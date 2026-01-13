# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Stack Manager for NBC Runtime

# This module provides a robust stack frame management system that maintains
# proper parent-child relationships and ensures clean resource cleanup.
# """

import logging
import dataclasses.dataclass,
import datetime.datetime
import typing.Any,

logger = logging.getLogger(__name__)


# @dataclass
class StackFrame
    #     """Represents a single stack frame with proper parent-child relationships."""

    #     name: str
    #     locals_data: Dict[str, Any]
    return_address: Optional[int] = None
    parent: Optional["StackFrame"] = None
    created_at: datetime = field(default_factory=datetime.now)
    frame_id: int = field(default=0)

    #     def __post_init__(self):
    #         """Initialize frame ID after object creation."""
    #         if self.return_address is None:
    self.return_address = 0

    #     def get_parent_chain(self) -> List["StackFrame"]:
    #         """Get the complete parent chain for this frame."""
    chain = []
    current = self.parent
    #         while current:
                chain.append(current)
    current = current.parent
    #         return chain

    #     def get_depth(self) -> int:
    #         """Get the depth of this frame in the stack."""
            return len(self.get_parent_chain())


class StackOverflowError(Exception)
    #     """Raised when maximum stack depth is exceeded."""

    #     pass


class StackUnderflowError(Exception)
    #     """Raised when attempting to pop from empty stack."""

    #     pass


class StackManager
    #     """Manages stack frames with proper validation and cleanup."""

    #     def __init__(self, max_stack_depth: int = 1000):
    #         """Initialize stack manager with configurable depth limit."""
    self.frames: List[StackFrame] = []
    self.current_frame: Optional[StackFrame] = None
    self.max_stack_depth = max_stack_depth
    self.frame_counter = 0
    self._closed_frames: List[StackFrame] = []
    self._lock = None  # Initialize lock to None

    #         logger.info(f"StackManager initialized with max_depth={max_stack_depth}")

    #     def push_frame(
    #         self,
    #         name: str,
    #         locals_data: Dict[str, Any],
    return_address: Optional[int] = None,
    #     ) -> StackFrame:
    #         """Push a new stack frame with validation."""
    #         if len(self.frames) >= self.max_stack_depth:
    error_msg = f"Maximum stack depth ({self.max_stack_depth}) exceeded"
                logger.error(error_msg)
                raise StackOverflowError(error_msg)

    #         # Create new frame with proper parent relationship
    parent = self.current_frame
    self.frame_counter + = 1

    frame = StackFrame(
    name = name,
    locals_data = locals_data.copy(),
    return_address = return_address,
    parent = parent,
    frame_id = self.frame_counter,
    #         )

            self.frames.append(frame)
    self.current_frame = frame

            logger.debug(
                f"Pushed frame '{name}' (ID: {frame.frame_id}), "
    #             f"depth={frame.get_depth()}, parent={parent.name if parent else 'None'}"
    #         )

    #         return frame

    #     def pop_frame(self) -> StackFrame:
    #         """Pop current frame and restore parent relationship."""
    #         if not self.frames:
    error_msg = "Attempt to pop from empty stack"
                logger.error(error_msg)
                raise StackUnderflowError(error_msg)

    frame = self.frames.pop()
    #         self.current_frame = frame.parent if frame.parent else None

    #         # Store for cleanup tracking
            self._closed_frames.append(frame)

            logger.debug(
                f"Popped frame '{frame.name}' (ID: {frame.frame_id}), "
    #             f"new_current={self.current_frame.name if self.current_frame else 'None'}"
    #         )

    #         return frame

    #     def pop(self) -> StackFrame:
    #         """Alias for pop_frame for compatibility."""
            return self.pop_frame()

    #     def get_stack_depth(self) -> int:
    #         """Get current stack depth."""
            return len(self.frames)

    #     def get_current_frame(self) -> Optional[StackFrame]:
    #         """Get the current stack frame."""
    #         return self.current_frame

    #     def get_frame_by_id(self, frame_id: int) -> Optional[StackFrame]:
    #         """Find a frame by its ID."""
    #         for frame in self.frames:
    #             if frame.frame_id == frame_id:
    #                 return frame
    #         return None

    #     def get_frame_by_name(self, name: str) -> List[StackFrame]:
    #         """Find all frames with the given name."""
    #         # Since self._lock is None, we'll just access directly
    #         return [frame for frame in self.frames if frame.name == name]

    #     def validate_stack(self) -> Dict[str, Any]:
    #         """Validate stack integrity and return status."""
    issues = []

    #         # Check for cycles in parent relationships
    visited = set()
    current = self.current_frame
    #         while current:
    #             if current.frame_id in visited:
                    issues.append(f"Cycle detected in frame {current.frame_id}")
    #                 break
                visited.add(current.frame_id)
    current = current.parent

    #         # Check depth consistency
    #         for i, frame in enumerate(self.frames):
    expected_depth = i
    actual_depth = frame.get_depth()
    #             if actual_depth != expected_depth:
                    issues.append(
    #                     f"Frame {frame.frame_id} has depth {actual_depth}, expected {expected_depth}"
    #                 )

    #         # Check for orphaned frames
    #         if self.frames and not self.current_frame:
                issues.append("Stack has frames but no current frame")

    #         return {
    "valid": len(issues) = = 0,
    #             "issues": issues,
                "frame_count": len(self.frames),
                "current_frame": (
    #                 self.current_frame.frame_id if self.current_frame else None
    #             ),
    #             "max_depth": self.max_stack_depth,
                "utilization": len(self.frames) / self.max_stack_depth,
    #         }

    #     def cleanup_closed_frames(self) -> int:
    #         """Clean up closed frames and return count of cleaned frames."""
    #         # Since self._lock is None, we'll just clear the tracking list
    count = len(self._closed_frames)
            self._closed_frames.clear()
            logger.debug(f"Cleaned up {count} closed frames")
    #         return count

    #     def get_stack_trace(self) -> List[Dict[str, Any]]:
    #         """Get a formatted stack trace for debugging."""
    #         if not self.current_frame:
    #             return []

    trace = []
    current = self.current_frame

    #         while current:
                trace.append(
    #                 {
    #                     "frame_id": current.frame_id,
    #                     "name": current.name,
                        "locals_count": len(current.locals_data),
    #                     "return_address": current.return_address,
                        "depth": current.get_depth(),
                        "created_at": current.created_at.isoformat(),
    #                 }
    #             )
    current = current.parent

    #         return trace

    #     def __len__(self) -> int:
    #         """Get current stack size."""
            return len(self.frames)

    #     def __str__(self) -> str:
    #         """String representation of stack state."""
    #         return f"StackManager(frames={len(self.frames)}, current={self.current_frame.name if self.current_frame else 'None'})"
