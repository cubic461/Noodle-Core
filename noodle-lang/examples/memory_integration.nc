# Converted from Python to NoodleCore
# Original file: src

# """
# Memory Integration Layer for NBC Runtime

# This module provides integration between the adaptive sheaves & barns memory manager
# and the existing NBC runtime, ensuring seamless compatibility and performance.
# """

import time
import threading
import logging
import weakref
import gc
import typing.Any
from dataclasses import dataclass
import abc.ABC

import .adaptive_memory_manager.(
#     AdaptiveMemoryManager, AdaptiveConfig, MemoryRequest, AllocationStrategy,
#     get_global_manager, init_memory_manager
# )
import .context_detector.ContextDetector
import .adaptive_sizing.AdaptiveSizingEngine

logger = logging.getLogger(__name__)



dataclass
class NBCMemoryRequest
    #     """NBC-specific memory request wrapper"""
    #     size: int
    alignment: int = 8
    object_type: str = "nbc_object"
    priority: int = 0
    bytecode_context: Dict[str, Any] = field(default_factory=dict)
    allocation_id: str = field(default_factory=lambda: f"nbc_{time.time()}_{id(self)}")
    timestamp: float = field(default_factory=time.time)


dataclass
class NBCMemoryStats
    #     """NBC-specific memory statistics"""
    nbc_allocations: int = 0
    nbc_frees: int = 0
    nbc_sheaf_hits: int = 0
    nbc_barn_hits: int = 0
    nbc_fallback_allocations: int = 0
    average_nbc_allocation_time: float = 0.0
    nbc_memory_usage: int = 0
    nbc_gc_interactions: int = 0

    #     # Integration metrics
    integration_overhead: float = 0.0
    compatibility_mode: bool = False
    last_integration_check: float = 0.0


class NBCMemoryAllocator
    #     """NBC-compatible memory allocator using adaptive sheaves & barns"""

    #     def __init__(self, config: AdaptiveConfig = None):
    self.config = config or AdaptiveConfig()
    self.memory_manager = init_memory_manager(config)
    self.context_detector = ContextDetector()
    self.sizing_manager = SheafSizingManager(
    AdaptiveSizingEngine(base_size = self.config.sheaf.size)
    #         )

    #         # NBC-specific state
    self.nbc_objects: Dict[int, Dict[str, Any]] = {}  # address - metadata
    self.allocator_stats = NBCMemoryStats()
    self._lock = threading.RLock()

    #         # Integration state
    self._integration_active = True
    self._last_gc_sync = time.time()
    self._gc_sync_interval = 5.0  # seconds

    #         # Start integration monitoring
            self._start_integration_monitoring()

    #     def _start_integration_monitoring(self)):
    #         """Start integration monitoring thread"""
    monitor_thread = threading.Thread(
    target = self._integration_monitoring_loop,
    daemon = True
    #         )
            monitor_thread.start()
            logger.info("NBC memory integration monitoring started")

    #     def _integration_monitoring_loop(self):
    #         """Monitor integration health and performance"""
    #         while True:
    #             try:
                    self._check_integration_health()
                    self._sync_with_gc()
                    time.sleep(1.0)
    #             except Exception as e:
                    logger.error(f"Integration monitoring error: {e}")
                    time.sleep(5.0)

    #     def _check_integration_health(self):
    #         """Check integration health and compatibility"""
    current_time = time.time()

    #         # Check if integration is still active
    #         if not self._integration_active:
    #             return

    #         # Check memory manager health
    #         if not self.memory_manager._running:
                logger.warning("Memory manager not running - reinitializing")
    self.memory_manager = init_memory_manager(self.config)

    #         # Check sizing manager health
    #         if not hasattr(self.sizing_manager, 'actor_sizing'):
                logger.warning("Sizing manager not properly initialized")
    self.sizing_manager = SheafSizingManager(
    AdaptiveSizingEngine(base_size = self.config.sheaf.size)
    #             )

    #         # Update last check time
    self.allocator_stats.last_integration_check = current_time

    #     def _sync_with_gc(self):
    #         """Synchronize with garbage collector"""
    current_time = time.time()

    #         if current_time - self._last_gc_sync < self._gc_sync_interval:
    #             return

    #         try:
    #             # Record GC event for context detector
    #             self.context_detector.record_gc_event(0.0)  # Placeholder for actual pause time

    #             # Update sizing metrics with GC pressure
    metrics = SizingMetrics(
    timestamp = current_time,
    gc_pressure = math.divide(len(gc.get_objects()), 10000.0  # Normalize)
    #             )
                self.sizing_manager.global_engine.record_metrics(metrics)

    self._last_gc_sync = current_time

    #         except Exception as e:
                logger.error(f"GC sync error: {e}")

    #     def nbc_allocate(self, size: int, alignment: int = 8,
    object_type: str = "nbc_object", priority: int = 0,
    bytecode_context: Dict[str, Any] = None) - Optional[int]):
    #         """
    #         NBC-compatible memory allocation

    #         Args:
    #             size: Size of memory to allocate
    #             alignment: Memory alignment requirement
    #             object_type: Type of NBC object being allocated
    priority: Allocation priority (higher = more urgent)
    #             bytecode_context: Context from bytecode execution

    #         Returns:
    #             Memory address or None if allocation failed
    #         """
    start_time = time.time()

    #         try:
    #             # Create NBC memory request
    request = NBCMemoryRequest(
    size = size,
    alignment = alignment,
    object_type = object_type,
    priority = priority,
    bytecode_context = bytecode_context or {}
    #             )

    #             # Map NBC object type to adaptive strategy
    strategy = self._map_nbc_to_adaptive_strategy(request)

    #             # Perform allocation
    address = self.memory_manager.allocate(
    size = size,
    alignment = alignment,
    actor_id = request.bytecode_context.get("actor_id"),
    object_type = object_type,
    priority = priority
    #             )

    #             if address is not None:
    #                 # Track NBC object
    #                 with self._lock:
    self.nbc_objects[address] = {
    #                         "size": size,
    #                         "alignment": alignment,
    #                         "object_type": object_type,
    #                         "allocation_id": request.allocation_id,
    #                         "timestamp": request.timestamp,
    #                         "strategy": strategy,
    #                         "bytecode_context": request.bytecode_context
    #                     }
    self.allocator_stats.nbc_allocations + = 1
    self.allocator_stats.nbc_memory_usage + = size

    #             # Update statistics
    allocation_time = time.time() - start_time
                self._update_nbc_stats(request, address, allocation_time)

    #             return address

    #         except Exception as e:
                logger.error(f"NBC allocation error: {e}")
    self.allocator_stats.nbc_fallback_allocations + = 1
    #             return None

    #     def _map_nbc_to_adaptive_strategy(self, request: NBCMemoryRequest) -AllocationStrategy):
    #         """Map NBC object type to adaptive allocation strategy"""
    object_type = request.object_type

    #         # NBC-specific strategy mapping
    #         if object_type.startswith("tensor_"):
    #             return AllocationStrategy.SHEAF_LOCAL  # Tensors benefit from local allocation
    #         elif object_type.startswith("matrix_"):
    #             return AllocationStrategy.SHEAF_LOCAL  # Matrices are compute-intensive
    #         elif object_type.startswith("vector_"):
    #             return AllocationStrategy.HYBRID_ADAPTIVE  # Vectors can use hybrid
    #         elif object_type.startswith("table_"):
    #             return AllocationStrategy.SHEAF_DISTRIBUTED  # Tables might be large
    #         elif object_type.startswith("actor_"):
    #             return AllocationStrategy.SHEAF_LOCAL  # Actor state should be local
    #         elif object_type.startswith("math_"):
    #             return AllocationStrategy.SHEAF_LOCAL  # Mathematical objects
    #         else:
    #             return AllocationStrategy.HYBRID_ADAPTIVE  # Default for unknown types

    #     def _update_nbc_stats(self, request: NBCMemoryRequest, address: Optional[int], allocation_time: float):
    #         """Update NBC-specific statistics"""
    #         if address is not None:
    self.allocator_stats.nbc_sheaf_hits + = 1
    #         else:
    self.allocator_stats.nbc_fallback_allocations + = 1

    #         # Update average allocation time
    total_allocations = self.allocator_stats.nbc_allocations
    current_avg = self.allocator_stats.average_nbc_allocation_time
    self.allocator_stats.average_nbc_allocation_time = (
                (current_avg * (total_allocations - 1) + allocation_time) / total_allocations
    #         )

    #     def nbc_free(self, address: int, size: int = 0) -bool):
    #         """
    #         NBC-compatible memory deallocation

    #         Args:
    #             address: Memory address to free
    #             size: Size of memory (optional, for optimization)

    #         Returns:
    #             True if successful, False otherwise
    #         """
    start_time = time.time()

    #         try:
    #             # Remove from NBC objects tracking
    #             with self._lock:
    #                 if address in self.nbc_objects:
    object_info = self.nbc_objects[address]
    actual_size = object_info["size"]
    #                     del self.nbc_objects[address]
    self.allocator_stats.nbc_memory_usage - = actual_size
    self.allocator_stats.nbc_frees + = 1
    #                 else:
    #                     # Object not tracked, but still try to free
    actual_size = size

    #             # Free memory using adaptive manager
    success = self.memory_manager.free(address, actual_size)

    #             # Update integration overhead
    #             if success:
    overhead = time.time() - start_time
    self.allocator_stats.integration_overhead = (
                        (self.allocator_stats.integration_overhead * 0.9 + overhead * 0.1)
    #                 )

    #             return success

    #         except Exception as e:
                logger.error(f"NBC free error: {e}")
    #             return False

    #     def nbc_reallocate(self, old_address: int, new_size: int,
    alignment: int = 8) - Optional[int]):
    #         """
    #         NBC-compatible memory reallocation

    #         Args:
    #             old_address: Existing memory address
    #             new_size: New size for reallocation
    #             alignment: Memory alignment requirement

    #         Returns:
    #             New memory address or None if failed
    #         """
    #         try:
    #             # Get old object info
    #             with self._lock:
    #                 if old_address not in self.nbc_objects:
    #                     return None

    old_info = self.nbc_objects[old_address]
    old_size = old_info["size"]
    object_type = old_info["object_type"]
    bytecode_context = old_info["bytecode_context"]

    #             # Allocate new memory
    new_address = self.nbc_allocate(
    size = new_size,
    alignment = alignment,
    object_type = object_type,
    bytecode_context = bytecode_context
    #             )

    #             if new_address is not None:
    #                 # Copy data if old address was valid
    #                 if old_address != 0:
    #                     # This would copy data from old to new address
    #                     # For now, just free the old address
                        self.nbc_free(old_address, old_size)

    #                 return new_address

    #             return None

    #         except Exception as e:
                logger.error(f"NBC reallocation error: {e}")
    #             return None

    #     def nbc_get_object_info(self, address: int) -Optional[Dict[str, Any]]):
    #         """
    #         Get information about NBC object at given address

    #         Args:
    #             address: Memory address

    #         Returns:
    #             Object information or None if not found
    #         """
    #         with self._lock:
                return self.nbc_objects.get(address)

    #     def nbc_get_memory_stats(self) -NBCMemoryStats):
    #         """
    #         Get NBC-specific memory statistics

    #         Returns:
    #             NBC memory statistics
    #         """
    #         with self._lock:
    #             # Create a copy to avoid race conditions
    stats = NBCMemoryStats(
    nbc_allocations = self.allocator_stats.nbc_allocations,
    nbc_frees = self.allocator_stats.nbc_frees,
    nbc_sheaf_hits = self.allocator_stats.nbc_sheaf_hits,
    nbc_barn_hits = self.allocator_stats.nbc_barn_hits,
    nbc_fallback_allocations = self.allocator_stats.nbc_fallback_allocations,
    average_nbc_allocation_time = self.allocator_stats.average_nbc_allocation_time,
    nbc_memory_usage = self.allocator_stats.nbc_memory_usage,
    nbc_gc_interactions = self.allocator_stats.nbc_gc_interactions,
    integration_overhead = self.allocator_stats.integration_overhead,
    compatibility_mode = self.allocator_stats.compatibility_mode,
    last_integration_check = self.allocator_stats.last_integration_check
    #             )
    #             return stats

    #     def nbc_register_actor(self, actor_id: str, actor_config: Dict[str, Any] = None):
    #         """
    #         Register an NBC actor with the adaptive memory system

    #         Args:
    #             actor_id: Unique actor identifier
    #             actor_config: Actor-specific memory configuration
    #         """
    #         try:
    #             # Register with memory manager
                self.memory_manager.register_actor(actor_id)

    #             # Register with sizing manager
                self.sizing_manager.register_actor(actor_id, actor_config)

    #             logger.debug(f"Registered NBC actor {actor_id} with adaptive memory system")

    #         except Exception as e:
                logger.error(f"Failed to register NBC actor {actor_id}: {e}")

    #     def nbc_unregister_actor(self, actor_id: str):
    #         """
    #         Unregister an NBC actor from the adaptive memory system

    #         Args:
    #             actor_id: Unique actor identifier
    #         """
    #         try:
    #             # Unregister from memory manager
                self.memory_manager.unregister_actor(actor_id)

    #             # Unregister from sizing manager
                self.sizing_manager.unregister_actor(actor_id)

                logger.debug(f"Unregistered NBC actor {actor_id} from adaptive memory system")

    #         except Exception as e:
                logger.error(f"Failed to unregister NBC actor {actor_id}: {e}")

    #     def nbc_get_system_insights(self) -Dict[str, Any]):
    #         """
    #         Get comprehensive system insights for NBC runtime

    #         Returns:
    #             System insights dictionary
    #         """
    #         try:
    #             # Get memory manager stats
    memory_stats = self.memory_manager.get_stats()

    #             # Get context analysis
    context_analysis = self.context_detector.get_current_analysis()

    #             # Get sizing insights
    sizing_insights = self.sizing_manager.global_engine.get_sizing_insights()

    #             # Get NBC-specific stats
    nbc_stats = self.nbc_get_memory_stats()

    #             return {
    #                 "memory_manager": {
    #                     "total_allocations": memory_stats.total_allocations,
    #                     "sheaf_hits": memory_stats.sheaf_hits,
    #                     "sheaf_misses": memory_stats.sheaf_misses,
    #                     "barn_hits": memory_stats.barn_hits,
    #                     "barn_misses": memory_stats.barn_misses,
    #                     "fallback_allocations": memory_stats.fallback_allocations,
    #                     "average_allocation_time": memory_stats.average_allocation_time,
    #                     "current_memory_usage": memory_stats.current_memory_usage,
    #                     "peak_memory_usage": memory_stats.peak_memory_usage
    #                 },
    #                 "context_analysis": {
    #                     "system_state": context_analysis.system_state.value,
    #                     "workload_pattern": context_analysis.workload.pattern.value,
    #                     "is_distributed": context_analysis.is_distributed,
    #                     "node_count": context_analysis.node_count,
    #                     "actor_count": context_analysis.actor_count,
    #                     "load_factor": context_analysis.load_factor,
    #                     "memory_pressure": context_analysis.memory_pressure,
    #                     "recommended_strategy": context_analysis.recommended_strategy,
    #                     "confidence": context_analysis.confidence
    #                 },
    #                 "sizing_insights": sizing_insights,
    #                 "nbc_stats": {
    #                     "nbc_allocations": nbc_stats.nbc_allocations,
    #                     "nbc_frees": nbc_stats.nbc_frees,
    #                     "nbc_memory_usage": nbc_stats.nbc_memory_usage,
    #                     "average_nbc_allocation_time": nbc_stats.average_nbc_allocation_time,
    #                     "integration_overhead": nbc_stats.integration_overhead,
    #                     "compatibility_mode": nbc_stats.compatibility_mode
    #                 },
                    "performance_recommendations": self._generate_performance_recommendations()
    #             }

    #         except Exception as e:
                logger.error(f"Failed to get system insights: {e}")
                return {"error": str(e)}

    #     def _generate_performance_recommendations(self) -List[str]):
    #         """Generate performance recommendations based on current state"""
    recommendations = []

    #         try:
    #             # Get current stats
    memory_stats = self.memory_manager.get_stats()
    context_analysis = self.context_detector.get_current_analysis()

    #             # Analyze hit rates
    total_allocations = memory_stats.total_allocations
    #             if total_allocations 0):
    sheaf_hit_rate = math.divide(memory_stats.sheaf_hits, total_allocations)
    barn_hit_rate = math.divide(memory_stats.barn_hits, total_allocations)

    #                 if sheaf_hit_rate < 0.5:
    #                     recommendations.append("Consider increasing sheaf size for better hit rates")

    #                 if barn_hit_rate < 0.3 and context_analysis.is_distributed:
                        recommendations.append("Barn utilization is low - check network latency")

    #             # Analyze allocation time
    #             if memory_stats.average_allocation_time 0.01):  # 10ms
                    recommendations.append("Allocation time is high - consider batching or larger sheaves")

    #             # Analyze memory pressure
    #             if context_analysis.memory_pressure 0.8):
                    recommendations.append("High memory pressure - consider reducing sheaf sizes")

    #             # Analyze GC interactions
    #             if memory_stats.gc_pressure 0.7):
                    recommendations.append("High GC pressure - consider more aggressive sheaf cleanup")

    #         except Exception as e:
                logger.error(f"Error generating recommendations: {e}")

    #         return recommendations

    #     def nbc_set_integration_mode(self, active: bool):
    #         """
    #         Enable or disable adaptive memory integration

    #         Args:
    #             active: True to enable integration, False to disable
    #         """
    self._integration_active = active
    self.allocator_stats.compatibility_mode = not active

    #         if active:
                logger.info("NBC adaptive memory integration enabled")
    #         else:
                logger.info("NBC adaptive memory integration disabled - using fallback mode")

    #     def cleanup(self):
    #         """Clean up NBC memory integration resources"""
    #         try:
    #             # Clean up sizing manager
                self.sizing_manager.cleanup()

    #             # Clean up memory manager
                self.memory_manager.cleanup()

    #             # Clear NBC objects
    #             with self._lock:
                    self.nbc_objects.clear()

                logger.info("NBC memory integration cleaned up")

    #         except Exception as e:
                logger.error(f"Error cleaning up NBC memory integration: {e}")


# Global NBC memory allocator instance
_nbc_allocator: Optional[NBCMemoryAllocator] = None
_allocator_lock = threading.RLock()


def get_nbc_allocator() -NBCMemoryAllocator):
#     """Get the global NBC memory allocator instance"""
#     global _nbc_allocator
#     with _allocator_lock:
#         if _nbc_allocator is None:
_nbc_allocator = NBCMemoryAllocator()
#         return _nbc_allocator


def init_nbc_memory_allocator(config: AdaptiveConfig = None) -NBCMemoryAllocator):
#     """Initialize the global NBC memory allocator"""
#     global _nbc_allocator
#     with _allocator_lock:
_nbc_allocator = NBCMemoryAllocator(config)
#         return _nbc_allocator


function cleanup_nbc_memory_allocator()
    #     """Clean up the global NBC memory allocator"""
    #     global _nbc_allocator
    #     with _allocator_lock:
    #         if _nbc_allocator is not None:
                _nbc_allocator.cleanup()
    _nbc_allocator = None


# NBC-compatible allocation functions
def nbc_allocate(size: int, alignment: int = 8, object_type: str = "nbc_object",
priority: int = 0 - bytecode_context: Dict[str, Any] = None, Optional[int]):)
#     """
#     NBC-compatible memory allocation function

#     Args:
#         size: Size of memory to allocate
#         alignment: Memory alignment requirement
#         object_type: Type of NBC object being allocated
#         priority: Allocation priority
#         bytecode_context: Context from bytecode execution

#     Returns:
#         Memory address or None if allocation failed
#     """
allocator = get_nbc_allocator()
    return allocator.nbc_allocate(size, alignment, object_type, priority, bytecode_context)


def nbc_free(address: int, size: int = 0) -bool):
#     """
#     NBC-compatible memory deallocation function

#     Args:
#         address: Memory address to free
        size: Size of memory (optional)

#     Returns:
#         True if successful, False otherwise
#     """
allocator = get_nbc_allocator()
    return allocator.nbc_free(address, size)


def nbc_reallocate(old_address: int, new_size: int, alignment: int = 8) -Optional[int]):
#     """
#     NBC-compatible memory reallocation function

#     Args:
#         old_address: Existing memory address
#         new_size: New size for reallocation
#         alignment: Memory alignment requirement

#     Returns:
#         New memory address or None if failed
#     """
allocator = get_nbc_allocator()
    return allocator.nbc_reallocate(old_address, new_size, alignment)


def nbc_get_memory_stats() -NBCMemoryStats):
#     """
#     Get NBC memory statistics

#     Returns:
#         NBC memory statistics
#     """
allocator = get_nbc_allocator()
    return allocator.nbc_get_memory_stats()


def nbc_get_system_insights() -Dict[str, Any]):
#     """
#     Get comprehensive system insights

#     Returns:
#         System insights dictionary
#     """
allocator = get_nbc_allocator()
    return allocator.nbc_get_system_insights()
