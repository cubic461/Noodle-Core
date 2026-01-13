"""
Noodlenet::Optimization - optimization.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
System performance optimization for NoodleNet distributed workloads.

This module provides comprehensive performance optimization including
adaptive algorithms, workload balancing, and resource optimization.
"""

import asyncio
import time
import logging
import json
import statistics
import random
from typing import Dict, List, Optional, Set, Tuple, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import uuid
from .config import NoodleNetConfig
from .identity import NodeIdentity
from .routing import MessageRouter, RouteInfo
from .link import Message

logger = logging.getLogger(__name__)


class OptimizationType(Enum):
    """Types of optimizations"""
    WORKLOAD_BALANCING = "workload_balancing"
    RESOURCE_ALLOCATION = "resource_allocation"
    NETWORK_ROUTING = "network_routing"
    CACHING = "caching"
    COMPRESSION = "compression"
    BATCHING = "batching"
    PARALLELISM = "parallelism"
    PREDICTION = "prediction"


class OptimizationStrategy(Enum):
    """Optimization strategies"""
    REACTIVE = "reactive"  # React to current conditions
    PROACTIVE = "proactive"  # Anticipate future conditions
    ADAPTIVE = "adaptive"  # Learn and adapt over time
    PREDICTIVE = "predictive"  # Use ML to predict optimal settings


class OptimizationStatus(Enum):
    """Optimization status"""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


@dataclass
class OptimizationTarget:
    """Target for optimization"""
    
    target_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str = ""
    optimization_type: OptimizationType = OptimizationType.WORKLOAD_BALANCING
    target_metrics: List[str] = field(default_factory=list)
    
    # Optimization parameters
    current_value: Any = None
    target_value: Any = None
    min_value: Any = None
    max_value: Any = None
    
    # Constraints
    constraints: Dict[str, Any] = field(default_factory=dict)
    
    # Priority
    priority: int = 1  # 1-10, higher is more important
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'target_id': self.target_id,
            'name': self.name,
            'optimization_type': self.optimization_type.value,
            'target_metrics': self.target_metrics,
            'current_value': self.current_value,
            'target_value': self.target_value,
            'min_value': self.min_value,
            'max_value': self.max_value,
            'constraints': self.constraints,
            'priority': self.priority
        }


@dataclass
class OptimizationAction:
    """Represents an optimization action"""
    
    action_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    target_id: str = ""
    optimization_type: OptimizationType = OptimizationType.WORKLOAD_BALANCING
    strategy: OptimizationStrategy = OptimizationStrategy.REACTIVE
    
    # Action details
    action_type: str = ""
    parameters: Dict[str, Any] = field(default_factory=dict)
    
    # Status
    status: OptimizationStatus = OptimizationStatus.PENDING
    created_at: float = field(default_factory=time.time)
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    
    # Results
    expected_improvement: float = 0.0
    actual_improvement: float = 0.0
    confidence: float = 0.0
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'action_id': self.action_id,
            'target_id': self.target_id,
            'optimization_type': self.optimization_type.value,
            'strategy': self.strategy.value,
            'action_type': self.action_type,
            'parameters': self.parameters,
            'status': self.status.value,
            'created_at': self.created_at,
            'started_at': self.started_at,
            'completed_at': self.completed_at,
            'expected_improvement': self.expected_improvement,
            'actual_improvement': self.actual_improvement,
            'confidence': self.confidence
        }


@dataclass
class PerformanceMetric:
    """Performance metric for optimization"""
    
    name: str
    value: float
    timestamp: float = field(default_factory=time.time)
    unit: str = ""
    labels: Dict[str, str] = field(default_factory=dict)
    
    # Historical data
    history: deque = field(default_factory=lambda: deque(maxlen=100))
    
    def add_sample(self, value: float, timestamp: Optional[float] = None):
        """Add a sample to the history"""
        if timestamp is None:
            timestamp = time.time()
        
        self.history.append({
            'value': value,
            'timestamp': timestamp
        })
        
        self.value = value
        self.timestamp = timestamp
    
    def get_trend(self, window_size: int = 10) -> float:
        """Calculate trend over window"""
        if len(self.history) < window_size:
            return 0.0
        
        recent_values = [sample['value'] for sample in list(self.history)[-window_size:]]
        
        # Simple linear regression
        n = len(recent_values)
        x = list(range(n))
        y = recent_values
        
        x_mean = statistics.mean(x)
        y_mean = statistics.mean(y)
        
        numerator = sum((x[i] - x_mean) * (y[i] - y_mean) for i in range(n))
        denominator = sum((x[i] - x_mean) ** 2 for i in range(n))
        
        if denominator == 0:
            return 0.0
        
        return numerator / denominator
    
    def get_variance(self, window_size: int = 10) -> float:
        """Calculate variance over window"""
        if len(self.history) < window_size:
            return 0.0
        
        recent_values = [sample['value'] for sample in list(self.history)[-window_size:]]
        return statistics.variance(recent_values) if len(recent_values) > 1 else 0.0


class WorkloadBalancer:
    """Workload balancer for distributed tasks"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize workload balancer
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        
        # Node information
        self._node_capacity: Dict[str, float] = {}
        self._node_load: Dict[str, float] = {}
        self._node_performance: Dict[str, PerformanceMetric] = {}
        
        # Workload distribution
        self._task_assignments: Dict[str, str] = {}  # task_id -> node_id
        self._node_tasks: Dict[str, Set[str]] = defaultdict(set)
        
        # Balancing algorithms
        self._algorithms = {
            'round_robin': self._round_robin_balance,
            'load_based': self._load_based_balance,
            'performance_based': self._performance_based_balance,
            'capacity_based': self._capacity_based_balance,
            'weighted': self._weighted_balance
        }
        
        self._current_algorithm = 'load_based'
        
        # Statistics
        self._stats = {
            'tasks_balanced': 0,
            'rebalances': 0,
            'algorithm_changes': 0
        }
    
    def register_node(self, node_id: str, capacity: float):
        """
        Register a node for workload balancing
        
        Args:
            node_id: ID of the node
            capacity: Node capacity (0.0-1.0)
        """
        self._node_capacity[node_id] = capacity
        self._node_load[node_id] = 0.0
        self._node_performance[node_id] = PerformanceMetric(
            name=f"node_performance_{node_id}",
            value=1.0,
            unit="score"
        )
        
        logger.info(f"Registered node {node_id} with capacity {capacity}")
    
    def unregister_node(self, node_id: str):
        """Unregister a node"""
        self._node_capacity.pop(node_id, None)
        self._node_load.pop(node_id, None)
        self._node_performance.pop(node_id, None)
        
        # Reassign tasks from this node
        tasks_to_reassign = self._node_tasks.get(node_id, set())
        for task_id in tasks_to_reassign:
            self._task_assignments.pop(task_id, None)
        
        self._node_tasks.pop(node_id, None)
        
        logger.info(f"Unregistered node {node_id}")
    
    def assign_task(self, task_id: str, preferred_node: Optional[str] = None) -> str:
        """
        Assign a task to a node
        
        Args:
            task_id: ID of the task
            preferred_node: Preferred node for assignment
            
        Returns:
            Assigned node ID
        """
        # If preferred node is specified and available, use it
        if preferred_node and self._is_node_available(preferred_node):
            self._assign_task_to_node(task_id, preferred_node)
            return preferred_node
        
        # Use current balancing algorithm
        algorithm = self._algorithms.get(self._current_algorithm)
        if algorithm:
            assigned_node = algorithm(task_id)
        else:
            assigned_node = self._load_based_balance(task_id)
        
        return assigned_node
    
    def update_node_load(self, node_id: str, load: float):
        """Update node load"""
        if node_id in self._node_load:
            self._node_load[node_id] = load
    
    def update_node_performance(self, node_id: str, performance: float):
        """Update node performance"""
        if node_id in self._node_performance:
            self._node_performance[node_id].add_sample(performance)
    
    def rebalance(self) -> List[Tuple[str, str]]:
        """
        Rebalance workload across nodes
        
        Returns:
            List of (task_id, new_node_id) reassignments
        """
        reassignments = []
        
        # Find overloaded nodes
        overloaded_nodes = [
            node_id for node_id, load in self._node_load.items()
            if load > 0.8  # 80% load threshold
        ]
        
        # Find underloaded nodes
        underloaded_nodes = [
            node_id for node_id, load in self._node_load.items()
            if load < 0.5  # 50% load threshold
        ]
        
        # Reassign tasks from overloaded to underloaded nodes
        for overloaded_node in overloaded_nodes:
            if not underloaded_nodes:
                break
            
            # Get tasks from overloaded node
            tasks = list(self._node_tasks.get(overloaded_node, set()))
            
            # Move some tasks to underloaded nodes
            tasks_to_move = min(len(tasks) // 2, len(underloaded_nodes))
            
            for i in range(tasks_to_move):
                if not tasks or not underloaded_nodes:
                    break
                
                # Select a task to move
                task_id = tasks.pop()
                
                # Select an underloaded node
                underloaded_node = underloaded_nodes[0]
                
                # Reassign task
                self._reassign_task(task_id, overloaded_node, underloaded_node)
                reassignments.append((task_id, underloaded_node))
                
                # Update loads
                self._node_load[overloaded_node] -= 0.1
                self._node_load[underloaded_node] += 0.1
                
                # Check if underloaded node is now balanced
                if self._node_load[underloaded_node] > 0.7:
                    underloaded_nodes.pop(0)
        
        if reassignments:
            self._stats['rebalances'] += 1
            logger.info(f"Rebalanced {len(reassignments)} tasks")
        
        return reassignments
    
    def set_algorithm(self, algorithm: str):
        """Set balancing algorithm"""
        if algorithm in self._algorithms:
            self._current_algorithm = algorithm
            self._stats['algorithm_changes'] += 1
            logger.info(f"Changed workload balancing algorithm to {algorithm}")
        else:
            logger.warning(f"Unknown balancing algorithm: {algorithm}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get workload balancer statistics"""
        stats = self._stats.copy()
        
        # Add node statistics
        stats['nodes'] = len(self._node_capacity)
        stats['total_tasks'] = len(self._task_assignments)
        stats['average_load'] = statistics.mean(self._node_load.values()) if self._node_load else 0.0
        stats['current_algorithm'] = self._current_algorithm
        
        # Add node details
        stats['node_details'] = {
            node_id: {
                'capacity': capacity,
                'load': self._node_load.get(node_id, 0.0),
                'tasks': len(self._node_tasks.get(node_id, set())),
                'performance': self._node_performance.get(node_id, PerformanceMetric("dummy", 0.0)).value
            }
            for node_id, capacity in self._node_capacity.items()
        }
        
        return stats
    
    def _is_node_available(self, node_id: str) -> bool:
        """Check if a node is available for task assignment"""
        return (
            node_id in self._node_capacity and
            self._node_load.get(node_id, 0.0) < 0.95  # 95% load threshold
        )
    
    def _assign_task_to_node(self, task_id: str, node_id: str):
        """Assign a task to a specific node"""
        # Remove from previous node if assigned
        if task_id in self._task_assignments:
            old_node = self._task_assignments[task_id]
            self._node_tasks[old_node].discard(task_id)
        
        # Assign to new node
        self._task_assignments[task_id] = node_id
        self._node_tasks[node_id].add(task_id)
        
        # Update load
        self._node_load[node_id] = min(1.0, self._node_load.get(node_id, 0.0) + 0.1)
        
        # Update statistics
        self._stats['tasks_balanced'] += 1
    
    def _reassign_task(self, task_id: str, old_node: str, new_node: str):
        """Reassign a task from one node to another"""
        # Remove from old node
        self._node_tasks[old_node].discard(task_id)
        
        # Assign to new node
        self._task_assignments[task_id] = new_node
        self._node_tasks[new_node].add(task_id)
    
    def _round_robin_balance(self, task_id: str) -> str:
        """Round-robin balancing"""
        if not self._node_capacity:
            raise ValueError("No nodes available for balancing")
        
        # Find node with fewest tasks
        min_tasks = float('inf')
        best_node = None
        
        for node_id in self._node_capacity.keys():
            task_count = len(self._node_tasks.get(node_id, set()))
            if task_count < min_tasks:
                min_tasks = task_count
                best_node = node_id
        
        if best_node:
            self._assign_task_to_node(task_id, best_node)
            return best_node
        
        raise ValueError("No suitable node found for task assignment")
    
    def _load_based_balance(self, task_id: str) -> str:
        """Load-based balancing"""
        if not self._node_capacity:
            raise ValueError("No nodes available for balancing")
        
        # Find node with lowest load
        min_load = float('inf')
        best_node = None
        
        for node_id, load in self._node_load.items():
            if load < min_load:
                min_load = load
                best_node = node_id
        
        if best_node:
            self._assign_task_to_node(task_id, best_node)
            return best_node
        
        raise ValueError("No suitable node found for task assignment")
    
    def _performance_based_balance(self, task_id: str) -> str:
        """Performance-based balancing"""
        if not self._node_capacity:
            raise ValueError("No nodes available for balancing")
        
        # Find node with best performance
        max_performance = -1.0
        best_node = None
        
        for node_id, perf_metric in self._node_performance.items():
            if perf_metric.value > max_performance:
                max_performance = perf_metric.value
                best_node = node_id
        
        if best_node:
            self._assign_task_to_node(task_id, best_node)
            return best_node
        
        raise ValueError("No suitable node found for task assignment")
    
    def _capacity_based_balance(self, task_id: str) -> str:
        """Capacity-based balancing"""
        if not self._node_capacity:
            raise ValueError("No nodes available for balancing")
        
        # Find node with most available capacity
        max_available = -1.0
        best_node = None
        
        for node_id, capacity in self._node_capacity.items():
            load = self._node_load.get(node_id, 0.0)
            available = capacity - load
            
            if available > max_available:
                max_available = available
                best_node = node_id
        
        if best_node:
            self._assign_task_to_node(task_id, best_node)
            return best_node
        
        raise ValueError("No suitable node found for task assignment")
    
    def _weighted_balance(self, task_id: str) -> str:
        """Weighted balancing (combines multiple factors)"""
        if not self._node_capacity:
            raise ValueError("No nodes available for balancing")
        
        # Calculate weighted score for each node
        best_score = -1.0
        best_node = None
        
        for node_id in self._node_capacity.keys():
            # Get metrics
            capacity = self._node_capacity[node_id]
            load = self._node_load.get(node_id, 0.0)
            performance = self._node_performance[node_id].value
            
            # Calculate weighted score
            # Higher capacity, lower load, and higher performance are better
            score = (capacity * 0.3) + ((1.0 - load) * 0.4) + (performance * 0.3)
            
            if score > best_score:
                best_score = score
                best_node = node_id
        
        if best_node:
            self._assign_task_to_node(task_id, best_node)
            return best_node
        
        raise ValueError("No suitable node found for task assignment")


class ResourceOptimizer:
    """Resource optimizer for distributed systems"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize resource optimizer
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        
        # Resource metrics
        self._cpu_metrics: Dict[str, PerformanceMetric] = {}
        self._memory_metrics: Dict[str, PerformanceMetric] = {}
        self._network_metrics: Dict[str, PerformanceMetric] = {}
        self._storage_metrics: Dict[str, PerformanceMetric] = {}
        
        # Optimization targets
        self._optimization_targets: Dict[str, OptimizationTarget] = {}
        
        # Optimization history
        self._optimization_history: List[OptimizationAction] = []
        
        # Optimization algorithms
        self._algorithms = {
            'threshold_based': self._threshold_based_optimization,
            'trend_based': self._trend_based_optimization,
            'ml_based': self._ml_based_optimization,
            'rule_based': self._rule_based_optimization
        }
        
        self._current_algorithm = 'threshold_based'
        
        # Statistics
        self._stats = {
            'optimizations_performed': 0,
            'optimizations_successful': 0,
            'performance_improvement': 0.0,
            'resource_savings': 0.0
        }
    
    def register_node(self, node_id: str):
        """Register a node for resource optimization"""
        self._cpu_metrics[node_id] = PerformanceMetric(
            name=f"cpu_usage_{node_id}",
            value=0.0,
            unit="percent"
        )
        
        self._memory_metrics[node_id] = PerformanceMetric(
            name=f"memory_usage_{node_id}",
            value=0.0,
            unit="percent"
        )
        
        self._network_metrics[node_id] = PerformanceMetric(
            name=f"network_usage_{node_id}",
            value=0.0,
            unit="percent"
        )
        
        self._storage_metrics[node_id] = PerformanceMetric(
            name=f"storage_usage_{node_id}",
            value=0.0,
            unit="percent"
        )
        
        logger.info(f"Registered node {node_id} for resource optimization")
    
    def update_resource_metrics(self, node_id: str, cpu: float, memory: float,
                             network: float, storage: float):
        """Update resource metrics for a node"""
        if node_id in self._cpu_metrics:
            self._cpu_metrics[node_id].add_sample(cpu)
        
        if node_id in self._memory_metrics:
            self._memory_metrics[node_id].add_sample(memory)
        
        if node_id in self._network_metrics:
            self._network_metrics[node_id].add_sample(network)
        
        if node_id in self._storage_metrics:
            self._storage_metrics[node_id].add_sample(storage)
    
    def add_optimization_target(self, target: OptimizationTarget):
        """Add an optimization target"""
        self._optimization_targets[target.target_id] = target
        logger.info(f"Added optimization target: {target.name}")
    
    def remove_optimization_target(self, target_id: str) -> bool:
        """Remove an optimization target"""
        if target_id in self._optimization_targets:
            del self._optimization_targets[target_id]
            logger.info(f"Removed optimization target: {target_id}")
            return True
        return False
    
    def optimize(self) -> List[OptimizationAction]:
        """
        Perform resource optimization
        
        Returns:
            List of optimization actions
        """
        # Use current optimization algorithm
        algorithm = self._algorithms.get(self._current_algorithm)
        if algorithm:
            actions = algorithm()
        else:
            actions = self._threshold_based_optimization()
        
        # Execute actions
        successful_actions = []
        for action in actions:
            try:
                success = await self._execute_optimization_action(action)
                if success:
                    successful_actions.append(action)
                    self._stats['optimizations_successful'] += 1
            except Exception as e:
                logger.error(f"Failed to execute optimization action {action.action_id}: {e}")
        
        # Update statistics
        self._stats['optimizations_performed'] += len(actions)
        
        # Add to history
        self._optimization_history.extend(actions)
        
        return successful_actions
    
    def set_algorithm(self, algorithm: str):
        """Set optimization algorithm"""
        if algorithm in self._algorithms:
            self._current_algorithm = algorithm
            logger.info(f"Changed resource optimization algorithm to {algorithm}")
        else:
            logger.warning(f"Unknown optimization algorithm: {algorithm}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get resource optimizer statistics"""
        stats = self._stats.copy()
        
        # Add target statistics
        stats['optimization_targets'] = len(self._optimization_targets)
        stats['registered_nodes'] = len(self._cpu_metrics)
        stats['current_algorithm'] = self._current_algorithm
        
        # Add resource statistics
        if self._cpu_metrics:
            stats['average_cpu_usage'] = statistics.mean(
                metric.value for metric in self._cpu_metrics.values()
            )
        
        if self._memory_metrics:
            stats['average_memory_usage'] = statistics.mean(
                metric.value for metric in self._memory_metrics.values()
            )
        
        return stats
    
    def _threshold_based_optimization(self) -> List[OptimizationAction]:
        """Threshold-based optimization"""
        actions = []
        
        for target_id, target in self._optimization_targets.items():
            # Check if target needs optimization
            if self._needs_optimization(target):
                # Create optimization action
                action = OptimizationAction(
                    target_id=target_id,
                    optimization_type=target.optimization_type,
                    strategy=OptimizationStrategy.REACTIVE,
                    action_type="threshold_adjustment",
                    parameters={
                        'target_value': target.target_value,
                        'current_value': target.current_value
                    }
                )
                
                actions.append(action)
        
        return actions
    
    def _trend_based_optimization(self) -> List[OptimizationAction]:
        """Trend-based optimization"""
        actions = []
        
        for target_id, target in self._optimization_targets.items():
            # Check trends
            if self._has_negative_trend(target):
                # Create optimization action
                action = OptimizationAction(
                    target_id=target_id,
                    optimization_type=target.optimization_type,
                    strategy=OptimizationStrategy.PROACTIVE,
                    action_type="trend_correction",
                    parameters={
                        'trend': 'negative',
                        'target_value': target.target_value
                    }
                )
                
                actions.append(action)
        
        return actions
    
    def _ml_based_optimization(self) -> List[OptimizationAction]:
        """Machine learning based optimization"""
        # This would use ML models to predict optimal settings
        # For now, we'll simulate with a simple heuristic
        actions = []
        
        # Analyze resource usage patterns
        for node_id in self._cpu_metrics.keys():
            cpu_metric = self._cpu_metrics[node_id]
            memory_metric = self._memory_metrics[node_id]
            
            # Check for patterns that indicate optimization opportunities
            if cpu_metric.get_variance() > 100 and memory_metric.get_variance() > 50:
                # High variance suggests optimization opportunity
                action = OptimizationAction(
                    target_id=f"resource_optimization_{node_id}",
                    optimization_type=OptimizationType.RESOURCE_ALLOCATION,
                    strategy=OptimizationStrategy.PREDICTIVE,
                    action_type="resource_reallocation",
                    parameters={
                        'node_id': node_id,
                        'cpu_variance': cpu_metric.get_variance(),
                        'memory_variance': memory_metric.get_variance()
                    }
                )
                
                actions.append(action)
        
        return actions
    
    def _rule_based_optimization(self) -> List[OptimizationAction]:
        """Rule-based optimization"""
        actions = []
        
        # Apply optimization rules
        for node_id in self._cpu_metrics.keys():
            cpu_usage = self._cpu_metrics[node_id].value
            memory_usage = self._memory_metrics[node_id].value
            
            # Rule: High CPU, low memory -> CPU optimization
            if cpu_usage > 80 and memory_usage < 50:
                action = OptimizationAction(
                    target_id=f"cpu_optimization_{node_id}",
                    optimization_type=OptimizationType.RESOURCE_ALLOCATION,
                    strategy=OptimizationStrategy.REACTIVE,
                    action_type="cpu_optimization",
                    parameters={
                        'node_id': node_id,
                        'cpu_usage': cpu_usage,
                        'memory_usage': memory_usage
                    }
                )
                
                actions.append(action)
            
            # Rule: Low CPU, high memory -> Memory optimization
            elif cpu_usage < 50 and memory_usage > 80:
                action = OptimizationAction(
                    target_id=f"memory_optimization_{node_id}",
                    optimization_type=OptimizationType.RESOURCE_ALLOCATION,
                    strategy=OptimizationStrategy.REACTIVE,
                    action_type="memory_optimization",
                    parameters={
                        'node_id': node_id,
                        'cpu_usage': cpu_usage,
                        'memory_usage': memory_usage
                    }
                )
                
                actions.append(action)
        
        return actions
    
    def _needs_optimization(self, target: OptimizationTarget) -> bool:
        """Check if a target needs optimization"""
        if target.current_value is None or target.target_value is None:
            return False
        
        # Check if current value is outside acceptable range
        if target.min_value is not None and target.current_value < target.min_value:
            return True
        
        if target.max_value is not None and target.current_value > target.max_value:
            return True
        
        # Check if current value is far from target
        if isinstance(target.current_value, (int, float)) and isinstance(target.target_value, (int, float)):
            diff = abs(target.current_value - target.target_value)
            threshold = abs(target.target_value) * 0.1  # 10% threshold
            
            return diff > threshold
        
        return False
    
    def _has_negative_trend(self, target: OptimizationTarget) -> bool:
        """Check if a target has a negative trend"""
        # This would analyze trends in target metrics
        # For now, we'll use a simple heuristic
        return random.random() < 0.2  # 20% chance of negative trend
    
    async def _execute_optimization_action(self, action: OptimizationAction) -> bool:
        """Execute an optimization action"""
        try:
            # Update status
            action.status = OptimizationStatus.RUNNING
            action.started_at = time.time()
            
            # Simulate optimization execution
            await asyncio.sleep(0.1)  # Simulate work
            
            # Update status
            action.status = OptimizationStatus.COMPLETED
            action.completed_at = time.time()
            
            # Calculate improvement (simulated)
            action.actual_improvement = random.uniform(0.05, 0.15)  # 5-15% improvement
            self._stats['performance_improvement'] += action.actual_improvement
            
            logger.info(f"Executed optimization action {action.action_id}")
            return True
            
        except Exception as e:
            action.status = OptimizationStatus.FAILED
            logger.error(f"Failed to execute optimization action {action.action_id}: {e}")
            return False


class DistributedPerformanceOptimizer:
    """Comprehensive performance optimizer for distributed systems"""
    
    def __init__(self, local_node_id: str, message_router: MessageRouter,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialize distributed performance optimizer
        
        Args:
            local_node_id: ID of the local node
            message_router: Message router for communication
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.message_router = message_router
        self.config = config or NoodleNetConfig()
        
        # Components
        self.workload_balancer = WorkloadBalancer(config)
        self.resource_optimizer = ResourceOptimizer(config)
        
        # Optimization targets
        self._optimization_targets: Dict[str, OptimizationTarget] = {}
        
        # Background tasks
        self._optimization_task: Optional[asyncio.Task] = None
        self._coordination_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Statistics
        self._stats = {
            'optimizations_performed': 0,
            'performance_improvement': 0.0,
            'resource_savings': 0.0,
            'last_optimization': 0.0
        }
        
        # Setup default optimization targets
        self._setup_default_targets()
    
    async def start(self):
        """Start distributed performance optimizer"""
        if self._running:
            return
        
        self._running = True
        self._optimization_task = asyncio.create_task(self._optimization_loop())
        self._coordination_task = asyncio.create_task(self._coordination_loop())
        
        logger.info("Distributed performance optimizer started")
    
    async def stop(self):
        """Stop distributed performance optimizer"""
        if not self._running:
            return
        
        self._running = False
        
        # Cancel background tasks
        for task in [self._optimization_task, self._coordination_task]:
            if task and not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        logger.info("Distributed performance optimizer stopped")
    
    def register_node(self, node_id: str, capacity: float):
        """Register a node for optimization"""
        self.workload_balancer.register_node(node_id, capacity)
        self.resource_optimizer.register_node(node_id)
    
    def unregister_node(self, node_id: str):
        """Unregister a node"""
        self.workload_balancer.unregister_node(node_id)
    
    def update_node_metrics(self, node_id: str, cpu: float, memory: float,
                           network: float, storage: float, performance: float):
        """Update node metrics"""
        # Update resource optimizer
        self.resource_optimizer.update_resource_metrics(node_id, cpu, memory, network, storage)
        
        # Update workload balancer
        self.workload_balancer.update_node_load(node_id, (cpu + memory) / 2.0)
        self.workload_balancer.update_node_performance(node_id, performance)
    
    def assign_task(self, task_id: str, preferred_node: Optional[str] = None) -> str:
        """Assign a task to a node"""
        return self.workload_balancer.assign_task(task_id, preferred_node)
    
    def add_optimization_target(self, target: OptimizationTarget):
        """Add an optimization target"""
        self._optimization_targets[target.target_id] = target
        self.resource_optimizer.add_optimization_target(target)
    
    def remove_optimization_target(self, target_id: str) -> bool:
        """Remove an optimization target"""
        if target_id in self._optimization_targets:
            del self._optimization_targets[target_id]
            return self.resource_optimizer.remove_optimization_target(target_id)
        return False
    
    def get_optimization_targets(self) -> Dict[str, OptimizationTarget]:
        """Get all optimization targets"""
        return self._optimization_targets.copy()
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get optimizer statistics"""
        stats = self._stats.copy()
        
        # Add component statistics
        stats['workload_balancer'] = self.workload_balancer.get_statistics()
        stats['resource_optimizer'] = self.resource_optimizer.get_statistics()
        
        return stats
    
    def _setup_default_targets(self):
        """Setup default optimization targets"""
        # CPU usage target
        cpu_target = OptimizationTarget(
            name="CPU Usage",
            optimization_type=OptimizationType.RESOURCE_ALLOCATION,
            target_metrics=["cpu_usage"],
            target_value=70.0,
            max_value=90.0,
            priority=8
        )
        self.add_optimization_target(cpu_target)
        
        # Memory usage target
        memory_target = OptimizationTarget(
            name="Memory Usage",
            optimization_type=OptimizationType.RESOURCE_ALLOCATION,
            target_metrics=["memory_usage"],
            target_value=75.0,
            max_value=95.0,
            priority=8
        )
        self.add_optimization_target(memory_target)
        
        # Network latency target
        latency_target = OptimizationTarget(
            name="Network Latency",
            optimization_type=OptimizationType.NETWORK_ROUTING,
            target_metrics=["network_latency"],
            target_value=50.0,  # 50ms
            max_value=100.0,  # 100ms
            priority=7
        )
        self.add_optimization_target(latency_target)
        
        # Task completion time target
        completion_target = OptimizationTarget(
            name="Task Completion Time",
            optimization_type=OptimizationType.WORKLOAD_BALANCING,
            target_metrics=["task_completion_time"],
            target_value=5.0,  # 5 seconds
            max_value=10.0,  # 10 seconds
            priority=9
        )
        self.add_optimization_target(completion_target)
    
    async def _optimization_loop(self):
        """Main optimization loop"""
        while self._running:
            try:
                # Perform resource optimization
                resource_actions = self.resource_optimizer.optimize()
                
                # Perform workload rebalancing
                rebalances = self.workload_balancer.rebalance()
                
                # Update statistics
                if resource_actions or rebalances:
                    self._stats['optimizations_performed'] += 1
                    self._stats['last_optimization'] = time.time()
                
                # Calculate total improvement
                total_improvement = sum(
                    action.actual_improvement for action in resource_actions
                )
                self._stats['performance_improvement'] += total_improvement
                
                await asyncio.sleep(self.config.optimization_interval)
                
            except Exception as e:
                logger.error(f"Error in optimization loop: {e}")
                await asyncio.sleep(30)
    
    async def _coordination_loop(self):
        """Coordination loop for distributed optimization"""
        while self._running:
            try:
                # Share optimization data with other nodes
                await self._share_optimization_data()
                
                # Receive optimization data from other nodes
                await self._receive_optimization_data()
                
                await asyncio.sleep(self.config.coordination_interval)
                
            except Exception as e:
                logger.error(f"Error in coordination loop: {e}")
                await asyncio.sleep(60)
    
    async def _share_optimization_data(self):
        """Share optimization data with other nodes"""
        # In a real implementation, this would send optimization data to other nodes
        # For now, we'll simulate sharing
        pass
    
    async def _receive_optimization_data(self):
        """Receive optimization data from other nodes"""
        # In a real implementation, this would receive optimization data from other nodes
        # For now, we'll simulate receiving
        pass

