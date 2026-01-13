# Converted from Python to NoodleCore
# Original file: src

# """
# Hot reload system for the Noodle-IDE plugin architecture.

# This module provides functionality to automatically reload plugins
# when their source code changes, enabling rapid development and
# testing of plugins without restarting the IDE.
# """

import asyncio
import hashlib
import importlib
import importlib.util
import logging
import os
import sys
import threading
import time
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any
import uuid
import weakref

try
    #     from watchdog.events import FileSystemEventHandler
    #     from watchdog.observers import Observer

    WATCHDOG_AVAILABLE = True
except ImportError
    WATCHDOG_AVAILABLE = False

    #     # Create dummy classes for when watchdog is not available
    #     class Observer:
    #         def __init__(self):
    #             pass

    #         def schedule(self, event_handler, path, recursive=False):
    #             pass

    #         def start(self):
    #             pass

    #         def stop(self):
    #             pass

    #         def join(self):
    #             pass

    #     class FileSystemEventHandler:
    #         def on_any_event(self, event):
    #             pass


class ReloadEvent(Enum)
    #     """Types of hot reload events."""

    FILE_CHANGED = "file_changed"
    PLUGIN_RELOADED = "plugin_reloaded"
    PLUGIN_FAILED = "plugin_failed"
    RELOAD_STARTED = "reload_started"
    RELOAD_COMPLETED = "reload_completed"


dataclass
class ReloadEventInfo
    #     """Information about a hot reload event."""

    #     event_type: ReloadEvent
    #     plugin_id: str
    file_path: Optional[str] = None
    error_message: Optional[str] = None
    timestamp: float = field(default_factory=time.time)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class ReloadState
    #     """State information for a plugin reload."""

    #     plugin_id: str
    #     original_state: str
    #     was_started: bool
    preserved_data: Dict[str, Any] = field(default_factory=dict)
    reload_start_time: float = field(default_factory=time.time)
    reload_end_time: Optional[float] = None
    success: bool = False
    error_message: Optional[str] = None


class PluginFileWatcher(FileSystemEventHandler)
    #     """Watches plugin files for changes."""

    #     def __init__(
    #         self,
    #         plugin_manager,
    #         callback: Callable[[ReloadEventInfo], None],
    ignore_patterns: List[str] = None,
    debounce_time: float = 1.0,
    #     ):""
    #         Initialize the file watcher.

    #         Args:
    #             plugin_manager: Plugin manager instance
    #             callback: Function to call when files change
    #             ignore_patterns: Patterns of files to ignore
    #             debounce_time: Time to wait before triggering reload
    #         """
    self.plugin_manager = plugin_manager
    self.callback = callback
    self.ignore_patterns = ignore_patterns or [
    #             "*.pyc",
    #             "__pycache__",
    #             ".git",
    #             ".idea",
    #             "*.log",
    #             "*.tmp",
    #             "node_modules",
    #             ".vscode",
    #         ]
    self.debounce_time = debounce_time
    self._pending_events: Dict[str, Dict[str, Any]] = {}
    self._debounce_timers: Dict[str, threading.Timer] = {}
    self._lock = threading.Lock()

    #     def on_modified(self, event):
    #         """Handle file modification events."""
    #         if not event.is_directory:
    file_path = event.src_path

    #             # Check if file should be ignored
    #             if self._should_ignore(file_path):
    #                 return

    #             # Find which plugin owns this file
    plugin_id = self._get_plugin_for_file(file_path)
    #             if plugin_id:
                    self._schedule_reload(plugin_id, file_path)

    #     def on_created(self, event):
    #         """Handle file creation events."""
    #         if not event.is_directory:
    file_path = event.src_path

    #             # Check if file should be ignored
    #             if self._should_ignore(file_path):
    #                 return

    #             # Find which plugin owns this file
    plugin_id = self._get_plugin_for_file(file_path)
    #             if plugin_id:
                    self._schedule_reload(plugin_id, file_path)

    #     def _should_ignore(self, file_path: str) -bool):
    #         """Check if a file should be ignored."""
    file_path = Path(file_path)

    #         # Check ignore patterns
    #         for pattern in self.ignore_patterns:
    #             if pattern.startswith("*."):
    #                 if file_path.name.endswith(pattern[1:]):
    #                     return True
    #             elif pattern in file_path.parts:
    #                 return True

    #         # Ignore hidden files
    #         if file_path.name.startswith("."):
    #             return True

    #         return False

    #     def _get_plugin_for_file(self, file_path: str) -Optional[str]):
    #         """Get the plugin ID that owns a file."""
    file_path = Path(file_path).resolve()

    #         for plugin_info in self.plugin_manager.get_all_plugins():
    #             if file_path.is_relative_to(plugin_info.path):
    #                 return plugin_info.id

    #         return None

    #     def _schedule_reload(self, plugin_id: str, file_path: str):
    #         """Schedule a plugin reload with debouncing."""
    #         with self._lock:
    now = time.time()

    #             # Cancel existing timer for this plugin
    #             if plugin_id in self._debounce_timers:
                    self._debounce_timers[plugin_id].cancel()

    #             # Store event info
    self._pending_events[plugin_id] = {
    #                 "file_path": file_path,
    #                 "timestamp": now,
    #             }

    #             # Schedule new timer
    timer = threading.Timer(
    #                 self.debounce_time,
    #                 self._perform_reload,
    args = [plugin_id]
    #             )
    self._debounce_timers[plugin_id] = timer
                timer.start()

    #     def _perform_reload(self, plugin_id: str):
    #         """Perform the actual plugin reload."""
    #         with self._lock:
    #             if plugin_id not in self._pending_events:
    #                 return

    event_info = self._pending_events[plugin_id]
    file_path = event_info["file_path"]

    #             # Clean up
    #             if plugin_id in self._debounce_timers:
    #                 del self._debounce_timers[plugin_id]
    #             del self._pending_events[plugin_id]

    #         # Create reload event
    reload_event = ReloadEventInfo(
    event_type = ReloadEvent.FILE_CHANGED,
    plugin_id = plugin_id,
    file_path = file_path,
    metadata = {"action": "schedule_reload"},
    #         )

    #         # Call the callback
            self.callback(reload_event)


class FileHashTracker
    #     """Tracks file hashes to detect changes."""

    #     def __init__(self):
    self._hashes: Dict[str, str] = {}
    self._lock = threading.Lock()

    #     def get_file_hash(self, file_path: str) -str):
    #         """Get the hash of a file."""
    #         try:
    #             with open(file_path, "rb") as f:
                    return hashlib.md5(f.read()).hexdigest()
            except (IOError, OSError):
    #             return ""

    #     def has_changed(self, file_path: str) -bool):
    #         """Check if a file has changed since last check."""
    #         with self._lock:
    current_hash = self.get_file_hash(file_path)

    #             if file_path not in self._hashes:
    self._hashes[file_path] = current_hash
    #                 return True

    #             if self._hashes[file_path] != current_hash:
    self._hashes[file_path] = current_hash
    #                 return True

    #             return False

    #     def remove_file(self, file_path: str):
    #         """Remove a file from tracking."""
    #         with self._lock:
                self._hashes.pop(file_path, None)

    #     def clear(self):
    #         """Clear all tracked files."""
    #         with self._lock:
                self._hashes.clear()


class StatePreserver
    #     """Preserves and restores plugin state during reload."""

    #     def __init__(self, plugin_manager):""
    #         Initialize the state preserver.

    #         Args:
    #             plugin_manager: Plugin manager instance
    #         """
    self.plugin_manager = plugin_manager
    self.logger = logging.getLogger(__name__)

    #     async def preserve_state(self, plugin_id: str) -Dict[str, Any]):
    #         """
    #         Preserve the state of a plugin before reload.

    #         Args:
    #             plugin_id: ID of the plugin

    #         Returns:
    #             Preserved state data
    #         """
    state_data = {}

    #         try:
    #             # Get plugin instance
    plugin = self.plugin_manager._instances.get(plugin_id)
    #             if not plugin:
    #                 return state_data

    #             # Preserve context state
    context = self.plugin_manager._contexts.get(plugin_id)
    #             if context:
    state_data["context_state"] = context._state.copy()

    #             # Preserve plugin-specific state if plugin supports it
    #             if hasattr(plugin, "preserve_state"):
    plugin_state = await plugin.preserve_state()
    #                 if plugin_state:
    state_data["plugin_state"] = plugin_state

    #             # Preserve configuration
    api = self.plugin_manager.get_plugin_api(plugin_id)
    #             if api:
    state_data["config"] = await api.config.get_all()

    #             # Preserve UI state if applicable
    #             if hasattr(plugin, "get_ui_state"):
    ui_state = await plugin.get_ui_state()
    #                 if ui_state:
    state_data["ui_state"] = ui_state

    #             self.logger.info(f"Preserved state for plugin {plugin_id}")

    #         except Exception as e:
    #             self.logger.error(f"Error preserving state for plugin {plugin_id}: {e}")

    #         return state_data

    #     async def restore_state(self, plugin_id: str, state_data: Dict[str, Any]) -bool):
    #         """
    #         Restore the state of a plugin after reload.

    #         Args:
    #             plugin_id: ID of the plugin
    #             state_data: Previously preserved state

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         try:
    #             # Get new plugin instance
    plugin = self.plugin_manager._instances.get(plugin_id)
    #             if not plugin:
    #                 return False

    #             # Restore context state
    context = self.plugin_manager._contexts.get(plugin_id)
    #             if context and "context_state" in state_data:
                    context._state.update(state_data["context_state"])

    #             # Restore configuration
    api = self.plugin_manager.get_plugin_api(plugin_id)
    #             if api and "config" in state_data:
    #                 for key, value in state_data["config"].items():
                        await api.config.set(key, value)

    #             # Restore plugin-specific state if plugin supports it
    #             if hasattr(plugin, "restore_state") and "plugin_state" in state_data:
                    await plugin.restore_state(state_data["plugin_state"])

    #             # Restore UI state if applicable
    #             if hasattr(plugin, "restore_ui_state") and "ui_state" in state_data:
                    await plugin.restore_ui_state(state_data["ui_state"])

    #             self.logger.info(f"Restored state for plugin {plugin_id}")
    #             return True

    #         except Exception as e:
    #             self.logger.error(f"Error restoring state for plugin {plugin_id}: {e}")
    #             return False


class HotReloadManager
    #     """
    #     Manages hot reloading of plugins.

    #     This class provides functionality to monitor plugin files for changes
    #     and automatically reload affected plugins when changes are detected.
    #     """

    #     def __init__(self, plugin_manager, event_bus, logger=None):""
    #         Initialize the hot reload manager.

    #         Args:
    #             plugin_manager: Plugin manager instance
    #             event_bus: Event bus for reload events
    #             logger: Logger instance
    #         """
    self.plugin_manager = plugin_manager
    self.event_bus = event_bus
    self.logger = logger or logging.getLogger(__name__)

    #         # Reload state
    self._enabled = False
    self._reloading_plugins: Set[str] = set()
    self._reload_states: Dict[str, ReloadState] = {}

    #         # File watching
    self._observer = None
    self._file_watchers: Dict[str, PluginFileWatcher] = {}
    self._tracker = FileHashTracker()

    #         # Polling fallback
    self._polling = False
    self._poll_interval = 1.0
    self._poll_task: Optional[asyncio.Task] = None
    self._stop_event = asyncio.Event()

    #         # State preservation
    self._state_preserver = StatePreserver(plugin_manager)

    #         # Callbacks
    self._reload_callbacks: List[Callable[[ReloadEventInfo], None]] = []

    #         # Statistics
    self._stats = {
    #             "total_reloads": 0,
    #             "successful_reloads": 0,
    #             "failed_reloads": 0,
    #             "last_reload_time": None,
    #             "average_reload_time": 0.0,
    #         }

    #         # Configuration
    self._config = {
    #             "enabled": True,
    #             "use_polling": False,
    #             "poll_interval": 1.0,
    #             "debounce_time": 1.0,
    #             "preserve_state": True,
    #             "auto_restart": True,
    #             "max_reload_attempts": 3,
    #         }

    #     def set_config(self, config: Dict[str, Any]) -None):
    #         """
    #         Set hot reload configuration.

    #         Args:
    #             config: Configuration dictionary
    #         """
            self._config.update(config)

    #     def enable(self, watch_directories: List[Path] = None) -None):
    #         """
    #         Enable hot reloading.

    #         Args:
    #             watch_directories: Directories to watch for changes
    #         """
    #         if self._enabled:
    #             return

    self._enabled = True

    #         # Start file watching or polling
    #         if self._config.get("use_polling", False):
                self._start_polling()
    #         else:
                self._start_file_watching(
                    watch_directories or self._get_plugin_directories()
    #             )

            self.logger.info("Hot reload enabled")

    #     async def disable(self) -None):
    #         """Disable hot reloading."""
    #         if not self._enabled:
    #             return

    self._enabled = False

    #         # Stop file watching or polling
    #         if self._polling:
                await self._stop_polling()
    #         else:
                self._stop_file_watching()

            self.logger.info("Hot reload disabled")

    #     def _get_plugin_directories(self) -List[Path]):
    #         """Get directories containing loaded plugins."""
    directories = set()

    #         for plugin_info in self.plugin_manager.get_all_plugins():
    #             if plugin_info.path:
                    directories.add(plugin_info.path)

            return list(directories)

    #     def _start_file_watching(self, directories: List[Path]) -None):
    #         """Start watching directories for file changes."""
    #         if self._observer and self._observer.is_alive():
    #             return

    #         if not WATCHDOG_AVAILABLE:
                self.logger.warning("watchdog not available, falling back to polling")
                self._start_polling()
    #             return

    self._observer = Observer()

    #         for directory in directories:
    #             if directory.exists() and directory.is_dir():
    #                 # Create file watcher for this directory
    watcher = PluginFileWatcher(
    #                     self.plugin_manager,
    #                     self._on_file_changed,
    debounce_time = self._config.get("debounce_time", 1.0),
    #                 )

    self._observer.schedule(watcher, str(directory), recursive = True)
    self._file_watchers[str(directory)] = watcher

            self._observer.start()
    #         self.logger.info(f"Watching {len(directories)} directories for changes")

    #     async def _stop_file_watching(self) -None):
    #         """Stop watching directories for file changes."""
    #         if self._observer:
                self._observer.stop()
                self._observer.join()
    self._observer = None

            self._file_watchers.clear()

    #     def _start_polling(self) -None):
    #         """Start polling for file changes."""
    #         if self._poll_task and not self._poll_task.done():
    #             return

    self._polling = True
            self._stop_event.clear()
    self._poll_interval = self._config.get("poll_interval", 1.0)

    self._poll_task = asyncio.create_task(self._poll_for_changes())
    #         self.logger.info("Started polling for file changes")

    #     async def _stop_polling(self) -None):
    #         """Stop polling for file changes."""
    self._polling = False
            self._stop_event.set()

    #         if self._poll_task:
                self._poll_task.cancel()
    #             try:
    #                 if not self._poll_task.done():
    #                     await self._poll_task
    #             except asyncio.CancelledError:
    #                 pass

    self._poll_task = None

    #     async def _poll_for_changes(self) -None):
    #         """Poll for file changes."""
    #         while not self._stop_event.is_set():
    #             try:
    #                 # Check all plugin files for changes
    #                 for plugin_info in self.plugin_manager.get_all_plugins():
    #                     if plugin_info.path:
                            await self._check_plugin_directory(
    #                             plugin_info.path, plugin_info.id
    #                         )

                    await asyncio.sleep(self._poll_interval)
    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
    #                 self.logger.error(f"Error polling for file changes: {e}")

    #     async def _check_plugin_directory(self, directory: Path, plugin_id: str) -None):
    #         """Check a plugin directory for file changes."""
    #         for file_path in directory.rglob("*"):
    #             if file_path.is_file() and not file_path.name.startswith("."):
    #                 if self._tracker.has_changed(str(file_path)):
                        await self._schedule_reload(plugin_id, str(file_path))

    #     async def _schedule_reload(self, plugin_id: str, file_path: str) -None):
    #         """Schedule a plugin reload."""
    #         # Check if already reloading
    #         if plugin_id in self._reloading_plugins:
                self.logger.debug(f"Plugin {plugin_id} is already being reloaded")
    #             return

    #         # Create reload event
    reload_event = ReloadEventInfo(
    event_type = ReloadEvent.FILE_CHANGED,
    plugin_id = plugin_id,
    file_path = file_path,
    metadata = {"action": "schedule_reload"},
    #         )

    #         # Emit event
            await self.event_bus.emit(
    #             "hot_reload.file_changed",
    #             {
    #                 "plugin_id": plugin_id,
    #                 "file_path": file_path,
    #             },
    source = "hot_reload_manager",
    #         )

    #         # Start reload process
            asyncio.create_task(self._reload_plugin(plugin_id, file_path))

    #     async def _reload_plugin(self, plugin_id: str, file_path: str) -None):
    #         """Perform the actual plugin reload."""
    #         if plugin_id in self._reloading_plugins:
    #             return

            self._reloading_plugins.add(plugin_id)
    reload_start_time = time.time()

    #         try:
    #             # Get current state
    current_state = self.plugin_manager.get_plugin_state(plugin_id)
    was_started = current_state.value == "started"

    #             # Create reload state
    reload_state = ReloadState(
    plugin_id = plugin_id,
    original_state = current_state.value,
    was_started = was_started,
    #             )
    self._reload_states[plugin_id] = reload_state

    #             # Emit reload started event
                await self.event_bus.emit(
    #                 "hot_reload.reload_started",
    #                 {
    #                     "plugin_id": plugin_id,
    #                     "file_path": file_path,
    #                     "was_started": was_started,
    #                 },
    source = "hot_reload_manager",
    #             )

    #             # Preserve state if enabled
    preserved_state = {}
    #             if self._config.get("preserve_state", True):
    preserved_state = await self._state_preserver.preserve_state(plugin_id)
    reload_state.preserved_data = preserved_state

    #             # Stop plugin if running
    #             if was_started:
                    await self.plugin_manager.stop_plugin(plugin_id)

    #             # Unload plugin
                await self.plugin_manager.unload_plugin(plugin_id)

    #             # Clear module cache to ensure fresh import
                await self._clear_module_cache(plugin_id)

    #             # Load plugin again
    load_success = await self.plugin_manager.load_plugin(plugin_id)

    #             if not load_success:
                    raise Exception("Failed to reload plugin")

    #             # Restore state if preserved
    #             if preserved_state:
                    await self._state_preserver.restore_state(plugin_id, preserved_state)

    #             # Start plugin if it was running before
    #             if was_started and self._config.get("auto_restart", True):
    start_success = await self.plugin_manager.start_plugin(plugin_id)
    #                 if not start_success:
                        raise Exception("Failed to restart plugin after reload")

    #             # Update reload state
    reload_state.reload_end_time = time.time()
    reload_state.success = True

    #             # Update statistics
    reload_time = reload_state.reload_end_time - reload_state.reload_start_time
                self._update_stats(True, reload_time)

    #             # Emit success event
                await self.event_bus.emit(
    #                 "hot_reload.reload_completed",
    #                 {
    #                     "plugin_id": plugin_id,
    #                     "file_path": file_path,
    #                     "success": True,
    #                     "reload_time": reload_time,
    #                 },
    source = "hot_reload_manager",
    #             )

                self.logger.info(f"Successfully reloaded plugin {plugin_id} in {reload_time:.3f}s")

    #         except Exception as e:
    #             # Update reload state
    reload_state.reload_end_time = time.time()
    reload_state.success = False
    reload_state.error_message = str(e)

    #             # Update statistics
    reload_time = reload_state.reload_end_time - reload_state.reload_start_time
                self._update_stats(False, reload_time)

    #             # Emit failure event
                await self.event_bus.emit(
    #                 "hot_reload.reload_completed",
    #                 {
    #                     "plugin_id": plugin_id,
    #                     "file_path": file_path,
    #                     "success": False,
                        "error": str(e),
    #                     "reload_time": reload_time,
    #                 },
    source = "hot_reload_manager",
    #             )

                self.logger.error(f"Failed to reload plugin {plugin_id}: {e}")

    #         finally:
    #             # Clean up
                self._reloading_plugins.discard(plugin_id)
    #             if plugin_id in self._reload_states:
    #                 del self._reload_states[plugin_id]

    #     async def _clear_module_cache(self, plugin_id: str) -None):
    #         """Clear module cache for a plugin."""
    #         # Remove plugin modules from sys.modules
    modules_to_remove = []
    module_name = plugin_id.replace("-", "_")

    #         for module_name in sys.modules:
    #             if module_name.startswith(plugin_id.replace("-", "_")):
                    modules_to_remove.append(module_name)

    #         for module_name in modules_to_remove:
    #             del sys.modules[module_name]

    #     async def _on_file_changed(self, event_info: ReloadEventInfo) -None):
    #         """Handle file change events."""
    #         # Call registered callbacks
    #         for callback in self._reload_callbacks:
    #             try:
                    callback(event_info)
    #             except Exception as e:
                    self.logger.error(f"Error in reload callback: {e}")

    #         # Emit event to event bus
            await self.event_bus.emit(
    #             "hot_reload.event",
    #             {
    #                 "event_type": event_info.event_type.value,
    #                 "plugin_id": event_info.plugin_id,
    #                 "file_path": event_info.file_path,
    #                 "error_message": event_info.error_message,
    #                 "timestamp": event_info.timestamp,
    #                 "request_id": event_info.request_id,
    #             },
    source = "hot_reload_manager",
    #         )

    #     def _update_stats(self, success: bool, reload_time: float) -None):
    #         """Update reload statistics."""
    self._stats["total_reloads"] + = 1
    self._stats["last_reload_time"] = time.time()

    #         if success:
    self._stats["successful_reloads"] + = 1
    #         else:
    self._stats["failed_reloads"] + = 1

    #         # Update average reload time
    total = self._stats["total_reloads"]
    current_avg = self._stats["average_reload_time"]
    self._stats["average_reload_time"] = (
                (current_avg * (total - 1) + reload_time) / total
    #         )

    #     def add_reload_callback(self, callback: Callable[[ReloadEventInfo], None]) -None):
    #         """Add a callback for reload events."""
            self._reload_callbacks.append(callback)

    #     def remove_reload_callback(self, callback: Callable[[ReloadEventInfo], None]) -None):
    #         """Remove a reload callback."""
    #         if callback in self._reload_callbacks:
                self._reload_callbacks.remove(callback)

    #     async def manually_reload_plugin(self, plugin_id: str) -bool):
    #         """
    #         Manually reload a plugin.

    #         Args:
    #             plugin_id: ID of plugin to reload

    #         Returns:
    #             True if successful, False otherwise
    #         """
            await self._schedule_reload(plugin_id, "manual_reload")
    #         return True

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get hot reload statistics."""
    #         return {
    #             **self._stats,
    #             "enabled": self._enabled,
    #             "polling": self._polling,
                "watching_directories": len(self._file_watchers),
                "reloading_plugins": list(self._reloading_plugins),
                "config": self._config.copy(),
    #         }

    #     def is_enabled(self) -bool):
    #         """Check if hot reload is enabled."""
    #         return self._enabled

    #     def is_reloading(self, plugin_id: str) -bool):
    #         """Check if a plugin is currently being reloaded."""
    #         return plugin_id in self._reloading_plugins

    #     def get_reload_state(self, plugin_id: str) -Optional[ReloadState]):
    #         """Get the reload state for a plugin."""
            return self._reload_states.get(plugin_id)