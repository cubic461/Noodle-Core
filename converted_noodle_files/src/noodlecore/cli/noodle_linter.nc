# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore CLI Linter Module
 = ==========================

# Provides linting functionality for NoodleCore CLI.
# """

import typing.List,


class NoodleLinter
    #     """Linter for NoodleCore CLI operations."""

    #     def __init__(self):
    #         """Initialize linter."""
    self.rules = []
    self.errors = []
    self.warnings = []

    #     def add_rule(self, rule_name: str, rule_func):
    #         """Add a linting rule."""
            self.rules.append({
    #             'name': rule_name,
    #             'func': rule_func
    #         })

    #     def remove_rule(self, rule_name: str):
    #         """Remove a linting rule."""
    #         self.rules = [rule for rule in self.rules if rule['name'] != rule_name]

    #     def lint(self, source: str) -> List[Dict[str, Any]]:
    #         """Lint source code with all rules."""
    self.errors = []
    self.warnings = []

    #         for rule in self.rules:
    #             try:
    result = rule['func'](source)
    #                 if result:
                        self.errors.extend(result)
    #             except Exception as e:
                    self.warnings.append({
    #                     'rule': rule['name'],
                        'message': f"Rule execution failed: {str(e)}"
    #                 })

    #         return self.errors

    #     def get_errors(self) -> List[Dict[str, Any]]:
    #         """Get all linting errors."""
    #         return self.errors

    #     def get_warnings(self) -> List[Dict[str, Any]]:
    #         """Get all linting warnings."""
    #         return self.warnings

    #     def clear(self):
    #         """Clear all errors and warnings."""
    self.errors = []
    self.warnings = []

    #     def get_stats(self) -> Dict[str, Any]:
    #         """Get linting statistics."""
    #         return {
                'rules_count': len(self.rules),
                'errors_count': len(self.errors),
                'warnings_count': len(self.warnings)
    #         }