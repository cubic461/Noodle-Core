# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Test utilities for TRM agent integration testing
# Provides comprehensive testing infrastructure with timeout, memory monitoring, and error handling
# """

import asyncio
import signal
import traceback
import time
import psutil
import gc
import threading
import weakref
import warnings
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import logging
import contextlib.asynccontextmanager,
import os
import tempfile
import shutil
import pathlib.Path

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)

class TestStatus(Enum)
    #     """Test execution status"""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    TIMEOUT = "timeout"
    CANCELLED = "cancelled"

class MemoryAlertLevel(Enum)
    #     """Memory alert levels"""
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"

# @dataclass
class TestResult
    #     """Comprehensive test result with error handling"""
    #     test_name: str
    #     status: TestStatus
    #     start_time: float
    end_time: Optional[float] = None
    duration: Optional[float] = None
    error: Optional[str] = None
    error_type: Optional[str] = None
    traceback: Optional[str] = None
    result: Optional[Any] = None
    memory_usage_mb: Optional[float] = None
    peak_memory_mb: Optional[float] = None
    warnings: List[str] = field(default_factory=list)

# @dataclass
class MemorySnapshot
    #     """Memory usage snapshot"""
    #     timestamp: float
    #     memory_usage_mb: float
    #     peak_memory_mb: float
    #     object_count: int
    #     thread_count: int
    gc_generation_counts: Dict[str, int] = field(default_factory=dict)

class MemoryMonitor
    #     """Advanced memory monitoring with limits and alerts"""

    #     def __init__(self,
    max_memory_mb: int = 500,
    warning_threshold_mb: int = 400,
    critical_threshold_mb: int = 480,
    snapshot_interval: float = 1.0,
    enable_gc_triggers: bool = True):
    self.max_memory_mb = max_memory_mb
    self.warning_threshold_mb = warning_threshold_mb
    self.critical_threshold_mb = critical_threshold_mb
    self.snapshot_interval = snapshot_interval
    self.enable_gc_triggers = enable_gc_triggers

    self.process = psutil.Process()
    self.initial_memory = None
    self.peak_memory = 0
    self.snapshots: Dict[float, MemorySnapshot] = {}
    self.alerts: List[Dict[str, Any]] = []
    self.monitoring_active = False
    self.monitor_thread: Optional[threading.Thread] = None
    self.lock = threading.Lock()

    #         # Memory tracking
    self.tracked_objects: weakref.WeakSet = weakref.WeakSet()
    self.memory_callbacks: Dict[MemoryAlertLevel, Callable] = {}

    #         # Performance tracking
    self.monitoring_overhead = 0

    #     def start(self):
    #         """Start memory monitoring"""
    #         if self.monitoring_active:
                warnings.warn("Memory monitoring is already active")
    #             return

    self.initial_memory = self._get_memory_usage_mb()
    self.peak_memory = self.initial_memory
    self.monitoring_active = True

    #         # Start monitoring thread
    self.monitor_thread = threading.Thread(target=self._monitoring_loop, daemon=True)
            self.monitor_thread.start()

    #         # Initial snapshot
            self._take_snapshot()

    #     def stop(self):
    #         """Stop memory monitoring"""
    self.monitoring_active = False
    #         if self.monitor_thread:
    self.monitor_thread.join(timeout = 1.0)

    #     def _monitoring_loop(self):
    #         """Main monitoring loop"""
    #         while self.monitoring_active:
    #             try:
    start_time = time.time()

    #                 # Take snapshot
    snapshot = self._take_snapshot()

    #                 # Check memory limits
                    self._check_memory_limits(snapshot)

    #                 # Calculate overhead
    self.monitoring_overhead = math.subtract(time.time(), start_time)

    #                 # Sleep until next interval
                    time.sleep(self.snapshot_interval)

    #             except Exception as e:
                    self._add_alert(
    level = MemoryAlertLevel.CRITICAL,
    message = f"Memory monitoring error: {str(e)}"
    #                 )

    #     def _get_memory_usage_mb(self) -> float:
    #         """Get current memory usage in MB"""
    #         try:
                return self.process.memory_info().rss / 1024 / 1024
    #         except Exception:
    #             return 0.0

    #     def _get_object_count(self) -> int:
    #         """Get approximate object count"""
    #         try:
                return len(gc.get_objects())
    #         except Exception:
    #             return 0

    #     def _get_gc_generation_counts(self) -> Dict[str, int]:
    #         """Get garbage collector generation counts"""
    #         try:
    counts = {}
    #             for i in range(3):  # Generations 0, 1, 2
    counts[f"generation_{i}"] = gc.get_count()[i]
    counts["garbage"] = len(gc.garbage)
    #             return counts
    #         except Exception:
    #             return {}

    #     def _take_snapshot(self) -> MemorySnapshot:
    #         """Take a memory snapshot"""
    current_time = time.time()
    memory_usage = self._get_memory_usage_mb()
    object_count = self._get_object_count()
    gc_counts = self._get_gc_generation_counts()
    thread_count = threading.active_count()

    #         # Update peak memory
    #         with self.lock:
    self.peak_memory = max(self.peak_memory, memory_usage)

    snapshot = MemorySnapshot(
    timestamp = current_time,
    memory_usage_mb = memory_usage,
    peak_memory_mb = self.peak_memory,
    object_count = object_count,
    thread_count = thread_count,
    gc_generation_counts = gc_counts
    #         )

    #         with self.lock:
    self.snapshots[current_time] = snapshot

    #         return snapshot

    #     def _check_memory_limits(self, snapshot: MemorySnapshot):
    #         """Check if memory limits are exceeded"""
    memory_mb = snapshot.memory_usage_mb

    #         if memory_mb >= self.critical_threshold_mb:
                self._add_alert(
    level = MemoryAlertLevel.CRITICAL,
    message = f"Critical memory usage: {memory_mb:.1f}MB >= {self.critical_threshold_mb}MB"
    #             )
                self._trigger_memory_actions(MemoryAlertLevel.CRITICAL)

    #         elif memory_mb >= self.warning_threshold_mb:
                self._add_alert(
    level = MemoryAlertLevel.WARNING,
    message = f"High memory usage: {memory_mb:.1f}MB >= {self.warning_threshold_mb}MB"
    #             )
                self._trigger_memory_actions(MemoryAlertLevel.WARNING)

    #         elif memory_mb >= self.max_memory_mb:
                raise MemoryError(f"Memory limit exceeded: {memory_mb:.1f}MB > {self.max_memory_mb}MB")

    #     def _add_alert(self, level: MemoryAlertLevel, message: str):
    #         """Add memory alert"""
    alert = {
                'timestamp': time.time(),
    #             'level': level.value,
    #             'message': message,
                'memory_usage_mb': self._get_memory_usage_mb(),
    #             'peak_memory_mb': self.peak_memory
    #         }

    #         with self.lock:
                self.alerts.append(alert)

    #         # Keep only last 100 alerts
    #         if len(self.alerts) > 100:
    self.alerts = math.subtract(self.alerts[, 100:])

    #     def _trigger_memory_actions(self, level: MemoryAlertLevel):
    #         """Trigger memory management actions"""
    #         if level == MemoryAlertLevel.CRITICAL:
    #             # Force garbage collection
                gc.collect()

    #             # Clear tracked objects
                self.tracked_objects.clear()

    #         elif level == MemoryAlertLevel.WARNING and self.enable_gc_triggers:
    #             # Suggest garbage collection
    #             if len(gc.garbage) > 0:
                    gc.collect()

    #     def register_callback(self, level: MemoryAlertLevel, callback: Callable):
    #         """Register callback for memory alerts"""
    self.memory_callbacks[level] = callback

    #     def get_memory_stats(self) -> Dict[str, Any]:
    #         """Get comprehensive memory statistics"""
    current_memory = self._get_memory_usage_mb()

    #         return {
    #             'current_memory_mb': current_memory,
    #             'peak_memory_mb': self.peak_memory,
    #             'initial_memory_mb': self.initial_memory,
    #             'memory_increase_mb': current_memory - self.initial_memory if self.initial_memory else 0,
    #             'max_memory_limit_mb': self.max_memory_mb,
    #             'warning_threshold_mb': self.warning_threshold_mb,
    #             'critical_threshold_mb': self.critical_threshold_mb,
                'tracked_object_count': len(self.tracked_objects),
                'total_alerts': len(self.alerts),
    #             'critical_alerts': len([a for a in self.alerts if a['level'] == 'critical']),
    #             'warning_alerts': len([a for a in self.alerts if a['level'] == 'warning']),
    #             'monitoring_overhead_ms': self.monitoring_overhead * 1000,
                'snapshot_count': len(self.snapshots),
                'gc_generation_counts': self._get_gc_generation_counts(),
                'thread_count': threading.active_count()
    #         }

    #     def track_object(self, obj):
    #         """Track an object for memory monitoring"""
            self.tracked_objects.add(obj)

    #     def cleanup(self):
    #         """Cleanup monitoring resources"""
            self.stop()
            self.snapshots.clear()
            self.alerts.clear()
            self.tracked_objects.clear()
            self.memory_callbacks.clear()

class AsyncTestExecutor
    #     """Advanced async test executor with comprehensive error handling"""

    #     def __init__(self, max_concurrent_tests: int = 3, timeout_seconds: int = 30):
    self.max_concurrent_tests = max_concurrent_tests
    self.timeout_seconds = timeout_seconds
    self.semaphore = asyncio.Semaphore(max_concurrent_tests)
    self.test_results: Dict[str, TestResult] = {}
    self.active_tasks: Dict[str, asyncio.Task] = {}
    self.cancelled_tasks: set = set()

    #     async def execute_test_async(self,
    #                                 test_func: Callable,
    #                                 test_name: str,
    timeout: Optional[int] = None,
    #                                 **kwargs) -> TestResult:
    #         """Execute a single async test with comprehensive error handling"""
    timeout = timeout or self.timeout_seconds
    start_time = asyncio.get_event_loop().time()

    test_result = TestResult(
    test_name = test_name,
    status = TestStatus.RUNNING,
    start_time = start_time
    #         )

    self.test_results[test_name] = test_result

    #         try:
    #             async with self.semaphore:
    #                 # Execute test with timeout
    test_result.result = await asyncio.wait_for(
                        test_func(**kwargs),
    timeout = timeout
    #                 )

    test_result.status = TestStatus.COMPLETED
    test_result.end_time = asyncio.get_event_loop().time()
    test_result.duration = math.subtract(test_result.end_time, test_result.start_time)

    #                 return test_result

    #         except asyncio.TimeoutError:
    test_result.status = TestStatus.TIMEOUT
    test_result.error = f"Test timed out after {timeout} seconds"
    test_result.error_type = "TimeoutError"
    test_result.end_time = asyncio.get_event_loop().time()
    test_result.duration = math.subtract(test_result.end_time, test_result.start_time)

    #         except Exception as e:
    test_result.status = TestStatus.FAILED
    test_result.error = str(e)
    test_result.error_type = type(e).__name__
    test_result.traceback = traceback.format_exc()
    test_result.end_time = asyncio.get_event_loop().time()
    test_result.duration = math.subtract(test_result.end_time, test_result.start_time)

    #         finally:
    #             if test_name in self.active_tasks:
    #                 del self.active_tasks[test_name]

    #         return test_result

    #     async def execute_test_batch_async(self,
    #                                      test_functions: Dict[str, Callable],
    timeout_per_test: Optional[int] = None,
    overall_timeout: Optional[int] = math.subtract(None), > Dict[str, TestResult]:)
    #         """Execute multiple tests concurrently with controlled concurrency"""
    timeout_per_test = timeout_per_test or self.timeout_seconds
    overall_timeout = math.multiply(overall_timeout or (len(test_functions), timeout_per_test))

    results = {}

    #         try:
    #             # Create tasks for all tests
    tasks = {}
    #             for test_name, test_func in test_functions.items():
    task = asyncio.create_task(
                        self.execute_test_async(test_func, test_name, timeout_per_test)
    #                 )
    tasks[test_name] = task
    self.active_tasks[test_name] = task

    #             # Wait for all tasks to complete with overall timeout
    done, pending = await asyncio.wait(
                    tasks.values(),
    timeout = overall_timeout,
    return_when = asyncio.ALL_COMPLETED
    #             )

    #             # Cancel any pending tasks
    #             for task in pending:
                    task.cancel()
                    self.cancelled_tasks.add(task)

    #             # Collect results
    #             for test_name, task in tasks.items():
    #                 if task in done:
    results[test_name] = task.result()
    #                 else:
    #                     # Task was cancelled or timed out
    results[test_name] = TestResult(
    test_name = test_name,
    status = TestStatus.CANCELLED,
    start_time = 0,
    end_time = asyncio.get_event_loop().time(),
    error = "Test was cancelled due to overall timeout"
    #                     )

    #             return results

    #         except Exception as e:
    #             # Handle any unexpected errors in batch execution
    #             for test_name in test_functions.keys():
    #                 if test_name not in results:
    results[test_name] = TestResult(
    test_name = test_name,
    status = TestStatus.FAILED,
    start_time = 0,
    end_time = asyncio.get_event_loop().time(),
    error = f"Batch execution error: {str(e)}",
    error_type = type(e).__name__
    #                     )
    #             return results

    #     def get_test_summary(self) -> Dict[str, Any]:
    #         """Generate comprehensive test execution summary"""
    total_tests = len(self.test_results)
    #         completed_tests = sum(1 for r in self.test_results.values() if r.status == TestStatus.COMPLETED)
    #         failed_tests = sum(1 for r in self.test_results.values() if r.status == TestStatus.FAILED)
    #         timeout_tests = sum(1 for r in self.test_results.values() if r.status == TestStatus.TIMEOUT)
    #         cancelled_tests = sum(1 for r in self.test_results.values() if r.status == TestStatus.CANCELLED)

    #         total_duration = sum(r.duration or 0 for r in self.test_results.values())
    #         average_duration = total_duration / total_tests if total_tests > 0 else 0

    #         return {
    #             'total_tests': total_tests,
    #             'completed': completed_tests,
    #             'failed': failed_tests,
    #             'timeouts': timeout_tests,
    #             'cancelled': cancelled_tests,
    #             'success_rate': completed_tests / total_tests if total_tests > 0 else 0,
    #             'average_duration': average_duration,
    #             'total_duration': total_duration,
                'active_tasks': len(self.active_tasks),
                'cancelled_tasks': len(self.cancelled_tasks),
    #             'detailed_results': self.test_results
    #         }

    #     async def cancel_all_tests(self):
    #         """Cancel all running tests"""
    #         for task in self.active_tasks.values():
    #             if not task.done():
                    task.cancel()
                    self.cancelled_tasks.add(task)

    #         # Wait for cancellation to complete
    await asyncio.gather(*self.active_tasks.values(), return_exceptions = True)

    #         # Update status of cancelled tests
    #         for test_name, task in self.active_tasks.items():
    #             if test_name in self.test_results:
    self.test_results[test_name].status = TestStatus.CANCELLED
    self.test_results[test_name].end_time = asyncio.get_event_loop().time()

            self.active_tasks.clear()

class TestProgressLogger
    #     """Comprehensive test progress logging"""

    #     def __init__(self, test_suite_name: str):
    self.test_suite_name = test_suite_name
    self.start_time = time.time()
    self.step_start_times: Dict[str, float] = {}
    self.step_completions: Dict[str, float] = {}
    self.current_step = None
    self.logger = logging.getLogger(f"{__name__}.{test_suite_name}")

    #     def log_step_start(self, step_name: str, total_steps: int = 1):
    #         """Log the start of a test step"""
    self.current_step = step_name
    self.step_start_times[step_name] = time.time()

            self.logger.info(f"🚀 Starting {step_name} ({total_steps} steps)")

    #     def log_step_complete(self, step_name: str):
    #         """Log the completion of a test step"""
    #         if step_name in self.step_start_times:
    duration = math.subtract(time.time(), self.step_start_times[step_name])
    self.step_completions[step_name] = duration
    #             del self.step_start_times[step_name]

                self.logger.info(f"✅ Completed {step_name} in {duration:.2f}s")

    #     def log_progress(self, current: int, total: int, message: str = ""):
    #         """Log test progress"""
    #         percentage = (current / total) * 100 if total > 0 else 0
    elapsed = math.subtract(time.time(), self.start_time)

    #         if message:
                self.logger.info(f"📊 Progress: {current}/{total} ({percentage:.1f}%) - {message}")
    #         else:
                self.logger.info(f"📊 Progress: {current}/{total} ({percentage:.1f}%) - Elapsed: {elapsed:.2f}s")

    #     def log_test_result(self, test_name: str, status: str, duration: float = 0):
    #         """Log individual test result"""
    status_icon = {
    #             TestStatus.COMPLETED.value: "✅",
    #             TestStatus.FAILED.value: "❌",
    #             TestStatus.TIMEOUT.value: "⏰",
    #             TestStatus.CANCELLED.value: "⏸"
            }.get(status, "❓")

            self.logger.info(f"{status_icon} {test_name}: {status} ({duration:.2f}s)")

    #     def log_memory_usage(self):
    #         """Log current memory usage"""
    #         try:
    process = psutil.Process()
    memory_mb = math.divide(process.memory_info().rss, 1024 / 1024)
                self.logger.info(f"💾 Memory usage: {memory_mb:.1f}MB")
    #         except Exception as e:
                self.logger.warning(f"Could not get memory usage: {e}")

    #     def log_error(self, error: Exception, context: str = ""):
    #         """Log error with context"""
    #         error_msg = f"❌ Error in {context}: {str(error)}" if context else f"❌ Error: {str(error)}"
            self.logger.error(error_msg)
            self.logger.debug(f"Traceback: {traceback.format_exc()}")

    #     def log_warning(self, message: str):
    #         """Log warning message"""
            self.logger.warning(f"⚠️  Warning: {message}")

    #     def log_info(self, message: str):
    #         """Log info message"""
            self.logger.info(f"ℹ️  {message}")

    #     def generate_summary(self) -> str:
    #         """Generate execution summary"""
    total_time = math.subtract(time.time(), self.start_time)

    summary = []
    summary.append(" = " * 60)
            summary.append(f"TEST SUITE SUMMARY: {self.test_suite_name}")
    summary.append(" = " * 60)
            summary.append(f"Total execution time: {total_time:.2f}s")
            summary.append("")

            summary.append("STEP COMPLETION TIMES:")
    #         for step, duration in self.step_completions.items():
                summary.append(f"  {step}: {duration:.2f}s")
            summary.append("")

            summary.append("ACTIVE STEPS:")
    #         for step, start_time in self.step_start_times.items():
    elapsed = math.subtract(time.time(), start_time)
                summary.append(f"  {step}: {elapsed:.2f}s (running)")
            summary.append("")

            return "\n".join(summary)

# @contextmanager
function temporary_directory(prefix: str = "test_")
    #     """Context manager for temporary directory with automatic cleanup"""
    temp_dir = None
    #     try:
    temp_dir = tempfile.mkdtemp(prefix=prefix)
    #         yield temp_dir
    #     finally:
    #         if temp_dir and os.path.exists(temp_dir):
    shutil.rmtree(temp_dir, ignore_errors = True)

# @asynccontextmanager
# async def async_timeout(timeout_seconds: int):
#     """Async context manager for timeout"""
#     async def timeout_handler():
        await asyncio.sleep(timeout_seconds)
        raise asyncio.TimeoutError(f"Operation timed out after {timeout_seconds} seconds")

timeout_task = asyncio.create_task(timeout_handler())
#     try:
#         yield
#     finally:
        timeout_task.cancel()
#         try:
#             await timeout_task
#         except asyncio.CancelledError:
#             pass

class TRMTestFixture
    #     """TRM test fixture with proper cleanup"""

    #     def __init__(self):
    self.temp_dirs: Set[str] = set()
    self.tracked_agents: Set[Any] = set()
    self.cleanup_called = False

    #     def create_temp_directory(self, prefix: str = "trm_test_") -> str:
    #         """Create temporary directory for testing"""
    temp_dir = tempfile.mkdtemp(prefix=prefix)
            self.temp_dirs.add(temp_dir)
    #         return temp_dir

    #     def track_agent(self, agent):
    #         """Track TRM agent for cleanup"""
            self.tracked_agents.add(agent)

    #     async def setup(self):
    #         """Setup test fixture"""
    #         # Create necessary directories
    self.temp_data_dir = self.create_temp_directory("trm_data_")
    self.temp_output_dir = self.create_temp_directory("trm_output_")

    #         # Initialize any required resources
    #         pass

    #     async def cleanup(self):
    #         """Cleanup test fixture"""
    #         if self.cleanup_called:
    #             return

    self.cleanup_called = True

    #         # Stop all tracked agents
    #         for agent in self.tracked_agents:
    #             try:
    #                 if hasattr(agent, 'stop'):
                        await agent.stop()
    #                 elif hasattr(agent, 'close'):
                        await agent.close()
    #             except Exception as e:
                    logger.warning(f"Error cleaning up agent: {e}")

    #         # Clear tracked agents
            self.tracked_agents.clear()

    #         # Remove temporary directories
    #         for temp_dir in self.temp_dirs:
    #             try:
    #                 if os.path.exists(temp_dir):
    shutil.rmtree(temp_dir, ignore_errors = True)
    #             except Exception as e:
                    logger.warning(f"Error removing temp directory {temp_dir}: {e}")

            self.temp_dirs.clear()

    #     async def __aenter__(self):
            await self.setup()
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
            await self.cleanup()

def create_trm_test_suite(max_concurrent: int = 2, timeout: int = 20) -> Dict[str, Any]:
#     """Create complete TRM test suite configuration"""
#     return {
'executor': AsyncTestExecutor(max_concurrent_tests = max_concurrent, timeout_seconds=timeout),
'memory_monitor': MemoryMonitor(max_memory_mb = 300, warning_threshold_mb=250, critical_threshold_mb=280),
        'progress_logger': TestProgressLogger("TRM_Test_Suite"),
        'test_fixture': TRMTestFixture(),
#         'max_concurrent_tests': max_concurrent,
#         'test_timeout': timeout,
#         'enable_memory_monitoring': True,
#         'enable_progress_logging': True
#     }