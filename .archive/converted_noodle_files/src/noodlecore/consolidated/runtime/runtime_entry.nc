# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Runtime Entry Point
 = ===========================

# This module provides a convenient entry point for executing NoodleCore code.
# It integrates the parser, interpreter, and module loader to provide
# a simple interface for running NoodleCore programs.
# """

import os
import sys
import typing.Any,

import .parser.NoodleParser
import .interpreter.NoodleInterpreter
import .module_loader.NoodleModuleLoader
import .builtins.NoodleBuiltins,
import .errors.NoodleError,
import .language_constructs.NoodleModule


class NoodleRuntime
    #     """
    #     Main runtime entry point for NoodleCore.

    #     This class provides a high-level interface for executing NoodleCore code
    #     from strings or files, with proper error handling and module management.
    #     """

    #     def __init__(self, search_paths: Optional[List[str]] = None):
    #         """
    #         Initialize the NoodleCore runtime.

    #         Args:
    #             search_paths: Optional list of paths to search for modules
    #         """
    #         # Initialize built-in functions
    self.builtins = NoodleBuiltins()

    #         # Create module loader
    self.module_loader = NoodleModuleLoader()
    #         if search_paths:
    #             for path in search_paths:
                    self.module_loader.add_search_path(path)

    #         # Create interpreter with built-ins
    builtin_functions = {
                name: create_builtin_function(name, func)
    #             for name, func in self.builtins.get_all_builtins().items()
    #         }

    self.interpreter = NoodleInterpreter(
    builtins = builtin_functions,
    module_loader = self.module_loader
    #         )

    #         # Create parser
    self.parser = NoodleParser()

    #     def execute_code(self, code: str, context: Optional[Dict[str, Any]] = None) -> Any:
    #         """
    #         Execute NoodleCore code from a string.

    #         Args:
    #             code: NoodleCore code to execute
    #             context: Optional execution context

    #         Returns:
    #             Any: Result of code execution

    #         Raises:
    #             NoodleError: If execution fails
    #         """
    #         try:
                return self.interpreter.execute_code(code, context)
    #         except Exception as e:
                self.interpreter.handle_error(e)
    #             raise

    #     def execute_file(self, file_path: str, context: Optional[Dict[str, Any]] = None) -> Any:
    #         """
    #         Execute NoodleCore code from a file.

    #         Args:
    #             file_path: Path to the file to execute
    #             context: Optional execution context

    #         Returns:
    #             Any: Result of file execution

    #         Raises:
    #             NoodleError: If execution fails
    #         """
    #         try:
                return self.interpreter.execute_file(file_path, context)
    #         except Exception as e:
                self.interpreter.handle_error(e)
    #             raise

    #     def load_module(self, module_name: str, module_path: Optional[str] = None) -> NoodleModule:
    #         """
    #         Load a NoodleCore module.

    #         Args:
    #             module_name: Name of the module to load
    #             module_path: Optional explicit path to the module file

    #         Returns:
    #             NoodleModule: Loaded module

    #         Raises:
    #             NoodleImportError: If module cannot be loaded
    #         """
    #         try:
                return self.module_loader.load_module(module_name, module_path)
    #         except Exception as e:
    #             if isinstance(e, NoodleImportError):
    #                 raise
    #             else:
                    raise NoodleImportError(
                        f"Failed to load module '{module_name}': {str(e)}",
    module_name = module_name
    #                 )

    #     def get_loaded_modules(self) -> List[str]:
    #         """
    #         Get list of loaded module names.

    #         Returns:
    #             List[str]: List of loaded module names
    #         """
            return self.module_loader.get_loaded_modules()

    #     def add_search_path(self, path: str) -> None:
    #         """
    #         Add a directory to module search paths.

    #         Args:
    #             path: Directory path to add
    #         """
            self.module_loader.add_search_path(path)

    #     def get_global_variables(self) -> Dict[str, Any]:
    #         """
    #         Get all global variables from the interpreter.

    #         Returns:
    #             Dict[str, Any]: Global variables
    #         """
            return self.interpreter.global_scope.copy()

    #     def set_global_variable(self, name: str, value: Any) -> None:
    #         """
    #         Set a global variable in the interpreter.

    #         Args:
    #             name: Variable name
    #             value: Variable value
    #         """
    self.interpreter.global_scope[name] = value

    #     def create_module(self, name: str, code: str) -> NoodleModule:
    #         """
    #         Create a new NoodleCore module from code.

    #         Args:
    #             name: Module name
    #             code: Module source code

    #         Returns:
    #             NoodleModule: Created module
    #         """
    #         # Parse the code
    #         try:
    ast = self.parser.parse(code, f"<module {name}>")
    #         except Exception as e:
                raise NoodleRuntimeError(
                    f"Failed to parse module '{name}': {str(e)}",
    operation = "module_creation"
    #             )

    #         # Create module object
    module = NoodleModule(
    name = name,
    path = f"<module {name}>",
    globals = {},
    functions = {},
    classes = {},
    imports = []
    #         )

    #         # Execute the module to populate globals
            self.interpreter.execute_module(module, ast)

    #         return module


# Create a default runtime instance
_default_runtime = None


def get_default_runtime() -> NoodleRuntime:
#     """
#     Get the default runtime instance.

#     Returns:
#         NoodleRuntime: Default runtime instance
#     """
#     global _default_runtime
#     if _default_runtime is None:
_default_runtime = NoodleRuntime()
#     return _default_runtime


def execute_code(code: str, context: Optional[Dict[str, Any]] = None) -> Any:
#     """
#     Execute NoodleCore code using the default runtime.

#     Args:
#         code: NoodleCore code to execute
#         context: Optional execution context

#     Returns:
#         Any: Result of code execution
#     """
runtime = get_default_runtime()
    return runtime.execute_code(code, context)


def execute_file(file_path: str, context: Optional[Dict[str, Any]] = None) -> Any:
#     """
#     Execute a NoodleCore file using the default runtime.

#     Args:
#         file_path: Path to the file to execute
#         context: Optional execution context

#     Returns:
#         Any: Result of file execution
#     """
runtime = get_default_runtime()
    return runtime.execute_file(file_path, context)


def load_module(module_name: str, module_path: Optional[str] = None) -> NoodleModule:
#     """
#     Load a NoodleCore module using the default runtime.

#     Args:
#         module_name: Name of the module to load
#         module_path: Optional explicit path to the module file

#     Returns:
#         NoodleModule: Loaded module
#     """
runtime = get_default_runtime()
    return runtime.load_module(module_name, module_path)


# Export runtime components
__all__ = [
#     'NoodleRuntime',
#     'get_default_runtime',
#     'execute_code',
#     'execute_file',
#     'load_module',
# ]