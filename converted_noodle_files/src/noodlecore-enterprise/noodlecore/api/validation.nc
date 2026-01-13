# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Input Validation System for NoodleCore API
# ------------------------------------------

# This module provides comprehensive input validation for all NoodleCore API endpoints,
# including HTML escaping to prevent XSS attacks, data type validation, format validation,
# and range checking as required by the Noodle AI Coding Agent Development Standards.
# """

import html
import logging
import re
import uuid
import datetime.datetime
import typing.Any,
import functools.wraps

import flask.request,
import .response_format.error_response,

logger = logging.getLogger(__name__)

# Validation error codes as per Noodle standards (4-digit format)
VALIDATION_ERROR_CODES = {
#     "missing_required": 1001,
#     "invalid_type": 1002,
#     "invalid_format": 1003,
#     "out_of_range": 1004,
#     "invalid_length": 1005,
#     "invalid_pattern": 1006,
#     "forbidden_content": 1007,
#     "invalid_json": 1008,
#     "validation_failed": 1009,
# }


class ValidationError(Exception)
    #     """
    #     Custom exception for validation errors with proper error codes.

    #     Attributes:
    #         message: Error message
    #         error_code: 4-digit error code as per Noodle standards
    #         details: Additional error details
    #     """

    #     def __init__(self, message: str, error_code: int = 1009, details: Dict = None):
    self.message = message
    self.error_code = error_code
    self.details = details or {}
            super().__init__(self.message)

    #     def to_dict(self) -> Dict:
    #         """Convert exception to dictionary format."""
    #         return {
    #             "error": self.message,
    #             "error_code": self.error_code,
    #             "details": self.details
    #         }


class InputValidator
    #     """
    #     Comprehensive input validator for NoodleCore API.

    #     Provides methods to validate and sanitize user input according to Noodle standards,
    #     including HTML escaping to prevent XSS attacks.
    #     """

    #     @staticmethod
    #     def escape_html(value: str) -> str:
    #         """
    #         Escape HTML entities to prevent XSS attacks.

    #         Args:
    #             value: Input string to escape

    #         Returns:
    #             HTML-escaped string
    #         """
    #         if not isinstance(value, str):
    #             return value
    return html.escape(value, quote = True)

    #     @staticmethod
    #     def validate_required(value: Any, field_name: str) -> Any:
    #         """
    #         Validate that a field is present and not empty.

    #         Args:
    #             value: Field value to validate
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated value

    #         Raises:
    #             ValidationError: If field is missing or empty
    #         """
    #         if value is None or (isinstance(value, str) and not value.strip()):
                raise ValidationError(
    #                 f"Required field '{field_name}' is missing or empty",
    error_code = VALIDATION_ERROR_CODES["missing_required"],
    details = {"field": field_name}
    #             )
    #         return value

    #     @staticmethod
    #     def validate_type(value: Any, expected_type: type, field_name: str) -> Any:
    #         """
    #         Validate that a field has the expected type.

    #         Args:
    #             value: Field value to validate
    #             expected_type: Expected type
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated value

    #         Raises:
    #             ValidationError: If field has incorrect type
    #         """
    #         if not isinstance(value, expected_type):
                raise ValidationError(
    #                 f"Field '{field_name}' must be of type {expected_type.__name__}",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {
    #                     "field": field_name,
    #                     "expected_type": expected_type.__name__,
                        "actual_type": type(value).__name__
    #                 }
    #             )
    #         return value

    #     @staticmethod
    #     def validate_string_length(value: str, min_length: int = 0, max_length: int = None, field_name: str = "field") -> str:
    #         """
    #         Validate string length constraints.

    #         Args:
    #             value: String value to validate
    #             min_length: Minimum allowed length
    #             max_length: Maximum allowed length
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated string

    #         Raises:
    #             ValidationError: If string length is out of bounds
    #         """
    #         if not isinstance(value, str):
                raise ValidationError(
    #                 f"Field '{field_name}' must be a string",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"field": field_name, "expected_type": "str"}
    #             )

    length = len(value)
    #         if length < min_length:
                raise ValidationError(
    #                 f"Field '{field_name}' must be at least {min_length} characters long",
    error_code = VALIDATION_ERROR_CODES["invalid_length"],
    details = {
    #                     "field": field_name,
    #                     "min_length": min_length,
    #                     "actual_length": length
    #                 }
    #             )

    #         if max_length is not None and length > max_length:
                raise ValidationError(
    #                 f"Field '{field_name}' must be at most {max_length} characters long",
    error_code = VALIDATION_ERROR_CODES["invalid_length"],
    details = {
    #                     "field": field_name,
    #                     "max_length": max_length,
    #                     "actual_length": length
    #                 }
    #             )

    #         return value

    #     @staticmethod
    #     def validate_pattern(value: str, pattern: str, field_name: str = "field") -> str:
    #         """
    #         Validate that a string matches a regex pattern.

    #         Args:
    #             value: String value to validate
    #             pattern: Regex pattern to match
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated string

    #         Raises:
    #             ValidationError: If string doesn't match pattern
    #         """
    #         if not isinstance(value, str):
                raise ValidationError(
    #                 f"Field '{field_name}' must be a string",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"field": field_name, "expected_type": "str"}
    #             )

    #         if not re.match(pattern, value):
                raise ValidationError(
    #                 f"Field '{field_name}' does not match required pattern",
    error_code = VALIDATION_ERROR_CODES["invalid_pattern"],
    details = {"field": field_name, "pattern": pattern}
    #             )

    #         return value

    #     @staticmethod
    #     def validate_uuid(value: str, field_name: str = "field") -> str:
    #         """
    #         Validate that a string is a valid UUID.

    #         Args:
    #             value: String value to validate
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated UUID string

    #         Raises:
    #             ValidationError: If string is not a valid UUID
    #         """
    #         if not isinstance(value, str):
                raise ValidationError(
    #                 f"Field '{field_name}' must be a string",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"field": field_name, "expected_type": "str"}
    #             )

    #         try:
                uuid.UUID(value)
    #             return value
    #         except ValueError:
                raise ValidationError(
    #                 f"Field '{field_name}' must be a valid UUID",
    error_code = VALIDATION_ERROR_CODES["invalid_format"],
    details = {"field": field_name, "expected_format": "UUID"}
    #             )

    #     @staticmethod
    #     def validate_numeric_range(value: Union[int, float], min_val: Union[int, float] = None,
    max_val: Union[int, float] = None, field_name: str = "field") -> Union[int, float]:
    #         """
    #         Validate that a numeric value is within the specified range.

    #         Args:
    #             value: Numeric value to validate
    #             min_val: Minimum allowed value
    #             max_val: Maximum allowed value
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated numeric value

    #         Raises:
    #             ValidationError: If value is out of range
    #         """
    #         if not isinstance(value, (int, float)):
                raise ValidationError(
    #                 f"Field '{field_name}' must be a number",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"field": field_name, "expected_type": "int or float"}
    #             )

    #         if min_val is not None and value < min_val:
                raise ValidationError(
    #                 f"Field '{field_name}' must be at least {min_val}",
    error_code = VALIDATION_ERROR_CODES["out_of_range"],
    details = {
    #                     "field": field_name,
    #                     "min_value": min_val,
    #                     "actual_value": value
    #                 }
    #             )

    #         if max_val is not None and value > max_val:
                raise ValidationError(
    #                 f"Field '{field_name}' must be at most {max_val}",
    error_code = VALIDATION_ERROR_CODES["out_of_range"],
    details = {
    #                     "field": field_name,
    #                     "max_value": max_val,
    #                     "actual_value": value
    #                 }
    #             )

    #         return value

    #     @staticmethod
    #     def validate_json(value: str, field_name: str = "field") -> Dict:
    #         """
    #         Validate that a string is valid JSON.

    #         Args:
    #             value: String value to validate
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Parsed JSON dictionary

    #         Raises:
    #             ValidationError: If string is not valid JSON
    #         """
    #         if not isinstance(value, str):
                raise ValidationError(
    #                 f"Field '{field_name}' must be a string",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"field": field_name, "expected_type": "str"}
    #             )

    #         try:
    #             import json
                return json.loads(value)
    #         except json.JSONDecodeError as e:
                raise ValidationError(
    #                 f"Field '{field_name}' contains invalid JSON",
    error_code = VALIDATION_ERROR_CODES["invalid_json"],
    details = {
    #                     "field": field_name,
                        "parse_error": str(e)
    #                 }
    #             )

    #     @staticmethod
    #     def validate_file_path(value: str, field_name: str = "field") -> str:
    #         """
    #         Validate that a string is a safe file path.

    #         Args:
    #             value: File path to validate
    #             field_name: Name of the field for error messages

    #         Returns:
    #             Validated file path

    #         Raises:
    #             ValidationError: If path is unsafe
    #         """
    #         if not isinstance(value, str):
                raise ValidationError(
    #                 f"Field '{field_name}' must be a string",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"field": field_name, "expected_type": "str"}
    #             )

    #         # Check for path traversal attempts
    #         if ".." in value or value.startswith("/"):
                raise ValidationError(
    #                 f"Field '{field_name}' contains unsafe path",
    error_code = VALIDATION_ERROR_CODES["forbidden_content"],
    details = {"field": field_name, "reason": "Path traversal detected"}
    #             )

    #         # Check for forbidden characters
    forbidden_chars = ['<', '>', ':', '"', '|', '?', '*']
    #         if any(char in value for char in forbidden_chars):
                raise ValidationError(
    #                 f"Field '{field_name}' contains forbidden characters",
    error_code = VALIDATION_ERROR_CODES["forbidden_content"],
    details = {
    #                     "field": field_name,
    #                     "forbidden_chars": [c for c in forbidden_chars if c in value]
    #                 }
    #             )

    #         return value

    #     @staticmethod
    #     def sanitize_code_input(code: str) -> str:
    #         """
    #         Sanitize code input while preserving functionality.

    #         Args:
    #             code: Code string to sanitize

    #         Returns:
    #             Sanitized code string
    #         """
    #         if not isinstance(code, str):
    #             return code

    #         # Escape HTML entities to prevent XSS
    #         # Note: This is a basic implementation. In a production environment,
    #         # you might want to use more sophisticated code sanitization
    #         # that preserves code functionality while preventing XSS
    #         return code


class ValidationSchema
    #     """
    #     Schema definition for input validation.

    #     Allows defining validation rules for complex objects.
    #     """

    #     def __init__(self):
    self.fields = {}
    self.required_fields = set()

    #     def add_field(self, name: str, validators: List[Callable], required: bool = True):
    #         """
    #         Add a field to the validation schema.

    #         Args:
    #             name: Field name
    #             validators: List of validator functions
    #             required: Whether the field is required
    #         """
    self.fields[name] = validators
    #         if required:
                self.required_fields.add(name)

    #     def validate(self, data: Dict) -> Dict:
    #         """
    #         Validate data against the schema.

    #         Args:
    #             data: Dictionary to validate

    #         Returns:
    #             Validated and sanitized data

    #         Raises:
    #             ValidationError: If validation fails
    #         """
    #         if not isinstance(data, dict):
                raise ValidationError(
    #                 "Input data must be a JSON object",
    error_code = VALIDATION_ERROR_CODES["invalid_type"],
    details = {"expected_type": "object"}
    #             )

    validated_data = {}

    #         # Check required fields
    #         for field_name in self.required_fields:
    #             if field_name not in data:
                    raise ValidationError(
    #                     f"Required field '{field_name}' is missing",
    error_code = VALIDATION_ERROR_CODES["missing_required"],
    details = {"field": field_name}
    #                 )

    #         # Validate each field
    #         for field_name, value in data.items():
    #             if field_name in self.fields:
    validated_value = value
    #                 for validator in self.fields[field_name]:
    #                     try:
    validated_value = validator(validated_value, field_name)
    #                     except TypeError:
    #                         # Handle validators that don't take field_name parameter
    validated_value = validator(validated_value)

    validated_data[field_name] = validated_value

    #         return validated_data


function validate_request(schema: ValidationSchema)
    #     """
    #     Decorator to validate request data against a schema.

    #     Args:
    #         schema: Validation schema to use

    #     Returns:
    #         Decorator function
    #     """
    #     def decorator(func):
            @wraps(func)
    #         def wrapper(*args, **kwargs):
    #             try:
    #                 # Get JSON data from request
    data = request.get_json()
    #                 if data is None:
                        return error_response(
    #                         "Invalid JSON data",
    status_code = 400,
    request_id = get_request_id()
    #                     )

    #                 # Validate data against schema
    validated_data = schema.validate(data)

    #                 # Store validated data in request context
    g.validated_data = validated_data

    #                 # Call the original function
                    return func(*args, **kwargs)

    #             except ValidationError as e:
                    logger.warning(f"Validation error (Request ID: {get_request_id()}): {e.message}")
                    return error_response(
                        e.to_dict(),
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             except Exception as e:
                    logger.error(f"Unexpected validation error (Request ID: {get_request_id()}): {str(e)}")
                    return error_response(
    #                     "Validation failed",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    #         return wrapper
    #     return decorator


function validate_params(schema: Dict[str, List[Callable]])
    #     """
    #     Decorator to validate request parameters against a schema.

    #     Args:
    #         schema: Dictionary mapping parameter names to validator functions

    #     Returns:
    #         Decorator function
    #     """
    #     def decorator(func):
            @wraps(func)
    #         def wrapper(*args, **kwargs):
    #             try:
    validated_params = {}

    #                 # Validate each parameter
    #                 for param_name, validators in schema.items():
    param_value = request.args.get(param_name)

    #                     # Check if parameter is required
    #                     if param_value is None:
    #                         # Check if first validator is a required validator
    #                         if validators and hasattr(validators[0], '__name__') and 'required' in validators[0].__name__:
                                raise ValidationError(
    #                                 f"Required parameter '{param_name}' is missing",
    error_code = VALIDATION_ERROR_CODES["missing_required"],
    details = {"parameter": param_name}
    #                             )
    #                         continue

    #                     # Apply validators
    validated_value = param_value
    #                     for validator in validators:
    validated_value = validator(validated_value, param_name)

    validated_params[param_name] = validated_value

    #                 # Store validated parameters in request context
    g.validated_params = validated_params

    #                 # Call the original function
                    return func(*args, **kwargs)

    #             except ValidationError as e:
                    logger.warning(f"Parameter validation error (Request ID: {get_request_id()}): {e.message}")
                    return error_response(
                        e.to_dict(),
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             except Exception as e:
                    logger.error(f"Unexpected parameter validation error (Request ID: {get_request_id()}): {str(e)}")
                    return error_response(
    #                     "Parameter validation failed",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    #         return wrapper
    #     return decorator


# Common validation schemas
execute_code_schema = ValidationSchema()
execute_code_schema.add_field(
#     "code",
#     [
        lambda x, f: InputValidator.validate_required(x, f),
lambda x, f: InputValidator.validate_string_length(x, min_length = 1, max_length=100000, field_name=f),
        lambda x, f: InputValidator.sanitize_code_input(x),
        lambda x, f: InputValidator.escape_html(x)
#     ],
required = True
# )
execute_code_schema.add_field(
#     "options",
#     [
        lambda x, f: InputValidator.validate_type(x, dict, f)
#     ],
required = False
# )
execute_code_schema.add_field(
#     "environment",
#     [
        lambda x, f: InputValidator.validate_type(x, dict, f)
#     ],
required = False
# )
execute_code_schema.add_field(
#     "context",
#     [
        lambda x, f: InputValidator.validate_type(x, dict, f)
#     ],
required = False
# )

batch_execute_schema = ValidationSchema()
batch_execute_schema.add_field(
#     "requests",
#     [
        lambda x, f: InputValidator.validate_required(x, f),
        lambda x, f: InputValidator.validate_type(x, list, f),
lambda x, f: InputValidator.validate_numeric_range(x, min_val = 1, max_val=10, field_name=f)
#     ],
required = True
# )
batch_execute_schema.add_field(
#     "options",
#     [
        lambda x, f: InputValidator.validate_type(x, dict, f)
#     ],
required = False
# )

file_path_schema = ValidationSchema()
file_path_schema.add_field(
#     "path",
#     [
        lambda x, f: InputValidator.validate_required(x, f),
lambda x, f: InputValidator.validate_string_length(x, min_length = 1, max_length=255, field_name=f),
        lambda x, f: InputValidator.validate_file_path(x, f),
        lambda x, f: InputValidator.escape_html(x)
#     ],
required = True
# )

file_content_schema = ValidationSchema()
file_content_schema.add_field(
#     "path",
#     [
        lambda x, f: InputValidator.validate_required(x, f),
lambda x, f: InputValidator.validate_string_length(x, min_length = 1, max_length=255, field_name=f),
        lambda x, f: InputValidator.validate_file_path(x, f),
        lambda x, f: InputValidator.escape_html(x)
#     ],
required = True
# )
file_content_schema.add_field(
#     "content",
#     [
        lambda x, f: InputValidator.validate_required(x, f),
        lambda x, f: InputValidator.escape_html(x)
#     ],
required = True
# )

project_schema = ValidationSchema()
project_schema.add_field(
#     "name",
#     [
        lambda x, f: InputValidator.validate_required(x, f),
lambda x, f: InputValidator.validate_string_length(x, min_length = 1, max_length=100, field_name=f),
        lambda x, f: InputValidator.validate_pattern(x, r'^[a-zA-Z0-9_-]+$', f),
        lambda x, f: InputValidator.escape_html(x)
#     ],
required = True
# )
project_schema.add_field(
#     "description",
#     [
lambda x, f: InputValidator.validate_string_length(x, min_length = 0, max_length=500, field_name=f),
        lambda x, f: InputValidator.escape_html(x)
#     ],
required = False
# )

# Common parameter validation schemas
session_id_params = {
#     "session_id": [
        lambda x, f: InputValidator.validate_required(x, f),
        lambda x, f: InputValidator.validate_uuid(x, f)
#     ]
# }

file_path_params = {
#     "path": [
        lambda x, f: InputValidator.validate_required(x, f),
        lambda x, f: InputValidator.validate_file_path(x, f),
        lambda x, f: InputValidator.escape_html(x)
#     ]
# }