# Converted from Python to NoodleCore
# Original file: src

# """
# Mobile API Error Classes
# -----------------------

# Defines custom exception classes for the mobile API with proper error codes
# following the NoodleCore development standards.
# """

import logging
import typing.Any

logger = logging.getLogger(__name__)


class MobileAPIError(Exception):""Base exception class for mobile API errors."""

    #     def __init__(
    #         self,
    #         message: str,
    error_code: int = 1000,
    status_code: int = 500,
    details: Optional[Dict[str, Any]] = None
    #     ):""
    #         Initialize mobile API error.

    #         Args:
    #             message: Error message
                error_code: 4-digit error code (1000-9999)
    #             status_code: HTTP status code
    #             details: Additional error details
    #         """
            super().__init__(message)
    self.message = message
    self.error_code = error_code
    self.status_code = status_code
    self.details = details or {}

    #         # Log error
            logger.error(
                f"MobileAPIError: {message} (Code: {error_code}, Status: {status_code})"
    #         )

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert error to dictionary for API response."""
    #         return {
    #             "error": self.message,
    #             "error_code": self.error_code,
    #             "details": self.details
    #         }


class AuthenticationError(MobileAPIError)
    #     """Authentication related errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 1001,
    status_code = 401,
    details = details
    #         )


class AuthorizationError(MobileAPIError)
    #     """Authorization related errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 1002,
    status_code = 403,
    details = details
    #         )


class TokenExpiredError(MobileAPIError)
    #     """Token expiration errors."""

    #     def __init__(self, message: str = "Token has expired", details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 1003,
    status_code = 401,
    details = details
    #         )


class DeviceRegistrationError(MobileAPIError)
    #     """Device registration errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 1004,
    status_code = 400,
    details = details
    #         )


class InvalidRequestError(MobileAPIError)
    #     """Invalid request errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 2001,
    status_code = 400,
    details = details
    #         )


class ValidationError(MobileAPIError)
    #     """Input validation errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 2002,
    status_code = 400,
    details = details
    #         )


class ResourceNotFoundError(MobileAPIError)
    #     """Resource not found errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 2003,
    status_code = 404,
    details = details
    #         )


class ProjectNotFoundError(ResourceNotFoundError)
    #     """Project not found error."""

    #     def __init__(self, project_id: str):
            super().__init__(
    message = f"Project not found: {project_id}",
    details = {"project_id": project_id}
    #         )


class FileNotFoundError(ResourceNotFoundError)
    #     """File not found error."""

    #     def __init__(self, file_path: str):
            super().__init__(
    message = f"File not found: {file_path}",
    details = {"file_path": file_path}
    #         )


class NodeNotFoundError(ResourceNotFoundError)
    #     """Node not found error."""

    #     def __init__(self, node_id: str):
            super().__init__(
    message = f"Node not found: {node_id}",
    details = {"node_id": node_id}
    #         )


class ExecutionError(MobileAPIError)
    #     """Code execution errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 3001,
    status_code = 500,
    details = details
    #         )


class NetworkError(MobileAPIError)
    #     """Network communication errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 3002,
    status_code = 503,
    details = details
    #         )


class DatabaseError(MobileAPIError)
    #     """Database operation errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 3003,
    status_code = 500,
    details = details
    #         )


class TimeoutError(MobileAPIError)
    #     """Operation timeout errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 3004,
    status_code = 408,
    details = details
    #         )


class RateLimitError(MobileAPIError)
    #     """Rate limiting errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 3005,
    status_code = 429,
    details = details
    #         )


class SecurityError(MobileAPIError)
    #     """Security related errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 4001,
    status_code = 403,
    details = details
    #         )


class EncryptionError(SecurityError)
    #     """Encryption/decryption errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    details = details
    #         )
    self.error_code = 4002


class ConfigurationError(MobileAPIError)
    #     """Configuration related errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 5001,
    status_code = 500,
    details = details
    #         )


class ServiceUnavailableError(MobileAPIError)
    #     """Service unavailable errors."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(
    message = message,
    error_code = 5002,
    status_code = 503,
    details = details
    #         )