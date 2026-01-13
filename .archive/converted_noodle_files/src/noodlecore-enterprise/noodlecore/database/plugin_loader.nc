# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Database Plugin Loader
# -----------------------
# Dynamic loading system for database backends.
# Discovers and instantiates backend plugins from the backends directory.
# Supports FFI for non-Python backends if needed.
# """

import importlib
import importlib.util
import os
import sys
import pathlib.Path
import typing.Any,

import .backends.__path__
import .backends.base.BackendConfig,


class PluginLoaderError(Exception)
    #     """Exception raised during plugin loading."""

    #     pass


class DatabasePluginLoader
    #     """
    #     Loads database backend plugins dynamically.
    #     Scans the backends directory for Python modules that subclass DatabaseBackend.
    #     Provides registry for runtime backend selection.
    #     """

    #     def __init__(self, backends_dir: Optional[Path] = None):
    #         if backends_dir is None:
    #             # Default to the backends package directory
    backends_dir = Path(backends_path[0])
    self.backends_dir = backends_dir
    self.loaded_backends: Dict[str, Type[DatabaseBackend]] = {}
    self.instances: Dict[str, DatabaseBackend] = {}
            self.load_all_backends()

    #     def load_all_backends(self) -> None:
    #         """Discover and load all backend plugins."""
    #         for file in self.backends_dir.glob("*.py"):
    #             if file.name.startswith("__") or file.name == "base.py":
    #                 continue
    module_name = file.stem
    #             try:
    spec = importlib.util.spec_from_file_location(module_name, file)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
                    spec.loader.exec_module(module)

    #                 # Find subclasses of DatabaseBackend
    #                 for name, obj in vars(module).items():
    #                     if (
                            isinstance(obj, type)
                            and issubclass(obj, DatabaseBackend)
    and obj ! = DatabaseBackend
    #                     ):
    backend_name = getattr(obj, "backend_name", module_name)
    self.loaded_backends[backend_name] = obj
    #                         if self._has_ffi_support(obj):
                                print(f"Loaded FFI backend: {backend_name}")
    #                         else:
                                print(f"Loaded Python backend: {backend_name}")
    #             except Exception as e:
    #                 # Skip backends with import issues for now
                    print(f"Warning: Failed to load backend {module_name}: {e}")
    #                 continue

    #     def _has_ffi_support(self, backend_class: Type[DatabaseBackend]) -> bool:
    #         """Check if backend supports FFI (e.g., has ffi_init method)."""
            return hasattr(backend_class, "ffi_init") or "ffi" in backend_class.__module__

    #     def get_available_backends(self) -> List[str]:
    #         """Get list of loaded backend names."""
            return list(self.loaded_backends.keys())

    #     def load_backend(self, backend_name: str, config: BackendConfig) -> DatabaseBackend:
    #         """Load and instantiate a backend by name."""
    #         if backend_name not in self.loaded_backends:
                raise PluginLoaderError(f"Backend {backend_name} not found")

    #         backend_class = self.loaded_backends[backend_name]
    instance = backend_class(config)

    #         # Initialize FFI if supported
    #         if self._has_ffi_support(backend_class):
    #             instance.ffi_init()  # Assume this method exists for FFI setup

    self.instances[backend_name] = instance
    #         return instance

    #     def get_backend(self, backend_name: str) -> Optional[DatabaseBackend]:
    #         """Get an already loaded backend instance."""
            return self.instances.get(backend_name)

    #     def unload_backend(self, backend_name: str) -> None:
    #         """Unload a backend and close connections."""
    #         if backend_name in self.instances:
    backend = self.instances[backend_name]
                backend.disconnect()
    #             del self.instances[backend_name]

    #     def list_backends(self) -> Dict[str, Dict[str, Any]]:
    #         """List all loaded backends with metadata."""
    info = {}
    #         for name, cls in self.loaded_backends.items():
    info[name] = {
    #                 "class": cls.__name__,
    #                 "module": cls.__module__,
                    "has_ffi": self._has_ffi_support(cls),
                    "config_params": getattr(cls, "required_config", []),
    #             }
    #         return info


# Global loader instance
loader = DatabasePluginLoader()


def get_plugin_loader() -> DatabasePluginLoader:
#     """Get the global plugin loader."""
#     return loader
