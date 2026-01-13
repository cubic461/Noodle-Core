# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance monitoring integration for region-based allocator.

# This module provides integration between the region-based allocator and the
# NBC runtime performance monitoring system, collecting metrics and providing
# real-time insights into memory usage patterns.
# """

import json
import logging
import threading
import time
import collections.defaultdict,
import dataclasses.dataclass,
import typing.Any,

import psutil

import ..region_based_allocator.(
#     MathematicalObjectRegionAllocator,
#     RegionBasedAllocator,
#     RegionStatus,
#     RegionType,
# )

logger = logging.getLogger(__name__)


# @dataclass
class RegionAllocatorMetrics
    #     """Metrics specific to region-based allocator performance."""

    #     # Allocation metrics
    allocation_count: int = 0
    deallocation_count: int = 0
    allocation_success_rate: float = 0.0
    average_allocation_time: float = 0.0
    peak_allocation_time: float = 0.0

    #     # Memory metrics
    total_memory_allocated: int = 0
    total_memory_freed: int = 0
    current_memory_usage: int = 0
    peak_memory_usage: int = 0
    memory_efficiency: float = 0.0

    #     # Region metrics
    regions_created: int = 0
    regions_destroyed: int = 0
    regions_active: int = 0
    average_region_utilization: float = 0.0
    fragmentation_ratio: float = 0.0

    #     # Object type metrics
    allocations_by_type: Dict[str, int] = field(default_factory=dict)
    memory_by_type: Dict[str, int] = field(default_factory=dict)

    #     # Performance metrics
    allocation_throughput: float = 0.0  # allocations per second
    deallocation_throughput: float = 0.0  # deallocations per second
    memory_throughput: float = 0.0  # bytes per second

    #     # Time series data for analysis
    allocation_times: deque = field(default_factory=lambda: deque(maxlen=1000))
    memory_usage_history: deque = field(default_factory=lambda: deque(maxlen=1000))
    region_utilization_history: deque = field(
    default_factory = lambda: deque(maxlen=1000)
    #     )


class RegionAllocatorPerformanceMonitor
    #     """
    #     Performance monitor for region-based allocators.

    #     This class collects and analyzes performance metrics from region-based allocators,
    #     providing insights into memory usage patterns and identifying optimization opportunities.
    #     """

    #     def __init__(
    #         self,
    #         allocator: Union[RegionBasedAllocator, MathematicalObjectRegionAllocator],
    collection_interval: float = 1.0,
    history_size: int = 1000,
    #     ):
    #         """
    #         Initialize the performance monitor.

    #         Args:
    #             allocator: The allocator instance to monitor
    #             collection_interval: Interval for metric collection in seconds
    #             history_size: Size of history buffers
    #         """
    self.allocator = allocator
    self.collection_interval = collection_interval
    self.history_size = history_size

    #         # Metrics storage
    self.metrics = RegionAllocatorMetrics()
    self.metrics_history = deque(maxlen=history_size)

    #         # Monitoring state
    self._monitoring = False
    self._monitor_thread = None
    self._stop_event = threading.Event()

    #         # Callbacks for alerts
    self._alert_callbacks: List[Callable] = []

    #         # Thresholds for alerts
    self.alert_thresholds = {
    #             "allocation_failure_rate": 0.1,  # 10% failure rate
    #             "memory_efficiency": 0.8,  # 80% efficiency threshold
    #             "fragmentation_ratio": 0.3,  # 30% fragmentation threshold
    #             "average_allocation_time": 0.01,  # 10ms average allocation time
    #             "region_utilization": 0.95,  # 95% region utilization threshold
    #         }

            logger.info("RegionAllocatorPerformanceMonitor initialized")

    #     def start_monitoring(self):
    #         """Start monitoring the allocator."""
    #         if self._monitoring:
                logger.warning("Monitoring already active")
    #             return

    self._monitoring = True
            self._stop_event.clear()

    #         # Start monitoring thread
    self._monitor_thread = threading.Thread(
    target = self._monitoring_loop, daemon=True
    #         )
            self._monitor_thread.start()

            logger.info("Region allocator monitoring started")

    #     def stop_monitoring(self):
    #         """Stop monitoring the allocator."""
    #         if not self._monitoring:
    #             return

    self._monitoring = False
            self._stop_event.set()

    #         if self._monitor_thread:
    self._monitor_thread.join(timeout = 5)

            logger.info("Region allocator monitoring stopped")

    #     def _monitoring_loop(self):
    #         """Main monitoring loop."""
    last_collection_time = time.time()
    last_allocation_count = 0
    last_deallocation_count = 0
    last_memory_usage = 0

    #         while self._monitoring and not self._stop_event.is_set():
    #             try:
    current_time = time.time()
    time_elapsed = math.subtract(current_time, last_collection_time)

    #                 # Collect metrics
                    self._collect_metrics()

    #                 # Calculate throughput metrics
    current_allocation_count = self.metrics.allocation_count
    current_deallocation_count = self.metrics.deallocation_count
    current_memory_usage = self.metrics.current_memory_usage

    #                 if time_elapsed > 0:
    allocation_diff = math.subtract(current_allocation_count, last_allocation_count)
    deallocation_diff = (
    #                         current_deallocation_count - last_deallocation_count
    #                     )
    memory_diff = math.subtract(current_memory_usage, last_memory_usage)

    self.metrics.allocation_throughput = math.divide(allocation_diff, time_elapsed)
    self.metrics.deallocation_throughput = (
    #                         deallocation_diff / time_elapsed
    #                     )
    self.metrics.memory_throughput = math.divide(memory_diff, time_elapsed)

    #                 # Update last values
    last_collection_time = current_time
    last_allocation_count = current_allocation_count
    last_deallocation_count = current_deallocation_count
    last_memory_usage = current_memory_usage

    #                 # Check for alerts
                    self._check_alerts()

    #                 # Store in history
                    self._store_metrics_snapshot()

    #                 # Wait for next collection
                    self._stop_event.wait(self.collection_interval)

    #             except Exception as e:
                    logger.error(f"Error in monitoring loop: {e}")
                    self._stop_event.wait(1.0)  # Wait before retrying

    #     def _collect_metrics(self):
    #         """Collect current metrics from the allocator."""
    #         try:
    #             # Get basic allocator statistics
    stats = self.allocator.get_statistics()

    #             # Update allocation metrics
    self.metrics.allocation_count = stats["allocations"]["total"]
    self.metrics.deallocation_count = stats["deallocations"]

    #             if stats["allocations"]["total"] > 0:
    self.metrics.allocation_success_rate = (
    #                     stats["allocations"]["successful"] / stats["allocations"]["total"]
    #                 )

    self.metrics.average_allocation_time = stats["allocations"]["average_time"]

    #             # Update memory metrics
    self.metrics.total_memory_allocated = stats["memory"]["total_allocated"]
    self.metrics.current_memory_usage = stats["memory"]["current_usage"]
    self.metrics.peak_memory_usage = stats["memory"]["peak_usage"]

    #             # Calculate memory efficiency
    total_capacity = sum(
                    len(regions) * self.allocator.region_sizes[region_type]
    #                 for region_type, regions in self.allocator.regions.items()
    #             )
    #             if total_capacity > 0:
    self.metrics.memory_efficiency = (
    #                     self.metrics.current_memory_usage / total_capacity
    #                 )

    #             # Update region metrics
    self.metrics.regions_created = stats["regions"]["created"]
    self.metrics.regions_destroyed = stats["regions"]["destroyed"]
    self.metrics.regions_active = stats["total_regions"]
    self.metrics.average_region_utilization = sum(
                    region.get_utilization()
    #                 for region_list in self.allocator.regions.values()
    #                 for region in region_list
                ) / max(stats["total_regions"], 1)

    self.metrics.fragmentation_ratio = stats["fragmentation_ratio"]

    #             # Update object type metrics (if available)
    #             if isinstance(self.allocator, MathematicalObjectRegionAllocator):
    type_stats = self.allocator.get_object_type_statistics()
    self.metrics.allocations_by_type = {
    #                     obj_type: stats["count"] for obj_type, stats in type_stats.items()
    #                 }

    self.metrics.memory_by_type = {
    #                     obj_type: stats["total_size"]
    #                     for obj_type, stats in type_stats.items()
    #                 }

    #             # Update time series data
                self.metrics.allocation_times.append(self.metrics.average_allocation_time)
                self.metrics.memory_usage_history.append(self.metrics.current_memory_usage)

    region_utilizations = [
                    region.get_utilization()
    #                 for region_list in self.allocator.regions.values()
    #                 for region in region_list
    #             ]
    #             if region_utilizations:
                    self.metrics.region_utilization_history.append(
                        sum(region_utilizations) / len(region_utilizations)
    #                 )

    #         except Exception as e:
                logger.error(f"Error collecting metrics: {e}")

    #     def _check_alerts(self):
    #         """Check for alert conditions."""
    alerts = []

    #         # Check allocation failure rate
    #         if (
    #             self.metrics.allocation_count > 0
                and (1 - self.metrics.allocation_success_rate)
    #             > self.alert_thresholds["allocation_failure_rate"]
    #         ):
                alerts.append(
    #                 {
    #                     "type": "high_failure_rate",
                        "message": f"High allocation failure rate: {(1 - self.metrics.allocation_success_rate) * 100:.1f}%",
    #                     "severity": "warning",
    #                 }
    #             )

    #         # Check memory efficiency
    #         if self.metrics.memory_efficiency > self.alert_thresholds["memory_efficiency"]:
                alerts.append(
    #                 {
    #                     "type": "high_memory_usage",
    #                     "message": f"High memory usage: {self.metrics.memory_efficiency * 100:.1f}%",
    #                     "severity": "warning",
    #                 }
    #             )

    #         # Check fragmentation
    #         if (
    #             self.metrics.fragmentation_ratio
    #             > self.alert_thresholds["fragmentation_ratio"]
    #         ):
                alerts.append(
    #                 {
    #                     "type": "high_fragmentation",
    #                     "message": f"High memory fragmentation: {self.metrics.fragmentation_ratio * 100:.1f}%",
    #                     "severity": "warning",
    #                 }
    #             )

    #         # Check allocation time
    #         if (
    #             self.metrics.average_allocation_time
    #             > self.alert_thresholds["average_allocation_time"]
    #         ):
                alerts.append(
    #                 {
    #                     "type": "slow_allocations",
    #                     "message": f"Slow average allocation time: {self.metrics.average_allocation_time * 1000:.2f}ms",
    #                     "severity": "info",
    #                 }
    #             )

    #         # Check region utilization
    #         if (
    #             self.metrics.average_region_utilization
    #             > self.alert_thresholds["region_utilization"]
    #         ):
                alerts.append(
    #                 {
    #                     "type": "high_region_utilization",
    #                     "message": f"High region utilization: {self.metrics.average_region_utilization * 100:.1f}%",
    #                     "severity": "info",
    #                 }
    #             )

    #         # Trigger callbacks for alerts
    #         for alert in alerts:
                self._trigger_alert(alert)

    #     def _trigger_alert(self, alert: Dict[str, Any]):
    #         """Trigger alert callbacks."""
            logger.warning(f"Performance alert: {alert['message']}")

    #         for callback in self._alert_callbacks:
    #             try:
                    callback(alert)
    #             except Exception as e:
                    logger.error(f"Error in alert callback: {e}")

    #     def _store_metrics_snapshot(self):
    #         """Store a snapshot of current metrics."""
    snapshot = {
                "timestamp": time.time(),
    #             "metrics": {
    #                 "allocation_count": self.metrics.allocation_count,
    #                 "deallocation_count": self.metrics.deallocation_count,
    #                 "allocation_success_rate": self.metrics.allocation_success_rate,
    #                 "average_allocation_time": self.metrics.average_allocation_time,
    #                 "current_memory_usage": self.metrics.current_memory_usage,
    #                 "peak_memory_usage": self.metrics.peak_memory_usage,
    #                 "memory_efficiency": self.metrics.memory_efficiency,
    #                 "regions_active": self.metrics.regions_active,
    #                 "average_region_utilization": self.metrics.average_region_utilization,
    #                 "fragmentation_ratio": self.metrics.fragmentation_ratio,
    #                 "allocation_throughput": self.metrics.allocation_throughput,
    #                 "deallocation_throughput": self.metrics.deallocation_throughput,
    #                 "memory_throughput": self.metrics.memory_throughput,
    #             },
    #         }

            self.metrics_history.append(snapshot)

    #     def add_alert_callback(self, callback: Callable):
    #         """Add a callback function for performance alerts."""
            self._alert_callbacks.append(callback)

    #     def remove_alert_callback(self, callback: Callable):
    #         """Remove a callback function for performance alerts."""
    #         if callback in self._alert_callbacks:
                self._alert_callbacks.remove(callback)

    #     def get_current_metrics(self) -> Dict[str, Any]:
    #         """Get current performance metrics."""
    #         return {
    #             "allocation": {
    #                 "count": self.metrics.allocation_count,
    #                 "deallocation_count": self.metrics.deallocation_count,
    #                 "success_rate": self.metrics.allocation_success_rate,
    #                 "average_time": self.metrics.average_allocation_time,
    #                 "throughput": self.metrics.allocation_throughput,
    #             },
    #             "memory": {
    #                 "current_usage": self.metrics.current_memory_usage,
    #                 "peak_usage": self.metrics.peak_memory_usage,
    #                 "total_allocated": self.metrics.total_memory_allocated,
    #                 "efficiency": self.metrics.memory_efficiency,
    #                 "throughput": self.metrics.memory_throughput,
    #             },
    #             "regions": {
    #                 "active": self.metrics.regions_active,
    #                 "created": self.metrics.regions_created,
    #                 "destroyed": self.metrics.regions_destroyed,
    #                 "average_utilization": self.metrics.average_region_utilization,
    #                 "fragmentation_ratio": self.metrics.fragmentation_ratio,
    #             },
    #             "object_types": self.metrics.allocations_by_type,
    #             "system": {
                    "cpu_percent": psutil.cpu_percent(),
                    "memory_percent": psutil.virtual_memory().percent,
                    "timestamp": time.time(),
    #             },
    #         }

    #     def get_metrics_history(
    self, duration: Optional[float] = None
    #     ) -> List[Dict[str, Any]]:
    #         """
    #         Get metrics history.

    #         Args:
    #             duration: Duration in seconds to look back (None for all history)

    #         Returns:
    #             List of metric snapshots
    #         """
    #         if duration is None:
                return list(self.metrics_history)

    cutoff_time = math.subtract(time.time(), duration)
    #         return [
    #             snapshot
    #             for snapshot in self.metrics_history
    #             if snapshot["timestamp"] >= cutoff_time
    #         ]

    #     def get_performance_report(self) -> Dict[str, Any]:
    #         """Generate a comprehensive performance report."""
    #         if not self.metrics_history:
    #             return {"error": "No metrics history available"}

    #         # Calculate trends
    recent_metrics = self.get_metrics_history(300)  # 5 minutes

    #         if len(recent_metrics) < 2:
    #             return {"error": "Insufficient data for trend analysis"}

    #         # Calculate trends
    memory_trend = (
    #             recent_metrics[-1]["metrics"]["current_memory_usage"]
    #             - recent_metrics[0]["metrics"]["current_memory_usage"]
            ) / len(recent_metrics)

    allocation_trend = (
    #             recent_metrics[-1]["metrics"]["allocation_throughput"]
    #             - recent_metrics[0]["metrics"]["allocation_throughput"]
            ) / len(recent_metrics)

    #         # Generate recommendations
    recommendations = []

    #         if self.metrics.fragmentation_ratio > 0.2:
                recommendations.append(
    #                 {
    #                     "type": "optimization",
    #                     "priority": "high",
    #                     "message": "Consider running region optimization to reduce fragmentation",
    #                     "action": "run_optimize_regions",
    #                 }
    #             )

    #         if self.metrics.memory_efficiency > 0.9:
                recommendations.append(
    #                 {
    #                     "type": "scaling",
    #                     "priority": "medium",
    #                     "message": "Consider increasing region limits to avoid memory pressure",
    #                     "action": "increase_region_limits",
    #                 }
    #             )

    #         if self.metrics.average_allocation_time > 0.005:
                recommendations.append(
    #                 {
    #                     "type": "performance",
    #                     "priority": "medium",
    #                     "message": "Allocation times are high, consider optimizing allocation strategy",
    #                     "action": "optimize_allocation_strategy",
    #                 }
    #             )

    #         return {
    #             "summary": {
    #                 "total_allocations": self.metrics.allocation_count,
    #                 "total_deallocations": self.metrics.deallocation_count,
    #                 "success_rate": f"{self.metrics.allocation_success_rate * 100:.1f}%",
    #                 "current_memory_usage": f"{self.metrics.current_memory_usage / 1024 / 1024:.2f} MB",
    #                 "memory_efficiency": f"{self.metrics.memory_efficiency * 100:.1f}%",
    #                 "fragmentation_ratio": f"{self.metrics.fragmentation_ratio * 100:.1f}%",
    #                 "average_allocation_time": f"{self.metrics.average_allocation_time * 1000:.2f} ms",
    #             },
    #             "trends": {
    #                 "memory_trend": f"{memory_trend / 1024:.2f} KB per sample",
    #                 "allocation_trend": f"{allocation_trend:.2f} allocations per sample per second",
    #             },
    #             "recommendations": recommendations,
    #             "system_status": {
                    "cpu_percent": psutil.cpu_percent(),
                    "memory_percent": psutil.virtual_memory().percent,
                    "timestamp": time.time(),
    #             },
    #         }

    #     def export_metrics(self, filepath: str):
    #         """Export metrics to a file."""
    #         try:
    #             with open(filepath, "w") as f:
                    json.dump(
    #                     {
                            "current_metrics": self.get_current_metrics(),
                            "history": list(self.metrics_history),
                            "performance_report": self.get_performance_report(),
    #                     },
    #                     f,
    indent = 2,
    #                 )

                logger.info(f"Metrics exported to {filepath}")
    #         except Exception as e:
                logger.error(f"Error exporting metrics: {e}")

    #     def set_alert_threshold(self, threshold_name: str, value: float):
    #         """Set an alert threshold."""
    #         if threshold_name in self.alert_thresholds:
    self.alert_thresholds[threshold_name] = value
                logger.info(f"Alert threshold '{threshold_name}' set to {value}")
    #         else:
                logger.warning(f"Unknown alert threshold: {threshold_name}")

    #     def get_alert_thresholds(self) -> Dict[str, float]:
    #         """Get current alert thresholds."""
            return self.alert_thresholds.copy()
