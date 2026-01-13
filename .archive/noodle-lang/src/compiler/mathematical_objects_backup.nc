# Converted from Python to NoodleCore
# Original file: src

# """
# Mathematical objects for Noodle language.
# Provides Matrix, Tensor, and Vector classes with operations.
# """

from dataclasses import dataclass
import enum.Enum
import typing.Any

import numpy as np

import .compiler.types.BasicType


class MatrixShapeError(Exception):""Exception raised for matrix shape mismatches"""

    #     pass


class TensorShapeError(Exception)
    #     """Exception raised for tensor shape mismatches"""

    #     pass


class VectorShapeError(Exception)
    #     """Exception raised for vector shape mismatches"""

    #     pass


class MatrixElementError(Exception)
    #     """Exception raised for matrix element access errors"""

    #     pass


class TensorElementError(Exception)
    #     """Exception raised for tensor element access errors"""

    #     pass


dataclass
class Matrix
    #     """
    #     Matrix class for Noodle language with 2D array operations.

    #     Supports common matrix operations like addition, multiplication,
    #     transpose, determinant, etc.
    #     """

    #     data: List[List[float]]
    #     rows: int
    #     cols: int
    dtype: str = "float"

    #     def __post_init__(self):
    #         # Validate matrix data
    #         if not self.data:
    #             self.data = [[0.0 for _ in range(self.cols)] for _ in range(self.rows)]

    #         # Check if data matches dimensions
    #         if len(self.data) != self.rows:
                raise MatrixShapeError(f"Expected {self.rows} rows, got {len(self.data)}")

    #         for i, row in enumerate(self.data):
    #             if len(row) != self.cols:
                    raise MatrixShapeError(
                        f"Row {i} expected {self.cols} columns, got {len(row)}"
    #                 )

    #         # Convert data to float if needed
    #         if self.dtype == "float":
    #             self.data = [[float(x) for x in row] for row in self.data]
    #         elif self.dtype == "int":
    #             self.data = [[int(x) for x in row] for row in self.data]

    #     @classmethod
    #     def zeros(cls, rows: int, cols: int, dtype: str = "float") -"Matrix"):
    #         """Create a matrix filled with zeros"""
    #         data = [[0.0 for _ in range(cols)] for _ in range(rows)]
            return cls(data, rows, cols, dtype)

    #     @classmethod
    #     def ones(cls, rows: int, cols: int, dtype: str = "float") -"Matrix"):
    #         """Create a matrix filled with ones"""
    #         data = [[1.0 for _ in range(cols)] for _ in range(rows)]
            return cls(data, rows, cols, dtype)

    #     @classmethod
    #     def identity(cls, size: int, dtype: str = "float") -"Matrix"):
    #         """Create an identity matrix"""
    #         data = [[0.0 for _ in range(size)] for _ in range(size)]
    #         for i in range(size):
    data[i][i] = 1.0
            return cls(data, size, size, dtype)

    #     @classmethod
    #     def diagonal(cls, values: List[float], dtype: str = "float") -"Matrix"):
    #         """Create a diagonal matrix from values"""
    size = len(values)
    #         data = [[0.0 for _ in range(size)] for _ in range(size)]
    #         for i, val in enumerate(values):
    data[i][i] = val
            return cls(data, size, size, dtype)

    #     @classmethod
    #     def from_numpy(cls, array: np.ndarray, dtype: str = "float") -"Matrix"):
    #         """Create a matrix from a numpy array"""
    #         if array.ndim != 2:
                raise MatrixShapeError("Array must be 2-dimensional")

    data = array.tolist()
            return cls(data, array.shape[0], array.shape[1], dtype)

    #     def to_numpy(self) -np.ndarray):
    #         """Convert matrix to numpy array"""
    return np.array(self.data, dtype = self.dtype)

    #     def copy(self) -"Matrix"):
    #         """Create a copy of the matrix"""
            return Matrix(
    #             [row.copy() for row in self.data], self.rows, self.cols, self.dtype
    #         )

    #     def transpose(self) -"Matrix"):
    #         """Return the transpose of the matrix"""
    transposed_data = [
    #             [self.data[j][i] for j in range(self.rows)] for i in range(self.cols)
    #         ]
            return Matrix(transposed_data, self.cols, self.rows, self.dtype)

    #     def __add__(self, other: Union["Matrix", float]) -"Matrix"):
    #         """Matrix addition or scalar addition"""
    #         if isinstance(other, Matrix):
    #             if self.rows != other.rows or self.cols != other.cols:
    #                 raise MatrixShapeError("Matrix dimensions must match for addition")

    result_data = [
    #                 [self.data[i][j] + other.data[i][j] for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)
    #         else:
    #             # Scalar addition
    result_data = [
    #                 [self.data[i][j] + other for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)

    #     def __sub__(self, other: Union["Matrix", float]) -"Matrix"):
    #         """Matrix subtraction or scalar subtraction"""
    #         if isinstance(other, Matrix):
    #             if self.rows != other.rows or self.cols != other.cols:
    #                 raise MatrixShapeError("Matrix dimensions must match for subtraction")

    result_data = [
    #                 [self.data[i][j] - other.data[i][j] for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)
    #         else:
    #             # Scalar subtraction
    result_data = [
    #                 [self.data[i][j] - other for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)

    #     def __mul__(self, other: Union["Matrix", float]) -"Matrix"):
    #         """Matrix multiplication or scalar multiplication"""
    #         if isinstance(other, Matrix):
    #             # Matrix multiplication
    #             if self.cols != other.rows:
                    raise MatrixShapeError(
    #                     f"Cannot multiply {self.rows}x{self.cols} matrix with {other.rows}x{other.cols} matrix"
    #                 )

    result_data = [
    #                 [
    #                     sum(self.data[i][k] * other.data[k][j] for k in range(self.cols))
    #                     for j in range(other.cols)
    #                 ]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, other.cols, self.dtype)
    #         else:
    #             # Scalar multiplication
    result_data = [
    #                 [self.data[i][j] * other for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)

    #     def __truediv__(self, other: Union["Matrix", float]) -"Matrix"):
    #         """Matrix division or scalar division"""
    #         if isinstance(other, Matrix):
    #             # Element-wise division
    #             if self.rows != other.rows or self.cols != other.cols:
                    raise MatrixShapeError(
    #                     "Matrix dimensions must match for element-wise division"
    #                 )

    result_data = [
    #                 [self.data[i][j] / other.data[i][j] for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)
    #         else:
    #             # Scalar division
    result_data = [
    #                 [self.data[i][j] / other for j in range(self.cols)]
    #                 for i in range(self.rows)
    #             ]
                return Matrix(result_data, self.rows, self.cols, self.dtype)

    #     def __matmul__(self, other: "Matrix") -"Matrix"):
            """Matrix multiplication (using @ operator)"""
            return self.__mul__(other)

    #     def __pow__(self, power: int) -"Matrix"):
            """Matrix power (using ** operator)"""
    #         if self.rows != self.cols:
    #             raise MatrixShapeError("Matrix must be square for power operation")

    result = self.copy()
    #         for _ in range(power - 1):
    result = result * self

    #         return result

    #     def __getitem__(self, key: Union[Tuple[int, int], int]) -Union[float, "Matrix"]):
    #         """Get element or submatrix"""
    #         if isinstance(key, tuple):
    i, j = key
    #             if isinstance(i, slice) or isinstance(j, slice):
    #                 # Return submatrix
    #                 rows = self.data[i] if isinstance(i, slice) else [self.data[i]]
    submatrix_data = [
    #                     row[j] if isinstance(j, slice) else [row[j]] for row in rows
    #                 ]
    rows_sub = len(submatrix_data)
    #                 cols_sub = len(submatrix_data[0]) if rows_sub 0 else 0
                    return Matrix(submatrix_data, rows_sub, cols_sub, self.dtype)
    #             else):
    #                 # Return single element
    #                 return self.data[i][j]
    #         else:
    #             # Return row as vector
    #             return Vector([self.data[key][j] for j in range(self.cols)], self.cols)

    #     def __setitem__(self, key: Tuple[int, int], value: float):
    #         """Set element value"""
    i, j = key
    self.data[i][j] = value

    #     def __str__(self) -str):
    #         """String representation of the matrix"""
            return f"Matrix({self.rows}x{self.cols}, {self.dtype})\n" + "\n".join(
    #             "[" + ", ".join(f"{x:.3f}" for x in row) + "]" for row in self.data
    #         )

    #     def __repr__(self) -str):
    #         """String representation for debugging"""
    return f"Matrix({self.rows}x{self.cols}, dtype = {self.dtype})"

    #     def determinant(self) -float):
    #         """Calculate the determinant of the matrix"""
    #         if self.rows != self.cols:
    #             raise MatrixShapeError("Determinant only defined for square matrices")

    #         if self.rows = 1:
    #             return self.data[0][0]
    #         elif self.rows = 2:
    #             return self.data[0][0] * self.data[1][1] - self.data[0][1] * self.data[1][0]
    #         else:
    #             # Use Laplace expansion for larger matrices
    det = 0
    #             for j in range(self.cols):
    minor = self.minor(0, j)
    det + = ((-1) * * j * self.data[0][j] * minor.determinant())
    #             return det

    #     def minor(self, row: int, col: int) -"Matrix"):
    #         """Get the minor matrix by removing specified row and column"""
    minor_data = [
    #             [self.data[i][j] for j in range(self.cols) if j != col]
    #             for i in range(self.rows)
    #             if i != row
    #         ]
            return Matrix(minor_data, self.rows - 1, self.cols - 1, self.dtype)

    #     def inverse(self) -"Matrix"):
    #         """Calculate the inverse of the matrix"""
    det = self.determinant()
    #         if det = 0:
                raise MatrixElementError("Matrix is singular and cannot be inverted")

    #         if self.rows = 1:
                return Matrix([[1 / det]], 1, 1, self.dtype)

    #         # Calculate adjugate matrix
    adjugate_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(self.cols):
    cofactor = ((-1) ** (i + j) * self.minor(i, j).determinant())
                    row.append(cofactor)
                adjugate_data.append(row)

    adjugate = Matrix(adjugate_data, self.rows, self.cols, self.dtype)
            return adjugate.transpose() * (1 / det)

    #     def trace(self) -float):
            """Calculate the trace of the matrix (sum of diagonal elements)"""
    #         if self.rows != self.cols:
    #             raise MatrixShapeError("Trace only defined for square matrices")

    #         return sum(self.data[i][i] for i in range(self.rows))

    #     def norm(self, p: int = 2) -float):
    #         """Calculate matrix p-norm"""
    #         if p = 1:
    #             # Maximum absolute column sum
                return max(
    #                 sum(abs(self.data[i][j]) for i in range(self.rows))
    #                 for j in range(self.cols)
    #             )
    #         elif p = 2:
                # Spectral norm (largest singular value)
    return np.linalg.norm(self.to_numpy(), ord = 2)
    #         elif p == float("inf"):
    #             # Maximum absolute row sum
                return max(
    #                 sum(abs(self.data[i][j]) for j in range(self.cols))
    #                 for i in range(self.rows)
    #             )
    #         else:
                raise ValueError(f"Unsupported p-norm: {p}")

    #     def rank(self) -int):
    #         """Calculate the rank of the matrix"""
    #         # Use numpy for efficient rank calculation
            return np.linalg.matrix_rank(self.to_numpy())

    #     def eigenvalues(self) -List[float]):
    #         """Calculate eigenvalues of the matrix"""
    #         if self.rows != self.cols:
    #             raise MatrixShapeError("Eigenvalues only defined for square matrices")

    eigenvals = np.linalg.eigvals(self.to_numpy())
            return eigenvals.tolist()

    #     def eigenvectors(self) -Tuple[List[float], "Matrix"]):
    #         """Calculate eigenvalues and eigenvectors of the matrix"""
    #         if self.rows != self.cols:
    #             raise MatrixShapeError("Eigenvectors only defined for square matrices")

    eigenvals, eigenvecs = np.linalg.eig(self.to_numpy())
            return eigenvals.tolist(), Matrix(
                eigenvecs.tolist(), self.rows, self.cols, self.dtype
    #         )

    #     def solve(self, b: Union["Matrix", List[float]]) -"Matrix"):
    """Solve linear system Ax = b"""
    #         if isinstance(b, list):
    b = Vector(b, len(b))

    #         if self.rows != b.rows:
                raise MatrixShapeError("Matrix and vector dimensions must match")

    #         # Use numpy to solve the system
    A = self.to_numpy()
    b_array = b.to_numpy()
    x = np.linalg.solve(A, b_array)

            return Vector(x.tolist(), len(x), self.dtype)

    #     def lu_decomposition(self) -Tuple["Matrix", "Matrix"]):
    #         """Perform LU decomposition of the matrix"""
    #         if self.rows != self.cols:
    #             raise MatrixShapeError("LU decomposition only defined for square matrices")

    #         # Use numpy for LU decomposition
    P, L, U = scipy.linalg.lu(self.to_numpy())

            return (
                Matrix(P.tolist(), self.rows, self.cols, self.dtype),
                Matrix(L.tolist(), self.rows, self.cols, self.dtype),
                Matrix(U.tolist(), self.rows, self.cols, self.dtype),
    #         )


dataclass
class Vector
    #     """
    #     Vector class for Noodle language with 1D array operations.

    #     Supports common vector operations like addition, dot product,
    #     cross product, norm calculations, etc.
    #     """

    #     data: List[float]
    #     size: int
    dtype: str = "float"

    #     def __post_init__(self):
    #         # Convert data to float if needed
    #         if self.dtype == "float":
    #             self.data = [float(x) for x in self.data]
    #         elif self.dtype == "int":
    #             self.data = [int(x) for x in self.data]

    #         if len(self.data) != self.size:
                raise VectorShapeError(f"Expected size {self.size}, got {len(self.data)}")

    #     @classmethod
    #     def zeros(cls, size: int, dtype: str = "float") -"Vector"):
    #         """Create a vector filled with zeros"""
            return cls([0.0] * size, size, dtype)

    #     @classmethod
    #     def ones(cls, size: int, dtype: str = "float") -"Vector"):
    #         """Create a vector filled with ones"""
            return cls([1.0] * size, size, dtype)

    #     @classmethod
    #     def linspace(cls, start: float, stop: float, num: int = 50) -"Vector"):
    #         """Create a vector with evenly spaced values"""
    step = (stop - start / (num - 1))
    #         return cls([start + i * step for i in range(num)], num)

    #     @classmethod
    #     def arange(cls, start: float, stop: float, step: float = 1.0) -"Vector"):
    #         """Create a vector with evenly spaced values in a given range"""
    values = []
    current = start
    #         while current < stop:
                values.append(current)
    current + = step
            return cls(values, len(values))

    #     @classmethod
    #     def from_numpy(cls, array: np.ndarray, dtype: str = "float") -"Vector"):
    #         """Create a vector from a numpy array"""
    #         if array.ndim != 1:
                raise VectorShapeError("Array must be 1-dimensional")

            return cls(array.tolist(), len(array), dtype)

    #     def to_numpy(self) -np.ndarray):
    #         """Convert vector to numpy array"""
    return np.array(self.data, dtype = self.dtype)

    #     def copy(self) -"Vector"):
    #         """Create a copy of the vector"""
            return Vector(self.data.copy(), self.size, self.dtype)

    #     def __add__(self, other: Union["Vector", float]) -"Vector"):
    #         """Vector addition or scalar addition"""
    #         if isinstance(other, Vector):
    #             if self.size != other.size:
    #                 raise VectorShapeError("Vector sizes must match for addition")

    #             result_data = [self.data[i] + other.data[i] for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)
    #         else:
    #             # Scalar addition
    #             result_data = [self.data[i] + other for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)

    #     def __sub__(self, other: Union["Vector", float]) -"Vector"):
    #         """Vector subtraction or scalar subtraction"""
    #         if isinstance(other, Vector):
    #             if self.size != other.size:
    #                 raise VectorShapeError("Vector sizes must match for subtraction")

    #             result_data = [self.data[i] - other.data[i] for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)
    #         else:
    #             # Scalar subtraction
    #             result_data = [self.data[i] - other for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)

    #     def __mul__(self, other: Union["Vector", float]) -Union["Vector", float]):
    #         """Vector multiplication or scalar multiplication"""
    #         if isinstance(other, Vector):
    #             if self.size != other.size:
    #                 raise VectorShapeError("Vector sizes must match for multiplication")

    #             # Element-wise multiplication
    #             result_data = [self.data[i] * other.data[i] for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)
    #         else:
    #             # Scalar multiplication
    #             result_data = [self.data[i] * other for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)

    #     def __truediv__(self, other: Union["Vector", float]) -"Vector"):
    #         """Vector division or scalar division"""
    #         if isinstance(other, Vector):
    #             if self.size != other.size:
    #                 raise VectorShapeError("Vector sizes must match for division")

    #             result_data = [self.data[i] / other.data[i] for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)
    #         else:
    #             # Scalar division
    #             result_data = [self.data[i] / other for i in range(self.size)]
                return Vector(result_data, self.size, self.dtype)

    #     def __dot__(self, other: "Vector") -float):
    #         """Dot product with another vector"""
    #         if self.size != other.size:
    #             raise VectorShapeError("Vector sizes must match for dot product")

    #         return sum(self.data[i] * other.data[i] for i in range(self.size))

    #     def cross(self, other: "Vector") -"Vector"):
    #         """Cross product with another vector (only for 3D vectors)"""
    #         if self.size != 3 or other.size != 3:
    #             raise VectorShapeError("Cross product only defined for 3D vectors")

    result_data = [
    #             self.data[1] * other.data[2] - self.data[2] * other.data[1],
    #             self.data[2] * other.data[0] - self.data[0] * other.data[2],
    #             self.data[0] * other.data[1] - self.data[1] * other.data[0],
    #         ]
            return Vector(result_data, 3, self.dtype)

    #     def magnitude(self) -float):
            """Calculate the magnitude (Euclidean norm) of the vector"""
    #         return sum(x**2 for x in self.data) ** 0.5

    #     def normalize(self) -"Vector"):
    #         """Return a normalized copy of the vector"""
    mag = self.magnitude()
    #         if mag = 0:
                raise VectorShapeError("Cannot normalize zero vector")

    #         return Vector([x / mag for x in self.data], self.size, self.dtype)

    #     def __getitem__(self, index: Union[int, slice]) -Union[float, "Vector"]):
    #         """Get element or subvector"""
    #         if isinstance(index, slice):
    #             # Return subvector
    subvector_data = self.data[index]
                return Vector(subvector_data, len(subvector_data), self.dtype)
    #         else:
    #             # Return single element
    #             return self.data[index]

    #     def __setitem__(self, index: int, value: float):
    #         """Set element value"""
    self.data[index] = value

    #     def __str__(self) -str):
    #         """String representation of the vector"""
            return (
                f"Vector({self.size}, {self.dtype}) ["
    #             + ", ".join(f"{x:.3f}" for x in self.data)
    #             + "]"
    #         )

    #     def __repr__(self) -str):
    #         """String representation for debugging"""
    return f"Vector({self.size}, dtype = {self.dtype})"

    #     def angle(self, other: "Vector") -float):
            """Calculate angle between two vectors (in radians)"""
    #         if self.size != other.size:
    #             raise VectorShapeError("Vector sizes must match for angle calculation")

    dot_product = self.__dot__(other)
    magnitude_product = self.magnitude() * other.magnitude()

    #         if magnitude_product = 0:
    #             raise VectorShapeError("Cannot calculate angle with zero vector")

    cos_angle = math.divide(dot_product, magnitude_product)
    #         # Clamp to avoid numerical errors
    cos_angle = max( - 1, min(1, cos_angle))
            return np.arccos(cos_angle)

    #     def project(self, other: "Vector") -"Vector"):
    #         """Project this vector onto another vector"""
    #         if self.size != other.size:
    #             raise VectorShapeError("Vector sizes must match for projection")

    dot_product = self.__dot__(other)
    #         other_mag_sq = sum(x**2 for x in other.data)

    #         if other_mag_sq = 0:
                raise VectorShapeError("Cannot project onto zero vector")

    scale = math.divide(dot_product, other_mag_sq)
    #         return Vector([scale * x for x in other.data], self.size, self.dtype)

    #     def orthogonal(self) -"Vector"):
    #         """Return a vector orthogonal to this one (for 2D vectors)"""
    #         if self.size != 2:
    #             raise VectorShapeError("Orthogonal vector only defined for 2D vectors")

            return Vector([-self.data[1], self.data[0]], 2, self.dtype)

    #     def to_matrix(self, orientation: str = "column") -Matrix):
    #         """Convert vector to a matrix"""
    #         if orientation == "column":
    #             return Matrix([[x] for x in self.data], self.size, 1, self.dtype)
    #         elif orientation == "row":
                return Matrix([self.data], 1, self.size, self.dtype)
    #         else:
                raise ValueError("Orientation must be 'column' or 'row'")

    #     def reshape(self, new_size: int) -"Vector"):
            """Reshape the vector to a new size (must preserve total elements)"""
    #         if new_size != self.size:
                raise VectorShapeError("Reshape must preserve total number of elements")

            return Vector(self.data.copy(), new_size, self.dtype)


dataclass
class Tensor
    #     """
    #     Tensor class for Noodle language with multi-dimensional array operations.

    #     Supports common tensor operations like addition, contraction,
    #     slicing, reshaping, etc.
    #     """

    #     data: List[Any]
    #     shape: Tuple[int, ...]
    dtype: str = "float"

    #     def __post_init__(self):
    #         # Validate tensor data
    #         if not self.data:
    #             # Create tensor of zeros if no data provided
    self.data = self._create_zeros_tensor(self.shape)
    #         else:
    #             # Validate that data matches shape
    #             if len(self.data) != self.shape[0]:
                    raise TensorShapeError(
                        f"First dimension mismatch: expected {self.shape[0]}, got {len(self.data)}"
    #                 )

    #             # Recursively validate nested dimensions
    #             for i, item in enumerate(self.data):
    #                 if isinstance(item, list):
    #                     if len(item) != self.shape[1]:
                            raise TensorShapeError(
                                f"Second dimension mismatch at index {i}: expected {self.shape[1]}, got {len(item)}"
    #                         )

    #         # Convert data to appropriate type
    #         if self.dtype == "float":
    self.data = self._convert_tensor_data(self.data, float)
    #         elif self.dtype == "int":
    self.data = self._convert_tensor_data(self.data, int)

    #     def _create_zeros_tensor(self, shape: Tuple[int, ...]) -List[Any]):
    #         """Create a tensor filled with zeros"""
    #         if len(shape) == 1:
    #             return [0.0] * shape[0]
    #         else:
    #             return [self._create_zeros_tensor(shape[1:]) for _ in range(shape[0])]

    #     def _convert_tensor_data(self, data: List[Any], converter: callable) -List[Any]):
    #         """Convert tensor data to specified type"""
    #         if isinstance(data[0], list):
    #             return [self._convert_tensor_data(subdata, converter) for subdata in data]
    #         else:
    #             return [converter(x) for x in data]

    #     @classmethod
    #     def zeros(cls, shape: Tuple[int, ...], dtype: str = "float") -"Tensor"):
    #         """Create a tensor filled with zeros"""
    data = cls._create_zeros_tensor(shape)
            return cls(data, shape, dtype)

    #     @classmethod
    #     def ones(cls, shape: Tuple[int, ...], dtype: str = "float") -"Tensor"):
    #         """Create a tensor filled with ones"""
    #         if len(shape) == 1:
    data = [1.0] * shape[0]
    #         elif len(shape) == 2:
    #             data = [[1.0] * shape[1] for _ in range(shape[0])]
    #         elif len(shape) == 3:
    data = [
    #                 [[1.0] * shape[2] for _ in range(shape[1])] for _ in range(shape[0])
    #             ]
    #         else:
                raise TensorShapeError("Only tensors up to 3 dimensions are supported")

            return cls(data, shape, dtype)

    #     @classmethod
    #     def eye(cls, size: int, dims: int = 2, dtype: str = "float") -"Tensor"):
    #         """Create an identity tensor"""
    #         if dims < 2:
                raise TensorShapeError("Identity tensor must have at least 2 dimensions")

    shape = [size] * dims
    data = cls._create_zeros_tensor(shape)

    #         # Set diagonal elements to 1
    indices = [0] * dims
    #         for i in range(size):
    #             for dim in range(dims):
    indices[dim] = i
                cls._set_element(data, tuple(indices), 1.0)

            return cls(data, tuple(shape), dtype)

    #     @classmethod
    #     def from_numpy(cls, array: np.ndarray, dtype: str = "float") -"Tensor"):
    #         """Create a tensor from a numpy array"""
    data = array.tolist()
    shape = array.shape
            return cls(data, shape, dtype)

    #     def to_numpy(self) -np.ndarray):
    #         """Convert tensor to numpy array"""
    return np.array(self.data, dtype = self.dtype)

    #     def copy(self) -"Tensor"):
    #         """Create a copy of the tensor"""
            return Tensor(self._deep_copy_data(self.data), self.shape, self.dtype)

    #     def _deep_copy_data(self, data: List[Any]) -List[Any]):
    #         """Deep copy tensor data"""
    #         if isinstance(data[0], list):
    #             return [self._deep_copy_data(subdata) for subdata in data]
    #         else:
                return data.copy()

    #     def _set_element(self, data: List[Any], indices: Tuple[int, ...], value: float):
    #         """Set element at given indices"""
    #         if len(indices) == 1:
    data[indices[0]] = value
    #         else:
                self._set_element(data[indices[0]], indices[1:], value)

    #     def _get_element(self, data: List[Any], indices: Tuple[int, ...]) -float):
    #         """Get element at given indices"""
    #         if len(indices) == 1:
    #             return data[indices[0]]
    #         else:
                return self._get_element(data[indices[0]], indices[1:])

    #     def __getitem__(
    #         self, indices: Union[Tuple[int, ...], int]
    #     ) -Union[float, "Tensor"]):
    #         """Get element or subtensor"""
    #         if isinstance(indices, int):
    indices = (indices,)

    #         # Validate indices
    #         if len(indices) len(self.shape)):
    #             raise TensorShapeError("Too many indices for tensor")

    #         # Extract subtensor
    #         if len(indices) == len(self.shape):
    #             # Return single element
                return self._get_element(self.data, indices)
    #         else:
    #             # Return subtensor
    subtensor_data = self._extract_subtensor(self.data, indices)
    new_shape = self.shape[len(indices) :]
                return Tensor(subtensor_data, new_shape, self.dtype)

    #     def _extract_subtensor(
    #         self, data: List[Any], indices: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Extract subtensor data"""
    #         if len(indices) == 1:
    #             return data[indices[0]]
    #         else:
                return self._extract_subtensor(data[indices[0]], indices[1:])

    #     def __setitem__(self, indices: Tuple[int, ...], value: float):
    #         """Set element value"""
    #         if len(indices) != len(self.shape):
                raise TensorShapeError("Indices must match tensor dimensions")

            self._set_element(self.data, indices, value)

    #     def __add__(self, other: Union["Tensor", float]) -"Tensor"):
    #         """Tensor addition or scalar addition"""
    #         if isinstance(other, Tensor):
    #             if self.shape != other.shape:
    #                 raise TensorShapeError("Tensor shapes must match for addition")

    result_data = self._add_tensor_data(self.data, other.data)
                return Tensor(result_data, self.shape, self.dtype)
    #         else:
    #             # Scalar addition
    result_data = self._add_scalar_to_tensor(self.data, other)
                return Tensor(result_data, self.shape, self.dtype)

    #     def _add_tensor_data(self, data1: List[Any], data2: List[Any]) -List[Any]):
    #         """Add two tensors element-wise"""
    #         if isinstance(data1[0], list):
    #             return [
    #                 self._add_tensor_data(sub1, sub2) for sub1, sub2 in zip(data1, data2)
    #             ]
    #         else:
    #             return [x + y for x, y in zip(data1, data2)]

    #     def _add_scalar_to_tensor(self, data: List[Any], scalar: float) -List[Any]):
    #         """Add scalar to tensor element-wise"""
    #         if isinstance(data[0], list):
    #             return [self._add_scalar_to_tensor(subdata, scalar) for subdata in data]
    #         else:
    #             return [x + scalar for x in data]

    #     def __sub__(self, other: Union["Tensor", float]) -"Tensor"):
    #         """Tensor subtraction or scalar subtraction"""
    #         if isinstance(other, Tensor):
    #             if self.shape != other.shape:
    #                 raise TensorShapeError("Tensor shapes must match for subtraction")

    result_data = self._subtract_tensor_data(self.data, other.data)
                return Tensor(result_data, self.shape, self.dtype)
    #         else:
    #             # Scalar subtraction
    result_data = self._subtract_scalar_from_tensor(self.data, other)
                return Tensor(result_data, self.shape, self.dtype)

    #     def _subtract_tensor_data(self, data1: List[Any], data2: List[Any]) -List[Any]):
    #         """Subtract two tensors element-wise"""
    #         if isinstance(data1[0], list):
    #             return [
                    self._subtract_tensor_data(sub1, sub2)
    #                 for sub1, sub2 in zip(data1, data2)
    #             ]
    #         else:
    #             return [x - y for x, y in zip(data1, data2)]

    #     def _subtract_scalar_from_tensor(self, data: List[Any], scalar: float) -List[Any]):
    #         """Subtract scalar from tensor element-wise"""
    #         if isinstance(data[0], list):
    #             return [
    #                 self._subtract_scalar_from_tensor(subdata, scalar) for subdata in data
    #             ]
    #         else:
    #             return [x - scalar for x in data]

    #     def __mul__(self, other: Union["Tensor", float]) -"Tensor"):
    #         """Tensor multiplication or scalar multiplication"""
    #         if isinstance(other, Tensor):
    #             if self.shape != other.shape:
                    raise TensorShapeError(
    #                     "Tensor shapes must match for element-wise multiplication"
    #                 )

    result_data = self._multiply_tensor_data(self.data, other.data)
                return Tensor(result_data, self.shape, self.dtype)
    #         else:
    #             # Scalar multiplication
    result_data = self._multiply_scalar_with_tensor(self.data, other)
                return Tensor(result_data, self.shape, self.dtype)

    #     def _multiply_tensor_data(self, data1: List[Any], data2: List[Any]) -List[Any]):
    #         """Multiply two tensors element-wise"""
    #         if isinstance(data1[0], list):
    #             return [
                    self._multiply_tensor_data(sub1, sub2)
    #                 for sub1, sub2 in zip(data1, data2)
    #             ]
    #         else:
    #             return [x * y for x, y in zip(data1, data2)]

    #     def _multiply_scalar_with_tensor(self, data: List[Any], scalar: float) -List[Any]):
    #         """Multiply scalar with tensor element-wise"""
    #         if isinstance(data[0], list):
    #             return [
    #                 self._multiply_scalar_with_tensor(subdata, scalar) for subdata in data
    #             ]
    #         else:
    #             return [x * scalar for x in data]

    #     def __truediv__(self, other: Union["Tensor", float]) -"Tensor"):
    #         """Tensor division or scalar division"""
    #         if isinstance(other, Tensor):
    #             if self.shape != other.shape:
                    raise TensorShapeError(
    #                     "Tensor shapes must match for element-wise division"
    #                 )

    result_data = self._divide_tensor_data(self.data, other.data)
                return Tensor(result_data, self.shape, self.dtype)
    #         else:
    #             # Scalar division
    result_data = self._divide_tensor_by_scalar(self.data, other)
                return Tensor(result_data, self.shape, self.dtype)

    #     def _divide_tensor_data(self, data1: List[Any], data2: List[Any]) -List[Any]):
    #         """Divide two tensors element-wise"""
    #         if isinstance(data1[0], list):
    #             return [
    #                 self._divide_tensor_data(sub1, sub2) for sub1, sub2 in zip(data1, data2)
    #             ]
    #         else:
    #             return [x / y for x, y in zip(data1, data2)]

    #     def _divide_tensor_by_scalar(self, data: List[Any], scalar: float) -List[Any]):
    #         """Divide tensor by scalar element-wise"""
    #         if isinstance(data[0], list):
    #             return [self._divide_tensor_by_scalar(subdata, scalar) for subdata in data]
    #         else:
    #             return [x / scalar for x in data]

    #     def reshape(self, new_shape: Tuple[int, ...]) -"Tensor"):
    #         """Reshape the tensor to a new shape"""
    #         # Check if total number of elements is preserved
    #         if np.prod(self.shape) != np.prod(new_shape):
                raise TensorShapeError("Reshape must preserve total number of elements")

    #         # Flatten the tensor
    flattened = self._flatten_tensor(self.data)

    #         # Build reshaped tensor
    reshaped_data = self._build_reshaped_tensor(flattened, new_shape)

            return Tensor(reshaped_data, new_shape, self.dtype)

    #     def _flatten_tensor(self, data: List[Any]) -List[float]):
    #         """Flatten tensor to 1D list"""
    #         if isinstance(data[0], list):
    result = []
    #             for subdata in data:
                    result.extend(self._flatten_tensor(subdata))
    #             return result
    #         else:
                return data.copy()

    #     def _build_reshaped_tensor(
    #         self, data: List[float], shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Build tensor from flattened data"""
    #         if len(shape) == 1:
    #             return data[: shape[0]]
    #         else:
    sub_size = np.prod(shape[1:])
    result = []
    #             for i in range(shape[0]):
    start = i * sub_size
    end = start + sub_size
                    result.append(self._build_reshaped_tensor(data[start:end], shape[1:]))
    #             return result

    #     def transpose(self, axes: Optional[Tuple[int, ...]] = None) -"Tensor"):
    #         """Transpose the tensor"""
    #         if axes is None:
    #             # Reverse axes for default transpose
    axes = tuple(reversed(range(len(self.shape))))

    #         if len(axes) != len(self.shape):
                raise TensorShapeError("Transpose axes must match tensor dimensions")

    #         # Create transposed shape
    #         new_shape = tuple(self.shape[i] for i in axes)

    #         # Create transposed data
    transposed_data = self._transpose_data(self.data, axes, self.shape)

            return Tensor(transposed_data, new_shape, self.dtype)

    #     def _transpose_data(
    #         self, data: List[Any], axes: Tuple[int, ...], shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Transpose tensor data"""
    #         if len(axes) == 1:
                return data.copy()

    #         # Permute axes
    #         new_order = [axes[i] for i in range(len(axes))]

    #         # Create transposed data
    transposed_data = self._permute_axes(data, new_order, shape)

    #         return transposed_data

    #     def _permute_axes(
    #         self, data: List[Any], new_order: List[int], shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Permute axes of tensor"""
    #         if len(new_order) == 1:
                return data.copy()

    #         # Get new axis order
    #         permuted_shape = tuple(shape[i] for i in new_order)

    #         # Create permuted data
    permuted_data = self._build_permuted_tensor(data, new_order, shape)

    #         return permuted_data

    #     def _build_permuted_tensor(
    #         self, data: List[Any], new_order: List[int], shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Build permuted tensor"""
    #         if len(new_order) == 1:
                return data.copy()

    #         # Get first axis in new order
    first_axis = new_order[0]
    #         new_shape = [shape[i] for i in new_order]

    #         # Build permuted data
    result = []
    #         for i in range(shape[first_axis]):
    subdata = self._get_slice(data, shape, first_axis, i)
    permuted_subdata = self._build_permuted_tensor(
    #                 subdata, new_order[1:], new_shape[1:]
    #             )
                result.append(permuted_subdata)

    #         return result

    #     def _get_slice(
    #         self, data: List[Any], shape: Tuple[int, ...], axis: int, index: int
    #     ) -List[Any]):
    #         """Get slice along given axis"""
    #         if axis = 0:
    #             return data[index]
    #         else:
    #             return [
    #                 self._get_slice(subdata, shape, axis - 1, index) for subdata in data
    #             ]

    #     def sum(self, axis: Optional[int] = None) -Union[float, "Tensor"]):
    #         """Sum tensor elements along given axis"""
    #         if axis is None:
    #             # Sum all elements
                return self._sum_all_elements(self.data)
    #         else:
    #             # Sum along specific axis
    #             if axis < 0 or axis >= len(self.shape):
                    raise TensorShapeError(
    #                     f"Axis {axis} out of bounds for tensor with {len(self.shape)} dimensions"
    #                 )

    new_shape = list(self.shape)
    new_shape[axis] = 1

    summed_data = self._sum_along_axis(self.data, axis, self.shape)

    #             # Remove summed axis if it's 1
    #             if new_shape[axis] == 1:
                    new_shape.pop(axis)
                    return Tensor(summed_data, tuple(new_shape), self.dtype)
    #             else:
                    return Tensor(summed_data, tuple(new_shape), self.dtype)

    #     def _sum_all_elements(self, data: List[Any]) -float):
    #         """Sum all elements in tensor"""
    #         if isinstance(data[0], list):
    #             return sum(self._sum_all_elements(subdata) for subdata in data)
    #         else:
                return sum(data)

    #     def _sum_along_axis(
    #         self, data: List[Any], axis: int, shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Sum tensor along specific axis"""
    #         if axis = 0:
    #             # Sum along first axis
    #             if len(shape) == 1:
                    return [sum(data)]
    #             else:
    #                 return [sum(subdata) for subdata in data]
    #         else:
    #             # Recursively sum along other axes
    #             return [
    #                 self._sum_along_axis(subdata, axis - 1, shape[1:]) for subdata in data
    #             ]

    #     def mean(self, axis: Optional[int] = None) -Union[float, "Tensor"]):
    #         """Calculate mean of tensor elements along given axis"""
    #         if axis is None:
    #             # Mean of all elements
    total = self._sum_all_elements(self.data)
    count = np.prod(self.shape)
    #             return total / count
    #         else:
    #             # Mean along specific axis
    summed = self.sum(axis)
    #             if isinstance(summed, Tensor):
    #                 # Divide by the size along the summed axis
    #                 if axis < len(self.shape):
    divisor = self.shape[axis]
                        return summed * (1.0 / divisor)
    #                 else:
    #                     return summed
    #             else:
    #                 return summed

    #     def std(self, axis: Optional[int] = None) -Union[float, "Tensor"]):
    #         """Calculate standard deviation of tensor elements along given axis"""
    #         if axis is None:
    #             # Standard deviation of all elements
    mean_val = self.mean()
    squared_diff = (self - mean_val) * * 2
                return squared_diff.mean() ** 0.5
    #         else:
    #             # Standard deviation along specific axis
    mean_val = self.mean(axis)
    squared_diff = (self - mean_val) * * 2
                return squared_diff.mean(axis) ** 0.5

    #     def max(self, axis: Optional[int] = None) -Union[float, "Tensor"]):
    #         """Find maximum value along given axis"""
    #         if axis is None:
    #             # Maximum of all elements
                return self._max_element(self.data)
    #         else:
    #             # Maximum along specific axis
    max_data = self._max_along_axis(self.data, axis, self.shape)
    new_shape = list(self.shape)
    #             if axis < len(new_shape):
    new_shape[axis] = 1
                return Tensor(max_data, tuple(new_shape), self.dtype)

    #     def _max_element(self, data: List[Any]) -float):
    #         """Find maximum element in tensor"""
    #         if isinstance(data[0], list):
    #             return max(self._max_element(subdata) for subdata in data)
    #         else:
                return max(data)

    #     def _max_along_axis(
    #         self, data: List[Any], axis: int, shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Find maximum along specific axis"""
    #         if axis = 0:
    #             # Max along first axis
    #             if len(shape) == 1:
                    return [max(data)]
    #             else:
    #                 return [max(subdata) for subdata in data]
    #         else:
    #             # Recursively find max along other axes
    #             return [
    #                 self._max_along_axis(subdata, axis - 1, shape[1:]) for subdata in data
    #             ]

    #     def min(self, axis: Optional[int] = None) -Union[float, "Tensor"]):
    #         """Find minimum value along given axis"""
    #         if axis is None:
    #             # Minimum of all elements
                return self._min_element(self.data)
    #         else:
    #             # Minimum along specific axis
    min_data = self._min_along_axis(self.data, axis, self.shape)
    new_shape = list(self.shape)
    #             if axis < len(new_shape):
    new_shape[axis] = 1
                return Tensor(min_data, tuple(new_shape), self.dtype)

    #     def _min_element(self, data: List[Any]) -float):
    #         """Find minimum element in tensor"""
    #         if isinstance(data[0], list):
    #             return min(self._min_element(subdata) for subdata in data)
    #         else:
                return min(data)

    #     def _min_along_axis(
    #         self, data: List[Any], axis: int, shape: Tuple[int, ...]
    #     ) -List[Any]):
    #         """Find minimum along specific axis"""
    #         if axis = 0:
    #             # Min along first axis
    #             if len(shape) == 1:
                    return [min(data)]
    #             else:
    #                 return [min(subdata) for subdata in data]
    #         else:
    #             # Recursively find min along other axes
    #             return [
    #                 self._min_along_axis(subdata, axis - 1, shape[1:]) for subdata in data
    #             ]

    #     def __str__(self) -str):
    #         """String representation of the tensor"""
            return (
                f"Tensor{self.shape} ({self.dtype})\n{self._format_tensor_data(self.data)}"
    #         )

    #     def __repr__(self) -str):
    #         """String representation for debugging"""
    return f"Tensor(shape = {self.shape}, dtype={self.dtype})"

    #     def _format_tensor_data(self, data: List[Any], indent: int = 0) -str):
    #         """Format tensor data for display"""
    #         if isinstance(data[0], list):
                return (
    #                 "[\n"
                    + "\n".join(
                        "  " * (indent + 1) + self._format_tensor_data(subdata, indent + 1)
    #                     for subdata in data
    #                 )
    #                 + "\n"
    #                 + "  " * indent
    #                 + "]"
    #             )
    #         else:
    #             return "[" + ", ".join(f"{x:.3f}" for x in data) + "]"


# Mathematical function library
def matmul(matrix1: Matrix, matrix2: Matrix) -Matrix):
#     """Matrix multiplication"""
#     return matrix1 @ matrix2


def dot(vec1: Vector, vec2: Vector) -float):
#     """Dot product of two vectors"""
    return vec1.__dot__(vec2)


def cross(vec1: Vector, vec2: Vector) -Vector):
#     """Cross product of two vectors"""
    return vec1.cross(vec2)


def outer(vec1: Vector, vec2: Vector) -Matrix):
#     """Outer product of two vectors"""
#     if vec1.size = 0 or vec2.size = 0:
        raise VectorShapeError("Vectors must not be empty")

result_data = [
#         [vec1.data[i] * vec2.data[j] for j in range(vec2.size)]
#         for i in range(vec1.size)
#     ]
    return Matrix(result_data, vec1.size, vec2.size)


def kron(matrix1: Matrix, matrix2: Matrix) -Matrix):
#     """Kronecker product of two matrices"""
rows = matrix1.rows * matrix2.rows
cols = matrix1.cols * matrix2.cols

result_data = [
#         [
#             matrix1.data[i // matrix2.rows][j // matrix2.cols]
#             * matrix2.data[i % matrix2.rows][j % matrix2.cols]
#             for j in range(cols)
#         ]
#         for i in range(rows)
#     ]

    return Matrix(result_data, rows, cols)


def vandermonde(vector: Vector, increasing: bool = False) -Matrix):
#     """Create Vandermonde matrix from vector"""
size = vector.size
#     result_data = [[vector.data[i] ** j for j in range(size)] for i in range(size)]

#     if not increasing:
#         # Reverse columns for decreasing order
#         result_data = [row[::-1] for row in result_data]

    return Matrix(result_data, size, size)


def hadamard(matrix1: Matrix, matrix2: Matrix) -Matrix):
    """Hadamard product (element-wise) of two matrices"""
#     if matrix1.rows != matrix2.rows or matrix1.cols != matrix2.cols:
#         raise MatrixShapeError("Matrix dimensions must match for Hadamard product")

result_data = [
#         [matrix1.data[i][j] * matrix2.data[i][j] for j in range(matrix1.cols)]
#         for i in range(matrix1.rows)
#     ]

    return Matrix(result_data, matrix1.rows, matrix1.cols)


def kronecker_delta(i: int, j: int) -float):
#     """Kronecker delta function"""
#     return 1.0 if i == j else 0.0


def levi_civita(i: int, j: int, k: int) -float):
    """Levi-Civita symbol (permutation symbol)"""
#     if (i, j, k) in [(0, 1, 2), (1, 2, 0), (2, 0, 1)]:
#         return 1.0
#     elif (i, j, k) in [(2, 1, 0), (1, 0, 2), (0, 2, 1)]:
#         return -1.0
#     else:
#         return 0.0


def tensor_product(tensor1: Tensor, tensor2: Tensor) -Tensor):
#     """Tensor product of two tensors"""
#     # This is a simplified implementation
#     # In a full implementation, we would handle arbitrary dimensions

#     if len(tensor1.shape) != 1 or len(tensor2.shape) != 1:
        raise TensorShapeError("Tensor product currently only supports 1D tensors")

#     # Outer product
result_data = [
#         [
            tensor1._get_element(tensor1.data, (i,))
            * tensor2._get_element(tensor2.data, (j,))
#             for j in range(tensor2.shape[0])
#         ]
#         for i in range(tensor1.shape[0])
#     ]

    return Tensor(result_data, (tensor1.shape[0], tensor2.shape[0]), tensor1.dtype)
