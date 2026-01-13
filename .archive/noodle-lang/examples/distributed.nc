# Converted from Python to NoodleCore
# Original file: src

# """
# Distributed runtime components for NBC.
# """

import typing.Any

import noodlecore.runtime.distributed.cluster_manager.ClusterManager
import noodlecore.runtime.distributed.collective_operations.CollectiveOperations
import noodlecore.runtime.distributed.fault_tolerance.FaultTolerance
import noodlecore.runtime.distributed.network_protocol.NetworkProtocol
import noodlecore.runtime.distributed.placement_engine.PlacementEngine
import noodlecore.runtime.distributed.resource_monitor.ResourceMonitor
import noodlecore.runtime.nbc_runtime.core.RuntimeConfig

# Lazy import for scheduler will be handled in _init_scheduler


class DistributedRuntime
    #     """Distributed runtime for NBC."""

    #     def __init__(self, config: RuntimeConfig):
    self.config = config
    self.placement_engine = PlacementEngine()
    self.cluster_manager = ClusterManager(self.placement_engine)
    self.network_protocol = NetworkProtocol()
    self.collective_operations = CollectiveOperations()
    self.fault_tolerance = FaultTolerance()
    self.scheduler = None  # Lazy init
    self.resource_monitor = ResourceMonitor()
            self._init_scheduler()

    #     def _init_scheduler(self):
    #         from .scheduler import Scheduler  # Lazy import

    self.scheduler = Scheduler(self.placement_engine, self.cluster_manager)

    #     def start(self):
    #         """Start the distributed runtime."""
            self.cluster_manager.start()
    #         if self.scheduler:
                self.scheduler.start()
            self.resource_monitor.start()

    #     def stop(self):
    #         """Stop the distributed runtime."""
    #         if self.scheduler:
                self.scheduler.stop()
            self.resource_monitor.stop()
            self.cluster_manager.stop()


__all__ = [
#     "DistributedRuntime",
#     "ClusterManager",
#     "NetworkProtocol",
#     "PlacementEngine",
#     "CollectiveOperations",
#     "FaultTolerance",
#     "Scheduler",
#     "ResourceMonitor",
# ]
