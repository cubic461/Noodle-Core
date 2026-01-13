"""
Execution planner for generating optimal sharding plans.

Uses metrics from the Observability Engine to intelligently partition
models across available hardware nodes.
"""

import time
from typing import List, Dict, Optional, Tuple, Any
from dataclasses import dataclass
import numpy as np
from collections import defaultdict

from src.plan import (
    PartitionPlan,
    PartitionStrategy,
    Stage,
    VirtualNode,
    DeviceType,
)
from noodle_poc.metrics import MetricsCollector, LayerMetrics


@dataclass
class PlanningConstraints:
    """Constraints and preferences for planning."""
    
    # Memory constraints
    max_vram_per_stage_gb: float = 24.0
    max_ram_per_stage_gb: float = 64.0
    
    # Latency constraints
    max_stage_latency_ms: float = 1000.0
    target_stage_latency_ms: float = 500.0
    
    # Balance constraints
    max_latency_imbalance_pct: float = 30.0  # Max 30% difference between stages
    
    # Miscellaneous
    prefer_fast_devices: bool = True
    min_stages: int = 1
    max_stages: int = 8
    allow_cross_node_duplicates: bool = False


class ExecutionPlanner:
    """
    Plans optimal model partitioning based on runtime metrics.
    
    Analyzes layer metrics to create intelligent sharding decisions:
    - Identifies bottlenecks requiring special placement
    - Balances latency across stages
    - Respects memory and hardware constraints
    - Considers network overhead in distributed scenarios
    """
    
    def __init__(
        self,
        metrics_collector: MetricsCollector,
        strategy: PartitionStrategy = PartitionStrategy.BALANCED,
        constraints: Optional[PlanningConstraints] = None,
    ):
        """
        Initialize execution planner.
        
        Args:
            metrics_collector: Contains profiling data from Observability Engine
            strategy: Partitioning strategy to use
            constraints: Planning constraints and preferences
        """
        self.metrics_collector = metrics_collector
        self.strategy = strategy
        self.constraints = constraints or PlanningConstraints()
        
        # Extract metrics for easier access
        self.layer_metrics = self._extract_layer_metrics()
        self.total_layers = len(self.layer_metrics)
        
    def _extract_layer_metrics(self) -> Dict[str, LayerMetrics]:
        """Extract latest metrics for each layer."""
        layer_metrics = {}
        
        for layer_name, runs in self.metrics_collector.metrics_history.items():
            if runs:
                # Use the most recent run
                layer_metrics[layer_name] = runs[-1]
        
        return layer_metrics
    
    def generate_plan(
        self,
        available_nodes: List[VirtualNode],
        model_name: str = "unknown_model",
    ) -> PartitionPlan:
        """
        Generate optimal partition plan for given nodes.
        
        Args:
            available_nodes: List of available hardware nodes
            model_name: Name of the model being partitioned
            
        Returns:
            PartitionPlan with stage assignments
        """
        print(f"[PLANNER] Generating partition plan for {model_name}")
        print(f"   Strategy: {self.strategy.value}")
        print(f"   Available nodes: {len(available_nodes)}")
        print(f"   Total layers to partition: {len(self.layer_metrics)}")
        
        start_time = time.time()
        
        # Validate inputs
        if not available_nodes:
            raise ValueError("No available nodes for planning")
        
        if not self.layer_metrics:
            raise ValueError("No layer metrics available for planning")
        
        # Sort nodes by priority and capability
        sorted_nodes = self._sort_nodes_by_capability(available_nodes)
        
        # Generate plan based on strategy
        if self.strategy == PartitionStrategy.BOTTLENECK_FIRST:
            plan = self._plan_bottleneck_first(sorted_nodes)
        elif self.strategy == PartitionStrategy.MEMORY_AWARE:
            plan = self._plan_memory_aware(sorted_nodes)
        elif self.strategy == PartitionStrategy.LATENCY_OPTIMIZED:
            plan = self._plan_latency_optimized(sorted_nodes)
        else:  # BALANCED (default)
            plan = self._plan_balanced(sorted_nodes)
        
        # Set plan metadata
        plan.plan_name = f"{model_name}_{self.strategy.value}_plan"
        plan.creation_timestamp = time.strftime("%Y%m%d_%H%M%S")
        plan.strategy = self.strategy
        
        # Add optimization notes
        self._add_optimization_notes(plan)
        
        planning_time = time.time() - start_time
        print(f"✅ Plan generated in {planning_time:.2f}s")
        print(f"   Total stages: {len(plan.stages)}")
        print(f"   Expected latency: {plan.total_expected_latency_ms:.1f}ms")
        print(f"   Load balance score: {plan.load_balance_score:.2f}")
        
        if plan.bottleneck_stage_id is not None:
            bottleneck = plan.stages[plan.bottleneck_stage_id]
            print(f"   ⚠️  Bottleneck: Stage {plan.bottleneck_stage_id} ({plan.bottleneck_latency_ms:.1f}ms)")
            print(f"      Reason: {plan.bottleneck_reason}")
        
        return plan
    
    def _sort_nodes_by_capability(self, nodes: List[VirtualNode]) -> List[VirtualNode]:
        """Sort nodes by compute capability (GPU > iGPU > CPU) and score."""
        def node_sort_key(node):
            # Priority: GPU (3) > iGPU (2) > CPU (1)
            type_priority = {"gpu": 3, "igpu": 2, "cpu": 1}.get(node.device_type.value, 0)
            
            # Within same type, sort by compute score
            return (-type_priority, -node.compute_score, node.node_id)
        
        return sorted(nodes, key=node_sort_key)
    
    def _plan_balanced(self, nodes: List[VirtualNode]) -> PartitionPlan:
        """
        Create balanced partition plan.
        
        Aims to distribute latency evenly across stages while respecting
        memory constraints.
        """
        plan = PartitionPlan(stages=[])
        
        # Sort layers by latency (descending)
        sorted_layers = sorted(
            self.layer_metrics.items(),
            key=lambda x: x[1].forward_latency_ms,
            reverse=True
        )
        
        # Calculate target latency per stage
        total_latency = sum(m.forward_latency_ms for m in self.layer_metrics.values())
        num_stages = min(len(nodes), self.constraints.max_stages)
        target_latency_per_stage = total_latency / num_stages
        
        # Greedy bin-packing algorithm
        stages = []
        current_stage_layers = []
        current_stage_latency = 0.0
        current_stage_memory = 0.0
        stage_id = 0
        node_idx = 0
        
        for layer_name, layer_metrics in sorted_layers:
            layer_latency = layer_metrics.forward_latency_ms
            layer_memory = layer_metrics.peak_vram_after / (1024 * 1024)  # MB
            
            # Check if adding layer would exceed constraints
            would_exceed_latency = (current_stage_latency + layer_latency > 
                                  target_latency_per_stage * 1.3)
            would_exceed_memory = (current_stage_memory + layer_memory > 
                                 self.constraints.max_vram_per_stage_gb * 1024)
            has_enough_layers = len(current_stage_layers) > 0
            
            # If constraints exceeded and we have layers, finalize current stage
            if has_enough_layers and (would_exceed_latency or would_exceed_memory or
                                     len(stages) < num_stages - 1 and 
                                     current_stage_latency >= target_latency_per_stage * 0.7):
                # Finalize current stage
                stage = Stage(
                    stage_id=stage_id,
                    node=nodes[node_idx % len(nodes)],
                    layers=current_stage_layers,
                    expected_latency_ms=current_stage_latency,
                    memory_required_mb=current_stage_memory,
                    num_parameters=sum(self.layer_metrics[l].num_parameters 
                                      for l in current_stage_layers),
                    rationale=f"Balanced stage targeting {target_latency_per_stage:.0f}ms latency",
                )
                stages.append(stage)
                
                # Reset for next stage
                stage_id += 1
                node_idx += 1
                current_stage_layers = []
                current_stage_latency = 0.0
                current_stage_memory = 0.0
            
            # Add layer to current stage
            current_stage_layers.append(layer_name)
            current_stage_latency += layer_latency
            current_stage_memory += layer_memory
        
        # Add final stage
        if current_stage_layers:
            stage = Stage(
                stage_id=stage_id,
                node=nodes[node_idx % len(nodes)],
                layers=current_stage_layers,
                expected_latency_ms=current_stage_latency,
                memory_required_mb=current_stage_memory,
                num_parameters=sum(self.layer_metrics[l].num_parameters 
                                  for l in current_stage_layers),
                rationale="Final balanced stage",
            )
            stages.append(stage)
        
        plan.stages = stages
        plan._recalculate_metrics()
        return plan
    
    def _plan_bottleneck_first(self, nodes: List[VirtualNode]) -> PartitionPlan:
        """
        Create plan that prioritizes bottleneck layers.
        
        Places the slowest layers on the fastest devices first,
        then fills remaining capacity with other layers.
        """
        plan = PartitionPlan(stages=[])
        
        # Identify bottlenecks (top 20% slowest layers)
        sorted_layers = sorted(
            self.layer_metrics.items(),
            key=lambda x: x[1].forward_latency_ms,
            reverse=True
        )
        
        bottleneck_threshold = int(len(sorted_layers) * 0.2)
        bottlenecks = sorted_layers[:bottleneck_threshold]
        remaining = sorted_layers[bottleneck_threshold:]
        
        stages = []
        stage_id = 0
        
        # Strategy 1: Place bottlenecks on fastest nodes
        nodes_by_speed = sorted(nodes, key=lambda n: n.compute_score, reverse=True)
        
        for i, (layer_name, layer_metrics) in enumerate(bottlenecks):
            node = nodes_by_speed[min(i, len(nodes_by_speed) - 1)]
            
            stage = Stage(
                stage_id=stage_id,
                node=node,
                layers=[layer_name],
                expected_latency_ms=layer_metrics.forward_latency_ms,
                memory_required_mb=layer_metrics.peak_vram_after / (1024 * 1024),
                num_parameters=layer_metrics.num_parameters,
                rationale=f"Bottleneck layer on fastest available device (score={node.compute_score})",
                tags=["bottleneck"],
            )
            stages.append(stage)
            stage_id += 1
        
        # Strategy 2: Greedily pack remaining layers
        # Reuse the balanced algorithm for remaining layers
        remaining_metrics = dict(remaining)
        
        if remaining_metrics:
            # Temporarily replace layer_metrics for balanced planning
            original_metrics = self.layer_metrics
            self.layer_metrics = remaining_metrics
            
            # Use balanced strategy for remaining layers
            remaining_plan = self._plan_balanced(nodes)
            
            # Adjust stage IDs and add to main plan
            for stage in remaining_plan.stages:
                stage.stage_id = stage_id
                stage.rationale += " (packed after bottlenecks)"
                stages.append(stage)
                stage_id += 1
            
            # Restore original metrics
            self.layer_metrics = original_metrics
        
        plan.stages = stages
        plan._recalculate_metrics()
        
        # Identify bottleneck stage
        if plan.stages:
            plan.bottleneck_reason = "Bottleneck-first strategy prioritizes slow layers"
        
        return plan
    
    def _plan_memory_aware(self, nodes: List[VirtualNode]) -> PartitionPlan:
        """
        Create plan that optimizes for memory usage.
        
        Tries to minimize peak memory usage by grouping memory-intensive
        layers appropriately and placing them on nodes with sufficient RAM/VRAM.
        """
        plan = PartitionPlan(stages=[])
        
        # Sort layers by memory usage
        sorted_layers = sorted(
            self.layer_metrics.items(),
            key=lambda x: x[1].peak_vram_after,
            reverse=True
        )
        
        # Group nodes by memory capacity
        memory_rich_nodes = [n for n in nodes if n.vram_gb >= 16 or n.ram_gb >= 32]
        other_nodes = [n for n in nodes if n not in memory_rich_nodes]
        all_nodes = memory_rich_nodes + other_nodes
        
        stages = []
        stage_id = 0
        node_idx = 0
        
        current_stage_layers = []
        current_stage_latency = 0.0
        current_stage_memory = 0.0
        
        for layer_name, layer_metrics in sorted_layers:
            layer_latency = layer_metrics.forward_latency_ms
            layer_memory = layer_metrics.peak_vram_after / (1024 * 1024)
            
            current_node = all_nodes[node_idx % len(all_nodes)]
            node_memory_limit = current_node.vram_gb * 1024 if current_node.vram_gb > 0 else current_node.ram_gb * 1024
            
            # Check if adding layer would exceed memory limits
            would_exceed_memory = (current_stage_memory + layer_memory > 
                                 node_memory_limit * 0.9)  # 90% threshold
            
            if would_exceed_memory and current_stage_layers:
                # Finalize current stage
                stage = Stage(
                    stage_id=stage_id,
                    node=current_node,
                    layers=current_stage_layers,
                    expected_latency_ms=current_stage_latency,
                    memory_required_mb=current_stage_memory,
                    num_parameters=sum(self.layer_metrics[l].num_parameters 
                                      for l in current_stage_layers),
                    rationale="Memory-optimized stage on high-memory node",
                )
                stages.append(stage)
                
                # Move to next node/stage
                stage_id += 1
                node_idx += 1
                current_stage_layers = []
                current_stage_latency = 0.0
                current_stage_memory = 0.0
            
            # Add layer to current stage
            current_stage_layers.append(layer_name)
            current_stage_latency += layer_latency
            current_stage_memory += layer_memory
        
        # Add final stage
        if current_stage_layers:
            current_node = all_nodes[node_idx % len(all_nodes)]
            stage = Stage(
                stage_id=stage_id,
                node=current_node,
                layers=current_stage_layers,
                expected_latency_ms=current_stage_latency,
                memory_required_mb=current_stage_memory,
                num_parameters=sum(self.layer_metrics[l].num_parameters 
                                  for l in current_stage_layers),
                rationale="Final memory-optimized stage",
            )
            stages.append(stage)
        
        plan.stages = stages
        plan._recalculate_metrics()
        
        return plan
    
    def _plan_latency_optimized(self, nodes: List[VirtualNode]) -> PartitionPlan:
        """
        Create plan that minimizes end-to-end latency.
        
        Uses dynamic programming to find optimal stage boundaries
        that minimize total latency while respecting constraints.
        """
        plan = PartitionPlan(stages=[])
        
        # For simplicity, reuse balanced strategy but with different targets
        # In a full implementation, this would use more sophisticated optimization
        
        sorted_layers = sorted(
            self.layer_metrics.items(),
            key=lambda x: x[1].forward_latency_ms,
            reverse=False  # Start with faster layers for better packing
        )
        
        # Sort nodes by speed (fastest first)
        sorted_nodes = sorted(nodes, key=lambda n: n.compute_score, reverse=True)
        
        stages = []
        stage_id = 0
        current_stage_layers = []
        current_stage_latency = 0.0
        
        for layer_name, layer_metrics in sorted_layers:
            layer_latency = layer_metrics.forward_latency_ms
            
            # If this layer would make stage too slow, create new stage
            if (current_stage_latency + layer_latency > self.constraints.max_stage_latency_ms and
                current_stage_layers):
                
                node = sorted_nodes[min(stage_id, len(sorted_nodes) - 1)]
                stage = Stage(
                    stage_id=stage_id,
                    node=node,
                    layers=current_stage_layers,
                    expected_latency_ms=current_stage_latency,
                    memory_required_mb=sum(self.layer_metrics[l].peak_vram_after 
                                          for l in current_stage_layers) / (1024 * 1024),
                    num_parameters=sum(self.layer_metrics[l].num_parameters 
                                      for l in current_stage_layers),
                    rationale="Latency-optimized stage on fastest node",
                )
                stages.append(stage)
                
                stage_id += 1
                current_stage_layers = []
                current_stage_latency = 0.0
            
            current_stage_layers.append(layer_name)
            current_stage_latency += layer_latency
        
        # Add final stage
        if current_stage_layers:
            node = sorted_nodes[min(stage_id, len(sorted_nodes) - 1)]
            stage = Stage(
                stage_id=stage_id,
                node=node,
                layers=current_stage_layers,
                expected_latency_ms=current_stage_latency,
                memory_required_mb=sum(self.layer_metrics[l].peak_vram_after 
                                      for l in current_stage_layers) / (1024 * 1024),
                num_parameters=sum(self.layer_metrics[l].num_parameters 
                                  for l in current_stage_layers),
                rationale="Final latency-optimized stage",
            )
            stages.append(stage)
        
        plan.stages = stages
        plan._recalculate_metrics()
        
        return plan
    
    def _add_optimization_notes(self, plan: PartitionPlan):
        """Add human-readable notes about optimization decisions."""
        
        plan.optimization_notes.append(f"Strategy: {self.strategy.value}")
        plan.optimization_notes.append(f"Total layers processed: {len(self.layer_metrics)}")
        
        # Memory notes
        total_memory = sum(s.memory_required_mb for s in plan.stages)
        avg_memory = total_memory / len(plan.stages) if plan.stages else 0
        plan.optimization_notes.append(f"Average memory per stage: {avg_memory:.1f}MB")
        
        # Latency balance notes
        if plan.stages:
            latencies = [s.expected_latency_ms for s in plan.stages]
            variance = np.var(latencies)
            std_dev = np.std(latencies)
            plan.optimization_notes.append(f"Latency std dev: {std_dev:.1f}ms")
            
            if plan.load_balance_score < 0.7:
                plan.optimization_notes.append("⚠️  Load imbalance detected - consider different strategy")
            else:
                plan.optimization_notes.append("✓ Good load balance achieved")
        
        # Node utilization notes
        node_ids = set(s.node.node_id for s in plan.stages)
        plan.optimization_notes.append(f"Nodes utilized: {len(node_ids)}")
        
        if plan.bottleneck_stage_id is not None:
            bottleneck_stage = plan.stages[plan.bottleneck_stage_id]
            plan.optimization_notes.append(
                f"Bottleneck: Stage {plan.bottleneck_stage_id} on {bottleneck_stage.node.node_id} "
                f"({plan.bottleneck_latency_ms:.1f}ms)"
            )
            
            # Suggest optimization
            if plan.bottleneck_latency_ms > plan.total_expected_latency_ms * 0.3:
                plan.optimization_notes.append(
                    "💡 Bottleneck >30% of total - consider bottleneck-first strategy"
                )












