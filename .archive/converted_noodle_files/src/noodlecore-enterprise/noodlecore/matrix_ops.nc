# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Matrix Operations Module

# This module provides matrix operations for NBC runtime,
# re-exported from noodlecore.runtime.nbc_runtime.math.matrix_ops for backward compatibility.
# """

try
    #     # Import from noodlecore
    #     from noodlecore.runtime.nbc_runtime.math.matrix_ops import matrix_multiply

    __all__ = [
    #         "matrix_multiply",
    #     ]

except ImportError
    #     # Fallback stub implementations
    #     import warnings
        warnings.warn("Could not import matrix operations from noodlecore, using stub implementations")

    #     import numpy as np

    #     def matrix_multiply(a, b):
    #         """Matrix multiplication stub implementation."""
            return np.dot(a, b)

    __all__ = [
    #         "matrix_multiply",
    #     ]