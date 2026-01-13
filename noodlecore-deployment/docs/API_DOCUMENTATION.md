# NoodleCore API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Core Architecture](#core-architecture)
3. [Compiler API](#compiler-api)
4. [Runtime API](#runtime-api)
5. [Database API](#database-api)
6. [Mathematical Objects API](#mathematical-objects-api)
7. [Optimization API](#optimization-api)
8. [System Integration API](#system-integration-api)
9. [Error Handling API](#error-handling-api)
10. [Best Practices](#best-practices)
11. [Migration Guide](#migration-guide)

## Overview

NoodleCore provides a comprehensive set of APIs for high-performance programming language execution, mathematical computing, database operations, and system integration. This documentation covers all public interfaces and provides guidance for proper usage.

### Key Components

- **Compiler API**: Lexical analysis, parsing, semantic analysis, and code generation
- **Runtime API**: Execution environment, bytecode interpretation, and FFI support
- **Database API**: Multi-backend database operations with plugin architecture
- **Mathematical Objects API**: Matrix, tensor, vector, and scalar operations
- **Optimization API**: JIT compilation, profiling, and caching
- **System Integration API**: Distributed computing and resource management

## Core Architecture

### Package Structure

```
noodlecore/
├── __init__.py          # Main public API exports
├── compiler/            # Compilation pipeline
├── runtime/             # Execution environment
├── database/            # Database operations
├── mathematical_objects/ # Mathematical computing
├── optimization/        # Performance optimization
├── system_integration/  # System integration
└── api/                 # REST and version APIs
```

### Version Information

```python
import noodlecore

print(noodlecore.__version__)  # "0.1.0"
print(noodlecore.__author__)   # "Michael van Erp"
```

## Compiler API

### Core Classes

#### `Lexer`
```python
from noodlecore.compiler import Lexer

# Initialize lexer
lexer = Lexer()

# Tokenize source code
tokens = lexer.tokenize(source_code, filename)

# Get token stream
for token in tokens:
    print(f"{token.type}: {token.value}")
```

#### `Parser`
```python
from noodlecore.compiler import Parser

# Initialize parser
parser = Parser()

# Parse tokens into AST
ast = parser.parse(tokens)

# Get parse tree
print(ast.dump())
```

#### `SemanticAnalyzer`
```python
from noodlecore.compiler import SemanticAnalyzer

# Initialize semantic analyzer
analyzer = SemanticAnalyzer()

# Analyze AST
analysis_result = analyzer.analyze(ast, symbol_table)

# Get type information
type_info = analyzer.get_type_info(node)
```

#### `NoodleCompiler`
```python
from noodlecore.compiler import NoodleCompiler

# Initialize compiler
compiler = NoodleCompiler()

# Compile source code
bytecode, errors = compiler.compile_source(source_code, filename)

# Execute compiled code
result = compiler.execute(bytecode)
```

### Convenience Functions

#### `compile_code()`
```python
from noodlecore import compile_code

# Compile and execute in one step
bytecode = compile_code("x = 5 + 3", "example.noodle")
```

#### `execute_code()`
```python
from noodlecore import execute_code

# Execute Noodle source directly
result = execute_code("print('Hello, World!')")
```

## Runtime API

### Core Classes

#### `RuntimeEnvironment`
```python
from noodlecore.runtime import RuntimeEnvironment

# Initialize runtime
runtime = RuntimeEnvironment()

# Execute bytecode
result = runtime.execute(bytecode)

# Get system status
status = runtime.get_system_status()
```

#### `NBCRuntime`
```python
from noodlecore.runtime.nbc_runtime.core import NBCRuntime

# Initialize NBC runtime
nbc_runtime = NBCRuntime(is_debug=True, is_distributed_enabled=True)

# Load bytecode
nbc_runtime.load_bytecode(bytecode)

# Execute program
result = nbc_runtime.execute()
```

### Value Types

#### `Value`
```python
from noodlecore.runtime import Value, RuntimeType

# Create runtime values
int_value = Value(RuntimeType.INTEGER, 42)
str_value = Value(RuntimeType.STRING, "hello")
bool_value = Value(RuntimeType.BOOLEAN, True)

# Check truthiness
if int_value.truthy():
    print("Value is truthy")
```

#### `Function`
```python
from noodlecore.runtime import Function

# Create function
def my_function(x, y):
    return x + y

func = Function(
    name="add",
    parameters=["x", "y"],
    body=my_function,
    closure={},
    built_in=True,
    native_func=my_function
)
```

### FFI Support

#### Python Bridge
```python
from noodlecore.runtime import RuntimeEnvironment

runtime = RuntimeEnvironment()

# Import Python module
runtime.python_bridge.import_module("numpy")

# Call Python function
result = runtime.python_bridge.call_function("numpy", "array", [1, 2, 3])
```

#### JavaScript Bridge
```python
# Import JavaScript module
runtime.js_bridge.import_module("math")

# Call JavaScript function
result = runtime.js_bridge.call_function("math", "sqrt", 16)
```

## Database API

### Core Classes

#### `DatabaseManager`
```python
from noodlecore.database import DatabaseManager

# Initialize database manager
db_manager = DatabaseManager()

# Add connection
db_manager.add_connection("main", "sqlite:///example.db")

# Execute query
result = db_manager.execute_query("SELECT * FROM users")
```

#### `DatabaseConnection`
```python
from noodlecore.database import DatabaseConnection

# Create connection
conn = DatabaseConnection("sqlite:///example.db", DatabaseType.SQLITE)

# Begin transaction
with conn.transaction() as tx:
    tx.execute("INSERT INTO users (name) VALUES (?)", ["John Doe"])
```

### High-Level Interface

#### Connection Management
```python
from noodlecore.database import connect, disconnect

# Connect to database
conn = connect("main", "sqlite:///example.db")

# Disconnect
disconnect("main")
```

#### Data Operations
```python
from noodlecore.database import insert, select, update, delete

# Insert data
insert("users", {"name": "John", "age": 30})

# Select data
users = select("users", columns=["name", "age"], where_clause="age > ?", params=[25])

# Update data
update("users", {"age": 31}, "name = ?", params=["John"])

# Delete data
delete("users", "age < ?", params=[18])
```

#### Transaction Management
```python
from noodlecore.database import transaction

# Use transaction context manager
with transaction("main") as tx:
    tx.execute("INSERT INTO logs (message) VALUES (?)", ["User created"])
    # Auto-commits on success, rolls back on exception
```

## Mathematical Objects API

### Core Classes

#### `Matrix`
```python
from noodlecore.mathematical_objects import Matrix
import numpy as np

# Create matrix
matrix = Matrix([[1, 2], [3, 4]])

# Matrix operations
result = matrix.multiply(matrix)
transposed = matrix.transpose()

# GPU acceleration
result_gpu = matrix.multiply(other_matrix, device="gpu")
```

#### `Tensor`
```python
from noodlecore.mathematical_objects import Tensor

# Create tensor
tensor = Tensor(np.random.randn(2, 3, 4))

# Tensor operations
result = tensor.add(other_tensor)
matmul_result = tensor.matmul(other_tensor)
```

#### `Vector`
```python
from noodlecore.mathematical_objects import Vector

# Create vector
vector = Vector([1, 2, 3, 4])

# Vector operations
dot_product = vector.dot(other_vector)
cross_product = vector.cross(other_vector)
normalized = vector.normalize()
```

#### `Scalar`
```python
from noodlecore.mathematical_objects import Scalar

# Create scalar
scalar = Scalar(42.0)

# Scalar operations
result = scalar.add(Scalar(10.0))
product = scalar.multiply(Scalar(2.0))
```

### Mathematical Operations

#### Hot Path Operations
```python
# Matrix operations with JIT compilation
@hot_path
def matrix_multiply_optimized(a, b):
    return a.multiply(b)

# Tensor operations with GPU acceleration
result = tensor.matmul(other_tensor).to("gpu")
```

## Optimization API

### Core Classes

#### `JITCompiler`
```python
from noodlecore.optimization import JITCompiler, JITConfig

# Configure JIT compiler
config = JITConfig(
    optimization_level=2,
    enable_mlir=True,
    hot_threshold=100
)

compiler = JITCompiler(config)

# Compile function
compiled_func = compiler.jit_compile(my_function)
```

#### `CodeProfiler`
```python
from noodlecore.optimization import CodeProfiler, ProfileConfig

# Configure profiler
config = ProfileConfig(
    enabled=True,
    memory_tracking=True,
    cpu_tracking=True
)

profiler = CodeProfiler(config)

# Profile function
profile_result = profiler.profile_function(my_function)
```

#### `JITCache`
```python
from noodlecore.optimization import JITCache, CacheConfig

# Configure cache
config = CacheConfig(
    max_size=1000,
    default_ttl=3600.0,
    eviction_policy="lru"
)

cache = JITCache(config)

# Cache function result
result = cache.get_or_compute("key", compute_function)
```

### Decorators

#### Profiling Decorator
```python
from noodlecore.optimization import profile_function

@profile_function(time_threshold=0.001)
def expensive_computation():
    # Your expensive computation here
    return result
```

#### JIT Compilation Decorator
```python
from noodlecore.optimization import jit_compile

@jit_compile(optimization_level=2)
def hot_function(x, y):
    # Frequently called function
    return x + y
```

## System Integration API

### Core Classes

#### `SystemIntegration`
```python
from noodlecore.system_integration import SystemIntegration

# Initialize system integration
system = SystemIntegration(config)

# Get system status
status = system.get_system_status()

# Execute code with system integration
result = system.execute_code("print('Hello, System!')")
```

#### `SystemConfig`
```python
from noodlecore.system_integration import SystemConfig

# Configure system
config = SystemConfig(
    enable_database=True,
    enable_distributed=True,
    enable_gpu=True,
    debug_mode=True
)
```

### Distributed Computing

#### Placement Engine
```python
from noodlecore.runtime.distributed.placement_engine import get_placement_engine

engine = get_placement_engine()

# Place tensor on optimal device
placement = engine.place_tensor(
    "operation_name",
    tensor_size,
    tensor_shape,
    data_type,
    constraints=[PlacementConstraint(ConstraintType.GPU_ONLY)]
)
```

## Error Handling API

### Core Classes

#### `ErrorHandler`
```python
from noodlecore.error_handler import ErrorHandler

# Initialize error handler
error_handler = ErrorHandler()

# Handle error
error_handler.handle_error(error, context="compilation")
```

#### `ErrorReporter`
```python
from noodlecore.error_reporting import ErrorReporter

# Initialize error reporter
reporter = ErrorReporter()

# Report error
reporter.report_error(
    error_code="E001",
    message="Syntax error",
    file_path="example.noodle",
    line_number=5
)
```

### Error Categories

#### Compiler Errors
```python
# Syntax errors (E1xx)
E101: Unexpected token
E102: Missing token
E103: Unterminated structure

# Semantic errors (E2xx)
E201: Variable redeclaration
E202: Undeclared variable
E203: Function call issues

# Type errors (E3xx)
E301: Type mismatch
E302: Invalid type conversion
E303: Unsupported operation
```

#### Runtime Errors
```python
# Runtime errors (E4xx)
E401: Division by zero
E402: Index out of bounds
E403: Null reference

# System errors (E6xx)
E601: File not found
E602: Permission denied
E603: Disk full
```

## Best Practices

### 1. API Usage Patterns

#### Proper Resource Management
```python
# Always use context managers for database connections
with transaction("main") as tx:
    tx.execute("INSERT INTO table VALUES (?)", [value])

# Always close resources when done
runtime.close()
db_manager.close()
```

#### Error Handling
```python
# Use proper error handling
try:
    result = execute_code(code)
except CompilationError as e:
    print(f"Compilation error: {e}")
except RuntimeError as e:
    print(f"Runtime error: {e}")
except Exception as e:
    print(f"Unexpected error: {e}")
```

### 2. Performance Optimization

#### Use JIT Compilation for Hot Paths
```python
# Mark frequently called functions for JIT compilation
@jit_compile(optimization_level=2)
def matrix_multiply(a, b):
    return a.multiply(b)
```

#### Use GPU Acceleration
```python
# Offload heavy computations to GPU
result = matrix.multiply(other_matrix, device="gpu")
```

#### Use Caching for Expensive Operations
```python
# Cache expensive function results
@cache_result(ttl=3600.0)
def expensive_computation(params):
    return result
```

### 3. Code Organization

#### Use Proper Imports
```python
# Import specific modules
from noodlecore.compiler import NoodleCompiler
from noodlecore.database import DatabaseManager
from noodlecore.mathematical_objects import Matrix

# Avoid wildcard imports
# from noodlecore import *  # Not recommended
```

#### Use Type Hints
```python
from typing import List, Dict, Optional
from noodlecore.mathematical_objects import Matrix

def process_matrices(matrices: List[Matrix]) -> Optional[Matrix]:
    if not matrices:
        return None
    return matrices[0].multiply(matrices[1])
```

## Migration Guide

### Breaking Changes

#### Version 0.1.0 to 0.2.0

1. **Database API Changes**
   ```python
   # Old way
   db.execute_query("SELECT * FROM table")
   
   # New way
   db_manager.execute_query("SELECT * FROM table")
   ```

2. **Runtime API Changes**
   ```python
   # Old way
   runtime.execute_bytecode(bytecode)
   
   # New way
   runtime.execute()
   ```

3. **Compiler API Changes**
   ```python
   # Old way
   compiler.compile(source_code)
   
   # New way
   compiler.compile_source(source_code, filename)
   ```

### Migration Steps

1. **Update Database Usage**
   ```python
   # Before
   from noodlecore.database import Database
   db = Database()
   result = db.execute_query("SELECT * FROM users")
   
   # After
   from noodlecore.database import DatabaseManager
   db_manager = DatabaseManager()
   result = db_manager.execute_query("SELECT * FROM users")
   ```

2. **Update Runtime Usage**
   ```python
   # Before
   from noodlecore.runtime import Runtime
   runtime = Runtime()
   result = runtime.execute_bytecode(bytecode)
   
   # After
   from noodlecore.runtime import RuntimeEnvironment
   runtime = RuntimeEnvironment()
   result = runtime.execute(bytecode)
   ```

3. **Update Compiler Usage**
   ```python
   # Before
   from noodlecore.compiler import Compiler
   compiler = Compiler()
   result = compiler.compile(source_code)
   
   # After
   from noodlecore.compiler import NoodleCompiler
   compiler = NoodleCompiler()
   result = compiler.compile_source(source_code, filename)
   ```

### Backward Compatibility

#### Legacy Support
```python
# Use legacy compatibility layer
from noodlecore.legacy import LegacyCompiler

# Old API still works but with warnings
compiler = LegacyCompiler()
result = compiler.compile(source_code)  # Shows deprecation warning
```

#### Migration Assistant
```python
# Use migration assistant to update code
from noodlecore.migration import MigrationAssistant

assistant = MigrationAssistant()
assistant.update_imports("old_code.py")
assistant.update_api_calls("old_code.py")
```

## Examples

### Basic Compilation and Execution
```python
from noodlecore import compile_code, execute_code

# Compile code
bytecode = compile_code("x = 5 + 3 * 2")

# Execute code
result = execute_code("print(x)")
```

### Database Operations
```python
from noodlecore.database import connect, insert, select

# Connect to database
conn = connect("main", "sqlite:///example.db")

# Insert data
insert("users", {"name": "John", "age": 30})

# Query data
users = select("users", where_clause="age > ?", params=[25])
```

### Mathematical Computing
```python
from noodlecore.mathematical_objects import Matrix, Tensor
import numpy as np

# Create matrices
matrix_a = Matrix([[1, 2], [3, 4]])
matrix_b = Matrix([[5, 6], [7, 8]])

# Perform operations
result = matrix_a.multiply(matrix_b)
transposed = matrix_a.transpose()
```

### Performance Optimization
```python
from noodlecore.optimization import jit_compile, profile_function

# JIT compile hot function
@jit_compile(optimization_level=2)
def matrix_multiply(a, b):
    return a.multiply(b)

# Profile performance
@profile_function()
def expensive_computation():
    # Your expensive computation here
    return result
```

## Conclusion

This documentation provides a comprehensive overview of the NoodleCore API. For more detailed information about specific components, refer to the individual module documentation. Always follow best practices for error handling, resource management, and performance optimization to get the most out of NoodleCore.

For questions or issues, please refer to the project repository or create an issue in the project tracker.