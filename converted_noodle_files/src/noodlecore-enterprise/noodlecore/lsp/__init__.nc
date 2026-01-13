# Converted from Python to NoodleCore
# Original file: noodle-core

# """
Noodle Language Server Protocol (LSP) implementation.

# Provides IDE integration with syntax highlighting, diagnostics,
# and language intelligence for VS Code and other editors.
# """

import .diagnostics.DiagnosticCollector
import .highlighting.SyntaxHighlighter
import .server.noodlecorecoreLanguageServer

__all__ = ["NoodleLanguageServer", "DiagnosticCollector", "SyntaxHighlighter"]
