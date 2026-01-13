# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Monitoring for NBC Runtime

# This module provides comprehensive performance monitoring for all NBC runtime
# components with real-time metrics collection, analysis, and reporting.
# """

import logging
import threading
import time
import weakref
import collections.defaultdict,
import contextlib.contextmanager
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import .unified_error_handler.(
#     UnifiedErrorHandler,
#     NBCErrors,
#     ErrorSeverity as UnifiedErrorSeverity,
#     ErrorCategory as UnifiedErrorCategory,
#     get_error_handler,
#     handle_error,
# )

logger = logging.getLogger(__name__)


class MetricType(Enum)
    #     """Metric types."""

    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    TIMER = "timer"


# @dataclass
class MetricValue
    #     """Metric value with timestamp."""

    #     value: Union[int, float]
    #     timestamp: float
    tags: Dict[str, str] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             "value": self.value,
    #             "timestamp": self.timestamp,
    #             "tags": self.tags,
    #         }


# @dataclass
class PerformanceMetric
    #     """Performance metric definition."""

    #     name: str
    #     metric_type: MetricType
    #     description: str
    unit: str = ""
    tags: Dict[str, str] = field(default_factory=dict)
    values: deque = field(default_factory=lambda: deque(maxlen=1000))

    #     def add_value(self, value: Union[int, float], tags: Dict[str, str] = None):
    #         """Add a value to the metric."""
    metric_value = MetricValue(
    value = value,
    timestamp = time.time(),
    tags = math.multiply({, *self.tags, **(tags or {})})
    #         )
            self.values.append(metric_value)

    #     def get_latest(self) -> Optional[MetricValue]:
    #         """Get latest value."""
    #         return self.values[-1] if self.values else None

    #     def get_average(self, window_size: int = 100) -> float:
    #         """Get average value over window."""
    #         if not self.values:
    #             return 0.0

    recent_values = math.subtract(list(self.values)[, window_size:])
    #         return sum(v.value for v in recent_values) / len(recent_values)

    #     def get_percentile(self, percentile: float) -> float:
    #         """Get percentile value."""
    #         if not self.values:
    #             return 0.0

    #         sorted_values = sorted(v.value for v in self.values)
    index = math.multiply(int(len(sorted_values), percentile / 100))
            return sorted_values[min(index, len(sorted_values) - 1)]

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             "name": self.name,
    #             "type": self.metric_type.value,
    #             "description": self.description,
    #             "unit": self.unit,
    #             "tags": self.tags,
    #             "latest": self.get_latest().to_dict() if self.get_latest() else None,
                "average": self.get_average(),
                "p50": self.get_percentile(50),
                "p95": self.get_percentile(95),
                "p99": self.get_percentile(99),
                "count": len(self.values),
    #         }


class PerformanceMonitor
    #     """
    #     Performance monitor for NBC runtime components.

    #     Provides comprehensive metrics collection, analysis, and reporting
    #     for all runtime components with real-time monitoring capabilities.
    #     """

    #     def __init__(self, component_name: str, config: Dict[str, Any] = None):
    #         """
    #         Initialize performance monitor.

    #         Args:
    #             component_name: Name of the component being monitored
    #             config: Configuration options
    #         """
    self.component_name = component_name
    self.config = config or {}
    self.metrics: Dict[str, PerformanceMetric] = {}
    self._lock = threading.RLock()
    self._start_time = time.time()
    self._is_monitoring = False
    self._monitor_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()

    #         # Initialize unified error handler
    self.unified_error_handler = get_error_handler(
    #             f"performance_monitor_{component_name}",
    #             self.config
    #         )

    #         # Register default metrics
            self._register_default_metrics()

    #         # Start monitoring if enabled
    #         if self.config.get("auto_start", True):
                self.start_monitoring()

    #     def _register_default_metrics(self):
    #         """Register default performance metrics."""
    #         # Execution metrics
            self.register_metric(
    #             "execution_time_total",
    #             MetricType.TIMER,
    #             "Total execution time",
    #             "seconds"
    #         )

            self.register_metric(
    #             "instructions_executed_total",
    #             MetricType.COUNTER,
    #             "Total number of instructions executed",
    #             "count"
    #         )

            self.register_metric(
    #             "instructions_per_second",
    #             MetricType.GAUGE,
    #             "Instructions executed per second",
    #             "ips"
    #         )

    #         # Memory metrics
            self.register_metric(
    #             "memory_usage_bytes",
    #             MetricType.GAUGE,
    #             "Current memory usage",
    #             "bytes"
    #         )

            self.register_metric(
    #             "memory_peak_bytes",
    #             MetricType.GAUGE,
    #             "Peak memory usage",
    #             "bytes"
    #         )

    #         # Error metrics
            self.register_metric(
    #             "errors_total",
    #             MetricType.COUNTER,
    #             "Total number of errors",
    #             "count"
    #         )

            self.register_metric(
    #             "error_rate",
    #             MetricType.GAUGE,
                "Error rate (errors per instruction)",
    #             "ratio"
    #         )

    #         # Performance metrics
            self.register_metric(
    #             "cache_hit_rate",
    #             MetricType.GAUGE,
    #             "Cache hit rate",
    #             "ratio"
    #         )

            self.register_metric(
    #             "jit_compilation_time",
    #             MetricType.TIMER,
    #             "JIT compilation time",
    #             "seconds"
    #         )

            self.register_metric(
    #             "gpu_utilization",
    #             MetricType.GAUGE,
    #             "GPU utilization percentage",
    #             "percent"
    #         )

    #     def register_metric(
    #         self,
    #         name: str,
    #         metric_type: MetricType,
    #         description: str,
    unit: str = "",
    tags: Dict[str, str] = None
    #     ):
    #         """
    #         Register a new performance metric.

    #         Args:
    #             name: Metric name
    #             metric_type: Type of metric
    #             description: Metric description
    #             unit: Unit of measurement
    #             tags: Additional tags
    #         """
    #         with self._lock:
    #             if name in self.metrics:
                    logger.warning(f"Metric {name} already registered")
    #                 return

    self.metrics[name] = PerformanceMetric(
    name = name,
    metric_type = metric_type,
    description = description,
    unit = unit,
    tags = tags or {}
    #             )

                logger.debug(f"Registered metric: {name}")

    #     def record_execution_time(self, operation: str, duration: float, tags: Dict[str, str] = None):
    #         """
    #         Record execution time for an operation.

    #         Args:
    #             operation: Operation name
    #             duration: Execution duration in seconds
    #             tags: Additional tags
    #         """
    metric_name = f"{operation}_execution_time"

    #         # Register metric if not exists
    #         if metric_name not in self.metrics:
                self.register_metric(
    #                 metric_name,
    #                 MetricType.TIMER,
    #                 f"Execution time for {operation}",
    #                 "seconds",
                    {"operation": operation, **(tags or {})}
    #             )

            self.metrics[metric_name].add_value(duration, tags)

    #         # Update total execution time
            self.metrics["execution_time_total"].add_value(duration)

    #     def record_instruction_execution(self, opcode: str, success: bool = True, tags: Dict[str, str] = None):
    #         """
    #         Record instruction execution.

    #         Args:
    #             opcode: Instruction opcode
    #             success: Whether execution was successful
    #             tags: Additional tags
    #         """
    #         # Update instruction count
            self.metrics["instructions_executed_total"].add_value(1, tags)

    #         # Update error count if failed
    #         if not success:
                self.metrics["errors_total"].add_value(1, tags)

    #         # Calculate and update error rate
    total_instructions = self.metrics["instructions_executed_total"].get_latest().value
    #         total_errors = self.metrics["errors_total"].get_latest().value if self.metrics["errors_total"].get_latest() else 0

    #         error_rate = total_errors / total_instructions if total_instructions > 0 else 0.0
            self.metrics["error_rate"].add_value(error_rate, tags)

    #         # Update instructions per second
    uptime = math.subtract(time.time(), self._start_time)
    #         if uptime > 0:
    ips = math.divide(total_instructions, uptime)
                self.metrics["instructions_per_second"].add_value(ips, tags)

    #     def record_memory_usage(self, memory_bytes: int, tags: Dict[str, str] = None):
    #         """
    #         Record memory usage.

    #         Args:
    #             memory_bytes: Memory usage in bytes
    #             tags: Additional tags
    #         """
            self.metrics["memory_usage_bytes"].add_value(memory_bytes, tags)

    #         # Update peak memory if higher
    current_peak = self.metrics["memory_peak_bytes"].get_latest()
    #         if current_peak is None or memory_bytes > current_peak.value:
                self.metrics["memory_peak_bytes"].add_value(memory_bytes, tags)

    #     def record_cache_performance(self, hits: int, misses: int, tags: Dict[str, str] = None):
    #         """
    #         Record cache performance.

    #         Args:
    #             hits: Number of cache hits
    #             misses: Number of cache misses
    #             tags: Additional tags
    #         """
    total = math.add(hits, misses)
    #         if total > 0:
    hit_rate = math.divide(hits, total)
                self.metrics["cache_hit_rate"].add_value(hit_rate, tags)

    #     def record_jit_compilation(self, opcode: str, duration: float, tags: Dict[str, str] = None):
    #         """
    #         Record JIT compilation performance.

    #         Args:
    #             opcode: Instruction opcode
    #             duration: Compilation duration
    #             tags: Additional tags
    #         """
    metric_name = f"{opcode}_jit_compilation_time"

    #         # Register metric if not exists
    #         if metric_name not in self.metrics:
                self.register_metric(
    #                 metric_name,
    #                 MetricType.TIMER,
    #                 f"JIT compilation time for {opcode}",
    #                 "seconds",
                    {"opcode": opcode, **(tags or {})}
    #             )

            self.metrics[metric_name].add_value(duration, tags)
            self.metrics["jit_compilation_time"].add_value(duration, tags)

    #     def record_gpu_utilization(self, utilization: float, tags: Dict[str, str] = None):
    #         """
    #         Record GPU utilization.

    #         Args:
                utilization: GPU utilization percentage (0-100)
    #             tags: Additional tags
    #         """
            self.metrics["gpu_utilization"].add_value(utilization, tags)

    #     def get_metric(self, name: str) -> Optional[PerformanceMetric]:
    #         """
    #         Get a specific metric.

    #         Args:
    #             name: Metric name

    #         Returns:
    #             Performance metric or None if not found
    #         """
    #         with self._lock:
                return self.metrics.get(name)

    #     def get_all_metrics(self) -> Dict[str, PerformanceMetric]:
    #         """
    #         Get all metrics.

    #         Returns:
    #             Dictionary of all metrics
    #         """
    #         with self._lock:
                return self.metrics.copy()

    #     def get_metrics_summary(self) -> Dict[str, Any]:
    #         """
    #         Get metrics summary.

    #         Returns:
    #             Summary of all metrics
    #         """
    #         with self._lock:
    summary = {
    #                 "component_name": self.component_name,
                    "uptime_seconds": time.time() - self._start_time,
                    "metrics_count": len(self.metrics),
    #                 "metrics": {}
    #             }

    #             for name, metric in self.metrics.items():
    summary["metrics"][name] = metric.to_dict()

    #             return summary

    #     def reset_metrics(self):
    #         """Reset all metrics."""
    #         with self._lock:
    #             for metric in self.metrics.values():
                    metric.values.clear()

    #             logger.info(f"Reset metrics for {self.component_name}")

    #     def start_monitoring(self):
    #         """Start performance monitoring."""
    #         if self._is_monitoring:
    #             return

    self._is_monitoring = True
            self._stop_event.clear()

    #         # Start monitoring thread
    self._monitor_thread = threading.Thread(
    target = self._monitoring_loop,
    daemon = True,
    name = f"PerformanceMonitor-{self.component_name}"
    #         )
            self._monitor_thread.start()

    #         logger.info(f"Started performance monitoring for {self.component_name}")

    #     def stop_monitoring(self):
    #         """Stop performance monitoring."""
    #         if not self._is_monitoring:
    #             return

    self._is_monitoring = False
            self._stop_event.set()

    #         if self._monitor_thread and self._monitor_thread.is_alive():
    self._monitor_thread.join(timeout = 5.0)

    #         logger.info(f"Stopped performance monitoring for {self.component_name}")

    #     def _monitoring_loop(self):
    #         """Main monitoring loop."""
    #         try:
    #             while not self._stop_event.is_set():
    #                 # Collect system metrics
                    self._collect_system_metrics()

    #                 # Sleep for monitoring interval
    interval = self.config.get("monitoring_interval", 1.0)
                    self._stop_event.wait(interval)

    #         except Exception as e:
                self.unified_error_handler.handle_error(
    error = e,
    message = f"Performance monitoring loop failed: {str(e)}",
    context = {"component": self.component_name},
    severity = UnifiedErrorSeverity.MEDIUM,
    category = UnifiedErrorCategory.RUNTIME,
    recovery_strategy = "restart_component",
    auto_recovery = True
    #             )
                logger.error(f"Performance monitoring loop failed: {e}")

    #     def _collect_system_metrics(self):
    #         """Collect system-level metrics."""
    #         try:
    #             # Collect memory usage
    #             try:
    #                 import psutil
    process = psutil.Process()
    memory_info = process.memory_info()
                    self.record_memory_usage(memory_info.rss)
    #             except ImportError:
    #                 # Fallback if psutil not available
    #                 pass

    #             # Collect GPU metrics if available
    #             try:
    #                 import GPUtil
    gpus = GPUtil.getGPUs()
    #                 if gpus:
    gpu = gpus[0]  # Use first GPU
                        self.record_gpu_utilization(gpu.load * 100)
    #             except ImportError:
    #                 # Fallback if GPUtil not available
    #                 pass

    #         except Exception as e:
                self.unified_error_handler.handle_error(
    error = e,
    message = f"Failed to collect system metrics: {str(e)}",
    context = {"component": self.component_name},
    severity = UnifiedErrorSeverity.LOW,
    category = UnifiedErrorCategory.RUNTIME,
    recovery_strategy = None,
    auto_recovery = False
    #             )

    #     @contextmanager
    #     def measure_execution(self, operation: str, tags: Dict[str, str] = None):
    #         """
    #         Context manager to measure execution time.

    #         Args:
    #             operation: Operation name
    #             tags: Additional tags
    #         """
    start_time = time.time()
    #         try:
    #             yield
    #         finally:
    duration = math.subtract(time.time(), start_time)
                self.record_execution_time(operation, duration, tags)

    #     def __enter__(self):
    #         """Context manager entry."""
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit."""
            self.stop_monitoring()


# Global performance monitor registry
_performance_monitors: Dict[str, PerformanceMonitor] = {}
_monitors_lock = threading.Lock()


def get_performance_monitor(component_name: str, config: Dict[str, Any] = None) -> PerformanceMonitor:
#     """
#     Get or create a performance monitor for a component.

#     Args:
#         component_name: Name of the component
#         config: Configuration options

#     Returns:
#         Performance monitor instance
#     """
#     with _monitors_lock:
#         if component_name not in _performance_monitors:
_performance_monitors[component_name] = PerformanceMonitor(component_name, config)

#         return _performance_monitors[component_name]


def list_performance_monitors() -> List[str]:
#     """
#     List all registered performance monitors.

#     Returns:
#         List of component names
#     """
#     with _monitors_lock:
        return list(_performance_monitors.keys())


function shutdown_all_monitors()
    #     """Shutdown all performance monitors."""
    #     with _monitors_lock:
    #         for monitor in _performance_monitors.values():
                monitor.stop_monitoring()

            _performance_monitors.clear()


# Decorators for easy performance monitoring

function monitor_performance(operation: str = None, tags: Dict[str, str] = None)
    #     """
    #     Decorator to monitor function performance.

    #     Args:
            operation: Operation name (defaults to function name)
    #         tags: Additional tags
    #     """
    #     def decorator(func: Callable) -> Callable:
    #         def wrapper(*args, **kwargs):
    component_name = func.__module__
    monitor = get_performance_monitor(component_name)

    op_name = operation or f"{func.__module__}.{func.__name__}"

    #             with monitor.measure_execution(op_name, tags):
    #                 try:
    result = math.multiply(func(, args, **kwargs))
                        monitor.record_instruction_execution(op_name, True, tags)
    #                     return result
    #                 except Exception as e:
                        monitor.record_instruction_execution(op_name, False, tags)
    #                     raise

    #         return wrapper
    #     return decorator


function monitor_method_performance(operation: str = None, tags: Dict[str, str] = None)
    #     """
    #     Decorator to monitor method performance.

    #     Args:
            operation: Operation name (defaults to method name)
    #         tags: Additional tags
    #     """
    #     def decorator(func: Callable) -> Callable:
    #         def wrapper(self, *args, **kwargs):
    component_name = self.__class__.__name__
    monitor = get_performance_monitor(component_name)

    op_name = operation or f"{component_name}.{func.__name__}"

    #             with monitor.measure_execution(op_name, tags):
    #                 try:
    result = math.multiply(func(self,, args, **kwargs))
                        monitor.record_instruction_execution(op_name, True, tags)
    #                     return result
    #                 except Exception as e:
                        monitor.record_instruction_execution(op_name, False, tags)
    #                     raise

    #         return wrapper
    #     return decorator