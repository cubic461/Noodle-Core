# Converted from Python to NoodleCore
# Original file: src

# """
# Bytecode Opcodes for Noodle Programming Language
# ------------------------------------------------
# This module defines the bytecode opcodes for the Noodle code generator.
# Each opcode represents an operation that can be executed by the Noodle runtime.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import enum.Enum
from dataclasses import dataclass
import typing.List


class OpCode(Enum)
    #     """Bytecode opcodes for the Noodle language"""

    #     # Stack operations
    PUSH = 0x01
    POP = 0x02
    DUP = 0x03
    SWAP = 0x04

    #     # Arithmetic operations
    ADD = 0x10
    SUB = 0x11
    MUL = 0x12
    DIV = 0x13
    MOD = 0x14
    NEG = 0x15

    #     # Comparison operations
    EQ = 0x20
    NE = 0x21
    LT = 0x22
    LE = 0x23
    GT = 0x24
    GE = 0x25

    #     # Flow control
    JMP = 0x30
    #     JZ = 0x31  # Jump if zero (false)
    #     JNZ = 0x32  # Jump if not zero (true)
    CALL = 0x33
    RET = 0x34

    #     # Memory operations
    LOAD = 0x40
    STORE = 0x41
    LOAD_GLOB = 0x42
    STORE_GLOB = 0x43

    #     # Matrix operations
    MATRIX_ZEROS = 0x50
    MATRIX_ONES = 0x51
    MATRIX_EYE = 0x52
    MATRIX_ADD = 0x53
    MATRIX_SUB = 0x54
    MATRIX_MUL = 0x55
    MATRIX_DIV = 0x56
    MATRIX_TRANSPOSE = 0x57

    #     # Python operations
    PYTHON_IMPORT = 0x60
    PYTHON_CALL = 0x61
    PYTHON_GETATTR = 0x62

    #     # Resource operations
    RESOURCE_ALLOC = 0x70
    RESOURCE_FREE = 0x71

    #     # Noodle-specific
    PRINT = 0x80
    IMPORT_MOD = 0x81
    CREATE_LIST = 0x82
    APPEND_LIST = 0x83
    CREATE_DICT = 0x84
    SET_DICT = 0x85

    #     # Control flow extensions
    ENTER_FRAME = 0x90
    EXIT_FRAME = 0x91

    #     # Special
    HALT = 0xFF


dataclass
class BytecodeInstruction
    #     """Represents a single bytecode instruction"""

    #     opcode: OpCode
    operands: List[Any] = None

    #     def __post_init__(self):
    #         """Validate instruction after creation"""
    #         if self.operands is None:
    self.operands = []
    #         if not isinstance(self.opcode, OpCode):
                raise TypeError(f"opcode must be an OpCode enum, got {type(self.opcode)}")

    #     def encode(self) -bytes):
    #         """Encode the instruction to bytes"""
    #         import struct

            # Encode opcode (1 byte) and operand count (1 byte)
    encoded = bytes([self.opcode.value, len(self.operands)])

    #         # Encode operands based on type
    #         for operand in self.operands:
    #             if isinstance(operand, int):
    encoded + = operand.to_bytes(4, "little", signed=True)
    #             elif isinstance(operand, float):
    encoded + = struct.pack("d", operand)
    #             elif isinstance(operand, str):
    encoded + = len(operand).to_bytes(2, "little") + operand.encode("utf-8")
    #             elif isinstance(operand, bool):
    #                 encoded += bytes([1 if operand else 0])
    #             else:
                    raise TypeError(f"Unsupported operand type: {type(operand)}")

    #         return encoded