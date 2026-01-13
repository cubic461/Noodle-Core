# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Tab Manager for NoodleCore Desktop IDE
#
# This module implements tab management for the desktop IDE.
# """

import typing
import dataclasses
import enum
import logging
import os
import time

# Import desktop GUI classes
import ...desktop.GUIError
import ..core.events.event_system.EventSystem,
import ..core.rendering.rendering_engine.RenderingEngine,
import ..core.components.component_library.ComponentLibrary,


class TabState(enum.Enum)
    #     """Tab states."""
    NORMAL = "normal"
    MODIFIED = "modified"
    READONLY = "readonly"
    CLOSED = "closed"


# @dataclasses.dataclass
class TabInfo
    #     """Information about a tab."""
    #     tab_id: str
    #     title: str
    #     file_path: str
    content: str = ""
    is_modified: bool = False
    is_readonly: bool = False
    state: TabState = TabState.NORMAL
    last_modified: float = 0.0
    is_active: bool = False
    icon: str = ""

    #     def __post_init__(self):
    #         if self.last_modified == 0.0:
    self.last_modified = time.time()


# @dataclasses.dataclass
class TabManagerConfig
    #     """Configuration for tab manager."""
    show_close_buttons: bool = True
    show_icons: bool = True
    show_modified_indicators: bool = True
    max_tabs: int = 20
    tab_width: float = 150.0
    tab_height: float = 25.0
    tab_spacing: float = 2.0
    close_button_size: float = 12.0
    background_color: Color = None
    foreground_color: Color = None
    active_tab_color: Color = None
    modified_tab_color: Color = None
    hover_color: Color = None

    #     def __post_init__(self):
    #         if self.background_color is None:
    self.background_color = Color(0.2, 0.2, 0.2, 1.0)
    #         if self.foreground_color is None:
    self.foreground_color = Color(0.8, 0.8, 0.8, 1.0)
    #         if self.active_tab_color is None:
    self.active_tab_color = Color(0.3, 0.3, 0.3, 1.0)
    #         if self.modified_tab_color is None:
    self.modified_tab_color = Color(0.1, 0.1, 0.1, 1.0)
    #         if self.hover_color is None:
    self.hover_color = Color(0.25, 0.25, 0.25, 1.0)


class TabManagerError(GUIError)
    #     """Exception raised for tab manager operations."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "7001", details)


class TabManager
    #     """
    #     Tab Manager component for NoodleCore Desktop IDE.

    #     This class manages editor tabs, including opening, closing, and switching between files.
    #     """

    #     def __init__(self):
    #         """Initialize the tab manager."""
    self.logger = logging.getLogger(__name__)
    self._window_id: typing.Optional[str] = None
    self._event_system: typing.Optional[EventSystem] = None
    self._rendering_engine: typing.Optional[RenderingEngine] = None
    self._component_library: typing.Optional[ComponentLibrary] = None
    self._config: typing.Optional[TabManagerConfig] = None
    self._is_initialized = False

    #         # Tab data
    self._tabs: typing.Dict[str, TabInfo] = {}
    self._tab_order: typing.List[str] = []  # Order of tabs
    self._active_tab_id: typing.Optional[str] = None
    self._next_tab_id = 1

    #         # UI components
    self._tab_bar_id: typing.Optional[str] = None
    self._close_button_ids: typing.Dict[str, str] = {}

    #         # Event callbacks
    self._on_tab_select: typing.Callable = None
    self._on_tab_close: typing.Callable = None
    self._on_tab_modify: typing.Callable = None
    self._on_tab_create: typing.Callable = None

    #         # Statistics
    self._stats = {
    #             'tabs_created': 0,
    #             'tabs_closed': 0,
    #             'tabs_modified': 0,
    #             'max_concurrent_tabs': 0,
    #             'total_tabs_opened': 0
    #         }

    #     def initialize(self, window_id: str, event_system: EventSystem,
    #                   rendering_engine: RenderingEngine, component_library: ComponentLibrary,
    config: TabManagerConfig = None):
    #         """
    #         Initialize the tab manager.

    #         Args:
    #             window_id: Window ID to attach to
    #             event_system: Event system instance
    #             rendering_engine: Rendering engine instance
    #             component_library: Component library instance
    #             config: Tab manager configuration
    #         """
    #         try:
    self._window_id = window_id
    self._event_system = event_system
    self._rendering_engine = rendering_engine
    self._component_library = component_library
    self._config = config or TabManagerConfig()

    #             # Create tab bar UI
                self._create_tab_bar_ui()

    #             # Register event handlers
                self._register_event_handlers()

    self._is_initialized = True
                self.logger.info("Tab manager initialized")

    #         except Exception as e:
                self.logger.error(f"Failed to initialize tab manager: {e}")
                raise TabManagerError(f"Initialization failed: {str(e)}")

    #     def _create_tab_bar_ui(self):
    #         """Create the tab bar UI components."""
    #         try:
    #             # Create tab bar panel
    self._tab_bar_id = self._component_library.create_component(
    #                 ComponentType.PANEL, self._window_id,
                    ComponentProperties(
    x = 0, y=0, width=800, height=self._config.tab_height,
    text = "",
    background_color = self._config.background_color,
    border = False
    #                 )
    #             )

                self.logger.debug("Tab bar UI created")

    #         except Exception as e:
                self.logger.error(f"Failed to create tab bar UI: {e}")
                raise TabManagerError(f"UI creation failed: {str(e)}")

    #     def _register_event_handlers(self):
    #         """Register event handlers for the tab manager."""
    #         try:
    #             # Mouse click events for tab switching
                self._event_system.register_handler(
    #                 EventType.MOUSE_CLICK,
    #                 self._handle_tab_click,
    window_id = self._window_id
    #             )

    #             # Double click events for new tab
                self._event_system.register_handler(
    #                 EventType.MOUSE_CLICK,
    #                 self._handle_double_click,
    window_id = self._window_id
    #             )

                self.logger.debug("Tab manager event handlers registered")

    #         except Exception as e:
                self.logger.error(f"Failed to register event handlers: {e}")
                raise TabManagerError(f"Event handler registration failed: {str(e)}")

    #     def _handle_tab_click(self, event_info):
    #         """Handle tab click events."""
    #         try:
    #             if hasattr(event_info, 'data') and event_info.data:
    mouse_event = event_info.data.get('mouse_event')
    #                 if mouse_event and mouse_event.button == 1:  # Left click
    #                     # This would determine which tab was clicked and switch to it
                        self.logger.debug("Tab click handled")

    #         except Exception as e:
                self.logger.error(f"Error handling tab click: {e}")

    #     def _handle_double_click(self, event_info):
    #         """Handle double click events."""
    #         try:
    #             if hasattr(event_info, 'data') and event_info.data:
    mouse_event = event_info.data.get('mouse_event')
    #                 if mouse_event and mouse_event.button == 1:  # Left click
    #                     # Create new tab on double click
                        self.logger.debug("Double click handled - creating new tab")

    #         except Exception as e:
                self.logger.error(f"Error handling double click: {e}")

    #     def open_tab(self, file_path: str, title: str = None, content: str = "") -> typing.Optional[str]:
    #         """
    #         Open a new tab.

    #         Args:
    #             file_path: Path to file
                title: Tab title (defaults to file name)
    #             content: Initial content

    #         Returns:
    #             Tab ID or None if failed
    #         """
    #         try:
    #             # Check if tab already exists
    existing_tab_id = self._find_tab_by_path(file_path)
    #             if existing_tab_id:
                    self.switch_to_tab(existing_tab_id)
    #                 return existing_tab_id

    #             # Check tab limit
    #             if len(self._tabs) >= self._config.max_tabs:
                    self.logger.warning(f"Maximum number of tabs ({self._config.max_tabs}) reached")
    #                 return None

    #             # Generate tab ID
    tab_id = f"tab_{self._next_tab_id}"
    self._next_tab_id + = 1

    #             # Create tab title if not provided
    #             if title is None:
    #                 title = os.path.basename(file_path) if file_path else "Untitled"

    #             # Create tab info
    tab_info = TabInfo(
    tab_id = tab_id,
    title = title,
    file_path = file_path,
    content = content
    #             )

    #             # Store tab
    self._tabs[tab_id] = tab_info
                self._tab_order.append(tab_id)

    #             # Switch to new tab
                self.switch_to_tab(tab_id)

    #             # Update statistics
    self._stats['tabs_created'] + = 1
    self._stats['total_tabs_opened'] + = 1
    self._stats['max_concurrent_tabs'] = max(self._stats['max_concurrent_tabs'], len(self._tabs))

    #             # Notify tab create callback
    #             if self._on_tab_create:
                    self._on_tab_create(tab_id, tab_info)

                self.logger.info(f"Opened tab: {title} ({file_path})")
    #             return tab_id

    #         except Exception as e:
                self.logger.error(f"Failed to open tab {file_path}: {e}")
                raise TabManagerError(f"Tab opening failed: {str(e)}")

    #     def close_tab(self, tab_id: str) -> bool:
    #         """
    #         Close a tab.

    #         Args:
    #             tab_id: ID of tab to close

    #         Returns:
    #             True if successful
    #         """
    #         try:
    #             if tab_id not in self._tabs:
    #                 return False

    tab_info = self._tabs[tab_id]

    #             # Notify tab close callback
    #             if self._on_tab_close:
                    self._on_tab_close(tab_id, tab_info)

    #             # Remove tab
    #             del self._tabs[tab_id]
    #             if tab_id in self._tab_order:
                    self._tab_order.remove(tab_id)

    #             # Switch to another tab if this was the active tab
    #             if self._active_tab_id == tab_id:
    #                 if self._tab_order:
    #                     # Switch to previous tab or first available
    new_active_index = math.subtract(max(0, self._tab_order.index(tab_id), 1))
    new_active_id = self._tab_order[new_active_index]
                        self.switch_to_tab(new_active_id)
    #                 else:
    self._active_tab_id = None

    #             # Update statistics
    self._stats['tabs_closed'] + = 1

                self.logger.info(f"Closed tab: {tab_info.title}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to close tab {tab_id}: {e}")
    #             return False

    #     def switch_to_tab(self, tab_id: str) -> bool:
    #         """
    #         Switch to a tab.

    #         Args:
    #             tab_id: ID of tab to switch to

    #         Returns:
    #             True if successful
    #         """
    #         try:
    #             if tab_id not in self._tabs:
    #                 return False

    #             # Deactivate current active tab
    #             if self._active_tab_id and self._active_tab_id in self._tabs:
    self._tabs[self._active_tab_id].is_active = False

    #             # Activate new tab
    self._tabs[tab_id].is_active = True
    self._active_tab_id = tab_id

    #             # Notify tab select callback
    #             if self._on_tab_select:
                    self._on_tab_select(tab_id, self._tabs[tab_id])

                self.logger.debug(f"Switched to tab: {self._tabs[tab_id].title}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to switch to tab {tab_id}: {e}")
    #             return False

    #     def set_tab_content(self, tab_id: str, content: str) -> bool:
    #         """
    #         Set tab content.

    #         Args:
    #             tab_id: ID of tab
    #             content: New content

    #         Returns:
    #             True if successful
    #         """
    #         try:
    #             if tab_id not in self._tabs:
    #                 return False

    tab_info = self._tabs[tab_id]
    was_modified = tab_info.is_modified

    #             # Update content and modification state
    tab_info.content = content
    tab_info.is_modified = True
    tab_info.state = TabState.MODIFIED
    tab_info.last_modified = time.time()

    #             # Update statistics if state changed
    #             if not was_modified:
    self._stats['tabs_modified'] + = 1

    #             # Notify tab modify callback
    #             if self._on_tab_modify:
                    self._on_tab_modify(tab_id, tab_info, True)

    #             self.logger.debug(f"Updated content for tab: {tab_info.title}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to set tab content {tab_id}: {e}")
    #             return False

    #     def save_tab_content(self, tab_id: str) -> bool:
    #         """
            Mark tab content as saved (not modified).

    #         Args:
    #             tab_id: ID of tab

    #         Returns:
    #             True if successful
    #         """
    #         try:
    #             if tab_id not in self._tabs:
    #                 return False

    tab_info = self._tabs[tab_id]
    was_modified = tab_info.is_modified

    #             # Update modification state
    tab_info.is_modified = False
    tab_info.state = TabState.NORMAL

    #             # Notify tab modify callback
    #             if self._on_tab_modify:
                    self._on_tab_modify(tab_id, tab_info, False)

    #             self.logger.debug(f"Saved content for tab: {tab_info.title}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to save tab content {tab_id}: {e}")
    #             return False

    #     def rename_tab(self, tab_id: str, new_title: str) -> bool:
    #         """
    #         Rename a tab.

    #         Args:
    #             tab_id: ID of tab
    #             new_title: New tab title

    #         Returns:
    #             True if successful
    #         """
    #         try:
    #             if tab_id not in self._tabs:
    #                 return False

    old_title = self._tabs[tab_id].title
    self._tabs[tab_id].title = new_title

                self.logger.debug(f"Renamed tab: {old_title} -> {new_title}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to rename tab {tab_id}: {e}")
    #             return False

    #     def _find_tab_by_path(self, file_path: str) -> typing.Optional[str]:
    #         """Find tab by file path."""
    #         for tab_id, tab_info in self._tabs.items():
    #             if tab_info.file_path == file_path:
    #                 return tab_id
    #         return None

    #     def get_active_tab(self) -> typing.Optional[TabInfo]:
    #         """Get the active tab."""
    #         if self._active_tab_id and self._active_tab_id in self._tabs:
    #             return self._tabs[self._active_tab_id]
    #         return None

    #     def get_tab(self, tab_id: str) -> typing.Optional[TabInfo]:
    #         """Get tab by ID."""
            return self._tabs.get(tab_id)

    #     def get_all_tabs(self) -> typing.List[TabInfo]:
    #         """Get all tabs in order."""
    #         return [self._tabs[tab_id] for tab_id in self._tab_order if tab_id in self._tabs]

    #     def get_modified_tabs(self) -> typing.List[TabInfo]:
    #         """Get all modified tabs."""
    #         return [tab for tab in self._tabs.values() if tab.is_modified]

    #     def close_all_tabs(self) -> bool:
    #         """Close all tabs."""
    #         try:
    #             # Close all tabs except active one first
    tab_ids = list(self._tabs.keys())
    #             for tab_id in tab_ids:
    #                 if tab_id != self._active_tab_id:
                        self.close_tab(tab_id)

    #             # Close active tab last
    #             if self._active_tab_id:
                    self.close_tab(self._active_tab_id)

    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to close all tabs: {e}")
    #             return False

    #     def set_callbacks(self, on_tab_select: typing.Callable = None,
    on_tab_close: typing.Callable = None,
    on_tab_modify: typing.Callable = None,
    on_tab_create: typing.Callable = None):
    #         """Set event callbacks."""
    self._on_tab_select = on_tab_select
    self._on_tab_close = on_tab_close
    self._on_tab_modify = on_tab_modify
    self._on_tab_create = on_tab_create

    #     def get_stats(self) -> typing.Dict[str, typing.Any]:
    #         """Get tab manager statistics."""
    stats = self._stats.copy()
            stats.update({
    #             'active_tab_id': self._active_tab_id,
                'current_tabs': len(self._tabs),
    #             'max_tabs': self._config.max_tabs,
                'tab_utilization': len(self._tabs) / self._config.max_tabs
    #         })
    #         return stats

    #     def is_initialized(self) -> bool:
    #         """Check if the tab manager is initialized."""
    #         return self._is_initialized


# Export main classes
__all__ = ['TabState', 'TabInfo', 'TabManagerConfig', 'TabManager']