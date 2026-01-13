# Converted from Python to NoodleCore
# Original file: src

# """
# Bytecode Generation for Noodle Programming Language
# ---------------------------------------------------
# This module implements bytecode generation for the Noodle code generator.
# It converts AST nodes to bytecode instructions.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import typing.List
import .code_generator_opcodes.OpCode
import .parser_ast_nodes.(
#     ASTNode,
#     ProgramNode,
#     StatementNode,
#     ExpressionNode,
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
#     MemberExprNode,
#     ParenExprNode,
#     ListExprNode,
#     DictExprNode,
#     SliceExprNode,
#     TernaryExprNode,
#     NodeType,
# )


class BytecodeGenerator
    #     """Generates bytecode from AST nodes"""

    #     def __init__(self):
    self.bytecode: List[BytecodeInstruction] = []
    self.constants: List[Any] = []
    self.labels: Dict[str, int] = {}
    self.label_refs: Dict[str, List[int]] = {}
    self.local_vars: Dict[str, int] = {}
    self.next_offset = 0
    self.symbol_table = None
    self.current_scope_depth = 0

    #     def generate(
    self, ast: ASTNode, symbol_table: Optional[Dict[str, Any]] = None, target_format: str = "nbc"
    #     ) -List[BytecodeInstruction]):
    #         """
    #         Generate bytecode from validated AST using symbol table for scopes/types.

    #         Args:
    #             ast: Validated AST root
    #             symbol_table: Semantic symbol table for variable resolution
    #             target_format: 'nbc' for bytecode

    #         Returns:
    #             List of BytecodeInstructions
    #         """
    self.symbol_table = symbol_table
    self.bytecode = []
    self.constants = []
    self.labels = {}
    self.label_refs = {}
    self.local_vars = {}
    self.next_offset = 0
    self.current_scope_depth = 0

    #         if isinstance(ast, ProgramNode):
                self._generate_program(ast)
    #         else:
                self._generate_statement(ast)

    #         # Resolve labels
            self._resolve_labels()

    #         # Ensure halt
    #         if not self.bytecode or self.bytecode[-1].opcode != OpCode.HALT:
                self._emit(OpCode.HALT)

    #         if target_format == "nbc":
    #             return self.bytecode
            raise ValueError(f"Unsupported target: {target_format}")

    #     def _generate_program(self, program: ProgramNode):
    #         """Generate code for entire program"""
    #         # Global scope
            self.symbol_table.enter_scope()
    #         for stmt in program.children:
                self._generate_statement(stmt)
            self.symbol_table.exit_scope()
    #         # Entry point call if main, but assume top-level exec

    #     def _generate_statement(self, stmt: StatementNode):
    #         """Dispatch to statement handlers"""
    #         if stmt.node_type == NodeType.VAR_DECL:
                self._generate_var_decl(stmt)
    #         elif stmt.node_type == NodeType.ASSIGN_STMT:
                self._generate_assign(stmt)
    #         elif stmt.node_type == NodeType.EXPR_STMT:
                self._generate_expr(stmt.expression)
                self._emit(OpCode.POP)  # Discard result
    #         elif stmt.node_type == NodeType.IF_STMT:
                self._generate_if(stmt)
    #         elif stmt.node_type == NodeType.WHILE_STMT:
                self._generate_while(stmt)
    #         elif stmt.node_type == NodeType.FOR_STMT:
                self._generate_for(stmt)
    #         elif stmt.node_type == NodeType.FUNC_DEF:
                self._generate_func_def(stmt)
    #         elif stmt.node_type == NodeType.RETURN_STMT:
                self._generate_return(stmt)
    #         elif stmt.node_type == NodeType.PRINT_STMT:
                self._generate_print(stmt)
    #         elif stmt.node_type == NodeType.IMPORT_STMT:
                self._generate_import(stmt)
    #         elif stmt.node_type == NodeType.COMPOUND_STMT:
                self.symbol_table.enter_scope()
    self.current_scope_depth + = 1
    #             for sub_stmt in stmt.statements:
                    self._generate_statement(sub_stmt)
                self.symbol_table.exit_scope()
    self.current_scope_depth - = 1
    #         else:
    #             # Unknown: nop
    #             pass

    #     def _generate_expr(self, expr: ExpressionNode):
    #         """Generate code for expressions"""
    #         if expr.node_type == NodeType.LITERAL_EXPR:
                self._generate_literal(expr)
    #         elif expr.node_type == NodeType.IDENTIFIER_EXPR:
                self._generate_load_var(expr.name)
    #         elif expr.node_type == NodeType.BINARY_EXPR:
                self._generate_binary(expr)
    #         elif expr.node_type == NodeType.UNARY_EXPR:
                self._generate_unary(expr)
    #         elif expr.node_type == NodeType.CALL_EXPR:
                self._generate_call(expr)
    #         elif expr.node_type == NodeType.LIST_EXPR:
                self._generate_list(expr)
    #         elif expr.node_type == NodeType.DICT_EXPR:
                self._generate_dict(expr)
    #         else:
    #             # Default: push None
                self._emit_constant(None)

    #     def _emit(self, opcode: OpCode, *operands) -int):
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

    #     def _allocate_var(self, name: str) -int):
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

    #     def _generate_assign(self, node: AssignStmtNode):
    #         """Assignment: load target offset, store value"""
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
                self._emit_constant(None)  # Undefined

    #     def _generate_literal(self, node: LiteralExprNode):
    #         """Push literal constant"""
            self._emit_constant(node.value)

    #     def _generate_binary(self, node: BinaryExprNode):
    #         """Binary op: eval left, right, apply op"""
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
    "= "): OpCode.GE,
    #         }
    #         if node.operator in op_map:
                self._emit(op_map[node.operator])
    #         else:
                self._emit(OpCode.POP)
                self._emit(OpCode.POP)
                self._emit_constant(None)

    #     def _generate_unary(self, node: UnaryExprNode):
    #         """Unary op"""
            self._generate_expr(node.operand)
    #         if node.operator == "-":
                self._emit(OpCode.NEG)
    #         # Add NOT if needed

    #     def _generate_if(self, node: IfStmtNode):
    #         """If/else with jumps"""
    else_label = f"else_{id(node)}"
    end_label = f"end_{id(node)}"

            self._generate_expr(node.condition)
            self._emit(OpCode.JZ, else_label)

    #         # Then
            self.symbol_table.enter_scope()
            self._generate_statement(node.then_branch)
            self.symbol_table.exit_scope()
            self._emit(OpCode.JMP, end_label)

            self._define_label(else_label)
    #         if node.else_branch:
                self.symbol_table.enter_scope()
                self._generate_statement(node.else_branch)
                self.symbol_table.exit_scope()

            self._define_label(end_label)

    #     def _generate_while(self, node: WhileStmtNode):
    #         """While loop"""
    start_label = f"while_start_{id(node)}"
    end_label = f"while_end_{id(node)}"

            self._define_label(start_label)
            self._generate_expr(node.condition)
            self._emit(OpCode.JZ, end_label)

            self.symbol_table.enter_scope()
            self._generate_statement(node.body)
            self.symbol_table.exit_scope()

            self._emit(OpCode.JMP, start_label)
            self._define_label(end_label)

    #     def _generate_for(self, node: ForStmtNode):
    #         """Simple for: assume list iter"""
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

            self.symbol_table.enter_scope()
            self._generate_statement(node.body)
            self.symbol_table.exit_scope()

            self._emit(OpCode.JMP, iter_label)
            self._define_label(end_label)
            self._emit(OpCode.POP)  # Clean iter

    #     def _generate_func_def(self, node: FuncDefNode):
    #         """Function: label, prologue, body, ret"""
    func_label = f"{node.name}_{id(node)}"
    self.labels[func_label] = len(self.bytecode)  # Forward def

    #         # Prologue at label
            self._emit(OpCode.ENTER_FRAME, len(node.params))

            self.symbol_table.enter_scope()
            # Store params (assume on stack)
    base_offset = self.next_offset
    #         for i, param in enumerate(node.params):
    name = param["name"]
    offset = base_offset + i
    self.local_vars[name] = offset
    #             # Params already pushed by caller

            self._generate_statement(node.body)
            self._emit(OpCode.RET)

            self.symbol_table.exit_scope()

    #     def _generate_call(self, node: CallExprNode):
    #         """Function call"""
    #         if isinstance(node.function, IdentifierExprNode):
    #             for arg in node.arguments:
                    self._generate_expr(arg)
                self._emit(OpCode.CALL, len(node.arguments), node.function.name)
    #         else:
                self._generate_expr(node.function)
    #             for arg in node.arguments:
                    self._generate_expr(arg)
                self._emit(OpCode.PYTHON_CALL)

    #     def _generate_return(self, node: ReturnStmtNode):
    #         """Return value"""
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

    #     def _generate_import(self, node: ImportStmtNode):
    #         """Import module"""
            self._emit(OpCode.IMPORT_MOD, node.module)
    #         if node.alias:
                self._emit(OpCode.STORE_GLOB, node.alias)

    #     def _generate_list(self, node: ListExprNode):
    #         """Create list"""
            self._emit(OpCode.CREATE_LIST, len(node.elements))
    temp = self._emit(OpCode.DUP)  # Keep list ref
    #         for elem in node.elements:
                self._generate_expr(elem)
                self._emit(OpCode.APPEND_LIST)
    #         # Pop temp if needed

    #     def _generate_dict(self, node: DictExprNode):
    #         """Create dict"""
            self._emit(OpCode.CREATE_DICT, len(node.pairs))
    #         for pair in node.pairs:
    key, val = (
    #                 pair
    #                 if isinstance(pair, tuple)
                    else (pair.get("key"), pair.get("value"))
    #             )
                self._generate_expr(key)
                self._generate_expr(val)
                self._emit(OpCode.SET_DICT)

    #     def _define_label(self, label: str):
    #         """Set label position"""
    self.labels[label] = len(self.bytecode)
    #         # Patch pending refs
    #         if label in self.label_refs:
    #             for ref_idx in self.label_refs[label]:
    #                 if ref_idx < len(self.bytecode):
    offset = self.labels[label] - ref_idx
    self.bytecode[ref_idx].operands[0] = offset
    #             del self.label_refs[label]

    #     def _emit_jump(self, opcode: OpCode, label: str) -int):
    #         """Emit jump to label, return instr idx for patching"""
    idx = self._emit(opcode, 0)  # Temp offset
    #         if label not in self.labels:
    #             if label not in self.label_refs:
    self.label_refs[label] = []
                self.label_refs[label].append(idx)
    #         else:
    offset = self.labels[label] - idx
    self.bytecode[idx].operands[0] = offset
    #         return idx

    #     def _resolve_labels(self):
    #         """Patch unresolved labels"""
    #         for label, refs in list(self.label_refs.items()):
    #             if label in self.labels:
    target = self.labels[label]
    #                 for ref in refs:
    #                     if ref < len(self.bytecode):
    offset = target - ref
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
    self.next_offset = 0
    self.symbol_table = None
    self.current_scope_depth == 0