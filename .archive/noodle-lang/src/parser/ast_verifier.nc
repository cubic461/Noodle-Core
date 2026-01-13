# Converted from Python to NoodleCore
# Original file: src

# """
# AST Verifier for NoodleCore
# ---------------------------
# This module verifies that AST nodes conform to the NoodleCore language specification.
# It checks for proper node structure, valid relationships, and compliance with language rules.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import logging
import typing.List
from dataclasses import dataclass
import enum.Enum

import ..compiler.ast_nodes.(
#     ASTNode, ProgramNode, NodeType,
#     ExpressionNode, StatementNode,
#     FunctionDefNode, ClassDefNode, CallNode, AssignmentNode,
#     BinaryOpNode, UnaryOpNode, VariableNode, LiteralNode,
#     IfNode, WhileNode, ForNode, TryNode, ImportNode,
#     ListNode, MatrixNode, TensorNode, IndexNode, SliceNode,
#     ReturnNode, RaiseNode, AsyncNode, AwaitNode, ParameterNode,
#     PropertyDefNode, DecoratorNode
# )
import ..compiler.parser_ast_nodes.ProgramNode
import .foreign_syntax_detector.ValidationIssue


class ASTValidationErrorCode
    #     """Error codes for AST validation issues"""
    INVALID_NODE_STRUCTURE = 3001
    INVALID_PARENT_CHILD_RELATIONSHIP = 3002
    INVALID_NODE_TYPE = 3003
    MISSING_REQUIRED_CHILD = 3004
    INVALID_EXPRESSION_CONTEXT = 3005
    INVALID_STATEMENT_CONTEXT = 3006
    INVALID_FUNCTION_DEFINITION = 3007
    INVALID_CLASS_DEFINITION = 3008
    INVALID_IMPORT_STATEMENT = 3009
    INVALID_CONTROL_FLOW = 3010
    INVALID_VARIABLE_USAGE = 3011
    INVALID_TYPE_USAGE = 3012
    INVALID_OPERATOR_USAGE = 3013
    INVALID_LITERAL_VALUE = 3014
    INVALID_CALL_EXPRESSION = 3015
    INVALID_ASSIGNMENT_TARGET = 3016
    INVALID_INDEX_EXPRESSION = 3017
    INVALID_SLICE_EXPRESSION = 3018
    INVALID_ASYNC_USAGE = 3019
    INVALID_EXCEPTION_HANDLING = 3020
    INVALID_DECORATOR_USAGE = 3021
    CIRCULAR_REFERENCE = 3022
    UNREACHABLE_CODE = 3023
    DEAD_CODE = 3024


dataclass
class ASTValidationContext
    #     """Context for AST validation"""
    current_function: Optional[FunctionDefNode] = None
    current_class: Optional[ClassDefNode] = None
    in_loop: bool = False
    in_async_context: bool = False
    variables_defined: Set[str] = None
    functions_defined: Set[str] = None
    classes_defined: Set[str] = None

    #     def __post_init__(self):
    #         if self.variables_defined is None:
    self.variables_defined = set()
    #         if self.functions_defined is None:
    self.functions_defined = set()
    #         if self.classes_defined is None:
    self.classes_defined = set()


class ASTVerifier
    #     """
    #     Verifies AST nodes against the NoodleCore language specification

    #     This class performs comprehensive validation of AST nodes to ensure they
    #     conform to the NoodleCore language specification, including proper structure,
    #     valid relationships, and compliance with language rules.
    #     """

    #     def __init__(self):""Initialize the AST verifier"""
    self.logger = logging.getLogger("noodlecore.validator.ast_verifier")
    self.issues: List[ValidationIssue] = []
    self.context = ASTValidationContext()

    #         # Define valid node types for different contexts
    self.valid_statement_types = self._define_valid_statement_types()
    self.valid_expression_types = self._define_valid_expression_types()
    self.valid_binary_operators = self._define_valid_binary_operators()
    self.valid_unary_operators = self._define_valid_unary_operators()

            self.logger.info("AST verifier initialized")

    #     def _define_valid_statement_types(self) -Set[NodeType]):
    #         """Define valid node types for statements"""
    #         return {
    #             NodeType.ASSIGNMENT,
    #             NodeType.FUNCTION_DEF,
    #             NodeType.CLASS_DEF,
    #             NodeType.IF,
    #             NodeType.WHILE,
    #             NodeType.FOR,
    #             NodeType.TRY,
    #             NodeType.RETURN,
    #             NodeType.RAISE,
    #             NodeType.IMPORT,
    #             NodeType.ASYNC,
    #             NodeType.PROPERTY_DEF
    #         }

    #     def _define_valid_expression_types(self) -Set[NodeType]):
    #         """Define valid node types for expressions"""
    #         return {
    #             NodeType.LITERAL,
    #             NodeType.BINARY,
    #             NodeType.UNARY,
    #             NodeType.CALL,
    #             NodeType.VARIABLE,
    #             NodeType.LIST,
    #             NodeType.MATRIX,
    #             NodeType.TENSOR,
    #             NodeType.INDEX,
    #             NodeType.SLICE,
    #             NodeType.AWAIT,
    #             NodeType.DECORATOR
    #         }

    #     def _define_valid_binary_operators(self) -Set[str]):
    #         """Define valid binary operators in NoodleCore"""
    #         return {
    #             '+', '-', '*', '/', '//', '%', '**',
    ' = =', '!=', '<', '<=', '>', '>=',
    #             'and', 'or', 'is', 'in', 'not in',
    #             '&', '|', '^', '<<', '>>',
    ' = ', '+=', '-=', '*=', '/=', '%=', '**=', '//='
    #         }

    #     def _define_valid_unary_operators(self) -Set[str]):
    #         """Define valid unary operators in NoodleCore"""
    #         return {
    #             '+', '-', 'not', '~'
    #         }

    #     def verify_ast(self, ast: ProgramNode) -List[ValidationIssue]):
    #         """
    #         Verify an AST against the NoodleCore specification

    #         Args:
    #             ast: The AST to verify

    #         Returns:
    #             List of validation issues found
    #         """
            self.issues.clear()
    self.context = ASTValidationContext()

    #         if not isinstance(ast, (ProgramNode, ParserProgramNode)):
                self._add_issue(
    line_number = 0,
    column = 0,
    severity = ValidationSeverity.ERROR,
    message = f"Root node must be a ProgramNode, got {type(ast).__name__}",
    error_code = ASTValidationErrorCode.INVALID_NODE_TYPE
    #             )
    #             return self.issues

    #         # Verify the program node
            self._verify_program_node(ast)

    #         self.logger.info(f"AST verification completed with {len(self.issues)} issues")
    #         return self.issues

    #     def _verify_program_node(self, node: ProgramNode):
    #         """Verify a program node"""
    #         # Check that all children are statements
    #         for child in node.children:
    #             if child.node_type not in self.valid_statement_types:
                    self._add_issue(
    #                     line_number=getattr(child.position, 'line', 0) if child.position else 0,
    #                     column=getattr(child.position, 'column', 0) if child.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Invalid statement type in program: {child.node_type.value}",
    error_code = ASTValidationErrorCode.INVALID_STATEMENT_CONTEXT
    #                 )

    #         # Verify each statement
    #         for stmt in node.statements:
                self._verify_statement(stmt)

    #     def _verify_statement(self, stmt: StatementNode):
    #         """Verify a statement node"""
    #         if not stmt:
    #             return

    #         # Verify based on statement type
    #         if stmt.node_type == NodeType.ASSIGNMENT:
                self._verify_assignment_node(stmt)
    #         elif stmt.node_type == NodeType.FUNCTION_DEF:
                self._verify_function_def_node(stmt)
    #         elif stmt.node_type == NodeType.CLASS_DEF:
                self._verify_class_def_node(stmt)
    #         elif stmt.node_type == NodeType.IF:
                self._verify_if_node(stmt)
    #         elif stmt.node_type == NodeType.WHILE:
                self._verify_while_node(stmt)
    #         elif stmt.node_type == NodeType.FOR:
                self._verify_for_node(stmt)
    #         elif stmt.node_type == NodeType.TRY:
                self._verify_try_node(stmt)
    #         elif stmt.node_type == NodeType.RETURN:
                self._verify_return_node(stmt)
    #         elif stmt.node_type == NodeType.RAISE:
                self._verify_raise_node(stmt)
    #         elif stmt.node_type == NodeType.IMPORT:
                self._verify_import_node(stmt)
    #         elif stmt.node_type == NodeType.ASYNC:
                self._verify_async_node(stmt)
    #         elif stmt.node_type == NodeType.PROPERTY_DEF:
                self._verify_property_def_node(stmt)
    #         else:
                self._add_issue(
    #                 line_number=getattr(stmt.position, 'line', 0) if stmt.position else 0,
    #                 column=getattr(stmt.position, 'column', 0) if stmt.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Unknown statement type: {stmt.node_type.value}",
    error_code = ASTValidationErrorCode.INVALID_STATEMENT_CONTEXT
    #             )

    #     def _verify_expression(self, expr: ExpressionNode):
    #         """Verify an expression node"""
    #         if not expr:
    #             return

    #         # Verify based on expression type
    #         if expr.node_type == NodeType.LITERAL:
                self._verify_literal_node(expr)
    #         elif expr.node_type == NodeType.BINARY:
                self._verify_binary_op_node(expr)
    #         elif expr.node_type == NodeType.UNARY:
                self._verify_unary_op_node(expr)
    #         elif expr.node_type == NodeType.CALL:
                self._verify_call_node(expr)
    #         elif expr.node_type == NodeType.VARIABLE:
                self._verify_variable_node(expr)
    #         elif expr.node_type == NodeType.LIST:
                self._verify_list_node(expr)
    #         elif expr.node_type == NodeType.MATRIX:
                self._verify_matrix_node(expr)
    #         elif expr.node_type == NodeType.TENSOR:
                self._verify_tensor_node(expr)
    #         elif expr.node_type == NodeType.INDEX:
                self._verify_index_node(expr)
    #         elif expr.node_type == NodeType.SLICE:
                self._verify_slice_node(expr)
    #         elif expr.node_type == NodeType.AWAIT:
                self._verify_await_node(expr)
    #         elif expr.node_type == NodeType.DECORATOR:
                self._verify_decorator_node(expr)
    #         else:
                self._add_issue(
    #                 line_number=getattr(expr.position, 'line', 0) if expr.position else 0,
    #                 column=getattr(expr.position, 'column', 0) if expr.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Unknown expression type: {expr.node_type.value}",
    error_code = ASTValidationErrorCode.INVALID_EXPRESSION_CONTEXT
    #             )

    #     def _verify_assignment_node(self, node: AssignmentNode):
    #         """Verify an assignment node"""
    #         # Check that target is valid
    #         if not isinstance(node.target, (VariableNode, IndexNode)):
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Assignment target must be a variable or index expression",
    error_code = ASTValidationErrorCode.INVALID_ASSIGNMENT_TARGET
    #             )

    #         # Check that value is an expression
    #         if node.value and node.value.node_type not in self.valid_expression_types:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Assignment value must be an expression",
    error_code = ASTValidationErrorCode.INVALID_EXPRESSION_CONTEXT
    #             )

    #         # Verify sub-expressions
    #         if node.target:
                self._verify_expression(node.target)
    #         if node.value:
                self._verify_expression(node.value)

    #         # Track variable definitions
    #         if isinstance(node.target, VariableNode):
                self.context.variables_defined.add(node.target.name)

    #     def _verify_function_def_node(self, node: FunctionDefNode):
    #         """Verify a function definition node"""
    #         # Save previous context
    prev_function = self.context.current_function
    prev_variables = self.context.variables_defined.copy()

    #         # Update context
    self.context.current_function = node
            self.context.variables_defined.clear()

    #         # Add parameters to defined variables
    #         for param in node.parameters:
                self.context.variables_defined.add(param.name)

    #         # Track function definition
            self.context.functions_defined.add(node.name)

    #         # Verify parameters
    #         for param in node.parameters:
    #             if param.default_value:
                    self._verify_expression(param.default_value)

    #         # Verify function body
    #         for stmt in node.body:
                self._verify_statement(stmt)

    #         # Check for return statements in non-void functions
    #         if node.return_type and not any(stmt.node_type == NodeType.RETURN for stmt in node.body):
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.WARNING,
    message = f"Function '{node.name}' has return type but no return statements",
    error_code = ASTValidationErrorCode.INVALID_FUNCTION_DEFINITION
    #             )

    #         # Restore context
    self.context.current_function = prev_function
    self.context.variables_defined = prev_variables

    #         # Verify decorators
    #         for decorator in node.decorators:
                self._verify_expression(decorator)

    #     def _verify_class_def_node(self, node: ClassDefNode):
    #         """Verify a class definition node"""
    #         # Save previous context
    #         prev_class = self.context.current_class
    prev_variables = self.context.variables_defined.copy()

    #         # Update context
    #         self.context.current_class = node
            self.context.variables_defined.clear()

    #         # Track class definition
            self.context.classes_defined.add(node.name)

    #         # Verify base classes
    #         for base in node.base_classes:
                self._verify_expression(base)

    #         # Verify class body
    #         for member in node.body:
    #             if isinstance(member, FunctionDefNode):
                    self._verify_function_def_node(member)
    #             elif isinstance(member, PropertyDefNode):
                    self._verify_property_def_node(member)
    #             else:
                    self._add_issue(
    #                     line_number=getattr(member.position, 'line', 0) if member.position else 0,
    #                     column=getattr(member.position, 'column', 0) if member.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Class body can only contain function definitions and property definitions",
    error_code = ASTValidationErrorCode.INVALID_CLASS_DEFINITION
    #                 )

    #         # Restore context
    #         self.context.current_class = prev_class
    self.context.variables_defined = prev_variables

    #     def _verify_if_node(self, node: IfNode):""Verify an if statement node"""
    #         # Verify condition
    #         if node.condition:
                self._verify_expression(node.condition)

    #         # Verify then body
    #         for stmt in node.then_body:
                self._verify_statement(stmt)

    #         # Verify elif clauses
    #         for condition, body in node.elif_clauses:
                self._verify_expression(condition)
    #             for stmt in body:
                    self._verify_statement(stmt)

    #         # Verify else body
    #         if node.else_body:
    #             for stmt in node.else_body:
                    self._verify_statement(stmt)

    #     def _verify_while_node(self, node: WhileNode):
    #         """Verify a while loop node"""
    #         # Save previous context
    prev_in_loop = self.context.in_loop

    #         # Update context
    self.context.in_loop = True

    #         # Verify condition
    #         if node.condition:
                self._verify_expression(node.condition)

    #         # Verify body
    #         for stmt in node.body:
                self._verify_statement(stmt)

    #         # Restore context
    self.context.in_loop = prev_in_loop

    #     def _verify_for_node(self, node: ForNode):
    #         """Verify a for loop node"""
    #         # Save previous context
    prev_in_loop = self.context.in_loop

    #         # Update context
    self.context.in_loop = True

    #         # Verify variable
    #         if node.variable:
                self._verify_expression(node.variable)
    #             if isinstance(node.variable, VariableNode):
                    self.context.variables_defined.add(node.variable.name)

    #         # Verify iterable
    #         if node.iterable:
                self._verify_expression(node.iterable)

    #         # Verify body
    #         for stmt in node.body:
                self._verify_statement(stmt)

    #         # Restore context
    self.context.in_loop = prev_in_loop

    #     def _verify_try_node(self, node: TryNode):
    #         """Verify a try-catch node"""
    #         # Verify try body
    #         for stmt in node.try_body:
                self._verify_statement(stmt)

    #         # Verify catch blocks
    #         for var, exc_type, body in node.catch_blocks:
    #             if var:
                    self._verify_expression(var)
    #             if body:
    #                 for stmt in body:
                        self._verify_statement(stmt)

    #         # Verify finally body
    #         if node.finally_body:
    #             for stmt in node.finally_body:
                    self._verify_statement(stmt)

    #     def _verify_return_node(self, node: ReturnNode):
    #         """Verify a return statement node"""
    #         # Check if return is in a function
    #         if not self.context.current_function:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Return statement outside of function",
    error_code = ASTValidationErrorCode.INVALID_CONTROL_FLOW
    #             )

    #         # Verify return value
    #         if node.value:
                self._verify_expression(node.value)

    #     def _verify_raise_node(self, node: RaiseNode):
    #         """Verify a raise statement node"""
    #         # Verify exception
    #         if node.exception:
                self._verify_expression(node.exception)

    #     def _verify_import_node(self, node: ImportNode):
    #         """Verify an import statement node"""
    #         # Check that module name is provided
    #         if not node.module:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Import statement must specify a module",
    error_code = ASTValidationErrorCode.INVALID_IMPORT_STATEMENT
    #             )

    #     def _verify_async_node(self, node: AsyncNode):
    #         """Verify an async node"""
    #         # Save previous context
    prev_in_async = self.context.in_async_context

    #         # Update context
    self.context.in_async_context = True

    #         # Verify body
    #         for stmt in node.body:
                self._verify_statement(stmt)

    #         # Restore context
    self.context.in_async_context = prev_in_async

    #     def _verify_property_def_node(self, node: PropertyDefNode):
    #         """Verify a property definition node"""
    #         # Check if property is in a class
    #         if not self.context.current_class:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Property definition outside of class",
    error_code = ASTValidationErrorCode.INVALID_CLASS_DEFINITION
    #             )

    #         # Verify getter
    #         if node.getter:
    #             for stmt in node.getter:
                    self._verify_statement(stmt)

    #         # Verify setter
    #         if node.setter:
    #             for stmt in node.setter:
                    self._verify_statement(stmt)

    #     def _verify_literal_node(self, node: LiteralNode):
    #         """Verify a literal node"""
    #         # Check that value is not None for non-None literals
    #         if node.value is None and node.literal_type.value not in ('none', 'null'):
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Literal value cannot be None",
    error_code = ASTValidationErrorCode.INVALID_LITERAL_VALUE
    #             )

    #     def _verify_binary_op_node(self, node: BinaryOpNode):
    #         """Verify a binary operation node"""
    #         # Check that operator is valid
    #         if node.operator not in self.valid_binary_operators:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Invalid binary operator: {node.operator}",
    error_code = ASTValidationErrorCode.INVALID_OPERATOR_USAGE
    #             )

    #         # Verify operands
    #         if node.left:
                self._verify_expression(node.left)
    #         if node.right:
                self._verify_expression(node.right)

    #     def _verify_unary_op_node(self, node: UnaryOpNode):
    #         """Verify a unary operation node"""
    #         # Check that operator is valid
    #         if node.operator not in self.valid_unary_operators:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Invalid unary operator: {node.operator}",
    error_code = ASTValidationErrorCode.INVALID_OPERATOR_USAGE
    #             )

    #         # Verify operand
    #         if node.operand:
                self._verify_expression(node.operand)

    #     def _verify_call_node(self, node: CallNode):
    #         """Verify a function call node"""
    #         # Verify function
    #         if node.function:
                self._verify_expression(node.function)

    #         # Verify arguments
    #         for arg in node.arguments:
                self._verify_expression(arg)

    #         # Check async call
    #         if node.is_async and not self.context.in_async_context:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Async call outside of async context",
    error_code = ASTValidationErrorCode.INVALID_ASYNC_USAGE
    #             )

    #     def _verify_variable_node(self, node: VariableNode):
    #         """Verify a variable node"""
    #         # Check if variable is defined
    #         if (node.name not in self.context.variables_defined and
    #             node.name not in self.context.functions_defined and
    #             node.name not in self.context.classes_defined):
    #             # This might be a global or imported variable, so just a warning
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.WARNING,
    message = f"Variable '{node.name}' may not be defined",
    error_code = ASTValidationErrorCode.INVALID_VARIABLE_USAGE
    #             )

    #     def _verify_list_node(self, node: ListNode):
    #         """Verify a list node"""
    #         # Verify elements
    #         for element in node.elements:
                self._verify_expression(element)

    #     def _verify_matrix_node(self, node: MatrixNode):
    #         """Verify a matrix node"""
    #         # Verify rows
    #         for row in node.rows:
    #             for element in row:
                    self._verify_expression(element)

    #         # Check that all rows have the same length
    #         if node.rows:
    row_length = len(node.rows[0])
    #             for i, row in enumerate(node.rows):
    #                 if len(row) != row_length:
                        self._add_issue(
    #                         line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                         column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Matrix row {i} has inconsistent length",
    error_code = ASTValidationErrorCode.INVALID_LITERAL_VALUE
    #                     )

    #     def _verify_tensor_node(self, node: TensorNode):
    #         """Verify a tensor node"""
    #         # Verify data
    #         for element in node.data:
                self._verify_expression(element)

    #         # Check that shape matches data size
    #         if node.shape:
    expected_size = 1
    #             for dim in node.shape:
    expected_size * = dim

    #             if len(node.data) != expected_size:
                    self._add_issue(
    #                     line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                     column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = f"Tensor shape {node.shape} does not match data size {len(node.data)}",
    error_code = ASTValidationErrorCode.INVALID_LITERAL_VALUE
    #                 )

    #     def _verify_index_node(self, node: IndexNode):
    #         """Verify an index node"""
    #         # Verify target
    #         if node.target:
                self._verify_expression(node.target)

    #         # Verify indices
    #         for index in node.indices:
    #             if isinstance(index, (ExpressionNode, SliceNode)):
                    self._verify_expression(index)

    #     def _verify_slice_node(self, node: SliceNode):
    #         """Verify a slice node"""
    #         # Verify start, stop, step
    #         if node.start:
                self._verify_expression(node.start)
    #         if node.stop:
                self._verify_expression(node.stop)
    #         if node.step:
                self._verify_expression(node.step)

    #     def _verify_await_node(self, node: AwaitNode):
    #         """Verify an await node"""
    #         # Check if in async context
    #         if not self.context.in_async_context:
                self._add_issue(
    #                 line_number=getattr(node.position, 'line', 0) if node.position else 0,
    #                 column=getattr(node.position, 'column', 0) if node.position else 0,
    severity = ValidationSeverity.ERROR,
    message = "Await expression outside of async context",
    error_code = ASTValidationErrorCode.INVALID_ASYNC_USAGE
    #             )

    #         # Verify value
    #         if node.value:
                self._verify_expression(node.value)

    #     def _verify_decorator_node(self, node: DecoratorNode):
    #         """Verify a decorator node"""
    #         # Verify arguments
    #         for arg in node.arguments:
                self._verify_expression(arg)

    #     def _add_issue(self, line_number: int, column: int, severity: ValidationSeverity,
    #                    message: str, error_code: int):
    #         """Add a validation issue"""
    issue = ValidationIssue(
    line_number = line_number,
    column = column,
    severity = severity,
    message = message,
    error_code = error_code
    #         )
            self.issues.append(issue)