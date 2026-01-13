# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Parser for Noodle Programming Language
# --------------------------------------
# This module implements the parsing phase of the Noodle compiler.
It builds an Abstract Syntax Tree (AST) from the tokens produced by the lexer.
# Uses the new modular lexer architecture with advanced token handling.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import re
import sys
import collections.defaultdict
import enum.Enum
import typing.Any,
import time
import threading

# Absolute import for lexer
sys.path.append(os.path.dirname(__file__))

import .lexer_main.Lexer,
import .lexer_tokens.LexerError,
import .lexer_position.Position,
import .lexer_patterns.get_pattern_matcher
import .parser_ast_nodes.(
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
#     Type,
#     Identifier,
# )
import .parser_statement_parsing.StatementParser
import .parser_expression_parsing.ExpressionParser


class ParserError(Exception)
    #     """Exception raised during parsing phase."""

    #     def __init__(self, message: str, line_number: int = None, column: int = None, position: Position = None):
    self.message = message
    self.line_number = line_number
    self.column = column
    self.position = position
            super().__init__(self.message)

    #     def __str__(self):
    #         if self.position:
    #             return f"ParserError at {self.position}: {self.message}"
    #         elif self.line_number is not None:
    #             if self.column is not None:
    #                 return f"ParserError at line {self.line_number}, column {self.column}: {self.message}"
    #             return f"ParserError at line {self.line_number}: {self.message}"
    #         return f"ParserError: {self.message}"


class Parser
    #     """Main parser class for the Noodle language with enhanced lexer integration"""

    #     def __init__(self, lexer: Lexer):
    self.lexer = lexer
    self.position_tracker = get_position_tracker()
    self.pattern_matcher = get_pattern_matcher()
    self.errors = []
    self.warnings = []
    self.parse_start_time = time.time()
    self.parse_count = 0
    self.total_parse_time = 0.0
    self.tokens_consumed = 0
    self.current_token = None
    self.token_stream = None

    #         # Initialize with fresh tokens
            self._initialize_tokens()

    #         # Create sub-parsers
    self.statement_parser = StatementParser(lexer)
    self.expression_parser = ExpressionParser(lexer)

    #         # Parser state
    self.current_scope = 'global'
    self.symbol_tables = {}
    self.type_inference_cache = {}

    #         # Thread safety
    self._lock = threading.RLock()

    #     def _initialize_tokens(self):
    #         """Initialize token stream from lexer"""
    #         if hasattr(self.lexer, 'tokenize'):
    #             # New lexer architecture
    self.token_stream = self.lexer.tokenize()
    self.current_token = self.token_stream.current()
    #         else:
    #             # Legacy lexer support
    self.current_token = self.lexer.get_next_token()

    #     def parse(self) -> ProgramNode:
    #         """Parse the entire program with enhanced error handling and statistics"""
    start_time = time.time()

    #         with self._lock:
    #             try:
    program = ProgramNode()
    program.position = self._create_position()

    #                 while self._has_more_tokens():
    statement = self._parse_statement()
    #                     if statement:
                            program.add_child(statement)
    self.tokens_consumed + = 1

    #                 # Link symbol tables to program
    program.symbol_tables = self.symbol_tables

    #                 return program

    #             except Exception as e:
    error_msg = f"Parser error: {str(e)}"
                    self.errors.append(error_msg)
    #                 if self.current_token and self.current_token.position:
                        self.errors.append(f"At position: {self.current_token.position}")

    #                 # Return partial program
                    return ProgramNode()
    #             finally:
    parse_time = math.subtract(time.time(), start_time)
    self.total_parse_time + = parse_time
    self.parse_count + = 1

    #     def _has_more_tokens(self) -> bool:
    #         """Check if there are more tokens to parse"""
    #         if self.token_stream:
                return self.token_stream.current() is not None
    return self.current_token and self.current_token.type ! = TokenType.EOF

    #     def _parse_statement(self) -> Optional[StatementNode]:
    #         """Parse a single statement"""
    #         if not self._has_more_tokens():
    #             return None

    start_position = self._get_token_position()

    #         try:
    #             # Use statement parser with enhanced error handling
    statement = self.statement_parser.parse_statement()

    #             if statement:
    #                 # Attach position information
    statement.position = start_position
    statement.scope = self.current_scope

    #                 # Update symbol table
                    self._update_symbol_table(statement)

    #             return statement

    #         except Exception as e:
    error_msg = f"Statement parsing error: {str(e)}"
                self.errors.append(error_msg)

    #             # Try to recover
    #             if self._try_recover():
                    return self._parse_statement()
    #             return None

    #     def _parse_expression(self) -> Optional[ExpressionNode]:
    #         """Parse an expression"""
    #         if not self._has_more_tokens():
    #             return None

    start_position = self._get_token_position()

    #         try:
    #             # Use expression parser with enhanced error handling
    expression = self.expression_parser.parse_expression()

    #             if expression:
    #                 # Attach position information
    expression.position = start_position

    #                 # Type inference
    expression_type = self._infer_expression_type(expression)
    expression.inferred_type = expression_type

    #                 # Cache type inference
    type_key = hash(expression)
    self.type_inference_cache[type_key] = expression_type

    #             return expression

    #         except Exception as e:
    error_msg = f"Expression parsing error: {str(e)}"
                self.errors.append(error_msg)

    #             # Try to recover
    #             if self._try_recover():
                    return self._parse_expression()
    #             return None

    #     def _get_token_position(self) -> Optional[Position]:
    #         """Get current token position"""
    #         if self.current_token and self.current_token.position:
    #             return self.current_token.position
    #         return None

    #     def _create_position(self) -> Optional[Position]:
    #         """Create a position at current location"""
            return self._get_token_position()

    #     def _update_symbol_table(self, statement: StatementNode):
    #         """Update symbol table with statement information"""
    #         if not hasattr(statement, 'name'):
    #             return

    scope = self.current_scope
    #         if scope not in self.symbol_tables:
    self.symbol_tables[scope] = {}

    symbol_info = {
    #             'name': statement.name,
                'type': self._get_statement_type(statement),
    #             'position': statement.position,
    #             'scope': scope,
                'timestamp': time.time(),
    #         }

    self.symbol_tables[scope][statement.name] = symbol_info

    #     def _get_statement_type(self, statement: StatementNode) -> str:
    #         """Get the type of a statement"""
    #         if isinstance(statement, VarDeclNode):
    #             return 'variable_declaration'
    #         elif isinstance(statement, AssignStmtNode):
    #             return 'assignment'
    #         elif isinstance(statement, FuncDefNode):
    #             return 'function_definition'
    #         elif isinstance(statement, IfStmtNode):
    #             return 'conditional'
    #         elif isinstance(statement, WhileStmtNode):
    #             return 'while_loop'
    #         elif isinstance(statement, ForStmtNode):
    #             return 'for_loop'
    #         elif isinstance(statement, ReturnStmtNode):
    #             return 'return'
    #         elif isinstance(statement, PrintStmtNode):
    #             return 'print'
    #         else:
    #             return 'unknown'

    #     def _infer_expression_type(self, expression: ExpressionNode) -> str:
    #         """Infer the type of an expression"""
    #         # Simple type inference logic
    #         if isinstance(expression, LiteralExprNode):
    #             return expression.type or 'unknown'
    #         elif isinstance(expression, IdentifierExprNode):
    #             # Look up in symbol tables
    #             for scope in reversed([self.current_scope] + list(self.symbol_tables.keys())):
    #                 if scope in self.symbol_tables and expression.name in self.symbol_tables[scope]:
    #                     return self.symbol_tables[scope][expression.name]['type']
    #             return 'unknown'
    #         elif isinstance(expression, BinaryExprNode):
    left_type = self._infer_expression_type(expression.left)
    right_type = self._infer_expression_type(expression.right)

    #             # Type promotion rules
    #             if 'float' in [left_type, right_type]:
    #                 return 'float'
    #             elif left_type == 'unknown' or right_type == 'unknown':
    #                 return 'unknown'
    #             else:
    #                 return left_type  # Simplified
    #         else:
    #             return 'unknown'

    #     def _try_recover(self) -> bool:
    #         """Try to recover from parsing error"""
    #         if not self._has_more_tokens():
    #             return False

    #         # Skip tokens until we find a statement boundary
    tokens_to_skip = 0
    max_skip = 10

    #         while (self._has_more_tokens() and
    #                tokens_to_skip < max_skip):

    #             current_type = self.current_token.type.value if self.current_token else TokenType.EOF.value

    #             # Stop at statement boundaries
    #             if current_type in [
    #                 TokenType.SEMICOLON.value,
    #                 TokenType.NEWLINE.value,
    #                 TokenType.EOF.value
    #             ]:
    #                 break

                self._advance_token()
    tokens_to_skip + = 1

    #         return tokens_to_skip < max_skip

    #     def _advance_token(self):
    #         """Advance to next token"""
    #         if self.token_stream:
    self.current_token = self.token_stream.consume()
    #         else:
    #             # Legacy support
    self.current_token = self.lexer.get_next_token()

    #     def get_errors(self) -> List[str]:
    #         """Get all parsing errors"""
    #         with self._lock:
                return self.errors.copy()

    #     def get_warnings(self) -> List[str]:
    #         """Get all parsing warnings"""
    #         with self._lock:
                return self.warnings.copy()

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get parser statistics"""
    #         with self._lock:
    total_time = sum(self.parse_times)
    #             avg_time = total_time / len(self.parse_times) if self.parse_times else 0

    #             return {
    #                 'parse_count': self.parse_count,
    #                 'total_parse_time': self.total_parse_time,
    #                 'average_parse_time': avg_time,
    #                 'tokens_consumed': self.tokens_consumed,
                    'error_count': len(self.errors),
                    'warning_count': len(self.warnings),
                    'symbol_table_count': len(self.symbol_tables),
                    'type_inference_cache_size': len(self.type_inference_cache),
    #                 'current_scope': self.current_scope,
                    'parser_age': time.time() - self.parse_start_time,
    #             }

    #     def reset(self):
    #         """Reset parser state"""
    #         with self._lock:
    self.errors = []
    self.warnings = []
    self.tokens_consumed = 0
    self.parse_count = 0
    self.total_parse_time = 0.0
    self.symbol_tables = {}
    self.type_inference_cache = {}
    self.current_scope = 'global'
                self._initialize_tokens()

    #     def set_scope(self, scope_name: str):
    #         """Set current scope"""
    #         with self._lock:
    self.current_scope = scope_name

    #     def get_scope(self) -> str:
    #         """Get current scope"""
    #         return self.current_scope

    #     def validate_ast(self, program: ProgramNode) -> List[str]:
    #         """Validate the AST structure"""
    errors = []

    #         # Check program structure
    #         if not isinstance(program, ProgramNode):
                errors.append("Root node is not a ProgramNode")

    #         # Check statements
    #         for i, statement in enumerate(program.children):
    #             if not isinstance(statement, StatementNode):
                    errors.append(f"Statement {i} is not a StatementNode")

    #         return errors


def parse(lexer: Lexer) -> ProgramNode:
#     """
#     Convenience function to parse tokens into an AST.

#     Args:
#         lexer: Lexer instance to get tokens from

#     Returns:
#         ProgramNode: Root node of the AST
#     """
parser = Parser(lexer)
    return parser.parse()
