# Converted from Python to NoodleCore
# Original file: src

# """
# Execution Context Management for NoodleCore Runtime

# This module provides context management for code execution, including
# variable scoping, resource tracking, and execution state management.
# """

import time
import uuid
import logging
import threading
import typing.Any
from dataclasses import dataclass
import enum.Enum
import contextlib.contextmanager

import .errors.NoodleError


class ContextScope(Enum)
    #     """Scope levels for execution context."""
    GLOBAL = "global"
    MODULE = "module"
    FUNCTION = "function"
    BLOCK = "block"


class ContextState(Enum)
    #     """State of an execution context."""
    CREATED = "created"
    ACTIVE = "active"
    SUSPENDED = "suspended"
    COMPLETED = "completed"
    ERROR = "error"


class ContextError(NoodleError)
    #     """Raised when context operations fail."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3401", details)


class ResourceLimitError(NoodleError)
    #     """Raised when resource limits are exceeded."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3402", details)


dataclass
class ResourceLimits
    #     """Resource limits for execution context."""
    max_memory_mb: int = 512
    max_execution_time: float = 30.0
    max_file_handles: int = 100
    max_network_connections: int = 10
    max_cpu_percent: float = 80.0


dataclass
class ExecutionContextStats
    #     """Statistics for an execution context."""
    created_at: float = field(default_factory=time.time)
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    execution_time: float = 0.0
    memory_usage_mb: float = 0.0
    cpu_usage_percent: float = 0.0
    instructions_executed: int = 0
    variables_created: int = 0
    functions_called: int = 0
    exceptions_raised: int = 0


class ExecutionContext
    #     """
    #     Manages execution context for NoodleCore programs.

    #     This class provides variable scoping, resource tracking, and
    #     execution state management for code execution.
    #     """

    #     def __init__(self, context_id: Optional[str] = None,
    scope: ContextScope = ContextScope.GLOBAL,
    parent: Optional['ExecutionContext'] = None,
    limits: Optional[ResourceLimits] = None):""
    #         Initialize execution context.

    #         Args:
    #             context_id: Unique identifier for the context
    #             scope: Scope level of the context
    #             parent: Parent context for nested scopes
    #             limits: Resource limits for the context
    #         """
    self.context_id = context_id or str(uuid.uuid4())
    self.scope = scope
    self.parent = parent
    self.limits = limits or ResourceLimits()
    self.state = ContextState.CREATED
    self.stats = ExecutionContextStats()
    self.logger = logging.getLogger(__name__)

    #         # Context data
    self._variables: Dict[str, Any] = {}
    self._functions: Dict[str, callable] = {}
    self._imports: Set[str] = set()
    self._children: List['ExecutionContext'] = []
    self._lock = threading.RLock()

    #         # Resource tracking
    self._memory_usage = 0
    self._start_time = 0
    self._execution_thread = None

    #         # Event handlers
    self._event_handlers = {
    #             "variable_created": [],
    #             "variable_modified": [],
    #             "function_called": [],
    #             "exception_raised": []
    #         }

    #     def enter(self) -None):
            """Enter the context (activate)."""
    #         with self._lock:
    #             if self.state != ContextState.CREATED:
                    raise ContextError(f"Cannot enter context in state: {self.state.value}")

    self.state = ContextState.ACTIVE
    self.stats.started_at = time.time()
    self._start_time = time.time()

    #             # Add to parent if exists
    #             if self.parent:
                    self.parent._children.append(self)

    #     def exit(self) -None):
            """Exit the context (deactivate)."""
    #         with self._lock:
    #             if self.state != ContextState.ACTIVE:
    #                 return

    self.state = ContextState.COMPLETED
    self.stats.completed_at = time.time()
    self.stats.execution_time = time.time() - self._start_time

    #             # Exit all children
    #             for child in self._children:
    #                 if child.state == ContextState.ACTIVE:
                        child.exit()

    #     def suspend(self) -None):
    #         """Suspend the context."""
    #         with self._lock:
    #             if self.state != ContextState.ACTIVE:
                    raise ContextError(f"Cannot suspend context in state: {self.state.value}")

    self.state = ContextState.SUSPENDED

    #     def resume(self) -None):
    #         """Resume a suspended context."""
    #         with self._lock:
    #             if self.state != ContextState.SUSPENDED:
                    raise ContextError(f"Cannot resume context in state: {self.state.value}")

    self.state = ContextState.ACTIVE

    #     def set_variable(self, name: str, value: Any) -None):
    #         """
    #         Set a variable in the context.

    #         Args:
    #             name: Variable name
    #             value: Variable value
    #         """
    #         with self._lock:
    #             if self.state != ContextState.ACTIVE:
                    raise ContextError(f"Cannot set variable in state: {self.state.value}")

    #             # Check if variable already exists
    is_new = name not in self._variables

    #             # Set variable
    self._variables[name] = value

    #             # Update stats
    #             if is_new:
    self.stats.variables_created + = 1
                    self._trigger_event("variable_created", {"name": name, "value": value})
    #             else:
                    self._trigger_event("variable_modified", {"name": name, "value": value})

    #             # Check memory usage
                self._update_memory_usage()

    #     def get_variable(self, name: str, default: Any = None) -Any):
    #         """
    #         Get a variable from the context.

    #         Args:
    #             name: Variable name
    #             default: Default value if not found

    #         Returns:
    #             Variable value or default
    #         """
    #         with self._lock:
    #             # Check current context
    #             if name in self._variables:
    #                 return self._variables[name]

    #             # Check parent context
    #             if self.parent:
                    return self.parent.get_variable(name, default)

    #             return default

    #     def has_variable(self, name: str) -bool):
    #         """
    #         Check if a variable exists in the context.

    #         Args:
    #             name: Variable name

    #         Returns:
    #             True if variable exists
    #         """
    #         with self._lock:
                return name in self._variables or (self.parent and self.parent.has_variable(name))

    #     def delete_variable(self, name: str) -None):
    #         """
    #         Delete a variable from the context.

    #         Args:
    #             name: Variable name
    #         """
    #         with self._lock:
    #             if self.state != ContextState.ACTIVE:
                    raise ContextError(f"Cannot delete variable in state: {self.state.value}")

    #             if name in self._variables:
    #                 del self._variables[name]
                    self._update_memory_usage()
    #             elif self.parent and self.parent.has_variable(name):
                    self.parent.delete_variable(name)

    #     def set_function(self, name: str, func: callable) -None):
    #         """
    #         Set a function in the context.

    #         Args:
    #             name: Function name
    #             func: Function object
    #         """
    #         with self._lock:
    #             if self.state != ContextState.ACTIVE:
                    raise ContextError(f"Cannot set function in state: {self.state.value}")

    self._functions[name] = func

    #     def get_function(self, name: str) -Optional[callable]):
    #         """
    #         Get a function from the context.

    #         Args:
    #             name: Function name

    #         Returns:
    #             Function object or None
    #         """
    #         with self._lock:
    #             # Check current context
    #             if name in self._functions:
    #                 return self._functions[name]

    #             # Check parent context
    #             if self.parent:
                    return self.parent.get_function(name)

    #             return None

    #     def add_import(self, module_name: str) -None):
    #         """
    #         Add an import to the context.

    #         Args:
    #             module_name: Module name
    #         """
    #         with self._lock:
    #             if self.state != ContextState.ACTIVE:
                    raise ContextError(f"Cannot add import in state: {self.state.value}")

                self._imports.add(module_name)

    #     def get_imports(self) -Set[str]):
    #         """
    #         Get all imports in the context.

    #         Returns:
    #             Set of module names
    #         """
    #         with self._lock:
    #             # Get imports from current context
    imports = self._imports.copy()

    #             # Add imports from parent context
    #             if self.parent:
                    imports.update(self.parent.get_imports())

    #             return imports

    #     def create_child(self, scope: ContextScope = ContextScope.FUNCTION,
    limits: Optional[ResourceLimits] = None) -'ExecutionContext'):
    #         """
    #         Create a child context.

    #         Args:
    #             scope: Scope level of the child context
    #             limits: Resource limits for the child context

    #         Returns:
    #             Child context
    #         """
    #         with self._lock:
    child = ExecutionContext(
    scope = scope,
    parent = self,
    limits = limits or self.limits
    #             )
    #             return child

    #     def get_all_variables(self) -Dict[str, Any]):
    #         """
    #         Get all variables in the context hierarchy.

    #         Returns:
    #             Dictionary of all variables
    #         """
    #         with self._lock:
    #             # Get variables from current context
    variables = self._variables.copy()

    #             # Add variables from parent context
    #             if self.parent:
    parent_vars = self.parent.get_all_variables()
    #                 # Don't override current context variables
    #                 for name, value in parent_vars.items():
    #                     if name not in variables:
    variables[name] = value

    #             return variables

    #     def check_limits(self) -None):
    #         """Check if resource limits are exceeded."""
    #         # Check execution time
    #         if self._start_time 0):
    execution_time = time.time() - self._start_time
    #             if execution_time self.limits.max_execution_time):
                    raise ResourceLimitError(f"Execution time limit exceeded: {execution_time:.2f}s")

    #         # Check memory usage
    #         if self._memory_usage self.limits.max_memory_mb):
                raise ResourceLimitError(f"Memory limit exceeded: {self._memory_usage:.2f}MB")

    #     def _update_memory_usage(self) -None):
    #         """Update memory usage estimate."""
    #         # This is a simplified estimation
    #         # In a real implementation, this would use more sophisticated tracking
    #         import sys

    total_size = 0
    #         for name, value in self._variables.items():
    total_size + = sys.getsizeof(value)

    self._memory_usage = total_size / (1024 * 1024  # Convert to MB)
    self.stats.memory_usage_mb = self._memory_usage

    #     def increment_instruction_count(self) -None):
    #         """Increment the instruction counter."""
    #         with self._lock:
    self.stats.instructions_executed + = 1

    #     def increment_function_call_count(self) -None):
    #         """Increment the function call counter."""
    #         with self._lock:
    self.stats.functions_called + = 1
                self._trigger_event("function_called", {})

    #     def increment_exception_count(self, exception: Exception) -None):
    #         """
    #         Increment the exception counter.

    #         Args:
    #             exception: The exception that was raised
    #         """
    #         with self._lock:
    self.stats.exceptions_raised + = 1
                self._trigger_event("exception_raised", {"exception": str(exception)})

    #     def add_event_handler(self, event: str, handler: callable) -None):
    #         """
    #         Add an event handler.

    #         Args:
    #             event: Event name
    #             handler: Handler function
    #         """
    #         with self._lock:
    #             if event in self._event_handlers:
                    self._event_handlers[event].append(handler)

    #     def remove_event_handler(self, event: str, handler: callable) -None):
    #         """
    #         Remove an event handler.

    #         Args:
    #             event: Event name
    #             handler: Handler function
    #         """
    #         with self._lock:
    #             if event in self._event_handlers and handler in self._event_handlers[event]:
                    self._event_handlers[event].remove(handler)

    #     def _trigger_event(self, event: str, data: Dict[str, Any]) -None):
    #         """
    #         Trigger an event.

    #         Args:
    #             event: Event name
    #             data: Event data
    #         """
    #         if event in self._event_handlers:
    #             for handler in self._event_handlers[event]:
    #                 try:
                        handler(data)
    #                 except Exception as e:
    #                     self.logger.error(f"Error in event handler for {event}: {str(e)}")

    #     def get_stats(self) -ExecutionContextStats):
    #         """
    #         Get execution statistics.

    #         Returns:
    #             Execution statistics
    #         """
    #         with self._lock:
    #             # Update current stats
    #             if self.state == ContextState.ACTIVE and self._start_time 0):
    self.stats.execution_time = time.time() - self._start_time

    #             return self.stats

    #     def reset_stats(self) -None):
    #         """Reset execution statistics."""
    #         with self._lock:
    self.stats = ExecutionContextStats()
    #             self._start_time = time.time() if self.state == ContextState.ACTIVE else 0

    #     def cleanup(self) -None):
    #         """Clean up resources."""
    #         with self._lock:
    #             # Exit if active
    #             if self.state == ContextState.ACTIVE:
                    self.exit()

    #             # Clean up children
    #             for child in self._children:
                    child.cleanup()

    #             # Clear data
                self._variables.clear()
                self._functions.clear()
                self._imports.clear()
                self._children.clear()
    #             self._event_handlers = {k: [] for k in self._event_handlers}


class ContextManager
    #     """
    #     Manages multiple execution contexts.

    #     This class provides a registry for execution contexts and
    #     utilities for context management.
    #     """

    #     def __init__(self):""Initialize context manager."""
    self._contexts: Dict[str, ExecutionContext] = {}
    self._global_context: Optional[ExecutionContext] = None
    self.logger = logging.getLogger(__name__)

    #     def create_global_context(self, limits: Optional[ResourceLimits] = None) -ExecutionContext):
    #         """
    #         Create the global context.

    #         Args:
    #             limits: Resource limits for the global context

    #         Returns:
    #             Global context
    #         """
    #         if self._global_context:
    #             return self._global_context

    self._global_context = ExecutionContext(
    context_id = "global",
    scope = ContextScope.GLOBAL,
    limits = limits
    #         )
    self._contexts["global"] = self._global_context
    #         return self._global_context

    #     def get_global_context(self) -ExecutionContext):
    #         """
    #         Get the global context.

    #         Returns:
    #             Global context
    #         """
    #         if not self._global_context:
                return self.create_global_context()
    #         return self._global_context

    #     def create_context(self, scope: ContextScope = ContextScope.FUNCTION,
    parent: Optional[ExecutionContext] = None,
    limits: Optional[ResourceLimits] = None) - ExecutionContext):
    #         """
    #         Create a new context.

    #         Args:
    #             scope: Scope level of the context
    #             parent: Parent context
    #             limits: Resource limits

    #         Returns:
    #             New context
    #         """
    context = ExecutionContext(
    scope = scope,
    parent = parent or self.get_global_context(),
    limits = limits
    #         )
    self._contexts[context.context_id] = context
    #         return context

    #     def get_context(self, context_id: str) -Optional[ExecutionContext]):
    #         """
    #         Get a context by ID.

    #         Args:
    #             context_id: Context ID

    #         Returns:
    #             Context or None
    #         """
            return self._contexts.get(context_id)

    #     def remove_context(self, context_id: str) -None):
    #         """
    #         Remove a context.

    #         Args:
    #             context_id: Context ID
    #         """
    #         if context_id in self._contexts:
    context = self._contexts[context_id]
                context.cleanup()
    #             del self._contexts[context_id]

    #     def get_all_contexts(self) -List[ExecutionContext]):
    #         """
    #         Get all contexts.

    #         Returns:
    #             List of all contexts
    #         """
            return list(self._contexts.values())

    #     def cleanup(self) -None):
    #         """Clean up all contexts."""
    #         for context in self._contexts.values():
                context.cleanup()
            self._contexts.clear()
    self._global_context = None

    #     @contextmanager
    #     def context_scope(self, scope: ContextScope = ContextScope.FUNCTION,
    parent: Optional[ExecutionContext] = None,
    limits: Optional[ResourceLimits] = None):
    #         """
    #         Context manager for creating and using a context.

    #         Args:
    #             scope: Scope level of the context
    #             parent: Parent context
    #             limits: Resource limits

    #         Yields:
    #             ExecutionContext
    #         """
    context = self.create_context(scope, parent, limits)
            context.enter()
    #         try:
    #             yield context
    #         finally:
                context.exit()