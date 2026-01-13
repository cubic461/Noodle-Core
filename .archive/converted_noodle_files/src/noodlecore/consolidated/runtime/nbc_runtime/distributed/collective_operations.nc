# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Collective operations for distributed execution.
# """

import enum.Enum
import typing.Any,


class CollectiveOperations
    #     """Collective operations for distributed execution."""

    #     def __init__(self):
    self.operations = []

    #     def broadcast(self, message: Any):
    #         """Broadcast a message to all nodes."""
    #         pass

    #     def reduce(self, data: List[Any], operation: str = "sum"):
    #         """Reduce data across nodes."""
    #         return data


class OperationType(Enum)
    #     """Types of collective operations."""

    BROADCAST = "broadcast"
    REDUCE = "reduce"
    ALL_REDUCE = "all_reduce"
    GATHER = "gather"
    SCATTER = "scatter"
    ALL_GATHER = "all_gather"
    REDUCE_SCATTER = "reduce_scatter"
