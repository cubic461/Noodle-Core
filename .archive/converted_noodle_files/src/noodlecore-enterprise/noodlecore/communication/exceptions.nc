# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Exception classes for NoodleCore communication.

# This module defines the exception classes used for error handling in the
# communication system, with 4-digit error codes as required by the standards.
# """

import typing.Optional,


class CommunicationError(Exception)
    #     """
    #     Base exception for communication errors.

    #     Attributes:
    #         error_code: 4-digit error code
    #         message: Error message
    #         details: Additional error details
    #     """

    #     def __init__(self, error_code: int, message: str, details: Optional[Dict[str, Any]] = None):
    self.error_code = error_code
    self.message = message
    self.details = details or {}
            super().__init__(f"[{error_code}] {message}")

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert exception to dictionary."""
    #         return {
    #             "error_code": self.error_code,
    #             "message": self.message,
    #             "details": self.details,
    #         }


class MessageValidationError(CommunicationError)
    #     """Exception raised when message validation fails."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1001, message, details)


class MessageTimeoutError(CommunicationError)
    #     """Exception raised when a message times out."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1002, message, details)


class ComponentNotAvailableError(CommunicationError)
    #     """Exception raised when a destination component is not available."""

    #     def __init__(self, component_name: str, details: Optional[Dict[str, Any]] = None):
    message = f"Component '{component_name}' is not available"
            super().__init__(1003, message, details)


class ProtocolError(CommunicationError)
    #     """Exception raised when there's a protocol violation."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1004, message, details)


class MessageDeliveryError(CommunicationError)
    #     """Exception raised when message delivery fails."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1005, message, details)


class ResponseError(CommunicationError)
    #     """Exception raised when a response contains an error."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1006, message, details)


class ConnectionError(CommunicationError)
    #     """Exception raised when there's a connection issue between components."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1007, message, details)


class SerializationError(CommunicationError)
    #     """Exception raised when message serialization/deserialization fails."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1008, message, details)


class AuthenticationError(CommunicationError)
    #     """Exception raised when authentication fails."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1009, message, details)


class AuthorizationError(CommunicationError)
    #     """Exception raised when authorization fails."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1010, message, details)


class RateLimitError(CommunicationError)
    #     """Exception raised when rate limit is exceeded."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1011, message, details)


class ResourceExhaustionError(CommunicationError)
    #     """Exception raised when system resources are exhausted."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1012, message, details)


class CommunicationFlowError(CommunicationError)
    #     """Exception raised when there's an error in the communication flow."""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(1013, message, details)