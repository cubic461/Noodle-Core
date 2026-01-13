# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Validation Middleware for NoodleCore API
# ----------------------------------------

# This module provides middleware for automatic input validation for all NoodleCore API endpoints.
# It integrates with the validation system to ensure all requests are properly validated
# before reaching the endpoint handlers, following the Noodle AI Coding Agent Development Standards.
# """

import logging
import time
import typing.Dict,
import functools.wraps

import flask.Flask,
import werkzeug.exceptions.BadRequest

import .validation.ValidationError,
import .response_format.error_response,

logger = logging.getLogger(__name__)

# Validation statistics
VALIDATION_STATS = {
#     "total_requests": 0,
#     "validation_errors": 0,
#     "validation_time_ms": 0,
#     "blocked_requests": 0
# }


class ValidationMiddleware
    #     """
    #     Flask middleware for automatic input validation.

    #     This middleware:
    #     - Validates incoming requests before they reach endpoint handlers
    #     - Sanitizes user inputs to prevent XSS attacks
    #     - Logs validation attempts and failures for security monitoring
    #     - Returns standardized error responses for validation failures
    #     """

    #     def __init__(self, app: Flask = None):
    #         """Initialize the validation middleware."""
    self.app = app
    self.validation_rules = {}
    self.param_validation_rules = {}

    #         if app is not None:
                self.init_app(app)

    #     def init_app(self, app: Flask):
    #         """Initialize the middleware with Flask app."""
            app.before_request(self._before_request)
            app.after_request(self._after_request)

    #         # Register validation statistics endpoint
    @app.route("/api/validation/stats", methods = ["GET"])
    #         def get_validation_stats():
    #             """Get validation statistics for monitoring."""
    return success_response(VALIDATION_STATS, request_id = get_request_id())

    #     def _before_request(self):
    #         """Process request before it reaches the endpoint handler."""
    #         # Start validation timer
    g.validation_start_time = time.time()

    #         # Update statistics
    VALIDATION_STATS["total_requests"] + = 1

    #         # Get request path and method
    path = request.path
    method = request.method

    #         # Check if we have validation rules for this endpoint
    endpoint_key = f"{method}:{path}"
    #         if endpoint_key in self.validation_rules:
    #             try:
    #                 # Get JSON data from request
    data = request.get_json()
    #                 if data is None:
                        raise ValidationError(
    #                         "Invalid JSON data",
    error_code = 1008,
    details = {"endpoint": endpoint_key}
    #                     )

    #                 # Validate data against rules
    validated_data = self._validate_data(data, self.validation_rules[endpoint_key])

    #                 # Store validated data in request context
    g.validated_data = validated_data

    #             except ValidationError as e:
    #                 # Log validation error
                    self._log_validation_error(endpoint_key, e)

    #                 # Update statistics
    VALIDATION_STATS["validation_errors"] + = 1
    VALIDATION_STATS["blocked_requests"] + = 1

    #                 # Return error response
                    return error_response(
                        e.to_dict(),
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             except Exception as e:
    #                 # Log unexpected error
    #                 logger.error(f"Unexpected validation error for {endpoint_key}: {str(e)}")

    #                 # Update statistics
    VALIDATION_STATS["validation_errors"] + = 1
    VALIDATION_STATS["blocked_requests"] + = 1

    #                 # Return generic error response
                    return error_response(
    #                     "Validation failed",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    #         # Check parameter validation rules
    #         if endpoint_key in self.param_validation_rules:
    #             try:
    #                 # Validate query parameters
    validated_params = self._validate_params(
                        request.args.to_dict(),
    #                     self.param_validation_rules[endpoint_key]
    #                 )

    #                 # Store validated parameters in request context
    g.validated_params = validated_params

    #             except ValidationError as e:
    #                 # Log validation error
                    self._log_validation_error(endpoint_key, e)

    #                 # Update statistics
    VALIDATION_STATS["validation_errors"] + = 1
    VALIDATION_STATS["blocked_requests"] + = 1

    #                 # Return error response
                    return error_response(
                        e.to_dict(),
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             except Exception as e:
    #                 # Log unexpected error
    #                 logger.error(f"Unexpected parameter validation error for {endpoint_key}: {str(e)}")

    #                 # Update statistics
    VALIDATION_STATS["validation_errors"] + = 1
    VALIDATION_STATS["blocked_requests"] + = 1

    #                 # Return generic error response
                    return error_response(
    #                     "Parameter validation failed",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    #     def _after_request(self, response):
    #         """Process response after it's generated."""
    #         # Update validation timing statistics
    #         if hasattr(g, 'validation_start_time'):
    validation_time = math.multiply((time.time() - g.validation_start_time), 1000  # Convert to ms)
    VALIDATION_STATS["validation_time_ms"] + = validation_time

    #             # Add validation timing header
    response.headers['X-Validation-Time-Ms'] = f"{validation_time:.2f}"

    #         # Add validation status header
    #         if hasattr(g, 'validated_data') or hasattr(g, 'validated_params'):
    response.headers['X-Validation-Status'] = 'passed'
    #         else:
    response.headers['X-Validation-Status'] = 'skipped'

    #         return response

    #     def _validate_data(self, data: Dict, rules: Dict) -> Dict:
    #         """
    #         Validate request data against rules.

    #         Args:
    #             data: Request data to validate
    #             rules: Validation rules to apply

    #         Returns:
    #             Validated and sanitized data

    #         Raises:
    #             ValidationError: If validation fails
    #         """
    #         if not isinstance(data, dict):
                raise ValidationError(
    #                 "Request data must be a JSON object",
    error_code = 1002,
    details = {"expected_type": "object"}
    #             )

    validated_data = {}

    #         # Check required fields
    #         for field_name, field_rules in rules.items():
    #             if field_rules.get("required", False) and field_name not in data:
                    raise ValidationError(
    #                     f"Required field '{field_name}' is missing",
    error_code = 1001,
    details = {"field": field_name}
    #                 )

    #         # Validate each field
    #         for field_name, value in data.items():
    #             if field_name in rules:
    field_rules = rules[field_name]
    validated_value = value

    #                 # Apply type validation
    #                 if "type" in field_rules:
    expected_type = field_rules["type"]
    #                     if not isinstance(validated_value, expected_type):
                            raise ValidationError(
    #                             f"Field '{field_name}' must be of type {expected_type.__name__}",
    error_code = 1002,
    details = {
    #                                 "field": field_name,
    #                                 "expected_type": expected_type.__name__,
                                    "actual_type": type(validated_value).__name__
    #                             }
    #                         )

    #                 # Apply string length validation
    #                 if isinstance(validated_value, str):
    #                     if "min_length" in field_rules:
    min_length = field_rules["min_length"]
    #                         if len(validated_value) < min_length:
                                raise ValidationError(
    #                                 f"Field '{field_name}' must be at least {min_length} characters long",
    error_code = 1005,
    details = {
    #                                     "field": field_name,
    #                                     "min_length": min_length,
                                        "actual_length": len(validated_value)
    #                                 }
    #                             )

    #                     if "max_length" in field_rules:
    max_length = field_rules["max_length"]
    #                         if len(validated_value) > max_length:
                                raise ValidationError(
    #                                 f"Field '{field_name}' must be at most {max_length} characters long",
    error_code = 1005,
    details = {
    #                                     "field": field_name,
    #                                     "max_length": max_length,
                                        "actual_length": len(validated_value)
    #                                 }
    #                             )

    #                     # Apply pattern validation
    #                     if "pattern" in field_rules:
    pattern = field_rules["pattern"]
    #                         import re
    #                         if not re.match(pattern, validated_value):
                                raise ValidationError(
    #                                 f"Field '{field_name}' does not match required pattern",
    error_code = 1006,
    details = {"field": field_name, "pattern": pattern}
    #                             )

    #                     # Apply HTML escaping for XSS prevention
    #                     if field_rules.get("escape_html", True):
    validated_value = InputValidator.escape_html(validated_value)

    #                 # Apply numeric range validation
    #                 if isinstance(validated_value, (int, float)):
    #                     if "min_value" in field_rules:
    min_value = field_rules["min_value"]
    #                         if validated_value < min_value:
                                raise ValidationError(
    #                                 f"Field '{field_name}' must be at least {min_value}",
    error_code = 1004,
    details = {
    #                                     "field": field_name,
    #                                     "min_value": min_value,
    #                                     "actual_value": validated_value
    #                                 }
    #                             )

    #                     if "max_value" in field_rules:
    max_value = field_rules["max_value"]
    #                         if validated_value > max_value:
                                raise ValidationError(
    #                                 f"Field '{field_name}' must be at most {max_value}",
    error_code = 1004,
    details = {
    #                                     "field": field_name,
    #                                     "max_value": max_value,
    #                                     "actual_value": validated_value
    #                                 }
    #                             )

    #                 # Apply custom validator
    #                 if "validator" in field_rules:
    validator = field_rules["validator"]
    #                     try:
    validated_value = validator(validated_value, field_name)
    #                     except TypeError:
    #                         # Handle validators that don't take field_name parameter
    validated_value = validator(validated_value)

    validated_data[field_name] = validated_value

    #         return validated_data

    #     def _validate_params(self, params: Dict, rules: Dict) -> Dict:
    #         """
    #         Validate query parameters against rules.

    #         Args:
    #             params: Query parameters to validate
    #             rules: Validation rules to apply

    #         Returns:
    #             Validated and sanitized parameters

    #         Raises:
    #             ValidationError: If validation fails
    #         """
    validated_params = {}

    #         # Check required parameters
    #         for param_name, param_rules in rules.items():
    #             if param_rules.get("required", False) and param_name not in params:
                    raise ValidationError(
    #                     f"Required parameter '{param_name}' is missing",
    error_code = 1001,
    details = {"parameter": param_name}
    #                 )

    #         # Validate each parameter
    #         for param_name, value in params.items():
    #             if param_name in rules:
    param_rules = rules[param_name]
    validated_value = value

    #                 # Apply type validation
    #                 if "type" in param_rules:
    expected_type = param_rules["type"]
    #                     try:
    #                         if expected_type == int:
    validated_value = int(validated_value)
    #                         elif expected_type == float:
    validated_value = float(validated_value)
    #                         elif expected_type == bool:
    validated_value = validated_value.lower() in ('true', '1', 'yes', 'on')
    #                         elif expected_type == str:
    validated_value = str(validated_value)
    #                         else:
    #                             if not isinstance(validated_value, expected_type):
                                    raise ValueError(f"Cannot convert to {expected_type.__name__}")
                        except (ValueError, TypeError):
                            raise ValidationError(
    #                             f"Parameter '{param_name}' must be of type {expected_type.__name__}",
    error_code = 1002,
    details = {
    #                                 "parameter": param_name,
    #                                 "expected_type": expected_type.__name__,
    #                                 "actual_value": value
    #                             }
    #                         )

    #                 # Apply string validation
    #                 if isinstance(validated_value, str):
    #                     if "min_length" in param_rules:
    min_length = param_rules["min_length"]
    #                         if len(validated_value) < min_length:
                                raise ValidationError(
    #                                 f"Parameter '{param_name}' must be at least {min_length} characters long",
    error_code = 1005,
    details = {
    #                                     "parameter": param_name,
    #                                     "min_length": min_length,
                                        "actual_length": len(validated_value)
    #                                 }
    #                             )

    #                     if "max_length" in param_rules:
    max_length = param_rules["max_length"]
    #                         if len(validated_value) > max_length:
                                raise ValidationError(
    #                                 f"Parameter '{param_name}' must be at most {max_length} characters long",
    error_code = 1005,
    details = {
    #                                     "parameter": param_name,
    #                                     "max_length": max_length,
                                        "actual_length": len(validated_value)
    #                                 }
    #                             )

    #                     # Apply pattern validation
    #                     if "pattern" in param_rules:
    pattern = param_rules["pattern"]
    #                         import re
    #                         if not re.match(pattern, validated_value):
                                raise ValidationError(
    #                                 f"Parameter '{param_name}' does not match required pattern",
    error_code = 1006,
    details = {"parameter": param_name, "pattern": pattern}
    #                             )

    #                     # Apply HTML escaping for XSS prevention
    #                     if param_rules.get("escape_html", True):
    validated_value = InputValidator.escape_html(validated_value)

    #                 # Apply numeric range validation
    #                 if isinstance(validated_value, (int, float)):
    #                     if "min_value" in param_rules:
    min_value = param_rules["min_value"]
    #                         if validated_value < min_value:
                                raise ValidationError(
    #                                 f"Parameter '{param_name}' must be at least {min_value}",
    error_code = 1004,
    details = {
    #                                     "parameter": param_name,
    #                                     "min_value": min_value,
    #                                     "actual_value": validated_value
    #                                 }
    #                             )

    #                     if "max_value" in param_rules:
    max_value = param_rules["max_value"]
    #                         if validated_value > max_value:
                                raise ValidationError(
    #                                 f"Parameter '{param_name}' must be at most {max_value}",
    error_code = 1004,
    details = {
    #                                     "parameter": param_name,
    #                                     "max_value": max_value,
    #                                     "actual_value": validated_value
    #                                 }
    #                             )

    #                 # Apply custom validator
    #                 if "validator" in param_rules:
    validator = param_rules["validator"]
    #                     try:
    validated_value = validator(validated_value, param_name)
    #                     except TypeError:
    #                         # Handle validators that don't take field_name parameter
    validated_value = validator(validated_value)

    validated_params[param_name] = validated_value

    #         return validated_params

    #     def _log_validation_error(self, endpoint: str, error: ValidationError):
    #         """Log validation error for security monitoring."""
            logger.warning(
    #             f"Validation failed for {endpoint} (Request ID: {get_request_id()}): {error.message}",
    extra = {
    #                 "endpoint": endpoint,
    #                 "error_code": error.error_code,
    #                 "details": error.details,
                    "request_id": get_request_id(),
    #                 "client_ip": request.remote_addr,
                    "user_agent": request.headers.get('User-Agent', '')
    #             }
    #         )

    #     def add_validation_rule(self, method: str, path: str, rules: Dict):
    #         """
    #         Add validation rules for an endpoint.

    #         Args:
                method: HTTP method (GET, POST, etc.)
    #             path: Endpoint path
    #             rules: Validation rules dictionary
    #         """
    endpoint_key = f"{method}:{path}"
    self.validation_rules[endpoint_key] = rules
    #         logger.debug(f"Added validation rules for {endpoint_key}")

    #     def add_param_validation_rule(self, method: str, path: str, rules: Dict):
    #         """
    #         Add parameter validation rules for an endpoint.

    #         Args:
                method: HTTP method (GET, POST, etc.)
    #             path: Endpoint path
    #             rules: Parameter validation rules dictionary
    #         """
    endpoint_key = f"{method}:{path}"
    self.param_validation_rules[endpoint_key] = rules
    #         logger.debug(f"Added parameter validation rules for {endpoint_key}")


function validate_endpoint(method: str, path: str, rules: Dict)
    #     """
    #     Decorator to add validation rules to an endpoint.

    #     Args:
            method: HTTP method (GET, POST, etc.)
    #         path: Endpoint path
    #         rules: Validation rules dictionary

    #     Returns:
    #         Decorator function
    #     """
    #     def decorator(func):
    #         # Register validation rules with the middleware
    #         if hasattr(current_app, 'validation_middleware'):
                current_app.validation_middleware.add_validation_rule(method, path, rules)

            @wraps(func)
    #         def wrapper(*args, **kwargs):
    #             # Get validated data from request context
    #             if hasattr(g, 'validated_data'):
    kwargs['validated_data'] = g.validated_data

    #             # Call the original function
                return func(*args, **kwargs)

    #         return wrapper
    #     return decorator


function validate_params(method: str, path: str, rules: Dict)
    #     """
    #     Decorator to add parameter validation rules to an endpoint.

    #     Args:
            method: HTTP method (GET, POST, etc.)
    #         path: Endpoint path
    #         rules: Parameter validation rules dictionary

    #     Returns:
    #         Decorator function
    #     """
    #     def decorator(func):
    #         # Register parameter validation rules with the middleware
    #         if hasattr(current_app, 'validation_middleware'):
                current_app.validation_middleware.add_param_validation_rule(method, path, rules)

            @wraps(func)
    #         def wrapper(*args, **kwargs):
    #             # Get validated parameters from request context
    #             if hasattr(g, 'validated_params'):
    kwargs['validated_params'] = g.validated_params

    #             # Call the original function
                return func(*args, **kwargs)

    #         return wrapper
    #     return decorator


# Common validation rules for NoodleCore endpoints
EXECUTE_CODE_RULES = {
#     "code": {
#         "required": True,
#         "type": str,
#         "min_length": 1,
#         "max_length": 100000,
#         "validator": InputValidator.sanitize_code_input,
#         "escape_html": True
#     },
#     "options": {
#         "required": False,
#         "type": dict
#     },
#     "environment": {
#         "required": False,
#         "type": dict
#     },
#     "context": {
#         "required": False,
#         "type": dict
#     }
# }

BATCH_EXECUTE_RULES = {
#     "requests": {
#         "required": True,
#         "type": list,
"validator": lambda x, f: InputValidator.validate_numeric_range(len(x), min_val = 1, max_val=10, field_name=f)
#     },
#     "options": {
#         "required": False,
#         "type": dict
#     }
# }

FILE_PATH_RULES = {
#     "path": {
#         "required": True,
#         "type": str,
#         "min_length": 1,
#         "max_length": 255,
#         "validator": InputValidator.validate_file_path,
#         "escape_html": True
#     }
# }

FILE_CONTENT_RULES = {
#     "path": {
#         "required": True,
#         "type": str,
#         "min_length": 1,
#         "max_length": 255,
#         "validator": InputValidator.validate_file_path,
#         "escape_html": True
#     },
#     "content": {
#         "required": True,
#         "type": str,
#         "escape_html": True
#     }
# }

PROJECT_RULES = {
#     "name": {
#         "required": True,
#         "type": str,
#         "min_length": 1,
#         "max_length": 100,
#         "pattern": r'^[a-zA-Z0-9_-]+$',
#         "escape_html": True
#     },
#     "description": {
#         "required": False,
#         "type": str,
#         "max_length": 500,
#         "escape_html": True
#     }
# }

SESSION_ID_RULES = {
#     "session_id": {
#         "required": True,
#         "type": str,
#         "validator": InputValidator.validate_uuid
#     }
# }