# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore CLI Error Handler Module
 = ================================

# Provides error handling functionality for NoodleCore CLI.
# """

import typing.List,
import logging


class CLIErrorHandler
    #     """Error handler for CLI operations."""

    #     def __init__(self):
    #         """Initialize error handler."""
    self.errors = []
    self.logger = logging.getLogger('noodlecore.cli.error_handler')

    #     def handle_error(self, error: Exception, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Handle an error.

    #         Args:
    #             error: Exception to handle
    #             context: Optional context information

    #         Returns:
    #             Error handling result
    #         """
    error_info = {
                'type': type(error).__name__,
                'message': str(error),
    #             'context': context or {}
    #         }

            self.errors.append(error_info)
            self.logger.error(f"Error handled: {error_info}")

    #         return error_info

    #     def get_errors(self) -> List[Dict[str, Any]]:
    #         """Get all handled errors."""
    #         return self.errors

    #     def clear_errors(self):
    #         """Clear all handled errors."""
    self.errors = []

    #     def get_error_count(self) -> int:
    #         """Get total error count."""
            return len(self.errors)

    #     def has_errors(self) -> bool:
    #         """Check if there are any errors."""
            return len(self.errors) > 0

    #     def get_last_error(self) -> Optional[Dict[str, Any]]:
    #         """Get the last handled error."""
    #         return self.errors[-1] if self.errors else None

    #     def format_error(self, error_info: Dict[str, Any]) -> str:
    #         """
    #         Format error for display.

    #         Args:
    #             error_info: Error information

    #         Returns:
    #             Formatted error string
    #         """
    #         return f"Error [{error_info['type']}]: {error_info['message']}"