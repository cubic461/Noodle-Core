# Converted from Python to NoodleCore
# Original file: src

# """
# Runtime Core for NBC Runtime
# ---------------------------
# This module contains the core runtime functionality for NBC execution.
# It provides the basic execution engine, stack management, and instruction handling.
# """

import time
import traceback
import typing.Any

import ...compiler.code_generator.BytecodeInstruction
import .config.NBCConfig
import .runtime_manager.StackManager
import .error_handler.ErrorHandler
import .errors.NBCRuntimeError


class RuntimeCore
    #     """
    #     Core runtime functionality for NBC execution.
    #     Handles basic instruction execution, stack management, and program control.
    #     """

    #     def __init__(self, config: NBCConfig = None):""
    #         Initialize the runtime core.

    #         Args:
    #             config: Runtime configuration
    #         """
    self.config = config or NBCConfig()
    self.stack: List[Any] = []
    self.globals: Dict[str, Any] = {}
    self.program_counter: int = 0
    self.bytecode: List[BytecodeInstruction] = []
    #         self.is_debug = self.config.debug_mode if hasattr(self.config, 'debug_mode') else False
    self.max_execution_time = getattr(self.config, 'max_execution_time', 300)  # 5 minutes default
    self.start_time = None
    self.error_handler = ErrorHandler()

    #         # Stack manager integration
    self.stack_manager = None
    #         if hasattr(self.config, 'max_stack_size'):
    self.stack_manager = StackManager(max_stack_depth=self.config.max_stack_size)

    #         # Built-in operations
    self.operations = {
    #             OpCode.PUSH: self._op_push,
    #             OpCode.POP: self._op_pop,
    #             OpCode.ADD: self._op_add,
    #             OpCode.SUB: self._op_sub,
    #             OpCode.MUL: self._op_mul,
    #             OpCode.DIV: self._op_div,
    #             OpCode.PRINT: self._op_print,
    #             OpCode.STORE: self._op_store,
    #             OpCode.LOAD: self._op_load,
    #             OpCode.CALL: self._op_call,
    #             OpCode.RET: self._op_return,
    #             OpCode.JMP: self._op_jump,
    #             OpCode.JZ: self._op_jump_if_false,
    #             OpCode.EQ: self._op_equal,
    #             OpCode.LT: self._op_less_than,
    #             OpCode.GT: self._op_greater_than,
    #             OpCode.HALT: self._op_halt,
    #         }

    #     def load_bytecode(self, bytecode: List[BytecodeInstruction]):
    #         """
    #         Load bytecode instructions for execution.

    #         Args:
    #             bytecode: List of bytecode instructions
    #         """
    self.bytecode = bytecode
    self.program_counter = 0

    #         if self.is_debug:
                print(f"Loaded {len(bytecode)} bytecode instructions")

    #     def execute(self) -Any):
    #         """
    #         Execute the loaded bytecode.

    #         Returns:
    #             The result of program execution
    #         """
    #         if not self.bytecode:
                raise NBCRuntimeError("No bytecode loaded")

    self.start_time = time.time()

    #         try:
    #             while self.program_counter < len(self.bytecode):
    #                 # Check execution timeout
    #                 if self._check_timeout():
                        raise NBCRuntimeError("Execution timeout exceeded")

    instruction = self.bytecode[self.program_counter]

    #                 if self.is_debug:
                        print(f"Executing instruction {self.program_counter}: {instruction}")

    #                 # Execute the instruction
                    self._execute_instruction(instruction)

    #                 # Increment program counter
    self.program_counter + = 1

    #                 # Check for halt condition
    #                 if instruction.opcode == OpCode.HALT:
    #                     break

    #             # Return the top of the stack if available
    #             if self.stack:
    #                 return self.stack[-1]
    #             return None

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Execution error at instruction {self.program_counter}: {e}")
                    print(f"Stack trace: {traceback.format_exc()}")
                raise NBCRuntimeError(f"Execution failed at instruction {self.program_counter}: {e}")

    #     def _check_timeout(self) -bool):
    #         """Check if execution has exceeded the timeout limit."""
    #         if self.start_time and (time.time() - self.start_time) self.max_execution_time):
    #             return True
    #         return False

    #     def _execute_instruction(self, instruction: BytecodeInstruction):
    #         """Execute a single bytecode instruction."""
    opcode = instruction.opcode
    operands = instruction.operands

    #         # Get the handler for this opcode
    handler = self.operations.get(opcode)
    #         if handler:
                handler(operands)
    #         else:
                raise NBCRuntimeError(f"Unknown opcode: {opcode}")

    #     def _op_push(self, operands):
    #         """Push operation - push value onto stack."""
    #         if len(operands) 0):
                self.stack.append(operands[0])

    #     def _op_pop(self, operands):
    #         """Pop operation - pop value from stack."""
    #         if self.stack:
                self.stack.pop()

    #     def _op_add(self, operands):
    #         """Add operation - add top two values on stack."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a + b)

    #     def _op_sub(self, operands):
    #         """Subtract operation - subtract top two values on stack."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a - b)

    #     def _op_mul(self, operands):
    #         """Multiply operation - multiply top two values on stack."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a * b)

    #     def _op_div(self, operands):
    #         """Divide operation - divide top two values on stack."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
    #             if b = 0:
                    raise NBCRuntimeError("Division by zero")
                self.stack.append(a / b)

    #     def _op_print(self, operands):
    #         """Print operation - print top value on stack."""
    #         if self.stack:
    value = self.stack.pop()
                print(value)

    #     def _op_store(self, operands):
    #         """Store operation - store value in variable."""
    #         if len(operands) >= 1 and self.stack:
    var_name = operands[0]
    value = self.stack.pop()
    self.globals[var_name] = value

    #             # Update stack manager if available
    #             if self.stack_manager:
                    self.stack_manager.set_variable(var_name, value)

    #     def _op_load(self, operands):
    #         """Load operation - load variable value onto stack."""
    #         if len(operands) >= 1:
    var_name = operands[0]
    #             # Try stack manager first, then globals
    #             if self.stack_manager:
    value = self.stack_manager.get_variable(var_name)
    #                 if value is not None:
                        self.stack.append(value)
    #                     return

    #             if var_name in self.globals:
                    self.stack.append(self.globals[var_name])
    #             else:
                    raise NBCRuntimeError(f"Variable not found: {var_name}")

    #     def _op_call(self, operands):
    #         """Call operation - call function (placeholder for now)."""
    #         # This will be expanded when we add function call support
    #         if self.is_debug:
                print(f"Function call placeholder: {operands}")

    #     def _op_return(self, operands):
    #         """Return operation - return from function (placeholder for now)."""
    #         # This will be expanded when we add function call support
    #         if self.is_debug:
                print("Return operation placeholder")

    #     def _op_jump(self, operands):
    #         """Jump operation - jump to specified instruction."""
    #         if len(operands) >= 1:
    self.program_counter = operands[0] - 1  # -1 because we increment after execution

    #     def _op_jump_if_false(self, operands):
    #         """Jump if false operation - jump if top value is false."""
    #         if len(operands) >= 1 and self.stack:
    condition = self.stack.pop()
    #             if not condition:
    self.program_counter = operands[0] - 1

    #     def _op_equal(self, operands):
    #         """Equal operation - compare top two values for equality."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
    self.stack.append(a == b)

    #     def _op_less_than(self, operands):
    #         """Less than operation - compare if top value is less than next."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a < b)

    #     def _op_greater_than(self, operands):
    #         """Greater than operation - compare if top value is greater than next."""
    #         if len(self.stack) >= 2:
    b = self.stack.pop()
    a = self.stack.pop()
                self.stack.append(a b)

    #     def _op_halt(self, operands)):
    #         """Halt operation - stop execution."""
    #         # This will be handled in the main execution loop
    #         pass

    #     def get_stack_depth(self) -int):
    #         """Get current stack depth."""
            return len(self.stack)

    #     def get_global_variables(self) -Dict[str, Any]):
    #         """Get global variables."""
            return self.globals.copy()

    #     def reset(self):
    #         """Reset runtime state."""
            self.stack.clear()
            self.globals.clear()
    self.program_counter = 0
            self.bytecode.clear()
    self.start_time = None

    #         # Reset stack manager
    #         if self.stack_manager:
                self.stack_manager.clear_stack()


def create_runtime_core(config: NBCConfig = None) -RuntimeCore):
#     """
#     Create a new runtime core instance.

#     Args:
#         config: Runtime configuration

#     Returns:
#         RuntimeCore instance
#     """
    return RuntimeCore(config)


__all__ = ["RuntimeCore", "create_runtime_core"]
