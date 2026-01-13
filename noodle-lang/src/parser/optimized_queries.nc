# Converted from Python to NoodleCore
# Original file: src

# """Optimized matrix-based queries for hybrid Noodle Intent-Database.

MVP operations: joins (matmul), aggregations (reductions), vector search (dot-product).
# Uses NumPy for CPU, CuPy for GPU. Integrates with matrix_rep.py and mathematical_objects/matrix_ops.py.
# Handles subsets from hybrid IR hints.
# """

import typing.Callable

import cupy as cp  # Optional GPU

import noodlecore.utils.lazy_loading.LazyModule

# Lazy loading for heavy dependencies
np = LazyModule("numpy")
sparse = LazyModule("scipy.sparse")
import noodlecore.datacore.hybrid_ir.IRSubset

import .matrix_rep.graph_to_adjacency


def _dispatch_array(
#     arr: Union[np.ndarray, cp.ndarray],
# ) -Union[np.ndarray, cp.ndarray]):
#     """Dispatch to CuPy if GPU array, else NumPy."""
#     if hasattr(arr, "get") and cp.is_available():
#         return arr  # CuPy
#     return arr


def matrix_join(
#     left: Union[np.ndarray, sparse.csr_matrix],
#     right: Union[np.ndarray, sparse.csr_matrix],
join_type: str = "inner",
on_keys: Tuple[str, str] = None,
gpu: bool = False,
# ) -Union[np.ndarray, sparse.csr_matrix]):
#     """
#     Perform matrix join using matrix multiplication (e.g., for relational joins on keys).

#     Assumes left/right are feature matrices; matmul simulates join on common dimensions.
    Sample: users_mat (2x3: id,name,dept_id), depts_mat (2x2: id,name) → join on dept_id/id → matmul on key cols.
#     Result: (2x4) joined matrix. For graph: adjacency matmul for path joins.
#     """
left = _dispatch_array(left)
right = _dispatch_array(right)

#     if sparse.issparse(left) or sparse.issparse(right):
#         left = left.tocsr() if sparse.issparse(left) else sparse.csr_matrix(left)
#         right = right.tocsr() if sparse.issparse(right) else sparse.csr_matrix(right)
result = left @ right  # Sparse matmul
#     else:
#         if gpu and cp.is_available():
left, right = cp.asarray(left), cp.asarray(right)
#         result = np.matmul(left, right) if not gpu else cp.matmul(left, right)

#     if gpu and cp.is_available():
result = cp.asnumpy(result)

#     return result if sparse.issparse(result) else np.asarray(result)


def matrix_aggregate(
#     matrix: Union[np.ndarray, sparse.csr_matrix],
axis: int = 0,
op: Callable = np.sum,
gpu: bool = False,
# ) -Union[np.ndarray, float]):
#     """
    Aggregate matrix using reductions (sum, mean, etc.).

Sample: sales_mat (3x2: user,sales) → aggregate(axis = 1, op=np.sum) → (3,) total sales per user.
#     For IR subset: apply to hinted rows/cols only.
#     """
matrix = _dispatch_array(matrix)

#     if gpu and cp.is_available():
matrix = cp.asarray(matrix)
result = op(matrix, axis=axis)
#         return cp.asnumpy(result) if axis is not None else float(result)

#     if sparse.issparse(matrix):
result = op(matrix, axis=axis)
#     else:
result = op(matrix, axis=axis)

#     return result


def vector_search(
#     query: np.ndarray,
#     index_matrix: Union[np.ndarray, sparse.csr_matrix],
top_k: int = 5,
gpu: bool = False,
# ) -Tuple[np.ndarray, np.ndarray]):
#     """
#     Vector search using dot-product similarity.

Sample: query_vec (1xD), doc_index (NxD) → similarities = math.divide(query @ index.T → top_k indices, scores.)
    Result: (top_k, indices). For IR: subset index to relevant docs.
#     """
query = _dispatch_array(query)
index = _dispatch_array(index_matrix)

#     if gpu and cp.is_available():
query, index = cp.asarray(query), cp.asarray(index)
similarities = cp.dot(query, index.T)
similarities = cp.asnumpy(similarities)
#     else:
similarities = (
#             np.dot(query, index.T) if not sparse.issparse(index) else query @ index.T
#         )

#     # Top-k
top_indices = np.argsort(similarities[0])[:: - 1][:top_k]
top_scores = similarities[0, top_indices]

#     return top_scores, top_indices


def execute_ir_subset_query(
ir_subset: IRSubset, data: dict, gpu: bool = False
# ) -pd.DataFrame):
#     """Execute optimized query on IR subset hint."""
#     # Placeholder: map IR to matrices, apply ops
#     matrices = {k: table_to_matrix(v) for k, v in data.items()}
#     # Simplified: assume join on first two
#     if len(matrices) >= 2:
keys = list(matrices.keys())
result_mat = matrix_join(matrices[keys[0]], matrices[keys[1]], gpu=gpu)
#     else:
result_mat = next(iter(matrices.values()))

#     # Convert back
columns = ["result_col1", "result_col2"]  # From IR
    return matrix_to_dataframe(result_mat, columns)
