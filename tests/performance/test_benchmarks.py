"""
Performance Benchmark Tests for NIP v3.0.0

Comprehensive performance benchmarks for:
- Pipeline execution speed
- Memory usage
- Throughput
- Latency
- Scalability
"""

import pytest
import asyncio
import time
import tracemalloc
from pathlib import Path
from typing import List, Dict
import statistics


class TestExecutionPerformance:
    """Test execution speed and performance"""
    
    @pytest.mark.asyncio
    async def test_small_pipeline_execution(self):
        """Test execution speed for small pipeline"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        start = time.time()
        result = await pipeline.execute("Say hello")
        duration = time.time() - start
        
        # Should complete in less than 5 seconds
        assert duration < 5.0
        assert result.success == True
    
    @pytest.mark.asyncio
    async def test_medium_pipeline_execution(self):
        """Test execution speed for medium pipeline"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        # Medium complexity task
        prompt = "Analyze the performance of a web application and suggest optimizations"
        
        start = time.time()
        result = await pipeline.execute(prompt)
        duration = time.time() - start
        
        # Should complete in less than 15 seconds
        assert duration < 15.0
        assert result.success == True
    
    @pytest.mark.asyncio
    async def test_parallel_execution_benchmark(self):
        """Benchmark parallel execution speedup"""
        from noodle.improve.parallel import ParallelExecutor
        
        executor = ParallelExecutor(max_parallel=4)
        
        # Sequential execution
        start = time.time()
        for i in range(10):
            await asyncio.sleep(0.1)
        seq_time = time.time() - start
        
        # Parallel execution
        start = time.time()
        tasks = [asyncio.sleep(0.1) for _ in range(10)]
        await executor.execute(tasks)
        par_time = time.time() - start
        
        # Parallel should be at least 2x faster
        speedup = seq_time / par_time
        assert speedup >= 2.0
    
    @pytest.mark.asyncio
    async def test_batch_processing_throughput(self):
        """Test batch processing throughput"""
        from noodle.improve.batch import BatchProcessor
        
        processor = BatchProcessor(batch_size=100)
        
        # Process 1000 items
        items = [{"id": i, "data": f"item{i}"} for i in range(1000)]
        
        start = time.time()
        results = await processor.process(items)
        duration = time.time() - start
        
        throughput = len(items) / duration
        
        # Should process at least 100 items/second
        assert throughput >= 100
        assert len(results) == 1000


class TestMemoryPerformance:
    """Test memory usage and efficiency"""
    
    @pytest.mark.asyncio
    async def test_memory_usage_small_task(self):
        """Test memory usage for small tasks"""
        tracemalloc.start()
        
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        # Execute small task
        await pipeline.execute("Hello world")
        
        current, peak = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        
        # Should use less than 100MB peak
        assert peak < 100 * 1024 * 1024
    
    @pytest.mark.asyncio
    async def test_memory_leak_check(self):
        """Check for memory leaks over multiple executions"""
        tracemalloc.start()
        
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        # Execute 100 times
        for i in range(100):
            await pipeline.execute(f"Task {i}")
        
        current, peak = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        
        # Memory should not grow unbounded
        # Current usage should be reasonable
        assert current < 200 * 1024 * 1024  # < 200MB
    
    @pytest.mark.asyncio
    async def test_cache_memory_efficiency(self):
        """Test cache memory management"""
        from noodle.improve.cache import MemoryCache
        
        cache = MemoryCache(max_memory_mb=10)
        
        # Fill cache with 1MB items
        for i in range(20):
            cache.set(f"key{i}", "x" * (1024 * 1024))  # 1MB each
        
        # Should enforce memory limit
        assert cache.memory_usage <= 12 * 1024 * 1024  # Allow some overhead
        
        # Should have evicted old entries
        assert len(cache.keys()) <= 12  # Should fit ~10 items


class TestLatency:
    """Test latency characteristics"""
    
    @pytest.mark.asyncio
    async def test_first_byte_latency(self):
        """Test time to first response byte"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        start = time.time()
        result = await pipeline.execute("Test")
        first_byte_time = time.time() - start
        
        # First byte should arrive quickly
        assert first_byte_time < 2.0
    
    @pytest.mark.asyncio
    async def test_p50_latency(self):
        """Test median (P50) latency"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        latencies = []
        for i in range(20):
            start = time.time()
            await pipeline.execute(f"Task {i}")
            latencies.append(time.time() - start)
        
        p50 = statistics.median(latencies)
        
        # Median latency should be reasonable
        assert p50 < 3.0
    
    @pytest.mark.asyncio
    async def test_p99_latency(self):
        """Test 99th percentile latency"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        latencies = []
        for i in range(100):
            start = time.time()
            await pipeline.execute(f"Task {i}")
            latencies.append(time.time() - start)
        
        latencies.sort()
        p99 = latencies[98]  # 99th percentile
        
        # P99 should be less than 10 seconds
        assert p99 < 10.0
    
    @pytest.mark.asyncio
    async def test_latency_stability(self):
        """Test latency consistency over time"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        latencies = []
        for i in range(50):
            start = time.time()
            await pipeline.execute(f"Task {i}")
            latencies.append(time.time() - start)
        
        # Calculate standard deviation
        stdev = statistics.stdev(latencies)
        mean = statistics.mean(latencies)
        
        # Coefficient of variation should be low (< 50%)
        cv = (stdev / mean) * 100
        assert cv < 50


class TestScalability:
    """Test scalability characteristics"""
    
    @pytest.mark.asyncio
    async def test_horizontal_scaling(self):
        """Test performance with more parallel workers"""
        from noodle.improve.parallel import ParallelExecutor
        
        # Test with different parallelism levels
        results = {}
        for max_parallel in [1, 2, 4, 8]:
            executor = ParallelExecutor(max_parallel=max_parallel)
            
            start = time.time()
            tasks = [asyncio.sleep(0.1) for _ in range(20)]
            await executor.execute(tasks)
            duration = time.time() - start
            
            results[max_parallel] = duration
        
        # More workers should be faster
        assert results[8] < results[4] < results[2] < results[1]
        
        # 8x parallelism should be at least 4x faster
        speedup = results[1] / results[8]
        assert speedup >= 4.0
    
    @pytest.mark.asyncio
    async def test_large_scale_processing(self):
        """Test processing large number of items"""
        from noodle.improve.batch import BatchProcessor
        
        processor = BatchProcessor(batch_size=1000)
        
        # Process 100,000 items
        items = [{"id": i} for i in range(100000)]
        
        start = time.time()
        results = await processor.process(items)
        duration = time.time() - start
        
        # Should complete in reasonable time
        assert duration < 60  # < 1 minute
        assert len(results) == 100000
    
    @pytest.mark.asyncio
    async def test_memory_scalability(self):
        """Test memory usage scales linearly"""
        tracemalloc.start()
        
        from noodle.improve.cache import MemoryCache
        
        cache = MemoryCache(max_memory_mb=100)
        
        # Measure memory for different cache sizes
        measurements = []
        for size in [100, 1000, 10000]:
            cache.clear()
            for i in range(size):
                cache.set(f"key{i}", "x" * 1024)  # 1KB each
            
            current, peak = tracemalloc.get_traced_memory()
            measurements.append((size, current))
        
        tracemalloc.stop()
        
        # Memory should scale roughly linearly
        # Check that 10x more data doesn't use 100x more memory
        _, mem_100 = measurements[0]
        _, mem_10000 = measurements[2]
        
        ratio = mem_10000 / mem_100
        assert ratio < 200  # < 200x for 100x data (allows overhead)


class TestConcurrencyPerformance:
    """Test concurrent operation performance"""
    
    @pytest.mark.asyncio
    async def test_concurrent_requests(self):
        """Test handling many concurrent requests"""
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        # Launch 50 concurrent requests
        tasks = [
            pipeline.execute(f"Task {i}")
            for i in range(50)
        ]
        
        start = time.time()
        results = await asyncio.gather(*tasks)
        duration = time.time() - start
        
        # All should complete
        assert len(results) == 50
        assert all(r.success for r in results)
        
        # Should complete faster than sequential
        assert duration < 50 * 2.0  # < 100 seconds
    
    @pytest.mark.asyncio
    async def test_cache_contention(self):
        """Test cache performance under contention"""
        from noodle.improve.cache import MemoryCache
        
        cache = MemoryCache()
        
        # Pre-populate cache
        for i in range(100):
            cache.set(f"key{i}", f"value{i}")
        
        # Concurrent reads
        start = time.time()
        tasks = [
            cache.get(f"key{i % 100}")
            for i in range(1000)
        ]
        results = await asyncio.gather(*tasks)
        duration = time.time() - start
        
        # All reads should complete
        assert len(results) == 1000
        
        # Should be fast (< 1 second)
        assert duration < 1.0
    
    @pytest.mark.asyncio
    async def test_lock_contention(self):
        """Test lock performance under contention"""
        from noodle.improve.locks import ResourceLock
        
        lock = ResourceLock()
        
        async def acquire_lock():
            async with lock.resource("test"):
                await asyncio.sleep(0.01)
            return True
        
        # Many tasks competing for same lock
        tasks = [acquire_lock() for _ in range(100)]
        
        start = time.time()
        results = await asyncio.gather(*tasks)
        duration = time.time() - start
        
        # All should complete
        assert len(results) == 100
        assert all(results)
        
        # Should complete in reasonable time
        # With lock contention, should take at least 100 * 0.01 = 1 second
        assert duration >= 1.0
        assert duration < 5.0  # But not too long


class TestIOPerformance:
    """Test I/O performance characteristics"""
    
    @pytest.mark.asyncio
    async def test_file_read_performance(self):
        """Test file reading performance"""
        from noodle.improve.files import FileReader
        import tempfile
        
        reader = FileReader()
        
        # Create test file
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
            f.write("x" * (1024 * 1024))  # 1MB file
            temp_path = f.name
        
        try:
            # Measure read time
            start = time.time()
            content = await reader.read(temp_path)
            duration = time.time() - start
            
            # Should read quickly
            assert duration < 0.5  # < 500ms
            assert len(content) == 1024 * 1024
        finally:
            Path(temp_path).unlink()
    
    @pytest.mark.asyncio
    async def test_file_write_performance(self):
        """Test file writing performance"""
        from noodle.improve.files import FileWriter
        import tempfile
        
        writer = FileWriter()
        
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
            temp_path = f.name
        
        try:
            data = "x" * (1024 * 1024)  # 1MB data
            
            # Measure write time
            start = time.time()
            await writer.write(temp_path, data)
            duration = time.time() - start
            
            # Should write quickly
            assert duration < 0.5  # < 500ms
            
            # Verify
            assert Path(temp_path).read_text() == data
        finally:
            Path(temp_path).unlink()
    
    @pytest.mark.asyncio
    async def test_concurrent_io(self):
        """Test concurrent I/O operations"""
        from noodle.improve.files import FileReader, FileWriter
        import tempfile
        
        reader = FileReader()
        writer = FileWriter()
        
        # Create test files
        files = []
        for i in range(50):
            with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
                f.write(f"content{i}")
                files.append(f.name)
        
        try:
            # Concurrent reads and writes
            tasks = []
            for i, fpath in enumerate(files):
                if i % 2 == 0:
                    tasks.append(reader.read(fpath))
                else:
                    tasks.append(writer.write(fpath, f"new{i}", mode='w'))
            
            start = time.time()
            results = await asyncio.gather(*tasks)
            duration = time.time() - start
            
            # All should complete
            assert len(results) == 50
            
            # Should be fast
            assert duration < 5.0
        finally:
            for fpath in files:
                Path(fpath).unlink()


class TestResourceEfficiency:
    """Test resource usage efficiency"""
    
    @pytest.mark.asyncio
    async def test_cpu_efficiency(self):
        """Test CPU usage efficiency"""
        import psutil
        import os
        
        process = psutil.Process(os.getpid())
        
        # Baseline CPU
        baseline_cpu = process.cpu_percent(interval=0.1)
        
        # Execute tasks
        from noodle.improve.pipeline import ImprovementPipeline
        pipeline = ImprovementPipeline()
        
        for i in range(10):
            await pipeline.execute(f"Task {i}")
        
        # Measure CPU usage
        cpu_usage = process.cpu_percent(interval=0.1)
        
        # CPU usage should be reasonable
        # Should not use 100% CPU continuously
        assert cpu_usage < 90 or baseline_cpu < 10
    
    @pytest.mark.asyncio
    async def test_connection_pool_efficiency(self):
        """Test connection pool efficiency"""
        from noodle.improve.pool import ConnectionPool
        
        pool = ConnectionPool(max_connections=10)
        
        # Acquire and release connections
        connections = []
        for i in range(10):
            conn = await pool.acquire()
            connections.append(conn)
        
        # Pool should be exhausted
        assert await pool.acquire() is None
        
        # Release all
        for conn in connections:
            await pool.release(conn)
        
        # Should be able to acquire again
        conn = await pool.acquire()
        assert conn is not None
        await pool.release(conn)
    
    @pytest.mark.asyncio
    async def test_memory_cleanup(self):
        """Test memory cleanup after operations"""
        import gc
        tracemalloc.start()
        
        from noodle.improve.pipeline import ImprovementPipeline
        
        pipeline = ImprovementPipeline()
        
        # Execute tasks
        for i in range(50):
            await pipeline.execute(f"Task {i}")
        
        # Force cleanup
        del pipeline
        gc.collect()
        
        current, peak = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        
        # Memory should be cleaned up
        # Current usage should be much lower than peak
        assert current < peak * 0.5  # At least 50% cleanup


class TestPerformanceRegression:
    """Test for performance regressions"""
    
    @pytest.mark.asyncio
    async def test_regression_detection(self):
        """Detect performance regressions using benchmarks"""
        from noodle.improve.benchmark import BenchmarkRunner
        
        runner = BenchmarkRunner()
        
        # Run benchmark
        results = await runner.run()
        
        # Check for regressions
        for metric, value in results.items():
            baseline = runner.get_baseline(metric)
            
            if baseline:
                change = ((value - baseline) / baseline) * 100
                
                # Should not regress more than 20%
                assert change < 20, f"Regression in {metric}: {change:.2f}%"
    
    @pytest.mark.asyncio
    async def test_update_baseline(self):
        """Update performance baseline"""
        from noodle.improve.benchmark import BenchmarkRunner
        
        runner = BenchmarkRunner()
        
        # Run benchmark
        results = await runner.run()
        
        # Update baseline
        runner.update_baseline(results)
        
        # Verify baseline was updated
        for metric, value in results.items():
            baseline = runner.get_baseline(metric)
            assert baseline == value


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
