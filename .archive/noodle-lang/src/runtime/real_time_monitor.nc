# Converted from Python to NoodleCore
# Original file: src

# """
# Real-Time Performance Monitoring System for Noodle

# This module implements a comprehensive real-time performance monitoring system
# that collects metrics from all runtime components, aggregates data with configurable
# sampling rates, and provides distributed monitoring support for multi-node deployments.
# """

import asyncio
import json
import logging
import queue
import statistics
import threading
import time
import uuid
import collections.defaultdict
import concurrent.futures.ThreadPoolExecutor
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import pathlib.Path
import typing.Any

import aiofiles
import aiohttp
import numpy as np
import psutil
import redis

logger = logging.getLogger(__name__)


class MetricType(Enum)
    #     """Types of performance metrics that can be collected"""

    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    SUMMARY = "summary"


class AlertSeverity(Enum)
    #     """Performance alert severity levels"""

    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"


class AlertCondition(Enum)
    #     """Performance alert conditions"""

    ABOVE = "above"
    BELOW = "below"
    EQUALS = "equals"


dataclass
class MetricConfig
    #     """Configuration for a specific metric"""

    #     name: str
    #     type: MetricType
    sampling_rate: float = 1.0  # samples per second
    enabled: bool = True
    retention_time: int = 3600  # seconds
    description: str = ""
    tags: Dict[str, str] = field(default_factory=dict)


dataclass
class PerformanceMetric
    #     """Single performance metric measurement"""

    #     name: str
    #     value: float
    #     unit: str
    #     timestamp: datetime
    metric_type: MetricType = MetricType.GAUGE
    tags: Dict[str, str] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary for serialization"""
    #         return {
    #             "name": self.name,
    #             "value": self.value,
    #             "unit": self.unit,
                "timestamp": self.timestamp.isoformat(),
    #             "metric_type": self.metric_type.value,
    #             "tags": self.tags,
    #             "metadata": self.metadata,
    #         }


dataclass
class AlertConfig
    #     """Configuration for performance alerts"""

    #     metric_name: str
    #     threshold: float
    #     condition: AlertCondition
    #     severity: AlertSeverity
    description: str = ""
    cooldown_seconds: int = 60
    enabled: bool = True
    callback: Optional[Callable[[str, PerformanceMetric], None]] = None
    tags: Dict[str, str] = field(default_factory=dict)


dataclass
class AlertEvent
    #     """Represents a triggered performance alert"""

    #     alert_config: AlertConfig
    #     metric: PerformanceMetric
    #     timestamp: datetime
    acknowledged: bool = False
    id: str = field(default_factory=lambda: str(uuid.uuid4()))


dataclass
class NodeInfo
    #     """Information about a monitored node"""

    #     node_id: str
    #     node_type: str
    #     address: str
    #     port: int
    #     last_seen: datetime
    status: str = "active"
    tags: Dict[str, str] = field(default_factory=dict)


class MetricsBuffer
    #     """Thread-safe buffer for metrics before storage"""

    #     def __init__(self, max_size: int = 10000):
    self.buffer = deque(maxlen=max_size)
    self._lock = threading.Lock()
    self._not_empty = threading.Condition(self._lock)

    #     def put(self, metric: PerformanceMetric) -None):
    #         """Add a metric to the buffer"""
    #         with self._lock:
                self.buffer.append(metric)
                self._not_empty.notify()

    #     def get_batch(self, batch_size: int = 100) -List[PerformanceMetric]):
    #         """Get a batch of metrics from the buffer"""
    #         with self._lock:
    #             if len(self.buffer) < batch_size:
    batch = list(self.buffer)
                    self.buffer.clear()
    #             else:
    #                 batch = [self.buffer.popleft() for _ in range(batch_size)]
    #             return batch

    #     def get_all(self) -List[PerformanceMetric]):
    #         """Get all metrics from the buffer"""
    #         with self._lock:
    metrics = list(self.buffer)
                self.buffer.clear()
    #             return metrics

    #     def size(self) -int):
    #         """Get current buffer size"""
    #         with self._lock:
                return len(self.buffer)


class TimeSeriesStorage
    #     """Time-series storage backend for metrics"""

    #     def __init__(
    self, storage_path: str = "metrics_data", max_file_size: int = 100 * 1024 * 1024
    #     ):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)
    self.max_file_size = max_file_size
    self.current_file = None
    self.current_file_handle = None
    self._lock = threading.Lock()

    #     def _get_file_path(self, metric_name: str, date: datetime) -Path):
    #         """Get file path for a metric on a specific date"""
    date_str = date.strftime("%Y-%m-%d")
    #         return self.storage_path / f"{metric_name}_{date_str}.json"

    #     def store_metrics(self, metrics: List[PerformanceMetric]) -None):
    #         """Store metrics in time-series format"""
    #         if not metrics:
    #             return

    #         # Group metrics by name and date
    metric_groups = defaultdict(list)
    #         for metric in metrics:
    date_key = metric.timestamp.date()
                metric_groups[(metric.name, date_key)].append(metric)

    #         # Write each group to its respective file
    #         for (metric_name, date), group_metrics in metric_groups.items():
    file_path = self._get_file_path(metric_name, date)

    #             with self._lock:
    #                 # Open file in append mode
    #                 with open(file_path, "a") as f:
    #                     for metric in group_metrics:
                            f.write(json.dumps(metric.to_dict()) + "\n")

    #     def get_metrics(
    #         self, metric_name: str, start_time: datetime, end_time: datetime
    #     ) -List[PerformanceMetric]):
    #         """Retrieve metrics for a specific time range"""
    metrics = []

    #         # Get all relevant files
    current_date = start_time.date()
    #         while current_date <= end_time.date():
    file_path = self._get_file_path(metric_name, current_date)

    #             if file_path.exists():
    #                 with open(file_path, "r") as f:
    #                     for line in f:
    #                         try:
    data = json.loads(line.strip())
    metric_time = datetime.fromisoformat(data["timestamp"])

    #                             if start_time <= metric_time <= end_time:
    metric = PerformanceMetric(
    name = data["name"],
    value = data["value"],
    unit = data["unit"],
    timestamp = metric_time,
    metric_type = MetricType(data["metric_type"]),
    tags = data.get("tags", {}),
    metadata = data.get("metadata", {}),
    #                                 )
                                    metrics.append(metric)
                            except (json.JSONDecodeError, KeyError, ValueError) as e:
                                logger.warning(f"Error parsing metric data: {e}")

    current_date + = timedelta(days=1)

    return sorted(metrics, key = lambda m: m.timestamp)

    #     def get_metric_summary(
    #         self, metric_name: str, start_time: datetime, end_time: datetime
    #     ) -Dict[str, Any]):
    #         """Get summary statistics for a metric over time"""
    metrics = self.get_metrics(metric_name, start_time, end_time)

    #         if not metrics:
    #             return {}

    #         values = [m.value for m in metrics]

    #         return {
    #             "metric_name": metric_name,
                "start_time": start_time.isoformat(),
                "end_time": end_time.isoformat(),
                "count": len(values),
                "min": min(values),
                "max": max(values),
                "mean": statistics.mean(values),
                "median": statistics.median(values),
    #             "std": statistics.stdev(values) if len(values) 1 else 0,
    #             "p95"): np.percentile(values, 95) if len(values) 0 else 0,
    #             "p99"): np.percentile(values, 99) if len(values) 0 else 0,
    #         }


class MetricsAggregator
    #     """Aggregates metrics with configurable sampling rates"""

    #     def __init__(self, buffer): MetricsBuffer, storage: TimeSeriesStorage):
    self.buffer = buffer
    self.storage = storage
    self.metrics_config: Dict[str, MetricConfig] = {}
    self.sampling_queues: Dict[str, queue.Queue] = {}
    self.aggregation_thread = None
    self.running = False
    self.executor = ThreadPoolExecutor(max_workers=4)

    #     def add_metric_config(self, config: MetricConfig) -None):
    #         """Add a metric configuration"""
    self.metrics_config[config.name] = config
    self.sampling_queues[config.name] = queue.Queue(maxsize=1000)

    #     def start(self) -None):
    #         """Start the metrics aggregation process"""
    #         if self.running:
    #             return

    self.running = True
    self.aggregation_thread = threading.Thread(
    target = self._aggregation_loop, daemon=True
    #         )
            self.aggregation_thread.start()
            logger.info("Metrics aggregator started")

    #     def stop(self) -None):
    #         """Stop the metrics aggregation process"""
    self.running = False
    #         if self.aggregation_thread:
    self.aggregation_thread.join(timeout = 5.0)
    self.executor.shutdown(wait = True)
            logger.info("Metrics aggregator stopped")

    #     def record_metric(self, metric: PerformanceMetric) -None):
    #         """Record a metric for aggregation"""
    #         if metric.name not in self.metrics_config:
    #             return

    config = self.metrics_config[metric.name]

    #         # Apply sampling rate
    #         if config.sampling_rate < 1.0:
    #             if np.random.random() config.sampling_rate):
    #                 return

    #         # Add to sampling queue
    #         try:
                self.sampling_queues[metric.name].put_nowait(metric)
    #         except queue.Full:
    #             logger.warning(f"Sampling queue full for metric {metric.name}")

    #     def _aggregation_loop(self) -None):
    #         """Main aggregation loop"""
    #         while self.running:
    #             try:
    #                 # Process each metric queue
    #                 for metric_name, metric_queue in self.sampling_queues.items():
    #                     if not metric_queue.empty():
    config = self.metrics_config[metric_name]

    #                         # Get batch of metrics
    batch_size = min(100, metric_queue.qsize())
    metrics = []
    #                         for _ in range(batch_size):
    #                             try:
    metric = metric_queue.get_nowait()
                                    metrics.append(metric)
    #                             except queue.Empty:
    #                                 break

    #                         if metrics:
    #                             # Store metrics
                                self.storage.store_metrics(metrics)

    #                             # Add to buffer for real-time access
    #                             for metric in metrics:
                                    self.buffer.put(metric)

                    time.sleep(1.0)  # Process every second

    #             except Exception as e:
                    logger.error(f"Error in aggregation loop: {e}")
                    time.sleep(1.0)


class AnomalyDetector
    #     """Detects performance anomalies using statistical methods"""

    #     def __init__(self, window_size: int = 100, sensitivity: float = 2.0):
    self.window_size = window_size
    self.sensitivity = sensitivity
    self.metric_windows: Dict[str, deque] = defaultdict(
    lambda: deque(maxlen = window_size)
    #         )
    self._lock = threading.Lock()

    #     def update_metric(self, metric: PerformanceMetric) -None):
    #         """Update metric window for anomaly detection"""
    #         with self._lock:
                self.metric_windows[metric.name].append(metric.value)

    #     def detect_anomalies(self, metric: PerformanceMetric) -List[Dict[str, Any]]):
    #         """Detect anomalies in a metric"""
    anomalies = []

    #         with self._lock:
    window = self.metric_windows[metric.name]

    #             if len(window) < 10:  # Need minimum data for reliable detection
    #                 return anomalies

    values = list(window)
    mean = statistics.mean(values)
    std = statistics.stdev(values)

    #             # Z-score anomaly detection
    #             z_score = abs(metric.value - mean) / std if std 0 else 0

    #             if z_score > self.sensitivity):
                    anomalies.append(
    #                     {
    #                         "metric_name": metric.name,
    #                         "value": metric.value,
                            "expected_range": (
    #                             mean - self.sensitivity * std,
    #                             mean + self.sensitivity * std,
    #                         ),
    #                         "z_score": z_score,
    #                         "severity": "high" if z_score 3.0 else "medium",
                            "timestamp"): metric.timestamp.isoformat(),
    #                     }
    #                 )

    #         return anomalies


class AlertManager
    #     """Manages performance alerts and notifications"""

    #     def __init__(self):
    self.alert_configs: Dict[str, AlertConfig] = {}
    self.alert_history: deque = deque(maxlen=1000)
    self.last_alert_times: Dict[str, datetime] = {}
    self._lock = threading.Lock()

    #     def add_alert_config(self, config: AlertConfig) -None):
    #         """Add an alert configuration"""
    key = f"{config.metric_name}_{config.condition.value}"
    self.alert_configs[key] = config
            logger.info(
                f"Added alert config: {config.metric_name} ({config.condition.value} {config.threshold})"
    #         )

    #     def check_alerts(self, metrics: List[PerformanceMetric]) -List[AlertEvent]):
    #         """Check metrics against alert thresholds"""
    triggered_events = []
    current_time = datetime.now()

    #         with self._lock:
    #             for metric in metrics:
    #                 for key, alert_config in self.alert_configs.items():
    #                     if (
    alert_config.metric_name != metric.name
    #                         or not alert_config.enabled
    #                     ):
    #                         continue

    #                     # Check cooldown period
    last_time = self.last_alert_times.get(key)
    #                     if (
    #                         last_time
                            and (current_time - last_time).total_seconds()
    #                         < alert_config.cooldown_seconds
    #                     ):
    #                         continue

    #                     # Check threshold condition
    triggered = False
    #                     if (
    alert_config.condition == AlertCondition.ABOVE
    #                         and metric.value alert_config.threshold
    #                     )):
    triggered = True
    #                     elif (
    alert_config.condition == AlertCondition.BELOW
    #                         and metric.value < alert_config.threshold
    #                     ):
    triggered = True
    #                     elif (
    alert_config.condition == AlertCondition.EQUALS
                            and abs(metric.value - alert_config.threshold) < 0.001
    #                     ):
    triggered = True

    #                     if triggered:
    alert_event = AlertEvent(
    alert_config = alert_config,
    metric = metric,
    timestamp = current_time,
    #                         )
                            triggered_events.append(alert_event)
                            self.alert_history.append(alert_event)
    self.last_alert_times[key] = current_time

    #                         # Execute callback if provided
    #                         if alert_config.callback:
    #                             try:
                                    alert_config.callback(
    #                                     alert_config.description
    #                                     or f"Alert triggered: {alert_config.metric_name}",
    #                                     metric,
    #                                 )
    #                             except Exception as e:
                                    logger.error(f"Error executing alert callback: {e}")

                            logger.warning(
    #                             f"Performance alert triggered: {alert_config.metric_name} "
                                f"({metric.value} {metric.unit}) {alert_config.condition.value} "
    #                             f"{alert_config.threshold} - {alert_config.severity.value}"
    #                         )

    #         return triggered_events

    #     def get_active_alerts(self) -List[AlertEvent]):
            """Get all active (unacknowledged) alerts"""
    #         with self._lock:
    #             return [event for event in self.alert_history if not event.acknowledged]

    #     def acknowledge_alert(self, alert_id: str) -bool):
    #         """Acknowledge an alert event"""
    #         with self._lock:
    #             for event in self.alert_history:
    #                 if event.id == alert_id:
    event.acknowledged = True
                        logger.info(f"Acknowledged alert: {alert_id}")
    #                     return True
    #         return False


class CorrelationAnalyzer
    #     """Analyzes correlations between performance metrics"""

    #     def __init__(self, correlation_window: int = 100):
    self.correlation_window = correlation_window
    self.metric_data: Dict[str, deque] = defaultdict(
    lambda: deque(maxlen = correlation_window)
    #         )
    self._lock = threading.Lock()

    #     def update_metric(self, metric: PerformanceMetric) -None):
    #         """Update metric data for correlation analysis"""
    #         with self._lock:
                self.metric_data[metric.name].append((metric.timestamp, metric.value))

    #     def calculate_correlation(self, metric1: str, metric2: str) -Optional[float]):
    #         """Calculate correlation between two metrics"""
    #         with self._lock:
    #             if metric1 not in self.metric_data or metric2 not in self.metric_data:
    #                 return None

    data1 = list(self.metric_data[metric1])
    data2 = list(self.metric_data[metric2])

    #             if len(data1) < 10 or len(data2) < 10:
    #                 return None

    #             # Align timestamps and get values
    #             values1 = [v for _, v in data1]
    #             values2 = [v for _, v in data2]

    #             # Calculate Pearson correlation
    #             if len(values1) != len(values2):
    #                 return None

    correlation = np.corrcoef(values1, values2)[0, 1]
    #             return correlation if not np.isnan(correlation) else None

    #     def get_correlation_report(self) -Dict[str, Dict[str, float]]):
    #         """Get correlation report for all metric pairs"""
    report = {}

    #         with self._lock:
    metric_names = list(self.metric_data.keys())

    #             for i, metric1 in enumerate(metric_names):
    report[metric1] = {}
    #                 for metric2 in metric_names[i + 1 :]:  # Avoid duplicate pairs
    correlation = self.calculate_correlation(metric1, metric2)
    #                     if correlation is not None:
    report[metric1][metric2] = correlation

    #         return report


class RealTimeMonitor
    #     """Main real-time performance monitoring system"""

    #     def __init__(
    #         self,
    storage_path: str = "metrics_data",
    max_buffer_size: int = 10000,
    enable_distributed: bool = False,
    redis_host: str = "localhost",
    redis_port: int = 6379,
    #     ):

    #         # Initialize components
    self.buffer = MetricsBuffer(max_buffer_size)
    self.storage = TimeSeriesStorage(storage_path)
    self.aggregator = MetricsAggregator(self.buffer, self.storage)
    self.anomaly_detector = AnomalyDetector()
    self.alert_manager = AlertManager()
    self.correlation_analyzer = CorrelationAnalyzer()

    #         # Distributed monitoring
    self.enable_distributed = enable_distributed
    self.redis_client = None
    self.registered_nodes: Dict[str, NodeInfo] = {}

    #         # System monitoring
    self.system_metrics_thread = None
    self.monitoring_active = False
    self.monitoring_interval = 1.0  # seconds

    #         # Visualization API
    self.api_server = None
    self.api_port = 8080

            logger.info("Real-time performance monitor initialized")

    #     def start(self) -None):
    #         """Start the monitoring system"""
    #         if self.monitoring_active:
    #             return

    #         # Start aggregator
            self.aggregator.start()

    #         # Start system metrics collection
    self.monitoring_active = True
    self.system_metrics_thread = threading.Thread(
    target = self._system_metrics_loop, daemon=True
    #         )
            self.system_metrics_thread.start()

    #         # Initialize Redis for distributed monitoring
    #         if self.enable_distributed:
    #             try:
    self.redis_client = redis.Redis(
    host = "localhost", port=6379, decode_responses=True
    #                 )
    #                 logger.info("Redis client initialized for distributed monitoring")
    #             except Exception as e:
                    logger.error(f"Failed to initialize Redis client: {e}")
    self.enable_distributed = False

            logger.info("Real-time performance monitor started")

    #     def stop(self) -None):
    #         """Stop the monitoring system"""
    self.monitoring_active = False

    #         # Stop aggregator
            self.aggregator.stop()

    #         # Wait for system metrics thread to finish
    #         if self.system_metrics_thread:
    self.system_metrics_thread.join(timeout = 5.0)

    #         # Close Redis connection
    #         if self.redis_client:
                self.redis_client.close()

            logger.info("Real-time performance monitor stopped")

    #     def add_metric_config(self, config: MetricConfig) -None):
    #         """Add a metric configuration"""
            self.aggregator.add_metric_config(config)

    #     def add_alert_config(self, config: AlertConfig) -None):
    #         """Add an alert configuration"""
            self.alert_manager.add_alert_config(config)

    #     def register_node(self, node_info: NodeInfo) -None):
    #         """Register a node for distributed monitoring"""
    #         if not self.enable_distributed:
    #             return

    self.registered_nodes[node_info.node_id] = node_info
            logger.info(f"Node registered: {node_info.node_id}")

    #     def record_metric(self, metric: PerformanceMetric) -None):
    #         """Record a performance metric"""
    #         # Record locally
            self.aggregator.record_metric(metric)

    #         # Update anomaly detector
            self.anomaly_detector.update_metric(metric)

    #         # Update correlation analyzer
            self.correlation_analyzer.update_metric(metric)

    #         # Check for alerts
    alerts = self.alert_manager.check_alerts([metric])

    #         # Publish to Redis if distributed monitoring is enabled
    #         if self.enable_distributed and self.redis_client:
    #             try:
                    self.redis_client.lpush("metrics", json.dumps(metric.to_dict()))
    #             except Exception as e:
                    logger.error(f"Failed to publish metric to Redis: {e}")

    #     def get_metrics(
    #         self, metric_name: str, start_time: datetime, end_time: datetime
    #     ) -List[PerformanceMetric]):
    #         """Get metrics for a specific time range"""
            return self.storage.get_metrics(metric_name, start_time, end_time)

    #     def get_metric_summary(
    #         self, metric_name: str, start_time: datetime, end_time: datetime
    #     ) -Dict[str, Any]):
    #         """Get summary statistics for a metric"""
            return self.storage.get_metric_summary(metric_name, start_time, end_time)

    #     def get_system_summary(self) -Dict[str, Any]):
    #         """Get system performance summary"""
    summary = {
                "timestamp": datetime.now().isoformat(),
                "buffer_size": self.buffer.size(),
                "active_nodes": len(self.registered_nodes),
                "active_alerts": len(self.alert_manager.get_active_alerts()),
    #             "monitoring_active": self.monitoring_active,
    #         }

    #         # Add recent alert summary
    recent_alerts = list(self.alert_manager.alert_history)[ - 10:]
    summary["recent_alerts"] = [
    #             {
    #                 "metric": event.alert_config.metric_name,
    #                 "value": event.metric.value,
    #                 "threshold": event.alert_config.threshold,
    #                 "severity": event.alert_config.severity.value,
                    "timestamp": event.timestamp.isoformat(),
    #                 "acknowledged": event.acknowledged,
    #             }
    #             for event in recent_alerts
    #         ]

    #         # Add correlation summary
    correlations = self.correlation_analyzer.get_correlation_report()
    #         if correlations:
    summary["correlations"] = correlations

    #         return summary

    #     def _system_metrics_loop(self) -None):
    #         """Collect system metrics in background thread"""
    #         while self.monitoring_active:
    #             try:
    #                 # Collect CPU metrics
    cpu_percent = psutil.cpu_percent(interval=None)
                    self.record_metric(
                        PerformanceMetric(
    name = "cpu_usage_percent",
    value = cpu_percent,
    unit = "percent",
    timestamp = datetime.now(),
    metric_type = MetricType.GAUGE,
    tags = {"source": "system"},
    #                     )
    #                 )

    #                 # Collect memory metrics
    memory = psutil.virtual_memory()
                    self.record_metric(
                        PerformanceMetric(
    name = "memory_usage_percent",
    value = memory.percent,
    unit = "percent",
    timestamp = datetime.now(),
    metric_type = MetricType.GAUGE,
    tags = {"source": "system"},
    #                     )
    #                 )

    #                 # Collect disk metrics
    disk = psutil.disk_usage("/")
                    self.record_metric(
                        PerformanceMetric(
    name = "disk_usage_percent",
    value = disk.percent,
    unit = "percent",
    timestamp = datetime.now(),
    metric_type = MetricType.GAUGE,
    tags = {"source": "system"},
    #                     )
    #                 )

    #                 # Collect network metrics
    network = psutil.net_io_counters()
                    self.record_metric(
                        PerformanceMetric(
    name = "network_bytes_sent",
    value = network.bytes_sent,
    unit = "bytes",
    timestamp = datetime.now(),
    metric_type = MetricType.COUNTER,
    tags = {"source": "system"},
    #                     )
    #                 )

                    self.record_metric(
                        PerformanceMetric(
    name = "network_bytes_recv",
    value = network.bytes_recv,
    unit = "bytes",
    timestamp = datetime.now(),
    metric_type = MetricType.COUNTER,
    tags = {"source": "system"},
    #                     )
    #                 )

                    time.sleep(self.monitoring_interval)

    #             except Exception as e:
                    logger.error(f"Error collecting system metrics: {e}")
                    time.sleep(self.monitoring_interval)


# Global instance
_global_monitor: Optional[RealTimeMonitor] = None


def get_real_time_monitor() -RealTimeMonitor):
#     """Get global real-time monitor instance"""
#     global _global_monitor

#     if _global_monitor is None:
_global_monitor = RealTimeMonitor()

#     return _global_monitor


def start_monitoring() -RealTimeMonitor):
#     """Start the global real-time monitor"""
monitor = get_real_time_monitor()
    monitor.start()
#     return monitor


def stop_monitoring() -None):
#     """Stop the global real-time monitor"""
monitor = get_real_time_monitor()
    monitor.stop()
