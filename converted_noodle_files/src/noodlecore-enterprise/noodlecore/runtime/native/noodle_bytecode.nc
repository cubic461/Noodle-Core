# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Native NoodleCore Bytecode Format
# --------------------------------

# This module defines the bytecode format for the native NoodleCore runtime.
# The bytecode is designed to be simple yet powerful, supporting the core
# operations of the Noodle language.
# """

import struct
import dataclasses.dataclass,
import enum.Enum
import typing.Any,


class OpCode(Enum)
    #     """Native NoodleCore Operation Codes"""

    #     # Stack operations
    PUSH = 0x01  # Push value to stack
    POP = 0x02  # Pop value from stack
    DUP = 0x03  # Duplicate top of stack
    SWAP = 0x04  # Swap top two stack elements

    #     # Arithmetic operations
    ADD = 0x10  # Addition
    SUB = 0x11  # Subtraction
    MUL = 0x12  # Multiplication
    DIV = 0x13  # Division
    MOD = 0x14  # Modulo
    POW = 0x15  # Power
    NEG = 0x16  # Negation

    #     # Comparison operations
    EQ = 0x20  # Equal
    NE = 0x21  # Not equal
    LT = 0x22  # Less than
    LE = 0x23  # Less than or equal
    GT = 0x24  # Greater than
    GE = 0x25  # Greater than or equal

    #     # Logical operations
    AND = 0x30  # Logical AND
    OR = 0x31  # Logical OR
    NOT = 0x32  # Logical NOT

    #     # Control flow
    JMP = 0x40  # Unconditional jump
    #     JZ = 0x41  # Jump if zero (false)
    #     JNZ = 0x42  # Jump if not zero (true)
    CALL = 0x43  # Function call
    RET = 0x44  # Return from function

    #     # Variable operations
    LOAD = 0x50  # Load variable value
    STORE = 0x51  # Store variable value

    #     # Array operations
    ARRAY_NEW = 0x60  # Create new array
    ARRAY_GET = 0x61  # Get array element
    ARRAY_SET = 0x62  # Set array element
    ARRAY_LEN = 0x63  # Get array length

    #     # Matrix operations
    MATRIX_NEW = 0x70  # Create new matrix
    MATRIX_GET = 0x71  # Get matrix element
    MATRIX_SET = 0x72  # Set matrix element
    MATRIX_ADD = 0x73  # Matrix addition
    MATRIX_SUB = 0x74  # Matrix subtraction
    MATRIX_MUL = 0x75  # Matrix multiplication

    #     # I/O operations
    PRINT = 0x90  # Print value

    #     # Special operations
    NOP = 0xF0  # No operation
    HALT = 0xF1  # Halt execution


class ValueType(Enum)
    #     """Native value types"""

    NULL = 0x00
    BOOLEAN = 0x01
    INTEGER = 0x02
    FLOAT = 0x03
    STRING = 0x04
    ARRAY = 0x05
    MATRIX = 0x06
    FUNCTION = 0x07


# @dataclass
class Value
    #     """Represents a value in the NoodleCore runtime"""

    #     type: ValueType
    data: Any = None

    #     def is_null(self) -> bool:
    return self.type = = ValueType.NULL

    #     def is_boolean(self) -> bool:
    return self.type = = ValueType.BOOLEAN

    #     def is_integer(self) -> bool:
    return self.type = = ValueType.INTEGER

    #     def is_float(self) -> bool:
    return self.type = = ValueType.FLOAT

    #     def is_string(self) -> bool:
    return self.type = = ValueType.STRING

    #     def is_array(self) -> bool:
    return self.type = = ValueType.ARRAY

    #     def is_matrix(self) -> bool:
    return self.type = = ValueType.MATRIX

    #     def is_function(self) -> bool:
    return self.type = = ValueType.FUNCTION

    #     def as_boolean(self) -> bool:
    #         if self.type == ValueType.BOOLEAN:
    #             return self.data
    #         elif self.type == ValueType.INTEGER:
    return self.data ! = 0
    #         elif self.type == ValueType.FLOAT:
    return self.data ! = 0.0
    #         elif self.type == ValueType.NULL:
    #             return False
    #         else:
    #             return True  # Non-null values are truthy

    #     def as_integer(self) -> int:
    #         if self.type == ValueType.INTEGER:
    #             return self.data
    #         elif self.type == ValueType.FLOAT:
                return int(self.data)
    #         elif self.type == ValueType.BOOLEAN:
    #             return 1 if self.data else 0
    #         else:
                raise ValueError(f"Cannot convert {self.type} to integer")

    #     def as_float(self) -> float:
    #         if self.type == ValueType.FLOAT:
    #             return self.data
    #         elif self.type == ValueType.INTEGER:
                return float(self.data)
    #         elif self.type == ValueType.BOOLEAN:
    #             return 1.0 if self.data else 0.0
    #         else:
                raise ValueError(f"Cannot convert {self.type} to float")

    #     def as_string(self) -> str:
    #         if self.type == ValueType.STRING:
    #             return self.data
    #         elif self.type == ValueType.NULL:
    #             return "null"
    #         elif self.type == ValueType.BOOLEAN:
    #             return "true" if self.data else "false"
    #         elif self.type == ValueType.INTEGER:
                return str(self.data)
    #         elif self.type == ValueType.FLOAT:
                return str(self.data)
    #         else:
    #             return f"{self.type.name} object"

    #     def __str__(self) -> str:
            return self.as_string()

    #     def __repr__(self) -> str:
            return f"Value({self.type.name}, {self.data})"


# Helper functions to create values
def null_value() -> Value:
#     """Create a null value"""
    return Value(ValueType.NULL)


def boolean_value(value: bool) -> Value:
#     """Create a boolean value"""
    return Value(ValueType.BOOLEAN, value)


def integer_value(value: int) -> Value:
#     """Create an integer value"""
    return Value(ValueType.INTEGER, value)


def float_value(value: float) -> Value:
#     """Create a float value"""
    return Value(ValueType.FLOAT, value)


def string_value(value: str) -> Value:
#     """Create a string value"""
    return Value(ValueType.STRING, value)


def array_value(value: List[Value]) -> Value:
#     """Create an array value"""
    return Value(ValueType.ARRAY, value)


def matrix_value(value: List[List[Value]]) -> Value:
#     """Create a matrix value"""
    return Value(ValueType.MATRIX, value)


# @dataclass
class Instruction
    #     """Represents a native NoodleCore instruction"""

    #     opcode: OpCode
    operands: List[Any] = field(default_factory=list)

    #     def to_bytes(self) -> bytes:
    #         """Convert instruction to bytes"""
    #         # Opcode as 1 byte
    result = bytes([self.opcode.value])

    #         # Add operands based on type
    #         for operand in self.operands:
    #             if isinstance(operand, int):
                    # 4-byte integer (signed)
    result + = struct.pack("<i", operand)
    #             elif isinstance(operand, float):
    #                 # 8-byte float
    result + = struct.pack("<d", operand)
    #             elif isinstance(operand, str):
    #                 # String with length prefix (2 bytes)
    encoded = operand.encode("utf-8")
    result + = struct.pack("<H", len(encoded))
    result + = encoded
    #             elif isinstance(operand, bool):
    #                 # Boolean as byte
    #                 result += bytes([1 if operand else 0])
    #             else:
                    raise ValueError(f"Unsupported operand type: {type(operand)}")

    #         return result

    #     @classmethod
    #     def from_bytes(cls, data: bytes, offset: int = 0) -> tuple["Instruction", int]:
    #         """Create instruction from bytes"""
    #         if offset >= len(data):
                raise ValueError("Offset out of bounds")

    #         # Read opcode
    opcode = OpCode(data[offset])
    offset + = 1

    #         # Parse operands based on opcode
    operands = []

    #         if opcode in [OpCode.PUSH, OpCode.LOAD, OpCode.STORE, OpCode.JMP, OpCode.JZ, OpCode.JNZ, OpCode.CALL]:
    #             # Integer operand
    #             if offset + 4 > len(data):
    #                 raise ValueError("Insufficient data for integer operand")
    operand = struct.unpack("<i", data[offset:offset+4])[0]
                operands.append(operand)
    offset + = 4

    #         elif opcode in [OpCode.MATRIX_NEW]:
                # Two integer operands (rows, cols)
    #             if offset + 8 > len(data):
    #                 raise ValueError("Insufficient data for matrix dimensions")
    rows = struct.unpack("<i", data[offset:offset+4])[0]
    cols = struct.unpack("<i", data[offset:offset+4])[0]
                operands.extend([rows, cols])
    offset + = 8

    #         elif opcode == OpCode.PRINT:
    #             # String operand
    #             if offset + 2 > len(data):
    #                 raise ValueError("Insufficient data for string length")
    str_len = struct.unpack("<H", data[offset:offset+2])[0]
    offset + = 2

    #             if offset + str_len > len(data):
    #                 raise ValueError("Insufficient data for string")
    string_val = data[offset:offset+str_len].decode("utf-8")
                operands.append(string_val)
    offset + = str_len

            return cls(opcode, operands), offset

    #     def __str__(self) -> str:
    #         operands_str = ", ".join(str(op) for op in self.operands)
            return f"{self.opcode.name}({operands_str})"


# @dataclass
class BytecodeFile
    #     """Represents a compiled NoodleCore bytecode file"""

    magic: bytes = b"NBC\x01"  # Magic number and version
    functions: Dict[str, List[Instruction]] = field(default_factory=dict)
    string_table: List[str] = field(default_factory=list)

    #     def to_bytes(self) -> bytes:
    #         """Convert bytecode file to bytes"""
    result = self.magic

    #         # String table
    result + = struct.pack("<I", len(self.string_table))
    #         for string in self.string_table:
    encoded = string.encode("utf-8")
    result + = struct.pack("<I", len(encoded))
    result + = encoded

    #         # Functions
    result + = struct.pack("<I", len(self.functions))
    #         for name, instructions in self.functions.items():
    #             # Function name
    encoded_name = name.encode("utf-8")
    result + = struct.pack("<I", len(encoded_name))
    result + = encoded_name

    #             # Instructions
    result + = struct.pack("<I", len(instructions))
    #             for instruction in instructions:
    instr_bytes = instruction.to_bytes()
    result + = struct.pack("<I", len(instr_bytes))
    result + = instr_bytes

    #         return result

    #     @classmethod
    #     def from_bytes(cls, data: bytes) -> "BytecodeFile":
    #         """Create bytecode file from bytes"""
    #         # Check magic number
    #         if len(data) < 4 or data[:4] != b"NBC\x01":
                raise ValueError("Invalid bytecode file format")

    offset = 4
    result = cls()

    #         # Read string table
    #         if offset + 4 > len(data):
    #             raise ValueError("Insufficient data for string table size")
    string_count = struct.unpack("<I", data[offset:offset+4])[0]
    offset + = 4

    #         for _ in range(string_count):
    #             if offset + 4 > len(data):
    #                 raise ValueError("Insufficient data for string length")
    str_len = struct.unpack("<I", data[offset:offset+4])[0]
    offset + = 4

    #             if offset + str_len > len(data):
    #                 raise ValueError("Insufficient data for string")
    string_val = data[offset:offset+str_len].decode("utf-8")
                result.string_table.append(string_val)
    offset + = str_len

    #         # Read functions
    #         if offset + 4 > len(data):
    #             raise ValueError("Insufficient data for function count")
    function_count = struct.unpack("<I", data[offset:offset+4])[0]
    offset + = 4

    #         for _ in range(function_count):
    #             # Function name
    #             if offset + 4 > len(data):
    #                 raise ValueError("Insufficient data for function name length")
    name_len = struct.unpack("<I", data[offset:offset+4])[0]
    offset + = 4

    #             if offset + name_len > len(data):
    #                 raise ValueError("Insufficient data for function name")
    name = data[offset:offset+name_len].decode("utf-8")
    offset + = name_len

    #             # Instructions
    #             if offset + 4 > len(data):
    #                 raise ValueError("Insufficient data for instruction count")
    instr_count = struct.unpack("<I", data[offset:offset+4])[0]
    offset + = 4

    instructions = []
    #             for _ in range(instr_count):
    #                 if offset + 4 > len(data):
    #                     raise ValueError("Insufficient data for instruction length")
    instr_len = struct.unpack("<I", data[offset:offset+4])[0]
    offset + = 4

    #                 if offset + instr_len > len(data):
    #                     raise ValueError("Insufficient data for instruction")
    instr_data = math.add(data[offset:offset, instr_len])
    instruction, new_offset = Instruction.from_bytes(instr_data)
    #                 if new_offset != instr_len:
                        raise ValueError("Instruction length mismatch")
                    instructions.append(instruction)
    offset + = instr_len

    result.functions[name] = instructions

    #         return result

    #     def save_to_file(self, filename: str):
    #         """Save bytecode to file"""
    #         with open(filename, "wb") as f:
                f.write(self.to_bytes())

    #     @classmethod
    #     def load_from_file(cls, filename: str) -> "BytecodeFile":
    #         """Load bytecode from file"""
    #         with open(filename, "rb") as f:
    data = f.read()
            return cls.from_bytes(data)