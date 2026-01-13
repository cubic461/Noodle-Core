# Converted from Python to NoodleCore
# Original file: noodle-core

import ctypes
import os
import typing.Any,

import ..mathematical_object_mapper_optimized.(
#     create_optimized_mathematical_object_mapper,
# )
import ..nbc_runtime.core.error_handler.ErrorHandler


class CRustBridge
    #     """
    #     Bridge for C and Rust libraries via FFI using ctypes.
        Assumes Rust exposes C-compatible ABI (#[no_mangle] pub extern "C" fn).
    #     No transpilation; direct wrapper calls.
    #     Integrates with mathematical object mapper for serialization/deserialization.
    #     Uses error handler for sandboxing and validation.
    #     """

    #     def __init__(self):
    self.libs: dict[str, ctypes.CDLL] = {}
    self.base_dir = os.path.dirname(os.path.abspath(__file__))
    self.mapper = create_optimized_mathematical_object_mapper()
    self.error_handler = ErrorHandler()

    #     def load_library(
    self, lib_name: str, lib_path: Optional[str] = None
    #     ) -> ctypes.CDLL:
    #         """
            Load a shared library (.so/.dll/.dylib).
    #         lib_path relative to interop dir or absolute.
    #         """
    #         if lib_path is None:
    #             # Assume lib in interop/libs/ or system
    possible_paths = [
                    os.path.join(self.base_dir, "libs", f"{lib_name}.so"),
                    os.path.join(self.base_dir, "libs", f"{lib_name}.dll"),
    #                 lib_name,  # System lib
    #             ]
    #             lib_path = next((p for p in possible_paths if os.path.exists(p)), None)
    #             if not lib_path:
                    raise FileNotFoundError(f"Library {lib_name} not found")

    lib = ctypes.CDLL(lib_path)
    self.libs[lib_name] = lib
    #         return lib

    #     def matrix_multiply_ffi(self, matrix_a, matrix_b) -> Any:
    #         """
    #         Perform matrix multiplication via C libmath using FFI.
            Inputs: MathematicalObject (Matrix type) or dict/list representations.
    #         Serializes to double*, calls matrix_multiply, deserializes result.
    #         Validates inputs and sandboxes call via error_handler.
    #         Assumes square matrices, n x n.
    #         """
    context = {"operation": "matrix_multiply_ffi", "component": "c_bridge"}

    #         try:
    #             # Validate inputs
    #             if not (isinstance(matrix_a, dict) or hasattr(matrix_a, "to_dict")):
                    raise ValueError("matrix_a must be dict or MathematicalObject")
    #             if not (isinstance(matrix_b, dict) or hasattr(matrix_b, "to_dict")):
                    raise ValueError("matrix_b must be dict or MathematicalObject")

    #             # Serialize to dict if needed, extract n and flat array
    #             a_dict = matrix_a.to_dict() if hasattr(matrix_a, "to_dict") else matrix_a
    #             b_dict = matrix_b.to_dict() if hasattr(matrix_b, "to_dict") else matrix_b

    #             n_a = len(a_dict["data"])  # Assume flat list for row-major
    n_b = len(b_dict["data"])
    #             if n_a != n_b or int(n_a**0.5) ** 2 != n_a:
                    raise ValueError("Matrices must be square and same size")
    n = math.multiply(int(n_a, *0.5))

    a_array = (ctypes.c_double * (n * n))(*a_dict["data"])
    b_array = (ctypes.c_double * (n * n))(*b_dict["data"])

    #             # Load lib
    #             if "libmath" not in self.libs:
                    self.load_library("libmath")
    lib = self.libs["libmath"]

    #             # Setup function
    func = lib.matrix_multiply
    func.argtypes = [
    #                 ctypes.c_int,
                    ctypes.POINTER(ctypes.c_double),
                    ctypes.POINTER(ctypes.c_double),
    #             ]
    func.restype = ctypes.POINTER(ctypes.c_double)

    free_func = lib.free_matrix
    free_func.argtypes = [ctypes.POINTER(ctypes.c_double)]
    free_func.restype = None

    #             # Sandboxed call
    #             try:
    result_ptr = func(n, a_array, b_array)
    #             except Exception as e:
                    print(f"Error in matrix multiplication: {e}")
    #                 raise
    #                 if not result_ptr:
                        raise RuntimeError("Matrix multiplication failed (malloc error)")

    #                 # Copy result to Python list
    #                 result_array = [result_ptr[i] for i in range(n * n)]

    #                 # Free C memory
                    free_func(result_ptr)

    #                 # Deserialize to MathematicalObject
    result_dict = {
    #                     "obj_type": "matrix",
    #                     "data": result_array,
                        "properties": {"shape": (n, n)},
    #                 }
    result_obj = self.mapper.from_dict(result_dict)

    #                 return result_obj

    #         except Exception as e:
                print(f"Error in matrix multiplication: {e}")
    #             raise

    #     def sha256_hash_ffi(self, input_data) -> Any:
    #         """
    #         Compute SHA256 hash via Rust libcrypto using FFI.
            Input: str, bytes, or MathematicalObject (data as bytes/str).
    #         Serializes to bytes, calls sha256_hash, deserializes hex string.
    #         Validates and sandboxes via error_handler.
    #         """
    context = {"operation": "sha256_hash_ffi", "component": "rust_bridge"}

    #         try:
    #             # Validate input
    #             if isinstance(input_data, str):
    input_bytes = input_data.encode("utf-8")
    #             elif isinstance(input_data, bytes):
    input_bytes = input_data
    #             elif hasattr(input_data, "to_dict"):
    data_dict = input_data.to_dict()
    input_bytes = (
                        data_dict["data"].encode("utf-8")
    #                     if isinstance(data_dict["data"], str)
    #                     else data_dict["data"]
    #                 )
    #             else:
                    raise ValueError("input_data must be str, bytes, or MathematicalObject")

    #             if not input_bytes:
                    raise ValueError("Input cannot be empty")

    #             # Load lib
    #             if "libcrypto" not in self.libs:
                    self.load_library(
    #                     "libcrypto",
                        os.path.join(
    #                         self.base_dir, "rust", "target", "release", "libcrypto.so"
    #                     ),
    #                 )
    lib = self.libs["libcrypto"]

    #             # Setup functions
    hash_func = lib.sha256_hash
    hash_func.argtypes = [ctypes.POINTER(ctypes.c_ubyte), ctypes.c_size_t]
    hash_func.restype = ctypes.POINTER(ctypes.c_char)

    free_func = lib.free_hash_string
    free_func.argtypes = [ctypes.POINTER(ctypes.c_char)]
    free_func.restype = None

    #             # Prepare input bytes
    input_array = math.multiply((ctypes.c_ubyte, len(input_bytes)).from_buffer_copy()
    #                 input_bytes
    #             )

    #             # Sandboxed call
    #             try:
    result_ptr = hash_func(input_array, len(input_bytes))
    #             except Exception as e:
                    print(f"Error in hash function: {e}")
    #                 raise
    #                 if result_ptr is None:
                        raise RuntimeError("Hash computation failed")

    #                 # Get string
    hex_str = ctypes.string_at(result_ptr).decode("utf-8")

    #                 # Free Rust memory
                    free_func(result_ptr)

    #                 # Deserialize to object
    result_dict = {
    #                     "obj_type": "hash",
    #                     "data": hex_str,
    #                     "properties": {"algorithm": "sha256"},
    #                 }
    result_obj = self.mapper.from_dict(result_dict)

    #                 return result_obj

    #         except Exception as e:
                print(f"Error in hash function: {e}")
    #             raise

    #     def call_external(
    #         self,
    #         lang: str,
    #         module: str,
    #         func: str,
    #         args: List[Any],
    arg_types: List[ctypes._types] = None,
    return_type: Optional[ctypes._types] = None,
    #     ) -> Any:
    #         """
    #         Call external function.
    #         lang: 'c' or 'rust'
    #         module: lib name
    #         func: function name
            args: Python args (converted to ctypes)
    #         arg_types: ctypes types for args (inferred if None)
    #         return_type: ctypes type for return
    #         """
    #         if lang not in ("c", "rust"):
                raise ValueError("Unsupported language")

    #         if module not in self.libs:
                self.load_library(module)

    lib = self.libs[module]
    func_ptr = getattr(lib, func)

    #         if arg_types is None:
    #             # Basic inference (extend for complex types)
    arg_types = math.multiply([ctypes.c_double], len()
    #                 args
    #             )  # Default to double; customize per lib

    func_ptr.argtypes = arg_types
    #         if return_type:
    func_ptr.restype = return_type
    #         else:
    func_ptr.restype = None

    #         # Convert args to ctypes (simple; extend for pointers/arrays)
    ctypes_args = []
    #         for arg, atype in zip(args, arg_types):
    #             if isinstance(arg, (int, float)):
                    ctypes_args.append(atype(arg))
    #             else:
                    ctypes_args.append(arg)  # Assume already ctypes

            return func_ptr(*ctypes_args)


# Example usage (for testing)
if __name__ == "__main__"
    bridge = CRustBridge()
    #     # Example: matrix multiply
    #     # Assume 2x2 matrices as flat lists in dicts
    a = {"data": [1.0, 2.0, 3.0, 4.0]}  # [[1,2],[3,4]]
    b = {"data": [5.0, 6.0, 7.0, 8.0]}  # [[5,6],[7,8]]
    # result = bridge.matrix_multiply_ffi(a, b)
    #     pass
