# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Monitor for Noodle Runtime

# This module provides comprehensive performance monitoring capabilities including:
# - Real-time performance metrics collection
# - Performance analysis and reporting
# - Resource usage tracking
# - Performance optimization recommendations
# """

import json
import logging
import threading
import time
import collections.deque
import dataclasses.dataclass,
import datetime.datetime
import typing.Any,

import psutil

logger = logging.getLogger(__name__)


# @dataclass
class PerformanceMetrics
    #     """Container for performance metrics."""

    #     timestamp: float
    #     cpu_percent: float
    #     memory_percent: float
    #     memory_used: float
    #     memory_total: float
    #     disk_read: float
    #     disk_write: float
    #     network_sent: float
    #     network_recv: float
    custom_metrics: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class PerformanceSnapshot
    #     """Snapshot of performance at a specific time."""

    #     timestamp: datetime
    #     metrics: PerformanceMetrics
    #     execution_stats: Dict[str, Any]
    #     memory_stats: Dict[str, Any]
    #     thread_stats: Dict[str, Any]


class PerformanceMonitor
    #     """
    #     Comprehensive performance monitoring system for Noodle runtime.

    #     Features:
    #     - Real-time metrics collection
    #     - Historical data storage and analysis
    #     - Performance threshold monitoring
    #     - Automated optimization suggestions
    #     - Thread-safe operation
    #     """

    #     def __init__(
    #         self,
    max_history_size: int = 1000,
    collection_interval: float = 1.0,
    enable_thread_monitoring: bool = True,
    #     ):
    #         """
    #         Initialize the performance monitor.

    #         Args:
    #             max_history_size: Maximum number of historical metrics to store
    #             collection_interval: Interval for metrics collection in seconds
    #             enable_thread_monitoring: Whether to monitor thread activity
    #         """
    self.max_history_size = max_history_size
    self.collection_interval = collection_interval
    self.enable_thread_monitoring = enable_thread_monitoring

    #         # Data storage
    self.metrics_history: deque = deque(maxlen=max_history_size)
    self.performance_snapshots: List[PerformanceSnapshot] = []

    #         # Monitoring state
    self.is_monitoring = False
    self.monitor_thread: Optional[threading.Thread] = None
    self.collection_lock = threading.Lock()

    #         # Callbacks
    self.threshold_callbacks: List[Callable[[PerformanceMetrics], None]] = []
    self.custom_collectors: List[Callable[[], Dict[str, Any]]] = []

    #         # Performance thresholds
    self.thresholds = {
    #             "cpu_percent": 80.0,
    #             "memory_percent": 85.0,
    #             "disk_usage_percent": 90.0,
    #         }

    #         # Statistics
    self.total_collections = 0
    self.threshold_violations = 0

            logger.info(
    #             f"PerformanceMonitor initialized with {max_history_size} max history size"
    #         )

    #     def start_monitoring(self) -> None:
    #         """Start performance monitoring in a background thread."""
    #         if self.is_monitoring:
                logger.warning("Performance monitoring is already running")
    #             return

    self.is_monitoring = True
    self.monitor_thread = threading.Thread(
    target = self._monitoring_loop, daemon=True, name="PerformanceMonitor"
    #         )
            self.monitor_thread.start()
            logger.info("Performance monitoring started")

    #     def stop_monitoring(self) -> None:
    #         """Stop performance monitoring."""
    #         if not self.is_monitoring:
                logger.warning("Performance monitoring is not running")
    #             return

    self.is_monitoring = False
    #         if self.monitor_thread:
    self.monitor_thread.join(timeout = 5.0)
            logger.info("Performance monitoring stopped")

    #     def _monitoring_loop(self) -> None:
    #         """Main monitoring loop running in background thread."""
    #         while self.is_monitoring:
    #             try:
    metrics = self.collect_metrics()
                    self._store_metrics(metrics)
                    self._check_thresholds(metrics)
                    self._collect_custom_metrics(metrics)

    self.total_collections + = 1

    #             except Exception as e:
                    logger.error(f"Error in performance monitoring loop: {e}")

                time.sleep(self.collection_interval)

    #     def collect_metrics(self) -> PerformanceMetrics:
    #         """
    #         Collect current performance metrics.

    #         Returns:
    #             Current performance metrics
    #         """
    #         try:
    #             # System metrics
    cpu_percent = psutil.cpu_percent(interval=None)
    memory = psutil.virtual_memory()
    disk_io = psutil.disk_io_counters()
    network_io = psutil.net_io_counters()

    metrics = PerformanceMetrics(
    timestamp = time.time(),
    cpu_percent = cpu_percent,
    memory_percent = memory.percent,
    memory_used = memory.used,
    memory_total = memory.total,
    #                 disk_read=disk_io.read_bytes if disk_io else 0,
    #                 disk_write=disk_io.write_bytes if disk_io else 0,
    #                 network_sent=network_io.bytes_sent if network_io else 0,
    #                 network_recv=network_io.bytes_recv if network_io else 0,
    #             )

    #             return metrics

    #         except Exception as e:
                logger.error(f"Error collecting performance metrics: {e}")
    #             # Return default metrics on error
                return PerformanceMetrics(
    timestamp = time.time(),
    cpu_percent = 0.0,
    memory_percent = 0.0,
    memory_used = 0,
    memory_total = 0,
    disk_read = 0,
    disk_write = 0,
    network_sent = 0,
    network_recv = 0,
    #             )

    #     def _store_metrics(self, metrics: PerformanceMetrics) -> None:
    #         """Store metrics in history."""
    #         with self.collection_lock:
                self.metrics_history.append(metrics)

    #     def _check_thresholds(self, metrics: PerformanceMetrics) -> None:
    #         """Check if metrics exceed thresholds and trigger callbacks."""
    violations = []

    #         if metrics.cpu_percent > self.thresholds["cpu_percent"]:
                violations.append(
    #                 f"CPU usage {metrics.cpu_percent:.1f}% exceeds threshold {self.thresholds['cpu_percent']:.1f}%"
    #             )

    #         if metrics.memory_percent > self.thresholds["memory_percent"]:
                violations.append(
    #                 f"Memory usage {metrics.memory_percent:.1f}% exceeds threshold {self.thresholds['memory_percent']:.1f}%"
    #             )

    #         if violations:
    self.threshold_violations + = 1
                logger.warning(f"Performance threshold violations: {', '.join(violations)}")

    #             for callback in self.threshold_callbacks:
    #                 try:
                        callback(metrics)
    #                 except Exception as e:
                        logger.error(f"Error in threshold callback: {e}")

    #     def _collect_custom_metrics(self, metrics: PerformanceMetrics) -> None:
    #         """Collect custom metrics from registered collectors."""
    #         for collector in self.custom_collectors:
    #             try:
    custom_data = collector()
                    metrics.custom_metrics.update(custom_data)
    #             except Exception as e:
                    logger.error(f"Error in custom metric collector: {e}")

    #     def add_threshold_callback(
    #         self, callback: Callable[[PerformanceMetrics], None]
    #     ) -> None:
    #         """Add a callback to be triggered when thresholds are exceeded."""
            self.threshold_callbacks.append(callback)

    #     def add_custom_collector(self, collector: Callable[[], Dict[str, Any]]) -> None:
    #         """Add a custom metrics collector."""
            self.custom_collectors.append(collector)

    #     def set_threshold(self, metric_name: str, threshold: float) -> None:
    #         """Set a performance threshold."""
    #         if metric_name in self.thresholds:
    self.thresholds[metric_name] = threshold
    #             logger.info(f"Updated threshold for {metric_name} to {threshold}")
    #         else:
                logger.warning(f"Unknown metric name: {metric_name}")

    #     def get_current_metrics(self) -> Optional[PerformanceMetrics]:
    #         """Get the most recent performance metrics."""
    #         with self.collection_lock:
    #             if self.metrics_history:
    #                 return self.metrics_history[-1]
    #             return None

    #     def get_metrics_history(
    self, count: Optional[int] = None
    #     ) -> List[PerformanceMetrics]:
    #         """
    #         Get historical performance metrics.

    #         Args:
    #             count: Number of recent metrics to return (None for all)

    #         Returns:
    #             List of historical metrics
    #         """
    #         with self.collection_lock:
    #             if count is None:
                    return list(self.metrics_history)
                return list(self.metrics_history)[-count:]

    #     def get_performance_summary(self) -> Dict[str, Any]:
    #         """Get a summary of performance statistics."""
    #         with self.collection_lock:
    #             if not self.metrics_history:
    #                 return {"error": "No performance data available"}

    #             # Calculate statistics
    #             cpu_values = [m.cpu_percent for m in self.metrics_history]
    #             memory_values = [m.memory_percent for m in self.metrics_history]

    summary = {
    #                 "total_collections": self.total_collections,
    #                 "threshold_violations": self.threshold_violations,
                    "current_metrics": (
                        self.get_current_metrics().__dict__
    #                     if self.get_current_metrics()
    #                     else None
    #                 ),
    #                 "statistics": {
    #                     "cpu": {
    #                         "avg": sum(cpu_values) / len(cpu_values) if cpu_values else 0,
    #                         "max": max(cpu_values) if cpu_values else 0,
    #                         "min": min(cpu_values) if cpu_values else 0,
    #                     },
    #                     "memory": {
                            "avg": (
                                sum(memory_values) / len(memory_values)
    #                             if memory_values
    #                             else 0
    #                         ),
    #                         "max": max(memory_values) if memory_values else 0,
    #                         "min": min(memory_values) if memory_values else 0,
    #                     },
                        "history_size": len(self.metrics_history),
    #                 },
                    "thresholds": self.thresholds.copy(),
    #             }

    #             return summary

    #     def export_metrics(self, filepath: str, format: str = "json") -> None:
    #         """
    #         Export performance metrics to a file.

    #         Args:
    #             filepath: Path to save the metrics
                format: Export format ("json" or "csv")
    #         """
    #         with self.collection_lock:
    metrics_data = list(self.metrics_history)

    #         if format == "json":
    data = {
                    "export_timestamp": datetime.now().isoformat(),
                    "total_metrics": len(metrics_data),
    #                 "metrics": [
    #                     {
    #                         "timestamp": m.timestamp,
    #                         "cpu_percent": m.cpu_percent,
    #                         "memory_percent": m.memory_percent,
    #                         "memory_used": m.memory_used,
    #                         "memory_total": m.memory_total,
    #                         "disk_read": m.disk_read,
    #                         "disk_write": m.disk_write,
    #                         "network_sent": m.network_sent,
    #                         "network_recv": m.network_recv,
    #                         "custom_metrics": m.custom_metrics,
    #                     }
    #                     for m in metrics_data
    #                 ],
    #             }

    #             with open(filepath, "w") as f:
    json.dump(data, f, indent = 2)

    #         elif format == "csv":
    #             import csv

    #             with open(filepath, "w", newline="") as f:
    #                 if metrics_data:
    writer = csv.DictWriter(
    f, fieldnames = metrics_data[0].__dict__.keys()
    #                     )
                        writer.writeheader()
    #                     for m in metrics_data:
                            writer.writerow(m.__dict__)

            logger.info(f"Exported {len(metrics_data)} metrics to {filepath}")

    #     def reset_statistics(self) -> None:
    #         """Reset performance monitoring statistics."""
    #         with self.collection_lock:
                self.metrics_history.clear()
                self.performance_snapshots.clear()
    self.total_collections = 0
    self.threshold_violations = 0

            logger.info("Performance monitoring statistics reset")

    #     def get_optimization_suggestions(self) -> List[str]:
    #         """
    #         Get performance optimization suggestions based on collected metrics.

    #         Returns:
    #             List of optimization suggestions
    #         """
    suggestions = []

    current_metrics = self.get_current_metrics()
    #         if not current_metrics:
    #             return suggestions

    #         # CPU usage suggestions
    #         if current_metrics.cpu_percent > 70:
                suggestions.append(
    #                 "High CPU usage detected. Consider optimizing algorithms or adding parallel processing."
    #             )

    #         # Memory usage suggestions
    #         if current_metrics.memory_percent > 80:
                suggestions.append(
    #                 "High memory usage detected. Consider memory optimization or garbage collection."
    #             )

    #         # Disk I/O suggestions
    #         if current_metrics.disk_read > 100 * 1024 * 1024:  # 100MB/s
                suggestions.append(
    #                 "High disk read activity. Consider caching or optimizing disk operations."
    #             )

    #         # Network I/O suggestions
    #         if current_metrics.network_sent > 10 * 1024 * 1024:  # 10MB/s
                suggestions.append(
    #                 "High network send activity. Consider data compression or batching."
    #             )

    #         return suggestions


# Global performance monitor instance
_default_performance_monitor = PerformanceMonitor()


def get_performance_monitor() -> PerformanceMonitor:
#     """Get the global performance monitor instance."""
#     return _default_performance_monitor


# Initialize the global monitor
_default_performance_monitor.start_monitoring()


# Export public API
__all__ = [
#     "PerformanceMonitor",
#     "PerformanceMetrics",
#     "PerformanceSnapshot",
#     "get_performance_monitor",
# ]
