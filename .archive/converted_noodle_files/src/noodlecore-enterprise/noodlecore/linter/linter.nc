# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Main NoodleCore Linter Module
# -----------------------------
# This module provides the main linter class that orchestrates syntax checking,
# semantic analysis, and validation rules for NoodleCore code.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import time
import uuid
import dataclasses.dataclass,
import enum.Enum
import pathlib.Path
import typing.Any,

# Import existing compiler components
import ..compiler.lexer_main.Lexer,
import ..compiler.parser.Parser,
import ..compiler.parser_ast_nodes.ProgramNode
import ..compiler.semantic_analyzer.SemanticAnalyzer
import ..compiler.diagnostics.DiagnosticCollection,
import ..compiler.error_codes.get_error_code_registry,

# Import linter components
import .syntax_checker.SyntaxChecker
import .semantic_analyzer.SemanticAnalyzer
import .validation_rules.ValidationRules,


class LinterMode(Enum)
    #     """Linter operation modes"""
    REAL_TIME = "real_time"  # For IDE integration during typing
    RUNTIME_LOAD = "runtime_load"  # For code execution preparation
    BATCH = "batch"  # For processing multiple files
    STRICT = "strict"  # Most strict validation


# @dataclass
class LinterConfig
    #     """Configuration for the NoodleCore linter"""

    mode: LinterMode = LinterMode.REAL_TIME
    enable_syntax_check: bool = True
    enable_semantic_check: bool = True
    enable_validation_rules: bool = True
    enable_forbidden_structure_check: bool = True
    max_errors: int = 100
    max_warnings: int = 50
    timeout_ms: int = 5000  # 5 seconds
    cache_enabled: bool = True
    strict_mode: bool = False
    custom_rules: List[str] = field(default_factory=list)
    disabled_rules: Set[str] = field(default_factory=set)
    disabled_categories: Set[str] = field(default_factory=set)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert config to dictionary"""
    #         return {
    #             "mode": self.mode.value,
    #             "enable_syntax_check": self.enable_syntax_check,
    #             "enable_semantic_check": self.enable_semantic_check,
    #             "enable_validation_rules": self.enable_validation_rules,
    #             "enable_forbidden_structure_check": self.enable_forbidden_structure_check,
    #             "max_errors": self.max_errors,
    #             "max_warnings": self.max_warnings,
    #             "timeout_ms": self.timeout_ms,
    #             "cache_enabled": self.cache_enabled,
    #             "strict_mode": self.strict_mode,
    #             "custom_rules": self.custom_rules,
                "disabled_rules": list(self.disabled_rules),
                "disabled_categories": list(self.disabled_categories),
    #         }


# @dataclass
class LinterError
    #     """Represents a linter error or warning"""

    #     code: str
    #     message: str
    #     severity: str  # "error", "warning", "info"
    #     category: str
    line: Optional[int] = None
    column: Optional[int] = None
    file: Optional[str] = None
    position: Optional[Any] = None  # Position object from lexer
    suggestion: Optional[str] = None
    related_info: List[str] = field(default_factory=list)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert error to dictionary"""
    #         return {
    #             "code": self.code,
    #             "message": self.message,
    #             "severity": self.severity,
    #             "category": self.category,
    #             "line": self.line,
    #             "column": self.column,
    #             "file": self.file,
    #             "suggestion": self.suggestion,
    #             "related_info": self.related_info,
    #         }


# @dataclass
class LinterResult
    #     """Result of a linter operation"""

    #     success: bool
    errors: List[LinterError] = field(default_factory=list)
    warnings: List[LinterError] = field(default_factory=list)
    infos: List[LinterError] = field(default_factory=list)
    execution_time_ms: int = 0
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))

    #     def has_errors(self) -> bool:
    #         """Check if there are any errors"""
            return len(self.errors) > 0

    #     def has_warnings(self) -> bool:
    #         """Check if there are any warnings"""
            return len(self.warnings) > 0

    #     def get_all_issues(self) -> List[LinterError]:
            """Get all issues (errors, warnings, and infos)"""
    #         return self.errors + self.warnings + self.infos

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert result to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "success": self.success,
    #             "errors": [error.to_dict() for error in self.errors],
    #             "warnings": [warning.to_dict() for warning in self.warnings],
    #             "infos": [info.to_dict() for info in self.infos],
    #             "execution_time_ms": self.execution_time_ms,
                "total_issues": len(self.get_all_issues()),
    #         }


class LinterException(Exception)
    #     """Exception raised by the linter"""

    #     def __init__(self, message: str, code: str = "LINTER_ERROR"):
    self.message = message
    self.code = code
            super().__init__(self.message)


class NoodleLinter
    #     """
    #     Main linter class for NoodleCore code

    #     This class orchestrates syntax checking, semantic analysis, and validation rules
    #     to provide comprehensive validation of NoodleCore code.
    #     """

    #     def __init__(self, config: Optional[LinterConfig] = None):
    #         """Initialize the linter with configuration"""
    self.config = config or LinterConfig()
    self.error_registry = get_error_code_registry()

    #         # Initialize components
    self.syntax_checker = SyntaxChecker()
    self.semantic_analyzer = SemanticAnalyzer()
    self.validation_rules = ValidationRules()

    #         # Performance tracking
    self.stats = {
    #             "files_processed": 0,
    #             "total_errors": 0,
    #             "total_warnings": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Cache for performance
    #         self._parse_cache = {} if self.config.cache_enabled else None

    #         # Apply configuration
            self._apply_config()

    #     def _apply_config(self):
    #         """Apply configuration to components"""
    #         if self.config.strict_mode:
    self.config.enable_syntax_check = True
    self.config.enable_semantic_check = True
    self.config.enable_validation_rules = True
    self.config.enable_forbidden_structure_check = True

    #         # Configure validation rules
            self.validation_rules.configure(
    disabled_rules = self.config.disabled_rules,
    disabled_categories = self.config.disabled_categories,
    custom_rules = self.config.custom_rules,
    #         )

    #     def lint_file(self, file_path: str) -> LinterResult:
    #         """
    #         Lint a NoodleCore file

    #         Args:
    #             file_path: Path to the .nc-code file

    #         Returns:
    #             LinterResult: Result of the linting operation
    #         """
    start_time = time.time()
    result = LinterResult(success=False)

    #         try:
    #             # Read file
    #             with open(file_path, 'r', encoding='utf-8') as f:
    source_code = f.read()

    #             # Lint the source code
    result = self.lint_source(source_code, file_path)

    #         except FileNotFoundError:
                result.errors.append(LinterError(
    code = "E601",
    message = f"File not found: {file_path}",
    severity = "error",
    category = "system",
    file = file_path,
    #             ))
    #         except Exception as e:
                result.errors.append(LinterError(
    code = "E501",
    message = f"Internal linter error: {str(e)}",
    severity = "error",
    category = "compiler",
    file = file_path,
    #             ))

    #         # Update stats
    result.execution_time_ms = math.multiply(int((time.time() - start_time), 1000))
    self.stats["files_processed"] + = 1
    self.stats["total_errors"] + = len(result.errors)
    self.stats["total_warnings"] + = len(result.warnings)
    self.stats["total_time_ms"] + = result.execution_time_ms

    #         return result

    #     def lint_source(self, source_code: str, file_path: Optional[str] = None) -> LinterResult:
    #         """
    #         Lint NoodleCore source code

    #         Args:
    #             source_code: The NoodleCore source code to lint
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             LinterResult: Result of the linting operation
    #         """
    start_time = time.time()
    result = LinterResult(success=True)

    #         try:
    #             # Check cache first
    #             cache_key = hash(source_code) if self.config.cache_enabled else None
    #             if cache_key is not None and self._parse_cache and cache_key in self._parse_cache:
    ast = self._parse_cache[cache_key]
    #             else:
    #                 # Parse the source code
    lexer = Lexer(source_code, file_path)
    parser = Parser(lexer)
    ast = parser.parse()

    #                 # Cache the AST
    #                 if cache_key is not None and self._parse_cache is not None:
    self._parse_cache[cache_key] = ast

    #             # Check for parser errors
    #             if hasattr(parser, 'get_errors'):
    parser_errors = parser.get_errors()
    #                 for error in parser_errors:
                        result.errors.append(LinterError(
    code = "E104",
    message = str(error),
    severity = "error",
    category = "syntax",
    file = file_path,
    #                     ))

    #             # Perform syntax checking
    #             if self.config.enable_syntax_check:
    syntax_result = self.syntax_checker.check(ast, file_path)
                    result.errors.extend(syntax_result.errors)
                    result.warnings.extend(syntax_result.warnings)

    #             # Perform semantic analysis
    #             if self.config.enable_semantic_check:
    semantic_result = self.semantic_analyzer.analyze(ast, file_path)
                    result.errors.extend(semantic_result.errors)
                    result.warnings.extend(semantic_result.warnings)

    #             # Apply validation rules
    #             if self.config.enable_validation_rules:
    validation_result = self.validation_rules.validate(ast, file_path)
                    result.errors.extend(validation_result.errors)
                    result.warnings.extend(validation_result.warnings)
                    result.infos.extend(validation_result.infos)

    #             # Check for forbidden structures
    #             if self.config.enable_forbidden_structure_check:
    forbidden_result = self._check_forbidden_structures(ast, file_path)
                    result.errors.extend(forbidden_result.errors)
                    result.warnings.extend(forbidden_result.warnings)

    #             # Determine success based on errors
    result.success = len(result.errors) == 0

    #             # Apply limits
    #             if len(result.errors) > self.config.max_errors:
    result.errors = result.errors[:self.config.max_errors]
                    result.warnings.append(LinterError(
    code = "W105",
    message = f"Too many errors ({len(result.errors)}), showing only first {self.config.max_errors}",
    severity = "warning",
    category = "linter",
    file = file_path,
    #                 ))

    #             if len(result.warnings) > self.config.max_warnings:
    result.warnings = result.warnings[:self.config.max_warnings]
                    result.infos.append(LinterError(
    code = "I101",
    message = f"Too many warnings ({len(result.warnings)}), showing only first {self.config.max_warnings}",
    severity = "info",
    category = "linter",
    file = file_path,
    #                 ))

    #         except ParserError as e:
                result.errors.append(LinterError(
    code = "E104",
    message = str(e),
    severity = "error",
    category = "syntax",
    file = file_path,
    line = getattr(e, 'line_number', None),
    column = getattr(e, 'column', None),
    #             ))
    result.success = False
    #         except Exception as e:
                result.errors.append(LinterError(
    code = "E501",
    message = f"Internal linter error: {str(e)}",
    severity = "error",
    category = "compiler",
    file = file_path,
    #             ))
    result.success = False

    #         # Calculate execution time
    result.execution_time_ms = math.multiply(int((time.time() - start_time), 1000))

    #         return result

    #     def _check_forbidden_structures(self, ast: ProgramNode, file_path: Optional[str] = None) -> LinterResult:
    #         """
    #         Check for forbidden structures (like Python-like constructs)

    #         Args:
    #             ast: The AST to check
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             LinterResult: Result of the forbidden structure check
    #         """
    result = LinterResult(success=True)

    #         # This would contain specific checks for forbidden structures
    #         # For now, we'll add a placeholder

    #         return result

    #     def lint_directory(self, directory_path: str, pattern: str = "*.nc") -> List[LinterResult]:
    #         """
    #         Lint all NoodleCore files in a directory

    #         Args:
    #             directory_path: Path to the directory
                pattern: File pattern to match (default: "*.nc")

    #         Returns:
    #             List[LinterResult]: Results for each file
    #         """
    results = []
    directory = Path(directory_path)

    #         if not directory.exists():
                return [LinterResult(
    success = False,
    errors = [LinterError(
    code = "E601",
    message = f"Directory not found: {directory_path}",
    severity = "error",
    category = "system",
    #                 )]
    #             )]

    #         for file_path in directory.glob(pattern):
    #             if file_path.is_file():
    result = self.lint_file(str(file_path))
                    results.append(result)

    #         return results

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get linter statistics"""
    #         return {
    #             "files_processed": self.stats["files_processed"],
    #             "total_errors": self.stats["total_errors"],
    #             "total_warnings": self.stats["total_warnings"],
    #             "total_time_ms": self.stats["total_time_ms"],
                "average_time_ms": (
    #                 self.stats["total_time_ms"] / self.stats["files_processed"]
    #                 if self.stats["files_processed"] > 0 else 0
    #             ),
    #             "cache_size": len(self._parse_cache) if self._parse_cache else 0,
                "config": self.config.to_dict(),
    #         }

    #     def clear_cache(self):
    #         """Clear the parse cache"""
    #         if self._parse_cache:
                self._parse_cache.clear()

    #     def reset_statistics(self):
    #         """Reset linter statistics"""
    self.stats = {
    #             "files_processed": 0,
    #             "total_errors": 0,
    #             "total_warnings": 0,
    #             "total_time_ms": 0,
    #         }