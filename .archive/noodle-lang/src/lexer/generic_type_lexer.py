"""
Lexer::Generic Type Lexer - generic_type_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Generic Type Parameters Lexer for Noodle Language
Implements lexical analysis for generic type syntax including type parameters, constraints, and inference.
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

class GenericTypeLexer:
    """
    Lexer for generic type parameters in Noodle language.
    
    Supports:
    - Type parameters: <T, U, V>
    - Type constraints: T: Numeric
    - Generic functions: function<T>(param: T)
    - Generic classes: class Container<T>
    - Type inference: var x = identity(42)
    """
    
    # Token types for generic type parameters
    LT = 62          # < angle bracket
    GT = 63          # > angle bracket
    COLON = 64       # : type constraint
    COMMA = 65       # , parameter separator
    IDENTIFIER = 66  # type parameter name
    GENERIC_KEYWORD = 67  # generic keyword markers
    
    def __init__(self):
        self.tokens: List[Token] = []
        self.current_line = 1
        self.current_column = 1
        
        # Regex patterns for generic type syntax
        self.patterns = {
            'type_param': r'<[A-Za-z_][A-Za-z0-9_]*(?:\s*:\s*[A-Za-z_][A-Za-z0-9_]*)?(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*:\s*[A-Za-z_][A-Za-z0-9_]*)?)*\s*>',
            'generic_function': r'function\s*<[^>]*>\s*\([^)]*\)',
            'generic_class': r'class\s+<[^>]*>',
            'type_constraint': r'[A-Za-z_][A-Za-z0-9_]*\s*:\s*[A-Za-z_][A-Za-z0-9_]*',
            'type_inference': r'var\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*[^;]+',
        }
        
        # Compile regex patterns for performance
        self.compiled_patterns = {
            name: re.compile(pattern) 
            for name, pattern in self.patterns.items()
        }
    
    def tokenize(self, input_text: str) -> List[Token]:
        """
        Tokenize input text containing generic type syntax.
        
        Args:
            input_text: Source code text to tokenize
            
        Returns:
            List of tokens representing generic type constructs
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
            
            # Check for generic type parameter list
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
            
            # Check for closing angle bracket
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
            
            # Check for type constraint
            if char == ':':
                self.tokens.append(Token(
                    type=self.COLON,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            # Check for parameter separator
            if char == ',':
                self.tokens.append(Token(
                    type=self.COMMA,
                    value=char,
                    line=self.current_line,
                    column=self.current_column
                ))
                self.current_column += 1
                i += 1
                continue
            
            # Check for identifiers (type names, parameter names)
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
    
    def _tokenize_type_parameter_list(self, input_text: str, start_pos: int) -> None:
        """Tokenize a complete type parameter list like <T, U: Numeric, V>"""
        # Add opening bracket token
        self.tokens.append(Token(
            type=self.LT,
            value='<',
            line=self.current_line,
            column=self.current_column
        ))
        
        # Extract content inside brackets
        end_pos = self._find_matching_bracket(input_text, start_pos, '<', '>')
        content = input_text[start_pos + 1:end_pos]
        
        # Tokenize parameters inside brackets
        self._tokenize_parameter_content(content)
        
        # Add closing bracket token (will be added by main loop)
    
    def _tokenize_parameter_content(self, content: str) -> None:
        """Tokenize the content inside type parameter brackets"""
        # Split by comma and process each parameter
        parameters = [param.strip() for param in content.split(',')]
        
        for param in parameters:
            if not param:
                continue
                
            # Check if parameter has constraint (contains ':')
            if ':' in param:
                type_param, constraint = param.split(':', 1)
                type_param = type_param.strip()
                constraint = constraint.strip()
                
                # Add type parameter identifier
                self.tokens.append(Token(
                    type=self.IDENTIFIER,
                    value=type_param,
                    line=self.current_line,
                    column=self.current_column
                ))
                
                # Add constraint colon
                self.tokens.append(Token(
                    type=self.COLON,
                    value=':',
                    line=self.current_line,
                    column=self.current_column
                ))
                
                # Add constraint type identifier
                self.tokens.append(Token(
                    type=self.IDENTIFIER,
                    value=constraint,
                    line=self.current_line,
                    column=self.current_column
                ))
            else:
                # Simple type parameter without constraint
                self.tokens.append(Token(
                    type=self.IDENTIFIER,
                    value=param.strip(),
                    line=self.current_line,
                    column=self.current_column
                ))
            
            # Add comma separator (except for last parameter)
            if param != parameters[-1]:
                self.tokens.append(Token(
                    type=self.COMMA,
                    value=',',
                    line=self.current_line,
                    column=self.current_column
                ))
    
    def _read_identifier(self, input_text: str, start_pos: int) -> str:
        """Read a complete identifier from input text"""
        i = start_pos
        while i < len(input_text) and (input_text[i].isalnum() or input_text[i] == '_'):
            i += 1
        return input_text[start_pos:i]
    
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
    
    def analyze_generic_constructs(self, input_text: str) -> Dict[str, List[str]]:
        """
        Analyze input text for generic type constructs.
        
        Returns:
            Dictionary with lists of found generic constructs
        """
        results = {
            'type_parameters': [],
            'generic_functions': [],
            'generic_classes': [],
            'type_constraints': [],
            'type_inference': []
        }
        
        # Find all matches for each pattern
        for pattern_name, compiled_pattern in self.compiled_patterns.items():
            matches = compiled_pattern.findall(input_text)
            
            if pattern_name == 'type_param':
                results['type_parameters'] = matches
            elif pattern_name == 'generic_function':
                results['generic_functions'] = matches
            elif pattern_name == 'generic_class':
                results['generic_classes'] = matches
            elif pattern_name == 'type_constraint':
                results['type_constraints'] = matches
            elif pattern_name == 'type_inference':
                results['type_inference'] = matches
        
        return results
    
    def validate_generic_syntax(self, tokens: List[Token]) -> List[str]:
        """
        Validate generic type syntax in token list.
        
        Args:
            tokens: List of tokens to validate
            
        Returns:
            List of validation error messages
        """
        errors = []
        i = 0
        
        while i < len(tokens):
            token = tokens[i]
            
            # Check for balanced angle brackets
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
                    errors.append(f"Unmatched '<' at line {token.line}, column {token.column}")
            
            # Check for valid type constraint syntax
            if token.type == self.COLON:
                if i == 0 or tokens[i-1].type != self.IDENTIFIER:
                    errors.append(f"Invalid type constraint at line {token.line}, column {token.column}")
                elif i == len(tokens) - 1 or tokens[i+1].type != self.IDENTIFIER:
                    errors.append(f"Missing constraint type at line {token.line}, column {token.column}")
            
            i += 1
        
        return errors
    
    def get_type_parameters(self, tokens: List[Token]) -> List[Dict[str, str]]:
        """
        Extract type parameters from token list.
        
        Returns:
            List of dictionaries with type parameter info
        """
        type_params = []
        i = 0
        
        while i < len(tokens):
            if tokens[i].type == self.LT:
                # Extract parameters until closing bracket
                j = i + 1
                current_param = {}
                
                while j < len(tokens) and tokens[j].type != self.GT:
                    if tokens[j].type == self.IDENTIFIER:
                        param_name = tokens[j].value
                        
                        # Check if next token is a constraint
                        if (j + 1 < len(tokens) and 
                            tokens[j + 1].type == self.COLON and
                            j + 2 < len(tokens) and 
                            tokens[j + 2].type == self.IDENTIFIER):
                            
                            current_param = {
                                'name': param_name,
                                'constraint': tokens[j + 2].value
                            }
                            j += 3  # Skip identifier, colon, constraint
                        else:
                            current_param = {
                                'name': param_name,
                                'constraint': None
                            }
                            j += 1
                        
                        type_params.append(current_param)
                    
                    # Skip commas and other tokens
                    if j < len(tokens) and tokens[j].type == self.COMMA:
                        j += 1
                    elif j < len(tokens) and tokens[j].type != self.GT:
                        j += 1
                
                i = j
            else:
                i += 1
        
        return type_params

# Utility functions for working with generic type tokens
def create_generic_token(token_type: int, value: str, line: int = 1, column: int = 1) -> Token:
    """Create a generic type token with default position"""
    return Token(type=token_type, value=value, line=line, column=column)

def is_generic_token(token: Token) -> bool:
    """Check if token is related to generic type syntax"""
    return token.type in [
        GenericTypeLexer.LT,
        GenericTypeLexer.GT,
        GenericTypeLexer.COLON,
        GenericTypeLexer.COMMA,
        GenericTypeLexer.IDENTIFIER,
        GenericTypeLexer.GENERIC_KEYWORD
    ]

def format_type_parameters(type_params: List[Dict[str, str]]) -> str:
    """Format type parameters list as string"""
    if not type_params:
        return ""
    
    formatted_params = []
    for param in type_params:
        if param['constraint']:
            formatted_params.append(f"{param['name']}: {param['constraint']}")
        else:
            formatted_params.append(param['name'])
    
    return f"<{', '.join(formatted_params)}>"

