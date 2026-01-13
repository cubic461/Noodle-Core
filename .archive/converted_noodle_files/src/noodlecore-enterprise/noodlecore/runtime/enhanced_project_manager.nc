# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Enhanced Project Manager
# -----------------------
# Extends the ProjectManager with multi-project support for IDE integration.
# """

import json
import logging
import os
import datetime.datetime
import pathlib.Path
import typing.Any,
import uuid.uuid4

import .project_analyzer.ProjectAnalyzer
import .project_context.ProjectContext
import .project_manager.ProjectManager

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


class EnhancedProjectManager(BaseProjectManager)
    #     """
    #     Enhanced ProjectManager with multi-project support for IDE integration.
    #     Provides methods to manage multiple projects simultaneously with project contexts.
    #     """

    #     def __init__(self, base_path: Union[Path, str], config_path: Optional[str] = None):
    #         """
    #         Initialize the EnhancedProjectManager.

    #         Args:
    #             base_path: Base directory for projects
    #             config_path: Optional path to configuration file
    #         """
            super().__init__(base_path, config_path)

    #         # Multi-project support
    self.project_contexts: Dict[str, ProjectContext] = {}
    self.active_project_id: Optional[str] = None
    self.recent_projects: List[str] = []  # Track recently accessed projects

    #         # Project analyzer instance
    self.analyzer = ProjectAnalyzer(base_path)

    #         # Load existing projects and contexts
            self._load_existing_projects()

    #     def _load_existing_projects(self):
    #         """Load existing projects and their contexts from the filesystem."""
    #         if not self.base_path.exists():
    #             return

    #         # Look for projects in the base directory
    #         for item in self.base_path.iterdir():
    #             if item.is_dir():
    #                 try:
    #                     # Try to load a project context
    context_file = item / ".noodle" / "project_context.json"
    #                     if context_file.exists():
    context = ProjectContext.load_from_file(item)
    self.project_contexts[context.id] = context
                            logger.info(
                                f"Loaded project context: {context.name} ({context.id})"
    #                         )
    #                 except Exception as e:
    #                     logger.warning(f"Failed to load project context for {item}: {e}")

    #     def add_project(
    #         self,
    #         project_path: Union[str, Path],
    project_name: Optional[str] = None,
    description: str = "",
    analyze: bool = True,
    #     ) -> ProjectContext:
    #         """
    #         Add a new project to the manager.

    #         Args:
    #             project_path: Path to the project directory
    #             project_name: Optional name for the project (defaults to directory name)
    #             description: Project description
    #             analyze: Whether to analyze the project structure immediately

    #         Returns:
    #             The created ProjectContext instance
    #         """
    project_path = Path(project_path)

    #         # Validate project path
    #         if not project_path.exists():
                raise FileNotFoundError(f"Project path does not exist: {project_path}")
    #         if not project_path.is_dir():
                raise ValueError(f"Project path is not a directory: {project_path}")

    #         # Generate project name if not provided
    #         if project_name is None:
    project_name = project_path.name

    #         # Create project context
    context = ProjectContext(
    name = project_name,
    root_path = str(project_path),
    description = description,
    is_active = False,
    #         )

    #         # Add to contexts
    self.project_contexts[context.id] = context

    #         # Create corresponding project if needed
    #         if str(project_path) not in [str(p.base_path) for p in self.projects.values()]:
                self.create_project(project_name, description)

    #         # Analyze project structure if requested
    #         if analyze:
                self.analyze_project(context.id)

    #         # Update recent projects
            self._add_to_recent_projects(context.id)

            logger.info(f"Added project: {project_name} ({context.id})")
    #         return context

    #     def remove_project(self, project_id: str) -> bool:
    #         """
    #         Remove a project from the manager.

    #         Args:
    #             project_id: Project ID to remove

    #         Returns:
    #             True if successful, False if not found
    #         """
    #         if project_id not in self.project_contexts:
                logger.warning(f"Project {project_id} not found")
    #             return False

    context = self.project_contexts[project_id]

    #         # Deactivate if it's the active project
    #         if self.active_project_id == project_id:
                self.set_active_project(None)

    #         # Remove from recent projects
    #         if project_id in self.recent_projects:
                self.recent_projects.remove(project_id)

    #         # Remove project context
    #         del self.project_contexts[project_id]

            logger.info(f"Removed project: {context.name} ({project_id})")
    #         return True

    #     def get_project_context(self, project_id: str) -> Optional[ProjectContext]:
    #         """
    #         Get a project context by ID.

    #         Args:
    #             project_id: Project ID

    #         Returns:
    #             The ProjectContext instance or None if not found
    #         """
            return self.project_contexts.get(project_id)

    #     def list_projects(self, include_inactive: bool = True) -> List[ProjectContext]:
    #         """
    #         List all managed projects.

    #         Args:
    #             include_inactive: Whether to include inactive projects

    #         Returns:
    #             List of ProjectContext instances
    #         """
    projects = list(self.project_contexts.values())

    #         if not include_inactive:
    #             projects = [p for p in projects if p.is_active]

            # Sort by last updated time (most recent first)
    projects.sort(key = lambda p: p.last_updated, reverse=True)

    #         return projects

    #     def get_recent_projects(self, limit: int = 10) -> List[ProjectContext]:
    #         """
    #         Get recently accessed projects.

    #         Args:
    #             limit: Maximum number of projects to return

    #         Returns:
    #             List of recent ProjectContext instances
    #         """
    recent_ids = self.recent_projects[:limit]
    #         return [
    #             self.project_contexts[pid]
    #             for pid in recent_ids
    #             if pid in self.project_contexts
    #         ]

    #     def set_active_project(self, project_id: Optional[str]) -> bool:
    #         """
    #         Set the active project.

    #         Args:
    #             project_id: Project ID to set as active, or None to deactivate all

    #         Returns:
    #             True if successful, False if not found
    #         """
    #         # Deactivate all projects
    #         if project_id is None:
    #             for context in self.project_contexts.values():
    context.is_active = False
    self.active_project_id = None
                logger.info("Deactivated all projects")
    #             return True

    #         # Activate specific project
    #         if project_id not in self.project_contexts:
                logger.warning(f"Project {project_id} not found")
    #             return False

    #         # Deactivate other projects
    #         for context in self.project_contexts.values():
    context.is_active = False

    #         # Set active project
    context = self.project_contexts[project_id]
    context.is_active = True
    self.active_project_id = project_id

    #         # Update recent projects
            self._add_to_recent_projects(project_id)

            logger.info(f"Set active project: {context.name} ({project_id})")
    #         return True

    #     def get_active_project(self) -> Optional[ProjectContext]:
    #         """
    #         Get the currently active project context.

    #         Returns:
    #             The active ProjectContext instance or None if no active project
    #         """
    #         if self.active_project_id and self.active_project_id in self.project_contexts:
    #             return self.project_contexts[self.active_project_id]
    #         return None

    #     def switch_project(self, project_id: str) -> bool:
    #         """
    #         Switch to a different project.

    #         Args:
    #             project_id: Project ID to switch to

    #         Returns:
    #             True if successful, False if not found
    #         """
    #         if project_id not in self.project_contexts:
                logger.warning(f"Project {project_id} not found")
    #             return False

    context = self.project_contexts[project_id]

    #         # Update active project
            self.set_active_project(project_id)

    #         # Update default project in the base manager
    #         for project in self.projects.values():
    #             if str(project.base_path) == context.root_path:
    self.default_project = project
    #                 break

            logger.info(f"Switched to project: {context.name} ({project_id})")
    #         return True

    #     def analyze_project(
    #         self,
    #         project_id: str,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> bool:
    #         """
    #         Analyze a project and update its structure.

    #         Args:
    #             project_id: Project ID to analyze
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             True if successful, False if not found
    #         """
    #         if project_id not in self.project_contexts:
                logger.warning(f"Project {project_id} not found")
    #             return False

    context = self.project_contexts[project_id]

    #         try:
    #             # Analyze project structure
    structure = self.analyzer.scan_directory(exclude_dirs, exclude_files)

    #             # Update project context
                context.set_project_structure(structure)

                logger.info(f"Analyzed project: {context.name} ({project_id})")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to analyze project {project_id}: {e}")
    #             return False

    #     def refresh_project(
    #         self,
    #         project_id: str,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> bool:
    #         """
    #         Refresh a project's structure and metadata.

    #         Args:
    #             project_id: Project ID to refresh
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             True if successful, False if not found
    #         """
    #         if project_id not in self.project_contexts:
                logger.warning(f"Project {project_id} not found")
    #             return False

    #         # Re-analyze the project
    success = self.analyze_project(project_id, exclude_dirs, exclude_files)

    #         if success:
                logger.info(f"Refreshed project: {project_id}")

    #         return success

    #     def _add_to_recent_projects(self, project_id: str):
    #         """Add a project to the recent projects list."""
    #         if project_id not in self.recent_projects:
                self.recent_projects.insert(0, project_id)

    #         # Keep only the most recent projects
    self.recent_projects = self.recent_projects[:50]

    #     def get_projects_by_language(self, language: str) -> List[ProjectContext]:
    #         """
    #         Get all projects that contain files of a specific language.

    #         Args:
                language: Language name (e.g., 'python', 'javascript')

    #         Returns:
    #             List of ProjectContext instances
    #         """
    projects = []

    #         for context in self.project_contexts.values():
    #             if (
    #                 context.project_structure
    #                 and language in context.project_structure.languages
    #             ):
                    projects.append(context)

    #         return projects

    #     def get_projects_by_type(self, project_type: str) -> List[ProjectContext]:
    #         """
    #         Get all projects of a specific type.

    #         Args:
                project_type: Project type (e.g., 'python', 'javascript', 'generic')

    #         Returns:
    #             List of ProjectContext instances
    #         """
    #         return [
    #             p for p in self.project_contexts.values() if p.project_type == project_type
    #         ]

    #     def get_projects_with_file(self, file_name: str) -> List[ProjectContext]:
    #         """
    #         Get all projects that contain a file with the given name.

    #         Args:
    #             file_name: Name of the file to search for

    #         Returns:
    #             List of ProjectContext instances
    #         """
    projects = []

    #         for context in self.project_contexts.values():
    #             if context.project_structure:
    #                 for file_path in context.project_structure.files:
    #                     if file_path.endswith(file_name) or file_name in file_path:
                            projects.append(context)
    #                         break

    #         return projects

    #     def search_projects(
    #         self,
    #         query: str,
    search_in_name: bool = True,
    search_in_description: bool = True,
    search_in_files: bool = False,
    #     ) -> List[ProjectContext]:
    #         """
    #         Search for projects matching a query.

    #         Args:
    #             query: Search query string
    #             search_in_name: Whether to search in project names
    #             search_in_description: Whether to search in project descriptions
    #             search_in_files: Whether to search in file names

    #         Returns:
    #             List of matching ProjectContext instances
    #         """
    query = query.lower()
    matches = []

    #         for context in self.project_contexts.values():
    #             # Search in name
    #             if search_in_name and query in context.name.lower():
                    matches.append(context)
    #                 continue

    #             # Search in description
    #             if search_in_description and query in context.description.lower():
                    matches.append(context)
    #                 continue

    #             # Search in files
    #             if search_in_files and context.project_structure:
    #                 for file_path in context.project_structure.files:
    #                     if query in file_path.lower():
                            matches.append(context)
    #                         break

    #         return matches

    #     def get_project_statistics(self, project_id: str) -> Dict[str, Any]:
    #         """
    #         Get comprehensive statistics for a project.

    #         Args:
    #             project_id: Project ID

    #         Returns:
    #             Dictionary with project statistics
    #         """
    #         if project_id not in self.project_contexts:
    #             return {}

    context = self.project_contexts[project_id]
    stats = {
    #             "id": context.id,
    #             "name": context.name,
    #             "type": context.project_type,
    #             "version": context.version,
    #             "description": context.description,
                "created_at": context.created_at.isoformat(),
                "last_updated": context.last_updated.isoformat(),
                "last_analyzed": (
    #                 context.last_analyzed.isoformat() if context.last_analyzed else None
    #             ),
    #             "is_active": context.is_active,
                "open_files_count": len(context.open_files),
    #             "selected_file": context.selected_file,
    #             "view_mode": context.view_mode,
    #             "statistics": context.statistics,
                "dependencies_count": sum(
    #                 len(deps) for deps in context.dependencies.values()
    #             ),
    #         }

    #         # Add project structure statistics if available
    #         if context.project_structure:
                stats.update(
    #                 {
    #                     "total_files": context.project_structure.total_files,
    #                     "total_size": context.project_structure.total_size,
                        "directory_count": len(context.project_structure.directories),
                        "language_distribution": dict(context.project_structure.languages),
                        "config_file_count": len(context.project_structure.config_files),
                        "package_file_count": len(context.project_structure.package_files),
    #                 }
    #             )

    #         return stats

    #     def get_all_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get statistics for all managed projects.

    #         Returns:
    #             Dictionary with all project statistics
    #         """
    all_stats = {
                "total_projects": len(self.project_contexts),
                "active_projects": sum(
    #                 1 for p in self.project_contexts.values() if p.is_active
    #             ),
                "recent_projects": len(self.recent_projects),
    #             "projects_by_type": {},
    #             "projects_by_language": {},
    #             "total_files": 0,
    #             "total_size": 0,
    #         }

    #         # Count projects by type and language
    #         for context in self.project_contexts.values():
    #             # By type
    #             if context.project_type not in all_stats["projects_by_type"]:
    all_stats["projects_by_type"][context.project_type] = 0
    all_stats["projects_by_type"][context.project_type] + = 1

    #             # By language (if project structure available)
    #             if context.project_structure:
    #                 for lang, count in context.project_structure.languages.items():
    #                     if lang not in all_stats["projects_by_language"]:
    all_stats["projects_by_language"][lang] = 0
    all_stats["projects_by_language"][lang] + = count

    #                 # Add to totals
    all_stats["total_files"] + = context.project_structure.total_files
    all_stats["total_size"] + = context.project_structure.total_size

    #         return all_stats

    #     def save_contexts(self):
    #         """Save all project contexts to disk."""
    #         for context in self.project_contexts.values():
    #             try:
                    context.save_to_file(Path(context.root_path))
    #             except Exception as e:
    #                 logger.error(f"Failed to save context for project {context.id}: {e}")

    #     def load_contexts_from_directory(self, directory: Union[str, Path]):
    #         """
    #         Load project contexts from a directory.

    #         Args:
    #             directory: Directory to search for projects
    #         """
    directory = Path(directory)

    #         if not directory.exists():
                logger.warning(f"Directory does not exist: {directory}")
    #             return

    #         for item in directory.iterdir():
    #             if item.is_dir():
    #                 try:
    self.add_project(item, analyze = False)
    #                 except Exception as e:
                        logger.warning(f"Failed to load project from {item}: {e}")

    #     def export_project_list(self, file_path: Union[str, Path]) -> bool:
    #         """
    #         Export the list of projects to a JSON file.

    #         Args:
    #             file_path: Path to save the export file

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         try:
    export_data = {
                    "exported_at": datetime.now().isoformat(),
                    "total_projects": len(self.project_contexts),
    #                 "active_project_id": self.active_project_id,
    #                 "recent_projects": self.recent_projects,
    #                 "projects": {
    #                     pid: {
    #                         "id": ctx.id,
    #                         "name": ctx.name,
    #                         "root_path": ctx.root_path,
    #                         "project_type": ctx.project_type,
    #                         "version": ctx.version,
    #                         "description": ctx.description,
                            "created_at": ctx.created_at.isoformat(),
                            "last_updated": ctx.last_updated.isoformat(),
    #                         "is_active": ctx.is_active,
    #                     }
    #                     for pid, ctx in self.project_contexts.items()
    #                 },
    #             }

    #             with open(file_path, "w", encoding="utf-8") as f:
    json.dump(export_data, f, indent = 2, ensure_ascii=False)

                logger.info(f"Exported project list to {file_path}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to export project list: {e}")
    #             return False

    #     def import_project_list(self, file_path: Union[str, Path]) -> bool:
    #         """
    #         Import a project list from a JSON file.

    #         Args:
    #             file_path: Path to the import file

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         try:
    #             with open(file_path, "r", encoding="utf-8") as f:
    import_data = json.load(f)

    #             # Import recent projects
    self.recent_projects = import_data.get("recent_projects", [])

    #             # Import active project
    self.active_project_id = import_data.get("active_project_id")

    #             # Import projects
    #             for pid, project_data in import_data.get("projects", {}).items():
    context = ProjectContext(
    id = project_data["id"],
    name = project_data["name"],
    root_path = project_data["root_path"],
    project_type = project_data["project_type"],
    version = project_data.get("version", ""),
    description = project_data.get("description", ""),
    created_at = datetime.fromisoformat(project_data["created_at"]),
    last_updated = datetime.fromisoformat(project_data["last_updated"]),
    is_active = project_data.get("is_active", False),
    #                 )

    self.project_contexts[context.id] = context

                logger.info(f"Imported project list from {file_path}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to import project list: {e}")
    #             return False
