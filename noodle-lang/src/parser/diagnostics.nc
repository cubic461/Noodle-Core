# Converted from Python to NoodleCore
# Original file: src

# """
# Diagnostics and Error Handling for Noodle Compiler
# --------------------------------------------------
# This module provides comprehensive error handling and diagnostic reporting
# for the Noodle compiler components.
# """

import json
import os
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

import ...error.CodeGenerationError

# Import from existing modules
import .ast_nodes.ASTNode
import .lexer.LexerError
import .parser.ParseError
import .semantic_analyzer.SemanticError


class DiagnosticSeverity(Enum)
    #     """Severity levels for diagnostics"""

    ERROR = "error"
    WARNING = "warning"
    INFO = "info"
    HINT = "hint"


class DiagnosticCategory(Enum)
    #     """Categories for diagnostics"""

    SYNTAX = "syntax"
    SEMANTIC = "semantic"
    TYPE_CHECKING = "type_checking"
    CODE_GENERATION = "code_generation"
    LEXICAL = "lexical"
    PERFORMANCE = "performance"
    SECURITY = "security"
    STYLE = "style"
    DEPRECATION = "deprecation"
    GENERAL = "general"


dataclass
class Diagnostic
    #     """Represents a diagnostic message"""

    #     severity: DiagnosticSeverity
    #     category: DiagnosticCategory
    #     message: str
    position: Optional[Position] = None
    code: Optional[str] = None
    file: Optional[str] = None
    related_diagnostics: List["Diagnostic"] = field(default_factory=list)
    actions: List[str] = field(default_factory=list)
    data: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert diagnostic to dictionary"""
    #         return {
    #             "severity": self.severity.value,
    #             "category": self.category.value,
    #             "message": self.message,
                "position": (
    #                 {
    #                     "line": self.position.line if self.position else None,
    #                     "column": self.position.column if self.position else None,
    #                     "offset": self.position.offset if self.position else None,
    #                 }
    #                 if self.position
    #                 else None
    #             ),
    #             "code": self.code,
    #             "file": self.file,
    #             "related_diagnostics": [
    #                 diag.to_dict() for diag in self.related_diagnostics
    #             ],
    #             "actions": self.actions,
    #             "data": self.data,
    #         }

    #     def to_json(self) -str):
    #         """Convert diagnostic to JSON string"""
    return json.dumps(self.to_dict(), indent = 2)

    #     def __str__(self) -str):
    #         """String representation of diagnostic"""
    parts = []

    #         if self.file:
                parts.append(f"File: {self.file}")

    #         if self.position:
                parts.append(f"Line {self.position.line}, Column {self.position.column}")

    #         if self.code:
                parts.append(f"({self.code})")

            parts.append(f"{self.severity.value.upper()}: {self.message}")

            return " | ".join(parts)


class DiagnosticCollection
    #     """Collection of diagnostics with filtering and grouping capabilities"""

    #     def __init__(self):
    self.diagnostics: List[Diagnostic] = []
    self.file_diagnostics: Dict[str, List[Diagnostic]] = {}
    self.severity_counts: Dict[DiagnosticSeverity, int] = {
    #             DiagnosticSeverity.ERROR: 0,
    #             DiagnosticSeverity.WARNING: 0,
    #             DiagnosticSeverity.INFO: 0,
    #             DiagnosticSeverity.HINT: 0,
    #         }
    self.category_counts: Dict[DiagnosticCategory, int] = {
    #             category: 0 for category in DiagnosticCategory
    #         }

    #     def add(self, diagnostic: Diagnostic):
    #         """Add a diagnostic to the collection"""
            self.diagnostics.append(diagnostic)

    #         # Update file diagnostics
    #         if diagnostic.file:
    #             if diagnostic.file not in self.file_diagnostics:
    self.file_diagnostics[diagnostic.file] = []
                self.file_diagnostics[diagnostic.file].append(diagnostic)

    #         # Update severity counts
    self.severity_counts[diagnostic.severity] + = 1

    #         # Update category counts
    self.category_counts[diagnostic.category] + = 1

    #     def add_error(
    #         self,
    #         message: str,
    position: Optional[Position] = None,
    file: Optional[str] = None,
    category: DiagnosticCategory = DiagnosticCategory.GENERAL,
    code: Optional[str] = None,
    #         **kwargs,
    #     ):
    #         """Add an error diagnostic"""
    diagnostic = Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = category,
    message = message,
    position = position,
    file = file,
    code = code,
    #             **kwargs,
    #         )
            self.add(diagnostic)

    #     def add_warning(
    #         self,
    #         message: str,
    position: Optional[Position] = None,
    file: Optional[str] = None,
    category: DiagnosticCategory = DiagnosticCategory.GENERAL,
    code: Optional[str] = None,
    #         **kwargs,
    #     ):
    #         """Add a warning diagnostic"""
    diagnostic = Diagnostic(
    severity = DiagnosticSeverity.WARNING,
    category = category,
    message = message,
    position = position,
    file = file,
    code = code,
    #             **kwargs,
    #         )
            self.add(diagnostic)

    #     def add_info(
    #         self,
    #         message: str,
    position: Optional[Position] = None,
    file: Optional[str] = None,
    category: DiagnosticCategory = DiagnosticCategory.GENERAL,
    code: Optional[str] = None,
    #         **kwargs,
    #     ):
    #         """Add an info diagnostic"""
    diagnostic = Diagnostic(
    severity = DiagnosticSeverity.INFO,
    category = category,
    message = message,
    position = position,
    file = file,
    code = code,
    #             **kwargs,
    #         )
            self.add(diagnostic)

    #     def add_hint(
    #         self,
    #         message: str,
    position: Optional[Position] = None,
    file: Optional[str] = None,
    category: DiagnosticCategory = DiagnosticCategory.GENERAL,
    code: Optional[str] = None,
    #         **kwargs,
    #     ):
    #         """Add a hint diagnostic"""
    diagnostic = Diagnostic(
    severity = DiagnosticSeverity.HINT,
    category = category,
    message = message,
    position = position,
    file = file,
    code = code,
    #             **kwargs,
    #         )
            self.add(diagnostic)

    #     def get_errors(self) -List[Diagnostic]):
    #         """Get all error diagnostics"""
    #         return [
    #             diag
    #             for diag in self.diagnostics
    #             if diag.severity == DiagnosticSeverity.ERROR
    #         ]

    #     def get_warnings(self) -List[Diagnostic]):
    #         """Get all warning diagnostics"""
    #         return [
    #             diag
    #             for diag in self.diagnostics
    #             if diag.severity == DiagnosticSeverity.WARNING
    #         ]

    #     def get_infos(self) -List[Diagnostic]):
    #         """Get all info diagnostics"""
    #         return [
    #             diag
    #             for diag in self.diagnostics
    #             if diag.severity == DiagnosticSeverity.INFO
    #         ]

    #     def get_hints(self) -List[Diagnostic]):
    #         """Get all hint diagnostics"""
    #         return [
    #             diag
    #             for diag in self.diagnostics
    #             if diag.severity == DiagnosticSeverity.HINT
    #         ]

    #     def get_by_file(self, file: str) -List[Diagnostic]):
    #         """Get diagnostics for a specific file"""
            return self.file_diagnostics.get(file, [])

    #     def get_by_category(self, category: DiagnosticCategory) -List[Diagnostic]):
    #         """Get diagnostics by category"""
    #         return [diag for diag in self.diagnostics if diag.category == category]

    #     def get_by_severity(self, severity: DiagnosticSeverity) -List[Diagnostic]):
    #         """Get diagnostics by severity"""
    #         return [diag for diag in self.diagnostics if diag.severity == severity]

    #     def has_errors(self) -bool):
    #         """Check if there are any errors"""
    #         return self.severity_counts[DiagnosticSeverity.ERROR] 0

    #     def has_warnings(self):
    """bool)"""
    #         """Check if there are any warnings"""
    #         return self.severity_counts[DiagnosticSeverity.WARNING] 0

    #     def has_infos(self):
    """bool)"""
    #         """Check if there are any infos"""
    #         return self.severity_counts[DiagnosticSeverity.INFO] 0

    #     def has_hints(self):
    """bool)"""
    #         """Check if there are any hints"""
    #         return self.severity_counts[DiagnosticSeverity.HINT] 0

    #     def is_empty(self):
    """bool)"""
    #         """Check if the collection is empty"""
    return len(self.diagnostics) = = 0

    #     def clear(self):
    #         """Clear all diagnostics"""
            self.diagnostics.clear()
            self.file_diagnostics.clear()
    self.severity_counts = {
    #             DiagnosticSeverity.ERROR: 0,
    #             DiagnosticSeverity.WARNING: 0,
    #             DiagnosticSeverity.INFO: 0,
    #             DiagnosticSeverity.HINT: 0,
    #         }
    #         self.category_counts = {category: 0 for category in DiagnosticCategory}

    #     def merge(self, other: "DiagnosticCollection"):
    #         """Merge another diagnostic collection"""
    #         for diagnostic in other.diagnostics:
                self.add(diagnostic)

    #     def to_json(self) -str):
    #         """Convert collection to JSON string"""
    #         return json.dumps([diag.to_dict() for diag in self.diagnostics], indent=2)

    #     def to_report(self) -str):
    #         """Generate a human-readable report"""
    #         if self.is_empty():
    #             return "No diagnostics found."

    lines = []
    lines.append(" = == Diagnostic Report ===")
            lines.append(f"Total: {len(self.diagnostics)}")
            lines.append(f"Errors: {self.severity_counts[DiagnosticSeverity.ERROR]}")
            lines.append(f"Warnings: {self.severity_counts[DiagnosticSeverity.WARNING]}")
            lines.append(f"Infos: {self.severity_counts[DiagnosticSeverity.INFO]}")
            lines.append(f"Hints: {self.severity_counts[DiagnosticSeverity.HINT]}")
            lines.append("")

    #         # Group by file
    #         for file, file_diags in self.file_diagnostics.items():
                lines.append(f"File: {file}")
    #             for diag in file_diags:
                    lines.append(f"  {diag}")
                lines.append("")

    #         # Group by category
    #         for category, count in self.category_counts.items():
    #             if count 0):
                    lines.append(f"{category.value.title()}: {count}")

            return "\n".join(lines)

    #     def __len__(self) -int):
    #         """Get the number of diagnostics"""
            return len(self.diagnostics)

    #     def __bool__(self) -bool):
    #         """Check if the collection is non-empty"""
            return len(self.diagnostics) 0


class DiagnosticReporter
    #     """Reports diagnostics to various output formats"""

    #     def __init__(self, output_format): str = "console"):
    self.output_format = output_format
    self.collections: Dict[str, DiagnosticCollection] = {}

    #     def create_collection(self, name: str) -DiagnosticCollection):
    #         """Create a new diagnostic collection"""
    collection = DiagnosticCollection()
    self.collections[name] = collection
    #         return collection

    #     def get_collection(self, name: str) -Optional[DiagnosticCollection]):
    #         """Get a diagnostic collection by name"""
            return self.collections.get(name)

    #     def report(self, collection_name: str, output_file: Optional[str] = None):
    #         """Report diagnostics from a collection"""
    collection = self.get_collection(collection_name)
    #         if not collection:
    #             return

    #         if self.output_format == "console":
                self._report_console(collection)
    #         elif self.output_format == "json":
                self._report_json(collection, output_file)
    #         elif self.output_format == "file":
                self._report_file(collection, output_file)
    #         else:
                raise ValueError(f"Unsupported output format: {self.output_format}")

    #     def _report_console(self, collection: DiagnosticCollection):
    #         """Report diagnostics to console"""
            print(collection.to_report())

    #     def _report_json(
    self, collection: DiagnosticCollection, output_file: Optional[str] = None
    #     ):
    #         """Report diagnostics as JSON"""
    json_output = collection.to_json()

    #         if output_file:
    #             with open(output_file, "w") as f:
                    f.write(json_output)
    #         else:
                print(json_output)

    #     def _report_file(
    self, collection: DiagnosticCollection, output_file: Optional[str] = None
    #     ):
    #         """Report diagnostics to a file"""
    #         if not output_file:
    output_file = "diagnostics.txt"

    #         with open(output_file, "w") as f:
                f.write(collection.to_report())

    #     def clear_collection(self, name: str):
    #         """Clear a diagnostic collection"""
    collection = self.get_collection(name)
    #         if collection:
                collection.clear()

    #     def clear_all(self):
    #         """Clear all diagnostic collections"""
    #         for collection in self.collections.values():
                collection.clear()


class ErrorConverter
    #     """Converts various error types to diagnostics"""

    #     @staticmethod
    #     def convert_lexer_error(
    error: LexerError, file: Optional[str] = None
    #     ) -Diagnostic):
    #         """Convert a LexerError to a Diagnostic"""
            return Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = DiagnosticCategory.LEXICAL,
    message = error.message,
    position = error.position,
    file = file,
    code = "LEXER_ERROR",
    #         )

    #     @staticmethod
    #     def convert_parse_error(
    error: ParseError, file: Optional[str] = None
    #     ) -Diagnostic):
    #         """Convert a ParseError to a Diagnostic"""
            return Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = DiagnosticCategory.SYNTAX,
    message = error.message,
    position = error.position,
    file = file,
    code = "PARSE_ERROR",
    #         )

    #     @staticmethod
    #     def convert_semantic_error(
    error: SemanticError, file: Optional[str] = None
    #     ) -Diagnostic):
    #         """Convert a SemanticError to a Diagnostic"""
            return Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = DiagnosticCategory.SEMANTIC,
    message = error.message,
    position = error.position,
    file = file,
    code = "SEMANTIC_ERROR",
    #         )

    #     @staticmethod
    #     def convert_compiler_error(
    error: CompilerError, file: Optional[str] = None
    #     ) -Diagnostic):
    #         """Convert a CompilerError to a Diagnostic"""
            return Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = DiagnosticCategory.GENERAL,
    message = error.message,
    position = getattr(error, "position", None),
    file = file,
    code = "COMPILER_ERROR",
    #         )

    #     @staticmethod
    #     def convert_code_generation_error(
    error: CodeGenerationError, file: Optional[str] = None
    #     ) -Diagnostic):
    #         """Convert a CodeGenerationError to a Diagnostic"""
            return Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = DiagnosticCategory.CODE_GENERATION,
    message = error.message,
    position = getattr(error, "position", None),
    file = file,
    code = "CODEGEN_ERROR",
    #         )


class DiagnosticEngine
    #     """Main diagnostic engine for the compiler"""

    #     def __init__(self, reporter: DiagnosticReporter):
    self.reporter = reporter
    self.error_converter = ErrorConverter()
    self.active_collection: Optional[str] = None

    #     def start_collection(self, name: str) -DiagnosticCollection):
    #         """Start a new diagnostic collection"""
    collection = self.reporter.create_collection(name)
    self.active_collection = name
    #         return collection

    #     def get_active_collection(self) -Optional[DiagnosticCollection]):
    #         """Get the active diagnostic collection"""
    #         if self.active_collection:
                return self.reporter.get_collection(self.active_collection)
    #         return None

    #     def end_collection(self):
    #         """End the current diagnostic collection"""
    self.active_collection = None

    #     def report_errors(self, collection_name: str):
    #         """Report errors from a collection"""
            self.reporter.report(collection_name)

    #     def clear_errors(self, collection_name: str):
    #         """Clear errors from a collection"""
            self.reporter.clear_collection(collection_name)

    #     def clear_all_errors(self):
    #         """Clear all errors"""
            self.reporter.clear_all()

    #     def convert_and_add_error(self, error: Exception, file: Optional[str] = None):
    #         """Convert an error to a diagnostic and add it to the active collection"""
    collection = self.get_active_collection()
    #         if not collection:
    #             return

    #         if isinstance(error, LexerError):
    diagnostic = self.error_converter.convert_lexer_error(error, file)
    #         elif isinstance(error, ParseError):
    diagnostic = self.error_converter.convert_parse_error(error, file)
    #         elif isinstance(error, SemanticError):
    diagnostic = self.error_converter.convert_semantic_error(error, file)
    #         elif isinstance(error, CompilerError):
    diagnostic = self.error_converter.convert_compiler_error(error, file)
    #         elif isinstance(error, CodeGenerationError):
    diagnostic = self.error_converter.convert_code_generation_error(error, file)
    #         else:
    #             # Generic error
    diagnostic = Diagnostic(
    severity = DiagnosticSeverity.ERROR,
    category = DiagnosticCategory.GENERAL,
    message = str(error),
    file = file,
    code = "UNKNOWN_ERROR",
    #             )

            collection.add(diagnostic)

    #     def validate_ast(
    self, node: ASTNode, file: Optional[str] = None
    #     ) -DiagnosticCollection):
    #         """Validate an AST and return diagnostics"""
    collection = self.start_collection(f"ast_validation_{id(node)}")

    #         # Perform AST validation
            self._validate_ast_node(node, collection, file)

    #         return collection

    #     def _validate_ast_node(
    #         self,
    #         node: ASTNode,
    #         collection: DiagnosticCollection,
    file: Optional[str] = None,
    #     ):
    #         """Validate an AST node and its children"""
    #         # Check for missing required fields
    #         if hasattr(node, "position") and not node.position:
                collection.add_warning(
    #                 f"Node {node.node_type.value} is missing position information",
    file = file,
    category = DiagnosticCategory.SYNTAX,
    #             )

    #         # Check for invalid node states
    #         if hasattr(node, "children") and node.children is None:
                collection.add_warning(
    #                 f"Node {node.node_type.value} has None children",
    file = file,
    category = DiagnosticCategory.SEMANTIC,
    #             )

    #         # Recursively validate children
    #         for child in node.get_children():
    #             if isinstance(child, ASTNode):
                    self._validate_ast_node(child, collection, file)

    #     def validate_symbol_table(
    self, symbol_table, file: Optional[str] = None
    #     ) -DiagnosticCollection):
    #         """Validate a symbol table and return diagnostics"""
    collection = self.start_collection(
                f"symbol_table_validation_{id(symbol_table)}"
    #         )

    #         # Perform symbol table validation
            self._validate_symbol_table(symbol_table, collection, file)

    #         return collection

    #     def _validate_symbol_table(
    self, symbol_table, collection: DiagnosticCollection, file: Optional[str] = None
    #     ):
    #         """Validate a symbol table"""
    #         # This would contain detailed validation logic for symbol tables
    #         # For now, we'll just add a placeholder
            collection.add_info(
    #             "Symbol table validation placeholder",
    file = file,
    category = DiagnosticCategory.SEMANTIC,
    #         )

    #     def validate_bytecode(
    self, bytecode: bytes, file: Optional[str] = None
    #     ) -DiagnosticCollection):
    #         """Validate bytecode and return diagnostics"""
    collection = self.start_collection(f"bytecode_validation_{id(bytecode)}")

    #         # Perform bytecode validation
            self._validate_bytecode(bytecode, collection, file)

    #         return collection

    #     def _validate_bytecode(
    #         self,
    #         bytecode: bytes,
    #         collection: DiagnosticCollection,
    file: Optional[str] = None,
    #     ):
    #         """Validate bytecode"""
    #         # Check for empty bytecode
    #         if len(bytecode) == 0:
                collection.add_error(
    #                 "Bytecode is empty",
    file = file,
    category = DiagnosticCategory.CODE_GENERATION,
    #             )
    #             return

    #         # Check for minimum valid bytecode size
    #         if len(bytecode) < 4:
                collection.add_error(
    #                 "Bytecode is too small to be valid",
    file = file,
    category = DiagnosticCategory.CODE_GENERATION,
    #             )
    #             return

    #         # Check for valid magic number (if applicable)
    #         # This would be specific to the NBC bytecode format

            collection.add_info(
    #             "Bytecode validation completed",
    file = file,
    category = DiagnosticCategory.CODE_GENERATION,
    #         )
