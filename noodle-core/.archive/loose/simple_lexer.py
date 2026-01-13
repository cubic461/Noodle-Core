#!/usr/bin/env python3
"""
Noodle Core::Simple Lexer - simple_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple lexer implementation for testing pattern matching
"""

import re
from dataclasses import dataclass
from enum import Enum

class TokenType(Enum):
    EOF = "EOF"
    IDENTIFIER = "IDENTIFIER"
    NUMBER = "NUMBER"
    STRING = "STRING"
    TRUE = "TRUE"
    FALSE = "FALSE"
    NONE = "NONE"
    PLUS = "PLUS"
    MINUS = "MINUS"
    MULTIPLY = "MULTIPLY"
    DIVIDE = "DIVIDE"
    MODULO = "MODULO"
    ASSIGN = "ASSIGN"
    EQ = "EQ"
    NE = "NE"
    LESS_THAN = "LESS_THAN"
    GREATER_THAN = "GREATER_THAN"
    LESS_EQUAL = "LESS_EQUAL"
    GREATER_EQUAL = "GREATER_EQUAL"
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
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
    UNDERSCORE = "UNDERSCORE"
    LT = "LT"
    GT = "GT"
    LE = "LE"
    GE = "GE"
    PIPE = "PIPE"
    AMPERSAND = "AMPERSAND"
    RANGE = "RANGE"

@dataclass
class SourceLocation:
    file: str
    line: int
    column: int
    offset: int

@dataclass
class Token:
    type: TokenType
    value: str
    location: SourceLocation

class SimpleLexer:
    def __init__(self, source: str, filename: str = "<input>"):
        self.source = source
        self.filename = filename
        self.tokens = []
        self.errors = []
        self.position = 0
        self.line = 1
        self.column = 1
        
        # Token specifications
        self.token_specs = [
            # Whitespace and comments
            (r'\s+', None),  # Skip whitespace
            (r'//.*', None),  # Skip single-line comments
            
            # Special single-character tokens (must come before identifier pattern)
            (r'_', TokenType.UNDERSCORE),
            
            # Literals
            (r'\d+\.\d+', TokenType.NUMBER),  # Float
            (r'\d+', TokenType.NUMBER),  # Integer
            (r'"[^"]*"', TokenType.STRING),  # String literal
            (r"'[^']*'", TokenType.STRING),  # String literal with single quotes
            
            # Operators and punctuation (longer patterns first)
            (r'=>', TokenType.ARROW),  # Arrow operator (must come before ASSIGN and GT)
            (r'\.\.', TokenType.RANGE),  # Range operator
            (r'==', TokenType.EQ),
            (r'!=', TokenType.NE),
            (r'<=', TokenType.LESS_EQUAL),
            (r'>=', TokenType.GREATER_EQUAL),
            (r'&&', TokenType.AND),
            (r'\|\|', TokenType.OR),
            (r'\+', TokenType.PLUS),
            (r'-', TokenType.MINUS),
            (r'\*', TokenType.MULTIPLY),
            (r'/', TokenType.DIVIDE),
            (r'%', TokenType.MODULO),
            (r'=', TokenType.ASSIGN),
            (r'<', TokenType.LT),
            (r'>', TokenType.GT),
            (r'\|', TokenType.PIPE),
            (r'&', TokenType.AMPERSAND),
            (r'!', TokenType.NOT),
            (r'\(', TokenType.LPAREN),
            (r'\)', TokenType.RPAREN),
            (r'\{', TokenType.LBRACE),
            (r'\}', TokenType.RBRACE),
            (r'\[', TokenType.LBRACKET),
            (r'\]', TokenType.RBRACKET),
            (r',', TokenType.COMMA),
            (r'\.', TokenType.DOT),
            (r':', TokenType.COLON),
            (r';', TokenType.SEMICOLON),
            
            # Keywords and identifiers (updated to not start with underscore)
            (r'[a-zA-Z][a-zA-Z0-9_]*', self._check_keyword),
        ]
        
        # Compile regex patterns
        self.token_regex = []
        for spec in self.token_specs:
            pattern = spec[0]
            token_type = spec[1]
            self.token_regex.append((re.compile(pattern), token_type))
    
    def _check_keyword(self, match):
        """Check if an identifier is a keyword"""
        value = match.group(0)
        keywords = {
            'true': TokenType.TRUE,
            'false': TokenType.FALSE,
            'none': TokenType.NONE,
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
            'and': TokenType.AND,
            'or': TokenType.OR,
            'not': TokenType.NOT,
        }
        
        if value in keywords:
            return keywords[value]
        return TokenType.IDENTIFIER
    
    def tokenize(self):
        """Tokenize the source code"""
        self.position = 0
        self.line = 1
        self.column = 1
        self.tokens = []
        self.errors = []
        
        while self.position < len(self.source):
            matched = False
            
            for regex, token_type in self.token_regex:
                match = regex.match(self.source, self.position)
                if match:
                    value = match.group(0)
                    
                    # Update line and column
                    if '\n' in value:
                        lines = value.split('\n')
                        self.line += len(lines) - 1
                        self.column = len(lines[-1]) + 1
                    else:
                        self.column += len(value)
                    
                    # Handle token type
                    if token_type is None:
                        # Skip whitespace and comments
                        pass
                    elif callable(token_type):
                        # For keyword checking
                        actual_type = token_type(match)
                        if actual_type:
                            location = SourceLocation(self.filename, self.line, self.column - len(value), self.position)
                            self.tokens.append(Token(actual_type, value, location))
                    else:
                        location = SourceLocation(self.filename, self.line, self.column - len(value), self.position)
                        self.tokens.append(Token(token_type, value, location))
                    
                    self.position = match.end()
                    matched = True
                    break
            
            if not matched:
                # Invalid character
                char = self.source[self.position]
                location = SourceLocation(self.filename, self.line, self.column, self.position)
                self.errors.append(f"Invalid character: '{char}' at {location}")
                self.position += 1
                self.column += 1
        
        # Add EOF token
        location = SourceLocation(self.filename, self.line, self.column, self.position)
        self.tokens.append(Token(TokenType.EOF, '', location))
        
        return self.tokens

