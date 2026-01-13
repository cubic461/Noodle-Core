# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Validation Rules for NoodleCore Linter
# --------------------------------------
# This module provides validation rules for NoodleCore code, including
# style guidelines, best practices, and security checks.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import re
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import ..compiler.parser_ast_nodes.(
#     ASTNode, ProgramNode, StatementNode, ExpressionNode,
#     NodeType, get_node_position, find_nodes
# )
import ..compiler.lexer.Position
import .linter.LinterError,


class RuleSeverity(Enum)
    #     """Severity levels for validation rules"""
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"
    HINT = "hint"


class RuleCategory(Enum)
    #     """Categories for validation rules"""
    STYLE = "style"
    PERFORMANCE = "performance"
    SECURITY = "security"
    BEST_PRACTICE = "best_practice"
    MAINTAINABILITY = "maintainability"
    READABILITY = "readability"
    DEPRECATION = "deprecation"


# @dataclass
class ValidationRule
    #     """Represents a validation rule"""

    #     name: str
    #     description: str
    #     category: RuleCategory
    #     severity: RuleSeverity
    enabled: bool = True
    message_template: str = ""
    suggestion_template: Optional[str] = None
    check_function: Optional[Callable] = None
    pattern: Optional[str] = None
    examples: List[str] = field(default_factory=list)

    #     def check(self, node: ASTNode, file_path: Optional[str] = None) -> List[LinterError]:
    #         """Check if the rule is violated"""
    errors = []

    #         if not self.enabled:
    #             return errors

    #         if self.check_function:
    rule_errors = self.check_function(node, file_path)
                errors.extend(rule_errors)

    #         return errors


class ValidationRules
    #     """
    #     Validation rules for NoodleCore code

    #     This class manages and applies validation rules to check for style guidelines,
    #     best practices, security issues, and other code quality aspects.
    #     """

    #     def __init__(self):
    #         """Initialize the validation rules"""
    self.rules = self._initialize_rules()
    self.disabled_rules: Set[str] = set()
    self.disabled_categories: Set[str] = set()
    self.custom_rules: List[ValidationRule] = []

    #     def _initialize_rules(self) -> Dict[str, ValidationRule]:
    #         """Initialize all validation rules"""
    rules = {}

    #         # Style rules
    rules["naming_convention"] = ValidationRule(
    name = "naming_convention",
    description = "Variable and function names should follow snake_case convention",
    category = RuleCategory.STYLE,
    severity = RuleSeverity.WARNING,
    message_template = "Name '{name}' should follow snake_case convention",
    suggestion_template = "Rename '{name}' to '{suggested_name}'",
    check_function = self._check_naming_convention,
    #         )

    rules["line_length"] = ValidationRule(
    name = "line_length",
    description = "Lines should not exceed 120 characters",
    category = RuleCategory.STYLE,
    severity = RuleSeverity.WARNING,
    message_template = "Line {line} exceeds 120 characters ({length} characters)",
    suggestion_template = "Break the line into multiple lines",
    check_function = self._check_line_length,
    #         )

    rules["indentation"] = ValidationRule(
    name = "indentation",
    description = "Code should use consistent indentation (4 spaces)",
    category = RuleCategory.STYLE,
    severity = RuleSeverity.WARNING,
    message_template = "Inconsistent indentation at line {line}",
    #             suggestion_template="Use 4 spaces for indentation",
    check_function = self._check_indentation,
    #         )

    #         # Performance rules
    rules["inefficient_loop"] = ValidationRule(
    name = "inefficient_loop",
    description = "Avoid inefficient loop patterns",
    category = RuleCategory.PERFORMANCE,
    severity = RuleSeverity.WARNING,
    message_template = "Inefficient loop pattern detected at line {line}",
    suggestion_template = "Consider using a more efficient loop pattern",
    check_function = self._check_inefficient_loop,
    #         )

    rules["memory_leak"] = ValidationRule(
    name = "memory_leak",
    description = "Potential memory leak detected",
    category = RuleCategory.PERFORMANCE,
    severity = RuleSeverity.WARNING,
    message_template = "Potential memory leak at line {line}",
    suggestion_template = "Ensure proper resource cleanup",
    check_function = self._check_memory_leak,
    #         )

    #         # Security rules
    rules["hardcoded_secrets"] = ValidationRule(
    name = "hardcoded_secrets",
    description = "Avoid hardcoded secrets or credentials",
    category = RuleCategory.SECURITY,
    severity = RuleSeverity.ERROR,
    message_template = "Potential hardcoded secret at line {line}",
    suggestion_template = "Use environment variables or configuration files",
    check_function = self._check_hardcoded_secrets,
    #         )

    rules["sql_injection"] = ValidationRule(
    name = "sql_injection",
    description = "Potential SQL injection vulnerability",
    category = RuleCategory.SECURITY,
    severity = RuleSeverity.ERROR,
    message_template = "Potential SQL injection at line {line}",
    suggestion_template = "Use parameterized queries",
    check_function = self._check_sql_injection,
    #         )

    #         # Best practice rules
    rules["unused_variable"] = ValidationRule(
    name = "unused_variable",
    description = "Variable '{name}' is declared but never used",
    category = RuleCategory.BEST_PRACTICE,
    severity = RuleSeverity.WARNING,
    message_template = "Variable '{name}' is declared but never used",
    suggestion_template = "Remove the unused variable or use it",
    check_function = self._check_unused_variable,
    #         )

    rules["magic_numbers"] = ValidationRule(
    name = "magic_numbers",
    description = "Avoid magic numbers in code",
    category = RuleCategory.BEST_PRACTICE,
    severity = RuleSeverity.INFO,
    message_template = "Magic number '{number}' at line {line}",
    #             suggestion_template="Replace magic number with a named constant",
    check_function = self._check_magic_numbers,
    #         )

    #         # Maintainability rules
    rules["complex_function"] = ValidationRule(
    name = "complex_function",
    description = "Function '{name}' is too complex (complexity: {complexity})",
    category = RuleCategory.MAINTAINABILITY,
    severity = RuleSeverity.WARNING,
    message_template = "Function '{name}' is too complex (complexity: {complexity})",
    suggestion_template = "Consider breaking the function into smaller functions",
    check_function = self._check_complex_function,
    #         )

    rules["large_function"] = ValidationRule(
    name = "large_function",
    description = "Function '{name}' is too long ({lines} lines)",
    category = RuleCategory.MAINTAINABILITY,
    severity = RuleSeverity.WARNING,
    message_template = "Function '{name}' is too long ({lines} lines)",
    suggestion_template = "Consider breaking the function into smaller functions",
    check_function = self._check_large_function,
    #         )

    #         # Readability rules
    rules["commented_code"] = ValidationRule(
    name = "commented_code",
    description = "Commented out code detected",
    category = RuleCategory.READABILITY,
    severity = RuleSeverity.INFO,
    message_template = "Commented out code at line {line}",
    suggestion_template = "Remove commented out code",
    check_function = self._check_commented_code,
    #         )

    rules["todo_comment"] = ValidationRule(
    name = "todo_comment",
    description = "TODO comment detected",
    category = RuleCategory.READABILITY,
    severity = RuleSeverity.INFO,
    message_template = "TODO comment at line {line}: '{comment}'",
    suggestion_template = "Address the TODO item or create a task",
    check_function = self._check_todo_comment,
    #         )

    #         return rules

    #     def configure(
    #         self,
    disabled_rules: Optional[Set[str]] = None,
    disabled_categories: Optional[Set[str]] = None,
    custom_rules: Optional[List[str]] = None,
    #     ):
    #         """Configure the validation rules"""
    #         if disabled_rules:
    self.disabled_rules = disabled_rules

    #         if disabled_categories:
    self.disabled_categories = disabled_categories

    #         if custom_rules:
    #             self.custom_rules = [self.rules.get(rule) for rule in custom_rules if rule in self.rules]

    #     def validate(self, ast: ProgramNode, file_path: Optional[str] = None) -> LinterResult:
    #         """
    #         Validate an AST against all rules

    #         Args:
    #             ast: The AST to validate
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             LinterResult: Result of the validation
    #         """
    result = LinterResult(success=True)

    #         # Get source code if available for text-based checks
    source_code = None
    #         if file_path:
    #             try:
    #                 with open(file_path, 'r', encoding='utf-8') as f:
    source_code = f.read()
    #             except:
    #                 pass

    #         # Apply each rule
    #         for rule_name, rule in self.rules.items():
    #             # Skip disabled rules
    #             if rule_name in self.disabled_rules:
    #                 continue

    #             # Skip rules in disabled categories
    #             if rule.category.value in self.disabled_categories:
    #                 continue

    #             # Apply the rule
    errors = rule.check(ast, file_path)

    #             # Categorize errors
    #             for error in errors:
    #                 if rule.severity == RuleSeverity.ERROR:
                        result.errors.append(error)
    #                 elif rule.severity == RuleSeverity.WARNING:
                        result.warnings.append(error)
    #                 elif rule.severity == RuleSeverity.INFO:
                        result.infos.append(error)
    #                 elif rule.severity == RuleSeverity.HINT:
                        result.infos.append(error)

    #         # Apply text-based rules if source code is available
    #         if source_code:
                self._validate_source_code(source_code, result, file_path)

    #         return result

    #     def _validate_source_code(self, source_code: str, result: LinterResult, file_path: Optional[str]):
    #         """Validate source code directly for text-based rules"""
    lines = source_code.split('\n')

    #         for line_num, line in enumerate(lines, 1):
    #             # Check line length
    #             if "line_length" not in self.disabled_rules and "style" not in self.disabled_categories:
    #                 if len(line) > 120:
                        result.warnings.append(LinterError(
    code = "W103",
    message = f"Line {line_num} exceeds 120 characters ({len(line)} characters)",
    severity = "warning",
    category = "style",
    file = file_path,
    line = line_num,
    suggestion = "Break the line into multiple lines",
    #                     ))

    #             # Check indentation
    #             if "indentation" not in self.disabled_rules and "style" not in self.disabled_categories:
    #                 if line.startswith('\t'):
                        result.warnings.append(LinterError(
    code = "W103",
    #                         message=f"Tab character used for indentation at line {line_num}",
    severity = "warning",
    category = "style",
    file = file_path,
    line = line_num,
    #                         suggestion="Use 4 spaces for indentation",
    #                     ))

    #             # Check commented code
    #             if "commented_code" not in self.disabled_rules and "readability" not in self.disabled_categories:
    #                 if re.search(r'^\s*\/\/.*[;{}]', line):
                        result.infos.append(LinterError(
    code = "I102",
    message = f"Commented out code at line {line_num}",
    severity = "info",
    category = "readability",
    file = file_path,
    line = line_num,
    suggestion = "Remove commented out code",
    #                     ))

    #             # Check TODO comments
    #             if "todo_comment" not in self.disabled_rules and "readability" not in self.disabled_categories:
    todo_match = re.search(r'\/\/\s*TODO\s*[:\s]*(.+)', line)
    #                 if todo_match:
                        result.infos.append(LinterError(
    code = "I103",
    message = f"TODO comment at line {line_num}: '{todo_match.group(1)}'",
    severity = "info",
    category = "readability",
    file = file_path,
    line = line_num,
    suggestion = "Address the TODO item or create a task",
    #                     ))

    #             # Check hardcoded secrets
    #             if "hardcoded_secrets" not in self.disabled_rules and "security" not in self.disabled_categories:
    secret_patterns = [
    r'password\s* = \s*["\'][^"\']+["\']',
    r'secret\s* = \s*["\'][^"\']+["\']',
    r'api_key\s* = \s*["\'][^"\']+["\']',
    r'token\s* = \s*["\'][^"\']+["\']',
    #                 ]

    #                 for pattern in secret_patterns:
    #                     if re.search(pattern, line, re.IGNORECASE):
                            result.errors.append(LinterError(
    code = "E701",
    message = f"Potential hardcoded secret at line {line_num}",
    severity = "error",
    category = "security",
    file = file_path,
    line = line_num,
    suggestion = "Use environment variables or configuration files",
    #                         ))

    #     def _check_naming_convention(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check naming convention"""
    errors = []

    #         if node.node_type == NodeType.VARIABLE and hasattr(node, 'name'):
    name = node.name
    position = get_node_position(node)

    #             # Check if name follows snake_case
    #             if not re.match(r'^[a-z_][a-z0-9_]*$', name):
    #                 # Convert to snake_case
    suggested_name = re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()

                    errors.append(LinterError(
    code = "W103",
    message = f"Name '{name}' should follow snake_case convention",
    severity = "warning",
    category = "style",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    suggestion = f"Rename '{name}' to '{suggested_name}'",
    #                 ))

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_naming_convention(child, file_path))

    #         return errors

    #     def _check_line_length(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
            """Check line length (handled in _validate_source_code)"""
    #         return []

    #     def _check_indentation(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
            """Check indentation (handled in _validate_source_code)"""
    #         return []

    #     def _check_inefficient_loop(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for inefficient loop patterns"""
    errors = []

    #         # This would contain specific checks for inefficient loop patterns
    #         # For now, we'll return an empty list

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_inefficient_loop(child, file_path))

    #         return errors

    #     def _check_memory_leak(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for potential memory leaks"""
    errors = []

    #         # This would contain specific checks for memory leaks
    #         # For now, we'll return an empty list

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_memory_leak(child, file_path))

    #         return errors

    #     def _check_hardcoded_secrets(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for hardcoded secrets (handled in _validate_source_code)"""
    #         return []

    #     def _check_sql_injection(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for potential SQL injection vulnerabilities"""
    errors = []

    #         # This would contain specific checks for SQL injection
    #         # For now, we'll return an empty list

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_sql_injection(child, file_path))

    #         return errors

    #     def _check_unused_variable(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for unused variables"""
    errors = []

    #         # This would contain specific checks for unused variables
    #         # For now, we'll return an empty list

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_unused_variable(child, file_path))

    #         return errors

    #     def _check_magic_numbers(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for magic numbers"""
    errors = []

    #         if node.node_type == NodeType.LITERAL and hasattr(node, 'value'):
    value = node.value
    position = get_node_position(node)

    #             # Check if it's a numeric literal
    #             if isinstance(value, (int, float)):
    #                 # Exclude common values
    #                 if value not in [0, 1, -1, 2, 10, 100, 1000]:
                        errors.append(LinterError(
    code = "I104",
    #                         message=f"Magic number '{value}' at line {position.line if position else 0}",
    severity = "info",
    category = "best_practice",
    file = file_path,
    #                         line=position.line if position else None,
    #                         column=position.column if position else None,
    #                         suggestion="Replace magic number with a named constant",
    #                     ))

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_magic_numbers(child, file_path))

    #         return errors

    #     def _check_complex_function(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for complex functions"""
    errors = []

    #         if node.node_type == NodeType.FUNCTION_DEF and hasattr(node, 'name'):
    position = get_node_position(node)

    #             # Calculate cyclomatic complexity
    complexity = self._calculate_complexity(node)

    #             if complexity > 10:  # Threshold for complex function
                    errors.append(LinterError(
    code = "W107",
    message = f"Function '{node.name}' is too complex (complexity: {complexity})",
    severity = "warning",
    category = "maintainability",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    suggestion = "Consider breaking the function into smaller functions",
    #                 ))

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_complex_function(child, file_path))

    #         return errors

    #     def _check_large_function(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for large functions"""
    errors = []

    #         if node.node_type == NodeType.FUNCTION_DEF and hasattr(node, 'name'):
    position = get_node_position(node)

    #             # Count lines in function body
    lines = self._count_function_lines(node)

    #             if lines > 50:  # Threshold for large function
                    errors.append(LinterError(
    code = "W108",
    message = f"Function '{node.name}' is too long ({lines} lines)",
    severity = "warning",
    category = "maintainability",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    suggestion = "Consider breaking the function into smaller functions",
    #                 ))

    #         # Recursively check child nodes
    #         for child in node.get_children():
                errors.extend(self._check_large_function(child, file_path))

    #         return errors

    #     def _check_commented_code(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for commented code (handled in _validate_source_code)"""
    #         return []

    #     def _check_todo_comment(self, node: ASTNode, file_path: Optional[str]) -> List[LinterError]:
    #         """Check for TODO comments (handled in _validate_source_code)"""
    #         return []

    #     def _calculate_complexity(self, node: ASTNode) -> int:
    #         """Calculate cyclomatic complexity of a function"""
    complexity = 1  # Base complexity

    #         # Add complexity for decision points
    #         if node.node_type == NodeType.IF:
    complexity + = 1
    #             if hasattr(node, 'elif_clauses') and node.elif_clauses:
    complexity + = len(node.elif_clauses)
    #             if hasattr(node, 'else_body') and node.else_body:
    complexity + = 1
    #         elif node.node_type == NodeType.WHILE or node.node_type == NodeType.FOR:
    complexity + = 1
    #         elif node.node_type == NodeType.TRY:
    complexity + = 1
    #             if hasattr(node, 'catch_blocks') and node.catch_blocks:
    complexity + = len(node.catch_blocks)
    #             if hasattr(node, 'finally_body') and node.finally_body:
    complexity + = 1

    #         # Recursively add complexity from child nodes
    #         for child in node.get_children():
    complexity + = self._calculate_complexity(child)

    #         return complexity

    #     def _count_function_lines(self, node: ASTNode) -> int:
    #         """Count the number of lines in a function"""
    #         if node.node_type != NodeType.FUNCTION_DEF:
    #             return 0

    lines = 0

    #         # Count lines in function body
    #         if hasattr(node, 'body') and node.body:
    #             for statement in node.body:
    lines + = self._count_node_lines(statement)

    #         return lines

    #     def _count_node_lines(self, node: ASTNode) -> int:
    #         """Count the number of lines for a node"""
    #         # This is a simplified implementation
    #         # In a real implementation, this would use position information
    #         lines = 1  # Base line for the node itself

    #         # Add lines for child nodes
    #         for child in node.get_children():
    lines + = self._count_node_lines(child)

    #         return lines