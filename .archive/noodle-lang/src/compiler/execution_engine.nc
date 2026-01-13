# Converted from Python to NoodleCore
# Original file: src

# """
# Execution engine for the Noodle runtime.

# This module provides execution functionality including:
# - Script execution
# - Module loading
# - Code evaluation
# - Error handling
# """

import importlib.util
import os
import sys
import traceback
import typing.Any

import .environment.Environment


class ExecutionEngine
    #     """
    #     High-level execution engine for Noodle programs.
    #     """

    #     def __init__(self, environment: Optional[Environment] = None):""
    #         Initialize the execution engine.

    #         Args:
    #             environment: Execution environment, defaults to global
    #         """
    self.environment = environment or get_global_environment()
    self.current_file = None
    self.execution_stack = []

    #     def execute_script(self, file_path: str, env: Optional[Environment] = None) -Any):
    #         """
    #         Execute a Noodle script file.

    #         Args:
    #             file_path: Path to the script file
    #             env: Optional environment for execution

    #         Returns:
    #             Execution result

    #         Raises:
    #             FileNotFoundError: If file doesn't exist
    #             RuntimeError: If execution fails
    #         """
    #         if not os.path.exists(file_path):
                raise FileNotFoundError(f"Script file not found: {file_path}")

    execution_env = env or self.environment.create_child(
                f"script_{os.path.basename(file_path)}"
    #         )

    #         try:
    #             with open(file_path, "r", encoding="utf-8") as f:
    source_code = f.read()

                return self.execute_source(source_code, execution_env, file_path)

    #         except Exception as e:
                raise RuntimeError(f"Failed to execute script {file_path}: {e}") from e

    #     def execute_source(
    self, source_code: str, env: Optional[Environment] = None, file_path: str = None
    #     ) -Any):
    #         """
    #         Execute source code.

    #         Args:
    #             source_code: Source code to execute
    #             env: Optional environment for execution
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             Execution result

    #         Raises:
    #             RuntimeError: If execution fails
    #         """
    execution_env = env or self.environment.create_child("execution")

    #         try:
    #             # Compile the source code
    compiled_code = compile(source_code, file_path or "<string>", "exec")

    #             # Execute in the provided environment
                exec(compiled_code, execution_env.variables)

    #             return execution_env

    #         except Exception as e:
    error_msg = f"Execution error"
    #             if file_path:
    error_msg + = f" in {file_path}"
    error_msg + = f": {e}"

    #             # Add traceback information
    #             if file_path:
    error_msg + = f"\nFile: {file_path}"
    #                 error_msg += f"\nLine: {e.__traceback__.tb_lineno if hasattr(e, '__traceback__') else 'unknown'}"

                raise RuntimeError(error_msg) from e

    #     def execute_module(
    self, module_name: str, env: Optional[Environment] = None
    #     ) -Any):
    #         """
    #         Execute a module.

    #         Args:
    #             module_name: Name of the module to execute
    #             env: Optional environment for execution

    #         Returns:
    #             Execution result

    #         Raises:
    #             ImportError: If module cannot be imported
    #             RuntimeError: If execution fails
    #         """
    execution_env = env or self.environment.create_child(f"module_{module_name}")

    #         try:
    #             # Import the module
    module = importlib.import_module(module_name)

    #             # Execute the module in the environment
    #             if hasattr(module, "__main__"):
                    exec(module.__main__, execution_env.variables)
    #             elif hasattr(module, "__init__"):
                    exec(module.__init__, execution_env.variables)

    #             return execution_env

    #         except ImportError as e:
                raise ImportError(f"Failed to import module '{module_name}': {e}") from e
    #         except Exception as e:
                raise RuntimeError(f"Failed to execute module '{module_name}': {e}") from e

    #     def evaluate_expression(
    self, expression: str, env: Optional[Environment] = None
    #     ) -Any):
    #         """
    #         Evaluate an expression.

    #         Args:
    #             expression: Expression to evaluate
    #             env: Optional environment for evaluation

    #         Returns:
    #             Evaluation result

    #         Raises:
    #             RuntimeError: If evaluation fails
    #         """
    execution_env = env or self.environment

    #         try:
                return eval(expression, execution_env.variables)

    #         except Exception as e:
                raise RuntimeError(
    #                 f"Failed to evaluate expression '{expression}': {e}"
    #             ) from e

    #     def load_module_from_file(self, file_path: str, module_name: str = None) -Any):
    #         """
    #         Load a module from a file.

    #         Args:
    #             file_path: Path to the module file
    #             module_name: Optional module name, defaults to filename without extension

    #         Returns:
    #             Loaded module

    #         Raises:
    #             FileNotFoundError: If file doesn't exist
    #             ImportError: If module cannot be loaded
    #         """
    #         if not os.path.exists(file_path):
                raise FileNotFoundError(f"Module file not found: {file_path}")

    #         if module_name is None:
    module_name = os.path.splitext(os.path.basename(file_path))[0]

    #         try:
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    #             if spec is None or spec.loader is None:
    #                 raise ImportError(f"Could not create module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
                spec.loader.exec_module(module)

    #             return module

    #         except Exception as e:
                raise ImportError(f"Failed to load module from {file_path}: {e}") from e

    #     def create_execution_context(
    self, name: str, parent_env: Optional[Environment] = None
    #     ) -Environment):
    #         """
    #         Create a new execution context.

    #         Args:
    #             name: Context name
    #             parent_env: Optional parent environment

    #         Returns:
    #             New execution environment
    #         """
            return (parent_env or self.environment).create_child(name)

    #     def push_context(self, name: str) -Environment):
    #         """
    #         Push a new execution context onto the stack.

    #         Args:
    #             name: Context name

    #         Returns:
    #             New execution environment
    #         """
    new_env = self.environment.create_child(name)
            self.execution_stack.append(self.environment)
    self.environment = new_env
    #         return new_env

    #     def pop_context(self) -Environment):
    #         """
    #         Pop the current execution context from the stack.

    #         Returns:
    #             Previous execution environment

    #         Raises:
    #             IndexError: If stack is empty
    #         """
    #         if not self.execution_stack:
                raise IndexError("Execution stack is empty")

    previous_env = self.environment
    self.environment = self.execution_stack.pop()
    #         return previous_env

    #     def get_current_context(self) -Environment):
    #         """
    #         Get the current execution context.

    #         Returns:
    #             Current execution environment
    #         """
    #         return self.environment

    #     def reset_context(self) -None):
    #         """Reset to the original environment."""
    self.environment = get_global_environment()
            self.execution_stack.clear()

    #     def get_execution_state(self) -Dict[str, Any]):
    #         """
    #         Get current execution state.

    #         Returns:
    #             State dictionary
    #         """
    #         return {
    #             "environment": self.environment,
    #             "current_file": self.current_file,
                "execution_stack": self.execution_stack.copy(),
    #         }

    #     def set_execution_state(self, state: Dict[str, Any]) -None):
    #         """
    #         Set execution state.

    #         Args:
    #             state: State dictionary
    #         """
    self.environment = state.get("environment", get_global_environment())
    self.current_file = state.get("current_file")
    self.execution_stack = state.get("execution_stack", [])
