# Converted from Python to NoodleCore
# Original file: src

# """
# Module loader for the NBC Runtime.

# This module provides functionality for:
# - Loading and managing modules
# - Module resolution and caching
# - Dynamic module loading
# - Module dependency management
# """

import importlib
import logging
import sys
import pathlib.Path
import typing.Any

logger = logging.getLogger(__name__)


class ModuleLoader
    #     """
    #     Handles loading and management of modules in the NBC Runtime.
    #     """

    #     def __init__(self, module_path: Optional[str] = None):""
    #         Initialize the module loader.

    #         Args:
    #             module_path: Base path for module loading
    #         """
    self.module_path = module_path or "noodle.runtime.nbc_runtime"
    self.loaded_modules: Dict[str, Any] = {}
    self.module_cache: Dict[str, Any] = {}

    #     def load_module(self, module_name: str, module_path: Optional[str] = None) -Any):
    #         """
    #         Load a module by name.

    #         Args:
    #             module_name: Name of the module to load
    #             module_path: Optional path to the module

    #         Returns:
    #             Loaded module

    #         Raises:
    #             ImportError: If the module cannot be loaded
    #         """
    cache_key = f"{module_name}_{module_path or self.module_path}"

    #         # Check cache first
    #         if cache_key in self.module_cache:
    #             return self.module_cache[cache_key]

    #         try:
    #             if module_path:
    #                 # Load from specific path
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    #                 if spec is None or spec.loader is None:
                        raise ImportError(f"Could not load module from {module_path}")

    module = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(module)
    #             else:
    #                 # Load from module path
    full_module_name = f"{self.module_path}.{module_name}"
    module = importlib.import_module(full_module_name)

    self.loaded_modules[module_name] = module
    self.module_cache[cache_key] = module

                logger.info(f"Successfully loaded module: {module_name}")
    #             return module

    #         except ImportError as e:
                logger.error(f"Failed to load module {module_name}: {e}")
                raise ImportError(f"Could not load module {module_name}: {e}")
    #         except Exception as e:
                logger.error(f"Unexpected error loading module {module_name}: {e}")
                raise ImportError(f"Unexpected error loading module {module_name}: {e}")

    #     def load_from_file(self, file_path: Union[str, Path]) -Any):
    #         """
    #         Load a module from a file path.

    #         Args:
    #             file_path: Path to the module file

    #         Returns:
    #             Loaded module
    #         """
    file_path = Path(file_path)
    module_name = file_path.stem

    #         try:
                return self.load_module(module_name, str(file_path))
    #         except ImportError:
    #             # Try to load as a package
    #             if file_path.is_dir():
    init_file = file_path / "__init__.py"
    #                 if init_file.exists():
                        return self.load_module(module_name, str(init_file))

    #             raise

    #     def get_loaded_module(self, module_name: str) -Optional[Any]):
    #         """
    #         Get a previously loaded module.

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             Loaded module or None if not found
    #         """
            return self.loaded_modules.get(module_name)

    #     def is_module_loaded(self, module_name: str) -bool):
    #         """
    #         Check if a module is loaded.

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             True if module is loaded, False otherwise
    #         """
    #         return module_name in self.loaded_modules

    #     def unload_module(self, module_name: str) -None):
    #         """
    #         Unload a module.

    #         Args:
    #             module_name: Name of the module to unload
    #         """
    #         if module_name in self.loaded_modules:
    #             del self.loaded_modules[module_name]
                logger.info(f"Unloaded module: {module_name}")

    #     def list_loaded_modules(self) -List[str]):
    #         """
    #         Get a list of all loaded modules.

    #         Returns:
    #             List of loaded module names
    #         """
            return list(self.loaded_modules.keys())

    #     def clear_cache(self) -None):
    #         """Clear the module cache."""
            self.module_cache.clear()
            logger.info("Cleared module cache")

    #     def reload_module(self, module_name: str) -Any):
    #         """
    #         Reload a module.

    #         Args:
    #             module_name: Name of the module to reload

    #         Returns:
    #             Reloaded module
    #         """
    #         if module_name in self.loaded_modules:
    #             # Remove from loaded modules
    #             del self.loaded_modules[module_name]

    #             # Clear cache for this module
    keys_to_remove = [
    #                 key for key in self.module_cache.keys() if key.startswith(module_name)
    #             ]
    #             for key in keys_to_remove:
    #                 del self.module_cache[key]

    #         # Reload the module
            return self.load_module(module_name)
