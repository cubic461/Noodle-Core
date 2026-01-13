# Converted from Python to NoodleCore
# Original file: src

# """
# Data Index for Noodle
# ---------------------
# This module implements the data index for Noodle, providing efficient memory and storage
# management across RAM, VRAM, disk, and remote storage. Includes object indexing, caching,
# and garbage collection with compile-time optimization support.
# """

import gc
import threading
import time
import collections.defaultdict
from dataclasses import dataclass
import enum.Enum
import typing.Any

import ..compiler.parser.ASTNode
import ..runtime.mathematical_objects.Actor


class StorageType(Enum)
    #     """Types of storage locations"""

    RAM = "ram"
    VRAM = "vram"
    DISK = "disk"
    REMOTE = "remote"
    CACHE = "cache"
    REGISTER = "register"


class PlacementStrategy(Enum)
    #     """Strategies for data placement"""

    AUTO = "auto"
    CPU_ONLY = "cpu_only"
    GPU_ONLY = "gpu_only"
    NPU_ONLY = "npu_only"
    MEMORY_LOCAL = "memory_local"
    NETWORK_BOUND = "network_bound"
    THROUGHPUT_SENSITIVE = "throughput_sensitive"
    LATENCY_SENSITIVE = "latency_sensitive"
    REPLICATED = "replicated"
    SHARDED = "sharded"
    CACHED = "cached"
    PINNED = "pinned"


dataclass
class ObjectLocation
    #     """Represents the location of an object in memory/storage"""

    #     object_id: str
    #     storage_type: StorageType
    address: Optional[int] = None  # Memory address or file offset
    size: int = 0  # Size in bytes
    placement_strategy: PlacementStrategy = PlacementStrategy.AUTO
    last_accessed: float = 0.0
    access_count: int = 0
    is_pinned: bool = False
    is_cached: bool = False
    replication_count: int = 1
    shard_id: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class CacheEntry
    #     """Entry in the cache index"""

    #     object_id: str
    #     data: Any
    #     size: int
    #     timestamp: float
    hit_count: int = 0
    eviction_priority: float = 0.0
    dependencies: Set[str] = field(default_factory=set)
    valid_until: Optional[float] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class GarbageCandidate
    #     """Candidate for garbage collection"""

    #     object_id: str
    #     reference_count: int
    #     size: int
    #     last_accessed: float
    #     creation_time: float
    is_root: bool = False
    depends_on: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


class DataIndex
    #     """
    #     Data Index for Noodle that manages object locations, caching, and garbage collection.
    #     Supports compile-time data layout optimization for performance.
    #     """

    #     def __init__(self):
    #         # Object index: ID -Location
    self.object_index): Dict[str, ObjectLocation] = {}

    #         # Cache index for computed results
    self.cache_index: Dict[str, CacheEntry] = {}
    self.cache_size_limit = 1024 * 1024 * 1024  # 1GB default cache limit
    self.current_cache_size = 0

    #         # Garbage map for memory management
    self.garbage_candidates: List[GarbageCandidate] = []
    self.reference_counts: Dict[str, int] = {}

    #         # Storage pools
    self.storage_pools: Dict[StorageType, Dict[str, Any]] = {
                StorageType.RAM: defaultdict(list),
                StorageType.VRAM: defaultdict(list),
                StorageType.DISK: defaultdict(list),
                StorageType.REMOTE: defaultdict(list),
    #         }

    #         # Compile-time optimization cache
    self.compile_time_cache: Dict[str, Dict[str, Any]] = {}

    #         # Locks for thread safety
    self.lock = threading.RLock()

    #         # Metrics
    self.created_at = time.time()
    self.last_updated = time.time()
    self.total_objects = 0
    self.total_cache_size = 0
    self.gc_runs = 0
    self.evictions = 0

    #     def register_object(
    #         self,
    #         object_id: str,
    storage_type: StorageType = StorageType.RAM,
    size: int = 0,
    placement_strategy: PlacementStrategy = PlacementStrategy.AUTO,
    is_pinned: bool = False,
    is_cached: bool = False,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -ObjectLocation):
    #         """
    #         Register a new object in the data index

    #         Args:
    #             object_id: Unique object identifier
    #             storage_type: Initial storage location
    #             size: Size of the object in bytes
    #             placement_strategy: Initial placement strategy
    #             is_pinned: Whether the object should be pinned in memory
    #             is_cached: Whether to cache the object
    #             metadata: Additional metadata

    #         Returns:
    #             ObjectLocation for the registered object
    #         """
    #         with self.lock:
    location = ObjectLocation(
    object_id = object_id,
    storage_type = storage_type,
    size = size,
    placement_strategy = placement_strategy,
    last_accessed = time.time(),
    is_pinned = is_pinned,
    is_cached = is_cached,
    metadata = metadata or {},
    #             )

    self.object_index[object_id] = location
    self.total_objects + = 1

    #             # Update storage pool
    self.storage_pools[storage_type][object_id] = location

    #             # Initialize reference count
    self.reference_counts[object_id] = 1

    #             # Update metrics
    self.last_updated = time.time()

    #             return location

    #     def get_object_location(self, object_id: str) -Optional[ObjectLocation]):
    #         """
    #         Get the current location of an object

    #         Args:
    #             object_id: Object identifier

    #         Returns:
    #             ObjectLocation if found, None otherwise
    #         """
    #         with self.lock:
    location = self.object_index.get(object_id)
    #             if location:
    #                 # Record access
    location.last_accessed = time.time()
    location.access_count + = 1
    #             return location

    #     def update_object_location(
    #         self,
    #         object_id: str,
    new_storage_type: Optional[StorageType] = None,
    new_address: Optional[int] = None,
    new_size: Optional[int] = None,
    new_placement_strategy: Optional[PlacementStrategy] = None,
    #     ) -bool):
    #         """
    #         Update the location of an object

    #         Args:
    #             object_id: Object identifier
    #             new_storage_type: New storage type
    #             new_address: New memory address or file offset
    #             new_size: New size in bytes
    #             new_placement_strategy: New placement strategy

    #         Returns:
    #             True if update successful, False if object not found
    #         """
    #         with self.lock:
    #             if object_id not in self.object_index:
    #                 return False

    location = self.object_index[object_id]

    #             if new_storage_type:
    #                 # Remove from old storage pool
    #                 if location.storage_type in self.storage_pools:
                        self.storage_pools[location.storage_type].pop(object_id, None)

    #                 # Update storage type
    location.storage_type = new_storage_type

    #                 # Add to new storage pool
    self.storage_pools[new_storage_type][object_id] = location

    #             if new_address is not None:
    location.address = new_address

    #             if new_size is not None:
    location.size = new_size

    #             if new_placement_strategy:
    location.placement_strategy = new_placement_strategy

    #             # Record access
    location.last_accessed = time.time()
    location.access_count + = 1

    #             # Update metrics
    self.last_updated = time.time()

    #             return True

    #     def cache_object(
    #         self,
    #         object_id: str,
    #         data: Any,
    #         size: int,
    valid_until: Optional[float] = None,
    dependencies: Optional[Set[str]] = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -bool):
    #         """
    #         Cache an object in the cache index

    #         Args:
    #             object_id: Object identifier
    #             data: Object data
    #             size: Size of the data in bytes
    #             valid_until: Cache expiration time
    #             dependencies: Set of dependent object IDs
    #             metadata: Additional metadata

    #         Returns:
    #             True if cached successfully, False if cache full or invalid
    #         """
    #         with self.lock:
    #             # Check if cache has space
    #             if self.current_cache_size + size self.cache_size_limit):
                    self._evict_cache_items(size)
    #                 if self.current_cache_size + size self.cache_size_limit):
    #                     return False

    #             # Create cache entry
    entry = CacheEntry(
    object_id = object_id,
    data = data,
    size = size,
    timestamp = time.time(),
    valid_until = valid_until,
    dependencies = dependencies or set(),
    metadata = metadata or {},
    #             )

    self.cache_index[object_id] = entry
    self.current_cache_size + = size

    #             # Mark object as cached
    #             if object_id in self.object_index:
    self.object_index[object_id].is_cached = True

    #             # Update metrics
    self.last_updated = time.time()

    #             return True

    #     def get_cached_object(self, object_id: str) -Optional[CacheEntry]):
    #         """
    #         Get a cached object

    #         Args:
    #             object_id: Object identifier

    #         Returns:
    #             CacheEntry if cached and valid, None otherwise
    #         """
    #         with self.lock:
    entry = self.cache_index.get(object_id)
    #             if entry:
    #                 # Check if still valid
    #                 if entry.valid_until and time.time() entry.valid_until):
                        self._invalidate_cache_entry(object_id)
    #                     return None

    #                 # Record cache hit
    entry.hit_count + = 1
    entry.timestamp = time.time()

    #                 # Record access on object location
    #                 if object_id in self.object_index:
    location = self.object_index[object_id]
    location.last_accessed = time.time()
    location.access_count + = 1

    #             return entry

    #     def invalidate_cache_entry(self, object_id: str) -bool):
    #         """
    #         Invalidate a cache entry

    #         Args:
    #             object_id: Object identifier

    #         Returns:
    #             True if entry was invalidated, False if not found
    #         """
    #         with self.lock:
    #             if object_id in self.cache_index:
    entry = self.cache_index[object_id]
    self.current_cache_size - = entry.size
    #                 del self.cache_index[object_id]

    #                 # Mark object as not cached
    #                 if object_id in self.object_index:
    self.object_index[object_id].is_cached = False

    self.evictions + = 1
    self.last_updated = time.time()
    #                 return True

    #             return False

    #     def compile_time_layout_optimization(
    #         self,
    #         obj: ASTNode,
    #         hardware_constraints: Dict[str, Any],
    #         optimization_hints: Dict[str, Any],
    #     ) -PlacementStrategy):
    #         """
    #         Perform compile-time data layout optimization

    #         Args:
    #             obj: AST node representing the object
    #             hardware_constraints: Available hardware constraints
    #             optimization_hints: Optimization hints from knowledge index

    #         Returns:
    #             Recommended placement strategy
    #         """
    #         with self.lock:
    #             # Analyze object type and size
    obj_type = getattr(obj, "type", None)
    estimated_size = self._estimate_object_size(obj)

    #             # Check if object is a tensor
    #             if obj_type == Type.MATRIX or isinstance(obj, Tensor):
    #                 # Large tensors should go to GPU if available
    #                 if estimated_size 1e6 and "gpu_memory" in hardware_constraints):
    gpu_memory = hardware_constraints["gpu_memory"]
    #                     if gpu_memory >= estimated_size:
    #                         return PlacementStrategy.GPU_ONLY

    #                 # Check if NPU is available for tensor operations
    #                 if (
    #                     "npu_available" in hardware_constraints
    #                     and "npu_optimized" in optimization_hints
    #                 ):
    #                     return PlacementStrategy.NPU_ONLY

    #             # Check for latency-sensitive operations
    #             if "latency_sensitive" in optimization_hints:
    #                 return PlacementStrategy.LATENCY_SENSITIVE

    #             # Check for throughput-sensitive operations
    #             if "throughput_sensitive" in optimization_hints:
    #                 return PlacementStrategy.THROUGHPUT_SENSITIVE

    #             # Default to CPU for small objects
    #             return PlacementStrategy.CPU_ONLY

    #     def _estimate_object_size(self, obj: ASTNode) -int):
    #         """
    #         Estimate the size of an object based on AST node

    #         Args:
    #             obj: AST node

    #         Returns:
    #             Estimated size in bytes
    #         """
    #         # Simple estimation based on node type
    #         if isinstance(obj, MatrixLiteral):
    rows = len(obj.rows)
    #             cols = len(obj.rows[0]) if rows 0 else 0
                # Assume float32 (4 bytes per element)
    #             return rows * cols * 4
    #         elif isinstance(obj, ArrayLiteral)):
    elements = len(obj.elements)
                # Assume 8 bytes per element (float64)
    #             return elements * 8
    #         elif isinstance(obj, ListLiteral):
    elements = len(obj.elements)
                # Assume 16 bytes per element (object reference + overhead)
    #             return elements * 16
    #         else:
    #             # Default estimation for other objects
    #             return 1024  # 1KB default

    #     def increment_reference_count(self, object_id: str) -int):
    #         """
    #         Increment the reference count for an object

    #         Args:
    #             object_id: Object identifier

    #         Returns:
    #             New reference count
    #         """
    #         with self.lock:
    self.reference_counts[object_id] = (
                    self.reference_counts.get(object_id, 0) + 1
    #             )
    #             return self.reference_counts[object_id]

    #     def decrement_reference_count(self, object_id: str) -int):
    #         """
    #         Decrement the reference count for an object

    #         Args:
    #             object_id: Object identifier

    #         Returns:
    #             New reference count
    #         """
    #         with self.lock:
    #             if object_id in self.reference_counts:
    self.reference_counts[object_id] - = 1
    #                 if self.reference_counts[object_id] <= 0:
                        self._schedule_garbage_collection(object_id)
    #                 return self.reference_counts[object_id]
    #             return 0

    #     def get_reference_count(self, object_id: str) -int):
    #         """
    #         Get the current reference count for an object

    #         Args:
    #             object_id: Object identifier

    #         Returns:
    #             Reference count
    #         """
            return self.reference_counts.get(object_id, 0)

    #     def _schedule_garbage_collection(self, object_id: str):
    #         """Schedule an object for garbage collection"""
    #         with self.lock:
    #             # Create garbage candidate
    location = self.object_index.get(object_id)
    #             if location:
    candidate = GarbageCandidate(
    object_id = object_id,
    reference_count = 0,
    size = location.size,
    last_accessed = location.last_accessed,
    creation_time = location.last_accessed
    #                     - location.access_count * 0.001,  # Approximate
    is_root = False,
    depends_on = list(self._get_dependent_objects(object_id)),
    metadata = location.metadata,
    #                 )

                    self.garbage_candidates.append(candidate)

    #                 # Trigger GC if many candidates
    #                 if len(self.garbage_candidates) 100):
                        self._run_garbage_collection()

    #     def _get_dependent_objects(self, object_id: str) -Set[str]):
    #         """Get objects that depend on this object"""
    dependents = set()
    #         for cache_entry in self.cache_index.values():
    #             if object_id in cache_entry.dependencies:
                    dependents.add(cache_entry.object_id)
    #         return dependents

    #     def _run_garbage_collection(self):
    #         """Run garbage collection"""
    #         with self.lock:
    self.gc_runs + = 1

    #             # Mark phase: find all reachable objects
    reachable = self._mark_reachable_objects()

    #             # Sweep phase: collect garbage
    #             for candidate in self.garbage_candidates[:]:
    #                 if candidate.object_id not in reachable:
                        self._collect_garbage(candidate)

                self.garbage_candidates.clear()

    #             # Update metrics
    self.last_updated = time.time()

    #     def _mark_reachable_objects(self) -Set[str]):
    #         """Mark all reachable objects"""
    reachable = set()
    visited = set()

    #         def mark_object(obj_id):
    #             if obj_id in visited:
    #                 return

                visited.add(obj_id)

    #             if obj_id in reachable:
    #                 return

                reachable.add(obj_id)

    #             # Mark dependencies
    #             if obj_id in self.cache_index:
    entry = self.cache_index[obj_id]
    #                 for dep_id in entry.dependencies:
                        mark_object(dep_id)

    #             # Mark objects that reference this one
    #             for cache_id, entry in self.cache_index.items():
    #                 if obj_id in entry.dependencies:
                        mark_object(cache_id)

            # Start from root objects (cached objects, pinned objects, etc.)
    #         for obj_id in list(self.cache_index.keys()):
                mark_object(obj_id)

    #         for obj_id, location in self.object_index.items():
    #             if location.is_pinned:
                    mark_object(obj_id)

    #         return reachable

    #     def _collect_garbage(self, candidate: GarbageCandidate):
    #         """Collect garbage for a candidate"""
    object_id = candidate.object_id

    #         # Remove from object index
    #         if object_id in self.object_index:
    location = self.object_index[object_id]
    self.total_objects - = 1

    #             # Remove from storage pool
    #             if location.storage_type in self.storage_pools:
                    self.storage_pools[location.storage_type].pop(object_id, None)

    #             del self.object_index[object_id]

    #             # Remove from reference counts
                self.reference_counts.pop(object_id, None)

    #         # Remove from cache
    #         if object_id in self.cache_index:
    entry = self.cache_index[object_id]
    self.current_cache_size - = entry.size
    #             del self.cache_index[object_id]

    #         # Remove from garbage candidates
    self.garbage_candidates = [
    #             c for c in self.garbage_candidates if c.object_id != object_id
    #         ]

    #     def _evict_cache_items(self, required_space: int):
    #         """Evict cache items to make space"""
    #         with self.lock:
    #             # Calculate eviction priority for each entry
    #             for entry in self.cache_index.values():
    #                 # Priority based on size, hit count, and age
    age = time.time() - entry.timestamp
    entry.eviction_priority = (entry.size / (entry.hit_count + 1) * ()
    #                     age / 3600
    #                 )  # Hours old

    #             # Sort by eviction priority and remove least important
    sorted_entries = sorted(
    self.cache_index.items(), key = lambda x: x[1].eviction_priority
    #             )

    #             for obj_id, entry in sorted_entries:
    #                 if self.current_cache_size + required_space <= self.cache_size_limit:
    #                     break

    self.current_cache_size - = entry.size
    #                 del self.cache_index[obj_id]
    self.evictions + = 1

    #     def _invalidate_cache_entry(self, object_id: str):
    #         """Invalidate a specific cache entry"""
    #         with self.lock:
    #             if object_id in self.cache_index:
    entry = self.cache_index[object_id]
    self.current_cache_size - = entry.size
    #                 del self.cache_index[object_id]
    self.evictions + = 1

    #     def get_index_statistics(self) -Dict[str, Any]):
    #         """
    #         Get statistics about the data index

    #         Returns:
    #             Dictionary of index statistics
    #         """
    #         with self.lock:
    #             return {
    #                 "total_objects": self.total_objects,
    #                 "total_cache_size": self.current_cache_size,
                    "cache_hit_rate": self._calculate_cache_hit_rate(),
    #                 "gc_runs": self.gc_runs,
    #                 "evictions": self.evictions,
    #                 "storage_by_type": {
    #                     st.value: len(pool) for st, pool in self.storage_pools.items()
    #                 },
                    "compile_time_cache_entries": len(self.compile_time_cache),
    #                 "created_at": self.created_at,
    #                 "last_updated": self.last_updated,
    #             }

    #     def _calculate_cache_hit_rate(self) -float):
    #         """Calculate the cache hit rate"""
    #         if not self.cache_index:
    #             return 0.0

    #         total_hits = sum(entry.hit_count for entry in self.cache_index.values())
    total_accesses = sum(
    #             entry.hit_count + 1 for entry in self.cache_index.values()
    #         )  # +1 for misses

    #         return total_hits / total_accesses if total_accesses 0 else 0.0

    #     def validate_integrity(self):
    """List[str])"""
    #         """
    #         Validate the integrity of the data index

    #         Returns:
    #             List of validation errors
    #         """
    errors = []

    #         # Check object index consistency
    #         for obj_id, location in self.object_index.items():
    #             # Check if object exists in storage pool
    #             if location.storage_type not in self.storage_pools:
                    errors.append(
    #                     f"Object {obj_id} has invalid storage type {location.storage_type}"
    #                 )
    #                 continue

    #             if obj_id not in self.storage_pools[location.storage_type]:
                    errors.append(
    #                     f"Object {obj_id} not in storage pool {location.storage_type}"
    #                 )

    #             # Check reference count
    #             if obj_id in self.reference_counts and self.reference_counts[obj_id] < 0:
                    errors.append(f"Object {obj_id} has negative reference count")

    #         # Check cache consistency
    #         for cache_id, entry in self.cache_index.items():
    #             if entry.size <= 0:
                    errors.append(f"Cache entry {cache_id} has invalid size {entry.size}")

    #             if self.current_cache_size < entry.size:
    #                 errors.append(f"Cache size inconsistency for entry {cache_id}")

    #         # Check garbage candidates
    #         for candidate in self.garbage_candidates:
    #             if (
    #                 candidate.object_id not in self.object_index
    #                 and candidate.object_id not in self.cache_index
    #             ):
                    errors.append(f"Garbage candidate {candidate.object_id} not in index")

    #         return errors

    #     def cost_based_join_optimizer(
    #         self,
    #         table1: str,
    #         table2: str,
    #         join_condition: Dict[str, Any],
    #         available_indexes: Dict[str, BTreeIndex],
    #     ) -Dict[str, Any]):
    #         """
    #         Optimize join using cost-based approach.

    #         Args:
    #             table1: First table name
    #             table2: Second table name
    join_condition: Join condition (e.g., {'on': 'table1.id = table2.id'})
    #             available_indexes: Available indexes for tables

    #         Returns:
    #             Dictionary with join plan and estimated cost
    #         """
            # Estimate table sizes (placeholder)
    table1_size = self._estimate_table_size(table1)
    table2_size = self._estimate_table_size(table2)

    #         # Check available indexes
    table1_index = available_indexes.get(f"{table1}_idx")
    table2_index = available_indexes.get(f"{table2}_idx")

    #         # Calculate costs for different join strategies
    strategies = []

    #         # Nested loop join
    nested_loop_cost = table1_size * table2_size
            strategies.append(
    #             {
    #                 "strategy": "nested_loop",
    #                 "cost": nested_loop_cost,
    #                 "description": "Simple nested loop join",
    #             }
    #         )

    #         # Hash join (if one table fits in memory)
    #         if table1_size < 10000 or table2_size < 10000:
    hash_cost = table1_size + table2_size
                strategies.append(
    #                 {
    #                     "strategy": "hash_join",
    #                     "cost": hash_cost,
                        "description": "Hash join (one table fits in memory)",
    #                 }
    #             )

    #         # Index nested loop join
    #         if table1_index:
    indexed_cost = table1_size * math.log2(table1_index.size)
                strategies.append(
    #                 {
    #                     "strategy": "index_nested_loop",
    #                     "cost": indexed_cost,
    #                     "description": f"Index nested loop using {table1_index.index_name}",
    #                 }
    #             )

    #         # Sort-merge join
    sort_merge_cost = table1_size * math.log2(
    #             table1_size
            ) + table2_size * math.log2(table2_size)
            strategies.append(
    #             {
    #                 "strategy": "sort_merge",
    #                 "cost": sort_merge_cost,
    #                 "description": "Sort-merge join",
    #             }
    #         )

    #         # Select best strategy
    best_strategy = min(strategies, key=lambda x: x["cost"])

    #         return {
    #             "best_strategy": best_strategy,
    #             "all_strategies": strategies,
    #             "table1_size": table1_size,
    #             "table2_size": table2_size,
    #             "indexes_available": {
    #                 table1: table1_index.get_stats() if table1_index else None,
    #                 table2: table2_index.get_stats() if table2_index else None,
    #             },
    #         }

    #     def _estimate_table_size(self, table_name: str) -int):
            """Estimate table size (placeholder)."""
    #         # In real implementation, query table statistics
    #         return 1000  # Default estimate

    #     def create_btree_index(
    self, table_name: str, columns: List[str], index_name: Optional[str] = None
    #     ) -BTreeIndex):
    #         """
    #         Create a B-tree index on specified columns.

    #         Args:
    #             table_name: Table name
    #             columns: List of column names to index
    #             index_name: Optional custom index name

    #         Returns:
    #             Created BTreeIndex instance
    #         """
    #         if index_name is None:
    index_name = f"{table_name}_{'_'.join(columns)}_idx"

    index = BTreeIndex(index_name, columns)

    #         # Store index for future use
    #         if not hasattr(self, "indexes"):
    self.indexes = {}
    self.indexes[index_name] = index

    #         return index

    #     def get_index_statistics(self) -Dict[str, Any]):
    #         """Get statistics for all indexes."""
    #         if not hasattr(self, "indexes"):
    #             return {}

    stats = {}
    #         for name, index in self.indexes.items():
    stats[name] = index.get_stats()

    #         return stats
