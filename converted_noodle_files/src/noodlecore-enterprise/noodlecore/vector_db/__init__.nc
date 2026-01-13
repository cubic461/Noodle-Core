# Converted from Python to NoodleCore
# Original file: noodle-core

# """Vector Database module for Noodle Core.

# Provides storage and search for embeddings using matrix runtime.
# """

__version__ = "0.1.0"

import .search.cosine_search
import .storage.VectorIndex

__all__ = ["VectorIndex", "cosine_search"]
