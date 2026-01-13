# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# CLI Exception Classes

# This module defines custom exception classes for the NoodleCore CLI system.
# All exceptions include 4-digit error codes as per NoodleCore standards.
# """

import logging
import typing.Dict,

logger = logging.getLogger(__name__)


class NoodleCliException(Exception)
    #     """Base exception class for NoodleCore CLI."""

    #     def __init__(self, message: str, error_code: int = 1001, details: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize the CLI exception.

    #         Args:
    #             message: Error message
                error_code: 4-digit error code (1001-9999)
    #             details: Additional error details
    #         """
            super().__init__(message)
    self.message = message
    self.error_code = error_code
    self.details = details or {}

    #         # Log the error
    logger.error(f"CLI Exception {error_code}: {message}", extra = self.details)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """
    #         Convert exception to dictionary for API responses.

    #         Returns:
    #             Dictionary representation of the exception
    #         """
    #         return {
    #             'error': True,
    #             'error_code': self.error_code,
    #             'message': self.message,
    #             'details': self.details
    #         }


class CommandNotFoundError(NoodleCliException)
    #     """Exception raised when a command is not found."""

    #     def __init__(self, command: str):
            super().__init__(
    #             f"Command not found: {command}",
    error_code = 1001,
    details = {'command': command}
    #         )


class InvalidArgumentError(NoodleCliException)
    #     """Exception raised for invalid command arguments."""

    #     def __init__(self, argument: str, value: Any, reason: str = ""):
    message = f"Invalid argument: {argument}={value}"
    #         if reason:
    message + = f" ({reason})"

            super().__init__(
    #             message,
    error_code = 1002,
    details = {'argument': argument, 'value': value, 'reason': reason}
    #         )


class MissingArgumentError(NoodleCliException)
    #     """Exception raised when required arguments are missing."""

    #     def __init__(self, argument: str):
            super().__init__(
    #             f"Missing required argument: {argument}",
    error_code = 1003,
    details = {'argument': argument}
    #         )


class ConfigurationError(NoodleCliException)
    #     """Exception raised for configuration-related errors."""

    #     def __init__(self, message: str, config_key: Optional[str] = None):
            super().__init__(
    #             f"Configuration error: {message}",
    error_code = 2001,
    #             details={'config_key': config_key} if config_key else {}
    #         )


class NetworkError(NoodleCliException)
    #     """Exception raised for network-related errors."""

    #     def __init__(self, message: str, url: Optional[str] = None, status_code: Optional[int] = None):
    details = {}
    #         if url:
    details['url'] = url
    #         if status_code:
    details['status_code'] = status_code

            super().__init__(
    #             f"Network error: {message}",
    error_code = 3001,
    details = details
    #         )


class AuthenticationError(NoodleCliException)
    #     """Exception raised for authentication failures."""

    #     def __init__(self, message: str = "Authentication failed"):
            super().__init__(
    #             message,
    error_code = 3002,
    details = {}
    #         )


class PermissionError(NoodleCliException)
    #     """Exception raised for permission-related errors."""

    #     def __init__(self, resource: str, action: str):
            super().__init__(
    #             f"Permission denied: {action} on {resource}",
    error_code = 3003,
    details = {'resource': resource, 'action': action}
    #         )


class ValidationError(NoodleCliException)
    #     """Exception raised for validation errors."""

    #     def __init__(self, message: str, file_path: Optional[str] = None, line_number: Optional[int] = None):
    details = {}
    #         if file_path:
    details['file_path'] = file_path
    #         if line_number:
    details['line_number'] = line_number

            super().__init__(
    #             f"Validation error: {message}",
    error_code = 4001,
    details = details
    #         )


class SandboxError(NoodleCliException)
    #     """Exception raised for sandbox execution errors."""

    #     def __init__(self, message: str, exit_code: Optional[int] = None):
    details = {}
    #         if exit_code is not None:
    details['exit_code'] = exit_code

            super().__init__(
    #             f"Sandbox error: {message}",
    error_code = 4002,
    details = details
    #         )


class TimeoutError(NoodleCliException)
    #     """Exception raised when operations timeout."""

    #     def __init__(self, operation: str, timeout_seconds: int):
            super().__init__(
    #             f"Operation timeout: {operation} exceeded {timeout_seconds} seconds",
    error_code = 4003,
    details = {'operation': operation, 'timeout_seconds': timeout_seconds}
    #         )


class ResourceLimitError(NoodleCliException)
    #     """Exception raised when resource limits are exceeded."""

    #     def __init__(self, resource_type: str, limit: str, current_usage: str):
            super().__init__(
                f"Resource limit exceeded: {resource_type} (limit: {limit}, current: {current_usage})",
    error_code = 4004,
    details = {
    #                 'resource_type': resource_type,
    #                 'limit': limit,
    #                 'current_usage': current_usage
    #             }
    #         )


class InternalError(NoodleCliException)
    #     """Exception raised for internal system errors."""

    #     def __init__(self, message: str, component: Optional[str] = None):
    details = {}
    #         if component:
    details['component'] = component

            super().__init__(
    #             f"Internal error: {message}",
    error_code = 5001,
    details = details
    #         )


class DatabaseError(NoodleCliException)
    #     """Exception raised for database-related errors."""

    #     def __init__(self, message: str, query: Optional[str] = None):
    details = {}
    #         if query:
    details['query'] = query

            super().__init__(
    #             f"Database error: {message}",
    error_code = 5002,
    details = details
    #         )


class FileSystemError(NoodleCliException)
    #     """Exception raised for file system-related errors."""

    #     def __init__(self, message: str, file_path: Optional[str] = None, operation: Optional[str] = None):
    details = {}
    #         if file_path:
    details['file_path'] = file_path
    #         if operation:
    details['operation'] = operation

            super().__init__(
    #             f"File system error: {message}",
    error_code = 5003,
    details = details
    #         )


def format_error_response(exception: Exception, request_id: Optional[str] = None) -> Dict[str, Any]:
#     """
#     Format an exception for API response.

#     Args:
#         exception: Exception to format
#         request_id: Request ID for tracking

#     Returns:
#         Formatted error response dictionary
#     """
response = {
#         'requestId': request_id,
#         'success': False
#     }

#     if isinstance(exception, NoodleCliException):
        response.update(exception.to_dict())
#     else:
        response.update({
#             'error': True,
#             'error_code': 5000,
            'message': str(exception),
            'details': {'exception_type': type(exception).__name__}
#         })

#     return response