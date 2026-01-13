# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# C FFI Bridge using ctypes for libmath.c integration.
# Supports matrix determinant as example; extend for matrix mul.
# """

import ctypes
import ctypes.POINTER,
import typing.Any,

import ..mathematical_objects.MathematicalObjectMapper


class CBridge
    #     """C FFI Bridge using ctypes."""

    #     def __init__(self):
    #         # Load libmath; assume compiled from examples/interop/libmath.c to libmath.so/dll
    #         lib_path = "examples/interop/libmath.so"  # Adjust for OS: .dll on Windows, .so on Linux
    #         try:
    self.libmath = ctypes.CDLL(lib_path)
    #         except OSError:
                raise ImportError(
    #                 f"libmath not found at {lib_path}. Compile examples/interop/libmath.c first."
    #             )

    #         # Define signatures for matrix mul (extend libmath.c if needed, but use determinant)
    self.libmath.matrix_multiply.argtypes = [
                POINTER(POINTER(c_double)),
                POINTER(POINTER(c_double)),
    #             c_int,
    #             c_int,
                POINTER(POINTER(c_double)),
    #         ]
    self.libmath.matrix_multiply.restype = None  # Void, modifies third arg

    #         # For determinant as example
    self.libmath.matrix_determinant.argtypes = [
                POINTER(POINTER(c_double)),
    #             c_int,
    #             c_int,
    #         ]
    self.libmath.matrix_determinant.restype = c_double

    #     def call_external(self, func: str, args: List[Any]) -> Any:
    #         """Call C function with matrix mul example."""
    #         if func == "matrix_multiply":
    #             if len(args) != 2:
                    raise ValueError("matrix_multiply requires two matrices")
    matrix_a, matrix_b = args
    #             if not isinstance(matrix_a, list) or not isinstance(matrix_b, list):
                    raise ValueError("Matrices must be 2D lists")
    #             rows, cols = len(matrix_a), len(matrix_a[0]) if matrix_a else 0
    #             if rows != len(matrix_b) or cols != len(matrix_b[0]):
                    raise ValueError("Matrices must have same dimensions")
    #             # Convert to C arrays (assume square for simplicity)
    c_matrix_a = math.multiply((ctypes.POINTER(c_double), rows)())
    c_matrix_b = math.multiply((ctypes.POINTER(c_double), rows)())
    #             for i in range(rows):
    #                 c_matrix_a[i] = (c_double * cols)(*[float(x) for x in matrix_a[i]])
    #                 c_matrix_b[i] = (c_double * cols)(*[float(x) for x in matrix_b[i]])
    result_matrix = math.multiply((ctypes.POINTER(c_double), rows)())
    #             for i in range(rows):
    result_matrix[i] = math.multiply((c_double, cols)())
                self.libmath.matrix_multiply(
    #                 c_matrix_a, c_matrix_b, rows, cols, result_matrix
    #             )
    #             # Convert back to Python list
    #             result = [[result_matrix[i][j] for j in range(cols)] for i in range(rows)]
    #             return result
    #         elif func == "matrix_determinant":
    #             if len(args) != 3:
                    raise ValueError("matrix_determinant requires matrix, rows, cols")
    matrix, rows, cols = args[0], int(args[1]), int(args[2])
    #             if not isinstance(matrix, list) or not all(
    #                 isinstance(row, list) for row in matrix
    #             ):
                    raise ValueError("Matrix must be 2D list")
    #             # Convert to C array
    c_matrix = math.multiply((ctypes.POINTER(c_double), rows)())
    #             for i in range(rows):
    row_array = math.multiply((c_double, cols)(*matrix[i]))
    c_matrix[i] = row_array
                return self.libmath.matrix_determinant(c_matrix, rows, cols)
    #         else:
                raise ValueError(f"Unknown C function: {func}")

    #     def serialize_args(
    #         self, args: List[Any], mapper: MathematicalObjectMapper
    #     ) -> List[Any]:
    #         """Serialize args for C (convert matrices to lists if needed)."""
    serialized_args = []
    #         for arg in args:
    #             if isinstance(arg, mapper.get_mathematical_object_class()):
                    serialized_args.append(mapper.to_dict(arg))
    #             else:
                    serialized_args.append(arg)
    #         return serialized_args

    #     def deserialize_result(
    self, result: Any, mapper: MathematicalObjectMapper, expected_type: str = None
    #     ) -> Any:
    #         """Deserialize result from C."""
    #         if expected_type == "matrix":
    #             # Return as list for mapper to handle as MathematicalObject if needed
    #             return result
    #         return result
