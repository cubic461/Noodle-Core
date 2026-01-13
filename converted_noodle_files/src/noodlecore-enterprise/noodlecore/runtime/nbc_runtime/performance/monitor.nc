# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Monitoring and Optimization System for NBC Runtime

# This module provides comprehensive performance monitoring, profiling, and optimization
# capabilities for distributed AI systems with GPU acceleration.
# """

import json
import logging
import statistics
import threading
import time
import collections.defaultdict,
import dataclasses.asdict,
import datetime.datetime,
import typing.Any,

import numpy as np
import psutil

try
    #     import cupy as cp

    CUPY_AVAILABLE = True
except ImportError
    CUPY_AVAILABLE = False

logger = logging.getLogger(__name__)


# @dataclass
class PerformanceMetric
    #     """Single performance metric measurement."""

    #     name: str
    #     value: float
    #     unit: str
    #     timestamp: datetime
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "name": self.name,
    #             "value": self.value,
    #             "unit": self.unit,
                "timestamp": self.timestamp.isoformat(),
    #             "metadata": self.metadata,
    #         }


# @dataclass
class PerformanceProfile
    #     """Performance profile for a specific operation or component."""

    #     operation_name: str
    metrics: List[PerformanceMetric] = field(default_factory=list)
    start_time: datetime = field(default_factory=datetime.now)
    end_time: Optional[datetime] = None
    total_duration: Optional[float] = None

    #     def add_metric(self, metric: PerformanceMetric):
    #         """Add a metric to the profile."""
            self.metrics.append(metric)

    #     def finalize(self):
    #         """Finalize the profile by setting end time and duration."""
    self.end_time = datetime.now()
    self.total_duration = math.subtract((self.end_time, self.start_time).total_seconds())

    #     def get_summary(self) -> Dict[str, Any]:
    #         """Get summary statistics for the profile."""
    #         if not self.metrics:
    #             return {"operation": self.operation_name, "duration": self.total_duration}

    values_by_name = defaultdict(list)
    #         for metric in self.metrics:
                values_by_name[metric.name].append(metric.value)

    summary = {
    #             "operation": self.operation_name,
    #             "duration": self.total_duration,
    #             "metrics": {},
    #         }

    #         for name, values in values_by_name.items():
    summary["metrics"][name] = {
                    "min": min(values),
                    "max": max(values),
                    "mean": statistics.mean(values),
                    "median": statistics.median(values),
    #                 "std": statistics.stdev(values) if len(values) > 1 else 0,
    #             }

    #         return summary


class PerformanceMonitor
    #     """Central performance monitoring system."""

    #     def __init__(self, max_profiles: int = 1000, max_metrics_per_profile: int = 100):
    self.max_profiles = max_profiles
    self.max_metrics_per_profile = max_metrics_per_profile
    self.profiles: deque = deque(maxlen=max_profiles)
    self.active_profiles: Dict[str, PerformanceProfile] = {}
    self.system_metrics_thread: Optional[threading.Thread] = None
    self.monitoring_active = False
    self.monitoring_interval = 1.0  # seconds
    self.system_metrics_history: deque = deque(
    maxlen = 3600
    #         )  # 1 hour at 1s intervals

    #         # GPU monitoring
    self.gpu_monitoring_enabled = CUPY_AVAILABLE

    #         # Custom metric collectors
    self.custom_collectors: List[Callable[[], List[PerformanceMetric]]] = []

    #     def start_monitoring(self, interval: float = 1.0):
    #         """Start system-wide performance monitoring."""
    #         if self.monitoring_active:
                logger.warning("Performance monitoring already active")
    #             return

    self.monitoring_interval = interval
    self.monitoring_active = True

    #         # Start system metrics collection thread
    self.system_metrics_thread = threading.Thread(
    target = self._collect_system_metrics, daemon=True
    #         )
            self.system_metrics_thread.start()

    #         logger.info(f"Performance monitoring started with {interval}s interval")

    #     def stop_monitoring(self):
    #         """Stop system-wide performance monitoring."""
    #         if not self.monitoring_active:
    #             return

    self.monitoring_active = False

    #         if self.system_metrics_thread:
    self.system_metrics_thread.join(timeout = 5.0)

            logger.info("Performance monitoring stopped")

    #     def start_profile(
    self, operation_name: str, profile_id: Optional[str] = None
    #     ) -> str:
    #         """Start a new performance profile."""
    profile_id = profile_id or f"{operation_name}_{int(time.time() * 1000)}"

    #         if profile_id in self.active_profiles:
                logger.warning(f"Profile {profile_id} already exists")
    #             return profile_id

    profile = PerformanceProfile(operation_name=operation_name)
    self.active_profiles[profile_id] = profile

            logger.debug(f"Started performance profile: {profile_id}")
    #         return profile_id

    #     def end_profile(self, profile_id: str) -> Optional[PerformanceProfile]:
    #         """End a performance profile and return it."""
    #         if profile_id not in self.active_profiles:
                logger.warning(f"Profile {profile_id} not found")
    #             return None

    profile = self.active_profiles.pop(profile_id)
            profile.finalize()
            self.profiles.append(profile)

            logger.debug(
    #             f"Ended performance profile: {profile_id} "
                f"(duration: {profile.total_duration:.3f}s)"
    #         )

    #         return profile

    #     def record_metric(
    #         self,
    #         profile_id: str,
    #         name: str,
    #         value: float,
    unit: str = "unknown",
    metadata: Optional[Dict[str, Any]] = None,
    #     ):
    #         """Record a performance metric for an active profile."""
    #         if profile_id not in self.active_profiles:
    #             logger.warning(f"Profile {profile_id} not found for metric recording")
    #             return

    profile = self.active_profiles[profile_id]

    #         if len(profile.metrics) >= self.max_metrics_per_profile:
                logger.warning(f"Profile {profile_id} has reached maximum metrics limit")
    #             return

    metric = PerformanceMetric(
    name = name,
    value = value,
    unit = unit,
    timestamp = datetime.now(),
    metadata = metadata or {},
    #         )

            profile.add_metric(metric)

    #     def add_custom_collector(self, collector: Callable[[], List[PerformanceMetric]]):
    #         """Add a custom metric collector function."""
            self.custom_collectors.append(collector)

    #     def get_profiles(
    self, operation_name: Optional[str] = None, limit: int = 100
    #     ) -> List[PerformanceProfile]:
    #         """Get performance profiles, optionally filtered by operation name."""
    profiles = list(self.profiles)

    #         if operation_name:
    #             profiles = [p for p in profiles if p.operation_name == operation_name]

    #         return profiles[-limit:]  # Return most recent profiles

    #     def get_system_metrics_summary(
    self, duration: timedelta = timedelta(minutes=5)
    #     ) -> Dict[str, Any]:
    #         """Get summary of recent system metrics."""
    cutoff_time = math.subtract(datetime.now(), duration)
    recent_metrics = [
    #             m for m in self.system_metrics_history if m.timestamp >= cutoff_time
    #         ]

    #         if not recent_metrics:
    #             return {}

    #         # Group by metric name
    metrics_by_name = defaultdict(list)
    #         for metric in recent_metrics:
                metrics_by_name[metric.name].append(metric.value)

    summary = {}
    #         for name, values in metrics_by_name.items():
    summary[name] = {
    #                 "current": values[-1] if values else 0,
    #                 "min": min(values) if values else 0,
    #                 "max": max(values) if values else 0,
    #                 "mean": statistics.mean(values) if values else 0,
                    "samples": len(values),
    #             }

    #         return summary

    #     def export_profiles(self, filepath: str, format: str = "json"):
    #         """Export performance profiles to file."""
    profiles_data = []

    #         for profile in self.profiles:
    profile_dict = {
    #                 "operation_name": profile.operation_name,
                    "start_time": profile.start_time.isoformat(),
    #                 "end_time": profile.end_time.isoformat() if profile.end_time else None,
    #                 "total_duration": profile.total_duration,
    #                 "metrics": [m.to_dict() for m in profile.metrics],
    #             }
                profiles_data.append(profile_dict)

    #         if format.lower() == "json":
    #             with open(filepath, "w") as f:
    json.dump(profiles_data, f, indent = 2)
    #         else:
                raise ValueError(f"Unsupported export format: {format}")

            logger.info(f"Exported {len(profiles_data)} profiles to {filepath}")

    #     def _collect_system_metrics(self):
    #         """Collect system metrics in background thread."""
    #         while self.monitoring_active:
    #             try:
    metrics = []

    #                 # CPU metrics
    cpu_percent = psutil.cpu_percent(interval=None)
                    metrics.append(
                        PerformanceMetric(
    name = "cpu_usage_percent",
    value = cpu_percent,
    unit = "percent",
    timestamp = datetime.now(),
    #                     )
    #                 )

    #                 # Memory metrics
    memory = psutil.virtual_memory()
                    metrics.append(
                        PerformanceMetric(
    name = "memory_usage_percent",
    value = memory.percent,
    unit = "percent",
    timestamp = datetime.now(),
    #                     )
    #                 )
                    metrics.append(
                        PerformanceMetric(
    name = "memory_available_gb",
    value = math.multiply(memory.available / (1024, *3),)
    unit = "gigabytes",
    timestamp = datetime.now(),
    #                     )
    #                 )

    #                 # Disk I/O metrics
    disk_io = psutil.disk_io_counters()
    #                 if disk_io:
                        metrics.append(
                            PerformanceMetric(
    name = "disk_read_mb_s",
    value = math.multiply(disk_io.read_bytes / (1024, *2),)
    unit = "megabytes_per_second",
    timestamp = datetime.now(),
    #                         )
    #                     )
                        metrics.append(
                            PerformanceMetric(
    name = "disk_write_mb_s",
    value = math.multiply(disk_io.write_bytes / (1024, *2),)
    unit = "megabytes_per_second",
    timestamp = datetime.now(),
    #                         )
    #                     )

    #                 # GPU metrics (if available)
    #                 if self.gpu_monitoring_enabled:
    gpu_metrics = self._collect_gpu_metrics()
                        metrics.extend(gpu_metrics)

    #                 # Custom collectors
    #                 for collector in self.custom_collectors:
    #                     try:
    custom_metrics = collector()
                            metrics.extend(custom_metrics)
    #                     except Exception as e:
                            logger.error(f"Custom collector failed: {e}")

    #                 # Store metrics
    #                 for metric in metrics:
                        self.system_metrics_history.append(metric)

    #             except Exception as e:
                    logger.error(f"Error collecting system metrics: {e}")

                time.sleep(self.monitoring_interval)

    #     def _collect_gpu_metrics(self) -> List[PerformanceMetric]:
    #         """Collect GPU-specific metrics."""
    metrics = []
    timestamp = datetime.now()

    #         try:
    #             # Memory usage
    mem_info = cp.get_default_memory_pool().used_bytes()
                metrics.append(
                    PerformanceMetric(
    name = "gpu_memory_used_mb",
    value = math.multiply(mem_info / (1024, *2),)
    unit = "megabytes",
    timestamp = timestamp,
    #                 )
    #             )

    #             # Memory pool info
    pool = cp.get_default_memory_pool()
                metrics.append(
                    PerformanceMetric(
    name = "gpu_memory_pool_size_mb",
    value = math.multiply(pool.total_bytes() / (1024, *2),)
    unit = "megabytes",
    timestamp = timestamp,
    #                 )
    #             )

    #             # GPU utilization (if available)
    #             # Note: This requires nvidia-ml-py or similar

    #         except Exception as e:
                logger.error(f"Error collecting GPU metrics: {e}")

    #         return metrics


class PerformanceOptimizer
    #     """Performance optimization recommendations based on monitoring data."""

    #     def __init__(self, monitor: PerformanceMonitor):
    self.monitor = monitor
    self.optimization_rules = self._load_optimization_rules()

    #     def analyze_performance(self, operation_name: str) -> List[Dict[str, Any]]:
    #         """Analyze performance for a specific operation and provide recommendations."""
    profiles = self.monitor.get_profiles(operation_name=operation_name, limit=50)

    #         if not profiles:
    #             return []

    recommendations = []

    #         # Analyze duration trends
    #         durations = [p.total_duration for p in profiles if p.total_duration]
    #         if durations:
    avg_duration = statistics.mean(durations)
    recent_avg = (
                    statistics.mean(durations[-10:])
    #                 if len(durations) >= 10
    #                 else avg_duration
    #             )

    #             if recent_avg > avg_duration * 1.2:
                    recommendations.append(
    #                     {
    #                         "type": "performance_degradation",
    #                         "severity": "high",
    #                         "message": f"Recent performance degradation detected. "
    #                         f"Average duration increased from {avg_duration:.3f}s "
    #                         f"to {recent_avg:.3f}s",
    #                         "suggestion": "Check for resource contention or algorithm changes",
    #                     }
    #                 )

    #         # Analyze memory usage
    memory_metrics = []
    #         for profile in profiles:
    #             for metric in profile.metrics:
    #                 if "memory" in metric.name.lower():
                        memory_metrics.append(metric.value)

    #         if memory_metrics:
    avg_memory = statistics.mean(memory_metrics)
    #             if avg_memory > 1024**3:  # 1GB
                    recommendations.append(
    #                     {
    #                         "type": "high_memory_usage",
    #                         "severity": "medium",
                            "message": f"High memory usage detected: {avg_memory/(1024**3):.1f}GB average",
    #                         "suggestion": "Consider memory optimization or batch processing",
    #                     }
    #                 )

    #         # Analyze system metrics
    system_summary = self.monitor.get_system_metrics_summary()

    #         if "cpu_usage_percent" in system_summary:
    cpu_usage = system_summary["cpu_usage_percent"]["mean"]
    #             if cpu_usage > 80:
                    recommendations.append(
    #                     {
    #                         "type": "high_cpu_usage",
    #                         "severity": "high",
    #                         "message": f"High CPU usage: {cpu_usage:.1f}%",
    #                         "suggestion": "Consider load balancing or optimization",
    #                     }
    #                 )

    #         if "memory_usage_percent" in system_summary:
    mem_usage = system_summary["memory_usage_percent"]["mean"]
    #             if mem_usage > 85:
                    recommendations.append(
    #                     {
    #                         "type": "high_memory_usage",
    #                         "severity": "high",
    #                         "message": f"High system memory usage: {mem_usage:.1f}%",
    #                         "suggestion": "Consider memory optimization or scaling",
    #                     }
    #                 )

    #         return recommendations

    #     def get_optimization_suggestions(self) -> List[Dict[str, Any]]:
    #         """Get general optimization suggestions based on current system state."""
    suggestions = []
    system_summary = self.monitor.get_system_metrics_summary()

    #         # GPU optimization suggestions
    #         if self.monitor.gpu_monitoring_enabled:
    #             if "gpu_memory_used_mb" in system_summary:
    gpu_mem_mb = system_summary["gpu_memory_used_mb"]["current"]
    #                 if gpu_mem_mb > 0.9 * 8192:  # Assuming 8GB GPU
                        suggestions.append(
    #                         {
    #                             "type": "gpu_memory",
    #                             "severity": "high",
    #                             "message": "GPU memory usage is high",
    #                             "suggestion": "Consider GPU memory optimization or batch size reduction",
    #                         }
    #                     )

    #         # CPU optimization
    #         if "cpu_usage_percent" in system_summary:
    cpu_usage = system_summary["cpu_usage_percent"]["current"]
    #             if cpu_usage < 20 and "gpu_memory_used_mb" in system_summary:
    gpu_mem_mb = system_summary["gpu_memory_used_mb"]["current"]
    #                 if gpu_mem_mb > 0:
                        suggestions.append(
    #                         {
    #                             "type": "cpu_gpu_balance",
    #                             "severity": "medium",
    #                             "message": "Low CPU usage with active GPU operations",
    #                             "suggestion": "Consider CPU-GPU workload balancing",
    #                         }
    #                     )

    #         return suggestions

    #     def _load_optimization_rules(self) -> List[Dict[str, Any]]:
    #         """Load optimization rules and thresholds."""
    #         return [
    #             {
                    "condition": lambda metrics: metrics.get("cpu_usage_percent", 0) > 90,
    #                 "recommendation": "High CPU usage detected. Consider parallelization or algorithm optimization.",
    #                 "severity": "critical",
    #             },
    #             {
                    "condition": lambda metrics: metrics.get("memory_usage_percent", 0)
    #                 > 95,
    #                 "recommendation": "Critical memory usage. Immediate action required.",
    #                 "severity": "critical",
    #             },
    #             {
                    "condition": lambda metrics: metrics.get("gpu_memory_used_mb", 0)
    #                 > 0.95 * 8192,
    #                 "recommendation": "GPU memory nearly full. Reduce batch size or optimize memory usage.",
    #                 "severity": "high",
    #             },
    #         ]


# Global instances
_global_monitor: Optional[PerformanceMonitor] = None
_global_optimizer: Optional[PerformanceOptimizer] = None


def get_performance_monitor() -> PerformanceMonitor:
#     """Get global performance monitor instance."""
#     global _global_monitor

#     if _global_monitor is None:
_global_monitor = PerformanceMonitor()

#     return _global_monitor


def get_performance_optimizer() -> PerformanceOptimizer:
#     """Get global performance optimizer instance."""
#     global _global_optimizer, _global_monitor

#     if _global_optimizer is None:
monitor = get_performance_monitor()
_global_optimizer = PerformanceOptimizer(monitor)

#     return _global_optimizer


# Convenience decorators
function profile_performance(operation_name: str)
    #     """Decorator to automatically profile function performance."""

    #     def decorator(func: Callable) -> Callable:
    #         def wrapper(*args, **kwargs):
    monitor = get_performance_monitor()
    profile_id = monitor.start_profile(operation_name)

    #             try:
    result = math.multiply(func(, args, **kwargs))

    #                 # Record basic metrics
                    monitor.record_metric(profile_id, "function_args", len(args))
                    monitor.record_metric(profile_id, "function_kwargs", len(kwargs))

    #                 return result
    #             finally:
                    monitor.end_profile(profile_id)

    #         return wrapper

    #     return decorator


function monitor_system_resources()
    #     """Context manager for monitoring system resources during operation."""
    monitor = get_performance_monitor()
    profile_id = monitor.start_profile("system_monitoring")

    #     try:
    #         # Record initial system state
    initial_metrics = monitor._collect_system_metrics()
    #         for metric in initial_metrics:
                monitor.record_metric(profile_id, metric.name, metric.value, metric.unit)

    #         yield profile_id

    #     finally:
            monitor.end_profile(profile_id)


# Example usage and testing
if __name__ == "__main__"
    #     # Initialize monitoring
    monitor = get_performance_monitor()
    monitor.start_monitoring(interval = 1.0)

    #     # Create optimizer
    optimizer = get_performance_optimizer()

    #     # Example profiling
    profile_id = monitor.start_profile("example_operation")

    #     # Simulate some work
        time.sleep(0.1)

    #     # Record metrics
        monitor.record_metric(profile_id, "items_processed", 1000, "count")
        monitor.record_metric(profile_id, "memory_used", 1024**2, "bytes")

    #     # End profile
    profile = monitor.end_profile(profile_id)

    #     # Get recommendations
    recommendations = optimizer.analyze_performance("example_operation")
    #     for rec in recommendations:
            print(f"Recommendation: {rec['message']}")
            print(f"Suggestion: {rec['suggestion']}")
            print()

    #     # Stop monitoring
        monitor.stop_monitoring()
