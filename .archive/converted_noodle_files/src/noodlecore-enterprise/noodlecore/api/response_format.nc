# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Standardized API Response Format for NoodleCore
# ----------------------------------------------

# This module provides standardized response formatting for all NoodleCore API endpoints,
# ensuring consistent structure with requestId field (UUID v4), proper status codes,
# and timestamp information as required by the Noodle AI Coding Agent Development Standards.
# """

import logging
import uuid
import datetime.datetime
import typing.Any,

import flask.jsonify,
import werkzeug.exceptions.HTTPException

logger = logging.getLogger(__name__)


class APIResponseFormatter
    #     """
    #     Standardized API response formatter that ensures all responses contain
        requestId field (UUID v4), consistent structure, and proper status codes.
    #     """

    #     @staticmethod
    #     def create_success_response(
    #         data: Any,
    request_id: Optional[str] = None,
    status_code: int = 200,
    message: Optional[str] = None
    #     ) -> Tuple[Response, int]:
    #         """
    #         Create a standardized success response.

    #         Args:
    #             data: Response data payload
                request_id: Optional request ID (UUID v4). If not provided, a new one will be generated
                status_code: HTTP status code (default: 200)
    #             message: Optional success message

    #         Returns:
                Tuple of (Flask Response, status_code)
    #         """
    #         # Generate request ID if not provided
    #         if not request_id:
    request_id = str(uuid.uuid4())

    response = {
    #             "success": True,
    #             "requestId": request_id,
                "timestamp": datetime.now().isoformat(),
    #             "data": data,
    #         }

    #         # Add message if provided
    #         if message:
    response["message"] = message

            return jsonify(response), status_code

    #     @staticmethod
    #     def create_error_response(
    #         error: Union[Any, Exception, str],
    request_id: Optional[str] = None,
    status_code: Optional[int] = None
    #     ) -> Tuple[Response, int]:
    #         """
    #         Create a standardized error response.

    #         Args:
    #             error: Error object or message
                request_id: Optional request ID (UUID v4). If not provided, a new one will be generated
    #             status_code: Optional HTTP status code. If not provided, will be derived from error object

    #         Returns:
                Tuple of (Flask Response, status_code)
    #         """
    #         # Generate request ID if not provided
    #         if not request_id:
    request_id = str(uuid.uuid4())

    #         # Handle different error types
    #         # Check if error has to_dict method (like MobileAPIError)
    #         if hasattr(error, 'to_dict') and callable(getattr(error, 'to_dict')):
    error_data = error.to_dict()
    response_status = status_code or getattr(error, 'status_code', 500)
    #         elif isinstance(error, HTTPException):
    error_data = {
    #                 "error": error.description,
    #                 "error_code": 5000,  # Default error code for HTTP exceptions
    #                 "details": {}
    #             }
    response_status = status_code or error.code
    #         elif isinstance(error, Exception):
    error_data = {
                    "error": str(error),
    #                 "error_code": 5000,  # Default error code for generic exceptions
                    "details": {"type": type(error).__name__}
    #             }
    response_status = status_code or 500
    #         else:
    #             # Handle string error messages
    error_data = {
                    "error": str(error),
    #                 "error_code": 5000,  # Default error code
    #                 "details": {}
    #             }
    response_status = status_code or 500

    response = {
    #             "success": False,
    #             "requestId": request_id,
                "timestamp": datetime.now().isoformat(),
    #             "error": error_data,
    #         }

    #         # Log error
            logger.error(f"API Error (Request ID: {request_id}): {error_data['error']}")

            return jsonify(response), response_status

    #     @staticmethod
    #     def create_timeout_response(
    timeout_seconds: int = 30,
    request_id: Optional[str] = None
    #     ) -> Tuple[Response, int]:
    #         """
    #         Create a standardized timeout response.

    #         Args:
    #             timeout_seconds: Timeout duration in seconds
                request_id: Optional request ID (UUID v4). If not provided, a new one will be generated

    #         Returns:
    Tuple of (Flask Response, status_code = 408)
    #         """
    #         # Generate request ID if not provided
    #         if not request_id:
    request_id = str(uuid.uuid4())

    response = {
    #             "success": False,
    #             "requestId": request_id,
                "timestamp": datetime.now().isoformat(),
    #             "error": {
    #                 "error": f"Request timeout after {timeout_seconds} seconds",
    #                 "error_code": 3004,  # Timeout error code
    #                 "details": {"timeout_seconds": timeout_seconds}
    #             },
    #         }

    #         # Log timeout
            logger.warning(f"API Timeout (Request ID: {request_id}): {timeout_seconds}s")

            return jsonify(response), 408


class ResponseMiddleware
    #     """
    #     Flask middleware to ensure all responses follow the standardized format.
    #     """

    #     def __init__(self, app=None):
    self.app = app
    #         if app is not None:
                self.init_app(app)

    #     def init_app(self, app):
    #         """Initialize the middleware with Flask app."""
            app.after_request(self._after_request)
            app.before_request(self._before_request)

    #     def _before_request(self):
    #         """Generate request ID and store in request context."""
    #         # Generate unique request ID for each request
    #         from flask import g
    g.request_id = str(uuid.uuid4())
    g.request_start_time = datetime.now()

    #     def _after_request(self, response):
    #         """Process response after request is handled."""
    #         # Only process JSON responses that aren't already standardized
    #         if (
    #             response.content_type and
    #             'application/json' in response.content_type and
                not self._is_standardized_response(response)
    #         ):
    #             try:
    #                 import json
    #                 from flask import g

    #                 # Get request ID from context
    request_id = getattr(g, 'request_id', str(uuid.uuid4()))

    #                 # Parse existing response
    data = json.loads(response.get_data(as_text=True))

    #                 # Wrap in standardized format
    standard_response = {
    #                     "success": response.status_code < 400,
    #                     "requestId": request_id,
                        "timestamp": datetime.now().isoformat(),
    #                 }

    #                 if response.status_code < 400:
    standard_response["data"] = data
    #                 else:
    standard_response["error"] = data

    #                 # Set new response data
                    response.set_data(json.dumps(standard_response))
    response.headers['Content-Length'] = len(response.get_data())
                except (json.JSONDecodeError, Exception) as e:
    #                 # If we can't parse the response, leave it as is
                    logger.warning(f"Failed to standardize response: {e}")

    #         return response

    #     def _is_standardized_response(self, response) -> bool:
    #         """Check if response is already in standardized format."""
    #         try:
    #             import json
    data = json.loads(response.get_data(as_text=True))
                return (
                    isinstance(data, dict) and
    #                 "requestId" in data and
    #                 "timestamp" in data and
                    ("success" in data or "error" in data)
    #             )
            except (json.JSONDecodeError, Exception):
    #             return False


def success_response(
#     data: Any,
request_id: Optional[str] = None,
status_code: int = 200,
message: Optional[str] = None
# ) -> Tuple[Response, int]:
#     """
#     Convenience function to create a success response.

#     Args:
#         data: Response data payload
        request_id: Optional request ID (UUID v4)
        status_code: HTTP status code (default: 200)
#         message: Optional success message

#     Returns:
        Tuple of (Flask Response, status_code)
#     """
    return APIResponseFormatter.create_success_response(
data = data,
request_id = request_id,
status_code = status_code,
message = message
#     )


def error_response(
#     error: Union[Any, Exception, str],
request_id: Optional[str] = None,
status_code: Optional[int] = None
# ) -> Tuple[Response, int]:
#     """
#     Convenience function to create an error response.

#     Args:
#         error: Error object or message
        request_id: Optional request ID (UUID v4)
#         status_code: Optional HTTP status code

#     Returns:
        Tuple of (Flask Response, status_code)
#     """
    return APIResponseFormatter.create_error_response(
error = error,
request_id = request_id,
status_code = status_code
#     )


def timeout_response(
timeout_seconds: int = 30,
request_id: Optional[str] = None
# ) -> Tuple[Response, int]:
#     """
#     Convenience function to create a timeout response.

#     Args:
#         timeout_seconds: Timeout duration in seconds
        request_id: Optional request ID (UUID v4)

#     Returns:
Tuple of (Flask Response, status_code = 408)
#     """
    return APIResponseFormatter.create_timeout_response(
timeout_seconds = timeout_seconds,
request_id = request_id
#     )


def get_request_id() -> str:
#     """
#     Get the current request ID from the Flask request context.

#     Returns:
        Request ID (UUID v4)
#     """
#     try:
#         from flask import g
        return getattr(g, 'request_id', str(uuid.uuid4()))
    except (ImportError, RuntimeError):
        return str(uuid.uuid4())