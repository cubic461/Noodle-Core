# Converted from Python to NoodleCore
# Original file: src

# """
# Plugin API for Noodle IDE

# This module provides the core API that plugins can use to interact
# with the IDE and other services.
# """

import os
import json
import logging
import pathlib.Path
import typing.Any
from dataclasses import dataclass
import asyncio
import uuid
import time

import .interfaces.PluginPermission
import .event_bus.EventBus


class FileSystemAPI
    #     """
    #     Secure file system API for plugins.

    #     Provides controlled access to the file system with permission checks.
    #     """

    #     def __init__(self, plugin_context: PluginContext):""
    #         Initialize the file system API.

    #         Args:
    #             plugin_context: The plugin context
    #         """
    self.context = plugin_context
    self.logger = plugin_context.get_logger()
    self._allowed_paths = self._get_allowed_paths()

    #     def _get_allowed_paths(self) -List[Path]):
    #         """Get the list of paths this plugin is allowed to access."""
    paths = [
    #             self.context.plugin_dir,  # Plugin's own directory
    #             self.context.data_dir,    # Plugin's data directory
    #         ]

    #         # Add workspace directory if plugin has file read permission
    #         if self.context.has_permission(PluginPermission.FILE_READ):
    #             # Get current workspace directory from environment or config
    workspace_dir = os.environ.get("NOODLE_WORKSPACE_DIR", ".")
                paths.append(Path(workspace_dir).resolve())

    #         return paths

    #     def _check_permission(self, path: Path, permission: PluginPermission) -bool):
    #         """
    #         Check if the plugin has permission to access the given path.

    #         Args:
    #             path: Path to check
    #             permission: Required permission

    #         Returns:
    #             True if access is allowed
    #         """
    #         if not self.context.has_permission(permission):
                self.logger.warning(
    #                 f"Plugin {self.context.plugin_id} lacks permission {permission.value}"
    #             )
    #             return False

    #         # Check if path is within allowed paths
    resolved_path = path.resolve()
    #         for allowed_path in self._allowed_paths:
    #             if resolved_path.is_relative_to(allowed_path):
    #                 return True

            self.logger.warning(
    #             f"Plugin {self.context.plugin_id} attempted to access restricted path: {path}"
    #         )
    #         return False

    #     async def read_file(self, path: Union[str, Path], encoding: str = "utf-8") -str):
    #         """
    #         Read a file's contents.

    #         Args:
    #             path: Path to the file
    #             encoding: File encoding

    #         Returns:
    #             File contents as string

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #             FileNotFoundError: If file doesn't exist
    #         """
    path = Path(path)

    #         if not self._check_permission(path, PluginPermission.FILE_READ):
                raise PermissionError(f"No permission to read {path}")

    #         if not path.exists():
                raise FileNotFoundError(f"File not found: {path}")

            return await asyncio.get_event_loop().run_in_executor(
                None, lambda: path.read_text(encoding)
    #         )

    #     async def write_file(
    #         self,
    #         path: Union[str, Path],
    #         content: str,
    encoding: str = "utf-8",
    create_dirs: bool = True,
    #     ) -None):
    #         """
    #         Write content to a file.

    #         Args:
    #             path: Path to the file
    #             content: Content to write
    #             encoding: File encoding
    #             create_dirs: Whether to create parent directories

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #         """
    path = Path(path)

    #         if not self._check_permission(path, PluginPermission.FILE_WRITE):
                raise PermissionError(f"No permission to write to {path}")

    #         if create_dirs:
    path.parent.mkdir(parents = True, exist_ok=True)

            await asyncio.get_event_loop().run_in_executor(
                None, lambda: path.write_text(content, encoding)
    #         )

    #     async def read_json(self, path: Union[str, Path]) -Dict[str, Any]):
    #         """
    #         Read a JSON file.

    #         Args:
    #             path: Path to the JSON file

    #         Returns:
    #             Parsed JSON data

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #             json.JSONDecodeError: If file is not valid JSON
    #         """
    content = await self.read_file(path)
            return json.loads(content)

    #     async def write_json(
    #         self,
    #         path: Union[str, Path],
    #         data: Dict[str, Any],
    indent: int = 2,
    #     ) -None):
    #         """
    #         Write data to a JSON file.

    #         Args:
    #             path: Path to the JSON file
    #             data: Data to write
    #             indent: JSON indentation

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #         """
    content = json.dumps(data, indent=indent)
            await self.write_file(path, content)

    #     async def list_files(
    #         self,
    #         directory: Union[str, Path],
    pattern: str = "*",
    recursive: bool = False,
    #     ) -List[Path]):
    #         """
    #         List files in a directory.

    #         Args:
    #             directory: Directory to list
    #             pattern: Glob pattern to match
    #             recursive: Whether to search recursively

    #         Returns:
    #             List of file paths

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #         """
    directory = Path(directory)

    #         if not self._check_permission(directory, PluginPermission.FILE_READ):
                raise PermissionError(f"No permission to list {directory}")

    #         if recursive:
    files = list(directory.rglob(pattern))
    #         else:
    files = list(directory.glob(pattern))

            # Filter to only include files (not directories)
    #         return [f for f in files if f.is_file()]

    #     async def exists(self, path: Union[str, Path]) -bool):
    #         """
    #         Check if a path exists.

    #         Args:
    #             path: Path to check

    #         Returns:
    #             True if path exists
    #         """
    path = Path(path)

    #         if not self._check_permission(path, PluginPermission.FILE_READ):
    #             return False

            return path.exists()

    #     async def mkdir(self, path: Union[str, Path], parents: bool = True) -None):
    #         """
    #         Create a directory.

    #         Args:
    #             path: Directory path to create
    #             parents: Whether to create parent directories

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #         """
    path = Path(path)

    #         if not self._check_permission(path, PluginPermission.FILE_WRITE):
                raise PermissionError(f"No permission to create directory {path}")

            await asyncio.get_event_loop().run_in_executor(
    None, lambda: path.mkdir(parents = parents, exist_ok=True)
    #         )


class ConfigurationAPI
    #     """
    #     Configuration API for plugins.

    #     Provides access to plugin configuration and settings.
    #     """

    #     def __init__(self, plugin_context: PluginContext):""
    #         Initialize the configuration API.

    #         Args:
    #             plugin_context: The plugin context
    #         """
    self.context = plugin_context
    self.logger = plugin_context.get_logger()
    self._config_file = self.context.data_dir / "config.json"
    self._config_cache: Optional[Dict[str, Any]] = None
    self._cache_time: Optional[float] = None
    #         self._cache_ttl = 5.0  # Cache for 5 seconds

    #     async def _load_config(self) -Dict[str, Any]):
    #         """Load configuration from file."""
    #         # Check cache
    now = time.time()
    #         if (
    #             self._config_cache is not None
    #             and self._cache_time is not None
    #             and now - self._cache_time < self._cache_ttl
    #         ):
    #             return self._config_cache

    #         # Load from file
    #         if self._config_file.exists():
    #             try:
    content = await asyncio.get_event_loop().run_in_executor(
    #                     None, self._config_file.read_text
    #                 )
    self._config_cache = json.loads(content)
                except (json.JSONDecodeError, IOError) as e:
                    self.logger.error(f"Failed to load config: {e}")
    self._config_cache = {}
    #         else:
    self._config_cache = {}

    self._cache_time = now
    #         return self._config_cache

    #     async def _save_config(self) -None):
    #         """Save configuration to file."""
    #         if self._config_cache is None:
    #             return

    content = json.dumps(self._config_cache, indent=2)
            await asyncio.get_event_loop().run_in_executor(
                None, lambda: self._config_file.write_text(content)
    #         )
    self._cache_time = time.time()

    #     async def get(self, key: str, default: Any = None) -Any):
    #         """
    #         Get a configuration value.

    #         Args:
                key: Configuration key (supports dot notation)
    #             default: Default value if key not found

    #         Returns:
    #             Configuration value
    #         """
    config = await self._load_config()

    #         # Handle dot notation
    keys = key.split(".")
    value = config

    #         for k in keys:
    #             if isinstance(value, dict) and k in value:
    value = value[k]
    #             else:
    #                 return default

    #         return value

    #     async def set(self, key: str, value: Any) -None):
    #         """
    #         Set a configuration value.

    #         Args:
                key: Configuration key (supports dot notation)
    #             value: Value to set
    #         """
    config = await self._load_config()

    #         # Handle dot notation
    keys = key.split(".")
    current = config

    #         for k in keys[:-1]:
    #             if k not in current:
    current[k] = {}
    current = current[k]

    current[keys[-1]] = value
            await self._save_config()

    #     async def delete(self, key: str) -bool):
    #         """
    #         Delete a configuration value.

    #         Args:
                key: Configuration key (supports dot notation)

    #         Returns:
    #             True if key was deleted, False if not found
    #         """
    config = await self._load_config()

    #         # Handle dot notation
    keys = key.split(".")
    current = config

    #         for k in keys[:-1]:
    #             if isinstance(current, dict) and k in current:
    current = current[k]
    #             else:
    #                 return False

    #         if keys[-1] in current:
    #             del current[keys[-1]]
                await self._save_config()
    #             return True

    #         return False

    #     async def get_all(self) -Dict[str, Any]):
    #         """
    #         Get all configuration values.

    #         Returns:
    #             All configuration data
    #         """
            return await self._load_config()

    #     async def clear(self) -None):
    #         """Clear all configuration."""
    self._config_cache = {}
            await self._save_config()


class UIService
    #     """
    #     UI service for plugins.

    #     Provides access to UI components and interactions.
    #     """

    #     def __init__(self, plugin_context: PluginContext):""
    #         Initialize the UI service.

    #         Args:
    #             plugin_context: The plugin context
    #         """
    self.context = plugin_context
    self.logger = plugin_context.get_logger()
    self._registered_components: Dict[str, Any] = {}
    self._registered_menus: List[Dict[str, Any]] = []
    self._registered_toolbars: List[Dict[str, Any]] = []
    self._registered_panels: Dict[str, Any] = {}

    #     def register_component(self, name: str, component: Any) -None):
    #         """
    #         Register a UI component.

    #         Args:
    #             name: Component name
    #             component: React component class
    #         """
    #         if not self.context.has_permission(PluginPermission.UI_ACCESS):
                raise PermissionError("Plugin lacks UI access permission")

    self._registered_components[name] = component
            self.logger.info(f"Registered UI component: {name}")

    #     def get_component(self, name: str) -Any):
    #         """
    #         Get a registered UI component.

    #         Args:
    #             name: Component name

    #         Returns:
    #             Component class or None if not found
    #         """
            return self._registered_components.get(name)

    #     def register_menu_item(self, menu_item: Dict[str, Any]) -None):
    #         """
    #         Register a menu item.

    #         Args:
    #             menu_item: Menu item definition
    #         """
    #         if not self.context.has_permission(PluginPermission.UI_ACCESS):
                raise PermissionError("Plugin lacks UI access permission")

    #         # Add plugin ID to menu item
    menu_item["plugin_id"] = self.context.plugin_id
            self._registered_menus.append(menu_item)

    #     def get_menu_items(self) -List[Dict[str, Any]]):
    #         """
    #         Get all registered menu items.

    #         Returns:
    #             List of menu item definitions
    #         """
            return self._registered_menus.copy()

    #     def register_toolbar_item(self, toolbar_item: Dict[str, Any]) -None):
    #         """
    #         Register a toolbar item.

    #         Args:
    #             toolbar_item: Toolbar item definition
    #         """
    #         if not self.context.has_permission(PluginPermission.UI_ACCESS):
                raise PermissionError("Plugin lacks UI access permission")

    #         # Add plugin ID to toolbar item
    toolbar_item["plugin_id"] = self.context.plugin_id
            self._registered_toolbars.append(toolbar_item)

    #     def get_toolbar_items(self) -List[Dict[str, Any]]):
    #         """
    #         Get all registered toolbar items.

    #         Returns:
    #             List of toolbar item definitions
    #         """
            return self._registered_toolbars.copy()

    #     def register_panel(self, panel_id: str, panel_config: Dict[str, Any]) -None):
    #         """
    #         Register a UI panel.

    #         Args:
    #             panel_id: Panel ID
    #             panel_config: Panel configuration
    #         """
    #         if not self.context.has_permission(PluginPermission.UI_ACCESS):
                raise PermissionError("Plugin lacks UI access permission")

    #         # Add plugin ID to panel config
    panel_config["plugin_id"] = self.context.plugin_id
    self._registered_panels[panel_id] = panel_config

    #     def get_panels(self) -Dict[str, Any]):
    #         """
    #         Get all registered panels.

    #         Returns:
    #             Dictionary of panel ID to configuration
    #         """
            return self._registered_panels.copy()

    #     async def show_notification(
    #         self,
    #         message: str,
    type: str = "info",
    duration: Optional[int] = None,
    #     ) -None):
    #         """
    #         Show a notification to the user.

    #         Args:
    #             message: Notification message
                type: Notification type (info, warning, error, success)
    #             duration: Duration in milliseconds (None for auto)
    #         """
    #         if not self.context.has_permission(PluginPermission.UI_ACCESS):
                raise PermissionError("Plugin lacks UI access permission")

            await self.context.event_bus.emit(
    #             "ui.notification",
    #             {
    #                 "message": message,
    #                 "type": type,
    #                 "duration": duration,
    #                 "plugin_id": self.context.plugin_id,
    #             },
    source = self.context.plugin_id,
    #         )

    #     async def show_dialog(self, dialog_config: Dict[str, Any]) -Any):
    #         """
    #         Show a dialog to the user.

    #         Args:
    #             dialog_config: Dialog configuration

    #         Returns:
    #             Dialog result
    #         """
    #         if not self.context.has_permission(PluginPermission.UI_ACCESS):
                raise PermissionError("Plugin lacks UI access permission")

    #         # This would integrate with the frontend dialog system
    #         # For now, just emit an event
            await self.context.event_bus.emit(
    #             "ui.dialog",
    #             {
    #                 "config": dialog_config,
    #                 "plugin_id": self.context.plugin_id,
                    "request_id": str(uuid.uuid4()),
    #             },
    source = self.context.plugin_id,
    #         )


class NetworkAPI
    #     """
    #     Network API for plugins.

    #     Provides controlled network access with permission checks.
    #     """

    #     def __init__(self, plugin_context: PluginContext):""
    #         Initialize the network API.

    #         Args:
    #             plugin_context: The plugin context
    #         """
    self.context = plugin_context
    self.logger = plugin_context.get_logger()
    self._allowed_domains = self._get_allowed_domains()

    #     def _get_allowed_domains(self) -List[str]):
    #         """Get the list of domains this plugin is allowed to access."""
    #         # This could be configured per plugin
    #         return [
    #             "api.github.com",
    #             "registry.npmjs.org",
    #             "pypi.org",
    #         ]

    #     async def http_request(
    #         self,
    #         method: str,
    #         url: str,
    headers: Optional[Dict[str, str]] = None,
    data: Optional[Union[str, Dict[str, Any]]] = None,
    timeout: float = 30.0,
    #     ) -Dict[str, Any]):
    #         """
    #         Make an HTTP request.

    #         Args:
    #             method: HTTP method
    #             url: Request URL
    #             headers: Request headers
    #             data: Request data
    #             timeout: Request timeout

    #         Returns:
    #             Response data

    #         Raises:
    #             PermissionError: If plugin lacks permission
    #         """
    #         if not self.context.has_permission(PluginPermission.NETWORK_ACCESS):
                raise PermissionError("Plugin lacks network access permission")

    #         # Check domain restrictions
    #         from urllib.parse import urlparse
    parsed = urlparse(url)
    #         if parsed.netloc not in self._allowed_domains:
                raise PermissionError(f"Domain {parsed.netloc} not allowed")

    #         # Make request using aiohttp or similar
    #         # This is a placeholder implementation
            self.logger.info(f"Making {method} request to {url}")

    #         # Return mock response for now
    #         return {
    #             "status": 200,
    #             "headers": {},
    #             "body": "",
    #         }


class PluginAPI
    #     """
    #     Main plugin API that provides access to all services.

    #     This is the primary interface that plugins use to interact with the IDE.
    #     """

    #     def __init__(self, plugin_context: PluginContext):""
    #         Initialize the plugin API.

    #         Args:
    #             plugin_context: The plugin context
    #         """
    self.context = plugin_context
    self.logger = plugin_context.get_logger()

    #         # Initialize service APIs
    self.filesystem = FileSystemAPI(plugin_context)
    self.config = ConfigurationAPI(plugin_context)
    self.ui = UIService(plugin_context)
    self.network = NetworkAPI(plugin_context)

    #         # Store reference to event bus
    self.event_bus = plugin_context.event_bus

    #     async def emit_event(
    #         self,
    #         event_type: str,
    data: Any = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -None):
    #         """
    #         Emit an event to the event bus.

    #         Args:
    #             event_type: Type of event
    #             data: Event data
    #             metadata: Event metadata
    #         """
    #         if not self.context.has_permission(PluginPermission.EVENT_PUBLISH):
                raise PermissionError("Plugin lacks event publish permission")

            await self.event_bus.emit(
    #             event_type,
    data = data,
    source = self.context.plugin_id,
    metadata = metadata,
    #         )

    #     def subscribe_to_event(
    #         self,
    #         event_type: str,
    #         callback: Callable,
    priority: int = 1,
    #     ) -str):
    #         """
    #         Subscribe to an event.

    #         Args:
    #             event_type: Type of event to subscribe to
    #             callback: Callback function
    #             priority: Event priority

    #         Returns:
    #             Handler ID
    #         """
    #         if not self.context.has_permission(PluginPermission.EVENT_SUBSCRIBE):
                raise PermissionError("Plugin lacks event subscribe permission")

            return self.event_bus.on(
    #             event_type,
    #             callback,
    priority = priority,
    plugin_id = self.context.plugin_id,
    #         )

    #     def unsubscribe_from_event(self, handler_id: str) -None):
    #         """
    #         Unsubscribe from an event.

    #         Args:
    #             handler_id: Handler ID returned by subscribe_to_event
    #         """
            self.event_bus.off(handler_id)

    #     def get_plugin_info(self, plugin_id: Optional[str] = None) -Optional[Dict[str, Any]]):
    #         """
    #         Get information about a plugin.

    #         Args:
    #             plugin_id: Plugin ID (None for self)

    #         Returns:
    #             Plugin information or None
    #         """
    #         if plugin_id is None:
    plugin_id = self.context.plugin_id

            return self.context.plugin_manager.get_plugin_info(plugin_id)

    #     def get_loaded_plugins(self) -List[Dict[str, Any]]):
    #         """
    #         Get information about all loaded plugins.

    #         Returns:
    #             List of plugin information
    #         """
            return self.context.plugin_manager.get_loaded_plugins()

    #     async def call_plugin_method(
    #         self,
    #         plugin_id: str,
    #         method_name: str,
    args: List[Any] = None,
    kwargs: Dict[str, Any] = None,
    #     ) -Any):
    #         """
    #         Call a method on another plugin.

    #         Args:
    #             plugin_id: Target plugin ID
    #             method_name: Method name
    #             args: Method arguments
    #             kwargs: Method keyword arguments

    #         Returns:
    #             Method result

    #         Raises:
    #             AttributeError: If method doesn't exist
    #             PermissionError: If plugin is not accessible
    #         """
    #         # This would implement secure inter-plugin communication
    #         # For now, just emit an event
            await self.emit_event(
    #             "plugin.method_call",
    #             {
    #                 "target_plugin": plugin_id,
    #                 "method": method_name,
    #                 "args": args or [],
    #                 "kwargs": kwargs or {},
    #             },
    #         )

    #     def get_logger(self, name: Optional[str] = None) -logging.Logger):
    #         """
    #         Get a logger for the plugin.

    #         Args:
    #             name: Logger name (None for default)

    #         Returns:
    #             Logger instance
    #         """
    #         if name:
                return logging.getLogger(f"plugin.{self.context.plugin_id}.{name}")
            return self.context.get_logger()

    #     async def get_performance_stats(self) -Dict[str, Any]):
    #         """
    #         Get performance statistics for the plugin.

    #         Returns:
    #             Performance statistics
    #         """
    #         return {
                "uptime": self.context.plugin.get_uptime(),
                "memory_usage": self._get_memory_usage(),
                "event_stats": self.event_bus.get_event_stats(),
    #         }

    #     def _get_memory_usage(self) -Dict[str, Any]):
    #         """Get memory usage statistics."""
    #         import psutil
    #         import os

    process = psutil.Process(os.getpid())
    memory_info = process.memory_info()

    #         return {
    #             "rss": memory_info.rss,
    #             "vms": memory_info.vms,
                "percent": process.memory_percent(),
    #         }