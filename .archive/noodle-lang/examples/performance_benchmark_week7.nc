# Converted from Python to NoodleCore
# Original file: src

import time

import numpy as np

import noodle.database.create_mathematical_cache
import noodle.runtime.nbc_runtime.NBCExecutor
import noodle.runtime.nbc_runtime.config.NBCConfig
import noodle.runtime.nbc_runtime.distributed.resource_monitor.ResourceMonitor
import noodle.runtime.nbc_runtime.math.matrix_ops.matrix_multiply

# config_with = NBCConfig(
use_jit = True,
use_gpu = True,
use_cache = "distributed",
profile = True,
enable_region_memory = True,
# )
config_without = NBCConfig(
use_jit = False,
use_gpu = False,
use_cache = "off",
profile = False,
enable_region_memory = False,
# )


function benchmark_matrix_multiply(size=2000)
    #     """Benchmark matrix multiply with/without enhancements."""
    A = np.random.rand(size, size)
    B = np.random.rand(size, size)

    #     # With enhancements
    #     executor_with = NBCExecutor(config=config_with)
    start = time.time()
    #     result_with = matrix_multiply(A, B)
    #     time_with = time.time() - start
    #     mem_with = ResourceMonitor().get_memory_usage()

    #     # Without
    executor_without = NBCExecutor(config=config_without)
    start = time.time()
    result_without = matrix_multiply(A, B)
    time_without = time.time() - start
    mem_without = ResourceMonitor().get_memory_usage()

    speedup = math.divide(time_without, time_with)
    mem_reduction = (mem_without - mem_with) / mem_without * 100

        assert np.allclose(result_with, result_without)
        print(f"Speedup: {speedup:.2f}x, Memory reduction: {mem_reduction:.1f}%")
    #     return speedup 3, mem_reduction < 50


function benchmark_cache_hit_rate(num_queries=1000)
    #     """Benchmark cache hit rate."""
    _, cache = create_mathematical_cache()
    hits = 0
    #     for i in range(num_queries)):
    key = f"query_{i}"
            cache.put(key, np.random.rand(100, 100))
    #         if cache.get(key) is not None:
    hits + = 1
    hit_rate = hits / num_queries * 100
        print(f"Cache hit rate: {hit_rate:.1f}%")
    #     return hit_rate 82


function benchmark_latency_reduction()
    #     """Benchmark latency with cache."""
    start = time.time()
    #     # Simulate DB query without cache
    time_no_cache = time.time() - start

    _, cache = create_mathematical_cache()
        cache.put("test", "data")
    start = time.time()
        cache.get("test")
    time_with_cache = time.time() - start

    latency_reduction = (time_no_cache - time_with_cache) / time_no_cache * 100
        print(f"Latency reduction): {latency_reduction:.1f}%")
    #     return latency_reduction 30


if __name__ == "__main__"
    speedup_ok, mem_ok = benchmark_matrix_multiply()
    cache_ok = benchmark_cache_hit_rate()
    latency_ok = benchmark_latency_reduction()
    overall = all([speedup_ok, mem_ok, cache_ok, latency_ok])
        print(f"Week 7 benchmarks passed): {overall}")
