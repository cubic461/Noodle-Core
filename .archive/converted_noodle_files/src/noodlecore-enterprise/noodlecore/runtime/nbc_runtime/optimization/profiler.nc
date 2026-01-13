# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Code Profiler for NBC Runtime
# -----------------------------
# Provides profiling capabilities for performance analysis and optimization.
# """

import cProfile
import functools
import io
import logging
import os
import pstats
import threading
import time
import collections.defaultdict,
import contextlib.contextmanager
import dataclasses.dataclass,
import pathlib.Path
import typing.Any,

import psutil

import noodlecore.runtime.nbc_runtime.optimization.errors.ProfilerError

logger = logging.getLogger(__name__)


# @dataclass
class ProfileResult
    #     """Represents a profiling result."""

    #     function_name: str
    #     execution_count: int
    #     total_time: float
    #     average_time: float
    #     min_time: float
    #     max_time: float
    call_stack: List[str] = field(default_factory=list)
    memory_usage: Dict[str, float] = field(default_factory=dict)
    cpu_usage: float = 0.0
    timestamp: float = field(default_factory=time.time)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary representation."""
    #         return {
    #             "function_name": self.function_name,
    #             "execution_count": self.execution_count,
    #             "total_time": self.total_time,
    #             "average_time": self.average_time,
    #             "min_time": self.min_time,
    #             "max_time": self.max_time,
    #             "call_stack": self.call_stack,
    #             "memory_usage": self.memory_usage,
    #             "cpu_usage": self.cpu_usage,
    #             "timestamp": self.timestamp,
    #         }


# @dataclass
class ProfileConfig
    #     """Configuration for profiling."""

    enabled: bool = True
    depth_limit: int = 10
    time_threshold: float = 0.001  # Only profile functions taking longer than this
    memory_tracking: bool = True
    cpu_tracking: bool = True
    output_directory: str = "profiling_results"
    max_results: int = 1000
    enable_call_stack: bool = True
    enable_line_profiling: bool = False

    #     def validate(self) -> bool:
    #         """Validate the profiling configuration."""
    #         if self.depth_limit <= 0:
    #             return False
    #         if self.time_threshold <= 0:
    #             return False
    #         if self.max_results <= 0:
    #             return False
    #         return True


class CodeProfiler
    #     """Code profiler for performance analysis."""

    #     def __init__(self, config: ProfileConfig = None):
    #         """Initialize the code profiler.

    #         Args:
    #             config: Profiling configuration
    #         """
    self.config = config or ProfileConfig()

    #         if not self.config.validate():
                raise ProfilerError(f"Invalid profiling configuration: {self.config}")

    #         # Thread-local storage for profiling data
    self._local = threading.local()

    #         # Global profiling data
    self.profile_results: Dict[str, ProfileResult] = {}
    self.call_counts: Dict[str, int] = defaultdict(int)
    self.total_execution_times: Dict[str, float] = defaultdict(float)
    self.min_execution_times: Dict[str, float] = {}
    self.max_execution_times: Dict[str, float] = {}

    #         # Lock for thread-safe operations
    self.lock = threading.RLock()

    #         # Output directory
    self.output_dir = Path(self.config.output_directory)
    self.output_dir.mkdir(exist_ok = True)

    #         # Statistics
    self.total_profiled_calls = 0
    self.total_profiled_time = 0.0
    self.profiled_functions: Set[str] = set()

    #         # Current profiling context
    self._current_context: Dict[str, Any] = {}

    #         logger.info(f"Code Profiler initialized with config: {self.config}")

    #     @contextmanager
    #     def profile(
    self, function_name: str, enable_memory: bool = None, enable_cpu: bool = None
    #     ):
    #         """Context manager for profiling a function.

    #         Args:
    #             function_name: Name of the function being profiled
                enable_memory: Whether to enable memory profiling (overrides config)
                enable_cpu: Whether to enable CPU profiling (overrides config)
    #         """
    #         if not self.config.enabled:
    #             yield
    #             return

    start_time = time.time()
    start_memory = None
    start_cpu = None

    #         try:
    #             # Initialize thread-local data
    #             if not hasattr(self._local, "profile_stack"):
    self._local.profile_stack = []

    #             # Add to call stack
                self._local.profile_stack.append(function_name)

    #             # Memory profiling
    #             if (
    #                 enable_memory
    #                 if enable_memory is not None
    #                 else self.config.memory_tracking
    #             ):
    start_memory = self._get_memory_usage()

    #             # CPU profiling
    #             if enable_cpu if enable_cpu is not None else self.config.cpu_tracking:
    start_cpu = psutil.cpu_percent(interval=None)

    #             # Execute the function
    #             yield

    #         finally:
    #             # Calculate execution time
    execution_time = math.subtract(time.time(), start_time)

    #             # Memory usage
    end_memory = None
    #             if (
    #                 enable_memory
    #                 if enable_memory is not None
    #                 else self.config.memory_tracking
    #             ):
    end_memory = self._get_memory_usage()
    memory_delta = (
                        self._calculate_memory_delta(start_memory, end_memory)
    #                     if start_memory and end_memory
    #                     else {}
    #                 )

    #             # CPU usage
    end_cpu = None
    #             if enable_cpu if enable_cpu is not None else self.config.cpu_tracking:
    end_cpu = psutil.cpu_percent(interval=None)
    #                 cpu_delta = end_cpu - start_cpu if start_cpu is not None else 0.0
    #             else:
    cpu_delta = 0.0

    #             # Remove from call stack
    #             if self._local.profile_stack:
                    self._local.profile_stack.pop()

    #             # Only record if above threshold
    #             if execution_time >= self.config.time_threshold:
                    self._record_profile_result(
    function_name = function_name,
    execution_time = execution_time,
    #                     memory_delta=memory_delta if enable_memory is not None else None,
    cpu_delta = cpu_delta,
    call_stack = (
                            list(self._local.profile_stack)
    #                         if self.config.enable_call_stack
    #                         else []
    #                     ),
    #                 )

    #     def _get_memory_usage(self) -> Dict[str, float]:
    #         """Get current memory usage."""
    #         try:
    process = psutil.Process(os.getpid())
    memory_info = process.memory_info()

    #             return {
    #                 "rss": memory_info.rss,  # Resident Set Size
    #                 "vms": memory_info.vms,  # Virtual Memory Size
                    "shared": getattr(memory_info, "shared", 0),
                    "text": getattr(memory_info, "text", 0),
                    "data": getattr(memory_info, "data", 0),
                    "stack": getattr(memory_info, "stack", 0),
    #             }
    #         except Exception as e:
                logger.warning(f"Failed to get memory usage: {e}")
    #             return {}

    #     def _calculate_memory_delta(
    #         self, start: Dict[str, float], end: Dict[str, float]
    #     ) -> Dict[str, float]:
    #         """Calculate memory usage delta."""
    delta = {}
    #         for key in start:
    #             if key in end:
    delta[key] = math.subtract(end[key], start[key])
    #         return delta

    #     def _record_profile_result(
    #         self,
    #         function_name: str,
    #         execution_time: float,
    #         memory_delta: Optional[Dict[str, float]],
    #         cpu_delta: float,
    #         call_stack: List[str],
    #     ):
    #         """Record a profiling result."""
    #         with self.lock:
    #             # Update call counts
    self.call_counts[function_name] + = 1

    #             # Update execution times
    self.total_execution_times[function_name] + = execution_time

    #             # Update min/max times
    #             if (
    #                 function_name not in self.min_execution_times
    #                 or execution_time < self.min_execution_times[function_name]
    #             ):
    self.min_execution_times[function_name] = execution_time

    #             if (
    #                 function_name not in self.max_execution_times
    #                 or execution_time > self.max_execution_times[function_name]
    #             ):
    self.max_execution_times[function_name] = execution_time

    #             # Update global statistics
    self.total_profiled_calls + = 1
    self.total_profiled_time + = execution_time
                self.profiled_functions.add(function_name)

    #             # Create profile result
    result = ProfileResult(
    function_name = function_name,
    execution_count = self.call_counts[function_name],
    total_time = self.total_execution_times[function_name],
    average_time = self.total_execution_times[function_name]
    #                 / self.call_counts[function_name],
    min_time = self.min_execution_times[function_name],
    max_time = self.max_execution_times[function_name],
    call_stack = call_stack,
    memory_usage = memory_delta or {},
    cpu_usage = cpu_delta,
    timestamp = time.time(),
    #             )

    #             # Store result
    self.profile_results[function_name] = result

    #             # Limit results count
    #             if len(self.profile_results) > self.config.max_results:
    #                 # Remove oldest result
    oldest_key = min(
                        self.profile_results.keys(),
    key = lambda k: self.profile_results[k].timestamp,
    #                 )
    #                 del self.profile_results[oldest_key]

    #     def profile_function(self, func: Callable) -> Callable:
    #         """Decorator to profile a function.

    #         Args:
    #             func: Function to profile

    #         Returns:
    #             Wrapped function with profiling
    #         """

            @functools.wraps(func)
    #         def wrapper(*args, **kwargs):
    #             with self.profile(func.__name__):
                    return func(*args, **kwargs)

    #         return wrapper

    #     def get_profile_results(
    self, function_name: str = None
    #     ) -> Union[ProfileResult, List[ProfileResult]]:
    #         """Get profiling results.

    #         Args:
    #             function_name: Optional function name to get results for

    #         Returns:
    #             Profile result or list of results
    #         """
    #         with self.lock:
    #             if function_name:
                    return self.profile_results.get(function_name)
                return list(self.profile_results.values())

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get profiling statistics."""
    #         with self.lock:
    #             return {
    #                 "total_profiled_calls": self.total_profiled_calls,
    #                 "total_profiled_time": self.total_profiled_time,
                    "profiled_functions_count": len(self.profiled_functions),
                    "profile_results_count": len(self.profile_results),
                    "average_execution_time": (
    #                     self.total_profiled_time / self.total_profiled_calls
    #                     if self.total_profiled_calls > 0
    #                     else 0
    #                 ),
                    "slowest_function": (
    max(self.max_execution_times.items(), key = lambda x: x[1])
    #                     if self.max_execution_times
    #                     else None
    #                 ),
                    "fastest_function": (
    min(self.min_execution_times.items(), key = lambda x: x[1])
    #                     if self.min_execution_times
    #                     else None
    #                 ),
                    "most_called_function": (
    max(self.call_counts.items(), key = lambda x: x[1])
    #                     if self.call_counts
    #                     else None
    #                 ),
    #                 "config": {
    #                     "enabled": self.config.enabled,
    #                     "time_threshold": self.config.time_threshold,
    #                     "memory_tracking": self.config.memory_tracking,
    #                     "cpu_tracking": self.config.cpu_tracking,
    #                 },
    #             }

    #     def get_hot_functions(self, threshold: float = None) -> List[ProfileResult]:
    #         """Get functions that are frequently called or slow.

    #         Args:
    #             threshold: Time threshold for hot functions

    #         Returns:
    #             List of hot functions
    #         """
    #         if threshold is None:
    threshold = self.config.time_threshold

    #         with self.lock:
    hot_functions = []
    #             for result in self.profile_results.values():
    #                 if (
    result.average_time > = threshold or result.execution_count >= 100
    #                 ):  # High call count threshold
                        hot_functions.append(result)

    #             # Sort by total time descending
    hot_functions.sort(key = lambda x: x.total_time, reverse=True)
    #             return hot_functions

    #     def export_profile_results(self, output_file: str = None) -> str:
    #         """Export profiling results to file.

    #         Args:
    #             output_file: Output file path

    #         Returns:
    #             Path to exported file
    #         """
    #         if output_file is None:
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    output_file = self.output_dir / f"profile_results_{timestamp}.json"

    results = {
                "statistics": self.get_statistics(),
    #             "profile_results": [
    #                 result.to_dict() for result in self.profile_results.values()
    #             ],
                "export_timestamp": time.time(),
    #         }

    #         import json

    #         with open(output_file, "w") as f:
    json.dump(results, f, indent = 2)

            logger.info(f"Profile results exported to {output_file}")
            return str(output_file)

    #     def reset(self):
    #         """Reset all profiling data."""
    #         with self.lock:
                self.profile_results.clear()
                self.call_counts.clear()
                self.total_execution_times.clear()
                self.min_execution_times.clear()
                self.max_execution_times.clear()
    self.total_profiled_calls = 0
    self.total_profiled_time = 0.0
                self.profiled_functions.clear()

            logger.info("Profiler data reset")

    #     def start_detailed_profiling(self, function_name: str):
    #         """Start detailed profiling for a function.

    #         Args:
    #             function_name: Name of the function to profile
    #         """
    #         if not self.config.enabled:
    #             return

    pr = cProfile.Profile()
            pr.enable()

    #         with self.lock:
    #             if not hasattr(self._local, "detailed_profiles"):
    self._local.detailed_profiles = {}
    self._local.detailed_profiles[function_name] = pr

    #     def stop_detailed_profiling(self, function_name: str) -> str:
    #         """Stop detailed profiling and return statistics.

    #         Args:
    #             function_name: Name of the function to stop profiling

    #         Returns:
    #             Profiling statistics as string
    #         """
    #         if not self.config.enabled:
    #             return ""

    #         with self.lock:
    #             if not hasattr(self._local, "detailed_profiles"):
    #                 return ""

    pr = self._local.detailed_profiles.pop(function_name, None)
    #             if pr is None:
    #                 return ""

                pr.disable()

    #             # Create string buffer for stats
    s = io.StringIO()
    ps = pstats.Stats(pr, stream=s).sort_stats("cumulative")
                ps.print_stats()

                return s.getvalue()

    #     def health_check(self) -> Dict[str, Any]:
    #         """Perform health check on profiler."""
    stats = self.get_statistics()

    issues = []
    #         if stats["profiled_functions_count"] == 0 and self.config.enabled:
                issues.append("No functions profiled - profiler may not be working")

    #         if stats["average_execution_time"] > 1.0:  # Slow average execution
                issues.append("High average execution time detected")

    #         if (
                len(self.profile_results) > self.config.max_results * 0.9
    #         ):  # Cache almost full
                issues.append("Profile results cache is almost full")

    #         return {
    #             "status": "healthy" if not issues else "warning",
    #             "issues": issues,
    #             "statistics": stats,
    #         }

    #     def __enter__(self):
    #         """Context manager entry."""
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit."""
    #         # Export results on exit if enabled
    #         if self.config.enabled:
                self.export_profile_results()


# Export CodeProfiler for backward compatibility
CodeProfiler = CodeProfiler
