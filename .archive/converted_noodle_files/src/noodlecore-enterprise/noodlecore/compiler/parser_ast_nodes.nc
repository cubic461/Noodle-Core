# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# AST Node Classes for Noodle Programming Language
# ------------------------------------------------
# This module defines the Abstract Syntax Tree node classes for the Noodle parser.
# Each node represents a construct in the Noodle language.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import enum.Enum
import typing.Any,
import .lexer_position.Position


class NodeType(Enum)
    #     """Node types for the AST"""

    #     # Statements
    PROGRAM = "PROGRAM"
    VAR_DECL = "VAR_DECL"
    ASSIGN_STMT = "ASSIGN_STMT"
    EXPR_STMT = "EXPR_STMT"
    IF_STMT = "IF_STMT"
    WHILE_STMT = "WHILE_STMT"
    FOR_STMT = "FOR_STMT"
    FUNC_DEF = "FUNC_DEF"
    RETURN_STMT = "RETURN_STMT"
    PRINT_STMT = "PRINT_STMT"
    IMPORT_STMT = "IMPORT_STMT"
    TRY_STMT = "TRY_STMT"
    CATCH_STMT = "CATCH_STMT"
    RAISE_STMT = "RAISE_STMT"
    COMPOUND_STMT = "COMPOUND_STMT"
    DECORATOR = "DECORATOR"

    #     # Expressions
    BINARY_EXPR = "BINARY_EXPR"
    UNARY_EXPR = "UNARY_EXPR"
    IDENTIFIER_EXPR = "IDENTIFIER_EXPR"
    LITERAL_EXPR = "LITERAL_EXPR"
    CALL_EXPR = "CALL_EXPR"
    MEMBER_EXPR = "MEMBER_EXPR"
    PAREN_EXPR = "PAREN_EXPR"
    LIST_EXPR = "LIST_EXPR"
    DICT_EXPR = "DICT_EXPR"
    SLICE_EXPR = "SLICE_EXPR"
    TERNARY_EXPR = "TERNARY_EXPR"

    #     # Special
    TYPE_HINT = "TYPE_HINT"
    PARAMETER = "PARAMETER"
    ARGUMENT = "ARGUMENT"
    KEY_VALUE = "KEY_VALUE"


class Type
    #     """Represents a type in the Noodle language"""

    #     def __init__(
    self, name: str, is_builtin: bool = False, base_type: Optional["Type"] = None
    #     ):
    #         """
    #         Initialize a Type.

    #         Args:
                name: Type name (e.g., 'int', 'str', 'List', 'UserClass')
    #             is_builtin: Whether this is a built-in type
    #             base_type: Base type for inheritance
    #         """
    self.name = name
    self.is_builtin = is_builtin
    self.base_type = base_type
    self.methods = {}
    self.attributes = {}

    #     def add_method(self, name: str, method_type: str):
    #         """Add a method to this type"""
    self.methods[name] = method_type

    #     def add_attribute(self, name: str, attribute_type: str):
    #         """Add an attribute to this type"""
    self.attributes[name] = attribute_type

    #     def is_subtype_of(self, other: "Type") -> bool:
    #         """Check if this type is a subtype of another type"""
    #         if self == other:
    #             return True
    #         if self.base_type is not None:
                return self.base_type.is_subtype_of(other)
    #         return False

    #     def __eq__(self, other) -> bool:
    #         """Check type equality"""
    #         if not isinstance(other, Type):
    #             return False
    return self.name = = other.name

    #     def __hash__(self) -> int:
    #         """Hash for use in sets/dictionaries"""
            return hash(self.name)

    #     def __repr__(self) -> str:
    #         """String representation"""
    #         base_info = f" -> {self.base_type.name}" if self.base_type else ""
            return f"Type({self.name}{base_info})"


class Identifier
    #     """Represents an identifier in the Noodle language"""

    #     def __init__(
    #         self,
    #         name: str,
    namespace: Optional[str] = None,
    type_hint: Optional[Type] = None,
    is_constant: bool = False,
    is_function: bool = False,
    #     ):
    #         """
    #         Initialize an Identifier.

    #         Args:
    #             name: Identifier name
                namespace: Optional namespace (e.g., module name)
    #             type_hint: Optional type hint
    #             is_constant: Whether this is a constant
    #             is_function: Whether this is a function
    #         """
    self.name = name
    self.namespace = namespace
    self.type_hint = type_hint
    self.is_constant = is_constant
    self.is_function = is_function
    self.value = None
    self.scope = None

    #     def set_value(self, value: Any):
    #         """Set the value of this identifier"""
    self.value = value

    #     def set_scope(self, scope: str):
    #         """Set the scope of this identifier"""
    self.scope = scope

    #     def get_full_name(self) -> str:
    #         """Get the fully qualified name"""
    #         if self.namespace:
    #             return f"{self.namespace}.{self.name}"
    #         return self.name

    #     def __eq__(self, other) -> bool:
    #         """Check identifier equality"""
    #         if not isinstance(other, Identifier):
    #             return False
    return self.get_full_name() = = other.get_full_name()

    #     def __hash__(self) -> int:
    #         """Hash for use in sets/dictionaries"""
            return hash(self.get_full_name())

    #     def __repr__(self) -> str:
    #         """String representation"""
    #         type_info = f": {self.type_hint.name}" if self.type_hint else ""
    #         const_info = " (const)" if self.is_constant else ""
    #         func_info = " (func)" if self.is_function else ""
            return f"Identifier({self.get_full_name()}{type_info}{const_info}{func_info})"


class ASTNode
    #     """Base class for AST nodes"""

    #     def __init__(self, node_type: NodeType, position: Optional[Position] = None):
    self.node_type = node_type
    self.position = position
    self.children: List[ASTNode] = []

    #     def add_child(self, child: "ASTNode"):
    #         """Add a child node"""
            self.children.append(child)

    #     def __repr__(self):
    class_name = self.__class__.__name__
    return f"{class_name}({self.node_type}, children = {len(self.children)})"


class Statement
    #     """Base class for statements"""

    #     pass


class Expression
    #     """Base class for expressions"""

    #     pass


class StatementNode(ASTNode)
    #     """Base class for statement nodes"""

    #     def __init__(self, node_type: NodeType, position: Optional[Position] = None):
            super().__init__(node_type, position)


class ExpressionNode(ASTNode)
    #     """Base class for expression nodes"""

    #     def __init__(self, node_type: NodeType, position: Optional[Position] = None):
            super().__init__(node_type, position)


class Program(ASTNode)
    #     """Represents a program in the AST"""

    #     def __init__(self, position: Optional[Position] = None):
            super().__init__(NodeType.PROGRAM, position)


class ProgramNode(ASTNode)
    #     """Represents a program node"""

    #     def __init__(self, position: Optional[Position] = None):
            super().__init__(NodeType.PROGRAM, position)


class VarDeclNode(StatementNode)
    #     """Represents a variable declaration statement"""

    #     def __init__(
    #         self,
    #         name: str,
    type_hint: Optional[str] = None,
    initializer: Optional[ExpressionNode] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.VAR_DECL, position)
    self.name = name
    self.type_hint = type_hint
    self.initializer = initializer


class AssignStmtNode(StatementNode)
    #     """Represents an assignment statement"""

    #     def __init__(
    #         self,
    #         target: ExpressionNode,
    #         value: ExpressionNode,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.ASSIGN_STMT, position)
    self.target = target
    self.value = value


class ExprStmtNode(StatementNode)
    #     """Represents an expression statement"""

    #     def __init__(self, expression: ExpressionNode, position: Optional[Position] = None):
            super().__init__(NodeType.EXPR_STMT, position)
    self.expression = expression


class IfStmtNode(StatementNode)
    #     """Represents an if statement"""

    #     def __init__(
    #         self,
    #         condition: ExpressionNode,
    #         then_branch: StatementNode,
    else_branch: Optional[StatementNode] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.IF_STMT, position)
    self.condition = condition
    self.then_branch = then_branch
    self.else_branch = else_branch


class WhileStmtNode(StatementNode)
    #     """Represents a while statement"""

    #     def __init__(
    #         self,
    #         condition: ExpressionNode,
    #         body: StatementNode,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.WHILE_STMT, position)
    self.condition = condition
    self.body = body


class ForStmtNode(StatementNode)
    #     """Represents a for statement"""

    #     def __init__(
    #         self,
    #         variable: str,
    #         iterable: ExpressionNode,
    #         body: StatementNode,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.FOR_STMT, position)
    self.variable = variable
    self.iterable = iterable
    self.body = body


class FuncDefNode(StatementNode)
    #     """Represents a function definition"""

    #     def __init__(
    #         self,
    #         name: str,
    #         params: List[Dict[str, Any]],
    return_type: Optional[str] = None,
    body: Optional[StatementNode] = None,
    is_async: bool = False,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.FUNC_DEF, position)
    self.name = name
    self.params = params  # List of {'name': str, 'type': Optional[str], 'default': Optional[ExpressionNode]}
    self.return_type = return_type
    self.body = body
    self.is_async = is_async


class ReturnStmtNode(StatementNode)
    #     """Represents a return statement"""

    #     def __init__(
    #         self,
    value: Optional[ExpressionNode] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.RETURN_STMT, position)
    self.value = value


class PrintStmtNode(StatementNode)
    #     """Represents a print statement"""

    #     def __init__(
    self, arguments: List[ExpressionNode], position: Optional[Position] = None
    #     ):
            super().__init__(NodeType.PRINT_STMT, position)
    self.arguments = arguments


class ImportStmtNode(StatementNode)
    #     """Represents an import statement"""

    #     def __init__(
    #         self,
    #         module: str,
    alias: Optional[str] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.IMPORT_STMT, position)
    self.module = module
    self.alias = alias


class TryStmtNode(StatementNode)
    #     """Represents a try statement"""

    #     def __init__(
    #         self,
    #         body: StatementNode,
    catch_var: Optional[str] = None,
    catch_body: Optional[StatementNode] = None,
    finally_body: Optional[StatementNode] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.TRY_STMT, position)
    self.body = body
    self.catch_var = catch_var
    self.catch_body = catch_body
    self.final_body = finally_body


class CompoundStmtNode(StatementNode)
    #     """Represents a compound statement containing multiple statements"""

    #     def __init__(
    self, statements: List[StatementNode], position: Optional[Position] = None
    #     ):
            super().__init__(NodeType.COMPOUND_STMT, position)
    self.statements = statements


class RaiseStmtNode(StatementNode)
    #     """Represents a raise/throw statement"""

    #     def __init__(
    #         self,
    exception: Optional[ExpressionNode] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.RAISE_STMT, position)
    self.exception = exception


class BinaryExprNode(ExpressionNode)
    #     """Represents a binary expression"""

    #     def __init__(
    #         self,
    #         left: ExpressionNode,
    #         operator: str,
    #         right: ExpressionNode,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.BINARY_EXPR, position)
    self.left = left
    self.operator = operator
    self.right = right


class UnaryExprNode(ExpressionNode)
    #     """Represents a unary expression"""

    #     def __init__(
    #         self,
    #         operator: str,
    #         operand: ExpressionNode,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.UNARY_EXPR, position)
    self.operator = operator
    self.operand = operand


class IdentifierExprNode(ExpressionNode)
    #     """Represents an identifier expression"""

    #     def __init__(self, name: str, position: Optional[Position] = None):
            super().__init__(NodeType.IDENTIFIER_EXPR, position)
    self.name = name


class LiteralExprNode(ExpressionNode)
    #     """Represents a literal expression"""

    #     def __init__(self, value: Any, type_name: str, position: Optional[Position] = None):
            super().__init__(NodeType.LITERAL_EXPR, position)
    self.value = value
    self.type_name = type_name


class CallExprNode(ExpressionNode)
    #     """Represents a function call expression"""

    #     def __init__(
    #         self,
    #         function: ExpressionNode,
    #         arguments: List[ExpressionNode],
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.CALL_EXPR, position)
    self.function = function
    self.arguments = arguments


class MemberExprNode(ExpressionNode)
    #     """Represents a member access expression"""

    #     def __init__(
    self, object: ExpressionNode, member: str, position: Optional[Position] = None
    #     ):
            super().__init__(NodeType.MEMBER_EXPR, position)
    self.object = object
    self.member = member


class ParenExprNode(ExpressionNode)
    #     """Represents a parenthesized expression"""

    #     def __init__(self, expression: ExpressionNode, position: Optional[Position] = None):
            super().__init__(NodeType.PAREN_EXPR, position)
    self.expression = expression


class ListExprNode(ExpressionNode)
    #     """Represents a list literal expression"""

    #     def __init__(
    self, elements: List[ExpressionNode], position: Optional[Position] = None
    #     ):
            super().__init__(NodeType.LIST_EXPR, position)
    self.elements = elements


class DictExprNode(ExpressionNode)
    #     """Represents a dictionary literal expression"""

    #     def __init__(
    #         self,
    #         pairs: List[Dict[str, ExpressionNode]],
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.DICT_EXPR, position)
    self.pairs = pairs


class SliceExprNode(ExpressionNode)
    #     """Represents a slice expression"""

    #     def __init__(
    #         self,
    #         target: ExpressionNode,
    start: Optional[ExpressionNode] = None,
    stop: Optional[ExpressionNode] = None,
    step: Optional[ExpressionNode] = None,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.SLICE_EXPR, position)
    self.target = target
    self.start = start
    self.stop = stop
    self.step = step


class TernaryExprNode(ExpressionNode)
    #     """Represents a ternary conditional expression"""

    #     def __init__(
    #         self,
    #         condition: ExpressionNode,
    #         if_true: ExpressionNode,
    #         if_false: ExpressionNode,
    position: Optional[Position] = None,
    #     ):
            super().__init__(NodeType.TERNARY_EXPR, position)
    self.condition = condition
    self.if_true = if_true
    self.if_false = if_false
