# Converted from Python to NoodleCore
# Original file: src

# """
# Scheduler Module for NBC Runtime
# --------------------------------
# This module contains scheduler-related functionality for the NBC runtime.
# """

import datetime
import threading
import time
from dataclasses import dataclass
import enum.Enum
import typing.Any


# Lazy import for distributed
dataclass
class SchedulerConfig
    #     """Configuration for the scheduler."""

    strategy: str = "round_robin"
    max_workers: int = 4
    heartbeat_interval: float = 30.0
    task_timeout: float = 300.0


class SchedulingStrategy(Enum)
    #     """Enumeration of scheduling strategies."""

    ROUND_ROBIN = "round_robin"
    LEAST_LOADED = "least_loaded"
    RESOURCE_AWARE = "resource_aware"


class Scheduler
    #     """Task scheduler for distributed NBC runtime."""

    #     def __init__(
    #         self,
    #         placement_engine,
    #         cluster_manager,
    config: Optional[SchedulerConfig] = None,
    #     ):
    self.config = config or SchedulerConfig()
    self.placement_engine = placement_engine
    self.cluster_manager = cluster_manager
    self.strategy = SchedulingStrategy(self.config.strategy)
    self.active_tasks: Dict[str, Any] = {}
    self.task_queue: List[Any] = []
    self.workers: List[Any] = []
    self._lock = threading.Lock()
    self._running = False

    #         # Lazy init distributed components if needed
    self.distributed_runtime = None

    #     def _init_distributed(self):
            from .distributed import ( Lazy import
    #             DistributedRuntimeConfig,
    #             get_distributed_runtime,
    #         )

    #         if not self.distributed_runtime:
    dr_config = DistributedRuntimeConfig(
    scheduler_strategy = self.config.strategy,
    max_workers = self.config.max_workers,
    heartbeat_interval = self.config.heartbeat_interval,
    task_timeout = self.config.task_timeout,
    #             )
    self.distributed_runtime = get_distributed_runtime(dr_config)

    #     def start(self):
    #         """Start the scheduler."""
    self._running = True
            self._init_distributed()  # Ensure distributed is initialized
    #         # Start worker threads or processes
            print("Scheduler started")

    #     def stop(self):
    #         """Stop the scheduler."""
    self._running = False
            print("Scheduler stopped")

    #     def schedule_task(self, task: Any) -str):
    #         """Schedule a task for execution."""
    #         with self._lock:
    task_id = f"task_{len(self.active_tasks)}_{time.time()}"
                self.task_queue.append(task)
    self.active_tasks[task_id] = task
    #             return task_id

    #     def get_next_task(self) -Optional[Any]):
    #         """Get the next task to execute based on strategy."""
    #         with self._lock:
    #             if self.task_queue:
                    return self.task_queue.pop(0)
    #             return None


__all__ = ["Scheduler", "SchedulerConfig", "SchedulingStrategy"]
