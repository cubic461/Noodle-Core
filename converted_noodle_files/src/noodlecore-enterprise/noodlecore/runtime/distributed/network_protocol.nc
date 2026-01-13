# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Network Protocol for Distributed Runtime
# ----------------------------------------
# This module implements the high-performance communication protocol for tensor data transfer
# with zero-copy optimization, compression, and encryption capabilities.
# """

import asyncio
import concurrent.futures
import hashlib
import hmac
import json
import logging
import re
import secrets
import socket
import struct
import threading
import time
import zlib
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum
import typing.Any,

import cryptography.fernet.Fernet
import cryptography.hazmat.primitives.hashes
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC

# Import protobuf with version compatibility shim
try
    #     import google.protobuf

    PROTOBUF_VERSION = tuple(map(int, google.protobuf.__version__.split(".")))
except ImportError
    PROTOBUF_VERSION = (0, 0, 0)


# Protobuf compatibility shim
class ProtobufCompatibility
    #     """Compatibility layer for different protobuf versions"""

    #     @staticmethod
    #     def serialize_message(message):
    #         """Serialize protobuf message with version compatibility"""
    #         if PROTOBUF_VERSION >= (4, 0, 0):
    #             # Protocol Buffers 4.x
    return message.SerializeToString(deterministic = True)
    #         else:
    #             # Protocol Buffers 3.x
                return message.SerializeToString()

    #     @staticmethod
    #     def deserialize_message(message_class, data):
    #         """Deserialize protobuf message with version compatibility"""
    message = message_class()
    #         if PROTOBUF_VERSION >= (4, 0, 0):
    #             # Protocol Buffers 4.x
                message.ParseFromString(data)
    #         else:
    #             # Protocol Buffers 3.x
                message.ParseFromString(data)
    #         return message


import multiprocessing
import os

# Import tensor and placement components
import ..mathematical_objects.MathematicalObject
import .scheduler.Node

logger = logging.getLogger(__name__)


class NetworkMessageType(Enum)
    #     """Types of network messages"""

    TENSOR_TRANSFER = "tensor_transfer"
    TENSOR_REQUEST = "tensor_request"
    TENSOR_RESPONSE = "tensor_response"
    HEARTBEAT = "heartbeat"
    TASK_SCHEDULE = "task_schedule"
    TASK_RESULT = "task_result"
    ERROR = "error"
    ACK = "ack"
    COLLECTIVE_OP = "collective_op"


class CompressionAlgorithm(Enum)
    #     """Compression algorithms for tensor data"""

    NONE = "none"
    ZLIB = "zlib"
    GZIP = "gzip"
    LZ4 = "lz4"
    SNAPPY = "snappy"


class EncryptionAlgorithm(Enum)
    #     """Encryption algorithms for tensor data"""

    NONE = "none"
    AES256 = "aes256"
    CHACHA20 = "chacha20"


# @dataclass
class NetworkMessage
    #     """Represents a network message"""

    #     message_type: NetworkMessageType
    #     source_node: str
    target_node: Optional[str] = None
    tensor_id: Optional[str] = None
    data: Optional[bytes] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    timestamp: datetime = field(default_factory=datetime.now)
    message_id: str = field(default_factory=lambda: str(time.time_ns()))
    compression: CompressionAlgorithm = CompressionAlgorithm.NONE
    encryption: EncryptionAlgorithm = EncryptionAlgorithm.NONE


# @dataclass
class TensorDescriptor
    #     """Describes a tensor for network transfer"""

    #     tensor_id: str
    #     shape: Tuple[int, ...]
    #     dtype: str
    #     size_bytes: int
    #     checksum: str
    #     placement: Dict[str, Any]
    flags: int = 0


# @dataclass
class NetworkConnection
    #     """Represents a network connection"""

    #     node_id: str
    #     socket: socket.socket
    #     address: str
    #     port: int
    connected: bool = True
    last_activity: datetime = field(default_factory=datetime.now)
    message_count: int = 0
    bytes_sent: int = 0
    bytes_received: int = 0
    encryption_enabled: bool = False
    compression_enabled: bool = False


# @dataclass
class NetworkStats
    #     """Network statistics and metrics"""

    messages_sent: int = 0
    messages_received: int = 0
    bytes_sent: int = 0
    bytes_received: int = 0
    connection_errors: int = 0
    transfer_errors: int = 0
    active_connections: int = 0
    compression_savings: int = 0
    encryption_operations: int = 0
    average_latency: float = 0.0
    last_activity: datetime = field(default_factory=datetime.now)


# @dataclass
class NetworkConfig
    #     """Configuration for network protocol"""

    listen_port: int = 9999
    max_connections: int = 100
    buffer_size: int = 65536
    #     compression_threshold: int = 1024  # Compress if larger than 1KB
    enable_compression: bool = True
    enable_encryption: bool = False
    encryption_key: Optional[bytes] = None
    max_message_size: int = math.multiply(100, 1024 * 1024  # 100MB)
    timeout: float = 30.0
    retry_attempts: int = 3
    retry_delay: float = 1.0

    #     def _validate_port(self, port: int) -> bool:
    #         """Validate port number is within acceptable range"""
    return 1024 < = port <= 65535

    #     def _validate_message_size(self, size: int) -> bool:
    #         """Validate message size is within acceptable limits"""
    return 0 < size < = self.max_message_size

    #     def _sanitize_node_id(self, node_id: str) -> str:
    #         """Sanitize node ID to prevent injection attacks"""
    #         if not node_id or not isinstance(node_id, str):
                raise ValueError("Invalid node ID")

    #         # Remove potentially dangerous characters
    sanitized = re.sub(r"[^\w\-\.:@]", "", node_id)
    #         if len(sanitized) != len(node_id):
                logger.warning(
    #                 f"Node ID contained potentially dangerous characters and was sanitized: {node_id}"
    #             )

    #         return sanitized

    #     def _generate_auth_token(self) -> str:
    #         """Generate a secure authentication token"""
            return secrets.token_urlsafe(32)

    #     def _derive_encryption_key(self, password: str, salt: bytes = None) -> bytes:
    #         """Derive encryption key from password using PBKDF2"""
    #         if salt is None:
    salt = secrets.token_bytes(16)

    kdf = PBKDF2HMAC(
    algorithm = hashes.SHA256(),
    length = 32,
    salt = salt,
    #             iterations=200000,  # Increased from 100000 for better security
    #         )
            return kdf.derive(password.encode()), salt

    #     def _validate_auth_token(self, token: str) -> bool:
    #         """Validate authentication token using HMAC signature"""
    #         if not token:
    #             return False

    #         try:
    #             # Split token into payload and signature
    parts = token.split(".")
    #             if len(parts) != 2:
    #                 return False

    payload, received_signature = parts

    #             # Verify signature using HMAC-SHA256
    expected_signature = hmac.new(
                    (
                        self.shared_secret.encode()
    #                     if hasattr(self, "shared_secret")
    #                     else b"noodle-default-secret"
    #                 ),
                    payload.encode(),
    #                 hashlib.sha256,
                ).hexdigest()

    #             # Use constant-time comparison to prevent timing attacks
                return hmac.compare_digest(received_signature, expected_signature)

    #         except Exception as e:
                logger.error(f"Token validation error: {e}")
    #             return False

    enable_zero_copy: bool = True
    enable_batching: bool = True
    batch_timeout: float = 0.1
    max_batch_size: int = 10


class NetworkServer
    #     """Network server for handling incoming connections"""

    #     def __init__(self, config: NetworkConfig):
    self.config = config
    self.server_socket = None
    self.connections: Dict[str, NetworkConnection] = {}
    self.stats = NetworkStats()
    self.running = False
    self.accept_thread = None
    self.message_handlers: Dict[NetworkMessageType, Callable] = {}

    #     def start(self):
    #         """Start the network server"""
    #         if self.running:
    #             return

    self.running = True
    self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind(("", self.config.listen_port))
            self.server_socket.listen(self.config.max_connections)

    self.accept_thread = threading.Thread(
    target = self._accept_connections, daemon=True
    #         )
            self.accept_thread.start()

    #     def stop(self):
    #         """Stop the network server"""
    #         if not self.running:
    #             return

    self.running = False

    #         # Close all connections
    #         for connection in self.connections.values():
    connection.connected = False
    #             try:
                    connection.socket.close()
    #             except:
    #                 pass

    #         # Close server socket
    #         if self.server_socket:
    #             try:
                    self.server_socket.close()
    #             except:
    #                 pass

    #         # Wait for accept thread to finish
    #         if self.accept_thread:
    self.accept_thread.join(timeout = 5.0)

    #     def _accept_connections(self):
    #         """Accept incoming connections"""
    #         while self.running:
    #             try:
    client_socket, address = self.server_socket.accept()
    connection = NetworkConnection(
    node_id = f"node_{len(self.connections)}",
    socket = client_socket,
    address = address[0],
    port = address[1],
    #                 )
    self.connections[connection.node_id] = connection
    self.stats.active_connections = len(self.connections)
    self.stats.last_activity = datetime.now()

    #                 # Start handler thread for this connection
    handler_thread = threading.Thread(
    target = self._handle_connection, args=(connection,), daemon=True
    #                 )
                    handler_thread.start()

                except (OSError, socket.error):
    #                 if self.running:
                        logger.error("Error accepting connection")
    #                 break

    #     def _handle_connection(self, connection: NetworkConnection):
    #         """Handle a single connection"""
    #         while connection.connected and self.running:
    #             try:
    #                 # Receive message length
    length_data = connection.socket.recv(4)
    #                 if not length_data:
    #                     break

    message_length = struct.unpack("!I", length_data)[0]

    #                 # Receive message data
    data = b""
    #                 while len(data) < message_length:
    chunk = connection.socket.recv(
                            min(message_length - len(data), self.config.buffer_size)
    #                     )
    #                     if not chunk:
    #                         break
    data + = chunk

    #                 if len(data) != message_length:
    #                     break

    #                 # Parse message
    message = self._parse_message(data)
    #                 if message:
                        self._handle_message(message, connection)

    connection.message_count + = 1
    connection.last_activity = datetime.now()

                except (OSError, socket.error, struct.error):
    #                 break

    #         # Clean up connection
    connection.connected = False
    #         try:
                connection.socket.close()
    #         except:
    #             pass

    #         if connection.node_id in self.connections:
    #             del self.connections[connection.node_id]
    self.stats.active_connections = len(self.connections)

    #     def _parse_message(self, data: bytes) -> Optional[NetworkMessage]:
    #         """Parse a network message from bytes"""
    #         try:
    message_dict = json.loads(data.decode("utf-8"))
                return NetworkMessage(
    message_type = NetworkMessageType(message_dict["message_type"]),
    source_node = message_dict["source_node"],
    target_node = message_dict.get("target_node"),
    tensor_id = message_dict.get("tensor_id"),
    data = message_dict.get("data"),
    metadata = message_dict.get("metadata", {}),
    timestamp = datetime.fromisoformat(message_dict["timestamp"]),
    message_id = message_dict["message_id"],
    compression = CompressionAlgorithm(
                        message_dict.get("compression", "none")
    #                 ),
    encryption = EncryptionAlgorithm(message_dict.get("encryption", "none")),
    #             )
            except (json.JSONDecodeError, KeyError, ValueError):
    #             return None

    #     def _handle_message(self, message: NetworkMessage, connection: NetworkConnection):
    #         """Handle an incoming message"""
    self.stats.messages_received + = 1
    self.stats.bytes_received + = len(str(message).encode("utf-8"))

    #         # Find appropriate handler
    handler = self.message_handlers.get(message.message_type)
    #         if handler:
    #             try:
                    handler(message, connection)
    #             except Exception as e:
                    logger.error(f"Error handling message: {e}")

    #     def register_handler(self, message_type: NetworkMessageType, handler: Callable):
    #         """Register a message handler"""
    self.message_handlers[message_type] = handler

    #     def send_message(
    #         self, connection: NetworkConnection, message: NetworkMessage
    #     ) -> bool:
    #         """Send a message to a connection"""
    #         try:
    #             # Serialize message
    message_dict = {
    #                 "message_type": message.message_type.value,
    #                 "source_node": message.source_node,
    #                 "target_node": message.target_node,
    #                 "tensor_id": message.tensor_id,
    #                 "data": message.data,
    #                 "metadata": message.metadata,
                    "timestamp": message.timestamp.isoformat(),
    #                 "message_id": message.message_id,
    #                 "compression": message.compression.value,
    #                 "encryption": message.encryption.value,
    #             }

    data = json.dumps(message_dict).encode("utf-8")

    #             # Send message length
                connection.socket.send(struct.pack("!I", len(data)))

    #             # Send message data
                connection.socket.sendall(data)

    #             # Update stats
    connection.message_count + = 1
    connection.bytes_sent + = len(data)
    self.stats.messages_sent + = 1
    self.stats.bytes_sent + = len(data)
    self.stats.last_activity = datetime.now()

    #             return True

            except (OSError, socket.error):
    #             return False


class NetworkClient
    #     """Network client for connecting to remote servers"""

    #     def __init__(self, config: NetworkConfig):
    self.config = config
    self.connections: Dict[str, NetworkConnection] = {}
    self.stats = NetworkStats()
    self.running = False
    self.response_handlers: Dict[str, Callable] = {}  # message_id to callback

    #     def connect(self, target_node: str, host: str, port: int) -> bool:
    #         """Connect to a remote server"""
    #         if self.running:
                logger.warning("Client is already running")
    #             return False

    #         try:
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                client_socket.settimeout(self.config.timeout)
                client_socket.connect((host, port))

    connection = NetworkConnection(
    node_id = target_node,
    socket = client_socket,
    address = host,
    port = port,
    connected = True,
    #             )

    self.connections[target_node] = connection
    self.stats.active_connections + = 1
    self.running = True

    #             # Start response handler thread
    handler_thread = threading.Thread(
    target = self._receive_responses, args=(connection,), daemon=True
    #             )
                handler_thread.start()

                logger.info(f"Connected to {target_node} at {host}:{port}")
    #             return True

            except (OSError, socket.error) as e:
                logger.error(f"Failed to connect to {target_node}: {e}")
    #             return False

    #     def send_request(self, message: NetworkMessage, target_node: str) -> bool:
    #         """Send a request message to target node"""
    #         if target_node not in self.connections:
                logger.error(f"No connection to {target_node}")
    #             return False

    connection = self.connections[target_node]
    #         if not connection.connected:
                logger.error(f"Connection to {target_node} is closed")
    #             return False

    #         try:
    #             # Serialize message
    message_dict = {
    #                 "message_type": message.message_type.value,
    #                 "source_node": message.source_node,
    #                 "target_node": message.target_node,
    #                 "tensor_id": message.tensor_id,
    #                 "data": message.data,
    #                 "metadata": message.metadata,
                    "timestamp": message.timestamp.isoformat(),
    #                 "message_id": message.message_id,
    #                 "compression": message.compression.value,
    #                 "encryption": message.encryption.value,
    #             }

    data = json.dumps(message_dict).encode("utf-8")

    #             # Send length prefix
                connection.socket.send(struct.pack("!I", len(data)))

    #             # Send data
                connection.socket.sendall(data)

    #             # Update stats
    self.stats.messages_sent + = 1
    self.stats.bytes_sent + = len(data)
    connection.bytes_sent + = len(data)
    connection.message_count + = 1
    connection.last_activity = datetime.now()

                logger.debug(f"Sent request {message.message_id} to {target_node}")
    #             return True

            except (OSError, socket.error) as e:
                logger.error(f"Failed to send request to {target_node}: {e}")
    connection.connected = False
    #             if target_node in self.connections:
    #                 del self.connections[target_node]
    self.stats.active_connections - = 1
    #             return False

    #     def _receive_responses(self, connection: NetworkConnection):
    #         """Receive and handle responses from server"""
    #         while connection.connected and self.running:
    #             try:
    #                 # Receive length
    length_data = connection.socket.recv(4)
    #                 if not length_data:
    #                     break

    message_length = struct.unpack("!I", length_data)[0]

    #                 # Receive data
    data = b""
    #                 while len(data) < message_length:
    chunk = connection.socket.recv(
                            min(message_length - len(data), self.config.buffer_size)
    #                     )
    #                     if not chunk:
    #                         break
    data + = chunk

    #                 if len(data) != message_length:
    #                     break

    #                 # Parse message
    message = self._parse_message(data)
    #                 if message:
                        self._handle_response(message, connection)

    connection.message_count + = 1
    connection.bytes_received + = len(data)
    connection.last_activity = datetime.now()

                except (OSError, socket.error, struct.error):
    #                 break

    #         # Cleanup
    connection.connected = False
    #         try:
                connection.socket.close()
    #         except:
    #             pass

    #         if connection.node_id in self.connections:
    #             del self.connections[connection.node_id]
    self.stats.active_connections - = 1

    #     def _parse_message(self, data: bytes) -> Optional[NetworkMessage]:
            """Parse incoming message (same as server)"""
    #         try:
    message_dict = json.loads(data.decode("utf-8"))
                return NetworkMessage(
    message_type = NetworkMessageType(message_dict["message_type"]),
    source_node = message_dict["source_node"],
    target_node = message_dict.get("target_node"),
    tensor_id = message_dict.get("tensor_id"),
    data = message_dict.get("data"),
    metadata = message_dict.get("metadata", {}),
    timestamp = datetime.fromisoformat(message_dict["timestamp"]),
    message_id = message_dict["message_id"],
    compression = CompressionAlgorithm(
                        message_dict.get("compression", "none")
    #                 ),
    encryption = EncryptionAlgorithm(message_dict.get("encryption", "none")),
    #             )
            except (json.JSONDecodeError, KeyError, ValueError):
    #             return None

    #     def _handle_response(self, message: NetworkMessage, connection: NetworkConnection):
    #         """Handle received response"""
    self.stats.messages_received + = 1
    self.stats.bytes_received + = len(str(message).encode("utf-8"))

    #         # Call registered handler if any
    message_id = message.message_id
    #         if message_id in self.response_handlers:
    #             try:
                    self.response_handlers[message_id](message)
    #                 del self.response_handlers[message_id]
    #             except Exception as e:
                    logger.error(f"Error handling response {message_id}: {e}")

            logger.debug(f"Handled response {message_id} from {connection.node_id}")

    #     def register_response_handler(self, message_id: str, handler: Callable):
    #         """Register a handler for a specific response message_id"""
    self.response_handlers[message_id] = handler

    #     def disconnect(self, target_node: Optional[str] = None):
    #         """Disconnect from target node or all"""
    #         if target_node:
    #             if target_node in self.connections:
    connection = self.connections[target_node]
    connection.connected = False
    #                 try:
                        connection.socket.close()
    #                 except:
    #                     pass
    #                 del self.connections[target_node]
    self.stats.active_connections - = 1
                    logger.info(f"Disconnected from {target_node}")
    #         else:
    #             for conn in list(self.connections.values()):
                    self.disconnect(conn.node_id)
    self.running = False
                logger.info("Disconnected from all servers")


class NetworkProtocol
    #     """
    #     High-performance network protocol for tensor data transfer
    #     """

    #     def __init__(self, config: NetworkConfig = None, local_node: Node = None):
    #         """
    #         Initialize the network protocol

    #         Args:
    #             config: Network configuration
    #             local_node: Local node information
    #         """
    self.config = config or NetworkConfig()
    self.local_node = local_node or Node(
    id = "local",
    name = "LocalNode",
    address = "localhost",
    port = self.config.listen_port,
    #         )

    #         # Network state
    self.connections: Dict[str, socket.socket] = {}
    #         self.shared_memory_regions: Dict[
    #             str, multiprocessing.shared_memory.SharedMemory
    ] = {}
    self.message_handlers: Dict[NetworkMessageType, callable] = {}
    self.pending_acks: Dict[str, asyncio.Event] = {}
    self.transfer_stats = {
    #             "messages_sent": 0,
    #             "messages_received": 0,
    #             "bytes_sent": 0,
    #             "bytes_received": 0,
    #             "compression_savings": 0,
    #             "transfer_errors": 0,
    #             "active_transfers": 0,
    #         }

    #         # Security components
    self.auth_token = self._generate_auth_token()
    self.encryption_key = None
    self.cipher_suite = None
    self.shared_secret = secrets.token_bytes(32)  # For JWT signature verification
            self._initialize_encryption()

    #         # Rate limiting
    self.message_rate_limiter = {}
    self.max_messages_per_second = 100

    #         # Threading
    self.server_thread = None
    self.running = False
    self.batch_buffer: List[NetworkMessage] = []
    self.batch_lock = threading.Lock()

    #         # Setup message handlers
    #         for msg_type in NetworkMessageType:
    self.message_handlers[msg_type] = getattr(self, f"_handle_{msg_type.value}")

    #         logger.info(f"Network protocol initialized for node {self.local_node.name}")

    #     def _initialize_encryption(self):
    #         """Initialize encryption if enabled"""
    #         if self.config.enable_encryption and self.config.encryption_key:
    #             try:
    self.cipher_suite = Fernet(self.config.encryption_key)
                    logger.info("Encryption initialized successfully")
    #             except Exception as e:
                    logger.error(f"Failed to initialize encryption: {e}")
    self.config.enable_encryption = False

    #     def _encrypt_data(self, data: bytes) -> bytes:
    #         """Encrypt data using configured encryption"""
    #         if not self.cipher_suite:
    #             return data

    #         try:
                return self.cipher_suite.encrypt(data)
    #         except Exception as e:
                logger.error(f"Encryption failed: {e}")
    #             return data

    #     def _decrypt_data(self, encrypted_data: bytes) -> bytes:
    #         """Decrypt data using configured encryption"""
    #         if not self.cipher_suite:
    #             return encrypted_data

    #         try:
                return self.cipher_suite.decrypt(encrypted_data)
    #         except Exception as e:
                logger.error(f"Decryption failed: {e}")
                raise ValueError("Invalid encrypted data")

    #     def _serialize_protobuf_message(self, message):
    #         """Serialize protobuf message using compatibility layer"""
            return ProtobufCompatibility.serialize_message(message)

    #     def _deserialize_protobuf_message(self, message_class, data):
    #         """Deserialize protobuf message using compatibility layer"""
            return ProtobufCompatibility.deserialize_message(message_class, data)

    #     def _validate_message_rate(self, node_id: str) -> bool:
    #         """Validate message rate to prevent DoS attacks"""
    current_time = time.time()

    #         if node_id not in self.message_rate_limiter:
    self.message_rate_limiter[node_id] = []

            # Remove old messages (older than 1 second)
    self.message_rate_limiter[node_id] = [
    #             timestamp
    #             for timestamp in self.message_rate_limiter[node_id]
    #             if current_time - timestamp < 1.0
    #         ]

    #         # Check if rate limit exceeded
    #         if len(self.message_rate_limiter[node_id]) >= self.max_messages_per_second:
    #             logger.warning(f"Rate limit exceeded for node {node_id}")
    #             return False

    #         # Add current message timestamp
            self.message_rate_limiter[node_id].append(current_time)
    #         return True

    #     def _validate_message_content(self, message: NetworkMessage) -> bool:
    #         """Validate message content for security"""
    #         # Validate node IDs
    #         try:
    message.source_node = self.config._sanitize_node_id(message.source_node)
    #             if message.target_node:
    message.target_node = self.config._sanitize_node_id(message.target_node)
    #         except ValueError as e:
                logger.error(f"Invalid node ID in message: {e}")
    #             return False

    #         # Validate message size
    #         if message.data and len(message.data) > self.config.max_message_size:
                logger.error(
                    f"Message size exceeds maximum limit: {len(message.data)} bytes"
    #             )
    #             return False

    #         # Validate tensor ID if present
    #         if message.tensor_id:
    #             if not re.match(r"^[a-zA-Z0-9_\-\.]+$", message.tensor_id):
                    logger.error(f"Invalid tensor ID format: {message.tensor_id}")
    #                 return False

    #         return True

    #     def start(self):
    #         """Start the network protocol"""
    #         if self.running:
                logger.warning("Network protocol is already running")
    #             return

    self.running = True
            logger.info("Starting network protocol...")

    #         try:
    #             # Start server thread
    self.server_thread = threading.Thread(target=self._server_loop, daemon=True)
                self.server_thread.start()

                logger.info("Network protocol started successfully")

    #         except Exception as e:
    self.running = False
                logger.error(f"Failed to start network protocol: {e}")
    #             raise

    #     def stop(self):
    #         """Stop the network protocol"""
    #         if not self.running:
                logger.warning("Network protocol is not running")
    #             return

    self.running = False
            logger.info("Stopping network protocol...")

    #         try:
    #             # Close all connections
    #             for conn in self.connections.values():
    #                 try:
                        conn.close()
    #                 except:
    #                     pass

                self.connections.clear()

    #             # Wait for server thread to finish
    #             if self.server_thread:
    self.server_thread.join(timeout = 5.0)

                logger.info("Network protocol stopped successfully")

    #         except Exception as e:
                logger.error(f"Error stopping network protocol: {e}")
    #             raise

    #     def register_message_handler(
    #         self, message_type: NetworkMessageType, handler: callable
    #     ):
    #         """
    #         Register a message handler for a specific message type

    #         Args:
    #             message_type: Type of message to handle
    #             handler: Handler function
    #         """
    self.message_handlers[message_type] = handler

    #     def send_message(self, message: NetworkMessage, target_node: str = None):
    #         """
    #         Send a message to a target node

    #         Args:
    #             message: Network message to send
                target_node: Target node ID (optional)
    #         """
    #         # Validate target node
    #         if target_node and not self.config._sanitize_node_id(target_node):
                raise ValueError(f"Invalid target node ID: {target_node}")

    #         # Check rate limiting
    #         if target_node and not self._validate_message_rate(target_node):
    #             raise ValueError(f"Rate limit exceeded for node {target_node}")

    #         # Validate message content
    #         if not self._validate_message_content(message):
                raise ValueError("Invalid message content")

    #         # Encrypt data if encryption is enabled
    #         if self.config.enable_encryption:
    message.data = self._encrypt_data(message.data)
    message.encryption = EncryptionAlgorithm.AES256

    #         # Serialize protobuf data if present
    #         if hasattr(message, "protobuf_data") and message.protobuf_data:
    #             try:
    message.data = self._serialize_protobuf_message(message.protobuf_data)
    #             except Exception as e:
                    logger.error(f"Failed to serialize protobuf message: {e}")
                    raise ValueError(f"Protobuf serialization failed: {e}")

    #         # TODO: Implement actual message sending logic
            logger.info(
    #             f"Sending message {message.message_id} from {message.source_node} to {target_node or 'broadcast'}"
    #         )

    #     def _server_loop(self):
    #         """Main server loop for handling incoming connections"""
    #         # TODO: Implement server loop
    #         pass

    #     def _handle_tensor_transfer(self, message: NetworkMessage):
    #         """Handle tensor transfer messages"""
            logger.info(f"Received tensor transfer: {message.tensor_id}")

    #     def _handle_tensor_request(self, message: NetworkMessage):
    #         """Handle tensor request messages"""
            logger.info(f"Received tensor request: {message.tensor_id}")

    #     def _handle_tensor_response(self, message: NetworkMessage):
    #         """Handle tensor response messages"""
            logger.info(f"Received tensor response: {message.tensor_id}")

    #     def _handle_heartbeat(self, message: NetworkMessage):
    #         """Handle heartbeat messages"""
            logger.info(f"Received heartbeat from {message.source_node}")

    #     def _handle_task_schedule(self, message: NetworkMessage):
    #         """Handle task schedule messages"""
            logger.info(
                f"Received task schedule: {message.metadata.get('task_id', 'unknown')}"
    #         )

    #     def _handle_task_result(self, message: NetworkMessage):
    #         """Handle task result messages"""
            logger.info(
                f"Received task result: {message.metadata.get('task_id', 'unknown')}"
    #         )

    #     def _handle_error(self, message: NetworkMessage):
    #         """Handle error messages"""
            logger.error(
                f"Received error from {message.source_node}: {message.metadata.get('error', 'unknown error')}"
    #         )

    #     def _handle_ack(self, message: NetworkMessage):
    #         """Handle acknowledgment messages"""
            logger.info(
    #             f"Received ACK for message {message.metadata.get('original_message_id', 'unknown')}"
    #         )

    #     def _handle_collective_op(self, message: NetworkMessage):
    #         """Handle collective operation messages"""
            logger.info(
                f"Received collective operation: {message.metadata.get('operation', 'unknown')}"
    #         )

    #     def _generate_auth_token(self) -> str:
    #         """Generate a secure authentication token"""
            return secrets.token_urlsafe(32)
