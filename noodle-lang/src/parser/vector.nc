# Converted from Python to NoodleCore
# Original file: src

# """
# Vector implementation for Noodle compiler.
# Provides vector operations and utilities.
# """

import typing.List
from dataclasses import dataclass
import enum.Enum
import math
import numpy as np
import functools.reduce
import threading
import .matrix.Matrix


class VectorShapeError(Exception)
    #     """Exception raised for vector shape mismatches"""
    #     pass


class VectorTypeError(Exception)
    #     """Exception raised for vector type mismatches"""
    #     pass


class VectorOperationError(Exception)
    #     """Exception raised for vector operation errors"""
    #     pass


class VectorStorageType(Enum)
    #     """Storage type for vector data"""
    DENSE = "dense"
    SPARSE = "sparse"
    ONE_HOT = "one-hot"


dataclass
class VectorProperties
    #     """Properties of a vector"""
    #     shape: Tuple[int, ...]
    storage_type: VectorStorageType = VectorStorageType.DENSE
    dtype: type = float
    name: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[float] = None
    modified_at: Optional[float] = None
    tags: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class Vector
    #     """Represents a vector with various operations"""
    #     data: List[Any]
    #     properties: VectorProperties
    _lock: threading.Lock = field(default_factory=threading.Lock)

    #     def __post_init__(self):
    #         """Initialize vector after creation"""
    #         if not self.data:
                raise ValueError("Vector data cannot be empty")

    #         # Validate shape
    #         if len(self.properties.shape) != 1:
                raise VectorShapeError(f"Vector shape must be 1D: {self.properties.shape}")

    #         if self.properties.shape[0] != len(self.data):
    self.properties.shape = (len(self.data),)

    #         # Set creation time if not set
    #         if self.properties.created_at is None:
    #             import time
    self.properties.created_at = time.time()

    self.properties.modified_at = time.time()

    #     @property
    #     def shape(self) -Tuple[int, ...]):
    #         """Get vector shape"""
    #         return self.properties.shape

    #     @property
    #     def size(self) -int):
    #         """Get vector size"""
    #         return self.shape[0]

    #     @property
    #     def magnitude(self) -float):
            """Get vector magnitude (L2 norm)"""
    #         return math.sqrt(sum(x ** 2 for x in self.data))

    #     @property
    #     def norm(self) -float):
    #         """Get vector L2 norm"""
    #         return self.magnitude

    #     def __str__(self) -str):
    #         """String representation of vector"""
            return f"Vector({self.shape}, {self.properties.storage_type.value})"

    #     def __repr__(self) -str):
    #         """Detailed string representation"""
    return f"Vector(data = {self.data}, properties={self.properties})"

    #     def __getitem__(self, key: Union[int, slice]) -Any):
    #         """Get element or slice from vector"""
    #         if isinstance(key, slice):
    #             return self.data[key]
    #         else:
    #             return self.data[key]

    #     def __setitem__(self, key: Union[int, slice], value: Any):
    #         """Set element or slice in vector"""
    #         with self._lock:
    #             if isinstance(key, slice):
    self.data[key] = value
    #             else:
    self.data[key] = value
    self.properties.modified_at = time.time()

    #     def __eq__(self, other: object) -bool):
    #         """Check if two vectors are equal"""
    #         if not isinstance(other, Vector):
    #             return False

    #         if self.shape != other.shape:
    #             return False

    return self.data == other.data

    #     def __neg__(self) -'Vector'):
    #         """Negate vector"""
    #         return Vector([-x for x in self.data], VectorProperties(self.shape))

    #     def __add__(self, other: Union['Vector', int, float]) -'Vector'):
    #         """Add vector with scalar or another vector"""
    #         if isinstance(other, (int, float)):
    #             return Vector([x + other for x in self.data], VectorProperties(self.shape))
    #         elif isinstance(other, Vector):
    #             if self.shape != other.shape:
                    raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")
    #             return Vector([x + y for x, y in zip(self.data, other.data)], VectorProperties(self.shape))
    #         else:
                raise VectorTypeError("Can only add Vector to Vector or scalar")

    #     def __radd__(self, other: Union[int, float]) -'Vector'):
    #         """Right add with scalar"""
            return self.__add__(other)

    #     def __sub__(self, other: Union['Vector', int, float]) -'Vector'):
    #         """Subtract vector with scalar or another vector"""
    #         if isinstance(other, (int, float)):
    #             return Vector([x - other for x in self.data], VectorProperties(self.shape))
    #         elif isinstance(other, Vector):
    #             if self.shape != other.shape:
                    raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")
    #             return Vector([x - y for x, y in zip(self.data, other.data)], VectorProperties(self.shape))
    #         else:
                raise VectorTypeError("Can only subtract Vector or scalar from Vector")

    #     def __rsub__(self, other: Union[int, float]) -'Vector'):
    #         """Right subtract with scalar"""
    #         return Vector([other - x for x in self.data], VectorProperties(self.shape))

    #     def __mul__(self, other: Union['Vector', int, float]) -'Vector'):
    #         """Multiply vector with scalar or another vector"""
    #         if isinstance(other, (int, float)):
    #             return Vector([x * other for x in self.data], VectorProperties(self.shape))
    #         elif isinstance(other, Vector):
    #             if self.shape != other.shape:
                    raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")
    #             return Vector([x * y for x, y in zip(self.data, other.data)], VectorProperties(self.shape))
    #         else:
    #             raise VectorTypeError("Can only multiply Vector with scalar or Vector")

    #     def __rmul__(self, other: Union[int, float]) -'Vector'):
    #         """Right multiply with scalar"""
            return self.__mul__(other)

    #     def __truediv__(self, other: Union['Vector', int, float]) -'Vector'):
    #         """Divide vector by scalar or another vector"""
    #         if isinstance(other, (int, float)):
    #             return Vector([x / other for x in self.data], VectorProperties(self.shape))
    #         elif isinstance(other, Vector):
    #             if self.shape != other.shape:
                    raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")
    #             return Vector([x / y for x, y in zip(self.data, other.data)], VectorProperties(self.shape))
    #         else:
                raise VectorTypeError("Can only divide Vector by scalar or Vector")

    #     def __rtruediv__(self, other: Union[int, float]) -'Vector'):
    #         """Right divide by scalar"""
    #         return Vector([other / x for x in self.data], VectorProperties(self.shape))

    #     def __pow__(self, exponent: Union[int, float]) -'Vector'):
    #         """Raise vector to power"""
    #         return Vector([x ** exponent for x in self.data], VectorProperties(self.shape))

    #     def __rpow__(self, other: Union[int, float]) -'Vector'):
    #         """Right raise to power"""
    #         return Vector([other ** x for x in self.data], VectorProperties(self.shape))

    #     def __abs__(self) -'Vector'):
    #         """Get absolute value of all elements"""
    #         return Vector([abs(x) for x in self.data], VectorProperties(self.shape))

    #     def __iter__(self):
    #         """Iterate over vector elements"""
            return iter(self.data)

    #     def __len__(self) -int):
    #         """Get vector length"""
    #         return self.size

    #     def dot(self, other: 'Vector') -Any):
    #         """Dot product with another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    #         return sum(x * y for x, y in zip(self.data, other.data))

    #     def cross(self, other: 'Vector') -'Vector'):
    #         """Cross product with another vector (only works for 3D vectors)"""
    #         if self.shape != (3,) or other.shape != (3,):
    #             raise VectorShapeError("Cross product only works for 3D vectors")

    x1, y1, z1 = self.data
    x2, y2, z2 = other.data

    result = [
    #             y1 * z2 - z1 * y2,
    #             z1 * x2 - x1 * z2,
    #             x1 * y2 - y1 * x2
    #         ]

            return Vector(result, VectorProperties((3,)))

    #     def outer(self, other: 'Vector') -'Matrix'):
    #         """Outer product with another vector"""
    rows = self.size
    cols = other.size

    result_data = []
    #         for x in self.data:
    #             row = [x * y for y in other.data]
                result_data.append(row)

            return Matrix(result_data, MatrixProperties((rows, cols)))

    #     def elementwise_multiply(self, other: 'Vector') -'Vector'):
    #         """Element-wise multiplication with another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    #         return Vector([x * y for x, y in zip(self.data, other.data)], VectorProperties(self.shape))

    #     def elementwise_divide(self, other: 'Vector') -'Vector'):
    #         """Element-wise division by another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    #         return Vector([x / y for x, y in zip(self.data, other.data)], VectorProperties(self.shape))

    #     def elementwise_power(self, exponent: Union[int, float]) -'Vector'):
    #         """Element-wise power"""
    #         return Vector([x ** exponent for x in self.data], VectorProperties(self.shape))

    #     def normalize(self, p: int = 2) -'Vector'):
    #         """Normalize vector to unit length"""
    #         if p = 2:
    #             # L2 norm
    norm = self.magnitude
    #             if norm = 0:
                    raise VectorOperationError("Cannot normalize zero vector")
    #             return Vector([x / norm for x in self.data], VectorProperties(self.shape))
    #         elif p = 1:
    #             # L1 norm
    #             norm = sum(abs(x) for x in self.data)
    #             if norm = 0:
                    raise VectorOperationError("Cannot normalize zero vector")
    #             return Vector([x / norm for x in self.data], VectorProperties(self.shape))
    #         else:
                raise ValueError(f"Unsupported norm: {p}")

    #     def project(self, other: 'Vector') -'Vector'):
    #         """Project this vector onto another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    dot_product = self.dot(other)
    #         other_norm_squared = sum(x ** 2 for x in other.data)

    #         if other_norm_squared = 0:
                raise VectorOperationError("Cannot project onto zero vector")

    scalar = math.divide(dot_product, other_norm_squared)
    #         return Vector([scalar * x for x in other.data], VectorProperties(self.shape))

    #     def orthogonal(self, other: 'Vector') -'Vector'):
    #         """Get component of this vector orthogonal to another vector"""
    projection = self.project(other)
    #         return self - projection

    #     def angle(self, other: 'Vector') -float):
            """Calculate angle between this vector and another vector (in radians)"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    dot_product = self.dot(other)
    norm_product = self.magnitude * other.magnitude

    #         if norm_product = 0:
    #             raise VectorOperationError("Cannot calculate angle with zero vector")

    cos_angle = math.divide(dot_product, norm_product)
            return math.acos(max(min(cos_angle, 1.0), -1.0))  # Clamp to avoid numerical errors

    #     def distance(self, other: 'Vector') -float):
    #         """Calculate Euclidean distance to another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    #         return math.sqrt(sum((x - y) ** 2 for x, y in zip(self.data, other.data)))

    #     def manhattan_distance(self, other: 'Vector') -float):
    #         """Calculate Manhattan distance to another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    #         return sum(abs(x - y) for x, y in zip(self.data, other.data))

    #     def cosine_similarity(self, other: 'Vector') -float):
    #         """Calculate cosine similarity with another vector"""
    #         if self.shape != other.shape:
                raise VectorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    dot_product = self.dot(other)
    norm_product = self.magnitude * other.magnitude

    #         if norm_product = 0:
    #             return 0.0

    #         return dot_product / norm_product

    #     def sum(self) -Any):
    #         """Sum all elements in vector"""
            return sum(self.data)

    #     def mean(self) -float):
    #         """Calculate mean of all elements"""
            return sum(self.data) / self.size

    #     def std(self) -float):
    #         """Calculate standard deviation of all elements"""
    mean_val = self.mean()
    #         variance = sum((x - mean_val) ** 2 for x in self.data) / self.size
            return math.sqrt(variance)

    #     def var(self) -float):
    #         """Calculate variance of all elements"""
    mean_val = self.mean()
    #         return sum((x - mean_val) ** 2 for x in self.data) / self.size

    #     def max(self) -Any):
    #         """Find maximum value in vector"""
            return max(self.data)

    #     def min(self) -Any):
    #         """Find minimum value in vector"""
            return min(self.data)

    #     def argmax(self) -int):
    #         """Find index of maximum value"""
            return self.data.index(max(self.data))

    #     def argmin(self) -int):
    #         """Find index of minimum value"""
            return self.data.index(min(self.data))

    #     def clip(self, min_val: Any, max_val: Any) -'Vector'):
    #         """Clip values to specified range"""
    #         return Vector([max(min(x, max_val), min_val) for x in self.data], VectorProperties(self.shape))

    #     def round(self, decimals: int = 0) -'Vector'):
    #         """Round all elements to specified decimals"""
    #         return Vector([round(x, decimals) for x in self.data], VectorProperties(self.shape))

    #     def sign(self) -'Vector'):
    #         """Get sign of all elements"""
    #         def sign_func(x):
    #             if x 0):
    #                 return 1
    #             elif x < 0:
    #                 return -1
    #             else:
    #                 return 0

    #         return Vector([sign_func(x) for x in self.data], VectorProperties(self.shape))

    #     def sqrt(self) -'Vector'):
    #         """Apply square root to all elements"""
    #         return Vector([math.sqrt(x) for x in self.data], VectorProperties(self.shape))

    #     def log(self, base: Optional[float] = None) -'Vector'):
    #         """Apply logarithm to all elements"""
    #         if base is None:
    #             return Vector([math.log(x) for x in self.data], VectorProperties(self.shape))
    #         else:
    #             return Vector([math.log(x, base) for x in self.data], VectorProperties(self.shape))

    #     def exp(self) -'Vector'):
    #         """Apply exponential to all elements"""
    #         return Vector([math.exp(x) for x in self.data], VectorProperties(self.shape))

    #     def sin(self) -'Vector'):
    #         """Apply sine to all elements"""
    #         return Vector([math.sin(x) for x in self.data], VectorProperties(self.shape))

    #     def cos(self) -'Vector'):
    #         """Apply cosine to all elements"""
    #         return Vector([math.cos(x) for x in self.data], VectorProperties(self.shape))

    #     def tan(self) -'Vector'):
    #         """Apply tangent to all elements"""
    #         return Vector([math.tan(x) for x in self.data], VectorProperties(self.shape))

    #     def asin(self) -'Vector'):
    #         """Apply arcsine to all elements"""
    #         return Vector([math.asin(x) for x in self.data], VectorProperties(self.shape))

    #     def acos(self) -'Vector'):
    #         """Apply arccosine to all elements"""
    #         return Vector([math.acos(x) for x in self.data], VectorProperties(self.shape))

    #     def atan(self) -'Vector'):
    #         """Apply arctangent to all elements"""
    #         return Vector([math.atan(x) for x in self.data], VectorProperties(self.shape))

    #     def sinh(self) -'Vector'):
    #         """Apply hyperbolic sine to all elements"""
    #         return Vector([math.sinh(x) for x in self.data], VectorProperties(self.shape))

    #     def cosh(self) -'Vector'):
    #         """Apply hyperbolic cosine to all elements"""
    #         return Vector([math.cosh(x) for x in self.data], VectorProperties(self.shape))

    #     def tanh(self) -'Vector'):
    #         """Apply hyperbolic tangent to all elements"""
    #         return Vector([math.tanh(x) for x in self.data], VectorProperties(self.shape))

    #     def apply(self, func: Callable[[Any], Any]) -'Vector'):
    #         """Apply function to each element of vector"""
    #         return Vector([func(x) for x in self.data], VectorProperties(self.shape))

    #     def map(self, func: Callable[[Any], Any]) -'Vector'):
    #         """Alias for apply method"""
            return self.apply(func)

    #     def filter(self, func: Callable[[Any], bool]) -'Vector'):
    #         """Filter elements in vector based on predicate"""
    #         filtered_values = [x for x in self.data if func(x)]
            return Vector(filtered_values, VectorProperties((len(filtered_values),)))

    #     def reduce(self, func: Callable[[Any, Any], Any], initial: Optional[Any] = None) -Any):
    #         """Reduce vector using function"""
    #         if initial is not None:
                return reduce(func, self.data, initial)
    #         else:
                return reduce(func, self.data)

    #     def all(self) -bool):
    #         """Check if all elements are True"""
            return all(self.data)

    #     def any(self) -bool):
    #         """Check if any element is True"""
            return any(self.data)

    #     def copy(self) -'Vector'):
    #         """Create a copy of the vector"""
    new_data = self.data.copy()
    new_properties = VectorProperties(
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
            return Vector(new_data, new_properties)

    #     def reshape(self, new_shape: Tuple[int, ...]) -'Vector'):
    #         """Reshape vector (only works for 1D vectors)"""
    #         if len(new_shape) != 1:
                raise VectorShapeError("Vector can only be reshaped to 1D")

    #         if new_shape[0] != self.size:
                raise VectorShapeError(f"Cannot reshape vector of size {self.size} to shape {new_shape}")

            return Vector(self.data.copy(), VectorProperties(new_shape))

    #     def to_matrix(self, orientation: str = 'column') -Matrix):
    #         """Convert vector to matrix"""
    #         if orientation == 'column':
    #             data = [[x] for x in self.data]
    shape = (self.size, 1)
    #         elif orientation == 'row':
    data = [self.data]
    shape = (1, self.size)
    #         else:
                raise ValueError("Orientation must be 'column' or 'row'")

    properties = MatrixProperties(
    shape = shape,
    storage_type = self.properties.storage_type,
    dtype = self.properties.dtype,
    name = self.properties.name,
    description = self.properties.description,
    created_at = self.properties.created_at,
    modified_at = self.properties.modified_at,
    tags = self.properties.tags,
    metadata = self.properties.metadata
    #         )

            return Matrix(data, properties)

    #     def to_numpy(self) -np.ndarray):
    #         """Convert vector to numpy array"""
            return np.array(self.data)

    #     @classmethod
    #     def from_numpy(cls, array: np.ndarray, **kwargs) -'Vector'):
    #         """Create vector from numpy array"""
    #         if array.ndim != 1:
                raise VectorShapeError("Only 1D numpy arrays can be converted to vectors")

    data = array.tolist()
    properties = VectorProperties(
    shape = array.shape,
    #             **kwargs
    #         )
            return cls(data, properties)

    #     def to_tensor(self):
    #         """Convert vector to tensor"""
    #         # Import here to avoid circular imports
    #         from .tensor import Tensor

    return Tensor.from_list(self.data, (self.size,), dtype = self.properties.dtype)

    #     @classmethod
    #     def from_tensor(cls, tensor):
    #         """Create vector from tensor (only works for 1D tensors)"""
    #         from .tensor import Tensor

    #         if not isinstance(tensor, Tensor):
                raise VectorTypeError("Can only create vector from Tensor")

    #         if tensor.ndim != 1:
                raise VectorShapeError("Can only create vector from 1D tensors")

    return cls(tensor.data, VectorProperties(tensor.shape, dtype = tensor.properties.dtype))

    #     def to_list(self) -List[Any]):
    #         """Convert vector to list"""
    #         return self.data

    #     @classmethod
    #     def from_list(cls, data: List[Any], **kwargs) -'Vector'):
    #         """Create vector from list"""
    properties = VectorProperties(
    shape = (len(data),),
    #             **kwargs
    #         )
            return cls(data, properties)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert vector to dictionary"""
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
    #     def from_dict(cls, data: Dict[str, Any]) -'Vector'):
    #         """Create vector from dictionary"""
    vector_data = data['data']
    properties_data = data['properties']

    properties = VectorProperties(
    shape = tuple(properties_data['shape']),
    storage_type = VectorStorageType(properties_data['storage_type']),
    #             dtype=eval(properties_data['dtype']),  # Be careful with eval in production
    name = properties_data.get('name'),
    description = properties_data.get('description'),
    created_at = properties_data.get('created_at'),
    modified_at = properties_data.get('modified_at'),
    tags = properties_data.get('tags', []),
    metadata = properties_data.get('metadata', {})
    #         )

            return cls(vector_data, properties)

    #     def save(self, filename: str, format: str = 'json') -None):
    #         """Save vector to file"""
    #         if format.lower() == 'json':
    #             import json
    #             with open(filename, 'w') as f:
    json.dump(self.to_dict(), f, indent = 2)
    #         elif format.lower() == 'npy':
    np_array = self.to_numpy()
                np.save(filename, np_array)
    #         else:
                raise ValueError(f"Unsupported format: {format}")

    #     @classmethod
    #     def load(cls, filename: str, format: str = 'json') -'Vector'):
    #         """Load vector from file"""
    #         if format.lower() == 'json':
    #             import json
    #             with open(filename, 'r') as f:
    data = json.load(f)
                return cls.from_dict(data)
    #         elif format.lower() == 'npy':
    np_array = np.load(filename)
                return cls.from_numpy(np_array)
    #         else:
                raise ValueError(f"Unsupported format: {format}")

    #     def sort(self, reverse: bool = False) -'Vector'):
    #         """Return sorted copy of vector"""
    return Vector(sorted(self.data, reverse = reverse), VectorProperties(self.shape))

    #     def argsort(self, reverse: bool = False) -List[int]):
    #         """Return indices that would sort the vector"""
    return sorted(range(self.size), key = lambda i: self.data[i], reverse=reverse)

    #     def sort_indices(self, reverse: bool = False) -Tuple[List[int], 'Vector']):
    #         """Return indices and sorted values"""
    indices = self.argsort(reverse=reverse)
    #         sorted_values = [self.data[i] for i in indices]
            return indices, Vector(sorted_values, VectorProperties(self.shape))

    #     def unique(self) -'Vector'):
    #         """Return unique elements in vector"""
            return Vector(list(set(self.data)), VectorProperties((len(set(self.data)),)))

    #     def count(self, value: Any) -int):
    #         """Count occurrences of value in vector"""
            return self.data.count(value)

    #     def index(self, value: Any, start: int = 0, end: Optional[int] = None) -int):
    #         """Find index of value in vector"""
    #         if end is None:
    end = self.size
            return self.data.index(value, start, end)

    #     def insert(self, index: int, value: Any) -'Vector'):
    #         """Insert value at specified index"""
    new_data = self.data.copy()
            new_data.insert(index, value)
            return Vector(new_data, VectorProperties((len(new_data),)))

    #     def append(self, value: Any) -'Vector'):
    #         """Append value to vector"""
    new_data = self.data.copy()
            new_data.append(value)
            return Vector(new_data, VectorProperties((len(new_data),)))

    #     def extend(self, other: Union['Vector', List[Any]]) -'Vector'):
    #         """Extend vector with elements from another vector or list"""
    #         if isinstance(other, Vector):
    new_data = self.data + other.data
    #         else:
    new_data = self.data + other
            return Vector(new_data, VectorProperties((len(new_data),)))

    #     def remove(self, value: Any) -'Vector'):
    #         """Remove first occurrence of value"""
    new_data = self.data.copy()
            new_data.remove(value)
            return Vector(new_data, VectorProperties((len(new_data),)))

    #     def pop(self, index: Optional[int] = None) -Tuple[Any, 'Vector']):
    #         """Pop element at specified index (or last if None)"""
    new_data = self.data.copy()
    #         if index is None:
    value = new_data.pop()
    #         else:
    value = new_data.pop(index)
            return value, Vector(new_data, VectorProperties((len(new_data),)))

    #     def reverse(self) -'Vector'):
    #         """Return reversed copy of vector"""
            return Vector(list(reversed(self.data)), VectorProperties(self.shape))

    #     def slice(self, start: Optional[int] = None, stop: Optional[int] = None, step: Optional[int] = None) -'Vector'):
    #         """Return slice of vector"""
            return Vector(self.data[start:stop:step], VectorProperties((len(self.data[start:stop:step]),)))

    #     def head(self, n: int = 5) -'Vector'):
    #         """Return first n elements of vector"""
            return self.slice(0, n)

    #     def tail(self, n: int = 5) -'Vector'):
    #         """Return last n elements of vector"""
            return self.slice(-n)

    #     def sample(self, n: Optional[int] = None, replace: bool = False) -'Vector'):
    #         """Sample elements from vector"""
    #         import random

    #         if n is None:
    n = min(5, self.size)

    #         if replace:
    #             indices = [random.randint(0, self.size - 1) for _ in range(n)]
    #         else:
    indices = random.sample(range(self.size), min(n, self.size))

    #         sampled_data = [self.data[i] for i in indices]
            return Vector(sampled_data, VectorProperties((len(sampled_data),)))

    #     def linspace(self, start: float, stop: float, num: int = 50) -'Vector'):
    #         """Create vector with evenly spaced values"""
    #         if num < 1:
                raise ValueError("Number of samples must be at least 1")

    #         if num = 1:
                return Vector([start], VectorProperties((1,)))

    step = (stop - start / (num - 1))
    #         data = [start + i * step for i in range(num)]
            return Vector(data, VectorProperties((num,)))

    #     def arange(self, start: float, stop: Optional[float] = None, step: float = 1.0) -'Vector'):
    #         """Create vector with evenly spaced values within given interval"""
    #         if stop is None:
    stop = start
    start = 0.0

    #         if step = 0:
                raise ValueError("Step must be non-zero")

    data = []
    current = start

    #         if step 0):
    #             while current < stop:
                    data.append(current)
    current + = step
    #         else:
    #             while current stop):
                    data.append(current)
    current + = step

            return Vector(data, VectorProperties((len(data),)))

    #     def logspace(self, start: float, stop: float, num: int = 50, base: float = 10.0) -'Vector'):
    #         """Create vector with evenly spaced values on log scale"""
    #         if num < 1:
                raise ValueError("Number of samples must be at least 1")

    #         if num = 1:
                return Vector([base ** start], VectorProperties((1,)))

    log_start = start * math.log(base)
    log_stop = stop * math.log(base)
    step = (log_stop - log_start / (num - 1))

    #         data = [math.exp(log_start + i * step) for i in range(num)]
            return Vector(data, VectorProperties((num,)))

    #     def geomspace(self, start: float, stop: float, num: int = 50) -'Vector'):
    #         """Create vector with evenly spaced values on log scale (geometric progression)"""
    #         if num < 1:
                raise ValueError("Number of samples must be at least 1")

    #         if num = 1:
                return Vector([start], VectorProperties((1,)))

    log_start = math.log(start)
    log_stop = math.log(stop)
    step = (log_stop - log_start / (num - 1))

    #         data = [math.exp(log_start + i * step) for i in range(num)]
            return Vector(data, VectorProperties((num,)))

    #     def zeros(self, size: int) -'Vector'):
    #         """Create vector filled with zeros"""
            return Vector([0.0] * size, VectorProperties((size,)))

    #     def ones(self, size: int) -'Vector'):
    #         """Create vector filled with ones"""
            return Vector([1.0] * size, VectorProperties((size,)))

    #     def full(self, size: int, fill_value: Any) -'Vector'):
    #         """Create vector filled with specified value"""
            return Vector([fill_value] * size, VectorProperties((size,)))

    #     @classmethod
    #     def zeros_like(cls, other: 'Vector') -'Vector'):
    #         """Create vector of zeros with same shape and type as another vector"""
            return cls.zeros(other.size)

    #     @classmethod
    #     def ones_like(cls, other: 'Vector') -'Vector'):
    #         """Create vector of ones with same shape and type as another vector"""
            return cls.ones(other.size)

    #     @classmethod
    #     def full_like(cls, other: 'Vector', fill_value: Any) -'Vector'):
    #         """Create vector filled with specified value with same shape and type as another vector"""
            return cls.full(other.size, fill_value)

    #     def eye(self, size: int, k: int = 0) -'Vector'):
    #         """Create vector with ones at specified diagonal and zeros elsewhere (only for 1D)"""
    #         if k < 0 or k >= size:
                return Vector.zeros(size)

    data = [0.0] * size
    data[k] = 1.0
            return Vector(data, VectorProperties((size,)))

    #     @classmethod
    #     def random(cls, size: int, min_val: float = 0.0, max_val: float = 1.0) -'Vector'):
    #         """Create random vector with values in specified range"""
    #         import random
    #         data = [random.uniform(min_val, max_val) for _ in range(size)]
            return Vector(data, VectorProperties((size,)))

    #     @classmethod
    #     def normal(cls, size: int, mean: float = 0.0, std: float = 1.0) -'Vector'):
    #         """Create random vector with normal distribution"""
    #         import random
    #         data = [random.gauss(mean, std) for _ in range(size)]
            return Vector(data, VectorProperties((size,)))

    #     @classmethod
    #     def uniform(cls, size: int, min_val: float = 0.0, max_val: float = 1.0) -'Vector'):
    #         """Create random vector with uniform distribution"""
            return cls.random(size, min_val, max_val)

    #     def cumsum(self) -'Vector'):
    #         """Return cumulative sum of vector elements"""
    result = []
    current_sum = 0

    #         for x in self.data:
    current_sum + = x
                result.append(current_sum)

            return Vector(result, VectorProperties((len(result),)))

    #     def cumprod(self) -'Vector'):
    #         """Return cumulative product of vector elements"""
    result = []
    current_product = 1

    #         for x in self.data:
    current_product * = x
                result.append(current_product)

            return Vector(result, VectorProperties((len(result),)))

    #     def diff(self, n: int = 1) -'Vector'):
    #         """Calculate n-th order discrete difference along vector"""
    #         if n < 1:
                raise ValueError("Order must be at least 1")

    result = self.data.copy()

    #         for _ in range(n):
    new_result = []
    #             for i in range(1, len(result)):
                    new_result.append(result[i] - result[i - 1])
    result = new_result

            return Vector(result, VectorProperties((len(result),)))

    #     def gradient(self, edge_order: int = 1) -'Vector'):
    #         """Calculate gradient of vector"""
    #         if self.size < 2:
                raise VectorOperationError("Gradient requires at least 2 elements")

    #         if edge_order not in [1, 2]:
                raise ValueError("Edge order must be 1 or 2")

    #         if self.size = 2:
                return Vector([self.data[1] - self.data[0]] * 2, VectorProperties((2,)))

    gradient = []

    #         # First point
    #         if edge_order = 1:
                gradient.append(-3 * self.data[0] + 4 * self.data[1] - self.data[2])
    #         else:
                gradient.append((-11 * self.data[0] + 18 * self.data[1] - 9 * self.data[2] + 2 * self.data[3]) / 6)

    #         # Middle points
    #         for i in range(1, self.size - 1):
                gradient.append((self.data[i + 1] - self.data[i - 1]) / 2)

    #         # Last point
    #         if edge_order = 1:
                gradient.append(self.data[-3] - 4 * self.data[-2] + 3 * self.data[-1])
    #         else:
                gradient.append((11 * self.data[-1] - 18 * self.data[-2] + 9 * self.data[-3] - 2 * self.data[-4]) / 6)

            return Vector(gradient, VectorProperties((len(gradient),)))

    #     def convolve(self, other: 'Vector', mode: str = 'full') -'Vector'):
    #         """Convolve with another vector"""
    #         if self.size = 0 or other.size = 0:
                return Vector.zeros(0)

    a = self.data
    b = other.data

    #         if mode == 'full':
    result_length = len(a) + len(b - 1)
    result = [0.0] * result_length

    #             for i in range(result_length):
    #                 for j in range(max(0, i - len(b) + 1), min(i + 1, len(a))):
    result[i] + = a[j] * b[i - j]
    #         elif mode == 'same':
    result_length = max(len(a), len(b))
    result = [0.0] * result_length

    #             for i in range(result_length):
    #                 for j in range(max(0, i - len(b) + 1), min(i + 1, len(a))):
    #                     if 0 <= i - j < len(b):
    result[i] + = a[j] * b[i - j]
    #         elif mode == 'valid':
    result_length = max(len(a) + len(b) - min(len(a), len(b)), 1)
    result = [0.0] * result_length

    #             for i in range(result_length):
    #                 for j in range(len(b)):
    result[i] + = a[i + j] * b[j]
    #         else:
                raise ValueError("Mode must be 'full', 'same', or 'valid'")

            return Vector(result, VectorProperties((len(result),)))

    #     def correlate(self, other: 'Vector', mode: str = 'full') -'Vector'):
    #         """Cross-correlate with another vector"""
    #         # Flip the kernel for correlation
    flipped_other = Vector(other.data[:: - 1], VectorProperties(other.shape))
            return self.convolve(flipped_other, mode)

    #     def hamming(self, size: int) -'Vector'):
    #         """Create Hamming window of specified size"""
    #         if size < 1:
                raise ValueError("Size must be at least 1")

    data = []
    #         for i in range(size):
                data.append(0.54 - 0.46 * math.cos(2 * math.pi * i / (size - 1)))

            return Vector(data, VectorProperties((size,)))

    #     def hanning(self, size: int) -'Vector'):
    #         """Create Hanning window of specified size"""
    #         if size < 1:
                raise ValueError("Size must be at least 1")

    data = []
    #         for i in range(size):
                data.append(0.5 * (1 - math.cos(2 * math.pi * i / (size - 1))))

            return Vector(data, VectorProperties((size,)))

    #     def blackman(self, size: int) -'Vector'):
    #         """Create Blackman window of specified size"""
    #         if size < 1:
                raise ValueError("Size must be at least 1")

    data = []
    #         for i in range(size):
                data.append(0.42 - 0.5 * math.cos(2 * math.pi * i / (size - 1)) +
                           0.08 * math.cos(4 * math.pi * i / (size - 1)))

            return Vector(data, VectorProperties((size,)))

    #     def bartlett(self, size: int) -'Vector'):
    #         """Create Bartlett window of specified size"""
    #         if size < 1:
                raise ValueError("Size must be at least 1")

    data = []
    #         for i in range(size):
    #             if i < size / 2:
                    data.append(2 * i / (size - 1))
    #             else:
                    data.append(2 - 2 * i / (size - 1))

            return Vector(data, VectorProperties((size,)))

    #     def kaiser(self, size: int, beta: float = 14.0) -'Vector'):
    #         """Create Kaiser window of specified size"""
    #         if size < 1:
                raise ValueError("Size must be at least 1")

    #         try:
    #             from scipy.special import i0
    #         except ImportError:
    #             raise VectorOperationError("scipy is required for Kaiser window")

    data = []
    #         for i in range(size):
    x = 2 * i / (size - 1 - 1)
                data.append(i0(beta * math.sqrt(1 - x ** 2)) / i0(beta))

            return Vector(data, VectorProperties((size,)))

    #     def to_one_hot(self, num_classes: Optional[int] = None) -'Vector'):
    #         """Convert vector to one-hot encoding"""
    #         if not all(isinstance(x, int) for x in self.data):
    #             raise VectorTypeError("One-hot encoding only works with integer vectors")

    #         if num_classes is None:
    num_classes = max(self.data) + 1

    one_hot_data = []
    #         for val in self.data:
    #             if val < 0 or val >= num_classes:
    #                 raise ValueError(f"Value {val} out of range for {num_classes} classes")

    row = [0.0] * num_classes
    row[val] = 1.0
                one_hot_data.extend(row)

            return Vector(one_hot_data, VectorProperties((len(self.data) * num_classes,)),
    storage_type = VectorStorageType.ONE_HOT)

    #     def from_one_hot(self) -'Vector'):
    #         """Convert one-hot encoded vector back to class indices"""
    #         if self.properties.storage_type != VectorStorageType.ONE_HOT:
                raise VectorTypeError("Vector is not one-hot encoded")

    num_classes = int(math.sqrt(self.size))
    #         if num_classes * num_classes != self.size:
                raise ValueError("One-hot vector size must be a perfect square")

    class_indices = []
    #         for i in range(0, self.size, num_classes):
    row = self.data[i:i + num_classes]
    #             if sum(row) != 1:
                    raise ValueError("One-hot encoding is invalid")

    class_idx = row.index(1.0)
                class_indices.append(class_idx)

            return Vector(class_indices, VectorProperties((len(class_indices),)))


# Example usage
if __name__ == "__main__"
    #     # Create a simple vector
    vector_data = [1, 2, 3, 4, 5]
    vector = Vector.from_list(vector_data, name="Example Vector")

        print("Original vector:")
        print(vector)

    #     # Vector operations
        print("\nVector operations:")
        print(f"Shape: {vector.shape}")
        print(f"Size: {vector.size}")
        print(f"Magnitude: {vector.magnitude}")
        print(f"Sum: {vector.sum()}")
        print(f"Mean: {vector.mean()}")
        print(f"Standard deviation: {vector.std()}")

    #     # Element-wise operations
        print("\nElement-wise operations:")
    squared = vector.apply(lambda x: x * * 2)
        print(f"Squared: {squared}")

    #     # Vector operations
        print("\nVector operations:")
    other = Vector.from_list([5, 4, 3, 2, 1])
        print(f"Other vector: {other}")

    dot_product = vector.dot(other)
        print(f"Dot product: {dot_product}")

    distance = vector.distance(other)
        print(f"Euclidean distance: {distance}")

    cosine_sim = vector.cosine_similarity(other)
        print(f"Cosine similarity: {cosine_sim}")

    #     # Special vectors
        print("\nSpecial vectors:")
    zeros = Vector.zeros(5)
        print(f"Zeros: {zeros}")

    ones = Vector.ones(3)
        print(f"Ones: {ones}")

    random_vec = Vector.random(4, min_val=0, max_val=10)
        print(f"Random: {random_vec}")

    #     # Save and load
        print("\nSave and load operations:")
    vector.save("example_vector.json", format = "json")
    loaded_vector = Vector.load("example_vector.json", format="json")
        print(f"Loaded vector: {loaded_vector}")

    #     # Clean up
    #     import os
        os.remove("example_vector.json")
