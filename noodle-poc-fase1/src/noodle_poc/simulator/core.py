"""
Stage simulation for local multi-node execution.
Simulates different hardware nodes as virtual entities on one machine.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any, Tuple
import torch
import time
import numpy as np
from contextlib import contextmanager


@dataclass
class ExecutionTrace:
    """Trace of execution events for analysis."""
    events: List[Dict[str, Any]] = field(default_factory=list)
    
    def add_event(self, event_type: str, **kwargs):
        """Add an execution event."""
        event = {
            'type': event_type,
            'timestamp': time.time(),
            **kwargs
        }
        self.events.append(event)
    
    def get_stage_timings(self) -> Dict[str, float]:
        """Get latency per stage."""
        stage_timings = {}
        
        for event in self.events:
            if event['type'] == 'stage_complete':
                stage_timings[event['stage_id']] = event['duration_ms']
        
        return stage_timings
    
    def get_transfer_timings(self) -> List[Dict[str, Any]]:
        """Get data transfer timings."""
        transfers = []
        
        for event in self.events:
            if event['type'] == 'transfer':
                transfers.append({
                    'from': event['from_stage'],
                    'to': event['to_stage'],
                    'duration_ms': event['duration_ms'],
                    'size_mb': event.get('size_mb', 0),
                })
        
        return transfers
    
    def get_total_latency(self) -> float:
        """Calculate total execution latency."""
        return sum(event.get('duration_ms', 0) for event in self.events)
    
    def generate_report(self) -> str:
        """Generate human-readable execution trace report."""
        lines = ["=" * 70, "EXECUTION TRACE REPORT", "=" * 70]
        
        stage_timings = self.get_stage_timings()
        transfer_timings = self.get_transfer_timings()
        
        lines.append(f"Total Stages: {len(stage_timings)}")
        lines.append(f"Total Transfers: {len(transfer_timings)}")
        lines.append(f"Total Latency: {self.get_total_latency():.2f} ms")
        lines.append("")
        
        # Stage breakdown
        lines.append("STAGE BREAKDOWN:")
        lines.append("-" * 70)
        for stage_id, duration in sorted(stage_timings.items()):
            lines.append(f"{stage_id}: {duration:.2f} ms")
        lines.append("")
        
        # Transfer breakdown
        if transfer_timings:
            lines.append("TRANSFER BREAKDOWN:")
            lines.append("-" * 70)
            for tf in transfer_timings:
                lines.append(
                    f"{tf['from']} -> {tf['to']}: {tf['duration_ms']:.2f} ms "
                    f"({tf['size_mb']:.2f} MB)"
                )
            lines.append("")
        
        lines.append("=" * 70)
        return "\n".join(lines)


class VirtualNode:
    """
    Virtual hardware node with specific characteristics.
    
    Simulates a physical node by:
    - Enforcing device isolation
    - Measuring computation time
    - Simulating data transfer overhead
    """
    
    def __init__(
        self,
        node_id: str,
        device: str,
        bandwidth_mbps: float = 32000,  # PCIe 4.0 x16 speed
        compute_factor: float = 1.0,
    ):
        """
        Initialize virtual node.
        
        Args:
            node_id: Unique identifier (e.g., 'gpu_node', 'cpu_node')
            device: Hardware device ('cuda:0', 'cpu', etc.)
            bandwidth_mbps: Data transfer bandwidth in Mbps
            compute_factor: Relative compute speed (1.0 = baseline)
        """
        self.node_id = node_id
        self.device = torch.device(device)
        self.bandwidth_mbps = bandwidth_mbps
        self.compute_factor = compute_factor
        self.layers_allocated: List[str] = []
    
    def can_accommodate(self, layer_memory_mb: float) -> bool:
        """
        Check if node has capacity for layer memory.
        
        This is a simplified check; real implementation would query
        actual device memory availability.
        """
        if self.device.type == 'cuda':
            # Approximate GPU memory check
            total_memory = torch.cuda.get_device_properties(self.device).total_memory
            available_memory = total_memory * 0.8  # 80% safety margin
            
            return layer_memory_mb * 1024 * 1024 < available_memory
        
        return True  # CPU nodes have "unlimited" RAM
    
    def calculate_transfer_time(self, tensor_size_mb: float, target_node: 'VirtualNode') -> float:
        """
        Calculate data transfer time between nodes.
        
        Args:
            tensor_size_mb: Size of data to transfer
            target_node: Target node for transfer
            
        Returns:
            Transfer time in milliseconds
        """
        # Same node = no transfer
        if self.node_id == target_node.node_id:
            return 0.0
        
        # Calculate bottleneck bandwidth (min of source and target)
        bottleneck_bandwidth = min(self.bandwidth_mbps, target_node.bandwidth_mbps)
        
        # Time = Size / Bandwidth (accounting for protocol overhead ~10%)
        transfer_time_ms = (tensor_size_mb * 8 * 1.1) / bottleneck_bandwidth
        return transfer_time_ms
    
    def estimate_compute_time(self, layer_latency_ms: float) -> float:
        """
        Estimate compute time accounting for node performance.
        
        Args:
            layer_latency_ms: Baseline latency on reference hardware
            
        Returns:
            Estimated latency on this node
        """
        return layer_latency_ms / self.compute_factor


class StagedSimulator:
    """
    Simulates staged execution across virtual nodes.
    
    Runs a partitioned model as if it were distributed across
    multiple physical machines, but executes locally with
    accurate performance modeling.
    """
    
    def __init__(
        self,
        partition_plan,
        virtual_nodes: Dict[str, VirtualNode],
        enable_profiling: bool = True,
    ):
        """
        Initialize staged simulator.
        
        Args:
            partition_plan: PartitionPlan with stage assignments
            virtual_nodes: Dictionary mapping stage_id to VirtualNode
            enable_profiling: Whether to collect detailed execution traces
        """
        self.plan = partition_plan
        self.nodes = virtual_nodes
        self.enable_profiling = enable_profiling
        self.trace = ExecutionTrace() if enable_profiling else None
    
    def simulate(self, model, inputs: Dict[str, torch.Tensor]) -> Tuple[torch.Tensor, Optional[ExecutionTrace]]:
        """
        Simulate staged execution of model.
        
        Args:
            model: PyTorch model to execute
            inputs: Input tensors dictionary
            
        Returns:
            (output_tensor, execution_trace) tuple
        """
        if self.enable_profiling:
            self.trace.add_event('simulation_start')
        
        activations = inputs['input_ids']  # Start with input tokens
        
        # Execute each stage sequentially
        for stage_id, layers in self.plan.stages.items():
            if self.enable_profiling:
                self.trace.add_event('stage_start', stage_id=stage_id)
            
            # Get virtual node for this stage
            node = self.nodes.get(stage_id)
            
            if not node:
                raise ValueError(f"No virtual node configured for stage: {stage_id}")
            
            # Move activations to node device
            if activations.device != node.device:
                transfer_start = time.time()
                activations = activations.to(node.device)
                transfer_time = (time.time() - transfer_start) * 1000
                
                if self.enable_profiling and transfer_time > 0.1:  # Ignore tiny transfers
                    self.trace.add_event(
                        'transfer',
                        from_stage='previous',
                        to_stage=stage_id,
                        duration_ms=transfer_time,
                        size_mb=activations.numel() * activations.element_size() / (1024*1024),
                    )
            
            # Execute stage forward pass
            stage_start = time.time()
            activations = self._execute_stage(model, layers, activations, node.device)
            stage_latency_ms = (time.time() - stage_start) * 1000
            
            if self.enable_profiling:
                self.trace.add_event(
                    'stage_complete',
                    stage_id=stage_id,
                    duration_ms=stage_latency_ms,
                    device=str(node.device),
                )
        
        if self.enable_profiling:
            self.trace.add_event('simulation_complete')
        
        return activations, self.trace
    
    def _execute_stage(self, model, layer_names: List[str], activations: torch.Tensor, device: torch.device) -> torch.Tensor:
        """
        Execute forward pass for specific layers.
        
        Args:
            model: PyTorch model
            layer_names: Names of layers to execute
            activations: Input activations
            device: Target device
            
        Returns:
            Output activations
        """
        with torch.no_grad():
            # Simplified stage execution
            # In a real implementation, you'd route through specific layers
            # For now, we'll simulate by running entire model and timing it
            
            # This is a placeholder - actual implementation would need to
            # extract and run only the specified layers
            
            # Fix: Ensure input_ids are the correct dtype for embeddings
            activations_long = activations.long() if activations.dtype != torch.long else activations
            output = model(input_ids=activations_long.unsqueeze(0))
            
            return output.logits.squeeze(0)
    
    def estimate_pipeline_throughput(self, batch_size: int = 1) -> float:
        """
        Estimate maximum pipeline throughput.
        
        Args:
            batch_size: Batch size for inference
            
        Returns:
            Throughput in requests per second
        """
        if not self.trace:
            return 0.0
        
        stage_timings = self.trace.get_stage_timings()
        
        if not stage_timings:
            return 0.0
        
        # Pipeline throughput limited by bottleneck stage
        bottleneck_latency_ms = max(stage_timings.values())
        
        # Convert to requests per second
        throughput = (1000 / bottleneck_latency_ms) * batch_size
        return throughput
    
    def get_resource_utilization(self) -> Dict[str, Dict[str, float]]:
        """
        Calculate resource utilization per node.
        
        Returns:
            Dictionary with utilization metrics per node
        """
        if not self.trace:
            return {}
        
        utilization = {}
        stage_timings = self.trace.get_stage_timings()
        
        total_time = self.trace.get_total_latency()
        
        for stage_id, node in self.nodes.items():
            stage_time = stage_timings.get(stage_id, 0.0)
            
            utilization[stage_id] = {
                'node_id': node.node_id,
                'active_time_ms': stage_time,
                'utilization_pct': (stage_time / total_time) * 100 if total_time > 0 else 0.0,
                'device': str(node.device),
            }
        
        return utilization
    
    def to_summary(self) -> Dict[str, Any]:
        """Generate summary of simulation results."""
        if not self.trace:
            return {'error': 'No profiling data available'}
        
        stage_timings = self.trace.get_stage_timings()
        transfer_timings = self.trace.get_transfer_timings()
        
        total_compute = sum(stage_timings.values())
        total_transfer = sum(tf['duration_ms'] for tf in transfer_timings)
        
        return {
            'stage_timings': stage_timings,
            'transfer_timings': transfer_timings,
            'bottleneck_stage': max(stage_timings.items(), key=lambda x: x[1])[0],
            'bottleneck_latency_ms': max(stage_timings.values()) if stage_timings else 0.0,
            'total_compute_ms': total_compute,
            'total_transfer_ms': total_transfer,
            'total_latency_ms': total_compute + total_transfer,
            'pipeline_throughput_rps': self.estimate_pipeline_throughput(),
        }
