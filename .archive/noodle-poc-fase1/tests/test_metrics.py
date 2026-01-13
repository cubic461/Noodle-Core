"""
Unit tests for metrics collection system.
"""

import pytest
import torch
import torch.nn as nn
from src.metrics import MetricsCollector, LayerMetrics


class TestLayerMetrics:
    """Tests for LayerMetrics dataclass."""

    def test_basic_creation(self):
        """Test basic LayerMetrics creation."""
        metrics = LayerMetrics(
            layer_name="test_layer",
            layer_type="Linear",
            layer_index=0
        )

        assert metrics.layer_name == "test_layer"
        assert metrics.layer_type == "Linear"
        assert metrics.layer_index == 0
        assert isinstance(metrics.timestamp, str)

    def test_to_dict(self):
        """Test conversion to dictionary."""
        metrics = LayerMetrics(
            layer_name="test",
            layer_type="Conv2d",
            layer_index=1
        )

        result = metrics.to_dict()
        assert isinstance(result, dict)
        assert result["layer_name"] == "test"
        assert result["layer_type"] == "Conv2d"

    def test_to_json(self):
        """Test JSON serialization."""
        metrics = LayerMetrics(
            layer_name="test",
            layer_type="LayerNorm",
            layer_index=2
        )

        json_str = metrics.to_json()
        assert isinstance(json_str, str)
        assert "test" in json_str


class TestMetricsCollector:
    """Tests for MetricsCollector."""

    @pytest.fixture
    def collector(self):
        """Create a MetricsCollector instance."""
        return MetricsCollector()

    def test_initialization(self, collector):
        """Test collector initialization."""
        assert collector.metrics_history == {}
        assert collector.current_batch == []
        assert isinstance(collector.process.pid, int)

    def test_start_layer_monitoring(self, collector):
        """Test starting layer monitoring."""
        metrics = collector.start_layer_monitoring(
            layer_name="linear_0",
            layer_type="Linear",
            layer_idx=0
        )

        assert isinstance(metrics, LayerMetrics)
        assert metrics.layer_name == "linear_0"
        assert metrics.layer_type == "Linear"
        assert len(collector.current_batch) == 1

    def test_stop_layer_monitoring(self, collector):
        """Test stopping layer monitoring."""
        metrics = collector.start_layer_monitoring("test", "Linear", 0)
        collector.stop_layer_monitoring(metrics, 10.5)

        assert metrics.forward_latency_ms == 10.5
        assert "test" in collector.metrics_history
        assert len(collector.metrics_history["test"]) == 1

    def test_record_tensor_metadata(self, collector):
        """Test tensor metadata recording."""
        metrics = collector.start_layer_monitoring("test", "Linear", 0)

        # Create sample tensors
        input_tensor = torch.randn(1, 10)
        output_tensor = torch.randn(1, 20)

        collector.record_tensor_metadata(metrics, input_tensor, output_tensor)

        assert len(metrics.input_shapes) == 1
        assert len(metrics.output_shapes) == 1
        assert metrics.input_shapes[0] == [1, 10]
        assert metrics.output_shapes[0] == [1, 20]

    def test_record_parameter_info(self, collector):
        """Test parameter info recording."""
        metrics = collector.start_layer_monitoring("test", "Linear", 0)

        # Create a simple module
        module = nn.Linear(10, 20)
        collector.record_parameter_info(metrics, module)

        assert metrics.num_parameters == 10 * 20 + 20  # weights + bias
        assert metrics.parameter_size_mb > 0

    @pytest.mark.skipif(not torch.cuda.is_available(), reason="CUDA not available")
    def test_cuda_memory_tracking(self, collector):
        """Test CUDA memory tracking (requires GPU)."""
        metrics = collector.start_layer_monitoring("test", "Linear", 0)

        # Create GPU tensor to trigger memory usage
        tensor = torch.randn(1000, 1000, device='cuda')

        collector.stop_layer_monitoring(metrics, 5.0)

        assert metrics.peak_vram_before >= 0
        assert metrics.peak_vram_after > 0
        assert metrics.vram_increase > 0

    def test_finalize_batch(self, collector):
        """Test batch finalization with percentile calculation."""
        # Create multiple runs
        for i in range(10):
            metrics = collector.start_layer_monitoring("test_layer", "Linear", i)
            collector.stop_layer_monitoring(metrics, float(i + 1))

        collector.finalize_batch()

        # Check if percentiles are calculated
        latest = collector.metrics_history["test_layer"][-1]
        assert latest.p50_latency_ms > 0
        assert latest.p95_latency_ms > 0
        assert latest.p99_latency_ms > 0

    def test_get_summary(self, collector):
        """Test summary generation."""
        # Create sample metrics
        for i in range(3):
            metrics = collector.start_layer_monitoring(f"layer_{i}", "Linear", i)
            collector.stop_layer_monitoring(metrics, 10.0 * (i + 1))

        summary = collector.get_summary()

        assert isinstance(summary, dict)
        assert len(summary) == 3
        assert "layer_0" in summary
        assert summary["layer_0"]["avg_latency_ms"] == 10.0

    def test_export_to_jsonl(self, collector, tmp_path):
        """Test JSONL export."""
        # Create sample metrics
        metrics = collector.start_layer_monitoring("test", "Linear", 0)
        collector.stop_layer_monitoring(metrics, 10.0)

        # Export to file
        output_file = tmp_path / "metrics.jsonl"
        collector.export_to_jsonl(str(output_file))

        # Check if file was created and contains data
        assert output_file.exists()
        with open(output_file, 'r') as f:
            line = f.readline()
            assert "test" in line
            assert "forward_latency_ms" in line


class TestIntegration:
    """Integration tests for real model profiling."""

    def test_simple_model_profiling(self):
        """Test profiling a simple model."""
        collector = MetricsCollector()

        # Create a simple model
        model = nn.Sequential(
            nn.Linear(10, 20),
            nn.ReLU(),
            nn.Linear(20, 5)
        )

        # Register hooks manually (simplified)
        hooks = []
        for name, module in model.named_modules():
            if name != "" and isinstance(module, nn.Linear):
                metrics = collector.start_layer_monitoring(name, "Linear", 0)

                # Simulate forward pass
                input_tensor = torch.randn(1, 10)
                output_tensor = module(input_tensor)

                collector.record_tensor_metadata(metrics, input_tensor, output_tensor)
                collector.record_parameter_info(metrics, module)
                collector.stop_layer_monitoring(metrics, 5.0)

        # Check results
        summary = collector.get_summary()
        assert len(summary) >= 2  # At least 2 Linear layers

    def test_multiple_runs_aggregation(self):
        """Test metrics aggregation over multiple runs."""
        collector = MetricsCollector()

        # Simulate 5 runs of the same layer
        for run in range(5):
            metrics = collector.start_layer_monitoring("test_layer", "Linear", run)
            collector.stop_layer_monitoring(metrics, float(run + 1))

        # Finalize and check aggregation
        collector.finalize_batch()
        summary = collector.get_summary()

        assert summary["test_layer"]["total_runs"] == 5
        avg_latency = sum(range(1, 6)) / 5  # Average of [1,2,3,4,5]
        assert abs(summary["test_layer"]["avg_latency_ms"] - avg_latency) < 0.01
