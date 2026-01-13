"""
Parser::Unified Parser - unified_parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

# Noodle Language Unified Parser - Python Implementation
# -------------------------------------------------
# 
# Python version of the unified parser that works with the lexer
# Provides clean AST generation from tokens

import os
import sys
import time
import threading
from typing import Any, Dict, List, Optional, Union

# Add lexer path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lexer'))
from lexer import Lexer, Token, TokenType, LexerError, Position

class ParseError(Exception):
    """Exception raised during parsing phase"""
    
    def __init__(self, message: str, position: Optional[Position] = None):
        self.message = message
        self.position = position
        super().__init__(self.message)
    
    def __str__(self):
        if self.position:
            return f"ParseError at {self.position}: {self.message}"
        return f"ParseError: {self.message}"

class UnifiedParser:
    """Unified parser for Noodle language with clean lexer integration"""
    
    def __init__(self, lexer: Lexer):
        self.lexer = lexer
        self.tokens: List[Token] = []
        self.current_token_index = 0
        self.current_token: Optional[Token] = None
        self.errors: List[ParseError] = []
        self.warnings: List[str] = []
        
        # Parser state
        self.current_scope = 'global'
        self.symbol_tables: Dict[str, Dict[str, Any]] = {}
        self.parse_depth = 0
        
        # Statistics
        self.parse_start_time = time.time()
        self.parse_count = 0
        self.total_parse_time = 0.0
        self.tokens_consumed = 0
        
        # Thread safety
        self._lock = threading.RLock()
        
        # Initialize tokens
        self._initialize_tokens()
    
    def _initialize_tokens(self):
        """Initialize token stream from lexer"""
        try:
            self.tokens = self.lexer.tokenize()
            if self.tokens and len(self.tokens) > 0:
                self.current_token = self.tokens[0]
                self.current_token_index = 0
            else:
                self.current_token = None
                self.current_token_index = -1
        except Exception as e:
            self.errors.append(ParseError(f"Lexer initialization failed: {str(e)}"))
            self.tokens = []
            self.current_token = None
            self.current_token_index = -1
    
    def _has_more_tokens(self) -> bool:
        """Check if there are more tokens to parse"""
        return self.current_token_index < len(self.tokens) and self.current_token is not None
    
    def _advance_token(self):
        """Advance to next token"""
        self.current_token_index += 1
        if self.current_token_index < len(self.tokens):
            self.current_token = self.tokens[self.current_token_index]
            self.tokens_consumed += 1
        else:
            self.current_token = None
    
    def _peek_token(self, offset: int = 1) -> Optional[Token]:
        """Peek at future token without advancing"""
        peek_index = self.current_token_index + offset
        if peek_index < len(self.tokens):
            return self.tokens[peek_index]
        return None
    
    def _expect_token(self, token_type: TokenType, error_message: str = None) -> Token:
        """Expect a specific token type, raise error if not found"""
        if not self.current_token:
            raise ParseError(error_message or f"Expected {token_type.value} but found end of input")
        
        if self.current_token.type == token_type:
            token = self.current_token
            self._advance_token()
            return token
        
        error_msg = error_message or f"Expected {token_type.value} but found {self.current_token.type.value}"
        raise ParseError(error_msg, self._get_token_position(self.current_token))
    
    def _get_token_position(self, token: Token) -> Position:
        """Get position information for a token"""
        if hasattr(token, 'position') and token.position:
            return token.position
        return Position(line=token.line, column=token.column)
    
    def _add_error(self, message: str, token: Optional[Token] = None):
        """Add an error to the error list"""
        position = self._get_token_position(token) if token else None
        self.errors.append(ParseError(message, position))
    
    def _add_warning(self, message: str):
        """Add a warning to the warning list"""
        self.warnings.append(message)
    
    def parse(self) -> Dict[str, Any]:
        """Parse the entire program and return AST"""
        start_time = time.time()
        
        with self._lock:
            try:
                program = {
                    'type': 'Program',
                    'statements': [],
                    'position': self._get_token_position(self.tokens[0]) if self.tokens else Position(1, 1),
                    'symbol_tables': {},
                    'errors': [],
                    'warnings': [],
                    'statistics': {}
                }
                
                # Parse all statements
                while self._has_more_tokens():
                    try:
                        statement = self._parse_statement()
                        if statement:
                            program['statements'].append(statement)
                    except ParseError as e:
                        self._add_error(str(e))
                        # Try to recover by skipping to next statement
                        self._recover_to_next_statement()
                
                # Finalize program
                program['symbol_tables'] = self.symbol_tables
                program['errors'] = [str(error) for error in self.errors]
                program['warnings'] = self.warnings.copy()
                program['statistics'] = self.get_statistics()
                
                return program
                
            except Exception as e:
                self._add_error(f"Critical parsing error: {str(e)}")
                return {
                    'type': 'Program',
                    'statements': [],
                    'position': Position(1, 1),
                    'symbol_tables': {},
                    'errors': [str(error) for error in self.errors],
                    'warnings': self.warnings.copy(),
                    'statistics': self.get_statistics()
                }
            finally:
                parse_time = time.time() - start_time
                self.total_parse_time += parse_time
                self.parse_count += 1
    
    def _parse_statement(self) -> Optional[Dict[str, Any]]:
        """Parse a single statement"""
        if not self._has_more_tokens():
            return None
        
        try:
            token = self.current_token
            
            if token.type == TokenType.IF:
                return self._parse_if_statement()
            elif token.type == TokenType.WHILE:
                return self._parse_while_statement()
            elif token.type == TokenType.FOR:
                return self._parse_for_statement()
            elif token.type == TokenType.FUNCTION:
                return self._parse_function_definition()
            elif token.type == TokenType.RETURN:
                return self._parse_return_statement()
            elif token.type == TokenType.IMPORT:
                return self._parse_import_statement()
            elif token.type == TokenType.CLASS:
                return self._parse_class_definition()
            elif token.type == TokenType.IDENTIFIER:
                return self._parse_assignment_or_expression_statement()
            else:
                # Skip unknown tokens and add warning
                self._add_warning(f"Unexpected token: {token.type.value}")
                self._advance_token()
                return None
                
        except ParseError:
            raise
        except Exception as e:
            raise ParseError(f"Statement parsing failed: {str(e)}", self._get_token_position(self.current_token))
    
    def _parse_if_statement(self) -> Dict[str, Any]:
        """Parse if statement"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.IF, "Expected 'if' keyword")
        
        condition = self._parse_expression()
        if not condition:
            raise ParseError("Expected condition after 'if'", self._get_token_position(self.current_token))
        
        self._expect_token(TokenType.LEFT_BRACE, "Expected '{' after if condition")
        
        then_branch = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_BRACE:
            stmt = self._parse_statement()
            if stmt:
                then_branch.append(stmt)
        
        self._expect_token(TokenType.RIGHT_BRACE, "Expected '}' after if body")
        
        else_branch = []
        if self._has_more_tokens() and self.current_token.type == TokenType.ELSE:
            self._advance_token()
            self._expect_token(TokenType.LEFT_BRACE, "Expected '{' after else")
            
            while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_BRACE:
                stmt = self._parse_statement()
                if stmt:
                    else_branch.append(stmt)
            
            self._expect_token(TokenType.RIGHT_BRACE, "Expected '}' after else body")
        
        return {
            'type': 'IfStatement',
            'condition': condition,
            'then_branch': then_branch,
            'else_branch': else_branch,
            'position': start_pos
        }
    
    def _parse_while_statement(self) -> Dict[str, Any]:
        """Parse while statement"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.WHILE, "Expected 'while' keyword")
        
        condition = self._parse_expression()
        if not condition:
            raise ParseError("Expected condition after 'while'", self._get_token_position(self.current_token))
        
        self._expect_token(TokenType.LEFT_BRACE, "Expected '{' after while condition")
        
        body = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_BRACE:
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect_token(TokenType.RIGHT_BRACE, "Expected '}' after while body")
        
        return {
            'type': 'WhileStatement',
            'condition': condition,
            'body': body,
            'position': start_pos
        }
    
    def _parse_for_statement(self) -> Dict[str, Any]:
        """Parse for statement"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.FOR, "Expected 'for' keyword")
        
        # For simplicity, parse basic for loop: for identifier in expression
        identifier = self._expect_token(TokenType.IDENTIFIER, "Expected identifier in for loop")
        self._expect_token(TokenType.IDENTIFIER, "Expected 'in' keyword")  # Should be 'in' but using IDENTIFIER for simplicity
        
        iterable = self._parse_expression()
        if not iterable:
            raise ParseError("Expected iterable after 'in'", self._get_token_position(self.current_token))
        
        self._expect_token(TokenType.LEFT_BRACE, "Expected '{' after for loop header")
        
        body = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_BRACE:
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect_token(TokenType.RIGHT_BRACE, "Expected '}' after for body")
        
        return {
            'type': 'ForStatement',
            'variable': identifier.value,
            'iterable': iterable,
            'body': body,
            'position': start_pos
        }
    
    def _parse_function_definition(self) -> Dict[str, Any]:
        """Parse function definition"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.FUNCTION, "Expected 'function' keyword")
        
        name = self._expect_token(TokenType.IDENTIFIER, "Expected function name")
        
        self._expect_token(TokenType.LEFT_PAREN, "Expected '(' after function name")
        
        parameters = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_PAREN:
            if self.current_token.type == TokenType.IDENTIFIER:
                param = self.current_token.value
                self._advance_token()
                parameters.append(param)
                
                if self.current_token and self.current_token.type == TokenType.COMMA:
                    self._advance_token()
            else:
                break
        
        self._expect_token(TokenType.RIGHT_PAREN, "Expected ')' after parameters")
        
        self._expect_token(TokenType.LEFT_BRACE, "Expected '{' after function signature")
        
        body = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_BRACE:
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect_token(TokenType.RIGHT_BRACE, "Expected '}' after function body")
        
        return {
            'type': 'FunctionDefinition',
            'name': name.value,
            'parameters': parameters,
            'body': body,
            'position': start_pos
        }
    
    def _parse_return_statement(self) -> Dict[str, Any]:
        """Parse return statement"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.RETURN, "Expected 'return' keyword")
        
        expression = None
        if self._has_more_tokens() and self.current_token.type not in [TokenType.SEMICOLON, TokenType.NEWLINE, TokenType.RIGHT_BRACE]:
            expression = self._parse_expression()
        
        return {
            'type': 'ReturnStatement',
            'expression': expression,
            'position': start_pos
        }
    
    def _parse_import_statement(self) -> Dict[str, Any]:
        """Parse import statement"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.IMPORT, "Expected 'import' keyword")
        
        module_name = self._expect_token(TokenType.STRING, "Expected module name string")
        
        return {
            'type': 'ImportStatement',
            'module': module_name.value,
            'position': start_pos
        }
    
    def _parse_class_definition(self) -> Dict[str, Any]:
        """Parse class definition"""
        start_pos = self._get_token_position(self.current_token)
        self._expect_token(TokenType.CLASS, "Expected 'class' keyword")
        
        name = self._expect_token(TokenType.IDENTIFIER, "Expected class name")
        
        # For simplicity, skip inheritance for now
        extends = None
        if self._has_more_tokens() and self.current_token.type == TokenType.EXTENDS:
            self._advance_token()
            extends = self._expect_token(TokenType.IDENTIFIER, "Expected parent class name")
        
        self._expect_token(TokenType.LEFT_BRACE, "Expected '{' after class name")
        
        body = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_BRACE:
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect_token(TokenType.RIGHT_BRACE, "Expected '}' after class body")
        
        return {
            'type': 'ClassDefinition',
            'name': name.value,
            'extends': extends.value if extends else None,
            'body': body,
            'position': start_pos
        }
    
    def _parse_assignment_or_expression_statement(self) -> Dict[str, Any]:
        """Parse assignment or expression statement"""
        start_pos = self._get_token_position(self.current_token)
        
        # Get the identifier
        identifier = self._expect_token(TokenType.IDENTIFIER, "Expected identifier")
        
        # Check if this is an assignment
        if self._has_more_tokens() and self.current_token.type == TokenType.ASSIGN:
            self._advance_token()
            expression = self._parse_expression()
            
            return {
                'type': 'AssignmentStatement',
                'variable': identifier.value,
                'expression': expression,
                'position': start_pos
            }
        else:
            # This is an expression statement
            # We need to parse the full expression starting with the identifier
            expression = self._parse_expression_starting_with_identifier(identifier)
            
            return {
                'type': 'ExpressionStatement',
                'expression': expression,
                'position': start_pos
            }
    
    def _parse_expression(self) -> Optional[Dict[str, Any]]:
        """Parse expression with operator precedence"""
        return self._parse_binary_expression(0)
    
    def _parse_expression_starting_with_identifier(self, identifier: Token) -> Dict[str, Any]:
        """Parse expression starting with an identifier (for function calls, etc.)"""
        if self._has_more_tokens() and self.current_token.type == TokenType.LEFT_PAREN:
            # Function call
            return self._parse_function_call(identifier)
        else:
            # Simple variable reference
            return {
                'type': 'IdentifierExpression',
                'name': identifier.value,
                'position': self._get_token_position(identifier)
            }
    
    def _parse_function_call(self, function_name: Token) -> Dict[str, Any]:
        """Parse function call"""
        start_pos = self._get_token_position(function_name)
        self._expect_token(TokenType.LEFT_PAREN, "Expected '(' after function name")
        
        arguments = []
        while self._has_more_tokens() and self.current_token.type != TokenType.RIGHT_PAREN:
            arg = self._parse_expression()
            if arg:
                arguments.append(arg)
            
            if self.current_token and self.current_token.type == TokenType.COMMA:
                self._advance_token()
        
        self._expect_token(TokenType.RIGHT_PAREN, "Expected ')' after function arguments")
        
        return {
            'type': 'FunctionCallExpression',
            'function': function_name.value,
            'arguments': arguments,
            'position': start_pos
        }
    
    def _parse_binary_expression(self, precedence: int) -> Optional[Dict[str, Any]]:
        """Parse binary expression with precedence climbing"""
        if not self._has_more_tokens():
            return None
        
        left = self._parse_primary_expression()
        if not left:
            return None
        
        while self._has_more_tokens():
            token = self.current_token
            
            # Check if this is an operator
            if token.type in [TokenType.PLUS, TokenType.MINUS, TokenType.MULTIPLY, TokenType.DIVIDE, 
                           TokenType.EQUAL, TokenType.NOT_EQUAL, TokenType.LESS_THAN, TokenType.LESS_EQUAL,
                           TokenType.GREATER_THAN, TokenType.GREATER_EQUAL, TokenType.AND, TokenType.OR]:
                
                # For simplicity, all operators have same precedence
                self._advance_token()
                right = self._parse_primary_expression()
                if not right:
                    break
                
                left = {
                    'type': 'BinaryExpression',
                    'left': left,
                    'operator': token.type.value,
                    'right': right,
                    'position': self._get_token_position(token)
                }
            else:
                break
        
        return left
    
    def _parse_primary_expression(self) -> Optional[Dict[str, Any]]:
        """Parse primary expression (literals, identifiers, parentheses)"""
        if not self._has_more_tokens():
            return None
        
        token = self.current_token
        
        if token.type == TokenType.NUMBER:
            self._advance_token()
            return {
                'type': 'LiteralExpression',
                'value': token.value,
                'data_type': 'number',
                'position': self._get_token_position(token)
            }
        
        elif token.type == TokenType.STRING:
            self._advance_token()
            return {
                'type': 'LiteralExpression',
                'value': token.value,
                'data_type': 'string',
                'position': self._get_token_position(token)
            }
        
        elif token.type == TokenType.BOOLEAN:
            self._advance_token()
            return {
                'type': 'LiteralExpression',
                'value': token.value,
                'data_type': 'boolean',
                'position': self._get_token_position(token)
            }
        
        elif token.type == TokenType.NULL:
            self._advance_token()
            return {
                'type': 'LiteralExpression',
                'value': None,
                'data_type': 'null',
                'position': self._get_token_position(token)
            }
        
        elif token.type == TokenType.IDENTIFIER:
            identifier = self.current_token
            self._advance_token()
            return self._parse_expression_starting_with_identifier(identifier)
        
        elif token.type == TokenType.LEFT_PAREN:
            self._advance_token()
            expression = self._parse_expression()
            self._expect_token(TokenType.RIGHT_PAREN, "Expected ')' after parenthesized expression")
            return expression
        
        else:
            self._add_error(f"Unexpected token in expression: {token.type.value}", token)
            self._advance_token()
            return None
    
    def _recover_to_next_statement(self):
        """Try to recover by skipping to the next statement boundary"""
        max_skip = 10
        skipped = 0
        
        while self._has_more_tokens() and skipped < max_skip:
            if self.current_token.type in [TokenType.SEMICOLON, TokenType.NEWLINE, TokenType.RIGHT_BRACE]:
                break
            self._advance_token()
            skipped += 1
    
    def get_errors(self) -> List[str]:
        """Get all parsing errors"""
        return [str(error) for error in self.errors]
    
    def get_warnings(self) -> List[str]:
        """Get all parsing warnings"""
        return self.warnings.copy()
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get parser statistics"""
        return {
            'parse_count': self.parse_count,
            'total_parse_time': self.total_parse_time,
            'average_parse_time': self.total_parse_time / self.parse_count if self.parse_count > 0 else 0,
            'tokens_consumed': self.tokens_consumed,
            'error_count': len(self.errors),
            'warning_count': len(self.warnings),
            'symbol_table_count': len(self.symbol_tables),
            'current_scope': self.current_scope,
            'parser_age': time.time() - self.parse_start_time
        }
    
    def reset(self):
        """Reset parser state"""
        with self._lock:
            self.errors = []
            self.warnings = []
            self.tokens_consumed = 0
            self.parse_count = 0
            self.total_parse_time = 0.0
            self.symbol_tables = {}
            self.current_scope = 'global'
            self.parse_depth = 0
            self._initialize_tokens()
    
    def set_scope(self, scope_name: str):
        """Set current scope"""
        with self._lock:
            self.current_scope = scope_name
    
    def get_scope(self) -> str:
        """Get current scope"""
        return self.current_scope

# Convenience function
def parse(source_code: str, filename: str = "<string>") -> Dict[str, Any]:
    """
    Parse Noodle source code into AST
    
    Args:
        source_code: The source code to parse
        filename: Optional filename for error reporting
    
    Returns:
        AST dictionary
    """
    lexer = Lexer(source_code, filename)
    parser = UnifiedParser(lexer)
    return parser.parse()

# Test function
def test_parser():
    """Test the parser with sample code"""
    test_code = """
    function calculate_sum(a, b) {
        return a + b;
    }
    
    function main() {
        x = 10;
        y = 20;
        result = calculate_sum(x, y);
        if result > 25 {
            print("Large result");
        }
    }
    """
    
    result = parse(test_code, "test.nc")
    print("Parse result:")
    print(f"Statements: {len(result['statements'])}")
    print(f"Errors: {len(result['errors'])}")
    print(f"Warnings: {len(result['warnings'])}")
    print(f"Statistics: {result['statistics']}")
    
    return result

if __name__ == "__main__":
    test_parser()

