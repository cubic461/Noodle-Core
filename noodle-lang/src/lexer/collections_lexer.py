"""
Lexer::Collections Lexer - collections_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Modern Collections Lexer for Noodle Language
Implements lexical analysis for modern collection types including generic collections, functional programming helpers, and stream processing.
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

class CollectionsLexer:
    """
    Lexer for modern collection types in Noodle language.
    
    Supports:
    - Generic collections: List<T>, Map<K, V>, Set<T>
    - Functional programming helpers: map, filter, reduce, fold
    - Stream processing: Stream<T> iterators and processors
    - Enhanced collection operations: union, intersection, difference
    """
    
    # Token types for collections
    LIST = 72         # List keyword
    MAP = 73          # Map keyword
    SET = 74          # Set keyword
    STREAM = 75        # Stream keyword
    GENERIC_LT = 76    # < for generic type
    GENERIC_GT = 77    # > for generic type
    LT = 78           # < angle bracket (for stream operations)
    GT = 79           # > angle bracket (for stream operations)
    PIPE = 80          # | pipe operator (functional programming)
    FUNCTIONAL = 81    # Functional programming helpers
    IDENTIFIER = 66    # Identifier token
    COMMA = 67         # Comma token
    
    def __init__(self):
        self.tokens: List[Token] = []
        self.current_line = 1
        self.current_column = 1
        
        # Regex patterns for collections syntax
        self.patterns = {
            'generic_collection': r'<[A-Za-z_][A-Za-z0-9_]*(?:\s*:\s*[A-Za-z_][A-Za-z0-9_]*)?(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*\s*>',
            'functional_call': r'[A-Za-z_][A-Za-z0-9_]*\s*\(\s*[^)]*\)\s*\.\s*[A-Za-z_][A-Za-z0-9_]*\s*\([^)]*\)',
            'stream_operation': r'(?:async\s+)?for\s+[A-Za-z_][A-Za-z0-9_]*\s+in\s+[A-Za-z_][A-Za-z0-9_]*\s*stream<[A-Za-z_][A-Za-z0-9_]*>\s*\{[^}]*\}',
            'collection_literal': r'\[[^\]]*\](?:\s*,\s*[^\]]+)*\]',
            'map_literal': r'\{[^}]*\}',
        }
        
        # Compile regex patterns for performance
        self.compiled_patterns = {
            name: re.compile(pattern) 
            for name, pattern in self.patterns.items()
        }
    
    def tokenize(self, input_text: str) -> List[Token]:
        """
        Tokenize input text containing collections syntax.
        
        Args:
            input_text: Source code text to tokenize
            
        Returns:
            List of tokens representing collection constructs
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
            
            # Check for collection keywords
            if self._is_keyword_at_position(input_text, i, 'List'):
                self.tokens.append(Token(
                    type=self.LIST,
                    value='List',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('List')
                i += len('List')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'Map'):
                self.tokens.append(Token(
                    type=self.MAP,
                    value='Map',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('Map')
                i += len('Map')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'Set'):
                self.tokens.append(Token(
                    type=self.SET,
                    value='Set',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('Set')
                i += len('Set')
                continue
            
            if self._is_keyword_at_position(input_text, i, 'Stream'):
                self.tokens.append(Token(
                    type=self.STREAM,
                    value='Stream',
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len('Stream')
                i += len('Stream')
                continue
            
            # Check for generic type parameters
            if char == '<':
                self.tokens.append(Token(
                    type=self.GENERIC_LT,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            if char == '>':
                self.tokens.append(Token(
                    type=self.GENERIC_GT,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            # Check for functional programming operators
            if char == '|':
                self.tokens.append(Token(
                    type=self.PIPE,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            # Check for angle brackets (stream operations)
            if char == '<':
                self.tokens.append(Token(
                    type=self.LT,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            if char == '>':
                self.tokens.append(Token(
                    type=self.GT,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            # Check for functional programming keywords
            if self._is_keyword_at_position(input_text, i, 'map') or self._is_keyword_at_position(input_text, i, 'filter') or self._is_keyword_at_position(input_text, i, 'reduce') or self._is_keyword_at_position(input_text, i, 'fold'):
                self.tokens.append(Token(
                    type=self.FUNCTIONAL,
                    value=self._read_functional_keyword(input_text, i),
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += len(self._read_functional_keyword(input_text, i))
                i += len(self._read_functional_keyword(input_text, i))
                continue
            
            # Check for collection literals
            if char == '[':
                # Check if it's a collection literal
                if self._is_collection_literal_at_position(input_text, i):
                    end_pos = self._find_matching_bracket(input_text, i, '[', ']')
                    if end_pos > i:
                        literal_content = input_text[i + 1:end_pos]
                        self.tokens.append(Token(
                            type=self.IDENTIFIER,
                            value=f'[{literal_content}]',
                            line=self.current_line,
                            column=self.current_column
                        ))
                        self.current_column += len(literal_content) + 2
                        i = end_pos + 1
                        continue
            
            # Check for map literals
            if char == '{':
                # Check if it's a map literal
                if self._is_map_literal_at_position(input_text, i):
                    end_pos = self._find_matching_bracket(input_text, i, '{', '}')
                    if end_pos > i:
                        literal_content = input_text[i + 1:end_pos]
                        self.tokens.append(Token(
                            type=self.IDENTIFIER,
                            value=f'{{{literal_content}}}',
                            line=self.current_line,
                            column=self.current_column
                        ))
                        self.current_column += len(literal_content) + 2
                        i = end_pos + 1
                        continue
            
            # Check for identifiers (type names, variable names)
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
            before_pos = pos - 1
            after_pos = pos + len(keyword)
            
            # Check characters before and after to ensure it's a separate word
            before_char = input_text[before_pos] if before_pos >= 0 else ' '
            after_char = input_text[after_pos] if after_pos < len(input_text) else ' '
            
            return (not before_char.isalnum() and before_char != '_') and (not after_char.isalnum() and after_char != '_')
    
    def _read_functional_keyword(self, input_text: str, start_pos: int) -> str:
        """Read a functional programming keyword"""
        i = start_pos
        while i < len(input_text) and (input_text[i].isalpha() or input_text[i] == '_'):
            i += 1
        return input_text[start_pos:i]
    
    def _read_identifier(self, input_text: str, start_pos: int) -> str:
        """Read an identifier"""
        i = start_pos
        while i < len(input_text) and (input_text[i].isalnum() or input_text[i] == '_'):
            i += 1
        return input_text[start_pos:i]
    
    def _is_collection_literal_at_position(self, input_text: str, pos: int) -> bool:
        """Check if position starts a collection literal"""
        return pos < len(input_text) and input_text[pos] == '['
    
    def _is_map_literal_at_position(self, input_text: str, pos: int) -> bool:
        """Check if position starts a map literal"""
        return pos < len(input_text) and input_text[pos] == '{'
    
    def _find_matching_bracket(self, input_text: str, start_pos: int, open_bracket: str, close_bracket: str) -> int:
        """Find the position of the matching closing bracket"""
        depth = 1
        i = start_pos + 1
        
        while i < len(input_text) and depth > 0:
            if input_text[i] == open_bracket:
                depth += 1
            elif input_text[i] == close_bracket:
                depth -= 1
            i += 1
        
        return i - 1 if depth == 0 else len(input_text) - 1
    
    def analyze_collections_constructs(self, input_text: str) -> Dict[str, List[str]]:
        """
        Analyze input text for collections constructs.
        
        Returns:
            Dictionary with lists of found collections constructs
        """
        results = {
            'generic_collections': [],
            'functional_calls': [],
            'stream_operations': [],
            'collection_literals': [],
            'map_literals': []
        }
        
        # Find all matches for each pattern
        for pattern_name, compiled_pattern in self.compiled_patterns.items():
            matches = compiled_pattern.findall(input_text)
            
            if pattern_name == 'generic_collection':
                results['generic_collections'] = matches
            elif pattern_name == 'functional_call':
                results['functional_calls'] = matches
            elif pattern_name == 'stream_operation':
                results['stream_operations'] = matches
            elif pattern_name == 'collection_literal':
                results['collection_literals'] = matches
            elif pattern_name == 'map_literal':
                results['map_literals'] = matches
        
        return results
    
    def validate_collections_syntax(self, tokens: List[Token]) -> List[str]:
        """
        Validate collections syntax in token list.
        
        Args:
            tokens: List of tokens to validate
            
        Returns:
            List of validation error messages
        """
        errors = []
        i = 0
        
        while i < len(tokens):
            token = tokens[i]
            
            # Check for balanced angle brackets in generic types
            if token.type == self.GENERIC_LT:
                bracket_count = 1
                j = i + 1
                
                while j < len(tokens) and bracket_count > 0:
                    if tokens[j].type == self.GENERIC_LT:
                        bracket_count += 1
                    elif tokens[j].type == self.GENERIC_GT:
                        bracket_count -= 1
                    j += 1
                
                if bracket_count > 0:
                    errors.append(f"Unmatched '<' in generic type at line {token.line}, column {token.column}")
            
            # Check for balanced brackets in stream operations
            if token.type == self.LT:
                bracket_count = 1
                j = i + 1
                
                while j < len(tokens) and bracket_count > 0:
                    if tokens[j].type == self.LT:
                        bracket_count += 1
                    elif tokens[j].type == self.GT:
                        bracket_count -= 1
                    j += 1
                
                if bracket_count > 0:
                    errors.append(f"Unmatched '<' in stream operation at line {token.line}, column {token.column}")
            
            i += 1
        
        return errors
    
    def get_generic_collections(self, tokens: List[Token]) -> List[Dict[str, str]]:
        """
        Extract generic collection type parameters from token list.
        
        Returns:
            List of dictionaries with collection type info
        """
        collections = []
        i = 0
        
        while i < len(tokens):
            if tokens[i].type == self.GENERIC_LT:
                # Extract collection type
                j = i + 1
                if j < len(tokens) and tokens[j].type == self.IDENTIFIER:
                    collection_type = tokens[j].value
                    
                    # Look for generic parameters
                    generic_params = []
                    k = j + 1
                    
                    while k < len(tokens) and tokens[k].type != self.GENERIC_GT:
                        if tokens[k].type == self.IDENTIFIER:
                            generic_params.append(tokens[k].value)
                        elif tokens[k].value == ',':
                            # Skip comma
                            pass
                        k += 1
                    
                    if tokens[k].type == self.GENERIC_GT:
                        collections.append({
                            'type': collection_type,
                            'parameters': generic_params
                        })
                        i = k + 1
            
            elif tokens[i].type != self.GENERIC_LT:
                i += 1
        
        return collections

# Utility functions for working with collections tokens
def create_collections_token(token_type: int, value: str, line: int = 1, column: int = 1) -> Token:
    """Create a collections token with default position"""
    return Token(type=token_type, value=value, line=line, column=column)

def is_collections_token(token: Token) -> bool:
    """Check if token is related to collections syntax"""
    return token.type in [
        CollectionsLexer.LIST,
        CollectionsLexer.MAP,
        CollectionsLexer.SET,
        CollectionsLexer.STREAM,
        CollectionsLexer.GENERIC_LT,
        CollectionsLexer.GENERIC_GT,
        CollectionsLexer.LT,
        CollectionsLexer.GT,
        CollectionsLexer.PIPE,
        CollectionsLexer.FUNCTIONAL,
        CollectionsLexer.IDENTIFIER
    ]

def format_generic_type(collection_type: str, parameters: List[str]) -> str:
    """Format generic collection type as string"""
    if not parameters:
        return f"{collection_type}"
    
    formatted_params = []
    for param in parameters:
        formatted_params.append(param)
    
    return f"{collection_type}<{', '.join(formatted_params)}>"

def format_functional_call(function_name: str, args: List[str]) -> str:
    """Format functional programming call as string"""
    return f"{function_name}({', '.join(args)})"

def format_stream_operation(operation: str, stream_type: str, item_var: str) -> str:
    """Format stream operation as string"""
    return f"{operation} {item_var} in stream<{stream_type}>"

