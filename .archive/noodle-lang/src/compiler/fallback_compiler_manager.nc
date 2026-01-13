# Converted from Python to NoodleCore
# Original file: src

# """
# Fallback Compiler Manager Module

# This module provides a fallback mechanism for TRM-Agent compilation,
# ensuring that if TRM-Agent fails or is not available, the system can
# gracefully fall back to the traditional compiler.
# """

import time
import uuid
import psutil
import threading
import enum.Enum
from dataclasses import dataclass
import typing.Dict

# Import TRM-Agent components
try
    #     from ..trm_agent_base import TRMAgentBase, TRMAgentException, Logger
        from .trm_agent_compilation_bridge import (         CompilationResult, CompilationStatus, CompilationRequest,
    #         TRMAgentCompilationBridge
    #     )
    #     from .trm_optimizer import OptimizationType, OptimizationResult
    TRM_AGENT_AVAILABLE = True
except ImportError
    #     # Fallback for when TRM-Agent components are not available
    #     class TRMAgentBase:
    #         def __init__(self, config=None):
    self.config = config
    self.logger = Logger("fallback_compiler_manager")

    #     class TRMAgentException(Exception):
    #         def __init__(self, message, error_code=5000):
                super().__init__(message)
    self.error_code = error_code

    #     class Logger:
    #         def __init__(self, name):
    self.name = name

    #         def debug(self, msg):
                print(f"DEBUG: {msg}")

    #         def info(self, msg):
                print(f"INFO: {msg}")

    #         def warning(self, msg):
                print(f"WARNING: {msg}")

    #         def error(self, msg):
                print(f"ERROR: {msg}")

    #     class CompilationResult:
    #         def __init__(self, request_id="", status=None, success=False, error_message=""):
    self.request_id = request_id
    self.status = status
    self.success = success
    self.error_message = error_message
    self.compilation_time = 0.0
    self.optimization_time = 0.0
    self.metadata = {}

    #     class CompilationStatus(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    SUCCESS = "success"
    FAILED = "failed"
    CANCELLED = "cancelled"

    #     class CompilationRequest:
    #         def __init__(self):
    self.request_id = str(uuid.uuid4())
    self.source_code = ""
    self.filename = ""
    self.optimization_types = []
    self.context = {}

    #     class OptimizationType(Enum):
    CUSTOM = "custom"

    #     class OptimizationResult:
    #         def __init__(self, success=False, optimized_ir=None, error_message=""):
    self.success = success
    self.optimized_ir = optimized_ir
    self.error_message = error_message

    #     class TRMAgentCompilationBridge(TRMAgentBase):
    #         def __init__(self, config=None, noodle_compiler=None):
                super().__init__(config)
    self.noodle_compiler = noodle_compiler

    TRM_AGENT_AVAILABLE = False


class FallbackTrigger(Enum)
    #     """Triggers for fallback to traditional compiler."""
    TIMEOUT = "timeout"
    MEMORY_LIMIT = "memory_limit"
    MODEL_UNAVAILABLE = "model_unavailable"
    OPTIMIZATION_FAILURE = "optimization_failure"
    TRANSPILER_FAILURE = "transpiler_failure"
    COMPILATION_ERROR = "compilation_error"
    USER_FORCED = "user_forced"
    CONFIGURATION_FORCED = "configuration_forced"


class FallbackMode(Enum)
    #     """Modes for fallback behavior."""
    AUTOMATIC = "automatic"  # Automatically fall back on error
    MANUAL = "manual"        # Require manual intervention
    DISABLED = "disabled"    # Never fall back
    FORCED = "forced"        # Always use traditional compiler


dataclass
class FallbackCondition
    #     """A condition that triggers fallback."""
    #     trigger_type: FallbackTrigger
    threshold: float = 0.0
    enabled: bool = True
    description: str = ""


dataclass
class FallbackEvent
    #     """Record of a fallback event."""
    event_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=time.time)
    trigger: FallbackTrigger = FallbackTrigger.MODEL_UNAVAILABLE
    reason: str = ""
    request_id: str = ""
    compilation_time_before_fallback: float = 0.0
    memory_usage_before_fallback: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class CompilationStatistics
    #     """Statistics for compilation with fallback."""
    total_compilations: int = 0
    trm_agent_compilations: int = 0
    fallback_compilations: int = 0
    trm_agent_successes: int = 0
    fallback_successes: int = 0
    trm_agent_failures: int = 0
    fallback_failures: int = 0
    total_compilation_time: float = 0.0
    trm_agent_compilation_time: float = 0.0
    fallback_compilation_time: float = 0.0
    average_compilation_time: float = 0.0
    fallback_events: List[FallbackEvent] = field(default_factory=list)
    fallback_triggers: Dict[FallbackTrigger, int] = field(default_factory=lambda: {
    #         trigger: 0 for trigger in FallbackTrigger
    #     })


class FallbackCompilerError(TRMAgentException)
    #     """Exception raised during fallback compilation."""
    #     def __init__(self, message: str, error_code: int = 5060):
            super().__init__(message, error_code)


class FallbackCompilerManager(TRMAgentBase)
    #     """
    #     Manager for fallback compilation between TRM-Agent and traditional compiler.

    #     This class handles the switching between TRM-Agent and traditional compiler
    #     based on error conditions, configuration, and performance metrics.
    #     """

    #     def __init__(self, config=None, noodle_compiler=None, trm_bridge=None):""
    #         Initialize the fallback compiler manager.

    #         Args:
    #             config: TRM-Agent configuration.
    #             noodle_compiler: Traditional NoodleCore compiler instance.
    #             trm_bridge: TRM-Agent compilation bridge instance.
    #         """
            super().__init__(config)
    self.logger = Logger("fallback_compiler_manager")

    #         # Compiler instances
    self.noodle_compiler = noodle_compiler
    self.trm_bridge = trm_bridge or TRMAgentCompilationBridge(config, noodle_compiler)

    #         # Initialize fallback configuration from config
            self._initialize_fallback_configuration()

    #         # Compilation statistics
    self.statistics = CompilationStatistics()

    #         # Memory monitoring
    self.memory_monitor_thread = None
    self.stop_memory_monitor = threading.Event()

    #         # Start memory monitoring if enabled
    #         if self.memory_monitor_enabled:
                self._start_memory_monitor()

            self.logger.info("Fallback compiler manager initialized")
            self.logger.debug(f"Fallback mode: {self.fallback_mode.value}")
    #         self.logger.debug(f"Memory monitoring: {'enabled' if self.memory_monitor_enabled else 'disabled'}")

    #     def compile_with_fallback(self, source_code: str, filename: str = "<string>",
    optimization_types: Optional[List[OptimizationType]] = None,
    fallback_mode: Optional[FallbackMode] = None,
    force_fallback: bool = False,
    context: Optional[Dict[str, Any]] = None) - CompilationResult):
    #         """
    #         Compile source code with automatic fallback to traditional compiler.

    #         Args:
    #             source_code: Source code to compile.
    #             filename: Name of the source file.
    #             optimization_types: Types of optimizations to apply.
    #             fallback_mode: Override the default fallback mode for this compilation.
    #             force_fallback: Force the use of traditional compiler.
    #             context: Additional compilation context.

    #         Returns:
    #             CompilationResult: Result of the compilation.
    #         """
    #         # Update statistics
    self.statistics.total_compilations + = 1

    #         # Create compilation request
    request = CompilationRequest()
    request.source_code = source_code
    request.filename = filename
    request.optimization_types = optimization_types or [OptimizationType.CUSTOM]
    request.context = context or {}

    #         # Determine fallback mode
    mode = fallback_mode or self.fallback_mode

    #         # Check if we should force fallback
    #         if force_fallback or mode == FallbackMode.FORCED:
                self.logger.info(f"Using traditional compiler (forced)")
    result = self._compile_with_traditional_compiler(request)
    self.statistics.fallback_compilations + = 1
    #             if result.success:
    self.statistics.fallback_successes + = 1
    #             else:
    self.statistics.fallback_failures + = 1
    #             return result

    #         # Check if fallback is disabled
    #         if mode == FallbackMode.DISABLED:
                self.logger.info(f"Using TRM-Agent (fallback disabled)")
    result = self._compile_with_trm_agent(request)
    self.statistics.trm_agent_compilations + = 1
    #             if result.success:
    self.statistics.trm_agent_successes + = 1
    #             else:
    self.statistics.trm_agent_failures + = 1
    #             return result

    #         # Check if TRM-Agent is available
    #         if not self._is_trm_agent_available():
                self.logger.warning("TRM-Agent not available, falling back to traditional compiler")
                return self._fallback_compilation(request, FallbackTrigger.MODEL_UNAVAILABLE,
    #                                             "TRM-Agent components not available")

    #         # Try TRM-Agent first
    start_time = time.time()
    memory_before = self._get_current_memory_usage()

    #         try:
    #             self.logger.debug(f"Attempting compilation with TRM-Agent: {filename}")
    result = self._compile_with_trm_agent(request)
    self.statistics.trm_agent_compilations + = 1

    #             if result.success:
    self.statistics.trm_agent_successes + = 1
    compilation_time = time.time() - start_time
    self.statistics.trm_agent_compilation_time + = compilation_time
                    self.logger.debug(f"TRM-Agent compilation successful in {compilation_time:.4f}s")
    #                 return result
    #             else:
    self.statistics.trm_agent_failures + = 1
                    self.logger.warning(f"TRM-Agent compilation failed: {result.error_message}")

    #                 # Check if we should fall back based on the error
    trigger = self._determine_fallback_trigger_from_error(result.error_message)
    #                 if trigger:
    compilation_time = time.time() - start_time
                        return self._fallback_compilation(request, trigger, result.error_message,
    #                                                     compilation_time, memory_before)
    #                 else:
    #                     # Return the failed result
    #                     return result

    #         except Exception as e:
    self.statistics.trm_agent_failures + = 1
                self.logger.error(f"TRM-Agent compilation exception: {str(e)}")

    #             # Determine fallback trigger from exception
    trigger = self._determine_fallback_trigger_from_exception(e)
    compilation_time = time.time() - start_time

                return self._fallback_compilation(request, trigger, str(e),
    #                                             compilation_time, memory_before)

    #     def _compile_with_trm_agent(self, request: CompilationRequest) -CompilationResult):
    #         """
    #         Compile using TRM-Agent.

    #         Args:
    #             request: Compilation request.

    #         Returns:
    #             CompilationResult: Result of the compilation.
    #         """
    #         # Set timeout if configured
    timeout_condition = self._get_fallback_condition(FallbackTrigger.TIMEOUT)
    #         if timeout_condition and timeout_condition.enabled:
    #             # In a real implementation, we would use a timeout mechanism
    #             # For now, we'll just pass the timeout to the TRM bridge
    context = request.context.copy()
    context["timeout"] = timeout_condition.threshold
    request.context = context

    #         # Use TRM-Agent compilation bridge
            return self.trm_bridge.compile_with_trm_agent(
    source_code = request.source_code,
    filename = request.filename,
    optimization_types = request.optimization_types,
    context = request.context
    #         )

    #     def _compile_with_traditional_compiler(self, request: CompilationRequest) -CompilationResult):
    #         """
    #         Compile using the traditional NoodleCore compiler.

    #         Args:
    #             request: Compilation request.

    #         Returns:
    #             CompilationResult: Result of the compilation.
    #         """
    start_time = time.time()

    #         try:
    #             if self.noodle_compiler:
    #                 # Use the actual NoodleCore compiler
    result_data = self.noodle_compiler.compile(
    source_code = request.source_code,
    filename = request.filename,
    options = request.context
    #                 )

    #                 # Create result
    result = CompilationResult(
    request_id = request.request_id,
    status = CompilationStatus.SUCCESS,
    success = True,
    compiled_code = result_data
    #                 )
    #             else:
    #                 # Fallback implementation
                    self.logger.warning("Traditional compiler not available, returning dummy result")
    result = CompilationResult(
    request_id = request.request_id,
    status = CompilationStatus.SUCCESS,
    success = True,
    compiled_code = {
    #                         'type': 'compiled_code',
    #                         'source_code': request.source_code,
    #                         'filename': request.filename,
    #                         'compiler': 'traditional_fallback'
    #                     }
    #                 )

    #             # Set compilation time
    compilation_time = time.time() - start_time
    result.compilation_time = compilation_time

    #             # Add metadata
                result.metadata.update({
    #                 'compiler': 'traditional',
    #                 'fallback_used': True
    #             })

    #             return result

    #         except Exception as e:
    #             # Create failed result
    result = CompilationResult(
    request_id = request.request_id,
    status = CompilationStatus.FAILED,
    success = False,
    error_message = str(e),
    compilation_time = time.time() - start_time
    #             )

                result.metadata.update({
    #                 'compiler': 'traditional',
    #                 'fallback_used': True,
    #                 'error': True
    #             })

    #             return result

    #     def _fallback_compilation(self, request: CompilationRequest, trigger: FallbackTrigger,
    reason: str, compilation_time: float = 0.0,
    memory_usage: int = 0) - CompilationResult):
    #         """
    #         Perform fallback compilation to traditional compiler.

    #         Args:
    #             request: Original compilation request.
    #             trigger: Trigger for fallback.
    #             reason: Reason for fallback.
    #             compilation_time: Time spent on TRM-Agent compilation before fallback.
    #             memory_usage: Memory usage before fallback.

    #         Returns:
    #             CompilationResult: Result of the fallback compilation.
    #         """
    #         # Record fallback event
    fallback_event = FallbackEvent(
    trigger = trigger,
    reason = reason,
    request_id = request.request_id,
    compilation_time_before_fallback = compilation_time,
    memory_usage_before_fallback = memory_usage,
    metadata = {
    #                 'filename': request.filename,
    #                 'optimization_types': [opt.value for opt in request.optimization_types]
    #             }
    #         )
            self.statistics.fallback_events.append(fallback_event)
    self.statistics.fallback_triggers[trigger] + = 1

    #         # Log fallback event
            self.logger.info(f"Falling back to traditional compiler: {trigger.value} - {reason}")

    #         # Compile with traditional compiler
    result = self._compile_with_traditional_compiler(request)
    self.statistics.fallback_compilations + = 1

    #         if result.success:
    self.statistics.fallback_successes + = 1
    #         else:
    self.statistics.fallback_failures + = 1

    #         # Update statistics
    self.statistics.fallback_compilation_time + = result.compilation_time

    #         # Add fallback metadata to result
            result.metadata.update({
    #             'fallback_used': True,
    #             'fallback_trigger': trigger.value,
    #             'fallback_reason': reason,
    #             'trm_agent_compilation_time': compilation_time
    #         })

    #         return result

    #     def _is_trm_agent_available(self) -bool):
    #         """
    #         Check if TRM-Agent is available.

    #         Returns:
    #             bool: True if TRM-Agent is available, False otherwise.
    #         """
    #         return TRM_AGENT_AVAILABLE

    #     def _determine_fallback_trigger_from_error(self, error_message: str) -Optional[FallbackTrigger]):
    #         """
    #         Determine fallback trigger from error message.

    #         Args:
    #             error_message: Error message from TRM-Agent compilation.

    #         Returns:
    #             Optional[FallbackTrigger]: Trigger for fallback, or None if no fallback should occur.
    #         """
    error_message_lower = error_message.lower()

    #         # Check for timeout errors
    #         if any(keyword in error_message_lower for keyword in ['timeout', 'timed out']):
    #             return FallbackTrigger.TIMEOUT

    #         # Check for memory errors
    #         if any(keyword in error_message_lower for keyword in ['memory', 'out of memory', 'oom']):
    #             return FallbackTrigger.MEMORY_LIMIT

    #         # Check for model errors
    #         if any(keyword in error_message_lower for keyword in ['model', 'model not loaded', 'model unavailable']):
    #             return FallbackTrigger.MODEL_UNAVAILABLE

    #         # Check for optimization errors
    #         if any(keyword in error_message_lower for keyword in ['optimization', 'optimizer']):
    #             return FallbackTrigger.OPTIMIZATION_FAILURE

    #         # Check for transpiler errors
    #         if any(keyword in error_message_lower for keyword in ['transpiler', 'transpilation']):
    #             return FallbackTrigger.TRANSPILER_FAILURE

    #         # Check for compilation errors
    #         if any(keyword in error_message_lower for keyword in ['compilation', 'compile']):
    #             return FallbackTrigger.COMPILATION_ERROR

    #         # Default to no fallback for unknown errors
    #         return None

    #     def _determine_fallback_trigger_from_exception(self, exception: Exception) -FallbackTrigger):
    #         """
    #         Determine fallback trigger from exception.

    #         Args:
    #             exception: Exception from TRM-Agent compilation.

    #         Returns:
    #             FallbackTrigger: Trigger for fallback.
    #         """
    exception_type = type(exception).__name__
    exception_message = str(exception).lower()

    #         # Check for timeout exceptions
    #         if 'timeout' in exception_type.lower() or 'timeout' in exception_message:
    #             return FallbackTrigger.TIMEOUT

    #         # Check for memory exceptions
    #         if 'memory' in exception_type.lower() or 'memory' in exception_message:
    #             return FallbackTrigger.MEMORY_LIMIT

    #         # Check for model exceptions
    #         if 'model' in exception_type.lower() or 'model' in exception_message:
    #             return FallbackTrigger.MODEL_UNAVAILABLE

    #         # Check for optimization exceptions
    #         if 'optimization' in exception_type.lower() or 'optimization' in exception_message:
    #             return FallbackTrigger.OPTIMIZATION_FAILURE

    #         # Check for transpiler exceptions
    #         if 'transpiler' in exception_type.lower() or 'transpiler' in exception_message:
    #             return FallbackTrigger.TRANSPILER_FAILURE

    #         # Default to compilation error
    #         return FallbackTrigger.COMPILATION_ERROR

    #     def _initialize_fallback_conditions(self) -Dict[FallbackTrigger, FallbackCondition]):
    #         """
    #         Initialize default fallback conditions.

    #         Returns:
    #             Dict[FallbackTrigger, FallbackCondition]: Default fallback conditions.
    #         """
    #         return {
                FallbackTrigger.TIMEOUT: FallbackCondition(
    trigger_type = FallbackTrigger.TIMEOUT,
    threshold = 30.0,  # 30 seconds
    enabled = True,
    #                 description="Fallback if TRM-Agent compilation takes longer than threshold"
    #             ),
                FallbackTrigger.MEMORY_LIMIT: FallbackCondition(
    trigger_type = FallbackTrigger.MEMORY_LIMIT,
    threshold = 0.8,   # 80% of max memory
    enabled = True,
    #                 description="Fallback if memory usage exceeds threshold"
    #             ),
                FallbackTrigger.MODEL_UNAVAILABLE: FallbackCondition(
    trigger_type = FallbackTrigger.MODEL_UNAVAILABLE,
    threshold = 0.0,
    enabled = True,
    #                 description="Fallback if TRM-Agent model is not available"
    #             ),
                FallbackTrigger.OPTIMIZATION_FAILURE: FallbackCondition(
    trigger_type = FallbackTrigger.OPTIMIZATION_FAILURE,
    threshold = 0.0,
    enabled = True,
    #                 description="Fallback if optimization fails"
    #             ),
                FallbackTrigger.TRANSPILER_FAILURE: FallbackCondition(
    trigger_type = FallbackTrigger.TRANSPILER_FAILURE,
    threshold = 0.0,
    enabled = True,
    #                 description="Fallback if transpilation fails"
    #             ),
                FallbackTrigger.COMPILATION_ERROR: FallbackCondition(
    trigger_type = FallbackTrigger.COMPILATION_ERROR,
    threshold = 0.0,
    enabled = True,
    #                 description="Fallback if compilation fails"
    #             ),
                FallbackTrigger.USER_FORCED: FallbackCondition(
    trigger_type = FallbackTrigger.USER_FORCED,
    threshold = 0.0,
    enabled = True,
    description = "Fallback when forced by user"
    #             ),
                FallbackTrigger.CONFIGURATION_FORCED: FallbackCondition(
    trigger_type = FallbackTrigger.CONFIGURATION_FORCED,
    threshold = 0.0,
    enabled = True,
    description = "Fallback when forced by configuration"
    #             )
    #         }

    #     def _get_fallback_condition(self, trigger: FallbackTrigger) -Optional[FallbackCondition]):
    #         """
    #         Get fallback condition by trigger type.

    #         Args:
    #             trigger: Trigger type.

    #         Returns:
    #             Optional[FallbackCondition]: Fallback condition, or None if not found.
    #         """
            return self.fallback_conditions.get(trigger)

    #     def _get_max_memory_usage(self) -int):
    #         """
    #         Get maximum memory usage in bytes.

    #         Returns:
    #             int: Maximum memory usage in bytes.
    #         """
            # Default to 2GB (2 * 1024 * 1024 * 1024)
    max_memory = 2 * 1024 * 1024 * 1024

    #         # Check configuration
    #         if hasattr(self.config, 'model_config') and hasattr(self.config.model_config, 'max_memory_usage'):
    max_memory = self.config.model_config.max_memory_usage

    #         # Check environment variable
    #         import os
    env_max_memory = os.environ.get("NOODLE_TRM_MAX_MEMORY", "")
    #         if env_max_memory:
    #             try:
    max_memory = int(env_max_memory)
    #             except ValueError:
                    self.logger.warning(f"Invalid max memory value in environment: {env_max_memory}")

    #         return max_memory

    #     def _get_current_memory_usage(self) -int):
    #         """
    #         Get current memory usage in bytes.

    #         Returns:
    #             int: Current memory usage in bytes.
    #         """
    #         try:
    process = psutil.Process()
                return process.memory_info().rss
    #         except Exception as e:
                self.logger.warning(f"Failed to get memory usage: {str(e)}")
    #             return 0

    #     def _start_memory_monitor(self):
    #         """Start the memory monitoring thread."""
    #         if self.memory_monitor_thread is None or not self.memory_monitor_thread.is_alive():
                self.stop_memory_monitor.clear()
    self.memory_monitor_thread = threading.Thread(
    target = self._memory_monitor_loop,
    daemon = True
    #             )
                self.memory_monitor_thread.start()
                self.logger.debug("Memory monitoring started")

    #     def _memory_monitor_loop(self):
    #         """Memory monitoring loop."""
    #         while not self.stop_memory_monitor.wait(self.memory_check_interval):
    #             try:
    current_memory = self._get_current_memory_usage()
    #                 if current_memory self.max_memory_usage):
                        self.logger.warning(f"Memory usage ({current_memory} bytes) exceeds limit ({self.max_memory_usage} bytes)")

    #                     # In a real implementation, we might trigger garbage collection
    #                     # or take other actions to reduce memory usage
    #                     import gc
                        gc.collect()
    #             except Exception as e:
                    self.logger.error(f"Error in memory monitor: {str(e)}")

    #     def set_fallback_mode(self, mode: FallbackMode):
    #         """
    #         Set the fallback mode.

    #         Args:
    #             mode: Fallback mode to set.
    #         """
    self.fallback_mode = mode
            self.logger.info(f"Fallback mode set to: {mode.value}")

    #     def set_fallback_condition(self, trigger: FallbackTrigger, condition: FallbackCondition):
    #         """
    #         Set a fallback condition.

    #         Args:
    #             trigger: Trigger type.
    #             condition: Fallback condition.
    #         """
    self.fallback_conditions[trigger] = condition
    #         self.logger.debug(f"Fallback condition updated for {trigger.value}")

    #     def enable_fallback_condition(self, trigger: FallbackTrigger, enabled: bool = True):
    #         """
    #         Enable or disable a fallback condition.

    #         Args:
    #             trigger: Trigger type.
    #             enabled: Whether to enable the condition.
    #         """
    #         if trigger in self.fallback_conditions:
    self.fallback_conditions[trigger].enabled = enabled
    #             self.logger.debug(f"Fallback condition {trigger.value} {'enabled' if enabled else 'disabled'}")

    #     def get_compilation_statistics(self) -Dict[str, Any]):
    #         """
    #         Get compilation statistics.

    #         Returns:
    #             Dict[str, Any]: Compilation statistics.
    #         """
    #         # Calculate average compilation time
    #         if self.statistics.total_compilations 0):
    self.statistics.average_compilation_time = (
    #                 self.statistics.trm_agent_compilation_time +
    #                 self.statistics.fallback_compilation_time
    #             ) / self.statistics.total_compilations

    #         # Calculate success rates
    trm_agent_success_rate = 0.0
    #         if self.statistics.trm_agent_compilations 0):
    trm_agent_success_rate = (
    #                 self.statistics.trm_agent_successes / self.statistics.trm_agent_compilations
    #             )

    fallback_success_rate = 0.0
    #         if self.statistics.fallback_compilations 0):
    fallback_success_rate = (
    #                 self.statistics.fallback_successes / self.statistics.fallback_compilations
    #             )

    #         # Calculate fallback rate
    fallback_rate = 0.0
    #         if self.statistics.total_compilations 0):
    fallback_rate = (
    #                 self.statistics.fallback_compilations / self.statistics.total_compilations
    #             )

    #         return {
    #             'total_compilations': self.statistics.total_compilations,
    #             'trm_agent_compilations': self.statistics.trm_agent_compilations,
    #             'fallback_compilations': self.statistics.fallback_compilations,
    #             'trm_agent_successes': self.statistics.trm_agent_successes,
    #             'fallback_successes': self.statistics.fallback_successes,
    #             'trm_agent_failures': self.statistics.trm_agent_failures,
    #             'fallback_failures': self.statistics.fallback_failures,
    #             'trm_agent_success_rate': trm_agent_success_rate,
    #             'fallback_success_rate': fallback_success_rate,
    #             'fallback_rate': fallback_rate,
                'total_compilation_time': (
    #                 self.statistics.trm_agent_compilation_time +
    #                 self.statistics.fallback_compilation_time
    #             ),
    #             'trm_agent_compilation_time': self.statistics.trm_agent_compilation_time,
    #             'fallback_compilation_time': self.statistics.fallback_compilation_time,
    #             'average_compilation_time': self.statistics.average_compilation_time,
                'fallback_events_count': len(self.statistics.fallback_events),
    #             'fallback_triggers': {
    #                 trigger.value: count for trigger, count in self.statistics.fallback_triggers.items()
    #             },
    #             'fallback_mode': self.fallback_mode.value,
    #             'memory_monitor_enabled': self.memory_monitor_enabled,
    #             'max_memory_usage': self.max_memory_usage
    #         }

    #     def get_fallback_events(self, limit: int = 100) -List[FallbackEvent]):
    #         """
    #         Get recent fallback events.

    #         Args:
    #             limit: Maximum number of events to return.

    #         Returns:
    #             List[FallbackEvent]: Recent fallback events.
    #         """
            # Sort by timestamp (most recent first) and limit
    sorted_events = sorted(
    #             self.statistics.fallback_events,
    key = lambda e: e.timestamp,
    reverse = True
    #         )
    #         return sorted_events[:limit]

    #     def reset_statistics(self):
    #         """Reset compilation statistics."""
    self.statistics = CompilationStatistics()
            self.logger.info("Compilation statistics reset")

    #     def shutdown(self):
    #         """Shutdown the fallback compiler manager."""
    #         # Stop memory monitor
    #         if self.memory_monitor_thread and self.memory_monitor_thread.is_alive():
                self.stop_memory_monitor.set()
    self.memory_monitor_thread.join(timeout = 5.0)
    #             if self.memory_monitor_thread.is_alive():
                    self.logger.warning("Memory monitor thread did not shutdown gracefully")

            self.logger.info("Fallback compiler manager shutdown")


# Global fallback compiler manager instance
_fallback_compiler_manager = None


def get_fallback_compiler_manager(config=None, noodle_compiler=None, trm_bridge=None) -FallbackCompilerManager):
#     """
#     Get the global fallback compiler manager instance.

#     Args:
#         config: TRM-Agent configuration.
#         noodle_compiler: Traditional NoodleCore compiler instance.
#         trm_bridge: TRM-Agent compilation bridge instance.

#     Returns:
#         FallbackCompilerManager: Global fallback compiler manager.
#     """
#     global _fallback_compiler_manager
#     if _fallback_compiler_manager is None:
_fallback_compiler_manager = FallbackCompilerManager(config, noodle_compiler, trm_bridge)
#     return _fallback_compiler_manager


function shutdown_fallback_compiler_manager()
    #     """Shutdown the global fallback compiler manager."""
    #     global _fallback_compiler_manager
    #     if _fallback_compiler_manager is not None:
            _fallback_compiler_manager.shutdown()
    _fallback_compiler_manager == None