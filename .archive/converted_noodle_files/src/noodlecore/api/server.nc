# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore API Server with DNS Support
# --------------------------------------

# This module provides a working API server implementation for NoodleCore with integrated
# DNS server functionality for home network access using custom domains.

# Features:
- HTTP API server on port 8080 (required by standards)
# - Integrated DNS server on port 53 for domain resolution
# - Home network access via www.noodle.nc, api.noodle.nc, etc.
# - Custom domain resolution for NoodleCore services
# - DNS caching and security measures
# - Concurrent HTTP and DNS server operation

# The API server follows all development standards including proper error handling,
# security, and performance constraints.
# """

import logging
import os
import sys
import time
import uuid
import threading
import json
import datetime
import psutil
import signal
import atexit
import typing.Dict,

# Flask imports
import flask.Flask,
import flask_cors.CORS

# Configure logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
# )
logger = logging.getLogger(__name__)

# Constants following NoodleCore standards
DEFAULT_HOST = "0.0.0.0"  # Required by standards
DEFAULT_PORT = 8080       # Required by standards
DEFAULT_DNS_PORT = 53     # DNS port
MAX_CONCURRENT_CONNECTIONS = 100  # Performance constraint
API_TIMEOUT_SECONDS = 30  # Request timeout
DB_TIMEOUT_SECONDS = 3    # Database query timeout


class APIServerError(Exception)
    #     """Custom exception for API server errors with error codes.

        Following the standards, error codes must be 4-digit format (1001-9999).
    #     """

    #     def __init__(self, message: str, error_code: int = 5000, details: Optional[Dict] = None):
    self.message = message
    self.error_code = error_code
    self.details = details or {}
            super().__init__(message)

    #     def to_dict(self) -> Dict:
    #         """Convert error to dictionary format."""
    #         return {
    #             "error": self.message,
    #             "error_code": self.error_code,
    #             "details": self.details
    #         }


def generate_request_id() -> str:
#     """Generate a UUID v4 request ID as required by standards."""
    return str(uuid.uuid4())


def success_response(data: Any, request_id: str = None) -> Dict:
#     """Create a standardized success response."""
#     return {
#         "success": True,
        "requestId": request_id or generate_request_id(),
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
#         "data": data
#     }


def error_response(error: Any, status_code: int = 500, request_id: str = None) -> Dict:
#     """Create a standardized error response."""
#     if isinstance(error, APIServerError):
response_data = {
#             "success": False,
            "requestId": request_id or generate_request_id(),
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
#             "error": {
#                 "message": error.message,
#                 "code": error.error_code,
#                 "details": error.details
#             }
#         }
#     else:
response_data = {
#             "success": False,
            "requestId": request_id or generate_request_id(),
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
#             "error": {
                "message": str(error),
#                 "code": 5000,
#                 "details": {}
#             }
#         }

response = jsonify(response_data)
response.status_code = status_code
#     return response


class APIServer
    #     """Main API Server class for NoodleCore.

    #     This class implements the HTTP API server following all NoodleCore standards:
    #     - Listens on 0.0.0.0:8080
        - All responses contain requestId field (UUID v4)
    #     - RESTful API paths with version numbers
    #     - Proper error handling with 4-digit error codes
    #     - Security measures including input validation
    #     - Performance constraints enforcement
    #     """

    #     def __init__(self, host: str = DEFAULT_HOST, port: int = DEFAULT_PORT, debug: bool = False):
    #         """Initialize the API Server.

    #         Args:
                host: Host address to bind to (must be 0.0.0.0 per standards)
                port: Port to bind to (must be 8080 per standards)
    #             debug: Enable debug mode
    #         """
    #         # Validate host and port against standards
    #         if host != DEFAULT_HOST:
                logger.warning(f"Host must be {DEFAULT_HOST} per standards, using {DEFAULT_HOST}")
    host = DEFAULT_HOST

    #         if port != DEFAULT_PORT:
                logger.warning(f"Port must be {DEFAULT_PORT} per standards, using {DEFAULT_PORT}")
    port = DEFAULT_PORT

    self.host = host
    self.port = port
    self.debug = debug
    self.start_time = time.time()

    #         # Initialize Flask app
    self.app = Flask(__name__)
            CORS(self.app)

    #         # Track active connections for performance constraints
    self.active_connections = 0
    self.connection_lock = threading.Lock()

    #         # Initialize DNS server
    self.dns_server = None
            self._setup_dns_integration()

    #         # Setup middleware
            self._setup_middleware()

    #         # Register endpoints
            self._register_endpoints()

            logger.info(f"API Server initialized on {host}:{port}")

    #     def _setup_dns_integration(self):
    #         """Setup DNS server integration."""
    #         try:
    #             # Import DNS server
    #             from ..network.dns_server import create_dns_server, DNSServer

    #             # Create DNS server instance
    self.dns_server = create_dns_server(
    host = DEFAULT_HOST,
    port = DEFAULT_DNS_PORT,
    debug = self.debug
    #             )

                logger.info("DNS Server integration initialized")

    #         except ImportError as e:
                logger.warning(f"DNS server not available: {e}")
    self.dns_server = None
    #         except Exception as e:
                logger.warning(f"DNS server initialization failed: {e}")
    self.dns_server = None

    #     def _setup_middleware(self):
    #         """Setup Flask middleware for standardized responses and validation."""

    #         # Request tracking middleware
    #         @self.app.before_request
    #         def _track_connections():
    #             """Track active connections for performance constraints."""
    #             with self.connection_lock:
    #                 if self.active_connections >= MAX_CONCURRENT_CONNECTIONS:
                        raise APIServerError(
    #                         "Server overloaded - too many connections",
    error_code = 3001,  # Server overload error
    details = {"max_connections": MAX_CONCURRENT_CONNECTIONS}
    #                     )
    self.active_connections + = 1

    #         @self.app.after_request
    #         def _cleanup_connections(response):
    #             """Clean up connection tracking."""
    #             with self.connection_lock:
    self.active_connections = math.subtract(max(0, self.active_connections, 1))
    #             return response

    #     def _register_endpoints(self):
    #         """Register API endpoints."""

    #         # Root endpoint
    @self.app.route("/", methods = ["GET"])
    #         def root():
    #             """Root endpoint with API information."""
    #             # Get DNS server status
    #             dns_status = "available" if self.dns_server else "unavailable"
    #             if self.dns_server:
    #                 try:
    dns_info = self.dns_server.get_status()
    dns_status = f"running on port {dns_info.get('port', 53)}"
    #                 except Exception:
    dns_status = "available but not running"

    data = {
    #                 "name": "NoodleCore API Server with DNS Support",
    #                 "version": "2.2.0",
    #                 "status": "running",
    #                 "endpoints": {
    #                     "health": "/api/v1/health",
                        "execute": "/api/v1/execute (POST)",
    #                     "runtime": "/api/v1/runtime/status",
    #                     "versions": "/api/versions",
    #                     "database": "/api/v1/database/status",
    #                     "dns": "/api/v1/dns/status"
    #                 },
    #                 "services": {
    #                     "http_server": {
    #                         "status": "running",
    #                         "host": "0.0.0.0",
    #                         "port": 8080
    #                     },
    #                     "dns_server": {
    #                         "status": dns_status,
    #                         "host": "0.0.0.0",
    #                         "port": 53,
    #                         "domains": [
    #                             "www.noodle.nc",
    #                             "noodle.nc",
    #                             "api.noodle.nc",
    #                             "ide.noodle.nc",
    #                             "dashboard.noodle.nc",
    #                             "app.noodle.nc"
    #                         ]
    #                     }
    #                 },
    #                 "standards": {
    #                     "host": "0.0.0.0",
    #                     "port": 8080,
    #                     "request_id_format": "UUID v4",
    #                     "api_style": "RESTful with versioning",
    #                     "dns_support": True
    #                 }
    #             }
                return jsonify(success_response(data))

    #         # Health check endpoint
    @self.app.route("/api/v1/health", methods = ["GET"])
    #         def health_check():
    #             """Health check endpoint."""
    #             try:
    #                 # Get memory usage
    #                 try:
    process = psutil.Process()
    memory_info = process.memory_info()
    memory_usage = {
                            "rss_mb": memory_info.rss / (1024 * 1024),
                            "vms_mb": memory_info.vms / (1024 * 1024),
                            "percent": process.memory_percent()
    #                     }
    #                 except ImportError:
    memory_usage = {"status": "psutil not available"}

    data = {
    #                     "status": "healthy",
    #                     "version": "2.1.0",
                        "uptime_seconds": time.time() - self.start_time,
    #                     "database_status": "simulated",  # In real implementation, would check actual DB
    #                     "active_connections": self.active_connections,
    #                     "memory_usage": memory_usage,
    #                     "performance_constraints": {
    #                         "max_connections": MAX_CONCURRENT_CONNECTIONS,
    #                         "api_timeout_seconds": API_TIMEOUT_SECONDS,
    #                         "db_timeout_seconds": DB_TIMEOUT_SECONDS
    #                     }
    #                 }
                    return jsonify(success_response(data))
    #             except Exception as e:
                    logger.error(f"Health check failed: {e}")
                    raise APIServerError(
    #                     "Health check failed",
    error_code = 3002,  # Health check error
    details = {"error": str(e)}
    #                 )

    #         # Database status endpoint
    @self.app.route("/api/v1/database/status", methods = ["GET"])
    #         def database_status():
    #             """Get database status and metrics."""
    #             try:
    data = {
    #                     "status": "connected",
    #                     "pool_status": {"active": 5, "idle": 3, "max": 20},
    #                     "query_performance_ms": 12.5,
    #                     "timeout_seconds": DB_TIMEOUT_SECONDS,
    #                     "max_connections": 20  # From standards
    #                 }
                    return jsonify(success_response(data))
    #             except Exception as e:
                    logger.error(f"Database status check failed: {e}")
                    raise APIServerError(
    #                     "Database status check failed",
    error_code = 4001,  # Database error
    details = {"error": str(e)}
    #                 )

            # Execute endpoint (core NoodleCore functionality)
    @self.app.route("/api/v1/execute", methods = ["POST"])
    #         def execute():
    #             """Execute NoodleCore operations."""
    #             try:
    request_data = request.get_json()
    #                 if not request_data:
    raise APIServerError("Request body must be JSON", error_code = 4001)

    #                 # Simulate processing time
                    time.sleep(0.1)

    result = {
                        "operation": request_data.get("operation", "unknown"),
    #                     "status": "completed",
                        "result": f"Processed operation: {request_data.get('operation')}",
    #                     "execution_time_ms": 100
    #                 }

                    return jsonify(success_response(result))
    #             except Exception as e:
                    logger.error(f"Execute operation failed: {e}")
                    raise APIServerError(
    #                     "Execute operation failed",
    error_code = 5001,
    details = {"error": str(e)}
    #                 )

    #         # Runtime status endpoint
    @self.app.route("/api/v1/runtime/status", methods = ["GET"])
    #         def runtime_status():
    #             """Get runtime status."""
    #             try:
    data = {
    #                     "status": "running",
                        "uptime_seconds": time.time() - self.start_time,
    #                     "active_connections": self.active_connections,
    #                     "max_connections": MAX_CONCURRENT_CONNECTIONS,
                        "memory_usage_mb": psutil.Process().memory_info().rss / (1024 * 1024),
                        "cpu_percent": psutil.cpu_percent(),
    #                     "components": {
    #                         "api": "running",
    #                         "database": "simulated",
    #                         "runtime": "running",
    #                         "optimization": "active"
    #                     }
    #                 }
                    return jsonify(success_response(data))
    #             except Exception as e:
                    logger.error(f"Runtime status failed: {e}")
                    raise APIServerError(
    #                     "Runtime status failed",
    error_code = 3003,
    details = {"error": str(e)}
    #                 )

    #         # Versions endpoint
    @self.app.route("/api/versions", methods = ["GET"])
    #         def versions():
    #             """Get API versions."""
                return jsonify(success_response({
    #                 "current_version": "v2",
    #                 "supported_versions": ["v1", "v2"],
    #                 "deprecation_notice": None
    #             }))

    #         # DNS status endpoint
    @self.app.route("/api/v1/dns/status", methods = ["GET"])
    #         def dns_status():
    #             """Get DNS server status."""
    #             try:
    #                 if not self.dns_server:
    return jsonify(error_response("DNS server not available", status_code = 503))

    dns_info = self.dns_server.get_status()
                    return jsonify(success_response(dns_info))
    #             except Exception as e:
                    logger.error(f"DNS status failed: {e}")
                    raise APIServerError(
    #                     "Failed to get DNS status",
    error_code = 6001,
    details = {"error": str(e)}
    #                 )

    #         # IDE-specific endpoints
            self._register_ide_endpoints()

    #         # Error handlers
            @self.app.errorhandler(APIServerError)
    #         def handle_api_server_error(error):
    #             """Handle custom API server errors."""
    return error_response(error, status_code = 500)

            @self.app.errorhandler(404)
    #         def handle_not_found(error):
    #             """Handle 404 errors."""
                return error_response(
    #                 "Endpoint not found",
    status_code = 404
    #             )

            @self.app.errorhandler(405)
    #         def handle_method_not_allowed(error):
    #             """Handle 405 errors."""
                return error_response(
    #                 "Method not allowed",
    status_code = 405
    #             )

            @self.app.errorhandler(500)
    #         def handle_internal_error(error):
    #             """Handle 500 errors."""
                logger.error(f"Internal server error: {error}")
                return error_response(
    #                 "Internal server error",
    status_code = 500
    #             )

    #     def _register_ide_endpoints(self):
    #         """Register IDE-specific endpoints for the Noodle IDE."""

    #         # Enhanced File Operations with Real File System Support
    @self.app.route("/api/v1/ide/files/open", methods = ["POST"])
    #         def open_file():
    #             """Open a file in the IDE with real file system support."""
    #             try:
    request_data = request.get_json()
    file_path = request_data.get("file_path")

    #                 if not file_path:
    raise APIServerError("File path is required", error_code = 4001)

    #                 # Try to read from real file system first
    content = ""
    file_size = 0
    created_at = datetime.datetime.utcnow().isoformat() + "Z"
    modified_at = datetime.datetime.utcnow().isoformat() + "Z"

    #                 try:
    #                     with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
    file_size = len(content)
    #                     # Get file stats
    #                     import os
    stats = os.stat(file_path)
    created_at = datetime.datetime.fromtimestamp(stats.st_ctime).isoformat() + "Z"
    modified_at = datetime.datetime.fromtimestamp(stats.st_mtime).isoformat() + "Z"
                    except (FileNotFoundError, IOError):
    #                     # Fallback to sample content if file doesn't exist
    sample_contents = {
    #                         "welcome": "# Welcome to Noodle IDE\n\n# This is a sample Noodle file\ndef main():\n    print('Hello from Noodle!')\n\nif __name__ == '__main__':\n    main()",
    #                         "main": "# Main entry point\ndef main():\n    print('Noodle application starting...')\n    return True\n\nif __name__ == '__main__':\n    main()",
    #                         "test": "# Test file\ndef test_function():\n    assert True\n    print('Test passed')\n\ndef test_class():\n    class TestClass:\n        def __init__(self):\n            self.value = 42\n    \n    instance = TestClass()\n    assert instance.value == 42\n    print('Class test passed')"
    #                     }
    content = sample_contents.get(file_path.split('.')[0], f"# {file_path}\n# File created: {datetime.datetime.utcnow().isoformat()}\nprint('Hello from {file_path}!')")
    file_size = len(content)

    file_name = file_path.split('/')[-1]
    #                 extension = file_path.split('.')[-1] if '.' in file_path else ''

    #                 # Determine file type and language
    language_map = {
    #                     'nc': 'noodle',
    #                     'py': 'python',
    #                     'js': 'javascript',
    #                     'ts': 'typescript',
    #                     'html': 'html',
    #                     'css': 'css',
    #                     'md': 'markdown',
    #                     'json': 'json',
    #                     'xml': 'xml',
    #                     'yml': 'yaml',
    #                     'yaml': 'yaml',
    #                     'sql': 'sql',
    #                     'java': 'java',
    #                     'cpp': 'cpp',
    #                     'c': 'c',
    #                     'go': 'go',
    #                     'rs': 'rust'
    #                 }
    language = language_map.get(extension.lower(), 'plaintext')

    file_info = {
    #                     "path": file_path,
    #                     "name": file_name,
    #                     "extension": extension,
    #                     "size": file_size,
    #                     "created_at": created_at,
    #                     "modified_at": modified_at,
    #                     "content": content,
    #                     "file_type": language,
    #                     "encoding": "utf-8",
    #                     "language": language,
    #                     "line_count": len(content.split('\n')) if content else 0
    #                 }

                    return jsonify(success_response(file_info))
    #             except Exception as e:
                    logger.error(f"Open file failed: {e}")
                    raise APIServerError(
    #                     "Failed to open file",
    error_code = 5002,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/files/save", methods = ["POST"])
    #         def save_file():
    #             """Save a file in the IDE."""
    #             try:
    request_data = request.get_json()
    file_path = request_data.get("file_path")
    content = request_data.get("content", "")

    #                 if not file_path:
    raise APIServerError("File path is required", error_code = 4001)

    #                 # Simulate file save operation
    save_result = {
    #                     "path": file_path,
    #                     "saved": True,
                        "size": len(content),
                        "saved_at": datetime.datetime.utcnow().isoformat() + "Z"
    #                 }

                    return jsonify(success_response(save_result))
    #             except Exception as e:
                    logger.error(f"Save file failed: {e}")
                    raise APIServerError(
    #                     "Failed to save file",
    error_code = 5003,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/files/create", methods = ["POST"])
    #         def create_file():
    #             """Create a new file."""
    #             try:
    request_data = request.get_json()
    file_path = request_data.get("file_path")
    content = request_data.get("content", "")
    file_type = request_data.get("file_type", "noodle")

    #                 if not file_path:
    raise APIServerError("File path is required", error_code = 4001)

    #                 # Simulate file creation
    file_info = {
    #                     "path": file_path,
                        "name": file_path.split('/')[-1],
    #                     "extension": file_path.split('.')[-1] if '.' in file_path else '',
                        "size": len(content),
                        "created_at": datetime.datetime.utcnow().isoformat() + "Z",
                        "modified_at": datetime.datetime.utcnow().isoformat() + "Z",
    #                     "content": content,
    #                     "file_type": file_type,
    #                     "encoding": "utf-8"
    #                 }

                    return jsonify(success_response(file_info))
    #             except Exception as e:
                    logger.error(f"Create file failed: {e}")
                    raise APIServerError(
    #                     "Failed to create file",
    error_code = 5004,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/files/delete", methods = ["POST"])
    #         def delete_file():
    #             """Delete a file."""
    #             try:
    request_data = request.get_json()
    file_path = request_data.get("file_path")

    #                 if not file_path:
    raise APIServerError("File path is required", error_code = 4001)

    #                 # Simulate file deletion
    delete_result = {
    #                     "path": file_path,
    #                     "deleted": True,
                        "deleted_at": datetime.datetime.utcnow().isoformat() + "Z"
    #                 }

                    return jsonify(success_response(delete_result))
    #             except Exception as e:
                    logger.error(f"Delete file failed: {e}")
                    raise APIServerError(
    #                     "Failed to delete file",
    error_code = 5005,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/files/list", methods = ["POST"])
    #         def list_files():
    #             """List files in directory."""
    #             try:
    request_data = request.get_json()
    directory = request_data.get("directory", "")

    #                 # Mock file listing
    files = [
    #                     {
    #                         "path": f"{directory}/main.nc",
    #                         "name": "main.nc",
    #                         "extension": "nc",
    #                         "size": 512,
    #                         "type": "file"
    #                     },
    #                     {
    #                         "path": f"{directory}/utils.nc",
    #                         "name": "utils.nc",
    #                         "extension": "nc",
    #                         "size": 1024,
    #                         "type": "file"
    #                     },
    #                     {
    #                         "path": f"{directory}/tests",
    #                         "name": "tests",
    #                         "extension": "",
    #                         "size": 0,
    #                         "type": "directory"
    #                     }
    #                 ]

                    return jsonify(success_response({"files": files}))
    #             except Exception as e:
                    logger.error(f"List files failed: {e}")
                    raise APIServerError(
    #                     "Failed to list files",
    error_code = 5006,
    details = {"error": str(e)}
    #                 )

    #         # Code Operations
    @self.app.route("/api/v1/ide/code/completions", methods = ["POST"])
    #         def get_code_completions():
    #             """Get code completions for the IDE."""
    #             try:
    request_data = request.get_json()
    content = request_data.get("content", "")
    position = request_data.get("position", 0)
    file_type = request_data.get("file_type", "noodle")

    #                 # Mock code completions
    completions = [
    #                     {
    #                         "text": "def",
    #                         "type": "keyword",
    #                         "description": "Define function",
    #                         "snippet": "def function_name():\n    pass"
    #                     },
    #                     {
    #                         "text": "class",
    #                         "type": "keyword",
    #                         "description": "Define class",
    #                         "snippet": "class ClassName:\n    pass"
    #                     },
    #                     {
    #                         "text": "if",
    #                         "type": "keyword",
    #                         "description": "Conditional statement",
    #                         "snippet": "if condition:\n    pass"
    #                     },
    #                     {
    #                         "text": "print",
    #                         "type": "function",
    #                         "description": "Print function",
                            "snippet": "print(value)"
    #                     }
    #                 ]

    #                 # Filter completions based on current word
    current_word = ""
    #                 for i in range(position - 1, -1, -1):
    #                     if content[i].isspace():
    #                         break
    current_word = math.add(content[i], current_word)

    filtered_completions = [
    #                     c for c in completions
    #                     if c["text"].startswith(current_word) and c["text"] != current_word
    #                 ]

                    return jsonify(success_response({"completions": filtered_completions[:10]}))
    #             except Exception as e:
                    logger.error(f"Get completions failed: {e}")
                    raise APIServerError(
    #                     "Failed to get completions",
    error_code = 5007,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/code/syntax-highlight", methods = ["POST"])
    #         def get_syntax_highlight():
    #             """Get advanced syntax highlighting for code."""
    #             try:
    request_data = request.get_json()
    content = request_data.get("content", "")
    file_type = request_data.get("file_type", "noodle")

    #                 # Enhanced syntax highlighting with comprehensive token analysis
    #                 import re
    highlights = []
    lines = content.split('\n')

    #                 # Language-specific syntax definitions
    syntax_rules = {
    #                     "python": {
    #                         "keywords": ["def", "class", "if", "elif", "else", "for", "while", "import", "from", "return", "async", "await", "try", "except", "finally", "with", "as", "yield", "break", "continue", "pass", "raise", "lambda", "and", "or", "not", "in", "is", "True", "False", "None"],
    "operators": [" = ", "+", "-", "*", "/", "//", "%", "**", "==", "!=", "<", ">", "<=", ">=", "and", "or", "not"],
    #                         "string_types": ["\"", "'"],
    #                         "comment_markers": ["#"],
                            "numbers": [r'\b\d+(\.\d+)?([eE][+-]?\d+)?\b']
    #                     },
    #                     "noodle": {
    #                         "keywords": ["def", "class", "if", "else", "for", "while", "import", "from", "return", "let", "mut", "async", "await", "match", "case", "pub", "mod", "use", "struct", "enum", "trait", "impl"],
    "operators": [" = ", "+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">=", "&&", "||", "!", ":", ";", "->", "=>", "::"],
    #                         "string_types": ["\"", "'"],
    #                         "comment_markers": ["#", "//"],
                            "numbers": [r'\b\d+(\.\d+)?([eE][+-]?\d+)?\b', r'\b0x[0-9a-fA-F]+\b', r'\b0b[01]+\b']
    #                     },
    #                     "javascript": {
    #                         "keywords": ["function", "var", "let", "const", "if", "else", "for", "while", "return", "break", "continue", "class", "extends", "super", "this", "new", "try", "catch", "finally", "throw", "async", "await", "import", "export", "from"],
    "operators": [" = ", "+", "-", "*", "/", "%", "++", "--", "==", "===", "!=", "!==", "<", ">", "<=", ">=", "&&", "||", "!", "?", ":", "::"],
    #                         "string_types": ["\"", "'", "`"],
    #                         "comment_markers": ["//", "/*"],
                            "numbers": [r'\b\d+(\.\d+)?([eE][+-]?\d+)?\b', r'\b0x[0-9a-fA-F]+\b', r'\b0b[01]+\b']
    #                     }
    #                 }

    #                 # Get syntax rules for the file type, fallback to Python
    rules = syntax_rules.get(file_type.lower(), syntax_rules["python"])

    #                 for line_idx, line in enumerate(lines):
    #                     # Process each line for different token types
    pos = 0

    #                     # Skip empty lines
    #                     if not line.strip():
    #                         continue

    #                     # Process comments
    #                     for comment_marker in rules["comment_markers"]:
    comment_idx = line.find(comment_marker)
    #                         if comment_idx != -1:
                                highlights.append({
    #                                 "start": line_idx * 1000 + comment_idx,
                                    "end": line_idx * 1000 + len(line),
    #                                 "token_type": "comment",
    #                                 "text": line[comment_idx:],
    #                                 "class": "token comment"
    #                             })

    #                     # Process keywords
    #                     for keyword in rules["keywords"]:
    #                         # Use word boundary to avoid partial matches
    pattern = rf'\b{re.escape(keyword)}\b'
    #                         for match in re.finditer(pattern, line):
    #                             # Skip if it's in a comment
    #                             comment_idx = line.find('#' if '#' in rules["comment_markers"] else '//')
    #                             if comment_idx != -1 and match.start() >= comment_idx:
    #                                 continue

                                highlights.append({
                                    "start": line_idx * 1000 + match.start(),
                                    "end": line_idx * 1000 + match.end(),
    #                                 "token_type": "keyword",
                                    "text": match.group(),
    #                                 "class": "token keyword"
    #                             })

    #                     # Process string literals
    #                     for string_type in rules["string_types"]:
    in_string = False
    string_start = math.subtract(, 1)
    #                         for i, char in enumerate(line):
    #                             if char == string_type and (i == 0 or line[i-1] != '\\'):
    #                                 if not in_string:
    in_string = True
    string_start = i
    #                                 else:
    in_string = False
    #                                     if string_start != -1:
    #                                         # Handle escape sequences within strings
    string_content = math.add(line[string_start:i, 1])
    #                                         # Count escape sequences
    escape_count = string_content.count('\\') - string_content.count('\\\\')
    #                                         if escape_count % 2 == 0:  # Even number of escapes = end of string
                                                highlights.append({
    #                                                 "start": line_idx * 1000 + string_start,
    #                                                 "end": line_idx * 1000 + i + 1,
    #                                                 "token_type": "string",
    #                                                 "text": string_content,
    #                                                 "class": "token string"
    #                                             })
    string_start = math.subtract(, 1)

    #                     # Process numbers
    #                     for number_pattern in rules["numbers"]:
    #                         for match in re.finditer(number_pattern, line):
    #                             # Skip if it's in a comment or string
    is_in_comment = False
    #                             comment_idx = line.find('#' if '#' in rules["comment_markers"] else '//')
    #                             if comment_idx != -1 and match.start() >= comment_idx:
    is_in_comment = True

    #                             # Simple string detection
    is_in_string = False
    #                             for string_type in rules["string_types"]:
    quote_count_before = line[:match.start()].count(string_type) - line[:match.start()].count(f'\\{string_type}')
    #                                 if quote_count_before % 2 == 1:  # Odd number of quotes before = in string
    is_in_string = True
    #                                     break

    #                             if not is_in_comment and not is_in_string:
                                    highlights.append({
                                        "start": line_idx * 1000 + match.start(),
                                        "end": line_idx * 1000 + match.end(),
    #                                     "token_type": "number",
                                        "text": match.group(),
    #                                     "class": "token number"
    #                                 })

    #                     # Process operators
    #                     for operator in rules["operators"]:
    #                         # Be careful with multi-character operators
    pattern = re.escape(operator)
    #                         for match in re.finditer(pattern, line):
                                highlights.append({
                                    "start": line_idx * 1000 + match.start(),
                                    "end": line_idx * 1000 + match.end(),
    #                                 "token_type": "operator",
                                    "text": match.group(),
    #                                 "class": "token operator"
    #                             })

    #                 # Add CSS classes for syntax highlighting
    css_rules = {
    #                     "keyword": "color: #569cd6; font-weight: bold;",
    #                     "string": "color: #ce9178;",
    #                     "number": "color: #b5cea8;",
    #                     "comment": "color: #6a9955; font-style: italic;",
    #                     "operator": "color: #d4d4d4;"
    #                 }

                    return jsonify(success_response({
    #                     "highlights": highlights,
    #                     "css_rules": css_rules,
    #                     "language": file_type,
                        "line_count": len(lines),
                        "tokens_count": len(highlights)
    #                 }))
    #             except Exception as e:
                    logger.error(f"Get syntax highlight failed: {e}")
                    raise APIServerError(
    #                     "Failed to get syntax highlight",
    error_code = 5008,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/code/execute", methods = ["POST"])
    #         def execute_code():
    #             """Execute code in the IDE."""
    #             try:
    request_data = request.get_json()
    content = request_data.get("content", "")
    file_type = request_data.get("file_type", "noodle")

    #                 # Simulate code execution
    execution_start = time.time()

    #                 # Simple execution simulation based on content
    output_lines = []
    #                 if "print(" in content:
    #                     # Extract print statements
    #                     for line in content.split('\n'):
    line = line.strip()
    #                         if line.startswith('print('):
    #                             # Extract string from print statement
    start = line.find('(') + 1
    end = line.find(')', start)
    #                             if start > 0 and end > start:
    string_content = line[start:end]
                                    output_lines.append(string_content.replace('"', '').replace("'", ""))

    execution_time = math.subtract(time.time(), execution_start)

    result = {
    #                     "output": '\n'.join(output_lines) if output_lines else "Code executed successfully",
    #                     "error": None,
    #                     "success": True,
    #                     "execution_time": execution_time,
                        "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
    #                 }

                    return jsonify(success_response(result))
    #             except Exception as e:
                    logger.error(f"Execute code failed: {e}")
                    raise APIServerError(
    #                     "Failed to execute code",
    error_code = 5009,
    details = {"error": str(e)}
    #                 )

    #         # Project Operations
    @self.app.route("/api/v1/ide/project/create", methods = ["POST"])
    #         def create_project():
    #             """Create a new project."""
    #             try:
    request_data = request.get_json()
    project_path = request_data.get("project_path")
    name = request_data.get("name")
    description = request_data.get("description", "")

    #                 if not project_path or not name:
    raise APIServerError("Project path and name are required", error_code = 4001)

    #                 # Mock project creation
    project = {
    #                     "name": name,
    #                     "path": project_path,
    #                     "description": description,
                        "created_at": datetime.datetime.utcnow().isoformat() + "Z",
                        "modified_at": datetime.datetime.utcnow().isoformat() + "Z",
    #                     "files": [
    #                         {
    #                             "path": f"{project_path}/main.nc",
    #                             "name": "main.nc",
    #                             "extension": "nc"
    #                         },
    #                         {
    #                             "path": f"{project_path}/README.md",
    #                             "name": "README.md",
    #                             "extension": "md"
    #                         }
    #                     ],
    #                     "settings": {
    #                         "type": "noodle",
    #                         "version": "1.0.0"
    #                     }
    #                 }

                    return jsonify(success_response(project))
    #             except Exception as e:
                    logger.error(f"Create project failed: {e}")
                    raise APIServerError(
    #                     "Failed to create project",
    error_code = 5010,
    details = {"error": str(e)}
    #                 )

    @self.app.route("/api/v1/ide/project/load", methods = ["POST"])
    #         def load_project():
    #             """Load an existing project."""
    #             try:
    request_data = request.get_json()
    project_path = request_data.get("project_path")

    #                 if not project_path:
    raise APIServerError("Project path is required", error_code = 4001)

    #                 # Mock project loading
    project = {
                        "name": project_path.split('/')[-1],
    #                     "path": project_path,
    #                     "description": "Loaded Noodle project",
    #                     "created_at": "2025-10-31T12:00:00Z",
                        "modified_at": datetime.datetime.utcnow().isoformat() + "Z",
    #                     "files": [
    #                         {
    #                             "path": f"{project_path}/main.nc",
    #                             "name": "main.nc",
    #                             "extension": "nc",
    #                             "size": 512
    #                         }
    #                     ],
    #                     "settings": {
    #                         "type": "noodle",
    #                         "version": "1.0.0"
    #                     }
    #                 }

                    return jsonify(success_response(project))
    #             except Exception as e:
                    logger.error(f"Load project failed: {e}")
                    raise APIServerError(
    #                     "Failed to load project",
    error_code = 5011,
    details = {"error": str(e)}
    #                 )

    #         # IDE Status
    @self.app.route("/api/v1/ide/status", methods = ["GET"])
    #         def get_ide_status():
    #             """Get IDE status and statistics."""
    #             try:
    status = {
    #                     "ide_info": {
    #                         "name": "Noodle IDE",
    #                         "version": "1.0.0",
    #                         "mode": "editor",
    #                         "is_running": True,
                            "uptime_seconds": time.time() - self.start_time
    #                     },
    #                     "current_file": {
    #                         "path": None,
    #                         "name": None,
    #                         "has_unsaved_changes": False
    #                     },
    #                     "current_project": {
    #                         "name": None,
    #                         "path": None,
    #                         "files_count": 0
    #                     },
    #                     "statistics": {
    #                         "operations_count": 42,
    #                         "error_count": 0,
    #                         "files_opened": 3,
    #                         "recent_files_count": 5,
    #                         "error_rate": 0.0
    #                     },
    #                     "features": [
    #                         "syntax_highlighting",
    #                         "code_completion",
    #                         "file_management",
    #                         "project_management",
    #                         "code_execution",
    #                         "real_time_editing",
    #                         "error_detection",
    #                         "auto_save"
    #                     ],
    #                     "settings": {
    #                         "auto_save_enabled": True,
    #                         "auto_save_interval": 30,
    #                         "theme": "dark"
    #                     }
    #                 }

                    return jsonify(success_response(status))
    #             except Exception as e:
                    logger.error(f"Get IDE status failed: {e}")
                    raise APIServerError(
    #                     "Failed to get IDE status",
    error_code = 5012,
    details = {"error": str(e)}
    #                 )

    #         # Search files
    @self.app.route("/api/v1/ide/files/search", methods = ["POST"])
    #         def search_files():
    #             """Search for files."""
    #             try:
    request_data = request.get_json()
    query = request_data.get("query")
    directory = request_data.get("directory", "")

    #                 if not query:
    raise APIServerError("Search query is required", error_code = 4001)

    #                 # Mock file search results
    files = [
    #                     {
    #                         "path": f"{directory}/main.nc",
    #                         "name": "main.nc",
    #                         "extension": "nc",
    #                         "size": 512,
    #                         "match_score": 0.9
    #                     },
    #                     {
    #                         "path": f"{directory}/helper.nc",
    #                         "name": "helper.nc",
    #                         "extension": "nc",
    #                         "size": 256,
    #                         "match_score": 0.7
    #                     }
    #                 ]

                    return jsonify(success_response({"files": files}))
    #             except Exception as e:
                    logger.error(f"Search files failed: {e}")
                    raise APIServerError(
    #                     "Failed to search files",
    error_code = 5013,
    details = {"error": str(e)}
    #                 )

    #     def run(self, threaded: bool = True):
    #         """Run both HTTP and DNS servers concurrently.

    #         Args:
    #             threaded: Enable threaded mode (recommended for production)
    #         """
            logger.info(f"Starting NoodleCore Dual Server on {self.host}")
            logger.info(f"HTTP Server: port {self.port}")
            logger.info(f"DNS Server: port {DEFAULT_DNS_PORT}")
            logger.info(f"Debug mode: {self.debug}")
            logger.info(f"Threaded mode: {threaded}")

    #         try:
    #             # Thread control variables
    self.dns_thread = None
    self.running = True

    #             # Start DNS server in a separate thread if available
    #             if self.dns_server:
    #                 def run_dns():
    #                     """DNS server thread function."""
    #                     try:
                            logger.info("Starting DNS server thread")
                            self.dns_server.start()
    #                     except Exception as e:
                            logger.error(f"DNS server thread error: {e}")

    self.dns_thread = threading.Thread(target=run_dns, daemon=True)
                    self.dns_thread.start()
                    logger.info("DNS server started in background thread")

                # Start HTTP server (main thread)
                logger.info("Starting HTTP server on main thread")
                self.app.run(
    host = self.host,
    port = self.port,
    debug = self.debug,
    threaded = threaded
    #             )

    #         except KeyboardInterrupt:
                logger.info("Server stopped by user")
    #         except Exception as e:
                logger.error(f"Server error: {e}")
    #             raise
    #         finally:
    #             # Clean up DNS server
    #             if self.dns_server and self.dns_thread:
                    logger.info("Stopping DNS server")
    #                 try:
                        self.dns_server.stop()
    #                 except Exception as e:
                        logger.error(f"Error stopping DNS server: {e}")


function create_api_server(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT, debug: bool = False)
    #     """Factory function to create an API server instance.

    #     Args:
    #         host: Host address to bind to
    #         port: Port to bind to
    #         debug: Enable debug mode

    #     Returns:
    #         APIServer instance
    #     """
        return APIServer(
    host = host,
    port = port,
    debug = debug
    #     )


function main()
    #     """Main entry point for the API server."""
    #     import argparse

    parser = argparse.ArgumentParser(description="NoodleCore API Server")
        parser.add_argument(
    #         "--host",
    default = DEFAULT_HOST,
    help = f"Host address (default: {DEFAULT_HOST})"
    #     )
        parser.add_argument(
    #         "--port",
    type = int,
    default = DEFAULT_PORT,
    help = f"Port number (default: {DEFAULT_PORT})"
    #     )
        parser.add_argument(
    #         "--debug",
    action = "store_true",
    help = "Enable debug mode"
    #     )
        parser.add_argument(
    #         "--no-threaded",
    action = "store_true",
    help = "Disable threaded mode"
    #     )

    args = parser.parse_args()

    #     # Check environment variables with NOODLE_ prefix
    #     if "NOODLE_ENV" in os.environ:
    debug = os.environ.get("NOODLE_ENV") == "development"
    #         if debug and not args.debug:
                logger.info("Debug mode enabled via NOODLE_ENV")
    args.debug = debug

    #     if "NOODLE_PORT" in os.environ:
    #         try:
    port = int(os.environ.get("NOODLE_PORT"))
    #             if port != DEFAULT_PORT:
                    logger.warning(f"Port must be {DEFAULT_PORT} per standards, ignoring NOODLE_PORT")
    #         except ValueError:
                logger.warning("Invalid NOODLE_PORT value, using default")

    #     # Create and run the server
    #     try:
    server = create_api_server(
    host = args.host,
    port = args.port,
    debug = args.debug
    #         )
    server.run(threaded = not args.no_threaded)
    #     except Exception as e:
            logger.error(f"Failed to start API server: {e}")
            sys.exit(1)


if __name__ == "__main__"
        main()