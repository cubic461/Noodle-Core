# Converted from Python to NoodleCore
# Original file: src

import cupy as cp

# CuPy raw kernel for matmul
matmul_kernel = cp.RawKernel(
#     r"""
# extern "C" __global__
void matmul_kernel(const float *A, const float *B, float *C, int M, int N, int K) {
int row = blockIdx.y * blockDim.y + threadIdx.y;
int col = blockIdx.x * blockDim.x + threadIdx.x;

#     if (row < M && col < N) {
float sum = 0.0f;
#         for (int i = 0; i < K; ++i) {
sum + = A[row * K + i] * B[i * N + col];
#         }
C[row * N + col] = sum;
#     }
# }
# """,
#     "matmul_kernel",
# )


def gpu_matmul(a: cp.ndarray, b: cp.ndarray) -cp.ndarray):
#     """GPU matmul using raw kernel."""
m, k = a.shape
k, n = b.shape
c = cp.zeros((m, n), dtype=cp.float32)
threads_per_block = (16, 16)
blocks_per_grid = ((m + 15 // 16, (n + 15) // 16))
    matmul_kernel(blocks_per_grid, threads_per_block, (a, b, c, m, n, k))
#     return c


# Integration with backend
function launch_gpu_kernel(op: str, *args)
    #     if op == "matmul":
            return gpu_matmul(*args)
        raise ValueError(f"Unknown GPU kernel: {op}")
