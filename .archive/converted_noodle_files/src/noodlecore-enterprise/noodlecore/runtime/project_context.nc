# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Project Context Structure
# ------------------------
# Defines the structure for managing project contexts in the IDE.
# """

import uuid
import dataclasses.dataclass,
import datetime.datetime
import pathlib.Path
import typing.Any,

# Import the project analyzer
import .project_analyzer.ProjectStructure


# @dataclass
class ProjectContext
    #     """
    #     Represents a project context in the IDE.
    #     Contains all information about a project including its structure and state.
    #     """

    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str = ""
    root_path: str = ""
    project_type: str = "unknown"
    version: str = ""
    description: str = ""

    #     # Project structure and metadata
    project_structure: Optional[ProjectStructure] = None
    dependencies: Dict[str, List[str]] = field(default_factory=dict)

    #     # Timing and status
    created_at: datetime = field(default_factory=datetime.now)
    last_updated: datetime = field(default_factory=datetime.now)
    last_analyzed: Optional[datetime] = None
    is_active: bool = False

    #     # IDE-specific state
    open_files: List[str] = field(default_factory=list)
    selected_file: Optional[str] = None
    view_mode: str = "tree"  # "tree" or "graph"

    #     # Project settings
    settings: Dict[str, Any] = field(default_factory=dict)

    #     # Language and tooling settings
    language_servers: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    debug_configurations: List[Dict[str, Any]] = field(default_factory=list)
    run_configurations: List[Dict[str, Any]] = field(default_factory=list)

    #     # Statistics
    statistics: Dict[str, Any] = field(default_factory=dict)

    #     # Custom metadata
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def update_last_updated(self):
    #         """Update the last_updated timestamp to now."""
    self.last_updated = datetime.now()

    #     def update_last_analyzed(self):
    #         """Update the last_analyzed timestamp to now."""
    self.last_analyzed = datetime.now()

    #     def add_open_file(self, file_path: str):
    #         """Add a file to the open files list if not already there."""
    #         if file_path not in self.open_files:
                self.open_files.append(file_path)
                self.update_last_updated()

    #     def remove_open_file(self, file_path: str):
    #         """Remove a file from the open files list."""
    #         if file_path in self.open_files:
                self.open_files.remove(file_path)
                self.update_last_updated()

    #         # Clear selected file if it's being closed
    #         if self.selected_file == file_path:
    self.selected_file = None

    #     def set_selected_file(self, file_path: str):
    #         """Set the currently selected file."""
    self.selected_file = file_path
            self.add_open_file(file_path)  # Ensure it's in open files
            self.update_last_updated()

    #     def set_view_mode(self, mode: str):
            """Set the current view mode ('tree' or 'graph')."""
    #         if mode in ["tree", "graph"]:
    self.view_mode = mode
                self.update_last_updated()

    #     def add_dependency(self, source_file: str, dependency: str):
    #         """Add a dependency relationship."""
    #         if source_file not in self.dependencies:
    self.dependencies[source_file] = []

    #         if dependency not in self.dependencies[source_file]:
                self.dependencies[source_file].append(dependency)
                self.update_last_updated()

    #     def remove_dependency(self, source_file: str, dependency: str):
    #         """Remove a dependency relationship."""
    #         if (
    #             source_file in self.dependencies
    #             and dependency in self.dependencies[source_file]
    #         ):
                self.dependencies[source_file].remove(dependency)
                self.update_last_updated()

    #     def get_dependencies(self, file_path: str) -> List[str]:
    #         """Get dependencies for a specific file."""
            return self.dependencies.get(file_path, [])

    #     def get_dependents(self, target_file: str) -> List[str]:
    #         """Get files that depend on the specified file."""
    dependents = []
    #         for source_file, deps in self.dependencies.items():
    #             if target_file in deps:
                    dependents.append(source_file)
    #         return dependents

    #     def set_project_structure(self, structure: ProjectStructure):
    #         """Set the project structure and update related metadata."""
    self.project_structure = structure
    self.project_type = structure.type
    self.dependencies = structure.dependencies
            self.update_last_analyzed()
            self.update_last_updated()

    #         # Update statistics
            self.update_statistics()

    #     def update_statistics(self):
    #         """Update project statistics from the project structure."""
    #         if self.project_structure:
    stats = {
    #                 "total_files": self.project_structure.total_files,
    #                 "total_size": self.project_structure.total_size,
                    "language_distribution": dict(self.project_structure.languages),
                    "directory_count": len(self.project_structure.directories),
                    "config_file_count": len(self.project_structure.config_files),
                    "package_file_count": len(self.project_structure.package_files),
    #             }
    self.statistics = stats
                self.update_last_updated()

    #     def get_file_metadata(self, file_path: str) -> Optional[Dict[str, Any]]:
    #         """Get metadata for a specific file."""
    #         if not self.project_structure:
    #             return None

    #         if file_path in self.project_structure.files:
    file_meta = self.project_structure.files[file_path]
    #             return {
    #                 "path": file_meta.path,
    #                 "name": file_meta.name,
    #                 "extension": file_meta.extension,
    #                 "size": file_meta.size,
    #                 "language": file_meta.language,
                    "modified": file_meta.modified.isoformat(),
    #                 "is_binary": file_meta.is_binary,
    #                 "hash": file_meta.hash,
    #                 "dependencies": file_meta.dependencies,
    #             }
    #         return None

    #     def get_directory_metadata(self, dir_path: str) -> Optional[Dict[str, Any]]:
    #         """Get metadata for a specific directory."""
    #         if not self.project_structure:
    #             return None

    #         if dir_path in self.project_structure.directories:
    dir_meta = self.project_structure.directories[dir_path]
    #             return {
    #                 "path": dir_meta.path,
    #                 "name": dir_meta.name,
    #                 "is_project_root": dir_meta.is_project_root,
    #                 "is_hidden": dir_meta.is_hidden,
    #                 "file_count": dir_meta.file_count,
    #                 "total_size": dir_meta.total_size,
                    "languages": dict(dir_meta.languages),
    #                 "description": dir_meta.description,
    #             }
    #         return None

    #     def find_files_by_language(self, language: str) -> List[str]:
    #         """Find all files of a specific language."""
    #         if not self.project_structure:
    #             return []

    language_files = []
    #         for file_path, file_meta in self.project_structure.files.items():
    #             if file_meta.language == language:
                    language_files.append(file_path)
    #         return language_files

    #     def find_files_by_extension(self, extension: str) -> List[str]:
    #         """Find all files with a specific extension."""
    #         if not self.project_structure:
    #             return []

    extension_files = []
    #         for file_path, file_meta in self.project_structure.files.items():
    #             if file_meta.extension == extension:
                    extension_files.append(file_path)
    #         return extension_files

    #     def get_files_in_directory(self, dir_path: str) -> List[str]:
    #         """Get all files in a specific directory."""
    #         if not self.project_structure:
    #             return []

    files = []
    prefix = dir_path + "/"
    #         for file_path in self.project_structure.files:
    #             if file_path.startswith(prefix):
                    files.append(file_path)
    #         return files

    #     def get_subdirectories(self, dir_path: str) -> List[str]:
    #         """Get all subdirectories of a specific directory."""
    #         if not self.project_structure:
    #             return []

    subdirs = set()
    prefix = dir_path + "/"
    #         for dir_meta_path in self.project_structure.directories:
    #             if dir_meta_path.startswith(prefix) and dir_meta_path != dir_path:
    #                 # Extract the immediate subdirectory name
    relative_path = dir_meta_path[len(dir_path) :].strip("/")
    #                 if "/" not in relative_path:  # Immediate subdirectory
                        subdirs.add(dir_meta_path)

            return list(subdirs)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert the ProjectContext to a dictionary for serialization."""
    result = {
    #             "id": self.id,
    #             "name": self.name,
    #             "root_path": self.root_path,
    #             "project_type": self.project_type,
    #             "version": self.version,
    #             "description": self.description,
                "created_at": self.created_at.isoformat(),
                "last_updated": self.last_updated.isoformat(),
                "last_analyzed": (
    #                 self.last_analyzed.isoformat() if self.last_analyzed else None
    #             ),
    #             "is_active": self.is_active,
    #             "open_files": self.open_files,
    #             "selected_file": self.selected_file,
    #             "view_mode": self.view_mode,
    #             "settings": self.settings,
    #             "language_servers": self.language_servers,
    #             "debug_configurations": self.debug_configurations,
    #             "run_configurations": self.run_configurations,
    #             "statistics": self.statistics,
    #             "metadata": self.metadata,
    #             "dependencies": {k: list(v) for k, v in self.dependencies.items()},
    #         }

    #         # Conditionally include project structure if it exists
    #         if self.project_structure:
    result["project_structure"] = {
    #                 "name": self.project_structure.name,
    #                 "type": self.project_structure.type,
    #                 "total_files": self.project_structure.total_files,
    #                 "total_size": self.project_structure.total_size,
                    "languages": dict(self.project_structure.languages),
    #                 "config_files": self.project_structure.config_files,
    #                 "package_files": self.project_structure.package_files,
    #             }

    #         return result

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "ProjectContext":
    #         """Create a ProjectContext from a dictionary."""
    #         # Convert string timestamps back to datetime objects
    created_at = datetime.fromisoformat(data["created_at"])
    last_updated = datetime.fromisoformat(data["last_updated"])
    last_analyzed = (
                datetime.fromisoformat(data["last_analyzed"])
    #             if data.get("last_analyzed")
    #             else None
    #         )

    #         # Create the ProjectContext instance
    context = cls(
    id = data["id"],
    name = data["name"],
    root_path = data["root_path"],
    project_type = data["project_type"],
    version = data.get("version", ""),
    description = data.get("description", ""),
    created_at = created_at,
    last_updated = last_updated,
    last_analyzed = last_analyzed,
    is_active = data.get("is_active", False),
    open_files = data.get("open_files", []),
    selected_file = data.get("selected_file"),
    view_mode = data.get("view_mode", "tree"),
    settings = data.get("settings", {}),
    language_servers = data.get("language_servers", {}),
    debug_configurations = data.get("debug_configurations", []),
    run_configurations = data.get("run_configurations", []),
    statistics = data.get("statistics", {}),
    metadata = data.get("metadata", {}),
    #             dependencies={k: list(v) for k, v in data.get("dependencies", {}).items()},
    #         )

    #         # Conditionally restore project structure
    #         if data.get("project_structure"):
    #             # In a real implementation, this would create a full ProjectStructure object
    #             # For now, we'll just store the basic stats
    structure_data = data["project_structure"]
    context.project_type = structure_data.get("type", context.project_type)

    #         return context

    #     def save_to_file(self, file_path: Union[str, Path]) -> str:
    #         """Save the ProjectContext to a JSON file."""
    file_path = Path(file_path)

    #         # Create .noodle directory if it doesn't exist
    noodle_dir = file_path / ".noodle"
    noodle_dir.mkdir(parents = True, exist_ok=True)

    #         # Save to file
    output_file = noodle_dir / "project_context.json"
    #         with open(output_file, "w", encoding="utf-8") as f:
    #             import json

    json.dump(self.to_dict(), f, indent = 2, ensure_ascii=False)

            return str(output_file)

    #     @classmethod
    #     def load_from_file(cls, file_path: Union[str, Path]) -> "ProjectContext":
    #         """Load a ProjectContext from a JSON file."""
    file_path = Path(file_path)

    #         # Construct path to project context file
    context_file = file_path / ".noodle" / "project_context.json"

    #         if not context_file.exists():
                raise FileNotFoundError(f"Project context file not found: {context_file}")

    #         with open(context_file, "r", encoding="utf-8") as f:
    #             import json

    data = json.load(f)

            return cls.from_dict(data)
