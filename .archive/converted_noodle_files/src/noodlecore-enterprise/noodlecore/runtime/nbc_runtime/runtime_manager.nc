# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Runtime Manager for NBC Runtime
# -------------------------------
# Provides runtime management components including resource management,
# stack management, and runtime factory functions.
# """

import uuid
import typing.Any,
import .config.NBCConfig
import .core.NBCRuntime
import .error_handler.ErrorHandler
import .errors.NBCRuntimeError


class ResourceManager
    #     """Manages runtime resources like memory and CPU."""

    #     def __init__(self, config: NBCConfig):
    #         """
    #         Initialize the resource manager.

    #         Args:
    #             config: NBC configuration
    #         """
    self.config = config
    self.memory_usage = 0
    #         self.max_memory = config.max_memory_usage if hasattr(config, 'max_memory_usage') else 100 * 1024 * 1024  # 100MB default
    self.cpu_usage = 0.0
    self.max_cpu = 1.0  # 100% CPU usage
    self.allocated_resources = {}
    self.error_handler = ErrorHandler()

    #     def allocate_memory(self, size: int) -> str:
    #         """
    #         Allocate memory for runtime operations.

    #         Args:
    #             size: Size of memory to allocate in bytes

    #         Returns:
    #             Allocation ID
    #         """
    #         if self.memory_usage + size > self.max_memory:
                raise NBCRuntimeError(f"Memory allocation failed: insufficient memory (requested: {size}, available: {self.max_memory - self.memory_usage})")

    allocation_id = str(uuid.uuid4())
    self.allocated_resources[allocation_id] = {
    #             'type': 'memory',
    #             'size': size,
                'allocated_at': __import__('time').time()
    #         }
    self.memory_usage + = size

    #         return allocation_id

    #     def deallocate_memory(self, allocation_id: str):
    #         """
    #         Deallocate memory.

    #         Args:
    #             allocation_id: ID of the allocation to deallocate
    #         """
    #         if allocation_id in self.allocated_resources:
    resource = self.allocated_resources[allocation_id]
    #             if resource['type'] == 'memory':
    self.memory_usage - = resource['size']
    #                 del self.allocated_resources[allocation_id]

    #     def get_memory_usage(self) -> int:
    #         """Get current memory usage."""
    #         return self.memory_usage

    #     def get_memory_percentage(self) -> float:
    #         """Get memory usage as percentage of max."""
    #         return (self.memory_usage / self.max_memory) * 100 if self.max_memory > 0 else 0

    #     def allocate_cpu(self, percentage: float) -> str:
    #         """
    #         Allocate CPU resources.

    #         Args:
                percentage: CPU percentage to allocate (0.0 to 1.0)

    #         Returns:
    #             Allocation ID
    #         """
    #         if self.cpu_usage + percentage > self.max_cpu:
                raise NBCRuntimeError(f"CPU allocation failed: insufficient CPU (requested: {percentage}, available: {self.max_cpu - self.cpu_usage})")

    allocation_id = str(uuid.uuid4())
    self.allocated_resources[allocation_id] = {
    #             'type': 'cpu',
    #             'percentage': percentage,
                'allocated_at': __import__('time').time()
    #         }
    self.cpu_usage + = percentage

    #         return allocation_id

    #     def deallocate_cpu(self, allocation_id: str):
    #         """
    #         Deallocate CPU resources.

    #         Args:
    #             allocation_id: ID of the allocation to deallocate
    #         """
    #         if allocation_id in self.allocated_resources:
    resource = self.allocated_resources[allocation_id]
    #             if resource['type'] == 'cpu':
    self.cpu_usage - = resource['percentage']
    #                 del self.allocated_resources[allocation_id]

    #     def get_cpu_usage(self) -> float:
    #         """Get current CPU usage."""
    #         return self.cpu_usage

    #     def get_cpu_percentage(self) -> float:
    #         """Get CPU usage as percentage of max."""
    #         return (self.cpu_usage / self.max_cpu) * 100 if self.max_cpu > 0 else 0

    #     def get_resource_stats(self) -> Dict[str, Any]:
    #         """Get resource usage statistics."""
    #         return {
    #             'memory_usage': self.memory_usage,
                'memory_percentage': self.get_memory_percentage(),
    #             'cpu_usage': self.cpu_usage,
                'cpu_percentage': self.get_cpu_percentage(),
                'allocations': len(self.allocated_resources),
    #             'max_memory': self.max_memory,
    #             'max_cpu': self.max_cpu
    #         }

    #     def cleanup(self):
    #         """Clean up all allocated resources."""
            self.allocated_resources.clear()
    self.memory_usage = 0
    self.cpu_usage = 0.0


class StackManager
    #     """Manages the runtime stack for execution."""

    #     def __init__(self, max_stack_depth: int = 1000):
    #         """
    #         Initialize the stack manager.

    #         Args:
    #             max_stack_depth: Maximum stack depth
    #         """
    self.max_stack_depth = max_stack_depth
    self.frames = []
    self.current_frame = None
    self.error_handler = ErrorHandler()

    #     def push_frame(self, frame_data: Dict[str, Any]):
    #         """
    #         Push a new stack frame.

    #         Args:
    #             frame_data: Frame data to push
    #         """
    #         if len(self.frames) >= self.max_stack_depth:
                raise NBCRuntimeError(f"Stack overflow: maximum depth of {self.max_stack_depth} exceeded")

    frame = {
                'id': str(uuid.uuid4()),
    #             'data': frame_data,
                'created_at': __import__('time').time(),
    #             'variables': {},
    #             'parent': self.current_frame
    #         }

            self.frames.append(frame)
    self.current_frame = frame

    #     def pop_frame(self) -> Optional[Dict[str, Any]]:
    #         """
    #         Pop the current stack frame.

    #         Returns:
    #             Popped frame data or None if stack is empty
    #         """
    #         if not self.frames:
    #             return None

    frame = self.frames.pop()
    #         if self.frames:
    self.current_frame = math.subtract(self.frames[, 1])
    #         else:
    self.current_frame = None

    #         return frame

    #     def get_stack_depth(self) -> int:
    #         """Get current stack depth."""
            return len(self.frames)

    #     def get_stack_frames(self) -> List[Dict[str, Any]]:
    #         """Get all stack frames."""
            return self.frames.copy()

    #     def set_variable(self, name: str, value: Any):
    #         """
    #         Set a variable in the current frame.

    #         Args:
    #             name: Variable name
    #             value: Variable value
    #         """
    #         if self.current_frame:
    self.current_frame['variables'][name] = value
    #         else:
                raise NBCRuntimeError("No current stack frame")

    #     def get_variable(self, name: str) -> Any:
    #         """
    #         Get a variable from the current frame.

    #         Args:
    #             name: Variable name

    #         Returns:
    #             Variable value or None if not found
    #         """
    #         if self.current_frame:
                return self.current_frame['variables'].get(name)
    #         return None

    #     def clear_stack(self):
    #         """Clear the entire stack."""
            self.frames.clear()
    self.current_frame = None


def create_runtime(config: NBCConfig) -> NBCRuntime:
#     """
#     Create a new NBC runtime instance.

#     Args:
#         config: Runtime configuration

#     Returns:
#         NBCRuntime instance
#     """
#     try:
#         # Create runtime with default parameters
runtime = NBCRuntime()

#         # Initialize runtime components
#         if not hasattr(runtime, 'resource_manager'):
runtime.resource_manager = ResourceManager(config)

#         if not hasattr(runtime, 'stack_manager'):
runtime.stack_manager = StackManager(
#                 max_stack_depth=config.max_stack_size if hasattr(config, 'max_stack_size') else 1000
#             )

#         # Set additional configuration
#         if hasattr(config, 'max_execution_time'):
runtime.max_execution_time = config.max_execution_time

#         if hasattr(config, 'max_memory_usage'):
runtime.max_memory_usage = config.max_memory_usage

#         if hasattr(config, 'enable_optimization'):
runtime.enable_optimization = config.enable_optimization

#         if hasattr(config, 'optimization_level'):
runtime.optimization_level = config.optimization_level

#         if hasattr(config, 'log_level'):
runtime.log_level = config.log_level

#         return runtime

#     except Exception as e:
error_handler = ErrorHandler()
        error_handler.handle_error(e, {"context": "create_runtime"})
        raise NBCRuntimeError(f"Failed to create runtime: {str(e)}")


def create_default_runtime() -> NBCRuntime:
#     """
#     Create a runtime with default configuration.

#     Returns:
#         NBCRuntime instance with default config
#     """
config = NBCConfig()
    return create_runtime(config)
