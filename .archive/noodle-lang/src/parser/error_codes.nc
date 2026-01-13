# Converted from Python to NoodleCore
# Original file: src

# """
# Error codes for Noodle compiler.
# Provides standardized error codes for all compilation errors.
# """

import typing.Dict
from dataclasses import dataclass
import enum.Enum
import re


class ErrorCategory(Enum)
    #     """Main error categories"""
    SYNTAX = "SYNTAX"
    SEMANTIC = "SEMANTIC"
    TYPE = "TYPE"
    RUNTIME = "RUNTIME"
    COMPILER = "COMPILER"
    SYSTEM = "SYSTEM"
    SECURITY = "SECURITY"
    PERFORMANCE = "PERFORMANCE"
    WARNING = "WARNING"


dataclass
class ErrorCode
    #     """Represents a standardized error code"""
        code: str  # Short code (e.g., "E001")
    #     category: ErrorCategory
    #     message: str  # Template message
    severity: str = "ERROR"  # ERROR, WARNING, INFO
    description: str = ""
    suggestion: str = ""
    examples: List[str] = field(default_factory=list)
    related_codes: List[str] = field(default_factory=list)
    since_version: str = "1.0.0"
    deprecated: bool = False

    #     def format_message(self, **kwargs) -str):
    #         """Format the error message with provided arguments"""
    #         try:
                return self.message.format(**kwargs)
    #         except KeyError as e:
    #             return f"{self.message} [Missing parameter: {e}]"


class ErrorCodeRegistry
    #     """Registry for all error codes"""

    #     def __init__(self):
    self.error_codes: Dict[str, ErrorCode] = {}
    self.category_codes: Dict[ErrorCategory, List[ErrorCode]] = {}
            self._initialize_error_codes()

    #     def _initialize_error_codes(self):
    #         """Initialize all error codes"""
            # Syntax Errors (E1xx)
            self.register_error_code(ErrorCode(
    code = "E101",
    category = ErrorCategory.SYNTAX,
    message = "Unexpected token '{token}' at line {line}, column {column}",
    severity = "ERROR",
    description = "An unexpected token was encountered during parsing",
    #             suggestion="Check if the token is correct and properly placed",
    examples = [
    #                 "Unexpected token '}' at line 5, column 10",
    #                 "Unexpected token 'else' at line 8, column 4"
    #             ],
    related_codes = ["E102", "E103"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E102",
    category = ErrorCategory.SYNTAX,
    message = "Missing '{expected_token}' before '{actual_token}' at line {line}",
    severity = "ERROR",
    description = "A required token is missing",
    suggestion = "Insert the missing token in the correct position",
    examples = [
    #                 "Missing ';' before '}' at line 5",
    #                 "Missing ')' before '{' at line 8"
    #             ],
    related_codes = ["E101", "E103"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E103",
    category = ErrorCategory.SYNTAX,
    message = "Unterminated {structure} starting at line {start_line}",
    severity = "ERROR",
    description = "A structure (string, comment, bracket) is not properly closed",
    suggestion = "Add the closing token to terminate the structure",
    examples = [
    #                 "Unterminated string starting at line 5",
    #                 "Unterminated comment starting at line 8"
    #             ],
    related_codes = ["E101", "E104"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E104",
    category = ErrorCategory.SYNTAX,
    message = "Invalid syntax at line {line}: {details}",
    severity = "ERROR",
    description = "General syntax error",
    suggestion = "Check the syntax around the reported line",
    examples = [
    #                 "Invalid syntax at line 5: Expected expression",
    #                 "Invalid syntax at line 8: Unexpected end of input"
    #             ],
    related_codes = ["E101", "E102"],
    since_version = "1.0.0"
    #         ))

            # Semantic Errors (E2xx)
            self.register_error_code(ErrorCode(
    code = "E201",
    category = ErrorCategory.SEMANTIC,
    message = "Redeclaration of variable '{variable_name}' at line {line}",
    severity = "ERROR",
    description = "A variable is being declared more than once in the same scope",
    suggestion = "Rename the variable or remove the duplicate declaration",
    examples = [
    #                 "Redeclaration of variable 'count' at line 5",
    #                 "Redeclaration of variable 'temp' at line 12"
    #             ],
    related_codes = ["E202", "E203"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E202",
    category = ErrorCategory.SEMANTIC,
    message = "Undeclared variable '{variable_name}' at line {line}",
    severity = "ERROR",
    description = "Use of an undeclared variable",
    suggestion = "Declare the variable before using it",
    examples = [
    #                 "Undeclared variable 'result' at line 5",
    #                 "Undeclared variable 'data' at line 8"
    #             ],
    related_codes = ["E201", "E204"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E203",
    category = ErrorCategory.SEMANTIC,
    message = "Variable '{variable_name}' used before initialization at line {line}",
    severity = "ERROR",
    description = "A variable is used before it has been assigned a value",
    suggestion = "Initialize the variable before using it",
    examples = [
    #                 "Variable 'x' used before initialization at line 5",
    #                 "Variable 'value' used before initialization at line 3"
    #             ],
    related_codes = ["E201", "E205"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E204",
    category = ErrorCategory.SEMANTIC,
    message = "Function '{function_name}' not found at line {line}",
    severity = "ERROR",
    description = "Call to an undefined function",
    suggestion = "Check the function name or define the function",
    examples = [
    #                 "Function 'calculate_average' not found at line 5",
    #                 "Function 'process_data' not found at line 8"
    #             ],
    related_codes = ["E205", "E206"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E205",
    category = ErrorCategory.SEMANTIC,
    message = "Too many arguments to function '{function_name}' at line {line}",
    severity = "ERROR",
    #             description="Function call with more arguments than expected",
    suggestion = "Remove extra arguments or check function definition",
    examples = [
    #                 "Too many arguments to function 'add' at line 5",
    #                 "Too many arguments to function 'process' at line 8"
    #             ],
    related_codes = ["E204", "E206"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E206",
    category = ErrorCategory.SEMANTIC,
    message = "Too few arguments to function '{function_name}' at line {line}",
    severity = "ERROR",
    #             description="Function call with fewer arguments than expected",
    suggestion = "Add missing arguments or check function definition",
    examples = [
    #                 "Too few arguments to function 'add' at line 5",
    #                 "Too few arguments to function 'process' at line 8"
    #             ],
    related_codes = ["E204", "E205"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E207",
    category = ErrorCategory.SEMANTIC,
    message = "Return statement outside function at line {line}",
    severity = "ERROR",
    description = "A return statement is used outside of a function",
    suggestion = "Move the return statement inside a function or remove it",
    examples = [
    #                 "Return statement outside function at line 5",
    #                 "Return statement outside function at line 12"
    #             ],
    related_codes = ["E208"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E208",
    category = ErrorCategory.SEMANTIC,
    message = "Function '{function_name}' should return a value at line {line}",
    severity = "ERROR",
    description = "A function that is declared to return a value doesn't",
    suggestion = "Add a return statement or change the function declaration",
    examples = [
    #                 "Function 'calculate' should return a value at line 5",
    #                 "Function 'get_value' should return a value at line 8"
    #             ],
    related_codes = ["E207"],
    since_version = "1.0.0"
    #         ))

            # Type Errors (E3xx)
            self.register_error_code(ErrorCode(
    code = "E301",
    category = ErrorCategory.TYPE,
    message = "Type mismatch: expected '{expected_type}', got '{actual_type}' at line {line}",
    severity = "ERROR",
    description = "A value of one type is used where another type is expected",
    suggestion = "Convert the value to the expected type or change the expected type",
    examples = [
    #                 "Type mismatch: expected 'int', got 'string' at line 5",
    #                 "Type mismatch: expected 'float', got 'bool' at line 8"
    #             ],
    related_codes = ["E302", "E303"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E302",
    category = ErrorCategory.TYPE,
    message = "Cannot convert type '{from_type}' to '{to_type}' at line {line}",
    severity = "ERROR",
    description = "An explicit type conversion is not possible",
    #             suggestion="Check if the conversion is valid or use a different approach",
    examples = [
    #                 "Cannot convert type 'string' to 'list' at line 5",
    #                 "Cannot convert type 'bool' to 'function' at line 8"
    #             ],
    related_codes = ["E301", "E303"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E303",
    category = ErrorCategory.TYPE,
    #             message="Operation '{operation}' not supported for types '{type1}' and '{type2}' at line {line}",
    severity = "ERROR",
    #             description="An operation is not valid for the given types",
    suggestion = "Use compatible types or a different operation",
    examples = [
    #                 "Operation '+' not supported for types 'string' and 'int' at line 5",
    #                 "Operation '==' not supported for types 'function' and 'list' at line 8"
    #             ],
    related_codes = ["E301", "E302"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E304",
    category = ErrorCategory.TYPE,
    message = "Generic type '{type_name}' missing type parameters at line {line}",
    severity = "ERROR",
    description = "A generic type is used without type parameters",
    suggestion = "Provide type parameters or use a concrete type",
    examples = [
    #                 "Generic type 'List' missing type parameters at line 5",
    #                 "Generic type 'Dict' missing type parameters at line 8"
    #             ],
    related_codes = ["E305"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E305",
    category = ErrorCategory.TYPE,
    #             message="Too many type arguments for generic type '{type_name}' at line {line}",
    severity = "ERROR",
    #             description="A generic type is provided with too many type arguments",
    suggestion = "Remove extra type arguments or check the type definition",
    examples = [
    #                 "Too many type arguments for generic type 'List' at line 5",
    #                 "Too many type arguments for generic type 'Dict' at line 8"
    #             ],
    related_codes = ["E304"],
    since_version = "1.0.0"
    #         ))

            # Runtime Errors (E4xx)
            self.register_error_code(ErrorCode(
    code = "E401",
    category = ErrorCategory.RUNTIME,
    message = "Division by zero at line {line}",
    severity = "ERROR",
    description = "An attempt to divide by zero was detected",
    suggestion = "Add a check to prevent division by zero",
    examples = [
    #                 "Division by zero at line 5",
    #                 "Division by zero at line 12"
    #             ],
    related_codes = ["E402"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E402",
    category = ErrorCategory.RUNTIME,
    message = "Index out of bounds at line {line}: index {index}, size {size}",
    severity = "ERROR",
    description = "Array or list index is outside the valid range",
    suggestion = "Check the index bounds before accessing",
    examples = [
    #                 "Index out of bounds at line 5: index 10, size 5",
    #                 "Index out of bounds at line 12: index -1, size 3"
    #             ],
    related_codes = ["E401", "E403"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E403",
    category = ErrorCategory.RUNTIME,
    message = "Null reference at line {line}",
    severity = "ERROR",
    description = "Attempt to access a null or undefined value",
    #             suggestion="Check if the value is properly initialized",
    examples = [
    #                 "Null reference at line 5",
    #                 "Null reference at line 12"
    #             ],
    related_codes = ["E402", "E404"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E404",
    category = ErrorCategory.RUNTIME,
    message = "Invalid arguments to function '{function_name}' at line {line}",
    severity = "ERROR",
    #             description="Function called with invalid argument values",
    suggestion = "Validate arguments before calling the function",
    examples = [
    #                 "Invalid arguments to function 'sqrt' at line 5",
    #                 "Invalid arguments to function 'sort' at line 12"
    #             ],
    related_codes = ["E403"],
    since_version = "1.0.0"
    #         ))

            # Compiler Errors (E5xx)
            self.register_error_code(ErrorCode(
    code = "E501",
    category = ErrorCategory.COMPILER,
    message = "Internal compiler error: {error_message}",
    severity = "ERROR",
    description = "An unexpected error occurred in the compiler",
    suggestion = "Report this error to the development team",
    examples = [
    #                 "Internal compiler error: Failed to parse AST node",
    #                 "Internal compiler error: Type inference failed"
    #             ],
    related_codes = ["E502"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E502",
    category = ErrorCategory.COMPILER,
    message = "Compilation failed: {details}",
    severity = "ERROR",
    description = "The compilation process failed",
    #             suggestion="Check the code for errors and try again",
    examples = [
    #                 "Compilation failed: Too many errors",
    #                 "Compilation failed: Out of memory"
    #             ],
    related_codes = ["E501"],
    since_version = "1.0.0"
    #         ))

            # System Errors (E6xx)
            self.register_error_code(ErrorCode(
    code = "E601",
    category = ErrorCategory.SYSTEM,
    message = "File not found: '{filename}'",
    severity = "ERROR",
    description = "The specified file could not be found",
    suggestion = "Check the file path and name",
    examples = [
    #                 "File not found: 'main.noodle'",
    #                 "File not found: 'utils.py'"
    #             ],
    related_codes = ["E602", "E603"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E602",
    category = ErrorCategory.SYSTEM,
    message = "Permission denied: '{filename}'",
    severity = "ERROR",
    description = "The program lacks permission to access the file",
    #             suggestion="Check file permissions or run with appropriate privileges",
    examples = [
    #                 "Permission denied: '/etc/config'",
    #                 "Permission denied: 'private_data.txt'"
    #             ],
    related_codes = ["E601", "E603"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E603",
    category = ErrorCategory.SYSTEM,
    #             message="Disk full while writing to '{filename}'",
    severity = "ERROR",
    #             description="No disk space available for file operations",
    suggestion = "Free up disk space or choose a different location",
    examples = [
    #                 "Disk full while writing to 'output.dat'",
    #                 "Disk full while writing to 'log.txt'"
    #             ],
    related_codes = ["E601", "E602"],
    since_version = "1.0.0"
    #         ))

            # Security Errors (E7xx)
            self.register_error_code(ErrorCode(
    code = "E701",
    category = ErrorCategory.SECURITY,
    message = "Potential security vulnerability: {vulnerability_type}",
    severity = "WARNING",
    description = "Code that may introduce security risks",
    suggestion = "Review and potentially modify the code",
    examples = [
    #                 "Potential security vulnerability: SQL injection",
    #                 "Potential security vulnerability: Cross-site scripting"
    #             ],
    related_codes = ["E702", "E703"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E702",
    category = ErrorCategory.SECURITY,
    message = "Insecure operation: {operation}",
    severity = "WARNING",
    description = "Operation that may be unsafe in certain contexts",
    #             suggestion="Use a more secure alternative if available",
    examples = [
                    "Insecure operation: eval()",
    #                 "Insecure operation: dynamic code execution"
    #             ],
    related_codes = ["E701", "E703"],
    since_version = "1.0.0"
    #         ))

            # Performance Errors (E8xx)
            self.register_error_code(ErrorCode(
    code = "E801",
    category = ErrorCategory.PERFORMANCE,
    message = "Potential performance issue: {issue}",
    severity = "WARNING",
    description = "Code that may perform poorly",
    suggestion = "Consider optimizing the code",
    examples = [
    #                 "Potential performance issue: Nested loop",
    #                 "Potential performance issue: String concatenation in loop"
    #             ],
    related_codes = ["E802"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "E802",
    category = ErrorCategory.PERFORMANCE,
    message = "Memory leak detected: {details}",
    severity = "WARNING",
    description = "Code that may cause memory leaks",
    suggestion = "Review memory management",
    examples = [
    #                 "Memory leak detected: Unreferenced objects",
    #                 "Memory leak detected: Circular references"
    #             ],
    related_codes = ["E801"],
    since_version = "1.0.0"
    #         ))

            # Warning Messages (W1xx)
            self.register_error_code(ErrorCode(
    code = "W101",
    category = ErrorCategory.WARNING,
    message = "Unused variable '{variable_name}' at line {line}",
    severity = "WARNING",
    description = "A variable is declared but never used",
    suggestion = "Remove the unused variable or use it",
    examples = [
    #                 "Unused variable 'unused_var' at line 5",
    #                 "Unused variable 'temp' at line 12"
    #             ],
    related_codes = ["W102"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "W102",
    category = ErrorCategory.WARNING,
    message = "Import '{module_name}' is not used at line {line}",
    severity = "WARNING",
    description = "An imported module is not used",
    suggestion = "Remove the unused import",
    examples = [
    #                 "Import 'unused_module' is not used at line 5",
    #                 "Import 'legacy_lib' is not used at line 12"
    #             ],
    related_codes = ["W101"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "W103",
    category = ErrorCategory.WARNING,
    message = "Code style violation: {violation} at line {line}",
    severity = "WARNING",
    description = "Code that doesn't follow style guidelines",
    suggestion = "Follow the project's coding standards",
    examples = [
    #                 "Code style violation: Line too long at line 5",
    #                 "Code style violation: Inconsistent indentation at line 12"
    #             ],
    related_codes = ["W104"],
    since_version = "1.0.0"
    #         ))

            self.register_error_code(ErrorCode(
    code = "W104",
    category = ErrorCategory.WARNING,
    message = "Deprecated feature: {feature} at line {line}",
    severity = "WARNING",
    description = "Use of deprecated language feature",
    suggestion = "Update the code to use modern alternatives",
    examples = [
    #                 "Deprecated feature: Old-style for loop at line 5",
    #                 "Deprecated feature: Legacy API usage at line 12"
    #             ],
    related_codes = ["W103"],
    since_version = "1.0.0"
    #         ))

    #     def register_error_code(self, error_code: ErrorCode):
    #         """Register an error code"""
    self.error_codes[error_code.code] = error_code

    #         # Add to category index
    #         if error_code.category not in self.category_codes:
    self.category_codes[error_code.category] = []
            self.category_codes[error_code.category].append(error_code)

    #     def get_error_code(self, code: str) -Optional[ErrorCode]):
    #         """Get an error code by its code"""
            return self.error_codes.get(code)

    #     def get_error_codes_by_category(self, category: ErrorCategory) -List[ErrorCode]):
    #         """Get all error codes for a category"""
            return self.category_codes.get(category, [])

    #     def get_all_error_codes(self) -List[ErrorCode]):
    #         """Get all registered error codes"""
            return list(self.error_codes.values())

    #     def find_similar_codes(self, code: str) -List[ErrorCode]):
    #         """Find error codes similar to the given code"""
    similar = []

    #         # Check for codes with similar names
    #         for error_code in self.error_codes.values():
    #             if self._are_similar_codes(code, error_code.code):
                    similar.append(error_code)

    #         return similar

    #     def _are_similar_codes(self, code1: str, code2: str) -bool):
    #         """Check if two error codes are similar"""
    #         # Remove category prefix and compare numbers
    #         num1 = code1[1:] if len(code1) 1 else code1
    #         num2 = code2[1):] if len(code2) 1 else code2

    #         # Check if numbers are close
    #         try):
    num1_int = int(num1)
    num2_int = int(num2)
    return abs(num1_int - num2_int) < = 10
    #         except ValueError:
    #             return False

    #     def format_error_message(self, code: str, **kwargs) -str):
    #         """Format an error message using its code"""
    error_code = self.get_error_code(code)
    #         if error_code:
                return error_code.format_message(**kwargs)
    #         else:
    #             return f"Unknown error code: {code}"


# Global instance
error_code_registry = ErrorCodeRegistry()


def get_error_code_registry() -ErrorCodeRegistry):
#     """Get the global error code registry"""
#     return error_code_registry


def get_error_code(code: str) -Optional[ErrorCode]):
#     """Get an error code by its code"""
    return error_code_registry.get_error_code(code)


def get_error_codes_by_category(category: ErrorCategory) -List[ErrorCode]):
#     """Get all error codes for a category"""
    return error_code_registry.get_error_codes_by_category(category)


def get_all_error_codes() -List[ErrorCode]):
#     """Get all registered error codes"""
    return error_code_registry.get_all_error_codes()


def find_similar_codes(code: str) -List[ErrorCode]):
#     """Find error codes similar to the given code"""
    return error_code_registry.find_similar_codes(code)


def format_error_message(code: str, **kwargs) -str):
#     """Format an error message using its code"""
    return error_code_registry.format_error_message(code, **kwargs)


# Utility functions for common error patterns
def create_error_with_context(error_code: str, context: Dict[str, Any]) -Dict[str, Any]):
#     """Create an error message with context information"""
#     return {
#         'code': error_code,
        'message': format_error_message(error_code, **context),
#         'severity': get_error_code(error_code).severity if get_error_code(error_code) else 'UNKNOWN',
#         'category': get_error_code(error_code).category.value if get_error_code(error_code) else 'UNKNOWN',
#         'context': context,
#         'timestamp': None  # Would be set in actual implementation
#     }


# Example usage
if __name__ == "__main__"
    #     # Get the error code registry
    registry = get_error_code_registry()

    #     # Get all error codes
    all_codes = registry.get_all_error_codes()
        print(f"Total error codes: {len(all_codes)}")

    #     # Get error codes by category
    syntax_errors = registry.get_error_codes_by_category(ErrorCategory.SYNTAX)
        print(f"Syntax errors: {len(syntax_errors)}")

    #     # Format an error message
    error_msg = registry.format_error_message("E101", token="}", line=5, column=10)
        print(f"Formatted error: {error_msg}")

    #     # Find similar codes
    similar = registry.find_similar_codes("E101")
    #     print(f"Codes similar to E101: {[code.code for code in similar]}")
