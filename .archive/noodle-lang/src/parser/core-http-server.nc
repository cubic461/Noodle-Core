# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# HTTP Server for Noodle IDE Integration

# This module provides an HTTP server wrapper around the core-entry-point.py
# to enable communication between the Noodle IDE and Noodle Core.
# """
import atexit
import json
import os
import signal
import subprocess
import sys
import threading
import time
import http.server.BaseHTTPRequestHandler
import urllib.parse.parse_qs

# Add src to path to allow imports from noodle
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

# Import CoreAPIHandler from the current directory
import importlib.util

spec = importlib.util.spec_from_file_location("core_entry_point", "core-entry-point.py")
core_entry_point = importlib.util.module_from_spec(spec)
spec.loader.exec_module(core_entry_point)
CoreAPIHandler = core_entry_point.CoreAPIHandler


class NoodleCoreAPIHandler(BaseHTTPRequestHandler)
    #     """HTTP request handler for Noodle Core API."""

    #     def __init__(self, *args, **kwargs):
    self.api_handler = CoreAPIHandler()
            super().__init__(*args, **kwargs)

    #     def _set_response(self, status_code=200, content_type="application/json"):
    #         """Set the response headers."""
            self.send_response(status_code)
            self.send_header("Content-type", content_type)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
            self.end_headers()

    #     def do_OPTIONS(self):
    #         """Handle OPTIONS requests for CORS."""
            self._set_response(200)

    #     def do_POST(self):
    #         """Handle POST requests."""
    #         try:
    #             # Parse the URL
    parsed_path = urlparse(self.path)
    endpoint = parsed_path.path

    #             # Read the request body
    content_length = int(self.headers.get("Content-Length", 0))
    post_data = self.rfile.read(content_length)

    #             # Parse JSON data
    #             try:
    request_data = json.loads(post_data.decode("utf-8"))
    #             except json.JSONDecodeError as e:
                    self._set_response(400)
    response = {"status": "error", "error": f"Invalid JSON: {str(e)}"}
                    self.wfile.write(json.dumps(response).encode("utf-8"))
    #                 return

    #             # Handle the request using the core API handler
    #             if endpoint == "/api/execute":
    response = self.api_handler.handle_request(
    #                     {"command": "execute", "params": request_data}
    #                 )
    #             elif endpoint == "/api/read_file":
    response = self.api_handler.handle_request(
    #                     {"command": "read_file", "params": request_data}
    #                 )
    #             elif endpoint == "/api/write_file":
    response = self.api_handler.handle_request(
    #                     {"command": "write_file", "params": request_data}
    #                 )
    #             elif endpoint == "/api/list_directory":
    response = self.api_handler.handle_request(
    #                     {"command": "list_directory", "params": request_data}
    #                 )
    #             elif endpoint == "/api/get_runtime_state":
    response = self.api_handler.handle_request(
    #                     {"command": "get_runtime_state"}
    #                 )
    #             elif endpoint == "/api/reset_runtime":
    response = self.api_handler.handle_request({"command": "reset_runtime"})
    #             elif endpoint == "/api/workspaces":
    response = self.api_handler.handle_request({"command": "workspaces"})
    #             elif endpoint == "/api/create_workspace":
    response = self.api_handler.handle_request(
    #                     {"command": "create_workspace", "params": request_data}
    #                 )
    #             elif endpoint == "/api/workspace_switch":
    response = self.api_handler.handle_request(
    #                     {"command": "workspace_switch", "params": request_data}
    #                 )
    #             elif endpoint == "/api/workspace_diff":
    response = self.api_handler.handle_request(
    #                     {"command": "workspace_diff", "params": request_data}
    #                 )
    #             elif endpoint == "/api/workspace_merge":
    response = self.api_handler.handle_request(
    #                     {"command": "workspace_merge", "params": request_data}
    #                 )
    #             else:
                    self._set_response(404)
    response = {"status": "error", "error": f"Unknown endpoint: {endpoint}"}
                    self.wfile.write(json.dumps(response).encode("utf-8"))
    #                 return

    #             # Send the response
    #             self._set_response(200 if response.get("status") == "success" else 500)
    self.wfile.write(json.dumps(response, indent = 2).encode("utf-8"))

    #         except Exception as e:
    print(f"Error handling POST request: {e}", file = sys.stderr)
                self._set_response(500)
    response = {"status": "error", "error": str(e)}
                self.wfile.write(json.dumps(response).encode("utf-8"))

    #     def do_GET(self):
    #         """Handle GET requests."""
    #         try:
    #             # Parse the URL
    parsed_path = urlparse(self.path)
    endpoint = parsed_path.path

    #             # Handle GET requests
    #             if endpoint == "/api/health":
                    self._set_response(200)
    response = {"status": "ok", "message": "Noodle Core API is running"}
                    self.wfile.write(json.dumps(response).encode("utf-8"))
    #             elif endpoint == "/api/endpoints":
                    self._set_response(200)
    endpoints = [
    #                     "/api/health",
    #                     "/api/endpoints",
    #                     "/api/execute",
    #                     "/api/read_file",
    #                     "/api/write_file",
    #                     "/api/list_directory",
    #                     "/api/get_runtime_state",
    #                     "/api/reset_runtime",
    #                     "/api/workspaces",
    #                     "/api/create_workspace",
    #                     "/api/workspace_switch",
    #                     "/api/workspace_diff",
    #                     "/api/workspace_merge",
    #                 ]
    response = {"status": "ok", "endpoints": endpoints}
                    self.wfile.write(json.dumps(response).encode("utf-8"))
    #             else:
                    self._set_response(404)
    response = {"status": "error", "error": f"Unknown endpoint: {endpoint}"}
                    self.wfile.write(json.dumps(response).encode("utf-8"))

    #         except Exception as e:
    print(f"Error handling GET request: {e}", file = sys.stderr)
                self._set_response(500)
    response = {"status": "error", "error": str(e)}
                self.wfile.write(json.dumps(response).encode("utf-8"))


class NoodleCoreHTTPServer
    #     """HTTP server for Noodle Core API."""

    #     def __init__(self, host="localhost", port=3000):
    self.host = host
    self.port = port
    self.server = None
    self.process = None

    #     def start(self):
    #         """Start the HTTP server."""
    #         try:
    self.server = HTTPServer((self.host, self.port), NoodleCoreAPIHandler)
                print(f"Noodle Core API server started on http://{self.host}:{self.port}")
                print("Available endpoints:")
                print("  GET  /api/health - Health check")
                print("  GET  /api/endpoints - List all endpoints")
                print("  POST /api/execute - Execute Noodle code")
                print("  POST /api/read_file - Read a file")
                print("  POST /api/write_file - Write a file")
                print("  POST /api/list_directory - List directory contents")
                print("  POST /api/get_runtime_state - Get runtime state")
                print("  POST /api/reset_runtime - Reset runtime")
                print("  POST /api/workspaces - List workspaces")
                print("  POST /api/create_workspace - Create a workspace")
                print("  POST /api/workspace_switch - Switch workspace")
                print("  POST /api/workspace_diff - Get workspace diff")
                print("  POST /api/workspace_merge - Merge workspace")

    #             # Start serving requests
                self.server.serve_forever()

    #         except KeyboardInterrupt:
                print("\nShutting down server...")
                self.stop()
    #         except Exception as e:
    print(f"Error starting server: {e}", file = sys.stderr)
                self.stop()

    #     def stop(self):
    #         """Stop the HTTP server."""
    #         if self.server:
                self.server.shutdown()
                self.server.server_close()
                print("Server stopped")


function main()
    #     """Main entry point for the HTTP server."""
    #     import argparse

    parser = argparse.ArgumentParser(description="Noodle Core HTTP Server")
    parser.add_argument("--host", default = "localhost", help="Host to bind to")
    parser.add_argument("--port", type = int, default=3000, help="Port to bind to")
    args = parser.parse_args()

    #     # Create and start the server
    server = NoodleCoreHTTPServer(host=args.host, port=args.port)

    #     # Register cleanup function
        atexit.register(server.stop)

    #     try:
            server.start()
    #     except KeyboardInterrupt:
            print("\nShutting down server...")
            server.stop()


if __name__ == "__main__"
        main()
