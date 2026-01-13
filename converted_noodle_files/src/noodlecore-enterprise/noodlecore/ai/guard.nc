# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# AI Guard Module for NoodleCore
# ------------------------------
# This module provides AI output validation functionality for the NoodleCore system.
# It intercepts AI output, validates it against NoodleCore syntax rules, and blocks
# invalid output while requesting corrections from the AI.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import time
import uuid
import logging
import dataclasses.dataclass,
import enum.Enum
import pathlib.Path
import typing.Any,

# Import NoodleCore components
import ..compiler.lexer_main.Lexer,
import ..compiler.parser.Parser,
import ..compiler.parser_ast_nodes.ProgramNode
import ..linter.linter.NoodleLinter,


class GuardMode(Enum)
    #     """AI Guard operation modes"""
    STRICT = "strict"  # Only .nc extension accepted, all syntax must parse via official compiler
    #     ADAPTIVE = "adaptive"  # Compares AI output with examples from official NoodleCore test suite
    #     PERMISSIVE = "permissive"  # Allows more flexibility but still checks for major issues


class GuardAction(Enum)
    #     """Actions to take when validation fails"""
    BLOCK = "block"  # Block the output completely
    #     REQUEST_CORRECTION = "request_correction"  # Ask AI for corrections
    #     WARN = "warn"  # Allow with warnings


# @dataclass
class GuardConfig
    #     """Configuration for the AI Guard"""

    mode: GuardMode = GuardMode.ADAPTIVE
    action_on_failure: GuardAction = GuardAction.REQUEST_CORRECTION
    max_correction_attempts: int = 3
    timeout_ms: int = 5000  # 5 seconds
    enable_logging: bool = True
    log_file: Optional[str] = None
    cache_enabled: bool = True
    strict_file_extension: bool = True
    allowed_extensions: Set[str] = field(default_factory=lambda: {".nc", ".noodle"})
    custom_validation_rules: List[str] = field(default_factory=list)
    disabled_validation_rules: Set[str] = field(default_factory=set)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert config to dictionary"""
    #         return {
    #             "mode": self.mode.value,
    #             "action_on_failure": self.action_on_failure.value,
    #             "max_correction_attempts": self.max_correction_attempts,
    #             "timeout_ms": self.timeout_ms,
    #             "enable_logging": self.enable_logging,
    #             "log_file": self.log_file,
    #             "cache_enabled": self.cache_enabled,
    #             "strict_file_extension": self.strict_file_extension,
                "allowed_extensions": list(self.allowed_extensions),
    #             "custom_validation_rules": self.custom_validation_rules,
                "disabled_validation_rules": list(self.disabled_validation_rules),
    #         }


# @dataclass
class GuardResult
    #     """Result of an AI guard validation"""

    #     success: bool
    #     is_valid: bool
    #     original_output: str
    corrected_output: Optional[str] = None
    errors: List[LinterError] = field(default_factory=list)
    warnings: List[LinterError] = field(default_factory=list)
    execution_time_ms: int = 0
    correction_attempts: int = 0
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
    #             "success": self.success,
    #             "isValid": self.is_valid,
    #             "originalOutput": self.original_output,
    #             "correctedOutput": self.corrected_output,
    #             "errors": [error.to_dict() for error in self.errors],
    #             "warnings": [warning.to_dict() for warning in self.warnings],
    #             "executionTimeMs": self.execution_time_ms,
    #             "correctionAttempts": self.correction_attempts,
                "totalIssues": len(self.get_all_issues()),
    #         }


class GuardException(Exception)
    #     """Exception raised by the AI Guard"""

    #     def __init__(self, message: str, code: str = "GUARD_ERROR"):
    self.message = message
    self.code = code
            super().__init__(self.message)


class AIGuard
    #     """
    #     AI Guard for validating AI-generated NoodleCore code

    #     This class intercepts AI output, validates it against NoodleCore syntax rules,
    #     and blocks invalid output while requesting corrections from the AI.
    #     """

    #     def __init__(self, config: Optional[GuardConfig] = None):
    #         """Initialize the AI Guard with configuration"""
    self.config = config or GuardConfig()

    #         # Initialize linter with appropriate configuration
    linter_config = LinterConfig()
    linter_config.mode = "runtime_load"
    linter_config.enable_syntax_check = True
    linter_config.enable_semantic_check = True
    linter_config.enable_validation_rules = True
    linter_config.timeout_ms = self.config.timeout_ms
    linter_config.cache_enabled = self.config.cache_enabled

    self.linter = NoodleLinter(linter_config)

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Performance tracking
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "correction_requests": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Cache for performance
    #         self._validation_cache = {} if self.config.cache_enabled else None

    #         # Test suite examples for adaptive mode
    self._test_suite_examples = self._load_test_suite_examples()

    #         self.logger.info(f"AI Guard initialized with mode: {self.config.mode.value}")

    #     def _setup_logging(self) -> logging.Logger:
    #         """Setup logging for the AI Guard"""
    logger = logging.getLogger("noodlecore.ai.guard")
            logger.setLevel(logging.INFO)

    #         if self.config.enable_logging:
    #             # Create formatter
    formatter = logging.Formatter(
                    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #             )

    #             # Create console handler
    console_handler = logging.StreamHandler()
                console_handler.setFormatter(formatter)
                logger.addHandler(console_handler)

    #             # Create file handler if log file is specified
    #             if self.config.log_file:
    file_handler = logging.FileHandler(self.config.log_file)
                    file_handler.setFormatter(formatter)
                    logger.addHandler(file_handler)

    #         return logger

    #     def _load_test_suite_examples(self) -> List[str]:
    #         """Load examples from the NoodleCore test suite for adaptive mode"""
    examples = []

    #         try:
    #             # Look for test files in the tests directory
    test_dir = Path(__file__).parent.parent.parent.parent / "tests"
    #             if test_dir.exists():
    #                 for file_path in test_dir.glob("*.nc"):
    #                     try:
    #                         with open(file_path, 'r', encoding='utf-8') as f:
                                examples.append(f.read())
    #                     except Exception as e:
                            self.logger.warning(f"Failed to read test file {file_path}: {str(e)}")

    #             self.logger.info(f"Loaded {len(examples)} test suite examples for adaptive mode")
    #         except Exception as e:
                self.logger.warning(f"Failed to load test suite examples: {str(e)}")

    #         return examples

    #     def validate_output(
    #         self,
    #         ai_output: str,
    file_path: Optional[str] = None,
    correction_callback: Optional[Callable[[str, List[LinterError]], str]] = None
    #     ) -> GuardResult:
    #         """
    #         Validate AI output against NoodleCore syntax rules

    #         Args:
    #             ai_output: The AI-generated output to validate
    #             file_path: Optional file path for error reporting
    #             correction_callback: Optional callback to request corrections from AI

    #         Returns:
    #             GuardResult: Result of the validation
    #         """
    start_time = time.time()
    result = GuardResult(
    success = False,
    is_valid = False,
    original_output = ai_output,
    #         )

    #         try:
                self.logger.info(f"Starting validation of AI output (request_id: {result.request_id})")
    self.stats["total_validations"] + = 1

    #             # Check file extension if strict mode is enabled
    #             if self.config.strict_file_extension and file_path:
    #                 if not self._check_file_extension(file_path):
                        result.errors.append(LinterError(
    code = "E801",
    message = f"File extension not allowed: {file_path}",
    severity = "error",
    category = "guard",
    file = file_path,
    suggestion = f"Use one of the allowed extensions: {', '.join(self.config.allowed_extensions)}",
    #                     ))

    #             # Perform validation based on mode
    #             if self.config.mode == GuardMode.STRICT:
    linter_result = self._validate_strict(ai_output, file_path)
    #             elif self.config.mode == GuardMode.ADAPTIVE:
    linter_result = self._validate_adaptive(ai_output, file_path)
    #             else:  # PERMISSIVE
    linter_result = self._validate_permissive(ai_output, file_path)

    #             # Update result with linter findings
                result.errors.extend(linter_result.errors)
                result.warnings.extend(linter_result.warnings)
    result.is_valid = len(result.errors) == 0

    #             # Handle validation failure
    #             if not result.is_valid:
    #                 if self.config.action_on_failure == GuardAction.BLOCK:
    result.success = False
                        self.logger.warning(f"Validation failed, blocking output (request_id: {result.request_id})")
    #                 elif self.config.action_on_failure == GuardAction.REQUEST_CORRECTION:
    #                     if correction_callback and result.correction_attempts < self.config.max_correction_attempts:
    result = self._request_correction(
    #                             ai_output, result.errors, correction_callback, result, file_path
    #                         )
    #                     else:
    result.success = False
                            self.logger.warning(
                                f"Validation failed, max correction attempts reached (request_id: {result.request_id})"
    #                         )
    #                 elif self.config.action_on_failure == GuardAction.WARN:
    result.success = True
                        self.logger.warning(
    #                         f"Validation failed, allowing with warnings (request_id: {result.request_id})"
    #                     )
    #             else:
    result.success = True
                    self.logger.info(f"Validation successful (request_id: {result.request_id})")

    #             # Update statistics
    #             if result.success:
    self.stats["successful_validations"] + = 1
    #             else:
    self.stats["failed_validations"] + = 1

    #         except Exception as e:
                result.errors.append(LinterError(
    code = "E801",
    message = f"Internal guard error: {str(e)}",
    severity = "error",
    category = "guard",
    file = file_path,
    #             ))
    result.success = False
                self.logger.error(f"Internal guard error (request_id: {result.request_id}): {str(e)}")

    #         # Calculate execution time
    result.execution_time_ms = math.multiply(int((time.time() - start_time), 1000))
    self.stats["total_time_ms"] + = result.execution_time_ms

    #         return result

    #     def _check_file_extension(self, file_path: str) -> bool:
    #         """Check if file extension is allowed"""
    ext = Path(file_path).suffix.lower()
    #         return ext in self.config.allowed_extensions

    #     def _validate_strict(self, ai_output: str, file_path: Optional[str] = None) -> LinterResult:
    #         """Validate in strict mode"""
    #         # Check cache first
    #         cache_key = hash(ai_output) if self.config.cache_enabled else None
    #         if cache_key is not None and self._validation_cache and cache_key in self._validation_cache:
    #             return self._validation_cache[cache_key]

    #         # Use linter with strict configuration
    self.linter.config.strict_mode = True
    linter_result = self.linter.lint_source(ai_output, file_path)

    #         # Additional strict checks
    #         if not ai_output.strip().endswith(';'):
    #             # In strict mode, all statements must end with semicolons
                linter_result.errors.append(LinterError(
    code = "E802",
    #                 message="Code must end with semicolon in strict mode",
    severity = "error",
    category = "guard",
    file = file_path,
    suggestion = "Add semicolon at the end of the code",
    #             ))

    #         # Cache the result
    #         if cache_key is not None and self._validation_cache is not None:
    self._validation_cache[cache_key] = linter_result

    #         return linter_result

    #     def _validate_adaptive(self, ai_output: str, file_path: Optional[str] = None) -> LinterResult:
    #         """Validate in adaptive mode"""
    #         # Check cache first
    #         cache_key = hash(ai_output) if self.config.cache_enabled else None
    #         if cache_key is not None and self._validation_cache and cache_key in self._validation_cache:
    #             return self._validation_cache[cache_key]

    #         # Use linter with standard configuration
    self.linter.config.strict_mode = False
    linter_result = self.linter.lint_source(ai_output, file_path)

    #         # Compare with test suite examples
    similarity_score = self._calculate_similarity_with_examples(ai_output)

    #         if similarity_score < 0.5:  # Threshold for similarity
                linter_result.warnings.append(LinterError(
    code = "W801",
    #                 message=f"Low similarity ({similarity_score:.2f}) with test suite examples",
    severity = "warning",
    category = "guard",
    file = file_path,
    suggestion = "Review code structure to match NoodleCore patterns",
    #             ))

    #         # Cache the result
    #         if cache_key is not None and self._validation_cache is not None:
    self._validation_cache[cache_key] = linter_result

    #         return linter_result

    #     def _validate_permissive(self, ai_output: str, file_path: Optional[str] = None) -> LinterResult:
    #         """Validate in permissive mode"""
    #         # Check cache first
    #         cache_key = hash(ai_output) if self.config.cache_enabled else None
    #         if cache_key is not None and self._validation_cache and cache_key in self._validation_cache:
    #             return self._validation_cache[cache_key]

    #         # Use linter with permissive configuration
    self.linter.config.strict_mode = False
    self.linter.config.enable_validation_rules = False  # Disable style rules
    linter_result = self.linter.lint_source(ai_output, file_path)

    #         # Only critical errors are considered in permissive mode
    linter_result.errors = [
    #             error for error in linter_result.errors
    #             if error.category in ["syntax", "semantic", "compiler"]
    #         ]

    #         # Cache the result
    #         if cache_key is not None and self._validation_cache is not None:
    self._validation_cache[cache_key] = linter_result

    #         return linter_result

    #     def _calculate_similarity_with_examples(self, ai_output: str) -> float:
    #         """Calculate similarity score with test suite examples"""
    #         if not self._test_suite_examples:
    #             return 0.0

    #         # Simple similarity calculation based on common patterns
    #         ai_lines = set(line.strip() for line in ai_output.split('\n') if line.strip())

    max_similarity = 0.0
    #         for example in self._test_suite_examples:
    #             example_lines = set(line.strip() for line in example.split('\n') if line.strip())

    #             # Calculate Jaccard similarity
    intersection = len(ai_lines.intersection(example_lines))
    union = len(ai_lines.union(example_lines))

    #             if union > 0:
    similarity = math.divide(intersection, union)
    max_similarity = max(max_similarity, similarity)

    #         return max_similarity

    #     def _request_correction(
    #         self,
    #         original_output: str,
    #         errors: List[LinterError],
    #         correction_callback: Callable[[str, List[LinterError]], str],
    #         result: GuardResult,
    file_path: Optional[str] = None
    #     ) -> GuardResult:
    #         """Request correction from AI"""
            self.logger.info(f"Requesting correction (attempt {result.correction_attempts + 1})")
    self.stats["correction_requests"] + = 1

    #         try:
    #             # Call the correction callback
    corrected_output = correction_callback(original_output, errors)

    #             # Validate the corrected output
    result.correction_attempts + = 1
    result.corrected_output = corrected_output

    #             # Perform validation on corrected output
    #             if self.config.mode == GuardMode.STRICT:
    linter_result = self._validate_strict(corrected_output, file_path)
    #             elif self.config.mode == GuardMode.ADAPTIVE:
    linter_result = self._validate_adaptive(corrected_output, file_path)
    #             else:  # PERMISSIVE
    linter_result = self._validate_permissive(corrected_output, file_path)

    #             # Update result with new findings
    result.errors = linter_result.errors
    result.warnings = linter_result.warnings
    result.is_valid = len(result.errors) == 0

    #             # If still invalid and we have more attempts, try again
    #             if not result.is_valid and result.correction_attempts < self.config.max_correction_attempts:
                    return self._request_correction(
    #                     original_output, result.errors, correction_callback, result, file_path
    #                 )
    #             elif result.is_valid:
    result.success = True
                    self.logger.info(f"Correction successful after {result.correction_attempts} attempts")
    #             else:
    result.success = False
                    self.logger.warning(f"Correction failed after {result.correction_attempts} attempts")

    #         except Exception as e:
                result.errors.append(LinterError(
    code = "E803",
    message = f"Correction request failed: {str(e)}",
    severity = "error",
    category = "guard",
    file = file_path,
    #             ))
    result.success = False
                self.logger.error(f"Correction request failed: {str(e)}")

    #         return result

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get guard statistics"""
    #         return {
    #             "total_validations": self.stats["total_validations"],
    #             "successful_validations": self.stats["successful_validations"],
    #             "failed_validations": self.stats["failed_validations"],
    #             "correction_requests": self.stats["correction_requests"],
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
    #         """Reset guard statistics"""
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "correction_requests": 0,
    #             "total_time_ms": 0,
    #         }
            self.logger.info("Statistics reset")