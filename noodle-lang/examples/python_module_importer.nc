# Converted from Python to NoodleCore
# Original file: src

# """
# Python Module Import System for Noodle
# --------------------------------------
# Provides functionality to import and use Python modules from Noodle.
# Handles namespace mapping and lazy loading.
# """

import sys
import importlib
import importlib.util
import threading
import time
import typing.Any
import .python_capi_wrapper.get_python_capi_wrapper
import ..runtime_types.RuntimeType


class PythonModuleImporter
    #     """Handles Python module imports for Noodle"""

    #     def __init__(self):
    #         # Cache for loaded modules
    self._module_cache: Dict[str, Any] = {}
    #         # Namespace mapping
    self._namespace_mapping: Dict[str, str] = {
    #             'math': 'math',
    #             'os': 'os',
    #             'sys': 'sys',
    #             'json': 'json',
    #             'datetime': 'datetime',
    #             'collections': 'collections',
    #             'itertools': 'itertools',
    #             'functools': 'functools',
    #             'operator': 'operator',
    #             'pathlib': 'pathlib',
    #             'typing': 'typing',
    #         }
    #         # Lazy loaded modules
    self._lazy_modules: Dict[str, str] = {}
    #         # API wrapper instance
    self._capi_wrapper = get_python_capi_wrapper()
    #         # Thread safety
    self._lock = threading.RLock()
    #         # Performance metrics
    self._import_count = 0
    self._total_time = 0.0
    self._error_count = 0
            # Allowed modules (security)
    self._allowed_modules: Set[str] = set()
            # Forbidden modules (security)
    self._forbidden_modules: Set[str] = set()
    #         # Module loading timeouts
    self._timeout = 30.0  # seconds
    #         # Module search paths
    self._search_paths: List[str] = []
    #         # Error handling mode
    self._error_mode = 'strict'  # 'strict', 'warn', 'ignore'
    #         # Module dependency tracking
    self._module_dependencies: Dict[str, List[str]] = {}

    #     def import_module(self, module_name: str, lazy: bool = True) -Optional[Any]):
    #         """
    #         Import a Python module

    #         Args:
    #             module_name: Name of the module to import
    #             lazy: Whether to lazy load the module

    #         Returns:
    #             The imported module or None if failed
    #         """
    #         # Check namespace mapping
    #         if module_name in self._namespace_mapping:
    actual_module_name = self._namespace_mapping[module_name]
    #         else:
    actual_module_name = module_name

    #         # Check cache first
    #         if actual_module_name in self._module_cache:
    #             return self._module_cache[actual_module_name]

    #         # Check if module is already loaded
    #         if actual_module_name in sys.modules:
    module = sys.modules[actual_module_name]
    self._module_cache[actual_module_name] = module
    #             return module

    #         # Lazy loading - just record the module name for later
    #         if lazy:
    self._lazy_modules[actual_module_name] = actual_module_name
    #             return None

    #         # Try to import the module
    #         try:
    module = importlib.import_module(actual_module_name)
    self._module_cache[actual_module_name] = module
    #             return module
    #         except ImportError as e:
                print(f"Failed to import module {actual_module_name}: {e}")
    #             return None
    #         except Exception as e:
                print(f"Unexpected error importing module {actual_module_name}: {e}")
    #             return None

    #     def get_module_attribute(self, module_name: str, attribute_name: str) -Optional[Value]):
    #         """
    #         Get an attribute from a Python module

    #         Args:
    #             module_name: Name of the module
    #             attribute_name: Name of the attribute

    #         Returns:
    #             The attribute as a Noodle Value or None if not found
    #         """
    #         # Import module if not already imported
    module = self.import_module(module_name, lazy=False)
    #         if module is None:
    #             return None

    #         # Get attribute
    #         try:
    attr = getattr(module, attribute_name)

    #             # Convert to Noodle Value based on type
    #             if callable(attr):
    #                 # Create a wrapper function
    #                 def wrapper(*args):
    #                     values = [arg if isinstance(arg, Value) else self._capi_wrapper.python_to_noodle(arg)
    #                              for arg in args]
                        return self._capi_wrapper.call_python_function(attr, values)

                    return Value(RuntimeType.FUNCTION, wrapper)
    #             elif isinstance(attr, (int, float, str, bool)):
                    return self._capi_wrapper.python_to_noodle(attr)
    #             elif isinstance(attr, (list, dict)):
                    return self._capi_wrapper.python_to_noodle(attr)
    #             else:
    #                 # For complex objects, create a generic wrapper
                    return Value(RuntimeType.OBJECT, attr)

    #         except AttributeError:
    #             return None
    #         except Exception as e:
                print(f"Error getting attribute {attribute_name} from module {module_name}: {e}")
    #             return None

    #     def set_module_attribute(self, module_name: str, attribute_name: str, value: Value) -bool):
    #         """
    #         Set an attribute in a Python module

    #         Args:
    #             module_name: Name of the module
    #             attribute_name: Name of the attribute
    #             value: Value to set

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         # Import module if not already imported
    module = self.import_module(module_name, lazy=False)
    #         if module is None:
    #             return False

    #         # Set attribute
    #         try:
    python_value = self._capi_wrapper.noodle_to_python(value)
                setattr(module, attribute_name, python_value)
    #             return True
    #         except Exception as e:
                print(f"Error setting attribute {attribute_name} in module {module_name}: {e}")
    #             return False

    #     def call_module_function(self, module_name: str, function_name: str, args: List[Value]) -Value):
    #         """
    #         Call a function from a Python module

    #         Args:
    #             module_name: Name of the module
    #             function_name: Name of the function
    #             args: Arguments as Noodle Values

    #         Returns:
    #             The result as a Noodle Value
    #         """
    #         # Get the function
    func_value = self.get_module_attribute(module_name, function_name)
    #         if func_value is None or func_value.type != RuntimeType.FUNCTION:
                return Value(RuntimeType.STRING, f"Function {function_name} not found in module {module_name}")

    #         # Call the function
    #         try:
    func = func_value.data
                return func(*args)
    #         except Exception as e:
    error_msg = f"Error calling function {function_name} from module {module_name}: {str(e)}"
                return Value(RuntimeType.STRING, error_msg)

    #     def get_module_functions(self, module_name: str) -Dict[str, Value]):
    #         """
    #         Get all functions from a Python module

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             Dictionary of function names to Function objects
    #         """
    #         # Import module if not already imported
    module = self.import_module(module_name, lazy=False)
    #         if module is None:
    #             return {}

    functions = {}
    #         for attr_name in dir(module):
    attr = getattr(module, attr_name)
    #             if callable(attr):
    #                 # Create a wrapper function
    #                 def wrapper(func=attr):
    #                     def inner(*args):
    #                         values = [arg if isinstance(arg, Value) else self._capi_wrapper.python_to_noodle(arg)
    #                                  for arg in args]
                            return self._capi_wrapper.call_python_function(func, values)
    #                     return inner
    functions[attr_name] = Value(RuntimeType.FUNCTION, wrapper(func))

    #         return functions

    #     def get_module_constants(self, module_name: str) -Dict[str, Value]):
    #         """
    #         Get all constants from a Python module

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             Dictionary of constant names to Values
    #         """
    #         # Import module if not already imported
    module = self.import_module(module_name, lazy=False)
    #         if module is None:
    #             return {}

    constants = {}
    #         for attr_name in dir(module):
    attr = getattr(module, attr_name)
    #             if not callable(attr):
    constants[attr_name] = self._capi_wrapper.python_to_noodle(attr)

    #         return constants

    #     def is_module_loaded(self, module_name: str) -bool):
    #         """
    #         Check if a module is loaded

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             True if loaded, False otherwise
    #         """
    #         # Check namespace mapping
    #         if module_name in self._namespace_mapping:
    actual_module_name = self._namespace_mapping[module_name]
    #         else:
    actual_module_name = module_name

    #         return actual_module_name in self._module_cache or actual_module_name in sys.modules

    #     def get_loaded_modules(self) -List[str]):
    #         """
    #         Get list of loaded modules

    #         Returns:
    #             List of module names
    #         """
    modules = list(self._module_cache.keys())

    #         # Add modules from sys.modules that we didn't explicitly load
    #         for module_name in sys.modules:
    #             if module_name not in self._module_cache and module_name not in modules:
                    modules.append(module_name)

    #         return modules

    #     def add_namespace_mapping(self, noodle_name: str, python_name: str):
    #         """
    #         Add a custom namespace mapping

    #         Args:
    #             noodle_name: Noodle module name
    #             python_name: Python module name
    #         """
    self._namespace_mapping[noodle_name] = python_name

    #     def remove_namespace_mapping(self, noodle_name: str):
    #         """
    #         Remove a namespace mapping

    #         Args:
    #             noodle_name: Noodle module name to remove
    #         """
    #         if noodle_name in self._namespace_mapping:
    #             del self._namespace_mapping[noodle_name]

    #     def set_allowed_modules(self, modules: Set[str]):
    #         """Set allowed modules for security"""
    self._allowed_modules = set(modules)

    #     def set_forbidden_modules(self, modules: Set[str]):
    #         """Set forbidden modules for security"""
    self._forbidden_modules = set(modules)

    #     def is_module_allowed(self, module_name: str) -bool):
    #         """Check if a module is allowed based on security rules"""
    #         # Check forbidden first
    #         if module_name in self._forbidden_modules:
    #             return False

    #         # Check allowed if set
    #         if self._allowed_modules:
    #             return module_name in self._allowed_modules

    #         # Default to allowed if no restrictions
    #         return True

    #     def set_timeout(self, timeout: float):
    #         """Set module loading timeout"""
    self._timeout = timeout

    #     def set_error_mode(self, mode: str):
    #         """Set error handling mode"""
    #         if mode in ['strict', 'warn', 'ignore']:
    self._error_mode = mode

    #     def add_search_path(self, path: str):
    #         """Add a search path for module imports"""
    #         if path not in self._search_paths:
                self._search_paths.append(path)

    #     def remove_search_path(self, path: str):
    #         """Remove a search path for module imports"""
    #         if path in self._search_paths:
                self._search_paths.remove(path)

    #     def get_module_info(self, module_name: str) -Dict[str, Any]):
    #         """Get detailed information about a module"""
    #         try:
    module = self.import_module(module_name, lazy=False)
    #             if module is None:
    #                 return {"error": "Module not found"}

    #             return {
    #                 "name": module_name,
                    "loaded": self.is_module_loaded(module_name),
                    "file": getattr(module, "__file__", None),
                    "path": getattr(module, "__path__", None),
                    "doc": getattr(module, "__doc__", None),
                    "functions": list(self.get_module_functions(module_name).keys()),
                    "constants": list(self.get_module_constants(module_name).keys()),
                    "size": len(str(module)),
                    "dependencies": self._module_dependencies.get(module_name, []),
    #             }
    #         except Exception as e:
                return {"error": str(e)}

    #     def reload_module(self, module_name: str) -bool):
    #         """Reload a module"""
    #         try:
    #             # Check namespace mapping
    #             if module_name in self._namespace_mapping:
    actual_module_name = self._namespace_mapping[module_name]
    #             else:
    actual_module_name = module_name

    #             # Remove from cache
    #             if actual_module_name in self._module_cache:
    #                 del self._module_cache[actual_module_name]

    #             # Reload using importlib
    #             if actual_module_name in sys.modules:
                    importlib.reload(sys.modules[actual_module_name])
    #                 return True
    #             else:
    #                 # Import if not loaded
    return self.import_module(module_name, lazy = False) is not None

    #         except Exception as e:
    #             if self._error_mode == 'strict':
    #                 raise
    #             elif self._error_mode == 'warn':
                    print(f"Warning: Failed to reload module {module_name}: {e}")
    #             return False

    #     def get_performance_metrics(self) -Dict[str, Any]):
    #         """Get performance metrics"""
    #         avg_time = self._total_time / self._import_count if self._import_count 0 else 0
    #         return {
    #             "import_count"): self._import_count,
    #             "total_time": self._total_time,
    #             "average_time": avg_time,
    #             "error_count": self._error_count,
    #             "error_rate": self._error_count / self._import_count if self._import_count 0 else 0,
                "cache_size"): len(self._module_cache),
                "lazy_modules": len(self._lazy_modules),
                "namespace_mappings": len(self._namespace_mapping),
                "allowed_modules": len(self._allowed_modules),
                "forbidden_modules": len(self._forbidden_modules),
                "search_paths": len(self._search_paths),
    #         }

    #     def clear_cache(self):
    #         """Clear all caches"""
            self._module_cache.clear()
            self._lazy_modules.clear()
            self._module_dependencies.clear()

    #     def reset_metrics(self):
    #         """Reset performance metrics"""
    self._import_count = 0
    self._total_time = 0.0
    self._error_count = 0

    #     def get_module_dependencies(self, module_name: str) -List[str]):
    #         """Get module dependencies"""
            return self._module_dependencies.get(module_name, [])

    #     def add_module_dependency(self, module_name: str, dependency: str):
    #         """Add a module dependency"""
    #         if module_name not in self._module_dependencies:
    self._module_dependencies[module_name] = []
    #         if dependency not in self._module_dependencies[module_name]:
                self._module_dependencies[module_name].append(dependency)

    #     def install_module(self, module_name: str, install_path: Optional[str] = None) -bool):
    #         """Install a module using pip"""
    #         try:
    #             import subprocess
    #             import pip

    cmd = [sys.executable, "-m", "pip", "install", module_name]
    #             if install_path:
                    cmd.extend(["-t", install_path])

    result = subprocess.run(cmd, capture_output=True, text=True)

    #             if result.returncode = 0:
    #                 # Add search path if install_path provided
    #                 if install_path:
                        self.add_search_path(install_path)
    #                 return True
    #             else:
                    print(f"Failed to install module {module_name}: {result.stderr}")
    #                 return False

    #         except Exception as e:
                print(f"Error installing module {module_name}: {e}")
    #             return False

    #     def uninstall_module(self, module_name: str) -bool):
    #         """Uninstall a module using pip"""
    #         try:
    #             import subprocess

    cmd = [sys.executable, "-m", "pip", "uninstall", "-y", module_name]
    result = subprocess.run(cmd, capture_output=True, text=True)

    #             if result.returncode = 0:
    #                 # Remove from cache if loaded
    #                 if module_name in self._module_cache:
    #                     del self._module_cache[module_name]
    #                 return True
    #             else:
                    print(f"Failed to uninstall module {module_name}: {result.stderr}")
    #                 return False

    #         except Exception as e:
                print(f"Error uninstalling module {module_name}: {e}")
    #             return False

    #     def list_available_modules(self, pattern: str = "") -List[str]):
    #         """List available modules with optional pattern filtering"""
    #         try:
    #             import pkgutil

    modules = []
    #             for importer, modname, ispkg in pkgutil.iter_modules():
    #                 if pattern in modname and self.is_module_allowed(modname):
                        modules.append(modname)

                return sorted(modules)

    #         except Exception as e:
                print(f"Error listing available modules: {e}")
    #             return []


# Global instance
_python_module_importer = None

def get_python_module_importer() -PythonModuleImporter):
#     """Get the global Python module importer instance"""
#     global _python_module_importer
#     if _python_module_importer is None:
_python_module_importer = PythonModuleImporter()
#     return _python_module_importer
