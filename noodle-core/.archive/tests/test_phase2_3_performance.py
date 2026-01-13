#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_3_performance.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Performance Optimization Tests for Phase 2.3

Comprehensive testing of performance optimization components including:
- GPU acceleration and performance optimization testing
- Cache manager and distributed processor testing
- Performance monitor and optimizer testing
- Resource usage and memory management testing
- Scalability and load testing
"""

import os
import sys
import unittest
import tempfile
import shutil
import time
import threading
import multiprocessing
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.gpu_accelerator import GPUAccelerator
from noodlecore.ai_agents.performance_optimizer import PerformanceOptimizer
from noodlecore.ai_agents.cache_manager import CacheManager
from noodlecore.ai_agents.distributed_processor import DistributedProcessor
from noodlecore.ai_agents.performance_monitor import PerformanceMonitor

class MockGPUAccelerator(GPUAccelerator):
    """Mock GPU accelerator for testing."""
    
    def __init__(self):
        self.is_available = True
        self.device_count = 2
        self.memory_total = 8192  # MB
        self.memory_used = 0
        self.utilization = 0.0
        self.temperature = 65.0
        self.processing_time = 0.01  # 10ms
        
    def is_gpu_available(self):
        return self.is_available
    
    def get_device_count(self):
        return self.device_count
    
    def get_memory_info(self):
        return {
            'total': self.memory_total,
            'used': self.memory_used,
            'free': self.memory_total - self.memory_used
        }
    
    def get_utilization(self):
        return self.utilization
    
    def get_temperature(self):
        return self.temperature
    
    def accelerate_matrix_operations(self, matrix_a, matrix_b):
        # Simulate GPU acceleration
        self.utilization = min(100.0, self.utilization + 10.0)
        self.memory_used = min(self.memory_total, self.memory_used + 100)
        
        time.sleep(self.processing_time)
        
        # Simple matrix multiplication result
        result = [[sum(a * b for a, b in zip(row_a, col_b)) 
                  for col_b in zip(*matrix_b)] 
                  for row_a in matrix_a]
        
        self.utilization = max(0.0, self.utilization - 5.0)
        return result
    
    def cleanup(self):
        self.utilization = 0.0
        self.memory_used = 0

class TestGPUAcceleration(unittest.TestCase):
    """Test GPU Acceleration functionality."""
    
    def setUp(self):
        self.gpu_accelerator = MockGPUAccelerator()
    
    def test_gpu_availability_detection(self):
        """Test GPU availability detection."""
        self.assertTrue(self.gpu_accelerator.is_gpu_available())
        self.assertGreater(self.gpu_accelerator.get_device_count(), 0)
    
    def test_memory_info(self):
        """Test GPU memory information."""
        memory_info = self.gpu_accelerator.get_memory_info()
        
        self.assertIn('total', memory_info)
        self.assertIn('used', memory_info)
        self.assertIn('free', memory_info)
        
        self.assertEqual(memory_info['total'], 8192)
        self.assertGreaterEqual(memory_info['total'], memory_info['used'])
        self.assertEqual(memory_info['free'], memory_info['total'] - memory_info['used'])
    
    def test_utilization_monitoring(self):
        """Test GPU utilization monitoring."""
        initial_utilization = self.gpu_accelerator.get_utilization()
        
        # Perform some operations
        matrix_a = [[1, 2], [3, 4]]
        matrix_b = [[5, 6], [7, 8]]
        
        self.gpu_accelerator.accelerate_matrix_operations(matrix_a, matrix_b)
        
        # Utilization should increase during operation
        current_utilization = self.gpu_accelerator.get_utilization()
        self.assertGreater(current_utilization, initial_utilization)
    
    def test_temperature_monitoring(self):
        """Test GPU temperature monitoring."""
        temperature = self.gpu_accelerator.get_temperature()
        
        self.assertIsInstance(temperature, float)
        self.assertGreater(temperature, 0)
        self.assertLess(temperature, 150)  # Reasonable temperature range
    
    def test_matrix_operations(self):
        """Test accelerated matrix operations."""
        matrix_a = [[1, 2, 3], [4, 5, 6]]
        matrix_b = [[7, 8], [9, 10], [11, 12]]
        
        start_time = time.time()
        result = self.gpu_accelerator.accelerate_matrix_operations(matrix_a, matrix_b)
        processing_time = time.time() - start_time
        
        # Check result
        expected = [[58, 64], [139, 154]]
        self.assertEqual(result, expected)
        
        # Check processing time
        self.assertLess(processing_time, 0.1)  # Should be fast
    
    def test_performance_comparison(self):
        """Test performance comparison between CPU and GPU."""
        # Create larger matrices for more noticeable difference
        size = 100
        matrix_a = [[i + j for j in range(size)] for i in range(size)]
        matrix_b = [[i * j for j in range(size)] for i in range(size)]
        
        # GPU processing
        start_time = time.time()
        gpu_result = self.gpu_accelerator.accelerate_matrix_operations(matrix_a, matrix_b)
        gpu_time = time.time() - start_time
        
        # Simple CPU processing for comparison
        start_time = time.time()
        cpu_result = [[sum(a * b for a, b in zip(row_a, col_b)) 
                     for col_b in zip(*matrix_b)] 
                     for row_a in matrix_a]
        cpu_time = time.time() - start_time
        
        # Results should be the same
        self.assertEqual(gpu_result, cpu_result)
        
        # GPU should be faster (in mock, we simulate this)
        self.assertLess(gpu_time, cpu_time)
    
    def test_resource_cleanup(self):
        """Test resource cleanup."""
        # Use some resources
        matrix_a = [[1, 2], [3, 4]]
        matrix_b = [[5, 6], [7, 8]]
        self.gpu_accelerator.accelerate_matrix_operations(matrix_a, matrix_b)
        
        # Check that resources are used
        self.assertGreater(self.gpu_accelerator.get_utilization(), 0)
        self.assertGreater(self.gpu_accelerator.get_memory_info()['used'], 0)
        
        # Cleanup
        self.gpu_accelerator.cleanup()
        
        # Resources should be released
        self.assertEqual(self.gpu_accelerator.get_utilization(), 0)
        self.assertEqual(self.gpu_accelerator.get_memory_info()['used'], 0)

class TestPerformanceOptimizer(unittest.TestCase):
    """Test Performance Optimizer functionality."""
    
    def setUp(self):
        self.optimizer = PerformanceOptimizer()
    
    def test_batch_size_optimization(self):
        """Test batch size optimization."""
        # Test with small input
        optimal_size = self.optimizer.get_optimal_batch_size(
            input_size_mb=0.1,  # 100KB
            target_latency_ms=50
        )
        self.assertGreater(optimal_size, 0)
        self.assertLessEqual(optimal_size, 100)  # Reasonable upper bound
        
        # Test with large input
        optimal_size = self.optimizer.get_optimal_batch_size(
            input_size_mb=10.0,  # 10MB
            target_latency_ms=500
        )
        self.assertGreater(optimal_size, 0)
        # Should be smaller for larger inputs to meet latency target
        self.assertLess(optimal_size, 50)
    
    def test_memory_optimization(self):
        """Test memory optimization recommendations."""
        current_usage = {
            'allocated_mb': 512,
            'peak_mb': 768,
            'fragmentation_ratio': 0.3
        }
        
        recommendations = self.optimizer.optimize_memory_usage(current_usage)
        
        self.assertIsInstance(recommendations, list)
        self.assertGreater(len(recommendations), 0)
        
        # Check for common optimization types
        rec_types = [rec.get('type') for rec in recommendations]
        self.assertIn('reduce_fragmentation', rec_types)
        self.assertIn('lower_peak_usage', rec_types)
    
    def test_cpu_optimization(self):
        """Test CPU optimization recommendations."""
        current_usage = {
            'cpu_percent': 85,
            'thread_count': 8,
            'active_threads': 16,
            'context_switches_per_sec': 1000
        }
        
        recommendations = self.optimizer.optimize_cpu_usage(current_usage)
        
        self.assertIsInstance(recommendations, list)
        self.assertGreater(len(recommendations), 0)
        
        # Check for common optimization types
        rec_types = [rec.get('type') for rec in recommendations]
        self.assertIn('reduce_thread_count', rec_types)
        self.assertIn('optimize_thread_affinity', rec_types)
    
    def test_io_optimization(self):
        """Test I/O optimization recommendations."""
        current_usage = {
            'read_ops_per_sec': 1000,
            'write_ops_per_sec': 500,
            'avg_read_latency_ms': 10,
            'avg_write_latency_ms': 20,
            'cache_hit_rate': 0.7
        }
        
        recommendations = self.optimizer.optimize_io_usage(current_usage)
        
        self.assertIsInstance(recommendations, list)
        self.assertGreater(len(recommendations), 0)
        
        # Check for common optimization types
        rec_types = [rec.get('type') for rec in recommendations]
        self.assertIn('increase_cache_size', rec_types)
        self.assertIn('optimize_io_pattern', rec_types)
    
    def test_algorithm_selection(self):
        """Test optimal algorithm selection."""
        problem_size = 1000
        available_algorithms = ['O(n^2)', 'O(n log n)', 'O(n)']
        constraints = {
            'max_memory_mb': 100,
            'max_time_ms': 100
        }
        
        optimal_algorithm = self.optimizer.select_optimal_algorithm(
            problem_size, available_algorithms, constraints
        )
        
        self.assertIn(optimal_algorithm, available_algorithms)
        # For large problems with time constraints, should prefer faster algorithms
        self.assertIn(optimal_algorithm, ['O(n log n)', 'O(n)'])
    
    def test_performance_profiling(self):
        """Test performance profiling capabilities."""
        def sample_function():
            time.sleep(0.1)  # Simulate work
            return sum(range(1000))
        
        # Profile the function
        profile = self.optimizer.profile_function(sample_function)
        
        self.assertIn('execution_time_ms', profile)
        self.assertIn('memory_peak_mb', profile)
        self.assertIn('cpu_time_ms', profile)
        self.assertIn('call_count', profile)
        
        self.assertGreater(profile['execution_time_ms'], 90)  # ~100ms
        self.assertGreater(profile['memory_peak_mb'], 0)
    
    def test_optimization_target_validation(self):
        """Test optimization target validation."""
        targets = {
            'max_latency_ms': 50,
            'max_memory_mb': 512,
            'min_throughput_ops_per_sec': 1000,
            'max_cpu_percent': 80
        }
        
        current_metrics = {
            'avg_latency_ms': 75,  # Exceeds target
            'memory_mb': 256,      # Within target
            'throughput_ops_per_sec': 800,  # Below target
            'cpu_percent': 60       # Within target
        }
        
        validation = self.optimizer.validate_targets(targets, current_metrics)
        
        self.assertFalse(validation['all_targets_met'])
        self.assertIn('latency', validation['failed_targets'])
        self.assertIn('throughput', validation['failed_targets'])
        self.assertNotIn('memory', validation['failed_targets'])
        self.assertNotIn('cpu', validation['failed_targets'])

class TestCacheManager(unittest.TestCase):
    """Test Cache Manager functionality."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.cache_manager = CacheManager(
            cache_dir=self.temp_dir,
            max_size_mb=100,
            max_items=1000
        )
    
    def tearDown(self):
        self.cache_manager.cleanup()
        shutil.rmtree(self.temp_dir)
    
    def test_cache_storage_and_retrieval(self):
        """Test cache storage and retrieval."""
        key = "test_key"
        value = {"data": "test_value", "timestamp": time.time()}
        dependencies = ["dep1", "dep2"]
        
        # Store in cache
        success = self.cache_manager.put(key, value, ttl_seconds=3600, dependencies=dependencies)
        self.assertTrue(success)
        
        # Retrieve from cache
        retrieved_value = self.cache_manager.get(key)
        self.assertIsNotNone(retrieved_value)
        self.assertEqual(retrieved_value["data"], "test_value")
    
    def test_cache_ttl_expiration(self):
        """Test cache TTL expiration."""
        key = "ttl_test_key"
        value = {"data": "expires_soon"}
        
        # Store with short TTL
        success = self.cache_manager.put(key, value, ttl_seconds=1)
        self.assertTrue(success)
        
        # Should be available immediately
        retrieved_value = self.cache_manager.get(key)
        self.assertIsNotNone(retrieved_value)
        
        # Wait for expiration
        time.sleep(1.5)
        
        # Should be expired
        retrieved_value = self.cache_manager.get(key)
        self.assertIsNone(retrieved_value)
    
    def test_cache_dependency_invalidation(self):
        """Test cache dependency invalidation."""
        key1 = "dependent_key1"
        key2 = "dependent_key2"
        dependency = "shared_dep"
        
        # Store items with dependency
        self.cache_manager.put(key1, {"data": "value1"}, dependencies=[dependency])
        self.cache_manager.put(key2, {"data": "value2"}, dependencies=[dependency])
        
        # Both should be available
        self.assertIsNotNone(self.cache_manager.get(key1))
        self.assertIsNotNone(self.cache_manager.get(key2))
        
        # Invalidate dependency
        self.cache_manager.invalidate_dependency(dependency)
        
        # Both should be invalidated
        self.assertIsNone(self.cache_manager.get(key1))
        self.assertIsNone(self.cache_manager.get(key2))
    
    def test_cache_size_management(self):
        """Test cache size management."""
        # Fill cache beyond limit
        for i in range(1500):  # More than max_items (1000)
            key = f"size_test_key_{i}"
            value = {"data": f"value_{i}", "size": 100}  # Simulate size
            
            success = self.cache_manager.put(key, value)
            
            # Should succeed until cache is full
            if i < 1000:
                self.assertTrue(success)
            else:
                # May start failing or evicting old items
                pass
        
        # Check cache statistics
        stats = self.cache_manager.get_statistics()
        self.assertLessEqual(stats['item_count'], 1000)
        self.assertLessEqual(stats['size_mb'], 100)
    
    def test_cache_performance(self):
        """Test cache performance."""
        # Pre-populate cache
        for i in range(1000):
            key = f"perf_key_{i}"
            value = {"data": f"value_{i}", "large_data": "x" * 1000}
            self.cache_manager.put(key, value)
        
        # Test retrieval performance
        start_time = time.time()
        hits = 0
        for i in range(1000):
            key = f"perf_key_{i}"
            if self.cache_manager.get(key):
                hits += 1
        
        total_time = time.time() - start_time
        avg_time = total_time / 1000
        
        # Performance targets
        self.assertLess(avg_time, 0.001)  # <1ms per retrieval
        self.assertEqual(hits, 1000)  # All should be hits
        
        # Check statistics
        stats = self.cache_manager.get_statistics()
        self.assertGreater(stats['hit_rate'], 0.99)
        self.assertLess(stats['avg_retrieval_time_ms'], 1.0)
    
    def test_cache_persistence(self):
        """Test cache persistence across restarts."""
        key = "persistent_key"
        value = {"data": "persistent_value"}
        
        # Store in cache
        self.cache_manager.put(key, value)
        
        # Create new cache manager (simulating restart)
        new_cache_manager = CacheManager(
            cache_dir=self.temp_dir,
            max_size_mb=100,
            max_items=1000
        )
        
        # Should retrieve persisted value
        retrieved_value = new_cache_manager.get(key)
        self.assertIsNotNone(retrieved_value)
        self.assertEqual(retrieved_value["data"], "persistent_value")
        
        new_cache_manager.cleanup()
    
    def test_cache_statistics(self):
        """Test cache statistics tracking."""
        # Perform various operations
        self.cache_manager.put("key1", {"data": "value1"})
        self.cache_manager.put("key2", {"data": "value2"})
        self.cache_manager.get("key1")  # Hit
        self.cache_manager.get("key3")  # Miss
        
        stats = self.cache_manager.get_statistics()
        
        self.assertEqual(stats['item_count'], 2)
        self.assertEqual(stats['hits'], 1)
        self.assertEqual(stats['misses'], 1)
        self.assertGreater(stats['hit_rate'], 0)
        self.assertGreater(stats['size_mb'], 0)

class TestDistributedProcessor(unittest.TestCase):
    """Test Distributed Processor functionality."""
    
    def setUp(self):
        self.processor = DistributedProcessor(
            max_workers=4,
            chunk_size=10
        )
    
    def tearDown(self):
        self.processor.cleanup()
    
    def test_task_distribution(self):
        """Test task distribution across workers."""
        tasks = [
            {"id": i, "data": f"task_{i}", "workload": i % 3}
            for i in range(20)
        ]
        
        def process_task(task):
            # Simulate processing time based on workload
            time.sleep(0.01 * (task['workload'] + 1))
            return {"id": task['id'], "result": f"processed_{task['data']}"}
        
        # Process tasks
        start_time = time.time()
        results = self.processor.process_tasks(tasks, process_task)
        processing_time = time.time() - start_time
        
        # Check results
        self.assertEqual(len(results), 20)
        
        for result in results:
            self.assertIn('id', result)
            self.assertIn('result', result)
            self.assertTrue(result['result'].startswith('processed_'))
        
        # Should be faster than sequential processing
        self.assertLess(processing_time, 0.2)  # Much less than 20 * 0.03s
    
    def test_load_balancing(self):
        """Test load balancing across workers."""
        tasks = [
            {"id": i, "workload": i % 5}  # Varied workloads
            for i in range(50)
        ]
        
        def process_task(task):
            time.sleep(0.01 * (task['workload'] + 1))
            return {"id": task['id'], "worker": threading.current_thread().name}
        
        results = self.processor.process_tasks(tasks, process_task)
        
        # Check load distribution
        worker_counts = {}
        for result in results:
            worker = result['worker']
            worker_counts[worker] = worker_counts.get(worker, 0) + 1
        
        # Should distribute across workers
        self.assertGreater(len(worker_counts), 1)
        
        # Load should be reasonably balanced
        max_tasks = max(worker_counts.values())
        min_tasks = min(worker_counts.values())
        self.assertLess(max_tasks - min_tasks, 5)  # Reasonable imbalance
    
    def test_fault_tolerance(self):
        """Test fault tolerance with failing tasks."""
        tasks = [
            {"id": i, "should_fail": i % 10 == 0}  # Every 10th task fails
            for i in range(30)
        ]
        
        def process_task(task):
            if task['should_fail']:
                raise Exception(f"Task {task['id']} failed")
            time.sleep(0.01)
            return {"id": task['id'], "status": "success"}
        
        # Process with error handling
        results = self.processor.process_tasks(tasks, process_task, continue_on_error=True)
        
        # Should have both successes and failures
        self.assertEqual(len(results), 30)
        
        successes = [r for r in results if r.get('status') == 'success']
        failures = [r for r in results if 'error' in r]
        
        self.assertEqual(len(successes), 27)  # 30 - 3 failures
        self.assertEqual(len(failures), 3)
    
    def test_chunk_processing(self):
        """Test chunk-based processing."""
        # Large task list
        tasks = [{"id": i, "data": f"data_{i}"} for i in range(100)]
        
        def process_chunk(chunk):
            # Simulate chunk processing
            time.sleep(0.05)
            return [{"id": task['id'], "chunk_id": id(chunk)} for task in chunk]
        
        # Process with chunking
        start_time = time.time()
        results = self.processor.process_chunks(tasks, process_chunk, chunk_size=10)
        processing_time = time.time() - start_time
        
        # Should process all tasks
        self.assertEqual(len(results), 100)
        
        # Should use multiple chunks
        chunk_ids = set(r['chunk_id'] for r in results)
        self.assertGreater(len(chunk_ids), 5)  # At least 5 chunks for 100 items
        
        # Should be faster than sequential
        self.assertLess(processing_time, 0.5)  # Much less than 10 * 0.05s
    
    def test_resource_monitoring(self):
        """Test resource monitoring during processing."""
        tasks = [
            {"id": i, "workload": 5}  # Consistent workload
            for i in range(20)
        ]
        
        def process_task(task):
            time.sleep(0.02)
            return {"id": task['id']}
        
        # Process with monitoring
        results = self.processor.process_tasks_with_monitoring(tasks, process_task)
        
        # Should include monitoring data
        self.assertIn('resource_usage', results)
        
        resource_usage = results['resource_usage']
        self.assertIn('peak_memory_mb', resource_usage)
        self.assertIn('avg_cpu_percent', resource_usage)
        self.assertIn('processing_time_ms', resource_usage)
        
        self.assertGreater(resource_usage['processing_time_ms'], 0)
        self.assertGreater(resource_usage['peak_memory_mb'], 0)
    
    def test_statistics_tracking(self):
        """Test statistics tracking."""
        tasks = [{"id": i, "data": f"data_{i}"} for i in range(50)]
        
        def process_task(task):
            time.sleep(0.001)
            return {"id": task['id']}
        
        # Process tasks
        self.processor.process_tasks(tasks, process_task)
        
        # Check statistics
        stats = self.processor.get_statistics()
        
        self.assertEqual(stats['total_tasks'], 50)
        self.assertEqual(stats['completed_tasks'], 50)
        self.assertGreater(stats['avg_processing_time_ms'], 0)
        self.assertGreater(stats['throughput_tasks_per_sec'], 0)
        self.assertGreater(stats['worker_utilization'], 0)

class TestPerformanceMonitor(unittest.TestCase):
    """Test Performance Monitor functionality."""
    
    def setUp(self):
        self.monitor = PerformanceMonitor(
            sampling_interval_ms=100,
            history_size=1000
        )
    
    def tearDown(self):
        self.monitor.cleanup()
    
    def test_cpu_monitoring(self):
        """Test CPU monitoring."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Generate some CPU load
        def cpu_load():
            end_time = time.time() + 0.5
            while time.time() < end_time:
                sum(range(1000))  # CPU work
        
        thread = threading.Thread(target=cpu_load)
        thread.start()
        thread.join()
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Check CPU metrics
        snapshot = self.monitor.get_current_snapshot()
        self.assertIn('cpu_percent', snapshot)
        self.assertGreater(snapshot['cpu_percent'], 0)
        self.assertLessEqual(snapshot['cpu_percent'], 100)
    
    def test_memory_monitoring(self):
        """Test memory monitoring."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Allocate some memory
        large_data = ['x' * 1000000 for _ in range(100)]
        
        time.sleep(0.2)  # Let monitor capture usage
        
        # Deallocate
        del large_data
        
        time.sleep(0.2)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Check memory metrics
        snapshot = self.monitor.get_current_snapshot()
        self.assertIn('memory_percent', snapshot)
        self.assertIn('memory_mb', snapshot)
        self.assertGreater(snapshot['peak_memory_mb'], snapshot['memory_mb'])
    
    def test_gpu_monitoring(self):
        """Test GPU monitoring."""
        # Mock GPU accelerator for testing
        gpu_accelerator = MockGPUAccelerator()
        self.monitor.set_gpu_accelerator(gpu_accelerator)
        
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Generate some GPU load
        matrix_a = [[1, 2], [3, 4]]
        matrix_b = [[5, 6], [7, 8]]
        gpu_accelerator.accelerate_matrix_operations(matrix_a, matrix_b)
        
        time.sleep(0.2)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Check GPU metrics
        snapshot = self.monitor.get_current_snapshot()
        self.assertIn('gpu_utilization', snapshot)
        self.assertIn('gpu_memory_mb', snapshot)
        self.assertIn('gpu_temperature', snapshot)
        
        self.assertGreater(snapshot['gpu_utilization'], 0)
        self.assertGreater(snapshot['gpu_memory_mb'], 0)
    
    def test_performance_trends(self):
        """Test performance trend analysis."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Generate varying load
        for i in range(10):
            # High load period
            if i % 3 == 0:
                time.sleep(0.1)
                sum(range(10000))
            # Low load period
            else:
                time.sleep(0.1)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Analyze trends
        trends = self.monitor.analyze_trends(time_window_minutes=1)
        
        self.assertIn('cpu_trend', trends)
        self.assertIn('memory_trend', trends)
        self.assertIn('performance_score', trends)
        
        # Should detect patterns
        self.assertIn(trends['cpu_trend'], ['increasing', 'decreasing', 'stable'])
        self.assertIn(trends['memory_trend'], ['increasing', 'decreasing', 'stable'])
    
    def test_alerting(self):
        """Test performance alerting."""
        # Configure alert thresholds
        thresholds = {
            'cpu_percent': 80,
            'memory_percent': 85,
            'response_time_ms': 1000
        }
        self.monitor.set_alert_thresholds(thresholds)
        
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Trigger alerts
        def high_load():
            end_time = time.time() + 0.3
            while time.time() < end_time:
                sum(range(10000))  # High CPU load
        
        thread = threading.Thread(target=high_load)
        thread.start()
        thread.join()
        
        time.sleep(0.2)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Check for alerts
        alerts = self.monitor.get_alerts()
        
        # Should have triggered some alerts
        self.assertGreater(len(alerts), 0)
        
        # Check alert structure
        for alert in alerts:
            self.assertIn('metric', alert)
            self.assertIn('threshold', alert)
            self.assertIn('actual_value', alert)
            self.assertIn('timestamp', alert)
            self.assertIn('severity', alert)
    
    def test_performance_recommendations(self):
        """Test performance recommendations."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Generate various performance scenarios
        # High CPU usage
        for _ in range(5):
            sum(range(10000))
            time.sleep(0.1)
        
        time.sleep(0.5)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Get recommendations
        recommendations = self.monitor.get_recommendations()
        
        self.assertIsInstance(recommendations, list)
        
        if recommendations:
            # Check recommendation structure
            for rec in recommendations:
                self.assertIn('type', rec)
                self.assertIn('description', rec)
                self.assertIn('priority', rec)
                self.assertIn('estimated_impact', rec)
    
    def test_benchmark_comparison(self):
        """Test benchmark comparison."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Perform standard workload
        for i in range(20):
            sum(range(1000))
            time.sleep(0.01)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Set benchmark
        benchmark = {
            'avg_response_time_ms': 50,
            'throughput_ops_per_sec': 100,
            'cpu_efficiency': 0.8,
            'memory_efficiency': 0.9
        }
        
        # Compare with benchmark
        comparison = self.monitor.compare_with_benchmark(benchmark)
        
        self.assertIn('performance_score', comparison)
        self.assertIn('deviations', comparison)
        self.assertIn('overall_assessment', comparison)
        
        # Should calculate meaningful score
        self.assertGreaterEqual(comparison['performance_score'], 0)
        self.assertLessEqual(comparison['performance_score'], 100)
    
    def test_statistics_and_reporting(self):
        """Test statistics collection and reporting."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Generate mixed workload
        for i in range(30):
            if i % 3 == 0:
                # High load
                sum(range(5000))
            time.sleep(0.05)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Get comprehensive statistics
        stats = self.monitor.get_comprehensive_statistics()
        
        self.assertIn('performance_summary', stats)
        self.assertIn('resource_utilization', stats)
        self.assertIn('trend_analysis', stats)
        self.assertIn('alerts_summary', stats)
        
        # Check performance summary
        perf_summary = stats['performance_summary']
        self.assertIn('avg_response_time_ms', perf_summary)
        self.assertIn('peak_response_time_ms', perf_summary)
        self.assertIn('throughput_ops_per_sec', perf_summary)
        
        # Check resource utilization
        resource_util = stats['resource_utilization']
        self.assertIn('avg_cpu_percent', resource_util)
        self.assertIn('peak_memory_mb', resource_util)
        self.assertIn('avg_gpu_utilization', resource_util)

class TestPerformanceIntegration(unittest.TestCase):
    """Test integration of performance components."""
    
    def setUp(self):
        self.gpu_accelerator = MockGPUAccelerator()
        self.optimizer = PerformanceOptimizer()
        self.cache_manager = CacheManager(max_size_mb=100, max_items=1000)
        self.distributed_processor = DistributedProcessor(max_workers=4)
        self.monitor = PerformanceMonitor()
    
    def tearDown(self):
        self.gpu_accelerator.cleanup()
        self.cache_manager.cleanup()
        self.distributed_processor.cleanup()
        self.monitor.cleanup()
    
    def test_integrated_performance_optimization(self):
        """Test integrated performance optimization."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Simulate workload
        tasks = [
            {"id": i, "matrix_size": 50 + i * 10}
            for i in range(10)
        ]
        
        def process_task(task):
            matrix_size = task['matrix_size']
            
            # Create matrices
            matrix_a = [[j for j in range(matrix_size)] for _ in range(matrix_size)]
            matrix_b = [[j for j in range(matrix_size)] for _ in range(matrix_size)]
            
            # Use GPU acceleration if available
            if self.gpu_accelerator.is_gpu_available():
                result = self.gpu_accelerator.accelerate_matrix_operations(matrix_a, matrix_b)
            else:
                # Fallback to CPU
                result = [[sum(a * b for a, b in zip(row_a, col_b)) 
                          for col_b in zip(*matrix_b)] 
                          for row_a in matrix_a]
            
            return {"id": task['id'], "result_size": len(result)}
        
        # Process tasks
        results = self.distributed_processor.process_tasks(tasks, process_task)
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Verify results
        self.assertEqual(len(results), 10)
        for result in results:
            self.assertIn('id', result)
            self.assertIn('result_size', result)
        
        # Check performance metrics
        snapshot = self.monitor.get_current_snapshot()
        self.assertGreater(snapshot['throughput_ops_per_sec'], 0)
        self.assertGreater(snapshot['avg_response_time_ms'], 0)
    
    def test_adaptive_optimization(self):
        """Test adaptive performance optimization."""
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Initial workload - light
        light_tasks = [{"id": i, "workload": 1} for i in range(5)]
        
        def process_task(task):
            time.sleep(0.01 * task['workload'])
            return {"id": task['id']}
        
        self.distributed_processor.process_tasks(light_tasks, process_task)
        
        # Get optimization recommendations
        snapshot = self.monitor.get_current_snapshot()
        recommendations = self.optimizer.optimize_cpu_usage({
            'cpu_percent': snapshot['cpu_percent'],
            'thread_count': 4,
            'active_threads': 8
        })
        
        # Heavy workload - test adaptation
        heavy_tasks = [{"id": i, "workload": 10} for i in range(5)]
        self.distributed_processor.process_tasks(heavy_tasks, process_task)
        
        # Get new recommendations
        heavy_snapshot = self.monitor.get_current_snapshot()
        heavy_recommendations = self.optimizer.optimize_cpu_usage({
            'cpu_percent': heavy_snapshot['cpu_percent'],
            'thread_count': 4,
            'active_threads': 8
        })
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Should have different recommendations for different loads
        self.assertNotEqual(
            snapshot['cpu_percent'],
            heavy_snapshot['cpu_percent']
        )
        
        # Recommendations should adapt to load
        self.assertIsInstance(recommendations, list)
        self.assertIsInstance(heavy_recommendations, list)
    
    def test_cache_integration_optimization(self):
        """Test cache integration with optimization."""
        # Test cache performance
        test_data = [
            {"key": f"test_key_{i}", "value": f"test_value_{i}"}
            for i in range(100)
        ]
        
        # Store in cache
        for data in test_data:
            self.cache_manager.put(data["key"], data["value"])
        
        # Test retrieval performance
        start_time = time.time()
        cache_hits = 0
        for data in test_data:
            if self.cache_manager.get(data["key"]):
                cache_hits += 1
        cache_time = time.time() - start_time
        
        # Get optimization recommendations
        cache_stats = self.cache_manager.get_statistics()
        io_recommendations = self.optimizer.optimize_io_usage({
            'cache_hit_rate': cache_stats['hit_rate'],
            'avg_read_latency_ms': cache_stats['avg_retrieval_time_ms'],
            'read_ops_per_sec': cache_hits / cache_time if cache_time > 0 else 0
        })
        
        # Should have cache-related recommendations
        self.assertIsInstance(io_recommendations, list)
        
        if cache_stats['hit_rate'] < 0.9:
            # Should recommend cache improvements
            rec_types = [rec.get('type') for rec in io_recommendations]
            self.assertIn('increase_cache_size', rec_types)
    
    def test_scalability_validation(self):
        """Test scalability validation."""
        # Test with increasing workload sizes
        workload_sizes = [10, 50, 100, 200]
        performance_results = []
        
        for size in workload_sizes:
            # Start monitoring
            self.monitor.start_monitoring()
            
            # Generate workload
            tasks = [{"id": i, "workload": i % 5} for i in range(size)]
            
            def process_task(task):
                time.sleep(0.001 * task['workload'])
                return {"id": task['id']}
            
            # Process tasks
            start_time = time.time()
            results = self.distributed_processor.process_tasks(tasks, process_task)
            processing_time = time.time() - start_time
            
            # Stop monitoring
            self.monitor.stop_monitoring()
            
            # Record performance
            snapshot = self.monitor.get_current_snapshot()
            performance_results.append({
                'workload_size': size,
                'processing_time': processing_time,
                'throughput': len(results) / processing_time,
                'avg_response_time': snapshot['avg_response_time_ms'],
                'cpu_usage': snapshot['cpu_percent']
            })
        
        # Analyze scalability
        # Performance should scale reasonably
        for i in range(1, len(performance_results)):
            prev = performance_results[i-1]
            curr = performance_results[i]
            
            # Throughput should increase with workload size
            self.assertGreaterEqual(curr['throughput'], prev['throughput'] * 0.8)
            
            # Response time should not increase disproportionately
            response_time_ratio = curr['avg_response_time'] / prev['avg_response_time']
            workload_ratio = curr['workload_size'] / prev['workload_size']
            self.assertLess(response_time_ratio, workload_ratio * 1.5)
    
    def test_performance_targets_validation(self):
        """Test performance targets validation."""
        # Define performance targets
        targets = {
            'simple_fix_target_ms': 50,
            'complex_fix_target_ms': 500,
            'large_file_memory_mb': 100,
            'min_throughput_ops_per_sec': 100,
            'max_cpu_percent': 80
        }
        
        # Start monitoring
        self.monitor.start_monitoring()
        
        # Simple fix test
        simple_start = time.time()
        simple_result = sum(range(100))  # Simple operation
        simple_time = (time.time() - simple_start) * 1000  # Convert to ms
        
        # Complex fix test
        complex_start = time.time()
        complex_result = [sum(range(100)) for _ in range(10)]  # Complex operation
        complex_time = (time.time() - complex_start) * 1000  # Convert to ms
        
        # Large file test (simulate)
        large_data = ['x' * 1000 for _ in range(10000)]  # ~10MB
        
        # Stop monitoring
        self.monitor.stop_monitoring()
        
        # Get current metrics
        snapshot = self.monitor.get_current_snapshot()
        
        # Validate targets
        targets_met = {}
        
        # Simple fix target
        targets_met['simple_fix'] = simple_time <= targets['simple_fix_target_ms']
        
        # Complex fix target
        targets_met['complex_fix'] = complex_time <= targets['complex_fix_target_ms']
        
        # Memory target
        targets_met['large_file_memory'] = snapshot['peak_memory_mb'] <= targets['large_file_memory_mb']
        
        # Throughput target
        targets_met['throughput'] = snapshot['throughput_ops_per_sec'] >= targets['min_throughput_ops_per_sec']
        
        # CPU target
        targets_met['cpu_usage'] = snapshot['cpu_percent'] <= targets['max_cpu_percent']
        
        # Should meet most targets for this simple test
        targets_passed = sum(targets_met.values())
        self.assertGreaterEqual(targets_passed, 3)  # At least half the targets
        
        # Check overall assessment
        overall_score = targets_passed / len(targets_met) * 100
        self.assertGreaterEqual(overall_score, 50)  # At least 50% of targets

if __name__ == '__main__':
    # Configure test environment
    os.environ['NOODLE_SYNTAX_FIXER_ADVANCED_ML'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_ML_GPU_ACCELERATION'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_ML_PERFORMANCE_MONITORING'] = 'true'
    
    # Run tests
    unittest.main(verbosity=2)

