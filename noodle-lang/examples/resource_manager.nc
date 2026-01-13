# Converted from Python to NoodleCore
# Original file: src

# """Resource manager for Noodle runtime, including region-based memory management."""

import contextlib.contextmanager
import typing.Generator

import .memory.region_allocator.RegionAllocator


class RegionManager
    #     """Manages regions for allocation, integrated with runtime lifecycle."""

    #     def __init__(self, config: Optional[RegionAllocatorConfig] = None):
    self.config = config or RegionAllocatorConfig()
    self.allocator = RegionAllocator(self.config)
    self.active_regions: list = []

    #     @contextmanager
    #     def create_region(
    self, scope: str = "default"
    #     ) -Generator[RegionAllocator, None, None]):
    #         """Context manager for creating a scoped region; auto-cleanup on exit."""
    region_alloc = RegionAllocator(
    #             self.config
    #         )  # New allocator per region for isolation
            self.active_regions.append(region_alloc)
    #         try:
    #             yield region_alloc
    #         finally:
    #             # Cleanup: reset region on task end
                region_alloc.reset_all_regions()
                self.active_regions.remove(region_alloc)
    #             # Hook for further lifecycle (e.g., notify distributed systems)
                self._notify_cleanup(scope)

    #     def _notify_cleanup(self, scope: str) -None):
    #         """Placeholder for lifecycle hooks (e.g., integrate with actor model or distributed cleanup)."""
    #         # Future: Call placement_engine.py or cluster_manager.py for distributed dealloc
    #         pass

    #     def get_global_allocator(self) -RegionAllocator):
    #         """Get global allocator for non-scoped use."""
    #         return self.allocator

    #     def cleanup_all(self) -None):
    #         """Full cleanup for runtime shutdown."""
    #         for alloc in self.active_regions:
                alloc.reset_all_regions()
            self.allocator.reset_all_regions()
            self.active_regions.clear()


# Global instance for backward compatibility
resource_manager = RegionManager()
