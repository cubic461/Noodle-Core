# Converted from Python to NoodleCore
# Original file: noodle-core

# """Mapper for mathematical objects, using region allocator for creation."""

import typing.Optional

import ..runtime.resource_manager.resource_manager
import .base.SimpleMathematicalObject


class MathematicalObjectMapper
    #     """Maps data to mathematical objects using provided allocator."""

    #     def __init__(self, allocator=None):
    self.allocator = allocator or resource_manager.get_global_allocator()

    #     def create_object(
    self, data: bytes, allocator: Optional[object] = None
    #     ) -> SimpleMathematicalObject:
    #         """Create SimpleMathematicalObject using specified or default allocator."""
    alloc = allocator or self.allocator
            return SimpleMathematicalObject(alloc, data)

    #     def map_from_buffer(self, buffer: memoryview) -> SimpleMathematicalObject:
            """Map existing buffer to object (prototype; assumes buffer from allocator)."""
    obj = SimpleMathematicalObject(self.allocator)
    #         obj.buffer = buffer  # Direct assignment for mapped view
    #         return obj

    #     def batch_create(self, data_list: list[bytes]) -> list[SimpleMathematicalObject]:
    #         """Batch create objects for efficiency."""
    #         return [self.create_object(data) for data in data_list]


# Global mapper for backward compatibility
global_mapper = MathematicalObjectMapper()
