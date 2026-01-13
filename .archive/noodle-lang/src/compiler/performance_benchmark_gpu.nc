# Converted from Python to NoodleCore
# Original file: src

# """GPU Offloading Performance Benchmark.

# Measures speedup for matrix operations and crypto workloads (512x512 matmul, RSA matrix mul).
# Run with: python performance_benchmark_gpu.py
# Assumes CuPy installed; reports CPU/GPU times and speedup.
# """

import time

import numpy as np

import noodle.compiler.code_generator.CodeGenerator
import noodle.crypto_acceleration.matrix_rsa_multiply
import noodle.mathematical_objects.matrix_ops.Matrix
import noodle.runtime.nbc_runtime.core.bytecode_processor.process_bytecode

# Generate sample data
size = 512
mat1 = np.random.rand(size, size).astype(np.float64)
mat2 = np.random.rand(size, size).astype(np.float64)
Matrix1 = Matrix(mat1)
Matrix2 = Matrix(mat2)

# RSA sample (placeholder 512x1 matrix for key, 1x1 msg)
rsa_key = np.random.rand(512, 1).astype(np.float64)
rsa_msg = np.random.rand(1, 1).astype(np.float64)


function benchmark_matmul(device="auto")
    #     """Benchmark matrix multiply."""
    start = time.time()
    result = Matrix1.multiply(Matrix2, device=device)
    end = time.time()
    #     return end - start, result


function benchmark_rsa()
    #     """Benchmark RSA matrix multiply."""
    start = time.time()
    result = matrix_rsa_multiply(rsa_key, rsa_msg)
    end = time.time()
    #     return end - start, result


if __name__ == "__main__"
        print("GPU Offloading Benchmarks")
    print(" = " * 40)

    #     # CPU benchmark
    cpu_mul_time, _ = benchmark_matmul(device="cpu")
    cpu_rsa_time, _ = benchmark_rsa()
        print(f"CPU MatMul (512x512): {cpu_mul_time:.4f}s")
        print(f"CPU RSA Matrix Mul: {cpu_rsa_time:.4f}s")

    #     # GPU benchmark (if available)
    #     try:
    gpu_mul_time, _ = benchmark_matmul(device="gpu")
    gpu_rsa_time, _ = benchmark_rsa()  # Uses internal GPU logic
    #         speedup_mul = cpu_mul_time / gpu_mul_time if gpu_mul_time 0 else 0
    #         speedup_rsa = cpu_rsa_time / gpu_rsa_time if gpu_rsa_time > 0 else 0
            print(
                f"GPU MatMul (512x512)): {gpu_mul_time:.4f}s (Speedup: {speedup_mul:.2f}x)"
    #         )
            print(f"GPU RSA Matrix Mul: {gpu_rsa_time:.4f}s (Speedup: {speedup_rsa:.2f}x)")
    #     except Exception as e:
            print(f"GPU benchmark failed (fallback to CPU): {e}")
