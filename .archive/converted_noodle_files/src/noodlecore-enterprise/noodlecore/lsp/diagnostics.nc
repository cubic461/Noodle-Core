# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Diagnostics implementation for Noodle LSP.
# """

import logging
import typing.List,

# Try to import lsprotocol types first, then fall back to pygls
try
    #     from lsprotocol.types import Diagnostic
except ImportError
    #     try:
    #         from pygls.types import Diagnostic
    #     except ImportError:
    #         # Basic fallback Diagnostic class
    #         class Diagnostic:
    #             def __init__(self, range, severity, message, source="noodle"):
    self.range = range
    self.severity = severity
    self.message = message
    self.source = source


logger = logging.getLogger(__name__)


class DiagnosticCollector
    #     """Collects and manages diagnostic information for documents."""

    #     def __init__(self):
    self.diagnostics = {}

    #     def collect(self, tokens, ast) -> List[Diagnostic]:
    #         """
    #         Collect diagnostics from tokens and AST.

    #         Args:
    #             tokens: List of tokens from lexer
    #             ast: Abstract syntax tree from parser

    #         Returns:
    #             List of Diagnostic objects
    #         """
    diagnostics = []

    #         # Example diagnostic collection - token errors
    #         if tokens:
    #             for token in tokens:
    #                 # Check for unknown tokens
    #                 if (
                        hasattr(token, "type")
    #                     and token.type
                        and hasattr(token.type, "value")
    #                 ):
    #                     if token.type.value == "UNKNOWN":
                            diagnostics.append(
                                Diagnostic(
    range = self._create_token_range(token),
    severity = 1,  # Error
    message = f"Unknown token: {token.value}",
    source = "noodle-lsp",
    #                             )
    #                         )

    #         # Example diagnostic collection - AST errors
    #         if ast:
    #             # Check for syntax errors in AST
    #             if hasattr(ast, "errors"):
    #                 for error in ast.errors:
                        diagnostics.append(
                            Diagnostic(
    range = self._create_position_range(
    #                                 error.line, error.column, error.length
    #                             ),
    severity = 1,  # Error
    message = error.message,
    source = "noodle-lsp",
    #                         )
    #                     )

    #         # Store diagnostics for document
    #         return diagnostics

    #     def _create_token_range(self, token):
    #         """Create a range for a token."""
    #         # Assuming token has position attributes
    #         from pygls.types import Position, Range

    #         # Create basic range (will be None if position not available)
    #         try:
                return Range(
    start = Position(
    line = (
    #                         token.position.line - 1
    #                         if hasattr(token.position, "line")
    #                         else 0
    #                     ),
    character = (
    #                         token.position.column - 1
    #                         if hasattr(token.position, "column")
    #                         else 0
    #                     ),
    #                 ),
    end = Position(
    line = (
    #                         token.position.line - 1
    #                         if hasattr(token.position, "line")
    #                         else 0
    #                     ),
    character = (
                            (token.position.column + len(token.value) - 1)
    #                         if hasattr(token.position, "column")
    #                         else 0
    #                     ),
    #                 ),
    #             )
    #         except:
    #             # Fallback range
    #             from pygls.types import Position, Range

                return Range(
    start = Position(line=0, character=0), end=Position(line=0, character=10)
    #             )

    #     def _create_position_range(self, line, column, length=1):
    #         """Create a range from position information."""
    #         from pygls.types import Position, Range

            return Range(
    start = math.subtract(Position(line=line, 1, character=column - 1),)
    end = math.add(Position(line=line - 1, character=column - 1, length),)
    #         )
