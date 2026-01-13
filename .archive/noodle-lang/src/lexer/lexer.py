"""
Lexer::Lexer - lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

# Noodle Language Lexer - Python Implementation
# ----------------------------------------------
# 
# Python version of the unified lexer for Noodle language
# Provides consistent token processing and error handling

import re
import enum
import time
import dataclasses
from typing import List, Optional, Dict, Any

logger = None  # Simple logger placeholder

class TokenType(enum.Enum):
    """Token types for Noodle language"""
    
    # Literals
    IDENTIFIER = "IDENTIFIER"
    NUMBER = "NUMBER"
    STRING = "STRING"
    BOOLEAN = "BOOLEAN"
    NULL = "NULL"
    
    # Operators
    PLUS = "PLUS"
    MINUS = "MINUS"
    MULTIPLY = "MULTIPLY"
    DIVIDE = "DIVIDE"
    MODULO = "MODULO"
    POWER = "POWER"
    
    # Comparison
    EQUAL = "EQUAL"
    NOT_EQUAL = "NOT_EQUAL"
    LESS_THAN = "LESS_THAN"
    LESS_EQUAL = "LESS_EQUAL"
    GREATER_THAN = "GREATER_THAN"
    GREATER_EQUAL = "GREATER_EQUAL"
    
    # Logical
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
    
    # Assignment
    ASSIGN = "ASSIGN"
    
    # Delimiters
    COMMA = "COMMA"
    SEMICOLON = "SEMICOLON"
    COLON = "COLON"
    DOT = "DOT"
    
    # Brackets
    LEFT_PAREN = "LEFT_PAREN"
    RIGHT_PAREN = "RIGHT_PAREN"
    LEFT_BRACE = "LEFT_BRACE"
    RIGHT_BRACE = "RIGHT_BRACE"
    LEFT_BRACKET = "LEFT_BRACKET"
    RIGHT_BRACKET = "RIGHT_BRACKET"
    
    # Keywords
    IF = "IF"
    ELSE = "ELSE"
    ELIF = "ELIF"
    WHILE = "WHILE"
    FOR = "FOR"
    FUNCTION = "FUNCTION"
    RETURN = "RETURN"
    BREAK = "BREAK"
    CONTINUE = "CONTINUE"
    IMPORT = "IMPORT"
    CLASS = "CLASS"
    EXTENDS = "EXTENDS"
    
    # Special
    NEWLINE = "NEWLINE"
    INDENT = "INDENT"
    DEDENT = "DEDENT"
    EOF = "EOF"
    UNKNOWN = "UNKNOWN"

@dataclasses.dataclass
class Token:
    """Token representation for Noodle language"""
    
    type: TokenType
    value: str
    line: int
    column: int
    position: Optional["Position"] = None
    
    def __str__(self) -> str:
        return f"Token({self.type.value}, '{self.value}', {self.line}:{self.column})"

@dataclasses.dataclass
class Position:
    """Position information for error messages"""
    
    line: int
    column: int
    filename: str = "<string>"
    
    def __str__(self) -> str:
        return f"{self.filename}:{self.line}:{self.column}"

class LexerError(Exception):
    """Lexer error with context information"""
    
    def __init__(self, message: str, position: Optional[Position] = None):
        self.message = message
        self.position = position
        super().__init__(f"Lexer Error: {message}")
    
    def __str__(self) -> str:
        if self.position:
            return f"Lexer Error at {self.position}: {self.message}"
        return f"Lexer Error: {self.message}"

class Lexer:
    """Unified lexer for Noodle language"""
    
    def __init__(self, source_code: str, filename: str = "<string>"):
        self.source_code = source_code
        self.filename = filename
        self.position = Position(line=1, column=1, filename=filename)
        self.tokens: List[Token] = []
        self.errors: List[LexerError] = []
        self.keywords = {
            "if", "else", "elif", "while", "for", "function", 
            "return", "break", "continue", "import", "class", "extends"
        }
        
        # Precompile regex patterns for performance
        self.patterns = {
            'identifier': re.compile(r'[a-zA-Z_][a-zA-Z0-9_]*'),
            'number': re.compile(r'\d+(\.\d+)?'),
            'string': re.compile(r'"([^"\\]|\\.)*"'),
            'boolean': re.compile(r'(true|false)'),
            'operator': re.compile(r'[\+\-\*/%=!<>=]'),
            'assignment': re.compile(r'='),
            'delimiter': re.compile(r'[,\;:\.\(\)\{\}\[\]]'),
            'whitespace': re.compile(r'\s+'),
            'newline': re.compile(r'\n'),
        }
        
        self.start_time = time.time()
    
    def tokenize(self) -> List[Token]:
        """Convert source code to token list"""
        start_time = time.time()
        
        try:
            while not self._is_at_end():
                self._skip_whitespace_and_comments()
                
                if self._is_at_end():
                    break
                    
                # Check for multi-character tokens
                char = self._current_char()
                
                # Numbers
                if char.isdigit() or (char == '.' and self._peek_next_char() and self._peek_next_char().isdigit()):
                    self._tokenize_number()
                
                # Strings
                elif char == '"':
                    self._tokenize_string()
                
                # Identifiers and keywords
                elif char.isalpha() or char == '_':
                    self._tokenize_identifier_or_keyword()
                
                # Operators and delimiters
                elif char in '+-*/%=!<>=;:,.(){}[]':
                    self._tokenize_operator_or_delimiter()
                
                # Skip unknown characters but continue
                else:
                    self._advance_position()
        
        except Exception as e:
            if logger:
                logger.error(f"Tokenization failed: {e}")
            self._add_error(f"Tokenization error: {str(e)}")
        
        # Add EOF token
        self._add_token(TokenType.EOF, "")
        
        tokenize_time = time.time() - start_time
        if logger:
            logger.info(f"Tokenized {len(self.tokens)} tokens in {tokenize_time:.3f}s")
        
        return self.tokens
    
    def _is_at_end(self) -> bool:
        """Check if we're at the end of the source"""
        lines = self.source_code.split('\n')
        if self.position.line > len(lines):
            return True
        if self.position.line == len(lines):
            return self.position.column > len(lines[-1])
        return False
    
    def _current_char(self) -> str:
        """Get current character"""
        lines = self.source_code.split('\n')
        if self.position.line <= len(lines):
            line = lines[self.position.line - 1]
            if self.position.column <= len(line):
                return line[self.position.column - 1]
        return ''
    
    def _peek_next_char(self) -> str:
        """Peek at next character without advancing"""
        lines = self.source_code.split('\n')
        if self.position.line <= len(lines):
            line = lines[self.position.line - 1]
            next_col = self.position.column
            if next_col < len(line):
                return line[next_col]
        return ''
    
    def _advance_position(self, steps: int = 1):
        """Advance position"""
        self.position.column += steps
        
        # Handle new lines
        lines = self.source_code.split('\n')
        if self.position.line <= len(lines):
            current_line_length = len(lines[self.position.line - 1])
            if self.position.column > current_line_length:
                self.position.line += 1
                self.position.column = 1
    
    def _skip_whitespace_and_comments(self):
        """Skip whitespace and comments"""
        while not self._is_at_end():
            char = self._current_char()
            
            # Whitespace
            if char.isspace():
                self._advance_position()
                continue
            
            # Single line comments
            if char == '#':
                self._advance_position()
                while not self._is_at_end() and self._current_char() != '\n':
                    self._advance_position()
                continue
            
            # Multi-line comments
            if char == '/' and self._peek_next_char() == '*':
                self._advance_position(2)  # Skip '/*'
                while not self._is_at_end():
                    if self._current_char() == '*' and self._peek_next_char() == '/':
                        self._advance_position(2)  # Skip '*/'
                        break
                    self._advance_position()
                continue
            
            break
    
    def _tokenize_number(self):
        """Tokenize numbers"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        number_str = ''
        
        while not self._is_at_end():
            char = self._current_char()
            if char.isdigit() or (char == '.' and self._peek_next_char() and self._peek_next_char().isdigit()):
                number_str += char
                self._advance_position()
            else:
                break
        
        self._add_token(TokenType.NUMBER, number_str, start_pos)
    
    def _tokenize_string(self):
        """Tokenize strings"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        self._advance_position()  # Skip opening quote
        
        string_value = ''
        while not self._is_at_end() and self._current_char() != '"':
            char = self._current_char()
            
            # Escape sequences
            if char == '\\':
                self._advance_position()
                if not self._is_at_end():
                    escaped_char = self._current_char()
                    string_value += '\\' + escaped_char
                    self._advance_position()
                continue
            
            string_value += char
            self._advance_position()
        
        self._add_token(TokenType.STRING, string_value, start_pos)
    
    def _tokenize_identifier_or_keyword(self):
        """Tokenize identifiers or keywords"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        identifier = ''
        
        while not self._is_at_end():
            char = self._current_char()
            if char.isalnum() or char == '_':
                identifier += char
                self._advance_position()
            else:
                break
        
        # Check if it's a keyword
        if identifier in self.keywords:
            token_type = getattr(TokenType, identifier.upper(), TokenType.IDENTIFIER)
        else:
            token_type = TokenType.IDENTIFIER
        
        self._add_token(token_type, identifier, start_pos)
    
    def _tokenize_operator_or_delimiter(self):
        """Tokenize operators and delimiters"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        char = self._current_char()
        
        # Map single characters to token types
        token_map = {
            '+': TokenType.PLUS,
            '-': TokenType.MINUS,
            '*': TokenType.MULTIPLY,
            '/': TokenType.DIVIDE,
            '%': TokenType.MODULO,
            '=': TokenType.ASSIGN,
            '<': TokenType.LESS_THAN,
            '>': TokenType.GREATER_THAN,
            ',': TokenType.COMMA,
            ';': TokenType.SEMICOLON,
            ':': TokenType.COLON,
            '.': TokenType.DOT,
            '(': TokenType.LEFT_PAREN,
            ')': TokenType.RIGHT_PAREN,
            '{': TokenType.LEFT_BRACE,
            '}': TokenType.RIGHT_BRACE,
            '[': TokenType.LEFT_BRACKET,
            ']': TokenType.RIGHT_BRACKET,
        }
        
        # Handle multi-character operators
        if char in ['=', ':', '==', '!=', '<=', '>=']:
            # Check for two-character operators
            next_char = self._peek_next_char()
            if char + next_char in ['==', '!=', '<=', '>=']:
                self._advance_position(2)
                operator_map = {
                    '==': TokenType.EQUAL,
                    '!=': TokenType.NOT_EQUAL,
                    '<=': TokenType.LESS_EQUAL,
                    '>=': TokenType.GREATER_EQUAL,
                }
                self._add_token(operator_map[char + next_char], char + next_char, start_pos)
            else:
                self._advance_position()
                self._add_token(token_map[char], char, start_pos)
        else:
            self._advance_position()
            self._add_token(token_map[char], char, start_pos)
    
    def _add_token(self, token_type: TokenType, value: str, position: Optional[Position] = None):
        """Add token to list"""
        token = Token(
            type=token_type,
            value=value,
            line=position.line if position else self.position.line,
            column=position.column if position else self.position.column,
            position=position or self.position
        )
        self.tokens.append(token)
    
    def _add_error(self, message: str):
        """Add error to list"""
        error = LexerError(message, Position(line=self.position.line, column=self.position.column, filename=self.filename))
        self.errors.append(error)
        if logger:
            logger.warning(f"Lexer error: {message} at {self.position}")
    
    def get_errors(self) -> List[LexerError]:
        """Get all lexer errors"""
        return self.errors
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get lexer statistics"""
        tokenize_time = time.time() - self.start_time
        
        return {
            'tokens_count': len(self.tokens),
            'errors_count': len(self.errors),
            'tokenize_time': tokenize_time,
            'tokens_per_second': len(self.tokens) / tokenize_time if tokenize_time > 0 else 0,
            'source_lines': len(self.source_code.split('\n')),
            'source_characters': len(self.source_code),
        }

# Utility functions
def tokenize(source_code: str, filename: str = "<string>") -> List[Token]:
    """
    Convert Noodle source code to token list
    
    Args:
        source_code: The source code to tokenize
        filename: Optional filename for error messages
    
    Returns:
        List of tokens
    """
    lexer = Lexer(source_code, filename)
    return lexer.tokenize()

def validate_syntax(tokens: List[Token]) -> List[str]:
    """
    Validate basic syntax of token list
    
    Args:
        tokens: Token list to validate
    
    Returns:
        List of syntax errors
    """
    errors = []
    
    # Simple validation rules
    paren_count = sum(1 for token in tokens if token.type == TokenType.LEFT_PAREN)
    paren_close_count = sum(1 for token in tokens if token.type == TokenType.RIGHT_PAREN)
    
    if paren_count != paren_close_count:
        errors.append("Mismatched parentheses")
    
    # Check for semicolons at end of statements
    for i, token in enumerate(tokens):
        if token.type == TokenType.SEMICOLON:
            next_token = tokens[i + 1] if i + 1 < len(tokens) else None
            if next_token and next_token.type not in [TokenType.NEWLINE, TokenType.EOF, TokenType.RIGHT_BRACE]:
                errors.append(f"Unexpected token after semicolon at line {token.line}")
    
    return errors

