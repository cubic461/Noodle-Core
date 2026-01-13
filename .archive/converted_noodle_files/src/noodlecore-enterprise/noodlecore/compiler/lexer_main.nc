# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Main Lexer for Noodle Programming Language
# -------------------------------------------
# This module implements the main lexer for the Noodle language.
# It tokenizes source code using patterns and position tracking.
# """

import time
import threading
import typing.List,
import .lexer_tokens.Token,
import .lexer_position.Position,
import .lexer_patterns.TokenPattern,


class Lexer
    #     """Main lexer for Noodle language"""

    #     def __init__(self, filename: str = None, content: str = None):
    self.filename = filename
    self.content = content
    self.position_tracker = get_position_tracker()
    self.pattern_matcher = get_pattern_matcher()

    #         # Add file to position tracker
    #         if filename and content:
    self.source_file = self.position_tracker.add_file(filename, content)
    #         else:
    self.source_file = None

    #         # Lexer state
    self.current_position = 0
    self.tokens: List[Token] = []
    self.errors: List[str] = []
    self.warnings: List[str] = []
    self.start_time = time.time()
    self.token_count = 0
    self._lock = threading.RLock()

    #         # Lexer settings
    self.skip_whitespace = True
    self.skip_comments = True
    self.include_newlines = True
    self.error_recovery = True
    self.max_errors = 10

    #         # Performance tracking
    self.parse_times: List[float] = []
    self.memory_usage = 0

    #     def tokenize(self, content: str = None, filename: str = None) -> TokenStream:
    #         """Tokenize content and return token stream"""
    start_time = time.time()

    #         with self._lock:
    #             # Update content and filename if provided
    #             if content is not None:
                    print(f"DEBUG: Lexer received content: {repr(content[:50])}")
    self.content = content
    #             if filename is not None:
    self.filename = filename
    self.source_file = self.position_tracker.add_file(filename, content)

    #             # Reset state
    self.current_position = 0
    self.tokens = []
    self.errors = []
    self.warnings = []
    self.token_count = 0

    #             # Debug: Print content being tokenized
                print(f"DEBUG: Tokenizing content: '{self.content}'")

    #             # Tokenize
    #             try:
    #                 if self.content is None:
    self.content = ""

    #                 while self.current_position < len(self.content):
    #                     # Debug: Print current position
    #                     char = self.content[self.current_position] if self.current_position < len(self.content) else 'EOF'
                        print(f"DEBUG: Processing position {self.current_position}, char: '{char}'")

                        self._skip_unwanted_tokens()

    #                     if self.current_position >= len(self.content):
    #                         break

    token = self._read_next_token()
    #                     if token:
                            print(f"DEBUG: Created token: {token}")
    #                         if token.is_error():
                                self.errors.append(f"Error at {token.position}: {token.value}")
    #                             if len(self.errors) >= self.max_errors:
    #                                 break
    #                         else:
                                self.tokens.append(token)
    self.token_count + = 1

    #                 # Add EOF token
    eof_position = self._create_position()
    eof_token = Token(TokenType.EOF, "", eof_position)
                    self.tokens.append(eof_token)
                    print(f"DEBUG: Added EOF token: {eof_token}")

    #             except Exception as e:
    #                 import traceback
    error_msg = f"Lexer error: {str(e)}"
                    print(f"DEBUG: Full error traceback:")
                    traceback.print_exc()
                    self.errors.append(error_msg)

    #                 if self.error_recovery:
                        self._recover_from_error()
    #                 else:
    #                     raise

    #             # Debug: Print final tokens
                print(f"DEBUG: Final tokens: {self.tokens}")

    #             # Track performance
    parse_time = math.subtract(time.time(), start_time)
                self.parse_times.append(parse_time)

    #             # Create token stream
    token_stream = TokenStream(self.tokens)

    #             return token_stream

    #     def _skip_unwanted_tokens(self):
    #         """Skip whitespace and comments if configured"""
    #         if not self.content:
    #             return

    #         # Find next non-whitespace character
    #         while self.current_position < len(self.content):
    char = self.content[self.current_position]

    #             # Skip whitespace
    #             if char.isspace():
    #                 if self.skip_whitespace:
    #                     # Simply skip whitespace when enabled
    #                     pass
    #                 else:
    #                     # Create position for whitespace
    position = self._create_position()
    #                     # Create and skip whitespace token
    whitespace_token = Token(TokenType.ERROR, char, position)
                        self.tokens.append(whitespace_token)
    self.current_position + = 1
    #                 continue

    #             # Skip comments
    #             if self.skip_comments:
    comment_token = self._try_read_comment()
    #                 if comment_token:
    #                     if comment_token.is_error():
                            self.errors.append(f"Comment error at {comment_token.position}: {comment_token.value}")
    #                     continue

    #             break

    #     def _try_read_comment(self) -> Optional[Token]:
    #         """Try to read a comment"""
    #         if not self.content or self.current_position >= len(self.content):
    #             return None

    current_char = self.content[self.current_position]

    #         # Line comment
    #         if current_char == '/' and self.current_position + 1 < len(self.content):
    next_char = math.add(self.content[self.current_position, 1])
    #             if next_char == '/':
    #                 # Read until end of line
    start_pos = self.current_position
    self.current_position + = 2

    #                 while (self.current_position < len(self.content) and
    self.content[self.current_position] ! = '\n'):
    self.current_position + = 1

    position = self._create_position(start_pos)
    comment_text = self.content[start_pos:self.current_position]
                    return Token(TokenType.ERROR, comment_text, position)

    #         # Block comment
    #         elif current_char == '/' and self.current_position + 1 < len(self.content):
    next_char = math.add(self.content[self.current_position, 1])
    #             if next_char == '*':
    #                 # Read until */
    start_pos = self.current_position
    self.current_position + = 2

    #                 while (self.current_position + 1 < len(self.content) and
    not (self.content[self.current_position] = = '*' and
    self.content[self.current_position + 1] = = '/')):
    self.current_position + = 1

    #                 if self.current_position + 1 < len(self.content):
    self.current_position + = math.multiply(2  # Skip, /)

    position = self._create_position(start_pos)
    comment_text = self.content[start_pos:self.current_position]
                    return Token(TokenType.ERROR, comment_text, position)

    #         return None

    #     def _read_next_token(self) -> Optional[Token]:
    #         """Read the next token"""
    #         if not self.content or self.current_position >= len(self.content):
    #             return None

    #         # Find best match using pattern matcher
    match = self.pattern_matcher.find_best_match(self.content, self.current_position)
    #         if not match:
    #             # No match found - create error token
    position = self._create_position()
    char = self.content[self.current_position]
    error_token = Token(TokenType.ERROR, f"Unknown character: {char}", position)
    self.current_position + = 1
    #             return error_token

    token_type, matched_text, end_position = match

    #         # Create position for token
    start_pos = self.current_position
    self.current_position = end_position
    position = self._create_position(start_pos)

    #         # Create token
    token = Token(token_type, matched_text, position)

    #         return token

    #     def _create_position(self, offset: int = None) -> Position:
    #         """Create a position at current location"""
    #         if offset is None:
    offset = self.current_position

    #         if self.source_file:
                return self.position_tracker.create_position_from_offset(offset)
    #         else:
    #             # Fallback for files not in tracker
    line = 1
    column = 1
    temp_offset = 0

    #             for char in self.content[:offset]:
    #                 if char == '\n':
    line + = 1
    column = 1
    #                 else:
    column + = 1
    temp_offset + = 1

                return Position(line, column)

    #     def _recover_from_error(self):
    #         """Recover from lexer error"""
    #         # Skip to next statement boundary
    #         while self.current_position < len(self.content):
    char = self.content[self.current_position]
    #             if char in [';', '\n']:
    #                 break
    self.current_position + = 1

    #     def get_tokens(self) -> List[Token]:
    #         """Get all tokens"""
    #         with self._lock:
                return self.tokens.copy()

    #     def get_errors(self) -> List[str]:
    #         """Get all errors"""
    #         with self._lock:
                return self.errors.copy()

    #     def get_warnings(self) -> List[str]:
    #         """Get all warnings"""
    #         with self._lock:
                return self.warnings.copy()

    #     def is_valid(self) -> bool:
    #         """Check if tokenization was successful"""
    #         with self._lock:
    return len(self.errors) = = 0

    #     def has_errors(self) -> bool:
    #         """Check if there are any errors"""
    #         with self._lock:
                return len(self.errors) > 0

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get lexer statistics"""
    #         with self._lock:
    total_time = sum(self.parse_times)
    #             avg_time = total_time / len(self.parse_times) if self.parse_times else 0

    #             return {
    #                 'filename': self.filename,
    #                 'content_size': len(self.content) if self.content else 0,
    #                 'token_count': self.token_count,
                    'error_count': len(self.errors),
                    'warning_count': len(self.warnings),
    #                 'total_parse_time': total_time,
    #                 'average_parse_time': avg_time,
                    'lexer_age': time.time() - self.start_time,
    #                 'current_position': self.current_position,
    #                 'settings': {
    #                     'skip_whitespace': self.skip_whitespace,
    #                     'skip_comments': self.skip_comments,
    #                     'include_newlines': self.include_newlines,
    #                     'error_recovery': self.error_recovery,
    #                     'max_errors': self.max_errors,
    #                 },
    #             }

    #     def reset(self):
    #         """Reset lexer state"""
    #         with self._lock:
    self.current_position = 0
    self.tokens = []
    self.errors = []
    self.warnings = []
    self.token_count = 0
    self.parse_times = []

    #     def configure(self, skip_whitespace: bool = None, skip_comments: bool = None,
    include_newlines: bool = None, error_recovery: bool = None,
    max_errors: int = None):
    #         """Configure lexer settings"""
    #         with self._lock:
    #             if skip_whitespace is not None:
    self.skip_whitespace = skip_whitespace
    #             if skip_comments is not None:
    self.skip_comments = skip_comments
    #             if include_newlines is not None:
    self.include_newlines = include_newlines
    #             if error_recovery is not None:
    self.error_recovery = error_recovery
    #             if max_errors is not None:
    self.max_errors = max_errors

    #     def validate_tokens(self) -> List[str]:
    #         """Validate token sequence"""
    #         with self._lock:
                return TokenValidator.validate_token_types(self.tokens, [])

    #     def get_token_positions(self) -> Dict[str, List[int]]:
    #         """Get positions of token types"""
    #         with self._lock:
    positions = {}
    #             for i, token in enumerate(self.tokens):
    #                 if token.type.name not in positions:
    positions[token.type.name] = []
                    positions[token.type.name].append(i)
    #             return positions

    #     def export_tokens(self, format: str = 'json') -> Union[str, Dict]:
    #         """Export tokens in specified format"""
    #         with self._lock:
    #             if format.lower() == 'json':
    #                 return {
    #                     'filename': self.filename,
    #                     'tokens': [token.to_dict() for token in self.tokens],
    #                     'errors': self.errors,
    #                     'warnings': self.warnings,
                        'statistics': self.get_statistics(),
    #                 }
    #             elif format.lower() == 'csv':
    #                 import csv
    #                 import io
    output = io.StringIO()
    writer = csv.writer(output)
                    writer.writerow(['Type', 'Value', 'Line', 'Column', 'Position'])

    #                 for token in self.tokens:
    position = token.position
    #                     line = position.line if position else 0
    #                     column = position.column if position else 0
                        writer.writerow([token.type.name, token.value, line, column, str(position)])

                    return output.getvalue()
    #             else:
                    raise ValueError(f"Unsupported export format: {format}")


def tokenize(source: str, filename: str = "<string>", **kwargs) -> TokenStream:
#     """Convenience function to tokenize source code"""
lexer = Lexer(filename, source)
    lexer.configure(**kwargs)
    return lexer.tokenize()


def tokenize_file(filename: str, **kwargs) -> TokenStream:
#     """Convenience function to tokenize a file"""
#     with open(filename, 'r', encoding='utf-8') as f:
content = f.read()
    return tokenize(content, filename, **kwargs)


# Global lexer cache
_lexer_cache = TokenCache(max_size=100)


def get_cached_lexer(filename: str, content: str = None) -> Lexer:
#     """Get cached lexer for file"""
#     cache_key = f"{filename}:{hash(content) if content else 'no_content'}"

#     # Try to get from cache
cached_tokens = _lexer_cache.get(cache_key)
#     if cached_tokens is not None:
#         # Create lexer with cached tokens
lexer = Lexer(filename, content)
lexer.tokens = cached_tokens
#         return lexer

#     # Create new lexer
lexer = Lexer(filename, content)
#     return lexer


function clear_lexer_cache()
    #     """Clear lexer cache"""
        _lexer_cache.clear()


def get_lexer_cache_stats() -> Dict[str, Any]:
#     """Get lexer cache statistics"""
    return _lexer_cache.get_statistics()
