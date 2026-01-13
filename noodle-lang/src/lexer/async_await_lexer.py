"""
Lexer::Async Await Lexer - async_await_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Async/Await Syntax Lexer for Noodle Language
Implements lexical analysis for async/await syntax including async functions, await expressions, and async iterators.
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

class AsyncAwaitLexer:
    """
    Lexer for async/await syntax in Noodle language.
    
    Supports:
    - Async functions: async function name() -> Type
    - Await expressions: result = await async_call()
    - Async iterators: async for item in async_generator()
    - Async context management
    """
    
    # Token types for async/await syntax
    ASYNC = 68        # async keyword
    AWAIT = 69        # await keyword
    ASYNC_FOR = 70   # async for loop
    ASYNC_ITERATOR = 71  # async iterator keyword
    IDENTIFIER = 66    # identifier token (reused from generic lexer)
    
    def __init__(self):
        self.tokens: List[Token] = []
        self.current_line = 1
        self.current_column = 1
        
        # Regex patterns for async/await syntax
        self.patterns = {
            'async_function': r'async\s+function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)\s*(?:->\s*[^{]*)?',
            'await_expression': r'await\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)',
            'async_for': r'async\s+for\s+([A-Za-z_][A-Za-z0-9_]*)\s+in\s+([A-Za-z_][A-Za-z0-9_]*)',
            'async_context': r'async\s+(?:with|using)\s+[^;]+',
        }
        
        # Compile regex patterns for performance
        self.compiled_patterns = {
            name: re.compile(pattern) 
            for name, pattern in self.patterns.items()
        }
    
    def tokenize(self, input_text: str) -> List[Token]:
        """
        Tokenize input text containing async/await syntax.
        
        Args:
            input_text: Source code text to tokenize
            
        Returns:
            List of tokens representing async/await constructs
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
            
            # Check for async keyword
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
            
            # Check for await keyword
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
            
            # Check for identifiers (function names, variable names)
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
            
            # Move to next character
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
            before_pos = pos - 1 if pos > 0 else 0
            after_pos = pos + len(keyword) if pos + len(keyword) < len(input_text) else len(input_text) - 1
            
            # Check characters before and after to ensure it's a separate word
            before_char = input_text[before_pos] if before_pos >= 0 else ' '
            after_char = input_text[after_pos] if after_pos < len(input_text) else ' '
            
            return (not before_char.isalnum() and before_char != '_') and (not after_char.isalnum() and after_char != '_')
        
        return False
    
    def _read_identifier(self, input_text: str, start_pos: int) -> str:
        """Read a complete identifier from input text"""
        i = start_pos
        while i < len(input_text) and (input_text[i].isalnum() or input_text[i] == '_'):
            i += 1
        return input_text[start_pos:i]
    
    def analyze_async_constructs(self, input_text: str) -> Dict[str, List[str]]:
        """
        Analyze input text for async/await constructs.
        
        Returns:
            Dictionary with lists of found async constructs
        """
        results = {
            'async_functions': [],
            'await_expressions': [],
            'async_for_loops': [],
            'async_contexts': []
        }
        
        # Find all matches for each pattern
        for pattern_name, compiled_pattern in self.compiled_patterns.items():
            matches = compiled_pattern.findall(input_text)
            
            if pattern_name == 'async_function':
                results['async_functions'] = matches
            elif pattern_name == 'await_expression':
                results['await_expressions'] = matches
            elif pattern_name == 'async_for':
                results['async_for_loops'] = matches
            elif pattern_name == 'async_context':
                results['async_contexts'] = matches
        
        return results
    
    def validate_async_syntax(self, tokens: List[Token]) -> List[str]:
        """
        Validate async/await syntax in token list.
        
        Args:
            tokens: List of tokens to validate
            
        Returns:
            List of validation error messages
        """
        errors = []
        i = 0
        
        while i < len(tokens):
            token = tokens[i]
            
            # Check for async without function
            if token.type == self.ASYNC:
                if i + 1 >= len(tokens) or tokens[i + 1].type != self.IDENTIFIER:
                    errors.append(f"Invalid async usage at line {token.line}, column {token.column}")
            
            # Check for await without expression
            if token.type == self.AWAIT:
                if i + 1 >= len(tokens) or tokens[i + 1].type != self.IDENTIFIER:
                    errors.append(f"Invalid await usage at line {token.line}, column {token.column}")
            
            # Check for async in for loop
            if (i + 1 < len(tokens) and 
                tokens[i].type == self.ASYNC and 
                tokens[i + 1].type == self.IDENTIFIER and
                tokens[i + 1].value == 'for'):
                
                # Should have loop variable and iterator
                if (i + 2 >= len(tokens) or tokens[i + 2].type != self.IDENTIFIER or
                    i + 3 >= len(tokens) or tokens[i + 3].value != 'in'):
                    errors.append(f"Invalid async for loop at line {token.line}, column {token.column}")
            
            i += 1
        
        return errors
    
    def get_async_functions(self, tokens: List[Token]) -> List[Dict[str, str]]:
        """
        Extract async functions from token list.
        
        Returns:
            List of dictionaries with async function info
        """
        async_functions = []
        i = 0
        
        while i < len(tokens):
            if (i + 2 < len(tokens) and 
                tokens[i].type == self.ASYNC and
                tokens[i + 1].type == self.IDENTIFIER and
                tokens[i + 1].value == 'function'):
                
                # Extract function name
                if (i + 2 < len(tokens) and tokens[i + 2].type == self.IDENTIFIER):
                    function_name = tokens[i + 2].value
                    
                    # Look for return type
                    return_type = None
                    j = i + 3
                    while j < len(tokens) and tokens[j].type != self.IDENTIFIER:
                        if tokens[j].value == '->':
                            if j + 1 < len(tokens) and tokens[j + 1].type == self.IDENTIFIER:
                                return_type = tokens[j + 1].value
                            break
                        j += 1
                    
                    async_functions.append({
                        'name': function_name,
                        'return_type': return_type
                    })
            
            i += 1
        
        return async_functions

# Utility functions for working with async/await tokens
def create_async_token(token_type: int, value: str, line: int = 1, column: int = 1) -> Token:
    """Create an async/await token with default position"""
    return Token(type=token_type, value=value, line=line, column=column)

def is_async_token(token: Token) -> bool:
    """Check if token is related to async/await syntax"""
    return token.type in [
        AsyncAwaitLexer.ASYNC,
        AsyncAwaitLexer.AWAIT,
        AsyncAwaitLexer.ASYNC_FOR,
        AsyncAwaitLexer.ASYNC_ITERATOR
    ]

def format_async_function_signature(async_func: Dict[str, str]) -> str:
    """Format async function signature as string"""
    if async_func['return_type']:
        return f"async function {async_func['name']}() -> {async_func['return_type']}"
    else:
        return f"async function {async_func['name']}()"

