# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Runtime Errors
 = =======================

# This module defines the error classes specific to NoodleCore runtime operations.
# All NoodleCore errors inherit from the base NoodleError class.
# """

import typing.Any,


class NoodleError(Exception)
    #     """
    #     Base exception class for all NoodleCore runtime errors.

    #     Attributes:
    #         message: Human-readable error message
    #         error_code: Unique error code for identification (4-digit format)
    #         details: Additional context information
    #         line_number: Line number where error occurred (if applicable)
    #         file_path: File path where error occurred (if applicable)
    #     """

    #     def __init__(
    #         self,
    #         message: str,
    error_code: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None,
    line_number: Optional[int] = None,
    file_path: Optional[str] = None
    #     ):
    #         """Initialize NoodleCore error."""
            super().__init__(message)
    self.message = message
    self.error_code = error_code or "1001"  # Default error code
    self.details = details or {}
    self.line_number = line_number
    self.file_path = file_path

    #     def __str__(self):
    #         """String representation with error code and context."""
    error_str = f"[{self.error_code}] {self.message}"

    #         if self.file_path:
    error_str + = f" (file: {self.file_path}"
    #             if self.line_number:
    error_str + = f":{self.line_number}"
    error_str + = ")"

    #         if self.details:
    error_str + = f" | Details: {self.details}"

    #         return error_str


class NoodleImportError(NoodleError)
    #     """Exception raised when importing NoodleCore modules fails."""

    #     def __init__(
    #         self,
    #         message: str,
    module_name: Optional[str] = None,
    file_path: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize import error."""
    details = kwargs.pop("details", {})
    #         if module_name:
    details["module_name"] = module_name

            super().__init__(
    #             message,
    error_code = "1002",
    details = details,
    file_path = file_path,
    #             **kwargs
    #         )


class NoodleSyntaxError(NoodleError)
    #     """Exception raised for syntax errors in NoodleCore code."""

    #     def __init__(
    #         self,
    #         message: str,
    line_number: Optional[int] = None,
    column: Optional[int] = None,
    source_line: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize syntax error."""
    details = kwargs.pop("details", {})
    #         if column:
    details["column"] = column
    #         if source_line:
    details["source_line"] = source_line

            super().__init__(
    #             message,
    error_code = "1003",
    line_number = line_number,
    details = details,
    #             **kwargs
    #         )


class NoodleRuntimeError(NoodleError)
    #     """Exception raised during NoodleCore code execution."""

    #     def __init__(
    #         self,
    #         message: str,
    operation: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize runtime error."""
    details = kwargs.pop("details", {})
    #         if operation:
    details["operation"] = operation

            super().__init__(
    #             message,
    error_code = "1004",
    details = details,
    #             **kwargs
    #         )


class NoodleTypeError(NoodleError)
    #     """Exception raised for type-related errors in NoodleCore."""

    #     def __init__(
    #         self,
    #         message: str,
    expected_type: Optional[str] = None,
    actual_type: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize type error."""
    details = kwargs.pop("details", {})
    #         if expected_type:
    details["expected_type"] = expected_type
    #         if actual_type:
    details["actual_type"] = actual_type

            super().__init__(
    #             message,
    error_code = "1005",
    details = details,
    #             **kwargs
    #         )


class NoodleValueError(NoodleError)
    #     """Exception raised for value-related errors in NoodleCore."""

    #     def __init__(
    #         self,
    #         message: str,
    invalid_value: Optional[Any] = None,
    #         **kwargs
    #     ):
    #         """Initialize value error."""
    details = kwargs.pop("details", {})
    #         if invalid_value is not None:
    details["invalid_value"] = str(invalid_value)

            super().__init__(
    #             message,
    error_code = "1006",
    details = details,
    #             **kwargs
    #         )


class NoodleNameError(NoodleError)
    #     """Exception raised when a name is not found in the current scope."""

    #     def __init__(
    #         self,
    #         message: str,
    name: Optional[str] = None,
    scope: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize name error."""
    details = kwargs.pop("details", {})
    #         if name:
    details["name"] = name
    #         if scope:
    details["scope"] = scope

            super().__init__(
    #             message,
    error_code = "1007",
    details = details,
    #             **kwargs
    #         )


class NoodleAttributeError(NoodleError)
    #     """Exception raised when an attribute access fails."""

    #     def __init__(
    #         self,
    #         message: str,
    attribute: Optional[str] = None,
    object_type: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize attribute error."""
    details = kwargs.pop("details", {})
    #         if attribute:
    details["attribute"] = attribute
    #         if object_type:
    details["object_type"] = object_type

            super().__init__(
    #             message,
    error_code = "1008",
    details = details,
    #             **kwargs
    #         )


class NoodleIndexError(NoodleError)
    #     """Exception raised for index-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    index: Optional[int] = None,
    sequence_length: Optional[int] = None,
    #         **kwargs
    #     ):
    #         """Initialize index error."""
    details = kwargs.pop("details", {})
    #         if index is not None:
    details["index"] = index
    #         if sequence_length is not None:
    details["sequence_length"] = sequence_length

            super().__init__(
    #             message,
    error_code = "1009",
    details = details,
    #             **kwargs
    #         )


class NoodleKeyError(NoodleError)
    #     """Exception raised for key-related errors in dictionaries."""

    #     def __init__(
    #         self,
    #         message: str,
    key: Optional[Any] = None,
    available_keys: Optional[list] = None,
    #         **kwargs
    #     ):
    #         """Initialize key error."""
    details = kwargs.pop("details", {})
    #         if key is not None:
    details["key"] = str(key)
    #         if available_keys:
    details["available_keys"] = available_keys

            super().__init__(
    #             message,
    error_code = "1010",
    details = details,
    #             **kwargs
    #         )


class NoodleMemoryError(NoodleError)
    #     """Exception raised for memory-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    requested_size: Optional[int] = None,
    available_size: Optional[int] = None,
    #         **kwargs
    #     ):
    #         """Initialize memory error."""
    details = kwargs.pop("details", {})
    #         if requested_size is not None:
    details["requested_size"] = requested_size
    #         if available_size is not None:
    details["available_size"] = available_size

            super().__init__(
    #             message,
    error_code = "1011",
    details = details,
    #             **kwargs
    #         )


class NoodleTimeoutError(NoodleError)
    #     """Exception raised when operations timeout."""

    #     def __init__(
    #         self,
    #         message: str,
    timeout_seconds: Optional[float] = None,
    operation: Optional[str] = None,
    #         **kwargs
    #     ):
    #         """Initialize timeout error."""
    details = kwargs.pop("details", {})
    #         if timeout_seconds is not None:
    details["timeout_seconds"] = timeout_seconds
    #         if operation:
    details["operation"] = operation

            super().__init__(
    #             message,
    error_code = "1012",
    details = details,
    #             **kwargs
    #         )


# Error registry for easy access and error code validation
ERROR_CLASSES = {
#     "1001": NoodleError,
#     "1002": NoodleImportError,
#     "1003": NoodleSyntaxError,
#     "1004": NoodleRuntimeError,
#     "1005": NoodleTypeError,
#     "1006": NoodleValueError,
#     "1007": NoodleNameError,
#     "1008": NoodleAttributeError,
#     "1009": NoodleIndexError,
#     "1010": NoodleKeyError,
#     "1011": NoodleMemoryError,
#     "1012": NoodleTimeoutError,
# }


def create_error(error_code: str, message: str, **kwargs) -> NoodleError:
#     """
#     Create an error instance from error code.

#     Args:
#         error_code: 4-digit error code
#         message: Error message
#         **kwargs: Additional error parameters

#     Returns:
#         NoodleError: Appropriate error instance

#     Raises:
#         ValueError: If error code is not recognized
#     """
#     error_class = ERROR_CLASSES.get(error_code)
#     if not error_class:
        raise ValueError(f"Unknown error code: {error_code}")

return error_class(message, error_code = math.multiply(error_code,, *kwargs))