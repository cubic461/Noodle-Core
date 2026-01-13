# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Task Distributor Module for NoodleCore
# Implements distributed task distribution and management
# """

import logging
import time
import threading
import typing
import typing.Any,
import dataclasses.dataclass,
import enum
import json
import math
import statistics
import uuid
import queue
import collections.deque

logger = logging.getLogger(__name__)


class TaskPriority(enum.Enum)
    #     """Priority of tasks"""
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4


class TaskStatus(enum.Enum)
    #     """Status of tasks"""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"


# @dataclass
class Task
    #     """A distributed task"""
    #     task_id: str
    #     task_type: str
    #     priority: TaskPriority
    data: Dict[str, Any] = field(default_factory=dict)
    required_capabilities: List[str] = field(default_factory=list)
    estimated_duration: float = field(default=0.0)
    created_at: float = field(default_factory=time.time)
    assigned_at: Optional[float] = None
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    node_id: Optional[str] = None
    result: Optional['TaskResult'] = None


# @dataclass
class TaskResult
    #     """Result of a task execution"""
    #     task_id: str
    #     node_id: str
    #     success: bool
    result: Any = None
    execution_time: float = field(default=0.0)
    error: Optional[str] = None
    completed_at: float = field(default_factory=time.time)


# @dataclass
class NodeInfo
    #     """Information about a node in the distributed system"""
    #     node_id: str
    is_active: bool = True
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    active_tasks: int = 0
    max_tasks: int = 10
    capabilities: List[str] = field(default_factory=list)
    last_heartbeat: float = 0.0
    load_score: float = 0.0

    #     def get_load_score(self) -> float:
    #         """Calculate load score for the node"""
    #         # Simple calculation based on active tasks and CPU/memory
    #         task_factor = self.active_tasks / max(self.max_tasks, 1) if self.max_tasks > 0 else 0
    cpu_factor = math.subtract(min(self.cpu_usage / 100.0, 1.0)  # Normalize to 0, 1)
    memory_factor = math.subtract(min(self.memory_usage / 100.0, 1.0)  # Normalize to 0, 1)

    #         # Calculate weighted load score
    load_score = math.add((task_factor * 0.5), (cpu_factor * 0.3) + (memory_factor * 0.2))

    #         return load_score


class TaskDistributor
    #     """Task distributor for distributed execution"""

    #     def __init__(self, max_nodes: int = 10, max_tasks_per_node: int = 10):
    #         """Initialize task distributor

    #         Args:
    #             max_nodes: Maximum number of nodes
    #             max_tasks_per_node: Maximum tasks per node
    #         """
    self.max_nodes = max_nodes
    self.max_tasks_per_node = max_tasks_per_node

    #         # Node management
    self.nodes: Dict[str, NodeInfo] = {}
            self.task_queue: queue.Queue()

    #         # Task management
    self.tasks: Dict[str, Task] = {}
    self.task_results: Dict[str, List[TaskResult]] = {}

    #         # Threading
    self._distribution_thread = None
    self._monitoring_thread = None
    self._running = False
    self._lock = threading.RLock()

    #         # Statistics
    self.statistics = {
    #             'total_tasks': 0,
    #             'completed_tasks': 0,
    #             'failed_tasks': 0,
    #             'active_tasks': 0,
    #             'nodes_count': 0,
    #             'active_nodes_count': 0,
    #             'average_task_duration': 0.0,
    #             'task_completion_rate': 0.0
    #         }

    #         logger.info(f"Task distributor initialized with max {max_nodes} nodes")

    #     def add_node(self, node_id: str, capabilities: List[str] = None) -> bool:
    #         """Add a node to the distributed system

    #         Args:
    #             node_id: Unique ID for the node
    #             capabilities: List of capabilities supported by the node

    #         Returns:
    #             True if node was added, False if node already exists
    #         """
    #         with self._lock:
    #             if node_id in self.nodes:
    #                 return False

    #             # Create new node
    node = NodeInfo(
    node_id = node_id,
    capabilities = capabilities or []
    #             )

    self.nodes[node_id] = node

    #             # Update statistics
    self.statistics['nodes_count'] = len(self.nodes)

    #             logger.info(f"Added node {node_id} with {len(capabilities or [])} capabilities")

    #             return True

    #     def remove_node(self, node_id: str) -> bool:
    #         """Remove a node from the distributed system

    #         Args:
    #             node_id: ID of the node to remove

    #         Returns:
    #             True if node was removed, False if node doesn't exist
    #         """
    #         with self._lock:
    #             if node_id not in self.nodes:
    #                 return False

    #             # Cancel any active tasks on this node
    #             for task_id, task in self.tasks.items():
    #                 if task.node_id == node_id and task.assigned_at:
    #                     if task.started_at and not task.completed_at:
    #                         # Mark as failed
    task.status = TaskStatus.FAILED
    task.completed_at = time.time()

    #                         # Create result
    result = TaskResult(
    task_id = task_id,
    node_id = node_id,
    success = False,
    error = "Node removed during task execution",
    completed_at = task.completed_at
    #                         )

    #                         # Add to results
    #                         if node_id not in self.task_results:
    self.task_results[node_id] = []
                            self.task_results[node_id].append(result)

    #             # Remove node
    #             del self.nodes[node_id]

    #             # Update statistics
    self.statistics['nodes_count'] = len(self.nodes)

                logger.info(f"Removed node {node_id}")

    #             return True

    #     def submit_task(self, task_type: str, priority: TaskPriority = TaskPriority.NORMAL,
    data: Dict[str, Any] = math.subtract(None, required_capabilities: List[str] = None), > str:)
    #         """Submit a task for distributed execution

    #         Args:
    #             task_type: Type of task
    #             priority: Priority of the task
    #             data: Additional data for the task
    #             required_capabilities: List of required capabilities
    #             estimated_duration: Estimated duration in seconds

    #         Returns:
    #             Task ID if submitted successfully, None otherwise
    #         """
    #         with self._lock:
    #             # Generate task ID
    task_id = str(uuid.uuid4())

    #             # Create task
    task = Task(
    task_id = task_id,
    task_type = task_type,
    priority = priority,
    data = data or {},
    required_capabilities = required_capabilities or [],
    estimated_duration = estimated_duration,
    created_at = time.time()
    #             )

    #             # Add to tasks
    self.tasks[task_id] = task

    #             # Add to queue
                self.task_queue.put(task)

    #             # Update statistics
    self.statistics['total_tasks'] + = 1

                logger.info(f"Submitted task {task_id} of type {task_type}")

    #             return task_id

    #     def get_task_status(self, task_id: str) -> Optional[Task]:
    #         """Get status of a task"""
    #         with self._lock:
                return self.tasks.get(task_id)

    #     def get_task_result(self, task_id: str) -> Optional[TaskResult]:
    #         """Get result of a task"""
    #         with self._lock:
    results = self.task_results.get(task_id, [])
    #             return results[-1] if results else None

    #     def get_node_info(self, node_id: str) -> Optional[NodeInfo]:
    #         """Get information about a node"""
    #         with self._lock:
                return self.nodes.get(node_id)

    #     def get_available_nodes(self, required_capabilities: Optional[List[str]] = None) -> List[NodeInfo]:
    #         """Get list of available nodes"""
    #         with self._lock:
    available_nodes = []

    #             for node_id, node in self.nodes.items():
    #                 # Check if node is active
    #                 if not node.is_active:
    #                     continue

    #                 # Check if node has required capabilities
    #                 if required_capabilities:
    #                     if not all(cap in node.capabilities for cap in required_capabilities):
    #                         continue

                    available_nodes.append(node)

    #             return available_nodes

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get distributor statistics"""
    #         with self._lock:
    stats = self.statistics.copy()

    #             # Add active nodes count
    #             stats['active_nodes_count'] = sum(1 for node in self.nodes.values() if node.is_active)

    #             # Add task queue size
    stats['queued_tasks_count'] = self.task_queue.qsize()

    #             return stats

    #     def start(self):
    #         """Start task distribution and monitoring"""
    #         with self._lock:
    #             if self._running:
    #                 return

    self._running = True

    #             # Start distribution thread
    self._distribution_thread = threading.Thread(target=self._distribution_worker)
    self._distribution_thread.daemon = True
                self._distribution_thread.start()

    #             # Start monitoring thread
    self._monitoring_thread = threading.Thread(target=self._monitoring_worker)
    self._monitoring_thread.daemon = True
                self._monitoring_thread.start()

                logger.info("Task distributor started")

    #     def stop(self):
    #         """Stop task distribution and monitoring"""
    #         with self._lock:
    #             if not self._running:
    #                 return

    self._running = False

    #             # Wait for threads to stop
    #             for thread in [self._distribution_thread, self._monitoring_thread]:
    #                 if thread and thread.is_alive():
    thread.join(timeout = 5.0)

                logger.info("Task distributor stopped")

    #     def _distribution_worker(self):
    #         """Background worker for task distribution"""
            logger.info("Task distribution worker started")

    #         while self._running:
    #             try:
    #                 # Get available tasks
    #                 if not self.task_queue.empty():
    task = self.task_queue.get(timeout=1.0)

    #                     if task:
                            self._assign_task_to_node(task)

    #                 # Sleep briefly if no tasks
    #                 else:
                        time.sleep(0.1)

    #             except Exception as e:
                    logger.error(f"Error in distribution worker: {e}")
                    time.sleep(1.0)

    #     def _monitoring_worker(self):
    #         """Background worker for monitoring tasks and nodes"""
            logger.info("Task monitoring worker started")

    #         while self._running:
    #             try:
    #                 # Update node heartbeats
                    self._update_node_heartbeats()

    #                 # Check task timeouts
                    self._check_task_timeouts()

    #                 # Update node statistics
                    self._update_node_statistics()

    #                 # Sleep briefly
                    time.sleep(5.0)

    #             except Exception as e:
                    logger.error(f"Error in monitoring worker: {e}")
                    time.sleep(5.0)

    #     def _assign_task_to_node(self, task: Task) -> bool:
    #         """Assign a task to the best available node"""
    #         # Find nodes with required capabilities
    available_nodes = []
    #         for node_id, node in self.nodes.items():
    #             if node.is_active and all(cap in node.capabilities for cap in task.required_capabilities):
                    available_nodes.append(node)

    #         if not available_nodes:
    #             logger.warning(f"No available nodes for task {task.task_id}")
    #             return False

    #         # Select best node based on load score
    best_node = min(available_nodes, key=lambda n: n.get_load_score())

    #         # Assign task to node
    task.node_id = best_node.node_id
    task.assigned_at = time.time()
    best_node.active_tasks + = 1

            logger.info(f"Assigned task {task.task_id} to node {best_node.node_id}")

    #         return True

    #     def _update_node_heartbeats(self):
    #         """Update node heartbeats"""
    current_time = time.time()

    #         for node_id, node in self.nodes.items():
    #             # Simple heartbeat update
    #             if node.is_active:
    node.last_heartbeat = current_time
    #                 # Decrease activity slightly if no tasks
    #                 if node.active_tasks == 0:
    node.cpu_usage = math.multiply(max(node.cpu_usage, 0.9, 5.0)  # Decay CPU usage)
    node.memory_usage = math.multiply(max(node.memory_usage, 0.9, 5.0)  # Decay memory usage)

    #     def _check_task_timeouts(self):
    #         """Check for task timeouts"""
    current_time = time.time()
    timeout_threshold = 300.0  # 5 minutes

    #         for task_id, task in self.tasks.items():
    #             if task.started_at and not task.completed_at:
    #                 # Check if task has been running too long
    #                 if current_time - task.started_at > timeout_threshold:
                        logger.warning(f"Task {task_id} timeout detected")

    #                     # Mark as failed
    task.status = TaskStatus.FAILED
    task.completed_at = current_time

    #                     # Create result
    result = TaskResult(
    task_id = task_id,
    node_id = task.node_id,
    success = False,
    error = "Task timeout",
    completed_at = task.completed_at
    #                     )

    #                     # Add to results
    #                     if task.node_id not in self.task_results:
    self.task_results[task.node_id] = []
                        self.task_results[task.node_id].append(result)

    #     def _update_node_statistics(self):
    #         """Update node statistics"""
    #         for node_id, node in self.nodes.items():
    #             if node.is_active:
    #                 # Calculate task completion rate
    completed_tasks = 0
    #                 for task_id, task in self.tasks.items():
    #                     if task.node_id == node_id and task.completed_at:
    completed_tasks + = 1

    #                 # Update node statistics
    #                 if completed_tasks > 0:
    node.active_tasks = completed_tasks
    #                     # Calculate completion rate
    completion_rate = math.multiply(completed_tasks / max(1, len(self.tasks)), 100.0)
    #                 else:
    completion_rate = 0.0

    #                 # Update average task duration
    total_duration = 0.0
    task_count = 0
    #                 for task_id, task in self.tasks.items():
    #                     if task.node_id == node_id and task.completed_at and task.started_at:
    total_duration + = math.subtract(task.completed_at, task.started_at)
    task_count + = 1

    #                 if task_count > 0:
    node.average_task_duration = math.divide(total_duration, task_count)
    #                 else:
    node.average_task_duration = 0.0