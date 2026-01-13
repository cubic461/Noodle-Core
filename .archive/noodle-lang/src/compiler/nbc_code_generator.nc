# Converted from Python to NoodleCore
# Original file: src

# """
# NBC Bytecode Code Generator for Noodle Compiler
# ----------------------------------------------
# This module implements the code generation phase of the Noodle compiler.
It converts the AST into NBC (Noodle Bytecode) instructions.
# """

import hashlib
import struct
from dataclasses import dataclass
import enum.Enum
import typing.Any

import ...error.CodeGenerationError

# Import from existing modules
import .ast_nodes.(
#     AssignmentNode,
#     ASTNode,
#     AsyncNode,
#     AwaitNode,
#     BinaryOpNode,
#     CallNode,
#     ClassDefNode,
#     DecoratorNode,
#     ExpressionNode,
#     ForNode,
#     FunctionDefNode,
#     IfNode,
#     ImportNode,
#     IndexNode,
#     ListNode,
#     MatrixNode,
#     NodeType,
#     ParameterNode,
#     ProgramNode,
#     PropertyDefNode,
#     RaiseNode,
#     ReturnNode,
#     SliceNode,
#     StatementNode,
#     TensorNode,
#     TryNode,
#     UnaryOpNode,
#     VariableNode,
#     WhileNode,
# )
import .semantic_analyzer.Symbol
import .types.BasicType


class OpCode(Enum)
    #     """NBC Operation Codes"""

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
    ABS = 0x17  # Absolute value

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
    XOR = 0x33  # Logical XOR

    #     # Control flow
    JMP = 0x40  # Unconditional jump
    #     JZ = 0x41  # Jump if zero
    #     JNZ = 0x42  # Jump if not zero
    CALL = 0x43  # Function call
    RET = 0x44  # Return from function

    #     # Variable operations
    LOAD = 0x50  # Load variable value
    STORE = 0x51  # Store variable value
    VAR_DECL = 0x52  # Declare variable
    CONST_DECL = 0x53  # Declare constant

    #     # Array/Matrix operations
    ARRAY_NEW = 0x60  # Create new array
    ARRAY_LEN = 0x61  # Get array length
    ARRAY_GET = 0x62  # Get array element
    ARRAY_SET = 0x63  # Set array element
    ARRAY_PUSH = 0x64  # Push to array
    ARRAY_POP = 0x65  # Pop from array

    #     # Matrix operations
    MATRIX_NEW = 0x70  # Create new matrix
    MATRIX_ROWS = 0x71  # Get matrix rows
    MATRIX_COLS = 0x72  # Get matrix columns
    MATRIX_GET = 0x73  # Get matrix element
    MATRIX_SET = 0x74  # Set matrix element
    MATRIX_ADD = 0x75  # Matrix addition
    MATRIX_SUB = 0x76  # Matrix subtraction
    MATRIX_MUL = 0x77  # Matrix multiplication
    MATRIX_TRANSPOSE = 0x78  # Matrix transpose
    MATRIX_DET = 0x79  # Matrix determinant
    MATRIX_INV = 0x7A  # Matrix inverse

    #     # Tensor operations
    TENSOR_NEW = 0x80  # Create new tensor
    TENSOR_SHAPE = 0x81  # Get tensor shape
    TENSOR_GET = 0x82  # Get tensor element
    TENSOR_SET = 0x83  # Set tensor element
    TENSOR_RESHAPE = 0x84  # Reshape tensor

    #     # I/O operations
    PRINT = 0x90  # Print value
    READ = 0x91  # Read input

    #     # Special operations
    NOP = 0xF0  # No operation
    HALT = 0xF1  # Halt execution
    DEBUG = 0xF2  # Debug breakpoint


dataclass
class Instruction
    #     """Represents an NBC instruction"""

    #     opcode: OpCode
    operands: List[Any] = field(default_factory=list)
    #     position: Optional[Any] = None  # Source position for debugging

    #     def to_bytes(self) -bytes):
    #         """Convert instruction to bytes"""
    #         # Opcode as 1 byte
    result = bytes([self.opcode.value])

    #         # Add operands based on type
    #         for operand in self.operands:
    #             if isinstance(operand, int):
    #                 # 4-byte integer
    result + = struct.pack("<i", operand)
    #             elif isinstance(operand, float):
    #                 # 8-byte float
    result + = struct.pack("<d", operand)
    #             elif isinstance(operand, str):
    #                 # String with length prefix
    encoded = operand.encode("utf-8")
    result + = struct.pack("<H", len(encoded))
    result + = encoded
    #             elif isinstance(operand, bool):
    #                 # Boolean as byte
    #                 result += bytes([1 if operand else 0])
    #             else:
                    raise CodeGenerationError(f"Unsupported operand type: {type(operand)}")

    #         return result

    #     def __str__(self):
    #         operands_str = ", ".join(str(op) for op in self.operands)
            return f"{self.opcode.name}({operands_str})"


dataclass
class FunctionCode
    #     """Represents compiled function code"""

    #     name: str
    #     instructions: List[Instruction]
    #     locals: List[str]
    #     parameters: List[str]
    #     return_type: Optional[Type]
    stack_size: int = 0
    max_stack_depth: int = 0

    #     def to_bytes(self) -bytes):
    #         """Convert function code to bytes"""
    #         # Function header
    result = struct.pack("<H", len(self.name))
    result + = self.name.encode("utf-8")

    #         # Parameters
    result + = struct.pack("<B", len(self.parameters))
    #         for param in self.parameters:
    result + = struct.pack("<H", len(param))
    result + = param.encode("utf-8")

    #         # Local variables
    result + = struct.pack("<H", len(self.locals))
    #         for local in self.locals:
    result + = struct.pack("<H", len(local))
    result + = local.encode("utf-8")

    #         # Return type
    #         if self.return_type:
    result + = struct.pack("<B", 1)  # Has return type
    #             # In a full implementation, we would serialize the type
    result + = struct.pack("<B", 0)  # Placeholder
    #         else:
    result + = struct.pack("<B", 0)  # No return type

    #         # Stack size
    result + = struct.pack("<H", self.stack_size)
    result + = struct.pack("<H", self.max_stack_depth)

    #         # Instructions
    result + = struct.pack("<I", len(self.instructions))
    #         for instr in self.instructions:
    result + = instr.to_bytes()

    #         return result


class NBCCodeGenerator
    #     """Generates NBC bytecode from AST"""

    #     def __init__(self, symbol_table: Optional[SymbolTable] = None):
    self.symbol_table = symbol_table or SymbolTable()
    self.functions: Dict[str, FunctionCode] = {}
    self.current_function: Optional[FunctionCode] = None
    self.current_instructions: List[Instruction] = []
    self.label_counter = 0
    self.variable_offsets: Dict[str, int] = {}
    self.stack_depth = 0
    self.max_stack_depth = 0
    self.string_literals: Dict[str, int] = {}
    self.literal_counter = 0
    self.imported_modules: Set[str] = set()

    #     def generate(self, node: ASTNode) -Dict[str, FunctionCode]):
    #         """Generate NBC bytecode from AST"""
            self.functions.clear()
    self.current_function = None
    self.current_instructions = []
    self.label_counter = 0
            self.variable_offsets.clear()
    self.stack_depth = 0
    self.max_stack_depth = 0
            self.string_literals.clear()
    self.literal_counter = 0
            self.imported_modules.clear()

    #         # Generate code for the main program
            self._generate_program(node)

    #         # Create main function if it doesn't exist
    #         if "main" not in self.functions:
                self._create_main_function()

    #         return self.functions

    #     def _generate_program(self, node: ASTNode):
    #         """Generate code for a program node"""
    #         if isinstance(node, ProgramNode):
    #             # Create main function
    self.current_function = FunctionCode(
    name = "main", instructions=[], locals=[], parameters=[], return_type=None
    #             )
    self.functions["main"] = self.current_function
    self.current_instructions = self.current_function.instructions

    #             # Generate code for each statement
    #             for statement in node.statements:
                    self._generate_statement(statement)

    #             # Add return at the end of main
                self._emit(OpCode.RET)

    #     def _create_main_function(self):
    #         """Create a default main function"""
    main_function = FunctionCode(
    name = "main", instructions=[], locals=[], parameters=[], return_type=None
    #         )
    self.functions["main"] = main_function
    self.current_instructions = main_function.instructions

    #         # Add a simple return instruction
            self._emit(OpCode.RET)

    #     def _generate_statement(self, node: StatementNode):
    #         """Generate code for a statement node"""
    method_name = f"_generate_{node.node_type.value.lower()}"
    generator = getattr(self, method_name, self._generate_statement_default)
            generator(node)

    #     def _generate_statement_default(self, node: StatementNode):
    #         """Default statement generation"""
    #         for child in node.get_children():
    #             if isinstance(child, StatementNode):
                    self._generate_statement(child)
    #             elif isinstance(child, ExpressionNode):
                    self._generate_expression(child)
    #                 # Pop expression result if not used
                    self._emit(OpCode.POP)

    #     def _generate_functiondef(self, node: FunctionDefNode):
    #         """Generate code for a function definition"""
    #         # Create new function
    function = FunctionCode(
    name = node.name,
    instructions = [],
    locals = [],
    #             parameters=[param.name for param in node.parameters],
    return_type = node.return_type,
    #         )
    self.functions[node.name] = function

    #         # Set as current function
    old_function = self.current_function
    old_instructions = self.current_instructions

    self.current_function = function
    self.current_instructions = function.instructions

    #         # Allocate space for parameters and locals
            self._allocate_function_locals(node)

    #         # Generate function body
    #         for statement in node.body:
                self._generate_statement(statement)

    #         # Add return if function doesn't have one
    #         if not self._has_return_statement(node):
                self._emit(OpCode.RET)

    #         # Calculate stack usage
    function.stack_size = self.max_stack_depth
    function.max_stack_depth = self.max_stack_depth

    #         # Restore current function
    self.current_function = old_function
    self.current_instructions = old_instructions

    #     def _allocate_function_locals(self, node: FunctionDefNode):
    #         """Allocate space for function parameters and locals"""
    offset = 0

            # Parameters (negative offsets)
    #         for param in reversed(node.parameters):
    offset - = 1
    self.variable_offsets[param.name] = offset

            # Local variables (positive offsets)
    #         for child in node.get_children():
    #             if isinstance(child, VariableNode):
    #                 if child.name not in self.variable_offsets:
    offset + = 1
    self.variable_offsets[child.name] = offset
                        self.current_function.locals.append(child.name)

    #         # Update stack depth
    self.stack_depth = max(0, offset)
    self.max_stack_depth = max(self.max_stack_depth, self.stack_depth)

    #     def _has_return_statement(self, node: FunctionDefNode) -bool):
    #         """Check if function has return statements"""
    #         for statement in node.body:
    #             if isinstance(statement, ReturnNode):
    #                 return True
    #             elif isinstance(statement, IfNode):
    #                 if self._has_return_in_branch(statement.then_body):
    #                     return True
    #                 if statement.else_body and self._has_return_in_branch(
    #                     statement.else_body
    #                 ):
    #                     return True
    #         return False

    #     def _has_return_in_branch(self, statements: List[StatementNode]) -bool):
    #         """Check if a branch has return statements"""
    #         for statement in statements:
    #             if isinstance(statement, ReturnNode):
    #                 return True
    #             elif isinstance(statement, IfNode):
    #                 if self._has_return_in_branch(statement.then_body):
    #                     return True
    #                 if statement.else_body and self._has_return_in_branch(
    #                     statement.else_body
    #                 ):
    #                     return True
    #         return False

    #     def _generate_call(self, node: CallNode):
    #         """Generate code for a function call"""
    #         # Push arguments in reverse order
    #         for arg in reversed(node.arguments):
                self._generate_expression(arg)

    #         # Generate function address
    #         if isinstance(node.function, VariableNode):
    #             # Direct function call
                self._emit(OpCode.CALL, [node.function.name])
    #         else:
                # Indirect function call (function pointer)
                self._generate_expression(node.function)
                self._emit(OpCode.CALL, [0])  # 0 means indirect call

    #     def _generate_binaryop(self, node: BinaryOpNode):
    #         """Generate code for a binary operation"""
    #         # Generate left operand
            self._generate_expression(node.left)

    #         # Generate right operand
            self._generate_expression(node.right)

    #         # Generate operation
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
    "= "): OpCode.GE,
    #             "&&": OpCode.AND,
    #             "||": OpCode.OR,
    #             "and": OpCode.AND,
    #             "or": OpCode.OR,
    #         }

    #         if node.operator in op_map:
                self._emit(op_map[node.operator])
    #         else:
                raise CodeGenerationError(f"Unsupported binary operator: {node.operator}")

    #     def _generate_unaryop(self, node: UnaryOpNode):
    #         """Generate code for a unary operation"""
    #         # Generate operand
            self._generate_expression(node.operand)

    #         # Generate operation
    op_map = {
    #             "-": OpCode.NEG,
    #             "!": OpCode.NOT,
    #             "not": OpCode.NOT,
    #         }

    #         if node.operator in op_map:
                self._emit(op_map[node.operator])
    #         else:
                raise CodeGenerationError(f"Unsupported unary operator: {node.operator}")

    #     def _generate_assignment(self, node: AssignmentNode):
    #         """Generate code for an assignment"""
    #         # Generate value
            self._generate_expression(node.value)

    #         # Store in variable
    #         if isinstance(node.target, VariableNode):
                self._emit(OpCode.STORE, [self.variable_offsets[node.target.name]])
    #         elif isinstance(node.target, IndexNode):
    #             # Generate target address
                self._generate_expression(node.target.target)

    #             # Generate indices
    #             for index in node.target.indices:
    #                 if isinstance(index, SliceNode):
                        self._generate_slice(index)
    #                 else:
                        self._generate_expression(index)

    #             # Store value
                self._emit(OpCode.ARRAY_SET)
    #         else:
                raise CodeGenerationError(
                    f"Unsupported assignment target: {type(node.target)}"
    #             )

    #     def _generate_variable(self, node: VariableNode):
    #         """Generate code for a variable reference"""
    #         if node.name in self.variable_offsets:
                self._emit(OpCode.LOAD, [self.variable_offsets[node.name]])
    #         else:
                raise CodeGenerationError(f"Undefined variable: {node.name}")

    #     def _generate_if(self, node: IfNode):
    #         """Generate code for an if statement"""
    #         # Generate condition
            self._generate_expression(node.condition)

    #         # Create labels
    else_label = self._new_label()
    end_label = self._new_label()

    #         # Jump to else if false
            self._emit(OpCode.JZ, [else_label])

    #         # Generate then body
    #         for statement in node.then_body:
                self._generate_statement(statement)

    #         # Jump to end
            self._emit(OpCode.JMP, [end_label])

    #         # Generate else body
            self._emit_label(else_label)
    #         if node.else_body:
    #             for statement in node.else_body:
                    self._generate_statement(statement)

    #         # Generate end label
            self._emit_label(end_label)

    #     def _generate_while(self, node: WhileNode):
    #         """Generate code for a while loop"""
    #         # Create labels
    start_label = self._new_label()
    end_label = self._new_label()

    #         # Generate start label
            self._emit_label(start_label)

    #         # Generate condition
            self._generate_expression(node.condition)

    #         # Jump to end if false
            self._emit(OpCode.JZ, [end_label])

    #         # Generate body
    #         for statement in node.body:
                self._generate_statement(statement)

    #         # Jump back to start
            self._emit(OpCode.JMP, [start_label])

    #         # Generate end label
            self._emit_label(end_label)

    #     def _generate_for(self, node: ForNode):
    #         """Generate code for a for loop"""
    #         # Create iterator
            self._generate_expression(node.iterable)
            self._emit(OpCode.ARRAY_NEW)  # Create iterator

    #         # Create labels
    start_label = self._new_label()
    end_label = self._new_label()

    #         # Generate start label
            self._emit_label(start_label)

    #         # Get next element
            self._emit(OpCode.ARRAY_GET)

    #         # Store in variable
            self._emit(OpCode.STORE, [self.variable_offsets[node.variable.name]])

    #         # Check if end
            self._emit(OpCode.JZ, [end_label])

    #         # Generate body
    #         for statement in node.body:
                self._generate_statement(statement)

    #         # Jump back to start
            self._emit(OpCode.JMP, [start_label])

    #         # Generate end label
            self._emit_label(end_label)

    #     def _generate_return(self, node: ReturnNode):
    #         """Generate code for a return statement"""
    #         if node.value:
                self._generate_expression(node.value)

            self._emit(OpCode.RET)

    #     def _generate_literal(self, node):
    #         """Generate code for a literal value"""
    #         if isinstance(node.value, (int, float)):
                self._emit(OpCode.PUSH, [node.value])
    #         elif isinstance(node.value, str):
    #             # Handle string literals
    #             if node.value not in self.string_literals:
    self.string_literals[node.value] = self.literal_counter
    self.literal_counter + = 1
                self._emit(OpCode.PUSH, [self.string_literals[node.value]])
    #         elif isinstance(node.value, bool):
    #             self._emit(OpCode.PUSH, [1 if node.value else 0])
    #         elif node.value is None:
                self._emit(OpCode.PUSH, [0])
    #         else:
                raise CodeGenerationError(f"Unsupported literal type: {type(node.value)}")

    #     def _generate_list(self, node):
    #         """Generate code for a list literal"""
    #         # Create empty list
            self._emit(OpCode.ARRAY_NEW)

    #         # Add elements
    #         for element in node.elements:
                self._generate_expression(element)
                self._emit(OpCode.ARRAY_PUSH)

    #     def _generate_matrix(self, node):
    #         """Generate code for a matrix literal"""
    #         # Create matrix
    rows = len(node.rows)
    #         cols = len(node.rows[0]) if rows 0 else 0

            self._emit(OpCode.MATRIX_NEW, [rows, cols])

    #         # Set elements
    #         for i, row in enumerate(node.rows)):
    #             for j, element in enumerate(row):
                    self._generate_expression(element)
                    self._emit(OpCode.MATRIX_SET, [i, j])

    #     def _generate_index(self, node):
    #         """Generate code for an indexing operation"""
    #         # Generate target
            self._generate_expression(node.target)

    #         # Generate indices
    #         for index in node.indices:
    #             if isinstance(index, SliceNode):
                    self._generate_slice(index)
    #             else:
                    self._generate_expression(index)

    #         # Get element
            self._emit(OpCode.ARRAY_GET)

    #     def _generate_slice(self, node):
    #         """Generate code for a slice operation"""
    #         # Generate start, stop, step
    #         if node.start:
                self._generate_expression(node.start)
    #         else:
                self._emit(OpCode.PUSH, [0])

    #         if node.stop:
                self._generate_expression(node.stop)
    #         else:
                self._emit(OpCode.PUSH, [0])

    #         if node.step:
                self._generate_expression(node.step)
    #         else:
                self._emit(OpCode.PUSH, [1])

    #     def _generate_expression(self, node: ExpressionNode):
    #         """Generate code for an expression node"""
    method_name = f"_generate_{node.node_type.value.lower()}"
    generator = getattr(self, method_name, self._generate_expression_default)
            generator(node)

    #     def _generate_expression_default(self, node: ExpressionNode):
    #         """Default expression generation"""
    #         for child in node.get_children():
    #             if isinstance(child, ExpressionNode):
                    self._generate_expression(child)

    #     def _emit(self, opcode: OpCode, operands: List[Any] = None):
    #         """Emit an instruction"""
    instruction = Instruction(opcode, operands or [])
            self.current_instructions.append(instruction)

    #         # Update stack depth
    #         if opcode == OpCode.PUSH:
    self.stack_depth + = 1
    #         elif opcode == OpCode.POP:
    self.stack_depth - = 1
    #         elif opcode == OpCode.CALL:
    self.stack_depth - = len(operands)  # Arguments
    #             # In a full implementation, we would account for return address
    #         elif opcode == OpCode.RET:
    self.stack_depth = 0  # Reset stack on return

    self.max_stack_depth = max(self.max_stack_depth, self.stack_depth)

    #     def _emit_label(self, label: int):
    #         """Emit a label (placeholder for jump targets)"""
    #         # In a full implementation, we would handle labels properly
    #         pass

    #     def _new_label(self) -int):
    #         """Create a new label"""
    label = self.label_counter
    self.label_counter + = 1
    #         return label

    #     def get_bytecode(self) -Dict[str, bytes]):
    #         """Get bytecode for all functions"""
    #         return {name: func.to_bytes() for name, func in self.functions.items()}

    #     def get_function_count(self) -int):
    #         """Get the number of compiled functions"""
            return len(self.functions)

    #     def get_instruction_count(self) -int):
    #         """Get the total number of instructions"""
    #         return sum(len(func.instructions) for func in self.functions.values())
