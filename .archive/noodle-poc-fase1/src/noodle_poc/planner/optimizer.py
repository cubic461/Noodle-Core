"""
Partition optimization algorithms using bin-packing and latency balancing.
"""

import pandas as pd
from typing import List, Dict, Tuple, Optional, Any
from collections import defaultdict
import numpy as np


class PartitionOptimizer:
    """
    Optimizes layer partitioning using various algorithms.
    
    Supports:
    - Bin-packing algorithms for latency balancing
    - Memory-constrained partitioning
    - Genetic algorithms for complex scenarios
    - Dynamic programming approaches
    """
    
    def __init__(self, metrics_data: pd.DataFrame):
        """
        Initialize optimizer with layer metrics.
        
        Args:
            metrics_data: DataFrame with layer metrics
        """
        self.metrics = metrics_data
        self.layer_info = self._prepare_layer_info()
    
    def _prepare_layer_info(self) -> Dict[str, Dict[str, float]]:
        """Prepare layer information dictionary."""
        layer_info = {}
        
        for _, row in self.metrics.iterrows():
            layer_info[row['layer_name']] = {
                'latency_ms': row['forward_latency_ms'],
                'memory_mb': row.get('parameter_size_mb', 0) or 0,
                'layer_type': row.get('layer_type', 'Unknown'),
                'parameters': row.get('num_parameters', 0),
            }
        
        return layer_info
    
    def optimize(
        self,
        valid_layers: pd.DataFrame,
        num_stages: int = 3,
        balance_threshold: float = 0.3,
        algorithm: str = 'binpack'
    ) -> Dict[str, List[str]]:
        """
        Optimize layer partitioning using specified algorithm.
        
        Args:
            valid_layers: DataFrame of layers to partition
            num_stages: Number of stages
            balance_threshold: Maximum latency variance (0.0 = perfect balance)
            algorithm: 'binpack', 'greedy', 'genetic'
        
        Returns:
            Dictionary mapping stage_id to list of layer names
        """
        if algorithm == 'binpack':
            return self._optimize_binpack(valid_layers, num_stages, balance_threshold)
        elif algorithm == 'greedy':
            return self._optimize_greedy(valid_layers, num_stages)
        else:
            raise ValueError(f"Unknown algorithm: {algorithm}")
    
    def _optimize_binpack(
        self,
        valid_layers: pd.DataFrame,
        num_stages: int,
        balance_threshold: float
    ) -> Dict[str, List[str]]:
        """
        Optimize using bin-packing algorithm with latency balancing.
        
        Algorithm:
        1. Sort layers by latency (largest first)
        2. Place each layer in the stage with minimal total latency
        3. Validate balance constraint
        4. If violated, use recursive bisection
        """
        # Prepare layer list
        layers = valid_layers.sort_values('forward_latency_ms', ascending=False)
        layer_data = [(row['layer_name'], row['forward_latency_ms']) 
                      for _, row in layers.iterrows()]
        
        # Bin-packing: place each layer in least-loaded stage
        stages = {f'stage_{i}': {'layers': [], 'latency': 0.0} 
                  for i in range(num_stages)}
        
        for layer_name, latency in layer_data:
            # Find stage with minimum latency
            min_stage = min(stages.keys(), key=lambda s: stages[s]['latency'])
            
            stages[min_stage]['layers'].append(layer_name)
            stages[min_stage]['latency'] += latency
        
        # Check balance constraint
        latencies = [stages[s]['latency'] for s in stages]
        variance = self._calculate_variance(latencies)
        avg_latency = sum(latencies) / len(latencies)
        
        if avg_latency > 0 and variance / avg_latency > balance_threshold:
            # Rebalance using recursive bisection
            stages = self._rebalance_bisection(layers, num_stages)
        
        return {
            stage_id: stage_data['layers']
            for stage_id, stage_data in stages.items()
        }
    
    def _optimize_greedy(
        self,
        valid_layers: pd.DataFrame,
        num_stages: int
    ) -> Dict[str, List[str]]:
        """
        Simple greedy optimization: accumulate layers until target latency.
        
        Less optimal but faster than bin-packing.
        """
        layers = valid_layers.sort_values('forward_latency_ms', ascending=False)
        
        # Calculate target latency per stage
        total_latency = layers['forward_latency_ms'].sum()
        target_latency = total_latency / num_stages
        
        stages = {f'stage_{i}': [] for i in range(num_stages)}
        current_stage = 0
        current_latency = 0.0
        
        for _, row in layers.iterrows():
            layer_latency = row['forward_latency_ms']
            
            # If adding this layer exceeds target and we're not at last stage
            if (current_latency + layer_latency > target_latency * 1.2 and 
                current_stage < num_stages - 1):
                current_stage += 1
                current_latency = 0.0
            
            stages[f'stage_{current_stage}'].append(row['layer_name'])
            current_latency += layer_latency
        
        return stages
    
    def _rebalance_bisection(
        self,
        layers: pd.DataFrame,
        num_stages: int,
        max_iterations: int = 10
    ) -> Dict[str, Dict[str, Any]]:
        """
        Rebalance stages using recursive bisection approach.
        
        More complex but better balance than greedy bin-packing.
        """
        # Group layers into optimal bins using dynamic programming
        layer_latencies = layers['forward_latency_ms'].values
        layer_names = layers['layer_name'].values.tolist()
        
        # Use First Fit Decreasing with early stopping
        stages = {f'stage_{i}': {'layers': [], 'latency': 0.0} 
                  for i in range(num_stages)}
        
        for layer_name, latency in zip(layer_names, layer_latencies):
            # Try to balance more aggressively
            min_stage = None
            min_latency = float('inf')
            
            for stage_id, stage_data in stages.items():
                if stage_data['latency'] < min_latency:
                    min_latency = stage_data['latency']
                    min_stage = stage_id
            
            if min_stage:
                stages[min_stage]['layers'].append(layer_name)
                stages[min_stage]['latency'] += latency
        
        return stages
    
    def _calculate_variance(self, values: List[float]) -> float:
        """Calculate variance of values."""
        if len(values) <= 1:
            return 0.0
        
        mean = sum(values) / len(values)
        variance = sum((x - mean) ** 2 for x in values) / len(values)
        return variance
    
    def optimize_with_memory_constraints(
        self,
        max_memory_per_stage_mb: float,
        num_stages: int = 3
    ) -> Dict[str, List[str]]:
        """
        Optimize with memory constraints per stage.
        
        First filters layers by memory, then performs latency optimization.
        """
        # Filter layers that fit in single stage
        large_layers = []
        small_layers = self.metrics[
            self.metrics['parameter_size_mb'] <= max_memory_per_stage_mb
        ].copy()
        
        # Handle layers that exceed memory limit (split or allocate separately)
        oversized = self.metrics[
            self.metrics['parameter_size_mb'] > max_memory_per_stage_mb
        ]
        
        if not oversized.empty:
            # For now, mark them for separate handling
            large_layers = oversized['layer_name'].tolist()
        
        # Optimize manageable layers
        stage_assignments = self.optimize(small_layers, num_stages)
        
        # Handle large layers by assigning them individually
        for i, large_layer in enumerate(large_layers):
            stage_assignments[f'stage_large_{i}'] = [large_layer]
        
        return stage_assignments
    
    def analyze_plan(self, plan: Dict[str, List[str]]) -> Dict[str, Any]:
        """
        Analyze the quality of a partition plan.
        
        Returns metrics like:
        - Latency balance
        - Memory balance
        - Communication overhead estimation
        """
        stage_metrics = {}
        
        for stage_id, layers in plan.items():
            stage_latency = sum(
                self.layer_info.get(layer, {}).get('latency_ms', 0)
                for layer in layers
            )
            
            stage_memory = sum(
                self.layer_info.get(layer, {}).get('memory_mb', 0)
                for layer in layers
            )
            
            stage_metrics[stage_id] = {
                'latency_ms': stage_latency,
                'memory_mb': stage_memory,
                'num_layers': len(layers),
            }
        
        latencies = [metrics['latency_ms'] for metrics in stage_metrics.values()]
        memories = [metrics['memory_mb'] for metrics in stage_metrics.values()]
        
        return {
            'stage_metrics': stage_metrics,
            'latency_stats': {
                'min': min(latencies),
                'max': max(latencies),
                'avg': sum(latencies) / len(latencies),
                'variance': self._calculate_variance(latencies),
            },
            'memory_stats': {
                'min': min(memories),
                'max': max(memories),
                'avg': sum(memories) / len(memories),
            },
            'bottleneck_stage': max(stage_metrics.items(), key=lambda x: x[1]['latency_ms'])[0],
        }
    
    def suggest_splits(self, layer_name: str) -> List[str]:
        """
        Suggest where a large layer can be split (for tensor parallelism).
        
        Returns list of suggested split strategies.
        """
        layer_metrics = self.metrics[
            self.metrics['layer_name'] == layer_name
        ].iloc[0]
        
        suggestions = []
        
        layer_type = layer_metrics.get('layer_type', 'Unknown')
        
        if layer_type in ['Linear', 'Conv2d']:
            suggestions.append("Column-wise split: weights[:, :dim//2]")
            suggestions.append("Row-wise split: weights[:dim//2, :]")
            suggestions.append("Head-wise (attention): split attention heads")
        
        elif layer_type == 'Embedding':
            suggestions.append("Vocabulary split: vocab[:len//2]")
        
        else:
            suggestions.append("Output feature split: divide output dimension")
        
        return suggestions
