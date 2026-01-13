# Converted from Python to NoodleCore
# Original file: src

# """
# Lexer for Noodle Programming Language
# -----------------------------------
# This module implements the lexical analysis phase of the Noodle compiler.
# It converts source code into a stream of tokens.

# This module now imports from the new small, AI-friendly modules.
# """

# Import from new small modules
import typing.List
import .lexer_tokens.Token
import .lexer_position.Position
import .lexer_patterns.TokenPattern
import .lexer_main.Lexer

# Re-export for backward compatibility
__all__ = ['Token', 'TokenType', 'LexerError', 'Position', 'TokenPatterns', 'Lexer', 'tokenize']
