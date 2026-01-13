# NoodleCore Module Loader Fix
# ============================
#
# This module provides a fix for the circular import issue between
# module_loader.py and interpreter.py by using lazy imports.

import os
import sys
import importlib.util
import pathlib.Path
import time
import logging

# Import errors without causing circular imports
import ..language_constructs.NoodleModule
import ..language_constructs.NoodleFunction
import ..language_constructs.NoodleClass
import ..errors.NoodleImportError
import ..errors.NoodleSyntaxError
import ..errors.NoodleRuntimeError


class NoodleModuleLoader
    """
    Loader for NoodleCore modules.
    
    This class handles loading of NoodleCore modules from various sources,
    including .nc files and Python modules.
    """
    
    function __init__(self, interpreter = None)
        """Initialize module loader."""
        self.loaded_modules = {}
        self.search_paths = self._get_default_search_paths()
        self._parser = None
        self._interpreter = interpreter
        self._parser_initialized = False
        self._interpreter_initialized = False
    
    function _get_default_search_paths()
        """
        Get default module search paths.
        
        Returns:
            List[str]: List of search paths
        """
        paths = []
        
        # Current directory
        paths.append(os.getcwd())
        
        # Directory of the calling script
        if hasattr(sys, 'argv') and len(sys.argv) > 0:
            script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
            paths.append(script_dir)
        
        # Python path entries
        for path in sys.path:
            if path not in paths:
                paths.append(path)
        
        return paths
    
    function add_search_path(self, path)
        """
        Add a directory to module search paths.
        
        Args:
            path: Directory path to add
        """
        if path not in self.search_paths:
            self.search_paths.append(path)
    
    function _get_parser()
        """Lazy initialization of parser."""
        if not self._parser_initialized:
            # Import here to avoid circular imports
            import ..parser.NoodleParser
            self._parser = NoodleParser()
            self._parser_initialized = True
        return self._parser
    
    function _get_interpreter()
        """Lazy initialization of interpreter."""
        if not self._interpreter_initialized:
            # Use provided interpreter or create a new one
            if self._interpreter is None:
                # Import here to avoid circular imports
                import ..interpreter.NoodleInterpreter
                self._interpreter = NoodleInterpreter(module_loader=self)
            self._interpreter_initialized = True
        return self._interpreter
    
    function find_module_file(self, module_name)
        """
        Find module file by name.
        
        Args:
            module_name: Module name to find
            
        Returns:
            Optional[str]: Path to module file if found
        """
        # Try different file extensions
        extensions = ['.nc', '.py']
        
        for search_path in self.search_paths:
            for ext in extensions:
                # Direct file match
                file_path = os.path.join(search_path, module_name + ext)
                if os.path.isfile(file_path):
                    return file_path
                
                # Package directory match
                package_dir = os.path.join(search_path, module_name)
                init_file = os.path.join(package_dir, '__init__' + ext)
                if os.path.isdir(package_dir) and os.path.isfile(init_file):
                    return init_file
        
        return None
    
    function load_module(self, module_name, module_path = None)
        """
        Load a NoodleCore module.
        
        Args:
            module_name: Name of module to load
            module_path: Optional explicit path to module file
            
        Returns:
            NoodleModule: Loaded module
            
        Raises:
            NoodleImportError: If module cannot be loaded
        """
        # Check if already loaded
        if module_name in self.loaded_modules:
            return self.loaded_modules[module_name]
        
        # Find module file if not provided
        if not module_path:
            module_path = self.find_module_file(module_name)
            if not module_path:
                raise NoodleImportError(
                    f"Module '{module_name}' not found",
                    module_name=module_name
                )
        
        try
            # Load based on file extension
            if module_path.endswith('.nc'):
                return self._load_noodlecore_module(module_name, module_path)
            elif module_path.endswith('.py'):
                return self._load_python_module(module_name, module_path)
            else:
                raise NoodleImportError(
                    f"Unsupported file type for module '{module_name}': {module_path}",
                    module_name=module_name,
                    file_path=module_path
                )
        except Exception as e
            if isinstance(e, (NoodleImportError, NoodleSyntaxError, NoodleRuntimeError)):
                raise
            else:
                raise NoodleImportError(
                    f"Failed to load module '{module_name}': {str(e)}",
                    module_name=module_name,
                    file_path=module_path
                )
    
    function _load_noodlecore_module(self, module_name, module_path)
        """
        Load a .nc (NoodleCore) module.
        
        Args:
            module_name: Module name
            module_path: Path to .nc file
            
        Returns:
            NoodleModule: Loaded module
        """
        try
            with open(module_path, 'r', encoding='utf-8') as f:
                source_code = f.read()
        except IOError as e
            raise NoodleImportError(
                f"Cannot read module file '{module_path}': {str(e)}",
                module_name=module_name,
                file_path=module_path
            )
        
        # Parse the source code
        try
            parser = self._get_parser()
            ast = parser.parse(source_code, module_path)
        except Exception as e
            if isinstance(e, NoodleSyntaxError):
                raise
            else:
                raise NoodleSyntaxError(
                    f"Failed to parse module '{module_name}': {str(e)}",
                    file_path=module_path
                )
        
        # Create module object
        module = NoodleModule(
            name=module_name,
            path=module_path,
            globals={},
            functions={},
            classes={},
            imports=[]
        )
        
        # Execute the module to populate globals
        try
            interpreter = self._get_interpreter()
            interpreter.execute_module(module, ast)
        except Exception as e
            if isinstance(e, NoodleRuntimeError):
                raise
            else:
                raise NoodleRuntimeError(
                    f"Failed to execute module '{module_name}': {str(e)}",
                    operation="module_execution"
                )
        
        # Cache the module
        self.loaded_modules[module_name] = module
        return module
    
    function _load_python_module(self, module_name, module_path)
        """
        Load a Python module and wrap it as NoodleCore module.
        
        Args:
            module_name: Module name
            module_path: Path to .py file
            
        Returns:
            NoodleModule: Wrapped module
        """
        try
            # Load Python module
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            if not spec:
                raise NoodleImportError(
                    f"Cannot create module spec for '{module_path}'",
                    module_name=module_name,
                    file_path=module_path
                )
            
            python_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(python_module)
        except Exception as e
            raise NoodleImportError(
                f"Failed to load Python module '{module_name}': {str(e)}",
                module_name=module_name,
                file_path=module_path
            )
        
        # Create NoodleCore wrapper
        module = NoodleModule(
            name=module_name,
            path=module_path,
            globals={},
            functions={},
            classes={},
            imports=[]
        )
        
        # Copy Python module attributes to NoodleCore module
        for name, value in vars(python_module).items():
            if not name.startswith('_'):
                module.globals[name] = value
                
                # Categorize the attribute
                if callable(value):
                    # Create NoodleFunction wrapper
                    module.functions[name] = self._wrap_python_function(name, value)
                elif isinstance(value, type):
                    # Create NoodleClass wrapper
                    module.classes[name] = self._wrap_python_class(name, value)
        
        # Cache the module
        self.loaded_modules[module_name] = module
        return module
    
    function _wrap_python_function(self, name, func)
        """
        Wrap a Python function as NoodleFunction.
        
        Args:
            name: Function name
            func: Python function
            
        Returns:
            NoodleFunction: Wrapped function
        """
        import inspect
        
        # Get function signature
        sig = inspect.signature(func)
        params = list(sig.parameters.keys())
        
        # Create wrapper
        def wrapper(*args, **kwargs)
            return func(*args, **kwargs)
        
        # Create function with Python function reference
        noodle_func = NoodleFunction(
            name=name,
            params=params,
            body=f"<Python function {name}>",
            closure={},
            is_builtin=False
        )
        
        # Store the actual Python function for execution
        noodle_func._python_func = func
        
        return noodle_func
    
    function _wrap_python_class(self, name, cls)
        """
        Wrap a Python class as NoodleClass.
        
        Args:
            name: Class name
            cls: Python class
            
        Returns:
            NoodleClass: Wrapped class
        """
        # Create NoodleClass wrapper
        noodle_class = NoodleClass(
            name=name,
            bases=[],
            methods={},
            attributes={},
            is_builtin=False
        )
        
        # Copy class attributes
        for attr_name, attr_value in vars(cls).items():
            if not attr_name.startswith('_'):
                noodle_class.attributes[attr_name] = attr_value
        
        # Wrap methods
        for method_name in dir(cls):
            if not method_name.startswith('_'):
                method = getattr(cls, method_name)
                if callable(method):
                    noodle_class.methods[method_name] = self._wrap_python_function(
                        f"{name}.{method_name}", method
                    )
        
        return noodle_class
    
    function reload_module(self, module_name)
        """
        Reload a module.
        
        Args:
            module_name: Module name to reload
            
        Returns:
            NoodleModule: Reloaded module
        """
        if module_name in self.loaded_modules:
            del self.loaded_modules[module_name]
        
        return self.load_module(module_name)
    
    function get_loaded_modules()
        """
        Get list of loaded module names.
        
        Returns:
            List[str]: List of loaded module names
        """
        return list(self.loaded_modules.keys())
    
    function is_module_loaded(self, module_name)
        """
        Check if a module is loaded.
        
        Args:
            module_name: Module name to check
            
        Returns:
            bool: True if module is loaded
        """
        return module_name in self.loaded_modules


# Export module loader
__all__ = [
    'NoodleModuleLoader',
]
