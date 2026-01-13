# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Monitor Module

# This module implements comprehensive performance monitoring and metrics collection
# for the NoodleCore CLI, ensuring adherence to performance constraints.
# """

import asyncio
import gc
import psutil
import time
import threading
import collections.defaultdict,
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import pathlib.Path
import typing.Dict,
import json
import statistics

import ..cli_config.get_cli_config


# Error codes for performance monitor (5201-5300)
class PerformanceErrorCodes
    MONITOR_INIT_FAILED = 5201
    METRIC_COLLECTION_FAILED = 5202
    THRESHOLD_EXCEEDED = 5203
    PERFORMANCE_ALERT_FAILED = 5204
    TREND_ANALYSIS_FAILED = 5205
    MEMORY_MONITORING_FAILED = 5206
    CPU_MONITORING_FAILED = 5207
    DATABASE_PERFORMANCE_FAILED = 5208
    AI_PERFORMANCE_FAILED = 5209
    SANDBOX_PERFORMANCE_FAILED = 5210


class PerformanceLevel(Enum)
    #     """Performance levels for classification."""
    EXCELLENT = "excellent"
    GOOD = "good"
    ACCEPTABLE = "acceptable"
    POOR = "poor"
    CRITICAL = "critical"


class MetricType(Enum)
    #     """Types of performance metrics."""
    RESPONSE_TIME = "response_time"
    THROUGHPUT = "throughput"
    MEMORY_USAGE = "memory_usage"
    CPU_USAGE = "cpu_usage"
    DATABASE_QUERY_TIME = "database_query_time"
    AI_LATENCY = "ai_latency"
    SANDBOX_EXECUTION_TIME = "sandbox_execution_time"
    CONCURRENT_CONNECTIONS = "concurrent_connections"
    ERROR_RATE = "error_rate"


# @dataclass
class PerformanceThreshold
    #     """Performance threshold configuration."""
    #     metric_type: MetricType
    #     warning_threshold: float
    #     critical_threshold: float
    #     time_window: int  # seconds
    enabled: bool = True


# @dataclass
class PerformanceMetric
    #     """Single performance metric data point."""
    #     timestamp: datetime
    #     metric_type: MetricType
    #     value: float
    #     component: str
    request_id: Optional[str] = None
    details: Optional[Dict[str, Any]] = None


# @dataclass
class PerformanceAlert
    #     """Performance alert data."""
    #     timestamp: datetime
    #     metric_type: MetricType
    #     level: str  # warning, critical
    #     value: float
    #     threshold: float
    #     component: str
    #     message: str
    details: Optional[Dict[str, Any]] = None


class PerformanceException(Exception)
    #     """Base exception for performance monitoring errors."""

    #     def __init__(self, message: str, error_code: int):
    self.error_code = error_code
            super().__init__(message)


class PerformanceMonitor
    #     """Comprehensive performance monitoring system."""

    #     # Performance constraints from requirements
    API_RESPONSE_TIME_LIMIT = 0.5  # 500ms
    DATABASE_QUERY_TIME_LIMIT = 3.0  # 3 seconds
    MEMORY_USAGE_LIMIT = math.multiply(2.0, 1024 * 1024 * 1024  # 2GB in bytes)
    CONCURRENT_CONNECTIONS_LIMIT = 100

    #     def __init__(self, config_dir: Optional[str] = None):
    #         """
    #         Initialize the performance monitor.

    #         Args:
    #             config_dir: Directory for performance data storage
    #         """
    self.config = get_cli_config()
    self.config_dir = Path(config_dir or '.project/.noodle/logs')
    self.config_dir.mkdir(parents = True, exist_ok=True)

    #         # Performance data storage
    self.metrics_file = self.config_dir / 'performance.log'
    self.alerts_file = self.config_dir / 'performance_alerts.log'
    self.trends_file = self.config_dir / 'performance_trends.json'

            # In-memory metrics storage (circular buffer)
    self.metrics_buffer: Dict[MetricType, Deque[PerformanceMetric]] = defaultdict(
    lambda: deque(maxlen = 10000)
    #         )

    #         # Active alerts
    self.active_alerts: List[PerformanceAlert] = []

    #         # Performance thresholds
    self.thresholds = self._initialize_thresholds()

    #         # Monitoring state
    self._monitoring = False
    self._monitor_task = None
    self._lock = threading.Lock()

    #         # System monitoring
    self._system_monitoring = False
    self._system_monitor_task = None

    #         # Performance statistics
    self._stats = {
    #             'total_metrics': 0,
    #             'total_alerts': 0,
                'start_time': datetime.now(),
                'last_update': datetime.now()
    #         }

    #         # Alert callbacks
    self._alert_callbacks: List[Callable[[PerformanceAlert], None]] = []

    #         # Initialize performance files
            self._initialize_files()

    #     def _initialize_thresholds(self) -> Dict[MetricType, PerformanceThreshold]:
    #         """Initialize default performance thresholds."""
    #         return {
                MetricType.RESPONSE_TIME: PerformanceThreshold(
    #                 MetricType.RESPONSE_TIME,
    warning_threshold = 0.3,  # 300ms
    critical_threshold = self.API_RESPONSE_TIME_LIMIT,
    time_window = 60
    #             ),
                MetricType.DATABASE_QUERY_TIME: PerformanceThreshold(
    #                 MetricType.DATABASE_QUERY_TIME,
    warning_threshold = 2.0,  # 2 seconds
    critical_threshold = self.DATABASE_QUERY_TIME_LIMIT,
    time_window = 60
    #             ),
                MetricType.MEMORY_USAGE: PerformanceThreshold(
    #                 MetricType.MEMORY_USAGE,
    warning_threshold = math.multiply(self.MEMORY_USAGE_LIMIT, 0.8,  # 80% of limit)
    critical_threshold = math.multiply(self.MEMORY_USAGE_LIMIT, 0.95,  # 95% of limit)
    time_window = 30
    #             ),
                MetricType.CPU_USAGE: PerformanceThreshold(
    #                 MetricType.CPU_USAGE,
    warning_threshold = 70.0,  # 70%
    critical_threshold = 90.0,  # 90%
    time_window = 30
    #             ),
                MetricType.CONCURRENT_CONNECTIONS: PerformanceThreshold(
    #                 MetricType.CONCURRENT_CONNECTIONS,
    warning_threshold = 80,  # 80 connections
    critical_threshold = self.CONCURRENT_CONNECTIONS_LIMIT,
    time_window = 60
    #             ),
                MetricType.AI_LATENCY: PerformanceThreshold(
    #                 MetricType.AI_LATENCY,
    warning_threshold = 5.0,  # 5 seconds
    critical_threshold = 10.0,  # 10 seconds
    time_window = 60
    #             ),
                MetricType.SANDBOX_EXECUTION_TIME: PerformanceThreshold(
    #                 MetricType.SANDBOX_EXECUTION_TIME,
    warning_threshold = 10.0,  # 10 seconds
    critical_threshold = 30.0,  # 30 seconds
    time_window = 60
    #             ),
                MetricType.ERROR_RATE: PerformanceThreshold(
    #                 MetricType.ERROR_RATE,
    warning_threshold = 0.05,  # 5%
    critical_threshold = 0.10,  # 10%
    time_window = 300  # 5 minutes
    #             )
    #         }

    #     def _initialize_files(self):
    #         """Initialize performance monitoring files."""
    #         try:
    #             # Initialize metrics file
    #             if not self.metrics_file.exists():
    #                 with open(self.metrics_file, 'w', encoding='utf-8') as f:
                        f.write("# NoodleCore Performance Metrics\n")
                        f.write(f"# Started: {datetime.now().isoformat()}\n\n")

    #             # Initialize alerts file
    #             if not self.alerts_file.exists():
    #                 with open(self.alerts_file, 'w', encoding='utf-8') as f:
                        f.write("# NoodleCore Performance Alerts\n")
                        f.write(f"# Started: {datetime.now().isoformat()}\n\n")

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to initialize performance files: {str(e)}",
    #                 PerformanceErrorCodes.MONITOR_INIT_FAILED
    #             )

    #     async def start_monitoring(self, system_interval: int = 30) -> None:
    #         """
    #         Start performance monitoring.

    #         Args:
    #             system_interval: Interval in seconds for system monitoring
    #         """
    #         if self._monitoring:
    #             return

    #         try:
    self._monitoring = True
    self._system_monitoring = True

    #             # Start system monitoring task
    self._system_monitor_task = asyncio.create_task(
                    self._system_monitoring_loop(system_interval)
    #             )

                await self._log_metric(
    #                 MetricType.RESPONSE_TIME,
    #                 0.0,
    #                 'performance_monitor',
    details = {'action': 'monitoring_started'}
    #             )

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to start performance monitoring: {str(e)}",
    #                 PerformanceErrorCodes.MONITOR_INIT_FAILED
    #             )

    #     async def stop_monitoring(self) -> None:
    #         """Stop performance monitoring."""
    self._monitoring = False
    self._system_monitoring = False

    #         if self._system_monitor_task:
                self._system_monitor_task.cancel()
    #             try:
    #                 await self._system_monitor_task
    #             except asyncio.CancelledError:
    #                 pass

    #         # Save final trends
            await self._save_performance_trends()

    #     async def _system_monitoring_loop(self, interval: int) -> None:
    #         """Background system monitoring loop."""
    #         while self._system_monitoring:
    #             try:
    #                 # Monitor memory usage
    memory_info = psutil.virtual_memory()
                    await self._log_metric(
    #                     MetricType.MEMORY_USAGE,
    #                     memory_info.used,
    #                     'system',
    details = {
    #                         'total': memory_info.total,
    #                         'available': memory_info.available,
    #                         'percent': memory_info.percent
    #                     }
    #                 )

    #                 # Monitor CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)
                    await self._log_metric(
    #                     MetricType.CPU_USAGE,
    #                     cpu_percent,
    #                     'system',
    details = {'cpu_count': psutil.cpu_count()}
    #                 )

    #                 # Check memory constraint
    #                 if memory_info.used > self.MEMORY_USAGE_LIMIT:
                        await self._trigger_alert(
    #                         MetricType.MEMORY_USAGE,
    #                         'critical',
    #                         memory_info.used,
    #                         self.MEMORY_USAGE_LIMIT,
    #                         'system',
                            f"Memory usage exceeded 2GB limit: {memory_info.used / (1024**3):.2f}GB"
    #                     )
    #                     # Trigger garbage collection
                        gc.collect()

                    await asyncio.sleep(interval)

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
    #                 # Log error but continue monitoring
    #                 try:
                        await self._log_metric(
    #                         MetricType.ERROR_RATE,
    #                         1.0,
    #                         'performance_monitor',
    details = {'error': str(e)}
    #                     )
    #                 except:
    #                     pass
                    await asyncio.sleep(interval)

    #     async def track_api_response_time(
    #         self,
    #         endpoint: str,
    #         response_time: float,
    request_id: Optional[str] = None,
    status_code: int = 200,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """
    #         Track API response time with constraint checking.

    #         Args:
    #             endpoint: API endpoint
    #             response_time: Response time in seconds
    #             request_id: Request ID for tracking
    #             status_code: HTTP status code
    #             details: Additional details
    #         """
    #         try:
    metric_details = {
    #                 'endpoint': endpoint,
    #                 'status_code': status_code,
                    **(details or {})
    #             }

                await self._log_metric(
    #                 MetricType.RESPONSE_TIME,
    #                 response_time,
    #                 'api',
    #                 request_id,
    #                 metric_details
    #             )

    #             # Check API constraint
    #             if response_time > self.API_RESPONSE_TIME_LIMIT:
                    await self._trigger_alert(
    #                     MetricType.RESPONSE_TIME,
    #                     'critical',
    #                     response_time,
    #                     self.API_RESPONSE_TIME_LIMIT,
    #                     'api',
    #                     f"API response time exceeded 500ms limit: {response_time:.3f}s",
    #                     metric_details
    #                 )

    #             # Check thresholds
                await self._check_thresholds(MetricType.RESPONSE_TIME, response_time, 'api')

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to track API response time: {str(e)}",
    #                 PerformanceErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def track_database_query_time(
    #         self,
    #         query_type: str,
    #         query_time: float,
    request_id: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """
    #         Track database query time with constraint checking.

    #         Args:
                query_type: Type of query (SELECT, INSERT, UPDATE, DELETE)
    #             query_time: Query execution time in seconds
    #             request_id: Request ID for tracking
    #             details: Additional details
    #         """
    #         try:
    metric_details = {
    #                 'query_type': query_type,
                    **(details or {})
    #             }

                await self._log_metric(
    #                 MetricType.DATABASE_QUERY_TIME,
    #                 query_time,
    #                 'database',
    #                 request_id,
    #                 metric_details
    #             )

    #             # Check database constraint
    #             if query_time > self.DATABASE_QUERY_TIME_LIMIT:
                    await self._trigger_alert(
    #                     MetricType.DATABASE_QUERY_TIME,
    #                     'critical',
    #                     query_time,
    #                     self.DATABASE_QUERY_TIME_LIMIT,
    #                     'database',
    #                     f"Database query time exceeded 3s limit: {query_time:.3f}s",
    #                     metric_details
    #                 )

    #             # Check thresholds
                await self._check_thresholds(MetricType.DATABASE_QUERY_TIME, query_time, 'database')

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to track database query time: {str(e)}",
    #                 PerformanceErrorCodes.DATABASE_PERFORMANCE_FAILED
    #             )

    #     async def track_ai_performance(
    #         self,
    #         model: str,
    #         latency: float,
    #         tokens_used: int,
    request_id: Optional[str] = None,
    success: bool = True,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """
    #         Track AI provider performance metrics.

    #         Args:
    #             model: AI model name
    #             latency: Response latency in seconds
    #             tokens_used: Number of tokens used
    #             request_id: Request ID for tracking
    #             success: Whether the request was successful
    #             details: Additional details
    #         """
    #         try:
    metric_details = {
    #                 'model': model,
    #                 'tokens_used': tokens_used,
    #                 'success': success,
    #                 'tokens_per_second': tokens_used / latency if latency > 0 else 0,
                    **(details or {})
    #             }

                await self._log_metric(
    #                 MetricType.AI_LATENCY,
    #                 latency,
    #                 'ai_adapter',
    #                 request_id,
    #                 metric_details
    #             )

    #             # Check thresholds
                await self._check_thresholds(MetricType.AI_LATENCY, latency, 'ai_adapter')

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to track AI performance: {str(e)}",
    #                 PerformanceErrorCodes.AI_PERFORMANCE_FAILED
    #             )

    #     async def track_sandbox_performance(
    #         self,
    #         operation: str,
    #         execution_time: float,
    memory_used: Optional[int] = None,
    request_id: Optional[str] = None,
    success: bool = True,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """
    #         Track sandbox execution performance.

    #         Args:
    #             operation: Type of operation
    #             execution_time: Execution time in seconds
    #             memory_used: Memory used in bytes
    #             request_id: Request ID for tracking
    #             success: Whether the operation was successful
    #             details: Additional details
    #         """
    #         try:
    metric_details = {
    #                 'operation': operation,
    #                 'memory_used': memory_used,
    #                 'success': success,
                    **(details or {})
    #             }

                await self._log_metric(
    #                 MetricType.SANDBOX_EXECUTION_TIME,
    #                 execution_time,
    #                 'sandbox',
    #                 request_id,
    #                 metric_details
    #             )

    #             # Check thresholds
                await self._check_thresholds(
    #                 MetricType.SANDBOX_EXECUTION_TIME,
    #                 execution_time,
    #                 'sandbox'
    #             )

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to track sandbox performance: {str(e)}",
    #                 PerformanceErrorCodes.SANDBOX_PERFORMANCE_FAILED
    #             )

    #     async def track_concurrent_connections(
    #         self,
    #         current_connections: int,
    max_connections: int = None,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """
    #         Track concurrent connections.

    #         Args:
    #             current_connections: Current number of connections
    #             max_connections: Maximum allowed connections
    #             details: Additional details
    #         """
    #         try:
    #             if max_connections is None:
    max_connections = self.CONCURRENT_CONNECTIONS_LIMIT

    metric_details = {
    #                 'current_connections': current_connections,
    #                 'max_connections': max_connections,
    #                 'utilization': current_connections / max_connections,
                    **(details or {})
    #             }

                await self._log_metric(
    #                 MetricType.CONCURRENT_CONNECTIONS,
    #                 current_connections,
    #                 'connection_manager',
    details = metric_details
    #             )

    #             # Check constraint
    #             if current_connections > self.CONCURRENT_CONNECTIONS_LIMIT:
                    await self._trigger_alert(
    #                     MetricType.CONCURRENT_CONNECTIONS,
    #                     'critical',
    #                     current_connections,
    #                     self.CONCURRENT_CONNECTIONS_LIMIT,
    #                     'connection_manager',
    #                     f"Concurrent connections exceeded limit: {current_connections}"
    #                 )

    #             # Check thresholds
                await self._check_thresholds(
    #                 MetricType.CONCURRENT_CONNECTIONS,
    #                 current_connections,
    #                 'connection_manager'
    #             )

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to track concurrent connections: {str(e)}",
    #                 PerformanceErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def _log_metric(
    #         self,
    #         metric_type: MetricType,
    #         value: float,
    #         component: str,
    request_id: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """Log a performance metric."""
    #         try:
    metric = PerformanceMetric(
    timestamp = datetime.now(),
    metric_type = metric_type,
    value = value,
    component = component,
    request_id = request_id,
    details = details
    #             )

    #             # Add to in-memory buffer
    #             with self._lock:
                    self.metrics_buffer[metric_type].append(metric)
    self._stats['total_metrics'] + = 1
    self._stats['last_update'] = datetime.now()

    #             # Save to file
                await self._save_metric(metric)

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to log metric: {str(e)}",
    #                 PerformanceErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def _save_metric(self, metric: PerformanceMetric) -> None:
    #         """Save metric to file."""
    #         try:
    metric_data = asdict(metric)
    metric_data['timestamp'] = metric.timestamp.isoformat()
    metric_data['metric_type'] = metric.metric_type.value

    #             with open(self.metrics_file, 'a', encoding='utf-8') as f:
    f.write(json.dumps(metric_data, default = str) + '\n')

    #         except IOError as e:
                raise PerformanceException(
                    f"Failed to save metric: {str(e)}",
    #                 PerformanceErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def _check_thresholds(
    #         self,
    #         metric_type: MetricType,
    #         value: float,
    #         component: str
    #     ) -> None:
    #         """Check if metric exceeds thresholds and trigger alerts."""
    #         try:
    threshold = self.thresholds.get(metric_type)
    #             if not threshold or not threshold.enabled:
    #                 return

    #             # Get recent metrics for time window
    recent_metrics = [
    #                 m for m in self.metrics_buffer[metric_type]
    #                 if (datetime.now() - m.timestamp).total_seconds() <= threshold.time_window
    #             ]

    #             if not recent_metrics:
    #                 return

    #             # Calculate average over time window
    #             avg_value = statistics.mean(m.value for m in recent_metrics)

    #             # Check critical threshold
    #             if avg_value >= threshold.critical_threshold:
                    await self._trigger_alert(
    #                     metric_type,
    #                     'critical',
    #                     avg_value,
    #                     threshold.critical_threshold,
    #                     component,
    f"{metric_type.value} exceeded critical threshold: {avg_value:.3f} > = {threshold.critical_threshold}"
    #                 )
    #             # Check warning threshold
    #             elif avg_value >= threshold.warning_threshold:
                    await self._trigger_alert(
    #                     metric_type,
    #                     'warning',
    #                     avg_value,
    #                     threshold.warning_threshold,
    #                     component,
    f"{metric_type.value} exceeded warning threshold: {avg_value:.3f} > = {threshold.warning_threshold}"
    #                 )

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to check thresholds: {str(e)}",
    #                 PerformanceErrorCodes.THRESHOLD_EXCEEDED
    #             )

    #     async def _trigger_alert(
    #         self,
    #         metric_type: MetricType,
    #         level: str,
    #         value: float,
    #         threshold: float,
    #         component: str,
    #         message: str,
    details: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """Trigger a performance alert."""
    #         try:
    alert = PerformanceAlert(
    timestamp = datetime.now(),
    metric_type = metric_type,
    level = level,
    value = value,
    threshold = threshold,
    component = component,
    message = message,
    details = details
    #             )

    #             # Add to active alerts
                self.active_alerts.append(alert)

                # Keep only recent alerts (last 1000)
    #             if len(self.active_alerts) > 1000:
    self.active_alerts = math.subtract(self.active_alerts[, 1000:])

    #             # Update stats
    self._stats['total_alerts'] + = 1

    #             # Save to file
                await self._save_alert(alert)

    #             # Call alert callbacks
    #             for callback in self._alert_callbacks:
    #                 try:
                        callback(alert)
    #                 except:
    #                     pass  # Don't let callback failures break monitoring

    #         except Exception as e:
                raise PerformanceException(
                    f"Failed to trigger alert: {str(e)}",
    #                 PerformanceErrorCodes.PERFORMANCE_ALERT_FAILED
    #             )

    #     async def _save_alert(self, alert: PerformanceAlert) -> None:
    #         """Save alert to file."""
    #         try:
    alert_data = asdict(alert)
    alert_data['timestamp'] = alert.timestamp.isoformat()
    alert_data['metric_type'] = alert.metric_type.value

    #             with open(self.alerts_file, 'a', encoding='utf-8') as f:
    f.write(json.dumps(alert_data, default = str) + '\n')

    #         except IOError as e:
                raise PerformanceException(
                    f"Failed to save alert: {str(e)}",
    #                 PerformanceErrorCodes.PERFORMANCE_ALERT_FAILED
    #             )

    #     async def get_performance_metrics(
    #         self,
    metric_type: Optional[MetricType] = None,
    component: Optional[str] = None,
    since: Optional[datetime] = None,
    until: Optional[datetime] = None,
    limit: int = 1000
    #     ) -> Dict[str, Any]:
    #         """
    #         Get performance metrics with filtering.

    #         Args:
    #             metric_type: Filter by metric type
    #             component: Filter by component
    #             since: Filter by start time
    #             until: Filter by end time
    #             limit: Maximum number of metrics

    #         Returns:
    #             Dictionary containing performance metrics
    #         """
    #         try:
    metrics = []

    #             # Collect metrics from buffer
    #             for mtype, metric_list in self.metrics_buffer.items():
    #                 if metric_type and mtype != metric_type:
    #                     continue

    #                 for metric in metric_list:
    #                     if component and metric.component != component:
    #                         continue
    #                     if since and metric.timestamp < since:
    #                         continue
    #                     if until and metric.timestamp > until:
    #                         continue

                        metrics.append(metric)

                # Sort by timestamp (newest first) and apply limit
    metrics.sort(key = lambda x: x.timestamp, reverse=True)
    metrics = metrics[:limit]

    #             # Convert to dict format
    metrics_data = []
    #             for metric in metrics:
    metric_dict = asdict(metric)
    metric_dict['timestamp'] = metric.timestamp.isoformat()
    metric_dict['metric_type'] = metric.metric_type.value
                    metrics_data.append(metric_dict)

    #             return {
    #                 'success': True,
    #                 'metrics': metrics_data,
                    'count': len(metrics_data),
    #                 'filters': {
    #                     'metric_type': metric_type.value if metric_type else None,
    #                     'component': component,
    #                     'since': since.isoformat() if since else None,
    #                     'until': until.isoformat() if until else None,
    #                     'limit': limit
    #                 }
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': PerformanceErrorCodes.METRIC_COLLECTION_FAILED
    #             }

    #     async def get_performance_summary(
    #         self,
    time_window: int = 3600  # 1 hour
    #     ) -> Dict[str, Any]:
    #         """
    #         Get performance summary for the specified time window.

    #         Args:
    #             time_window: Time window in seconds

    #         Returns:
    #             Dictionary containing performance summary
    #         """
    #         try:
    cutoff_time = math.subtract(datetime.now(), timedelta(seconds=time_window))
    summary = {}

    #             for metric_type, metric_list in self.metrics_buffer.items():
    #                 # Filter metrics by time window
    recent_metrics = [
    #                     m for m in metric_list
    #                     if m.timestamp >= cutoff_time
    #                 ]

    #                 if not recent_metrics:
    #                     continue

    #                 values = [m.value for m in recent_metrics]

    summary[metric_type.value] = {
                        'count': len(values),
                        'min': min(values),
                        'max': max(values),
                        'avg': statistics.mean(values),
                        'median': statistics.median(values),
    #                     'std_dev': statistics.stdev(values) if len(values) > 1 else 0.0
    #                 }

    #                 # Add performance level classification
    avg_value = summary[metric_type.value]['avg']
    threshold = self.thresholds.get(metric_type)
    #                 if threshold:
    #                     if avg_value < threshold.warning_threshold:
    level = PerformanceLevel.EXCELLENT
    #                     elif avg_value < threshold.critical_threshold:
    level = PerformanceLevel.GOOD
    #                     else:
    level = PerformanceLevel.POOR

    summary[metric_type.value]['performance_level'] = level.value

    #             # Add system health indicators
    summary['system_health'] = {
                    'memory_usage_percent': psutil.virtual_memory().percent,
                    'cpu_usage_percent': psutil.cpu_percent(),
                    'disk_usage_percent': psutil.disk_usage('/').percent,
                    'active_processes': len(psutil.pids())
    #             }

    #             # Add recent alerts
    recent_alerts = [
    #                 alert for alert in self.active_alerts
    #                 if alert.timestamp >= cutoff_time
    #             ]

    summary['recent_alerts'] = {
                    'total': len(recent_alerts),
    #                 'warning': len([a for a in recent_alerts if a.level == 'warning']),
    #                 'critical': len([a for a in recent_alerts if a.level == 'critical'])
    #             }

    #             return {
    #                 'success': True,
    #                 'summary': summary,
    #                 'time_window': time_window,
                    'generated_at': datetime.now().isoformat()
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': PerformanceErrorCodes.TREND_ANALYSIS_FAILED
    #             }

    #     async def analyze_performance_trends(
    #         self,
    #         metric_type: MetricType,
    time_window: int = 86400  # 24 hours
    #     ) -> Dict[str, Any]:
    #         """
    #         Analyze performance trends for a specific metric.

    #         Args:
    #             metric_type: Type of metric to analyze
    #             time_window: Time window in seconds

    #         Returns:
    #             Dictionary containing trend analysis
    #         """
    #         try:
    cutoff_time = math.subtract(datetime.now(), timedelta(seconds=time_window))
    metrics = [
    #                 m for m in self.metrics_buffer[metric_type]
    #                 if m.timestamp >= cutoff_time
    #             ]

    #             if len(metrics) < 2:
    #                 return {
    #                     'success': False,
    #                     'error': 'Insufficient data for trend analysis',
    #                     'error_code': PerformanceErrorCodes.TREND_ANALYSIS_FAILED
    #                 }

    #             # Sort by timestamp
    metrics.sort(key = lambda x: x.timestamp)

    #             # Extract values and timestamps
    #             values = [m.value for m in metrics]
    #             timestamps = [(m.timestamp - metrics[0].timestamp).total_seconds() for m in metrics]

                # Calculate trend (simple linear regression)
    n = len(values)
    sum_x = sum(timestamps)
    sum_y = sum(values)
    #             sum_xy = sum(x * y for x, y in zip(timestamps, values))
    #             sum_x2 = sum(x * x for x in timestamps)

    slope = math.multiply((n, sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x))
    intercept = math.multiply((sum_y - slope, sum_x) / n)

    #             # Calculate correlation coefficient
    mean_x = math.divide(sum_x, n)
    mean_y = math.divide(sum_y, n)
    #             numerator = sum((x - mean_x) * (y - mean_y) for x, y in zip(timestamps, values))
    #             denominator_x = sum((x - mean_x) ** 2 for x in timestamps)
    #             denominator_y = sum((y - mean_y) ** 2 for y in values)

    #             correlation = numerator / ((denominator_x * denominator_y) ** 0.5) if denominator_x * denominator_y > 0 else 0

    #             # Determine trend direction
    #             if abs(slope) < 0.001:
    trend_direction = 'stable'
    #             elif slope > 0:
    trend_direction = 'increasing'
    #             else:
    trend_direction = 'decreasing'

                # Predict future values (next hour)
    future_time = math.add(time_window, 3600  # Current window + 1 hour)
    predicted_value = math.add(slope * future_time, intercept)

    #             return {
    #                 'success': True,
    #                 'metric_type': metric_type.value,
    #                 'time_window': time_window,
    #                 'data_points': n,
    #                 'trend': {
    #                     'direction': trend_direction,
    #                     'slope': slope,
    #                     'correlation': correlation,
    #                     'intercept': intercept
    #                 },
    #                 'statistics': {
                        'current_avg': statistics.mean(values),
                        'min': min(values),
                        'max': max(values),
    #                     'std_dev': statistics.stdev(values) if len(values) > 1 else 0.0
    #                 },
    #                 'prediction': {
    #                     'next_hour_value': predicted_value,
                        'confidence': abs(correlation)
    #                 },
                    'analyzed_at': datetime.now().isoformat()
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': PerformanceErrorCodes.TREND_ANALYSIS_FAILED
    #             }

    #     async def _save_performance_trends(self) -> None:
    #         """Save performance trends to file."""
    #         try:
    trends = {}

    #             for metric_type in MetricType:
    trend_analysis = await self.analyze_performance_trends(metric_type)
    #                 if trend_analysis['success']:
    trends[metric_type.value] = trend_analysis

    trends_data = {
                    'generated_at': datetime.now().isoformat(),
    #                 'trends': trends
    #             }

    #             with open(self.trends_file, 'w', encoding='utf-8') as f:
    json.dump(trends_data, f, indent = 2, default=str)

    #         except Exception as e:
    #             # Don't raise exception for trend saving failures
    #             pass

    #     def add_alert_callback(self, callback: Callable[[PerformanceAlert], None]) -> None:
    #         """Add a callback function for performance alerts."""
            self._alert_callbacks.append(callback)

    #     def remove_alert_callback(self, callback: Callable[[PerformanceAlert], None]) -> None:
    #         """Remove an alert callback function."""
    #         if callback in self._alert_callbacks:
                self._alert_callbacks.remove(callback)

    #     def get_active_alerts(
    #         self,
    level: Optional[str] = None,
    metric_type: Optional[MetricType] = None,
    limit: int = 100
    #     ) -> List[PerformanceAlert]:
    #         """
    #         Get active performance alerts.

    #         Args:
                level: Filter by alert level (warning, critical)
    #             metric_type: Filter by metric type
    #             limit: Maximum number of alerts

    #         Returns:
    #             List of performance alerts
    #         """
    alerts = self.active_alerts.copy()

    #         if level:
    #             alerts = [a for a in alerts if a.level == level]

    #         if metric_type:
    #             alerts = [a for a in alerts if a.metric_type == metric_type]

            # Sort by timestamp (newest first) and apply limit
    alerts.sort(key = lambda x: x.timestamp, reverse=True)
    #         return alerts[:limit]

    #     def get_performance_stats(self) -> Dict[str, Any]:
    #         """Get performance monitoring statistics."""
    uptime = datetime.now() - self._stats['start_time']

    #         return {
    #             'monitoring_active': self._monitoring,
    #             'system_monitoring_active': self._system_monitoring,
    #             'total_metrics': self._stats['total_metrics'],
    #             'total_alerts': self._stats['total_alerts'],
                'uptime_seconds': uptime.total_seconds(),
                'start_time': self._stats['start_time'].isoformat(),
                'last_update': self._stats['last_update'].isoformat(),
    #             'metrics_buffer_sizes': {
                    metric_type.value: len(metrics)
    #                 for metric_type, metrics in self.metrics_buffer.items()
    #             },
                'active_alerts_count': len(self.active_alerts),
    #             'configured_thresholds': {
    #                 metric_type.value: {
    #                     'warning': threshold.warning_threshold,
    #                     'critical': threshold.critical_threshold,
    #                     'enabled': threshold.enabled
    #                 }
    #                 for metric_type, threshold in self.thresholds.items()
    #             }
    #         }

    #     def update_threshold(
    #         self,
    #         metric_type: MetricType,
    warning_threshold: Optional[float] = None,
    critical_threshold: Optional[float] = None,
    enabled: Optional[bool] = None
    #     ) -> None:
    #         """
    #         Update performance threshold configuration.

    #         Args:
    #             metric_type: Type of metric
    #             warning_threshold: New warning threshold
    #             critical_threshold: New critical threshold
    #             enabled: Whether threshold is enabled
    #         """
    #         if metric_type in self.thresholds:
    threshold = self.thresholds[metric_type]

    #             if warning_threshold is not None:
    threshold.warning_threshold = warning_threshold
    #             if critical_threshold is not None:
    threshold.critical_threshold = critical_threshold
    #             if enabled is not None:
    threshold.enabled = enabled