# Converted from Python to NoodleCore
# Original file: src

# """
# NoodleCore Validator
# ---------------------
# This module provides the main validator functionality for NoodleCore code,
# serving as the strict enforcer of the NoodleCore language specification.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import logging
import os
import time
import uuid
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.List

import ..compiler.frontend.CompilerFrontend
import ..compiler.parser_ast_nodes.ProgramNode
import .foreign_syntax_detector.ForeignSyntaxDetector
import .ast_verifier.ASTVerifier
import .auto_corrector.AutoCorrector
import .result_reporter.ValidationResultReporter
import .exceptions.(
#     ValidationError, ValidatorInitializationError, FileAccessError,
#     ParsingError, ConfigurationError, TimeoutError, create_validation_error
# )


class ValidationMode(Enum)
    #     """Validation modes for different use cases"""
    STRICT = "strict"  # Strict validation, no auto-correction
    LENIENT = "lenient"  # Allow warnings but not errors
    AUTO_CORRECT = "auto_correct"  # Attempt auto-correction
    SYNTAX_ONLY = "syntax_only"  # Only check syntax, not semantics


dataclass
class ValidatorConfig
    #     """Configuration for the NoodleCore validator"""

    #     # Validation settings
    mode: ValidationMode = ValidationMode.STRICT
    timeout_ms: int = 30000  # 30 seconds
    max_file_size_mb: int = 10
    enable_ast_verification: bool = True
    enable_foreign_syntax_detection: bool = True
    enable_auto_correction: bool = False

    #     # Reporting settings
    report_format: ReportFormat = ReportFormat.CONSOLE
    report_level: ReportLevel = ReportLevel.STANDARD
    save_report: bool = False
    report_file_path: Optional[str] = None

    #     # Performance settings
    enable_caching: bool = True
    cache_size: int = 100
    enable_parallel_processing: bool = False
    max_workers: int = 4

    #     # Logging settings
    log_level: str = "INFO"
    enable_performance_logging: bool = False

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert config to dictionary"""
    #         return {
    #             "mode": self.mode.value,
    #             "timeout_ms": self.timeout_ms,
    #             "max_file_size_mb": self.max_file_size_mb,
    #             "enable_ast_verification": self.enable_ast_verification,
    #             "enable_foreign_syntax_detection": self.enable_foreign_syntax_detection,
    #             "enable_auto_correction": self.enable_auto_correction,
    #             "report_format": self.report_format.value,
    #             "report_level": self.report_level.value,
    #             "save_report": self.save_report,
    #             "report_file_path": self.report_file_path,
    #             "enable_caching": self.enable_caching,
    #             "cache_size": self.cache_size,
    #             "enable_parallel_processing": self.enable_parallel_processing,
    #             "max_workers": self.max_workers,
    #             "log_level": self.log_level,
    #             "enable_performance_logging": self.enable_performance_logging
    #         }


class NoodleCoreValidator
    #     """
    #     Main validator for NoodleCore code

    #     This class serves as the strict enforcer of the NoodleCore language specification,
    #     providing comprehensive validation including syntax checking, AST verification,
    #     foreign syntax detection, and auto-correction capabilities.
    #     """

    #     def __init__(self, config: Optional[ValidatorConfig] = None):""
    #         Initialize the NoodleCore validator

    #         Args:
    #             config: Validator configuration
    #         """
    self.config = config or ValidatorConfig()

    #         # Setup logging
    self.logger = self._setup_logging()

    #         try:
    #             # Initialize components
    self.frontend = CompilerFrontend()
    self.foreign_syntax_detector = ForeignSyntaxDetector()
    self.ast_verifier = ASTVerifier()
    self.auto_corrector = AutoCorrector()
    self.result_reporter = ValidationResultReporter(self.config.log_level)

    #             # Performance tracking
    self.stats = {
    #                 "total_validations": 0,
    #                 "successful_validations": 0,
    #                 "failed_validations": 0,
    #                 "total_time_ms": 0,
    #                 "files_validated": 0,
    #                 "lines_validated": 0,
    #                 "issues_found": 0,
    #                 "corrections_applied": 0
    #             }

    #             # Cache for validation results
    #             self._validation_cache = {} if self.config.enable_caching else None

                self.logger.info("NoodleCore validator initialized successfully")

    #         except Exception as e:
                self.logger.error(f"Failed to initialize validator: {e}")
                raise ValidatorInitializationError(f"Failed to initialize validator: {e}")

    #     def _setup_logging(self) -logging.Logger):
    #         """Setup logging for the validator"""
    logger = logging.getLogger("noodlecore.validator")
            logger.setLevel(getattr(logging, self.config.log_level.upper()))

    #         # Create formatter
    formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #         )

    #         # Create console handler
    console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)

    #         return logger

    #     def validate_code(
    #         self,
    #         code: str,
    file_path: Optional[str] = None,
    request_id: Optional[str] = None
    #     ) -ValidationReport):
    #         """
    #         Validate NoodleCore code

    #         Args:
    #             code: The code to validate
    #             file_path: Optional file path for error reporting
    #             request_id: Optional request ID for tracking

    #         Returns:
    #             ValidationReport with validation results
    #         """
    start_time = time.time()
    request_id = request_id or str(uuid.uuid4())

            self.logger.info(f"Starting validation (request_id: {request_id})")
    self.stats["total_validations"] + = 1

    #         try:
    #             # Check cache first
    cache_key = None
    #             if self._validation_cache is not None:
    #                 import hashlib
    content_hash = hashlib.md5(code.encode()).hexdigest()
    cache_key = f"{content_hash}:{self.config.mode.value}"

    #                 if cache_key in self._validation_cache:
                        self.logger.info(f"Using cached validation result (request_id: {request_id})")
    cached_report = self._validation_cache[cache_key]
    #                     return cached_report

    #             # Parse the code
    parse_result = self._parse_code(code, file_path)

    #             # Collect all issues
    all_issues = []

    #             # Check for foreign syntax
    #             if self.config.enable_foreign_syntax_detection:
    foreign_issues = self.foreign_syntax_detector.detect_foreign_syntax(code)
                    all_issues.extend(foreign_issues)

    #             # Verify AST structure
    ast_issues = []
    #             if self.config.enable_ast_verification and parse_result.success and parse_result.ast:
    ast_issues = self.ast_verifier.verify_ast(parse_result.ast)
                    all_issues.extend(ast_issues)

    #             # Apply auto-correction if enabled
    auto_correction_result = None
    corrected_code = code

    #             if self.config.enable_auto_correction or self.config.mode == ValidationMode.AUTO_CORRECT:
    auto_correction_result = self.auto_corrector.auto_correct(code, all_issues)
    corrected_code = auto_correction_result.corrected_code

    #                 # Re-parse corrected code to verify
    #                 if auto_correction_result.success:
    #                     try:
    corrected_parse_result = self._parse_code(corrected_code, file_path)
    #                         if corrected_parse_result.success:
    #                             # Re-verify AST if needed
    #                             if self.config.enable_ast_verification and corrected_parse_result.ast:
    corrected_ast_issues = self.ast_verifier.verify_ast(corrected_parse_result.ast)
                                    auto_correction_result.remaining_issues.extend(corrected_ast_issues)
    #                     except Exception as e:
                            self.logger.warning(f"Failed to re-parse corrected code: {e}")

    #             # Create validation report
    report = self.result_reporter.create_report(
    issues = all_issues,
    auto_correction_result = auto_correction_result,
    file_path = file_path,
    execution_time_ms = int((time.time() - start_time) * 1000,)
    request_id = request_id
    #             )

    #             # Update statistics
                self._update_stats(report, len(code.split('\n')))

    #             # Cache result
    #             if self._validation_cache is not None and cache_key is not None:
    self._validation_cache[cache_key] = report

    #             # Save report if requested
    #             if self.config.save_report and self.config.report_file_path:
                    self.result_reporter.save_report(
    #                     report,
    #                     self.config.report_file_path,
    #                     self.config.report_format,
    #                     self.config.report_level
    #                 )

    #             # Log result
                self.logger.info(f"Validation completed (request_id: {request_id}): "
    #                            f"{'VALID' if report.exit_code = 0 else 'INVALID'} "
    #                            f"with {report.total_issues} issues")

    #             return report

    #         except TimeoutError:
    self.stats["failed_validations"] + = 1
                self.logger.error(f"Validation timeout (request_id: {request_id})")
    #             raise
    #         except Exception as e:
    self.stats["failed_validations"] + = 1
                self.logger.error(f"Validation failed (request_id: {request_id}): {e}")

    #             # Create error report
    error_report = ValidationReport(
    request_id = request_id,
    file_path = file_path,
    timestamp = time.time(),
    exit_code = 1,
    total_issues = 1,
    error_count = 1,
    warning_count = 0,
    info_count = 0,
    issues = [ValidationIssue(
    line_number = 0,
    column = 0,
    severity = ValidationSeverity.ERROR,
    message = f"Validation failed: {str(e)}",
    error_code = 1001
    #                 )],
    execution_time_ms = int((time.time() - start_time) * 1000)
    #             )

    #             return error_report

    #     def validate_file(self, file_path: str) -ValidationReport):
    #         """
    #         Validate a NoodleCore file

    #         Args:
    #             file_path: Path to the file to validate

    #         Returns:
    #             ValidationReport with validation results
    #         """
    #         try:
    #             # Check file size
    file_size_mb = os.path.getsize(file_path) / (1024 * 1024)
    #             if file_size_mb self.config.max_file_size_mb):
                    raise FileAccessError(
    #                     file_path,
                        f"File too large ({file_size_mb:.2f}MB {self.config.max_file_size_mb}MB)"
    #                 )

    #             # Read file
    #             with open(file_path, 'r', encoding='utf-8') as f):
    code = f.read()

    #             # Validate code
                return self.validate_code(code, file_path)

    #         except IOError as e:
                raise FileAccessError(file_path, str(e))

    #     def validate_directory(
    #         self,
    #         directory_path: str,
    pattern: str = "*.nc",
    recursive: bool = True
    #     ) -List[ValidationReport]):
    #         """
    #         Validate all NoodleCore files in a directory

    #         Args:
    #             directory_path: Path to the directory
    #             pattern: File pattern to match
    #             recursive: Whether to search recursively

    #         Returns:
    #             List of validation reports
    #         """
    reports = []

    #         try:
    #             # Find files
    path = Path(directory_path)
    #             if recursive:
    files = list(path.rglob(pattern))
    #             else:
    files = list(path.glob(pattern))

    #             # Validate each file
    #             for file_path in files:
    #                 if file_path.is_file():
    #                     try:
    report = self.validate_file(str(file_path))
                            reports.append(report)
    #                     except Exception as e:
                            self.logger.error(f"Failed to validate file {file_path}: {e}")

    #             return reports

    #         except Exception as e:
                raise FileAccessError(directory_path, str(e))

    #     def is_valid_noodlecore(self, code: str) -bool):
    #         """
    #         Check if code is valid NoodleCore

    #         Args:
    #             code: The code to check

    #         Returns:
    #             True if valid, False otherwise
    #         """
    report = self.validate_code(code)
    return report.exit_code = 0

    #     def get_validation_summary(self, reports: List[ValidationReport]) -Dict[str, Any]):
    #         """
    #         Get a summary of validation results

    #         Args:
    #             reports: List of validation reports

    #         Returns:
    #             Summary dictionary
    #         """
    total_files = len(reports)
    #         valid_files = sum(1 for report in reports if report.exit_code = 0)
    #         total_issues = sum(report.total_issues for report in reports)
    #         total_errors = sum(report.error_count for report in reports)
    #         total_warnings = sum(report.warning_count for report in reports)
    #         total_corrections = sum(len(report.corrections) for report in reports)

    #         return {
    #             "total_files": total_files,
    #             "valid_files": valid_files,
    #             "invalid_files": total_files - valid_files,
    #             "success_rate": valid_files / total_files if total_files 0 else 0,
    #             "total_issues"): total_issues,
    #             "total_errors": total_errors,
    #             "total_warnings": total_warnings,
    #             "total_corrections": total_corrections
    #         }

    #     def get_statistics(self) -Dict[str, Any]):
    #         """
    #         Get validator statistics

    #         Returns:
    #             Statistics dictionary
    #         """
    stats = self.stats.copy()

    #         # Calculate averages
    #         if stats["total_validations"] 0):
    stats["success_rate"] = stats["successful_validations"] / stats["total_validations"]
    stats["average_time_ms"] = stats["total_time_ms"] / stats["total_validations"]
    #         else:
    stats["success_rate"] = 0
    stats["average_time_ms"] = 0

    #         # Add cache statistics
    #         if self._validation_cache is not None:
    stats["cache_size"] = len(self._validation_cache)
    #         else:
    stats["cache_size"] = 0

    #         return stats

    #     def reset_statistics(self):
    #         """Reset validator statistics"""
    self.stats = {
    #             "total_validations": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "total_time_ms": 0,
    #             "files_validated": 0,
    #             "lines_validated": 0,
    #             "issues_found": 0,
    #             "corrections_applied": 0
    #         }
            self.logger.info("Validator statistics reset")

    #     def clear_cache(self):
    #         """Clear validation cache"""
    #         if self._validation_cache is not None:
                self._validation_cache.clear()
                self.logger.info("Validation cache cleared")

    #     def update_config(self, config: ValidatorConfig):
    #         """
    #         Update validator configuration

    #         Args:
    #             config: New configuration
    #         """
    self.config = config

    #         # Update logging level
            self.logger.setLevel(getattr(logging, config.log_level.upper()))

    #         # Update cache settings
    #         if not config.enable_caching:
    self._validation_cache = None
    #         elif self._validation_cache is None:
    self._validation_cache = {}

            self.logger.info("Validator configuration updated")

    #     def _parse_code(self, code: str, file_path: Optional[str] = None) -ParseResult):
    #         """
    #         Parse code into an AST

    #         Args:
    #             code: The code to parse
    #             file_path: Optional file path

    #         Returns:
    #             ParseResult with AST or errors
    #         """
    #         try:
    #             # Set timeout
    #             if self.config.timeout_ms 0):
    #                 import signal

    #                 def timeout_handler(signum, frame):
                        raise TimeoutError(
    #                         "Parsing timeout",
    timeout_ms = self.config.timeout_ms,
    operation = "parsing"
    #                     )

                    signal.signal(signal.SIGALRM, timeout_handler)
                    signal.alarm(self.config.timeout_ms // 1000)

    #             # Parse the code
    parse_result = self.frontend.parse(code, file_path, ParsingMode.FULL)

    #             # Cancel timeout
    #             if self.config.timeout_ms 0):
                    signal.alarm(0)

    #             return parse_result

    #         except Exception as e:
    #             if isinstance(e, TimeoutError):
    #                 raise

    #             # Convert to parsing error
                raise ParsingError(str(e))

    #     def _update_stats(self, report: ValidationReport, lines_validated: int):
    #         """
    #         Update validator statistics

    #         Args:
    #             report: Validation report
    #             lines_validated: Number of lines validated
    #         """
    self.stats["total_time_ms"] + = report.execution_time_ms

    #         if report.exit_code = 0:
    self.stats["successful_validations"] + = 1
    #         else:
    self.stats["failed_validations"] + = 1

    self.stats["files_validated"] + = 1
    self.stats["lines_validated"] + = lines_validated
    self.stats["issues_found"] + = report.total_issues
    self.stats["corrections_applied"] + = len(report.corrections)


# Global validator instance
_validator_instance: Optional[NoodleCoreValidator] = None


def get_validator(config: Optional[ValidatorConfig] = None) -NoodleCoreValidator):
#     """
#     Get the global validator instance

#     Args:
#         config: Optional configuration

#     Returns:
#         NoodleCoreValidator instance
#     """
#     global _validator_instance

#     if _validator_instance is None:
_validator_instance = NoodleCoreValidator(config)
#     elif config is not None:
        _validator_instance.update_config(config)

#     return _validator_instance


def validate_code(code: str, file_path: Optional[str] = None) -ValidationReport):
#     """
#     Convenience function to validate code

#     Args:
#         code: The code to validate
#         file_path: Optional file path

#     Returns:
#         ValidationReport with validation results
#     """
validator = get_validator()
    return validator.validate_code(code, file_path)


def validate_file(file_path: str) -ValidationReport):
#     """
#     Convenience function to validate a file

#     Args:
#         file_path: Path to the file to validate

#     Returns:
#         ValidationReport with validation results
#     """
validator = get_validator()
    return validator.validate_file(file_path)


def is_valid_noodlecore(code: str) -bool):
#     """
#     Convenience function to check if code is valid NoodleCore

#     Args:
#         code: The code to check

#     Returns:
#         True if valid, False otherwise
#     """
validator = get_validator()
    return validator.is_valid_noodlecore(code)