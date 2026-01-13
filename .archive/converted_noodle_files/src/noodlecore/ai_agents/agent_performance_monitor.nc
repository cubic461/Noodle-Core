# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore AI Agent Performance Monitor
 = =========================================

# Performance monitoring utilities for AI agents with comprehensive metrics,
# real-time monitoring, and alerting capabilities.

# Implements AI agent standards:
# - Performance metrics collection
# - Resource usage monitoring
# - Alert system for performance issues
# - Proper error handling with 4-digit error codes
# """

import os
import time
import threading
import logging
import uuid
import psutil
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import collections.defaultdict,

import .errors.DatabaseError,


class MetricType(Enum)
    #     """Types of performance metrics."""
    EXECUTION_TIME = "execution_time"
    MEMORY_USAGE = "memory_usage"
    CPU_USAGE = "cpu_usage"
    REQUEST_COUNT = "request_count"
    ERROR_COUNT = "error_count"
    RESPONSE_TIME = "response_time"
    THROUGHPUT = "throughput"
    QUEUE_DEPTH = "queue_depth"


class AlertLevel(Enum)
    #     """Alert severity levels."""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


# @dataclass
class PerformanceMetric
    #     """Performance metric data point."""
    #     metric_id: str
    #     agent_id: str
    #     metric_type: MetricType
    #     value: float
    #     unit: str
    timestamp: datetime = field(default_factory=datetime.now)
    tags: Dict[str, str] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class AgentPerformanceStats
    #     """Performance statistics for an agent."""
    #     agent_id: str
    total_requests: int = 0
    total_errors: int = 0
    avg_execution_time: float = 0.0
    max_execution_time: float = 0.0
    min_execution_time: float = float(999999.0)
    avg_memory_usage: float = 0.0
    max_memory_usage: float = 0.0
    avg_cpu_usage: float = 0.0
    max_cpu_usage: float = 0.0
    last_updated: datetime = field(default_factory=datetime.now)
    uptime_percentage: float = 100.0
    response_time_p95: float = 0.0
    response_time_p99: float = 0.0


# @dataclass
class PerformanceAlert
    #     """Performance alert for agent issues."""
    #     alert_id: str
    #     agent_id: str
    #     metric_type: MetricType
    #     level: AlertLevel
    #     message: str
    #     threshold: float
    #     current_value: float
    timestamp: datetime = field(default_factory=datetime.now)
    resolved: bool = False
    resolved_at: Optional[datetime] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


class AgentPerformanceMonitor
    #     """
    #     Performance monitor for AI agents.

    #     Features:
    #     - Real-time performance metrics collection
    #     - Resource usage monitoring
    #     - Alert system with configurable thresholds
    #     - Historical data analysis
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, max_history_size: int = 10000):
    #         """
    #         Initialize performance monitor.

    #         Args:
    #             max_history_size: Maximum number of metrics to keep in memory
    #         """
    self.max_history_size = max_history_size
    self.logger = logging.getLogger('noodlecore.ai_agents.performance_monitor')

    #         # Performance data storage
    self._metrics: Dict[str, deque] = defaultdict(lambda: deque(maxlen=max_history_size))
    self._agent_stats: Dict[str, AgentPerformanceStats] = {}
    self._alerts: Dict[str, PerformanceAlert] = {}

    #         # Monitoring state
    self._monitoring_active = False
    self._monitoring_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()

    #         # Performance thresholds
    self._thresholds = {
    #             MetricType.EXECUTION_TIME: {"warning": 2.0, "error": 5.0, "critical": 10.0},
    #             MetricType.MEMORY_USAGE: {"warning": 100.0, "error": 200.0, "critical": 500.0},  # MB
    #             MetricType.CPU_USAGE: {"warning": 70.0, "error": 85.0, "critical": 95.0},  # %
    #             MetricType.ERROR_COUNT: {"warning": 5.0, "error": 10.0, "critical": 20.0},  # per minute
    #             MetricType.RESPONSE_TIME: {"warning": 1.0, "error": 2.0, "critical": 5.0}
    #         }

    #         # Alert callbacks
    self._alert_callbacks: List[Callable[[PerformanceAlert], None]] = []

            self.logger.info("Agent performance monitor initialized")

    #     def start_monitoring(self, interval_seconds: float = 5.0) -> None:
    #         """
    #         Start performance monitoring.

    #         Args:
    #             interval_seconds: Monitoring interval in seconds

    #         Raises:
    #             DatabaseError: If monitoring cannot be started
    #         """
    #         try:
    #             if self._monitoring_active:
    raise DatabaseError("Performance monitoring is already active", error_code = 9001)

    self._monitoring_active = True
                self._stop_event.clear()

    #             # Start monitoring thread
    self._monitoring_thread = threading.Thread(
    target = self._monitoring_loop,
    args = (interval_seconds,),
    daemon = True
    #             )
                self._monitoring_thread.start()

    #             self.logger.info(f"Started performance monitoring with {interval_seconds}s interval")
    #         except Exception as e:
    error_msg = f"Failed to start performance monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 9002)

    #     def stop_monitoring(self) -> None:
    #         """
    #         Stop performance monitoring.

    #         Raises:
    #             DatabaseError: If monitoring cannot be stopped
    #         """
    #         try:
    #             if not self._monitoring_active:
    #                 return

    #             # Signal stop
                self._stop_event.set()
    self._monitoring_active = False

    #             # Wait for thread to finish
    #             if self._monitoring_thread and self._monitoring_thread.is_alive():
    self._monitoring_thread.join(timeout = 10)

                self.logger.info("Stopped performance monitoring")
    #         except Exception as e:
    error_msg = f"Failed to stop performance monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 9003)

    #     def record_metric(
    #         self,
    #         agent_id: str,
    #         metric_type: MetricType,
    #         value: float,
    unit: str = "",
    tags: Optional[Dict[str, str]] = None,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -> str:
    #         """
    #         Record a performance metric for an agent.

    #         Args:
    #             agent_id: ID of the agent
    #             metric_type: Type of metric
    #             value: Metric value
    #             unit: Unit of measurement
    #             tags: Optional tags for categorization
    #             metadata: Optional additional metadata

    #         Returns:
    #             Metric ID
    #         """
    #         try:
    #             # Generate metric ID
    metric_id = str(uuid.uuid4())

    #             # Create metric
    metric = PerformanceMetric(
    metric_id = metric_id,
    agent_id = agent_id,
    metric_type = metric_type,
    value = value,
    unit = unit,
    tags = tags or {},
    metadata = metadata or {}
    #             )

    #             # Store metric
                self._metrics[agent_id].append(metric)

    #             # Update agent statistics
                self._update_agent_stats(agent_id, metric)

    #             # Check for alerts
                self._check_metric_alerts(agent_id, metric_type, value)

    #             return metric_id
    #         except Exception as e:
    error_msg = f"Failed to record metric: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 9004)

    #     def record_execution_time(
    #         self,
    #         agent_id: str,
    #         execution_time: float,
    operation: str = "",
    success: bool = True
    #     ) -> str:
    #         """
    #         Record execution time for an agent operation.

    #         Args:
    #             agent_id: ID of the agent
    #             execution_time: Execution time in seconds
    #             operation: Type of operation performed
    #             success: Whether the operation was successful

    #         Returns:
    #             Metric ID
    #         """
    #         # Record execution time metric
    metric_id = self.record_metric(
    agent_id = agent_id,
    metric_type = MetricType.EXECUTION_TIME,
    value = execution_time,
    unit = "seconds",
    #             tags={"operation": operation, "status": "success" if success else "error"}
    #         )

    #         # Record request count
            self.record_metric(
    agent_id = agent_id,
    metric_type = MetricType.REQUEST_COUNT,
    value = 1,
    unit = "count",
    tags = {"operation": operation}
    #         )

    #         # Record error count if failed
    #         if not success:
                self.record_metric(
    agent_id = agent_id,
    metric_type = MetricType.ERROR_COUNT,
    value = 1,
    unit = "count",
    tags = {"operation": operation}
    #             )

    #         return metric_id

    #     def record_resource_usage(
    #         self,
    #         agent_id: str,
    #         memory_mb: float,
    #         cpu_percent: float
    #     ) -> None:
    #         """
    #         Record resource usage for an agent.

    #         Args:
    #             agent_id: ID of the agent
    #             memory_mb: Memory usage in MB
    #             cpu_percent: CPU usage percentage
    #         """
    #         # Record memory usage
            self.record_metric(
    agent_id = agent_id,
    metric_type = MetricType.MEMORY_USAGE,
    value = memory_mb,
    unit = "MB"
    #         )

    #         # Record CPU usage
            self.record_metric(
    agent_id = agent_id,
    metric_type = MetricType.CPU_USAGE,
    value = cpu_percent,
    unit = "percent"
    #         )

    #     def get_agent_stats(self, agent_id: str) -> Optional[AgentPerformanceStats]:
    #         """
    #         Get performance statistics for an agent.

    #         Args:
    #             agent_id: ID of the agent

    #         Returns:
    #             Agent performance statistics or None if not found
    #         """
            return self._agent_stats.get(agent_id)

    #     def get_all_agent_stats(self) -> Dict[str, AgentPerformanceStats]:
    #         """
    #         Get performance statistics for all agents.

    #         Returns:
    #             Dictionary mapping agent IDs to their statistics
    #         """
            return self._agent_stats.copy()

    #     def get_metrics(
    #         self,
    #         agent_id: str,
    metric_type: Optional[MetricType] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None
    #     ) -> List[PerformanceMetric]:
    #         """
    #         Get performance metrics for an agent.

    #         Args:
    #             agent_id: ID of the agent
    #             metric_type: Optional filter by metric type
    #             start_time: Optional start time filter
    #             end_time: Optional end time filter

    #         Returns:
    #             List of performance metrics
    #         """
    #         if agent_id not in self._metrics:
    #             return []

    metrics = list(self._metrics[agent_id])

    #         # Apply filters
    #         if metric_type:
    #             metrics = [m for m in metrics if m.metric_type == metric_type]

    #         if start_time:
    #             metrics = [m for m in metrics if m.timestamp >= start_time]

    #         if end_time:
    #             metrics = [m for m in metrics if m.timestamp <= end_time]

            # Sort by timestamp (newest first)
    metrics.sort(key = lambda m: m.timestamp, reverse=True)

    #         return metrics

    #     def get_alerts(
    #         self,
    agent_id: Optional[str] = None,
    level: Optional[AlertLevel] = None,
    resolved: Optional[bool] = None
    #     ) -> List[PerformanceAlert]:
    #         """
    #         Get performance alerts.

    #         Args:
    #             agent_id: Optional filter by agent ID
    #             level: Optional filter by alert level
    #             resolved: Optional filter by resolved status

    #         Returns:
    #             List of performance alerts
    #         """
    alerts = list(self._alerts.values())

    #         # Apply filters
    #         if agent_id:
    #             alerts = [a for a in alerts if a.agent_id == agent_id]

    #         if level:
    #             alerts = [a for a in alerts if a.level == level]

    #         if resolved is not None:
    #             alerts = [a for a in alerts if a.resolved == resolved]

            # Sort by timestamp (newest first)
    alerts.sort(key = lambda a: a.timestamp, reverse=True)

    #         return alerts

    #     def resolve_alert(self, alert_id: str) -> bool:
    #         """
    #         Resolve a performance alert.

    #         Args:
    #             alert_id: Alert ID to resolve

    #         Returns:
    #             True if resolved successfully
    #         """
    #         try:
    #             if alert_id not in self._alerts:
    #                 return False

    alert = self._alerts[alert_id]
    alert.resolved = True
    alert.resolved_at = datetime.now()

                self.logger.info(f"Resolved alert: {alert_id}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to resolve alert {alert_id}: {str(e)}"
                self.logger.error(error_msg)
    #             return False

    #     def set_threshold(
    #         self,
    #         metric_type: MetricType,
    #         warning_threshold: float,
    #         error_threshold: float,
    #         critical_threshold: float
    #     ) -> None:
    #         """
    #         Set performance thresholds for a metric type.

    #         Args:
    #             metric_type: Type of metric
    #             warning_threshold: Warning threshold value
    #             error_threshold: Error threshold value
    #             critical_threshold: Critical threshold value
    #         """
    self._thresholds[metric_type] = {
    #             "warning": warning_threshold,
    #             "error": error_threshold,
    #             "critical": critical_threshold
    #         }

    #         self.logger.info(f"Updated thresholds for {metric_type.value}")

    #     def add_alert_callback(self, callback: Callable[[PerformanceAlert], None]) -> None:
    #         """
    #         Add a callback function for alert notifications.

    #         Args:
    #             callback: Function to call when alerts are generated
    #         """
            self._alert_callbacks.append(callback)

    #     def get_performance_summary(self, hours: int = 24) -> Dict[str, Any]:
    #         """
    #         Get performance summary for the specified time period.

    #         Args:
    #             hours: Number of hours to include in summary

    #         Returns:
    #             Performance summary dictionary
    #         """
    #         try:
    end_time = datetime.now()
    start_time = math.subtract(end_time, timedelta(hours=hours))

    #             # Collect summary data
    summary = {
    #                 "period_hours": hours,
                    "start_time": start_time.isoformat(),
                    "end_time": end_time.isoformat(),
                    "total_agents": len(self._agent_stats),
    #                 "active_agents": 0,
    #                 "total_requests": 0,
    #                 "total_errors": 0,
    #                 "avg_execution_time": 0.0,
    #                 "max_execution_time": 0.0,
    #                 "avg_memory_usage": 0.0,
    #                 "avg_cpu_usage": 0.0,
    #                 "alerts_generated": 0,
    #                 "alerts_resolved": 0,
    #                 "agent_breakdown": {}
    #             }

    execution_times = []
    memory_usages = []
    cpu_usages = []

    #             # Process each agent's metrics
    #             for agent_id, stats in self._agent_stats.items():
    #                 # Get metrics for time period
    metrics = self.get_metrics(agent_id, start_time=start_time, end_time=end_time)

    #                 if metrics:
    #                     # Agent is considered active if it has recent metrics
    summary["active_agents"] + = 1

    #                     # Collect execution times
    #                     exec_times = [m.value for m in metrics if m.metric_type == MetricType.EXECUTION_TIME]
    #                     if exec_times:
                            execution_times.extend(exec_times)

    #                     # Collect memory usages
    #                     mem_usages = [m.value for m in metrics if m.metric_type == MetricType.MEMORY_USAGE]
    #                     if mem_usages:
                            memory_usages.extend(mem_usages)

    #                     # Collect CPU usages
    #                     cpu_usages = [m.value for m in metrics if m.metric_type == MetricType.CPU_USAGE]
    #                     if cpu_usages:
                            cpu_usages.extend(cpu_usages)

    #                     # Count requests and errors
    #                     requests = [m for m in metrics if m.metric_type == MetricType.REQUEST_COUNT]
    #                     summary["total_requests"] += sum(m.value for m in requests)

    #                     errors = [m for m in metrics if m.metric_type == MetricType.ERROR_COUNT]
    #                     summary["total_errors"] += sum(m.value for m in errors)

    #                     # Agent breakdown
    summary["agent_breakdown"][agent_id] = {
    #                         "requests": sum(m.value for m in requests),
    #                         "errors": sum(m.value for m in errors),
    #                         "avg_execution_time": sum(exec_times) / len(exec_times) if exec_times else 0.0,
    #                         "max_execution_time": max(exec_times) if exec_times else 0.0,
    #                         "avg_memory_usage": sum(mem_usages) / len(mem_usages) if mem_usages else 0.0,
    #                         "avg_cpu_usage": sum(cpu_usages) / len(cpu_usages) if cpu_usages else 0.0
    #                     }

    #             # Calculate overall averages
    #             if execution_times:
    summary["avg_execution_time"] = math.divide(sum(execution_times), len(execution_times))
    summary["max_execution_time"] = max(execution_times)

    #             if memory_usages:
    summary["avg_memory_usage"] = math.divide(sum(memory_usages), len(memory_usages))

    #             if cpu_usages:
    summary["avg_cpu_usage"] = math.divide(sum(cpu_usages), len(cpu_usages))

    #             # Count alerts
    alerts = self.get_alerts(start_time=start_time, end_time=end_time)
    #             summary["alerts_generated"] = len([a for a in alerts if not a.resolved])
    #             summary["alerts_resolved"] = len([a for a in alerts if a.resolved])

    #             return summary
    #         except Exception as e:
    error_msg = f"Failed to generate performance summary: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 9005)

    #     def _monitoring_loop(self, interval_seconds: float) -> None:
    #         """Main monitoring loop for system metrics."""
    #         while not self._stop_event.wait(interval_seconds):
    #             try:
    #                 # Collect system metrics for all agents
                    self._collect_system_metrics()

    #                 # Check for stale alerts
                    self._check_stale_alerts()

    #                 # Update agent statistics
                    self._update_all_agent_stats()
    #             except Exception as e:
                    self.logger.error(f"Error in monitoring loop: {str(e)}")

    #     def _collect_system_metrics(self) -> None:
    #         """Collect system performance metrics."""
    #         try:
    #             # Get system memory and CPU usage
    memory_info = psutil.virtual_memory()
    cpu_percent = psutil.cpu_percent(interval=1)

    #             # Update metrics for all active agents
    #             for agent_id, stats in self._agent_stats.items():
    #                 # For now, use system-wide metrics
    #                 # In a real implementation, you'd track per-process metrics
                    self.record_resource_usage(
    agent_id = agent_id,
    memory_mb = math.multiply(memory_info.used / (1024, 1024),  # Convert to MB)
    cpu_percent = cpu_percent
    #                 )
    #         except Exception as e:
                self.logger.warning(f"Failed to collect system metrics: {str(e)}")

    #     def _update_agent_stats(self, agent_id: str, metric: PerformanceMetric) -> None:
    #         """Update agent statistics based on new metric."""
    #         # Initialize stats if not exists
    #         if agent_id not in self._agent_stats:
    self._agent_stats[agent_id] = AgentPerformanceStats(agent_id=agent_id)

    stats = self._agent_stats[agent_id]

    #         # Update based on metric type
    #         if metric.metric_type == MetricType.EXECUTION_TIME:
    stats.total_requests + = 1
    stats.avg_execution_time = (
                    (stats.avg_execution_time * (stats.total_requests - 1) + metric.value) / stats.total_requests
    #             )
    stats.max_execution_time = max(stats.max_execution_time, metric.value)
    stats.min_execution_time = min(stats.min_execution_time, metric.value)

    #         elif metric.metric_type == MetricType.ERROR_COUNT:
    stats.total_errors + = int(metric.value)

    #         elif metric.metric_type == MetricType.MEMORY_USAGE:
    stats.avg_memory_usage = (
                    (stats.avg_memory_usage + metric.value) / 2  # Simple moving average
    #             )
    stats.max_memory_usage = max(stats.max_memory_usage, metric.value)

    #         elif metric.metric_type == MetricType.CPU_USAGE:
    stats.avg_cpu_usage = (
                    (stats.avg_cpu_usage + metric.value) / 2  # Simple moving average
    #             )
    stats.max_cpu_usage = max(stats.max_cpu_usage, metric.value)

    stats.last_updated = datetime.now()

    #     def _update_all_agent_stats(self) -> None:
    #         """Update statistics for all agents."""
    #         for agent_id in self._agent_stats:
    #             # Calculate percentiles for response times
    #             metrics = [m for m in self._metrics[agent_id] if m.metric_type == MetricType.EXECUTION_TIME]
    #             if metrics:
    #                 values = sorted([m.value for m in metrics])
    #                 if len(values) >= 20:  # Need sufficient data for percentiles
    stats = self._agent_stats[agent_id]
    stats.response_time_p95 = math.multiply(values[int(len(values), 0.95)])
    stats.response_time_p99 = math.multiply(values[int(len(values), 0.99)])

    #     def _check_metric_alerts(self, agent_id: str, metric_type: MetricType, value: float) -> None:
    #         """Check if metric value triggers alerts."""
    #         if metric_type not in self._thresholds:
    #             return

    thresholds = self._thresholds[metric_type]

    #         # Check critical threshold
    #         if value >= thresholds["critical"]:
                self._create_alert(
    agent_id = agent_id,
    metric_type = metric_type,
    level = AlertLevel.CRITICAL,
    threshold = thresholds["critical"],
    current_value = value
    #             )
    #         # Check error threshold
    #         elif value >= thresholds["error"]:
                self._create_alert(
    agent_id = agent_id,
    metric_type = metric_type,
    level = AlertLevel.ERROR,
    threshold = thresholds["error"],
    current_value = value
    #             )
    #         # Check warning threshold
    #         elif value >= thresholds["warning"]:
                self._create_alert(
    agent_id = agent_id,
    metric_type = metric_type,
    level = AlertLevel.WARNING,
    threshold = thresholds["warning"],
    current_value = value
    #             )

    #     def _create_alert(
    #         self,
    #         agent_id: str,
    #         metric_type: MetricType,
    #         level: AlertLevel,
    #         threshold: float,
    #         current_value: float
    #     ) -> None:
    #         """Create a performance alert."""
    alert_id = str(uuid.uuid4())

    alert = PerformanceAlert(
    alert_id = alert_id,
    agent_id = agent_id,
    metric_type = metric_type,
    level = level,
    message = f"{level.value.upper()}: {metric_type.value} = {current_value} (threshold: {threshold})",
    threshold = threshold,
    current_value = current_value
    #         )

    self._alerts[alert_id] = alert

    #         # Notify callbacks
    #         for callback in self._alert_callbacks:
    #             try:
                    callback(alert)
    #             except Exception as e:
                    self.logger.error(f"Alert callback failed: {str(e)}")

            self.logger.warning(f"Performance alert: {alert.message}")

    #     def _check_stale_alerts(self) -> None:
    #         """Check for and resolve stale alerts."""
    #         try:
    stale_threshold = timedelta(hours=1)  # Consider alerts stale after 1 hour

    #             for alert_id, alert in list(self._alerts.items()):
    #                 if alert.resolved:
    #                     continue

    #                 if datetime.now() - alert.timestamp > stale_threshold:
    #                     # Auto-resolve stale alerts
    alert.resolved = True
    alert.resolved_at = datetime.now()

                        self.logger.info(f"Auto-resolved stale alert: {alert_id}")
    #         except Exception as e:
                self.logger.warning(f"Failed to check stale alerts: {str(e)}")


# Global performance monitor instance
_global_monitor: Optional[AgentPerformanceMonitor] = None


def get_agent_performance_monitor() -> AgentPerformanceMonitor:
#     """
#     Get the global agent performance monitor instance.

#     Returns:
#         AgentPerformanceMonitor instance
#     """
#     global _global_monitor
#     if _global_monitor is None:
_global_monitor = AgentPerformanceMonitor()
#     return _global_monitor


function track_agent_performance(agent_id: str, operation: str = "")
    #     """
    #     Decorator to track agent performance automatically.

    #     Args:
    #         agent_id: ID of the agent
    #         operation: Description of the operation

    #     Returns:
    #         Decorator function
    #     """
    #     def decorator(func):
    #         def wrapper(*args, **kwargs):
    monitor = get_agent_performance_monitor()
    start_time = time.time()

    #             try:
    result = math.multiply(func(, args, **kwargs))
    success = True
    #             except Exception as e:
    success = False
                    monitor.record_execution_time(
    agent_id = agent_id,
    execution_time = math.subtract(time.time(), start_time,)
    operation = operation,
    success = False
    #                 )
    #                 raise e

    #             # Record successful execution
                monitor.record_execution_time(
    agent_id = agent_id,
    execution_time = math.subtract(time.time(), start_time,)
    operation = operation,
    success = success
    #             )

    #             return result

    #         return wrapper
    #     return decorator