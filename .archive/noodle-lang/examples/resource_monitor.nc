# Converted from Python to NoodleCore
# Original file: src

# """
# Resource monitor for distributed runtime.
# """

import typing.Any
from dataclasses import dataclass
import enum.Enum


class ResourceStatus(Enum)
    #     """Resource status enumeration for distributed monitoring."""

    IDLE = "idle"
    ACTIVE = "active"
    OVERLOADED = "overloaded"
    CRITICAL = "critical"
    OFFLINE = "offline"
    MAINTENANCE = "maintenance"
    UNKNOWN = "unknown"


class ResourceType(Enum)
    #     """Resource type enumeration for distributed monitoring."""

    CPU = "cpu"
    MEMORY = "memory"
    DISK = "disk"
    NETWORK = "network"
    GPU = "gpu"
    STORAGE = "storage"
    CUSTOM = "custom"


dataclass
class ResourceProfile
    #     """Resource profile for monitoring and profiling distributed runtime components."""

    #     node_id: str
    #     cpu_usage: float
    #     memory_usage: float
    #     disk_usage: float
    #     network_io: Dict[str, float]
    gpu_usage: Optional[Dict[str, float]] = None
    custom_metrics: Optional[Dict[str, Any]] = None
    timestamp: Optional[float] = None

import ..config.NBCConfig

try
    #     from pyinstrument import Profiler
except ImportError
    Profiler = None

config = NBCConfig()


class ResourceMonitor
    #     """Resource monitor for distributed runtime with PyInstrument profiling."""

    #     def __init__(self):
    self.resources = {}
    self.status = "stopped"
    self.profiler = None
    #         if config.profile and Profiler:
    self.profiler = Profiler(interval=0.001)  # Low overhead ~1ms
                logger.info("PyInstrument profiling enabled")
    #         else:
                logger.info("Profiling disabled or PyInstrument not available")

    #     def start(self):
    #         """Start the resource monitor and profiler."""
    self.status = "running"
    #         if self.profiler:
                self.profiler.start()

    #     def stop(self):
    #         """Stop the resource monitor and profiler."""
    self.status = "stopped"
    #         if self.profiler:
                self.profiler.stop()

    #     def monitor_resource(self, resource: str, usage: float):
    #         """Monitor resource usage."""
    self.resources[resource] = usage

    #     def get_profile_report(self) -str):
    #         """Get profiling report."""
    #         if self.profiler:
                return self.profiler.output_text()
    #         return "Profiling not enabled"

    #     def export_metrics(self, format: str = "json") -Dict[str, Any]):
    #         """Export metrics."""
    metrics = {"resources": self.resources}
    #         if self.profiler:
    metrics["profile"] = self.profiler.get_json()
    #         return metrics
