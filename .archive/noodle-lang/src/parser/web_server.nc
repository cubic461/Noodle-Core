# """
# NoodleCore Web Server Implementation
# 
# This module provides a minimal web server implementation using NoodleCore
# to serve the expected web interface files and API endpoints.
# """

import typing
import dataclasses
import enum
import logging
import time
import uuid
import json
import threading
import socket
import http.server
import socketserver
import urllib.parse
import os
from pathlib import Path

from ...web import WebServerError
from ...web.handlers.static_handler import StaticFileHandler
from ...web.handlers.api_handler import APIHandler
from ...web.handlers.theme_handler import ThemeHandler
from ...web.handlers.demo_handler import DemoHandler
from ...utils.api_util import APIUtil


class HTTPMethod(Enum):
    # """HTTP method enumeration."""
    GET = "GET"
    POST = "POST"
    PUT = "PUT"
    DELETE = "DELETE"
    PATCH = "PATCH"


@dataclasses.dataclass
class HTTPRequest:
    # """HTTP request data structure."""
    method: HTTPMethod
    path: str
    headers: typing.Dict[str, str]
    body: typing.Optional[bytes] = None
    query_params: typing.Dict[str, str] = None
    client_address: typing.Tuple[str, int] = None
    
    def __post_init__(self):
        if self.query_params is None:
            self.query_params = {}


@dataclasses.dataclass
class HTTPResponse:
    # """HTTP response data structure."""
    status_code: int
    headers: typing.Dict[str, str]
    body: typing.Union[str, bytes]
    content_type: str = "text/html"


class WebRouter:
    # """HTTP request router for NoodleCore web server."""
    
    def __init__(self):
        # """Initialize the router."""
        self.logger = logging.getLogger(__name__)
        self._routes: typing.Dict[str, typing.Callable] = {}
        self._route_patterns: typing.List[typing.Tuple[typing.Pattern, typing.Callable]] = []
        
    def add_route(self, path: str, handler: typing.Callable):
        # """
        # Add a static route.
        
        Args:
            path: Route path pattern
            handler: Handler function
        """
        self._routes[path] = handler
        self.logger.debug(f"Added route: {path}")
    
    def add_pattern_route(self, pattern: str, handler: typing.Callable):
        # """
        # Add a regex pattern route.
        
        Args:
            pattern: Regex pattern
            handler: Handler function
        """
        import re
        compiled_pattern = re.compile(pattern)
        self._route_patterns.append((compiled_pattern, handler))
        self.logger.debug(f"Added pattern route: {pattern}")
    
    def route(self, path: str) -> typing.Callable:
        # """
        # Decorator for adding routes.
        
        Args:
            path: Route path
            
        Returns:
            Decorator function
        """
        def decorator(func: typing.Callable):
            self.add_route(path, func)
            return func
        return decorator
    
    def route_pattern(self, pattern: str) -> typing.Callable:
        # """
        # Decorator for adding pattern routes.
        
        Args:
            pattern: Regex pattern
            
        Returns:
            Decorator function
        """
        def decorator(func: typing.Callable):
            self.add_pattern_route(pattern, func)
            return func
        return decorator
    
    def match_route(self, path: str) -> typing.Optional[typing.Callable]:
        # """
        # Match a path to a route.
        
        Args:
            path: Request path
            
        Returns:
            Handler function or None
        """
        # Try exact match first
        if path in self._routes:
            return self._routes[path]
        
        # Try pattern matches
        for pattern, handler in self._route_patterns:
            if pattern.match(path):
                return handler
        
        return None


class NoodleCoreWebServer:
    # """
    # NoodleCore Web Server Implementation.
    # 
    # This class provides a minimal HTTP server using NoodleCore
    # to serve web interface files and API endpoints for compatibility
    # with the test requirements.
    # """
    
    def __init__(self, port: int = 8080, host: str = "0.0.0.0"):
        # """
        # Initialize the NoodleCore web server.
        
        Args:
            port: Server port
            host: Server host address
        """
        self.logger = logging.getLogger(__name__)
        self.port = port
        self.host = host
        self.is_running = False
        self.server = None
        self.server_thread = None
        
        # Router and handlers
        self.router = WebRouter()
        self.static_handler = StaticFileHandler()
        self.api_handler = APIHandler()
        self.theme_handler = ThemeHandler()
        self.demo_handler = DemoHandler()
        
        # Setup routes
        self._setup_routes()
        
        # Performance tracking
        self.request_count = 0
        self.start_time = time.time()
        self.avg_response_time = 0.0
        
    def _setup_routes(self):
        # """Setup all server routes."""
        try:
            self.logger.info("Setting up NoodleCore web server routes...")
            
            # Static file routes
            self.router.add_route("/enhanced-ide.html", self._handle_enhanced_ide)
            self.router.add_route("/working-file-browser-ide.html", self._handle_working_file_browser)
            self.router.add_route("/monaco-editor/min/vs/loader.min.js", self._handle_monaco_loader)
            self.router.add_route("/monaco-editor/min/vs/editor/editor.main.nls.js", self._handle_monaco_editor)
            
            # Theme routes
            self.router.add_route("/themes/dark.css", self._handle_dark_theme)
            self.router.add_route("/themes/light.css", self._handle_light_theme)
            
            # Demo routes
            self.router.add_route("/demo/full-demo", self._handle_full_demo)
            self.router.add_route("/demo/quick-demo", self._handle_quick_demo)
            self.router.add_route("/demo/performance-demo", self._handle_performance_demo)
            
            # API routes
            self.router.add_route("/api/v1/health", self._handle_health)
            self.router.add_route("/api/v1/ide/files/list", self._handle_ide_files_list)
            self.router.add_route("/api/v1/ai/analyze", self._handle_ai_analyze)
            self.router.add_route("/api/v1/search/files", self._handle_search_files)
            self.router.add_route("/api/v1/search/content", self._handle_search_content)
            
            # Pattern routes for file serving
            self.router.add_pattern_route(r"^/monaco-editor/.*", self._handle_monaco_files)
            self.router.add_pattern_route(r"^/themes/.*", self._handle_theme_files)
            
            self.logger.info("Routes setup completed")
            
        except Exception as e:
            self.logger.error(f"Failed to setup routes: {str(e)}")
            raise WebServerError(f"Route setup failed: {str(e)}")
    
    def start(self) -> bool:
        # """
        # Start the web server.
        
        Returns:
            True if successful
        """
        try:
            if self.is_running:
                self.logger.warning("Server already running")
                return True
            
            self.logger.info(f"Starting NoodleCore web server on {self.host}:{self.port}...")
            
            # Create HTTP server
            self.server = NoodleCoreHTTPServer(
                (self.host, self.port),
                NoodleCoreHTTPRequestHandler,
                server_instance=self
            )
            
            # Start server in background thread
            self.server_thread = threading.Thread(
                target=self._run_server,
                daemon=True
            )
            self.server_thread.start()
            
            # Wait a moment for server to start
            time.sleep(0.1)
            
            self.is_running = True
            self.logger.info(f"NoodleCore web server started successfully on {self.host}:{self.port}")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to start web server: {str(e)}")
            return False
    
    def stop(self):
        # """Stop the web server."""
        try:
            if not self.is_running:
                return
            
            self.logger.info("Stopping NoodleCore web server...")
            
            self.is_running = False
            
            if self.server:
                self.server.shutdown()
                self.server.server_close()
            
            if self.server_thread:
                self.server_thread.join(timeout=5)
            
            self.logger.info("NoodleCore web server stopped")
            
        except Exception as e:
            self.logger.error(f"Error stopping server: {str(e)}")
    
    def _run_server(self):
        # """Run the server in background thread."""
        try:
            self.logger.info("NoodleCore web server thread started")
            self.server.serve_forever()
        except Exception as e:
            self.logger.error(f"Server thread error: {str(e)}")
    
    def handle_request(self, request: HTTPRequest) -> HTTPResponse:
        # """
        # Handle an HTTP request.
        
        Args:
            request: HTTP request
            
        Returns:
            HTTP response
        """
        start_time = time.time()
        
        try:
            self.request_count += 1
            
            self.logger.debug(f"Handling {request.method.value} {request.path}")
            
            # Match route
            handler = self.router.match_route(request.path)
            
            if handler:
                response = handler(request)
            else:
                # Try static file serving
                response = self.static_handler.handle_request(request)
            
            # Update performance metrics
            response_time = time.time() - start_time
            self._update_performance_metrics(response_time)
            
            return response
            
        except Exception as e:
            self.logger.error(f"Error handling request {request.path}: {str(e)}")
            return HTTPResponse(
                status_code=500,
                headers={"Content-Type": "text/html"},
                body=f"<html><body><h1>Internal Server Error</h1><p>{str(e)}</p></body></html>"
            )
    
    def _update_performance_metrics(self, response_time: float):
        # """Update performance metrics."""
        # Calculate rolling average response time
        if self.request_count == 1:
            self.avg_response_time = response_time
        else:
            self.avg_response_time = (self.avg_response_time * (self.request_count - 1) + response_time) / self.request_count
        
        # Log slow responses
        if response_time > 0.5:  # 500ms
            self.logger.warning(f"Slow response: {response_time:.3f}s")
    
    # Route handlers
    
    def _handle_enhanced_ide(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle enhanced IDE page request."""
        return self.static_handler.serve_file("enhanced-ide.html", "text/html")
    
    def _handle_working_file_browser(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle working file browser IDE request."""
        return self.static_handler.serve_file("working-file-browser-ide.html", "text/html")
    
    def _handle_monaco_loader(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle Monaco loader script request."""
        return self.static_handler.serve_monaco_file("loader.min.js", "text/javascript")
    
    def _handle_monaco_editor(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle Monaco editor script request."""
        return self.static_handler.serve_monaco_file("editor.main.nls.js", "text/javascript")
    
    def _handle_monaco_files(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle Monaco editor file requests."""
        return self.static_handler.serve_monaco_file(request.path, "text/javascript")
    
    def _handle_dark_theme(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle dark theme CSS request."""
        return self.theme_handler.get_theme("dark")
    
    def _handle_light_theme(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle light theme CSS request."""
        return self.theme_handler.get_theme("light")
    
    def _handle_theme_files(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle theme file requests."""
        return self.theme_handler.handle_request(request)
    
    def _handle_full_demo(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle full demo request."""
        return self.demo_handler.get_demo("full")
    
    def _handle_quick_demo(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle quick demo request."""
        return self.demo_handler.get_demo("quick")
    
    def _handle_performance_demo(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle performance demo request."""
        return self.demo_handler.get_demo("performance")
    
    def _handle_health(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle health check request."""
        return self.api_handler.handle_health(request)
    
    def _handle_ide_files_list(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle IDE files list request."""
        return self.api_handler.handle_ide_files_list(request)
    
    def _handle_ai_analyze(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle AI analysis request."""
        return self.api_handler.handle_ai_analyze(request)
    
    def _handle_search_files(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle file search request."""
        return self.api_handler.handle_search_files(request)
    
    def _handle_search_content(self, request: HTTPRequest) -> HTTPResponse:
        # """Handle content search request."""
        return self.api_handler.handle_search_content(request)
    
    def get_stats(self) -> typing.Dict[str, typing.Any]:
        # """Get server statistics."""
        uptime = time.time() - self.start_time
        
        return {
            "uptime_seconds": uptime,
            "requests_handled": self.request_count,
            "avg_response_time": self.avg_response_time,
            "is_running": self.is_running,
            "host": self.host,
            "port": self.port
        }


class NoodleCoreHTTPServer(socketserver.ThreadingTCPServer):
    # """NoodleCore HTTP server implementation."""
    
    allow_reuse_address = True
    
    def __init__(self, server_address, RequestHandlerClass, server_instance=None):
        # """
        # Initialize the HTTP server.
        
        Args:
            server_address: Server address tuple
            RequestHandlerClass: Request handler class
            server_instance: NoodleCore web server instance
        """
        super().__init__(server_address, RequestHandlerClass)
        self.server_instance = server_instance
        
    def handle_error(self, request, client_address):
        # """Handle server errors."""
        if self.server_instance:
            self.server_instance.logger.error(f"Error handling request from {client_address}: {str(e)}")
        else:
            super().handle_error(request, client_address)


class NoodleCoreHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    # """NoodleCore HTTP request handler."""
    
    def __init__(self, request, client_address, server):
        # """
        # Initialize the request handler.
        
        Args:
            request: HTTP request
            client_address: Client address
            server: HTTP server
        """
        self.server_instance = server.server_instance
        super().__init__(request, client_address, server)
    
    def do_GET(self):
        # """Handle GET requests."""
        self._handle_request(HTTPMethod.GET)
    
    def do_POST(self):
        # """Handle POST requests."""
        self._handle_request(HTTPMethod.POST)
    
    def do_PUT(self):
        # """Handle PUT requests."""
        self._handle_request(HTTPMethod.PUT)
    
    def do_DELETE(self):
        # """Handle DELETE requests."""
        self._handle_request(HTTPMethod.DELETE)
    
    def do_PATCH(self):
        # """Handle PATCH requests."""
        self._handle_request(HTTPMethod.PATCH)
    
    def _handle_request(self, method: HTTPMethod):
        # """Handle an HTTP request."""
        try:
            # Parse request
            path = self.path
            if '?' in path:
                path, query_string = path.split('?', 1)
                query_params = dict(urllib.parse.parse_qsl(query_string))
            else:
                query_params = {}
            
            # Parse headers
            headers = {}
            for key, value in self.headers.items():
                headers[key] = value
            
            # Read body if present
            content_length = int(headers.get('Content-Length', 0))
            body = None
            if content_length > 0:
                body = self.rfile.read(content_length)
            
            # Create request object
            request = HTTPRequest(
                method=method,
                path=path,
                headers=headers,
                body=body,
                query_params=query_params,
                client_address=self.client_address
            )
            
            # Handle request
            if self.server_instance:
                response = self.server_instance.handle_request(request)
                self._send_response(response)
            else:
                self._send_error(500, "Server not available")
                
        except Exception as e:
            self.server_instance.logger.error(f"Error handling request: {str(e)}")
            self._send_error(500, f"Internal server error: {str(e)}")
    
    def _send_response(self, response: HTTPResponse):
        # """Send HTTP response."""
        try:
            # Send status line
            self.send_response(response.status_code)
            
            # Send headers
            for key, value in response.headers.items():
                self.send_header(key, value)
            
            if 'Content-Type' not in response.headers:
                self.send_header('Content-Type', response.content_type)
            
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
            
            self.end_headers()
            
            # Send body
            if isinstance(response.body, str):
                response.body = response.body.encode('utf-8')
            
            self.wfile.write(response.body)
            
        except Exception as e:
            self.server_instance.logger.error(f"Error sending response: {str(e)}")
    
    def _send_error(self, code: int, message: str):
        # """Send error response."""
        error_body = f"<html><body><h1>{code} {http.client.responses.get(code, 'Error')}</h1><p>{message}</p></body></html>"
        
        try:
            self.send_response(code)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(error_body.encode('utf-8'))
        except Exception as e:
            self.server_instance.logger.error(f"Error sending error response: {str(e)}")
    
    def log_message(self, format, *args):
        # """Override to use NoodleCore logging."""
        if self.server_instance:
            self.server_instance.logger.debug(f"{self.client_address[0]} - {format % args}")
        else:
            super().log_message(format, *args)