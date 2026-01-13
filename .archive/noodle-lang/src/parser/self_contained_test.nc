# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Self-Contained Test for Native NoodleCore Runtime
# --------------------------------------------------

# This script directly tests the native NoodleCore runtime components
# by copying the necessary code into this file, avoiding import issues.
# """

import struct
import sys
import os
import time
import re
from dataclasses import dataclass
import enum.Enum
import typing.Any


# ====== Bytecode Format ======

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


dataclass
class Value
    #     """Represents a value in the NoodleCore runtime"""

    #     type: ValueType
    data: Any = None

    #     def is_null(self) -bool):
    return self.type == ValueType.NULL

    #     def is_boolean(self) -bool):
    return self.type == ValueType.BOOLEAN

    #     def is_integer(self) -bool):
    return self.type == ValueType.INTEGER

    #     def is_float(self) -bool):
    return self.type == ValueType.FLOAT

    #     def is_string(self) -bool):
    return self.type == ValueType.STRING

    #     def is_array(self) -bool):
    return self.type == ValueType.ARRAY

    #     def is_matrix(self) -bool):
    return self.type == ValueType.MATRIX

    #     def is_function(self) -bool):
    return self.type == ValueType.FUNCTION

    #     def as_boolean(self) -bool):
    #         if self.type == ValueType.BOOLEAN:
    #             return self.data
    #         elif self.type == ValueType.INTEGER:
    return self.data != 0
    #         elif self.type == ValueType.FLOAT:
    return self.data != 0.0
    #         elif self.type == ValueType.NULL:
    #             return False
    #         else:
    #             return True  # Non-null values are truthy

    #     def as_integer(self) -int):
    #         if self.type == ValueType.INTEGER:
    #             return self.data
    #         elif self.type == ValueType.FLOAT:
                return int(self.data)
    #         elif self.type == ValueType.BOOLEAN:
    #             return 1 if self.data else 0
    #         else:
                raise ValueError(f"Cannot convert {self.type} to integer")

    #     def as_float(self) -float):
    #         if self.type == ValueType.FLOAT:
    #             return self.data
    #         elif self.type == ValueType.INTEGER:
                return float(self.data)
    #         elif self.type == ValueType.BOOLEAN:
    #             return 1.0 if self.data else 0.0
    #         else:
                raise ValueError(f"Cannot convert {self.type} to float")

    #     def as_string(self) -str):
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

    #     def __str__(self) -str):
            return self.as_string()

    #     def __repr__(self) -str):
            return f"Value({self.type.name}, {self.data})"


# Helper functions to create values
def null_value() -Value):
#     """Create a null value"""
    return Value(ValueType.NULL)


def boolean_value(value: bool) -Value):
#     """Create a boolean value"""
    return Value(ValueType.BOOLEAN, value)


def integer_value(value: int) -Value):
#     """Create an integer value"""
    return Value(ValueType.INTEGER, value)


def float_value(value: float) -Value):
#     """Create a float value"""
    return Value(ValueType.FLOAT, value)


def string_value(value: str) -Value):
#     """Create a string value"""
    return Value(ValueType.STRING, value)


def array_value(value: List[Value]) -Value):
#     """Create an array value"""
    return Value(ValueType.ARRAY, value)


def matrix_value(value: List[List[Value]]) -Value):
#     """Create a matrix value"""
    return Value(ValueType.MATRIX, value)


dataclass
class Instruction
    #     """Represents a native NoodleCore instruction"""

    #     opcode: OpCode
    operands: List[Any] = field(default_factory=list)

    #     def __str__(self) -str):
    #         operands_str = ", ".join(str(op) for op in self.operands)
            return f"{self.opcode.name}({operands_str})"


# ====== Interpreter ======

class CallFrame
    #     """Represents a function call frame"""

    #     def __init__(self, function_name: str, return_address: int, stack_base: int = 0):
    self.function_name = function_name
    self.return_address = return_address
    self.local_variables: Dict[str, Value] = {}
    self.stack_base = stack_base


class NoodleRuntimeError(Exception)
    #     """Runtime error in NoodleCore execution"""
    #     def __init__(self, message: str, instruction: Optional[Instruction] = None):
    self.message = message
    self.instruction = instruction
            super().__init__(message)


class NoodleCoreInterpreter
    #     """Native NoodleCore bytecode interpreter"""

    #     def __init__(self, debug: bool = False):""Initialize the interpreter"""
    self.debug = debug
    self.stack: List[Value] = []
    self.call_stack: List[CallFrame] = []
    self.global_variables: Dict[str, Value] = {}
    self.current_function: str = ""
    self.current_instructions: List[Instruction] = []
    self.pc: int = 0  # Program counter
    self.halted: bool = False
    self.output_buffer: List[str] = []

    #         # Statistics
    self.instruction_count: int = 0
    self.max_stack_depth: int = 0

    #     def load_bytecode(self, functions: Dict[str, List[Instruction]]):
    #         """Load bytecode for execution"""
            self.global_variables.clear()
            self.stack.clear()
            self.call_stack.clear()
    self.current_function = ""
    self.current_instructions = []
    self.pc = 0
    self.halted = False
    self.instruction_count = 0
    self.max_stack_depth = 0

    #         # Store all functions
    self.functions = functions

    #     def execute_function(self, function_name: str) -Value):
    #         """Execute a specific function"""
    #         if function_name not in self.functions:
                raise NoodleRuntimeError(f"Function '{function_name}' not found")

    #         # Set up initial call frame
    self.current_function = function_name
    self.current_instructions = self.functions[function_name]
    self.pc = 0
            self.call_stack.clear()
            self.stack.clear()

    #         # Add initial call frame
            self.call_stack.append(CallFrame(
    function_name = function_name,
    #             return_address=-1,  # No return address for initial call
    stack_base = 0
    #         ))

    #         # Execute until halt or return
    #         while not self.halted and self.pc < len(self.current_instructions):
                self._execute_instruction()

    #             # Update statistics
    self.instruction_count + = 1
    self.max_stack_depth = max(self.max_stack_depth, len(self.stack))

    #             if self.debug:
                    self._debug_state()

    #         # Return value if any
    #         return self.stack[-1] if self.stack else null_value()

    #     def _execute_instruction(self):
    #         """Execute the current instruction"""
    #         if self.pc >= len(self.current_instructions):
                raise NoodleRuntimeError("Program counter out of bounds")

    instruction = self.current_instructions[self.pc]

    #         try:
    #             if instruction.opcode == OpCode.PUSH:
                    self._execute_push(instruction)
    #             elif instruction.opcode == OpCode.POP:
                    self._execute_pop(instruction)
    #             elif instruction.opcode == OpCode.ADD:
                    self._execute_add(instruction)
    #             elif instruction.opcode == OpCode.SUB:
                    self._execute_sub(instruction)
    #             elif instruction.opcode == OpCode.MUL:
                    self._execute_mul(instruction)
    #             elif instruction.opcode == OpCode.DIV:
                    self._execute_div(instruction)
    #             elif instruction.opcode == OpCode.EQ:
                    self._execute_eq(instruction)
    #             elif instruction.opcode == OpCode.NE:
                    self._execute_ne(instruction)
    #             elif instruction.opcode == OpCode.LT:
                    self._execute_lt(instruction)
    #             elif instruction.opcode == OpCode.GT:
                    self._execute_gt(instruction)
    #             elif instruction.opcode == OpCode.AND:
                    self._execute_and(instruction)
    #             elif instruction.opcode == OpCode.OR:
                    self._execute_or(instruction)
    #             elif instruction.opcode == OpCode.NOT:
                    self._execute_not(instruction)
    #             elif instruction.opcode == OpCode.JMP:
                    self._execute_jmp(instruction)
    #             elif instruction.opcode == OpCode.JZ:
                    self._execute_jz(instruction)
    #             elif instruction.opcode == OpCode.JNZ:
                    self._execute_jnz(instruction)
    #             elif instruction.opcode == OpCode.LOAD:
                    self._execute_load(instruction)
    #             elif instruction.opcode == OpCode.STORE:
                    self._execute_store(instruction)
    #             elif instruction.opcode == OpCode.ARRAY_NEW:
                    self._execute_array_new(instruction)
    #             elif instruction.opcode == OpCode.ARRAY_GET:
                    self._execute_array_get(instruction)
    #             elif instruction.opcode == OpCode.ARRAY_SET:
                    self._execute_array_set(instruction)
    #             elif instruction.opcode == OpCode.ARRAY_LEN:
                    self._execute_array_len(instruction)
    #             elif instruction.opcode == OpCode.MATRIX_NEW:
                    self._execute_matrix_new(instruction)
    #             elif instruction.opcode == OpCode.MATRIX_GET:
                    self._execute_matrix_get(instruction)
    #             elif instruction.opcode == OpCode.MATRIX_SET:
                    self._execute_matrix_set(instruction)
    #             elif instruction.opcode == OpCode.MATRIX_ADD:
                    self._execute_matrix_add(instruction)
    #             elif instruction.opcode == OpCode.MATRIX_SUB:
                    self._execute_matrix_sub(instruction)
    #             elif instruction.opcode == OpCode.MATRIX_MUL:
                    self._execute_matrix_mul(instruction)
    #             elif instruction.opcode == OpCode.PRINT:
                    self._execute_print(instruction)
    #             elif instruction.opcode == OpCode.NOP:
    #                 pass  # No operation
    #             elif instruction.opcode == OpCode.HALT:
    self.halted = True
    #             else:
                    raise NoodleRuntimeError(f"Unknown opcode: {instruction.opcode}")

    self.pc + = 1

    #         except Exception as e:
                raise NoodleRuntimeError(
                    f"Error executing instruction {instruction}: {str(e)}",
    #                 instruction
    #             ) from e

    #     def _execute_push(self, instruction: Instruction):
    #         """Execute PUSH instruction"""
    operand = instruction.operands[0]
    #         if isinstance(operand, int):
                self.stack.append(integer_value(operand))
    #         elif isinstance(operand, float):
                self.stack.append(float_value(operand))
    #         elif isinstance(operand, bool):
                self.stack.append(boolean_value(operand))
    #         elif isinstance(operand, str):
                self.stack.append(string_value(operand))
    #         else:
                raise NoodleRuntimeError(f"Unsupported PUSH operand type: {type(operand)}")

    #     def _execute_pop(self, instruction: Instruction):
    #         """Execute POP instruction"""
    #         if self.stack:
                self.stack.pop()

    #     def _execute_add(self, instruction: Instruction):
    #         """Execute ADD instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in ADD")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = integer_value(a.as_integer() + b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = float_value(a.as_float() + b.as_float())
    #         elif a.is_string() and b.is_string():
    result = string_value(a.as_string() + b.as_string())
    #         else:
                raise NoodleRuntimeError(f"Cannot add {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_sub(self, instruction: Instruction):
    #         """Execute SUB instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in SUB")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = integer_value(a.as_integer() - b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = float_value(a.as_float() - b.as_float())
    #         else:
                raise NoodleRuntimeError(f"Cannot subtract {b.type} from {a.type}")

            self.stack.append(result)

    #     def _execute_mul(self, instruction: Instruction):
    #         """Execute MUL instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in MUL")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = integer_value(a.as_integer() * b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = float_value(a.as_float() * b.as_float())
    #         else:
                raise NoodleRuntimeError(f"Cannot multiply {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_div(self, instruction: Instruction):
    #         """Execute DIV instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in DIV")

    b = self.stack.pop()
    a = self.stack.pop()

    #         # Check for division by zero
    #         if (b.is_integer() and b.as_integer() == 0) or (b.is_float() and b.as_float() == 0.0):
                raise NoodleRuntimeError("Division by zero")

    #         if a.is_integer() and b.is_integer():
    result = math.divide(integer_value(a.as_integer(), / b.as_integer()))
    #         elif a.is_float() or b.is_float():
    result = math.divide(float_value(a.as_float(), b.as_float()))
    #         else:
                raise NoodleRuntimeError(f"Cannot divide {a.type} by {b.type}")

            self.stack.append(result)

    #     def _execute_eq(self, instruction: Instruction):
    #         """Execute EQ instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in EQ")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.type != b.type:
    result = boolean_value(False)
    #         elif a.is_null() and b.is_null():
    result = boolean_value(True)
    #         elif a.is_boolean():
    result = boolean_value(a.as_boolean() == b.as_boolean())
    #         elif a.is_integer():
    result = boolean_value(a.as_integer() == b.as_integer())
    #         elif a.is_float():
    result = boolean_value(a.as_float() == b.as_float())
    #         elif a.is_string():
    result = boolean_value(a.as_string() == b.as_string())
    #         else:
    result = boolean_value(a.data == b.data)

            self.stack.append(result)

    #     def _execute_ne(self, instruction: Instruction):
    #         """Execute NE instruction"""
            self._execute_eq(instruction)
    result = self.stack.pop()
            self.stack.append(boolean_value(not result.as_boolean()))

    #     def _execute_lt(self, instruction: Instruction):
    #         """Execute LT instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in LT")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = boolean_value(a.as_integer() < b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = boolean_value(a.as_float() < b.as_float())
    #         elif a.is_string() and b.is_string():
    result = boolean_value(a.as_string() < b.as_string())
    #         else:
                raise NoodleRuntimeError(f"Cannot compare {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_gt(self, instruction: Instruction):
    #         """Execute GT instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in GT")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = boolean_value(a.as_integer() b.as_integer())
    #         elif a.is_float() or b.is_float()):
    result = boolean_value(a.as_float() b.as_float())
    #         elif a.is_string() and b.is_string()):
    result = boolean_value(a.as_string() b.as_string())
    #         else):
                raise NoodleRuntimeError(f"Cannot compare {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_and(self, instruction: Instruction):
    #         """Execute AND instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in AND")

    b = self.stack.pop()
    a = self.stack.pop()

    result = boolean_value(a.as_boolean() and b.as_boolean())
            self.stack.append(result)

    #     def _execute_or(self, instruction: Instruction):
    #         """Execute OR instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in OR")

    b = self.stack.pop()
    a = self.stack.pop()

    result = boolean_value(a.as_boolean() or b.as_boolean())
            self.stack.append(result)

    #     def _execute_not(self, instruction: Instruction):
    #         """Execute NOT instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in NOT")

    a = self.stack.pop()
    result = boolean_value(not a.as_boolean())
            self.stack.append(result)

    #     def _execute_jmp(self, instruction: Instruction):
    #         """Execute JMP instruction"""
    target = instruction.operands[0]
    #         if target < 0 or target >= len(self.current_instructions):
                raise NoodleRuntimeError(f"Invalid jump target: {target}")
    self.pc = target - 1  # -1 because pc will be incremented

    #     def _execute_jz(self, instruction: Instruction):
    #         """Execute JZ instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in JZ")

    condition = self.stack.pop()
    #         if not condition.as_boolean():
    target = instruction.operands[0]
    #             if target < 0 or target >= len(self.current_instructions):
                    raise NoodleRuntimeError(f"Invalid jump target: {target}")
    self.pc = target - 1  # -1 because pc will be incremented

    #     def _execute_jnz(self, instruction: Instruction):
    #         """Execute JNZ instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in JNZ")

    condition = self.stack.pop()
    #         if condition.as_boolean():
    target = instruction.operands[0]
    #             if target < 0 or target >= len(self.current_instructions):
                    raise NoodleRuntimeError(f"Invalid jump target: {target}")
    self.pc = target - 1  # -1 because pc will be incremented

    #     def _execute_load(self, instruction: Instruction):
    #         """Execute LOAD instruction"""
    var_index = instruction.operands[0]

    #         # Get variable name from index
    var_name = f"var_{var_index}"

    #         # Check local variables first
    #         if self.call_stack and var_name in self.call_stack[-1].local_variables:
    value = self.call_stack[ - 1].local_variables[var_name]
    #         elif var_name in self.global_variables:
    value = self.global_variables[var_name]
    #         else:
                raise NoodleRuntimeError(f"Variable '{var_name}' not found")

            self.stack.append(value)

    #     def _execute_store(self, instruction: Instruction):
    #         """Execute STORE instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in STORE")

    var_index = instruction.operands[0]
    var_name = f"var_{var_index}"
    value = self.stack.pop()

    #         # Store in local variables if in a function
    #         if self.call_stack:
    self.call_stack[-1].local_variables[var_name] = value
    #         else:
    self.global_variables[var_name] = value

    #     def _execute_array_new(self, instruction: Instruction):
    #         """Execute ARRAY_NEW instruction"""
    array = []
            self.stack.append(array_value(array))

    #     def _execute_array_get(self, instruction: Instruction):
    #         """Execute ARRAY_GET instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in ARRAY_GET")

    index = self.stack.pop()
    array_val = self.stack.pop()

    #         if not array_val.is_array():
                raise NoodleRuntimeError("ARRAY_GET requires array value")

    #         if not index.is_integer():
                raise NoodleRuntimeError("Array index must be integer")

    idx = index.as_integer()
    #         if idx < 0 or idx >= len(array_val.data):
                raise NoodleRuntimeError(f"Array index out of bounds: {idx}")

            self.stack.append(array_val.data[idx])

    #     def _execute_array_set(self, instruction: Instruction):
    #         """Execute ARRAY_SET instruction"""
    #         if len(self.stack) < 3:
                raise NoodleRuntimeError("Stack underflow in ARRAY_SET")

    value = self.stack.pop()
    index = self.stack.pop()
    array_val = self.stack.pop()

    #         if not array_val.is_array():
                raise NoodleRuntimeError("ARRAY_SET requires array value")

    #         if not index.is_integer():
                raise NoodleRuntimeError("Array index must be integer")

    idx = index.as_integer()
    #         if idx < 0 or idx >= len(array_val.data):
                raise NoodleRuntimeError(f"Array index out of bounds: {idx}")

    array_val.data[idx] = value
            self.stack.append(array_val)

    #     def _execute_array_len(self, instruction: Instruction):
    #         """Execute ARRAY_LEN instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in ARRAY_LEN")

    array_val = self.stack.pop()

    #         if not array_val.is_array():
                raise NoodleRuntimeError("ARRAY_LEN requires array value")

            self.stack.append(integer_value(len(array_val.data)))

    #     def _execute_matrix_new(self, instruction: Instruction):
    #         """Execute MATRIX_NEW instruction"""
    rows = instruction.operands[0]
    cols = instruction.operands[1]

    matrix = []
    #         for _ in range(rows):
    #             row = [null_value() for _ in range(cols)]
                matrix.append(row)

            self.stack.append(matrix_value(matrix))

    #     def _execute_matrix_get(self, instruction: Instruction):
    #         """Execute MATRIX_GET instruction"""
    #         if len(self.stack) < 3:
                raise NoodleRuntimeError("Stack underflow in MATRIX_GET")

    col = self.stack.pop()
    row = self.stack.pop()
    matrix_val = self.stack.pop()

    #         if not matrix_val.is_matrix():
                raise NoodleRuntimeError("MATRIX_GET requires matrix value")

    #         if not row.is_integer() or not col.is_integer():
                raise NoodleRuntimeError("Matrix indices must be integers")

    r = row.as_integer()
    c = col.as_integer()

    #         if r < 0 or r >= len(matrix_val.data) or c < 0 or c >= len(matrix_val.data[0]):
                raise NoodleRuntimeError(f"Matrix index out of bounds: ({r}, {c})")

            self.stack.append(matrix_val.data[r][c])

    #     def _execute_matrix_set(self, instruction: Instruction):
    #         """Execute MATRIX_SET instruction"""
    #         if len(self.stack) < 4:
                raise NoodleRuntimeError("Stack underflow in MATRIX_SET")

    value = self.stack.pop()
    col = self.stack.pop()
    row = self.stack.pop()
    matrix_val = self.stack.pop()

    #         if not matrix_val.is_matrix():
                raise NoodleRuntimeError("MATRIX_SET requires matrix value")

    #         if not row.is_integer() or not col.is_integer():
                raise NoodleRuntimeError("Matrix indices must be integers")

    r = row.as_integer()
    c = col.as_integer()

    #         if r < 0 or r >= len(matrix_val.data) or c < 0 or c >= len(matrix_val.data[0]):
                raise NoodleRuntimeError(f"Matrix index out of bounds: ({r}, {c})")

    matrix_val.data[r][c] = value
            self.stack.append(matrix_val)

    #     def _execute_matrix_add(self, instruction: Instruction):
    #         """Execute MATRIX_ADD instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in MATRIX_ADD")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if not a.is_matrix() or not b.is_matrix():
                raise NoodleRuntimeError("MATRIX_ADD requires matrix values")

    a_rows = len(a.data)
    #         a_cols = len(a.data[0]) if a_rows 0 else 0
    b_rows = len(b.data)
    #         b_cols = len(b.data[0]) if b_rows > 0 else 0

    #         if a_rows != b_rows or a_cols != b_cols):
    #             raise NoodleRuntimeError("Matrix dimensions must match for addition")

    result = []
    #         for i in range(a_rows):
    row = []
    #             for j in range(a_cols):
    #                 if a.data[i][j].is_integer() and b.data[i][j].is_integer():
                        row.append(integer_value(
                            a.data[i][j].as_integer() + b.data[i][j].as_integer()
    #                     ))
    #                 elif a.data[i][j].is_float() or b.data[i][j].is_float():
                        row.append(float_value(
                            a.data[i][j].as_float() + b.data[i][j].as_float()
    #                     ))
    #                 else:
                        raise NoodleRuntimeError("Matrix elements must be numeric")
                result.append(row)

            self.stack.append(matrix_value(result))

    #     def _execute_matrix_sub(self, instruction: Instruction):
    #         """Execute MATRIX_SUB instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in MATRIX_SUB")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if not a.is_matrix() or not b.is_matrix():
                raise NoodleRuntimeError("MATRIX_SUB requires matrix values")

    a_rows = len(a.data)
    #         a_cols = len(a.data[0]) if a_rows 0 else 0
    b_rows = len(b.data)
    #         b_cols = len(b.data[0]) if b_rows > 0 else 0

    #         if a_rows != b_rows or a_cols != b_cols):
    #             raise NoodleRuntimeError("Matrix dimensions must match for subtraction")

    result = []
    #         for i in range(a_rows):
    row = []
    #             for j in range(a_cols):
    #                 if a.data[i][j].is_integer() and b.data[i][j].is_integer():
                        row.append(integer_value(
                            a.data[i][j].as_integer() - b.data[i][j].as_integer()
    #                     ))
    #                 elif a.data[i][j].is_float() or b.data[i][j].is_float():
                        row.append(float_value(
                            a.data[i][j].as_float() - b.data[i][j].as_float()
    #                     ))
    #                 else:
                        raise NoodleRuntimeError("Matrix elements must be numeric")
                result.append(row)

            self.stack.append(matrix_value(result))

    #     def _execute_matrix_mul(self, instruction: Instruction):
    #         """Execute MATRIX_MUL instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in MATRIX_MUL")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if not a.is_matrix() or not b.is_matrix():
                raise NoodleRuntimeError("MATRIX_MUL requires matrix values")

    a_rows = len(a.data)
    #         a_cols = len(a.data[0]) if a_rows 0 else 0
    b_rows = len(b.data)
    #         b_cols = len(b.data[0]) if b_rows > 0 else 0

    #         if a_cols != b_rows):
    #             raise NoodleRuntimeError("Matrix dimensions must be compatible for multiplication")

    result = []
    #         for i in range(a_rows):
    row = []
    #             for j in range(b_cols):
    sum_val = 0
    #                 for k in range(a_cols):
    #                     if a.data[i][k].is_integer() and b.data[k][j].is_integer():
    sum_val + = a.data[i][k].as_integer() * b.data[k][j].as_integer()
    #                     elif a.data[i][k].is_float() or b.data[k][j].is_float():
    sum_val + = a.data[i][k].as_float() * b.data[k][j].as_float()
    #                     else:
                            raise NoodleRuntimeError("Matrix elements must be numeric")

    #                 # Determine if result should be integer or float
    #                 if isinstance(sum_val, int):
                        row.append(integer_value(sum_val))
    #                 else:
                        row.append(float_value(sum_val))
                result.append(row)

            self.stack.append(matrix_value(result))

    #     def _execute_print(self, instruction: Instruction):
    #         """Execute PRINT instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in PRINT")

    value = self.stack.pop()
    output = value.as_string()
            self.output_buffer.append(output)
            print(output)  # Also print to stdout

    #     def _debug_state(self):
    #         """Print debug information about the current state"""
            print(f"--- Debug State ---")
            print(f"Function: {self.current_function}")
            print(f"PC: {self.pc}/{len(self.current_instructions)}")
    #         print(f"Stack: {[str(v) for v in self.stack]}")
    #         print(f"Call Stack: {[(f.function_name, f.return_address) for f in self.call_stack]}")
    #         print(f"Global Vars: {[(k, str(v)) for k, v in self.global_variables.items()]}")
    #         if self.call_stack:
    #             print(f"Local Vars: {[(k, str(v)) for k, v in self.call_stack[-1].local_variables.items()]}")
            print("-------------------")

    #     def get_output(self) -List[str]):
    #         """Get the output buffer"""
            return self.output_buffer.copy()

    #     def clear_output(self):
    #         """Clear the output buffer"""
            self.output_buffer.clear()

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get execution statistics"""
    #         return {
    #             "instruction_count": self.instruction_count,
    #             "max_stack_depth": self.max_stack_depth,
                "current_stack_depth": len(self.stack),
    #             "functions_called": len(set(f.function_name for f in self.call_stack)),
                "global_variables": len(self.global_variables),
    #             "halted": self.halted
    #         }


# ====== Simple Parser ======

class ParseError(Exception)
    #     """Error during parsing"""
    #     def __init__(self, message: str, line: int, column: int):
    self.message = message
    self.line = line
    self.column = column
            super().__init__(f"Parse error at line {line}, column {column}: {message}")


dataclass
class Token
    #     """Represents a token in the Noodle language"""
    #     type: str
    #     value: str
    #     line: int
    #     column: int


class Lexer
    #     """Lexical analyzer for Noodle source code"""

    #     # Token patterns
    TOKEN_PATTERNS = [
            ('NUMBER', r'\d+(\.\d+)?'),  # Integer or float
            ('STRING', r'"[^"]*"'),      # String literal
            ('IDENTIFIER', r'[a-zA-Z_]\w*'),  # Variable or function name
            ('OP', r'[\+\-\*/\%]'),      # Arithmetic operators
    ('COMPARE', r'[<>] = ?|==|!='),  # Comparison operators
            ('LOGICAL', r'&&|\|\||!'),   # Logical operators
    ('ASSIGN', r' = '),            # Assignment
            ('LPAREN', r'\('),           # Left parenthesis
            ('RPAREN', r'\)'),           # Right parenthesis
            ('LBRACKET', r'\['),         # Left bracket
            ('RBRACKET', r'\]'),         # Right bracket
            ('LBRACE', r'\{'),           # Left brace
            ('RBRACE', r'\}'),           # Right brace
            ('COMMA', r','),             # Comma
            ('SEMICOLON', r';'),         # Semicolon
            ('WHITESPACE', r'\s+'),      # Whitespace
            ('COMMENT', r'//.*'),        # Comment
            ('NEWLINE', r'\n'),          # Newline
            ('UNKNOWN', r'.'),           # Unknown character
    #     ]

    #     def __init__(self):
    #         # Compile regex patterns
    #         self.patterns = [(name, re.compile(pattern)) for name, pattern in self.TOKEN_PATTERNS]

    #     def tokenize(self, source: str) -List[Token]):
    #         """Tokenize the source code"""
    tokens = []
    line = 1
    column = 1
    i = 0

    #         while i < len(source):
    match = None

    #             # Try each pattern
    #             for name, pattern in self.patterns:
    match = pattern.match(source, i)
    #                 if match:
    value = match.group(0)

    #                     # Skip whitespace and comments
    #                     if name not in ['WHITESPACE', 'COMMENT']:
                            tokens.append(Token(name, value, line, column))

    #                     # Update line and column
    #                     if name == 'NEWLINE':
    line + = 1
    column = 1
    #                     else:
    column + = len(value)

    #                     break

    #             if not match:
    #                 # Unknown character
                    tokens.append(Token('UNKNOWN', source[i], line, column))
    column + = 1
    i + = 1
    #             else:
    i = match.end()

    #         return tokens


class SimpleParser
    #     """Simple parser for Noodle source code"""

    #     def __init__(self):
    self.lexer = Lexer()
    self.tokens = []
    self.current = 0
    self.variables = {}  # Map variable names to indices
    self.next_var_index = 0
    self.functions = {}  # Map function names to their bytecode
    self.current_function = "main"
    self.instructions = []  # Current function instructions
    self.labels = {}  # Map label names to instruction indices
    self.pending_jumps = []  # Jumps that need to be resolved

    #     def parse(self, source: str) -Dict[str, List[Instruction]]):
    #         """Parse source code and return bytecode"""
    self.tokens = self.lexer.tokenize(source)
    self.current = 0
    self.variables = {}
    self.next_var_index = 0
    self.functions = {}
    self.current_function = "main"
    self.instructions = []
    self.labels = {}
    self.pending_jumps = []

    #         # Parse the program
            self._parse_program()

    #         # Resolve pending jumps
            self._resolve_jumps()

    #         return self.functions

    #     def _parse_program(self):
    #         """Parse the entire program"""
    #         # Start with main function
    self.functions["main"] = []
    self.instructions = self.functions["main"]

    #         while not self._is_at_end():
                self._parse_statement()

    #         # Add halt instruction at the end
            self.instructions.append(Instruction(OpCode.HALT))

    #     def _parse_statement(self):
    #         """Parse a statement"""
    #         if self._match('PRINT'):
                self._parse_print_statement()
    #         elif self._match('IDENTIFIER'):
    #             # Could be variable assignment or function call
    name = self._previous().value

    #             if self._match('ASSIGN'):
                    self._parse_assignment_statement(name)
    #             else:
                    raise ParseError(f"Unexpected token after identifier '{name}'",
                                    self._peek().line, self._peek().column)
    #         elif self._match('IF'):
                self._parse_if_statement()
    #         elif self._match('WHILE'):
                self._parse_while_statement()
    #         elif self._match('LBRACE'):
                self._parse_block()
    #         else:
    #             # Try to parse as expression
                self._parse_expression()
    #             # Pop the result if not used
                self.instructions.append(Instruction(OpCode.POP))

    #     def _parse_print_statement(self):
    #         """Parse a print statement"""
    #         if not self._match('LPAREN'):
                raise ParseError("Expected '(' after print", self._peek().line, self._peek().column)

    #         # Parse expression
            self._parse_expression()

    #         if not self._match('RPAREN'):
                raise ParseError("Expected ')' after print argument", self._peek().line, self._peek().column)

    #         # Add print instruction
            self.instructions.append(Instruction(OpCode.PRINT))

    #     def _parse_assignment_statement(self, var_name: str):
    #         """Parse an assignment statement"""
    #         # Get or allocate variable index
    #         if var_name not in self.variables:
    self.variables[var_name] = self.next_var_index
    self.next_var_index + = 1

    var_index = self.variables[var_name]

    #         # Parse expression
            self._parse_expression()

    #         # Add store instruction
            self.instructions.append(Instruction(OpCode.STORE, [var_index]))

    #     def _parse_if_statement(self):
    #         """Parse an if statement"""
    #         if not self._match('LPAREN'):
                raise ParseError("Expected '(' after if", self._peek().line, self._peek().column)

    #         # Parse condition
            self._parse_expression()

    #         if not self._match('RPAREN'):
    #             raise ParseError("Expected ')' after if condition", self._peek().line, self._peek().column)

    #         # Create labels
    else_label = self._create_label()
    end_label = self._create_label()

    #         # Add jump if false
            self._add_jump(OpCode.JZ, else_label)

    #         # Parse then branch
            self._parse_statement()

    #         # Add jump to end
            self._add_jump(OpCode.JMP, end_label)

    #         # Add else label
            self._add_label(else_label)

    #         # Parse else branch if present
    #         if self._match('ELSE'):
                self._parse_statement()

    #         # Add end label
            self._add_label(end_label)

    #     def _parse_while_statement(self):
    #         """Parse a while statement"""
    #         if not self._match('LPAREN'):
                raise ParseError("Expected '(' after while", self._peek().line, self._peek().column)

    #         # Create labels
    start_label = self._create_label()
    end_label = self._create_label()

    #         # Add start label
            self._add_label(start_label)

    #         # Parse condition
            self._parse_expression()

    #         if not self._match('RPAREN'):
    #             raise ParseError("Expected ')' after while condition", self._peek().line, self._peek().column)

    #         # Add jump if false
            self._add_jump(OpCode.JZ, end_label)

    #         # Parse body
            self._parse_statement()

    #         # Add jump back to start
            self._add_jump(OpCode.JMP, start_label)

    #         # Add end label
            self._add_label(end_label)

    #     def _parse_block(self):
    #         """Parse a block of statements"""
    #         while not self._check('RBRACE') and not self._is_at_end():
                self._parse_statement()

    #         if not self._match('RBRACE'):
                raise ParseError("Expected '}' after block", self._peek().line, self._peek().column)

    #     def _parse_expression(self):
    #         """Parse an expression"""
            self._parse_logical_or()

    #     def _parse_logical_or(self):
    #         """Parse logical OR expression"""
            self._parse_logical_and()

    #         while self._match('LOGICAL') and self._previous().value in ['||', 'or']:
    operator = self._previous().value
                self._parse_logical_and()

    #             if operator in ['||', 'or']:
                    self.instructions.append(Instruction(OpCode.OR))

    #     def _parse_logical_and(self):
    #         """Parse logical AND expression"""
            self._parse_equality()

    #         while self._match('LOGICAL') and self._previous().value in ['&&', 'and']:
    operator = self._previous().value
                self._parse_equality()

    #             if operator in ['&&', 'and']:
                    self.instructions.append(Instruction(OpCode.AND))

    #     def _parse_equality(self):
    #         """Parse equality expression"""
            self._parse_comparison()

    #         while self._match('COMPARE') and self._previous().value in ['==', '!=']:
    operator = self._previous().value
                self._parse_comparison()

    #             if operator == '==':
                    self.instructions.append(Instruction(OpCode.EQ))
    #             elif operator == '!=':
                    self.instructions.append(Instruction(OpCode.NE))

    #     def _parse_comparison(self):
    #         """Parse comparison expression"""
            self._parse_term()

    #         while self._match('COMPARE') and self._previous().value in ['<', '<=', '>', '>=']:
    operator = self._previous().value
                self._parse_term()

    #             if operator == '<':
                    self.instructions.append(Instruction(OpCode.LT))
    #             elif operator == '<=':
                    self.instructions.append(Instruction(OpCode.LE))
    #             elif operator == '>':
                    self.instructions.append(Instruction(OpCode.GT))
    #             elif operator == '>=':
                    self.instructions.append(Instruction(OpCode.GE))

    #     def _parse_term(self):
    #         """Parse term expression"""
            self._parse_factor()

    #         while self._match('OP') and self._previous().value in ['+', '-']:
    operator = self._previous().value
                self._parse_factor()

    #             if operator == '+':
                    self.instructions.append(Instruction(OpCode.ADD))
    #             elif operator == '-':
                    self.instructions.append(Instruction(OpCode.SUB))

    #     def _parse_factor(self):
    #         """Parse factor expression"""
            self._parse_unary()

    #         while self._match('OP') and self._previous().value in ['*', '/', '%']:
    operator = self._previous().value
                self._parse_unary()

    #             if operator == '*':
                    self.instructions.append(Instruction(OpCode.MUL))
    #             elif operator == '/':
                    self.instructions.append(Instruction(OpCode.DIV))
    #             elif operator == '%':
                    self.instructions.append(Instruction(OpCode.MOD))

    #     def _parse_unary(self):
    #         """Parse unary expression"""
    #         if self._match('OP') and self._previous().value == '-':
                self._parse_unary()
                self.instructions.append(Instruction(OpCode.NEG))
    #         elif self._match('LOGICAL') and self._previous().value in ['!', 'not']:
                self._parse_unary()
                self.instructions.append(Instruction(OpCode.NOT))
    #         else:
                self._parse_primary()

    #     def _parse_primary(self):
    #         """Parse primary expression"""
    #         if self._match('NUMBER'):
    value = self._previous().value
    #             if '.' in value:
                    self.instructions.append(Instruction(OpCode.PUSH, [float(value)]))
    #             else:
                    self.instructions.append(Instruction(OpCode.PUSH, [int(value)]))
    #         elif self._match('STRING'):
    value = self._previous().value[1: - 1]  # Remove quotes
                self.instructions.append(Instruction(OpCode.PUSH, [value]))
    #         elif self._match('IDENTIFIER'):
    var_name = self._previous().value

    #             # Check if it's a variable
    #             if var_name in self.variables:
    var_index = self.variables[var_name]
                    self.instructions.append(Instruction(OpCode.LOAD, [var_index]))
    #             else:
                    raise ParseError(f"Undefined variable: {var_name}",
                                    self._previous().line, self._previous().column)
    #         elif self._match('LPAREN'):
                self._parse_expression()
    #             if not self._match('RPAREN'):
                    raise ParseError("Expected ')' after expression", self._peek().line, self._peek().column)
    #         elif self._match('LBRACKET'):
                self._parse_array_literal()
    #         else:
                raise ParseError(f"Unexpected token: {self._peek().value}",
                                self._peek().line, self._peek().column)

    #     def _parse_array_literal(self):
    #         """Parse array literal"""
    #         # Create empty array
            self.instructions.append(Instruction(OpCode.ARRAY_NEW))

    #         # Parse elements if any
    #         if not self._check('RBRACKET'):
                self._parse_expression()
                self.instructions.append(Instruction(OpCode.ARRAY_PUSH))

    #             while self._match('COMMA'):
                    self._parse_expression()
                    self.instructions.append(Instruction(OpCode.ARRAY_PUSH))

    #         if not self._match('RBRACKET'):
                raise ParseError("Expected ']' after array elements", self._peek().line, self._peek().column)

    #     def _create_label(self) -str):
    #         """Create a new label"""
            return f"label_{len(self.labels)}"

    #     def _add_label(self, label: str):
    #         """Add a label at the current position"""
    self.labels[label] = len(self.instructions)

    #         # Check if there are pending jumps to this label
    #         for i, (opcode, target_label, instruction_index) in enumerate(self.pending_jumps):
    #             if target_label == label:
    #                 # Update the jump instruction with the actual target
    self.instructions[instruction_index].operands[0] = self.labels[label]
    #                 # Remove from pending jumps
                    self.pending_jumps.pop(i)
    #                 break

    #     def _add_jump(self, opcode: OpCode, label: str):
    #         """Add a jump instruction with a label to be resolved later"""
    instruction_index = len(self.instructions)
            self.instructions.append(Instruction(opcode, [0]))  # Placeholder target
            self.pending_jumps.append((opcode, label, instruction_index))

    #     def _resolve_jumps(self):
    #         """Resolve all pending jumps"""
    #         for opcode, label, instruction_index in self.pending_jumps:
    #             if label in self.labels:
    self.instructions[instruction_index].operands[0] = self.labels[label]
    #             else:
                    raise ParseError(f"Undefined label: {label}", 0, 0)

    #     def _match(self, token_type: str) -bool):
    #         """Check if current token matches the given type and advance"""
    #         if self._check(token_type):
                self._advance()
    #             return True
    #         return False

    #     def _check(self, token_type: str) -bool):
    #         """Check if current token matches the given type"""
    #         if self._is_at_end():
    #             return False
    return self._peek().type == token_type

    #     def _advance(self) -Token):
    #         """Advance to the next token"""
    #         if not self._is_at_end():
    self.current + = 1
            return self._previous()

    #     def _is_at_end(self) -bool):
    #         """Check if at end of tokens"""
    return self.current = len(self.tokens) or self.tokens[self.current].type == 'EOF'

    #     def _peek(self):
    """Token)"""
    #         """Get current token"""
    #         return self.tokens[self.current]

    #     def _previous(self) -Token):
    #         """Get previous token"""
    #         return self.tokens[self.current - 1]


# ====== Test Functions ======

function test_basic_interpreter()
    #     """Test the basic interpreter with manually created bytecode"""
        print("Testing Basic Interpreter")
    print(" = " * 30)

    #     try:
    #         # Create a simple program that prints "Hello, World!"
    instructions = [
    #             # Push "Hello, World!" to stack
                Instruction(OpCode.PUSH, ["Hello, World!"]),
    #             # Print the value
                Instruction(OpCode.PRINT, []),
    #             # Halt
                Instruction(OpCode.HALT, [])
    #         ]

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=True)
            interpreter.load_bytecode({"main": instructions})
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Basic interpreter test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in basic interpreter test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_parser()
    #     """Test the parser with a simple program"""
        print("\nTesting Parser")
    print(" = " * 30)

    #     try:
    #         # Simple Noodle program
    source = """
            print("Hello from parser!");
    x = 10;
    y = 20;
    z = x + y;
            print("The sum is:");
            print(z);
    #         """

    #         # Parse the source
    parser = SimpleParser()
    functions = parser.parse(source)

            print(f"Parsed {len(functions)} functions")
    #         for name, instructions in functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode(functions)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Parser test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in parser test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_file_parsing()
    #     """Test parsing a file"""
        print("\nTesting File Parsing")
    print(" = " * 30)

    #     try:
    #         # Check if the example file exists
    #         if not os.path.exists("examples/hello_world.noodle"):
                print("Example file not found, skipping file parsing test")
    #             return True

    #         # Read the file
    #         with open("examples/hello_world.noodle", "r") as f:
    source = f.read()

    #         # Parse the source
    parser = SimpleParser()
    functions = parser.parse(source)

            print(f"Parsed {len(functions)} functions")
    #         for name, instructions in functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode(functions)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("File parsing test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in file parsing test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_control_flow()
    #     """Test control flow statements"""
        print("\nTesting Control Flow")
    print(" = " * 30)

    #     try:
    #         # Noodle program with control flow
    source = """
    x = 10;
    #         if (x 5) {
                print("x is greater than 5");
    #         } else {
                print("x is not greater than 5");
    #         }

    i = 0;
    #         while (i < 3) {
                print("Loop iteration):");
                print(i);
    i = i + 1;
    #         }
    #         """

    #         # Parse the source
    parser = SimpleParser()
    functions = parser.parse(source)

            print(f"Parsed {len(functions)} functions")
    #         for name, instructions in functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode(functions)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Control flow test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in control flow test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_arrays()
    #     """Test array operations"""
        print("\nTesting Arrays")
    print(" = " * 30)

    #     try:
    #         # Noodle program with arrays
    source = """
    arr = [1, 2, 3];
            print("Array elements:");
    i = 0;
    #         while (i < 3) {
                print(arr[i]);
    i = i + 1;
    #         }
    #         """

    #         # Parse the source
    parser = SimpleParser()
    functions = parser.parse(source)

            print(f"Parsed {len(functions)} functions")
    #         for name, instructions in functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode(functions)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Arrays test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in arrays test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_matrices()
    #     """Test matrix operations"""
        print("\nTesting Matrices")
    print(" = " * 30)

    #     try:
    #         # Noodle program with matrices
    source = """
    mat1 = [[1, 2], [3, 4]];
    mat2 = [[5, 6], [7, 8]];
    mat3 = mat1 + mat2;
            print("Matrix addition result:");
            print(mat3[0][0]);
            print(mat3[0][1]);
            print(mat3[1][0]);
            print(mat3[1][1]);
    #         """

    #         # Parse the source
    parser = SimpleParser()
    functions = parser.parse(source)

            print(f"Parsed {len(functions)} functions")
    #         for name, instructions in functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode(functions)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Matrices test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in matrices test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

if __name__ == "__main__"
    #     # Change to the noodle-core directory
        os.chdir(os.path.dirname(os.path.abspath(__file__)))

    #     # Run tests
    success1 = test_basic_interpreter()
    success2 = test_parser()
    success3 = test_file_parsing()
    success4 = test_control_flow()
    success5 = test_arrays()
    success6 = test_matrices()

    #     # Print final result
        print("\n\nTest Summary")
    print(" = " * 30)
    #     if success1 and success2 and success3 and success4 and success5 and success6:
            print("All tests passed successfully!")
            print("\nNative NoodleCore Runtime Demonstration Complete!")
            print("This proves that NoodleCore works independently of Python wrappers.")
            sys.exit(0)
    #     else:
            print("Some tests failed!")
            sys.exit(1)