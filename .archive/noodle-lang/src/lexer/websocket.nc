# Converted from Python to NoodleCore
# Original file: src

# """
# Enhanced WebSocket Implementation for Mobile API
# -----------------------------------------------

# This module provides an enhanced WebSocket implementation for real-time communication
# between the NoodleControl mobile app and NoodleCore, including NoodleRPC bridge,
# message serialization, connection management, and event subscription system.
# """

import asyncio
import json
import logging
import threading
import time
import uuid
import datetime.datetime
import enum.Enum
import typing.Any
import queue
import hashlib
import hmac

try
    #     import socketio
    #     from flask_socketio import SocketIO, emit, join_room, leave_room, disconnect
    WEBSOCKET_AVAILABLE = True
except ImportError
    WEBSOCKET_AVAILABLE = False
        logging.warning("WebSocket dependencies not available. Real-time features will be limited.")

import .errors.NetworkError

logger = logging.getLogger(__name__)

# Constants
MAX_CONNECTIONS = 100  # As per performance constraints
CONNECTION_TIMEOUT = 300  # 5 minutes
PING_INTERVAL = 30  # 30 seconds
MESSAGE_QUEUE_SIZE = 1000
RECONNECT_DELAY = 5  # seconds
MAX_RECONNECT_ATTEMPTS = 10


class ConnectionState(Enum)
    #     """WebSocket connection states."""
    CONNECTING = "connecting"
    CONNECTED = "connected"
    DISCONNECTED = "disconnected"
    RECONNECTING = "reconnecting"
    ERROR = "error"


class MessageType(Enum)
    #     """Message types for WebSocket communication."""
    #     # Control messages
    CONNECT = "connect"
    DISCONNECT = "disconnect"
    PING = "ping"
    PONG = "pong"
    ERROR = "error"

    #     # Authentication messages
    AUTH_REQUEST = "auth_request"
    AUTH_RESPONSE = "auth_response"
    TOKEN_REFRESH = "token_refresh"

    #     # NoodleRPC messages
    RPC_REQUEST = "rpc_request"
    RPC_RESPONSE = "rpc_response"
    RPC_NOTIFICATION = "rpc_notification"

    #     # Event subscription messages
    SUBSCRIBE = "subscribe"
    UNSUBSCRIBE = "unsubscribe"
    EVENT = "event"

    #     # Data synchronization messages
    SYNC_REQUEST = "sync_request"
    SYNC_RESPONSE = "sync_response"
    SYNC_COMPLETE = "sync_complete"


class WebSocketConnection
    #     """Represents a WebSocket connection with enhanced capabilities."""

    #     def __init__(self, client_id: str, device_id: str, socket_id: str):""
    #         Initialize WebSocket connection.

    #         Args:
    #             client_id: Unique client identifier
    #             device_id: Device identifier
    #             socket_id: Socket.IO session ID
    #         """
    self.client_id = client_id
    self.device_id = device_id
    self.socket_id = socket_id
    self.state = ConnectionState.CONNECTING
    self.connected_at = datetime.now()
    self.last_ping = time.time()
    self.rooms: Set[str] = set()
    self.subscriptions: Set[str] = set()
    self.message_queue = queue.Queue(maxsize=MESSAGE_QUEUE_SIZE)
    self.reconnect_attempts = 0
    self.sequence_number = 0
    self.auth_token = None
    self.device_fingerprint = None
    self._lock = threading.Lock()

    #     def update_ping(self):
    #         """Update the last ping time."""
    #         with self._lock:
    self.last_ping = time.time()

    #     def add_room(self, room_name: str):
    #         """Add a room to the connection."""
    #         with self._lock:
                self.rooms.add(room_name)

    #     def remove_room(self, room_name: str):
    #         """Remove a room from the connection."""
    #         with self._lock:
                self.rooms.discard(room_name)

    #     def add_subscription(self, event_type: str):
    #         """Add an event subscription."""
    #         with self._lock:
                self.subscriptions.add(event_type)

    #     def remove_subscription(self, event_type: str):
    #         """Remove an event subscription."""
    #         with self._lock:
                self.subscriptions.discard(event_type)

    #     def is_stale(self, timeout_seconds: int = CONNECTION_TIMEOUT) -bool):
    #         """Check if connection is stale."""
            return time.time() - self.last_ping timeout_seconds

    #     def next_sequence_number(self):
    """int)"""
    #         """Get the next sequence number for message ordering."""
    #         with self._lock:
    self.sequence_number + = 1
    #             return self.sequence_number

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert connection to dictionary."""
    #         return {
    #             "client_id": self.client_id,
    #             "device_id": self.device_id,
    #             "socket_id": self.socket_id,
    #             "state": self.state.value,
                "connected_at": self.connected_at.isoformat(),
    #             "last_ping": self.last_ping,
                "rooms": list(self.rooms),
                "subscriptions": list(self.subscriptions),
    #             "reconnect_attempts": self.reconnect_attempts,
    #         }


class MessageSerializer
    #     """Handles message serialization and deserialization for efficient data transfer."""

    #     @staticmethod
    #     def serialize_message(message_type: MessageType, data: Dict[str, Any],
    sequence_number: int = 0 - request_id: str = None, Dict[str, Any]):)
    #         """
    #         Serialize a message for transmission.

    #         Args:
    #             message_type: Type of the message
    #             data: Message data
    #             sequence_number: Sequence number for ordering
    #             request_id: Request ID for correlation

    #         Returns:
    #             Serialized message dictionary
    #         """
    #         if not request_id:
    request_id = str(uuid.uuid4())

    message = {
    #             "type": message_type.value,
    #             "requestId": request_id,
                "timestamp": datetime.now().isoformat(),
    #             "sequence": sequence_number,
    #             "data": data,
    #         }

    #         # Add message hash for integrity verification
    message_str = json.dumps(message, sort_keys=True)
    message["hash"] = hashlib.sha256(message_str.encode()).hexdigest()

    #         return message

    #     @staticmethod
    #     def deserialize_message(message: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Deserialize a received message.

    #         Args:
    #             message: Received message dictionary

    #         Returns:
    #             Deserialized message dictionary

    #         Raises:
    #             ValidationError: If message is invalid or corrupted
    #         """
    #         try:
    #             # Verify message has required fields
    required_fields = ["type", "requestId", "timestamp", "sequence", "data"]
    #             for field in required_fields:
    #                 if field not in message:
                        raise ValidationError(f"Missing required field: {field}")

    #             # Verify message integrity
    message_hash = message.pop("hash", None)
    #             if message_hash:
    message_str = json.dumps(message, sort_keys=True)
    calculated_hash = hashlib.sha256(message_str.encode()).hexdigest()
    #                 if calculated_hash != message_hash:
                        raise ValidationError("Message integrity check failed")

    #             # Convert string type to enum
    #             try:
    message_type = MessageType(message["type"])
    message["type"] = message_type
    #             except ValueError:
                    raise ValidationError(f"Invalid message type: {message['type']}")

    #             return message
            except (json.JSONDecodeError, KeyError, TypeError) as e:
                raise ValidationError(f"Invalid message format: {e}")


class NoodleRPCBridge
    #     """Bridge module to interface with the NoodleNet distributed system."""

    #     def __init__(self, redis_client=None):""
    #         Initialize NoodleRPC bridge.

    #         Args:
    #             redis_client: Redis client for distributed communication
    #         """
    self.redis = redis_client
    self.rpc_handlers: Dict[str, Callable] = {}
    self.pending_requests: Dict[str, Dict[str, Any]] = {}
    self._lock = threading.Lock()

    #         # Register default RPC handlers
            self._register_default_handlers()

    #     def _register_default_handlers(self):
    #         """Register default RPC handlers."""
            self.register_rpc_handler("system.info", self._handle_system_info)
            self.register_rpc_handler("node.list", self._handle_node_list)
            self.register_rpc_handler("node.execute", self._handle_node_execute)
            self.register_rpc_handler("reasoning.start", self._handle_reasoning_start)
            self.register_rpc_handler("reasoning.status", self._handle_reasoning_status)

    #     def register_rpc_handler(self, method: str, handler: Callable):
    #         """
    #         Register an RPC method handler.

    #         Args:
    #             method: RPC method name
    #             handler: Handler function
    #         """
    #         with self._lock:
    self.rpc_handlers[method] = handler
                logger.info(f"Registered RPC handler: {method}")

    #     def unregister_rpc_handler(self, method: str):
    #         """
    #         Unregister an RPC method handler.

    #         Args:
    #             method: RPC method name
    #         """
    #         with self._lock:
    #             if method in self.rpc_handlers:
    #                 del self.rpc_handlers[method]
                    logger.info(f"Unregistered RPC handler: {method}")

    #     async def handle_request(self, request: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle an RPC request.

    #         Args:
    #             request: RPC request dictionary

    #         Returns:
    #             RPC response dictionary
    #         """
    #         try:
    method = request.get("method")
    params = request.get("params", {})
    request_id = request.get("requestId")

    #             if not method:
                    raise ValidationError("RPC method is required")

    #             # Get handler for method
    #             with self._lock:
    handler = self.rpc_handlers.get(method)

    #             if not handler:
                    raise ValidationError(f"Unknown RPC method: {method}")

    #             # Execute handler
    #             if asyncio.iscoroutinefunction(handler):
    result = await handler(params)
    #             else:
    result = handler(params)

    #             return {
    #                 "success": True,
    #                 "requestId": request_id,
    #                 "result": result,
                    "timestamp": datetime.now().isoformat(),
    #             }
    #         except Exception as e:
                logger.error(f"RPC request failed: {e}")
    #             return {
    #                 "success": False,
                    "requestId": request.get("requestId"),
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
    #             }

    #     async def send_notification(self, method: str, params: Dict[str, Any]):
    #         """
            Send an RPC notification (no response expected).

    #         Args:
    #             method: RPC method name
    #             params: Parameters
    #         """
    #         try:
    notification = {
    #                 "type": MessageType.RPC_NOTIFICATION.value,
    #                 "method": method,
    #                 "params": params,
                    "timestamp": datetime.now().isoformat(),
    #             }

    #             # Publish to Redis for distributed nodes
    #             if self.redis:
                    self.redis.publish("noodlerpc_notifications", json.dumps(notification))

                logger.info(f"Sent RPC notification: {method}")
    #         except Exception as e:
                logger.error(f"Failed to send RPC notification: {e}")

    #     # Default RPC handlers
    #     def _handle_system_info(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle system.info RPC request."""
    #         return {
    #             "version": "1.0.0",
    #             "node_count": 1,
                "uptime": time.time(),
    #             "memory_usage": "256MB",
    #             "cpu_usage": "15%",
    #         }

    #     def _handle_node_list(self, params: Dict[str, Any]) -List[Dict[str, Any]]):
    #         """Handle node.list RPC request."""
    #         return [
    #             {
    #                 "id": "node-001",
    #                 "name": "Primary Node",
    #                 "status": "active",
                    "last_seen": datetime.now().isoformat(),
    #             }
    #         ]

    #     def _handle_node_execute(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle node.execute RPC request."""
    command = params.get("command")
    #         if not command:
                raise ValidationError("Command is required")

    #         return {
                "command_id": str(uuid.uuid4()),
    #             "status": "executed",
    #             "result": f"Executed: {command}",
    #         }

    #     def _handle_reasoning_start(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle reasoning.start RPC request."""
    prompt = params.get("prompt")
    #         if not prompt:
                raise ValidationError("Prompt is required")

    #         return {
                "session_id": str(uuid.uuid4()),
    #             "status": "started",
    #             "prompt": prompt[:100] + "..." if len(prompt) 100 else prompt,
    #         }

    #     def _handle_reasoning_status(self, params): Dict[str, Any]) -Dict[str, Any]):
    #         """Handle reasoning.status RPC request."""
    session_id = params.get("session_id")
    #         if not session_id:
                raise ValidationError("Session ID is required")

    #         return {
    #             "session_id": session_id,
    #             "status": "processing",
    #             "progress": 75,
                "estimated_completion": datetime.now().isoformat(),
    #         }


class EventSubscriptionManager
    #     """Manages event subscriptions for real-time updates."""

    #     def __init__(self, redis_client=None):""
    #         Initialize event subscription manager.

    #         Args:
    #             redis_client: Redis client for distributed event publishing
    #         """
    self.redis = redis_client
    self.subscriptions: Dict[str, Set[str]] = {}  # event_type - set of client_ids
    self.client_subscriptions): Dict[str, Set[str]] = {}  # client_id - set of event_types
    self._lock = threading.Lock()

    #     def subscribe(self, client_id): str, event_types: List[str]) -bool):
    #         """
    #         Subscribe a client to event types.

    #         Args:
    #             client_id: Client ID
    #             event_types: List of event types to subscribe to

    #         Returns:
    #             True if subscription was successful
    #         """
    #         try:
    #             with self._lock:
    #                 # Initialize client subscriptions if not exists
    #                 if client_id not in self.client_subscriptions:
    self.client_subscriptions[client_id] = set()

    #                 # Add subscriptions
    #                 for event_type in event_types:
    #                     # Initialize event type subscriptions if not exists
    #                     if event_type not in self.subscriptions:
    self.subscriptions[event_type] = set()

    #                     # Add client to event type
                        self.subscriptions[event_type].add(client_id)
                        self.client_subscriptions[client_id].add(event_type)

                logger.info(f"Client {client_id} subscribed to events: {event_types}")
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to subscribe client {client_id}: {e}")
    #             return False

    #     def unsubscribe(self, client_id: str, event_types: List[str]) -bool):
    #         """
    #         Unsubscribe a client from event types.

    #         Args:
    #             client_id: Client ID
    #             event_types: List of event types to unsubscribe from

    #         Returns:
    #             True if unsubscription was successful
    #         """
    #         try:
    #             with self._lock:
    #                 if client_id not in self.client_subscriptions:
    #                     return True

    #                 # Remove subscriptions
    #                 for event_type in event_types:
    #                     if event_type in self.subscriptions:
                            self.subscriptions[event_type].discard(client_id)

                        self.client_subscriptions[client_id].discard(event_type)

    #                 # Clean up empty subscription sets
    #                 if not self.client_subscriptions[client_id]:
    #                     del self.client_subscriptions[client_id]

                logger.info(f"Client {client_id} unsubscribed from events: {event_types}")
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to unsubscribe client {client_id}: {e}")
    #             return False

    #     def get_subscribers(self, event_type: str) -Set[str]):
    #         """
    #         Get all clients subscribed to an event type.

    #         Args:
    #             event_type: Event type

    #         Returns:
    #             Set of client IDs
    #         """
    #         with self._lock:
                return self.subscriptions.get(event_type, set()).copy()

    #     def get_client_subscriptions(self, client_id: str) -Set[str]):
    #         """
    #         Get all event types a client is subscribed to.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             Set of event types
    #         """
    #         with self._lock:
                return self.client_subscriptions.get(client_id, set()).copy()


class ConnectionManager
    #     """Manages WebSocket connections with enhanced capabilities."""

    #     def __init__(self, redis_client=None):""
    #         Initialize connection manager.

    #         Args:
    #             redis_client: Redis client for distributed connection management
    #         """
    self.redis = redis_client
    self.connections: Dict[str, WebSocketConnection] = {}  # client_id - connection
    self.device_connections): Dict[str, Set[str]] = {}  # device_id - set of client_ids
    self.socket_to_client): Dict[str, str] = {}  # socket_id - client_id
    self._lock = threading.Lock()
    self._cleanup_thread = None
            self._start_cleanup_thread()

    #     def _start_cleanup_thread(self)):
    #         """Start the cleanup thread for stale connections."""
    #         def cleanup():
    #             while True:
    #                 try:
                        time.sleep(60)  # Run every minute
                        self.cleanup_stale_connections()
    #                 except Exception as e:
                        logger.error(f"Connection cleanup error: {e}")

    self._cleanup_thread = threading.Thread(target=cleanup, daemon=True)
            self._cleanup_thread.start()

    #     def add_connection(self, connection: WebSocketConnection):
    #         """
    #         Add a new connection.

    #         Args:
    #             connection: WebSocket connection
    #         """
    #         with self._lock:
    self.connections[connection.client_id] = connection

    #             # Track device connections
    #             if connection.device_id not in self.device_connections:
    self.device_connections[connection.device_id] = set()
                self.device_connections[connection.device_id].add(connection.client_id)

    #             # Track socket to client mapping
    self.socket_to_client[connection.socket_id] = connection.client_id

            logger.info(f"Added connection: {connection.client_id} (device: {connection.device_id})")

    #     def remove_connection(self, client_id: str) -Optional[WebSocketConnection]):
    #         """
    #         Remove a connection.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             Removed connection or None if not found
    #         """
    #         with self._lock:
    connection = self.connections.pop(client_id, None)

    #             if connection:
    #                 # Remove from device connections
    #                 if connection.device_id in self.device_connections:
                        self.device_connections[connection.device_id].discard(client_id)
    #                     if not self.device_connections[connection.device_id]:
    #                         del self.device_connections[connection.device_id]

    #                 # Remove socket mapping
    #                 if connection.socket_id in self.socket_to_client:
    #                     del self.socket_to_client[connection.socket_id]

    #         if connection:
                logger.info(f"Removed connection: {connection.client_id}")

    #         return connection

    #     def get_connection(self, client_id: str) -Optional[WebSocketConnection]):
    #         """
    #         Get a connection by client ID.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             WebSocket connection or None if not found
    #         """
    #         with self._lock:
                return self.connections.get(client_id)

    #     def get_connection_by_socket(self, socket_id: str) -Optional[WebSocketConnection]):
    #         """
    #         Get a connection by socket ID.

    #         Args:
    #             socket_id: Socket ID

    #         Returns:
    #             WebSocket connection or None if not found
    #         """
    #         with self._lock:
    client_id = self.socket_to_client.get(socket_id)
    #             if client_id:
                    return self.connections.get(client_id)
    #             return None

    #     def get_device_connections(self, device_id: str) -List[WebSocketConnection]):
    #         """
    #         Get all connections for a device.

    #         Args:
    #             device_id: Device ID

    #         Returns:
    #             List of WebSocket connections
    #         """
    #         with self._lock:
    client_ids = self.device_connections.get(device_id, set())
    #             return [self.connections[cid] for cid in client_ids if cid in self.connections]

    #     def get_all_connections(self) -List[WebSocketConnection]):
    #         """
    #         Get all connections.

    #         Returns:
    #             List of all WebSocket connections
    #         """
    #         with self._lock:
                return list(self.connections.values())

    #     def cleanup_stale_connections(self, timeout_seconds: int = CONNECTION_TIMEOUT):
    #         """
    #         Clean up stale connections.

    #         Args:
    #             timeout_seconds: Connection timeout in seconds
    #         """
    stale_connections = []

    #         with self._lock:
    #             for client_id, connection in self.connections.items():
    #                 if connection.is_stale(timeout_seconds):
                        stale_connections.append(client_id)

    #         # Remove stale connections
    #         for client_id in stale_connections:
    connection = self.remove_connection(client_id)
    #             if connection:
                    logger.info(f"Cleaned up stale connection: {client_id}")

    #     def get_connection_stats(self) -Dict[str, Any]):
    #         """
    #         Get connection statistics.

    #         Returns:
    #             Connection statistics dictionary
    #         """
    #         with self._lock:
    total_connections = len(self.connections)
    total_devices = len(self.device_connections)

    #             # Calculate connections per device
    connections_per_device = {
                    device_id: len(clients)
    #                 for device_id, clients in self.device_connections.items()
    #             }

    #             return {
    #                 "total_connections": total_connections,
    #                 "total_devices": total_devices,
    #                 "connections_per_device": connections_per_device,
    #                 "max_connections": MAX_CONNECTIONS,
                    "utilization": (total_connections / MAX_CONNECTIONS) * 100,
    #             }


class MessageQueue
    #     """Manages message queuing for offline scenarios."""

    #     def __init__(self, redis_client=None):""
    #         Initialize message queue.

    #         Args:
    #             redis_client: Redis client for persistent queuing
    #         """
    self.redis = redis_client
    self.queues: Dict[str, queue.Queue] = {}  # client_id - queue
    self._lock = threading.Lock()

    #     def enqueue_message(self, client_id): str, message: Dict[str, Any]) -bool):
    #         """
    #         Enqueue a message for a client.

    #         Args:
    #             client_id: Client ID
    #             message: Message to enqueue

    #         Returns:
    #             True if message was enqueued successfully
    #         """
    #         try:
    #             with self._lock:
    #                 if client_id not in self.queues:
    self.queues[client_id] = queue.Queue(maxsize=MESSAGE_QUEUE_SIZE)

    #                 # Add timestamp to message
    message["queued_at"] = datetime.now().isoformat()

                    # Try to enqueue (non-blocking)
    #                 try:
                        self.queues[client_id].put_nowait(message)
    #                 except queue.Full:
    #                     # Queue is full, remove oldest message
    #                     try:
                            self.queues[client_id].get_nowait()
                            self.queues[client_id].put_nowait(message)
    #                     except queue.Empty:
    #                         return False

    #                 # Also store in Redis for persistence
    #                 if self.redis:
    redis_key = f"message_queue:{client_id}"
                        self.redis.lpush(redis_key, json.dumps(message))
    #                     # Keep only last 100 messages per client
                        self.redis.ltrim(redis_key, 0, 99)
    #                     # Set expiry
                        self.redis.expire(redis_key, 86400)  # 24 hours

    #             return True
    #         except Exception as e:
    #             logger.error(f"Failed to enqueue message for {client_id}: {e}")
    #             return False

    #     def dequeue_messages(self, client_id: str) -List[Dict[str, Any]]):
    #         """
    #         Dequeue all messages for a client.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             List of messages
    #         """
    messages = []

    #         try:
    #             with self._lock:
    #                 if client_id in self.queues:
    #                     # Get all messages from memory queue
    #                     while not self.queues[client_id].empty():
    #                         try:
    message = self.queues[client_id].get_nowait()
                                messages.append(message)
    #                         except queue.Empty:
    #                             break

    #                     # Clear the queue
    #                     del self.queues[client_id]

    #             # Also get messages from Redis
    #             if self.redis:
    redis_key = f"message_queue:{client_id}"
    redis_messages = self.redis.lrange(redis_key - 0,, 1)

    #                 for redis_message in redis_messages:
    #                     try:
    message = json.loads(redis_message)
                            messages.append(message)
    #                     except json.JSONDecodeError:
    #                         continue

    #                 # Clear Redis queue
                    self.redis.delete(redis_key)

    #             # Sort by timestamp
    messages.sort(key = lambda m: m.get("queued_at", ""))

    #         except Exception as e:
    #             logger.error(f"Failed to dequeue messages for {client_id}: {e}")

    #         return messages

    #     def get_queue_size(self, client_id: str) -int):
    #         """
    #         Get the size of a client's message queue.

    #         Args:
    #             client_id: Client ID

    #         Returns:
    #             Queue size
    #         """
    #         try:
    #             with self._lock:
    #                 if client_id in self.queues:
                        return self.queues[client_id].qsize()
    #                 return 0
    #         except Exception as e:
    #             logger.error(f"Failed to get queue size for {client_id}: {e}")
    #             return 0


class EnhancedWebSocketHandler
    #     """
    #     Enhanced WebSocket handler with NoodleRPC bridge, message serialization,
    #     connection management, event subscription, and message queuing.
    #     """

    #     def __init__(self, redis_client=None):""
    #         Initialize enhanced WebSocket handler.

    #         Args:
    #             redis_client: Redis client for distributed operations
    #         """
    self.redis = redis_client
    self.connection_manager = ConnectionManager(redis_client)
    self.event_manager = EventSubscriptionManager(redis_client)
    self.message_queue = MessageQueue(redis_client)
    self.rpc_bridge = NoodleRPCBridge(redis_client)
    self.serializer = MessageSerializer()

    #         # Initialize SocketIO if available
    #         if WEBSOCKET_AVAILABLE:
    self.socketio = SocketIO(cors_allowed_origins="*", async_mode='threading')
                self._setup_socketio_handlers()
    #         else:
    self.socketio = None
                logger.warning("SocketIO not available. WebSocket functionality disabled.")

    #         # Start background tasks
            self._start_background_tasks()

    #     def _start_background_tasks(self):
    #         """Start background tasks for WebSocket management."""
    #         # Start Redis listener for distributed events
    #         if self.redis:
                self._start_redis_listener()

    #         # Start ping monitoring
            self._start_ping_monitor()

    #     def _setup_socketio_handlers(self):
    #         """Setup enhanced SocketIO event handlers."""
    #         if not self.socketio:
    #             return

            @self.socketio.on('connect')
    #         def handle_connect(auth_data):
    #             """Handle client connection with enhanced authentication."""
    #             try:
    #                 # Extract authentication data
    #                 device_id = auth_data.get('device_id') if auth_data else None
    #                 auth_token = auth_data.get('token') if auth_data else None

    #                 if not device_id:
                        logger.warning("Client connected without device_id")
                        disconnect()
    #                     return

    #                 # Validate connection limit
    #                 if len(self.connection_manager.get_all_connections()) >= MAX_CONNECTIONS:
                        logger.warning("Connection limit reached")
                        disconnect()
    #                     return

    #                 # Create connection
    client_id = str(uuid.uuid4())
    socket_id = request.sid  # Flask request context

    connection = WebSocketConnection(client_id, device_id, socket_id)
    connection.auth_token = auth_token
    connection.state = ConnectionState.CONNECTED

    #                 # Add connection to manager
                    self.connection_manager.add_connection(connection)

    #                 # Join device-specific room
                    join_room(f"device:{device_id}")
                    connection.add_room(f"device:{device_id}")

    #                 # Send connection confirmation
    response = self.serializer.serialize_message(
    #                     MessageType.CONNECT,
    #                     {
    #                         "client_id": client_id,
    #                         "device_id": device_id,
                            "server_time": datetime.now().isoformat(),
    #                         "capabilities": ["rpc", "events", "queue"],
    #                     }
    #                 )
                    emit('connected', response)

    #                 # Dequeue any pending messages
    pending_messages = self.message_queue.dequeue_messages(client_id)
    #                 for message in pending_messages:
                        emit('message', message)

                    logger.info(f"Client connected: {client_id} (device: {device_id})")
    #             except Exception as e:
                    logger.error(f"Error handling client connection: {e}")
                    disconnect()

            @self.socketio.on('disconnect')
    #         def handle_disconnect():
    #             """Handle client disconnection with cleanup."""
    #             try:
    socket_id = request.sid
    connection = self.connection_manager.get_connection_by_socket(socket_id)

    #                 if connection:
    #                     # Remove connection from manager
                        self.connection_manager.remove_connection(connection.client_id)

    #                     # Leave all rooms
    #                     for room_name in connection.rooms:
                            leave_room(room_name)

    #                     # Update connection state
    connection.state = ConnectionState.DISCONNECTED

                        logger.info(f"Client disconnected: {connection.client_id}")
    #             except Exception as e:
                    logger.error(f"Error handling client disconnection: {e}")

            @self.socketio.on('message')
    #         def handle_message(message_data):
    #             """Handle incoming messages with enhanced processing."""
    #             try:
    socket_id = request.sid
    connection = self.connection_manager.get_connection_by_socket(socket_id)

    #                 if not connection:
                        emit('error', {"message": "Connection not found"})
    #                     return

    #                 # Update ping
                    connection.update_ping()

    #                 # Deserialize message
    #                 try:
    message = self.serializer.deserialize_message(message_data)
    #                 except ValidationError as e:
                        emit('error', {"message": f"Invalid message: {e}"})
    #                     return

    #                 # Handle message based on type
                    asyncio.create_task(self._process_message(connection, message))

    #             except Exception as e:
                    logger.error(f"Error handling message: {e}")
                    emit('error', {"message": "Failed to process message"})

            @self.socketio.on('ping')
    #         def handle_ping():
    #             """Handle ping with enhanced response."""
    #             try:
    socket_id = request.sid
    connection = self.connection_manager.get_connection_by_socket(socket_id)

    #                 if connection:
                        connection.update_ping()

    response = self.serializer.serialize_message(
    #                     MessageType.PONG,
    #                     {
                            "timestamp": datetime.now().isoformat(),
                            "server_time": datetime.now().isoformat(),
    #                     }
    #                 )
                    emit('pong', response)
    #             except Exception as e:
                    logger.error(f"Error handling ping: {e}")

    #     async def _process_message(self, connection: WebSocketConnection, message: Dict[str, Any]):
    #         """
    #         Process a received message.

    #         Args:
    #             connection: WebSocket connection
    #             message: Deserialized message
    #         """
    #         try:
    message_type = message["type"]
    data = message["data"]
    request_id = message["requestId"]

    #             # Handle different message types
    #             if message_type == MessageType.RPC_REQUEST:
                    await self._handle_rpc_request(connection, data, request_id)
    #             elif message_type == MessageType.SUBSCRIBE:
                    self._handle_subscribe(connection, data, request_id)
    #             elif message_type == MessageType.UNSUBSCRIBE:
                    self._handle_unsubscribe(connection, data, request_id)
    #             elif message_type == MessageType.SYNC_REQUEST:
                    await self._handle_sync_request(connection, data, request_id)
    #             elif message_type == MessageType.PING:
                    self._handle_ping_message(connection, data, request_id)
    #             else:
                    logger.warning(f"Unknown message type: {message_type}")

    #         except Exception as e:
                logger.error(f"Error processing message: {e}")
    error_response = self.serializer.serialize_message(
    #                 MessageType.ERROR,
    #                 {"message": f"Failed to process message: {e}"},
    request_id = request_id
    #             )
                self._send_to_connection(connection, error_response)

    #     async def _handle_rpc_request(self, connection: WebSocketConnection,
    #                                  data: Dict[str, Any], request_id: str):
    #         """
    #         Handle RPC request message.

    #         Args:
    #             connection: WebSocket connection
    #             data: Request data
    #             request_id: Request ID
    #         """
    #         try:
    #             # Process RPC request
    response = await self.rpc_bridge.handle_request({
                    "method": data.get("method"),
                    "params": data.get("params", {}),
    #                 "requestId": request_id,
    #             })

    #             # Send response
    response_message = self.serializer.serialize_message(
    #                 MessageType.RPC_RESPONSE,
    #                 response,
    request_id = request_id
    #             )
                self._send_to_connection(connection, response_message)

    #         except Exception as e:
                logger.error(f"Error handling RPC request: {e}")
    error_response = self.serializer.serialize_message(
    #                 MessageType.ERROR,
    #                 {"message": f"RPC request failed: {e}"},
    request_id = request_id
    #             )
                self._send_to_connection(connection, error_response)

    #     def _handle_subscribe(self, connection: WebSocketConnection,
    #                          data: Dict[str, Any], request_id: str):
    #         """
    #         Handle subscription request.

    #         Args:
    #             connection: WebSocket connection
    #             data: Request data
    #             request_id: Request ID
    #         """
    #         try:
    event_types = data.get("eventTypes", [])

    #             if not event_types:
                    raise ValidationError("Event types are required")

    #             # Subscribe to events
    success = self.event_manager.subscribe(connection.client_id, event_types)

    #             if success:
    #                 # Update connection subscriptions
    #                 for event_type in event_types:
                        connection.add_subscription(event_type)

    #                 # Send confirmation
    response = self.serializer.serialize_message(
    #                     MessageType.SUBSCRIBE,
    #                     {
    #                         "subscribed": True,
    #                         "eventTypes": event_types,
    #                     },
    request_id = request_id
    #                 )
                    self._send_to_connection(connection, response)

                    logger.info(f"Client {connection.client_id} subscribed to: {event_types}")
    #             else:
                    raise ValidationError("Failed to subscribe to events")

    #         except Exception as e:
                logger.error(f"Error handling subscription: {e}")
    error_response = self.serializer.serialize_message(
    #                 MessageType.ERROR,
    #                 {"message": f"Subscription failed: {e}"},
    request_id = request_id
    #             )
                self._send_to_connection(connection, error_response)

    #     def _handle_unsubscribe(self, connection: WebSocketConnection,
    #                            data: Dict[str, Any], request_id: str):
    #         """
    #         Handle unsubscription request.

    #         Args:
    #             connection: WebSocket connection
    #             data: Request data
    #             request_id: Request ID
    #         """
    #         try:
    event_types = data.get("eventTypes", [])

    #             if not event_types:
                    raise ValidationError("Event types are required")

    #             # Unsubscribe from events
    success = self.event_manager.unsubscribe(connection.client_id, event_types)

    #             if success:
    #                 # Update connection subscriptions
    #                 for event_type in event_types:
                        connection.remove_subscription(event_type)

    #                 # Send confirmation
    response = self.serializer.serialize_message(
    #                     MessageType.UNSUBSCRIBE,
    #                     {
    #                         "unsubscribed": True,
    #                         "eventTypes": event_types,
    #                     },
    request_id = request_id
    #                 )
                    self._send_to_connection(connection, response)

                    logger.info(f"Client {connection.client_id} unsubscribed from: {event_types}")
    #             else:
                    raise ValidationError("Failed to unsubscribe from events")

    #         except Exception as e:
                logger.error(f"Error handling unsubscription: {e}")
    error_response = self.serializer.serialize_message(
    #                 MessageType.ERROR,
    #                 {"message": f"Unsubscription failed: {e}"},
    request_id = request_id
    #             )
                self._send_to_connection(connection, error_response)

    #     async def _handle_sync_request(self, connection: WebSocketConnection,
    #                                  data: Dict[str, Any], request_id: str):
    #         """
    #         Handle sync request for offline scenarios.

    #         Args:
    #             connection: WebSocket connection
    #             data: Request data
    #             request_id: Request ID
    #         """
    #         try:
    #             # Get sync data based on request
    sync_type = data.get("syncType", "events")
    since = data.get("since")

    #             if sync_type == "events":
    #                 # Get missed events
    events = self._get_missed_events(connection.device_id, since)

    response = self.serializer.serialize_message(
    #                     MessageType.SYNC_RESPONSE,
    #                     {
    #                         "syncType": sync_type,
    #                         "events": events,
    #                         "hasMore": False,
    #                     },
    request_id = request_id
    #                 )
                    self._send_to_connection(connection, response)

    #             # Send sync complete
    complete_response = self.serializer.serialize_message(
    #                 MessageType.SYNC_COMPLETE,
    #                 {
    #                     "syncType": sync_type,
                        "syncedAt": datetime.now().isoformat(),
    #                 },
    request_id = request_id
    #             )
                self._send_to_connection(connection, complete_response)

    #         except Exception as e:
                logger.error(f"Error handling sync request: {e}")
    error_response = self.serializer.serialize_message(
    #                 MessageType.ERROR,
    #                 {"message": f"Sync request failed: {e}"},
    request_id = request_id
    #             )
                self._send_to_connection(connection, error_response)

    #     def _handle_ping_message(self, connection: WebSocketConnection,
    #                             data: Dict[str, Any], request_id: str):
    #         """
    #         Handle ping message.

    #         Args:
    #             connection: WebSocket connection
    #             data: Request data
    #             request_id: Request ID
    #         """
    #         try:
    #             # Update ping time
                connection.update_ping()

    #             # Send pong response
    response = self.serializer.serialize_message(
    #                 MessageType.PONG,
    #                 {
                        "timestamp": datetime.now().isoformat(),
                        "server_time": datetime.now().isoformat(),
    #                 },
    request_id = request_id
    #             )
                self._send_to_connection(connection, response)

    #         except Exception as e:
                logger.error(f"Error handling ping: {e}")

    #     def _send_to_connection(self, connection: WebSocketConnection, message: Dict[str, Any]):
    #         """
    #         Send a message to a specific connection.

    #         Args:
    #             connection: WebSocket connection
    #             message: Message to send
    #         """
    #         try:
    #             if self.socketio and connection.socket_id:
    self.socketio.emit('message', message, room = connection.socket_id)
    #         except Exception as e:
                logger.error(f"Failed to send message to {connection.client_id}: {e}")

    #     def _get_missed_events(self, device_id: str, since: Optional[str]) -List[Dict[str, Any]]):
    #         """
    #         Get missed events for a device since a given time.

    #         Args:
    #             device_id: Device ID
    #             since: ISO format timestamp

    #         Returns:
    #             List of missed events
    #         """
    #         # This would typically query a database or event store
    #         # For now, return empty list
    #         return []

    #     def _start_redis_listener(self):
    #         """Start Redis listener for distributed events."""
    #         def redis_listener():
    #             try:
    pubsub = self.redis.pubsub()
                    pubsub.subscribe('noodlerpc_notifications', 'websocket_events')

    #                 for message in pubsub.listen():
    #                     if message['type'] == 'message':
    #                         try:
    event_data = json.loads(message['data'])

    #                             # Handle RPC notifications
    #                             if message['channel'] == b'noodlerpc_notifications':
                                    self._handle_rpc_notification(event_data)
    #                             # Handle WebSocket events
    #                             elif message['channel'] == b'websocket_events':
                                    self._handle_websocket_event(event_data)

    #                         except Exception as e:
                                logger.error(f"Error processing Redis event: {e}")

    #             except Exception as e:
                    logger.error(f"Redis listener error: {e}")

    #         # Start listener in a separate thread
    listener_thread = threading.Thread(target=redis_listener, daemon=True)
            listener_thread.start()
            logger.info("Redis listener started")

    #     def _handle_rpc_notification(self, notification: Dict[str, Any]):
    #         """
    #         Handle RPC notification from Redis.

    #         Args:
    #             notification: RPC notification data
    #         """
    #         try:
    method = notification.get("method")
    params = notification.get("params", {})

    #             # Create notification message
    message = self.serializer.serialize_message(
    #                 MessageType.RPC_NOTIFICATION,
    #                 {
    #                     "method": method,
    #                     "params": params,
    #                 }
    #             )

    #             # Get subscribers for this notification type
    subscribers = self.event_manager.get_subscribers(f"rpc:{method}")

    #             # Send to all subscribers
    #             for client_id in subscribers:
    connection = self.connection_manager.get_connection(client_id)
    #                 if connection:
                        self._send_to_connection(connection, message)
    #                 else:
    #                     # Queue message for offline client
                        self.message_queue.enqueue_message(client_id, message)

    #         except Exception as e:
                logger.error(f"Error handling RPC notification: {e}")

    #     def _handle_websocket_event(self, event_data: Dict[str, Any]):
    #         """
    #         Handle WebSocket event from Redis.

    #         Args:
    #             event_data: WebSocket event data
    #         """
    #         try:
    event_type = event_data.get("event")
    data = event_data.get("data", {})
    target = event_data.get("target")

    #             # Create event message
    message = self.serializer.serialize_message(
    #                 MessageType.EVENT,
    #                 {
    #                     "eventType": event_type,
    #                     "data": data,
    #                 }
    #             )

    #             # Send based on target
    #             if target:
    #                 if target.startswith("device:"):
    device_id = target[7:]  # Remove "device:" prefix
    connections = self.connection_manager.get_device_connections(device_id)
    #                     for connection in connections:
                            self._send_to_connection(connection, message)
    #                 else:
    #                     # Room target
    #                     if self.socketio:
    self.socketio.emit('message', message, room = target)
    #             else:
    #                 # Broadcast to all
    #                 if self.socketio:
                        self.socketio.emit('message', message)

    #         except Exception as e:
                logger.error(f"Error handling WebSocket event: {e}")

    #     def _start_ping_monitor(self):
    #         """Start ping monitoring for connections."""
    #         def ping_monitor():
    #             while True:
    #                 try:
                        time.sleep(PING_INTERVAL)

    #                     # Check all connections
    connections = self.connection_manager.get_all_connections()
    #                     for connection in connections:
    #                         if connection.is_stale(CONNECTION_TIMEOUT):
    #                             # Connection is stale, remove it
                                self.connection_manager.remove_connection(connection.client_id)
                                logger.info(f"Removed stale connection: {connection.client_id}")
    #                         else:
    #                             # Send ping
    ping_message = self.serializer.serialize_message(
    #                                 MessageType.PING,
    #                                 {
                                        "timestamp": datetime.now().isoformat(),
    #                                 }
    #                             )
                                self._send_to_connection(connection, ping_message)

    #                 except Exception as e:
                        logger.error(f"Ping monitor error: {e}")

    #         # Start monitor in a separate thread
    monitor_thread = threading.Thread(target=ping_monitor, daemon=True)
            monitor_thread.start()
            logger.info("Ping monitor started")

    #     def broadcast_event(self, event_type: str, data: Dict[str, Any],
    target: Optional[str] = None):
    #         """
    #         Broadcast an event to subscribed clients.

    #         Args:
    #             event_type: Type of event
    #             data: Event data
    #             target: Target (device_id, room_name, or None for all)
    #         """
    #         try:
    #             # Create event message
    message = self.serializer.serialize_message(
    #                 MessageType.EVENT,
    #                 {
    #                     "eventType": event_type,
    #                     "data": data,
    #                 }
    #             )

    #             # Get subscribers
    subscribers = self.event_manager.get_subscribers(event_type)

    #             # Send to subscribers
    #             for client_id in subscribers:
    connection = self.connection_manager.get_connection(client_id)
    #                 if connection:
                        self._send_to_connection(connection, message)
    #                 else:
    #                     # Queue message for offline client
                        self.message_queue.enqueue_message(client_id, message)

    #             # Also publish to Redis for distributed support
    #             if self.redis:
    redis_event = {
    #                     "event": event_type,
    #                     "data": data,
    #                     "target": target,
                        "timestamp": datetime.now().isoformat(),
    #                 }
                    self.redis.publish('websocket_events', json.dumps(redis_event))

                logger.info(f"Broadcasted event '{event_type}' to {len(subscribers)} subscribers")

    #         except Exception as e:
                logger.error(f"Failed to broadcast event '{event_type}': {e}")

    #     def get_statistics(self) -Dict[str, Any]):
    #         """
    #         Get WebSocket handler statistics.

    #         Returns:
    #             Statistics dictionary
    #         """
    connection_stats = self.connection_manager.get_connection_stats()

    #         return {
    #             "connections": connection_stats,
    #             "subscriptions": {
                    "total_event_types": len(self.event_manager.subscriptions),
                    "total_clients": len(self.event_manager.client_subscriptions),
    #             },
    #             "message_queues": {
                    "total_clients": len(self.message_queue.queues),
                    "total_messages": sum(
    #                     q.qsize() for q in self.message_queue.queues.values()
    #                 ),
    #             },
                "rpc_handlers": len(self.rpc_bridge.rpc_handlers),
    #             "capabilities": [
    #                 "rpc",
    #                 "events",
    #                 "queue",
    #                 "serialization",
    #                 "reconnection",
    #                 "monitoring",
    #             ],
    #         }