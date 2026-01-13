# Converted from Python to NoodleCore
# Original file: noodle-core

import typing.Any,

import ..parser_ast_nodes.(
#     ASTNode,
#     BinaryExprNode,
#     CallExprNode,
#     IdentifierExprNode,
#     LiteralExprNode,
#     ProgramNode,
#     VarDeclNode,
# )
import ..semantic_analyzer_symbol_table.SymbolTable
import ..parser_ast_nodes.Identifier
import .ir.(
#     AddOp,
#     Attribute,
#     Block,
#     ConstantOp,
#     Dialect,
#     LoadOp,
#     Location,
#     Module,
#     Operation,
#     StoreOp,
#     Value,
# )


class NIRBuilder
    #     def __init__(self, symbol_table: SymbolTable):
    self.symbol_table = symbol_table
    self.current_module: Optional[Module] = None
    self.current_block: Optional[Block] = None
    self.values: dict[str, Value] = {}  # Symbol name to Value

    #     def build_from_ast(self, ast: ProgramNode, symbol_table: SymbolTable) -> Module:
    self.symbol_table = symbol_table
    self.current_module = Module(name="main_module")
    self.current_block = Block()
    self.current_module.blocks = [self.current_block]

    #         for node in ast.children:
                self.visit(node)

    #         return self.current_module

    #     def visit(self, node: ASTNode):
    #         if isinstance(node, ProgramNode):
                return self.visit_program(node)
    #         elif isinstance(node, VarDeclNode):
                return self.visit_vardecl(node)
    #         elif isinstance(node, BinaryExprNode):
                return self.visit_binary(node)
    #         elif isinstance(node, CallExprNode):
                return self.visit_call(node)
    #         elif isinstance(node, LiteralExprNode):
                return self.visit_literal(node)
    #         elif isinstance(node, IdentifierExprNode):
                return self.visit_identifier(node)
    #         # Add more as needed

    #     def visit_program(self, node: ProgramNode):
    #         for child in node.children:
                self.visit(child)

    #     def visit_vardecl(self, node: VarDeclNode):
    #         # Visit value to get Value
    #         value = self.visit(node.value) if node.value else None
    #         if not value:
    #             # Default constant 0
    value = self.build_constant(0, "i32")

    #         # Load symbol type
    symbol = self.symbol_table.lookup(node.name)
    #         type_str = symbol.type.value if symbol and symbol.type else "i32"

    #         # Assume global store for simplicity
    ptr_value = Value(f"ptr_{node.name}", type=f"!ptr<{type_str}>")
    store_op = StoreOp(
    #             value,
    #             ptr_value,
    #             Location(line=node.position.line if hasattr(node, "position") else 0),
    #         )
            self.current_block.operations.append(store_op)

    #         # Store result value for future loads
    self.values[node.name] = value

    #     def visit_binary(self, node: BinaryExprNode):
    lhs = self.visit(node.left)
    rhs = self.visit(node.right)

    #         # Only support addition for now, fallback to AddOp for any operator
    #         if node.operator == "+":
    op = AddOp(
    #                 lhs,
    #                 rhs,
    #                 Location(line=node.position.line if hasattr(node, "position") else 0),
    #             )
    #         else:
    #             # For other operators, create a generic operation with the operator name
    op = Operation(
    #                 node.operator,
    #                 Dialect.STD,
    operands = [lhs, rhs],
    location = Location(
    #                     line=node.position.line if hasattr(node, "position") else 0
    #                 ),
    #             )

            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def visit_call(self, node: CallExprNode):
    #         # Build args
    #         args = [self.visit(arg) for arg in node.arguments]
    #         # Assume func is known, build generic operation for function calls
    func_name = (
    #             node.function.name
    #             if isinstance(node.function, IdentifierExprNode)
    #             else node.function.value
    #         )
    call_op = Operation(
    #             "call",
    #             Dialect.STD,
    operands = args,
    attributes = [Attribute("callee", func_name)],
    location = Location(
    #                 line=node.position.line if hasattr(node, "position") else 0
    #             ),
    #         )
            self.current_block.operations.append(call_op)
    #         return call_op.results[0]

    #     def visit_literal(self, node: LiteralExprNode):
    value = node.value
    type_str = (
    #             "i32"
    #             if isinstance(value, int)
    #             else "f64" if isinstance(value, float) else "string"
    #         )
            return self.build_constant(value, type_str)

    #     def visit_identifier(self, node: IdentifierExprNode):
    #         if node.name in self.values:
                # Load from stored value (simplified, assume SSA)
    #             return self.values[node.name]
    symbol = self.symbol_table.lookup(node.name)
    #         if symbol:
    #             # Build LoadOp
    ptr_value = Value(
    #                 f"ptr_{node.name}",
    #                 type=f"!ptr<{symbol.type.value if symbol.type else 'i32'}>",
    #             )
    load_op = LoadOp(
    #                 ptr_value,
    #                 Location(line=node.position.line if hasattr(node, "position") else 0),
    #             )
                self.current_block.operations.append(load_op)
    val = load_op.results[0]
    self.values[node.name] = val
    #             return val
            return Value(f"undef_{node.name}")

    #     def build_constant(self, value: Any, type_str: str) -> Value:
    const_op = ConstantOp(value, type_str, Location())
            self.current_block.operations.append(const_op)
    #         return const_op.results[0]
