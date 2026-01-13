# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Mathematical Objects Module
 = ================================

# This module provides mathematical object definitions for NoodleCore,
# including functors, matrices, and other mathematical constructs.
# """

import typing.List,
import abc.ABC,

# Mathematical Object Types
class ObjectType
    #     """Enumeration of mathematical object types."""

    STRING = "string"
    INTEGER = "integer"
    FLOAT = "float"
    BOOLEAN = "boolean"
    LIST = "list"
    DICT = "dict"
    MATRIX = "matrix"
    VECTOR = "vector"
    FUNCTOR = "functor"
    NONE = "none"

    #     @classmethod
    #     def get_type(cls, value: Any) -> str:
    #         """Get the type of a value."""
    #         if value is None:
    #             return cls.NONE
    #         elif isinstance(value, str):
    #             return cls.STRING
    #         elif isinstance(value, int):
    #             return cls.INTEGER
    #         elif isinstance(value, float):
    #             return cls.FLOAT
    #         elif isinstance(value, bool):
    #             return cls.BOOLEAN
    #         elif isinstance(value, list):
    #             return cls.LIST
    #         elif isinstance(value, dict):
    #             return cls.DICT
    #         elif isinstance(value, Matrix):
    #             return cls.MATRIX
    #         elif isinstance(value, Vector):
    #             return cls.VECTOR
    #         elif isinstance(value, Functor):
    #             return cls.FUNCTOR
    #         else:
    #             return "unknown"

# Base Mathematical Class
class MathematicalObject
    #     """Base class for all mathematical objects."""

    #     def __init__(self, object_type: str):
    self.object_type = object_type

    #     def __str__(self):
            return f"{self.__class__.__name__}({self.object_type})"

    #     def __repr__(self):
            return self.__str__()

# Functor Class
class Functor(MathematicalObject)
    #     """Represents a mathematical function object."""

    #     def __init__(self, name: str, func: Callable, params: List[str] = None):
            super().__init__(ObjectType.FUNCTOR)
    self.name = name
    self.func = func
    self.params = params or []

    #     def __call__(self, *args):
            return self.func(*args)

    #     def __str__(self):
            return f"Functor({self.name})"

# Vector Class
class Vector(MathematicalObject)
    #     """Represents a mathematical vector."""

    #     def __init__(self, elements: List[float]):
            super().__init__(ObjectType.VECTOR)
    self.elements = elements

    #     def __add__(self, other: 'Vector') -> 'Vector':
    #         if len(self.elements) != len(other.elements):
                raise ValueError("Vectors must have same length")
    #         return Vector([a + b for a, b in zip(self.elements, other.elements)])

    #     def __mul__(self, scalar: float) -> 'Vector':
    #         return Vector([e * scalar for e in self.elements])

    #     def dot(self, other: 'Vector') -> float:
    #         if len(self.elements) != len(other.elements):
                raise ValueError("Vectors must have same length")
    #         return sum(a * b for a, b in zip(self.elements, other.elements))

    #     def magnitude(self) -> float:
    #         return sum(e ** 2 for e in self.elements) ** 0.5

    #     def __str__(self):
            return f"Vector({self.elements})"

# Matrix Class
class Matrix(MathematicalObject)
    #     """Represents a mathematical matrix."""

    #     def __init__(self, rows: List[List[float]]):
            super().__init__(ObjectType.MATRIX)
    self.rows = rows
    self.num_rows = len(rows)
    #         self.num_cols = len(rows[0]) if rows > 0 else 0

    #     def __add__(self, other: 'Matrix') -> 'Matrix':
    #         if self.num_rows != other.num_rows or self.num_cols != other.num_cols:
                raise ValueError("Matrices must have same dimensions")
    result = []
    #         for i in range(self.num_rows):
    row = []
    #             for j in range(self.num_cols):
                    row.append(self.rows[i][j] + other.rows[i][j])
                result.append(row)
            return Matrix(result)

    #     def __mul__(self, other: Union['Matrix', 'Vector']) -> Union['Matrix', 'Vector']:
    #         if isinstance(other, Matrix):
    #             if self.num_cols != other.num_rows:
                    raise ValueError("Matrix dimensions incompatible")
    result = []
    #             for i in range(self.num_rows):
    row = []
    #                 for j in range(other.num_cols):
    #                     sum_val = sum(self.rows[i][k] * other.rows[k][j] for k in range(self.num_cols))
                        row.append(sum_val)
                    result.append(row)
                return Matrix(result)
    #         elif isinstance(other, Vector):
    #             if self.num_cols != len(other.elements):
                    raise ValueError("Matrix and vector dimensions incompatible")
    result = []
    #             for i in range(self.num_rows):
    #                 sum_val = sum(self.rows[i][j] * other.elements[j] for j in range(self.num_cols))
                    result.append(sum_val)
                return Vector(result)

    #     def transpose(self) -> 'Matrix':
    result = []
    #         for j in range(self.num_cols):
    row = []
    #             for i in range(self.num_rows):
                    row.append(self.rows[i][j])
                result.append(row)
            return Matrix(result)

    #     def __str__(self):
            return f"Matrix({self.rows})"

# Utility Functions
def create_vector(elements: List[float]) -> Vector:
#     """Create a new vector."""
    return Vector(elements)

def create_matrix(rows: List[List[float]]) -> Matrix:
#     """Create a new matrix."""
    return Matrix(rows)

def create_functor(name: str, func: Callable, params: List[str] = None) -> Functor:
#     """Create a new functor."""
    return Functor(name, func, params)