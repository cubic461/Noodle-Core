"""
Staged execution simulator for testing partition plans locally.

Simulates distributed inference by running model stages on different
(virtual) devices and tracking tensor transfers between them.
"""

import torch
import torch.nn as nn
from typing import List, Dict, Optional, Tuple, Any
from dataclasses import dataclass
import time
from collections import defaultdict

from .plan import PartitionPlan, Stage, VirtualNode, DeviceType
from .metrics import MetricsCollector


@dataclass
class SimulatedTensorTransfer:
    """Represents a tensor transfer between stages."""
    
    source_stage_id: int
    target_stage_id: int
    tensor_shape: List[int]
    tensor_dtype: str
    size_bytes: int
    transfer_time_ms: float
    method: str  # "local_copy", "remote_transfer"


class VirtualKVCache:
    """
    Simulates KV-cache for attention layers.
    
    In real distributed inference, each stage maintains its own
    KV-cache. This class simulates that behavior for staged execution.
    """
    
    def __init__(self, stage_id: int, max_seq_len: int = 2048):
        self.stage_id = stage_id
        self.max_seq_len = max_seq_len
        self.cache: Dict[str, torch.Tensor] = {}
        
        # Tracking
        self.num_entries = 0
        self.total_memory_bytes = 0
        
    def add_entry(self, key: str, key_tensor: torch.Tensor, value_tensor: torch.Tensor):
        """Add KV-cache entry."""
        cache_key = f"{key}_k"
        cache_val = f"{key}_v"
        
        self.cache[cache_key] = key_tensor
        self.cache[cache_val] = value_tensor
        
        self.num_entries += 1
        self.total_memory_bytes += key_tensor.numel() * key_tensor.element_size()
        self.total_memory_bytes += value_tensor.numel() * value_tensor.element_size()
        
    def get_memory_mb(self) -> float:
        """Get cache memory usage in MB."""
        return self.total_memory_bytes / (1024 * 1024)
    
    def clear(self):
        """Clear cache."""
        self.cache.clear()
        self.num_entries = 0
        self.total_memory_bytes = 0


class MockLayer:
    """
    Mock layer for simulation purposes.
    
    Simulates layer execution without actual model weights.
    Uses timing and memory metrics from Fase 1 profiling.
    """
    
    def __init__(self, layer_metrics, device: str = "cpu"):
        self.layer_name = layer_metrics.layer_name
        self.layer_type = layer_metrics.layer_type
        self.expected_latency_ms = layer_metrics.forward_latency_ms
        self.expected_memory_mb = layer_metrics.peak_vram_after / (1024 * 1024)
        self.device = torch.device(device)
        
        # Simulate layer computation
        if "attention" in self.layer_type.lower():
            self._is_attention = True
            self.kv_cache = VirtualKVCache(stage_id=-1)
        else:
            self._is_attention = False
            self.kv_cache = None
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Simulate forward pass."""
        # Add expected latency
        time.sleep(self.expected_latency_ms / 1000.0)
        
        # Move to device (simulates memory overhead)
        x = x.to(self.device)
        
        # Simulate attention KV-cache updates
        if self._is_attention and self.kv_cache:
            # Create dummy KV tensors
            batch, seq, hidden = x.shape
            k = torch.randn(batch, seq, hidden // 2, device=x.device)
            v = torch.randn(batch, seq, hidden // 2, device=x.device)
            self.kv_cache.add_entry(f"layer_{hash(self)}", k, v)
        
        # Simulate output (keep shape, just pass through)
        return x


class SimulatedStage:
    """
    Represents a stage in the simulated execution.
    
    Manages layers, KV-cache, and stage lifecycle.
    """
    
    def __init__(self, stage: Stage, layer_metrics_map: Dict[str, Any]):
        self.stage_id = stage.stage_id
        self.node = stage.node
        self.layers = stage.layers
        
        # Create mock layers for simulation
        self.mock_layers: List[MockLayer] = []
        for layer_name in self.layers:
            if layer_name in layer_metrics_map:
                # Use real metrics if available
                layer_metrics = layer_metrics_map[layer_name]
            else:
                # Fallback mocked metrics
                from .metrics import LayerMetrics
                layer_metrics = LayerMetrics(
                    layer_name=layer_name,
                    layer_type="Unknown",
                    forward_latency_ms=50.0,
                    peak_vram_after=500 * 1024 * 1024,
                )
            
            device = "cuda:0" if self.node.device_type == DeviceType.GPU else "cpu"
            mock_layer = MockLayer(layer_metrics, device=device)
            self.mock_layers.append(mock_layer)
        
        # Stage-level KV-cache (for attention layers in this stage)
        self.kv_cache = VirtualKVCache(stage_id=stage.stage_id)
        
        # Statistics
        self.total_runs = 0
        self.total_latency_ms = 0.0
        self.peak_memory_mb = 0.0
        
    def run_stage(self, input_tensor: torch.Tensor) -> Tuple[torch.Tensor, float, float]:
        """
        Run this stage with given input.
        
        Args:
            input_tensor: Input activations
            
        Returns:
            (output_tensor, latency_ms, memory_mb)
        """
        start_time = time.time()
        current_memory = 0.0
        
        x = input_tensor
        
        # Execute each layer in sequence
        for layer in self.mock_layers:
            # Track memory allocation
            if layer.device.type == "cuda" and torch.cuda.is_available():
                torch.cuda.reset_peak_memory_stats()
                before_mem = torch.cuda.memory_allocated()
            
            # Forward pass
            x = layer.forward(x)
            
            # Update memory tracking
            if layer.device.type == "cuda" and torch.cuda.is_available():
                after_mem = torch.cuda.memory_allocated()
                current_memory = max(current_memory, (after_mem - before_mem) / (1024 * 1024))
            else:
                current_memory = max(current_memory, layer.expected_memory_mb)
        
        latency_ms = (time.time() - start_time) * 1000
        
        # Update statistics
        self.total_runs += 1
        self.total_latency_ms += latency_ms
        self.peak_memory_mb = max(self.peak_memory_mb, current_memory)
        
        return x, latency_ms, current_memory


class StagedSimulator:
    """
    Simulates staged execution of a partition plan.
    
    Runs inference by executing stages sequentially with realistic
    timing and memory simulation based on Fase 1 metrics.
    """
    
    def __init__(
        self,
        plan: PartitionPlan,
        layer_metrics_map: Dict[str, Any],
        track_transfers: bool = True,
    ):
        """
        Initialize staged simulator.
        
        Args:
            plan: Partition plan to simulate
            layer_metrics_map: Dictionary mapping layer names to their metrics
            track_transfers: Whether to track tensor transfers between stages
        """
        self.plan = plan
        self.layer_metrics_map = layer_metrics_map
        self.track_transfers = track_transfers
        
        # Create stages
        self.stages: List[SimulatedStage] = [
            SimulatedStage(stage, layer_metrics_map)
            for stage in plan.stages
        ]
        
        # Transfer tracking
        self.tensor_transfers: List[SimulatedTensorTransfer] = []
        self.transfer_overhead_ms = 0.0
        
        # Execution stats
        self.total_forward_passes = 0
        self.total_execution_time_ms = 0.0
        self.total_transfer_time_ms = 0.0
        
    def simulate_inference(
        self,
        input_tensor: torch.Tensor,
        num_runs: int = 10,
        warmup_runs: int = 3,
    ) -> Dict[str, Any]:
        """
        Simulate complete inference through all stages.
        
        Args:
            input_tensor: Input to first stage
            num_runs: Number of inference runs
            warmup_runs: Number of warmup runs (discarded from stats)
            
        Returns:
            Dictionary with execution statistics
        """
        print(f"🧪 Staged Simulator - Running {num_runs} iterations with {warmup_runs} warmup")
        print(f"   Plan: {self.plan.plan_name}")
        print(f"   Stages: {len(self.stages)}")
        
        all_stats = []
        
        for run_idx in range(num_runs + warmup_runs):
            is_warmup = run_idx < warmup_runs
            run_stats = self._run_single_inference(input_tensor, run_idx, is_warmup)
            
            if not is_warmup:
                all_stats.append(run_stats)
        
        # Aggregate statistics
        return self._aggregate_stats(all_stats)
    
    def _run_single_inference(
        self,
        input_tensor: torch.Tensor,
        run_idx: int,
        is_warmup: bool,
    ) -> Dict[str, Any]:
        """Run a single inference pass through all stages."""
        
        stage_stats = []
        current_tensor = input_tensor.clone()
        
        for stage in self.stages:
            # Run stage
            output_tensor, stage_latency_ms, stage_memory_mb = stage.run_stage(current_tensor)
            
            # Simulate tensor transfer to next stage
            transfer_time_ms = 0.0
            if stage != self.stages[-1]:  # Not the last stage
                transfer_time_ms = self._simulate_tensor_transfer(
                    output_tensor,
                    stage.stage_id,
                    stage.stage_id + 1,
                )
            
            stage_stats.append({
                "stage_id": stage.stage_id,
                "node": stage.node.node_id,
                "latency_ms": stage_latency_ms,
                "memory_mb": stage_memory_mb,
                "transfer_ms": transfer_time_ms,
                "num_layers": len(stage.layers),
            })
            
            # Prepare tensor for next stage
            current_tensor = output_tensor
        
        self.total_forward_passes += 1
        
        return {
            "run_idx": run_idx,
            "is_warmup": is_warmup,
            "stage_stats": stage_stats,
            "total_latency_ms": sum(s["latency_ms"] + s["transfer_ms"] for s in stage_stats),
            "final_output_shape": list(current_tensor.shape),
        }
    
    def _simulate_tensor_transfer(
        self,
        tensor: torch.Tensor,
        source_stage_id: int,
        target_stage_id: int,
    ) -> float:
        """
        Simulate tensor transfer between stages.
        
        Returns transfer time in milliseconds.
        """
        # Calculate tensor size
        size_bytes = tensor.numel() * tensor.element_size()
        
        # Determine transfer method and time
        source_node = self.stages[source_stage_id].node
        target_node = self.stages[target_stage_id].node
        
        if source_node == target_node:
            # Local copy (fast)
            transfer_time_ms = 0.1  # Minimal overhead
            method = "local_copy"
        else:
            # Network transfer (slow)
            # Estimate: bandwidth + latency
            bandwidth_mbps = min(source_node.bandwidth_mbps, target_node.bandwidth_mbps)
            size_mb = size_bytes / (1024 * 1024)
            transfer_time_ms = (size_mb * 8) / bandwidth_mbps  # seconds
            transfer_time_ms = transfer_time_ms * 1000  # ms
            transfer_time_ms += source_node.network_latency_ms
            method = "remote_transfer"
        
        # Track transfer
        if self.track_transfers:
            transfer = SimulatedTensorTransfer(
                source_stage_id=source_stage_id,
                target_stage_id=target_stage_id,
                tensor_shape=list(tensor.shape),
                tensor_dtype=str(tensor.dtype),
                size_bytes=size_bytes,
                transfer_time_ms=transfer_time_ms,
                method=method,
            )
            self.tensor_transfers.append(transfer)
            self.total_transfer_time_ms += transfer_time_ms
        
        return transfer_time_ms
    
    def _aggregate_stats(self, all_stats: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Aggregate statistics across all runs."""
        
        if not all_stats:
            return {"error": "No statistics collected"}
        
        # Collect per-stage statistics
        stage_aggregates = defaultdict(lambda: {
            "latencies": [],
            "memories": [],
            "transfers": [],
            "runs": 0,
        })
        
        total_latencies = []
        
        for run in all_stats:
            total_latencies.append(run["total_latency_ms"])
            
            for stage_stat in run["stage_stats"]:
                stage_id = stage_stat["stage_id"]
                stage_aggregates[stage_id]["latencies"].append(stage_stat["latency_ms"])
                stage_aggregates[stage_id]["memories"].append(stage_stat["memory_mb"])
                stage_aggregates[stage_id]["transfers"].append(stage_stat["transfer_ms"])
                stage_aggregates[stage_id]["runs"] += 1
        
        # Calculate aggregates
        stage_summaries = {}
        for stage_id, stats in stage_aggregates.items():
            stage_summaries[stage_id] = {
                "avg_latency_ms": sum(stats["latencies"]) / len(stats["latencies"]),
                "p95_latency_ms": sorted(stats["latencies"])[int(len(stats["latencies"]) * 0.95)],
                "avg_memory_mb": sum(stats["memories"]) / len(stats["memories"]),
                "peak_memory_mb": max(stats["memories"]),
                "avg_transfer_ms": sum(stats["transfers"]) / len(stats["transfers"]),
                "runs": stats["runs"],
                "node": self.stages[stage_id].node.node_id,
            }
        
        agg_stats = {
            "total_runs": len(all_stats),
            "total": {
                "avg_latency_ms": sum(total_latencies) / len(total_latencies),
                "p95_latency_ms": sorted(total_latencies)[int(len(total_latencies) * 0.95)],
                "min_latency_ms": min(total_latencies),
                "max_latency_ms": max(total_latencies),
            },
            "stages": stage_summaries,
            "transfers": {
                "total_transfers": len(self.tensor_transfers),
                "network_transfers": sum(1 for t in self.tensor_transfers if t.method == "remote_transfer"),
                "total_transfer_time_ms": self.total_transfer_time_ms,
                "avg_transfer_time_ms": self.total_transfer_time_ms / len(self.tensor_transfers) if self.tensor_transfers else 0,
            },
            "bottleneck": max(stage_summaries.items(), key=lambda x: x[1]["avg_latency_ms"]),
        }
        
        return agg_stats
    
    def get_stage_summary(self) -> str:
        """Get human-readable stage execution summary."""
        if not self.stages:
            return "No stages executed"
        
        lines = []
        lines.append("=" * 80)
        lines.append("STAGED EXECUTION SUMMARY")
        lines.append("=" * 80)
        
        # Overall stats
        lines.append(f"Total forward passes: {self.total_forward_passes}")
        lines.append(f"Total execution time: {self.total_execution_time_ms:.1f}ms")
        lines.append(f"Total transfer overhead: {self.total_transfer_time_ms:.1f}ms")
        
        # Per-stage breakdown
        lines.append("\nStage Breakdown:")
        for stage in self.stages:
            if stage.total_runs > 0:
                avg_latency = stage.total_latency_ms / stage.total_runs
                lines.append(f"  Stage {stage.stage_id} ({stage.node.node_id}):")
                lines.append(f"    Executions: {stage.total_runs}")
                lines.append(f"    Avg latency: {avg_latency:.1f}ms")
                lines.append(f"    Peak memory: {stage.peak_memory_mb:.1f}MB")
                lines.append(f"    Layers: {', '.join(stage.layers[:3])}" +
                           ("..." if len(stage.layers) > 3 else ""))
        
        # Transfer analysis
        if self.tensor_transfers:
            lines.append(f"\nTensor Transfers: {len(self.tensor_transfers)}")
            network_transfers = [t for t in self.tensor_transfers if t.method == "remote_transfer"]
            if network_transfers:
                lines.append(f"  Network transfers: {len(network_transfers)}")
                lines.append(f"  Network overhead: {sum(t.transfer_time_ms for t in network_transfers):.1f}ms")
        
        lines.append("=" * 80)
        
        return "\n".join(lines)


def compare_staged_vs_native(
    plan: PartitionPlan,
    layer_metrics: Dict[str, Any],
    native_latency_ms: float,
    num_comparison_runs: int = 20,
) -> Dict[str, Any]:
    """
    Compare staged execution against native (single-device) execution.
    
    Args:
        plan: Partition plan to test
        layer_metrics: Layer metrics from Fase 1
        native_latency_ms: Measured native latency
        num_comparison_runs: Number of simulation runs
        
    Returns:
        Comparison report
    """
    print("\n" + "=" * 80)
    print("🔄 COMPARISON: Staged vs Native Execution")
    print("=" * 80)
    
    # Create simulator
    simulator = StagedSimulator(plan, layer_metrics)
    
    # Create sample input tensor (based on typical sequence)
    sample_input = torch.randn(1, 128, 768)  # [batch, seq_len, hidden_dim]
    
    # Run staged simulation
    staged_stats = simulator.simulate_inference(sample_input, num_runs=num_comparison_runs)
    
    # Calculate overhead
    avg_staged = staged_stats["total"]["avg_latency_ms"]
    overhead_ms = avg_staged - native_latency_ms
    overhead_pct = (overhead_ms / native_latency_ms) * 100 if native_latency_ms > 0 else 0
    
    # Summary
    summary = {
        "native_latency_ms": native_latency_ms,
        "staged_latency_ms": avg_staged,
        "overhead_ms": overhead_ms,
        "overhead_pct": overhead_pct,
        "speedup": native_latency_ms / avg_staged if avg_staged > 0 else 0,
        "bottleneck_stage": staged_stats["bottleneck"][0],
        "bottleneck_latency": staged_stats["bottleneck"][1]["avg_latency_ms"],
        "transfer_overhead_ms": staged_stats["transfers"]["total_transfer_time_ms"],
    }
    
    print(f"Native:        {native_latency_ms:.1f}ms")
    print(f"Staged:        {avg_staged:.1f}ms")
    print(f"Overhead:      {overhead_ms:.1f}ms ({overhead_pct:.1f}%)")
    
    if overhead_pct > 0:
        print(f"Slowdown:      {1/summary['speedup']:.2f}x" if summary['speedup'] < 1 else f"Speedup: {summary['speedup']:.2f}x")
    else:
        print("✅ Staged execution is faster!")
    
    print("\nBottleneck Analysis:")
    print(f"  Stage {summary['bottleneck_stage']}: {summary['bottleneck_latency']:.1f}ms")
    print(f"  Transfer overhead: {summary['transfer_overhead_ms']:.1f}ms")
    
    print("=" * 80)
    
    return summary
