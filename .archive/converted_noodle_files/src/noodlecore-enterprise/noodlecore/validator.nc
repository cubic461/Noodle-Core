# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Validator - 100% NoodleCore Validation
# -------------------------------------------------
# This module provides comprehensive validation for NoodleCore code to ensure
# 100% compliance with the NoodleCore language specification.

# The validator serves as the strict enforcer of the NoodleCore language
# specification, detecting any foreign syntax and ensuring all code is pure
# NoodleCore.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import sys
import time
import uuid
import logging
import re
import dataclasses.dataclass,
import enum.Enum
import pathlib.Path
import typing.Any,

# Import compiler components
import .compiler.frontend.CompilerFrontend,
import .compiler.ast_nodes.ASTNode,
import .compiler.parser_ast_nodes.ProgramNode
import .error_handler.NoodleCoreError

# Import validator components
import .validator.foreign_syntax_detector.ForeignSyntaxDetector
import .validator.ast_verifier.ASTVerifier
import .validator.auto_corrector.AutoCorrector
import .validator.result_reporter.ValidationResultReporter


class ValidationMode(Enum)
    #     """Modes for validation operations"""
    STRICT = "strict"  # Strict validation, no foreign syntax allowed
    PERMISSIVE = "permissive"  # Allow some non-critical foreign syntax
    AUTO_CORRECT = "auto_correct"  # Attempt to auto-correct issues


class ValidationSeverity(Enum)
    #     """Severity levels for validation issues"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


# @dataclass
class ValidationIssue
    #     """Represents a validation issue"""

    #     severity: ValidationSeverity
    #     code: str  # 4-digit error code
    #     message: str
    line: Optional[int] = None
    column: Optional[int] = None
    end_line: Optional[int] = None
    end_column: Optional[int] = None
    suggestion: Optional[str] = None
    auto_correctable: bool = False

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "severity": self.severity.value,
    #             "code": self.code,
    #             "message": self.message,
    #             "line": self.line,
    #             "column": self.column,
    #             "endLine": self.end_line,
    #             "endColumn": self.end_column,
    #             "suggestion": self.suggestion,
    #             "autoCorrectable": self.auto_correctable,
    #         }


# @dataclass
class ValidationResult
    #     """Represents the result of a validation operation"""

    #     request_id: str
    #     is_valid: bool
    issues: List[ValidationIssue] = field(default_factory=list)
    corrected_code: Optional[str] = None
    execution_time_ms: int = 0
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "isValid": self.is_valid,
    #             "issues": [issue.to_dict() for issue in self.issues],
    #             "correctedCode": self.corrected_code,
    #             "executionTimeMs": self.execution_time_ms,
    #             "timestamp": self.timestamp,
    #         }

    #     def get_exit_code(self) -> int:
    #         """Get the appropriate exit code for this result"""
    #         if self.is_valid:
    #             return 0
    #         elif self.corrected_code is not None:
    #             return 2  # Auto-correction was attempted
    #         else:
    #             return 1  # Invalid code


# @dataclass
class ValidationRequest
    #     """Represents a validation request"""

    #     code: str
    file_path: Optional[str] = None
    mode: ValidationMode = ValidationMode.STRICT
    auto_correct: bool = False
    metadata: Dict[str, Any] = field(default_factory=dict)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "code": self.code,
    #             "filePath": self.file_path,
    #             "mode": self.mode.value,
    #             "autoCorrect": self.auto_correct,
    #             "metadata": self.metadata,
    #             "timestamp": self.timestamp,
    #         }


class ValidatorError(Exception)
    #     """Exception raised by the validator"""

    #     def __init__(self, message: str, code: int = 1001, details: Optional[Dict[str, Any]] = None):
    self.message = message
    self.code = code
    self.details = details or {}
            super().__init__(self.message)

    #     def __str__(self):
    #         return f"ValidatorError[{self.code}]: {self.message}"


class NoodleCoreValidator
    #     """
    #     100% NoodleCore Validator

    #     This class provides comprehensive validation for NoodleCore code to ensure
    #     100% compliance with the NoodleCore language specification. It serves as
    #     the strict enforcer of the NoodleCore language specification.
    #     """

    #     def __init__(self, mode: ValidationMode = ValidationMode.STRICT):
    #         """Initialize the NoodleCore validator"""
    self.mode = mode

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Initialize compiler frontend
    self._frontend = CompilerFrontend()

    #         # Initialize validator components
    self._foreign_syntax_detector = ForeignSyntaxDetector()
    self._ast_verifier = ASTVerifier()
    self._auto_corrector = AutoCorrector()
    self._result_reporter = ValidationResultReporter()

    #         # Performance tracking
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "auto_corrections": 0,
    #             "total_time_ms": 0,
    #         }

    #         self.logger.info(f"NoodleCore validator initialized with mode: {self.mode.value}")

    #     def _setup_logging(self) -> logging.Logger:
    #         """Setup logging for the validator"""
    logger = logging.getLogger("noodlecore.validator")
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
    file_path: Optional[str] = None,
    mode: Optional[ValidationMode] = None,
    auto_correct: Optional[bool] = None
    #     ) -> ValidationResult:
    #         """
    #         Validate NoodleCore code

    #         Args:
    #             code: The code to validate
    #             file_path: Optional file path for error reporting
                mode: Validation mode (defaults to instance mode)
    #             auto_correct: Whether to attempt auto-correction

    #         Returns:
    #             ValidationResult: Result of the validation operation
    #         """
    start_time = time.time()

    #         # Create validation request
    request = ValidationRequest(
    code = code,
    file_path = file_path,
    mode = mode or self.mode,
    #             auto_correct=auto_correct if auto_correct is not None else (self.mode == ValidationMode.AUTO_CORRECT)
    #         )

            self.logger.info(f"Processing validation request (request_id: {request.request_id})")
    self.stats["total_validations"] + = 1

    #         try:
    #             # Parse the code first
    parse_result = self._frontend.parse(
    code = code,
    file_path = file_path,
    mode = ParsingMode.FULL
    #             )

    #             # Create validation result
    result = ValidationResult(
    request_id = request.request_id,
    is_valid = True,  # Assume valid until issues are found
    execution_time_ms = math.multiply(int((time.time() - start_time), 1000))
    #             )

    #             # Check for parsing errors
    #             if not parse_result.success:
    #                 for error in parse_result.errors:
                        result.issues.append(ValidationIssue(
    severity = ValidationSeverity.ERROR,
    code = "1001",
    message = f"Parse error: {str(error)}",
    line = getattr(error, 'line_number', None),
    column = getattr(error, 'column', None)
    #                     ))
    result.is_valid = False

    #             # Detect foreign syntax
    foreign_issues = self._foreign_syntax_detector.detect(code, file_path)
                result.issues.extend(foreign_issues)

    #             # Verify AST if parsing was successful
    #             if parse_result.success and parse_result.ast:
    ast_issues = self._ast_verifier.verify(parse_result.ast, request.mode)
                    result.issues.extend(ast_issues)

    #             # Determine if code is valid based on mode and issues
    result.is_valid = self._determine_validity(result.issues, request.mode)

    #             # Attempt auto-correction if requested and needed
    #             if not result.is_valid and request.auto_correct:
    correction_result = self._auto_corrector.correct(code, result.issues)
    #                 if correction_result:
    result.corrected_code = correction_result
    self.stats["auto_corrections"] + = 1

    #             # Update statistics
    #             if result.is_valid:
    self.stats["successful_validations"] + = 1
    #             else:
    self.stats["failed_validations"] + = 1

    self.stats["total_time_ms"] + = result.execution_time_ms

                self.logger.info(f"Validation completed (request_id: {request.request_id}): "
    #                            f"{'Valid' if result.is_valid else 'Invalid'}")
    #             return result

    #         except Exception as e:
    #             # Create error result
    error_result = ValidationResult(
    request_id = request.request_id,
    is_valid = False,
    issues = [ValidationIssue(
    severity = ValidationSeverity.CRITICAL,
    code = "1002",
    message = f"Validation error: {str(e)}"
    #                 )],
    execution_time_ms = math.multiply(int((time.time() - start_time), 1000))
    #             )

    #             # Update statistics
    self.stats["failed_validations"] + = 1
    self.stats["total_time_ms"] + = error_result.execution_time_ms

                self.logger.error(f"Validation failed (request_id: {request.request_id}): {str(e)}")
    #             return error_result

    #     def validate_file(self, file_path: str) -> ValidationResult:
    #         """
    #         Validate a NoodleCore file

    #         Args:
    #             file_path: Path to the file to validate

    #         Returns:
    #             ValidationResult: Result of the validation operation
    #         """
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()

                return self.validate(code, file_path)

    #         except IOError as e:
                raise ValidatorError(f"Failed to read file: {str(e)}", 1003)

    #     def _determine_validity(
    #         self,
    #         issues: List[ValidationIssue],
    #         mode: ValidationMode
    #     ) -> bool:
    #         """Determine if code is valid based on issues and mode"""
    #         if not issues:
    #             return True

    #         if mode == ValidationMode.STRICT:
    #             # In strict mode, any issue makes the code invalid
                return not any(issue.severity in [ValidationSeverity.ERROR, ValidationSeverity.CRITICAL]
    #                           for issue in issues)

    #         elif mode == ValidationMode.PERMISSIVE:
    #             # In permissive mode, only errors and critical issues make the code invalid
                return not any(issue.severity in [ValidationSeverity.CRITICAL]
    #                           for issue in issues)

    #         elif mode == ValidationMode.AUTO_CORRECT:
    #             # In auto-correct mode, only critical issues make the code invalid
                return not any(issue.severity in [ValidationSeverity.CRITICAL]
    #                           for issue in issues)

    #         return False

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
    #             "auto_corrections": self.stats["auto_corrections"],
                "auto_correction_rate": (
    #                 self.stats["auto_corrections"] / self.stats["total_validations"]
    #                 if self.stats["total_validations"] > 0 else 0
    #             ),
    #             "total_time_ms": self.stats["total_time_ms"],
                "average_time_ms": (
    #                 self.stats["total_time_ms"] / self.stats["total_validations"]
    #                 if self.stats["total_validations"] > 0 else 0
    #             ),
    #             "mode": self.mode.value,
    #         }

    #     def reset_statistics(self):
    #         """Reset validator statistics"""
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "auto_corrections": 0,
    #             "total_time_ms": 0,
    #         }
            self.logger.info("Statistics reset")


# Global validator instance
_validator_instance: Optional[NoodleCoreValidator] = None


def get_validator(mode: ValidationMode = ValidationMode.STRICT) -> NoodleCoreValidator:
#     """
#     Get the global validator instance

#     Args:
#         mode: Validation mode

#     Returns:
#         NoodleCoreValidator: The validator instance
#     """
#     global _validator_instance

#     if _validator_instance is None:
_validator_instance = NoodleCoreValidator(mode)
#     elif mode != _validator_instance.mode:
#         # Create new instance if mode is different
_validator_instance = NoodleCoreValidator(mode)

#     return _validator_instance


def validate_code(
#     code: str,
file_path: Optional[str] = None,
mode: ValidationMode = ValidationMode.STRICT,
auto_correct: bool = False
# ) -> ValidationResult:
#     """
#     Convenience function to validate code

#     Args:
#         code: The code to validate
#         file_path: Optional file path
#         mode: Validation mode
#         auto_correct: Whether to attempt auto-correction

#     Returns:
#         ValidationResult: Result of the validation operation
#     """
validator = get_validator(mode)
    return validator.validate(code, file_path, mode, auto_correct)


def validate_file(
#     file_path: str,
mode: ValidationMode = ValidationMode.STRICT,
auto_correct: bool = False
# ) -> ValidationResult:
#     """
#     Convenience function to validate a file

#     Args:
#         file_path: Path to the file to validate
#         mode: Validation mode
#         auto_correct: Whether to attempt auto-correction

#     Returns:
#         ValidationResult: Result of the validation operation
#     """
validator = get_validator(mode)
    return validator.validate_file(file_path)


function main()
    #     """Main entry point for the validator CLI"""
    #     import argparse

    parser = argparse.ArgumentParser(description="NoodleCore Validator - 100% NoodleCore Validation")
    parser.add_argument("file", help = "File to validate")
    parser.add_argument("--mode", choices = ["strict", "permissive", "auto_correct"],
    default = "strict", help="Validation mode")
    parser.add_argument("--auto-correct", action = "store_true",
    help = "Attempt to auto-correct issues")
    #     parser.add_argument("--output", help="Output file for validation report")
    parser.add_argument("--format", choices = ["text", "json"], default="text",
    help = "Output format")
    parser.add_argument("--quiet", action = "store_true",
    help = "Only output validation result")

    args = parser.parse_args()

    #     # Convert mode string to enum
    mode = ValidationMode(args.mode)

    #     # Validate the file
    result = validate_file(args.file, mode, args.auto_correct)

    #     # Generate report
    #     if args.format == "json":
    #         import json
    report = json.dumps(result.to_dict(), indent=2)
    #     else:
    report = _result_reporter.generate_text_report(result)

    #     # Output report
    #     if args.output:
    #         with open(args.output, 'w') as f:
                f.write(report)
    #     elif not args.quiet:
            print(report)

    #     # Print validation result
    #     if result.is_valid:
            print("✅ Valid NoodleCore code")
    exit_code = 0
    #     elif result.corrected_code is not None:
            print("⚠️  Invalid NoodleCore code (auto-correction attempted)")
    exit_code = 2
    #     else:
            print("❌ Invalid NoodleCore code")
    exit_code = 1

    #     return exit_code


if __name__ == "__main__"
        sys.exit(main())