# Enhanced NBC Runtime with Robust Module Loading and Parser-Interpreter Integration
# =================================================================================
#
# This module provides an enhanced version of the NBC runtime that integrates
# the RobustNoodleModuleLoader and ParserInterpreterInterface for improved
# module loading and execution.
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
import enum.Enum
import typing.Any
import pathlib
import sys
import os

import ....error.NBCRuntimeError
import ....versioning.Version

# Import enhanced components
import ..robust_module_loader.RobustNoodleModuleLoader
import ..parser_interpreter_interface.ParserInterpreterInterface
import ..parser_interpreter_interface.OpCode
import ..parser_interpreter_interface.Instruction
import ..parser_interpreter_interface.BytecodeFunction
import ..parser_interpreter_interface.BytecodeModule

# Attempt imports for runtime components
try
    # Import error handling components
    import ..error_handler.ErrorHandler
    import ..error_handler.ErrorContext
    import ..error_handler.ErrorResult
    import ..error_handler.ErrorSeverity
    import ..error_handler.ErrorCategory
    
    # Import resource management
    import ..resource_manager.ResourceManager
    import ..resource_manager.ResourceHandle
    
    # Import stack management
    import ..stack_manager.StackManager
    import ..stack_manager.StackFrame
    
    INTEGRITY_AVAILABLE = True
except ImportError as e
    logging.warning(f"Optional import failed: {e}")
    INTEGRITY_AVAILABLE = False

# Attempt imports for optional components
try
    # Import mathematical components
    import ..mathematical.matrix_ops.MatrixOperationsManager
    import ..mathematical.objects.MathematicalObjectMapper
    
    # Import database components
    from noodlecore.database.connection_manager import (
        ConnectionPool as DatabaseConnection,
        DatabaseConfig
    )
    
    MATH_OBJECTS_AVAILABLE = True
    DATABASE_AVAILABLE = True
except ImportError as e
    logging.warning(f"Optional import failed: {e}")
    MATH_OBJECTS_AVAILABLE = False
    DATABASE_AVAILABLE = False


class PythonFFIError(NBCRuntimeError)
    """Python FFI error."""
    
    function __init__(
        self,
        message,
        error_code = "PYTHON_FFI_ERROR",
        details = None,
    )
        """Initialize Python FFI error."""
        super().__init__(message, error_code, details)


class RuntimeConfig
    """Enhanced runtime configuration."""
    
    function __init__(
        self,
        max_stack_depth = 1000,
        max_execution_time = 3600.0,  # 1 hour
        max_memory_usage = 1024 * 1024 * 1024,  # 1GB
        enable_optimization = True,
        optimization_level = 2,
        enable_profiling = False,
        enable_tracing = False,
        log_level = "INFO",
        database_config = None,
        matrix_backend = "numpy",
        # Module loading configuration
        enable_module_cache = True,
        module_cache_ttl = 300.0,  # 5 minutes
        max_module_retries = 3,
        module_search_paths = None,
        # Parser-interpreter configuration
        enable_parser_optimizations = True,
        parser_optimization_level = 2,
        enable_bytecode_generation = True
    )
        """Initialize runtime configuration."""
        self.max_stack_depth = max_stack_depth
        self.max_execution_time = max_execution_time
        self.max_memory_usage = max_memory_usage
        self.enable_optimization = enable_optimization
        self.optimization_level = optimization_level
        self.enable_profiling = enable_profiling
        self.enable_tracing = enable_tracing
        self.log_level = log_level
        self.database_config = database_config
        self.matrix_backend = matrix_backend
        # Module loading config
        self.enable_module_cache = enable_module_cache
        self.module_cache_ttl = module_cache_ttl
        self.max_module_retries = max_module_retries
        self.module_search_paths = module_search_paths
        # Parser-interpreter config
        self.enable_parser_optimizations = enable_parser_optimizations
        self.parser_optimization_level = parser_optimization_level
        self.enable_bytecode_generation = enable_bytecode_generation
    
    function to_dict()
        """Convert to dictionary."""
        return {
            "max_stack_depth": self.max_stack_depth,
            "max_execution_time": self.max_execution_time,
            "max_memory_usage": self.max_memory_usage,
            "enable_optimization": self.enable_optimization,
            "optimization_level": self.optimization_level,
            "enable_profiling": self.enable_profiling,
            "enable_tracing": self.enable_tracing,
            "log_level": self.log_level,
            "database_config": (
                self.database_config.to_dict() if self.database_config else None
            ),
            "matrix_backend": self.matrix_backend,
            # Module loading config
            "enable_module_cache": self.enable_module_cache,
            "module_cache_ttl": self.module_cache_ttl,
            "max_module_retries": self.max_module_retries,
            "module_search_paths": self.module_search_paths,
            # Parser-interpreter config
            "enable_parser_optimizations": self.enable_parser_optimizations,
            "parser_optimization_level": self.parser_optimization_level,
            "enable_bytecode_generation": self.enable_bytecode_generation,
        }


class RuntimeMetrics
    """Enhanced runtime metrics."""
    
    function __init__(
        self,
        start_time = 0.0,
        end_time = None,
        execution_time = 0.0,
        instructions_executed = 0,
        memory_used = 0,
        stack_depth = 0,
        errors_count = 0,
        warnings_count = 0,
        database_queries = 0,
        matrix_operations = 0,
        optimization_applied = 0,
        # Module loading metrics
        modules_loaded = 0,
        modules_cached = 0,
        module_load_time = 0.0,
        # Parser-interpreter metrics
        source_code_parsed = 0,
        bytecode_generated = 0,
        optimizations_applied = 0
    )
        """Initialize runtime metrics."""
        self.start_time = start_time
        self.end_time = end_time
        self.execution_time = execution_time
        self.instructions_executed = instructions_executed
        self.memory_used = memory_used
        self.stack_depth = stack_depth
        self.errors_count = errors_count
        self.warnings_count = warnings_count
        self.database_queries = database_queries
        self.matrix_operations = matrix_operations
        self.optimization_applied = optimization_applied
        # Module loading metrics
        self.modules_loaded = modules_loaded
        self.modules_cached = modules_cached
        self.module_load_time = module_load_time
        # Parser-interpreter metrics
        self.source_code_parsed = source_code_parsed
        self.bytecode_generated = bytecode_generated
        self.optimizations_applied = optimizations_applied
    
    function to_dict()
        """Convert to dictionary."""
        return {
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
            # Module loading metrics
            "modules_loaded": self.modules_loaded,
            "modules_cached": self.modules_cached,
            "module_load_time": self.module_load_time,
            # Parser-interpreter metrics
            "source_code_parsed": self.source_code_parsed,
            "bytecode_generated": self.bytecode_generated,
            "optimizations_applied": self.optimizations_applied,
        }


class RuntimeState
    """Runtime states."""
    
    INITIALIZING = "initializing"
    READY = "ready"
    RUNNING = "running"
    PAUSED = "paused"
    STOPPED = "stopped"
    ERROR = "error"


class NBCRuntime
    """Enhanced NBC runtime coordinator with robust module loading and parser-interpreter integration."""
    
    function __init__(self, config = None)
        """
        Initialize enhanced NBC runtime.
        
        Args:
            config: Enhanced runtime configuration
        """
        self.config = config or RuntimeConfig()
        self.state = RuntimeState.INITIALIZING
        
        # Initialize logging
        self._setup_logging()
        
        # Initialize core components
        if INTEGRITY_AVAILABLE:
            self.stack_manager = ..stack_manager.StackManager.StackManager(
                max_stack_depth=self.config.max_stack_depth
            )
            self.error_handler = ..error_handler.ErrorHandler.ErrorHandler()
            self.resource_manager = ..resource_manager.ResourceManager.ResourceManager(
                max_memory=self.config.max_memory_usage
            )
        else
            # Fallback components
            self.stack_manager = None
            self.error_handler = None
            self.resource_manager = None
        
        # Initialize optional components (conditionally)
        self.matrix_ops_manager = None
        self.math_object_mapper = None
        self.database_pool = None
        
        # Initialize enhanced components
        self.module_loader = None
        self.parser_interpreter = None
        
        # Initialize enhanced components
        self._initialize_enhanced_components()
        
        # Initialize optional components
        self._initialize_optional_components()
        
        # Runtime state
        self.current_program = None
        self.current_instruction = None
        self.program_counter = 0
        self.runtime_metrics = RuntimeMetrics()
        
        # Threading
        self._execution_thread = None
        self._stop_event = threading.Event()
        self._pause_event = threading.Event()
        self._pause_event.set()  # Initially not paused
        
        # Event callbacks
        self._event_callbacks = {
            "before_instruction": [],
            "after_instruction": [],
            "on_error": [],
            "on_warning": [],
            "on_stack_push": [],
            "on_stack_pop": [],
            "on_database_query": [],
            "on_matrix_operation": [],
            "on_module_load": [],
            "on_bytecode_generated": [],
        }
        
        # Register error handlers
        self._register_error_handlers()
        
        # Mark as ready
        self.state = RuntimeState.READY
        self.logger.info("Enhanced NBC Runtime initialized successfully")
    
    function _setup_logging()
        """Setup logging configuration."""
        logging.basicConfig(
            level=getattr(logging, self.config.log_level.upper()),
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        )
        self.logger = logging.getLogger(__name__)
    
    function _initialize_enhanced_components()
        """Initialize enhanced components."""
        try
            # Initialize robust module loader
            self.module_loader = ..robust_module_loader.RobustNoodleModuleLoader.RobustNoodleModuleLoader(
                base_path=self.config.module_search_paths[0] if self.config.module_search_paths else None,
                interpreter=self
            )
            
            # Configure module loader
            self.module_loader.enable_cache(self.config.enable_module_cache)
            self.module_loader.set_cache_ttl(self.config.module_cache_ttl)
            
            # Initialize parser-interpreter interface
            self.parser_interpreter = ..parser_interpreter_interface.ParserInterpreterInterface.ParserInterpreterInterface(
                enable_optimizations=self.config.enable_parser_optimizations,
                optimization_level=self.config.parser_optimization_level
            )
            
            self.logger.info("Enhanced components initialized successfully")
            
        except Exception as e
            self.logger.error(f"Failed to initialize enhanced components: {e}")
            # Continue without enhanced components
            self.module_loader = None
            self.parser_interpreter = None
    
    function _initialize_optional_components()
        """Initialize optional components."""
        # Initialize matrix operations if available
        if MATH_OBJECTS_AVAILABLE
            try
                self.matrix_ops_manager = ..mathematical.matrix_ops.MatrixOperationsManager.MatrixOperationsManager()
                self.math_object_mapper = ..mathematical.objects.MathematicalObjectMapper.MathematicalObjectMapper()
            except ImportError
                self.logger.warning("Matrix operations manager not available")
        
        # Initialize database connections if available
        if DATABASE_AVAILABLE and self.config.database_config
            try
                self.database_pool = DatabaseConnection(self.config.database_config)
            except ImportError
                self.logger.warning("Database connections not available")
    
    function _register_error_handlers()
        """Register error handlers."""
        if not INTEGRITY_AVAILABLE
            return
            
        # Handle stack overflow
        function handle_stack_overflow(error, context)
            self.logger.error(f"Stack overflow: {error}")
            self.state = RuntimeState.ERROR
            return {"action": "stop", "message": str(error)}
        
        self.error_handler.register_handler(OverflowError, handle_stack_overflow)
        
        # Handle memory errors
        function handle_memory_error(error, context)
            self.logger.error(f"Memory error: {error}")
            if self.resource_manager
                self.resource_manager.cleanup()
            return {"action": "stop", "message": str(error)}
        
        self.error_handler.register_handler(MemoryError, handle_memory_error)
        
        # Handle module loading errors
        function handle_module_error(error, context)
            self.logger.error(f"Module loading error: {error}")
            return {"action": "retry", "message": str(error), "retries": self.config.max_module_retries}
        
        if self.module_loader
            self.error_handler.register_handler(Exception, handle_module_error)
    
    function load_program_from_source(self, source_code, module_name, filename = "<string>")
        """
        Load and compile a program from source code.
        
        Args:
            source_code: Source code to load
            module_name: Name of the module
            filename: Filename for error reporting
            
        Returns:
            True if successful, False otherwise
        """
        try
            # Parse and compile source code
            if self.parser_interpreter and self.config.enable_bytecode_generation
                bytecode_module = self.parser_interpreter.parse_and_compile(
                    source_code, module_name, filename
                )
                
                # Update metrics
                self.runtime_metrics.source_code_parsed += 1
                self.runtime_metrics.bytecode_generated += 1
                
                # Fire event
                self._fire_event("on_bytecode_generated", bytecode_module)
                
                # Convert bytecode to instructions (simplified)
                instructions = self._convert_bytecode_to_instructions(bytecode_module)
                self.current_program = instructions
            else
                # Fallback: create simple instructions from source
                instructions = self._create_simple_instructions_from_source(source_code)
                self.current_program = instructions
            
            self.program_counter = 0
            self.state = RuntimeState.READY
            
            self.logger.info(f"Loaded program from source: {module_name}")
            return True
            
        except Exception as e
            self.state = RuntimeState.ERROR
            self.logger.error(f"Failed to load program from source: {e}")
            self._fire_event("on_error", e)
            return False
    
    function load_module(self, module_name)
        """
        Load a module using the robust module loader.
        
        Args:
            module_name: Name of the module to load
            
        Returns:
            True if successful, False otherwise
        """
        try
            if not self.module_loader
                self.logger.error("Module loader not available")
                return False
            
            # Load module
            start_time = time.time()
            module = self.module_loader.load_module(module_name)
            load_time = time.time() - start_time
            
            # Update metrics
            self.runtime_metrics.modules_loaded += 1
            self.runtime_metrics.module_load_time += load_time
            
            if self.module_loader.cache_enabled
                self.runtime_metrics.modules_cached += 1
            
            # Store module as current program
            self.current_program = module
            self.program_counter = 0
            self.state = RuntimeState.READY
            
            # Fire event
            self._fire_event("on_module_load", module_name, module)
            
            self.logger.info(f"Loaded module: {module_name}")
            return True
            
        except Exception as e
            self.state = RuntimeState.ERROR
            self.logger.error(f"Failed to load module: {e}")
            self._fire_event("on_error", e)
            return False
    
    function _convert_bytecode_to_instructions(self, bytecode_module)
        """Convert bytecode module to instructions."""
        instructions = []
        
        # Convert each function to instructions
        for func_name, func in bytecode_module.functions.items()
            # Create instruction for function definition
            func_instr = {
                "type": "function_def",
                "name": func_name,
                "parameters": func.parameters,
                "instructions": []
            }
            
            # Convert each instruction in the function
            for instr in func.instructions
                func_instr["instructions"].append({
                    "type": "instruction",
                    "opcode": instr.opcode.value,
                    "operands": instr.operands,
                    "position": instr.position
                })
            
            instructions.append(func_instr)
        
        return instructions
    
    function _create_simple_instructions_from_source(self, source_code)
        """Create simple instructions from source code."""
        instructions = []
        
        # Split source into lines
        lines = source_code.split('\n')
        
        for i, line in enumerate(lines)
            line = line.strip()
            if not line or line.startswith('#')
                continue
            
            # Create simple instruction
            if '=' in line
                # Assignment
                parts = line.split('=', 1)
                var_name = parts[0].strip()
                value = parts[1].strip()
                
                instructions.append({
                    "type": "assignment",
                    "variable": var_name,
                    "value": value,
                    "line": i + 1
                })
            elif line.startswith('print')
                # Print statement
                args = line[5:].strip()
                if args.startswith('(') and args.endswith(')')
                    args = args[1:-1].strip()
                
                instructions.append({
                    "type": "print",
                    "args": [args] if args else [],
                    "line": i + 1
                })
            else
                # Expression statement
                instructions.append({
                    "type": "expression",
                    "expression": line,
                    "line": i + 1
                })
        
        return instructions
    
    function load_program(self, program)
        """
        Load a program for execution.
        
        Args:
            program: List of instructions to load
        """
        try
            # Validate program
            if not self._validate_program(program)
                raise ValueError("Invalid program")
            
            # Load program
            self.current_program = program
            self.program_counter = 0
            self.state = RuntimeState.READY
            
            self.logger.info(f"Loaded program with {len(program)} instructions")
            
        except Exception as e
            self.state = RuntimeState.ERROR
            self.logger.error(f"Failed to load program: {e}")
            self._fire_event("on_error", e)
            raise
    
    function _validate_program(self, program)
        """Validate a program."""
        try
            if not program
                return False
            
            for instruction in program
                if not isinstance(instruction, dict) or "type" not in instruction
                    return False
            
            return True
        except Exception
            return False
    
    function execute_program(self, program = None)
        """
        Execute the loaded program or a new program.
        
        Args:
            program: Optional program to execute
            
        Returns:
            Execution result
        """
        if program
            self.load_program(program)
        
        if not self.current_program
            raise ValueError("No program loaded")
        
        # Start execution
        self.state = RuntimeState.RUNNING
        self.runtime_metrics.start_time = time.time()
        self._stop_event.clear()
        
        try
            # Execute in separate thread
            self._execution_thread = threading.Thread(
                target=self._execute_program_thread, daemon=True
            )
            self._execution_thread.start()
            
            # Wait for completion
            self._execution_thread.join()
            
            # Calculate final metrics
            self.runtime_metrics.end_time = time.time()
            self.runtime_metrics.execution_time = (
                self.runtime_metrics.end_time - self.runtime_metrics.start_time
            )
            
            return {
                "success": self.state != RuntimeState.ERROR,
                "state": self.state.value,
                "metrics": self.runtime_metrics.to_dict(),
                "error": (
                    None if self.state != RuntimeState.ERROR else "Execution failed"
                ),
            }
            
        except Exception as e
            self.state = RuntimeState.ERROR
            self.logger.error(f"Execution failed: {e}")
            self._fire_event("on_error", e)
            return {
                "success": False,
                "state": self.state.value,
                "metrics": self.runtime_metrics.to_dict(),
                "error": str(e),
            }
    
    function _execute_program_thread(self)
        """Execute program in separate thread."""
        try
            while not self._stop_event.is_set() and self.program_counter < len(self.current_program)
                # Check pause
                self._pause_event.wait()
                
                # Check timeout
                if (
                    time.time() - self.runtime_metrics.start_time
                    > self.config.max_execution_time
                )
                    raise TimeoutError("Execution timeout exceeded")
                
                # Execute instruction
                instruction = self.current_program[self.program_counter]
                self.current_instruction = instruction
                
                # Fire before instruction event
                self._fire_event("before_instruction", instruction)
                
                # Execute instruction
                result = self._execute_instruction(instruction)
                
                # Fire after instruction event
                self._fire_event("after_instruction", instruction, result)
                
                # Update metrics
                self.runtime_metrics.instructions_executed += 1
                if self.stack_manager
                    self.runtime_metrics.stack_depth = self.stack_manager.get_stack_depth()
                
                # Move to next instruction
                self.program_counter += 1
            
            # Check if program completed successfully
            if self.program_counter >= len(self.current_program)
                self.logger.info("Program completed successfully")
                self.state = RuntimeState.STOPPED
            
        except Exception as e
            # Handle error
            error_context = None
            if INTEGRITY_AVAILABLE and self.error_handler
                error_context = ..error_handler.ErrorHandler.ErrorContext(
                    instruction=self.current_instruction,
                    program_counter=self.program_counter,
                    stack_depth=self.stack_manager.get_stack_depth() if self.stack_manager else 0,
                    memory_usage=self.resource_manager.get_memory_usage() if self.resource_manager else 0,
                )
            
            if self.error_handler
                error_result = self.error_handler.handle_error(e, error_context)
            else
                error_result = {"action": "stop", "message": str(e)}
            
            # Fire error event
            self._fire_event("on_error", e, error_result)
            
            # Update metrics
            self.runtime_metrics.errors_count += 1
            
            # Stop execution
            self.stop()
    
    function _execute_instruction(self, instruction)
        """
        Execute a single instruction.
        
        Args:
            instruction: Instruction to execute
            
        Returns:
            Execution result
        """
        try
            # Handle different instruction types
            if instruction["type"] == "assignment"
                return self._execute_assignment(instruction)
            elif instruction["type"] == "print"
                return self._execute_print(instruction)
            elif instruction["type"] == "expression"
                return self._execute_expression(instruction)
            elif instruction["type"] == "function_def"
                return self._execute_function_def(instruction)
            else
                raise ValueError(f"Unknown instruction type: {instruction['type']}")
            
        except Exception as e
            self.logger.error(f"Instruction execution failed: {e}")
            self._fire_event("on_error", e)
            raise
    
    function _execute_assignment(self, instruction)
        """Execute assignment instruction."""
        var_name = instruction["variable"]
        value = instruction["value"]
        
        # Evaluate value (simplified)
        if value.isdigit()
            value = int(value)
        elif value.replace('.', '', 1).isdigit()
            value = float(value)
        elif value.lower() in ('true', 'false')
            value = value.lower() == 'true'
        
        # Store variable (simplified)
        if not hasattr(self, '_variables')
            self._variables = {}
        
        self._variables[var_name] = value
        
        # Push to stack if available
        if self.stack_manager
            self.stack_manager.push(value)
        
        return value
    
    function _execute_print(self, instruction)
        """Execute print instruction."""
        args = instruction["args"]
        
        # Evaluate arguments
        output = []
        for arg in args
            # Simplified evaluation
            if hasattr(self, '_variables') and arg in self._variables
                value = self._variables[arg]
            else
                value = arg
            
            output.append(str(value))
        
        print(" ".join(output))
        
        # Push result to stack if available
        result = " ".join(output)
        if self.stack_manager
            self.stack_manager.push(result)
        
        return result
    
    function _execute_expression(self, instruction)
        """Execute expression instruction."""
        expression = instruction["expression"]
        
        # Evaluate expression (simplified)
        try
            # This is a very simplified evaluation
            # In a real implementation, we would have a proper expression evaluator
            result = eval(expression, {}, getattr(self, '_variables', {}))
        except
            result = expression
        
        # Push result to stack if available
        if self.stack_manager
            self.stack_manager.push(result)
        
        return result
    
    function _execute_function_def(self, instruction)
        """Execute function definition instruction."""
        func_name = instruction["name"]
        parameters = instruction["parameters"]
        func_instructions = instruction["instructions"]
        
        # Create function object (simplified)
        function = {
            "name": func_name,
            "parameters": parameters,
            "instructions": func_instructions,
            "scope": getattr(self, '_variables', {}).copy()
        }
        
        # Store function
        if not hasattr(self, '_functions')
            self._functions = {}
        
        self._functions[func_name] = function
        
        # Push to stack if available
        if self.stack_manager
            self.stack_manager.push(function)
        
        return function
    
    function stop(self)
        """Stop runtime execution."""
        self._stop_event.set()
        self.state = RuntimeState.STOPPED
        
        # Cleanup resources
        if self.resource_manager
            self.resource_manager.cleanup()
        
        self.logger.info("Runtime stopped")
    
    function pause(self)
        """Pause runtime execution."""
        self._pause_event.clear()
        self.state = RuntimeState.PAUSED
        self.logger.info("Runtime paused")
    
    function resume(self)
        """Resume runtime execution."""
        self._pause_event.set()
        self.state = RuntimeState.RUNNING
        self.logger.info("Runtime resumed")
    
    function reset(self)
        """Reset runtime state."""
        # Stop current execution
        self.stop()
        
        # Reset components
        if self.stack_manager
            self.stack_manager.clear()
        if self.resource_manager
            self.resource_manager.cleanup()
        
        # Clear state
        self.current_program = None
        self.current_instruction = None
        self.program_counter = 0
        self.runtime_metrics = RuntimeMetrics()
        
        # Clear variables and functions
        if hasattr(self, '_variables')
            self._variables.clear()
        if hasattr(self, '_functions')
            self._functions.clear()
        
        # Reset state
        self.state = RuntimeState.READY
        
        self.logger.info("Runtime reset")
    
    function get_state(self)
        """Get current runtime state."""
        return self.state
    
    function get_metrics(self)
        """Get runtime metrics."""
        return self.runtime_metrics
    
    function get_stack_depth(self)
        """Get current stack depth."""
        if self.stack_manager
            return self.stack_manager.get_stack_depth()
        return 0
    
    function get_memory_usage(self)
        """Get current memory usage."""
        if self.resource_manager
            return self.resource_manager.get_memory_usage()
        return 0
    
    function get_module_loader_stats(self)
        """Get module loader statistics."""
        if self.module_loader
            return self.module_loader.get_statistics()
        return None
    
    function get_parser_interpreter_stats(self)
        """Get parser-interpreter statistics."""
        if self.parser_interpreter
            return self.parser_interpreter.get_statistics()
        return None
    
    function add_event_callback(self, event, callback)
        """
        Add event callback.
        
        Args:
            event: Event name
            callback: Callback function
        """
        if event in self._event_callbacks
            self._event_callbacks[event].append(callback)
        else
            raise ValueError(f"Unknown event: {event}")
    
    function remove_event_callback(self, event, callback)
        """
        Remove event callback.
        
        Args:
            event: Event name
            callback: Callback function
        """
        if event in self._event_callbacks
            try
                self._event_callbacks[event].remove(callback)
            except ValueError
                pass
    
    function _fire_event(self, event, *args, **kwargs)
        """
        Fire event callbacks.
        
        Args:
            event: Event name
            *args: Event arguments
            **kwargs: Event keyword arguments
        """
        if event in self._event_callbacks
            for callback in self._event_callbacks[event]
                try
                    callback(*args, **kwargs)
                except Exception as e
                    self.logger.error(f"Event callback failed: {e}")
    
    function __enter__(self)
        """Context manager entry."""
        return self
    
    function __exit__(self, exc_type, exc_val, exc_tb)
        """Context manager exit."""
        self.stop()
    
    function __str__(self)
        """String representation."""
        return f"EnhancedNBCRuntime(state={self.state.value}, program_loaded={self.current_program is not None})"
    
    function __repr__(self)
        """Detailed string representation."""
        return (f"EnhancedNBCRuntime(state={self.state.value}, "
                f"program_loaded={self.current_program is not None}, "
                f"stack_depth={self.get_stack_depth()}, "
                f"memory_usage={self.get_memory_usage()}, "
                f"module_loader={self.module_loader is not None}, "
                f"parser_interpreter={self.parser_interpreter is not None})")


# Factory functions


function create_enhanced_runtime(config = None)
    """Create a new enhanced NBC runtime instance."""
    return NBCRuntime(config)


# Utility functions


function validate_program(program)
    """
    Validate a program.
    
    Args:
        program: Program to validate
        
    Returns:
        True if valid
    """
    try
        # Check if program has instructions
        if not program
            return False
        
        # Validate each instruction
        for instruction in program
            if not isinstance(instruction, dict) or "type" not in instruction
                return False
        
        return True
        
    except Exception
        return False


function profile_enhanced_execution(runtime)
    """
    Profile enhanced runtime execution.
    
    Args:
        runtime: Runtime to profile
        
    Returns:
        Profile data
    """
    metrics = runtime.get_metrics()
    
    # Get enhanced component stats
    module_stats = runtime.get_module_loader_stats()
    parser_stats = runtime.get_parser_interpreter_stats()
    
    profile = {
        "execution_time": metrics.execution_time,
        "instructions_executed": metrics.instructions_executed,
        "instructions_per_second": (
            metrics.instructions_executed / metrics.execution_time
            if metrics.execution_time > 0
            else 0
        ),
        "stack_depth": metrics.stack_depth,
        "memory_usage": metrics.memory_used,
        "database_queries": metrics.database_queries,
        "matrix_operations": metrics.matrix_operations,
        "errors_count": metrics.errors_count,
        "warnings_count": metrics.warnings_count,
        # Enhanced metrics
        "modules_loaded": metrics.modules_loaded,
        "modules_cached": metrics.modules_cached,
        "module_load_time": metrics.module_load_time,
        "source_code_parsed": metrics.source_code_parsed,
        "bytecode_generated": metrics.bytecode_generated,
        "optimizations_applied": metrics.optimizations_applied,
    }
    
    # Add component stats if available
    if module_stats
        profile["module_loader"] = module_stats
    
    if parser_stats
        profile["parser_interpreter"] = parser_stats
    
    return profile


# Set up logger
logger = logging.getLogger(__name__)
