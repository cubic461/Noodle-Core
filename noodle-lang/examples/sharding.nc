# Converted from Python to NoodleCore
# Original file: src

# """Sharding strategy for distributed vector database.

# Implements consistent hashing for distributing vector data across nodes.
# """

import hashlib
import json
import logging
import uuid
import abc.ABC
from dataclasses import dataclass
import typing.Any

import noodlecore.runtime.matrix.Matrix

logger = logging.getLogger(__name__)


dataclass
class ShardInfo
    #     """Information about a shard."""

    #     shard_id: str
    #     node_id: str
    #     start_key: str
    #     end_key: str
    vector_count: int = 0
    size_bytes: int = 0
    last_updated: float = 0.0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "shard_id": self.shard_id,
    #             "node_id": self.node_id,
    #             "start_key": self.start_key,
    #             "end_key": self.end_key,
    #             "vector_count": self.vector_count,
    #             "size_bytes": self.size_bytes,
    #             "last_updated": self.last_updated,
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"ShardInfo"):
    #         """Create from dictionary."""
            return cls(
    shard_id = data["shard_id"],
    node_id = data["node_id"],
    start_key = data["start_key"],
    end_key = data["end_key"],
    vector_count = data.get("vector_count", 0),
    size_bytes = data.get("size_bytes", 0),
    last_updated = data.get("last_updated", 0.0),
    #         )


class HashFunction
    #     """Hash function for consistent hashing."""

    #     @staticmethod
    #     def hash_key(key: str) -int):
    #         """Hash a key to an integer."""
            return int(hashlib.md5(key.encode()).hexdigest(), 16)

    #     @staticmethod
    #     def hash_node(node_id: str) -int):
    #         """Hash a node ID to an integer."""
            return HashFunction.hash_key(f"node:{node_id}")


class ConsistentHashRing
    #     """Consistent hash ring for distributing data across nodes."""

    #     def __init__(self, virtual_nodes: int = 3):""Initialize consistent hash ring.

    #         Args:
    #             virtual_nodes: Number of virtual nodes per physical node
    #         """
    self.virtual_nodes = virtual_nodes
    self.ring: Dict[int, str] = {}  # hash - node_id
    self.nodes): Dict[str, Set[int]] = {}  # node_id - set of hashes
    self.shards): Dict[str, ShardInfo] = {}  # shard_id - ShardInfo

    #     def add_node(self, node_id): str) -None):
    #         """Add a node to the hash ring.

    #         Args:
    #             node_id: ID of the node to add
    #         """
    #         if node_id in self.nodes:
    #             return

    #         # Generate virtual node hashes
    node_hashes = set()
    #         for i in range(self.virtual_nodes):
    virtual_node_id = f"{node_id}:{i}"
    hash_val = HashFunction.hash_node(virtual_node_id)
    self.ring[hash_val] = node_id
                node_hashes.add(hash_val)

    self.nodes[node_id] = node_hashes
    #         logger.info(f"Added node {node_id} with {self.virtual_nodes} virtual nodes")

    #     def remove_node(self, node_id: str) -None):
    #         """Remove a node from the hash ring.

    #         Args:
    #             node_id: ID of the node to remove
    #         """
    #         if node_id not in self.nodes:
    #             return

    #         # Remove virtual nodes
    #         for hash_val in self.nodes[node_id]:
    #             del self.ring[hash_val]

    #         del self.nodes[node_id]

    #         # Reassign shards from this node
    #         shards_to_reassign = [s for s in self.shards.values() if s.node_id == node_id]
    #         for shard in shards_to_reassign:
    new_node_id = self.get_node_for_key(shard.shard_id)
    #             if new_node_id:
    shard.node_id = new_node_id
                    logger.info(
    #                     f"Reassigned shard {shard.shard_id} from {node_id} to {new_node_id}"
    #                 )

            logger.info(f"Removed node {node_id}")

    #     def get_node_for_key(self, key: str) -Optional[str]):
    #         """Get the node responsible for a key.

    #         Args:
    #             key: Key to look up

    #         Returns:
    #             Node ID responsible for the key, or None if no nodes
    #         """
    #         if not self.ring:
    #             return None

    key_hash = HashFunction.hash_key(key)

    # Find the first node hash = key_hash
    sorted_hashes = sorted(self.ring.keys())
    #         for hash_val in sorted_hashes):
    #             if hash_val >= key_hash:
    #                 return self.ring[hash_val]

    #         # Wrap around to the first node
    #         return self.ring[sorted_hashes[0]]

    #     def get_shard_for_key(self, key: str) -Optional[ShardInfo]):
    #         """Get the shard responsible for a key.

    #         Args:
    #             key: Key to look up

    #         Returns:
    #             Shard info for the key, or None if no shards
    #         """
    node_id = self.get_node_for_key(key)
    #         if not node_id:
    #             return None

    #         # Find shard on this node
    #         for shard in self.shards.values():
    #             if shard.node_id == node_id and shard.start_key <= key <= shard.end_key:
    #                 return shard

    #         return None

    #     def add_shard(
    #         self, shard_id: str, node_id: str, start_key: str, end_key: str
    #     ) -None):
    #         """Add a shard to the ring.

    #         Args:
    #             shard_id: ID of the shard
    #             node_id: Node ID where the shard is located
    #             start_key: Start key of the shard range
    #             end_key: End key of the shard range
    #         """
    shard = ShardInfo(
    shard_id = shard_id, node_id=node_id, start_key=start_key, end_key=end_key
    #         )
    self.shards[shard_id] = shard
            logger.info(
    #             f"Added shard {shard_id} on node {node_id} for range {start_key}-{end_key}"
    #         )

    #     def remove_shard(self, shard_id: str) -None):
    #         """Remove a shard from the ring.

    #         Args:
    #             shard_id: ID of the shard to remove
    #         """
    #         if shard_id in self.shards:
    #             del self.shards[shard_id]
                logger.info(f"Removed shard {shard_id}")

    #     def get_shards_for_node(self, node_id: str) -List[ShardInfo]):
    #         """Get all shards on a node.

    #         Args:
    #             node_id: Node ID

    #         Returns:
    #             List of shards on the node
    #         """
    #         return [s for s in self.shards.values() if s.node_id == node_id]

    #     def rebalance(self) -Dict[str, List[str]]):
    #         """Rebalance shards across nodes.

    #         Returns:
    #             Mapping of node IDs to lists of shard IDs to move
    #         """
    #         if not self.nodes or len(self.nodes) < 2:
    #             return {}

    #         # Calculate ideal shard count per node
    total_shards = len(self.shards)
    nodes_count = len(self.nodes)
    ideal_shards_per_node = math.divide(total_shards, / nodes_count)

    #         # Find nodes with too many or too few shards
    node_shard_counts = {
    #             node_id: len(self.get_shards_for_node(node_id)) for node_id in self.nodes
    #         }

    moves = {}

    #         # Move shards from overloaded nodes
    #         for node_id, count in node_shard_counts.items():
    #             if count ideal_shards_per_node):
    excess = count - ideal_shards_per_node
    shards_to_move = self.get_shards_for_node(node_id)[:excess]

    #                 # Find underloaded nodes
    underloaded_nodes = [
    #                     n
    #                     for n, c in node_shard_counts.items()
    #                     if c < ideal_shards_per_node and n != node_id
    #                 ]

    #                 if underloaded_nodes:
    target_node = underloaded_nodes[0]
    #                     moves[node_id] = [s.shard_id for s in shards_to_move]

    #                     # Update shard assignments
    #                     for shard in shards_to_move:
    shard.node_id = target_node

    #         return moves

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "virtual_nodes": self.virtual_nodes,
    #             "ring": {str(k): v for k, v in self.ring.items()},
    #             "nodes": {k: list(v) for k, v in self.nodes.items()},
    #             "shards": {k: v.to_dict() for k, v in self.shards.items()},
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"ConsistentHashRing"):
    #         """Create from dictionary."""
    ring = cls(virtual_nodes=data.get("virtual_nodes", 3))

    #         # Restore ring
    #         ring.ring = {int(k): v for k, v in data.get("ring", {}).items()}

    #         # Restore nodes
    ring.nodes = {}
    #         for node_id, hashes in data.get("nodes", {}).items():
    ring.nodes[node_id] = set(hashes)

    #         # Restore shards
    ring.shards = {}
    #         for shard_id, shard_data in data.get("shards", {}).items():
    ring.shards[shard_id] = ShardInfo.from_dict(shard_data)

    #         return ring


class ShardingStrategy(ABC)
    #     """Abstract base class for sharding strategies."""

    #     @abstractmethod
    #     def assign_shard(self, key: str, available_nodes: List[str]) -str):
    #         """Assign a key to a shard.

    #         Args:
    #             key: Key to assign
    #             available_nodes: List of available node IDs

    #         Returns:
    #             Node ID where the key should be stored
    #         """
    #         pass

    #     @abstractmethod
    #     def get_shard_range(self, shard_id: str, total_shards: int) -Tuple[str, str]):
    #         """Get the key range for a shard.

    #         Args:
    #             shard_id: ID of the shard
    #             total_shards: Total number of shards

    #         Returns:
                Tuple of (start_key, end_key)
    #         """
    #         pass


class RangeShardingStrategy(ShardingStrategy)
    #     """Range-based sharding strategy."""

    #     def assign_shard(self, key: str, available_nodes: List[str]) -str):
    #         """Assign a key to a shard based on range.

    #         Args:
    #             key: Key to assign
    #             available_nodes: List of available node IDs

    #         Returns:
    #             Node ID where the key should be stored
    #         """
    #         if not available_nodes:
                raise ValueError("No available nodes")

    #         # Simple round-robin assignment
    key_hash = HashFunction.hash_key(key)
    node_index = key_hash % len(available_nodes)
    #         return available_nodes[node_index]

    #     def get_shard_range(self, shard_id: str, total_shards: int) -Tuple[str, str]):
    #         """Get the key range for a shard.

    #         Args:
    #             shard_id: ID of the shard
    #             total_shards: Total number of shards

    #         Returns:
                Tuple of (start_key, end_key)
    #         """
    shard_num = int(shard_id.split("-")[1])  # Extract number from shard-X
    range_size = (2 * *128 - 1 // total_shards)

    start_key = hex(shard_num * range_size[2:].zfill(32))
    end_key = hex((shard_num + 1 * range_size - 1)[2:].zfill(32))

    #         return start_key, end_key


class ShardedVectorIndex
    #     """Sharded vector index that distributes data across nodes."""

    #     def __init__(self, strategy: ShardingStrategy = None):""Initialize sharded vector index.

    #         Args:
    #             strategy: Sharding strategy to use
    #         """
    self.hash_ring = ConsistentHashRing()
    self.strategy = strategy or RangeShardingStrategy()
    self.local_indices: Dict[str, Any] = {}  # node_id - local index
    self.shard_metadata): Dict[str, Dict[str, Any]] = {}  # shard_id - metadata

    #     def add_node(self, node_id): str, local_index: Any = None) -None):
    #         """Add a node to the cluster.

    #         Args:
    #             node_id: ID of the node
    #             local_index: Local vector index for the node
    #         """
            self.hash_ring.add_node(node_id)
    self.local_indices[node_id] = local_index or {}

    #         # Create shards for this node if needed
            self._create_shards_for_node(node_id)

    #     def remove_node(self, node_id: str) -None):
    #         """Remove a node from the cluster.

    #         Args:
    #             node_id: ID of the node to remove
    #         """
            self.hash_ring.remove_node(node_id)
    #         if node_id in self.local_indices:
    #             del self.local_indices[node_id]

    #     def _create_shards_for_node(self, node_id: str) -None):
    #         """Create shards for a new node.

    #         Args:
    #             node_id: ID of the node
    #         """
    #         # Get existing shards count
    total_shards = len(self.hash_ring.shards)

    #         # Create new shards for this node
    shards_per_node = math.divide(max(1, total_shards, / max(1, len(self.hash_ring.nodes))))

    #         for i in range(shards_per_node):
    shard_id = f"shard-{total_shards + i}"
    start_key, end_key = self.strategy.get_shard_range(
    #                 shard_id, total_shards + shards_per_node
    #             )

                self.hash_ring.add_shard(shard_id, node_id, start_key, end_key)

    #     def get_node_for_key(self, key: str) -Optional[str]):
    #         """Get the node responsible for a key.

    #         Args:
    #             key: Key to look up

    #         Returns:
    #             Node ID responsible for the key
    #         """
            return self.hash_ring.get_node_for_key(key)

    #     def get_shard_for_key(self, key: str) -Optional[ShardInfo]):
    #         """Get the shard responsible for a key.

    #         Args:
    #             key: Key to look up

    #         Returns:
    #             Shard info for the key
    #         """
            return self.hash_ring.get_shard_for_key(key)

    #     def add_vector(
    self, vector_id: str, vector: Matrix, metadata: Dict[str, Any] = None
    #     ) -None):
    #         """Add a vector to the appropriate shard.

    #         Args:
    #             vector_id: ID of the vector
    #             vector: Vector data
    #             metadata: Optional metadata
    #         """
    node_id = self.get_node_for_key(vector_id)
    #         if not node_id:
                raise ValueError("No nodes available")

    #         # Add to local index
    #         if node_id not in self.local_indices:
    self.local_indices[node_id] = {}

    local_index = self.local_indices[node_id]
    local_index[vector_id] = {"vector": vector, "metadata": metadata or {}}

    #         # Update shard metadata
    shard = self.get_shard_for_key(vector_id)
    #         if shard:
    shard.vector_count + = 1
                # Estimate size (simplified)
    shard.size_bytes + = vector.size * 4  # Assuming 4 bytes per float

    #     def get_vector(self, vector_id: str) -Optional[Dict[str, Any]]):
    #         """Get a vector by ID.

    #         Args:
    #             vector_id: ID of the vector

    #         Returns:
    #             Dictionary with 'vector' and 'metadata', or None if not found
    #         """
    node_id = self.get_node_for_key(vector_id)
    #         if not node_id or node_id not in self.local_indices:
    #             return None

            return self.local_indices[node_id].get(vector_id)

    #     def search(
    self, query_vector: Matrix, k: int = 5, filter_func: callable = None
    #     ) -List[Tuple[str, float]]):
    #         """Search across all shards.

    #         Args:
    #             query_vector: Query vector
    #             k: Number of results to return
    #             filter_func: Optional filter function

    #         Returns:
                List of (vector_id, score) tuples
    #         """
    all_results = []

    #         # Search in each local index
    #         for node_id, local_index in self.local_indices.items():
    #             for vector_id, data in local_index.items():
    #                 if filter_func and not filter_func(data["metadata"]):
    #                     continue

                    # Calculate similarity (simplified)
    score = self._calculate_similarity(query_vector, data["vector"])
                    all_results.append((vector_id, score))

    #         # Sort by score and return top k
    all_results.sort(key = lambda x: x[1], reverse=True)
    #         return all_results[:k]

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

    #     def rebalance(self) -Dict[str, List[str]]):
    #         """Rebalance shards across nodes.

    #         Returns:
    #             Mapping of node IDs to lists of shard IDs to move
    #         """
            return self.hash_ring.rebalance()

    #     def get_cluster_status(self) -Dict[str, Any]):
    #         """Get cluster status information.

    #         Returns:
    #             Dictionary with cluster status
    #         """
    #         total_vectors = sum(len(idx) for idx in self.local_indices.values())
    total_size = sum(
    #             sum(s.size_bytes for s in self.hash_ring.get_shards_for_node(node_id))
    #             for node_id in self.local_indices.keys()
    #         )

    #         return {
                "total_nodes": len(self.local_indices),
                "total_shards": len(self.hash_ring.shards),
    #             "total_vectors": total_vectors,
    #             "total_size_bytes": total_size,
    #             "nodes": {
    #                 node_id: {
                        "vectors": len(self.local_indices[node_id]),
    #                     "shards": [
    #                         s.shard_id for s in self.hash_ring.get_shards_for_node(node_id)
    #                     ],
    #                 }
    #                 for node_id in self.local_indices.keys()
    #             },
    #         }

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary for serialization."""
    #         return {
                "hash_ring": self.hash_ring.to_dict(),
    #             "local_indices": {
    #                 node_id: {
    #                     vec_id: {
    #                         "vector": {
    #                             "data": vec["vector"].data,
    #                             "shape": vec["vector"].shape,
    #                         },
    #                         "metadata": vec["metadata"],
    #                     }
    #                     for vec_id, vec in local_index.items()
    #                 }
    #                 for node_id, local_index in self.local_indices.items()
    #             },
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"ShardedVectorIndex"):
    #         """Create from dictionary."""
    index = cls()

    #         # Restore hash ring
    index.hash_ring = ConsistentHashRing.from_dict(data["hash_ring"])

    #         # Restore local indices
    index.local_indices = {}
    #         for node_id, local_data in data["local_indices"].items():
    local_index = {}
    #             for vec_id, vec_data in local_data.items():
    #                 from noodlecore.runtime.matrix import Matrix

    vector = Matrix(
    vec_data["vector"]["shape"], data = vec_data["vector"]["data"]
    #                 )
    local_index[vec_id] = {
    #                     "vector": vector,
    #                     "metadata": vec_data["metadata"],
    #                 }
    index.local_indices[node_id] = local_index

    #         return index
