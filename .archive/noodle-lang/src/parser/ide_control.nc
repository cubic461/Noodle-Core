# Converted from Python to NoodleCore
# Original file: src

# """
# Mobile API IDE Control Module
# ------------------------------

# Handles IDE control endpoints for remote project management and code execution
from the NoodleControl mobile app.
# """

import json
import logging
import os
import subprocess
import tempfile
import time
import uuid
import datetime.datetime
import pathlib.Path
import typing.Any

import .errors.(
#     ExecutionError,
#     FileNotFoundError,
#     InvalidRequestError,
#     ProjectNotFoundError,
#     ValidationError,
# )

logger = logging.getLogger(__name__)


class IDEController
    #     """
    #     Manages IDE control operations for mobile API including project management,
    #     file operations, and code execution.
    #     """

    #     def __init__(self, core_path: Optional[str] = None, workspace_path: Optional[str] = None):""
    #         Initialize IDEController.

    #         Args:
    #             core_path: Path to the NoodleCore entry point
    #             workspace_path: Path to the workspace directory
    #         """
    self.core_path = core_path or self._find_core_entry_point()
    self.workspace_path = workspace_path or os.getcwd()
    self.active_sessions: Dict[str, Dict[str, Any]] = {}

    #         # Ensure workspace directory exists
    Path(self.workspace_path).mkdir(parents = True, exist_ok=True)

    #     def _find_core_entry_point(self) -str):
    #         """Find the core-entry-point.py script in the project."""
    possible_paths = [
    #             "core-entry-point.py",
    #             "src/core-entry-point.py",
    #             "noodle-dev/core-entry-point.py",
    #             "noodle-dev/src/core-entry-point.py",
    #         ]

    #         for path in possible_paths:
    #             if os.path.exists(path):
                    return os.path.abspath(path)

            raise FileNotFoundError("Could not find core-entry-point.py")

    #     def list_projects(self, include_details: bool = False) -List[Dict[str, Any]]):
    #         """
    #         List all projects in the workspace.

    #         Args:
    #             include_details: Whether to include detailed project information

    #         Returns:
    #             List of project information dictionaries
    #         """
    #         try:
    projects = []
    workspace = Path(self.workspace_path)

    #             for item in workspace.iterdir():
    #                 if item.is_dir() and not item.name.startswith("."):
    project_info = {
    #                         "id": item.name,
    #                         "name": item.name,
                            "path": str(item),
                            "created_at": datetime.fromtimestamp(item.stat().st_ctime).isoformat(),
                            "modified_at": datetime.fromtimestamp(item.stat().st_mtime).isoformat(),
    #                     }

    #                     if include_details:
    #                         # Check if it's a Noodle project
    main_file = item / "main.noodle"
    project_info["is_noodle_project"] = main_file.exists()

    #                         # Count files
    file_count = 0
    #                         for root, dirs, files in os.walk(item):
    file_count + = len(files)
    project_info["file_count"] = file_count

    #                         # Get project size
    size = 0
    #                         for root, dirs, files in os.walk(item):
    #                             for file in files:
    size + = os.path.getsize(os.path.join(root, file))
    project_info["size_bytes"] = size

                        projects.append(project_info)

    #             return projects
    #         except Exception as e:
                logger.error(f"Failed to list projects: {e}")
                raise InvalidRequestError(f"Failed to list projects: {e}")

    #     def create_project(self, name: str, description: str = "", template: str = "basic") -Dict[str, Any]):
    #         """
    #         Create a new project.

    #         Args:
    #             name: Project name
    #             description: Project description
    #             template: Project template to use

    #         Returns:
    #             Dictionary containing project creation result
    #         """
    #         try:
    #             # Validate project name
    #             if not name or not name.strip():
                    raise ValidationError("Project name is required")

    #             if not name.replace("-", "").replace("_", "").isalnum():
                    raise ValidationError("Project name must contain only alphanumeric characters, hyphens, and underscores")

    #             # Check if project already exists
    project_path = math.divide(Path(self.workspace_path), name)
    #             if project_path.exists():
                    raise InvalidRequestError(f"Project '{name}' already exists")

    #             # Create project directory
    project_path.mkdir(parents = True, exist_ok=True)

    #             # Create basic project structure
    (project_path / "src").mkdir(exist_ok = True)
    (project_path / "tests").mkdir(exist_ok = True)
    (project_path / "docs").mkdir(exist_ok = True)

    #             # Create project files based on template
    #             if template == "basic":
                    self._create_basic_project(project_path, name, description)
    #             elif template == "advanced":
                    self._create_advanced_project(project_path, name, description)
    #             else:
    #                 # Default to basic template
                    self._create_basic_project(project_path, name, description)

    #             # Create project metadata
    metadata = {
    #                 "name": name,
    #                 "description": description,
    #                 "template": template,
                    "created_at": datetime.now().isoformat(),
    #                 "version": "1.0.0",
    #             }

    #             with open(project_path / "project.json", "w") as f:
    json.dump(metadata, f, indent = 2)

    #             return {
    #                 "id": name,
    #                 "name": name,
    #                 "description": description,
    #                 "template": template,
                    "path": str(project_path),
    #                 "created_at": metadata["created_at"],
    #                 "files": [
    #                     "main.noodle",
    #                     "project.json",
    #                     "src/",
    #                     "tests/",
    #                     "docs/"
    #                 ]
    #             }
    #         except Exception as e:
                logger.error(f"Failed to create project: {e}")
                raise InvalidRequestError(f"Failed to create project: {e}")

    #     def get_project(self, project_id: str) -Dict[str, Any]):
    #         """
    #         Get project information.

    #         Args:
    #             project_id: Project ID/name

    #         Returns:
    #             Dictionary containing project information
    #         """
    #         try:
    project_path = math.divide(Path(self.workspace_path), project_id)
    #             if not project_path.exists():
                    raise ProjectNotFoundError(project_id)

    #             # Load project metadata
    metadata_file = project_path / "project.json"
    metadata = {}
    #             if metadata_file.exists():
    #                 with open(metadata_file, "r") as f:
    metadata = json.load(f)

    #             # Get project statistics
    file_count = 0
    size = 0
    #             for root, dirs, files in os.walk(project_path):
    #                 for file in files:
    file_count + = 1
    size + = os.path.getsize(os.path.join(root, file))

    #             # Check if it's a Noodle project
    main_file = project_path / "main.noodle"
    is_noodle_project = main_file.exists()

    #             return {
    #                 "id": project_id,
                    "name": metadata.get("name", project_id),
                    "description": metadata.get("description", ""),
                    "template": metadata.get("template", "basic"),
                    "path": str(project_path),
                    "created_at": metadata.get("created_at", datetime.fromtimestamp(project_path.stat().st_ctime).isoformat()),
                    "modified_at": datetime.fromtimestamp(project_path.stat().st_mtime).isoformat(),
    #                 "file_count": file_count,
    #                 "size_bytes": size,
    #                 "is_noodle_project": is_noodle_project,
                    "version": metadata.get("version", "1.0.0"),
    #             }
    #         except Exception as e:
                logger.error(f"Failed to get project: {e}")
                raise InvalidRequestError(f"Failed to get project: {e}")

    #     def delete_project(self, project_id: str) -bool):
    #         """
    #         Delete a project.

    #         Args:
    #             project_id: Project ID/name

    #         Returns:
    #             True if project was successfully deleted
    #         """
    #         try:
    project_path = math.divide(Path(self.workspace_path), project_id)
    #             if not project_path.exists():
                    raise ProjectNotFoundError(project_id)

    #             # Remove project directory
    #             import shutil
                shutil.rmtree(project_path)

    #             return True
    #         except Exception as e:
                logger.error(f"Failed to delete project: {e}")
                raise InvalidRequestError(f"Failed to delete project: {e}")

    #     def list_files(self, project_id: str, path: str = "", recursive: bool = False) -List[Dict[str, Any]]):
    #         """
    #         List files in a project directory.

    #         Args:
    #             project_id: Project ID/name
    #             path: Relative path within the project
    #             recursive: Whether to list files recursively

    #         Returns:
    #             List of file information dictionaries
    #         """
    #         try:
    project_path = math.divide(Path(self.workspace_path), project_id)
    #             if not project_path.exists():
                    raise ProjectNotFoundError(project_id)

    #             target_path = project_path / path if path else project_path
    #             if not target_path.exists():
                    raise FileNotFoundError(str(target_path))

    files = []

    #             if recursive:
    #                 for root, dirs, file_names in os.walk(target_path):
    #                     for file_name in file_names:
    file_path = math.divide(Path(root), file_name)
    relative_path = file_path.relative_to(project_path)

                            files.append({
    #                             "name": file_name,
                                "path": str(relative_path),
    #                             "type": "file",
                                "size": file_path.stat().st_size,
                                "modified_at": datetime.fromtimestamp(file_path.stat().st_mtime).isoformat(),
    #                         })
    #             else:
    #                 for item in target_path.iterdir():
    #                     try:
    relative_path = item.relative_to(project_path)

    #                         if item.is_file():
                                files.append({
    #                                 "name": item.name,
                                    "path": str(relative_path),
    #                                 "type": "file",
                                    "size": item.stat().st_size,
                                    "modified_at": datetime.fromtimestamp(item.stat().st_mtime).isoformat(),
    #                             })
    #                         elif item.is_dir():
                                files.append({
    #                                 "name": item.name,
                                    "path": str(relative_path),
    #                                 "type": "directory",
                                    "modified_at": datetime.fromtimestamp(item.stat().st_mtime).isoformat(),
    #                             })
                        except (PermissionError, OSError) as e:
                            logger.warning(f"Skipping inaccessible item {item}: {e}")
    #                         continue

    return sorted(files, key = lambda x: (x["type"] != "directory", x["name"]))
    #         except Exception as e:
                logger.error(f"Failed to list files: {e}")
                raise InvalidRequestError(f"Failed to list files: {e}")

    #     def read_file(self, project_id: str, file_path: str) -Dict[str, Any]):
    #         """
    #         Read file contents.

    #         Args:
    #             project_id: Project ID/name
    #             file_path: Relative path to the file within the project

    #         Returns:
    #             Dictionary containing file content and metadata
    #         """
    #         try:
    project_path = math.divide(Path(self.workspace_path), project_id)
    #             if not project_path.exists():
                    raise ProjectNotFoundError(project_id)

    full_path = math.divide(project_path, file_path)
    #             if not full_path.exists() or not full_path.is_file():
                    raise FileNotFoundError(str(full_path))

    #             # Read file content
    #             with open(full_path, "r", encoding="utf-8") as f:
    content = f.read()

    #             return {
    #                 "name": full_path.name,
    #                 "path": file_path,
    #                 "content": content,
                    "size": len(content),
                    "modified_at": datetime.fromtimestamp(full_path.stat().st_mtime).isoformat(),
    #             }
    #         except Exception as e:
                logger.error(f"Failed to read file: {e}")
                raise InvalidRequestError(f"Failed to read file: {e}")

    #     def write_file(self, project_id: str, file_path: str, content: str, create_if_not_exists: bool = True) -Dict[str, Any]):
    #         """
    #         Write content to a file.

    #         Args:
    #             project_id: Project ID/name
    #             file_path: Relative path to the file within the project
    #             content: File content to write
    #             create_if_not_exists: Whether to create the file if it doesn't exist

    #         Returns:
    #             Dictionary containing file operation result
    #         """
    #         try:
    project_path = math.divide(Path(self.workspace_path), project_id)
    #             if not project_path.exists():
                    raise ProjectNotFoundError(project_id)

    full_path = math.divide(project_path, file_path)

    #             # Check if file exists
    file_exists = full_path.exists()

    #             if file_exists and not full_path.is_file():
                    raise InvalidRequestError(f"Path exists but is not a file: {file_path}")

    #             if not file_exists and not create_if_not_exists:
                    raise FileNotFoundError(str(full_path))

    #             # Ensure directory exists
    full_path.parent.mkdir(parents = True, exist_ok=True)

    #             # Write content
    #             with open(full_path, "w", encoding="utf-8") as f:
                    f.write(content)

    #             return {
    #                 "name": full_path.name,
    #                 "path": file_path,
                    "size": len(content),
    #                 "created": not file_exists,
                    "modified_at": datetime.now().isoformat(),
    #             }
    #         except Exception as e:
                logger.error(f"Failed to write file: {e}")
                raise InvalidRequestError(f"Failed to write file: {e}")

    #     def execute_code(self, project_id: str, code: str, context: Optional[Dict[str, Any]] = None) -Dict[str, Any]):
    #         """
    #         Execute Noodle code.

    #         Args:
    #             project_id: Project ID/name
    #             code: Noodle code to execute
    #             context: Execution context

    #         Returns:
    #             Dictionary containing execution result
    #         """
    #         try:
    project_path = math.divide(Path(self.workspace_path), project_id)
    #             if not project_path.exists():
                    raise ProjectNotFoundError(project_id)

    #             # Create execution session
    session_id = str(uuid.uuid4())

    #             # Create temporary file for the code
    #             with tempfile.NamedTemporaryFile(mode="w", suffix=".noodle", delete=False) as f:
                    f.write(code)
    temp_file = f.name

    #             # Prepare execution options
    exec_options = [
    #                 os.path.dirname(self.core_path) + "/python.exe" if os.name == "nt" else "python3",
    #                 self.core_path,
    #                 "--file",
    #                 temp_file,
    #                 "--format",
    #                 "json",
    #                 "--workspace",
                    str(project_path),
    #             ]

    #             # Add debug option if requested
    #             if context and context.get("debug", False):
                    exec_options.append("--debug")

    #             # Prepare JSON input for core-entry-point.py
    input_data = {
    #                 "command": "execute",
    #                 "params": {
    #                     "code": code,
                        "workspace": str(project_path),
    #                     "context": context or {}
    #                 }
    #             }

    #             # Execute the code
    start_time = time.time()

    result = subprocess.run(
    #                 exec_options,
    input = json.dumps(input_data),
    capture_output = True,
    text = True,
    #                 timeout=context.get("timeout", 30) if context else 30,
    #             )
    execution_time = time.time() - start_time

    #             # Clean up temporary file
    #             try:
                    os.unlink(temp_file)
    #             except:
    #                 pass

    #             # Parse result
    response_data = {
    #                 "session_id": session_id,
    #                 "execution_time": execution_time,
    #                 "exit_code": result.returncode,
    #                 "output": result.stdout,
    #                 "stderr": result.stderr,
    "success": result.returncode = 0,
    #             }

    #             # Store session information
    self.active_sessions[session_id] = {
    #                 "project_id": project_id,
    #                 "code": code,
    #                 "context": context,
    #                 "result": response_data,
                    "created_at": datetime.now(),
    #             }

    #             return response_data
    #         except subprocess.TimeoutExpired:
                raise ExecutionError(f"Execution timeout after 30 seconds")
    #         except Exception as e:
                logger.error(f"Code execution failed: {e}")
                raise ExecutionError(f"Code execution failed: {e}")

    #     def get_execution_session(self, session_id: str) -Dict[str, Any]):
    #         """
    #         Get execution session information.

    #         Args:
    #             session_id: Session ID

    #         Returns:
    #             Dictionary containing session information
    #         """
    session = self.active_sessions.get(session_id)
    #         if not session:
                raise InvalidRequestError(f"Session not found: {session_id}")

    #         return session

    #     def _create_basic_project(self, project_path: Path, name: str, description: str):
    #         """Create a basic project structure."""
    #         # Create main.noodle file
    main_file = project_path / "main.noodle"
    #         with open(main_file, "w", encoding="utf-8") as f:
                f.write(f"# {name}\n")
                f.write(f"# {description}\n")
                f.write("# Main Noodle file\n\n")
                f.write("println(\"Hello, Noodle!\");\n")

    #         # Create README.md
    readme_file = project_path / "README.md"
    #         with open(readme_file, "w", encoding="utf-8") as f:
                f.write(f"# {name}\n\n")
                f.write(f"{description}\n\n")
                f.write("## Getting Started\n\n")
                f.write("Run the main file with:\n\n")
                f.write("```bash\n")
                f.write("noodle run main.noodle\n")
                f.write("```\n")

    #     def _create_advanced_project(self, project_path: Path, name: str, description: str):
    #         """Create an advanced project structure."""
    #         # Create basic structure
            self._create_basic_project(project_path, name, description)

    #         # Create additional directories
    (project_path / "lib").mkdir(exist_ok = True)
    (project_path / "config").mkdir(exist_ok = True)
    (project_path / "data").mkdir(exist_ok = True)

    #         # Create lib/utils.noodle
    utils_file = project_path / "lib" / "utils.noodle"
    #         with open(utils_file, "w", encoding="utf-8") as f:
                f.write("# Utility functions\n\n")
                f.write("function log(message) {\n")
                f.write("    println(\"[LOG] \" + message);\n")
                f.write("}\n")

    #         # Create config/config.noodle
    config_file = project_path / "config" / "config.noodle"
    #         with open(config_file, "w", encoding="utf-8") as f:
                f.write("# Configuration\n\n")
    f.write("const APP_NAME = \"" + name + "\";\n")
    f.write("const VERSION = \"1.0.0\";\n")

    #         # Update main.noodle to use the utilities
    main_file = project_path / "main.noodle"
    #         with open(main_file, "r+", encoding="utf-8") as f:
    content = f.read()
                f.seek(0)
                f.write(f"# {name}\n")
                f.write(f"# {description}\n")
                f.write("# Main Noodle file\n\n")
                f.write("import \"lib/utils.noodle\";\n")
                f.write("import \"config/config.noodle\";\n\n")
                f.write("log(\"Starting \" + APP_NAME + \" v\" + VERSION);\n")
                f.write("println(\"Hello, Noodle!\");\n")