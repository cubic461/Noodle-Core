# Converted from Python to NoodleCore
# Original file: src

# """
# HTTP Server Wrapper for Noodle Core
# ----------------------------------
# Provides a REST API interface for the Noodle Core runtime,
# enabling IDE integration and remote execution.
# """

# Standard library imports
import json
import logging
import os
import subprocess
import sys
import tempfile
import threading
import time
import uuid
import datetime.datetime
import pathlib.Path
import typing.Any

# Configure logging first
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)

# Third-party imports
import flask.Flask
import flask_cors.CORS
import werkzeug.exceptions.BadRequest

# Local imports
import ..api.response_format.(
#     ResponseMiddleware,
#     success_response,
#     error_response,
#     timeout_response,
#     get_request_id
# )
import ..api.version_middleware.APIVersionMiddleware
import ..api.validation_middleware.ValidationMiddleware
import ..api.validation.ValidationError
import ..api.v1.register_v1_endpoints
import ..api.v2.register_v2_endpoints

# SocketIO import with error handling
SocketIO = None
Server = None
try
    #     # Try to import flask_socketio.Server directly
    #     from flask_socketio import Server as SocketIOServer

    Server = SocketIOServer

    #     # Import SocketIO wrapper
    #     from flask_socketio import SocketIO
except ImportError
    #     try:
    #         # Fallback to direct socketio import
    #         import socketio

    Server = socketio.Server
    SocketIO = socketio.SocketIO
    #     except ImportError:
            logger.debug("flask_socketio and socketio not available")
    SocketIO = None
    Server = None
except Exception as e
        logger.debug(f"SocketIO initialization failed: {e}")
    SocketIO = None
    Server = None

# Local imports
import ..error.noodlecorecoreError
import .resource_monitor.noodlecorecoreProfiler
import .resource_monitor.load_profiling_config


class NoodleHTTPServer
    #     """
    #     HTTP Server wrapper for Noodle Core runtime.
    #     Provides REST API endpoints for IDE integration.
    #     """

    #     """
    #     HTTP Server wrapper for Noodle Core runtime.
    #     Provides REST API endpoints for IDE integration.
    #     """

    #     def __init__(
    #         self,
    host: str = "localhost",
    port: int = 8080,
    core_path: Optional[str] = None,
    runtime_config: Optional[Dict] = None,
    #     ):""
    #         Initialize the HTTP server.

    #         Args:
    #             host: Host address to bind to
    #             port: Port to bind to
    #             core_path: Path to the core-entry-point.py script
    #             runtime_config: Runtime configuration dictionary
    #         """
    self.host = host
    self.port = port
    self.core_path = core_path or self._find_core_entry_point()
    self.runtime_config = runtime_config or {}
    self.app = Flask(__name__)
            CORS(self.app)

    #         # Initialize start time for uptime tracking
    self.start_time = time.time()

    #         # Initialize response middleware for standardized format
            ResponseMiddleware(self.app)

    #         # Initialize API versioning middleware
            APIVersionMiddleware(self.app)

    #         # Initialize validation middleware
            ValidationMiddleware(self.app)

    #         # Register versioned endpoints
            register_v1_endpoints(self.app, self)
            register_v2_endpoints(self.app, self)

    #         # SocketIO integration for real-time events (lazy-loaded)
    self._server = None
    self.socketio = None

    #         # Track active execution sessions
    self.sessions: Dict[str, Dict] = {}
    self.session_lock = threading.Lock()

    #         # Setup routes
            self._setup_routes()

    #     def _find_core_entry_point(self) -str):
    #         """Find the core-entry-point.py script in the project."""
    possible_paths = [
    #             "core-entry-point.py",
    #             "src/core-entry-point.py",
    #             "noodle-dev/core-entry-point.py",
    #             "noodle-dev/src/core-entry-point.py",
    #         ]

    #         for path in possible_paths:
    #             if os.path.exists(path):
                    return os.path.abspath(path)

            raise FileNotFoundError(
    #             "Could not find core-entry-point.py. Please specify the path manually."
    #         )

    #     def _setup_routes(self):
    #         """Setup HTTP routes for the API."""

    @self.app.route("/", methods = ["GET"])
    #         def root():
    #             """Root endpoint for basic API info."""
    data = {
    #                 "name": "Noodle Core HTTP Server",
    #                 "version": "1.0.0",
    #                 "status": "running",
    #                 "endpoints": {
    #                     "health": "/api/v1/health",
                        "execute": "/api/v1/execute (POST)",
                        "files": "/api/v1/files (POST, GET)",
    #                     "runtime": "/api/v1/runtime/status",
    #                     "versions": "/api/versions",
    #                 },
    #             }
    return success_response(data, request_id = get_request_id())

    @self.app.route("/api/v1/health", methods = ["GET"])
    #         def health_check():
    #             """Health check endpoint."""
    data = {
    #                 "status": "healthy",
    #                 "version": "1.0.0",
    #             }
    return success_response(data, request_id = get_request_id())

    #         # Legacy health endpoint for backward compatibility
    @self.app.route("/health", methods = ["GET"])
    #         def health_check_legacy():
                """Health check endpoint (legacy)."""
    data = {
    #                 "status": "healthy",
    #                 "version": "1.0.0",
    #             }
    return success_response(data, request_id = get_request_id())

    @self.app.route("/api/v1/runtime/status", methods = ["GET"])
    #         def runtime_status():
    #             """Get runtime status information."""
    #             try:
    #                 # Get memory usage
    #                 import psutil

    process = psutil.Process()
    memory_info = process.memory_info()

    #                 # Get active sessions count
    #                 with self.session_lock:
    active_sessions = len(self.sessions)

    data = {
    #                     "status": "running",
    #                     "memory_usage": {
    #                         "rss": memory_info.rss,
    #                         "vms": memory_info.vms,
                            "percent": process.memory_percent(),
    #                     },
    #                     "active_sessions": active_sessions,
                        "uptime": (
                            time.time() - self.start_time
    #                         if hasattr(self, "start_time")
    #                         else 0
    #                     ),
    #                     "core_path": self.core_path,
    #                 }
    return success_response(data, request_id = get_request_id())
    #             except ImportError:
    #                 # psutil not available, provide basic status
    data = {
    #                     "status": "running",
                        "active_sessions": len(self.sessions),
    #                     "core_path": self.core_path,
    #                 }
    return success_response(data, request_id = get_request_id())

    #         # Legacy runtime status endpoint for backward compatibility
    @self.app.route("/runtime/status", methods = ["GET"])
    #         def runtime_status_legacy():
                """Get runtime status information (legacy)."""
                return runtime_status()

    @self.app.route("/api/v1/execute", methods = ["POST"])
    #         def execute_code():
    #             """Execute Noodle code and return results."""
    #             try:
    data = request.get_json()
    #                 if not data:
    return error_response("Invalid JSON data", status_code = 400, request_id=get_request_id())

    code = data.get("code", "")
    options = data.get("options", {})

    #                 if not code:
    return error_response("No code provided", status_code = 400, request_id=get_request_id())

    #                 # Create unique session ID
    session_id = str(uuid.uuid4())

    #                 # Create temporary file for the code
    #                 with tempfile.NamedTemporaryFile(
    mode = "w", suffix=".noodle", delete=False
    #                 ) as f:
                        f.write(code)
    temp_file = f.name

    #                 # Prepare execution options
    exec_options = [
    #                     sys.executable,
    #                     self.core_path,
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
    input_data = {"command": "execute", "params": {"code": code}}

    #                 # Run the core-entry-point.py with JSON input via stdin
    result = subprocess.run(
    #                     exec_options,
    input = json.dumps(input_data),
    capture_output = True,
    text = True,
    timeout = options.get("timeout", 30),
    #                 )
    execution_time = time.time() - start_time

    #                 # Check if core script returned an error
    #                 if result.returncode != 0:
    #                     try:
    #                         # Try to parse the error response from core script
    error_response_data = json.loads(result.stdout)
    #                         if error_response_data.get("status") == "error":
    #                             # Return the error response with appropriate status code
    return error_response(error_response_data, status_code = 400, request_id=get_request_id())
                        except (json.JSONDecodeError, AttributeError):
    #                         # If we can't parse the error, check stderr for specific error messages
    error_msg = result.stderr.strip()
    #                         if (
    #                             "400 Bad Request" in error_msg
    #                             or "Missing 'command'" in error_msg
    #                         ):
                                return error_response(
    #                                 {
    #                                     "status": "error",
    #                                     "error": "Invalid request format",
    #                                     "details": "Missing required 'command' field",
    #                                 },
    status_code = 400,
    request_id = get_request_id()
    #                             )
    #                         elif "404" in error_msg:
                                return error_response(
    #                                 {"status": "error", "error": "Resource not found"},
    status_code = 404,
    request_id = get_request_id()
    #                             )
    #                         else:
    #                             # Return a generic error with the stderr content
                                return error_response(
    #                                 {
    #                                     "status": "error",
    #                                     "error": "Core script execution failed",
    #                                     "details": result.stderr,
    #                                 },
    status_code = 500,
    request_id = get_request_id()
    #                             )

    #                 # Clean up temporary file
    #                 try:
                        os.unlink(temp_file)
    #                 except:
    #                     pass

    #                 # Parse result
    #                 output = result.stdout if result.returncode = 0 else result.stderr
    response_data = {
    #                     "session_id": session_id,
    #                     "execution_time": execution_time,
    #                     "exit_code": result.returncode,
    #                     "output": output,
    #                     "stdout": result.stdout,
    #                     "stderr": result.stderr,
    "success": result.returncode = 0,
    #                 }

    #                 # Store session information
    #                 with self.session_lock:
    self.sessions[session_id] = {
                            "created_at": datetime.now(),
    #                         "code": code,
    #                         "options": options,
    #                         "result": response_data,
    #                     }

    return success_response(response_data, request_id = get_request_id())

    #             except subprocess.TimeoutExpired:
                    return timeout_response(
    timeout_seconds = options.get("timeout", 30),
    request_id = get_request_id()
    #                 )
    #             except subprocess.CalledProcessError as e:
    #                 # Check if the error contains a 400 Bad Request message
    #                 if "400 Bad Request" in str(e) or "Missing 'command'" in str(e):
                        return error_response(
    #                         {
    #                             "status": "error",
    #                             "error": "Invalid request format",
    #                             "details": "Missing required 'command' field",
    #                         },
    status_code = 400,
    request_id = get_request_id()
    #                     )
    #                 else:
                        logger.error(f"Core script execution error: {str(e)}")
                        return error_response(
    #                         {
    #                             "status": "error",
    #                             "error": "Core script execution failed",
                                "details": str(e),
    #                         },
    status_code = 500,
    request_id = get_request_id()
    #                     )
    #             except ValueError as e:
    #                 # JSON parsing error or other value errors
                    logger.error(f"Value error: {str(e)}")
                    return error_response(
    #                     {
    #                         "status": "error",
    #                         "error": "Invalid request format",
                            "details": str(e),
    #                     },
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             except BadRequest as e:
    #                 # Catch Flask's BadRequest exception specifically
                    logger.error(f"Bad request error: {str(e)}")
                    return error_response(
    #                     {
    #                         "status": "error",
    #                         "error": "Invalid request format",
                            "details": str(e),
    #                     },
    status_code = 400,
    request_id = get_request_id()
    #                 )
    #             except Exception as e:
                    logger.error(f"Execution error: {type(e).__name__}: {str(e)}")
    return error_response(f"Execution failed: {str(e)}", status_code = 500, request_id=get_request_id())

    #         # Legacy execute endpoint for backward compatibility
    @self.app.route("/execute", methods = ["POST"])
    #         def execute_code_legacy():
                """Execute Noodle code and return results (legacy)."""
                return execute_code()

    @self.app.route("/api/v1/sessions/<session_id>", methods = ["GET"])
    #         def get_session(session_id: str):
    #             """Get information about a specific session."""
    #             with self.session_lock:
    session = self.sessions.get(session_id)
    #                 if not session:
    return error_response("Session not found", status_code = 404, request_id=get_request_id())

    return success_response(session, request_id = get_request_id())

    @self.app.route("/api/v1/sessions", methods = ["GET"])
    #         def list_sessions():
    #             """List all active sessions."""
    #             with self.session_lock:
    data = {
                        "sessions": list(self.sessions.keys()),
                        "count": len(self.sessions),
    #                 }
    return success_response(data, request_id = get_request_id())

    @self.app.route("/api/v1/sessions/<session_id>", methods = ["DELETE"])
    #         def delete_session(session_id: str):
    #             """Delete a specific session."""
    #             with self.session_lock:
    #                 if session_id in self.sessions:
    #                     del self.sessions[session_id]
    return success_response({"message": "Session deleted"}, request_id = get_request_id())
    #                 else:
    return error_response("Session not found", status_code = 404, request_id=get_request_id())

    #         # Legacy session endpoints for backward compatibility
    @self.app.route("/sessions/<session_id>", methods = ["GET"])
    #         def get_session_legacy(session_id: str):
                """Get information about a specific session (legacy)."""
                return get_session(session_id)

    @self.app.route("/sessions", methods = ["GET"])
    #         def list_sessions_legacy():
                """List all active sessions (legacy)."""
                return list_sessions()

    @self.app.route("/sessions/<session_id>", methods = ["DELETE"])
    #         def delete_session_legacy(session_id: str):
                """Delete a specific session (legacy)."""
                return delete_session(session_id)

    @self.app.route("/files", methods = ["POST", "GET"])
    #         def file_operations():
                """Handle file operations (create, read, list)."""
    #             try:
    #                 if request.method == "POST":
    data = request.get_json()
    #                     if not data:
    return error_response("Invalid JSON data", status_code = 400, request_id=get_request_id())

    path = data.get("path", "")
    content = data.get("content", "")

    #                     if not path:
    return error_response("Path is required", status_code = 400, request_id=get_request_id())

    #                     # Validate and sanitize path
    #                     from ..api.validation import InputValidator
    #                     try:
    path = InputValidator.validate_file_path(path, "path")
    path = InputValidator.escape_html(path)
    content = InputValidator.escape_html(content)
    #                     except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    #                     # Ensure directory exists
    file_path = Path(path)
    file_path.parent.mkdir(parents = True, exist_ok=True)

    #                     # Write content
    #                     with open(file_path, "w", encoding="utf-8") as f:
                            f.write(content)

                        return success_response(
                            {"message": "File created successfully", "path": str(file_path)},
    request_id = get_request_id()
    #                     )

    #                 elif request.method == "GET":
    #                     # Handle GET requests for file listing or reading
    path_param = request.args.get("path", "")

    #                     if path_param:
    #                         # Validate and sanitize path
    #                         from ..api.validation import InputValidator
    #                         try:
    path_param = InputValidator.validate_file_path(path_param, "path")
    path_param = InputValidator.escape_html(path_param)
    #                         except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    #                     if not path_param:
    #                         # List files in current directory
    #                         try:
    current_dir = Path(".")
    files = []

    #                             for item in current_dir.iterdir():
    #                                 try:
    #                                     if item.is_file():
                                            files.append(
    #                                             {
    #                                                 "name": item.name,
                                                    "path": str(item),
                                                    "size": item.stat().st_size,
                                                    "modified": datetime.fromtimestamp(
                                                        item.stat().st_mtime
                                                    ).isoformat(),
    #                                             }
    #                                         )
    #                                     elif item.is_dir():
                                            files.append(
    #                                             {
    #                                                 "name": item.name,
                                                    "path": str(item),
    #                                                 "type": "directory",
                                                    "modified": datetime.fromtimestamp(
                                                        item.stat().st_mtime
                                                    ).isoformat(),
    #                                             }
    #                                         )
                                    except (PermissionError, OSError) as e:
    #                                     # Skip files/directories we can't access
                                        logger.warning(
    #                                         f"Skipping inaccessible item {item}: {e}"
    #                                     )
    #                                     continue

                                return success_response(
    #                                 {
    #                                     "files": files,
                                        "path": str(current_dir),
                                        "count": len(files),
    #                                 },
    request_id = get_request_id()
    #                             )
                            except (PermissionError, OSError) as e:
                                logger.error(f"Error listing directory: {e}")
                                return error_response(
                                    f"Cannot access directory: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                             )
    #                     else:
    #                         # Handle file reading or directory listing
    #                         try:
    path_obj = Path(path_param)

    #                             if not path_obj.exists():
    return error_response("Path not found", status_code = 404, request_id=get_request_id())

    #                             if path_obj.is_file():
    #                                 # Read file
    #                                 with open(path_obj, "r", encoding="utf-8") as f:
    content = f.read()

                                    return success_response(
                                        {"content": content, "path": str(path_obj)},
    request_id = get_request_id()
    #                                 )
    #                             elif path_obj.is_dir():
    #                                 # List directory contents
    files = []

    #                                 for item in path_obj.iterdir():
    #                                     try:
    #                                         if item.is_file():
                                                files.append(
    #                                                 {
    #                                                     "name": item.name,
                                                        "path": str(item),
                                                        "size": item.stat().st_size,
                                                        "modified": datetime.fromtimestamp(
                                                            item.stat().st_mtime
                                                        ).isoformat(),
    #                                                 }
    #                                             )
    #                                         elif item.is_dir():
                                                files.append(
    #                                                 {
    #                                                     "name": item.name,
                                                        "path": str(item),
    #                                                     "type": "directory",
                                                        "modified": datetime.fromtimestamp(
                                                            item.stat().st_mtime
                                                        ).isoformat(),
    #                                                 }
    #                                             )
                                        except (PermissionError, OSError) as e:
    #                                         # Skip files/directories we can't access
                                            logger.warning(
    #                                             f"Skipping inaccessible item {item}: {e}"
    #                                         )
    #                                         continue

                                    return success_response(
    #                                     {
    #                                         "files": files,
                                            "path": str(path_obj),
                                            "count": len(files),
    #                                     },
    request_id = get_request_id()
    #                                 )

                            except (PermissionError, OSError) as e:
                                logger.error(f"Error accessing path {path_param}: {e}")
                                return error_response(
                                    f"Cannot access path: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                             )

    #             except Exception as e:
                    logger.error(f"File operations error: {str(e)}")
                    return error_response(
                        f"Failed to process file operation: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    @self.app.route("/files/<path:file_path>", methods = ["GET"])
    #         def read_file(file_path: str):
    #             """Read file contents."""
    #             try:
    #                 # Validate and sanitize file path
    #                 from ..api.validation import InputValidator
    #                 try:
    file_path = InputValidator.validate_file_path(file_path, "file_path")
    file_path = InputValidator.escape_html(file_path)
    #                 except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    full_path = Path(file_path)

    #                 if not full_path.exists():
    return error_response("File not found", status_code = 404, request_id=get_request_id())

    #                 with open(full_path, "r", encoding="utf-8") as f:
    content = f.read()

    data = {"content": content, "path": str(full_path)}
    return success_response(data, request_id = get_request_id())

    #             except Exception as e:
                    logger.error(f"File read error: {str(e)}")
                    return error_response(
                        f"Failed to read file: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    @self.app.route("/files/<path:file_path>", methods = ["PUT"])
    #         def update_file(file_path: str):
    #             """Update file contents."""
    #             try:
    data = request.get_json()
    #                 if not data:
    return error_response("Invalid JSON data", status_code = 400, request_id=get_request_id())

    content = data.get("content", "")

    #                 # Validate and sanitize inputs
    #                 from ..api.validation import InputValidator
    #                 try:
    file_path = InputValidator.validate_file_path(file_path, "file_path")
    file_path = InputValidator.escape_html(file_path)
    content = InputValidator.escape_html(content)
    #                 except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    full_path = Path(file_path)

    #                 # Ensure directory exists
    full_path.parent.mkdir(parents = True, exist_ok=True)

    #                 # Write content
    #                 with open(full_path, "w", encoding="utf-8") as f:
                        f.write(content)

                    return success_response(
                        {"message": "File updated successfully", "path": str(full_path)},
    request_id = get_request_id()
    #                 )

    #             except Exception as e:
                    logger.error(f"File update error: {str(e)}")
                    return error_response(
                        f"Failed to update file: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    @self.app.route("/files/<path:file_path>", methods = ["DELETE"])
    #         def delete_file(file_path: str):
    #             """Delete a file."""
    #             try:
    #                 # Validate and sanitize file path
    #                 from ..api.validation import InputValidator
    #                 try:
    file_path = InputValidator.validate_file_path(file_path, "file_path")
    file_path = InputValidator.escape_html(file_path)
    #                 except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    full_path = Path(file_path)

    #                 if not full_path.exists():
    return error_response("File not found", status_code = 404, request_id=get_request_id())

                    full_path.unlink()

                    return success_response(
                        {"message": "File deleted successfully", "path": str(full_path)},
    request_id = get_request_id()
    #                 )

    #             except Exception as e:
                    logger.error(f"File deletion error: {str(e)}")
                    return error_response(
                        f"Failed to delete file: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    @self.app.route("/projects", methods = ["POST"])
    #         def create_project():
    #             """Create a new project."""
    #             try:
    data = request.get_json()
    #                 if not data:
    return error_response("Invalid JSON data", status_code = 400, request_id=get_request_id())

    name = data.get("name", "")
    description = data.get("description", "")

    #                 if not name:
    return error_response("Project name is required", status_code = 400, request_id=get_request_id())

    #                 # Validate and sanitize inputs
    #                 from ..api.validation import InputValidator
    #                 try:
    name = InputValidator.validate_string_length(name, min_length=1, max_length=100, field_name="name")
    name = InputValidator.validate_pattern(name, r'^[a-zA-Z0-9_-]+$', "name")
    name = InputValidator.escape_html(name)

    #                     if description:
    description = InputValidator.validate_string_length(description, max_length=500, field_name="description")
    description = InputValidator.escape_html(description)
    #                 except ValidationError as e:
    return error_response(e.to_dict(), status_code = 400, request_id=get_request_id())

    #                 # Create project directory
    project_path = Path(name)
    project_path.mkdir(exist_ok = True)

    #                 # Create basic project structure
    (project_path / "src").mkdir(exist_ok = True)
    (project_path / "tests").mkdir(exist_ok = True)

    #                 # Create main.noodle file
    main_file = project_path / "main.noodle"
    #                 with open(main_file, "w", encoding="utf-8") as f:
                        f.write(f"# {name}\n")
                        f.write(f"# {description}\n")
                        f.write("# Main Noodle file\n")

                    return success_response(
    #                     {
    #                         "message": "Project created successfully",
    #                         "name": name,
                            "path": str(project_path),
    #                         "files": [
                                str(main_file),
                                str(project_path / "src"),
                                str(project_path / "tests"),
    #                         ],
    #                     },
    request_id = get_request_id()
    #                 )

    #             except Exception as e:
                    logger.error(f"Project creation error: {str(e)}")
                    return error_response(
                        f"Failed to create project: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    @self.app.route("/projects", methods = ["GET"])
    #         def list_projects():
    #             """List all projects in the current directory."""
    #             try:
    projects = []
    current_dir = Path(".")

    #                 for item in current_dir.iterdir():
    #                     if item.is_dir() and not item.name.startswith("."):
    #                         # Check if it's a Noodle project (has main.noodle)
    main_file = item / "main.noodle"
    is_noodle_project = main_file.exists()

                            projects.append(
    #                             {
    #                                 "name": item.name,
                                    "path": str(item),
    #                                 "is_noodle_project": is_noodle_project,
                                    "created_at": datetime.fromtimestamp(
                                        item.stat().st_ctime
                                    ).isoformat(),
    #                             }
    #                         )

    data = {"projects": projects, "count": len(projects)}
    return success_response(data, request_id = get_request_id())

    #             except Exception as e:
                    logger.error(f"Project listing error: {str(e)}")
                    return error_response(
                        f"Failed to list projects: {str(e)}",
    status_code = 500,
    request_id = get_request_id()
    #                 )

    #     def run(self, debug: bool = False):
    #         """Run the HTTP server."""
    self.start_time = time.time()
            logger.info(f"Starting Noodle HTTP server on {self.host}:{self.port}")
            logger.info(f"Core entry point: {self.core_path}")

    #         try:
    self.app.run(host = "0.0.0.0", port=8080, debug=debug, threaded=True)
    #         except KeyboardInterrupt:
                logger.info("Server stopped by user")
    #         except Exception as e:
                logger.error(f"Server error: {str(e)}")
    #             raise

    #     def start(self):
    #         """Start the HTTP server in a separate thread."""
    self.start_time = time.time()
    self.server_thread = threading.Thread(target=self.run, kwargs={"debug": False})
    self.server_thread.daemon = True
            self.server_thread.start()
            logger.info(f"Server started in background thread on {self.host}:{self.port}")

    #     def stop(self):
    #         """Stop the HTTP server."""
    #         if hasattr(self, "server_thread") and self.server_thread.is_alive():
    #             # Note: Flask doesn't have a direct stop method, so we'll just log it
                logger.info("Server stop requested")

    #     def is_running(self):
    #         """Check if the server is running."""
    #         if hasattr(self, "server_thread"):
                return self.server_thread.is_alive()
    #         return False

    #     def _get_socketio(self):
    #         """Lazy-load SocketIO server when needed."""
    #         if self._server is None:
    #             try:
    #                 # Use the properly imported Server and SocketIO classes
    #                 if Server is not None and SocketIO is not None:
    #                     # Initialize SocketIO with the Flask app
    self._server = SocketIO(self.app, cors_allowed_origins="*")

    #                     # Ensure Server has the 'reason' attribute if needed
    #                     if not hasattr(Server, "reason"):
    Server.reason = "Connection failed"
    #                 else:
    #                     # Create a mock SocketIO if imports failed
    #                     class MockSocketIO:
    #                         def emit(self, *args, **kwargs):
    #                             return None

    #                         def on(self, event, handler, *args, **kwargs):
    #                             return None

    #                         def connect(self, *args, **kwargs):
    #                             return None

    self._server = MockSocketIO()
    #             except Exception as e:
                    logger.warning(f"Failed to initialize SocketIO: {e}")

    #                 # Create a minimal fallback
    #                 class FallbackSocketIO:
    #                     def emit(self, *args, **kwargs):
    #                         pass

    #                     def on(self, event, handler, *args, **kwargs):
    #                         pass

    #                     def connect(self, *args, **kwargs):
    #                         pass

    self._server = FallbackSocketIO()
    #         return self._server

    #     def emit(self, *args, **kwargs):
    #         """Delegate emit to SocketIO server."""
            return self._get_socketio().emit(*args, **kwargs)

    #     def on(self, event, handler, *args, **kwargs):
    #         """Delegate on to SocketIO server."""
            return self._get_socketio().on(event, handler, *args, **kwargs)

    #     def connect(self, *args, **kwargs):
    #         """Delegate connect to SocketIO server."""
            return self._get_socketio().connect(*args, **kwargs)


function main()
    #     """Main entry point for the HTTP server."""
    #     import argparse

    parser = argparse.ArgumentParser(description="Noodle Core HTTP Server")
    parser.add_argument("--host", default = "localhost", help="Host address")
    parser.add_argument("--port", type = int, default=8080, help="Port number")
    parser.add_argument("--core-path", help = "Path to core-entry-point.py")
    parser.add_argument("--debug", action = "store_true", help="Enable debug mode")

    args = parser.parse_args()

    #     try:
    server = NoodleHTTPServer(
    host = args.host, port=args.port, core_path=args.core_path
    #         )
    server.run(debug = args.debug)
    #     except Exception as e:
            logger.error(f"Failed to start server: {str(e)}")
            sys.exit(1)


# Create alias for backward compatibility
HTTPServer = NoodleHTTPServer

if __name__ == "__main__"
        main()
