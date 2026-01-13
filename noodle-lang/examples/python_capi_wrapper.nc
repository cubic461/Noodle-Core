# Converted from Python to NoodleCore
# Original file: src

# """
# Python C API Wrapper for Noodle
# -------------------------------
# Provides a robust interface between Noodle and Python C API.
# Handles type conversion, exception management, and function calls.
# """

import ctypes
import sys
import traceback
import threading
import time
import typing.Any
import ..runtime_types.RuntimeType

# Load Python C API
try
    #     if sys.platform == "win32":
    python_lib = ctypes.pythonapi
    #     else:
    python_lib = ctypes.CDLL(None)
except Exception as e
        raise RuntimeError(f"Failed to load Python C API: {e}")


class PythonCAPIWrapper
    #     """Wrapper for Python C API functionality"""

    #     def __init__(self):
    #         # Initialize Python C API types
            self._init_types()
    #         # Initialize Python C API functions
            self._init_functions()
    #         # Type conversion cache
    self._type_cache: Dict[RuntimeType, Any] = {}
    #         # Exception handling state
    self._exception_state: Optional[Exception] = None
    #         # Thread safety
    self._lock = threading.RLock()
    #         # Performance metrics
    self._call_count = 0
    self._total_time = 0.0
    self._exception_count = 0
    #         # Allowed modules and functions
    self._allowed_modules = set()
    self._allowed_functions = set()
    #         # Module cache for performance
    self._module_cache: Dict[str, Any] = {}
    #         # Function cache for performance
    self._function_cache: Dict[str, Callable] = {}

    #     def _init_types(self):
    #         """Initialize Python C API types"""
    #         # Basic Python types
    self.PyObject = ctypes.py_object
    self.PyObjectPtr = ctypes.POINTER(self.PyObject)

    #         # Type objects
    self.PyTypeObject = ctypes.py_object
    self.PyTypeObjectPtr = ctypes.POINTER(self.PyTypeObject)

    #         # Integer types
    self.Py_ssize_t = ctypes.c_ssize_t

    #         # String types
    self.Py_UNICODE = ctypes.c_wchar
    self.Py_UNICODEPtr = ctypes.POINTER(self.Py_UNICODE)

    #     def _init_functions(self):
    #         """Initialize Python C API functions with proper signatures"""
    #         # Basic object functions
    self.Py_IncRef = python_lib.Py_IncRef
    self.Py_IncRef.argtypes = [self.PyObjectPtr]
    self.Py_IncRef.restype = None

    self.Py_DecRef = python_lib.Py_DecRef
    self.Py_DecRef.argtypes = [self.PyObjectPtr]
    self.Py_DecRef.restype = None

    #         # Object creation
    self.Py_None = python_lib.Py_None
    self.Py_None.restype = self.PyObjectPtr

    #         # Type checking
    self.PyLong_Check = python_lib.PyLong_Check
    self.PyLong_Check.argtypes = [self.PyObjectPtr]
    self.PyLong_Check.restype = ctypes.c_int

    self.PyFloat_Check = python_lib.PyFloat_Check
    self.PyFloat_Check.argtypes = [self.PyObjectPtr]
    self.PyFloat_Check.restype = ctypes.c_int

    self.PyString_Check = python_lib.PyString_Check
    self.PyString_Check.argtypes = [self.PyObjectPtr]
    self.PyString_Check.restype = ctypes.c_int

    self.PyList_Check = python_lib.PyList_Check
    self.PyList_Check.argtypes = [self.PyObjectPtr]
    self.PyList_Check.restype = ctypes.c_int

    self.PyDict_Check = python_lib.PyDict_Check
    self.PyDict_Check.argtypes = [self.PyObjectPtr]
    self.PyDict_Check.restype = ctypes.c_int

    #         # Object creation
    self.PyLong_FromLong = python_lib.PyLong_FromLong
    self.PyLong_FromLong.argtypes = [ctypes.c_long]
    self.PyLong_FromLong.restype = self.PyObjectPtr

    self.PyLong_FromLongLong = python_lib.PyLong_FromLongLong
    self.PyLong_FromLongLong.argtypes = [ctypes.c_longlong]
    self.PyLong_FromLongLong.restype = self.PyObjectPtr

    self.PyFloat_FromDouble = python_lib.PyFloat_FromDouble
    self.PyFloat_FromDouble.argtypes = [ctypes.c_double]
    self.PyFloat_FromDouble.restype = self.PyObjectPtr

    self.PyString_FromString = python_lib.PyString_FromString
    self.PyString_FromString.argtypes = [ctypes.c_char_p]
    self.PyString_FromString.restype = self.PyObjectPtr

    self.PyList_New = python_lib.PyList_New
    self.PyList_New.argtypes = [self.Py_ssize_t]
    self.PyList_New.restype = self.PyObjectPtr

    self.PyDict_New = python_lib.PyDict_New
    self.PyDict_New.restype = self.PyObjectPtr

    #         # Object access
    self.PyLong_AsLong = python_lib.PyLong_AsLong
    self.PyLong_AsLong.argtypes = [self.PyObjectPtr]
    self.PyLong_AsLong.restype = ctypes.c_long

    self.PyLong_AsLongLong = python_lib.PyLong_AsLongLong
    self.PyLong_AsLongLong.argtypes = [self.PyObjectPtr]
    self.PyLong_AsLongLong.restype = ctypes.c_longlong

    self.PyFloat_AsDouble = python_lib.PyFloat_AsDouble
    self.PyFloat_AsDouble.argtypes = [self.PyObjectPtr]
    self.PyFloat_AsDouble.restype = ctypes.c_double

    #         # List operations
    self.PyList_Size = python_lib.PyList_Size
    self.PyList_Size.argtypes = [self.PyObjectPtr]
    self.PyList_Size.restype = self.Py_ssize_t

    self.PyList_GetItem = python_lib.PyList_GetItem
    self.PyList_GetItem.argtypes = [self.PyObjectPtr, self.Py_ssize_t]
    self.PyList_GetItem.restype = self.PyObjectPtr

    self.PyList_SetItem = python_lib.PyList_SetItem
    self.PyList_SetItem.argtypes = [self.PyObjectPtr, self.Py_ssize_t, self.PyObjectPtr]
    self.PyList_SetItem.restype = ctypes.c_int

    #         # Dict operations
    self.PyDict_Size = python_lib.PyDict_Size
    self.PyDict_Size.argtypes = [self.PyObjectPtr]
    self.PyDict_Size.restype = self.Py_ssize_t

    self.PyDict_GetItemString = python_lib.PyDict_GetItemString
    self.PyDict_GetItemString.argtypes = [self.PyObjectPtr, ctypes.c_char_p]
    self.PyDict_GetItemString.restype = self.PyObjectPtr

    self.PyDict_SetItemString = python_lib.PyDict_SetItemString
    self.PyDict_SetItemString.argtypes = [self.PyObjectPtr, ctypes.c_char_p, self.PyObjectPtr]
    self.PyDict_SetItemString.restype = ctypes.c_int

    #         # Exception handling
    self.PyErr_ExceptionMatches = python_lib.PyErr_ExceptionMatches
    self.PyErr_ExceptionMatches.argtypes = [self.PyTypeObjectPtr]
    self.PyErr_ExceptionMatches.restype = ctypes.c_int

    self.PyErr_Print = python_lib.PyErr_Print
    self.PyErr_Print.argtypes = []
    self.PyErr_Print.restype = None

    #     def python_to_noodle(self, python_obj: Any) -Value):
    #         """Convert Python object to Noodle Value"""
    #         if python_obj is None:
                return Value(RuntimeType.NONE, None)
    #         elif isinstance(python_obj, bool):
                return Value(RuntimeType.BOOLEAN, python_obj)
    #         elif isinstance(python_obj, int):
                return Value(RuntimeType.INTEGER, python_obj)
    #         elif isinstance(python_obj, float):
                return Value(RuntimeType.FLOAT, python_obj)
    #         elif isinstance(python_obj, str):
                return Value(RuntimeType.STRING, python_obj)
    #         elif isinstance(python_obj, list):
    #             return Value(RuntimeType.LIST, [self.python_to_noodle(item) for item in python_obj])
    #         elif isinstance(python_obj, dict):
    #             return Value(RuntimeType.DICT, {k: self.python_to_noodle(v) for k, v in python_obj.items()})
    #         else:
    #             # For complex objects, create a generic wrapper
                return Value(RuntimeType.OBJECT, python_obj)

    #     def noodle_to_python(self, noodle_value: Value) -Any):
    #         """Convert Noodle Value to Python object"""
    #         if noodle_value.type == RuntimeType.NONE:
    #             return None
    #         elif noodle_value.type == RuntimeType.BOOLEAN:
                return bool(noodle_value.data)
    #         elif noodle_value.type == RuntimeType.INTEGER:
                return int(noodle_value.data)
    #         elif noodle_value.type == RuntimeType.FLOAT:
                return float(noodle_value.data)
    #         elif noodle_value.type == RuntimeType.STRING:
                return str(noodle_value.data)
    #         elif noodle_value.type == RuntimeType.LIST:
    #             return [self.noodle_to_python(item) for item in noodle_value.data]
    #         elif noodle_value.type == RuntimeType.DICT:
    #             return {k: self.noodle_to_python(v) for k, v in noodle_value.data.items()}
    #         else:
    #             # For complex types, return the raw data
    #             return noodle_value.data

    #     def call_python_function(self, func: Callable, args: List[Value]) -Value):
    #         """Call a Python function with Noodle arguments"""
    #         with self._lock:
    start_time = time.time()
    self._call_count + = 1

    #             try:
    #                 # Convert Noodle arguments to Python arguments
    #                 python_args = [self.noodle_to_python(arg) for arg in args]

    #                 # Call the Python function
    result = func( * python_args)

    #                 # Convert result back to Noodle Value
    noodle_result = self.python_to_noodle(result)

    #                 # Update performance metrics
    execution_time = time.time() - start_time
    self._total_time + = execution_time

    #                 return noodle_result

    #             except Exception as e:
    #                 # Handle exceptions gracefully
    error_msg = f"Python function call failed: {str(e)}"
    self._exception_state = Exception(error_msg)
    self._exception_count + = 1
                    return Value(RuntimeType.STRING, error_msg)

    #     def get_exception_state(self) -Optional[Exception]):
    #         """Get current exception state"""
    #         return self._exception_state

    #     def clear_exception_state(self):
    #         """Clear exception state"""
    self._exception_state = None

    #     def check_python_exception(self) -bool):
    #         """Check if a Python exception occurred"""
    #         # This is a simplified check - in a real implementation,
    #         # we would use Python C API functions to check for exceptions
    #         return self._exception_state is not None

    #     def set_allowed_modules(self, modules: Set[str]):
    #         """Set allowed Python modules"""
    self._allowed_modules = set(modules)

    #     def set_allowed_functions(self, functions: Set[str]):
    #         """Set allowed Python functions"""
    self._allowed_functions = set(functions)

    #     def is_module_allowed(self, module_name: str) -bool):
    #         """Check if a module is allowed"""
    #         return not self._allowed_modules or module_name in self._allowed_modules

    #     def is_function_allowed(self, function_name: str) -bool):
    #         """Check if a function is allowed"""
    #         return not self._allowed_functions or function_name in self._allowed_functions

    #     def get_cached_module(self, module_name: str) -Optional[Any]):
    #         """Get a cached module"""
            return self._module_cache.get(module_name)

    #     def cache_module(self, module_name: str, module: Any):
    #         """Cache a module"""
    self._module_cache[module_name] = module

    #     def get_cached_function(self, function_name: str) -Optional[Callable]):
    #         """Get a cached function"""
            return self._function_cache.get(function_name)

    #     def cache_function(self, function_name: str, func: Callable):
    #         """Cache a function"""
    self._function_cache[function_name] = func

    #     def get_performance_metrics(self) -Dict[str, Any]):
    #         """Get performance metrics"""
    #         avg_time = self._total_time / self._call_count if self._call_count 0 else 0
    #         return {
    #             "call_count"): self._call_count,
    #             "total_time": self._total_time,
    #             "average_time": avg_time,
    #             "exception_count": self._exception_count,
    #             "exception_rate": self._exception_count / self._call_count if self._call_count 0 else 0,
                "cache_size"): len(self._module_cache) + len(self._function_cache),
                "allowed_modules": len(self._allowed_modules),
                "allowed_functions": len(self._allowed_functions),
    #         }

    #     def clear_cache(self):
    #         """Clear all caches"""
            self._module_cache.clear()
            self._function_cache.clear()

    #     def reset_metrics(self):
    #         """Reset performance metrics"""
    self._call_count = 0
    self._total_time = 0.0
    self._exception_count = 0

    #     def call_with_exception_handling(self, func: Callable, args: List[Value]) -Value):
    #         """Call a Python function with enhanced exception handling"""
    #         try:
    #             # Check function cache first
    func_name = getattr(func, "__name__", str(func))
    cached_func = self.get_cached_function(func_name)

    #             if cached_func is not None:
    func = cached_func

    #             # Call the function
    result = self.call_python_function(func, args)

    #             # Cache the function if not already cached
    #             if cached_func is None:
                    self.cache_function(func_name, func)

    #             return result

    #         except Exception as e:
    #             # Enhanced exception handling
    error_msg = f"Enhanced Python function call failed: {str(e)}"
    self._exception_state = Exception(error_msg)
    self._exception_count + = 1

    #             # Log the full traceback for debugging
    traceback_str = traceback.format_exc()
                print(f"Full traceback: {traceback_str}")

                return Value(RuntimeType.STRING, error_msg)

    #     def create_python_object(self, obj_type: str, *args: Any) -Optional[Any]):
    #         """Create a Python object of the specified type"""
    #         try:
    #             if obj_type == "list":
                    return list(args)
    #             elif obj_type == "dict":
                    return dict(args)
    #             elif obj_type == "set":
                    return set(args)
    #             elif obj_type == "tuple":
                    return tuple(args)
    #             elif obj_type == "str":
    #                 return str(args[0]) if args else ""
    #             elif obj_type == "int":
    #                 return int(args[0]) if args else 0
    #             elif obj_type == "float":
    #                 return float(args[0]) if args else 0.0
    #             elif obj_type == "bool":
    #                 return bool(args[0]) if args else False
    #             else:
    #                 # Try to create using the type constructor
    python_type = __import__(obj_type)
                    return python_type(*args)

    #         except Exception as e:
    error_msg = f"Failed to create Python object of type {obj_type}: {str(e)}"
    self._exception_state = Exception(error_msg)
    #             return None

    #     def get_python_type_info(self, obj: Any) -Dict[str, Any]):
    #         """Get type information about a Python object"""
    #         try:
    #             return {
                    "type": type(obj).__name__,
                    "module": type(obj).__module__,
    #                 "methods": [method for method in dir(obj) if not method.startswith('_')],
    #                 "attributes": [attr for attr in dir(obj) if not attr.startswith('_')],
                    "value": str(obj),
    #                 "size": len(obj) if hasattr(obj, '__len__') else None,
    #                 "hashable": obj.__hash__ is not None,
    #             }
    #         except Exception as e:
    error_msg = f"Failed to get type info: {str(e)}"
    self._exception_state = Exception(error_msg)
    #             return {"error": error_msg}


# Global instance
_python_capi_wrapper = None

def get_python_capi_wrapper() -PythonCAPIWrapper):
#     """Get the global Python C API wrapper instance"""
#     global _python_capi_wrapper
#     if _python_capi_wrapper is None:
_python_capi_wrapper = PythonCAPIWrapper()
#     return _python_capi_wrapper
