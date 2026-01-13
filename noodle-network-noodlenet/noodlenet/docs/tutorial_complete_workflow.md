# NoodleVision Complete Workflow Tutorial

This tutorial provides a comprehensive guide to using NoodleVision for audio feature extraction, from basic setup to advanced workflows.

## Table of Contents

1. [Introduction](#introduction)
2. [Setup](#setup)
3. [Basic Usage](#basic-usage)
4. [Advanced Features](#advanced-features)
5. [Performance Optimization](#performance-optimization)
6. [Real-world Example](#real-world-example)
7. [Best Practices](#best-practices)

## Introduction

NoodleVision is a comprehensive audio processing library that provides high-performance feature extraction with advanced memory management. This tutorial will guide you through the complete workflow.

### What You'll Learn

- Audio loading and preprocessing
- Feature extraction with multiple operators
- Memory management and optimization
- Batch processing
- Performance monitoring
- Error handling
- Visualization of results

### Prerequisites

- Python 3.8+
- NumPy
- Matplotlib
- NoodleVision installed

## Setup

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/noodlenet.git
cd noodlenet

# Install dependencies
pip install -r requirements.txt

# Install NoodleVision
pip install -e .
```

### Basic Configuration

Create a configuration file at `~/.noodlenet/config.json`:

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
  }
}
```

### Verification

Run the verification script to ensure everything is working:

```python
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Test basic imports
print("✓ Successfully imported NoodleVision modules")

# Test audio operators
audio = np.random.randn(22050)
operators = {
    'Spectrogram': SpectrogramOperator(),
    'MFCC': MFCCOperator(n_mfcc=13),
    'Chroma': ChromaOperator(),
    'Tonnetz': TonnetzOperator()
}

for name, operator in operators.items():
    result = operator(audio)
    print(f"✓ {name}: {result.shape}")

# Test memory management
manager = MemoryManager(policy=MemoryPolicy.BALANCED)
tensor = manager.allocate_tensor((256, 256), np.float32)
if tensor is not None:
    print("✓ Memory management works")
    manager.free_tensor(tensor)
manager.cleanup()
```

## Basic Usage

### Loading Audio

```python
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

def load_audio(file_path, sample_rate=22050):
    """Load audio file (simulated for this tutorial)"""
    # In a real implementation, you would use librosa or similar
    # For this tutorial, we'll generate test audio
    duration = 10.0  # seconds
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    
    # Generate complex audio with multiple frequency components
    audio = (
        0.5 * np.sin(2 * np.pi * 440 * t) +  # A4 note
        0.3 * np.sin(2 * np.pi * 880 * t) +  # A5 note
        0.2 * np.sin(2 * np.pi * 220 * t) +  # A3 note
        0.1 * np.random.randn(len(t))          # Noise
    )
    
    # Normalize
    audio = audio / np.max(np.abs(audio))
    return audio

# Load audio
audio = load_audio("example.wav")
print(f"Audio loaded: {len(audio)} samples")
```

### Feature Extraction

```python
# Initialize operators
operators = {
    'spectrogram': SpectrogramOperator(),
    'mfcc': MFCCOperator(n_mfcc=13),
    'chroma': ChromaOperator(),
    'tonnetz': TonnetzOperator()
}

# Extract features
features = {}
for name, operator in operators.items():
    try:
        feature = operator(audio)
        features[name] = feature
        print(f"✓ {name}: {feature.shape}")
    except Exception as e:
        print(f"✗ {name} failed: {e}")
```

### Memory Management

```python
# Initialize memory manager
manager = MemoryManager(policy=MemoryPolicy.BALANCED)

# Process with memory management
results = {}
for name, feature in features.items():
    # Allocate memory
    memory = manager.allocate_tensor(feature.shape, feature.dtype)
    if memory is not None:
        memory[:] = feature
        results[name] = memory
        print(f"✓ Allocated memory for {name}")

# Get statistics
stats = manager.get_statistics()
print(f"CPU usage: {stats['cpu_pool']['usage_percentage']:.1f}%")
print(f"GPU usage: {stats['gpu_pool']['usage_percentage']:.1f}%")

# Clean up
for tensor in results.values():
    manager.free_tensor(tensor)
manager.cleanup()
```

## Advanced Features

### Custom Operator Parameters

```python
# Initialize operators with custom parameters
spectrogram = SpectrogramOperator(
    window_size=1024,
    hop_length=256,
    n_fft=1024
)

mfcc = MFCCOperator(
    n_mfcc=20,
    n_mels=128,
    fmin=0.0,
    fmax=8000.0
)

chroma = ChromaOperator(
    n_chroma=24,
    tuning=0.0
)

tonnetz = TonnetzOperator(
    n_tonnetz=6
)

# Extract features with custom operators
custom_features = {}
for name, operator in [('spectrogram', spectrogram), 
                      ('mfcc', mfcc), 
                      ('chroma', chroma),
                      ('tonnetz', tonnetz)]:
    try:
        feature = operator(audio)
        custom_features[name] = feature
        print(f"✓ {name}: {feature.shape}")
    except Exception as e:
        print(f"✗ {name} failed: {e}")
```

### Batch Processing

```python
def process_batch(audio_files, batch_size=5):
    """Process multiple audio files in batches"""
    all_features = []
    
    for i in range(0, len(audio_files), batch_size):
        batch_files = audio_files[i:i + batch_size]
        print(f"Processing batch {i//batch_size + 1}")
        
        batch_features = []
        for file_path in batch_files:
            try:
                # Load audio
                audio = load_audio(file_path)
                
                # Extract features
                features = {}
                for name, operator in operators.items():
                    features[name] = operator(audio)
                
                batch_features.append(features)
            except Exception as e:
                print(f"✗ Failed to process {file_path}: {e}")
                batch_features.append(None)
        
        all_features.extend(batch_features)
        
        # Clean up after batch
        manager.cleanup()
    
    return all_features

# Example batch processing
audio_files = ["audio1.wav", "audio2.wav", "audio3.wav", "audio4.wav", "audio5.wav"]
all_features = process_batch(audio_files, batch_size=2)
```

### Performance Monitoring

```python
import time
from collections import defaultdict

class PerformanceMonitor:
    def __init__(self):
        self.metrics = defaultdict(list)
    
    def start_timing(self, operation):
        self.metrics[operation]['start'] = time.time()
    
    def end_timing(self, operation):
        if 'start' in self.metrics[operation]:
            duration = time.time() - self.metrics[operation]['start']
            self.metrics[operation]['durations'].append(duration)
            del self.metrics[operation]['start']
            return duration
        return None
    
    def get_average_time(self, operation):
        if operation in self.metrics and 'durations' in self.metrics[operation]:
            return np.mean(self.metrics[operation]['durations'])
        return None
    
    def print_summary(self):
        print("\nPerformance Summary:")
        for operation, data in self.metrics.items():
            if 'durations' in data:
                avg_time = np.mean(data['durations'])
                std_time = np.std(data['durations'])
                print(f"  {operation}: {avg_time:.3f}s ± {std_time:.3f}")

# Use performance monitor
monitor = PerformanceMonitor()

# Monitor feature extraction
for name, operator in operators.items():
    monitor.start_timing(f"{name}_extraction")
    feature = operator(audio)
    duration = monitor.end_timing(f"{name}_extraction")
    print(f"✓ {name}: {duration:.3f}s")

monitor.print_summary()
```

## Performance Optimization

### Memory Policy Selection

```python
# Test different memory policies
policies = [
    MemoryPolicy.CONSERVATIVE,
    MemoryPolicy.BALANCED,
    MemoryPolicy.AGGRESSIVE_REUSE,
    MemoryPolicy.QUALITY_FIRST,
    MemoryPolicy.LATENCY_FIRST
]

policy_results = {}
for policy in policies:
    manager = MemoryManager(policy=policy)
    
    # Process audio
    start_time = time.time()
    for name, operator in operators.items():
        feature = operator(audio)
        memory = manager.allocate_tensor(feature.shape, feature.dtype)
        if memory is not None:
            memory[:] = feature
            manager.free_tensor(memory)
    
    processing_time = time.time() - start_time
    stats = manager.get_statistics()
    
    policy_results[policy.value] = {
        'time': processing_time,
        'cache_efficiency': stats['cache_stats']['cache_efficiency'],
        'memory_usage': stats['cpu_pool']['usage_percentage']
    }
    
    manager.cleanup()

# Compare policies
print("\nPolicy Performance Comparison:")
for policy, metrics in policy_results.items():
    print(f"  {policy}:")
    print(f"    Time: {metrics['time']:.3f}s")
    print(f"    Cache efficiency: {metrics['cache_efficiency']:.2f}")
    print(f"    Memory usage: {metrics['memory_usage']:.1f}%")
```

### GPU Acceleration

```python
# Check GPU availability
import torch
gpu_available = torch.cuda.is_available()
print(f"CUDA available: {gpu_available}")

if gpu_available:
    # Configure GPU memory
    import torch
    torch.cuda.set_per_process_memory_fraction(0.8)
    
    # Use GPU operators
    spectrogram = SpectrogramOperator(prefer_gpu=True)
    mfcc = MFCCOperator(prefer_gpu=True)
    chroma = ChromaOperator(prefer_gpu=True)
    tonnetz = TonnetzOperator(prefer_gpu=True)
    
    # Process with GPU
    gpu_features = {}
    for name, operator in [('spectrogram', spectrogram), 
                          ('mfcc', mfcc), 
                          ('chroma', chroma),
                          ('tonnetz', tonnetz)]:
        try:
            feature = operator(audio)
            gpu_features[name] = feature
            print(f"✓ GPU {name}: {feature.shape}")
        except Exception as e:
            print(f"✗ GPU {name} failed: {e}")
```

### Caching Strategy

```python
from noodlenet.vision.memory import TensorCache

# Create cache
cache = TensorCache(max_size=50, eviction_policy="lru")

# Process with caching
cached_features = {}
for i in range(5):  # Process multiple times to test caching
    print(f"\nIteration {i+1}:")
    
    for name, operator in operators.items():
        # Check cache first
        cached_tensor = cache.get(operator.expected_shape(), operator.expected_dtype())
        
        if cached_tensor is not None:
            print(f"  ✓ {name}: from cache")
            cached_features[name] = cached_tensor
        else:
            # Compute and cache
            feature = operator(audio)
            cache.add(feature.copy())
            cached_features[name] = feature
            print(f"  ✓ {name}: computed and cached")

# Cache statistics
stats = cache.get_stats()
print(f"\nCache Statistics:")
print(f"  Hits: {stats['hits']}")
print(f"  Misses: {stats['misses']}")
print(f"  Cache efficiency: {stats['cache_efficiency']:.2f}")
```

## Real-world Example

### Audio Analysis Pipeline

```python
class AudioAnalyzer:
    def __init__(self, memory_policy=MemoryPolicy.BALANCED):
        self.memory_manager = MemoryManager(policy=memory_policy)
        self.operators = {
            'spectrogram': SpectrogramOperator(),
            'mfcc': MFCCOperator(n_mfcc=13),
            'chroma': ChromaOperator(),
            'tonnetz': TonnetzOperator()
        }
        self.monitor = PerformanceMonitor()
    
    def analyze_audio(self, audio, sample_rate=22050):
        """Comprehensive audio analysis"""
        results = {
            'features': {},
            'statistics': {},
            'metadata': {
                'sample_rate': sample_rate,
                'duration': len(audio) / sample_rate,
                'channels': 1
            }
        }
        
        # Extract features
        for name, operator in self.operators.items():
            self.monitor.start_timing(f"{name}_extraction")
            feature = operator(audio)
            self.monitor.end_timing(f"{name}_extraction")
            
            results['features'][name] = feature
            
            # Calculate statistics
            results['statistics'][name] = {
                'shape': feature.shape,
                'dtype': str(feature.dtype),
                'mean': np.mean(feature),
                'std': np.std(feature),
                'min': np.min(feature),
                'max': np.max(feature)
            }
        
        return results
    
    def analyze_batch(self, audio_files, batch_size=3):
        """Analyze multiple audio files"""
        all_results = []
        
        for i in range(0, len(audio_files), batch_size):
            batch_files = audio_files[i:i + batch_size]
            print(f"Processing batch {i//batch_size + 1}")
            
            batch_results = []
            for file_path in batch_files:
                try:
                    audio = load_audio(file_path)
                    result = self.analyze_audio(audio)
                    batch_results.append(result)
                except Exception as e:
                    print(f"✗ Failed to analyze {file_path}: {e}")
                    batch_results.append(None)
            
            all_results.extend(batch_results)
            self.memory_manager.cleanup()
        
        return all_results
    
    def generate_report(self, results):
        """Generate analysis report"""
        report = {
            'summary': {
                'total_files': len(results),
                'successful_analyses': sum(1 for r in results if r is not None),
                'failed_analyses': sum(1 for r in results if r is None)
            },
            'performance': {
                'average_extraction_times': {
                    name: self.monitor.get_average_time(f"{name}_extraction")
                    for name in self.operators.keys()
                }
            },
            'features_summary': {}
        }
        
        # Aggregate feature statistics
        for name in self.operators.keys():
            if name in results[0]['features']:
                feature_stats = []
                for result in results:
                    if result and name in result['statistics']:
                        feature_stats.append(result['statistics'][name])
                
                if feature_stats:
                    report['features_summary'][name] = {
                        'avg_shape': np.mean([fs['shape'] for fs in feature_stats], axis=0).astype(int),
                        'avg_mean': np.mean([fs['mean'] for fs in feature_stats]),
                        'avg_std': np.mean([fs['std'] for fs in feature_stats]),
                        'overall_min': min(fs['min'] for fs in feature_stats),
                        'overall_max': max(fs['max'] for fs in feature_stats)
                    }
        
        return report
    
    def cleanup(self):
        """Clean up resources"""
        self.memory_manager.cleanup()

# Example usage
analyzer = AudioAnalyzer(memory_policy=MemoryPolicy.BALANCED)

# Analyze single audio file
audio = load_audio("example.wav")
result = analyzer.analyze_audio(audio)

# Analyze batch
audio_files = ["audio1.wav", "audio2.wav", "audio3.wav", "audio4.wav"]
results = analyzer.analyze_batch(audio_files)

# Generate report
report = analyzer.generate_report(results)

# Print report
print("\nAudio Analysis Report:")
print(f"Total files: {report['summary']['total_files']}")
print(f"Successful: {report['summary']['successful_analyses']}")
print(f"Failed: {report['summary']['failed_analyses']}")

print("\nFeature Summary:")
for name, stats in report['features_summary'].items():
    print(f"  {name}:")
    print(f"    Average shape: {stats['avg_shape']}")
    print(f"    Mean: {stats['avg_mean']:.3f} ± {stats['avg_std']:.3f}")
    print(f"    Range: [{stats['overall_min']:.3f}, {stats['overall_max']:.3f}]")

analyzer.cleanup()
```

### Visualization

```python
import matplotlib.pyplot as plt
import seaborn as sns

def visualize_analysis_results(results, save_path=None):
    """Visualize audio analysis results"""
    # Create figure with subplots
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    fig.suptitle('Audio Analysis Results', fontsize=16)
    
    # Plot spectrograms
    if all('spectrogram' in r['features'] for r in results if r):
        spec_data = np.stack([r['features']['spectrogram'] for r in results if r])
        avg_spec = np.mean(np.abs(spec_data), axis=0)
        im1 = axes[0, 0].imshow(avg_spec, aspect='auto', origin='lower', cmap='viridis')
        axes[0, 0].set_title('Average Spectrogram')
        axes[0, 0].set_xlabel('Time Frames')
        axes[0, 0].set_ylabel('Frequency Bins')
        plt.colorbar(im1, ax=axes[0, 0])
    
    # Plot MFCC statistics
    if all('mfcc' in r['statistics'] for r in results if r):
        mfcc_means = [r['statistics']['mfcc']['mean'] for r in results if r]
        axes[0, 1].hist(mfcc_means, bins=20, alpha=0.7, color='blue')
        axes[0, 1].set_title('MFCC Means Distribution')
        axes[0, 1].set_xlabel('Mean Value')
        axes[0, 1].set_ylabel('Frequency')
    
    # Plot chroma features
    if all('chroma' in r['features'] for r in results if r):
        chroma_data = np.stack([r['features']['chroma'] for r in results if r])
        avg_chroma = np.mean(chroma_data, axis=0)
        im3 = axes[1, 0].imshow(avg_chroma, aspect='auto', origin='lower', cmap='hsv')
        axes[1, 0].set_title('Average Chroma Features')
        axes[1, 0].set_xlabel('Time Frames')
        axes[1, 0].set_ylabel('Chroma Bins')
        plt.colorbar(im3, ax=axes[1, 0])
    
    # Plot Tonnetz features
    if all('tonnetz' in r['features'] for r in results if r):
        tonnetz_data = np.stack([r['features']['tonnetz'] for r in results if r])
        avg_tonnetz = np.mean(tonnetz_data, axis=0)
        im4 = axes[1, 1].imshow(avg_tonnetz, aspect='auto', origin='lower', cmap='plasma')
        axes[1, 1].set_title('Average Tonnetz Features')
        axes[1, 1].set_xlabel('Time Frames')
        axes[1, 1].set_ylabel('Tonnetz Dimensions')
        plt.colorbar(im4, ax=axes[1, 1])
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"✓ Visualization saved to {save_path}")
    
    plt.show()

# Visualize results
visualize_analysis_results(results)
```

## Best Practices

### 1. Memory Management

```python
# Best practice: Initialize managers once and reuse
def process_audio_files(audio_files):
    manager = MemoryManager(policy=MemoryPolicy.BALANCED)
    
    try:
        for file_path in audio_files:
            audio = load_audio(file_path)
            # Process audio
            features = extract_features(audio, manager)
            # Use features...
    finally:
        manager.cleanup()

# Helper function for feature extraction with memory management
def extract_features(audio, manager):
    features = {}
    
    for name, operator in operators.items():
        feature = operator(audio)
        memory = manager.allocate_tensor(feature.shape, feature.dtype)
        if memory is not None:
            memory[:] = feature
            features[name] = memory
    
    return features
```

### 2. Error Handling

```python
def robust_audio_processing(audio_path):
    """Robust audio processing with comprehensive error handling"""
    try:
        # Validate input
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"Audio file not found: {audio_path}")
        
        # Load audio
        audio = load_audio(audio_path)
        if len(audio) == 0:
            raise ValueError("Empty audio signal")
        
        # Process with validation
        features = {}
        for name, operator in operators.items():
            try:
                feature = operator(audio)
                if feature is None or np.any(np.isnan(feature)):
                    raise ValueError(f"Invalid features for {name}")
                features[name] = feature
            except Exception as e:
                print(f"Warning: Failed to extract {name}: {e}")
                features[name] = None
        
        return features
    
    except Exception as e:
        print(f"Error processing {audio_path}: {e}")
        return None
```

### 3. Performance Optimization

```python
def optimized_batch_processing(audio_files, batch_size=5):
    """Optimized batch processing with memory management"""
    # Initialize with aggressive reuse for batch processing
    manager = MemoryManager(policy=MemoryPolicy.AGGRESSIVE_REUSE)
    
    try:
        # Process in batches
        for i in range(0, len(audio_files), batch_size):
            batch_files = audio_files[i:i + batch_size]
            
            # Process batch
            batch_features = []
            for file_path in batch_files:
                features = robust_audio_processing(file_path)
                batch_features.append(features)
            
            # Clean up after batch
            manager.cleanup()
            
            # Yield batch results
            yield batch_features
    
    finally:
        manager.cleanup()
```

### 4. Logging and Monitoring

```python
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('audio_processing.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def process_with_logging(audio_files):
    """Process audio files with comprehensive logging"""
    start_time = datetime.now()
    logger.info(f"Starting audio processing for {len(audio_files)} files")
    
    processed_count = 0
    failed_count = 0
    
    for i, file_path in enumerate(audio_files):
        try:
            logger.info(f"Processing file {i+1}/{len(audio_files)}: {file_path}")
            
            # Load and process
            audio = load_audio(file_path)
            features = extract_features(audio)
            
            processed_count += 1
            logger.info(f"Successfully processed {file_path}")
            
        except Exception as e:
            failed_count += 1
            logger.error(f"Failed to process {file_path}: {e}")
    
    # Log summary
    end_time = datetime.now()
    duration = end_time - start_time
    
    logger.info(f"Processing completed:")
    logger.info(f"  Total files: {len(audio_files)}")
    logger.info(f"  Processed: {processed_count}")
    logger.info(f"  Failed: {failed_count}")
    logger.info(f"  Duration: {duration}")
    logger.info(f"  Average time per file: {duration/len(audio_files)}")
```

### 5. Configuration Management

```python
import json
from pathlib import Path

class NoodleVisionConfig:
    def __init__(self, config_path=None):
        self.config_path = config_path or Path.home() / '.noodlenet' / 'config.json'
        self.config = self.load_config()
    
    def load_config(self):
        """Load configuration from file"""
        if self.config_path.exists():
            with open(self.config_path, 'r') as f:
                return json.load(f)
        return self.get_default_config()
    
    def get_default_config(self):
        """Get default configuration"""
        return {
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
    
    def save_config(self):
        """Save configuration to file"""
        self.config_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.config_path, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def get(self, key, default=None):
        """Get configuration value"""
        keys = key.split('.')
        value = self.config
        for k in keys:
            value = value.get(k, default)
            if value is None:
                return default
        return value

# Usage
config = NoodleVisionConfig()

# Use configuration
memory_policy = config.get('memory.policy', 'balanced')
sample_rate = config.get('audio.default_sample_rate', 22050)
log_level = config.get('logging.level', 'INFO')
```

## Conclusion

This tutorial has covered the complete workflow for using NoodleVision:

1. **Setup and Installation**: Getting NoodleVision running with proper configuration
2. **Basic Usage**: Loading audio and extracting features
3. **Advanced Features**: Custom parameters, batch processing, and performance monitoring
4. **Performance Optimization**: Memory policies, GPU acceleration, and caching
5. **Real-world Example**: Complete audio analysis pipeline with visualization
6. **Best Practices**: Memory management, error handling, logging, and configuration

### Next Steps

1. **Explore the API**: Refer to the API documentation for detailed information
2. **Try Real Audio**: Load and process actual audio files instead of test signals
3. **Custom Operators**: Create your own audio processing operators
4. **Integration**: Integrate NoodleVision into larger audio processing pipelines
5. **Performance Tuning**: Optimize for specific use cases and hardware

### Resources

- [API Documentation](audio_operators_api.md)
- [Memory Management Documentation](memory_management_api.md)
- [Installation Guide](installation_guide.md)
- [Examples](../examples/)

Happy audio processing with NoodleVision!
