# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Error Handler for NBC Runtime
# -----------------------------
# Handles errors in the NBC runtime system.
# """

import logging
import typing.Dict,


class ErrorHandler
    #     """Central error handler for NBC runtime."""

    #     def __init__(self):
    #         """Initialize the error handler."""
    self.logger = logging.getLogger(__name__)
    self.error_count = 0
    self.error_history = []
    self.max_history = 100

    #         # Configure logging
            logging.basicConfig(
    level = logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #         )

    #     def handle_error(self, error: Exception, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Handle an error with context.

    #         Args:
    #             error: The exception that occurred
    #             context: Additional context about the error

    #         Returns:
    #             Error information dictionary
    #         """
    error_info = {
                "error_type": type(error).__name__,
                "error_message": str(error),
    #             "error_count": self.error_count + 1,
    #             "timestamp": None,  # Will be set by the caller
    #             "context": context or {}
    #         }

    #         # Log the error
            self.logger.error(f"Error occurred: {error_info}")

    #         # Update error count and history
    self.error_count + = 1
            self.error_history.append(error_info)

    #         # Keep only recent errors
    #         if len(self.error_history) > self.max_history:
    self.error_history = math.subtract(self.error_history[, self.max_history:])

    #         return error_info

    #     def get_error_count(self) -> int:
    #         """Get the total number of errors handled."""
    #         return self.error_count

    #     def get_error_history(self) -> List[Dict[str, Any]]:
    #         """Get the error history."""
            return self.error_history.copy()

    #     def clear_error_history(self):
    #         """Clear the error history."""
    self.error_history = []
    self.error_count = 0

    #     def log_warning(self, message: str, context: Optional[Dict[str, Any]] = None):
    #         """Log a warning message."""
    warning_info = {
    #             "type": "warning",
    #             "message": message,
    #             "context": context or {}
    #         }
            self.logger.warning(message)
            self.error_history.append(warning_info)

    #     def log_info(self, message: str, context: Optional[Dict[str, Any]] = None):
    #         """Log an info message."""
    info_info = {
    #             "type": "info",
    #             "message": message,
    #             "context": context or {}
    #         }
            self.logger.info(message)
            self.error_history.append(info_info)
