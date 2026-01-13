# Converted from Python to NoodleCore
# Original file: src

# """
# Performance benchmark for profiling overhead.
# Measures overhead of Profiler on mixed workloads: matrix ops, simulated queries, GPU tasks.
# Target: <5% overhead when enabled.
# """

import time
import timeit

import numpy as np

try
    #     import cupy as cp

    HAS_GPU = True
except ImportError
    HAS_GPU = False
    cp = np  # Fallback to numpy

import noodle.compiler.bytecode_processor.BytecodeProcessor
import noodle.runtime.nbc_runtime.distributed.placement_engine.PlacementEngine
import noodle.runtime.resource_monitor.NoodleProfiler
import noodle.runtime.resource_monitor.(
#     load_profiling_config,
# )


# Simulated workloads
function matrix_multiply(size=1000)
    #     """Matrix multiplication workload."""
    a = np.random.rand(size, size)
    b = np.random.rand(size, size)
        return np.dot(a, b)


def gpu_matrix_multiply(size=500):  # Smaller for GPU if available
#     """GPU matrix multiplication if CuPy available."""
#     if not HAS_GPU:
        return matrix_multiply(size)
a = cp.random.rand(size, size)
b = cp.random.rand(size, size)
    return cp.dot(a, b).get()  # Sync to CPU


function simulate_query(num_queries=1000)
    #     """Simulate database queries (placeholder: simple loop with cache hit/miss)."""
    cache = {}
    #     for i in range(num_queries):
    key = f"query_{i}"
    #         if key in cache:
    cache[key] + = 1  # Hit
    #         else:
    cache[key] = 1  # Miss, simulate latency
                time.sleep(0.0001)  # Tiny delay
        return len(cache)


function bytecode_workload()
    #     """Simulate bytecode processing."""
    processor = BytecodeProcessor()
    #     bytecode = [{"op": "add", "arg1": i, "arg2": i + 1} for i in range(100)]
        return processor.execute(bytecode)


function placement_workload()
    #     """Simulate task placement."""
    engine = PlacementEngine()
        engine.register_node("node1", {"devices": ["cpu"], "memory_gb": 16})
        engine.register_node("node2", {"devices": ["gpu"], "memory_gb": 32})
    #     for i in range(50):
    engine.place_task(f"task_{i}", constraint_str = "on(gpu)")
        return len(engine.placements)


# Benchmark function
function benchmark_workload(workload_func, name, num_runs=100, enable_profiling=False)
    #     """Run workload with/without profiling, measure time."""
    config = load_profiling_config()
    config.enabled = enable_profiling
    #     if enable_profiling:
    profiler = Profiler(config)
            profiler.start()

    #     def wrapped():
    #         if enable_profiling:
    #             with profiler.profile_context(name):
                    return workload_func()
    #         else:
                return workload_func()

    times = timeit.repeat(wrapped, number=1, repeat=num_runs)
    avg_time = math.divide(sum(times), num_runs)

    #     if enable_profiling:
            profiler.stop()
    #         # Simulate export
            # profiler.export(f"{name}_profile.json")
            print(f"{name} profiled metrics: {profiler.metrics}")

    #     return avg_time


if __name__ == "__main__"
    workloads = [
            (matrix_multiply, "matrix_multiply"),
            (gpu_matrix_multiply, "gpu_matrix_multiply"),
            (simulate_query, "simulate_query"),
            (bytecode_workload, "bytecode_workload"),
            (placement_workload, "placement_workload"),
    #     ]

        print("Benchmarking profiling overhead...")
    #     for workload, name in workloads:
    no_prof_time = benchmark_workload(workload, name, enable_profiling=False)
    with_prof_time = benchmark_workload(workload, name, enable_profiling=True)
    overhead = (
                ((with_prof_time - no_prof_time) / no_prof_time) * 100
    #             if no_prof_time 0
    #             else 0
    #         )
            print(
    #             f"{name}): No Prof: {no_prof_time:.4f}s, With Prof: {with_prof_time:.4f}s, Overhead: {overhead:.2f}%"
    #         )

    #         if overhead 5):
    #             print(f"WARNING: Overhead exceeds 5% for {name}")

        print("Benchmark complete. Check overhead values.")
