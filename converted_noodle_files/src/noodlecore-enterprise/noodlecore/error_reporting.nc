# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Enhanced error reporting system for Noodle compiler.
# """

import typing.Any,
import dataclasses.dataclass
import enum.Enum
import traceback
import sys

import .error_handler.DatabaseError
import .compiler.ast_nodes.ASTNode,


class ErrorSeverity(Enum)
    #     """Error severity levels"""
    ERROR = "ERROR"
    WARNING = "WARNING"
    INFO = "INFO"
    DEBUG = "DEBUG"


class ErrorCategory(Enum)
    #     """Error categories"""
    SYNTAX = "SYNTAX"
    SEMANTIC = "SEMANTIC"
    TYPE = "TYPE"
    RUNTIME = "RUNTIME"
    IMPORT = "IMPORT"
    NAME = "NAME"
    VALUE = "VALUE"
    ATTRIBUTE = "ATTRIBUTE"
    SYSTEM = "SYSTEM"


# @dataclass
class ErrorContext
    #     """Context information for errors"""
    source_code: Optional[str] = None
    filename: Optional[str] = None
    line_number: Optional[int] = None
    column_number: Optional[int] = None
    line_content: Optional[str] = None
    snippet: Optional[str] = None
    stack_trace: Optional[List[str]] = None
    related_nodes: Optional[List[ASTNode]] = None

    #     def get_error_location(self) -> str:
    #         """Get formatted error location"""
    #         if self.filename:
    #             if self.line_number is not None:
    #                 if self.column_number is not None:
    #                     return f"{self.filename}:{self.line_number}:{self.column_number}"
    #                 return f"{self.filename}:{self.line_number}"
    #             return self.filename
    #         return "unknown location"

    #     def get_error_snippet(self) -> str:
    #         """Get error code snippet"""
    #         if not self.source_code or not self.line_number:
    #             return ""

    lines = self.source_code.split('\n')
    #         if 0 <= self.line_number - 1 < len(lines):
    line = math.subtract(lines[self.line_number, 1])

    #             # Highlight error position
    #             if self.column_number is not None:
    #                 if 0 <= self.column_number - 1 < len(line):
    highlight = ' ' * (self.column_number - 1) + '^'
    #                     return f"{line}\n{highlight}"
    #             return line
    #         return ""


# @dataclass
class ReportedError
    #     """Represents a reported error"""
    #     message: str
    #     severity: ErrorSeverity
    #     category: ErrorCategory
    #     context: ErrorContext
    error_code: Optional[str] = None
    suggestion: Optional[str] = None
    original_exception: Optional[Exception] = None

    #     def __str__(self) -> str:
    #         """String representation of the error"""
    result = f"[{self.severity.value}] {self.category.value}: {self.message}"

    #         if self.error_code:
    result = f"[{self.error_code}] {result}"

    #         if self.context.get_error_location():
    result + = f" at {self.context.get_error_location()}"

    #         if self.suggestion:
    result + = f"\n  Suggestion: {self.suggestion}"

    #         if self.context.get_error_snippet():
    result + = f"\n  {self.context.get_error_snippet()}"

    #         if self.original_exception:
    result + = f"\n  Original: {type(self.original_exception).__name__}: {self.original_exception}"

    #         return result


class ErrorReporter
    #     """Centralized error reporting system"""

    #     def __init__(self):
    self.errors: List[ReportedError] = []
    self.warnings: List[ReportedError] = []
    self.max_errors = 100
    self.max_warnings = 100
    self.show_traceback = False

    #     def report_error(
    #         self,
    #         message: str,
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    category: ErrorCategory = ErrorCategory.SYSTEM,
    context: Optional[ErrorContext] = None,
    error_code: Optional[str] = None,
    suggestion: Optional[str] = None,
    original_exception: Optional[Exception] = None
    #     ) -> ReportedError:
    #         """Report an error"""
    #         if context is None:
    context = ErrorContext()

    error = ReportedError(
    message = message,
    severity = severity,
    category = category,
    context = context,
    error_code = error_code,
    suggestion = suggestion,
    original_exception = original_exception
    #         )

    #         if severity == ErrorSeverity.ERROR:
    #             if len(self.errors) >= self.max_errors:
    #                 return error

                self.errors.append(error)
                print(f"ERROR: {error}")
    #         else:
    #             if len(self.warnings) >= self.max_warnings:
    #                 return error

                self.warnings.append(error)
                print(f"WARNING: {error}")

    #         return error

    #     def report_exception(
    #         self,
    #         exception: Exception,
    context: Optional[ErrorContext] = None,
    error_code: Optional[str] = None
    #     ) -> ReportedError:
    #         """Report an exception"""
    #         if context is None:
    context = ErrorContext()

    #         # Get stack trace if enabled
    stack_trace = None
    #         if self.show_traceback:
    stack_trace = traceback.format_exception(
                    type(exception), exception, exception.__traceback__
    #             )
    #             if stack_trace:
    #                 stack_trace = [line.strip() for line in stack_trace]

    #         # Update context with stack trace
    context.stack_trace = stack_trace

    #         # Determine error category based on exception type
    category = ErrorCategory.SYSTEM
    #         if isinstance(exception, CompilationError):
    category = ErrorCategory.SYNTAX
    #         elif isinstance(exception, ImportError):
    category = ErrorCategory.IMPORT
    #         elif isinstance(exception, NameError):
    category = ErrorCategory.NAME
    #         elif isinstance(exception, TypeError):
    category = ErrorCategory.TYPE
    #         elif isinstance(exception, ValueError):
    category = ErrorCategory.VALUE

            return self.report_error(
    message = str(exception),
    severity = ErrorSeverity.ERROR,
    category = category,
    context = context,
    error_code = error_code,
    original_exception = exception
    #         )

    #     def report_syntax_error(
    #         self,
    #         message: str,
    position: Optional[Position] = None,
    filename: Optional[str] = None,
    source_code: Optional[str] = None,
    error_code: Optional[str] = None
    #     ) -> ReportedError:
    #         """Report a syntax error"""
    context = ErrorContext()

    #         if position:
    context.line_number = position.line
    context.column_number = position.column
    #             if source_code:
    context.source_code = source_code
    context.line_content = self._get_line_at_position(source_code, position)

    #         if filename:
    context.filename = filename

            return self.report_error(
    message = message,
    severity = ErrorSeverity.ERROR,
    category = ErrorCategory.SYNTAX,
    context = context,
    error_code = error_code
    #         )

    #     def report_semantic_error(
    #         self,
    #         message: str,
    node: Optional[ASTNode] = None,
    filename: Optional[str] = None,
    source_code: Optional[str] = None,
    suggestion: Optional[str] = None
    #     ) -> ReportedError:
    #         """Report a semantic error"""
    context = ErrorContext()

    #         if node:
    #             if node.position:
    context.line_number = node.position.line
    context.column_number = node.position.column
    #             if source_code:
    context.source_code = source_code
    #                 if node.position:
    context.line_content = self._get_line_at_position(source_code, node.position)

    #         if filename:
    context.filename = filename

            return self.report_error(
    message = message,
    severity = ErrorSeverity.ERROR,
    category = ErrorCategory.SEMANTIC,
    context = context,
    suggestion = suggestion
    #         )

    #     def report_type_error(
    #         self,
    #         message: str,
    node: Optional[ASTNode] = None,
    expected_type: Optional[str] = None,
    actual_type: Optional[str] = None,
    filename: Optional[str] = None,
    source_code: Optional[str] = None
    #     ) -> ReportedError:
    #         """Report a type error"""
    suggestion = None
    #         if expected_type and actual_type:
    suggestion = f"Expected type '{expected_type}', got '{actual_type}'"

    context = ErrorContext()

    #         if node:
    #             if node.position:
    context.line_number = node.position.line
    context.column_number = node.position.column
    #             if source_code:
    context.source_code = source_code
    #                 if node.position:
    context.line_content = self._get_line_at_position(source_code, node.position)

    #         if filename:
    context.filename = filename

            return self.report_error(
    message = message,
    severity = ErrorSeverity.ERROR,
    category = ErrorCategory.TYPE,
    context = context,
    suggestion = suggestion
    #         )

    #     def report_warning(
    #         self,
    #         message: str,
    context: Optional[ErrorContext] = None,
    suggestion: Optional[str] = None
    #     ) -> ReportedError:
    #         """Report a warning"""
            return self.report_error(
    message = message,
    severity = ErrorSeverity.WARNING,
    context = context,
    suggestion = suggestion
    #         )

    #     def has_errors(self) -> bool:
    #         """Check if any errors have been reported"""
            return len(self.errors) > 0

    #     def has_warnings(self) -> bool:
    #         """Check if any warnings have been reported"""
            return len(self.warnings) > 0

    #     def get_errors(self) -> List[ReportedError]:
    #         """Get all reported errors"""
            return self.errors.copy()

    #     def get_warnings(self) -> List[ReportedError]:
    #         """Get all reported warnings"""
            return self.warnings.copy()

    #     def clear(self):
    #         """Clear all reported errors and warnings"""
            self.errors.clear()
            self.warnings.clear()

    #     def get_error_summary(self) -> Dict[str, int]:
    #         """Get summary of reported errors by category"""
    summary = {}
    #         for error in self.errors:
    cat = error.category.value
    summary[cat] = math.add(summary.get(cat, 0), 1)
    #         return summary

    #     def _get_line_at_position(self, source_code: str, position: Position) -> Optional[str]:
    #         """Get line content at given position"""
    lines = source_code.split('\n')
    #         if 0 <= position.line - 1 < len(lines):
    #             return lines[position.line - 1]
    #         return None

    #     def create_context_from_node(
    #         self,
    #         node: ASTNode,
    filename: Optional[str] = None,
    source_code: Optional[str] = None
    #     ) -> ErrorContext:
    #         """Create error context from AST node"""
    context = ErrorContext()

    #         if node.position:
    context.line_number = node.position.line
    context.column_number = node.position.column

    #         if filename:
    context.filename = filename

    #         if source_code:
    context.source_code = source_code
    #             if node.position:
    context.line_content = self._get_line_at_position(source_code, node.position)

    #         return context


# Global error reporter instance
error_reporter = ErrorReporter()


def report_error(
#     message: str,
severity: ErrorSeverity = ErrorSeverity.ERROR,
category: ErrorCategory = ErrorCategory.SYSTEM,
context: Optional[ErrorContext] = None,
error_code: Optional[str] = None,
suggestion: Optional[str] = None,
original_exception: Optional[Exception] = None
# ) -> ReportedError:
#     """Convenience function to report an error"""
    return error_reporter.report_error(
#         message, severity, category, context, error_code, suggestion, original_exception
#     )


def report_exception(
#     exception: Exception,
context: Optional[ErrorContext] = None,
error_code: Optional[str] = None
# ) -> ReportedError:
#     """Convenience function to report an exception"""
    return error_reporter.report_exception(exception, context, error_code)


def report_syntax_error(
#     message: str,
position: Optional[Position] = None,
filename: Optional[str] = None,
source_code: Optional[str] = None,
error_code: Optional[str] = None
# ) -> ReportedError:
#     """Convenience function to report a syntax error"""
    return error_reporter.report_syntax_error(
#         message, position, filename, source_code, error_code
#     )


def report_semantic_error(
#     message: str,
node: Optional[ASTNode] = None,
filename: Optional[str] = None,
source_code: Optional[str] = None,
suggestion: Optional[str] = None
# ) -> ReportedError:
#     """Convenience function to report a semantic error"""
    return error_reporter.report_semantic_error(
#         message, node, filename, source_code, suggestion
#     )


def report_type_error(
#     message: str,
node: Optional[ASTNode] = None,
expected_type: Optional[str] = None,
actual_type: Optional[str] = None,
filename: Optional[str] = None,
source_code: Optional[str] = None
# ) -> ReportedError:
#     """Convenience function to report a type error"""
    return error_reporter.report_type_error(
#         message, node, expected_type, actual_type, filename, source_code
#     )


def report_warning(
#     message: str,
context: Optional[ErrorContext] = None,
suggestion: Optional[str] = None
# ) -> ReportedError:
#     """Convenience function to report a warning"""
    return error_reporter.report_warning(message, context, suggestion)


def get_error_reporter() -> ErrorReporter:
#     """Get the global error reporter instance"""
#     return error_reporter
