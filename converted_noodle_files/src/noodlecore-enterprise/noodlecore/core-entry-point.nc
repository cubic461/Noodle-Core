# Converted from Python to NoodleCore
# Original file: noodle-core

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
import typing.Any,

# Add src to path to allow imports from noodle
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

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
    print(f"Error importing Noodle modules: {e}", file = sys.stderr)
        sys.exit(1)


class CoreAPIHandler
    #     """Handler for API requests from Noodle IDE."""

    #     def __init__(self):
    #         """Initialize the API handler."""
    self.runtime = None
    self.sandbox_manager = init_global_sandbox_manager(
                os.path.join(os.path.dirname(__file__), "noodle-project")
    #         )
    self.last_error = None
            self._initialize_runtime()

    #     def _initialize_runtime(self):
    #         """Initialize the NBC runtime."""
    #         try:
    config = RuntimeConfig(
    max_stack_size = 1000,
    debug_mode = False
    #             )
    #             # Set additional runtime parameters
    #             config.max_execution_time = 30.0  # 30 seconds for API calls
    config.max_memory_usage = math.multiply(100, 1024 * 1024  # 100MB)
    config.enable_optimization = True
    config.optimization_level = 2
    config.log_level = "INFO"
    self.runtime = create_runtime(config)
    print("Runtime initialized successfully", file = sys.stderr)
    #         except Exception as e:
    print(f"Failed to initialize runtime: {e}", file = sys.stderr)
    self.last_error = str(e)

    #     def handle_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
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

    #     def _compile_code_to_instructions(self, code: str) -> List[Dict[str, Any]]:
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
    #                     if value.startswith("math.add(") and ")" in value:
                            # Parse math.add(a, b)
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
    #                     elif value.startswith("math.subtract(") and ")" in value:
                            # Parse math.subtract(a, b)
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
    #                     if line.startswith("math.add("):
                            # Parse math.add(a, b)
    match = re.match(r"math\.add\(([^,]+),\s*([^)]+)\)", line)
    #                         if match:
    a, b = match.groups()
                                instructions.append({
    #                                 "type": "math_add",
                                    "a": a.strip(),
                                    "b": b.strip(),
    #                                 "line": line_num
    #                             })
    #                     elif line.startswith("math.subtract("):
                            # Parse math.subtract(a, b)
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

    #     def _handle_execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
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
    result = math.add(a_val, b_val)
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
    result = math.subtract(a_val, b_val)
    print(f"{a} - {b} = {result}")
    #                                 # Store result in variable
    #                                 if hasattr(self.runtime, 'globals'):
    self.runtime.globals[variable] = result
    #                                 else:
    print(f"Assigning {variable} = {result}")
    #                             else:
                                    print(f"Cannot subtract {a} and {b}: not valid numbers or variables")

    #                 # Get stack result
    stack_result = None
    #                 if (
    #                     self.runtime.stack_manager
                        and hasattr(self.runtime.stack_manager, "frames")
                        and len(self.runtime.stack_manager.frames) > 0
    #                 ):
    stack_result = self.runtime.stack_manager.current_frame

    #                 return {
    #                     "status": "success",
    #                     "result": stack_result,
    #                     "metrics": self.runtime.get_metrics().to_dict() if hasattr(self.runtime, 'get_metrics') else {},
    #                     "output": f"Executed: {code}",
    #                 }
    #             else:
                    raise RuntimeError("Runtime not initialized")

    #         except Exception as e:
    print(f"Execute error: {e}", file = sys.stderr)
    #             import traceback
    traceback.print_exc(file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
    #                 "output": f"Error executing code: {e}",
    #             }

    #     def _handle_read_file(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'read_file' command."""
    #         try:
    file_path = params.get("path")
    #             if not file_path:
                    raise ValueError("Missing 'path' parameter")

    #             with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

    #             return {"status": "success", "content": content, "path": file_path}

    #         except Exception as e:
                return {"status": "error", "error": str(e), "path": params.get("path", "")}

    #     def _handle_write_file(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'write_file' command."""
    #         try:
    file_path = params.get("path")
    content = params.get("content")

    #             if not file_path:
                    raise ValueError("Missing 'path' parameter")
    #             if content is None:
                    raise ValueError("Missing 'content' parameter")

    #             # Ensure directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok = True)

    #             with open(file_path, "w", encoding="utf-8") as f:
                    f.write(content)

    #             return {
    #                 "status": "success",
    #                 "path": file_path,
    #                 "message": "File written successfully",
    #             }

    #         except Exception as e:
                return {"status": "error", "error": str(e), "path": params.get("path", "")}

    #     def _handle_list_directory(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'list_directory' command."""
    #         try:
    dir_path = params.get("path", ".")

    #             if not os.path.isdir(dir_path):
                    raise ValueError(f"Not a directory: {dir_path}")

    items = []
    #             for item in os.listdir(dir_path):
    item_path = os.path.join(dir_path, item)
                    items.append(
    #                     {
    #                         "name": item,
    #                         "path": item_path,
                            "is_dir": os.path.isdir(item_path),
                            "size": (
                                os.path.getsize(item_path)
    #                             if os.path.isfile(item_path)
    #                             else 0
    #                         ),
    #                     }
    #                 )

    #             return {"status": "success", "path": dir_path, "items": items}

    #         except Exception as e:
                return {"status": "error", "error": str(e), "path": params.get("path", "")}

    #     def _handle_get_runtime_state(self) -> Dict[str, Any]:
    #         """Handle 'get_runtime_state' command."""
    #         try:
    #             if not self.runtime:
    #                 return {"status": "error", "error": "Runtime not initialized"}

    #             return {
    #                 "status": "success",
                    "state": self.runtime.get_state().value,
                    "metrics": self.runtime.get_metrics().to_dict(),
                    "stack_depth": self.runtime.get_stack_depth(),
                    "memory_usage": self.runtime.get_memory_usage(),
    #             }

    #         except Exception as e:
                return {"status": "error", "error": str(e)}

    #     def _handle_reset_runtime(self) -> Dict[str, Any]:
    #         """Handle 'reset_runtime' command."""
    #         try:
    #             if not self.runtime:
    #                 # Recreate runtime
                    self._initialize_runtime()
    #             else:
                    self.runtime.reset()

    #             return {"status": "success", "message": "Runtime reset successfully"}

    #         except Exception as e:
                return {"status": "error", "error": str(e)}

    #     # Workspace / Sandbox API Handlers
    #     def _handle_list_workspaces(self) -> Dict[str, Any]:
    #         """Handle 'workspaces' command to list all workspaces."""
    #         try:
    sandboxes = self.sandbox_manager.list_sandboxes()
    workspaces = {}

    #             for agent_id, sandbox_info in sandboxes.items():
    workspaces[agent_id] = {
    #                     "id": agent_id,
    #                     "name": f"Sandbox-{agent_id}",
                        "status": sandbox_info.get("status", "unknown"),
                        "path": str(sandbox_info.get("dir", "")),
    #                 }

    #             return {
    #                 "status": "success",
    #                 "workspaces": workspaces,
                    "count": len(workspaces),
    #             }

    #         except Exception as e:
    print(f"Error listing workspaces: {e}", file = sys.stderr)
                return {"status": "error", "error": str(e)}

    #     def _handle_create_workspace(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'create_workspace' command to create a new workspace."""
    #         try:
    name = params.get("name", f"workspace-{uuid.uuid4().hex[:8]}")

    #             # Generate unique agent_id from name
    agent_id = f"ws-{name.replace(' ', '-').lower()}-{uuid.uuid4().hex[:4]}"

    sandbox_path = self.sandbox_manager.create_sandbox(agent_id, copy_base=True)

    #             return {
    #                 "status": "success",
    #                 "workspace_id": agent_id,
    #                 "workspace_name": name,
                    "message": f"Workspace created: {name} ({agent_id})",
                    "sandbox_path": str(sandbox_path),
    #             }

    #         except Exception as e:
    print(f"Error creating workspace: {e}", file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "message": f'Failed to create workspace: {params.get("name", "unknown")}',
    #             }

    #     def _handle_switch_workspace(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'workspace_switch' command to switch to a workspace."""
    #         try:
    workspace_id = params.get("workspace_id")
    #             if not workspace_id:
                    raise ValueError("Missing 'workspace_id' parameter")

    #             # For now, just update the base project path to point to the sandbox
    #             # In a full implementation, this would track the active workspace
    sandbox_path = self.sandbox_manager.get_sandbox_path(workspace_id)

    #             if not sandbox_path:
                    raise ValueError(f"Workspace not found: {workspace_id}")

    #             return {
    #                 "status": "success",
    #                 "workspace_id": workspace_id,
    #                 "message": f"Switched to workspace: {workspace_id}",
                    "sandbox_path": str(sandbox_path),
    #             }

    #         except Exception as e:
    print(f"Error switching workspace: {e}", file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
                    "message": f'Failed to switch workspace: {params.get("workspace_id", "unknown")}',
    #             }

    #     def _handle_workspace_diff(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'workspace_diff' command to show diff for a workspace."""
    #         try:
    workspace_id = params.get("workspace_id")
    #             if not workspace_id:
                    raise ValueError("Missing 'workspace_id' parameter")

    sandbox_path = self.sandbox_manager.get_sandbox_path(workspace_id)
    #             if not sandbox_path:
                    raise ValueError(f"Workspace not found: {workspace_id}")

    #             # Get changes for this sandbox
    success, changes = self.sandbox_manager.commit_sandbox(
    workspace_id, generate_diff = True
    #             )

    #             if not success:
                    raise ValueError(
    #                     f"Failed to generate diff for workspace: {workspace_id}"
    #                 )

                # Generate detailed diff (full diff content)
    base_path = Path(os.path.join(os.path.dirname(__file__), "noodle-project"))
    detailed_diff = []

    #             if base_path.exists() and changes:
    #                 for change in changes:
    #                     # Detailed diff using difflib for known file changes
    #                     if change.startswith(("ADDED:", "MODIFIED:")):
    filename = change.split(": ", 1)[1]
    sandbox_file = math.divide(sandbox_path, filename)
    base_file = math.divide(base_path, filename)

    #                         if change.startswith("ADDED:") and sandbox_file.exists():
    #                             # Read entire content for new files
    #                             try:
    #                                 with open(sandbox_file, "r", encoding="utf-8") as f:
    content = f.read()
                                    detailed_diff.append(f"+++ NEW: {filename}\n{content}")
    #                             except Exception as e:
                                    detailed_diff.append(
                                        f"+++ NEW: {filename} (error reading: {e})"
    #                                 )

    #                         elif (
                                change.startswith("MODIFIED:")
                                and base_file.exists()
                                and sandbox_file.exists()
    #                         ):
    #                             # Generate unified diff
    #                             try:
    #                                 with open(base_file, "r", encoding="utf-8") as bf:
    base_lines = bf.readlines()
    #                                 with open(sandbox_file, "r", encoding="utf-8") as sf:
    sandbox_lines = sf.readlines()

    diff = difflib.unified_diff(
    #                                     base_lines,
    #                                     sandbox_lines,
    fromfile = str(base_file),
    tofile = str(sandbox_file),
    lineterm = "",
    #                                 )
                                    detailed_diff.append("".join(diff))
    #                             except Exception as e:
                                    detailed_diff.append(
                                        f"--- MODIFIED: {filename} (error diffing: {e})"
    #                                 )
    #                     else:
                            detailed_diff.append(change)

    #             return {
    #                 "status": "success",
    #                 "workspace_id": workspace_id,
                    "diff": "\n".join(detailed_diff),
    #                 "changes": changes,
    #                 "change_count": len(changes) if changes else 0,
    #             }

    #         except Exception as e:
    print(f"Error getting workspace diff: {e}", file = sys.stderr)
    #             return {
    #                 "status": "error",
                    "error": str(e),
    #                 "message": f'Failed to get diff for workspace: {params.get("workspace_id", "unknown")}',
    #             }

    #     def _handle_workspace_merge(self, params: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handle 'workspace_merge' command to merge a workspace."""
    #         try:
    workspace_id = params.get("workspace_id")
    strategy = params.get("strategy", "auto")  # auto, manual, ai-review

    #             if not workspace_id:
                    raise ValueError("Missing 'workspace_id' parameter")

    sandbox_path = self.sandbox_manager.get_sandbox_path(workspace_id)
    #             if not sandbox_path:
                    raise ValueError(f"Workspace not found: {workspace_id}")

    #             # For now, implement simple auto-merge
    #             # In a real implementation, this would use the strategy parameter
    #             if strategy not in ["auto", "manual", "ai-review"]:
                    raise ValueError(f"Invalid merge strategy: {strategy}")

    #             # Get changes for this sandbox
    success, changes = self.sandbox_manager.commit_sandbox(
    workspace_id, generate_diff = True
    #             )

    #             if not success:
    #                 raise ValueError(f"Failed to get changes for workspace: {workspace_id}")

    #             if not changes:
    #                 return {
    #                     "status": "success",
    #                     "workspace_id": workspace_id,
    #                     "message": f"No changes to merge for workspace: {workspace_id}",
    #                     "merged_files": 0,
    #                     "strategy": strategy,
    #                 }

    #             # Simple auto-merge: copy changed files from sandbox to base project
    base_project_path = Path(
                    os.path.join(os.path.dirname(__file__), "noodle-project")
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


if __name__ == "__main__"
        main()
