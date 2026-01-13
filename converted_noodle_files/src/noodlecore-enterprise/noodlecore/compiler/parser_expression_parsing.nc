# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Expression Parsing for Noodle Programming Language
# --------------------------------------------------
# This module implements expression parsing for the Noodle parser.
# It handles the parsing of expressions with operator precedence.
# Supports complex expressions with type inference and error handling.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import time
import threading
import typing.List,
import .lexer_tokens.Token,
import .parser_ast_nodes.(
#     ExpressionNode,
#     BinaryExprNode,
#     UnaryExprNode,
#     IdentifierExprNode,
#     LiteralExprNode,
#     CallExprNode,
#     ParenExprNode,
#     ListExprNode,
#     DictExprNode,
#     SliceExprNode,
#     TernaryExprNode,
# )


class ExpressionParser
    #     """Handles expression parsing with operator precedence"""

    #     def __init__(self, lexer, tokens=None, token_index=0):
    self.lexer = lexer
    #         # Use the provided tokens and token index
    #         self.tokens = tokens if tokens is not None else self.lexer.tokens
    self.token_index = token_index
    #         self.current_token = self.tokens[self.token_index] if self.token_index < len(self.tokens) else None

    #         # Error handling and recovery
    self.error_count = 0
    self.max_errors = 10
    self.error_recovery_enabled = True

    #         # Performance tracking
    self.parse_start_time = time.time()
    self.parse_count = 0
    self.total_parse_time = 0.0

    #         # Type inference cache
    self.type_cache: Dict[ExpressionNode, str] = {}

            # Operator precedence table (extended)
    self.precedence_table = {
    #             TokenType.OR.value: 1,
    #             TokenType.AND.value: 2,
    #             TokenType.EQUAL.value: 3,
    #             TokenType.NOT_EQUAL.value: 3,
    #             TokenType.LESS_THAN.value: 4,
    #             TokenType.GREATER_THAN.value: 4,
    #             TokenType.LESS_EQUAL.value: 4,
    #             TokenType.GREATER_EQUAL.value: 4,
                TokenType.RANGE.value: 4,  # Range operator (..)
    #             TokenType.PLUS.value: 5,
    #             TokenType.MINUS.value: 5,
    #             TokenType.MULTIPLY.value: 6,
    #             TokenType.DIVIDE.value: 6,
    #             TokenType.MODULO.value: 6,
    #             TokenType.POWER.value: 7,
    #             TokenType.BITWISE_AND.value: 8,
    #             TokenType.BITWISE_OR.value: 8,
    #             TokenType.BITWISE_XOR.value: 8,
    #             TokenType.BITWISE_SHIFT_LEFT.value: 9,
    #             TokenType.BITWISE_SHIFT_RIGHT.value: 9,
    #         }

    #         # Associativity table
    self.associativity_table = {
    #             TokenType.POWER.value: 'right',
    #             TokenType.BITWISE_SHIFT_LEFT.value: 'left',
    #             TokenType.BITWISE_SHIFT_RIGHT.value: 'left',
    #             TokenType.MULTIPLY.value: 'left',
    #             TokenType.DIVIDE.value: 'left',
    #             TokenType.MODULO.value: 'left',
    #             TokenType.PLUS.value: 'left',
    #             TokenType.MINUS.value: 'left',
    #             TokenType.BITWISE_AND.value: 'left',
    #             TokenType.BITWISE_XOR.value: 'left',
    #             TokenType.BITWISE_OR.value: 'left',
    #             TokenType.EQUAL.value: 'left',
    #             TokenType.NOT_EQUAL.value: 'left',
    #             TokenType.LESS_THAN.value: 'left',
    #             TokenType.GREATER_THAN.value: 'left',
    #             TokenType.LESS_EQUAL.value: 'left',
    #             TokenType.GREATER_EQUAL.value: 'left',
    #             TokenType.RANGE.value: 'left',  # Range operator is left-associative
    #             TokenType.AND.value: 'left',
    #             TokenType.OR.value: 'left',
    #         }

    #         # Thread safety
    self._lock = threading.RLock()

    #         # Expression optimization flags
    self.enable_constant_folding = True
    self.enable_dead_code_elimination = True
    self.enable_short_circuit_evaluation = True

    #         # Expression context
    self.in_parenthesis = 0
    self.in_list = 0
    self.in_dict = 0

    #     def eat(self, token_type):
    #         """Consume the current token if it matches the expected type"""
    #         if self.current_token and self.current_token.type.value == token_type.value:
    #             # Move to the next token using our index
    self.token_index + = 1
    #             if self.token_index < len(self.tokens):
    self.current_token = self.tokens[self.token_index]
    #             else:
    self.current_token = Token(TokenType.EOF, "", None)
    #         else:
    #             self.error(f"Expected {token_type}, got {self.current_token.type if self.current_token else 'None'}")

    #     def error(self, message):
    #         """Raise a parsing error"""
            raise Exception(f"Parser error: {message}")

    #     def parse_expression(self) -> ExpressionNode:
    #         """Parse an expression"""
            print(f"DEBUG: ExpressionParser.parse_expression() called - current_token: {self.current_token}, token_index: {self.token_index}")
    result = self.parse_binary_expression(0)
            print(f"DEBUG: ExpressionParser.parse_expression() done - current_token: {self.current_token}, token_index: {self.token_index}")
    #         return result

    #     def parse_binary_expression(self, precedence: int) -> ExpressionNode:
    #         """Parse a binary expression with operator precedence"""
    left = self.parse_primary_expression()

    #         while True:
    operator = self.current_token.value
    operator_type = self.current_token.type

    #             # Check if this is a binary operator
    #             if operator_type.value not in [
    #                 TokenType.PLUS.value,
    #                 TokenType.MINUS.value,
    #                 TokenType.MULTIPLY.value,
    #                 TokenType.DIVIDE.value,
    #                 TokenType.EQUAL.value,
    #                 TokenType.NOT_EQUAL.value,
    #                 TokenType.LESS_THAN.value,
    #                 TokenType.GREATER_THAN.value,
    #                 TokenType.LESS_EQUAL.value,
    #                 TokenType.GREATER_EQUAL.value,
    #                 TokenType.RANGE.value,  # Add range operator
    #                 TokenType.AND.value,
    #                 TokenType.OR.value,
    #             ]:
    #                 break

    #             # Get precedence of current operator
    current_precedence = self.precedence_table.get(operator_type.value, 0)

    #             # If current operator has lower precedence, stop
    #             if current_precedence < precedence:
    #                 break

    #             # Consume the operator
                self.eat(operator_type)

    #             # Parse right side with higher or equal precedence
    #             if (self.get_operator_associativity(operator_type) == 'left' and
    current_precedence = = precedence):
    right = self.parse_binary_expression(current_precedence)
    #             else:
    right = math.add(self.parse_binary_expression(current_precedence, 1))

    #             # Create binary expression node
    left = BinaryExprNode(left, operator, right)

    #         return left

    #     def parse_primary_expression(self) -> ExpressionNode:
    #         """Parse a primary expression"""
    token = self.current_token

    #         if token.type.value == TokenType.EOF.value:
    #             # EOF should be handled gracefully, return None
    #             return None
    #         elif token.type.value == TokenType.INTEGER.value:
                self.eat(TokenType.INTEGER)
                return LiteralExprNode(token.value, "int")
    #         elif token.type.value == TokenType.FLOAT.value:
                self.eat(TokenType.FLOAT)
                return LiteralExprNode(token.value, "float")
    #         elif token.type.value == TokenType.NUMBER.value:
                self.eat(TokenType.NUMBER)
    #             # Try to determine if it's an integer or float
    #             if '.' in token.value or 'e' in token.value.lower():
                    return LiteralExprNode(token.value, "float")
    #             else:
                    return LiteralExprNode(token.value, "int")
    #         elif token.type.value == TokenType.STRING.value:
                self.eat(TokenType.STRING)
                return LiteralExprNode(token.value, "str")
    #         elif token.type.value == TokenType.BOOLEAN.value:
                self.eat(TokenType.BOOLEAN)
                return LiteralExprNode(token.value, "bool")
    #         elif token.type.value == TokenType.IDENTIFIER.value:
    name = token.value
                self.eat(TokenType.IDENTIFIER)

    #             # Check if this is a function call
    #             if self.current_token.type.value == TokenType.LPAREN.value:
                    return self.parse_function_call(name)
    #             else:
                    return IdentifierExprNode(name)
    #         elif token.type.value == TokenType.LPAREN.value:
                self.eat(TokenType.LPAREN)
    expression = self.parse_expression()
                self.eat(TokenType.RPAREN)
                return ParenExprNode(expression)
    #         elif token.type.value == TokenType.LBRACKET.value:
                return self.parse_list_expression()
    #         elif token.type.value == TokenType.LBRACE.value:
                return self.parse_dict_expression()
    #         else:
                self.error(f"Unexpected token: {token.type}")
    #             return None

    #     def parse_function_call(self, function_name: str) -> CallExprNode:
    #         """Parse a function call"""
            self.eat(TokenType.LPAREN)
    arguments = []

    #         while self.current_token.type.value != TokenType.RPAREN.value:
                arguments.append(self.parse_expression())

    #             if self.current_token.type.value == TokenType.COMMA.value:
                    self.eat(TokenType.COMMA)

            self.eat(TokenType.RPAREN)
            return CallExprNode(IdentifierExprNode(function_name), arguments)

    #     def parse_list_expression(self) -> ListExprNode:
    #         """Parse a list expression"""
            self.eat(TokenType.LBRACKET)
    elements = []

    #         while self.current_token.type.value != TokenType.RBRACKET.value:
                elements.append(self.parse_expression())

    #             if self.current_token.type.value == TokenType.COMMA.value:
                    self.eat(TokenType.COMMA)

            self.eat(TokenType.RBRACKET)
            return ListExprNode(elements)

    #     def parse_dict_expression(self) -> DictExprNode:
    #         """Parse a dictionary expression"""
            self.eat(TokenType.LBRACE)
    pairs = []

    #         while self.current_token.type.value != TokenType.RBRACE.value:
    key = self.parse_expression()
                self.eat(TokenType.COLON)
    value = self.parse_expression()
                pairs.append({"key": key, "value": value})

    #             if self.current_token.type.value == TokenType.COMMA.value:
                    self.eat(TokenType.COMMA)

            self.eat(TokenType.RBRACE)
            return DictExprNode(pairs)

    #     def parse_ternary_expression(self, condition: ExpressionNode) -> TernaryExprNode:
    #         """Parse a ternary conditional expression"""
            self.eat(TokenType.QUESTION)
    if_true = self.parse_expression()
            self.eat(TokenType.COLON)
    if_false = self.parse_expression()
            return TernaryExprNode(condition, if_true, if_false)

    #     def error(self, message: str):
    #         """Raise an error with the given message"""
    self.error_count + = 1
    #         if self.error_count > self.max_errors and self.error_recovery_enabled:
                self.recover_from_error()
            raise Exception(f"Parser error: {message}")

    #     def recover_from_error(self):
    #         """Attempt to recover from parsing errors"""
    #         # Skip tokens until we find a statement boundary
    #         while self.token_index < len(self.tokens):
    token = self.current_token
    #             if token.type.value in [TokenType.SEMICOLON.value, TokenType.NEWLINE.value]:
                    self.eat(token.type)
    #                 break
    #             elif token.type.value == TokenType.EOF.value:
    #                 break
    #             else:
    self.token_index + = 1
    #                 if self.token_index < len(self.tokens):
    self.current_token = self.tokens[self.token_index]

    #     def get_operator_associativity(self, operator_type: TokenType) -> str:
    #         """Get the associativity of an operator"""
            return self.associativity_table.get(operator_type.value, 'left')

    #     def parse_unary_expression(self) -> ExpressionNode:
    #         """Parse a unary expression"""
    token = self.current_token

    #         if token.type.value in [TokenType.MINUS.value, TokenType.NOT.value, TokenType.BANG.value]:
    operator = token.value
    operator_type = token.type
                self.eat(operator_type)
    operand = self.parse_unary_expression()
                return UnaryExprNode(operator, operand)

            return self.parse_primary_expression()

    #     def parse_postfix_expression(self, expr: ExpressionNode) -> ExpressionNode:
    #         """Parse postfix expressions after primary expressions"""
    #         while True:
    token = self.current_token

    #             if token.type.value == TokenType.LPAREN.value:
    #                 # Function call
    expr = self.parse_function_call(expr)
    #             elif token.type.value == TokenType.LBRACKET.value:
    #                 # Array/list indexing
    expr = self.parse_index_expression(expr)
    #             elif token.type.value == TokenType.DOT.value:
    #                 # Member access
    expr = self.parse_member_access(expr)
    #             elif token.type.value == TokenType.INCREMENT.value:
    #                 # Post-increment
                    self.eat(TokenType.INCREMENT)
    expr = BinaryExprNode(expr, '++', None)
    #             elif token.type.value == TokenType.DECREMENT.value:
    #                 # Post-decrement
                    self.eat(TokenType.DECREMENT)
    expr = BinaryExprNode(expr, '--', None)
    #             else:
    #                 break

    #         return expr

    #     def parse_index_expression(self, expr: ExpressionNode) -> ExpressionNode:
    #         """Parse array/list indexing expression"""
            self.eat(TokenType.LBRACKET)
    index = self.parse_expression()
            self.eat(TokenType.RBRACKET)
            return SliceExprNode(expr, index)

    #     def parse_member_access(self, expr: ExpressionNode) -> ExpressionNode:
    #         """Parse member access expression"""
            self.eat(TokenType.DOT)
    #         if self.current_token.type.value != TokenType.IDENTIFIER.value:
                self.error("Expected identifier after dot operator")

    member_name = self.current_token.value
            self.eat(TokenType.IDENTIFIER)
            return BinaryExprNode(expr, '.', IdentifierExprNode(member_name))

    #     def parse_assignment_expression(self) -> ExpressionNode:
    #         """Parse assignment expressions"""
    left = self.parse_binary_expression(0)

    #         # Check for assignment operator
    #         if self.current_token.type.value == TokenType.EQUAL.value:
                self.eat(TokenType.EQUAL)
    right = self.parse_assignment_expression()
    return BinaryExprNode(left, ' = ', right)
    #         elif self.current_token.type.value in [
    #             TokenType.PLUS_EQUAL.value,
    #             TokenType.MINUS_EQUAL.value,
    #             TokenType.MULTIPLY_EQUAL.value,
    #             TokenType.DIVIDE_EQUAL.value,
    #         ]:
    operator = self.current_token.value
    operator_type = self.current_token.type
                self.eat(operator_type)
    right = self.parse_assignment_expression()
    return BinaryExprNode(BinaryExprNode(left, operator[:-1], right), ' = ', right)

    #         return left

    #     def parse_ternary_if(self, condition: ExpressionNode) -> ExpressionNode:
    #         """Parse ternary conditional expressions"""
    #         if self.current_token.type.value == TokenType.QUESTION.value:
                return self.parse_ternary_expression(condition)
    #         return condition

    #     def optimize_expression(self, expr: ExpressionNode) -> ExpressionNode:
    #         """Apply optimizations to expressions"""
    #         if not self.enable_constant_folding:
    #             return expr

    #         # Constant folding for literals
    #         if isinstance(expr, BinaryExprNode):
    #             if (isinstance(expr.left, LiteralExprNode) and
                    isinstance(expr.right, LiteralExprNode)):
    #                 try:
    #                     if expr.operator == '+':
    value = math.add(float(expr.left.value), float(expr.right.value))
    #                     elif expr.operator == '-':
    value = math.subtract(float(expr.left.value), float(expr.right.value))
    #                     elif expr.operator == '*':
    value = math.multiply(float(expr.left.value), float(expr.right.value))
    #                     elif expr.operator == '/':
    value = math.divide(float(expr.left.value), float(expr.right.value))
    #                     else:
    #                         return expr

    #                     # Determine type
    #                     if isinstance(value, int):
    type_name = 'int'
    #                     else:
    type_name = 'float'

                        return LiteralExprNode(value, type_name)
                    except (ValueError, ZeroDivisionError):
    #                     pass

    #         return expr

    #     def infer_expression_type(self, expr: ExpressionNode) -> str:
    #         """Infer the type of an expression"""
    #         if expr in self.type_cache:
    #             return self.type_cache[expr]

    #         if isinstance(expr, LiteralExprNode):
    expr_type = expr.type
    #         elif isinstance(expr, IdentifierExprNode):
    expr_type = 'unknown'  # Need symbol table lookup
    #         elif isinstance(expr, BinaryExprNode):
    left_type = self.infer_expression_type(expr.left)
    right_type = self.infer_expression_type(expr.right)

    #             # Type promotion rules
    #             if left_type == 'float' or right_type == 'float':
    expr_type = 'float'
    #             else:
    expr_type = left_type  # Simplified type inference
    #         elif isinstance(expr, UnaryExprNode):
    expr_type = self.infer_expression_type(expr.operand)
    #         elif isinstance(expr, CallExprNode):
    expr_type = 'unknown'  # Need function signature lookup
    #         else:
    expr_type = 'unknown'

    self.type_cache[expr] = expr_type
    #         return expr_type

    #     def get_parse_statistics(self) -> Dict[str, Any]:
    #         """Get parsing statistics"""
    parse_time = math.subtract(time.time(), self.parse_start_time)

    #         return {
    #             'parse_count': self.parse_count,
    #             'total_parse_time': parse_time,
                'average_parse_time': parse_time / max(self.parse_count, 1),
    #             'error_count': self.error_count,
                'error_rate': self.error_count / max(self.parse_count, 1),
                'type_cache_size': len(self.type_cache),
                'precedence_table_size': len(self.precedence_table),
                'associativity_table_size': len(self.associativity_table),
    #             'optimization_enabled': {
    #                 'constant_folding': self.enable_constant_folding,
    #                 'dead_code_elimination': self.enable_dead_code_elimination,
    #                 'short_circuit_evaluation': self.enable_short_circuit_evaluation,
    #             },
    #         }

    #     def reset_statistics(self):
    #         """Reset parsing statistics"""
    self.error_count = 0
    self.parse_count = 0
    self.total_parse_time = 0.0
            self.type_cache.clear()

    #     def set_optimization_flags(self, constant_folding: bool = None,
    dead_code_elimination: bool = None,
    short_circuit_evaluation: bool = None):
    #         """Set optimization flags"""
    #         if constant_folding is not None:
    self.enable_constant_folding = constant_folding
    #         if dead_code_elimination is not None:
    self.enable_dead_code_elimination = dead_code_elimination
    #         if short_circuit_evaluation is not None:
    self.enable_short_circuit_evaluation = short_circuit_evaluation

    #     def parse_expression_with_context(self) -> ExpressionNode:
    #         """Parse expression with context tracking"""
    start_time = time.time()
    self.parse_count + = 1

    #         try:
    #             # Track expression context
    original_context = {
    #                 'in_parenthesis': self.in_parenthesis,
    #                 'in_list': self.in_list,
    #                 'in_dict': self.in_dict,
    #             }

    expr = self.parse_assignment_expression()
    expr = self.parse_ternary_if(expr)
    expr = self.parse_postfix_expression(expr)

    #             # Apply optimizations
    #             if self.enable_constant_folding:
    expr = self.optimize_expression(expr)

    #             # Infer type
    expr_type = self.infer_expression_type(expr)

    #             return expr

    #         finally:
    self.total_parse_time + = math.subtract(time.time(), start_time)

    #     def validate_expression(self, expr: ExpressionNode) -> List[str]:
    #         """Validate an expression and return any issues"""
    issues = []

    #         # Check for undefined identifiers (simplified)
    #         if isinstance(expr, IdentifierExprNode):
    #             # In a real implementation, we'd check symbol tables
    #             pass

    #         # Check for division by zero
    #         if isinstance(expr, BinaryExprNode) and expr.operator == '/':
    #             # Simplified check - in practice we'd need constant folding
    #             pass

    #         # Check for type mismatches
    #         try:
    expr_type = self.infer_expression_type(expr)
    #             if expr_type == 'unknown':
                    issues.append("Cannot determine expression type")
    #         except Exception as e:
                issues.append(f"Type inference error: {str(e)}")

    #         return issues

    #     def get_expression_complexity(self, expr: ExpressionNode) -> int:
    #         """Calculate expression complexity"""
    #         if isinstance(expr, LiteralExprNode):
    #             return 1
    #         elif isinstance(expr, IdentifierExprNode):
    #             return 1
    #         elif isinstance(expr, UnaryExprNode):
                return 1 + self.get_expression_complexity(expr.operand)
    #         elif isinstance(expr, BinaryExprNode):
                return (1 +
                       self.get_expression_complexity(expr.left) +
                       self.get_expression_complexity(expr.right))
    #         elif isinstance(expr, CallExprNode):
                return (1 +
                       self.get_expression_complexity(expr.function) +
    #                    sum(self.get_expression_complexity(arg) for arg in expr.arguments))
    #         else:
    #             return 1  # Unknown expression type


function parse(lexer)
    #     """Convenience function to parse tokens into an AST"""
    #     from .parser_statement_parsing import StatementParser
    parser = StatementParser(lexer)
        return parser.parse_program()


function tokenize(source: str, filename: str = "<string>")
    #     """Convenience function to tokenize source code"""
    #     from .lexer_main import tokenize as lexer_tokenize
        return lexer_tokenize(source, filename)
