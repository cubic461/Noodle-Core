# Converted from Python to NoodleCore
# Original file: src

# """
# Mobile API Server Module
# -------------------------

# Main server module that ties together all mobile API components
# and provides the Flask application with all endpoints.
# """

import functools
import json
import logging
import os
import uuid
import datetime.datetime
import typing.Any

import flask.Flask
import flask_cors.CORS

import ..api.response_format.(
#     ResponseMiddleware,
#     success_response,
#     error_response,
#     timeout_response,
#     get_request_id
# )
import ..api.version_middleware.APIVersionMiddleware
import .auth.AuthManager
import .ide_control.IDEController
import .node_management.NodeManager
import .reasoning_monitor.ReasoningMonitor
import .notifications.NotificationManager
import .websocket_handler.WebSocketHandler
import .errors.(
#     AuthenticationError,
#     AuthorizationError,
#     InvalidRequestError,
#     MobileAPIError,
#     TokenExpiredError,
#     ValidationError,
# )

logger = logging.getLogger(__name__)


class MobileAPIServer
    #     """
    #     Main server class for the Mobile API that integrates all components
    #     and provides the Flask application with all endpoints.
    #     """

    #     def __init__(
    #         self,
    host: str = "0.0.0.0",
    port: int = 8080,
    db_connection = None,
    redis_client = None,
    config: Optional[Dict[str, Any]] = None,
    #     ):""
    #         Initialize MobileAPIServer.

    #         Args:
    #             host: Host address to bind to
    #             port: Port to bind to
    #             db_connection: Database connection
    #             redis_client: Redis client
    #             config: Additional configuration
    #         """
    self.host = host
    self.port = port
    self.db = db_connection
    self.redis = redis_client
    self.config = config or {}

    #         # Initialize Flask app
    self.app = Flask(__name__)
            CORS(self.app)

    #         # Configure Flask app
            self.app.config.update(self.config)

    #         # Initialize response middleware for standardized format
            ResponseMiddleware(self.app)

    #         # Initialize API versioning middleware
            APIVersionMiddleware(self.app)

    #         # Initialize components
    self.auth_manager = AuthManager(db_connection, redis_client)
    self.ide_controller = IDEController()
    self.node_manager = NodeManager()
    self.reasoning_monitor = ReasoningMonitor()
    self.notification_manager = NotificationManager(redis_client)
    self.websocket_handler = WebSocketHandler(redis_client, self.auth_manager)

    #         # Setup routes
            self._setup_routes()

    #         # Setup error handlers
            self._setup_error_handlers()

    #         # Start WebSocket handler
    #         if self.websocket_handler.socketio:
    self.socketio = self.websocket_handler.socketio
    self.socketio.init_app(self.app, cors_allowed_origins = "*")
    #         else:
    self.socketio = None

    #         # Add WebSocket monitoring endpoint
            self._setup_monitoring_routes()

    #     def _setup_routes(self):
    #         """Setup all API routes."""

    #         # Health check endpoint
    @self.app.route("/api/v1/health", methods = ["GET"])
    #         def health_check():
    #             """Health check endpoint."""
    data = {
    #                 "status": "healthy",
    #                 "version": "1.0.0",
    #                 "services": {
    #                     "auth": "ok",
    #                     "ide": "ok",
    #                     "node_management": "ok",
    #                     "reasoning_monitor": "ok",
    #                     "notifications": "ok",
    #                     "websocket": "ok" if self.socketio else "disabled",
    #                 }
    #             }
    return success_response(data, request_id = get_request_id())

    #         # Authentication endpoints
    @self.app.route("/api/v1/auth/register", methods = ["POST"])
    #         def register_device():
    #             """Register a new mobile device."""
    #             try:
    data = request.get_json()
    #                 if not data:
                        raise InvalidRequestError("Invalid JSON data")

    result = self.auth_manager.register_device(data)
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Device registration error: {e}")
    return error_response(MobileAPIError(f"Registration failed: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/auth/refresh", methods = ["POST"])
    #         def refresh_token():
    #             """Refresh access token."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("refreshToken"):
                        raise InvalidRequestError("Refresh token is required")

    result = self.auth_manager.refresh_token(data["refreshToken"])
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Token refresh error: {e}")
    return error_response(MobileAPIError(f"Token refresh failed: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/auth/revoke", methods = ["POST"])
    #         def revoke_device():
    #             """Revoke device access."""
    #             try:
    #                 device_id = request.json.get("deviceId") if request.json else None
    #                 if not device_id:
                        raise InvalidRequestError("Device ID is required")

    success = self.auth_manager.revoke_device(device_id)
    return success_response({"revoked": success}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Device revocation error: {e}")
    return error_response(MobileAPIError(f"Device revocation failed: {e}"), request_id = get_request_id())

    #         # IDE Control endpoints
    @self.app.route("/api/v1/ide/projects", methods = ["GET"])
    #         @self._require_auth
    #         def list_projects():
    #             """List all projects."""
    #             try:
    include_details = request.args.get("includeDetails", "false").lower() == "true"
    projects = self.ide_controller.list_projects(include_details)
    return success_response({"projects": projects}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"List projects error: {e}")
    return error_response(MobileAPIError(f"Failed to list projects: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/projects", methods = ["POST"])
    #         @self._require_auth
    #         def create_project():
    #             """Create a new project."""
    #             try:
    data = request.get_json()
    #                 if not data:
                        raise InvalidRequestError("Invalid JSON data")

    result = self.ide_controller.create_project(
    name = data.get("name", ""),
    description = data.get("description", ""),
    template = data.get("template", "basic")
    #                 )
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Create project error: {e}")
    return error_response(MobileAPIError(f"Failed to create project: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/projects/<project_id>", methods = ["GET"])
    #         @self._require_auth
    #         def get_project(project_id):
    #             """Get project information."""
    #             try:
    project = self.ide_controller.get_project(project_id)
    return success_response(project, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get project error: {e}")
    return error_response(MobileAPIError(f"Failed to get project: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/projects/<project_id>", methods = ["DELETE"])
    #         @self._require_auth
    #         def delete_project(project_id):
    #             """Delete a project."""
    #             try:
    success = self.ide_controller.delete_project(project_id)
    return success_response({"deleted": success}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Delete project error: {e}")
    return error_response(MobileAPIError(f"Failed to delete project: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/projects/<project_id>/files", methods = ["GET"])
    #         @self._require_auth
    #         def list_files(project_id):
    #             """List files in a project."""
    #             try:
    path = request.args.get("path", "")
    recursive = request.args.get("recursive", "false").lower() == "true"
    files = self.ide_controller.list_files(project_id, path, recursive)
    return success_response({"files": files}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"List files error: {e}")
    return error_response(MobileAPIError(f"Failed to list files: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/projects/<project_id>/files/read", methods = ["POST"])
    #         @self._require_auth
    #         def read_file(project_id):
    #             """Read file contents."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("path"):
                        raise InvalidRequestError("File path is required")

    file_content = self.ide_controller.read_file(project_id, data["path"])
    return success_response(file_content, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Read file error: {e}")
    return error_response(MobileAPIError(f"Failed to read file: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/projects/<project_id>/files/write", methods = ["POST"])
    #         @self._require_auth
    #         def write_file(project_id):
    #             """Write file contents."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("path") or "content" not in data:
                        raise InvalidRequestError("File path and content are required")

    result = self.ide_controller.write_file(
    #                     project_id,
    #                     data["path"],
    #                     data["content"],
                        data.get("createIfNotExists", True)
    #                 )
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Write file error: {e}")
    return error_response(MobileAPIError(f"Failed to write file: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/ide/execute", methods = ["POST"])
    #         @self._require_auth
    #         def execute_code():
    #             """Execute code."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("projectId") or not data.get("code"):
                        raise InvalidRequestError("Project ID and code are required")

    result = self.ide_controller.execute_code(
    #                     data["projectId"],
    #                     data["code"],
                        data.get("context")
    #                 )
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Execute code error: {e}")
    return error_response(MobileAPIError(f"Failed to execute code: {e}"), request_id = get_request_id())

    #         # Node Management endpoints
    @self.app.route("/api/v1/net/nodes", methods = ["GET"])
    #         @self._require_auth
    #         def get_nodes():
    #             """Get all nodes in the network."""
    #             try:
    include_metrics = request.args.get("includeMetrics", "false").lower() == "true"
    result = self.node_manager.get_nodes(include_metrics)
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get nodes error: {e}")
    return error_response(MobileAPIError(f"Failed to get nodes: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/net/nodes/<node_id>", methods = ["GET"])
    #         @self._require_auth
    #         def get_node(node_id):
    #             """Get information about a specific node."""
    #             try:
    include_metrics = request.args.get("includeMetrics", "true").lower() == "true"
    node = self.node_manager.get_node(node_id, include_metrics)
    return success_response(node, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get node error: {e}")
    return error_response(MobileAPIError(f"Failed to get node: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/net/nodes/<node_id>/command", methods = ["POST"])
    #         @self._require_auth
    #         def execute_node_command(node_id):
    #             """Execute a command on a node."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("command"):
                        raise InvalidRequestError("Command is required")

    result = self.node_manager.execute_node_command(
    #                     node_id,
    #                     data["command"],
                        data.get("parameters")
    #                 )
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Execute node command error: {e}")
    return error_response(MobileAPIError(f"Failed to execute node command: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/net/topology", methods = ["GET"])
    #         @self._require_auth
    #         def get_topology():
    #             """Get network topology."""
    #             try:
    force_refresh = request.args.get("forceRefresh", "false").lower() == "true"
    topology = self.node_manager.get_topology(force_refresh)
    return success_response(topology, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get topology error: {e}")
    return error_response(MobileAPIError(f"Failed to get topology: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/net/metrics", methods = ["GET"])
    #         @self._require_auth
    #         def get_network_metrics():
    #             """Get network metrics."""
    #             try:
    time_range = request.args.get("timeRange", "1h")
    metrics = self.node_manager.get_network_metrics(time_range)
    return success_response(metrics, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get network metrics error: {e}")
    return error_response(MobileAPIError(f"Failed to get network metrics: {e}"), request_id = get_request_id())

    #         # Reasoning Monitor endpoints
    @self.app.route("/api/v1/reasoning/sessions", methods = ["GET"])
    #         @self._require_auth
    #         def get_reasoning_sessions():
    #             """Get reasoning sessions."""
    #             try:
    include_details = request.args.get("includeDetails", "false").lower() == "true"
    sessions = self.reasoning_monitor.get_reasoning_sessions(include_details)
    return success_response({"sessions": sessions}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get reasoning sessions error: {e}")
    return error_response(MobileAPIError(f"Failed to get reasoning sessions: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/reasoning/sessions/<session_id>", methods = ["GET"])
    #         @self._require_auth
    #         def get_reasoning_session(session_id):
    #             """Get reasoning session information."""
    #             try:
    include_steps = request.args.get("includeSteps", "false").lower() == "true"
    session = self.reasoning_monitor.get_reasoning_session(session_id, include_steps)
    return success_response(session, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get reasoning session error: {e}")
    return error_response(MobileAPIError(f"Failed to get reasoning session: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/reasoning/sessions/<session_id>/steps", methods = ["GET"])
    #         @self._require_auth
    #         def get_reasoning_steps(session_id):
    #             """Get reasoning steps."""
    #             try:
    step_limit = request.args.get("limit", type=int)
    steps = self.reasoning_monitor.get_reasoning_steps(session_id, step_limit)
    return success_response({"steps": steps}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get reasoning steps error: {e}")
    return error_response(MobileAPIError(f"Failed to get reasoning steps: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/reasoning/sessions/<session_id>/visualization", methods = ["GET"])
    #         @self._require_auth
    #         def get_reasoning_visualization(session_id):
    #             """Get reasoning visualization."""
    #             try:
    format_type = request.args.get("format", "json")
    visualization = self.reasoning_monitor.get_reasoning_visualization(session_id, format_type)
    return success_response(visualization, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get reasoning visualization error: {e}")
    return error_response(MobileAPIError(f"Failed to get reasoning visualization: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/reasoning/sessions", methods = ["POST"])
    #         @self._require_auth
    #         def start_reasoning_session():
    #             """Start a reasoning session."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("prompt"):
                        raise InvalidRequestError("Prompt is required")

    result = self.reasoning_monitor.start_reasoning_session(
    #                     data["prompt"],
                        data.get("context"),
                        data.get("model")
    #                 )
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Start reasoning session error: {e}")
    return error_response(MobileAPIError(f"Failed to start reasoning session: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/reasoning/sessions/<session_id>", methods = ["DELETE"])
    #         @self._require_auth
    #         def stop_reasoning_session(session_id):
    #             """Stop a reasoning session."""
    #             try:
    success = self.reasoning_monitor.stop_reasoning_session(session_id)
    return success_response({"stopped": success}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Stop reasoning session error: {e}")
    return error_response(MobileAPIError(f"Failed to stop reasoning session: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/reasoning/sessions/<session_id>/optimize", methods = ["POST"])
    #         @self._require_auth
    #         def optimize_reasoning_model(session_id):
    #             """Optimize reasoning model."""
    #             try:
    data = request.get_json() or {}
    result = self.reasoning_monitor.optimize_model(
    #                     session_id,
                        data.get("optimizationParams")
    #                 )
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Optimize reasoning model error: {e}")
    return error_response(MobileAPIError(f"Failed to optimize reasoning model: {e}"), request_id = get_request_id())

    #         # Notification endpoints
    @self.app.route("/api/v1/notifications", methods = ["GET"])
    #         @self._require_auth
    #         def get_notifications():
    #             """Get notifications for the authenticated device."""
    #             try:
    device_id = g.device_id
    limit = request.args.get("limit", 50, type=int)
    offset = request.args.get("offset", 0, type=int)
    unread_only = request.args.get("unreadOnly", "false").lower() == "true"

    result = self.notification_manager.get_notifications(device_id, limit, offset, unread_only)
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get notifications error: {e}")
    return error_response(MobileAPIError(f"Failed to get notifications: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/notifications/<notification_id>/read", methods = ["POST"])
    #         @self._require_auth
    #         def mark_notification_read(notification_id):
    #             """Mark notification as read."""
    #             try:
    device_id = g.device_id
    success = self.notification_manager.mark_notification_read(device_id, notification_id)
    return success_response({"marked": success}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Mark notification read error: {e}")
    return error_response(MobileAPIError(f"Failed to mark notification as read: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/notifications/read-all", methods = ["POST"])
    #         @self._require_auth
    #         def mark_all_notifications_read():
    #             """Mark all notifications as read."""
    #             try:
    device_id = g.device_id
    count = self.notification_manager.mark_all_notifications_read(device_id)
    return success_response({"marked_count": count}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Mark all notifications read error: {e}")
    return error_response(MobileAPIError(f"Failed to mark all notifications as read: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/notifications/<notification_id>", methods = ["DELETE"])
    #         @self._require_auth
    #         def delete_notification(notification_id):
    #             """Delete notification."""
    #             try:
    device_id = g.device_id
    success = self.notification_manager.delete_notification(device_id, notification_id)
    return success_response({"deleted": success}, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Delete notification error: {e}")
    return error_response(MobileAPIError(f"Failed to delete notification: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/notifications/subscribe", methods = ["POST"])
    #         @self._require_auth
    #         def subscribe_to_events():
    #             """Subscribe to events."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("eventTypes"):
                        raise InvalidRequestError("Event types are required")

    device_id = g.device_id
    result = self.notification_manager.subscribe_to_events(device_id, data["eventTypes"])
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Subscribe to events error: {e}")
    return error_response(MobileAPIError(f"Failed to subscribe to events: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/notifications/unsubscribe", methods = ["POST"])
    #         @self._require_auth
    #         def unsubscribe_from_events():
    #             """Unsubscribe from events."""
    #             try:
    data = request.get_json()
    #                 if not data or not data.get("eventTypes"):
                        raise InvalidRequestError("Event types are required")

    device_id = g.device_id
    result = self.notification_manager.unsubscribe_from_events(device_id, data["eventTypes"])
    return success_response(result, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Unsubscribe from events error: {e}")
    return error_response(MobileAPIError(f"Failed to unsubscribe from events: {e}"), request_id = get_request_id())

    #     def _setup_monitoring_routes(self):
    #         """Setup monitoring endpoints for WebSocket layer."""

    @self.app.route("/api/v1/websocket/stats", methods = ["GET"])
    #         @self._require_auth
    #         def get_websocket_stats():
    #             """Get WebSocket statistics and monitoring data."""
    #             try:
    #                 if not self.websocket_handler.monitor:
    return error_response(MobileAPIError("Monitoring not available", 5000), request_id = get_request_id())

    stats = self.websocket_handler.monitor.get_monitoring_data()
    return success_response(stats, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get WebSocket stats error: {e}")
    return error_response(MobileAPIError(f"Failed to get WebSocket stats: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/websocket/health", methods = ["GET"])
    #         @self._require_auth
    #         def get_websocket_health():
    #             """Get WebSocket health status."""
    #             try:
    #                 if not self.websocket_handler.monitor:
    return error_response(MobileAPIError("Monitoring not available", 5000), request_id = get_request_id())

    health = self.websocket_handler.monitor.check_health()
    return success_response(health, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get WebSocket health error: {e}")
    return error_response(MobileAPIError(f"Failed to get WebSocket health: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/websocket/alerts", methods = ["GET"])
    #         @self._require_auth
    #         def get_websocket_alerts():
    #             """Get WebSocket alerts."""
    #             try:
    #                 if not self.websocket_handler.monitor:
    return error_response(MobileAPIError("Monitoring not available", 5000), request_id = get_request_id())

    include_resolved = request.args.get("includeResolved", "false").lower() == "true"

    #                 if include_resolved:
    alerts = self.websocket_handler.monitor.alert_manager.get_all_alerts()
    #                 else:
    alerts = self.websocket_handler.monitor.alert_manager.get_active_alerts()

                    return success_response({
    #                     "alerts": [alert.to_dict() for alert in alerts],
                        "count": len(alerts)
    }, request_id = get_request_id())
    #             except MobileAPIError as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Get WebSocket alerts error: {e}")
    return error_response(MobileAPIError(f"Failed to get WebSocket alerts: {e}"), request_id = get_request_id())

    @self.app.route("/api/v1/websocket/connections", methods = ["GET"])
    #         @self._require_auth
    #         def get_websocket_connections():
    #             """Get WebSocket connection information."""
    #             try:
    #                 if not self.websocket_handler.enhanced_handler:
                        return self._error_response(MobileAPIError("Enhanced handler not available", 5000))

    connections = self.websocket_handler.enhanced_handler.connection_manager.get_all_connections()
    #                 connection_data = [conn.to_dict() for conn in connections]

                    return self._success_response({
    #                     "connections": connection_data,
                        "count": len(connections)
    #                 })
    #             except MobileAPIError as e:
                    return self._error_response(e)
    #             except Exception as e:
                    logger.error(f"Get WebSocket connections error: {e}")
                    return self._error_response(MobileAPIError(f"Failed to get WebSocket connections: {e}"))

    #     def _setup_error_handlers(self):
    #         """Setup error handlers for the Flask app."""

            @self.app.errorhandler(MobileAPIError)
    #         def handle_mobile_api_error(e):
    #             """Handle MobileAPIError exceptions."""
    return error_response(e, request_id = get_request_id())

            @self.app.errorhandler(404)
    #         def handle_not_found(e):
    #             """Handle 404 errors."""
    return error_response(MobileAPIError("Resource not found", 2003, 404), request_id = get_request_id())

            @self.app.errorhandler(405)
    #         def handle_method_not_allowed(e):
    #             """Handle 405 errors."""
    return error_response(MobileAPIError("Method not allowed", 2001, 405), request_id = get_request_id())

            @self.app.errorhandler(500)
    #         def handle_internal_error(e):
    #             """Handle 500 errors."""
                logger.error(f"Internal server error: {e}")
    return error_response(MobileAPIError("Internal server error", 5000, 500), request_id = get_request_id())

    #     def _require_auth(self, f):
    #         """Decorator to require authentication for a route."""
            functools.wraps(f)
    #         def decorated_function(*args, **kwargs):
    #             try:
    #                 # Get authorization header
    auth_header = request.headers.get("Authorization")
    #                 if not auth_header or not auth_header.startswith("Bearer "):
                        raise AuthenticationError("Authorization header is required")

    token = auth_header[7:]  # Remove "Bearer " prefix

    #                 # Authenticate device
    auth_result = self.auth_manager.authenticate_device(token)

    #                 # Store device info in request context
    g.device_id = auth_result["deviceId"]
    g.device_fingerprint = auth_result["deviceFingerprint"]

                    return f(*args, **kwargs)
                except (AuthenticationError, AuthorizationError, TokenExpiredError) as e:
    return error_response(e, request_id = get_request_id())
    #             except Exception as e:
                    logger.error(f"Authentication error: {e}")
    return error_response(AuthenticationError("Authentication failed"), request_id = get_request_id())

    #         return decorated_function

    #     # Removed _success_response and _error_response methods as they are now replaced by the standardized response format

    #     def run(self, debug: bool = False):
    #         """Run the Mobile API server."""
            logger.info(f"Starting Mobile API server on {self.host}:{self.port}")

    #         if self.socketio:
    #             # Run with SocketIO support
                self.socketio.run(
    #                 self.app,
    host = self.host,
    port = self.port,
    debug = debug,
    allow_unsafe_werkzeug = True
    #             )
    #         else:
    #             # Run without SocketIO support
                self.app.run(
    host = self.host,
    port = self.port,
    debug = debug,
    threaded = True
    #             )

    #     def start(self):
    #         """Start the server in a separate thread."""
    #         import threading

    server_thread = threading.Thread(
    target = self.run,
    kwargs = {"debug": False},
    daemon = True
    #         )
            server_thread.start()
            logger.info(f"Mobile API server started in background thread on {self.host}:{self.port}")
    #         return server_thread