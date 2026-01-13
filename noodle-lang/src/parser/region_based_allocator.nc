# Converted from Python to NoodleCore
# Original file: src

# """
# Region-Based Allocator for Mathematical Objects

# This module provides a region-based memory allocation system for mathematical objects
# that improves performance and reduces memory fragmentation through contiguous memory regions.
# """

import abc
import logging
import math
import threading
import time
import weakref
import collections.defaultdict
import contextlib.contextmanager
from dataclasses import dataclass
import enum.Enum
import typing.Any

import psutil

import .nbc_runtime.core.resource_manager.(
#     ResourceHandle,
#     ResourceManager,
#     ResourceType,
# )
import .nbc_runtime.math.objects.(
#     MathematicalObject,
#     Matrix,
#     ObjectType,
#     Scalar,
#     Vector,
# )

logger = logging.getLogger(__name__)


class RegionType(Enum)
    #     """Types of memory regions."""

    SMALL = "small"  # Objects < 1KB
    MEDIUM = "medium"  # Objects 1KB - 10KB
    LARGE = "large"  # Objects 10KB - 1MB
    HUGE = "huge"  # Objects 1MB


class RegionStatus(Enum)
    #     """Status of memory regions."""

    EMPTY = "empty"
    PARTIAL = "partial"
    FULL = "full"
    DEALLOCATING = "deallocating"


dataclass
class MemoryRegion
    #     """Represents a contiguous memory region."""

    #     region_id): str
    #     region_type: RegionType
    #     size: int
    #     base_address: int
    objects: Dict[str, MathematicalObject] = field(default_factory=dict)
    status: RegionStatus = RegionStatus.EMPTY
    created_at: float = field(default_factory=time.time)
    last_accessed: float = field(default_factory=time.time)
    access_count: int = 0
    fragmentation_ratio: float = 0.0

    #     def update_access(self):
    #         """Update last access time and access count."""
    self.last_accessed = time.time()
    self.access_count + = 1

    #     def get_used_memory(self) -int):
    #         """Get used memory in bytes."""
    #         return sum(obj.get_memory_usage() for obj in self.objects.values())

    #     def get_free_memory(self) -int):
    #         """Get free memory in bytes."""
            return self.size - self.get_used_memory()

    #     def get_utilization(self) -float):
            """Get utilization ratio (0.0 to 1.0)."""
    #         return self.get_used_memory() / self.size if self.size 0 else 0.0

    #     def update_fragmentation(self)):
    #         """Update fragmentation ratio."""
    #         if len(self.objects) <= 1:
    self.fragmentation_ratio = 0.0
    #             return

    #         # Calculate fragmentation based on gap sizes between objects
    addresses = sorted(
    #             [
                    obj.get_memory_address()
    #                 for obj in self.objects.values()
    #                 if hasattr(obj, "get_memory_address")
    #             ]
    #         )
    #         if len(addresses) < 2:
    self.fragmentation_ratio = 0.0
    #             return

    gaps = []
    #         for i in range(1, len(addresses)):
    gap = (
    #                 addresses[i]
    #                 - addresses[i - 1]
                    - getattr(self.objects[addresses[i - 1]], "size", 0)
    #             )
    #             if gap 0):
                    gaps.append(gap)

    #         if gaps:
    avg_gap = math.divide(sum(gaps), len(gaps))
    self.fragmentation_ratio = math.divide(min(avg_gap, self.size, 1.0))
    #         else:
    self.fragmentation_ratio = 0.0


dataclass
class AllocationStats
    #     """Statistics for allocation operations."""

    total_allocations: int = 0
    total_deallocations: int = 0
    successful_allocations: int = 0
    failed_allocations: int = 0
    average_allocation_time: float = 0.0
    total_allocated_memory: int = 0
    peak_memory_usage: int = 0
    current_memory_usage: int = 0
    regions_created: int = 0
    regions_destroyed: int = 0
    fragmentation_ratio: float = 0.0

    #     def update_allocation(self, success: bool, size: int, allocation_time: float):
    #         """Update allocation statistics."""
    self.total_allocations + = 1
    #         if success:
    self.successful_allocations + = 1
    self.total_allocated_memory + = size
    #         else:
    self.failed_allocations + = 1

    #         # Update average allocation time
    #         if self.total_allocations 1):
    self.average_allocation_time = (
                    self.average_allocation_time * (self.total_allocations - 1)
    #                 + allocation_time
    #             ) / self.total_allocations
    #         else:
    self.average_allocation_time = allocation_time

    #     def update_deallocation(self, size: int):
    #         """Update deallocation statistics."""
    self.total_deallocations + = 1
    self.total_allocated_memory = max(0 - self.total_allocated_memory, size)

    #     def update_memory_usage(self, current_usage: int):
    #         """Update memory usage statistics."""
    self.current_memory_usage = current_usage
    #         if current_usage self.peak_memory_usage):
    self.peak_memory_usage = current_usage


class RegionBasedAllocator(abc.ABC)
    #     """
    #     Abstract base class for region-based allocators.

    #     This class provides the core interface for region-based memory allocation
    #     of mathematical objects with different region types and sizes.
    #     """

    #     def __init__(
    #         self,
    max_small_regions: int = 100,
    max_medium_regions: int = 50,
    max_large_regions: int = 20,
    max_huge_regions: int = 5,
    region_sizes: Optional[Dict[RegionType, int]] = None,
    cleanup_interval: int = 300,
    #     ):""
    #         Initialize region-based allocator.

    #         Args:
    #             max_small_regions: Maximum number of small regions
    #             max_medium_regions: Maximum number of medium regions
    #             max_large_regions: Maximum number of large regions
    #             max_huge_regions: Maximum number of huge regions
    #             region_sizes: Custom region sizes for each type
    #             cleanup_interval: Cleanup interval in seconds
    #         """
    self.max_regions = {
    #             RegionType.SMALL: max_small_regions,
    #             RegionType.MEDIUM: max_medium_regions,
    #             RegionType.LARGE: max_large_regions,
    #             RegionType.HUGE: max_huge_regions,
    #         }

    #         # Default region sizes
    self.default_region_sizes = {
    #             RegionType.SMALL: 1024,  # 1KB
    #             RegionType.MEDIUM: 10 * 1024,  # 10KB
    #             RegionType.LARGE: 1024 * 1024,  # 1MB
    #             RegionType.HUGE: 10 * 1024 * 1024,  # 10MB
    #         }

    self.region_sizes = region_sizes or self.default_region_sizes
    self.cleanup_interval = cleanup_interval

    #         # Region management
    self.regions: Dict[RegionType, List[MemoryRegion]] = {
    #             RegionType.SMALL: [],
    #             RegionType.MEDIUM: [],
    #             RegionType.LARGE: [],
    #             RegionType.HUGE: [],
    #         }

    #         # Object to region mapping
    self.object_to_region: Dict[int, Tuple[str, RegionType]] = {}

    #         # Statistics
    self.stats = AllocationStats()

    #         # Threading
    self._lock = threading.RLock()
    self._cleanup_thread = None
    self._stop_cleanup = False

    #         # Start cleanup thread
            self._start_cleanup_thread()

            logger.info(
    #             f"RegionBasedAllocator initialized with region limits: "
    f"small = {max_small_regions}, medium={max_medium_regions}, "
    f"large = {max_large_regions}, huge={max_huge_regions}"
    #         )

    #     def _start_cleanup_thread(self):
    #         """Start background cleanup thread."""

    #         def cleanup_worker():
    #             while not self._stop_cleanup:
                    time.sleep(self.cleanup_interval)
                    self._cleanup_regions()

    self._cleanup_thread = threading.Thread(target=cleanup_worker, daemon=True)
            self._cleanup_thread.start()
            logger.debug("Region cleanup thread started")

    #     def _cleanup_regions(self):
    #         """Clean up unused regions."""
    #         with self._lock:
    current_time = time.time()

    #             for region_type, region_list in self.regions.items():
    regions_to_remove = []

    #                 for region in region_list:
    #                     # Check if region is unused (not accessed for 10 minutes)
    time_diff = current_time - region.last_accessed
    #                     if (
    #                         time_diff 600  # 10 minutes
    and region.status == RegionStatus.EMPTY
    and len(region.objects) = = 0
    #                     )):
                            regions_to_remove.append(region)

    #                 # Remove unused regions
    #                 for region in regions_to_remove:
                        self._destroy_region(region)
                        logger.debug(
    #                         f"Cleaned up {region_type.value} region: {region.region_id}"
    #                     )

    #     def _destroy_region(self, region: MemoryRegion):
    #         """Destroy a memory region."""
    region_type = self._get_region_type_for_size(region.size)

    #         # Remove from regions list
    #         if region in self.regions[region_type]:
                self.regions[region_type].remove(region)

    #         # Remove objects from mapping
    #         for obj_id in list(region.objects.keys()):
    #             if obj_id in self.object_to_region:
    #                 del self.object_to_region[obj_id]

    #         # Update statistics
    self.stats.regions_destroyed + = 1
            self.stats.update_memory_usage(self.get_total_memory_usage())

    #     def _get_region_type_for_size(self, size: int) -RegionType):
    #         """Determine region type for a given size."""
    #         if size < 1024:  # 1KB
    #             return RegionType.SMALL
    #         elif size < 10 * 1024:  # 10KB
    #             return RegionType.MEDIUM
    #         elif size < 1024 * 1024:  # 1MB
    #             return RegionType.LARGE
    #         else:
    #             return RegionType.HUGE

    #     def _find_suitable_region(
    #         self, size: int, region_type: RegionType
    #     ) -Optional[MemoryRegion]):
    #         """Find a suitable region for allocation."""
    #         # Try to find a region with enough free space
    #         for region in self.regions[region_type]:
    #             if region.get_free_memory() >= size and region.status != RegionStatus.FULL:
    #                 return region

    #         # Create new region if under limit
    #         if len(self.regions[region_type]) < self.max_regions[region_type]:
                return self._create_region(region_type)

    #         return None

    #     def _create_region(self, region_type: RegionType) -MemoryRegion):
    #         """Create a new memory region."""
    region_id = (
                f"{region_type.value}_{int(time.time())}_{len(self.regions[region_type])}"
    #         )
    size = self.region_sizes[region_type]
    base_address = id(self) + hash(region_id  # Simple address generation)

    region = MemoryRegion(
    region_id = region_id,
    region_type = region_type,
    size = size,
    base_address = base_address,
    #         )

            self.regions[region_type].append(region)
    self.stats.regions_created + = 1

            logger.debug(f"Created new {region_type.value} region: {region_id}")
    #         return region

    #     def allocate_object(self, obj: MathematicalObject) -Optional[str]):
    #         """
    #         Allocate a mathematical object in a suitable region.

    #         Args:
    #             obj: Mathematical object to allocate

    #         Returns:
    #             Object ID if successful, None otherwise
    #         """
    start_time = time.time()

    #         try:
    #             with self._lock:
    #                 # Get object size
    obj_size = obj.get_memory_usage()
    region_type = self._get_region_type_for_size(obj_size)

    #                 # Find suitable region
    region = self._find_suitable_region(obj_size, region_type)

    #                 if not region:
                        logger.warning(
    #                         f"No suitable region found for object of size {obj_size}"
    #                     )
                        self.stats.update_allocation(
                            False, obj_size, time.time() - start_time
    #                     )
    #                     return None

    #                 # Allocate object
    obj_id = f"obj_{id(obj)}_{int(time.time())}"
    region.objects[obj_id] = obj
    self.object_to_region[id(obj)] = (obj_id, region_type)

    #                 # Update region status
    #                 if region.get_utilization() >= 0.95:
    region.status = RegionStatus.FULL
    #                 elif region.get_utilization() 0.0):
    region.status = RegionStatus.PARTIAL
    #                 else:
    region.status = RegionStatus.EMPTY

                    region.update_access()
                    region.update_fragmentation()

    #                 # Update statistics
                    self.stats.update_allocation(True, obj_size, time.time() - start_time)
                    self.stats.update_memory_usage(self.get_total_memory_usage())

                    logger.debug(f"Allocated object {obj_id} in region {region.region_id}")
    #                 return obj_id

    #         except Exception as e:
                logger.error(f"Allocation failed: {e}")
                self.stats.update_allocation(False, obj_size, time.time() - start_time)
    #             return None

    #     def deallocate_object(self, obj_id: str) -bool):
    #         """
    #         Deallocate a mathematical object.

    #         Args:
    #             obj_id: Object ID to deallocate

    #         Returns:
    #             True if successful, False otherwise
    #         """
    start_time = time.time()

    #         try:
    #             with self._lock:
    #                 # Find object in regions
    found = False
    #                 for region_type, region_list in self.regions.items():
    #                     for region in region_list:
    #                         if obj_id in region.objects:
    obj = region.objects[obj_id]
    obj_size = obj.get_memory_usage()

    #                             # Remove object
    #                             del region.objects[obj_id]
    #                             if id(obj) in self.object_to_region:
                                    del self.object_to_region[id(obj)]

    #                             # Update region status
    #                             if len(region.objects) == 0:
    region.status = RegionStatus.EMPTY
    #                             elif region.get_utilization() < 0.95:
    region.status = RegionStatus.PARTIAL

                                region.update_access()
                                region.update_fragmentation()

    #                             # Update statistics
                                self.stats.update_deallocation(obj_size)
                                self.stats.update_memory_usage(
                                    self.get_total_memory_usage()
    #                             )

    found = True
    #                             break

    #                     if found:
    #                         break

    #                 if not found:
                        logger.warning(f"Object {obj_id} not found in any region")
    #                     return False

                    logger.debug(f"Deallocated object {obj_id}")
    #                 return True

    #         except Exception as e:
                logger.error(f"Deallocation failed: {e}")
    #             return False

    #     def get_object_region(self, obj: MathematicalObject) -Optional[MemoryRegion]):
    #         """Get the region containing a specific object."""
    obj_id = id(obj)
    #         if obj_id not in self.object_to_region:
    #             return None

    region_id, region_type = self.object_to_region[obj_id]

    #         for region in self.regions[region_type]:
    #             if region.region_id == region_id:
    #                 return region

    #         return None

    #     def get_region_for_object(self, obj_id: str) -Optional[MemoryRegion]):
    #         """Get the region containing a specific object ID."""
    #         for region_list in self.regions.values():
    #             for region in region_list:
    #                 if obj_id in region.objects:
    #                     return region
    #         return None

    #     def get_total_memory_usage(self) -int):
    #         """Get total memory usage across all regions."""
    total = 0
    #         for region_list in self.regions.values():
    #             for region in region_list:
    total + = region.get_used_memory()
    #         return total

    #     def get_total_free_memory(self) -int):
    #         """Get total free memory across all regions."""
    total = 0
    #         for region_list in self.regions.values():
    #             for region in region_list:
    total + = region.get_free_memory()
    #         return total

    #     def get_fragmentation_ratio(self) -float):
    #         """Get overall fragmentation ratio."""
    #         if not any(self.regions.values()):
    #             return 0.0

    #         total_regions = sum(len(regions) for regions in self.regions.values())
    #         if total_regions = 0:
    #             return 0.0

    weighted_fragmentation = 0.0
    #         for region_list in self.regions.values():
    #             for region in region_list:
    weighted_fragmentation + = region.fragmentation_ratio * len(
    #                     region.objects
    #                 )

            return weighted_fragmentation / max(total_regions, 1)

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get comprehensive allocator statistics."""
    #         return {
    #             "total_regions": sum(len(regions) for regions in self.regions.values()),
    #             "regions_by_type": {
    #                 rt.value: len(regions) for rt, regions in self.regions.items()
    #             },
                "total_memory_usage": self.get_total_memory_usage(),
                "total_free_memory": self.get_total_free_memory(),
                "fragmentation_ratio": self.get_fragmentation_ratio(),
    #             "allocations": {
    #                 "total": self.stats.total_allocations,
    #                 "successful": self.stats.successful_allocations,
    #                 "failed": self.stats.failed_allocations,
                    "success_rate": (
    #                     self.stats.successful_allocations
                        / max(self.stats.total_allocations, 1)
    #                 )
    #                 * 100,
    #                 "average_time": self.stats.average_allocation_time,
    #             },
    #             "deallocations": self.stats.total_deallocations,
    #             "memory": {
    #                 "total_allocated": self.stats.total_allocated_memory,
    #                 "peak_usage": self.stats.peak_memory_usage,
    #                 "current_usage": self.stats.current_memory_usage,
    #             },
    #             "regions": {
    #                 "created": self.stats.regions_created,
    #                 "destroyed": self.stats.regions_destroyed,
    #             },
    #         }

    #     def cleanup_all_regions(self) -int):
    #         """Clean up all empty regions and return count of cleaned regions."""
    #         with self._lock:
    cleaned_count = 0

    #             for region_type, region_list in self.regions.items():
    regions_to_remove = [
    #                     region
    #                     for region in region_list
    #                     if region.status == RegionStatus.EMPTY and len(region.objects) == 0
    #                 ]

    #                 for region in regions_to_remove:
                        self._destroy_region(region)
    cleaned_count + = 1

                logger.info(f"Cleaned up {cleaned_count} empty regions")
    #             return cleaned_count

    #     def optimize_regions(self) -int):
    #         """Optimize regions by defragmenting and consolidating."""
    #         with self._lock:
    optimized_count = 0

    #             for region_list in self.regions.values():
    #                 for region in region_list:
    #                     if region.status == RegionStatus.PARTIAL:
    #                         # Simple defragmentation - sort objects by address
    #                         if hasattr(region, "objects") and region.objects:
    sorted_objects = sorted(
                                    region.objects.items(),
    key = lambda x: getattr(
    #                                     x[1], "get_memory_address", lambda: 0
                                    )(),
    #                             )
    region.objects = dict(sorted_objects)
                                region.update_fragmentation()
    optimized_count + = 1

                logger.info(f"Optimized {optimized_count} regions")
    #             return optimized_count

    #     def shutdown(self):
    #         """Shutdown the allocator and cleanup all resources."""
    self._stop_cleanup = True
    #         if self._cleanup_thread:
    self._cleanup_thread.join(timeout = 5)

            self.cleanup_all_regions()
            logger.info("RegionBasedAllocator shutdown complete")

    #     def __len__(self) -int):
    #         """Get total number of objects allocated."""
    count = 0
    #         for region_list in self.regions.values():
    #             for region in region_list:
    count + = len(region.objects)
    #         return count

    #     def __str__(self) -str):
    #         """String representation of allocator state."""
    stats = self.get_statistics()
            return (
    f"RegionBasedAllocator(regions = {stats['total_regions']}, "
    f"memory_usage = {stats['total_memory_usage']}B, "
    f"utilization = {(stats['total_memory_usage'] / max(stats['total_memory_usage'] + stats['total_free_memory'], 1)) * 100:.1f}%)"
    #         )


class MathematicalObjectRegionAllocator(RegionBasedAllocator)
    #     """
    #     Specialized region-based allocator for mathematical objects.

    #     This allocator extends the base region allocator with specific optimizations
    #     for mathematical objects and integration with the NBC runtime.
    #     """

    #     def __init__(
    #         self,
    max_small_regions: int = 100,
    max_medium_regions: int = 50,
    max_large_regions: int = 20,
    max_huge_regions: int = 5,
    region_sizes: Optional[Dict[RegionType, int]] = None,
    cleanup_interval: int = 300,
    enable_optimization: bool = True,
    #     ):""
    #         Initialize mathematical object region allocator.

    #         Args:
    #             max_small_regions: Maximum number of small regions
    #             max_medium_regions: Maximum number of medium regions
    #             max_large_regions: Maximum number of large regions
    #             max_huge_regions: Maximum number of huge regions
    #             region_sizes: Custom region sizes for each type
    #             cleanup_interval: Cleanup interval in seconds
    #             enable_optimization: Whether to enable region optimization
    #         """
            super().__init__(
    max_small_regions = max_small_regions,
    max_medium_regions = max_medium_regions,
    max_large_regions = max_large_regions,
    max_huge_regions = max_huge_regions,
    region_sizes = region_sizes,
    cleanup_interval = cleanup_interval,
    #         )

    self.enable_optimization = enable_optimization
    self.object_type_stats = defaultdict(lambda: {"count": 0, "total_size": 0})

            logger.info("MathematicalObjectRegionAllocator initialized")

    #     def allocate_object(self, obj: MathematicalObject) -Optional[str]):
    #         """
    #         Allocate a mathematical object with type-specific optimizations.

    #         Args:
    #             obj: Mathematical object to allocate

    #         Returns:
    #             Object ID if successful, None otherwise
    #         """
    start_time = time.time()

    #         try:
    #             with self._lock:
    #                 # Update object type statistics
    obj_type = (
    #                     obj.object_type.value if hasattr(obj, "object_type") else "unknown"
    #                 )
    self.object_type_stats[obj_type]["count"] + = 1
    obj_size = obj.get_memory_usage()
    self.object_type_stats[obj_type]["total_size"] + = obj_size

    #                 # Type-specific allocation strategies
    #                 if hasattr(obj, "is_sparse") and obj.is_sparse():
    #                     # Sparse objects get special handling
                        return self._allocate_sparse_object(obj, obj_size)

    #                 # Use parent allocation for regular objects
    obj_id = super().allocate_object(obj)

    #                 if obj_id and self.enable_optimization:
    #                     # Apply type-specific optimizations
                        self._optimize_object_allocation(obj, obj_id)

    allocation_time = time.time() - start_time
                    self.stats.update_allocation(bool(obj_id), obj_size, allocation_time)

    #                 return obj_id

    #         except Exception as e:
                logger.error(f"Mathematical object allocation failed: {e}")
    allocation_time = time.time() - start_time
                self.stats.update_allocation(False, obj_size, allocation_time)
    #             return None

    #     def _allocate_sparse_object(
    #         self, obj: MathematicalObject, size: int
    #     ) -Optional[str]):
    #         """Allocate sparse mathematical objects with special handling."""
    #         # Sparse objects prefer large regions for better locality
    #         region_type = RegionType.LARGE if size < 1024 * 1024 else RegionType.HUGE

    region = self._find_suitable_region(size, region_type)
    #         if not region:
    #             # Fall back to any suitable region
    #             for rt in [RegionType.LARGE, RegionType.MEDIUM, RegionType.SMALL]:
    region = self._find_suitable_region(size, rt)
    #                 if region:
    #                     break

    #         if not region:
    #             return None

    #         # Allocate sparse object
    obj_id = f"sparse_obj_{id(obj)}_{int(time.time())}"
    region.objects[obj_id] = obj
    self.object_to_region[id(obj)] = (obj_id, region.region_type)

    #         # Mark region as sparse-optimized
    #         if not hasattr(region, "sparse_objects"):
    region.sparse_objects = set()
            region.sparse_objects.add(obj_id)

    #         # Update region status
    #         if region.get_utilization() >= 0.95:
    region.status = RegionStatus.FULL
    #         elif region.get_utilization() 0.0):
    region.status = RegionStatus.PARTIAL
    #         else:
    region.status = RegionStatus.EMPTY

            region.update_access()
            region.update_fragmentation()

            logger.debug(f"Allocated sparse object {obj_id} in region {region.region_id}")
    #         return obj_id

    #     def _optimize_object_allocation(self, obj: MathematicalObject, obj_id: str):
    #         """Apply type-specific optimizations to object allocation."""
    #         obj_type = obj.object_type.value if hasattr(obj, "object_type") else "unknown"

    #         # Type-specific optimizations
    #         if obj_type == "matrix":
    #             # Matrix objects benefit from contiguous memory
                self._optimize_matrix_allocation(obj, obj_id)
    #         elif obj_type == "vector":
    #             # Vector objects benefit from aligned memory
                self._optimize_vector_allocation(obj, obj_id)
    #         elif obj_type == "scalar":
    #             # Scalar objects are small and can be packed densely
                self._optimize_scalar_allocation(obj, obj_id)

    #     def _optimize_matrix_allocation(self, obj: MathematicalObject, obj_id: str):
    #         """Optimize matrix object allocation."""
    region = self.get_region_for_object(obj_id)
    #         if region and hasattr(region, "objects") and obj_id in region.objects:
    #             # Ensure matrix data is contiguous
    #             if hasattr(obj, "ensure_contiguous"):
                    obj.ensure_contiguous()

    #             # Update region fragmentation
                region.update_fragmentation()

    #     def _optimize_vector_allocation(self, obj: MathematicalObject, obj_id: str):
    #         """Optimize vector object allocation."""
    region = self.get_region_for_object(obj_id)
    #         if region and hasattr(region, "objects") and obj_id in region.objects:
    #             # Ensure vector data is aligned
    #             if hasattr(obj, "align_memory"):
                    obj.align_memory()

    #     def _optimize_scalar_allocation(self, obj: MathematicalObject, obj_id: str):
    #         """Optimize scalar object allocation."""
    #         # Scalars are small, so we can pack them densely
    #         pass

    #     def get_object_type_statistics(self) -Dict[str, Dict[str, Any]]):
    #         """Get statistics by object type."""
    stats = {}
    #         for obj_type, type_stats in self.object_type_stats.items():
    stats[obj_type] = {
    #                 "count": type_stats["count"],
    #                 "total_size": type_stats["total_size"],
                    "average_size": type_stats["total_size"] / max(type_stats["count"], 1),
    #             }
    #         return stats

    #     def get_regions_by_object_type(self, obj_type: str) -List[MemoryRegion]):
    #         """Get regions containing objects of a specific type."""
    regions = []
    #         for region_list in self.regions.values():
    #             for region in region_list:
    #                 for obj in region.objects.values():
    #                     if (
                            hasattr(obj, "object_type")
    and obj.object_type.value == obj_type
    #                     ):
                            regions.append(region)
    #                         break
    #         return regions

    #     def batch_allocate_objects(
    #         self, objects: List[MathematicalObject]
    #     ) -List[Optional[str]]):
    #         """
    #         Allocate multiple mathematical objects efficiently.

    #         Args:
    #             objects: List of mathematical objects to allocate

    #         Returns:
    #             List of object IDs (None for failed allocations)
    #         """
    results = []

    #         # Sort objects by size for better packing
    sorted_objects = sorted(objects, key=lambda obj: obj.get_memory_usage())

    #         for obj in sorted_objects:
    obj_id = self.allocate_object(obj)
                results.append(obj_id)

    #         return results

    #     def batch_deallocate_objects(self, obj_ids: List[str]) -int):
    #         """
    #         Deallocate multiple mathematical objects.

    #         Args:
    #             obj_ids: List of object IDs to deallocate

    #         Returns:
    #             Number of successfully deallocated objects
    #         """
    success_count = 0

    #         for obj_id in obj_ids:
    #             if self.deallocate_object(obj_id):
    success_count + = 1

    #         return success_count

    #     def get_memory_fragmentation_by_type(self) -Dict[str, float]):
    #         """Get memory fragmentation ratio by object type."""
    fragmentation_by_type = {}

    #         for obj_type in self.object_type_stats.keys():
    regions = self.get_regions_by_object_type(obj_type)
    #             if regions:
    #                 avg_fragmentation = sum(r.fragmentation_ratio for r in regions) / len(
    #                     regions
    #                 )
    fragmentation_by_type[obj_type] = avg_fragmentation
    #             else:
    fragmentation_by_type[obj_type] = 0.0

    #         return fragmentation_by_type

    #     def get_optimization_recommendations(self) -List[Dict[str, Any]]):
    #         """Get optimization recommendations based on current usage patterns."""
    recommendations = []

    #         # Check for high fragmentation
    overall_fragmentation = self.get_fragmentation_ratio()
    #         if overall_fragmentation 0.3):
                recommendations.append(
    #                 {
    #                     "type": "defragmentation",
    #                     "priority": "high",
                        "message": f"High fragmentation detected ({overall_fragmentation:.2%}). Consider running optimization.",
    #                     "action": "run_optimize_regions",
    #                 }
    #             )

    #         # Check for underutilized regions
    #         for region_type, region_list in self.regions.items():
    #             for region in region_list:
    #                 if (
    region.status == RegionStatus.EMPTY
                        and region.last_accessed < time.time() - 3600
    #                 ):
                        recommendations.append(
    #                         {
    #                             "type": "cleanup",
    #                             "priority": "medium",
    #                             "message": f"Empty region {region.region_id} not used for over an hour.",
    #                             "action": "cleanup_empty_regions",
    #                         }
    #                     )

    #         # Check object type distribution
    type_stats = self.get_object_type_statistics()
    #         for obj_type, stats in type_stats.items():
    #             if stats["count"] 0):
    avg_size = stats["average_size"]
    expected_region_type = self._get_region_type_for_size(int(avg_size))

    #                 # Check if objects are in appropriately sized regions
    regions = self.get_regions_by_object_type(obj_type)
    inappropriate_regions = [
    #                     r
    #                     for r in regions
    #                     if r.region_type != expected_region_type
                        and r.get_utilization() < 0.5
    #                 ]

    #                 if inappropriate_regions:
                        recommendations.append(
    #                         {
    #                             "type": "region_allocation",
    #                             "priority": "low",
    #                             "message": f"{obj_type} objects could benefit from {expected_region_type.value} regions.",
    #                             "action": "reallocate_objects_by_type",
    #                         }
    #                     )

    #         return recommendations

    #     def shutdown(self):
    #         """Shutdown the allocator and cleanup all resources."""
    #         # Run final optimization before shutdown
    #         if self.enable_optimization:
                self.optimize_regions()

    #         # Call parent shutdown
            super().shutdown()
            logger.info("MathematicalObjectRegionAllocator shutdown complete")
