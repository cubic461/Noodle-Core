"""
Lexer::Io Abstractions Lexer - io_abstractions_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Enhanced I/O Abstractions Lexer for Noodle Language
Implements lexical analysis for modern I/O abstractions including file streams, network operations, and async I/O patterns.
"""

from typing import List, Dict, Optional, Tuple
import re
from dataclasses import dataclass

@dataclass
class Token:
    """Represents a lexical token in the Noodle language"""
    type: int
    value: str
    line: int
    column: int

class IOAbstractionsLexer:
    """
    Lexer for enhanced I/O abstractions in Noodle language.
    
    Supports:
    - File I/O operations: open, read, write, close
    - Network I/O: HTTP requests, WebSocket connections
    - Stream processing: async streams, buffered I/O
    - Resource management: with statements, context managers
    - Error handling: try-catch for I/O operations
    """
    
    # Token types for I/O abstractions
    FILE = 90         # File keyword
    OPEN = 91         # open keyword
    READ = 92         # read keyword
    WRITE = 93        # write keyword
    CLOSE = 94        # close keyword
    HTTP = 95         # HTTP keyword
    REQUEST = 96      # request keyword
    RESPONSE = 97      # response keyword
    STREAM = 98       # stream keyword
    ASYNC = 99       # async keyword
    AWAIT = 100      # await keyword
    WITH = 101        # with keyword
    TRY = 102         # try keyword
    CATCH = 103       # catch keyword
    FINALLY = 104     # finally keyword
    BUFFER = 105      # buffer keyword
    FLUSH = 106       # flush keyword
    SOCKET = 107      # socket keyword
    CONNECT = 108     # connect keyword
    LISTEN = 109      # listen keyword
    ACCEPT = 110      # accept keyword
    SEND = 111        # send keyword
    RECEIVE = 112     # receive keyword
    IDENTIFIER = 113   # Identifier token
    STRING_LITERAL = 114 # String literal token
    NUMBER_LITERAL = 115 # Number literal token
    COLON = 116       # : colon
    SEMICOLON = 117    # ; semicolon
    COMMA = 118       # , comma
    DOT = 119         # . dot
    LEFT_PAREN = 120   # ( left parenthesis
    RIGHT_PAREN = 121  # ) right parenthesis
    LEFT_BRACE = 122   # { left brace
    RIGHT_BRACE = 123  # } right brace
    LEFT_BRACKET = 124  # [ left bracket
    RIGHT_BRACKET = 125 # ] right bracket
    ARROW = 126       # -> arrow
    EQUALS = 127      # = equals
    PLUS = 128        # + plus
    MINUS = 129       # - minus
    ASTERISK = 130    # * asterisk
    SLASH = 131       # / slash
    LESS_THAN = 132    # < less than
    GREATER_THAN = 133  # > greater than
    EXCLAMATION = 134  # ! exclamation
    QUESTION = 135     # ? question mark
    AMPERSAND = 136    # & ampersand
    PIPE = 137        # | pipe
    PERCENT = 138      # % percent
    TILDE = 139       # ~ tilde
    CARET = 140       # ^ caret
    AT = 141          # @ at symbol
    HASH = 142        # # hash
    DOLLAR = 143      # $ dollar
    UNDERSCORE = 144   # _ underscore
    NEWLINE = 145      # newline
    WHITESPACE = 146   # whitespace
    UNKNOWN = 147      # unknown token
    
    def __init__(self):
        self.tokens: List[Token] = []
        self.current_line = 1
        self.current_column = 1
        
        # Regex patterns for I/O abstractions
        self.patterns = {
            'file_operation': r'(?:open|read|write|close|flush)\s*\([^)]*\)',
            'http_operation': r'(?:get|post|put|delete|patch)\s*\([^)]*\)',
            'stream_operation': r'(?:async\s+)?for\s+[A-Za-z_][A-Za-z0-9_]*\s+in\s+[A-Za-z_][A-Za-z0-9_]*\s*\{[^}]*\}',
            'socket_operation': r'(?:connect|listen|accept|send|receive)\s*\([^)]*\)',
            'resource_management': r'with\s+[A-Za-z_][A-Za-z0-9_]*\s+as\s+[A-Za-z_][A-Za-z0-9_]*\s*:\s*\{[^}]*\}',
            'error_handling': r'try\s*\{[^}]*\}\s*(?:catch\s*\([^)]*\)\s*\{[^}]*\})?\s*(?:finally\s*\{[^}]*\})?',
        }
        
        # Compile regex patterns for performance
        self.compiled_patterns = {
            name: re.compile(pattern) 
            for name, pattern in self.patterns.items()
        }
    
    def tokenize(self, input_text: str) -> List[Token]:
        """
        Tokenize input text containing I/O abstractions syntax.
        
        Args:
            input_text: Source code text to tokenize
            
        Returns:
            List of tokens representing I/O constructs
        """
        self.tokens = []
        self.current_line = 1
        self.current_column = 1
        
        # Process the input text
        i = 0
        while i < len(input_text):
            char = input_text[i]
            
            # Skip whitespace and track position
            if char.isspace():
                if char == '\n':
                    self.current_line += 1
                    self.current_column = 1
                else:
                    self.current_column += 1
                i += 1
                continue
            
            # Check for I/O keywords
            if self._is_keyword_at_position(input_text, i, 'File'):
                self.tokens.append(Token(
                    type=self.FILE,
                    value='File',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('File')
                i += len('File')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'open'):
                self.tokens.append(Token(
                    type=self.OPEN,
                    value='open',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('open')
                i += len('open')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'read'):
                self.tokens.append(Token(
                    type=self.READ,
                    value='read',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('read')
                i += len('read')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'write'):
                self.tokens.append(Token(
                    type=self.WRITE,
                    value='write',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('write')
                i += len('write')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'close'):
                self.tokens.append(Token(
                    type=self.CLOSE,
                    value='close',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('close')
                i += len('close')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'HTTP'):
                self.tokens.append(Token(
                    type=self.HTTP,
                    value='HTTP',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('HTTP')
                i += len('HTTP')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'request'):
                self.tokens.append(Token(
                    type=self.REQUEST,
                    value='request',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('request')
                i += len('request')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'response'):
                self.tokens.append(Token(
                    type=self.RESPONSE,
                    value='response',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('response')
                i += len('response')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'stream'):
                self.tokens.append(Token(
                    type=self.STREAM,
                    value='stream',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('stream')
                i += len('stream')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'async'):
                self.tokens.append(Token(
                    type=self.ASYNC,
                    value='async',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('async')
                i += len('async')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'await'):
                self.tokens.append(Token(
                    type=self.AWAIT,
                    value='await',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('await')
                i += len('await')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'with'):
                self.tokens.append(Token(
                    type=self.WITH,
                    value='with',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('with')
                i += len('with')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'try'):
                self.tokens.append(Token(
                    type=self.TRY,
                    value='try',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('try')
                i += len('try')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'catch'):
                self.tokens.append(Token(
                    type=self.CATCH,
                    value='catch',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('catch')
                i += len('catch')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'finally'):
                self.tokens.append(Token(
                    type=self.FINALLY,
                    value='finally',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('finally')
                i += len('finally')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'buffer'):
                self.tokens.append(Token(
                    type=self.BUFFER,
                    value='buffer',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('buffer')
                i += len('buffer')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'flush'):
                self.tokens.append(Token(
                    type=self.FLUSH,
                    value='flush',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('flush')
                i += len('flush')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'socket'):
                self.tokens.append(Token(
                    type=self.SOCKET,
                    value='socket',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('socket')
                i += len('socket')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'connect'):
                self.tokens.append(Token(
                    type=self.CONNECT,
                    value='connect',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('connect')
                i += len('connect')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'listen'):
                self.tokens.append(Token(
                    type=self.LISTEN,
                    value='listen',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('listen')
                i += len('listen')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'accept'):
                self.tokens.append(Token(
                    type=self.ACCEPT,
                    value='accept',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('accept')
                i += len('accept')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'send'):
                self.tokens.append(Token(
                    type=self.SEND,
                    value='send',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('send')
                i += len('send')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'receive'):
                self.tokens.append(Token(
                    type=self.RECEIVE,
                    value='receive',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('receive')
                i += len('receive')
                continue
            
            # Check for multi-character operators
            if i + 1 < len(input_text):
                two_char = input_text[i:i+2]
                if two_char == '->':
                    self.tokens.append(Token(
                        type=self.ARROW,
                        value=two_char,
                        line=self.current_line,
                        column=self.current_column
                    ))
                    self.current_column += 2
                    i += 2
                    continue
            
            # Check for single-character tokens
            single_char_tokens = {
                ':': self.COLON,
                ';': self.SEMICOLON,
                ',': self.COMMA,
                '.': self.DOT,
                '(': self.LEFT_PAREN,
                ')': self.RIGHT_PAREN,
                '{': self.LEFT_BRACE,
                '}': self.RIGHT_BRACE,
                '[': self.LEFT_BRACKET,
                ']': self.RIGHT_BRACKET,
                '=': self.EQUALS,
                '+': self.PLUS,
                '-': self.MINUS,
                '*': self.ASTERISK,
                '/': self.SLASH,
                '<': self.LESS_THAN,
                '>': self.GREATER_THAN,
                '!': self.EXCLAMATION,
                '?': self.QUESTION,
                '&': self.AMPERSAND,
                '|': self.PIPE,
                '%': self.PERCENT,
                '~': self.TILDE,
                '^': self.CARET,
                '@': self.AT,
                '#': self.HASH,
                '$': self.DOLLAR,
                '_': self.UNDERSCORE,
            }
            
            if char in single_char_tokens:
                self.tokens.append(Token(
                    type=single_char_tokens[char],
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            # Check for string literals
            if char == '"' or char == "'":
                string_literal = self._read_string_literal(input_text, i)
                self.tokens.append(Token(
                    type=self.STRING_LITERAL,
                    value=string_literal,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len(string_literal)
                i += len(string_literal)
                continue
            
            # Check for number literals
            if char.isdigit() or (char == '.' and i + 1 < len(input_text) and input_text[i + 1].isdigit()):
                number_literal = self._read_number_literal(input_text, i)
                self.tokens.append(Token(
                    type=self.NUMBER_LITERAL,
                    value=number_literal,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len(number_literal)
                i += len(number_literal)
                continue
            
            # Check for identifiers
            if char.isalpha() or char == '_':
                identifier = self._read_identifier(input_text, i)
                self.tokens.append(Token(
                    type=self.IDENTIFIER,
                    value=identifier,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len(identifier)
                i += len(identifier)
                continue
            
            # Unknown character
            self.tokens.append(Token(
                type=self.UNKNOWN,
                value=char,
                line=self.current_line,
                column=self.current_column
            ))
            self.current_column += 1
            i += 1
        
        return self.tokens
    
    def _is_keyword_at_position(self, input_text: str, pos: int, keyword: str) -> bool:
        """Check if keyword exists at current position"""
        if pos + len(keyword) > len(input_text):
            return False
        
        # Check if keyword matches
        if input_text[pos:pos + len(keyword)] == keyword:
            # Check if it's a complete word (not part of larger identifier)
            before_pos = pos - 1
            after_pos = pos + len(keyword)
            
            # Check characters before and after to ensure it's a separate word
            before_char = input_text[before_pos] if before_pos >= 0 else ' '
            after_char = input_text[after_pos] if after_pos < len(input_text) else ' '
            
            return (not before_char.isalnum() and before_char != '_') and (not after_char.isalnum() and after_char != '_')
    
    def _read_string_literal(self, input_text: str, start_pos: int) -> str:
        """Read a string literal"""
        quote_char = input_text[start_pos]
        i = start_pos + 1
        result = quote_char
        
        while i < len(input_text) and input_text[i] != quote_char:
            if input_text[i] == '\\':
                # Handle escape sequences
                if i + 1 < len(input_text):
                    result += input_text[i:i+2]
                    i += 2
                else:
                    result += input_text[i]
                    i += 1
            else:
                result += input_text[i]
                i += 1
        
        if i < len(input_text):
            result += input_text[i]  # Closing quote
            i += 1
        
        return result
    
    def _read_number_literal(self, input_text: str, start_pos: int) -> str:
        """Read a number literal"""
        i = start_pos
        
        # Handle optional sign
        if input_text[i] == '-':
            i += 1
        
        # Handle integer part
        while i < len(input_text) and input_text[i].isdigit():
            i += 1
        
        # Handle fractional part
        if i < len(input_text) and input_text[i] == '.':
            i += 1
            while i < len(input_text) and input_text[i].isdigit():
                i += 1
        
        # Handle exponent part
        if i < len(input_text) and (input_text[i] == 'e' or input_text[i] == 'E'):
            i += 1
            if i < len(input_text) and (input_text[i] == '+' or input_text[i] == '-'):
                i += 1
            while i < len(input_text) and input_text[i].isdigit():
                i += 1
        
        return input_text[start_pos:i]
    
    def _read_identifier(self, input_text: str, start_pos: int) -> str:
        """Read an identifier"""
        i = start_pos
        while i < len(input_text) and (input_text[i].isalnum() or input_text[i] == '_'):
            i += 1
        return input_text[start_pos:i]
    
    def analyze_io_constructs(self, input_text: str) -> Dict[str, List[str]]:
        """
        Analyze input text for I/O constructs.
        
        Returns:
            Dictionary with lists of found I/O constructs
        """
        results = {
            'file_operations': [],
            'http_operations': [],
            'stream_operations': [],
            'socket_operations': [],
            'resource_management': [],
            'error_handling': []
        }
        
        # Find all matches for each pattern
        for pattern_name, compiled_pattern in self.compiled_patterns.items():
            matches = compiled_pattern.findall(input_text)
            
            if pattern_name == 'file_operation':
                results['file_operations'] = matches
            elif pattern_name == 'http_operation':
                results['http_operations'] = matches
            elif pattern_name == 'stream_operation':
                results['stream_operations'] = matches
            elif pattern_name == 'socket_operation':
                results['socket_operations'] = matches
            elif pattern_name == 'resource_management':
                results['resource_management'] = matches
            elif pattern_name == 'error_handling':
                results['error_handling'] = matches
        
        return results
    
    def validate_io_syntax(self, tokens: List[Token]) -> List[str]:
        """
        Validate I/O syntax in token list.
        
        Args:
            tokens: List of tokens to validate
            
        Returns:
            List of validation error messages
        """
        errors = []
        i = 0
        
        while i < len(tokens):
            token = tokens[i]
            
            # Check for balanced parentheses in function calls
            if token.type in [self.OPEN, self.READ, self.WRITE, self.CLOSE, self.FLUSH, self.CONNECT, self.LISTEN, self.ACCEPT, self.SEND, self.RECEIVE]:
                if i + 1 < len(tokens) and tokens[i + 1].type == self.LEFT_PAREN:
                    paren_count = 1
                    j = i + 2
                    
                    while j < len(tokens) and paren_count > 0:
                        if tokens[j].type == self.LEFT_PAREN:
                            paren_count += 1
                        elif tokens[j].type == self.RIGHT_PAREN:
                            paren_count -= 1
                        j += 1
                    
                    if paren_count > 0:
                        errors.append(f"Unmatched '(' in I/O operation at line {token.line}, column {token.column}")
            
            # Check for with statement structure
            if token.type == self.WITH:
                # Should be followed by identifier and 'as'
                if i + 2 >= len(tokens):
                    errors.append(f"Incomplete 'with' statement at line {token.line}, column {token.column}")
                elif tokens[i + 2].type != self.AS:
                    errors.append(f"Missing 'as' in 'with' statement at line {token.line}, column {token.column}")
            
            # Check for try-catch structure
            if token.type == self.TRY:
                # Should be followed by { and optionally catch/finally
                has_catch = False
                has_finally = False
                
                j = i + 1
                while j < len(tokens):
                    if tokens[j].type == self.CATCH:
                        has_catch = True
                    elif tokens[j].type == self.FINALLY:
                        has_finally = True
                        break
                    j += 1
                
                if not has_catch and not has_finally:
                    errors.append(f"'try' block without 'catch' or 'finally' at line {token.line}, column {token.column}")
            
            i += 1
        
        return errors

# Utility functions for working with I/O tokens
def create_io_token(token_type: int, value: str, line: int = 1, column: int = 1) -> Token:
    """Create an I/O token with default position"""
    return Token(type=token_type, value=value, line=line, column=column)

def is_io_token(token: Token) -> bool:
    """Check if token is related to I/O abstractions"""
    return token.type in [
        IOAbstractionsLexer.FILE,
        IOAbstractionsLexer.OPEN,
        IOAbstractionsLexer.READ,
        IOAbstractionsLexer.WRITE,
        IOAbstractionsLexer.CLOSE,
        IOAbstractionsLexer.HTTP,
        IOAbstractionsLexer.REQUEST,
        IOAbstractionsLexer.RESPONSE,
        IOAbstractionsLexer.STREAM,
        IOAbstractionsLexer.ASYNC,
        IOAbstractionsLexer.AWAIT,
        IOAbstractionsLexer.WITH,
        IOAbstractionsLexer.TRY,
        IOAbstractionsLexer.CATCH,
        IOAbstractionsLexer.FINALLY,
        IOAbstractionsLexer.BUFFER,
        IOAbstractionsLexer.FLUSH,
        IOAbstractionsLexer.SOCKET,
        IOAbstractionsLexer.CONNECT,
        IOAbstractionsLexer.LISTEN,
        IOAbstractionsLexer.ACCEPT,
        IOAbstractionsLexer.SEND,
        IOAbstractionsLexer.RECEIVE,
    ]

def format_file_operation(operation: str, filename: str, mode: str = "read") -> str:
    """Format file operation as string"""
    return f"{operation}({filename}, mode: '{mode}')"

def format_http_operation(method: str, url: str, headers: Dict[str, str] = None) -> str:
    """Format HTTP operation as string"""
    if headers:
        header_str = ", ".join([f"{k}: '{v}'" for k, v in headers.items()])
        return f"HTTP.{method}({url}, headers: {{{header_str}}})"
    return f"HTTP.{method}({url})"

def format_stream_operation(operation: str, source: str, target: str = None) -> str:
    """Format stream operation as string"""
    if target:
        return f"{operation}({source}) -> {target}"
    return f"{operation}({source})"

