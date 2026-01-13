# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Runtime Value Operations for Noodle Language
# --------------------------------------------
# Provides operations on runtime values and conversions.
# Handles variable declaration, assignment, and memory management.
# """

import time
import threading
import weakref
import typing.Any,
import .runtime_types.Value,


class ValueOperations
    #     """Provides operations on runtime values"""

    #     @staticmethod
    #     def python_to_value(python_value: Any) -> Value:
    #         """Convert Python value to Noodle Value"""
    #         if python_value is None:
                return Value(RuntimeType.NONE, None)
    #         elif isinstance(python_value, bool):
                return Value(RuntimeType.BOOLEAN, python_value)
    #         elif isinstance(python_value, int):
                return Value(RuntimeType.INTEGER, python_value)
    #         elif isinstance(python_value, float):
                return Value(RuntimeType.FLOAT, python_value)
    #         elif isinstance(python_value, str):
                return Value(RuntimeType.STRING, python_value)
    #         elif isinstance(python_value, list):
                return Value(RuntimeType.LIST, python_value)
    #         elif isinstance(python_value, dict):
                return Value(RuntimeType.DICT, python_value)
    #         else:
                raise ExecutionError(f"Cannot convert Python type {type(python_value).__name__} to Noodle value")

    #     @staticmethod
    #     def value_to_python(value: Value) -> Any:
    #         """Convert Noodle Value to Python value"""
    #         return value.data

    #     @staticmethod
    #     def binary_operation(left: Value, right: Value, operator: str) -> Value:
    #         """Perform binary operation between two values"""
    #         # Type checking
    #         if left.type != right.type:
                raise ExecutionError(f"Cannot perform {operator} on {left.type} and {right.type}")

    #         # Perform operation
    #         if operator == '+':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(left.type, left.data + right.data)
    #             elif left.type == RuntimeType.STRING:
                    return Value(RuntimeType.STRING, left.data + right.data)
    #             elif left.type == RuntimeType.LIST:
                    return Value(RuntimeType.LIST, left.data + right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '-':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(left.type, left.data - right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '*':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(left.type, left.data * right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '/':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(RuntimeType.FLOAT, left.data / right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '//':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(RuntimeType.INTEGER, left.data // right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '%':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(left.type, left.data % right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '**':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(left.type, left.data ** right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '==':
    return Value(RuntimeType.BOOLEAN, left = = right)

    #         elif operator == '!=':
    return Value(RuntimeType.BOOLEAN, left ! = right)

    #         elif operator == '<':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(RuntimeType.BOOLEAN, left.data < right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '<=':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
    return Value(RuntimeType.BOOLEAN, left.data < = right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '>':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(RuntimeType.BOOLEAN, left.data > right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == '>=':
    #             if left.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
    return Value(RuntimeType.BOOLEAN, left.data > = right.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {left.type}")

    #         elif operator == 'and':
                return Value(RuntimeType.BOOLEAN, left.truthy() and right.truthy())

    #         elif operator == 'or':
                return Value(RuntimeType.BOOLEAN, left.truthy() or right.truthy())

    #         else:
                raise ExecutionError(f"Unknown binary operator: {operator}")

    #     @staticmethod
    #     def unary_operation(operand: Value, operator: str) -> Value:
    #         """Perform unary operation on a value"""
    #         if operator == '-':
    #             if operand.type in [RuntimeType.INTEGER, RuntimeType.FLOAT]:
                    return Value(operand.type, -operand.data)
    #             else:
                    raise ExecutionError(f"Cannot perform {operator} on {operand.type}")

    #         elif operator in ['!', 'not']:
                return Value(RuntimeType.BOOLEAN, not operand.truthy())

    #         else:
                raise ExecutionError(f"Unknown unary operator: {operator}")

    #     @staticmethod
    #     def get_attribute(obj: Value, attr_name: str) -> Value:
    #         """Get attribute from object"""
    #         if obj.type == RuntimeType.INSTANCE:
    instance = obj.data
                return instance.get_attribute(attr_name)

    #         elif obj.type == RuntimeType.MODULE:
    module = obj.data
    #             if hasattr(module, attr_name):
    attr_value = getattr(module, attr_name)
                    return ValueOperations.python_to_value(attr_value)
    #             else:
                    raise ExecutionError(f"Module '{module.__name__}' has no attribute '{attr_name}'")

    #         elif obj.type == RuntimeType.CLASS:
    cls = obj.data
    method = cls.get_method(attr_name)
    #             if method:
                    return Value(RuntimeType.FUNCTION, method)
    #             else:
                    raise ExecutionError(f"Class '{cls.name}' has no method '{attr_name}'")

    #         else:
                raise ExecutionError(f"Cannot access attributes on {obj.type}")

    #     @staticmethod
    #     def set_attribute(obj: Value, attr_name: str, value: Value) -> None:
    #         """Set attribute on object"""
    #         if obj.type == RuntimeType.INSTANCE:
    instance = obj.data
                instance.set_attribute(attr_name, value)
    #         else:
                raise ExecutionError(f"Cannot assign to attributes on {obj.type}")

    #     @staticmethod
    #     def get_index(obj: Value, index: Value) -> Value:
    #         """Get item from object by index"""
    #         if obj.type == RuntimeType.LIST:
    #             if index.type != RuntimeType.INTEGER:
                    raise ExecutionError("List index must be integer")
    #             try:
                    return ValueOperations.python_to_value(obj.data[index.data])
    #             except IndexError:
                    raise ExecutionError("List index out of range")

    #         elif obj.type == RuntimeType.DICT:
    #             if index.type not in [RuntimeType.STRING, RuntimeType.INTEGER]:
                    raise ExecutionError("Dict index must be string or integer")
    #             try:
                    return ValueOperations.python_to_value(obj.data[index.data])
    #             except KeyError:
                    raise ExecutionError(f"Dict key '{index.data}' not found")

    #         elif obj.type == RuntimeType.STRING:
    #             if index.type != RuntimeType.INTEGER:
                    raise ExecutionError("String index must be integer")
    #             try:
                    return Value(RuntimeType.STRING, obj.data[index.data])
    #             except IndexError:
                    raise ExecutionError("String index out of range")

    #         else:
                raise ExecutionError(f"Cannot index into {obj.type}")

    #     @staticmethod
    #     def set_index(obj: Value, index: Value, value: Value) -> None:
    #         """Set item in object by index"""
    #         if obj.type == RuntimeType.LIST:
    #             if index.type != RuntimeType.INTEGER:
                    raise ExecutionError("List index must be integer")
    #             try:
    obj.data[index.data] = value.data
    #             except IndexError:
                    raise ExecutionError("List index out of range")

    #         elif obj.type == RuntimeType.DICT:
    #             if index.type not in [RuntimeType.STRING, RuntimeType.INTEGER]:
                    raise ExecutionError("Dict index must be string or integer")
    obj.data[index.data] = value.data

    #         else:
                raise ExecutionError(f"Cannot assign to index of {obj.type}")

    #     @staticmethod
    #     def call_function(func: Value, arguments: list[Value], runtime: "RuntimeEnvironment") -> Value:
    #         """Call a function"""
    #         if func.type != RuntimeType.FUNCTION:
                raise ExecutionError(f"Cannot call non-function of type {func.type}")

    #         # Call function
            return func.data.call(arguments, runtime)

    #     @staticmethod
    #     def create_list(elements: list[Value]) -> Value:
    #         """Create a list from element values"""
    #         data = [elem.data for elem in elements]
            return Value(RuntimeType.LIST, data)

    #     @staticmethod
    #     def create_dict(pairs: list[tuple]) -> Value:
    #         """Create a dictionary from key-value pairs"""
    data = {}
    #         for key, value in pairs:
    #             if isinstance(key, Value):
    #                 if key.type != RuntimeType.STRING:
                        raise ExecutionError("Dictionary keys must be strings")
    data[key.data] = value.data
    #             else:
    #                 # Key is already a Python value
    data[key] = value.data

            return Value(RuntimeType.DICT, data)


class ExecutionError(Exception)
    #     """Exception raised during execution"""
    #     pass


class VariableEnvironment
    #     """Manages variable scope and storage"""

    #     def __init__(self, parent: Optional['VariableEnvironment'] = None):
    self.parent = parent
    self.variables: Dict[str, Value] = {}
    self.constants: Set[str] = set()
    self._lock = threading.RLock()
    self._variable_history: Dict[str, List[Value]] = {}
    self._creation_time = time.time()
    self._last_access: Dict[str, float] = {}
    self._access_count: Dict[str, int] = {}

    #         # Memory management
    self._weak_refs: Dict[str, weakref.ref] = {}
    self._max_history_size = 100
    self._cleanup_threshold = 0.9

    #     def declare_variable(self, name: str, value: Value, constant: bool = False) -> None:
    #         """Declare a new variable"""
    #         with self._lock:
    #             if name in self.variables:
                    raise ExecutionError(f"Variable '{name}' already declared")

    self.variables[name] = value

    #             if constant:
                    self.constants.add(name)

    #             # Track history
    #             if name not in self._variable_history:
    self._variable_history[name] = []
                self._variable_history[name].append(value)

    #             # Limit history size
    #             if len(self._variable_history[name]) > self._max_history_size:
    self._variable_history[name] = math.subtract(self._variable_history[name][, self._max_history_size:])

    #             # Track access
    self._last_access[name] = time.time()
    self._access_count[name] = 1

    #             # Create weak reference
    self._weak_refs[name] = weakref.ref(value)

    #     def set_variable(self, name: str, value: Value, force: bool = False) -> None:
    #         """Set an existing variable"""
    #         with self._lock:
    #             if name in self.constants and not force:
                    raise ExecutionError(f"Cannot assign to constant '{name}'")

    #             # Find the scope where the variable is defined
    env = self
    #             while env:
    #                 if name in env.variables:
    env.variables[name] = value

    #                     # Update history
    #                     if name not in env._variable_history:
    env._variable_history[name] = []
                        env._variable_history[name].append(value)

    #                     # Limit history size
    #                     if len(env._variable_history[name]) > self._max_history_size:
    env._variable_history[name] = math.subtract(env._variable_history[name][, self._max_history_size:])

    #                     # Update access tracking
    env._last_access[name] = time.time()
    env._access_count[name] = math.add(env._access_count.get(name, 0), 1)

    #                     # Update weak reference
    env._weak_refs[name] = weakref.ref(value)
    #                     return
    env = env.parent

    #             # Variable not found in any scope
                raise ExecutionError(f"Variable '{name}' not found")

    #     def get_variable(self, name: str) -> Value:
    #         """Get a variable value"""
    #         with self._lock:
    env = self
    #             while env:
    #                 if name in env.variables:
    #                     # Update access tracking
    env._last_access[name] = time.time()
    env._access_count[name] = math.add(env._access_count.get(name, 0), 1)
    #                     return env.variables[name]
    env = env.parent

    #             # Variable not found
                raise ExecutionError(f"Variable '{name}' not found")

    #     def has_variable(self, name: str) -> bool:
    #         """Check if a variable exists"""
    env = self
    #         while env:
    #             if name in env.variables:
    #                 return True
    env = env.parent
    #         return False

    #     def delete_variable(self, name: str) -> None:
    #         """Delete a variable"""
    #         with self._lock:
    env = self
    #             while env:
    #                 if name in env.variables:
    #                     del env.variables[name]
    #                     if name in env.constants:
                            env.constants.remove(name)
    #                     if name in env._variable_history:
    #                         del env._variable_history[name]
    #                     if name in env._last_access:
    #                         del env._last_access[name]
    #                     if name in env._access_count:
    #                         del env._access_count[name]
    #                     if name in env._weak_refs:
    #                         del env._weak_refs[name]
    #                     return
    env = env.parent

                raise ExecutionError(f"Variable '{name}' not found")

    #     def get_all_variables(self) -> Dict[str, Value]:
    #         """Get all variables in this scope and parent scopes"""
    variables = {}
    env = self
    #         while env:
    #             for name, value in env.variables.items():
    #                 if name not in variables:  # Only get the first occurrence (closest scope)
    variables[name] = value
    env = env.parent
    #         return variables

    #     def get_variable_info(self, name: str) -> Dict[str, Any]:
    #         """Get information about a variable"""
    env = self
    #         while env:
    #             if name in env.variables:
    #                 return {
    #                     'name': name,
    #                     'value': env.variables[name],
    #                     'constant': name in env.constants,
    #                     'declared_at': env._creation_time,
                        'last_access': env._last_access.get(name, 0),
                        'access_count': env._access_count.get(name, 0),
                        'history_size': len(env._variable_history.get(name, [])),
    #                 }
    env = env.parent

            raise ExecutionError(f"Variable '{name}' not found")

    #     def get_variable_history(self, name: str) -> List[Value]:
    #         """Get the history of variable values"""
    env = self
    #         while env:
    #             if name in env.variables:
                    return env._variable_history[name].copy()
    env = env.parent

            raise ExecutionError(f"Variable '{name}' not found")

    #     def cleanup_unused_variables(self, threshold: float = 3600.0) -> int:
    #         """Clean up variables that haven't been accessed recently"""
    cleaned_count = 0

    #         def _cleanup_recursive(env: VariableEnvironment) -> int:
    #             nonlocal cleaned_count
    current_time = time.time()

    #             # Find unused variables
    unused_vars = []
    #             for name in env.variables:
    #                 if name not in env.constants:
    last_access = env._last_access.get(name, 0)
    #                     if current_time - last_access > threshold:
                            unused_vars.append(name)

    #             # Remove unused variables
    #             for name in unused_vars:
    #                 del env.variables[name]
    #                 if name in env.constants:
                        env.constants.remove(name)
    #                 if name in env._variable_history:
    #                     del env._variable_history[name]
    #                 if name in env._last_access:
    #                     del env._last_access[name]
    #                 if name in env._access_count:
    #                     del env._access_count[name]
    #                 if name in env._weak_refs:
    #                     del env._weak_refs[name]
    cleaned_count + = 1

    #             # Recursively clean parent scopes
    #             if env.parent:
                    _cleanup_recursive(env.parent)

    #             return cleaned_count

            return _cleanup_recursive(self)

    #     def get_memory_usage(self) -> Dict[str, Any]:
    #         """Get memory usage statistics"""
    total_variables = 0
    total_constants = 0
    total_memory = 0

    #         def _collect_stats(env: VariableEnvironment) -> None:
    #             nonlocal total_variables, total_constants, total_memory
    total_variables + = len(env.variables)
    total_constants + = len(env.constants)

    #             # Estimate memory usage
    #             for value in env.variables.values():
    total_memory + = sys.getsizeof(value)

            _collect_stats(self)

    #         return {
    #             'total_variables': total_variables,
    #             'total_constants': total_constants,
    #             'memory_bytes': total_memory,
    #             'history_size': sum(len(h) for h in self._variable_history.values()),
                'access_count': sum(self._access_count.values()),
    #         }

    #     def create_child_scope(self) -> 'VariableEnvironment':
    #         """Create a new child scope"""
            return VariableEnvironment(self)

    #     def get_scope_depth(self) -> int:
    #         """Get the depth of this scope"""
    depth = 0
    env = self
    #         while env:
    depth + = 1
    env = env.parent
    #         return depth

    #     def get_scope_info(self) -> Dict[str, Any]:
    #         """Get information about the current scope"""
    #         return {
                'depth': self.get_scope_depth(),
                'variables_count': len(self.variables),
                'constants_count': len(self.constants),
    #             'parent_scope': self.parent is not None,
                'memory_usage': self.get_memory_usage(),
    #         }

    #     def export_variables(self, names: Optional[List[str]] = None) -> Dict[str, Value]:
    #         """Export variables to a dictionary"""
    #         if names is None:
                return self.get_all_variables()

    exported = {}
    #         for name in names:
    #             try:
    exported[name] = self.get_variable(name)
    #             except ExecutionError:
    #                 pass  # Skip variables that don't exist
    #         return exported

    #     def import_variables(self, variables: Dict[str, Value], constants: bool = False) -> None:
    #         """Import variables from a dictionary"""
    #         for name, value in variables.items():
    self.declare_variable(name, value, constant = constants)

    #     def clear_all_variables(self) -> None:
            """Clear all variables in this scope (but not parent scopes)"""
    #         with self._lock:
                self.variables.clear()
                self.constants.clear()
                self._variable_history.clear()
                self._last_access.clear()
                self._access_count.clear()
                self._weak_refs.clear()

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get comprehensive statistics about variable usage"""
    stats = {
                'scope_info': self.get_scope_info(),
                'memory_usage': self.get_memory_usage(),
                'variable_count': len(self.variables),
                'constant_count': len(self.constants),
    #             'most_accessed': [],
    #             'oldest_variables': [],
    #             'recently_accessed': [],
    #         }

    #         # Sort variables by access count
    sorted_by_access = sorted(
                self._access_count.items(),
    key = lambda x: x[1],
    reverse = True
    #         )
    stats['most_accessed'] = sorted_by_access[:10]

    #         # Sort variables by last access time
    sorted_by_time = sorted(
                self._last_access.items(),
    key = lambda x: x[1]
    #         )
    stats['oldest_variables'] = sorted_by_time[:10]

    #         # Get recently accessed variables
    current_time = time.time()
    recent_threshold = math.subtract(current_time, 60  # Last minute)
    recent_vars = [
                (name, self._access_count[name])
    #             for name, last_time in self._last_access.items()
    #             if last_time >= recent_threshold
    #         ]
    stats['recently_accessed'] = recent_vars

    #         return stats
