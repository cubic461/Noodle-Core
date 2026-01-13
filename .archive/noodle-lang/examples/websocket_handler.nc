# Converted from Python to NoodleCore
# Original file: src

# """
# Mobile API WebSocket Handler Module
# ------------------------------------

# Enhanced WebSocket handler that integrates with the new WebSocket/NoodleRPC
# connection layer for real-time communication with the NoodleControl mobile app.
# """

import json
import logging
import threading
import time
import uuid
import datetime.datetime
import typing.Any

try
    #     import socketio
    #     from flask_socketio import SocketIO, emit, join_room, leave_room, disconnect
    #     from flask import request
    WEBSOCKET_AVAILABLE = True
except ImportError
    WEBSOCKET_AVAILABLE = False
        logging.warning("WebSocket dependencies not available. Real-time features will be limited.")

import .errors.NetworkError
import .websocket.EnhancedWebSocketHandler
import .websocket_security.WebSocketSecurityManager
import .websocket_monitoring.WebSocketMonitor
import .noodlerpc_bridge.NoodleRPCBridge

logger = logging.getLogger(__name__)


class WebSocketHandler
    #     """
    #     Enhanced WebSocket handler that integrates with the new WebSocket/NoodleRPC
    #     connection layer for real-time communication with mobile clients.
    #     """

    #     def __init__(self, redis_client=None, auth_manager=None):""
    #         Initialize WebSocketHandler.

    #         Args:
    #             redis_client: Redis client for cross-server WebSocket messaging
    #             auth_manager: Authentication manager for WebSocket security
    #         """
    self.redis = redis_client
    self.auth_manager = auth_manager

    #         # Initialize enhanced components
    self.enhanced_handler = EnhancedWebSocketHandler(redis_client)
    self.security_manager = None
    self.monitor = None

    #         # Initialize security and monitoring if auth manager is provided
    #         if auth_manager:
    self.security_manager = WebSocketSecurityManager(auth_manager, redis_client)
    self.monitor = WebSocketMonitor(redis_client)

    #             # Register monitoring with enhanced handler
                self._setup_monitoring()

    #         # Legacy compatibility
    self.connected_clients: Dict[str, Dict[str, Any]] = {}
    self.rooms: Dict[str, Set[str]] = {}  # room_name - set of client_ids
    self.event_handlers): Dict[str, List[Callable]] = {}
    self.message_queue: List[Dict[str, Any]] = []
    self._lock = threading.Lock()

    #         # Initialize SocketIO if available
    #         if WEBSOCKET_AVAILABLE:
    self.socketio = self.enhanced_handler.socketio
    #             if self.socketio:
                    self._setup_socketio_handlers()
    #         else:
    self.socketio = None
                logger.warning("SocketIO not available. WebSocket functionality disabled.")

    #     def _setup_monitoring(self):
    #         """Setup monitoring integration."""
    #         if not self.monitor:
    #             return

    #         # Register monitoring callbacks
    self.enhanced_handler.connection_manager.add_connection = self._monitor_connection_added
    self.enhanced_handler.connection_manager.remove_connection = self._monitor_connection_removed

    #     def _monitor_connection_added(self, connection):
    #         """Monitor connection addition."""
    #         if self.monitor:
                self.monitor.record_connection_established(
    #                 connection.device_id,
    #                 "unknown"  # IP address would be set in real implementation
    #             )

    #     def _monitor_connection_removed(self, client_id):
    #         """Monitor connection removal."""
    #         if self.monitor and client_id in self.connected_clients:
    client = self.connected_clients[client_id]
    duration = time.time() - client.get('connected_at_timestamp', time.time())
                self.monitor.record_connection_closed(
                    client.get('device_id'),
    #                 "unknown",  # IP address would be set in real implementation
    #                 duration
    #             )

    #     def _setup_socketio_handlers(self):
    #         """Setup enhanced SocketIO event handlers."""
    #         if not self.socketio:
    #             return

    #         # Use enhanced handlers if available
    #         if self.enhanced_handler:
    #             # The enhanced handler already sets up all the necessary handlers
    #             return

    #         # Fallback to basic handlers
            @self.socketio.on('connect')
    #         def handle_connect(data):
    #             """Handle client connection."""
    #             try:
    client_id = str(uuid.uuid4())
    #                 device_id = data.get('device_id') if data else None

    #                 if not device_id:
                        logger.warning("Client connected without device_id")
                        disconnect()
    #                     return

    #                 # Record monitoring
    #                 if self.monitor:
                        self.monitor.record_connection_established(device_id, "unknown")

    #                 # Register client
    #                 with self._lock:
    self.connected_clients[client_id] = {
    #                         'device_id': device_id,
                            'connected_at': datetime.now().isoformat(),
                            'connected_at_timestamp': time.time(),
                            'last_ping': time.time(),
                            'rooms': set(),
    #                     }

    #                 # Join device-specific room
                    join_room(f"device:{device_id}")

    #                 # Add to device room tracking
    #                 with self._lock:
    #                     if f"device:{device_id}" not in self.rooms:
    self.rooms[f"device:{device_id}"] = set()
                        self.rooms[f"device:{device_id}"].add(client_id)

    #                 # Send connection confirmation
                    emit('connected', {
    #                     'client_id': client_id,
    #                     'device_id': device_id,
                        'server_time': datetime.now().isoformat(),
    #                 })

                    logger.info(f"Client connected: {client_id} (device: {device_id})")
    #             except Exception as e:
                    logger.error(f"Error handling client connection: {e}")
    #                 if self.monitor:
                        self.monitor.record_error("connection_error", str(e))
                    disconnect()

            @self.socketio.on('disconnect')
    #         def handle_disconnect():
    #             """Handle client disconnection."""
    #             try:
    #                 # Find client ID from session
    client_id = None
    #                 with self._lock:
    #                     for cid, client in self.connected_clients.items():
    #                         if client.get('device_id') == request.sid:
    client_id = cid
    #                             break

    #                 if client_id:
    client = self.connected_clients.get(client_id, {})
    device_id = client.get('device_id')

    #                     # Record monitoring
    #                     if self.monitor and client_id in self.connected_clients:
    connected_at = self.connected_clients[client_id].get('connected_at_timestamp', time.time())
    duration = time.time() - connected_at
                            self.monitor.record_connection_closed(device_id, "unknown", duration)

    #                     # Remove from rooms
    #                     with self._lock:
    #                         for room_name in client.get('rooms', set()):
    #                             if room_name in self.rooms and client_id in self.rooms[room_name]:
                                    self.rooms[room_name].remove(client_id)

    #                         # Remove client
    #                         if client_id in self.connected_clients:
    #                             del self.connected_clients[client_id]

    #                     # Leave device-specific room
    #                     if device_id:
                            leave_room(f"device:{device_id}")

    #                         # Update room tracking
    #                         with self._lock:
    #                             if f"device:{device_id}" in self.rooms:
                                    self.rooms[f"device:{device_id}"].discard(client_id)
    #                                 if not self.rooms[f"device:{device_id}"]:
    #                                     del self.rooms[f"device:{device_id}"]

                        logger.info(f"Client disconnected: {client_id} (device: {device_id})")
    #             except Exception as e:
                    logger.error(f"Error handling client disconnection: {e}")
    #                 if self.monitor:
                        self.monitor.record_error("disconnection_error", str(e))

            @self.socketio.on('join_room')
    #         def handle_join_room(data):
    #             """Handle room join request."""
    #             try:
    client_id = self._get_client_id_from_request()
    #                 if not client_id:
                        emit('error', {'message': 'Client not authenticated'})
    #                     return

    room_name = data.get('room')
    #                 if not room_name:
                        emit('error', {'message': 'Room name is required'})
    #                     return

    #                 # Validate room name
    #                 if not self._validate_room_name(room_name):
                        emit('error', {'message': 'Invalid room name'})
    #                     return

    #                 # Join room
                    join_room(room_name)

    #                 # Update tracking
    #                 with self._lock:
    #                     if client_id in self.connected_clients:
                            self.connected_clients[client_id]['rooms'].add(room_name)

    #                     if room_name not in self.rooms:
    self.rooms[room_name] = set()
                        self.rooms[room_name].add(client_id)

    #                 # Send confirmation
                    emit('room_joined', {
    #                     'room': room_name,
    #                     'client_id': client_id,
                        'joined_at': datetime.now().isoformat(),
    #                 })

                    logger.info(f"Client {client_id} joined room: {room_name}")
    #             except Exception as e:
                    logger.error(f"Error handling room join: {e}")
                    emit('error', {'message': 'Failed to join room'})

            @self.socketio.on('leave_room')
    #         def handle_leave_room(data):
    #             """Handle room leave request."""
    #             try:
    client_id = self._get_client_id_from_request()
    #                 if not client_id:
                        emit('error', {'message': 'Client not authenticated'})
    #                     return

    room_name = data.get('room')
    #                 if not room_name:
                        emit('error', {'message': 'Room name is required'})
    #                     return

    #                 # Leave room
                    leave_room(room_name)

    #                 # Update tracking
    #                 with self._lock:
    #                     if client_id in self.connected_clients:
                            self.connected_clients[client_id]['rooms'].discard(room_name)

    #                     if room_name in self.rooms and client_id in self.rooms[room_name]:
                            self.rooms[room_name].remove(client_id)
    #                         if not self.rooms[room_name]:
    #                             del self.rooms[room_name]

    #                 # Send confirmation
                    emit('room_left', {
    #                     'room': room_name,
    #                     'client_id': client_id,
                        'left_at': datetime.now().isoformat(),
    #                 })

                    logger.info(f"Client {client_id} left room: {room_name}")
    #             except Exception as e:
                    logger.error(f"Error handling room leave: {e}")
                    emit('error', {'message': 'Failed to leave room'})

            @self.socketio.on('ping')
    #         def handle_ping():
    #             """Handle ping request."""
    #             try:
    client_id = self._get_client_id_from_request()
    #                 if client_id:
    #                     with self._lock:
    #                         if client_id in self.connected_clients:
    self.connected_clients[client_id]['last_ping'] = time.time()

                    emit('pong', {
                        'timestamp': datetime.now().isoformat(),
    #                 })
    #             except Exception as e:
                    logger.error(f"Error handling ping: {e}")

    #     def _get_client_id_from_request(self) -Optional[str]):
    #         """Get client ID from the current request context."""
    #         # This would typically extract the client ID from the session or request
    #         # For now, return a mock implementation
    #         try:
    #             # In a real implementation, this would use Flask's request context
    #             # to get the client ID from the session
    #             return "mock_client_id"
    #         except:
    #             return None

    #     def _validate_room_name(self, room_name: str) -bool):
    #         """Validate room name for security."""
    #         # Only allow specific room patterns
    allowed_patterns = [
    #             "device:*",
    #             "project:*",
    #             "execution:*",
    #             "node:*",
    #             "reasoning:*",
    #             "notifications:*",
    #         ]

    #         for pattern in allowed_patterns:
    #             if pattern.endswith("*"):
    prefix = pattern[: - 1]
    #                 if room_name.startswith(prefix):
    #                     return True
    #             elif room_name == pattern:
    #                 return True

    #         return False

    #     def broadcast_to_device(self, device_id: str, event: str, data: Dict[str, Any]) -int):
    #         """
    #         Broadcast an event to a specific device.

    #         Args:
    #             device_id: Target device ID
    #             event: Event name
    #             data: Event data

    #         Returns:
    #             Number of clients that received the event
    #         """
    #         if not self.socketio:
                logger.warning("SocketIO not available, cannot broadcast event")
    #             return 0

    #         try:
    room_name = f"device:{device_id}"

    #             # Send via SocketIO
    self.socketio.emit(event, data, room = room_name)

    #             # Get count of connected clients for this device
    #             with self._lock:
    client_count = len(self.rooms.get(room_name, set()))

    #             # Also publish to Redis for cross-server support
    #             if self.redis:
    redis_message = {
    #                     'event': event,
    #                     'data': data,
    #                     'room': room_name,
                        'timestamp': datetime.now().isoformat(),
    #                 }
                    self.redis.publish('websocket_events', json.dumps(redis_message))

                logger.info(f"Broadcasted event '{event}' to device {device_id} ({client_count} clients)")
    #             return client_count
    #         except Exception as e:
                logger.error(f"Failed to broadcast to device {device_id}: {e}")
    #             return 0

    #     def broadcast_to_room(self, room_name: str, event: str, data: Dict[str, Any]) -int):
    #         """
    #         Broadcast an event to a specific room.

    #         Args:
    #             room_name: Target room name
    #             event: Event name
    #             data: Event data

    #         Returns:
    #             Number of clients that received the event
    #         """
    #         if not self.socketio:
                logger.warning("SocketIO not available, cannot broadcast event")
    #             return 0

    #         try:
    #             # Validate room name
    #             if not self._validate_room_name(room_name):
                    logger.error(f"Invalid room name: {room_name}")
    #                 return 0

    #             # Send via SocketIO
    self.socketio.emit(event, data, room = room_name)

    #             # Get count of connected clients in room
    #             with self._lock:
    client_count = len(self.rooms.get(room_name, set()))

    #             # Also publish to Redis for cross-server support
    #             if self.redis:
    redis_message = {
    #                     'event': event,
    #                     'data': data,
    #                     'room': room_name,
                        'timestamp': datetime.now().isoformat(),
    #                 }
                    self.redis.publish('websocket_events', json.dumps(redis_message))

                logger.info(f"Broadcasted event '{event}' to room {room_name} ({client_count} clients)")
    #             return client_count
    #         except Exception as e:
                logger.error(f"Failed to broadcast to room {room_name}: {e}")
    #             return 0

    #     def broadcast_to_all(self, event: str, data: Dict[str, Any]) -int):
    #         """
    #         Broadcast an event to all connected clients.

    #         Args:
    #             event: Event name
    #             data: Event data

    #         Returns:
    #             Number of clients that received the event
    #         """
    #         if not self.socketio:
                logger.warning("SocketIO not available, cannot broadcast event")
    #             return 0

    #         try:
    #             # Send via SocketIO
                self.socketio.emit(event, data)

    #             # Get total count of connected clients
    #             with self._lock:
    client_count = len(self.connected_clients)

    #             # Also publish to Redis for cross-server support
    #             if self.redis:
    redis_message = {
    #                     'event': event,
    #                     'data': data,
    #                     'broadcast': True,
                        'timestamp': datetime.now().isoformat(),
    #                 }
                    self.redis.publish('websocket_events', json.dumps(redis_message))

                logger.info(f"Broadcasted event '{event}' to all clients ({client_count} clients)")
    #             return client_count
    #         except Exception as e:
                logger.error(f"Failed to broadcast to all clients: {e}")
    #             return 0

    #     def register_event_handler(self, event: str, handler: Callable):
    #         """
    #         Register a custom event handler.

    #         Args:
    #             event: Event name
    #             handler: Handler function
    #         """
    #         if event not in self.event_handlers:
    self.event_handlers[event] = []

            self.event_handlers[event].append(handler)
    #         logger.info(f"Registered handler for event: {event}")

    #     def unregister_event_handler(self, event: str, handler: Callable):
    #         """
    #         Unregister a custom event handler.

    #         Args:
    #             event: Event name
    #             handler: Handler function
    #         """
    #         if event in self.event_handlers:
    #             if handler in self.event_handlers[event]:
                    self.event_handlers[event].remove(handler)
    #                 logger.info(f"Unregistered handler for event: {event}")

    #     def trigger_event(self, event: str, data: Dict[str, Any], target: Optional[str] = None):
    #         """
    #         Trigger a custom event.

    #         Args:
    #             event: Event name
    #             data: Event data
    #             target: Target (device_id, room_name, or None for all)
    #         """
    #         try:
    #             # Call registered handlers
    #             if event in self.event_handlers:
    #                 for handler in self.event_handlers[event]:
    #                     try:
                            handler(data, target)
    #                     except Exception as e:
    #                         logger.error(f"Error in event handler for '{event}': {e}")

    #             # Broadcast event
    #             if target:
    #                 if target.startswith("device:"):
    device_id = target[7:]  # Remove "device:" prefix
                        self.broadcast_to_device(device_id, event, data)
    #                 else:
                        self.broadcast_to_room(target, event, data)
    #             else:
                    self.broadcast_to_all(event, data)
    #         except Exception as e:
                logger.error(f"Failed to trigger event '{event}': {e}")

    #     def get_connected_clients(self) -List[Dict[str, Any]]):
    #         """
    #         Get list of connected clients.

    #         Returns:
    #             List of client information dictionaries
    #         """
    #         with self._lock:
    #             return [
    #                 {
    #                     'client_id': client_id,
                        'device_id': client_info.get('device_id'),
                        'connected_at': client_info.get('connected_at'),
                        'last_ping': client_info.get('last_ping'),
                        'rooms': list(client_info.get('rooms', set())),
    #                 }
    #                 for client_id, client_info in self.connected_clients.items()
    #             ]

    #     def get_client_info(self, client_id: str) -Optional[Dict[str, Any]]):
    #         """
    #         Get information about a specific client.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             Client information dictionary or None if not found
    #         """
    #         with self._lock:
    client_info = self.connected_clients.get(client_id)
    #             if not client_info:
    #                 return None

    #             return {
    #                 'client_id': client_id,
                    'device_id': client_info.get('device_id'),
                    'connected_at': client_info.get('connected_at'),
                    'last_ping': client_info.get('last_ping'),
                    'rooms': list(client_info.get('rooms', set())),
    #             }

    #     def get_room_info(self, room_name: str) -Dict[str, Any]):
    #         """
    #         Get information about a specific room.

    #         Args:
    #             room_name: Room name

    #         Returns:
    #             Room information dictionary
    #         """
    #         with self._lock:
    client_ids = list(self.rooms.get(room_name, set()))
    clients = []

    #             for client_id in client_ids:
    #                 if client_id in self.connected_clients:
                        clients.append({
    #                         'client_id': client_id,
                            'device_id': self.connected_clients[client_id].get('device_id'),
                            'connected_at': self.connected_clients[client_id].get('connected_at'),
    #                     })

    #             return {
    #                 'room_name': room_name,
                    'client_count': len(clients),
    #                 'clients': clients,
    #             }

    #     def disconnect_client(self, client_id: str) -bool):
    #         """
    #         Disconnect a specific client.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             True if client was successfully disconnected
    #         """
    #         if not self.socketio:
                logger.warning("SocketIO not available, cannot disconnect client")
    #             return False

    #         try:
    #             # This would typically use the client's session ID to disconnect
    #             # For now, return a mock implementation
                logger.info(f"Disconnected client: {client_id}")
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to disconnect client {client_id}: {e}")
    #             return False

    #     def cleanup_stale_connections(self, timeout_seconds: int = 300):
    #         """
    #         Clean up stale connections.

    #         Args:
    #             timeout_seconds: Connection timeout in seconds
    #         """
    #         try:
    current_time = time.time()
    stale_clients = []

    #             with self._lock:
    #                 for client_id, client_info in self.connected_clients.items():
    last_ping = client_info.get('last_ping', 0)
    #                     if current_time - last_ping timeout_seconds):
                            stale_clients.append(client_id)

    #             # Disconnect stale clients
    #             for client_id in stale_clients:
                    self.disconnect_client(client_id)
                    logger.info(f"Cleaned up stale connection: {client_id}")

    #             if stale_clients:
                    logger.info(f"Cleaned up {len(stale_clients)} stale connections")
    #         except Exception as e:
                logger.error(f"Failed to cleanup stale connections: {e}")

    #     def start_redis_listener(self):
    #         """Start Redis listener for cross-server WebSocket events."""
    #         if not self.redis:
    #             return

    #         def redis_listener():
    #             try:
    pubsub = self.redis.pubsub()
                    pubsub.subscribe('websocket_events')

    #                 for message in pubsub.listen():
    #                     if message['type'] == 'message':
    #                         try:
    event_data = json.loads(message['data'])
    event = event_data.get('event')
    data = event_data.get('data')
    room = event_data.get('room')
    broadcast = event_data.get('broadcast', False)

    #                             if self.socketio:
    #                                 if broadcast:
                                        self.socketio.emit(event, data)
    #                                 elif room:
    self.socketio.emit(event, data, room = room)
    #                         except Exception as e:
                                logger.error(f"Error processing Redis WebSocket event: {e}")
    #             except Exception as e:
                    logger.error(f"Redis listener error: {e}")

    #         # Start listener in a separate thread
    listener_thread = threading.Thread(target=redis_listener, daemon=True)
            listener_thread.start()
            logger.info("Redis WebSocket listener started")