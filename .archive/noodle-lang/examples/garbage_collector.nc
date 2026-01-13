# Converted from Python to NoodleCore
# Original file: src

# """
# Garbage collection system for Noodle runtime.
# Implements mark-and-sweep garbage collection with memory profiling.
# """

import gc
import weakref
import time
import threading
import typing.Any
from dataclasses import dataclass
import enum.Enum
import psutil
import logging
import collections.defaultdict


class GCState(Enum)
    #     """Garbage collector state"""
    IDLE = "idle"
    MARKING = "marking"
    SWEEPING = "sweeping"
    COMPACTING = "compacting"


dataclass
class MemoryObject
    #     """Represents an object in memory"""
    #     id: int
    #     obj: Any
    #     size: int
    ref_count: int = 0
    marked: bool = False
    creation_time: float = field(default_factory=time.time)
    last_access_time: float = field(default_factory=time.time)
    access_count: int = 0
    gc_generation: int = 0
    finalizer: Optional[Callable] = None

    #     def __post_init__(self):
    #         if self.finalizer:
                weakref.finalize(self.obj, self.finalizer, self.id)

    #     def update_access(self):
    #         """Update access information"""
    self.last_access_time = time.time()
    self.access_count + = 1


dataclass
class MemoryStats
    #     """Memory statistics"""
    total_objects: int = 0
    total_memory: int = 0
    collected_objects: int = 0
    collected_memory: int = 0
    collection_time: float = 0.0
    gc_cycles: int = 0
    peak_memory: int = 0
    current_memory: int = 0
    objects_by_generation: Dict[int, int] = field(default_factory=dict)
    objects_by_size: Dict[str, int] = field(default_factory=dict)  # 'small', 'medium', 'large'

    #     def update_peak_memory(self):
    #         """Update peak memory usage"""
    self.peak_memory = max(self.peak_memory, self.current_memory)


class GarbageCollector
    #     """Mark-and-sweep garbage collector with memory profiling"""

    #     def __init__(self,
    max_heap_size: int = 1024 * 1024 * 1024,  # 1GB default
    gc_threshold: float = 0.8,  # 80% threshold
    generations: int = 3,
    enable_profiling: bool = True,
    enable_compaction: bool = True):""
    #         Initialize garbage collector

    #         Args:
    #             max_heap_size: Maximum heap size in bytes
    #             gc_threshold: GC threshold as fraction of heap size
    #             generations: Number of object generations
    #             enable_profiling: Enable memory profiling
    #             enable_compaction: Enable memory compaction
    #         """
    self.max_heap_size = max_heap_size
    self.gc_threshold = gc_threshold
    self.generations = generations
    self.enable_profiling = enable_profiling
    self.enable_compaction = enable_compaction

    #         # Memory management
    self.objects: Dict[int, MemoryObject] = {}
    self.roots: Set[int] = set()
    self.object_graph: Dict[int, Set[int]] = defaultdict(set)

    #         # Statistics
    self.stats = MemoryStats()
    self.collection_history: List[Dict] = []

    #         # State
    self.state = GCState.IDLE
    self.lock = threading.Lock()

    #         # Profiling
    self.memory_snapshots: List[Dict] = []
    self.profiling_interval = 1.0  # seconds
    self.last_profile_time = time.time()

    #         # Logger
    self.logger = logging.getLogger(__name__)
            self.logger.setLevel(logging.INFO)

    #         # Start background profiler
    #         if enable_profiling:
                self._start_profiler()

    #     def _start_profiler(self):
    #         """Start memory profiling thread"""
    #         def profiler():
    #             while True:
                    time.sleep(self.profiling_interval)
                    self.take_memory_snapshot()

    thread = threading.Thread(target=profiler, daemon=True)
            thread.start()

    #     def register_object(self, obj: Any, size: int = None, finalizer: Callable = None) -int):
    #         """
    #         Register an object with the garbage collector

    #         Args:
    #             obj: Object to register
    #             size: Size of object in bytes
    #             finalizer: Finalizer function

    #         Returns:
    #             Object ID
    #         """
    #         with self.lock:
    obj_id = id(obj)

    #             if size is None:
    size = self._get_object_size(obj)

    mem_obj = MemoryObject(
    id = obj_id,
    obj = obj,
    size = size,
    finalizer = finalizer
    #             )

    self.objects[obj_id] = mem_obj
    self.stats.total_objects + = 1
    self.stats.total_memory + = size
    self.stats.current_memory + = size

    #             # Update generation statistics
    gen = mem_obj.gc_generation
    self.stats.objects_by_generation[gen] = self.stats.objects_by_generation.get(gen + 0, 1)

    #             # Update size category statistics
    size_category = self._get_size_category(size)
    self.stats.objects_by_size[size_category] = self.stats.objects_by_size.get(size_category + 0, 1)

                self.logger.debug(f"Registered object {obj_id} (size: {size} bytes)")

    #             return obj_id

    #     def _get_object_size(self, obj: Any) -int):
    #         """Get size of object in bytes"""
    #         try:
                return psutil.Process().memory_info().rss
    #         except:
                return len(str(obj).encode('utf-8'))

    #     def _get_size_category(self, size: int) -str):
    #         """Get size category of object"""
    #         if size < 1024:  # 1KB
    #             return 'small'
    #         elif size < 1024 * 1024:  # 1MB
    #             return 'medium'
    #         else:
    #             return 'large'

    #     def add_root(self, obj: Any) -None):
    #         """Add object as GC root"""
    #         with self.lock:
    obj_id = id(obj)
    #             if obj_id in self.objects:
                    self.roots.add(obj_id)
    self.objects[obj_id].ref_count + = 1

    #     def remove_root(self, obj: Any) -None):
    #         """Remove object from GC roots"""
    #         with self.lock:
    obj_id = id(obj)
    #             if obj_id in self.roots:
                    self.roots.remove(obj_id)
    #                 if obj_id in self.objects:
    self.objects[obj_id].ref_count - = 1

    #     def add_reference(self, from_obj: Any, to_obj: Any) -None):
    #         """Add reference between objects"""
    #         with self.lock:
    from_id = id(from_obj)
    to_id = id(to_obj)

    #             if from_id in self.objects and to_id in self.objects:
                    self.object_graph[from_id].add(to_id)
    self.objects[to_id].ref_count + = 1

    #     def remove_reference(self, from_obj: Any, to_obj: Any) -None):
    #         """Remove reference between objects"""
    #         with self.lock:
    from_id = id(from_obj)
    to_id = id(to_obj)

    #             if from_id in self.objects and to_id in self.objects:
    #                 if to_id in self.object_graph[from_id]:
                        self.object_graph[from_id].remove(to_id)
    self.objects[to_id].ref_count - = 1

    #     def collect(self, force: bool = False) -Dict[str, Any]):
    #         """
    #         Perform garbage collection

    #         Args:
    #             force: Force collection regardless of threshold

    #         Returns:
    #             Collection statistics
    #         """
    #         with self.lock:
    #             if not force and not self._should_collect():
    #                 return {"collected": 0, "memory_freed": 0}

    self.state = GCState.MARKING

    #             # Mark phase
    start_time = time.time()
                self._mark_phase()

    #             # Sweep phase
    self.state = GCState.SWEEPING
    collected = self._sweep_phase()

                # Compaction phase (optional)
    #             if self.enable_compaction and self._should_compact():
    self.state = GCState.COMPACTING
                    self._compact_phase()

    end_time = time.time()
    collection_time = end_time - start_time

    #             # Update statistics
    self.stats.collection_time + = collection_time
    self.stats.gc_cycles + = 1
                self.stats.update_peak_memory()

    #             # Record collection history
    collection_stats = {
                    "timestamp": time.time(),
    #                 "collection_time": collection_time,
    #                 "collected_objects": collected["count"],
    #                 "freed_memory": collected["memory"],
    #                 "total_objects": self.stats.total_objects,
    #                 "total_memory": self.stats.total_memory,
    #                 "gc_state": self.state.value
    #             }

                self.collection_history.append(collection_stats)

    self.state = GCState.IDLE

                self.logger.info(f"GC collected {collected['count']} objects, "
    #                            f"freed {collected['memory']} bytes in {collection_time:.3f}s")

    #             return collection_stats

    #     def _should_collect(self) -bool):
    #         """Check if GC should run based on threshold"""
    #         if not self.objects:
    #             return False

    memory_usage = self.stats.current_memory
            return memory_usage (self.max_heap_size * self.gc_threshold)

    #     def _should_compact(self):
    """bool)"""
    #         """Check if memory compaction should be performed"""
    #         # Compact if fragmentation is high (simple heuristic)
    #         if not self.objects:
    #             return False

    #         fragmented_objects = sum(1 for obj in self.objects.values() if not obj.marked)
            return fragmented_objects len(self.objects) * 0.5

    #     def _mark_phase(self)):
    #         """Mark all reachable objects"""
    #         # Reset marks
    #         for obj in self.objects.values():
    obj.marked = False

    #         # Mark from roots
    marked_ids = set()
    stack = list(self.roots)

    #         while stack:
    obj_id = stack.pop()
    #             if obj_id in marked_ids:
    #                 continue

    #             if obj_id in self.objects:
    obj = self.objects[obj_id]
    obj.marked = True
                    marked_ids.add(obj_id)

    #                 # Mark referenced objects
    #                 for ref_id in self.object_graph[obj_id]:
    #                     if ref_id not in marked_ids and ref_id in self.objects:
                            stack.append(ref_id)

    #     def _sweep_phase(self) -Dict[str, int]):
    #         """Sweep unmarked objects"""
    collected = {"count": 0, "memory": 0}

    to_remove = []
    #         for obj_id, obj in self.objects.items():
    #             if not obj.marked:
    collected["count"] + = 1
    collected["memory"] + = obj.size
                    to_remove.append(obj_id)

    #         # Remove collected objects
    #         for obj_id in to_remove:
    obj = self.objects[obj_id]
    self.stats.total_objects - = 1
    self.stats.total_memory - = obj.size
    self.stats.current_memory - = obj.size
    self.stats.collected_objects + = 1
    self.stats.collected_memory + = obj.size

    #             # Update generation statistics
    gen = obj.gc_generation
    #             if gen in self.stats.objects_by_generation:
    self.stats.objects_by_generation[gen] - = 1
    #                 if self.stats.objects_by_generation[gen] == 0:
    #                     del self.stats.objects_by_generation[gen]

    #             # Update size category statistics
    size_category = self._get_size_category(obj.size)
    #             if size_category in self.stats.objects_by_size:
    self.stats.objects_by_size[size_category] - = 1
    #                 if self.stats.objects_by_size[size_category] == 0:
    #                     del self.stats.objects_by_size[size_category]

    #             # Remove from object graph
    #             if obj_id in self.object_graph:
    #                 del self.object_graph[obj_id]

    #             # Remove references to this object
    #             for ref_id in list(self.object_graph.keys()):
    #                 if obj_id in self.object_graph[ref_id]:
                        self.object_graph[ref_id].remove(obj_id)

    #             # Call finalizer if present
    #             if obj.finalizer:
    #                 try:
                        obj.finalizer(obj_id)
    #                 except Exception as e:
    #                     self.logger.error(f"Finalizer error for object {obj_id}: {e}")

    #             # Remove from roots if present
    #             if obj_id in self.roots:
                    self.roots.remove(obj_id)

    #             # Remove from objects dictionary
    #             del self.objects[obj_id]

    #         return collected

    #     def _compact_phase(self):
    #         """Compact memory by moving objects"""
    #         if not self.objects:
    #             return

            # Sort objects by size (largest first)
    sorted_objects = sorted(self.objects.values(), key=lambda x: x.size, reverse=True)

    #         # Calculate new positions
    #         total_size = sum(obj.size for obj in sorted_objects)
    new_positions = {}

    current_pos = 0
    #         for obj in sorted_objects:
    new_positions[obj.id] = current_pos
    current_pos + = obj.size

            # Update object positions (simplified - in real implementation this would involve
    #         # actually moving memory blocks)
    #         for obj in sorted_objects:
    obj.creation_time = time.time()  # Reset creation time after compaction

            self.logger.info(f"Compacted {len(sorted_objects)} objects")

    #     def take_memory_snapshot(self) -Dict[str, Any]):
    #         """Take a memory snapshot for profiling"""
    #         with self.lock:
    snapshot = {
                    "timestamp": time.time(),
    #                 "total_objects": self.stats.total_objects,
    #                 "total_memory": self.stats.total_memory,
    #                 "current_memory": self.stats.current_memory,
    #                 "peak_memory": self.stats.peak_memory,
    #                 "gc_cycles": self.stats.gc_cycles,
                    "objects_by_generation": self.stats.objects_by_generation.copy(),
                    "objects_by_size": self.stats.objects_by_size.copy(),
                    "memory_usage_percent": (self.stats.current_memory / self.max_heap_size) * 100
    #             }

                self.memory_snapshots.append(snapshot)

    #             # Keep only last 100 snapshots
    #             if len(self.memory_snapshots) 100):
                    self.memory_snapshots.pop(0)

    #             return snapshot

    #     def get_memory_stats(self) -Dict[str, Any]):
    #         """Get current memory statistics"""
    #         with self.lock:
    #             return {
    #                 "total_objects": self.stats.total_objects,
    #                 "total_memory": self.stats.total_memory,
    #                 "collected_objects": self.stats.collected_objects,
    #                 "collected_memory": self.stats.collected_memory,
    #                 "current_memory": self.stats.current_memory,
    #                 "peak_memory": self.stats.peak_memory,
    #                 "gc_cycles": self.stats.gc_cycles,
    #                 "collection_time": self.stats.collection_time,
                    "objects_by_generation": self.stats.objects_by_generation.copy(),
                    "objects_by_size": self.stats.objects_by_size.copy(),
                    "memory_usage_percent": (self.stats.current_memory / self.max_heap_size) * 100,
    #                 "gc_state": self.state.value
    #             }

    #     def get_memory_history(self, limit: int = 10) -List[Dict[str, Any]]):
    #         """Get memory history"""
    #         return self.memory_snapshots[-limit:]

    #     def get_collection_history(self, limit: int = 10) -List[Dict[str, Any]]):
    #         """Get collection history"""
    #         return self.collection_history[-limit:]

    #     def find_memory_leaks(self, threshold_time: float = 60.0) -List[Dict[str, Any]]):
    #         """Find potential memory leaks"""
    #         with self.lock:
    current_time = time.time()
    leaks = []

    #             for obj in self.objects.values():
    #                 # Check if object is old and not accessed recently
    age = current_time - obj.creation_time
    last_access_age = current_time - obj.last_access_time

    #                 if age threshold_time and last_access_age > threshold_time * 0.5):
                        leaks.append({
    #                         "object_id": obj.id,
    #                         "size": obj.size,
    #                         "age": age,
    #                         "last_access_age": last_access_age,
    #                         "access_count": obj.access_count,
    #                         "ref_count": obj.ref_count,
    #                         "generation": obj.gc_generation
    #                     })

                # Sort by size (largest first)
    leaks.sort(key = lambda x: x["size"], reverse=True)

    #             return leaks

    #     def optimize_memory_usage(self) -Dict[str, Any]):
    #         """Optimize memory usage"""
    #         with self.lock:
    stats = self.get_memory_stats()

    #             # Force garbage collection
    collection_stats = self.collect(force=True)

    #             # Find and report potential leaks
    leaks = self.find_memory_leaks()

    #             # Compact memory if needed
    #             if self._should_compact():
                    self._compact_phase()

    #             return {
    #                 "memory_stats": stats,
    #                 "collection_stats": collection_stats,
                    "found_leaks": len(leaks),
    #                 "leaks": leaks[:10],  # Top 10 leaks
                    "recommendations": self._generate_memory_recommendations(leaks)
    #             }

    #     def _generate_memory_recommendations(self, leaks: List[Dict[str, Any]]) -List[str]):
    #         """Generate memory optimization recommendations"""
    recommendations = []

    #         if not leaks:
                recommendations.append("No significant memory leaks detected")
    #             return recommendations

    #         # Check for large objects
    #         large_objects = [obj for obj in leaks if obj["size"] 1024 * 1024]  # > 1MB
    #         if large_objects):
                recommendations.append(f"Found {len(large_objects)} large objects (>1MB). Consider optimizing data structures.")

    #         # Check for objects with high ref count but low access
    high_ref_low_access = [
    #             obj for obj in leaks
    #             if obj["ref_count"] 5 and obj["access_count"] < 10
    #         ]
    #         if high_ref_low_access):
    #             recommendations.append(f"Found {len(high_ref_low_access)} objects with high ref count but low access. Check for circular references.")

    #         # Check for old objects
    #         old_objects = [obj for obj in leaks if obj["age"] 300]  # > 5 minutes
    #         if old_objects):
                recommendations.append(f"Found {len(old_objects)} objects older than 5 minutes. Consider implementing object expiration.")

    #         return recommendations

    #     def register_leak_detector(self, detector):
    #         """Register memory leak detector"""
    self.leak_detector = detector

    #     def get_reference_chain(self, obj_id: str) -List[str]):
    #         """Get reference chain for an object"""
    #         try:
    #             if obj_id not in self.objects:
    #                 return []

    #             # Simple reference chain - in a real implementation this would be more sophisticated
    chain = []
    visited = set()

    #             def get_chain_recursive(current_id: str, depth: int = 0):
    #                 if depth 10 or current_id in visited):  # Limit depth to prevent infinite loops
    #                     return

                    visited.add(current_id)

    #                 if current_id in self.object_graph:
    #                     for ref_id in self.object_graph[current_id]:
    #                         if ref_id in self.objects and ref_id not in visited:
                                chain.append(f"{ref_id} -{self.objects[ref_id].obj.__class__.__name__}")
                                get_chain_recursive(ref_id, depth + 1)

                get_chain_recursive(obj_id)
    #             return chain

    #         except Exception as e):
                logging.getLogger(__name__).error(f"Reference chain analysis error: {e}")
    #             return []

    #     def shutdown(self):
    #         """Shutdown garbage collector"""
    #         with self.lock:
    #             # Force final collection
    self.collect(force = True)

    #             # Clear all objects
                self.objects.clear()
                self.roots.clear()
                self.object_graph.clear()

    #             # Stop profiling thread
    self.enable_profiling = False


# Memory pool implementation
class MemoryPool
    #     """Memory pool for object allocation"""

    #     def __init__(self, pool_size: int = 1024 * 1024 * 100):  # 100MB default
    self.pool_size = pool_size
    self.used_memory = 0
    self.free_blocks: List[int] = []
    self.allocated_blocks: Dict[int, Tuple[int, int]] = {}  # address - (size, generation)
    self.lock = threading.Lock()

    #         # Initialize free blocks
            self.free_blocks.append(0)

    #     def allocate(self, size): int, generation: int = 0) -Optional[int]):
    #         """Allocate memory from pool"""
    #         with self.lock:
                # Find suitable free block (first-fit)
    #             for i, block_start in enumerate(self.free_blocks):
    block_size = self._get_block_size(block_start)

    #                 if block_size >= size:
    #                     # Use this block
                        self.free_blocks.pop(i)

    #                     # Create allocated block
    allocated_end = block_start + size
    self.allocated_blocks[block_start] = (size, generation)
    self.used_memory + = size

    #                     # Add remaining free block back if any
    remaining_size = block_size - size
    #                     if remaining_size 0):
                            self.free_blocks.append(allocated_end)

    #                     return block_start

    #             return None

    #     def deallocate(self, address: int) -bool):
    #         """Deallocate memory back to pool"""
    #         with self.lock:
    #             if address not in self.allocated_blocks:
    #                 return False

    size, generation = self.allocated_blocks.pop(address)
    self.used_memory - = size

    #             # Add back to free blocks
                self._add_free_block(address, size)

    #             return True

    #     def _get_block_size(self, address: int) -int):
    #         """Get size of memory block"""
    next_address = self.pool_size
    #         for block_start, (size, _) in sorted(self.allocated_blocks.items()):
    #             if block_start address):
    next_address = block_start
    #                 break

    #         return next_address - address

    #     def _add_free_block(self, address: int, size: int):
    #         """Add free block to pool"""
    #         # Merge adjacent blocks
    merged_blocks = []

    #         for i, free_block in enumerate(self.free_blocks):
    #             if free_block == address + size:
    #                 # Merge with next block
                    merged_blocks.append((address, size + self._get_block_size(free_block)))
    #                 # Remove the merged block
                    self.free_blocks.pop(i)
    #                 break
    #         else:
                merged_blocks.append((address, size))

    #         # Add merged blocks
    #         for block_start, block_size in merged_blocks:
                self.free_blocks.append(block_start)

    #         # Sort free blocks
            self.free_blocks.sort()

    #     def get_stats(self) -Dict[str, Any]):
    #         """Get memory pool statistics"""
    #         with self.lock:
    #             return {
    #                 "pool_size": self.pool_size,
    #                 "used_memory": self.used_memory,
    #                 "free_memory": self.pool_size - self.used_memory,
                    "fragmentation": self._calculate_fragmentation(),
                    "free_blocks": len(self.free_blocks),
                    "allocated_blocks": len(self.allocated_blocks)
    #             }

    #     def _calculate_fragmentation(self) -float):
    #         """Calculate memory fragmentation"""
    #         if not self.free_blocks:
    #             return 0.0

    total_free = self.pool_size - self.used_memory
    #         if total_free = 0:
    #             return 0.0

    #         largest_free = max(self._get_block_size(addr) for addr in self.free_blocks)
            return 1.0 - (largest_free / total_free)


# Reference counting implementation
class ReferenceCounter
    #     """Reference counting for objects"""

    #     def __init__(self):
    self.ref_counts: Dict[int, int] = {}
    self.finalizers: Dict[int, Callable] = {}
    self.lock = threading.Lock()

    #     def add_reference(self, obj: Any) -None):
    #         """Add reference to object"""
    #         with self.lock:
    obj_id = id(obj)
    self.ref_counts[obj_id] = self.ref_counts.get(obj_id + 0, 1)

    #     def remove_reference(self, obj: Any) -None):
    #         """Remove reference from object"""
    #         with self.lock:
    obj_id = id(obj)
    #             if obj_id in self.ref_counts:
    self.ref_counts[obj_id] - = 1

    #                 if self.ref_counts[obj_id] <= 0:
    #                     # Object can be collected
    #                     del self.ref_counts[obj_id]

    #                     # Call finalizer if present
    #                     if obj_id in self.finalizers:
    #                         try:
                                self.finalizers[obj_id](obj_id)
    #                             del self.finalizers[obj_id]
    #                         except Exception as e:
    #                             logging.getLogger(__name__).error(f"Finalizer error for object {obj_id}: {e}")

    #     def get_reference_count(self, obj: Any) -int):
    #         """Get reference count for object"""
    #         with self.lock:
                return self.ref_counts.get(id(obj), 0)

    #     def add_finalizer(self, obj: Any, finalizer: Callable) -None):
    #         """Add finalizer for object"""
    #         with self.lock:
    obj_id = id(obj)
    self.finalizers[obj_id] = finalizer

    #     def collect_garbage(self) -List[int]):
    #         """Collect objects with zero references"""
    #         with self.lock:
    #             to_collect = [obj_id for obj_id, count in self.ref_counts.items() if count <= 0]

    #             for obj_id in to_collect:
    #                 del self.ref_counts[obj_id]
    #                 if obj_id in self.finalizers:
    #                     try:
                            self.finalizers[obj_id](obj_id)
    #                         del self.finalizers[obj_id]
    #                     except Exception as e:
    #                         logging.getLogger(__name__).error(f"Finalizer error for object {obj_id}: {e}")

    #             return to_collect


# Example usage
if __name__ == "__main__"
    #     # Create garbage collector
    gc = GarbageCollector(
    max_heap_size = 1024 * 1024 * 10,  # 10MB
    gc_threshold = 0.7,  # 70% threshold
    generations = 3,
    enable_profiling = True,
    enable_compaction = True
    #     )

    #     # Create some objects
    obj1 = {"data": "test", "size": 1024}
    obj2 = [1, 2, 3, 4, 5]
    obj3 = "large string" * 1000

    #     # Register objects
    id1 = gc.register_object(obj1)
    id2 = gc.register_object(obj2)
    id3 = gc.register_object(obj3)

    #     # Add references
        gc.add_root(obj1)
        gc.add_reference(obj1, obj2)
        gc.add_reference(obj2, obj3)

    #     # Get memory stats
        print("Memory stats:", gc.get_memory_stats())

    #     # Force garbage collection
    collection_stats = gc.collect(force=True)
        print("Collection stats:", collection_stats)

    #     # Find memory leaks
    leaks = gc.find_memory_leaks()
        print("Memory leaks:", leaks)

    #     # Optimize memory usage
    optimization_stats = gc.optimize_memory_usage()
        print("Optimization stats:", optimization_stats)

    #     # Create memory pool
    pool = MemoryPool(pool_size=1024 * 1024 * 5  # 5MB)

    #     # Allocate memory
    addr1 = pool.allocate(1024)
    addr2 = pool.allocate(2048)

        print("Pool stats:", pool.get_stats())

    #     # Deallocate memory
        pool.deallocate(addr1)
        print("Pool stats after deallocation:", pool.get_stats())

    #     # Create reference counter
    ref_counter = ReferenceCounter()

    #     # Add references
        ref_counter.add_reference(obj1)
        ref_counter.add_reference(obj1)

    #     print("Reference count for obj1:", ref_counter.get_reference_count(obj1))

    #     # Remove references
        ref_counter.remove_reference(obj1)
        ref_counter.remove_reference(obj1)

    #     # Collect garbage
    collected = ref_counter.collect_garbage()
        print("Collected objects:", collected)

    #     # Shutdown garbage collector
        gc.shutdown()
