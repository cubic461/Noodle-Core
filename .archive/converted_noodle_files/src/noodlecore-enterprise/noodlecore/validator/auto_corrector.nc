# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Auto-Corrector for NoodleCore
# -----------------------------
# This module provides automatic correction capabilities for common NoodleCore syntax issues
# that can be safely fixed without changing the program's semantics.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import re
import logging
import typing.List,
import dataclasses.dataclass
import enum.Enum

import .foreign_syntax_detector.ValidationIssue,


class CorrectionResult(Enum)
    #     """Result of an auto-correction attempt"""
    SUCCESS = "success"
    FAILED = "failed"
    NOT_APPLICABLE = "not_applicable"
    PARTIAL = "partial"


# @dataclass
class Correction
    #     """Represents a correction applied to code"""
    #     line_number: int
    #     column: int
    #     original_text: str
    #     corrected_text: str
    #     description: str
    #     result: CorrectionResult


# @dataclass
class AutoCorrectionResult
    #     """Result of auto-correction process"""
    #     success: bool
    #     corrected_code: str
    #     corrections: List[Correction]
    #     remaining_issues: List[ValidationIssue]
    exit_code: int  # 0 = math.subtract(valid, 1 = invalid, 2 = auto, correction failed)


class AutoCorrector
    #     """
    #     Provides automatic correction capabilities for NoodleCore code

    #     This class attempts to automatically fix common syntax issues in NoodleCore code
    #     that can be safely corrected without changing the program's semantics.
    #     """

    #     def __init__(self):
    #         """Initialize the auto-corrector"""
    self.logger = logging.getLogger("noodlecore.validator.auto_corrector")

    #         # Define correction rules
    self.correction_rules = self._define_correction_rules()

    #         # Compile regex patterns for efficiency
    self.compiled_rules = self._compile_correction_rules()

            self.logger.info("Auto-corrector initialized")

    #     def _define_correction_rules(self) -> List[Dict]:
    #         """Define correction rules for common issues"""
    #         return [
    #             # Python import to NoodleCore include/use
    #             {
    #                 "name": "Python Import to Include",
    #                 "error_code": 2001,
                    "pattern": r'^(\s*)import\s+(\w+)',
    #                 "replacement": r'\1include \2',
    #                 "description": "Replace 'import' with 'include'"
    #             },
    #             {
    #                 "name": "Python From Import to Use",
    #                 "error_code": 2001,
                    "pattern": r'^(\s*)from\s+(\w+)\s+import\s+(\w+)',
    #                 "replacement": r'\1use \2.\3',
    #                 "description": "Replace 'from ... import' with 'use'"
    #             },

    #             # Python def to function
    #             {
    #                 "name": "Python Def to Function",
    #                 "error_code": 2002,
                    "pattern": r'^(\s*)def\s+(\w+)\s*\(',
                    "replacement": r'\1function \2(',
    #                 "description": "Replace 'def' with 'function'"
    #             },

    #             # Remove colons after class definition
    #             {
    #                 "name": "Remove Class Colon",
    #                 "error_code": 2003,
                    "pattern": r'^(\s*)class\s+(\w+)(\s*\([^)]*\))?\s*:\s*$',
    #                 "replacement": r'\1class \2\3',
    #                 "description": "Remove colon after class definition"
    #             },

    #             # Remove colons after control flow statements
    #             {
    #                 "name": "Remove Control Flow Colon",
    #                 "error_code": 2004,
                    "pattern": r'^(\s*)(if|elif|else|while|for|try|except|finally|with)\s+(.*)\s*:\s*$',
    #                 "replacement": r'\1\2 \3',
    #                 "description": "Remove colon after control flow statement"
    #             },

    #             # Python decorator to attribute
    #             {
    #                 "name": "Python Decorator to Attribute",
    #                 "error_code": 2005,
                    "pattern": r'^(\s*)@(\w+)',
    #                 "replacement": r'\1attribute \2',
    #                 "description": "Replace '@' with 'attribute'"
    #             },

    #             # Python except to catch
    #             {
    #                 "name": "Python Except to Catch",
    #                 "error_code": 2007,
                    "pattern": r'^(\s*)except\s*:',
    #                 "replacement": r'\1catch',
    #                 "description": "Replace 'except' with 'catch'"
    #             },

    #             # Remove trailing semicolons
    #             {
    #                 "name": "Remove Trailing Semicolon",
    #                 "error_code": 2009,
                    "pattern": r';(\s*)$',
    #                 "replacement": r'\1',
    #                 "description": "Remove trailing semicolon"
    #             },

    #             # C-style comments to NoodleCore comments
    #             {
    #                 "name": "C-Style to NoodleCore Comment",
    #                 "error_code": 2010,
                    "pattern": r'//(.*)',
    #                 "replacement": r'#\1',
    #                 "description": "Replace '//' comment with '#'"
    #             },
    #             {
    #                 "name": "C-Style Block Comment to NoodleCore",
    #                 "error_code": 2010,
                    "pattern": r'/\*(.*?)\*/',
    #                 "replacement": r'#\1',
    #                 "description": "Replace '/* */' comment with '#'"
    #             },

    #             # JavaScript var/let/const removal
    #             {
    #                 "name": "Remove JavaScript Variable Declaration",
    #                 "error_code": 2012,
    "pattern": r'^(\s*)(var|let|const)\s+(\w+)\s* = ',
    "replacement": r'\1\3 = ',
    #                 "description": "Remove 'var', 'let', or 'const' keyword"
    #             },

    #             # JavaScript arrow function to function
    #             {
    #                 "name": "JavaScript Arrow Function to Function",
    #                 "error_code": 2013,
    "pattern": r'(\w+)\s* = \s*\(([^)]*)\)\s*=>',
                    "replacement': r'function \1(\2)',
    #                 "description": "Replace arrow function with function keyword"
    #             },

    #             # Java package to module
    #             {
    #                 "name": "Java Package to Module",
    #                 "error_code": 2014,
                    "pattern": r'^(\s*)package\s+([\w.]+);',
    #                 "replacement': r'\1module \2',
    #                 "description": "Replace 'package' with 'module'"
    #             },

    #             # Ruby begin-end removal
    #             {
    #                 "name": "Remove Ruby Begin-End",
    #                 "error_code": 2015,
                    "pattern": r'^(\s*)begin\s*$',
    #                 "replacement": r'\1',
    #                 "description": "Remove 'begin' keyword"
    #             },
    #             {
    #                 "name": "Remove Ruby End",
    #                 "error_code": 2015,
                    "pattern": r'^(\s*)end\s*$',
    #                 "replacement": r'\1',
    #                 "description": "Remove 'end' keyword"
    #             },

    #             # Shell shebang removal
    #             {
    #                 "name": "Remove Shell Shebang",
    #                 "error_code": 2016,
    #                 "pattern": r'^#![^\n]*\n',
    #                 "replacement": r'',
    #                 "description": "Remove shell shebang line"
    #             }
    #         ]

    #     def _compile_correction_rules(self) -> List[Dict]:
    #         """Compile correction rule patterns for efficiency"""
    compiled = []
    #         for rule in self.correction_rules:
    #             try:
    compiled_pattern = re.compile(rule["pattern"], re.MULTILINE)
                    compiled.append({
    #                     **rule,
    #                     "compiled_pattern": compiled_pattern
    #                 })
    #             except re.error as e:
                    self.logger.error(f"Failed to compile correction rule '{rule['name']}': {e}")

    #         return compiled

    #     def auto_correct(self, code: str, issues: List[ValidationIssue]) -> AutoCorrectionResult:
    #         """
    #         Attempt to automatically correct issues in the code

    #         Args:
    #             code: The code to correct
    #             issues: List of validation issues to correct

    #         Returns:
    #             AutoCorrectionResult with corrected code and corrections applied
    #         """
    #         self.logger.info(f"Starting auto-correction for {len(issues)} issues")

    #         # Filter issues that are auto-correctable
    #         correctable_issues = [issue for issue in issues if issue.auto_correctable]

    #         if not correctable_issues:
                self.logger.info("No auto-correctable issues found")
                return AutoCorrectionResult(
    success = False,
    corrected_code = code,
    corrections = [],
    remaining_issues = issues,
    #                 exit_code=1 if issues else 0
    #             )

            # Apply corrections in order of line number (reverse to maintain positions)
    corrections = []
    corrected_code = code

    #         # Sort issues by line number in descending order to maintain positions
    correctable_issues.sort(key = lambda x: x.line_number, reverse=True)

    #         for issue in correctable_issues:
    correction = self._apply_correction(corrected_code, issue)
    #             if correction:
                    corrections.append(correction)
    #                 if correction.result == CorrectionResult.SUCCESS:
    corrected_code = correction.corrected_text

    #         # Re-validate to check remaining issues
    remaining_issues = self._get_remaining_issues(issues, corrections)

    #         # Determine success and exit code
    success = len(remaining_issues) == 0
    #         exit_code = 0 if success else (2 if corrections and not success else 1)

            self.logger.info(f"Auto-correction completed: {len(corrections)} corrections applied, "
                            f"{len(remaining_issues)} issues remaining")

            return AutoCorrectionResult(
    success = success,
    corrected_code = corrected_code,
    corrections = corrections,
    remaining_issues = remaining_issues,
    exit_code = exit_code
    #         )

    #     def _apply_correction(self, code: str, issue: ValidationIssue) -> Optional[Correction]:
    #         """
    #         Apply a correction for a specific issue

    #         Args:
    #             code: The code to correct
    #             issue: The validation issue to correct

    #         Returns:
    #             Correction if applied, None otherwise
    #         """
    #         if not issue.error_code:
    #             return None

    #         # Find matching correction rule
    rule = None
    #         for r in self.compiled_rules:
    #             if r["error_code"] == issue.error_code:
    rule = r
    #                 break

    #         if not rule:
    #             self.logger.warning(f"No correction rule found for error code {issue.error_code}")
    #             return None

    #         try:
    #             # Apply the correction
    corrected_code = rule["compiled_pattern"].sub(rule["replacement"], code)

    #             # Check if any changes were made
    #             if corrected_code == code:
                    return Correction(
    line_number = issue.line_number,
    column = issue.column,
    original_text = "",
    corrected_text = "",
    description = f"Failed to apply correction: {rule['description']}",
    result = CorrectionResult.FAILED
    #                 )

                return Correction(
    line_number = issue.line_number,
    column = issue.column,
    original_text = code,
    corrected_text = corrected_code,
    description = rule["description"],
    result = CorrectionResult.SUCCESS
    #             )

    #         except Exception as e:
                self.logger.error(f"Error applying correction: {e}")
                return Correction(
    line_number = issue.line_number,
    column = issue.column,
    original_text = code,
    corrected_text = code,
    description = f"Error applying correction: {str(e)}",
    result = CorrectionResult.FAILED
    #             )

    #     def _get_remaining_issues(self, original_issues: List[ValidationIssue],
    #                            corrections: List[Correction]) -> List[ValidationIssue]:
    #         """
    #         Get list of issues that remain after corrections

    #         Args:
    #             original_issues: Original list of issues
    #             corrections: Corrections that were applied

    #         Returns:
    #             List of remaining issues
    #         """
    #         # Get line numbers of successful corrections
    corrected_lines = set()
    #         for correction in corrections:
    #             if correction.result == CorrectionResult.SUCCESS:
                    corrected_lines.add(correction.line_number)

    #         # Filter out issues that were corrected
    remaining_issues = []
    #         for issue in original_issues:
    #             if issue.line_number not in corrected_lines or not issue.auto_correctable:
                    remaining_issues.append(issue)

    #         return remaining_issues

    #     def can_auto_correct(self, issues: List[ValidationIssue]) -> bool:
    #         """
    #         Check if all issues can be automatically corrected

    #         Args:
    #             issues: List of validation issues

    #         Returns:
    #             True if all issues can be auto-corrected, False otherwise
    #         """
    #         if not issues:
    #             return True

    #         # Check if all issues are auto-correctable
    #         for issue in issues:
    #             if not issue.auto_correctable:
    #                 return False

    #             # Check if we have a correction rule for this issue
    #             has_rule = any(r["error_code"] == issue.error_code for r in self.compiled_rules)
    #             if not has_rule:
    #                 return False

    #         return True

    #     def get_correction_preview(self, code: str, issues: List[ValidationIssue]) -> List[Correction]:
    #         """
    #         Get a preview of corrections without applying them

    #         Args:
    #             code: The code to preview corrections for
    #             issues: List of validation issues

    #         Returns:
    #             List of corrections that would be applied
    #         """
    corrections = []

    #         for issue in issues:
    #             if issue.auto_correctable:
    correction = self._apply_correction(code, issue)
    #                 if correction:
                        corrections.append(correction)

    #         return corrections

    #     def add_custom_correction_rule(self, name: str, error_code: int, pattern: str,
    #                                   replacement: str, description: str):
    #         """
    #         Add a custom correction rule

    #         Args:
    #             name: Name of the correction rule
    #             error_code: Error code this rule applies to
    #             pattern: Regex pattern to match
    #             replacement: Replacement string
    #             description: Description of the correction
    #         """
    rule = {
    #             "name": name,
    #             "error_code": error_code,
    #             "pattern": pattern,
    #             "replacement": replacement,
    #             "description": description
    #         }

    #         try:
    compiled_pattern = re.compile(pattern, re.MULTILINE)
    rule["compiled_pattern"] = compiled_pattern
                self.compiled_rules.append(rule)
                self.logger.info(f"Added custom correction rule: {name}")
    #         except re.error as e:
                self.logger.error(f"Failed to compile custom correction rule '{name}': {e}")

    #     def remove_correction_rule(self, error_code: int) -> bool:
    #         """
    #         Remove a correction rule by error code

    #         Args:
    #             error_code: Error code of the rule to remove

    #         Returns:
    #             True if rule was removed, False if not found
    #         """
    original_length = len(self.compiled_rules)
    #         self.compiled_rules = [r for r in self.compiled_rules if r["error_code"] != error_code]

    #         if len(self.compiled_rules) < original_length:
    #             self.logger.info(f"Removed correction rule for error code {error_code}")
    #             return True

    #         return False

    #     def get_correction_rules(self) -> List[Dict]:
    #         """
    #         Get all correction rules

    #         Returns:
    #             List of correction rules
    #         """
    #         return [
    #             {
    #                 "name": rule["name"],
    #                 "error_code": rule["error_code"],
    #                 "pattern": rule["pattern"],
    #                 "replacement": rule["replacement"],
    #                 "description": rule["description"]
    #             }
    #             for rule in self.compiled_rules
    #         ]