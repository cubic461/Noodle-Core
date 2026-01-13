# Converted from Python to NoodleCore
# Original file: src

# """
# Module Loader for Noodle Runtime

# This module provides functionality for loading and managing Python modules
# within the Noodle runtime environment.
# """

import importlib
import importlib.util
import logging
import os
import sys
import pathlib.Path
import typing.Any

logger = logging.getLogger(__name__)


class ModuleLoader
    #     """
    #     Handles loading of Python modules with support for:
    #     - Dynamic module loading from file paths
    #     - Module caching and reloading
    #     - Namespace management
    #     - Error handling for failed loads
    #     """

    #     def __init__(self, namespace: Optional[str] = None):
    #         """
    #         Initialize the module loader.

    #         Args:
    #             namespace: Optional namespace for loaded modules
    #         """
    self.namespace = namespace
    self.loaded_modules: Dict[str, Any] = {}
    self.module_paths: Dict[str, Path] = {}

    #     def load_module_from_path(
    #         self, module_name: str, file_path: Union[str, Path]
    #     ) -Any):
    #         """
    #         Load a module from a file path.

    #         Args:
    #             module_name: Name to assign to the loaded module
    #             file_path: Path to the Python file to load

    #         Returns:
    #             The loaded module

    #         Raises:
    #             ImportError: If the module cannot be loaded
    #             FileNotFoundError: If the file doesn't exist
    #         """
    file_path = Path(file_path)

    #         if not file_path.exists():
                raise FileNotFoundError(f"Module file not found: {file_path}")

    #         if not file_path.suffix == ".py":
                raise ImportError(f"Only Python files (.py) can be loaded: {file_path}")

    #         try:
    #             # Create module spec
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    #             if spec is None or spec.loader is None:
    #                 raise ImportError(f"Could not create module spec for {file_path}")

    #             # Load the module
    module = importlib.util.module_from_spec(spec)

    #             # Add to sys.modules to prevent duplicate loading
    #             if module_name not in sys.modules:
    sys.modules[module_name] = module

    #             # Execute the module
                spec.loader.exec_module(module)

    #             # Track loaded module
    self.loaded_modules[module_name] = module
    self.module_paths[module_name] = file_path

                logger.info(f"Successfully loaded module: {module_name} from {file_path}")
    #             return module

    #         except Exception as e:
                logger.error(f"Failed to load module {module_name} from {file_path}: {e}")
                raise ImportError(f"Failed to load module {module_name}: {e}")

    #     def load_module_from_directory(
    #         self, module_name: str, directory: Union[str, Path]
    #     ) -Any):
    #         """
    #         Load a module from a directory (looks for __init__.py).

    #         Args:
    #             module_name: Name to assign to the loaded module
    #             directory: Path to the directory containing the module

    #         Returns:
    #             The loaded module

    #         Raises:
    #             ImportError: If the module cannot be loaded
    #             FileNotFoundError: If the directory doesn't exist
    #         """
    directory = Path(directory)

    #         if not directory.exists():
                raise FileNotFoundError(f"Directory not found: {directory}")

    init_file = directory / "__init__.py"
    #         if not init_file.exists():
                raise ImportError(f"No __init__.py found in directory: {directory}")

            return self.load_module_from_path(module_name, init_file)

    #     def reload_module(self, module_name: str) -Any):
    #         """
    #         Reload a previously loaded module.

    #         Args:
    #             module_name: Name of the module to reload

    #         Returns:
    #             The reloaded module

    #         Raises:
    #             ImportError: If the module cannot be reloaded
    #             KeyError: If the module was not previously loaded
    #         """
    #         if module_name not in self.loaded_modules:
                raise KeyError(f"Module {module_name} was not previously loaded")

    file_path = self.module_paths[module_name]

    #         try:
    #             # Remove from sys.modules to force reload
    #             if module_name in sys.modules:
    #                 del sys.modules[module_name]

    #             # Reload the module
                return self.load_module_from_path(module_name, file_path)

    #         except Exception as e:
                logger.error(f"Failed to reload module {module_name}: {e}")
                raise ImportError(f"Failed to reload module {module_name}: {e}")

    #     def get_module(self, module_name: str) -Any):
    #         """
    #         Get a previously loaded module.

    #         Args:
    #             module_name: Name of the module to retrieve

    #         Returns:
    #             The loaded module

    #         Raises:
    #             KeyError: If the module was not loaded
    #         """
    #         if module_name not in self.loaded_modules:
                raise KeyError(f"Module {module_name} was not loaded")

    #         return self.loaded_modules[module_name]

    #     def is_module_loaded(self, module_name: str) -bool):
    #         """
    #         Check if a module is loaded.

    #         Args:
    #             module_name: Name of the module to check

    #         Returns:
    #             True if the module is loaded, False otherwise
    #         """
    #         return module_name in self.loaded_modules

    #     def unload_module(self, module_name: str) -None):
    #         """
    #         Unload a module.

    #         Args:
    #             module_name: Name of the module to unload

    #         Raises:
    #             KeyError: If the module was not loaded
    #         """
    #         if module_name not in self.loaded_modules:
                raise KeyError(f"Module {module_name} was not loaded")

    #         # Remove from sys.modules
    #         if module_name in sys.modules:
    #             del sys.modules[module_name]

    #         # Remove from tracking
    #         del self.loaded_modules[module_name]
    #         del self.module_paths[module_name]

            logger.info(f"Unloaded module: {module_name}")

    #     def list_loaded_modules(self) -List[str]):
    #         """
    #         Get a list of all loaded module names.

    #         Returns:
    #             List of loaded module names
    #         """
            return list(self.loaded_modules.keys())

    #     def get_module_info(self, module_name: str) -Dict[str, Any]):
    #         """
    #         Get information about a loaded module.

    #         Args:
    #             module_name: Name of the module to get info for

    #         Returns:
    #             Dictionary containing module information

    #         Raises:
    #             KeyError: If the module was not loaded
    #         """
    #         if module_name not in self.loaded_modules:
                raise KeyError(f"Module {module_name} was not loaded")

    module = self.loaded_modules[module_name]
    file_path = self.module_paths[module_name]

    #         return {
    #             "name": module_name,
                "file_path": str(file_path),
    #             "module": module,
    #             "namespace": self.namespace,
                "loaded_at": getattr(module, "__file__", None),
                "docstring": getattr(module, "__doc__", None),
    #         }


# Global module loader instance
_default_loader = ModuleLoader()


def load_profiling_config(config_path: Optional[str] = None) -Dict[str, Any]):
#     """
#     Load profiling configuration from a file.

#     Args:
#         config_path: Path to the configuration file

#     Returns:
#         Configuration dictionary
#     """
#     if config_path is None:
#         # Default configuration
#         return {
#             "enabled": False,
#             "sampling_rate": 1000,
#             "max_depth": 10,
#             "include_threading": True,
#             "include_memory": True,
#             "output_format": "json",
#         }

#     try:
#         import json

#         with open(config_path, "r") as f:
            return json.load(f)
#     except Exception as e:
        logger.warning(f"Failed to load profiling config from {config_path}: {e}")
#         return {}


function NoodleProfiler(*args, **kwargs)
    #     """
    #     Placeholder for NoodleProfiler.

    #     This is a compatibility function that will be replaced with the actual
    #     profiler implementation when available.
    #     """
        logger.warning("NoodleProfiler placeholder - actual implementation not available")

    #     class Profiler:
    #         def __init__(self, *args, **kwargs):
    self.enabled = False
    self.config = {}

    #         def start(self):
    #             pass

    #         def stop(self):
    #             pass

    #         def get_stats(self):
    #             return {}

    #         def reset(self):
    #             pass

        return Profiler(*args, **kwargs)


# Export public API
__all__ = [
#     "ModuleLoader",
#     "load_profiling_config",
#     "NoodleProfiler",
# ]
