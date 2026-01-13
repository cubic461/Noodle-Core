# NoodleVision Memory Management API Reference

This document provides detailed API documentation for the memory management system in NoodleVision.

## Overview

NoodleVision includes an advanced memory management system designed for efficient allocation, pooling, and caching of memory resources. The system supports both CPU and GPU memory management with adaptive policies to optimize performance and memory usage.

## Core Components

### MemoryManager

The main interface for memory management operations.

```python
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Initialize memory manager
manager = MemoryManager(policy=MemoryPolicy.BALANCED)

# Process audio with memory management
audio = np.random.randn(22050 * 10)  # 10 seconds
```

#### Parameters

- **policy** (`MemoryPolicy`): Memory management policy. Default: `MemoryPolicy.BALANCED`

#### Policies

- **CONSERVATIVE**: Minimal memory usage, slower allocation
- **BALANCED**: Balanced approach between performance and memory usage
- **AGGRESSIVE_REUSE**: Maximum memory reuse, best for repetitive tasks
- **QUALITY_FIRST**: Prioritize quality, may use more memory
- **LATENCY_FIRST**: Prioritize low latency, fastest allocation

#### Methods

##### `allocate_tensor(shape, dtype, prefer_gpu=True)`

Allocate memory for a tensor.

```python
# Allocate tensor
tensor = manager.allocate_tensor((1024, 1024), np.float32, prefer_gpu=True)
if tensor is not None:
    # Use tensor
    tensor[:] = np.random.rand(*tensor.shape)
```

**Parameters:**
- **shape** (`tuple`): Tensor shape
- **dtype** (`np.dtype`): Tensor data type
- **prefer_gpu** (`bool`): Whether to prefer GPU allocation. Default: True

**Returns:**
- `np.ndarray` or None: Allocated tensor or None if allocation failed

##### `free_tensor(tensor)`

Free memory used by a tensor.

```python
# Free tensor
manager.free_tensor(tensor)
```

**Parameters:**
- **tensor** (`np.ndarray`): Tensor to free

##### `set_policy(policy)`

Change memory management policy.

```python
# Change policy
manager.set_policy(MemoryPolicy.AGGRESSIVE_REUSE)
```

**Parameters:**
- **policy** (`MemoryPolicy`): New memory policy

##### `get_statistics()`

Get memory usage statistics.

```python
# Get statistics
stats = manager.get_statistics()
print(f"CPU usage: {stats['cpu_pool']['usage_percentage']:.1f}%")
print(f"GPU usage: {stats['gpu_pool']['usage_percentage']:.1f}%")
print(f"Cache efficiency: {stats['cache_stats']['cache_efficiency']:.2f}")
```

**Returns:**
- `dict`: Memory usage statistics

##### `cleanup()`

Clean up unused memory and resources.

```python
# Clean up
manager.cleanup()
```

### MemoryPool

Advanced memory pool for efficient allocation.

```python
from noodlenet.vision.memory import MemoryPool, GPUMemoryPool, CPUMemoryPool

# CPU memory pool
cpu_pool = CPUMemoryPool(max_size=512 * 1024 * 1024)  # 512MB

# GPU memory pool (if CUDA available)
gpu_pool = GPUMemoryPool(max_size=1024 * 1024 * 1024)  # 1GB
```

#### Parameters

- **max_size** (`int`): Maximum pool size in bytes
- **block_size** (`int`): Size of memory blocks in bytes. Default: 1024 * 1024 (1MB)

#### Methods

##### `allocate(size)`

Allocate memory block.

```python
# Allocate memory
block = cpu_pool.allocate(1024 * 1024)  # 1MB
if block is not None:
    # Use block
    block.data[:] = np.random.rand(*block.data.shape)
```

**Parameters:**
- **size** (`int`): Size in bytes

**Returns:**
- `MemoryBlock` or None: Allocated block or None if allocation failed

##### `free(block)`

Free memory block.

```python
# Free block
cpu_pool.free(block)
```

**Parameters:**
- **block** (`MemoryBlock`): Block to free

##### `get_stats()`

Get pool statistics.

```python
# Get statistics
stats = cpu_pool.get_stats()
print(f"Total allocated: {stats['total_allocated']} bytes")
print(f"Peak usage: {stats['peak_usage']} bytes")
```

**Returns:**
- `MemoryStats`: Pool statistics

##### `get_usage()`

Get pool usage information.

```python
# Get usage
usage = cpu_pool.get_usage()
print(f"Current usage: {usage['current_usage']} bytes")
print(f"Usage percentage: {usage['usage_percentage']:.1f}%")
```

**Returns:**
- `dict`: Pool usage information

### MemoryBlock

Represents a block of allocated memory.

```python
from noodlenet.vision.memory import MemoryBlock

# Create memory block
block = MemoryBlock(
    pointer=id(np.zeros(1024, dtype=np.int8)),
    size=1024,
    timestamp=time.time()
)
```

#### Parameters

- **pointer** (`int`): Memory pointer
- **size** (`int`): Block size in bytes
- **timestamp** (`float`): Allocation timestamp
- **data** (`np.ndarray`): Associated tensor data
- **in_use** (`bool`): Whether block is in use

#### Methods

##### `is_expired(max_age)`

Check if block is expired.

```python
# Check if expired
if block.is_expired(300.0):  # 5 minutes
    print("Block is expired")
```

**Parameters:**
- **max_age** (`float`): Maximum age in seconds

**Returns:**
- `bool`: True if expired

### TensorCache

Cache for frequently used tensors.

```python
from noodlenet.vision.memory import TensorCache

# Create cache
cache = TensorCache(max_size=100, eviction_policy="lru")
```

#### Parameters

- **max_size** (`int`): Maximum number of cached tensors. Default: 100
- **eviction_policy** (`str`): Eviction policy. Options: 'lru', 'lfu', 'adaptive'. Default: 'lru'

#### Methods

##### `get(shape, dtype)`

Get tensor from cache.

```python
# Get tensor from cache
tensor = cache.get((256, 256), np.float32)
if tensor is not None:
    print("Tensor found in cache")
else:
    print("Tensor not in cache")
```

**Parameters:**
- **shape** (`tuple`): Tensor shape
- **dtype** (`np.dtype`): Tensor data type

**Returns:**
- `np.ndarray` or None: Cached tensor or None if not found

##### `add(tensor)`

Add tensor to cache.

```python
# Add tensor to cache
tensor = np.random.rand(256, 256)
cache.add(tensor)
```

**Parameters:**
- **tensor** (`np.ndarray`): Tensor to cache

##### `get_stats()`

Get cache statistics.

```python
# Get statistics
stats = cache.get_stats()
print(f"Cache hits: {stats['hits']}")
print(f"Cache misses: {stats['misses']}")
print(f"Cache efficiency: {stats['cache_efficiency']:.2f}")
```

**Returns:**
- `dict`: Cache statistics

##### `cleanup()`

Clean up expired cache entries.

```python
# Clean up cache
cache.cleanup()
```

### SystemMemoryMonitor

Monitor system memory usage.

```python
from noodlenet.vision.memory import SystemMemoryMonitor

# Create monitor
monitor = SystemMemoryMonitor()
```

#### Methods

##### `get_memory_info()`

Get system memory information.

```python
# Get memory info
info = monitor.get_memory_info()
print(f"Process RSS: {info['process_rss']} bytes")
print(f"System used: {info['system_used']} bytes")
print(f"System available: {info['system_available']} bytes")
```

**Returns:**
- `dict`: System memory information

##### `get_available_memory()`

Get available system memory.

```python
# Get available memory
available = monitor.get_available_memory()
print(f"Available memory: {available} bytes")
```

**Returns:**
- `int`: Available memory in bytes

## Usage Examples

### Basic Memory Management

```python
import numpy as np
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Initialize manager
manager = MemoryManager(policy=MemoryPolicy.BALANCED)

# Create audio
audio = np.random.randn(22050 * 30)  # 30 seconds

# Process with memory management
operators = {
    'spectrogram': lambda: SpectrogramOperator()(audio),
    'mfcc': lambda: MFCCOperator(n_mfcc=13)(audio),
    'chroma': lambda: ChromaOperator()(audio)
}

results = {}
for name, operator in operators.items():
    # Allocate memory
    shape = operator().shape
    dtype = operator().dtype
    
    memory = manager.allocate_tensor(shape, dtype)
    if memory is not None:
        # Compute and store result
        memory[:] = operator()
        results[name] = memory

# Print statistics
stats = manager.get_statistics()
print(f"CPU usage: {stats['cpu_pool']['usage_percentage']:.1f}%")
print(f"GPU usage: {stats['gpu_pool']['usage_percentage']:.1f}%")
print(f"Cache efficiency: {stats['cache_stats']['cache_efficiency']:.2f}")

# Clean up
for tensor in results.values():
    manager.free_tensor(tensor)
manager.cleanup()
```

### Advanced Memory Pool Usage

```python
import numpy as np
from noodlenet.vision.memory import CPUMemoryPool, MemoryBlock

# Create memory pool
pool = CPUMemoryPool(max_size=256 * 1024 * 1024)  # 256MB

# Allocate blocks
blocks = []
for i in range(10):
    size = 16 * 1024 * 1024  # 16MB
    block = pool.allocate(size)
    if block:
        # Initialize block data
        if block.data is None:
            block.data = np.zeros((size // 8,), dtype=np.int64)  # Simulate allocation
        
        # Fill with random data
        block.data[:] = np.random.rand(*block.data.shape)
        blocks.append(block)

# Use blocks
for block in blocks:
    print(f"Block size: {block.size} bytes")
    print(f"Block in use: {block.in_use}")

# Free blocks
for block in blocks:
    pool.free(block)

# Get pool statistics
stats = pool.get_stats()
print(f"Total allocated: {stats['total_allocated']} bytes")
print(f"Peak usage: {stats['peak_usage']} bytes")
```

### Tensor Cache Usage

```python
import numpy as np
from noodlenet.vision.memory import TensorCache, MemoryManager

# Create cache and manager
cache = TensorCache(max_size=50)
manager = MemoryManager(policy=MemoryPolicy.AGGRESSIVE_REUSE)

# Common tensor shapes
common_shapes = [
    (128, 128),
    (256, 256),
    (512, 512)
]

# Process multiple times
for i in range(20):
    for shape in common_shapes:
        # Check cache first
        tensor = cache.get(shape, np.float32)
        
        if tensor is None:
            # Allocate and compute
            tensor = manager.allocate_tensor(shape, np.float32)
            if tensor is not None:
                # Simulate computation
                tensor[:] = np.random.rand(*shape)
                
                # Add to cache
                cache.add(tensor.copy())
        
        print(f"Iteration {i}, shape {shape}: {'cached' if cache.get_stats()['hits'] > 0 else 'computed'}")

# Cache statistics
stats = cache.get_stats()
print(f"Cache hits: {stats['hits']}")
print(f"Cache misses: {stats['misses']}")
print(f"Cache efficiency: {stats['cache_efficiency']:.2f}")
```

### Memory Policy Comparison

```python
import numpy as np
import time
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Test different policies
policies = [
    MemoryPolicy.CONSERVATIVE,
    MemoryPolicy.BALANCED,
    MemoryPolicy.AGGRESSIVE_REUSE,
    MemoryPolicy.QUALITY_FIRST,
    MemoryPolicy.LATENCY_FIRST
]

test_shape = (1024, 1024)
test_data = np.random.rand(*test_shape)

results = {}
for policy in policies:
    manager = MemoryManager(policy=policy)
    
    # Measure allocation time
    start_time = time.time()
    for i in range(100):
        tensor = manager.allocate_tensor(test_shape, test_data.dtype)
        if tensor is not None:
            manager.free_tensor(tensor)
    
    allocation_time = time.time() - start_time
    
    # Get statistics
    stats = manager.get_statistics()
    
    results[policy.value] = {
        'allocation_time': allocation_time,
        'cache_efficiency': stats['cache_stats']['cache_efficiency'],
        'allocations_count': stats['allocations_count']
    }
    
    manager.cleanup()

# Print results
print("Policy Performance Comparison:")
for policy, metrics in results.items():
    print(f"{policy}:")
    print(f"  Allocation time: {metrics['allocation_time']:.4f}s")
    print(f"  Cache efficiency: {metrics['cache_efficiency']:.2f}")
    print(f"  Allocations: {metrics['allocations_count']}")
```

## Performance Considerations

### Memory Usage Optimization

1. **Choose appropriate policy**: Select based on your use case
   - Conservative: Memory-constrained environments
   - Balanced: General purpose
   - Aggressive Reuse: Repetitive tasks
   - Quality First: High-quality processing
   - Latency First: Real-time applications

2. **Reuse operators**: Initialize once and reuse
3. **Batch processing**: Process multiple items together
4. **Monitor memory**: Use statistics to track usage

### Cache Management

1. **Appropriate cache size**: Set based on available memory
2. **Eviction policy**: Choose based on access patterns
3. **Cache warming**: Preload frequently used tensors
4. **Cleanup**: Regular cleanup of expired entries

### Pool Configuration

1. **Pool size**: Set based on expected workload
2. **Block size**: Choose based on typical allocation sizes
3. **Pool monitoring**: Use statistics to optimize

## Error Handling

The memory management system includes robust error handling:

```python
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

manager = MemoryManager(policy=MemoryPolicy.BALANCED)

try:
    # Try to allocate very large tensor
    large_shape = (10000, 10000)
    tensor = manager.allocate_tensor(large_shape, np.float32)
    
    if tensor is not None:
        print("Allocation successful")
    else:
        print("Allocation failed - trying smaller size")
        
        # Fallback to smaller allocation
        small_shape = (1024, 1024)
        tensor = manager.allocate_tensor(small_shape, np.float32)
        if tensor is not None:
            print("Fallback allocation successful")
    
except Exception as e:
    print(f"Memory allocation error: {e}")
    # Handle error appropriately
```

## Best Practices

1. **Initialize managers once** and reuse them
2. **Monitor memory usage** regularly
3. **Clean up resources** when done
4. **Choose appropriate policies** for your use case
5. **Handle allocation failures** gracefully
6. **Use cache efficiently** for repeated operations
7. **Profile memory usage** to identify bottlenecks
8. **Consider memory constraints** when processing large datasets

## Troubleshooting

### Common Issues

1. **Allocation failures**: Check available memory and policy settings
2. **Memory leaks**: Ensure proper cleanup of resources
3. **Poor cache performance**: Adjust cache size and eviction policy
4. **High memory usage**: Consider more conservative policies

### Debugging Tips

1. **Enable logging** for memory operations
2. **Monitor statistics** regularly
3. **Use cleanup operations** to free unused memory
4. **Check system memory** usage
5. **Profile memory allocation patterns**

## Integration with Audio Operators

```python
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

class AudioProcessor:
    def __init__(self, policy=MemoryPolicy.BALANCED):
        self.manager = MemoryManager(policy)
        self.operators = {
            'spectrogram': SpectrogramOperator(),
            'mfcc': MFCCOperator(n_mfcc=13),
            'chroma': ChromaOperator()
        }
    
    def process_audio(self, audio):
        """Process audio with memory management"""
        results = {}
        
        for name, operator in self.operators.items():
            # Compute features
            features = operator(audio)
            
            # Allocate memory
            memory = self.manager.allocate_tensor(
                features.shape, 
                features.dtype
            )
            
            if memory is not None:
                # Store results
                memory[:] = features
                results[name] = memory
        
        return results
    
    def cleanup(self):
        """Clean up resources"""
        self.manager.cleanup()

# Usage
processor = AudioProcessor(MemoryPolicy.AGGRESSIVE_REUSE)
audio = np.random.randn(22050 * 60)  # 60 seconds
results = processor.process_audio(audio)

# Use results...
processor.cleanup()
