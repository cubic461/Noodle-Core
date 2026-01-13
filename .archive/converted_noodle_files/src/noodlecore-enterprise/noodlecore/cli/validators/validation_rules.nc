# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Validation Rules Module

# This module defines specific validation rules for NoodleCore and implements
# a rule engine for custom validations.
# """

import re
import time
import abc.ABC,
import typing.Dict,
import enum.Enum
import dataclasses.dataclass,
import logging

import .validator_base.(
#     ValidationResult, ValidationIssue,
#     ValidationSeverity
# )
import .grammar.Token,


class RuleCategory(Enum)
    #     """Enumeration for rule categories."""
    SYNTAX = "syntax"
    SEMANTIC = "semantic"
    STYLE = "style"
    SECURITY = "security"
    PERFORMANCE = "performance"
    BEST_PRACTICES = "best_practices"


# @dataclass
class RuleContext
    #     """Context information for rule execution."""
    #     code: str
    #     tokens: List[Token]
    #     ast_root: ASTNode
    file_path: Optional[str] = None
    config: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class RuleResult
    #     """Result of a rule execution."""
    #     rule_id: str
    issues: List[ValidationIssue] = field(default_factory=list)
    execution_time: float = 0.0
    enabled: bool = True


class ValidationRule(ABC)
    #     """Abstract base class for validation rules."""

    #     def __init__(self, rule_id: str, name: str, description: str,
    #                  category: RuleCategory, severity: ValidationSeverity,
    enabled: bool = True):
    #         """
    #         Initialize the validation rule.

    #         Args:
    #             rule_id: Unique identifier for the rule
    #             name: Human-readable name of the rule
    #             description: Description of what the rule checks
    #             category: Category of the rule
    #             severity: Default severity for issues found by this rule
    #             enabled: Whether the rule is enabled
    #         """
    self.rule_id = rule_id
    self.name = name
    self.description = description
    self.category = category
    self.severity = severity
    self.enabled = enabled
    self.logger = logging.getLogger(f"noodlecore.validators.rules.{rule_id}")

    #     @abstractmethod
    #     async def check(self, context: RuleContext) -> RuleResult:
    #         """
    #         Check the rule against the given context.

    #         Args:
    #             context: Rule execution context

    #         Returns:
    #             RuleResult containing any issues found
    #         """
    #         pass

    #     def create_issue(self, line: Optional[int], column: Optional[int],
    message: str, suggestion: Optional[str] = None,
    severity: Optional[ValidationSeverity] = math.subtract(None), > ValidationIssue:)
    #         """
    #         Create a validation issue.

    #         Args:
    #             line: Line number where the issue occurs
    #             column: Column number where the issue occurs
    #             message: Issue message
    #             suggestion: Optional suggestion for fixing the issue
    #             severity: Issue severity (overrides default if provided)

    #         Returns:
    #             ValidationIssue object
    #         """
            return ValidationIssue(
    line = line,
    column = column,
    message = message,
    severity = severity or self.severity,
    code = self.rule_id,
    rule = self.name,
    suggestion = suggestion
    #         )


class RegexRule(ValidationRule)
    #     """Rule that checks for patterns using regular expressions."""

    #     def __init__(self, rule_id: str, name: str, description: str,
    #                  category: RuleCategory, severity: ValidationSeverity,
    pattern: str, message: str, suggestion: Optional[str] = None,
    enabled: bool = True):
    #         """
    #         Initialize the regex rule.

    #         Args:
    #             rule_id: Unique identifier for the rule
    #             name: Human-readable name of the rule
    #             description: Description of what the rule checks
    #             category: Category of the rule
    #             severity: Default severity for issues found by this rule
    #             pattern: Regular expression pattern to check
    #             message: Message to use when pattern is found
    #             suggestion: Optional suggestion for fixing the issue
    #             enabled: Whether the rule is enabled
    #         """
            super().__init__(rule_id, name, description, category, severity, enabled)
    self.pattern = re.compile(pattern, re.MULTILINE | re.IGNORECASE)
    self.message = message
    self.suggestion = suggestion

    #     async def check(self, context: RuleContext) -> RuleResult:
    #         """
    #         Check the regex pattern against the code.

    #         Args:
    #             context: Rule execution context

    #         Returns:
    #             RuleResult containing any issues found
    #         """
    start_time = time.time()
    result = RuleResult(self.rule_id)

    #         for match in self.pattern.finditer(context.code):
    line_num = context.code[:match.start()].count('\n') + 1
    line_start = context.code.rfind('\n', 0, match.start()) + 1
    column_num = math.add(match.start() - line_start, 1)

                result.issues.append(self.create_issue(
    line = line_num,
    column = column_num,
    message = self.message,
    suggestion = self.suggestion
    #             ))

    result.execution_time = math.subtract(time.time(), start_time)
    #         return result


class ASTRule(ValidationRule)
    #     """Rule that checks the AST structure."""

    #     def __init__(self, rule_id: str, name: str, description: str,
    #                  category: RuleCategory, severity: ValidationSeverity,
    enabled: bool = True):
    #         """
    #         Initialize the AST rule.

    #         Args:
    #             rule_id: Unique identifier for the rule
    #             name: Human-readable name of the rule
    #             description: Description of what the rule checks
    #             category: Category of the rule
    #             severity: Default severity for issues found by this rule
    #             enabled: Whether the rule is enabled
    #         """
            super().__init__(rule_id, name, description, category, severity, enabled)

    #     async def check(self, context: RuleContext) -> RuleResult:
    #         """
    #         Check the AST structure.

    #         Args:
    #             context: Rule execution context

    #         Returns:
    #             RuleResult containing any issues found
    #         """
    start_time = time.time()
    result = RuleResult(self.rule_id)

    #         # Call the abstract method to check the AST
            await self._check_ast(context.ast_root, result)

    result.execution_time = math.subtract(time.time(), start_time)
    #         return result

    #     @abstractmethod
    #     async def _check_ast(self, node: ASTNode, result: RuleResult) -> None:
    #         """
    #         Check a specific AST node.

    #         Args:
    #             node: AST node to check
    #             result: RuleResult to add issues to
    #         """
    #         pass


class RuleEngine
    #     """Engine for managing and executing validation rules."""

    #     def __init__(self, config: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize the rule engine.

    #         Args:
    #             config: Optional configuration dictionary
    #         """
    self.config = config or {}
    self.logger = logging.getLogger("noodlecore.validators.rule_engine")
    self.rules: Dict[str, ValidationRule] = {}
    self.rule_categories: Dict[RuleCategory, List[str]] = {
    #             category: [] for category in RuleCategory
    #         }

    #         # Register default rules
            self._register_default_rules()

    #     def register_rule(self, rule: ValidationRule) -> None:
    #         """
    #         Register a validation rule.

    #         Args:
    #             rule: Rule to register
    #         """
    self.rules[rule.rule_id] = rule
            self.rule_categories[rule.category].append(rule.rule_id)
            self.logger.debug(f"Registered rule: {rule.rule_id}")

    #     def unregister_rule(self, rule_id: str) -> None:
    #         """
    #         Unregister a validation rule.

    #         Args:
    #             rule_id: ID of the rule to unregister
    #         """
    #         if rule_id in self.rules:
    rule = self.rules[rule_id]
                self.rule_categories[rule.category].remove(rule_id)
    #             del self.rules[rule_id]
                self.logger.debug(f"Unregistered rule: {rule_id}")

    #     def enable_rule(self, rule_id: str) -> None:
    #         """
    #         Enable a rule.

    #         Args:
    #             rule_id: ID of the rule to enable
    #         """
    #         if rule_id in self.rules:
    self.rules[rule_id].enabled = True
                self.logger.debug(f"Enabled rule: {rule_id}")

    #     def disable_rule(self, rule_id: str) -> None:
    #         """
    #         Disable a rule.

    #         Args:
    #             rule_id: ID of the rule to disable
    #         """
    #         if rule_id in self.rules:
    self.rules[rule_id].enabled = False
                self.logger.debug(f"Disabled rule: {rule_id}")

    #     def enable_category(self, category: RuleCategory) -> None:
    #         """
    #         Enable all rules in a category.

    #         Args:
    #             category: Category to enable
    #         """
    #         for rule_id in self.rule_categories[category]:
                self.enable_rule(rule_id)

    #     def disable_category(self, category: RuleCategory) -> None:
    #         """
    #         Disable all rules in a category.

    #         Args:
    #             category: Category to disable
    #         """
    #         for rule_id in self.rule_categories[category]:
                self.disable_rule(rule_id)

    #     async def check_rules(self, context: RuleContext,
    rule_ids: Optional[List[str]] = None,
    categories: Optional[List[RuleCategory]] = math.subtract(None), > List[RuleResult]:)
    #         """
    #         Check rules against the given context.

    #         Args:
    #             context: Rule execution context
    #             rule_ids: Optional list of specific rule IDs to check
    #             categories: Optional list of categories to check

    #         Returns:
    #             List of RuleResult objects
    #         """
    #         # Determine which rules to check
    rules_to_check = []

    #         if rule_ids:
    #             # Check specific rules
    #             for rule_id in rule_ids:
    #                 if rule_id in self.rules and self.rules[rule_id].enabled:
                        rules_to_check.append(self.rules[rule_id])
    #         elif categories:
    #             # Check rules in specific categories
    #             for category in categories:
    #                 for rule_id in self.rule_categories[category]:
    #                     if self.rules[rule_id].enabled:
                            rules_to_check.append(self.rules[rule_id])
    #         else:
    #             # Check all enabled rules
    #             rules_to_check = [rule for rule in self.rules.values() if rule.enabled]

    #         # Execute rules
    results = []
    #         for rule in rules_to_check:
    #             try:
    result = await rule.check(context)
                    results.append(result)
    #             except Exception as e:
                    self.logger.error(f"Error executing rule {rule.rule_id}: {str(e)}")
    #                 # Create a result with an error issue
    error_result = RuleResult(rule.rule_id)
                    error_result.issues.append(ValidationIssue(
    message = f"Rule execution error: {str(e)}",
    severity = ValidationSeverity.ERROR,
    code = rule.rule_id,
    rule = rule.name
    #                 ))
                    results.append(error_result)

    #         return results

    #     def get_rule_info(self, rule_id: str) -> Optional[Dict[str, Any]]:
    #         """
    #         Get information about a specific rule.

    #         Args:
    #             rule_id: ID of the rule

    #         Returns:
    #             Dictionary containing rule information or None if not found
    #         """
    #         if rule_id not in self.rules:
    #             return None

    rule = self.rules[rule_id]
    #         return {
    #             "id": rule.rule_id,
    #             "name": rule.name,
    #             "description": rule.description,
    #             "category": rule.category.value,
    #             "severity": rule.severity.value,
    #             "enabled": rule.enabled
    #         }

    #     def get_all_rules_info(self) -> Dict[str, Any]:
    #         """
    #         Get information about all registered rules.

    #         Returns:
    #             Dictionary containing all rules information
    #         """
    #         return {
                "total_rules": len(self.rules),
    #             "enabled_rules": len([r for r in self.rules.values() if r.enabled]),
    #             "categories": {
    #                 category.value: {
                        "rule_count": len(rule_ids),
    #                     "rules": [self.get_rule_info(rule_id) for rule_id in rule_ids]
    #                 }
    #                 for category, rule_ids in self.rule_categories.items()
    #             }
    #         }

    #     def _register_default_rules(self) -> None:
    #         """Register default validation rules."""
    #         # Security rules
            self.register_rule(RegexRule(
    rule_id = "SEC001",
    name = "No eval() usage",
    description = "Detects usage of eval() function which can be a security risk",
    category = RuleCategory.SECURITY,
    severity = ValidationSeverity.ERROR,
    pattern = r'\beval\s*\(',
    message = "Usage of eval() function detected, which can be a security risk",
    suggestion = "Avoid using eval() or validate inputs thoroughly"
    #         ))

            self.register_rule(RegexRule(
    rule_id = "SEC002",
    name = "No exec() usage",
    description = "Detects usage of exec() function which can be a security risk",
    category = RuleCategory.SECURITY,
    severity = ValidationSeverity.ERROR,
    pattern = r'\bexec\s*\(',
    message = "Usage of exec() function detected, which can be a security risk",
    suggestion = "Avoid using exec() or validate inputs thoroughly"
    #         ))

            self.register_rule(RegexRule(
    rule_id = "SEC003",
    name = "SQL injection prevention",
    description = "Detects potential SQL injection vulnerabilities",
    category = RuleCategory.SECURITY,
    severity = ValidationSeverity.ERROR,
    pattern = r'\b(select|insert|update|delete)\s+.*\+',
    message = "Potential SQL injection vulnerability detected",
    suggestion = "Use parameterized queries to prevent SQL injection"
    #         ))

    #         # Performance rules
            self.register_rule(RegexRule(
    rule_id = "PERF001",
    name = "No infinite loops",
    description = "Detects potential infinite loops",
    category = RuleCategory.PERFORMANCE,
    severity = ValidationSeverity.WARNING,
    pattern = r'\b(while|for)\s*\(\s*true\s*\)',
    message = "Potential infinite loop detected",
    suggestion = "Ensure loop has a proper exit condition"
    #         ))

    #         # Style rules
            self.register_rule(RegexRule(
    rule_id = "STYLE001",
    name = "Line length limit",
    description = "Ensures lines don't exceed recommended length",
    category = RuleCategory.STYLE,
    severity = ValidationSeverity.WARNING,
    pattern = r'.{121,}',  # Lines longer than 120 characters
    message = "Line exceeds recommended length of 120 characters",
    #             suggestion="Break long lines into multiple lines for better readability"
    #         ))

    #         # Best practices rules
            self.register_rule(RegexRule(
    rule_id = "BP001",
    name = "Module declaration required",
    description = "Ensures every file has a module declaration",
    category = RuleCategory.BEST_PRACTICES,
    severity = ValidationSeverity.WARNING,
    pattern = r'^(?!module\s+)',
    message = "File missing module declaration",
    suggestion = "Add a module declaration at the beginning of the file"
    #         ))

            self.register_rule(RegexRule(
    rule_id = "BP002",
    name = "Entry point required",
    description = "Ensures module has an entry point",
    category = RuleCategory.BEST_PRACTICES,
    severity = ValidationSeverity.WARNING,
    pattern = r'\bentry\s+\w+\s*\(',
    message = "Module missing entry point",
    suggestion = "Add an entry point function to the module"
    #         ))


class NoodleCoreRuleSet
    #     """Predefined rule sets for NoodleCore validation."""

    #     @staticmethod
    #     def get_security_rules() -> List[str]:
    #         """Get list of security-focused rule IDs."""
    #         return ["SEC001", "SEC002", "SEC003"]

    #     @staticmethod
    #     def get_performance_rules() -> List[str]:
    #         """Get list of performance-focused rule IDs."""
    #         return ["PERF001"]

    #     @staticmethod
    #     def get_style_rules() -> List[str]:
    #         """Get list of style-focused rule IDs."""
    #         return ["STYLE001"]

    #     @staticmethod
    #     def get_best_practices_rules() -> List[str]:
    #         """Get list of best practices rule IDs."""
    #         return ["BP001", "BP002"]

    #     @staticmethod
    #     def get_all_rules() -> List[str]:
    #         """Get list of all rule IDs."""
            return (
                NoodleCoreRuleSet.get_security_rules() +
                NoodleCoreRuleSet.get_performance_rules() +
                NoodleCoreRuleSet.get_style_rules() +
                NoodleCoreRuleSet.get_best_practices_rules()
    #         )

    #     @staticmethod
    #     def get_strict_rules() -> List[str]:
    #         """Get list of rules for strict validation mode."""
            return NoodleCoreRuleSet.get_all_rules()

    #     @staticmethod
    #     def get_basic_rules() -> List[str]:
    #         """Get list of rules for basic validation mode."""
            return NoodleCoreRuleSet.get_security_rules() + NoodleCoreRuleSet.get_best_practices_rules()