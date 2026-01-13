# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Native NoodleCore Bytecode Interpreter
# -------------------------------------

# This module implements the native NoodleCore bytecode interpreter.
# It executes NoodleCore bytecode independently of Python, providing
# a true native runtime for the Noodle language.
# """

import sys
import traceback
import dataclasses.dataclass,
import typing.Any,

import .noodle_bytecode.(
#     OpCode, Value, ValueType, Instruction, BytecodeFile,
#     null_value, boolean_value, integer_value, float_value,
#     string_value, array_value, matrix_value
# )


class NoodleRuntimeError(Exception)
    #     """Runtime error in NoodleCore execution"""
    #     def __init__(self, message: str, instruction: Optional[Instruction] = None):
    self.message = message
    self.instruction = instruction
            super().__init__(message)


# @dataclass
class CallFrame
    #     """Represents a function call frame"""

    #     function_name: str
    #     return_address: int
    local_variables: Dict[str, Value] = field(default_factory=dict)
    stack_base: int = 0


class NoodleCoreInterpreter
    #     """Native NoodleCore bytecode interpreter"""

    #     def __init__(self, debug: bool = False):
    #         """Initialize the interpreter"""
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

    #     def load_bytecode(self, bytecode: BytecodeFile):
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
    self.functions = bytecode.functions

    #     def execute_function(self, function_name: str) -> Value:
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
    #             elif instruction.opcode == OpCode.DUP:
                    self._execute_dup(instruction)
    #             elif instruction.opcode == OpCode.SWAP:
                    self._execute_swap(instruction)
    #             elif instruction.opcode == OpCode.ADD:
                    self._execute_add(instruction)
    #             elif instruction.opcode == OpCode.SUB:
                    self._execute_sub(instruction)
    #             elif instruction.opcode == OpCode.MUL:
                    self._execute_mul(instruction)
    #             elif instruction.opcode == OpCode.DIV:
                    self._execute_div(instruction)
    #             elif instruction.opcode == OpCode.MOD:
                    self._execute_mod(instruction)
    #             elif instruction.opcode == OpCode.POW:
                    self._execute_pow(instruction)
    #             elif instruction.opcode == OpCode.NEG:
                    self._execute_neg(instruction)
    #             elif instruction.opcode == OpCode.EQ:
                    self._execute_eq(instruction)
    #             elif instruction.opcode == OpCode.NE:
                    self._execute_ne(instruction)
    #             elif instruction.opcode == OpCode.LT:
                    self._execute_lt(instruction)
    #             elif instruction.opcode == OpCode.LE:
                    self._execute_le(instruction)
    #             elif instruction.opcode == OpCode.GT:
                    self._execute_gt(instruction)
    #             elif instruction.opcode == OpCode.GE:
                    self._execute_ge(instruction)
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
    #             elif instruction.opcode == OpCode.CALL:
                    self._execute_call(instruction)
    #             elif instruction.opcode == OpCode.RET:
                    self._execute_ret(instruction)
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

    #     def _execute_dup(self, instruction: Instruction):
    #         """Execute DUP instruction"""
    #         if self.stack:
                self.stack.append(self.stack[-1])

    #     def _execute_swap(self, instruction: Instruction):
    #         """Execute SWAP instruction"""
    #         if len(self.stack) >= 2:
    self.stack[-1], self.stack[-2] = math.subtract(self.stack[, 2], self.stack[-1])

    #     def _execute_add(self, instruction: Instruction):
    #         """Execute ADD instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in ADD")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = math.add(integer_value(a.as_integer(), b.as_integer()))
    #         elif a.is_float() or b.is_float():
    result = math.add(float_value(a.as_float(), b.as_float()))
    #         elif a.is_string() and b.is_string():
    result = math.add(string_value(a.as_string(), b.as_string()))
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
    result = math.subtract(integer_value(a.as_integer(), b.as_integer()))
    #         elif a.is_float() or b.is_float():
    result = math.subtract(float_value(a.as_float(), b.as_float()))
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
    result = math.multiply(integer_value(a.as_integer(), b.as_integer()))
    #         elif a.is_float() or b.is_float():
    result = math.multiply(float_value(a.as_float(), b.as_float()))
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

    #     def _execute_mod(self, instruction: Instruction):
    #         """Execute MOD instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in MOD")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if b.is_integer() and b.as_integer() == 0:
                raise NoodleRuntimeError("Modulo by zero")

    #         if a.is_integer() and b.is_integer():
    result = integer_value(a.as_integer() % b.as_integer())
    #         else:
                raise NoodleRuntimeError(f"Cannot compute modulo of {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_pow(self, instruction: Instruction):
    #         """Execute POW instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in POW")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = math.multiply(integer_value(a.as_integer(), * b.as_integer()))
    #         elif a.is_float() or b.is_float():
    result = math.multiply(float_value(a.as_float(), * b.as_float()))
    #         else:
                raise NoodleRuntimeError(f"Cannot compute power of {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_neg(self, instruction: Instruction):
    #         """Execute NEG instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in NEG")

    a = self.stack.pop()

    #         if a.is_integer():
    result = math.subtract(integer_value(, a.as_integer()))
    #         elif a.is_float():
    result = math.subtract(float_value(, a.as_float()))
    #         else:
                raise NoodleRuntimeError(f"Cannot negate {a.type}")

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

    #     def _execute_le(self, instruction: Instruction):
    #         """Execute LE instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in LE")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = boolean_value(a.as_integer() <= b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = boolean_value(a.as_float() <= b.as_float())
    #         elif a.is_string() and b.is_string():
    result = boolean_value(a.as_string() <= b.as_string())
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
    result = boolean_value(a.as_integer() > b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = boolean_value(a.as_float() > b.as_float())
    #         elif a.is_string() and b.is_string():
    result = boolean_value(a.as_string() > b.as_string())
    #         else:
                raise NoodleRuntimeError(f"Cannot compare {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_ge(self, instruction: Instruction):
    #         """Execute GE instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in GE")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.is_integer() and b.is_integer():
    result = boolean_value(a.as_integer() >= b.as_integer())
    #         elif a.is_float() or b.is_float():
    result = boolean_value(a.as_float() >= b.as_float())
    #         elif a.is_string() and b.is_string():
    result = boolean_value(a.as_string() >= b.as_string())
    #         else:
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
    self.pc = math.subtract(target, 1  # -1 because pc will be incremented)

    #     def _execute_jz(self, instruction: Instruction):
    #         """Execute JZ instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in JZ")

    condition = self.stack.pop()
    #         if not condition.as_boolean():
    target = instruction.operands[0]
    #             if target < 0 or target >= len(self.current_instructions):
                    raise NoodleRuntimeError(f"Invalid jump target: {target}")
    self.pc = math.subtract(target, 1  # -1 because pc will be incremented)

    #     def _execute_jnz(self, instruction: Instruction):
    #         """Execute JNZ instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in JNZ")

    condition = self.stack.pop()
    #         if condition.as_boolean():
    target = instruction.operands[0]
    #             if target < 0 or target >= len(self.current_instructions):
                    raise NoodleRuntimeError(f"Invalid jump target: {target}")
    self.pc = math.subtract(target, 1  # -1 because pc will be incremented)

    #     def _execute_call(self, instruction: Instruction):
    #         """Execute CALL instruction"""
    function_name = instruction.operands[0]

    #         if function_name not in self.functions:
                raise NoodleRuntimeError(f"Function '{function_name}' not found")

    #         # Create new call frame
            self.call_stack.append(CallFrame(
    function_name = function_name,
    return_address = math.add(self.pc, 1,  # Return to next instruction)
    stack_base = len(self.stack)
    #         ))

    #         # Switch to new function
    self.current_function = function_name
    self.current_instructions = self.functions[function_name]
    self.pc = math.subtract(, 1  # Will be incremented to 0)

    #     def _execute_ret(self, instruction: Instruction):
    #         """Execute RET instruction"""
    #         if not self.call_stack:
                raise NoodleRuntimeError("Return from empty call stack")

    #         # Get return value
    #         return_value = self.stack.pop() if self.stack else null_value()

    #         # Pop current call frame
    current_frame = self.call_stack.pop()

    #         # Restore stack to base level
    #         while len(self.stack) > current_frame.stack_base:
                self.stack.pop()

    #         # Push return value
            self.stack.append(return_value)

    #         # Return to caller
    #         if self.call_stack:
    caller_frame = math.subtract(self.call_stack[, 1])
    self.current_function = caller_frame.function_name
    self.current_instructions = self.functions[self.current_function]
    self.pc = math.subtract(caller_frame.return_address, 1  # -1 because pc will be incremented)
    #         else:
    #             # End of program
    self.halted = True

    #     def _execute_load(self, instruction: Instruction):
    #         """Execute LOAD instruction"""
    var_index = instruction.operands[0]

    #         # Get variable name from index
    var_name = f"var_{var_index}"

    #         # Check local variables first
    #         if self.call_stack and var_name in self.call_stack[-1].local_variables:
    value = math.subtract(self.call_stack[, 1].local_variables[var_name])
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
    #         a_cols = len(a.data[0]) if a_rows > 0 else 0
    b_rows = len(b.data)
    #         b_cols = len(b.data[0]) if b_rows > 0 else 0

    #         if a_rows != b_rows or a_cols != b_cols:
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
    #         a_cols = len(a.data[0]) if a_rows > 0 else 0
    b_rows = len(b.data)
    #         b_cols = len(b.data[0]) if b_rows > 0 else 0

    #         if a_rows != b_rows or a_cols != b_cols:
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
    #         a_cols = len(a.data[0]) if a_rows > 0 else 0
    b_rows = len(b.data)
    #         b_cols = len(b.data[0]) if b_rows > 0 else 0

    #         if a_cols != b_rows:
    #             raise NoodleRuntimeError("Matrix dimensions must be compatible for multiplication")

    result = []
    #         for i in range(a_rows):
    row = []
    #             for j in range(b_cols):
    sum_val = 0
    #                 for k in range(a_cols):
    #                     if a.data[i][k].is_integer() and b.data[k][j].is_integer():
    sum_val + = math.multiply(a.data[i][k].as_integer(), b.data[k][j].as_integer())
    #                     elif a.data[i][k].is_float() or b.data[k][j].is_float():
    sum_val + = math.multiply(a.data[i][k].as_float(), b.data[k][j].as_float())
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

    #     def get_output(self) -> List[str]:
    #         """Get the output buffer"""
            return self.output_buffer.copy()

    #     def clear_output(self):
    #         """Clear the output buffer"""
            self.output_buffer.clear()

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get execution statistics"""
    #         return {
    #             "instruction_count": self.instruction_count,
    #             "max_stack_depth": self.max_stack_depth,
                "current_stack_depth": len(self.stack),
    #             "functions_called": len(set(f.function_name for f in self.call_stack)),
                "global_variables": len(self.global_variables),
    #             "halted": self.halted
    #         }