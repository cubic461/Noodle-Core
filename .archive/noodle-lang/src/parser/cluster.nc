# Converted from Python to NoodleCore
# Original file: src

# """Cluster management for distributed vector database.

# Coordinates sharding, replication, and node communication.
# """

import asyncio
import http.server
import json
import logging
import socket
import socketserver
import threading
import time
import uuid
import dataclasses.asdict
import enum.Enum
import typing.Any
import urllib.parse.urlparse

import requests

import noodlecore.runtime.matrix.Matrix

import .replication.(
#     ConsistentReplicationStrategy,
#     ReplicationConfig,
#     ReplicationManager,
#     ReplicationStrategy,
# )
import .sharding.ConsistentHashRing

logger = logging.getLogger(__name__)


class NodeStatus(Enum)
    #     """Node status."""

    ACTIVE = "active"
    STANDBY = "standby"
    FAILED = "failed"
    JOINING = "joining"
    LEAVING = "leaving"


dataclass
class NodeInfo
    #     """Information about a cluster node."""

    #     node_id: str
    #     host: str
    #     port: int
    status: NodeStatus = NodeStatus.ACTIVE
    last_heartbeat: float = 0.0
    vector_count: int = 0
    shard_count: int = 0
    memory_usage: float = 0.0
    cpu_usage: float = 0.0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
            return asdict(self)

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"NodeInfo"):
    #         """Create from dictionary."""
            return cls(
    node_id = data["node_id"],
    host = data["host"],
    port = data["port"],
    status = NodeStatus(data["status"]),
    last_heartbeat = data.get("last_heartbeat", 0.0),
    vector_count = data.get("vector_count", 0),
    shard_count = data.get("shard_count", 0),
    memory_usage = data.get("memory_usage", 0.0),
    cpu_usage = data.get("cpu_usage", 0.0),
    #         )


class ClusterNode
    #     """A node in the distributed vector database cluster."""

    #     def __init__(
    #         self,
    #         node_id: str,
    #         host: str,
    #         port: int,
    cluster_manager: "ClusterManager" = None,
    #     ):""Initialize cluster node.

    #         Args:
    #             node_id: Unique ID for this node
    #             host: Host address
    #             port: Port number
    #             cluster_manager: Cluster manager (if this is a managed node)
    #         """
    self.node_id = node_id
    self.host = host
    self.port = port
    self.cluster_manager = cluster_manager

    #         # Node state
    self.status = NodeStatus.JOINING
    self.last_heartbeat = time.time()

    #         # Vector index
    self.local_index = {}

    #         # HTTP server for communication
    self.http_server = None
    self.server_thread = None

    #         # State synchronization
    self.state_lock = threading.Lock()

    #         # Metrics
    self.vector_count = 0
    self.memory_usage = 0.0
    self.cpu_usage = 0.0

    #     def start(self) -None):
    #         """Start the node."""
    #         # Start HTTP server
    handler = NodeRequestHandler(self)
    self.http_server = socketserver.ThreadingTCPServer(
                (self.host, self.port), handler
    #         )
    self.server_thread = threading.Thread(
    target = self.http_server.serve_forever, daemon=True
    #         )
            self.server_thread.start()

    #         # Update status
    self.status = NodeStatus.ACTIVE
    self.last_heartbeat = time.time()

            logger.info(f"Node {self.node_id} started on {self.host}:{self.port}")

    #     def stop(self) -None):
    #         """Stop the node."""
    #         if self.http_server:
                self.http_server.shutdown()
                self.http_server.server_close()

    self.status = NodeStatus.FAILED
            logger.info(f"Node {self.node_id} stopped")

    #     def add_vector(
    self, vector_id: str, vector: Matrix, metadata: Dict[str, Any] = None
    #     ) -None):
    #         """Add a vector to this node.

    #         Args:
    #             vector_id: ID of the vector
    #             vector: Vector data
    #             metadata: Optional metadata
    #         """
    #         with self.state_lock:
    self.local_index[vector_id] = {"vector": vector, "metadata": metadata or {}}
    self.vector_count + = 1
    self.memory_usage + = vector.size * 4  # Estimate size

    #     def remove_vector(self, vector_id: str) -bool):
    #         """Remove a vector from this node.

    #         Args:
    #             vector_id: ID of the vector

    #         Returns:
    #             True if vector was removed, False if not found
    #         """
    #         with self.state_lock:
    #             if vector_id in self.local_index:
    vector = self.local_index[vector_id]["vector"]
    #                 del self.local_index[vector_id]
    self.vector_count - = 1
    self.memory_usage - = vector.size * 4
    #                 return True
    #             return False

    #     def get_vector(self, vector_id: str) -Optional[Dict[str, Any]]):
    #         """Get a vector by ID.

    #         Args:
    #             vector_id: ID of the vector

    #         Returns:
    #             Dictionary with 'vector' and 'metadata', or None if not found
    #         """
    #         with self.state_lock:
                return self.local_index.get(vector_id)

    #     def search_local(
    self, query_vector: Matrix, k: int = 5, filter_func: callable = None
    #     ) -List[Tuple[str, float]]):
    #         """Search locally for similar vectors.

    #         Args:
    #             query_vector: Query vector
    #             k: Number of results to return
    #             filter_func: Optional filter function

    #         Returns:
                List of (vector_id, score) tuples
    #         """
    results = []

    #         for vector_id, data in self.local_index.items():
    #             if filter_func and not filter_func(data["metadata"]):
    #                 continue

    #             # Calculate cosine similarity
    score = self._calculate_similarity(query_vector, data["vector"])
                results.append((vector_id, score))

    #         # Sort by score and return top k
    results.sort(key = lambda x: x[1], reverse=True)
    #         return results[:k]

    #     def _calculate_similarity(self, vec1: Matrix, vec2: Matrix) -float):
    #         """Calculate cosine similarity between two vectors.

    #         Args:
    #             vec1: First vector
    #             vec2: Second vector

    #         Returns:
    #             Cosine similarity score
    #         """
    #         # Simplified cosine similarity calculation
    dot_product = 0.0
    norm1 = 0.0
    norm2 = 0.0

    #         for i in range(vec1.size):
    dot_product + = vec1.data[i] * vec2.data[i]
    norm1 + = vec1.data[i] * * 2
    norm2 + = vec2.data[i] * * 2

    #         if norm1 = 0 or norm2 = 0:
    #             return 0.0

            return dot_product / (norm1**0.5 * norm2**0.5)

    #     def get_status(self) -Dict[str, Any]):
    #         """Get node status information.

    #         Returns:
    #             Dictionary with node status
    #         """
    #         return {
    #             "node_id": self.node_id,
    #             "host": self.host,
    #             "port": self.port,
    #             "status": self.status.value,
    #             "last_heartbeat": self.last_heartbeat,
    #             "vector_count": self.vector_count,
    #             "memory_usage": self.memory_usage,
    #             "cpu_usage": self.cpu_usage,
                "local_index_size": len(self.local_index),
    #         }

    #     def handle_request(
    #         self, path: str, method: str, data: Dict[str, Any]
    #     ) -Dict[str, Any]):
    #         """Handle an incoming HTTP request.

    #         Args:
    #             path: Request path
    #             method: HTTP method
    #             data: Request data

    #         Returns:
    #             Response data
    #         """
    #         try:
    #             if path == "/status":
                    return {"status": "ok", "data": self.get_status()}

    #             elif path == "/vector" and method == "GET":
    vector_id = data.get("vector_id")
    #                 if not vector_id:
    #                     return {"status": "error", "message": "vector_id required"}

    vector = self.get_vector(vector_id)
    #                 if vector:
    #                     return {
    #                         "status": "ok",
    #                         "data": {
                                "vector": vector["vector"].to_dict(),
    #                             "metadata": vector["metadata"],
    #                         },
    #                     }
    #                 else:
    #                     return {"status": "error", "message": "vector not found"}

    #             elif path == "/vector" and method == "POST":
    vector_id = data.get("vector_id")
    vector_data = data.get("vector")
    metadata = data.get("metadata", {})

    #                 if not vector_id or not vector_data:
    #                     return {
    #                         "status": "error",
    #                         "message": "vector_id and vector required",
    #                     }

    #                 # Create vector matrix
    vector = Matrix(vector_data["shape"], data=vector_data["data"])

    #                 # Add vector
                    self.add_vector(vector_id, vector, metadata)

    #                 return {"status": "ok", "message": "vector added"}

    #             elif path == "/vector" and method == "DELETE":
    vector_id = data.get("vector_id")
    #                 if not vector_id:
    #                     return {"status": "error", "message": "vector_id required"}

    #                 if self.remove_vector(vector_id):
    #                     return {"status": "ok", "message": "vector removed"}
    #                 else:
    #                     return {"status": "error", "message": "vector not found"}

    #             elif path == "/search" and method == "POST":
    query_data = data.get("query")
    k = data.get("k", 5)
    filter_func = data.get("filter_func")

    #                 if not query_data:
    #                     return {"status": "error", "message": "query required"}

    #                 # Create query vector
    query_vector = Matrix(query_data["shape"], data=query_data["data"])

    #                 # Search
    results = self.search_local(query_vector, k)

    #                 return {
    #                     "status": "ok",
    #                     "data": {
    #                         "results": [
    #                             {"vector_id": vector_id, "score": score}
    #                             for vector_id, score in results
    #                         ]
    #                     },
    #                 }

    #             else:
    #                 return {"status": "error", "message": "invalid endpoint"}

    #         except Exception as e:
                logger.error(f"Error handling request: {e}")
                return {"status": "error", "message": str(e)}

    #     def update_heartbeat(self) -None):
    #         """Update heartbeat timestamp."""
    self.last_heartbeat = time.time()


class NodeRequestHandler(http.server.BaseHTTPRequestHandler)
    #     """HTTP request handler for cluster nodes."""

    #     def __init__(self, node: ClusterNode, *args, **kwargs):""Initialize request handler.

    #         Args:
    #             node: Cluster node instance
    #         """
    self.node = node
            super().__init__(*args, **kwargs)

    #     def do_GET(self):
    #         """Handle GET requests."""
    #         try:
    parsed_path = urlparse(self.path)
    data = {
    #                 "path": parsed_path.path,
    #                 "method": "GET",
    #                 "query": dict(parsed_path.query) if parsed_path.query else {},
    #             }

    response = self.node.handle_request(data["path"], data["method"], data)

                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(response).encode())

    #         except Exception as e:
                logger.error(f"Error handling GET request: {e}")
                self.send_response(500)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(
                    json.dumps({"status": "error", "message": str(e)}).encode()
    #             )

    #     def do_POST(self):
    #         """Handle POST requests."""
    #         try:
    content_length = int(self.headers["Content-Length"])
    post_data = self.rfile.read(content_length)

    data = json.loads(post_data.decode())
    parsed_path = urlparse(self.path)

    data["path"] = parsed_path.path
    data["method"] = "POST"

    response = self.node.handle_request(data["path"], data["method"], data)

                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(response).encode())

    #         except Exception as e:
                logger.error(f"Error handling POST request: {e}")
                self.send_response(500)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(
                    json.dumps({"status": "error", "message": str(e)}).encode()
    #             )

    #     def log_message(self, format, *args):
    #         """Override to use our logger."""
            logger.info(format % args)


class ClusterManager
    #     """Manages a cluster of vector database nodes."""

    #     def __init__(self, config: Dict[str, Any] = None):""Initialize cluster manager.

    #         Args:
    #             config: Cluster configuration
    #         """
    self.config = config or {}
    self.nodes: Dict[str, NodeInfo] = {}
    self.local_node: Optional[ClusterNode] = None

    #         # Sharding and replication
    self.sharded_index = ShardedVectorIndex()
    self.replication_manager = ReplicationManager(
                ReplicationConfig(
    replication_factor = self.config.get("replication_factor", 3),
    max_concurrent_replications = self.config.get(
    #                     "max_concurrent_replications", 5
    #                 ),
    #             )
    #         )

    #         # Cluster state
    self.cluster_lock = threading.Lock()
    self.running = False

    #         # Callbacks
    self.on_node_joined: Optional[Callable] = None
    self.on_node_left: Optional[Callable] = None
    self.on_node_failed: Optional[Callable] = None

    #     def start(self) -None):
    #         """Start the cluster manager."""
    #         if self.running:
    #             return

    self.running = True

    #         # Start replication manager
            self.replication_manager.start()

            logger.info("Cluster manager started")

    #     def stop(self) -None):
    #         """Stop the cluster manager."""
    self.running = False

    #         # Stop replication manager
            self.replication_manager.stop()

    #         # Stop all nodes
    #         for node_info in self.nodes.values():
                self._stop_node(node_info.node_id)

            logger.info("Cluster manager stopped")

    #     def create_cluster(self, node_configs: List[Dict[str, Any]]) -None):
    #         """Create a cluster with the given node configurations.

    #         Args:
    #             node_configs: List of node configurations with 'node_id', 'host', 'port'
    #         """
    #         for node_config in node_configs:
    node_id = node_config["node_id"]
    host = node_config["host"]
    port = node_config["port"]

    #             # Create node
    node = ClusterNode(node_id, host, port, self)
                node.start()

    #             # Add to cluster
    #             with self.cluster_lock:
    self.nodes[node_id] = NodeInfo(
    node_id = node_id,
    host = host,
    port = port,
    status = NodeStatus.ACTIVE,
    last_heartbeat = time.time(),
    #                 )

    #             # Add to sharded index
                self.sharded_index.add_node(node_id, node.local_index)

                logger.info(f"Added node {node_id} to cluster")

    #     def join_cluster(self, node_id: str, host: str, port: int) -None):
    #         """Join an existing cluster.

    #         Args:
    #             node_id: ID for this node
    #             host: Host address
    #             port: Port number
    #         """
    #         # Create local node
    self.local_node = ClusterNode(node_id, host, port, self)
            self.local_node.start()

    #         # Add to cluster
    #         with self.cluster_lock:
    self.nodes[node_id] = NodeInfo(
    node_id = node_id,
    host = host,
    port = port,
    status = NodeStatus.ACTIVE,
    last_heartbeat = time.time(),
    #             )

    #         # Add to sharded index
            self.sharded_index.add_node(node_id, self.local_node.local_index)

            # Notify other nodes (in real implementation, this would be a cluster-wide operation)
            logger.info(f"Node {node_id} joined cluster")

    #         if self.on_node_joined:
                self.on_node_joined(node_id)

    #     def leave_cluster(self, node_id: str) -None):
    #         """Leave the cluster.

    #         Args:
    #             node_id: ID of the node to remove
    #         """
    #         with self.cluster_lock:
    #             if node_id not in self.nodes:
    #                 return

    #             # Update status
    self.nodes[node_id].status = NodeStatus.LEAVING

    #             # Remove from sharded index
                self.sharded_index.remove_node(node_id)

    #             # Stop node
                self._stop_node(node_id)

    #             # Remove from cluster
    #             del self.nodes[node_id]

            logger.info(f"Node {node_id} left cluster")

    #         if self.on_node_left:
                self.on_node_left(node_id)

    #     def _stop_node(self, node_id: str) -None):
    #         """Stop a node.

    #         Args:
    #             node_id: ID of the node to stop
    #         """
    #         # Find and stop the node
    #         for node_info in self.nodes.values():
    #             if node_info.node_id == node_id:
    #                 # In a real implementation, we would connect to the node and tell it to stop
    #                 # For now, we just update the status
    node_info.status = NodeStatus.FAILED
    #                 break

    #     def add_vector(
    self, vector_id: str, vector: Matrix, metadata: Dict[str, Any] = None
    #     ) -None):
    #         """Add a vector to the cluster.

    #         Args:
    #             vector_id: ID of the vector
    #             vector: Vector data
    #             metadata: Optional metadata
    #         """
    #         # Add to sharded index
            self.sharded_index.add_vector(vector_id, vector, metadata)

    #         # Schedule replication
    source_node = self.sharded_index.get_node_for_key(vector_id)
    #         if source_node:
    #             # Get target nodes for replication
    available_nodes = [
    #                 n.node_id
    #                 for n in self.nodes.values()
    #                 if n.status == NodeStatus.ACTIVE and n.node_id != source_node
    #             ]

    #             if available_nodes:
    #                 # Select replicas
    replication_strategy = ConsistentReplicationStrategy(
    #                     self.replication_manager
    #                 )
    target_nodes = replication_strategy.select_replicas(
    #                     vector_id, available_nodes
    #                 )

    #                 # Schedule replication
                    self.replication_manager.schedule_replication(
    #                     source_node, target_nodes, [vector_id]
    #                 )

    #     def get_vector(self, vector_id: str) -Optional[Dict[str, Any]]):
    #         """Get a vector by ID.

    #         Args:
    #             vector_id: ID of the vector

    #         Returns:
    #             Dictionary with 'vector' and 'metadata', or None if not found
    #         """
            return self.sharded_index.get_vector(vector_id)

    #     def search(
    self, query_vector: Matrix, k: int = 5, filter_func: callable = None
    #     ) -List[Tuple[str, float]]):
    #         """Search across the cluster.

    #         Args:
    #             query_vector: Query vector
    #             k: Number of results to return
    #             filter_func: Optional filter function

    #         Returns:
                List of (vector_id, score) tuples
    #         """
            return self.sharded_index.search(query_vector, k, filter_func)

    #     def get_cluster_status(self) -Dict[str, Any]):
    #         """Get cluster status information.

    #         Returns:
    #             Dictionary with cluster status
    #         """
    #         with self.cluster_lock:
    total_nodes = len(self.nodes)
    active_nodes = sum(
    #                 1 for n in self.nodes.values() if n.status == NodeStatus.ACTIVE
    #             )

    #             return {
    #                 "total_nodes": total_nodes,
    #                 "active_nodes": active_nodes,
    #                 "nodes": {
                        node_id: node_info.to_dict()
    #                     for node_id, node_info in self.nodes.items()
    #                 },
                    "sharding": self.sharded_index.get_cluster_status(),
                    "replication": self.replication_manager.get_cluster_health(),
    #             }

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary for serialization.

    #         Returns:
    #             Dictionary representation
    #         """
    #         with self.cluster_lock:
    #             return {
    #                 "config": self.config,
    #                 "nodes": {
                        node_id: node_info.to_dict()
    #                     for node_id, node_info in self.nodes.items()
    #                 },
                    "sharded_index": self.sharded_index.to_dict(),
                    "replication_manager": self.replication_manager.to_dict(),
    #             }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"ClusterManager"):
    #         """Create from dictionary.

    #         Args:
    #             data: Dictionary representation

    #         Returns:
    #             ClusterManager instance
    #         """
    manager = cls(config=data["config"])

    #         # Restore nodes
    #         for node_id, node_data in data["nodes"].items():
    manager.nodes[node_id] = NodeInfo.from_dict(node_data)

    #         # Restore sharded index
    manager.sharded_index = ShardedVectorIndex.from_dict(data["sharded_index"])

    #         # Restore replication manager
    manager.replication_manager = ReplicationManager.from_dict(
    #             data["replication_manager"]
    #         )

    #         return manager
