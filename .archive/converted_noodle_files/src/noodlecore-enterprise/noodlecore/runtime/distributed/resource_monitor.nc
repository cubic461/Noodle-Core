# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Resource Monitor
# ---------------
# This module implements the resource monitoring component for the distributed runtime system.
# It tracks system resources, detects bottlenecks, and provides resource optimization recommendations.
# """

import json
import logging
import threading
import time
import warnings
import collections.deque
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import numpy as np
import psutil

# Suppress warnings from psutil
warnings.filterwarnings("ignore", category = UserWarning, module="psutil")

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


class ResourceType(Enum)
    #     """Types of system resources that can be monitored"""

    CPU = "cpu"
    MEMORY = "memory"
    DISK = "disk"
    NETWORK = "network"
    GPU = "gpu"  # Optional, requires nvidia-ml-py
    CUSTOM = "custom"


class ResourceStatus(Enum)
    #     """Status of system resources"""

    NORMAL = "normal"
    WARNING = "warning"
    CRITICAL = "critical"
    UNKNOWN = "unknown"


# @dataclass
class ResourceMetric
    #     """Represents a single resource metric"""

    #     name: str
    #     type: ResourceType
    #     value: float
    #     unit: str
    timestamp: float = field(default_factory=time.time)
    threshold_warning: Optional[float] = None
    threshold_critical: Optional[float] = None

    #     def get_status(self) -> ResourceStatus:
    #         """Determine status based on thresholds"""
    #         if (
    #             self.threshold_critical is not None
    and self.value > = self.threshold_critical
    #         ):
    #             return ResourceStatus.CRITICAL
    #         elif (
    self.threshold_warning is not None and self.value > = self.threshold_warning
    #         ):
    #             return ResourceStatus.WARNING
    #         else:
    #             return ResourceStatus.NORMAL


# @dataclass
class ResourceProfile
    #     """Resource profile for a system or node"""

    #     node_id: str
    metrics: Dict[str, ResourceMetric] = field(default_factory=dict)
    history: Dict[str, deque] = field(default_factory=lambda: deque(maxlen=100))
    last_updated: float = field(default_factory=time.time)

    #     def add_metric(self, metric: ResourceMetric):
    #         """Add a metric to the profile"""
    self.metrics[metric.name] = metric
    #         if metric.name not in self.history:
    self.history[metric.name] = deque(maxlen=100)
            self.history[metric.name].append(metric.value)
    self.last_updated = time.time()

    #     def get_metric(self, name: str) -> Optional[ResourceMetric]:
    #         """Get a specific metric"""
            return self.metrics.get(name)

    #     def get_average(self, name: str, window: int = 10) -> Optional[float]:
    #         """Get average value for a metric over a window"""
    #         if name not in self.history or len(self.history[name]) < window:
    #             return None

    values = math.subtract(list(self.history[name])[, window:])
            return sum(values) / len(values)

    #     def get_trend(self, name: str, window: int = 10) -> Optional[str]:
    #         """Get trend direction for a metric"""
    #         if name not in self.history or len(self.history[name]) < window + 1:
    #             return None

    recent = math.subtract(list(self.history[name])[, window:])
    older = math.add(list(self.history[name])[-(window, 1) : -1])

    #         if not recent or not older:
    #             return None

    recent_avg = math.divide(sum(recent), len(recent))
    older_avg = math.divide(sum(older), len(older))

    #         if recent_avg > older_avg * 1.05:
    #             return "increasing"
    #         elif recent_avg < older_avg * 0.95:
    #             return "decreasing"
    #         else:
    #             return "stable"


class ResourceMonitor
    #     """
    #     Main resource monitoring system for the distributed runtime
    #     """

    #     def __init__(
    #         self,
    update_interval: float = 1.0,
    history_size: int = 1000,
    enable_gpu: bool = False,
    #     ):
    #         """
    #         Initialize the resource monitor

    #         Args:
    #             update_interval: Interval for resource updates (seconds)
    #             history_size: Number of historical data points to keep
                enable_gpu: Whether to monitor GPU resources (requires nvidia-ml-py)
    #         """
    self.update_interval = update_interval
    self.history_size = history_size
    self.enable_gpu = enable_gpu

    #         # Resource profiles for different nodes
    self.profiles: Dict[str, ResourceProfile] = {}

    #         # Monitoring state
    self.running = False
    self.monitor_thread = None

    #         # Custom metrics
    self.custom_metrics: Dict[str, Callable] = {}

    #         # Resource thresholds
    self.thresholds = {
    #             "cpu_warning": 80.0,
    #             "cpu_critical": 95.0,
    #             "memory_warning": 85.0,
    #             "memory_critical": 95.0,
    #             "disk_warning": 85.0,
    #             "disk_critical": 95.0,
    #             "network_warning": 80.0,  # Mbps
    #             "network_critical": 95.0,
    #         }

    #         # Alert callbacks
    self.alert_callbacks: List[Callable] = []

    #         # Initialize GPU monitoring if enabled
    #         if self.enable_gpu:
    #             try:
    #                 import pynvml

    self.pynvml = pynvml
                    self.pynvml.nvmlInit()
    self.gpu_count = self.pynvml.nvmlDeviceGetCount()
    #                 logger.info(f"GPU monitoring enabled with {self.gpu_count} GPUs")
    #             except ImportError:
                    logger.warning("nvidia-ml-py not installed, GPU monitoring disabled")
    self.enable_gpu = False
    #             except Exception as e:
                    logger.warning(f"Failed to initialize GPU monitoring: {e}")
    self.enable_gpu = False

    #     def start(self):
    #         """Start the resource monitor"""
    #         if self.running:
    #             return

    self.running = True
            logger.info("Starting resource monitor")

    #         # Start monitoring thread
    self.monitor_thread = threading.Thread(
    target = self._monitoring_loop, daemon=True
    #         )
            self.monitor_thread.start()

            logger.info("Resource monitor started")

    #     def stop(self):
    #         """Stop the resource monitor"""
    #         if not self.running:
    #             return

    self.running = False
            logger.info("Stopping resource monitor")

    #         # Wait for thread to finish
    #         if self.monitor_thread:
    self.monitor_thread.join(timeout = 5.0)

    #         # Cleanup GPU monitoring
    #         if self.enable_gpu and hasattr(self, "pynvml"):
    #             try:
                    self.pynvml.nvmlShutdown()
    #             except:
    #                 pass

            logger.info("Resource monitor stopped")

    #     def register_node(self, node_id: str):
    #         """Register a new node for monitoring"""
    #         if node_id not in self.profiles:
    self.profiles[node_id] = ResourceProfile(node_id=node_id)
    #             logger.info(f"Node registered for monitoring: {node_id}")

    #     def unregister_node(self, node_id: str):
    #         """Unregister a node from monitoring"""
    #         if node_id in self.profiles:
    #             del self.profiles[node_id]
                logger.info(f"Node unregistered from monitoring: {node_id}")

    #     def add_custom_metric(self, name: str, func: Callable):
    #         """
    #         Add a custom metric function

    #         Args:
    #             name: Name of the metric
    #             func: Function that returns the metric value
    #         """
    self.custom_metrics[name] = func
            logger.info(f"Custom metric added: {name}")

    #     def set_threshold(self, metric: str, warning: float, critical: float):
    #         """
    #         Set thresholds for a metric

    #         Args:
    #             metric: Name of the metric
    #             warning: Warning threshold
    #             critical: Critical threshold
    #         """
    self.thresholds[f"{metric}_warning"] = warning
    self.thresholds[f"{metric}_critical"] = critical
            logger.info(
    #             f"Thresholds set for {metric}: warning={warning}, critical={critical}"
    #         )

    #     def add_alert_callback(self, callback: Callable):
    #         """
    #         Add a callback function for resource alerts

    #         Args:
    #             callback: Function to call when alert is triggered
    #         """
            self.alert_callbacks.append(callback)

    #     def get_node_resources(self, node_id: str) -> Optional[Dict[str, Any]]:
    #         """
    #         Get current resource metrics for a node

    #         Args:
    #             node_id: ID of the node

    #         Returns:
    #             Dictionary of resource metrics or None if node not found
    #         """
    #         if node_id not in self.profiles:
    #             return None

    profile = self.profiles[node_id]
    #         return {name: metric.__dict__ for name, metric in profile.metrics.items()}

    #     def get_system_summary(self) -> Dict[str, Any]:
    #         """
    #         Get a summary of all monitored nodes

    #         Returns:
    #             System summary with aggregate metrics
    #         """
    #         if not self.profiles:
    #             return {"nodes": 0, "status": "no_nodes"}

    summary = {
                "nodes": len(self.profiles),
                "timestamp": time.time(),
    #             "nodes_status": {},
    #             "system_alerts": [],
    #         }

    #         # Get status for each node
    #         for node_id, profile in self.profiles.items():
    node_status = {"metrics": {}, "alerts": []}

    #             # Check each metric
    #             for name, metric in profile.metrics.items():
    status = metric.get_status()
    node_status["metrics"][name] = {
    #                     "value": metric.value,
    #                     "status": status.value,
    #                     "unit": metric.unit,
    #                 }

    #                 # Check for alerts
    #                 if status == ResourceStatus.CRITICAL:
    alert = {
    #                         "node": node_id,
    #                         "metric": name,
    #                         "value": metric.value,
    #                         "status": status.value,
    "message": f"Critical resource usage: {name} = {metric.value}{metric.unit}",
    #                     }
                        node_status["alerts"].append(alert)
                        summary["system_alerts"].append(alert)

    summary["nodes_status"][node_id] = node_status

    #         return summary

    #     def get_resource_recommendations(self, node_id: str) -> List[Dict[str, Any]]:
    #         """
    #         Get optimization recommendations for a node

    #         Args:
    #             node_id: ID of the node

    #         Returns:
    #             List of recommendations
    #         """
    #         if node_id not in self.profiles:
    #             return []

    profile = self.profiles[node_id]
    recommendations = []

    #         # CPU recommendations
    cpu_metric = profile.get_metric("cpu_percent")
    #         if cpu_metric:
    #             if cpu_metric.get_status() == ResourceStatus.CRITICAL:
                    recommendations.append(
    #                     {
    #                         "type": "cpu",
    #                         "priority": "high",
    #                         "issue": "High CPU usage",
    #                         "recommendation": "Consider scaling out or optimizing CPU-intensive tasks",
    #                         "current_value": cpu_metric.value,
    #                     }
    #                 )
    #             elif cpu_metric.get_status() == ResourceStatus.WARNING:
                    recommendations.append(
    #                     {
    #                         "type": "cpu",
    #                         "priority": "medium",
    #                         "issue": "Elevated CPU usage",
    #                         "recommendation": "Monitor CPU usage and consider load balancing",
    #                         "current_value": cpu_metric.value,
    #                     }
    #                 )

    #         # Memory recommendations
    memory_metric = profile.get_metric("memory_percent")
    #         if memory_metric:
    #             if memory_metric.get_status() == ResourceStatus.CRITICAL:
                    recommendations.append(
    #                     {
    #                         "type": "memory",
    #                         "priority": "high",
    #                         "issue": "High memory usage",
    #                         "recommendation": "Consider increasing memory or optimizing memory usage",
    #                         "current_value": memory_metric.value,
    #                     }
    #                 )

    #         # Disk recommendations
    disk_metric = profile.get_metric("disk_percent")
    #         if disk_metric:
    #             if disk_metric.get_status() == ResourceStatus.CRITICAL:
                    recommendations.append(
    #                     {
    #                         "type": "disk",
    #                         "priority": "high",
    #                         "issue": "Low disk space",
    #                         "recommendation": "Clean up disk space or increase storage capacity",
    #                         "current_value": disk_metric.value,
    #                     }
    #                 )

    #         return recommendations

    #     def _monitoring_loop(self):
    #         """Main monitoring loop"""
    #         while self.running:
    #             try:
    #                 # Update all registered nodes
    #                 for node_id in list(self.profiles.keys()):
                        self._update_node_resources(node_id)

                    time.sleep(self.update_interval)

    #             except Exception as e:
                    logger.error(f"Error in monitoring loop: {e}")
                    time.sleep(1.0)

    #     def _update_node_resources(self, node_id: str):
    #         """Update resource metrics for a specific node"""
    #         try:
    profile = self.profiles[node_id]

    #             # CPU metrics
    cpu_percent = psutil.cpu_percent(interval=None)
    cpu_metric = ResourceMetric(
    name = "cpu_percent",
    type = ResourceType.CPU,
    value = cpu_percent,
    unit = "%",
    threshold_warning = self.thresholds["cpu_warning"],
    threshold_critical = self.thresholds["cpu_critical"],
    #             )
                profile.add_metric(cpu_metric)

    #             # Memory metrics
    memory = psutil.virtual_memory()
    memory_metric = ResourceMetric(
    name = "memory_percent",
    type = ResourceType.MEMORY,
    value = memory.percent,
    unit = "%",
    threshold_warning = self.thresholds["memory_warning"],
    threshold_critical = self.thresholds["memory_critical"],
    #             )
                profile.add_metric(memory_metric)

    #             # Disk metrics
    disk = psutil.disk_usage("/")
    disk_metric = ResourceMetric(
    name = "disk_percent",
    type = ResourceType.DISK,
    value = disk.percent,
    unit = "%",
    threshold_warning = self.thresholds["disk_warning"],
    threshold_critical = self.thresholds["disk_critical"],
    #             )
                profile.add_metric(disk_metric)

    #             # Network metrics
    network = psutil.net_io_counters()
    #             # Convert bytes to Mbps for easier interpretation
    network_bytes_sent = math.multiply(network.bytes_sent, 8 / 1024 / 1024  # Mbps)
    network_bytes_recv = math.multiply(network.bytes_recv, 8 / 1024 / 1024  # Mbps)

    network_sent_metric = ResourceMetric(
    name = "network_sent_mbps",
    type = ResourceType.NETWORK,
    value = network_bytes_sent,
    unit = "Mbps",
    threshold_warning = self.thresholds["network_warning"],
    threshold_critical = self.thresholds["network_critical"],
    #             )
                profile.add_metric(network_sent_metric)

    network_recv_metric = ResourceMetric(
    name = "network_recv_mbps",
    type = ResourceType.NETWORK,
    value = network_bytes_recv,
    unit = "Mbps",
    threshold_warning = self.thresholds["network_warning"],
    threshold_critical = self.thresholds["network_critical"],
    #             )
                profile.add_metric(network_recv_metric)

    #             # GPU metrics if enabled
    #             if self.enable_gpu and hasattr(self, "pynvml"):
                    self._update_gpu_metrics(profile)

    #             # Custom metrics
    #             for name, func in self.custom_metrics.items():
    #                 try:
    value = func()
    custom_metric = ResourceMetric(
    name = name, type=ResourceType.CUSTOM, value=value, unit="custom"
    #                     )
                        profile.add_metric(custom_metric)
    #                 except Exception as e:
                        logger.warning(f"Error getting custom metric {name}: {e}")

    #             # Check for alerts
                self._check_alerts(profile)

    #         except Exception as e:
    #             logger.error(f"Error updating resources for node {node_id}: {e}")

    #     def _update_gpu_metrics(self, profile: ResourceProfile):
    #         """Update GPU metrics if GPU monitoring is enabled"""
    #         try:
    #             for i in range(self.gpu_count):
    handle = self.pynvml.nvmlDeviceGetHandleByIndex(i)

    #                 # GPU utilization
    utilization = self.pynvml.nvmlDeviceGetUtilizationRates(handle)
    gpu_util_metric = ResourceMetric(
    name = f"gpu_{i}_utilization",
    type = ResourceType.GPU,
    value = utilization.gpu,
    unit = "%",
    threshold_warning = 80.0,
    threshold_critical = 95.0,
    #                 )
                    profile.add_metric(gpu_util_metric)

    #                 # Memory usage
    memory_info = self.pynvml.nvmlDeviceGetMemoryInfo(handle)
    gpu_memory_metric = ResourceMetric(
    name = f"gpu_{i}_memory_percent",
    type = ResourceType.GPU,
    value = math.multiply((memory_info.used / memory_info.total), 100,)
    unit = "%",
    threshold_warning = 80.0,
    threshold_critical = 95.0,
    #                 )
                    profile.add_metric(gpu_memory_metric)

    #                 # Temperature
    #                 try:
    temp = self.pynvml.nvmlDeviceGetTemperature(
    #                         handle, self.pynvml.NVML_TEMPERATURE_GPU
    #                     )
    gpu_temp_metric = ResourceMetric(
    name = f"gpu_{i}_temperature",
    type = ResourceType.GPU,
    value = temp,
    unit = "°C",
    threshold_warning = 80.0,
    threshold_critical = 90.0,
    #                     )
                        profile.add_metric(gpu_temp_metric)
    #                 except:
    #                     pass  # Temperature not available on all systems

    #         except Exception as e:
                logger.warning(f"Error updating GPU metrics: {e}")

    #     def _check_alerts(self, profile: ResourceProfile):
    #         """Check for resource alerts and trigger callbacks"""
    alerts = []

    #         for metric in profile.metrics.values():
    status = metric.get_status()
    #             if status in [ResourceStatus.WARNING, ResourceStatus.CRITICAL]:
                    alerts.append(
    #                     {
    #                         "node_id": profile.node_id,
    #                         "metric": metric.name,
    #                         "value": metric.value,
    #                         "status": status.value,
    #                         "timestamp": metric.timestamp,
    #                         "threshold_warning": metric.threshold_warning,
    #                         "threshold_critical": metric.threshold_critical,
    #                     }
    #                 )

    #         # Trigger callbacks for alerts
    #         for alert in alerts:
    #             for callback in self.alert_callbacks:
    #                 try:
                        callback(alert)
    #                 except Exception as e:
                        logger.error(f"Error in alert callback: {e}")


# Global resource monitor instance
_monitor = None


def get_resource_monitor() -> ResourceMonitor:
#     """Get the global resource monitor instance"""
#     global _monitor
#     if _monitor is None:
_monitor = ResourceMonitor()
#     return _monitor


function start_resource_monitor()
    #     """Start the global resource monitor"""
    monitor = get_resource_monitor()
        monitor.start()


function stop_resource_monitor()
    #     """Stop the global resource monitor"""
    monitor = get_resource_monitor()
        monitor.stop()


# @dataclass
class ResourceConfig
    #     """Configuration for resource monitoring"""

    update_interval: float = 1.0
    history_size: int = 1000
    enable_gpu: bool = False
    cpu_warning_threshold: float = 80.0
    cpu_critical_threshold: float = 95.0
    memory_warning_threshold: float = 85.0
    memory_critical_threshold: float = 95.0
    disk_warning_threshold: float = 85.0
    disk_critical_threshold: float = 95.0
    network_warning_threshold: float = 80.0
    network_critical_threshold: float = 95.0

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "update_interval": self.update_interval,
    #             "history_size": self.history_size,
    #             "enable_gpu": self.enable_gpu,
    #             "cpu_warning_threshold": self.cpu_warning_threshold,
    #             "cpu_critical_threshold": self.cpu_critical_threshold,
    #             "memory_warning_threshold": self.memory_warning_threshold,
    #             "memory_critical_threshold": self.memory_critical_threshold,
    #             "disk_warning_threshold": self.disk_warning_threshold,
    #             "disk_critical_threshold": self.disk_critical_threshold,
    #             "network_warning_threshold": self.network_warning_threshold,
    #             "network_critical_threshold": self.network_critical_threshold,
    #         }


# @dataclass
class ResourceStats
    #     """Resource statistics for monitoring"""

    cpu_percent: float = 0.0
    memory_percent: float = 0.0
    disk_percent: float = 0.0
    network_sent_mbps: float = 0.0
    network_recv_mbps: float = 0.0
    gpu_utilization: Optional[List[float]] = None
    gpu_memory_percent: Optional[List[float]] = None
    gpu_temperature: Optional[List[float]] = None
    timestamp: float = field(default_factory=time.time)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "cpu_percent": self.cpu_percent,
    #             "memory_percent": self.memory_percent,
    #             "disk_percent": self.disk_percent,
    #             "network_sent_mbps": self.network_sent_mbps,
    #             "network_recv_mbps": self.network_recv_mbps,
    #             "gpu_utilization": self.gpu_utilization,
    #             "gpu_memory_percent": self.gpu_memory_percent,
    #             "gpu_temperature": self.gpu_temperature,
    #             "timestamp": self.timestamp,
    #         }
