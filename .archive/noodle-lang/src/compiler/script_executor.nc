# Converted from Python to NoodleCore
# Original file: src

# """
# Script Executor for Noodle Runtime

# This module provides functionality for executing Noodle scripts and managing
# script execution environments.
# """

import importlib
import importlib.util
import json
import logging
import os
import sys
import tempfile
import traceback
import pathlib.Path
import typing.Any

import .environment.Environment
import .module_loader.ModuleLoader
import .performance_monitor.get_performance_monitor

logger = logging.getLogger(__name__)


class ScriptExecutor
    #     """
    #     Handles execution of Noodle scripts with comprehensive error handling
    #     and performance monitoring.
    #     """

    #     def __init__(
    #         self,
    environment: Optional[Environment] = None,
    module_loader: Optional[ModuleLoader] = None,
    enable_profiling: bool = False,
    #     ):""
    #         Initialize the script executor.

    #         Args:
    #             environment: Execution environment (creates default if None)
    #             module_loader: Module loader instance (creates default if None)
    #             enable_profiling: Whether to enable performance profiling
    #         """
    self.environment = environment or Environment()
    self.module_loader = module_loader or ModuleLoader()
    self.enable_profiling = enable_profiling

    #         # Performance monitoring
    self.performance_monitor = get_performance_monitor()

    #         # Execution state
    self.execution_history: List[Dict[str, Any]] = []
    self.current_execution: Optional[Dict[str, Any]] = None

    #         # Security settings
    self.allowed_imports: List[str] = [
    #             "os",
    #             "sys",
    #             "json",
    #             "logging",
    #             "pathlib",
    #             "typing",
    #             "dataclasses",
    #             "enum",
    #             "functools",
    #         ]
    self.restricted_imports: List[str] = [
    #             "subprocess",
    #             "socket",
    #             "threading",
    #             "multiprocessing",
    #             "ctypes",
    #             "marshal",
    #             "pickle",
    #             "shelve",
    #         ]

            logger.info("ScriptExecutor initialized")

    #     def execute_script(
    #         self,
    #         script_content: str,
    script_path: Optional[str] = None,
    globals_dict: Optional[Dict[str, Any]] = None,
    locals_dict: Optional[Dict[str, Any]] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Execute a Noodle script with comprehensive error handling.

    #         Args:
    #             script_content: The script content to execute
    #             script_path: Path to the script (for error reporting)
    #             globals_dict: Global variables for execution
    #             locals_dict: Local variables for execution

    #         Returns:
    #             Execution result dictionary
    #         """
    execution_id = f"exec_{len(self.execution_history) + 1}"
    execution_start = self.performance_monitor.get_current_metrics()

    #         # Initialize execution context
    execution_context = {
    #             "id": execution_id,
    #             "script_path": script_path,
    #             "start_time": execution_start.timestamp if execution_start else None,
    #             "status": "running",
    #             "error": None,
    #             "result": None,
    #             "globals": globals_dict or {},
    #             "locals": locals_dict or {},
    #             "imports_used": [],
    #             "modules_loaded": [],
    #             "performance_metrics": {},
    #         }

    self.current_execution = execution_context
            self.execution_history.append(execution_context)

    #         try:
    #             # Validate script content
                self._validate_script(script_content)

    #             # Prepare execution environment
    exec_globals = self._prepare_execution_globals(globals_dict)
    exec_locals = self._prepare_execution_locals(locals_dict)

    #             # Execute the script
                logger.info(f"Executing script {execution_id}")

    #             if self.enable_profiling:
    #                 # Start profiling
                    self.performance_monitor.start_monitoring()

    #             # Execute the script
                exec(script_content, exec_globals, exec_locals)

    #             # Capture result
    execution_context["result"] = {
    #                 "success": True,
    #                 "globals": exec_globals,
    #                 "locals": exec_locals,
    #                 "output": "Script executed successfully",
    #             }

    execution_context["status"] = "completed"
                logger.info(f"Script {execution_id} executed successfully")

    #         except Exception as e:
    #             # Handle execution errors
    error_info = {
                    "type": type(e).__name__,
                    "message": str(e),
                    "traceback": traceback.format_exc(),
                    "line_number": self._get_error_line_number(e, script_content),
    #             }

    execution_context["error"] = error_info
    execution_context["status"] = "failed"

                logger.error(f"Script {execution_id} failed: {error_info['message']}")

    #         finally:
    #             # Complete execution
    execution_end = self.performance_monitor.get_current_metrics()
    execution_context["end_time"] = (
    #                 execution_end.timestamp if execution_end else None
    #             )

    #             if self.enable_profiling and execution_start:
    #                 # Calculate performance metrics
    execution_context["performance_metrics"] = {
    #                     "execution_duration": execution_context["end_time"]
    #                     - execution_context["start_time"],
    #                     "cpu_usage": execution_end.cpu_percent if execution_end else 0,
                        "memory_usage": (
    #                         execution_end.memory_percent if execution_end else 0
    #                     ),
    #                 }

    #             # Log execution summary
                self._log_execution_summary(execution_context)

    #             # Stop profiling if enabled
    #             if self.enable_profiling:
                    self.performance_monitor.stop_monitoring()

    #         return execution_context

    #     def execute_file(
    #         self,
    #         file_path: Union[str, Path],
    globals_dict: Optional[Dict[str, Any]] = None,
    locals_dict: Optional[Dict[str, Any]] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Execute a script from a file.

    #         Args:
    #             file_path: Path to the script file
    #             globals_dict: Global variables for execution
    #             locals_dict: Local variables for execution

    #         Returns:
    #             Execution result dictionary
    #         """
    file_path = Path(file_path)

    #         if not file_path.exists():
                raise FileNotFoundError(f"Script file not found: {file_path}")

    #         if not file_path.suffix == ".py":
                raise ValueError(f"Only Python files (.py) can be executed: {file_path}")

    #         # Read script content
    #         try:
    #             with open(file_path, "r", encoding="utf-8") as f:
    script_content = f.read()
    #         except Exception as e:
                raise IOError(f"Failed to read script file {file_path}: {e}")

    #         # Execute the script
            return self.execute_script(
    script_content = script_content,
    script_path = str(file_path),
    globals_dict = globals_dict,
    locals_dict = locals_dict,
    #         )

    #     def execute_module(
    #         self,
    #         module_name: str,
    function_name: str = "main",
    args: Optional[List[Any]] = None,
    kwargs: Optional[Dict[str, Any]] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Execute a specific function from a loaded module.

    #         Args:
    #             module_name: Name of the module to execute
    #             function_name: Name of the function to call
    #             args: Arguments to pass to the function
    #             kwargs: Keyword arguments to pass to the function

    #         Returns:
    #             Execution result dictionary
    #         """
    args = args or []
    kwargs = kwargs or {}

    #         try:
    #             # Load the module
    module = self.module_loader.get_module(module_name)

    #             # Get the function
    #             if not hasattr(module, function_name):
                    raise AttributeError(
    #                     f"Module {module_name} does not have function {function_name}"
    #                 )

    func = getattr(module, function_name)

    #             # Execute the function
    result = func( * args, **kwargs)

    #             return {
    #                 "success": True,
    #                 "result": result,
    #                 "module": module_name,
    #                 "function": function_name,
    #             }

    #         except Exception as e:
    #             return {
    #                 "success": False,
                    "error": str(e),
    #                 "module": module_name,
    #                 "function": function_name,
    #             }

    #     def _validate_script(self, script_content: str) -None):
    #         """
    #         Validate script content for security and syntax.

    #         Args:
    #             script_content: Script content to validate

    #         Raises:
    #             ValueError: If script contains invalid content
    #         """
    #         # Check for restricted imports
    #         for restricted in self.restricted_imports:
    #             if (
    #                 f"import {restricted}" in script_content
    #                 or f"from {restricted}" in script_content
    #             ):
                    raise ValueError(f"Restricted import detected: {restricted}")

    #         # Basic syntax validation
    #         try:
                compile(script_content, "<string>", "exec")
    #         except SyntaxError as e:
                raise ValueError(f"Script syntax error: {e}")

    #     def _prepare_execution_globals(
    #         self, globals_dict: Optional[Dict[str, Any]]
    #     ) -Dict[str, Any]):
    #         """
    #         Prepare global variables for script execution.

    #         Args:
    #             globals_dict: Custom global variables

    #         Returns:
    #             Global variables dictionary
    #         """
    #         # Start with standard globals
    exec_globals = {
    #             "__name__": "__main__",
    #             "__file__": "<string>",
    #             "__package__": None,
    #             "__doc__": None,
    #             "__builtins__": __builtins__,
    #         }

    #         # Add environment variables
            exec_globals.update(self.environment.get_globals())

    #         # Add custom globals
    #         if globals_dict:
                exec_globals.update(globals_dict)

    #         # Track imports
    exec_globals["__import_tracker__"] = ImportTracker()

    #         return exec_globals

    #     def _prepare_execution_locals(
    #         self, locals_dict: Optional[Dict[str, Any]]
    #     ) -Dict[str, Any]):
    #         """
    #         Prepare local variables for script execution.

    #         Args:
    #             locals_dict: Custom local variables

    #         Returns:
    #             Local variables dictionary
    #         """
    exec_locals = {}

    #         if locals_dict:
                exec_locals.update(locals_dict)

    #         return exec_locals

    #     def _get_error_line_number(
    #         self, error: Exception, script_content: str
    #     ) -Optional[int]):
    #         """
    #         Extract line number from error traceback.

    #         Args:
    #             error: Exception that occurred
    #             script_content: Script content where error occurred

    #         Returns:
    #             Line number of the error, or None if not available
    #         """
    #         if hasattr(error, "lineno"):
    #             return error.lineno

    #         # Try to extract from traceback
    tb = error.__traceback__
    #         if tb:
    #             return tb.tb_lineno

    #         return None

    #     def _log_execution_summary(self, execution_context: Dict[str, Any]) -None):
    #         """
    #         Log a summary of script execution.

    #         Args:
    #             execution_context: Execution context to summarize
    #         """
    status = execution_context["status"]
    script_path = execution_context.get("script_path", "<string>")

    #         if status == "completed":
                logger.info(
                    f"Script execution completed: {execution_context['id']} ({script_path})"
    #             )
    #         else:
    error = execution_context.get("error", {})
                logger.error(
                    f"Script execution failed: {execution_context['id']} ({script_path}) - {error.get('message', 'Unknown error')}"
    #             )

    #     def get_execution_history(
    self, count: Optional[int] = None
    #     ) -List[Dict[str, Any]]):
    #         """
    #         Get execution history.

    #         Args:
    #             count: Number of recent executions to return (None for all)

    #         Returns:
    #             List of execution contexts
    #         """
    #         if count is None:
                return self.execution_history.copy()
    #         return self.execution_history[-count:] if count 0 else []

    #     def clear_execution_history(self):
    """None)"""
    #         """Clear execution history."""
            self.execution_history.clear()
            logger.info("Execution history cleared")

    #     def set_security_policy(
    #         self,
    allowed_imports: Optional[List[str]] = None,
    restricted_imports: Optional[List[str]] = None,
    #     ) -None):
    #         """
    #         Set security policy for script execution.

    #         Args:
    #             allowed_imports: List of allowed import modules
    #             restricted_imports: List of restricted import modules
    #         """
    #         if allowed_imports is not None:
    self.allowed_imports = allowed_imports

    #         if restricted_imports is not None:
    self.restricted_imports = restricted_imports

            logger.info("Security policy updated")


class ImportTracker
    #     """
    #     Tracks imports made during script execution.
    #     """

    #     def __init__(self):""Initialize the import tracker."""
    self.imports: List[str] = []
    self.from_imports: List[str] = []

    #     def track_import(self, module_name: str) -None):
    #         """Track a standard import."""
    #         if module_name not in self.imports:
                self.imports.append(module_name)

    #     def track_from_import(self, module_name: str, imported_name: str) -None):
    #         """Track a 'from ... import ...' statement."""
    import_key = f"{module_name}.{imported_name}"
    #         if import_key not in self.from_imports:
                self.from_imports.append(import_key)

    #     def get_all_imports(self) -List[str]):
    #         """Get all tracked imports."""
    #         return self.imports + self.from_imports


# Custom import hook for tracking imports
class ImportTrackingHook
    #     """
    #     Import hook that tracks imports made during script execution.
    #     """

    #     def __init__(self, tracker: ImportTracker):""
    #         Initialize the import hook.

    #         Args:
    #             tracker: ImportTracker instance
    #         """
    self.tracker = tracker

    #     def find_spec(
    self, fullname: str, path: Optional[str] = None, target: Optional[Any] = None
    #     ) -Any):
    #         """Find module spec for import tracking."""
            self.tracker.track_import(fullname)
    #         return None  # Let default importer handle the actual import


# Export public API
__all__ = [
#     "ScriptExecutor",
#     "ImportTracker",
#     "ImportTrackingHook",
# ]
