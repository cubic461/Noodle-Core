# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Built-in Functions
 = ==========================

# This module provides built-in functions for NoodleCore runtime.
# These functions are available in all NoodleCore programs without explicit import.
# """

import math
import random
import sys
import os
import typing.Any,
import datetime.datetime

import .language_constructs.NoodleFunction,
import .errors.NoodleTypeError,


class NoodleBuiltins
    #     """
    #     Container for all NoodleCore built-in functions.

    #     This class provides the standard library functions that are
    #     available in all NoodleCore programs.
    #     """

    #     def __init__(self):
    #         """Initialize built-in functions registry."""
    self._functions: Dict[str, Callable] = {}
            self._register_all_builtins()

    #     def _register_all_builtins(self):
    #         """Register all built-in functions."""
    #         # I/O functions
            self._register_function("print", self._builtin_print)
            self._register_function("input", self._builtin_input)

    #         # Type conversion functions
            self._register_function("int", self._builtin_int)
            self._register_function("float", self._builtin_float)
            self._register_function("str", self._builtin_str)
            self._register_function("bool", self._builtin_bool)
            self._register_function("list", self._builtin_list)
            self._register_function("dict", self._builtin_dict)

    #         # Mathematical functions
            self._register_function("abs", self._builtin_abs)
            self._register_function("min", self._builtin_min)
            self._register_function("max", self._builtin_max)
            self._register_function("sum", self._builtin_sum)
            self._register_function("len", self._builtin_len)
            self._register_function("range", self._builtin_range)

    #         # List operations
            self._register_function("append", self._builtin_append)
            self._register_function("extend", self._builtin_extend)
            self._register_function("pop", self._builtin_pop)
            self._register_function("sort", self._builtin_sort)
            self._register_function("reverse", self._builtin_reverse)

    #         # String operations
            self._register_function("upper", self._builtin_upper)
            self._register_function("lower", self._builtin_lower)
            self._register_function("strip", self._builtin_strip)
            self._register_function("split", self._builtin_split)
            self._register_function("join", self._builtin_join)

    #         # System functions
            self._register_function("exit", self._builtin_exit)
            self._register_function("time", self._builtin_time)
            self._register_function("random", self._builtin_random)
            self._register_function("type", self._builtin_type)

    #         # File operations
            self._register_function("open", self._builtin_open)
            self._register_function("read", self._builtin_read)
            self._register_function("write", self._builtin_write)

    #         # Debug functions
            self._register_function("debug", self._builtin_debug)
            self._register_function("assert", self._builtin_assert)

    #     def _register_function(self, name: str, func: Callable):
    #         """Register a built-in function."""
    self._functions[name] = func

    #     def get_builtin(self, name: str) -> Optional[Callable]:
    #         """
    #         Get a built-in function by name.

    #         Args:
    #             name: Function name

    #         Returns:
    #             Optional[Callable]: Function if found
    #         """
            return self._functions.get(name)

    #     def get_all_builtins(self) -> Dict[str, Callable]:
    #         """
    #         Get all built-in functions.

    #         Returns:
    #             Dict[str, Callable]: All registered functions
    #         """
            return self._functions.copy()

    #     # I/O Functions
    #     def _builtin_print(self, *args, sep: str = " ", end: str = "\n") -> None:
    #         """Print values to standard output."""
    print(*args, sep = sep, end=end)

    #     def _builtin_input(self, prompt: str = "") -> str:
    #         """Get input from user."""
            return input(prompt)

    #     # Type Conversion Functions
    #     def _builtin_int(self, value: Any) -> int:
    #         """Convert value to integer."""
    #         try:
                return int(value)
            except (ValueError, TypeError) as e:
                raise NoodleTypeError(f"Cannot convert {value} to int: {e}")

    #     def _builtin_float(self, value: Any) -> float:
    #         """Convert value to float."""
    #         try:
                return float(value)
            except (ValueError, TypeError) as e:
                raise NoodleTypeError(f"Cannot convert {value} to float: {e}")

    #     def _builtin_str(self, value: Any) -> str:
    #         """Convert value to string."""
            return str(value)

    #     def _builtin_bool(self, value: Any) -> bool:
    #         """Convert value to boolean."""
            return bool(value)

    #     def _builtin_list(self, *args) -> List[Any]:
    #         """Create a list from arguments."""
    #         if len(args) == 1 and hasattr(args[0], '__iter__'):
                return list(args[0])
            return list(args)

    #     def _builtin_dict(self, **kwargs) -> Dict[str, Any]:
    #         """Create a dictionary from keyword arguments."""
            return dict(kwargs)

    #     # Mathematical Functions
    #     def _builtin_abs(self, value: Any) -> Any:
    #         """Get absolute value."""
    #         try:
                return abs(value)
    #         except TypeError as e:
                raise NoodleTypeError(f"Cannot get absolute value of {value}: {e}")

    #     def _builtin_min(self, *args) -> Any:
    #         """Get minimum value."""
    #         if not args:
                raise NoodleValueError("min() requires at least one argument")
    #         try:
                return min(args)
    #         except TypeError as e:
                raise NoodleTypeError(f"Cannot compare values: {e}")

    #     def _builtin_max(self, *args) -> Any:
    #         """Get maximum value."""
    #         if not args:
                raise NoodleValueError("max() requires at least one argument")
    #         try:
                return max(args)
    #         except TypeError as e:
                raise NoodleTypeError(f"Cannot compare values: {e}")

    #     def _builtin_sum(self, iterable: List[Any]) -> Any:
    #         """Sum values in iterable."""
    #         try:
                return sum(iterable)
    #         except TypeError as e:
                raise NoodleTypeError(f"Cannot sum values: {e}")

    #     def _builtin_len(self, obj: Any) -> int:
    #         """Get length of object."""
    #         try:
                return len(obj)
    #         except TypeError as e:
                raise NoodleTypeError(f"Object of type {type(obj)} has no length: {e}")

    #     def _builtin_range(self, *args) -> List[int]:
    #         """Create a range of numbers."""
    #         try:
                return list(range(*args))
            except (TypeError, ValueError) as e:
                raise NoodleValueError(f"Invalid range arguments: {e}")

    #     # List Operations
    #     def _builtin_append(self, lst: List[Any], value: Any) -> List[Any]:
    #         """Append value to list."""
            NoodleType.ensure_type(lst, NoodleType.LIST, "lst")
            lst.append(value)
    #         return lst

    #     def _builtin_extend(self, lst: List[Any], other: List[Any]) -> List[Any]:
    #         """Extend list with another list."""
            NoodleType.ensure_type(lst, NoodleType.LIST, "lst")
            NoodleType.ensure_type(other, NoodleType.LIST, "other")
            lst.extend(other)
    #         return lst

    #     def _builtin_pop(self, lst: List[Any], index: int = -1) -> Any:
    #         """Pop element from list."""
            NoodleType.ensure_type(lst, NoodleType.LIST, "lst")
    #         try:
                return lst.pop(index)
    #         except IndexError as e:
                raise NoodleIndexError(f"Index {index} out of range: {e}")

    #     def _builtin_sort(self, lst: List[Any]) -> List[Any]:
    #         """Sort list."""
            NoodleType.ensure_type(lst, NoodleType.LIST, "lst")
    #         try:
                return sorted(lst)
    #         except TypeError as e:
                raise NoodleTypeError(f"Cannot sort list: {e}")

    #     def _builtin_reverse(self, lst: List[Any]) -> List[Any]:
    #         """Reverse list."""
            NoodleType.ensure_type(lst, NoodleType.LIST, "lst")
    #         return lst[::-1]

    #     # String Operations
    #     def _builtin_upper(self, s: str) -> str:
    #         """Convert string to uppercase."""
            NoodleType.ensure_type(s, NoodleType.STRING, "s")
            return s.upper()

    #     def _builtin_lower(self, s: str) -> str:
    #         """Convert string to lowercase."""
            NoodleType.ensure_type(s, NoodleType.STRING, "s")
            return s.lower()

    #     def _builtin_strip(self, s: str, chars: Optional[str] = None) -> str:
    #         """Strip characters from string."""
            NoodleType.ensure_type(s, NoodleType.STRING, "s")
            return s.strip(chars)

    #     def _builtin_split(self, s: str, sep: Optional[str] = None) -> List[str]:
    #         """Split string into list."""
            NoodleType.ensure_type(s, NoodleType.STRING, "s")
            return s.split(sep)

    #     def _builtin_join(self, sep: str, iterable: List[str]) -> str:
    #         """Join strings with separator."""
            NoodleType.ensure_type(sep, NoodleType.STRING, "sep")
    #         try:
                return sep.join(iterable)
    #         except TypeError as e:
                raise NoodleTypeError(f"Cannot join iterable: {e}")

    #     # System Functions
    #     def _builtin_exit(self, code: int = 0) -> None:
    #         """Exit the program."""
            NoodleType.ensure_type(code, NoodleType.INTEGER, "code")
            sys.exit(code)

    #     def _builtin_time(self) -> float:
    #         """Get current timestamp."""
            return datetime.now().timestamp()

    #     def _builtin_random(self, min_val: int = 0, max_val: int = 1) -> float:
    #         """Get random number in range."""
            NoodleType.ensure_type(min_val, NoodleType.INTEGER, "min_val")
            NoodleType.ensure_type(max_val, NoodleType.INTEGER, "max_val")
            return random.uniform(min_val, max_val)

    #     def _builtin_type(self, value: Any) -> str:
    #         """Get type name of value."""
            return NoodleType.get_type(value)

    #     # File Operations
    #     def _builtin_open(self, filename: str, mode: str = "r") -> Any:
    #         """Open a file."""
            NoodleType.ensure_type(filename, NoodleType.STRING, "filename")
            NoodleType.ensure_type(mode, NoodleType.STRING, "mode")
    #         try:
                return open(filename, mode)
    #         except IOError as e:
                raise NoodleRuntimeError(f"Cannot open file {filename}: {e}")

    #     def _builtin_read(self, file_obj: Any) -> str:
    #         """Read from file object."""
    #         try:
                return file_obj.read()
    #         except AttributeError as e:
                raise NoodleTypeError(f"Object is not a file: {e}")
    #         except IOError as e:
                raise NoodleRuntimeError(f"Cannot read from file: {e}")

    #     def _builtin_write(self, file_obj: Any, content: str) -> None:
    #         """Write to file object."""
            NoodleType.ensure_type(content, NoodleType.STRING, "content")
    #         try:
                file_obj.write(content)
    #         except AttributeError as e:
                raise NoodleTypeError(f"Object is not a file: {e}")
    #         except IOError as e:
                raise NoodleRuntimeError(f"Cannot write to file: {e}")

    #     # Debug Functions
    #     def _builtin_debug(self, *args) -> None:
    #         """Print debug information."""
    #         print(f"[DEBUG] {' '.join(str(arg) for arg in args)}")

    #     def _builtin_assert(self, condition: Any, message: str = "Assertion failed") -> None:
    #         """Assert condition is true."""
    #         if not condition:
                raise NoodleRuntimeError(f"Assertion failed: {message}")


# Create built-in function wrappers that can be called from NoodleCore
def create_builtin_function(name: str, builtin_func: Callable) -> NoodleFunction:
#     """
#     Create a NoodleFunction wrapper for a built-in function.

#     Args:
#         name: Function name
#         builtin_func: The built-in function to wrap

#     Returns:
#         NoodleFunction: Wrapped function
#     """
#     def wrapper(*args, **kwargs):
        return builtin_func(*args, **kwargs)

#     # Get parameter information from the function signature
sig = inspect.signature(builtin_func)
params = list(sig.parameters.keys())

#     # Create function with Python function reference
func = NoodleFunction(
name = name,
params = params,
body = f"<built-in function {name}>",
closure = {},
is_builtin = True
#     )

#     # Store the actual Python function for execution
func._python_func = builtin_func

#     return func


# Export built-in functions
__all__ = [
#     'NoodleBuiltins',
#     'create_builtin_function',
# ]