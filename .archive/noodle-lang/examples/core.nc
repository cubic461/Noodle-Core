# Converted from Python to NoodleCore
# Original file: src

# """
# Core runtime components for Noodle.
# """

from dataclasses import dataclass
import enum.Enum
import typing.Any


dataclass
class RuntimeConfig
    #     """Configuration for the runtime."""

    debug: bool = False
    log_level: str = "INFO"
    timeout: float = 30.0
    max_workers: int = 4
    gpu_enabled: bool = False
    gpu_memory_limit: int = 1024  # MB
    enable_cuda: bool = False
    enable_opencl: bool = False


class RuntimeState(Enum)
    #     """Runtime state."""

    STOPPED = "stopped"
    RUNNING = "running"
    PAUSED = "paused"


class RuntimeMetrics
    #     """Runtime metrics."""

    #     def __init__(self):
    self.execution_time = 0.0
    self.memory_usage = 0.0
    self.cpu_usage = 0.0


class NBCRuntime
    #     """NBC Runtime."""

    #     def __init__(self, config: RuntimeConfig):
    self.config = config
    self.state = RuntimeState.STOPPED
    self.metrics = RuntimeMetrics()

    #     def start(self):
    #         """Start the runtime."""
    self.state = RuntimeState.RUNNING

    #     def stop(self):
    #         """Stop the runtime."""
    self.state = RuntimeState.STOPPED
