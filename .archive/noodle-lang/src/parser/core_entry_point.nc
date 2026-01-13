# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Core Entry Point for Noodle IDE Integration

# This module serves as the entry point for the Noodle Core to handle
# requests from the Noodle IDE. It processes API commands, executes
# Noodle programs, and returns results to the IDE.
# """
import difflib
import json
import os
import re
import shutil
import sys
import tempfile
import traceback
import uuid
import pathlib.Path
import typing.Any

# Add src to path to allow imports from noodle
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

# Import TRM-Agent components
try
    #     from .config.trm_agent_config import load_trm_agent_config
    #     from .compiler.trm_agent_compilation_bridge import TRMAgentCompilationBridge
    #     from .compiler.trm_optimizer import OptimizationType, OptimizationStrategy, OptimizationTarget
    TRM_AGENT_AVAILABLE = True
except ImportError
    TRM_AGENT_AVAILABLE = False

# Import runtime modules with fallback
try
        from noodlecore.runtime.nbc_runtime import (
    #         ErrorHandler,
    #         NBCRuntime,
    #         NBCRuntimeError,
    #         ResourceManager,
    #         RuntimeConfig,
    #         StackManager,
    #         create_runtime,
    #     )
    #     from noodlecore.runtime.sandbox import SandboxManager, init_global_sandbox_manager
except ImportError as e
    print(f"Warning: Runtime modules not available: {e}", file = sys.stderr)
    #     # Create fallback classes
    #     class RuntimeConfig:
    #         def __init__(self, max_stack_size=1000, debug_mode=False):
    self.max_stack_size = max_stack_size
    self.debug_mode = debug_mode
    self.max_execution_time = 30.0
    self.max_memory_usage = 100 * 1024 * 1024
    self.enable_optimization = True
    self.optimization_level = 2
    self.log_level = "INFO"

    #     class NBCRuntime:
    #         def __init__(self, config):
    self.config = config
    self.globals = {}

    #     def create_runtime(config):
            return NBCRuntime(config)

    #     class SandboxManager:
    #         def __init__(self, base_path):
    self.base_path = Path(base_path)
    self.sandboxes = {}

    #         def create_workspace(self, name):
    #             import uuid
    workspace_id = str(uuid.uuid4())
    workspace_path = self.base_path / "sandboxes" / workspace_id
    workspace_path.mkdir(parents = True, exist_ok=True)

    self.sandboxes[workspace_id] = {
                    "path": str(workspace_path),
    #                 "status": "created",
                    "created": str(workspace_path.stat().st_ctime),
                    "modified": str(workspace_path.stat().st_mtime)
    #             }
    #             return workspace_id

    #         def switch_workspace(self, workspace_id):
    #             return workspace_id in self.sandboxes

    #         def get_workspace_diff(self, workspace_id):
    #             return []

    #     def init_global_sandbox_manager(base_path):
            return SandboxManager(base_path)


class CoreAPIHandler
    #     """Handler for API requests from Noodle IDE."""

    #     def __init__(self):""Initialize the API handler."""
    self.runtime = None
    self.sandbox_manager = init_global_sandbox_manager(
                os.path.join(os.path.dirname(__file__), "..", "..", "noodle-project")
    #         )
    self.last_error = None
    self.trm_agent_bridge = None
            self._initialize_runtime()
            self._initialize_trm_agent()

    #     def _initialize_runtime(self):
    #         """Initialize the NBC runtime."""
    #         try:
    config = RuntimeConfig(
    max_stack_size = 1000,
    debug_mode = False
    #             )
    #             # Set additional runtime parameters
    #             config.max_execution_time = 30.0  # 30 seconds for API calls
    config.max_memory_usage = 100 * 1024 * 1024  # 100MB
    config.enable_optimization = True
    config.optimization_level = 2
    config.log_level = "INFO"
    self.runtime = create_runtime(config)
    print("Runtime initialized successfully", file = sys.stderr)
    #         except Exception as e:
    print(f"Failed to initialize runtime: {e}", file = sys.stderr)
    self.last_error = str(e)

    #     def _initialize_trm_agent(self):
    #         """Initialize the TRM-Agent compilation bridge."""
    #         if not TRM_AGENT_AVAILABLE:
    print("TRM-Agent not available, skipping initialization", file = sys.stderr)
    #             return

    #         try:
    #             # Load TRM-Agent configuration
    trm_config = load_trm_agent_config()

    #             # Initialize TRM-Agent compilation bridge
    self.trm_agent_bridge = TRMAgentCompilationBridge(config=trm_config)

    print("TRM-Agent initialized successfully", file = sys.stderr)
    #         except Exception as e:
    print(f"Failed to initialize TRM-Agent: {e}", file = sys.stderr)
    self.trm_agent_bridge = None

    #     def handle_request(self, request: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle an API request from the IDE.

    #         Args:
    #             request: The request data with 'command' and optional parameters

    #         Returns:
    #             Response data
    #         """
    #         try:
    command = request.get("command")
    params = request.get("params", {})

    #             if not command:
                    raise ValueError("Missing 'command' in request")

    print(f"Processing command: {command}", file = sys.stderr)

    #             # Dispatch to appropriate handler
    #             if command == "execute":
                    return self._handle_execute(params)
    #             elif command == "build":
                    return self._handle_build(params)
    #             elif command == "read_file":
                    return self._handle_read_file(params)
    #             elif command == "write_file":
                    return self._handle_write_file(params)
    #             elif command == "list_directory":
                    return self._handle_list_directory(params)
    #             elif command == "get_runtime_state":
                    return self._handle_get_runtime_state()
    #             elif command == "reset_runtime":
                    return self._handle_reset_runtime()
    #             # TRM-Agent API
    #             elif command == "trm_agent_compile":
                    return self._handle_trm_agent_compile(params)
    #             elif command == "trm_agent_status":
                    return self._handle_trm_agent_status()
    #             elif command == "trm_agent_config":
                    return self._handle_trm_agent_config(params)
    #             # Workspace / Sandbox API
    #             elif command == "workspaces":
                    return self._handle_list_workspaces()
    #             elif command == "create_workspace":
                    return self._handle_create_workspace(params)
    #             elif command == "workspace_switch":
                    return self._handle_switch_workspace(params)
    #             elif command == "workspace_diff":
                    return self._handle_workspace_diff(params)
    #             elif command == "workspace_merge":
                    return self._handle_workspace_merge(params)
    #             else:
                    raise ValueError(f"Unknown command: {command}")

    #         except Exception as e:
    print(f"Error handling request: {e}", file = sys.stderr)
    traceback.print_exc(file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "details": traceback.format_exc(),
    #             }

    #     def _compile_code_to_instructions(self, code: str) -List[Dict[str, Any]]):
    #         """
    #         Compile Noodle code to instructions.

    #         This is a simplified implementation for testing.
    #         In a full implementation, this would use the Noodle compiler.
    #         """
    #         try:
    #             # For now, create simple instructions based on code patterns
    instructions = []

    #             # Split code into lines
    lines = code.strip().split("\n")

    #             for line_num, line in enumerate(lines, 1):
    line = line.strip()
    #                 if not line or line.startswith("#"):
    #                     continue

    #                 # Simple pattern matching for basic operations
    #                 # First check for print statements with quotes
    #                 if line.startswith('print(') and ')' in line:
    #                     # Extract content between quotes
    match = re.match(r'print\(["\']([^"\']+)["\']\)', line)
    #                     if match:
                            instructions.append({
    #                             "type": "print",
                                "value": match.group(1),
    #                             "line": line_num
    #                         })
    #                 elif line.startswith("print "):
    #                     # Print instruction - create a simple print operation
                        instructions.append({
    #                         "type": "print",
                            "value": line[6:].strip(),
    #                         "line": line_num
    #                     })
    #                 elif "=" in line and not line.startswith("#"):
    #                     # Assignment instruction
    parts = line.split("=", 1)
    var_name = parts[0].strip()
    value = parts[1].strip()

    #                     # Check if value is a math operation
    #                     if value.startswith("") and ")" in value:
                            # Parse math.add(a + b
    match = re.match(r"math\.add\(([^,]+),\s*([^)]+)\)", value)
    #                         if match:
    a, b = match.groups()
                                instructions.append({
    #                                 "type": "math_add",
    #                                 "variable": var_name,
                                    "a": a.strip(),
                                    "b": b.strip(),
    #                                 "line": line_num
    #                             })
    #                             continue  # Skip the regular assignment
    #                     elif value.startswith("") and ")" in value:
                            # Parse math.subtract(a - b
    match = re.match(r"math\.subtract\(([^,]+),\s*([^)]+)\)", value)
    #                         if match:
    a, b = match.groups()
                                instructions.append({
    #                                 "type": "math_subtract",
    #                                 "variable": var_name,
                                    "a": a.strip(),
                                    "b": b.strip(),
    #                                 "line": line_num
    #                             })
    #                             continue  # Skip the regular assignment

    #                     # Regular assignment - Try to parse as number
    #                     try:
    #                         num_value = float(value) if "." in value else int(value)
                            instructions.append({
    #                             "type": "assign",
    #                             "variable": var_name,
    #                             "value": num_value,
    #                             "line": line_num
    #                         })
    #                     except ValueError:
    #                         # String value
                            instructions.append({
    #                             "type": "assign",
    #                             "variable": var_name,
                                "value": value.strip("\"'"),
    #                             "line": line_num
    #                         })
    #                 elif line.startswith("math."):
    #                     # Math operation
    #                     if line.startswith(""):
                            # Parse math.add(a + b
    match = re.match(r"math\.add\(([^,]+),\s*([^)]+)\)", line)
    #                         if match:
    a, b = match.groups()
                                instructions.append({
    #                                 "type": "math_add",
                                    "a": a.strip(),
                                    "b": b.strip(),
    #                                 "line": line_num
    #                             })
    #                     elif line.startswith(""):
                            # Parse math.subtract(a - b
    match = re.match(r"math\.subtract\(([^,]+),\s*([^)]+)\)", line)
    #                         if match:
    a, b = match.groups()
                                instructions.append({
    #                                 "type": "math_subtract",
                                    "a": a.strip(),
                                    "b": b.strip(),
    #                                 "line": line_num
    #                             })
    #                 else:
    #                     # Unknown instruction type
                        instructions.append({
    #                         "type": "unknown",
    #                         "code": line,
    #                         "line": line_num
    #                     })

    #             return instructions

    #         except Exception as e:
    print(f"Error compiling code: {e}", file = sys.stderr)
    #             # Return empty instructions on error
    #             return []

    #     def _handle_execute(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'execute' command."""
    #         try:
    code = params.get("code")
    #             if not code:
                    raise ValueError("Missing 'code' parameter")

    #             # Create instructions from code
    instructions = self._compile_code_to_instructions(code)

    #             # For debugging: print the generated instructions
    print(f"Generated instructions: {instructions}", file = sys.stderr)

    #             # Load and execute program
    #             if self.runtime:
    #                 # Simple execution for testing - use the built-in functions
    #                 if instructions:
    #                     # Execute each instruction
    #                     for instruction in instructions:
    #                         if instruction["type"] == "print":
    #                             # Check if the value is a variable in globals
    value = instruction["value"]
    #                             if hasattr(self.runtime, 'globals') and value in self.runtime.globals:
                                    print(self.runtime.globals[value])
    #                             else:
                                    print(value)
    #                         elif instruction["type"] == "assign":
    #                             # Handle assignment by storing in the runtime
    #                             if hasattr(self.runtime, 'globals'):
    self.runtime.globals[instruction["variable"]] = instruction["value"]
    #                             else:
    #                                 # Fallback: just print the assignment
    print(f"Assigning {instruction['variable']} = {instruction['value']}")
    #                         elif instruction["type"] == "math_add":
    #                             # Handle math.add operation
    a = instruction["a"]
    b = instruction["b"]
    variable = instruction.get("variable", "result")

    #                             # Get values from globals or parse as numbers
    a_val = None
    b_val = None

    #                             if hasattr(self.runtime, 'globals'):
    #                                 # Check if a and b are variables in globals
    #                                 if a in self.runtime.globals:
    a_val = self.runtime.globals[a]
    #                                 if b in self.runtime.globals:
    b_val = self.runtime.globals[b]

    #                             # If not in globals, try to parse as numbers
    #                             if a_val is None:
    #                                 try:
    #                                     a_val = float(a) if "." in a else int(a)
    #                                 except ValueError:
    #                                     pass

    #                             if b_val is None:
    #                                 try:
    #                                     b_val = float(b) if "." in b else int(b)
    #                                 except ValueError:
    #                                     pass

    #                             # If both values are numbers, perform addition
    #                             if isinstance(a_val, (int, float)) and isinstance(b_val, (int, float)):
    result = a_val + b_val
    print(f"{a} + {b} = {result}")
    #                                 # Store result in variable
    #                                 if hasattr(self.runtime, 'globals'):
    self.runtime.globals[variable] = result
    #                                 else:
    print(f"Assigning {variable} = {result}")
    #                             else:
                                    print(f"Cannot add {a} and {b}: not valid numbers or variables")

    #                         elif instruction["type"] == "math_subtract":
    #                             # Handle math.subtract operation
    a = instruction["a"]
    b = instruction["b"]
    variable = instruction.get("variable", "result")

    #                             # Get values from globals or parse as numbers
    a_val = None
    b_val = None

    #                             if hasattr(self.runtime, 'globals'):
    #                                 # Check if a and b are variables in globals
    #                                 if a in self.runtime.globals:
    a_val = self.runtime.globals[a]
    #                                 if b in self.runtime.globals:
    b_val = self.runtime.globals[b]

    #                             # If not in globals, try to parse as numbers
    #                             if a_val is None:
    #                                 try:
    #                                     a_val = float(a) if "." in a else int(a)
    #                                 except ValueError:
    #                                     pass

    #                             if b_val is None:
    #                                 try:
    #                                     b_val = float(b) if "." in b else int(b)
    #                                 except ValueError:
    #                                     pass

    #                             # If both values are numbers, perform subtraction
    #                             if isinstance(a_val, (int, float)) and isinstance(b_val, (int, float)):
    result = a_val - b_val
    print(f"{a} - {b} = {result}")
    #                                 # Store result in variable
    #                                 if hasattr(self.runtime, 'globals'):
    self.runtime.globals[variable] = result
    #                                 else:
    print(f"Assigning {variable} = {result}")
    #                             else:
                                    print(f"Cannot subtract {b} from {a}: not valid numbers or variables")

    #             return {
    #                 "status": "success",
    #                 "output": "Execution completed successfully",
                    "instructions": len(instructions),
    #                 "message": "Code executed successfully"
    #             }

    #         except Exception as e:
    print(f"Error executing code: {e}", file = sys.stderr)
    traceback.print_exc(file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "details": traceback.format_exc(),
    #             }

    #     def _handle_build(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'build' command to compile Noodle source code to NBC bytecode."""
    #         try:
    source_code = params.get("source_code")
    source_file = params.get("source_file")
    output_file = params.get("output_file")
    optimization_level = params.get("optimization_level", 2)
    target = params.get("target", "nbc")

    #             if not source_code and not source_file:
                    raise ValueError("Missing 'source_code' or 'source_file' parameter")

    #             # If source_file is provided but not source_code, read the file
    #             if source_file and not source_code:
    file_path = Path(source_file)
    #                 if not file_path.exists():
    #                     return {
    #                         "status": "error",
    #                         "error": f"Source file not found: {source_file}"
    #                     }

    #                 with open(file_path, 'r', encoding='utf-8') as f:
    source_code = f.read()

    #             # Create instructions from source code
    instructions = self._compile_code_to_instructions(source_code)

    #             # Generate bytecode based on target
    #             if target == "nbc":
    #                 # Create NBC bytecode
    bytecode = {
    #                     "version": "1.0",
    #                     "format": "nbc",
    #                     "instructions": instructions,
    #                     "metadata": {
    #                         "source_file": source_file,
    #                         "optimization_level": optimization_level,
                            "compilation_time": str(uuid.uuid4())
    #                     }
    #                 }
    #             elif target == "python":
                    # Convert to Python code (simplified)
    bytecode = self._convert_to_python(source_code, instructions)
    #             elif target == "javascript":
                    # Convert to JavaScript code (simplified)
    bytecode = self._convert_to_javascript(source_code, instructions)
    #             else:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Unsupported target: {target}"
    #                 }

    #             # Prepare response
    response = {
    #                 "status": "success",
    #                 "bytecode": bytecode,
    #                 "build_info": {
    #                     "source_file": source_file,
    #                     "output_file": output_file,
    #                     "target": target,
    #                     "optimization_level": optimization_level,
                        "instructions_count": len(instructions)
    #                 }
    #             }

    #             # If output_file is specified, write the bytecode to file
    #             if output_file:
    output_path = Path(output_file)
    output_path.parent.mkdir(parents = True, exist_ok=True)

    #                 with open(output_path, 'w', encoding='utf-8') as f:
    #                     if isinstance(bytecode, dict):
    json.dump(bytecode, f, indent = 2)
    #                     else:
                            f.write(bytecode)

    response["message"] = f"Successfully built to {output_file}"

    #             return response

    #         except Exception as e:
    print(f"Error building code: {e}", file = sys.stderr)
    traceback.print_exc(file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "details": traceback.format_exc(),
    #             }

    #     def _convert_to_python(self, source_code: str, instructions: List[Dict[str, Any]]) -str):
    #         """Convert Noodle instructions to Python code."""
    python_code = "# Generated Python code from Noodle source\n\n"

    #         for instruction in instructions:
    #             if instruction["type"] == "print":
    value = instruction["value"]
    python_code + = f"print({value})\n"
    #             elif instruction["type"] == "assign":
    var = instruction["variable"]
    value = instruction["value"]
    python_code + = f"{var} = {value}\n"
    #             elif instruction["type"] == "math_add":
    a = instruction["a"]
    b = instruction["b"]
    var = instruction.get("variable", "result")
    python_code + = f"{var} = {a} + {b}\n"
    #             elif instruction["type"] == "math_subtract":
    a = instruction["a"]
    b = instruction["b"]
    var = instruction.get("variable", "result")
    python_code + = f"{var} = {a} - {b}\n"

    #         return python_code

    #     def _convert_to_javascript(self, source_code: str, instructions: List[Dict[str, Any]]) -str):
    #         """Convert Noodle instructions to JavaScript code."""
    js_code = "// Generated JavaScript code from Noodle source\n\n"

    #         for instruction in instructions:
    #             if instruction["type"] == "print":
    value = instruction["value"]
    js_code + = f"console.log({value});\n"
    #             elif instruction["type"] == "assign":
    var = instruction["variable"]
    value = instruction["value"]
    js_code + = f"let {var} = {value};\n"
    #             elif instruction["type"] == "math_add":
    a = instruction["a"]
    b = instruction["b"]
    var = instruction.get("variable", "result")
    js_code + = f"let {var} = {a} + {b};\n"
    #             elif instruction["type"] == "math_subtract":
    a = instruction["a"]
    b = instruction["b"]
    var = instruction.get("variable", "result")
    js_code + = f"let {var} = {a} - {b};\n"

    #         return js_code

    #     def _handle_read_file(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'read_file' command."""
    #         try:
    file_path = params.get("path")
    #             if not file_path:
                    raise ValueError("Missing 'path' parameter")

    file_path = Path(file_path)
    #             if not file_path.exists():
    #                 return {
    #                     "status": "error",
    #                     "error": f"File not found: {file_path}"
    #                 }

    #             with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #             return {
    #                 "status": "success",
    #                 "content": content,
                    "path": str(file_path),
                    "size": len(content)
    #             }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_write_file(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'write_file' command."""
    #         try:
    file_path = params.get("path")
    content = params.get("content", "")
    create_dirs = params.get("create_dirs", False)

    #             if not file_path:
                    raise ValueError("Missing 'path' parameter")

    file_path = Path(file_path)

    #             if create_dirs and not file_path.parent.exists():
    file_path.parent.mkdir(parents = True, exist_ok=True)

    #             with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)

    #             return {
    #                 "status": "success",
                    "path": str(file_path),
                    "size": len(content)
    #             }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_list_directory(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'list_directory' command."""
    #         try:
    dir_path = params.get("path", ".")
    dir_path = Path(dir_path)

    #             if not dir_path.exists():
    #                 return {
    #                     "status": "error",
    #                     "error": f"Directory not found: {dir_path}"
    #                 }

    #             if not dir_path.is_dir():
    #                 return {
    #                     "status": "error",
    #                     "error": f"Path is not a directory: {dir_path}"
    #                 }

    items = []
    #             for item in dir_path.iterdir():
                    items.append({
    #                     "name": item.name,
                        "path": str(item),
                        "is_dir": item.is_dir(),
    #                     "size": item.stat().st_size if item.is_file() else 0,
                        "modified": item.stat().st_mtime
    #                 })

    #             return {
    #                 "status": "success",
                    "path": str(dir_path),
    #                 "items": items,
                    "count": len(items)
    #             }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_get_runtime_state(self) -Dict[str, Any]):
    #         """Handle 'get_runtime_state' command."""
    #         try:
    state = {
    #                 "runtime_initialized": self.runtime is not None,
    #                 "sandbox_manager_active": self.sandbox_manager is not None,
    #                 "last_error": self.last_error
    #             }

    #             if self.runtime:
                    state.update({
                        "max_stack_size": getattr(self.runtime.config, 'max_stack_size', 0),
                        "debug_mode": getattr(self.runtime.config, 'debug_mode', False),
                        "max_execution_time": getattr(self.runtime.config, 'max_execution_time', 0),
                        "max_memory_usage": getattr(self.runtime.config, 'max_memory_usage', 0),
                        "enable_optimization": getattr(self.runtime.config, 'enable_optimization', False),
                        "optimization_level": getattr(self.runtime.config, 'optimization_level', 0)
    #                 })

    #             return {
    #                 "status": "success",
    #                 "state": state
    #             }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_reset_runtime(self) -Dict[str, Any]):
    #         """Handle 'reset_runtime' command."""
    #         try:
    #             # Reset runtime
    self.runtime = None
                self._initialize_runtime()

    #             return {
    #                 "status": "success",
    #                 "message": "Runtime reset successfully"
    #             }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_list_workspaces(self) -Dict[str, Any]):
    #         """Handle 'workspaces' command."""
    #         try:
    workspaces = []
    #             if self.sandbox_manager:
    #                 for workspace_id, workspace in self.sandbox_manager.sandboxes.items():
                        workspaces.append({
    #                         "id": workspace_id,
                            "path": workspace.get("path", ""),
                            "status": workspace.get("status", "unknown"),
                            "created": workspace.get("created", ""),
                            "modified": workspace.get("modified", "")
    #                     })

    #             return {
    #                 "status": "success",
    #                 "workspaces": workspaces,
                    "count": len(workspaces)
    #             }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_create_workspace(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'create_workspace' command."""
    #         try:
    workspace_name = params.get("name")
    #             if not workspace_name:
                    raise ValueError("Missing 'name' parameter")

    #             if not self.sandbox_manager:
    #                 return {
    #                     "status": "error",
    #                     "error": "Sandbox manager not initialized"
    #                 }

    workspace_id = self.sandbox_manager.create_workspace(workspace_name)
    #             if workspace_id:
    #                 return {
    #                     "status": "success",
    #                     "workspace_id": workspace_id,
    #                     "message": f"Workspace '{workspace_name}' created successfully"
    #                 }
    #             else:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Failed to create workspace '{workspace_name}'"
    #                 }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_switch_workspace(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'workspace_switch' command."""
    #         try:
    workspace_id = params.get("workspace_id")
    #             if not workspace_id:
                    raise ValueError("Missing 'workspace_id' parameter")

    #             if not self.sandbox_manager:
    #                 return {
    #                     "status": "error",
    #                     "error": "Sandbox manager not initialized"
    #                 }

    success = self.sandbox_manager.switch_workspace(workspace_id)
    #             if success:
    #                 return {
    #                     "status": "success",
    #                     "workspace_id": workspace_id,
    #                     "message": f"Switched to workspace '{workspace_id}'"
    #                 }
    #             else:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Failed to switch to workspace '{workspace_id}'"
    #                 }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_workspace_diff(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'workspace_diff' command."""
    #         try:
    workspace_id = params.get("workspace_id")
    #             if not workspace_id:
                    raise ValueError("Missing 'workspace_id' parameter")

    #             if not self.sandbox_manager:
    #                 return {
    #                     "status": "error",
    #                     "error": "Sandbox manager not initialized"
    #                 }

    diff_result = self.sandbox_manager.get_workspace_diff(workspace_id)
    #             if diff_result:
    #                 return {
    #                     "status": "success",
    #                     "workspace_id": workspace_id,
    #                     "changes": diff_result,
    #                     "message": f"Workspace diff generated for '{workspace_id}'"
    #                 }
    #             else:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Failed to generate diff for workspace '{workspace_id}'"
    #                 }

    #         except Exception as e:
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_workspace_merge(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'workspace_merge' command."""
    #         try:
    workspace_id = params.get("workspace_id")
    strategy = params.get("strategy", "merge")

    #             if not workspace_id:
                    raise ValueError("Missing 'workspace_id' parameter")

    #             if not self.sandbox_manager:
    #                 return {
    #                     "status": "error",
    #                     "error": "Sandbox manager not initialized"
    #                 }

    #             # Get workspace path
    sandbox_path = Path(self.sandbox_manager.sandboxes[workspace_id]["path"])

    #             # Get changes from diff
    changes = self.sandbox_manager.get_workspace_diff(workspace_id)

    #             # Copy changed files from sandbox to base project
    base_project_path = Path(
                    os.path.join(os.path.dirname(__file__), "..", "..", "noodle-project")
    #             )
    merged_files = 0
    merge_details = []

    #             for change in changes:
    #                 if change.startswith(("ADDED:", "MODIFIED:")):
    filename = change.split(": ", 1)[1]
    sandbox_file = math.divide(sandbox_path, filename)
    base_file = math.divide(base_project_path, filename)

    #                     if sandbox_file.exists():
    #                         # Ensure target directory exists
    base_file.parent.mkdir(parents = True, exist_ok=True)

    #                         # Copy file
                            shutil.copy2(sandbox_file, base_file)
                            merge_details.append(f"Merged: {filename}")
    merged_files + = 1
    #                 elif change.startswith("ERROR"):
                        merge_details.append(f"Skipped (error): {change}")

    #             # Update workspace status
    #             if workspace_id in self.sandbox_manager.sandboxes:
    self.sandbox_manager.sandboxes[workspace_id]["status"] = "merged"

    #             return {
    #                 "status": "success",
    #                 "workspace_id": workspace_id,
    #                 "message": f"Workspace merge completed using strategy: {strategy}",
    #                 "merged_files": merged_files,
    #                 "strategy": strategy,
    #                 "details": merge_details,
    #             }

    #         except Exception as e:
    print(f"Error merging workspace: {e}", file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "message": f'Failed to merge workspace: {params.get("workspace_id", "unknown")}',
    #             }

    #     def _handle_trm_agent_compile(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'trm_agent_compile' command."""
    #         try:
    #             if not self.trm_agent_bridge:
    #                 return {
    #                     "status": "error",
    #                     "error": "TRM-Agent not available"
    #                 }

    source_code = params.get("code")
    #             if not source_code:
                    raise ValueError("Missing 'code' parameter")

    filename = params.get("filename", "<string>")

    #             # Get optimization parameters
    optimization_types_str = params.get("optimization_types", ["custom"])
    optimization_types = []
    #             for opt_type_str in optimization_types_str:
    #                 try:
                        optimization_types.append(OptimizationType(opt_type_str))
    #                 except ValueError:
    #                     return {
    #                         "status": "error",
    #                         "error": f"Invalid optimization type: {opt_type_str}"
    #                     }

    optimization_strategy_str = params.get("optimization_strategy", "balanced")
    #             try:
    optimization_strategy = OptimizationStrategy(optimization_strategy_str)
    #             except ValueError:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Invalid optimization strategy: {optimization_strategy_str}"
    #                 }

    optimization_target_str = params.get("optimization_target", "balanced")
    #             try:
    optimization_target = OptimizationTarget(optimization_target_str)
    #             except ValueError:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Invalid optimization target: {optimization_target_str}"
    #                 }

    enable_feedback = params.get("enable_feedback", True)

    #             # Compile with TRM-Agent
    result = self.trm_agent_bridge.compile_with_trm_agent(
    source_code = source_code,
    filename = filename,
    optimization_types = optimization_types,
    optimization_strategy = optimization_strategy,
    optimization_target = optimization_target,
    enable_feedback = enable_feedback
    #             )

    #             # Convert result to dictionary
    #             return {
    #                 "status": "success" if result.success else "error",
    #                 "request_id": result.request_id,
    #                 "compilation_status": result.status.value,
    #                 "success": result.success,
    #                 "compilation_time": result.compilation_time,
    #                 "optimization_time": result.optimization_time,
    #                 "error_message": result.error_message,
    #                 "metadata": result.metadata
    #             }

    #         except Exception as e:
    print(f"Error in TRM-Agent compilation: {e}", file = sys.stderr)
    traceback.print_exc(file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "details": traceback.format_exc(),
    #             }

    #     def _handle_trm_agent_status(self) -Dict[str, Any]):
    #         """Handle 'trm_agent_status' command."""
    #         try:
    #             if not self.trm_agent_bridge:
    #                 return {
    #                     "status": "error",
    #                     "error": "TRM-Agent not available"
    #                 }

    #             # Get compilation statistics
    stats = self.trm_agent_bridge.get_compilation_statistics()

    #             return {
    #                 "status": "success",
    #                 "trm_agent_available": True,
    #                 "statistics": stats
    #             }

    #         except Exception as e:
    print(f"Error getting TRM-Agent status: {e}", file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }

    #     def _handle_trm_agent_config(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle 'trm_agent_config' command."""
    #         try:
    #             if not self.trm_agent_bridge:
    #                 return {
    #                     "status": "error",
    #                     "error": "TRM-Agent not available"
    #                 }

    action = params.get("action", "get")

    #             if action == "get":
    #                 # Get current configuration
    #                 from .config.trm_agent_config import get_config_adapter
    adapter = get_config_adapter()
    config_summary = adapter.get_config_summary()

    #                 return {
    #                     "status": "success",
    #                     "config": config_summary
    #                 }

    #             elif action == "reset_statistics":
    #                 # Reset compilation statistics
                    self.trm_agent_bridge.reset_compilation_statistics()

    #                 return {
    #                     "status": "success",
    #                     "message": "TRM-Agent statistics reset successfully"
    #                 }

    #             else:
    #                 return {
    #                     "status": "error",
    #                     "error": f"Unknown action: {action}"
    #                 }

    #         except Exception as e:
    print(f"Error handling TRM-Agent config: {e}", file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e)
    #             }


function main()
    #     """Main entry point for the core API."""
    handler = CoreAPIHandler()

    #     # Read JSON request from stdin
    #     try:
    input_data = sys.stdin.read()
    request = json.loads(input_data)
    #     except json.JSONDecodeError as e:
    print(f"Invalid JSON request: {e}", file = sys.stderr)
    response = {"status": "error", "error": f"Invalid JSON: {str(e)}"}
            print(json.dumps(response))
            sys.exit(1)
    #     except Exception as e:
    print(f"Error reading request: {e}", file = sys.stderr)
    response = {"status": "error", "error": f"Read error: {str(e)}"}
            print(json.dumps(response))
            sys.exit(1)

    #     # Handle request
    response = handler.handle_request(request)

    #     # Send response to stdout
    print(json.dumps(response, indent = 2))

    #     # Exit with appropriate code
    #     sys.exit(0 if response.get("status") == "success" else 1)


class CoreEntryPoint
    #     """
    #     Main entry point for NoodleCore system initialization and management.

    #     This class provides the primary interface for initializing and managing
    #     the NoodleCore runtime environment, including configuration loading,
    #     component initialization, and system lifecycle management.
    #     """

    #     def __init__(self, config: Optional["NoodleCoreConfig"] = None):""
    #         Initialize the CoreEntryPoint with optional configuration.

    #         Args:
    #             config: Optional NoodleCoreConfig instance. If not provided,
    #                    a default configuration will be created.
    #         """
    #         # Import here to avoid circular imports
    #         try:
    #             from .config import NoodleCoreConfig
    #         except ImportError:
    #             # Fallback for when config module is not available
    #             class NoodleCoreConfig:
    #                 def __init__(self):
    self.environment = "development"
    self.debug = True
    self.max_stack_size = 1000
    self.max_execution_time = 30.0
    self.max_memory_usage = 100 * 1024 * 1024
    self.enable_optimization = True
    self.optimization_level = 2
    self.host = "0.0.0.0"
    self.port = 8080
    self.request_timeout = 30
    self.db_connection_pool_size = 20
    self.db_connection_timeout = 30
    self.jwt_expiration_time = 7200
    self.log_level = "INFO"
    self.custom_settings = {}

    self.config = config or NoodleCoreConfig()
    self.runtime = None
    self.sandbox_manager = None
    self.initialized = False
    self.error_handler = None

    #         # Initialize logging
            self._setup_logging()

    #     def _setup_logging(self):
    #         """Setup logging based on configuration."""
    #         import logging
    #         import sys

    log_level = getattr(logging, self.config.log_level.upper(), logging.INFO)
            logging.basicConfig(
    level = log_level,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream = sys.stderr
    #         )
    self.logger = logging.getLogger(__name__)

    #     def initialize(self) -bool):
    #         """
    #         Initialize the NoodleCore system components.

    #         Returns:
    #             True if initialization was successful, False otherwise.
    #         """
    #         try:
                self.logger.info("Initializing NoodleCore system...")

    #             # Initialize runtime
    #             if not self._initialize_runtime():
                    self.logger.error("Failed to initialize runtime")
    #                 return False

    #             # Initialize sandbox manager
    #             if not self._initialize_sandbox_manager():
                    self.logger.error("Failed to initialize sandbox manager")
    #                 return False

    self.initialized = True
                self.logger.info("NoodleCore system initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize NoodleCore: {e}")
    #             if self.error_handler:
                    self.error_handler(e, {"context": "initialization"})
    #             return False

    #     def _initialize_runtime(self) -bool):
    #         """
    #         Initialize the runtime component.

    #         Returns:
    #             True if initialization was successful, False otherwise.
    #         """
    #         try:
    #             # Create runtime configuration
    runtime_config = RuntimeConfig(
    max_stack_size = self.config.max_stack_size,
    debug_mode = self.config.debug
    #             )

    #             # Set additional runtime parameters
    runtime_config.max_execution_time = self.config.max_execution_time
    runtime_config.max_memory_usage = self.config.max_memory_usage
    runtime_config.enable_optimization = self.config.enable_optimization
    runtime_config.optimization_level = self.config.optimization_level
    runtime_config.log_level = self.config.log_level

    #             # Create runtime instance
    self.runtime = create_runtime(runtime_config)

                self.logger.info("Runtime initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize runtime: {e}")
    #             return False

    #     def _initialize_sandbox_manager(self) -bool):
    #         """
    #         Initialize the sandbox manager component.

    #         Returns:
    #             True if initialization was successful, False otherwise.
    #         """
    #         try:
    #             import os
    #             from pathlib import Path

    #             # Create sandbox base path
    base_path = Path(os.path.join(os.path.dirname(__file__), "..", "..", "noodle-project"))
    base_path.mkdir(parents = True, exist_ok=True)

    #             # Initialize sandbox manager
    self.sandbox_manager = init_global_sandbox_manager(str(base_path))

                self.logger.info("Sandbox manager initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize sandbox manager: {e}")
    #             return False

    #     def shutdown(self) -bool):
    #         """
    #         Shutdown the NoodleCore system components.

    #         Returns:
    #             True if shutdown was successful, False otherwise.
    #         """
    #         try:
                self.logger.info("Shutting down NoodleCore system...")

    #             # Shutdown sandbox manager
    #             if self.sandbox_manager:
    #                 # In a real implementation, this would properly shutdown the sandbox manager
    self.sandbox_manager = None

    #             # Shutdown runtime
    #             if self.runtime:
    #                 # In a real implementation, this would properly shutdown the runtime
    self.runtime = None

    self.initialized = False
                self.logger.info("NoodleCore system shutdown successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to shutdown NoodleCore: {e}")
    #             if self.error_handler:
                    self.error_handler(e, {"context": "shutdown"})
    #             return False

    #     def get_status(self) -Dict[str, Any]):
    #         """
    #         Get the current status of the NoodleCore system.

    #         Returns:
    #             Dictionary containing system status information.
    #         """
    #         return {
    #             "initialized": self.initialized,
    #             "runtime_active": self.runtime is not None,
    #             "sandbox_manager_active": self.sandbox_manager is not None,
    #             "environment": self.config.environment,
    #             "debug_mode": self.config.debug,
    #             "log_level": self.config.log_level
    #         }

    #     def set_error_handler(self, handler: Callable[[Exception, Dict[str, Any]], None]):
    #         """
    #         Set a custom error handler for the system.

    #         Args:
    #             handler: Function that takes an exception and context dictionary
    #         """
    self.error_handler = handler
            self.logger.info("Custom error handler registered")

    #     def execute_command(self, command: str, params: Optional[Dict[str, Any]] = None) -Dict[str, Any]):
    #         """
    #         Execute a command in the NoodleCore system.

    #         Args:
    #             command: Command to execute
    #             params: Optional parameters for the command

    #         Returns:
    #             Dictionary containing the execution result
    #         """
    #         if not self.initialized:
    #             return {
    #                 "status": "error",
    #                 "error": "NoodleCore system is not initialized",
    #                 "error_code": 1001
    #             }

    #         try:
    #             # Create a handler instance to process the command
    handler = CoreAPIHandler()

    #             # Create request dictionary
    request = {
    #                 "command": command,
    #                 "params": params or {}
    #             }

    #             # Handle the request
    result = handler.handle_request(request)

    #             return result

    #         except Exception as e:
                self.logger.error(f"Failed to execute command '{command}': {e}")
    #             if self.error_handler:
                    self.error_handler(e, {"command": command, "params": params})

    #             return {
    #                 "status": "error",
                    "error": str(e),
    #                 "error_code": 1002
    #             }

    #     def __str__(self) -str):
    #         """String representation of the CoreEntryPoint."""
    return f"CoreEntryPoint(initialized = {self.initialized}, environment={self.config.environment})"

    #     def __repr__(self) -str):
    #         """Debug representation of the CoreEntryPoint."""
    return (f"CoreEntryPoint(initialized = {self.initialized}, "
    f"runtime = {self.runtime is not None}, "
    f"sandbox = {self.sandbox_manager is not None})")


if __name__ == "__main__"
        main()