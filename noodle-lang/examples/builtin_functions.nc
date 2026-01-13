# Converted from Python to NoodleCore
# Original file: src

# """
# Built-in Functions Module for NBC Runtime
# ----------------------------------------
# This module implements built-in functions for NBC runtime.
# It provides essential functions that are available in all NBC programs.
# """

import time
import math
import random
import json
import typing.Any

import .config.NBCConfig
import .error_handling.ErrorHandler
import .errors.NBCRuntimeError


class BuiltInFunctions
    #     """
    #     Built-in functions for NBC runtime.
    #     Provides essential functions that are available in all NBC programs.
    #     """

    #     def __init__(self, config: NBCConfig = None):""
    #         Initialize built-in functions.

    #         Args:
    #             config: Runtime configuration
    #         """
    self.config = config or NBCConfig()
    self.is_debug = getattr(self.config, 'debug_mode', False)

    #         # Error handler
    self.error_handler = create_error_handler(self.config)

    #         # Built-in functions registry
    self.builtin_functions = {
    #             # Basic I/O
    #             "print": self._builtin_print,
    #             "input": self._builtin_input,

    #             # Type conversion
    #             "str": self._builtin_str,
    #             "int": self._builtin_int,
    #             "float": self._builtin_float,
    #             "bool": self._builtin_bool,

    #             # Collection functions
    #             "len": self._builtin_len,
    #             "range": self._builtin_range,
    #             "enumerate": self._builtin_enumerate,
    #             "zip": self._builtin_zip,

    #             # Math functions
    #             "abs": self._builtin_abs,
    #             "round": self._builtin_round,
    #             "min": self._builtin_min,
    #             "max": self._builtin_max,
    #             "sum": self._builtin_sum,
    #             "pow": self._builtin_pow,
    #             "sqrt": self._builtin_sqrt,

    #             # Random functions
    #             "random": self._builtin_random,
    #             "randint": self._builtin_randint,
    #             "choice": self._builtin_choice,
    #             "shuffle": self._builtin_shuffle,

    #             # Time functions
    #             "time": self._builtin_time,
    #             "sleep": self._builtin_sleep,

    #             # String functions
    #             "upper": self._builtin_upper,
    #             "lower": self._builtin_lower,
    #             "startswith": self._builtin_startswith,
    #             "endswith": self._builtin_endswith,
    #             "contains": self._builtin_contains,
    #             "split": self._builtin_split,
    #             "join": self._builtin_join,

    #             # List functions
    #             "append": self._builtin_append,
    #             "extend": self._builtin_extend,
    #             "insert": self._builtin_insert,
    #             "remove": self._builtin_remove,
    #             "pop": self._builtin_pop,
    #             "index": self._builtin_index,
    #             "count": self._builtin_count,

    #             # Dictionary functions
    #             "keys": self._builtin_keys,
    #             "values": self._builtin_values,
    #             "items": self._builtin_items,
    #             "get": self._builtin_get,
    #             "update": self._builtin_update,

    #             # JSON functions
    #             "json_loads": self._builtin_json_loads,
    #             "json_dumps": self._builtin_json_dumps,

    #             # System functions
    #             "type": self._builtin_type,
    #             "isinstance": self._builtin_isinstance,
    #             "hasattr": self._builtin_hasattr,
    #             "getattr": self._builtin_getattr,
    #             "setattr": self._builtin_setattr,
    #             "delattr": self._builtin_delattr,
    #             "dir": self._builtin_dir,
    #             "globals": self._builtin_globals,
    #             "locals": self._builtin_locals,
    #         }

    #     def get_builtin_function(self, name: str) -Optional[Callable]):
    #         """
    #         Get a built-in function by name.

    #         Args:
    #             name: Name of the function

    #         Returns:
    #             Function or None if not found
    #         """
            return self.builtin_functions.get(name)

    #     def has_builtin_function(self, name: str) -bool):
    #         """
    #         Check if a built-in function exists.

    #         Args:
    #             name: Name of the function

    #         Returns:
    #             True if function exists, False otherwise
    #         """
    #         return name in self.builtin_functions

    #     def list_builtin_functions(self) -List[str]):
    #         """
    #         Get list of all built-in function names.

    #         Returns:
    #             List of function names
    #         """
            return list(self.builtin_functions.keys())

    #     def call_builtin_function(self, name: str, args: List[Any] = None,
    kwargs: Dict[str, Any] = None) - Any):
    #         """
    #         Call a built-in function.

    #         Args:
    #             name: Name of the function
    #             args: List of arguments
    #             kwargs: Dictionary of keyword arguments

    #         Returns:
    #             Function result
    #         """
    #         if not self.has_builtin_function(name):
                raise NBCRuntimeError(f"Built-in function not found: {name}")

    func = self.get_builtin_function(name)

    #         try:
    #             if kwargs:
                    return func(*args or [], **kwargs)
    #             else:
                    return func(*args or [])
    #         except Exception as e:
                self.error_handler.handle_error(e, {"function": name, "args": args, "kwargs": kwargs})
                raise NBCRuntimeError(f"Error calling built-in function {name}: {e}")

    #     # Basic I/O functions
    #     def _builtin_print(self, *args, sep: str = " ", end: str = "\n", file=None, flush=False):
    #         """Built-in print function."""
    print(*args, sep = sep, end=end, file=file, flush=flush)

    #     def _builtin_input(self, prompt: str = "") -str):
    #         """Built-in input function."""
            return input(prompt)

    #     # Type conversion functions
    #     def _builtin_str(self, obj: Any) -str):
    #         """Convert to string."""
            return str(obj)

    #     def _builtin_int(self, obj: Any) -int):
    #         """Convert to integer."""
            return int(obj)

    #     def _builtin_float(self, obj: Any) -float):
    #         """Convert to float."""
            return float(obj)

    #     def _builtin_bool(self, obj: Any) -bool):
    #         """Convert to boolean."""
            return bool(obj)

    #     # Collection functions
    #     def _builtin_len(self, obj: Any) -int):
    #         """Get length of object."""
            return len(obj)

    #     def _builtin_range(self, *args) -range):
    #         """Generate range of numbers."""
    #         if len(args) == 1:
                return range(args[0])
    #         elif len(args) == 2:
                return range(args[0], args[1])
    #         elif len(args) == 3:
                return range(args[0], args[1], args[2])
    #         else:
                raise NBCRuntimeError("range() takes 1-3 arguments")

    #     def _builtin_enumerate(self, iterable, start: int = 0):
    #         """Enumerate over iterable."""
            return enumerate(iterable, start)

    #     def _builtin_zip(self, *iterables):
    #         """Zip multiple iterables."""
            return zip(*iterables)

    #     # Math functions
    #     def _builtin_abs(self, x: Union[int, float]) -Union[int, float]):
    #         """Absolute value."""
            return abs(x)

    #     def _builtin_round(self, number: float, ndigits: Optional[int] = None) -Union[int, float]):
    #         """Round number."""
            return round(number, ndigits)

    #     def _builtin_min(self, *args) -Any):
    #         """Minimum value."""
    #         if args:
                return min(args)
    #         else:
                raise NBCRuntimeError("min() takes at least 1 argument")

    #     def _builtin_max(self, *args) -Any):
    #         """Maximum value."""
    #         if args:
                return max(args)
    #         else:
                raise NBCRuntimeError("max() takes at least 1 argument")

    #     def _builtin_sum(self, iterable, start: Any = 0) -Any):
    #         """Sum of values."""
            return sum(iterable, start)

    #     def _builtin_pow(self, base: Union[int, float], exp: Union[int, float],
    mod: Optional[Union[int, float]] = None) - Union[int, float]):
    #         """Power function."""
    #         if mod is not None:
                return pow(base, exp, mod)
    #         else:
                return pow(base, exp)

    #     def _builtin_sqrt(self, x: Union[int, float]) -float):
    #         """Square root."""
            return math.sqrt(x)

    #     # Random functions
    #     def _builtin_random(self) -float):
    #         """Random float between 0.0 and 1.0."""
            return random.random()

    #     def _builtin_randint(self, a: int, b: int) -int):
    #         """Random integer between a and b."""
            return random.randint(a, b)

    #     def _builtin_choice(self, seq):
    #         """Choose random element from sequence."""
            return random.choice(seq)

    #     def _builtin_shuffle(self, seq):
    #         """Shuffle sequence in place."""
            random.shuffle(seq)

    #     # Time functions
    #     def _builtin_time(self) -float):
    #         """Current time in seconds."""
            return time.time()

    #     def _builtin_sleep(self, seconds: Union[int, float]):
    #         """Sleep for specified seconds."""
            time.sleep(seconds)

    #     # String functions
    #     def _builtin_upper(self, s: str) -str):
    #         """Convert to uppercase."""
            return s.upper()

    #     def _builtin_lower(self, s: str) -str):
    #         """Convert to lowercase."""
            return s.lower()

    #     def _builtin_startswith(self, s: str, prefix: str) -bool):
    #         """Check if string starts with prefix."""
            return s.startswith(prefix)

    #     def _builtin_endswith(self, s: str, suffix: str) -bool):
    #         """Check if string ends with suffix."""
            return s.endswith(suffix)

    #     def _builtin_contains(self, container, item) -bool):
    #         """Check if container contains item."""
    #         return item in container

    #     def _builtin_split(self, s: str, sep: Optional[str] = None, maxsplit: int = -1) -List[str]):
    #         """Split string."""
            return s.split(sep, maxsplit)

    #     def _builtin_join(self, iterable, sep: str = "") -str):
    #         """Join strings."""
            return sep.join(iterable)

    #     # List functions
    #     def _builtin_append(self, lst: List, item: Any) -None):
    #         """Append item to list."""
            lst.append(item)

    #     def _builtin_extend(self, lst: List, items: List) -None):
    #         """Extend list with items."""
            lst.extend(items)

    #     def _builtin_insert(self, lst: List, index: int, item: Any) -None):
    #         """Insert item at index."""
            lst.insert(index, item)

    #     def _builtin_remove(self, lst: List, item: Any) -None):
    #         """Remove item from list."""
            lst.remove(item)

    #     def _builtin_pop(self, lst: List, index: int = -1) -Any):
    #         """Pop item from list."""
            return lst.pop(index)

    #     def _builtin_index(self, lst: List, item: Any, start: int = 0, stop: int = None) -int):
    #         """Find index of item."""
    #         if stop is None:
                return lst.index(item, start)
    #         else:
                return lst.index(item, start, stop)

    #     def _builtin_count(self, lst: List, item: Any) -int):
    #         """Count occurrences of item."""
            return lst.count(item)

    #     # Dictionary functions
    #     def _builtin_keys(self, d: Dict) -List):
    #         """Get dictionary keys."""
            return list(d.keys())

    #     def _builtin_values(self, d: Dict) -List):
    #         """Get dictionary values."""
            return list(d.values())

    #     def _builtin_items(self, d: Dict) -List):
    #         """Get dictionary items."""
            return list(d.items())

    #     def _builtin_get(self, d: Dict, key: Any, default: Any = None) -Any):
    #         """Get value from dictionary."""
            return d.get(key, default)

    #     def _builtin_update(self, d: Dict, other: Dict) -None):
    #         """Update dictionary."""
            d.update(other)

    #     # JSON functions
    #     def _builtin_json_loads(self, s: str) -Any):
    #         """Load JSON string."""
            return json.loads(s)

    #     def _builtin_json_dumps(self, obj: Any, indent: Optional[int] = None) -str):
    #         """Dump to JSON string."""
    return json.dumps(obj, indent = indent)

    #     # System functions
    #     def _builtin_type(self, obj: Any) -type):
    #         """Get type of object."""
            return type(obj)

    #     def _builtin_isinstance(self, obj: Any, class_info: Union[type, tuple]) -bool):
    #         """Check if object is instance of class."""
            return isinstance(obj, class_info)

    #     def _builtin_hasattr(self, obj: Any, name: str) -bool):
    #         """Check if object has attribute."""
            return hasattr(obj, name)

    #     def _builtin_getattr(self, obj: Any, name: str, default: Any = None) -Any):
    #         """Get attribute from object."""
            return getattr(obj, name, default)

    #     def _builtin_setattr(self, obj: Any, name: str, value: Any) -None):
    #         """Set attribute on object."""
            setattr(obj, name, value)

    #     def _builtin_delattr(self, obj: Any, name: str) -None):
    #         """Delete attribute from object."""
            delattr(obj, name)

    #     def _builtin_dir(self, obj: Any = None) -List[str]):
    #         """Get attributes of object."""
    #         return dir(obj) if obj is not None else dir()

    #     def _builtin_globals(self) -Dict[str, Any]):
    #         """Get global variables."""
            return globals()

    #     def _builtin_locals(self) -Dict[str, Any]):
    #         """Get local variables."""
            return locals()

    #     def add_builtin_function(self, name: str, func: Callable) -None):
    #         """
    #         Add a custom built-in function.

    #         Args:
    #             name: Name of the function
    #             func: Function to add
    #         """
    self.builtin_functions[name] = func

    #     def remove_builtin_function(self, name: str) -None):
    #         """
    #         Remove a built-in function.

    #         Args:
    #             name: Name of the function to remove
    #         """
    #         if name in self.builtin_functions:
    #             del self.builtin_functions[name]

    #     def clear_builtin_functions(self) -None):
    #         """Clear all built-in functions."""
            self.builtin_functions.clear()


def create_builtin_functions(config: NBCConfig = None) -BuiltInFunctions):
#     """
#     Create a new built-in functions instance.

#     Args:
#         config: Runtime configuration

#     Returns:
#         BuiltInFunctions instance
#     """
    return BuiltInFunctions(config)


__all__ = ["BuiltInFunctions", "create_builtin_functions"]
