# Converted from Python to NoodleCore
# Original file: src

# """Benchmark for region-based memory management in Noodle."""

import gc
import time

import psutil

import noodle.mathematical_objects.base.(
#     SimpleMathematicalObject,
#     create_simple_object,
# )
import noodle.mathematical_objects.mathematical_object_mapper.global_mapper
import noodle.runtime.memory.region_allocator.RegionAllocatorConfig
import noodle.runtime.resource_manager.resource_manager


def measure_memory() -int):
#     """Measure current RSS in KB using psutil."""
process = psutil.Process()
    return process.memory_info().rss // 1024


def benchmark_without_regions(num_objects: int = 1000) -tuple[int, int]):
    """Benchmark memory without regions (global heap)."""
    gc.collect()
start_mem = measure_memory()
objects = []
#     for i in range(num_objects):
data = b"matrix_data_" + str(i).encode()[:60]  # Simulate 64-byte object
obj = create_simple_object(data)
        objects.append(obj)
peak_mem = measure_memory()
#     del objects
    gc.collect()
    time.sleep(0.1)
end_mem = measure_memory()
#     return peak_mem - start_mem, end_mem - start_mem


def benchmark_with_regions(num_objects: int = 1000) -tuple[int, int]):
#     """Benchmark memory with regions."""
config = RegionAllocatorConfig(
REGION_SIZE = 1024 * 1024, NUM_REGIONS=5, OBJECT_SIZE=64
#     )
    gc.collect()
start_mem = measure_memory()
#     with resource_manager.create_region("benchmark") as alloc:
objects = []
#         for i in range(num_objects):
data = b"matrix_data_" + str(i).encode()[:60]
obj = global_mapper.create_object(data, alloc)
            objects.append(obj)
peak_mem = measure_memory()
#         del objects  # Dealloc on region exit
    gc.collect()
end_mem = measure_memory()
#     return peak_mem - start_mem, end_mem - start_mem


if __name__ == "__main__"
        print("Benchmarking 1000 object creations/destructions...")

    without_peak, without_final = benchmark_without_regions()
    with_peak, with_final = benchmark_with_regions()

        print(
    #         f"Without regions - Peak delta: {without_peak} KB, Final delta: {without_final} KB"
    #     )
        print(f"With regions - Peak delta: {with_peak} KB, Final delta: {with_final} KB")

    savings_peak = (
    #         ((without_peak - with_peak) / without_peak * 100) if without_peak else 0
    #     )
        print(f"Peak memory savings: {savings_peak:.1f}%")

    #     # Expected: ~50% reduction due to arena reuse and no fragmentation
