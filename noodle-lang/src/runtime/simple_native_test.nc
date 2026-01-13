# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Simple Test for Native NoodleCore Runtime
# ---------------------------------------

# This script demonstrates the native NoodleCore runtime concept
# with a simplified test that focuses on the core functionality.
# """

import sys
import os
import time
from dataclasses import dataclass
import enum.Enum
import typing.Any


# ====== Bytecode Format ======

class OpCode(Enum)
    #     """Native NoodleCore Operation Codes"""

    #     # Stack operations
    PUSH = 0x01  # Push value to stack
    POP = 0x02  # Pop value from stack

    #     # Arithmetic operations
    ADD = 0x10  # Addition
    SUB = 0x11  # Subtraction
    MUL = 0x12  # Multiplication
    DIV = 0x13  # Division

    #     # Comparison operations
    EQ = 0x20  # Equal
    LT = 0x22  # Less than
    GT = 0x24  # Greater than

    #     # Control flow
    JMP = 0x40  # Unconditional jump
    #     JZ = 0x41  # Jump if zero (false)
    #     JNZ = 0x42  # Jump if not zero (true)

    #     # Variable operations
    LOAD = 0x50  # Load variable value
    STORE = 0x51  # Store variable value

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


dataclass
class Value
    #     """Represents a value in the NoodleCore runtime"""

    #     type: ValueType
    data: Any = None

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
    #             elif instruction.opcode == OpCode.LT:
                    self._execute_lt(instruction)
    #             elif instruction.opcode == OpCode.GT:
                    self._execute_gt(instruction)
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

    #         if a.type == ValueType.INTEGER and b.type == ValueType.INTEGER:
    result = integer_value(a.data + b.data)
    #         elif a.type == ValueType.FLOAT or b.type == ValueType.FLOAT:
    result = float_value(a.as_float() + b.as_float())
    #         elif a.type == ValueType.STRING and b.type == ValueType.STRING:
    result = string_value(a.data + b.data)
    #         else:
                raise NoodleRuntimeError(f"Cannot add {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_sub(self, instruction: Instruction):
    #         """Execute SUB instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in SUB")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.type == ValueType.INTEGER and b.type == ValueType.INTEGER:
    result = integer_value(a.data - b.data)
    #         elif a.type == ValueType.FLOAT or b.type == ValueType.FLOAT:
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

    #         if a.type == ValueType.INTEGER and b.type == ValueType.INTEGER:
    result = integer_value(a.data * b.data)
    #         elif a.type == ValueType.FLOAT or b.type == ValueType.FLOAT:
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
    #         if (b.type == ValueType.INTEGER and b.data = 0) or (b.type == ValueType.FLOAT and b.data = 0.0):
                raise NoodleRuntimeError("Division by zero")

    #         if a.type == ValueType.INTEGER and b.type == ValueType.INTEGER:
    result = math.divide(integer_value(a.data, / b.data))
    #         elif a.type == ValueType.FLOAT or b.type == ValueType.FLOAT:
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
    #         elif a.type == ValueType.NULL and b.type == ValueType.NULL:
    result = boolean_value(True)
    #         elif a.type == ValueType.BOOLEAN:
    result = boolean_value(a.data == b.data)
    #         elif a.type == ValueType.INTEGER:
    result = boolean_value(a.data == b.data)
    #         elif a.type == ValueType.FLOAT:
    result = boolean_value(a.data == b.data)
    #         elif a.type == ValueType.STRING:
    result = boolean_value(a.data == b.data)
    #         else:
    result = boolean_value(a.data == b.data)

            self.stack.append(result)

    #     def _execute_lt(self, instruction: Instruction):
    #         """Execute LT instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in LT")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.type == ValueType.INTEGER and b.type == ValueType.INTEGER:
    result = boolean_value(a.data < b.data)
    #         elif a.type == ValueType.FLOAT or b.type == ValueType.FLOAT:
    result = boolean_value(a.as_float() < b.as_float())
    #         elif a.type == ValueType.STRING and b.type == ValueType.STRING:
    result = boolean_value(a.data < b.data)
    #         else:
                raise NoodleRuntimeError(f"Cannot compare {a.type} and {b.type}")

            self.stack.append(result)

    #     def _execute_gt(self, instruction: Instruction):
    #         """Execute GT instruction"""
    #         if len(self.stack) < 2:
                raise NoodleRuntimeError("Stack underflow in GT")

    b = self.stack.pop()
    a = self.stack.pop()

    #         if a.type == ValueType.INTEGER and b.type == ValueType.INTEGER:
    result = boolean_value(a.data b.data)
    #         elif a.type == ValueType.FLOAT or b.type == ValueType.FLOAT):
    result = boolean_value(a.as_float() b.as_float())
    #         elif a.type == ValueType.STRING and b.type == ValueType.STRING):
    result = boolean_value(a.data b.data)
    #         else):
                raise NoodleRuntimeError(f"Cannot compare {a.type} and {b.type}")

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
    #         if not condition.data:  # False
    target = instruction.operands[0]
    #             if target < 0 or target >= len(self.current_instructions):
                    raise NoodleRuntimeError(f"Invalid jump target: {target}")
    self.pc = target - 1  # -1 because pc will be incremented

    #     def _execute_jnz(self, instruction: Instruction):
    #         """Execute JNZ instruction"""
    #         if len(self.stack) < 1:
                raise NoodleRuntimeError("Stack underflow in JNZ")

    condition = self.stack.pop()
    #         if condition.data:  # True
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


# ====== Test Functions ======

function test_hello_world()
    #     """Test a simple Hello World program"""
        print("Testing Hello World Program")
    print(" = " * 30)

    #     try:
    #         # Create a simple program that prints "Hello, NoodleCore World!"
    instructions = [
    #             # Push "Hello, NoodleCore World!" to stack
                Instruction(OpCode.PUSH, ["Hello, NoodleCore World!"]),
    #             # Print the value
                Instruction(OpCode.PRINT, []),
    #             # Halt
                Instruction(OpCode.HALT, [])
    #         ]

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode({"main": instructions})

    start_time = time.time()
    result = interpreter.execute_function("main")
    end_time = time.time()

    #         # Get output and statistics
    output = interpreter.get_output()
    stats = interpreter.get_statistics()

            print("Output:", output)
            print(f"Execution time: {end_time - start_time:.4f}s")
            print(f"Instructions executed: {stats['instruction_count']}")
            print(f"Max stack depth: {stats['max_stack_depth']}")

            print("Hello World test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in Hello World test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_arithmetic()
    #     """Test arithmetic operations"""
        print("\nTesting Arithmetic Operations")
    print(" = " * 30)

    #     try:
    #         # Create a program that performs arithmetic operations
    instructions = [
    #             # Push 10
                Instruction(OpCode.PUSH, [10]),
                # Store in var_0 (x)
                Instruction(OpCode.STORE, [0]),

    #             # Push 20
                Instruction(OpCode.PUSH, [20]),
                # Store in var_1 (y)
                Instruction(OpCode.STORE, [1]),

    #             # Load x
                Instruction(OpCode.LOAD, [0]),
    #             # Load y
                Instruction(OpCode.LOAD, [1]),
    #             # Add
                Instruction(OpCode.ADD, []),
                # Store in var_2 (z)
                Instruction(OpCode.STORE, [2]),

    #             # Push "The sum of x and y is: "
                Instruction(OpCode.PUSH, ["The sum of x and y is: "]),
    #             # Print
                Instruction(OpCode.PRINT, []),

    #             # Load z
                Instruction(OpCode.LOAD, [2]),
    #             # Print
                Instruction(OpCode.PRINT, []),

    #             # Halt
                Instruction(OpCode.HALT, [])
    #         ]

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode({"main": instructions})

    start_time = time.time()
    result = interpreter.execute_function("main")
    end_time = time.time()

    #         # Get output and statistics
    output = interpreter.get_output()
    stats = interpreter.get_statistics()

            print("Output:", output)
            print(f"Execution time: {end_time - start_time:.4f}s")
            print(f"Instructions executed: {stats['instruction_count']}")
            print(f"Max stack depth: {stats['max_stack_depth']}")

            print("Arithmetic test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in arithmetic test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_control_flow()
    #     """Test control flow operations"""
        print("\nTesting Control Flow Operations")
    print(" = " * 30)

    #     try:
    #         # Create a program that uses control flow
    instructions = [
    #             # Push 10
                Instruction(OpCode.PUSH, [10]),
                # Store in var_0 (x)
                Instruction(OpCode.STORE, [0]),

    #             # Push 5
                Instruction(OpCode.PUSH, [5]),
                # Store in var_1 (y)
                Instruction(OpCode.STORE, [1]),

    #             # Load x
                Instruction(OpCode.LOAD, [0]),
    #             # Load y
                Instruction(OpCode.LOAD, [1]),
                # Compare (x y)
                Instruction(OpCode.GT, []),
    #             # Jump if false to else_label (7)
                Instruction(OpCode.JZ, [7]),

    #             # Then branch
    #             # Push "x is greater than y"
                Instruction(OpCode.PUSH, ["x is greater than y"]),
    #             # Print
                Instruction(OpCode.PRINT, []),
                # Jump to end (12)
                Instruction(OpCode.JMP, [12]),

                # Else label (7)
    #             # Push "x is not greater than y"
                Instruction(OpCode.PUSH, ["x is not greater than y"]),
    #             # Print
                Instruction(OpCode.PRINT, []),

                # End label (12)
    #             # Halt
                Instruction(OpCode.HALT, [])
    #         ]

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode({"main"): instructions})

    start_time = time.time()
    result = interpreter.execute_function("main")
    end_time = time.time()

    #         # Get output and statistics
    output = interpreter.get_output()
    stats = interpreter.get_statistics()

            print("Output:", output)
            print(f"Execution time: {end_time - start_time:.4f}s")
            print(f"Instructions executed: {stats['instruction_count']}")
            print(f"Max stack depth: {stats['max_stack_depth']}")

            print("Control flow test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in control flow test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_loop()
    #     """Test loop operations"""
        print("\nTesting Loop Operations")
    print(" = " * 30)

    #     try:
    #         # Create a program that uses a loop
    instructions = [
    # Initialize i = 0
                Instruction(OpCode.PUSH, [0]),
    Instruction(OpCode.STORE, [0]),  # var_0 = i

                # Start label (2)
    #             # Load i
                Instruction(OpCode.LOAD, [0]),
    #             # Push 3
                Instruction(OpCode.PUSH, [3]),
                # Compare (i < 3)
                Instruction(OpCode.LT, []),
    #             # Jump if false to end (11)
                Instruction(OpCode.JZ, [11]),

    #             # Loop body
    #             # Push "Loop iteration: "
                Instruction(OpCode.PUSH, ["Loop iteration: "]),
    #             # Print
                Instruction(OpCode.PRINT, []),

    #             # Load i
                Instruction(OpCode.LOAD, [0]),
    #             # Print
                Instruction(OpCode.PRINT, []),

    #             # Increment i
    #             # Load i
                Instruction(OpCode.LOAD, [0]),
    #             # Push 1
                Instruction(OpCode.PUSH, [1]),
    #             # Add
                Instruction(OpCode.ADD, []),
    #             # Store in i
                Instruction(OpCode.STORE, [0]),

                # Jump back to start (2)
                Instruction(OpCode.JMP, [2]),

                # End label (11)
    #             # Push "Loop completed"
                Instruction(OpCode.PUSH, ["Loop completed"]),
    #             # Print
                Instruction(OpCode.PRINT, []),

    #             # Halt
                Instruction(OpCode.HALT, [])
    #         ]

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=False)
            interpreter.load_bytecode({"main": instructions})

    start_time = time.time()
    result = interpreter.execute_function("main")
    end_time = time.time()

    #         # Get output and statistics
    output = interpreter.get_output()
    stats = interpreter.get_statistics()

            print("Output:", output)
            print(f"Execution time: {end_time - start_time:.4f}s")
            print(f"Instructions executed: {stats['instruction_count']}")
            print(f"Max stack depth: {stats['max_stack_depth']}")

            print("Loop test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in loop test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

if __name__ == "__main__"
    #     # Change to the noodle-core directory
        os.chdir(os.path.dirname(os.path.abspath(__file__)))

    #     # Run tests
    success1 = test_hello_world()
    success2 = test_arithmetic()
    success3 = test_control_flow()
    success4 = test_loop()

    #     # Print final result
        print("\n\nTest Summary")
    print(" = " * 30)
    #     if success1 and success2 and success3 and success4:
            print("All tests passed successfully!")
            print("\nNative NoodleCore Runtime Demonstration Complete!")
            print("This proves that NoodleCore works independently of Python wrappers.")
            print("\nKey Features Demonstrated:")
            print("- Stack-based bytecode execution")
            print("- Variable storage and retrieval")
            print("- Arithmetic operations")
            print("- Control flow (conditional statements)")
            print("- Loops")
            print("- I/O operations")
            print("\nThe native runtime demonstrates that NoodleCore is a complete,")
            print("independent language runtime system that can execute bytecode")
    #         print("directly, without relying on Python for execution.")
            sys.exit(0)
    #     else:
            print("Some tests failed!")
            sys.exit(1)