# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Matrix implementation for Noodle compiler.
# Provides mathematical matrix operations and utilities.
# """

import typing.List,
import dataclasses.dataclass,
import enum.Enum
import math
import numpy as np
import functools.reduce
import operator
import threading


class MatrixShapeError(Exception)
    #     """Exception raised for matrix shape mismatches"""
    #     pass


class MatrixTypeError(Exception)
    #     """Exception raised for matrix type mismatches"""
    #     pass


class MatrixOperationError(Exception)
    #     """Exception raised for matrix operation errors"""
    #     pass


class MatrixStorageType(Enum)
    #     """Storage type for matrix data"""
    DENSE = "dense"
    SPARSE = "sparse"
    DIAGONAL = "diagonal"
    SYMMETRIC = "symmetric"


# @dataclass
class MatrixProperties
    #     """Properties of a matrix"""
    #     shape: Tuple[int, int]
    storage_type: MatrixStorageType = MatrixStorageType.DENSE
    dtype: type = float
    name: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[float] = None
    modified_at: Optional[float] = None
    tags: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class Matrix
    #     """Represents a mathematical matrix with various operations"""
    #     data: List[List[Any]]
    #     properties: MatrixProperties
    _lock: threading.Lock = field(default_factory=threading.Lock)

    #     def __post_init__(self):
    #         """Initialize matrix after creation"""
    #         if not self.data:
                raise ValueError("Matrix data cannot be empty")

    #         # Validate shape
    rows = len(self.data)
    #         cols = len(self.data[0]) if rows > 0 else 0

    #         for row in self.data:
    #             if len(row) != cols:
                    raise MatrixShapeError(f"All rows must have the same length: {cols}")

    #         # Update properties if shape doesn't match
    #         if self.properties.shape != (rows, cols):
    self.properties.shape = (rows, cols)

    #         # Set creation time if not set
    #         if self.properties.created_at is None:
    #             import time
    self.properties.created_at = time.time()

    self.properties.modified_at = time.time()

    #     @property
    #     def shape(self) -> Tuple[int, int]:
    #         """Get matrix shape"""
    #         return self.properties.shape

    #     @property
    #     def rows(self) -> int:
    #         """Get number of rows"""
    #         return self.shape[0]

    #     @property
    #     def cols(self) -> int:
    #         """Get number of columns"""
    #         return self.shape[1]

    #     @property
    #     def is_square(self) -> bool:
    #         """Check if matrix is square"""
    return self.rows = = self.cols

    #     @property
    #     def is_diagonal(self) -> bool:
    #         """Check if matrix is diagonal"""
    #         if not self.is_square:
    #             return False

    #         for i in range(self.rows):
    #             for j in range(self.cols):
    #                 if i != j and self.data[i][j] != 0:
    #                     return False
    #         return True

    #     @property
    #     def is_symmetric(self) -> bool:
    #         """Check if matrix is symmetric"""
    #         if not self.is_square:
    #             return False

    #         for i in range(self.rows):
    #             for j in range(i + 1, self.cols):
    #                 if self.data[i][j] != self.data[j][i]:
    #                     return False
    #         return True

    #     @property
    #     def is_tridiagonal(self) -> bool:
    #         """Check if matrix is tridiagonal"""
    #         if not self.is_square:
    #             return False

    #         for i in range(self.rows):
    #             for j in range(self.cols):
    #                 if abs(i - j) > 1 and self.data[i][j] != 0:
    #                     return False
    #         return True

    #     @property
    #     def is_upper_triangular(self) -> bool:
    #         """Check if matrix is upper triangular"""
    #         if not self.is_square:
    #             return False

    #         for i in range(self.rows):
    #             for j in range(i):
    #                 if self.data[i][j] != 0:
    #                     return False
    #         return True

    #     @property
    #     def is_lower_triangular(self) -> bool:
    #         """Check if matrix is lower triangular"""
    #         if not self.is_square:
    #             return False

    #         for i in range(self.rows):
    #             for j in range(i + 1, self.cols):
    #                 if self.data[i][j] != 0:
    #                     return False
    #         return True

    #     def __str__(self) -> str:
    #         """String representation of matrix"""
            return f"Matrix({self.rows}x{self.cols}, {self.properties.storage_type.value})"

    #     def __repr__(self) -> str:
    #         """Detailed string representation"""
    return f"Matrix(data = {self.data}, properties={self.properties})"

    #     def __getitem__(self, key: Union[int, Tuple[int, int]]) -> Any:
    #         """Get element or row from matrix"""
    #         if isinstance(key, tuple):
    i, j = key
    #             return self.data[i][j]
    #         else:
    #             return self.data[key]

    #     def __setitem__(self, key: Union[int, Tuple[int, int]], value: Any):
    #         """Set element or row in matrix"""
    #         with self._lock:
    #             if isinstance(key, tuple):
    i, j = key
    self.data[i][j] = value
    #             else:
    self.data[key] = value
    self.properties.modified_at = time.time()

    #     def __eq__(self, other: object) -> bool:
    #         """Check if two matrices are equal"""
    #         if not isinstance(other, Matrix):
    #             return False

    #         if self.shape != other.shape:
    #             return False

    #         for i in range(self.rows):
    #             for j in range(self.cols):
    #                 if self.data[i][j] != other.data[i][j]:
    #                     return False

    #         return True

    #     def __neg__(self) -> 'Matrix':
    #         """Negate matrix"""
            return self.multiply(-1)

    #     def __add__(self, other: 'Matrix') -> 'Matrix':
    #         """Add two matrices"""
    #         if not isinstance(other, Matrix):
                raise MatrixTypeError("Can only add Matrix to Matrix")

    #         if self.shape != other.shape:
                raise MatrixShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(self.cols):
                    row.append(self.data[i][j] + other.data[i][j])
                result_data.append(row)

            return Matrix(result_data, MatrixProperties(self.shape))

    #     def __sub__(self, other: 'Matrix') -> 'Matrix':
    #         """Subtract two matrices"""
    #         if not isinstance(other, Matrix):
                raise MatrixTypeError("Can only subtract Matrix from Matrix")

    #         if self.shape != other.shape:
                raise MatrixShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(self.cols):
                    row.append(self.data[i][j] - other.data[i][j])
                result_data.append(row)

            return Matrix(result_data, MatrixProperties(self.shape))

    #     def __mul__(self, other: Union['Matrix', int, float]) -> 'Matrix':
    #         """Multiply matrix with scalar or another matrix"""
    #         if isinstance(other, (int, float)):
                return self.multiply(other)
    #         elif isinstance(other, Matrix):
                return self.matmul(other)
    #         else:
    #             raise MatrixTypeError("Can only multiply Matrix with scalar or Matrix")

    #     def __rmul__(self, other: Union[int, float]) -> 'Matrix':
    #         """Right multiply with scalar"""
    #         if isinstance(other, (int, float)):
                return self.multiply(other)
    #         else:
    #             raise MatrixTypeError("Can only multiply Matrix with scalar")

    #     def multiply(self, scalar: Union[int, float]) -> 'Matrix':
    #         """Multiply matrix with scalar"""
    result_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(self.cols):
                    row.append(self.data[i][j] * scalar)
                result_data.append(row)

            return Matrix(result_data, MatrixProperties(self.shape))

    #     def matmul(self, other: 'Matrix') -> 'Matrix':
    #         """Matrix multiplication"""
    #         if self.cols != other.rows:
    #             raise MatrixShapeError(f"Cannot multiply {self.rows}x{self.cols} matrix with {other.rows}x{other.cols} matrix")

    result_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(other.cols):
    #                 dot_product = sum(self.data[i][k] * other.data[k][j] for k in range(self.cols))
                    row.append(dot_product)
                result_data.append(row)

    new_shape = (self.rows, other.cols)
            return Matrix(result_data, MatrixProperties(new_shape))

    #     def add(self, other: 'Matrix') -> 'Matrix':
    #         """Add another matrix"""
            return self.__add__(other)

    #     def subtract(self, other: 'Matrix') -> 'Matrix':
    #         """Subtract another matrix"""
            return self.__sub__(other)

    #     def transpose(self) -> 'Matrix':
    #         """Get transpose of matrix"""
    result_data = []
    #         for j in range(self.cols):
    row = []
    #             for i in range(self.rows):
                    row.append(self.data[i][j])
                result_data.append(row)

    new_shape = (self.cols, self.rows)
            return Matrix(result_data, MatrixProperties(new_shape))

    #     def trace(self) -> Any:
            """Get trace of matrix (sum of diagonal elements)"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Trace only defined for square matrices")

    trace_value = 0
    #         for i in range(self.rows):
    trace_value + = self.data[i][i]
    #         return trace_value

    #     def determinant(self) -> Any:
    #         """Get determinant of matrix"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Determinant only defined for square matrices")

    #         if self.rows == 1:
    #             return self.data[0][0]
    #         elif self.rows == 2:
    #             return self.data[0][0] * self.data[1][1] - self.data[0][1] * self.data[1][0]
    #         else:
    #             # Use Laplace expansion for larger matrices
    det = 0
    #             for j in range(self.cols):
    minor = self.minor(0, j)
    sign = math.multiply((-1), * j)
    det + = math.multiply(sign, self.data[0][j] * minor.determinant())
    #             return det

    #     def minor(self, row: int, col: int) -> 'Matrix':
    #         """Get minor matrix by removing specified row and column"""
    minor_data = []
    #         for i in range(self.rows):
    #             if i == row:
    #                 continue
    minor_row = []
    #             for j in range(self.cols):
    #                 if j == col:
    #                     continue
                    minor_row.append(self.data[i][j])
                minor_data.append(minor_row)

    new_shape = math.subtract((self.rows, 1, self.cols - 1))
            return Matrix(minor_data, MatrixProperties(new_shape))

    #     def cofactor(self, row: int, col: int) -> Any:
    #         """Get cofactor of element at specified position"""
    minor = self.minor(row, col)
    sign = math.add((-1) ** (row, col))
            return sign * minor.determinant()

    #     def adjugate(self) -> 'Matrix':
            """Get adjugate (adjoint) of matrix"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Adjugate only defined for square matrices")

    adj_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(self.cols):
                    row.append(self.cofactor(j, i))
                adj_data.append(row)

            return Matrix(adj_data, MatrixProperties(self.shape))

    #     def inverse(self) -> 'Matrix':
    #         """Get inverse of matrix"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Inverse only defined for square matrices")

    det = self.determinant()
    #         if det == 0:
                raise MatrixOperationError("Matrix is singular and cannot be inverted")

    adj = self.adjugate()
            return adj.multiply(1 / det)

    #     def power(self, exponent: int) -> 'Matrix':
    #         """Raise matrix to integer power"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Power only defined for square matrices")

    #         if exponent == 0:
                return identity_matrix(self.rows)
    #         elif exponent == 1:
                return self.copy()
    #         elif exponent < 0:
    inv = self.inverse()
                return inv.power(-exponent)
    #         else:
    result = self.copy()
    #             for _ in range(exponent - 1):
    result = result.matmul(self)
    #             return result

    #     def copy(self) -> 'Matrix':
    #         """Create a copy of the matrix"""
    #         new_data = [row.copy() for row in self.data]
    new_properties = MatrixProperties(
    shape = self.shape,
    storage_type = self.properties.storage_type,
    dtype = self.properties.dtype,
    name = self.properties.name,
    description = self.properties.description,
    created_at = self.properties.created_at,
    modified_at = time.time(),
    tags = self.properties.tags.copy(),
    metadata = self.properties.metadata.copy()
    #         )
            return Matrix(new_data, new_properties)

    #     def reshape(self, new_shape: Tuple[int, int]) -> 'Matrix':
    #         """Reshape matrix to new dimensions"""
    #         if new_shape[0] * new_shape[1] != self.rows * self.cols:
                raise MatrixShapeError(f"Cannot reshape {self.shape} to {new_shape}")

    #         # Flatten the matrix
    flattened = []
    #         for row in self.data:
                flattened.extend(row)

    #         # Build new matrix
    new_data = []
    #         for i in range(new_shape[0]):
    start_idx = math.multiply(i, new_shape[1])
    end_idx = math.add(start_idx, new_shape[1])
                new_data.append(flattened[start_idx:end_idx])

            return Matrix(new_data, MatrixProperties(new_shape))

    #     def flatten(self) -> List[Any]:
    #         """Flatten matrix to 1D list"""
    flattened = []
    #         for row in self.data:
                flattened.extend(row)
    #         return flattened

    #     def diagonal(self) -> List[Any]:
    #         """Get diagonal elements of matrix"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Diagonal only defined for square matrices")

    diag = []
    #         for i in range(self.rows):
                diag.append(self.data[i][i])
    #         return diag

    #     def set_diagonal(self, values: List[Any]) -> 'Matrix':
    #         """Set diagonal elements of matrix"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Diagonal only defined for square matrices")

    #         if len(values) != self.rows:
                raise MatrixShapeError(f"Expected {self.rows} diagonal values, got {len(values)}")

    result = self.copy()
    #         for i in range(self.rows):
    result.data[i][i] = values[i]

    #         return result

    #     def norm(self, p: int = 2) -> float:
    #         """Calculate matrix p-norm"""
    #         if p == 1:
    #             # Column-sum norm
    #             return max(sum(abs(self.data[i][j]) for i in range(self.rows)) for j in range(self.cols))
    #         elif p == 2:
                # Spectral norm (largest singular value)
    #             # For now, use Frobenius norm as approximation
                return self.frobenius_norm()
    #         elif p == float('inf'):
    #             # Row-sum norm
    #             return max(sum(abs(self.data[i][j]) for j in range(self.cols)) for i in range(self.rows))
    #         else:
                raise ValueError(f"Unsupported norm: {p}")

    #     def frobenius_norm(self) -> float:
    #         """Calculate Frobenius norm"""
    #         return math.sqrt(sum(abs(self.data[i][j]) ** 2 for i in range(self.rows) for j in range(self.cols)))

    #     def rank(self) -> int:
    #         """Calculate matrix rank using Gaussian elimination"""
    #         # Create a copy of the matrix
    #         mat = [row.copy() for row in self.data]
    rank = 0

    #         # Gaussian elimination
    #         for col in range(self.cols):
    #             if rank >= self.rows:
    #                 break

    #             # Find pivot
    pivot_row = math.subtract(, 1)
    #             for row in range(rank, self.rows):
    #                 if mat[row][col] != 0:
    pivot_row = row
    #                     break

    #             if pivot_row == -1:
    #                 continue

    #             # Swap rows if needed
    #             if pivot_row != rank:
    mat[rank], mat[pivot_row] = mat[pivot_row], mat[rank]

    #             # Eliminate column
    #             for row in range(rank + 1, self.rows):
    factor = math.divide(mat[row][col], mat[rank][col])
    #                 for c in range(col, self.cols):
    mat[row][c] - = math.multiply(factor, mat[rank][c])

    rank + = 1

    #         return rank

    #     def eigenvalues(self) -> List[complex]:
            """Calculate eigenvalues (simplified implementation)"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Eigenvalues only defined for square matrices")

    #         # For small matrices, use direct computation
    #         if self.rows == 1:
    #             return [self.data[0][0]]
    #         elif self.rows == 2:
    a, b, c, d = self.data[0][0], self.data[0][1], self.data[1][0], self.data[1][1]
    trace = math.add(a, d)
    det = math.multiply(a, d - b * c)
    discriminant = math.multiply(trace, * 2 - 4 * det)
    #             if discriminant >= 0:
                    return [(trace + math.sqrt(discriminant)) / 2, (trace - math.sqrt(discriminant)) / 2]
    #             else:
    real_part = math.divide(trace, 2)
    imag_part = math.subtract(math.sqrt(, discriminant) / 2)
                    return [complex(real_part, imag_part), complex(real_part, -imag_part)]
    #         else:
    #             # For larger matrices, use numpy's eigenvalue computation
    #             try:
    np_matrix = np.array(self.data, dtype=float)
    eigenvalues = np.linalg.eigvals(np_matrix)
                    return eigenvalues.tolist()
    #             except:
                    raise MatrixOperationError("Could not compute eigenvalues")

    #     def eigenvectors(self) -> Tuple[List[complex], List[List[complex]]]:
    #         """Calculate eigenvectors and eigenvalues"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Eigenvectors only defined for square matrices")

    #         try:
    np_matrix = np.array(self.data, dtype=float)
    eigenvalues, eigenvectors = np.linalg.eig(np_matrix)
                return eigenvalues.tolist(), eigenvectors.tolist()
    #         except:
                raise MatrixOperationError("Could not compute eigenvectors")

    #     def singular_values(self) -> List[float]:
    #         """Calculate singular values"""
    #         try:
    np_matrix = np.array(self.data, dtype=float)
    return np.linalg.svd(np_matrix, compute_uv = False).tolist()
    #         except:
                raise MatrixOperationError("Could not compute singular values")

    #     def condition_number(self, p: int = 2) -> float:
    #         """Calculate condition number"""
    #         if p == 2:
    #             # Use largest singular value
    svs = self.singular_values()
    #             if not svs:
                    return float('inf')
                return max(svs) / min(svs)
    #         else:
    #             raise ValueError(f"Unsupported norm for condition number: {p}")

    #     def solve(self, b: 'Matrix') -> 'Matrix':
    """Solve linear system Ax = b"""
    #         if self.rows != self.cols:
                raise MatrixShapeError("System matrix must be square")

    #         if b.rows != self.rows:
    #             raise MatrixShapeError("Matrix dimensions don't match for system solution")

    #         try:
    #             # Use numpy to solve the system
    A = np.array(self.data, dtype=float)
    B = np.array(b.data, dtype=float)
    X = np.linalg.solve(A, B)

    result_data = X.tolist()
                return Matrix(result_data, MatrixProperties((self.rows, b.cols)))
    #         except np.linalg.LinAlgError:
                raise MatrixOperationError("Could not solve linear system")

    #     def lu_decomposition(self) -> Tuple['Matrix', 'Matrix', 'Matrix']:
    #         """Perform LU decomposition"""
    #         if not self.is_square:
    #             raise MatrixShapeError("LU decomposition only defined for square matrices")

    n = self.rows
    #         L = [[0.0] * n for _ in range(n)]
    #         U = [[0.0] * n for _ in range(n)]

    #         # Copy the matrix
    #         A = [row.copy() for row in self.data]

    #         for i in range(n):
    #             # Upper triangular matrix
    #             for k in range(i, n):
    sum = 0
    #                 for j in range(i):
    sum + = math.multiply(L[i][j], U[j][k])
    U[i][k] = math.subtract(A[i][k], sum)

    #             # Lower triangular matrix
    #             for k in range(i, n):
    #                 if i == k:
    L[i][i] = 1
    #                 else:
    sum = 0
    #                     for j in range(i):
    sum + = math.multiply(L[k][j], U[j][i])
    L[k][i] = math.subtract((A[k][i], sum) / U[i][i])

    L_matrix = Matrix(L, MatrixProperties((n, n)))
    U_matrix = Matrix(U, MatrixProperties((n, n)))
    #         P_matrix = identity_matrix(n)  # Identity permutation matrix for now

    #         return P_matrix, L_matrix, U_matrix

    #     def qr_decomposition(self) -> Tuple['Matrix', 'Matrix']:
    #         """Perform QR decomposition using Gram-Schmidt"""
    #         if not self.is_square:
    #             # For rectangular matrices, we can still do QR
    #             pass

    m, n = self.rows, self.cols
    #         Q = [[0.0] * m for _ in range(m)]
    #         R = [[0.0] * n for _ in range(n)]

    #         # Copy the matrix
    #         A = [row.copy() for row in self.data]

    #         # Gram-Schmidt process
    #         for j in range(n):
    #             # Copy column j of A into v
    #             v = [A[i][j] for i in range(m)]

    #             # Subtract projections onto previous columns
    #             for i in range(j):
    #                 # Compute projection
    #                 dot_product = sum(Q[i][k] * A[k][j] for k in range(m))
    R[i][j] = dot_product

    #                 # Subtract projection
    #                 for k in range(m):
    v[k] - = math.multiply(Q[i][k], R[i][j])

    #             # Normalize v to get Q column
    #             norm_v = math.sqrt(sum(v[k] ** 2 for k in range(m)))
    #             if norm_v == 0:
                    raise MatrixOperationError("QR decomposition failed: zero vector encountered")

    R[j][j] = norm_v
    #             for k in range(m):
    Q[k][j] = math.divide(v[k], norm_v)

    Q_matrix = Matrix(Q, MatrixProperties((m, m)))
    R_matrix = Matrix(R, MatrixProperties((m, n)))

    #         return Q_matrix, R_matrix

    #     def cholesky_decomposition(self) -> 'Matrix':
    #         """Perform Cholesky decomposition"""
    #         if not self.is_square:
    #             raise MatrixShapeError("Cholesky decomposition only defined for square matrices")

    #         if not self.is_symmetric():
    #             raise MatrixOperationError("Matrix must be symmetric for Cholesky decomposition")

    n = self.rows
    #         L = [[0.0] * n for _ in range(n)]

    #         for i in range(n):
    #             for j in range(i + 1):
    #                 if i == j:
    #                     # Sum of squares of elements in row
    #                     sum_sq = sum(L[i][k] ** 2 for k in range(j))
    diff = math.subtract(self.data[i][i], sum_sq)
    #                     if diff <= 0:
                            raise MatrixOperationError("Matrix is not positive definite")
    L[i][j] = math.sqrt(diff)
    #                 else:
    #                     # Sum of products
    #                     sum_prod = sum(L[i][k] * L[j][k] for k in range(j))
    L[i][j] = math.subtract((self.data[i][j], sum_prod) / L[j][j])

            return Matrix(L, MatrixProperties((n, n)))

    #     def svd_decomposition(self) -> Tuple['Matrix', 'Matrix', 'Matrix']:
    #         """Perform Singular Value Decomposition"""
    #         try:
    np_matrix = np.array(self.data, dtype=float)
    U, S, Vh = np.linalg.svd(np_matrix)

    #             # Convert to matrices
    U_matrix = Matrix(U.tolist(), MatrixProperties((self.rows, self.rows)))
    #             S_matrix = Matrix([[S[i] if i == j else 0 for j in range(min(self.rows, self.cols))]
    #                               for i in range(min(self.rows, self.cols))],
                                 MatrixProperties((min(self.rows, self.cols), min(self.rows, self.cols))))
    V_matrix = Matrix(Vh.T.tolist(), MatrixProperties((self.cols, self.cols)))

    #             return U_matrix, S_matrix, V_matrix
    #         except:
                raise MatrixOperationError("Could not perform SVD decomposition")

    #     def mean(self, axis: Optional[int] = None) -> Union[float, List[float], 'Matrix']:
    #         """Calculate mean of matrix elements"""
    #         if axis is None:
    #             # Mean of all elements
    #             total = sum(sum(row) for row in self.data)
                return total / (self.rows * self.cols)
    #         elif axis == 0:
                # Mean along columns (row-wise)
    means = []
    #             for j in range(self.cols):
    #                 col_sum = sum(self.data[i][j] for i in range(self.rows))
                    means.append(col_sum / self.rows)
    #             return means
    #         elif axis == 1:
                # Mean along rows (column-wise)
    means = []
    #             for i in range(self.rows):
    #                 row_sum = sum(self.data[i][j] for j in range(self.cols))
                    means.append(row_sum / self.cols)
    #             return means
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def std(self, axis: Optional[int] = None) -> Union[float, List[float], 'Matrix']:
    #         """Calculate standard deviation of matrix elements"""
    #         if axis is None:
    #             # Standard deviation of all elements
    mean_val = self.mean()
    variance = math.multiply(sum((self.data[i][j] - mean_val), * 2)
    #                           for i in range(self.rows) for j in range(self.cols)) / (self.rows * self.cols)
                return math.sqrt(variance)
    #         elif axis == 0:
                # Standard deviation along columns (row-wise)
    means = self.mean(axis=0)
    stds = []
    #             for j in range(self.cols):
    #                 variance = sum((self.data[i][j] - means[j]) ** 2 for i in range(self.rows)) / self.rows
                    stds.append(math.sqrt(variance))
    #             return stds
    #         elif axis == 1:
                # Standard deviation along rows (column-wise)
    means = self.mean(axis=1)
    stds = []
    #             for i in range(self.rows):
    #                 variance = sum((self.data[i][j] - means[i]) ** 2 for j in range(self.cols)) / self.cols
                    stds.append(math.sqrt(variance))
    #             return stds
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def var(self, axis: Optional[int] = None) -> Union[float, List[float], 'Matrix']:
    #         """Calculate variance of matrix elements"""
    #         if axis is None:
    #             # Variance of all elements
    mean_val = self.mean()
                return sum((self.data[i][j] - mean_val) ** 2
    #                       for i in range(self.rows) for j in range(self.cols)) / (self.rows * self.cols)
    #         elif axis == 0:
                # Variance along columns (row-wise)
    means = self.mean(axis=0)
    vars = []
    #             for j in range(self.cols):
    #                 vars.append(sum((self.data[i][j] - means[j]) ** 2 for i in range(self.rows)) / self.rows)
    #             return vars
    #         elif axis == 1:
                # Variance along rows (column-wise)
    means = self.mean(axis=1)
    vars = []
    #             for i in range(self.rows):
    #                 vars.append(sum((self.data[i][j] - means[i]) ** 2 for j in range(self.cols)) / self.cols)
    #             return vars
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def max(self, axis: Optional[int] = None) -> Union[Any, List[Any], 'Matrix']:
            """Find maximum value(s) in matrix"""
    #         if axis is None:
    #             # Maximum of all elements
    #             return max(max(row) for row in self.data)
    #         elif axis == 0:
                # Maximum along columns (row-wise)
    max_vals = []
    #             for j in range(self.cols):
    #                 max_vals.append(max(self.data[i][j] for i in range(self.rows)))
    #             return max_vals
    #         elif axis == 1:
                # Maximum along rows (column-wise)
    max_vals = []
    #             for i in range(self.rows):
    #                 max_vals.append(max(self.data[i][j] for j in range(self.cols)))
    #             return max_vals
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def min(self, axis: Optional[int] = None) -> Union[Any, List[Any], 'Matrix']:
            """Find minimum value(s) in matrix"""
    #         if axis is None:
    #             # Minimum of all elements
    #             return min(min(row) for row in self.data)
    #         elif axis == 0:
                # Minimum along columns (row-wise)
    min_vals = []
    #             for j in range(self.cols):
    #                 min_vals.append(min(self.data[i][j] for i in range(self.rows)))
    #             return min_vals
    #         elif axis == 1:
                # Minimum along rows (column-wise)
    min_vals = []
    #             for i in range(self.rows):
    #                 min_vals.append(min(self.data[i][j] for j in range(self.cols)))
    #             return min_vals
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def sum(self, axis: Optional[int] = None) -> Union[Any, List[Any], 'Matrix']:
    #         """Sum of matrix elements"""
    #         if axis is None:
    #             # Sum of all elements
    #             return sum(sum(row) for row in self.data)
    #         elif axis == 0:
                # Sum along columns (row-wise)
    sums = []
    #             for j in range(self.cols):
    #                 sums.append(sum(self.data[i][j] for i in range(self.rows)))
    #             return sums
    #         elif axis == 1:
                # Sum along rows (column-wise)
    sums = []
    #             for i in range(self.rows):
    #                 sums.append(sum(self.data[i][j] for j in range(self.cols)))
    #             return sums
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def apply(self, func: Callable[[Any], Any]) -> 'Matrix':
    #         """Apply function to each element of matrix"""
    result_data = []
    #         for i in range(self.rows):
    row = []
    #             for j in range(self.cols):
                    row.append(func(self.data[i][j]))
                result_data.append(row)

            return Matrix(result_data, MatrixProperties(self.shape))

    #     def map(self, func: Callable[[Any], Any]) -> 'Matrix':
    #         """Alias for apply method"""
            return self.apply(func)

    #     def reduce(self, func: Callable[[Any, Any], Any], axis: Optional[int] = None, initial: Optional[Any] = None) -> Union[Any, List[Any], 'Matrix']:
    #         """Reduce matrix using function"""
    #         if axis is None:
    #             # Reduce all elements
    #             values = [item for row in self.data for item in row]
    #             if initial is not None:
                    return reduce(func, values, initial)
    #             else:
                    return reduce(func, values)
    #         elif axis == 0:
                # Reduce along columns (row-wise)
    results = []
    #             for j in range(self.cols):
    #                 values = [self.data[i][j] for i in range(self.rows)]
    #                 if initial is not None:
                        results.append(reduce(func, values, initial))
    #                 else:
                        results.append(reduce(func, values))
    #             return results
    #         elif axis == 1:
                # Reduce along rows (column-wise)
    results = []
    #             for i in range(self.rows):
    values = self.data[i]
    #                 if initial is not None:
                        results.append(reduce(func, values, initial))
    #                 else:
                        results.append(reduce(func, values))
    #             return results
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def filter(self, func: Callable[[Any], bool]) -> 'Matrix':
    #         """Filter elements in matrix based on predicate"""
    #         # Flatten matrix first
    #         filtered_values = [x for row in self.data for x in row if func(x)]

    #         if not filtered_values:
                return Matrix([[0]], MatrixProperties((1, 1)))

            # Find new dimensions (square-ish)
    total_elements = len(filtered_values)
    new_rows = math.ceil(math.sqrt(total_elements))
    new_cols = math.divide(math.ceil(total_elements, new_rows))

    #         # Pad with zeros if needed
    #         while len(filtered_values) < new_rows * new_cols:
                filtered_values.append(0)

    #         # Build new matrix
    result_data = []
    #         for i in range(new_rows):
    start_idx = math.multiply(i, new_cols)
    end_idx = math.add(start_idx, new_cols)
                result_data.append(filtered_values[start_idx:end_idx])

            return Matrix(result_data, MatrixProperties((new_rows, new_cols)))

    #     def all(self, axis: Optional[int] = None) -> Union[bool, List[bool], 'Matrix']:
    #         """Check if all elements are True"""
    #         if axis is None:
    #             return all(all(x for x in row) for row in self.data)
    #         elif axis == 0:
    #             return [all(self.data[i][j] for i in range(self.rows)) for j in range(self.cols)]
    #         elif axis == 1:
    #             return [all(self.data[i][j] for j in range(self.cols)) for i in range(self.rows)]
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def any(self, axis: Optional[int] = None) -> Union[bool, List[bool], 'Matrix']:
    #         """Check if any element is True"""
    #         if axis is None:
    #             return any(any(x for x in row) for row in self.data)
    #         elif axis == 0:
    #             return [any(self.data[i][j] for i in range(self.rows)) for j in range(self.cols)]
    #         elif axis == 1:
    #             return [any(self.data[i][j] for j in range(self.cols)) for i in range(self.rows)]
    #         else:
                raise ValueError(f"Invalid axis: {axis}")

    #     def clip(self, min_val: Any, max_val: Any) -> 'Matrix':
    #         """Clip values to specified range"""
    #         def clip_func(x):
                return max(min(x, max_val), min_val)

            return self.apply(clip_func)

    #     def round(self, decimals: int = 0) -> 'Matrix':
    #         """Round all elements to specified decimals"""
    #         def round_func(x):
    #             if isinstance(x, (int, float)):
                    return round(x, decimals)
    #             return x

            return self.apply(round_func)

    #     def abs(self) -> 'Matrix':
    #         """Get absolute value of all elements"""
            return self.apply(abs)

    #     def sign(self) -> 'Matrix':
    #         """Get sign of all elements"""
    #         def sign_func(x):
    #             if x > 0:
    #                 return 1
    #             elif x < 0:
    #                 return -1
    #             else:
    #                 return 0

            return self.apply(sign_func)

    #     def log(self, base: Optional[float] = None) -> 'Matrix':
    #         """Apply logarithm to all elements"""
    #         def log_func(x):
    #             if base is None:
                    return math.log(x)
    #             else:
                    return math.log(x, base)

            return self.apply(log_func)

    #     def exp(self) -> 'Matrix':
    #         """Apply exponential to all elements"""
            return self.apply(math.exp)

    #     def sqrt(self) -> 'Matrix':
    #         """Apply square root to all elements"""
            return self.apply(math.sqrt)

    #     def sin(self) -> 'Matrix':
    #         """Apply sine to all elements"""
            return self.apply(math.sin)

    #     def cos(self) -> 'Matrix':
    #         """Apply cosine to all elements"""
            return self.apply(math.cos)

    #     def tan(self) -> 'Matrix':
    #         """Apply tangent to all elements"""
            return self.apply(math.tan)

    #     def asin(self) -> 'Matrix':
    #         """Apply arcsine to all elements"""
            return self.apply(math.asin)

    #     def acos(self) -> 'Matrix':
    #         """Apply arccosine to all elements"""
            return self.apply(math.acos)

    #     def atan(self) -> 'Matrix':
    #         """Apply arctangent to all elements"""
            return self.apply(math.atan)

    #     def sinh(self) -> 'Matrix':
    #         """Apply hyperbolic sine to all elements"""
            return self.apply(math.sinh)

    #     def cosh(self) -> 'Matrix':
    #         """Apply hyperbolic cosine to all elements"""
            return self.apply(math.cosh)

    #     def tanh(self) -> 'Matrix':
    #         """Apply hyperbolic tangent to all elements"""
            return self.apply(math.tanh)

    #     def to_numpy(self) -> np.ndarray:
    #         """Convert matrix to numpy array"""
            return np.array(self.data)

    #     @classmethod
    #     def from_numpy(cls, array: np.ndarray, **kwargs) -> 'Matrix':
    #         """Create matrix from numpy array"""
    data = array.tolist()
    properties = MatrixProperties(
    shape = array.shape,
    #             **kwargs
    #         )
            return cls(data, properties)

    #     def to_list(self) -> List[List[Any]]:
    #         """Convert matrix to nested list"""
    #         return self.data

    #     @classmethod
    #     def from_list(cls, data: List[List[Any]], **kwargs) -> 'Matrix':
    #         """Create matrix from nested list"""
    properties = MatrixProperties(
    #             shape=(len(data), len(data[0]) if data else 0),
    #             **kwargs
    #         )
            return cls(data, properties)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert matrix to dictionary"""
    #         return {
    #             'data': self.data,
    #             'properties': {
    #                 'shape': self.properties.shape,
    #                 'storage_type': self.properties.storage_type.value,
                    'dtype': str(self.properties.dtype),
    #                 'name': self.properties.name,
    #                 'description': self.properties.description,
    #                 'created_at': self.properties.created_at,
    #                 'modified_at': self.properties.modified_at,
    #                 'tags': self.properties.tags,
    #                 'metadata': self.properties.metadata
    #             }
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'Matrix':
    #         """Create matrix from dictionary"""
    matrix_data = data['data']
    properties_data = data['properties']

    properties = MatrixProperties(
    shape = tuple(properties_data['shape']),
    storage_type = MatrixStorageType(properties_data['storage_type']),
    #             dtype=eval(properties_data['dtype']),  # Be careful with eval in production
    name = properties_data.get('name'),
    description = properties_data.get('description'),
    created_at = properties_data.get('created_at'),
    modified_at = properties_data.get('modified_at'),
    tags = properties_data.get('tags', []),
    metadata = properties_data.get('metadata', {})
    #         )

            return cls(matrix_data, properties)

    #     def save(self, filename: str, format: str = 'json') -> None:
    #         """Save matrix to file"""
    #         if format.lower() == 'json':
    #             import json
    #             with open(filename, 'w') as f:
    json.dump(self.to_dict(), f, indent = 2)
    #         elif format.lower() == 'csv':
    #             import csv
    #             with open(filename, 'w', newline='') as f:
    writer = csv.writer(f)
    #                 for row in self.data:
                        writer.writerow(row)
    #         else:
                raise ValueError(f"Unsupported format: {format}")

    #     @classmethod
    #     def load(cls, filename: str, format: str = 'json') -> 'Matrix':
    #         """Load matrix from file"""
    #         if format.lower() == 'json':
    #             import json
    #             with open(filename, 'r') as f:
    data = json.load(f)
                return cls.from_dict(data)
    #         elif format.lower() == 'csv':
    #             import csv
    data = []
    #             with open(filename, 'r') as f:
    reader = csv.reader(f)
    #                 for row in reader:
    #                     data.append([float(x) for x in row])
                return cls.from_list(data)
    #         else:
                raise ValueError(f"Unsupported format: {format}")


def identity_matrix(n: int, **kwargs) -> Matrix:
#     """Create identity matrix of size n x n"""
#     data = [[0.0] * n for _ in range(n)]
#     for i in range(n):
data[i][i] = 1.0

properties = MatrixProperties(
shape = (n, n),
#         **kwargs
#     )
    return Matrix(data, properties)


def zero_matrix(rows: int, cols: int, **kwargs) -> Matrix:
#     """Create zero matrix of specified dimensions"""
#     data = [[0.0] * cols for _ in range(rows)]

properties = MatrixProperties(
shape = (rows, cols),
#         **kwargs
#     )
    return Matrix(data, properties)


def ones_matrix(rows: int, cols: int, **kwargs) -> Matrix:
#     """Create matrix filled with ones"""
#     data = [[1.0] * cols for _ in range(rows)]

properties = MatrixProperties(
shape = (rows, cols),
#         **kwargs
#     )
    return Matrix(data, properties)


def diagonal_matrix(diagonal: List[Any], **kwargs) -> Matrix:
#     """Create diagonal matrix from diagonal elements"""
n = len(diagonal)
#     data = [[0.0] * n for _ in range(n)]
#     for i in range(n):
data[i][i] = diagonal[i]

properties = MatrixProperties(
shape = (n, n),
storage_type = MatrixStorageType.DIAGONAL,
#         **kwargs
#     )
    return Matrix(data, properties)


def random_matrix(rows: int, cols: int, min_val: float = 0.0, max_val: float = 1.0, **kwargs) -> Matrix:
#     """Create random matrix with values in specified range"""
#     import random
#     data = [[random.uniform(min_val, max_val) for _ in range(cols)] for _ in range(rows)]

properties = MatrixProperties(
shape = (rows, cols),
#         **kwargs
#     )
    return Matrix(data, properties)


def hilbert_matrix(n: int, **kwargs) -> Matrix:
#     """Create Hilbert matrix of size n x n"""
data = []
#     for i in range(n):
row = []
#         for j in range(n):
            row.append(1.0 / (i + j + 1))
        data.append(row)

properties = MatrixProperties(
shape = (n, n),
#         **kwargs
#     )
    return Matrix(data, properties)


def toeplitz_matrix(first_row: List[Any], first_col: List[Any], **kwargs) -> Matrix:
#     """Create Toeplitz matrix"""
#     if len(first_row) != len(first_col):
        raise ValueError("First row and first column must have the same length")

n = len(first_row)
data = []
#     for i in range(n):
row = []
#         for j in range(n):
#             if i == 0 and j == 0:
                row.append(first_row[0])
#             elif i == 0:
                row.append(first_row[j])
#             elif j == 0:
                row.append(first_col[i])
#             else:
                row.append(first_row[j - i])
        data.append(row)

properties = MatrixProperties(
shape = (n, n),
#         **kwargs
#     )
    return Matrix(data, properties)


def circulant_matrix(first_row: List[Any], **kwargs) -> Matrix:
#     """Create circulant matrix"""
n = len(first_row)
data = []
#     for i in range(n):
row = []
#         for j in range(n):
            row.append(first_row[(j - i) % n])
        data.append(row)

properties = MatrixProperties(
shape = (n, n),
#         **kwargs
#     )
    return Matrix(data, properties)


def block_matrix(blocks: List[List[Matrix]], **kwargs) -> Matrix:
#     """Create block matrix from list of matrices"""
#     if not blocks:
        return zero_matrix(0, 0, **kwargs)

#     # Check that all rows have the same number of blocks
num_blocks_row = len(blocks)
num_blocks_col = len(blocks[0])
#     for row in blocks:
#         if len(row) != num_blocks_col:
            raise ValueError("All rows must have the same number of blocks")

#     # Check that all blocks in a row have the same number of rows
#     for i in range(num_blocks_row):
block_rows = blocks[i][0].rows
#         for j in range(1, num_blocks_col):
#             if blocks[i][j].rows != block_rows:
                raise ValueError(f"All blocks in row {i} must have the same number of rows")

#     # Check that all blocks in a column have the same number of columns
#     for j in range(num_blocks_col):
block_cols = blocks[0][j].cols
#         for i in range(1, num_blocks_row):
#             if blocks[i][j].cols != block_cols:
                raise ValueError(f"All blocks in column {j} must have the same number of columns")

#     # Calculate total size
#     total_rows = sum(blocks[i][0].rows for i in range(num_blocks_row))
#     total_cols = sum(blocks[0][j].cols for j in range(num_blocks_col))

#     # Build block matrix
result_data = []
row_offset = 0
#     for i in range(num_blocks_row):
col_offset = 0
#         # Add rows for this block row
#         for _ in range(blocks[i][0].rows):
row = []
#             for j in range(num_blocks_col):
#                 # Add elements from this block
#                 for k in range(blocks[i][j].cols):
                    row.append(blocks[i][j].data[_][k])
#                 # Fill with zeros if needed (shouldn't happen with proper block sizing)
# col_offset + = blocks[i][j].cols
            result_data.append(row)
# row_offset + = blocks[i][0].rows

properties = MatrixProperties(
shape = (total_rows, total_cols),
#         **kwargs
#     )
    return Matrix(result_data, properties)


def kronecker_product(A: Matrix, B: Matrix, **kwargs) -> Matrix:
#     """Compute Kronecker product of two matrices"""
result_rows = math.multiply(A.rows, B.rows)
result_cols = math.multiply(A.cols, B.cols)

result_data = []
#     for i in range(A.rows):
#         for _ in range(B.rows):
row = []
#             for j in range(A.cols):
#                 for __ in range(B.cols):
                    row.append(A.data[i][j] * B.data[_][__])
            result_data.append(row)

properties = MatrixProperties(
shape = (result_rows, result_cols),
#         **kwargs
#     )
    return Matrix(result_data, properties)


def hadamard_product(A: Matrix, B: Matrix, **kwargs) -> Matrix:
    """Compute Hadamard (element-wise) product of two matrices"""
#     if A.shape != B.shape:
#         raise MatrixShapeError(f"Matrices must have the same shape for Hadamard product: {A.shape} vs {B.shape}")

result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(A.data[i][j] * B.data[i][j])
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def khatri_rao_product(A: Matrix, B: Matrix, **kwargs) -> Matrix:
#     """Compute Khatri-Rao product of two matrices"""
#     if A.rows != B.rows:
#         raise MatrixShapeError(f"Matrices must have the same number of rows for Khatri-Rao product: {A.rows} vs {B.rows}")

result_cols = math.multiply(A.cols, B.cols)
result_data = []

#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
#             for k in range(B.cols):
                row.append(A.data[i][j] * B.data[i][k])
        result_data.append(row)

properties = MatrixProperties(
shape = (A.rows, result_cols),
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_multiply(matrices: List[Matrix], **kwargs) -> Matrix:
#     """Perform element-wise multiplication of multiple matrices"""
#     if not matrices:
        raise ValueError("At least one matrix must be provided")

#     # Check all matrices have the same shape
shape = matrices[0].shape
#     for matrix in matrices[1:]:
#         if matrix.shape != shape:
            raise MatrixShapeError(f"All matrices must have the same shape: {shape} vs {matrix.shape}")

#     # Perform element-wise multiplication
result_data = []
#     for i in range(shape[0]):
row = []
#         for j in range(shape[1]):
product = 1
#             for matrix in matrices:
product * = matrix.data[i][j]
            row.append(product)
        result_data.append(row)

properties = MatrixProperties(
shape = shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_divide(A: Matrix, B: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise division of two matrices"""
#     if A.shape != B.shape:
#         raise MatrixShapeError(f"Matrices must have the same shape for element-wise division: {A.shape} vs {B.shape}")

result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
#             if B.data[i][j] == 0:
                raise MatrixOperationError(f"Division by zero at position ({i}, {j})")
            row.append(A.data[i][j] / B.data[i][j])
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_power(A: Matrix, exponent: float, **kwargs) -> Matrix:
#     """Perform element-wise power of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(A.data[i][j] ** exponent)
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_sqrt(A: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise square root of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
#             if A.data[i][j] < 0:
                raise MatrixOperationError(f"Square root of negative number at position ({i}, {j})")
            row.append(math.sqrt(A.data[i][j]))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_log(A: Matrix, base: Optional[float] = None, **kwargs) -> Matrix:
#     """Perform element-wise logarithm of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
value = A.data[i][j]
#             if value <= 0:
                raise MatrixOperationError(f"Logarithm of non-positive number at position ({i}, {j})")
#             if base is None:
                row.append(math.log(value))
#             else:
                row.append(math.log(value, base))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_exp(A: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise exponential of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(math.exp(A.data[i][j]))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_abs(A: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise absolute value of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(abs(A.data[i][j]))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_sin(A: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise sine of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(math.sin(A.data[i][j]))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_cos(A: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise cosine of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(math.cos(A.data[i][j]))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def elementwise_tan(A: Matrix, **kwargs) -> Matrix:
#     """Perform element-wise tangent of matrix"""
result_data = []
#     for i in range(A.rows):
row = []
#         for j in range(A.cols):
            row.append(math.tan(A.data[i][j]))
        result_data.append(row)

properties = MatrixProperties(
shape = A.shape,
#         **kwargs
#     )
    return Matrix(result_data, properties)


def horizontal_concat(matrices: List[Matrix], **kwargs) -> Matrix:
#     """Horizontally concatenate matrices"""
#     if not matrices:
        raise ValueError("At least one matrix must be provided")

#     # Check all matrices have the same number of rows
rows = matrices[0].rows
#     for matrix in matrices[1:]:
#         if matrix.rows != rows:
            raise MatrixShapeError(f"All matrices must have the same number of rows: {rows} vs {matrix.rows}")

#     # Concatenate horizontally
result_data = []
#     for i in range(rows):
row = []
#         for matrix in matrices:
            row.extend(matrix.data[i])
        result_data.append(row)

#     total_cols = sum(matrix.cols for matrix in matrices)
properties = MatrixProperties(
shape = (rows, total_cols),
#         **kwargs
#     )
    return Matrix(result_data, properties)


def vertical_concat(matrices: List[Matrix], **kwargs) -> Matrix:
#     """Vertically concatenate matrices"""
#     if not matrices:
        raise ValueError("At least one matrix must be provided")

#     # Check all matrices have the same number of columns
cols = matrices[0].cols
#     for matrix in matrices[1:]:
#         if matrix.cols != cols:
            raise MatrixShapeError(f"All matrices must have the same number of columns: {cols} vs {matrix.cols}")

#     # Concatenate vertically
result_data = []
#     for matrix in matrices:
        result_data.extend(matrix.data)

#     total_rows = sum(matrix.rows for matrix in matrices)
properties = MatrixProperties(
shape = (total_rows, cols),
#         **kwargs
#     )
    return Matrix(result_data, properties)


def stack(matrices: List[Matrix], axis: int = 0, **kwargs) -> 'Tensor':
#     """Stack matrices into a tensor along specified axis"""
#     # Import here to avoid circular imports
#     from .tensor import Tensor

#     if not matrices:
        raise ValueError("At least one matrix must be provided")

#     if axis not in [0, 1, 2]:
        raise ValueError("Axis must be 0, 1, or 2")

#     # Convert matrices to tensors
#     tensors = [tensor.from_matrix(matrix) for matrix in matrices]

#     # Stack them
return tensor.stack(tensors, axis = math.multiply(axis,, *kwargs))


# Example usage
if __name__ == "__main__"
    #     # Create a simple matrix
    matrix_data = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    matrix = Matrix.from_list(matrix_data, name="Example Matrix")

        print("Original matrix:")
        print(matrix)

    #     # Matrix operations
        print("\nMatrix operations:")
        print(f"Shape: {matrix.shape}")
        print(f"Is square: {matrix.is_square}")
        print(f"Transpose:\n{matrix.transpose()}")

    #     # Create identity matrix
    identity = identity_matrix(3)
        print(f"\nIdentity matrix:\n{identity}")

    #     # Matrix multiplication
    product = matrix.matmul(identity)
        print(f"\nMatrix multiplication result:\n{product}")

    #     # Element-wise operations
        print("\nElement-wise operations:")
    squared = elementwise_power(matrix, 2)
        print(f"Matrix squared:\n{squared}")

    #     # Statistical operations
        print("\nStatistical operations:")
        print(f"Mean: {matrix.mean()}")
        print(f"Standard deviation: {matrix.std()}")
        print(f"Maximum: {matrix.max()}")
        print(f"Minimum: {matrix.min()}")

    #     # Special matrices
        print("\nSpecial matrices:")
    random_mat = random_matrix(2, 3, min_val=0, max_val=10)
        print(f"Random matrix:\n{random_mat}")

    hilbert = hilbert_matrix(3)
        print(f"Hilbert matrix:\n{hilbert}")

    #     # Matrix decompositions
        print("\nMatrix decompositions:")
    #     try:
    Q, R = matrix.qr_decomposition()
            print(f"Q matrix:\n{Q}")
            print(f"R matrix:\n{R}")
    #     except MatrixOperationError as e:
            print(f"QR decomposition failed: {e}")

    #     # Save and load
        print("\nSave and load operations:")
    matrix.save("example_matrix.json", format = "json")
    loaded_matrix = Matrix.load("example_matrix.json", format="json")
        print(f"Loaded matrix:\n{loaded_matrix}")

    #     # Clean up
        os.remove("example_matrix.json")
