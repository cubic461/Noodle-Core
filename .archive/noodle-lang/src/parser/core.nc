# Converted from Python to NoodleCore
# Original file: src

# """
# Core Module for NBC Runtime
# --------------------------------
# This module contains core-related functionality for the NBC runtime.
# """

import datetime
import heapq
import importlib
import inspect
import json
import os
import random
import sys
import threading
import time
import traceback
import collections.deque
import concurrent.futures.Future
from dataclasses import dataclass
import enum.Enum
import typing.Any

import ...compiler.code_generator.BytecodeInstruction
import ..interop.js_bridge
import .code_generator.CodeGenerator


# Lazy loading for heavy dependencies
class LazyLoader
    #     """Lazy loader for heavy dependencies"""

    #     def __init__(self, module_name, import_name=None):
    self.module_name = module_name
    self.import_name = import_name
    self._module = None
    self._lock = threading.Lock()

    #     def __getattr__(self, name):
    #         if self._module is None:
    #             with self._lock:
    #                 if self._module is None:
    #                     try:
    module = importlib.import_module(self.module_name)
    #                         if self.import_name:
    self._module = getattr(module, self.import_name)
    #                         else:
    self._module = module
    #                     except ImportError as e:
                            raise ImportError(
    #                             f"Failed to lazy load {self.module_name}: {e}"
    #                         )
            return getattr(self._module, name)

    #     def __dir__(self):
    #         if self._module is None:
    #             with self._lock:
    #                 if self._module is None:
    #                     try:
    module = importlib.import_module(self.module_name)
    #                         if self.import_name:
    self._module = getattr(module, self.import_name)
    #                         else:
    self._module = module
    #                     except ImportError:
    #                         return []
            return dir(self._module)


# Lazy imports for heavy dependencies
numpy = LazyLoader("numpy")
scipy = LazyLoader("scipy")
pandas = LazyLoader("pandas")
matplotlib = LazyLoader("matplotlib")
sklearn = LazyLoader("sklearn")

# Lazy imports for internal modules
mathematical_objects = LazyLoader("noodle.mathematical_objects")
database = LazyLoader("noodle.database")
distributed = LazyLoader("noodle.runtime.distributed")
matrix_runtime = LazyLoader("noodle.runtime.matrix_runtime")

# """
# NBC Runtime Execution Environment
# ---------------------------------
# This module implements the runtime execution environment for NBC (Noodle ByteCode).
# It provides a virtual machine that can execute compiled Noodle programs with Python FFI support.
# """


class RuntimeError(Exception)
    #     """Exception raised during NBC program execution"""

    #     def __init__(self, message: str, position: Optional[str] = None):
    self.message = message
    self.position = position
    #         if position:
                super().__init__(f"{message} at {position}")
    #         else:
                super().__init__(message)


class PythonFFIError(RuntimeError)
    #     """Exception raised for Python FFI related errors"""

    #     pass


class JSFFIError(RuntimeError)
    #     """Exception raised for JS FFI related errors"""

    #     pass


dataclass
class StackFrame
    #     """Represents a stack frame for function calls"""

    #     name: str
    #     locals: Dict[str, Any]
    #     return_address: int
    parent: Optional["StackFrame"] = None


versioned_class(version = "1.0.0")
class NBCRuntime
    #     """
    #     NBC Virtual Machine that executes compiled Noodle programs
    #     """

    versioned(version = "1.0.0")
    #     def __init__(
    #         self,
    is_debug: bool = False,
    is_distributed_enabled: bool = False,
    is_database_enabled: bool = False,
    #     ):""
    #         Initialize the NBC runtime

    #         Args:
    #             is_debug: Whether to enable debug mode with detailed execution info
    #             is_distributed_enabled: Whether to enable distributed runtime features
    #             is_database_enabled: Whether to enable database backend features
    #         """
    #         from .utils import DependencyContainer  # DI container

    self.is_debug = is_debug
    self.is_distributed_enabled = is_distributed_enabled
    self.is_database_enabled = is_database_enabled
    self.container = DependencyContainer()  # DI container
    self.stack: List[Any] = []
    self.globals: Dict[str, Any] = {}
    self.frames: List[StackFrame] = []
    self.current_frame: Optional[StackFrame] = None
    self.program_counter: int = 0
    self.bytecode: List[BytecodeInstruction] = []
    self.python_modules: Dict[str, Any] = {}
    self.python_functions: Dict[str, Callable] = {}
    self.constants_pool: Dict[str, str] = {}

    #         # Bridge integrations
    self.python_bridge = python_bridge.bridge
    self.js_bridge = js_bridge.bridge

    #         # Distributed runtime components
    self.distributed_runtime = None
    self.is_distributed_enabled = False

    #         # Database state tracking
    self.database_state = {
    #             "connected": False,
    #             "current_transaction": None,
    #             "transaction_count": 0,
    #             "last_operation": None,
    #             "operation_count": 0,
    #         }

    #         # Database module
    self.database_module = None
    self.is_database_enabled = False

    #         # Security features
    self.is_security_enabled = True
    self.allowed_modules = {
    #             "math",
    #             "random",
    #             "datetime",
    #             "json",
    #             "os",
    #             "sys",
    #             "numpy",
    #             "scipy",
    #             "pandas",
    #         }  # Python
    self.allowed_js_modules = {"math", "crypto"}  # JS whitelist
    self.network_timeout = 30.0
    self.max_tensor_size = 100 * 1024 * 1024  # 100MB

    #         # Built-in functions
    self.builtins = {
    #             "print": self._builtin_print,
    #             "len": self._builtin_len,
    #             "str": self._builtin_str,
    #             "int": self._builtin_int,
    #             "float": self._builtin_float,
    #             "bool": self._builtin_bool,
    #         }

    #         # Error handlers
    self.error_handlers = {
    #             "division_by_zero": self._handle_division_by_zero_error,
    #             "overflow": self._handle_overflow_error,
    #             "underflow": self._handle_underflow_error,
    #             "invalid_operation": self._handle_invalid_operation_error,
    #             "type_error": self._handle_type_error,
    #             "value_error": self._handle_value_error,
    #             "index_error": self._handle_index_error,
    #             "key_error": self._handle_key_error,
    #             "cuda_launch_failure": self._handle_cuda_launch_failure_error,
    #             "matrix_overflow": self._handle_matrix_overflow,
    #             "tensor_dimension_mismatch": self._handle_tensor_dimension_mismatch,
    #             "matrix_singular": self._handle_matrix_singular,
    #             "gpu_memory_error": self._handle_gpu_memory_error,
    #             "computation_timeout": self._handle_computation_timeout,
    #         }

    #         # Initialize Python FFI environment
            self.init_python_ffi()

    #         # Initialize matrix runtime
            self.init_matrix_runtime()

    #         # Initialize mathematical object system
            self.init_mathematical_objects()

    #         # Initialize tensor system
            self.init_tensor_system()

    #         # Initialize performance optimizations for matrix/tensor operations
            self.setup_matrix_tensor_performance_optimizations()

    #         # Initialize enhanced matrix/tensor error handling
            self.setup_matrix_tensor_error_handling()

    #         # Initialize enhanced matrix/tensor integration
            self.enhance_matrix_tensor_integration()

    #         # Initialize distributed runtime if enabled
    #         if self.is_distributed_enabled:
                self.init_distributed_runtime()

    #         # Initialize database backend if enabled
    #         if self.is_database_enabled:
                self.init_database_backend()
    self.is_database_enabled = True
    #             # Initialize modular database system
    self.database_module = DatabaseModule()
                self.database_module.initialize()

    #     def _builtin_print(self, *args):
    #         """Built-in print function implementation."""
            print(*args)

    #     def _builtin_len(self, obj):
    #         """Built-in len function implementation."""
            return len(obj)

    #     def _builtin_str(self, obj):
    #         """Built-in str function implementation."""
            return str(obj)

    #     def _builtin_int(self, obj):
    #         """Built-in int function implementation."""
            return int(obj)

    #     def _builtin_float(self, obj):
    #         """Built-in float function implementation."""
            return float(obj)

    #     def _builtin_bool(self, obj):
    #         """Built-in bool function implementation."""
            return bool(obj)

    #     def _handle_division_by_zero_error(self, error):
    #         """Handle division by zero errors."""
            raise RuntimeError("Division by zero error")

    #     def _handle_overflow_error(self, error):
    #         """Handle overflow errors."""
            raise RuntimeError("Overflow error")

    #     def _handle_underflow_error(self, error):
    #         """Handle underflow errors."""
            raise RuntimeError("Underflow error")

    #     def _handle_invalid_operation_error(self, error):
    #         """Handle invalid operation errors."""
            raise RuntimeError("Invalid operation error")

    #     def _handle_type_error(self, error):
    #         """Handle type errors."""
            raise RuntimeError("Type error")

    #     def _handle_value_error(self, error):
    #         """Handle value errors."""
            raise RuntimeError("Value error")

    #     def _handle_index_error(self, error):
    #         """Handle index errors."""
            raise RuntimeError("Index error")

    #     def _handle_key_error(self, error):
    #         """Handle key errors."""
            raise RuntimeError("Key error")

    #     def _handle_cuda_launch_failure_error(self, error):
    #         """Handle CUDA launch failure errors."""
            raise RuntimeError("CUDA launch failure error")

    #     def _handle_matrix_overflow(self, error):
    #         """Handle matrix overflow errors."""
            raise RuntimeError("Matrix overflow error")

    #     def _handle_tensor_dimension_mismatch(self, error):
    #         """Handle tensor dimension mismatch errors."""
            raise RuntimeError("Tensor dimension mismatch error")

    #     def _handle_matrix_singular(self, error):
    #         """Handle matrix singular errors."""
            raise RuntimeError("Matrix singular error")

    #     def _handle_gpu_memory_error(self, error):
    #         """Handle GPU memory errors."""
            raise RuntimeError("GPU memory error")

    #     def _handle_computation_timeout(self, error):
    #         """Handle computation timeout errors."""
            raise RuntimeError("Computation timeout error")

    #     def init_python_ffi(self):
    #         """Initialize Python FFI environment"""
    #         # Initialize Python modules dictionary
    self.python_modules = {}

    #         # Initialize Python functions dictionary
    self.python_functions = {}

    #         # Initialize constants pool
    self.constants_pool = {}

    #         # Use bridge to preload allowed modules
    #         for module_name in self.allowed_modules:
    #             try:
    module = self.bridge.load_module(module_name)
    #                 if module:
    self.python_modules[module_name] = module

    #                     # Cache functions via introspection
    #                     for attr_name in dir(module):
    attr = getattr(module, attr_name)
    #                         if callable(attr):
    self.python_functions[f"{module_name}.{attr_name}"] = attr
    #             except Exception as e:
    #                 if self.is_debug:
                        print(
    #                         f"Warning: Could not preload Python module {module_name}: {e}"
    #                     )

    #     def init_matrix_runtime(self):
    #         """Initialize matrix runtime components"""
    #         from .matrix_runtime import get_matrix_runtime  # Lazy import

    #         # Initialize matrix runtime if enabled
    self.matrix_runtime = None
    self.is_matrix_enabled = False

    #         # Try to get matrix runtime instance
    #         try:
    self.matrix_runtime = get_matrix_runtime()
    self.is_matrix_enabled = True
                self.container.register(
    #                 "matrix_runtime", self.matrix_runtime
    #             )  # DI register

    #             if self.is_debug:
                    print("Matrix runtime initialized successfully")
    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Warning: Could not initialize matrix runtime: {e}")

    #     def init_mathematical_objects(self):
    #         """Initialize mathematical object system"""
            from .mathematical_objects import ( Lazy import
    #             ObjectType,
    #             create_mathematical_object,
    #             get_mathematical_object_type,
    #         )

    #         # Initialize mathematical object registry
    self.mathematical_objects = {}

    #         # Initialize object type registry
    self.object_types = {}

    #         # Initialize factory functions
    self.math_object_factory = create_mathematical_object
    self.get_object_type = get_mathematical_object_type
            self.container.register(
    #             "mathematical_factory", self.math_object_factory
    #         )  # DI register

    #         # Register basic mathematical object types
    #         for obj_type in ObjectType:
    self.object_types[obj_type.value] = obj_type

    #         if self.is_debug:
                print("Mathematical object system initialized successfully")

    #     def init_tensor_system(self):
    #         """Initialize tensor system"""
    #         # Initialize tensor registry
    self.tensors = {}

    #         # Initialize tensor operations
    self.tensor_operations = {}

    #         # Register basic tensor operations
    self.tensor_operations["add"] = self._tensor_add
    self.tensor_operations["subtract"] = self._tensor_subtract
    self.tensor_operations["multiply"] = self._tensor_multiply
    self.tensor_operations["divide"] = self._tensor_divide
    self.tensor_operations["transpose"] = self._tensor_transpose
    self.tensor_operations["dot"] = self._tensor_dot
    self.tensor_operations["contract"] = self._tensor_contract

    #         if self.is_debug:
                print("Tensor system initialized successfully")

    #     def _tensor_add(self, a, b):
    #         """Tensor addition operation"""
    #         return a + b

    #     def _tensor_subtract(self, a, b):
    #         """Tensor subtraction operation"""
    #         return a - b

    #     def _tensor_multiply(self, a, b):
    #         """Tensor multiplication operation"""
    #         return a * b

    #     def _tensor_divide(self, a, b):
    #         """Tensor division operation"""
    #         return a / b

    #     def _tensor_transpose(self, a):
    #         """Tensor transpose operation"""
    #         return a.T if hasattr(a, "T") else a

    #     def _tensor_dot(self, a, b):
    #         """Tensor dot product operation"""
    #         return a.dot(b) if hasattr(a, "dot") else a * b

    #     def _tensor_contract(self, a, b, axes):
    #         """Tensor contraction operation"""
    #         return a  # Placeholder implementation

    #     def setup_matrix_tensor_performance_optimizations(self):
    #         """Setup matrix and tensor performance optimizations"""
    #         # Initialize performance optimization registry
    self.performance_optimizations = {}

    #         # Register basic optimizations
    self.performance_optimizations["matrix_multiply"] = (
    #             self._optimize_matrix_multiply
    #         )
    self.performance_optimizations["tensor_operations"] = (
    #             self._optimize_tensor_operations
    #         )
    self.performance_optimizations["gpu_acceleration"] = (
    #             self._optimize_gpu_acceleration
    #         )
    self.performance_optimizations["memory_layout"] = self._optimize_memory_layout

    #         if self.is_debug:
                print("Matrix and tensor performance optimizations initialized")

    #     def _optimize_matrix_multiply(self, operation):
    #         """Optimize matrix multiplication operations"""
    #         # Placeholder for matrix multiplication optimization
    #         if self.is_debug:
                print("Matrix multiplication optimization applied")
    #         return operation

    #     def _optimize_tensor_operations(self, operation):
    #         """Optimize tensor operations"""
    #         # Placeholder for tensor operation optimization
    #         if self.is_debug:
                print("Tensor operations optimization applied")
    #         return operation

    #     def _optimize_gpu_acceleration(self, operation):
    #         """Optimize GPU acceleration"""
    #         # Placeholder for GPU acceleration optimization
    #         if self.is_debug:
                print("GPU acceleration optimization applied")
    #         return operation

    #     def _optimize_memory_layout(self, operation):
    #         """Optimize memory layout"""
    #         # Placeholder for memory layout optimization
    #         if self.is_debug:
                print("Memory layout optimization applied")
    #         return operation

    #     def setup_matrix_tensor_error_handling(self):
    #         """Setup enhanced matrix and tensor error handling"""
    #         # Initialize error handling registry
    self.matrix_tensor_error_handlers = {}

    #         # Register error handlers
    self.matrix_tensor_error_handlers["dimension_mismatch"] = (
    #             self._handle_dimension_mismatch
    #         )
    self.matrix_tensor_error_handlers["singular_matrix"] = (
    #             self._handle_singular_matrix
    #         )
    self.matrix_tensor_error_handlers["gpu_error"] = self._handle_gpu_error

    #         if self.is_debug:
                print("Matrix and tensor error handling initialized")

    #     def _handle_dimension_mismatch(self, error):
    #         """Handle dimension mismatch errors"""
            raise RuntimeError(f"Dimension mismatch: {error}")

    #     def _handle_singular_matrix(self, error):
    #         """Handle singular matrix errors"""
            raise RuntimeError(f"Singular matrix: {error}")

    #     def _handle_gpu_error(self, error):
    #         """Handle GPU-related errors"""
            raise RuntimeError(f"GPU error: {error}")

    #     def enhance_matrix_tensor_integration(self):
    #         """Enhance matrix and tensor integration"""
    #         # Initialize integration registry
    self.matrix_tensor_integration = {}

    #         # Register integration functions
    self.matrix_tensor_integration["convert_matrix_to_tensor"] = (
    #             self._convert_matrix_to_tensor
    #         )
    self.matrix_tensor_integration["convert_tensor_to_matrix"] = (
    #             self._convert_tensor_to_matrix
    #         )
    self.matrix_tensor_integration["unified_operations"] = (
    #             self._unified_matrix_tensor_operations
    #         )

    #         if self.is_debug:
                print("Matrix and tensor integration enhanced")

    #     def _convert_matrix_to_tensor(self, matrix):
    #         """Convert matrix to tensor"""
    #         # Placeholder implementation
    #         return matrix

    #     def _convert_tensor_to_matrix(self, tensor):
    #         """Convert tensor to matrix"""
    #         # Placeholder implementation
    #         return tensor

    #     def _unified_matrix_tensor_operations(self, operation):
    #         """Provide unified operations for matrices and tensors"""
    #         # Placeholder implementation
    #         return operation

    #     def init_distributed_runtime(self):
    #         """Initialize distributed runtime components"""
            from .distributed import ( Lazy import
    #             DistributedRuntime,
    #             get_distributed_runtime,
    #         )

    #         try:
    self.distributed_runtime = get_distributed_runtime()
    self.is_distributed_enabled = True
                self.container.register(
    #                 "distributed_runtime", self.distributed_runtime
    #             )  # DI register
    #             # Register scheduler via distributed
    scheduler = self.distributed_runtime.scheduler
                self.container.register("scheduler", scheduler)

    #             if self.is_debug:
                    print("Distributed runtime initialized successfully")
    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Warning: Could not initialize distributed runtime: {e}")
    self.is_distributed_enabled = False

    #     def init_database_backend(self):
    #         """Initialize database backend components"""
    #         from .database import DatabaseModule  # Lazy import

    #         try:
    #             # Initialize database connection and state
    self.database_state["connected"] = True
    self.database_state["last_operation"] = "initialization"
    self.database_module = DatabaseModule()
                self.database_module.initialize()
                self.container.register(
    #                 "database_module", self.database_module
    #             )  # DI register

    #             if self.is_debug:
                    print("Database backend initialized successfully")
    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Warning: Could not initialize database backend: {e}")
    self.database_state["connected"] = False

    versioned(version = "1.0.0")
    #     def load_bytecode(self, bytecode: List[BytecodeInstruction]):
    #         """Load bytecode instructions into the runtime"""
    self.bytecode = bytecode
    self.program_counter = 0

    #         if self.is_debug:
                print(f"Loaded {len(bytecode)} bytecode instructions")

    versioned(version = "1.0.0")
    #     def execute(self) -Any):
    #         """
    #         Execute the loaded bytecode

    #         Returns:
    #             The result of program execution
    #         """
    #         if not self.bytecode:
                raise RuntimeError("No bytecode loaded")

    #         try:
    #             while self.program_counter < len(self.bytecode):
    instruction = self.bytecode[self.program_counter]

    #                 if self.is_debug:
                        print(
    #                         f"Executing instruction {self.program_counter}: {instruction}"
    #                     )

    #                 # Execute the instruction
                    self._execute_instruction(instruction)

    #                 # Increment program counter
    self.program_counter + = 1

    #                 # Check for halt condition
    #                 if instruction.opcode == OpCode.HALT:
    #                     break

    #             # Return the top of the stack if available
    #             if self.stack:
    #                 return self.stack[-1]
    #             return None

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Execution error at instruction {self.program_counter}: {e}")
                    print(f"Stack trace: {traceback.format_exc()}")
                raise RuntimeError(
    #                 f"Execution failed at instruction {self.program_counter}: {e}"
    #             )

    #     def _execute_instruction(self, instruction: BytecodeInstruction):
    #         """Execute a single bytecode instruction"""
    opcode = instruction.opcode
    operands = instruction.operands

    #         # Map opcodes to their handlers
    opcode_handlers = {
    #             OpCode.PUSH: self._op_push,
    #             OpCode.POP: self._op_pop,
    #             OpCode.ADD: self._op_add,
    #             OpCode.SUB: self._op_sub,
    #             OpCode.MUL: self._op_mul,
    #             OpCode.DIV: self._op_div,
    #             OpCode.PRINT: self._op_print,
    #             OpCode.STORE: self._op_store,
    #             OpCode.LOAD: self._op_load,
    #             OpCode.CALL: self._op_call,
    #             OpCode.RETURN: self._op_return,
    #             OpCode.JUMP: self._op_jump,
    #             OpCode.JUMP_IF_FALSE: self._op_jump_if_false,
    #             OpCode.EQUAL: self._op_equal,
    #             OpCode.LESS_THAN: self._op_less_than,
    #             OpCode.GREATER_THAN: self._op_greater_than,
    #             OpCode.PYTHON_IMPORT: self._op_python_import,
    #             OpCode.PYTHON_CALL: self._op_python_call,
    #             OpCode.JS_IMPORT: self._op_js_import,
    #             OpCode.JS_CALL: self._op_js_call,
    #             OpCode.HALT: self._op_halt,
    #         }

    #         # Get the handler for this opcode
    handler = opcode_handlers.get(opcode)
    #         if handler:
                handler(operands)
    #         else:
                raise RuntimeError(f"Unknown opcode: {opcode}")

    #     def _op_push(self, operands):
    #         """Push operation"""
    #         if len(operands) 0):
                self.stack.append(operands[0])

    #     def _op_pop(self, operands):
    #         """Pop operation"""
    #         if self.stack:
                self.stack.pop()

    #     def _op_add(self, operands):
    #         """Add operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a + b)

    #     def _op_sub(self, operands):
    #         """Subtract operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a - b)

    #     def _op_mul(self, operands):
    #         """Multiply operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a * b)

    #     def _op_div(self, operands):
    #         """Divide operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
    #             if b = 0:
                    self._handle_division_by_zero_error("Division by zero")
                self.stack.append(a / b)

    #     def _op_print(self, operands):
    #         """Print operation"""
    #         if self.stack:
    value = self.stack.pop()
                print(value)

    #     def _op_store(self, operands):
    #         """Store operation"""
    #         if len(operands) >= 1 and self.stack:
    var_name = operands[0]
    value = self.stack.pop()
    #             if self.current_frame:
    self.current_frame.locals[var_name] = value
    #             else:
    self.globals[var_name] = value

    #     def _op_load(self, operands):
    #         """Load operation"""
    #         if len(operands) >= 1:
    var_name = operands[0]
    #             if self.current_frame and var_name in self.current_frame.locals:
                    self.stack.append(self.current_frame.locals[var_name])
    #             elif var_name in self.globals:
                    self.stack.append(self.globals[var_name])
    #             else:
                    raise RuntimeError(f"Variable not found: {var_name}")

    #     def _op_call(self, operands):
    #         """Call operation"""
    #         if len(operands) >= 1:
    func_name = operands[0]
    #             if func_name in self.builtins:
    #                 # Handle built-in functions
    args = []
    #                 if len(operands) 1):
    num_args = operands[1]
    #                     for _ in range(num_args):
    #                         if self.stack:
                                args.insert(0, self.stack.pop())

    result = self.builtins[func_name]( * args)
    #                 if result is not None:
                        self.stack.append(result)
    #             else:
                    raise RuntimeError(f"Unknown function: {func_name}")

    #     def _op_return(self, operands):
    #         """Return operation"""
    #         # Placeholder for return logic
    #         pass

    #     def _op_jump(self, operands):
    #         """Jump operation"""
    #         if len(operands) >= 1:
    self.program_counter = (
    #                 operands[0] - 1
    #             )  # -1 because we increment after execution

    #     def _op_jump_if_false(self, operands):
    #         """Jump if false operation"""
    #         if len(operands) >= 1 and self.stack:
    condition = self.stack.pop()
    #             if not condition:
    self.program_counter = operands[0] - 1

    #     def _op_equal(self, operands):
    #         """Equal operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
    self.stack.append(a == b)

    #     def _op_less_than(self, operands):
    #         """Less than operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a < b)

    #     def _op_greater_than(self, operands):
    #         """Greater than operation"""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a b)

    #     def _op_python_import(self, operands)):
    #         """Python import operation"""
    #         if operands and isinstance(operands[0], str):
    module_name = operands[0]
    #             try:
    module = self.bridge.load_module(module_name)
    #                 if module:
    self.python_modules[module_name] = module
    #                     # Update function cache
    #                     for attr_name in dir(module):
    attr = getattr(module, attr_name)
    #                         if callable(attr):
    self.python_functions[f"{module_name}.{attr_name}"] = attr
    #                     # Push the module to stack for use
                        self.stack.append(module)
    #                     if self.is_debug:
                            print(f"Successfully imported module via bridge: {module_name}")
    #                 else:
                        raise RuntimeError(f"Bridge failed to load module {module_name}")
    #             except Exception as e:
    #                 if self.is_debug:
                        print(f"Failed to import module {module_name}: {e}")
                    raise RuntimeError(f"Failed to import module {module_name}: {e}")

    #     def _op_python_call(self, operands):
    #         """Python call operation"""
    #         if operands and isinstance(operands[0], str):
    #             # Parse func_name as module.func
    #             if "." in operands[0]:
    module_name, func_name = operands[0].rsplit(".", 1)
    #             else:
    module_name = None
    func_name = operands[0]

    args = []
    kwargs = {}  # For future use
    #             if len(operands) 1):
    num_args = operands[1]
    #                 for _ in range(num_args):
    #                     if self.stack:
                            args.insert(0, self.stack.pop())

    #             try:
    #                 # Use bridge for dynamic call with conversion
    #                 if module_name:
    result = self.python_bridge.call_external(
    module_name = module_name,
    func_name = func_name,
    args = args,
    kwargs = kwargs,
    project = "noodle-runtime",
    noodle_runtime = self,
    #                     )
    #                 else:
    #                     # Direct func if no module (from preloaded)
    #                     if func_name in self.python_functions:
    result = self.python_functions[func_name]( * args)
    #                     else:
                            raise RuntimeError(f"Python function not found: {func_name}")

    #                 if result is not None:
                        self.stack.append(result)
    #             except Exception as e:
                    raise PythonFFIError(f"Python function call failed: {e}") from e
    #             if self.is_debug:
                    print(f"Successfully called Python function: {operands[0]}")
    #         else:
                raise RuntimeError("PYTHON_CALL requires function name operand")

    #     def _op_js_import(self, operands):
    #         """JS import/eval operation"""
    #         if operands and isinstance(operands[0], str):
    code_or_module = operands[0]
    #             try:
    #                 if code_or_module.endswith(".js") or "." in code_or_module:
    #                     # Assume module name; load via bridge
    module = self.js_bridge.load_module(code_or_module)
    #                     if module:
                            self.stack.append(module)
    #                         if self.is_debug:
                                print(f"Successfully imported JS module: {code_or_module}")
    #                     else:
                            raise RuntimeError(
    #                             f"JS bridge failed to load module {code_or_module}"
    #                         )
    #                 else:
    #                     # Eval code
    result = self.js_bridge.evaluate_expression(code_or_module)
                        self.stack.append(result)
    #                     if self.is_debug:
                            print(f"Successfully evaluated JS code")
    #             except Exception as e:
    #                 if self.is_debug:
                        print(f"Failed to import/eval JS: {e}")
                    raise JSFFIError(f"JS import/eval failed: {e}")
    #         else:
                raise RuntimeError("JS_IMPORT requires code or module operand")

    #     def _op_js_call(self, operands):
    #         """JS call operation"""
    #         if operands and isinstance(operands[0], str):
    #             if "." in operands[0]:
    module_name, func_name = operands[0].rsplit(".", 1)
    #             else:
    module_name = None
    func_name = operands[0]

    args = []
    #             if len(operands) 1):
    num_args = operands[1]
    #                 for _ in range(num_args):
    #                     if self.stack:
                            args.insert(0, self.stack.pop())

    #             try:
    result = self.js_bridge.call_function(
    module = module_name,
    func_name = func_name,
    args = args,
    project = "noodle-runtime",
    #                 )
    #                 if result is not None:
                        self.stack.append(result)
    #                 if self.is_debug:
                        print(f"Successfully called JS function: {operands[0]}")
    #             except Exception as e:
                    raise JSFFIError(f"JS function call failed: {e}")
    #         else:
                raise RuntimeError("JS_CALL requires function name operand")

    #     def _op_halt(self, operands):
    #         """Halt operation"""
    #         # This will be handled in the main execution loop
    #         pass

    #     def optimize_mathematical_object_operations(self):
    #         """Optimize mathematical object operations"""
    #         if self.is_matrix_enabled and self.matrix_runtime:
                self.matrix_runtime.optimize_operations()
    #         if self.is_debug:
                print("Mathematical object operations optimized")

    #     def get_mathematical_object_stats(self):
    #         """Get mathematical object statistics"""
    #         return {
                "total_objects": len(self.mathematical_objects),
                "object_types": len(self.object_types),
    #             "tensors": len(self.tensors) if hasattr(self, "tensors") else 0,
    #         }


versioned(version = "1.0.0")
def run_bytecode(bytecode: List[BytecodeInstruction], is_debug: bool = False) -Any):
#     """
#     Convenience function to run NBC bytecode

#     Args:
#         bytecode: List of bytecode instructions to execute
#         debug: Whether to enable debug mode

#     Returns:
#         The result of program execution
#     """
runtime = NBCRuntime(debug=debug)
    runtime.load_bytecode(bytecode)
    return runtime.execute()


__all__ = ["NBCRuntime", "run_bytecode", "RuntimeError", "PythonFFIError", "StackFrame"]

if __name__ == "__main__"
    #     from .code_generator import CodeGenerator  # Adjusted import

    #     # Generate some test bytecode
    generator = CodeGenerator(debug=True)

    #     # Simple program: print "Hello, World!"
    test_bytecode = [
            BytecodeInstruction(OpCode.PUSH, ['"Hello, World!"']),
            BytecodeInstruction(OpCode.PRINT),
    #     ]

        print("Testing NBC Runtime...")
    result = run_bytecode(test_bytecode, debug=True)
        print(f"Program result: {result}")

    #     # Test with arithmetic
    test_bytecode2 = [
            BytecodeInstruction(OpCode.PUSH, ["5"]),
            BytecodeInstruction(OpCode.PUSH, ["3"]),
            BytecodeInstruction(OpCode.ADD),
            BytecodeInstruction(OpCode.PRINT),
    #     ]

        print("\nTesting arithmetic...")
    result2 = run_bytecode(test_bytecode2, debug=True)
        print(f"Program result: {result2}")
