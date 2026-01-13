"""
Noodlenet::Scheduler - scheduler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Resource-aware task distribution scheduler for NoodleNet.

This module implements a declarative scheduler that distributes tasks
across the distributed network based on resource availability,
node capabilities, and cost optimization.
"""

import asyncio
import time
import heapq
import logging
import uuid
from typing import Dict, List, Optional, Set, Tuple, Any, Callable
from dataclasses import dataclass, field
from collections import defaultdict, deque
from enum import Enum
from .config import NoodleNetConfig
from .identity import NodeIdentity
from .routing import MessageRouter, RouteInfo
from .link import Message

logger = logging.getLogger(__name__)


class TaskPriority(Enum):
    """Task priority levels"""
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4
    URGENT = 5


class TaskStatus(Enum):
    """Task execution status"""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    TIMEOUT = "timeout"


@dataclass
class ResourceRequirement:
    """Resource requirements for a task"""
    
    cpu_cores: int = 1
    memory_mb: int = 512
    gpu_required: bool = False
    gpu_memory_mb: int = 0
    storage_gb: int = 1
    network_bandwidth_mbps: float = 10.0
    custom_resources: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'cpu_cores': self.cpu_cores,
            'memory_mb': self.memory_mb,
            'gpu_required': self.gpu_required,
            'gpu_memory_mb': self.gpu_memory_mb,
            'storage_gb': self.storage_gb,
            'network_bandwidth_mbps': self.network_bandwidth_mbps,
            'custom_resources': self.custom_resources
        }


@dataclass
class Task:
    """Task definition for distributed execution"""
    
    task_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    task_type: str
    priority: TaskPriority = TaskPriority.NORMAL
    requirements: ResourceRequirement = field(default_factory=ResourceRequirement)
    
    # Task data
    payload: Any = None
    dependencies: List[str] = field(default_factory=list)
    timeout: float = 300.0  # 5 minutes default
    
    # Scheduling information
    created_at: float = field(default_factory=time.time)
    scheduled_at: Optional[float] = None
    assigned_node: Optional[str] = None
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    
    # Execution information
    status: TaskStatus = TaskStatus.PENDING
    result: Optional[Any] = None
    error: Optional[str] = None
    retry_count: int = 0
    max_retries: int = 3
    
    # Cost information
    estimated_cost: float = 0.0
    actual_cost: float = 0.0
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert task to dictionary"""
        return {
            'task_id': self.task_id,
            'task_type': self.task_type,
            'priority': self.priority.value,
            'requirements': self.requirements.to_dict(),
            'payload': self.payload,
            'dependencies': self.dependencies,
            'timeout': self.timeout,
            'created_at': self.created_at,
            'scheduled_at': self.scheduled_at,
            'assigned_node': self.assigned_node,
            'started_at': self.started_at,
            'completed_at': self.completed_at,
            'status': self.status.value,
            'result': self.result,
            'error': self.error,
            'retry_count': self.retry_count,
            'max_retries': self.max_retries,
            'estimated_cost': self.estimated_cost,
            'actual_cost': self.actual_cost
        }


@dataclass
class NodeResources:
    """Available resources on a node"""
    
    node_id: str
    cpu_cores: int = 1
    cpu_usage: float = 0.0  # 0.0-1.0
    memory_mb: int = 1024
    memory_usage: float = 0.0  # 0.0-1.0
    gpu_available: bool = False
    gpu_memory_mb: int = 0
    gpu_usage: float = 0.0  # 0.0-1.0
    storage_gb: int = 100
    storage_usage: float = 0.0  # 0.0-1.0
    network_bandwidth_mbps: float = 100.0
    network_usage: float = 0.0  # 0.0-1.0
    custom_resources: Dict[str, Any] = field(default_factory=dict)
    
    # Capabilities
    capabilities: Set[str] = field(default_factory=set)
    
    # Performance metrics
    task_completion_rate: float = 1.0  # 0.0-1.0
    avg_task_duration: float = 0.0
    last_updated: float = field(default_factory=time.time)
    
    def can_fulfill_requirement(self, requirement: ResourceRequirement) -> bool:
        """Check if node can fulfill a resource requirement"""
        if requirement.cpu_cores > self.cpu_cores:
            return False
        
        if requirement.memory_mb > (self.memory_mb * (1.0 - self.memory_usage)):
            return False
        
        if requirement.gpu_required and not self.gpu_available:
            return False
        
        if requirement.gpu_memory_mb > (self.gpu_memory_mb * (1.0 - self.gpu_usage)):
            return False
        
        if requirement.storage_gb > (self.storage_gb * (1.0 - self.storage_usage)):
            return False
        
        if requirement.network_bandwidth_mbps > (self.network_bandwidth_mbps * (1.0 - self.network_usage)):
            return False
        
        # Check custom resources
        for resource, required_amount in requirement.custom_resources.items():
            if resource not in self.custom_resources:
                return False
            available_amount = self.custom_resources[resource]
            if required_amount > available_amount:
                return False
        
        return True
    
    def get_resource_score(self, requirement: ResourceRequirement) -> float:
        """Calculate how well a node matches resource requirements"""
        score = 1.0
        
        # CPU scoring
        cpu_ratio = self.cpu_cores / requirement.cpu_cores
        score *= min(cpu_ratio, 2.0)  # Cap at 2x
        
        # Memory scoring
        memory_ratio = (self.memory_mb * (1.0 - self.memory_usage)) / requirement.memory_mb
        score *= min(memory_ratio, 2.0)  # Cap at 2x
        
        # GPU scoring
        if requirement.gpu_required:
            if self.gpu_available:
                gpu_ratio = (self.gpu_memory_mb * (1.0 - self.gpu_usage)) / max(requirement.gpu_memory_mb, 1)
                score *= min(gpu_ratio, 2.0)  # Cap at 2x
            else:
                score *= 0.1  # Heavy penalty for no GPU
        
        # Performance scoring
        score *= self.task_completion_rate
        score *= (2.0 - self.avg_task_duration)  # Lower duration is better
        
        return score
    
    def update_usage(self, requirement: ResourceRequirement, duration: float):
        """Update resource usage after task completion"""
        # Simple linear usage model
        cpu_usage = min(requirement.cpu_cores / self.cpu_cores, 1.0)
        memory_usage = min(requirement.memory_mb / self.memory_mb, 1.0)
        
        if requirement.gpu_required:
            gpu_usage = min(requirement.gpu_memory_mb / max(self.gpu_memory_mb, 1), 1.0)
        else:
            gpu_usage = 0.0
        
        network_usage = min(requirement.network_bandwidth_mbps / self.network_bandwidth_mbps, 1.0)
        storage_usage = min(requirement.storage_gb / self.storage_gb, 1.0)
        
        # Update usage (exponential moving average)
        alpha = 0.1
        self.cpu_usage = alpha * cpu_usage + (1 - alpha) * self.cpu_usage
        self.memory_usage = alpha * memory_usage + (1 - alpha) * self.memory_usage
        self.gpu_usage = alpha * gpu_usage + (1 - alpha) * self.gpu_usage
        self.network_usage = alpha * network_usage + (1 - alpha) * self.network_usage
        self.storage_usage = alpha * storage_usage + (1 - alpha) * self.storage_usage
        
        # Update performance metrics
        self.last_updated = time.time()
    
    def update_performance(self, task_duration: float, success: bool):
        """Update performance metrics"""
        alpha = 0.1
        self.task_completion_rate = alpha * (1.0 if success else 0.0) + (1 - alpha) * self.task_completion_rate
        self.avg_task_duration = alpha * task_duration + (1 - alpha) * self.avg_task_duration
        self.last_updated = time.time()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert node resources to dictionary"""
        return {
            'node_id': self.node_id,
            'cpu_cores': self.cpu_cores,
            'cpu_usage': self.cpu_usage,
            'memory_mb': self.memory_mb,
            'memory_usage': self.memory_usage,
            'gpu_available': self.gpu_available,
            'gpu_memory_mb': self.gpu_memory_mb,
            'gpu_usage': self.gpu_usage,
            'storage_gb': self.storage_gb,
            'storage_usage': self.storage_usage,
            'network_bandwidth_mbps': self.network_bandwidth_mbps,
            'network_usage': self.network_usage,
            'custom_resources': self.custom_resources,
            'capabilities': list(self.capabilities),
            'task_completion_rate': self.task_completion_rate,
            'avg_task_duration': self.avg_task_duration,
            'last_updated': self.last_updated
        }


class CostModel:
    """Cost model for task scheduling decisions"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize cost model
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        
        # Cost factors
        self.cpu_cost_per_core_hour = 0.1  # $0.10 per core per hour
        self.memory_cost_per_gb_hour = 0.05  # $0.05 per GB per hour
        self.gpu_cost_per_hour = 0.5  # $0.50 per GPU hour
        self.network_cost_per_gb = 0.01  # $0.01 per GB transferred
        self.storage_cost_per_gb_hour = 0.001  # $0.001 per GB per hour
        
        # Time-based costs
        self.latency_penalty_per_ms = 0.001  # $0.001 per ms latency
        self.energy_cost_per_watt_hour = 0.0001  # $0.0001 per watt-hour
        
        # Performance bonuses
        self.performance_bonus_factor = 0.2  # 20% bonus for good performance
        self.reliability_penalty_factor = 0.3  # 30% penalty for poor reliability
    
    def calculate_task_cost(self, task: Task, node_resources: NodeResources, 
                        estimated_duration: float, network_distance: float) -> float:
        """
        Calculate the cost of executing a task on a node
        
        Args:
            task: Task to execute
            node_resources: Available resources on node
            estimated_duration: Estimated execution duration in seconds
            network_distance: Network distance to target node
            
        Returns:
            Total cost value
        """
        # Resource costs
        cpu_cost = (task.requirements.cpu_cores * estimated_duration / 3600) * self.cpu_cost_per_core_hour
        memory_cost = (task.requirements.memory_mb / 1024 * estimated_duration / 3600) * self.memory_cost_per_gb_hour
        
        if task.requirements.gpu_required:
            gpu_cost = (estimated_duration / 3600) * self.gpu_cost_per_hour
        else:
            gpu_cost = 0.0
        
        network_cost = (task.requirements.network_bandwidth_mbps * estimated_duration / 3600 / 1024) * self.network_cost_per_gb
        
        # Time-based costs
        latency_cost = network_distance * self.latency_penalty_per_ms
        energy_cost = estimated_duration * self.energy_cost_per_watt_hour * 100  # Assume 100W average
        
        # Base cost
        total_cost = cpu_cost + memory_cost + gpu_cost + network_cost + latency_cost + energy_cost
        
        # Performance adjustments
        performance_score = node_resources.task_completion_rate
        if performance_score > 0.8:
            total_cost *= (1.0 - self.performance_bonus_factor)  # 20% discount
        elif performance_score < 0.5:
            total_cost *= (1.0 + self.reliability_penalty_factor)  # 30% penalty
        
        return total_cost
    
    def calculate_network_distance_cost(self, distance: float) -> float:
        """Calculate network distance cost"""
        # Simple model: cost increases with distance
        return distance * 0.01  # $0.01 per hop


class ResourceAwareScheduler:
    """Resource-aware task scheduler for NoodleNet"""
    
    def __init__(self, local_node_id: str, message_router: MessageRouter,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialize the scheduler
        
        Args:
            local_node_id: ID of the local node
            message_router: Message router for communication
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.message_router = message_router
        self.config = config or NoodleNetConfig()
        
        # Scheduling state
        self.pending_tasks: Dict[str, Task] = {}  # task_id -> Task
        self.running_tasks: Dict[str, Task] = {}  # task_id -> Task
        self.completed_tasks: Dict[str, Task] = {}  # task_id -> Task
        self.node_resources: Dict[str, NodeResources] = {}  # node_id -> NodeResources
        
        # Scheduling queues
        self.task_queues: Dict[TaskPriority, deque] = {
            priority: deque() for priority in TaskPriority
        }
        
        # Cost model
        self.cost_model = CostModel(config)
        
        # Scheduling algorithms
        self.scheduling_algorithm = "cost_optimized"  # fifo, priority, cost_optimized, load_balanced
        
        # Statistics
        self._stats = {
            'tasks_submitted': 0,
            'tasks_completed': 0,
            'tasks_failed': 0,
            'tasks_cancelled': 0,
            'avg_wait_time': 0.0,
            'avg_execution_time': 0.0,
            'total_cost': 0.0,
            'node_utilization': 0.0,
            'scheduling_decisions': 0
        }
        
        # Event handlers
        self._task_completed_handler: Optional[Callable] = None
        self._task_failed_handler: Optional[Callable] = None
        self._node_resources_updated_handler: Optional[Callable] = None
        
        # Background tasks
        self._scheduling_task: Optional[asyncio.Task] = None
        self._resource_monitoring_task: Optional[asyncio.Task] = None
        self._cleanup_task: Optional[asyncio.Task] = None
        
        self._running = False
    
    async def start(self):
        """Start the scheduler"""
        if self._running:
            logger.warning("Scheduler is already running")
            return
        
        self._running = True
        
        # Start background tasks
        self._scheduling_task = asyncio.create_task(self._scheduling_loop())
        self._resource_monitoring_task = asyncio.create_task(self._resource_monitoring_loop())
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        logger.info("Resource-aware scheduler started")
    
    async def stop(self):
        """Stop the scheduler"""
        if not self._running:
            return
        
        self._running = False
        
        # Cancel background tasks
        for task in [self._scheduling_task, self._resource_monitoring_task, self._cleanup_task]:
            if task and not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        logger.info("Resource-aware scheduler stopped")
    
    def submit_task(self, task_type: str, payload: Any = None,
                  requirements: Optional[ResourceRequirement] = None,
                  priority: TaskPriority = TaskPriority.NORMAL,
                  dependencies: List[str] = None,
                  timeout: Optional[float] = None,
                  task_id: Optional[str] = None) -> str:
        """
        Submit a task for scheduling
        
        Args:
            task_type: Type of task
            payload: Task payload
            requirements: Resource requirements
            priority: Task priority
            dependencies: List of task IDs this task depends on
            timeout: Task timeout in seconds
            task_id: Optional custom task ID
            
        Returns:
            Task ID
        """
        # Create task
        task = Task(
            task_type=task_type,
            payload=payload,
            requirements=requirements or ResourceRequirement(),
            priority=priority,
            dependencies=dependencies or [],
            timeout=timeout or self.config.default_task_timeout,
            task_id=task_id or str(uuid.uuid4())
        )
        
        # Add to pending tasks
        self.pending_tasks[task.task_id] = task
        
        # Add to appropriate priority queue
        self.task_queues[task.priority].append(task)
        
        # Update statistics
        self._stats['tasks_submitted'] += 1
        
        logger.info(f"Task submitted: {task.task_id} (type: {task_type}, priority: {task.priority.name})")
        
        return task.task_id
    
    def cancel_task(self, task_id: str) -> bool:
        """
        Cancel a pending task
        
        Args:
            task_id: ID of task to cancel
            
        Returns:
            True if successfully cancelled
        """
        if task_id in self.running_tasks:
            # Cannot cancel running tasks
            return False
        
        if task_id in self.pending_tasks:
            task = self.pending_tasks[task_id]
            task.status = TaskStatus.CANCELLED
            task.completed_at = time.time()
            
            # Move to completed tasks
            self.completed_tasks[task_id] = task
            del self.pending_tasks[task_id]
            
            # Update statistics
            self._stats['tasks_cancelled'] += 1
            
            # Call handler
            if self._task_failed_handler:
                asyncio.create_task(self._task_failed_handler(task))
            
            logger.info(f"Task cancelled: {task_id}")
            return True
        
        return False
    
    def get_task_status(self, task_id: str) -> Optional[Dict[str, Any]]:
        """
        Get the status of a task
        
        Args:
            task_id: ID of task
            
        Returns:
            Task status dictionary or None if not found
        """
        if task_id in self.pending_tasks:
            return self.pending_tasks[task_id].to_dict()
        elif task_id in self.running_tasks:
            return self.running_tasks[task_id].to_dict()
        elif task_id in self.completed_tasks:
            return self.completed_tasks[task_id].to_dict()
        else:
            return None
    
    def update_node_resources(self, node_id: str, resources: NodeResources):
        """
        Update resource information for a node
        
        Args:
            node_id: ID of the node
            resources: Updated node resources
        """
        self.node_resources[node_id] = resources
        
        # Update statistics
        self._stats['node_utilization'] = self._calculate_node_utilization()
        
        # Call handler
        if self._node_resources_updated_handler:
            asyncio.create_task(self._node_resources_updated_handler(node_id, resources))
        
        logger.debug(f"Updated resources for node {node_id}")
    
    def set_task_completed_handler(self, handler: Callable):
        """Set handler for task completion events"""
        self._task_completed_handler = handler
    
    def set_task_failed_handler(self, handler: Callable):
        """Set handler for task failure events"""
        self._task_failed_handler = handler
    
    def set_node_resources_updated_handler(self, handler: Callable):
        """Set handler for node resource update events"""
        self._node_resources_updated_handler = handler
    
    def get_scheduler_statistics(self) -> Dict[str, Any]:
        """Get comprehensive scheduler statistics"""
        stats = self._stats.copy()
        
        # Add queue statistics
        stats['queue_sizes'] = {
            priority.name: len(queue) for priority, queue in self.task_queues.items()
        }
        
        # Add node statistics
        stats['node_count'] = len(self.node_resources)
        stats['node_utilization'] = self._calculate_node_utilization()
        
        # Add task statistics
        stats['pending_tasks'] = len(self.pending_tasks)
        stats['running_tasks'] = len(self.running_tasks)
        stats['completed_tasks'] = len(self.completed_tasks)
        
        return stats
    
    def _calculate_node_utilization(self) -> float:
        """Calculate average node utilization"""
        if not self.node_resources:
            return 0.0
        
        total_utilization = 0.0
        node_count = len(self.node_resources)
        
        for resources in self.node_resources.values():
            utilization = (
                resources.cpu_usage +
                resources.memory_usage +
                resources.gpu_usage +
                resources.network_usage +
                resources.storage_usage
            ) / 5.0  # Average of 5 resource types
            total_utilization += utilization
        
        return total_utilization / max(node_count, 1)
    
    async def _scheduling_loop(self):
        """Main scheduling loop"""
        while self._running:
            try:
                # Check for tasks that can be scheduled
                await self._schedule_pending_tasks()
                
                # Check for running tasks that have timed out
                await self._check_timeouts()
                
                # Clean up completed tasks
                await self._cleanup_completed_tasks()
                
                # Wait before next iteration
                await asyncio.sleep(self.config.scheduling_interval)
                
            except Exception as e:
                logger.error(f"Error in scheduling loop: {e}")
                await asyncio.sleep(5)
    
    async def _schedule_pending_tasks(self):
        """Schedule pending tasks based on available resources"""
        # Get available nodes
        available_nodes = [
            node_id for node_id, resources in self.node_resources.items()
            if self._is_node_available(resources)
        ]
        
        if not available_nodes:
            return
        
        # Schedule tasks by priority
        for priority in [TaskPriority.URGENT, TaskPriority.CRITICAL, TaskPriority.HIGH, TaskPriority.NORMAL, TaskPriority.LOW]:
            queue = self.task_queues[priority]
            
            while queue and available_nodes:
                task = queue[0]
                
                # Check dependencies
                if not self._check_dependencies(task):
                    queue.popleft()
                    continue
                
                # Find best node for this task
                best_node = await self._find_best_node(task, available_nodes)
                
                if best_node:
                    # Assign task to node
                    await self._assign_task_to_node(task, best_node)
                    available_nodes.remove(best_node)
                    
                    # Remove from queue
                    queue.popleft()
                else:
                    # No suitable node found
                    break
    
    def _is_node_available(self, resources: NodeResources) -> bool:
        """Check if a node is available for new tasks"""
        # Check if node is not overloaded
        total_load = (
            resources.cpu_usage +
            resources.memory_usage +
            resources.gpu_usage +
            resources.network_usage +
            resources.storage_usage
        )
        
        # Node is available if load < 80%
        return total_load < 4.0  # 80% of 5 resource types
    
    def _check_dependencies(self, task: Task) -> bool:
        """Check if all task dependencies are completed"""
        for dep_id in task.dependencies:
            if dep_id in self.completed_tasks:
                if self.completed_tasks[dep_id].status != TaskStatus.COMPLETED:
                    return False
            elif dep_id in self.pending_tasks:
                if self.pending_tasks[dep_id].status != TaskStatus.COMPLETED:
                    return False
            else:
                # Dependency not found
                return False
        
        return True
    
    async def _find_best_node(self, task: Task, available_nodes: List[str]) -> Optional[str]:
        """Find the best node for a task"""
        if not available_nodes:
            return None
        
        best_node = None
        best_score = -1.0
        
        for node_id in available_nodes:
            resources = self.node_resources.get(node_id)
            if not resources:
                continue
            
            # Check if node can fulfill requirements
            if not resources.can_fulfill_requirement(task.requirements):
                continue
            
            # Calculate score
            score = resources.get_resource_score(task.requirements)
            
            # Apply cost optimization
            if self.scheduling_algorithm == "cost_optimized":
                # Estimate network distance (simplified)
                network_distance = 1.0  # Would be calculated from routing table
                
                # Calculate cost
                cost = self.cost_model.calculate_task_cost(
                    task, resources, task.estimated_duration, network_distance
                )
                
                # Lower cost is better
                score *= (1.0 / (1.0 + cost))
            
            if score > best_score:
                best_score = score
                best_node = node_id
        
        return best_node
    
    async def _assign_task_to_node(self, task: Task, node_id: str):
        """Assign a task to a node"""
        # Update task
        task.assigned_node = node_id
        task.scheduled_at = time.time()
        task.status = TaskStatus.RUNNING
        task.started_at = time.time()
        
        # Move to running tasks
        self.running_tasks[task.task_id] = task
        del self.pending_tasks[task.task_id]
        
        # Update statistics
        self._stats['scheduling_decisions'] += 1
        
        # Send task to node
        task_message = Message(
            sender_id=self.local_node_id,
            recipient_id=node_id,
            message_type="task_assignment",
            payload=task.to_dict()
        )
        
        # Send via message router
        route = await self.message_router.find_route(node_id, task_message)
        if route:
            await self.message_router.send_message(node_id, task_message)
        
        logger.info(f"Task {task.task_id} assigned to node {node_id}")
    
    async def _check_timeouts(self):
        """Check for timed out tasks"""
        current_time = time.time()
        
        for task_id, task in list(self.running_tasks.items()):
            if task.started_at and (current_time - task.started_at) > task.timeout:
                # Task has timed out
                task.status = TaskStatus.TIMEOUT
                task.error = "Task timeout"
                task.completed_at = current_time
                
                # Move to completed tasks
                self.completed_tasks[task_id] = task
                del self.running_tasks[task_id]
                
                # Update statistics
                self._stats['tasks_failed'] += 1
                
                # Call handler
                if self._task_failed_handler:
                    await self._task_failed_handler(task)
                
                logger.warning(f"Task {task_id} timed out")
    
    async def _cleanup_completed_tasks(self):
        """Clean up completed tasks older than cleanup threshold"""
        current_time = time.time()
        cleanup_age = self.config.task_cleanup_age
        
        tasks_to_remove = []
        
        for task_id, task in list(self.completed_tasks.items()):
            if task.completed_at and (current_time - task.completed_at) > cleanup_age:
                tasks_to_remove.append(task_id)
        
        for task_id in tasks_to_remove:
            del self.completed_tasks[task_id]
        
        if tasks_to_remove:
            logger.debug(f"Cleaned up {len(tasks_to_remove)} old completed tasks")
    
    async def _resource_monitoring_loop(self):
        """Monitor node resource usage"""
        while self._running:
            try:
                # Request resource updates from all nodes
                await self._request_resource_updates()
                
                # Wait before next iteration
                await asyncio.sleep(self.config.resource_monitoring_interval)
                
            except Exception as e:
                logger.error(f"Error in resource monitoring loop: {e}")
                await asyncio.sleep(10)
    
    async def _request_resource_updates(self):
        """Request resource updates from all nodes"""
        # This would typically send a message to all nodes requesting their current resource usage
        # For now, we'll simulate resource updates
        
        for node_id, resources in self.node_resources.items():
            # Simulate some resource usage changes
            if resources.cpu_usage > 0.8:
                # Simulate resource usage reduction
                resources.cpu_usage *= 0.95
                resources.memory_usage *= 0.95
                resources.last_updated = time.time()
                
                # Update node resources
                self.node_resources[node_id] = resources
    
    async def _cleanup_loop(self):
        """Periodic cleanup"""
        while self._running:
            try:
                # Clean up stale node resources
                current_time = time.time()
                stale_nodes = [
                    node_id for node_id, resources in self.node_resources.items()
                    if current_time - resources.last_updated > self.config.resource_timeout
                ]
                
                for node_id in stale_nodes:
                    del self.node_resources[node_id]
                
                if stale_nodes:
                    logger.debug(f"Cleaned up {len(stale_nodes)} stale node resources")
                
                # Wait before next iteration
                await asyncio.sleep(self.config.cleanup_interval)
                
            except Exception as e:
                logger.error(f"Error in cleanup loop: {e}")
                await asyncio.sleep(30)

