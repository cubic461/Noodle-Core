"""
Tests for capability matcher.
"""

import pytest
from ..core import (
    DeviceType,
    HardwareCapability,
    LayerRequirements,
    CapabilityMatcher,
    auto_detect_capabilities,
)
import torch


class TestHardwareCapability:
    """Tests for HardwareCapability."""

    def test_creation(self):
        """Test basic creation."""
        cap = HardwareCapability(
            device_id="test",
            device_type=DeviceType.CPU,
            memory_gb=16.0,
        )

        assert cap.device_id == "test"
        assert cap.device_type == DeviceType.CPU
        assert cap.memory_gb == 16.0

    def test_suitability_check(self):
        """Test layer suitability."""
        cap = HardwareCapability(
            device_id="test",
            device_type=DeviceType.CUDA,
            memory_gb=8.0,
            available_memory_gb=6.0,
        )

        assert cap.is_suitable_for_layer(1.0)
        assert not cap.is_suitable_for_layer(10.0)
        assert not cap.is_suitable_for_layer(1.0, requires_fp16=True)
        cap.has_fp16 = True
        assert cap.is_suitable_for_layer(1.0, requires_fp16=True)

    def test_execution_time_estimate(self):
        """Test execution time estimation."""
        cap = HardwareCapability(
            device_id="test",
            device_type=DeviceType.CUDA,
            compute_score=2.0,
            current_load=0.0,
        )

        # 100ms baseline should take 50ms on 2x compute
        estimated = cap.estimate_execution_time(100.0)
        assert estimated == 50.0

        # With load, should take longer
        cap.current_load = 0.5
        estimated = cap.estimate_execution_time(100.0)
        assert estimated == 100.0  # 100 / (2.0 * 0.5)


class TestLayerRequirements:
    """Tests for LayerRequirements."""

    def test_creation(self):
        """Test basic creation."""
        req = LayerRequirements(
            layer_name="test_layer",
            layer_type="Linear",
            memory_gb=2.0,
            compute_millions=1000.0,
        )

        assert req.layer_name == "test_layer"
        assert req.memory_gb == 2.0
        assert req.precision == "fp32"


class TestCapabilityMatcher:
    """Tests for CapabilityMatcher."""

    @pytest.fixture
    def matcher(self):
        """Create a matcher with test devices."""
        matcher = CapabilityMatcher()

        # Add CPU
        cpu_cap = HardwareCapability(
            device_id="cpu",
            device_type=DeviceType.CPU,
            device_name="Test CPU",
            compute_score=1.0,
            memory_gb=16.0,
            available_memory_gb=14.0,
        )

        matcher.register_device(cpu_cap)

        # Add GPU
        gpu_cap = HardwareCapability(
            device_id="cuda:0",
            device_type=DeviceType.CUDA,
            device_name="Test GPU",
            compute_score=10.0,
            memory_gb=8.0,
            available_memory_gb=7.0,
            has_fp16=True,
        )

        matcher.register_device(gpu_cap)

        return matcher

    def test_register_device(self, matcher):
        """Test device registration."""
        assert len(matcher.devices) == 2
        assert "cpu" in matcher.devices
        assert "cuda:0" in matcher.devices

    def test_filter_by_requirements(self, matcher):
        """Test device filtering."""
        req = LayerRequirements(
            layer_name="test",
            layer_type="Linear",
            memory_gb=1.0,
            compute_millions=100.0,
            requires_fp16=True,
        )

        filtered = matcher._filter_by_requirements(req)
        assert "cuda:0" in filtered  # Has FP16
        assert "cpu" not in filtered  # No FP16

    def test_find_optimal_device_balanced(self, matcher):
        """Test balanced device selection."""
        req = LayerRequirements(
            layer_name="test",
            layer_type="Linear",
            memory_gb=0.5,
            compute_millions=100.0,
        )

        device_id, score = matcher.find_optimal_device(req, strategy="balanced")
        assert device_id == "cuda:0"  # Faster device
        assert score > 0

    def test_find_optimal_device_latency(self, matcher):
        """Test latency-focused selection."""
        req = LayerRequirements(
            layer_name="test",
            layer_type="Linear",
            memory_gb=0.5,
            compute_millions=100.0,
        )

        device_id, score = matcher.find_optimal_device(req, strategy="latency")
        assert device_id == "cuda:0"  # Faster device
        assert score > 0

    def test_find_optimal_device_memory(self, matcher):
        """Test memory-focused selection."""
        req = LayerRequirements(
            layer_name="test",
            layer_type="Linear",
            memory_gb=2.0,
            compute_millions=100.0,
        )

        device_id, score = matcher.find_optimal_device(req, strategy="memory")

        # CPU has more memory available
        assert device_id in ["cpu", "cuda:0"]
        assert score > 0

    def test_no_suitable_device(self, matcher):
        """Test case where no device is suitable."""
        req = LayerRequirements(
            layer_name="test",
            layer_type="Linear",
            memory_gb=20.0,  # Exceeds all device memory
            compute_millions=100.0,
        )

        device_id, score = matcher.find_optimal_device(req)
        assert device_id is None
        assert score == 0.0

    def test_can_accommodate_model(self, matcher):
        """Test full model accommodation check."""
        requirements = [
            LayerRequirements("layer1", "Linear", 1.0, 100.0),
            LayerRequirements("layer2", "LayerNorm", 0.5, 50.0),
        ]

        feasible, assignment = matcher.can_accommodate_model(requirements)
        assert feasible

        # Both layers should be assigned
        all_assigned = sum(len(layers) for layers in assignment.values())
        assert all_assigned == 2

    def test_can_accommodate_model_infeasible(self, matcher):
        """Test infeasible model accommodation."""
        requirements = [
            LayerRequirements("layer1", "Linear", 1.0, 100.0),
            LayerRequirements("layer2", "Linear", 100.0, 100.0),  # Too large
        ]

        feasible, assignment = matcher.can_accommodate_model(requirements)
        assert not feasible

    def test_get_device_summary(self, matcher):
        """Test device summary."""
        summary = matcher.get_device_summary()
        assert summary['total_devices'] == 2
        assert DeviceType.CPU.value in summary['by_type']
        assert summary['total_memory_gb'] > 0


def test_auto_detect_capabilities():
    """Test automatic capability detection."""
    capabilities = auto_detect_capabilities()

    assert "cpu" in capabilities

    if torch.cuda.is_available():
        assert len(capabilities) > 1
        assert "cuda:0" in capabilities

        cuda_cap = capabilities["cuda:0"]
        assert cuda_cap.device_type in [DeviceType.CUDA, DeviceType.CUDA_INTEGRATED]
        assert cuda_cap.memory_gb > 0
    else:
        assert len(capabilities) == 1
