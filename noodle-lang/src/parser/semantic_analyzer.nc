# Converted from Python to NoodleCore
# Original file: src

# """
# Semantic Analyzer for Noodle Programming Language
# -------------------------------------------------
# This module implements the semantic analysis phase of the Noodle compiler.
# It performs type checking, symbol resolution, and semantic validation.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import .parser_ast_nodes.ASTNode
import .semantic_analyzer_symbol_table.SymbolTable
import .semantic_analyzer_visitor_pattern.TypeCheckerVisitor


class SemanticError(Exception)
    #     """Exception raised during semantic analysis phase."""

    #     def __init__(self, message: str, node: ASTNode = None, line_number: int = None):
    self.message = message
    self.node = node
    self.line_number = line_number
            super().__init__(self.message)

    #     def __str__(self):
    #         if self.line_number is not None:
    #             return f"SemanticError at line {self.line_number}: {self.message}"
    #         elif self.node and hasattr(self.node, 'position') and self.node.position:
    #             return f"SemanticError at {self.node.position}: {self.message}"
    #         return f"SemanticError: {self.message}"


class SemanticAnalyzer
    #     """Semantic analyzer for the Noodle language"""

    #     def __init__(self):
    self.symbol_table = SymbolTable()
    self.errors = []
    self.warnings = []

    #     def analyze(self, ast: ASTNode) -bool):
    #         """
    #         Perform semantic analysis on the AST.

    #         Args:
    #             ast: The root node of the AST

    #         Returns:
    #             bool: True if analysis succeeded, False if errors were found
    #         """
            self.errors.clear()
            self.warnings.clear()

    #         # Initialize type checker
    type_checker = TypeCheckerVisitor()
    type_checker.symbol_table = self.symbol_table

    #         # Traverse AST with type checker
    #         try:
                type_checker.visit(ast)
                self.errors.extend(type_checker.errors)
    #         except Exception as e:
                self.errors.append(f"Semantic analysis error: {str(e)}")

    return len(self.errors) = = 0

    #     def get_errors(self) -list):
    #         """Get semantic analysis errors"""
    #         return self.errors

    #     def get_warnings(self) -list):
    #         """Get semantic analysis warnings"""
    #         return self.warnings

    #     def add_error(self, message: str):
    #         """Add a semantic error"""
            self.errors.append(message)

    #     def add_warning(self, message: str):
    #         """Add a semantic warning"""
            self.warnings.append(message)

    #     def has_errors(self) -bool):
    #         """Check if there are any semantic errors"""
            return len(self.errors) 0

    #     def has_warnings(self):
    """bool)"""
    #         """Check if there are any semantic warnings"""
            return len(self.warnings) > 0
