"""
Scaling::Horizontal Scaler - horizontal_scaler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Horizontal Scaling Module for NoodleNet
Implements distributed processing, load balancing, and auto-scaling capabilities
"""

import asyncio
import time
import logging
import json
import random
from typing import Dict, List, Optional, Set, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import threading
import psutil
import socket
from concurrent.futures import ThreadPoolExecutor
from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from ..link import NoodleLink
from ..identity import NodeIdentity, NoodleIdentityManager

logger = logging.getLogger(__name__)


class ScalingMetric(Enum):
    """Types of scaling metrics"""
    CPU_USAGE = "cpu_usage"
    MEMORY_USAGE = "memory_usage"
    REQUEST_COUNT = "request_count"
    RESPONSE_TIME = "response_time"
    ERROR_RATE = "error_rate"
    THROUGHPUT = "throughput"


class ScalingAction(Enum):
    """Types of scaling actions"""
    SCALE_UP = "scale_up"
    SCALE_DOWN = "scale_down"
    REDISTRIBUTE_LOAD = "redistribute_load"
    ADD_NODE = "add_node"
    REMOVE_NODE = "remove_node"


@dataclass
class ScalingDecision:
    """Represents a scaling decision"""
    decision_id: str
    action: ScalingAction
    target_nodes: List[str]
    reason: str
    priority: float
    expected_impact: float
    confidence: float
    cost: float
    metadata: Dict[str, Any] = field(default_factory=dict)
    status: str = "pending"  # pending, executing, completed, failed
    created_at: float = field(default_factory=time.time)
    executed_at: Optional[float] = None
    completed_at: Optional[float] = None


@dataclass
class LoadMetrics:
    """Load metrics for a node"""
    node_id: str
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    request_count: int = 0
    response_time: float = 0.0
    error_rate: float = 0.0
    throughput: float = 0.0
    last_updated: float = field(default_factory=time.time)
    active_connections: int = 0
    queue_size: int = 0


class LoadBalancer:
    """Intelligent load balancer for distributed processing"""
    
    def __init__(self, mesh: NoodleMesh, config: NoodleNetConfig):
        self.mesh = mesh
        self.config = config
        
        # Load balancing strategies
        self.strategies = {
            'round_robin': self._round_robin_strategy,
            'least_connections': self._least_connections_strategy,
            'least_response_time': self._least_response_time_strategy,
            'resource_based': self._resource_based_strategy,
            'weighted_round_robin': self._weighted_round_robin_strategy
        }
        
        self.current_strategy = config.get('load_balancing_strategy', 'resource_based')
        
        # Load tracking
        self.node_loads: Dict[str, LoadMetrics] = {}
        self.request_history = deque(maxlen=10000)
        self.health_check_history = deque(maxlen=1000)
        
        # Load balancing state
        self.current_index = 0
        self.weights = defaultdict(int)
        
        # Statistics
        self.stats = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'average_response_time': 0.0,
            'load_balancing_efficiency': 0.0
        }
        
        logger.info(f"LoadBalancer initialized with strategy: {self.current_strategy}")
    
    def select_node(self, available_nodes: List[str], request_context: Dict[str, Any] = None) -> Optional[str]:
        """Select the best node for a request"""
        if not available_nodes:
            return None
        
        # Get current load metrics for available nodes
        available_loads = []
        for node_id in available_nodes:
            if node_id in self.node_loads:
                available_loads.append((node_id, self.node_loads[node_id]))
        
        if not available_loads:
            return random.choice(available_nodes)
        
        # Apply current strategy
        strategy_func = self.strategies.get(self.current_strategy, self._resource_based_strategy)
        selected_node = strategy_func(available_loads, request_context)
        
        # Update request history
        self.request_history.append({
            'timestamp': time.time(),
            'selected_node': selected_node,
            'strategy': self.current_strategy,
            'request_context': request_context
        })
        
        self.stats['total_requests'] += 1
        
        return selected_node
    
    def _round_robin_strategy(self, available_loads: List[tuple], request_context: Dict[str, Any]) -> str:
        """Round-robin load balancing strategy"""
        if not hasattr(self, '_round_robin_index'):
            self._round_robin_index = 0
        
        selected_node = available_loads[self._round_robin_index % len(available_loads)][0]
        self._round_robin_index += 1
        
        return selected_node
    
    def _least_connections_strategy(self, available_loads: List[tuple], request_context: Dict[str, Any]) -> str:
        """Least connections load balancing strategy"""
        return min(available_loads, key=lambda x: x[1].active_connections)[0]
    
    def _least_response_time_strategy(self, available_loads: List[tuple], request_context: Dict[str, Any]) -> str:
        """Least response time load balancing strategy"""
        return min(available_loads, key=lambda x: x[1].response_time)[0]
    
    def _resource_based_strategy(self, available_loads: List[tuple], request_context: Dict[str, Any]) -> str:
        """Resource-based load balancing strategy"""
        def calculate_score(load_metrics: LoadMetrics) -> float:
            # Calculate composite score based on multiple factors
            cpu_score = load_metrics.cpu_usage / 100.0
            memory_score = load_metrics.memory_usage / 100.0
            connections_score = load_metrics.active_connections / 100.0
            response_time_score = min(load_metrics.response_time / 1000.0, 1.0)
            
            # Weighted combination
            total_score = (cpu_score * 0.3 + memory_score * 0.3 + 
                          connections_score * 0.2 + response_time_score * 0.2)
            
            return total_score
        
        return min(available_loads, key=lambda x: calculate_score(x[1]))[0]
    
    def _weighted_round_robin_strategy(self, available_loads: List[tuple], request_context: Dict[str, Any]) -> str:
        """Weighted round-robin load balancing strategy"""
        # Select node based on weights
        total_weight = sum(self.weights[node_id] for node_id, _ in available_loads)
        if total_weight == 0:
            return random.choice([node_id for node_id, _ in available_loads])
        
        # Weighted random selection
        rand_value = random.uniform(0, total_weight)
        current_weight = 0
        
        for node_id, _ in available_loads:
            current_weight += self.weights[node_id]
            if rand_value <= current_weight:
                return node_id
        
        return available_loads[-1][0]
    
    def update_node_load(self, node_id: str, metrics: Dict[str, Any]):
        """Update load metrics for a node"""
        if node_id not in self.node_loads:
            self.node_loads[node_id] = LoadMetrics(node_id=node_id)
        
        load_metrics = self.node_loads[node_id]
        load_metrics.cpu_usage = metrics.get('cpu_usage', 0.0)
        load_metrics.memory_usage = metrics.get('memory_usage', 0.0)
        load_metrics.request_count = metrics.get('request_count', 0)
        load_metrics.response_time = metrics.get('response_time', 0.0)
        load_metrics.error_rate = metrics.get('error_rate', 0.0)
        load_metrics.throughput = metrics.get('throughput', 0.0)
        load_metrics.active_connections = metrics.get('active_connections', 0)
        load_metrics.queue_size = metrics.get('queue_size', 0)
        load_metrics.last_updated = time.time()
    
    def set_node_weight(self, node_id: str, weight: int):
        """Set weight for a node in weighted strategies"""
        self.weights[node_id] = max(0, weight)
    
    def get_load_distribution(self) -> Dict[str, Any]:
        """Get current load distribution across nodes"""
        distribution = {}
        total_requests = sum(load.request_count for load in self.node_loads.values())
        
        for node_id, load_metrics in self.node_loads.items():
            distribution[node_id] = {
                'cpu_usage': load_metrics.cpu_usage,
                'memory_usage': load_metrics.memory_usage,
                'request_count': load_metrics.request_count,
                'response_time': load_metrics.response_time,
                'error_rate': load_metrics.error_rate,
                'throughput': load_metrics.throughput,
                'active_connections': load_metrics.active_connections,
                'queue_size': load_metrics.queue_size,
                'request_percentage': (load_metrics.request_count / total_requests * 100) if total_requests > 0 else 0
            }
        
        return distribution
    
    def get_balancer_stats(self) -> Dict[str, Any]:
        """Get load balancer statistics"""
        if self.request_history:
            recent_requests = list(self.request_history)[-1000:]
            successful_requests = sum(1 for req in recent_requests 
                                    if req.get('success', True))
            failed_requests = len(recent_requests) - successful_requests
            
            avg_response_time = sum(req.get('response_time', 0) 
                                  for req in recent_requests) / len(recent_requests)
        else:
            successful_requests = 0
            failed_requests = 0
            avg_response_time = 0.0
        
        return {
            'total_requests': self.stats['total_requests'],
            'successful_requests': successful_requests,
            'failed_requests': failed_requests,
            'average_response_time': avg_response_time,
            'current_strategy': self.current_strategy,
            'active_nodes': len(self.node_loads),
            'load_distribution': self.get_load_distribution()
        }
    
    def set_strategy(self, strategy: str):
        """Set the load balancing strategy"""
        if strategy in self.strategies:
            self.current_strategy = strategy
            logger.info(f"Load balancing strategy changed to: {strategy}")
        else:
            logger.warning(f"Unknown strategy: {strategy}")


class HorizontalScaler:
    """Horizontal scaling manager for distributed processing"""
    
    def __init__(self, mesh: NoodleMesh, load_balancer: LoadBalancer, 
                 identity_manager: NoodleIdentityManager, config: NoodleNetConfig):
        self.mesh = mesh
        self.load_balancer = load_balancer
        self.identity_manager = identity_manager
        self.config = config
        
        # Scaling configuration
        self.scaling_thresholds = {
            ScalingMetric.CPU_USAGE: config.get('cpu_threshold', 80.0),
            ScalingMetric.MEMORY_USAGE: config.get('memory_threshold', 85.0),
            ScalingMetric.REQUEST_COUNT: config.get('request_threshold', 1000),
            ScalingMetric.RESPONSE_TIME: config.get('response_time_threshold', 1000.0),
            ScalingMetric.ERROR_RATE: config.get('error_rate_threshold', 0.05)
        }
        
        self.scaling_decisions: Dict[str, ScalingDecision] = {}
        self.decision_queue = []
        
        # Auto-scaling configuration
        self.auto_scaling_enabled = config.get('auto_scaling_enabled', True)
        self.min_nodes = config.get('min_nodes', 2)
        self.max_nodes = config.get('max_nodes', 10)
        self.scale_up_cooldown = config.get('scale_up_cooldown', 300)  # 5 minutes
        self.scale_down_cooldown = config.get('scale_down_cooldown', 600)  # 10 minutes
        
        # Scaling history
        self.scaling_history = deque(maxlen=1000)
        self.metrics_history = deque(maxlen=10000)
        
        # Thread pool for scaling operations
        self.executor = ThreadPoolExecutor(max_workers=5)
        
        # Running state
        self._running = False
        self._scaling_task = None
        
        logger.info("HorizontalScaler initialized")
    
    async def start(self):
        """Start the horizontal scaler"""
        if self._running:
            return
        
        self._running = True
        self._scaling_task = asyncio.create_task(self._scaling_loop())
        
        logger.info("HorizontalScaler started")
    
    async def stop(self):
        """Stop the horizontal scaler"""
        if not self._running:
            return
        
        self._running = False
        
        if self._scaling_task:
            self._scaling_task.cancel()
            try:
                await self._scaling_task
            except asyncio.CancelledError:
                pass
        
        self.executor.shutdown(wait=True)
        
        logger.info("HorizontalScaler stopped")
    
    async def _scaling_loop(self):
        """Main scaling loop"""
        while self._running:
            try:
                if self.auto_scaling_enabled:
                    # Evaluate scaling needs
                    decisions = await self._evaluate_scaling_needs()
                    
                    # Execute scaling decisions
                    await self._execute_scaling_decisions(decisions)
                
                # Wait for next iteration
                await asyncio.sleep(30.0)  # Check every 30 seconds
                
            except Exception as e:
                logger.error(f"Error in scaling loop: {e}")
                await asyncio.sleep(10.0)
    
    async def _evaluate_scaling_needs(self) -> List[ScalingDecision]:
        """Evaluate if scaling is needed"""
        decisions = []
        
        # Get current metrics
        current_metrics = await self._collect_current_metrics()
        
        # Check if we need to scale up
        if self._should_scale_up(current_metrics):
            decision = ScalingDecision(
                decision_id=f"scale_up_{int(time.time())}",
                action=ScalingAction.SCALE_UP,
                target_nodes=[],
                reason="High resource utilization detected",
                priority=0.9,
                expected_impact=0.3,
                confidence=0.8,
                cost=10.0,
                metadata={
                    'current_metrics': current_metrics,
                    'thresholds': self.scaling_thresholds
                }
            )
            decisions.append(decision)
        
        # Check if we need to scale down
        elif self._should_scale_down(current_metrics):
            decision = ScalingDecision(
                decision_id=f"scale_down_{int(time.time())}",
                action=ScalingAction.SCALE_DOWN,
                target_nodes=[],
                reason="Low resource utilization detected",
                priority=0.7,
                expected_impact=0.2,
                confidence=0.7,
                cost=5.0,
                metadata={
                    'current_metrics': current_metrics,
                    'thresholds': self.scaling_thresholds
                }
            )
            decisions.append(decision)
        
        # Check if we need to redistribute load
        if self._should_redistribute_load(current_metrics):
            decision = ScalingDecision(
                decision_id=f"redistribute_{int(time.time())}",
                action=ScalingAction.REDISTRIBUTE_LOAD,
                target_nodes=[],
                reason="Uneven load distribution detected",
                priority=0.6,
                expected_impact=0.15,
                confidence=0.9,
                cost=2.0,
                metadata={
                    'current_metrics': current_metrics,
                    'load_distribution': self.load_balancer.get_load_distribution()
                }
            )
            decisions.append(decision)
        
        return decisions
    
    async def _collect_current_metrics(self) -> Dict[str, Any]:
        """Collect current system metrics"""
        metrics = {
            'timestamp': time.time(),
            'node_count': self.mesh.get_node_count(),
            'active_nodes': len(self.load_balancer.node_loads),
            'average_cpu': 0.0,
            'average_memory': 0.0,
            'total_requests': 0,
            'average_response_time': 0.0,
            'average_error_rate': 0.0
        }
        
        if self.load_balancer.node_loads:
            cpu_values = []
            memory_values = []
            request_values = []
            response_times = []
            error_rates = []
            
            for load_metrics in self.load_balancer.node_loads.values():
                cpu_values.append(load_metrics.cpu_usage)
                memory_values.append(load_metrics.memory_usage)
                request_values.append(load_metrics.request_count)
                response_times.append(load_metrics.response_time)
                error_rates.append(load_metrics.error_rate)
            
            metrics['average_cpu'] = sum(cpu_values) / len(cpu_values)
            metrics['average_memory'] = sum(memory_values) / len(memory_values)
            metrics['total_requests'] = sum(request_values)
            metrics['average_response_time'] = sum(response_times) / len(response_times)
            metrics['average_error_rate'] = sum(error_rates) / len(error_rates)
        
        # Store metrics history
        self.metrics_history.append(metrics)
        
        return metrics
    
    def _should_scale_up(self, metrics: Dict[str, Any]) -> bool:
        """Check if we should scale up"""
        if metrics['node_count'] >= self.max_nodes:
            return False
        
        # Check various thresholds
        cpu_threshold = self.scaling_thresholds[ScalingMetric.CPU_USAGE]
        memory_threshold = self.scaling_thresholds[ScalingMetric.MEMORY_USAGE]
        request_threshold = self.scaling_thresholds[ScalingMetric.REQUEST_COUNT]
        response_time_threshold = self.scaling_thresholds[ScalingMetric.RESPONSE_TIME]
        error_rate_threshold = self.scaling_thresholds[ScalingMetric.ERROR_RATE]
        
        # Check if any threshold is exceeded
        scale_up_needed = (
            metrics['average_cpu'] > cpu_threshold or
            metrics['average_memory'] > memory_threshold or
            metrics['total_requests'] > request_threshold or
            metrics['average_response_time'] > response_time_threshold or
            metrics['average_error_rate'] > error_rate_threshold
        )
        
        return scale_up_needed
    
    def _should_scale_down(self, metrics: Dict[str, Any]) -> bool:
        """Check if we should scale down"""
        if metrics['node_count'] <= self.min_nodes:
            return False
        
        # Check if all metrics are well below thresholds
        cpu_threshold = self.scaling_thresholds[ScalingMetric.CPU_USAGE] * 0.6
        memory_threshold = self.scaling_thresholds[ScalingMetric.MEMORY_USAGE] * 0.6
        request_threshold = self.scaling_thresholds[ScalingMetric.REQUEST_COUNT] * 0.3
        
        scale_down_possible = (
            metrics['average_cpu'] < cpu_threshold and
            metrics['average_memory'] < memory_threshold and
            metrics['total_requests'] < request_threshold
        )
        
        return scale_down_possible
    
    def _should_redistribute_load(self, metrics: Dict[str, Any]) -> bool:
        """Check if we should redistribute load"""
        if not self.load_balancer.node_loads:
            return False
        
        # Check for uneven distribution
        load_distribution = self.load_balancer.get_load_distribution()
        cpu_values = [metrics['cpu_usage'] for metrics in load_distribution.values()]
        
        if len(cpu_values) < 2:
            return False
        
        # Check if standard deviation is high (uneven distribution)
        avg_cpu = sum(cpu_values) / len(cpu_values)
        variance = sum((x - avg_cpu) ** 2 for x in cpu_values) / len(cpu_values)
        std_dev = variance ** 0.5
        
        # Consider redistribution if standard deviation is high
        return std_dev > 20.0  # 20% standard deviation threshold
    
    async def _execute_scaling_decisions(self, decisions: List[ScalingDecision]):
        """Execute scaling decisions"""
        for decision in decisions:
            await self._execute_scaling_decision(decision)
    
    async def _execute_scaling_decision(self, decision: ScalingDecision):
        """Execute a single scaling decision"""
        decision.status = "executing"
        decision.executed_at = time.time()
        self.scaling_decisions[decision.decision_id] = decision
        
        try:
            if decision.action == ScalingAction.SCALE_UP:
                await self._execute_scale_up(decision)
            elif decision.action == ScalingAction.SCALE_DOWN:
                await self._execute_scale_down(decision)
            elif decision.action == ScalingAction.REDISTRIBUTE_LOAD:
                await self._execute_redistribute_load(decision)
            
            decision.status = "completed"
            decision.completed_at = time.time()
            
            logger.info(f"Scaling decision {decision.decision_id} completed successfully")
            
        except Exception as e:
            decision.status = "failed"
            decision.completed_at = time.time()
            logger.error(f"Scaling decision {decision.decision_id} failed: {e}")
    
    async def _execute_scale_up(self, decision: ScalingDecision):
        """Execute scale up action"""
        # In a real implementation, this would:
        # 1. Provision new nodes (VMs, containers, etc.)
        # 2. Join them to the mesh
        # 3. Update load balancer weights
        
        logger.info("Executing scale up action")
        
        # Simulate adding a new node
        new_node_id = f"node_{int(time.time())}"
        
        # Update load balancer
        self.load_balancer.set_node_weight(new_node_id, 1)
        
        # Record scaling action
        self.scaling_history.append({
            'timestamp': time.time(),
            'action': 'scale_up',
            'node_id': new_node_id,
            'decision_id': decision.decision_id
        })
    
    async def _execute_scale_down(self, decision: ScalingDecision):
        """Execute scale down action"""
        # In a real implementation, this would:
        # 1. Identify underutilized nodes
        # 2. Migrate workloads away from them
        # 3. Remove them from the mesh
        
        logger.info("Executing scale down action")
        
        # Find underutilized nodes
        underutilized_nodes = []
        for node_id, load_metrics in self.load_balancer.node_loads.items():
            if (load_metrics.cpu_usage < 30.0 and 
                load_metrics.memory_usage < 40.0 and
                load_metrics.active_connections < 5):
                underutilized_nodes.append(node_id)
        
        if underutilized_nodes:
            # Remove the most underutilized node
            node_to_remove = min(underutilized_nodes, 
                               key=lambda n: self.load_balancer.node_loads[n].cpu_usage)
            
            # Update load balancer
            if node_to_remove in self.load_balancer.weights:
                del self.load_balancer.weights[node_to_remove]
            
            # Record scaling action
            self.scaling_history.append({
                'timestamp': time.time(),
                'action': 'scale_down',
                'node_id': node_to_remove,
                'decision_id': decision.decision_id
            })
    
    async def _execute_redistribute_load(self, decision: ScalingDecision):
        """Execute load redistribution action"""
        logger.info("Executing load redistribution action")
        
        # Update load balancer strategy to better distribute load
        if self.load_balancer.current_strategy != 'resource_based':
            self.load_balancer.set_strategy('resource_based')
        
        # Record scaling action
        self.scaling_history.append({
            'timestamp': time.time(),
            'action': 'redistribute_load',
            'decision_id': decision.decision_id
        })
    
    def get_scaling_summary(self) -> Dict[str, Any]:
        """Get scaling summary"""
        total_decisions = len(self.scaling_decisions)
        completed_decisions = len([d for d in self.scaling_decisions.values() if d.status == "completed"])
        failed_decisions = len([d for d in self.scaling_decisions.values() if d.status == "failed"])
        
        # Calculate average impact
        completed = [d for d in self.scaling_decisions.values() if d.status == "completed"]
        avg_impact = 0.0
        if completed:
            avg_impact = sum(d.expected_impact for d in completed) / len(completed)
        
        return {
            'total_decisions': total_decisions,
            'completed_decisions': completed_decisions,
            'failed_decisions': failed_decisions,
            'average_impact': avg_impact,
            'auto_scaling_enabled': self.auto_scaling_enabled,
            'min_nodes': self.min_nodes,
            'max_nodes': self.max_nodes,
            'current_nodes': self.mesh.get_node_count(),
            'scaling_history': list(self.scaling_history)[-10:],  # Last 10 entries
            'load_balancer_stats': self.load_balancer.get_balancer_stats()
        }
    
    def get_decision_statistics(self) -> Dict[str, Any]:
        """Get decision statistics"""
        decisions_by_action = defaultdict(int)
        decisions_by_status = defaultdict(int)
        
        for decision in self.scaling_decisions.values():
            decisions_by_action[decision.action.value] += 1
            decisions_by_status[decision.status] += 1
        
        return {
            'total_decisions': len(self.scaling_decisions),
            'decisions_by_action': dict(decisions_by_action),
            'decisions_by_status': dict(decisions_by_status)
        }
    
    def is_scaling_active(self) -> bool:
        """Check if scaling is active"""
        return self._running

