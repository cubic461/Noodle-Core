# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Centralized Error Definitions for Noodle Runtime

# This module provides centralized error class definitions to avoid circular imports
# and ensure consistent error handling across the entire Noodle runtime system.
# """

import typing.Any,


class NoodleError(Exception)
    #     """Base exception class for all Noodle runtime errors."""

    #     def __init__(
    self, message: str, error_code: str = None, details: Dict[str, Any] = None
    #     ):
    #         """Initialize Noodle error."""
            super().__init__(message)
    self.message = message
    self.error_code = error_code
    self.details = details or {}

    #     def __str__(self):
    #         """String representation."""
    #         if self.error_code:
    #             return f"[{self.error_code}] {self.message}"
    #         return self.message


class NBCRuntimeError(NoodleError)
    #     """NBC runtime error."""

    #     pass


class SerializationError(NoodleError)
    #     """Error during serialization operations."""

    #     def __init__(
    #         self,
    #         message: str,
    error_code: str = "SERIALIZATION_ERROR",
    details: Dict[str, Any] = None,
    #     ):
    #         """Initialize serialization error."""
            super().__init__(message, error_code, details)


class DeserializationError(SerializationError)
    #     """Error during deserialization operations."""

    #     def __init__(
    #         self,
    #         message: str,
    error_code: str = "DESERIALIZATION_ERROR",
    details: Dict[str, Any] = None,
    #     ):
    #         """Initialize deserialization error."""
            super().__init__(message, error_code, details)


class DatabaseError(NoodleError)
    #     """Database operation error."""

    #     pass


class TransactionError(DatabaseError)
    #     """Database transaction error."""

    #     pass


class ConfigurationError(NoodleError)
    #     """Configuration error."""

    #     pass


class DistributedError(NoodleError)
    #     """Distributed system error."""

    #     pass


class MatrixError(NoodleError)
    #     """Matrix operation error."""

    #     pass


class MathematicalObjectMapperError(NoodleError)
    #     """Mathematical object mapper error."""

    #     pass


class InvalidMathematicalObjectError(MathematicalObjectMapperError)
    #     """Invalid mathematical object error."""

    #     pass


# Error registry for easy access
ERROR_CLASSES = {
#     "NoodleError": NoodleError,
#     "NBCRuntimeError": NBCRuntimeError,
#     "SerializationError": SerializationError,
#     "DeserializationError": DeserializationError,
#     "DatabaseError": DatabaseError,
#     "TransactionError": TransactionError,
#     "ConfigurationError": ConfigurationError,
#     "DistributedError": DistributedError,
#     "MatrixError": MatrixError,
#     "MathematicalObjectMapperError": MathematicalObjectMapperError,
#     "InvalidMathematicalObjectError": InvalidMathematicalObjectError,
# }
