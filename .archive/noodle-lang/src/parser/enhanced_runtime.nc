# Enhanced NBC Runtime with Robust Module Loading and Parser-Interpreter Integration
# ===============================================================================
#
# This module provides an enhanced version of the NBC runtime that integrates:
# - Robust module loading with dependency resolution
# - Parser-interpreter interface for efficient AST processing
# - Enhanced error handling and optimization
#

import abc
import functools
import logging
import queue
import threading
import time
import traceback
import weakref
import contextlib.contextmanager
from dataclasses import dataclass
import enum.Enum
import typing.Any, typing.Dict, typing.List, typing.Optional, typing.Callable

import ....error.NBCRuntimeError
import ....versioning.Version
import .error_handler.(
#     ErrorCategory,
#     ErrorContext,
#     ErrorHandler,
#     ErrorResult,
#     ErrorSeverity,
# )
import .resource_manager.ResourceHandle
import .stack_manager.StackFrame

# Import new components
try
    import .robust_module_loader as robust_loader
    import .parser_interpreter_interface as parser_interface
except ImportError as e
    logging.warning(f"Enhanced runtime components not available: {e}")
    robust_loader = None
    parser_interface = None


class PythonFFIError(NBCRuntimeError)
    """Python FFI error."""

    def __init__(
        self,
        message: str,
        error_code: str = "PYTHON_FFI_ERROR",
        details: Dict[str, Any] = None,
    ):
        """Initialize Python FFI error."""
        super().__init__(message, error_code, details)


@dataclass
class EnhancedRuntimeConfig
    """Enhanced runtime configuration."""

    # Original runtime config
    max_stack_depth: int = 1000
    max_execution_time: float = 3600.0  # 1 hour
    max_memory_usage: int = 1024 * 1024 * 1024  # 1GB
    enable_optimization: bool = True
    optimization_level: int = 2
    enable_profiling: bool = False
    enable_tracing: bool = False
    log_level: str = "INFO"
    database_config: Optional["DatabaseConfig"] = None
    matrix_backend: str = "numpy"
    
    # Enhanced runtime config
    enable_module_loading: bool = True
    enable_parser_interface: bool = True
    module_cache_enabled: bool = True
    module_cache_ttl: float = 300.0  # 5 minutes
    max_module_retries: int = 3
    parser_optimization_level: int = 2
    enable_bytecode_optimization: bool = True
    enable_incremental_compilation: bool = False
    module_search_paths: Optional[List[str]] = None


@dataclass
class EnhancedRuntimeMetrics
    """Enhanced runtime metrics."""

    # Original metrics
    start_time: float = 0.0
    end_time: Optional[float] = None
    execution_time: float = 0.0
    instructions_executed: int = 0
    memory_used: int = 0
    stack_depth: int = 0
    errors_count: int = 0
    warnings_count: int = 0
    database_queries: int = 0
    matrix_operations: int = 0
    optimization_applied: int = 0
    
    # Enhanced metrics
    modules_loaded: int = 0
    modules_cached: int = 0
    modules_failed: int = 0
    bytecode_compilations: int = 0
    optimizations_applied: int = 0
    dependency_resolutions: int = 0
    circular_dependencies_detected: int = 0
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            # Original metrics
            "start_time": self.start_time,
            "end_time": self.end_time,
            "execution_time": self.execution_time,
            "instructions_executed": self.instructions_executed,
            "memory_used": self.memory_used,
            "stack_depth": self.stack_depth,
            "errors_count": self.errors_count,
            "warnings_count": self.warnings_count,
            "database_queries": self.database_queries,
            "matrix_operations": self.matrix_operations,
            "optimization_applied": self.optimization_applied,
            # Enhanced metrics
            "modules_loaded": self.modules_loaded,
            "modules_cached": self.modules_cached,
            "modules_failed": self.modules_failed,
            "bytecode_compilations": self.bytecode_compilations,
            "optimizations_applied": self.optimizations_applied,
            "dependency_resolutions": self.dependency_resolutions,
            "circular_dependencies_detected": self.circular_dependencies_detected,
        }


class RuntimeState(Enum)
    """Runtime states."""

    INITIALIZING = "initializing"
    READY = "ready"
    RUNNING = "running"
    PAUSED = "paused"
    STOPPED = "stopped"
    ERROR = "error"
    COMPILING = "compiling"
    LOADING_MODULE = "loading_module"


class EnhancedNBCRuntime
    """
    Enhanced NBC runtime coordinator with robust module loading and parser-interpreter integration.
    
    Features:
    - Robust module loading with dependency resolution
    - Parser-interpreter interface for efficient AST processing
    - Enhanced error handling and optimization
    - Bytecode compilation and caching
    - Incremental compilation support
    """

    def __init__(self, config: Optional[EnhancedRuntimeConfig] = None):
        """Initialize enhanced NBC runtime."""
        self.config = config or EnhancedRuntimeConfig()
        self.state = RuntimeState.INITIALIZING
        
        # Initialize core components
        self.stack_manager = StackManager(max_stack_depth=self.config.max_stack_depth)
        self.error_handler = ErrorHandler()
        self.resource_manager = ResourceManager(max_memory=self.config.max_memory_usage)
        
        # Initialize enhanced components
        self.module_loader: Optional[robust_loader.RobustNoodleModuleLoader] = None
        self.parser_interface: Optional[parser_interface.ParserInterpreterInterface] = None
        self.compiled_modules: Dict[str, parser_interface.BytecodeModule] = {}
        self.module_dependencies: Dict[str, List[str]] = {}
        
        # Initialize original optional components
        self.matrix_ops_manager = None
        self.math_object_mapper = None
        self.database_pool = None
        
        # Initialize available components
        if INSTRUCTION_AVAILABLE:
            # Import instruction-related types
            try:
                from ..execution.instruction import Instruction
                self.Instruction = Instruction
            except ImportError:
                # Define basic Instruction class
                @dataclass
                class Instruction:
                    instruction_type: InstructionType
                    operation: str
                    operands: List[Any] = None
                    
                    @property
                    def opcode(self):
                        """Get opcode (alias for operation)."""
                        return self.operation
                    
                    def validate(self) -> bool:
                        """Validate instruction."""
                        if not self.instruction_type or not self.operation:
                            return False
                        
                        if self.operands is not None:
                            if not isinstance(self.operands, list):
                                return False
                        
                        return True
                    
                    def __str__(self):
                        """String representation."""
                        return f"Instruction({self.instruction_type}, {self.operation}, {self.operands})"
                
                self.Instruction = Instruction
        else:
            # Define fallback Instruction class
            @dataclass
            class Instruction:
                instruction_type: InstructionType
                operation: str
                operands: List[Any] = None
                
                @property
                def opcode(self):
                    """Get opcode (alias for operation)."""
                    return self.operation
                
                def validate(self) -> bool:
                    """Validate instruction."""
                    if not self.instruction_type or not self.operation:
                        return False
                    
                    if self.operands is not None:
                        if not isinstance(self.operands, list):
                            return False
                    
                    return True
                
                def __str__(self):
                    """String representation."""
                    return f"Instruction({self.instruction_type}, {self.operation}, {self.operands})"
            
            self.Instruction = Instruction
        
        # Initialize matrix operations if available
        if MATH_OBJECTS_AVAILABLE:
            try:
                import ..mathematical.matrix_ops.MatrixOperationsManager
                self.matrix_ops_manager = MatrixOperationsManager()
            except ImportError:
                logging.warning("Matrix operations manager not available")
            
            try:
                import ..mathematical.objects.MathematicalObjectMapper
                self.math_object_mapper = MathematicalObjectMapper()
            except ImportError:
                logging.warning("Mathematical object mapper not available")
            
            try:
                from noodlecore.database.connection_manager import (
                    ConnectionPool as DatabaseConnection,
                )
                from noodlecore.database.connection_manager import (
                    DatabaseConfig,
                )
                
                if self.config.database_config:
                    self.database_pool = DatabaseConnection(self.config.database_config)
            except ImportError:
                logging.warning("Database connections not available")
        
        # Initialize enhanced components if enabled
        if self.config.enable_module_loading and robust_loader:
            self.module_loader = robust_loader.RobustNoodleModuleLoader(
                base_path=self.config.module_search_paths[0] if self.config.module_search_paths else None,
                interpreter=self  # Pass runtime as interpreter
            )
            self.module_loader.enable_cache(self.config.module_cache_enabled)
            self.module_loader.set_cache_ttl(self.config.module_cache_ttl)
        
        if self.config.enable_parser_interface and parser_interface:
            self.parser_interface = parser_interface.ParserInterpreterInterface(
                enable_optimizations=self.config.enable_bytecode_optimization,
                optimization_level=self.config.parser_optimization_level
            )
        
        # Runtime state
        self.current_program: Optional[List[Instruction]] = None
        self.current_instruction: Optional[Instruction] = None
        self.program_counter: int = 0
        self.runtime_metrics = EnhancedRuntimeMetrics()
        
        # Threading
        self._execution_thread: Optional[threading.Thread] = None
        self._stop_event = threading.Event()
        self._pause_event = threading.Event()
        self._pause_event.set()  # Initially not paused
        
        # Event callbacks (enhanced)
        self._event_callbacks: Dict[str, List[Callable]] = {
            "before_instruction": [],
            "after_instruction": [],
            "on_error": [],
            "on_warning": [],
            "on_stack_push": [],
            "on_stack_pop": [],
            "on_database_query": [],
            "on_matrix_operation": [],
            # Enhanced events
            "before_module_load": [],
            "after_module_load": [],
            "on_module_error": [],
            "before_compilation": [],
            "after_compilation": [],
            "on_optimization": [],
        }
        
        # Initialize logging
        self._setup_logging()
        
        # Register error handlers
        self._register_error_handlers()
        
        # Mark as ready
        self.state = RuntimeState.READY
        logger.info("Enhanced NBC Runtime initialized successfully")
    
    def _setup_logging(self):
        """Setup logging configuration."""
        logging.basicConfig(
            level=getattr(logging, self.config.log_level.upper()),
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        )
    
    def _register_error_handlers(self):
        """Register error handlers."""
        
        # Handle stack overflow
        def handle_stack_overflow(error: Exception, context: ErrorContext):
            logger.error(f"Stack overflow: {error}")
            self.state = RuntimeState.ERROR
            return {"action": "stop", "message": str(error)}
        
        self.error_handler.register_handler(OverflowError, handle_stack_overflow)
        
        # Handle memory errors
        def handle_memory_error(error: Exception, context: ErrorContext):
            logger.error(f"Memory error: {error}")
            self.resource_manager.cleanup()
            return {"action": "stop", "message": str(error)}
        
        self.error_handler.register_handler(MemoryError, handle_memory_error)
        
        # Handle module loading errors
        def handle_module_error(error: Exception, context: ErrorContext):
            logger.error(f"Module loading error: {error}")
            self.runtime_metrics.modules_failed += 1
            self._fire_event("on_module_error", error, context)
            return {"action": "continue", "message": str(error)}
        
        self.error_handler.register_handler(ImportError, handle_module_error)
        
        # Handle database errors
        def handle_database_error(error: Exception, context: ErrorContext):
            logger.error(f"Database error: {error}")
            return {"action": "retry", "message": str(error), "retries": 3}
        
        self.error_handler.register_handler(Exception, handle_database_error)
    
    def load_module(self, module_name: str, force_reload: bool = False) -> Any:
        """
        Load a module with enhanced features.
        
        Args:
            module_name: Name of the module to load
            force_reload: Force reload even if cached
            
        Returns:
            Loaded module
            
        Raises:
            NBCRuntimeError: If module cannot be loaded
        """
        if not self.module_loader:
            raise NBCRuntimeError("Module loading not enabled")
        
        try:
            self.state = RuntimeState.LOADING_MODULE
            self._fire_event("before_module_load", module_name)
            
            # Load module using robust loader
            module = self.module_loader.load_module(module_name, force_reload)
            
            # Update metrics
            self.runtime_metrics.modules_loaded += 1
            if self.module_loader.is_cache_enabled:
                self.runtime_metrics.modules_cached += 1
            
            # Store in compiled modules if we have parser interface
            if self.parser_interface and hasattr(module, 'source'):
                self._compile_module_to_bytecode(module_name, module)
            
            self._fire_event("after_module_load", module_name, module)
            self.state = RuntimeState.READY
            
            return module
            
        except Exception as e:
            self.state = RuntimeState.ERROR
            self.runtime_metrics.modules_failed += 1
            self._fire_event("on_module_error", e, {"module": module_name})
            raise NBCRuntimeError(f"Failed to load module '{module_name}': {str(e)}")
    
    def _compile_module_to_bytecode(self, module_name: str, module: Any):
        """Compile module source to bytecode."""
        if not hasattr(module, 'source'):
            return
        
        try:
            self.state = RuntimeState.COMPILING
            self._fire_event("before_compilation", module_name)
            
            # Parse and compile using parser interface
            bytecode_module = self.parser_interface.parse_and_compile(
                module.source,
                module_name,
                getattr(module, 'path', '<unknown>')
            )
            
            # Store compiled module
            self.compiled_modules[module_name] = bytecode_module
            self.runtime_metrics.bytecode_compilations += 1
            
            # Update dependencies
            self._update_module_dependencies(module_name, bytecode_module)
            
            self._fire_event("after_compilation", module_name, bytecode_module)
            self.state = RuntimeState.READY
            
        except Exception as e:
            logger.error(f"Failed to compile module '{module_name}': {e}")
            self.runtime_metrics.modules_failed += 1
    
    def _update_module_dependencies(self, module_name: str, bytecode_module: parser_interface.BytecodeModule):
        """Update module dependency graph."""
        if not bytecode_module.imports:
            return
        
        self.module_dependencies[module_name] = bytecode_module.imports
        self.runtime_metrics.dependency_resolutions += 1
        
        # Check for circular dependencies
        if self._has_circular_dependency(module_name):
            self.runtime_metrics.circular_dependencies_detected += 1
            logger.warning(f"Circular dependency detected for module: {module_name}")
    
    def _has_circular_dependency(self, module_name: str, visited: Optional[Set[str]] = None) -> bool:
        """Check for circular dependencies in module graph."""
        if visited is None:
            visited = set()
        
        if module_name in visited:
