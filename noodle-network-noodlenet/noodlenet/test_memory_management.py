"""
Test Suite::Noodlenet - test_memory_management.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for NoodleVision memory management optimization

This script tests the enhanced memory pooling, caching, and allocation strategies.
"""

import logging
import numpy as np
import time
import threading
import sys
import os

# Add the current directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import modules directly to avoid package import issues
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'vision'))

import memory
import ops_audio

MemoryManager = memory.MemoryManager
MemoryPolicy = memory.MemoryPolicy
SystemMemoryMonitor = memory.SystemMemoryMonitor
SpectrogramOperator = ops_audio.SpectrogramOperator
MFCCOperator = ops_audio.MFCCOperator
ChromaOperator = ops_audio.ChromaOperator

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def test_memory_pooling():
    """Test memory pooling optimization"""
    logger.info("Testing memory pooling optimization...")
    
    # Initialize memory manager
    manager = MemoryManager(policy=MemoryPolicy.BALANCED)
    
    # Create test tensors of various sizes
    test_tensors = []
    
    # Small tensors (audio features)
    for i in range(50):
        tensor = np.random.rand(128, 83)  # Chroma features
        test_tensors.append(tensor)
    
    # Medium tensors (spectrograms)
    for i in range(30):
        tensor = np.random.rand(1025, 83)  # Spectrogram
        test_tensors.append(tensor)
    
    # Large tensors (multi-channel audio)
    for i in range(10):
        tensor = np.random.rand(22050 * 2, 2)  # 2 seconds stereo audio
        test_tensors.append(tensor)
    
    # Allocate and free tensors to test pooling
    allocated_tensors = []
    
    # Phase 1: Allocate all tensors
    logger.info("Phase 1: Allocating tensors...")
    start_time = time.time()
    
    for i, tensor in enumerate(test_tensors):
        # Copy tensor to simulate real allocation
        shape = tensor.shape
        dtype = tensor.dtype
        
        # Allocate with memory manager
        allocated_tensor = manager.allocate_tensor(shape, dtype, prefer_gpu=False)
        if allocated_tensor is not None:
            # Fill with same data for consistency
            allocated_tensor[:] = tensor
            allocated_tensors.append(allocated_tensor)
            
            if i % 10 == 0:
                logger.info(f"  Allocated tensor {i}/{len(test_tensors)}")
    
    phase1_time = time.time() - start_time
    logger.info(f"Phase 1 completed in {phase1_time:.3f}s")
    
    # Phase 2: Access statistics
    logger.info("Phase 2: Checking memory statistics...")
    stats = manager.get_statistics()
    logger.info(f"  System memory: {stats['system_memory']['system_used'] / 1024**2:.1f}MB used")
    logger.info(f"  CPU pool usage: {stats['cpu_pool']['usage_percentage']:.1f}%")
    logger.info(f"  GPU pool usage: {stats['gpu_pool']['usage_percentage']:.1f}%")
    logger.info(f"  Cache hits: {stats['cache_stats']['hits']}")
    logger.info(f"  Cache misses: {stats['cache_stats']['misses']}")
    
    # Phase 3: Free some tensors and test caching
    logger.info("Phase 3: Testing caching...")
    start_time = time.time()
    
    # Free first 30% of tensors
    free_count = len(allocated_tensors) // 3
    for i in range(free_count):
        tensor = allocated_tensors.pop(0)
        manager.free_tensor(tensor)
    
    # Allocate same tensors again (should hit cache)
    cache_test_tensors = []
    for i in range(free_count):
        tensor = test_tensors[i]
        cached_tensor = manager.allocate_tensor(tensor.shape, tensor.dtype, prefer_gpu=False)
        if cached_tensor is not None:
            cache_test_tensors.append(cached_tensor)
    
    phase3_time = time.time() - start_time
    logger.info(f"Phase 3 completed in {phase3_time:.3f}s")
    
    # Phase 4: Final statistics
    logger.info("Phase 4: Final statistics...")
    final_stats = manager.get_statistics()
    logger.info(f"  Final cache hits: {final_stats['cache_stats']['hits']}")
    logger.info(f"  Final cache misses: {final_stats['cache_stats']['misses']}")
    logger.info(f"  Cache efficiency: {final_stats['cache_stats']['cache_efficiency']:.2f}")
    logger.info(f"  Total cached bytes: {final_stats['cache_stats']['total_cached_bytes'] / 1024**2:.1f}MB")
    
    # Phase 5: Cleanup
    logger.info("Phase 5: Cleanup...")
    manager.cleanup()
    
    # Clean up remaining tensors
    for tensor in allocated_tensors + cache_test_tensors:
        manager.free_tensor(tensor)
    
    logger.info("Memory pooling test completed")


def test_audio_operators_with_memory():
    """Test audio operators with memory management"""
    logger.info("Testing audio operators with memory management...")
    
    # Create test audio data
    sample_rate = 22050
    duration = 2.0  # seconds
    audio_data = np.random.randn(int(sample_rate * duration))
    
    # Initialize memory manager with aggressive reuse
    manager = MemoryManager(policy=MemoryPolicy.AGGRESSIVE_REUSE)
    
    # Test different operators
    operators = [
        ("Spectrogram", SpectrogramOperator()),
        ("MFCC", MFCCOperator(n_mfcc=13)),
        ("Chroma", ChromaOperator()),
    ]
    
    for op_name, operator in operators:
        logger.info(f"Testing {op_name} operator...")
        
        # Warm up cache
        _ = operator(audio_data)
        
        # Run multiple iterations to test memory reuse
        times = []
        for i in range(10):
            start_time = time.time()
            result = operator(audio_data)
            processing_time = time.time() - start_time
            times.append(processing_time)
            
            # Free result tensor
            manager.free_tensor(result)
        
        avg_time = np.mean(times)
        std_time = np.std(times)
        
        logger.info(f"  Average processing time: {avg_time:.4f}s Â± {std_time:.4f}s")
        logger.info(f"  Result shape: {result.shape}")
        logger.info(f"  Memory stats: {manager.get_statistics()['cache_stats']}")
    
    logger.info("Audio operators test completed")


def test_memory_policies():
    """Test different memory management policies"""
    logger.info("Testing different memory management policies...")
    
    # Create test tensors
    test_tensor = np.random.rand(1024, 1024)
    
    policies = [
        MemoryPolicy.CONSERVATIVE,
        MemoryPolicy.BALANCED,
        MemoryPolicy.AGGRESSIVE_REUSE,
        MemoryPolicy.QUALITY_FIRST,
        MemoryPolicy.LATENCY_FIRST,
    ]
    
    for policy in policies:
        logger.info(f"Testing {policy.value} policy...")
        
        # Create new manager with policy
        manager = MemoryManager(policy=policy)
        
        # Allocate and free multiple times
        times = []
        for i in range(20):
            start_time = time.time()
            tensor = manager.allocate_tensor(test_tensor.shape, test_tensor.dtype)
            if tensor is not None:
                manager.free_tensor(tensor)
            times.append(time.time() - start_time)
        
        avg_time = np.mean(times)
        stats = manager.get_statistics()
        
        logger.info(f"  Average allocation time: {avg_time:.6f}s")
        logger.info(f"  Cache efficiency: {stats['cache_stats']['cache_efficiency']:.2f}")
        logger.info(f"  Total allocations: {stats['allocations_count']}")


def main():
    """Main test function"""
    logger.info("Starting NoodleVision memory management tests...")
    
    try:
        # Test 1: Memory pooling
        test_memory_pooling()
        logger.info("-" * 50)
        
        # Test 2: Audio operators with memory
        test_audio_operators_with_memory()
        logger.info("-" * 50)
        
        # Test 3: Memory policies
        test_memory_policies()
        
        logger.info("All tests completed successfully!")
        
    except Exception as e:
        logger.error(f"Test failed with error: {e}")
        raise


if __name__ == "__main__":
    main()


