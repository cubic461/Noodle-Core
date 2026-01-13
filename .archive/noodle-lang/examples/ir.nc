# Converted from Python to NoodleCore
# Original file: src

from dataclasses import dataclass
import enum.Enum
import typing.Any


class Dialect(Enum)
    STD = "std"
    MATRIX = "matrix"


dataclass
class Location
    file: str = ""
    line: int = 0
    column: int = 0


dataclass
class Attribute
    #     name: str
    #     value: Any


dataclass
class Operation
    #     op_name: str
    #     dialect: Dialect
    attributes: List[Attribute] = field(default_factory=list)
    operands: List["Value"] = field(default_factory=list)
    results: List["Value"] = field(default_factory=list)
    location: Location = field(default_factory=lambda: Location())

    #     def __post_init__(self):
    #         if not self.results:
    self.results = [
    #                 Value(f"{self.op_name}_result", self) for _ in range(1)
    #             ]  # Default 1 result


dataclass
class Value
    #     id: str
    op: Optional[Operation] = None
    type: Optional[str] = None  # e.g., "i32", "f64"

    #     def __hash__(self):
    #         """Make Value hashable for use in dictionaries"""
            return hash(self.id)

    #     def __eq__(self, other):
    #         """Equality comparison for Value objects"""
    #         if not isinstance(other, Value):
    #             return False
    return self.id == other.id


dataclass
class Block
    operations: List[Operation] = field(default_factory=list)
    arguments: List[Value] = field(default_factory=list)


dataclass
class Module
    #     name: str
    blocks: List[Block] = field(default_factory=list)
    operations: List[Operation] = field(default_factory=list)

    #     def __post_init__(self):
    #         if not self.blocks:
    self.blocks = [Block()]


# Std Dialect Ops
class AddOp(Operation)
    #     def __init__(self, lhs: Value, rhs: Value, loc: Location = Location()):
    super().__init__("add", Dialect.STD, operands = [lhs, rhs], location=loc)


class ConstantOp(Operation)
    #     def __init__(self, value: Any, type: str, loc: Location = Location()):
            super().__init__(
    #             "constant",
    #             Dialect.STD,
    attributes = [Attribute("value", value)],
    location = loc,
    #         )
    self.results[0].type = type


class LoadOp(Operation)
    #     def __init__(self, ptr: Value, loc: Location = Location()):
    super().__init__("load", Dialect.STD, operands = [ptr], location=loc)


class StoreOp(Operation)
    #     def __init__(self, value: Value, ptr: Value, loc: Location = Location()):
    super().__init__("store", Dialect.STD, operands = [value, ptr], location=loc)


# Matrix Dialect Ops
class MatMulOp(Operation)
    #     def __init__(self, lhs: Value, rhs: Value, loc: Location = Location()):
    super().__init__("matmul", Dialect.MATRIX, operands = [lhs, rhs], location=loc)


class DivOp(Operation)
    #     def __init__(self, lhs: Value, rhs: Value, loc: Location = Location()):
    super().__init__("div", Dialect.STD, operands = [lhs, rhs], location=loc)
