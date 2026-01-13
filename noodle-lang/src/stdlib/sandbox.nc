# Converted from Python to NoodleCore
# Original file: src

# """
# Plugin sandboxing and security framework for Noodle IDE.

# This module provides a secure execution environment for plugins,
# isolating them from the core system and each other.
# """

import asyncio
import importlib
import importlib.util
import inspect
import logging
import os
import sys
import threading
import time
import traceback
import collections.defaultdict
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any
import uuid
import weakref
import resource
import signal
import multiprocessing
import contextlib.contextmanager

import .interfaces.Plugin


class SandboxViolation(Exception)
    #     """Exception raised when a plugin violates sandbox rules."""
    #     pass


class ResourceLimit(Enum)
    #     """Types of resource limits."""
    CPU_TIME = "cpu_time"
    MEMORY = "memory"
    FILE_DESCRIPTORS = "file_descriptors"
    NETWORK_CONNECTIONS = "network_connections"
    DISK_IO = "disk_io"


dataclass
class SandboxConfig
    #     """Configuration for plugin sandbox."""

    #     # Resource limits
    max_cpu_time: Optional[float] = None  # seconds
    max_memory: Optional[int] = None      # bytes
    max_file_descriptors: Optional[int] = None
    max_network_connections: Optional[int] = None
    max_disk_io: Optional[int] = None     # bytes per second

    #     # Security settings
    allow_file_access: bool = False
    allow_network_access: bool = False
    allow_system_calls: bool = False
    allow_subprocesses: bool = False

    #     # Allowed paths
    allowed_read_paths: List[Path] = field(default_factory=list)
    allowed_write_paths: List[Path] = field(default_factory=list)

    #     # Monitoring
    enable_monitoring: bool = True
    monitoring_interval: float = 1.0  # seconds

    #     # Isolation
    use_process_isolation: bool = False
    use_namespace_isolation: bool = False


dataclass
class ResourceUsage
    #     """Current resource usage statistics."""

    cpu_time: float = 0.0
    memory_usage: int = 0
    file_descriptors: int = 0
    network_connections: int = 0
    disk_io_read: int = 0
    disk_io_write: int = 0
    last_update: float = field(default_factory=time.time)


class RestrictedModule
    #     """Wrapper for modules with restricted access."""

    #     def __init__(self, module: Any, allowed_attributes: Set[str]):""
    #         Initialize restricted module.

    #         Args:
    #             module: The original module
    #             allowed_attributes: Set of allowed attribute names
    #         """
    self._module = module
    self._allowed = allowed_attributes

    #     def __getattr__(self, name: str) -Any):
    #         """Get attribute if allowed."""
    #         if name not in self._allowed:
                raise SandboxViolation(f"Access to '{name}' is not allowed")
            return getattr(self._module, name)


class RestrictedImport
    #     """Custom import hook for restricting module imports."""

    #     def __init__(self, allowed_modules: Set[str], restricted_modules: Dict[str, Set[str]]):""
    #         Initialize restricted import hook.

    #         Args:
    #             allowed_modules: Set of fully allowed modules
    #             restricted_modules: Dict of module to allowed attributes
    #         """
    self.allowed_modules = allowed_modules
    self.restricted_modules = restricted_modules
    self.original_import = __builtins__['__import__']
    self.logger = logging.getLogger(__name__)

    #     def __call__(self, name: str, globals=None, locals=None, fromlist=(), level=0):
    #         """Custom import function with restrictions."""
    #         # Check if module is allowed
    #         if name not in self.allowed_modules and name not in self.restricted_modules:
                raise SandboxViolation(f"Import of module '{name}' is not allowed")

    #         # Perform the import
    module = self.original_import(name, globals, locals, fromlist, level)

    #         # Apply restrictions if needed
    #         if name in self.restricted_modules:
    allowed_attrs = self.restricted_modules[name]
                return RestrictedModule(module, allowed_attrs)

    #         return module


class ResourceMonitor
    #     """Monitors resource usage for a plugin."""

    #     def __init__(self, plugin_id: str, config: SandboxConfig):""
    #         Initialize resource monitor.

    #         Args:
    #             plugin_id: ID of the plugin to monitor
    #             config: Sandbox configuration
    #         """
    self.plugin_id = plugin_id
    self.config = config
    self.logger = logging.getLogger(__name__)
    self.usage = ResourceUsage()
    self._monitoring = False
    self._monitor_task: Optional[asyncio.Task] = None
    self._process = None
    self._start_time = time.time()

    #         # Get process for monitoring
    #         try:
    self._process = multiprocessing.current_process()
    #         except:
    self._process = None

    #     async def start_monitoring(self) -None):
    #         """Start resource monitoring."""
    #         if self._monitoring or not self.config.enable_monitoring:
    #             return

    self._monitoring = True
    self._monitor_task = asyncio.create_task(self._monitor_loop())
    #         self.logger.info(f"Started resource monitoring for plugin {self.plugin_id}")

    #     async def stop_monitoring(self) -None):
    #         """Stop resource monitoring."""
    #         if not self._monitoring:
    #             return

    self._monitoring = False
    #         if self._monitor_task:
                self._monitor_task.cancel()
    #             try:
    #                 await self._monitor_task
    #             except asyncio.CancelledError:
    #                 pass

    #         self.logger.info(f"Stopped resource monitoring for plugin {self.plugin_id}")

    #     async def _monitor_loop(self) -None):
    #         """Main monitoring loop."""
    #         while self._monitoring:
    #             try:
                    await self._update_usage()
                    await self._check_limits()
                    await asyncio.sleep(self.config.monitoring_interval)
    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    self.logger.error(f"Error in resource monitor: {e}")

    #     async def _update_usage(self) -None):
    #         """Update current resource usage."""
    #         try:
    #             import psutil

    #             # Get current process
    #             if self._process:
    process = psutil.Process(self._process.pid)
    #             else:
    process = psutil.Process()

    #             # Update memory usage
    memory_info = process.memory_info()
    self.usage.memory_usage = memory_info.rss

    #             # Update CPU time
    self.usage.cpu_time = process.cpu_times().user + process.cpu_times(.system)

    #             # Update file descriptors
    #             try:
    self.usage.file_descriptors = process.num_fds()
                except (AttributeError, psutil.AccessDenied):
                    # Windows doesn't have num_fds()
    self.usage.file_descriptors = len(process.open_files())

    #             # Update network connections
    #             try:
    self.usage.network_connections = len(process.connections())
                except (psutil.AccessDenied, psutil.NoSuchProcess):
    self.usage.network_connections = 0

    #             # Update disk I/O
    #             try:
    io_counters = process.io_counters()
    self.usage.disk_io_read = io_counters.read_bytes
    self.usage.disk_io_write = io_counters.write_bytes
                except (AttributeError, psutil.AccessDenied):
    #                 # Windows or no permissions
    #                 pass

    self.usage.last_update = time.time()

    #         except ImportError:
    #             # psutil not available, use basic monitoring
                self.logger.warning("psutil not available, using basic monitoring")
    #         except Exception as e:
                self.logger.error(f"Error updating resource usage: {e}")

    #     async def _check_limits(self) -None):
    #         """Check if resource limits are exceeded."""
    violations = []

    #         # Check CPU time limit
    #         if self.config.max_cpu_time and self.usage.cpu_time self.config.max_cpu_time):
                violations.append(f"CPU time limit exceeded: {self.usage.cpu_time}s {self.config.max_cpu_time}s")

    #         # Check memory limit
    #         if self.config.max_memory and self.usage.memory_usage > self.config.max_memory):
                violations.append(f"Memory limit exceeded: {self.usage.memory_usage} {self.config.max_memory}")

    #         # Check file descriptor limit
    #         if self.config.max_file_descriptors and self.usage.file_descriptors > self.config.max_file_descriptors):
                violations.append(f"File descriptor limit exceeded: {self.usage.file_descriptors} {self.config.max_file_descriptors}")

    #         # Check network connection limit
    #         if self.config.max_network_connections and self.usage.network_connections > self.config.max_network_connections):
                violations.append(f"Network connection limit exceeded: {self.usage.network_connections} {self.config.max_network_connections}")

    #         # Raise violation if any limits exceeded
    #         if violations):
                raise SandboxViolation(f"Resource limits exceeded: {'; '.join(violations)}")

    #     def get_usage(self) -ResourceUsage):
    #         """Get current resource usage."""
    #         return self.usage


class PluginSandbox
    #     """
    #     Secure execution environment for plugins.

    #     This class provides a sandboxed environment for running plugins
    #     with restricted access to system resources.
    #     """

    #     def __init__(self, plugin_id: str, config: Optional[SandboxConfig] = None):""
    #         Initialize the plugin sandbox.

    #         Args:
    #             plugin_id: ID of the plugin
    #             config: Sandbox configuration
    #         """
    self.plugin_id = plugin_id
    self.config = config or SandboxConfig()
    self.logger = logging.getLogger(__name__)

    #         # Resource monitoring
    self.monitor = ResourceMonitor(plugin_id, self.config)

    #         # Security restrictions
    self._original_import = None
    self._original_open = None
    self._original_exec = None
    self._restricted = False

    #         # Execution context
    self._execution_context: Dict[str, Any] = {}
    self._allowed_modules = self._get_allowed_modules()
    self._restricted_modules = self._get_restricted_modules()

    #     def _get_allowed_modules(self) -Set[str]):
    #         """Get the set of fully allowed modules."""
    #         return {
    #             # Standard library modules that are generally safe
    #             'builtins',
    #             'math',
    #             'random',
    #             'datetime',
    #             'json',
    #             're',
    #             'string',
    #             'collections',
    #             'itertools',
    #             'functools',
    #             'operator',
    #             'typing',
    #             'dataclasses',
    #             'enum',
    #             'contextlib',
    #             'asyncio',
    #             'logging',
    #         }

    #     def _get_restricted_modules(self) -Dict[str, Set[str]]):
    #         """Get modules with restricted attribute access."""
    #         return {
    #             'os': {
    #                 'environ', 'getcwd', 'chdir', 'mkdir', 'makedirs', 'listdir',
    #                 'path', 'sep', 'pathsep', 'linesep', 'curdir', 'pardir',
    #             },
    #             'sys': {
    #                 'version', 'version_info', 'platform', 'argv', 'path',
    #                 'modules', 'executable', 'prefix',
    #             },
    #             'pathlib': {
    #                 'Path', 'PurePath', 'PosixPath', 'WindowsPath',
    #             },
    #         }

    #     async def enter(self) -None):
    #         """Enter the sandbox environment."""
    #         if self._restricted:
    #             return

    #         self.logger.info(f"Entering sandbox for plugin {self.plugin_id}")

    #         # Start resource monitoring
            await self.monitor.start_monitoring()

    #         # Apply restrictions
            self._apply_restrictions()
    self._restricted = True

    #     async def exit(self) -None):
    #         """Exit the sandbox environment."""
    #         if not self._restricted:
    #             return

    #         self.logger.info(f"Exiting sandbox for plugin {self.plugin_id}")

    #         # Stop resource monitoring
            await self.monitor.stop_monitoring()

    #         # Restore original functions
            self._restore_restrictions()
    self._restricted = False

    #     @contextmanager
    #     async def context(self):
    #         """Context manager for sandbox execution."""
            await self.enter()
    #         try:
    #             yield self
    #         finally:
                await self.exit()

    #     def _apply_restrictions(self) -None):
    #         """Apply security restrictions."""
    #         # Restrict imports
    #         if not self._original_import:
    self._original_import = __builtins__['__import__']
    restricted_import = RestrictedImport(
    #                 self._allowed_modules,
    #                 self._restricted_modules,
    #             )
    __builtins__['__import__'] = restricted_import

    #         # Restrict file operations
    #         if not self.config.allow_file_access and not self._original_open:
    self._original_open = builtins.open
    #             def restricted_open(*args, **kwargs):
                    raise SandboxViolation("File access is not allowed in this sandbox")
    builtins.open = restricted_open

    #         # Restrict subprocess execution
    #         if not self.config.allow_subprocesses:
    #             import subprocess
    original_popen = subprocess.Popen
    #             def restricted_popen(*args, **kwargs):
                    raise SandboxViolation("Subprocess execution is not allowed in this sandbox")
    subprocess.Popen = restricted_popen

    #     def _restore_restrictions(self) -None):
    #         """Restore original functions."""
    #         # Restore import
    #         if self._original_import:
    __builtins__['__import__'] = self._original_import
    self._original_import = None

    #         # Restore file operations
    #         if self._original_open:
    builtins.open = self._original_open
    self._original_open = None

    #         # Restore subprocess
    #         if not self.config.allow_subprocesses:
    #             import subprocess
    #             # This is a simplified restoration
    #             # In practice, we'd need to store the original

    #     async def execute_function(
    #         self,
    #         func: Callable,
    #         *args,
    timeout: Optional[float] = None,
    #         **kwargs,
    #     ) -Any):
    #         """
    #         Execute a function within the sandbox.

    #         Args:
    #             func: Function to execute
    #             args: Function arguments
    #             timeout: Execution timeout
    #             kwargs: Function keyword arguments

    #         Returns:
    #             Function result

    #         Raises:
    #             SandboxViolation: If sandbox rules are violated
    #             asyncio.TimeoutError: If execution times out
    #         """
    #         async with self.context():
    #             try:
    #                 if timeout:
    return await asyncio.wait_for(func(*args, **kwargs), timeout = timeout)
    #                 else:
    #                     if asyncio.iscoroutinefunction(func):
                            return await func(*args, **kwargs)
    #                     else:
    #                         # Run sync function in executor
    loop = asyncio.get_event_loop()
                            return await loop.run_in_executor(None, func, *args, **kwargs)

    #             except Exception as e:
                    self.logger.error(f"Error executing function in sandbox: {e}")
    #                 raise

    #     def get_resource_usage(self) -ResourceUsage):
    #         """Get current resource usage."""
            return self.monitor.get_usage()

    #     def check_file_access(self, path: Union[str, Path], mode: str = 'r') -bool):
    #         """
    #         Check if file access is allowed.

    #         Args:
    #             path: File path to check
                mode: Access mode ('r', 'w', 'rw')

    #         Returns:
    #             True if access is allowed
    #         """
    #         if not self.config.allow_file_access:
    #             return False

    path = Path(path).resolve()

    #         # Check read access
    #         if 'r' in mode:
    #             for allowed_path in self.config.allowed_read_paths:
    #                 if path.is_relative_to(allowed_path.resolve()):
    #                     return True

    #         # Check write access
    #         if 'w' in mode:
    #             for allowed_path in self.config.allowed_write_paths:
    #                 if path.is_relative_to(allowed_path.resolve()):
    #                     return True

    #         return False

    #     def check_network_access(self, host: str, port: int) -bool):
    #         """
    #         Check if network access is allowed.

    #         Args:
    #             host: Host to connect to
    #             port: Port to connect to

    #         Returns:
    #             True if access is allowed
    #         """
    #         return self.config.allow_network_access


class SandboxManager
    #     """
    #     Manages sandboxes for all plugins.

    #     This class creates and manages sandbox instances for plugins,
    #     providing centralized control over security policies.
    #     """

    #     def __init__(self):""Initialize the sandbox manager."""
    self.logger = logging.getLogger(__name__)
    self._sandboxes: Dict[str, PluginSandbox] = {}
    self._default_config = SandboxConfig()
    self._plugin_configs: Dict[str, SandboxConfig] = {}

    #     def set_default_config(self, config: SandboxConfig) -None):
    #         """
    #         Set the default sandbox configuration.

    #         Args:
    #             config: Default configuration
    #         """
    self._default_config = config

    #     def set_plugin_config(self, plugin_id: str, config: SandboxConfig) -None):
    #         """
    #         Set sandbox configuration for a specific plugin.

    #         Args:
    #             plugin_id: Plugin ID
    #             config: Plugin-specific configuration
    #         """
    self._plugin_configs[plugin_id] = config

    #     def get_sandbox(self, plugin_id: str) -PluginSandbox):
    #         """
    #         Get or create a sandbox for a plugin.

    #         Args:
    #             plugin_id: Plugin ID

    #         Returns:
    #             Plugin sandbox instance
    #         """
    #         if plugin_id not in self._sandboxes:
    config = self._plugin_configs.get(plugin_id, self._default_config)
    self._sandboxes[plugin_id] = PluginSandbox(plugin_id, config)

    #         return self._sandboxes[plugin_id]

    #     async def remove_sandbox(self, plugin_id: str) -None):
    #         """
    #         Remove a sandbox for a plugin.

    #         Args:
    #             plugin_id: Plugin ID
    #         """
    #         if plugin_id in self._sandboxes:
                await self._sandboxes[plugin_id].exit()
    #             del self._sandboxes[plugin_id]

    #     async def shutdown(self) -None):
    #         """Shutdown all sandboxes."""
    #         for plugin_id in list(self._sandboxes.keys()):
                await self.remove_sandbox(plugin_id)

    #     def get_all_resource_usage(self) -Dict[str, ResourceUsage]):
    #         """
    #         Get resource usage for all active sandboxes.

    #         Returns:
    #             Dictionary of plugin ID to resource usage
    #         """
    #         return {
                plugin_id: sandbox.get_resource_usage()
    #             for plugin_id, sandbox in self._sandboxes.items()
    #         }

    #     def get_sandbox_count(self) -int):
    #         """Get the number of active sandboxes."""
            return len(self._sandboxes)