# Converted from Python to NoodleCore
# Original file: src

# """
# Enhanced Performance Monitoring System for NBC Runtime

# This module extends the base performance monitoring with advanced features including:
# - Real-time performance alerts
# - Advanced GPU monitoring
# - Performance regression detection
# - Integration with compiler optimizations
# """

# from ....interop import call_python, bridge  # For Python interop monitoring
# Commented out interop import as module doesn't exist
# from ....interop.js_bridge import bridge as js_bridge
# Commented out interop import as module doesn't exist
import asyncio
import logging
import statistics
import threading
import time
import collections.defaultdict
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import typing.Any

import numpy as np
import scipy.stats

import noodlecore.versioning.Version

import ...error.ErrorCategory
import .monitor.PerformanceMetric

logger = logging.getLogger(__name__)


class AlertSeverity(Enum)
    #     """Performance alert severity levels."""

    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"


class AlertCondition(Enum)
    #     """Performance alert conditions."""

    ABOVE = "above"
    BELOW = "below"
    EQUALS = "equals"


dataclass
class PerformanceAlert
    #     """Performance alert configuration."""

    #     metric_name: str
    #     threshold: float
    #     condition: AlertCondition
    #     severity: AlertSeverity
    description: str = ""
    cooldown_seconds: int = 60  # Prevent alert spam
    callback: Optional[Callable[[str, PerformanceMetric], None]] = None
    enabled: bool = True


dataclass
class AlertEvent
    #     """Represents a triggered performance alert."""

    #     alert: PerformanceAlert
    #     metric: PerformanceMetric
    #     timestamp: datetime
    acknowledged: bool = False


versioned(
version = "1.0.0",
deprecated = False,
#     description="Manager for performance alerts and notifications with threshold monitoring and callbacks.",
constraints = VersionRange(min_version="1.0.0"),
compatibility = {
#         "backward_compatible": True,
#         "forward_compatible": False,
#         "notes": "Future versions may introduce additional alert strategies and notification mechanisms.",
#     },
# )
class PerformanceAlertManager
    #     """Manage performance alerts and notifications."""

    #     def __init__(self):
    self.alerts: List[PerformanceAlert] = []
    self.alert_history: deque = deque(maxlen=1000)
    self.last_alert_times: Dict[str, datetime] = {}
    self._lock = threading.Lock()

    #     def add_alert(self, alert: PerformanceAlert) -None):
    #         """Add a performance alert configuration."""
    #         with self._lock:
                self.alerts.append(alert)
                logger.info(
    #                 f"Added performance alert: {alert.metric_name} "
                    f"({alert.condition.value} {alert.threshold})"
    #             )

    #     def remove_alert(self, metric_name: str, condition: AlertCondition) -bool):
    #         """Remove a performance alert configuration."""
    #         with self._lock:
    original_count = len(self.alerts)
    self.alerts = [
    #                 alert
    #                 for alert in self.alerts
    #                 if not (
    alert.metric_name == metric_name and alert.condition == condition
    #                 )
    #             ]
    removed = original_count != len(self.alerts)
    #             if removed:
                    logger.info(f"Removed performance alert: {metric_name}")
    #             return removed

    #     def check_alerts(self, metrics: List[PerformanceMetric]) -List[AlertEvent]):
    #         """Check metrics against alert thresholds and trigger alerts."""
    triggered_events = []
    current_time = datetime.now()

    #         with self._lock:
    #             for metric in metrics:
    #                 for alert in self.alerts:
    #                     if not alert.enabled or alert.metric_name != metric.name:
    #                         continue

    #                     # Check cooldown period
    last_time = self.last_alert_times.get(
    #                         f"{alert.metric_name}_{alert.condition.value}"
    #                     )
    #                     if (
    #                         last_time
                            and (current_time - last_time).total_seconds()
    #                         < alert.cooldown_seconds
    #                     ):
    #                         continue

    #                     # Check threshold condition
    triggered = False
    #                     if (
    alert.condition == AlertCondition.ABOVE
    #                         and metric.value alert.threshold
    #                     )):
    triggered = True
    #                     elif (
    alert.condition == AlertCondition.BELOW
    #                         and metric.value < alert.threshold
    #                     ):
    triggered = True
    #                     elif (
    alert.condition == AlertCondition.EQUALS
                            and abs(metric.value - alert.threshold) < 0.001
    #                     ):
    triggered = True

    #                     if triggered:
    alert_event = AlertEvent(
    alert = alert, metric=metric, timestamp=current_time
    #                         )
                            triggered_events.append(alert_event)
                            self.alert_history.append(alert_event)
    #                         self.last_alert_times[
    #                             f"{alert.metric_name}_{alert.condition.value}"
    ] = current_time

    #                         # Execute callback if provided
    #                         if alert.callback:
    #                             try:
                                    alert.callback(
    #                                     alert.description
    #                                     or f"Alert triggered: {alert.metric_name}",
    #                                     metric,
    #                                 )
    #                             except Exception as e:
                                    logger.error(f"Error executing alert callback: {e}")

                            logger.warning(
    #                             f"Performance alert triggered: {alert.metric_name} "
                                f"({metric.value} {metric.unit}) {alert.condition.value} "
    #                             f"{alert.threshold} - {alert.severity.value}"
    #                         )

    #         try:
    #             return triggered_events
    #         except Exception as e:
    error_info = self.error_handler.handle_error(
    #                 e, {"operation": "alert_check"}
    #             )
                logger.error(f"Error in alert checking: {error_info}")
    #             return []

    #     def get_active_alerts(self) -List[AlertEvent]):
            """Get all active (unacknowledged) alerts."""
    #         with self._lock:
    #             return [event for event in self.alert_history if not event.acknowledged]

    #     def acknowledge_alert(self, alert_event: AlertEvent) -None):
    #         """Acknowledge an alert event."""
    alert_event.acknowledged = True
            logger.info(f"Acknowledged alert: {alert_event.alert.metric_name}")


versioned(
version = "1.0.0",
deprecated = False,
#     description="Advanced GPU performance monitoring with extended metrics including utilization and memory bandwidth.",
constraints = VersionRange(min_version="1.0.0"),
compatibility = {
#         "backward_compatible": True,
#         "forward_compatible": False,
#         "notes": "Future versions may introduce additional GPU metrics and monitoring capabilities.",
#     },
# )
class AdvancedGPUMonitor
    #     """Advanced GPU performance monitoring with extended metrics."""

    #     def __init__(self):
    self.cupy_available = False
            self._initialize_gpu_support()

    #     def _initialize_gpu_support(self) -None):
    #         """Initialize GPU support and check availability."""
    #         try:
    #             import cupy as cp

    self.cupy_available = True
    self.cp = cp
    #             logger.info("Advanced GPU monitoring initialized with CuPy")
    #         except ImportError:
                logger.info("CuPy not available, advanced GPU monitoring disabled")

    #     def collect_advanced_gpu_metrics(self) -List[PerformanceMetric]):
    #         """Collect advanced GPU metrics including utilization and memory bandwidth."""
    metrics = []
    timestamp = datetime.now()

    #         if not self.cupy_available:
    #             # Fallback to resource manager for CPU metrics
    #             try:
    resource_usage = self.resource_manager.get_resource_usage()
                    metrics.append(
                        PerformanceMetric(
    name = "cpu_memory_utilization_percent",
    value = resource_usage.get("memory_utilization_percent", 0),
    unit = "percent",
    timestamp = timestamp,
    #                     )
    #                 )
    #             except Exception as e:
                    logger.debug(f"Resource metrics unavailable: {e}")
    #             return metrics

    #         try:
    device = self.cp.cuda.Device()
    device_id = device.id

    #             # GPU utilization (if available through nvidia-ml-py or similar)
    #             try:
    #                 # This would require nvidia-ml-py or similar library
    #                 # For now, we'll use memory utilization as a proxy
    mem_info = self.cp.get_default_memory_pool()
    used_memory = mem_info.used_bytes()
    total_memory = mem_info.total_bytes()

    #                 if total_memory 0):
    utilization_percent = (used_memory / total_memory) * 100
                        metrics.append(
                            PerformanceMetric(
    name = "gpu_memory_utilization_percent",
    value = utilization_percent,
    unit = "percent",
    timestamp = timestamp,
    #                         )
    #                     )
    #             except Exception as e:
                    logger.debug(f"GPU utilization metrics not available: {e}")

                # Memory bandwidth estimation (simplified)
    #             try:
    #                 # Create a test array to measure memory bandwidth
    size = 1024 * 1024  # 1MB
    test_array = self.cp.random.random(size, dtype=self.cp.float32)

    start_time = time.perf_counter()
    #                 # Perform memory-intensive operation
    result = self.cp.dot(test_array, test_array)
                    self.cp.cuda.Device().synchronize()
    end_time = time.perf_counter()

    bandwidth_gbps = (size * 4 * 2 / ()
                        (end_time - start_time) * 1e9
    #                 )  # GB/s
                    metrics.append(
                        PerformanceMetric(
    name = "gpu_memory_bandwidth_gbps",
    value = bandwidth_gbps,
    unit = "GB/s",
    timestamp = timestamp,
    #                     )
    #                 )

    #             except Exception as e:
                    logger.debug(f"GPU bandwidth measurement failed: {e}")

    #             # GPU temperature (if available)
    #             try:
    #                 # This would require nvidia-ml-py or similar
    #                 # Placeholder for temperature monitoring
    #                 pass
    #             except Exception as e:
                    logger.debug(f"GPU temperature monitoring not available: {e}")

    #         except Exception as e:
                logger.error(f"Error collecting advanced GPU metrics: {e}")

    #         # Integrate stack manager metrics
    #         try:
    stack_depth = len(self.stack_manager)
                metrics.append(
                    PerformanceMetric(
    name = "stack_depth",
    value = stack_depth,
    unit = "frames",
    timestamp = timestamp,
    #                 )
    #             )
    #         except Exception as e:
                logger.debug(f"Stack metrics unavailable: {e}")

    #         return metrics


versioned(
version = "1.0.0",
deprecated = False,
#     description="Detect performance regressions by comparing against historical baselines with statistical significance.",
constraints = VersionRange(min_version="1.0.0"),
compatibility = {
#         "backward_compatible": True,
#         "forward_compatible": False,
#         "notes": "Future versions may introduce additional regression detection algorithms and baseline management strategies.",
#     },
# )
class PerformanceRegressionDetector
    #     """Detect performance regressions by comparing against historical baselines."""

    #     def __init__(self, baseline_window: int = 100, significance_threshold: float = 2.0):
    self.baseline_window = baseline_window
    self.significance_threshold = significance_threshold
    self.baselines: Dict[str, Dict[str, List[float]]] = defaultdict(
                lambda: defaultdict(list)
    #         )
    self._lock = threading.Lock()

    #     def update_baseline(self, operation_name: str, metrics: Dict[str, float]) -None):
    #         """Update performance baseline for an operation."""
    #         with self._lock:
    #             for metric_name, value in metrics.items():
                    self.baselines[operation_name][metric_name].append(value)

    #                 # Keep only recent values within the window
    #                 if (
                        len(self.baselines[operation_name][metric_name])
    #                     self.baseline_window
    #                 )):
                        self.baselines[operation_name][metric_name].pop(0)

    #     def detect_regression(
    #         self, operation_name: str, current_metrics: Dict[str, float]
    #     ) -List[Dict[str, Any]]):
    #         """Detect performance regressions by comparing with baselines."""
    regressions = []

    #         with self._lock:
    #             if operation_name not in self.baselines:
    #                 return regressions

    #             for metric_name, current_value in current_metrics.items():
    #                 if metric_name in self.baselines[operation_name]:
    baseline_values = self.baselines[operation_name][metric_name]

    #                     if (
    len(baseline_values) = 5
    #                     )):  # Need minimum data for reliable statistics
    baseline_mean = statistics.mean(baseline_values)
    baseline_std = statistics.stdev(baseline_values)

    #                         # Check if current value is significantly worse (higher is worse for timing metrics)
    #                         if current_value baseline_mean + (
    #                             self.significance_threshold * baseline_std
    #                         )):
    regression_factor = (
    #                                 current_value / baseline_mean
    #                                 if baseline_mean 0
                                    else float("inf")
    #                             )

                                regressions.append(
    #                                 {
    #                                     "metric"): metric_name,
    #                                     "current": current_value,
    #                                     "baseline_mean": baseline_mean,
    #                                     "baseline_std": baseline_std,
    #                                     "regression_factor": regression_factor,
                                        "severity": (
    #                                         "major" if regression_factor 2.0 else "minor"
    #                                     ),
                                        "error_info"): self.error_handler.handle_error(
                                            Exception(
    #                                             f"Regression detected in {metric_name}"
    #                                         ),
    #                                         {"operation": "regression_detection"},
    #                                     ),
    #                                 }
    #                             )

    #         return regressions

    #     def get_baseline_summary(self, operation_name: str) -Optional[Dict[str, Any]]):
    #         """Get baseline summary for an operation."""
    #         with self._lock:
    #             if operation_name not in self.baselines:
    #                 return None

    summary = {}
    #             for metric_name, values in self.baselines[operation_name].items():
    #                 if values:
    summary[metric_name] = {
                            "mean": statistics.mean(values),
                            "std": statistics.stdev(values),
                            "min": min(values),
                            "max": max(values),
                            "count": len(values),
    #                     }

    #             return summary if summary else None


versioned(
version = "1.0.0",
deprecated = False,
#     description="Enhanced performance monitor with advanced features including alerts, GPU monitoring, and regression detection.",
constraints = VersionRange(min_version="1.0.0"),
compatibility = {
#         "backward_compatible": True,
#         "forward_compatible": False,
#         "notes": "Future versions may introduce additional monitoring capabilities and performance optimizations.",
#     },
# )
class EnhancedPerformanceMonitor(PerformanceMonitor)
    #     """Enhanced performance monitor with advanced features."""

    #     def __init__(self, max_profiles: int = 1000, max_metrics_per_profile: int = 100):
            super().__init__(max_profiles, max_metrics_per_profile)

    self.alert_manager = PerformanceAlertManager()
    self.gpu_monitor = AdvancedGPUMonitor()
    self.regression_detector = PerformanceRegressionDetector()
    self.external_call_stats: Dict[str, Dict[str, Any]] = {}  # module.func - stats
    self.external_call_lock = threading.Lock()

    #         # Background monitoring thread for advanced metrics
    self.advanced_monitoring_enabled = False
    self.advanced_monitoring_thread = None
    self.advanced_monitoring_interval = 5.0  # seconds

            logger.info("Enhanced performance monitor initialized")

    #     def enable_advanced_monitoring(self, interval_seconds): float = 5.0) -None):
    #         """Enable advanced performance monitoring with alerts."""
    #         if self.advanced_monitoring_enabled:
    #             return

    self.advanced_monitoring_interval = interval_seconds
    self.advanced_monitoring_enabled = True

    self.advanced_monitoring_thread = threading.Thread(
    target = self._advanced_monitoring_loop, daemon=True
    #         )
            self.advanced_monitoring_thread.start()

    #         logger.info(f"Advanced monitoring enabled with {interval_seconds}s interval")

    #     def disable_advanced_monitoring(self) -None):
    #         """Disable advanced performance monitoring."""
    self.advanced_monitoring_enabled = False
    #         if self.advanced_monitoring_thread:
    self.advanced_monitoring_thread.join(timeout = 5.0)
            logger.info("Advanced monitoring disabled")

    #     def _advanced_monitoring_loop(self) -None):
    #         """Background loop for advanced monitoring."""
            logger.info("Advanced monitoring loop started")

    #         while self.advanced_monitoring_enabled:
    #             try:
    #                 # Collect advanced GPU metrics
    gpu_metrics = self.gpu_monitor.collect_advanced_gpu_metrics()

    #                 # Add GPU metrics to current profile if active
    #                 if gpu_metrics and self.active_profiles:
    #                     for profile in self.active_profiles.values():
    #                         for metric in gpu_metrics:
                                profile.add_metric(metric)

    #                 # Check for performance alerts
    all_metrics = []
    #                 for profile in self.active_profiles.values():
                        all_metrics.extend(profile.metrics)

    #                 if all_metrics:
                        self.alert_manager.check_alerts(all_metrics)

                    time.sleep(self.advanced_monitoring_interval)

    #             except Exception as e:
    error_info = self.error_handler.handle_error(
    #                     e, {"operation": "advanced_monitoring_loop"}
    #                 )
                    logger.error(f"Error in advanced monitoring loop: {error_info}")
                    time.sleep(self.advanced_monitoring_interval)

            logger.info("Advanced monitoring loop stopped")

    #     def add_performance_alert(
    #         self,
    #         metric_name: str,
    #         threshold: float,
    condition: AlertCondition = AlertCondition.ABOVE,
    severity: AlertSeverity = AlertSeverity.WARNING,
    description: str = "",
    cooldown_seconds: int = 60,
    callback: Optional[Callable] = None,
    #     ) -None):
    #         """Add a performance alert configuration."""
    alert = PerformanceAlert(
    metric_name = metric_name,
    threshold = threshold,
    condition = condition,
    severity = severity,
    description = description,
    cooldown_seconds = cooldown_seconds,
    callback = callback,
    #         )
            self.alert_manager.add_alert(alert)

    #     def record_operation_performance(
    #         self,
    #         operation_name: str,
    #         duration: float,
    additional_metrics: Optional[Dict[str, float]] = None,
    #     ) -None):
    #         """Record operation performance and update regression baselines."""
    profile_id = self.start_profile(operation_name)

    #         # Record basic duration metric
            self.record_metric(profile_id, "operation_duration", duration, "seconds")

    #         # Record additional metrics
    #         if additional_metrics:
    #             for metric_name, value in additional_metrics.items():
                    self.record_metric(profile_id, metric_name, value, "units")

            self.end_profile(profile_id)

    #         # Update regression detector baseline
    all_metrics = {"operation_duration": duration}
    #         if additional_metrics:
                all_metrics.update(additional_metrics)

            self.regression_detector.update_baseline(operation_name, all_metrics)

    #         # Check for immediate regressions
    regressions = self.check_performance_regressions(operation_name, all_metrics)
    #         if regressions:
    #             for regression in regressions:
                    self.alert_manager.add_alert(
                        PerformanceAlert(
    metric_name = regression["metric"],
    threshold = regression["baseline_mean"],
    condition = AlertCondition.ABOVE,
    severity = AlertSeverity.CRITICAL,
    description = f"Performance regression detected: {regression['regression_factor']:.2f}x slower",
    #                     )
    #                 )

    #     def check_performance_regressions(
    #         self, operation_name: str, current_metrics: Dict[str, float]
    #     ) -List[Dict[str, Any]]):
    #         """Check for performance regressions in an operation."""
            return self.regression_detector.detect_regression(
    #             operation_name, current_metrics
    #         )

    #     def get_performance_summary(self) -Dict[str, Any]):
    #         """Get comprehensive performance summary including alerts and regressions."""
    summary = {
                "active_profiles": len(self.active_profiles),
                "total_profiles": len(self.profiles),
                "active_alerts": len(self.alert_manager.get_active_alerts()),
    #             "advanced_monitoring": self.advanced_monitoring_enabled,
    #             "gpu_support": self.gpu_monitor.cupy_available,
    #         }

    #         # Add recent alert summary
    recent_alerts = list(self.alert_manager.alert_history)[ - 10:]
    summary["recent_alerts"] = [
    #             {
    #                 "metric": event.alert.metric_name,
    #                 "value": event.metric.value,
    #                 "threshold": event.alert.threshold,
    #                 "severity": event.alert.severity.value,
                    "timestamp": event.timestamp.isoformat(),
    #             }
    #             for event in recent_alerts
    #         ]

    #         # Add external call stats summary
    summary["external_calls"] = {
    #             key: {
                    "count": stats.get("count", 0),
                    "total_duration": stats.get("total_duration", 0.0),
                    "avg_duration": stats.get("total_duration", 0.0)
                    / max(stats.get("count", 1), 1),
                    "arg_types": list(stats.get("arg_types", set())),
    #             }
    #             for key, stats in self.external_call_stats.items()
    #         }

    #         return summary

    #     def record_python_call(
    #         self, module_name: str, func_name: str, args: List[Any], duration: float
    #     ) -None):
    #         """
    #         Record a Python external library call for ALE monitoring.
    #         Tracks frequency, duration, and argument types.
    #         """
    key = f"{module_name}.{func_name}"

    #         with self.external_call_lock:
    #             if key not in self.external_call_stats:
    self.external_call_stats[key] = {
    #                     "count": 0,
    #                     "total_duration": 0.0,
                        "arg_types": set(),
    #                 }

    stats = self.external_call_stats[key]
    stats["count"] + = 1
    stats["total_duration"] + = duration

                # Summarize arg types (non-sensitive)
    #             if args:
    #                 arg_types = tuple(type(arg).__name__ for arg in args)
                    stats["arg_types"].add(arg_types)

    #         # Record as profiled operation
    additional_metrics = {
    #             "external_call_duration": duration,
    #             "call_frequency": stats["count"],
                "avg_call_duration": (
    #                 stats["total_duration"] / stats["count"] if stats["count"] 0 else 0.0
    #             ),
    #         }
            self.record_operation_performance(
    #             f"python_{module_name}_{func_name}", duration, additional_metrics
    #         )

            logger.debug(
    #             f"Logged Python call): {key}, duration: {duration}s, args types: {arg_types}, frequency: {stats['count']}"
    #         )

    #         # Optional: Trigger alert for high frequency
    #         if stats["count"] % 100 = 0:  # Every 100 calls
                self.alert_manager.add_alert(
                    PerformanceAlert(
    metric_name = "call_frequency",
    threshold = 100,
    condition = AlertCondition.EQUALS,
    severity = AlertSeverity.INFO,
    description = f"High frequency Python calls to {key}",
    #                 )
    #             )

    #     def record_js_call(
    #         self,
    #         module_name: str,
    #         func_name: str,
    #         args: List[Any],
    #         duration: float,
    event_loop_ticks: int = 0,
    #     ) -None):
    #         """
    #         Record a JS external library call for ALE monitoring (async, event-loop aware).
            Tracks frequency, duration, ticks (event-loop iterations).
    #         """
    key = f"{module_name}.{func_name}"

    #         with self.external_call_lock:
    #             if key not in self.external_call_stats:
    self.external_call_stats[key] = {
    #                     "count": 0,
    #                     "total_duration": 0.0,
    #                     "total_ticks": 0,
                        "arg_types": set(),
    #                 }

    stats = self.external_call_stats[key]
    stats["count"] + = 1
    stats["total_duration"] + = duration
    stats["total_ticks"] + = event_loop_ticks

    #             # Summarize arg types
    #             if args:
    #                 arg_types = tuple(type(arg).__name__ for arg in args)
                    stats["arg_types"].add(arg_types)

    #         # Record as profiled operation with JS-specific metrics
    additional_metrics = {
    #             "external_call_duration": duration,
    #             "event_loop_ticks": event_loop_ticks,
    #             "call_frequency": stats["count"],
                "avg_call_duration": (
    #                 stats["total_duration"] / stats["count"] if stats["count"] 0 else 0.0
    #             ),
                "avg_ticks"): (
    #                 stats["total_ticks"] / stats["count"] if stats["count"] 0 else 0
    #             ),
    #         }
            self.record_operation_performance(
    #             f"js_{module_name}_{func_name}", duration, additional_metrics
    #         )

            logger.debug(
    #             f"Logged JS call): {key}, duration: {duration}s, ticks: {event_loop_ticks}, frequency: {stats['count']}"
    #         )

    #         # Alert for high async overhead
    #         if event_loop_ticks 100):  # Threshold for event-loop strain
                self.alert_manager.add_alert(
                    PerformanceAlert(
    metric_name = "event_loop_ticks",
    threshold = 100,
    condition = AlertCondition.ABOVE,
    severity = AlertSeverity.WARNING,
    description = f"High event-loop ticks in JS call to {key}",
    #                 )
    #             )

    #     def benchmark_external_call(
    #         self,
    #         module_name: str,
    #         func_name: str,
    #         noodle_func: Callable,
    #         test_data: List[Tuple[List[Any], Dict[str, Any]]],
    num_runs: int = 10,
    significance_level: float = 0.05,
    #     ) -Dict[str, Any]):
    #         """
    #         Benchmark Python external call vs Noodle implementation.
    #         Runs multiple iterations, performs t-test for significance, validates correctness.
    #         Returns results with speedup, p-value, validation status.
    #         """
    python_times = []
    noodle_times = []
    validation_errors = []

    #         for data in test_data:
    args, kwargs = data

    #             # Python call
    start = time.perf_counter()
    #             try:
    python_result = bridge.call_external(
    #                     module_name, func_name, args, kwargs
    #                 )
                    python_times.append(time.perf_counter() - start)
                    self.record_python_call(module_name, func_name, args, python_times[-1])
    #             except Exception as e:
                    logger.error(f"Python benchmark failed: {e}")
                    return {"error": str(e)}

    #             # Noodle call
    start = time.perf_counter()
    #             try:
    noodle_result = noodle_func( * args, **kwargs)
                    noodle_times.append(time.perf_counter() - start)

                    # Validate correctness (basic equality check)
    #                 if not self._validate_results(python_result, noodle_result):
                        validation_errors.append(
    #                         f"Mismatch for args {args}: Python={python_result}, Noodle={noodle_result}"
    #                     )
    #             except Exception as e:
                    logger.error(f"Noodle benchmark failed: {e}")
                    return {"error": str(e)}

    #         if len(python_times) < 2 or len(noodle_times) < 2:
    #             return {"error": "Insufficient runs for statistical test"}

    #         # Statistical test (t-test for mean difference)
    t_stat, p_value = stats.ttest_ind(noodle_times, python_times, equal_var=False)

    #         # Mean times
    python_mean = np.mean(python_times)
    noodle_mean = np.mean(noodle_times)
    #         speedup = python_mean / noodle_mean if noodle_mean 0 else float("inf")

    is_significant = p_value < significance_level
    is_better = noodle_mean < python_mean and is_significant

    #         # Log benchmark results
            self.record_operation_performance(
    #             f"benchmark_{module_name}_{func_name}",
                (python_mean + noodle_mean) / 2,
    #             {
    #                 "python_mean"): python_mean,
    #                 "noodle_mean": noodle_mean,
    #                 "speedup": speedup,
    #                 "p_value": p_value,
    #             },
    #         )

    results = {
    #             "module": module_name,
    #             "func": func_name,
    #             "python_mean_time": python_mean,
    #             "noodle_mean_time": noodle_mean,
    #             "speedup": speedup,
    #             "p_value": p_value,
    #             "significant": is_significant,
    #             "noodle_better": is_better,
    #             "validation_errors": validation_errors,
    #             "num_runs": num_runs,
    #         }

    #         if is_better and speedup 1.1):  # 10% faster
                logger.info(
    #                 f"Benchmark success: Noodle {speedup:.2f}x faster for {module_name}.{func_name} (p={p_value:.4f})"
    #             )
    #             # Trigger alert for potential replacement
                self.alert_manager.add_alert(
                    PerformanceAlert(
    metric_name = "benchmark_speedup",
    threshold = 1.1,
    condition = AlertCondition.ABOVE,
    severity = AlertSeverity.INFO,
    #                     description=f"Noodle implementation faster for {module_name}.{func_name}",
    #                 )
    #             )
    #         else:
                logger.warning(
    #                 f"Benchmark: Noodle not significantly better for {module_name}.{func_name}"
    #             )

    #         return results

    #     async def benchmark_js_call(
    #         self,
    #         module_name: str,
    #         func_name: str,
    #         noodle_func: Awaitable,
    #         test_data: List[Tuple[List[Any], Dict[str, Any]]],
    num_runs: int = 10,
    significance_level: float = 0.05,
    #     ) -Dict[str, Any]):
    #         """
            Benchmark JS external call vs Noodle implementation (async, event-loop aware).
    #         Uses asyncio time and QuickJS hrtime for ticks; validates with NoodleEvent.
    #         """
    js_times = []
    noodle_times = []
    js_ticks = []
    validation_errors = []

    loop = asyncio.get_event_loop()

    #         for data in test_data:
    args, kwargs = data

    #             # JS call
    start = loop.time()
    ticks_start = (
                    js_bridge.ctx.eval("process.hrtime.bigint()")
    #                 if hasattr(js_bridge, "ctx")
    #                 else 0
    #             )
    #             try:
    js_result = await js_bridge.call_external(
    #                     module_name, func_name, args, kwargs
    #                 )
    duration = loop.time() - start
    ticks_end = (
                        js_bridge.ctx.eval("process.hrtime.bigint()")
    #                     if hasattr(js_bridge, "ctx")
    #                     else 0
    #                 )
    ticks = (
    #                     int((ticks_end - ticks_start) / 10**6) if ticks_end else 0
    #                 )  # ms ticks
                    js_times.append(duration)
                    js_ticks.append(ticks)
                    self.record_js_call(module_name, func_name, args, duration, ticks)
    #             except Exception as e:
                    logger.error(f"JS benchmark failed: {e}")
                    return {"error": str(e)}

                # Noodle call (async)
    start = loop.time()
    #             try:
    noodle_result = await noodle_func( * args, **kwargs)
    duration = loop.time() - start
                    noodle_times.append(duration)

                    # Validate (handle NoodleEvent)
    #                 if isinstance(js_result, NoodleEvent):
    js_result = js_result.value
    #                 if not self._validate_results(js_result, noodle_result):
                        validation_errors.append(
    #                         f"Mismatch for args {args}: JS={js_result}, Noodle={noodle_result}"
    #                     )
    #             except Exception as e:
                    logger.error(f"Noodle JS benchmark failed: {e}")
                    return {"error": str(e)}

    #         if len(js_times) < 2 or len(noodle_times) < 2:
    #             return {"error": "Insufficient runs for statistical test"}

    #         # Statistical test
    t_stat, p_value = stats.ttest_ind(noodle_times, js_times, equal_var=False)

    js_mean = np.mean(js_times)
    noodle_mean = np.mean(noodle_times)
    #         speedup = js_mean / noodle_mean if noodle_mean 0 else float("inf")
    avg_ticks = np.mean(js_ticks)

    is_significant = p_value < significance_level
    is_better = noodle_mean < js_mean and is_significant

    #         # Log with ticks
            self.record_operation_performance(
    #             f"benchmark_js_{module_name}_{func_name}",
                (js_mean + noodle_mean) / 2,
    #             {
    #                 "js_mean"): js_mean,
    #                 "noodle_mean": noodle_mean,
    #                 "speedup": speedup,
    #                 "p_value": p_value,
    #                 "avg_ticks": avg_ticks,
    #             },
    #         )

    results = {
    #             "module": module_name,
    #             "func": func_name,
    #             "js_mean_time": js_mean,
    #             "noodle_mean_time": noodle_mean,
    #             "speedup": speedup,
    #             "p_value": p_value,
    #             "significant": is_significant,
    #             "noodle_better": is_better,
    #             "avg_event_ticks": avg_ticks,
    #             "validation_errors": validation_errors,
    #             "num_runs": num_runs,
    #         }

    #         if is_better and speedup 1.1):
                logger.info(
    #                 f"JS Benchmark success: Noodle {speedup:.2f}x faster for {module_name}.{func_name} (p={p_value:.4f}, ticks={avg_ticks:.0f})"
    #             )
                self.alert_manager.add_alert(
                    PerformanceAlert(
    metric_name = "benchmark_speedup_js",
    threshold = 1.1,
    condition = AlertCondition.ABOVE,
    severity = AlertSeverity.INFO,
    #                     description=f"Noodle faster for JS {module_name}.{func_name}",
    #                 )
    #             )
    #         else:
                logger.warning(
    #                 f"JS Benchmark: Noodle not better for {module_name}.{func_name}"
    #             )

    #         return results

    #     def _validate_results(self, python_result: Any, noodle_result: Any) -bool):
    #         """
    #         Basic validation: Check if results are equal (with tolerance for floats).
    #         """
    #         if type(python_result) != type(noodle_result):
    #             return False

    #         if isinstance(python_result, (int, str, bool)):
    return python_result == noodle_result

    #         if isinstance(python_result, float):
                return abs(python_result - noodle_result) < 1e-6

    #         if hasattr(python_result, "equals") and callable(
                getattr(python_result, "equals")
    #         ):
                return python_result.equals(noodle_result)

    #         # For lists/arrays, check element-wise
    #         if isinstance(python_result, (list, np.ndarray)):
    #             if len(python_result) != len(noodle_result):
    #                 return False
                return all(
                    self._validate_results(p, n)
    #                 for p, n in zip(python_result, noodle_result)
    #             )

    return python_result == noodle_result


# Convenience functions for common use cases
def create_performance_monitor_with_alerts() -EnhancedPerformanceMonitor):
#     """Create an enhanced performance monitor with common alert configurations."""
monitor = EnhancedPerformanceMonitor()

#     # Add common performance alerts
    monitor.add_performance_alert(
#         "cpu_percent",
#         80.0,
#         AlertCondition.ABOVE,
#         AlertSeverity.WARNING,
#         "High CPU usage detected",
cooldown_seconds = 300,
#     )

    monitor.add_performance_alert(
#         "memory_percent",
#         85.0,
#         AlertCondition.ABOVE,
#         AlertSeverity.WARNING,
#         "High memory usage detected",
cooldown_seconds = 300,
#     )

    monitor.add_performance_alert(
#         "gpu_memory_utilization_percent",
#         90.0,
#         AlertCondition.ABOVE,
#         AlertSeverity.CRITICAL,
#         "Critical GPU memory usage",
cooldown_seconds = 60,
#     )

    monitor.add_performance_alert(
#         "operation_duration",
#         10.0,
#         AlertCondition.ABOVE,
#         AlertSeverity.WARNING,
#         "Operation taking longer than expected",
cooldown_seconds = 120,
#     )

#     return monitor
