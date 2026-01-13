# Converted from Python to NoodleCore
# Original file: src

# """
# Mathematical Objects for NBC Runtime

# This module provides the base classes and implementations for
# mathematical objects used in the NBC runtime system.
# """

import abc
import functools
import json
import logging
import math
import os
import weakref
import contextlib.contextmanager
from dataclasses import dataclass
import enum.Enum
import typing.Any

import numpy as np

logger = logging.getLogger(__name__)


class ObjectType(Enum)
    #     """Types of mathematical objects."""

    MATHEMATICAL_OBJECT = "mathematical_object"
    SCALAR = "scalar"
    VECTOR = "vector"
    MATRIX = "matrix"
    TENSOR = "tensor"
    FUNCTION = "function"
    SET = "set"
    RELATION = "relation"
    GROUP = "group"
    RING = "ring"
    FIELD = "field"
    CATEGORY = "category"
    FUNCTOR = "functor"
    NATURAL_TRANSFORMATION = "natural_transformation"


class MathematicalProperty(Enum)
    #     """Mathematical properties."""

    COMMUTATIVE = "commutative"
    ASSOCIATIVE = "associative"
    DISTRIBUTIVE = "distributive"
    IDEMPOTENT = "idempotent"
    INVERTIBLE = "invertible"
    REFLEXIVE = "reflexive"
    SYMMETRIC = "symmetric"
    TRANSITIVE = "transitive"
    LINEAR = "linear"
    BILINEAR = "bilinear"
    HERMITIAN = "hermitian"
    POSITIVE_DEFINITE = "positive_definite"
    ORTHOGONAL = "orthogonal"
    UNITARY = "unitary"
    NORMAL = "normal"
    SELF_ADJOINT = "self_adjoint"


dataclass
class MathematicalProperties
    #     """Container for mathematical properties."""

    properties: Set[MathematicalProperty] = field(default_factory=set)

    #     def add_property(self, prop: MathematicalProperty):
    #         """Add a property."""
            self.properties.add(prop)

    #     def remove_property(self, prop: MathematicalProperty):
    #         """Remove a property."""
            self.properties.discard(prop)

    #     def has_property(self, prop: MathematicalProperty) -bool):
    #         """Check if has property."""
    #         return prop in self.properties

    #     def to_dict(self) -Dict[str, bool]):
    #         """Convert to dictionary."""
    #         return {prop.value: prop in self.properties for prop in MathematicalProperty}


class MathematicalObject
    #     """Base class for all mathematical objects."""

    #     def __init__(
    #         self,
    #         obj_type: ObjectType,
    data: Any = None,
    properties: Optional[MathematicalProperties] = None,
    #     ):""
    #         Initialize mathematical object.

    #         Args:
    #             obj_type: Type of the object
    #             data: Object data
    #             properties: Mathematical properties
    #         """
    self.object_type = obj_type
    self.data = data
    self.properties = properties or MathematicalProperties()
    self._cache = {}
    self._dirty = True
    self._id = id(self)
    self._weak_ref = weakref.ref(self)

    #     def copy(self) -"MathematicalObject"):
    #         """Create a copy of the object."""
            return MathematicalObject(
    obj_type = self.object_type,
    data = self.data,
    properties = MathematicalProperties(
    properties = set(self.properties.properties)
    #             ),
    #         )

    #     def validate(self) -bool):
    #         """Validate the object."""
    #         return True

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         # Handle both MathematicalProperties objects and dictionaries
    #         if hasattr(self.properties, "to_dict"):
    properties_dict = self.properties.to_dict()
    #         else:
    properties_dict = self.properties

    #         return {
    #             "object_type": self.object_type.value,
    #             "data": self.data,
    #             "properties": properties_dict,
    #             "id": self._id,
    #         }

    #     def __str__(self) -str):
    #         """String representation."""
            return f"{self.object_type.value}({self.data})"

    #     def __repr__(self) -str):
    #         """Representation."""
            return f"MathematicalObject({self.object_type.value}, {self.data})"


class Scalar(MathematicalObject)
    #     """Scalar mathematical object."""

    #     def __init__(
    #         self,
    #         value: Union[int, float],
    properties: Optional[MathematicalProperties] = None,
    #     ):""
    #         Initialize scalar.

    #         Args:
    #             value: Scalar value
    #             properties: Mathematical properties
    #         """
            super().__init__(ObjectType.SCALAR, value, properties)

    #     def __add__(self, other: "Scalar") -"Scalar"):
    #         """Add two scalars."""
            return Scalar(self.data + other.data)

    #     def __sub__(self, other: "Scalar") -"Scalar"):
    #         """Subtract two scalars."""
            return Scalar(self.data - other.data)

    #     def __mul__(self, other: "Scalar") -"Scalar"):
    #         """Multiply two scalars."""
            return Scalar(self.data * other.data)

    #     def __truediv__(self, other: "Scalar") -"Scalar"):
    #         """Divide two scalars."""
            return Scalar(self.data / other.data)


class Vector(MathematicalObject)
    #     """Vector mathematical object."""

    #     def __init__(
    #         self,
    #         data: List[Union[int, float]],
    properties: Optional[MathematicalProperties] = None,
    #     ):""
    #         Initialize vector.

    #         Args:
    #             data: Vector data
    #             properties: Mathematical properties
    #         """
            super().__init__(ObjectType.VECTOR, data, properties)

    #     def __add__(self, other: "Vector") -"Vector"):
    #         """Add two vectors."""
    #         return Vector([a + b for a, b in zip(self.data, other.data)])

    #     def __sub__(self, other: "Vector") -"Vector"):
    #         """Subtract two vectors."""
    #         return Vector([a - b for a, b in zip(self.data, other.data)])

    #     def __mul__(self, scalar: Scalar) -"Vector"):
    #         """Multiply vector by scalar."""
    #         return Vector([a * scalar.data for a in self.data])


class Matrix(MathematicalObject)
    #     """Matrix mathematical object."""

    #     def __init__(
    #         self,
    #         data: List[List[Union[int, float]]],
    properties: Optional[MathematicalProperties] = None,
    #     ):""
    #         Initialize matrix.

    #         Args:
    #             data: Matrix data
    #             properties: Mathematical properties
    #         """
            super().__init__(ObjectType.MATRIX, data, properties)
    self.rows = len(data)
    #         self.cols = len(data[0]) if data and data[0] else 0

    #     def __add__(self, other: "Matrix") -"Matrix"):
    #         """Add two matrices."""
    result = []
    #         for i in range(len(self.data)):
    row = []
    #             for j in range(len(self.data[i])):
                    row.append(self.data[i][j] + other.data[i][j])
                result.append(row)
            return Matrix(result)

    #     def __sub__(self, other: "Matrix") -"Matrix"):
    #         """Subtract two matrices."""
    result = []
    #         for i in range(len(self.data)):
    row = []
    #             for j in range(len(self.data[i])):
                    row.append(self.data[i][j] - other.data[i][j])
                result.append(row)
            return Matrix(result)

    #     def get_cache_key(self) -str):
    #         """Generate a cache key for the matrix."""
    #         import hashlib
    #         import json

    #         # Convert matrix data to a consistent string representation
    data_str = json.dumps(self.data, sort_keys=True)
            return hashlib.md5(data_str.encode()).hexdigest()


class Tensor(MathematicalObject)
    #     """Tensor mathematical object."""

    #     def __init__(self, data: Any, properties: Optional[MathematicalProperties] = None):""
    #         Initialize tensor.

    #         Args:
    #             data: Tensor data
    #             properties: Mathematical properties
    #         """
            super().__init__(ObjectType.TENSOR, data, properties)
    self.shape = getattr(data, "shape", ())

    #     def __str__(self) -str):
    #         """String representation."""
    return f"Tensor(shape = {getattr(self.data, 'shape', 'unknown')})"

    #     def __repr__(self) -str):
    #         """Representation."""
            return f"Tensor({self.data})"

    #     def get_cache_key(self) -str):
    #         """Generate a cache key for the tensor."""
    #         import hashlib
    #         import json

    #         # Convert tensor data to a consistent string representation
    #         try:
    #             # If it's a numpy array, convert to list first
    #             if hasattr(self.data, "tolist"):
    data_str = json.dumps(self.data.tolist(), sort_keys=True)
    #             else:
    data_str = json.dumps(str(self.data), sort_keys=True)
    #         except Exception:
    #             # Fallback to string representation
    data_str = json.dumps(str(self.data), sort_keys=True)
            return hashlib.md5(data_str.encode()).hexdigest()


class MathematicalObjectMapper
    #     """Mapper for mathematical objects."""

    #     def __init__(self):""Initialize mathematical object mapper."""
    self._mappers = {}
    self._cache = {}

    #     def register_mapper(self, obj_type: ObjectType, mapper: Callable):
    #         """
    #         Register a mapper for a specific object type.

    #         Args:
    #             obj_type: Object type
    #             mapper: Mapper function
    #         """
    self._mappers[obj_type] = mapper

    #     def map_object(self, obj: MathematicalObject) -Any):
    #         """
    #         Map a mathematical object to its representation.

    #         Args:
    #             obj: Mathematical object to map

    #         Returns:
    #             Mapped representation
    #         """
    #         if obj.object_type not in self._mappers:
    #             raise ValueError(f"No mapper registered for {obj.object_type}")

    mapper = self._mappers[obj.object_type]
            return mapper(obj)

    #     def map_to_database(self, obj: MathematicalObject) -Dict[str, Any]):
    #         """
    #         Map a mathematical object to database format.

    #         Args:
    #             obj: Mathematical object to map

    #         Returns:
    #             Database representation
    #         """
    mapped = self.map_object(obj)
    #         return {
    #             "object_type": obj.object_type.value,
    #             "data": mapped,
                "properties": obj.properties.to_dict(),
    #             "id": obj._id,
    #         }


class Table(MathematicalObject)
    #     """Table mathematical object for structured data."""

    #     def __init__(
    #         self,
    #         data: List[Dict[str, Any]],
    columns: Optional[List[str]] = None,
    properties: Optional[MathematicalProperties] = None,
    #     ):""
    #         Initialize table.

    #         Args:
    #             data: Table data as list of dictionaries
                columns: List of column names (optional)
    #             properties: Mathematical properties
    #         """
    #         if columns is None:
    #             # Extract columns from first row if available
    #             columns = list(data[0].keys()) if data else []

    #         super().__init__(ObjectType.MATRIX, data, properties)  # Using MATRIX for now
    self.columns = columns

    #     def get_row(self, index: int) -Dict[str, Any]):
    #         """Get row by index."""
    #         if 0 <= index < len(self.data):
    #             return self.data[index]
            raise IndexError("Row index out of range")

    #     def get_column(self, column_name: str) -List[Any]):
    #         """Get column by name."""
    #         if column_name not in self.columns:
                raise ValueError(f"Column '{column_name}' not found")

    #         return [row.get(column_name) for row in self.data]

    #     def filter(self, **kwargs) -"Table"):
    #         """Filter table by column values."""
    filtered_data = []
    #         for row in self.data:
    match = True
    #             for key, value in kwargs.items():
    #                 if key not in row or row[key] != value:
    match = False
    #                     break
    #             if match:
                    filtered_data.append(row)
            return Table(filtered_data, self.columns.copy(), self.properties)

    #     def __str__(self) -str):
    #         """String representation."""
    return f"Table(rows = {len(self.data)}, columns={len(self.columns)})"

    #     def __repr__(self) -str):
    #         """Representation."""
    #         return f"Table(data={self.data[:2]}{'...' if len(self.data) 2 else ''}, columns={self.columns})"


class Function(MathematicalObject)
    #     """Function mathematical object."""

    #     def __init__(
    self, func): Callable, properties: Optional[MathematicalProperties] = None
    #     ):
    #         """
    #         Initialize function.

    #         Args:
    #             func: Function callable
    #             properties: Mathematical properties
    #         """
            super().__init__(ObjectType.FUNCTION, func, properties)

    #     def __call__(self, *args, **kwargs) -Any):
    #         """Call the function."""
    #         if callable(self.data):
                return self.data(*args, **kwargs)
            raise TypeError("Function object is not callable")

    #     def __str__(self) -str):
    #         """String representation."""
            return f"Function({self.data})"

    #     def __repr__(self) -str):
    #         """Representation."""
            return f"Function({self.data})"

    #     def compose(self, other: "Function") -"Function"):
    #         """Compose with another function."""

    #         def composed(*args, **kwargs):
                return self.data(other.data(*args, **kwargs))

            return Function(composed)


class Actor(MathematicalObject)
    #     """Actor mathematical object for concurrent/parallel computation."""

    #     def __init__(
    #         self,
    #         behavior: Callable,
    state: Optional[Dict[str, Any]] = None,
    properties: Optional[MathematicalProperties] = None,
    #     ):""
    #         Initialize actor.

    #         Args:
    #             behavior: Actor behavior function
    #             state: Actor state dictionary
    #             properties: Mathematical properties
    #         """
            super().__init__(ObjectType.FUNCTION, behavior, properties)
    self.state = state or {}
    self._mailbox = []

    #     def send(self, message: Any) -None):
    #         """Send message to actor."""
            self._mailbox.append(message)

    #     def receive(self) -Any):
    #         """Receive next message from mailbox."""
    #         return self._mailbox.pop(0) if self._mailbox else None

    #     def process_messages(self) -List[Any]):
    #         """Process all messages in mailbox."""
    results = []
    #         while self._mailbox:
    message = self.receive()
    #             if callable(self.data):
    result = self.data(message, self.state)
                    results.append(result)
    #         return results

    #     def update_state(self, **kwargs) -None):
    #         """Update actor state."""
            self.state.update(kwargs)

    #     def __str__(self) -str):
    #         """String representation."""
    return f"Actor(state = {self.state}, messages={len(self._mailbox)})"

    #     def __repr__(self) -str):
    #         """Representation."""
    return f"Actor(behavior = {self.data}, state={self.state})"

    #     def map_from_database(self, data: Dict[str, Any]) -MathematicalObject):
    #         """
    #         Map database data to mathematical object.

    #         Args:
    #             data: Database data

    #         Returns:
    #             Mathematical object
    #         """
    obj_type = ObjectType(data["object_type"])
    obj_data = data["data"]
    properties = MathematicalProperties()

    #         for prop_name, has_prop in data["properties"].items():
    #             if has_prop:
                    properties.add_property(MathematicalProperty(prop_name))

    #         if obj_type == ObjectType.SCALAR:
                return Scalar(obj_data, properties)
    #         elif obj_type == ObjectType.VECTOR:
                return Vector(obj_data, properties)
    #         elif obj_type == ObjectType.MATRIX:
                return Matrix(obj_data, properties)
    #         elif obj_type == ObjectType.TENSOR:
                return Tensor(obj_data, properties)
    #         elif obj_type == ObjectType.FUNCTION:
                return Function(obj_data, properties)
    #         else:
                return MathematicalObject(obj_type, obj_data, properties)


# Factory functions for creating mathematical objects
def create_scalar(
value: Union[int, float], properties: Optional[MathematicalProperties] = None
# ) -Scalar):
#     """Create a scalar object."""
    return Scalar(value, properties)


def create_vector(
data: List[Union[int, float]], properties: Optional[MathematicalProperties] = None
# ) -Vector):
#     """Create a vector object."""
    return Vector(data, properties)


def create_matrix(
#     data: List[List[Union[int, float]]],
properties: Optional[MathematicalProperties] = None,
# ) -Matrix):
#     """Create a matrix object."""
    return Matrix(data, properties)


def create_tensor(
data: Any, properties: Optional[MathematicalProperties] = None
# ) -Tensor):
#     """Create a tensor object."""
    return Tensor(data, properties)


def create_mathematical_object(
#     obj_type: ObjectType,
data: Any = None,
properties: Optional[MathematicalProperties] = None,
# ) -MathematicalObject):
#     """Create a mathematical object of the specified type."""
#     if obj_type == ObjectType.SCALAR:
        return Scalar(data, properties)
#     elif obj_type == ObjectType.VECTOR:
        return Vector(data, properties)
#     elif obj_type == ObjectType.MATRIX:
        return Matrix(data, properties)
#     elif obj_type == ObjectType.TENSOR:
        return Tensor(data, properties)
#     else:
        return MathematicalObject(obj_type, data, properties)
