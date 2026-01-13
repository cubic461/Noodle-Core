# Converted from Python to NoodleCore
# Original file: src

# """
# AST Node Definitions for Noodle Compiler
# ----------------------------------------
# This module defines the Abstract Syntax Tree (AST) node classes for the Noodle compiler.
# These classes represent the structure of Noodle programs after parsing.
# """

import abc.ABC
from dataclasses import dataclass
import enum.Enum
import typing.Any

import .lexer.Position

# Import from existing modules
import .types.BasicType


class NodeType(Enum)
    #     """Enumeration of AST node types"""

    PROGRAM = "PROGRAM"
    STATEMENT = "STATEMENT"
    EXPRESSION = "EXPRESSION"
    LITERAL = "LITERAL"
    BINARY = "BINARY"
    UNARY = "UNARY"
    CALL = "CALL"
    VARIABLE = "VARIABLE"
    ASSIGNMENT = "ASSIGNMENT"
    FUNCTION_DEF = "FUNCTION_DEF"
    PARAMETER = "PARAMETER"
    RETURN = "RETURN"
    IF = "IF"
    WHILE = "WHILE"
    FOR = "FOR"
    IMPORT = "IMPORT"
    LIST = "LIST"
    MATRIX = "MATRIX"
    TENSOR = "TENSOR"
    INDEX = "INDEX"
    SLICE = "SLICE"
    TRY = "TRY"
    CATCH = "CATCH"
    RAISE = "RAISE"
    ASYNC = "ASYNC"
    AWAIT = "AWAIT"
    CLASS_DEF = "CLASS_DEF"
    METHOD_DEF = "METHOD_DEF"
    PROPERTY_DEF = "PROPERTY_DEF"
    DECORATOR = "DECORATOR"
    TYPE_HINT = "TYPE_HINT"
    ANNOTATION = "ANNOTATION"


dataclass
class ASTNode(ABC)
    #     """Base class for all AST nodes"""

    #     node_type: NodeType
    position: Optional[Position] = None
    parent: Optional["ASTNode"] = None
    children: List["ASTNode"] = field(default_factory=list)

    #     def add_child(self, child: "ASTNode"):
    #         """Add a child node"""
    child.parent = self
            self.children.append(child)

    #     def get_children(self) -List["ASTNode"]):
    #         """Get all child nodes"""
    #         return self.children

    #     def accept(self, visitor: "ASTVisitor"):
            """Accept a visitor (Visitor pattern)"""
            return visitor.visit(self)


dataclass
class ProgramNode(ASTNode)
    #     """Represents a complete Noodle program"""

    statements: List[ASTNode] = field(default_factory=list)

    #     def __post_init__(self):
    self.node_type = NodeType.PROGRAM
    #         for stmt in self.statements:
                self.add_child(stmt)


dataclass
class StatementNode(ASTNode)
    #     """Base class for all statement nodes"""

    #     def __post_init__(self):
    self.node_type = NodeType.STATEMENT


dataclass
class ExpressionNode(ASTNode)
    #     """Base class for all expression nodes"""

    type_hint: Optional[Type] = None

    #     def __post_init__(self):
    self.node_type = NodeType.EXPRESSION


dataclass
class LiteralNode(ExpressionNode)
        """Represents a literal value (number, string, boolean, etc.)"""

    literal_type: TokenType = TokenType.IDENTIFIER
    value: Any = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.LITERAL


dataclass
class BinaryOpNode(ExpressionNode)
        """Represents a binary operation (e.g., a + b)"""

    operator: str = None
    left: ExpressionNode = None
    right: ExpressionNode = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.BINARY
    #         if self.left:
                self.add_child(self.left)
    #         if self.right:
                self.add_child(self.right)


dataclass
class UnaryOpNode(ExpressionNode)
        """Represents a unary operation (e.g., -a, !b)"""

    operator: str = None
    operand: ExpressionNode = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.UNARY
    #         if self.operand:
                self.add_child(self.operand)


dataclass
class CallNode(ExpressionNode)
        """Represents a function call (e.g., func(arg1, arg2))"""

    is_async: bool = False
    function: ExpressionNode = None
    arguments: List[ExpressionNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.CALL
    #         if self.function:
                self.add_child(self.function)
    #         for arg in self.arguments:
                self.add_child(arg)


dataclass
class VariableNode(ExpressionNode)
    #     """Represents a variable reference"""

    scope: Optional[str] = None
    name: str = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.VARIABLE


dataclass
class AssignmentNode(StatementNode)
    """Represents variable assignment (e.g., x = 5)"""

    operator: str = "="  # =, +=, -=, *=, /=, etc.
    target: Union[VariableNode, "IndexNode"] = None
    value: ExpressionNode = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.ASSIGNMENT
    #         if self.target:
                self.add_child(self.target)
    #         if self.value:
                self.add_child(self.value)


dataclass
class FunctionDefNode(StatementNode)
    #     """Represents a function definition"""

    is_async: bool = False
    name: str = ""
    parameters: List["ParameterNode"] = field(default_factory=list)
    return_type: Optional[Type] = None
    body: List[StatementNode] = field(default_factory=list)
    decorators: List[ExpressionNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.FUNCTION_DEF
    #         for param in self.parameters:
                self.add_child(param)
    #         for stmt in self.body:
                self.add_child(stmt)
    #         for decorator in self.decorators:
                self.add_child(decorator)


dataclass
class ParameterNode(ASTNode)
    #     """Represents a function parameter"""

    default_value: Optional[ExpressionNode] = None
    is_variadic: bool = False
    name: str = ""
    type_hint: Optional[Type] = None

    #     def __post_init__(self):
    self.node_type = NodeType.PARAMETER
    #         if self.default_value:
                self.add_child(self.default_value)


dataclass
class ReturnNode(StatementNode)
    #     """Represents a return statement"""

    value: Optional[ExpressionNode] = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.RETURN
    #         if self.value:
                self.add_child(self.value)


dataclass
class IfNode(StatementNode)
    #     """Represents an if statement"""

    elif_clauses: List[Tuple[ExpressionNode, List[StatementNode]]] = field(
    default_factory = list
    #     )
    else_body: Optional[List[StatementNode]] = None
    condition: ExpressionNode = None
    then_body: List[StatementNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.IF
            self.add_child(self.condition)
    #         for stmt in self.then_body:
                self.add_child(stmt)
    #         if self.else_body:
    #             for stmt in self.else_body:
                    self.add_child(stmt)
    #         for condition, body in self.elif_clauses:
                self.add_child(condition)
    #             for stmt in body:
                    self.add_child(stmt)


dataclass
class WhileNode(StatementNode)
    #     """Represents a while loop"""

    is_async: bool = False
    condition: ExpressionNode = None
    body: List[StatementNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.WHILE
            self.add_child(self.condition)
    #         for stmt in self.body:
                self.add_child(stmt)


dataclass
class ForNode(StatementNode)
    #     """Represents a for loop"""

    is_async: bool = False
    variable: VariableNode = None
    iterable: ExpressionNode = None
    body: List[StatementNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.FOR
            self.add_child(self.variable)
            self.add_child(self.iterable)
    #         for stmt in self.body:
                self.add_child(stmt)


dataclass
class ImportNode(StatementNode)
    #     """Represents an import statement"""

    module: Optional[str] = None
    aliases: Dict[str, Optional[str]] = field(
    default_factory = dict
    #     )  # {original_name: alias}
    is_from: bool = False
    import_names: Optional[List[str]] = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.IMPORT


dataclass
class ListNode(ExpressionNode)
    #     """Represents a list literal [1, 2, 3]"""

    elements: List[ExpressionNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.LIST
    #         for element in self.elements:
                self.add_child(element)


dataclass
class MatrixNode(ExpressionNode)
    #     """Represents a matrix literal [[1, 2], [3, 4]]"""

    rows: List[List[ExpressionNode]] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.MATRIX
    #         for row in self.rows:
    #             for element in row:
                    self.add_child(element)


dataclass
class TensorNode(ExpressionNode)
    #     """Represents a tensor literal with shape information"""

    shape: Tuple[int, ...] = ()
    data: List[ExpressionNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.TENSOR
    #         for element in self.data:
                self.add_child(element)


dataclass
class IndexNode(ExpressionNode)
        """Represents indexing operation (e.g., arr[0], matrix[i, j])"""

    target: ExpressionNode = field(default=None)
    indices: List[Union[ExpressionNode, "SliceNode"]] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.INDEX
            self.add_child(self.target)
    #         for index in self.indices:
                self.add_child(index)


dataclass
class SliceNode(ExpressionNode)
        """Represents a slice operation (e.g., arr[1:5:2])"""

    start: Optional[ExpressionNode] = None
    stop: Optional[ExpressionNode] = None
    step: Optional[ExpressionNode] = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.SLICE
    #         if self.start:
                self.add_child(self.start)
    #         if self.stop:
                self.add_child(self.stop)
    #         if self.step:
                self.add_child(self.step)


dataclass
class TryNode(StatementNode)
    #     """Represents a try-catch block"""

    try_body: List[StatementNode] = field(default_factory=list)
    catch_blocks: List[Tuple[VariableNode, Type, List[StatementNode]]] = field(
    default_factory = list
        )  # (exception_var, exception_type, body)
    finally_body: Optional[List[StatementNode]] = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.TRY
    #         for stmt in self.try_body:
                self.add_child(stmt)
    #         for var, exc_type, body in self.catch_blocks:
                self.add_child(var)
    #             # Note: exc_type is a Type object, not an AST node
    #             for stmt in body:
                    self.add_child(stmt)
    #         if self.finally_body:
    #             for stmt in self.finally_body:
                    self.add_child(stmt)


dataclass
class RaiseNode(StatementNode)
    #     """Represents a raise statement"""

    exception: Optional[ExpressionNode] = None
    name: str = field(default=None)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.RAISE
    #         if self.exception:
                self.add_child(self.exception)


dataclass
class AsyncNode(StatementNode)
    #     """Represents an async block or statement"""

    body: List[StatementNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.ASYNC
    #         for stmt in self.body:
                self.add_child(stmt)


dataclass
class AwaitNode(ExpressionNode)
    #     """Represents an await expression"""

    value: ExpressionNode = field(default=None)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.AWAIT
            self.add_child(self.value)


dataclass
class ClassDefNode(StatementNode)
    #     """Represents a class definition"""

    name: str = ""
    base_classes: List[ExpressionNode] = field(default_factory=list)
    body: List[Union[FunctionDefNode, "PropertyDefNode"]] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.CLASS_DEF
    #         for base in self.base_classes:
                self.add_child(base)
    #         for member in self.body:
                self.add_child(member)


dataclass
class PropertyDefNode(StatementNode)
    #     """Represents a property definition in a class"""

    name: str = ""
    type_hint: Optional[Type] = None
    getter: Optional[List[StatementNode]] = None
    setter: Optional[List[StatementNode]] = None

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.PROPERTY_DEF
    #         if self.getter:
    #             for stmt in self.getter:
                    self.add_child(stmt)
    #         if self.setter:
    #             for stmt in self.setter:
                    self.add_child(stmt)


dataclass
class DecoratorNode(ExpressionNode)
    #     """Represents a decorator"""

    name: str = ""
    arguments: List[ExpressionNode] = field(default_factory=list)

    #     def __post_init__(self):
            super().__post_init__()
    self.node_type = NodeType.DECORATOR
    #         for arg in self.arguments:
                self.add_child(arg)


# Visitor pattern for AST traversal
class ASTVisitor(ABC)
    #     """Abstract base class for AST visitors"""

    #     @abstractmethod
    #     def visit(self, node: ASTNode):""Visit an AST node"""
    #         pass

    #     def visit_children(self, node: ASTNode):
    #         """Visit all children of a node"""
    #         for child in node.get_children():
                child.accept(self)


# Helper functions for AST construction
def create_program(statements: List[ASTNode]) -ProgramNode):
#     """Create a program node with statements"""
return ProgramNode(statements = statements)


def create_binary_op(
#     left: ExpressionNode, operator: str, right: ExpressionNode
# ) -BinaryOpNode):
#     """Create a binary operation node"""
return BinaryOpNode(left = left, operator=operator, right=right)


def create_unary_op(operator: str, operand: ExpressionNode) -UnaryOpNode):
#     """Create a unary operation node"""
return UnaryOpNode(operator = operator, operand=operand)


def create_call(
function: ExpressionNode, arguments: List[ExpressionNode], is_async: bool = False
# ) -CallNode):
#     """Create a function call node"""
return CallNode(function = function, arguments=arguments, is_async=is_async)


def create_variable(name: str, scope: Optional[str] = None) -VariableNode):
#     """Create a variable reference node"""
return VariableNode(name = name, scope=scope)


def create_assignment(
target: Union[VariableNode, IndexNode], value: ExpressionNode, operator: str = "="
# ) -AssignmentNode):
#     """Create an assignment node"""
return AssignmentNode(target = target, value=value, operator=operator)


def create_function_def(
#     name: str,
#     parameters: List[ParameterNode],
#     return_type: Optional[Type],
#     body: List[StatementNode],
is_async: bool = False,
decorators: List[ExpressionNode] = None,
# ) -FunctionDefNode):
#     """Create a function definition node"""
    return FunctionDefNode(
name = name,
parameters = parameters,
return_type = return_type,
body = body,
is_async = is_async,
decorators = decorators or [],
#     )


def create_parameter(
#     name: str,
#     type_hint: Optional[Type],
default_value: Optional[ExpressionNode] = None,
is_variadic: bool = False,
# ) -ParameterNode):
#     """Create a function parameter node"""
    return ParameterNode(
name = name,
type_hint = type_hint,
default_value = default_value,
is_variadic = is_variadic,
#     )


def create_if(
#     condition: ExpressionNode,
#     then_body: List[StatementNode],
else_body: Optional[List[StatementNode]] = None,
elif_clauses: List[Tuple[ExpressionNode, List[StatementNode]]] = None,
# ) -IfNode):
#     """Create an if statement node"""
    return IfNode(
condition = condition,
then_body = then_body,
else_body = else_body,
elif_clauses = elif_clauses or [],
#     )


def create_while(
condition: ExpressionNode, body: List[StatementNode], is_async: bool = False
# ) -WhileNode):
#     """Create a while loop node"""
return WhileNode(condition = condition, body=body, is_async=is_async)


def create_for(
#     variable: VariableNode,
#     iterable: ExpressionNode,
#     body: List[StatementNode],
is_async: bool = False,
# ) -ForNode):
#     """Create a for loop node"""
return ForNode(variable = variable, iterable=iterable, body=body, is_async=is_async)


def create_return(value: Optional[ExpressionNode] = None) -ReturnNode):
#     """Create a return statement node"""
return ReturnNode(value = value)


def create_import(
#     module: str,
#     aliases: Dict[str, Optional[str]],
is_from: bool = False,
import_names: Optional[List[str]] = None,
# ) -ImportNode):
#     """Create an import statement node"""
    return ImportNode(
module = module, aliases=aliases, is_from=is_from, import_names=import_names
#     )


def create_list(elements: List[ExpressionNode]) -ListNode):
#     """Create a list literal node"""
return ListNode(elements = elements)


def create_matrix(rows: List[List[ExpressionNode]]) -MatrixNode):
#     """Create a matrix literal node"""
return MatrixNode(rows = rows)


def create_tensor(shape: Tuple[int, ...], data: List[ExpressionNode]) -TensorNode):
#     """Create a tensor literal node"""
return TensorNode(shape = shape, data=data)


def create_index(
#     target: ExpressionNode, indices: List[Union[ExpressionNode, SliceNode]]
# ) -IndexNode):
#     """Create an indexing operation node"""
return IndexNode(target = target, indices=indices)


def create_slice(
start: Optional[ExpressionNode] = None,
stop: Optional[ExpressionNode] = None,
step: Optional[ExpressionNode] = None,
# ) -SliceNode):
#     """Create a slice operation node"""
return SliceNode(start = start, stop=stop, step=step)


def create_try(
#     try_body: List[StatementNode],
#     catch_blocks: List[Tuple[VariableNode, Type, List[StatementNode]]],
finally_body: Optional[List[StatementNode]] = None,
# ) -TryNode):
#     """Create a try-catch block node"""
    return TryNode(
try_body = try_body, catch_blocks=catch_blocks, finally_body=finally_body
#     )


def create_raise(exception: Optional[ExpressionNode] = None) -RaiseNode):
#     """Create a raise statement node"""
return RaiseNode(exception = exception)


def create_async(body: List[StatementNode]) -AsyncNode):
#     """Create an async block node"""
return AsyncNode(body = body)


def create_await(value: ExpressionNode) -AwaitNode):
#     """Create an await expression node"""
return AwaitNode(value = value)


def create_class_def(
#     name: str,
#     base_classes: List[ExpressionNode],
#     body: List[Union[FunctionDefNode, PropertyDefNode]],
# ) -ClassDefNode):
#     """Create a class definition node"""
return ClassDefNode(name = name, base_classes=base_classes, body=body)


def create_property_def(
#     name: str,
#     type_hint: Optional[Type],
getter: Optional[List[StatementNode]] = None,
setter: Optional[List[StatementNode]] = None,
# ) -PropertyDefNode):
#     """Create a property definition node"""
return PropertyDefNode(name = name, type_hint=type_hint, getter=getter, setter=setter)


def create_decorator(name: str, arguments: List[ExpressionNode]) -DecoratorNode):
#     """Create a decorator node"""
return DecoratorNode(name = name, arguments=arguments)


# AST utility functions
def find_nodes(node: ASTNode, node_type: NodeType) -List[ASTNode]):
#     """Find all nodes of a specific type in the AST"""
result = []

#     def _find(n: ASTNode):
#         if n.node_type == node_type:
            result.append(n)
#         for child in n.get_children():
            _find(child)

    _find(node)
#     return result


def find_variable_declarations(node: ASTNode) -List[VariableNode]):
#     """Find all variable declarations in the AST"""
#     return [
#         n for n in find_nodes(node, NodeType.VARIABLE) if isinstance(n, VariableNode)
#     ]


def find_function_definitions(node: ASTNode) -List[FunctionDefNode]):
#     """Find all function definitions in the AST"""
#     return [
#         n
#         for n in find_nodes(node, NodeType.FUNCTION_DEF)
#         if isinstance(n, FunctionDefNode)
#     ]


def get_node_position(node: ASTNode) -Optional[Position]):
#     """Get the position of a node in the source code"""
#     if node.position:
#         return node.position

#     # If the node doesn't have a position, try to get it from the first child
#     for child in node.get_children():
pos = get_node_position(child)
#         if pos:
#             return pos

#     return None
