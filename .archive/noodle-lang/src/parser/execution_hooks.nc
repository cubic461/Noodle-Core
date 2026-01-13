# Converted from Python to NoodleCore
# Original file: src

# """
# Execution hooks for connecting LSP to nbc_runtime.
# """

import json
import logging
import os
import subprocess
import pathlib.Path
import typing.Any

logger = logging.getLogger(__name__)


class ExecutionHooks:
    #     """Handles execution of Noodle code through nbc_runtime."""

    #     def __init__(self, runtime_path: Optional[str] = None):
    self.runtime_path = runtime_path or self._get_default_runtime_path()
    self.execution_cache = {}

    #     def _get_default_runtime_path(self) -str):
    #         """Get the default path to nbc_runtime."""
    #         # Try environment variable first
    env_path = os.environ.get("NOODLE_RUNTIME_PATH")
    #         if env_path and os.path.exists(env_path):
    #             return env_path

    #         # Fallback to relative path
    current_dir = os.path.dirname(os.path.abspath(__file__))
    runtime_path = os.path.join(current_dir, "..", "..", "runtime", "nbc_runtime")

    #         if os.path.exists(runtime_path):
    #             return runtime_path

    #         # Last fallback - assume it's in the Python path
    #         return "noodle.runtime.nbc_runtime"

    #     def execute_code(
    self, code: str, context: Optional[Dict[str, Any]] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Execute Noodle code using nbc_runtime.

    #         Args:
    #             code: The Noodle code to execute
    #             context: Optional context variables

    #         Returns:
    #             Dictionary with execution results
    #         """
    #         try:
    #             # Create a unique cache key for this code
    cache_key = hash(code + str(context))

    #             # Check cache first
    #             if cache_key in self.execution_cache:
    #                 logger.debug(f"Returning cached result for code execution")
    #                 return self.execution_cache[cache_key]

    #             # Prepare execution environment
    env = os.environ.copy()
    #             if context:
                    env.update(context)

    #             # Try to execute via subprocess first (for standalone script)
    result = self._execute_via_subprocess(code, env)

    #             # If subprocess fails, try to import and execute directly
    #             if not result.get("success", False):
    result = self._execute_via_import(code, context)

    #             # Cache the result
    self.execution_cache[cache_key] = result

    #             return result

    #         except Exception as e:
                logger.error(f"Error executing code: {e}")
    #             return {
    #                 "success": False,
                    "error": str(e),
    #                 "output": "",
    #                 "execution_time": 0,
    #             }

    #     def _execute_via_subprocess(self, code: str, env: Dict[str, str]) -Dict[str, Any]):
    #         """Execute code using subprocess."""
    #         try:
    #             # Write code to temporary file
    #             with tempfile.NamedTemporaryFile(
    mode = "w", suffix=".noodle", delete=False
    #             ) as f:
                    f.write(code)
    temp_file = f.name

    #             try:
    #                 # Execute using nbc_runtime
    cmd = [sys.executable, self.runtime_path, "execute", temp_file]

    start_time = time.time()
    result = subprocess.run(
    #                     cmd,
    capture_output = True,
    text = True,
    env = env,
    timeout = 30,  # 30 second timeout
    #                 )
    execution_time = time.time() - start_time

    #                 return {
    "success": result.returncode = 0,
    #                     "output": result.stdout,
    #                     "error": result.stderr,
    #                     "execution_time": execution_time,
    #                     "return_code": result.returncode,
    #                 }

    #             finally:
    #                 # Clean up temporary file
                    os.unlink(temp_file)

    #         except Exception as e:
                logger.error(f"Subprocess execution failed: {e}")
    #             return {
    #                 "success": False,
                    "error": str(e),
    #                 "output": "",
    #                 "execution_time": 0,
    #             }

    #     def _execute_via_import(
    #         self, code: str, context: Optional[Dict[str, Any]]
    #     ) -Dict[str, Any]):
    #         """Execute code by importing nbc_runtime directly."""
    #         try:
    #             import sys
    #             import time

    start_time = time.time()

    #             # Add runtime to path if needed
    runtime_dir = os.path.join(os.path.dirname(self.runtime_path), "..")
    #             if runtime_dir not in sys.path:
                    sys.path.insert(0, runtime_dir)

    #             # Import nbc_runtime
    #             from noodlecore.runtime.nbc_runtime import execute_code

    #             # Execute the code
    result = execute_code(code, context or {})
    execution_time = time.time() - start_time

    #             return {
    #                 "success": True,
    #                 "output": str(result) if result else "",
    #                 "error": "",
    #                 "execution_time": execution_time,
    #                 "result": result,
    #             }

    #         except ImportError as e:
                logger.error(f"Failed to import nbc_runtime: {e}")
    #             return {
    #                 "success": False,
    #                 "error": f"Runtime not available: {e}",
    #                 "output": "",
    #                 "execution_time": 0,
    #             }
    #         except Exception as e:
                logger.error(f"Direct execution failed: {e}")
    #             return {
    #                 "success": False,
                    "error": str(e),
    #                 "output": "",
    #                 "execution_time": 0,
    #             }

    #     def validate_syntax(self, code: str) -Dict[str, Any]):
    #         """
    #         Validate syntax of Noodle code without execution.

    #         Args:
    #             code: The Noodle code to validate

    #         Returns:
    #             Dictionary with validation results
    #         """
    #         try:
    #             # Try to parse the code
    #             from noodlecore.compiler.lexer import Lexer
    #             from noodlecore.compiler.parser import Parser

    lexer = Lexer(code)
    tokens = []

    #             # Collect all tokens
    #             while True:
    token = lexer.next_token()
    #                 if token.type.name == "EOF":
    #                     break
                    tokens.append(token)

    #             # Try to parse
    parser = Parser(tokens)
    ast = parser.parse()

    #             return {
    #                 "valid": True,
                    "tokens_count": len(tokens),
    #                 "ast": ast,
    #                 "errors": [],
    #             }

    #         except Exception as e:
    #             return {
    #                 "valid": False,
                    "error": str(e),
    #                 "tokens_count": 0,
    #                 "ast": None,
                    "errors": [str(e)],
    #             }

    #     def get_completions(
    #         self, code: str, position: Dict[str, int]
    #     ) -List[Dict[str, Any]]):
    #         """
    #         Get code completions at a specific position.

    #         Args:
    #             code: The current code
    #             position: Dictionary with 'line' and 'character' (0-based)

    #         Returns:
    #             List of completion suggestions
    #         """
    #         try:
    #             # Simple completion logic - in production this would be more sophisticated
    completions = []

    #             # Get the current line and context
    lines = code.split("\n")
    #             if position["line"] < len(lines):
    current_line = lines[position["line"]]
    before_cursor = current_line[: position["character"]]

    #                 # Keyword completions
    keywords = [
    #                     "var",
    #                     "func",
    #                     "if",
    #                     "while",
    #                     "for",
    #                     "return",
    #                     "true",
    #                     "false",
    #                 ]
    #                 for keyword in keywords:
    #                     if before_cursor.endswith(keyword[: len(before_cursor)]):
                            completions.append(
    #                             {
    #                                 "label": keyword,
    #                                 "kind": "keyword",
    #                                 "detail": "Noodle keyword",
    #                                 "insertText": keyword,
    #                             }
    #                         )

    #                 # Built-in function completions
    builtins = ["print", "len", "sqrt", "sin", "cos", "tan"]
    #                 for builtin in builtins:
    #                     if before_cursor.endswith(builtin[: len(before_cursor)]):
                            completions.append(
    #                             {
    #                                 "label": builtin,
    #                                 "kind": "function",
    #                                 "detail": "Built-in function",
                                    "insertText": builtin + "()",
    #                             }
    #                         )

    #             return completions

    #         except Exception as e:
                logger.error(f"Error getting completions: {e}")
    #             return []

    #     def clear_cache(self):
    #         """Clear the execution cache."""
            self.execution_cache.clear()
            logger.info("Execution cache cleared")

    #     def get_cache_stats(self) -Dict[str, Any]):
    #         """Get cache statistics."""
    #         return {
                "cache_size": len(self.execution_cache),
                "cache_keys": list(self.execution_cache.keys()),
    #         }


# Import required modules at the end to avoid circular imports
import sys
import tempfile
import time
