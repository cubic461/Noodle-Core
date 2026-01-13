# Converted from Python to NoodleCore
# Original file: src

# """
# WebSocket Monitoring Module
# --------------------------

# This module provides comprehensive monitoring and logging for the WebSocket
# connection layer, including performance metrics, health checks, and alerts.
# """

import json
import logging
import time
import collections.defaultdict
import datetime.datetime
import typing.Any
import enum.Enum

logger = logging.getLogger(__name__)

# Constants
METRICS_RETENTION_PERIOD = 3600  # 1 hour
HEALTH_CHECK_INTERVAL = 60  # 1 minute
ALERT_THRESHOLD_CONNECTION_FAILURES = 5  # Alert after 5 failures
# ALERT_THRESHOLD_HIGH_LATENCY = 1000  # Alert if latency 1s
# ALERT_THRESHOLD_ERROR_RATE = 0.1  # Alert if error rate > 10%


class MetricType(Enum)
    #     """Types of metrics that can be collected."""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    TIMER = "timer"


class AlertLevel(Enum)
    #     """Alert severity levels."""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class Metric
    #     """Represents a single metric value."""

    #     def __init__(self, name): str, metric_type: MetricType, value: float,
    tags: Dict[str, str] = None, timestamp: float = None):
    #         """
    #         Initialize metric.

    #         Args:
    #             name: Metric name
    #             metric_type: Type of metric
    #             value: Metric value
    #             tags: Additional tags
    #             timestamp: Timestamp (current time if not provided)
    #         """
    self.name = name
    self.type = metric_type
    self.value = value
    self.tags = tags or {}
    self.timestamp = timestamp or time.time()

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert metric to dictionary."""
    #         return {
    #             "name": self.name,
    #             "type": self.type.value,
    #             "value": self.value,
    #             "tags": self.tags,
    #             "timestamp": self.timestamp,
    #         }


class Alert
    #     """Represents an alert condition."""

    #     def __init__(self, name: str, level: AlertLevel, message: str,
    details: Dict[str, Any] = None, timestamp: float = None):""
    #         Initialize alert.

    #         Args:
    #             name: Alert name
    #             level: Alert severity level
    #             message: Alert message
    #             details: Additional details
    #             timestamp: Timestamp (current time if not provided)
    #         """
    self.name = name
    self.level = level
    self.message = message
    self.details = details or {}
    self.timestamp = timestamp or time.time()
    self.resolved = False
    self.resolved_at = None

    #     def resolve(self):
    #         """Mark alert as resolved."""
    self.resolved = True
    self.resolved_at = time.time()

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert alert to dictionary."""
    #         return {
    #             "name": self.name,
    #             "level": self.level.value,
    #             "message": self.message,
    #             "details": self.details,
    #             "timestamp": self.timestamp,
    #             "resolved": self.resolved,
    #             "resolved_at": self.resolved_at,
    #         }


class MetricsCollector
    #     """Collects and manages metrics for the WebSocket layer."""

    #     def __init__(self, retention_period: int = METRICS_RETENTION_PERIOD):""
    #         Initialize metrics collector.

    #         Args:
                retention_period: How long to retain metrics (seconds)
    #         """
    self.retention_period = retention_period
    self.metrics: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
    self.counters: Dict[str, float] = defaultdict(float)
    self.gauges: Dict[str, float] = defaultdict(float)
    self.histograms: Dict[str, List[float]] = defaultdict(list)
    self.timers: Dict[str, List[float]] = defaultdict(list)
    self._lock = None

    #         try:
    #             import threading
    self._lock = threading.Lock()
    #         except ImportError:
                logger.warning("Threading not available, metrics collector may not be thread-safe")

    #         # Start cleanup task
            self._start_cleanup_task()

    #     def increment_counter(self, name: str, value: float = 1.0, tags: Dict[str, str] = None):
    #         """
    #         Increment a counter metric.

    #         Args:
    #             name: Metric name
    #             value: Value to increment by
    #             tags: Additional tags
    #         """
    timestamp = time.time()

    #         if self._lock:
    #             with self._lock:
    self.counters[name] + = value
                    self._store_metric(name, MetricType.COUNTER, self.counters[name], tags, timestamp)
    #         else:
    self.counters[name] + = value
                self._store_metric(name, MetricType.COUNTER, self.counters[name], tags, timestamp)

    #     def set_gauge(self, name: str, value: float, tags: Dict[str, str] = None):
    #         """
    #         Set a gauge metric.

    #         Args:
    #             name: Metric name
    #             value: Gauge value
    #             tags: Additional tags
    #         """
    timestamp = time.time()

    #         if self._lock:
    #             with self._lock:
    self.gauges[name] = value
                    self._store_metric(name, MetricType.GAUGE, value, tags, timestamp)
    #         else:
    self.gauges[name] = value
                self._store_metric(name, MetricType.GAUGE, value, tags, timestamp)

    #     def record_histogram(self, name: str, value: float, tags: Dict[str, str] = None):
    #         """
    #         Record a histogram value.

    #         Args:
    #             name: Metric name
    #             value: Histogram value
    #             tags: Additional tags
    #         """
    timestamp = time.time()

    #         if self._lock:
    #             with self._lock:
                    self.histograms[name].append(value)
    #                 # Keep only last 1000 values
    #                 if len(self.histograms[name]) 1000):
    self.histograms[name] = self.histograms[name][ - 1000:]
                    self._store_metric(name, MetricType.HISTOGRAM, value, tags, timestamp)
    #         else:
                self.histograms[name].append(value)
    #             if len(self.histograms[name]) 1000):
    self.histograms[name] = self.histograms[name][ - 1000:]
                self._store_metric(name, MetricType.HISTOGRAM, value, tags, timestamp)

    #     def record_timer(self, name: str, duration: float, tags: Dict[str, str] = None):
    #         """
    #         Record a timer value.

    #         Args:
    #             name: Metric name
    #             duration: Duration in seconds
    #             tags: Additional tags
    #         """
    timestamp = time.time()

    #         if self._lock:
    #             with self._lock:
                    self.timers[name].append(duration)
    #                 # Keep only last 1000 values
    #                 if len(self.timers[name]) 1000):
    self.timers[name] = self.timers[name][ - 1000:]
                    self._store_metric(name, MetricType.TIMER, duration, tags, timestamp)
    #         else:
                self.timers[name].append(duration)
    #             if len(self.timers[name]) 1000):
    self.timers[name] = self.timers[name][ - 1000:]
                self._store_metric(name, MetricType.TIMER, duration, tags, timestamp)

    #     def _store_metric(self, name: str, metric_type: MetricType, value: float,
    #                      tags: Dict[str, str], timestamp: float):
    #         """Store a metric value."""
    metric_key = self._get_metric_key(name, tags)
    metric = Metric(name, metric_type, value, tags, timestamp)
            self.metrics[metric_key].append(metric)

    #     def _get_metric_key(self, name: str, tags: Dict[str, str] = None) -str):
    #         """Generate a unique key for a metric with tags."""
    #         if not tags:
    #             return name

    #         tag_str = ",".join(f"{k}={v}" for k, v in sorted(tags.items()))
    #         return f"{name}[{tag_str}]"

    #     def get_metric(self, name: str, tags: Dict[str, str] = None) -Optional[Metric]):
    #         """
    #         Get the latest value of a metric.

    #         Args:
    #             name: Metric name
    #             tags: Additional tags

    #         Returns:
    #             Latest metric value or None
    #         """
    metric_key = self._get_metric_key(name, tags)
    metrics_queue = self.metrics.get(metric_key)

    #         if metrics_queue and metrics_queue:
    #             return metrics_queue[-1]

    #         return None

    #     def get_metrics_summary(self, name: str, tags: Dict[str, str] = None) -Dict[str, Any]):
    #         """
    #         Get a summary of a metric.

    #         Args:
    #             name: Metric name
    #             tags: Additional tags

    #         Returns:
    #             Metric summary dictionary
    #         """
    metric_key = self._get_metric_key(name, tags)
    metrics_queue = self.metrics.get(metric_key)

    #         if not metrics_queue:
    #             return {}

            # Get recent metrics (within retention period)
    cutoff_time = time.time() - self.retention_period
    recent_metrics = [
    #             m for m in metrics_queue
    #             if m.timestamp cutoff_time
    #         ]

    #         if not recent_metrics):
    #             return {}

    #         # Calculate summary based on metric type
    #         if recent_metrics[0].type == MetricType.COUNTER:
    #             return {
    #                 "latest": recent_metrics[-1].value,
                    "count": len(recent_metrics),
    #             }
    #         elif recent_metrics[0].type == MetricType.GAUGE:
    #             values = [m.value for m in recent_metrics]
    #             return {
    #                 "latest": recent_metrics[-1].value,
                    "min": min(values),
                    "max": max(values),
                    "avg": sum(values) / len(values),
                    "count": len(values),
    #             }
    #         elif recent_metrics[0].type in [MetricType.HISTOGRAM, MetricType.TIMER]:
    #             values = [m.value for m in recent_metrics]
                values.sort()
    count = len(values)

    #             return {
    #                 "count": count,
    #                 "min": values[0],
    #                 "max": values[-1],
                    "avg": sum(values) / count,
                    "p50": values[int(count * 0.5)],
                    "p90": values[int(count * 0.9)],
                    "p95": values[int(count * 0.95)],
                    "p99": values[int(count * 0.99)],
    #             }

    #         return {}

    #     def get_all_metrics(self) -Dict[str, Any]):
    #         """Get all metrics with summaries."""
    all_metrics = {}

    #         # Get unique metric names
    metric_names = set()
    #         for metric_key in self.metrics.keys():
    #             if "[" in metric_key:
    metric_name = metric_key.split("[")[0]
    #             else:
    metric_name = metric_key
                metric_names.add(metric_name)

    #         # Get summary for each metric
    #         for metric_name in metric_names:
    summary = self.get_metrics_summary(metric_name)
    #             if summary:
    all_metrics[metric_name] = summary

    #         return all_metrics

    #     def _start_cleanup_task(self):
    #         """Start background task to clean up old metrics."""
    #         def cleanup():
    #             while True:
    #                 try:
                        time.sleep(300)  # Run every 5 minutes

    cutoff_time = time.time() - self.retention_period

    #                     if self._lock:
    #                         with self._lock:
    #                             for metric_key, metrics_queue in self.metrics.items():
    #                                 # Remove old metrics
    #                                 while metrics_queue and metrics_queue[0].timestamp < cutoff_time:
                                        metrics_queue.popleft()
    #                     else:
    #                         for metric_key, metrics_queue in self.metrics.items():
    #                             while metrics_queue and metrics_queue[0].timestamp < cutoff_time:
                                    metrics_queue.popleft()

    #                 except Exception as e:
                        logger.error(f"Metrics cleanup error: {e}")

    #         try:
    #             import threading
    cleanup_thread = threading.Thread(target=cleanup, daemon=True)
                cleanup_thread.start()
                logger.info("Metrics cleanup thread started")
    #         except ImportError:
                logger.warning("Threading not available, metrics cleanup disabled")


class AlertManager
    #     """Manages alerts for the WebSocket layer."""

    #     def __init__(self):""Initialize alert manager."""
    self.alerts: Dict[str, Alert] = {}
    self.alert_handlers: List[Callable[[Alert], None]] = []
    self._lock = None

    #         try:
    #             import threading
    self._lock = threading.Lock()
    #         except ImportError:
                logger.warning("Threading not available, alert manager may not be thread-safe")

    #     def register_alert_handler(self, handler: Callable[[Alert], None]):
    #         """
    #         Register an alert handler.

    #         Args:
    #             handler: Alert handler function
    #         """
            self.alert_handlers.append(handler)
            logger.info("Registered alert handler")

    #     def trigger_alert(self, name: str, level: AlertLevel, message: str,
    details: Dict[str, Any] = None):
    #         """
    #         Trigger an alert.

    #         Args:
    #             name: Alert name
    #             level: Alert severity level
    #             message: Alert message
    #             details: Additional details
    #         """
    timestamp = time.time()
    alert = Alert(name, level, message, details, timestamp)

    #         if self._lock:
    #             with self._lock:
    self.alerts[name] = alert
    #         else:
    self.alerts[name] = alert

    #         # Call alert handlers
    #         for handler in self.alert_handlers:
    #             try:
                    handler(alert)
    #             except Exception as e:
                    logger.error(f"Error in alert handler: {e}")

            logger.warning(f"Alert triggered: {name} ({level.value}) - {message}")

    #     def resolve_alert(self, name: str):
    #         """
    #         Resolve an alert.

    #         Args:
    #             name: Alert name
    #         """
    #         if self._lock:
    #             with self._lock:
    #                 if name in self.alerts:
                        self.alerts[name].resolve()
    #         else:
    #             if name in self.alerts:
                    self.alerts[name].resolve()

            logger.info(f"Alert resolved: {name}")

    #     def get_active_alerts(self) -List[Alert]):
    #         """
            Get all active (unresolved) alerts.

    #         Returns:
    #             List of active alerts
    #         """
    #         if self._lock:
    #             with self._lock:
    #                 return [alert for alert in self.alerts.values() if not alert.resolved]
    #         else:
    #             return [alert for alert in self.alerts.values() if not alert.resolved]

    #     def get_all_alerts(self) -List[Alert]):
    #         """
            Get all alerts (active and resolved).

    #         Returns:
    #             List of all alerts
    #         """
    #         if self._lock:
    #             with self._lock:
                    return list(self.alerts.values())
    #         else:
                return list(self.alerts.values())


class WebSocketMonitor
    #     """
    #     Comprehensive monitoring for the WebSocket connection layer.

    #     Collects metrics, manages alerts, and provides health checks.
    #     """

    #     def __init__(self, redis_client=None):""
    #         Initialize WebSocket monitor.

    #         Args:
    #             redis_client: Redis client for distributed monitoring
    #         """
    self.redis = redis_client
    self.metrics_collector = MetricsCollector()
    self.alert_manager = AlertManager()

    #         # Health status
    self.health_status = {
    #             "healthy": True,
                "last_check": time.time(),
    #             "issues": [],
    #         }

    #         # Start monitoring tasks
            self._start_monitoring_tasks()

    #         # Register default alert handlers
            self._register_default_alert_handlers()

            logger.info("WebSocket monitor initialized")

    #     def record_connection_established(self, device_id: str, ip_address: str):
    #         """
    #         Record a new connection establishment.

    #         Args:
    #             device_id: Device ID
    #             ip_address: Client IP address
    #         """
            self.metrics_collector.increment_counter(
    #             "websocket.connections.established",
    tags = {"device_id": device_id, "ip_address": ip_address}
    #         )

            self.metrics_collector.set_gauge(
    #             "websocket.connections.active",
                self._get_active_connection_count()
    #         )

    #     def record_connection_closed(self, device_id: str, ip_address: str, duration: float):
    #         """
    #         Record a connection closure.

    #         Args:
    #             device_id: Device ID
    #             ip_address: Client IP address
    #             duration: Connection duration in seconds
    #         """
            self.metrics_collector.increment_counter(
    #             "websocket.connections.closed",
    tags = {"device_id": device_id, "ip_address": ip_address}
    #         )

            self.metrics_collector.record_histogram(
    #             "websocket.connections.duration",
    #             duration,
    tags = {"device_id": device_id}
    #         )

    #         # Update active connections gauge
            self.metrics_collector.set_gauge(
    #             "websocket.connections.active",
                self._get_active_connection_count()
    #         )

    #     def record_message_received(self, message_type: str, size: int):
    #         """
    #         Record a received message.

    #         Args:
    #             message_type: Type of message
    #             size: Message size in bytes
    #         """
            self.metrics_collector.increment_counter(
    #             "websocket.messages.received",
    tags = {"message_type": message_type}
    #         )

            self.metrics_collector.record_histogram(
    #             "websocket.messages.size",
    #             size,
    tags = {"message_type": message_type, "direction": "received"}
    #         )

    #     def record_message_sent(self, message_type: str, size: int):
    #         """
    #         Record a sent message.

    #         Args:
    #             message_type: Type of message
    #             size: Message size in bytes
    #         """
            self.metrics_collector.increment_counter(
    #             "websocket.messages.sent",
    tags = {"message_type": message_type}
    #         )

            self.metrics_collector.record_histogram(
    #             "websocket.messages.size",
    #             size,
    tags = {"message_type": message_type, "direction": "sent"}
    #         )

    #     def record_rpc_request(self, method: str, duration: float, success: bool):
    #         """
    #         Record an RPC request.

    #         Args:
    #             method: RPC method name
    #             duration: Request duration in seconds
    #             success: Whether the request was successful
    #         """
    tags = {"method": method, "success": str(success)}

            self.metrics_collector.increment_counter(
    #             "websocket.rpc.requests",
    tags = tags
    #         )

            self.metrics_collector.record_timer(
    #             "websocket.rpc.duration",
    #             duration,
    tags = {"method": method}
    #         )

    #         # Check for high latency
    #         if duration ALERT_THRESHOLD_HIGH_LATENCY / 1000):  # Convert ms to s
                self.alert_manager.trigger_alert(
    #                 "high_rpc_latency",
    #                 AlertLevel.WARNING,
    #                 f"High RPC latency detected for method {method}: {duration:.3f}s",
    #                 {"method": method, "duration": duration}
    #             )

    #     def record_error(self, error_type: str, error_message: str, device_id: str = None):
    #         """
    #         Record an error.

    #         Args:
    #             error_type: Type of error
    #             error_message: Error message
                device_id: Device ID (optional)
    #         """
    tags = {"error_type": error_type}
    #         if device_id:
    tags["device_id"] = device_id

            self.metrics_collector.increment_counter(
    #             "websocket.errors",
    tags = tags
    #         )

    #         # Check error rate
    error_rate = self._get_error_rate()
    #         if error_rate ALERT_THRESHOLD_ERROR_RATE):
                self.alert_manager.trigger_alert(
    #                 "high_error_rate",
    #                 AlertLevel.ERROR,
    #                 f"High error rate detected: {error_rate:.2%}",
    #                 {"error_rate": error_rate}
    #             )

    #     def record_authentication_result(self, success: bool, device_id: str = None):
    #         """
    #         Record an authentication result.

    #         Args:
    #             success: Whether authentication was successful
                device_id: Device ID (optional)
    #         """
    tags = {"success": str(success)}
    #         if device_id:
    tags["device_id"] = device_id

            self.metrics_collector.increment_counter(
    #             "websocket.authentications",
    tags = tags
    #         )

    #         if not success:
    #             # Check for multiple failed authentications
    failed_auths = self._get_failed_authentication_count()
    #             if failed_auths >= ALERT_THRESHOLD_CONNECTION_FAILURES:
                    self.alert_manager.trigger_alert(
    #                     "multiple_failed_authentications",
    #                     AlertLevel.WARNING,
    #                     f"Multiple failed authentications detected: {failed_auths}",
    #                     {"failed_count": failed_auths}
    #                 )

    #     def check_health(self) -Dict[str, Any]):
    #         """
    #         Perform health check.

    #         Returns:
    #             Health status dictionary
    #         """
    issues = []

    #         # Check error rate
    error_rate = self._get_error_rate()
    #         if error_rate 0.2):  # 20% error rate
                issues.append(f"High error rate: {error_rate:.2%}")

    #         # Check connection failures
    failed_auths = self._get_failed_authentication_count()
    #         if failed_auths 10):
                issues.append(f"High number of failed authentications: {failed_auths}")

    #         # Check active alerts
    active_alerts = self.alert_manager.get_active_alerts()
    #         critical_alerts = [a for a in active_alerts if a.level == AlertLevel.CRITICAL]
    #         if critical_alerts:
                issues.append(f"Critical alerts active: {len(critical_alerts)}")

    #         # Update health status
    self.health_status = {
    "healthy": len(issues) = = 0,
                "last_check": time.time(),
    #             "issues": issues,
                "active_alerts": len(active_alerts),
    #         }

    #         return self.health_status

    #     def get_monitoring_data(self) -Dict[str, Any]):
    #         """
    #         Get comprehensive monitoring data.

    #         Returns:
    #             Monitoring data dictionary
    #         """
    #         return {
                "metrics": self.metrics_collector.get_all_metrics(),
                "health": self.check_health(),
    #             "alerts": {
    #                 "active": [a.to_dict() for a in self.alert_manager.get_active_alerts()],
    #                 "all": [a.to_dict() for a in self.alert_manager.get_all_alerts()],
    #             },
                "timestamp": datetime.now().isoformat(),
    #         }

    #     def _get_active_connection_count(self) -int):
    #         """Get the current number of active connections."""
    #         # This would typically get the count from the connection manager
    #         # For now, return a mock value
    #         return 10

    #     def _get_error_rate(self) -float):
    #         """Get the current error rate."""
    total_requests = 0
    total_errors = 0

    #         # Get recent metrics
    #         for metric_name in ["websocket.messages.received", "websocket.errors"]:
    summary = self.metrics_collector.get_metrics_summary(metric_name)
    #             if summary:
    #                 if "count" in summary:
    #                     if metric_name == "websocket.errors":
    total_errors = summary["count"]
    #                     else:
    total_requests = summary["count"]

    #         if total_requests = 0:
    #             return 0.0

    #         return total_errors / total_requests

    #     def _get_failed_authentication_count(self) -int):
    #         """Get the count of failed authentications in the last hour."""
    summary = self.metrics_collector.get_metrics_summary(
    #             "websocket.authentications",
    tags = {"success": "False"}
    #         )
            return summary.get("count", 0)

    #     def _start_monitoring_tasks(self):
    #         """Start background monitoring tasks."""
    #         def health_check():
    #             while True:
    #                 try:
                        time.sleep(HEALTH_CHECK_INTERVAL)
                        self.check_health()
    #                 except Exception as e:
                        logger.error(f"Health check error: {e}")

    #         try:
    #             import threading
    health_thread = threading.Thread(target=health_check, daemon=True)
                health_thread.start()
                logger.info("Health check thread started")
    #         except ImportError:
                logger.warning("Threading not available, health checks disabled")

    #     def _register_default_alert_handlers(self):
    #         """Register default alert handlers."""
    #         def log_alert(alert: Alert):
    #             """Log alert to file."""
    #             if alert.level == AlertLevel.CRITICAL:
                    logger.critical(f"ALERT: {alert.message}")
    #             elif alert.level == AlertLevel.ERROR:
                    logger.error(f"ALERT: {alert.message}")
    #             elif alert.level == AlertLevel.WARNING:
                    logger.warning(f"ALERT: {alert.message}")
    #             else:
                    logger.info(f"ALERT: {alert.message}")

    #         def redis_alert(alert: Alert):
    #             """Publish alert to Redis."""
    #             if self.redis:
    #                 try:
                        self.redis.publish("websocket_alerts", json.dumps(alert.to_dict()))
    #                 except Exception as e:
                        logger.error(f"Failed to publish alert to Redis: {e}")

    #         # Register handlers
            self.alert_manager.register_alert_handler(log_alert)
            self.alert_manager.register_alert_handler(redis_alert)