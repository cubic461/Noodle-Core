"""
Logger implementation for structured output (JSONL) and metrics aggregation.
Enables persistent storage of profiling data for later analysis.
"""

import json
import logging
from pathlib import Path
from typing import List, Dict, Any, Optional, Union
from datetime import datetime
import pandas as pd
from .metrics import MetricsCollector


class StructuredLogger:
    """Structured logging system for JSONL output."""

    def __init__(
        self,
        log_dir: Union[str, Path] = "data/logs",
        log_level: str = "INFO",
    ):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)

        # Setup logging
        self.logger = logging.getLogger("noodle-poc")
        self.logger.setLevel(getattr(logging, log_level.upper()))

        # File handler for JSONL
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.jsonl_path = self.log_dir / f"metrics_{timestamp}.jsonl"
        self.file_handler = logging.FileHandler(self.jsonl_path)
        self.file_handler.setLevel(logging.INFO)
        self.logger.addHandler(self.file_handler)

        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        console_handler.setFormatter(formatter)
        self.logger.addHandler(console_handler)

    def log_metrics(self, metrics_collector: MetricsCollector):
        """Log all metrics from a MetricsCollector."""
        try:
            summary = metrics_collector.get_summary()

            # Log summary
            self.logger.info("=== Metrics Summary ===")
            for layer_name, data in summary.items():
                self.logger.info(
                    f"{layer_name}: "
                    f"avg_lat={data['avg_latency_ms']:.2f}ms, "
                    f"p95={data['p95_latency_ms']:.2f}ms, "
                    f"vram={data['total_vram_mb']:.2f}MB, "
                    f"params={data['num_parameters']:,}"
                )

            # Export to JSONL
            metrics_collector.export_to_jsonl(self._get_metrics_jsonl_path())

        except Exception as e:
            self.logger.error(f"Error logging metrics: {e}")

    def log_config(self, config: Dict[str, Any]):
        """Log configuration parameters."""
        self.logger.info("=== Configuration ===")
        self.logger.info(json.dumps(config, indent=2))
        config["timestamp"] = datetime.now().isoformat()

        # Save config
        config_file = self.log_dir / f"config_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)

    def log_observation(self, observation: Dict[str, Any]):
        """Log a single observation (for real-time monitoring)."""
        try:
            observation["timestamp"] = datetime.utcnow().isoformat()
            log_entry = json.dumps(observation)

            # Write to JSONL file
            with open(self.jsonl_path, 'a') as f:
                f.write(log_entry + '\n')

            self.logger.debug(f"Observation logged: {observation.get('layer_name', 'unknown')}")

        except Exception as e:
            self.logger.error(f"Error writing observation: {e}")

    def log_system_info(self):
        """Log system information."""
        import psutil
        import torch

        system_info = {
            "cpu_count": psutil.cpu_count(),
            "total_ram_gb": psutil.virtual_memory().total / (1024**3),
            "available_ram_gb": psutil.virtual_memory().available / (1024**3),
        }

        if torch.cuda.is_available():
            system_info["gpu_count"] = torch.cuda.device_count()
            system_info["cuda_version"] = torch.version.cuda

            for i in range(torch.cuda.device_count()):
                props = torch.cuda.get_device_properties(i)
                system_info[f"gpu_{i}_name"] = props.name
                system_info[f"gpu_{i}_total_memory_gb"] = props.total_memory / (1024**3)

        self.logger.info("=== System Info ===")
        self.logger.info(json.dumps(system_info, indent=2))

        # Save to file
        sysinfo_file = self.log_dir / f"system_info_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(sysinfo_file, 'w') as f:
            json.dump(system_info, f, indent=2)

    def _get_metrics_jsonl_path(self) -> Path:
        """Get path for metrics JSONL file."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        return self.log_dir.parent / f"metrics_{timestamp}.jsonl"

    def to_dataframe(self, filepath: Optional[Path] = None) -> pd.DataFrame:
        """Load metrics JSONL into a pandas DataFrame for analysis."""
        if filepath is None:
            filepath = self.jsonl_path

        if not filepath.exists():
            raise FileNotFoundError(f"Metrics file not found: {filepath}")

        # Read JSONL
        data = []
        with open(filepath, 'r') as f:
            for line in f:
                data.append(json.loads(line))

        return pd.DataFrame(data)

    def get_summary_stats(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate summary statistics from DataFrame."""
        summary = {
            "total_layers": df['layer_name'].nunique(),
            "total_runs": len(df),
            "total_forward_latency_sec": df['forward_latency_ms'].sum() / 1000,
            "avg_forward_latency_ms": df['forward_latency_ms'].mean(),
            "memory_intensive_layers": df.nlargest(5, 'peak_vram_after')['layer_name'].tolist(),
            "latency_intensive_layers": df.nlargest(5, 'forward_latency_ms')['layer_name'].tolist(),
        }

        # Per-layer statistics
        per_layer_stats = df.groupby('layer_name').agg({
            'forward_latency_ms': ['mean', 'std', 'min', 'max', 'count'],
            'peak_vram_after': 'mean',
            'num_parameters': 'first',
        }).to_dict()

        summary["per_layer_stats"] = per_layer_stats

        return summary

    def export_to_csv(self, df: pd.DataFrame, filepath: Path):
        """Export DataFrame to CSV for external analysis."""
        df.to_csv(filepath, index=False)

    def close(self):
        """Clean up and close handlers."""
        self.file_handler.close()
        self.logger.removeHandler(self.file_handler)

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - cleanup."""
        self.close()


class MetricsAggregator:
    """Aggregate multiple profiling runs and compute statistics."""

    def __init__(self, jsonl_files: List[Path]):
        self.jsonl_files = jsonl_files
        self.dataframes: Dict[Path, pd.DataFrame] = {}

    def load_all(self):
        """Load all JSONL files into memory."""
        for file in self.jsonl_files:
            if file.exists():
                df = pd.read_json(file, lines=True)
                self.dataframes[file] = df

    def compare_runs(
        self,
        metric: str = 'forward_latency_ms',
        group_by: str = 'layer_name'
    ) -> pd.DataFrame:
        """Compare the same metric across different runs."""
        comparisons = []

        for file, df in self.dataframes.items():
            grouped = df.groupby(group_by)[metric].mean().to_dict()
            comparisons.append({
                'run': file.stem,
                **grouped
            })

        return pd.DataFrame(comparisons)

    def identify_bottlenecks(self, threshold_p95_ms: float = 50.0) -> Dict[str, Any]:
        """Identify performance bottlenecks."""
        bottlenecks = {}

        for file, df in self.dataframes.items():
            slow_layers = df[df['forward_latency_ms'] > threshold_p95_ms]
            bottlenecks[file.stem] = {
                'num_bottlenecks': len(slow_layers),
                'bottleneck_layers': slow_layers['layer_name'].unique().tolist(),
                'total_impact_ms': slow_layers['forward_latency_ms'].sum(),
            }

        return bottlenecks

    def export_report(
        self,
        output_file: Path,
        format: str = 'html'
    ):
        """Export aggregated report."""
        if format == 'html':
            self._export_html_report(output_file)
        elif format == 'json':
            self._export_json_report(output_file)
        else:
            raise ValueError(f"Unsupported format: {format}")

    def _export_html_report(self, output_file: Path):
        """Export as HTML report."""
        with open(output_file, 'w') as f:
            f.write("<html><body>")
            f.write("<h1>NoodleCore Observability Report</h1>")

            for file, df in self.dataframes.items():
                f.write(f"<h2>Run: {file.stem}</h2>")
                f.write(df.describe().to_html())
                f.write("<hr>")

            f.write("</body></html>")

    def _export_json_report(self, output_file: Path):
        """Export as JSON report."""
        report = {
            'aggregation_timestamp': datetime.now().isoformat(),
            'total_runs': len(self.dataframes),
            'runs': {}
        }

        for file, df in self.dataframes.items():
            report['runs'][file.stem] = {
                'total_rows': len(df),
                'layers_profiled': df['layer_name'].nunique(),
                'mean_latency': df['forward_latency_ms'].mean(),
                'total_memory_mb': df['peak_vram_after'].max() / (1024**2),
            }

        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
