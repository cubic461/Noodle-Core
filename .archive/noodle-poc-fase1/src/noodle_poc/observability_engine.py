"""
Main observability engine coordinating metrics collection, logging, and visualization.
Main entry point for profiling LLM models.
"""

import torch
import torch.nn as nn
from typing import Optional, Dict, Any, Union, List
from pathlib import Path
from tqdm import tqdm
import yaml
import argparse
import sys

from .metrics import MetricsCollector, LayerMetrics
from .hooks import ModelInstrumentor, instrument_transformer_blocks
from .logger import StructuredLogger
from .dashboard import DashboardGenerator


class ObservabilityEngine:
    """
    Main engine for observing and profiling LLM execution.

    Coordinates:
    - Metrics collection (latency, memory, tensors)
    - Hook registration on model layers
    - Profiling runs and warmup
    - Output to structured logs and dashboards
    """

    def __init__(
        self,
        model: Optional[nn.Module] = None,
        log_dir: Optional[Path] = None,
        config: Optional[Dict[str, Any]] = None,
    ):
        """
        Initialize the observability engine.

        Args:
            model: PyTorch model to profile (can be set later)
            log_dir: Directory for logs and outputs
            config: Configuration dictionary
        """
        self.model = model
        self.log_dir = Path(log_dir) if log_dir else Path("data/metrics")
        self.log_dir.mkdir(parents=True, exist_ok=True)

        self.config = config or {}
        self._setup_components()

    def _setup_components(self):
        """Initialize internal components."""
        self.metrics_collector = MetricsCollector()
        self.instrumentor = ModelInstrumentor(self.metrics_collector)
        self.logger = StructuredLogger(
            log_dir=self.log_dir / "logs",
            log_level=self.config.get("log_level", "INFO")
        )

        # Profiling state
        self.is_instrumented = False
        self.hook_handles: List[Any] = []

    def set_model(self, model: nn.Module):
        """Set the model to be profiled."""
        self.model = model

    def instrument(self, model: Optional[nn.Module] = None):
        """
        Instrument the model with monitoring hooks.

        Args:
            model: Optional model (uses self.model if not provided)
        """
        target_model = model or self.model
        if target_model is None:
            raise ValueError("No model provided to instrument")

        self.logger.logger.info("🔧 Instrumenting model with hooks...")

        # Strategy 1: Use generic instrumentor for all named modules
        self.instrumentor.instrument_model(target_model)

        # Strategy 2: Use specialized hooks for Transformers (faster, less overhead)
        if self._is_transformer_model(target_model):
            self.logger.logger.info("Detected Transformer model - using specialized hooks")
            self.hook_handles = instrument_transformer_blocks(target_model, self.metrics_collector)

        self.model = target_model
        self.is_instrumented = True

        self.logger.logger.info(f"✅ Instrumented {len(self.instrumentor.layer_mappings)} layers")

    def _is_transformer_model(self, model: nn.Module) -> bool:
        """Check if model is a known Transformer architecture."""
        return (
            hasattr(model, 'transformer') or
            hasattr(model, 'encoder') or
            hasattr(model, 'decoder')
        )

    def warmup(
        self,
        sample_inputs: Union[torch.Tensor, Dict[str, torch.Tensor]],
        num_warmup_runs: Optional[int] = None,
    ):
        """
        Perform warmup runs to stabilize measurements.

        Args:
            sample_inputs: Sample inputs for model (can be tokens, dict, etc.)
            num_warmup_runs: Number of warmup runs (from config if not provided)
        """
        num_warmup_runs = num_warmup_runs or self.config.get("num_warmup_runs", 10)

        if not self.is_instrumented:
            raise RuntimeError("Model must be instrumented before warmup")

        self.logger.logger.info(f"🔥 Warming up with {num_warmup_runs} runs...")

        self.model.eval()
        with torch.no_grad():
            for _ in tqdm(range(num_warmup_runs), desc="Warmup", leave=False):
                try:
                    # Clear previous run metrics
                    self.metrics_collector.current_batch.clear()

                    # Forward pass
                    if isinstance(sample_inputs, dict):
                        outputs = self.model(**sample_inputs)
                    else:
                        outputs = self.model(sample_inputs)

                    # Move outputs to CPU to free memory
                    if isinstance(outputs, torch.Tensor):
                        outputs = outputs.cpu()
                    elif isinstance(outputs, dict):
                        outputs = {k: v.cpu() if isinstance(v, torch.Tensor) else v
                                   for k, v in outputs.items()}

                    torch.cuda.empty_cache() if torch.cuda.is_available() else None

                except Exception as e:
                    self.logger.logger.error(f"Warmup error: {e}")
                    break

        self.metrics_collector.metrics_history.clear()  # Don't keep warmup metrics
        self.logger.logger.info("✅ Warmup complete")

    def profile(
        self,
        inputs: Union[torch.Tensor, Dict[str, torch.Tensor]],
        num_runs: Optional[int] = None,
        profile_name: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Profile the model with given inputs.

        Args:
            inputs: Model inputs (tokens, attention masks, etc.)
            num_runs: Number of profiling runs (from config if not provided)
            profile_name: Name for this profiling session

        Returns:
            Dictionary with profiling results
        """
        num_runs = num_runs or self.config.get("num_profile_runs", 100)
        profile_name = profile_name or self.config.get("model_name", "unknown_model")

        if not self.is_instrumented:
            raise RuntimeError("Model must be instrumented before profiling")

        self.logger.logger.info(f"🔍 Starting profiling for '{profile_name}' ({num_runs} runs)")

        self.model.eval()
        total_times = []

        with torch.no_grad():
            for run_idx in tqdm(range(num_runs), desc=f"Profiling {profile_name}"):
                try:
                    # Start timer for complete forward pass
                    start_time = torch.cuda.Event(enable_timing=True) if torch.cuda.is_available() else None
                    end_time = torch.cuda.Event(enable_timing=True) if torch.cuda.is_available() else None

                    if start_time:
                        start_time.record()

                    # Forward pass
                    if isinstance(inputs, dict):
                        outputs = self.model(**inputs)
                    else:
                        outputs = self.model(inputs)

                    if end_time:
                        end_time.record()

                    # Synchronize and compute total time
                    if torch.cuda.is_available():
                        torch.cuda.synchronize()
                        total_time_ms = start_time.elapsed_time(end_time)
                        total_times.append(total_time_ms)

                    # Clear outputs and cache
                    if isinstance(outputs, torch.Tensor):
                        outputs = outputs.cpu()
                    elif isinstance(outputs, dict):
                        outputs = {k: v.cpu() if isinstance(v, torch.Tensor) else v
                                   for k, v in outputs.items()}

                    torch.cuda.empty_cache() if torch.cuda.is_available() else None

                    # Finalize batch (compute percentiles)
                    if (run_idx + 1) % 10 == 0:  # Every 10 runs
                        self.metrics_collector.finalize_batch()

                except Exception as e:
                    self.logger.logger.error(f"Profiling error on run {run_idx}: {e}")
                    break

        # Final finalize
        self.metrics_collector.finalize_batch()

        # Generate report
        report = {
            'profile_name': profile_name,
            'num_runs': num_runs,
            'total_layers': len(self.instrumentor.layer_mappings),
            'layer_summary': self.metrics_collector.get_summary(),
        }

        if total_times:
            report['end_to_end_latency'] = {
                'mean_ms': sum(total_times) / len(total_times),
                'total_ms': sum(total_times),
                'num_runs': len(total_times),
            }

        # Log metrics and save
        self.logger.log_metrics(self.metrics_collector)
        self.logger.log_system_info()

        self.logger.logger.info(f"✅ Profiling complete: {len(self.metrics_collector.metrics_history)} layers profiled")

        return report

    def save_dashboard(self, output_name: Optional[str] = None):
        """Generate and save dashboard visualization."""
        output_name = output_name or self.config.get("model_name", "dashboard")

        # Export metrics to JSONL for dashboard
        jsonl_path = self.log_dir / f"{output_name}_metrics.jsonl"
        self.metrics_collector.export_to_jsonl(jsonl_path)

        # Generate dashboard
        dashboard_path = self.log_dir / f"{output_name}_dashboard.html"

        try:
            dashboard = DashboardGenerator.from_jsonl(jsonl_path)
            dashboard.export_html(dashboard_path)
            self.logger.logger.info(f"📊 Dashboard saved: {dashboard_path}")

            # Bottleneck analysis
            bottlenecks = dashboard.get_bottleneck_analysis()
            self.logger.logger.info("🔴 Top Bottlenecks:")
            for i, bn in enumerate(bottlenecks['top_bottlenecks'][:5], 1):
                self.logger.logger.info(
                    f"  {i}. {bn['layer_name']}: {bn['latency_pct']:.2f}% "
                    f"({bn['forward_latency_ms']:.2f}ms)"
                )

        except Exception as e:
            self.logger.logger.error(f"Error generating dashboard: {e}")

    def finalize(self):
        """Clean up and finalize profiling session."""
        self.logger.logger.info("🧹 Cleaning up...")
        self.instrumentor.remove_hooks()
        for handle in self.hook_handles:
            handle.remove()
        self.hook_handles.clear()
        self.is_instrumented = False

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - cleanup."""
        if self.is_instrumented:
            self.finalize()
        self.logger.close()

    @classmethod
    def from_config(cls, config_path: Path, model: Optional[nn.Module] = None):
        """Load configuration from YAML file."""
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)

        return cls(model=model, config=config)


def main():
    """Main entry point for CLI usage."""
    parser = argparse.ArgumentParser(description="NoodleCore Observability Engine")
    parser.add_argument(
        '--config',
        type=str,
        default='config/default_config.yaml',
        help='Path to configuration file'
    )
    parser.add_argument(
        '--model-name',
        type=str,
        help='Model name to profile (overrides config)'
    )
    parser.add_argument(
        '--num-samples',
        type=int,
        help='Number of profiling samples (overrides config)'
    )
    parser.add_argument(
        '--output-dir',
        type=str,
        help='Output directory for results (overrides config)'
    )

    args = parser.parse_args()

    # Load configuration
    try:
        engine = ObservabilityEngine.from_config(Path(args.config))
    except Exception as e:
        print(f"Error loading config: {e}")
        sys.exit(1)

    # Override config with CLI args
    if args.model_name:
        engine.config['model_name'] = args.model_name
    if args.num_samples:
        engine.config['num_profile_runs'] = args.num_samples
    if args.output_dir:
        engine.log_dir = Path(args.output_dir)
        engine.logger.log_dir = engine.log_dir / "logs"

    # Example usage (placeholder - would need actual model loading)
    print("✅ Observability Engine initialized")
    print(f"   Config: {engine.config}")
    print(f"   Output: {engine.log_dir}")

    # Usage example:
    # 1. Load your model
    # 2. Create sample inputs
    # 3. instrument() -> warmup() -> profile() -> save_dashboard() -> finalize()


if __name__ == '__main__':
    main()
