# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Python FFI Module for NBC Runtime
# --------------------------------
This module handles Python Foreign Function Interface (FFI) operations.
# It provides functionality to load Python modules and call Python functions.
# """

import sys
import traceback
import typing.Any,

import ...compiler.code_generator.BytecodeInstruction
import .config.NBCConfig
import .error_handler.ErrorHandler
import .errors.NBCRuntimeError,


class PythonFFI
    #     """
    #     Python Foreign Function Interface for NBC runtime.
    #     Handles loading Python modules and calling Python functions.
    #     """

    #     def __init__(self, config: NBCConfig = None):
    #         """
    #         Initialize Python FFI.

    #         Args:
    #             config: Runtime configuration
    #         """
    self.config = config or NBCConfig()
    self.is_debug = getattr(self.config, 'debug_mode', False)

    #         # Python modules dictionary
    self.python_modules: Dict[str, Any] = {}

    #         # Python functions dictionary
    self.python_functions: Dict[str, Callable] = {}

    #         # Constants pool
    self.constants_pool: Dict[str, str] = {}

    #         # Allowed modules for security
    self.allowed_modules = {
    #             "math", "random", "datetime", "json", "os", "sys",
    #             "numpy", "scipy", "pandas", "matplotlib", "sklearn"
    #         }

    #         # Error handler
    self.error_handler = ErrorHandler()

    #         # Initialize Python FFI environment
            self.init_python_ffi()

    #     def init_python_ffi(self):
    #         """Initialize Python FFI environment."""
    #         # Initialize Python modules dictionary
    self.python_modules = {}

    #         # Initialize Python functions dictionary
    self.python_functions = {}

    #         # Initialize constants pool
    self.constants_pool = {}

    #         # Pre-load allowed modules
            self._preload_allowed_modules()

    #     def _preload_allowed_modules(self):
    #         """Pre-load allowed Python modules."""
    #         for module_name in self.allowed_modules:
    #             try:
    module = self._load_python_module(module_name)
    #                 if module:
    self.python_modules[module_name] = module

    #                     # Cache functions via introspection
                        self._cache_module_functions(module_name, module)

    #                     if self.is_debug:
                            print(f"Pre-loaded Python module: {module_name}")
    #             except Exception as e:
    #                 if self.is_debug:
                        print(f"Warning: Could not preload Python module {module_name}: {e}")

    #     def _load_python_module(self, module_name: str) -> Optional[Any]:
    #         """
    #         Load a Python module.

    #         Args:
    #             module_name: Name of the module to load

    #         Returns:
    #             Loaded module or None if failed
    #         """
    #         try:
                __import__(module_name)
                return sys.modules.get(module_name)
    #         except ImportError as e:
    #             if self.is_debug:
                    print(f"Failed to import module {module_name}: {e}")
    #             return None

    #     def _cache_module_functions(self, module_name: str, module: Any):
    #         """
    #         Cache functions from a module.

    #         Args:
    #             module_name: Name of the module
    #             module: The module object
    #         """
    #         try:
    #             for attr_name in dir(module):
    attr = getattr(module, attr_name)
    #                 if callable(attr):
    func_name = f"{module_name}.{attr_name}"
    self.python_functions[func_name] = attr
    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Warning: Could not cache functions from {module_name}: {e}")

    #     def python_import(self, operands: List) -> Any:
    #         """
    #         Execute Python import operation.

    #         Args:
    #             operands: List of operands, first should be module name

    #         Returns:
    #             Loaded module or None
    #         """
    #         if not operands or not isinstance(operands[0], str):
                raise PythonFFIError("Python import requires module name operand")

    module_name = operands[0]

    #         # Security check
    #         if module_name not in self.allowed_modules:
                raise PythonFFIError(f"Module {module_name} not in allowed modules")

    #         try:
    #             # Try to get from cache first
    #             if module_name in self.python_modules:
    module = self.python_modules[module_name]
    #                 if self.is_debug:
                        print(f"Using cached module: {module_name}")
    #             else:
    #                 # Load module
    module = self._load_python_module(module_name)
    #                 if module:
    self.python_modules[module_name] = module
                        self._cache_module_functions(module_name, module)
    #                     if self.is_debug:
                            print(f"Successfully imported Python module: {module_name}")
    #                 else:
                        raise PythonFFIError(f"Failed to import module {module_name}")

    #             return module

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Failed to import module {module_name}: {e}")
                    print(f"Stack trace: {traceback.format_exc()}")
                raise PythonFFIError(f"Failed to import module {module_name}: {e}")

    #     def python_call(self, operands: List) -> Any:
    #         """
    #         Execute Python function call operation.

    #         Args:
    #             operands: List of operands, first should be function name

    #         Returns:
    #             Function result or None
    #         """
    #         if not operands or not isinstance(operands[0], str):
                raise PythonFFIError("Python call requires function name operand")

    func_name = operands[0]

    #         # Parse function name as module.func
    #         if "." in func_name:
    module_name, actual_func_name = func_name.rsplit(".", 1)
    #         else:
    module_name = None
    actual_func_name = func_name

    #         # Extract arguments from operands
    args = []
    kwargs = {}

    #         if len(operands) > 1:
    #             num_args = operands[1] if isinstance(operands[1], int) else 0

                # Extract arguments from stack (this would be handled by the runtime)
    #             # For now, we'll assume args are provided in operands
    arg_start = 2
    #             for i in range(num_args):
    #                 if arg_start + i < len(operands):
                        args.append(operands[arg_start + i])

    #         try:
    #             # Get function reference
    #             if module_name:
    #                 # Call function from module
    #                 if module_name in self.python_modules:
    module = self.python_modules[module_name]
    #                     if hasattr(module, actual_func_name):
    func = getattr(module, actual_func_name)
    result = math.multiply(func(, args, **kwargs))

    #                         if self.is_debug:
                                print(f"Successfully called Python function: {func_name}")

    #                         return result
    #                     else:
                            raise PythonFFIError(f"Function {actual_func_name} not found in module {module_name}")
    #                 else:
                        raise PythonFFIError(f"Module {module_name} not loaded")
    #             else:
    #                 # Call cached function
    #                 if func_name in self.python_functions:
    func = self.python_functions[func_name]
    result = math.multiply(func(, args, **kwargs))

    #                     if self.is_debug:
                            print(f"Successfully called Python function: {func_name}")

    #                     return result
    #                 else:
                        raise PythonFFIError(f"Python function not found: {func_name}")

    #         except Exception as e:
    #             if self.is_debug:
    #                 print(f"Python function call failed for {func_name}: {e}")
                    print(f"Stack trace: {traceback.format_exc()}")
    #             raise PythonFFIError(f"Python function call failed for {func_name}: {e}")

    #     def get_module_info(self, module_name: str) -> Dict[str, Any]:
    #         """
    #         Get information about a loaded module.

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             Dictionary with module information
    #         """
    #         if module_name not in self.python_modules:
    #             return {"error": f"Module {module_name} not loaded"}

    module = self.python_modules[module_name]

    #         # Get module attributes
    attributes = []
    functions = []

    #         for attr_name in dir(module):
    attr = getattr(module, attr_name)
    #             if callable(attr):
                    functions.append(attr_name)
    #             else:
                    attributes.append(attr_name)

    #         return {
    #             "name": module_name,
    #             "loaded": True,
    #             "attributes": attributes,
    #             "functions": functions,
    #             "module_object": module
    #         }

    #     def get_function_info(self, func_name: str) -> Dict[str, Any]:
    #         """
    #         Get information about a cached function.

    #         Args:
    #             func_name: Name of the function

    #         Returns:
    #             Dictionary with function information
    #         """
    #         if func_name not in self.python_functions:
    #             return {"error": f"Function {func_name} not found"}

    func = self.python_functions[func_name]

    #         try:
    #             # Get function signature
    #             import inspect
    sig = inspect.signature(func)

    #             return {
    #                 "name": func_name,
    #                 "callable": True,
                    "signature": str(sig),
                    "docstring": inspect.getdoc(func),
    #                 "function_object": func
    #             }
    #         except Exception as e:
    #             return {
    #                 "name": func_name,
    #                 "callable": True,
    #                 "error": f"Could not get function info: {e}",
    #                 "function_object": func
    #             }

    #     def add_allowed_module(self, module_name: str):
    #         """
    #         Add a module to the allowed modules list.

    #         Args:
    #             module_name: Name of the module to allow
    #         """
    #         if module_name not in self.allowed_modules:
                self.allowed_modules.add(module_name)

    #             # Try to load the module
    #             try:
    module = self._load_python_module(module_name)
    #                 if module:
    self.python_modules[module_name] = module
                        self._cache_module_functions(module_name, module)

    #                     if self.is_debug:
                            print(f"Successfully added and loaded module: {module_name}")
    #                 else:
    #                     # Module added but not loaded
    #                     if self.is_debug:
                            print(f"Module {module_name} allowed but not loaded")
    #             except Exception as e:
    #                 if self.is_debug:
                        print(f"Warning: Could not load allowed module {module_name}: {e}")

    #     def remove_allowed_module(self, module_name: str):
    #         """
    #         Remove a module from the allowed modules list.

    #         Args:
    #             module_name: Name of the module to disallow
    #         """
    #         if module_name in self.allowed_modules:
                self.allowed_modules.remove(module_name)

    #             # Remove from cache if loaded
    #             if module_name in self.python_modules:
    #                 del self.python_modules[module_name]

    #                 # Remove cached functions
    #                 functions_to_remove = [f"{module_name}.{func}" for func in dir(self.python_modules.get(module_name, {}))
    #                                      if callable(getattr(self.python_modules.get(module_name), func, None))]

    #                 for func_name in functions_to_remove:
    #                     if func_name in self.python_functions:
    #                         del self.python_functions[func_name]

    #                 if self.is_debug:
                        print(f"Removed module from cache: {module_name}")

    #     def get_allowed_modules(self) -> List[str]:
    #         """Get list of allowed modules."""
            return list(self.allowed_modules)

    #     def get_loaded_modules(self) -> List[str]:
    #         """Get list of loaded modules."""
            return list(self.python_modules.keys())

    #     def get_cached_functions(self) -> List[str]:
    #         """Get list of cached functions."""
            return list(self.python_functions.keys())

    #     def reset(self):
    #         """Reset Python FFI state."""
            self.python_modules.clear()
            self.python_functions.clear()
            self.constants_pool.clear()

    #         # Re-initialize
            self.init_python_ffi()


def create_python_ffi(config: NBCConfig = None) -> PythonFFI:
#     """
#     Create a new Python FFI instance.

#     Args:
#         config: Runtime configuration

#     Returns:
#         PythonFFI instance
#     """
    return PythonFFI(config)


__all__ = ["PythonFFI", "create_python_ffi", "PythonFFIError"]
