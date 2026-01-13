# """
# File Explorer for NoodleCore Desktop IDE - Integrated Version
# 
# This module implements file and project navigation with tree view,
# file operations, and integration with NoodleCore file APIs via system integrator.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time
import os
import json

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent
from ..core.rendering.rendering_engine import RenderingEngine
from ..core.components.component_library import ComponentLibrary, TreeViewProperties, TreeNode
from .integration.system_integrator import NoodleCoreSystemIntegrator


class FileIcon(Enum):
    # """File type icons."""
    FILE = "file"
    FOLDER = "folder"
    PYTHON_FILE = "python_file"
    JS_FILE = "js_file"
    HTML_FILE = "html_file"
    CSS_FILE = "css_file"
    JSON_FILE = "json_file"
    MARKDOWN_FILE = "markdown_file"
    IMAGE_FILE = "image_file"
    EXECUTABLE_FILE = "executable_file"
    NOODLE_FILE = "noodle_file"
    NC_FILE = "nc_file"


class FileOperation(Enum):
    # """File operations."""
    CREATE = "create"
    DELETE = "delete"
    RENAME = "rename"
    MOVE = "move"
    COPY = "copy"
    OPEN = "open"


class FileFilter(Enum):
    # """File filter options."""
    ALL_FILES = "all"
    NOODLE_FILES = "*.nc"
    PYTHON_FILES = "*.py"
    JS_FILES = "*.js"
    MARKDOWN_FILES = "*.md"
    CONFIG_FILES = "*.json"
    SOURCE_FILES = "*.py,*.js,*.ts,*.nc"


@dataclass
class FileInfo:
    # """File information."""
    path: str
    name: str
    type: str
    size: int
    modified: float
    icon: FileIcon = None
    is_directory: bool = False
    is_hidden: bool = False
    is_readonly: bool = False
    
    def __post_init__(self):
        if self.icon is None:
            self.icon = self._determine_icon()
    
    def _determine_icon(self) -> FileIcon:
        """Determine file icon based on extension."""
        if self.is_directory:
            return FileIcon.FOLDER
        
        ext = os.path.splitext(self.name)[1].lower()
        icon_map = {
            ".py": FileIcon.PYTHON_FILE,
            ".js": FileIcon.JS_FILE,
            ".ts": FileIcon.JS_FILE,
            ".html": FileIcon.HTML_FILE,
            ".htm": FileIcon.HTML_FILE,
            ".css": FileIcon.CSS_FILE,
            ".json": FileIcon.JSON_FILE,
            ".md": FileIcon.MARKDOWN_FILE,
            ".nc": FileIcon.NOODLE_FILE,
            ".exe": FileIcon.EXECUTABLE_FILE,
            ".png": FileIcon.IMAGE_FILE,
            ".jpg": FileIcon.IMAGE_FILE,
            ".jpeg": FileIcon.IMAGE_FILE,
            ".gif": FileIcon.IMAGE_FILE,
            ".svg": FileIcon.IMAGE_FILE
        }
        
        return icon_map.get(ext, FileIcon.FILE)


@dataclass
class ProjectInfo:
    # """Project information."""
    name: str
    path: str
    type: str
    root_node_id: str
    configuration: typing.Dict[str, typing.Any] = None
    files_count: int = 0
    last_opened: float = None
    
    def __post_init__(self):
        if self.configuration is None:
            self.configuration = {}
        if self.last_opened is None:
            self.last_opened = time.time()


class FileExplorerError(GUIError):
    # """Exception raised for file explorer operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "7001", details)


class FileOperationError(FileExplorerError):
    # """Raised when file operations fail."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "7002", details)


class ProjectLoadError(FileExplorerError):
    # """Raised when project loading fails."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "7003", details)


class IntegratedFileExplorer:
    # """
    # Integrated File Explorer for NoodleCore Desktop IDE.
    # 
    # This class provides file and project navigation, tree view management,
    # file operations, and integration with NoodleCore file APIs via system integrator.
    # """
    
    def __init__(self, system_integrator: NoodleCoreSystemIntegrator = None):
        # """Initialize the integrated file explorer."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # System integration
        self._system_integrator = system_integrator or NoodleCoreSystemIntegrator()
        
        # Window and component references
        self._window_id = None
        self._tree_view_component_id = None
        
        # Project and file data
        self._current_project: typing.Optional[ProjectInfo] = None
        self._projects: typing.Dict[str, ProjectInfo] = {}
        self._file_tree_nodes: typing.Dict[str, TreeNode] = {}
        self._expanded_nodes: typing.Set[str] = set()
        
        # File operation callbacks
        self._on_file_open: typing.Optional[typing.Callable] = None
        self._on_file_create: typing.Optional[typing.Callable] = None
        self._on_file_delete: typing.Optional[typing.Callable] = None
        
        # Configuration
        self._show_hidden_files = False
        self._auto_refresh = True
        self._filter: FileFilter = FileFilter.ALL_FILES
        self._use_backend_api = True
        
        # Metrics
        self._metrics = {
            "projects_loaded": 0,
            "nodes_created": 0,
            "file_operations": 0,
            "refresh_count": 0,
            "files_browsed": 0,
            "api_operations": 0,
            "backend_operations": 0
        }
    
    def initialize(self, window_id: str, event_system: EventSystem,
                  rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        # """
        # Initialize the file explorer.
        
        Args:
            window_id: Window ID to attach to
            event_system: Event system instance
            rendering_engine: Rendering engine instance
            component_library: Component library instance
        """
        try:
            self._window_id = window_id
            self._event_system = event_system
            self._rendering_engine = rendering_engine
            self._component_library = component_library
            
            # Initialize system integrator
            if not self._system_integrator.initialize():
                self.logger.warning("System integrator initialization failed, falling back to local operations")
                self._use_backend_api = False
            
            # Create tree view component
            self._create_tree_view()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Set up integration callbacks
            self._setup_integration_callbacks()
            
            self.logger.info("Integrated file explorer initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize file explorer: {str(e)}")
            raise FileExplorerError(f"File explorer initialization failed: {str(e)}")
    
    def _setup_integration_callbacks(self):
        """Set up callbacks for system integrator integration."""
        if self._system_integrator:
            # Set callback for file operations
            self._system_integrator.set_callback("file_operation", self._handle_backend_file_operation)
    
    def _handle_backend_file_operation(self, operation_data: typing.Dict):
        """Handle file operations from backend API."""
        try:
            operation_type = operation_data.get("operation")
            file_path = operation_data.get("path")
            
            if operation_type == "file_created":
                self.logger.info(f"Backend: File created: {file_path}")
                if self._auto_refresh:
                    self.refresh()
            elif operation_type == "file_deleted":
                self.logger.info(f"Backend: File deleted: {file_path}")
                if self._auto_refresh:
                    self.refresh()
            elif operation_type == "file_modified":
                self.logger.info(f"Backend: File modified: {file_path}")
                if self._auto_refresh:
                    self.refresh()
                    
        except Exception as e:
            self.logger.error(f"Error handling backend file operation: {str(e)}")
    
    def _create_tree_view(self):
        # """Create the tree view component."""
        try:
            # Create root node
            root_node = TreeNode(
                node_id="root",
                text="NoodleCore IDE",
                icon="folder",
                expanded=True
            )
            
            # Create tree view component
            self._tree_view_component_id = self._component_library.create_component(
                component_type="tree_view",
                window_id=self._window_id,
                root_node=root_node,
                x=0,
                y=0,
                width=250,
                height=400,
                show_icons=True,
                show_lines=True,
                allow_multi_select=False
            )
            
            self.logger.info(f"Created tree view component: {self._tree_view_component_id}")
            
        except Exception as e:
            self.logger.error(f"Failed to create tree view: {str(e)}")
            raise FileExplorerError(f"Tree view creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        # """Register event handlers."""
        try:
            # Node selection events
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_tree_click,
                window_id=self._window_id
            )
            
            # Context menu events
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_context_menu,
                window_id=self._window_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise FileExplorerError(f"Event handler registration failed: {str(e)}")
    
    def load_project(self, project_path: str, project_type: str = "generic") -> bool:
        # """
        # Load a project into the file explorer.
        
        Args:
            project_path: Path to project directory
            project_type: Type of project (python, nodejs, etc.)
        
        Returns:
            True if successful
        """
        try:
            if self._use_backend_api and self._system_integrator:
                return self._load_project_via_api(project_path, project_type)
            else:
                return self._load_project_locally(project_path, project_type)
                
        except Exception as e:
            self.logger.error(f"Failed to load project {project_path}: {str(e)}")
            raise ProjectLoadError(f"Project loading failed: {str(e)}")
    
    def _load_project_via_api(self, project_path: str, project_type: str) -> bool:
        """Load project using backend API."""
        try:
            # Get file tree from backend
            files_data = self._system_integrator.get_file_tree(project_path)
            
            if not files_data:
                self.logger.warning("Backend API returned no file data, falling back to local")
                return self._load_project_locally(project_path, project_type)
            
            # Create project info
            project_name = os.path.basename(project_path)
            project_info = ProjectInfo(
                name=project_name,
                path=project_path,
                type=project_type
            )
            
            # Build file tree from API data
            root_node_id = self._build_file_tree_from_api(files_data, project_name, project_path)
            project_info.root_node_id = root_node_id
            
            # Count files
            project_info.files_count = self._count_files_in_tree(files_data)
            
            # Register project
            self._projects[project_path] = project_info
            self._current_project = project_info
            
            # Update tree view
            self._update_tree_view()
            
            # Update metrics
            self._metrics["projects_loaded"] += 1
            self._metrics["refresh_count"] += 1
            self._metrics["backend_operations"] += 1
            
            self.logger.info(f"Loaded project via API: {project_name} from {project_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to load project via API: {str(e)}")
            return self._load_project_locally(project_path, project_type)
    
    def _load_project_locally(self, project_path: str, project_type: str) -> bool:
        """Load project using local filesystem."""
        try:
            if not os.path.exists(project_path):
                raise ProjectLoadError(f"Project path does not exist: {project_path}")
            
            if not os.path.isdir(project_path):
                raise ProjectLoadError(f"Project path is not a directory: {project_path}")
            
            # Create project info
            project_name = os.path.basename(project_path)
            project_info = ProjectInfo(
                name=project_name,
                path=project_path,
                type=project_type
            )
            
            # Build file tree locally
            root_node_id = self._build_file_tree(project_path, project_name)
            project_info.root_node_id = root_node_id
            
            # Register project
            self._projects[project_path] = project_info
            self._current_project = project_info
            
            # Update tree view
            self._update_tree_view()
            
            # Update metrics
            self._metrics["projects_loaded"] += 1
            self._metrics["refresh_count"] += 1
            
            self.logger.info(f"Loaded project locally: {project_name} from {project_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to load project locally: {str(e)}")
            raise ProjectLoadError(f"Project loading failed: {str(e)}")
    
    def _build_file_tree_from_api(self, files_data: typing.List[typing.Dict], display_name: str, root_path: str) -> str:
        """Build file tree from backend API data."""
        try:
            root_node_id = str(uuid.uuid4())
            
            # Create root node
            root_node = TreeNode(
                node_id=root_node_id,
                text=display_name,
                icon="folder",
                expanded=True,
                user_data={"path": root_path, "is_directory": True}
            )
            
            # Build tree from API data
            self._build_tree_from_api_recursive(root_node, files_data, root_path)
            
            # Store tree node
            self._file_tree_nodes[root_node_id] = root_node
            
            return root_node_id
            
        except Exception as e:
            self.logger.error(f"Failed to build file tree from API: {str(e)}")
            raise FileExplorerError(f"API file tree building failed: {str(e)}")
    
    def _build_tree_from_api_recursive(self, parent_node: TreeNode, files_data: typing.List[typing.Dict], base_path: str):
        """Build tree recursively from API data."""
        try:
            # Filter files for this directory
            dir_files = []
            for file_data in files_data:
                file_path = file_data.get("path", "")
                file_dir = os.path.dirname(file_path)
                if file_dir == base_path or (not file_dir and base_path == "."):
                    dir_files.append(file_data)
            
            # Sort files (directories first, then files)
            dir_files.sort(key=lambda f: (not f.get("is_directory", False), f.get("name", "").lower()))
            
            for file_data in dir_files:
                file_name = file_data.get("name", "")
                file_path = file_data.get("path", "")
                is_directory = file_data.get("is_directory", False)
                
                # Create file info
                file_info = FileInfo(
                    path=file_path,
                    name=file_name,
                    type="directory" if is_directory else "file",
                    size=file_data.get("size", 0),
                    modified=file_data.get("modified", time.time()),
                    is_directory=is_directory
                )
                
                # Create tree node
                node_id = str(uuid.uuid4())
                node = TreeNode(
                    node_id=node_id,
                    text=file_name,
                    icon=file_info.icon.value,
                    expanded=False,
                    parent=parent_node,
                    user_data={
                        "path": file_path,
                        "file_info": file_info,
                        "is_directory": is_directory,
                        "api_data": file_data
                    }
                )
                
                # Add to parent
                parent_node.children.append(node)
                
                # Store node
                self._file_tree_nodes[node_id] = node
                self._metrics["nodes_created"] += 1
                
                # Recursively build for directories
                if is_directory:
                    # Find child files for this directory
                    child_files = []
                    for f in files_data:
                        f_path = f.get("path", "")
                        f_dir = os.path.dirname(f_path)
                        if f_dir == file_path:
                            child_files.append(f)
                    
                    if child_files:
                        self._build_tree_from_api_recursive(node, child_files, file_path)
                        
        except Exception as e:
            self.logger.warning(f"Error building API tree for {base_path}: {str(e)}")
    
    def _count_files_in_tree(self, files_data: typing.List[typing.Dict]) -> int:
        """Count files in tree data."""
        count = 0
        for file_data in files_data:
            if not file_data.get("is_directory", False):
                count += 1
        return count
    
    def _build_file_tree(self, directory_path: str, display_name: str) -> str:
        # """
        # Build a file tree from directory structure.
        
        Args:
            directory_path: Directory to scan
            display_name: Display name for root node
        
        Returns:
            Root node ID
        """
        try:
            root_node_id = str(uuid.uuid4())
            
            # Create root node
            root_node = TreeNode(
                node_id=root_node_id,
                text=display_name,
                icon="folder",
                expanded=True,
                user_data={"path": directory_path, "is_directory": True}
            )
            
            # Build tree recursively
            self._build_tree_recursive(root_node, directory_path)
            
            # Store tree node
            self._file_tree_nodes[root_node_id] = root_node
            
            return root_node_id
            
        except Exception as e:
            self.logger.error(f"Failed to build file tree: {str(e)}")
            raise FileExplorerError(f"File tree building failed: {str(e)}")
    
    def _build_tree_recursive(self, parent_node: TreeNode, directory_path: str):
        # """
        # Build tree recursively.
        
        Args:
            parent_node: Parent tree node
            directory_path: Directory path to scan
        """
        try:
            # Get directory contents
            try:
                entries = os.listdir(directory_path)
            except (PermissionError, OSError):
                return
            
            # Sort entries (directories first, then files)
            entries.sort(key=lambda e: (not os.path.isdir(os.path.join(directory_path, e)), e.lower()))
            
            for entry in entries:
                entry_path = os.path.join(directory_path, entry)
                
                # Skip hidden files if not showing hidden
                if not self._show_hidden_files and entry.startswith('.'):
                    continue
                
                try:
                    is_directory = os.path.isdir(entry_path)
                    file_info = FileInfo(
                        path=entry_path,
                        name=entry,
                        type="directory" if is_directory else "file",
                        size=os.path.getsize(entry_path) if not is_directory else 0,
                        modified=os.path.getmtime(entry_path),
                        is_directory=is_directory
                    )
                    
                    # Create tree node
                    node_id = str(uuid.uuid4())
                    node = TreeNode(
                        node_id=node_id,
                        text=entry,
                        icon=file_info.icon.value,
                        expanded=False,
                        parent=parent_node,
                        user_data={
                            "path": entry_path,
                            "file_info": file_info,
                            "is_directory": is_directory
                        }
                    )
                    
                    # Add to parent
                    parent_node.children.append(node)
                    
                    # Store node
                    self._file_tree_nodes[node_id] = node
                    self._metrics["nodes_created"] += 1
                    
                    # Recursively build for directories
                    if is_directory:
                        self._build_tree_recursive(node, entry_path)
                        
                except (PermissionError, OSError):
                    # Skip inaccessible files
                    continue
                    
        except Exception as e:
            self.logger.warning(f"Error building tree for {directory_path}: {str(e)}")
    
    def _update_tree_view(self):
        # """Update the tree view with current project."""
        try:
            if not self._current_project:
                return
            
            # Get root node
            root_node = self._file_tree_nodes.get(self._current_project.root_node_id)
            if not root_node:
                return
            
            # Update tree view component
            self._component_library.update_component(
                self._tree_view_component_id,
                root_node=root_node
            )
            
            self.logger.info("Tree view updated")
            
        except Exception as e:
            self.logger.error(f"Failed to update tree view: {str(e)}")
    
    def refresh(self) -> bool:
        # """
        # Refresh the file explorer view.
        
        Returns:
            True if successful
        """
        try:
            if not self._current_project:
                return False
            
            # Refresh using appropriate method
            if self._use_backend_api and self._system_integrator:
                success = self._refresh_via_api()
            else:
                success = self._refresh_locally()
            
            if success:
                self._metrics["refresh_count"] += 1
            
            return success
            
        except Exception as e:
            self.logger.error(f"Failed to refresh file explorer: {str(e)}")
            return False
    
    def _refresh_via_api(self) -> bool:
        """Refresh using backend API."""
        try:
            # Get fresh file tree from API
            files_data = self._system_integrator.get_file_tree(self._current_project.path)
            
            if files_data:
                # Rebuild file tree
                root_node_id = self._build_file_tree_from_api(
                    files_data,
                    self._current_project.name,
                    self._current_project.path
                )
                
                # Update project info
                self._current_project.root_node_id = root_node_id
                self._current_project.files_count = self._count_files_in_tree(files_data)
                
                # Update tree view
                self._update_tree_view()
                
                self._metrics["backend_operations"] += 1
                self.logger.info("File explorer refreshed via API")
                return True
            else:
                self.logger.warning("API refresh failed, falling back to local")
                return self._refresh_locally()
                
        except Exception as e:
            self.logger.error(f"API refresh failed: {str(e)}")
            return self._refresh_locally()
    
    def _refresh_locally(self) -> bool:
        """Refresh using local filesystem."""
        try:
            # Rebuild file tree
            root_node_id = self._build_file_tree(
                self._current_project.path,
                self._current_project.name
            )
            
            # Update project info
            self._current_project.root_node_id = root_node_id
            
            # Update tree view
            self._update_tree_view()
            
            self.logger.info("File explorer refreshed locally")
            return True
            
        except Exception as e:
            self.logger.error(f"Local refresh failed: {str(e)}")
            return False
    
    def create_file(self, parent_path: str, file_name: str, file_type: str = "text") -> bool:
        # """
        # Create a new file.
        
        Args:
            parent_path: Parent directory path
            file_name: Name of new file
            file_type: Type of file to create
        
        Returns:
            True if successful
        """
        try:
            file_path = os.path.join(parent_path, file_name)
            
            if self._use_backend_api and self._system_integrator:
                # Use backend API
                success = self._system_integrator.create_file(file_path)
                self._metrics["backend_operations"] += 1
            else:
                # Use local filesystem
                content = self._generate_file_content(file_name, file_type)
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                success = True
                self._metrics["api_operations"] += 1
            
            if success:
                self._metrics["file_operations"] += 1
                self.logger.info(f"Created file: {file_path}")
                
                # Refresh view
                if self._auto_refresh:
                    self.refresh()
                
                # Trigger callback
                if self._on_file_create:
                    self._on_file_create(file_path, file_type)
            
            return success
            
        except Exception as e:
            self.logger.error(f"Failed to create file {file_path}: {str(e)}")
            raise FileOperationError(f"File creation failed: {str(e)}")
    
    def delete_file(self, file_path: str) -> bool:
        # """
        # Delete a file or folder.
        
        Args:
            file_path: Path to file or folder to delete
        
        Returns:
            True if successful
        """
        try:
            if self._use_backend_api and self._system_integrator:
                # Use backend API
                success = self._system_integrator.delete_file(file_path)
                self._metrics["backend_operations"] += 1
            else:
                # Use local filesystem
                if os.path.isdir(file_path):
                    import shutil
                    shutil.rmtree(file_path)
                else:
                    os.remove(file_path)
                success = True
                self._metrics["api_operations"] += 1
            
            if success:
                self._metrics["file_operations"] += 1
                self.logger.info(f"Deleted: {file_path}")
                
                # Refresh view
                if self._auto_refresh:
                    self.refresh()
                
                # Trigger callback
                if self._on_file_delete:
                    self._on_file_delete(file_path)
            
            return success
            
        except Exception as e:
            self.logger.error(f"Failed to delete {file_path}: {str(e)}")
            raise FileOperationError(f"File deletion failed: {str(e)}")
    
    def open_file(self, file_path: str) -> bool:
        # """
        # Open a file in the IDE.
        
        Args:
            file_path: Path to file to open
        
        Returns:
            True if successful
        """
        try:
            if self._use_backend_api and self._system_integrator:
                # Check if file exists via API first
                content = self._system_integrator.get_file_content(file_path)
                if content is None:
                    # Fall back to local check
                    if not os.path.exists(file_path) or not os.path.isfile(file_path):
                        raise FileOperationError(f"File does not exist: {file_path}")
                self._metrics["backend_operations"] += 1
            else:
                # Use local filesystem
                if not os.path.exists(file_path):
                    raise FileOperationError(f"File does not exist: {file_path}")
                if not os.path.isfile(file_path):
                    raise FileOperationError(f"Path is not a file: {file_path}")
                self._metrics["api_operations"] += 1
            
            # Get file info
            if self._use_backend_api and self._system_integrator:
                # Try to get file info from API, fallback to local
                try:
                    files_data = self._system_integrator.get_file_tree(os.path.dirname(file_path))
                    file_info = None
                    if files_data:
                        for f in files_data:
                            if f.get("path") == file_path:
                                file_info = FileInfo(
                                    path=file_path,
                                    name=os.path.basename(file_path),
                                    type="file",
                                    size=f.get("size", 0),
                                    modified=f.get("modified", time.time()),
                                    is_directory=False
                                )
                                break
                    
                    if not file_info:
                        # Fallback to local
                        file_info = FileInfo(
                            path=file_path,
                            name=os.path.basename(file_path),
                            type="file",
                            size=os.path.getsize(file_path),
                            modified=os.path.getmtime(file_path),
                            is_directory=False
                        )
                except:
                    # Final fallback
                    file_info = FileInfo(
                        path=file_path,
                        name=os.path.basename(file_path),
                        type="file",
                        size=os.path.getsize(file_path),
                        modified=os.path.getmtime(file_path),
                        is_directory=False
                    )
            else:
                # Use local filesystem
                file_info = FileInfo(
                    path=file_path,
                    name=os.path.basename(file_path),
                    type="file",
                    size=os.path.getsize(file_path),
                    modified=os.path.getmtime(file_path),
                    is_directory=False
                )
            
            self._metrics["files_browsed"] += 1
            self.logger.info(f"Opening file: {file_path}")
            
            # Trigger callback
            if self._on_file_open:
                return self._on_file_open(file_path, file_info)
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to open file {file_path}: {str(e)}")
            raise FileOperationError(f"File open failed: {str(e)}")
    
    def set_system_integrator(self, system_integrator: NoodleCoreSystemIntegrator):
        """Set the system integrator for backend integration."""
        self._system_integrator = system_integrator
        self.logger.info("System integrator updated")
    
    def set_use_backend_api(self, use_api: bool):
        """Set whether to use backend API or local operations."""
        self._use_backend_api = use_api
        self.logger.info(f"Backend API usage: {use_api}")
    
    def set_filter(self, filter_type: FileFilter):
        # """
        # Set file filter.
        
        Args:
            filter_type: File filter to apply
        """
        self._filter = filter_type
        self.logger.info(f"Set file filter to: {filter_type.value}")
    
    def set_show_hidden_files(self, show: bool):
        # """
        # Set whether to show hidden files.
        
        Args:
            show: Whether to show hidden files
        """
        self._show_hidden_files = show
        self.logger.info(f"Show hidden files: {show}")
    
    def set_auto_refresh(self, auto: bool):
        # """
        # Set auto-refresh behavior.
        
        Args:
            auto: Whether to auto-refresh
        """
        self._auto_refresh = auto
        self.logger.info(f"Auto refresh: {auto}")
    
    def set_callbacks(self, on_file_open: typing.Callable = None,
                     on_file_create: typing.Callable = None,
                     on_file_delete: typing.Callable = None):
        # """
        # Set operation callbacks.
        
        Args:
            on_file_open: Callback when file is opened
            on_file_create: Callback when file is created
            on_file_delete: Callback when file is deleted
        """
        self._on_file_open = on_file_open
        self._on_file_create = on_file_create
        self._on_file_delete = on_file_delete
    
    def get_current_project(self) -> typing.Optional[ProjectInfo]:
        # """Get current project information."""
        return self._current_project
    
    def get_projects(self) -> typing.Dict[str, ProjectInfo]:
        # """Get all loaded projects."""
        return self._projects.copy()
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        # """Get file explorer metrics."""
        metrics = self._metrics.copy()
        
        # Add integration status
        if self._system_integrator:
            metrics["integration_status"] = self._system_integrator.get_integration_status()
            metrics["integration_metrics"] = self._system_integrator.get_integration_metrics()
        
        return metrics
    
    def _generate_file_content(self, file_name: str, file_type: str) -> str:
        # """
        # Generate initial content for new files.
        
        Args:
            file_name: Name of the file
            file_type: Type of file
        
        Returns:
            Initial file content
        """
        try:
            ext = os.path.splitext(file_name)[1].lower()
            
            if ext == ".py":
                return f'# {file_name}\\n# Created by NoodleCore IDE\\n\\n'
            elif ext in [".js", ".ts"]:
                return f'// {file_name}\\n// Created by NoodleCore IDE\\n\\n'
            elif ext == ".html":
                return f'<!DOCTYPE html>\\n<html>\\n<head>\\n    <title>{file_name}</title>\\n</head>\\n<body>\\n    <h1>{file_name}</h1>\\n</body>\\n</html>\\n'
            elif ext == ".css":
                return f'/* {file_name} */\\n/* Created by NoodleCore IDE */\\n\\n'
            elif ext == ".json":
                return '{\\n  "name": "' + file_name + '",\\n  "version": "1.0.0"\\n}\\n'
            elif ext == ".md":
                return f'# {file_name}\\n\\n## Created by NoodleCore IDE\\n\\n'
            elif ext == ".nc":
                return f'# {file_name}\\n# Created by NoodleCore IDE\\n# NoodleCore module file\\n\\n'
            else:
                return f'# {file_name}\\n# Created by NoodleCore IDE\\n\\n'
                
        except Exception as e:
            self.logger.warning(f"Failed to generate content for {file_name}: {str(e)}")
            return f'# {file_name}\\n# Created by NoodleCore IDE\\n\\n'
    
    # Event handlers
    
    def _handle_tree_click(self, event: MouseEvent):
        # """Handle tree view clicks."""
        # In real implementation, would handle node selection
        self.logger.debug(f"Tree click at ({event.x}, {event.y})")
    
    def _handle_context_menu(self, event: MouseEvent):
        # """Handle context menu requests."""
        # In real implementation, would show context menu
        self.logger.debug(f"Context menu request at ({event.x}, {event.y})")