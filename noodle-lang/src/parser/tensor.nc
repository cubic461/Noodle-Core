# Converted from Python to NoodleCore
# Original file: src

# """
# Tensor implementation for Noodle compiler.
# Provides multi-dimensional tensor operations and utilities.
# """

import typing.List
from dataclasses import dataclass
import enum.Enum
import math
import numpy as np
import functools.reduce
import threading
import .matrix.Matrix


class TensorShapeError(Exception)
    #     """Exception raised for tensor shape mismatches"""
    #     pass


class TensorTypeError(Exception)
    #     """Exception raised for tensor type mismatches"""
    #     pass


class TensorOperationError(Exception)
    #     """Exception raised for tensor operation errors"""
    #     pass


class TensorStorageType(Enum)
    #     """Storage type for tensor data"""
    DENSE = "dense"
    SPARSE = "sparse"
    DIAGONAL = "diagonal"
    SYMMETRIC = "symmetric"


dataclass
class TensorProperties
    #     """Properties of a tensor"""
    #     shape: Tuple[int, ...]
    storage_type: TensorStorageType = TensorStorageType.DENSE
    dtype: type = float
    name: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[float] = None
    modified_at: Optional[float] = None
    tags: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class Tensor
    #     """Represents a multi-dimensional tensor with various operations"""
    #     data: List[Any]
    #     properties: TensorProperties
    _lock: threading.Lock = field(default_factory=threading.Lock)

    #     def __post_init__(self):
    #         """Initialize tensor after creation"""
    #         if not self.data:
                raise ValueError("Tensor data cannot be empty")

    #         # Validate shape
    calculated_shape = self._calculate_shape(self.data)
    #         if self.properties.shape != calculated_shape:
    self.properties.shape = calculated_shape

    #         # Set creation time if not set
    #         if self.properties.created_at is None:
    #             import time
    self.properties.created_at = time.time()

    self.properties.modified_at = time.time()

    #     def _calculate_shape(self, data: Any) -Tuple[int, ...]):
    #         """Calculate the shape of nested data"""
    #         if isinstance(data, list):
    #             if not data:
                    return ()
    first_shape = self._calculate_shape(data[0])
    #             if first_shape:
                    return (len(data),) + first_shape
    #             else:
                    return (len(data),)
    #         else:
                return ()

    #     @property
    #     def shape(self) -Tuple[int, ...]):
    #         """Get tensor shape"""
    #         return self.properties.shape

    #     @property
    #     def ndim(self) -int):
    #         """Get number of dimensions"""
            return len(self.shape)

    #     @property
    #     def size(self) -int):
    #         """Get total number of elements"""
            return reduce(operator.mul, self.shape, 1)

    #     @property
    #     def is_scalar(self) -bool):
    #         """Check if tensor is a scalar"""
    return self.ndim = 0

    #     @property
    #     def is_vector(self) -bool):
    #         """Check if tensor is a vector"""
    return self.ndim = 1

    #     @property
    #     def is_matrix(self) -bool):
    #         """Check if tensor is a matrix"""
    return self.ndim = 2

    #     def __str__(self) -str):
    #         """String representation of tensor"""
            return f"Tensor({self.shape}, {self.properties.storage_type.value})"

    #     def __repr__(self) -str):
    #         """Detailed string representation"""
    return f"Tensor(data = {self.data}, properties={self.properties})"

    #     def __getitem__(self, key: Union[int, Tuple[int, ...]]) -Any):
    #         """Get element or slice from tensor"""
    #         if isinstance(key, tuple):
    current = self.data
    #             for k in key:
    current = current[k]
    #             return current
    #         else:
    #             return self.data[key]

    #     def __setitem__(self, key: Union[int, Tuple[int, ...]], value: Any):
    #         """Set element or slice in tensor"""
    #         with self._lock:
    #             if isinstance(key, tuple):
    current = self.data
    #                 for k in key[:-1]:
    current = current[k]
    current[key[-1]] = value
    #             else:
    self.data[key] = value
    self.properties.modified_at = time.time()

    #     def __eq__(self, other: object) -bool):
    #         """Check if two tensors are equal"""
    #         if not isinstance(other, Tensor):
    #             return False

    #         if self.shape != other.shape:
    #             return False

            return self._data_equal(self.data, other.data)

    #     def _data_equal(self, a: Any, b: Any) -bool):
    #         """Recursively check if nested data structures are equal"""
    #         if isinstance(a, list) and isinstance(b, list):
    #             if len(a) != len(b):
    #                 return False
    #             return all(self._data_equal(x, y) for x, y in zip(a, b))
    #         else:
    return a == b

    #     def __neg__(self) -'Tensor'):
    #         """Negate tensor"""
            return self.apply(lambda x: -x)

    #     def __add__(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Add tensor with scalar or another tensor"""
    #         if isinstance(other, (int, float)):
                return self.apply(lambda x: x + other)
    #         elif isinstance(other, Tensor):
                return self.add(other)
    #         else:
                raise TensorTypeError("Can only add Tensor to Tensor or scalar")

    #     def __radd__(self, other: Union[int, float]) -'Tensor'):
    #         """Right add with scalar"""
            return self.__add__(other)

    #     def __sub__(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Subtract tensor with scalar or another tensor"""
    #         if isinstance(other, (int, float)):
                return self.apply(lambda x: x - other)
    #         elif isinstance(other, Tensor):
                return self.subtract(other)
    #         else:
                raise TensorTypeError("Can only subtract Tensor or scalar from Tensor")

    #     def __rsub__(self, other: Union[int, float]) -'Tensor'):
    #         """Right subtract with scalar"""
            return self.apply(lambda x: other - x)

    #     def __mul__(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Multiply tensor with scalar or another tensor"""
    #         if isinstance(other, (int, float)):
                return self.multiply(other)
    #         elif isinstance(other, Tensor):
                return self.multiply(other)
    #         else:
    #             raise TensorTypeError("Can only multiply Tensor with scalar or Tensor")

    #     def __rmul__(self, other: Union[int, float]) -'Tensor'):
    #         """Right multiply with scalar"""
            return self.__mul__(other)

    #     def __truediv__(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Divide tensor by scalar or another tensor"""
    #         if isinstance(other, (int, float)):
                return self.apply(lambda x: x / other)
    #         elif isinstance(other, Tensor):
                return self.divide(other)
    #         else:
                raise TensorTypeError("Can only divide Tensor by scalar or Tensor")

    #     def __rtruediv__(self, other: Union[int, float]) -'Tensor'):
    #         """Right divide by scalar"""
            return self.apply(lambda x: other / x)

    #     def __pow__(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Raise tensor to power of scalar or another tensor"""
    #         if isinstance(other, (int, float)):
                return self.apply(lambda x: x ** other)
    #         elif isinstance(other, Tensor):
                return self.pow(other)
    #         else:
                raise TensorTypeError("Can only raise Tensor to power of scalar or Tensor")

    #     def __rpow__(self, other: Union[int, float]) -'Tensor'):
    #         """Right raise to power"""
            return self.apply(lambda x: other ** x)

    #     def add(self, other: 'Tensor') -'Tensor'):
    #         """Add another tensor"""
    #         if self.shape != other.shape:
                raise TensorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = self._elementwise_operation(self.data + other.data, lambda x, y: x, y)
            return Tensor(result_data, TensorProperties(self.shape))

    #     def subtract(self, other: 'Tensor') -'Tensor'):
    #         """Subtract another tensor"""
    #         if self.shape != other.shape:
                raise TensorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = self._elementwise_operation(self.data - other.data, lambda x, y: x, y)
            return Tensor(result_data, TensorProperties(self.shape))

    #     def multiply(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Multiply with scalar or another tensor"""
    #         if isinstance(other, (int, float)):
    result_data = self._apply_elementwise(self.data * lambda x: x, other)
                return Tensor(result_data, TensorProperties(self.shape))
    #         elif isinstance(other, Tensor):
    #             if self.shape != other.shape:
                    raise TensorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = self._elementwise_operation(self.data * other.data, lambda x, y: x, y)
                return Tensor(result_data, TensorProperties(self.shape))
    #         else:
    #             raise TensorTypeError("Can only multiply Tensor with scalar or Tensor")

    #     def divide(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Divide by scalar or another tensor"""
    #         if isinstance(other, (int, float)):
    result_data = math.divide(self._apply_elementwise(self.data, lambda x: x, other))
                return Tensor(result_data, TensorProperties(self.shape))
    #         elif isinstance(other, Tensor):
    #             if self.shape != other.shape:
                    raise TensorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = math.divide(self._elementwise_operation(self.data, other.data, lambda x, y: x, y))
                return Tensor(result_data, TensorProperties(self.shape))
    #         else:
                raise TensorTypeError("Can only divide Tensor by scalar or Tensor")

    #     def pow(self, other: Union['Tensor', int, float]) -'Tensor'):
    #         """Raise to power of scalar or another tensor"""
    #         if isinstance(other, (int, float)):
    result_data = self._apply_elementwise(self.data * lambda x: x, * other)
                return Tensor(result_data, TensorProperties(self.shape))
    #         elif isinstance(other, Tensor):
    #             if self.shape != other.shape:
                    raise TensorShapeError(f"Shapes {self.shape} and {other.shape} do not match")

    result_data = self._elementwise_operation(self.data * other.data, lambda x, y: x, * y)
                return Tensor(result_data, TensorProperties(self.shape))
    #         else:
                raise TensorTypeError("Can only raise Tensor to power of scalar or Tensor")

    #     def _elementwise_operation(self, a: Any, b: Any, op: Callable[[Any, Any], Any]) -Any):
    #         """Perform element-wise operation on nested data"""
    #         if isinstance(a, list) and isinstance(b, list):
    #             return [self._elementwise_operation(x, y, op) for x, y in zip(a, b)]
    #         else:
                return op(a, b)

    #     def _apply_elementwise(self, data: Any, func: Callable[[Any], Any]) -Any):
    #         """Apply function to each element of nested data"""
    #         if isinstance(data, list):
    #             return [self._apply_elementwise(x, func) for x in data]
    #         else:
                return func(data)

    #     def reshape(self, new_shape: Tuple[int, ...]) -'Tensor'):
    #         """Reshape tensor to new dimensions"""
    #         if reduce(operator.mul, new_shape, 1) != self.size:
                raise TensorShapeError(f"Cannot reshape shape {self.shape} to {new_shape}")

    #         # Flatten the tensor
    flattened = self.flatten()

    #         # Build new tensor
    #         def build_shape(data: List[Any], shape: Tuple[int, ...]) -Any):
    #             if len(shape) == 1:
    #                 return data[:shape[0]]
    #             else:
    step = reduce(operator.mul, shape[1:], 1)
    #                 return [build_shape(data[i:i+step], shape[1:]) for i in range(0, len(data), step)]

    new_data = build_shape(flattened, new_shape)
            return Tensor(new_data, TensorProperties(new_shape))

    #     def flatten(self) -List[Any]):
    #         """Flatten tensor to 1D list"""
    result = []

    #         def flatten_recursive(data: Any):
    #             if isinstance(data, list):
    #                 for item in data:
                        flatten_recursive(item)
    #             else:
                    result.append(data)

            flatten_recursive(self.data)
    #         return result

    #     def transpose(self, axes: Optional[Tuple[int, ...]] = None) -'Tensor'):
    #         """Transpose tensor along specified axes"""
    #         if axes is None:
    #             # Reverse axes for default transpose
    axes = tuple(reversed(range(self.ndim)))
    #         else:
    #             if len(axes) != self.ndim:
    raise TensorShapeError(f"Number of axes must match tensor dimensions: {len(axes)} ! = {self.ndim}")
    #             if set(axes) != set(range(self.ndim)):
                    raise TensorShapeError("Axes must contain all dimensions exactly once")

    #         # Convert to numpy array for easier transposition
    np_array = self.to_numpy()
    transposed = np.transpose(np_array, axes)

    #         # Convert back to tensor
            return Tensor.from_numpy(transposed)

    #     def squeeze(self, axis: Optional[Union[int, Tuple[int, ...]]] = None) -'Tensor'):
    #         """Remove dimensions of size 1"""
    #         if axis is None:
    #             # Remove all dimensions of size 1
    #             new_shape = tuple(dim for dim in self.shape if dim != 1)
    #         else:
    #             if isinstance(axis, int):
    axis = (axis,)
    #             new_shape = tuple(dim for i, dim in enumerate(self.shape) if i not in axis or dim != 1)

            return self.reshape(new_shape)

    #     def expand_dims(self, axis: int) -'Tensor'):
    #         """Add a dimension of size 1 at specified position"""
    #         if axis < -self.ndim - 1 or axis self.ndim):
    #             raise TensorShapeError(f"Axis {axis} out of bounds for tensor with {self.ndim} dimensions")

    #         if axis < 0:
    axis = self.ndim + 1 + axis

    new_shape = self.shape[:axis] + (1, + self.shape[axis:])
            return self.reshape(new_shape)

    #     def sum(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Sum tensor elements along specified axis"""
    #         if axis is None:
    #             # Sum all elements
    flattened = self.flatten()
    #             return sum(flattened) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier summation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.sum(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.sum(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def mean(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Calculate mean of tensor elements along specified axis"""
    #         if axis is None:
    #             # Mean of all elements
    flattened = self.flatten()
    #             return sum(flattened) / len(flattened) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier mean calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.mean(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.mean(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def std(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Calculate standard deviation of tensor elements along specified axis"""
    #         if axis is None:
    #             # Standard deviation of all elements
    flattened = self.flatten()
    #             mean_val = sum(flattened) / len(flattened) if flattened else 0
    #             variance = sum((x - mean_val) ** 2 for x in flattened) / len(flattened) if flattened else 0
                return math.sqrt(variance)

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier std calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.std(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.std(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def var(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Calculate variance of tensor elements along specified axis"""
    #         if axis is None:
    #             # Variance of all elements
    flattened = self.flatten()
    #             mean_val = sum(flattened) / len(flattened) if flattened else 0
    #             return sum((x - mean_val) ** 2 for x in flattened) / len(flattened) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier var calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.var(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.var(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def max(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
            """Find maximum value(s) in tensor along specified axis"""
    #         if axis is None:
    #             # Maximum of all elements
    flattened = self.flatten()
    #             return max(flattened) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier max calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.max(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.max(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def min(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
            """Find minimum value(s) in tensor along specified axis"""
    #         if axis is None:
    #             # Minimum of all elements
    flattened = self.flatten()
    #             return min(flattened) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier min calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.min(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.min(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def argmax(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Find indices of maximum values along specified axis"""
    #         if axis is None:
    #             # Index of maximum element
    flattened = self.flatten()
    #             return flattened.index(max(flattened)) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier argmax calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.argmax(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.argmax(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def argmin(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Find indices of minimum values along specified axis"""
    #         if axis is None:
    #             # Index of minimum element
    flattened = self.flatten()
    #             return flattened.index(min(flattened)) if flattened else 0

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier argmin calculation
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    result = np.argmin(np_array, axis=axis_value, keepdims=keepdims)
    #             new_shape = self.shape[:axis_value] + self.shape[axis_value+1:] if not keepdims else self.shape

    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()
    #         else:
    #             # Multiple axis reduction
    result = np.argmin(np_array, axis=axis, keepdims=keepdims)
    #             if keepdims or result.ndim 0):
                    return Tensor.from_numpy(result)
    #             else:
                    return result.item()

    #     def clip(self, min_val: Any, max_val: Any) -'Tensor'):
    #         """Clip values to specified range"""
    #         def clip_func(x):
                return max(min(x, max_val), min_val)

            return self.apply(clip_func)

    #     def abs(self) -'Tensor'):
    #         """Get absolute value of all elements"""
            return self.apply(abs)

    #     def sign(self) -'Tensor'):
    #         """Get sign of all elements"""
    #         def sign_func(x):
    #             if x 0):
    #                 return 1
    #             elif x < 0:
    #                 return -1
    #             else:
    #                 return 0

            return self.apply(sign_func)

    #     def sqrt(self) -'Tensor'):
    #         """Apply square root to all elements"""
            return self.apply(math.sqrt)

    #     def log(self, base: Optional[float] = None) -'Tensor'):
    #         """Apply logarithm to all elements"""
    #         def log_func(x):
    #             if base is None:
                    return math.log(x)
    #             else:
                    return math.log(x, base)

            return self.apply(log_func)

    #     def exp(self) -'Tensor'):
    #         """Apply exponential to all elements"""
            return self.apply(math.exp)

    #     def sin(self) -'Tensor'):
    #         """Apply sine to all elements"""
            return self.apply(math.sin)

    #     def cos(self) -'Tensor'):
    #         """Apply cosine to all elements"""
            return self.apply(math.cos)

    #     def tan(self) -'Tensor'):
    #         """Apply tangent to all elements"""
            return self.apply(math.tan)

    #     def apply(self, func: Callable[[Any], Any]) -'Tensor'):
    #         """Apply function to each element of tensor"""
    result_data = self._apply_elementwise(self.data, func)
            return Tensor(result_data, TensorProperties(self.shape))

    #     def map(self, func: Callable[[Any], Any]) -'Tensor'):
    #         """Alias for apply method"""
            return self.apply(func)

    #     def reduce(self, func: Callable[[Any, Any], Any], axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = False, initial: Optional[Any] = None) -Union['Tensor', Any]):
    #         """Reduce tensor using function along specified axis"""
    #         if axis is None:
    #             # Reduce all elements
    flattened = self.flatten()
    #             if initial is not None:
                    return reduce(func, flattened, initial)
    #             else:
    #                 return reduce(func, flattened) if flattened else None

    #         if isinstance(axis, int):
    axis = (axis,)

    #         # Convert to numpy array for easier reduction
    np_array = self.to_numpy()

    #         if len(axis) == 1:
    #             # Single axis reduction
    axis_value = axis[0]
    #             if axis_value < 0:
    axis_value = self.ndim + axis_value

    #             # Apply reduction
    result = np_array
    #             for dim in reversed(sorted(axis)):
    result = np.apply_along_axis(func, dim, result)

    #             if not keepdims and result.ndim 0):
    #                 # Remove reduced dimensions
    #                 slices = [slice(None) if i not in axis else slice(None, 1)
    #                          for i in range(self.ndim)]
    result = result[tuple(slices)]

    #                 if result.size = 1:
                        return result.item()

                return Tensor.from_numpy(result)
    #         else:
    #             # Multiple axis reduction
    #             # Flatten the specified axes
    sorted_axes = sorted(axis)
    #             new_shape = (reduce(operator.mul, (self.shape[i] for i in sorted_axes), 1),)
    #             new_data = np_array.transpose(sorted_axes + [i for i in range(self.ndim) if i not in sorted_axes])
    #             new_data = new_data.reshape(new_shape + tuple(self.shape[i] for i in range(self.ndim) if i not in sorted_axes))

    #             # Apply reduction
    result = np.apply_along_axis(func, 0, new_data)

    #             if not keepdims:
    #                 # Remove reduced dimensions
    #                 result = result.reshape([dim for i, dim in enumerate(result.shape) if i = 0 or i >= len(axis)])

    #             if result.size = 1:
                    return result.item()

                return Tensor.from_numpy(result)

    #     def filter(self, func: Callable[[Any], bool]) -'Tensor'):
    #         """Filter elements in tensor based on predicate"""
    #         # Flatten tensor first
    flattened = self.flatten()
    #         filtered_values = [x for x in flattened if func(x)]

    #         if not filtered_values:
    #             # Return scalar 0 if no elements pass filter
                return Tensor(0, TensorProperties(()))

    #         # Find new dimensions (cube root for 3D, square root for 2D)
    total_elements = len(filtered_values)
    #         if self.ndim >= 3:
    #             # For 3D+, try to maintain similar aspect ratio
    new_dim = round(total_elements * * (1/self.ndim))
    #             new_shape = tuple(new_dim for _ in range(self.ndim))
    #             # Adjust for exact fit
    #             while reduce(operator.mul, new_shape, 1) < total_elements:
    #                 for i in range(self.ndim):
    new_shape = list(new_shape)
    new_shape[i] + = 1
    new_shape = tuple(new_shape)
    #                     if reduce(operator.mul, new_shape, 1) >= total_elements:
    #                         break
    #         else:
    #             # For 1D/2D, use more intuitive shapes
    #             if self.ndim = 1:
    new_shape = (total_elements,)
    #             else:  # 2D
    new_rows = round(math.sqrt(total_elements))
    new_cols = math.divide(math.ceil(total_elements, new_rows))
    new_shape = (new_rows, new_cols)

    #         # Pad with zeros if needed
    #         while len(filtered_values) < reduce(operator.mul, new_shape, 1):
                filtered_values.append(0)

    #         # Build new tensor
    #         def build_shape(data: List[Any], shape: Tuple[int, ...]) -Any):
    #             if len(shape) == 1:
    #                 return data[:shape[0]]
    #             else:
    step = reduce(operator.mul, shape[1:], 1)
    #                 return [build_shape(data[i:i+step], shape[1:]) for i in range(0, len(data), step)]

    new_data = build_shape(filtered_values, new_shape)
            return Tensor(new_data, TensorProperties(new_shape))

    #     def all(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Check if all elements are True along specified axis"""
    #         if axis is None:
    #             # Check all elements
    flattened = self.flatten()
    #             return all(flattened) if flattened else True

            return self.reduce(lambda x, y: x and y, axis, keepdims)

    #     def any(self, axis: Optional[Union[int, Tuple[int, ...]]] = None, keepdims: bool = False) -Union['Tensor', Any]):
    #         """Check if any element is True along specified axis"""
    #         if axis is None:
    #             # Check any element
    flattened = self.flatten()
    #             return any(flattened) if flattened else False

            return self.reduce(lambda x, y: x or y, axis, keepdims)

    #     def round(self, decimals: int = 0) -'Tensor'):
    #         """Round all elements to specified decimals"""
    #         def round_func(x):
    #             if isinstance(x, (int, float)):
                    return round(x, decimals)
    #             return x

            return self.apply(round_func)

    #     def copy(self) -'Tensor'):
    #         """Create a copy of the tensor"""
    #         def deep_copy(data: Any) -Any):
    #             if isinstance(data, list):
    #                 return [deep_copy(x) for x in data]
    #             else:
    #                 return data

    new_data = deep_copy(self.data)
    new_properties = TensorProperties(
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
            return Tensor(new_data, new_properties)

    #     def to_numpy(self) -np.ndarray):
    #         """Convert tensor to numpy array"""
    #         def convert_to_numpy(data: Any) -Any):
    #             if isinstance(data, list):
    #                 return np.array(convert_to_numpy(x) for x in data)
    #             else:
    #                 return data

            return np.array(convert_to_numpy(self.data))

    #     @classmethod
    #     def from_numpy(cls, array: np.ndarray, **kwargs) -'Tensor'):
    #         """Create tensor from numpy array"""
    #         def convert_from_numpy(array: np.ndarray) -Any):
    #             if array.ndim = 0:
                    return array.item()
    #             elif array.ndim = 1:
                    return list(array)
    #             else:
    #                 return [convert_from_numpy(array[i]) for i in range(array.shape[0])]

    data = convert_from_numpy(array)
    properties = TensorProperties(
    shape = array.shape,
    #             **kwargs
    #         )
            return cls(data, properties)

    #     @classmethod
    #     def from_matrix(cls, matrix: Matrix, **kwargs) -'Tensor'):
    #         """Create tensor from matrix"""
            return cls(matrix.data, TensorProperties(matrix.shape, **kwargs))

    #     def to_matrix(self) -Matrix):
    #         """Convert tensor to matrix (only works for 2D tensors)"""
    #         if self.ndim != 2:
                raise TensorShapeError("Only 2D tensors can be converted to matrices")

    properties = MatrixProperties(
    shape = self.shape,
    storage_type = self.properties.storage_type,
    dtype = self.properties.dtype,
    name = self.properties.name,
    description = self.properties.description,
    created_at = self.properties.created_at,
    modified_at = self.properties.modified_at,
    tags = self.properties.tags,
    metadata = self.properties.metadata
    #         )
            return Matrix(self.data, properties)

    #     def to_list(self) -List[Any]):
    #         """Convert tensor to nested list"""
    #         return self.data

    #     @classmethod
    #     def from_list(cls, data: List[Any], shape: Optional[Tuple[int, ...]] = None, **kwargs) -'Tensor'):
    #         """Create tensor from nested list"""
    #         if shape is None:
    shape = cls._calculate_shape(data)

    properties = TensorProperties(
    shape = shape,
    #             **kwargs
    #         )
            return cls(data, properties)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert tensor to dictionary"""
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
    #     def from_dict(cls, data: Dict[str, Any]) -'Tensor'):
    #         """Create tensor from dictionary"""
    tensor_data = data['data']
    properties_data = data['properties']

    properties = TensorProperties(
    shape = tuple(properties_data['shape']),
    storage_type = TensorStorageType(properties_data['storage_type']),
    #             dtype=eval(properties_data['dtype']),  # Be careful with eval in production
    name = properties_data.get('name'),
    description = properties_data.get('description'),
    created_at = properties_data.get('created_at'),
    modified_at = properties_data.get('modified_at'),
    tags = properties_data.get('tags', []),
    metadata = properties_data.get('metadata', {})
    #         )

            return cls(tensor_data, properties)

    #     def save(self, filename: str, format: str = 'json') -None):
    #         """Save tensor to file"""
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
    #     def load(cls, filename: str, format: str = 'json') -'Tensor'):
    #         """Load tensor from file"""
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

    #     def diagonal(self, offset: int = 0) -'Tensor'):
    #         """Extract diagonal from matrix (only works for 2D tensors)"""
    #         if self.ndim != 2:
    #             raise TensorShapeError("Diagonal extraction only works for 2D tensors")

    rows, cols = self.shape
    #         if offset >= 0:
    diag_length = min(rows - cols, offset)
    #             diag_data = [self.data[i][i + offset] for i in range(diag_length)]
    #         else:
    diag_length = min(rows + offset, cols)
    #             diag_data = [self.data[i - offset][i] for i in range(diag_length)]

            return Tensor(diag_data, TensorProperties((diag_length,)))

    #     def trace(self) -Any):
    #         """Calculate trace of matrix (only works for 2D tensors)"""
    #         if self.ndim != 2:
    #             raise TensorShapeError("Trace only works for 2D tensors")

    #         if self.shape[0] != self.shape[1]:
    #             raise TensorShapeError("Trace only defined for square matrices")

    trace_value = 0
    #         for i in range(self.shape[0]):
    trace_value + = self.data[i][i]
    #         return trace_value

    #     def concatenate(self, other: 'Tensor', axis: int = 0) -'Tensor'):
    #         """Concatenate with another tensor along specified axis"""
    #         if self.ndim != other.ndim:
    #             raise TensorShapeError(f"Cannot concatenate tensors with different dimensions: {self.ndim} vs {other.ndim}")

    #         if axis < 0 or axis >= self.ndim:
    #             raise TensorShapeError(f"Axis {axis} out of bounds for tensor with {self.ndim} dimensions")

    #         if any(self.shape[i] != other.shape[i] for i in range(self.ndim) if i != axis):
                raise TensorShapeError(f"Tensor shapes must match except along concatenation axis")

    #         # Convert to numpy arrays for easier concatenation
    self_np = self.to_numpy()
    other_np = other.to_numpy()

    result_np = np.concatenate([self_np, other_np], axis=axis)
            return Tensor.from_numpy(result_np)

    #     def stack(self, other: 'Tensor', axis: int = 0) -'Tensor'):
    #         """Stack with another tensor along new axis"""
    #         if self.shape != other.shape:
    #             raise TensorShapeError(f"Cannot stack tensors with different shapes: {self.shape} vs {other.shape}")

    #         # Convert to numpy arrays for easier stacking
    self_np = self.to_numpy()
    other_np = other.to_numpy()

    result_np = np.stack([self_np, other_np], axis=axis)
            return Tensor.from_numpy(result_np)

    #     def split(self, indices: Union[int, List[int], Tuple[int, ...]], axis: int = 0) -List['Tensor']):
    #         """Split tensor into multiple tensors along specified axis"""
    #         if isinstance(indices, int):
    #             # Split into equal parts
    size = self.shape[axis]
    #             if size % indices != 0:
                    raise TensorShapeError(f"Cannot split axis of size {size} into {indices} equal parts")

    chunk_size = math.divide(size, / indices)
    indices = list(range(chunk_size, size, chunk_size))

    #         # Convert to numpy array for easier splitting
    np_array = self.to_numpy()

    result_np = np.split(np_array, indices, axis=axis)
    #         return [Tensor.from_numpy(x) for x in result_np]

    #     def tile(self, repetitions: Union[int, Tuple[int, ...]]) -'Tensor'):
    #         """Tile tensor along specified dimensions"""
    #         if isinstance(repetitions, int):
    repetitions = (repetitions) * self.ndim

    #         # Convert to numpy array for easier tiling
    np_array = self.to_numpy()

    result_np = np.tile(np_array, repetitions)
            return Tensor.from_numpy(result_np)

    #     def repeat(self, repeats: Union[int, Tuple[int, ...]], axis: int = 0) -'Tensor'):
    #         """Repeat elements along specified axis"""
    #         if isinstance(repeats, int):
    repeats = (repeats) * self.ndim

    #         # Convert to numpy array for easier repeating
    np_array = self.to_numpy()

    result_np = np.repeat(np_array, repeats, axis=axis)
            return Tensor.from_numpy(result_np)

    #     def swapaxes(self, axis1: int, axis2: int) -'Tensor'):
    #         """Swap two axes"""
    #         if axis1 < 0 or axis1 >= self.ndim or axis2 < 0 or axis2 >= self.ndim:
                raise TensorShapeError("Axis indices out of bounds")

    #         # Convert to numpy array for easier axis swapping
    np_array = self.to_numpy()

    result_np = np.swapaxes(np_array, axis1, axis2)
            return Tensor.from_numpy(result_np)

    #     def moveaxis(self, source: int, destination: int) -'Tensor'):
    #         """Move axis to new position"""
    #         # Convert to numpy array for easier axis moving
    np_array = self.to_numpy()

    result_np = np.moveaxis(np_array, source, destination)
            return Tensor.from_numpy(result_np)

    #     def rollaxis(self, axis: int, start: int = 0) -'Tensor'):
    #         """Roll axis to new position"""
    #         # Convert to numpy array for easier axis rolling
    np_array = self.to_numpy()

    result_np = np.rollaxis(np_array, axis, start)
            return Tensor.from_numpy(result_np)

    #     def take(self, indices: Union[int, List[int], Tuple[int, ...]], axis: int = 0) -'Tensor'):
    #         """Take elements along specified axis"""
    #         # Convert to numpy array for easier element taking
    np_array = self.to_numpy()

    result_np = np.take(np_array, indices, axis=axis)
            return Tensor.from_numpy(result_np)

    #     def choose(self, choices: 'Tensor', mode: str = 'raise') -'Tensor'):
    #         """Construct an array from an index array and a set of arrays to choose from"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    choices_np = choices.to_numpy()

    result_np = np.choose(self_np, choices_np, mode=mode)
            return Tensor.from_numpy(result_np)

    #     def where(self, condition: 'Tensor', other: Union['Tensor', Any] = 0) -'Tensor'):
    #         """Return elements chosen from two arrays depending on condition"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    condition_np = condition.to_numpy()

    #         if isinstance(other, Tensor):
    other_np = other.to_numpy()
    #         else:
    other_np = other

    result_np = np.where(condition_np, self_np, other_np)
            return Tensor.from_numpy(result_np)

    #     def masked_select(self, mask: 'Tensor') -'Tensor'):
    #         """Return elements from tensor selected by mask"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    mask_np = mask.to_numpy()

    result_np = self_np[mask_np]
            return Tensor.from_numpy(result_np)

    #     def masked_fill(self, mask: 'Tensor', value: Any) -'Tensor'):
    #         """Fill elements from tensor selected by mask with value"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    mask_np = mask.to_numpy()

    result_np = np.where(mask_np, value, self_np)
            return Tensor.from_numpy(result_np)

    #     def masked_zero(self, mask: 'Tensor') -'Tensor'):
    #         """Fill elements from tensor selected by mask with zero"""
            return self.masked_fill(mask, 0)

    #     def index_select(self, axis: int, index: Union[int, List[int], 'Tensor']) -'Tensor'):
    #         """Select elements along specified axis"""
    #         # Convert to numpy array
    self_np = self.to_numpy()

    #         if isinstance(index, Tensor):
    index_np = index.to_numpy()
    #         else:
    index_np = index

    #         # Create indexing tuple
    idx = [slice(None)] * self.ndim
    idx[axis] = index_np

    result_np = self_np[tuple(idx)]
            return Tensor.from_numpy(result_np)

    #     def gather(self, dim: int, index: 'Tensor') -'Tensor'):
    #         """Gather values along specified dimension"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    index_np = index.to_numpy()

    #         # Use advanced indexing
    #         idx = [np.arange(s) for s in self.shape]
    idx[dim] = index_np

    result_np = self_np[tuple(idx)]
            return Tensor.from_numpy(result_np)

    #     def scatter_add(self, dim: int, index: 'Tensor', src: 'Tensor') -'Tensor'):
    #         """Add values into tensor using specified indices"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    index_np = index.to_numpy()
    src_np = src.to_numpy()

    #         # Create output array
    result_np = self_np.copy()

    #         # Handle different dimensions
    #         if dim = 0:
    result_np[index_np] + = src_np
    #         else:
    #             # For higher dimensions, we need to handle broadcasting
    #             # This is a simplified implementation
    result_np = np.add.at(result_np, index_np, src_np)

            return Tensor.from_numpy(result_np)

    #     def dot(self, other: 'Tensor') -'Tensor'):
    #         """Dot product with another tensor"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    other_np = other.to_numpy()

    result_np = np.dot(self_np, other_np)
            return Tensor.from_numpy(result_np)

    #     def tensordot(self, other: 'Tensor', axes: Union[int, Tuple[List[int], List[int]]] = 2) -'Tensor'):
    #         """Tensor dot product"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    other_np = other.to_numpy()

    result_np = np.tensordot(self_np, other_np, axes=axes)
            return Tensor.from_numpy(result_np)

    #     def einsum(self, subscripts: str, *tensors: 'Tensor') -'Tensor'):
    #         """Einstein summation"""
    #         # Convert all tensors to numpy arrays
    #         np_tensors = [tensor.to_numpy() for tensor in tensors]

    result_np = np.einsum(subscripts * self.to_numpy(,, np_tensors))
            return Tensor.from_numpy(result_np)

    #     def convolve(self, kernel: 'Tensor', mode: str = 'full') -'Tensor'):
    #         """Convolve with kernel"""
    #         # Convert to numpy arrays
    self_np = self.to_numpy()
    kernel_np = kernel.to_numpy()

    #         if self.ndim != kernel.ndim:
                raise TensorShapeError("Input and kernel must have same number of dimensions")

    #         # Handle different dimensions
    #         if self.ndim = 1:
    result_np = np.convolve(self_np, kernel_np, mode=mode)
    #         elif self.ndim = 2:
    result_np = np.convolve(self_np, kernel_np, mode=mode)
    #         else:
    #             # For higher dimensions, use scipy's convolve
    #             try:
    #                 from scipy import ndimage
    result_np = ndimage.convolve(self_np, kernel_np, mode=mode)
    #             except ImportError:
    #                 raise TensorOperationError("scipy is required for convolution with >2 dimensions")

            return Tensor.from_numpy(result_np)

    #     def correlate(self, kernel: 'Tensor', mode: str = 'full') -'Tensor'):
    #         """Cross-correlate with kernel"""
    #         # Flip kernel for correlation
    #         if self.ndim = 1:
    flipped_kernel = kernel.data[:: - 1]
    #         elif self.ndim = 2:
    #             flipped_kernel = [row[::-1] for row in kernel.data[::-1]]
    #         else:
    flipped_kernel = kernel.data  # Higher dimensions are complex

    flipped_kernel_tensor = Tensor(flipped_kernel, TensorProperties(kernel.shape))
            return self.convolve(flipped_kernel_tensor, mode)

    #     def pad(self, pad_width: Union[int, Tuple[Tuple[int, int], ...]], mode: str = 'constant', **kwargs) -'Tensor'):
    #         """Pad tensor with specified width"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if isinstance(pad_width, int):
    pad_width = ((pad_width * pad_width,), self.ndim)

    result_np = np.pad(np_array * pad_width, mode=mode,, *kwargs)
            return Tensor.from_numpy(result_np)

    #     def gradient(self, axis: Optional[Union[int, Tuple[int, ...]]] = None) -Union['Tensor', List['Tensor']]):
    #         """Calculate gradient along specified axis"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if axis is None:
    #             # Calculate gradient along all axes
    gradients = np.gradient(np_array)
    #             return [Tensor.from_numpy(g) for g in gradients]
    #         elif isinstance(axis, int):
    #             # Calculate gradient along single axis
    gradient = np.gradient(np_array, axis=axis)
                return Tensor.from_numpy(gradient)
    #         else:
    #             # Calculate gradient along multiple axes
    gradients = np.gradient(np_array, axis=axis)
    #             return [Tensor.from_numpy(g) for g in gradients]

    #     def laplacian(self) -'Tensor'):
    #         """Calculate Laplacian"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         try:
    #             from scipy import ndimage
    result_np = ndimage.laplace(np_array)
    #         except ImportError:
    #             raise TensorOperationError("scipy is required for Laplacian calculation")

            return Tensor.from_numpy(result_np)

    #     def hessian(self) -'Tensor'):
    #         """Calculate Hessian matrix"""
    #         if self.ndim != 1:
    #             raise TensorShapeError("Hessian only defined for 1D tensors (vectors)")

    #         # Calculate gradient of gradient
    gradient = self.gradient()
    #         if isinstance(gradient, list):
    hessian = gradient[0].gradient()
    #             if isinstance(hessian, list):
    #                 # Stack to form Hessian matrix
    #                 hessian_matrix = [[hessian[i][j] for j in range(len(hessian))] for i in range(len(hessian))]
                    return Tensor(hessian_matrix, TensorProperties((len(hessian), len(hessian))))

            raise TensorOperationError("Could not compute Hessian matrix")

    #     def fft(self, axes: Optional[Union[int, Tuple[int, ...]]] = None) -'Tensor'):
    #         """Fast Fourier Transform along specified axes"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if axes is None:
    #             # FFT along all axes
    result_np = np.fft.fftn(np_array)
    #         elif isinstance(axes, int):
    #             # FFT along single axis
    result_np = np.fft.fft(np_array, axis=axes)
    #         else:
    #             # FFT along multiple axes
    result_np = np.fft.fftn(np_array, axes=axes)

            return Tensor.from_numpy(result_np)

    #     def ifft(self, axes: Optional[Union[int, Tuple[int, ...]]] = None) -'Tensor'):
    #         """Inverse Fast Fourier Transform along specified axes"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if axes is None:
    #             # IFFT along all axes
    result_np = np.fft.ifftn(np_array)
    #         elif isinstance(axes, int):
    #             # IFFT along single axis
    result_np = np.fft.ifft(np_array, axis=axes)
    #         else:
    #             # IFFT along multiple axes
    result_np = np.fft.ifftn(np_array, axes=axes)

            return Tensor.from_numpy(result_np)

    #     def real(self) -'Tensor'):
    #         """Extract real part of complex tensor"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    result_np = np.real(np_array)
            return Tensor.from_numpy(result_np)

    #     def imag(self) -'Tensor'):
    #         """Extract imaginary part of complex tensor"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    result_np = np.imag(np_array)
            return Tensor.from_numpy(result_np)

    #     def conj(self) -'Tensor'):
    #         """Complex conjugate"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    result_np = np.conj(np_array)
            return Tensor.from_numpy(result_np)

    #     def angle(self) -'Tensor'):
    #         """Phase angle of complex tensor"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    result_np = np.angle(np_array)
            return Tensor.from_numpy(result_np)

    #     def norm(self, ord: Optional[Union[int, float, str]] = None, axis: Optional[Union[int, Tuple[int, ...]]] = None,
    keepdims: bool = False) -Union['Tensor', float]):
    #         """Calculate norm of tensor"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if axis is None:
    #             # Calculate overall norm
    result_np = np.linalg.norm(np_array, ord=ord)
    #             if isinstance(result_np, np.ndarray) and result_np.size = 1:
                    return result_np.item()
                return Tensor.from_numpy(result_np)
    #         else:
    #             # Calculate norm along specified axis
    #             if isinstance(axis, int):
    result_np = np.linalg.norm(np_array, ord=ord, axis=axis, keepdims=keepdims)
    #             else:
    result_np = np.linalg.norm(np_array, ord=ord, axis=axis, keepdims=keepdims)

    #             if keepdims or result_np.ndim 0):
                    return Tensor.from_numpy(result_np)
    #             else:
                    return result_np.item()

    #     def normalize(self, ord: Optional[Union[int, float, str]] = None, axis: Optional[Union[int, Tuple[int, ...]]] = None) -'Tensor'):
    #         """Normalize tensor"""
    #         # Calculate norm
    norm_val = self.norm(ord=ord, axis=axis, keepdims=True)

    #         # Avoid division by zero
    #         if isinstance(norm_val, Tensor):
    norm_data = norm_val.data
    #             if isinstance(norm_data, list) and all(isinstance(x, (int, float)) for x in norm_data):
    norm_val = sum(norm_data)

    #         if norm_val = 0:
                return self.copy()

    #         # Divide by norm
    #         return self / norm_val

    #     def svd(self, full_matrices: bool = True, compute_uv: bool = True) -Union['Tensor', Tuple['Tensor', 'Tensor', 'Tensor']]):
    #         """Singular Value Decomposition"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("SVD only works for 2D tensors")

    U, S, Vh = np.linalg.svd(np_array, full_matrices=full_matrices, compute_uv=compute_uv)

    #         if compute_uv:
    U_tensor = Tensor.from_numpy(U)
    #             S_tensor = Tensor.from_numpy(np.diag(S) if full_matrices else S)
    V_tensor = Tensor.from_numpy(Vh.T)
    #             return U_tensor, S_tensor, V_tensor
    #         else:
                return Tensor.from_numpy(S)

    #     def eig(self) -Tuple['Tensor', 'Tensor']):
    #         """Eigenvalue decomposition"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Eigenvalue decomposition only works for 2D tensors")

    #         if self.shape[0] != self.shape[1]:
    #             raise TensorShapeError("Eigenvalue decomposition only works for square matrices")

    eigenvalues, eigenvectors = np.linalg.eig(np_array)

    eigenvalues_tensor = Tensor.from_numpy(eigenvalues)
    eigenvectors_tensor = Tensor.from_numpy(eigenvectors)

    #         return eigenvalues_tensor, eigenvectors_tensor

    #     def eigvals(self) -'Tensor'):
    #         """Compute eigenvalues only"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Eigenvalue computation only works for 2D tensors")

    #         if self.shape[0] != self.shape[1]:
    #             raise TensorShapeError("Eigenvalue computation only works for square matrices")

    eigenvalues = np.linalg.eigvals(np_array)
            return Tensor.from_numpy(eigenvalues)

    #     def inv(self) -'Tensor'):
    #         """Matrix inverse"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Matrix inverse only works for 2D tensors")

    #         if self.shape[0] != self.shape[1]:
    #             raise TensorShapeError("Matrix inverse only works for square matrices")

    result_np = np.linalg.inv(np_array)
            return Tensor.from_numpy(result_np)

    #     def pinv(self, rcond: Optional[float] = None) -'Tensor'):
    #         """Moore-Penrose pseudo-inverse"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    result_np = np.linalg.pinv(np_array, rcond=rcond)
            return Tensor.from_numpy(result_np)

    #     def det(self) -Any):
    #         """Determinant"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Determinant only works for 2D tensors")

    #         if self.shape[0] != self.shape[1]:
    #             raise TensorShapeError("Determinant only works for square matrices")

    result = np.linalg.det(np_array)
    #         return result.item() if isinstance(result, np.ndarray) else result

    #     def rank(self) -int):
    #         """Matrix rank"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Matrix rank only works for 2D tensors")

            return np.linalg.matrix_rank(np_array)

    #     def cond(self, p: Optional[Union[int, float, str]] = None) -float):
    #         """Condition number"""
    #         # Convert to numpy array
    np_array = self.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Condition number only works for 2D tensors")

    result = np.linalg.cond(np_array, p=p)
    #         return result.item() if isinstance(result, np.ndarray) else result

    #     def solve(self, b: 'Tensor') -'Tensor'):
    """Solve linear system Ax = b"""
    #         # Convert to numpy arrays
    A_np = self.to_numpy()
    b_np = b.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Linear system solving only works for 2D tensors")

    #         if self.shape[0] != self.shape[1]:
                raise TensorShapeError("Coefficient matrix must be square")

    #         if self.shape[0] != b_np.shape[0]:
                raise TensorShapeError("Coefficient matrix and right-hand side must have compatible dimensions")

    result_np = np.linalg.solve(A_np, b_np)
            return Tensor.from_numpy(result_np)

    #     def lstsq(self, b: 'Tensor', rcond: Optional[float] = None) -'Tensor'):
    #         """Least-squares solution"""
    #         # Convert to numpy arrays
    A_np = self.to_numpy()
    b_np = b.to_numpy()

    #         if self.ndim != 2:
    #             raise TensorShapeError("Least-squares solving only works for 2D tensors")

    result_np, _, _, _ = np.linalg.lstsq(A_np, b_np, rcond=rcond)
            return Tensor.from_numpy(result_np)

    #     def qr(self, mode: str =
