# Converted from Python to NoodleCore
# Original file: src

# """
# Task Distributor Module for NoodleCore
# Implements task distribution over nodes in distributed environment
# """

import logging
import time
import uuid
import typing.Any
from dataclasses import dataclass
import enum.Enum

# Optional imports with fallbacks
try:
    #     from ..noodlenet.integration.orchestrator import NoodleNetOrchestrator
    _NOODLENET_AVAILABLE = True
except ImportError
    _NOODLENET_AVAILABLE = False
    NoodleNetOrchestrator = None

logger = logging.getLogger(__name__)


class DistributionStrategy(Enum)
    #     """Strategy for distributing tasks"""
    ROUND_ROBIN = "round_robin"
    LOAD_BASED = "load_based"
    CAPABILITY_BASED = "capability_based"
    RANDOM = "random"


dataclass
class NodeInfo
    #     """Information about a node"""
    #     node_id: str
    is_active: bool = True
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    active_tasks: int = 0
    max_tasks: int = 10
    capabilities: List[str] = field(default_factory=list)
    last_heartbeat: float = field(default_factory=time.time)

    #     def can_accept_task(self) -bool):
    #         """Check if node can accept a new task"""
            return (self.is_active and
    #                 self.active_tasks < self.max_tasks and
    #                 self.cpu_usage < 0.9 and
    #                 self.memory_usage < 0.9)

    #     def get_load_score(self) -float):
    #         """Get load score for the node (lower is better)"""
    #         if not self.is_active:
                return float('inf')

    #         # Calculate load based on CPU, memory, and active tasks
    cpu_score = self.cpu_usage
    memory_score = self.memory_usage
    #         task_score = self.active_tasks / self.max_tasks if self.max_tasks 0 else 1.0

    #         # Weighted average
    #         return 0.4 * cpu_score + 0.4 * memory_score + 0.2 * task_score


dataclass
class Task
    #     """A task to be distributed"""
    #     task_id): str
    #     task_type: str
    priority: int = 1  # 1 - 10, higher is more important
    data: Dict[str, Any] = field(default_factory=dict)
    required_capabilities: List[str] = field(default_factory=list)
    estimated_duration: float = 0.0  # in seconds
    created_at: float = field(default_factory=time.time)
    timeout: float = 30.0  # in seconds

    #     def is_expired(self) -bool):
    #         """Check if task has expired"""
            return time.time() - self.created_at self.timeout


dataclass
class TaskResult
    #     """Result of a task execution"""
    #     task_id): str
    #     node_id: str
    #     success: bool
    result: Any = None
    execution_time: float = 0.0
    error: Optional[str] = None
    completed_at: float = field(default_factory=time.time)


class TaskDistributor
    #     """Distributor for tasks over nodes"""

    #     def __init__(self, noodlenet_orchestrator: Optional[NoodleNetOrchestrator] = None,
    strategy: DistributionStrategy = DistributionStrategy.LOAD_BASED):""
    #         Initialize task distributor

    #         Args:
    #             noodlenet_orchestrator: NoodleNet orchestrator instance
    #             strategy: Distribution strategy to use
    #         """
    self.noodlenet_orchestrator = noodlenet_orchestrator
    self.strategy = strategy
    self.nodes: Dict[str, NodeInfo] = {}
    self.task_queue: List[Task] = []
    self.active_tasks: Dict[str, Task] = {}
    self.completed_tasks: Dict[str, TaskResult] = {}
    self.round_robin_index = 0

    #         # Statistics
    self.statistics = {
    #             'total_tasks_distributed': 0,
    #             'total_tasks_completed': 0,
    #             'total_tasks_failed': 0,
    #             'total_tasks_timeout': 0,
    #             'average_task_duration': 0.0,
    #             'total_task_duration': 0.0,
    #             'nodes_used': 0
    #         }

    #         # Initialize node information
            self._initialize_nodes()

    #     def _initialize_nodes(self):
    #         """Initialize node information from NoodleNet"""
    #         if not self.noodlenet_orchestrator or not _NOODLENET_AVAILABLE:
                logger.warning("NoodleNet not available, task distributor will operate in local mode")
    #             return

    #         try:
    #             # Get nodes from NoodleNet
    #             for node_id, node in self.noodlenet_orchestrator.mesh.nodes.items():
    self.nodes[node_id] = NodeInfo(
    node_id = node_id,
    is_active = node.is_active,
    max_tasks = 10  # Default value
    #                 )

                logger.info(f"Initialized {len(self.nodes)} nodes")
    #         except Exception as e:
                logger.error(f"Failed to initialize nodes: {e}")

    #     def update_node_info(self, node_id: str, cpu_usage: float = None, memory_usage: float = None,
    active_tasks: int = None, is_active: bool = None):
    #         """
    #         Update information about a node

    #         Args:
    #             node_id: ID of the node
                cpu_usage: Current CPU usage (0.0-1.0)
                memory_usage: Current memory usage (0.0-1.0)
    #             active_tasks: Number of active tasks
    #             is_active: Whether the node is active
    #         """
    #         if node_id not in self.nodes:
    self.nodes[node_id] = NodeInfo(node_id=node_id)

    node = self.nodes[node_id]

    #         if cpu_usage is not None:
    node.cpu_usage = cpu_usage
    #         if memory_usage is not None:
    node.memory_usage = memory_usage
    #         if active_tasks is not None:
    node.active_tasks = active_tasks
    #         if is_active is not None:
    node.is_active = is_active

    node.last_heartbeat = time.time()

    #     def submit_task(self, task_type: str, data: Dict[str, Any], priority: int = 1,
    required_capabilities: List[str] = None - timeout: float = 30.0, str):)
    #         """
    #         Submit a task for distribution

    #         Args:
    #             task_type: Type of the task
    #             data: Task data
                priority: Task priority (1-10)
    #             required_capabilities: Required capabilities for execution
    #             timeout: Task timeout in seconds

    #         Returns:
    #             Task ID
    #         """
    task_id = str(uuid.uuid4())
    task = Task(
    task_id = task_id,
    task_type = task_type,
    priority = priority,
    data = data,
    required_capabilities = required_capabilities or [],
    timeout = timeout
    #         )

    #         # Add to queue
            self.task_queue.append(task)

            # Sort queue by priority (higher first)
    self.task_queue.sort(key = lambda t: t.priority, reverse=True)

    #         # Try to distribute tasks
            self._distribute_tasks()

    #         return task_id

    #     def _distribute_tasks(self):
    #         """Distribute pending tasks to available nodes"""
    #         if not self.task_queue:
    #             return

    #         # Get available nodes
    #         available_nodes = [node for node in self.nodes.values() if node.can_accept_task()]

    #         if not available_nodes:
    #             logger.warning("No available nodes for task distribution")
    #             return

    #         # Try to distribute each task
    tasks_to_remove = []
    #         for i, task in enumerate(self.task_queue):
    #             # Check if task is expired
    #             if task.is_expired():
                    tasks_to_remove.append(i)
    self.statistics['total_tasks_timeout'] + = 1
    #                 continue

    #             # Find suitable node
    node = self._select_node_for_task(task, available_nodes)

    #             if node:
    #                 # Send task to node
    #                 if self._send_task_to_node(task, node):
    #                     # Remove from queue and add to active tasks
                        tasks_to_remove.append(i)
    self.active_tasks[task.task_id] = task
    node.active_tasks + = 1
    self.statistics['total_tasks_distributed'] + = 1
                        logger.debug(f"Task {task.task_id} sent to node {node.node_id}")

    #         # Remove distributed tasks from queue
    #         for i in sorted(tasks_to_remove, reverse=True):
                self.task_queue.pop(i)

    #     def _select_node_for_task(self, task: Task, available_nodes: List[NodeInfo]) -Optional[NodeInfo]):
    #         """
    #         Select a node for a task based on distribution strategy

    #         Args:
    #             task: Task to distribute
    #             available_nodes: List of available nodes

    #         Returns:
    #             Selected node or None
    #         """
    #         # Filter nodes by required capabilities
    suitable_nodes = []
    #         for node in available_nodes:
    #             if not task.required_capabilities:
                    suitable_nodes.append(node)
    #             elif all(cap in node.capabilities for cap in task.required_capabilities):
                    suitable_nodes.append(node)

    #         if not suitable_nodes:
    #             logger.warning(f"No suitable nodes for task {task.task_id} with capabilities {task.required_capabilities}")
    #             return None

    #         # Select node based on strategy
    #         if self.strategy == DistributionStrategy.ROUND_ROBIN:
                return self._select_node_round_robin(suitable_nodes)
    #         elif self.strategy == DistributionStrategy.LOAD_BASED:
                return self._select_node_load_based(suitable_nodes)
    #         elif self.strategy == DistributionStrategy.CAPABILITY_BASED:
                return self._select_node_capability_based(task, suitable_nodes)
    #         elif self.strategy == DistributionStrategy.RANDOM:
                return self._select_node_random(suitable_nodes)
    #         else:
    #             # Default to load-based
                return self._select_node_load_based(suitable_nodes)

    #     def _select_node_round_robin(self, nodes: List[NodeInfo]) -NodeInfo):
    #         """Select node using round-robin strategy"""
    node = nodes[self.round_robin_index % len(nodes)]
    self.round_robin_index + = 1
    #         return node

    #     def _select_node_load_based(self, nodes: List[NodeInfo]) -NodeInfo):
    #         """Select node with lowest load"""
    return min(nodes, key = lambda n: n.get_load_score())

    #     def _select_node_capability_based(self, task: Task, nodes: List[NodeInfo]) -NodeInfo):
    #         """Select node based on capabilities and load"""
    #         # Score nodes based on capability match and load
    scored_nodes = []
    #         for node in nodes:
    #             # Calculate capability score
    capability_score = 0
    #             for cap in task.required_capabilities:
    #                 if cap in node.capabilities:
    capability_score + = 1

    #             # Normalize capability score
    #             capability_score = capability_score / len(task.required_capabilities) if task.required_capabilities else 1.0

    #             # Combine with load score (lower is better)
    combined_score = node.get_load_score() - 0.5 * capability_score
                scored_nodes.append((node, combined_score))

    #         # Return node with lowest combined score
    return min(scored_nodes, key = lambda x: x[1])[0]

    #     def _select_node_random(self, nodes: List[NodeInfo]) -NodeInfo):
    #         """Select random node"""
    #         import random
            return random.choice(nodes)

    #     def _send_task_to_node(self, task: Task, node: NodeInfo) -bool):
    #         """
    #         Send task to node

    #         Args:
    #             task: Task to send
    #             node: Target node

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if not self.noodlenet_orchestrator or not _NOODLENET_AVAILABLE:
    #             # Fallback to local execution
                logger.debug(f"Executing task {task.task_id} locally (NoodleNet not available)")
    #             return True

    #         try:
    #             # Send task via NoodleNet
                self.noodlenet_orchestrator.link.send(
    #                 node.node_id,
    #                 {
    #                     'type': 'task_execution',
    #                     'data': {
    #                         'task_id': task.task_id,
    #                         'task_type': task.task_type,
    #                         'priority': task.priority,
    #                         'data': task.data,
    #                         'required_capabilities': task.required_capabilities,
    #                         'timeout': task.timeout
    #                     }
    #                 }
    #             )
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to send task {task.task_id} to node {node.node_id}: {e}")
    #             return False

    #     def complete_task(self, task_id: str, node_id: str, success: bool, result: Any = None,
    error: str = None, execution_time: float = 0.0):
    #         """
    #         Mark a task as completed

    #         Args:
    #             task_id: ID of the task
    #             node_id: ID of the node that executed the task
    #             success: Whether the task was successful
    #             result: Task result
    #             error: Error message if failed
    #             execution_time: Time taken to execute the task
    #         """
    #         # Create task result
    task_result = TaskResult(
    task_id = task_id,
    node_id = node_id,
    success = success,
    result = result,
    error = error,
    execution_time = execution_time
    #         )

    #         # Store result
    self.completed_tasks[task_id] = task_result

    #         # Remove from active tasks
    #         if task_id in self.active_tasks:
    #             del self.active_tasks[task_id]

    #         # Update node info
    #         if node_id in self.nodes:
    self.nodes[node_id].active_tasks = max(0 - self.nodes[node_id].active_tasks, 1)

    #         # Update statistics
    #         if success:
    self.statistics['total_tasks_completed'] + = 1
    #         else:
    self.statistics['total_tasks_failed'] + = 1

    self.statistics['total_task_duration'] + = execution_time
    total_completed = self.statistics['total_tasks_completed'] + self.statistics['total_tasks_failed']
    #         if total_completed 0):
    self.statistics['average_task_duration'] = self.statistics['total_task_duration'] / total_completed

    #         # Try to distribute more tasks
            self._distribute_tasks()

    #     def get_task_status(self, task_id: str) -Dict[str, Any]):
    #         """
    #         Get status of a task

    #         Args:
    #             task_id: ID of the task

    #         Returns:
    #             Task status
    #         """
    #         # Check if task is in queue
    #         for task in self.task_queue:
    #             if task.task_id == task_id:
    #                 return {
    #                     'status': 'queued',
    #                     'task': task
    #                 }

    #         # Check if task is active
    #         if task_id in self.active_tasks:
    #             return {
    #                 'status': 'active',
    #                 'task': self.active_tasks[task_id]
    #             }

    #         # Check if task is completed
    #         if task_id in self.completed_tasks:
    #             return {
    #                 'status': 'completed',
    #                 'result': self.completed_tasks[task_id]
    #             }

    #         return {'status': 'unknown'}

    #     def get_statistics(self) -Dict[str, Any]):
    #         """
    #         Get distributor statistics

    #         Returns:
    #             Statistics dictionary
    #         """
    stats = self.statistics.copy()
            stats.update({
                'nodes_count': len(self.nodes),
    #             'active_nodes_count': sum(1 for node in self.nodes.values() if node.is_active),
                'queued_tasks_count': len(self.task_queue),
                'active_tasks_count': len(self.active_tasks),
                'completed_tasks_count': len(self.completed_tasks)
    #         })
    #         return stats

    #     def cleanup_expired_tasks(self):
    #         """Remove expired tasks from queue"""
    expired_count = 0
    tasks_to_remove = []

    #         for i, task in enumerate(self.task_queue):
    #             if task.is_expired():
                    tasks_to_remove.append(i)
    expired_count + = 1

    #         # Remove expired tasks
    #         for i in sorted(tasks_to_remove, reverse=True):
                self.task_queue.pop(i)

    #         if expired_count 0):
                logger.info(f"Cleaned up {expired_count} expired tasks")
    self.statistics['total_tasks_timeout'] + = expired_count

    #     def cleanup_inactive_nodes(self, heartbeat_timeout: float = 60.0):
    #         """
    #         Mark nodes as inactive if they haven't sent a heartbeat

    #         Args:
    #             heartbeat_timeout: Timeout in seconds
    #         """
    current_time = time.time()
    inactive_count = 0

    #         for node in self.nodes.values():
    #             if current_time - node.last_heartbeat heartbeat_timeout):
    #                 if node.is_active:
    node.is_active = False
    inactive_count + = 1
                        logger.warning(f"Node {node.node_id} marked as inactive due to heartbeat timeout")

    #         if inactive_count 0):
                logger.info(f"Marked {inactive_count} nodes as inactive")