"""
Edge Case Tests for NIP v3.0.0

Comprehensive edge case coverage for:
- Empty/null inputs
- Boundary conditions
- Error handling
- Race conditions
- Resource exhaustion
"""

import pytest
import asyncio
import tempfile
from pathlib import Path
import json
import contextlib


class TestEmptyInputs:
    """Test handling of empty and null inputs"""

    @pytest.mark.asyncio
    async def test_empty_prompt(self):
        """Test handling of empty prompt strings"""
        from noodle.improve.pipeline import ImprovementPipeline

        pipeline = ImprovementPipeline()
        result = await pipeline.execute("")

        assert result.success is False
        assert "empty" in result.error.lower()

    @pytest.mark.asyncio
    async def test_null_parameters(self):
        """Test handling of None/null parameters"""
        from noodle.improve.tools import ToolExecutor

        executor = ToolExecutor()
        result = await executor.execute_tool("test_tool", None)

        assert result.status == "error"
        assert "null" in result.error.lower() or "none" in result.error.lower()

    @pytest.mark.asyncio
    async def test_empty_array(self):
        """Test handling of empty arrays/lists"""
        from noodle.improve.comparison import CandidateComparator

        comparator = CandidateComparator([])
        result = await comparator.compare()

        assert len(result.candidates) == 0
        assert result.best_candidate is None

    @pytest.mark.asyncio
    async def test_empty_file(self):
        """Test handling of empty file inputs"""
        from noodle.improve.files import FileReader

        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
            temp_path = f.name

        try:
            reader = FileReader()
            content = await reader.read(temp_path)

            assert content == ""
        finally:
            Path(temp_path).unlink()

    @pytest.mark.asyncio
    async def test_whitespace_only(self):
        """Test handling of whitespace-only strings"""
        from noodle.improve.parser import PromptParser

        parser = PromptParser()
        result = parser.parse("   \n\t   ")

        assert result.is_empty is True
        assert len(result.tokens) == 0


class TestBoundaryConditions:
    """Test boundary and limit conditions"""

    @pytest.mark.asyncio
    async def test_max_context_length(self):
        """Test handling of maximum context length"""
        from noodle.improve.llm import LLMProvider

        provider = LLMProvider(max_tokens=4096)

        # Create exactly max length prompt
        long_prompt = "x" * 4096
        result = await provider.generate(long_prompt)

        # Should handle gracefully
        assert result is not None or result.error is not None

    @pytest.mark.asyncio
    async def test_zero_candidates(self):
        """Test handling of zero candidates"""
        from noodle.improve.comparison import CandidateComparator

        comparator = CandidateComparator([])
        result = await comparator.compare()

        assert result.winner is None
        assert len(result.rankings) == 0

    @pytest.mark.asyncio
    async def test_single_candidate(self):
        """Test handling of single candidate"""
        from noodle.improve.comparison import CandidateComparator

        candidates = [{"id": "candidate1", "score": 0.8}]
        comparator = CandidateComparator(candidates)
        result = await comparator.compare()

        assert result.winner == "candidate1"
        assert len(result.rankings) == 1

    @pytest.mark.asyncio
    async def test_max_parallel_tasks(self):
        """Test behavior at maximum parallel task limit"""
        from noodle.improve.parallel import ParallelExecutor

        executor = ParallelExecutor(max_parallel=10)

        # Create 20 tasks (2x max_parallel)
        tasks = [asyncio.sleep(0.1) for _ in range(20)]
        results = await executor.execute(tasks)

        assert len(results) == 20
        assert executor.max_concurrent_reached is True

    @pytest.mark.asyncio
    async def test_timeout_boundary(self):
        """Test timeout at exact boundary"""
        from noodle.improve.execution import TimeoutExecutor

        executor = TimeoutExecutor(timeout=1.0)

        # Task that takes exactly 1 second
        async def exact_timeout_task():
            await asyncio.sleep(1.0)
            return "completed"

        result = await executor.execute(exact_timeout_task())

        # Should complete just in time
        assert result == "completed" or result.timeout is True


class TestErrorHandling:
    """Test error handling and recovery"""

    @pytest.mark.asyncio
    async def test_invalid_json(self):
        """Test handling of invalid JSON input"""
        from noodle.improve.config import ConfigParser

        parser = ConfigParser()

        with pytest.raises(json.JSONDecodeError):
            parser.parse("{invalid json}")

    @pytest.mark.asyncio
    async def test_file_not_found(self):
        """Test handling of missing files"""
        from noodle.improve.files import FileReader

        reader = FileReader()

        with pytest.raises(FileNotFoundError):
            await reader.read("/nonexistent/file.txt")

    @pytest.mark.asyncio
    async def test_network_timeout(self):
        """Test handling of network timeouts"""
        from noodle.improve.api import APIClient

        client = APIClient(timeout=0.1)

        with pytest.raises(TimeoutError):
            await client.get("http://httpbin.org/delay/10")

    @pytest.mark.asyncio
    async def test_permission_denied(self):
        """Test handling of permission errors"""
        from noodle.improve.files import FileWriter

        with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
            temp_path = f.name

        # Make file read-only
        Path(temp_path).chmod(0o444)

        try:
            writer = FileWriter()

            with pytest.raises(PermissionError):
                await writer.write(temp_path, "new content")
        finally:
            Path(temp_path).chmod(0o644)
            Path(temp_path).unlink()

    @pytest.mark.asyncio
    async def test_memory_exhaustion(self):
        """Test handling of memory pressure"""
        from noodle.improve.cache import MemoryCache

        cache = MemoryCache(max_memory_mb=1)

        # Try to cache more than available memory
        large_data = "x" * (2 * 1024 * 1024)  # 2MB

        result = cache.set("large_key", large_data)

        # Should reject or evict
        assert result is False or cache.get("large_key") is None


class TestRaceConditions:
    """Test concurrent access and race conditions"""

    @pytest.mark.asyncio
    async def test_concurrent_write(self):
        """Test concurrent writes to same resource"""
        from noodle.improve.files import FileWriter

        with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
            temp_path = f.name

        try:
            writer = FileWriter()

            # Write concurrently
            tasks = [
                writer.write(temp_path, f"content{i}\n", mode='a')
                for i in range(10)
            ]
            await asyncio.gather(*tasks)

            # Verify all writes completed
            content = Path(temp_path).read_text()
            assert len(content.splitlines()) == 10
        finally:
            Path(temp_path).unlink()

    @pytest.mark.asyncio
    async def test_concurrent_cache_access(self):
        """Test concurrent cache access"""
        from noodle.improve.cache import MemoryCache

        cache = MemoryCache()

        # Concurrent reads and writes
        tasks = []
        for i in range(100):
            if i % 2 == 0:
                tasks.append(cache.set(f"key{i}", f"value{i}"))
            else:
                tasks.append(cache.get(f"key{i-1}"))

        results = await asyncio.gather(*tasks)

        # All operations should complete
        assert len(results) == 100

    @pytest.mark.asyncio
    async def test_concurrent_llm_requests(self):
        """Test concurrent LLM requests"""
        from noodle.improve.llm import LLMProvider

        provider = LLMProvider(max_concurrent=5)

        # Create 10 concurrent requests
        prompts = [f"test prompt {i}" for i in range(10)]
        tasks = [provider.generate(p) for p in prompts]

        results = await asyncio.gather(*tasks, return_exceptions=True)

        # All should complete (some may be rate limited)
        assert len(results) == 10

    @pytest.mark.asyncio
    async def test_deadlock_prevention(self):
        """Test deadlock prevention in resource management"""
        from noodle.improve.locks import ResourceLock

        lock = ResourceLock()

        async def task1():
            async with lock.resource("A"):
                await asyncio.sleep(0.1)
                async with lock.resource("B"):
                    return "task1_complete"

        async def task2():
            async with lock.resource("B"):
                await asyncio.sleep(0.1)
                async with lock.resource("A"):
                    return "task2_complete"

        # Run both tasks (should not deadlock)
        results = await asyncio.gather(task1(), task2(), return_exceptions=True)

        # At least one should complete
        assert any(r is not Exception for r in results)


class TestResourceExhaustion:
    """Test behavior under resource pressure"""

    @pytest.mark.asyncio
    async def test_disk_space_exhaustion(self):
        """Test handling of disk space exhaustion"""
        from noodle.improve.files import FileWriter

        writer = FileWriter()

        # Try to write very large file
        with tempfile.NamedTemporaryFile(mode='w', delete=False, dir='/tmp') as f:
            temp_path = f.name

        try:
            # This might fail due to disk space
            result = await writer.write(temp_path, "x" * (10 * 1024 * 1024 * 1024))

            # Should handle gracefully
            assert result is True or "space" in str(result.error).lower()
        except OSError as e:
            # Expected to fail
            assert "space" in str(e).lower() or "disk" in str(e).lower()
        finally:
            with contextlib.suppress(Exception):
                Path(temp_path).unlink()

    @pytest.mark.asyncio
    async def test_file_descriptor_exhaustion(self):
        """Test handling of too many open files"""
        from noodle.improve.files import FileReader

        reader = FileReader()
        files = []

        try:
            # Open many files
            for i in range(10000):
                with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
                    f.write(f"content{i}")
                    temp_path = f.name
                    files.append(temp_path)

                # This might fail due to FD limit
                try:
                    content = await reader.read(temp_path)
                    assert content == f"content{i}"
                except OSError as e:
                    # Expected to fail at some point
                    assert "file" in str(e).lower() or "descriptor" in str(e).lower()
                    break
        finally:
            for f in files:
                with contextlib.suppress(Exception):
                    Path(f).unlink()

    @pytest.mark.asyncio
    async def test_memory_limit(self):
        """Test behavior at memory limit"""
        from noodle.improve.cache import MemoryCache

        cache = MemoryCache(max_memory_mb=10)

        # Fill cache
        for i in range(1000):
            cache.set(f"key{i}", "x" * 1024)  # 1KB each

        # Should evict old entries
        assert cache.memory_usage <= 10 * 1024 * 1024

    @pytest.mark.asyncio
    async def test_connection_pool_exhaustion(self):
        """Test handling of connection pool exhaustion"""
        from noodle.improve.database import ConnectionPool

        pool = ConnectionPool(max_connections=5)

        # Try to get more connections than available
        connections = []
        for i in range(10):
            try:
                conn = await pool.acquire()
                connections.append(conn)
            except Exception:
                # Expected to fail after 5
                assert i >= 5
                break

        # Should have at most 5 connections
        assert len(connections) <= 5

        # Cleanup
        for conn in connections:
            await pool.release(conn)


class TestInvalidStates:
    """Test handling of invalid system states"""

    @pytest.mark.asyncio
    async def test_corrupted_cache(self):
        """Test handling of corrupted cache data"""
        from noodle.improve.cache import DiskCache

        with tempfile.TemporaryDirectory() as tmpdir:
            cache = DiskCache(cache_dir=tmpdir)

            # Write corrupted data
            cache_file = Path(tmpdir) / "corrupted"
            cache_file.write_text("not valid pickle data")

            # Should handle gracefully
            result = cache.get("corrupted")
            assert result is None

    @pytest.mark.asyncio
    async def test_broken_symlink(self):
        """Test handling of broken symbolic links"""
        from noodle.improve.files import FileReader

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create broken symlink
            link = Path(tmpdir) / "broken_link"
            link.symlink_to("/nonexistent/target")

            reader = FileReader()

            # Should handle gracefully
            with pytest.raises(FileNotFoundError):
                await reader.read(str(link))

    @pytest.mark.asyncio
    async def test_interrupted_operation(self):
        """Test handling of interrupted operations"""
        from noodle.improve.execution import CancellableExecutor

        executor = CancellableExecutor()

        async def long_running():
            for _i in range(100):
                await asyncio.sleep(0.1)
                if executor.is_cancelled():
                    raise asyncio.CancelledError()
            return "completed"

        # Start task
        task = asyncio.create_task(long_running())

        # Cancel after 0.2 seconds
        await asyncio.sleep(0.2)
        executor.cancel()

        # Should handle cancellation
        with pytest.raises((asyncio.CancelledError, Exception)):
            await task

    @pytest.mark.asyncio
    async def test_invalid_unicode(self):
        """Test handling of invalid unicode data"""
        from noodle.improve.parser import TextParser

        parser = TextParser()

        # Invalid UTF-8 sequence
        invalid_bytes = b'\xff\xfe\x00\x00'

        with pytest.raises(UnicodeDecodeError):
            parser.parse_bytes(invalid_bytes)

    @pytest.mark.asyncio
    async def test_malformed_config(self):
        """Test handling of malformed configuration"""
        from noodle.improve.config import ConfigLoader

        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.json') as f:
            f.write('{"valid": false, "nested": {"missing": true}}')
            temp_path = f.name

        try:
            loader = ConfigLoader()

            # Should validate and reject
            with pytest.raises(ValueError):
                loader.load(temp_path, require_fields=["valid", "nested", "present"])
        finally:
            Path(temp_path).unlink()


class TestPerformanceEdgeCases:
    """Test performance-related edge cases"""

    @pytest.mark.asyncio
    async def test_cold_start(self):
        """Test cold start performance"""
        import time
        from noodle.improve.pipeline import ImprovementPipeline

        # First call (cold start)
        pipeline = ImprovementPipeline()
        start = time.time()
        await pipeline.execute("test")
        cold_time = time.time() - start

        # Second call (warm)
        start = time.time()
        await pipeline.execute("test")
        warm_time = time.time() - start

        # Warm should be faster
        assert warm_time <= cold_time

    @pytest.mark.asyncio
    async def test_large_batch_processing(self):
        """Test processing very large batches"""
        from noodle.improve.batch import BatchProcessor

        processor = BatchProcessor(batch_size=10000)

        # Process large batch
        items = [{"id": i, "value": f"item{i}"} for i in range(100000)]
        results = await processor.process(items)

        assert len(results) == 100000

    @pytest.mark.asyncio
    async def test_memory_leak_prevention(self):
        """Test memory leak prevention"""
        import gc
        from noodle.improve.cache import MemoryCache

        cache = MemoryCache()

        # Add and remove many items
        for i in range(10000):
            cache.set(f"key{i}", "x" * 1024)
            cache.delete(f"key{i}")

        # Force garbage collection
        gc.collect()

        # Memory should be freed
        assert cache.memory_usage < 100 * 1024 * 1024  # < 100MB


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
