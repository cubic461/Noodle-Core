# NoodleCore API Examples and Tutorials

## Table of Contents
1. [Getting Started](#getting-started)
2. [Compiler API Examples](#compiler-api-examples)
3. [Runtime API Examples](#runtime-api-examples)
4. [Database API Examples](#database-api-examples)
5. [Mathematical Objects API Examples](#mathematical-objects-api-examples)
6. [Optimization API Examples](#optimization-api-examples)
7. [System Integration Examples](#system-integration-examples)
8. [Advanced Examples](#advanced-examples)
9. [Performance Optimization Examples](#performance-optimization-examples)

## Getting Started

### Installation and Setup

```python
# Install NoodleCore
pip install noodlecore

# Basic import
import noodlecore
from noodlecore import compile_code, execute_code
from noodlecore.compiler import NoodleCompiler
from noodlecore.runtime import RuntimeEnvironment
from noodlecore.database import DatabaseManager
from noodlecore.mathematical_objects import Matrix, Vector
from noodlecore.optimization import JITCompiler, CodeProfiler
```

### Hello World Example

```python
# Simple Hello World
from noodlecore import execute_code

# Execute Noodle code directly
result = execute_code("print('Hello, NoodleCore!')")
print(f"Result: {result}")
```

## Compiler API Examples

### Basic Compilation

```python
from noodlecore.compiler import NoodleCompiler, Lexer, Parser, SemanticAnalyzer

# Initialize compiler components
compiler = NoodleCompiler()
lexer = Lexer()
parser = Parser()
semantic_analyzer = SemanticAnalyzer()

# Source code
source_code = """
x = 5 + 3 * 2
y = x * 4
print(y)
"""

# Step-by-step compilation
tokens = lexer.tokenize(source_code, "example.noodle")
print("Tokens:", tokens)

ast = parser.parse(tokens)
print("AST:", ast.dump())

analysis_result = semantic_analyzer.analyze(ast)
print("Analysis:", analysis_result)

bytecode, errors = compiler.compile_source(source_code, "example.noodle")
print("Bytecode:", bytecode)
print("Errors:", errors)
```

### Error Handling in Compilation

```python
from noodlecore.compiler import NoodleCompiler
from noodlecore.error_handler import ErrorHandler

# Initialize with error handling
compiler = NoodleCompiler()
error_handler = ErrorHandler()

# Code with errors
source_code = """
x = 5 +  # Missing expression
y = x * 
print(y)
"""

try:
    bytecode, errors = compiler.compile_source(source_code, "error_example.noodle")
    if errors:
        for error in errors:
            error_handler.handle_error(error, context="compilation")
    else:
        print("Compilation successful!")
except Exception as e:
    print(f"Compilation failed: {e}")
```

### Advanced Compilation Features

```python
from noodlecore.compiler import NoodleCompiler, DeploymentDSLParser

# Parse deployment configuration
deployment_parser = DeploymentDSLParser()
deployment_config = deployment_parser.parse("""
deployment:
  name: "example-app"
  version: "1.0.0"
  resources:
    cpu: "2"
    memory: "4Gi"
    gpu: "1"
""")

# Compile with deployment configuration
compiler = NoodleCompiler()
compiler.set_deployment_config(deployment_config)

bytecode = compiler.compile_source(source_code, "deployment_example.noodle")
```

## Runtime API Examples

### Basic Runtime Execution

```python
from noodlecore.runtime import RuntimeEnvironment, Value, RuntimeType

# Initialize runtime
runtime = RuntimeEnvironment()

# Create runtime values
x = Value(RuntimeType.INTEGER, 5)
y = Value(RuntimeType.INTEGER, 3)
z = Value(RuntimeType.INTEGER, x.data + y.data)

print(f"x = {x}")
print(f"y = {y}")
print(f"z = {z}")
```

### Bytecode Execution

```python
from noodlecore.runtime import RuntimeEnvironment
from noodlecore.compiler import NoodleCompiler

# Compile code
compiler = NoodleCompiler()
bytecode, errors = compiler.compile_source("x = 10; y = x * 2; print(y)", "example.noodle")

# Execute bytecode
runtime = RuntimeEnvironment()
result = runtime.execute(bytecode)
print(f"Execution result: {result}")
```

### FFI (Foreign Function Interface) Examples

#### Python Bridge

```python
from noodlecore.runtime import RuntimeEnvironment

# Initialize runtime with Python FFI
runtime = RuntimeEnvironment()

# Import Python module
runtime.python_bridge.import_module("numpy")

# Call Python function
array = runtime.python_bridge.call_function("numpy", "array", [1, 2, 3, 4, 5])
print(f"NumPy array: {array}")

# Use NumPy operations
mean = runtime.python_bridge.call_function("numpy", "mean", array)
print(f"Mean: {mean}")
```

#### JavaScript Bridge

```python
from noodlecore.runtime import RuntimeEnvironment

# Initialize runtime with JavaScript FFI
runtime = RuntimeEnvironment()

# Import JavaScript module
runtime.js_bridge.import_module("math")

# Call JavaScript function
sqrt_result = runtime.js_bridge.call_function("math", "sqrt", 16)
print(f"Square root of 16: {sqrt_result}")

# Use JavaScript Date
date = runtime.js_bridge.call_function("Date", "now")
print(f"Current timestamp: {date}")
```

### Advanced Runtime Features

```python
from noodlecore.runtime import RuntimeEnvironment, Function, Value, RuntimeType

# Create custom function
def custom_function(x, y):
    return x * y

func = Function(
    name="multiply",
    parameters=["x", "y"],
    body=custom_function,
    closure={},
    built_in=True,
    native_func=custom_function
)

# Add to runtime
runtime = RuntimeEnvironment()
runtime.built_ins["multiply"] = func

# Execute function
result = func.call([Value(RuntimeType.INTEGER, 5), Value(RuntimeType.INTEGER, 3)], runtime)
print(f"5 * 3 = {result.data}")
```

## Database API Examples

### Basic Database Operations

```python
from noodlecore.database import DatabaseManager, DatabaseType, connect, insert, select

# Initialize database manager
db_manager = DatabaseManager()

# Add connection
db_manager.add_connection("main", "sqlite:///example.db", DatabaseType.SQLITE)

# Create table
db_manager.create_table("users", {
    "id": {"type": "INTEGER", "primary_key": True, "autoincrement": True},
    "name": {"type": "TEXT", "nullable": False},
    "age": {"type": "INTEGER", "nullable": False},
    "email": {"type": "TEXT", "nullable": True}
})

# Insert data
insert("users", {"name": "John Doe", "age": 30, "email": "john@example.com"})
insert("users", {"name": "Jane Smith", "age": 25, "email": "jane@example.com"})

# Query data
users = select("users", columns=["name", "age"], where_clause="age > ?", params=[25])
print("Users older than 25:")
for user in users.rows:
    print(f"  {user['name']}, {user['age']} years old")
```

### Transaction Management

```python
from noodlecore.database import transaction, insert, select

# Use transaction context manager
try:
    with transaction("main") as tx:
        # Insert multiple records in a transaction
        insert("users", {"name": "Alice Johnson", "age": 28, "email": "alice@example.com"})
        insert("users", {"name": "Bob Wilson", "age": 35, "email": "bob@example.com"})
        
        # This will be committed if successful
        print("Transaction committed successfully")
except Exception as e:
    print(f"Transaction failed: {e}")
    # Transaction will be rolled back automatically
```

### Advanced Database Operations

```python
from noodlecore.database import DatabaseManager, update, delete, select

# Update data
update("users", {"age": 31}, "name = ?", params=["John Doe"])

# Delete data
delete("users", "age < ?", params=[18])

# Complex queries
adults = select(
    "users", 
    columns=["name", "email"], 
    where_clause="age >= ? AND email IS NOT NULL", 
    params=[18],
    order_by="name",
    limit=10
)

# Count records
user_count = select("users", columns=["COUNT(*) as count"])
print(f"Total users: {user_count.rows[0]['count']}")
```

### Multiple Database Backends

```python
from noodlecore.database import DatabaseManager, DatabaseType

# Initialize manager
db_manager = DatabaseManager()

# Add multiple connections
db_manager.add_connection("sqlite_db", "sqlite:///local.db", DatabaseType.SQLITE)
db_manager.add_connection("postgres_db", "postgresql://user:pass@localhost:5432/mydb", DatabaseType.POSTGRESQL)

# Switch between backends
db_manager.switch_backend("sqlite_db")
sqlite_result = db_manager.execute_query("SELECT * FROM users")

db_manager.switch_backend("postgres_db")
postgres_result = db_manager.execute_query("SELECT * FROM users")

print(f"SQLite users: {len(sqlite_result.rows)}")
print(f"PostgreSQL users: {len(postgres_result.rows)}")
```

## Mathematical Objects API Examples

### Basic Matrix Operations

```python
from noodlecore.mathematical_objects import Matrix
import numpy as np

# Create matrices
matrix_a = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
matrix_b = Matrix([[9, 8, 7], [6, 5, 4], [3, 2, 1]])

print("Matrix A:")
print(matrix_a.data)
print("Matrix B:")
print(matrix_b.data)

# Matrix operations
result_multiply = matrix_a.multiply(matrix_b)
result_add = matrix_a.add(matrix_b)
result_transpose = matrix_a.transpose()

print("A * B:")
print(result_multiply.data)
print("A + B:")
print(result_add.data)
print("A^T:")
print(result_transpose.data)
```

### Tensor Operations

```python
from noodlecore.mathematical_objects import Tensor
import numpy as np

# Create tensors
tensor_a = Tensor(np.random.randn(2, 3, 4))
tensor_b = Tensor(np.random.randn(2, 3, 4))

print("Tensor A shape:", tensor_a.dimensions)
print("Tensor B shape:", tensor_b.dimensions)

# Tensor operations
result_add = tensor_a.add(tensor_b)
result_matmul = tensor_a.matmul(tensor_b)

print("A + B shape:", result_add.dimensions)
print("A @ B shape:", result_matmul.dimensions)
```

### Vector Operations

```python
from noodlecore.mathematical_objects import Vector

# Create vectors
vector_a = Vector([1, 2, 3, 4])
vector_b = Vector([4, 3, 2, 1])

print("Vector A:", vector_a.data)
print("Vector B:", vector_b.data)

# Vector operations
dot_product = vector_a.dot(vector_b)
cross_product = vector_a.cross(vector_b)  # Only for 3D vectors
normalized = vector_a.normalize()

print("A · B:", dot_product)
print("A × B:", cross_product.data)
print("Normalized A:", normalized.data)
```

### Scalar Operations

```python
from noodlecore.mathematical_objects import Scalar

# Create scalars
scalar_a = Scalar(10.5)
scalar_b = Scalar(2.0)

print("Scalar A:", scalar_a.value)
print("Scalar B:", scalar_b.value)

# Scalar operations
result_add = scalar_a.add(scalar_b)
result_sub = scalar_a.subtract(scalar_b)
result_mul = scalar_a.multiply(scalar_b)
result_div = scalar_a.divide(scalar_b)

print("A + B:", result_add.value)
print("A - B:", result_sub.value)
print("A * B:", result_mul.value)
print("A / B:", result_div.value)
```

### Advanced Mathematical Operations

```python
from noodlecore.mathematical_objects import Matrix, Tensor
import numpy as np

# Matrix decomposition
matrix = Matrix([[4, 12], [-2, 5]])
eigenvalues, eigenvectors = np.linalg.eig(matrix.data)
print("Eigenvalues:", eigenvalues)
print("Eigenvectors:", eigenvectors)

# Tensor operations with different dimensions
tensor_2d = Tensor(np.random.randn(3, 4))
tensor_3d = Tensor(np.random.randn(3, 4, 5))

# Reshape tensor
reshaped = tensor_2d.reshape((2, 6))
print("Original shape:", tensor_2d.dimensions)
print("Reshaped shape:", reshaped.dimensions)

# Matrix power
matrix_power = matrix.multiply(matrix).multiply(matrix)
print("Matrix^3:")
print(matrix_power.data)
```

## Optimization API Examples

### JIT Compilation

```python
from noodlecore.optimization import JITCompiler, JITConfig
import time

# Configure JIT compiler
config = JITConfig(
    optimization_level=2,
    enable_mlir=True,
    hot_threshold=50
)

compiler = JITCompiler(config)

# Define a computationally expensive function
@jit_compile(optimization_level=2)
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Test performance
start_time = time.time()
result = fibonacci(35)
end_time = time.time()

print(f"Fibonacci(35) = {result}")
print(f"Execution time: {end_time - start_time:.4f} seconds")
```

### Code Profiling

```python
from noodlecore.optimization import CodeProfiler, ProfileConfig
import time

# Configure profiler
config = ProfileConfig(
    enabled=True,
    memory_tracking=True,
    cpu_tracking=True,
    time_threshold=0.001
)

profiler = CodeProfiler(config)

# Profile a function
@profile_function()
def expensive_computation(n):
    result = 0
    for i in range(n):
        result += i ** 2
    return result

# Run and get profile
result = expensive_computation(1000000)
profile_result = profiler.get_profile_result("expensive_computation")

print(f"Computation result: {result}")
print(f"Profile result: {profile_result}")
```

### Caching

```python
from noodlecore.optimization import JITCache, CacheConfig
import time

# Configure cache
config = CacheConfig(
    max_size=1000,
    default_ttl=3600.0,
    eviction_policy="lru"
)

cache = JITCache(config)

# Cache expensive function
@cache_result(ttl=300.0)  # Cache for 5 minutes
def expensive_data_processing(data):
    print("Processing data...")
    time.sleep(2)  # Simulate expensive operation
    return sum(data)

# Test caching
data = list(range(1000))

# First call (will compute)
start_time = time.time()
result1 = expensive_data_processing(data)
end_time = time.time()
print(f"First call: {end_time - start_time:.2f} seconds")

# Second call (will use cache)
start_time = time.time()
result2 = expensive_data_processing(data)
end_time = time.time()
print(f"Second call: {end_time - start_time:.2f} seconds")

print(f"Results equal: {result1 == result2}")
```

### Performance Monitoring

```python
from noodlecore.optimization import get_performance_metrics, check_optimization_health

# Get performance metrics
metrics = get_performance_metrics()
print("Performance Metrics:")
print(f"Timestamp: {metrics['timestamp']}")
for component, data in metrics['components'].items():
    print(f"{component}: {data}")

# Check optimization health
health = check_optimization_health()
print("\nOptimization Health:")
print(f"Overall Status: {health['overall_status']}")
for component, status in health['components'].items():
    print(f"{component}: {status}")
```

## System Integration Examples

### Basic System Integration

```python
from noodlecore.system_integration import SystemIntegration, SystemConfig

# Configure system
config = SystemConfig(
    enable_database=True,
    enable_distributed=True,
    enable_gpu=True,
    debug_mode=True
)

# Initialize system integration
system = SystemIntegration(config)

# Get system status
status = system.get_system_status()
print(f"System Status: {status}")
print(f"Database Enabled: {status.database_enabled}")
print(f"Distributed Enabled: {status.distributed_enabled}")
print(f"GPU Enabled: {status.gpu_enabled}")

# Execute code with system integration
result = system.execute_code("print('Hello, Integrated System!')")
```

### Distributed Computing

```python
from noodlecore.runtime.distributed.placement_engine import get_placement_engine, ConstraintType

# Get placement engine
engine = get_placement_engine()

# Define tensor
tensor_size = 1024 * 1024 * 1024  # 1GB
tensor_shape = (1024, 1024, 1024)
data_type = "float32"

# Place tensor with constraints
placement = engine.place_tensor(
    "matrix_multiply",
    tensor_size,
    tensor_shape,
    data_type,
    constraints=[
        ConstraintType.GPU_ONLY,
        ConstraintType.LOCAL_ONLY
    ]
)

print(f"Tensor placement: {placement}")
print(f"Target nodes: {placement.target_nodes}")
print(f"Memory required: {placement.memory_required}")
```

### Resource Management

```python
from noodlecore.system_integration import SystemIntegration, SystemConfig

# Configure with resource limits
config = SystemConfig(
    max_memory="8Gi",
    max_cpu="4",
    max_gpu="1",
    enable_monitoring=True
)

system = SystemIntegration(config)

# Monitor resource usage
while True:
    status = system.get_system_status()
    print(f"Memory Usage: {status.memory_usage}")
    print(f"CPU Usage: {status.cpu_usage}")
    print(f"GPU Usage: {status.gpu_usage}")
    
    # Check if we need to scale
    if status.memory_usage > 0.8:
        print("Warning: High memory usage!")
    
    time.sleep(5)
```

## Advanced Examples

### Complete Workflow: Compile, Execute, and Store

```python
from noodlecore import compile_code, execute_code
from noodlecore.database import DatabaseManager, insert
from noodlecore.mathematical_objects import Matrix
from noodlecore.optimization import JITCompiler, CodeProfiler

# Step 1: Compile and execute code
source_code = """
# Matrix operations
matrix_a = [[1, 2], [3, 4]]
matrix_b = [[5, 6], [7, 8]]
result = []
for i in range(2):
    row = []
    for j in range(2):
        val = 0
        for k in range(2):
            val += matrix_a[i][k] * matrix_b[k][j]
        row.append(val)
    result.append(row)
print(result)
"""

# Compile and execute
bytecode = compile_code(source_code)
result = execute_code(source_code)
print(f"Execution result: {result}")

# Step 2: Store results in database
db_manager = DatabaseManager()
db_manager.add_connection("results", "sqlite:///results.db")
db_manager.create_table("computations", {
    "id": {"type": "INTEGER", "primary_key": True, "autoincrement": True},
    "code": {"type": "TEXT", "nullable": False},
    "result": {"type": "TEXT", "nullable": False},
    "timestamp": {"type": "DATETIME", "nullable": False}
})

insert("computations", {
    "code": source_code,
    "result": str(result),
    "timestamp": "2025-01-01 12:00:00"
})

# Step 3: Optimize with JIT
@jit_compile(optimization_level=2)
def matrix_multiply_optimized(a, b):
    result = []
    for i in range(len(a)):
        row = []
        for j in range(len(b[0])):
            val = 0
            for k in range(len(b)):
                val += a[i][k] * b[k][j]
            row.append(val)
        result.append(row)
    return result

# Test optimized version
matrix_a = [[1, 2], [3, 4]]
matrix_b = [[5, 6], [7, 8]]
optimized_result = matrix_multiply_optimized(matrix_a, matrix_b)
print(f"Optimized result: {optimized_result}")
```

### Machine Learning Pipeline

```python
from noodlecore.mathematical_objects import Matrix, Tensor
from noodlecore.optimization import JITCompiler, CodeProfiler
from noodlecore.runtime import RuntimeEnvironment
import numpy as np

# Initialize components
runtime = RuntimeEnvironment()
compiler = JITCompiler()
profiler = CodeProfiler()

# Generate synthetic data
np.random.seed(42)
X = np.random.randn(100, 5)  # 100 samples, 5 features
y = np.random.randn(100, 1)  # 100 targets

# Convert to Noodle objects
X_tensor = Tensor(X)
y_tensor = Tensor(y)

# Define linear regression model
@jit_compile(optimization_level=2)
def linear_regression(X, y, learning_rate=0.01, epochs=1000):
    # Initialize weights
    weights = np.random.randn(X.data.shape[1], 1)
    bias = 0
    
    for epoch in range(epochs):
        # Forward pass
        predictions = X.data @ weights + bias
        
        # Compute loss (MSE)
        loss = np.mean((predictions - y.data) ** 2)
        
        # Backward pass
        grad_weights = (2 / X.data.shape[0]) * X.data.T @ (predictions - y.data)
        grad_bias = (2 / X.data.shape[0]) * np.sum(predictions - y.data)
        
        # Update parameters
        weights -= learning_rate * grad_weights
        bias -= learning_rate * grad_bias
        
        if epoch % 100 == 0:
            print(f"Epoch {epoch}, Loss: {loss}")
    
    return weights, bias

# Train the model
weights, bias = linear_regression(X_tensor, y_tensor)

print(f"Final weights: {weights.flatten()}")
print(f"Final bias: {bias}")

# Make predictions
test_data = np.random.randn(5, 5)
test_tensor = Tensor(test_data)
predictions = test_tensor.data @ weights + bias
print(f"Predictions: {predictions.flatten()}")
```

### Real-time Data Processing

```python
from noodlecore.mathematical_objects import Matrix, Vector
from noodlecore.optimization import JITCache, CodeProfiler
from noodlecore.runtime import RuntimeEnvironment
import time
import numpy as np

# Initialize components
runtime = RuntimeEnvironment()
cache = JITCache()
profiler = CodeProfiler()

# Real-time data processing pipeline
@jit_compile(optimization_level=2)
def process_data_stream(data_window):
    # Compute moving average
    moving_avg = np.mean(data_window, axis=0)
    
    # Compute standard deviation
    std_dev = np.std(data_window, axis=0)
    
    # Detect anomalies
    threshold = 2.0  # 2 standard deviations
    anomalies = np.abs(data_window - moving_avg) > threshold * std_dev
    
    return moving_avg, std_dev, anomalies

# Simulate real-time data stream
data_window_size = 100
data_window = np.random.randn(data_window_size, 10)

# Process data in real-time
for i in range(1000):
    # Generate new data point
    new_data = np.random.randn(1, 10)
    
    # Update data window (sliding window)
    data_window = np.vstack([data_window[1:], new_data])
    
    # Process with caching
    cache_key = f"process_{i}"
    result = cache.get_or_compute(cache_key, lambda: process_data_stream(data_window))
    
    moving_avg, std_dev, anomalies = result
    
    # Log anomalies
    if np.any(anomalies):
        print(f"Anomaly detected at step {i}")
        print(f"Anomaly count: {np.sum(anomalies)}")
    
    # Simulate real-time delay
    time.sleep(0.1)
```

## Performance Optimization Examples

### GPU Acceleration

```python
from noodlecore.mathematical_objects import Matrix
from noodlecore.optimization import JITCompiler
import numpy as np

# Create large matrices for GPU acceleration
size = 1000
matrix_a = Matrix(np.random.randn(size, size))
matrix_b = Matrix(np.random.randn(size, size))

# CPU computation
@jit_compile(optimization_level=1)
def matrix_multiply_cpu(a, b):
    return a.multiply(b, device="cpu")

# GPU computation
@jit_compile(optimization_level=3)
def matrix_multiply_gpu(a, b):
    return a.multiply(b, device="gpu")

# Benchmark both
import time

start_time = time.time()
cpu_result = matrix_multiply_cpu(matrix_a, matrix_b)
cpu_time = time.time() - start_time

start_time = time.time()
gpu_result = matrix_multiply_gpu(matrix_a, matrix_b)
gpu_time = time.time() - start_time

print(f"CPU time: {cpu_time:.4f} seconds")
print(f"GPU time: {gpu_time:.4f} seconds")
print(f"Speedup: {cpu_time / gpu_time:.2f}x")
```

### Memory Optimization

```python
from noodlecore.optimization import JITCache, CacheConfig
from noodlecore.mathematical_objects import Matrix
import numpy as np

# Configure cache for memory optimization
config = CacheConfig(
    max_size=100,  # Small cache to force eviction
    default_ttl=60.0,
    eviction_policy="lru"
)

cache = JITCache(config)

# Generate large datasets
datasets = []
for i in range(200):
    dataset = np.random.randn(1000, 1000)
    datasets.append(dataset)

# Process datasets with caching
@cache_result(ttl=30.0)
def process_dataset(dataset, cache_key):
    # Simulate expensive processing
    result = np.mean(dataset, axis=0)
    return result

# Process with memory monitoring
processed_count = 0
cache_hits = 0
cache_misses = 0

for i, dataset in enumerate(datasets):
    cache_key = f"dataset_{i}"
    
    if cache.contains(cache_key):
        cache_hits += 1
        print(f"Cache hit for {cache_key}")
    else:
        cache_misses += 1
        print(f"Cache miss for {cache_key}")
    
    result = process_dataset(dataset, cache_key)
    processed_count += 1
    
    # Monitor cache performance
    if i % 50 == 0:
        print(f"Processed: {processed_count}, Cache hits: {cache_hits}, Cache misses: {cache_misses}")
        print(f"Cache size: {cache.size()}, Hit rate: {cache_hits / (cache_hits + cache_misses):.2%}")

print(f"\nFinal Results:")
print(f"Total processed: {processed_count}")
print(f"Cache hits: {cache_hits}")
print(f"Cache misses: {cache_misses}")
print(f"Overall hit rate: {cache_hits / (cache_hits + cache_misses):.2%}")
```

### Parallel Processing

```python
from noodlecore.optimization import JITCompiler, CodeProfiler
from noodlecore.mathematical_objects import Matrix
import numpy as np
from concurrent.futures import ThreadPoolExecutor

# Configure JIT for parallel processing
config = JITConfig(
    optimization_level=2,
    enable_mlir=True,
    parallel_threads=True
)

compiler = JITCompiler(config)

# Define parallel processing functions
@jit_compile(optimization_level=2)
def parallel_matrix_multiply(matrices):
    results = []
    for matrix in matrices:
        result = matrix.multiply(matrix)
        results.append(result)
    return results

@jit_compile(optimization_level=2)
def parallel_data_processing(data_chunks):
    results = []
    for chunk in data_chunks:
        # Simulate complex data processing
        processed = np.fft.fft(chunk)
        results.append(processed)
    return results

# Generate test data
num_matrices = 50
matrix_size = 100
matrices = [Matrix(np.random.randn(matrix_size, matrix_size)) for _ in range(num_matrices)]

data_chunks = [np.random.randn(1000) for _ in range(100)]

# Process in parallel
print("Processing matrices...")
start_time = time.time()
matrix_results = parallel_matrix_multiply(matrices)
matrix_time = time.time() - start_time

print("Processing data chunks...")
start_time = time.time()
data_results = parallel_data_processing(data_chunks)
data_time = time.time() - start_time

print(f"Matrix processing time: {matrix_time:.4f} seconds")
print(f"Data processing time: {data_time:.4f} seconds")
print(f"Total processed: {len(matrix_results)} matrices, {len(data_results)} data chunks")
```

## Conclusion

These examples demonstrate the power and flexibility of the NoodleCore API. From basic compilation and execution to advanced mathematical computing, database operations, and performance optimization, NoodleCore provides a comprehensive toolkit for high-performance computing applications.

Remember to:
1. Always use proper error handling
2. Monitor resource usage in production
3. Cache expensive operations
4. Leverage GPU acceleration when available
5. Profile and optimize critical code paths

For more detailed information, refer to the main API documentation and explore the individual module documentation.