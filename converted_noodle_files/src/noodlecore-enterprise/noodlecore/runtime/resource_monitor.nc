# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Resource Monitor
# ---------------
# Monitor system resources and performance metrics.
# """

import json
import logging
import threading
import time
import collections.deque
import dataclasses.dataclass,
import datetime.datetime,
import typing.Any,

import psutil

logger = logging.getLogger(__name__)


# @dataclass
class ResourceMetrics
    #     """Resource usage metrics."""

    #     timestamp: datetime
    #     cpu_percent: float
    #     memory_percent: float
    #     memory_used: int
    #     memory_total: int
    #     disk_percent: float
    #     disk_used: int
    #     disk_total: int
    #     network_sent: int
    #     network_received: int
    #     process_count: int
    #     thread_count: int

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
                "timestamp": self.timestamp.isoformat(),
    #             "cpu_percent": self.cpu_percent,
    #             "memory_percent": self.memory_percent,
    #             "memory_used": self.memory_used,
    #             "memory_total": self.memory_total,
    #             "disk_percent": self.disk_percent,
    #             "disk_used": self.disk_used,
    #             "disk_total": self.disk_total,
    #             "network_sent": self.network_sent,
    #             "network_received": self.network_received,
    #             "process_count": self.process_count,
    #             "thread_count": self.thread_count,
    #         }


# @dataclass
class AlertConfig
    #     """Alert configuration."""

    cpu_threshold: float = 80.0
    memory_threshold: float = 85.0
    disk_threshold: float = 90.0
    network_threshold: int = math.multiply(100, 1024 * 1024  # 100MB/s)
    check_interval: int = 60  # seconds
    enabled: bool = True

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             "cpu_threshold": self.cpu_threshold,
    #             "memory_threshold": self.memory_threshold,
    #             "disk_threshold": self.disk_threshold,
    #             "network_threshold": self.network_threshold,
    #             "check_interval": self.check_interval,
    #             "enabled": self.enabled,
    #         }


class ResourceMonitor
    #     """Monitor system resources and performance metrics."""

    #     def __init__(self, config: Optional[AlertConfig] = None):
    self.config = config or AlertConfig()
    self._metrics_history: deque = deque(maxlen=1000)
    self._network_history: deque = deque(maxlen=100)
    self._alerts: List[Dict[str, Any]] = []
    self._callbacks: List[Callable[[Dict[str, Any]], None]] = []
    self._monitoring = False
    self._monitor_thread: Optional[threading.Thread] = None
    self._lock = threading.RLock()
    self._last_network_stats = None
    self._start_time = datetime.now()

    #         # Initialize network stats
    self._last_network_stats = psutil.net_io_counters()

    #     def start_monitoring(self) -> None:
    #         """Start resource monitoring."""
    #         with self._lock:
    #             if self._monitoring:
    #                 return

    self._monitoring = True
    self._monitor_thread = threading.Thread(
    target = self._monitor_loop, daemon=True
    #             )
                self._monitor_thread.start()
                logger.info("Started resource monitoring")

    #     def stop_monitoring(self) -> None:
    #         """Stop resource monitoring."""
    #         with self._lock:
    #             if not self._monitoring:
    #                 return

    self._monitoring = False
    #             if self._monitor_thread:
    self._monitor_thread.join(timeout = 5)
    self._monitor_thread = None
                logger.info("Stopped resource monitoring")

    #     def _monitor_loop(self) -> None:
    #         """Main monitoring loop."""
    #         while self._monitoring:
    #             try:
    metrics = self._collect_metrics()
                    self._metrics_history.append(metrics)

    #                 # Check for alerts
    #                 if self.config.enabled:
    alerts = self._check_alerts(metrics)
    #                     for alert in alerts:
                            self._add_alert(alert)
                            self._notify_callbacks(alert)

                    time.sleep(self.config.check_interval)

    #             except Exception as e:
                    logger.error(f"Error in monitoring loop: {e}")
                    time.sleep(self.config.check_interval)

    #     def _collect_metrics(self) -> ResourceMetrics:
    #         """Collect current resource metrics."""
    #         # CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)

    #         # Memory usage
    memory = psutil.virtual_memory()

    #         # Disk usage
    disk = psutil.disk_usage("/")

    #         # Network usage
    network = psutil.net_io_counters()
    network_sent = network.bytes_sent
    network_received = network.bytes_received

    #         # Process and thread counts
    process_count = len(psutil.pids())
    thread_count = sum(
                p.num_threads()
    #             for p in psutil.process_iter(["num_threads"])
    #             if p.info["num_threads"]
    #         )

            return ResourceMetrics(
    timestamp = datetime.now(),
    cpu_percent = cpu_percent,
    memory_percent = memory.percent,
    memory_used = memory.used,
    memory_total = memory.total,
    disk_percent = disk.percent,
    disk_used = disk.used,
    disk_total = disk.total,
    network_sent = network_sent,
    network_received = network_received,
    process_count = process_count,
    thread_count = thread_count,
    #         )

    #     def _check_alerts(self, metrics: ResourceMetrics) -> List[Dict[str, Any]]:
    #         """Check for resource alerts."""
    alerts = []

    #         # CPU alert
    #         if metrics.cpu_percent > self.config.cpu_threshold:
                alerts.append(
    #                 {
    #                     "type": "cpu",
    #                     "level": "warning" if metrics.cpu_percent < 95 else "critical",
    #                     "message": f"High CPU usage: {metrics.cpu_percent:.1f}%",
    #                     "value": metrics.cpu_percent,
    #                     "threshold": self.config.cpu_threshold,
                        "timestamp": metrics.timestamp.isoformat(),
    #                 }
    #             )

    #         # Memory alert
    #         if metrics.memory_percent > self.config.memory_threshold:
                alerts.append(
    #                 {
    #                     "type": "memory",
    #                     "level": "warning" if metrics.memory_percent < 95 else "critical",
    #                     "message": f"High memory usage: {metrics.memory_percent:.1f}%",
    #                     "value": metrics.memory_percent,
    #                     "threshold": self.config.memory_threshold,
                        "timestamp": metrics.timestamp.isoformat(),
    #                 }
    #             )

    #         # Disk alert
    #         if metrics.disk_percent > self.config.disk_threshold:
                alerts.append(
    #                 {
    #                     "type": "disk",
    #                     "level": "warning" if metrics.disk_percent < 95 else "critical",
    #                     "message": f"High disk usage: {metrics.disk_percent:.1f}%",
    #                     "value": metrics.disk_percent,
    #                     "threshold": self.config.disk_threshold,
                        "timestamp": metrics.timestamp.isoformat(),
    #                 }
    #             )

    #         # Network alert
    #         if self._last_network_stats:
    time_diff = (
                    (
    #                     metrics.timestamp - self._metrics_history[-1].timestamp
                    ).total_seconds()
    #                 if self._metrics_history
    #                 else 1
    #             )
    network_sent_rate = (
    #                 metrics.network_sent - self._last_network_stats.bytes_sent
    #             ) / time_diff
    network_received_rate = (
    #                 metrics.network_received - self._last_network_stats.bytes_received
    #             ) / time_diff

    #             if network_sent_rate > self.config.network_threshold:
                    alerts.append(
    #                     {
    #                         "type": "network_sent",
    #                         "level": "warning",
                            "message": f"High network send rate: {network_sent_rate / (1024*1024):.2f} MB/s",
    #                         "value": network_sent_rate,
    #                         "threshold": self.config.network_threshold,
                            "timestamp": metrics.timestamp.isoformat(),
    #                     }
    #                 )

    #             if network_received_rate > self.config.network_threshold:
                    alerts.append(
    #                     {
    #                         "type": "network_received",
    #                         "level": "warning",
                            "message": f"High network receive rate: {network_received_rate / (1024*1024):.2f} MB/s",
    #                         "value": network_received_rate,
    #                         "threshold": self.config.network_threshold,
                            "timestamp": metrics.timestamp.isoformat(),
    #                     }
    #                 )

    self._last_network_stats = network

    #         return alerts

    #     def _add_alert(self, alert: Dict[str, Any]) -> None:
    #         """Add an alert to the history."""
    #         with self._lock:
                self._alerts.append(alert)
    #             # Keep only last 1000 alerts
    #             if len(self._alerts) > 1000:
    self._alerts = math.subtract(self._alerts[, 1000:])

    #     def _notify_callbacks(self, alert: Dict[str, Any]) -> None:
    #         """Notify all callbacks of an alert."""
    #         for callback in self._callbacks:
    #             try:
                    callback(alert)
    #             except Exception as e:
                    logger.error(f"Error in alert callback: {e}")

    #     def add_callback(self, callback: Callable[[Dict[str, Any]], None]) -> None:
    #         """Add a callback for alerts."""
            self._callbacks.append(callback)

    #     def remove_callback(self, callback: Callable[[Dict[str, Any]], None]) -> None:
    #         """Remove a callback for alerts."""
    #         if callback in self._callbacks:
                self._callbacks.remove(callback)

    #     def get_current_metrics(self) -> Optional[ResourceMetrics]:
    #         """Get current resource metrics."""
    #         if not self._metrics_history:
    #             return None
    #         return self._metrics_history[-1]

    #     def get_metrics_history(self, hours: int = 24) -> List[ResourceMetrics]:
    #         """Get metrics history for the specified number of hours."""
    cutoff_time = math.subtract(datetime.now(), timedelta(hours=hours))
    #         return [m for m in self._metrics_history if m.timestamp >= cutoff_time]

    #     def get_alerts(self, hours: int = 24) -> List[Dict[str, Any]]:
    #         """Get alerts from the specified number of hours."""
    cutoff_time = math.subtract(datetime.now(), timedelta(hours=hours))
    #         return [
    #             a
    #             for a in self._alerts
    #             if datetime.fromisoformat(a["timestamp"]) >= cutoff_time
    #         ]

    #     def get_system_info(self) -> Dict[str, Any]:
    #         """Get system information."""
    boot_time = datetime.fromtimestamp(psutil.boot_time())

    #         return {
                "boot_time": boot_time.isoformat(),
                "uptime_seconds": (datetime.now() - boot_time).total_seconds(),
                "cpu_count": psutil.cpu_count(),
    "cpu_count_logical": psutil.cpu_count(logical = True),
                "memory_total": psutil.virtual_memory().total,
                "disk_total": psutil.disk_usage("/").total,
                "network_interfaces": list(psutil.net_if_addrs().keys()),
                "load_average": (
    #                 list(psutil.getloadavg()) if hasattr(psutil, "getloadavg") else None
    #             ),
    #         }

    #     def get_process_info(self) -> Dict[str, Any]:
    #         """Get current process information."""
    process = psutil.Process()

    #         return {
    #             "pid": process.pid,
                "name": process.name(),
                "exe": process.exe(),
                "cwd": process.cwd(),
                "status": process.status(),
                "create_time": datetime.fromtimestamp(process.create_time()).isoformat(),
                "cpu_percent": process.cpu_percent(),
                "memory_percent": process.memory_percent(),
                "memory_info": process.memory_info()._asdict(),
                "num_threads": process.num_threads(),
                "num_handles": (
    #                 process.num_handles() if hasattr(process, "num_handles") else None
    #             ),
    #             "open_files": [f.path for f in process.open_files()],
    #             "connections": [c._asdict() for c in process.connections()],
    #         }

    #     def get_performance_summary(self) -> Dict[str, Any]:
    #         """Get performance summary."""
    current_metrics = self.get_current_metrics()
    #         if not current_metrics:
    #             return {}

    alerts = self.get_alerts(hours=1)

    #         return {
                "current_metrics": current_metrics.to_dict(),
                "alert_count": len(alerts),
    #             "critical_alerts": len([a for a in alerts if a["level"] == "critical"]),
    #             "warning_alerts": len([a for a in alerts if a["level"] == "warning"]),
                "system_info": self.get_system_info(),
                "process_info": self.get_process_info(),
    #         }

    #     def export_metrics(self, filename: str, hours: int = 24) -> None:
    #         """Export metrics to a file."""
    metrics = self.get_metrics_history(hours)

    data = {
                "export_time": datetime.now().isoformat(),
    #             "hours": hours,
                "metrics_count": len(metrics),
    #             "metrics": [m.to_dict() for m in metrics],
    #         }

    #         with open(filename, "w") as f:
    json.dump(data, f, indent = 2)

            logger.info(f"Exported {len(metrics)} metrics to {filename}")

    #     def import_metrics(self, filename: str) -> None:
    #         """Import metrics from a file."""
    #         with open(filename, "r") as f:
    data = json.load(f)

    metrics = []
    #         for m in data["metrics"]:
                metrics.append(
                    ResourceMetrics(
    timestamp = datetime.fromisoformat(m["timestamp"]),
    cpu_percent = m["cpu_percent"],
    memory_percent = m["memory_percent"],
    memory_used = m["memory_used"],
    memory_total = m["memory_total"],
    disk_percent = m["disk_percent"],
    disk_used = m["disk_used"],
    disk_total = m["disk_total"],
    network_sent = m["network_sent"],
    network_received = m["network_received"],
    process_count = m["process_count"],
    thread_count = m["thread_count"],
    #                 )
    #             )

    #         with self._lock:
                self._metrics_history.extend(metrics)

            logger.info(f"Imported {len(metrics)} metrics from {filename}")

    #     def clear_history(self) -> None:
    #         """Clear metrics and alerts history."""
    #         with self._lock:
                self._metrics_history.clear()
                self._alerts.clear()
            logger.info("Cleared metrics and alerts history")

    #     def is_monitoring(self) -> bool:
    #         """Check if monitoring is active."""
    #         return self._monitoring

    #     def get_config(self) -> AlertConfig:
    #         """Get current configuration."""
    #         return self.config

    #     def set_config(self, config: AlertConfig) -> None:
    #         """Set new configuration."""
    self.config = config
            logger.info("Updated resource monitor configuration")


class noodlecorecoreProfiler
    #     """
    #     Performance profiler for Noodle operations.
    #     Provides profiling capabilities for runtime performance analysis.
    #     """

    #     def __init__(self, enabled: bool = True):
    self.enabled = enabled
    self.profiles = {}
    self.current_profile = None
    self.start_time = None
    self.logger = logging.getLogger(__name__)

    #     def start_profile(self, name: str) -> None:
    #         """Start profiling a specific operation."""
    #         if not self.enabled:
    #             return

    self.current_profile = name
    self.start_time = time.time()
    self.profiles[name] = {
    #             "start_time": self.start_time,
    #             "end_time": None,
    #             "duration": None,
    #             "calls": 0,
    #             "sub_profiles": [],
    #         }
            self.logger.debug(f"Started profiling: {name}")

    #     def end_profile(self, name: str) -> None:
    #         """End profiling a specific operation."""
    #         if not self.enabled or name != self.current_profile:
    #             return

    end_time = time.time()
    duration = math.subtract(end_time, self.start_time)

    #         if name in self.profiles:
                self.profiles[name].update({"end_time": end_time, "duration": duration})

    self.current_profile = None
            self.logger.debug(f"Ended profiling: {name}, duration: {duration:.4f}s")

    #     def get_profile(self, name: str) -> Optional[Dict[str, Any]]:
    #         """Get profile data for a specific operation."""
            return self.profiles.get(name)

    #     def get_all_profiles(self) -> Dict[str, Any]:
    #         """Get all profile data."""
    #         return self.profiles

    #     def clear_profiles(self) -> None:
    #         """Clear all profile data."""
            self.profiles.clear()
    self.current_profile = None
            self.logger.info("Cleared all profile data")

    #     def get_summary(self) -> Dict[str, Any]:
    #         """Get profiling summary statistics."""
    #         if not self.profiles:
    #             return {}

    total_profiles = len(self.profiles)
    completed_profiles = len(
    #             [p for p in self.profiles.values() if p["duration"] is not None]
    #         )
    total_time = sum(
    #             p["duration"] for p in self.profiles.values() if p["duration"] is not None
    #         )
    #         avg_time = total_time / completed_profiles if completed_profiles > 0 else 0

    #         return {
    #             "total_profiles": total_profiles,
    #             "completed_profiles": completed_profiles,
    #             "total_time": total_time,
    #             "average_time": avg_time,
                "longest_profile": max(
    #                 [
                        (name, p["duration"])
    #                     for name, p in self.profiles.items()
    #                     if p["duration"] is not None
    #                 ],
    key = lambda x: x[1],
    default = (None, None),
    #             ),
    #         }


def load_profiling_config(config_path: Optional[str] = None) -> Dict[str, Any]:
#     """
#     Load profiling configuration from file or return default configuration.

#     Args:
#         config_path: Path to configuration file. If None, uses default configuration.

#     Returns:
#         Dictionary containing profiling configuration.
#     """
default_config = {
#         "enabled": True,
#         "log_level": "INFO",
#         "output_format": "json",
#         "max_profiles": 1000,
#         "auto_save": True,
#         "save_interval": 300,  # 5 minutes
#         "include_memory": True,
#         "include_cpu": True,
#         "include_disk": True,
#         "include_network": True,
#         "sampling_rate": 0.1,  # 100ms
#         "buffer_size": 10000,
#         "compress_logs": False,
#         "log_directory": "./profiles",
#         "filename_prefix": "noodle_profile_",
#         "filename_suffix": ".json",
#     }

#     if config_path is None:
#         return default_config

#     try:
#         with open(config_path, "r") as f:
#             import json

config = json.load(f)
#             # Merge with default config to ensure all keys are present
merged_config = default_config.copy()
            merged_config.update(config)
#             return merged_config
#     except FileNotFoundError:
        logger.warning(
#             f"Profiling config file not found: {config_path}, using defaults"
#         )
#         return default_config
#     except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in profiling config file {config_path}: {e}")
#         return default_config
#     except Exception as e:
        logger.error(f"Error loading profiling config from {config_path}: {e}")
#         return default_config
