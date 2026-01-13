# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Type definitions for Noodle Programming Language
# -----------------------------------------------
# This module defines the type system for Noodle, including primitive types,
# composite types, and type checking utilities.
# """

import abc.ABC,
import dataclasses.dataclass
import enum.Enum
import typing.Any,


class BasicType(Enum)
    #     """
    #     Basic primitive types in Noodle
    #     """

    INT = "int"
    FLOAT = "float"
    BOOL = "bool"
    STRING = "string"
    VOID = "void"


class Type(Enum)
    #     """
    #     Primitive types in Noodle
    #     """

    INT = "int"
    FLOAT = "float"
    BOOL = "bool"
    STRING = "string"
    LIST = "list"
    DICT = "dict"
    MATRIX = "matrix"
    ARRAY = "array"
    NIL = "nil"
    FUNCTION = "function"
    ANY = "any"


class BaseType
    #     """
    #     Base type class for Noodle
    #     """
    #     def __init__(self, name: str):
    self.name = name

    #     def __str__(self):
    #         return self.name

    #     def __repr__(self):
            return f"BaseType('{self.name}')"

    #     @classmethod
    #     def is_numeric(cls, type_str: str) -> bool:
    #         """Check if a type string represents a numeric type"""
            return type_str in (cls.INT.value, cls.FLOAT.value)

    #     @classmethod
    #     def is_primitive(cls, type_str: str) -> bool:
    #         """Check if a type string represents a primitive type"""
    #         return type_str in [
    #             t.value
    #             for t in cls
    #             if t != cls.LIST
    and t ! = cls.DICT
    and t ! = cls.MATRIX
    and t ! = cls.ARRAY
    and t ! = cls.FUNCTION
    #         ]


# @dataclass
class ArrayType
    #     """
    #     Type for arrays with specified dimensions and dtype
    #     """

        dtype: str  # Data type (int, float, etc.)
    #     shape: Tuple[int, ...]  # Array shape

    #     def __str__(self):
            return f"Array[{self.dtype}, {', '.join(map(str, self.shape))}]"


# @dataclass
class MatrixType
    #     """
    #     Type for matrices with specified dimensions and element type
    #     """

    #     rows: int
    #     cols: int
        element_type: str  # Element type (int, float, etc.)

    #     def __str__(self):
    #         return f"Matrix[{self.rows}x{self.cols}, {self.element_type}]"


# @dataclass
class TensorType
    #     """
    #     Type for tensors with specified shape and element type
    #     """

    #     shape: Tuple[int, ...]  # Tensor shape
        element_type: str  # Element type (int, float, etc.)

    #     def __str__(self):
            return f"Tensor[{', '.join(map(str, self.shape))}, {self.element_type}]"


# @dataclass
class UnionType
    #     """
    #     Type for union types that can be one of several possible types
    #     """

    #     types: List[str]  # List of possible types

    #     def __str__(self):
            return f"Union[{', '.join(self.types)}]"


# @dataclass
class FunctionType
    #     """
    #     Type for functions with parameter and return types
    #     """

    #     parameter_types: List[str]
    #     return_type: str

    #     def __str__(self):
    params = ", ".join(self.parameter_types)
            return f"Function[({params}), {self.return_type}]"


class TypeChecker
    #     """
    #     Utilities for type checking and type compatibility
    #     """

    #     @staticmethod
    #     def is_compatible(source_type: str, target_type: str) -> bool:
    #         """
    #         Check if source type is compatible with target type

    #         Args:
    #             source_type: Source type string
    #             target_type: Target type string

    #         Returns:
    #             True if types are compatible
    #         """
    #         # Same types are always compatible
    #         if source_type == target_type:
    #             return True

    #         # Numeric type compatibility
    #         if Type.is_numeric(source_type) and Type.is_numeric(target_type):
    #             return True

    #         # Any type is compatible with anything
    #         if source_type == Type.ANY.value or target_type == Type.ANY.value:
    #             return True

            # List compatibility (element type must be compatible)
    #         if source_type.startswith("List[") and target_type.startswith("List["):
    source_elem = math.subtract(source_type[5:, 1])
    target_elem = math.subtract(target_type[5:, 1])
                return TypeChecker.is_compatible(source_elem, target_elem)

            # Dictionary compatibility (key and value types must be compatible)
    #         if source_type.startswith("Dict[") and target_type.startswith("Dict["):
    source_key = source_type[5 : source_type.index(",")]
    source_val = source_type[source_type.index(",") + 1 : -1]
    target_key = target_type[5 : target_type.index(",")]
    target_val = target_type[target_type.index(",") + 1 : -1]
                return TypeChecker.is_compatible(
    #                 source_key, target_key
                ) and TypeChecker.is_compatible(source_val, target_val)

    #         return False

    #     @staticmethod
    #     def get_common_type(type1: str, type2: str) -> Optional[str]:
    #         """
    #         Get the most general common type between two types

    #         Args:
    #             type1: First type
    #             type2: Second type

    #         Returns:
    #             Common type or None if no common type exists
    #         """
    #         # Same types
    #         if type1 == type2:
    #             return type1

    #         # Numeric types promote to float
    #         if Type.is_numeric(type1) and Type.is_numeric(type2):
    #             return Type.FLOAT.value

    #         # List types
    #         if type1.startswith("List[") and type2.startswith("List["):
    elem1 = math.subtract(type1[5:, 1])
    elem2 = math.subtract(type2[5:, 1])
    common_elem = TypeChecker.get_common_type(elem1, elem2)
    #             if common_elem:
    #                 return f"List[{common_elem}]"

    #         return Type.ANY.value
