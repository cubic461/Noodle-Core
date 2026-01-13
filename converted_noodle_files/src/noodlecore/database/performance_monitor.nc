# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Performance Monitor
 = ========================================

# Performance monitoring utilities for database operations.
# Provides comprehensive performance metrics and analysis.

# Implements database standards:
# - Query performance tracking
# - Resource usage monitoring
# - Performance alerting
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import threading
import psutil
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import collections.defaultdict,

import .errors.(
#     DatabaseError, QueryError, ConnectionError
# )


class MetricType(Enum)
    #     """Types of performance metrics."""
    QUERY_TIME = "query_time"
    CONNECTION_COUNT = "connection_count"
    MEMORY_USAGE = "memory_usage"
    CPU_USAGE = "cpu_usage"
    DISK_IO = "disk_io"
    CACHE_HIT_RATE = "cache_hit_rate"
    SLOW_QUERY = "slow_query"
    ERROR_RATE = "error_rate"


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
    #     metric_type: MetricType
    #     value: float
    #     unit: str
    timestamp: datetime = field(default_factory=datetime.now)
    tags: Dict[str, str] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class QueryPerformance
    #     """Query performance data."""
    #     query_id: str
    #     sql: str
    #     execution_time: float
    rows_affected: Optional[int] = None
    rows_returned: Optional[int] = None
    timestamp: datetime = field(default_factory=datetime.now)
    parameters: Optional[List[Any]] = None
    error: Optional[str] = None
    database: Optional[str] = None
    table: Optional[str] = None
    operation_type: Optional[str] = None


# @dataclass
class PerformanceAlert
    #     """Performance alert."""
    #     alert_id: str
    #     metric_type: MetricType
    #     level: AlertLevel
    #     message: str
    #     threshold: float
    #     current_value: float
    timestamp: datetime = field(default_factory=datetime.now)
    resolved: bool = False
    resolved_at: Optional[datetime] = None


class DatabasePerformanceMonitor
    #     """
    #     Performance monitor for database operations.

    #     Features:
    #     - Query performance tracking
    #     - Resource usage monitoring
    #     - Performance alerting
    #     - Historical data analysis
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, backend=None, max_history_size: int = 10000):
    #         """
    #         Initialize performance monitor.

    #         Args:
    #             backend: Optional database backend instance
    #             max_history_size: Maximum number of metrics to keep in memory
    #         """
    self.backend = backend
    self.max_history_size = max_history_size
    self.logger = logging.getLogger('noodlecore.database.performance_monitor')

    #         # Performance data storage
    self._metrics: Dict[MetricType, deque] = defaultdict(lambda: deque(maxlen=max_history_size))
    self._queries: deque = deque(maxlen=max_history_size)
    self._alerts: Dict[str, PerformanceAlert] = {}

    #         # Monitoring state
    self._monitoring_active = False
    self._monitoring_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()

    #         # Performance thresholds
    self._thresholds: Dict[MetricType, Dict[str, float]] = {
    #             MetricType.QUERY_TIME: {"warning": 1.0, "error": 3.0, "critical": 5.0},
    #             MetricType.CONNECTION_COUNT: {"warning": 15.0, "error": 18.0, "critical": 20.0},
    #             MetricType.MEMORY_USAGE: {"warning": 70.0, "error": 85.0, "critical": 95.0},
    #             MetricType.CPU_USAGE: {"warning": 70.0, "error": 85.0, "critical": 95.0},
    #             MetricType.ERROR_RATE: {"warning": 1.0, "error": 5.0, "critical": 10.0}
    #         }

            self.logger.info("Database performance monitor initialized")

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
    raise DatabaseError("Monitoring is already active", error_code = 6060)

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
    error_msg = f"Failed to start monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6061)

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
    self._monitoring_thread.join(timeout = 10.0)

                self.logger.info("Stopped performance monitoring")
    #         except Exception as e:
    error_msg = f"Failed to stop monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6062)

    #     def record_query_performance(
    #         self,
    #         sql: str,
    #         execution_time: float,
    rows_affected: Optional[int] = None,
    rows_returned: Optional[int] = None,
    parameters: Optional[List[Any]] = None,
    error: Optional[str] = None
    #     ) -> str:
    #         """
    #         Record query performance data.

    #         Args:
    #             sql: SQL query
    #             execution_time: Execution time in seconds
    #             rows_affected: Number of rows affected
    #             rows_returned: Number of rows returned
    #             parameters: Query parameters
    #             error: Error message if query failed

    #         Returns:
    #             Query ID
    #         """
    #         try:
    #             # Generate query ID
    query_id = str(uuid.uuid4())

    #             # Extract table and operation type from SQL
    table, operation_type = self._parse_sql_query(sql)

    #             # Create query performance record
    query_perf = QueryPerformance(
    query_id = query_id,
    sql = sql,
    execution_time = execution_time,
    rows_affected = rows_affected,
    rows_returned = rows_returned,
    parameters = parameters,
    error = error,
    database = self._get_database_name(),
    table = table,
    operation_type = operation_type
    #             )

    #             # Store query performance
                self._queries.append(query_perf)

    #             # Record query time metric
                self.record_metric(
    #                 MetricType.QUERY_TIME,
    #                 execution_time,
    #                 "seconds",
    tags = {
    #                     "operation": operation_type or "unknown",
    #                     "table": table or "unknown",
    #                     "status": "error" if error else "success"
    #                 }
    #             )

    #             # Check for slow query alert
    #             if execution_time > self._thresholds[MetricType.QUERY_TIME]["warning"]:
                    self._create_alert(
    #                     MetricType.SLOW_QUERY,
    #                     AlertLevel.WARNING if execution_time < self._thresholds[MetricType.QUERY_TIME]["error"] else AlertLevel.ERROR,
    #                     f"Slow query detected: {execution_time:.3f}s",
    #                     execution_time,
    #                     {
    #                         "query_id": query_id,
    #                         "sql": sql,
    #                         "table": table,
    #                         "operation": operation_type
    #                     }
    #                 )

    #             return query_id
    #         except Exception as e:
    error_msg = f"Failed to record query performance: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6063)

    #     def record_metric(
    #         self,
    #         metric_type: MetricType,
    #         value: float,
    #         unit: str,
    tags: Optional[Dict[str, str]] = None,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -> str:
    #         """
    #         Record a performance metric.

    #         Args:
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
    metric_type = metric_type,
    value = value,
    unit = unit,
    tags = tags or {},
    metadata = metadata or {}
    #             )

    #             # Store metric
                self._metrics[metric_type].append(metric)

    #             # Check for alerts
                self._check_metric_alerts(metric_type, value)

    #             return metric_id
    #         except Exception as e:
    error_msg = f"Failed to record metric: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6064)

    #     def get_metrics(
    #         self,
    metric_type: Optional[MetricType] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    tags: Optional[Dict[str, str]] = None
    #     ) -> List[PerformanceMetric]:
    #         """
    #         Get performance metrics.

    #         Args:
    #             metric_type: Optional filter by metric type
    #             start_time: Optional start time filter
    #             end_time: Optional end time filter
    #             tags: Optional tag filters

    #         Returns:
    #             List of metrics
    #         """
    metrics = []

    #         # Filter by metric type
    #         if metric_type:
    metric_list = list(self._metrics[metric_type])
    #         else:
    #             # Combine all metrics
    metric_list = []
    #             for mlist in self._metrics.values():
                    metric_list.extend(mlist)

    #         # Apply filters
    #         for metric in metric_list:
    #             # Time filter
    #             if start_time and metric.timestamp < start_time:
    #                 continue
    #             if end_time and metric.timestamp > end_time:
    #                 continue

    #             # Tag filter
    #             if tags:
    #                 if not all(metric.tags.get(k) == v for k, v in tags.items()):
    #                     continue

                metrics.append(metric)

    #         # Sort by timestamp
    metrics.sort(key = lambda m: m.timestamp, reverse=True)

    #         return metrics

    #     def get_query_performance(
    #         self,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    operation_type: Optional[str] = None,
    table: Optional[str] = None,
    min_execution_time: Optional[float] = None
    #     ) -> List[QueryPerformance]:
    #         """
    #         Get query performance data.

    #         Args:
    #             start_time: Optional start time filter
    #             end_time: Optional end time filter
    #             operation_type: Optional operation type filter
    #             table: Optional table filter
    #             min_execution_time: Optional minimum execution time filter

    #         Returns:
    #             List of query performance data
    #         """
    queries = list(self._queries)

    #         # Apply filters
    #         for query in queries:
    #             # Time filter
    #             if start_time and query.timestamp < start_time:
    #                 continue
    #             if end_time and query.timestamp > end_time:
    #                 continue

    #             # Operation type filter
    #             if operation_type and query.operation_type != operation_type:
    #                 continue

    #             # Table filter
    #             if table and query.table != table:
    #                 continue

    #             # Execution time filter
    #             if min_execution_time and query.execution_time < min_execution_time:
    #                 continue

    #         # Sort by timestamp
    queries.sort(key = lambda q: q.timestamp, reverse=True)

    #         return queries

    #     def get_alerts(
    #         self,
    level: Optional[AlertLevel] = None,
    resolved: Optional[bool] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None
    #     ) -> List[PerformanceAlert]:
    #         """
    #         Get performance alerts.

    #         Args:
    #             level: Optional alert level filter
    #             resolved: Optional resolved status filter
    #             start_time: Optional start time filter
    #             end_time: Optional end time filter

    #         Returns:
    #             List of alerts
    #         """
    alerts = list(self._alerts.values())

    #         # Apply filters
    #         for alert in alerts:
    #             # Level filter
    #             if level and alert.level != level:
    #                 continue

    #             # Resolved filter
    #             if resolved is not None and alert.resolved != resolved:
    #                 continue

    #             # Time filter
    #             if start_time and alert.timestamp < start_time:
    #                 continue
    #             if end_time and alert.timestamp > end_time:
    #                 continue

    #         # Sort by timestamp
    alerts.sort(key = lambda a: a.timestamp, reverse=True)

    #         return alerts

    #     def resolve_alert(self, alert_id: str) -> bool:
    #         """
    #         Resolve a performance alert.

    #         Args:
    #             alert_id: Alert ID to resolve

    #         Returns:
    #             True if resolved successfully

    #         Raises:
    #             DatabaseError: If alert cannot be resolved
    #         """
    #         try:
    #             if alert_id not in self._alerts:
    raise DatabaseError(f"Alert {alert_id} not found", error_code = 6065)

    alert = self._alerts[alert_id]
    alert.resolved = True
    alert.resolved_at = datetime.now()

                self.logger.info(f"Resolved alert: {alert_id}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to resolve alert {alert_id}: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6066)

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

    #             # Get metrics for the time period
    metrics = self.get_metrics(start_time=start_time, end_time=end_time)
    queries = self.get_query_performance(start_time=start_time, end_time=end_time)

    #             # Calculate summary statistics
    summary = {
    #                 "period_hours": hours,
                    "start_time": start_time.isoformat(),
                    "end_time": end_time.isoformat(),
                    "total_queries": len(queries),
    #                 "avg_query_time": 0.0,
    #                 "max_query_time": 0.0,
    #                 "slow_queries": 0,
    #                 "failed_queries": 0,
    #                 "metrics": {}
    #             }

    #             if queries:
    #                 # Query statistics
    #                 execution_times = [q.execution_time for q in queries]
    summary["avg_query_time"] = math.divide(sum(execution_times), len(execution_times))
    summary["max_query_time"] = max(execution_times)
    #                 summary["slow_queries"] = len([q for q in queries if q.execution_time > self._thresholds[MetricType.QUERY_TIME]["warning"]])
    #                 summary["failed_queries"] = len([q for q in queries if q.error])

    #             # Metric statistics
    #             for metric_type in MetricType:
    #                 type_metrics = [m for m in metrics if m.metric_type == metric_type]
    #                 if type_metrics:
    #                     values = [m.value for m in type_metrics]
    summary["metrics"][metric_type.value] = {
                            "count": len(values),
                            "avg": sum(values) / len(values),
                            "min": min(values),
                            "max": max(values),
    #                         "latest": values[-1] if values else None
    #                     }

    #             return summary
    #         except Exception as e:
    error_msg = f"Failed to generate performance summary: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6067)

    #     def _monitoring_loop(self, interval_seconds: float) -> None:
    #         """Main monitoring loop."""
    #         while not self._stop_event.wait(interval_seconds):
    #             try:
    #                 # Collect system metrics
                    self._collect_system_metrics()

    #                 # Check for stale alerts
                    self._check_stale_alerts()
    #             except Exception as e:
                    self.logger.error(f"Error in monitoring loop: {str(e)}")

    #     def _collect_system_metrics(self) -> None:
    #         """Collect system performance metrics."""
    #         try:
    #             # Memory usage
    memory_percent = psutil.virtual_memory().percent
                self.record_metric(MetricType.MEMORY_USAGE, memory_percent, "percent")

    #             # CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)
                self.record_metric(MetricType.CPU_USAGE, cpu_percent, "percent")

    #             # Disk I/O
    disk_io = psutil.disk_io_counters()
    #             if disk_io:
    read_bytes = disk_io.read_bytes
    write_bytes = disk_io.write_bytes
                    self.record_metric(MetricType.DISK_IO, read_bytes + write_bytes, "bytes")

    #             # Connection count (if backend available)
    #             if self.backend and hasattr(self.backend, 'get_connection_count'):
    connection_count = self.backend.get_connection_count()
                    self.record_metric(MetricType.CONNECTION_COUNT, connection_count, "count")
    #         except Exception as e:
                self.logger.warning(f"Failed to collect system metrics: {str(e)}")

    #     def _check_metric_alerts(self, metric_type: MetricType, value: float) -> None:
    #         """Check if metric value triggers alerts."""
    #         if metric_type not in self._thresholds:
    #             return

    thresholds = self._thresholds[metric_type]

    #         # Check critical threshold
    #         if value >= thresholds["critical"]:
                self._create_alert(
    #                 metric_type,
    #                 AlertLevel.CRITICAL,
    #                 f"Critical {metric_type.value}: {value}",
    #                 value
    #             )
    #         # Check error threshold
    #         elif value >= thresholds["error"]:
                self._create_alert(
    #                 metric_type,
    #                 AlertLevel.ERROR,
    #                 f"High {metric_type.value}: {value}",
    #                 value
    #             )
    #         # Check warning threshold
    #         elif value >= thresholds["warning"]:
                self._create_alert(
    #                 metric_type,
    #                 AlertLevel.WARNING,
    #                 f"Elevated {metric_type.value}: {value}",
    #                 value
    #             )

    #     def _create_alert(
    #         self,
    #         metric_type: MetricType,
    #         level: AlertLevel,
    #         message: str,
    #         value: float,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """Create a performance alert."""
    alert_id = str(uuid.uuid4())

    alert = PerformanceAlert(
    alert_id = alert_id,
    metric_type = metric_type,
    level = level,
    message = message,
    threshold = self._thresholds.get(metric_type, {}).get(level.value, value),
    current_value = value
    #         )

    #         if metadata:
                alert.metadata.update(metadata)

    self._alerts[alert_id] = alert

            self.logger.warning(f"Performance alert: {message}")

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

    #     def _parse_sql_query(self, sql: str) -> Tuple[Optional[str], Optional[str]]:
    #         """Parse SQL query to extract table and operation type."""
    #         try:
    sql_upper = sql.upper().strip()

    #             # Extract operation type
    operation_type = None
    #             if sql_upper.startswith("SELECT"):
    operation_type = "SELECT"
    #             elif sql_upper.startswith("INSERT"):
    operation_type = "INSERT"
    #             elif sql_upper.startswith("UPDATE"):
    operation_type = "UPDATE"
    #             elif sql_upper.startswith("DELETE"):
    operation_type = "DELETE"
    #             elif sql_upper.startswith("CREATE"):
    operation_type = "CREATE"
    #             elif sql_upper.startswith("ALTER"):
    operation_type = "ALTER"
    #             elif sql_upper.startswith("DROP"):
    operation_type = "DROP"

                # Extract table name (simple extraction)
    table = None
    #             if operation_type in ["SELECT", "INSERT", "UPDATE", "DELETE"]:
    #                 # Look for FROM, INTO, or table name after operation
    #                 import re

    #                 # SELECT ... FROM table
    match = re.search(r'FROM\s+(\w+)', sql_upper)
    #                 if match:
    table = match.group(1).lower()
    #                     return table, operation_type

    #                 # INSERT INTO table
    match = re.search(r'INTO\s+(\w+)', sql_upper)
    #                 if match:
    table = match.group(1).lower()
    #                     return table, operation_type

    #                 # UPDATE table
    match = re.search(r'UPDATE\s+(\w+)', sql_upper)
    #                 if match:
    table = match.group(1).lower()
    #                     return table, operation_type

    #                 # DELETE FROM table
    match = re.search(r'DELETE\s+FROM\s+(\w+)', sql_upper)
    #                 if match:
    table = match.group(1).lower()
    #                     return table, operation_type

    #             return table, operation_type
    #         except Exception as e:
                self.logger.warning(f"Failed to parse SQL query: {str(e)}")
    #             return None, None

    #     def _get_database_name(self) -> Optional[str]:
    #         """Get the current database name."""
    #         try:
    #             if self.backend and hasattr(self.backend, 'get_database_name'):
                    return self.backend.get_database_name()
    #             return None
    #         except Exception as e:
                self.logger.warning(f"Failed to get database name: {str(e)}")
    #             return None