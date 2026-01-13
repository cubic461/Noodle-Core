# Converted from Python to NoodleCore
# Original file: src

# """
# Bytecode executor for the Noodle runtime.

# This module provides bytecode execution functionality including:
# - Bytecode interpretation
# - Instruction execution
# - Memory management
# - Error handling
# """

import sys
import traceback
import typing.Any


class BytecodeExecutor
    #     """
    #     Executes Noodle bytecode instructions.
    #     """

    #     def __init__(self, config: Optional[Dict] = None):""
    #         Initialize the bytecode executor.

    #         Args:
    #             config: Configuration dictionary for executor settings
    #         """
    self.config = config or {}
    self.stack = []
    self.variables = {}
    self.instructions = []
    self.pc = 0  # Program counter

    #     def load_bytecode(self, bytecode: List[Dict]) -None):
    #         """
    #         Load bytecode for execution.

    #         Args:
    #             bytecode: List of bytecode instructions
    #         """
    self.instructions = bytecode
    self.pc = 0

    #     def execute(self) -Any):
    #         """
    #         Execute the loaded bytecode.

    #         Returns:
    #             Result of execution
    #         """
    #         try:
    #             while self.pc < len(self.instructions):
    instruction = self.instructions[self.pc]
                    self._execute_instruction(instruction)
    self.pc + = 1

    #             return self.stack[-1] if self.stack else None

    #         except Exception as e:
                raise RuntimeError(f"Bytecode execution error: {e}") from e

    #     def _execute_instruction(self, instruction: Dict) -None):
    #         """
    #         Execute a single instruction.

    #         Args:
    #             instruction: Instruction dictionary
    #         """
    opcode = instruction.get("opcode")
    operands = instruction.get("operands", [])

    #         if opcode == "PUSH":
                self.stack.append(operands[0])
    #         elif opcode == "POP":
    #             if self.stack:
                    self.stack.pop()
    #         elif opcode == "ADD":
    #             if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                    self.stack.append(a + b)
    #         elif opcode == "SUB":
    #             if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                    self.stack.append(a - b)
    #         elif opcode == "MUL":
    #             if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                    self.stack.append(a * b)
    #         elif opcode == "DIV":
    #             if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
    #                 if b != 0:
                        self.stack.append(a / b)
    #                 else:
                        raise ZeroDivisionError("Division by zero")
    #         elif opcode == "LOAD_VAR":
    var_name = operands[0]
    #             if var_name in self.variables:
                    self.stack.append(self.variables[var_name])
    #             else:
                    raise NameError(f"Variable '{var_name}' not found")
    #         elif opcode == "STORE_VAR":
    var_name = operands[0]
    value = self.stack.pop()
    self.variables[var_name] = value
    #         elif opcode == "JUMP":
    self.pc = operands[0] - 1  # -1 because pc increments after
    #         elif opcode == "JUMP_IF_TRUE":
    #             if self.stack.pop():
    self.pc = operands[0] - 1
    #         elif opcode == "JUMP_IF_FALSE":
    #             if not self.stack.pop():
    self.pc = operands[0] - 1
    #         else:
                raise NotImplementedError(f"Opcode '{opcode}' not implemented")

    #     def reset(self) -None):
    #         """Reset the executor state."""
    self.stack = []
    self.variables = {}
    self.pc = 0

    #     def get_state(self) -Dict):
    #         """
    #         Get current executor state.

    #         Returns:
    #             State dictionary
    #         """
    #         return {
                "stack": self.stack.copy(),
                "variables": self.variables.copy(),
    #             "pc": self.pc,
    #         }

    #     def set_state(self, state: Dict) -None):
    #         """
    #         Set executor state.

    #         Args:
    #             state: State dictionary
    #         """
    self.stack = state.get("stack", [])
    self.variables = state.get("variables", {})
    self.pc = state.get("pc", 0)
