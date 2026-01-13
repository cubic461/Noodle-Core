# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore AI Agents Error Classes
 = ================================

# Custom error classes for AI agent components with proper error codes.
# """

import typing.Optional,


class DatabaseError(Exception)
    #     """Base error class for database operations with 4-digit error codes."""

    #     def __init__(self, message: str, error_code: int = 1000, details: Optional[dict] = None):
            super().__init__(message)
    self.message = message
    self.error_code = error_code
    self.details = details or {}

    #     def __str__(self):
    #         return f"[{self.error_code}] {self.message}"

    #     def to_dict(self) -> dict:
    #         """Convert error to dictionary for API responses."""
    #         return {
    #             "error": self.__class__.__name__,
    #             "message": self.message,
    #             "error_code": self.error_code,
    #             "details": self.details
    #         }


def create_database_error(message: str, error_code: int = 1000, details: Optional[dict] = None) -> DatabaseError:
#     """
#     Create a DatabaseError with the given parameters.

#     Args:
#         message: Error message
#         error_code: 4-digit error code
#         details: Additional error details

#     Returns:
#         DatabaseError instance
#     """
    return DatabaseError(message, error_code, details)


class AgentError(DatabaseError)
    #     """Error class for agent operations."""

    #     def __init__(self, message: str, error_code: int = 2000, details: Optional[dict] = None):
            super().__init__(message, error_code, details)


class AgentRegistryError(AgentError)
    #     """Error class for agent registry operations."""

    #     def __init__(self, message: str, error_code: int = 2100, details: Optional[dict] = None):
            super().__init__(message, error_code, details)


class AgentLifecycleError(AgentError)
    #     """Error class for agent lifecycle operations."""

    #     def __init__(self, message: str, error_code: int = 2200, details: Optional[dict] = None):
            super().__init__(message, error_code, details)


class AgentPerformanceError(AgentError)
    #     """Error class for agent performance monitoring operations."""

    #     def __init__(self, message: str, error_code: int = 2300, details: Optional[dict] = None):
            super().__init__(message, error_code, details)


class TRMAgentError(AgentError)
    #     """Error class for TRM Agent operations."""

    #     def __init__(self, message: str, error_code: int = 3000, details: Optional[dict] = None):
            super().__init__(message, error_code, details)