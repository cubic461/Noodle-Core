# Converted from Python to NoodleCore
# Original file: src

# """
# Error Handler for NBC Runtime

# This module provides centralized error handling with consistent error messages,
# proper exception chaining, and comprehensive error recovery mechanisms.
# """

import logging
import traceback
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import typing.Any

logger = logging.getLogger(__name__)


class ErrorSeverity(Enum)
    #     """Error severity levels."""

    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class ErrorCategory(Enum)
    #     """Error categories for classification."""

    RUNTIME = "runtime"
    MEMORY = "memory"
    DATABASE = "database"
    NETWORK = "network"
    VALIDATION = "validation"
    SERIALIZATION = "serialization"
    MATRIX = "matrix"
    UNKNOWN = "unknown"


dataclass
class ErrorContext
    #     """Context information for error handling."""

    #     operation: str
    #     component: str
    timestamp: datetime = field(default_factory=datetime.now)
    stack_trace: Optional[str] = None
    additional_data: Dict[str, Any] = field(default_factory=dict)

    #     def __post_init__(self):
    #         """Generate stack trace if not provided."""
    #         if self.stack_trace is None:
    self.stack_trace = traceback.format_stack()


dataclass
class ErrorInfo
    #     """Comprehensive error information."""

    #     error_type: str
    #     message: str
    #     severity: ErrorSeverity
    #     category: ErrorCategory
    #     context: ErrorContext
    original_error: Optional[Exception] = None
    recovery_attempted: bool = False
    recovery_successful: bool = False
    recovery_message: Optional[str] = None


dataclass
class ErrorResult
    #     """Result of error handling operation."""

    #     success: bool
    error_info: Optional[ErrorInfo] = None
    recovery_successful: bool = False
    message: str = ""
    action: str = "continue"  # continue, stop, retry
    data: Dict[str, Any] = field(default_factory=dict)


class ErrorHandler
    #     """Centralized error handling system."""

    #     def __init__(self):""Initialize error handler."""
    self.handlers: Dict[Type[Exception], Callable] = {}
    self.error_history: List[ErrorInfo] = []
    self.recovery_strategies: Dict[ErrorCategory, Callable] = {}
    self.max_history_size = 1000

    #         # Register default handlers
            self._register_default_handlers()
            self._register_default_recovery_strategies()

            logger.info("ErrorHandler initialized")

    #     def _register_default_handlers(self):
    #         """Register default error handlers."""

    #         # Generic exception handler
    #         def generic_handler(error: Exception, context: ErrorContext) -ErrorInfo):
                return ErrorInfo(
    error_type = type(error).__name__,
    message = str(error),
    severity = self._classify_severity(error),
    category = self._classify_category(error),
    context = context,
    original_error = error,
    #             )

    self.handlers[Exception] = generic_handler

    #     def _register_default_recovery_strategies(self):
    #         """Register default recovery strategies."""

    #         # Memory error recovery
    #         def memory_recovery(error_info: ErrorInfo) -bool):
    #             if error_info.category == ErrorCategory.MEMORY:
                    logger.warning("Attempting memory recovery strategy")
    #                 # In a real implementation, this would trigger garbage collection
    #                 # or memory optimization strategies
    #                 return True
    #             return False

    #         # Database error recovery
    #         def database_recovery(error_info: ErrorInfo) -bool):
    #             if error_info.category == ErrorCategory.DATABASE:
                    logger.warning("Attempting database recovery strategy")
    #                 # In a real implementation, this would retry transactions
    #                 # or reconnect to database
    #                 return True
    #             return False

    self.recovery_strategies[ErrorCategory.MEMORY] = memory_recovery
    self.recovery_strategies[ErrorCategory.DATABASE] = database_recovery

    #     def register_handler(self, error_type: Type[Exception], handler: Callable):
    #         """Register error handler for specific error type."""
    self.handlers[error_type] = handler
    #         logger.debug(f"Registered handler for {error_type.__name__}")

    #     def register_recovery_strategy(self, category: ErrorCategory, strategy: Callable):
    #         """Register recovery strategy for error category."""
    self.recovery_strategies[category] = strategy
    #         logger.debug(f"Registered recovery strategy for {category.value}")

    #     def handle_error(
    self, error: Exception, context: Optional[Dict[str, Any]] = None
    #     ) -Dict[str, Any]):
    #         """Handle error with registered handler."""
    #         # Convert context to ErrorContext if needed
    #         if context is None:
    context = {}

    #         if isinstance(context, dict):
    error_context = ErrorContext(
    operation = context.get("operation", "unknown"),
    component = context.get("component", "unknown"),
    additional_data = context,
    #             )
    #         else:
    error_context = context

    error_type = type(error)
    handler = self.handlers.get(error_type)

    #         if handler:
    #             try:
    error_info = handler(error, error_context)
    #                 logger.debug(f"Handled error {error_type.__name__} with custom handler")
    #             except Exception as handler_error:
                    logger.error(f"Error handler failed: {handler_error}")
    error_info = self._create_fallback_error(error, error_context)
    #         else:
    error_info = self._create_fallback_error(error, error_context)

    #         # Attempt recovery
            self._attempt_recovery(error_info)

    #         # Store in history
            self._store_error_info(error_info)

    #         # Convert to dictionary for compatibility
    #         return {
    #             "type": error_info.error_type,
    #             "message": error_info.message,
    #             "context": context,
    #         }

    #     def _create_fallback_error(
    #         self, error: Exception, context: ErrorContext
    #     ) -ErrorInfo):
    #         """Create fallback error info for unregistered error types."""
    error_info = ErrorInfo(
    error_type = type(error).__name__,
    message = str(error),
    severity = self._classify_severity(error),
    category = self._classify_category(error),
    context = context,
    original_error = error,
    #         )

    #         logger.warning(f"Using fallback handler for {error_info.error_type}")
    #         return error_info

    #     def _classify_severity(self, error: Exception) -ErrorSeverity):
    #         """Classify error severity."""
    #         if isinstance(error, (MemoryError, RuntimeError)):
    #             return ErrorSeverity.CRITICAL
    #         elif isinstance(error, (ValueError, TypeError, KeyError)):
    #             return ErrorSeverity.MEDIUM
    #         else:
    #             return ErrorSeverity.LOW

    #     def _classify_category(self, error: Exception) -ErrorCategory):
    #         """Classify error category."""
    #         if isinstance(error, MemoryError):
    #             return ErrorCategory.MEMORY
    #         elif "database" in str(error).lower() or "sql" in str(error).lower():
    #             return ErrorCategory.DATABASE
    #         elif "network" in str(error).lower() or "connection" in str(error).lower():
    #             return ErrorCategory.NETWORK
    #         elif (
                "serialization" in str(error).lower()
                or "deserialization" in str(error).lower()
    #         ):
    #             return ErrorCategory.SERIALIZATION
    #         elif "matrix" in str(error).lower() or "numpy" in str(error).lower():
    #             return ErrorCategory.MATRIX
    #         elif "validation" in str(error).lower() or "invalid" in str(error).lower():
    #             return ErrorCategory.VALIDATION
    #         else:
    #             return ErrorCategory.UNKNOWN

    #     def _attempt_recovery(self, error_info: ErrorInfo) -None):
    #         """Attempt error recovery using registered strategies."""
    #         if hasattr(error_info, "recovery_attempted") and error_info.recovery_attempted:
    #             return

    strategy = self.recovery_strategies.get(error_info.category)
    #         if strategy:
    #             try:
    success = strategy(error_info)
    error_info.recovery_attempted = True
    error_info.recovery_successful = success
    error_info.recovery_message = (
    #                     f"Recovery {'successful' if success else 'failed'}"
    #                 )

    #                 if success:
                        logger.info(f"Successfully recovered from {error_info.error_type}")
    #                 else:
    #                     logger.warning(f"Recovery failed for {error_info.error_type}")

    #             except Exception as recovery_error:
                    logger.error(f"Recovery strategy failed: {recovery_error}")
    error_info.recovery_attempted = True
    error_info.recovery_successful = False
    error_info.recovery_message = f"Recovery failed: {recovery_error}"

    #     def _store_error_info(self, error_info: ErrorInfo) -None):
    #         """Store error info in history."""
            self.error_history.append(error_info)

    #         # Maintain history size
    #         if len(self.error_history) self.max_history_size):
                self.error_history.pop(0)

    #         # Log error
    log_level = (
    #             logging.ERROR
    #             if error_info.severity in [ErrorSeverity.HIGH, ErrorSeverity.CRITICAL]
    #             else logging.WARNING
    #         )
            logger.log(
    #             log_level, f"Error occurred: {error_info.error_type} - {error_info.message}"
    #         )

    #     def get_error_statistics(self) -Dict[str, Any]):
    #         """Get error statistics from history."""
    #         if not self.error_history:
    #             return {"total_errors": 0}

    total_errors = len(self.error_history)
    #         severity_counts = {severity.value: 0 for severity in ErrorSeverity}
    #         category_counts = {category.value: 0 for category in ErrorCategory}
    recovery_success_count = 0

    #         for error_info in self.error_history:
    severity_counts[error_info.severity.value] + = 1
    category_counts[error_info.category.value] + = 1
    #             if error_info.recovery_successful:
    recovery_success_count + = 1

    #         return {
    #             "total_errors": total_errors,
    #             "severity_distribution": severity_counts,
    #             "category_distribution": category_counts,
                "recovery_success_rate": (
    #                 recovery_success_count / total_errors if total_errors 0 else 0
    #             ),
    #             "recent_errors"): [
    #                 {
    #                     "type": error.error_type,
    #                     "message": error.message,
    #                     "severity": error.severity.value,
                        "timestamp": error.context.timestamp.isoformat(),
    #                 }
    #                 for error in self.error_history[-10:]  # Last 10 errors
    #             ],
    #         }

    #     def clear_error_history(self) -None):
    #         """Clear error history."""
            self.error_history.clear()
            logger.info("Error history cleared")

    #     def get_errors_by_category(self, category: ErrorCategory) -List[ErrorInfo]):
    #         """Get errors filtered by category."""
    #         return [error for error in self.error_history if error.category == category]

    #     def get_errors_by_severity(self, severity: ErrorSeverity) -List[ErrorInfo]):
    #         """Get errors filtered by severity."""
    #         return [error for error in self.error_history if error.severity == severity]

    #     def __len__(self) -int):
    #         """Get number of errors in history."""
            return len(self.error_history)

    #     def __str__(self) -str):
    #         """String representation of error handler state."""
    return f"ErrorHandler(errors = {len(self.error_history)}, handlers={len(self.handlers)})"
