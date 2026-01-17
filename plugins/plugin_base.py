"""
NIP v3.0.0 Plugin Base System

This module provides the foundation for the NIP plugin system, including:
- Base Plugin class
- Plugin metadata management
- Plugin registry system
- Plugin loader and unloader
- Version management and dependency resolution
"""

from __future__ import annotations
import os
import sys
import json
import importlib.util
import inspect
from pathlib import Path
from typing import List, Dict, Any, Optional, Callable, Type
from dataclasses import dataclass, field
from datetime import datetime
import hashlib
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class PluginMetadata:
    """
    Metadata container for plugin information.
    
    Attributes:
        name: Unique plugin identifier
        version: Semantic version (e.g., "1.0.0")
        description: Human-readable description
        author: Plugin author
        plugin_type: "tool", "provider", "guard", or "hook"
        dependencies: List of required plugins with version constraints
        min_nip_version: Minimum NIP version required
        permissions: List of required permissions
        tags: Searchable tags
        homepage: Plugin homepage URL
        repository: Source repository URL
        license: License type
    """
    name: str
    version: str
    description: str
    author: str
    plugin_type: str
    dependencies: List[str] = field(default_factory=list)
    min_nip_version: str = "3.0.0"
    permissions: List[str] = field(default_factory=list)
    tags: List[str] = field(default_factory=list)
    homepage: str = ""
    repository: str = ""
    license: str = "MIT"
    
    def __post_init__(self):
        """Validate metadata after initialization."""
        if self.plugin_type not in ["tool", "provider", "guard", "hook"]:
            raise ValueError(f"Invalid plugin_type: {self.plugin_type}")
        
        if not self._is_valid_version(self.version):
            raise ValueError(f"Invalid version format: {self.version}")
    
    @staticmethod
    def _is_valid_version(version: str) -> bool:
        """Check if version follows semantic versioning."""
        parts = version.split(".")
        if len(parts) != 3:
            return False
        try:
            major, minor, patch = parts
            return all(p.isdigit() for p in [major, minor, patch])
        except ValueError:
            return False
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert metadata to dictionary."""
        return {
            "name": self.name,
            "version": self.version,
            "description": self.description,
            "author": self.author,
            "plugin_type": self.plugin_type,
            "dependencies": self.dependencies,
            "min_nip_version": self.min_nip_version,
            "permissions": self.permissions,
            "tags": self.tags,
            "homepage": self.homepage,
            "repository": self.repository,
            "license": self.license
        }


class PluginContext:
    """
    Context object passed to plugins providing access to NIP services.
    
    Provides:
    - Configuration access
    - Inter-plugin communication
    - Event system access
    - Shared resources
    """
    
    def __init__(self, registry: 'PluginRegistry'):
        self.registry = registry
        self.config: Dict[str, Any] = {}
        self.shared_state: Dict[str, Any] = {}
        self.logger = logger
    
    def get_config(self, key: str, default: Any = None) -> Any:
        """Get configuration value."""
        keys = key.split(".")
        value = self.config
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
            else:
                return default
        return value if value is not None else default
    
    def set_config(self, key: str, value: Any):
        """Set configuration value."""
        keys = key.split(".")
        config = self.config
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        config[keys[-1]] = value
    
    def get_plugin(self, plugin_name: str) -> Optional['Plugin']:
        """Get another loaded plugin by name."""
        return self.registry.get_plugin(plugin_name)
    
    def emit_event(self, event_name: str, data: Any = None):
        """Emit an event to all registered hooks."""
        self.registry.emit_event(event_name, data)


class Plugin:
    """
    Base class for all NIP plugins.
    
    All plugins must extend this class and implement the required methods.
    """
    
    def __init__(self, metadata: PluginMetadata):
        """
        Initialize the plugin.
        
        Args:
            metadata: Plugin metadata instance
        """
        if not isinstance(metadata, PluginMetadata):
            raise TypeError("metadata must be an instance of PluginMetadata")
        
        self.metadata = metadata
        self.enabled = True
        self.context: Optional[PluginContext] = None
        self._loaded = False
        self._tools: List[Dict[str, Any]] = []
        self._providers: List[Dict[str, Any]] = []
        self._guards: List[Dict[str, Any]] = []
        self._hooks: List[Dict[str, Any]] = []
    
    # Lifecycle methods
    
    def initialize(self):
        """
        Called when the plugin is loaded.
        
        Override this method to perform initialization tasks.
        """
        pass
    
    def enable(self):
        """
        Called when the plugin is enabled.
        
        Override this method to perform enable tasks.
        """
        self.enabled = True
    
    def disable(self):
        """
        Called when the plugin is disabled.
        
        Override this method to perform disable tasks.
        """
        self.enabled = False
    
    def cleanup(self):
        """
        Called before the plugin is unloaded.
        
        Override this method to clean up resources.
        """
        pass
    
    # Registration methods (override these)
    
    def register_tools(self) -> List[Dict[str, Any]]:
        """
        Register tool plugins.
        
        Returns:
            List of tool definitions
        """
        return []
    
    def register_providers(self) -> List[Dict[str, Any]]:
        """
        Register provider plugins.
        
        Returns:
            List of provider definitions
        """
        return []
    
    def register_guards(self) -> List[Dict[str, Any]]:
        """
        Register guard plugins.
        
        Returns:
            List of guard definitions
        """
        return []
    
    def register_hooks(self) -> List[Dict[str, Any]]:
        """
        Register hook plugins.
        
        Returns:
            List of hook definitions
        """
        return []
    
    # Utility methods
    
    def log_info(self, message: str):
        """Log an info message."""
        logger.info(f"[{self.metadata.name}] {message}")
    
    def log_error(self, message: str):
        """Log an error message."""
        logger.error(f"[{self.metadata.name}] {message}")
    
    def log_warning(self, message: str):
        """Log a warning message."""
        logger.warning(f"[{self.metadata.name}] {message}")
    
    def log_debug(self, message: str):
        """Log a debug message."""
        logger.debug(f"[{self.metadata.name}] {message}")
    
    def get_config(self, key: str, default: Any = None) -> Any:
        """Get configuration value from context."""
        if self.context:
            return self.context.get_config(key, default)
        return default
    
    def set_config(self, key: str, value: Any):
        """Set configuration value in context."""
        if self.context:
            self.context.set_config(key, value)
    
    def get_shared_state(self, key: str, default: Any = None) -> Any:
        """Get shared state value."""
        if self.context:
            return self.context.shared_state.get(key, default)
        return default
    
    def set_shared_state(self, key: str, value: Any):
        """Set shared state value."""
        if self.context:
            self.context.shared_state[key] = value


class PluginRegistry:
    """
    Central registry for managing loaded plugins.
    
    Handles:
    - Plugin registration and lookup
    - Dependency resolution
    - Event dispatching
    - Inter-plugin communication
    """
    
    def __init__(self):
        self.plugins: Dict[str, Plugin] = {}
        self.tools: Dict[str, Any] = {}
        self.providers: Dict[str, Any] = {}
        self.guards: Dict[str, Any] = {}
        self.hooks: Dict[str, List[Callable]] = {}
        self.context = PluginContext(self)
    
    def register(self, plugin: Plugin) -> bool:
        """
        Register a plugin in the registry.
        
        Args:
            plugin: Plugin instance to register
            
        Returns:
            True if registration successful
        """
        name = plugin.metadata.name
        
        if name in self.plugins:
            raise ValueError(f"Plugin '{name}' is already registered")
        
        # Check dependencies
        for dep in plugin.metadata.dependencies:
            dep_name = dep.split(">=")[0].split("==")[0].strip()
            if dep_name not in self.plugins:
                raise ValueError(f"Missing dependency: {dep}")
        
        # Set context
        plugin.context = self.context
        
        # Register components
        self.plugins[name] = plugin
        
        for tool in plugin._tools:
            tool_id = f"{name}.{tool['name']}"
            self.tools[tool_id] = tool
        
        for provider in plugin._providers:
            provider_id = f"{name}.{provider['name']}"
            self.providers[provider_id] = provider
        
        for guard in plugin._guards:
            guard_id = f"{name}.{guard['name']}"
            self.guards[guard_id] = guard
        
        for hook in plugin._hooks:
            event_name = hook['event']
            if event_name not in self.hooks:
                self.hooks[event_name] = []
            self.hooks[event_name].append(hook['handler'])
        
        plugin.log_info(f"Registered plugin '{name}' v{plugin.metadata.version}")
        return True
    
    def unregister(self, plugin_name: str) -> bool:
        """
        Unregister a plugin from the registry.
        
        Args:
            plugin_name: Name of plugin to unregister
            
        Returns:
            True if unregistration successful
        """
        if plugin_name not in self.plugins:
            raise ValueError(f"Plugin '{plugin_name}' is not registered")
        
        plugin = self.plugins[plugin_name]
        
        # Check if other plugins depend on this one
        for name, other_plugin in self.plugins.items():
            if name != plugin_name:
                for dep in other_plugin.metadata.dependencies:
                    if dep.startswith(plugin_name):
                        raise ValueError(
                            f"Cannot unregister: plugin '{name}' depends on '{plugin_name}'"
                        )
        
        # Remove components
        for tool_id in list(self.tools.keys()):
            if tool_id.startswith(f"{plugin_name}."):
                del self.tools[tool_id]
        
        for provider_id in list(self.providers.keys()):
            if provider_id.startswith(f"{plugin_name}."):
                del self.providers[provider_id]
        
        for guard_id in list(self.guards.keys()):
            if guard_id.startswith(f"{plugin_name}."):
                del self.guards[guard_id]
        
        for event_name in list(self.hooks.keys()):
            self.hooks[event_name] = [
                h for h in self.hooks[event_name]
                if not hasattr(h, '__self__') or 
                h.__self__.metadata.name != plugin_name
            ]
            if not self.hooks[event_name]:
                del self.hooks[event_name]
        
        del self.plugins[plugin_name]
        plugin.log_info(f"Unregistered plugin '{plugin_name}'")
        return True
    
    def get_plugin(self, plugin_name: str) -> Optional[Plugin]:
        """Get a plugin by name."""
        return self.plugins.get(plugin_name)
    
    def get_all_plugins(self) -> List[Plugin]:
        """Get all registered plugins."""
        return list(self.plugins.values())
    
    def emit_event(self, event_name: str, data: Any = None):
        """Emit an event to all registered hooks."""
        if event_name in self.hooks:
            for handler in self.hooks[event_name]:
                try:
                    handler(data)
                except Exception as e:
                    logger.error(f"Error in event handler: {e}")
    
    def get_tool(self, tool_id: str) -> Optional[Dict[str, Any]]:
        """Get a tool by ID."""
        return self.tools.get(tool_id)
    
    def get_all_tools(self) -> Dict[str, Any]:
        """Get all registered tools."""
        return self.tools.copy()
    
    def get_provider(self, provider_id: str) -> Optional[Dict[str, Any]]:
        """Get a provider by ID."""
        return self.providers.get(provider_id)
    
    def get_all_providers(self) -> Dict[str, Any]:
        """Get all registered providers."""
        return self.providers.copy()


class PluginLoader:
    """
    Handles loading and unloading of plugin files.
    
    Supports:
    - Loading plugins from Python files
    - Hot loading/unloading
    - Version checking
    - Dependency resolution
    """
    
    def __init__(self, registry: Optional[PluginRegistry] = None):
        """
        Initialize the plugin loader.
        
        Args:
            registry: Optional existing registry (creates new if None)
        """
        self.registry = registry or PluginRegistry()
        self.loaded_files: Dict[str, str] = {}  # file_path -> plugin_name
    
    def load_plugin(self, file_path: str) -> Optional[Plugin]:
        """
        Load a plugin from a Python file.
        
        Args:
            file_path: Path to the plugin file
            
        Returns:
            Loaded plugin instance or None if failed
        """
        path = Path(file_path)
        
        if not path.exists():
            raise FileNotFoundError(f"Plugin file not found: {file_path}")
        
        if not path.suffix == ".py":
            raise ValueError("Plugin file must be a Python file (.py)")
        
        # Load module
        spec = importlib.util.spec_from_file_location(path.stem, path)
        if spec is None or spec.loader is None:
            raise ImportError(f"Cannot load spec from {file_path}")
        
        module = importlib.util.module_from_spec(spec)
        sys.modules[path.stem] = module
        
        try:
            spec.loader.exec_module(module)
        except Exception as e:
            raise ImportError(f"Error executing plugin module: {e}")
        
        # Find Plugin class
        plugin_class = None
        for name, obj in inspect.getmembers(module, inspect.isclass):
            if issubclass(obj, Plugin) and obj is not Plugin:
                plugin_class = obj
                break
        
        if plugin_class is None:
            raise ValueError(f"No Plugin class found in {file_path}")
        
        # Instantiate plugin
        plugin = plugin_class()
        
        # Initialize plugin
        try:
            plugin.initialize()
        except Exception as e:
            logger.error(f"Error initializing plugin: {e}")
            raise
        
        # Register components
        plugin._tools = plugin.register_tools()
        plugin._providers = plugin.register_providers()
        plugin._guards = plugin.register_guards()
        plugin._hooks = plugin.register_hooks()
        
        # Register in registry
        self.registry.register(plugin)
        plugin._loaded = True
        self.loaded_files[str(path)] = plugin.metadata.name
        
        return plugin
    
    def unload_plugin(self, plugin_name: str) -> bool:
        """
        Unload a plugin.
        
        Args:
            plugin_name: Name of plugin to unload
            
        Returns:
            True if successful
        """
        plugin = self.registry.get_plugin(plugin_name)
        
        if plugin is None:
            raise ValueError(f"Plugin '{plugin_name}' is not loaded")
        
        if not plugin._loaded:
            raise ValueError(f"Plugin '{plugin_name}' is not loaded")
        
        # Cleanup plugin
        try:
            plugin.cleanup()
        except Exception as e:
            logger.error(f"Error during plugin cleanup: {e}")
        
        # Unregister from registry
        self.registry.unregister(plugin_name)
        
        # Remove from loaded files
        for file_path, name in list(self.loaded_files.items()):
            if name == plugin_name:
                del self.loaded_files[file_path]
                break
        
        plugin._loaded = False
        return True
    
    def reload_plugin(self, file_path: str) -> Optional[Plugin]:
        """
        Reload a plugin from file.
        
        Args:
            file_path: Path to plugin file
            
        Returns:
            Reloaded plugin instance
        """
        path = str(Path(file_path).resolve())
        
        if path not in self.loaded_files:
            return self.load_plugin(file_path)
        
        plugin_name = self.loaded_files[path]
        self.unload_plugin(plugin_name)
        return self.load_plugin(file_path)
    
    def get_registry(self) -> PluginRegistry:
        """Get the plugin registry."""
        return self.registry
    
    def load_from_directory(self, directory: str, pattern: str = "*.py") -> List[Plugin]:
        """
        Load all plugins from a directory.
        
        Args:
            directory: Directory path
            pattern: File pattern to match
            
        Returns:
            List of loaded plugins
        """
        dir_path = Path(directory)
        
        if not dir_path.exists():
            raise FileNotFoundError(f"Directory not found: {directory}")
        
        plugins = []
        for file_path in dir_path.glob(pattern):
            if file_path.is_file():
                try:
                    plugin = self.load_plugin(str(file_path))
                    if plugin:
                        plugins.append(plugin)
                except Exception as e:
                    logger.error(f"Error loading plugin from {file_path}: {e}")
        
        return plugins


class PluginValidator:
    """
    Validates plugin structure and metadata.
    
    Performs checks:
    - Metadata completeness
    - Version compatibility
    - Dependency validity
    - Schema validation
    """
    
    @staticmethod
    def validate_metadata(metadata: PluginMetadata) -> tuple[bool, List[str]]:
        """
        Validate plugin metadata.
        
        Args:
            metadata: PluginMetadata to validate
            
        Returns:
            Tuple of (is_valid, list_of_errors)
        """
        errors = []
        
        # Required fields
        if not metadata.name:
            errors.append("Plugin name is required")
        
        if not metadata.version:
            errors.append("Plugin version is required")
        
        if not metadata.description:
            errors.append("Plugin description is required")
        
        if not metadata.author:
            errors.append("Plugin author is required")
        
        if not metadata.plugin_type:
            errors.append("Plugin type is required")
        
        # Version format
        if metadata.version and not PluginMetadata._is_valid_version(metadata.version):
            errors.append(f"Invalid version format: {metadata.version}")
        
        # Plugin type
        if metadata.plugin_type not in ["tool", "provider", "guard", "hook"]:
            errors.append(f"Invalid plugin type: {metadata.plugin_type}")
        
        # Dependencies format
        for dep in metadata.dependencies:
            if not PluginValidator._is_valid_dependency(dep):
                errors.append(f"Invalid dependency format: {dep}")
        
        return (len(errors) == 0, errors)
    
    @staticmethod
    def _is_valid_dependency(dep: str) -> bool:
        """Check if dependency string is valid."""
        if ">=" in dep:
            parts = dep.split(">=")
            return len(parts) == 2 and all(parts)
        elif "==" in dep:
            parts = dep.split("==")
            return len(parts) == 2 and all(parts)
        else:
            return bool(dep.strip())
    
    @staticmethod
    def validate_plugin(plugin: Plugin) -> tuple[bool, List[str]]:
        """
        Validate a plugin instance.
        
        Args:
            plugin: Plugin instance to validate
            
        Returns:
            Tuple of (is_valid, list_of_errors)
        """
        errors = []
        
        # Validate metadata
        valid, meta_errors = PluginValidator.validate_metadata(plugin.metadata)
        if not valid:
            errors.extend(meta_errors)
        
        # Check if required methods are callable
        if not callable(plugin.initialize):
            errors.append("initialize() must be callable")
        
        if not callable(plugin.enable):
            errors.append("enable() must be callable")
        
        if not callable(plugin.disable):
            errors.append("disable() must be callable")
        
        if not callable(plugin.cleanup):
            errors.append("cleanup() must be callable")
        
        return (len(errors) == 0, errors)


# Convenience functions for easy access

def create_plugin(metadata: PluginMetadata) -> Plugin:
    """
    Factory function to create a plugin instance.
    
    Args:
        metadata: Plugin metadata
        
    Returns:
        Plugin instance
    """
    return Plugin(metadata)


def load_plugin(file_path: str) -> Optional[Plugin]:
    """
    Convenience function to load a plugin.
    
    Args:
        file_path: Path to plugin file
        
    Returns:
        Loaded plugin or None
    """
    loader = PluginLoader()
    return loader.load_plugin(file_path)


def create_plugin_loader() -> PluginLoader:
    """
    Factory function to create a plugin loader.
    
    Returns:
        PluginLoader instance
    """
    return PluginLoader()
