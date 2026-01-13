# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Code Generator for Noodle Programming Language
# ----------------------------------------------
# This module implements the code generation phase of the Noodle compiler.
# It converts AST nodes to bytecode instructions that can be executed by the NBC runtime.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import logging
import struct
import typing.Any,

import .ast_nodes.(
#     ASTNode,
#     ProgramNode,
#     StatementNode,
#     ExpressionNode,
#     LiteralNode,
#     BinaryOpNode,
#     UnaryOpNode,
#     CallNode,
#     VariableNode,
#     AssignmentNode,
#     FunctionDefNode,
#     ParameterNode,
#     ReturnNode,
#     IfNode,
#     WhileNode,
#     ForNode,
#     ImportNode,
#     ListNode,
#     MatrixNode,
#     TensorNode,
#     IndexNode,
#     SliceNode,
#     TryNode,
#     RaiseNode,
#     AsyncNode,
#     AwaitNode,
#     ClassDefNode,
#     PropertyDefNode,
#     DecoratorNode,
#     NodeType,
# )
import .parser_ast_nodes.(
#     ProgramNode as ParserProgramNode,
#     VarDeclNode,
#     AssignStmtNode,
#     ExprStmtNode,
#     IfStmtNode,
#     WhileStmtNode,
#     ForStmtNode,
#     FuncDefNode,
#     ReturnStmtNode,
#     PrintStmtNode,
#     ImportStmtNode,
#     TryStmtNode,
#     CompoundStmtNode,
#     RaiseStmtNode,
#     BinaryExprNode,
#     UnaryExprNode,
#     IdentifierExprNode,
#     LiteralExprNode,
#     CallExprNode,
#     ListExprNode,
#     DictExprNode,
#     SliceExprNode,
#     TernaryExprNode,
# )
import .semantic_analyzer_symbol_table.SymbolTable

# Import NBC runtime instruction format
import ..runtime.nbc_runtime.execution.instruction.(
#     Instruction,
#     InstructionType,
#     InstructionPriority,
# )
import ..runtime.nbc_runtime.execution.bytecode.(
#     BytecodeProcessor,
#     BytecodeProgram,
#     BytecodeFormat,
# )

logger = logging.getLogger(__name__)


class CodeGenerationError(Exception)
    #     """Exception raised during code generation phase."""

    #     def __init__(self, message: str, line_number: int = None, column: int = None):
    self.message = message
    self.line_number = line_number
    self.column = column
            super().__init__(self.message)

    #     def __str__(self):
    #         if self.line_number is not None:
    #             if self.column is not None:
    #                 return f"CodeGenerationError at line {self.line_number}, column {self.column}: {self.message}"
    #             return f"CodeGenerationError at line {self.line_number}: {self.message}"
    #         return f"CodeGenerationError: {self.message}"


class OpCode
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
    POW = 0x16
    ABS = 0x17
    SQRT = 0x18

    #     # Comparison operations
    EQ = 0x20
    NE = 0x21
    LT = 0x22
    LE = 0x23
    GT = 0x24
    GE = 0x25

    #     # Logical operations
    AND = 0x30
    OR = 0x31
    NOT = 0x32
    XOR = 0x33

    #     # Flow control
    JMP = 0x40
    #     JZ = 0x41  # Jump if zero (false)
    #     JNZ = 0x42  # Jump if not zero (true)
    CALL = 0x43
    RET = 0x44
    CMP = 0x45

    #     # Memory operations
    LOAD = 0x50
    STORE = 0x51
    LOAD_GLOB = 0x52
    STORE_GLOB = 0x53

    #     # Matrix operations
    MATRIX_ZEROS = 0x60
    MATRIX_ONES = 0x61
    MATRIX_EYE = 0x62
    MATRIX_ADD = 0x63
    MATRIX_SUB = 0x64
    MATRIX_MUL = 0x65
    MATRIX_DIV = 0x66
    MATRIX_TRANSPOSE = 0x67
    TENSOR_CREATE = 0x68
    TENSOR_RESHAPE = 0x69

    #     # Python operations
    PYTHON_IMPORT = 0x70
    PYTHON_CALL = 0x71
    PYTHON_GETATTR = 0x72

    #     # Resource operations
    RESOURCE_ALLOC = 0x80
    RESOURCE_FREE = 0x81

    #     # Noodle-specific
    PRINT = 0x90
    IMPORT_MOD = 0x91
    CREATE_LIST = 0x92
    APPEND_LIST = 0x93
    CREATE_DICT = 0x94
    SET_DICT = 0x95

    #     # Control flow extensions
    ENTER_FRAME = 0xA0
    EXIT_FRAME = 0xA1

    #     # Special
    HALT = 0xFF


class BytecodeInstruction
    #     """Represents a single bytecode instruction compatible with NBC runtime"""

    #     def __init__(self, opcode: int, operands: List[Any] = None):
    self.opcode = opcode
    self.operands = operands or []

    #     def to_instruction(self) -> Instruction:
    #         """Convert to NBC runtime Instruction format"""
    #         # Map opcode to instruction type and name
    opcode_map = {
                OpCode.ADD: ("ADD", InstructionType.ARITHMETIC),
                OpCode.SUB: ("SUB", InstructionType.ARITHMETIC),
                OpCode.MUL: ("MUL", InstructionType.ARITHMETIC),
                OpCode.DIV: ("DIV", InstructionType.ARITHMETIC),
                OpCode.MOD: ("MOD", InstructionType.ARITHMETIC),
                OpCode.NEG: ("NEG", InstructionType.ARITHMETIC),
                OpCode.POW: ("POW", InstructionType.ARITHMETIC),
                OpCode.ABS: ("ABS", InstructionType.ARITHMETIC),
                OpCode.SQRT: ("SQRT", InstructionType.ARITHMETIC),
                OpCode.EQ: ("EQ", InstructionType.LOGICAL),
                OpCode.NE: ("NE", InstructionType.LOGICAL),
                OpCode.LT: ("LT", InstructionType.LOGICAL),
                OpCode.LE: ("LE", InstructionType.LOGICAL),
                OpCode.GT: ("GT", InstructionType.LOGICAL),
                OpCode.GE: ("GE", InstructionType.LOGICAL),
                OpCode.AND: ("AND", InstructionType.LOGICAL),
                OpCode.OR: ("OR", InstructionType.LOGICAL),
                OpCode.NOT: ("NOT", InstructionType.LOGICAL),
                OpCode.XOR: ("XOR", InstructionType.LOGICAL),
                OpCode.JMP: ("JMP", InstructionType.CONTROL_FLOW),
                OpCode.JZ: ("JZ", InstructionType.CONTROL_FLOW),
                OpCode.JNZ: ("JNZ", InstructionType.CONTROL_FLOW),
                OpCode.CALL: ("CALL", InstructionType.CONTROL_FLOW),
                OpCode.RET: ("RET", InstructionType.CONTROL_FLOW),
                OpCode.CMP: ("CMP", InstructionType.CONTROL_FLOW),
                OpCode.MATRIX_ZEROS: ("MATRIX_ZEROS", InstructionType.MATRIX),
                OpCode.MATRIX_ONES: ("MATRIX_ONES", InstructionType.MATRIX),
                OpCode.MATRIX_EYE: ("MATRIX_EYE", InstructionType.MATRIX),
                OpCode.MATRIX_ADD: ("MATRIX_ADD", InstructionType.MATRIX),
                OpCode.MATRIX_SUB: ("MATRIX_SUB", InstructionType.MATRIX),
                OpCode.MATRIX_MUL: ("MATRIX_MUL", InstructionType.MATRIX),
                OpCode.MATRIX_DIV: ("MATRIX_DIV", InstructionType.MATRIX),
                OpCode.MATRIX_TRANSPOSE: ("MATRIX_TRANSPOSE", InstructionType.MATRIX),
                OpCode.TENSOR_CREATE: ("TENSOR_CREATE", InstructionType.MATRIX),
                OpCode.TENSOR_RESHAPE: ("TENSOR_RESHAPE", InstructionType.MATRIX),
                OpCode.PRINT: ("PRINT", InstructionType.NORMAL),
                OpCode.CREATE_LIST: ("CREATE_LIST", InstructionType.NORMAL),
                OpCode.APPEND_LIST: ("APPEND_LIST", InstructionType.NORMAL),
                OpCode.CREATE_DICT: ("CREATE_DICT", InstructionType.NORMAL),
                OpCode.SET_DICT: ("SET_DICT", InstructionType.NORMAL),
                OpCode.PUSH: ("PUSH", InstructionType.STACK),
                OpCode.POP: ("POP", InstructionType.STACK),
                OpCode.DUP: ("DUP", InstructionType.STACK),
                OpCode.SWAP: ("SWAP", InstructionType.STACK),
                OpCode.LOAD: ("LOAD", InstructionType.MEMORY),
                OpCode.STORE: ("STORE", InstructionType.MEMORY),
                OpCode.LOAD_GLOB: ("LOAD_GLOB", InstructionType.MEMORY),
                OpCode.STORE_GLOB: ("STORE_GLOB", InstructionType.MEMORY),
                OpCode.ENTER_FRAME: ("ENTER_FRAME", InstructionType.FUNCTION),
                OpCode.EXIT_FRAME: ("EXIT_FRAME", InstructionType.FUNCTION),
                OpCode.HALT: ("HALT", InstructionType.NORMAL),
    #         }

    name, instr_type = opcode_map.get(self.opcode, (f"UNKNOWN_{self.opcode:02X}", InstructionType.NORMAL))

            return Instruction(
    opcode = name,
    operands = self.operands,
    instruction_type = instr_type,
    priority = InstructionPriority.NORMAL,
    estimated_cycles = 1,
    #         )


class CodeGenerator
    #     """Noodle Code Generator - generates bytecode from AST for NBC runtime"""

    #     def __init__(self):
    self.bytecode: List[BytecodeInstruction] = []
    self.constants: List[Any] = []
    self.labels: Dict[str, int] = {}
    self.label_refs: Dict[str, List[int]] = {}
    self.local_vars: Dict[str, int] = {}
    self.global_vars: Dict[str, int] = {}
    self.next_offset = 0
    self.symbol_table = None
    self.current_scope_depth = 0
    self.function_stack: List[str] = []
    self.loop_stack: List[Tuple[str, str]] = []  # (start_label, end_label)
    self.bytecode_processor = BytecodeProcessor()

    #     def generate(
    self, ast: ASTNode, symbol_table: Optional[SymbolTable] = None, target_format: str = "nbc"
    #     ) -> List[Instruction]:
    #         """
    #         Generate bytecode from validated AST using symbol table for scopes/types.

    #         Args:
    #             ast: Validated AST root
    #             symbol_table: Semantic symbol table for variable resolution
    #             target_format: 'nbc' for bytecode

    #         Returns:
    #             List of NBC runtime Instructions
    #         """
    self.symbol_table = symbol_table
    self.bytecode = []
    self.constants = []
    self.labels = {}
    self.label_refs = {}
    self.local_vars = {}
    self.global_vars = {}
    self.next_offset = 0
    self.current_scope_depth = 0
    self.function_stack = []
    self.loop_stack = []

    #         # Handle different AST node types
    #         if isinstance(ast, ProgramNode):
                self._generate_program(ast)
    #         elif isinstance(ast, ParserProgramNode):
                self._generate_parser_program(ast)
    #         else:
                self._generate_statement(ast)

    #         # Resolve labels
            self._resolve_labels()

    #         # Ensure halt
    #         if not self.bytecode or self.bytecode[-1].opcode != OpCode.HALT:
                self._emit(OpCode.HALT)

    #         # Convert to NBC runtime instructions
    #         instructions = [instr.to_instruction() for instr in self.bytecode]

    #         if target_format == "nbc":
    #             return instructions
            raise ValueError(f"Unsupported target: {target_format}")

    #     def _generate_program(self, program: ProgramNode):
    #         """Generate code for entire program"""
    #         # Global scope
    #         if self.symbol_table:
                self.symbol_table.enter_scope()

    #         for stmt in program.statements:
                self._generate_statement(stmt)

    #         if self.symbol_table:
                self.symbol_table.exit_scope()

    #     def _generate_parser_program(self, program: ParserProgramNode):
    #         """Generate code for parser program node"""
    #         # Global scope
    #         if self.symbol_table:
                self.symbol_table.enter_scope()

    #         for stmt in program.children:
                self._generate_statement(stmt)

    #         if self.symbol_table:
                self.symbol_table.exit_scope()

    #     def _generate_statement(self, stmt: ASTNode):
    #         """Dispatch to statement handlers"""
    #         if isinstance(stmt, AssignmentNode):
                self._generate_assignment(stmt)
    #         elif isinstance(stmt, AssignStmtNode):
                self._generate_parser_assignment(stmt)
    #         elif isinstance(stmt, VarDeclNode):
                self._generate_var_decl(stmt)
    #         elif isinstance(stmt, ExprStmtNode):
                self._generate_expr(stmt.expression)
                self._emit(OpCode.POP)  # Discard result
    #         elif isinstance(stmt, IfNode):
                self._generate_if(stmt)
    #         elif isinstance(stmt, IfStmtNode):
                self._generate_parser_if(stmt)
    #         elif isinstance(stmt, WhileNode):
                self._generate_while(stmt)
    #         elif isinstance(stmt, WhileStmtNode):
                self._generate_parser_while(stmt)
    #         elif isinstance(stmt, ForNode):
                self._generate_for(stmt)
    #         elif isinstance(stmt, ForStmtNode):
                self._generate_parser_for(stmt)
    #         elif isinstance(stmt, FunctionDefNode):
                self._generate_function_def(stmt)
    #         elif isinstance(stmt, FuncDefNode):
                self._generate_parser_function_def(stmt)
    #         elif isinstance(stmt, ReturnNode):
                self._generate_return(stmt)
    #         elif isinstance(stmt, ReturnStmtNode):
                self._generate_parser_return(stmt)
    #         elif isinstance(stmt, PrintStmtNode):
                self._generate_print(stmt)
    #         elif isinstance(stmt, ImportNode):
                self._generate_import(stmt)
    #         elif isinstance(stmt, ImportStmtNode):
                self._generate_parser_import(stmt)
    #         elif isinstance(stmt, TryNode):
                self._generate_try(stmt)
    #         elif isinstance(stmt, TryStmtNode):
                self._generate_parser_try(stmt)
    #         elif isinstance(stmt, CompoundStmtNode):
    #             if self.symbol_table:
                    self.symbol_table.enter_scope()
    self.current_scope_depth + = 1
    #             for sub_stmt in stmt.statements:
                    self._generate_statement(sub_stmt)
    #             if self.symbol_table:
                    self.symbol_table.exit_scope()
    self.current_scope_depth - = 1
    #         else:
    #             # Unknown: nop
    #             pass

    #     def _generate_expr(self, expr: ExpressionNode):
    #         """Generate code for expressions"""
    #         if isinstance(expr, LiteralNode):
                self._generate_literal(expr)
    #         elif isinstance(expr, LiteralExprNode):
                self._generate_parser_literal(expr)
    #         elif isinstance(expr, VariableNode):
                self._generate_load_var(expr.name)
    #         elif isinstance(expr, IdentifierExprNode):
                self._generate_load_var(expr.name)
    #         elif isinstance(expr, BinaryOpNode):
                self._generate_binary(expr)
    #         elif isinstance(expr, BinaryExprNode):
                self._generate_parser_binary(expr)
    #         elif isinstance(expr, UnaryOpNode):
                self._generate_unary(expr)
    #         elif isinstance(expr, UnaryExprNode):
                self._generate_parser_unary(expr)
    #         elif isinstance(expr, CallNode):
                self._generate_call(expr)
    #         elif isinstance(expr, CallExprNode):
                self._generate_parser_call(expr)
    #         elif isinstance(expr, ListNode):
                self._generate_list(expr)
    #         elif isinstance(expr, ListExprNode):
                self._generate_parser_list(expr)
    #         elif isinstance(expr, MatrixNode):
                self._generate_matrix(expr)
    #         elif isinstance(expr, TensorNode):
                self._generate_tensor(expr)
    #         elif isinstance(expr, IndexNode):
                self._generate_index(expr)
    #         elif isinstance(expr, SliceNode):
                self._generate_slice(expr)
    #         else:
    #             # Default: push None
                self._emit_constant(None)

    #     def _emit(self, opcode: OpCode, *operands) -> int:
    #         """Emit instruction, return index"""
    instr = BytecodeInstruction(opcode, list(operands))
            self.bytecode.append(instr)
            return len(self.bytecode) - 1

    #     def _emit_constant(self, value: Any):
    #         """Add constant if new, emit PUSH idx"""
    #         if value not in self.constants:
                self.constants.append(value)
    idx = self.constants.index(value)
            self._emit(OpCode.PUSH, idx)

    #     def _allocate_var(self, name: str) -> int:
    #         """Allocate local stack slot"""
    #         if name not in self.local_vars:
    self.local_vars[name] = self.next_offset
    self.next_offset + = 1  # Simple slot allocation
    #         return self.local_vars[name]

    #     def _generate_var_decl(self, node: VarDeclNode):
    #         """Var declaration: alloc and init"""
    offset = self._allocate_var(node.name)
    #         if node.initializer:
                self._generate_expr(node.initializer)
    #         else:
                self._emit_constant(None)
            self._emit(OpCode.STORE, offset)

    #     def _generate_assignment(self, node: AssignmentNode):
    #         """Assignment: load target offset, store value"""
    #         if isinstance(node.target, VariableNode):
    offset = self.local_vars.get(node.target.name)
    #             if offset is None:
    offset = self._allocate_var(node.target.name)
                self._generate_expr(node.value)
                self._emit(OpCode.STORE, offset)
    #         else:
                self._generate_expr(node.value)
                self._emit(OpCode.POP)

    #     def _generate_parser_assignment(self, node: AssignStmtNode):
    #         """Parser assignment: load target offset, store value"""
    #         if isinstance(node.target, IdentifierExprNode):
    offset = self.local_vars.get(node.target.name)
    #             if offset is None:
    offset = self._allocate_var(node.target.name)
                self._generate_expr(node.value)
                self._emit(OpCode.STORE, offset)
    #         else:
                self._generate_expr(node.value)
                self._emit(OpCode.POP)

    #     def _generate_load_var(self, name: str):
    #         """Load local var to stack"""
    offset = self.local_vars.get(name)
    #         if offset is not None:
                self._emit(OpCode.LOAD, offset)
    #         else:
    #             # Try global
    #             if name in self.global_vars:
                    self._emit(OpCode.LOAD_GLOB, self.global_vars[name])
    #             else:
                    self._emit_constant(None)  # Undefined

    #     def _generate_literal(self, node: LiteralNode):
    #         """Push literal constant"""
            self._emit_constant(node.value)

    #     def _generate_parser_literal(self, node: LiteralExprNode):
    #         """Push literal constant"""
            self._emit_constant(node.value)

    #     def _generate_binary(self, node: BinaryOpNode):
    #         """Binary op: eval left, right, apply op"""
            self._generate_expr(node.left)
            self._generate_expr(node.right)
    op_map = {
    #             "+": OpCode.ADD,
    #             "-": OpCode.SUB,
    #             "*": OpCode.MUL,
    #             "/": OpCode.DIV,
    #             "%": OpCode.MOD,
    #             "**": OpCode.POW,
    " = =": OpCode.EQ,
    "! = ": OpCode.NE,
    #             "<": OpCode.LT,
    "< = ": OpCode.LE,
    #             ">": OpCode.GT,
    "> = ": OpCode.GE,
    #             "and": OpCode.AND,
    #             "or": OpCode.OR,
    #         }
    #         if node.operator in op_map:
                self._emit(op_map[node.operator])
    #         else:
                self._emit(OpCode.POP)
                self._emit(OpCode.POP)
                self._emit_constant(None)

    #     def _generate_parser_binary(self, node: BinaryExprNode):
    #         """Parser binary op: eval left, right, apply op"""
            self._generate_expr(node.left)
            self._generate_expr(node.right)
    op_map = {
    #             "+": OpCode.ADD,
    #             "-": OpCode.SUB,
    #             "*": OpCode.MUL,
    #             "/": OpCode.DIV,
    " = =": OpCode.EQ,
    "! = ": OpCode.NE,
    #             "<": OpCode.LT,
    "< = ": OpCode.LE,
    #             ">": OpCode.GT,
    "> = ": OpCode.GE,
    #         }
    #         if node.operator in op_map:
                self._emit(op_map[node.operator])
    #         else:
                self._emit(OpCode.POP)
                self._emit(OpCode.POP)
                self._emit_constant(None)

    #     def _generate_unary(self, node: UnaryOpNode):
    #         """Unary op"""
            self._generate_expr(node.operand)
    #         if node.operator == "-":
                self._emit(OpCode.NEG)
    #         elif node.operator == "not":
                self._emit(OpCode.NOT)

    #     def _generate_parser_unary(self, node: UnaryExprNode):
    #         """Parser unary op"""
            self._generate_expr(node.operand)
    #         if node.operator == "-":
                self._emit(OpCode.NEG)

    #     def _generate_if(self, node: IfNode):
    #         """If/else with jumps"""
    else_label = f"else_{id(node)}"
    end_label = f"end_{id(node)}"

            self._generate_expr(node.condition)
            self._emit(OpCode.JZ, else_label)

    #         # Then
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
    #         for stmt in node.then_body:
                self._generate_statement(stmt)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self._emit(OpCode.JMP, end_label)

            self._define_label(else_label)
    #         if node.else_body:
    #             if self.symbol_table:
                    self.symbol_table.enter_scope()
    #             for stmt in node.else_body:
                    self._generate_statement(stmt)
    #             if self.symbol_table:
                    self.symbol_table.exit_scope()

            self._define_label(end_label)

    #     def _generate_parser_if(self, node: IfStmtNode):
    #         """Parser if/else with jumps"""
    else_label = f"else_{id(node)}"
    end_label = f"end_{id(node)}"

            self._generate_expr(node.condition)
            self._emit(OpCode.JZ, else_label)

    #         # Then
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
            self._generate_statement(node.then_branch)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self._emit(OpCode.JMP, end_label)

            self._define_label(else_label)
    #         if node.else_branch:
    #             if self.symbol_table:
                    self.symbol_table.enter_scope()
                self._generate_statement(node.else_branch)
    #             if self.symbol_table:
                    self.symbol_table.exit_scope()

            self._define_label(end_label)

    #     def _generate_while(self, node: WhileNode):
    #         """While loop"""
    start_label = f"while_start_{id(node)}"
    end_label = f"while_end_{id(node)}"

            self._define_label(start_label)
            self._generate_expr(node.condition)
            self._emit(OpCode.JZ, end_label)

            self.loop_stack.append((start_label, end_label))
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
    #         for stmt in node.body:
                self._generate_statement(stmt)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self.loop_stack.pop()

            self._emit(OpCode.JMP, start_label)
            self._define_label(end_label)

    #     def _generate_parser_while(self, node: WhileStmtNode):
    #         """Parser while loop"""
    start_label = f"while_start_{id(node)}"
    end_label = f"while_end_{id(node)}"

            self._define_label(start_label)
            self._generate_expr(node.condition)
            self._emit(OpCode.JZ, end_label)

            self.loop_stack.append((start_label, end_label))
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
            self._generate_statement(node.body)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self.loop_stack.pop()

            self._emit(OpCode.JMP, start_label)
            self._define_label(end_label)

    #     def _generate_for(self, node: ForNode):
    #         """For loop"""
    iter_label = f"for_iter_{id(node)}"
    end_label = f"for_end_{id(node)}"

            self._generate_expr(node.iterable)
            self._emit(OpCode.DUP)  # Keep iter

            self._define_label(iter_label)
            # Simplified: assume iter.next() via CALL or custom
            self._emit(OpCode.CALL, "iter_next")  # Placeholder
            self._emit(OpCode.JZ, end_label)

    offset = self._allocate_var(node.variable.name)
            self._emit(OpCode.STORE, offset)

            self.loop_stack.append((iter_label, end_label))
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
    #         for stmt in node.body:
                self._generate_statement(stmt)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self.loop_stack.pop()

            self._emit(OpCode.JMP, iter_label)
            self._define_label(end_label)
            self._emit(OpCode.POP)  # Clean iter

    #     def _generate_parser_for(self, node: ForStmtNode):
    #         """Parser for loop"""
    iter_label = f"for_iter_{id(node)}"
    end_label = f"for_end_{id(node)}"

            self._generate_expr(node.iterable)
            self._emit(OpCode.DUP)  # Keep iter

            self._define_label(iter_label)
            # Simplified: assume iter.next() via CALL or custom
            self._emit(OpCode.CALL, "iter_next")  # Placeholder
            self._emit(OpCode.JZ, end_label)

    offset = self._allocate_var(node.variable)
            self._emit(OpCode.STORE, offset)

            self.loop_stack.append((iter_label, end_label))
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
            self._generate_statement(node.body)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self.loop_stack.pop()

            self._emit(OpCode.JMP, iter_label)
            self._define_label(end_label)
            self._emit(OpCode.POP)  # Clean iter

    #     def _generate_function_def(self, node: FunctionDefNode):
    #         """Function: label, prologue, body, ret"""
    func_label = f"{node.name}_{id(node)}"
    self.labels[func_label] = len(self.bytecode)  # Forward def

    #         # Prologue at label
            self._emit(OpCode.ENTER_FRAME, len(node.parameters))

    #         if self.symbol_table:
                self.symbol_table.enter_scope()
            # Store params (assume on stack)
    base_offset = self.next_offset
    #         for i, param in enumerate(node.parameters):
    name = param.name
    offset = math.add(base_offset, i)
    self.local_vars[name] = offset
    #             # Params already pushed by caller

    #         for stmt in node.body:
                self._generate_statement(stmt)
            self._emit(OpCode.RET)

    #         if self.symbol_table:
                self.symbol_table.exit_scope()

    #     def _generate_parser_function_def(self, node: FuncDefNode):
    #         """Parser function: label, prologue, body, ret"""
    func_label = f"{node.name}_{id(node)}"
    self.labels[func_label] = len(self.bytecode)  # Forward def

    #         # Prologue at label
            self._emit(OpCode.ENTER_FRAME, len(node.params))

    #         if self.symbol_table:
                self.symbol_table.enter_scope()
            # Store params (assume on stack)
    base_offset = self.next_offset
    #         for i, param in enumerate(node.params):
    name = param["name"]
    offset = math.add(base_offset, i)
    self.local_vars[name] = offset
    #             # Params already pushed by caller

            self._generate_statement(node.body)
            self._emit(OpCode.RET)

    #         if self.symbol_table:
                self.symbol_table.exit_scope()

    #     def _generate_call(self, node: CallNode):
    #         """Function call"""
    #         if isinstance(node.function, VariableNode):
    #             for arg in node.arguments:
                    self._generate_expr(arg)
                self._emit(OpCode.CALL, len(node.arguments), node.function.name)
    #         else:
                self._generate_expr(node.function)
    #             for arg in node.arguments:
                    self._generate_expr(arg)
                self._emit(OpCode.PYTHON_CALL)

    #     def _generate_parser_call(self, node: CallExprNode):
    #         """Parser function call"""
    #         if isinstance(node.function, IdentifierExprNode):
    #             for arg in node.arguments:
                    self._generate_expr(arg)
                self._emit(OpCode.CALL, len(node.arguments), node.function.name)
    #         else:
                self._generate_expr(node.function)
    #             for arg in node.arguments:
                    self._generate_expr(arg)
                self._emit(OpCode.PYTHON_CALL)

    #     def _generate_return(self, node: ReturnNode):
    #         """Return value"""
    #         if node.value:
                self._generate_expr(node.value)
    #         else:
                self._emit_constant(None)
            self._emit(OpCode.RET)

    #     def _generate_parser_return(self, node: ReturnStmtNode):
    #         """Parser return value"""
    #         if node.value:
                self._generate_expr(node.value)
    #         else:
                self._emit_constant(None)
            self._emit(OpCode.RET)

    #     def _generate_print(self, node: PrintStmtNode):
    #         """Print args"""
    #         for arg in node.arguments:
                self._generate_expr(arg)
            self._emit(OpCode.PRINT, len(node.arguments))

    #     def _generate_import(self, node: ImportNode):
    #         """Import module"""
            self._emit(OpCode.IMPORT_MOD, node.module)
    #         if node.aliases:
    #             for alias in node.aliases:
                    self._emit(OpCode.STORE_GLOB, alias)

    #     def _generate_parser_import(self, node: ImportStmtNode):
    #         """Parser import module"""
            self._emit(OpCode.IMPORT_MOD, node.module)
    #         if node.alias:
                self._emit(OpCode.STORE_GLOB, node.alias)

    #     def _generate_try(self, node: TryNode):
    #         """Try-catch block"""
    #         # Simplified try-catch implementation
    try_label = f"try_{id(node)}"
    catch_label = f"catch_{id(node)}"
    end_label = f"end_{id(node)}"

            self._define_label(try_label)
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
    #         for stmt in node.try_body:
                self._generate_statement(stmt)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self._emit(OpCode.JMP, end_label)

            self._define_label(catch_label)
    #         for var, exc_type, body in node.catch_blocks:
    #             if self.symbol_table:
                    self.symbol_table.enter_scope()
    offset = self._allocate_var(var.name)
                self._emit(OpCode.STORE, offset)
    #             for stmt in body:
                    self._generate_statement(stmt)
    #             if self.symbol_table:
                    self.symbol_table.exit_scope()

            self._define_label(end_label)

    #     def _generate_parser_try(self, node: TryStmtNode):
    #         """Parser try-catch block"""
    #         # Simplified try-catch implementation
    try_label = f"try_{id(node)}"
    catch_label = f"catch_{id(node)}"
    end_label = f"end_{id(node)}"

            self._define_label(try_label)
    #         if self.symbol_table:
                self.symbol_table.enter_scope()
            self._generate_statement(node.body)
    #         if self.symbol_table:
                self.symbol_table.exit_scope()
            self._emit(OpCode.JMP, end_label)

            self._define_label(catch_label)
    #         if node.catch_var:
    offset = self._allocate_var(node.catch_var)
                self._emit(OpCode.STORE, offset)
    #         if node.catch_body:
    #             if self.symbol_table:
                    self.symbol_table.enter_scope()
                self._generate_statement(node.catch_body)
    #             if self.symbol_table:
                    self.symbol_table.exit_scope()

            self._define_label(end_label)

    #     def _generate_list(self, node: ListNode):
    #         """Create list"""
            self._emit(OpCode.CREATE_LIST, len(node.elements))
    temp = self._emit(OpCode.DUP)  # Keep list ref
    #         for elem in node.elements:
                self._generate_expr(elem)
                self._emit(OpCode.APPEND_LIST)
    #         # Pop temp if needed

    #     def _generate_parser_list(self, node: ListExprNode):
    #         """Create list"""
            self._emit(OpCode.CREATE_LIST, len(node.elements))
    temp = self._emit(OpCode.DUP)  # Keep list ref
    #         for elem in node.elements:
                self._generate_expr(elem)
                self._emit(OpCode.APPEND_LIST)
    #         # Pop temp if needed

    #     def _generate_matrix(self, node: MatrixNode):
    #         """Create matrix"""
    #         # Calculate dimensions
    rows = len(node.rows)
    #         cols = len(node.rows[0]) if rows > 0 else 0

    #         # Create matrix with zeros
            self._emit_constant(rows)
            self._emit_constant(cols)
            self._emit(OpCode.MATRIX_ZEROS)

    #         # Fill with values
    #         for i, row in enumerate(node.rows):
    #             for j, elem in enumerate(row):
                    self._emit(OpCode.DUP)  # Duplicate matrix reference
                    self._emit_constant(i)
                    self._emit_constant(j)
                    self._generate_expr(elem)
    #                 # This would need a matrix set instruction
                    self._emit(OpCode.POP)  # Clean up

    #     def _generate_tensor(self, node: TensorNode):
    #         """Create tensor"""
    #         # Create tensor with shape
    shape_str = str(node.shape)
            self._emit_constant(shape_str)
            self._emit_constant(1)  # Default dtype
            self._emit(OpCode.TENSOR_CREATE)

    #         # Fill with values
    #         for i, elem in enumerate(node.data):
                self._emit(OpCode.DUP)  # Duplicate tensor reference
                self._generate_expr(elem)
    #             # This would need a tensor set instruction
                self._emit(OpCode.POP)  # Clean up

    #     def _generate_index(self, node: IndexNode):
    #         """Index operation"""
            self._generate_expr(node.target)
    #         for index in node.indices:
                self._generate_expr(index)
    #         # This would need an index instruction
            self._emit(OpCode.POP)  # Clean up

    #     def _generate_slice(self, node: SliceNode):
    #         """Slice operation"""
            self._generate_expr(node.target)
    #         if node.start:
                self._generate_expr(node.start)
    #         else:
                self._emit_constant(0)
    #         if node.stop:
                self._generate_expr(node.stop)
    #         else:
                self._emit_constant(-1)  # End of sequence
    #         if node.step:
                self._generate_expr(node.step)
    #         else:
                self._emit_constant(1)
    #         # This would need a slice instruction
            self._emit(OpCode.POP)  # Clean up

    #     def _define_label(self, label: str):
    #         """Set label position"""
    self.labels[label] = len(self.bytecode)
    #         # Patch pending refs
    #         if label in self.label_refs:
    #             for ref_idx in self.label_refs[label]:
    #                 if ref_idx < len(self.bytecode):
    offset = math.subtract(self.labels[label], ref_idx)
    self.bytecode[ref_idx].operands[0] = offset
    #             del self.label_refs[label]

    #     def _emit_jump(self, opcode: OpCode, label: str) -> int:
    #         """Emit jump to label, return instr idx for patching"""
    idx = self._emit(opcode, 0)  # Temp offset
    #         if label not in self.labels:
    #             if label not in self.label_refs:
    self.label_refs[label] = []
                self.label_refs[label].append(idx)
    #         else:
    offset = math.subtract(self.labels[label], idx)
    self.bytecode[idx].operands[0] = offset
    #         return idx

    #     def _resolve_labels(self):
    #         """Patch unresolved labels"""
    #         for label, refs in list(self.label_refs.items()):
    #             if label in self.labels:
    target = self.labels[label]
    #                 for ref in refs:
    #                     if ref < len(self.bytecode):
    offset = math.subtract(target, ref)
    self.bytecode[ref].operands[0] = offset
    #                 del self.label_refs[label]
    #             else:
    #                 # Error: set to halt or nop
    #                 for ref in refs:
    #                     if ref < len(self.bytecode):
    self.bytecode[ref].operands[0] = 0  # Relative to self

    #     def reset(self):
    #         """Reset state"""
    self.bytecode = []
    self.constants = []
    self.labels = {}
    self.label_refs = {}
    self.local_vars = {}
    self.global_vars = {}
    self.next_offset = 0
    self.symbol_table = None
    self.current_scope_depth = 0
    self.function_stack = []
    self.loop_stack = []

    #     def compile_to_bytecode(self, instructions: List[Instruction]) -> bytes:
    #         """Compile NBC runtime instructions to bytecode"""
    program = self.bytecode_processor.compile(instructions, BytecodeFormat.NBC)

    #         # Find code section
    #         code_section = next((s for s in program.sections if s.name == "code"), None)

    #         if code_section is None:
                raise ValueError("No code section found in compiled program")

    #         return code_section.data

    #     def save_bytecode(self, filename: str, instructions: List[Instruction]):
    #         """Save bytecode to file"""
    bytecode = self.compile_to_bytecode(instructions)
    #         with open(filename, "wb") as f:
                f.write(bytecode)


def generate_bytecode(
#     ast: ASTNode, symbol_table: SymbolTable
# ) -> List[Instruction]:
#     """Convenience: generate from AST and symbol table"""
generator = CodeGenerator()
    return generator.generate(ast, symbol_table)
