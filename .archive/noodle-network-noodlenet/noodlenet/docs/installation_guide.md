# NoodleVision Installation and Configuration Guide

This guide provides step-by-step instructions for installing and configuring NoodleVision on your system.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Verification](#verification)
5. [Troubleshooting](#troubleshooting)
6. [System Requirements](#system-requirements)

## Prerequisites

### System Requirements

- **Operating System**: Linux, macOS, or Windows
- **Python**: 3.8 or higher
- **RAM**: Minimum 4GB (8GB recommended)
- **Disk Space**: Minimum 1GB free space
- **GPU (Optional)**: CUDA-compatible GPU for GPU acceleration

### Python Dependencies

NoodleVision requires the following Python packages:

```
numpy>=1.19.0
scipy>=1.7.0
librosa>=0.8.0
soundfile>=0.10.0
psutil>=5.8.0
```

### Optional Dependencies

For GPU acceleration:
```
torch>=1.9.0
torchaudio>=0.9.0
```

For development and testing:
```
pytest>=6.0.0
matplotlib>=3.3.0
```

## Installation

### Option 1: Direct Installation from Source

1. **Clone the repository**
```bash
git clone https://github.com/your-org/noodlenet.git
cd noodlenet
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Install NoodleVision**
```bash
pip install -e .
```

### Option 2: Install via pip (when available)

```bash
pip install noodlenet
```

### Option 3: Development Installation

For development purposes:

```bash
git clone https://github.com/your-org/noodlenet.git
cd noodlenet
pip install -e ".[dev]"
```

## Configuration

### Basic Configuration

NoodleVision uses a simple configuration system. Create a configuration file at `~/.noodlenet/config.json`:

```json
{
  "memory": {
    "policy": "balanced",
    "max_cpu_memory": 536870912,
    "max_gpu_memory": 1073741824,
    "cache_size": 100,
    "eviction_policy": "lru"
  },
  "audio": {
    "default_sample_rate": 22050,
    "window_size": 2048,
    "hop_length": 512,
    "n_fft": 2048
  },
  "logging": {
    "level": "INFO",
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  }
}
```

### Environment Variables

You can also configure NoodleVision using environment variables:

```bash
export NOODLEVISION_MEMORY_POLICY=balanced
export NOODLEVISION_MAX_CPU_MEMORY=536870912
export NOODLEVISION_MAX_GPU_MEMORY=1073741824
export NOODLEVISION_LOG_LEVEL=INFO
```

### GPU Configuration

If you have a CUDA-compatible GPU and want to use GPU acceleration:

1. **Install PyTorch with CUDA support**
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

2. **Verify GPU availability**
```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU count: {torch.cuda.device_count()}")
print(f"Current GPU: {torch.cuda.current_device()}")
```

3. **Configure GPU memory allocation**
```json
{
  "memory": {
    "max_gpu_memory": 1073741824,
    "gpu_memory_fraction": 0.9
  }
}
```

### Audio Configuration

Configure audio processing parameters:

```json
{
  "audio": {
    "default_sample_rate": 22050,
    "window_size": 2048,
    "hop_length": 512,
    "n_fft": 2048,
    "mfcc": {
      "n_mfcc": 13,
      "n_mels": 128
    },
    "chroma": {
      "n_chroma": 12
    },
    "tonnetz": {
      "n_tonnetz": 6
    }
  }
}
```

## Verification

### Basic Installation Check

```python
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Test basic imports
print("✓ Successfully imported NoodleVision modules")

# Test audio operators
audio = np.random.randn(22050)  # 1 second of audio

operators = {
    'Spectrogram': SpectrogramOperator(),
    'MFCC': MFCCOperator(n_mfcc=13),
    'Chroma': ChromaOperator(),
    'Tonnetz': TonnetzOperator()
}

results = {}
for name, operator in operators.items():
    try:
        result = operator(audio)
        results[name] = result
        print(f"✓ {name} operator works - shape: {result.shape}")
    except Exception as e:
        print(f"✗ {name} operator failed: {e}")

# Test memory management
try:
    manager = MemoryManager(policy=MemoryPolicy.BALANCED)
    tensor = manager.allocate_tensor((256, 256), np.float32)
    if tensor is not None:
        print("✓ Memory management works")
        manager.free_tensor(tensor)
    else:
        print("✗ Memory allocation failed")
    manager.cleanup()
except Exception as e:
    print(f"✗ Memory management failed: {e}")

print("\nInstallation verification complete!")
```

### Performance Verification

```python
import time
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Create test audio
audio = np.random.randn(22050 * 10)  # 10 seconds

# Test performance
operator = SpectrogramOperator()
manager = MemoryManager(policy=MemoryPolicy.BALANCED)

# Process audio
start_time = time.time()
result = operator(audio)
processing_time = time.time() - start_time

print(f"✓ Audio processing completed in {processing_time:.3f}s")
print(f"✓ Result shape: {result.shape}")
print(f"✓ Memory policy: {manager.get_statistics()['policy']}")

# Memory usage
stats = manager.get_statistics()
print(f"✓ CPU memory usage: {stats['cpu_pool']['usage_percentage']:.1f}%")
print(f"✓ GPU memory usage: {stats['gpu_pool']['usage_percentage']:.1f}%")
```

## Troubleshooting

### Common Issues

#### 1. Import Errors

**Problem**: `ModuleNotFoundError: No module named 'noodlenet'`

**Solution**:
```bash
# Ensure you're in the correct directory
cd /path/to/noodlenet

# Reinstall in development mode
pip install -e .
```

#### 2. Audio Processing Errors

**Problem**: `ValueError: negative dimensions are not allowed`

**Solution**:
- Ensure audio input is not empty
- Check audio sample rate and duration
- Validate audio data format

```python
import numpy as np

# Validate audio
def validate_audio(audio):
    if len(audio) == 0:
        raise ValueError("Audio is empty")
    if not isinstance(audio, np.ndarray):
        raise ValueError("Audio must be a numpy array")
    if len(audio.shape) != 1:
        raise ValueError("Audio must be 1D array")
    return True

# Usage
try:
    validate_audio(audio)
    result = operator(audio)
except ValueError as e:
    print(f"Audio validation failed: {e}")
```

#### 3. Memory Allocation Errors

**Problem**: `MemoryError: Unable to allocate array`

**Solution**:
- Reduce memory pool size
- Use more conservative memory policy
- Process smaller batches

```python
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Use conservative policy
manager = MemoryManager(policy=MemoryPolicy.CONSERVATIVE)

# Process smaller chunks
chunk_size = 22050  # 1 second
for i in range(0, len(audio), chunk_size):
    chunk = audio[i:i+chunk_size]
    # Process chunk
```

#### 4. GPU Issues

**Problem**: GPU not available or CUDA errors

**Solution**:
```python
import torch

# Check GPU availability
if torch.cuda.is_available():
    print(f"CUDA available: {torch.cuda.is_available()}")
    print(f"GPU device: {torch.cuda.get_device_name(0)}")
    print(f"GPU memory: {torch.cuda.get_device_properties(0).total_memory}")
else:
    print("CUDA not available, using CPU fallback")
```

#### 5. Performance Issues

**Problem**: Slow processing or high memory usage

**Solution**:
```python
# Monitor performance
import time
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

manager = MemoryManager(policy=MemoryPolicy.AGGRESSIVE_REUSE)

# Time operations
start_time = time.time()
result = operator(audio)
end_time = time.time()

print(f"Processing time: {end_time - start_time:.3f}s")
print(f"Memory usage: {manager.get_statistics()['cpu_pool']['usage_percentage']:.1f}%")
```

### Debug Mode

Enable debug logging for troubleshooting:

```python
import logging

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Or set via environment variable
import os
os.environ['NOODLEVISION_LOG_LEVEL'] = 'DEBUG'
```

### System Information

Get system information for debugging:

```python
import sys
import platform
import numpy as np

print(f"Python version: {sys.version}")
print(f"Platform: {platform.platform()}")
print(f"NumPy version: {np.__version__}")

# Test audio operators
try:
    from noodlenet.vision.ops_audio import SpectrogramOperator
    operator = SpectrogramOperator()
    print("✓ Audio operators imported successfully")
except Exception as e:
    print(f"✗ Audio operators failed: {e}")

# Test memory management
try:
    from noodlenet.vision.memory import MemoryManager
    manager = MemoryManager()
    print("✓ Memory management imported successfully")
except Exception as e:
    print(f"✗ Memory management failed: {e}")
```

## System Requirements

### Minimum Requirements

- **CPU**: 2 GHz dual-core processor
- **RAM**: 4 GB
- **Storage**: 1 GB free space
- **Python**: 3.8+
- **Dependencies**: numpy, scipy, librosa, soundfile, psutil

### Recommended Requirements

- **CPU**: 3 GHz quad-core processor or better
- **RAM**: 8 GB or more
- **Storage**: 2 GB free space
- **GPU**: CUDA-compatible GPU for acceleration
- **Python**: 3.9+
- **Dependencies**: latest versions with GPU support

### Optional Requirements

- **High-speed storage**: SSD for faster I/O
- **Multiple GPUs**: For parallel processing
- **Large RAM**: 16GB+ for processing long audio files
- **Fast CPU**: For real-time processing

## Performance Optimization

### Memory Optimization

```python
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Use aggressive reuse for repetitive tasks
manager = MemoryManager(policy=MemoryPolicy.AGGRESSIVE_REUSE)

# Process in batches
batch_size = 1000
for i in range(0, len(data), batch_size):
    batch = data[i:i+batch_size]
    # Process batch
    manager.cleanup()  # Clean up after each batch
```

### GPU Optimization

```python
# Configure GPU memory
import torch
torch.cuda.set_per_process_memory_fraction(0.8)  # Use 80% of GPU memory

# Use GPU operators when available
from noodlenet.vision.ops_audio import SpectrogramOperator
operator = SpectrogramOperator(prefer_gpu=True)
```

### Multi-threading

```python
import threading
from noodlenet.vision.memory import MemoryManager
from noodlenet.vision.ops_audio import SpectrogramOperator

def process_audio_chunk(audio_chunk, results, idx):
    manager = MemoryManager(policy=MemoryPolicy.BALANCED)
    operator = SpectrogramOperator()
    
    result = operator(audio_chunk)
    results[idx] = result
    manager.cleanup()

# Process multiple chunks in parallel
chunks = [...]  # List of audio chunks
results = [None] * len(chunks)

threads = []
for i, chunk in enumerate(chunks):
    thread = threading.Thread(target=process_audio_chunk, args=(chunk, results, i))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()
```

## Best Practices

1. **Initialize managers once** and reuse them
2. **Use appropriate memory policies** for your workload
3. **Monitor memory usage** regularly
4. **Clean up resources** when done
5. **Handle errors gracefully** with try-catch blocks
6. **Use batch processing** for large datasets
7. **Enable logging** for debugging
8. **Validate inputs** before processing
9. **Test with small datasets** first
10. **Profile performance** to identify bottlenecks

## Getting Help

### Community Support

- GitHub Issues: [Report bugs and request features](https://github.com/your-org/noodlenet/issues)
- Discussions: [Join community discussions](https://github.com/your-org/noodlenet/discussions)
- Documentation: [Full documentation](https://noodlenet.readthedocs.io/)

### Professional Support

For enterprise support and consulting, contact:
- Email: support@your-org.com
- Website: https://your-org.com/noodlenet

### Contributing

We welcome contributions! Please see [CONTRIBUTING.md](https://github.com/your-org/noodlenet/blob/main/CONTRIBUTING.md) for guidelines.
