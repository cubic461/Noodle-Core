# Converted from Python to NoodleCore
# Original file: src

# """
# Plugin Interfaces for Noodle IDE

# This module defines the core interfaces and base classes for the Noodle IDE plugin system.
# """

import abc.ABC
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any
import time
import uuid


class PluginType(Enum)
    #     """Enumeration of supported plugin types."""
    UI = "ui"
    SERVICE = "service"
    AI = "ai"
    DEBUGGER = "debugger"
    EDITOR = "editor"
    VISUALIZATION = "visualization"
    THEME = "theme"
    LANGUAGE = "language"


class PluginState(Enum)
    #     """Enumeration of plugin states."""
    UNLOADED = "unloaded"
    LOADING = "loading"
    LOADED = "loaded"
    INITIALIZING = "initializing"
    INITIALIZED = "initialized"
    STARTING = "starting"
    STARTED = "started"
    STOPPING = "stopping"
    STOPPED = "stopped"
    ERROR = "error"


class PluginPermission(Enum)
    #     """Plugin permissions for security."""
    FILE_READ = "file.read"
    FILE_WRITE = "file.write"
    NETWORK_ACCESS = "network.access"
    SYSTEM_ACCESS = "system.access"
    UI_ACCESS = "ui.access"
    CONFIG_ACCESS = "config.access"
    EVENT_PUBLISH = "event.publish"
    EVENT_SUBSCRIBE = "event.subscribe"


dataclass
class PluginMetadata
    #     """Metadata for a plugin."""
    #     id: str
    #     name: str
    #     version: str
    #     description: str
    #     author: str
    #     plugin_type: PluginType
    dependencies: List[str] = field(default_factory=list)
    entry_point: str = "plugin.py"
    permissions: List[PluginPermission] = field(default_factory=list)
    min_noodle_version: str = "1.0.0"
    max_noodle_version: Optional[str] = None
    homepage: Optional[str] = None
    repository: Optional[str] = None
    license: Optional[str] = None
    keywords: List[str] = field(default_factory=list)
    tags: List[str] = field(default_factory=list)
    icon: Optional[str] = None
    screenshots: List[str] = field(default_factory=list)
    configuration_schema: Optional[Dict[str, Any]] = None


dataclass
class InitializationResult
    #     """Result of plugin initialization."""
    #     success: bool
    error: Optional[str] = None
    data: Dict[str, Any] = field(default_factory=dict)
    warnings: List[str] = field(default_factory=list)


dataclass
class StartResult
    #     """Result of plugin start."""
    #     success: bool
    error: Optional[str] = None
    data: Dict[str, Any] = field(default_factory=dict)


dataclass
class StopResult
    #     """Result of plugin stop."""
    #     success: bool
    error: Optional[str] = None
    data: Dict[str, Any] = field(default_factory=dict)


dataclass
class DestroyResult
    #     """Result of plugin destruction."""
    #     success: bool
    error: Optional[str] = None
    data: Dict[str, Any] = field(default_factory=dict)


class PluginContext
    #     """Context provided to plugins during initialization."""

    #     def __init__(
    #         self,
    #         plugin_id: str,
    #         plugin_manager,
    #         event_bus,
    #         config_manager,
    #         plugin_api,
    #         plugin_dir: Path,
    #         data_dir: Path,
    #     ):
    self.plugin_id = plugin_id
    self.plugin_manager = plugin_manager
    self.event_bus = event_bus
    self.config_manager = config_manager
    self.plugin_api = plugin_api
    self.plugin_dir = plugin_dir
    self.data_dir = data_dir
    self._state = {}
    self._permissions: List[PluginPermission] = []
    self._logger = None

    #     def get_state(self, key: str, default: Any = None) -Any):
    #         """Get a value from the plugin's state."""
            return self._state.get(key, default)

    #     def set_state(self, key: str, value: Any) -None):
    #         """Set a value in the plugin's state."""
    self._state[key] = value

    #     def clear_state(self) -None):
    #         """Clear all plugin state."""
            self._state.clear()

    #     def has_permission(self, permission: PluginPermission) -bool):
    #         """Check if plugin has a specific permission."""
    #         return permission in self._permissions

    #     def set_permissions(self, permissions: List[PluginPermission]) -None):
    #         """Set the permissions for this plugin."""
    self._permissions = permissions

    #     def get_logger(self):
    #         """Get a logger for this plugin."""
    #         if self._logger is None:
    #             import logging
    self._logger = logging.getLogger(f"plugin.{self.plugin_id}")
    #         return self._logger


class Plugin(ABC)
    #     """Base class for all plugins."""

    #     def __init__(self, metadata: PluginMetadata):
    self.metadata = metadata
    self.context: Optional[PluginContext] = None
    self.state = PluginState.UNLOADED
    self._error_message: Optional[str] = None
    self._start_time: Optional[float] = None
    self._request_id = str(uuid.uuid4())

    #     @abstractmethod
    #     async def initialize(self, context: PluginContext) -InitializationResult):
    #         """
    #         Initialize the plugin with the provided context.

    #         Args:
    #             context: The plugin context containing core services

    #         Returns:
    #             InitializationResult containing success status and any error
    #         """
    #         pass

    #     @abstractmethod
    #     async def start(self) -StartResult):
    #         """
    #         Start the plugin's functionality.

    #         Returns:
    #             StartResult with success status and any error
    #         """
    #         pass

    #     @abstractmethod
    #     async def stop(self) -StopResult):
    #         """
    #         Stop the plugin's functionality.

    #         Returns:
    #             StopResult with success status and any error
    #         """
    #         pass

    #     @abstractmethod
    #     async def destroy(self) -DestroyResult):
    #         """
    #         Clean up plugin resources.

    #         Returns:
    #             DestroyResult with success status and any error
    #         """
    #         pass

    #     def get_ui_component(self) -Optional[Any]):
    #         """
    #         Return the React component for this plugin's UI.

    #         Returns:
    #             React component class or None if no UI
    #         """
    #         return None

    #     def get_permissions(self) -List[PluginPermission]):
    #         """
    #         Get the permissions required by this plugin.

    #         Returns:
    #             List of permission strings
    #         """
    #         return self.metadata.permissions

    #     def get_dependencies(self) -List[str]):
    #         """
    #         Get the plugins this plugin depends on.

    #         Returns:
    #             List of plugin IDs
    #         """
    #         return self.metadata.dependencies

    #     def set_error(self, error_message: str) -None):
    #         """Set the plugin to error state with an error message."""
    self.state = PluginState.ERROR
    self._error_message = error_message

    #     def get_error(self) -Optional[str]):
    #         """Get the current error message."""
    #         return self._error_message

    #     def is_compatible_with(self, noodle_version: str) -bool):
    #         """
    #         Check if the plugin is compatible with the given Noodle version.

    #         Args:
    #             noodle_version: The Noodle IDE version string

    #         Returns:
    #             True if compatible, False otherwise
    #         """
    #         # TODO: Implement proper version comparison
    #         return True

    #     def get_uptime(self) -Optional[float]):
    #         """Get the uptime of the plugin if started."""
    #         if self._start_time is None:
    #             return None
            return time.time() - self._start_time

    #     def get_request_id(self) -str):
    #         """Get the unique request ID for this plugin instance."""
    #         return self._request_id


class UIPlugin(Plugin)
    #     """Base class for UI plugins."""

    #     @abstractmethod
    #     def get_component(self) -Any):
    #         """
    #         Get the main React component for this plugin.

    #         Returns:
    #             React component class
    #         """
    #         pass

    #     @abstractmethod
    #     def get_menu_items(self) -List[Dict[str, Any]]):
    #         """
    #         Get menu items to add to the IDE menu.

    #         Returns:
    #             List of menu item definitions
    #         """
    #         pass

    #     def get_toolbar_items(self) -List[Dict[str, Any]]):
    #         """
    #         Get toolbar items to add to the IDE toolbar.

    #         Returns:
    #             List of toolbar item definitions
    #         """
    #         return []

    #     def get_panel_components(self) -Dict[str, Any]):
    #         """
    #         Get panel components to add to the IDE.

    #         Returns:
    #             Dictionary of panel ID to component
    #         """
    #         return {}


class ServicePlugin(Plugin)
    #     """Base class for service plugins."""

    #     @abstractmethod
    #     async def handle_request(self, request: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle a service request.

    #         Args:
    #             request: Request data

    #         Returns:
    #             Response data
    #         """
    #         pass

    #     def get_endpoints(self) -List[Dict[str, Any]]):
    #         """
    #         Get the API endpoints provided by this service.

    #         Returns:
    #             List of endpoint definitions
    #         """
    #         return []


class AIPlugin(Plugin)
    #     """Base class for AI-powered plugins."""

    #     @abstractmethod
    #     async def process_input(self, input_data: Any) -Any):
    #         """
    #         Process input using AI capabilities.

    #         Args:
    #             input_data: Input to process

    #         Returns:
    #             Processed output
    #         """
    #         pass

    #     @abstractmethod
    #     def get_capabilities(self) -List[str]):
    #         """
    #         Get the AI capabilities of this plugin.

    #         Returns:
    #             List of capability strings
    #         """
    #         pass

    #     def get_model_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the AI model used.

    #         Returns:
    #             Model information dictionary
    #         """
    #         return {}


class DebuggerPlugin(Plugin)
    #     """Base class for debugger plugins."""

    #     @abstractmethod
    #     async def start_debugging(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Start a debugging session.

    #         Args:
    #             config: Debug configuration

    #         Returns:
    #             Debug session information
    #         """
    #         pass

    #     @abstractmethod
    #     async def stop_debugging(self) -Dict[str, Any]):
    #         """
    #         Stop the current debugging session.

    #         Returns:
    #             Result of stopping the session
    #         """
    #         pass

    #     @abstractmethod
    #     async def set_breakpoint(self, file: str, line: int) -Dict[str, Any]):
    #         """
    #         Set a breakpoint.

    #         Args:
    #             file: File path
    #             line: Line number

    #         Returns:
    #             Breakpoint information
    #         """
    #         pass

    #     async def remove_breakpoint(self, file: str, line: int) -Dict[str, Any]):
    #         """
    #         Remove a breakpoint.

    #         Args:
    #             file: File path
    #             line: Line number

    #         Returns:
    #             Result of removing breakpoint
    #         """
    #         pass


class ThemePlugin(Plugin)
    #     """Base class for theme plugins."""

    #     @abstractmethod
    #     def get_theme_definition(self) -Dict[str, Any]):
    #         """
    #         Get the theme definition.

    #         Returns:
    #             Theme definition dictionary
    #         """
    #         pass

    #     def get_css_variables(self) -Dict[str, str]):
    #         """
    #         Get CSS variables for the theme.

    #         Returns:
    #             Dictionary of CSS variable names to values
    #         """
    #         return {}


class LanguagePlugin(Plugin)
    #     """Base class for language support plugins."""

    #     @abstractmethod
    #     def get_language_info(self) -Dict[str, Any]):
    #         """
    #         Get language information.

    #         Returns:
    #             Language information dictionary
    #         """
    #         pass

    #     def get_syntax_definition(self) -Dict[str, Any]):
    #         """
    #         Get syntax definition for the language.

    #         Returns:
    #             Syntax definition dictionary
    #         """
    #         return {}

    #     def get_snippets(self) -List[Dict[str, Any]]):
    #         """
    #         Get code snippets for the language.

    #         Returns:
    #             List of snippet definitions
    #         """
    #         return []