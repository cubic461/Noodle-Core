# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Error Handling Module

# This module provides standardized error handling with 4-digit error codes
# for the NoodleCore system, following the Noodle AI Coding Agent Development Standards.
# """

import logging
import typing.Any,


class NoodleCoreError(Exception)
    #     """
    #     Base exception class for NoodleCore errors.

    #     All NoodleCore exceptions should inherit from this class and
    #     include a 4-digit error code as specified in the development standards.
    #     """

    #     def __init__(self, message: str, error_code: int, context: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize the NoodleCoreError.

    #         Args:
    #             message: Error message describing the issue
                error_code: 4-digit error code (1001-9999)
    #             context: Optional context information about the error
    #         """
            super().__init__(message)
    self.message = message
    self.error_code = error_code
    self.context = context or {}

    #         # Log the error
    logger = logging.getLogger(__name__)
            logger.error(f"{message} (Error: {error_code})")

    #     def __str__(self) -> str:
    #         """String representation of the error."""
            return f"{self.message} (Error: {self.error_code})"

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert error to dictionary for API responses."""
    #         return {
    #             "error": self.message,
    #             "error_code": self.error_code,
    #             "context": self.context
    #         }


class ConfigurationError(NoodleCoreError)
    #     """Error raised for configuration-related issues."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 1001, context)


class InitializationError(NoodleCoreError)
    #     """Error raised when system initialization fails."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 1002, context)


class RuntimeError(NoodleCoreError)
    #     """Error raised during runtime execution."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 1003, context)


class NetworkError(NoodleCoreError)
    #     """Error raised for network-related issues."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 2001, context)


class ConnectionError(NetworkError)
    #     """Error raised for connection-related issues."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 2002, context)


class MessageError(NetworkError)
    #     """Error raised for message-related issues."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 2003, context)


class ValidationError(NoodleCoreError)
    #     """Error raised for validation failures."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 3001, context)


class AuthenticationError(NoodleCoreError)
    #     """Error raised for authentication failures."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 4001, context)


class AuthorizationError(NoodleCoreError)
    #     """Error raised for authorization failures."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 4002, context)


class DatabaseError(NoodleCoreError)
    #     """Error raised for database-related issues."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 5001, context)


class TimeoutError(NoodleCoreError)
    #     """Error raised when operations timeout."""

    #     def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
            super().__init__(message, 5002, context)


class ErrorHandler
    #     """
    #     Centralized error handler for NoodleCore components.

    #     This class provides a consistent way to handle errors across
    #     different components of the NoodleCore system.
    #     """

    #     def __init__(self, component_name: str):
    #         """
    #         Initialize the ErrorHandler.

    #         Args:
    #             component_name: Name of the component using this handler
    #         """
    self.component_name = component_name
    self.logger = logging.getLogger(f"{__name__}.{component_name}")
    self.custom_handlers = {}

    #     def handle_error(self, error: Exception, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Handle an error and return a standardized error response.

    #         Args:
    #             error: The exception to handle
    #             context: Optional context information about the error

    #         Returns:
    #             Dictionary containing standardized error information
    #         """
    #         # Create context if not provided
    error_context = context or {}
    error_context["component"] = self.component_name

    #         # Check if it's already a NoodleCoreError
    #         if isinstance(error, NoodleCoreError):
    #             # Add additional context
                error.context.update(error_context)
                self.logger.error(f"{error.message} (Error: {error.error_code})")
                return error.to_dict()

    #         # Convert to appropriate NoodleCoreError based on exception type
    #         if isinstance(error, ConnectionRefusedError):
    noodle_error = ConnectionError(str(error), error_context)
    #         elif isinstance(error, TimeoutError):
    noodle_error = TimeoutError(str(error), error_context)
    #         elif isinstance(error, ValueError):
    noodle_error = ValidationError(str(error), error_context)
    #         elif isinstance(error, PermissionError):
    noodle_error = AuthorizationError(str(error), error_context)
    #         else:
    #             # Default to RuntimeError for unknown exceptions
    noodle_error = RuntimeError(str(error), error_context)

    #         # Check for custom handlers
    error_type = type(noodle_error)
    #         if error_type in self.custom_handlers:
    #             try:
                    self.custom_handlers[error_type](noodle_error, error_context)
    #             except Exception as handler_error:
                    self.logger.error(f"Error in custom error handler: {handler_error}")

            return noodle_error.to_dict()

    #     def register_custom_handler(self, error_type: type, handler: callable):
    #         """
    #         Register a custom error handler for a specific error type.

    #         Args:
    #             error_type: The error type to handle
    #             handler: Function that takes an error and context
    #         """
    self.custom_handlers[error_type] = handler
    #         self.logger.info(f"Registered custom handler for {error_type.__name__}")

    #     def create_error_response(self, message: str, error_code: int,
    context: Optional[Dict[str, Any]] = math.subtract(None), > Dict[str, Any]:)
    #         """
    #         Create a standardized error response.

    #         Args:
    #             message: Error message
    #             error_code: 4-digit error code
    #             context: Optional context information

    #         Returns:
    #             Dictionary containing standardized error information
    #         """
    error = NoodleCoreError(message, error_code, context)
            return self.handle_error(error, context)