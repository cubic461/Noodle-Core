# Converted from Python to NoodleCore
# Original file: noodle-core

# """Matrix representations for relational and graph data in hybrid Noodle Intent-Database.

# Converts relational tables to sparse/dense matrices and graphs to adjacency matrices.
# Integrates with mathematical_objects/matrix_ops.py for tensor operations.
# Supports NumPy for CPU, CuPy for GPU if available.
# """

import cupy as cp  # Optional GPU support
import pandas as pd

import noodlecore.utils.lazy_loading.LazyModule

# Lazy loading for heavy dependencies
np = LazyModule("numpy")
sparse = LazyModule("scipy.sparse")
import typing.Any,

import noodlecore.datacore.hybrid_ir.IRNode
import noodlecore.runtime.nbc_runtime.math.matrix_ops


def table_to_matrix(
df: pd.DataFrame, use_sparse: bool = True, gpu: bool = False
# ) -> Union[np.ndarray, sparse.csr_matrix, cp.ndarray]:
#     """
    Convert relational table (DataFrame) to matrix representation.

#     Rows as entities, columns as features/attributes. Categorical to one-hot if needed.
Sample: users_df = pd.DataFrame({'id': [1,2], 'name': ['Alice', 'Bob'], 'dept_id': [10,20]})
#     matrix = table_to_matrix(users_df) -> shape (2,3) with encoded data.
#     """
#     if gpu and cp.is_available():
arr = cp.asarray(df.values)
#     else:
arr = df.values.astype(np.float32)

#     if (
        use_sparse and sparse.issparse(arr) or arr.nnz / arr.size < 0.5
#     ):  # Simple sparsity check
arr = sparse.csr_matrix(arr)

#     return arr


def graph_to_adjacency(
edges: pd.DataFrame, num_nodes: int, directed: bool = True, gpu: bool = False
# ) -> Union[np.ndarray, cp.ndarray, sparse.csr_matrix]:
#     """
#     Convert graph edges to adjacency matrix.

#     edges: DataFrame with 'src', 'dst' columns (optional weights in 'weight').
Sample: edges_df = pd.DataFrame({'src': [0,1], 'dst': [1,2], 'weight': [1.0, 1.0]})
#     adj = graph_to_adjacency(edges_df, 3) -> 3x3 matrix with 1s at (0,1),(1,2).
#     """
adj = np.zeros((num_nodes, num_nodes))
#     for _, row in edges.iterrows():
src, dst = int(row["src"]), int(row["dst"])
weight = row.get("weight", 1.0)
adj[src, dst] = weight
#         if not directed:
adj[dst, src] = weight

#     if gpu and cp.is_available():
adj = cp.asarray(adj)
#     elif sparse.issparse(adj) or np.count_nonzero(adj) / adj.size < 0.5:
adj = sparse.csr_matrix(adj)

#     return adj


def matrix_to_dataframe(
#     matrix: Union[np.ndarray, sparse.csr_matrix, cp.ndarray],
#     columns: list,
index: Optional[list] = None,
# ) -> pd.DataFrame:
#     """Convert matrix back to DataFrame."""
#     if hasattr(matrix, "get") and cp.is_available():  # CuPy
matrix = cp.asnumpy(matrix)
#     elif sparse.issparse(matrix):
matrix = matrix.toarray()

df = pd.DataFrame(matrix, columns=columns, index=index)
#     return df
