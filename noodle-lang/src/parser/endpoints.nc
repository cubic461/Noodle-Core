# Converted from Python to NoodleCore
# Original file: src

# """
# API Version 2 Endpoint Handlers
# -------------------------------

# This module contains all endpoint handlers for API version 2.
# This version enhances the v1 API with additional functionality and improved response formats.
# """

import logging
import uuid
import tempfile
import subprocess
import time
import os
import json
import sys
import datetime.datetime
import pathlib.Path
import typing.Any

import flask.Flask

import ...runtime.http_server.NoodleHTTPServer
import ..response_format.success_response
import ..validation.(
#     execute_code_schema,
#     batch_execute_schema,
#     validate_request,
#     validate_params,
#     session_id_params,
#     ValidationError,
#     InputValidator
# )
import ..validation_middleware.ValidationMiddleware

logger = logging.getLogger(__name__)


function register_v2_endpoints(app: Flask, server: NoodleHTTPServer)
    #     """
    #     Register all v2 endpoints with the Flask app.

    #     Args:
    #         app: Flask application instance
    #         server: NoodleHTTPServer instance
    #     """

    #     # Initialize validation middleware
    validation_middleware = ValidationMiddleware(app)
    app.validation_middleware = validation_middleware

    #     # Register validation rules for endpoints
        validation_middleware.add_validation_rule("POST", "/api/v2/execute", {
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
    #         },
    #         "environment": {
    #             "required": False,
    #             "type": dict
    #         },
    #         "context": {
    #             "required": False,
    #             "type": dict
    #         }
    #     })

        validation_middleware.add_validation_rule("POST", "/api/v2/execute/batch", {
    #         "requests": {
    #             "required": True,
    #             "type": list,
    "validator": lambda x, f: InputValidator.validate_numeric_range(len(x), min_val = 1, max_val=10, field_name=f)
    #         },
    #         "options": {
    #             "required": False,
    #             "type": dict
    #         }
    #     })

        validation_middleware.add_param_validation_rule("GET", "/api/v2/sessions/{session_id}", {
    #         "session_id": {
    #             "required": True,
    #             "type": str,
                "validator": lambda x, f: uuid.UUID(x)  # Validate UUID format
    #         }
    #     })

        validation_middleware.add_param_validation_rule("DELETE", "/api/v2/sessions/{session_id}", {
    #         "session_id": {
    #             "required": True,
    #             "type": str,
                "validator": lambda x, f: uuid.UUID(x)  # Validate UUID format
    #         }
    #     })

    #     # Health check endpoint (enhanced with more details)
    app.route("/api/v2/health", methods = ["GET"])
    #     def health_check():
    #         """Health check endpoint with enhanced information."""
    #         try:
    #             # Get system information
    #             import psutil
    process = psutil.Process()

    data = {
    #                 "status": "healthy",
    #                 "version": "2.0.0",
    #                 "api_version": "v2",
    #                 "system": {
    "cpu_percent": psutil.cpu_percent(interval = 0.1),
    #                     "memory": {
                            "total": psutil.virtual_memory().total,
                            "available": psutil.virtual_memory().available,
                            "percent": psutil.virtual_memory().percent,
    #                     },
    #                     "disk": {
                            "total": psutil.disk_usage('/').total,
                            "free": psutil.disk_usage('/').free,
                            "percent": psutil.disk_usage('/').percent,
    #                     }
    #                 },
    #                 "process": {
                        "pid": os.getpid(),
                        "memory_percent": process.memory_percent(),
                        "create_time": datetime.fromtimestamp(process.create_time()).isoformat(),
    #                 }
    #             }
    return success_response(data, request_id = get_request_id())
    #         except ImportError:
    #             # psutil not available, provide basic status
    data = {
    #                 "status": "healthy",
    #                 "version": "2.0.0",
    #                 "api_version": "v2",
    #                 "process": {
                        "pid": os.getpid(),
    #                 }
    #             }
    return success_response(data, request_id = get_request_id())

        # Runtime status endpoint (enhanced)
    app.route("/api/v2/runtime/status", methods = ["GET"])
    #     def runtime_status():
    #         """Get enhanced runtime status information."""
    #         try:
    #             # Get memory usage
    #             import psutil

    process = psutil.Process()
    memory_info = process.memory_info()

    #             # Get active sessions count
    #             with server.session_lock:
    active_sessions = len(server.sessions)
    #                 # Include session details
    session_details = []
    #                 for session_id, session_data in server.sessions.items():
                        session_details.append({
    #                         "session_id": session_id,
                            "created_at": session_data["created_at"].isoformat(),
    #                         "has_result": "result" in session_data
    #                     })

    data = {
    #                 "status": "running",
                    "uptime": (
                        time.time() - server.start_time
    #                     if hasattr(server, "start_time")
    #                     else 0
    #                 ),
    #                 "core_path": server.core_path,
    #                 "memory_usage": {
    #                     "rss": memory_info.rss,
    #                     "vms": memory_info.vms,
                        "percent": process.memory_percent(),
    #                     "shared": memory_info.shared if hasattr(memory_info, 'shared') else 0,
    #                 },
    #                 "sessions": {
    #                     "active_count": active_sessions,
    #                     "details": session_details
    #                 },
    #                 "performance": {
    "cpu_percent": process.cpu_percent(interval = 0.1),
                        "threads": process.num_threads(),
    #                     "open_files": len(process.open_files()) if hasattr(process, 'open_files') else 0,
    #                 }
    #             }
    return success_response(data, request_id = get_request_id())
    #         except ImportError:
    #             # psutil not available, provide basic status
    #             with server.session_lock:
    active_sessions = len(server.sessions)

    data = {
    #                 "status": "running",
                    "uptime": (
                        time.time() - server.start_time
    #                     if hasattr(server, "start_time")
    #                     else 0
    #                 ),
    #                 "core_path": server.core_path,
    #                 "sessions": {
    #                     "active_count": active_sessions
    #                 }
    #             }
    return success_response(data, request_id = get_request_id())

    #     # Execute code endpoint (enhanced with additional options)
    app.route("/api/v2/execute", methods = ["POST"])
    #     def execute_code():
    #         """Execute Noodle code and return results with enhanced information."""
    #         try:
    #             # Get validated data from middleware or validate manually
    #             if hasattr(g, 'validated_data'):
    validated_data = g.validated_data
    code = validated_data.get("code", "")
    options = validated_data.get("options", {})
    environment = validated_data.get("environment", {})
    context = validated_data.get("context", {})
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
    environment = validated_data.get("environment", {})
    context = validated_data.get("context", {})

    #             # Sanitize code input
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

    #             # Prepare JSON input for core-entry-point.py with enhanced context
    input_data = {
    #                 "command": "execute",
    #                 "params": {
    #                     "code": code,
    #                     "environment": environment,
    #                     "context": context
    #                 }
    #             }

    #             # Run the core-entry-point.py with JSON input via stdin
    result = subprocess.run(
    #                 exec_options,
    input = json.dumps(input_data),
    capture_output = True,
    text = True,
    timeout = options.get("timeout", 30),
    #             )
    execution_time = time.time() - start_time

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
    #             output = result.stdout if result.returncode = 0 else result.stderr

    #             # Enhanced response data for v2
    response_data = {
    #                 "session_id": session_id,
    #                 "execution_time": execution_time,
    #                 "exit_code": result.returncode,
    #                 "output": output,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    "success": result.returncode = 0,
    #                 "api_version": "v2",
                    "timestamp": datetime.now().isoformat(),
    #                 "options": options,
    #                 "environment": environment,
    #                 "context": context
    #             }

    #             # Store session information
    #             with server.session_lock:
    server.sessions[session_id] = {
                        "created_at": datetime.now(),
    #                     "code": code,
    #                     "options": options,
    #                     "environment": environment,
    #                     "context": context,
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

        # Session endpoints (enhanced)
    app.route("/api/v2/sessions/<session_id>", methods = ["GET"])
    #     def get_session(session_id: str):
    #         """Get enhanced information about a specific session."""
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

    #                 # Convert datetime objects to ISO format for JSON serialization
    session_copy = session.copy()
    #                 if "created_at" in session_copy:
    session_copy["created_at"] = session_copy["created_at"].isoformat()

    #                 # Add API version information
    session_copy["api_version"] = "v2"

    return success_response(session_copy, request_id = get_request_id())
    #         except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    app.route("/api/v2/sessions", methods = ["GET"])
    #     def list_sessions():
    #         """List all active sessions with enhanced information."""
    #         with server.session_lock:
    sessions = []
    #             for session_id, session_data in server.sessions.items():
    session_info = {
    #                     "session_id": session_id,
                        "created_at": session_data["created_at"].isoformat(),
    #                     "has_result": "result" in session_data,
    #                 }

    #                 # Add additional session metadata
    #                 if "options" in session_data:
    session_info["options"] = session_data["options"]
    #                 if "environment" in session_data:
    session_info["environment"] = session_data["environment"]

                    sessions.append(session_info)

    data = {
    #                 "sessions": sessions,
                    "count": len(server.sessions),
    #                 "api_version": "v2"
    #             }
    return success_response(data, request_id = get_request_id())

    app.route("/api/v2/sessions/<session_id>", methods = ["DELETE"])
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
                        return success_response({
    #                         "message": "Session deleted",
    #                         "session_id": session_id,
    #                         "api_version": "v2"
    }, request_id = get_request_id())
    #                 else:
    return error_response("Session not found", status_code = 404, request_id=get_request_id())
    #         except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    #     # New v2 endpoint: Batch execution
    app.route("/api/v2/execute/batch", methods = ["POST"])
    #     def execute_batch():
    #         """Execute multiple code snippets in a batch request."""
    #         try:
    #             # Get validated data from middleware or validate manually
    #             if hasattr(g, 'validated_data'):
    validated_data = g.validated_data
    batch_requests = validated_data.get("requests", [])
    batch_options = validated_data.get("options", {})
    #             else:
    #                 # Fallback validation if middleware didn't process
    data = request.get_json()
    #                 if not data:
                        raise ValidationError(
    #                         "Invalid JSON data",
    error_code = 1008
    #                     )

    #                 # Validate against schema
    validated_data = batch_execute_schema.validate(data)
    batch_requests = validated_data.get("requests", [])
    batch_options = validated_data.get("options", {})

    results = []

    #             # Create a batch session ID
    batch_id = str(uuid.uuid4())

    #             for i, req in enumerate(batch_requests):
    #                 # Validate each individual request
    #                 try:
    code = req.get("code", "")
    options = {**batch_options, **req.get("options", {})}
    environment = req.get("environment", {})
    context = req.get("context", {})

    #                     if not code:
                            results.append({
    #                             "index": i,
    #                             "success": False,
    #                             "error": "No code provided"
    #                         })
    #                         continue

    #                     # Sanitize code input
    code = InputValidator.sanitize_code_input(code)

    #                 # Create temporary file for the code
    #                 with tempfile.NamedTemporaryFile(
    mode = "w", suffix=".noodle", delete=False
    #                 ) as f:
                        f.write(code)
    temp_file = f.name

    #                 # Prepare execution options
    exec_options = [
    #                     sys.executable,
    #                     server.core_path,
    #                     "--file",
    #                     temp_file,
    #                     "--format",
    #                     "json",
    #                 ]

    #                 # Add additional options
    #                 if options.get("debug", False):
                        exec_options.append("--debug")
    #                 if options.get("verbose", False):
                        exec_options.append("--verbose")

    #                 # Execute the code
    start_time = time.time()

    #                 # Prepare JSON input for core-entry-point.py
    input_data = {
    #                     "command": "execute",
    #                     "params": {
    #                         "code": code,
    #                         "environment": environment,
    #                         "context": context
    #                     }
    #                 }

    #                 try:
    #                     # Run the core-entry-point.py with JSON input via stdin
    result = subprocess.run(
    #                         exec_options,
    input = json.dumps(input_data),
    capture_output = True,
    text = True,
    timeout = options.get("timeout", 30),
    #                     )
    execution_time = time.time() - start_time

    #                     # Parse result
    #                     output = result.stdout if result.returncode = 0 else result.stderr

                        results.append({
    #                         "index": i,
    "success": result.returncode = 0,
    #                         "execution_time": execution_time,
    #                         "exit_code": result.returncode,
    #                         "output": output,
    #                         "stdout": result.stdout,
    #                         "stderr": result.stderr,
    #                     })
    #                 except subprocess.TimeoutExpired:
                        results.append({
    #                         "index": i,
    #                         "success": False,
                            "error": f"Execution timeout after {options.get('timeout', 30)} seconds"
    #                     })
    #                 except Exception as e:
                        results.append({
    #                         "index": i,
    #                         "success": False,
                            "error": str(e)
    #                     })
    #                 finally:
    #                     # Clean up temporary file
    #                     try:
                            os.unlink(temp_file)
    #                     except:
    #                         pass

    #             # Prepare batch response
    batch_response = {
    #                 "batch_id": batch_id,
                    "total_requests": len(batch_requests),
    #                 "successful_requests": sum(1 for r in results if r["success"]),
    #                 "failed_requests": sum(1 for r in results if not r["success"]),
    #                 "results": results,
    #                 "api_version": "v2",
                    "timestamp": datetime.now().isoformat()
    #             }

    return success_response(batch_response, request_id = get_request_id())

    #         except Exception as e:
                logger.error(f"Batch execution error: {type(e).__name__}: {str(e)}")
    return error_response(f"Batch execution failed: {str(e)}", status_code = 500, request_id=get_request_id())