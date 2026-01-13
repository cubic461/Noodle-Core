# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Cache Monitoring Module
# ----------------------

# This module provides comprehensive cache monitoring capabilities to track cache performance,
# collect statistics, and provide insights into cache behavior.
# """

import base64
import json
import logging
import os
import pickle
import statistics
import threading
import time
import abc.ABC,
import collections.OrderedDict,
import concurrent.futures.ThreadPoolExecutor
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import io.BytesIO
import typing.(
#     Any,
#     Callable,
#     Dict,
#     Generic,
#     List,
#     Optional,
#     Set,
#     Tuple,
#     TypeVar,
#     Union,
# )

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import psutil
import seaborn as sns


class CacheMetricType(Enum)
    #     """Types of cache metrics."""

    HIT_RATE = "hit_rate"
    MISS_RATE = "miss_rate"
    EVICTION_COUNT = "eviction_count"
    MEMORY_USAGE = "memory_usage"
    ACCESS_COUNT = "access_count"
    AVG_ACCESS_TIME = "avg_access_time"
    CACHE_SIZE = "cache_size"
    CACHE_UTILIZATION = "cache_utilization"
    EFFICIENCY = "efficiency"
    COST_PER_HIT = "cost_per_hit"
    ROI = "roi"
    ERROR_RATE = "error_rate"
    THROUGHPUT = "throughput"
    LATENCY = "latency"
    CPU_UTILIZATION = "cpu_utilization"
    MEMORY_PRESSURE = "memory_pressure"
    I_O_UTILIZATION = "io_utilization"


class CacheHealthStatus(Enum)
    #     """Cache health status levels."""

    HEALTHY = "healthy"
    WARNING = "warning"
    CRITICAL = "critical"
    UNKNOWN = "unknown"


# @dataclass
class CacheMetric
    #     """Represents a cache metric with metadata."""

    #     metric_type: CacheMetricType
    #     value: float
    #     timestamp: float
    tags: Dict[str, str] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert metric to dictionary."""
    #         return {
    #             "metric_type": self.metric_type.value,
    #             "value": self.value,
    #             "timestamp": self.timestamp,
    #             "tags": self.tags,
    #             "metadata": self.metadata,
    #         }


# @dataclass
class CacheThreshold
    #     """Represents a cache threshold configuration."""

    #     metric_type: CacheMetricType
    #     warning_threshold: float
    #     critical_threshold: float
    enabled: bool = True
    alert_callback: Optional[Callable] = None


# @dataclass
class CacheAlert
    #     """Represents a cache alert."""

    #     alert_id: str
    #     metric_type: CacheMetricType
    #     current_value: float
    #     threshold_value: float
    #     status: CacheHealthStatus
    #     timestamp: float
    #     message: str
    tags: Dict[str, str] = field(default_factory=dict)
    acknowledged: bool = False


# @dataclass
class CacheTopologyNode
    #     """Represents a node in cache topology."""

    #     node_id: str
    #     node_type: str  # e.g., 'L1', 'L2', 'L3', 'RAM', 'DISK'
    #     size: int  # in bytes
    hit_count: int = 0
    miss_count: int = 0
    children: List["CacheTopologyNode"] = field(default_factory=list)
    parent: Optional["CacheTopologyNode"] = None

    #     def add_child(self, child: "CacheTopologyNode") -> None:
    #         """Add a child node."""
    child.parent = self
            self.children.append(child)

    #     def get_hit_rate(self) -> float:
    #         """Calculate hit rate for this node."""
    total = math.add(self.hit_count, self.miss_count)
    #         return self.hit_count / total if total > 0 else 0.0

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert node to dictionary."""
    #         return {
    #             "node_id": self.node_id,
    #             "node_type": self.node_type,
    #             "size": self.size,
    #             "hit_count": self.hit_count,
    #             "miss_count": self.miss_count,
                "hit_rate": self.get_hit_rate(),
    #             "children": [child.to_dict() for child in self.children],
    #         }


# @dataclass
class CacheAccessPattern
    #     """Represents a cache access pattern."""

    #     pattern_id: str
    #     key_pattern: str
    #     access_frequency: float
    #     access_times: List[float]
    #     hit_rate: float
    #     last_accessed: float
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class CacheEfficiencyMetrics
    #     """Represents cache efficiency metrics."""

    #     cost_per_hit: float
    #     roi: float
    #     savings: float
    #     overhead: float
    #     efficiency_score: float
    #     timestamp: float


class CacheMonitor
    #     """Main cache monitoring class."""

    #     def __init__(self, cache: Any, config: Optional[Dict[str, Any]] = None):
    #         """Initialize cache monitor.

    #         Args:
    #             cache: Cache instance to monitor
    #             config: Configuration dictionary
    #         """
    self.cache = cache
    self.config = config or {}
    self.logger = logging.getLogger(__name__)

    #         # Metrics storage
    self.metrics: Dict[CacheMetricType, deque] = defaultdict(
    lambda: deque(maxlen = 1000)
    #         )
    self.metrics_history: List[CacheMetric] = []
    self.alerts: List[CacheAlert] = []
    self.thresholds: Dict[CacheMetricType, CacheThreshold] = {}

    #         # Performance tracking
    self.access_times: List[float] = deque(maxlen=1000)
    self.hit_count = 0
    self.miss_count = 0
    self.eviction_count = 0
    self.error_count = 0

    #         # Resource monitoring
    self.cpu_usage: deque = deque(maxlen=100)
    self.memory_usage: deque = deque(maxlen=100)
    self.io_usage: deque = deque(maxlen=100)

    #         # Pattern analysis
    self.access_patterns: Dict[str, CacheAccessPattern] = {}
    self.anomaly_detection_window = 3600  # 1 hour

    #         # Efficiency metrics
    self.efficiency_metrics: List[CacheEfficiencyMetrics] = []

    #         # Topology
    self.topology: Optional[CacheTopologyNode] = None

    #         # Threading
    self._stop_event = threading.Event()
    self._monitor_thread = None
    self._metrics_lock = threading.Lock()

    #         # Initialize default thresholds
            self._initialize_default_thresholds()

    #         # Start monitoring
            self.start_monitoring()

    #     def _initialize_default_thresholds(self) -> None:
    #         """Initialize default thresholds for metrics."""
    default_thresholds = {
                CacheMetricType.HIT_RATE: CacheThreshold(
    #                 CacheMetricType.HIT_RATE, 0.8, 0.6
    #             ),
                CacheMetricType.MEMORY_USAGE: CacheThreshold(
    #                 CacheMetricType.MEMORY_USAGE, 0.8, 0.95
    #             ),
                CacheMetricType.ERROR_RATE: CacheThreshold(
    #                 CacheMetricType.ERROR_RATE, 0.01, 0.05
    #             ),
                CacheMetricType.LATENCY: CacheThreshold(
    #                 CacheMetricType.LATENCY, 0.1, 0.5  # seconds
    #             ),
                CacheMetricType.CPU_UTILIZATION: CacheThreshold(
    #                 CacheMetricType.CPU_UTILIZATION, 0.7, 0.9
    #             ),
                CacheMetricType.MEMORY_PRESSURE: CacheThreshold(
    #                 CacheMetricType.MEMORY_PRESSURE, 0.8, 0.95
    #             ),
    #         }

    #         for metric_type, threshold in default_thresholds.items():
    self.thresholds[metric_type] = threshold

    #     def start_monitoring(self) -> None:
    #         """Start cache monitoring."""
    #         if self._monitor_thread is not None and self._monitor_thread.is_alive():
    #             return

            self._stop_event.clear()
    self._monitor_thread = threading.Thread(
    target = self._monitor_worker, daemon=True
    #         )
            self._monitor_thread.start()

    #         # Start resource monitoring
            self._start_resource_monitoring()

    #     def stop_monitoring(self) -> None:
    #         """Stop cache monitoring."""
            self._stop_event.set()
    #         if self._monitor_thread is not None:
                self._monitor_thread.join()

    #         # Stop resource monitoring
            self._stop_resource_monitoring()

    #     def _monitor_worker(self) -> None:
    #         """Background monitoring worker."""
    interval = self.config.get("monitoring_interval", 60)  # 60 seconds

    #         while not self._stop_event.wait(interval):
    #             try:
                    self._collect_metrics()
                    self._analyze_patterns()
                    self._check_thresholds()
                    self._update_efficiency_metrics()
    #             except Exception as e:
                    self.logger.error(f"Error in monitoring worker: {e}")

    #     def _collect_metrics(self) -> None:
    #         """Collect cache metrics."""
    current_time = time.time()

    #         with self._metrics_lock:
    #             # Calculate hit rate
    total_accesses = math.add(self.hit_count, self.miss_count)
    #             hit_rate = self.hit_count / total_accesses if total_accesses > 0 else 0.0
    miss_rate = math.subtract(1.0, hit_rate)

    #             # Get cache size and memory usage
    #             cache_size = len(self.cache._cache) if hasattr(self.cache, "_cache") else 0
    max_size = (
                    getattr(self.cache.config, "max_size", 1000)
    #                 if hasattr(self.cache, "config")
    #                 else 1000
    #             )
    #             cache_utilization = cache_size / max_size if max_size > 0 else 0.0

    #             # Calculate average access time
    avg_access_time = (
    #                 statistics.mean(self.access_times) if self.access_times else 0.0
    #             )

    #             # Calculate error rate
    error_rate = (
    #                 self.error_count / total_accesses if total_accesses > 0 else 0.0
    #             )

                # Calculate throughput (operations per second)
    time_window = 60  # last 60 seconds
    recent_accesses = sum(
    #                 1 for t in self.access_times if current_time - t <= time_window
    #             )
    #             throughput = recent_accesses / time_window if time_window > 0 else 0.0

    #             # Create metrics
    metrics_to_add = [
                    CacheMetric(CacheMetricType.HIT_RATE, hit_rate, current_time),
                    CacheMetric(CacheMetricType.MISS_RATE, miss_rate, current_time),
                    CacheMetric(CacheMetricType.ACCESS_COUNT, total_accesses, current_time),
                    CacheMetric(
    #                     CacheMetricType.AVG_ACCESS_TIME, avg_access_time, current_time
    #                 ),
                    CacheMetric(CacheMetricType.CACHE_SIZE, cache_size, current_time),
                    CacheMetric(
    #                     CacheMetricType.CACHE_UTILIZATION, cache_utilization, current_time
    #                 ),
                    CacheMetric(CacheMetricType.ERROR_RATE, error_rate, current_time),
                    CacheMetric(CacheMetricType.THROUGHPUT, throughput, current_time),
                    CacheMetric(
    #                     CacheMetricType.EVICTION_COUNT, self.eviction_count, current_time
    #                 ),
    #             ]

    #             # Add metrics to storage
    #             for metric in metrics_to_add:
                    self.metrics[metric.metric_type].append(metric)
                    self.metrics_history.append(metric)

    #             # Update topology if available
    #             if self.topology:
                    self._update_topology_metrics()

    #     def _start_resource_monitoring(self) -> None:
    #         """Start resource monitoring thread."""

    #         def resource_worker():
    interval = self.config.get("resource_monitoring_interval", 5)  # 5 seconds

    #             while not self._stop_event.wait(interval):
    #                 try:
    #                     # CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)
                        self.cpu_usage.append(cpu_percent)

    #                     # Memory usage
    memory = psutil.virtual_memory()
                        self.memory_usage.append(memory.percent)

                        # I/O usage (simplified)
    io_counters = psutil.disk_io_counters()
    #                     if io_counters:
    io_percent = min(
    #                             100,
                                (io_counters.read_bytes + io_counters.write_bytes)
                                / (1024 * 1024),
    #                         )  # MB
                            self.io_usage.append(io_percent)
    #                 except Exception as e:
                        self.logger.error(f"Error in resource monitoring: {e}")

    resource_thread = threading.Thread(target=resource_worker, daemon=True)
            resource_thread.start()

    #     def _stop_resource_monitoring(self) -> None:
    #         """Stop resource monitoring."""
    #         # This is a placeholder - in a real implementation, we'd need to track the resource thread
    #         pass

    #     def _analyze_patterns(self) -> None:
    #         """Analyze access patterns."""
    current_time = time.time()
    window_start = math.subtract(current_time, self.anomaly_detection_window)

    #         # Group recent accesses by key patterns
    recent_accesses = defaultdict(list)
    #         for access_time in self.access_times:
    #             if access_time >= window_start:
    #                 # This would need to be adapted based on actual cache key structure
    #                 # For now, we'll use a simplified approach
    key_pattern = "general"  # Placeholder
                    recent_accesses[key_pattern].append(access_time)

    #         # Update or create access patterns
    #         for pattern_key, access_times in recent_accesses.items():
    #             if pattern_key not in self.access_patterns:
    self.access_patterns[pattern_key] = CacheAccessPattern(
    pattern_id = pattern_key,
    key_pattern = pattern_key,
    access_frequency = 0.0,
    access_times = [],
    hit_rate = 0.0,
    last_accessed = 0.0,
    #                 )

    pattern = self.access_patterns[pattern_key]
                pattern.access_times.extend(access_times)
    pattern.last_accessed = current_time

    #             # Calculate frequency
    pattern.access_frequency = math.divide(len(access_times), self.anomaly_detection_window)

    #             # Keep only recent access times
    #             recent_times = [t for t in pattern.access_times if t >= window_start]
    #             if len(recent_times) != len(pattern.access_times):
    pattern.access_times = recent_times

    #     def _check_thresholds(self) -> None:
    #         """Check metric thresholds and generate alerts."""
    current_time = time.time()

    #         for metric_type, threshold in self.thresholds.items():
    #             if not threshold.enabled:
    #                 continue

    #             # Get current metric value
    current_value = 0.0
    #             if metric_type in self.metrics and self.metrics[metric_type]:
    current_value = math.subtract(self.metrics[metric_type][, 1].value)

    #             # Check against thresholds
    status = CacheHealthStatus.HEALTHY
    message = ""

    #             if current_value >= threshold.critical_threshold:
    status = CacheHealthStatus.CRITICAL
    message = f"{metric_type.value} is critical: {current_value:.4f} >= {threshold.critical_threshold:.4f}"
    #             elif current_value >= threshold.warning_threshold:
    status = CacheHealthStatus.WARNING
    message = f"{metric_type.value} is warning: {current_value:.4f} >= {threshold.warning_threshold:.4f}"

    #             if status != CacheHealthStatus.HEALTHY:
    #                 # Create alert
    alert = CacheAlert(
    alert_id = f"{metric_type.value}_{int(current_time)}",
    metric_type = metric_type,
    current_value = current_value,
    threshold_value = (
    #                         threshold.warning_threshold
    #                         if status == CacheHealthStatus.WARNING
    #                         else threshold.critical_threshold
    #                     ),
    status = status,
    timestamp = current_time,
    message = message,
    tags = {"metric_type": metric_type.value},
    #                 )

                    self.alerts.append(alert)

    #                 # Call alert callback if provided
    #                 if threshold.alert_callback:
    #                     try:
                            threshold.alert_callback(alert)
    #                     except Exception as e:
                            self.logger.error(f"Error in alert callback: {e}")

    #     def _update_efficiency_metrics(self) -> None:
    #         """Update cache efficiency metrics."""
    current_time = time.time()

            # Calculate cost per hit (simplified)
    #         # In a real implementation, this would consider actual costs
    #         operational_cost = self.cpu_usage[-1] / 100.0 if self.cpu_usage else 0.0
    #         memory_cost = self.memory_usage[-1] / 100.0 if self.memory_usage else 0.0
    total_cost = math.add(operational_cost, memory_cost)

    hits = self.hit_count
    #         cost_per_hit = total_cost / hits if hits > 0 else 0.0

            # Calculate ROI (simplified)
    #         # Assuming each hit saves a certain amount of time/resources
    time_per_miss = 0.1  # seconds (assumed cost of a miss)
    savings = math.multiply(hits, time_per_miss)
    overhead = math.multiply(total_cost, 3600  # cost per hour)

    #         roi = (savings - overhead) / overhead if overhead > 0 else 0.0

            # Calculate efficiency score (0-1)
    efficiency_score = min(
    #             1.0,
                (self.hit_count / (self.hit_count + self.miss_count)) * (1.0 - total_cost),
    #         )

    #         # Create efficiency metrics
    efficiency_metric = CacheEfficiencyMetrics(
    cost_per_hit = cost_per_hit,
    roi = roi,
    savings = savings,
    overhead = overhead,
    efficiency_score = efficiency_score,
    timestamp = current_time,
    #         )

            self.efficiency_metrics.append(efficiency_metric)

    #         # Keep only recent metrics
    #         if len(self.efficiency_metrics) > 1000:
    self.efficiency_metrics = math.subtract(self.efficiency_metrics[, 1000:])

    #     def _update_topology_metrics(self) -> None:
    #         """Update topology metrics."""
    #         if not self.topology:
    #             return

    #         # This is a simplified implementation
    #         # In a real system, we would traverse the topology and update metrics
    #         # based on actual cache performance data

    #         # Update root node metrics
    self.topology.hit_count = self.hit_count
    self.topology.miss_count = self.miss_count

    #     def record_hit(self, key: str, access_time: float = None) -> None:
    #         """Record a cache hit.

    #         Args:
    #             key: Cache key that was accessed
    #             access_time: Time of access (current time if None)
    #         """
    current_time = access_time or time.time()
            self.access_times.append(current_time)
    self.hit_count + = 1

    #         # Update access pattern
    self._update_access_pattern(key, current_time, hit = True)

    #     def record_miss(self, key: str, access_time: float = None) -> None:
    #         """Record a cache miss.

    #         Args:
    #             key: Cache key that was accessed
    #             access_time: Time of access (current time if None)
    #         """
    current_time = access_time or time.time()
            self.access_times.append(current_time)
    self.miss_count + = 1

    #         # Update access pattern
    self._update_access_pattern(key, current_time, hit = False)

    #     def record_eviction(self) -> None:
    #         """Record a cache eviction."""
    self.eviction_count + = 1

    #     def record_error(self) -> None:
    #         """Record a cache error."""
    self.error_count + = 1

    #     def _update_access_pattern(self, key: str, access_time: float, hit: bool) -> None:
    #         """Update access pattern for a key."""
            # Extract pattern from key (simplified)
    #         # In a real implementation, this would be more sophisticated
    pattern_parts = key.split(":")
    pattern_key = (
    #             ":".join(pattern_parts[:2]) if len(pattern_parts) > 1 else "general"
    #         )

    #         if pattern_key not in self.access_patterns:
    self.access_patterns[pattern_key] = CacheAccessPattern(
    pattern_id = pattern_key,
    key_pattern = pattern_key,
    access_frequency = 0.0,
    access_times = [],
    hit_rate = 0.0,
    last_accessed = 0.0,
    #             )

    pattern = self.access_patterns[pattern_key]
            pattern.access_times.append(access_time)
    pattern.last_accessed = access_time

    #         # Update hit rate
    total_accesses = len(pattern.access_times)
    hit_count = sum(
    #             1 for t in pattern.access_times[-10:] if t == access_time and hit
    #         )  # Simplified
    pattern.hit_rate = math.divide(hit_count, min(10, total_accesses))

    #     def set_topology(self, topology: CacheTopologyNode) -> None:
    #         """Set cache topology.

    #         Args:
    #             topology: Root node of cache topology
    #         """
    self.topology = topology

    #     def get_metrics(
    #         self,
    metric_type: Optional[CacheMetricType] = None,
    start_time: Optional[float] = None,
    end_time: Optional[float] = None,
    #     ) -> List[CacheMetric]:
    #         """Get cache metrics.

    #         Args:
    #             metric_type: Specific metric type to retrieve (all if None)
    #             start_time: Start time for filtering (all if None)
    #             end_time: End time for filtering (all if None)

    #         Returns:
    #             List of metrics
    #         """
    #         if metric_type:
    metrics = list(self.metrics.get(metric_type, []))
    #         else:
    metrics = self.metrics_history.copy()

    #         # Filter by time range
    #         if start_time or end_time:
    filtered_metrics = []
    #             for metric in metrics:
    #                 if start_time and metric.timestamp < start_time:
    #                     continue
    #                 if end_time and metric.timestamp > end_time:
    #                     continue
                    filtered_metrics.append(metric)
    metrics = filtered_metrics

    #         return metrics

    #     def get_alerts(
    #         self,
    status: Optional[CacheHealthStatus] = None,
    acknowledged: Optional[bool] = None,
    #     ) -> List[CacheAlert]:
    #         """Get cache alerts.

    #         Args:
    #             status: Filter by status (all if None)
    #             acknowledged: Filter by acknowledgment status (all if None)

    #         Returns:
    #             List of alerts
    #         """
    alerts = self.alerts.copy()

    #         # Filter by status
    #         if status:
    #             alerts = [alert for alert in alerts if alert.status == status]

    #         # Filter by acknowledgment
    #         if acknowledged is not None:
    #             alerts = [alert for alert in alerts if alert.acknowledged == acknowledged]

    #         return alerts

    #     def acknowledge_alert(self, alert_id: str) -> bool:
    #         """Acknowledge an alert.

    #         Args:
    #             alert_id: ID of the alert to acknowledge

    #         Returns:
    #             True if alert was found and acknowledged, False otherwise
    #         """
    #         for alert in self.alerts:
    #             if alert.alert_id == alert_id:
    alert.acknowledged = True
    #                 return True
    #         return False

    #     def get_access_patterns(self) -> Dict[str, CacheAccessPattern]:
    #         """Get access patterns.

    #         Returns:
    #             Dictionary of access patterns
    #         """
            return self.access_patterns.copy()

    #     def get_efficiency_metrics(self) -> List[CacheEfficiencyMetrics]:
    #         """Get efficiency metrics.

    #         Returns:
    #             List of efficiency metrics
    #         """
            return self.efficiency_metrics.copy()

    #     def get_topology(self) -> Optional[CacheTopologyNode]:
    #         """Get cache topology.

    #         Returns:
    #             Root node of cache topology or None if not set
    #         """
    #         return self.topology

    #     def get_health_status(self) -> CacheHealthStatus:
    #         """Get overall cache health status.

    #         Returns:
    #             Current health status
    #         """
    #         # Check critical alerts first
    critical_alerts = [
    #             alert for alert in self.alerts if alert.status == CacheHealthStatus.CRITICAL
    #         ]
    #         if critical_alerts:
    #             return CacheHealthStatus.CRITICAL

    #         # Check warning alerts
    warning_alerts = [
    #             alert for alert in self.alerts if alert.status == CacheHealthStatus.WARNING
    #         ]
    #         if warning_alerts:
    #             return CacheHealthStatus.WARNING

    #         # Default to healthy if no alerts
    #         return CacheHealthStatus.HEALTHY

    #     def export_metrics(
    #         self,
    format: str = "json",
    start_time: Optional[float] = None,
    end_time: Optional[float] = None,
    #     ) -> Union[str, bytes]:
    #         """Export metrics in specified format.

    #         Args:
                format: Export format ('json', 'csv', 'pickle')
    #             start_time: Start time for filtering (all if None)
    #             end_time: End time for filtering (all if None)

    #         Returns:
    #             Exported data as string or bytes
    #         """
    metrics = self.get_metrics(start_time=start_time, end_time=end_time)

    #         if format == "json":
    data = {
    #                 "metrics": [metric.to_dict() for metric in metrics],
    #                 "alerts": [alert.__dict__ for alert in self.alerts],
    #                 "efficiency_metrics": [
    #                     metric.__dict__ for metric in self.efficiency_metrics
    #                 ],
                    "timestamp": time.time(),
    #             }
    return json.dumps(data, indent = 2)

    #         elif format == "csv":
    #             # Convert to DataFrame and then to CSV
    df_data = []
    #             for metric in metrics:
                    df_data.append(
    #                     {
    #                         "timestamp": metric.timestamp,
    #                         "metric_type": metric.metric_type.value,
    #                         "value": metric.value,
                            "tags": json.dumps(metric.tags),
                            "metadata": json.dumps(metric.metadata),
    #                     }
    #                 )

    df = pd.DataFrame(df_data)
    return df.to_csv(index = False)

    #         elif format == "pickle":
    data = {
    #                 "metrics": metrics,
    #                 "alerts": self.alerts,
    #                 "efficiency_metrics": self.efficiency_metrics,
                    "timestamp": time.time(),
    #             }
                return pickle.dumps(data)

    #         else:
                raise ValueError(f"Unsupported export format: {format}")

    #     def generate_visualization(
    self, metric_type: CacheMetricType, chart_type: str = "line"
    #     ) -> str:
    #         """Generate visualization for a metric.

    #         Args:
    #             metric_type: Metric type to visualize
                chart_type: Type of chart ('line', 'bar', 'histogram')

    #         Returns:
    #             Base64 encoded image data
    #         """
    metrics = self.get_metrics(metric_type)

    #         if not metrics:
    #             return ""

    #         # Prepare data
    #         timestamps = [m.timestamp for m in metrics]
    #         values = [m.value for m in metrics]

    #         # Create plot
    plt.figure(figsize = (10, 6))

    #         if chart_type == "line":
                plt.plot(timestamps, values)
    #         elif chart_type == "bar":
                plt.bar(timestamps, values)
    #         elif chart_type == "histogram":
    plt.hist(values, bins = 20)
    #         else:
                raise ValueError(f"Unsupported chart type: {chart_type}")

            plt.title(f"{metric_type.value} Over Time")
            plt.xlabel("Time")
            plt.ylabel("Value")

    #         # Convert to base64
    buffer = BytesIO()
    plt.savefig(buffer, format = "png")
            buffer.seek(0)
    image_base64 = base64.b64encode(buffer.getvalue()).decode()
            plt.close()

    #         return image_base64

    #     def generate_dashboard_data(self) -> Dict[str, Any]:
    #         """Generate data for cache monitoring dashboard.

    #         Returns:
    #             Dictionary containing dashboard data
    #         """
    current_time = time.time()

    #         # Current metrics
    current_metrics = {}
    #         for metric_type, metrics_queue in self.metrics.items():
    #             if metrics_queue:
    current_metrics[metric_type.value] = {
    #                     "value": metrics_queue[-1].value,
    #                     "timestamp": metrics_queue[-1].timestamp,
    #                     "min": min(m.value for m in metrics_queue),
    #                     "max": max(m.value for m in metrics_queue),
    #                     "avg": statistics.mean(m.value for m in metrics_queue),
    #                 }

    #         # Alerts summary
    alerts_summary = {
                "total": len(self.alerts),
                "critical": len(
    #                 [a for a in self.alerts if a.status == CacheHealthStatus.CRITICAL]
    #             ),
                "warning": len(
    #                 [a for a in self.alerts if a.status == CacheHealthStatus.WARNING]
    #             ),
    #             "acknowledged": len([a for a in self.alerts if a.acknowledged]),
    #         }

    #         # Efficiency metrics
    efficiency_summary = {}
    #         if self.efficiency_metrics:
    latest = math.subtract(self.efficiency_metrics[, 1])
    efficiency_summary = {
    #                 "cost_per_hit": latest.cost_per_hit,
    #                 "roi": latest.roi,
    #                 "efficiency_score": latest.efficiency_score,
    #                 "savings": latest.savings,
    #                 "overhead": latest.overhead,
    #             }

    #         # Topology visualization data
    topology_data = None
    #         if self.topology:
    topology_data = self.topology.to_dict()

    #         # Access patterns summary
    patterns_summary = {}
    #         for pattern_id, pattern in self.access_patterns.items():
    patterns_summary[pattern_id] = {
    #                 "access_frequency": pattern.access_frequency,
    #                 "hit_rate": pattern.hit_rate,
    #                 "last_accessed": pattern.last_accessed,
    #             }

    #         return {
    #             "timestamp": current_time,
    #             "metrics": current_metrics,
    #             "alerts": alerts_summary,
    #             "efficiency": efficiency_summary,
    #             "topology": topology_data,
    #             "patterns": patterns_summary,
                "health_status": self.get_health_status().value,
    #         }

    #     def __del__(self):
    #         """Cleanup when object is destroyed."""
            self.stop_monitoring()


def create_cache_monitor(
cache: Any, config: Optional[Dict[str, Any]] = None
# ) -> CacheMonitor:
#     """Create a cache monitor.

#     Args:
#         cache: Cache instance to monitor
#         config: Configuration dictionary

#     Returns:
#         CacheMonitor instance
#     """
    return CacheMonitor(cache, config)
