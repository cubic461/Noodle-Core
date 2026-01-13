# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Language Server Protocol implementation for Noodle.

# Provides LSP capabilities for IDE integration including diagnostics,
# completion, hover, syntax highlighting, and execution hooks.
# """

import json
import logging
import os
import typing.Any,

# For pygls 1.3.1, we need to use lsprotocol instead of pygls.types
# Note: In lsprotocol 2023.0.1, some constants have slightly different names
try
        from lsprotocol.types import (
    #         TEXT_DOCUMENT_COMPLETION,
    #         TEXT_DOCUMENT_DEFINITION,
    #         TEXT_DOCUMENT_DIAGNOSTICS,
    #         TEXT_DOCUMENT_DID_CHANGE,
    #         TEXT_DOCUMENT_DID_CLOSE,
    #         TEXT_DOCUMENT_DID_OPEN,
    #         TEXT_DOCUMENT_DID_SAVE,
    #         TEXT_DOCUMENT_DOCUMENT_SYMBOL,
    #         TEXT_DOCUMENT_EXECUTE_COMMAND,
    #         TEXT_DOCUMENT_HOVER,
    #         TEXT_DOCUMENT_REFERENCES,
    #         TEXT_DOCUMENT_SEMANTIC_TOKENS_FULL,
    #         CompletionItem,
    #         CompletionList,
    #         CompletionParams,
    #         Diagnostic,
    #         DidChangeTextDocumentParams,
    #         DidOpenTextDocumentParams,
    #         DidSaveTextDocumentParams,
    #         DocumentSymbol,
    #         DocumentSymbolParams,
    #         ExecuteCommandParams,
    #         MarkupContent,
    #         MarkupKind,
    #         Position,
    #         Range,
    #         ReferenceParams,
    #         SemanticTokenModifiers,
    #         SemanticTokens,
    #         SemanticTokensOptions,
    #         SemanticTokensParams,
    #         TextDocumentIdentifier,
    #         TextDocumentPositionParams,
    #     )
except ImportError
    #     # Try alternative names for some constants
    #     try:
    #         from lsprotocol.types import TEXT_DOCUMENT_DIAGNOSTICS  # Alternative name
            from lsprotocol.types import (
    #             TEXT_DOCUMENT_COMPLETION,
    #             TEXT_DOCUMENT_DEFINITION,
    #             TEXT_DOCUMENT_DID_CHANGE,
    #             TEXT_DOCUMENT_DID_CLOSE,
    #             TEXT_DOCUMENT_DID_OPEN,
    #             TEXT_DOCUMENT_DID_SAVE,
    #             TEXT_DOCUMENT_DOCUMENT_SYMBOL,
    #             TEXT_DOCUMENT_EXECUTE_COMMAND,
    #             TEXT_DOCUMENT_HOVER,
    #             TEXT_DOCUMENT_REFERENCES,
    #             TEXT_DOCUMENT_SEMANTIC_TOKENS_FULL,
    #             CompletionItem,
    #             CompletionList,
    #             CompletionParams,
    #             Diagnostic,
    #             DidChangeTextDocumentParams,
    #             DidOpenTextDocumentParams,
    #             DidSaveTextDocumentParams,
    #             DocumentSymbol,
    #             DocumentSymbolParams,
    #             ExecuteCommandParams,
    #             Hover,
    #             MarkupContent,
    #             MarkupKind,
    #             Position,
    #             Range,
    #             ReferenceParams,
    #             SemanticTokens,
    #             SemanticTokensOptions,
    #             SemanticTokensParams,
    #             TextDocumentIdentifier,
    #             TextDocumentPositionParams,
    #         )
    #     except ImportError:
    #         # Fallback for older versions or if lsprotocol not available
            from pygls.types import (
    #             TEXT_DOCUMENT_COMPLETION,
    #             TEXT_DOCUMENT_DEFINITION,
    #             TEXT_DOCUMENT_DIAGNOSTICS,
    #             TEXT_DOCUMENT_DID_CHANGE,
    #             TEXT_DOCUMENT_DID_CLOSE,
    #             TEXT_DOCUMENT_DID_OPEN,
    #             TEXT_DOCUMENT_DID_SAVE,
    #             TEXT_DOCUMENT_DOCUMENT_SYMBOL,
    #             TEXT_DOCUMENT_EXECUTE_COMMAND,
    #             TEXT_DOCUMENT_HOVER,
    #             TEXT_DOCUMENT_REFERENCES,
    #             TEXT_DOCUMENT_SEMANTIC_TOKENS_FULL,
    #             CompletionItem,
    #             CompletionList,
    #             CompletionParams,
    #             Diagnostic,
    #             DidChangeTextDocumentParams,
    #             DidOpenTextDocumentParams,
    #             DidSaveTextDocumentParams,
    #             DocumentSymbol,
    #             DocumentSymbolParams,
    #             ExecuteCommandParams,
    #             Hover,
    #             MarkupContent,
    #             MarkupKind,
    #             Position,
    #             Range,
    #             ReferenceParams,
    #             SemanticTokenModifiers,
    #             SemanticTokens,
    #             SemanticTokensOptions,
    #             SemanticTokensParams,
    #             TextDocumentIdentifier,
    #             TextDocumentPositionParams,
    #         )

try
    #     from lsprotocol import LanguageServerProtocol
    #     from pygls.server import LanguageServer
except ImportError
    #     # Create minimal fallback classes
    #     class LanguageServer:
    #         def __init__(self, name="", version=""):
    self.name = name
    self.version = version
    self._document_cache = {}

    #         def update_document_cache(self, uri, text):
    self._document_cache[uri] = {"text": text}

    #         def get_document_text(self, uri):
                return self._document_cache.get(uri, {}).get("text")

    #         def clear_document_cache(self, uri):
    #             if uri in self._document_cache:
    #                 del self._document_cache[uri]

    #         def publish_diagnostics(self, uri, diagnostics):
    #             pass

    #     class LanguageServerProtocol:
    #         def __init__(self, server):
    self.server = server


function import_from_path(module_name, file_path)
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    #     if spec is None:
    #         return None
    module = importlib.util.module_from_spec(spec)
    #     try:
            spec.loader.exec_module(module)
    #         return module
    #     except Exception as e:
            print(f"❌ Error loading {module_name} from {file_path}: {e}")
    #         return None


import importlib.util

# Importeer compiler componenten
lexer_path = os.path.join(os.path.dirname(__file__), "..", "compiler", "lexer.py")
lexer_module = import_from_path("lexer", lexer_path)
# tokenize = lexer_module.tokenize if lexer_module else None

parser_path = os.path.join(os.path.dirname(__file__), "..", "compiler", "parser.py")
parser_module = None
if os.path.exists(parser_path)
    #     try:
    #         # Use absolute import path
    #         import sys

            sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
    #         from noodlecore.compiler.parser import Parser

    parser_module = type("Module", (), {"Parser": Parser})
    #     except Exception as e:
            print(f"❌ Error loading parser: {e}")
    Parser = None
else
        print(f"❌ Parser file not found: {parser_path}")
    Parser = None

# Importeer LSP componenten
diagnostics_path = os.path.join(os.path.dirname(__file__), "diagnostics.py")
diagnostics_module = None
if os.path.exists(diagnostics_path)
    #     try:
    diagnostics_module = import_from_path("diagnostics", diagnostics_path)
    #     except Exception as e:
            print(f"❌ Error loading diagnostics: {e}")
DiagnosticCollector = (
#     diagnostics_module.DiagnosticCollector if diagnostics_module else None
# )

highlighting_path = os.path.join(os.path.dirname(__file__), "highlighting.py")
highlighting_module = None
if os.path.exists(highlighting_path)
    #     try:
    highlighting_module = import_from_path("highlighting", highlighting_path)
    #     except Exception as e:
            print(f"❌ Error loading highlighting: {e}")
SyntaxHighlighter = (
#     highlighting_module.SyntaxHighlighter if highlighting_module else None
# )

# Import new tree-sitter and execution components
try
    #     from .tree_sitter_integration import TreeSitterHighlighter

    tree_sitter_available = True
except ImportError
    tree_sitter_available = False
    TreeSitterHighlighter = None

try
    #     from .execution_hooks import ExecutionHooks

    execution_hooks_available = True
except ImportError
    execution_hooks_available = False
    ExecutionHooks = None

logger = logging.getLogger(__name__)


class NoodleLanguageServer(LanguageServer)
    #     """Language server for Noodle programming language."""

    #     def __init__(self, *args, **kwargs):
    #         # Initialize with required name and version parameters
            super().__init__("Noodle Language Server", "0.1.0", *args, **kwargs)
    self.diagnostic_collector = (
    #             DiagnosticCollector() if DiagnosticCollector else None
    #         )
    #         self.syntax_highlighter = SyntaxHighlighter() if SyntaxHighlighter else None
    self.tree_sitter_highlighter = (
    #             TreeSitterHighlighter() if tree_sitter_available else None
    #         )
    #         self.execution_hooks = ExecutionHooks() if execution_hooks_available else None
    self._document_cache: Dict[str, Dict[str, Any]] = {}

    #     def update_document_cache(self, uri: str, text: str):
    #         """Update the document cache with new text."""
    self._document_cache[uri] = {
    #             "text": text,
                "version": self._document_cache.get(uri, {}).get("version", 0) + 1,
    #         }

    #     def get_document_text(self, uri: str) -> Optional[str]:
    #         """Get the text for a document."""
            return self._document_cache.get(uri, {}).get("text")

    #     def clear_document_cache(self, uri: str):
    #         """Clear a document from the cache."""
    #         if uri in self._document_cache:
    #             del self._document_cache[uri]


class NoodleLanguageServerProtocol(LanguageServerProtocol)
    #     """LanguageServerProtocol for Noodle language server."""

    #     def __init__(self, server: NoodleLanguageServer):
            super().__init__(server)
    self.server = server

    #     async def process_tokenization(self, uri: str, text: str) -> None:
    #         """Process tokenization and update diagnostics and highlighting."""
    #         if not tokenize or not Parser or not DiagnosticCollector:
    #             logger.error("Required modules not available for tokenization")
    #             return

    #         try:
    #             # Tokenize the document
    tokens = tokenize(text, uri)

                # Parse the document (basic implementation)
    parser = Parser(tokens)
    ast = parser.parse()

    #             # Collect diagnostics
    diagnostics = self.server.diagnostic_collector.collect(tokens, ast)

    #             # Publish diagnostics
                self.server.publish_diagnostics(uri, diagnostics)

    #             # Cache tokens for highlighting
    self.server._document_cache[uri]["tokens"] = tokens

    #         except Exception as e:
                logger.error(f"Error processing document {uri}: {e}")
    #             # Publish error diagnostic
    error_diagnostic = Diagnostic(
    range = Range(
    start = Position(line=0, character=0),
    end = Position(line=0, character=10),
    #                 ),
    severity = 1,  # Error
    message = f"Error processing document: {str(e)}",
    source = "noodle-lsp",
    #             )
                self.server.publish_diagnostics(uri, [error_diagnostic])


# Global server instance
server = NoodleLanguageServer()


@server.feature(TEXT_DOCUMENT_DID_OPEN)
# async def did_open(ls: NoodleLanguageServer, params: DidOpenTextDocumentParams):
#     """Handle text document open event."""
uri = params.text_document.uri
text = params.text_document.text

    logger.info(f"Document opened: {uri}")

#     # Update cache
    ls.update_document_cache(uri, text)

#     # Process tokenization
protocol = NoodleLanguageServerProtocol(ls)
    await protocol.process_tokenization(uri, text)


@server.feature(TEXT_DOCUMENT_DID_CHANGE)
# async def did_change(ls: NoodleLanguageServer, params: DidChangeTextDocumentParams):
#     """Handle text document change event."""
uri = params.text_document.uri
changes = params.content_changes

#     if not changes:
#         return

#     # Get current text
current_text = ls.get_document_text(uri)
#     if current_text is None:
#         return

    # Apply changes (simplified - in real implementation, use proper diff)
new_text = math.subtract(changes[, 1].text)

#     # Update cache
    ls.update_document_cache(uri, new_text)

    logger.info(f"Document changed: {uri}")

#     # Process tokenization
protocol = NoodleLanguageServerProtocol(ls)
    await protocol.process_tokenization(uri, new_text)


@server.feature(TEXT_DOCUMENT_DID_CLOSE)
# async def did_close(ls: NoodleLanguageServer, params: TextDocumentIdentifier):
#     """Handle text document close event."""
uri = params.uri

    logger.info(f"Document closed: {uri}")

#     # Clear cache
    ls.clear_document_cache(uri)

#     # Clear diagnostics
    ls.publish_diagnostics(uri, [])


@server.feature(TEXT_DOCUMENT_DID_SAVE)
# async def did_save(ls: NoodleLanguageServer, params: DidSaveTextDocumentParams):
#     """Handle text document save event."""
uri = params.text_document.uri

    logger.info(f"Document saved: {uri}")

#     # Optional: Trigger additional processing on save
#     # This could include more thorough analysis or compilation


@server.feature(TEXT_DOCUMENT_SEMANTIC_TOKENS_FULL)
# async def semantic_tokens_full(ls: NoodleLanguageServer, params: SemanticTokensParams):
#     """Handle semantic tokens request for syntax highlighting."""
uri = params.text_document.uri

#     # Get cached text
text = ls.get_document_text(uri)
#     if text is None:
return SemanticTokens(data = [])

#     # Use tree-sitter if available for better highlighting
#     if ls.tree_sitter_highlighter:
tree_sitter_tokens = ls.tree_sitter_highlighter.get_highlight_tokens(text)
#         # Convert tree-sitter tokens to LSP format
semantic_data = []
prev_line = 0
prev_start = 0

#         for token in tree_sitter_tokens:
line = token["position"]["line"] - 1  # Convert to 0-based
start = token["position"]["column"] - 1  # Convert to 0-based

delta_line = math.subtract(line, prev_line)
#             delta_start = start - prev_start if line == prev_line else start

            semantic_data.extend(
#                 [
#                     delta_line,
#                     delta_start,
#                     token["length"],
#                     token["type"],
#                     0,  # No modifiers for now
#                 ]
#             )

prev_line = line
prev_start = start + token["length"]

return SemanticTokens(data = semantic_data)
#     else:
#         # Fallback to original syntax highlighter
tokens = ls._document_cache.get(uri, {}).get("tokens", [])
#         if ls.syntax_highlighter:
            return ls.syntax_highlighter.get_semantic_tokens(tokens, text)
#         else:
return SemanticTokens(data = [])


@server.feature(TEXT_DOCUMENT_HOVER)
# async def hover(ls: NoodleLanguageServer, params: TextDocumentPositionParams):
#     """Handle hover request for showing information about symbols."""
uri = params.text_document.uri
position = params.position

#     # Get cached text
text = ls.get_document_text(uri)
#     if text is None:
#         return None

#     # Use tree-sitter for better hover information
#     if ls.tree_sitter_highlighter:
tree_sitter_tokens = ls.tree_sitter_highlighter.get_highlight_tokens(text)

#         # Find token at position
target_line = math.add(position.line, 1  # Convert to 1-based)
target_char = math.add(position.character, 1  # Convert to 1-based)

#         for token in tree_sitter_tokens:
#             if (
token["position"]["line"] = = target_line
and target_char > = token["position"]["column"]
and target_char < = token["position"]["column"] + token["length"]
#             ):

content = f"**{token['type']}**\n\n"
content + = f"Value: `{token['value']}`\n\n"
content + = f"Position: {token['position']['line']}:{token['position']['column']}"

                return Hover(
contents = MarkupContent(kind=MarkupKind.Markdown, value=content),
range = Range(
start = Position(
line = token["position"]["line"] - 1,
character = token["position"]["column"] - 1,
#                         ),
end = Position(
line = token["position"]["line"] - 1,
character = token["position"]["column"] + token["length"] - 1,
#                         ),
#                     ),
#                 )

#         return None
#     else:
#         # Fallback to original hover implementation
tokens = ls._document_cache.get(uri, {}).get("tokens", [])
protocol = NoodleLanguageServerProtocol(ls)
hover_info = protocol._get_hover_info(tokens, position)
#         return hover_info


@server.feature(TEXT_DOCUMENT_COMPLETION)
# async def completion(ls: NoodleLanguageServer, params: CompletionParams):
#     """Handle completion request for code completion."""
uri = params.text_document.uri
position = params.position

#     # Get cached text
text = ls.get_document_text(uri)
#     if text is None:
return CompletionList(is_incomplete = False, items=[])

#     # Use execution hooks for completions
#     if ls.execution_hooks:
completions = ls.execution_hooks.get_completions(
#             text, {"line": position.line, "character": position.character}
#         )

#         # Convert to CompletionItem format
completion_items = []
#         for comp in completions:
            completion_items.append(
                CompletionItem(
label = comp["label"],
kind = comp.get("kind", 1),  # 1 = Text
detail = comp.get("detail", ""),
documentation = comp.get("documentation", ""),
insert_text = comp.get("insertText", comp["label"]),
#                 )
#             )

return CompletionList(is_incomplete = False, items=completion_items)
#     else:
return CompletionList(is_incomplete = False, items=[])


@server.feature(TEXT_DOCUMENT_EXECUTE_COMMAND)
# async def execute_command(ls: NoodleLanguageServer, params: ExecuteCommandParams):
#     """Handle execute command request for code execution."""
#     if params.command == "noodle.execute":
#         # Extract code from arguments
#         code = params.arguments[0] if params.arguments else ""

#         # Execute the code
#         if ls.execution_hooks:
result = ls.execution_hooks.execute_code(code)

#             return {
#                 "success": result["success"],
#                 "output": result["output"],
#                 "error": result["error"],
#                 "execution_time": result["execution_time"],
#             }
#         else:
#             return {
#                 "success": False,
#                 "output": "",
#                 "error": "Execution hooks not available",
#                 "execution_time": 0,
#             }

#     return None


def _get_hover_info(self, tokens: List, position: Position) -> Optional[Hover]:
#     """Get hover information for a specific position."""
#     # Convert to 1-based for comparison with lexer positions
target_line = math.add(position.line, 1)
target_char = math.add(position.character, 1)

#     # Find the token at the position
#     for token in tokens:
#         if (
token.position.line = = target_line
and target_char > = token.position.column
and target_char < = math.add(token.position.column, len(token.value))
#         ):

#             # Generate hover content
content = self._generate_hover_content(token)
            return Hover(
contents = MarkupContent(kind=MarkupKind.Markdown, value=content),
range = Range(
start = Position(
line = math.subtract(token.position.line, 1,)
character = math.subtract(token.position.column, 1,)
#                     ),
end = Position(
line = math.subtract(token.position.line, 1,)
character = math.add(token.position.column, len(token.value) - 1,)
#                     ),
#                 ),
#             )

#     return None


def _generate_hover_content(self, token) -> str:
#     """Generate hover content for a token."""
#     # Basic hover information
content = f"**{token.type.value}**\n\n"
content + = f"Value: `{token.value}`\n\n"

#     # Add position information
content + = f"Position: {token.position.line}:{token.position.column}"

#     # Add specific information for different token types
#     if hasattr(token, "type") and hasattr(token.type, "value"):
#         if token.type.value == "NUMBER":
content + = f"\n\nType: Number"
#         elif token.type.value == "STRING":
content + = f"\n\nType: String"
#         elif token.type.value == "IDENTIFIER":
content + = f"\n\nType: Identifier"
#         elif token.type.value in ["VAR", "FUNC", "IF", "WHILE"]:
content + = f"\n\nType: Keyword"

#     return content


# Add the hover method to the server class
NoodleLanguageServerProtocol._get_hover_info = _get_hover_info
NoodleLanguageServerProtocol._generate_hover_content = _generate_hover_content


function start_server_stdio()
    #     """Start the language server in stdio mode."""
    protocol = NoodleLanguageServerProtocol(server)

    #     # Start the server
        logger.info("Starting Noodle Language Server")
        protocol.start_io()


if __name__ == "__main__"
    #     import sys

    #     # Set up logging
        logging.basicConfig(
    level = logging.INFO,
    format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    #     )

    #     # Start server
        start_server_stdio()
