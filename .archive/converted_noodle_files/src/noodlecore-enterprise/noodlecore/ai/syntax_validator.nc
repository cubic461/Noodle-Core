# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Syntax Validation Integration Module for NoodleCore AI Guard
# -----------------------------------------------------------
# This module provides integration with the NoodleCore linter for syntax validation
# of AI-generated code, with specialized handling for different validation modes.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import re
import time
import uuid
import logging
import dataclasses.dataclass,
import enum.Enum
import pathlib.Path
import typing.Any,

import ..compiler.lexer_main.Lexer,
import ..compiler.parser.Parser,
import ..compiler.parser_ast_nodes.ProgramNode,
import ..linter.linter.NoodleLinter,
import .guard.GuardMode


class ValidationLevel(Enum)
    #     """Levels of syntax validation"""
    BASIC = "basic"  # Basic syntax checking
    STANDARD = "standard"  # Standard syntax and semantic checking
    COMPREHENSIVE = "comprehensive"  # Full validation including style rules


class ValidationStrategy(Enum)
    #     """Strategies for handling validation failures"""
    FAIL_FAST = "fail_fast"  # Stop at first error
    COLLECT_ALL = "collect_all"  # Collect all errors
    #     SMART_RETRY = "smart_retry"  # Retry with different strategies


# @dataclass
class ValidationConfig
    #     """Configuration for syntax validation"""

    level: ValidationLevel = ValidationLevel.STANDARD
    strategy: ValidationStrategy = ValidationStrategy.COLLECT_ALL
    enable_caching: bool = True
    timeout_ms: int = 5000  # 5 seconds
    max_errors: int = 100
    enable_semantic_check: bool = True
    enable_style_check: bool = True
    custom_rules: List[str] = field(default_factory=list)
    disabled_rules: Set[str] = field(default_factory=set)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert config to dictionary"""
    #         return {
    #             "level": self.level.value,
    #             "strategy": self.strategy.value,
    #             "enable_caching": self.enable_caching,
    #             "timeout_ms": self.timeout_ms,
    #             "max_errors": self.max_errors,
    #             "enable_semantic_check": self.enable_semantic_check,
    #             "enable_style_check": self.enable_style_check,
    #             "custom_rules": self.custom_rules,
                "disabled_rules": list(self.disabled_rules),
    #         }


# @dataclass
class ValidationResult
    #     """Result of syntax validation"""

    #     is_valid: bool
    errors: List[LinterError] = field(default_factory=list)
    warnings: List[LinterError] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)
    execution_time_ms: int = 0
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))

    #     def has_errors(self) -> bool:
    #         """Check if there are any errors"""
            return len(self.errors) > 0

    #     def has_warnings(self) -> bool:
    #         """Check if there are any warnings"""
            return len(self.warnings) > 0

    #     def get_all_issues(self) -> List[LinterError]:
            """Get all issues (errors and warnings)"""
    #         return self.errors + self.warnings

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert result to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "isValid": self.is_valid,
    #             "errors": [error.to_dict() for error in self.errors],
    #             "warnings": [warning.to_dict() for warning in self.warnings],
    #             "suggestions": self.suggestions,
    #             "executionTimeMs": self.execution_time_ms,
                "totalIssues": len(self.get_all_issues()),
    #         }


class SyntaxValidator
    #     """
    #     Syntax validator for AI-generated NoodleCore code

    #     This class provides integration with the NoodleCore linter for syntax validation
    #     of AI-generated code, with specialized handling for different validation modes.
    #     """

    #     def __init__(self, config: Optional[ValidationConfig] = None):
    #         """Initialize the syntax validator"""
    self.config = config or ValidationConfig()

    #         # Initialize linter with appropriate configuration
    linter_config = LinterConfig()
    linter_config.mode = "runtime_load"
    linter_config.enable_syntax_check = True
    linter_config.enable_semantic_check = self.config.enable_semantic_check
    linter_config.enable_validation_rules = self.config.enable_style_check
    linter_config.timeout_ms = self.config.timeout_ms
    linter_config.max_errors = self.config.max_errors
    linter_config.cache_enabled = self.config.enable_caching

    self.linter = NoodleLinter(linter_config)

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Performance tracking
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Cache for performance
    #         self._validation_cache = {} if self.config.enable_caching else None

    #         self.logger.info(f"Syntax validator initialized with level: {self.config.level.value}")

    #     def _setup_logging(self) -> logging.Logger:
    #         """Setup logging for the syntax validator"""
    logger = logging.getLogger("noodlecore.ai.syntax_validator")
            logger.setLevel(logging.INFO)

    #         # Create formatter
    formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #         )

    #         # Create console handler
    console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)

    #         return logger

    #     def validate(
    #         self,
    #         code: str,
    mode: GuardMode = GuardMode.ADAPTIVE,
    file_path: Optional[str] = None
    #     ) -> ValidationResult:
    #         """
    #         Validate NoodleCore code syntax

    #         Args:
    #             code: The code to validate
                mode: The validation mode (strict, adaptive, permissive)
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             ValidationResult: Result of the validation
    #         """
    start_time = time.time()
    result = ValidationResult(is_valid=False)

    #         try:
                self.logger.info(f"Starting validation (request_id: {result.request_id})")
    self.stats["total_validations"] + = 1

    #             # Check cache first
    #             cache_key = hash(code) if self.config.enable_caching else None
    #             if cache_key is not None and self._validation_cache and cache_key in self._validation_cache:
    cached_result = self._validation_cache[cache_key]
                    self.logger.info(f"Using cached validation result (request_id: {result.request_id})")
    #                 return cached_result

    #             # Configure linter based on mode
                self._configure_linter_for_mode(mode)

    #             # Perform validation based on strategy
    #             if self.config.strategy == ValidationStrategy.FAIL_FAST:
    linter_result = self._validate_fail_fast(code, file_path)
    #             elif self.config.strategy == ValidationStrategy.COLLECT_ALL:
    linter_result = self._validate_collect_all(code, file_path)
    #             else:  # SMART_RETRY
    linter_result = self._validate_smart_retry(code, file_path)

    #             # Update result with linter findings
    result.errors = linter_result.errors
    result.warnings = linter_result.warnings
    result.is_valid = len(result.errors) == 0

    #             # Generate suggestions based on errors
    result.suggestions = self._generate_suggestions(result.errors)

    #             # Cache the result
    #             if cache_key is not None and self._validation_cache is not None:
    self._validation_cache[cache_key] = result

    #             # Update statistics
    #             if result.is_valid:
    self.stats["successful_validations"] + = 1
                    self.logger.info(f"Validation successful (request_id: {result.request_id})")
    #             else:
    self.stats["failed_validations"] + = 1
                    self.logger.warning(f"Validation failed (request_id: {result.request_id})")

    #         except Exception as e:
                result.errors.append(LinterError(
    code = "E804",
    message = f"Internal validation error: {str(e)}",
    severity = "error",
    category = "validator",
    file = file_path,
    #             ))
    result.is_valid = False
                self.logger.error(f"Internal validation error (request_id: {result.request_id}): {str(e)}")

    #         # Calculate execution time
    result.execution_time_ms = math.multiply(int((time.time() - start_time), 1000))
    self.stats["total_time_ms"] + = result.execution_time_ms

    #         return result

    #     def _configure_linter_for_mode(self, mode: GuardMode):
    #         """Configure linter based on validation mode"""
    #         if mode == GuardMode.STRICT:
    self.linter.config.strict_mode = True
    self.linter.config.enable_syntax_check = True
    self.linter.config.enable_semantic_check = True
    self.linter.config.enable_validation_rules = True
    #         elif mode == GuardMode.ADAPTIVE:
    self.linter.config.strict_mode = False
    self.linter.config.enable_syntax_check = True
    self.linter.config.enable_semantic_check = True
    self.linter.config.enable_validation_rules = True
    #         else:  # PERMISSIVE
    self.linter.config.strict_mode = False
    self.linter.config.enable_syntax_check = True
    self.linter.config.enable_semantic_check = True
    self.linter.config.enable_validation_rules = False

    #     def _validate_fail_fast(self, code: str, file_path: Optional[str] = None) -> LinterResult:
    #         """Validate with fail-fast strategy"""
    #         # Configure linter for fail-fast
    self.linter.config.max_errors = 1
    self.linter.config.max_warnings = 0

            return self.linter.lint_source(code, file_path)

    #     def _validate_collect_all(self, code: str, file_path: Optional[str] = None) -> LinterResult:
    #         """Validate with collect-all strategy"""
    #         # Configure linter for collecting all errors
    self.linter.config.max_errors = self.config.max_errors
    self.linter.config.max_warnings = 50

            return self.linter.lint_source(code, file_path)

    #     def _validate_smart_retry(self, code: str, file_path: Optional[str] = None) -> LinterResult:
    #         """Validate with smart-retry strategy"""
    #         # First try with standard configuration
    linter_result = self.linter.lint_source(code, file_path)

    #         # If there are syntax errors, try with different configurations
    #         if linter_result.has_errors():
    #             # Try without semantic checking
    original_semantic = self.linter.config.enable_semantic_check
    self.linter.config.enable_semantic_check = False
    semantic_result = self.linter.lint_source(code, file_path)
    self.linter.config.enable_semantic_check = original_semantic

    #             # Use the result with fewer errors
    #             if len(semantic_result.errors) < len(linter_result.errors):
    linter_result = semantic_result
    #             else:
    #                 # Try without validation rules
    original_validation = self.linter.config.enable_validation_rules
    self.linter.config.enable_validation_rules = False
    validation_result = self.linter.lint_source(code, file_path)
    self.linter.config.enable_validation_rules = original_validation

    #                 # Use the result with fewer errors
    #                 if len(validation_result.errors) < len(linter_result.errors):
    linter_result = validation_result

    #         return linter_result

    #     def _generate_suggestions(self, errors: List[LinterError]) -> List[str]:
    #         """Generate suggestions based on errors"""
    suggestions = []

    #         for error in errors:
    #             if error.suggestion:
                    suggestions.append(error.suggestion)
    #             else:
    #                 # Generate generic suggestions based on error code
    #                 if error.code == "E104":  # Syntax error
    #                     suggestions.append("Check for proper syntax, missing semicolons, or balanced braces")
    #                 elif error.code == "E201":  # Redeclaration
    #                     suggestions.append("Use a different name for the variable or function")
    #                 elif error.code == "E202":  # Undeclared variable
                        suggestions.append("Declare the variable before using it")
    #                 elif error.code == "E301":  # Type mismatch
                        suggestions.append("Ensure the value matches the expected type")

    #         # Remove duplicates while preserving order
    unique_suggestions = []
    #         for suggestion in suggestions:
    #             if suggestion not in unique_suggestions:
                    unique_suggestions.append(suggestion)

    #         return unique_suggestions

    #     def validate_basic_syntax(self, code: str, file_path: Optional[str] = None) -> ValidationResult:
    #         """Validate basic syntax only"""
    #         # Create a minimal linter configuration for basic syntax checking
    original_config = self.linter.config

    basic_config = LinterConfig()
    basic_config.enable_syntax_check = True
    basic_config.enable_semantic_check = False
    basic_config.enable_validation_rules = False
    basic_config.timeout_ms = self.config.timeout_ms

    self.linter.config = basic_config
    result = self.validate(code, GuardMode.PERMISSIVE, file_path)

    #         # Restore original configuration
    self.linter.config = original_config

    #         return result

    #     def validate_with_custom_rules(
    #         self,
    #         code: str,
    #         custom_rules: List[str],
    file_path: Optional[str] = None
    #     ) -> ValidationResult:
    #         """Validate with custom rules"""
    #         # Store original rules
    original_custom_rules = self.linter.config.custom_rules

    #         # Apply custom rules
            self.linter.config.custom_rules.extend(custom_rules)
    result = self.validate(code, GuardMode.ADAPTIVE, file_path)

    #         # Restore original rules
    self.linter.config.custom_rules = original_custom_rules

    #         return result

    #     def get_error_summary(self, errors: List[LinterError]) -> Dict[str, int]:
    #         """Get a summary of errors by category"""
    summary = {}

    #         for error in errors:
    category = error.category
    #             if category not in summary:
    summary[category] = 0
    summary[category] + = 1

    #         return summary

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get validator statistics"""
    #         return {
    #             "total_validations": self.stats["total_validations"],
    #             "successful_validations": self.stats["successful_validations"],
    #             "failed_validations": self.stats["failed_validations"],
                "success_rate": (
    #                 self.stats["successful_validations"] / self.stats["total_validations"]
    #                 if self.stats["total_validations"] > 0 else 0
    #             ),
    #             "total_time_ms": self.stats["total_time_ms"],
                "average_time_ms": (
    #                 self.stats["total_time_ms"] / self.stats["total_validations"]
    #                 if self.stats["total_validations"] > 0 else 0
    #             ),
    #             "cache_size": len(self._validation_cache) if self._validation_cache else 0,
                "config": self.config.to_dict(),
    #         }

    #     def clear_cache(self):
    #         """Clear the validation cache"""
    #         if self._validation_cache:
                self._validation_cache.clear()
                self.logger.info("Validation cache cleared")

    #     def reset_statistics(self):
    #         """Reset validator statistics"""
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "total_time_ms": 0,
    #         }
            self.logger.info("Statistics reset")