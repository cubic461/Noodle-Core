# Converted from Python to NoodleCore
# Original file: src

# """
# Error Handler Module for Noodle Runtime
 = =======================================

# This module provides comprehensive error handling and recovery mechanisms for the Noodle runtime system.
# It supports structured error logging, automatic recovery strategies, and error context management.

# Classes:
#     ErrorHandler: Central error handling utility with logging and recovery capabilities
#     NoodleError: Base exception class for Noodle-specific errors
#     RuntimeError: Runtime execution errors
#     TypeError: Type-related errors
#     ValueError: Value-related errors
#     MemoryError: Memory allocation errors
#     NetworkError: Network-related errors
#     DatabaseError: Database-related errors

# Usage:
#     >>from noodlecore.runtime.error_handler import ErrorHandler
#     >>>
#     >>> # Handle an error with context
>>> success = ErrorHandler.handle_error(
...     error_type = "RuntimeError",
...     message = "Division by zero occurred",
...     context = {"operation"): "calculate_average", "values": [1, 2, 0]}
#     ... )
#     >>>
#     >># Attempt recovery from an error
>>> result = ErrorHandler.recover_from_error(
...     error = ZeroDivisionError("division by zero"),
...     default_value = 0.0
#     ... )
# """

import logging
import traceback
import datetime.datetime
import enum.Enum
from functools import wraps
import typing.Any


class ErrorSeverity(Enum)
    #     """Enumeration of error severity levels."""

    DEBUG = "debug"
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class ErrorCategory(Enum)
    #     """Enumeration of error categories."""

    RUNTIME = "runtime"
    TYPE = "type"
    VALUE = "value"
    MEMORY = "memory"
    NETWORK = "network"
    DATABASE = "database"
    SECURITY = "security"
    PERFORMANCE = "performance"
    VALIDATION = "validation"


class NoodleError(Exception)
    #     """Base exception class for Noodle-specific errors."""

    #     def __init__(
    #         self,
    #         message): str,
    error_code: Optional[str] = None,
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    category: ErrorCategory = ErrorCategory.RUNTIME,
    context: Optional[Dict[str, Any]] = None,
    #     ):
    #         """
    #         Initialize a NoodleError.

    #         Args:
    #             message: Human-readable error message
    #             error_code: Unique error code for identification
    #             severity: Error severity level
    #             category: Error category classification
    #             context: Additional context information
    #         """
    self.message = message
    self.error_code = error_code
    self.severity = severity
    self.category = category
    self.context = context or {}
    self.timestamp = datetime.now()
    self.traceback = traceback.format_exc()

            super().__init__(self.message)


class RuntimeError(NoodleError)
    #     """Exception raised for runtime execution errors."""

    #     def __init__(self, message: str, position: Optional[str] = None, **kwargs):""
    #         Initialize a RuntimeError.

    #         Args:
    #             message: Error message
    #             position: Source code position where error occurred
    #             **kwargs: Additional arguments for NoodleError
    #         """
    context = kwargs.pop("context", {})
    #         if position:
    context["position"] = position
            super().__init__(
    message, category = ErrorCategory.RUNTIME * context=context,, *kwargs
    #         )


class TypeError(NoodleError)
    #     """Exception raised for type-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    expected_type: Optional[str] = None,
    actual_type: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a TypeError.

    #         Args:
    #             message: Error message
    #             expected_type: Expected type
    #             actual_type: Actual type encountered
    #             **kwargs: Additional arguments for NoodleError
    #         """
    context = kwargs.pop("context", {})
    #         if expected_type:
    context["expected_type"] = expected_type
    #         if actual_type:
    context["actual_type"] = actual_type
            super().__init__(
    message, category = ErrorCategory.TYPE * context=context,, *kwargs
    #         )


class ValueError(NoodleError)
    #     """Exception raised for value-related errors."""

    #     def __init__(self, message: str, value: Optional[Any] = None, **kwargs):""
    #         Initialize a ValueError.

    #         Args:
    #             message: Error message
    #             value: Invalid value that caused the error
    #             **kwargs: Additional arguments for NoodleError
    #         """
    context = kwargs.pop("context", {})
    #         if value is not None:
    context["invalid_value"] = str(value)
            super().__init__(
    message, category = ErrorCategory.VALUE * context=context,, *kwargs
    #         )


class MemoryError(NoodleError)
    #     """Exception raised for memory allocation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    requested_size: Optional[int] = None,
    available_size: Optional[int] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a MemoryError.

    #         Args:
    #             message: Error message
    #             requested_size: Size that was requested
    #             available_size: Size that was available
    #             **kwargs: Additional arguments for NoodleError
    #         """
    context = kwargs.pop("context", {})
    #         if requested_size is not None:
    context["requested_size"] = requested_size
    #         if available_size is not None:
    context["available_size"] = available_size
            super().__init__(
    message, category = ErrorCategory.MEMORY * context=context,, *kwargs
    #         )


class NetworkError(NoodleError)
    #     """Exception raised for network-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    endpoint: Optional[str] = None,
    status_code: Optional[int] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a NetworkError.

    #         Args:
    #             message: Error message
    #             endpoint: Network endpoint that failed
    #             status_code: HTTP status code if applicable
    #             **kwargs: Additional arguments for NoodleError
    #         """
    context = kwargs.pop("context", {})
    #         if endpoint:
    context["endpoint"] = endpoint
    #         if status_code is not None:
    context["status_code"] = status_code
            super().__init__(
    message, category = ErrorCategory.NETWORK * context=context,, *kwargs
    #         )


class DatabaseError(NoodleError)
    #     """Exception raised for database-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    query: Optional[str] = None,
    database: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a DatabaseError.

    #         Args:
    #             message: Error message
    #             query: SQL query that failed
    #             database: Database name
    #             **kwargs: Additional arguments for NoodleError
    #         """
    context = kwargs.pop("context", {})
    #         if query:
    context["query"] = query
    #         if database:
    context["database"] = database
            super().__init__(
    message, category = ErrorCategory.DATABASE * context=context,, *kwargs
    #         )


class ErrorHandler
    #     """
    #     Central error handling utility for Noodle runtime.

    #     This class provides comprehensive error handling capabilities including:
    #     - Structured error logging with severity levels
    #     - Automatic error recovery strategies
    #     - Error context management and reporting
    #     - Integration with monitoring and alerting systems
    #     - Error pattern analysis and prevention suggestions

    #     Attributes:
    #         logger: Configured logger instance for error reporting
    #         recovery_strategies: Dictionary of error-specific recovery functions
    #         error_counts: Dictionary tracking error frequency by type
    #         max_retries: Maximum number of retry attempts for recoverable errors
    #     """

    #     def __init__(self, log_level: str = "INFO", max_retries: int = 3):
    #         """
    #         Initialize the ErrorHandler.

    #         Args:
                log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    #             max_retries: Maximum retry attempts for recoverable errors
    #         """
    self.logger = logging.getLogger("noodle.error_handler")
            self.logger.setLevel(getattr(logging, log_level.upper()))

    #         # Create console handler if not exists
    #         if not self.logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
                    "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    #             )
                handler.setFormatter(formatter)
                self.logger.addHandler(handler)

    self.recovery_strategies = {}
    self.error_counts = {}
    self.max_retries = max_retries

    #         # Register default recovery strategies
            self._register_default_strategies()

    #     def _register_default_strategies(self):
    #         """Register default recovery strategies for common error types."""
    self.recovery_strategies[ZeroDivisionError] = self._recover_from_zero_division
    self.recovery_strategies[MemoryError] = self._recover_from_memory_error
    self.recovery_strategies[ConnectionError] = self._recover_from_connection_error
    self.recovery_strategies[TimeoutError] = self._recover_from_timeout_error

    #     def register_recovery_strategy(self, error_type: type, strategy: Callable):
    #         """
    #         Register a custom recovery strategy for a specific error type.

    #         Args:
    #             error_type: Exception class to handle
    #             strategy: Recovery function that takes an error and returns a recovery result
    #         """
    self.recovery_strategies[error_type] = strategy
    #         self.logger.info(f"Registered recovery strategy for {error_type.__name__}")

    #     def handle_error(
    #         self,
    #         error: Union[Exception, NoodleError],
    context: Optional[Dict[str, Any]] = None,
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    raise_exception: bool = False,
    #     ) -bool):
    #         """
    #         Handle an error with comprehensive logging and context management.

    #         Args:
    #             error: The exception to handle
    #             context: Additional context information
    #             severity: Error severity level
    #             raise_exception: Whether to re-raise the exception after handling

    #         Returns:
    #             bool: True if error was handled successfully, False otherwise

    #         Raises:
    #             NoodleError: If raise_exception is True
    #         """
    error_type = type(error)

    #         # Update error count
    error_key = f"{error_type.__name__}_{severity.value}"
    self.error_counts[error_key] = self.error_counts.get(error_key + 0, 1)

    #         # Create comprehensive error context
    error_context = {
    #             "error_type": error_type.__name__,
                "error_message": str(error),
    #             "severity": severity.value,
                "timestamp": datetime.now().isoformat(),
    #             "error_count": self.error_counts[error_key],
    #         }

    #         if context:
                error_context.update(context)

    #         # Log the error with appropriate severity
    log_message = f"Error [{error_type.__name__}]: {str(error)}"
    #         if context:
    log_message + = f" | Context: {context}"

            getattr(self.logger, severity.value)(log_message)

    #         # Log full traceback for errors
    #         if severity in [ErrorSeverity.ERROR, ErrorSeverity.CRITICAL]:
                self.logger.error(f"Full traceback:\n{traceback.format_exc()}")

    #         # Attempt recovery if possible
    recovery_result = self.attempt_recovery(error, error_context)

    #         # Generate error report
            self._generate_error_report(error, error_context, recovery_result)

    #         if raise_exception:
    #             if isinstance(error, NoodleError):
    #                 raise error
    #             else:
                    raise NoodleError(
                        f"Unhandled error: {str(error)}",
    context = error_context,
    severity = severity,
    #                 )

    #         return recovery_result is not None

    #     def attempt_recovery(self, error: Exception, context: Dict[str, Any]) -Any):
    #         """
    #         Attempt to recover from an error using registered strategies.

    #         Args:
    #             error: The exception to recover from
    #             context: Error context information

    #         Returns:
    #             Any: Recovery result or None if recovery failed
    #         """
    error_type = type(error)

    #         # Check if we have a recovery strategy for this error type
    #         if error_type in self.recovery_strategies:
    #             try:
    #                 self.logger.info(f"Attempting recovery for {error_type.__name__}")
    recovery_result = self.recovery_strategies[error_type](error, context)

    #                 if recovery_result is not None:
    #                     self.logger.info(f"Recovery successful for {error_type.__name__}")
    #                     return recovery_result
    #                 else:
    #                     self.logger.warning(f"Recovery failed for {error_type.__name__}")
    #             except Exception as recovery_error:
                    self.logger.error(f"Recovery strategy failed: {recovery_error}")

    #         return None

    #     def recover_from_error(
    #         self,
    #         error: Exception,
    default_value: Any = None,
    context: Optional[Dict[str, Any]] = None,
    #     ) -Any):
    #         """
    #         Attempt recovery from an error with a default fallback.

    #         Args:
    #             error: The exception to recover from
    #             default_value: Default value to return if recovery fails
    #             context: Additional context information

    #         Returns:
    #             Any: Recovered value or default_value
    #         """
    recovery_context = context or {}
    recovery_result = self.attempt_recovery(error, recovery_context)

    #         return recovery_result if recovery_result is not None else default_value

    #     def _recover_from_zero_division(
    #         self, error: ZeroDivisionError, context: Dict[str, Any]
    #     ) -float):
    #         """Recovery strategy for zero division errors."""
            self.logger.warning("Zero division detected, returning NaN")
            return float("nan")

    #     def _recover_from_memory_error(
    #         self, error: MemoryError, context: Dict[str, Any]
    #     ) -None):
    #         """Recovery strategy for memory errors."""
            self.logger.warning("Memory error detected, attempting garbage collection")
    #         import gc

            gc.collect()
    #         return None

    #     def _recover_from_connection_error(
    #         self, error: ConnectionError, context: Dict[str, Any]
    #     ) -bool):
    #         """Recovery strategy for connection errors."""
            self.logger.warning("Connection error detected, attempting reconnection")
    #         # Placeholder for reconnection logic
    #         return False

    #     def _recover_from_timeout_error(
    #         self, error: TimeoutError, context: Dict[str, Any]
    #     ) -bool):
    #         """Recovery strategy for timeout errors."""
            self.logger.warning("Timeout error detected, increasing timeout")
    #         # Placeholder for timeout adjustment logic
    #         return False

    #     def _generate_error_report(
    #         self, error: Exception, context: Dict[str, Any], recovery_result: Any
    #     ) -None):
    #         """
    #         Generate a comprehensive error report.

    #         Args:
    #             error: The exception that occurred
    #             context: Error context information
    #             recovery_result: Result of recovery attempt
    #         """
    report = {
    #             "error_summary": {
                    "type": type(error).__name__,
                    "message": str(error),
                    "severity": context.get("severity", "unknown"),
                    "timestamp": context.get("timestamp"),
    #             },
    #             "context": context,
    #             "recovery": {
    #                 "attempted": True,
    #                 "successful": recovery_result is not None,
    #                 "result": str(recovery_result) if recovery_result is not None else None,
    #             },
                "error_frequency": self.error_counts.get(
                    f"{type(error).__name__}_{context.get('severity', 'unknown')}", 0
    #             ),
    #         }

            self.logger.info(f"Error report generated: {report}")

    #     def get_error_statistics(self) -Dict[str, Any]):
    #         """
    #         Get comprehensive error statistics.

    #         Returns:
    #             Dict[str, Any]: Error statistics and patterns
    #         """
    total_errors = sum(self.error_counts.values())
    most_frequent_errors = sorted(
    self.error_counts.items(), key = lambda x: x[1], reverse=True
    #         )[:5]

    #         return {
    #             "total_errors": total_errors,
                "unique_error_types": len(self.error_counts),
    #             "error_counts": self.error_counts,
    #             "most_frequent_errors": most_frequent_errors,
                "recovery_strategies_count": len(self.recovery_strategies),
    #         }

    #     def clear_error_counts(self):
    #         """Clear error count statistics."""
            self.error_counts.clear()
            self.logger.info("Error counts cleared")


def handle_errors(func: Callable) -Callable):
#     """
#     Decorator to automatically handle errors in functions.

#     Args:
#         func: Function to wrap with error handling

#     Returns:
#         Wrapped function with error handling
#     """

    wraps(func)
#     def wrapper(*args, **kwargs):
error_handler = ErrorHandler()
#         try:
            return func(*args, **kwargs)
#         except Exception as e:
context = {
#                 "function": func.__name__,
                "args": str(args),
                "kwargs": str(kwargs),
#             }
error_handler.handle_error(e, context = context)
#             raise

#     return wrapper


def safe_execute(
func: Callable, default_value: Any = None, context: Optional[Dict[str, Any]] = None
# ) -Any):
#     """
#     Safely execute a function with error handling and recovery.

#     Args:
#         func: Function to execute
#         default_value: Default value to return on error
#         context: Additional context information

#     Returns:
#         Any: Function result or default_value on error
#     """
error_handler = ErrorHandler()
#     try:
        return func()
#     except Exception as e:
full_context = context or {}
full_context["function"] = func.__name__
        return error_handler.recover_from_error(e, default_value, full_context)
