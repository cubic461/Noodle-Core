#!/usr/bin/env python3
"""
Noodle Lang::Nbc Vm - nbc_vm.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Noodle Bytecode Virtual Machine (NBC VM)

Deze module implementeert een NBC (Noodle Bytecode) VM die de bytecode
van de NoodleCore compiler kan uitvoeren.

Architectuur:
- Stack-based virtual machine
- Static single-assignment (SSA) form
- Type-annotated bytecode
- Functional execution model

Core Components:
1. NBCVM - Main execution engine
2. NBCBytecode - Bytecode container
3. Instruction - Instruction representation
4. Heap - Variable storage
5. Stack - Evaluation stack
"""

from dataclasses import dataclass
from typing import Any, List, Dict, Optional, Union, Callable
from enum import Enum
import json
import pickle


class Opcode(Enum):
    """NBC Opcodes"""
    
    # Stack operations
    LOAD_CONST = "LOAD_CONST"  # Push constant onto stack
    POP_TOP = "POP_TOP"  # Pop top of stack
    
    # Variable operations
    STORE_NAME = "STORE_NAME"  # Store top in variable
    LOAD_NAME = "LOAD_NAME"  # Load variable onto stack
    
    # Arithmetic operations
    BINARY_ADD = "BINARY_ADD"
    BINARY_SUBTRACT = "BINARY_SUBTRACT"
    BINARY_MULTIPLY = "BINARY_MULTIPLY"
    BINARY_DIVIDE = "BINARY_DIVIDE"
    BINARY_MODULO = "BINARY_MODULO"
    
    # Comparison operations
    COMPARE_OP = "COMPARE_OP"
    
    # Control flow
    JUMP_ABSOLUTE = "JUMP_ABSOLUTE"
    JUMP_FORWARD = "JUMP_FORWARD"
    POP_JUMP_IF_FALSE = "POP_JUMP_IF_FALSE"
    
    # Function operations
    MAKE_FUNCTION = "MAKE_FUNCTION"
    CALL_FUNCTION = "CALL_FUNCTION"
    RETURN_VALUE = "RETURN_VALUE"
    
    # Object operations
    BUILD_LIST = "BUILD_LIST"
    BUILD_DICT = "BUILD_DICT"
    
    # Attribute access
    LOAD_ATTR = "LOAD_ATTR"
    STORE_ATTR = "STORE_ATTR"


class ComparisonOp(Enum):
    """Comparison operators"""
    EQ = "=="
    NE = "!="
    LT = "<"
    GT = ">"
    LE = "<="
    GE = ">="


@dataclass
class Instruction:
    """NBC Instruction"""
    opcode: Opcode
    operand: Any = None
    lineno: int = 0  # Source line for debugging
    
    def __str__(self):
        if self.operand is not None:
            return f"{self.opcode.value} {self.operand}"
        return self.opcode.value


@dataclass
class FunctionObject:
    """Function object in NBC"""
    name: str
    bytecode: 'NBCBytecode'
    parameters: List[str]
    
    def __str__(self):
        return f"<Function {self.name} with {len(self.parameters)} params>"


class NBCBytecode:
    """
    Noodle Bytecode container
    Contains instructions, constants, and metadata
    """
    
    def __init__(self, instructions: List[Instruction] = None,
                 constants: List[Any] = None,
                 names: List[str] = None,
                 functions: List[str] = None,
                 entry_point: str = None):
        self.instructions = instructions or []
        self.constants = constants or []
        self.names = names or []  # Variable names
        self.functions = functions or []  # Function names
        self.entry_point = entry_point or "main"
    
    def add_instruction(self, opcode: Opcode, operand=None, lineno=0):
        """Add instruction to bytecode"""
        self.instructions.append(Instruction(opcode, operand, lineno))
    
    def add_constant(self, value: Any) -> int:
        """Add constant and return its index"""
        if value not in self.constants:
            self.constants.append(value)
        return self.constants.index(value)
    
    def add_name(self, name: str) -> int:
        """Add variable name and return its index"""
        if name not in self.names:
            self.names.append(name)
        return self.names.index(name)
    
    def save(self, filename: str):
        """Save bytecode to file"""
        with open(filename, 'wb') as f:
            pickle.dump(self, f)
    
    @staticmethod
    def load(filename: str) -> 'NBCBytecode':
        """Load bytecode from file"""
        with open(filename, 'rb') as f:
            return pickle.load(f)
    
    def disassemble(self) -> str:
        """Disassemble bytecode to human-readable format"""
        lines = ["NBC Bytecode Disassembly"]
        lines.append("=" * 50)
        
        lines.append(f"Constants ({len(self.constants)}):")
        for i, const in enumerate(self.constants):
            lines.append(f"  {i}: {repr(const)}")
        
        lines.append(f"\\nNames ({len(self.names)}):")
        for i, name in enumerate(self.names):
            lines.append(f"  {i}: {repr(name)}")
        
        lines.append(f"\\nFunctions ({len(self.functions)}):")
        for func in self.functions:
            lines.append(f"  {func}")
        
        lines.append(f"\\nEntry point: {self.entry_point}")
        
        lines.append(f"\\nInstructions ({len(self.instructions)}):")
        for i, instr in enumerate(self.instructions):
            lines.append(f"  {i:3d}: {instr}")
        
        return "\\n".join(lines)
    
    def size(self) -> int:
        """Return size in memory (approximate)"""
        total = sum(len(str(instr)) for instr in self.instructions)
        total += sum(sys.getsizeof(const) for const in self.constants)
        total += sum(len(name) for name in self.names)
        return total


class NBCVM:
    """
    Noodle Bytecode Virtual Machine
    
    Een stack-based VM die NBC bytecode uitvoert.
    Houdt stack, heap (variables), en instruction pointer bij.
    """
    
    def __init__(self):
        # Execution state
        self.stack = []
        self.heap = {}
        
        # Code being executed
        self.bytecode: Optional[NBCBytecode] = None
        self.instructions: List[Instruction] = []
        self.instruction_pointer = 0
        
        # Runtime state
        self.running = False
        self.last_result = None
        self.error = None
        
        # Performance monitoring
        self.instructions_executed = 0
        self.max_stack_depth = 0
        self.start_time = 0
        
    def load_bytecode(self, bytecode: NBCBytecode):
        """Load bytecode for execution"""
        self.bytecode = bytecode
        self.instructions = bytecode.instructions
    
    def reset(self):
        """Reset execution state"""
        self.stack.clear()
        self.heap.clear()
        self.instruction_pointer = 0
        self.running = False
        self.last_result = None
        self.error = None
        self.instructions_executed = 0
        self.max_stack_depth = 0
    
    def execute(self) -> Any:
        """
        Execute loaded bytecode and return result
        
        Returns:
            Result of execution (return value or None)
        
        Raises:
            NBCRuntimeError: On execution errors
        """
        if not self.instructions:
            raise NBCRuntimeError("No bytecode loaded")
        
        self.reset()
        self.running = True
        
        try:
            while self.running:
                if not (0 <= self.instruction_pointer < len(self.instructions)):
                    self.running = False
                    break
                
                self._execute_single_instruction()
            
            return self.last_result
        
        except Exception as e:
            self.running = False
            self.error = f"Runtime error: {type(e).__name__}: {str(e)}"
            raise NBCRuntimeError(self.error)
    
    def _execute_single_instruction(self):
        """Execute one instruction"""
        instruction = self.instructions[self.instruction_pointer]
        self.instruction_pointer += 1
        self.instructions_executed += 1
        
        # Update max stack depth
        if len(self.stack) > self.max_stack_depth:
            self.max_stack_depth = len(self.stack)
        
        # Dispatch instruction
        try:
            self._dispatch(instruction)
        except Exception as e:
            raise NBCRuntimeError(
                f"Instruction {instruction} failed at IP {self.instruction_pointer-1}: {e}"
            )
    
    def _dispatch(self, instruction: Instruction):
        """Dispatch instruction to handler"""
        opcode_handlers = {
            Opcode.LOAD_CONST: self._handle_load_const,
            Opcode.POP_TOP: self._handle_pop_top,
            Opcode.STORE_NAME: self._handle_store_name,
            Opcode.LOAD_NAME: self._handle_load_name,
            Opcode.BINARY_ADD: self._handle_binary_add,
            Opcode.BINARY_SUBTRACT: self._handle_binary_subtract,
            Opcode.BINARY_MULTIPLY: self._handle_binary_multiply,
            Opcode.BINARY_DIVIDE: self._handle_binary_divide,
            Opcode.COMPARE_OP: self._handle_compare_op,
            Opcode.JUMP_ABSOLUTE: self._handle_jump_absolute,
            Opcode.POP_JUMP_IF_FALSE: self._handle_pop_jump_if_false,
            Opcode.RETURN_VALUE: self._handle_return_value,
            Opcode.BUILD_LIST: self._handle_build_list,
        }
        
        handler = opcode_handlers.get(instruction.opcode)
        if handler:
            handler(instruction)
        else:
            raise NotImplementedError(
                f"Opcode {instruction.opcode} not implemented yet"
            )
    
    # --- Instruction Handlers ---
    
    def _handle_load_const(self, instr: Instruction):
        """Push constant onto stack"""
        if instr.operand is None:
            raise NBCRuntimeError("LOAD_CONST requires operand")
        
        try:
            constant = self.bytecode.constants[instr.operand]
        except IndexError:
            raise NBCRuntimeError(f"Invalid constant index {instr.operand}")
        
        self.stack.append(constant)
    
    def _handle_pop_top(self, instr: Instruction):
        """Pop top of stack"""
        if not self.stack:
            raise NBCRuntimeError("Cannot POP_TOP from empty stack")
        self.stack.pop()
    
    def _handle_store_name(self, instr: Instruction):
        """Store top of stack in variable"""
        if instr.operand is None:
            raise NBCRuntimeError("STORE_NAME requires operand")
        
        if not self.stack:
            raise NBCRuntimeError("Cannot STORE_NAME from empty stack")
        
        try:
            name = self.bytecode.names[instr.operand]
        except IndexError:
            raise NBCRuntimeError(f"Invalid name index {instr.operand}")
        
        value = self.stack.pop()
        self.heap[name] = value
    
    def _handle_load_name(self, instr: Instruction):
        """Load variable onto stack"""
        if instr.operand is None:
            raise NBCRuntimeError("LOAD_NAME requires operand")
        
        try:
            name = self.bytecode.names[instr.operand]
        except IndexError:
            raise NBCRuntimeError(f"Invalid name index {instr.operand}")
        
        if name not in self.heap:
            raise NBCRuntimeError(f"Variable {name!r} not defined")
        
        self.stack.append(self.heap[name])
    
    def _handle_binary_add(self, instr: Instruction):
        """Binary addition"""
        if len(self.stack) < 2:
            raise NBCRuntimeError("Need 2 operands for BINARY_ADD")
        
        b = self.stack.pop()
        a = self.stack.pop()
        result = a + b
        self.stack.append(result)
    
    def _handle_binary_subtract(self, instr: Instruction):
        """Binary subtraction"""
        if len(self.stack) < 2:
            raise NBCRuntimeError("Need 2 operands for BINARY_SUBTRACT")
        
        b = self.stack.pop()
        a = self.stack.pop()
        result = a - b
        self.stack.append(result)
    
    def _handle_binary_multiply(self, instr: Instruction):
        """Binary multiplication"""
        if len(self.stack) < 2:
            raise NBCRuntimeError("Need 2 operands for BINARY_MULTIPLY")
        
        b = self.stack.pop()
        a = self.stack.pop()
        result = a * b
        self.stack.append(result)
    
    def _handle_binary_divide(self, instr: Instruction):
        """Binary division"""
        if len(self.stack) < 2:
            raise NBCRuntimeError("Need 2 operands for BINARY_DIVIDE")
        
        b = self.stack.pop()
        a = self.stack.pop()
        
        if b == 0:
            raise NBCRuntimeError("Division by zero")
        
        result = a / b
        self.stack.append(result)
    
    def _handle_compare_op(self, instr: Instruction):
        """Comparison operation"""
        if len(self.stack) < 2:
            raise NBCRuntimeError("Need 2 operands for COMPARE_OP")
        
        comparison_map = {
            "==": lambda a, b: a == b,
            "!=": lambda a, b: a != b,
            "<": lambda a, b: a < b,
            ">": lambda a, b: a > b,
            "<=": lambda a, b: a <= b,
            ">=": lambda a, b: a >= b,
        }
        
        comparison = instr.operand
        handler = comparison_map.get(comparison)
        if not handler:
            raise NBCRuntimeError(f"Unknown comparison {comparison}")
        
        b = self.stack.pop()
        a = self.stack.pop()
        result = handler(a, b)
        self.stack.append(result)
    
    def _handle_jump_absolute(self, instr: Instruction):
        """Unconditional jump"""
        try:
            target_ip = instr.operand
            if not isinstance(target_ip, int):
                raise ValueError("Target must be integer")
            if not (0 <= target_ip < len(self.instructions)):
                raise ValueError("Target out of bounds")
        except (TypeError, ValueError) as e:
            raise NBCRuntimeError(f"Invalid jump target: {e}")
        
        self.instruction_pointer = target_ip
    
    def _handle_pop_jump_if_false(self, instr: Instruction):
        """Pop and jump if false"""
        if not self.stack:
            raise NBCRuntimeError("Cannot POP_JUMP_IF_FALSE from empty stack")
        
        condition = self.stack.pop()
        
        try:
            target_ip = instr.operand
            if not isinstance(target_ip, int):
                raise ValueError("Target must be integer")
            if not (0 <= target_ip < len(self.instructions)):
                raise ValueError("Target out of bounds")
        except (TypeError, ValueError) as e:
            raise NBCRuntimeError(f"Invalid jump target: {e}")
        
        # The interpreter jumps if the condition is TRUE (non-zero)
        # But in our stack machine semantics, we jump if FALSE
        if not condition:
            self.instruction_pointer = target_ip
    
    def _handle_return_value(self, instr: Instruction):
        """Return from function"""
        if self.stack:
            self.last_result = self.stack[-1]
        else:
            self.last_result = None
        
        # Stop execution
        self.running = False
    
    def _handle_build_list(self, instr: Instruction):
        """Build a list from stack values"""
        try:
            count = instr.operand
            if not isinstance(count, int) or count < 0:
                raise ValueError("Count must be non-negative integer")
            if count > len(self.stack):
                raise ValueError("Not enough values on stack")
        except (TypeError, ValueError) as e:
            raise NBCRuntimeError(f"Invalid BUILD_LIST operand: {e}")
        
        # Pop count elements from stack
        elements = []
        for _ in range(count):
            elements.insert(0, self.stack.pop())  # Insert at front to maintain order
        
        self.stack.append(elements)
    
    def get_stack_dump(self) -> str:
        """Get string representation of current stack"""
        return "[" + ", ".join(repr(item) for item in self.stack) + "]"
    
    def get_heap_dump(self) -> str:
        """Get string representation of heap"""
        return str(self.heap)


class NBCRuntimeError(Exception):
    """Runtime error in NBC VM"""
    pass


def example_bytecode() -> NBCBytecode:
    """
    Genereer voorbeeld bytecode voor een simpele expressie:
        def hello() { return 42; }
    """
    bytecode = NBCBytecode()
    
    # Constants
    const_42 = bytecode.add_constant(42)
    
    # Instructions
    bytecode.add_instruction(Opcode.LOAD_CONST, const_42, 1)  # Push 42
    bytecode.add_instruction(Opcode.RETURN_VALUE, None, 2)     # Return
    
    return bytecode


if __name__ == "__main__":
    import sys
    from pathlib import Path
    
    # Example: Execute example bytecode
    try:
        print("=== NBC VM Demonstration ===")
        
        # Create and execute example bytecode
        bytecode = example_bytecode()
        
        print("\nDisassembly:")
        print(bytecode.disassemble())
        
        print("\n\\nExecuting...")
        vm = NBCVM()
        vm.load_bytecode(bytecode)
        result = vm.execute()
        
        print(f"âœ… Execution successful!")
        print(f"   Result: {result}")
        print(f"   Instructions executed: {vm.instructions_executed}")
        print(f"   Max stack depth: {vm.max_stack_depth}")
        
        sys.exit(0)
    
    except Exception as e:
        print(f"\\nâŒ Execution failed: {e}")
        sys.exit(1)


