# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Security sandbox for the Noodle-IDE plugin architecture.

# This module provides a secure execution environment for plugins,
# isolating them from each other and from the IDE core.
# """

import asyncio
import os
import sys
import subprocess
import tempfile
import shutil
import logging
import inspect
import textwrap
import pathlib.Path
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import contextlib.contextmanager
import json
import threading
import functools.wraps

# Import resource module only on Unix-like systems (not available on Windows)
try
    #     import resource

    HAS_RESOURCE = True
except ImportError
    HAS_RESOURCE = False
import signal

# Constants
DEFAULT_MEMORY_LIMIT = math.multiply(100, 1024 * 1024  # 100MB)
DEFAULT_CPU_TIME = 10  # seconds
DEFAULT_FILE_SIZE = math.multiply(10, 1024 * 1024  # 10MB)
DEFAULT_TOTAL_FILES = 100
DEFAULT_MAX_OPEN_FILES = 50


class SecurityLevel(Enum)
    #     """Security levels for plugin execution."""

    NONE = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    RESTRICTED = 4


# @dataclass
class SecurityPolicy
    #     """Security policy for a plugin."""

    level: SecurityLevel = SecurityLevel.MEDIUM
    memory_limit: int = DEFAULT_MEMORY_LIMIT
    cpu_time_limit: int = DEFAULT_CPU_TIME
    file_size_limit: int = DEFAULT_FILE_SIZE
    max_files: int = DEFAULT_TOTAL_FILES
    max_open_files: int = DEFAULT_MAX_OPEN_FILES
    allowed_paths: List[str] = field(default_factory=list)
    blocked_paths: List[str] = field(default_factory=list)
    allowed_hosts: List[str] = field(default_factory=list)
    blocked_hosts: List[str] = field(default_factory=list)
    allowed_env_vars: List[str] = field(default_factory=list)
    blocked_env_vars: List[str] = field(default_factory=list)
    allowed_imports: List[str] = field(default_factory=list)
    blocked_imports: List[str] = field(default_factory=list)
    system_calls: Dict[str, bool] = field(default_factory=dict)
    network_access: bool = False
    file_access: bool = True
    subprocess_access: bool = False
    unsafe_modules: bool = False


class SecurityViolation(Exception)
    #     """Exception raised for security violations."""

    #     def __init__(self, violation_type: str, message: str, policy: SecurityPolicy):
    self.violation_type = violation_type
    self.message = message
    self.policy = policy
            super().__init__(f"{violation_type}: {message}")


class ResourceLimiter
    #     """Limits system resources for plugin execution."""

    #     def __init__(self, policy: SecurityPolicy):
    self.policy = policy
    self._original_limits = {}
    self._active = False

    #     def __enter__(self):
    #         """Enter context and apply resource limits."""
    self._active = True
            self._apply_limits()
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Exit context and restore original limits."""
    self._active = False
            self._restore_limits()

    #     def _apply_limits(self):
    #         """Apply resource limits."""
    #         if not HAS_RESOURCE:
                logging.warning(
    #                 "Resource module not available on this platform, skipping resource limits"
    #             )
    #             return

    #         try:
                # Memory limit (Linux only)
    #             if hasattr(resource, "RLIMIT_AS"):
    self._original_limits["as"] = resource.getrlimit(resource.RLIMIT_AS)
                    resource.setrlimit(
    #                     resource.RLIMIT_AS,
                        (self.policy.memory_limit, self.policy.memory_limit),
    #                 )

    #             # CPU time limit
    #             if hasattr(resource, "RLIMIT_CPU"):
    self._original_limits["cpu"] = resource.getrlimit(resource.RLIMIT_CPU)
                    resource.setrlimit(
    #                     resource.RLIMIT_CPU,
                        (self.policy.cpu_time_limit, self.policy.cpu_time_limit),
    #                 )

    #             # File size limit
    #             if hasattr(resource, "RLIMIT_FSIZE"):
    self._original_limits["fsize"] = resource.getrlimit(
    #                     resource.RLIMIT_FSIZE
    #                 )
                    resource.setrlimit(
    #                     resource.RLIMIT_FSIZE,
                        (self.policy.file_size_limit, self.policy.file_size_limit),
    #                 )

    #             # Number of open files
    #             if hasattr(resource, "RLIMIT_NOFILE"):
    self._original_limits["nofile"] = resource.getrlimit(
    #                     resource.RLIMIT_NOFILE
    #                 )
                    resource.setrlimit(
    #                     resource.RLIMIT_NOFILE,
                        (self.policy.max_open_files, self.policy.max_open_files),
    #                 )

            except (OSError, AttributeError) as e:
    #             # Some limits may not be available on all platforms
                logging.warning(f"Could not apply all resource limits: {e}")

    #     def _restore_limits(self):
    #         """Restore original resource limits."""
    #         for limit_name, (soft, hard) in self._original_limits.items():
    #             try:
                    resource.setrlimit(
                        getattr(resource, f"RLIMIT_{limit_name.upper()}"), (soft, hard)
    #                 )
                except (OSError, AttributeError):
    #                 pass


class FileSystemGuard
    #     """Guards file system access for plugins."""

    #     def __init__(self, policy: SecurityPolicy):
    self.policy = policy
    self._temp_dir = None
    self._allowed_files = set()
    self._file_handles = {}

    #     def __enter__(self):
    #         """Enter context and set up file system restrictions."""
    #         # Create temporary directory for plugin files
    self._temp_dir = tempfile.mkdtemp(prefix="noodle_plugin_")
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Exit context and clean up files."""
    #         if self._temp_dir and os.path.exists(self._temp_dir):
    shutil.rmtree(self._temp_dir, ignore_errors = True)

    #         # Close all file handles
    #         for fh in self._file_handles.values():
    #             try:
                    fh.close()
    #             except:
    #                 pass
            self._file_handles.clear()

    #     def check_path(self, path: str, mode: str = "r") -> bool:
    #         """
    #         Check if a path is allowed.

    #         Args:
    #             path: Path to check
                mode: File access mode ('r', 'w', 'x')

    #         Returns:
    #             True if allowed, False otherwise
    #         """
    path = os.path.abspath(path)

    #         # Check blocked paths first
    #         for blocked in self.policy.blocked_paths:
    #             if path.startswith(os.path.abspath(blocked)):
    #                 return False

    #         # Check allowed paths
    #         if self.policy.allowed_paths:
    #             for allowed in self.policy.allowed_paths:
    #                 if path.startswith(os.path.abspath(allowed)):
    #                     return True
    #             return False

    #         # Default to temp directory only
            return path.startswith(os.path.abspath(self._temp_dir or ""))

    #     def open_file(self, path: str, mode: str = "r", **kwargs):
    #         """
    #         Open a file with security checks.

    #         Args:
    #             path: File path
    #             mode: File open mode
    #             **kwargs: Additional arguments for open()

    #         Returns:
    #             File handle
    #         """
    #         if not self.check_path(path, mode[0]):
                raise SecurityViolation(
    #                 "file_access", f"Access to path not allowed: {path}", self.policy
    #             )

    #         # Limit file size for write operations
    #         if "w" in mode or "a" in mode or "+" in mode:
    #             if "size" not in kwargs:
    kwargs["size"] = self.policy.file_size_limit

    fh = math.multiply(open(path, mode,, *kwargs))
    self._file_handles[fh.fileno()] = fh
    #         return fh

    #     def listdir(self, path: str) -> List[str]:
    #         """
    #         List directory contents.

    #         Args:
    #             path: Directory path

    #         Returns:
    #             List of file names
    #         """
    #         if not self.check_path(path, "x"):
                raise SecurityViolation(
    #                 "file_access", f"Directory listing not allowed: {path}", self.policy
    #             )

    #         try:
    files = os.listdir(path)
    #             # Apply file count limit
    #             return files[: self.policy.max_files]
    #         except OSError as e:
                raise SecurityViolation(
    #                 "file_access", f"Directory listing failed: {e}", self.policy
    #             )

    #     def create_temp_file(self, suffix: str = None) -> str:
    #         """
    #         Create a temporary file for plugin use.

    #         Args:
    #             suffix: File suffix

    #         Returns:
    #             Path to temporary file
    #         """
    fd, path = tempfile.mkstemp(dir=self._temp_dir, suffix=suffix)
            os.close(fd)
    #         return path


class NetworkGuard
    #     """Guards network access for plugins."""

    #     def __init__(self, policy: SecurityPolicy):
    self.policy = policy

    #     def check_host(self, host: str, port: int = None) -> bool:
    #         """
    #         Check if a host is allowed for network access.

    #         Args:
    #             host: Hostname or IP address
    #             port: Port number

    #         Returns:
    #             True if allowed, False otherwise
    #         """
    #         if not self.policy.network_access:
    #             return False

    #         # Check blocked hosts
    #         for blocked in self.policy.blocked_hosts:
    #             if host == blocked or host.endswith(f".{blocked}"):
    #                 return False

    #         # Check allowed hosts
    #         if self.policy.allowed_hosts:
    #             for allowed in self.policy.allowed_hosts:
    #                 if host == allowed or host.endswith(f".{allowed}"):
    #                     return True
    #             return False

    #         # Default to no network access
    #         return False


class ImportGuard
    #     """Guards module imports for plugins."""

    #     def __init__(self, policy: SecurityPolicy):
    self.policy = policy
    self._original_imports = {}
    self._patched_modules = set()

    #     def __enter__(self):
    #         """Enter context and set up import restrictions."""
            self._patch_imports()
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Exit context and restore original imports."""
            self._restore_imports()

    #     def _patch_imports(self):
    #         """Patch __import__ function to enforce restrictions."""
    original_import = __import__

    #         def restricted_import(name, *args, **kwargs):
    #             # Check blocked imports
    #             for blocked in self.policy.blocked_imports:
    #                 if name == blocked or name.startswith(f"{blocked}."):
                        raise SecurityViolation(
    #                         "import_restricted", f"Module not allowed: {name}", self.policy
    #                     )

    #             # Check allowed imports
    #             if self.policy.allowed_imports:
    allowed = False
    #                 for allowed_name in self.policy.allowed_imports:
    #                     if name == allowed_name or name.startswith(f"{allowed_name}."):
    allowed = True
    #                         break
    #                 if not allowed:
                        raise SecurityViolation(
    #                         "import_restricted",
    #                         f"Module not in allowed list: {name}",
    #                         self.policy,
    #                     )

                return original_import(name, *args, **kwargs)

    __builtins__.__import__ = restricted_import
    self._original_imports["__import__"] = original_import

    #     def _restore_imports(self):
    #         """Restore original imports."""
    #         if "__import__" in self._original_imports:
    __builtins__.__import__ = self._original_imports["__import__"]


class SecuritySandbox
    #     """
    #     Main security sandbox for plugin execution.

    #     This class provides comprehensive security isolation for plugins,
    #     including resource limits, file system restrictions, network access
    #     control, and import restrictions.
    #     """

    #     def __init__(self, policy: SecurityPolicy = None):
    #         """
    #         Initialize the security sandbox.

    #         Args:
    #             policy: Security policy to apply
    #         """
    self.policy = policy or SecurityPolicy()
    self.limiter = ResourceLimiter(self.policy)
    self.fs_guard = FileSystemGuard(self.policy)
    self.net_guard = NetworkGuard(self.policy)
    self.import_guard = ImportGuard(self.policy)

    #         # Security monitoring
    self.violations = []
    self._monitor_thread = None
    self._stop_event = threading.Event()

    #     def __enter__(self):
    #         """Enter sandbox context."""
            self.limiter.__enter__()
            self.fs_guard.__enter__()
            self.net_guard.__enter__()
            self.import_guard.__enter__()

    #         # Start security monitoring
            self._start_monitoring()

    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Exit sandbox context."""
            self._stop_monitoring()

            self.import_guard.__exit__(exc_type, exc_val, exc_tb)
            self.net_guard.__exit__(exc_type, exc_val, exc_tb)
            self.fs_guard.__exit__(exc_type, exc_val, exc_tb)
            self.limiter.__exit__(exc_type, exc_val, exc_tb)

    #     def _start_monitoring(self):
    #         """Start security monitoring thread."""
            self._stop_event.clear()
    self._monitor_thread = threading.Thread(target=self._monitor_security)
    self._monitor_thread.daemon = True
            self._monitor_thread.start()

    #     def _stop_monitoring(self):
    #         """Stop security monitoring."""
            self._stop_event.set()
    #         if self._monitor_thread:
    self._monitor_thread.join(timeout = 1.0)

    #     def _monitor_security(self):
    #         """Monitor for security violations."""
    #         while not self._stop_event.is_set():
    #             try:
    #                 # Check memory usage
    #                 if hasattr(self, "_check_memory_usage"):
    #                     try:
                            self._check_memory_usage()
    #                     except SecurityViolation as e:
                            self.violations.append(e)

    #                 # Check other metrics...

                    time.sleep(1.0)
    #             except Exception as e:
                    logging.error(f"Security monitoring error: {e}")

    #     def _check_memory_usage(self):
    #         """Check if memory usage exceeds limits."""
    #         try:
    #             # Get current process memory usage
    #             import psutil

    process = psutil.Process()
    memory_info = process.memory_info()
    rss = memory_info.rss

    #             if rss > self.policy.memory_limit:
                    raise SecurityViolation(
    #                     "memory_limit",
                        f"Memory usage ({rss} bytes) exceeds limit ({self.policy.memory_limit} bytes)",
    #                     self.policy,
    #                 )

    #         except ImportError:
    #             # psutil not available, skip memory check
    #             pass

    #     def wrap_function(self, func: Callable) -> Callable:
    #         """
    #         Wrap a function to execute within the sandbox.

    #         Args:
    #             func: Function to wrap

    #         Returns:
    #             Wrapped function
    #         """

            @wraps(func)
    #         def wrapper(*args, **kwargs):
    #             with self:
                    return func(*args, **kwargs)

    #         return wrapper

    #     def execute_code(
    #         self,
    #         code: str,
    globals_dict: Dict[str, Any] = None,
    locals_dict: Dict[str, Any] = None,
    #     ) -> Any:
    #         """
    #         Execute code within the sandbox.

    #         Args:
    #             code: Code to execute
    #             globals_dict: Global namespace
    #             locals_dict: Local namespace

    #         Returns:
    #             Result of code execution
    #         """
    #         if globals_dict is None:
    globals_dict = {}
    #         if locals_dict is None:
    locals_dict = {}

    #         # Create restricted globals
    restricted_globals = globals_dict.copy()
    restricted_globals["__builtins__"] = self._restrict_builtins()

    #         # Execute code
    #         try:
    #             with self:
                    exec(code, restricted_globals, locals_dict)
    #         except SecurityViolation as e:
                self.violations.append(e)
    #             raise
    #         except Exception as e:
                logging.error(f"Code execution error: {e}")
    #             raise

            return locals_dict.get("result", None)

    #     def _restrict_builtins(self) -> Dict[str, Any]:
    #         """Create restricted builtins dictionary."""
    restricted = {}

    #         # Safe builtins
    safe_builtins = [
    #             "abs",
    #             "all",
    #             "any",
    #             "ascii",
    #             "bin",
    #             "bool",
    #             "bytearray",
    #             "bytes",
    #             "chr",
    #             "complex",
    #             "dict",
    #             "dir",
    #             "divmod",
    #             "enumerate",
    #             "filter",
    #             "float",
    #             "format",
    #             "frozenset",
    #             "hash",
    #             "hex",
    #             "int",
    #             "iter",
    #             "len",
    #             "list",
    #             "map",
    #             "max",
    #             "min",
    #             "next",
    #             "oct",
    #             "ord",
    #             "pow",
    #             "range",
    #             "repr",
    #             "reversed",
    #             "round",
    #             "set",
    #             "slice",
    #             "sorted",
    #             "str",
    #             "sum",
    #             "tuple",
    #             "zip",
    #         ]

    #         for builtin in safe_builtins:
    #             if builtin in __builtins__:
    restricted[builtin] = __builtins__[builtin]

            # Potentially dangerous builtins (disabled by default)
    #         if self.policy.unsafe_modules:
    dangerous_builtins = [
    #                 "eval",
    #                 "exec",
    #                 "compile",
    #                 "open",
    #                 "input",
    #                 "globals",
    #                 "locals",
    #                 "vars",
    #                 "dir",
    #             ]
    #             for builtin in dangerous_builtins:
    #                 if builtin in __builtins__:
    restricted[builtin] = __builtins__[builtin]

    #         return restricted

    #     def create_sandboxed_environment(self) -> Dict[str, Any]:
    #         """
    #         Create a completely sandboxed execution environment.

    #         Returns:
    #             Dictionary with safe globals and locals
    #         """
    env = {
                "__builtins__": self._restrict_builtins(),
    #             "__name__": "__sandbox__",
    #             "__doc__": None,
    #             "__package__": None,
    #             "__loader__": None,
    #             "__spec__": None,
    #             "__file__": None,
    #             "__cached__": None,
    #         }

    #         # Add safe imports
    #         for module in self.policy.allowed_imports:
    #             try:
    env[module] = __import__(module)
    #             except ImportError:
    #                 pass

    #         return env

    #     def get_violations(self) -> List[SecurityViolation]:
    #         """Get list of security violations."""
            return self.violations.copy()

    #     def clear_violations(self):
    #         """Clear recorded security violations."""
            self.violations.clear()


class DefaultSecurityPolicies
    #     """Collection of default security policies."""

    #     @staticmethod
    #     def minimal_policy() -> SecurityPolicy:
    #         """Minimal security policy (for trusted plugins)."""
            return SecurityPolicy(
    level = SecurityLevel.LOW,
    memory_limit = math.multiply(500, 1024 * 1024,  # 500MB)
    cpu_time_limit = 60,  # 1 minute
    file_size_limit = math.multiply(100, 1024 * 1024,  # 100MB)
    max_files = 1000,
    max_open_files = 200,
    allowed_paths = ["/tmp"],
    allowed_env_vars = ["PATH", "HOME"],
    network_access = True,
    subprocess_access = True,
    #         )

    #     @staticmethod
    #     def standard_policy() -> SecurityPolicy:
            """Standard security policy (most plugins)."""
            return SecurityPolicy(
    level = SecurityLevel.MEDIUM,
    memory_limit = math.multiply(100, 1024 * 1024,  # 100MB)
    cpu_time_limit = 10,  # 10 seconds
    file_size_limit = math.multiply(10, 1024 * 1024,  # 10MB)
    max_files = 100,
    max_open_files = 50,
    allowed_paths = ["/tmp", "/var/tmp"],
    allowed_env_vars = ["PATH", "HOME", "LANG"],
    network_access = True,
    subprocess_access = False,
    #         )

    #     @staticmethod
    #     def strict_policy() -> SecurityPolicy:
            """Strict security policy (untrusted plugins)."""
            return SecurityPolicy(
    level = SecurityLevel.HIGH,
    memory_limit = math.multiply(50, 1024 * 1024,  # 50MB)
    cpu_time_limit = 5,  # 5 seconds
    file_size_limit = math.multiply(1, 1024 * 1024,  # 1MB)
    max_files = 50,
    max_open_files = 20,
    network_access = False,
    subprocess_access = False,
    unsafe_modules = False,
    #         )

    #     @staticmethod
    #     def restricted_policy() -> SecurityPolicy:
    #         """Most restrictive security policy."""
            return SecurityPolicy(
    level = SecurityLevel.RESTRICTED,
    memory_limit = math.multiply(10, 1024 * 1024,  # 10MB)
    cpu_time_limit = 1,  # 1 second
    file_size_limit = math.multiply(1024, 1024,  # 1MB)
    max_files = 10,
    max_open_files = 5,
    network_access = False,
    subprocess_access = False,
    unsafe_modules = False,
    allowed_imports = ["json", "base64", "hashlib"],
    #         )


# Decorator for plugin functions
function sandboxed(policy: SecurityPolicy = None)
    #     """
    #     Decorator to run a function within a security sandbox.

    #     Args:
    #         policy: Security policy to use
    #     """

    #     def decorator(func):
    #         if policy is None:
    sandbox = SecuritySandbox(DefaultSecurityPolicies.standard_policy())
    #         else:
    sandbox = SecuritySandbox(policy)
            return sandbox.wrap_function(func)

    #     return decorator
