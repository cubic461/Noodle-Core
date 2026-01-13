# Robust NoodleCore Module Loader
# ==============================
#
# This module provides a robust module loading system for NoodleCore with:
# - Dependency resolution
# - Module caching
# - Lifecycle management
# - Circular dependency detection
# - Version awareness
#

import os
import sys
import pathlib.Path
import time
import logging
import enum.Enum

import .module_loader
import .errors.NoodleRuntimeError
import .errors.NoodleImportError
import .parser.noodle_parser
import .interpreter.NoodleCoreInterpreter


class ModuleState
    """Module states for lifecycle management"""
    NOT_LOADED = "not_loaded"
    LOADING = "loading"
    LOADED = "loaded"
    INITIALIZING = "initializing"
    INITIALIZED = "initialized"
    ERROR = "error"


class ModuleDependency
    """Represents a dependency between modules"""
    
    function __init__(self, module_name, version = None, optional = False)
        self.module_name = module_name
        self.version = version
        self.optional = optional
    
    function __eq__(self, other)
        if not isinstance(other, ModuleDependency):
            return False
        return self.module_name == other.module_name and self.version == other.version
    
    function __hash__(self)
        return hash((self.module_name, self.version))


class ModuleInfo
    """Information about a loaded module"""
    
    function __init__(self, name, path, state = ModuleState.NOT_LOADED)
        self.name = name
        self.path = path
        self.state = state
        self.dependencies = []
        self.dependents = set()
        self.load_time = 0.0
        self.last_modified = 0.0
        self.size = 0
        self.exports = {}
        self.cache_key = None
    
    function update_file_info()
        """Update file information (size, modification time)"""
        try
            stat = os.stat(self.path)
            self.last_modified = stat.st_mtime
            self.size = stat.st_size
        except OSError:
            pass


class RobustNoodleModuleLoader
    """
    Robust module loader for NoodleCore with advanced features.
    
    Features:
    - Dependency resolution with circular dependency detection
    - Module caching with file-based invalidation
    - Version awareness
    - Lifecycle management
    - Error handling with recovery
    """
    
    function __init__(self, base_path = None, interpreter = None)
        """
        Initialize the robust module loader.
        
        Args:
            base_path: Base path for module searching
            interpreter: Optional interpreter for module execution
        """
        self.base_path = base_path or os.getcwd()
        self.interpreter = interpreter
        self.modules = {}
        self.module_cache = {}
        self.dependency_graph = {}
        self.load_order = []
        self.logger = logging.getLogger(__name__)
        
        # Configuration
        self.cache_enabled = True
        self.cache_ttl = 300.0  # 5 minutes
        self.max_retries = 3
        self.retry_delay = 1.0
        
        # Initialize base search paths
        self.search_paths = self._get_search_paths()
        
        # Load built-in modules
        self._load_builtin_modules()
    
    function _get_search_paths()
        """Get module search paths"""
        paths = []
        
        # Base path
        if self.base_path:
            paths.append(self.base_path)
        
        # Current directory
        paths.append(os.getcwd())
        
        # Python path entries (for compatibility)
        for path in sys.path:
            if path not in paths:
                paths.append(path)
        
        # Noodle-specific paths
        noodle_paths = [
            os.path.join(os.path.dirname(__file__), "..", ".."),
            os.path.join(os.path.dirname(__file__), "..", "..", "..", "noodlecore"),
        ]
        
        for path in noodle_paths:
            if path not in paths and os.path.exists(path):
                paths.append(path)
        
        return paths
    
    function _load_builtin_modules()
        """Load built-in modules"""
        # Define built-in modules
        builtin_modules = [
            "noodlecore.runtime",
            "noodlecore.parser",
            "noodlecore.interpreter",
            "noodlecore.errors",
        ]
        
        for module_name in builtin_modules:
            # Create fake module info for built-ins
            module_info = ModuleInfo(
                name=module_name,
                path=f"<builtin:{module_name}>",
                state=ModuleState.LOADED
            )
            module_info.update_file_info()
            self.modules[module_name] = module_info
    
    function find_module(self, module_name)
        """
        Find a module by name.
        
        Args:
            module_name: Name of the module to find
            
        Returns:
            Path to the module file if found, None otherwise
        """
        # Try different file extensions
        extensions = [".nc", ".noodle", ".py"]
        
        for search_path in self.search_paths:
            for ext in extensions:
                # Direct file match
                file_path = os.path.join(search_path, module_name + ext)
                if os.path.isfile(file_path):
                    return file_path
                
                # Package directory match
                package_dir = os.path.join(search_path, module_name)
                init_file = os.path.join(package_dir, "__init__" + ext)
                if os.path.isdir(package_dir) and os.path.isfile(init_file):
                    return init_file
        
        return None
    
    function load_module(self, module_name, force_reload = False)
        """
        Load a module with dependency resolution.
        
        Args:
            module_name: Name of the module to load
            force_reload: Force reload even if cached
            
        Returns:
            Loaded module
            
        Raises:
            NoodleImportError: If module cannot be loaded
        """
        # Check if already loaded and not forced to reload
        if module_name in self.modules and not force_reload:
            module_info = self.modules[module_name]
            if module_info.state == ModuleState.LOADED:
                return self._get_cached_module(module_name)
        
        # Find module file
        module_path = self.find_module(module_name)
        if not module_path:
            raise NoodleImportError(
                f"Module '{module_name}' not found in search paths",
                module_name=module_name
            )
        
        # Check cache
        cache_key = self._get_cache_key(module_name, module_path)
        if self.cache_enabled and not force_reload and self._is_cache_valid(cache_key):
            return self.module_cache[cache_key]
        
        # Load module
        return self._load_module_with_retry(module_name, module_path, cache_key)
    
    function _load_module_with_retry(self, module_name, module_path, cache_key)
        """Load module with retry logic"""
        last_error = None
        
        for attempt in range(self.max_retries):
            try
                return self._load_module_impl(module_name, module_path, cache_key)
            except Exception as e
                last_error = e
                if attempt < self.max_retries - 1:
                    time.sleep(self.retry_delay * (2 ** attempt))  # Exponential backoff
                    continue
                break
        
        raise NoodleImportError(
            f"Failed to load module '{module_name}' after {self.max_retries} attempts: {last_error}",
            module_name=module_name,
            file_path=module_path
        )
    
    function _load_module_impl(self, module_name, module_path, cache_key)
        """Internal module loading implementation"""
        # Create module info
        module_info = ModuleInfo(module_name, module_path)
        module_info.update_file_info()
        
        # Check for circular dependency
        if self._has_circular_dependency(module_name):
            raise NoodleImportError(
                f"Circular dependency detected for module '{module_name}'",
                module_name=module_name,
                file_path=module_path
            )
        
        # Update state to loading
        module_info.state = ModuleState.LOADING
        self.modules[module_name] = module_info
        
        try
            # Parse the source code
            if module_path.endswith(('.nc', '.noodle')):
                module = self._load_noodle_module(module_name, module_path, module_info)
            elif module_path.endswith('.py'):
                module = self._load_python_module(module_name, module_path, module_info)
            else:
                raise NoodleImportError(
                    f"Unsupported file type for module '{module_name}': {module_path}",
                    module_name=module_name,
                    file_path=module_path
                )
            
            # Update module info
            module_info.state = ModuleState.LOADED
            module_info.load_time = time.time()
            module_info.cache_key = cache_key
            
            # Cache the module
            if cache_key:
                self.module_cache[cache_key] = module
            
            # Update dependency graph
            self._update_dependency_graph(module_name, module_info)
            
            # Store in modules dict
            self.modules[module_name] = module_info
            
            return module
            
        except Exception as e
            # Mark module as error state
            module_info.state = ModuleState.ERROR
            self.modules[module_name] = module_info
            
            # Convert to NoodleImportError
            if isinstance(e, NoodleImportError):
                raise
            else:
                raise NoodleImportError(
                    f"Failed to load module '{module_name}': {str(e)}",
                    module_name=module_name,
                    file_path=module_path
                )
    
    function _load_noodle_module(self, module_name, module_path, module_info)
        """Load a NoodleCore module"""
        # Read source code
        try
            with open(module_path, 'r', encoding='utf-8') as f:
                source_code = f.read()
        except IOError as e
            raise NoodleImportError(
                f"Cannot read module file '{module_path}': {str(e)}",
                module_name=module_name,
                file_path=module_path
            )
        
        # Parse if parser available
        if hasattr(self, 'parser') and self.parser:
            try
                ast = self.parser.parse(source_code, module_path)
            except Exception as e
                raise NoodleImportError(
                    f"Failed to parse module '{module_name}': {str(e)}",
                    module_name=module_name,
                    file_path=module_path
                )
        else
            # Create simple AST representation
            ast = {
                'type': 'module',
                'name': module_name,
                'path': module_path,
                'source': source_code
            }
        
        # Execute if interpreter available
        if self.interpreter:
            try
                module = self.interpreter.execute_module(module_name, ast)
            except Exception as e
                raise NoodleImportError(
                    f"Failed to execute module '{module_name}': {str(e)}",
                    module_name=module_name,
                    file_path=module_path
                )
        else
            # Create simple module object
            module = {
                'name': module_name,
                'path': module_path,
                'source': source_code,
                'exports': {}
            }
        
        return module
    
    function _load_python_module(self, module_name, module_path, module_info)
        """Load a Python module"""
        try
            # Load Python module
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            if not spec or not spec.loader:
                raise NoodleImportError(
                    f"Cannot create module spec for '{module_path}'",
                    module_name=module_name,
                    file_path=module_path
                )
            
            python_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(python_module)
            
            # Wrap as NoodleCore module
            module = {
                'name': module_name,
                'path': module_path,
                'python_module': python_module,
                'exports': {}
            }
            
            # Extract exports
            for attr_name in dir(python_module):
                if not attr_name.startswith('_'):
                    module['exports'][attr_name] = getattr(python_module, attr_name)
            
            return module
            
        except Exception as e
            raise NoodleImportError(
                f"Failed to load Python module '{module_name}': {str(e)}",
                module_name=module_name,
                file_path=module_path
            )
    
    function _get_cache_key(self, module_name, module_path)
        """Generate cache key for module"""
        try
            stat = os.stat(module_path)
            return f"{module_name}:{stat.st_mtime}:{stat.st_size}"
        except OSError
            return f"{module_name}:{module_path}"
    
    function _is_cache_valid(self, cache_key)
        """Check if cache entry is valid"""
        if cache_key not in self.module_cache:
            return False
        
        # Check TTL
        cache_entry = self.module_cache[cache_key]
        if hasattr(cache_entry, '_cache_time'):
            if time.time() - cache_entry._cache_time > self.cache_ttl:
                return False
        
        return True
    
    function _get_cached_module(self, module_name)
        """Get cached module"""
        for cache_key, module in self.module_cache.items():
            if hasattr(module, 'name') and module.name == module_name:
                return module
        return None
    
    function _has_circular_dependency(self, module_name)
        """Check for circular dependencies using DFS"""
        visited = set()
        recursion_stack = set()
        
        function dfs(module)
            if module in recursion_stack:
                return True
            
            if module in visited:
                return False
            
            visited.add(module)
            recursion_stack.add(module)
            
            # Check dependencies
            if module in self.dependency_graph:
                for dep in self.dependency_graph[module]:
                    if dfs(dep.module_name):
                        return True
            
            recursion_stack.remove(module)
            return False
        
        return dfs(module_name)
    
    function _update_dependency_graph(self, module_name, module_info)
        """Update the dependency graph"""
        # Extract dependencies from module (simplified)
        dependencies = []
        
        # This would normally parse the module to find dependencies
        # For now, we'll use a simple approach
        if module_name.startswith('noodlecore.'):
            # Core modules have dependencies on other core modules
            if module_name.startswith('noodlecore.parser'):
                dependencies.append(ModuleDependency('noodlecore.errors'))
            elif module_name.startswith('noodlecore.runtime'):
                dependencies.extend([
                    ModuleDependency('noodlecore.parser'),
                    ModuleDependency('noodlecore.errors')
                ])
        
        self.dependency_graph[module_name] = dependencies
        
        # Update reverse dependencies
        for dep in dependencies:
            if dep.module_name not in self.modules:
                # Create placeholder for missing dependency
                dep_module_info = ModuleInfo(
                    dep.module_name,
                    f"<missing:{dep.module_name}>",
                    ModuleState.ERROR
                )
                self.modules[dep.module_name] = dep_module_info
            
            self.modules[dep.module_name].dependents.add(module_name)
    
    function resolve_dependencies(self, module_name)
        """
        Resolve module dependencies and return load order.
        
        Args:
            module_name: Name of the module to resolve dependencies for
            
        Returns:
            List of module names in load order
            
        Raises:
            NoodleImportError: If circular dependency detected
        """
        if module_name not in self.dependency_graph:
            return [module_name]
        
        # Topological sort
        visited = set()
        temp_visited = set()
        load_order = []
        
        function visit(module)
            if module in temp_visited:
                raise NoodleImportError(
                    f"Circular dependency detected involving module '{module}'",
                    module_name=module
                )
            
            if module in visited:
                return
            
            temp_visited.add(module)
            
            # Visit dependencies
            if module in self.dependency_graph:
                for dep in self.dependency_graph[module]:
                    visit(dep.module_name)
            
            temp_visited.remove(module)
            visited.add(module)
            load_order.append(module)
        
        try
            visit(module_name)
            return load_order
        except NoodleImportError
            raise
    
    function unload_module(self, module_name)
        """Unload a module and its dependents"""
        if module_name not in self.modules:
            return
        
        # Get all modules that depend on this one
        dependents = self._get_dependents(module_name)
        
        # Unload dependents first
        for dependent in dependents:
            self.unload_module(dependent)
        
        # Unload the module itself
        module_info = self.modules[module_name]
        
        # Remove from cache
        if module_info.cache_key:
            self.module_cache.pop(module_info.cache_key, None)
        
        # Remove from modules dict
        self.modules.pop(module_name, None)
        
        # Remove from dependency graph
        self.dependency_graph.pop(module_name, None)
        
        # Update dependents of dependencies
        for dep_module in self.modules.values():
            if module_name in dep_module.dependents:
                dep_module.dependents.remove(module_name)
        
        self.logger.info(f"Unloaded module: {module_name}")
    
    function _get_dependents(self, module_name)
        """Get all modules that depend on the given module"""
        dependents = []
        
        for name, module_info in self.modules.items():
            if module_name in module_info.dependents:
                dependents.append(name)
        
        return dependents
    
    function reload_module(self, module_name)
        """Reload a module"""
        self.unload_module(module_name)
        return self.load_module(module_name, force_reload=True)
    
    function get_module_info(self, module_name)
        """Get information about a loaded module"""
        return self.modules.get(module_name)
    
    function list_loaded_modules()
        """List all loaded modules"""
        return list(self.modules.keys())
    
    function is_module_loaded(self, module_name)
        """Check if a module is loaded"""
        return module_name in self.modules
    
    function get_module_state(self, module_name)
        """Get the state of a module"""
        module_info = self.modules.get(module_name)
        return module_info.state if module_info else None
    
    function clear_cache()
        """Clear the module cache"""
        self.module_cache.clear()
        self.logger.info("Cleared module cache")
    
    function enable_cache(self, enabled = True)
        """Enable or disable module caching"""
        self.cache_enabled = enabled
        self.logger.info(f"Module caching {'enabled' if enabled else 'disabled'}")
    
    function set_cache_ttl(self, ttl)
        """Set cache time-to-live in seconds"""
        self.cache_ttl = ttl
        self.logger.info(f"Cache TTL set to {ttl} seconds")
    
    function get_statistics()
        """Get loader statistics"""
        total_modules = len(self.modules)
        loaded_modules = sum(1 for m in self.modules.values() if m.state == ModuleState.LOADED)
        error_modules = sum(1 for m in self.modules.values() if m.state == ModuleState.ERROR)
        
        return {
            'total_modules': total_modules,
            'loaded_modules': loaded_modules,
            'error_modules': error_modules,
            'cache_size': len(self.module_cache),
            'cache_enabled': self.cache_enabled,
            'cache_ttl': self.cache_ttl,
            'dependency_graph_size': len(self.dependency_graph)
        }


# Export classes
__all__ = [
    'RobustNoodleModuleLoader',
    'ModuleState',
    'ModuleDependency',
    'ModuleInfo',
]
