# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Code completion implementation for Noodle LSP.
# """

import logging
import typing.Any,

# Try to import lsprotocol types first, then fall back to pygls
try
        from lsprotocol.types import (
    #         CompletionItem,
    #         CompletionList,
    #         CompletionOptions,
    #         CompletionParams,
    #         InsertTextFormat,
    #         Position,
    #         TextDocumentIdentifier,
    #     )
except ImportError
    #     try:
            from pygls.types import (
    #             CompletionItem,
    #             CompletionList,
    #             CompletionOptions,
    #             CompletionParams,
    #             InsertTextFormat,
    #             Position,
    #             TextDocumentIdentifier,
    #         )
    #     except ImportError:
    #         # Basic fallback classes
    #         class CompletionItem:
    #             def __init__(
    #                 self,
    label = None,
    kind = 1,
    insert_text = None,
    detail = None,
    documentation = None,
    #             ):
    self.label = label
    self.kind = kind
    self.insert_text = insert_text
    self.detail = detail
    self.documentation = documentation

    #         class CompletionList:
    #             def __init__(self, is_incomplete=False, items=None):
    self.is_incomplete = is_incomplete
    self.items = items or []

    #         class CompletionOptions:
    #             def __init__(self, trigger_characters=None):
    self.trigger_characters = trigger_characters or []

    #         class CompletionParams:
    #             def __init__(self, text_document=None, position=None, context=None):
    self.text_document = text_document
    self.position = position
    self.context = context

    #         class InsertTextFormat:
    #             # Use numeric constants for insert text format
    PlainText = 1
    Snippet = 2

    #         class TextDocumentIdentifier:
    #             def __init__(self, uri=None):
    self.uri = uri

    #         class Position:
    #             def __init__(self, line=None, character=None):
    self.line = line
    self.character = character


logger = logging.getLogger(__name__)


class CompletionProvider
    #     """Handles code completion for Noodle documents."""

    #     def __init__(self):
    #         # Basic keyword completion
    self.keywords = [
    #             "var",
    #             "func",
    #             "if",
    #             "else",
    #             "while",
    #             "for",
    #             "return",
    #             "true",
    #             "false",
    #             "int",
    #             "float",
    #             "string",
    #             "bool",
    #             "matrix",
    #             "vector",
    #             "list",
    #             "dict",
    #             "import",
    #             "from",
    #             "as",
    #             "class",
    #             "extends",
    #             "implements",
    #             "interface",
    #             "public",
    #             "private",
    #             "protected",
    #             "static",
    #             "const",
    #             "final",
    #             "break",
    #             "continue",
    #             "switch",
    #             "case",
    #             "default",
    #             "try",
    #             "catch",
    #             "finally",
    #             "throw",
    #             "new",
    #             "delete",
    #             "sizeof",
    #             "typeof",
    #         ]

    #         # Built-in functions
    self.builtins = {
    #             "print": {
    #                 "label": "print",
    #                 "kind": 3,  # Function
                    "insert_text": "print(${1:value})",
    #                 "detail": "Built-in function",
    #                 "documentation": "Prints the specified value to the console.",
    #             },
    #             "len": {
    #                 "label": "len",
    #                 "kind": 3,  # Function
                    "insert_text": "len(${1:object})",
    #                 "detail": "Built-in function",
    #                 "documentation": "Returns the length of an object.",
    #             },
    #             "typeof": {
    #                 "label": "typeof",
    #                 "kind": 3,  # Function
                    "insert_text": "typeof(${1:expression})",
    #                 "detail": "Built-in function",
    #                 "documentation": "Returns the type of the specified expression.",
    #             },
    #             "sqrt": {
    #                 "label": "sqrt",
    #                 "kind": 3,  # Function
                    "insert_text": "sqrt(${1:value})",
    #                 "detail": "Math function",
    #                 "documentation": "Returns the square root of a number.",
    #             },
    #             "sin": {
    #                 "label": "sin",
    #                 "kind": 3,  # Function
                    "insert_text": "sin(${1:angle})",
    #                 "detail": "Math function",
    #                 "documentation": "Returns the sine of an angle in radians.",
    #             },
    #             "cos": {
    #                 "label": "cos",
    #                 "kind": 3,  # Function
                    "insert_text": "cos(${1:angle})",
    #                 "detail": "Math function",
    #                 "documentation": "Returns the cosine of an angle in radians.",
    #             },
    #             "tan": {
    #                 "label": "tan",
    #                 "kind": 3,  # Function
                    "insert_text": "tan(${1:angle})",
    #                 "detail": "Math function",
    #                 "documentation": "Returns the tangent of an angle in radians.",
    #             },
    #             "matrix": {
    #                 "label": "matrix",
    #                 "kind": 3,  # Function
                    "insert_text": "matrix(${1:rows}, ${2:cols})",
    #                 "detail": "Matrix constructor",
    #                 "documentation": "Creates a new matrix with specified dimensions.",
    #             },
    #             "vector": {
    #                 "label": "vector",
    #                 "kind": 3,  # Function
                    "insert_text": "vector(${1:size})",
    #                 "detail": "Vector constructor",
    #                 "documentation": "Creates a new vector with specified size.",
    #             },
    #         }

    #         # Common types
    self.types = [
    #             {"label": "int", "kind": 13, "detail": "Integer type"},
    #             {"label": "float", "kind": 13, "detail": "Floating-point type"},
    #             {"label": "string", "kind": 13, "detail": "String type"},
    #             {"label": "bool", "kind": 13, "detail": "Boolean type"},
    #             {"label": "matrix", "kind": 13, "detail": "Matrix type"},
    #             {"label": "vector", "kind": 13, "detail": "Vector type"},
    #             {"label": "list", "kind": 13, "detail": "List type"},
    #             {"label": "dict", "kind": 13, "detail": "Dictionary type"},
    #         ]

    #         # Common snippets
    self.snippets = [
    #             {
    #                 "label": "if",
    #                 "kind": 15,  # Snippet
    #                 "insert_text": "if (${1:condition}) {\n    ${2:// code}\n}",
    #                 "detail": "If statement",
    #                 "documentation": "Creates an if statement.",
    #             },
    #             {
    #                 "label": "else",
    #                 "kind": 15,  # Snippet
    #                 "insert_text": "else {\n    ${1:// code}\n}",
    #                 "detail": "Else statement",
    #                 "documentation": "Creates an else statement.",
    #             },
    #             {
    #                 "label": "while",
    #                 "kind": 15,  # Snippet
    #                 "insert_text": "while (${1:condition}) {\n    ${2:// code}\n}",
    #                 "detail": "While loop",
    #                 "documentation": "Creates a while loop.",
    #             },
    #             {
    #                 "label": "for",
    #                 "kind": 15,  # Snippet
    #                 "insert_text": "for (${1:variable} in ${2:collection}) {\n    ${3:// code}\n}",
    #                 "detail": "For loop",
    #                 "documentation": "Creates a for loop.",
    #             },
    #             {
    #                 "label": "func",
    #                 "kind": 15,  # Snippet
                    "insert_text": "func ${1:name}(${2:parameters}) ${3:// return type} {\n    ${4:// body}\n}",
    #                 "detail": "Function definition",
    #                 "documentation": "Defines a new function.",
    #             },
    #             {
    #                 "label": "var",
    #                 "kind": 15,  # Snippet
    "insert_text": "var ${1:name}: ${2:type} = ${3:value}",
    #                 "detail": "Variable declaration",
    #                 "documentation": "Declares a new variable.",
    #             },
    #         ]

    #         # Trigger characters for completion
    self.trigger_characters = [".", " ", "(", "[", "{", ",", ";", ":"]

    #     def get_completion_items(
    #         self, text: str, position: Position, document_uri: str
    #     ) -> CompletionList:
    #         """
    #         Get completion items for the given position in the document.

    #         Args:
    #             text: The text content of the document
    #             position: The cursor position
    #             document_uri: The URI of the document

    #         Returns:
    #             CompletionList with available completion items
    #         """
    #         # Get the current line and character
    line = position.line
    char = position.character

    #         # Extract the text before the cursor
    lines = text.split("\n")
    current_line = math.subtract(lines[min(line, len(lines), 1)])
    text_before_cursor = current_line[:char]

    #         # Determine completion context
    completion_items = []

    #         # Check if we're completing a member access (.)
    #         if text_before_cursor.strip().endswith("."):
    #             # Get member completions for the object
                completion_items.extend(self._get_member_completions(text_before_cursor))
    #         else:
    #             # Get general completions
                completion_items.extend(self.keywords)
                completion_items.extend(self.types)

    #             # Add built-in functions
    #             for key, item in self.builtins.items():
                    completion_items.append(item)

    #             # Add snippets
                completion_items.extend(self.snippets)

    #         # Convert to CompletionItem objects
    items = []
    #         for item in completion_items:
    #             if isinstance(item, str):
                    items.append(
                        CompletionItem(
    label = item,
    kind = 9,  # Keyword
    insert_text = item,
    detail = "Keyword",
    #                     )
    #                 )
    #             elif isinstance(item, dict):
                    items.append(
                        CompletionItem(
    label = item["label"],
    kind = item.get("kind", 9),
    insert_text = item.get("insert_text"),
    detail = item.get("detail"),
    documentation = item.get("documentation"),
    #                     )
    #                 )

    return CompletionList(is_incomplete = False, items=items)

    #     def _get_member_completions(self, text_before_cursor: str) -> List[Dict[str, Any]]:
    #         """
    #         Get member completions for an object.

    #         Args:
    #             text_before_cursor: The text before the cursor

    #         Returns:
    #             List of completion items for object members
    #         """
    #         # Extract the object name
    object_part = text_before_cursor.rsplit(".", 1)[0]

    #         # Simple type-based member completion
    completion_items = []

    #         # Check for matrix operations
    #         if "matrix" in object_part.lower():
    matrix_ops = [
    #                 {"label": "transpose", "kind": 2, "detail": "Matrix operation"},
    #                 {"label": "inverse", "kind": 2, "detail": "Matrix operation"},
    #                 {"label": "determinant", "kind": 2, "detail": "Matrix operation"},
    #                 {"label": "multiply", "kind": 2, "detail": "Matrix operation"},
    #                 {"label": "add", "kind": 2, "detail": "Matrix operation"},
    #                 {"label": "subtract", "kind": 2, "detail": "Matrix operation"},
    #             ]
                completion_items.extend(matrix_ops)

    #         # Check for vector operations
    #         elif "vector" in object_part.lower():
    vector_ops = [
    #                 {"label": "magnitude", "kind": 2, "detail": "Vector operation"},
    #                 {"label": "normalize", "kind": 2, "detail": "Vector operation"},
    #                 {"label": "dot", "kind": 2, "detail": "Vector operation"},
    #                 {"label": "cross", "kind": 2, "detail": "Vector operation"},
    #                 {"label": "add", "kind": 2, "detail": "Vector operation"},
    #                 {"label": "subtract", "kind": 2, "detail": "Vector operation"},
    #             ]
                completion_items.extend(vector_ops)

    #         # Check for list operations
    #         elif "list" in object_part.lower():
    list_ops = [
    #                 {"label": "append", "kind": 2, "detail": "List method"},
    #                 {"label": "insert", "kind": 2, "detail": "List method"},
    #                 {"label": "remove", "kind": 2, "detail": "List method"},
    #                 {"label": "pop", "kind": 2, "detail": "List method"},
    #                 {"label": "length", "kind": 2, "detail": "List property"},
    #                 {"label": "sort", "kind": 2, "detail": "List method"},
    #             ]
                completion_items.extend(list_ops)

    #         return completion_items

    #     def get_completion_options(self) -> CompletionOptions:
    #         """
    #         Get the completion options for the language server.

    #         Returns:
    #             CompletionOptions with trigger characters
    #         """
    return CompletionOptions(trigger_characters = self.trigger_characters)
