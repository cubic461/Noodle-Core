"""
Ahr::Ahr Performance Optimizer - ahr_performance_optimizer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Enhanced Performance Optimizer for Adaptive Hybrid Runtime (AHR)
Implements intelligent caching, memory management, and horizontal scaling optimizations
"""

import asyncio
import time
import logging
import threading
import weakref
from typing import Dict, List, Optional, Set, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import heapq
import psutil
import gc
from concurrent.futures import ThreadPoolExecutor
from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from ..link import NoodleLink
from .ahr_base import AHRBase, ModelComponent, ExecutionMetrics

logger = logging.getLogger(__name__)


class OptimizationType(Enum):
    """Types of performance optimizations"""
    CACHE_OPTIMIZATION = "cache_optimization"
    MEMORY_OPTIMIZATION = "memory_optimization"
    EXECUTION_MODE_OPTIMIZATION = "execution_mode_optimization"
    LOAD_BALANCING = "load_balancing"
    PARALLELIZATION = "parallelization"
    JIT_COMPILATION = "jit_compilation"
    AOT_COMPILATION = "aot_compilation"


@dataclass
class OptimizationDecision:
    """Represents a performance optimization decision"""
    decision_id: str
    optimization_type: OptimizationType
    component_id: str
    model_id: str
    priority: float
    expected_improvement: float
    confidence: float
    execution_cost: float
    metadata: Dict[str, Any] = field(default_factory=dict)
    status: str = "pending"  # pending, executing, completed, failed
    created_at: float = field(default_factory=time.time)
    executed_at: Optional[float] = None
    completed_at: Optional[float] = None


@dataclass
class CacheEntry:
    """Represents a cache entry with metadata"""
    key: str
    value: Any
    size: int
    access_count: int = 0
    last_accessed: float = field(default_factory=time.time)
    created_at: float = field(default_factory=time.time)
    expiration_time: Optional[float] = None
    access_pattern: str = "unknown"  # hot, warm, cold


class IntelligentCache:
    """Intelligent caching system with adaptive eviction policies"""
    
    def __init__(self, max_size_mb: int = 512, eviction_policy: str = "lru"):
        self.max_size_bytes = max_size_mb * 1024 * 1024
        self.eviction_policy = eviction_policy
        self.cache: Dict[str, CacheEntry] = {}
        self.access_history: deque = deque(maxlen=10000)
        self.size_bytes = 0
        self.hits = 0
        self.misses = 0
        self.lock = threading.RLock()
        
        # Cache statistics
        self.stats = {
            'total_accesses': 0,
            'hits': 0,
            'misses': 0,
            'evictions': 0,
            'current_size_bytes': 0,
            'hit_rate': 0.0
        }
    
    def get(self, key: str) -> Optional[Any]:
        """Get value from cache with intelligent eviction"""
        with self.lock:
            self.stats['total_accesses'] += 1
            
            if key in self.cache:
                entry = self.cache[key]
                entry.access_count += 1
                entry.last_accessed = time.time()
                self.access_history.append((key, time.time(), 'hit'))
                self.hits += 1
                self.stats['hits'] += 1
                self.stats['hit_rate'] = self.hits / self.stats['total_accesses']
                return entry.value
            
            self.misses += 1
            self.stats['misses'] += 1
            self.stats['hit_rate'] = self.hits / self.stats['total_accesses']
            self.access_history.append((key, time.time(), 'miss'))
            return None
    
    def put(self, key: str, value: Any, size: int, expiration_time: Optional[float] = None):
        """Put value in cache with size tracking"""
        with self.lock:
            # Check if we need to evict
            while self.size_bytes + size > self.max_size_bytes and self.cache:
                self._evict_entry()
            
            # Create new entry
            entry = CacheEntry(
                key=key,
                value=value,
                size=size,
                expiration_time=expiration_time,
                last_accessed=time.time()
            )
            
            self.cache[key] = entry
            self.size_bytes += size
            self.stats['current_size_bytes'] = self.size_bytes
    
    def _evict_entry(self):
        """Evict entry based on policy"""
        if not self.cache:
            return
        
        if self.eviction_policy == "lru":
            # Least Recently Used
            oldest_key = min(self.cache.keys(), 
                           key=lambda k: self.cache[k].last_accessed)
        elif self.eviction_policy == "lfu":
            # Least Frequently Used
            oldest_key = min(self.cache.keys(), 
                           key=lambda k: self.cache[k].access_count)
        elif self.eviction_policy == "adaptive":
            # Adaptive based on access patterns
            oldest_key = self._adaptive_eviction()
        else:
            oldest_key = next(iter(self.cache.keys()))
        
        self._remove_entry(oldest_key)
    
    def _adaptive_eviction(self) -> str:
        """Adaptive eviction based on access patterns"""
        # Score entries based on recency, frequency, and size
        scored_entries = []
        current_time = time.time()
        
        for key, entry in self.cache.items():
            recency_score = 1.0 / (current_time - entry.last_accessed + 1)
            frequency_score = entry.access_count
            size_penalty = entry.size / 1024  # KB penalty
            
            score = (recency_score * 0.4 + frequency_score * 0.6) / (size_penalty + 1)
            scored_entries.append((score, key))
        
        # Return lowest scoring entry
        return min(scored_entries, key=lambda x: x[0])[1]
    
    def _remove_entry(self, key: str):
        """Remove entry from cache"""
        if key in self.cache:
            entry = self.cache[key]
            del self.cache[key]
            self.size_bytes -= entry.size
            self.stats['current_size_bytes'] = self.size_bytes
            self.stats['evictions'] += 1
    
    def clear_expired(self):
        """Clear expired entries"""
        current_time = time.time()
        expired_keys = []
        
        for key, entry in self.cache.items():
            if (entry.expiration_time and 
                current_time > entry.expiration_time):
                expired_keys.append(key)
        
        for key in expired_keys:
            self._remove_entry(key)
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        return self.stats.copy()
    
    def optimize_access_patterns(self):
        """Analyze access patterns and optimize cache"""
        if len(self.access_history) < 100:
            return
        
        # Analyze recent access patterns
        recent_accesses = list(self.access_history)[-1000:]
        hot_keys = set()
        cold_keys = set()
        
        # Identify hot and cold keys
        key_access_times = defaultdict(list)
        for key, timestamp, access_type in recent_accesses:
            key_access_times[key].append(timestamp)
        
        for key, access_times in key_access_times.items():
            if len(access_times) > 10:  # Frequently accessed
                hot_keys.add(key)
            elif len(access_times) < 2:  # Rarely accessed
                cold_keys.add(key)
        
        # Adjust cache behavior based on patterns
        if hot_keys:
            logger.info(f"Identified {len(hot_keys)} hot keys for optimization")
        
        if cold_keys:
            logger.info(f"Identified {len(cold_keys)} cold keys for potential eviction")


class MemoryOptimizer:
    """Advanced memory management and optimization"""
    
    def __init__(self, max_memory_mb: int = 2048):
        self.max_memory_bytes = max_memory_mb * 1024 * 1024
        self.current_memory_bytes = 0
        self.memory_threshold = 0.8  # 80% threshold
        self.gc_threshold = 0.9  # 90% threshold
        self.object_refs = weakref.WeakValueDictionary()
        self.memory_pools = {}
        self.lock = threading.RLock()
        
        # Memory statistics
        self.stats = {
            'total_allocated': 0,
            'total_freed': 0,
            'gc_cycles': 0,
            'peak_memory': 0,
            'current_memory': 0,
            'memory_efficiency': 0.0
        }
    
    def allocate_memory(self, size: int, pool_name: str = "default") -> int:
        """Allocate memory with pool management"""
        with self.lock:
            self.current_memory_bytes += size
            self.stats['total_allocated'] += size
            self.stats['current_memory'] = self.current_memory_bytes
            self.stats['peak_memory'] = max(self.stats['peak_memory'], 
                                          self.current_memory_bytes)
            
            # Check memory thresholds
            if self.current_memory_bytes > self.max_memory_bytes * self.gc_threshold:
                self._trigger_gc()
            
            if self.current_memory_bytes > self.max_memory_bytes * self.memory_threshold:
                self._optimize_memory()
            
            return id(object())  # Return object ID as memory address
    
    def free_memory(self, size: int):
        """Free memory"""
        with self.lock:
            self.current_memory_bytes = max(0, self.current_memory_bytes - size)
            self.stats['total_freed'] += size
            self.stats['current_memory'] = self.current_memory_bytes
    
    def _trigger_gc(self):
        """Trigger garbage collection"""
        gc.collect()
        self.stats['gc_cycles'] += 1
        logger.info(f"Triggered garbage collection (cycle {self.stats['gc_cycles']})")
    
    def _optimize_memory(self):
        """Optimize memory usage"""
        # Force garbage collection
        gc.collect()
        
        # Clear unused pools
        for pool_name in list(self.memory_pools.keys()):
            if not self.memory_pools[pool_name]['active_objects']:
                del self.memory_pools[pool_name]
        
        # Compress memory if needed
        if self.current_memory_bytes > self.max_memory_bytes * 0.95:
            self._compress_memory()
    
    def _compress_memory(self):
        """Compress memory usage"""
        # This is a placeholder for memory compression logic
        # In a real implementation, this would involve:
        # - Object deduplication
        # - Memory defragmentation
        # - Swapping to disk
        logger.warning("Memory compression triggered - consider increasing memory limit")
    
    def get_memory_stats(self) -> Dict[str, Any]:
        """Get memory statistics"""
        with self.lock:
            efficiency = (self.stats['total_freed'] / 
                         max(self.stats['total_allocated'], 1))
            
            return {
                **self.stats,
                'memory_usage_percent': (self.current_memory_bytes / 
                                       self.max_memory_bytes) * 100,
                'memory_efficiency': efficiency,
                'available_memory': self.max_memory_bytes - self.current_memory_bytes
            }


class PerformanceOptimizer:
    """Main performance optimizer for AHR"""
    
    def __init__(self, ahr: AHRBase, mesh: NoodleMesh, config: NoodleNetConfig):
        self.ahr = ahr
        self.mesh = mesh
        self.config = config
        
        # Optimization components
        self.cache = IntelligentCache(
            max_size_mb=config.get('cache_size_mb', 512),
            eviction_policy=config.get('cache_eviction_policy', 'adaptive')
        )
        
        self.memory_optimizer = MemoryOptimizer(
            max_memory_mb=config.get('max_memory_mb', 2048)
        )
        
        # Optimization decisions
        self.decisions: Dict[str, OptimizationDecision] = {}
        self.decision_queue = []
        self.max_concurrent_optimizations = config.get('max_concurrent_optimizations', 5)
        
        # Performance monitoring
        self.performance_history = deque(maxlen=10000)
        self.optimization_history = deque(maxlen=1000)
        
        # Thread pool for async optimizations
        self.executor = ThreadPoolExecutor(max_workers=self.max_concurrent_optimizations)
        
        # Running state
        self._running = False
        self._optimization_task = None
        
        logger.info("PerformanceOptimizer initialized")
    
    async def start(self):
        """Start the performance optimizer"""
        if self._running:
            return
        
        self._running = True
        self._optimization_task = asyncio.create_task(self._optimization_loop())
        
        # Start memory monitoring
        asyncio.create_task(self._memory_monitoring_loop())
        
        logger.info("PerformanceOptimizer started")
    
    async def stop(self):
        """Stop the performance optimizer"""
        if not self._running:
            return
        
        self._running = False
        
        if self._optimization_task:
            self._optimization_task.cancel()
            try:
                await self._optimization_task
            except asyncio.CancelledError:
                pass
        
        self.executor.shutdown(wait=True)
        
        logger.info("PerformanceOptimizer stopped")
    
    async def _optimization_loop(self):
        """Main optimization loop"""
        while self._running:
            try:
                # Evaluate optimization opportunities
                decisions = await self._evaluate_optimization_opportunities()
                
                # Execute high-priority decisions
                await self._execute_optimizations(decisions)
                
                # Update cache and memory
                self.cache.optimize_access_patterns()
                self.memory_optimizer._optimize_memory()
                
                # Wait for next iteration
                await asyncio.sleep(5.0)
                
            except Exception as e:
                logger.error(f"Error in optimization loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _memory_monitoring_loop(self):
        """Memory monitoring loop"""
        while self._running:
            try:
                # Get current memory usage
                memory_stats = self.memory_optimizer.get_memory_stats()
                
                # Log memory warnings
                if memory_stats['memory_usage_percent'] > 90:
                    logger.warning(f"High memory usage: {memory_stats['memory_usage_percent']:.1f}%")
                
                # Record performance metrics
                self.performance_history.append({
                    'timestamp': time.time(),
                    'memory_usage': memory_stats['memory_usage_percent'],
                    'cache_hit_rate': self.cache.stats['hit_rate'],
                    'active_decisions': len(self.decisions)
                })
                
                await asyncio.sleep(10.0)
                
            except Exception as e:
                logger.error(f"Error in memory monitoring loop: {e}")
                await asyncio.sleep(5.0)
    
    async def _evaluate_optimization_opportunities(self) -> List[OptimizationDecision]:
        """Evaluate optimization opportunities across all models"""
        decisions = []
        
        for model_id, profile in self.ahr.model_profiles.items():
            # Evaluate cache optimizations
            cache_decisions = await self._evaluate_cache_optimizations(model_id, profile)
            decisions.extend(cache_decisions)
            
            # Evaluate execution mode optimizations
            execution_decisions = await self._evaluate_execution_mode_optimizations(model_id, profile)
            decisions.extend(execution_decisions)
            
            # Evaluate memory optimizations
            memory_decisions = await self._evaluate_memory_optimizations(model_id, profile)
            decisions.extend(memory_decisions)
        
        # Sort by priority
        decisions.sort(key=lambda d: d.priority, reverse=True)
        
        return decisions[:20]  # Limit to top 20 decisions
    
    async def _evaluate_cache_optimizations(self, model_id: str, profile) -> List[OptimizationDecision]:
        """Evaluate cache optimization opportunities"""
        decisions = []
        
        for component_id, component in profile.components.items():
            # Check if component is frequently executed
            if component.execution_count > 50 and component.average_latency > 10:
                # Create cache optimization decision
                decision = OptimizationDecision(
                    decision_id=f"cache_{model_id}_{component_id}_{int(time.time())}",
                    optimization_type=OptimizationType.CACHE_OPTIMIZATION,
                    component_id=component_id,
                    model_id=model_id,
                    priority=0.8,
                    expected_improvement=component.average_latency * 0.5,
                    confidence=0.7,
                    execution_cost=1.0,
                    metadata={
                        'current_latency': component.average_latency,
                        'execution_count': component.execution_count
                    }
                )
                decisions.append(decision)
        
        return decisions
    
    async def _evaluate_execution_mode_optimizations(self, model_id: str, profile) -> List[OptimizationDecision]:
        """Evaluate execution mode optimization opportunities"""
        decisions = []
        
        for component_id, component in profile.components.items():
            # Check if component should be optimized to JIT or AOT
            if (component.execution_mode.value == "interpreter" and 
                component.execution_count > 100 and
                component.average_latency > 50):
                
                # Determine best execution mode
                if component.average_latency > 100:
                    target_mode = "aot"
                    improvement_factor = 0.8
                else:
                    target_mode = "jit"
                    improvement_factor = 0.6
                
                decision = OptimizationDecision(
                    decision_id=f"execution_mode_{model_id}_{component_id}_{int(time.time())}",
                    optimization_type=OptimizationType.EXECUTION_MODE_OPTIMIZATION,
                    component_id=component_id,
                    model_id=model_id,
                    priority=0.9,
                    expected_improvement=component.average_latency * improvement_factor,
                    confidence=0.8,
                    execution_cost=5.0,
                    metadata={
                        'current_mode': component.execution_mode.value,
                        'target_mode': target_mode,
                        'current_latency': component.average_latency
                    }
                )
                decisions.append(decision)
        
        return decisions
    
    async def _evaluate_memory_optimizations(self, model_id: str, profile) -> List[OptimizationDecision]:
        """Evaluate memory optimization opportunities"""
        decisions = []
        
        # Check overall memory usage
        memory_stats = self.memory_optimizer.get_memory_stats()
        if memory_stats['memory_usage_percent'] > 80:
            decision = OptimizationDecision(
                decision_id=f"memory_{model_id}_{int(time.time())}",
                optimization_type=OptimizationType.MEMORY_OPTIMIZATION,
                component_id="global",
                model_id=model_id,
                priority=0.95,
                expected_improvement=memory_stats['memory_usage_percent'] * 0.1,
                confidence=0.9,
                execution_cost=2.0,
                metadata={
                    'current_memory_usage': memory_stats['memory_usage_percent'],
                    'available_memory': memory_stats['available_memory']
                }
            )
            decisions.append(decision)
        
        return decisions
    
    async def _execute_optimizations(self, decisions: List[OptimizationDecision]):
        """Execute optimization decisions"""
        if not decisions:
            return
        
        # Limit concurrent optimizations
        active_decisions = [d for d in self.decisions.values() if d.status == "executing"]
        available_slots = self.max_concurrent_optimizations - len(active_decisions)
        
        decisions_to_execute = decisions[:available_slots]
        
        for decision in decisions_to_execute:
            await self._execute_optimization(decision)
    
    async def _execute_optimization(self, decision: OptimizationDecision):
        """Execute a single optimization decision"""
        decision.status = "executing"
        decision.executed_at = time.time()
        self.decisions[decision.decision_id] = decision
        
        try:
            if decision.optimization_type == OptimizationType.CACHE_OPTIMIZATION:
                await self._execute_cache_optimization(decision)
            elif decision.optimization_type == OptimizationType.EXECUTION_MODE_OPTIMIZATION:
                await self._execute_execution_mode_optimization(decision)
            elif decision.optimization_type == OptimizationType.MEMORY_OPTIMIZATION:
                await self._execute_memory_optimization(decision)
            
            decision.status = "completed"
            decision.completed_at = time.time()
            
            logger.info(f"Optimization {decision.decision_id} completed successfully")
            
        except Exception as e:
            decision.status = "failed"
            decision.completed_at = time.time()
            logger.error(f"Optimization {decision.decision_id} failed: {e}")
    
    async def _execute_cache_optimization(self, decision: OptimizationDecision):
        """Execute cache optimization"""
        # Cache the component's execution results
        component = self.ahr.model_profiles[decision.model_id].components[decision.component_id]
        
        # Create cache key based on component parameters
        cache_key = f"{decision.model_id}_{decision.component_id}_{component.execution_count}"
        
        # Cache the component (placeholder for actual caching logic)
        self.cache.put(
            key=cache_key,
            value=component,  # This would be the actual execution result
            size=1024,  # Estimated size
            expiration_time=time.time() + 3600  # 1 hour expiration
        )
    
    async def _execute_execution_mode_optimization(self, decision: OptimizationDecision):
        """Execute execution mode optimization"""
        component = self.ahr.model_profiles[decision.model_id].components[decision.component_id]
        
        # Update execution mode based on decision
        target_mode = decision.metadata['target_mode']
        if target_mode == "jit":
            component.execution_mode = ExecutionMode.JIT
        elif target_mode == "aot":
            component.execution_mode = ExecutionMode.AOT
        
        logger.info(f"Updated {decision.component_id} execution mode to {target_mode}")
    
    async def _execute_memory_optimization(self, decision: OptimizationDecision):
        """Execute memory optimization"""
        # Trigger garbage collection
        self.memory_optimizer._trigger_gc()
        
        # Clear cache if needed
        if self.cache.stats['current_size_bytes'] > self.cache.max_size_bytes * 0.9:
            self.cache.clear_expired()
        
        logger.info("Memory optimization executed")
    
    def get_optimization_summary(self) -> Dict[str, Any]:
        """Get optimization summary"""
        total_decisions = len(self.decisions)
        completed_decisions = len([d for d in self.decisions.values() if d.status == "completed"])
        failed_decisions = len([d for d in self.decisions.values() if d.status == "failed"])
        
        # Calculate average improvement
        completed = [d for d in self.decisions.values() if d.status == "completed"]
        avg_improvement = 0.0
        if completed:
            avg_improvement = sum(d.expected_improvement for d in completed) / len(completed)
        
        return {
            'total_decisions': total_decisions,
            'completed_decisions': completed_decisions,
            'failed_decisions': failed_decisions,
            'average_improvement': avg_improvement,
            'cache_stats': self.cache.get_stats(),
            'memory_stats': self.memory_optimizer.get_memory_stats(),
            'performance_history': list(self.performance_history)[-10:]  # Last 10 entries
        }
    
    def get_decision_statistics(self) -> Dict[str, Any]:
        """Get decision statistics"""
        decisions_by_type = defaultdict(int)
        decisions_by_status = defaultdict(int)
        
        for decision in self.decisions.values():
            decisions_by_type[decision.optimization_type.value] += 1
            decisions_by_status[decision.status] += 1
        
        return {
            'total_decisions': len(self.decisions),
            'decisions_by_type': dict(decisions_by_type),
            'decisions_by_status': dict(decisions_by_status)
        }
    
    def is_optimization_active(self) -> bool:
        """Check if optimization is active"""
        return self._running

