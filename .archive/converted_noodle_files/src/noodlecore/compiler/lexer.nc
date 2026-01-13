# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Lexer Module
 = ===================

# This module provides lexical analysis functionality for NoodleCore,
# including token definitions and tokenization logic.

# Improvements made:
# - Fixed duplicate method definitions
# - Added missing IDENTIFIER token type
# - Improved number parsing with better error handling
# - Added support for scientific notation
# - Optimized performance by reducing repeated indexing
# - Enhanced code readability and documentation
# - Added proper error handling for malformed numbers
- Fixed delimiter recognition (parentheses, braces, etc.)
# - Fixed dot operator precedence issue
# """

import typing.List,
import enum.Enum
import dataclasses.dataclass

# Token Types
class TokenType(Enum)
    #     """Enumeration of token types in NoodleCore."""

    #     # Literals
    INTEGER = "INTEGER"
    FLOAT = "FLOAT"
    STRING = "STRING"
    BOOLEAN = "BOOLEAN"
    NONE = "NONE"

    #     # Operators
    PLUS = "PLUS"
    MINUS = "MINUS"
    MULTIPLY = "MULTIPLY"
    DIVIDE = "DIVIDE"
    MODULO = "MODULO"

    #     # Comparisons
    EQUAL = "EQUAL"
    NOT_EQUAL = "NOT_EQUAL"
    LESS_THAN = "LESS_THAN"
    GREATER_THAN = "GREATER_THAN"
    LESS_EQUAL = "LESS_EQUAL"
    GREATER_EQUAL = "GREATER_EQUAL"

    #     # Logical
    AND = "AND"
    OR = "OR"
    NOT = "NOT"

    #     # Assignment
    ASSIGN = "ASSIGN"

    #     # Delimiters
    LEFT_PAREN = "LEFT_PAREN"
    RIGHT_PAREN = "RIGHT_PAREN"
    LEFT_BRACE = "LEFT_BRACE"
    RIGHT_BRACE = "RIGHT_BRACE"
    SEMICOLON = "SEMICOLON"
    COMMA = "COMMA"
    DOT = "DOT"

    #     # Keywords
    FUNC = "FUNC"
    CLASS = "CLASS"
    IF = "IF"
    ELSE = "ELSE"
    FOR = "FOR"
    WHILE = "WHILE"
    RETURN = "RETURN"
    IMPORT = "IMPORT"
    VAR = "VAR"

    #     # Identifiers
    IDENTIFIER = "IDENTIFIER"

    #     # Special
    NEWLINE = "NEWLINE"
    EOF = "EOF"
    INDENT = "INDENT"
    DEDENT = "DEDENT"

# @dataclass
class Token
    #     """Represents a token in the NoodleCore language."""

    #     token_type: TokenType
    #     value: Any
    #     line_number: int
    #     column: int
    #     lexeme: str

    #     def __str__(self):
            return f"Token({self.token_type}, {self.value}, {self.line_number}:{self.column})"

    #     def __repr__(self):
            return self.__str__()

class Lexer
    #     """Lexical analyzer for NoodleCore language."""

    #     def __init__(self, source: str):
    self.source = source
    self.position = 0
    self.line_number = 1
    self.column = 1
    self.tokens = []

    #     def tokenize(self) -> List[Token]:
    #         """Convert source code into a list of tokens."""
    self.tokens = []
    self.position = 0
    self.line_number = 1
    self.column = 1

    #         while self.position < len(self.source):
    char = self.current_char

    #             # Skip whitespace but track newlines
    #             if char.isspace():
    #                 if char == '\n':
                        self._handle_newline()
    #                 else:
    self.position + = 1
    self.column + = 1
    #                 continue

    #             # Check for numbers first (highest priority for dot)
    #             if self._is_number_start(char):
    number_value, token_type = self._read_number()
                    self.tokens.append(Token(token_type, number_value, self.line_number, self.column, number_value))
    self.column + = len(number_value)
    #                 continue

    #             # Check for multi-character tokens (including delimiters, but not dot)
    #             if char in '+-*/%=<>!&|(){},;':
    token_type = self._get_operator_token_type(char)
    #                 if token_type:
                        self.tokens.append(Token(token_type, char, self.line_number, self.column, char))
    self.position + = 1
    self.column + = 1
    #                     continue

                # Handle dot operator specifically (after number check)
    #             if char == '.':
    token_type = self._get_operator_token_type(char)
    #                 if token_type:
                        self.tokens.append(Token(token_type, char, self.line_number, self.column, char))
    self.position + = 1
    self.column + = 1
    #                     continue

    #             # Check for strings
    #             if char in '"\'':
    string_value = self._read_string(char)
                    self.tokens.append(Token(TokenType.STRING, string_value, self.line_number, self.column, string_value))
    #                 self.column += len(string_value) + 2  # +2 for quotes
    #                 continue

    #             # Check for identifiers and keywords
    #             if char.isalpha() or char == '_':
    identifier = self._read_identifier()
    token_type = self._get_keyword_token_type(identifier)
                    self.tokens.append(Token(token_type, identifier, self.line_number, self.column, identifier))
    self.column + = len(identifier)
    #                 continue

    #             # If we get here, it's an unrecognized character
                self.tokens.append(Token(TokenType.EOF, char, self.line_number, self.column, f"Unexpected character: {char}"))
    self.position + = 1
    self.column + = 1

    #         # Add EOF token
            self.tokens.append(Token(TokenType.EOF, None, self.line_number, self.column, None))
    #         return self.tokens

    #     @property
    #     def current_char(self) -> str:
    #         """Get the current character at position."""
    #         if self.position < len(self.source):
    #             return self.source[self.position]
    #         return ''

    #     @property
    #     def peek_char(self) -> str:
    #         """Peek at the next character without advancing position."""
    #         if self.position + 1 < len(self.source):
    #             return self.source[self.position + 1]
    #         return ''

    #     @property
    #     def peek_ahead_char(self) -> str:
    #         """Peek at the character after next without advancing position."""
    #         if self.position + 2 < len(self.source):
    #             return self.source[self.position + 2]
    #         return ''

    #     def _handle_newline(self):
    #         """Handle newline characters by updating line and column tracking."""
    self.position + = 1
    self.line_number + = 1
    self.column = 1

    #     def _is_number_start(self, char: str) -> bool:
    #         """Check if a character can start a number literal."""
    return char.isdigit() or (char = = '.' and self.peek_char.isdigit())

    #     def _read_number(self) -> tuple[str, TokenType]:
    #         """
            Read a number (integer, float, or scientific notation) from source.

    #         Returns:
                tuple: (number_string, token_type)

    #         Raises:
    #             ValueError: If the number format is invalid
    #         """
    start_pos = self.position
    has_decimal = False
    has_exponent = False

    #         # Read the main part of the number
    #         while self.position < len(self.source):
    char = self.current_char

    #             if char.isdigit():
    self.position + = 1
    #             elif char == '.':
    #                 if has_decimal:
                        raise ValueError(f"Invalid number format: multiple decimal points at line {self.line_number}, column {self.column}")
    has_decimal = True
    self.position + = 1
    #                 # Check if there's a digit after the decimal
    #                 if self.position >= len(self.source) or not self.current_char.isdigit():
                        raise ValueError(f"Invalid number format: decimal point not followed by digit at line {self.line_number}, column {self.column}")
    #             elif char in 'eE':
    #                 if has_exponent:
                        raise ValueError(f"Invalid number format: multiple exponents at line {self.line_number}, column {self.column}")
    has_exponent = True
    self.position + = 1
    #                 # Check for optional sign after exponent
    #                 if self.current_char in '+-':
    self.position + = 1
    #                 # Must have at least one digit after exponent
    #                 if self.position >= len(self.source) or not self.current_char.isdigit():
                        raise ValueError(f"Invalid number format: exponent not followed by digit at line {self.line_number}, column {self.column}")
    #             else:
    #                 break

    number_str = self.source[start_pos:self.position]

    #         # Determine token type
    #         if has_exponent or has_decimal:
    #             return number_str, TokenType.FLOAT
    #         else:
    #             return number_str, TokenType.INTEGER

    #     def _read_string(self, quote_char: str) -> str:
    #         """
    #         Read a string literal from source.

    #         Args:
                quote_char: The quote character used to start the string (' or ")

    #         Returns:
    #             The string content without quotes

    #         Raises:
    #             ValueError: If the string is not properly terminated
    #         """
    start_pos = math.add(self.position, 1)
    self.position + = 1  # Skip opening quote

    #         while self.position < len(self.source) and self.current_char != quote_char:
    #             # Handle escape sequences
    #             if self.current_char == '\\' and self.position + 1 < len(self.source):
    self.position + = 2  # Skip escape character and escaped char
    #             else:
    self.position + = 1

    #         if self.position >= len(self.source):
                raise ValueError(f"Unterminated string literal starting at line {self.line_number}, column {self.column}")

    end_pos = self.position
    self.position + = 1  # Skip closing quote

    #         return self.source[start_pos:end_pos]

    #     def _read_identifier(self) -> str:
    #         """
    #         Read an identifier from source.

    #         Returns:
    #             The identifier string
    #         """
    start_pos = self.position

    #         # First character must be letter or underscore
    #         if self.current_char.isalpha() or self.current_char == '_':
    self.position + = 1

    #         # Subsequent characters can be letters, digits, or underscores
    #         while (self.position < len(self.source) and
    (self.current_char.isalnum() or self.current_char = = '_')):
    self.position + = 1

    #         return self.source[start_pos:self.position]

    #     def _get_operator_token_type(self, char: str) -> Optional[TokenType]:
    #         """Get token type for operator character."""
    operator_map = {
    #             '+': TokenType.PLUS,
    #             '-': TokenType.MINUS,
    #             '*': TokenType.MULTIPLY,
    #             '/': TokenType.DIVIDE,
    #             '%': TokenType.MODULO,
    ' = ': TokenType.EQUAL,
    #             '!': TokenType.NOT_EQUAL,
    #             '<': TokenType.LESS_THAN,
    #             '>': TokenType.GREATER_THAN,
    #             '&': TokenType.AND,
    #             '|': TokenType.OR,
                '(': TokenType.LEFT_PAREN,
    #             ')': TokenType.RIGHT_PAREN,
    #             '{': TokenType.LEFT_BRACE,
    #             '}': TokenType.RIGHT_BRACE,
    #             ',': TokenType.COMMA,
    #             ';': TokenType.SEMICOLON,
    #             '.': TokenType.DOT,
    #         }
            return operator_map.get(char)

    #     def _get_keyword_token_type(self, identifier: str) -> TokenType:
    #         """Get token type for keyword or identifier."""
    keywords = {
    #             'func': TokenType.FUNC,
    #             'class': TokenType.CLASS,
    #             'if': TokenType.IF,
    #             'else': TokenType.ELSE,
    #             'for': TokenType.FOR,
    #             'while': TokenType.WHILE,
    #             'return': TokenType.RETURN,
    #             'import': TokenType.IMPORT,
    #             'var': TokenType.VAR,
    #             'true': TokenType.BOOLEAN,
    #             'false': TokenType.BOOLEAN,
    #             'none': TokenType.NONE,
    #         }
            return keywords.get(identifier, TokenType.IDENTIFIER)
