# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Real-time Collaboration Features - WebSocket-based real-time collaboration
# """

import asyncio
import logging
import time
import json
import uuid
import websockets
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import abc.ABC,

import .collaborative_environment.(
#     CollaborativeEnvironment, User, Change, Conflict,
#     ChangeType, CollaborationRole
# )

logger = logging.getLogger(__name__)


class MessageType(Enum)
    #     """Types of real-time messages"""
    USER_JOINED = "user_joined"
    USER_LEFT = "user_left"
    CHANGE_APPLIED = "change_applied"
    CURSOR_UPDATED = "cursor_updated"
    SELECTION_UPDATED = "selection_updated"
    CONFLICT_DETECTED = "conflict_detected"
    CONFLICT_RESOLVED = "conflict_resolved"
    FILE_OPENED = "file_opened"
    FILE_CLOSED = "file_closed"
    TYPING_STARTED = "typing_started"
    TYPING_STOPPED = "typing_stopped"
    PRESENCE_UPDATE = "presence_update"
    SESSION_CREATED = "session_created"
    SESSION_UPDATED = "session_updated"
    ERROR = "error"


# @dataclass
class CollaborationMessage
    #     """Real-time collaboration message"""
    #     message_id: str
    #     message_type: MessageType
    #     session_id: str
    #     user_id: str
    #     timestamp: float
    data: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -> Dict[str, Any]:
    #         return {
    #             'message_id': self.message_id,
    #             'message_type': self.message_type.value,
    #             'session_id': self.session_id,
    #             'user_id': self.user_id,
    #             'timestamp': self.timestamp,
    #             'data': self.data
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'CollaborationMessage':
            return cls(
    message_id = data['message_id'],
    message_type = MessageType(data['message_type']),
    session_id = data['session_id'],
    user_id = data['user_id'],
    timestamp = data['timestamp'],
    data = data.get('data', {})
    #         )


# @dataclass
class ConnectionInfo
    #     """WebSocket connection information"""
    #     connection_id: str
    #     websocket: Any
    #     user_id: str
    #     session_id: str
    #     connected_at: float
    last_ping: float = field(default_factory=time.time)

    #     def to_dict(self) -> Dict[str, Any]:
    #         return {
    #             'connection_id': self.connection_id,
    #             'user_id': self.user_id,
    #             'session_id': self.session_id,
    #             'connected_at': self.connected_at,
    #             'last_ping': self.last_ping
    #         }


class RealtimeCollaborationServer
    #     """Real-time collaboration server using WebSockets"""

    #     def __init__(self, collaborative_env: CollaborativeEnvironment,
    host: str = "localhost", port: int = 8765):
    #         """
    #         Initialize real-time collaboration server

    #         Args:
    #             collaborative_env: Collaborative environment instance
    #             host: Server host
    #             port: Server port
    #         """
    self.collaborative_env = collaborative_env
    self.host = host
    self.port = port
    self.connections: Dict[str, ConnectionInfo] = {}
    self.session_connections: Dict[str, Set[str]] = math.subtract({}  # session_id, > connection_ids)
    self.user_connections: Dict[str, Set[str]] = math.subtract({}  # user_id, > connection_ids)

    #         # Message handlers
    self.message_handlers = {
    #             MessageType.CHANGE_APPLIED: self._handle_change_applied,
    #             MessageType.CURSOR_UPDATED: self._handle_cursor_updated,
    #             MessageType.SELECTION_UPDATED: self._handle_selection_updated,
    #             MessageType.TYPING_STARTED: self._handle_typing_started,
    #             MessageType.TYPING_STOPPED: self._handle_typing_stopped,
    #             MessageType.PRESENCE_UPDATE: self._handle_presence_update
    #         }

    #         # Event handlers
    self.event_handlers = {}

    #         # Register event handlers with collaborative environment
            self.collaborative_env.register_event_handler('user_joined', self._on_user_joined)
            self.collaborative_env.register_event_handler('user_left', self._on_user_left)
            self.collaborative_env.register_event_handler('change_applied', self._on_change_applied)
            self.collaborative_env.register_event_handler('conflict_detected', self._on_conflict_detected)

    #         # Background tasks
    self.ping_interval = 30  # seconds
    self.cleanup_interval = 300  # seconds

    #     async def start_server(self):
    #         """Start the WebSocket server"""
            logger.info(f"Starting real-time collaboration server on {self.host}:{self.port}")

    #         # Start background tasks
            asyncio.create_task(self._ping_loop())
            asyncio.create_task(self._cleanup_loop())

    #         # Start WebSocket server
    #         async with websockets.serve(
    #             self._handle_websocket_connection,
    #             self.host,
    #             self.port
    #         ):
                logger.info(f"Real-time collaboration server started on {self.host}:{self.port}")
                await asyncio.Future()  # Run forever

    #     async def _handle_websocket_connection(self, websocket, path):
    #         """Handle incoming WebSocket connection"""
    connection_id = str(uuid.uuid4())

    #         try:
    #             # Wait for authentication message
    auth_message = await websocket.recv()
    auth_data = json.loads(auth_message)

    #             # Validate authentication
    #             if not await self._authenticate_connection(auth_data):
                    await websocket.send(json.dumps({
    #                     'type': 'error',
    #                     'message': 'Authentication failed'
    #                 }))
    #                 return

    user_id = auth_data['user_id']
    session_id = auth_data['session_id']

    #             # Create connection info
    connection_info = ConnectionInfo(
    connection_id = connection_id,
    websocket = websocket,
    user_id = user_id,
    session_id = session_id,
    connected_at = time.time()
    #             )

    self.connections[connection_id] = connection_info

    #             # Update session and user connections
    #             if session_id not in self.session_connections:
    self.session_connections[session_id] = set()
                self.session_connections[session_id].add(connection_id)

    #             if user_id not in self.user_connections:
    self.user_connections[user_id] = set()
                self.user_connections[user_id].add(connection_id)

    #             # Join collaborative session
    session = await self.collaborative_env.get_session(session_id)
    #             if session:
    #                 # Send session state to new user
                    await self._send_session_state(connection_id, session)

    #                 # Notify other users
                    await self._broadcast_to_session(session_id, CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.USER_JOINED,
    session_id = session_id,
    user_id = user_id,
    timestamp = time.time(),
    data = {
    #                         'user': session.participants.get(user_id).to_dict() if user_id in session.participants else None
    #                     }
    ), exclude_connection_id = connection_id)

                logger.info(f"User {user_id} connected to session {session_id}")

    #             # Handle messages from this connection
                await self._handle_connection_messages(connection_id)

    #         except websockets.exceptions.ConnectionClosed:
                logger.info(f"Connection {connection_id} closed")
    #         except Exception as e:
                logger.error(f"Error handling WebSocket connection: {e}")
    #         finally:
    #             # Clean up connection
                await self._cleanup_connection(connection_id)

    #     async def _authenticate_connection(self, auth_data: Dict[str, Any]) -> bool:
    #         """
    #         Authenticate connection

    #         Args:
    #             auth_data: Authentication data

    #         Returns:
    #             Authentication success
    #         """
    #         # This would validate against your authentication system
    #         # For now, just check required fields
    required_fields = ['user_id', 'session_id', 'token']

    #         for field in required_fields:
    #             if field not in auth_data:
    #                 return False

            # Validate token (simplified)
    #         # In practice, this would validate JWT or other token
    return auth_data.get('token') = = 'valid_token'

    #     async def _send_session_state(self, connection_id: str, session):
    #         """Send current session state to new connection"""
    connection = self.connections.get(connection_id)
    #         if not connection:
    #             return

    #         try:
    #             # Send session info
    session_message = CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.SESSION_CREATED,
    session_id = session.session_id,
    user_id = connection.user_id,
    timestamp = time.time(),
    data = {
                        'session': session.to_dict()
    #                 }
    #             )

                await connection.websocket.send(json.dumps(session_message.to_dict()))

    #             # Send current file states
    #             for file_path, content in session.files.items():
    file_message = CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.FILE_OPENED,
    session_id = session.session_id,
    user_id = connection.user_id,
    timestamp = time.time(),
    data = {
    #                         'file_path': file_path,
    #                         'content': content
    #                     }
    #                 )

                    await connection.websocket.send(json.dumps(file_message.to_dict()))

    #         except Exception as e:
                logger.error(f"Error sending session state: {e}")

    #     async def _handle_connection_messages(self, connection_id: str):
    #         """Handle messages from a connection"""
    connection = self.connections.get(connection_id)
    #         if not connection:
    #             return

    #         try:
    #             async for message in connection.websocket:
    data = json.loads(message)

    #                 # Parse message
    #                 if 'type' not in data:
    #                     continue

    message_type = MessageType(data['type'])

    #                 # Create collaboration message
    collab_message = CollaborationMessage(
    message_id = data.get('message_id', str(uuid.uuid4())),
    message_type = message_type,
    session_id = connection.session_id,
    user_id = connection.user_id,
    timestamp = data.get('timestamp', time.time()),
    data = data.get('data', {})
    #                 )

    #                 # Handle message
                    await self._handle_message(connection_id, collab_message)

    #         except websockets.exceptions.ConnectionClosed:
                logger.info(f"Connection {connection_id} closed during message handling")
    #         except Exception as e:
                logger.error(f"Error handling connection messages: {e}")

    #     async def _handle_message(self, connection_id: str, message: CollaborationMessage):
    #         """Handle incoming collaboration message"""
    handler = self.message_handlers.get(message.message_type)

    #         if handler:
    #             try:
                    await handler(connection_id, message)
    #             except Exception as e:
                    logger.error(f"Error handling message {message.message_type}: {e}")
    #         else:
                logger.warning(f"Unknown message type: {message.message_type}")

    #     async def _handle_change_applied(self, connection_id: str, message: CollaborationMessage):
    #         """Handle change applied message"""
    change_data = message.data

    #         # Create change object
    change = Change(
    change_id = message.message_id,
    user_id = message.user_id,
    file_path = change_data['file_path'],
    change_type = ChangeType(change_data['change_type']),
    position = tuple(change_data['position']),
    content = change_data.get('content', ''),
    old_content = change_data.get('old_content', ''),
    timestamp = message.timestamp,
    version = change_data.get('version', 0)
    #         )

    #         # Apply change in collaborative environment
    success = await self.collaborative_env.apply_change(message.session_id, change)

    #         if success:
    #             # Broadcast to other users in session
                await self._broadcast_to_session(message.session_id, message,
    exclude_connection_id = connection_id)

    #     async def _handle_cursor_updated(self, connection_id: str, message: CollaborationMessage):
    #         """Handle cursor updated message"""
    position = tuple(message.data['position'])

    #         # Update cursor in collaborative environment
            await self.collaborative_env.update_cursor(
    #             message.session_id, message.user_id, position
    #         )

    #         # Broadcast to other users in session
            await self._broadcast_to_session(message.session_id, message,
    exclude_connection_id = connection_id)

    #     async def _handle_selection_updated(self, connection_id: str, message: CollaborationMessage):
    #         """Handle selection updated message"""
    selection = message.data.get('selection')

    #         # Update selection in collaborative environment
            await self.collaborative_env.update_selection(
    #             message.session_id, message.user_id, selection
    #         )

    #         # Broadcast to other users in session
            await self._broadcast_to_session(message.session_id, message,
    exclude_connection_id = connection_id)

    #     async def _handle_typing_started(self, connection_id: str, message: CollaborationMessage):
    #         """Handle typing started message"""
    #         # Broadcast to other users in session
            await self._broadcast_to_session(message.session_id, message,
    exclude_connection_id = connection_id)

    #     async def _handle_typing_stopped(self, connection_id: str, message: CollaborationMessage):
    #         """Handle typing stopped message"""
    #         # Broadcast to other users in session
            await self._broadcast_to_session(message.session_id, message,
    exclude_connection_id = connection_id)

    #     async def _handle_presence_update(self, connection_id: str, message: CollaborationMessage):
    #         """Handle presence update message"""
    #         # Update user presence in collaborative environment
    session = await self.collaborative_env.get_session(message.session_id)
    #         if session and message.user_id in session.participants:
    user = session.participants[message.user_id]

    #             if 'status' in message.data:
    user.status = message.data['status']

    user.last_seen = time.time()

    #         # Broadcast to other users in session
            await self._broadcast_to_session(message.session_id, message,
    exclude_connection_id = connection_id)

    #     async def _broadcast_to_session(self, session_id: str, message: CollaborationMessage,
    exclude_connection_id: Optional[str] = None):
    #         """Broadcast message to all connections in session"""
    connection_ids = self.session_connections.get(session_id, set())

    #         for connection_id in connection_ids:
    #             if connection_id != exclude_connection_id:
    connection = self.connections.get(connection_id)
    #                 if connection:
    #                     try:
                            await connection.websocket.send(json.dumps(message.to_dict()))
    #                     except Exception as e:
                            logger.error(f"Error broadcasting to connection {connection_id}: {e}")

    #     async def _cleanup_connection(self, connection_id: str):
    #         """Clean up connection"""
    connection = self.connections.get(connection_id)
    #         if not connection:
    #             return

    #         # Remove from connections
    #         del self.connections[connection_id]

    #         # Remove from session connections
    #         if connection.session_id in self.session_connections:
                self.session_connections[connection.session_id].discard(connection_id)

    #             # Clean up empty session connections
    #             if not self.session_connections[connection.session_id]:
    #                 del self.session_connections[connection.session_id]

    #         # Remove from user connections
    #         if connection.user_id in self.user_connections:
                self.user_connections[connection.user_id].discard(connection_id)

    #             # Clean up empty user connections
    #             if not self.user_connections[connection.user_id]:
    #                 del self.user_connections[connection.user_id]

    #         # Leave collaborative session
            await self.collaborative_env.leave_session(connection.user_id)

            logger.info(f"Cleaned up connection {connection_id}")

    #     # Event handlers
    #     async def _on_user_joined(self, data: Dict[str, Any]):
    #         """Handle user joined event"""
    session_id = data['session_id']
    user_id = data['user_id']

    message = CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.USER_JOINED,
    session_id = session_id,
    user_id = 'system',
    timestamp = time.time(),
    data = {
    #                 'user_id': user_id
    #             }
    #         )

            await self._broadcast_to_session(session_id, message)

    #     async def _on_user_left(self, data: Dict[str, Any]):
    #         """Handle user left event"""
    session_id = data['session_id']
    user_id = data['user_id']

    message = CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.USER_LEFT,
    session_id = session_id,
    user_id = 'system',
    timestamp = time.time(),
    data = {
    #                 'user_id': user_id
    #             }
    #         )

            await self._broadcast_to_session(session_id, message)

    #     async def _on_change_applied(self, data: Dict[str, Any]):
    #         """Handle change applied event"""
    session_id = data['session_id']
    change_id = data['change_id']
    user_id = data['user_id']

    message = CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.CHANGE_APPLIED,
    session_id = session_id,
    user_id = 'system',
    timestamp = time.time(),
    data = {
    #                 'change_id': change_id,
    #                 'user_id': user_id
    #             }
    #         )

            await self._broadcast_to_session(session_id, message)

    #     async def _on_conflict_detected(self, data: Dict[str, Any]):
    #         """Handle conflict detected event"""
    session_id = data['session_id']
    conflict_id = data['conflict_id']

    message = CollaborationMessage(
    message_id = str(uuid.uuid4()),
    message_type = MessageType.CONFLICT_DETECTED,
    session_id = session_id,
    user_id = 'system',
    timestamp = time.time(),
    data = {
    #                 'conflict_id': conflict_id
    #             }
    #         )

            await self._broadcast_to_session(session_id, message)

    #     async def _ping_loop(self):
    #         """Background ping loop"""
    #         while True:
    #             try:
    #                 # Send ping to all connections
    #                 for connection_id, connection in list(self.connections.items()):
    #                     try:
    ping_message = {
    #                             'type': 'ping',
                                'timestamp': time.time()
    #                         }
                            await connection.websocket.send(json.dumps(ping_message))
    connection.last_ping = time.time()
    #                     except Exception as e:
                            logger.error(f"Error pinging connection {connection_id}: {e}")
    #                         # Mark for cleanup
    connection.last_ping = 0

    #                 # Wait for next ping
                    await asyncio.sleep(self.ping_interval)

    #             except Exception as e:
                    logger.error(f"Error in ping loop: {e}")
                    await asyncio.sleep(10)

    #     async def _cleanup_loop(self):
    #         """Background cleanup loop"""
    #         while True:
    #             try:
    current_time = time.time()
    dead_connections = []

    #                 # Find dead connections
    #                 for connection_id, connection in self.connections.items():
    #                     if current_time - connection.last_ping > 60:  # 60 seconds timeout
                            dead_connections.append(connection_id)

    #                 # Clean up dead connections
    #                 for connection_id in dead_connections:
                        await self._cleanup_connection(connection_id)

    #                 # Wait for next cleanup
                    await asyncio.sleep(self.cleanup_interval)

    #             except Exception as e:
                    logger.error(f"Error in cleanup loop: {e}")
                    await asyncio.sleep(30)

    #     def register_event_handler(self, event_type: str, handler: Callable):
    #         """Register event handler"""
    #         if event_type not in self.event_handlers:
    self.event_handlers[event_type] = []

            self.event_handlers[event_type].append(handler)

    #     async def get_server_stats(self) -> Dict[str, Any]:
    #         """Get server statistics"""
    #         return {
                'total_connections': len(self.connections),
                'active_sessions': len(self.session_connections),
                'connected_users': len(self.user_connections),
                'uptime': time.time() - getattr(self, 'start_time', time.time())
    #         }


class RealtimeCollaborationClient
    #     """Real-time collaboration client"""

    #     def __init__(self, server_url: str):
    #         """
    #         Initialize collaboration client

    #         Args:
    #             server_url: WebSocket server URL
    #         """
    self.server_url = server_url
    self.websocket = None
    self.user_id = None
    self.session_id = None
    self.connected = False
    self.message_handlers = {}

    #         # Event callbacks
    self.on_connected = None
    self.on_disconnected = None
    self.on_user_joined = None
    self.on_user_left = None
    self.on_change_applied = None
    self.on_conflict_detected = None

    #     async def connect(self, user_id: str, session_id: str, token: str):
    #         """
    #         Connect to collaboration server

    #         Args:
    #             user_id: User ID
    #             session_id: Session ID
    #             token: Authentication token
    #         """
    #         try:
    self.user_id = user_id
    self.session_id = session_id

    #             # Connect to WebSocket
    self.websocket = await websockets.connect(self.server_url)

    #             # Send authentication
    auth_message = {
    #                 'user_id': user_id,
    #                 'session_id': session_id,
    #                 'token': token
    #             }

                await self.websocket.send(json.dumps(auth_message))

    #             # Wait for authentication response
    response = await self.websocket.recv()
    response_data = json.loads(response)

    #             if response_data.get('type') == 'error':
                    raise Exception(f"Authentication failed: {response_data.get('message')}")

    self.connected = True

    #             # Start message handling loop
                asyncio.create_task(self._message_loop())

    #             # Call connected callback
    #             if self.on_connected:
                    await self.on_connected()

                logger.info(f"Connected to collaboration server as {user_id}")

    #         except Exception as e:
                logger.error(f"Error connecting to collaboration server: {e}")
    #             raise

    #     async def disconnect(self):
    #         """Disconnect from collaboration server"""
    #         if self.websocket:
                await self.websocket.close()
    self.connected = False

    #             # Call disconnected callback
    #             if self.on_disconnected:
                    await self.on_disconnected()

                logger.info("Disconnected from collaboration server")

    #     async def send_change(self, file_path: str, change_type: ChangeType,
    position: Tuple[int, int], content: str = "",
    old_content: str = "", version: int = 0):
    #         """
    #         Send change to server

    #         Args:
    #             file_path: File path
    #             change_type: Type of change
                position: Position (line, column)
    #             content: New content
    #             old_content: Old content
    #             version: Version number
    #         """
    #         if not self.connected:
    #             return

    message = {
    #             'type': 'change_applied',
                'message_id': str(uuid.uuid4()),
                'timestamp': time.time(),
    #             'data': {
    #                 'file_path': file_path,
    #                 'change_type': change_type.value,
    #                 'position': position,
    #                 'content': content,
    #                 'old_content': old_content,
    #                 'version': version
    #             }
    #         }

            await self.websocket.send(json.dumps(message))

    #     async def send_cursor_update(self, position: Tuple[int, int]):
    #         """
    #         Send cursor position update

    #         Args:
                position: New cursor position (line, column)
    #         """
    #         if not self.connected:
    #             return

    message = {
    #             'type': 'cursor_updated',
                'message_id': str(uuid.uuid4()),
                'timestamp': time.time(),
    #             'data': {
    #                 'position': position
    #             }
    #         }

            await self.websocket.send(json.dumps(message))

    #     async def send_selection_update(self, selection: Optional[Tuple[Tuple[int, int], Tuple[int, int]]]):
    #         """
    #         Send selection update

    #         Args:
    #             selection: New selection or None
    #         """
    #         if not self.connected:
    #             return

    message = {
    #             'type': 'selection_updated',
                'message_id': str(uuid.uuid4()),
                'timestamp': time.time(),
    #             'data': {
    #                 'selection': selection
    #             }
    #         }

            await self.websocket.send(json.dumps(message))

    #     async def send_typing_started(self):
    #         """Send typing started notification"""
    #         if not self.connected:
    #             return

    message = {
    #             'type': 'typing_started',
                'message_id': str(uuid.uuid4()),
                'timestamp': time.time()
    #         }

            await self.websocket.send(json.dumps(message))

    #     async def send_typing_stopped(self):
    #         """Send typing stopped notification"""
    #         if not self.connected:
    #             return

    message = {
    #             'type': 'typing_stopped',
                'message_id': str(uuid.uuid4()),
                'timestamp': time.time()
    #         }

            await self.websocket.send(json.dumps(message))

    #     async def send_presence_update(self, status: str):
    #         """
    #         Send presence update

    #         Args:
                status: User status (active, idle, away)
    #         """
    #         if not self.connected:
    #             return

    message = {
    #             'type': 'presence_update',
                'message_id': str(uuid.uuid4()),
                'timestamp': time.time(),
    #             'data': {
    #                 'status': status
    #             }
    #         }

            await self.websocket.send(json.dumps(message))

    #     async def _message_loop(self):
    #         """Handle incoming messages"""
    #         try:
    #             async for message in self.websocket:
    data = json.loads(message)
    message_type = data.get('type')

    #                 # Handle different message types
    #                 if message_type == 'user_joined':
    #                     if self.on_user_joined:
                            await self.on_user_joined(data)

    #                 elif message_type == 'user_left':
    #                     if self.on_user_left:
                            await self.on_user_left(data)

    #                 elif message_type == 'change_applied':
    #                     if self.on_change_applied:
                            await self.on_change_applied(data)

    #                 elif message_type == 'conflict_detected':
    #                     if self.on_conflict_detected:
                            await self.on_conflict_detected(data)

    #                 elif message_type == 'cursor_updated':
    #                     # Handle cursor updates from other users
    #                     pass

    #                 elif message_type == 'selection_updated':
    #                     # Handle selection updates from other users
    #                     pass

    #                 elif message_type == 'ping':
    #                     # Respond to ping
    pong_message = {
    #                         'type': 'pong',
                            'timestamp': time.time()
    #                     }
                        await self.websocket.send(json.dumps(pong_message))

    #         except websockets.exceptions.ConnectionClosed:
    self.connected = False
    #             if self.on_disconnected:
                    await self.on_disconnected()
    #         except Exception as e:
                logger.error(f"Error in message loop: {e}")