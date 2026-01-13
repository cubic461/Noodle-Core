# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Constant Folding Optimization for Noodle Compiler
# ------------------------------------------------
# This module implements constant folding optimization for the Noodle compiler.
# It evaluates constant expressions at compile time instead of runtime.

# Created for Week 2: Compiler Optimalizations
# """

import typing.Any,
import ..parser_ast_nodes.(
#     ASTNode,
#     ExpressionNode,
#     BinaryExprNode,
#     UnaryExprNode,
#     LiteralExprNode,
#     IdentifierExprNode,
#     ParenExprNode,
#     VarDeclNode,
#     NodeType,
# )


class ConstantFolder
    #     """Implements constant folding optimization"""

    #     def __init__(self):
    self.constants: Dict[str, Any] = {}
    self.modified = False

    #     def fold_constants(self, node: ASTNode) -> ASTNode:
    #         """
    #         Apply constant folding to an AST node.

    #         Args:
    #             node: The root AST node to optimize

    #         Returns:
    #             The optimized AST node
    #         """
    self.modified = False
    #         # Don't reset constants - allow them to persist between calls
    # self.constants = {}

            return self._visit_node(node)

    #     def _visit_node(self, node: ASTNode) -> ASTNode:
    #         """Visit and optimize a node"""
    #         if node is None:
    #             return node

    #         # Dispatch based on node type
    #         if node.node_type == NodeType.BINARY_EXPR:
                return self._visit_binary_expr(node)
    #         elif node.node_type == NodeType.UNARY_EXPR:
                return self._visit_unary_expr(node)
    #         elif node.node_type == NodeType.LITERAL_EXPR:
                return self._visit_literal_expr(node)
    #         elif node.node_type == NodeType.IDENTIFIER_EXPR:
                return self._visit_identifier_expr(node)
    #         elif node.node_type == NodeType.PAREN_EXPR:
                return self._visit_paren_expr(node)
    #         elif node.node_type == NodeType.PROGRAM:
                return self._visit_program(node)
    #         elif node.node_type == NodeType.VAR_DECL:
                return self._visit_var_decl(node)
    #         elif hasattr(node, 'children'):
                return self._visit_children(node)
    #         else:
    #             return node

    #     def _visit_children(self, node: ASTNode) -> ASTNode:
    #         """Visit and optimize all children of a node"""
    changed = False

    #         for i, child in enumerate(node.children):
    new_child = self._visit_node(child)
    #             if new_child is not child:
    changed = True
    node.children[i] = new_child

    #         if changed:
    self.modified = True

    #         return node

    #     def _visit_binary_expr(self, node: BinaryExprNode) -> ExpressionNode:
    #         """Optimize binary expressions"""
    #         # First visit children
    new_left = self._visit_node(node.left)
    new_right = self._visit_node(node.right)

    #         if new_left is not node.left or new_right is not node.right:
    node.left = new_left
    node.right = new_right
    self.modified = True

    #         # Try to fold if both operands are constants
    #         if self._is_constant(node.left) and self._is_constant(node.right):
    #             try:
    left_val = self._get_constant_value(node.left)
    right_val = self._get_constant_value(node.right)
    result = self._evaluate_binary_op(node.operator, left_val, right_val)

    #                 # Create new literal node
    #                 from ..lexer_position import Position
    position = node.position or Position(1, 1)
                    return LiteralExprNode(result, type(result).__name__, position)
                except (TypeError, ZeroDivisionError, ArithmeticError):
    #                 # Evaluation failed, keep original
    #                 pass

    #         return node

    #     def _visit_unary_expr(self, node: UnaryExprNode) -> ExpressionNode:
    #         """Optimize unary expressions"""
    #         # First visit child
    new_operand = self._visit_node(node.operand)

    #         if new_operand is not node.operand:
    node.operand = new_operand
    self.modified = True

    #         # Try to fold if operand is constant
    #         if self._is_constant(node.operand):
    #             try:
    operand_val = self._get_constant_value(node.operand)
    result = self._evaluate_unary_op(node.operator, operand_val)

    #                 # Create new literal node
    #                 from ..lexer_position import Position
    position = node.position or Position(1, 1)
                    return LiteralExprNode(result, type(result).__name__, position)
                except (TypeError, ArithmeticError):
    #                 # Evaluation failed, keep original
    #                 pass

    #         return node

    #     def _visit_literal_expr(self, node: LiteralExprNode) -> ExpressionNode:
    #         """Literal expressions are already constant"""
    #         return node

    #     def _visit_identifier_expr(self, node: IdentifierExprNode) -> ExpressionNode:
    #         """Check if identifier refers to a constant"""
    #         if node.name in self.constants:
    #             # Create literal from constant value
    #             from ..lexer_position import Position
    position = node.position or Position(1, 1)
                return LiteralExprNode(self.constants[node.name], type(self.constants[node.name]).__name__, position)
    #         return node

    #     def _visit_paren_expr(self, node: ParenExprNode) -> ExpressionNode:
    #         """Optimize parenthesized expressions"""
    #         # Visit the inner expression
    new_expr = self._visit_node(node.expression)

    #         if new_expr is not node.expression:
    node.expression = new_expr
    self.modified = True

    #         # If inner expression is constant, we can remove parentheses
    #         if self._is_constant(new_expr):
    #             return new_expr

    #         return node

    #     def _visit_program(self, node: ASTNode) -> ASTNode:
    #         """Optimize program nodes"""
    #         # Program nodes have children
            return self._visit_children(node)

    #     def _visit_var_decl(self, node: VarDeclNode) -> ASTNode:
    #         """Optimize variable declarations"""
    #         # Visit and optimize the initializer if it exists
    #         if node.initializer is not None:
    new_initializer = self._visit_node(node.initializer)
    #             if new_initializer is not node.initializer:
    node.initializer = new_initializer
    self.modified = True
    #         return node

    #     def _is_constant(self, node: ASTNode) -> bool:
    #         """Check if a node represents a constant value"""
    #         if node is None:
    #             return False

    #         if node.node_type == NodeType.LITERAL_EXPR:
    #             return True

    #         if node.node_type == NodeType.IDENTIFIER_EXPR:
    #             return node.name in self.constants

    #         # Recursively check if all children are constants
    #         if hasattr(node, 'children'):
    #             return all(self._is_constant(child) for child in node.children)

    #         return False

    #     def _get_constant_value(self, node: ASTNode) -> Any:
    #         """Get the constant value of a node"""
    #         if node is None:
    #             return None

    #         if node.node_type == NodeType.LITERAL_EXPR:
    #             return node.value

    #         if node.node_type == NodeType.IDENTIFIER_EXPR:
    #             if node.name in self.constants:
    #                 return self.constants[node.name]
    #             return None

    #         # For parenthesized expressions, get the inner value
    #         if node.node_type == NodeType.PAREN_EXPR:
                return self._get_constant_value(node.expression)

    #         # For binary expressions, try to evaluate them if both children are constants
    #         if node.node_type == NodeType.BINARY_EXPR:
    #             if self._is_constant(node.left) and self._is_constant(node.right):
    #                 try:
    left_val = self._get_constant_value(node.left)
    right_val = self._get_constant_value(node.right)
                        return self._evaluate_binary_op(node.operator, left_val, right_val)
                    except (TypeError, ZeroDivisionError, ArithmeticError):
    #                     return None

    #         # For unary expressions, try to evaluate if operand is constant
    #         if node.node_type == NodeType.UNARY_EXPR:
    #             if self._is_constant(node.operand):
    #                 try:
    operand_val = self._get_constant_value(node.operand)
                        return self._evaluate_unary_op(node.operator, operand_val)
                    except (TypeError, ArithmeticError):
    #                     return None

    #         # For other node types, try to evaluate them
    #         if hasattr(node, 'children'):
    #             # This is a simplified approach - in production, you'd need
    #             # more sophisticated evaluation based on node type
    #             return None

    #         return None

    #     def _evaluate_binary_op(self, operator: str, left: Any, right: Any) -> Any:
    #         """Evaluate a binary operation with constant operands"""
    #         if operator == '+':
    #             return left + right
    #         elif operator == '-':
    #             return left - right
    #         elif operator == '*':
    #             return left * right
    #         elif operator == '/':
    #             if right == 0:
                    raise ZeroDivisionError("Division by zero")
    #             return left / right
    #         elif operator == '//':
    #             if right == 0:
                    raise ZeroDivisionError("Division by zero")
    #             return left // right
    #         elif operator == '%':
    #             if right == 0:
                    raise ZeroDivisionError("Modulo by zero")
    #             return left % right
    #         elif operator == '**':
    #             return left ** right
    #         elif operator == '==':
    return left = = right
    #         elif operator == '!=':
    return left ! = right
    #         elif operator == '<':
    #             return left < right
    #         elif operator == '<=':
    return left < = right
    #         elif operator == '>':
    #             return left > right
    #         elif operator == '>=':
    return left > = right
    #         elif operator == 'and':
    #             return left and right
    #         elif operator == 'or':
    #             return left or right
    #         elif operator == 'xor':
    return bool(left) ! = bool(right)
    #         elif operator == '<<':
    #             return left << right
    #         elif operator == '>>':
    #             return left >> right
    #         elif operator == '&':
    #             return left & right
    #         elif operator == '|':
    #             return left | right
    #         elif operator == '^':
    #             return left ^ right
    #         else:
                raise TypeError(f"Unknown binary operator: {operator}")

    #     def _evaluate_unary_op(self, operator: str, operand: Any) -> Any:
    #         """Evaluate a unary operation with constant operand"""
    #         if operator == '-':
    #             return -operand
    #         elif operator == '+':
    #             return +operand
    #         elif operator == '~':
    #             return ~operand
    #         elif operator == 'not':
    #             return not operand
    #         else:
                raise TypeError(f"Unknown unary operator: {operator}")

    #     def add_constant(self, name: str, value: Any):
    #         """Add a constant value that can be used in folding"""
    self.constants[name] = value

    #     def is_changed(self) -> bool:
    #         """Check if any modifications were made"""
    #         return self.modified


def create_constant_folder() -> ConstantFolder:
#     """Create a new constant folder instance"""
    return ConstantFolder()


def apply_constant_folding(node: ASTNode) -> ASTNode:
#     """
#     Apply constant folding optimization to an AST node.

#     Args:
#         node: The AST node to optimize

#     Returns:
#         The optimized AST node
#     """
folder = create_constant_folder()
    return folder.fold_constants(node)
