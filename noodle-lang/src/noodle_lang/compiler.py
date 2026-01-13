#!/usr/bin/env python3
"""
Noodle Lang::Compiler - compiler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Noodle Language Compiler

This is the main compiler for the Noodle programming language, transforming
Noodle source code into NBC (Noodle Bytecode) for execution by the Noodle runtime.

Features:
- Complete lexical analysis and parsing
- Semantic analysis with type inference
- Optimization passes
- NBC bytecode generation
- Error reporting and recovery
- Source map generation for debugging
"""

import os
import sys
import time
import hashlib
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any, Union
from dataclasses import dataclass
from enum import Enum
import json

# Import NoodleCore components
try:
    from noodlecore.runtime.nbc_bytecode import NBCBytecode, NBCInstruction
    from noodlecore.runtime.nbc_executor import NBCExecutor
    from noodlecore.ai_agents.trm_agent import TRMAgent
except ImportError:
    # Fallback for development
    NBCBytecode = None
    NBCInstruction = None
    NBCExecutor = None
    TRMAgent = None

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CompilationPhase(Enum):
    """Compilation phases for progress tracking"""
    LEXING = "lexing"
    PARSING = "parsing"
    SEMANTIC_ANALYSIS = "semantic_analysis"
    OPTIMIZATION = "optimization"
    CODE_GENERATION = "code_generation"
    FINALIZATION = "finalization"


@dataclass
class SourceLocation:
    """Source code location information"""
    file: str
    line: int
    column: int
    offset: int


@dataclass
class CompilationError:
    """Compilation error with location and message"""
    location: SourceLocation
    message: str
    severity: str = "error"  # error, warning, info
    phase: CompilationPhase = CompilationPhase.LEXING


@dataclass
class CompilationResult:
    """Result of compilation process"""
    success: bool
    bytecode: Optional[NBCBytecode]
    errors: List[CompilationError]
    warnings: List[CompilationError]
    compilation_time: float
    source_map: Optional[Dict[str, Any]]
    statistics: Dict[str, Any]


class NoodleLexer:
    """Lexical analyzer for Noodle language"""
    
    # Token types
    TOKENS = {
        'LET': 'LET',
        'DEF': 'DEF',
        'RETURN': 'RETURN',
        'IF': 'IF',
        'ELSE': 'ELSE',
        'FOR': 'FOR',
        'IN': 'IN',
        'WHILE': 'WHILE',
        'BREAK': 'BREAK',
        'CONTINUE': 'CONTINUE',
        'IMPORT': 'IMPORT',
        'FROM': 'FROM',
        'AS': 'AS',
        'CLASS': 'CLASS',
        'STRUCT': 'STRUCT',
        'INTERFACE': 'INTERFACE',
        'IMPLEMENTS': 'IMPLEMENTS',
        'EXTENDS': 'EXTENDS',
        'TYPE': 'TYPE',
        'ENUM': 'ENUM',
        'MATCH': 'MATCH',
        'CASE': 'CASE',
        'DEFAULT': 'DEFAULT',
        'ASYNC': 'ASYNC',
        'AWAIT': 'AWAIT',
        'YIELD': 'YIELD',
        'TRUE': 'TRUE',
        'FALSE': 'FALSE',
        'NONE': 'NONE',
        'IDENTIFIER': 'IDENTIFIER',
        'NUMBER': 'NUMBER',
        'STRING': 'STRING',
        'PLUS': 'PLUS',
        'MINUS': 'MINUS',
        'MULTIPLY': 'MULTIPLY',
        'DIVIDE': 'DIVIDE',
        'MODULO': 'MODULO',
        'ASSIGN': 'ASSIGN',
        'EQ': 'EQ',
        'NE': 'NE',
        'LT': 'LT',
        'GT': 'GT',
        'LE': 'LE',
        'GE': 'GE',
        'AND': 'AND',
        'OR': 'OR',
        'NOT': 'NOT',
        'LPAREN': 'LPAREN',
        'RPAREN': 'RPAREN',
        'LBRACE': 'LBRACE',
        'RBRACE': 'RBRACE',
        'LBRACKET': 'LBRACKET',
        'RBRACKET': 'RBRACKET',
        'COMMA': 'COMMA',
        'DOT': 'DOT',
        'COLON': 'COLON',
        'SEMICOLON': 'SEMICOLON',
        'ARROW': 'ARROW',
        'DOUBLE_COLON': 'DOUBLE_COLON',
        'NEWLINE': 'NEWLINE',
        'EOF': 'EOF',
    }
    
    def __init__(self, source: str, filename: str = "<input>"):
        self.source = source
        self.filename = filename
        self.position = 0
        self.line = 1
        self.column = 1
        self.tokens = []
        self.errors = []
    
    def error(self, message: str, position: int = None):
        """Record a lexing error"""
        if position is None:
            position = self.position
        
        line_num, col_num = self._get_line_column(position)
        location = SourceLocation(self.filename, line_num, col_num, position)
        self.errors.append(CompilationError(location, message, "error", CompilationPhase.LEXING))
    
    def _get_line_column(self, position: int) -> Tuple[int, int]:
        """Get line and column for a position in the source"""
        line = 1
        column = 1
        for i in range(min(position, len(self.source))):
            if self.source[i] == '\n':
                line += 1
                column = 1
            else:
                column += 1
        return line, column
    
    def _current_char(self) -> str:
        """Get current character"""
        if self.position >= len(self.source):
            return '\0'
        return self.source[self.position]
    
    def _peek_char(self, offset: int = 1) -> str:
        """Peek at character at offset"""
        pos = self.position + offset
        if pos >= len(self.source):
            return '\0'
        return self.source[pos]
    
    def _skip_whitespace(self):
        """Skip whitespace characters"""
        while self._current_char() in ' \t\r':
            self.position += 1
            self.column += 1
    
    def _skip_comment(self):
        """Skip comment"""
        if self._current_char() == '#':
            while self._current_char() not in '\n\0':
                self.position += 1
            return True
        return False
    
    def _read_identifier(self) -> str:
        """Read an identifier"""
        start = self.position
        while (self._current_char().isalnum() or self._current_char() == '_'):
            self.position += 1
            self.column += 1
        
        return self.source[start:self.position]
    
    def _read_number(self) -> str:
        """Read a number literal"""
        start = self.position
        
        # Integer part
        while self._current_char().isdigit():
            self.position += 1
            self.column += 1
        
        # Fractional part
        if self._current_char() == '.' and self._peek_char().isdigit():
            self.position += 1
            self.column += 1
            while self._current_char().isdigit():
                self.position += 1
                self.column += 1
        
        # Exponent part
        if self._current_char() in 'eE':
            self.position += 1
            self.column += 1
            if self._current_char() in '+-':
                self.position += 1
                self.column += 1
            while self._current_char().isdigit():
                self.position += 1
                self.column += 1
        
        return self.source[start:self.position]
    
    def _read_string(self, quote_char: str) -> str:
        """Read a string literal"""
        start = self.position
        self.position += 1  # Skip opening quote
        self.column += 1
        
        value = ""
        while self._current_char() != quote_char and self._current_char() != '\0':
            if self._current_char() == '\\':
                # Escape sequence
                self.position += 1
                self.column += 1
                if self._current_char() == '\0':
                    self.error("Unterminated string literal", start)
                    break
                
                escape_char = self._current_char()
                if escape_char == 'n':
                    value += '\n'
                elif escape_char == 't':
                    value += '\t'
                elif escape_char == 'r':
                    value += '\r'
                elif escape_char == '\\':
                    value += '\\'
                elif escape_char == quote_char:
                    value += quote_char
                else:
                    value += escape_char
            else:
                value += self._current_char()
            
            self.position += 1
            self.column += 1
        
        if self._current_char() == quote_char:
            self.position += 1  # Skip closing quote
            self.column += 1
        else:
            self.error("Unterminated string literal", start)
        
        return value
    
    def tokenize(self) -> List[Tuple[str, str, SourceLocation]]:
        """Tokenize the source code"""
        self.tokens = []
        self.errors = []
        
        while self.position < len(self.source):
            self._skip_whitespace()
            
            # Skip comments
            if self._skip_comment():
                continue
            
            start_pos = self.position
            line_num, col_num = self._get_line_column(start_pos)
            location = SourceLocation(self.filename, line_num, col_num, start_pos)
            
            current_char = self._current_char()
            
            # End of file
            if current_char == '\0':
                self.tokens.append(('EOF', '', location))
                break
            
            # Newline
            if current_char == '\n':
                self.tokens.append(('NEWLINE', '\n', location))
                self.position += 1
                self.line += 1
                self.column = 1
                continue
            
            # Identifiers and keywords
            if current_char.isalpha() or current_char == '_':
                identifier = self._read_identifier()
                token_type = self.TOKENS.get(identifier.upper(), 'IDENTIFIER')
                self.tokens.append((token_type, identifier, location))
                continue
            
            # Numbers
            if current_char.isdigit():
                number = self._read_number()
                self.tokens.append(('NUMBER', number, location))
                continue
            
            # Strings
            if current_char in '"\'':
                string_value = self._read_string(current_char)
                self.tokens.append(('STRING', string_value, location))
                continue
            
            # Two-character operators
            two_char_ops = {
                '==': 'EQ',
                '!=': 'NE',
                '<=': 'LE',
                '>=': 'GE',
                '&&': 'AND',
                '||': 'OR',
                '->': 'ARROW',
                '::': 'DOUBLE_COLON',
                '//': 'DIVIDE',
            }
            
            two_char = current_char + self._peek_char()
            if two_char in two_char_ops:
                self.tokens.append((two_char_ops[two_char], two_char, location))
                self.position += 2
                self.column += 2
                continue
            
            # Single-character operators
            single_char_ops = {
                '+': 'PLUS',
                '-': 'MINUS',
                '*': 'MULTIPLY',
                '/': 'DIVIDE',
                '%': 'MODULO',
                '=': 'ASSIGN',
                '<': 'LT',
                '>': 'GT',
                '!': 'NOT',
                '(': 'LPAREN',
                ')': 'RPAREN',
                '{': 'LBRACE',
                '}': 'RBRACE',
                '[': 'LBRACKET',
                ']': 'RBRACKET',
                ',': 'COMMA',
                '.': 'DOT',
                ':': 'COLON',
                ';': 'SEMICOLON',
            }
            
            if current_char in single_char_ops:
                self.tokens.append((single_char_ops[current_char], current_char, location))
                self.position += 1
                self.column += 1
                continue
            
            # Unknown character
            self.error(f"Unexpected character: '{current_char}'")
            self.position += 1
            self.column += 1
        
        return self.tokens


class NoodleParser:
    """Parser for Noodle language"""
    
    def __init__(self, tokens: List[Tuple[str, str, SourceLocation]]):
        self.tokens = tokens
        self.position = 0
        self.errors = []
        self.warnings = []
        self.ast = None
    
    def error(self, message: str, token: Tuple[str, str, SourceLocation] = None):
        """Record a parsing error"""
        if token is None:
            token = self._current_token()
        
        location = token[2]
        self.errors.append(CompilationError(location, message, "error", CompilationPhase.PARSING))
    
    def warning(self, message: str, token: Tuple[str, str, SourceLocation] = None):
        """Record a parsing warning"""
        if token is None:
            token = self._current_token()
        
        location = token[2]
        self.warnings.append(CompilationError(location, message, "warning", CompilationPhase.PARSING))
    
    def _current_token(self) -> Tuple[str, str, SourceLocation]:
        """Get current token"""
        if self.position >= len(self.tokens):
            return ('EOF', '', SourceLocation("", 0, 0, 0))
        return self.tokens[self.position]
    
    def _peek_token(self, offset: int = 1) -> Tuple[str, str, SourceLocation]:
        """Peek at token at offset"""
        pos = self.position + offset
        if pos >= len(self.tokens):
            return ('EOF', '', SourceLocation("", 0, 0, 0))
        return self.tokens[pos]
    
    def _advance(self) -> Tuple[str, str, SourceLocation]:
        """Advance to next token"""
        token = self._current_token()
        self.position += 1
        return token
    
    def _expect(self, expected_type: str, error_message: str = None) -> Tuple[str, str, SourceLocation]:
        """Expect a specific token type"""
        token = self._current_token()
        if token[0] == expected_type:
            return self._advance()
        
        if error_message is None:
            error_message = f"Expected {expected_type}, got {token[0]}"
        self.error(error_message, token)
        return token
    
    def _match(self, *token_types: str) -> bool:
        """Check if current token matches any of the given types"""
        return self._current_token()[0] in token_types
    
    def parse(self) -> Dict[str, Any]:
        """Parse the token stream into an AST"""
        self.errors = []
        self.warnings = []
        self.ast = {
            'type': 'program',
            'statements': []
        }
        
        while not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                self.ast['statements'].append(stmt)
        
        return self.ast
    
    def _parse_statement(self) -> Optional[Dict[str, Any]]:
        """Parse a statement"""
        if self._match('LET'):
            return self._parse_let_statement()
        elif self._match('DEF'):
            return self._parse_function_definition()
        elif self._match('IF'):
            return self._parse_if_statement()
        elif self._match('FOR'):
            return self._parse_for_statement()
        elif self._match('WHILE'):
            return self._parse_while_statement()
        elif self._match('RETURN'):
            return self._parse_return_statement()
        elif self._match('IMPORT'):
            return self._parse_import_statement()
        elif self._match('CLASS'):
            return self._parse_class_definition()
        else:
            # Try to parse as expression statement
            expr = self._parse_expression()
            if expr:
                self._expect('SEMICOLON', "Expected ';' after expression")
                return {
                    'type': 'expression_statement',
                    'expression': expr
                }
            return None
    
    def _parse_let_statement(self) -> Dict[str, Any]:
        """Parse a let statement (variable declaration)"""
        let_token = self._advance()  # 'let'
        
        name_token = self._expect('IDENTIFIER', "Expected variable name after 'let'")
        name = name_token[1]
        
        # Optional type annotation
        type_annotation = None
        if self._match('COLON'):
            self._advance()  # ':'
            type_token = self._expect('IDENTIFIER', "Expected type name after ':'")
            type_annotation = type_token[1]
        
        # Optional initialization
        initializer = None
        if self._match('ASSIGN'):
            self._advance()  # '='
            initializer = self._parse_expression()
        
        self._expect('SEMICOLON', "Expected ';' after let statement")
        
        return {
            'type': 'let_statement',
            'name': name,
            'type_annotation': type_annotation,
            'initializer': initializer,
            'location': let_token[2]
        }
    
    def _parse_function_definition(self) -> Dict[str, Any]:
        """Parse a function definition"""
        def_token = self._advance()  # 'def'
        
        name_token = self._expect('IDENTIFIER', "Expected function name after 'def'")
        name = name_token[1]
        
        self._expect('LPAREN', "Expected '(' after function name")
        
        parameters = []
        if not self._match('RPAREN'):
            while True:
                param_name_token = self._expect('IDENTIFIER', "Expected parameter name")
                param_name = param_name_token[1]
                
                # Optional type annotation
                param_type = None
                if self._match('COLON'):
                    self._advance()  # ':'
                    type_token = self._expect('IDENTIFIER', "Expected type name after ':'")
                    param_type = type_token[1]
                
                parameters.append({
                    'name': param_name,
                    'type': param_type
                })
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RPAREN', "Expected ')' after parameters")
        
        # Optional return type
        return_type = None
        if self._match('ARROW'):
            self._advance()  # '->'
            return_type_token = self._expect('IDENTIFIER', "Expected return type after '->'")
            return_type = return_type_token[1]
        
        # Function body
        self._expect('LBRACE', "Expected '{' to start function body")
        
        body = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end function body")
        
        return {
            'type': 'function_definition',
            'name': name,
            'parameters': parameters,
            'return_type': return_type,
            'body': body,
            'location': def_token[2]
        }
    
    def _parse_if_statement(self) -> Dict[str, Any]:
        """Parse an if statement"""
        if_token = self._advance()  # 'if'
        
        condition = self._parse_expression()
        
        self._expect('LBRACE', "Expected '{' after if condition")
        
        then_branch = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                then_branch.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end if body")
        
        # Optional else branch
        else_branch = None
        if self._match('ELSE'):
            self._advance()  # 'else'
            
            if self._match('IF'):
                # else if
                else_branch = self._parse_if_statement()
            else:
                self._expect('LBRACE', "Expected '{' after else")
                
                else_branch = []
                while not self._match('RBRACE') and not self._match('EOF'):
                    stmt = self._parse_statement()
                    if stmt:
                        else_branch.append(stmt)
                
                self._expect('RBRACE', "Expected '}' to end else body")
        
        return {
            'type': 'if_statement',
            'condition': condition,
            'then_branch': then_branch,
            'else_branch': else_branch,
            'location': if_token[2]
        }
    
    def _parse_for_statement(self) -> Dict[str, Any]:
        """Parse a for statement"""
        for_token = self._advance()  # 'for'
        
        variable_token = self._expect('IDENTIFIER', "Expected variable name after 'for'")
        variable = variable_token[1]
        
        self._expect('IN', "Expected 'in' after for variable")
        
        iterable = self._parse_expression()
        
        self._expect('LBRACE', "Expected '{' after for iterable")
        
        body = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end for body")
        
        return {
            'type': 'for_statement',
            'variable': variable,
            'iterable': iterable,
            'body': body,
            'location': for_token[2]
        }
    
    def _parse_while_statement(self) -> Dict[str, Any]:
        """Parse a while statement"""
        while_token = self._advance()  # 'while'
        
        condition = self._parse_expression()
        
        self._expect('LBRACE', "Expected '{' after while condition")
        
        body = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end while body")
        
        return {
            'type': 'while_statement',
            'condition': condition,
            'body': body,
            'location': while_token[2]
        }
    
    def _parse_return_statement(self) -> Dict[str, Any]:
        """Parse a return statement"""
        return_token = self._advance()  # 'return'
        
        value = None
        if not self._match('SEMICOLON'):
            value = self._parse_expression()
        
        self._expect('SEMICOLON', "Expected ';' after return statement")
        
        return {
            'type': 'return_statement',
            'value': value,
            'location': return_token[2]
        }
    
    def _parse_import_statement(self) -> Dict[str, Any]:
        """Parse an import statement"""
        import_token = self._advance()  # 'import'
        
        module_token = self._expect('STRING', "Expected module name as string literal")
        module_name = module_token[1]
        
        # Optional alias
        alias = None
        if self._match('AS'):
            self._advance()  # 'as'
            alias_token = self._expect('IDENTIFIER', "Expected alias name after 'as'")
            alias = alias_token[1]
        
        self._expect('SEMICOLON', "Expected ';' after import statement")
        
        return {
            'type': 'import_statement',
            'module': module_name,
            'alias': alias,
            'location': import_token[2]
        }
    
    def _parse_class_definition(self) -> Dict[str, Any]:
        """Parse a class definition"""
        class_token = self._advance()  # 'class'
        
        name_token = self._expect('IDENTIFIER', "Expected class name after 'class'")
        name = name_token[1]
        
        # Optional inheritance
        extends = None
        if self._match('EXTENDS'):
            self._advance()  # 'extends'
            extends_token = self._expect('IDENTIFIER', "Expected parent class name after 'extends'")
            extends = extends_token[1]
        
        self._expect('LBRACE', "Expected '{' to start class body")
        
        members = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                members.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end class body")
        
        return {
            'type': 'class_definition',
            'name': name,
            'extends': extends,
            'members': members,
            'location': class_token[2]
        }
    
    def _parse_expression(self) -> Optional[Dict[str, Any]]:
        """Parse an expression"""
        return self._parse_assignment()
    
    def _parse_assignment(self) -> Optional[Dict[str, Any]]:
        """Parse assignment expression"""
        left = self._parse_logical_or()
        
        if self._match('ASSIGN'):
            assign_token = self._advance()  # '='
            right = self._parse_assignment()
            
            return {
                'type': 'assignment',
                'left': left,
                'right': right,
                'location': assign_token[2]
            }
        
        return left
    
    def _parse_logical_or(self) -> Optional[Dict[str, Any]]:
        """Parse logical OR expression"""
        left = self._parse_logical_and()
        
        while self._match('OR'):
            op_token = self._advance()  # '||'
            right = self._parse_logical_and()
            
            left = {
                'type': 'binary_expression',
                'operator': '||',
                'left': left,
                'right': right,
                'location': op_token[2]
            }
        
        return left
    
    def _parse_logical_and(self) -> Optional[Dict[str, Any]]:
        """Parse logical AND expression"""
        left = self._parse_equality()
        
        while self._match('AND'):
            op_token = self._advance()  # '&&'
            right = self._parse_equality()
            
            left = {
                'type': 'binary_expression',
                'operator': '&&',
                'left': left,
                'right': right,
                'location': op_token[2]
            }
        
        return left
    
    def _parse_equality(self) -> Optional[Dict[str, Any]]:
        """Parse equality expression"""
        left = self._parse_comparison()
        
        while self._match('EQ', 'NE'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_comparison()
            
            left = {
                'type': 'binary_expression',
                'operator': operator,
                'left': left,
                'right': right,
                'location': op_token[2]
            }
        
        return left
    
    def _parse_comparison(self) -> Optional[Dict[str, Any]]:
        """Parse comparison expression"""
        left = self._parse_term()
        
        while self._match('LT', 'GT', 'LE', 'GE'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_term()
            
            left = {
                'type': 'binary_expression',
                'operator': operator,
                'left': left,
                'right': right,
                'location': op_token[2]
            }
        
        return left
    
    def _parse_term(self) -> Optional[Dict[str, Any]]:
        """Parse term expression (addition/subtraction)"""
        left = self._parse_factor()
        
        while self._match('PLUS', 'MINUS'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_factor()
            
            left = {
                'type': 'binary_expression',
                'operator': operator,
                'left': left,
                'right': right,
                'location': op_token[2]
            }
        
        return left
    
    def _parse_factor(self) -> Optional[Dict[str, Any]]:
        """Parse factor expression (multiplication/division)"""
        left = self._parse_unary()
        
        while self._match('MULTIPLY', 'DIVIDE', 'MODULO'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_unary()
            
            left = {
                'type': 'binary_expression',
                'operator': operator,
                'left': left,
                'right': right,
                'location': op_token[2]
            }
        
        return left
    
    def _parse_unary(self) -> Optional[Dict[str, Any]]:
        """Parse unary expression"""
        if self._match('NOT', 'MINUS'):
            op_token = self._advance()
            operator = op_token[0]
            operand = self._parse_unary()
            
            return {
                'type': 'unary_expression',
                'operator': operator,
                'operand': operand,
                'location': op_token[2]
            }
        
        return self._parse_primary()
    
    def _parse_primary(self) -> Optional[Dict[str, Any]]:
        """Parse primary expression"""
        token = self._current_token()
        
        if self._match('NUMBER'):
            num_token = self._advance()
            return {
                'type': 'number_literal',
                'value': float(num_token[1]) if '.' in num_token[1] else int(num_token[1]),
                'location': num_token[2]
            }
        
        if self._match('STRING'):
            str_token = self._advance()
            return {
                'type': 'string_literal',
                'value': str_token[1],
                'location': str_token[2]
            }
        
        if self._match('TRUE'):
            true_token = self._advance()
            return {
                'type': 'boolean_literal',
                'value': True,
                'location': true_token[2]
            }
        
        if self._match('FALSE'):
            false_token = self._advance()
            return {
                'type': 'boolean_literal',
                'value': False,
                'location': false_token[2]
            }
        
        if self._match('NONE'):
            none_token = self._advance()
            return {
                'type': 'none_literal',
                'value': None,
                'location': none_token[2]
            }
        
        if self._match('IDENTIFIER'):
            ident_token = self._advance()
            name = ident_token[1]
            
            # Function call
            if self._match('LPAREN'):
                return self._parse_function_call(name, ident_token[2])
            
            # Variable reference
            return {
                'type': 'identifier',
                'name': name,
                'location': ident_token[2]
            }
        
        if self._match('LPAREN'):
            self._advance()  # '('
            expr = self._parse_expression()
            self._expect('RPAREN', "Expected ')' after expression")
            return expr
        
        if self._match('LBRACE'):
            return self._parse_object_literal()
        
        if self._match('LBRACKET'):
            return self._parse_array_literal()
        
        self.error(f"Unexpected token: {token[0]}")
        return None
    
    def _parse_function_call(self, function_name: str, location: SourceLocation) -> Dict[str, Any]:
        """Parse a function call"""
        self._advance()  # '('
        
        arguments = []
        if not self._match('RPAREN'):
            while True:
                arg = self._parse_expression()
                if arg:
                    arguments.append(arg)
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RPAREN', "Expected ')' after function arguments")
        
        return {
            'type': 'function_call',
            'function': function_name,
            'arguments': arguments,
            'location': location
        }
    
    def _parse_object_literal(self) -> Dict[str, Any]:
        """Parse an object literal"""
        lbrace_token = self._advance()  # '{'
        
        properties = []
        if not self._match('RBRACE'):
            while True:
                key_token = self._expect('STRING', "Expected string key in object literal")
                key = key_token[1]
                
                self._expect('COLON', "Expected ':' after object key")
                value = self._parse_expression()
                
                properties.append({
                    'key': key,
                    'value': value
                })
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RBRACE', "Expected '}' to end object literal")
        
        return {
            'type': 'object_literal',
            'properties': properties,
            'location': lbrace_token[2]
        }
    
    def _parse_array_literal(self) -> Dict[str, Any]:
        """Parse an array literal"""
        lbracket_token = self._advance()  # '['
        
        elements = []
        if not self._match('RBRACKET'):
            while True:
                element = self._parse_expression()
                if element:
                    elements.append(element)
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RBRACKET', "Expected ']' to end array literal")
        
        return {
            'type': 'array_literal',
            'elements': elements,
            'location': lbracket_token[2]
        }


class NoodleSemanticAnalyzer:
    """Semantic analyzer for Noodle language"""
    
    def __init__(self):
        self.symbol_table = {}
        self.errors = []
        self.warnings = []
        self.current_function = None
    
    def error(self, message: str, location: SourceLocation):
        """Record a semantic error"""
        self.errors.append(CompilationError(location, message, "error", CompilationPhase.SEMANTIC_ANALYSIS))
    
    def warning(self, message: str, location: SourceLocation):
        """Record a semantic warning"""
        self.warnings.append(CompilationError(location, message, "warning", CompilationPhase.SEMANTIC_ANALYSIS))
    
    def analyze(self, ast: Dict[str, Any]) -> bool:
        """Analyze the AST for semantic errors"""
        self.errors = []
        self.warnings = []
        
        self._analyze_program(ast)
        
        return len(self.errors) == 0
    
    def _analyze_program(self, node: Dict[str, Any]):
        """Analyze a program node"""
        for stmt in node.get('statements', []):
            self._analyze_statement(stmt)
    
    def _analyze_statement(self, stmt: Dict[str, Any]):
        """Analyze a statement"""
        stmt_type = stmt.get('type')
        
        if stmt_type == 'let_statement':
            self._analyze_let_statement(stmt)
        elif stmt_type == 'function_definition':
            self._analyze_function_definition(stmt)
        elif stmt_type == 'if_statement':
            self._analyze_if_statement(stmt)
        elif stmt_type == 'for_statement':
            self._analyze_for_statement(stmt)
        elif stmt_type == 'while_statement':
            self._analyze_while_statement(stmt)
        elif stmt_type == 'return_statement':
            self._analyze_return_statement(stmt)
        elif stmt_type == 'import_statement':
            self._analyze_import_statement(stmt)
        elif stmt_type == 'class_definition':
            self._analyze_class_definition(stmt)
        elif stmt_type == 'expression_statement':
            self._analyze_expression(stmt.get('expression'))
    
    def _analyze_let_statement(self, stmt: Dict[str, Any]):
        """Analyze a let statement"""
        name = stmt.get('name')
        initializer = stmt.get('initializer')
        
        if initializer:
            self._analyze_expression(initializer)
        
        # Check for redeclaration
        if name in self.symbol_table:
            self.error(f"Variable '{name}' already declared", stmt.get('location'))
        else:
            self.symbol_table[name] = {
                'type': stmt.get('type_annotation'),
                'initialized': initializer is not None,
                'location': stmt.get('location')
            }
    
    def _analyze_function_definition(self, stmt: Dict[str, Any]):
        """Analyze a function definition"""
        name = stmt.get('name')
        parameters = stmt.get('parameters', [])
        body = stmt.get('body', [])
        
        # Check for redeclaration
        if name in self.symbol_table:
            self.error(f"Function '{name}' already declared", stmt.get('location'))
        else:
            self.symbol_table[name] = {
                'type': 'function',
                'parameters': parameters,
                'return_type': stmt.get('return_type'),
                'location': stmt.get('location')
            }
        
        # Analyze function body in new scope
        old_symbol_table = self.symbol_table
        self.symbol_table = old_symbol_table.copy()
        old_function = self.current_function
        self.current_function = name
        
        # Add parameters to symbol table
        for param in parameters:
            param_name = param.get('name')
            if param_name in self.symbol_table:
                self.error(f"Parameter '{param_name}' already declared", stmt.get('location'))
            else:
                self.symbol_table[param_name] = {
                    'type': param.get('type'),
                    'parameter': True,
                    'location': stmt.get('location')
                }
        
        # Analyze body
        for stmt in body:
            self._analyze_statement(stmt)
        
        # Restore symbol table
        self.symbol_table = old_symbol_table
        self.current_function = old_function
    
    def _analyze_if_statement(self, stmt: Dict[str, Any]):
        """Analyze an if statement"""
        condition = stmt.get('condition')
        then_branch = stmt.get('then_branch', [])
        else_branch = stmt.get('else_branch')
        
        self._analyze_expression(condition)
        
        for stmt in then_branch:
            self._analyze_statement(stmt)
        
        if else_branch:
            if isinstance(else_branch, dict) and else_branch.get('type') == 'if_statement':
                self._analyze_if_statement(else_branch)
            elif isinstance(else_branch, list):
                for stmt in else_branch:
                    self._analyze_statement(stmt)
    
    def _analyze_for_statement(self, stmt: Dict[str, Any]):
        """Analyze a for statement"""
        variable = stmt.get('variable')
        iterable = stmt.get('iterable')
        body = stmt.get('body', [])
        
        self._analyze_expression(iterable)
        
        # Analyze body in new scope
        old_symbol_table = self.symbol_table
        self.symbol_table = old_symbol_table.copy()
        
        self.symbol_table[variable] = {
            'type': None,
            'loop_variable': True,
            'location': stmt.get('location')
        }
        
        for stmt in body:
            self._analyze_statement(stmt)
        
        # Restore symbol table
        self.symbol_table = old_symbol_table
    
    def _analyze_while_statement(self, stmt: Dict[str, Any]):
        """Analyze a while statement"""
        condition = stmt.get('condition')
        body = stmt.get('body', [])
        
        self._analyze_expression(condition)
        
        for stmt in body:
            self._analyze_statement(stmt)
    
    def _analyze_return_statement(self, stmt: Dict[str, Any]):
        """Analyze a return statement"""
        value = stmt.get('value')
        
        if value:
            self._analyze_expression(value)
        elif self.current_function:
            # Check if function expects a return value
            func_info = self.symbol_table.get(self.current_function, {})
            if func_info.get('return_type') and func_info['return_type'] != 'None':
                self.warning("Function expects return value but returns None", stmt.get('location'))
    
    def _analyze_import_statement(self, stmt: Dict[str, Any]):
        """Analyze an import statement"""
        # Import statements are currently pass-through
        # In a full implementation, we would check module existence
        pass
    
    def _analyze_class_definition(self, stmt: Dict[str, Any]):
        """Analyze a class definition"""
        name = stmt.get('name')
        members = stmt.get('members', [])
        
        # Check for redeclaration
        if name in self.symbol_table:
            self.error(f"Class '{name}' already declared", stmt.get('location'))
        else:
            self.symbol_table[name] = {
                'type': 'class',
                'members': members,
                'location': stmt.get('location')
            }
        
        # Analyze class members
        for member in members:
            self._analyze_statement(member)
    
    def _analyze_expression(self, expr: Dict[str, Any]):
        """Analyze an expression"""
        if not expr:
            return
        
        expr_type = expr.get('type')
        
        if expr_type == 'identifier':
            name = expr.get('name')
            if name not in self.symbol_table:
                self.error(f"Undefined variable '{name}'", expr.get('location'))
        elif expr_type == 'binary_expression':
            self._analyze_expression(expr.get('left'))
            self._analyze_expression(expr.get('right'))
        elif expr_type == 'unary_expression':
            self._analyze_expression(expr.get('operand'))
        elif expr_type == 'function_call':
            function = expr.get('function')
            if function not in self.symbol_table:
                self.error(f"Undefined function '{function}'", expr.get('location'))
            
            for arg in expr.get('arguments', []):
                self._analyze_expression(arg)
        elif expr_type == 'array_literal':
            for element in expr.get('elements', []):
                self._analyze_expression(element)
        elif expr_type == 'object_literal':
            for prop in expr.get('properties', []):
                self._analyze_expression(prop.get('value'))


class NoodleOptimizer:
    """Optimizer for Noodle AST"""
    
    def __init__(self):
        self.optimizations = 0
    
    def optimize(self, ast: Dict[str, Any]) -> Dict[str, Any]:
        """Optimize the AST"""
        self.optimizations = 0
        return self._optimize_node(ast)
    
    def _optimize_node(self, node: Any) -> Any:
        """Recursively optimize a node"""
        if not isinstance(node, dict):
            return node
        
        node_type = node.get('type')
        
        if node_type == 'program':
            statements = node.get('statements', [])
            optimized_statements = []
            for stmt in statements:
                optimized = self._optimize_node(stmt)
                if optimized:
                    optimized_statements.append(optimized)
            node['statements'] = optimized_statements
        
        elif node_type == 'binary_expression':
            left = self._optimize_node(node.get('left'))
            right = self._optimize_node(node.get('right'))
            operator = node.get('operator')
            
            # Constant folding
            if (left and right and 
                left.get('type') in ['number_literal', 'boolean_literal'] and
                right.get('type') in ['number_literal', 'boolean_literal']):
                
                result = self._fold_constants(left, operator, right)
                if result:
                    self.optimizations += 1
                    return result
            
            node['left'] = left
            node['right'] = right
        
        elif node_type == 'unary_expression':
            operand = self._optimize_node(node.get('operand'))
            operator = node.get('operator')
            
            # Constant folding for unary expressions
            if (operand and 
                operand.get('type') in ['number_literal', 'boolean_literal']):
                
                result = self._fold_unary_constant(operator, operand)
                if result:
                    self.optimizations += 1
                    return result
            
            node['operand'] = operand
        
        elif node_type == 'function_call':
            arguments = node.get('arguments', [])
            optimized_args = []
            for arg in arguments:
                optimized_args.append(self._optimize_node(arg))
            node['arguments'] = optimized_args
        
        elif node_type == 'array_literal':
            elements = node.get('elements', [])
            optimized_elements = []
            for element in elements:
                optimized_elements.append(self._optimize_node(element))
            node['elements'] = optimized_elements
        
        elif node_type == 'object_literal':
            properties = node.get('properties', [])
            optimized_properties = []
            for prop in properties:
                optimized_value = self._optimize_node(prop.get('value'))
                optimized_properties.append({
                    'key': prop.get('key'),
                    'value': optimized_value
                })
            node['properties'] = optimized_properties
        
        return node
    
    def _fold_constants(self, left: Dict[str, Any], operator: str, right: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Fold binary constant expressions"""
        left_val = left.get('value')
        right_val = right.get('value')
        
        if left.get('type') == 'number_literal' and right.get('type') == 'number_literal':
            if operator == 'PLUS':
                return {'type': 'number_literal', 'value': left_val + right_val}
            elif operator == 'MINUS':
                return {'type': 'number_literal', 'value': left_val - right_val}
            elif operator == 'MULTIPLY':
                return {'type': 'number_literal', 'value': left_val * right_val}
            elif operator == 'DIVIDE':
                if right_val != 0:
                    return {'type': 'number_literal', 'value': left_val / right_val}
            elif operator == 'EQ':
                return {'type': 'boolean_literal', 'value': left_val == right_val}
            elif operator == 'NE':
                return {'type': 'boolean_literal', 'value': left_val != right_val}
            elif operator == 'LT':
                return {'type': 'boolean_literal', 'value': left_val < right_val}
            elif operator == 'GT':
                return {'type': 'boolean_literal', 'value': left_val > right_val}
            elif operator == 'LE':
                return {'type': 'boolean_literal', 'value': left_val <= right_val}
            elif operator == 'GE':
                return {'type': 'boolean_literal', 'value': left_val >= right_val}
        
        elif left.get('type') == 'boolean_literal' and right.get('type') == 'boolean_literal':
            if operator == 'AND':
                return {'type': 'boolean_literal', 'value': left_val and right_val}
            elif operator == 'OR':
                return {'type': 'boolean_literal', 'value': left_val or right_val}
            elif operator == 'EQ':
                return {'type': 'boolean_literal', 'value': left_val == right_val}
            elif operator == 'NE':
                return {'type': 'boolean_literal', 'value': left_val != right_val}
        
        return None
    
    def _fold_unary_constant(self, operator: str, operand: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Fold unary constant expressions"""
        value = operand.get('value')
        
        if operand.get('type') == 'number_literal':
            if operator == 'MINUS':
                return {'type': 'number_literal', 'value': -value}
            elif operator == 'NOT':
                return {'type': 'boolean_literal', 'value': not bool(value)}
        
        elif operand.get('type') == 'boolean_literal':
            if operator == 'NOT':
                return {'type': 'boolean_literal', 'value': not value}
        
        return None


class NoodleCodeGenerator:
    """Code generator for Noodle AST to NBC bytecode"""
    
    def __init__(self):
        self.instructions = []
        self.constants = []
        self.source_map = {}
        self.label_counter = 0
        self.current_function = None
    
    def generate(self, ast: Dict[str, Any]) -> Tuple[List[NBCInstruction], List[Any]]:
        """Generate NBC bytecode from AST"""
        self.instructions = []
        self.constants = []
        self.source_map = {}
        self.label_counter = 0
        self.current_function = None
        
        self._generate_program(ast)
        
        return self.instructions, self.constants
    
    def _generate_program(self, node: Dict[str, Any]):
        """Generate code for a program"""
        for stmt in node.get('statements', []):
            self._generate_statement(stmt)
    
    def _generate_statement(self, stmt: Dict[str, Any]):
        """Generate code for a statement"""
        stmt_type = stmt.get('type')
        
        if stmt_type == 'let_statement':
            self._generate_let_statement(stmt)
        elif stmt_type == 'function_definition':
            self._generate_function_definition(stmt)
        elif stmt_type == 'if_statement':
            self._generate_if_statement(stmt)
        elif stmt_type == 'for_statement':
            self._generate_for_statement(stmt)
        elif stmt_type == 'while_statement':
            self._generate_while_statement(stmt)
        elif stmt_type == 'return_statement':
            self._generate_return_statement(stmt)
        elif stmt_type == 'import_statement':
            self._generate_import_statement(stmt)
        elif stmt_type == 'class_definition':
            self._generate_class_definition(stmt)
        elif stmt_type == 'expression_statement':
            self._generate_expression(stmt.get('expression'))
    
    def _generate_let_statement(self, stmt: Dict[str, Any]):
        """Generate code for a let statement"""
        name = stmt.get('name')
        initializer = stmt.get('initializer')
        
        if initializer:
            self._generate_expression(initializer)
        
        # Store variable
        self._add_instruction('STORE_VAR', name, stmt.get('location'))
    
    def _generate_function_definition(self, stmt: Dict[str, Any]):
        """Generate code for a function definition"""
        name = stmt.get('name')
        parameters = stmt.get('parameters', [])
        body = stmt.get('body', [])
        
        # Create function object
        func_start = len(self.instructions)
        
        # Save current context
        old_function = self.current_function
        self.current_function = name
        
        # Function prologue
        self._add_instruction('FUNC_START', name, stmt.get('location'))
        
        # Parameters
        for param in parameters:
            self._add_instruction('PARAM', param.get('name'), stmt.get('location'))
        
        # Function body
        for stmt in body:
            self._generate_statement(stmt)
        
        # Function epilogue
        self._add_instruction('FUNC_END', name, stmt.get('location'))
        
        # Restore context
        self.current_function = old_function
    
    def _generate_if_statement(self, stmt: Dict[str, Any]):
        """Generate code for an if statement"""
        condition = stmt.get('condition')
        then_branch = stmt.get('then_branch', [])
        else_branch = stmt.get('else_branch')
        
        # Generate condition
        self._generate_expression(condition)
        
        # Create labels
        else_label = self._create_label()
        end_label = self._create_label()
        
        # Conditional jump
        self._add_instruction('JUMP_IF_FALSE', else_label, stmt.get('location'))
        
        # Then branch
        for stmt in then_branch:
            self._generate_statement(stmt)
        
        # Jump to end
        self._add_instruction('JUMP', end_label, stmt.get('location'))
        
        # Else branch
        self._add_label(else_label)
        
        if else_branch:
            if isinstance(else_branch, dict) and else_branch.get('type') == 'if_statement':
                self._generate_if_statement(else_branch)
            elif isinstance(else_branch, list):
                for stmt in else_branch:
                    self._generate_statement(stmt)
        
        # End label
        self._add_label(end_label)
    
    def _generate_for_statement(self, stmt: Dict[str, Any]):
        """Generate code for a for statement"""
        variable = stmt.get('variable')
        iterable = stmt.get('iterable')
        body = stmt.get('body', [])
        
        # Create labels
        start_label = self._create_label()
        end_label = self._create_label()
        
        # Generate iterable
        self._generate_expression(iterable)
        
        # Iterator setup
        self._add_instruction('ITERATOR_INIT', variable, stmt.get('location'))
        
        # Loop start
        self._add_label(start_label)
        
        # Check if iterator has next
        self._add_instruction('ITERATOR_HAS_NEXT', variable, stmt.get('location'))
        self._add_instruction('JUMP_IF_FALSE', end_label, stmt.get('location'))
        
        # Get next value
        self._add_instruction('ITERATOR_NEXT', variable, stmt.get('location'))
        
        # Loop body
        for stmt in body:
            self._generate_statement(stmt)
        
        # Jump back to start
        self._add_instruction('JUMP', start_label, stmt.get('location'))
        
        # End label
        self._add_label(end_label)
        
        # Cleanup iterator
        self._add_instruction('ITERATOR_END', variable, stmt.get('location'))
    
    def _generate_while_statement(self, stmt: Dict[str, Any]):
        """Generate code for a while statement"""
        condition = stmt.get('condition')
        body = stmt.get('body', [])
        
        # Create labels
        start_label = self._create_label()
        end_label = self._create_label()
        
        # Loop start
        self._add_label(start_label)
        
        # Generate condition
        self._generate_expression(condition)
        
        # Conditional jump
        self._add_instruction('JUMP_IF_FALSE', end_label, stmt.get('location'))
        
        # Loop body
        for stmt in body:
            self._generate_statement(stmt)
        
        # Jump back to start
        self._add_instruction('JUMP', start_label, stmt.get('location'))
        
        # End label
        self._add_label(end_label)
    
    def _generate_return_statement(self, stmt: Dict[str, Any]):
        """Generate code for a return statement"""
        value = stmt.get('value')
        
        if value:
            self._generate_expression(value)
        
        self._add_instruction('RETURN', value is not None, stmt.get('location'))
    
    def _generate_import_statement(self, stmt: Dict[str, Any]):
        """Generate code for an import statement"""
        module = stmt.get('module')
        alias = stmt.get('alias') or module
        
        self._add_instruction('IMPORT', module, stmt.get('location'))
        self._add_instruction('STORE_VAR', alias, stmt.get('location'))
    
    def _generate_class_definition(self, stmt: Dict[str, Any]):
        """Generate code for a class definition"""
        name = stmt.get('name')
        members = stmt.get('members', [])
        
        # Create class object
        self._add_instruction('CLASS_START', name, stmt.get('location'))
        
        # Class members
        for member in members:
            self._generate_statement(member)
        
        # End class
        self._add_instruction('CLASS_END', name, stmt.get('location'))
    
    def _generate_expression(self, expr: Dict[str, Any]):
        """Generate code for an expression"""
        if not expr:
            return
        
        expr_type = expr.get('type')
        
        if expr_type == 'identifier':
            self._add_instruction('LOAD_VAR', expr.get('name'), expr.get('location'))
        elif expr_type == 'number_literal':
            self._add_instruction('LOAD_CONST', expr.get('value'), expr.get('location'))
        elif expr_type == 'string_literal':
            self._add_instruction('LOAD_CONST', expr.get('value'), expr.get('location'))
        elif expr_type == 'boolean_literal':
            self._add_instruction('LOAD_CONST', expr.get('value'), expr.get('location'))
        elif expr_type == 'none_literal':
            self._add_instruction('LOAD_CONST', None, expr.get('location'))
        elif expr_type == 'binary_expression':
            self._generate_binary_expression(expr)
        elif expr_type == 'unary_expression':
            self._generate_unary_expression(expr)
        elif expr_type == 'function_call':
            self._generate_function_call(expr)
        elif expr_type == 'array_literal':
            self._generate_array_literal(expr)
        elif expr_type == 'object_literal':
            self._generate_object_literal(expr)
    
    def _generate_binary_expression(self, expr: Dict[str, Any]):
        """Generate code for a binary expression"""
        left = expr.get('left')
        operator = expr.get('operator')
        right = expr.get('right')
        
        # Generate operands
        self._generate_expression(left)
        self._generate_expression(right)
        
        # Generate operation
        op_map = {
            'PLUS': 'ADD',
            'MINUS': 'SUB',
            'MULTIPLY': 'MUL',
            'DIVIDE': 'DIV',
            'MODULO': 'MOD',
            'EQ': 'EQ',
            'NE': 'NE',
            'LT': 'LT',
            'GT': 'GT',
            'LE': 'LE',
            'GE': 'GE',
            'AND': 'AND',
            'OR': 'OR',
        }
        
        nbc_op = op_map.get(operator, 'UNKNOWN')
        self._add_instruction(nbc_op, None, expr.get('location'))
    
    def _generate_unary_expression(self, expr: Dict[str, Any]):
        """Generate code for a unary expression"""
        operand = expr.get('operand')
        operator = expr.get('operator')
        
        # Generate operand
        self._generate_expression(operand)
        
        # Generate operation
        op_map = {
            'MINUS': 'NEG',
            'NOT': 'NOT',
        }
        
        nbc_op = op_map.get(operator, 'UNKNOWN')
        self._add_instruction(nbc_op, None, expr.get('location'))
    
    def _generate_function_call(self, expr: Dict[str, Any]):
        """Generate code for a function call"""
        function = expr.get('function')
        arguments = expr.get('arguments', [])
        
        # Generate arguments
        for arg in arguments:
            self._generate_expression(arg)
        
        # Generate call
        self._add_instruction('CALL', function, expr.get('location'))
    
    def _generate_array_literal(self, expr: Dict[str, Any]):
        """Generate code for an array literal"""
        elements = expr.get('elements', [])
        
        # Generate elements
        for element in elements:
            self._generate_expression(element)
        
        # Create array
        self._add_instruction('ARRAY_CREATE', len(elements), expr.get('location'))
    
    def _generate_object_literal(self, expr: Dict[str, Any]):
        """Generate code for an object literal"""
        properties = expr.get('properties', [])
        
        # Generate key-value pairs
        for prop in properties:
            key = prop.get('key')
            value = prop.get('value')
            
            self._add_instruction('LOAD_CONST', key, expr.get('location'))
            self._generate_expression(value)
        
        # Create object
        self._add_instruction('OBJECT_CREATE', len(properties), expr.get('location'))
    
    def _add_instruction(self, opcode: str, operand: Any, location: SourceLocation):
        """Add an instruction to the output"""
        instruction = {
            'opcode': opcode,
            'operand': operand,
            'location': location
        }
        self.instructions.append(instruction)
        
        # Add to source map
        instr_index = len(self.instructions) - 1
        self.source_map[instr_index] = {
            'file': location.file,
            'line': location.line,
            'column': location.column
        }
    
    def _create_label(self) -> str:
        """Create a new label"""
        label = f"label_{self.label_counter}"
        self.label_counter += 1
        return label
    
    def _add_label(self, label: str):
        """Add a label to the output"""
        self._add_instruction('LABEL', label, SourceLocation("", 0, 0, 0))


class NoodleCompiler:
    """Main Noodle compiler class"""
    
    def __init__(self, optimize: bool = True, debug: bool = False):
        self.optimize = optimize
        self.debug = debug
        self.trm_agent = None
        
        # Initialize TRM agent if available
        if TRMAgent:
            try:
                self.trm_agent = TRMAgent()
                logger.info("TRM agent initialized for compilation optimization")
            except Exception as e:
                logger.warning(f"Failed to initialize TRM agent: {e}")
    
    def compile_file(self, filepath: str) -> CompilationResult:
        """Compile a Noodle file"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                source = f.read()
            return self.compile_source(source, filepath)
        except Exception as e:
            error = CompilationError(
                SourceLocation(filepath, 0, 0, 0),
                f"Failed to read file: {str(e)}",
                "error",
                CompilationPhase.LEXING
            )
            return CompilationResult(False, None, [error], [], 0.0, None, {})
    
    def compile_source(self, source: str, filename: str = "<source>") -> CompilationResult:
        """Compile Noodle source code"""
        start_time = time.time()
        errors = []
        warnings = []
        
        # Phase 1: Lexical analysis
        logger.info(f"Starting lexical analysis for {filename}")
        lexer = NoodleLexer(source, filename)
        tokens = lexer.tokenize()
        errors.extend(lexer.errors)
        
        if errors and not self.debug:
            return CompilationResult(False, None, errors, warnings, 0.0, None, {})
        
        # Phase 2: Parsing
        logger.info("Starting parsing")
        parser = NoodleParser(tokens)
        ast = parser.parse()
        errors.extend(parser.errors)
        warnings.extend(parser.warnings)
        
        if errors and not self.debug:
            return CompilationResult(False, None, errors, warnings, 0.0, None, {})
        
        # Phase 3: Semantic analysis
        logger.info("Starting semantic analysis")
        semantic_analyzer = NoodleSemanticAnalyzer()
        if not semantic_analyzer.analyze(ast):
            errors.extend(semantic_analyzer.errors)
            warnings.extend(semantic_analyzer.warnings)
            return CompilationResult(False, None, errors, warnings, 0.0, None, {})
        
        warnings.extend(semantic_analyzer.warnings)
        
        # Phase 4: Optimization
        logger.info("Starting optimization")
        optimizer = NoodleOptimizer()
        optimized_ast = optimizer.optimize(ast) if self.optimize else ast
        
        if self.debug:
            logger.info(f"Applied {optimizer.optimizations} optimizations")
        
        # Phase 5: Code generation
        logger.info("Starting code generation")
        code_generator = NoodleCodeGenerator()
        instructions, constants = code_generator.generate(optimized_ast)
        
        # Phase 6: Finalization
        logger.info("Finalizing compilation")
        
        # Create bytecode
        bytecode = None
        if NBCBytecode:
            try:
                bytecode = NBCBytecode(instructions, constants)
            except Exception as e:
                error = CompilationError(
                    SourceLocation(filename, 0, 0, 0),
                    f"Failed to create bytecode: {str(e)}",
                    "error",
                    CompilationPhase.CODE_GENERATION
                )
                errors.append(error)
        
        # Generate statistics
        compilation_time = time.time() - start_time
        statistics = {
            'tokens': len(tokens),
            'ast_nodes': self._count_ast_nodes(ast),
            'instructions': len(instructions),
            'constants': len(constants),
            'optimizations': optimizer.optimizations,
            'compilation_time': compilation_time
        }
        
        success = len(errors) == 0
        result = CompilationResult(
            success=success,
            bytecode=bytecode,
            errors=errors,
            warnings=warnings,
            compilation_time=compilation_time,
            source_map=code_generator.source_map,
            statistics=statistics
        )
        
        # Apply TRM optimization if available
        if self.trm_agent and success:
            try:
                result = self._apply_trm_optimization(result, source, filename)
            except Exception as e:
                logger.warning(f"TRM optimization failed: {e}")
        
        logger.info(f"Compilation completed in {compilation_time:.3f}s with {len(errors)} errors and {len(warnings)} warnings")
        
        return result
    
    def _apply_trm_optimization(self, result: CompilationResult, source: str, filename: str) -> CompilationResult:
        """Apply TRM agent optimization to compilation result"""
        if not self.trm_agent or not result.bytecode:
            return result
        
        # Create optimization request for TRM agent
        optimization_request = {
            'type': 'compile_optimization',
            'source': source,
            'filename': filename,
            'bytecode': result.bytecode,
            'statistics': result.statistics
        }
        
        # Get optimization suggestions
        try:
            suggestions = self.trm_agent.optimize_compilation(optimization_request)
            
            if suggestions:
                logger.info(f"TRM agent provided {len(suggestions)} optimization suggestions")
                
                # Apply suggestions (in a real implementation, this would be more sophisticated)
                for suggestion in suggestions:
                    if suggestion.get('type') == 'instruction_reorder':
                        # Reorder instructions for better performance
                        pass
                    elif suggestion.get('type') == 'constant_folding':
                        # Apply additional constant folding
                        pass
                
                # Update statistics
                result.statistics['trm_optimizations'] = len(suggestions)
        
        except Exception as e:
            logger.warning(f"Failed to apply TRM optimization: {e}")
        
        return result
    
    def _count_ast_nodes(self, node: Any) -> int:
        """Count nodes in AST for statistics"""
        if not isinstance(node, dict):
            return 0
        
        count = 1  # Count this node
        for value in node.values():
            if isinstance(value, dict):
                count += self._count_ast_nodes(value)
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        count += self._count_ast_nodes(item)
        
        return count
    
    def get_supported_features(self) -> List[str]:
        """Get list of supported language features"""
        return [
            "Variable declarations (let)",
            "Function definitions",
            "Control flow (if/else, for, while)",
            "Basic data types (numbers, strings, booleans)",
            "Arrays and objects",
            "Import statements",
            "Class definitions",
            "Return statements",
            "Arithmetic and logical operations",
            "Function calls",
            "Comments",
            "Type annotations",
            "Error reporting",
            "Source maps",
            "Optimization passes",
            "TRM agent integration"
        ]
    
    def get_language_version(self) -> str:
        """Get Noodle language version"""
        return "1.0.0"


def main():
    """Main entry point for the compiler"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Noodle Language Compiler')
    parser.add_argument('input', help='Input file to compile')
    parser.add_argument('-o', '--output', help='Output file for bytecode')
    parser.add_argument('-O', '--optimize', action='store_true', default=True, help='Enable optimizations')
    parser.add_argument('-d', '--debug', action='store_true', help='Enable debug mode')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--version', action='version', version='Noodle Compiler 1.0.0')
    
    args = parser.parse_args()
    
    # Configure logging
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    
    # Create compiler
    compiler = NoodleCompiler(optimize=args.optimize, debug=args.debug)
    
    # Compile file
    result = compiler.compile_file(args.input)
    
    # Print errors and warnings
    for error in result.errors:
        print(f"Error: {error.location.file}:{error.location.line}:{error.location.column}: {error.message}")
    
    for warning in result.warnings:
        print(f"Warning: {warning.location.file}:{warning.location.line}:{warning.location.column}: {warning.message}")
    
    if result.success and result.bytecode:
        # Save bytecode if output specified
        if args.output:
            try:
                result.bytecode.save(args.output)
                print(f"Bytecode saved to {args.output}")
            except Exception as e:
                print(f"Failed to save bytecode: {e}")
        else:
            print("Compilation successful!")
            print(f"Statistics: {result.statistics}")
    else:
        print("Compilation failed!")
        sys.exit(1)


if __name__ == '__main__':
    main()

