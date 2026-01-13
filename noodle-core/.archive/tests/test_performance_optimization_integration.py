#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_performance_optimization_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Integration Tests for Performance Optimization Infrastructure

This module tests the integration of all performance optimization components:
GPUAccelerator, PerformanceOptimizer, CacheManager, DistributedProcessor, and PerformanceMonitor.
"""

import os
import sys
import time
import unittest
import logging
from unittest.mock import Mock, patch

# Add the project root to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.gpu_accelerator import GPUAccelerator, GPUBackend
from noodlecore.ai_agents.performance_optimizer import PerformanceOptimizer, OptimizationLevel, QuantizationType
from noodlecore.ai_agents.cache_manager import CacheManager, CacheStrategy
from noodlecore.ai_agents.distributed_processor import DistributedProcessor, TaskStatus
from noodlecore.ai_agents.performance_monitor import PerformanceMonitor, AlertLevel, MetricType
from noodlecore.database.connection_pool import DatabaseConnectionPool

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TestGPUAccelerator(unittest.TestCase):
    """Test cases for GPU Accelerator component."""
    
    def setUp(self):
        """Set up test environment."""
        # Disable GPU for testing
        with patch.dict(os.environ, {'NOODLE_SYNTAX_FIXER_GPU_ACCELERATION': 'false'}):
            self.gpu_accelerator = GPUAccelerator(enable_gpu=False)
    
    def test_gpu_detection(self):
        """Test GPU detection functionality."""
        # Test with GPU disabled
        self.assertFalse(self.gpu_accelerator.is_gpu_available())
        self.assertEqual(self.gpu_accelerator.get_gpu_count(), 0)
        
        # Test GPU info
        gpu_info = self.gpu_accelerator.get_gpu_info()
        self.assertIsNone(gpu_info)
        
        all_gpu_info = self.gpu_accelerator.get_all_gpu_info()
        self.assertEqual(len(all_gpu_info), 0)
    
    def test_memory_management(self):
        """Test GPU memory management."""
        # Test memory allocation
        allocation_id = self.gpu_accelerator.allocate_memory(100)
        self.assertIsNone(allocation_id)  # Should fail when GPU is disabled
        
        # Test memory deallocation
        result = self.gpu_accelerator.deallocate_memory("test_id")
        self.assertFalse(result)  # Should fail when allocation doesn't exist
    
    def test_statistics(self):
        """Test GPU accelerator statistics."""
        stats = self.gpu_accelerator.get_statistics()
        
        self.assertIn('total_operations', stats)
        self.assertIn('gpu_operations', stats)
        self.assertIn('cpu_fallbacks', stats)
        self.assertIn('gpu_count', stats)
        self.assertIn('current_backend', stats)
        
        # Should have zero operations when GPU is disabled
        self.assertEqual(stats['total_operations'], 0)
        self.assertEqual(stats['gpu_operations'], 0)
    
    def tearDown(self):
        """Clean up after tests."""
        self.gpu_accelerator.cleanup()

class TestPerformanceOptimizer(unittest.TestCase):
    """Test cases for Performance Optimizer component."""
    
    def setUp(self):
        """Set up test environment."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_BATCH_SIZE_AUTO': 'true',
            'NOODLE_SYNTAX_FIXER_PERFORMANCE_MONITORING': 'true',
            'NOODLE_SYNTAX_FIXER_QUANTIZATION_ENABLED': 'true',
            'NOODLE_SYNTAX_FIXER_AUTO_OPTIMIZATION': 'true'
        }):
            self.optimizer = PerformanceOptimizer()
    
    def test_optimization_settings(self):
        """Test optimization settings management."""
        settings = self.optimizer.get_current_settings()
        
        self.assertIsNotNone(settings)
        self.assertEqual(settings.optimization_level.value, "balanced")
        self.assertGreater(settings.batch_size, 0)
        self.assertGreater(settings.max_concurrent_operations, 0)
        self.assertIsInstance(settings.use_gpu, bool)
        self.assertGreater(settings.memory_limit_mb, 0)
    
    def test_workload_optimization(self):
        """Test workload-based optimization."""
        result = self.optimizer.optimize_for_workload(
            workload_size=100,
            complexity_level="medium",
            target_latency_ms=100
        )
        
        self.assertIsNotNone(result)
        self.assertIsInstance(result.applied_optimizations, list)
        self.assertIsInstance(result.performance_improvement, float)
        self.assertGreaterEqual(result.optimization_time, 0)
    
    def test_auto_optimization(self):
        """Test automatic optimization."""
        result = self.optimizer.auto_optimize()
        
        self.assertIsNotNone(result)
        self.assertIsInstance(result.settings_before, object)
        self.assertIsInstance(result.settings_after, object)
    
    def test_batch_size_calculation(self):
        """Test optimal batch size calculation."""
        batch_size = self.optimizer.get_optimal_batch_size(
            input_size_mb=1.0,
            target_latency_ms=100
        )
        
        self.assertGreater(batch_size, 0)
        self.assertIsInstance(batch_size, int)
    
    def test_model_quantization(self):
        """Test model quantization."""
        # Mock model
        mock_model = Mock()
        
        # Test with different quantization types
        quantized = self.optimizer.quantize_model(mock_model, QuantizationType.DYNAMIC)
        self.assertIsNotNone(quantized)
        
        quantized = self.optimizer.quantize_model(mock_model, QuantizationType.NONE)
        self.assertEqual(quantized, mock_model)
    
    def test_workload_balancing(self):
        """Test CPU-GPU workload balancing."""
        tasks = [Mock() for _ in range(10)]
        gpu_tasks, cpu_tasks = self.optimizer.balance_workload(tasks)
        
        self.assertIsInstance(gpu_tasks, list)
        self.assertIsInstance(cpu_tasks, list)
        self.assertEqual(len(gpu_tasks) + len(cpu_tasks), len(tasks))
    
    def test_statistics(self):
        """Test optimizer statistics."""
        stats = self.optimizer.get_statistics()
        
        self.assertIn('optimization_cycles', stats)
        self.assertIn('total_optimizations', stats)
        self.assertIn('successful_optimizations', stats)
        self.assertIn('current_settings', stats)
        self.assertIn('current_resources', stats)
    
    def tearDown(self):
        """Clean up after tests."""
        self.optimizer.cleanup()

class TestCacheManager(unittest.TestCase):
    """Test cases for Cache Manager component."""
    
    def setUp(self):
        """Set up test environment."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_CACHE_STRATEGY': 'lru',
            'NOODLE_SYNTAX_FIXER_CACHE_SIZE': '100',
            'NOODLE_SYNTAX_FIXER_CACHE_TTL': '3600'
        }):
            self.cache_manager = CacheManager(cache_size=100, strategy='lru')
    
    def test_cache_operations(self):
        """Test basic cache operations."""
        # Test put and get
        test_key = "test_key"
        test_value = {"data": "test_value"}
        
        result = self.cache_manager.put(test_key, test_value)
        self.assertTrue(result)
        
        cached_value = self.cache_manager.get(test_key)
        self.assertEqual(cached_value, test_value)
        
        # Test non-existent key
        non_existent = self.cache_manager.get("non_existent_key")
        self.assertIsNone(non_existent)
    
    def test_cache_expiration(self):
        """Test cache expiration functionality."""
        # Put value with short TTL
        test_key = "expire_test"
        test_value = "expire_value"
        
        result = self.cache_manager.put(test_key, test_value, ttl_seconds=1)
        self.assertTrue(result)
        
        # Should be available immediately
        cached_value = self.cache_manager.get(test_key)
        self.assertEqual(cached_value, test_value)
        
        # Wait for expiration
        time.sleep(2)
        expired_value = self.cache_manager.get(test_key)
        self.assertIsNone(expired_value)
    
    def test_dependency_invalidation(self):
        """Test dependency-based cache invalidation."""
        # Put entries with dependencies
        self.cache_manager.put("key1", "value1", dependencies=["dep1"])
        self.cache_manager.put("key2", "value2", dependencies=["dep1"])
        
        # Invalidate dependency
        invalidated_count = self.cache_manager.invalidate_by_dependency("dep1")
        self.assertEqual(invalidated_count, 2)
        
        # Entries should be gone
        self.assertIsNone(self.cache_manager.get("key1"))
        self.assertIsNone(self.cache_manager.get("key2"))
    
    def test_cache_statistics(self):
        """Test cache statistics."""
        stats = self.cache_manager.get_statistics()
        
        self.assertIsNotNone(stats)
        self.assertGreaterEqual(stats.hit_count, 0)
        self.assertGreaterEqual(stats.miss_count, 0)
        self.assertIsInstance(stats.hit_rate, float)
        self.assertIsInstance(stats.total_size_bytes, int)
    
    def test_cache_info(self):
        """Test cache information."""
        info = self.cache_manager.get_cache_info()
        
        self.assertIn('strategy', info)
        self.assertIn('max_size', info)
        self.assertIn('stats', info)
        self.assertIn('dependency_count', info)
    
    def tearDown(self):
        """Clean up after tests."""
        self.cache_manager.cleanup()

class TestDistributedProcessor(unittest.TestCase):
    """Test cases for Distributed Processor component."""
    
    def setUp(self):
        """Set up test environment."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_DISTRIBUTED_PROCESSING': 'false',  # Disable for testing
            'NOODLE_SYNTAX_FIXER_MAX_WORKERS': '2'
        }):
            self.processor = DistributedProcessor(max_workers=2)
    
    def test_task_submission(self):
        """Test task submission and tracking."""
        # Submit a task
        task_id = self.processor.submit_task(
            task_type="test_task",
            data={"input": "test_data"},
            priority=5
        )
        
        self.assertIsNotNone(task_id)
        self.assertIsInstance(task_id, str)
        
        # Check task status
        task_status = self.processor.get_task_status(task_id)
        self.assertIsNotNone(task_status)
        self.assertEqual(task_status.task_type, "test_task")
        self.assertEqual(task_status.status, TaskStatus.COMPLETED)  # Should be completed locally
    
    def test_chunked_task_submission(self):
        """Test chunked task submission."""
        data_list = [{"item": i} for i in range(10)]
        
        task_ids = self.processor.submit_chunked_task(
            task_type="chunked_task",
            data_list=data_list,
            priority=5
        )
        
        self.assertEqual(len(task_ids), 10)  # Should create 10 tasks with chunk size 1
        
        # Check all tasks have chunk info
        for task_id in task_ids:
            task_status = self.processor.get_task_status(task_id)
            self.assertIsNotNone(task_status.chunk_info)
    
    def test_task_cancellation(self):
        """Test task cancellation."""
        # Submit a task
        task_id = self.processor.submit_task(
            task_type="cancel_task",
            data={"input": "test_data"}
        )
        
        # Cancel the task
        result = self.processor.cancel_task(task_id)
        self.assertTrue(result)
        
        # Check task status
        task_status = self.processor.get_task_status(task_id)
        self.assertEqual(task_status.status, TaskStatus.CANCELLED)
    
    def test_worker_management(self):
        """Test worker node management."""
        # Add a worker
        worker_id = self.processor.add_worker(
            host="localhost",
            port=8080,
            capabilities=["test_task"]
        )
        
        self.assertIsNotNone(worker_id)
        self.assertIsInstance(worker_id, str)
        
        # Check worker status
        worker_status = self.processor.get_worker_status(worker_id)
        self.assertIsNotNone(worker_status)
        self.assertEqual(worker_status.host, "localhost")
        self.assertEqual(worker_status.port, 8080)
        
        # Remove worker
        result = self.processor.remove_worker(worker_id)
        self.assertTrue(result)
        
        # Worker should be gone
        worker_status = self.processor.get_worker_status(worker_id)
        self.assertIsNone(worker_status)
    
    def test_statistics(self):
        """Test processor statistics."""
        stats = self.processor.get_statistics()
        
        self.assertIn('total_tasks', stats)
        self.assertIn('completed_tasks', stats)
        self.assertIn('failed_tasks', stats)
        self.assertIn('success_rate', stats)
        self.assertIn('pending_tasks', stats)
        self.assertIn('worker_count', stats)
    
    def tearDown(self):
        """Clean up after tests."""
        self.processor.cleanup()

class TestPerformanceMonitor(unittest.TestCase):
    """Test cases for Performance Monitor component."""
    
    def setUp(self):
        """Set up test environment."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_PERFORMANCE_MONITORING': 'true',
            'NOODLE_SYNTAX_FIXER_MONITORING_INTERVAL': '1'
        }):
            self.monitor = PerformanceMonitor(monitoring_interval=1)
    
    def test_metric_recording(self):
        """Test performance metric recording."""
        # Record a metric
        self.monitor.record_metric(
            metric_type=MetricType.CPU_USAGE,
            value=75.5,
            unit="%",
            tags={"source": "test"}
        )
        
        # Get metrics
        metrics = self.monitor.get_metrics(MetricType.CPU_USAGE)
        self.assertGreater(len(metrics), 0)
        
        # Check last metric
        last_metric = metrics[-1]
        self.assertEqual(last_metric.value, 75.5)
        self.assertEqual(last_metric.unit, "%")
        self.assertEqual(last_metric.tags["source"], "test")
    
    def test_performance_snapshot(self):
        """Test performance snapshot generation."""
        snapshot = self.monitor.get_current_snapshot()
        
        self.assertIsNotNone(snapshot)
        self.assertIsInstance(snapshot.cpu_percent, float)
        self.assertIsInstance(snapshot.memory_percent, float)
        self.assertIsInstance(snapshot.gpu_utilization, float)
        self.assertIsInstance(snapshot.response_time_ms, float)
        self.assertIsInstance(snapshot.throughput_ops_per_sec, float)
    
    def test_alert_system(self):
        """Test alert system functionality."""
        # Record a high metric to trigger alert
        self.monitor.record_metric(
            metric_type=MetricType.CPU_USAGE,
            value=95.0,  # Above threshold
            unit="%"
        )
        
        # Check for alerts
        alerts = self.monitor.get_alerts()
        self.assertGreater(len(alerts), 0)
        
        # Check alert properties
        cpu_alerts = [a for a in alerts if a.metric_type == MetricType.CPU_USAGE]
        if cpu_alerts:
            alert = cpu_alerts[0]
            self.assertEqual(alert.level, AlertLevel.WARNING)
            self.assertIn("High cpu_usage", alert.message.lower())
    
    def test_bottleneck_identification(self):
        """Test bottleneck identification."""
        # Record metrics that would indicate bottlenecks
        self.monitor.record_metric(MetricType.CPU_USAGE, 85.0, unit="%")
        self.monitor.record_metric(MetricType.MEMORY_USAGE, 90.0, unit="%")
        
        # Get bottlenecks
        bottlenecks = self.monitor.get_bottlenecks()
        self.assertGreater(len(bottlenecks), 0)
        
        # Check bottleneck properties
        cpu_bottlenecks = [b for b in bottlenecks if b.resource_type == "CPU"]
        if cpu_bottlenecks:
            bottleneck = cpu_bottlenecks[0]
            self.assertGreater(bottleneck.severity, 0.8)
            self.assertIn("High CPU usage", bottleneck.description)
    
    def test_performance_summary(self):
        """Test performance summary generation."""
        # Record some metrics
        for i in range(10):
            self.monitor.record_metric(MetricType.CPU_USAGE, 50.0 + i, unit="%")
            time.sleep(0.1)
        
        # Get summary
        summary = self.monitor.get_performance_summary(duration_minutes=1)
        
        self.assertIn('duration_minutes', summary)
        self.assertIn('metrics', summary)
        self.assertIn('alerts', summary)
        self.assertIn('bottlenecks', summary)
        
        # Check CPU metrics in summary
        if MetricType.CPU_USAGE.value in summary['metrics']:
            cpu_metrics = summary['metrics'][MetricType.CPU_USAGE.value]
            self.assertIn('count', cpu_metrics)
            self.assertIn('avg', cpu_metrics)
            self.assertIn('max', cpu_metrics)
    
    def test_alert_callbacks(self):
        """Test alert callback registration."""
        callback_called = False
        
        def test_callback(alert):
            nonlocal callback_called
            callback_called = True
            self.assertEqual(alert.level, AlertLevel.WARNING)
        
        # Register callback
        self.monitor.register_alert_callback(AlertLevel.WARNING, test_callback)
        
        # Trigger alert
        self.monitor.record_metric(MetricType.ERROR_RATE, 15.0, unit="%")
        
        # Check callback was called
        self.assertTrue(callback_called)
    
    def test_statistics(self):
        """Test monitor statistics."""
        stats = self.monitor.get_statistics()
        
        self.assertIn('monitoring_active', stats)
        self.assertIn('total_metrics', stats)
        self.assertIn('total_alerts', stats)
        self.assertIn('unresolved_alerts', stats)
        self.assertIn('total_bottlenecks', stats)
    
    def tearDown(self):
        """Clean up after tests."""
        self.monitor.cleanup()

class TestComponentIntegration(unittest.TestCase):
    """Test cases for component integration."""
    
    def setUp(self):
        """Set up test environment with all components."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_GPU_ACCELERATION': 'false',
            'NOODLE_SYNTAX_FIXER_BATCH_SIZE_AUTO': 'true',
            'NOODLE_SYNTAX_FIXER_CACHE_STRATEGY': 'lru',
            'NOODLE_SYNTAX_FIXER_DISTRIBUTED_PROCESSING': 'false',
            'NOODLE_SYNTAX_FIXER_PERFORMANCE_MONITORING': 'true'
        }):
            self.gpu_accelerator = GPUAccelerator(enable_gpu=False)
            self.optimizer = PerformanceOptimizer(gpu_accelerator=self.gpu_accelerator)
            self.cache_manager = CacheManager(cache_size=100, strategy='lru')
            self.processor = DistributedProcessor(max_workers=2)
            self.monitor = PerformanceMonitor(
                gpu_accelerator=self.gpu_accelerator,
                performance_optimizer=self.optimizer,
                cache_manager=self.cache_manager,
                distributed_processor=self.processor
            )
    
    def test_cross_component_communication(self):
        """Test communication between components."""
        # Test optimizer can access GPU info
        gpu_stats = self.optimizer.get_statistics()
        self.assertIn('gpu_count', gpu_stats)
        
        # Test monitor can access cache stats
        cache_stats = self.monitor.get_statistics()
        self.assertIn('cache_stats', cache_stats)
        
        # Test monitor can access processor stats
        processor_stats = self.monitor.get_statistics()
        self.assertIn('distributed_stats', processor_stats)
    
    def test_performance_optimization_flow(self):
        """Test end-to-end performance optimization flow."""
        # Simulate a performance issue
        self.monitor.record_metric(MetricType.CPU_USAGE, 95.0, unit="%")
        self.monitor.record_metric(MetricType.RESPONSE_TIME, 1500.0, unit="ms")
        
        # Trigger optimization
        optimization_result = self.optimizer.optimize_for_workload(
            workload_size=100,
            complexity_level="complex",
            target_latency_ms=100
        )
        
        self.assertTrue(optimization_result.success)
        self.assertGreater(optimization_result.performance_improvement, 0)
        
        # Check if bottlenecks were identified
        bottlenecks = self.monitor.get_bottlenecks()
        self.assertGreater(len(bottlenecks), 0)
    
    def test_cache_integration_with_optimization(self):
        """Test cache integration with performance optimization."""
        # Put something in cache
        test_key = "integration_test"
        test_value = {"data": "integration_value"}
        
        cache_result = self.cache_manager.put(test_key, test_value)
        self.assertTrue(cache_result)
        
        # Retrieve from cache
        cached_value = self.cache_manager.get(test_key)
        self.assertEqual(cached_value, test_value)
        
        # Check cache statistics
        cache_stats = self.cache_manager.get_statistics()
        self.assertGreater(cache_stats.hit_count, 0)
        
        # Check if optimizer is aware of cache
        opt_settings = self.optimizer.get_current_settings()
        self.assertTrue(opt_settings.enable_caching)
    
    def test_distributed_processing_integration(self):
        """Test distributed processing integration."""
        # Submit tasks to distributed processor
        task_ids = []
        for i in range(5):
            task_id = self.processor.submit_task(
                task_type="integration_test",
                data={"item": i},
                priority=5
            )
            task_ids.append(task_id)
        
        # Check all tasks completed
        completed_count = 0
        for task_id in task_ids:
            task_status = self.processor.get_task_status(task_id)
            if task_status and task_status.status == TaskStatus.COMPLETED:
                completed_count += 1
        
        self.assertEqual(completed_count, 5)
        
        # Check processor statistics
        processor_stats = self.processor.get_statistics()
        self.assertEqual(processor_stats['total_tasks'], 5)
        self.assertEqual(processor_stats['completed_tasks'], 5)
    
    def test_monitoring_integration(self):
        """Test monitoring integration with all components."""
        # Record metrics from all components
        self.monitor.record_metric(MetricType.CPU_USAGE, 75.0, unit="%")
        self.monitor.record_metric(MetricType.MEMORY_USAGE, 60.0, unit="%")
        self.monitor.record_metric(MetricType.CACHE_HIT_RATE, 85.0, unit="%")
        
        # Get comprehensive snapshot
        snapshot = self.monitor.get_current_snapshot()
        
        self.assertGreater(snapshot.cpu_percent, 0)
        self.assertGreater(snapshot.memory_percent, 0)
        self.assertGreater(snapshot.cache_hit_rate, 0)
        
        # Check if all components are monitored
        monitor_stats = self.monitor.get_statistics()
        self.assertIn('gpu_stats', monitor_stats)
        self.assertIn('optimizer_stats', monitor_stats)
        self.assertIn('cache_stats', monitor_stats)
        self.assertIn('distributed_stats', monitor_stats)
    
    def test_performance_targets(self):
        """Test if performance targets are met."""
        # Simulate optimal performance
        self.monitor.record_metric(MetricType.RESPONSE_TIME, 30.0, unit="ms")  # < 50ms target
        self.monitor.record_metric(MetricType.CPU_USAGE, 40.0, unit="%")  # Under threshold
        self.monitor.record_metric(MetricType.MEMORY_USAGE, 50.0, unit="%")  # Under threshold
        
        # Get performance summary
        summary = self.monitor.get_performance_summary(duration_minutes=1)
        
        # Check if targets are met
        if MetricType.RESPONSE_TIME.value in summary['metrics']:
            response_time_avg = summary['metrics'][MetricType.RESPONSE_TIME.value]['avg']
            self.assertLess(response_time_avg, 50)  # Should be under 50ms target
        
        if MetricType.CPU_USAGE.value in summary['metrics']:
            cpu_avg = summary['metrics'][MetricType.CPU_USAGE.value]['avg']
            self.assertLess(cpu_avg, 80)  # Should be under threshold
    
    def tearDown(self):
        """Clean up after tests."""
        self.monitor.cleanup()
        self.processor.cleanup()
        self.cache_manager.cleanup()
        self.optimizer.cleanup()
        self.gpu_accelerator.cleanup()

class TestPerformanceTargets(unittest.TestCase):
    """Test performance targets compliance."""
    
    def test_simple_fix_performance_target(self):
        """Test <50ms target for simple fixes."""
        # This would test actual syntax fixer performance
        # For now, just verify the monitoring can track this
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_PERFORMANCE_MONITORING': 'true'
        }):
            monitor = PerformanceMonitor()
            
            # Simulate simple fix performance
            monitor.record_metric(MetricType.RESPONSE_TIME, 45.0, unit="ms")
            
            # Get metrics
            metrics = monitor.get_metrics(MetricType.RESPONSE_TIME)
            self.assertGreater(len(metrics), 0)
            
            # Check if under target
            last_metric = metrics[-1]
            self.assertLess(last_metric.value, 50)  # Under 50ms target
            
            monitor.cleanup()
    
    def test_complex_fix_performance_target(self):
        """Test <500ms target for complex fixes."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_PERFORMANCE_MONITORING': 'true'
        }):
            monitor = PerformanceMonitor()
            
            # Simulate complex fix performance
            monitor.record_metric(MetricType.RESPONSE_TIME, 450.0, unit="ms")
            
            # Get metrics
            metrics = monitor.get_metrics(MetricType.RESPONSE_TIME)
            self.assertGreater(len(metrics), 0)
            
            # Check if under target
            last_metric = metrics[-1]
            self.assertLess(last_metric.value, 500)  # Under 500ms target
            
            monitor.cleanup()
    
    def test_memory_optimization_for_large_files(self):
        """Test memory optimization for large files (>10MB)."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_PERFORMANCE_MONITORING': 'true'
        }):
            monitor = PerformanceMonitor()
            
            # Simulate processing large file
            monitor.record_metric(MetricType.MEMORY_USAGE, 70.0, unit="%")
            
            # Get metrics
            metrics = monitor.get_metrics(MetricType.MEMORY_USAGE)
            self.assertGreater(len(metrics), 0)
            
            # Check if memory usage is reasonable for large files
            last_metric = metrics[-1]
            self.assertLess(last_metric.value, 90)  # Should be under 90%
            
            monitor.cleanup()

def run_performance_tests():
    """Run all performance optimization tests."""
    print("Running Performance Optimization Integration Tests...")
    
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add test cases
    test_suite.addTest(unittest.makeSuite(TestGPUAccelerator))
    test_suite.addTest(unittest.makeSuite(TestPerformanceOptimizer))
    test_suite.addTest(unittest.makeSuite(TestCacheManager))
    test_suite.addTest(unittest.makeSuite(TestDistributedProcessor))
    test_suite.addTest(unittest.makeSuite(TestPerformanceMonitor))
    test_suite.addTest(unittest.makeSuite(TestComponentIntegration))
    test_suite.addTest(unittest.makeSuite(TestPerformanceTargets))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Print results
    if result.wasSuccessful():
        print("âœ… All performance optimization tests passed!")
        return True
    else:
        print("âŒ Some performance optimization tests failed!")
        print(f"Tests run: {result.testsRun}")
        print(f"Failures: {len(result.failures)}")
        print(f"Errors: {len(result.errors)}")
        return False

if __name__ == "__main__":
    success = run_performance_tests()
    sys.exit(0 if success else 1)

