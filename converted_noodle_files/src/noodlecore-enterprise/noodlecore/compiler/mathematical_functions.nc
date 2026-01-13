# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Mathematical functions library for Noodle compiler.
# Provides mathematical functions that can operate on scalars, vectors, matrices, and tensors.
# """

import typing.Union,
import math
import numpy as np
import functools.wraps
import .mathematical_objects.matrix.Matrix
import .mathematical_objects.tensor.Tensor
import .mathematical_objects.vector.Vector


class MathFunctionError(Exception)
    #     """Exception raised for mathematical function errors"""
    #     pass


def broadcast_arguments(func: Callable) -> Callable:
#     """Decorator to handle broadcasting of arguments"""
    @wraps(func)
#     def wrapper(*args, **kwargs):
#         # Check if arguments are mathematical objects
#         math_objects = [arg for arg in args if isinstance(arg, (Matrix, Tensor, Vector))]

#         if not math_objects:
#             # No mathematical objects, call original function
            return func(*args, **kwargs)

#         # For now, we'll handle simple cases where all math objects have the same shape
#         # In a more sophisticated implementation, we'd need proper broadcasting logic
#         if len(set(obj.shape for obj in math_objects)) > 1:
#             raise MathFunctionError("Arguments with different shapes are not supported yet")

#         # Call the function
        return func(*args, **kwargs)

#     return wrapper


class MathFunctions
    #     """Collection of mathematical functions that can operate on multiple data types"""

    #     @staticmethod
    #     @broadcast_arguments
    #     def abs(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Absolute value function"""
    #         if isinstance(x, (int, float)):
                return abs(x)
    #         elif isinstance(x, Vector):
                return x.abs()
    #         elif isinstance(x, Matrix):
                return x.abs()
    #         elif isinstance(x, Tensor):
                return x.abs()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for abs: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def sqrt(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Square root function"""
    #         if isinstance(x, (int, float)):
                return math.sqrt(x)
    #         elif isinstance(x, Vector):
                return x.sqrt()
    #         elif isinstance(x, Matrix):
                return x.sqrt()
    #         elif isinstance(x, Tensor):
                return x.sqrt()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for sqrt: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def exp(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Exponential function"""
    #         if isinstance(x, (int, float)):
                return math.exp(x)
    #         elif isinstance(x, Vector):
                return x.exp()
    #         elif isinstance(x, Matrix):
                return x.exp()
    #         elif isinstance(x, Tensor):
                return x.exp()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for exp: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def log(x: Union[int, float, Vector, Matrix, Tensor], base: Optional[float] = None) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Logarithm function"""
    #         if isinstance(x, (int, float)):
    #             if base is None:
                    return math.log(x)
    #             else:
                    return math.log(x, base)
    #         elif isinstance(x, Vector):
                return x.log(base)
    #         elif isinstance(x, Matrix):
                return x.log(base)
    #         elif isinstance(x, Tensor):
                return x.log(base)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for log: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def sin(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Sine function"""
    #         if isinstance(x, (int, float)):
                return math.sin(x)
    #         elif isinstance(x, Vector):
                return x.sin()
    #         elif isinstance(x, Matrix):
                return x.sin()
    #         elif isinstance(x, Tensor):
                return x.sin()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for sin: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cos(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Cosine function"""
    #         if isinstance(x, (int, float)):
                return math.cos(x)
    #         elif isinstance(x, Vector):
                return x.cos()
    #         elif isinstance(x, Matrix):
                return x.cos()
    #         elif isinstance(x, Tensor):
                return x.cos()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for cos: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def tan(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Tangent function"""
    #         if isinstance(x, (int, float)):
                return math.tan(x)
    #         elif isinstance(x, Vector):
                return x.tan()
    #         elif isinstance(x, Matrix):
                return x.tan()
    #         elif isinstance(x, Tensor):
                return x.tan()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for tan: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def asin(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Arcsine function"""
    #         if isinstance(x, (int, float)):
                return math.asin(x)
    #         elif isinstance(x, Vector):
                return x.asin()
    #         elif isinstance(x, Matrix):
                return x.asin()
    #         elif isinstance(x, Tensor):
                return x.asin()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for asin: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def acos(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Arccosine function"""
    #         if isinstance(x, (int, float)):
                return math.acos(x)
    #         elif isinstance(x, Vector):
                return x.acos()
    #         elif isinstance(x, Matrix):
                return x.acos()
    #         elif isinstance(x, Tensor):
                return x.acos()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for acos: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def atan(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Arctangent function"""
    #         if isinstance(x, (int, float)):
                return math.atan(x)
    #         elif isinstance(x, Vector):
                return x.atan()
    #         elif isinstance(x, Matrix):
                return x.atan()
    #         elif isinstance(x, Tensor):
                return x.atan()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for atan: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def sinh(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Hyperbolic sine function"""
    #         if isinstance(x, (int, float)):
                return math.sinh(x)
    #         elif isinstance(x, Vector):
                return x.sinh()
    #         elif isinstance(x, Matrix):
                return x.sinh()
    #         elif isinstance(x, Tensor):
                return x.sinh()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for sinh: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cosh(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Hyperbolic cosine function"""
    #         if isinstance(x, (int, float)):
                return math.cosh(x)
    #         elif isinstance(x, Vector):
                return x.cosh()
    #         elif isinstance(x, Matrix):
                return x.cosh()
    #         elif isinstance(x, Tensor):
                return x.cosh()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for cosh: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def tanh(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Hyperbolic tangent function"""
    #         if isinstance(x, (int, float)):
                return math.tanh(x)
    #         elif isinstance(x, Vector):
                return x.tanh()
    #         elif isinstance(x, Matrix):
                return x.tanh()
    #         elif isinstance(x, Tensor):
                return x.tanh()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for tanh: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def round(x: Union[int, float, Vector, Matrix, Tensor], decimals: int = 0) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Round function"""
    #         if isinstance(x, (int, float)):
                return round(x, decimals)
    #         elif isinstance(x, Vector):
                return x.round(decimals)
    #         elif isinstance(x, Matrix):
                return x.round(decimals)
    #         elif isinstance(x, Tensor):
                return x.round(decimals)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for round: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def floor(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Floor function"""
    #         if isinstance(x, (int, float)):
                return math.floor(x)
    #         elif isinstance(x, Vector):
                return x.apply(math.floor)
    #         elif isinstance(x, Matrix):
                return x.apply(math.floor)
    #         elif isinstance(x, Tensor):
                return x.apply(math.floor)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for floor: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def ceil(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Ceiling function"""
    #         if isinstance(x, (int, float)):
                return math.ceil(x)
    #         elif isinstance(x, Vector):
                return x.apply(math.ceil)
    #         elif isinstance(x, Matrix):
                return x.apply(math.ceil)
    #         elif isinstance(x, Tensor):
                return x.apply(math.ceil)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for ceil: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def sign(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Sign function"""
    #         if isinstance(x, (int, float)):
    #             if x > 0:
    #                 return 1
    #             elif x < 0:
    #                 return -1
    #             else:
    #                 return 0
    #         elif isinstance(x, Vector):
                return x.sign()
    #         elif isinstance(x, Matrix):
                return x.sign()
    #         elif isinstance(x, Tensor):
                return x.sign()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for sign: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def clip(x: Union[int, float, Vector, Matrix, Tensor], min_val: Any, max_val: Any) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Clip function"""
    #         if isinstance(x, (int, float)):
                return max(min(x, max_val), min_val)
    #         elif isinstance(x, Vector):
                return x.clip(min_val, max_val)
    #         elif isinstance(x, Matrix):
                return x.clip(min_val, max_val)
    #         elif isinstance(x, Tensor):
                return x.clip(min_val, max_val)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for clip: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def power(x: Union[int, float, Vector, Matrix, Tensor], exponent: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
    #         """Power function"""
    #         if isinstance(x, (int, float)) and isinstance(exponent, (int, float)):
    #             return x ** exponent
    #         elif isinstance(x, Vector):
    #             if isinstance(exponent, (int, float)):
                    return x.elementwise_power(exponent)
    #             else:
                    return x.power(exponent)
    #         elif isinstance(x, Matrix):
    #             if isinstance(exponent, (int, float)):
                    return x.power(exponent)
    #             else:
                    raise MathFunctionError("Matrix to matrix power is not implemented")
    #         elif isinstance(x, Tensor):
    #             if isinstance(exponent, (int, float)):
                    return x.pow(exponent)
    #             else:
                    return x.pow(exponent)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for power: {type(x)}, {type(exponent)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def reciprocal(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
            """Reciprocal function (1/x)"""
    #         if isinstance(x, (int, float)):
    #             return 1.0 / x
    #         elif isinstance(x, Vector):
                return x.apply(lambda val: 1.0 / val)
    #         elif isinstance(x, Matrix):
                return x.apply(lambda val: 1.0 / val)
    #         elif isinstance(x, Tensor):
                return x.apply(lambda val: 1.0 / val)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for reciprocal: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def square(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
            """Square function (x^2)"""
    #         if isinstance(x, (int, float)):
    #             return x ** 2
    #         elif isinstance(x, Vector):
                return x.elementwise_power(2)
    #         elif isinstance(x, Matrix):
                return x.power(2)
    #         elif isinstance(x, Tensor):
                return x.pow(2)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for square: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cube(x: Union[int, float, Vector, Matrix, Tensor]) -> Union[int, float, Vector, Matrix, Tensor]:
            """Cube function (x^3)"""
    #         if isinstance(x, (int, float)):
    #             return x ** 3
    #         elif isinstance(x, Vector):
                return x.elementwise_power(3)
    #         elif isinstance(x, Matrix):
                return x.power(3)
    #         elif isinstance(x, Tensor):
                return x.pow(3)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for cube: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def norm(x: Union[Vector, Matrix, Tensor], ord: Optional[Union[int, float, str]] = None,
    axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Norm function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("norm with axis is not supported for Vector")
    return x.norm(ord = ord)
    #         elif isinstance(x, Matrix):
    #             if axis is None:
    #                 # Frobenius norm
                    return x.frobenius_norm()
    #             else:
    return x.norm(ord = ord, axis=axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.norm(ord = ord, axis=axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for norm: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def trace(x: Matrix) -> Any:
            """Trace function (sum of diagonal elements)"""
    #         if isinstance(x, Matrix):
                return x.trace()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for trace: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def det(x: Matrix) -> Any:
    #         """Determinant function"""
    #         if isinstance(x, Matrix):
                return x.determinant()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for det: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def inv(x: Matrix) -> Matrix:
    #         """Inverse function"""
    #         if isinstance(x, Matrix):
                return x.inverse()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for inv: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def eigvals(x: Matrix) -> Tensor:
    #         """Eigenvalues function"""
    #         if isinstance(x, Matrix):
    eigenvalues, _ = x.eigenvalues()
    #             return eigenvalues
    #         else:
    #             raise MathFunctionError(f"Unsupported type for eigvals: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def eig(x: Matrix) -> Tuple[Tensor, Tensor]:
    #         """Eigendecomposition function"""
    #         if isinstance(x, Matrix):
                return x.eig()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for eig: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def svd(x: Matrix, full_matrices: bool = True, compute_uv: bool = True) -> Union[Tensor, Tuple[Tensor, Tensor, Tensor]]:
    #         """Singular Value Decomposition function"""
    #         if isinstance(x, Matrix):
    return x.svd(full_matrices = full_matrices, compute_uv=compute_uv)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for svd: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def qr(x: Matrix, mode: str = 'reduced') -> Tuple[Matrix, Matrix]:
    #         """QR Decomposition function"""
    #         if isinstance(x, Matrix):
    Q, R = x.qr_decomposition()
    #             return Q, R
    #         else:
    #             raise MathFunctionError(f"Unsupported type for qr: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cholesky(x: Matrix) -> Matrix:
    #         """Cholesky Decomposition function"""
    #         if isinstance(x, Matrix):
                return x.cholesky_decomposition()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for cholesky: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def lu(x: Matrix) -> Tuple[Matrix, Matrix, Matrix]:
    #         """LU Decomposition function"""
    #         if isinstance(x, Matrix):
    P, L, U = x.lu_decomposition()
    #             return P, L, U
    #         else:
    #             raise MathFunctionError(f"Unsupported type for lu: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def solve(A: Matrix, b: Union[Matrix, Vector]) -> Union[Matrix, Vector]:
    #         """Linear system solver"""
    #         if isinstance(A, Matrix):
    #             if isinstance(b, Matrix):
                    return A.solve(b)
    #             elif isinstance(b, Vector):
    #                 # Convert vector to matrix for solving
    b_matrix = b.to_matrix(orientation='column')
    result_matrix = A.solve(b_matrix)
                    return Vector.from_tensor(result_matrix.to_tensor().reshape((result_matrix.shape[0],)))
    #             else:
    #                 raise MathFunctionError(f"Unsupported type for b: {type(b)}")
    #         else:
    #             raise MathFunctionError(f"Unsupported type for A: {type(A)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def lstsq(A: Matrix, b: Union[Matrix, Vector], rcond: Optional[float] = None) -> Union[Matrix, Vector]:
    #         """Least squares solver"""
    #         if isinstance(A, Matrix):
    #             if isinstance(b, Matrix):
                    return A.lstsq(b)
    #             elif isinstance(b, Vector):
    #                 # Convert vector to matrix for solving
    b_matrix = b.to_matrix(orientation='column')
    result_matrix = A.lstsq(b_matrix)
                    return Vector.from_tensor(result_matrix.to_tensor().reshape((result_matrix.shape[0],)))
    #             else:
    #                 raise MathFunctionError(f"Unsupported type for b: {type(b)}")
    #         else:
    #             raise MathFunctionError(f"Unsupported type for A: {type(A)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def dot(a: Union[Vector, Matrix], b: Union[Vector, Matrix]) -> Union[float, Matrix]:
    #         """Dot product function"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
                return a.dot(b)
    #         elif isinstance(a, Matrix) and isinstance(b, Matrix):
                return a.matmul(b)
    #         elif isinstance(a, Vector) and isinstance(b, Matrix):
    #             # Vector-matrix multiplication
    return a.to_matrix(orientation = 'row').matmul(b).to_vector()
    #         elif isinstance(a, Matrix) and isinstance(b, Vector):
    #             # Matrix-vector multiplication
    return a.matmul(b.to_matrix(orientation = 'column')).to_vector()
    #         else:
    #             raise MathFunctionError(f"Unsupported types for dot: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cross(a: Vector, b: Vector) -> Vector:
    #         """Cross product function"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
                return a.cross(b)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for cross: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def outer(a: Vector, b: Vector) -> Matrix:
    #         """Outer product function"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
                return a.outer(b)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for outer: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def vander(x: Vector, N: Optional[int] = None, increasing: bool = False) -> Matrix:
    #         """Vandermonde matrix"""
    #         if isinstance(x, Vector):
    data = x.data
    #             N = N if N is not None else len(data)

    vander_data = []
    #             for x_i in data:
    #                 row = [x_i ** (N - 1 - i) if not increasing else x_i ** i for i in range(N)]
                    vander_data.append(row)

                return Matrix(vander_data, MatrixProperties((len(data), N)))
    #         else:
    #             raise MathFunctionError(f"Unsupported type for vander: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def hadamard(a: Union[Vector, Matrix, Tensor], b: Union[Vector, Matrix, Tensor]) -> Union[Vector, Matrix, Tensor]:
            """Hadamard product (element-wise multiplication)"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
                return a.elementwise_multiply(b)
    #         elif isinstance(a, Matrix) and isinstance(b, Matrix):
                return a.hadamard_product(b)
    #         elif isinstance(a, Tensor) and isinstance(b, Tensor):
                return a.multiply(b)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for hadamard: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def kronecker(a: Union[Vector, Matrix], b: Union[Vector, Matrix]) -> Matrix:
    #         """Kronecker product"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
    #             # Convert vectors to matrices for Kronecker product
    a_matrix = a.to_matrix(orientation='column')
    b_matrix = b.to_matrix(orientation='column')
                return a_matrix.kronecker_product(b_matrix)
    #         elif isinstance(a, Matrix) and isinstance(b, Matrix):
                return a.kronecker_product(b)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for kronecker: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def khatri_rao(a: Matrix, b: Matrix) -> Matrix:
    #         """Khatri-Rao product"""
            return a.khatri_rao_product(b)

    #     @staticmethod
    #     @broadcast_arguments
    #     def sum(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Sum function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("sum with axis is not supported for Vector")
                return x.sum()
    #         elif isinstance(x, Matrix):
    return x.sum(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.sum(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for sum: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def mean(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Mean function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("mean with axis is not supported for Vector")
                return x.mean()
    #         elif isinstance(x, Matrix):
    return x.mean(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.mean(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for mean: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def std(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Standard deviation function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("std with axis is not supported for Vector")
                return x.std()
    #         elif isinstance(x, Matrix):
    return x.std(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.std(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for std: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def var(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Variance function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("var with axis is not supported for Vector")
                return x.var()
    #         elif isinstance(x, Matrix):
    return x.var(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.var(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for var: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def max(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Maximum function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("max with axis is not supported for Vector")
                return x.max()
    #         elif isinstance(x, Matrix):
    return x.max(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.max(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for max: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def min(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[float, Vector, Matrix, Tensor]:)
    #         """Minimum function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("min with axis is not supported for Vector")
                return x.min()
    #         elif isinstance(x, Matrix):
    return x.min(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.min(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for min: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def argmax(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[int, Vector, Matrix, Tensor]:)
    #         """Argmax function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("argmax with axis is not supported for Vector")
                return x.argmax()
    #         elif isinstance(x, Matrix):
    return x.argmax(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.argmax(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for argmax: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def argmin(x: Union[Vector, Matrix, Tensor], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = math.subtract(False), > Union[int, Vector, Matrix, Tensor]:)
    #         """Argmin function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("argmin with axis is not supported for Vector")
                return x.argmin()
    #         elif isinstance(x, Matrix):
    return x.argmin(axis = axis, keepdims=keepdims)
    #         elif isinstance(x, Tensor):
    return x.argmin(axis = axis, keepdims=keepdims)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for argmin: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cumsum(x: Union[Vector, Matrix], axis: Optional[int] = None) -> Union[Vector, Matrix]:
    #         """Cumulative sum function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("cumsum with axis is not supported for Vector")
                return x.cumsum()
    #         elif isinstance(x, Matrix):
    #             if axis is None:
    #                 # Flatten and compute cumulative sum
    flat_data = x.flatten()
    cumsum_data = []
    current_sum = 0
    #                 for val in flat_data:
    current_sum + = val
                        cumsum_data.append(current_sum)
                    return Matrix(cumsum_data, MatrixProperties((len(cumsum_data), 1)))
    #             else:
    #                 # Compute cumulative sum along specified axis
    result_data = []
    #                 if axis == 0:  # Column-wise
    #                     for j in range(x.cols):
    col_sum = 0
    #                         for i in range(x.rows):
    col_sum + = x.data[i][j]
                                result_data.append(col_sum)
                        return Matrix(result_data, MatrixProperties((x.rows, x.cols)))
    #                 elif axis == 1:  # Row-wise
    #                     for i in range(x.rows):
    row_sum = 0
    #                         for j in range(x.cols):
    row_sum + = x.data[i][j]
                                result_data.append(row_sum)
                        return Matrix(result_data, MatrixProperties((x.rows, x.cols)))
    #                 else:
    #                     raise MathFunctionError(f"Invalid axis for cumsum: {axis}")
    #         else:
    #             raise MathFunctionError(f"Unsupported type for cumsum: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def cumprod(x: Union[Vector, Matrix], axis: Optional[int] = None) -> Union[Vector, Matrix]:
    #         """Cumulative product function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("cumprod with axis is not supported for Vector")
                return x.cumprod()
    #         elif isinstance(x, Matrix):
    #             if axis is None:
    #                 # Flatten and compute cumulative product
    flat_data = x.flatten()
    cumprod_data = []
    current_product = 1
    #                 for val in flat_data:
    current_product * = val
                        cumprod_data.append(current_product)
                    return Matrix(cumprod_data, MatrixProperties((len(cumprod_data), 1)))
    #             else:
    #                 # Compute cumulative product along specified axis
    result_data = []
    #                 if axis == 0:  # Column-wise
    #                     for j in range(x.cols):
    col_product = 1
    #                         for i in range(x.rows):
    col_product * = x.data[i][j]
                                result_data.append(col_product)
                        return Matrix(result_data, MatrixProperties((x.rows, x.cols)))
    #                 elif axis == 1:  # Row-wise
    #                     for i in range(x.rows):
    row_product = 1
    #                         for j in range(x.cols):
    row_product * = x.data[i][j]
                                result_data.append(row_product)
                        return Matrix(result_data, MatrixProperties((x.rows, x.cols)))
    #                 else:
    #                     raise MathFunctionError(f"Invalid axis for cumprod: {axis}")
    #         else:
    #             raise MathFunctionError(f"Unsupported type for cumprod: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def diff(x: Union[Vector, Matrix], n: int = 1, axis: Optional[int] = None) -> Union[Vector, Matrix]:
    #         """Difference function"""
    #         if isinstance(x, Vector):
    #             if axis is not None:
    #                 raise MathFunctionError("diff with axis is not supported for Vector")
                return x.diff(n)
    #         elif isinstance(x, Matrix):
    #             if axis is None:
    #                 # Flatten and compute differences
    flat_data = x.flatten()
    result_data = []
    #                 for _ in range(n):
    new_data = []
    #                     for i in range(1, len(flat_data)):
                            new_data.append(flat_data[i] - flat_data[i - 1])
    flat_data = new_data
                    return Matrix(result_data, MatrixProperties((len(result_data), 1)))
    #             else:
    #                 # Compute differences along specified axis
    result_data = []
    #                 if axis == 0:  # Column-wise
    #                     for j in range(x.cols):
    #                         col_data = [x.data[i][j] for i in range(x.rows)]
    #                         for _ in range(n):
    new_col_data = []
    #                             for i in range(1, len(col_data)):
                                    new_col_data.append(col_data[i] - col_data[i - 1])
    col_data = new_col_data
                            result_data.extend(col_data)
                        return Matrix(result_data, MatrixProperties((x.rows - n, x.cols)))
    #                 elif axis == 1:  # Row-wise
    #                     for i in range(x.rows):
    row_data = x.data[i]
    #                         for _ in range(n):
    new_row_data = []
    #                             for j in range(1, len(row_data)):
                                    new_row_data.append(row_data[j] - row_data[j - 1])
    row_data = new_row_data
                            result_data.extend(row_data)
                        return Matrix(result_data, MatrixProperties((x.rows, x.cols - n)))
    #                 else:
    #                     raise MathFunctionError(f"Invalid axis for diff: {axis}")
    #         else:
    #             raise MathFunctionError(f"Unsupported type for diff: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def gradient(f: Union[Vector, Matrix], *varargs, **kwargs) -> Union[Vector, List[Vector], Matrix, List[Matrix]]:
    #         """Gradient function"""
    #         if isinstance(f, Vector):
                return f.gradient(**kwargs)
    #         elif isinstance(f, Matrix):
    #             if f.shape[0] == 1 or f.shape[1] == 1:
    #                 # Treat as vector if it's a row or column vector
    vector_data = f.flatten()
    vector = Vector(vector_data, VectorProperties((len(vector_data),)))
                    return vector.gradient(**kwargs)
    #             else:
    #                 # For 2D matrices, return gradient along both axes
    grad_x = []
    grad_y = []

                    # Gradient along rows (axis 1)
    #                 for i in range(f.rows):
    row = f.data[i]
    row_vector = Vector(row, VectorProperties((len(row),)))
    grad_row = math.multiply(row_vector.gradient(, *kwargs))
                        grad_x.append(grad_row.data)

                    # Gradient along columns (axis 0)
    #                 for j in range(f.cols):
    #                     col = [f.data[i][j] for i in range(f.rows)]
    col_vector = Vector(col, VectorProperties((len(col),)))
    grad_col = math.multiply(col_vector.gradient(, *kwargs))
                        grad_y.append(grad_col.data)

    #                 # Convert to matrices
    grad_x_matrix = Matrix(grad_x, MatrixProperties(f.shape))
    grad_y_matrix = Matrix(grad_y, MatrixProperties(f.shape))

    #                 return [grad_x_matrix, grad_y_matrix]
    #         else:
    #             raise MathFunctionError(f"Unsupported type for gradient: {type(f)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def laplacian(x: Matrix) -> Matrix:
    #         """Laplacian function"""
    #         if isinstance(x, Matrix):
                return x.laplacian()
    #         else:
    #             raise MathFunctionError(f"Unsupported type for laplacian: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def fft(x: Union[Vector, Tensor], axes: Optional[Union[int, Tuple[int, ...]]] = None) -> Union[Vector, Tensor]:
    #         """Fast Fourier Transform"""
    #         if isinstance(x, Vector):
    #             # Convert vector to tensor for FFT
    tensor_x = x.to_tensor()
    result_tensor = tensor_x.fft(axes=axes)
                return Vector.from_tensor(result_tensor)
    #         elif isinstance(x, Tensor):
    return x.fft(axes = axes)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for fft: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def ifft(x: Union[Vector, Tensor], axes: Optional[Union[int, Tuple[int, ...]]] = None) -> Union[Vector, Tensor]:
    #         """Inverse Fast Fourier Transform"""
    #         if isinstance(x, Vector):
    #             # Convert vector to tensor for IFFT
    tensor_x = x.to_tensor()
    result_tensor = tensor_x.ifft(axes=axes)
                return Vector.from_tensor(result_tensor)
    #         elif isinstance(x, Tensor):
    return x.ifft(axes = axes)
    #         else:
    #             raise MathFunctionError(f"Unsupported type for ifft: {type(x)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def convolve(a: Union[Vector, Matrix], b: Union[Vector, Matrix], mode: str = 'full') -> Union[Vector, Matrix]:
    #         """Convolution function"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
    return a.convolve(b, mode = mode)
    #         elif isinstance(a, Matrix) and isinstance(b, Matrix):
    return a.convolve(b, mode = mode)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for convolve: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def correlate(a: Union[Vector, Matrix], b: Union[Vector, Matrix], mode: str = 'full') -> Union[Vector, Matrix]:
    #         """Correlation function"""
    #         if isinstance(a, Vector) and isinstance(b, Vector):
    return a.correlate(b, mode = mode)
    #         elif isinstance(a, Matrix) and isinstance(b, Matrix):
    return a.correlate(b, mode = mode)
    #         else:
    #             raise MathFunctionError(f"Unsupported types for correlate: {type(a)}, {type(b)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def meshgrid(*xi: Vector, indexing: str = 'xy') -> List[Matrix]:
    #         """Create coordinate matrices from coordinate vectors"""
    #         if not all(isinstance(x, Vector) for x in xi):
                raise MathFunctionError("All arguments must be Vectors")

    #         # Get the number of dimensions
    ndim = len(xi)

    #         # Get the size of each dimension
    #         sizes = [x.size for x in xi]

    #         # Create the meshgrid
    grid = []
    #         for i in range(ndim):
    #             # Create a matrix with the current vector repeated along other dimensions
    data = []
    #             if indexing == 'xy':
    #                 # For 2D, swap the first two dimensions
    dims = math.add([1, 0], list(range(2, ndim)))
    #             else:
    #                 # Default indexing
    dims = list(range(ndim))

    #             for j in range(ndim):
    #                 if j == i:
    #                     # Repeat the current vector along the dimension
    #                     if dims[j] == 0:
    #                         # First dimension
    #                         for _ in range(sizes[1] if ndim > 1 else 1):
    #                             data.extend([x.data for x in xi[i]])
    #                     elif dims[j] == 1 and ndim > 1:
    #                         # Second dimension
    #                         for _ in range(sizes[0]):
    #                             data.extend([x.data for x in xi[i]])
    #                     else:
    #                         # Other dimensions (simplified for now)
    #                         data.extend([x.data for x in xi[i]])
    #                 else:
    #                     # Create a constant matrix with the vector's values
    #                     if dims[j] == 0:
    #                         # First dimension
    #                         for _ in range(sizes[1] if ndim > 1 else 1):
                                data.append(xi[j].data.copy())
    #                     elif dims[j] == 1 and ndim > 1:
    #                         # Second dimension
    #                         for _ in range(sizes[0]):
                                data.append(xi[j].data.copy())
    #                     else:
    #                         # Other dimensions (simplified for now)
                            data.append(xi[j].data.copy())

    #             # Convert to matrix
    #             if ndim == 2:
    #                 if i == 0:
    shape = (sizes[1], sizes[0])
    #                 else:
    shape = (sizes[0], sizes[1])
    #             else:
    shape = sizes

                grid.append(Matrix(data, MatrixProperties(shape)))

    #         return grid

    #     @staticmethod
    #     @broadcast_arguments
    #     def linspace(start: Union[int, float, Vector], stop: Union[int, float, Vector],
    num: int = math.subtract(50, endpoint: bool = True), > Union[Vector, List[Vector]]:)
    #         """Evenly spaced numbers over a specified interval"""
    #         if isinstance(start, (int, float)) and isinstance(stop, (int, float)):
    #             # Create a single vector
    #             if endpoint:
    step = math.subtract((stop, start) / (num - 1))
    #             else:
    step = math.subtract((stop, start) / num)

    #             data = [start + i * step for i in range(num)]
                return Vector(data, VectorProperties((num,)))
    #         elif isinstance(start, Vector) and isinstance(stop, Vector):
    #             if start.size != stop.size:
                    raise MathFunctionError("start and stop vectors must have the same size")

    #             # Create multiple vectors
    result_vectors = []
    #             for i in range(start.size):
    s = start.data[i]
    e = stop.data[i]

    #                 if endpoint:
    step = math.subtract((e, s) / (num - 1))
    #                 else:
    step = math.subtract((e, s) / num)

    #                 data = [s + j * step for j in range(num)]
                    result_vectors.append(Vector(data, VectorProperties((num,))))

    #             return result_vectors
    #         else:
    #             raise MathFunctionError(f"Unsupported types for linspace: {type(start)}, {type(stop)}")

    #     @staticmethod
    #     @broadcast_arguments
    #     def logspace(start: Union[int, float, Vector], stop: Union[int, float, Vector],
    num: int = math.subtract(50, base: float = 10.0, endpoint: bool = True), > Union[Vector, List[Vector]]:)
    #         """Evenly spaced numbers on a log scale"""
    #         if isinstance(start, (int, float)) and isinstance(stop, (int, float)):
    #             # Create a single vector
    #             if endpoint:
    log_start = math.multiply(start, math.log(base))
    log_stop = math.multiply(stop, math.log(base))
    step = math.subtract((log_stop, log_start) / (num - 1))
    #             else:
    log_start = math.multiply(start, math.log(base))
    log_stop = math.multiply(stop, math.log(base))
    step = math.subtract((log_stop, log_start) / num)

    #             data = [math.exp(log_start + i * step) for i in range(num)]
                return Vector(data, VectorProperties((num,)))
    #         elif isinstance(start, Vector) and isinstance(stop, Vector):
    #             if start.size != stop.size:
                    raise MathFunctionError("start and stop vectors must have the same size")

    #             # Create multiple vectors
    result_vectors = []
    #             for i in range(start.size):
    s = start.data[i]
    e = stop.data[i]

    #                 if endpoint:
    log_start = math.multiply(s, math.log(base))
    log_stop = math.multiply(e, math.log(base))
    step = math.subtract((log_stop, log_start) / (num - 1))
    #                 else:
    log_start = math.multiply(s, math.log(base))
    log_stop = math.multiply(e, math.log(base))
    step = math.subtract((log_stop, log_start) / num)

    #                 data = [math.exp(log_start + j * step) for j in range(num)]
                    result_vectors.append(Vector(data, VectorProperties((num,))))

    #             return result_vectors
    #         else:
                raise MathFunctionError(f"Unsupported types
