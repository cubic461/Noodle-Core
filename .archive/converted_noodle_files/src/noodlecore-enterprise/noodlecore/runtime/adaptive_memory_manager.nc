# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Hybrid Adaptive Memory Manager with Sheaves & Barns

# This module implements a sophisticated memory management system that combines
# local sheaf allocation with centralized barn pooling, adapting its strategy
# based on runtime context and workload patterns.

# The system provides:
- Context-aware strategy selection (local vs distributed)
# - Adaptive sheaf sizing based on workload patterns
# - Lock-free allocation for performance-critical paths
# - Intelligent batching and prefill strategies
# - Seamless fallback to traditional GC/heap allocation
# """

import asyncio
import threading
import time
import weakref
import logging
import gc
import psutil
import math
import abc.ABC,
import dataclasses.dataclass,
import enum.Enum
import typing.Any,
import collections.defaultdict,
import heapq
import uuid
import mmap
import os

logger = logging.getLogger(__name__)


class MemoryContext(Enum)
    #     """Runtime execution context for adaptive memory management"""
    LOCAL = "local"           # Single-node execution
    DISTRIBUTED = "distributed" # Multi-node cluster
    TRANSITIONING = "transitioning" # Context switching


class AllocationStrategy(Enum)
    #     """Memory allocation strategies based on context and workload"""
    SHEAF_LOCAL = "sheaf_local"        # Use local sheaf buffer
    SHEAF_DISTRIBUTED = "sheaf_distributed" # Use distributed barn
    HYBRID_ADAPTIVE = "hybrid_adaptive" # Adaptive switching
    FALLBACK_HEAP = "fallback_heap"     # Direct heap allocation
    FALLBACK_REGION = "fallback_region" # Region-based allocation


# @dataclass
class MemoryRequest
    #     """Represents a memory allocation request"""
    #     size: int
    alignment: int = 8
    object_type: str = "generic"
    priority: int = 0  # Higher = more urgent
    context: Dict[str, Any] = field(default_factory=dict)
    allocation_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=time.time)


# @dataclass
class MemoryStats
    #     """Performance metrics for memory allocation"""
    total_allocations: int = 0
    sheaf_hits: int = 0
    sheaf_misses: int = 0
    barn_hits: int = 0
    barn_misses: int = 0
    fallback_allocations: int = 0
    average_allocation_time: float = 0.0
    peak_memory_usage: int = 0
    current_memory_usage: int = 0
    gc_pressure: float = 0.0


# @dataclass
class SheafConfig
    #     """Configuration for sheaf buffers"""
    size: int = math.multiply(4, 1024 * 1024  # 4MB default)
    max_objects: int = 1000
    prefill_ratio: float = 0.1    # 10% prefill
    adaptive_sizing: bool = True
    min_size: int = math.multiply(256, 1024    # 256KB)
    max_size: int = math.multiply(16, 1024 * 1024  # 16MB)


# @dataclass
class BarnConfig
    #     """Configuration for central barn pool"""
    max_size: int = math.multiply(100, 1024 * 1024  # 100MB)
    max_sheaves: int = 25
    replication_factor: int = 2
    load_threshold: float = 0.8
    sync_interval: float = 1.0


# @dataclass
class AdaptiveConfig
    #     """Overall adaptive memory manager configuration"""
    context: MemoryContext = MemoryContext.LOCAL
    strategy: AllocationStrategy = AllocationStrategy.HYBRID_ADAPTIVE
    sheaf: SheafConfig = field(default_factory=SheafConfig)
    barn: BarnConfig = field(default_factory=BarnConfig)
    adaptation_interval: float = 5.0  # seconds
    #     performance_window: float = 30.0  # seconds for performance analysis
    enable_monitoring: bool = True
    enable_prefill: bool = True
    enable_batching: bool = True
    batch_size: int = 100
    batch_timeout: float = 0.1  # seconds


class Sheaf
    #     """Local memory buffer for fast lock-free allocation"""

    #     def __init__(self, sheaf_id: str, size: int, config: SheafConfig):
    self.sheaf_id = sheaf_id
    self.size = size
    self.config = config
    self._buffer = math.subtract(mmap.mmap(, 1, size, access=mmap.ACCESS_WRITE))
    self._offset = 0
    self._used = 0
    self._lock = threading.RLock()
    self._allocations: Dict[int, Tuple[int, int]] = math.subtract({}  # offset, > (size, alignment))
    self._free_list: List[int] = []  # Available offsets
    self._last_access = time.time()
    self._allocation_count = 0
    self._hit_count = 0

    #         # Prefill strategy
    #         if config.prefill_ratio > 0:
                self._prefill()

    #     def _prefill(self):
    #         """Pre-allocate small objects for faster initial allocation"""
    prefill_size = math.multiply(int(self.size, self.config.prefill_ratio))
    #         if prefill_size > 0:
    #             try:
    #                 # Create pre-allocated small chunks
    chunk_size = 64  # Small objects
    chunks = []
    #                 for i in range(0, prefill_size, chunk_size):
    offset = self._allocate(chunk_size, 8)
    #                     if offset is not None:
                            chunks.append(offset)

                    logger.debug(f"Sheaf {self.sheaf_id} pre-filled {len(chunks)} chunks")
    #             except Exception as e:
                    logger.warning(f"Sheaf {self.sheaf_id} prefill failed: {e}")

    #     def allocate(self, size: int, alignment: int = 8) -> Optional[int]:
    #         """Allocate memory from sheaf with alignment"""
    #         if size <= 0:
    #             return None

    #         # Check for small objects that might be pre-allocated
    #         if size <= 64 and self._free_list:
    #             for offset in self._free_list:
    #                 if self._is_aligned(offset, alignment):
                        self._free_list.remove(offset)
    self._allocations[offset] = (size, alignment)
    self._used + = size
    self._last_access = time.time()
    self._allocation_count + = 1
    #                     return offset

    #         # Try to find contiguous block
    offset = self._find_contiguous_block(size, alignment)
    #         if offset is not None:
    self._allocations[offset] = (size, alignment)
    self._used + = size
    self._last_access = time.time()
    self._allocation_count + = 1
    #             return offset

    #         return None

    #     def _allocate(self, size: int, alignment: int = 8) -> Optional[int]:
    #         """Internal allocation method (for compatibility)"""
            return self.allocate(size, alignment)

    #     def _find_contiguous_block(self, size: int, alignment: int) -> Optional[int]:
    #         """Find a contiguous block of requested size"""
    #         # First try free list
    #         for offset in self._free_list:
    #             if self._is_aligned(offset, alignment) and self._is_contiguous_free(offset, size):
    #                 return offset

    #         # Then try extending current offset
    #         if self._offset + size <= self.size and self._is_aligned(self._offset, alignment):
    #             # Check if area is free
    #             if self._is_contiguous_free(self._offset, size):
    offset = self._offset
    self._offset + = size
    #                 return offset

    #         return None

    #     def _is_aligned(self, offset: int, alignment: int) -> bool:
    #         """Check if offset is properly aligned"""
    return offset % alignment = = 0

    #     def _is_contiguous_free(self, offset: int, size: int) -> bool:
    #         """Check if area is contiguous and free"""
    end_offset = math.add(offset, size)
    #         if end_offset > self.size:
    #             return False

    #         # Check if area overlaps with any allocations
    #         for alloc_offset, (alloc_size, _) in self._allocations.items():
    #             if not (end_offset <= alloc_offset or offset >= alloc_offset + alloc_size):
    #                 return False

    #         return True

    #     def free(self, offset: int) -> bool:
    #         """Free memory back to sheaf"""
    #         if offset in self._allocations:
    size, alignment = self._allocations[offset]
    #             del self._allocations[offset]
    self._used - = size
                self._free_list.append(offset)
    self._last_access = time.time()
    #             return True
    #         return False

    #     def get_usage_stats(self) -> Dict[str, Any]:
    #         """Get sheaf usage statistics"""
    #         return {
    #             "sheaf_id": self.sheaf_id,
    #             "size": self.size,
    #             "used": self._used,
    #             "free": self.size - self._used,
    #             "utilization": self._used / self.size if self.size > 0 else 0,
    #             "allocation_count": self._allocation_count,
    #             "hit_count": self._hit_count,
    #             "last_access": self._last_access,
                "fragmentation": self._calculate_fragmentation()
    #         }

    #     def _calculate_fragmentation(self) -> float:
    #         """Calculate memory fragmentation ratio"""
    #         if self._used == 0:
    #             return 0.0

    #         # Simple fragmentation calculation based on free space distribution
    free_blocks = len(self._free_list)
    #         if free_blocks == 0:
    #             return 0.0

    avg_free_size = math.subtract((self.size, self._used) / free_blocks)
            return 1.0 - (avg_free_size / (self.size / free_blocks))

    #     def cleanup(self):
    #         """Clean up sheaf resources"""
    #         try:
                self._buffer.close()
    #         except:
    #             pass


class Barn
    #     """Central pool for managing sheaf reuse and distribution"""

    #     def __init__(self, config: BarnConfig):
    self.config = config
    self._sheaves: Dict[str, Sheaf] = {}
    self._lock = threading.RLock()
    self._stats = MemoryStats()
    self._last_sync = time.time()
    self._load_monitor = threading.Thread(target=self._monitor_load, daemon=True)
            self._load_monitor.start()

    #     def create_sheaf(self, sheaf_id: str, size: int = None) -> Optional[Sheaf]:
    #         """Create a new sheaf in the barn"""
    #         with self._lock:
    #             if len(self._sheaves) >= self.config.max_sheaves:
                    logger.warning(f"Barn at capacity ({self.config.max_sheaves} sheaves)")
    #                 return None

    #             if size is None:
    size = math.multiply(4, 1024 * 1024  # Default 4MB)

    #             # Check total size limit
    #             total_size = sum(s.size for s in self._sheaves.values())
    #             if total_size + size > self.config.max_size:
                    logger.warning(f"Barn size limit exceeded")
    #                 return None

    sheaf = Sheaf(sheaf_id, size, SheafConfig())
    self._sheaves[sheaf_id] = sheaf
                logger.debug(f"Created sheaf {sheaf_id} in barn")
    #             return sheaf

    #     def get_sheaf(self, sheaf_id: str) -> Optional[Sheaf]:
    #         """Get a sheaf from the barn"""
    #         with self._lock:
                return self._sheaves.get(sheaf_id)

    #     def return_sheaf(self, sheaf_id: str) -> bool:
    #         """Return a sheaf to the barn for reuse"""
    #         with self._lock:
    #             if sheaf_id in self._sheaves:
                    logger.debug(f"Returned sheaf {sheaf_id} to barn")
    #                 return True
    #             return False

    #     def _monitor_load(self):
    #         """Monitor barn load and trigger cleanup if needed"""
    #         while True:
                time.sleep(self.config.sync_interval)

    #             with self._lock:
    #                 total_size = sum(s.size for s in self._sheaves.values())
    load_ratio = math.divide(total_size, self.config.max_size)

    #                 if load_ratio > self.config.load_threshold:
                        self._cleanup_underutilized_sheaves()

    #     def _cleanup_underutilized_sheaves(self):
    #         """Remove underutilized sheaves to free space"""
            # Sort sheaves by utilization (lowest first)
    sheaves_sorted = sorted(
                self._sheaves.items(),
    key = lambda x: x[1].get_usage_stats()["utilization"]
    #         )

    #         # Remove bottom 20% of sheaves
    remove_count = math.divide(max(1, len(sheaves_sorted), / 5))
    #         for sheaf_id, sheaf in sheaves_sorted[:remove_count]:
                logger.debug(f"Removing underutilized sheaf {sheaf_id}")
                sheaf.cleanup()
    #             del self._sheaves[sheaf_id]

    #     def get_stats(self) -> MemoryStats:
    #         """Get barn statistics"""
    #         with self._lock:
    #             return self._stats


class ContextDetector
    #     """Detects runtime context and determines optimal strategy"""

    #     def __init__(self):
    self._context = MemoryContext.LOCAL
    self._node_count = 1
    self._actor_count = 0
    self._load_factor = 0.0
    self._memory_pressure = 0.0
    self._last_analysis = time.time()

    #     def analyze_context(self, system_stats: Dict[str, Any]) -> MemoryContext:
    #         """Analyze system context and determine appropriate memory strategy"""
    current_time = time.time()

    #         # Update metrics
    self._node_count = system_stats.get("node_count", 1)
    self._actor_count = system_stats.get("actor_count", 0)
    self._load_factor = system_stats.get("load_factor", 0.0)
    self._memory_pressure = system_stats.get("memory_pressure", 0.0)

    #         # Context determination logic
    #         if self._node_count == 1 and self._actor_count < 10:
    self._context = MemoryContext.LOCAL
    #         elif self._node_count > 1 or self._actor_count >= 50:
    self._context = MemoryContext.DISTRIBUTED
    #         else:
    self._context = MemoryContext.TRANSITIONING

    self._last_analysis = current_time
    #         return self._context

    #     def get_optimal_strategy(self, context: MemoryContext, workload_pattern: str) -> AllocationStrategy:
    #         """Determine optimal allocation strategy based on context and workload"""
    #         if context == MemoryContext.LOCAL:
    #             if workload_pattern == "compute_intensive":
    #                 return AllocationStrategy.SHEAF_LOCAL
    #             else:
    #                 return AllocationStrategy.HYBRID_ADAPTIVE

    #         elif context == MemoryContext.DISTRIBUTED:
    #             if workload_pattern == "memory_intensive":
    #                 return AllocationStrategy.SHEAF_DISTRIBUTED
    #             else:
    #                 return AllocationStrategy.HYBRID_ADAPTIVE

    #         else:  # TRANSITIONING
    #             return AllocationStrategy.HYBRID_ADAPTIVE


class AdaptiveMemoryManager
    #     """Main adaptive memory manager coordinating sheaves and barns"""

    #     def __init__(self, config: AdaptiveConfig = None):
    self.config = config or AdaptiveConfig()
    self._context_detector = ContextDetector()
    self._barn = Barn(self.config.barn)
    self._sheaves: Dict[str, Sheaf] = {}  # Active sheaves (not in barn)
    self._actor_sheaf_map: Dict[str, str] = math.subtract({}  # actor_id, > sheaf_id)
    self._stats = MemoryStats()
    self._allocation_history = deque(maxlen=1000)
    self._performance_window = deque(maxlen=int(self.config.performance_window))
    self._batch_queue: List[MemoryRequest] = []
    self._lock = threading.RLock()
    self._monitoring_thread = None
    self._adaptation_thread = None
    self._running = False

    #         # Start background threads
            self._start_background_threads()

    #     def _start_background_threads(self):
    #         """Start monitoring and adaptation threads"""
    self._running = True

    #         # Performance monitoring thread
    self._monitoring_thread = threading.Thread(
    target = self._monitoring_loop,
    daemon = True
    #         )
            self._monitoring_thread.start()

    #         # Adaptation thread
    self._adaptation_thread = threading.Thread(
    target = self._adaptation_loop,
    daemon = True
    #         )
            self._adaptation_thread.start()

    #     def _monitoring_loop(self):
    #         """Continuous performance monitoring"""
    #         while self._running:
    #             try:
                    self._update_performance_metrics()
                    time.sleep(1.0)  # Monitor every second
    #             except Exception as e:
                    logger.error(f"Monitoring error: {e}")

    #     def _adaptation_loop(self):
    #         """Continuous adaptation of memory strategies"""
    #         while self._running:
    #             try:
                    self._adapt_strategies()
                    time.sleep(self.config.adaptation_interval)
    #             except Exception as e:
                    logger.error(f"Adaptation error: {e}")

    #     def allocate(self, size: int, alignment: int = 8, actor_id: str = None,
    object_type: str = "generic", priority: int = 0) -> Optional[int]:
    #         """Allocate memory using adaptive strategy"""
    request = MemoryRequest(
    size = size,
    alignment = alignment,
    object_type = object_type,
    priority = priority,
    context = {"actor_id": actor_id}
    #         )

    start_time = time.time()

    #         try:
    #             # Determine allocation strategy
    strategy = self._determine_allocation_strategy(request)
    result = self._execute_allocation(request, strategy)

    #             # Update statistics
    allocation_time = math.subtract(time.time(), start_time)
                self._update_allocation_stats(request, strategy, result, allocation_time)

    #             return result

    #         except Exception as e:
                logger.error(f"Allocation failed: {e}")
    #             # Only count as fallback if allocation actually failed
    #             # If we got a result from the exception handler, don't increment
    #             if result is None:
    self._stats.fallback_allocations + = 1
    #             return result

    #     def _determine_allocation_strategy(self, request: MemoryRequest) -> AllocationStrategy:
    #         """Determine the best allocation strategy for this request"""
    #         # Get system context
    system_stats = self._get_system_stats()
    context = self._context_detector.analyze_context(system_stats)

    #         # Determine workload pattern
    workload_pattern = self._analyze_workload_pattern(request)

    #         # Get optimal strategy
    optimal_strategy = self._context_detector.get_optimal_strategy(context, workload_pattern)

    #         # Apply business logic based on request characteristics
    #         if request.size > 100 * 1024:  # Large objects
    #             return AllocationStrategy.FALLBACK_HEAP
    #         elif request.object_type == "mathematical":
    #             return AllocationStrategy.SHEAF_LOCAL
    #         else:
    #             return optimal_strategy

    #     def _execute_allocation(self, request: MemoryRequest, strategy: AllocationStrategy) -> Optional[int]:
    #         """Execute allocation using the specified strategy"""
    #         if strategy == AllocationStrategy.SHEAF_LOCAL:
                return self._allocate_from_sheaf(request)
    #         elif strategy == AllocationStrategy.SHEAF_DISTRIBUTED:
                return self._allocate_from_barn(request)
    #         elif strategy == AllocationStrategy.HYBRID_ADAPTIVE:
                return self._allocate_hybrid(request)
    #         elif strategy == AllocationStrategy.FALLBACK_HEAP:
                return self._allocate_fallback_heap(request)
    #         elif strategy == AllocationStrategy.FALLBACK_REGION:
                return self._allocate_fallback_region(request)
    #         else:
                return self._allocate_fallback_heap(request)

    #     def _allocate_from_sheaf(self, request: MemoryRequest) -> Optional[int]:
    #         """Allocate from local sheaf buffer"""
    actor_id = request.context.get("actor_id")

    #         # Get or create sheaf for this actor
    sheaf_id = self._actor_sheaf_map.get(actor_id)
    #         if not sheaf_id:
    sheaf_id = f"sheaf_{actor_id}_{uuid.uuid4().hex[:8]}"
    sheaf = Sheaf(sheaf_id, self.config.sheaf.size, self.config.sheaf)
    self._sheaves[sheaf_id] = sheaf
    self._actor_sheaf_map[actor_id] = sheaf_id

    sheaf = self._sheaves.get(sheaf_id)
    #         if not sheaf:
    #             return None

    #         # Try allocation
    result = sheaf.allocate(request.size, request.alignment)
    #         if result is not None:
    self._stats.sheaf_hits + = 1
    sheaf._hit_count + = 1
    #         else:
    self._stats.sheaf_misses + = 1

    #         return result

    #     def _allocate_from_barn(self, request: MemoryRequest) -> Optional[int]:
    #         """Allocate from central barn pool"""
    #         # Create unique sheaf for this request
    sheaf_id = f"barn_sheaf_{uuid.uuid4().hex[:8]}"
    sheaf = self._barn.create_sheaf(sheaf_id, self.config.sheaf.size)

    #         if sheaf:
    result = sheaf.allocate(request.size, request.alignment)
    #             if result is not None:
    self._stats.barn_hits + = 1
    #             else:
    self._stats.barn_misses + = 1
    #             return result

    self._stats.barn_misses + = 1
    #         return None

    #     def _allocate_hybrid(self, request: MemoryRequest) -> Optional[int]:
    #         """Hybrid allocation strategy with fallback"""
    #         # Try local sheaf first
    result = self._allocate_from_sheaf(request)
    #         if result is not None:
    #             return result

    #         # Try barn
    result = self._allocate_from_barn(request)
    #         if result is not None:
    #             return result

    #         # Fallback to heap
            return self._allocate_fallback_heap(request)

    #     def _allocate_fallback_heap(self, request: MemoryRequest) -> Optional[int]:
    #         """Fallback to traditional heap allocation"""
    #         try:
    #             # Use Python's built-in memory allocation
    #             import ctypes
    alignment = max(request.alignment, 8)
    size = math.add(((request.size, alignment - 1) // alignment) * alignment)

    #             # Use Python's malloc directly
    ptr = ctypes.pythonapi.malloc(ctypes.c_size_t(size))

    #             if ptr != 0:
    self._stats.fallback_allocations + = 1
    #                 return ptr
    #             else:
    #                 return None

    #         except Exception as e:
                logger.error(f"Heap allocation failed: {e}")
    #             # Try even simpler approach
    #             try:
    #                 # Allocate bytes and return id as address
    data = bytearray(size)
                    return id(data)
    #             except Exception as e2:
                    logger.error(f"Simple allocation failed: {e2}")
    #                 return None

    #     def _allocate_fallback_region(self, request: MemoryRequest) -> Optional[int]:
    #         """Fallback to region-based allocation"""
    #         # This would integrate with existing hybrid memory model
    #         # For now, just use heap allocation
            return self._allocate_fallback_heap(request)

    #     def free(self, address: int, size: int = 0, actor_id: str = None) -> bool:
    #         """Free memory back to appropriate pool"""
    #         try:
    #             # Try to find which sheaf this address belongs to
    #             for sheaf_id, sheaf in self._sheaves.items():
    #                 if self._address_in_sheaf(address, sheaf):
                        return sheaf.free(address)

    #             # Try barn sheaves
    #             for sheaf in self._barn._sheaves.values():
    #                 if self._address_in_sheaf(address, sheaf):
                        return sheaf.free(address)

    #             # Fallback to heap free
                self._free_heap(address)
    #             return True

    #         except Exception as e:
                logger.error(f"Free operation failed: {e}")
    #             return False

    #     def _address_in_sheaf(self, address: int, sheaf: Sheaf) -> bool:
    #         """Check if address belongs to sheaf"""
    #         # This is a simplified check - in reality we'd need better tracking
    #         return True  # Placeholder for implementation

    #     def _free_heap(self, address: int):
    #         """Free heap memory"""
    #         try:
    #             import ctypes
                ctypes.pythonapi.free(address)
    #         except Exception as e:
                logger.error(f"Heap free failed: {e}")

    #     def _get_system_stats(self) -> Dict[str, Any]:
    #         """Get current system statistics"""
    #         try:
    #             return {
    #                 "node_count": 1,  # Would be detected in distributed mode
                    "actor_count": len(self._actor_sheaf_map),
                    "load_factor": psutil.cpu_percent() / 100.0,
                    "memory_pressure": psutil.virtual_memory().percent / 100.0,
                    "available_memory": psutil.virtual_memory().available,
                    "total_memory": psutil.virtual_memory().total
    #             }
    #         except Exception as e:
                logger.error(f"System stats error: {e}")
    #             return {
    #                 "node_count": 1,
                    "actor_count": len(self._actor_sheaf_map),
    #                 "load_factor": 0.0,
    #                 "memory_pressure": 0.0,
    #                 "available_memory": 1024 * 1024 * 1024,
    #                 "total_memory": 8 * 1024 * 1024 * 1024
    #             }

    #     def _analyze_workload_pattern(self, request: MemoryRequest) -> str:
    #         """Analyze workload pattern for strategy selection"""
    #         # Simple pattern analysis based on request characteristics
    #         if request.size > 50 * 1024:  # Large allocations
    #             return "memory_intensive"
    #         elif request.object_type == "mathematical":
    #             return "compute_intensive"
    #         else:
    #             return "general"

    #     def _update_allocation_stats(self, request: MemoryRequest, strategy: AllocationStrategy,
    #                                  result: Optional[int], allocation_time: float):
    #         """Update allocation statistics"""
    self._stats.total_allocations + = 1
    self._stats.average_allocation_time = (
                (self._stats.average_allocation_time * (self._stats.total_allocations - 1) + allocation_time) /
    #             self._stats.total_allocations
    #         )

            # Track memory usage (simplified)
    #         if result is not None:
    self._stats.current_memory_usage + = request.size
    self._stats.peak_memory_usage = max(self._stats.peak_memory_usage, self._stats.current_memory_usage)

    #         # Add to history
            self._allocation_history.append({
    #             "request": request,
    #             "strategy": strategy,
    #             "result": result,
    #             "time": allocation_time,
                "timestamp": time.time()
    #         })

    #     def _update_performance_metrics(self):
    #         """Update performance monitoring metrics"""
    #         # Calculate GC pressure
    #         try:
    gc_count = len(gc.get_objects())
    self._stats.gc_pressure = math.divide(gc_count, 10000.0  # Normalize)
    #         except:
    self._stats.gc_pressure = 0.0

    #         # Add to performance window
            self._performance_window.append({
                "timestamp": time.time(),
    #             "memory_usage": self._stats.current_memory_usage,
    #             "gc_pressure": self._stats.gc_pressure,
                "allocation_rate": self._stats.total_allocations / max(1, time.time() - getattr(self, '_start_time', time.time()))
    #         })

    #     def _adapt_strategies(self):
    #         """Adapt allocation strategies based on performance"""
    #         if not self._performance_window:
    #             return

    #         # Analyze recent performance
    recent_performance = math.subtract(list(self._performance_window)[, 60:]  # Last 60 seconds)

    #         # Check for performance issues
    #         avg_allocation_time = sum(p.get("allocation_rate", 0) for p in recent_performance) / len(recent_performance)
    #         high_gc_pressure = any(p.get("gc_pressure", 0) > 0.8 for p in recent_performance)

    #         # Adapt configuration based on performance
    #         if high_gc_pressure:
    #             # Reduce prefill to reduce GC pressure
    self.config.sheaf.prefill_ratio = math.subtract(max(0.05, self.config.sheaf.prefill_ratio, 0.01))
                logger.info("Reduced prefill ratio due to high GC pressure")

    #         if avg_allocation_time > 0.01:  # 10ms average allocation time
    #             # Increase batch size for better throughput
    self.config.batch_size = math.add(min(500, self.config.batch_size, 10))
                logger.info("Increased batch size due to slow allocation times")

    #     def register_actor(self, actor_id: str):
    #         """Register a new actor and assign it a sheaf"""
    #         with self._lock:
    #             if actor_id not in self._actor_sheaf_map:
    sheaf_id = f"actor_{actor_id}_{uuid.uuid4().hex[:8]}"
    sheaf = Sheaf(sheaf_id, self.config.sheaf.size, self.config.sheaf)
    self._sheaves[sheaf_id] = sheaf
    self._actor_sheaf_map[actor_id] = sheaf_id
    #                 logger.debug(f"Registered actor {actor_id} with sheaf {sheaf_id}")

    #     def unregister_actor(self, actor_id: str):
    #         """Unregister an actor and clean up its sheaf"""
    #         with self._lock:
    #             if actor_id in self._actor_sheaf_map:
    sheaf_id = self._actor_sheaf_map[actor_id]
    #                 if sheaf_id in self._sheaves:
    sheaf = self._sheaves[sheaf_id]
                        sheaf.cleanup()
    #                     del self._sheaves[sheaf_id]
    #                 del self._actor_sheaf_map[actor_id]
                    logger.debug(f"Unregistered actor {actor_id}")

    #     def get_stats(self) -> MemoryStats:
    #         """Get comprehensive memory statistics"""
    #         with self._lock:
    stats = MemoryStats(
    total_allocations = self._stats.total_allocations,
    sheaf_hits = self._stats.sheaf_hits,
    sheaf_misses = self._stats.sheaf_misses,
    barn_hits = self._stats.barn_hits,
    barn_misses = self._stats.barn_misses,
    fallback_allocations = self._stats.fallback_allocations,
    average_allocation_time = self._stats.average_allocation_time,
    peak_memory_usage = self._stats.peak_memory_usage,
    current_memory_usage = self._stats.current_memory_usage,
    gc_pressure = self._stats.gc_pressure
    #             )
    #             return stats

    #     def get_sheaf_stats(self) -> Dict[str, Any]:
    #         """Get statistics for all active sheaves"""
    #         with self._lock:
    #             return {
                    sheaf_id: sheaf.get_usage_stats()
    #                 for sheaf_id, sheaf in self._sheaves.items()
    #             }

    #     def cleanup(self):
    #         """Clean up resources"""
    self._running = False

    #         # Cleanup all sheaves
    #         for sheaf in self._sheaves.values():
                sheaf.cleanup()
            self._sheaves.clear()

    #         # Cleanup barn
    #         for sheaf in self._barn._sheaves.values():
                sheaf.cleanup()
            self._barn._sheaves.clear()

            logger.info("Adaptive memory manager cleaned up")


# Global instance for easy access
_global_manager: Optional[AdaptiveMemoryManager] = None
_manager_lock = threading.RLock()


def get_global_manager() -> AdaptiveMemoryManager:
#     """Get the global adaptive memory manager instance"""
#     global _global_manager
#     with _manager_lock:
#         if _global_manager is None:
_global_manager = AdaptiveMemoryManager()
#         return _global_manager


def init_memory_manager(config: AdaptiveConfig = None) -> AdaptiveMemoryManager:
#     """Initialize the global memory manager with custom configuration"""
#     global _global_manager
#     with _manager_lock:
_global_manager = AdaptiveMemoryManager(config)
#         return _global_manager


function cleanup_memory_manager()
    #     """Clean up the global memory manager"""
    #     global _global_manager
    #     with _manager_lock:
    #         if _global_manager is not None:
                _global_manager.cleanup()
    _global_manager = None
