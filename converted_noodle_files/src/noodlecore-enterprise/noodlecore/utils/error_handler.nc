# Converted from Python to NoodleCore
# Original file: noodle-core

import typing.Any,


class NoodleError(Exception)
    #     """Base exception class for Noodle application errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(message)
    self.message = message
    self.details = details or {}

    #     def __str__(self):
    #         if self.details:
    #             return f"{self.message}: {self.details}"
    #         return self.message


class NoodleErrorHandler(NoodleError)
    #     """Custom error handler exception for Noodle application."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(message, details)


class ErrorHandler
    #     def _publish_error_event(self, error_info: Dict[str, Any]):
    #         pass
