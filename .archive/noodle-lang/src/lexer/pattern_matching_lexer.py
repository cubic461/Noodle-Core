"""
Lexer::Pattern Matching Lexer - pattern_matching_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

# Pattern Matching Lexer Extension
# ==============================
# 
# Extends the unified lexer with pattern matching tokens

import re
from typing import List, Optional
from .lexer import TokenType, Token, Position, Lexer

class PatternMatchingLexer(Lexer):
    """Extended lexer with pattern matching support"""
    
    def __init__(self, source_code: str, filename: str = "<string>"):
        super().__init__(source_code, filename)
        
        # Add pattern matching specific patterns
        self.patterns.update({
            'match_keyword': re.compile(r'match'),
            'case_keyword': re.compile(r'case'),
            'when_keyword': re.compile(r'when'),
            'arrow': re.compile(r'=>'),
            'underscore': re.compile(r'_'),
        })
    
    def _tokenize_pattern_matching_constructs(self):
        """Tokenize pattern matching specific constructs"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        
        # Check for match keyword
        if self._current_char() == 'm' and self._peek_next_char() == 'a':
            next_chars = self._peek_ahead(4)
            if next_chars == 'tch':
                self._advance_position(5)
                self._add_token(TokenType.MATCH, 'match', start_pos)
                return
        
        # Check for case keyword
        if self._current_char() == 'c' and self._peek_next_char() == 'a':
            next_chars = self._peek_ahead(3)
            if next_chars == 'se':
                self._advance_position(4)
                self._add_token(TokenType.CASE, 'case', start_pos)
                return
        
        # Check for when keyword
        if self._current_char() == 'w' and self._peek_next_char() == 'h':
            next_chars = self._peek_ahead(3)
            if next_chars == 'hen':
                self._advance_position(4)
                self._add_token(TokenType.WHEN, 'when', start_pos)
                return
        
        # Check for arrow operator
        if self._current_char() == '=' and self._peek_next_char() == '>':
            self._advance_position(2)
            self._add_token(TokenType.ARROW, '=>', start_pos)
            return
    
    def _peek_ahead(self, count: int) -> str:
        """Peek ahead by specified number of characters"""
        result = ''
        for i in range(count):
            if self.position.column + i <= len(self.source_code.split('\n')[self.position.line - 1]):
                result += self._source_code.split('\n')[self.position.line - 1][self.position.column + i - 1]
        return result
    
    def tokenize(self) -> List[Token]:
        """Extended tokenize with pattern matching support"""
        # First run the base tokenizer
        tokens = super().tokenize()
        
        # Post-process to identify pattern matching constructs
        # This is a simplified approach - in a full implementation,
        # we would integrate this into the main tokenization loop
        pattern_tokens = self._extract_pattern_matching_tokens()
        
        # Insert pattern tokens in the right places
        result_tokens = []
        pattern_token_index = 0
        
        for token in tokens:
            # Check if we need to insert a pattern token before this token
            if (pattern_token_index < len(pattern_tokens) and 
                self._should_insert_pattern_token_before(token, pattern_tokens[pattern_token_index])):
                
                # Insert the pattern token
                result_tokens.append(pattern_tokens[pattern_token_index])
                pattern_token_index += 1
            
            result_tokens.append(token)
        
        return result_tokens
    
    def _extract_pattern_matching_tokens(self) -> List[Token]:
        """Extract pattern matching constructs from source code"""
        tokens = []
        
        # Simple pattern matching - look for keywords in source
        source_lower = self.source_code.lower()
        
        # Find match statements
        match_matches = list(re.finditer(r'\bmatch\b', source_lower))
        for match in match_matches:
            pos = self._get_position_from_index(match.start())
            tokens.append(Token(TokenType.MATCH, 'match', pos.line, pos.column, pos))
        
        # Find case statements  
        case_matches = list(re.finditer(r'\bcase\b', source_lower))
        for match in case_matches:
            pos = self._get_position_from_index(match.start())
            tokens.append(Token(TokenType.CASE, 'case', pos.line, pos.column, pos))
        
        # Find when statements
        when_matches = list(re.finditer(r'\bwhen\b', source_lower))
        for match in when_matches:
            pos = self._get_position_from_index(match.start())
            tokens.append(Token(TokenType.WHEN, 'when', pos.line, pos.column, pos))
        
        # Find arrow operators
        arrow_matches = list(re.finditer(r'=>', source_lower))
        for match in arrow_matches:
            pos = self._get_position_from_index(match.start())
            tokens.append(Token(TokenType.ARROW, '=>', pos.line, pos.column, pos))
        
        return sorted(tokens, key=lambda t: (t.line, t.column))
    
    def _get_position_from_index(self, index: int) -> Position:
        """Convert character index to line/column position"""
        lines_before = self.source_code[:index].split('\n')
        line_num = len(lines_before)
        column_num = len(lines_before[-1]) + 1
        
        return Position(line=line_num, column=column_num, filename=self.filename)
    
    def _should_insert_pattern_token_before(self, token: Token, pattern_token: Token) -> bool:
        """Check if pattern token should be inserted before the given token"""
        # Simple heuristic: pattern tokens come before the constructs they modify
        pattern_priority = {
            TokenType.MATCH: ['IDENTIFIER', 'LEFT_PAREN'],
            TokenType.CASE: ['IDENTIFIER', 'STRING', 'NUMBER'],
            TokenType.WHEN: ['IDENTIFIER'],
            TokenType.ARROW: ['IDENTIFIER', 'STRING', 'NUMBER', 'RIGHT_PAREN'],
        }
        
        if pattern_token.type not in pattern_priority:
            return False
        
        allowed_preceding = pattern_priority[pattern_token.type]
        return token.type in allowed_preceding and (
            token.line < pattern_token.line or 
            (token.line == pattern_token.line and token.column < pattern_token.column)
        )

# Extend TokenType enum with pattern matching tokens
# Note: In a full implementation, this would be added to the main TokenType enum
PATTERN_MATCHING_TOKENS = {
    'MATCH': 'MATCH',
    'CASE': 'CASE', 
    'WHEN': 'WHEN',
    'ARROW': 'ARROW'
}

# Add pattern matching tokens to TokenType if not already present
for token_name, token_value in PATTERN_MATCHING_TOKENS.items():
    if not hasattr(TokenType, token_name):
        setattr(TokenType, token_name, token_value)

