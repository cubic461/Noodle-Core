# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Task Index for Noodle
# ---------------------
# This module implements the task index for Noodle, providing efficient management
# of active tasks, threads, cores, and GPU kernels through a task table and scheduler.
# """

import heapq
import queue
import threading
import time
import uuid
import concurrent.futures.Future
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import ..compiler.parser.ASTNode,
import ..compiler.semantic_analyzer.Symbol


class TaskStatus(Enum)
    #     """Status of a task in the system"""

    PENDING = "pending"
    READY = "ready"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    PAUSED = "paused"


class TaskPriority(Enum)
    #     """Priority levels for tasks"""

    LOW = 0
    NORMAL = 1
    HIGH = 2
    CRITICAL = 3


class TaskType(Enum)
    #     """Types of tasks that can be executed"""

    CPU_COMPUTE = "cpu_compute"
    GPU_COMPUTE = "gpu_compute"
    NPU_COMPUTE = "npu_compute"
    TPU_COMPUTE = "tpu_compute"
    IO_OPERATION = "io_operation"
    NETWORK_OPERATION = "network_operation"
    MEMORY_OPERATION = "memory_operation"
    SYNCHRONIZATION = "synchronization"
    COMPILATION = "compilation"
    METAPROGRAMMING = "metaprogramming"


class ResourceType(Enum)
    #     """Types of hardware resources"""

    CPU_CORE = "cpu_core"
    GPU = "gpu"
    NPU = "npu"
    TPU = "tpu"
    MEMORY = "memory"
    NETWORK = "network"
    DISK = "disk"


# @dataclass
class ResourceRequirement
    #     """Resource requirements for a task"""

    #     resource_type: ResourceType
    #     amount: int
    min_version: Optional[str] = None
    max_version: Optional[str] = None
    constraints: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class TaskDependency
    #     """Represents a dependency between tasks"""

    #     task_id: str
    #     dependency_type: str  # "data", "control", "resource"
    resource_requirements: Optional[List[ResourceRequirement]] = None
    estimated_duration: Optional[float] = None


# @dataclass
class TaskResult
    #     """Result of a task execution"""

    #     success: bool
    value: Any = None
    error: Optional[str] = None
    execution_time: float = 0.0
    memory_used: int = 0
    cpu_time: float = 0.0
    gpu_time: float = 0.0
    output_data: Optional[Any] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class Task
    #     """Represents a task in the system"""

    #     id: str
    #     name: str
    #     task_type: TaskType
    #     priority: TaskPriority
    #     status: TaskStatus
    #     created_at: float
    #     updated_at: float
    estimated_duration: Optional[float] = None
    actual_duration: Optional[float] = None
    dependencies: List[TaskDependency] = field(default_factory=list)
    resource_requirements: List[ResourceRequirement] = field(default_factory=list)
    assigned_resources: Dict[str, Any] = field(default_factory=dict)
    execution_node: Optional[str] = None
    thread_id: Optional[int] = None
    code_object: Optional[bytes] = None
    input_data: Optional[Dict[str, Any]] = None
    output_data: Optional[Dict[str, Any]] = None
    result: Optional[TaskResult] = None
    progress: float = 0.0
    error_message: Optional[str] = None
    retry_count: int = 0
    max_retries: int = 3
    timeout: Optional[float] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    tags: Set[str] = field(default_factory=set)
    affinity_score: float = 0.0


# @dataclass
class Resource
    #     """Represents a hardware resource"""

    #     id: str
    #     type: ResourceType
    #     name: str
    #     total_units: int
    #     available_units: int
    allocated_units: int = 0
    version: str = "1.0"
    capabilities: Dict[str, Any] = field(default_factory=dict)
    location: str = "local"
    status: str = "available"
    last_updated: float = field(default_factory=time.time)
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class SchedulingPolicy
    #     """Policy for task scheduling"""

    #     name: str
    priority_weight: float = 1.0
    dependency_weight: float = 1.0
    resource_weight: float = 1.0
    affinity_weight: float = 1.0
    fairness_weight: float = 1.0
    max_concurrent_tasks: int = 4
    resource_allocation_strategy: str = (
    #         "best_fit"  # "best_fit", "first_fit", "worst_fit"
    #     )
    load_balancing: bool = True
    preemption_enabled: bool = True
    priority_inheritance: bool = True


class TaskScheduler
    #     """Scheduler for managing task execution"""

    #     def __init__(self, policy: SchedulingPolicy):
    self.policy = policy
    self.task_queue = []  # Priority queue
    self.running_tasks: Dict[str, Task] = {}
    self.completed_tasks: Dict[str, Task] = {}
    self.failed_tasks: Dict[str, Task] = {}
    self.resources: Dict[str, Resource] = {}
    self.resource_locks: Dict[str, threading.Lock] = {}
    self.task_dependencies: Dict[str, Set[str]] = {}
    self.dependency_graph: Dict[str, Set[str]] = {}
    self.execution_stats: Dict[str, int] = {}
    self.lock = threading.Lock()
    self.shutdown_flag = False
    self.scheduler_thread: Optional[threading.Thread] = None
    self.task_event = threading.Event()

    #     def start(self):
    #         """Start the scheduler"""
    self.scheduler_thread = threading.Thread(target=self._scheduler_loop)
    self.scheduler_thread.daemon = True
            self.scheduler_thread.start()

    #     def stop(self):
    #         """Stop the scheduler"""
    self.shutdown_flag = True
            self.task_event.set()
    #         if self.scheduler_thread:
                self.scheduler_thread.join()

    #     def add_task(self, task: Task) -> bool:
    #         """Add a task to the scheduler"""
    #         with self.lock:
    #             # Calculate priority score
    priority_score = self._calculate_priority_score(task)

    #             # Add to priority queue
                heapq.heappush(self.task_queue, (-priority_score, task.id, task))

    #             # Update dependencies
    self.task_dependencies[task.id] = set()
    #             for dep in task.dependencies:
                    self.task_dependencies[task.id].add(dep.task_id)
    #                 if dep.task_id not in self.dependency_graph:
    self.dependency_graph[dep.task_id] = set()
                    self.dependency_graph[dep.task_id].add(task.id)

    #             # Signal new task
                self.task_event.set()
    #             return True

    #     def cancel_task(self, task_id: str) -> bool:
    #         """Cancel a task"""
    #         with self.lock:
    #             # Check if task is running
    #             if task_id in self.running_tasks:
    task = self.running_tasks[task_id]
    task.status = TaskStatus.CANCELLED
    #                 # In a real implementation, we would interrupt the task
    #                 return True

    #             # Check if task is in queue
    #             for i, (_, tid, _) in enumerate(self.task_queue):
    #                 if tid == task_id:
    task = self.task_queue[i][2]
    task.status = TaskStatus.CANCELLED
                        self.task_queue.pop(i)
                        heapq.heapify(self.task_queue)
    #                     return True

    #             return False

    #     def get_task(self, task_id: str) -> Optional[Task]:
    #         """Get a task by ID"""
    #         with self.lock:
    #             # Check running tasks
    #             if task_id in self.running_tasks:
    #                 return self.running_tasks[task_id]

    #             # Check completed tasks
    #             if task_id in self.completed_tasks:
    #                 return self.completed_tasks[task_id]

    #             # Check failed tasks
    #             if task_id in self.failed_tasks:
    #                 return self.failed_tasks[task_id]

    #             # Check queue
    #             for _, tid, task in self.task_queue:
    #                 if tid == task_id:
    #                     return task

    #             return None

    #     def get_tasks_by_status(self, status: TaskStatus) -> List[Task]:
    #         """Get all tasks with a specific status"""
    #         with self.lock:
    tasks = []

                # Check queue (all tasks in queue are pending or ready)
    #             if status in [TaskStatus.PENDING, TaskStatus.READY]:
    #                 for _, _, task in self.task_queue:
    #                     if task.status == status:
                            tasks.append(task)

    #             # Check running tasks
    #             if status == TaskStatus.RUNNING:
                    tasks.extend(self.running_tasks.values())

    #             # Check completed tasks
    #             if status == TaskStatus.COMPLETED:
                    tasks.extend(self.completed_tasks.values())

    #             # Check failed tasks
    #             if status == TaskStatus.FAILED:
                    tasks.extend(self.failed_tasks.values())

    #             return tasks

    #     def add_resource(self, resource: Resource):
    #         """Add a resource to the scheduler"""
    #         with self.lock:
    self.resources[resource.id] = resource
    #             if resource.id not in self.resource_locks:
    self.resource_locks[resource.id] = threading.Lock()

    #     def remove_resource(self, resource_id: str) -> bool:
    #         """Remove a resource from the scheduler"""
    #         with self.lock:
    #             if resource_id in self.resources:
    #                 # Check if resource is allocated
    resource = self.resources[resource_id]
    #                 if resource.allocated_units > 0:
    #                     return False

    #                 del self.resources[resource_id]
    #                 if resource_id in self.resource_locks:
    #                     del self.resource_locks[resource_id]
    #                 return True

    #             return False

    #     def get_resource(self, resource_id: str) -> Optional[Resource]:
    #         """Get a resource by ID"""
    #         with self.lock:
                return self.resources.get(resource_id)

    #     def get_available_resources(self, resource_type: ResourceType) -> List[Resource]:
    #         """Get all available resources of a specific type"""
    #         with self.lock:
    #             return [
    #                 res
    #                 for res in self.resources.values()
    #                 if res.type == resource_type and res.available_units > 0
    #             ]

    #     def allocate_resources(self, task: Task) -> bool:
    #         """Allocate resources for a task"""
    #         with self.lock:
    #             # Try to allocate resources based on policy
    #             if self.policy.resource_allocation_strategy == "best_fit":
    success = self._best_fit_allocation(task)
    #             elif self.policy.resource_allocation_strategy == "first_fit":
    success = self._first_fit_allocation(task)
    #             elif self.policy.resource_allocation_strategy == "worst_fit":
    success = self._worst_fit_allocation(task)
    #             else:
    success = self._best_fit_allocation(task)

    #             if success:
    task.status = TaskStatus.READY
    #                 return True

    #             return False

    #     def release_resources(self, task: Task):
    #         """Release resources allocated to a task"""
    #         with self.lock:
    #             for resource_id, amount in task.assigned_resources.items():
    #                 if resource_id in self.resources:
    resource = self.resources[resource_id]
    resource.allocated_units - = amount
    resource.available_units + = amount
    resource.last_updated = time.time()

                task.assigned_resources.clear()

    #     def get_scheduler_stats(self) -> Dict[str, Any]:
    #         """Get scheduler statistics"""
    #         with self.lock:
    #             return {
                    "total_tasks": len(self.task_queue)
                    + len(self.running_tasks)
                    + len(self.completed_tasks)
                    + len(self.failed_tasks),
                    "pending_tasks": len(self.task_queue),
                    "running_tasks": len(self.running_tasks),
                    "completed_tasks": len(self.completed_tasks),
                    "failed_tasks": len(self.failed_tasks),
                    "total_resources": len(self.resources),
                    "available_resources": sum(
    #                     res.available_units for res in self.resources.values()
    #                 ),
                    "allocated_resources": sum(
    #                     res.allocated_units for res in self.resources.values()
    #                 ),
    #                 "policy": self.policy.name,
    #                 "resource_allocation_strategy": self.policy.resource_allocation_strategy,
                    "scheduler_uptime": (
    #                     time.time() - self.created_at if hasattr(self, "created_at") else 0
    #                 ),
    #             }

    #     def _scheduler_loop(self):
    #         """Main scheduler loop"""
    self.created_at = time.time()

    #         while not self.shutdown_flag:
    #             try:
    #                 # Wait for new tasks or timeout
    #                 if not self.task_event.wait(timeout=1.0):
    #                     continue

                    self.task_event.clear()

    #                 # Process tasks
                    self._process_tasks()

    #             except Exception as e:
    #                 # Log error
                    print(f"Scheduler error: {e}")
    #                 continue

    #     def _process_tasks(self):
    #         """Process tasks in the queue"""
    #         with self.lock:
    #             # Check if we can run more tasks
    #             if len(self.running_tasks) >= self.policy.max_concurrent_tasks:
    #                 return

    #             # Process ready tasks
    ready_tasks = []
    new_queue = []

    #             while self.task_queue:
    priority, task_id, task = heapq.heappop(self.task_queue)

    #                 # Check if task is ready to run
    #                 if self._is_task_ready(task):
                        ready_tasks.append(task)
    #                 else:
                        new_queue.append((priority, task_id, task))

    #             # Put unready tasks back in queue
    #             for item in new_queue:
                    heapq.heappush(self.task_queue, item)

    #             # Try to run ready tasks
    #             for task in ready_tasks:
    #                 if len(self.running_tasks) >= self.policy.max_concurrent_tasks:
    #                     # Put task back in queue
    priority_score = self._calculate_priority_score(task)
                        heapq.heappush(self.task_queue, (-priority_score, task.id, task))
    #                     break

    #                 # Allocate resources
    #                 if self.allocate_resources(task):
                        self._execute_task(task)

    #     def _is_task_ready(self, task: Task) -> bool:
    #         """Check if a task is ready to run"""
    #         # Check dependencies
    #         for dep in task.dependencies:
    #             if dep.task_id not in self.completed_tasks:
    #                 return False

    #         # Check resource availability
    #         for req in task.resource_requirements:
    available = self.get_available_resources(req.resource_type)
    #             if len(available) < req.amount:
    #                 return False

    #         return True

    #     def _execute_task(self, task: Task):
    #         """Execute a task"""
    task.status = TaskStatus.RUNNING
    task.updated_at = time.time()
    self.running_tasks[task.id] = task

    #         # Start task in a new thread
    execution_thread = threading.Thread(target=self._run_task, args=(task,))
    execution_thread.daemon = True
            execution_thread.start()

    #     def _run_task(self, task: Task):
    #         """Run a task"""
    start_time = time.time()

    #         try:
    #             # Execute task code
    #             # In a real implementation, this would execute the actual task code
    result = self._execute_task_code(task)

    #             # Create result
    task.result = TaskResult(
    success = True,
    value = result,
    execution_time = math.subtract(time.time(), start_time,)
    metadata = {"execution_node": task.execution_node},
    #             )

    #             # Update task status
    #             with self.lock:
    task.status = TaskStatus.COMPLETED
    task.actual_duration = math.subtract(time.time(), start_time)
    self.completed_tasks[task.id] = task
    #                 del self.running_tasks[task.id]

    #                 # Release resources
                    self.release_resources(task)

    #                 # Signal dependent tasks
                    self._signal_dependent_tasks(task.id)

    #         except Exception as e:
    #             # Handle task failure
    #             with self.lock:
    task.status = TaskStatus.FAILED
    task.error_message = str(e)
    task.retry_count + = 1

    #                 # Check if we should retry
    #                 if task.retry_count < task.max_retries:
    #                     # Reset task and put back in queue
    task.status = TaskStatus.PENDING
    task.error_message = None

    priority_score = self._calculate_priority_score(task)
                        heapq.heappush(self.task_queue, (-priority_score, task.id, task))
    #                 else:
    #                     # Mark as failed
    self.failed_tasks[task.id] = task
    #                     del self.running_tasks[task.id]

    #                 # Release resources
                    self.release_resources(task)

    #         finally:
    #             # Update execution stats
    #             with self.lock:
    #                 if task.task_type.value not in self.execution_stats:
    self.execution_stats[task.task_type.value] = 0
    self.execution_stats[task.task_type.value] + = 1

    #     def _execute_task_code(self, task: Task) -> Any:
    #         """Execute the actual task code"""
    #         # This is a placeholder for actual task execution
    #         # In a real implementation, this would execute the NBC bytecode
    #         # or compiled code for the task

    #         # Simulate execution time
    #         if task.estimated_duration:
    #             time.sleep(min(task.estimated_duration, 0.1))  # Cap at 100ms for demo
    #         else:
                time.sleep(0.01)  # Default 10ms

    #         # Return dummy result
    #         return {
    #             "task_id": task.id,
    #             "status": "completed",
    #             "result": f"Result for {task.name}",
    #         }

    #     def _signal_dependent_tasks(self, task_id: str):
    #         """Signal tasks that depend on the completed task"""
    #         if task_id in self.dependency_graph:
    #             for dependent_id in self.dependency_graph[task_id]:
    dependent_task = self.get_task(dependent_id)
    #                 if dependent_task and dependent_task.status == TaskStatus.PENDING:
    #                     # Check if all dependencies are satisfied
    #                     if self._is_task_ready(dependent_task):
    #                         # Move to ready state
    priority_score = self._calculate_priority_score(dependent_task)
                            heapq.heappush(
    #                             self.task_queue,
                                (-priority_score, dependent_id, dependent_task),
    #                         )

    #     def _calculate_priority_score(self, task: Task) -> float:
    #         """Calculate priority score for task scheduling"""
    #         # Base priority from task priority
    base_priority = math.multiply(task.priority.value, 1000)

    #         # Add dependency weight
    dependency_weight = math.multiply(len(task.dependencies), self.policy.dependency_weight * 100)

    #         # Add affinity weight
    affinity_weight = math.multiply(task.affinity_score, self.policy.affinity_weight * 100)

            # Add resource weight (based on resource scarcity)
    resource_weight = 0
    #         for req in task.resource_requirements:
    available = len(self.get_available_resources(req.resource_type))
    total = len(
    #                 [r for r in self.resources.values() if r.type == req.resource_type]
    #             )
    #             if total > 0:
    scarcity = math.subtract(1.0, (available / total))
    resource_weight + = math.multiply(scarcity, self.policy.resource_weight * 100)

    #         # Combine weights
    total_score = (
    #             base_priority
                + (dependency_weight * 0.1)
    #             + affinity_weight
                + (resource_weight * 0.1)
    #         )

    #         return total_score

    #     def _best_fit_allocation(self, task: Task) -> bool:
    #         """Best fit resource allocation strategy"""
    allocation = {}

    #         for req in task.resource_requirements:
    available = self.get_available_resources(req.resource_type)

    #             # Find resources with smallest sufficient allocation
    best_resource = None
    best_waste = float("inf")

    #             for resource in available:
    #                 if resource.available_units >= req.amount:
    waste = math.subtract(resource.available_units, req.amount)
    #                     if waste < best_waste:
    best_waste = waste
    best_resource = resource

    #             if not best_resource:
    #                 return False

    #             # Allocate resource
    allocation[best_resource.id] = req.amount
    best_resource.allocated_units + = req.amount
    best_resource.available_units - = req.amount
    best_resource.last_updated = time.time()

    task.assigned_resources = allocation
    #         return True

    #     def _first_fit_allocation(self, task: Task) -> bool:
    #         """First fit resource allocation strategy"""
    allocation = {}

    #         for req in task.resource_requirements:
    available = self.get_available_resources(req.resource_type)

    #             # Find first sufficient resource
    allocated = False
    #             for resource in available:
    #                 if resource.available_units >= req.amount:
    #                     # Allocate resource
    allocation[resource.id] = req.amount
    resource.allocated_units + = req.amount
    resource.available_units - = req.amount
    resource.last_updated = time.time()
    allocated = True
    #                     break

    #             if not allocated:
    #                 # Rollback previous allocations
    #                 for res_id, amount in allocation.items():
    resource = self.resources[res_id]
    resource.allocated_units - = amount
    resource.available_units + = amount
    #                 return False

    task.assigned_resources = allocation
    #         return True

    #     def _worst_fit_allocation(self, task: Task) -> bool:
    #         """Worst fit resource allocation strategy"""
    allocation = {}

    #         for req in task.resource_requirements:
    available = self.get_available_resources(req.resource_type)

    #             # Find resource with largest available space
    best_resource = None
    best_available = math.subtract(, 1)

    #             for resource in available:
    #                 if (
    resource.available_units > = req.amount
    #                     and resource.available_units > best_available
    #                 ):
    best_available = resource.available_units
    best_resource = resource

    #             if not best_resource:
    #                 return False

    #             # Allocate resource
    allocation[best_resource.id] = req.amount
    best_resource.allocated_units + = req.amount
    best_resource.available_units - = req.amount
    best_resource.last_updated = time.time()

    task.assigned_resources = allocation
    #         return True


class TaskIndex
    #     """
    #     Task Index for Noodle that manages active tasks, threads, cores, and GPU kernels.
    #     Combines a task table with an advanced scheduler for efficient resource management.
    #     """

    #     def __init__(self, scheduling_policy: Optional[SchedulingPolicy] = None):
    self.scheduler = TaskScheduler(scheduling_policy or SchedulingPolicy("default"))
    self.task_table: Dict[str, Task] = {}
    self.resource_table: Dict[str, Resource] = {}
    self.node_table: Dict[str, Dict[str, Any]] = {}
    self.performance_metrics: Dict[str, List[float]] = {}
    self.created_at = time.time()
    self.last_updated = time.time()

    #         # Start the scheduler
            self.scheduler.start()

    #     def create_task(
    #         self,
    #         name: str,
    #         task_type: TaskType,
    priority: TaskPriority = TaskPriority.NORMAL,
    dependencies: Optional[List[TaskDependency]] = None,
    resource_requirements: Optional[List[ResourceRequirement]] = None,
    estimated_duration: Optional[float] = None,
    max_retries: int = 3,
    timeout: Optional[float] = None,
    metadata: Optional[Dict[str, Any]] = None,
    tags: Optional[Set[str]] = None,
    #     ) -> Task:
    #         """
    #         Create a new task

    #         Args:
    #             name: Task name
    #             task_type: Type of task
    #             priority: Task priority
    #             dependencies: List of task dependencies
    #             resource_requirements: List of resource requirements
    #             estimated_duration: Estimated execution time
    #             max_retries: Maximum retry attempts
    #             timeout: Task timeout
    #             metadata: Additional metadata
    #             tags: Task tags

    #         Returns:
    #             Created task
    #         """
    #         # Create task
    task = Task(
    id = str(uuid.uuid4()),
    name = name,
    task_type = task_type,
    priority = priority,
    status = TaskStatus.PENDING,
    created_at = time.time(),
    updated_at = time.time(),
    dependencies = dependencies or [],
    resource_requirements = resource_requirements or [],
    estimated_duration = estimated_duration,
    max_retries = max_retries,
    timeout = timeout,
    metadata = metadata or {},
    tags = tags or set(),
    #         )

    #         # Add to task table
    self.task_table[task.id] = task

    #         # Add to scheduler
            self.scheduler.add_task(task)

    #         # Update metrics
    self.last_updated = time.time()

    #         return task

    #     def get_task(self, task_id: str) -> Optional[Task]:
    #         """Get a task by ID"""
            return self.task_table.get(task_id) or self.scheduler.get_task(task_id)

    #     def get_tasks_by_status(self, status: TaskStatus) -> List[Task]:
    #         """Get all tasks with a specific status"""
            return self.scheduler.get_tasks_by_status(status)

    #     def get_tasks_by_type(self, task_type: TaskType) -> List[Task]:
    #         """Get all tasks of a specific type"""
    #         return [
    #             task for task in self.task_table.values() if task.task_type == task_type
    #         ]

    #     def get_tasks_by_priority(self, priority: TaskPriority) -> List[Task]:
    #         """Get all tasks with a specific priority"""
    #         return [task for task in self.task_table.values() if task.priority == priority]

    #     def cancel_task(self, task_id: str) -> bool:
    #         """Cancel a task"""
    success = self.scheduler.cancel_task(task_id)
    #         if success:
    task = self.task_table.get(task_id)
    #             if task:
    task.status = TaskStatus.CANCELLED
    self.last_updated = time.time()
    #         return success

    #     def add_resource(
    #         self,
    #         resource_type: ResourceType,
    #         name: str,
    #         total_units: int,
    version: str = "1.0",
    capabilities: Optional[Dict[str, Any]] = None,
    location: str = "local",
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Resource:
    #         """
    #         Add a resource to the index

    #         Args:
    #             resource_type: Type of resource
    #             name: Resource name
    #             total_units: Total units available
    #             version: Resource version
    #             capabilities: Resource capabilities
    #             location: Resource location
    #             metadata: Additional metadata

    #         Returns:
    #             Created resource
    #         """
    #         # Create resource
    resource = Resource(
    id = str(uuid.uuid4()),
    type = resource_type,
    name = name,
    total_units = total_units,
    available_units = total_units,
    version = version,
    capabilities = capabilities or {},
    location = location,
    metadata = metadata or {},
    #         )

    #         # Add to tables
    self.resource_table[resource.id] = resource
            self.scheduler.add_resource(resource)

    #         # Update metrics
    self.last_updated = time.time()

    #         return resource

    #     def get_resource(self, resource_id: str) -> Optional[Resource]:
    #         """Get a resource by ID"""
            return self.resource_table.get(resource_id) or self.scheduler.get_resource(
    #             resource_id
    #         )

    #     def get_resources_by_type(self, resource_type: ResourceType) -> List[Resource]:
    #         """Get all resources of a specific type"""
    #         return [
    #             res for res in self.resource_table.values() if res.type == resource_type
    #         ]

    #     def get_available_resources(self, resource_type: ResourceType) -> List[Resource]:
    #         """Get all available resources of a specific type"""
            return self.scheduler.get_available_resources(resource_type)

    #     def add_node(
    #         self,
    #         node_id: str,
    #         node_type: str,
    #         capabilities: Dict[str, Any],
    location: str = "local",
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Dict[str, Any]:
    #         """
    #         Add a compute node to the index

    #         Args:
    #             node_id: Node identifier
    #             node_type: Type of node
    #             capabilities: Node capabilities
    #             location: Node location
    #             metadata: Additional metadata

    #         Returns:
    #             Node information
    #         """
    node_info = {
    #             "id": node_id,
    #             "type": node_type,
    #             "capabilities": capabilities,
    #             "location": location,
    #             "metadata": metadata or {},
                "last_updated": time.time(),
    #             "active_tasks": 0,
    #             "total_tasks": 0,
    #             "success_rate": 0.0,
    #             "average_execution_time": 0.0,
    #         }

    self.node_table[node_id] = node_info
    self.last_updated = time.time()

    #         return node_info

    #     def get_node(self, node_id: str) -> Optional[Dict[str, Any]]:
    #         """Get a node by ID"""
            return self.node_table.get(node_id)

    #     def get_nodes_by_type(self, node_type: str) -> List[Dict[str, Any]]:
    #         """Get all nodes of a specific type"""
    #         return [node for node in self.node_table.values() if node["type"] == node_type]

    #     def get_task_dependencies(self, task_id: str) -> List[TaskDependency]:
    #         """Get dependencies for a task"""
    task = self.get_task(task_id)
    #         return task.dependencies if task else []

    #     def get_dependent_tasks(self, task_id: str) -> List[Task]:
    #         """Get tasks that depend on the given task"""
    dependents = []

    #         for task in self.task_table.values():
    #             for dep in task.dependencies:
    #                 if dep.task_id == task_id:
                        dependents.append(task)

    #         return dependents

    #     def get_execution_path(self, task_id: str) -> List[str]:
    #         """
    #         Get the execution path for a task (all dependencies in order)

    #         Args:
    #             task_id: Task ID

    #         Returns:
    #             List of task IDs in execution order
    #         """
    task = self.get_task(task_id)
    #         if not task:
    #             return []

    path = []
    visited = set()

    #         def visit_task(t_id):
    #             if t_id in visited:
    #                 return

                visited.add(t_id)
    t = self.get_task(t_id)
    #             if not t:
    #                 return

    #             # Visit dependencies first
    #             for dep in t.dependencies:
                    visit_task(dep.task_id)

                path.append(t_id)

            visit_task(task_id)
    #         return path

    #     def optimize_task_placement(self, task_id: str) -> Optional[str]:
    #         """
    #         Optimize task placement based on resource availability and dependencies

    #         Args:
    #             task_id: Task ID to optimize

    #         Returns:
    #             Recommended node ID or None if no optimization needed
    #         """
    task = self.get_task(task_id)
    #         if not task:
    #             return None

    #         # Check if task is already running
    #         if task.status == TaskStatus.RUNNING:
    #             return task.execution_node

    #         # Find best node based on resource requirements
    best_node = None
    best_score = math.subtract(, 1)

    #         for node_id, node_info in self.node_table.items():
    #             # Check if node can handle task type
    #             if "task_types" in node_info["capabilities"]:
    #                 if task.task_type.value not in node_info["capabilities"]["task_types"]:
    #                     continue

    #             # Calculate score based on resource availability
    score = 0.0

    #             # Check resource availability
    #             for req in task.resource_requirements:
    #                 if req.resource_type.value in node_info["capabilities"]:
    available = node_info["capabilities"][req.resource_type.value]
    #                     if available >= req.amount:
    score + = 1.0
    #                     else:
    score - = 1.0

    #             # Check load
    load_factor = node_info["active_tasks"] / max(
                    node_info["capabilities"].get("max_concurrent_tasks", 1), 1
    #             )
    score - = math.multiply(load_factor, 0.5)

    #             # Check location affinity
    #             if task.metadata.get("preferred_location") == node_info["location"]:
    score + = 0.5

    #             # Update best node
    #             if score > best_score:
    best_score = score
    best_node = node_id

    #         return best_node

    #     def get_performance_metrics(self, task_id: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Get performance metrics for tasks or the entire system

    #         Args:
    #             task_id: Optional task ID to get metrics for

    #         Returns:
    #             Performance metrics
    #         """
    #         if task_id:
    task = self.get_task(task_id)
    #             if not task or not task.result:
    #                 return {}

    #             return {
    #                 "task_id": task_id,
    #                 "execution_time": task.result.execution_time,
    #                 "cpu_time": task.result.cpu_time,
    #                 "gpu_time": task.result.gpu_time,
    #                 "memory_used": task.result.memory_used,
    #                 "success": task.result.success,
    #                 "error": task.result.error,
    #             }
    #         else:
    #             # System-wide metrics
    scheduler_stats = self.scheduler.get_scheduler_stats()

    #             return {
    #                 "system_metrics": scheduler_stats,
    #                 "node_metrics": {
    #                     node_id: {
    #                         "active_tasks": node["active_tasks"],
    #                         "total_tasks": node["total_tasks"],
    #                         "success_rate": node["success_rate"],
    #                         "average_execution_time": node["average_execution_time"],
    #                     }
    #                     for node_id, node in self.node_table.items()
    #                 },
    #                 "resource_utilization": {
                        res_type.value: sum(
    #                         res.allocated_units
    #                         for res in self.get_resources_by_type(res_type)
    #                     )
                        / max(
                            sum(
    #                             res.total_units
    #                             for res in self.get_resources_by_type(res_type)
    #                         ),
    #                         1,
    #                     )
    #                     for res_type in ResourceType
    #                 },
    #                 "created_at": self.created_at,
    #                 "last_updated": self.last_updated,
    #             }

    #     def validate_system_state(self) -> List[str]:
    #         """
    #         Validate the state of the task index

    #         Returns:
    #             List of validation errors
    #         """
    errors = []

    #         # Check task consistency
    #         for task_id, task in self.task_table.items():
    #             # Check if task exists in scheduler
    #             if not self.scheduler.get_task(task_id):
                    errors.append(f"Task {task_id} in table but not in scheduler")

    #             # Check resource allocation consistency
    #             for resource_id, amount in task.assigned_resources.items():
    resource = self.get_resource(resource_id)
    #                 if not resource:
                        errors.append(
    #                         f"Task {task_id} references non-existent resource {resource_id}"
    #                     )
    #                 elif resource.allocated_units < amount:
                        errors.append(
    #                         f"Resource {resource_id} allocated less than task {task_id} expects"
    #                     )

    #         # Check resource consistency
    #         for resource_id, resource in self.resource_table.items():
    #             # Check allocation consistency
    #             if resource.allocated_units > resource.total_units:
                    errors.append(f"Resource {resource_id} allocated more than total")

    #             if (
    #                 resource.available_units + resource.allocated_units
    ! = resource.total_units
    #             ):
    errors.append(f"Resource {resource_id} available + allocated ! = total")

    #         # Check node consistency
    #         for node_id, node in self.node_table.items():
    #             # Check active tasks count
    active_count = sum(
    #                 1
    #                 for task in self.get_tasks_by_status(TaskStatus.RUNNING)
    #                 if task.execution_node == node_id
    #             )
    #             if node["active_tasks"] != active_count:
                    errors.append(f"Node {node_id} active task count mismatch")

    #         return errors

    #     def export_state(self) -> Dict[str, Any]:
    #         """
    #         Export the current state of the task index

    #         Returns:
    #             Dictionary representation of the state
    #         """
    #         return {
    #             "tasks": [
    #                 {
    #                     "id": task.id,
    #                     "name": task.name,
    #                     "type": task.task_type.value,
    #                     "priority": task.priority.value,
    #                     "status": task.status.value,
    #                     "created_at": task.created_at,
    #                     "updated_at": task.updated_at,
    #                     "estimated_duration": task.estimated_duration,
    #                     "actual_duration": task.actual_duration,
    #                     "dependencies": [
    #                         {
    #                             "task_id": dep.task_id,
    #                             "dependency_type": dep.dependency_type,
    #                             "estimated_duration": dep.estimated_duration,
    #                         }
    #                         for dep in task.dependencies
    #                     ],
    #                     "resource_requirements": [
    #                         {
    #                             "type": req.resource_type.value,
    #                             "amount": req.amount,
    #                             "constraints": req.constraints,
    #                         }
    #                         for req in task.resource_requirements
    #                     ],
    #                     "assigned_resources": task.assigned_resources,
    #                     "execution_node": task.execution_node,
                        "result": (
    #                         {
    #                             "success": task.result.success,
    #                             "execution_time": task.result.execution_time,
    #                             "memory_used": task.result.memory_used,
    #                             "error": task.result.error,
    #                         }
    #                         if task.result
    #                         else None
    #                     ),
    #                     "metadata": task.metadata,
                        "tags": list(task.tags),
    #                 }
    #                 for task in self.task_table.values()
    #             ],
    #             "resources": [
    #                 {
    #                     "id": res.id,
    #                     "type": res.type.value,
    #                     "name": res.name,
    #                     "total_units": res.total_units,
    #                     "available_units": res.available_units,
    #                     "allocated_units": res.allocated_units,
    #                     "version": res.version,
    #                     "location": res.location,
    #                     "capabilities": res.capabilities,
    #                     "metadata": res.metadata,
    #                 }
    #                 for res in self.resource_table.values()
    #             ],
    #             "nodes": [
    #                 {
    #                     "id": node["id"],
    #                     "type": node["type"],
    #                     "capabilities": node["capabilities"],
    #                     "location": node["location"],
    #                     "metadata": node["metadata"],
    #                     "active_tasks": node["active_tasks"],
    #                     "total_tasks": node["total_tasks"],
    #                     "success_rate": node["success_rate"],
    #                     "average_execution_time": node["average_execution_time"],
    #                 }
    #                 for node in self.node_table.values()
    #             ],
                "exported_at": time.time(),
    #         }

    #     def import_state(self, state: Dict[str, Any]) -> bool:
    #         """
    #         Import a state into the task index

    #         Args:
    #             state: Dictionary representation of state

    #         Returns:
    #             True if import successful
    #         """
    #         try:
    #             # Clear existing state
                self.task_table.clear()
                self.resource_table.clear()
                self.node_table.clear()

    #             # Import resources
    #             for res_data in state.get("resources", []):
    resource = Resource(
    id = res_data["id"],
    type = ResourceType(res_data["type"]),
    name = res_data["name"],
    total_units = res_data["total_units"],
    available_units = res_data["available_units"],
    allocated_units = res_data["allocated_units"],
    version = res_data["version"],
    location = res_data["location"],
    capabilities = res_data["capabilities"],
    metadata = res_data["metadata"],
    #                 )
    self.resource_table[resource.id] = resource
                    self.scheduler.add_resource(resource)

    #             # Import nodes
    #             for node_data in state.get("nodes", []):
                    self.add_node(
    node_id = node_data["id"],
    node_type = node_data["type"],
    capabilities = node_data["capabilities"],
    location = node_data["location"],
    metadata = node_data["metadata"],
    #                 )

    #             # Import tasks
    #             for task_data in state.get("tasks", []):
    dependencies = [
                        TaskDependency(
    task_id = dep["task_id"],
    dependency_type = dep["dependency_type"],
    estimated_duration = dep["estimated_duration"],
    #                     )
    #                     for dep in task_data["dependencies"]
    #                 ]

    resource_requirements = [
                        ResourceRequirement(
    resource_type = ResourceType(req["type"]),
    amount = req["amount"],
    constraints = req["constraints"],
    #                     )
    #                     for req in task_data["resource_requirements"]
    #                 ]

    task = Task(
    id = task_data["id"],
    name = task_data["name"],
    task_type = TaskType(task_data["type"]),
    priority = TaskPriority(task_data["priority"]),
    status = TaskStatus(task_data["status"]),
    created_at = task_data["created_at"],
    updated_at = task_data["updated_at"],
    estimated_duration = task_data["estimated_duration"],
    actual_duration = task_data["actual_duration"],
    dependencies = dependencies,
    resource_requirements = resource_requirements,
    assigned_resources = task_data["assigned_resources"],
    execution_node = task_data["execution_node"],
    metadata = task_data["metadata"],
    tags = set(task_data["tags"]),
    #                 )

    #                 # Add result if present
    #                 if task_data.get("result"):
    task.result = TaskResult(
    success = task_data["result"]["success"],
    execution_time = task_data["result"]["execution_time"],
    memory_used = task_data["result"]["memory_used"],
    error = task_data["result"]["error"],
    #                     )

    self.task_table[task.id] = task

    #                 # Add to scheduler if not completed
    #                 if task.status not in [
    #                     TaskStatus.COMPLETED,
    #                     TaskStatus.FAILED,
    #                     TaskStatus.CANCELLED,
    #                 ]:
                        self.scheduler.add_task(task)

    self.last_updated = time.time()
    #             return True

    #         except Exception as e:
                print(f"Error importing state: {e}")
    #             return False

    #     def shutdown(self):
    #         """Shutdown the task index"""
            self.scheduler.stop()
