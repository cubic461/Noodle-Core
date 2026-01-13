#!/usr/bin/env python3
"""
Partition plan data structures and VirtualNode definitions.

Defines the core data structures for distributed execution planning:
- VirtualNode: Hardware capability representation
- Stage: A partitioned model segment
- PartitionPlan: Complete execution plan with optimization metadata
"""

import json
import time
from dataclasses import dataclass, asdict, field
from typing import List, Dict, Optional, Any
from enum import Enum
import numpy as np


class DeviceType(Enum):
    """Enum for device types."""
    CPU = "cpu"
    GPU = "gpu"
    IGPU = "igpu"  # Integrated GPU

    def __str__(self):
        return self.value


class PartitionStrategy(Enum):
    """Partitioning strategies."""
    BALANCED = "balanced"  # Distribute latency evenly
    BOTTLENECK_FIRST = "bottleneck_first"  # Prioritize slowest layers
    MEMORY_AWARE = "memory_aware"  # Optimize for memory usage
    LATENCY_OPTIMIZED = "latency_optimized"  # Minimize end-to-end latency

    def __str__(self):
        return self.value


@dataclass
class VirtualNode:
    """
    Represents a hardware node in distributed execution.
    
    Can be GPU, integrated GPU, or CPU with different capabilities.
    """
    
    # Core identifiers
    node_id: str
    device_type: DeviceType
    
    # Compute capabilities
    compute_score: float = 100.0  # Higher is better (FLOPs equivalent)
    vram_gb: float = 0.0
    ram_gb: float = 0.0
    
    # Memory bandwidth (GB/s)
    memory_bandwidth_gbs: float = 100.0
    
    # Network characteristics
    network_latency_ms: float = 0.5  # RTT to coordinator
    bandwidth_mbps: float = 10000.0  # Network bandwidth (Mbps)
    
    # Features
    supports_fp16: bool = True
    supports_fp32: bool = True
    supports_int8: bool = False
    
    # Utilization (runtime)
    current_utilization: float = 0.0
    max_utilization: float = 0.95
    
    def __post_init__(self):
        """Validate and normalize node data."""
        self.vram_gb = max(0.0, self.vram_gb)
        self.ram_gb = max(0.0, self.ram_gb)
        self.compute_score = max(1.0, self.compute_score)
        
    @property
    def available_vram_gb(self) -> float:
        """Available VRAM accounting for utilization."""
        return self.vram_gb * (1.0 - self.current_utilization)
    
    @property
    def available_ram_gb(self) -> float:
        """Available RAM accounting for utilization."""
        return self.ram_gb * (1.0 - self.current_utilization)
    
    @property
    def is_idle(self) -> bool:
        """Check if node is idle."""
        return self.current_utilization < 0.1
    
    def can_fit(self, memory_mb: float) -> bool:
        """Check if node can fit memory requirement."""
        available = self.available_vram_gb if self.device_type == DeviceType.GPU else self.available_ram_gb
        return memory_mb / 1024.0 <= available
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        data = asdict(self)
        data['device_type'] = self.device_type.value
        return data
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'VirtualNode':
        """Create from dictionary."""
        device_type = DeviceType(data['device_type'])
        return cls(
            node_id=data['node_id'],
            device_type=device_type,
            compute_score=data['compute_score'],
            vram_gb=data['vram_gb'],
            ram_gb=data['ram_gb'],
            memory_bandwidth_gbs=data['memory_bandwidth_gbs'],
            network_latency_ms=data['network_latency_ms'],
            bandwidth_mbps=data['bandwidth_mbps'],
            supports_fp16=data['supports_fp16'],
            supports_fp32=data['supports_fp32'],
            supports_int8=data['supports_int8'],
            current_utilization=data['current_utilization'],
        )


@dataclass
class Stage:
    """Represents a stage in partitioned execution."""
    
    # Identifiers
    stage_id: int
    node: VirtualNode
    
    # Model partitions
    layers: List[str]
    
    # Performance estimates (from Fase 1 metrics)
    expected_latency_ms: float
    memory_required_mb: float
    num_parameters: int
    
    # Metadata
    rationale: str = ""
    tags: List[str] = field(default_factory=list)
    
    def __post_init__(self):
        """Validate and normalize."""
        if self.expected_latency_ms < 0:
            raise ValueError("Latency must be non-negative")
        if self.memory_required_mb < 0:
            raise ValueError("Memory must be non-negative")
        if self.num_parameters < 0:
            raise ValueError("Parameter count must be non-negative")
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        data = asdict(self)
        data['node'] = self.node.to_dict()
        return data
    
    @property
    def bottleneck_score(self) -> float:
        """
        Bottleneck score (higher = more likely bottleneck).
        Based on latency and memory usage.
        """
        latency_score = self.expected_latency_ms / 1000.0  # Normalize to seconds
        memory_score = self.memory_required_mb / (1024 * 1024)  # Normalize to GB
        return latency_score * 0.7 + memory_score * 0.3


@dataclass
class PartitionPlan:
    """
    Complete partition plan for distributed execution.
    
    Defines how model layers are distributed across available nodes.
    """
    
    # Core data
    stages: List[Stage] = field(default_factory=list)
    
    # Metadata
    plan_name: str = "unnamed_plan"
    creation_timestamp: str = field(default_factory=lambda: time.strftime("%Y%m%d_%H%M%S"))
    strategy: PartitionStrategy = PartitionStrategy.BALANCED
    
    # Optimized parameters
    total_expected_latency_ms: float = 0.0
    load_balance_score: float = 0.0  # 0-1, higher is better
    
    # Execution planning
    bottleneck_stage_id: Optional[int] = None
    bottleneck_latency_ms: float = 0.0
    bottleneck_memory_mb: float = 0.0
    bottleneck_reason: str = ""
    
    # Optimization notes
    optimization_notes: List[str] = field(default_factory=list)
    
    def __post_init__(self):
        """Recalculate metrics on initialization."""
        if self.stages:
            self._recalculate_metrics()
    
    def _recalculate_metrics(self):
        """Calculate derived metrics."""
        if not self.stages:
            return
        
        # Total latency (sum of all stages)
        self.total_expected_latency_ms = sum(s.expected_latency_ms for s in self.stages)
        
        # Load balance (1 - coefficient of variation)
        latencies = [s.expected_latency_ms for s in self.stages]
        if len(latencies) > 1 and np.mean(latencies) > 0:
            std_dev = np.std(latencies)
            mean_lat = np.mean(latencies)
            coefficient_of_variation = std_dev / mean_lat
            self.load_balance_score = max(0.0, 1.0 - coefficient_of_variation)
        else:
            self.load_balance_score = 1.0
        
        # Bottleneck identification
        if self.stages:
            bottleneck_stage = max(self.stages, key=lambda s: s.expected_latency_ms)
            self.bottleneck_stage_id = bottleneck_stage.stage_id
            self.bottleneck_latency_ms = bottleneck_stage.expected_latency_ms
            self.bottleneck_memory_mb = bottleneck_stage.memory_required_mb
    
    def get_stage_by_id(self, stage_id: int) -> Optional[Stage]:
        """Get stage by ID."""
        for stage in self.stages:
            if stage.stage_id == stage_id:
                return stage
        return None
    
    def get_stages_on_node(self, node_id: str) -> List[Stage]:
        """Get all stages assigned to a node."""
        return [s for s in self.stages if s.node.node_id == node_id]
    
    def validate(self) -> List[str]:
        """Validate plan and return list of errors."""
        errors = []
        
        if not self.stages:
            errors.append("Plan has no stages")
        
        # Check for duplicate stage IDs
        stage_ids = [s.stage_id for s in self.stages]
        if len(stage_ids) != len(set(stage_ids)):
            errors.append("Duplicate stage IDs found")
        
        # Check for empty stages
        for stage in self.stages:
            if not stage.layers:
                errors.append(f"Stage {stage.stage_id} has no layers")
            
            # Check memory constraints
            if not stage.node.can_fit(stage.memory_required_mb):
                errors.append(f"Stage {stage.stage_id} exceeds node {stage.node.node_id} memory capacity")
        
        return errors
    
    def is_valid(self) -> bool:
        """Check if plan is valid."""
        return len(self.validate()) == 0
    
    def to_json(self, indent: int = 2) -> str:
        """Export plan to JSON string."""
        data = asdict(self)
        data['stages'] = [s.to_dict() for s in self.stages]
        data['strategy'] = self.strategy.value
        data['timestamp'] = self.creation_timestamp
        return json.dumps(data, indent=indent)
    
    def to_dict(self) -> Dict[str, Any]:
        """Export plan to dictionary."""
        return {
            'plan_name': self.plan_name,
            'creation_timestamp': self.creation_timestamp,
            'strategy': self.strategy.value,
            'total_expected_latency_ms': self.total_expected_latency_ms,
            'load_balance_score': self.load_balance_score,
            'bottleneck_stage_id': self.bottleneck_stage_id,
            'bottleneck_latency_ms': self.bottleneck_latency_ms,
            'bottleneck_reason': self.bottleneck_reason,
            'stages': [s.to_dict() for s in self.stages],
            'optimization_notes': self.optimization_notes,
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'PartitionPlan':
        """Create plan from dictionary."""
        # Reconstruct VirtualNode objects
        stages = []
        for stage_data in data['stages']:
            node = VirtualNode.from_dict(stage_data['node'])
            
            stage = Stage(
                stage_id=stage_data['stage_id'],
                node=node,
                layers=stage_data['layers'],
                expected_latency_ms=stage_data['expected_latency_ms'],
                memory_required_mb=stage_data['memory_required_mb'],
                num_parameters=stage_data['num_parameters'],
                rationale=stage_data['rationale'],
                tags=stage_data.get('tags', []),
            )
            stages.append(stage)
        
        # Create plan
        strategy = PartitionStrategy(data.get('strategy', 'balanced'))
        plan = cls(
            stages=stages,
            plan_name=data.get('plan_name', 'unnamed_plan'),
            creation_timestamp=data.get('timestamp', time.strftime("%Y%m%d_%H%M%S")),
            strategy=strategy,
        )
        
        # Restore calculated fields
        plan.total_expected_latency_ms = data.get('total_expected_latency_ms', plan.total_expected_latency_ms)
        plan.load_balance_score = data.get('load_balance_score', plan.load_balance_score)
        plan.bottleneck_stage_id = data.get('bottleneck_stage_id')
        plan.bottleneck_latency_ms = data.get('bottleneck_latency_ms', 0.0)
        plan.bottleneck_reason = data.get('bottleneck_reason', '')
        plan.optimization_notes = data.get('optimization_notes', [])
        
        return plan
    
    def visualize(self) -> str:
        """Generate ASCII art visualization of the plan."""
        lines = []
        lines.append("=" * 80)
        lines.append(f"PARTITION PLAN: {self.plan_name}")
        lines.append("=" * 80)
        lines.append(f"Strategy: {self.strategy.value}")
        lines.append(f"Total Stages: {len(self.stages)}")
        lines.append(f"Total Latency: {self.total_expected_latency_ms:.1f}ms")
        lines.append(f"Bottleneck: Stage {self.bottleneck_stage_id} at {self.bottleneck_latency_ms:.1f}ms")
        lines.append("")
        
        # Stage breakdown
        for i, stage in enumerate(self.stages):
            lines.append(f"Stage {stage.stage_id}:")
            lines.append(f"  Node: {stage.node.node_id} ({stage.node.device_type.value})")
            lines.append(f"  Latency: {stage.expected_latency_ms:.1f}ms")
            lines.append(f"  Memory: {stage.memory_required_mb:.1f}MB")
            lines.append(f"  Parameters: {stage.num_parameters:,}")
            lines.append(f"  Layers: {len(stage.layers)}")
            
            # Show layer names (truncate if many)
            if len(stage.layers) <= 5:
                lines.append(f"  Layer names: {', '.join(stage.layers)}")
            else:
                lines.append(f"  Layer names: {', '.join(stage.layers[:3])}... (+{len(stage.layers)-3} more)")
            
            lines.append(f"  Rationale: {stage.rationale}")
            lines.append("")
        
        # Optimization notes
        if self.optimization_notes:
            lines.append("Optimization Notes:")
            for note in self.optimization_notes:
                lines.append(f"  - {note}")
            lines.append("")
        
        lines.append("=" * 80)
        return "\n".join(lines)
    
    def summary(self) -> Dict[str, Any]:
        """Generate summary statistics."""
        node_ids = list(set(s.node.node_id for s in self.stages))
        
        return {
            'total_stages': len(self.stages),
            'total_layers': sum(len(s.layers) for s in self.stages),
            'nodes_used': len(node_ids),
            'node_utilization': {nid: len(self.get_stages_on_node(nid)) for nid in node_ids},
            'total_latency_ms': self.total_expected_latency_ms,
            'load_balance_score': self.load_balance_score,
            'bottleneck': self.bottleneck_stage_id,
        }


def create_fake_metrics_for_demo() -> Dict[str, Any]:
    """Create fake layer metrics for demo/testing purposes."""
    from noodle_poc.metrics import LayerMetrics
    
    model_layers = [
        "embeddings",
        *[f"transformer.h.{i}" for i in range(24)],
        "lm_head",
    ]
    
    metrics = {}
    for idx, layer_name in enumerate(model_layers):
        layer_type = "Embedding" if layer_name == "embeddings" else "Linear" if layer_name == "lm_head" else "TransformerBlock"
        
        # Simulate realistic latency (attention layers slower, lm_head fast)
        if layer_name == "lm_head":
            latency_ms = 15.0
            memory_mb = 200.0
        elif layer_name == "embeddings":
            latency_ms = 25.0
            memory_mb = 300.0
        else:
            block_idx = int(layer_name.split(".")[-1])
            latency_ms = 30.0 + block_idx * 2.0  # Later blocks slightly slower
            memory_mb = 500.0
        
        metrics[layer_name] = LayerMetrics(
            layer_name=layer_name,
            layer_type=layer_type,
            layer_index=idx,
            forward_latency_ms=latency_ms,
            peak_vram_after=memory_mb * 1024 * 1024,  # Convert to bytes
            num_parameters=1000000 if layer_type == "Linear" else 500000,
            parameter_size_mb=1.0,
            device="cuda:0",
        )
    
    return metrics
