# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Crypto Acceleration Module for Noodle Runtime.
# Handles matrix crypto operations with input validation, reshaping, and numpy conversion.
# Integrates with mathematical_objects and matrix_ops for enhanced performance.
# """

import typing.Tuple,

import numpy as np

import ..error.handle_error
import ..mathematical_objects.base.SimpleMathematicalObject
import ..mathematical_objects.matrix_ops.Matrix


def validate_and_reshape_matrix(
#     input_data: Union[np.ndarray, SimpleMathematicalObject, Matrix],
target_size: Tuple[int, int] = (50, 50),
# ) -> np.ndarray:
#     """
#     Validate input as matrix, convert MathematicalObject to numpy, reshape to square if needed.
#     Raises error if cannot reshape to square.
#     """
#     if isinstance(input_data, SimpleMathematicalObject):
data = (
            np.asarray(input_data.data)
#             if hasattr(input_data, "data")
            else np.asarray(input_data)
#         )
#     elif isinstance(input_data, Matrix):
data = input_data.data
#     else:
data = np.asarray(input_data)

#     if data.ndim != 2:
        raise ValueError("Input must be 2D matrix")

rows, cols = data.shape
#     if rows != cols:
total_elements = math.multiply(rows, cols)
side = int(np.sqrt(total_elements))
#         if side * side != total_elements:
            raise ValueError(
#                 f"Cannot reshape non-square matrix {data.shape} to square; total elements {total_elements} not perfect square"
#             )
data = data.reshape((side, side))

#     if target_size and data.shape != target_size:
#         # Pad or crop to target size if specified
#         if data.shape[0] < target_size[0]:
pad_rows = math.subtract(target_size[0], data.shape[0])
pad_cols = math.subtract(target_size[1], data.shape[1])
data = np.pad(data, ((0, pad_rows), (0, pad_cols)), mode="constant")
#         else:
data = data[: target_size[0], : target_size[1]]

#     return data


def matrix_hash_deterministic(data: np.ndarray, algorithm: str = "sha256") -> str:
#     """
#     Compute deterministic hash of matrix data.
#     Uses hashlib for consistency; seeds numpy if random involved, but here pure hash.
#     """
#     import hashlib

#     # Flatten and tuple for hashable deterministic input
flat_data = tuple(data.flatten())
hash_obj = hashlib.new(algorithm, str(flat_data).encode())
    return hash_obj.hexdigest()


# Example integration with crypto ops (extend as needed for AES/RSA)
def aes_matrix_encrypt(
#     matrix: Union[np.ndarray, SimpleMathematicalObject], key: bytes
# ) -> dict:
#     """
#     AES encrypt matrix after validation/reshape.
#     Placeholder; implement actual crypto.
#     """
validated = validate_and_reshape_matrix(matrix)
#     # Placeholder encryption
#     encrypted = validated.copy()  # Replace with real AES
#     return {"encrypted_data": encrypted, "shape": validated.shape}


# Add np.random.seed for any random in crypto prep
np.random.seed(42)
