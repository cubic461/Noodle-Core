# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Distributed System Performance Module for NoodleCore
# """

import os
import time
import json
import logging
import threading
import asyncio
import psutil
import typing.Dict,
import dataclasses.dataclass,
import collections.defaultdict,
import concurrent.futures.ThreadPoolExecutor,

import redis
import redis.exceptions.ConnectionError,

import .cache_manager.get_cache_manager
import .distributed_integration.DistributedNodeManager,
import .load_balancer.LoadBalancer

logger = logging.getLogger(__name__)


# @dataclass
class NodePerformanceMetrics
    #     """Performance metrics for a distributed node"""
    #     node_id: str
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    disk_usage: float = 0.0
    network_io: Dict[str, float] = field(default_factory=dict)
    task_count: int = 0
    active_tasks: int = 0
    completed_tasks: int = 0
    failed_tasks: int = 0
    avg_task_time: float = 0.0
    last_heartbeat: float = field(default_factory=time.time)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "node_id": self.node_id,
    #             "cpu_usage": self.cpu_usage,
    #             "memory_usage": self.memory_usage,
    #             "disk_usage": self.disk_usage,
    #             "network_io": self.network_io,
    #             "task_count": self.task_count,
    #             "active_tasks": self.active_tasks,
    #             "completed_tasks": self.completed_tasks,
    #             "failed_tasks": self.failed_tasks,
    #             "avg_task_time": self.avg_task_time,
    #             "last_heartbeat": self.last_heartbeat
    #         }


# @dataclass
class TaskPerformanceMetrics
    #     """Performance metrics for a task"""
    #     task_id: str
    #     node_id: str
    #     task_type: str
    #     start_time: float
    end_time: Optional[float] = None
    duration: Optional[float] = None
    status: str = "pending"
    error: Optional[str] = None
    resource_usage: Dict[str, Any] = field(default_factory=dict)

    #     def complete(self, status: str = "completed", error: Optional[str] = None):
    #         """Mark task as complete"""
    self.end_time = time.time()
    self.duration = math.subtract(self.end_time, self.start_time)
    self.status = status
    self.error = error

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "task_id": self.task_id,
    #             "node_id": self.node_id,
    #             "task_type": self.task_type,
    #             "start_time": self.start_time,
    #             "end_time": self.end_time,
    #             "duration": self.duration,
    #             "status": self.status,
    #             "error": self.error,
    #             "resource_usage": self.resource_usage
    #         }


class DistributedPerformanceMonitor
    #     """Performance monitor for distributed system"""

    #     def __init__(self, node_manager: DistributedNodeManager,
    #                  task_distributor: TaskDistributor,
    #                  load_balancer: LoadBalancer):
    self.node_manager = node_manager
    self.task_distributor = task_distributor
    self.load_balancer = load_balancer

    #         # Performance data
    self.node_metrics = {}
    self.task_metrics = {}
    self.metrics_lock = threading.RLock()

    #         # Performance history
    self.node_metrics_history = defaultdict(lambda: deque(maxlen=1000))
    self.task_metrics_history = deque(maxlen=10000)

    #         # Monitoring settings
    self.monitoring_interval = getattr(node_manager.config, "monitoring_interval", 10)  # 10 seconds
    self.performance_thresholds = getattr(node_manager.config, "performance_thresholds", {
    #             "cpu_usage": 80.0,  # 80%
    #             "memory_usage": 80.0,  # 80%
    #             "disk_usage": 90.0,  # 90%
    #             "avg_task_time": 30.0,  # 30 seconds
    #             "task_failure_rate": 10.0  # 10%
    #         })

    #         # Monitoring task
    self.monitoring_task = None
    self.running = False

    #         # Cache
    self.cache_manager = get_cache_manager()

    #         # Performance callbacks
    self.performance_callbacks = []

    #     def start_monitoring(self):
    #         """Start performance monitoring"""
    #         if self.running:
    #             return

    self.running = True
            logger.info("Starting distributed performance monitoring")

    #         # Start monitoring task
    #         try:
    loop = asyncio.get_event_loop()
    #         except RuntimeError:
    loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)

    self.monitoring_task = loop.create_task(self._monitoring_loop())

    #     def stop_monitoring(self):
    #         """Stop performance monitoring"""
    #         if not self.running:
    #             return

    self.running = False
            logger.info("Stopping distributed performance monitoring")

    #         # Cancel monitoring task
    #         if self.monitoring_task:
                self.monitoring_task.cancel()

    #     async def _monitoring_loop(self):
    #         """Main monitoring loop"""
    #         while self.running:
    #             try:
    #                 # Monitor nodes
                    await self._monitor_nodes()

    #                 # Monitor tasks
                    await self._monitor_tasks()

    #                 # Check performance thresholds
                    await self._check_performance_thresholds()

    #                 # Update cache
                    await self._update_cache()

    #                 # Sleep until next monitoring cycle
                    await asyncio.sleep(self.monitoring_interval)

    #             except Exception as e:
                    logger.error(f"Error in monitoring loop: {e}")
                    await asyncio.sleep(1)  # Short sleep before retrying

    #     async def _monitor_nodes(self):
    #         """Monitor all nodes"""
    nodes = self.node_manager.get_all_nodes()

    #         for node_id, node_info in nodes.items():
    #             try:
    #                 # Get node metrics
    metrics = await self._collect_node_metrics(node_id)

    #                 with self.metrics_lock:
    self.node_metrics[node_id] = metrics
                        self.node_metrics_history[node_id].append(metrics)

    #                 # Update load balancer with node performance
                    self.load_balancer.update_node_performance(node_id, metrics)

    #             except Exception as e:
                    logger.error(f"Error monitoring node {node_id}: {e}")

    #     async def _collect_node_metrics(self, node_id: str) -> NodePerformanceMetrics:
    #         """Collect performance metrics for a node"""
    #         # Get node info
    node_info = self.node_manager.get_node(node_id)

    #         # Create metrics
    metrics = NodePerformanceMetrics(node_id=node_id)

    #         # Collect system metrics
    #         try:
    #             # CPU usage
    metrics.cpu_usage = psutil.cpu_percent(interval=1)

    #             # Memory usage
    memory = psutil.virtual_memory()
    metrics.memory_usage = memory.percent

    #             # Disk usage
    disk = psutil.disk_usage('/')
    metrics.disk_usage = disk.percent

    #             # Network I/O
    network = psutil.net_io_counters()
    metrics.network_io = {
    #                 "bytes_sent": network.bytes_sent,
    #                 "bytes_recv": network.bytes_recv,
    #                 "packets_sent": network.packets_sent,
    #                 "packets_recv": network.packets_recv
    #             }
    #         except Exception as e:
    #             logger.error(f"Error collecting system metrics for node {node_id}: {e}")

    #         # Collect task metrics
    #         try:
    #             # Get tasks for node
    node_tasks = self.task_distributor.get_node_tasks(node_id)
    metrics.task_count = len(node_tasks)
    #             metrics.active_tasks = len([t for t in node_tasks if t.get("status") == "running"])
    #             metrics.completed_tasks = len([t for t in node_tasks if t.get("status") == "completed"])
    #             metrics.failed_tasks = len([t for t in node_tasks if t.get("status") == "failed"])

    #             # Calculate average task time
    #             completed_tasks = [t for t in node_tasks if t.get("status") == "completed"]
    #             if completed_tasks:
    task_times = []
    #                 for task in completed_tasks:
    task_metrics = self.task_metrics.get(task.get("task_id"))
    #                     if task_metrics and task_metrics.duration:
                            task_times.append(task_metrics.duration)

    #                 if task_times:
    metrics.avg_task_time = math.divide(sum(task_times), len(task_times))
    #         except Exception as e:
    #             logger.error(f"Error collecting task metrics for node {node_id}: {e}")

    #         # Update last heartbeat
    metrics.last_heartbeat = time.time()

    #         return metrics

    #     async def _monitor_tasks(self):
    #         """Monitor all tasks"""
    #         # Get active tasks
    active_tasks = self.task_distributor.get_active_tasks()

    #         for task_id, task_info in active_tasks.items():
    #             try:
    #                 # Check if task metrics exist
    #                 with self.metrics_lock:
    #                     if task_id not in self.task_metrics:
    #                         # Create new task metrics
    self.task_metrics[task_id] = TaskPerformanceMetrics(
    task_id = task_id,
    node_id = task_info.get("node_id"),
    task_type = task_info.get("task_type"),
    start_time = task_info.get("start_time", time.time())
    #                         )

    #                 # Update task status if changed
    task_metrics = self.task_metrics[task_id]
    current_status = task_info.get("status")

    #                 if current_status != task_metrics.status and current_status in ["completed", "failed"]:
                        task_metrics.complete(
    status = current_status,
    error = task_info.get("error")
    #                     )

    #                     with self.metrics_lock:
                            self.task_metrics_history.append(task_metrics)

    #             except Exception as e:
                    logger.error(f"Error monitoring task {task_id}: {e}")

    #     async def _check_performance_thresholds(self):
    #         """Check performance thresholds and trigger alerts"""
    #         with self.metrics_lock:
    #             for node_id, metrics in self.node_metrics.items():
    alerts = []

    #                 # Check CPU usage
    #                 if metrics.cpu_usage > self.performance_thresholds["cpu_usage"]:
                        alerts.append({
    #                         "type": "cpu_usage",
    #                         "node_id": node_id,
    #                         "value": metrics.cpu_usage,
    #                         "threshold": self.performance_thresholds["cpu_usage"]
    #                     })

    #                 # Check memory usage
    #                 if metrics.memory_usage > self.performance_thresholds["memory_usage"]:
                        alerts.append({
    #                         "type": "memory_usage",
    #                         "node_id": node_id,
    #                         "value": metrics.memory_usage,
    #                         "threshold": self.performance_thresholds["memory_usage"]
    #                     })

    #                 # Check disk usage
    #                 if metrics.disk_usage > self.performance_thresholds["disk_usage"]:
                        alerts.append({
    #                         "type": "disk_usage",
    #                         "node_id": node_id,
    #                         "value": metrics.disk_usage,
    #                         "threshold": self.performance_thresholds["disk_usage"]
    #                     })

    #                 # Check average task time
    #                 if metrics.avg_task_time > self.performance_thresholds["avg_task_time"]:
                        alerts.append({
    #                         "type": "avg_task_time",
    #                         "node_id": node_id,
    #                         "value": metrics.avg_task_time,
    #                         "threshold": self.performance_thresholds["avg_task_time"]
    #                     })

    #                 # Check task failure rate
    #                 if metrics.task_count > 0:
    failure_rate = math.multiply((metrics.failed_tasks / metrics.task_count), 100)
    #                     if failure_rate > self.performance_thresholds["task_failure_rate"]:
                            alerts.append({
    #                             "type": "task_failure_rate",
    #                             "node_id": node_id,
    #                             "value": failure_rate,
    #                             "threshold": self.performance_thresholds["task_failure_rate"]
    #                         })

    #                 # Trigger callbacks for alerts
    #                 for alert in alerts:
                        await self._trigger_performance_alert(alert)

    #     async def _trigger_performance_alert(self, alert: Dict[str, Any]):
    #         """Trigger performance alert"""
            logger.warning(f"Performance alert: {json.dumps(alert)}")

    #         # Call performance callbacks
    #         for callback in self.performance_callbacks:
    #             try:
    #                 if asyncio.iscoroutinefunction(callback):
                        await callback(alert)
    #                 else:
                        callback(alert)
    #             except Exception as e:
                    logger.error(f"Error in performance callback: {e}")

    #     async def _update_cache(self):
    #         """Update cache with performance metrics"""
    #         try:
    #             # Cache node metrics
    #             with self.metrics_lock:
    node_metrics_data = {
                        node_id: metrics.to_dict()
    #                     for node_id, metrics in self.node_metrics.items()
    #                 }

    self.cache_manager.set("node_metrics", node_metrics_data, ttl = 60)  # 1 minute

    #             # Cache system metrics
    system_metrics = self._calculate_system_metrics()
    self.cache_manager.set("system_metrics", system_metrics, ttl = 60)  # 1 minute

    #         except Exception as e:
                logger.error(f"Error updating cache: {e}")

    #     def _calculate_system_metrics(self) -> Dict[str, Any]:
    #         """Calculate system-wide metrics"""
    #         with self.metrics_lock:
    #             if not self.node_metrics:
    #                 return {}

    #             # Calculate averages
    #             avg_cpu = sum(m.cpu_usage for m in self.node_metrics.values()) / len(self.node_metrics)
    #             avg_memory = sum(m.memory_usage for m in self.node_metrics.values()) / len(self.node_metrics)
    #             avg_disk = sum(m.disk_usage for m in self.node_metrics.values()) / len(self.node_metrics)

    #             # Calculate totals
    #             total_tasks = sum(m.task_count for m in self.node_metrics.values())
    #             total_active_tasks = sum(m.active_tasks for m in self.node_metrics.values())
    #             total_completed_tasks = sum(m.completed_tasks for m in self.node_metrics.values())
    #             total_failed_tasks = sum(m.failed_tasks for m in self.node_metrics.values())

    #             # Calculate averages
    avg_task_time = 0
    #             if self.task_metrics_history:
    #                 completed_tasks = [m for m in self.task_metrics_history if m.status == "completed"]
    #                 if completed_tasks:
    #                     avg_task_time = sum(m.duration for m in completed_tasks) / len(completed_tasks)

    #             return {
    #                 "avg_cpu_usage": avg_cpu,
    #                 "avg_memory_usage": avg_memory,
    #                 "avg_disk_usage": avg_disk,
                    "total_nodes": len(self.node_metrics),
    #                 "total_tasks": total_tasks,
    #                 "total_active_tasks": total_active_tasks,
    #                 "total_completed_tasks": total_completed_tasks,
    #                 "total_failed_tasks": total_failed_tasks,
    #                 "avg_task_time": avg_task_time,
                    "timestamp": time.time()
    #             }

    #     def get_node_metrics(self, node_id: str) -> Optional[NodePerformanceMetrics]:
    #         """Get performance metrics for a node"""
    #         with self.metrics_lock:
                return self.node_metrics.get(node_id)

    #     def get_all_node_metrics(self) -> Dict[str, NodePerformanceMetrics]:
    #         """Get performance metrics for all nodes"""
    #         with self.metrics_lock:
                return self.node_metrics.copy()

    #     def get_task_metrics(self, task_id: str) -> Optional[TaskPerformanceMetrics]:
    #         """Get performance metrics for a task"""
    #         with self.metrics_lock:
                return self.task_metrics.get(task_id)

    #     def get_system_metrics(self) -> Dict[str, Any]:
    #         """Get system-wide performance metrics"""
    #         # Try cache first
    cached_metrics = self.cache_manager.get("system_metrics")
    #         if cached_metrics:
    #             return cached_metrics

    #         # Calculate and return
            return self._calculate_system_metrics()

    #     def get_node_metrics_history(self, node_id: str, limit: int = 100) -> List[NodePerformanceMetrics]:
    #         """Get performance metrics history for a node"""
    #         with self.metrics_lock:
    history = list(self.node_metrics_history.get(node_id, []))
    #             return history[-limit:] if history else []

    #     def get_task_metrics_history(self, limit: int = 1000) -> List[TaskPerformanceMetrics]:
    #         """Get performance metrics history for tasks"""
    #         with self.metrics_lock:
    history = list(self.task_metrics_history)
    #             return history[-limit:] if history else []

    #     def add_performance_callback(self, callback: Callable[[Dict[str, Any]], None]):
    #         """Add a performance callback"""
            self.performance_callbacks.append(callback)

    #     def remove_performance_callback(self, callback: Callable[[Dict[str, Any]], None]):
    #         """Remove a performance callback"""
    #         if callback in self.performance_callbacks:
                self.performance_callbacks.remove(callback)

    #     def optimize_load_balancing(self):
    #         """Optimize load balancing based on performance metrics"""
    #         # Get node metrics
    node_metrics = self.get_all_node_metrics()

    #         # Calculate node scores
    node_scores = {}
    #         for node_id, metrics in node_metrics.items():
    #             # Calculate score based on CPU, memory, and task metrics
    cpu_score = math.subtract(100, metrics.cpu_usage)
    memory_score = math.subtract(100, metrics.memory_usage)
    task_score = math.multiply(100 - (metrics.active_tasks / max(metrics.task_count, 1), 100))

    #             # Weighted average
    node_scores[node_id] = math.add((cpu_score * 0.4, memory_score * 0.3 + task_score * 0.3))

    #         # Update load balancer with node scores
            self.load_balancer.update_node_scores(node_scores)

    #         logger.info(f"Optimized load balancing with node scores: {node_scores}")

    #     def rebalance_tasks(self):
    #         """Rebalance tasks based on performance metrics"""
    #         # Get node metrics
    node_metrics = self.get_all_node_metrics()

    #         # Find overloaded and underloaded nodes
    overloaded_nodes = []
    underloaded_nodes = []

    #         for node_id, metrics in node_metrics.items():
    #             # Check if node is overloaded
    #             if (metrics.cpu_usage > self.performance_thresholds["cpu_usage"] or
    #                 metrics.memory_usage > self.performance_thresholds["memory_usage"] or
    #                 metrics.active_tasks > 10):  # Arbitrary threshold
                    overloaded_nodes.append(node_id)

    #             # Check if node is underloaded
    #             elif (metrics.cpu_usage < 50 and
    #                   metrics.memory_usage < 50 and
    #                   metrics.active_tasks < 3):  # Arbitrary thresholds
                    underloaded_nodes.append(node_id)

    #         # Rebalance tasks
    #         if overloaded_nodes and underloaded_nodes:
    #             for overloaded_node in overloaded_nodes:
    #                 # Get tasks from overloaded node
    tasks = self.task_distributor.get_node_tasks(overloaded_node)

    #                 # Select tasks to move
    tasks_to_move = []
    #                 for task in tasks:
    #                     if (task.get("status") == "pending" and
                            len(tasks_to_move) < 3):  # Move at most 3 tasks
                            tasks_to_move.append(task)

    #                 # Move tasks to underloaded nodes
    #                 for i, task in enumerate(tasks_to_move):
    #                     if i < len(underloaded_nodes):
    target_node = underloaded_nodes[i]
                            self.task_distributor.reassign_task(task.get("task_id"), target_node)

                    logger.info(f"Rebalanced {len(tasks_to_move)} tasks from {overloaded_node}")

    #     def generate_performance_report(self) -> Dict[str, Any]:
    #         """Generate a comprehensive performance report"""
    #         # Get system metrics
    system_metrics = self.get_system_metrics()

    #         # Get node metrics
    node_metrics = self.get_all_node_metrics()

    #         # Get task metrics history
    task_history = self.get_task_metrics_history(limit=1000)

    #         # Calculate performance statistics
    #         completed_tasks = [m for m in task_history if m.status == "completed"]
    #         failed_tasks = [m for m in task_history if m.status == "failed"]

    #         # Calculate task duration statistics
    #         task_durations = [m.duration for m in completed_tasks if m.duration]
    #         avg_task_duration = sum(task_durations) / len(task_durations) if task_durations else 0
    #         min_task_duration = min(task_durations) if task_durations else 0
    #         max_task_duration = max(task_durations) if task_durations else 0

    #         # Calculate task type statistics
    task_type_stats = defaultdict(lambda: {"count": 0, "completed": 0, "failed": 0})
    #         for task in task_history:
    task_type = task.task_type
    task_type_stats[task_type]["count"] + = 1
    #             if task.status == "completed":
    task_type_stats[task_type]["completed"] + = 1
    #             elif task.status == "failed":
    task_type_stats[task_type]["failed"] + = 1

    #         # Calculate success rates
    #         for task_type, stats in task_type_stats.items():
    #             if stats["count"] > 0:
    stats["success_rate"] = (stats["completed"] / stats["count"]) * 100
    #             else:
    stats["success_rate"] = 0

    #         return {
                "report_time": time.time(),
    #             "system_metrics": system_metrics,
                "node_count": len(node_metrics),
    #             "node_metrics": {node_id: metrics.to_dict() for node_id, metrics in node_metrics.items()},
    #             "task_statistics": {
                    "total_tasks": len(task_history),
                    "completed_tasks": len(completed_tasks),
                    "failed_tasks": len(failed_tasks),
    #                 "success_rate": (len(completed_tasks) / len(task_history) * 100) if task_history else 0,
    #                 "avg_task_duration": avg_task_duration,
    #                 "min_task_duration": min_task_duration,
    #                 "max_task_duration": max_task_duration
    #             },
                "task_type_statistics": dict(task_type_stats)
    #         }


# Global performance monitor instance
_performance_monitor = None


def get_distributed_performance_monitor(node_manager: DistributedNodeManager,
#                                       task_distributor: TaskDistributor,
#                                       load_balancer: LoadBalancer) -> DistributedPerformanceMonitor:
#     """Get the global distributed performance monitor instance"""
#     global _performance_monitor

#     if _performance_monitor is None:
_performance_monitor = DistributedPerformanceMonitor(
#             node_manager, task_distributor, load_balancer
#         )

#     return _performance_monitor


def initialize_distributed_performance_monitor(node_manager: DistributedNodeManager,
#                                              task_distributor: TaskDistributor,
#                                              load_balancer: LoadBalancer):
#     """Initialize the global distributed performance monitor"""
#     global _performance_monitor

#     if _performance_monitor is not None:
        _performance_monitor.stop_monitoring()

_performance_monitor = DistributedPerformanceMonitor(
#         node_manager, task_distributor, load_balancer
#     )

    _performance_monitor.start_monitoring()
    logger.info("Distributed Performance Monitor initialized")


function shutdown_distributed_performance_monitor()
    #     """Shutdown the global distributed performance monitor"""
    #     global _performance_monitor

    #     if _performance_monitor is not None:
            _performance_monitor.stop_monitoring()
    _performance_monitor = None

        logger.info("Distributed Performance Monitor shutdown")