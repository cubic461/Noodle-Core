# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Monitor Module for NoodleCore
# Implements extensive performance monitoring and analysis
# """

import logging
import time
import threading
import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import json
import math
import statistics
import collections.deque

# Optional imports with fallbacks
try
    #     from ..noodlenet.integration.orchestrator import NoodleNetOrchestrator
    _NOODLENET_AVAILABLE = True
except ImportError
    _NOODLENET_AVAILABLE = False
    NoodleNetOrchestrator = None

try
    #     from .task_distributor import TaskDistributor, NodeInfo, Task, TaskResult
except ImportError
    #     class TaskDistributor:
    #         pass

    #     class NodeInfo:
    #         def __init__(self, node_id):
    self.node_id = node_id
    self.is_active = True
    self.cpu_usage = 0.0
    self.memory_usage = 0.0
    self.active_tasks = 0
    self.max_tasks = 10
    self.capabilities = []
    self.last_heartbeat = 0.0

    #     class Task:
    #         def __init__(self, task_id, task_type):
    self.task_id = task_id
    self.task_type = task_type
    self.priority = 1
    self.data = {}
    self.required_capabilities = []
    self.estimated_duration = 0.0

    #     class TaskResult:
    #         def __init__(self, task_id, node_id):
    self.task_id = task_id
    self.node_id = node_id
    self.success = False
    self.result = None
    self.execution_time = 0.0
    self.error = None
    self.completed_at = 0.0

logger = logging.getLogger(__name__)


class MetricType(Enum)
    #     """Type of performance metric"""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    TIMER = "timer"


class AlertSeverity(Enum)
    #     """Severity of performance alert"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


# @dataclass
class PerformanceMetric
    #     """A performance metric"""
    #     name: str
    #     metric_type: MetricType
    #     value: Union[int, float]
    timestamp: float = field(default_factory=time.time)
    tags: Dict[str, str] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'name': self.name,
    #             'type': self.metric_type.value,
    #             'value': self.value,
    #             'timestamp': self.timestamp,
    #             'tags': self.tags
    #         }


# @dataclass
class PerformanceAlert
    #     """A performance alert"""
    #     name: str
    #     severity: AlertSeverity
    #     message: str
    #     metric_name: str
    #     current_value: Union[int, float]
    #     threshold_value: Union[int, float]
    timestamp: float = field(default_factory=time.time)
    resolved: bool = False
    resolved_timestamp: Optional[float] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'name': self.name,
    #             'severity': self.severity.value,
    #             'message': self.message,
    #             'metric_name': self.metric_name,
    #             'current_value': self.current_value,
    #             'threshold_value': self.threshold_value,
    #             'timestamp': self.timestamp,
    #             'resolved': self.resolved,
    #             'resolved_timestamp': self.resolved_timestamp
    #         }


# @dataclass
class PerformanceThreshold
    #     """Threshold for performance alerting"""
    #     metric_name: str
    #     severity: AlertSeverity
    operator: str  # ">", "<", "> = ", "<=", "==", "!="
    #     threshold_value: Union[int, float]
    duration: float = 0.0  # Duration in seconds before alerting
    message_template: str = ""

    #     def check(self, value: Union[int, float]) -> bool:
    #         """Check if threshold is triggered"""
    #         if self.operator == ">":
    #             return value > self.threshold_value
    #         elif self.operator == "<":
    #             return value < self.threshold_value
    #         elif self.operator == ">=":
    return value > = self.threshold_value
    #         elif self.operator == "<=":
    return value < = self.threshold_value
    #         elif self.operator == "==":
    return value = = self.threshold_value
    #         elif self.operator == "!=":
    return value ! = self.threshold_value
    #         return False

    #     def format_message(self, metric_name: str, current_value: Union[int, float]) -> str:
    #         """Format alert message"""
    #         if self.message_template:
                return self.message_template.format(
    metric_name = metric_name,
    current_value = current_value,
    threshold_value = self.threshold_value
    #             )
    #         else:
                return f"{metric_name} is {current_value} (threshold: {self.operator} {self.threshold_value})"


# @dataclass
class PerformanceReport
    #     """Performance report"""
    #     report_id: str
    #     start_time: float
    #     end_time: float
    metrics: Dict[str, List[PerformanceMetric]] = field(default_factory=dict)
    alerts: List[PerformanceAlert] = field(default_factory=list)
    bottlenecks: List[Dict[str, Any]] = field(default_factory=list)
    trends: Dict[str, Any] = field(default_factory=dict)
    summary: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'report_id': self.report_id,
    #             'start_time': self.start_time,
    #             'end_time': self.end_time,
    #             'duration': self.end_time - self.start_time,
    #             'metrics_count': sum(len(metrics) for metrics in self.metrics.values()),
                'alerts_count': len(self.alerts),
                'bottlenecks_count': len(self.bottlenecks),
    #             'summary': self.summary
    #         }


class PerformanceMonitor
    #     """Performance monitor for distributed execution"""

    #     def __init__(self, task_distributor: TaskDistributor, noodlenet_orchestrator: Optional[NoodleNetOrchestrator] = None,
    metrics_retention: int = 10000, alert_check_interval: float = 10.0):
    #         """
    #         Initialize performance monitor

    #         Args:
    #             task_distributor: Task distributor instance
    #             noodlenet_orchestrator: NoodleNet orchestrator instance
    #             metrics_retention: Number of metrics to retain per metric name
    #             alert_check_interval: Interval for checking alerts in seconds
    #         """
    self.task_distributor = task_distributor
    self.noodlenet_orchestrator = noodlenet_orchestrator
    self.metrics_retention = metrics_retention
    self.alert_check_interval = alert_check_interval

    #         # Metrics storage
    self.metrics: Dict[str, deque] = {}
    self.metric_locks: Dict[str, threading.Lock] = {}

    #         # Thresholds and alerts
    self.thresholds: List[PerformanceThreshold] = []
    self.active_alerts: Dict[str, PerformanceAlert] = {}
    self.alert_history: List[PerformanceAlert] = []

    #         # Background threads
    self.metrics_collection_thread = None
    self.alert_check_thread = None
    self.report_generation_thread = None
    self.threads_running = False

    #         # Statistics
    self.statistics = {
    #             'total_metrics': 0,
    #             'total_alerts': 0,
    #             'active_alerts': 0,
    #             'reports_generated': 0,
    #             'bottlenecks_detected': 0,
    #             'metrics_collection_rate': 0.0,
    #             'last_metrics_update': 0.0
    #         }

    #         # Get local node ID
    self.local_node_id = ""
            self._get_local_node_id()

    #         # Initialize default thresholds
            self._initialize_default_thresholds()

    #     def _get_local_node_id(self):
    #         """Get local node ID from NoodleNet"""
    #         if self.noodlenet_orchestrator and hasattr(self.noodlenet_orchestrator, 'identity_manager'):
    self.local_node_id = self.noodlenet_orchestrator.identity_manager.local_node_id
    #         else:
    self.local_node_id = f"node_{int(time.time()) % 10000}"

    #     def _initialize_default_thresholds(self):
    #         """Initialize default performance thresholds"""
    #         # CPU usage thresholds
            self.thresholds.append(PerformanceThreshold(
    metric_name = "cpu_usage",
    severity = AlertSeverity.WARNING,
    operator = ">",
    threshold_value = 80.0,
    duration = 60.0,
    message_template = "High CPU usage: {current_value}% (threshold: >{threshold_value}%)"
    #         ))

            self.thresholds.append(PerformanceThreshold(
    metric_name = "cpu_usage",
    severity = AlertSeverity.CRITICAL,
    operator = ">",
    threshold_value = 95.0,
    duration = 30.0,
    message_template = "Critical CPU usage: {current_value}% (threshold: >{threshold_value}%)"
    #         ))

    #         # Memory usage thresholds
            self.thresholds.append(PerformanceThreshold(
    metric_name = "memory_usage",
    severity = AlertSeverity.WARNING,
    operator = ">",
    threshold_value = 80.0,
    duration = 60.0,
    message_template = "High memory usage: {current_value}% (threshold: >{threshold_value}%)"
    #         ))

            self.thresholds.append(PerformanceThreshold(
    metric_name = "memory_usage",
    severity = AlertSeverity.CRITICAL,
    operator = ">",
    threshold_value = 95.0,
    duration = 30.0,
    message_template = "Critical memory usage: {current_value}% (threshold: >{threshold_value}%)"
    #         ))

    #         # Task queue size thresholds
            self.thresholds.append(PerformanceThreshold(
    metric_name = "task_queue_size",
    severity = AlertSeverity.WARNING,
    operator = ">",
    threshold_value = 100,
    duration = 120.0,
    message_template = "Large task queue: {current_value} tasks (threshold: >{threshold_value})"
    #         ))

    #         # Response time thresholds
            self.thresholds.append(PerformanceThreshold(
    metric_name = "average_response_time",
    severity = AlertSeverity.WARNING,
    operator = ">",
    threshold_value = 500.0,
    duration = 60.0,
    message_template = "High response time: {current_value}ms (threshold: >{threshold_value}ms)"
    #         ))

    #         # Error rate thresholds
            self.thresholds.append(PerformanceThreshold(
    metric_name = "error_rate",
    severity = AlertSeverity.WARNING,
    operator = ">",
    threshold_value = 5.0,
    duration = 60.0,
    message_template = "High error rate: {current_value}% (threshold: >{threshold_value}%)"
    #         ))

    #     def start(self):
    #         """Start performance monitoring background threads"""
    #         if self.threads_running:
    #             return

    self.threads_running = True

    #         # Start metrics collection thread
    self.metrics_collection_thread = threading.Thread(target=self._metrics_collection_worker)
    self.metrics_collection_thread.daemon = True
            self.metrics_collection_thread.start()

    #         # Start alert check thread
    self.alert_check_thread = threading.Thread(target=self._alert_check_worker)
    self.alert_check_thread.daemon = True
            self.alert_check_thread.start()

    #         # Start report generation thread
    self.report_generation_thread = threading.Thread(target=self._report_generation_worker)
    self.report_generation_thread.daemon = True
            self.report_generation_thread.start()

            logger.info("Performance monitor started")

    #     def stop(self):
    #         """Stop performance monitoring background threads"""
    #         if not self.threads_running:
    #             return

    self.threads_running = False

    #         # Wait for threads to stop
    #         for thread in [self.metrics_collection_thread, self.alert_check_thread, self.report_generation_thread]:
    #             if thread and thread.is_alive():
    thread.join(timeout = 5.0)

            logger.info("Performance monitor stopped")

    #     def record_metric(self, name: str, value: Union[int, float], metric_type: MetricType = MetricType.GAUGE,
    tags: Dict[str, str] = None):
    #         """
    #         Record a performance metric

    #         Args:
    #             name: Metric name
    #             value: Metric value
    #             metric_type: Type of metric
    #             tags: Additional tags
    #         """
    #         # Create metric
    metric = PerformanceMetric(
    name = name,
    metric_type = metric_type,
    value = value,
    tags = tags or {}
    #         )

    #         # Get or create metric lock
    #         if name not in self.metric_locks:
    self.metric_locks[name] = threading.Lock()

    #         # Add metric to storage
    #         with self.metric_locks[name]:
    #             if name not in self.metrics:
    self.metrics[name] = deque(maxlen=self.metrics_retention)

                self.metrics[name].append(metric)

    #             # Update statistics
    self.statistics['total_metrics'] + = 1
    self.statistics['last_metrics_update'] = time.time()

    #     def get_metrics(self, name: str, since: Optional[float] = None, limit: Optional[int] = None) -> List[PerformanceMetric]:
    #         """
    #         Get metrics for a specific name

    #         Args:
    #             name: Metric name
    #             since: Get metrics since this timestamp
    #             limit: Maximum number of metrics to return

    #         Returns:
    #             List of metrics
    #         """
    #         if name not in self.metrics:
    #             return []

    #         with self.metric_locks[name]:
    metrics = list(self.metrics[name])

    #         # Filter by timestamp
    #         if since is not None:
    #             metrics = [m for m in metrics if m.timestamp >= since]

    #         # Limit results
    #         if limit is not None:
    metrics = math.subtract(metrics[, limit:])

    #         return metrics

    #     def get_latest_metric(self, name: str) -> Optional[PerformanceMetric]:
    #         """
    #         Get the latest metric for a specific name

    #         Args:
    #             name: Metric name

    #         Returns:
    #             Latest metric or None
    #         """
    metrics = self.get_metrics(name, limit=1)
    #         return metrics[0] if metrics else None

    #     def add_threshold(self, threshold: PerformanceThreshold):
    #         """
    #         Add a performance threshold

    #         Args:
    #             threshold: Threshold to add
    #         """
            self.thresholds.append(threshold)
    #         logger.info(f"Added threshold for {threshold.metric_name}: {threshold.operator} {threshold.threshold_value}")

    #     def remove_threshold(self, metric_name: str, severity: AlertSeverity = None):
    #         """
    #         Remove performance thresholds

    #         Args:
    #             metric_name: Metric name
    #             severity: Severity to filter by (None for all)
    #         """
    original_count = len(self.thresholds)

    #         if severity is None:
    #             self.thresholds = [t for t in self.thresholds if t.metric_name != metric_name]
    #         else:
    #             self.thresholds = [t for t in self.thresholds
    #                               if not (t.metric_name == metric_name and t.severity == severity)]

    removed_count = math.subtract(original_count, len(self.thresholds))
    #         logger.info(f"Removed {removed_count} thresholds for {metric_name}")

    #     def get_active_alerts(self) -> List[PerformanceAlert]:
    #         """
    #         Get active alerts

    #         Returns:
    #             List of active alerts
    #         """
            return list(self.active_alerts.values())

    #     def get_alert_history(self, since: Optional[float] = None, limit: Optional[int] = None) -> List[PerformanceAlert]:
    #         """
    #         Get alert history

    #         Args:
    #             since: Get alerts since this timestamp
    #             limit: Maximum number of alerts to return

    #         Returns:
    #             List of alerts
    #         """
    alerts = self.alert_history.copy()

    #         # Filter by timestamp
    #         if since is not None:
    #             alerts = [a for a in alerts if a.timestamp >= since]

            # Sort by timestamp (most recent first)
    alerts.sort(key = lambda a: a.timestamp, reverse=True)

    #         # Limit results
    #         if limit is not None:
    alerts = alerts[:limit]

    #         return alerts

    #     def resolve_alert(self, alert_name: str):
    #         """
    #         Resolve an active alert

    #         Args:
    #             alert_name: Name of the alert to resolve
    #         """
    #         if alert_name in self.active_alerts:
    alert = self.active_alerts[alert_name]
    alert.resolved = True
    alert.resolved_timestamp = time.time()

    #             # Move to history
                self.alert_history.append(alert)

    #             # Remove from active alerts
    #             del self.active_alerts[alert_name]

    #             # Update statistics
    self.statistics['active_alerts'] = len(self.active_alerts)

                logger.info(f"Resolved alert: {alert_name}")

    #     def generate_report(self, start_time: Optional[float] = None, end_time: Optional[float] = None) -> PerformanceReport:
    #         """
    #         Generate a performance report

    #         Args:
    #             start_time: Start time for the report (default: 1 hour ago)
    #             end_time: End time for the report (default: now)

    #         Returns:
    #             Performance report
    #         """
    current_time = time.time()

    #         if start_time is None:
    start_time = math.subtract(current_time, 3600.0  # 1 hour ago)

    #         if end_time is None:
    end_time = current_time

    #         # Create report
    report_id = f"report_{int(current_time)}"
    report = PerformanceReport(
    report_id = report_id,
    start_time = start_time,
    end_time = end_time
    #         )

    #         # Collect metrics
    #         for name in self.metrics:
    #             with self.metric_locks[name]:
    #                 metrics = [m for m in self.metrics[name] if start_time <= m.timestamp <= end_time]
    #                 if metrics:
    report.metrics[name] = metrics

    #         # Collect alerts
    #         report.alerts = [a for a in self.alert_history if start_time <= a.timestamp <= end_time]

    #         # Analyze metrics for trends and bottlenecks
    report.trends = self._analyze_trends(report.metrics)
    report.bottlenecks = self._detect_bottlenecks(report.metrics)

    #         # Generate summary
    report.summary = self._generate_summary(report)

    #         # Update statistics
    self.statistics['reports_generated'] + = 1
    self.statistics['bottlenecks_detected'] + = len(report.bottlenecks)

    #         return report

    #     def _analyze_trends(self, metrics: Dict[str, List[PerformanceMetric]]) -> Dict[str, Any]:
    #         """Analyze trends in metrics"""
    trends = {}

    #         for name, metric_list in metrics.items():
    #             if not metric_list or len(metric_list) < 2:
    #                 continue

    #             # Extract values
    #             values = [m.value for m in metric_list]
    #             timestamps = [m.timestamp for m in metric_list]

    #             # Calculate trend
    #             if len(values) >= 2:
    #                 # Simple linear regression
    n = len(values)
    x_sum = sum(range(n))
    y_sum = sum(values)
    #                 xy_sum = sum(i * values[i] for i in range(n))
    #                 x2_sum = sum(i * i for i in range(n))

    #                 # Calculate slope
    slope = math.multiply((n, xy_sum - x_sum * y_sum) / (n * x2_sum - x_sum * x_sum))

    #                 # Determine trend direction
    #                 if abs(slope) < 0.01:
    trend_direction = "stable"
    #                 elif slope > 0:
    trend_direction = "increasing"
    #                 else:
    trend_direction = "decreasing"

    trends[name] = {
    #                     'direction': trend_direction,
    #                     'slope': slope,
                        'min': min(values),
                        'max': max(values),
                        'avg': statistics.mean(values),
                        'median': statistics.median(values),
    #                     'std_dev': statistics.stdev(values) if len(values) > 1 else 0.0
    #                 }

    #         return trends

    #     def _detect_bottlenecks(self, metrics: Dict[str, List[PerformanceMetric]]) -> List[Dict[str, Any]]:
    #         """Detect performance bottlenecks"""
    bottlenecks = []

    #         # Check for high CPU usage
    #         if "cpu_usage" in metrics:
    cpu_metrics = metrics["cpu_usage"]
    #             if cpu_metrics:
    #                 avg_cpu = statistics.mean([m.value for m in cpu_metrics])
    #                 max_cpu = max(m.value for m in cpu_metrics)

    #                 if avg_cpu > 80.0:
                        bottlenecks.append({
    #                         'type': 'cpu_bottleneck',
    #                         'severity': 'high' if avg_cpu > 90.0 else 'medium',
                            'description': f"High average CPU usage: {avg_cpu:.2f}% (max: {max_cpu:.2f}%)",
    #                         'metric': 'cpu_usage',
    #                         'value': avg_cpu
    #                     })

    #         # Check for high memory usage
    #         if "memory_usage" in metrics:
    mem_metrics = metrics["memory_usage"]
    #             if mem_metrics:
    #                 avg_mem = statistics.mean([m.value for m in mem_metrics])
    #                 max_mem = max(m.value for m in mem_metrics)

    #                 if avg_mem > 80.0:
                        bottlenecks.append({
    #                         'type': 'memory_bottleneck',
    #                         'severity': 'high' if avg_mem > 90.0 else 'medium',
                            'description': f"High average memory usage: {avg_mem:.2f}% (max: {max_mem:.2f}%)",
    #                         'metric': 'memory_usage',
    #                         'value': avg_mem
    #                     })

    #         # Check for large task queue
    #         if "task_queue_size" in metrics:
    queue_metrics = metrics["task_queue_size"]
    #             if queue_metrics:
    #                 avg_queue = statistics.mean([m.value for m in queue_metrics])
    #                 max_queue = max(m.value for m in queue_metrics)

    #                 if avg_queue > 50:
                        bottlenecks.append({
    #                         'type': 'queue_bottleneck',
    #                         'severity': 'high' if avg_queue > 100 else 'medium',
                            'description': f"Large average task queue: {avg_queue:.2f} tasks (max: {max_queue:.2f})",
    #                         'metric': 'task_queue_size',
    #                         'value': avg_queue
    #                     })

    #         # Check for high response time
    #         if "average_response_time" in metrics:
    rt_metrics = metrics["average_response_time"]
    #             if rt_metrics:
    #                 avg_rt = statistics.mean([m.value for m in rt_metrics])
    #                 max_rt = max(m.value for m in rt_metrics)

    #                 if avg_rt > 200.0:
                        bottlenecks.append({
    #                         'type': 'response_time_bottleneck',
    #                         'severity': 'high' if avg_rt > 500.0 else 'medium',
                            'description': f"High average response time: {avg_rt:.2f}ms (max: {max_rt:.2f}ms)",
    #                         'metric': 'average_response_time',
    #                         'value': avg_rt
    #                     })

    #         # Check for high error rate
    #         if "error_rate" in metrics:
    error_metrics = metrics["error_rate"]
    #             if error_metrics:
    #                 avg_error = statistics.mean([m.value for m in error_metrics])
    #                 max_error = max(m.value for m in error_metrics)

    #                 if avg_error > 1.0:
                        bottlenecks.append({
    #                         'type': 'error_rate_bottleneck',
    #                         'severity': 'high' if avg_error > 5.0 else 'medium',
                            'description': f"High average error rate: {avg_error:.2f}% (max: {max_error:.2f}%)",
    #                         'metric': 'error_rate',
    #                         'value': avg_error
    #                     })

    #         return bottlenecks

    #     def _generate_summary(self, report: PerformanceReport) -> Dict[str, Any]:
    #         """Generate summary of the report"""
    summary = {
    #             'total_metrics': sum(len(metrics) for metrics in report.metrics.values()),
                'total_alerts': len(report.alerts),
                'total_bottlenecks': len(report.bottlenecks),
    #             'critical_alerts': len([a for a in report.alerts if a.severity == AlertSeverity.CRITICAL]),
    #             'warning_alerts': len([a for a in report.alerts if a.severity == AlertSeverity.WARNING]),
    #             'high_severity_bottlenecks': len([b for b in report.bottlenecks if b.get('severity') == 'high']),
    #             'top_metrics': {}
    #         }

    #         # Get top metrics by activity
    #         metric_counts = [(name, len(metrics)) for name, metrics in report.metrics.items()]
    metric_counts.sort(key = lambda x: x[1], reverse=True)
    summary['top_metrics'] = metric_counts[:5]

    #         return summary

    #     def _metrics_collection_worker(self):
    #         """Background worker for collecting metrics"""
    last_collection_time = 0.0

    #         while self.threads_running:
    #             try:
    current_time = time.time()

    #                 # Calculate collection rate
    #                 if last_collection_time > 0:
    time_diff = math.subtract(current_time, last_collection_time)
    #                     if time_diff > 0:
    self.statistics['metrics_collection_rate'] = math.divide(1.0, time_diff)

    last_collection_time = current_time

    #                 # Collect system metrics
                    self._collect_system_metrics()

    #                 # Collect task distributor metrics
                    self._collect_task_distributor_metrics()

    #                 # Collect node metrics
                    self._collect_node_metrics()

    #                 # Sleep until next collection
                    time.sleep(5.0)
    #             except Exception as e:
                    logger.error(f"Error in metrics collection worker: {e}")
                    time.sleep(5.0)

    #     def _collect_system_metrics(self):
    #         """Collect system-level metrics"""
    #         # Get task distributor statistics
    task_stats = self.task_distributor.get_statistics()

    #         # Record task queue size
    queue_size = task_stats.get('queued_tasks_count', 0)
            self.record_metric("task_queue_size", queue_size, MetricType.GAUGE)

    #         # Record active tasks
    active_tasks = task_stats.get('active_tasks_count', 0)
            self.record_metric("active_tasks", active_tasks, MetricType.GAUGE)

    #         # Record completed tasks
    completed_tasks = task_stats.get('completed_tasks_count', 0)
            self.record_metric("completed_tasks", completed_tasks, MetricType.COUNTER)

    #         # Record failed tasks
    failed_tasks = task_stats.get('total_tasks_failed', 0)
            self.record_metric("failed_tasks", failed_tasks, MetricType.COUNTER)

    #         # Calculate and record task completion rate
    total_tasks = task_stats.get('total_tasks_distributed', 0)
    #         if total_tasks > 0:
    completion_rate = math.multiply((completed_tasks / total_tasks), 100.0)
                self.record_metric("task_completion_rate", completion_rate, MetricType.GAUGE)

    #         # Calculate and record error rate
    #         if total_tasks > 0:
    error_rate = math.multiply((failed_tasks / total_tasks), 100.0)
                self.record_metric("error_rate", error_rate, MetricType.GAUGE)

    #         # Record average task duration
    avg_duration = task_stats.get('average_task_duration', 0.0)
            self.record_metric("average_task_duration", avg_duration * 1000.0, MetricType.GAUGE)  # Convert to ms

    #     def _collect_task_distributor_metrics(self):
    #         """Collect task distributor metrics"""
    #         # Get node statistics
    node_stats = self.task_distributor.get_statistics()

    #         # Record node count
    node_count = node_stats.get('nodes_count', 0)
            self.record_metric("node_count", node_count, MetricType.GAUGE)

    #         # Record active node count
    active_node_count = node_stats.get('active_nodes_count', 0)
            self.record_metric("active_node_count", active_node_count, MetricType.GAUGE)

    #         # Calculate and record node utilization
    #         if node_count > 0:
    node_utilization = math.multiply((active_node_count / node_count), 100.0)
                self.record_metric("node_utilization", node_utilization, MetricType.GAUGE)

    #     def _collect_node_metrics(self):
    #         """Collect node-specific metrics"""
    #         for node_id, node in self.task_distributor.nodes.items():
    #             # Record CPU usage
    cpu_usage = node.cpu_usage
                self.record_metric(
    #                 "cpu_usage",
    #                 cpu_usage,
    #                 MetricType.GAUGE,
    tags = {"node_id": node_id}
    #             )

    #             # Record memory usage
    memory_usage = node.memory_usage
                self.record_metric(
    #                 "memory_usage",
    #                 memory_usage,
    #                 MetricType.GAUGE,
    tags = {"node_id": node_id}
    #             )

    #             # Record active tasks
    active_tasks = node.active_tasks
                self.record_metric(
    #                 "active_tasks",
    #                 active_tasks,
    #                 MetricType.GAUGE,
    tags = {"node_id": node_id}
    #             )

    #             # Calculate and record task utilization
    #             if node.max_tasks > 0:
    task_utilization = math.multiply((active_tasks / node.max_tasks), 100.0)
                    self.record_metric(
    #                     "task_utilization",
    #                     task_utilization,
    #                     MetricType.GAUGE,
    tags = {"node_id": node_id}
    #                 )

    #             # Calculate and record load score
    load_score = node.get_load_score()
                self.record_metric(
    #                 "load_score",
    #                 load_score * 100.0,  # Convert to percentage
    #                 MetricType.GAUGE,
    tags = {"node_id": node_id}
    #             )

    #     def _alert_check_worker(self):
    #         """Background worker for checking alerts"""
    #         while self.threads_running:
    #             try:
    #                 # Check each threshold
    #                 for threshold in self.thresholds:
                        self._check_threshold(threshold)

    #                 # Update statistics
    self.statistics['active_alerts'] = len(self.active_alerts)

    #                 # Sleep until next check
                    time.sleep(self.alert_check_interval)
    #             except Exception as e:
                    logger.error(f"Error in alert check worker: {e}")
                    time.sleep(self.alert_check_interval)

    #     def _check_threshold(self, threshold: PerformanceThreshold):
    #         """Check if a threshold is triggered"""
    #         # Get latest metric
    latest_metric = self.get_latest_metric(threshold.metric_name)
    #         if not latest_metric:
    #             return

    #         # Check if threshold is triggered
    #         if threshold.check(latest_metric.value):
    #             # Check if alert already exists
    alert_key = f"{threshold.metric_name}_{threshold.severity.value}"

    #             if alert_key not in self.active_alerts:
    #                 # Create new alert
    alert = PerformanceAlert(
    name = alert_key,
    severity = threshold.severity,
    message = threshold.format_message(threshold.metric_name, latest_metric.value),
    metric_name = threshold.metric_name,
    current_value = latest_metric.value,
    threshold_value = threshold.threshold_value
    #                 )

    #                 # Add to active alerts
    self.active_alerts[alert_key] = alert

    #                 # Update statistics
    self.statistics['total_alerts'] + = 1

                    logger.warning(f"Alert triggered: {alert.message}")
    #         else:
    #             # Check if alert should be resolved
    alert_key = f"{threshold.metric_name}_{threshold.severity.value}"
    #             if alert_key in self.active_alerts:
                    self.resolve_alert(alert_key)

    #     def _report_generation_worker(self):
    #         """Background worker for generating reports"""
    #         while self.threads_running:
    #             try:
    #                 # Generate hourly report
    current_time = time.time()
    start_time = math.subtract(current_time, 3600.0  # 1 hour ago)

    report = self.generate_report(start_time, current_time)

    #                 # Log summary
                    logger.info(f"Generated performance report: {report.summary}")

    #                 # Sleep until next report
                    time.sleep(3600.0)  # 1 hour
    #             except Exception as e:
                    logger.error(f"Error in report generation worker: {e}")
                    time.sleep(300.0)  # 5 minutes

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get performance monitor statistics

    #         Returns:
    #             Statistics dictionary
    #         """
    stats = self.statistics.copy()
            stats.update({
                'metrics_count': len(self.metrics),
                'thresholds_count': len(self.thresholds),
    #             'threads_running': self.threads_running
    #         })
    #         return stats