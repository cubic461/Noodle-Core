# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# API Version 1 Endpoint Handlers
# -------------------------------

# This module contains all endpoint handlers for API version 1.
# These endpoints provide the core functionality of the NoodleCore API.
# """

import logging
import uuid
import tempfile
import subprocess
import time
import os
import json
import datetime.datetime
import pathlib.Path
import typing.Any,

import flask.Flask,
import sys

import ...runtime.http_server.NoodleHTTPServer
import ..response_format.success_response,
import ..validation.(
#     execute_code_schema,
#     validate_request,
#     validate_params,
#     session_id_params,
#     ValidationError
# )
import ..validation_middleware.ValidationMiddleware

logger = logging.getLogger(__name__)


function register_v1_endpoints(app: Flask, server: NoodleHTTPServer)
    #     """
    #     Register all v1 endpoints with the Flask app.

    #     Args:
    #         app: Flask application instance
    #         server: NoodleHTTPServer instance
    #     """

    #     # Initialize validation middleware
    validation_middleware = ValidationMiddleware(app)
    app.validation_middleware = validation_middleware

    #     # Register validation rules for endpoints
        validation_middleware.add_validation_rule("POST", "/api/v1/execute", {
    #         "code": {
    #             "required": True,
    #             "type": str,
    #             "min_length": 1,
    #             "max_length": 100000,
    #             "validator": lambda x, f: x,  # Will be sanitized in the endpoint
    #             "escape_html": False  # Don't escape here, will handle in endpoint
    #         },
    #         "options": {
    #             "required": False,
    #             "type": dict
    #         }
    #     })

        validation_middleware.add_param_validation_rule("GET", "/api/v1/sessions/{session_id}", {
    #         "session_id": {
    #             "required": True,
    #             "type": str,
                "validator": lambda x, f: uuid.UUID(x)  # Validate UUID format
    #         }
    #     })

        validation_middleware.add_param_validation_rule("DELETE", "/api/v1/sessions/{session_id}", {
    #         "session_id": {
    #             "required": True,
    #             "type": str,
                "validator": lambda x, f: uuid.UUID(x)  # Validate UUID format
    #         }
    #     })

    #     # Health check endpoint
    @app.route("/api/v1/health", methods = ["GET"])
    #     def health_check():
    #         """Health check endpoint."""
    data = {
    #             "status": "healthy",
    #             "version": "1.0.0",
    #         }
    return success_response(data, request_id = get_request_id())

    #     # Runtime status endpoint
    @app.route("/api/v1/runtime/status", methods = ["GET"])
    #     def runtime_status():
    #         """Get runtime status information."""
    #         try:
    #             # Get memory usage
    #             import psutil

    process = psutil.Process()
    memory_info = process.memory_info()

    #             # Get active sessions count
    #             with server.session_lock:
    active_sessions = len(server.sessions)

    data = {
    #                 "status": "running",
    #                 "memory_usage": {
    #                     "rss": memory_info.rss,
    #                     "vms": memory_info.vms,
                        "percent": process.memory_percent(),
    #                 },
    #                 "active_sessions": active_sessions,
                    "uptime": (
                        time.time() - server.start_time
    #                     if hasattr(server, "start_time")
    #                     else 0
    #                 ),
    #                 "core_path": server.core_path,
    #             }
    return success_response(data, request_id = get_request_id())
    #         except ImportError:
    #             # psutil not available, provide basic status
    data = {
    #                 "status": "running",
                    "active_sessions": len(server.sessions),
    #                 "core_path": server.core_path,
    #             }
    return success_response(data, request_id = get_request_id())

    #     # Execute code endpoint
    @app.route("/api/v1/execute", methods = ["POST"])
    #     def execute_code():
    #         """Execute Noodle code and return results."""
    #         try:
    #             # Get validated data from middleware or validate manually
    #             if hasattr(g, 'validated_data'):
    validated_data = g.validated_data
    code = validated_data.get("code", "")
    options = validated_data.get("options", {})
    #             else:
    #                 # Fallback validation if middleware didn't process
    data = request.get_json()
    #                 if not data:
                        raise ValidationError(
    #                         "Invalid JSON data",
    error_code = 1008
    #                     )

    #                 # Validate against schema
    validated_data = execute_code_schema.validate(data)
    code = validated_data.get("code", "")
    options = validated_data.get("options", {})

    #             # Sanitize code input
    #             from ..validation import InputValidator
    code = InputValidator.sanitize_code_input(code)
    code = InputValidator.escape_html(code)

    #             # Create unique session ID
    session_id = str(uuid.uuid4())

    #             # Create temporary file for the code
    #             with tempfile.NamedTemporaryFile(
    mode = "w", suffix=".noodle", delete=False
    #             ) as f:
                    f.write(code)
    temp_file = f.name

    #             # Prepare execution options
    exec_options = [
    #                 sys.executable,
    #                 server.core_path,
    #                 "--file",
    #                 temp_file,
    #                 "--format",
    #                 "json",
    #             ]

    #             # Add additional options
    #             if options.get("debug", False):
                    exec_options.append("--debug")
    #             if options.get("verbose", False):
                    exec_options.append("--verbose")

    #             # Execute the code
    start_time = time.time()

    #             # Prepare JSON input for core-entry-point.py
    input_data = {"command": "execute", "params": {"code": code}}

    #             # Run the core-entry-point.py with JSON input via stdin
    result = subprocess.run(
    #                 exec_options,
    input = json.dumps(input_data),
    capture_output = True,
    text = True,
    timeout = options.get("timeout", 30),
    #             )
    execution_time = math.subtract(time.time(), start_time)

    #             # Check if core script returned an error
    #             if result.returncode != 0:
    #                 try:
    #                     # Try to parse the error response from core script
    error_response_data = json.loads(result.stdout)
    #                     if error_response_data.get("status") == "error":
    #                         # Return the error response with appropriate status code
    return error_response(error_response_data, status_code = 400, request_id=get_request_id())
                    except (json.JSONDecodeError, AttributeError):
    #                     # If we can't parse the error, check stderr for specific error messages
    error_msg = result.stderr.strip()
    #                     if (
    #                         "400 Bad Request" in error_msg
    #                         or "Missing 'command'" in error_msg
    #                     ):
                            return error_response(
    #                             {
    #                                 "status": "error",
    #                                 "error": "Invalid request format",
    #                                 "details": "Missing required 'command' field",
    #                             },
    status_code = 400,
    request_id = get_request_id()
    #                         )
    #                     elif "404" in error_msg:
                            return error_response(
    #                             {"status": "error", "error": "Resource not found"},
    status_code = 404,
    request_id = get_request_id()
    #                         )
    #                     else:
    #                         # Return a generic error with the stderr content
                            return error_response(
    #                             {
    #                                 "status": "error",
    #                                 "error": "Core script execution failed",
    #                                 "details": result.stderr,
    #                             },
    status_code = 500,
    request_id = get_request_id()
    #                         )

    #             # Clean up temporary file
    #             try:
                    os.unlink(temp_file)
    #             except:
    #                 pass

    #             # Parse result
    #             output = result.stdout if result.returncode == 0 else result.stderr
    response_data = {
    #                 "session_id": session_id,
    #                 "execution_time": execution_time,
    #                 "exit_code": result.returncode,
    #                 "output": output,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    "success": result.returncode = = 0,
    #             }

    #             # Store session information
    #             with server.session_lock:
    server.sessions[session_id] = {
                        "created_at": datetime.now(),
    #                     "code": code,
    #                     "options": options,
    #                     "result": response_data,
    #                 }

    return success_response(response_data, request_id = get_request_id())

    #         except subprocess.TimeoutExpired:
                return timeout_response(
    timeout_seconds = options.get("timeout", 30),
    request_id = get_request_id()
    #             )
    #         except subprocess.CalledProcessError as e:
    #             # Check if the error contains a 400 Bad Request message
    #             if "400 Bad Request" in str(e) or "Missing 'command'" in str(e):
                    return error_response(
    #                     {
    #                         "status": "error",
    #                         "error": "Invalid request format",
    #                         "details": "Missing required 'command' field",
    #                     },
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             else:
                    logger.error(f"Core script execution error: {str(e)}")
                    return error_response(
    #                     {
    #                         "status": "error",
    #                         "error": "Core script execution failed",
                            "details": str(e),
    #                     },
    status_code = 500,
    request_id = get_request_id()
    #                 )
    #         except ValueError as e:
    #             # JSON parsing error or other value errors
                logger.error(f"Value error: {str(e)}")
                return error_response(
    #                 {
    #                     "status": "error",
    #                     "error": "Invalid request format",
                        "details": str(e),
    #                 },
    status_code = 400,
    request_id = get_request_id()
    #             )
    #         except Exception as e:
                logger.error(f"Execution error: {type(e).__name__}: {str(e)}")
    return error_response(f"Execution failed: {str(e)}", status_code = 500, request_id=get_request_id())

    #     # Session endpoints
    @app.route("/api/v1/sessions/<session_id>", methods = ["GET"])
    #     def get_session(session_id: str):
    #         """Get information about a specific session."""
    #         try:
    #             # Validate session_id format
    #             try:
                    uuid.UUID(session_id)
    #             except ValueError:
                    raise ValidationError(
    #                     "Invalid session ID format",
    error_code = 1003,
    details = {"expected_format": "UUID"}
    #                 )

    #             with server.session_lock:
    session = server.sessions.get(session_id)
    #                 if not session:
    return error_response("Session not found", status_code = 404, request_id=get_request_id())

    return success_response(session, request_id = get_request_id())
    #         except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    @app.route("/api/v1/sessions", methods = ["GET"])
    #     def list_sessions():
    #         """List all active sessions."""
    #         with server.session_lock:
    data = {
                    "sessions": list(server.sessions.keys()),
                    "count": len(server.sessions),
    #             }
    return success_response(data, request_id = get_request_id())

    @app.route("/api/v1/sessions/<session_id>", methods = ["DELETE"])
    #     def delete_session(session_id: str):
    #         """Delete a specific session."""
    #         try:
    #             # Validate session_id format
    #             try:
                    uuid.UUID(session_id)
    #             except ValueError:
                    raise ValidationError(
    #                     "Invalid session ID format",
    error_code = 1003,
    details = {"expected_format": "UUID"}
    #                 )

    #             with server.session_lock:
    #                 if session_id in server.sessions:
    #                     del server.sessions[session_id]
    return success_response({"message": "Session deleted"}, request_id = get_request_id())
    #                 else:
    return error_response("Session not found", status_code = 404, request_id=get_request_id())
    #         except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())