"""
Metrics collection system for tracking LLM execution behavior.
Collects latency, memory, tensor metadata and provides structured output.
"""

import time
import json
from dataclasses import dataclass, asdict, field
from typing import Dict, List, Optional, Any
from datetime import datetime
import psutil
import torch


@dataclass
class LayerMetrics:
    """Metrics for a single layer execution."""

    # Identifier
    layer_name: str
    layer_type: str
    layer_index: int

    # Latency metrics (seconds)
    forward_latency_ms: float = 0.0
    backward_latency_ms: float = 0.0
    p50_latency_ms: float = 0.0
    p95_latency_ms: float = 0.0
    p99_latency_ms: float = 0.0

    # Memory metrics (bytes)
    peak_vram_before: int = 0
    peak_vram_after: int = 0
    peak_vram_allocated: int = 0
    peak_ram_before: int = 0
    peak_ram_after: int = 0
    vram_increase: int = 0
    ram_increase: int = 0

    # Tensor metadata
    input_shapes: List[List[int]] = field(default_factory=list)
    output_shapes: List[List[int]] = field(default_factory=list)
    input_dtypes: List[str] = field(default_factory=list)
    output_dtypes: List[str] = field(default_factory=list)
    num_parameters: int = 0
    parameter_size_mb: float = 0.0

    # Model-specific (attention, etc.)
    num_attention_heads: Optional[int] = None
    hidden_size: Optional[int] = None
    sequence_length: Optional[int] = None

    # System
    device: str = "cpu"
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())

    # Custom metrics
    custom_metrics: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)

    def to_json(self) -> str:
        """Convert to JSON string."""
        return json.dumps(self.to_dict(), indent=2)


class MetricsCollector:
    """Collects and aggregates metrics for multiple layer executions."""

    def __init__(self):
        self.metrics_history: Dict[str, List[LayerMetrics]] = {}
        self.current_batch: List[LayerMetrics] = []
        self.process = psutil.Process()
        self.device_handles: Dict[str, Any] = {}

    def start_layer_monitoring(self, layer_name: str, layer_type: str, layer_idx: int) -> LayerMetrics:
        """Start monitoring a layer execution."""
        metrics = LayerMetrics(
            layer_name=layer_name,
            layer_type=layer_type,
            layer_index=layer_idx,
        )

        # Snapshot memory before
        if torch.cuda.is_available():
            torch.cuda.reset_peak_memory_stats()
            metrics.peak_vram_before = torch.cuda.memory_allocated()
        metrics.peak_ram_before = self.process.memory_info().rss

        metrics.device = str(torch.cuda.current_device()) if torch.cuda.is_available() else "cpu"

        self.current_batch.append(metrics)
        return metrics

    def stop_layer_monitoring(self, metrics: LayerMetrics, forward_latency_ms: float):
        """Stop monitoring and finalize metrics."""
        metrics.forward_latency_ms = forward_latency_ms

        # Snapshot memory after
        if torch.cuda.is_available():
            metrics.peak_vram_after = torch.cuda.memory_allocated()
            metrics.peak_vram_allocated = torch.cuda.max_memory_allocated()
        metrics.peak_ram_after = self.process.memory_info().rss

        # Calculate increases
        metrics.vram_increase = metrics.peak_vram_after - metrics.peak_vram_before
        metrics.ram_increase = metrics.peak_ram_after - metrics.peak_ram_before

        # Store in history
        if metrics.layer_name not in self.metrics_history:
            self.metrics_history[metrics.layer_name] = []
        self.metrics_history[metrics.layer_name].append(metrics)

    def record_tensor_metadata(self, metrics: LayerMetrics, inputs, outputs):
        """Record tensor shapes and dtypes."""
        if isinstance(inputs, torch.Tensor):
            inputs = [inputs]
        if isinstance(outputs, torch.Tensor):
            outputs = [outputs]

        for tensor in inputs:
            if isinstance(tensor, torch.Tensor):
                metrics.input_shapes.append(list(tensor.shape))
                metrics.input_dtypes.append(str(tensor.dtype))
            else:
                # Handle non-tensor inputs (tuples, dicts, etc.)
                if isinstance(tensor, (tuple, list)):
                    for subtensor in tensor:
                        if isinstance(subtensor, torch.Tensor):
                            metrics.input_shapes.append(list(subtensor.shape))
                            metrics.input_dtypes.append(str(subtensor.dtype))

        for tensor in outputs:
            if isinstance(tensor, torch.Tensor):
                metrics.output_shapes.append(list(tensor.shape))
                metrics.output_dtypes.append(str(tensor.dtype))

    def record_parameter_info(self, metrics: LayerMetrics, module: torch.nn.Module):
        """Record parameter count and size."""
        num_params = sum(p.numel() for p in module.parameters())
        param_size = sum(p.numel() * p.element_size() for p in module.parameters()) / (1024 * 1024)

        metrics.num_parameters = num_params
        metrics.parameter_size_mb = param_size

        # Try to extract model-specific info
        if hasattr(module, 'num_attention_heads'):
            metrics.num_attention_heads = module.num_attention_heads
        if hasattr(module, 'hidden_size'):
            metrics.hidden_size = module.hidden_size

    def finalize_batch(self):
        """Calculate aggregate statistics for the current batch."""
        for layer_name, runs in self.metrics_history.items():
            if len(runs) > 1:
                latencies = [run.forward_latency_ms for run in runs]
                latencies.sort()

                # Calculate percentiles
                runs[-1].p50_latency_ms = latencies[len(latencies) // 2]
                runs[-1].p95_latency_ms = latencies[int(len(latencies) * 0.95)]
                runs[-1].p99_latency_ms = latencies[int(len(latencies) * 0.99)]

    def get_summary(self) -> Dict[str, Any]:
        """Get aggregated summary of all metrics."""
        summary = {}
        for layer_name, runs in self.metrics_history.items():
            if not runs:
                continue

            latest = runs[-1]
            summary[layer_name] = {
                "layer_type": latest.layer_type,
                "total_runs": len(runs),
                "avg_latency_ms": sum(r.forward_latency_ms for r in runs) / len(runs),
                "p95_latency_ms": latest.p95_latency_ms,
                "total_vram_mb": latest.peak_vram_after / (1024 * 1024),
                "vram_increase_mb": latest.vram_increase / (1024 * 1024),
                "num_parameters": latest.num_parameters,
                "parameter_size_mb": latest.parameter_size_mb,
            }
        return summary

    def export_to_jsonl(self, filepath: str):
        """Export all metrics to JSONL file."""
        with open(filepath, 'w') as f:
            for layer_name, runs in self.metrics_history.items():
                for run in runs:
                    f.write(json.dumps(run.to_dict()) + '\n')
