# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Syntax highlighting implementation for Noodle LSP.
# """

import logging
import typing.Any,

# Try to import lsprotocol types first, then fall back to pygls
try
        from lsprotocol.types import (
    #         SemanticTokenModifiers,
    #         SemanticTokens,
    #         SemanticTokensOptions,
    #         SemanticTokensParams,
    #         SemanticTokenTypes,
    #     )
except ImportError
    #     try:
            from pygls.types import (
    #             SemanticTokenModifiers,
    #             SemanticTokens,
    #             SemanticTokensOptions,
    #             SemanticTokensParams,
    #             SemanticTokenTypes,
    #         )
    #     except ImportError:
    #         # Basic fallback classes with proper attributes
    #         class SemanticTokens:
    #             def __init__(self, data=None):
    self.data = data or []

    #         class SemanticTokensParams:
    #             def __init__(self, text_document=None):
    self.text_document = text_document

    #         class SemanticTokensOptions:
    #             def __init__(self, full=False):
    self.full = full

    #         class SemanticTokenTypes:
    #             # Define numeric constants for token types
    namespace = 1
    type = 2
    class_ = 3
    enum = 4
    interface = 5
    struct = 6
    typeParameter = 7
    parameter = 8
    variable = 9
    property = 10
    enumMember = 11
    event = 12
    function = 13
    method = 14
    macro = 15
    keyword = 16
    modifier = 17
    comment = 18
    string = 19
    number = 20
    regexp = 21
    operator = 22

    #             # Add string representations for easier mapping
    TYPE_MAP = {
    #                 "namespace": 1,
    #                 "type": 2,
    #                 "class": 3,
    #                 "enum": 4,
    #                 "interface": 5,
    #                 "struct": 6,
    #                 "typeParameter": 7,
    #                 "parameter": 8,
    #                 "variable": 9,
    #                 "property": 10,
    #                 "enumMember": 11,
    #                 "event": 12,
    #                 "function": 13,
    #                 "method": 14,
    #                 "macro": 15,
    #                 "keyword": 16,
    #                 "modifier": 17,
    #                 "comment": 18,
    #                 "string": 19,
    #                 "number": 20,
    #                 "regexp": 21,
    #                 "operator": 22,
    #             }

    #             @classmethod
    #             def get_type(cls, type_name):
                    return cls.TYPE_MAP.get(
    #                     type_name, cls.variable
    #                 )  # Default to variable if not found

    #             # Custom attributes for easier access
    KEYWORD = 16
    STRING = 19
    NUMBER = 20
    OPERATOR = 22
    COMMENT = 18
    TYPE = 2
    FUNCTION = 13
    VARIABLE = 9

    #         class SemanticTokenModifiers:
    #             # Define numeric constants for token modifiers
    declaration = 1
    definition = 2
    readonly = 3
    static = 4
    deprecated = 5
    abstract = 6
    async_modifier = 7  # Changed from 'async' to avoid conflict
    modification = 8
    documentation = 9
    defaultLibrary = 10

    #             # Custom attributes for easier access
    DECLARATION = 1
    DEFINITION = 2
    READONLY = 3
    STATIC = 4
    DEFAULT_LIBRARY = 10


logger = logging.getLogger(__name__)


class SyntaxHighlighter
    #     """Handles syntax highlighting for Noodle documents."""

    #     def __init__(self):
    #         # Token type mapping
    self.token_type_map = {
    #             "KEYWORD": 16,  # Directly use the numeric value
    #             "STRING": 19,
    #             "NUMBER": 20,
    #             "OPERATOR": 22,
    #             "COMMENT": 18,
    #             "TYPE": 2,
    #             "FUNCTION": 13,
    #             "VARIABLE": 9,
    #         }

    #         # Token modifier mapping
    self.token_modifier_map = {
    #             "DECLARATION": 1,
    #             "DEFINITION": 2,
    #             "STATIC": 4,
    #             "DEFAULT_LIBRARY": 10,
    #         }

    #     def get_semantic_tokens(self, tokens, text: str) -> SemanticTokens:
    #         """
    #         Generate semantic tokens from token list.

    #         Args:
    #             tokens: List of tokens from lexer
    #             text: Original text of the document

    #         Returns:
    #             SemanticTokens object containing highlighting information
    #         """
    #         if not tokens:
    return SemanticTokens(data = [])

    #         # Convert tokens to LSP semantic token format
    #         # Each token is represented as: [deltaLine, deltaStart, length, tokenType, tokenModifiers]
    semantic_tokens = []
    prev_line = 0
    prev_start = 0

    #         for token in tokens:
    #             if not hasattr(token, "type") or not token.type:
    #                 continue

    #             # Get token type
    token_type_value = (
    #                 token.type.value if hasattr(token.type, "value") else str(token.type)
    #             )
    token_type = self.token_type_map.get(
    #                 token_type_value, 9
                )  # Default to variable (9)

    #             # Calculate line and position
    line = 0
    start = 0

    #             if hasattr(token, "position") and token.position:
    #                 if hasattr(token.position, "line"):
    line = math.subtract(token.position.line, 1  # Convert to 0-based)
    #                 if hasattr(token.position, "column"):
    start = math.subtract(token.position.column, 1  # Convert to 0-based)

    #             # Calculate deltas
    delta_line = math.subtract(line, prev_line)
    #             delta_start = start - prev_start if line == prev_line else start

    #             # Token length
    #             length = len(token.value) if hasattr(token, "value") else 1

                # Add to semantic tokens (simplified format)
    #             # In a real implementation, you'd need to handle more complex scenarios
                semantic_tokens.extend(
    #                 [delta_line, delta_start, length, token_type, 0]  # No modifiers for now
    #             )

    #             # Update previous position
    prev_line = line
    prev_start = math.add(start, length)

    return SemanticTokens(data = semantic_tokens)

    #     def get_semantic_tokens_options(self) -> SemanticTokensOptions:
    #         """
    #         Get options for semantic tokens request.

    #         Returns:
    #             SemanticTokensOptions with configuration
    #         """
    return SemanticTokensOptions(full = True)
