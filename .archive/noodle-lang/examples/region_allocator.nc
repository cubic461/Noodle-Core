# Converted from Python to NoodleCore
# Original file: src

# """Region-based memory allocator for mathematical objects in Noodle runtime."""

import typing.List

# bytearray is a built-in Python type, no import needed


class RegionAllocatorConfig
    #     """Configuration for region allocator."""

    REGION_SIZE: int = 1024 * 1024  # 1MB default
    NUM_REGIONS: int = 10
    #     OBJECT_SIZE: int = 64  # Fixed size for SimpleMathematicalObject prototype


class RegionAllocator
        """Allocator using bump pointer within fixed-size regions (arenas)."""

    #     def __init__(self, config: Optional[RegionAllocatorConfig] = None):
    self.config = config or RegionAllocatorConfig()
    self.regions: List[bytearray] = []
    self.current_region_idx: int = 0
    self.bump_pointers: List[int] = []
            self._init_regions()

    #     def _init_regions(self) -None):
    #         """Initialize regions as bytearrays."""
    #         for _ in range(self.config.NUM_REGIONS):
    region = bytearray(self.config.REGION_SIZE)
                self.regions.append(region)
                self.bump_pointers.append(0)

    #     def alloc(self, size: int = None) -Optional[memoryview]):
    #         """Allocate space using bump pointer; return memoryview to buffer.

    #         Args:
    #             size: Object size; defaults to config.OBJECT_SIZE.

    #         Returns:
    #             memoryview to allocated space or None if full.
    #         """
    size = size or self.config.OBJECT_SIZE
    current_bump = self.bump_pointers[self.current_region_idx]
    end = current_bump + size

    #         if end self.config.REGION_SIZE):
    #             # Try next region
    self.current_region_idx = (self.current_region_idx + 1 % len(self.regions))
    current_bump = self.bump_pointers[self.current_region_idx]
    end = current_bump + size
    #             if end self.config.REGION_SIZE):
    #                 return None  # All regions full

    region = self.regions[self.current_region_idx]
    self.bump_pointers[self.current_region_idx] = end
            return memoryview(region)[current_bump:end]

    #     def reset_current_region(self) -None):
    #         """Reset bump pointer of current region to 0."""
    self.bump_pointers[self.current_region_idx] = 0

    #     def reset_all_regions(self) -None):
    #         """Reset all bump pointers to 0, deallocating all."""
    #         for i in range(len(self.bump_pointers)):
    self.bump_pointers[i] = 0
    self.current_region_idx = 0

    #     def is_full(self) -bool):
    #         """Check if current region is full."""
    current_bump = self.bump_pointers[self.current_region_idx]
    #         return current_bump + self.config.OBJECT_SIZE self.config.REGION_SIZE

    #     def get_used_memory(self):
    """int)"""
    #         """Get total used memory across regions."""
    #         return sum(bp for bp in self.bump_pointers)
