# Converted from Python to NoodleCore
# Original file: src

# """
# Validation Exceptions for NoodleCore
# -----------------------------------
# This module defines exception classes for the NoodleCore validator with 4-digit error codes
# as required by the Noodle AI Coding Agent Development Standards.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import typing.Optional


class ValidationError(Exception):""
    #     Base exception for all validation errors

    #     All validation exceptions inherit from this class and include a 4-digit error code
    #     as required by the Noodle AI Coding Agent Development Standards.
    #     """

    #     def __init__(self, message: str, code: int = 1001, details: Optional[Dict[str, Any]] = None):""
    #         Initialize the validation error

    #         Args:
    #             message: Error message
                code: 4-digit error code (1001-9999)
    #             details: Additional error details
    #         """
    self.message = message
    self.code = code
    self.details = details or {}
            super().__init__(self.message)

    #     def __str__(self):
    #         return f"ValidationError[{self.code}]: {self.message}"

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert exception to dictionary"""
    #         return {
    #             "error": "ValidationError",
    #             "code": self.code,
    #             "message": self.message,
    #             "details": self.details
    #         }


class ValidatorInitializationError(ValidationError)
    #     """Exception raised when validator initialization fails"""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(message, 1001, details)


class FileAccessError(ValidationError)
    #     """Exception raised when file access fails"""

    #     def __init__(self, file_path: str, reason: str, details: Optional[Dict[str, Any]] = None):
    message = f"Failed to access file '{file_path}': {reason}"
    #         if details is None:
    details = {"file_path": file_path, "reason": reason}
    #         else:
                details.update({"file_path": file_path, "reason": reason})
            super().__init__(message, 1002, details)


class ParsingError(ValidationError)
    #     """Exception raised when code parsing fails"""

    #     def __init__(self, message: str, line_number: Optional[int] = None,
    column: Optional[int] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if line_number is not None:
    details["line_number"] = line_number
    #         if column is not None:
    details["column"] = column

            super().__init__(message, 1003, details)


class ASTVerificationError(ValidationError)
    #     """Exception raised when AST verification fails"""

    #     def __init__(self, message: str, node_type: Optional[str] = None,
    line_number: Optional[int] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if node_type is not None:
    details["node_type"] = node_type
    #         if line_number is not None:
    details["line_number"] = line_number

            super().__init__(message, 1004, details)


class ForeignSyntaxError(ValidationError)
    #     """Exception raised when foreign syntax is detected"""

    #     def __init__(self, message: str, syntax_type: Optional[str] = None,
    line_number: Optional[int] = None, column: Optional[int] = None,
    details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if syntax_type is not None:
    details["syntax_type"] = syntax_type
    #         if line_number is not None:
    details["line_number"] = line_number
    #         if column is not None:
    details["column"] = column

            super().__init__(message, 1005, details)


class AutoCorrectionError(ValidationError)
    #     """Exception raised when auto-correction fails"""

    #     def __init__(self, message: str, correction_type: Optional[str] = None,
    line_number: Optional[int] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if correction_type is not None:
    details["correction_type"] = correction_type
    #         if line_number is not None:
    details["line_number"] = line_number

            super().__init__(message, 1006, details)


class ReportGenerationError(ValidationError)
    #     """Exception raised when report generation fails"""

    #     def __init__(self, message: str, report_format: Optional[str] = None,
    file_path: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if report_format is not None:
    details["report_format"] = report_format
    #         if file_path is not None:
    details["file_path"] = file_path

            super().__init__(message, 1007, details)


class ConfigurationError(ValidationError)
    #     """Exception raised when validator configuration is invalid"""

    #     def __init__(self, message: str, config_key: Optional[str] = None,
    config_value: Optional[Any] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if config_key is not None:
    details["config_key"] = config_key
    #         if config_value is not None:
    details["config_value"] = config_value

            super().__init__(message, 1008, details)


class TimeoutError(ValidationError)
    #     """Exception raised when validation times out"""

    #     def __init__(self, message: str, timeout_ms: Optional[int] = None,
    operation: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if timeout_ms is not None:
    details["timeout_ms"] = timeout_ms
    #         if operation is not None:
    details["operation"] = operation

            super().__init__(message, 1009, details)


class MemoryLimitError(ValidationError)
    #     """Exception raised when validation exceeds memory limits"""

    #     def __init__(self, message: str, memory_usage_mb: Optional[float] = None,
    memory_limit_mb: Optional[float] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if memory_usage_mb is not None:
    details["memory_usage_mb"] = memory_usage_mb
    #         if memory_limit_mb is not None:
    details["memory_limit_mb"] = memory_limit_mb

            super().__init__(message, 1010, details)


class CircularReferenceError(ValidationError)
    #     """Exception raised when circular references are detected"""

    #     def __init__(self, message: str, reference_chain: Optional[List[str]] = None,
    details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if reference_chain is not None:
    details["reference_chain"] = reference_chain

            super().__init__(message, 1011, details)


class TypeMismatchError(ValidationError)
    #     """Exception raised when type mismatches are detected"""

    #     def __init__(self, message: str, expected_type: Optional[str] = None,
    actual_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if expected_type is not None:
    details["expected_type"] = expected_type
    #         if actual_type is not None:
    details["actual_type"] = actual_type

            super().__init__(message, 1012, details)


class InvalidNodeStructureError(ValidationError)
    #     """Exception raised when AST node structure is invalid"""

    #     def __init__(self, message: str, node_type: Optional[str] = None,
    expected_structure: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if node_type is not None:
    details["node_type"] = node_type
    #         if expected_structure is not None:
    details["expected_structure"] = expected_structure

            super().__init__(message, 1013, details)


class InvalidOperatorError(ValidationError)
    #     """Exception raised when invalid operators are used"""

    #     def __init__(self, message: str, operator: Optional[str] = None,
    context: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if operator is not None:
    details["operator"] = operator
    #         if context is not None:
    details["context"] = context

            super().__init__(message, 1014, details)


class InvalidIdentifierError(ValidationError)
    #     """Exception raised when invalid identifiers are used"""

    #     def __init__(self, message: str, identifier: Optional[str] = None,
    identifier_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if identifier is not None:
    details["identifier"] = identifier
    #         if identifier_type is not None:
    details["identifier_type"] = identifier_type

            super().__init__(message, 1015, details)


class InvalidControlFlowError(ValidationError)
    #     """Exception raised when invalid control flow is detected"""

    #     def __init__(self, message: str, control_type: Optional[str] = None,
    line_number: Optional[int] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if control_type is not None:
    details["control_type"] = control_type
    #         if line_number is not None:
    details["line_number"] = line_number

            super().__init__(message, 1016, details)


class InvalidImportError(ValidationError)
    #     """Exception raised when invalid imports are detected"""

    #     def __init__(self, message: str, import_statement: Optional[str] = None,
    module_name: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if import_statement is not None:
    details["import_statement"] = import_statement
    #         if module_name is not None:
    details["module_name"] = module_name

            super().__init__(message, 1017, details)


class InvalidFunctionDefinitionError(ValidationError)
    #     """Exception raised when invalid function definitions are detected"""

    #     def __init__(self, message: str, function_name: Optional[str] = None,
    issue_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if function_name is not None:
    details["function_name"] = function_name
    #         if issue_type is not None:
    details["issue_type"] = issue_type

            super().__init__(message, 1018, details)


class InvalidClassDefinitionError(ValidationError)
    #     """Exception raised when invalid class definitions are detected"""

    #     def __init__(self, message: str, class_name: Optional[str] = None,
    issue_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if class_name is not None:
    details["class_name"] = class_name
    #         if issue_type is not None:
    details["issue_type"] = issue_type

            super().__init__(message, 1019, details)


class InvalidVariableUsageError(ValidationError)
    #     """Exception raised when invalid variable usage is detected"""

    #     def __init__(self, message: str, variable_name: Optional[str] = None,
    usage_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if variable_name is not None:
    details["variable_name"] = variable_name
    #         if usage_type is not None:
    details["usage_type"] = usage_type

            super().__init__(message, 1020, details)


class InvalidAsyncUsageError(ValidationError)
    #     """Exception raised when invalid async usage is detected"""

    #     def __init__(self, message: str, async_type: Optional[str] = None,
    line_number: Optional[int] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if async_type is not None:
    details["async_type"] = async_type
    #         if line_number is not None:
    details["line_number"] = line_number

            super().__init__(message, 1021, details)


class InvalidExceptionHandlingError(ValidationError)
    #     """Exception raised when invalid exception handling is detected"""

    #     def __init__(self, message: str, exception_type: Optional[str] = None,
    handling_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if exception_type is not None:
    details["exception_type"] = exception_type
    #         if handling_type is not None:
    details["handling_type"] = handling_type

            super().__init__(message, 1022, details)


class InvalidDecoratorError(ValidationError)
    #     """Exception raised when invalid decorator usage is detected"""

    #     def __init__(self, message: str, decorator_name: Optional[str] = None,
    target_type: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if decorator_name is not None:
    details["decorator_name"] = decorator_name
    #         if target_type is not None:
    details["target_type"] = target_type

            super().__init__(message, 1023, details)


class UnreachableCodeError(ValidationError)
    #     """Exception raised when unreachable code is detected"""

    #     def __init__(self, message: str, line_number: Optional[int] = None,
    code_snippet: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if line_number is not None:
    details["line_number"] = line_number
    #         if code_snippet is not None:
    details["code_snippet"] = code_snippet

            super().__init__(message, 1024, details)


class DeadCodeError(ValidationError)
    #     """Exception raised when dead code is detected"""

    #     def __init__(self, message: str, line_number: Optional[int] = None,
    code_snippet: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    #         if details is None:
    details = {}

    #         if line_number is not None:
    details["line_number"] = line_number
    #         if code_snippet is not None:
    details["code_snippet"] = code_snippet

            super().__init__(message, 1025, details)


# Error code mapping for easy lookup
ERROR_CODE_MAP = {
#     1001: ValidatorInitializationError,
#     1002: FileAccessError,
#     1003: ParsingError,
#     1004: ASTVerificationError,
#     1005: ForeignSyntaxError,
#     1006: AutoCorrectionError,
#     1007: ReportGenerationError,
#     1008: ConfigurationError,
#     1009: TimeoutError,
#     1010: MemoryLimitError,
#     1011: CircularReferenceError,
#     1012: TypeMismatchError,
#     1013: InvalidNodeStructureError,
#     1014: InvalidOperatorError,
#     1015: InvalidIdentifierError,
#     1016: InvalidControlFlowError,
#     1017: InvalidImportError,
#     1018: InvalidFunctionDefinitionError,
#     1019: InvalidClassDefinitionError,
#     1020: InvalidVariableUsageError,
#     1021: InvalidAsyncUsageError,
#     1022: InvalidExceptionHandlingError,
#     1023: InvalidDecoratorError,
#     1024: UnreachableCodeError,
#     1025: DeadCodeError,
# }


def create_validation_error(error_code: int, message: str, **kwargs) -ValidationError):
#     """
#     Create a validation error by error code

#     Args:
#         error_code: 4-digit error code
#         message: Error message
#         **kwargs: Additional arguments for the specific error type

#     Returns:
#         ValidationError instance
#     """
#     error_class = ERROR_CODE_MAP.get(error_code, ValidationError)
    return error_class(message, error_code, **kwargs)


def is_validation_error_code(error_code: int) -bool):
#     """
#     Check if an error code is a valid validation error code

#     Args:
#         error_code: Error code to check

#     Returns:
#         True if valid, False otherwise
#     """
#     return error_code in ERROR_CODE_MAP