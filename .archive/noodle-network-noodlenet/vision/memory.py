"""
Vision::Memory - memory.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Memory management for NoodleVision

This module provides memory-aware management for multimedia processing,
with adaptive policies and GPU/CPU memory pools.
"""

import logging
import numpy as np
import psutil
import threading
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import deque
import time

logger = logging.getLogger(__name__)


class MemoryPolicy(Enum):
    """Memory management policies"""
    AGGRESSIVE_REUSE = "aggressive_reuse"     # Maximize memory reuse
    BALANCED = "balanced"                     # Balanced approach
    QUALITY_FIRST = "quality_first"          # Prioritize quality
    LATENCY_FIRST = "latency_first"          # Prioritize low latency
    CONSERVATIVE = "conservative"             # Minimize memory usage


@dataclass
class MemoryStats:
    """Memory statistics tracking"""
    total_allocated: int = 0
    total_freed: int = 0
    peak_usage: int = 0
    current_usage: int = 0
    allocations_count: int = 0
    frees_count: int = 0
    cache_hits: int = 0
    cache_misses: int = 0
    
    def hit_rate(self) -> float:
        """Calculate cache hit rate"""
        total = self.cache_hits + self.cache_misses
        if total == 0:
            return 0.0
        return self.cache_hits / total


@dataclass
class MemoryBlock:
    """Represents a block of allocated memory"""
    pointer: int
    size: int
    timestamp: float
    data: Optional[np.ndarray] = None
    in_use: bool = True
    
    def is_expired(self, max_age: float) -> bool:
        """Check if memory block is expired"""
        return time.time() - self.timestamp > max_age


class MemoryPool:
    """Generic memory pool for efficient allocation"""
    
    def __init__(self, max_size: int, block_size: int = 1024 * 1024):
        """
        Initialize memory pool
        
        Args:
            max_size: Maximum pool size in bytes
            block_size: Size of memory blocks in bytes
        """
        self.max_size = max_size
        self.block_size = block_size
        self.blocks: List[MemoryBlock] = []
        self.available_blocks: List[MemoryBlock] = []
        self.stats = MemoryStats()
        self._lock = threading.Lock()
        
        # Memory pooling optimizations
        self.size_classes = self._calculate_size_classes()
        self.pooled_blocks: Dict[int, List[MemoryBlock]] = {}
        self.allocation_history = deque(maxlen=1000)
        
        # Pre-allocate blocks
        self._preallocate()
    
    def _calculate_size_classes(self) -> List[int]:
        """
        Calculate optimal size classes for memory pooling
        
        Returns:
            List of size class boundaries
        """
        # Power-of-2 size classes for better alignment
        size_classes = []
        current = 1024  # Start at 1KB
        
        while current <= self.block_size:
            size_classes.append(current)
            current *= 2
        
        # Add largest block size
        if size_classes[-1] < self.block_size:
            size_classes.append(self.block_size)
        
        return size_classes
    
    def _find_best_size_class(self, size: int) -> int:
        """
        Find the best size class for a given allocation size
        
        Args:
            size: Requested size in bytes
            
        Returns:
            Optimal size class boundary
        """
        # Find smallest size class that can accommodate the request
        for size_class in self.size_classes:
            if size_class >= size:
                return size_class
        
        # Return largest size class if none found
        return self.size_classes[-1]
    
    def _preallocate(self):
        """Pre-allocate memory blocks"""
        num_blocks = self.max_size // self.block_size
        
        for _ in range(num_blocks):
            # In a real implementation, this would allocate actual memory
            # For now, we simulate with placeholders
            block = MemoryBlock(
                pointer=id(np.zeros(self.block_size // 8, dtype=np.int64)),
                size=self.block_size,
                timestamp=time.time()
            )
            self.blocks.append(block)
            self.available_blocks.append(block)
            
            # Add to appropriate size class pool
            target_size = self._find_best_size_class(block.size)
            if target_size not in self.pooled_blocks:
                self.pooled_blocks[target_size] = []
            self.pooled_blocks[target_size].append(block)
    
    def allocate(self, size: int) -> Optional[MemoryBlock]:
        """
        Allocate memory block with optimized size class matching
        
        Args:
            size: Size in bytes
            
        Returns:
            Allocated memory block or None if failed
        """
        with self._lock:
            # Find best fit size class
            target_size = self._find_best_size_class(size)
            
            # First try to find exact match in pooled blocks
            if target_size in self.pooled_blocks:
                for block in self.pooled_blocks[target_size]:
                    if not block.in_use:
                        block.in_use = True
                        block.timestamp = time.time()
                        
                        # Update stats
                        self.stats.total_allocated += size
                        self.stats.current_usage += size
                        self.stats.allocations_count += 1
                        self.stats.peak_usage = max(self.stats.peak_usage, self.stats.current_usage)
                        
                        # Record allocation for analysis
                        self.allocation_history.append({
                            'size': size,
                            'requested_size': size,
                            'actual_size': block.size,
                            'timestamp': time.time()
                        })
                        
                        return block
            
            # Fallback to general available blocks
            for block in self.available_blocks:
                if block.size >= size and not block.in_use:
                    block.in_use = True
                    block.timestamp = time.time()
                    
                    # Update stats
                    self.stats.total_allocated += size
                    self.stats.current_usage += size
                    self.stats.allocations_count += 1
                    self.stats.peak_usage = max(self.stats.peak_usage, self.stats.current_usage)
                    
                    # Record allocation
                    self.allocation_history.append({
                        'size': size,
                        'requested_size': size,
                        'actual_size': block.size,
                        'timestamp': time.time()
                    })
                    
                    return block
            
            # No suitable block found
            return None
    
    def free(self, block: MemoryBlock) -> bool:
        """
        Free memory block
        
        Args:
            block: Block to free
            
        Returns:
            True if freed successfully
        """
        with self._lock:
            if block.in_use:
                block.in_use = False
                block.timestamp = time.time()
                
                # Update stats
                self.stats.total_freed += block.size
                self.stats.current_usage -= block.size
                self.stats.frees_count += 1
                
                # Add to available blocks
                if block not in self.available_blocks:
                    self.available_blocks.append(block)
                
                return True
            
            return False
    
    def cleanup_expired(self, max_age: float = 300.0):
        """Clean up expired memory blocks"""
        with self._lock:
            current_time = time.time()
            
            # Remove expired blocks from available list
            self.available_blocks = [
                block for block in self.available_blocks
                if not block.is_expired(max_age)
            ]
    
    def get_stats(self) -> MemoryStats:
        """Get memory pool statistics"""
        return self.stats
    
    def get_usage(self) -> Dict[str, Any]:
        """Get memory usage information"""
        return {
            "current_usage": self.stats.current_usage,
            "max_size": self.max_size,
            "available_blocks": len(self.available_blocks),
            "total_blocks": len(self.blocks),
            "usage_percentage": (self.stats.current_usage / self.max_size) * 100
        }


class GPUMemoryPool(MemoryPool):
    """GPU memory pool for CUDA operations"""
    
    def __init__(self, max_size: int = 1024**3, block_size: int = 16 * 1024 * 1024):
        """
        Initialize GPU memory pool
        
        Args:
            max_size: Maximum GPU memory in bytes (default: 1GB)
            block_size: Size of GPU memory blocks in bytes (default: 16MB)
        """
        super().__init__(max_size, block_size)
        self.cuda_available = self._check_cuda()
        
        if not self.cuda_available:
            logger.warning("CUDA not available, using CPU fallback")
    
    def _check_cuda(self) -> bool:
        """Check if CUDA is available"""
        try:
            import torch
            return torch.cuda.is_available()
        except ImportError:
            return False
    
    def allocate_tensor(self, shape: tuple, dtype: np.dtype) -> Optional[np.ndarray]:
        """
        Allocate GPU tensor
        
        Args:
            shape: Tensor shape
            dtype: Tensor dtype
            
        Returns:
            Allocated tensor or None if failed
        """
        # Calculate required size
        size = int(np.prod(shape) * dtype.itemsize)
        
        # Allocate memory block
        block = self.allocate(size)
        
        if block is None:
            return None
        
        # Create tensor
        tensor = np.zeros(shape, dtype=dtype)
        
        # In a real implementation, this would be a GPU tensor
        # For now, we simulate with CPU tensor
        if self.cuda_available:
            try:
                import torch
                tensor = torch.zeros(shape, dtype=dtype, device='cuda')
            except Exception as e:
                logger.warning(f"Failed to create GPU tensor: {e}")
        
        block.data = tensor
        
        return tensor
    
    def free_tensor(self, tensor: np.ndarray):
        """
        Free GPU tensor
        
        Args:
            tensor: Tensor to free
        """
        # Find corresponding block
        for block in self.blocks:
            if block.data is tensor:
                self.free(block)
                break


class CPUMemoryPool(MemoryPool):
    """CPU memory pool for host operations"""
    
    def __init__(self, max_size: int = 512 * 1024 * 1024, block_size: int = 4 * 1024 * 1024):
        """
        Initialize CPU memory pool
        
        Args:
            max_size: Maximum CPU memory in bytes (default: 512MB)
            block_size: Size of CPU memory blocks in bytes (default: 4MB)
        """
        super().__init__(max_size, block_size)


class MemoryManager:
    """Memory-aware manager for multimedia processing"""
    
    def __init__(self, policy: MemoryPolicy = MemoryPolicy.BALANCED):
        """
        Initialize memory manager
        
        Args:
            policy: Memory management policy
        """
        self.policy = policy
        self.cpu_pool = CPUMemoryPool()
        self.gpu_pool = GPUMemoryPool()
        
        # System monitoring
        self.system_monitor = SystemMemoryMonitor()
        
        # Cache for frequently used tensors
        self.tensor_cache = TensorCache(max_size=100)
        
        # Allocation tracking
        self.allocations: Dict[int, MemoryBlock] = {}
        self._lock = threading.Lock()
        
        # Configuration
        self.gpu_memory_limit = 0.9  # 90% of GPU memory
        self.cpu_memory_limit = 0.8  # 80% of CPU memory
    
    def allocate_tensor(self, shape: tuple, dtype: np.dtype,
                        prefer_gpu: bool = True) -> Optional[np.ndarray]:
        """
        Allocate tensor with memory-aware decision
        
        Args:
            shape: Tensor shape
            dtype: Tensor dtype
            prefer_gpu: Whether to prefer GPU allocation
            
        Returns:
            Allocated tensor or None if failed
        """
        # Calculate required size
        size = int(np.prod(shape) * dtype.itemsize)
        
        # Check available memory
        available_memory = self.system_monitor.get_available_memory()
        
        # Choose allocation strategy based on policy
        if self.policy == MemoryPolicy.AGGRESSIVE_REUSE:
            # Try cache first
            cached_tensor = self.tensor_cache.get(shape, dtype)
            if cached_tensor is not None:
                self.cpu_pool.stats.cache_hits += 1
                return cached_tensor
            self.cpu_pool.stats.cache_misses += 1
        
        elif self.policy == MemoryPolicy.QUALITY_FIRST:
            # Always try GPU first
            if prefer_gpu and self._check_gpu_memory(size):
                tensor = self.gpu_pool.allocate_tensor(shape, dtype)
                if tensor is not None:
                    return tensor
        
        elif self.policy == MemoryPolicy.LATENCY_FIRST:
            # Use fastest available memory
            if prefer_gpu and self._check_gpu_memory(size):
                tensor = self.gpu_pool.allocate_tensor(shape, dtype)
                if tensor is not None:
                    return tensor
            
            # Fallback to CPU
            tensor = self._allocate_cpu_tensor(shape, dtype)
            if tensor is not None:
                return tensor
        
        else:  # BALANCED or CONSERVATIVE
            # Balanced approach
            if prefer_gpu and self._check_gpu_memory(size):
                tensor = self.gpu_pool.allocate_tensor(shape, dtype)
                if tensor is not None:
                    return tensor
            
            # Check CPU memory
            if self._check_cpu_memory(size):
                tensor = self._allocate_cpu_tensor(shape, dtype)
                if tensor is not None:
                    return tensor
        
        # If all else fails, try the other memory type
        if prefer_gpu:
            tensor = self._allocate_cpu_tensor(shape, dtype)
        else:
            tensor = self.gpu_pool.allocate_tensor(shape, dtype)
        
        return tensor
    
    def _allocate_cpu_tensor(self, shape: tuple, dtype: np.dtype) -> Optional[np.ndarray]:
        """Allocate CPU tensor"""
        size = int(np.prod(shape) * dtype.itemsize)
        
        block = self.cpu_pool.allocate(size)
        if block is None:
            return None
        
        tensor = np.zeros(shape, dtype=dtype)
        block.data = tensor
        
        # Track allocation
        with self._lock:
            self.allocations[id(tensor)] = block
        
        return tensor
    
    def _check_gpu_memory(self, size: int) -> bool:
        """Check if enough GPU memory is available"""
        if not self.gpu_pool.cuda_available:
            return False
        
        usage = self.gpu_pool.get_usage()
        available = usage["max_size"] - usage["current_usage"]
        
        return (available >= size and 
                usage["usage_percentage"] < self.gpu_memory_limit * 100)
    
    def _check_cpu_memory(self, size: int) -> bool:
        """Check if enough CPU memory is available"""
        usage = self.cpu_pool.get_usage()
        available = usage["max_size"] - usage["current_usage"]
        
        return (available >= size and 
                usage["usage_percentage"] < self.cpu_memory_limit * 100)
    
    def free_tensor(self, tensor: np.ndarray):
        """
        Free tensor memory
        
        Args:
            tensor: Tensor to free
        """
        # Add to cache if policy allows
        if self.policy == MemoryPolicy.AGGRESSIVE_REUSE:
            self.tensor_cache.add(tensor)
            return
        
        # Find and free block
        tensor_id = id(tensor)
        
        with self._lock:
            if tensor_id in self.allocations:
                block = self.allocations[tensor_id]
                
                # Determine which pool to use
                if block.size > 16 * 1024 * 1024:  # Large blocks go to GPU if available
                    if self.gpu_pool.cuda_available:
                        self.gpu_pool.free(block)
                    else:
                        self.cpu_pool.free(block)
                else:
                    self.cpu_pool.free(block)
                
                # Remove from tracking
                del self.allocations[tensor_id]
    
    def set_policy(self, policy: MemoryPolicy):
        """Set memory management policy"""
        self.policy = policy
        logger.info(f"Set memory policy to: {policy.value}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get memory manager statistics"""
        return {
            "policy": self.policy.value,
            "system_memory": self.system_monitor.get_memory_info(),
            "cpu_pool": self.cpu_pool.get_usage(),
            "gpu_pool": self.gpu_pool.get_usage(),
            "cache_stats": self.tensor_cache.get_stats(),
            "allocations_count": len(self.allocations)
        }
    
    def cleanup(self):
        """Clean up unused memory"""
        # Clean up pools
        self.cpu_pool.cleanup_expired()
        self.gpu_pool.cleanup_expired()
        
        # Clean up cache
        self.tensor_cache.cleanup()
        
        # Log statistics
        logger.info(f"Memory cleanup completed. Stats: {self.get_statistics()}")


class SystemMemoryMonitor:
    """Monitor system memory usage"""
    
    def __init__(self):
        """Initialize system monitor"""
        self.process = psutil.Process()
        self.history = deque(maxlen=100)
    
    def get_memory_info(self) -> Dict[str, Any]:
        """Get system memory information"""
        # Process memory
        process_mem = self.process.memory_info()
        
        # System memory
        system_mem = psutil.virtual_memory()
        
        return {
            "process_rss": process_mem.rss,
            "process_vms": process_mem.vms,
            "system_total": system_mem.total,
            "system_available": system_mem.available,
            "system_used": system_mem.used,
            "system_percent": system_mem.percent
        }
    
    def get_available_memory(self) -> int:
        """Get available system memory"""
        # Use available() for newer ps versions
        try:
            return self.process.memory_info().available
        except AttributeError:
            # Fallback for older ps versions
            return self.process.memory_info().rss


class TensorCache:
    """Cache for frequently used tensors with smart eviction strategies"""
    
    def __init__(self, max_size: int = 100, eviction_policy: str = "lru"):
        """
        Initialize tensor cache
        
        Args:
            max_size: Maximum number of cached tensors
            eviction_policy: Eviction policy ('lru', 'lfu', 'adaptive')
        """
        self.max_size = max_size
        self.eviction_policy = eviction_policy
        self.cache: Dict[str, np.ndarray] = {}
        self.access_times: Dict[str, float] = {}
        self.access_counts: Dict[str, int] = {}
        self.tensor_sizes: Dict[str, int] = {}
        self.stats = {
            "hits": 0,
            "misses": 0,
            "evictions": 0,
            "total_cached_bytes": 0,
            "cache_efficiency": 0.0
        }
    
    def get(self, shape: tuple, dtype: np.dtype) -> Optional[np.ndarray]:
        """
        Get tensor from cache with enhanced tracking
        
        Args:
            shape: Tensor shape
            dtype: Tensor dtype
            
        Returns:
            Cached tensor or None if not found
        """
        key = self._generate_key(shape, dtype)
        
        if key in self.cache:
            # Update access time and count
            self.access_times[key] = time.time()
            self.access_counts[key] = self.access_counts.get(key, 0) + 1
            
            # Update stats
            self.stats["hits"] += 1
            
            return self.cache[key]
        
        # Update stats
        self.stats["misses"] += 1
        
        return None
    
    def add(self, tensor: np.ndarray):
        """
        Add tensor to cache with enhanced tracking
        
        Args:
            tensor: Tensor to cache
        """
        if len(self.cache) >= self.max_size:
            self._evict_lru()
        
        key = self._generate_key(tensor.shape, tensor.dtype)
        
        # Calculate tensor size
        size = tensor.nbytes
        
        # Store tensor and metadata
        self.cache[key] = tensor
        self.access_times[key] = time.time()
        self.access_counts[key] = 0  # Will be incremented on first access
        self.tensor_sizes[key] = size
        
        # Update total cached bytes
        self.stats["total_cached_bytes"] += size
        self._update_cache_efficiency()
    
    def _generate_key(self, shape: tuple, dtype: np.dtype) -> str:
        """Generate cache key for tensor"""
        return f"{shape}-{dtype.str}"
    
    def _evict_lru(self):
        """Evict least recently used item with size tracking"""
        if not self.access_times:
            return
        
        # Find least recently used
        lru_key = min(self.access_times.items(), key=lambda x: x[1])[0]
        
        # Remove from cache and update stats
        if lru_key in self.tensor_sizes:
            self.stats["total_cached_bytes"] -= self.tensor_sizes[lru_key]
        
        self.cache.pop(lru_key, None)
        self.access_times.pop(lru_key, None)
        self.access_counts.pop(lru_key, None)
        self.tensor_sizes.pop(lru_key, None)
        
        # Update stats
        self.stats["evictions"] += 1
        self._update_cache_efficiency()
    
    def _update_cache_efficiency(self):
        """Calculate cache efficiency metrics"""
        total_requests = self.stats["hits"] + self.stats["misses"]
        if total_requests > 0:
            self.stats["cache_efficiency"] = self.stats["hits"] / total_requests
        else:
            self.stats["cache_efficiency"] = 0.0
    
    def cleanup(self):
        """Clean up expired cache entries with comprehensive tracking"""
        current_time = time.time()
        max_age = 300.0  # 5 minutes
        
        # Remove old entries
        expired_keys = [
            key for key, timestamp in self.access_times.items()
            if current_time - timestamp > max_age
        ]
        
        for key in expired_keys:
            if key in self.tensor_sizes:
                self.stats["total_cached_bytes"] -= self.tensor_sizes[key]
            
            self.cache.pop(key, None)
            self.access_times.pop(key, None)
            self.access_counts.pop(key, None)
            self.tensor_sizes.pop(key, None)
        
        # Update efficiency
        self._update_cache_efficiency()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        return self.stats.copy()


