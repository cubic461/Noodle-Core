# """
# Multi-Tab Manager for NoodleCore Desktop IDE
# 
# This module implements tab management for multiple file editing,
# with support for tab creation, closing, reordering, and state persistence.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time
import os

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color
from ..core.components.component_library import ComponentLibrary


class TabState(Enum):
    # """Tab state enumeration."""
    OPEN = "open"
    DIRTY = "dirty"  # Modified but not saved
    CLOSING = "closing"
    LOADING = "loading"
    READONLY = "readonly"


class TabPosition(Enum):
    # """Tab position relative to others."""
    FIRST = "first"
    MIDDLE = "middle"
    LAST = "last"
    ONLY = "only"


@dataclasses.dataclass
class TabInfo:
    # """Tab information data."""
    tab_id: str
    title: str
    file_path: str
    icon: str = ""
    state: TabState = TabState.OPEN
    is_modified: bool = False
    is_selected: bool = False
    position: TabPosition = TabPosition.LAST
    creation_time: float = None
    last_modified: float = None
    file_size: int = 0
    encoding: str = "utf-8"
    line_count: int = 0
    cursor_position: typing.Tuple[int, int] = (1, 1)
    scroll_position: typing.Tuple[int, int] = (0, 0)
    tab_order: int = 0
    
    def __post_init__(self):
        if self.creation_time is None:
            self.creation_time = time.time()
        if self.last_modified is None:
            self.last_modified = time.time()


@dataclasses.dataclass
class TabGroup:
    # """Group of related tabs (e.g., split editors)."""
    group_id: str
    name: str
    tab_ids: typing.List[str]
    orientation: str = "horizontal"  # horizontal or vertical
    is_active: bool = True
    creation_time: float = None
    
    def __post_init__(self):
        if self.creation_time is None:
            self.creation_time = time.time()


@dataclasses.dataclass
class TabLayout:
    # """Tab layout configuration."""
    show_tabs: bool = True
    tab_position: str = "top"  # top, bottom, left, right
    close_button_on_hover: bool = True
    show_file_icons: bool = True
    show_modified_indicators: bool = True
    enable_tab_scrolling: bool = True
    max_visible_tabs: int = 20
    min_tab_width: int = 120
    max_tab_width: int = 300
    
    # Visual styles
    active_tab_color: Color = None
    inactive_tab_color: Color = None
    modified_tab_color: Color = None
    tab_text_color: Color = None
    
    def __post_init__(self):
        # Default colors (dark theme)
        if self.active_tab_color is None:
            self.active_tab_color = Color(0.2, 0.2, 0.25, 1.0)
        if self.inactive_tab_color is None:
            self.inactive_tab_color = Color(0.15, 0.15, 0.18, 1.0)
        if self.modified_tab_color is None:
            self.modified_tab_color = Color(0.3, 0.2, 0.2, 1.0)
        if self.tab_text_color is None:
            self.tab_text_color = Color(0.86, 0.88, 0.91, 1.0)


class TabManagerError(GUIError):
    # """Exception raised for tab manager operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "11001", details)


class TabCreationError(TabManagerError):
    # """Raised when tab creation fails."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "11002", details)


class TabStateError(TabManagerError):
    # """Raised when tab state operations fail."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "11003", details)


class TabManager:
    # """
    # Multi-Tab Manager for NoodleCore Desktop IDE.
    # 
    # This class provides comprehensive tab management functionality including
    # tab creation, closing, reordering, state persistence, and grouping.
    # """
    
    def __init__(self):
        # """Initialize the tab manager."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        self._tab_control_component_id = None
        self._tab_area_component_id = None
        
        # Tab management
        self._tabs: typing.Dict[str, TabInfo] = {}
        self._tab_order: typing.List[str] = []
        self._active_tab_id: typing.Optional[str] = None
        self._tab_groups: typing.Dict[str, TabGroup] = {}
        
        # Tab groups management
        self._active_group_id: typing.Optional[str] = None
        self._tab_counter = 0
        
        # Layout configuration
        self._layout = TabLayout()
        
        # Callbacks
        self._on_tab_select: typing.Callable = None
        self._on_tab_close: typing.Callable = None
        self._on_tab_modify: typing.Callable = None
        self._on_tab_create: typing.Callable = None
        
        # Configuration
        self._auto_save_enabled = True
        self._auto_save_interval = 30.0  # seconds
        self._restore_closed_tabs = True
        self._recently_closed: typing.List[TabInfo] = []
        self._max_recently_closed = 10
        
        # Metrics
        self._metrics = {
            "tabs_created": 0,
            "tabs_closed": 0,
            "tabs_reopened": 0,
            "active_tab_switches": 0,
            "total_tab_lifetime": 0.0,
            "groups_created": 0
        }
        
        # Initialize with default group
        self._create_default_group()
    
    def _create_default_group(self):
        # """Create default tab group."""
        try:
            default_group = TabGroup(
                group_id=str(uuid.uuid4()),
                name="Default",
                tab_ids=[],
                orientation="horizontal",
                is_active=True
            )
            
            self._tab_groups[default_group.group_id] = default_group
            self._active_group_id = default_group.group_id
            self._metrics["groups_created"] += 1
            
            self.logger.info("Created default tab group")
            
        except Exception as e:
            self.logger.error(f"Failed to create default group: {str(e)}")
    
    def initialize(self, window_id: str, event_system: EventSystem,
                  rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        # """
        # Initialize the tab manager.
        
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
            
            # Create tab control
            self._create_tab_control()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Start auto-save timer if enabled
            if self._auto_save_enabled:
                self._start_auto_save_timer()
            
            self.logger.info("Tab manager initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize tab manager: {str(e)}")
            raise TabManagerError(f"Tab manager initialization failed: {str(e)}")
    
    def _create_tab_control(self):
        # """Create the tab control component."""
        try:
            # Create tab area container
            self._tab_area_component_id = self._component_library.create_component(
                component_type="container",
                window_id=self._window_id,
                x=0,
                y=0,
                width=800,
                height=25,
                title="Tab Bar",
                show_border=False
            )
            
            # Create tab control
            self._tab_control_component_id = self._component_library.create_component(
                component_type="tab_control",
                window_id=self._window_id,
                tabs=[],  # Start with no tabs
                x=0,
                y=0,
                width=800,
                height=25,
                show_icons=self._layout.show_file_icons,
                enable_scrolling=self._layout.enable_tab_scrolling,
                max_tabs=self._layout.max_visible_tabs
            )
            
            self.logger.info("Tab control created")
            
        except Exception as e:
            self.logger.error(f"Failed to create tab control: {str(e)}")
            raise TabManagerError(f"Tab control creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        # """Register event handlers."""
        try:
            # Tab selection
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_tab_click,
                window_id=self._window_id
            )
            
            # Tab closing
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_tab_close_click,
                window_id=self._window_id
            )
            
            # Tab dragging for reordering
            self._event_system.register_handler(
                EventType.MOUSE_DRAG,
                self._handle_tab_drag,
                window_id=self._window_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise TabManagerError(f"Event handler registration failed: {str(e)}")
    
    def open_tab(self, file_path: str, title: str = None, options: typing.Dict[str, typing.Any] = None) -> str:
        # """
        # Open a new tab.
        
        Args:
            file_path: Path to file to open
            title: Tab title (defaults to filename)
            options: Additional options
        
        Returns:
            Tab ID
        """
        try:
            if options is None:
                options = {}
            
            # Check if file already open in a tab
            for tab_id, tab_info in self._tabs.items():
                if tab_info.file_path == file_path:
                    self.select_tab(tab_id)
                    return tab_id
            
            # Create new tab
            tab_id = str(uuid.uuid4())
            tab_title = title or os.path.basename(file_path)
            
            # Get file info
            file_stats = self._get_file_info(file_path)
            
            tab_info = TabInfo(
                tab_id=tab_id,
                title=tab_title,
                file_path=file_path,
                state=TabState.OPEN,
                creation_time=time.time(),
                file_size=file_stats.get('size', 0),
                encoding=file_stats.get('encoding', 'utf-8')
            )
            
            # Add tab to collection
            self._tabs[tab_id] = tab_info
            self._tab_order.append(tab_id)
            self._tab_counter += 1
            tab_info.tab_order = self._tab_counter
            
            # Add to current group
            if self._active_group_id:
                group = self._tab_groups[self._active_group_id]
                group.tab_ids.append(tab_id)
            
            # Update component
            self._update_tab_control()
            
            # Set as active tab
            self._active_tab_id = tab_id
            tab_info.is_selected = True
            self._metrics["tabs_created"] += 1
            
            # Notify callback
            if self._on_tab_create:
                self._on_tab_create(tab_id, tab_info)
            
            self.logger.info(f"Opened tab: {tab_title} ({file_path})")
            return tab_id
            
        except Exception as e:
            self.logger.error(f"Failed to open tab for {file_path}: {str(e)}")
            raise TabCreationError(f"Tab creation failed: {str(e)}")
    
    def close_tab(self, tab_id: str, force: bool = False) -> bool:
        # """
        # Close a tab.
        
        Args:
            tab_id: ID of tab to close
            force: Force close without saving
        
        Returns:
            True if successful
        """
        try:
            if tab_id not in self._tabs:
                return False
            
            tab_info = self._tabs[tab_id]
            
            # Check if tab has unsaved changes
            if tab_info.is_modified and not force:
                # In real implementation, would show save dialog
                self.logger.warning("Tab has unsaved changes")
                return False
            
            # Set tab state to closing
            tab_info.state = TabState.CLOSING
            
            # Remove from group
            if self._active_group_id:
                group = self._tab_groups[self._active_group_id]
                if tab_id in group.tab_ids:
                    group.tab_ids.remove(tab_id)
            
            # Add to recently closed if restore enabled
            if self._restore_closed_tabs:
                self._recently_closed.append(tab_info)
                if len(self._recently_closed) > self._max_recently_closed:
                    self._recently_closed.pop(0)
            
            # Remove from collections
            self._tabs.pop(tab_id)
            if tab_id in self._tab_order:
                self._tab_order.remove(tab_id)
            
            # Select another tab if this was active
            if self._active_tab_id == tab_id:
                self._active_tab_id = self._get_next_tab_id(tab_id)
                if self._active_tab_id:
                    self.select_tab(self._active_tab_id)
            
            # Update component
            self._update_tab_control()
            
            # Notify callback
            if self._on_tab_close:
                self._on_tab_close(tab_id, tab_info)
            
            self._metrics["tabs_closed"] += 1
            self.logger.info(f"Closed tab: {tab_info.title}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to close tab {tab_id}: {str(e)}")
            return False
    
    def select_tab(self, tab_id: str) -> bool:
        # """
        # Select a tab.
        
        Args:
            tab_id: ID of tab to select
        
        Returns:
            True if successful
        """
        try:
            if tab_id not in self._tabs:
                return False
            
            # Deselect current tab
            if self._active_tab_id and self._active_tab_id in self._tabs:
                self._tabs[self._active_tab_id].is_selected = False
            
            # Select new tab
            self._active_tab_id = tab_id
            self._tabs[tab_id].is_selected = True
            
            # Update component
            self._update_tab_control()
            
            # Notify callback
            if self._on_tab_select:
                self._on_tab_select(tab_id, self._tabs[tab_id])
            
            self._metrics["active_tab_switches"] += 1
            self.logger.debug(f"Selected tab: {tab_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to select tab {tab_id}: {str(e)}")
            return False
    
    def reorder_tab(self, tab_id: str, new_position: int) -> bool:
        # """
        # Reorder a tab.
        
        Args:
            tab_id: ID of tab to reorder
            new_position: New position in tab order (0-based)
        
        Returns:
            True if successful
        """
        try:
            if tab_id not in self._tab_order:
                return False
            
            current_position = self._tab_order.index(tab_id)
            
            if new_position < 0 or new_position >= len(self._tab_order):
                return False
            
            # Remove from current position
            self._tab_order.remove(tab_id)
            
            # Insert at new position
            self._tab_order.insert(new_position, tab_id)
            
            # Update tab order
            for i, tid in enumerate(self._tab_order):
                if tid in self._tabs:
                    self._tabs[tid].tab_order = i
            
            # Update component
            self._update_tab_control()
            
            self.logger.info(f"Reordered tab {tab_id} to position {new_position}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to reorder tab {tab_id}: {str(e)}")
            return False
    
    def mark_tab_modified(self, tab_id: str, modified: bool):
        # """
        # Mark tab as modified/unmodified.
        
        Args:
            tab_id: ID of tab
            modified: Whether tab is modified
        """
        try:
            if tab_id not in self._tabs:
                return
            
            tab_info = self._tabs[tab_id]
            was_modified = tab_info.is_modified
            
            tab_info.is_modified = modified
            tab_info.state = TabState.DIRTY if modified else TabState.OPEN
            tab_info.last_modified = time.time()
            
            # Update component
            self._update_tab_control()
            
            # Notify callback
            if self._on_tab_modify and was_modified != modified:
                self._on_tab_modify(tab_id, tab_info, modified)
            
            self.logger.debug(f"Tab {tab_id} marked as {'modified' if modified else 'clean'}")
            
        except Exception as e:
            self.logger.error(f"Failed to mark tab {tab_id} as modified: {str(e)}")
    
    def rename_tab(self, tab_id: str, new_title: str) -> bool:
        # """
        # Rename a tab.
        
        Args:
            tab_id: ID of tab to rename
            new_title: New tab title
        
        Returns:
            True if successful
        """
        try:
            if tab_id not in self._tabs:
                return False
            
            old_title = self._tabs[tab_id].title
            self._tabs[tab_id].title = new_title
            
            # Update component
            self._update_tab_control()
            
            self.logger.info(f"Renamed tab from '{old_title}' to '{new_title}'")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to rename tab {tab_id}: {str(e)}")
            return False
    
    def create_tab_group(self, name: str, tab_ids: typing.List[str] = None) -> str:
        # """
        # Create a new tab group.
        
        Args:
            name: Group name
            tab_ids: List of tab IDs to include (optional)
        
        Returns:
            Group ID
        """
        try:
            group_id = str(uuid.uuid4())
            group = TabGroup(
                group_id=group_id,
                name=name,
                tab_ids=tab_ids or [],
                orientation="horizontal"
            )
            
            # Deactivate current group
            if self._active_group_id and self._active_group_id in self._tab_groups:
                self._tab_groups[self._active_group_id].is_active = False
            
            # Set new group as active
            self._tab_groups[group_id] = group
            self._active_group_id = group_id
            
            # Update metrics
            self._metrics["groups_created"] += 1
            
            self.logger.info(f"Created tab group: {name} ({group_id})")
            return group_id
            
        except Exception as e:
            self.logger.error(f"Failed to create tab group {name}: {str(e)}")
            raise TabManagerError(f"Tab group creation failed: {str(e)}")
    
    def close_all_tabs(self, exclude_active: bool = False) -> int:
        # """
        # Close all tabs.
        
        Args:
            exclude_active: Don't close the active tab
        
        Returns:
            Number of tabs closed
        """
        try:
            closed_count = 0
            tabs_to_close = self._tab_order.copy()
            
            if exclude_active and self._active_tab_id:
                tabs_to_close = [tid for tid in tabs_to_close if tid != self._active_tab_id]
            
            for tab_id in tabs_to_close:
                if self.close_tab(tab_id):
                    closed_count += 1
            
            self.logger.info(f"Closed {closed_count} tabs")
            return closed_count
            
        except Exception as e:
            self.logger.error(f"Failed to close all tabs: {str(e)}")
            return 0
    
    def reopen_last_tab(self) -> typing.Optional[str]:
        # """
        # Reopen the last closed tab.
        
        Returns:
            Tab ID of reopened tab, or None if none available
        """
        try:
            if not self._recently_closed:
                return None
            
            # Get most recently closed tab
            closed_tab_info = self._recently_closed.pop()
            
            # Recreate tab
            tab_id = self.open_tab(closed_tab_info.file_path, closed_tab_info.title)
            self._metrics["tabs_reopened"] += 1
            
            self.logger.info(f"Reopened tab: {closed_tab_info.title}")
            return tab_id
            
        except Exception as e:
            self.logger.error(f"Failed to reopen last tab: {str(e)}")
            return None
    
    def get_active_tab(self) -> typing.Optional[TabInfo]:
        # """Get information about the active tab."""
        if self._active_tab_id and self._active_tab_id in self._tabs:
            return self._tabs[self._active_tab_id]
        return None
    
    def get_all_tabs(self) -> typing.Dict[str, TabInfo]:
        # """Get all tabs."""
        return self._tabs.copy()
    
    def get_tab(self, tab_id: str) -> typing.Optional[TabInfo]:
        # """Get tab information by ID."""
        return self._tabs.get(tab_id)
    
    def get_tab_by_file_path(self, file_path: str) -> typing.Optional[TabInfo]:
        # """Get tab information by file path."""
        for tab_info in self._tabs.values():
            if tab_info.file_path == file_path:
                return tab_info
        return None
    
    def get_tab_count(self) -> int:
        # """Get total number of tabs."""
        return len(self._tabs)
    
    def get_modified_tabs(self) -> typing.List[TabInfo]:
        # """Get list of modified tabs."""
        return [tab for tab in self._tabs.values() if tab.is_modified]
    
    def set_callbacks(self, on_tab_select: typing.Callable = None,
                     on_tab_close: typing.Callable = None,
                     on_tab_modify: typing.Callable = None,
                     on_tab_create: typing.Callable = None):
        # """
        # Set tab manager callbacks.
        
        Args:
            on_tab_select: Called when tab is selected
            on_tab_close: Called when tab is closed
            on_tab_modify: Called when tab modification state changes
            on_tab_create: Called when new tab is created
        """
        self._on_tab_select = on_tab_select
        self._on_tab_close = on_tab_close
        self._on_tab_modify = on_tab_modify
        self._on_tab_create = on_tab_create
    
    def set_layout(self, **kwargs):
        # """
        # Update tab layout configuration.
        
        Args:
            **kwargs: Layout options to update
        """
        for key, value in kwargs.items():
            if hasattr(self._layout, key):
                setattr(self._layout, key, value)
        
        # Apply changes to component
        self._update_tab_control()
        self.logger.info("Tab layout updated")
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        # """Get tab manager metrics."""
        return self._metrics.copy()
    
    # Private methods
    
    def _get_file_info(self, file_path: str) -> typing.Dict[str, typing.Any]:
        # """Get file information."""
        try:
            if not os.path.exists(file_path):
                return {"size": 0, "encoding": "utf-8"}
            
            stat = os.stat(file_path)
            return {
                "size": stat.st_size,
                "modified": stat.st_mtime,
                "encoding": "utf-8"  # Simplified
            }
        except Exception as e:
            self.logger.warning(f"Failed to get file info for {file_path}: {str(e)}")
            return {"size": 0, "encoding": "utf-8"}
    
    def _get_next_tab_id(self, current_tab_id: str) -> typing.Optional[str]:
        # """Get the next tab ID after closing current tab."""
        try:
            current_index = self._tab_order.index(current_tab_id) if current_tab_id in self._tab_order else -1
            
            # Try to select the tab to the right
            if current_index < len(self._tab_order) - 1:
                return self._tab_order[current_index + 1]
            
            # Try to select the tab to the left
            if current_index > 0:
                return self._tab_order[current_index - 1]
            
            # No other tabs
            return None
            
        except Exception as e:
            self.logger.error(f"Failed to get next tab ID: {str(e)}")
            return None
    
    def _update_tab_control(self):
        # """Update the tab control component with current tabs."""
        try:
            # Prepare tab data
            tab_data = []
            for tab_id in self._tab_order:
                if tab_id in self._tabs:
                    tab_info = self._tabs[tab_id]
                    
                    # Create tab display info
                    display_title = tab_info.title
                    if tab_info.is_modified:
                        display_title += " •"
                    
                    tab_data.append({
                        "id": tab_id,
                        "title": display_title,
                        "icon": tab_info.icon,
                        "is_selected": tab_info.is_selected,
                        "is_modified": tab_info.is_modified
                    })
            
            # Update component
            self._component_library.update_tab_control(
                self._tab_control_component_id,
                tabs=tab_data
            )
            
        except Exception as e:
            self.logger.error(f"Failed to update tab control: {str(e)}")
    
    def _start_auto_save_timer(self):
        # """Start auto-save timer for modified tabs."""
        # In real implementation, would start a timer thread
        self.logger.debug("Auto-save timer started")
    
    # Event handlers
    
    def _handle_tab_click(self, event: MouseEvent):
        # """Handle tab clicks."""
        # In real implementation, would identify clicked tab and select it
        self.logger.debug(f"Tab click at ({event.x}, {event.y})")
    
    def _handle_tab_close_click(self, event: MouseEvent):
        # """Handle tab close button clicks."""
        # In real implementation, would identify clicked close button and close tab
        self.logger.debug(f"Tab close click at ({event.x}, {event.y})")
    
    def _handle_tab_drag(self, event):
        # """Handle tab dragging for reordering."""
        # In real implementation, would handle drag and drop for tab reordering
        self.logger.debug(f"Tab drag: {event}")