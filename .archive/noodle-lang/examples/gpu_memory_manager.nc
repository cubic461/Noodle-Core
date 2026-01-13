# Converted from Python to NoodleCore
# Original file: src

# """
# GPU Memory Manager for NBC Runtime

# This module provides GPU memory management for CuPy operations,
# including memory pooling, tracking, and automatic cleanup.
# """

import gc
import logging
import threading
import time
import weakref
from dataclasses import dataclass
import enum.Enum
import typing.Any

logger = logging.getLogger(__name__)

try
    #     import cupy as cp

    CUPY_AVAILABLE = True
except ImportError
    CUPY_AVAILABLE = False
        logger.warning("CuPy not available. GPU memory management disabled.")


class GPUMemoryState(Enum)
    #     """GPU memory allocation states."""

    FREE = "free"
    ALLOCATED = "allocated"
    POOLED = "pooled"
    CLEANUP_PENDING = "cleanup_pending"


dataclass
class GPUMemoryAllocation
    #     """Track GPU memory allocation."""

    #     size: int
    ptr: Optional[int] = None
    state: GPUMemoryState = GPUMemoryState.FREE
    allocation_time: float = field(default_factory=time.time)
    last_access_time: float = field(default_factory=time.time)
    access_count: int = 0


class GPUMemoryPool
    #     """Pool for GPU memory allocations."""

    #     def __init__(self, pool_size: int = 1024**3):  # 1GB default
    self.pool_size = pool_size
    self.allocated_size = 0
    self.allocations: Dict[int, GPUMemoryAllocation] = {}
    self.free_list: List[int] = []
    self._lock = threading.RLock()

    #     def allocate(self, size: int) -Optional[int]):
    #         """Allocate memory from pool."""
    #         with self._lock:
    #             # Try to find suitable free allocation
    #             for i, ptr in enumerate(self.free_list):
    allocation = self.allocations.get(ptr)
    #                 if allocation and allocation.size >= size:
                        self.free_list.pop(i)
    allocation.state = GPUMemoryState.ALLOCATED
    allocation.last_access_time = time.time()
    allocation.access_count + = 1
    #                     return ptr

    #             # Check if we can allocate new memory
    #             if self.allocated_size + size <= self.pool_size:
    ptr = self._allocate_raw(size)
    #                 if ptr:
    self.allocations[ptr] = GPUMemoryAllocation(
    size = size, ptr=ptr, state=GPUMemoryState.ALLOCATED
    #                     )
    self.allocated_size + = size
    #                     return ptr

    #             return None

    #     def deallocate(self, ptr: int) -bool):
    #         """Return allocation to pool."""
    #         with self._lock:
    allocation = self.allocations.get(ptr)
    #             if allocation and allocation.state == GPUMemoryState.ALLOCATED:
    allocation.state = GPUMemoryState.POOLED
                    self.free_list.append(ptr)
    #                 return True
    #             return False

    #     def _allocate_raw(self, size: int) -Optional[int]):
    #         """Allocate raw GPU memory."""
    #         if not CUPY_AVAILABLE:
    #             return None

    #         try:
    #             # Use CuPy's memory pool
    #             with cp.cuda.Device():
    mem = cp.cuda.alloc(size)
    #                 return mem.ptr
    #         except Exception as e:
                logger.error(f"Failed to allocate GPU memory: {e}")
    #             return None


class GPUMemoryManager
    #     """Main GPU memory manager."""

    #     def __init__(
    #         self,
    device_id: int = 0,
    memory_limit: Optional[int] = None,
    enable_pooling: bool = True,
    cleanup_threshold: float = 0.9,
    #     ):
    self.device_id = device_id
    self.memory_limit = memory_limit or self._get_default_memory_limit()
    self.enable_pooling = enable_pooling
    self.cleanup_threshold = cleanup_threshold

    self.allocated_memory = 0
    self.peak_memory_usage = 0
    self.allocations: Dict[int, GPUMemoryAllocation] = {}
    self.pools: Dict[str, GPUMemoryPool] = {}
    self._lock = threading.RLock()
    self._cleanup_thread = None
    self._stop_cleanup = threading.Event()

    #         if CUPY_AVAILABLE:
                self._initialize_device()
    #             if enable_pooling:
                    self._initialize_pools()
                self._start_cleanup_thread()

    #     def _get_default_memory_limit(self) -int):
    #         """Get default GPU memory limit."""
    #         if not CUPY_AVAILABLE:
    #             return 0

    #         try:
    #             with cp.cuda.Device(self.device_id):
    mem_info = cp.cuda.runtime.memGetInfo()
                    return int(mem_info[0] * 0.8)  # Use 80% of available memory
    #         except Exception as e:
                logger.error(f"Failed to get GPU memory info: {e}")
    #             return 8 * 1024**3  # 8GB fallback

    #     def _initialize_device(self):
    #         """Initialize GPU device."""
    #         try:
    #             with cp.cuda.Device(self.device_id):
    #                 # Set memory pool configuration
                    cp.cuda.set_allocator(cp.cuda.MemoryPool().malloc)
                    logger.info(f"Initialized GPU device {self.device_id}")
    #         except Exception as e:
                logger.error(f"Failed to initialize GPU device {self.device_id}: {e}")

    #     def _initialize_pools(self):
    #         """Initialize memory pools for different allocation sizes."""
            # Small allocations (up to 64MB)
    self.pools["small"] = GPUMemoryPool(pool_size=512 * 1024**2)

            # Medium allocations (64MB - 512MB)
    self.pools["medium"] = GPUMemoryPool(pool_size=1024 * *3)

            # Large allocations (512MB+)
    self.pools["large"] = GPUMemoryPool(pool_size=2 * 1024**3)

    #     def _start_cleanup_thread(self):
    #         """Start background cleanup thread."""
    self._cleanup_thread = threading.Thread(
    target = self._cleanup_worker, daemon=True
    #         )
            self._cleanup_thread.start()

    #     def _cleanup_worker(self):
    #         """Background worker for memory cleanup."""
    #         while not self._stop_cleanup.is_set():
    #             try:
    #                 if self.allocated_memory self.memory_limit * self.cleanup_threshold):
                        self._perform_cleanup()
                    time.sleep(5)  # Check every 5 seconds
    #             except Exception as e:
                    logger.error(f"Error in cleanup worker: {e}")

    #     def _perform_cleanup(self):
    #         """Perform memory cleanup."""
    #         with self._lock:
    #             # Clean up old allocations
    current_time = time.time()
    to_remove = []

    #             for ptr, allocation in self.allocations.items():
    #                 if (
    allocation.state == GPUMemoryState.POOLED
    #                     and current_time - allocation.last_access_time 60
    #                 )):  # 1 minute timeout
                        to_remove.append(ptr)

    #             for ptr in to_remove:
                    self._free_allocation(ptr)

    #             # Force CuPy garbage collection
    #             if CUPY_AVAILABLE:
                    cp.get_default_memory_pool().free_all_blocks()
                    cp.get_default_pinned_memory_pool().free_all_blocks()

                gc.collect()

                logger.info(
                    f"Cleaned up {len(to_remove)} allocations. "
    #                 f"Memory usage: {self.allocated_memory / 1024**3:.2f}GB"
    #             )

    #     def allocate(self, size: int, pool_hint: Optional[str] = None) -Optional[int]):
    #         """Allocate GPU memory."""
    #         with self._lock:
    #             # Check memory limit
    #             if self.allocated_memory + size self.memory_limit):
                    self._perform_cleanup()
    #                 if self.allocated_memory + size self.memory_limit):
                        logger.warning(
    #                         f"GPU memory limit exceeded. "
    #                         f"Requested: {size / 1024**3:.2f}GB, "
                            f"Available: {(self.memory_limit - self.allocated_memory) / 1024**3:.2f}GB"
    #                     )
    #                     return None

    #             # Try pool allocation first
    #             if self.enable_pooling and pool_hint:
    pool = self.pools.get(pool_hint)
    #                 if pool:
    ptr = pool.allocate(size)
    #                     if ptr:
    self.allocations[ptr] = GPUMemoryAllocation(
    size = size, ptr=ptr, state=GPUMemoryState.ALLOCATED
    #                         )
    self.allocated_memory + = size
    self.peak_memory_usage = max(
    #                             self.peak_memory_usage, self.allocated_memory
    #                         )
    #                         return ptr

    #             # Direct allocation
    ptr = self._allocate_raw(size)
    #             if ptr:
    self.allocations[ptr] = GPUMemoryAllocation(
    size = size, ptr=ptr, state=GPUMemoryState.ALLOCATED
    #                 )
    self.allocated_memory + = size
    self.peak_memory_usage = max(
    #                     self.peak_memory_usage, self.allocated_memory
    #                 )
    #                 return ptr

    #             return None

    #     def _allocate_raw(self, size: int) -Optional[int]):
    #         """Allocate raw GPU memory."""
    #         if not CUPY_AVAILABLE:
    #             return None

    #         try:
    #             with cp.cuda.Device(self.device_id):
    mem = cp.cuda.alloc(size)
    #                 return mem.ptr
    #         except Exception as e:
                logger.error(f"Failed to allocate {size / 1024**3:.2f}GB GPU memory: {e}")
    #             return None

    #     def deallocate(self, ptr: int, return_to_pool: bool = True) -bool):
    #         """Deallocate GPU memory."""
    #         with self._lock:
    allocation = self.allocations.get(ptr)
    #             if not allocation:
    #                 return False

    #             if allocation.state != GPUMemoryState.ALLOCATED:
    #                 return False

    #             # Return to pool or free
    #             if self.enable_pooling and return_to_pool:
    #                 # Find appropriate pool
    pool_hint = self._get_pool_hint(allocation.size)
    pool = self.pools.get(pool_hint)
    #                 if pool and pool.deallocate(ptr):
    allocation.state = GPUMemoryState.POOLED
    self.allocated_memory - = allocation.size
    #                     return True

    #             # Free allocation
                return self._free_allocation(ptr)

    #     def _get_pool_hint(self, size: int) -str):
    #         """Get pool hint based on allocation size."""
    #         if size <= 64 * 1024**2:  # 64MB
    #             return "small"
    #         elif size <= 512 * 1024**2:  # 512MB
    #             return "medium"
    #         else:
    #             return "large"

    #     def _free_allocation(self, ptr: int) -bool):
    #         """Free GPU memory allocation."""
    allocation = self.allocations.get(ptr)
    #         if not allocation:
    #             return False

    #         try:
    #             if CUPY_AVAILABLE and allocation.ptr:
    #                 # Free CuPy memory
    mem = cp.cuda.MemoryPointer(
                        cp.cuda.UnownedMemory(allocation.ptr, allocation.size, None), 0
    #                 )
                    mem.mem.free()

    self.allocated_memory - = allocation.size
    #             del self.allocations[ptr]
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to free GPU memory: {e}")
    #             return False

    #     def get_memory_stats(self) -Dict[str, Any]):
    #         """Get memory usage statistics."""
    #         with self._lock:
    #             return {
    #                 "device_id": self.device_id,
    #                 "allocated_memory": self.allocated_memory,
    #                 "peak_memory_usage": self.peak_memory_usage,
    #                 "memory_limit": self.memory_limit,
                    "utilization": (
    #                     self.allocated_memory / self.memory_limit
    #                     if self.memory_limit 0
    #                     else 0
    #                 ),
                    "active_allocations"): len(
    #                     [
    #                         a
    #                         for a in self.allocations.values()
    #                         if a.state == GPUMemoryState.ALLOCATED
    #                     ]
    #                 ),
                    "pooled_allocations": len(
    #                     [
    #                         a
    #                         for a in self.allocations.values()
    #                         if a.state == GPUMemoryState.POOLED
    #                     ]
    #                 ),
    #                 "pool_stats": {
    #                     name: {
    #                         "allocated_size": pool.allocated_size,
    #                         "pool_size": pool.pool_size,
                            "free_allocations": len(pool.free_list),
    #                     }
    #                     for name, pool in self.pools.items()
    #                 },
    #             }

    #     def cleanup(self):
    #         """Perform full cleanup."""
    #         with self._lock:
                self._stop_cleanup.set()
    #             if self._cleanup_thread:
    self._cleanup_thread.join(timeout = 5)

    #             # Free all allocations
    #             for ptr in list(self.allocations.keys()):
                    self._free_allocation(ptr)

    #             # Clear pools
                self.pools.clear()

    #             # Final CuPy cleanup
    #             if CUPY_AVAILABLE:
                    cp.get_default_memory_pool().free_all_blocks()
                    cp.get_default_pinned_memory_pool().free_all_blocks()

                logger.info("GPU memory cleanup completed")


# Global GPU memory manager instance
_global_gpu_memory_manager: Optional[GPUMemoryManager] = None
_manager_lock = threading.Lock()


def get_gpu_memory_manager(device_id: int = 0, **kwargs) -GPUMemoryManager):
#     """Get global GPU memory manager instance."""
#     global _global_gpu_memory_manager

#     with _manager_lock:
#         if _global_gpu_memory_manager is None:
_global_gpu_memory_manager = GPUMemoryManager(device_id=device_id * , *kwargs)

#         return _global_gpu_memory_manager


def allocate_gpu_memory(size: int, device_id: int = 0, **kwargs) -Optional[int]):
#     """Convenience function to allocate GPU memory."""
manager = get_gpu_memory_manager(device_id=device_id)
    return manager.allocate(size, **kwargs)


def deallocate_gpu_memory(ptr: int, device_id: int = 0, **kwargs) -bool):
#     """Convenience function to deallocate GPU memory."""
manager = get_gpu_memory_manager(device_id=device_id)
    return manager.deallocate(ptr, **kwargs)


def get_gpu_memory_stats(device_id: int = 0) -Dict[str, Any]):
#     """Get GPU memory statistics."""
manager = get_gpu_memory_manager(device_id=device_id)
    return manager.get_memory_stats()
