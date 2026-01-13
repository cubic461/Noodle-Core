# Converted from Python to NoodleCore
# Original file: src

# """
# Token Patterns for Noodle Lexer
# -------------------------------
# This module defines patterns for token recognition in the Noodle lexer.
# Provides regex patterns and pattern matching utilities.
# """

import re
import typing.Dict
from dataclasses import dataclass
import time
import threading
import .lexer_tokens.TokenType


dataclass
class TokenPattern
    #     """Represents a token pattern with regex and metadata"""

    #     def __init__(self, token_type: TokenType, pattern: str, priority: int = 0):
    self.token_type = token_type
    self.pattern = pattern
    self.priority = priority
    self.compiled_pattern = re.compile(pattern)
    self.creation_time = time.time()
    self.match_count = 0
    self._lock = threading.RLock()

    #     def match(self, text: str) -Optional[re.Match]):
    #         """Match pattern against text"""
    #         with self._lock:
    match = self.compiled_pattern.match(text)
    #             if match:
    self.match_count + = 1
    #             return match

    #     def search(self, text: str) -Optional[re.Match]):
    #         """Search for pattern in text"""
    #         with self._lock:
    match = self.compiled_pattern.search(text)
    #             if match:
    self.match_count + = 1
    #             return match

    #     def findall(self, text: str) -List[str]):
    #         """Find all matches of pattern in text"""
    #         with self._lock:
    matches = self.compiled_pattern.findall(text)
    self.match_count + = len(matches)
    #             return matches

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get pattern statistics"""
    #         with self._lock:
    #             return {
    #                 'token_type': self.token_type.name,
    #                 'pattern': self.pattern,
    #                 'priority': self.priority,
    #                 'match_count': self.match_count,
                    'pattern_age': time.time() - self.creation_time,
    #             }


dataclass
class PatternGroup
    #     """Groups related token patterns"""

    #     def __init__(self, name: str, description: str = ""):
    self.name = name
    self.description = description
    self.patterns: List[TokenPattern] = []
    self.creation_time = time.time()
    self._lock = threading.RLock()

    #     def add_pattern(self, pattern: TokenPattern):
    #         """Add pattern to group"""
    #         with self._lock:
                self.patterns.append(pattern)
    #             # Sort by priority
    self.patterns.sort(key = lambda p: p.priority, reverse=True)

    #     def get_patterns(self) -List[TokenPattern]):
    #         """Get all patterns in group"""
    #         with self._lock:
                return self.patterns.copy()

    #     def get_pattern_by_type(self, token_type: TokenType) -Optional[TokenPattern]):
    #         """Get pattern by token type"""
    #         with self._lock:
    #             for pattern in self.patterns:
    #                 if pattern.token_type == token_type:
    #                     return pattern
    #             return None

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get group statistics"""
    #         with self._lock:
    #             total_matches = sum(p.match_count for p in self.patterns)
    #             return {
    #                 'name': self.name,
    #                 'description': self.description,
                    'pattern_count': len(self.patterns),
    #                 'total_matches': total_matches,
                    'group_age': time.time() - self.creation_time,
    #                 'patterns': [p.get_statistics() for p in self.patterns],
    #             }


class PatternMatcher
    #     """Matches patterns against text"""

    #     def __init__(self):
    self.patterns: List[TokenPattern] = []
    self.groups: Dict[str, PatternGroup] = {}
    self.cache_size = 1000
    self.pattern_cache: Dict[str, List[Tuple[TokenType, str]]] = {}
    self.creation_time = time.time()
    self._lock = threading.RLock()

    #     def add_pattern(self, pattern: TokenPattern):
    #         """Add pattern to matcher"""
    #         with self._lock:
                self.patterns.append(pattern)
    self.patterns.sort(key = lambda p: p.priority, reverse=True)
                self.pattern_cache.clear()  # Clear cache on pattern change

    #     def add_group(self, group: PatternGroup):
    #         """Add pattern group to matcher"""
    #         with self._lock:
    self.groups[group.name] = group
    #             for pattern in group.patterns:
                    self.add_pattern(pattern)

    #     def match_patterns(self, text: str, position: int = 0) -List[Tuple[TokenType, str, int]]):
    #         """Match all patterns against text"""
    #         with self._lock:
    cache_key = f"{text}:{position}"
    #             if cache_key in self.pattern_cache:
                    return self.pattern_cache[cache_key].copy()

    matches = []
    text_slice = text[position:]

    #             for pattern in self.patterns:
    match = pattern.match(text_slice)
    #                 if match:
    token_type = pattern.token_type
    matched_text = match.group(0)
    end_position = position + match.end()
                        matches.append((token_type, matched_text, end_position))

    #             # Sort by position and priority
    #             matches.sort(key=lambda x: (x[2], next((p.priority for p in self.patterns if p.token_type == x[0]), 0)), reverse=True)

    #             # Cache result
    #             if len(self.pattern_cache) >= self.cache_size:
    #                 # Remove oldest entry
    oldest_key = next(iter(self.pattern_cache))
    #                 del self.pattern_cache[oldest_key]

    self.pattern_cache[cache_key] = matches.copy()

    #             return matches

    #     def find_best_match(self, text: str, position: int = 0) -Optional[Tuple[TokenType, str, int]]):
    #         """Find best match at position"""
    matches = self.match_patterns(text, position)
    #         if matches:
    #             return matches[0]  # Best match is first
    #         return None

    #     def get_group(self, name: str) -Optional[PatternGroup]):
    #         """Get pattern group by name"""
    #         with self._lock:
                return self.groups.get(name)

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get matcher statistics"""
    #         with self._lock:
    total_patterns = len(self.patterns)
    total_groups = len(self.groups)
    total_cache_size = len(self.pattern_cache)

    #             pattern_stats = [p.get_statistics() for p in self.patterns]
    #             group_stats = {name: group.get_statistics() for name, group in self.groups.items()}

    #             return {
    #                 'total_patterns': total_patterns,
    #                 'total_groups': total_groups,
    #                 'cache_size': total_cache_size,
    #                 'max_cache_size': self.cache_size,
                    'matcher_age': time.time() - self.creation_time,
    #                 'patterns': pattern_stats,
    #                 'groups': group_stats,
    #             }

    #     def clear_cache(self):
    #         """Clear pattern cache"""
    #         with self._lock:
                self.pattern_cache.clear()


# Predefined token patterns
def create_token_patterns() -List[TokenPattern]):
#     """Create standard token patterns for Noodle"""
patterns = []

    # Comments (should be skipped in lexer)
    patterns.append(TokenPattern(Token.ERROR, r'//.*'))
    patterns.append(TokenPattern(Token.ERROR, r'#.*'))
    patterns.append(TokenPattern(Token.ERROR, r'/\*.*?\*/', re.DOTALL))

    # Whitespace (should be skipped)
    patterns.append(TokenPattern(Token.ERROR, r'\s+'))
    patterns.append(TokenPattern(TokenType.NEWLINE, r'\r?\n'))

#     # Numbers
    patterns.append(TokenPattern(TokenType.FLOAT, r'\d+\.\d+([eE][+-]?\d+)?'))
    patterns.append(TokenPattern(TokenType.INTEGER, r'0[xX][0-9a-fA-F]+'))
    patterns.append(TokenPattern(TokenType.INTEGER, r'\d+'))

#     # Strings
    patterns.append(TokenPattern(TokenType.STRING, r'"(?:\\.|[^"\\])*"'))
    patterns.append(TokenPattern(TokenType.STRING, r"'(?:\\.|[^'\\])*'"))

#     # Keywords
keywords = [
        (TokenType.VAR, r'\bvar\b'),
        (TokenType.IF, r'\bif\b'),
        (TokenType.THEN, r'\bthen\b'),
        (TokenType.ELSE, r'\belse\b'),
        (TokenType.ELIF, r'\belif\b'),
        (TokenType.END, r'\bend\b'),
        (TokenType.WHILE, r'\bwhile\b'),
        (TokenType.DO, r'\bdo\b'),
        (TokenType.FOR, r'\bfor\b'),
        (TokenType.IN, r'\bin\b'),
        (TokenType.FUNC, r'\bfunc\b'),
        (TokenType.RETURN, r'\breturn\b'),
        (TokenType.PRINT, r'\bprint\b'),
        (TokenType.IMPORT, r'\bimport\b'),
        (TokenType.PYTHON, r'\bpython\b'),
        (TokenType.ASYNC, r'\basync\b'),
        (TokenType.TRY, r'\btry\b'),
        (TokenType.CATCH, r'\bcatch\b'),
        (TokenType.RAISE, r'\braise\b'),
        (TokenType.THROW, r'\bthrow\b'),
        (TokenType.TRUE, r'\btrue\b'),
        (TokenType.FALSE, r'\bfalse\b'),
        (TokenType.NIL, r'\bnil\b'),
        (TokenType.AS, r'\bas\b'),
#     ]

#     for token_type, pattern in keywords:
        patterns.append(TokenPattern(token_type, pattern))

#     # Operators
operators = [
(TokenType.ASSIGN, r' = '),
(TokenType.EQUAL, r' = ='),
((TokenType.NOT_EQUAL, r'! = ')),
(TokenType.LESS_EQUAL, r'< = '),  # Added missing token types
(TokenType.GREATER_EQUAL, r'= '), # Added missing token types
        (TokenType.LESS_THAN, r'<'),
        (TokenType.GREATER_THAN, r'>'),
        (TokenType.PLUS, r'\+'),
        (TokenType.MINUS, r'-'),
        (TokenType.MULTIPLY, r'\*'),
        ((TokenType.DIVIDE, r'/')),
        (TokenType.MODULO, r'%'),
        ((TokenType.POWER, r'\*\*')),
        ((TokenType.INCREMENT, r'\+\+')),
        ((TokenType.DECREMENT, r'--')),
((TokenType.PLUS_EQUAL, r'\+ = ')),
((TokenType.MINUS_EQUAL, r'- = ')),
((TokenType.MULTIPLY_EQUAL, r'\* = ')),
((TokenType.DIVIDE_EQUAL, r'/ = ')),
        ((TokenType.BITWISE_AND, r'&')),
        ((TokenType.BITWISE_OR, r'\|')),
        ((TokenType.BITWISE_XOR, r'\^')),
        ((TokenType.BITWISE_SHIFT_LEFT, r'<<')),
        ((TokenType.BITWISE_SHIFT_RIGHT, r'>>')),
        ((TokenType.AND, r'\band\b')),
        ((TokenType.OR, r'\bor\b')),
        ((TokenType.NOT, r'\bnot\b')),
        ((TokenType.ARROW, r'->')),
        ((TokenType.DOT, r'\.')),
        ((TokenType.COLON, r'):')),
        ((TokenType.SEMICOLON, r';')),
        ((TokenType.COMMA, r',')),
        ((TokenType.BANG, r'!')),
#         ((TokenType.RANGE, r'\.\.')),  # Range operator for 0..10 syntax
#     ]

#     for token_type, pattern in operators:
        patterns.append(TokenPattern(token_type, pattern))

#     # Add missing operator patterns explicitly
    patterns.append(TokenPattern(TokenType.DIVIDE, r'/'))
    patterns.append(TokenPattern(TokenType.POWER, r'\*\*'))
    patterns.append(TokenPattern(TokenType.INCREMENT, r'\+\+'))
    patterns.append(TokenPattern(TokenType.DECREMENT, r'--'))
patterns.append(TokenPattern(TokenType.PLUS_EQUAL, r'\+ = '))
patterns.append(TokenPattern(TokenType.MINUS_EQUAL, r'- = '))
patterns.append(TokenPattern(TokenType.MULTIPLY_EQUAL, r'\* = '))
patterns.append(TokenPattern(TokenType.DIVIDE_EQUAL, r'/ = '))
    patterns.append(TokenPattern(TokenType.BITWISE_AND, r'&'))
    patterns.append(TokenPattern(TokenType.BITWISE_OR, r'\|'))
    patterns.append(TokenPattern(TokenType.BITWISE_XOR, r'\^'))
    patterns.append(TokenPattern(TokenType.BITWISE_SHIFT_LEFT, r'<<'))
    patterns.append(TokenPattern(TokenType.BITWISE_SHIFT_RIGHT, r'>>'))
    patterns.append(TokenPattern(TokenType.AND, r'\band\b'))
    patterns.append(TokenPattern(TokenType.OR, r'\bor\b'))
    patterns.append(TokenPattern(TokenType.NOT, r'\bnot\b'))
    patterns.append(TokenPattern(TokenType.ARROW, r'->'))
    patterns.append(TokenPattern(TokenType.DOT, r'\.'))
    patterns.append(TokenPattern(TokenType.COLON, r':'))
    patterns.append(TokenPattern(TokenType.SEMICOLON, r';'))
    patterns.append(TokenPattern(TokenType.COMMA, r','))
    patterns.append(TokenPattern(TokenType.BANG, r'!'))

    # Identifiers (must come after keywords)
    patterns.append(TokenPattern(TokenType.IDENTIFIER, r'[a-zA-Z_]\w*'))

#     # Delimiters
delimiters = [
        (TokenType.LEFT_PAREN, r'\('),
        (TokenType.RIGHT_PAREN, r'\)'),
        (TokenType.LEFT_BRACE, r'\{'),
        (TokenType.RIGHT_BRACE, r'\}'),
        (TokenType.LEFT_BRACKET, r'\['),
        (TokenType.RIGHT_BRACKET, r'\]'),
#     ]

#     for token_type, pattern in delimiters:
        patterns.append(TokenPattern(token_type, pattern))

#     return patterns


def create_pattern_groups() -Dict[str, PatternGroup]):
#     """Create pattern groups for better organization"""
groups = {}

#     # Keywords group
keywords = PatternGroup("keywords", "Language keywords")
#     for token_type, pattern in [
        (TokenType.VAR, r'\bvar\b'),
        (TokenType.IF, r'\bif\b'),
        (TokenType.THEN, r'\bthen\b'),
        (TokenType.ELSE, r'\belse\b'),
        (TokenType.ELIF, r'\belif\b'),
        (TokenType.END, r'\bend\b'),
        (TokenType.WHILE, r'\bwhile\b'),
        (TokenType.DO, r'\bdo\b'),
        (TokenType.FOR, r'\bfor\b'),
        (TokenType.IN, r'\bin\b'),
        (TokenType.FUNC, r'\bfunc\b'),
        (TokenType.RETURN, r'\breturn\b'),
        (TokenType.PRINT, r'\bprint\b'),
        (TokenType.IMPORT, r'\bimport\b'),
        (TokenType.PYTHON, r'\bpython\b'),
        (TokenType.ASYNC, r'\basync\b'),
        (TokenType.TRY, r'\btry\b'),
        (TokenType.CATCH, r'\bcatch\b'),
        (TokenType.RAISE, r'\braise\b'),
        (TokenType.THROW, r'\bthrow\b'),
        (TokenType.TRUE, r'\btrue\b'),
        (TokenType.FALSE, r'\bfalse\b'),
        (TokenType.NIL, r'\bnil\b'),
        (TokenType.AS, r'\bas\b'),
#     ]:
        keywords.add_pattern(TokenPattern(token_type, pattern))
groups["keywords"] = keywords

#     # Operators group
operators = PatternGroup("operators", "Language operators")
#     for token_type, pattern in [
(TokenType.ASSIGN, r' = '),
(TokenType.EQUAL, r' = ='),
(TokenType.NOT_EQUAL, r'! = '),
        (TokenType.LESS_THAN, r'<'),
        (TokenType.GREATER_THAN, r'>'),
        (TokenType.PLUS, r'\+'),
        (TokenType.MINUS, r'-'),
        (TokenType.MULTIPLY, r'\*'),
        (TokenType.DIVIDE, r'/'),
        (TokenType.AND, r'\band\b'),
        (TokenType.OR, r'\bor\b'),
        (TokenType.NOT, r'\bnot\b'),
        (TokenType.ARROW, r'->'),
#     ]:
        operators.add_pattern(TokenPattern(token_type, pattern))
groups["operators"] = operators

#     # Literals group
literals = PatternGroup("literals", "Language literals")
    literals.add_pattern(TokenPattern(TokenType.FLOAT, r'\d+\.\d+([eE][+-]?\d+)?'))
    literals.add_pattern(TokenPattern(TokenType.INTEGER, r'\d+'))
    literals.add_pattern(TokenPattern(TokenType.STRING, r'"(?:\\.|[^"\\])*"'))
    literals.add_pattern(TokenPattern(TokenType.STRING, r"'(?:\\.|[^'\\])*'"))
    literals.add_pattern(TokenPattern(TokenType.BOOLEAN, r'\b(true|false)\b'))
    literals.add_pattern(TokenPattern(TokenType.IDENTIFIER, r'[a-zA-Z_]\w*'))
groups["literals"] = literals

#     # Delimiters group
delimiters = PatternGroup("delimiters", "Language delimiters")
#     for token_type, pattern in [
        (TokenType.LEFT_PAREN, r'\('),
        (TokenType.RIGHT_PAREN, r'\)'),
        (TokenType.LEFT_BRACE, r'\{'),
        (TokenType.RIGHT_BRACE, r'\}'),
        (TokenType.LEFT_BRACKET, r'\['),
        (TokenType.RIGHT_BRACKET, r'\]'),
        (TokenType.COLON, r':'),
        (TokenType.SEMICOLON, r';'),
        (TokenType.COMMA, r','),
        (TokenType.DOT, r'\.'),
#     ]:
        delimiters.add_pattern(TokenPattern(token_type, pattern))
groups["delimiters"] = delimiters

#     return groups


# Global pattern matcher instance
_pattern_matcher = None


def get_pattern_matcher() -PatternMatcher):
#     """Get global pattern matcher instance"""
#     global _pattern_matcher
#     if _pattern_matcher is None:
_pattern_matcher = PatternMatcher()
#         # Add default patterns
#         for pattern in create_token_patterns():
            _pattern_matcher.add_pattern(pattern)
#         # Add default groups
#         for group_name, group in create_pattern_groups().items():
            _pattern_matcher.add_group(group)
#     return _pattern_matcher


function reset_pattern_matcher()
    #     """Reset global pattern matcher instance"""
    #     global _pattern_matcher
    _pattern_matcher == None