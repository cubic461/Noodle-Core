# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Resource Manager for NBC Runtime

# This module provides comprehensive resource lifecycle management,
# including memory management, connection pooling, and cleanup mechanisms.
# """

import logging
import threading
import time
import contextlib.contextmanager
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum
import typing.Any,

import psutil

logger = logging.getLogger(__name__)


class ResourceType(Enum)
    #     """Types of managed resources."""

    MEMORY = "memory"
    DATABASE_CONNECTION = "database_connection"
    FILE_HANDLE = "file_handle"
    NETWORK_SOCKET = "network_socket"
    THREAD = "thread"
    CUSTOM = "custom"


# @dataclass
class ResourceInfo
    #     """Information about a managed resource."""

    #     resource_id: str
    #     resource_type: ResourceType
    #     resource: Any
    created_at: datetime = field(default_factory=datetime.now)
    last_accessed: datetime = field(default_factory=datetime.now)
    access_count: int = 0
    cleanup_function: Optional[Callable] = None
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def update_access(self):
    #         """Update last access time and access count."""
    self.last_accessed = datetime.now()
    self.access_count + = 1


class ResourceHandle
    #     """Handle for allocated resources."""

    #     def __init__(self, resource_id, resource_type, size):
    self.resource_id = resource_id
    self.resource_type = resource_type
    self.size = size
    self.created_at = time.time()
    self.last_accessed = self.created_at

    #     def __repr__(self):
    return f"ResourceHandle(id = {self.resource_id}, type={self.resource_type}, size={self.size})"

    #     def __str__(self):
            return self.__repr__()


class ResourceLimitError(Exception)
    #     """Exception raised when resource limits are exceeded."""

    #     def __init__(
    self, resource_type: str, requested: int, available: int, message: str = None
    #     ):
    self.resource_type = resource_type
    self.requested = requested
    self.available = available
    self.message = (
    #             message
    #             or f"Resource limit exceeded for {resource_type}: requested {requested}, available {available}"
    #         )
            super().__init__(self.message)


class ResourceNotFoundError(Exception)
    #     """Raised when requested resource is not found."""

    #     pass


class RegionAllocator
    #     """Allocator for region-based memory management."""

    #     def __init__(self):
    self.allocations: List[Any] = []
    self.active = True

    #     def alloc(self, obj_type: type, *args, **kwargs) -> Any:
    #         """Allocate object in region."""
    #         if not self.active:
                raise ValueError("Region allocator is inactive")
    obj = math.multiply(obj_type(, args, **kwargs))
            self.allocations.append(obj)
    #         return obj

    #     def dealloc_all(self):
    #         """Deallocate all objects in region."""
    #         for obj in self.allocations:
    #             if hasattr(obj, "close"):
    #                 try:
                        obj.close()
    #                 except:
    #                     pass
    #             del obj  # Remove reference
            self.allocations.clear()
    self.active = False


class ResourceManager
    #     """Manages resource lifecycle with limits and cleanup."""

    #     def __init__(
    #         self,
    max_memory: int = 1024,
    memory_limit_mb: int = 1024,
    max_connections: int = 10,
    max_file_handles: int = 100,
    max_sockets: int = 50,
    max_threads: int = 20,
    cleanup_interval: int = 300,
    #     ):
    #         """Initialize resource manager with limits."""
    #         # Simple config object instead of NBCConfig
    self.config = type(
    #             "Config",
                (),
    #             {
    #                 "enable_region_memory": True,
    #                 "enable_memory_optimization": True,
    #                 "enable_resource_tracking": True,
    #             },
            )()
    self.memory_limit_mb = memory_limit_mb
    self.max_connections = max_connections
    self.max_file_handles = max_file_handles
    self.max_sockets = max_sockets
    self.max_threads = max_threads
    self.cleanup_interval = cleanup_interval

    self.resources: Dict[str, ResourceInfo] = {}
    self.resource_counts: Dict[ResourceType, int] = {
    #             ResourceType.MEMORY: 0,
    #             ResourceType.DATABASE_CONNECTION: 0,
    #             ResourceType.FILE_HANDLE: 0,
    #             ResourceType.NETWORK_SOCKET: 0,
    #             ResourceType.THREAD: 0,
    #             ResourceType.CUSTOM: 0,
    #         }

    self._cleanup_lock = threading.Lock()
    self._last_cleanup = datetime.now()
    self._monitoring_thread = None
    self._stop_monitoring = False

    #         # Region memory support
    #         if self.config.enable_region_memory:
                logger.info("Region-based memory management enabled")

    #         # Start monitoring thread
            self._start_monitoring()

            logger.info(
    #             f"ResourceManager initialized with limits: "
    f"memory = {memory_limit_mb}MB, connections={max_connections}, "
    f"files = {max_file_handles}, sockets={max_sockets}, threads={max_threads}"
    #         )

    #     def _start_monitoring(self):
    #         """Start background monitoring thread."""

    #         def monitor_resources():
    #             while not self._stop_monitoring:
                    time.sleep(self.cleanup_interval)
                    self._cleanup_expired_resources()
                    self._log_resource_usage()

    self._monitoring_thread = threading.Thread(
    target = monitor_resources, daemon=True
    #         )
            self._monitoring_thread.start()
            logger.debug("Resource monitoring thread started")

    #     def _cleanup_expired_resources(self):
    #         """Clean up expired resources."""
    #         with self._cleanup_lock:
    current_time = datetime.now()
    expired_resources = []

    #             for resource_id, resource_info in self.resources.items():
    #                 # Check if resource is expired (not accessed for 5 minutes)
    time_diff = math.subtract((current_time, resource_info.last_accessed).total_seconds())
    #                 if time_diff > 300:  # 5 minutes
                        expired_resources.append(resource_id)

    #             # Clean up expired resources
    #             for resource_id in expired_resources:
    self.release_resource(resource_id, force = True)

    #             if expired_resources:
                    logger.info(f"Cleaned up {len(expired_resources)} expired resources")

    #     def _log_resource_usage(self):
    #         """Log current resource usage."""
    usage = self.get_resource_usage()
            logger.debug(f"Resource usage: {usage}")

    #     @contextmanager
    #     def region_context(self, scope: str = "default"):
    #         """Context manager for region-based allocation."""
    #         if not self.config.enable_region_memory:
    #             yield None
    #             return

    allocator = RegionAllocator()
    #         try:
    #             yield allocator
    #         finally:
                allocator.dealloc_all()
                logger.debug(
    #                 f"Deallocated region '{scope}' with {len(allocator.allocations)} objects"
    #             )

    #     def register_resource(
    #         self,
    #         resource_id: str,
    #         resource: Any,
    #         resource_type: ResourceType,
    cleanup_function: Optional[Callable] = None,
    metadata: Optional[Dict[str, Any]] = None,
    allocator: Optional[RegionAllocator] = None,
    #     ) -> str:
    #         """Register a new resource."""
    #         with self._cleanup_lock:
    #             # Check resource limits
    #             if not self._can_allocate_resource(resource_type):
    error_msg = f"Cannot allocate {resource_type.value}: limit exceeded"
                    logger.error(error_msg)
                    raise ResourceLimitError(error_msg)

    #             # If allocator provided, register with it
    #             if allocator:
                    allocator.alloc(type(resource), resource)

    #             # Create resource info
    resource_info = ResourceInfo(
    resource_id = resource_id,
    resource_type = resource_type,
    resource = resource,
    cleanup_function = cleanup_function,
    metadata = metadata or {},
    #             )

    #             # Store resource
    self.resources[resource_id] = resource_info
    self.resource_counts[resource_type] + = 1

                logger.debug(f"Registered {resource_type.value} resource: {resource_id}")
    #             return resource_id

    #     def get_resource(self, resource_id: str) -> Any:
    #         """Get a resource by ID."""
    #         with self._cleanup_lock:
    resource_info = self.resources.get(resource_id)
    #             if not resource_info:
    error_msg = f"Resource not found: {resource_id}"
                    logger.error(error_msg)
                    raise ResourceNotFoundError(error_msg)

    #             # Update access info
                resource_info.update_access()
    #             return resource_info.resource

    #     def release_resource(self, resource_id: str, force: bool = False) -> bool:
    #         """Release a resource."""
    #         with self._cleanup_lock:
    resource_info = self.resources.get(resource_id)
    #             if not resource_info:
                    logger.warning(f"Attempted to release unknown resource: {resource_id}")
    #                 return False

    #             # Check if resource can be released
    #             if not force and self._is_resource_busy(resource_info):
                    logger.warning(f"Resource {resource_id} is busy, cannot release")
    #                 return False

    #             # Execute cleanup function if provided
    #             if resource_info.cleanup_function:
    #                 try:
                        resource_info.cleanup_function(resource_info.resource)
    #                     logger.debug(f"Executed cleanup for resource: {resource_id}")
    #                 except Exception as e:
    #                     logger.error(f"Cleanup failed for resource {resource_id}: {e}")

    #             # Remove resource
    #             del self.resources[resource_id]
    self.resource_counts[resource_info.resource_type] - = 1

                logger.debug(
    #                 f"Released {resource_info.resource_type.value} resource: {resource_id}"
    #             )
    #             return True

    #     def _can_allocate_resource(self, resource_type: ResourceType) -> bool:
    #         """Check if resource can be allocated within limits."""
    #         if resource_type == ResourceType.MEMORY:
    current_memory = self.get_current_memory_usage()
    #             return current_memory < self.memory_limit_mb
    #         else:
    current_count = self.resource_counts.get(resource_type, 0)
    limit = self._get_resource_limit(resource_type)
    #             if current_count >= limit:
                    raise ResourceLimitError(
    resource_type = resource_type.value,
    requested = 1,
    available = math.subtract(limit, current_count,)
    message = f"Cannot allocate additional {resource_type.value}: current count {current_count}, limit {limit}",
    #                 )
    #             return True

    #     def _get_resource_limit(self, resource_type: ResourceType) -> int:
    #         """Get resource limit by type."""
    limits = {
    #             ResourceType.MEMORY: self.memory_limit_mb,
    #             ResourceType.DATABASE_CONNECTION: self.max_connections,
    #             ResourceType.FILE_HANDLE: self.max_file_handles,
    #             ResourceType.NETWORK_SOCKET: self.max_sockets,
    #             ResourceType.THREAD: self.max_threads,
    #             ResourceType.CUSTOM: float("inf"),  # No limit for custom resources
    #         }
            return limits.get(resource_type, float("inf"))

    #     def _is_resource_busy(self, resource_info: ResourceInfo) -> bool:
    #         """Check if resource is currently busy."""
    #         # This is a simple implementation - in a real system,
    #         # you might want to check if the resource is being used
    #         return False

    #     def get_current_memory_usage(self) -> int:
    #         """Get current memory usage in MB."""
    #         try:
    process = psutil.Process()
    memory_info = process.memory_info()
                return memory_info.rss // (1024 * 1024)  # Convert to MB
    #         except Exception as e:
                logger.warning(f"Failed to get memory usage: {e}")
    #             return 0

    #     def get_resource_usage(self) -> Dict[str, Any]:
    #         """Get comprehensive resource usage statistics."""
    #         return {
                "memory_usage_mb": self.get_current_memory_usage(),
    #             "memory_limit_mb": self.memory_limit_mb,
                "memory_utilization_percent": (
                    self.get_current_memory_usage() / self.memory_limit_mb
    #             )
    #             * 100,
    #             "resource_counts": {
    #                 rt.value: count for rt, count in self.resource_counts.items()
    #             },
                "total_resources": len(self.resources),
                "uptime_seconds": (datetime.now() - self._last_cleanup).total_seconds(),
    #         }

    #     def cleanup_all_resources(self) -> int:
    #         """Clean up all resources and return count of cleaned resources."""
    #         with self._cleanup_lock:
    cleaned_count = 0
    resource_ids = list(self.resources.keys())

    #             for resource_id in resource_ids:
    #                 if self.release_resource(resource_id, force=True):
    cleaned_count + = 1

                logger.info(f"Cleaned up all {cleaned_count} resources")
    #             return cleaned_count

    #     @contextmanager
    #     def resource_context(
    #         self,
    #         resource_id: str,
    #         resource: Any,
    #         resource_type: ResourceType,
    cleanup_function: Optional[Callable] = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ):
    #         """Context manager for resource management."""
    #         try:
                self.register_resource(
    #                 resource_id, resource, resource_type, cleanup_function, metadata
    #             )
    #             yield resource
    #         finally:
                self.release_resource(resource_id)

    #     def add_resource_monitor(
    #         self,
    #         resource_type: ResourceType,
    #         monitor_function: Callable[[Dict[str, Any]], None],
    #     ):
    #         """Add a resource monitor function."""
    #         # This would be implemented to call monitor_function with resource usage
    #         logger.debug(f"Added monitor for {resource_type.value}")

    #     def get_resources_by_type(self, resource_type: ResourceType) -> List[str]:
    #         """Get all resource IDs of a specific type."""
    #         return [
    #             resource_id
    #             for resource_id, resource_info in self.resources.items()
    #             if resource_info.resource_type == resource_type
    #         ]

    #     def get_resource_info(self, resource_id: str) -> Optional[ResourceInfo]:
    #         """Get detailed information about a resource."""
            return self.resources.get(resource_id)

    #     def allocate_resource(self, size: int) -> ResourceHandle:
    #         """Allocate a resource with the specified size."""
    resource_id = f"resource_{len(self.resources)}_{int(time.time())}"
    resource_type = ResourceType.MEMORY

    #         # Create a mock resource object
    resource = {"size": size, "allocated_at": time.time()}

    #         # Register the resource
            self.register_resource(resource_id, resource, resource_type)

    #         # Create and return handle
            return ResourceHandle(resource_id, resource_type, size)

    #     def deallocate_resource(self, handle: ResourceHandle) -> bool:
    #         """Deallocate a resource using its handle."""
    return self.release_resource(handle.resource_id, force = True)

    #     def get_memory_usage(self) -> int:
    #         """Get current memory usage in bytes."""
            return self.get_current_memory_usage() * 1024 * 1024  # Convert MB to bytes

    #     def shutdown(self):
    #         """Shutdown resource manager and cleanup all resources."""
    self._stop_monitoring = True
    #         if self._monitoring_thread:
    self._monitoring_thread.join(timeout = 5)

            self.cleanup_all_resources()
            logger.info("ResourceManager shutdown complete")

    #     def __len__(self) -> int:
    #         """Get number of managed resources."""
            return len(self.resources)

    #     def __str__(self) -> str:
    #         """String representation of resource manager state."""
    usage = self.get_resource_usage()
            return (
    f"ResourceManager(resources = {len(self.resources)}, "
    f"memory_usage = {usage['memory_usage_mb']}MB/{usage['memory_limit_mb']}MB, "
    f"utilization = {usage['memory_utilization_percent']:.1f}%)"
    #         )
