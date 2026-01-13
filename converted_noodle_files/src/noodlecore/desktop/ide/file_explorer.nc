# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# File Explorer for NoodleCore Desktop IDE
#
# This module implements the file explorer component for the desktop IDE.
# """

import typing
import dataclasses
import enum
import logging
import os
import time
import pathlib.Path

# Import desktop GUI classes
import ...desktop.GUIError
import ..core.events.event_system.EventSystem,
import ..core.rendering.rendering_engine.RenderingEngine,
import ..core.components.component_library.ComponentLibrary,


class FileType(enum.Enum)
    #     """File types for file explorer."""
    FILE = "file"
    DIRECTORY = "directory"
    SYMLINK = "symlink"
    UNKNOWN = "unknown"


class SortOrder(enum.Enum)
    #     """Sort orders for file explorer."""
    NAME_ASC = "name_asc"
    NAME_DESC = "name_desc"
    TYPE_ASC = "type_asc"
    TYPE_DESC = "type_desc"
    SIZE_ASC = "size_asc"
    SIZE_DESC = "size_desc"
    DATE_ASC = "date_asc"
    DATE_DESC = "date_desc"


# @dataclasses.dataclass
class FileItem
    #     """File or directory item."""
    #     name: str
    #     path: str
    #     file_type: FileType
    size: int = 0
    modified_time: float = 0.0
    is_hidden: bool = False
    is_expanded: bool = False
    children: typing.List['FileItem'] = None

    #     def __post_init__(self):
    #         if self.children is None:
    self.children = []


# @dataclasses.dataclass
class FileExplorerConfig
    #     """Configuration for file explorer."""
    show_hidden_files: bool = False
    show_file_extensions: bool = True
    show_icons: bool = True
    auto_refresh: bool = True
    refresh_interval: float = 5.0
    root_path: str = "."
    sort_order: SortOrder = SortOrder.NAME_ASC
    icon_size: float = 16.0
    font_size: float = 12.0
    background_color: Color = None
    foreground_color: Color = None
    selection_color: Color = None

    #     def __post_init__(self):
    #         if self.background_color is None:
    self.background_color = Color(0.15, 0.15, 0.15, 1.0)
    #         if self.foreground_color is None:
    self.foreground_color = Color(0.9, 0.9, 0.9, 1.0)
    #         if self.selection_color is None:
    self.selection_color = Color(0.3, 0.6, 1.0, 0.3)


class FileExplorerError(GUIError)
    #     """Exception raised for file explorer operations."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "6001", details)


class FileExplorer
    #     """
    #     File Explorer component for NoodleCore Desktop IDE.

    #     This class provides file and directory browsing capabilities.
    #     """

    #     def __init__(self):
    #         """Initialize the file explorer."""
    self.logger = logging.getLogger(__name__)
    self._window_id: typing.Optional[str] = None
    self._event_system: typing.Optional[EventSystem] = None
    self._rendering_engine: typing.Optional[RenderingEngine] = None
    self._component_library: typing.Optional[ComponentLibrary] = None
    self._config: typing.Optional[FileExplorerConfig] = None
    self._is_initialized = False

    #         # File system data
    self._current_path: str = "."
    self._root_items: typing.List[FileItem] = []
    self._selected_items: typing.List[str] = []
    self._expanded_paths: typing.Set[str] = set()

    #         # UI components
    self._panel_id: typing.Optional[str] = None
    self._tree_view_id: typing.Optional[str] = None
    self._refresh_button_id: typing.Optional[str] = None

    #         # Event callbacks
    self._on_file_open: typing.Callable = None
    self._on_path_change: typing.Callable = None

    #         # Statistics
    self._stats = {
    #             'files_displayed': 0,
    #             'directories_displayed': 0,
    #             'refresh_count': 0,
    #             'last_refresh_time': 0.0
    #         }

    #     def initialize(self, window_id: str, event_system: EventSystem,
    #                   rendering_engine: RenderingEngine, component_library: ComponentLibrary,
    config: FileExplorerConfig = None):
    #         """
    #         Initialize the file explorer.

    #         Args:
    #             window_id: Window ID to attach to
    #             event_system: Event system instance
    #             rendering_engine: Rendering engine instance
    #             component_library: Component library instance
    #             config: Explorer configuration
    #         """
    #         try:
    self._window_id = window_id
    self._event_system = event_system
    self._rendering_engine = rendering_engine
    self._component_library = component_library
    self._config = config or FileExplorerConfig()

    #             # Create explorer UI components
                self._create_explorer_ui()

    #             # Load initial content
                self._load_directory(self._config.root_path)

    #             # Register event handlers
                self._register_event_handlers()

    self._is_initialized = True
                self.logger.info("File explorer initialized")

    #         except Exception as e:
                self.logger.error(f"Failed to initialize file explorer: {e}")
                raise FileExplorerError(f"Initialization failed: {str(e)}")

    #     def _create_explorer_ui(self):
    #         """Create the file explorer UI components."""
    #         try:
    #             # Create main panel
    self._panel_id = self._component_library.create_component(
    #                 ComponentType.PANEL, self._window_id,
                    ComponentProperties(
    x = 0, y=0, width=250, height=400,
    text = "File Explorer",
    background_color = self._config.background_color,
    foreground_color = self._config.foreground_color,
    border = True
    #                 )
    #             )

    #             # Create tree view area (simplified for now)
    self._tree_view_id = self._component_library.create_component(
    #                 ComponentType.PANEL, self._window_id,
                    ComponentProperties(
    x = 5, y=25, width=240, height=370,
    text = "",
    background_color = self._config.background_color,
    border = False
    #                 )
    #             )

                self.logger.debug("File explorer UI created")

    #         except Exception as e:
                self.logger.error(f"Failed to create explorer UI: {e}")
                raise FileExplorerError(f"UI creation failed: {str(e)}")

    #     def _register_event_handlers(self):
    #         """Register event handlers for the file explorer."""
    #         try:
    #             # Mouse click events
                self._event_system.register_handler(
    #                 EventType.MOUSE_CLICK,
    #                 self._handle_mouse_click
    #             )

    #             # Double click events
                self._event_system.register_handler(
    #                 EventType.MOUSE_CLICK,
    #                 self._handle_double_click,
    window_id = self._window_id
    #             )

                self.logger.debug("File explorer event handlers registered")

    #         except Exception as e:
                self.logger.error(f"Failed to register event handlers: {e}")
                raise FileExplorerError(f"Event handler registration failed: {str(e)}")

    #     def _handle_mouse_click(self, event_info):
    #         """Handle mouse click events."""
    #         try:
    #             # Handle file/directory selection
    #             if hasattr(event_info, 'data') and event_info.data:
    mouse_event = event_info.data.get('mouse_event')
    #                 if mouse_event and mouse_event.button == 1:  # Left click
                        self.logger.debug("Mouse click handled in file explorer")

    #         except Exception as e:
                self.logger.error(f"Error handling mouse click: {e}")

    #     def _handle_double_click(self, event_info):
    #         """Handle double click events."""
    #         try:
    #             # Handle file opening on double click
    #             if hasattr(event_info, 'data') and event_info.data:
    mouse_event = event_info.data.get('mouse_event')
    #                 if mouse_event and mouse_event.button == 1:  # Left click
                        self.logger.debug("Double click handled in file explorer")
    #                     # This would open the selected file

    #         except Exception as e:
                self.logger.error(f"Error handling double click: {e}")

    #     def _load_directory(self, path: str) -> bool:
    #         """Load directory contents."""
    #         try:
                self.logger.info(f"Loading directory: {path}")

    #             # Validate path
    #             if not os.path.exists(path):
                    self.logger.warning(f"Path does not exist: {path}")
    #                 return False

    #             if not os.path.isdir(path):
                    self.logger.warning(f"Path is not a directory: {path}")
    #                 return False

    #             # Load directory contents
    items = []
    #             try:
    #                 for item_name in os.listdir(path):
    item_path = os.path.join(path, item_name)

    #                     # Skip hidden files if not configured to show them
    #                     if not self._config.show_hidden_files and item_name.startswith('.'):
    #                         continue

    #                     # Determine file type
    #                     if os.path.islink(item_path):
    file_type = FileType.SYMLINK
    #                     elif os.path.isdir(item_path):
    file_type = FileType.DIRECTORY
    #                     elif os.path.isfile(item_path):
    file_type = FileType.FILE
    #                     else:
    file_type = FileType.UNKNOWN

    #                     # Get file stats
    #                     try:
    stat_info = os.stat(item_path)
    size = stat_info.st_size
    modified_time = stat_info.st_mtime
    #                     except OSError:
    size = 0
    modified_time = 0

    #                     # Create file item
    item = FileItem(
    name = item_name,
    path = item_path,
    file_type = file_type,
    size = size,
    modified_time = modified_time,
    is_hidden = item_name.startswith('.')
    #                     )

                        items.append(item)

    #             except OSError as e:
                    self.logger.error(f"Failed to list directory {path}: {e}")
    #                 return False

    #             # Sort items
    items = self._sort_items(items)

    #             # Store items
    #             if path == self._config.root_path:
    self._root_items = items
    #             else:
                    self._update_expanded_directory(path, items)

    #             # Update statistics
                self._update_stats(items)

    self._current_path = path
    self._stats['refresh_count'] + = 1
    self._stats['last_refresh_time'] = time.time()

    #             # Notify path change
    #             if self._on_path_change:
                    self._on_path_change(path)

                self.logger.info(f"Loaded {len(items)} items from {path}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to load directory {path}: {e}")
                raise FileExplorerError(f"Directory loading failed: {str(e)}")

    #     def _sort_items(self, items: typing.List[FileItem]) -> typing.List[FileItem]:
    #         """Sort file items according to configuration."""
    #         try:
    sorted_items = items.copy()

    #             if self._config.sort_order == SortOrder.NAME_ASC:
    sorted_items.sort(key = lambda x: x.name.lower())
    #             elif self._config.sort_order == SortOrder.NAME_DESC:
    sorted_items.sort(key = lambda x: x.name.lower(), reverse=True)
    #             elif self._config.sort_order == SortOrder.TYPE_ASC:
    sorted_items.sort(key = lambda x: (x.file_type.value, x.name.lower()))
    #             elif self._config.sort_order == SortOrder.TYPE_DESC:
    sorted_items.sort(key = lambda x: (x.file_type.value, x.name.lower()), reverse=True)
    #             elif self._config.sort_order == SortOrder.SIZE_ASC:
    sorted_items.sort(key = lambda x: x.size)
    #             elif self._config.sort_order == SortOrder.SIZE_DESC:
    sorted_items.sort(key = lambda x: x.size, reverse=True)
    #             elif self._config.sort_order == SortOrder.DATE_ASC:
    sorted_items.sort(key = lambda x: x.modified_time)
    #             elif self._config.sort_order == SortOrder.DATE_DESC:
    sorted_items.sort(key = lambda x: x.modified_time, reverse=True)

    #             return sorted_items

    #         except Exception as e:
                self.logger.error(f"Failed to sort items: {e}")
    #             return items

    #     def _update_expanded_directory(self, path: str, items: typing.List[FileItem]):
    #         """Update expanded directory with loaded items."""
    #         try:
    #             # Find the expanded directory and update its children
    #             for item in self._root_items:
    #                 if self._find_and_update_directory(item, path, items):
    #                     break

    #         except Exception as e:
                self.logger.error(f"Failed to update expanded directory: {e}")

    #     def _find_and_update_directory(self, item: FileItem, path: str, items: typing.List[FileItem]) -> bool:
    #         """Find and update a directory item."""
    #         try:
    #             if item.path == path:
    item.children = items
    item.is_expanded = True
    #                 return True

    #             # Recursively search children
    #             for child in item.children:
    #                 if self._find_and_update_directory(child, path, items):
    #                     return True

    #             return False

    #         except Exception as e:
                self.logger.error(f"Failed to find and update directory: {e}")
    #             return False

    #     def _update_stats(self, items: typing.List[FileItem]):
    #         """Update file explorer statistics."""
    #         try:
    #             files = sum(1 for item in items if item.file_type == FileType.FILE)
    #             dirs = sum(1 for item in items if item.file_type == FileType.DIRECTORY)

    self._stats['files_displayed'] = files
    self._stats['directories_displayed'] = dirs

    #         except Exception as e:
                self.logger.error(f"Failed to update stats: {e}")

    #     def navigate_to_path(self, path: str) -> bool:
    #         """Navigate to a specific path."""
    #         try:
    #             if not os.path.exists(path):
                    self.logger.warning(f"Path does not exist: {path}")
    #                 return False

                return self._load_directory(path)

    #         except Exception as e:
                self.logger.error(f"Failed to navigate to {path}: {e}")
    #             return False

    #     def navigate_up(self) -> bool:
    #         """Navigate to parent directory."""
    #         try:
    parent_path = os.path.dirname(self._current_path)
    #             if parent_path != self._current_path:  # Not at root
                    return self._load_directory(parent_path)
    #             return False

    #         except Exception as e:
                self.logger.error(f"Failed to navigate up: {e}")
    #             return False

    #     def refresh(self) -> bool:
    #         """Refresh the current directory."""
    #         try:
                return self._load_directory(self._current_path)

    #         except Exception as e:
                self.logger.error(f"Failed to refresh: {e}")
    #             return False

    #     def toggle_hidden_files(self) -> bool:
    #         """Toggle showing hidden files."""
    #         try:
    self._config.show_hidden_files = not self._config.show_hidden_files
                return self.refresh()

    #         except Exception as e:
                self.logger.error(f"Failed to toggle hidden files: {e}")
    #             return False

    #     def set_sort_order(self, sort_order: SortOrder) -> bool:
    #         """Set the sort order."""
    #         try:
    self._config.sort_order = sort_order
                return self.refresh()

    #         except Exception as e:
                self.logger.error(f"Failed to set sort order: {e}")
    #             return False

    #     def open_file(self, file_path: str) -> bool:
    #         """Open a file in the editor."""
    #         try:
                self.logger.info(f"Opening file: {file_path}")

    #             # Notify file open callback
    #             if self._on_file_open:
                    self._on_file_open(file_path)
    #                 return True

    #             return False

    #         except Exception as e:
                self.logger.error(f"Failed to open file {file_path}: {e}")
    #             return False

    #     def set_on_file_open_callback(self, callback: typing.Callable):
    #         """Set callback for file open events."""
    self._on_file_open = callback

    #     def set_on_path_change_callback(self, callback: typing.Callable):
    #         """Set callback for path change events."""
    self._on_path_change = callback

    #     def get_current_path(self) -> str:
    #         """Get the current path."""
    #         return self._current_path

    #     def get_root_items(self) -> typing.List[FileItem]:
    #         """Get the root directory items."""
            return self._root_items.copy()

    #     def get_stats(self) -> typing.Dict[str, typing.Any]:
    #         """Get file explorer statistics."""
    stats = self._stats.copy()
            stats.update({
    #             'current_path': self._current_path,
    #             'config': {
    #                 'show_hidden_files': self._config.show_hidden_files,
    #                 'sort_order': self._config.sort_order.value,
    #                 'root_path': self._config.root_path
    #             }
    #         })
    #         return stats

    #     def is_initialized(self) -> bool:
    #         """Check if the file explorer is initialized."""
    #         return self._is_initialized


# Export main classes
__all__ = ['FileType', 'SortOrder', 'FileItem', 'FileExplorerConfig', 'FileExplorer']