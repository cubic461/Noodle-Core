#!/usr/bin/env python3
"""
Noodle Lang::Lexer - lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Noodle Language Lexer

This module implements lexical analysis for the Noodle programming language,
converting source code into a stream of tokens.

Features:
- Complete token set for Noodle language
- Source location tracking
- Error reporting with line/column information
- Support for comments and whitespace
- String literals with escape sequences
- Number literals (integers and floats)
"""

import re
from typing import List, Tuple, Optional, Dict, Any
from dataclasses import dataclass
from enum import Enum

# Import CompilationPhase from compiler module
try:
    from .compiler import CompilationPhase
except ImportError:
    # Fallback: define a simple enum if compiler module is not available
    class CompilationPhase(Enum):
        LEXING = "lexing"
        PARSING = "parsing"
        SEMANTIC_ANALYSIS = "semantic_analysis"
        OPTIMIZATION = "optimization"
        CODE_GENERATION = "code_generation"


class TokenType(Enum):
    """Token types for Noodle language"""
    
    # Keywords
    LET = "LET"
    DEF = "DEF"
    RETURN = "RETURN"
    IF = "IF"
    ELSE = "ELSE"
    FOR = "FOR"
    IN = "IN"
    WHILE = "WHILE"
    BREAK = "BREAK"
    CONTINUE = "CONTINUE"
    IMPORT = "IMPORT"
    FROM = "FROM"
    AS = "AS"
    CLASS = "CLASS"
    STRUCT = "STRUCT"
    INTERFACE = "INTERFACE"
    IMPLEMENTS = "IMPLEMENTS"
    EXTENDS = "EXTENDS"
    TYPE = "TYPE"
    ENUM = "ENUM"
    MATCH = "MATCH"
    CASE = "CASE"
    DEFAULT = "DEFAULT"
    ASYNC = "ASYNC"
    AWAIT = "AWAIT"
    YIELD = "YIELD"
    TRUE = "TRUE"
    FALSE = "FALSE"
    NONE = "NONE"
    
    # Literals
    IDENTIFIER = "IDENTIFIER"
    NUMBER = "NUMBER"
    STRING = "STRING"
    
    # Operators
    PLUS = "PLUS"
    MINUS = "MINUS"
    MULTIPLY = "MULTIPLY"
    DIVIDE = "DIVIDE"
    MODULO = "MODULO"
    ASSIGN = "ASSIGN"
    EQ = "EQ"
    NE = "NE"
    LT = "LT"
    GT = "GT"
    LE = "LE"
    GE = "GE"
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
    
    # Delimiters
    LPAREN = "LPAREN"
    RPAREN = "RPAREN"
    LBRACE = "LBRACE"
    RBRACE = "RBRACE"
    LBRACKET = "LBRACKET"
    RBRACKET = "RBRACKET"
    COMMA = "COMMA"
    DOT = "DOT"
    COLON = "COLON"
    SEMICOLON = "SEMICOLON"
    ARROW = "ARROW"
    DOUBLE_COLON = "DOUBLE_COLON"
    
    # Special
    NEWLINE = "NEWLINE"
    EOF = "EOF"
    UNKNOWN = "UNKNOWN"


@dataclass
class SourceLocation:
    """Source code location information"""
    file: str
    line: int
    column: int
    offset: int
    
    def __str__(self) -> str:
        return f"{self.file}:{self.line}:{self.column}"


@dataclass
class Token:
    """Token representing a lexical unit"""
    type: TokenType
    value: str
    location: SourceLocation
    
    def __str__(self) -> str:
        return f"Token({self.type.value}, '{self.value}', {self.location})"
    
    def __repr__(self) -> str:
        return self.__str__()


@dataclass
class CompilationError:
    """Compilation error with location and message"""
    location: SourceLocation
    message: str
    severity: str = "error"  # error, warning, info


class NoodleLexer:
    """Lexical analyzer for Noodle language"""
    
    # Keyword to token type mapping
    KEYWORDS = {
        'let': TokenType.LET,
        'def': TokenType.DEF,
        'return': TokenType.RETURN,
        'if': TokenType.IF,
        'else': TokenType.ELSE,
        'for': TokenType.FOR,
        'in': TokenType.IN,
        'while': TokenType.WHILE,
        'break': TokenType.BREAK,
        'continue': TokenType.CONTINUE,
        'import': TokenType.IMPORT,
        'from': TokenType.FROM,
        'as': TokenType.AS,
        'class': TokenType.CLASS,
        'struct': TokenType.STRUCT,
        'interface': TokenType.INTERFACE,
        'implements': TokenType.IMPLEMENTS,
        'extends': TokenType.EXTENDS,
        'type': TokenType.TYPE,
        'enum': TokenType.ENUM,
        'match': TokenType.MATCH,
        'case': TokenType.CASE,
        'default': TokenType.DEFAULT,
        'async': TokenType.ASYNC,
        'await': TokenType.AWAIT,
        'yield': TokenType.YIELD,
        'true': TokenType.TRUE,
        'false': TokenType.FALSE,
        'none': TokenType.NONE,
    }
    
    # Single-character tokens
    SINGLE_CHAR_TOKENS = {
        '+': TokenType.PLUS,
        '-': TokenType.MINUS,
        '*': TokenType.MULTIPLY,
        '/': TokenType.DIVIDE,
        '%': TokenType.MODULO,
        '=': TokenType.ASSIGN,
        '<': TokenType.LT,
        '>': TokenType.GT,
        '!': TokenType.NOT,
        '(': TokenType.LPAREN,
        ')': TokenType.RPAREN,
        '{': TokenType.LBRACE,
        '}': TokenType.RBRACE,
        '[': TokenType.LBRACKET,
        ']': TokenType.RBRACKET,
        ',': TokenType.COMMA,
        '.': TokenType.DOT,
        ':': TokenType.COLON,
        ';': TokenType.SEMICOLON,
    }
    
    # Multi-character operators
    MULTI_CHAR_OPERATORS = {
        '==': TokenType.EQ,
        '!=': TokenType.NE,
        '<=': TokenType.LE,
        '>=': TokenType.GE,
        '&&': TokenType.AND,
        '||': TokenType.OR,
        '->': TokenType.ARROW,
        '::': TokenType.DOUBLE_COLON,
        '//': TokenType.DIVIDE,
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
        self.errors.append(CompilationError(location, message, "error"))
    
    def warning(self, message: str, position: int = None):
        """Record a lexing warning"""
        if position is None:
            position = self.position
        
        line_num, col_num = self._get_line_column(position)
        location = SourceLocation(self.filename, line_num, col_num, position)
        self.errors.append(CompilationError(location, message, "warning"))
    
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
    
    def _peek_string(self, length: int) -> str:
        """Peek at a string of given length"""
        end = self.position + length
        if end > len(self.source):
            return self.source[self.position:]
        return self.source[self.position:end]
    
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
                elif escape_char == 'x':
                    # Hex escape sequence
                    hex_digits = self._peek_string(2)
                    if len(hex_digits) == 2 and all(c in '0123456789abcdefABCDEF' for c in hex_digits):
                        value += chr(int(hex_digits, 16))
                        self.position += 2
                        self.column += 2
                    else:
                        self.error(f"Invalid hex escape sequence: \\x{hex_digits}")
                        value += escape_char
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
    
    def _create_token(self, token_type: TokenType, value: str, position: int = None) -> Token:
        """Create a token with location information"""
        if position is None:
            position = self.position - len(value)
        
        line_num, col_num = self._get_line_column(position)
        location = SourceLocation(self.filename, line_num, col_num, position)
        return Token(token_type, value, location)
    
    def tokenize(self) -> List[Token]:
        """Tokenize the source code"""
        self.tokens = []
        self.errors = []
        
        while self.position < len(self.source):
            self._skip_whitespace()
            
            # Skip comments
            if self._skip_comment():
                continue
            
            start_pos = self.position
            
            # End of file
            if self._current_char() == '\0':
                self.tokens.append(self._create_token(TokenType.EOF, "", start_pos))
                break
            
            # Newline
            if self._current_char() == '\n':
                self.tokens.append(self._create_token(TokenType.NEWLINE, '\n', start_pos))
                self.position += 1
                self.line += 1
                self.column = 1
                continue
            
            # Multi-character operators (check first)
            two_char = self._peek_string(2)
            if two_char in self.MULTI_CHAR_OPERATORS:
                token_type = self.MULTI_CHAR_OPERATORS[two_char]
                self.tokens.append(self._create_token(token_type, two_char, start_pos))
                self.position += 2
                self.column += 2
                continue
            
            # Single-character operators
            current_char = self._current_char()
            if current_char in self.SINGLE_CHAR_TOKENS:
                token_type = self.SINGLE_CHAR_TOKENS[current_char]
                self.tokens.append(self._create_token(token_type, current_char, start_pos))
                self.position += 1
                self.column += 1
                continue
            
            # Identifiers and keywords
            if current_char.isalpha() or current_char == '_':
                identifier = self._read_identifier()
                token_type = self.KEYWORDS.get(identifier, TokenType.IDENTIFIER)
                self.tokens.append(self._create_token(token_type, identifier, start_pos))
                continue
            
            # Numbers
            if current_char.isdigit():
                number = self._read_number()
                self.tokens.append(self._create_token(TokenType.NUMBER, number, start_pos))
                continue
            
            # Strings
            if current_char in '"\'':
                string_value = self._read_string(current_char)
                self.tokens.append(self._create_token(TokenType.STRING, string_value, start_pos))
                continue
            
            # Unknown character
            self.error(f"Unexpected character: '{current_char}'")
            self.position += 1
            self.column += 1
        
        return self.tokens
    
    def get_tokens_with_types(self) -> List[Tuple[str, str, SourceLocation]]:
        """Get tokens as tuples for compatibility with existing code"""
        result = []
        for token in self.tokens:
            result.append((token.type.value, token.value, token.location))
        return result


def tokenize_source(source: str, filename: str = "<source>") -> List[Token]:
    """Tokenize Noodle source code"""
    lexer = NoodleLexer(source, filename)
    return lexer.tokenize()


def tokenize_file(filepath: str) -> List[Token]:
    """Tokenize a Noodle file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            source = f.read()
        return tokenize_source(source, filepath)
    except Exception as e:
        raise Exception(f"Failed to read file {filepath}: {str(e)}")


if __name__ == '__main__':
    import sys
    import json
    
    if len(sys.argv) < 2:
        print("Usage: python lexer.py <file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    
    try:
        tokens = tokenize_file(filepath)
        
        # Convert to JSON-serializable format
        token_data = []
        for token in tokens:
            token_data.append({
                'type': token.type.value,
                'value': token.value,
                'location': {
                    'file': token.location.file,
                    'line': token.location.line,
                    'column': token.location.column,
                    'offset': token.location.offset
                }
            })
        
        print(json.dumps(token_data, indent=2))
        
        # Print errors if any
        lexer = NoodleLexer(open(filepath, 'r').read(), filepath)
        lexer.tokenize()
        if lexer.errors:
            print("\nErrors:")
            for error in lexer.errors:
                print(f"{error.location}: {error.message}")
    
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

