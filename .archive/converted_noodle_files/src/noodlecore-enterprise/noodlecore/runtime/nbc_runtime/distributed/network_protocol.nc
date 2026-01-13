# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Network protocol for distributed communication.
# """

import json
import socket
import threading
import time
import concurrent.futures.ThreadPoolExecutor
import dataclasses.dataclass,
import enum.Enum
import queue.Queue
import threading.Lock
import typing.Any,

# Placeholder for gRPC/QUIC support (requires installation)
# import grpc
# from grpc import Server, ServerCredentials, ChannelCredentials, secure_channel


# For same-node IPC, use socket-based communication
# @dataclass
class Message
    #     sender: str
    #     receiver: str
    #     type: str
    payload: Any = None
    timestamp: float = field(default_factory=time.time)


class TransportType(Enum)
    TCP = "tcp"
    IPC = "ipc"
    GRPC = "grpc"
    QUIC = "quic"


class NetworkProtocol
    #     """Network protocol for distributed communication."""

    #     def __init__(self):
    self.connections = {}
    self.status = "stopped"
    self.message_queues = {}  # {node: Queue}
    self.lock = Lock()
    self.executor = ThreadPoolExecutor(max_workers=4)
    self.retry_attempts = 3
    self.retry_backoff = 2.0  # Exponential backoff factor

    #     def connect(
    self, node: str, port: int, transport: TransportType = TransportType.TCP
    #     ):
    #         """Connect to a node using specified transport."""
    #         with self.lock:
    #             if node in self.connections:
    #                 return  # Already connected
    self.connections[node] = port
    self.message_queues[node] = Queue()

            # For IPC (same-node), use Unix socket or shared memory
    #         if transport == TransportType.IPC:
                self._setup_ipc_connection(node, port)
    #         else:
                self._setup_tcp_connection(node, port)

    #     def disconnect(self, node: str):
    #         """Disconnect from a node."""
    #         with self.lock:
    #             if node in self.connections:
    #                 del self.connections[node]
    #             if node in self.message_queues:
    #                 del self.message_queues[node]

    #     def _setup_tcp_connection(self, node: str, port: int):
    #         """Setup TCP connection."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((node, port))
    self.connections[node] = sock

    #     def _setup_ipc_connection(self, node: str, port: int):
    #         """Setup IPC for same-node (using TCP loopback for simplicity)."""
    #         # In real impl, use Unix domain sockets or shared memory
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #         sock.connect(("localhost", port))  # Loopback for same-node
    self.connections[node] = sock

    #     def _serialize_payload(self, payload: Any, columnar: bool = False) -> bytes:
    #         """Efficient serialization for network transfer."""
    #         if columnar and isinstance(payload, (list, dict)):
    #             # Simple columnar serialization using json for now; real impl use Apache Arrow
    serialized = json.dumps(payload)
    #         else:
    #             # Efficient serialization (placeholder for Protocol Buffers or MessagePack)
    serialized = json.dumps(payload).encode("utf-8")
    #         return serialized

    #     def _deserialize_payload(self, data: bytes) -> Any:
    #         """Deserialize payload."""
            return json.loads(data.decode("utf-8"))

    #     def send_message(self, node: str, message: Any, retry: bool = True) -> bool:
    #         """Send a message to a node with optional retry."""
    attempts = 0
    #         while attempts < self.retry_attempts:
    #             try:
    #                 with self.lock:
    #                     if node not in self.connections:
                            raise ValueError(f"No connection to node {node}")
    sock = self.connections[node]

    serialized = self._serialize_payload(message)
                    sock.sendall(serialized)

                    # Simulate ordering guarantee (in real, use sequence numbers)
    #                 return True
    #             except Exception as e:
    attempts + = 1
    #                 if not retry or attempts == self.retry_attempts:
    #                     raise e
                    time.sleep(self.retry_backoff**attempts)
    #         return False

    #     def receive_message(self, node: str) -> Optional[Message]:
    #         """Receive a message from a node."""
    #         try:
    #             with self.lock:
    #                 if node not in self.connections:
    #                     return None
    sock = self.connections[node]

    data = sock.recv(4096)
    #             if not data:
    #                 return None
    payload = self._deserialize_payload(data)
                return Message(node, node, "received", payload)
    #         except:
    #             return None

    #     def send_batch(self, node: str, messages: List[Any]) -> bool:
    #         """Send batched messages."""
    batch = {"type": "batch", "messages": messages}
            return self.send_message(node, batch)

    #     def process_batch(self):
    #         """Process received batch."""
    #         # Placeholder for batch processing
    #         pass

    #     def send_zero_copy(self, node: str, data: Any):
    #         """Send data with zero-copy (placeholder for RDMA or shared memory)."""
    #         # In real impl, use mmap for shared memory or RDMA libraries
    #         self.send_message(node, data, retry=False)  # No retry for zero-copy

    #     def send_shared_memory(self, node: str, data: Any):
    #         """Send data via shared memory for local transfer."""
    #         # Placeholder for shared memory transfer
    self.send_message(node, data, retry = False)

    #     def start(self):
    #         """Start the network protocol."""
    self.status = "running"
    #         # Start listener threads in real impl

    #     def stop(self):
    #         """Stop the network protocol."""
    self.status = "stopped"
    #         # Close all connections in real impl


# For gRPC support (stub)
# class GRPCServer:
#     def __init__(self):
#         self.server = None
#
#     def start(self, port):
#         self.server = grpc.server()
#         self.server.add_insecure_port(f'[::]:{port}')
#         self.server.start()
#
#     def stop(self):
#         self.server.stop(0)

# NetworkProtocol would use GRPCServer for TransportType.GRPC
