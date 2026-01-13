# Converted from Python to NoodleCore
# Original file: src

# """
# Enhanced Plugin Manager for Noodle IDE

# This module provides the core plugin management functionality,
# including loading, unloading, dependency resolution, and lifecycle
# management of plugins with hot-reload capabilities.
# """

import asyncio
import importlib
import importlib.util
import inspect
import json
import logging
import os
import sys
import time
import traceback
import concurrent.futures.ThreadPoolExecutor
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any
import uuid
import weakref
import threading

import .interfaces.(
#     Plugin,
#     PluginContext,
#     PluginState,
#     PluginType,
#     PluginMetadata,
#     PluginPermission,
#     InitializationResult,
#     StartResult,
#     StopResult,
#     DestroyResult,
# )
import .event_bus.EventBus
import .plugin_api.PluginAPI
import .sandbox.SandboxManager
import .hot_reload.HotReloadManager


class LoadError(Enum)
    #     """Types of plugin loading errors."""
    NOT_FOUND = "plugin_not_found"
    INVALID_FORMAT = "invalid_format"
    DEPENDENCY_MISSING = "dependency_missing"
    INITIALIZATION_FAILED = "initialization_failed"
    ALREADY_LOADED = "already_loaded"
    PERMISSION_DENIED = "permission_denied"
    SANDBOX_VIOLATION = "sandbox_violation"
    VERSION_INCOMPATIBLE = "version_incompatible"


dataclass
class PluginError
    #     """Represents a plugin loading or runtime error."""

    #     plugin_id: str
    #     error_type: LoadError
    #     message: str
    stack_trace: Optional[str] = None
    timestamp: float = field(default_factory=time.time)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))


dataclass
class PluginPackage
    #     """Represents a plugin package with its manifest and files."""

    #     id: str
    #     name: str
    #     version: str
    #     description: str
    #     author: str
    #     plugin_type: PluginType
    #     entry_file: str
    #     dependencies: List[str]
    #     permissions: List[PluginPermission]
    #     files: Dict[str, Path]
    config: Dict[str, Any] = field(default_factory=dict)
    path: Path = field(default_factory=Path)
    is_loaded: bool = False
    load_error: Optional[PluginError] = None
    metadata: Optional[PluginMetadata] = None


dataclass
class PluginInfo
    #     """Information about a plugin."""

    #     id: str
    #     name: str
    #     version: str
    #     description: str
    #     author: str
    #     plugin_type: PluginType
    #     dependencies: List[str]
    #     permissions: List[PluginPermission]
    #     path: Path
    #     state: PluginState
    #     load_time: Optional[float]
    #     config: Dict[str, Any]
    error: Optional[str] = None
    uptime: Optional[float] = None
    resource_usage: Optional[Dict[str, Any]] = None


class PluginManager
    #     """
    #     Manages the lifecycle and dependencies of plugins.

    #     This class is responsible for loading, initializing, starting, stopping,
    #     and unloading plugins. It also handles dependency resolution and
    #     provides plugin information and error handling.
    #     """

    #     def __init__(
    #         self,
    #         event_bus: EventBus,
    plugin_dirs: List[Path] = None,
    max_concurrent_loads: int = 4,
    enable_hot_reload: bool = True,
    enable_sandbox: bool = True,
    #     ):""
    #         Initialize the plugin manager.

    #         Args:
    #             event_bus: Event bus instance
    #             plugin_dirs: List of directories to scan for plugins
    #             max_concurrent_loads: Maximum number of concurrent plugin loads
    #             enable_hot_reload: Enable hot-reload functionality
    #             enable_sandbox: Enable plugin sandboxing
    #         """
    self.event_bus = event_bus
    self.plugin_dirs = plugin_dirs or []
    self.max_concurrent_loads = max_concurrent_loads
    self.enable_hot_reload = enable_hot_reload
    self.enable_sandbox = enable_sandbox

    #         # Plugin storage
    self._packages: Dict[str, PluginPackage] = {}
    self._instances: Dict[str, Plugin] = {}
    self._contexts: Dict[str, PluginContext] = {}
    self._apis: Dict[str, PluginAPI] = {}
    self._dependency_graph: Dict[str, Set[str]] = {}
    self._reverse_deps: Dict[str, Set[str]] = {}

    #         # State tracking
    self._state: Dict[str, PluginState] = {}
    self._load_times: Dict[str, float] = {}
    self._start_times: Dict[str, float] = {}

    #         # Thread pool for plugin operations
    self._executor = ThreadPoolExecutor(max_workers=max_concurrent_loads)

    #         # Error handling
    self._load_results: Dict[str, PluginError] = {}
    self._logger = logging.getLogger(__name__)

    #         # Plugin path tracking
    self._original_sys_path = list(sys.path)

    #         # Sandbox manager
    #         self._sandbox_manager = SandboxManager() if enable_sandbox else None

    #         # Hot reload manager
    self._hot_reload_manager = None
    #         if enable_hot_reload:
    self._hot_reload_manager = HotReloadManager(
    #                 self, event_bus, self._logger
    #             )

    #         # Performance tracking
    self._performance_stats: Dict[str, Dict[str, Any]] = defaultdict(
    #             lambda: {
    #                 "load_time": 0.0,
    #                 "init_time": 0.0,
    #                 "start_time": 0.0,
    #                 "stop_time": 0.0,
    #                 "destroy_time": 0.0,
    #                 "total_reloads": 0,
    #                 "total_errors": 0,
    #             }
    #         )

    #         # Configuration
    self._config: Dict[str, Any] = {}

    #     def set_config(self, config: Dict[str, Any]) -None):
    #         """
    #         Set plugin manager configuration.

    #         Args:
    #             config: Configuration dictionary
    #         """
    self._config = config

    #         # Update sandbox configuration if provided
    #         if self._sandbox_manager and "sandbox" in config:
    #             from .sandbox import SandboxConfig
    sandbox_config = SandboxConfig(**config["sandbox"])
                self._sandbox_manager.set_default_config(sandbox_config)

    #         # Update hot reload configuration if provided
    #         if self._hot_reload_manager and "hot_reload" in config:
    hot_reload_config = config["hot_reload"]
    #             if hot_reload_config.get("enabled", True):
                    self._hot_reload_manager.enable(
    poll_interval = hot_reload_config.get("poll_interval", 1.0),
    use_polling = hot_reload_config.get("use_polling", False),
    #                 )

    #     async def initialize(self) -None):
    #         """Initialize the plugin manager."""
            self._logger.info("Initializing plugin manager")

    #         # Start event bus if not already started
            await self.event_bus.start()

    #         # Start hot reload if enabled
    #         if self._hot_reload_manager:
                self._hot_reload_manager.enable()

    #         # Scan for plugins
            await self.scan_for_plugins()

            self._logger.info("Plugin manager initialized")

    #     async def shutdown(self) -None):
    #         """Shutdown the plugin manager and all plugins."""
            self._logger.info("Shutting down plugin manager")

    #         # Stop hot reload
    #         if self._hot_reload_manager:
                self._hot_reload_manager.disable()

    #         # Stop all running plugins
    #         for plugin_id in list(self._instances.keys()):
                await self.stop_plugin(plugin_id)
                await self.unload_plugin(plugin_id)

    #         # Shutdown sandbox manager
    #         if self._sandbox_manager:
                await self._sandbox_manager.shutdown()

    #         # Shutdown thread pool
    self._executor.shutdown(wait = True)

    #         # Restore original sys.path
    sys.path = self._original_sys_path

    #         # Stop event bus
            await self.event_bus.stop()

            self._logger.info("Plugin manager shutdown complete")

    #     def add_plugin_directory(self, directory: Path) -None):
    #         """Add a directory to scan for plugins."""
    #         if directory.exists() and directory not in self.plugin_dirs:
                self.plugin_dirs.append(directory)
                asyncio.create_task(self._scan_directory_for_plugins(directory))

    #     async def scan_for_plugins(self) -None):
    #         """Scan all plugin directories for new plugins."""
    #         for directory in self.plugin_dirs:
                await self._scan_directory_for_plugins(directory)

    #     async def _scan_directory_for_plugins(self, directory: Path) -None):
    #         """Scan a single directory for plugins."""
    #         if not directory.exists() or not directory.is_dir():
    #             return

    #         self._logger.info(f"Scanning for plugins in {directory}")

    #         for item in directory.iterdir():
    #             if item.is_dir() and not item.name.startswith("."):
    #                 # Check if this is a plugin directory
    plugin_package = await self._detect_plugin_directory(item)
    #                 if plugin_package:
    self._packages[plugin_package.id] = plugin_package
                        self._logger.debug(
                            f"Found plugin: {plugin_package.name} ({plugin_package.id})"
    #                     )

    #     async def _detect_plugin_directory(self, directory: Path) -Optional[PluginPackage]):
    #         """
    #         Detect if a directory contains a plugin and create a package.

    #         Args:
    #             directory: Directory to check

    #         Returns:
    #             PluginPackage if detected, None otherwise
    #         """
    #         # Check for manifest file
    manifest_path = directory / "plugin.json"
    manifest = None

    #         if manifest_path.exists():
    #             try:
    #                 with manifest_path.open("r", encoding="utf-8") as f:
    manifest = json.load(f)
    #             except Exception as e:
                    self._logger.warning(f"Failed to load manifest {manifest_path}: {e}")

    #         # Find plugin entry point
    entry_file = None
    #         for entry_type in ["plugin.py", "main.py", "index.py"]:
    possible_entry = math.divide(directory, entry_type)
    #             if possible_entry.exists():
    entry_file = entry_type
    #                 break

    #         if not entry_file and manifest:
    entry_file = manifest.get("entry_point", "plugin.py")
    #             if (directory / entry_file).exists():
    #                 pass  # Found entry point in manifest
    #             else:
    entry_file = None

    #         if not entry_file:
    #             return None

    #         # Create plugin metadata
    #         if manifest:
    plugin_id = manifest.get("id", directory.name)
    name = manifest.get("name", directory.name)
    version = manifest.get("version", "0.0.1")
    description = manifest.get("description", "")
    author = manifest.get("author", "Unknown")
    plugin_type_str = manifest.get("type", "service")
    dependencies = manifest.get("dependencies", [])
    permissions = [
    #                 PluginPermission(p) for p in manifest.get("permissions", [])
    #             ]

    #             # Convert plugin type string to enum
    #             try:
    plugin_type = PluginType(plugin_type_str)
    #             except ValueError:
    plugin_type = PluginType.SERVICE

    #             # Create metadata object
    metadata = PluginMetadata(
    id = plugin_id,
    name = name,
    version = version,
    description = description,
    author = author,
    plugin_type = plugin_type,
    dependencies = dependencies,
    entry_point = entry_file,
    permissions = permissions,
    min_noodle_version = manifest.get("min_noodle_version", "1.0.0"),
    max_noodle_version = manifest.get("max_noodle_version"),
    homepage = manifest.get("homepage"),
    repository = manifest.get("repository"),
    license = manifest.get("license"),
    keywords = manifest.get("keywords", []),
    tags = manifest.get("tags", []),
    icon = manifest.get("icon"),
    screenshots = manifest.get("screenshots", []),
    configuration_schema = manifest.get("configuration_schema"),
    #             )
    #         else:
    #             # Auto-detect plugin info
    plugin_id = directory.name
    name = directory.name
    version = "0.0.1"
    description = ""
    author = "Unknown"
    plugin_type = PluginType.SERVICE
    dependencies = []
    permissions = []

    metadata = PluginMetadata(
    id = plugin_id,
    name = name,
    version = version,
    description = description,
    author = author,
    plugin_type = plugin_type,
    dependencies = dependencies,
    entry_point = entry_file,
    permissions = permissions,
    #             )

    #         # Load all plugin files
    files = {}
    #         for file_path in directory.rglob("*"):
    #             if file_path.is_file() and not file_path.name.startswith("."):
    files[file_path.relative_to(directory).as_posix()] = file_path

    plugin_package = PluginPackage(
    id = plugin_id,
    name = name,
    version = version,
    description = description,
    author = author,
    plugin_type = plugin_type,
    entry_file = entry_file,
    dependencies = dependencies,
    permissions = permissions,
    files = files,
    path = directory,
    config = manifest or {},
    metadata = metadata,
    #         )

    #         return plugin_package

    #     async def load_plugin(self, plugin_id: str) -bool):
    #         """
    #         Load a plugin by its ID.

    #         Args:
    #             plugin_id: ID of plugin to load

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if plugin_id in self._instances:
                self._logger.warning(f"Plugin {plugin_id} is already loaded")
    #             return True

    #         # Check if the plugin exists
    #         if plugin_id not in self._packages:
    error = PluginError(
    plugin_id = plugin_id,
    error_type = LoadError.NOT_FOUND,
    message = f"Plugin {plugin_id} not found",
    #             )
    self._load_results[plugin_id] = error
                self._logger.error(f"Plugin {plugin_id} not found")
    #             return False

    package = self._packages[plugin_id]
    start_time = time.time()

    #         try:
    #             # Update state
    self._state[plugin_id] = PluginState.LOADING

    #             # Check dependencies
    missing_deps = await self._check_dependencies(plugin_id)
    #             if missing_deps:
    error = PluginError(
    plugin_id = plugin_id,
    error_type = LoadError.DEPENDENCY_MISSING,
    message = f"Missing dependencies: {', '.join(missing_deps)}",
    #                 )
    self._load_results[plugin_id] = error
    self._state[plugin_id] = PluginState.ERROR
                    self._logger.error(f"Plugin {plugin_id} has missing dependencies")
    #                 return False

    #             # Load the plugin module
    module = await self._load_plugin_module(package, plugin_id)

    #             # Create plugin instance
    plugin_instance = await self._create_plugin_instance(module, plugin_id)

    #             # Create plugin context
    context = await self._create_plugin_context(plugin_id)

    #             # Create plugin API
    api = PluginAPI(context)

    #             # Store instances
    self._instances[plugin_id] = plugin_instance
    self._contexts[plugin_id] = context
    self._apis[plugin_id] = api

    #             # Set plugin context
    plugin_instance.context = context

    #             # Initialize plugin
    self._state[plugin_id] = PluginState.INITIALIZING
    init_start = time.time()
    init_result = await plugin_instance.initialize(context)
    init_time = time.time() - init_start

    #             if not init_result.success:
    error = PluginError(
    plugin_id = plugin_id,
    error_type = LoadError.INITIALIZATION_FAILED,
    message = init_result.error or "Plugin initialization failed",
    #                 )
    self._load_results[plugin_id] = error
    self._state[plugin_id] = PluginState.ERROR
                    self._logger.error(f"Plugin {plugin_id} initialization failed")
    #                 return False

    #             # Update state and timing
    self._state[plugin_id] = PluginState.INITIALIZED
    self._load_times[plugin_id] = time.time()
    load_time = self._load_times[plugin_id] - start_time

    #             # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["load_time"] = load_time
    stats["init_time"] = init_time

    #             # Update package
    package.is_loaded = True

                self._logger.info(f"Plugin {plugin_id} loaded successfully in {load_time:.3f}s")

    #             # Emit plugin loaded event
                await self.event_bus.emit(
    #                 "plugin.loaded",
    #                 {
    #                     "plugin_id": plugin_id,
                        "plugin_info": self.get_plugin_info(plugin_id),
    #                     "load_time": load_time,
    #                 },
    source = "plugin_manager",
    #             )

    #             return True

    #         except Exception as e:
    stack_trace = traceback.format_exc()
    error = PluginError(
    plugin_id = plugin_id,
    error_type = LoadError.INVALID_FORMAT,
    message = str(e),
    stack_trace = stack_trace,
    #             )
    self._load_results[plugin_id] = error
    self._state[plugin_id] = PluginState.ERROR

    #             # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["total_errors"] + = 1

                self._logger.error(f"Failed to load plugin {plugin_id}: {e}")
    #             return False

    #     async def _load_plugin_module(self, package: PluginPackage, plugin_id: str):
    #         """Load the plugin module from package."""
    #         # Add plugin path to sys.path temporarily
            sys.path.insert(0, str(package.path))

    #         try:
    #             # Load entry file
    entry_path = math.divide(package.path, package.entry_file)

    #             # Create module spec
    module_name = plugin_id.replace("-", "_")
    spec = importlib.util.spec_from_file_location(module_name, entry_path)
    #             if spec is None or spec.loader is None:
    #                 raise ImportError(f"Could not create module spec for {plugin_id}")

    #             # Create and execute module
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module

    #             # Execute in sandbox if enabled
    #             if self._sandbox_manager:
    sandbox = self._sandbox_manager.get_sandbox(plugin_id)
                    await sandbox.execute_function(spec.loader.exec_module, module)
    #             else:
                    spec.loader.exec_module(module)

    #             return module

    #         finally:
    #             # Remove plugin path from sys.path
    #             if str(package.path) in sys.path:
                    sys.path.remove(str(package.path))

    #     async def _create_plugin_instance(self, module, plugin_id: str) -Plugin):
    #         """Create a plugin instance from the loaded module."""
    #         # Look for plugin class in module
    #         plugin_class = None

    #         # Check common plugin class names
    #         for class_name in ["Plugin", f"{plugin_id.replace('-', '_').capitalize()}Plugin", "Main"]:
    #             if hasattr(module, class_name):
    #                 plugin_class = getattr(module, class_name)
    #                 if inspect.isclass(plugin_class) and issubclass(plugin_class, Plugin):
    #                     break

    #         if plugin_class is None:
    #             # If no specific class found, create a generic plugin instance
    #             # This would need to be implemented based on the plugin type
    #             raise ValueError(f"No valid plugin class found in module for {plugin_id}")

    #         # Create plugin instance
    #         try:
    #             # Try to get metadata from module
    #             if hasattr(module, "PLUGIN_METADATA"):
    metadata = module.PLUGIN_METADATA
    #             else:
    metadata = self._packages[plugin_id].metadata

    plugin_instance = plugin_class(metadata)

    #         except Exception as e:
    #             # Fallback creation
    metadata = self._packages[plugin_id].metadata
    plugin_instance = plugin_class(metadata)

    #         return plugin_instance

    #     async def _create_plugin_context(self, plugin_id: str) -PluginContext):
    #         """Create a context for plugin initialization."""
    package = self._packages[plugin_id]

    #         # Create data directory if it doesn't exist
    data_dir = Path(f"./data/plugins/{plugin_id}")
    data_dir.mkdir(parents = True, exist_ok=True)

    context = PluginContext(
    plugin_id = plugin_id,
    plugin_manager = self,
    event_bus = self.event_bus,
    config_manager = self,  # This would be the actual config manager
    plugin_api = None,  # Will be set after API is created
    plugin_dir = package.path,
    data_dir = data_dir,
    #         )

    #         # Set permissions
            context.set_permissions(package.permissions)

    #         return context

    #     async def _check_dependencies(self, plugin_id: str) -List[str]):
    #         """Check if plugin dependencies are satisfied."""
    #         if plugin_id not in self._packages:
    #             return []

    plugin = self._packages[plugin_id]
    missing_deps = []

    #         for dep in plugin.dependencies:
    #             if dep not in self._instances:
                    missing_deps.append(dep)

    #         return missing_deps

    #     async def start_plugin(self, plugin_id: str) -bool):
    #         """
    #         Start a plugin that has been loaded and initialized.

    #         Args:
    #             plugin_id: ID of plugin to start

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if plugin_id not in self._instances:
                self._logger.error(f"Plugin {plugin_id} not loaded")
    #             return False

    #         if self._state[plugin_id] == PluginState.STARTED:
                self._logger.warning(f"Plugin {plugin_id} is already started")
    #             return True

    #         try:
    plugin = self._instances[plugin_id]
    self._state[plugin_id] = PluginState.STARTING

    start_time = time.time()
    result = await plugin.start()
    start_duration = time.time() - start_time

    #             if result.success:
    self._state[plugin_id] = PluginState.STARTED
    self._start_times[plugin_id] = time.time()

    #                 # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["start_time"] = start_duration

                    self._logger.info(f"Plugin {plugin_id} started successfully in {start_duration:.3f}s")

    #                 # Emit plugin started event
                    await self.event_bus.emit(
    #                     "plugin.started",
    #                     {
    #                         "plugin_id": plugin_id,
                            "plugin_info": self.get_plugin_info(plugin_id),
    #                         "start_time": start_duration,
    #                     },
    source = "plugin_manager",
    #                 )

    #                 return True
    #             else:
    self._state[plugin_id] = PluginState.ERROR
                    self._logger.error(f"Plugin {plugin_id} failed to start: {result.error}")
    #                 return False

    #         except Exception as e:
    self._state[plugin_id] = PluginState.ERROR
                self._logger.error(f"Failed to start plugin {plugin_id}: {e}")

    #             # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["total_errors"] + = 1

    #             return False

    #     async def stop_plugin(self, plugin_id: str) -bool):
    #         """
    #         Stop a plugin that is currently running.

    #         Args:
    #             plugin_id: ID of plugin to stop

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if plugin_id not in self._instances:
                self._logger.error(f"Plugin {plugin_id} not loaded")
    #             return False

    #         if self._state[plugin_id] not in [PluginState.STARTED, PluginState.ERROR]:
    #             return True  # Already stopped

    #         try:
    plugin = self._instances[plugin_id]
    self._state[plugin_id] = PluginState.STOPPING

    stop_time = time.time()
    result = await plugin.stop()
    stop_duration = time.time() - stop_time

    #             if result.success:
    self._state[plugin_id] = PluginState.STOPPED

    #                 # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["stop_time"] = stop_duration

                    self._logger.info(f"Plugin {plugin_id} stopped successfully in {stop_duration:.3f}s")

    #                 # Emit plugin stopped event
                    await self.event_bus.emit(
    #                     "plugin.stopped",
    #                     {
    #                         "plugin_id": plugin_id,
                            "plugin_info": self.get_plugin_info(plugin_id),
    #                         "stop_time": stop_duration,
    #                     },
    source = "plugin_manager",
    #                 )

    #                 return True
    #             else:
    self._state[plugin_id] = PluginState.ERROR
                    self._logger.error(f"Plugin {plugin_id} failed to stop: {result.error}")
    #                 return False

    #         except Exception as e:
    self._state[plugin_id] = PluginState.ERROR
                self._logger.error(f"Failed to stop plugin {plugin_id}: {e}")
    #             return False

    #     async def unload_plugin(self, plugin_id: str) -bool):
    #         """
    #         Unload a plugin and remove it from memory.

    #         Args:
    #             plugin_id: ID of plugin to unload

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if plugin_id not in self._instances:
    #             return False

    #         # Check if other plugins depend on this one
    dependent_plugins = await self._get_dependent_plugins(plugin_id)
    #         if dependent_plugins:
                self._logger.warning(
                    f"Cannot unload plugin {plugin_id}: other plugins depend on it: {', '.join(dependent_plugins)}"
    #             )
    #             return False

    #         try:
    #             # Stop plugin if it's running
    #             if self._state[plugin_id] == PluginState.STARTED:
                    await self.stop_plugin(plugin_id)

    #             # Destroy plugin
    plugin = self._instances[plugin_id]
    destroy_time = time.time()
    destroy_result = await plugin.destroy()
    destroy_duration = time.time() - destroy_time

    #             if not destroy_result.success:
                    self._logger.error(
    #                     f"Failed to destroy plugin {plugin_id}: {destroy_result.error}"
    #                 )

    #             # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["destroy_time"] = destroy_duration

    #             # Remove from instances
    #             del self._instances[plugin_id]
    #             if plugin_id in self._contexts:
    #                 del self._contexts[plugin_id]
    #             if plugin_id in self._apis:
    #                 del self._apis[plugin_id]
    #             if plugin_id in self._state:
    #                 del self._state[plugin_id]

    #             # Reset package loaded state
    #             if plugin_id in self._packages:
    self._packages[plugin_id].is_loaded = False

    #             # Remove sandbox
    #             if self._sandbox_manager:
                    await self._sandbox_manager.remove_sandbox(plugin_id)

    #             # Emit plugin unloaded event
                await self.event_bus.emit(
    #                 "plugin.unloaded",
    #                 {
    #                     "plugin_id": plugin_id,
                        "plugin_info": self.get_plugin_info(plugin_id),
    #                     "destroy_time": destroy_duration,
    #                 },
    source = "plugin_manager",
    #             )

                self._logger.info(f"Plugin {plugin_id} unloaded successfully")
    #             return True

    #         except Exception as e:
                self._logger.error(f"Failed to unload plugin {plugin_id}: {e}")
    #             return False

    #     async def _get_dependent_plugins(self, plugin_id: str) -List[str]):
    #         """Get all plugins that depend on the given plugin."""
    dependents = []

    #         for other_plugin_id, deps in self._dependency_graph.items():
    #             if plugin_id in deps and other_plugin_id in self._instances:
                    dependents.append(other_plugin_id)

    #         return dependents

    #     async def reload_plugin(self, plugin_id: str) -bool):
    #         """
    #         Reload a plugin by unloading and loading it again.

    #         Args:
    #             plugin_id: ID of plugin to reload

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if plugin_id not in self._instances:
    #             # Not loaded, just load it
                return await self.load_plugin(plugin_id)

    #         # Get current state
    current_state = self._state[plugin_id]
    was_started = current_state == PluginState.STARTED

    #         # Unload the plugin
    #         if not await self.unload_plugin(plugin_id):
    #             return False

    #         # Load the plugin again
    #         if not await self.load_plugin(plugin_id):
    #             return False

    #         # Update performance stats
    stats = self._performance_stats[plugin_id]
    stats["total_reloads"] + = 1

    #         # If plugin was started before, start it again
    #         if was_started:
                return await self.start_plugin(plugin_id)

    #         return True

    #     def get_plugin_info(self, plugin_id: str) -Optional[PluginInfo]):
    #         """
    #         Get information about a plugin.

    #         Args:
    #             plugin_id: ID of plugin

    #         Returns:
    #             PluginInfo if plugin exists, None otherwise
    #         """
    #         if plugin_id not in self._packages:
    #             return None

    package = self._packages[plugin_id]
    state = self._state.get(plugin_id, PluginState.UNLOADED)
    load_time = self._load_times.get(plugin_id)
    error = self._load_results.get(plugin_id)

    #         # Calculate uptime if plugin is started
    uptime = None
    #         if state == PluginState.STARTED and plugin_id in self._start_times:
    uptime = time.time() - self._start_times[plugin_id]

    #         # Get resource usage if sandbox is enabled
    resource_usage = None
    #         if self._sandbox_manager:
    usage = self._sandbox_manager.get_sandbox(plugin_id).get_resource_usage()
    resource_usage = {
    #                 "cpu_time": usage.cpu_time,
    #                 "memory_usage": usage.memory_usage,
    #                 "file_descriptors": usage.file_descriptors,
    #                 "network_connections": usage.network_connections,
    #             }

            return PluginInfo(
    id = plugin_id,
    name = package.name,
    version = package.version,
    description = package.description,
    author = package.author,
    plugin_type = package.plugin_type,
    dependencies = package.dependencies,
    permissions = package.permissions,
    path = package.path,
    state = state,
    load_time = load_time,
    config = package.config,
    #             error=error.message if error else None,
    uptime = uptime,
    resource_usage = resource_usage,
    #         )

    #     def get_all_plugins(self) -List[PluginInfo]):
    #         """Get information about all plugins."""
    plugins = []

    #         for plugin_id in self._packages:
    plugin_info = self.get_plugin_info(plugin_id)
    #             if plugin_info:
                    plugins.append(plugin_info)

    #         return plugins

    #     def get_loaded_plugins(self) -List[PluginInfo]):
    #         """Get information about loaded plugins."""
    plugins = []

    #         for plugin_id in self._instances:
    plugin_info = self.get_plugin_info(plugin_id)
    #             if plugin_info:
                    plugins.append(plugin_info)

    #         return plugins

    #     def get_plugin_state(self, plugin_id: str) -Optional[PluginState]):
    #         """Get the current state of a plugin."""
            return self._state.get(plugin_id)

    #     def get_performance_stats(self) -Dict[str, Dict[str, Any]]):
    #         """Get performance statistics for all plugins."""
            return dict(self._performance_stats)

    #     def get_plugin_api(self, plugin_id: str) -Optional[PluginAPI]):
    #         """Get the API for a specific plugin."""
            return self._apis.get(plugin_id)

        # Configuration manager interface (placeholder)
    #     async def get_config(self, key: str, default: Any = None) -Any):
    #         """Get a configuration value."""
            return self._config.get(key, default)

    #     async def set_config(self, key: str, value: Any) -None):
    #         """Set a configuration value."""
    self._config[key] = value