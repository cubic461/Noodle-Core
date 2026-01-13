# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore Module Loader Fix
# ============================
#
# This module provides a fix for the circular import issue between
# module_loader.py and interpreter.py by using lazy imports.

import os
import sys
import importlib.util
import pathlib.Path
import typing.Any,

# Import errors without causing circular imports
import .language_constructs.NoodleModule,
import .errors.NoodleImportError,


class NoodleModuleLoader
    #     """
    #     Loader for NoodleCore modules.

    #     This class handles loading of NoodleCore modules from various sources,
    #     including .nc files and Python modules.
    #     """

    #     def __init__(self, interpreter: Optional[Any] = None):
    #         """Initialize module loader."""
    self.loaded_modules: Dict[str, NoodleModule] = {}
    self.search_paths: List[str] = self._get_default_search_paths()
    self._parser = None
    self._interpreter = interpreter
    self._parser_initialized = False
    self._interpreter_initialized = False

    #     def _get_default_search_paths(self) -> List[str]:
    #         """
    #         Get default module search paths.

    #         Returns:
    #             List[str]: List of search paths
    #         """
    paths = []

    #         # Current directory
            paths.append(os.getcwd())

    #         # Directory of the calling script
    #         if hasattr(sys, 'argv') and len(sys.argv) > 0:
    script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
                paths.append(script_dir)

    #         # Python path entries
    #         for path in sys.path:
    #             if path not in paths:
                    paths.append(path)

    #         return paths

    #     def add_search_path(self, path: str) -> None:
    #         """
    #         Add a directory to module search paths.

    #         Args:
    #             path: Directory path to add
    #         """
    #         if path not in self.search_paths:
                self.search_paths.append(path)

    #     def _get_parser(self):
    #         """Lazy initialization of parser."""
    #         if not self._parser_initialized:
    #             # Import here to avoid circular imports
    #             from ..parser import NoodleParser
    self._parser = NoodleParser()
    self._parser_initialized = True
    #         return self._parser

    #     def _get_interpreter(self):
    #         """Lazy initialization of interpreter."""
    #         if not self._interpreter_initialized:
    #             # Use provided interpreter or create a new one
    #             if self._interpreter is None:
    #                 # Import here to avoid circular imports
    #                 from ..interpreter import NoodleInterpreter
    self._interpreter = NoodleInterpreter(module_loader=self)
    self._interpreter_initialized = True
    #         return self._interpreter

    #     def find_module_file(self, module_name: str) -> Optional[str]:
    #         """
    #         Find module file by name.

    #         Args:
    #             module_name: Module name to find

    #         Returns:
    #             Optional[str]: Path to module file if found
    #         """
    #         # Try different file extensions
    extensions = ['.nc', '.py']

    #         for search_path in self.search_paths:
    #             for ext in extensions:
    #                 # Direct file match
    file_path = math.add(os.path.join(search_path, module_name, ext))
    #                 if os.path.isfile(file_path):
    #                     return file_path

    #                 # Package directory match
    package_dir = os.path.join(search_path, module_name)
    init_file = os.path.join(package_dir, '__init__' + ext)
    #                 if os.path.isdir(package_dir) and os.path.isfile(init_file):
    #                     return init_file

    #         return None

    #     def load_module(self, module_name: str, module_path: Optional[str] = None) -> NoodleModule:
    #         """
    #         Load a NoodleCore module.

    #         Args:
    #             module_name: Name of module to load
    #             module_path: Optional explicit path to module file

    #         Returns:
    #             NoodleModule: Loaded module

    #         Raises:
    #             NoodleImportError: If module cannot be loaded
    #         """
    #         # Check if already loaded
    #         if module_name in self.loaded_modules:
    #             return self.loaded_modules[module_name]

    #         # Find module file if not provided
    #         if not module_path:
    module_path = self.find_module_file(module_name)
    #             if not module_path:
                    raise NoodleImportError(
    #                     f"Module '{module_name}' not found",
    module_name = module_name
    #                 )

    #         try:
    #             # Load based on file extension
    #             if module_path.endswith('.nc'):
                    return self._load_noodlecore_module(module_name, module_path)
    #             elif module_path.endswith('.py'):
                    return self._load_python_module(module_name, module_path)
    #             else:
                    raise NoodleImportError(
    #                     f"Unsupported file type for module '{module_name}': {module_path}",
    module_name = module_name,
    file_path = module_path
    #                 )
    #         except Exception as e:
    #             if isinstance(e, (NoodleImportError, NoodleSyntaxError, NoodleRuntimeError)):
    #                 raise
    #             else:
                    raise NoodleImportError(
                        f"Failed to load module '{module_name}': {str(e)}",
    module_name = module_name,
    file_path = module_path
    #                 )

    #     def _load_noodlecore_module(self, module_name: str, module_path: str) -> NoodleModule:
    #         """
            Load a .nc (NoodleCore) module.

    #         Args:
    #             module_name: Module name
    #             module_path: Path to .nc file

    #         Returns:
    #             NoodleModule: Loaded module
    #         """
    #         try:
    #             with open(module_path, 'r', encoding='utf-8') as f:
    source_code = f.read()
    #         except IOError as e:
                raise NoodleImportError(
                    f"Cannot read module file '{module_path}': {str(e)}",
    module_name = module_name,
    file_path = module_path
    #             )

    #         # Parse the source code
    #         try:
    parser = self._get_parser()
    ast = parser.parse(source_code, module_path)
    #         except Exception as e:
    #             if isinstance(e, NoodleSyntaxError):
    #                 raise
    #             else:
                    raise NoodleSyntaxError(
                        f"Failed to parse module '{module_name}': {str(e)}",
    file_path = module_path
    #                 )

    #         # Create module object
    module = NoodleModule(
    name = module_name,
    path = module_path,
    globals = {},
    functions = {},
    classes = {},
    imports = []
    #         )

    #         # Execute the module to populate globals
    #         try:
    interpreter = self._get_interpreter()
                interpreter.execute_module(module, ast)
    #         except Exception as e:
    #             if isinstance(e, NoodleRuntimeError):
    #                 raise
    #             else:
                    raise NoodleRuntimeError(
                        f"Failed to execute module '{module_name}': {str(e)}",
    operation = "module_execution"
    #                 )

    #         # Cache the module
    self.loaded_modules[module_name] = module
    #         return module

    #     def _load_python_module(self, module_name: str, module_path: str) -> NoodleModule:
    #         """
    #         Load a Python module and wrap it as NoodleCore module.

    #         Args:
    #             module_name: Module name
    #             module_path: Path to .py file

    #         Returns:
    #             NoodleModule: Wrapped module
    #         """
    #         try:
    #             # Load Python module
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    #             if not spec:
                    raise NoodleImportError(
    #                     f"Cannot create module spec for '{module_path}'",
    module_name = module_name,
    file_path = module_path
    #                 )

    python_module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(python_module)
    #         except Exception as e:
                raise NoodleImportError(
                    f"Failed to load Python module '{module_name}': {str(e)}",
    module_name = module_name,
    file_path = module_path
    #             )

    #         # Create NoodleCore wrapper
    module = NoodleModule(
    name = module_name,
    path = module_path,
    globals = {},
    functions = {},
    classes = {},
    imports = []
    #         )

    #         # Copy Python module attributes to NoodleCore module
    #         for name, value in vars(python_module).items():
    #             if not name.startswith('_'):
    module.globals[name] = value

    #                 # Categorize the attribute
    #                 if callable(value):
    #                     # Create NoodleFunction wrapper
    module.functions[name] = self._wrap_python_function(name, value)
    #                 elif isinstance(value, type):
    #                     # Create NoodleClass wrapper
    module.classes[name] = self._wrap_python_class(name, value)

    #         # Cache the module
    self.loaded_modules[module_name] = module
    #         return module

    #     def _wrap_python_function(self, name: str, func) -> NoodleFunction:
    #         """
    #         Wrap a Python function as NoodleFunction.

    #         Args:
    #             name: Function name
    #             func: Python function

    #         Returns:
    #             NoodleFunction: Wrapped function
    #         """
    #         import inspect

    #         # Get function signature
    sig = inspect.signature(func)
    params = list(sig.parameters.keys())

    #         # Create wrapper
    #         def wrapper(*args, **kwargs):
                return func(*args, **kwargs)

    #         # Create function with Python function reference
    noodle_func = NoodleFunction(
    name = name,
    params = params,
    body = f"<Python function {name}>",
    closure = {},
    is_builtin = False
    #         )

    #         # Store the actual Python function for execution
    noodle_func._python_func = func

    #         return noodle_func

    #     def _wrap_python_class(self, name: str, cls) -> NoodleClass:
    #         """
    #         Wrap a Python class as NoodleClass.

    #         Args:
    #             name: Class name
    #             cls: Python class

    #         Returns:
    #             NoodleClass: Wrapped class
    #         """
    #         # Create NoodleClass wrapper
    #         noodle_class = NoodleClass(
    name = name,
    bases = [],
    methods = {},
    attributes = {},
    is_builtin = False
    #         )

    #         # Copy class attributes
    #         for attr_name, attr_value in vars(cls).items():
    #             if not attr_name.startswith('_'):
    noodle_class.attributes[attr_name] = attr_value

    #         # Wrap methods
    #         for method_name in dir(cls):
    #             if not method_name.startswith('_'):
    method = getattr(cls, method_name)
    #                 if callable(method):
    noodle_class.methods[method_name] = self._wrap_python_function(
    #                         f"{name}.{method_name}", method
    #                     )

    #         return noodle_class

    #     def reload_module(self, module_name: str) -> NoodleModule:
    #         """
    #         Reload a module.

    #         Args:
    #             module_name: Module name to reload

    #         Returns:
    #             NoodleModule: Reloaded module
    #         """
    #         if module_name in self.loaded_modules:
    #             del self.loaded_modules[module_name]

            return self.load_module(module_name)

    #     def get_loaded_modules(self) -> List[str]:
    #         """
    #         Get list of loaded module names.

    #         Returns:
    #             List[str]: List of loaded module names
    #         """
            return list(self.loaded_modules.keys())

    #     def is_module_loaded(self, module_name: str) -> bool:
    #         """
    #         Check if a module is loaded.

    #         Args:
    #             module_name: Module name to check

    #         Returns:
    #             bool: True if module is loaded
    #         """
    #         return module_name in self.loaded_modules


# Export module loader
__all__ = [
#     'NoodleModuleLoader',
# ]
