"""
Hardware capability matching and device selection algorithms.
Determines optimal device placements based on hardware characteristics.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple, Any
import torch
import logging
from enum import Enum


class DeviceType(Enum):
    """Hardware device types."""
    CPU = "cpu"
    CUDA = "cuda"
    CUDA_INTEGRATED = "cuda_integrated"
    UNKNOWN = "unknown"


@dataclass
class HardwareCapability:
    """Complete hardware capability profile."""

    # Core identifiers
    device_id: str
    device_type: DeviceType
    device_name: str = "unknown"

    # Performance characteristics
    compute_score: float = 1.0  # Relative compute capacity (normalized)
    memory_gb: float = 0.0  # Total available memory
    has_fp16: bool = False  # FP16/BF16 support
    has_int8: bool = False  # INT8 quantization support

    # Network characteristics
    network_bandwidth_mbps: float = 1000.0  # Network bandwidth
    latency_to_coordinator_ms: float = 1.0  # Network latency

    # Power/frequency info
    power_limit_w: Optional[float] = None
    clock_frequency_mhz: Optional[float] = None

    # Inference-specific features
    optimized_for_transformers: bool = False  # Specialized hardware

    # Load characteristics
    current_load: float = 0.0  # Current utilization (0.0-1.0)
    available_memory_gb: float = 0.0

    def is_suitable_for_layer(self, layer_memory_gb: float, requires_fp16: bool = False) -> bool:
        """Check if device can accommodate layer."""
        if layer_memory_gb > self.available_memory_gb * 0.9:  # 90% safety margin
            return False

        if requires_fp16 and not self.has_fp16:
            return False

        return True

    def estimate_execution_time(self, baseline_latency_ms: float) -> float:
        """Estimate execution time accounting for device performance."""
        # Adjust for compute score and current load
        effective_score = self.compute_score * (1.0 - self.current_load)
        return baseline_latency_ms / max(effective_score, 0.1)


@dataclass
class LayerRequirements:
    """Requirements for layer execution."""

    layer_name: str
    layer_type: str

    # Resource requirements
    memory_gb: float  # Peak memory usage
    compute_millions: float  # Compute operations in millions (rough estimate)

    # Precision requirements
    precision: str = "fp32"  # fp32, fp16, bf16, int8
    tensor_parallelism_level: int = 1  # 1 = no TP, 2+ = TP degree

    # Feature requirements
    requires_fp16: bool = False
    requires_fast_memory: bool = True  # Prefers GPU memory
    is_latency_sensitive: bool = False  # Prefers faster devices

    # Execution characteristics
    reuse_factor: float = 1.0  # Data reuse (attention layers: >1.0)
    communication_intensity: float = 1.0  # Amount of data exchange


class CapabilityMatcher:
    """
    Matches layer requirements to hardware capabilities.

    Uses multiple strategies:
    1. Strict filtering by requirements
    2. Scoring-based ranking
    3. Cost model optimization
    """

    def __init__(self):
        self.logger = logging.getLogger("CapabilityMatcher")
        self.devices: Dict[str, HardwareCapability] = {}

    def register_device(self, capability: HardwareCapability):
        """Register device capability."""
        self.devices[capability.device_id] = capability

    def find_optimal_device(
        self,
        requirement: LayerRequirements,
        available_devices: Optional[List[str]] = None,
        strategy: str = "balanced"
    ) -> Tuple[Optional[str], float]:
        """
        Find optimal device for layer execution.

        Args:
            requirement: Layer requirements
            available_devices: List of device IDs to consider (None = all)
            strategy: Selection strategy ("balanced", "latency", "memory", "cost")

        Returns:
            (device_id, score) tuple or (None, 0.0) if no suitable device
        """
        candidates = self._filter_by_requirements(requirement, available_devices)

        if not candidates:
            self.logger.warning(f"No suitable devices found for layer {requirement.layer_name}")
            return None, 0.0

        # Score candidates
        scores = self._score_devices(candidates, requirement, strategy)

        # Select best
        best_device = max(scores, key=scores.get)
        best_score = scores[best_device]

        return best_device, best_score

    def _filter_by_requirements(
        self,
        requirement: LayerRequirements,
        available_devices: Optional[List[str]] = None
    ) -> Dict[str, HardwareCapability]:
        """Filter devices by hard requirements."""
        candidates = {}

        device_list = available_devices or self.devices.keys()

        for device_id in device_list:
            device = self.devices.get(device_id)
            if not device:
                continue

            # Check basic suitability
            if not device.is_suitable_for_layer(
                requirement.memory_gb,
                requirement.requires_fp16
            ):
                continue

            # Check memory availability
            if requirement.memory_gb > device.available_memory_gb:
                continue

            # Check load threshold
            if device.current_load > 0.95:  # Overloaded
                continue

            candidates[device_id] = device

        return candidates

    def _score_devices(
        self,
        candidates: Dict[str, HardwareCapability],
        requirement: LayerRequirements,
        strategy: str
    ) -> Dict[str, float]:
        """Score devices based on strategy."""

        if strategy == "latency":
            return self._score_for_latency(candidates, requirement)
        elif strategy == "memory":
            return self._score_for_memory(candidates, requirement)
        elif strategy == "cost":
            return self._score_for_cost(candidates, requirement)
        else:  # balanced
            return self._score_balanced(candidates, requirement)

    def _score_for_latency(
        self,
        candidates: Dict[str, HardwareCapability],
        requirement: LayerRequirements
    ) -> Dict[str, float]:
        """Score for minimum latency."""
        scores = {}

        for device_id, device in candidates.items():
            # Estimate execution time
            estimated_time = device.estimate_execution_time(requirement.compute_millions / 10)

            # Penalize network latency for communication-intense layers
            network_penalty = 0.0
            if requirement.communication_intensity > 1.0:
                network_penalty = device.latency_to_coordinator_ms * 0.1

            # Lower is better, so invert score
            scores[device_id] = 1000.0 / (estimated_time + network_penalty + 1.0)

        return scores

    def _score_for_memory(
        self,
        candidates: Dict[str, HardwareCapability],
        requirement: LayerRequirements
    ) -> Dict[str, float]:
        """Score for memory efficiency."""
        scores = {}

        for device_id, device in candidates.items():
            memory_usage_ratio = requirement.memory_gb / device.available_memory_gb

            # Prefer devices with more available memory
            # Also consider memory type
            memory_bonus = 1.0
            if requirement.requires_fast_memory and device.device_type in [DeviceType.CUDA, DeviceType.CUDA_INTEGRATED]:
                memory_bonus = 2.0

            scores[device_id] = (1.0 - memory_usage_ratio) * memory_bonus * 100.0

        return scores

    def _score_for_cost(
        self,
        candidates: Dict[str, HardwareCapability],
        requirement: LayerRequirements
    ) -> Dict[str, float]:
        """Score for cost efficiency (power/performance)."""
        scores = {}

        for device_id, device in candidates.items():
            # Estimate power consumption per operation
            power_efficiency = 1.0

            if device.power_limit_w:
                # Perf per watt
                power_efficiency = device.compute_score / (device.power_limit_w / 100.0)

            # Consider network cost
            network_cost = device.latency_to_coordinator_ms * 0.01

            scores[device_id] = power_efficiency - network_cost

        return scores

    def _score_balanced(
        self,
        candidates: Dict[str, HardwareCapability],
        requirement: LayerRequirements
    ) -> Dict[str, float]:
        """Balanced scoring considering multiple factors."""
        latency_scores = self._score_for_latency(candidates, requirement)
        memory_scores = self._score_for_memory(candidates, requirement)
        cost_scores = self._score_for_cost(candidates, requirement)

        # Weighted combination
        combined = {}

        for device_id in candidates:
            # Weight factors based on layer type
            latency_weight = 0.4
            memory_weight = 0.3
            cost_weight = 0.3

            if requirement.is_latency_sensitive:
                latency_weight = 0.7
                memory_weight = 0.2
                cost_weight = 0.1

            combined[device_id] = (
                latency_scores[device_id] * latency_weight +
                memory_scores[device_id] * memory_weight +
                cost_scores[device_id] * cost_weight
            )

        return combined

    def can_accommodate_model(
        self,
        requirements: List[LayerRequirements],
        devices: Optional[List[str]] = None
    ) -> Tuple[bool, Dict[str, List[str]]]:
        """
        Check if model can be fully accommodated.

        Returns:
            (feasible, assignment) where assignment maps device_id -> [layer_names]
        """
        assignment = {did: [] for did in (devices or self.devices.keys())}
        feasible = True

        for req in requirements:
            device_id, score = self.find_optimal_device(req, devices)

            if device_id is None:
                self.logger.error(f"Cannot place layer {req.layer_name}")
                feasible = False
                continue

            assignment[device_id].append(req.layer_name)

        return feasible, assignment

    def get_device_summary(self) -> Dict[str, Any]:
        """Get summary of all devices."""
        return {
            'total_devices': len(self.devices),
            'by_type': {
                dtype.value: sum(
                    1 for d in self.devices.values() if d.device_type == dtype
                )
                for dtype in DeviceType
            },
            'total_memory_gb': sum(d.memory_gb for d in self.devices.values()),
            'available_memory_gb': sum(d.available_memory_gb for d in self.devices.values()),
            'avg_compute_score': sum(d.compute_score for d in self.devices.values()) / len(self.devices),
        }


def auto_detect_capabilities() -> Dict[str, HardwareCapability]:
    """Auto-detect hardware capabilities on current machine."""
    capabilities = {}

    # CPU capability
    cpu_cap = HardwareCapability(
        device_id="cpu",
        device_type=DeviceType.CPU,
        device_name="CPU",
        compute_score=1.0,  # Baseline
        memory_gb=torch.torch.get_num_threads() * 2.0,  # Rough estimate
        available_memory_gb=torch.torch.get_num_threads() * 1.5,
        has_fp16=False,
        has_int8=True,
        network_bandwidth_mbps=1000.0,  # Local
        latency_to_coordinator_ms=0.1,
    )

    capabilities["cpu"] = cpu_cap

    # CUDA devices
    if torch.cuda.is_available():
        for i in range(torch.cuda.device_count()):
            props = torch.cuda.get_device_properties(i)

            # Detect if integrated GPU
            device_type = DeviceType.CUDA_INTEGRATED if props.integrated else DeviceType.CUDA

            # Compute score based on specs
            compute_score = (
                props.multi_processor_count * props.clock_rate / 1000000.0
            ) / 100.0  # Normalized

            # Detect FP16 support (assume compute >= 6.0 supports FP16)
            has_fp16 = float(props.major) >= 6.0

            cap = HardwareCapability(
                device_id=f"cuda:{i}",
                device_type=device_type,
                device_name=props.name,
                compute_score=compute_score,
                memory_gb=props.total_memory / (1024**3),
                available_memory_gb=(props.total_memory - torch.cuda.memory_allocated(i)) / (1024**3),
                has_fp16=has_fp16,
                has_int8=True,
                network_bandwidth_mbps=10000.0 if device_type != DeviceType.CUDA_INTEGRATED else 5000.0,
                latency_to_coordinator_ms=0.5 if device_type != DeviceType.CUDA_INTEGRATED else 1.0,
                clock_frequency_mhz=props.clock_rate / 1000.0,
                optimized_for_transformers=has_fp16,  # FP16 helps transformers
            )

            capabilities[f"cuda:{i}"] = cap

    return capabilities


# Utility functions

def create_requirement_from_metrics(
    layer_name: str,
    layer_metrics: Dict[str, Any],
    layer_type: str = "unknown"
) -> LayerRequirements:
    """Create LayerRequirements from Fase 1 metrics."""
    memory_gb = layer_metrics.get('peak_vram_after', 0) / (1024**3)

    # Estimate compute from latency
    latency_ms = layer_metrics.get('forward_latency_ms', 10.0)
    compute_millions = latency_ms * 1000.0  # Rough estimate

    return LayerRequirements(
        layer_name=layer_name,
        layer_type=layer_type,
        memory_gb=memory_gb,
        compute_millions=compute_millions,
        precision=layer_metrics.get('input_dtypes', ['fp32'])[0].replace('torch.', ''),
        is_latency_sensitive=latency_ms > 100.0,  # Mark slow layers as latency-sensitive
    )
