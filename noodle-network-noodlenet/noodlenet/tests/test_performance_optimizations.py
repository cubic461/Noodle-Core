"""
Test Suite::Tests - test_performance_optimizations.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive tests for performance optimizations
Tests caching, memory management, horizontal scaling, and monitoring
"""

import pytest
import asyncio
import time
import threading
from unittest.mock import Mock, patch, AsyncMock
from typing import Dict, List, Any

# Import the performance optimization modules
from ..ahr.ahr_performance_optimizer import (
    PerformanceOptimizer, IntelligentCache, MemoryOptimizer, 
    OptimizationDecision, OptimizationType
)
from ..scaling.horizontal_scaler import (
    HorizontalScaler, LoadBalancer, ScalingDecision, ScalingAction,
    ScalingMetric
)
from ..monitoring.performance_monitor import (
    PerformanceMonitor, MetricData, MetricType, AlertLevel, Alert
)
from ..mesh import NoodleMesh, NodeMetrics
from ..config import NoodleNetConfig
from ..ahr.ahr_base import AHRBase, ModelComponent, ExecutionMode


class TestIntelligentCache:
    """Test the intelligent caching system"""
    
    def test_cache_initialization(self):
        """Test cache initialization with default parameters"""
        cache = IntelligentCache(max_size_mb=256, eviction_policy="lru")
        
        assert cache.max_size_bytes == 256 * 1024 * 1024
        assert cache.eviction_policy == "lru"
        assert len(cache.cache) == 0
        assert cache.size_bytes == 0
        assert cache.hits == 0
        assert cache.misses == 0
    
    def test_cache_put_and_get(self):
        """Test basic cache put and get operations"""
        cache = IntelligentCache(max_size_mb=1)
        
        # Put a value in cache
        cache.put("key1", "value1", 1024)
        
        # Get the value
        value = cache.get("key1")
        assert value == "value1"
        
        # Check cache statistics
        assert cache.stats['total_accesses'] == 1
        assert cache.stats['hits'] == 1
        assert cache.stats['misses'] == 0
        assert cache.stats['hit_rate'] == 1.0
    
    def test_cache_miss(self):
        """Test cache miss behavior"""
        cache = IntelligentCache(max_size_mb=1)
        
        # Try to get a non-existent key
        value = cache.get("nonexistent_key")
        assert value is None
        
        # Check cache statistics
        assert cache.stats['total_accesses'] == 1
        assert cache.stats['hits'] == 0
        assert cache.stats['misses'] == 1
        assert cache.stats['hit_rate'] == 0.0
    
    def test_cache_eviction_lru(self):
        """Test LRU cache eviction policy"""
        cache = IntelligentCache(max_size_mb=1, eviction_policy="lru")
        
        # Fill cache to capacity
        for i in range(10):
            cache.put(f"key{i}", f"value{i}", 10240)  # 10KB each
        
        # Add one more item to trigger eviction
        cache.put("key10", "value10", 10240)
        
        # The first key should have been evicted
        assert cache.get("key0") is None
        assert cache.get("key1") is not None
    
    def test_cache_eviction_lfu(self):
        """Test LFU cache eviction policy"""
        cache = IntelligentCache(max_size_mb=1, eviction_policy="lfu")
        
        # Add items with different access patterns
        cache.put("key1", "value1", 10240)
        cache.put("key2", "value2", 10240)
        
        # Access key1 multiple times
        for _ in range(5):
            cache.get("key1")
        
        # Add more items to fill cache
        cache.put("key3", "value3", 10240)
        cache.put("key4", "value4", 10240)
        
        # Add one more item to trigger eviction
        cache.put("key5", "value5", 10240)
        
        # key2 should have been evicted (least frequently used)
        assert cache.get("key2") is None
        assert cache.get("key1") is not None
    
    def test_cache_clear_expired(self):
        """Test clearing expired cache entries"""
        cache = IntelligentCache(max_size_mb=1)
        
        # Add an expired entry
        cache.put("expired_key", "value", 1024, expiration_time=time.time() - 1)
        
        # Add a valid entry
        cache.put("valid_key", "value", 1024, expiration_time=time.time() + 3600)
        
        # Clear expired entries
        cache.clear_expired()
        
        # Check that expired entry is removed
        assert cache.get("expired_key") is None
        assert cache.get("valid_key") is not None
    
    def test_cache_optimize_access_patterns(self):
        """Test cache access pattern optimization"""
        cache = IntelligentCache(max_size_mb=1)
        
        # Simulate access patterns
        for i in range(20):
            cache.put(f"key{i}", f"value{i}", 1024)
        
        # Access some keys frequently
        for _ in range(10):
            cache.get("key1")
            cache.get("key2")
        
        # Access some keys rarely
        cache.get("key19")
        
        # Optimize access patterns
        cache.optimize_access_patterns()
        
        # Check that hot keys are identified
        assert len(cache.access_history) > 0


class TestMemoryOptimizer:
    """Test the memory optimization system"""
    
    def test_memory_optimizer_initialization(self):
        """Test memory optimizer initialization"""
        optimizer = MemoryOptimizer(max_memory_mb=1024)
        
        assert optimizer.max_memory_bytes == 1024 * 1024 * 1024
        assert optimizer.current_memory_bytes == 0
        assert optimizer.memory_threshold == 0.8
        assert optimizer.gc_threshold == 0.9
    
    def test_memory_allocation(self):
        """Test memory allocation"""
        optimizer = MemoryOptimizer(max_memory_mb=1024)
        
        # Allocate memory
        address = optimizer.allocate_memory(1024, "test_pool")
        
        assert optimizer.current_memory_bytes == 1024
        assert optimizer.stats['total_allocated'] == 1024
        assert optimizer.stats['current_memory'] == 1024
    
    def test_memory_freeing(self):
        """Test memory freeing"""
        optimizer = MemoryOptimizer(max_memory_mb=1024)
        
        # Allocate and free memory
        optimizer.allocate_memory(1024, "test_pool")
        optimizer.free_memory(512)
        
        assert optimizer.current_memory_bytes == 512
        assert optimizer.stats['total_freed'] == 512
    
    def test_memory_threshold_triggers(self):
        """Test memory threshold triggers"""
        optimizer = MemoryOptimizer(max_memory_mb=1024)
        
        # Allocate memory to trigger GC threshold
        optimizer.allocate_memory(921600000)  # 90% of 1GB
        
        # GC should have been triggered
        assert optimizer.stats['gc_cycles'] >= 1
    
    def test_memory_stats(self):
        """Test memory statistics"""
        optimizer = MemoryOptimizer(max_memory_mb=1024)
        
        # Allocate some memory
        optimizer.allocate_memory(512000)
        optimizer.allocate_memory(256000)
        optimizer.free_memory(128000)
        
        stats = optimizer.get_memory_stats()
        
        assert stats['total_allocated'] == 768000
        assert stats['total_freed'] == 128000
        assert stats['current_memory'] == 640000
        assert stats['memory_usage_percent'] == (640000 / (1024 * 1024 * 1024)) * 100


class TestLoadBalancer:
    """Test the load balancer"""
    
    def test_load_balancer_initialization(self):
        """Test load balancer initialization"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        load_balancer = LoadBalancer(mesh, config)
        
        assert load_balancer.mesh == mesh
        assert load_balancer.current_strategy == 'resource_based'
        assert len(load_balancer.strategies) > 0
    
    def test_round_robin_strategy(self):
        """Test round-robin load balancing strategy"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        load_balancer = LoadBalancer(mesh, config)
        
        # Create mock load metrics
        loads = [
            ("node1", Mock(active_connections=5)),
            ("node2", Mock(active_connections=3)),
            ("node3", Mock(active_connections=7))
        ]
        
        # Test round-robin selection
        selected1 = load_balancer._round_robin_strategy(loads, {})
        selected2 = load_balancer._round_robin_strategy(loads, {})
        selected3 = load_balancer._round_robin_strategy(loads, {})
        
        assert selected1 != selected2
        assert selected2 != selected3
    
    def test_least_connections_strategy(self):
        """Test least connections load balancing strategy"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        load_balancer = LoadBalancer(mesh, config)
        
        # Create mock load metrics
        loads = [
            ("node1", Mock(active_connections=5)),
            ("node2", Mock(active_connections=3)),
            ("node3", Mock(active_connections=7))
        ]
        
        selected = load_balancer._least_connections_strategy(loads, {})
        assert selected == "node2"
    
    def test_resource_based_strategy(self):
        """Test resource-based load balancing strategy"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        load_balancer = LoadBalancer(mesh, config)
        
        # Create mock load metrics
        loads = [
            ("node1", Mock(cpu_usage=80.0, memory_usage=70.0, active_connections=5, response_time=100.0)),
            ("node2", Mock(cpu_usage=60.0, memory_usage=50.0, active_connections=3, response_time=50.0)),
            ("node3", Mock(cpu_usage=90.0, memory_usage=80.0, active_connections=7, response_time=150.0))
        ]
        
        selected = load_balancer._resource_based_strategy(loads, {})
        assert selected == "node2"  # Should select the least loaded node
    
    def test_load_balancer_stats(self):
        """Test load balancer statistics"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        load_balancer = LoadBalancer(mesh, config)
        
        # Update some load metrics
        load_balancer.update_node_load("node1", {
            'cpu_usage': 70.0,
            'memory_usage': 60.0,
            'request_count': 100,
            'response_time': 50.0,
            'error_rate': 0.01,
            'throughput': 10.0,
            'active_connections': 5,
            'queue_size': 2
        })
        
        stats = load_balancer.get_balancer_stats()
        
        assert stats['active_nodes'] == 1
        assert 'load_distribution' in stats
        assert 'node1' in stats['load_distribution']


class TestHorizontalScaler:
    """Test the horizontal scaling system"""
    
    def test_horizontal_scaler_initialization(self):
        """Test horizontal scaler initialization"""
        mesh = Mock(spec=NoodleMesh)
        load_balancer = Mock(spec=LoadBalancer)
        identity_manager = Mock()
        config = NoodleNetConfig()
        
        scaler = HorizontalScaler(mesh, load_balancer, identity_manager, config)
        
        assert scaler.mesh == mesh
        assert scaler.load_balancer == load_balancer
        assert scaler.min_nodes == 2
        assert scaler.max_nodes == 10
        assert scaler.auto_scaling_enabled == True
    
    def test_should_scale_up(self):
        """Test scale up condition evaluation"""
        mesh = Mock(spec=NoodleMesh)
        load_balancer = Mock(spec=LoadBalancer)
        identity_manager = Mock()
        config = NoodleNetConfig()
        
        scaler = HorizontalScaler(mesh, load_balancer, identity_manager, config)
        
        # Mock node count below max
        mesh.get_node_count.return_value = 5
        
        # Test metrics that should trigger scale up
        metrics = {
            'node_count': 5,
            'average_cpu': 85.0,  # Above threshold
            'average_memory': 80.0,
            'total_requests': 1500,
            'average_response_time': 1200.0,
            'average_error_rate': 0.08
        }
        
        assert scaler._should_scale_up(metrics) == True
    
    def test_should_scale_down(self):
        """Test scale down condition evaluation"""
        mesh = Mock(spec=NoodleMesh)
        load_balancer = Mock(spec=LoadBalancer)
        identity_manager = Mock()
        config = NoodleNetConfig()
        
        scaler = HorizontalScaler(mesh, load_balancer, identity_manager, config)
        
        # Mock node count above min
        mesh.get_node_count.return_value = 5
        
        # Test metrics that should trigger scale down
        metrics = {
            'node_count': 5,
            'average_cpu': 25.0,  # Well below threshold
            'average_memory': 30.0,
            'total_requests': 200,
            'average_response_time': 100.0,
            'average_error_rate': 0.01
        }
        
        assert scaler._should_scale_down(metrics) == True
    
    def test_should_not_scale_below_min(self):
        """Test that scaling doesn't go below minimum"""
        mesh = Mock(spec=NoodleMesh)
        load_balancer = Mock(spec=LoadBalancer)
        identity_manager = Mock()
        config = NoodleNetConfig()
        
        scaler = HorizontalScaler(mesh, load_balancer, identity_manager, config)
        scaler.min_nodes = 2
        
        # Mock node count at minimum
        mesh.get_node_count.return_value = 2
        
        # Test metrics that would normally trigger scale down
        metrics = {
            'node_count': 2,
            'average_cpu': 25.0,
            'average_memory': 30.0,
            'total_requests': 200,
            'average_response_time': 100.0,
            'average_error_rate': 0.01
        }
        
        assert scaler._should_scale_down(metrics) == False


class TestPerformanceMonitor:
    """Test the performance monitoring system"""
    
    def test_performance_monitor_initialization(self):
        """Test performance monitor initialization"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        monitor = PerformanceMonitor(mesh, config)
        
        assert monitor.mesh == mesh
        assert monitor.collection_interval == 5.0
        assert len(monitor.alert_thresholds) > 0
        assert monitor.stats['total_metrics_collected'] == 0
    
    def test_record_metric(self):
        """Test metric recording"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        monitor = PerformanceMonitor(mesh, config)
        
        # Record a metric
        metric_data = MetricData(
            timestamp=time.time(),
            metric_type=MetricType.CPU,
            value=75.0,
            node_id="node1"
        )
        
        monitor._record_metric(metric_data)
        
        # Check that metric was recorded
        assert len(monitor.metrics) > 0
        assert monitor.stats['total_metrics_collected'] == 1
    
    def test_create_alert(self):
        """Test alert creation"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        monitor = PerformanceMonitor(mesh, config)
        
        # Create an alert
        monitor._create_alert(
            metric_type=MetricType.CPU,
            current_value=95.0,
            threshold=90.0,
            node_id="node1",
            message="High CPU usage"
        )
        
        # Check that alert was created
        assert len(monitor.alerts) == 1
        assert monitor.stats['total_alerts_generated'] == 1
        assert monitor.stats['active_alerts'] == 1
    
    def test_resolve_alert(self):
        """Test alert resolution"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        monitor = PerformanceMonitor(mesh, config)
        
        # Create and resolve an alert
        monitor._create_alert(
            metric_type=MetricType.CPU,
            current_value=95.0,
            threshold=90.0,
            node_id="node1",
            message="High CPU usage"
        )
        
        alert_id = list(monitor.alerts.keys())[0]
        monitor.resolve_alert(alert_id)
        
        # Check that alert was resolved
        assert monitor.alerts[alert_id].resolved == True
        assert monitor.stats['active_alerts'] == 0
        assert monitor.stats['resolved_alerts'] == 1
    
    def test_metrics_summary(self):
        """Test metrics summary generation"""
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        monitor = PerformanceMonitor(mesh, config)
        
        # Record some metrics
        for i in range(10):
            metric_data = MetricData(
                timestamp=time.time() + i,
                metric_type=MetricType.CPU,
                value=70.0 + i,
                node_id="node1"
            )
            monitor._record_metric(metric_data)
        
        # Get summary
        summary = monitor.get_metrics_summary(MetricType.CPU, time_range=60)
        
        assert summary['metric_type'] == 'cpu'
        assert summary['count'] == 10
        assert summary['latest_value'] == 79.0
        assert summary['mean_value'] == 74.5


class TestPerformanceOptimizer:
    """Test the main performance optimizer"""
    
    def test_performance_optimizer_initialization(self):
        """Test performance optimizer initialization"""
        ahr = Mock(spec=AHRBase)
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        optimizer = PerformanceOptimizer(ahr, mesh, config)
        
        assert optimizer.ahr == ahr
        assert optimizer.mesh == mesh
        assert optimizer.config == config
        assert isinstance(optimizer.cache, IntelligentCache)
        assert isinstance(optimizer.memory_optimizer, MemoryOptimizer)
    
    @pytest.mark.asyncio
    async def test_start_and_stop(self):
        """Test starting and stopping the optimizer"""
        ahr = Mock(spec=AHRBase)
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        optimizer = PerformanceOptimizer(ahr, mesh, config)
        
        # Start optimizer
        await optimizer.start()
        assert optimizer.is_optimization_active() == True
        
        # Stop optimizer
        await optimizer.stop()
        assert optimizer.is_optimization_active() == False
    
    @pytest.mark.asyncio
    async def test_evaluate_cache_optimizations(self):
        """Test cache optimization evaluation"""
        ahr = Mock(spec=AHRBase)
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        optimizer = PerformanceOptimizer(ahr, mesh, config)
        
        # Mock model profile with components
        component = ModelComponent("comp1", "dense")
        component.execution_count = 100
        component.average_latency = 50.0
        
        profile = Mock()
        profile.components = {"comp1": component}
        
        # Mock model profiles
        ahr.model_profiles = {"model1": profile}
        
        # Evaluate optimizations
        decisions = await optimizer._evaluate_cache_optimizations("model1", profile)
        
        # Should have cache optimization decisions
        assert len(decisions) > 0
        assert decisions[0].optimization_type == OptimizationType.CACHE_OPTIMIZATION


class TestIntegration:
    """Integration tests for performance optimization components"""
    
    @pytest.mark.asyncio
    async def test_full_optimization_workflow(self):
        """Test full optimization workflow"""
        # Create mock components
        ahr = Mock(spec=AHRBase)
        mesh = Mock(spec=NoodleMesh)
        config = NoodleNetConfig()
        
        # Initialize all components
        optimizer = PerformanceOptimizer(ahr, mesh, config)
        load_balancer = LoadBalancer(mesh, config)
        scaler = HorizontalScaler(mesh, load_balancer, Mock(), config)
        monitor = PerformanceMonitor(mesh, config)
        
        # Start all components
        await optimizer.start()
        await scaler.start()
        await monitor.start()
        
        # Simulate some activity
        component = ModelComponent("test_comp", "dense")
        component.execution_count = 50
        component.average_latency = 100.0
        
        profile = Mock()
        profile.components = {"test_comp": component}
        ahr.model_profiles = {"test_model": profile}
        
        # Let the optimizer run for a short time
        await asyncio.sleep(0.1)
        
        # Stop all components
        await optimizer.stop()
        await scaler.stop()
        await monitor.stop()
        
        # Check that components ran successfully
        assert optimizer.is_optimization_active() == False
        assert scaler.is_scaling_active() == False
        assert monitor.is_monitoring_active() == False
    
    def test_memory_efficiency_improvement(self):
        """Test that memory efficiency is improved"""
        optimizer = MemoryOptimizer(max_memory_mb=1024)
        
        # Simulate memory allocation patterns
        initial_memory = optimizer.current_memory_bytes
        
        # Allocate memory
        optimizer.allocate_memory(512000)
        optimizer.allocate_memory(256000)
        
        # Free some memory
        optimizer.free_memory(128000)
        
        # Check memory efficiency
        stats = optimizer.get_memory_stats()
        assert stats['memory_efficiency'] > 0.0
        assert stats['current_memory'] < (512000 + 256000)
    
    def test_cache_hit_rate_improvement(self):
        """Test that cache hit rate improves with usage"""
        cache = IntelligentCache(max_size_mb=1)
        
        # Initial hit rate should be 0
        assert cache.stats['hit_rate'] == 0.0
        
        # Add and access items
        for i in range(10):
            cache.put(f"key{i}", f"value{i}", 1024)
        
        # Access some items multiple times
        for _ in range(5):
            cache.get("key1")
            cache.get("2")
        
        # Hit rate should improve
        assert cache.stats['hit_rate'] > 0.0
        assert cache.stats['hits'] > 0

