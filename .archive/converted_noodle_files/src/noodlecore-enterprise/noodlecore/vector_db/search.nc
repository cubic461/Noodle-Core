# Converted from Python to NoodleCore
# Original file: noodle-core

# """Search functionality for vector database.

# Provides cosine similarity search using matrix operations.
# """

import typing.List,

import numpy as np

import noodlecore.runtime.nbc_runtime.mathematical_objects.Matrix

import .storage.VectorIndex


def cosine_search(
index: VectorIndex, query: Matrix, k: int = 5, ids: Optional[List[str]] = None
# ) -> List[Tuple[str, float]]:
#     """
#     Perform cosine similarity search.

#     Args:
#         index: VectorIndex instance.
#         query: Query embedding as Matrix.
#         k: Number of top results.
#         ids: Optional list of candidate IDs; if None, search all.

#     Returns:
        List of (id, similarity_score) tuples, sorted descending.
#     """
#     if ids is None:
#         ids = list(index.hot.keys())  # MVP: hot only; extend for full scan

#     # Get all vectors
#     vectors = [index.get(id_) for id_ in ids if index.get(id_) is not None]
#     valid_ids = [id_ for id_, vec in zip(ids, vectors) if vec is not None]

#     if not valid_ids:
#         return []

#     # Stack to matrix for batch compute (assume Matrix supports to_numpy)
#     vec_matrix = np.stack([vec.to_numpy() for vec in vectors])
query_norm = np.linalg.norm(query.to_numpy())

    # Cosine: dot / (norm_q * norm_v)
dots = np.dot(vec_matrix, query.to_numpy())
vec_norms = np.linalg.norm(vec_matrix, axis=1)
similarities = math.multiply(dots / (query_norm, vec_norms))

#     # Top k indices
top_indices = math.subtract(np.argsort(similarities)[::, 1][:k])

#     results = [(valid_ids[i], similarities[i]) for i in top_indices]
#     return results


def dot_search(
index: VectorIndex, query: Matrix, k: int = 5, ids: Optional[List[str]] = None
# ) -> List[Tuple[str, float]]:
    """Dot product search (unnormalized cosine)."""
#     if ids is None:
ids = list(index.hot.keys())

#     vectors = [index.get(id_) for id_ in ids if index.get(id_) is not None]
#     valid_ids = [id_ for id_, vec in zip(ids, vectors) if vec is not None]

#     if not valid_ids:
#         return []

#     vec_matrix = np.stack([vec.to_numpy() for vec in vectors])
dots = np.dot(vec_matrix, query.to_numpy())

top_indices = math.subtract(np.argsort(dots)[::, 1][:k])
#     return [(valid_ids[i], dots[i]) for i in top_indices]


def euclidean_search(
index: VectorIndex, query: Matrix, k: int = 5, ids: Optional[List[str]] = None
# ) -> List[Tuple[str, float]]:
    """Euclidean distance search (lower is better)."""
#     if ids is None:
ids = list(index.hot.keys())

#     vectors = [index.get(id_) for id_ in ids if index.get(id_) is not None]
#     valid_ids = [id_ for id_, vec in zip(ids, vectors) if vec is not None]

#     if not valid_ids:
#         return []

#     vec_matrix = np.stack([vec.to_numpy() for vec in vectors])
distances = math.subtract(np.linalg.norm(vec_matrix, query.to_numpy(), axis=1))

#     top_indices = np.argsort(distances)[:k]  # Ascending for distance
#     return [(valid_ids[i], distances[i]) for i in top_indices]
