# Converted from Python to NoodleCore
# Original file: src

# """
# Validation Engine Module

# This module provides a centralized validation orchestration system that
# coordinates syntax and semantic validation, aggregates results, and provides
# reporting and formatting capabilities.
# """

import asyncio
import time
import typing.Dict
from dataclasses import dataclass
import enum.Enum
import logging
import json

import .validator_base.(
#     ValidatorBase, ValidationResult, ValidationIssue,
#     ValidationStatus, ValidationSeverity
# )
import .syntax_validator.SyntaxValidator
import .semantic_validator.SemanticValidator
import .validation_rules.(
#     RuleEngine, RuleContext, RuleResult, RuleCategory,
#     NoodleCoreRuleSet
# )
import .grammar.NoodleCoreGrammar


class ValidationMode(Enum)
    #     """Enumeration for validation modes."""
    SYNTAX_ONLY = "syntax_only"
    SEMANTIC_ONLY = "semantic_only"
    RULES_ONLY = "rules_only"
    SYNTAX_AND_SEMANTIC = "syntax_and_semantic"
    FULL = "full"  # All validators and rules


dataclass
class ValidationConfig
    #     """Configuration for validation operations."""
    mode: ValidationMode = ValidationMode.FULL
    strict_mode: bool = False
    enable_caching: bool = True
    enable_incremental: bool = False
    max_concurrent_validations: int = 10
    timeout_seconds: float = 30.0
    rule_categories: List[RuleCategory] = field(default_factory=list)
    custom_rules: List[str] = field(default_factory=list)
    output_format: str = "json"  # json, xml, text, html
    include_metrics: bool = True
    include_suggestions: bool = True


dataclass
class AggregatedResult
    #     """Aggregated validation result from multiple validators."""
    #     status: ValidationStatus
    #     total_issues: int
    #     error_count: int
    #     warning_count: int
    #     info_count: int
    results: Dict[str, ValidationResult] = field(default_factory=dict)
    rule_results: List[RuleResult] = field(default_factory=list)
    metrics: Dict[str, Any] = field(default_factory=dict)
    execution_time: float = 0.0
    timestamp: float = field(default_factory=time.time)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert the aggregated result to a dictionary."""
    #         return {
    #             "status": self.status.value,
    #             "summary": {
    #                 "total_issues": self.total_issues,
    #                 "error_count": self.error_count,
    #                 "warning_count": self.warning_count,
    #                 "info_count": self.info_count
    #             },
    #             "results": {
                    name: result.to_dict()
    #                 for name, result in self.results.items()
    #             },
    #             "rule_results": [
    #                 {
    #                     "rule_id": result.rule_id,
                        "issue_count": len(result.issues),
    #                     "execution_time": result.execution_time,
    #                     "enabled": result.enabled
    #                 }
    #                 for result in self.rule_results
    #             ],
    #             "metrics": self.metrics,
    #             "execution_time": self.execution_time,
    #             "timestamp": self.timestamp
    #         }


class ValidationEngine
    #     """Centralized validation orchestration system."""

    #     def __init__(self, config: Optional[ValidationConfig] = None):""
    #         Initialize the validation engine.

    #         Args:
    #             config: Optional validation configuration
    #         """
    self.config = config or ValidationConfig()
    self.logger = logging.getLogger("noodlecore.validators.engine")

    #         # Initialize validators
    self.syntax_validator = SyntaxValidator()
    self.semantic_validator = SemanticValidator()

    #         # Initialize rule engine
    self.rule_engine = RuleEngine()

    #         # Configure rule engine based on config
    #         if self.config.rule_categories:
    #             # Enable only specified categories
    #             for category in RuleCategory:
    #                 if category in self.config.rule_categories:
                        self.rule_engine.enable_category(category)
    #                 else:
                        self.rule_engine.disable_category(category)

    #         # Performance tracking
    self.metrics = {
    #             "validations_performed": 0,
    #             "total_validation_time": 0.0,
    #             "cache_hits": 0,
    #             "cache_misses": 0,
    #             "files_validated": 0,
    #             "lines_validated": 0
    #         }

    #         # Validation cache for incremental validation
    self.validation_cache = {}

    #     async def validate_code(self, code: str, file_path: Optional[str] = None,
    mode: Optional[ValidationMode] = None) - AggregatedResult):
    #         """
    #         Validate NoodleCore code.

    #         Args:
    #             code: NoodleCore code to validate
    #             file_path: Optional file path for reporting
    #             mode: Optional validation mode override

    #         Returns:
    #             AggregatedResult containing all validation results
    #         """
    start_time = time.time()
    validation_mode = mode or self.config.mode

    #         # Create aggregated result
    aggregated = AggregatedResult(status=ValidationStatus.PASSED)

    #         try:
    #             # Parse code once for all validators
    tokens, ast_root = self._parse_code(code)

    #             # Create rule context
    rule_context = RuleContext(
    code = code,
    tokens = tokens,
    ast_root = ast_root,
    file_path = file_path,
    config = self.config.__dict__
    #             )

    #             # Run validators based on mode
    #             if validation_mode in [ValidationMode.SYNTAX_ONLY, ValidationMode.SYNTAX_AND_SEMANTIC, ValidationMode.FULL]:
                    await self._run_syntax_validator(code, file_path, aggregated)

    #             if validation_mode in [ValidationMode.SEMANTIC_ONLY, ValidationMode.SYNTAX_AND_SEMANTIC, ValidationMode.FULL]:
                    await self._run_semantic_validator(code, file_path, aggregated)

    #             if validation_mode in [ValidationMode.RULES_ONLY, ValidationMode.FULL]:
                    await self._run_rule_engine(rule_context, aggregated)

    #             # Update metrics
    aggregated.execution_time = time.time() - start_time
                self._update_metrics(aggregated)

    #             # Determine overall status
    #             if aggregated.error_count 0):
    aggregated.status = ValidationStatus.FAILED
    #             elif aggregated.warning_count 0 and self.config.strict_mode):
    aggregated.status = ValidationStatus.FAILED

    #         except Exception as e:
                self.logger.error(f"Validation error: {str(e)}")
    aggregated.status = ValidationStatus.FAILED
    aggregated.execution_time = time.time() - start_time

    #             # Add error issue
    error_result = ValidationResult(
    status = ValidationStatus.FAILED,
    validator_name = "ValidationEngine",
    file_path = file_path
    #             )
                error_result.add_issue(ValidationIssue(
    message = f"Validation failed: {str(e)}",
    severity = ValidationSeverity.ERROR,
    code = "2901"
    #             ))
    aggregated.results["engine_error"] = error_result
    aggregated.error_count = 1
    aggregated.total_issues = 1

    #         return aggregated

    #     async def validate_file(self, file_path: str,
    mode: Optional[ValidationMode] = None) - AggregatedResult):
    #         """
    #         Validate a NoodleCore file.

    #         Args:
    #             file_path: Path to the file to validate
    #             mode: Optional validation mode override

    #         Returns:
    #             AggregatedResult containing all validation results
    #         """
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()

                return await self.validate_code(code, file_path, mode)

    #         except FileNotFoundError:
    #             # Create error result
    aggregated = AggregatedResult(status=ValidationStatus.FAILED)
    error_result = ValidationResult(
    status = ValidationStatus.FAILED,
    validator_name = "ValidationEngine",
    file_path = file_path
    #             )
                error_result.add_issue(ValidationIssue(
    message = f"File not found: {file_path}",
    severity = ValidationSeverity.ERROR,
    code = "2902"
    #             ))
    aggregated.results["file_error"] = error_result
    aggregated.error_count = 1
    aggregated.total_issues = 1
    #             return aggregated

    #         except Exception as e:
                self.logger.error(f"Error reading file {file_path}: {str(e)}")
    aggregated = AggregatedResult(status=ValidationStatus.FAILED)
    error_result = ValidationResult(
    status = ValidationStatus.FAILED,
    validator_name = "ValidationEngine",
    file_path = file_path
    #             )
                error_result.add_issue(ValidationIssue(
    message = f"Error reading file: {str(e)}",
    severity = ValidationSeverity.ERROR,
    code = "2903"
    #             ))
    aggregated.results["file_error"] = error_result
    aggregated.error_count = 1
    aggregated.total_issues = 1
    #             return aggregated

    #     async def validate_multiple_files(self, file_paths: List[str],
    mode: Optional[ValidationMode] = None) - List[AggregatedResult]):
    #         """
    #         Validate multiple files concurrently.

    #         Args:
    #             file_paths: List of file paths to validate
    #             mode: Optional validation mode override

    #         Returns:
    #             List of AggregatedResult objects
    #         """
    #         # Limit concurrent validations
    semaphore = asyncio.Semaphore(self.config.max_concurrent_validations)

    #         async def validate_with_semaphore(file_path: str) -AggregatedResult):
    #             async with semaphore:
                    return await self.validate_file(file_path, mode)

    #         # Create tasks for all files
    #         tasks = [validate_with_semaphore(file_path) for file_path in file_paths]

    #         # Execute tasks with timeout
    #         try:
    results = await asyncio.wait_for(
    asyncio.gather(*tasks, return_exceptions = True),
    timeout = self.config.timeout_seconds
    #             )

    #             # Process results
    processed_results = []
    #             for i, result in enumerate(results):
    #                 if isinstance(result, Exception):
                        self.logger.error(f"Error validating file {file_paths[i]}: {str(result)}")
    #                     # Create error result
    error_result = AggregatedResult(status=ValidationStatus.FAILED)
    error_result.results["validation_error"] = ValidationResult(
    status = ValidationStatus.FAILED,
    validator_name = "ValidationEngine",
    file_path = file_paths[i]
    #                     )
                        error_result.results["validation_error"].add_issue(ValidationIssue(
    message = f"Validation error: {str(result)}",
    severity = ValidationSeverity.ERROR,
    code = "2904"
    #                     ))
    error_result.error_count = 1
    error_result.total_issues = 1
                        processed_results.append(error_result)
    #                 else:
                        processed_results.append(result)

    #             return processed_results

    #         except asyncio.TimeoutError:
                self.logger.error("Validation timed out")
    #             # Create timeout results for all files
    timeout_results = []
    #             for file_path in file_paths:
    timeout_result = AggregatedResult(status=ValidationStatus.FAILED)
    timeout_result.results["timeout_error"] = ValidationResult(
    status = ValidationStatus.FAILED,
    validator_name = "ValidationEngine",
    file_path = file_path
    #                 )
                    timeout_result.results["timeout_error"].add_issue(ValidationIssue(
    message = "Validation timed out",
    severity = ValidationSeverity.ERROR,
    code = "2905"
    #                 ))
    timeout_result.error_count = 1
    timeout_result.total_issues = 1
                    timeout_results.append(timeout_result)

    #             return timeout_results

    #     def format_result(self, result: AggregatedResult,
    format_type: Optional[str] = None) - str):
    #         """
    #         Format a validation result for output.

    #         Args:
    #             result: AggregatedResult to format
    #             format_type: Optional format type override

    #         Returns:
    #             Formatted result string
    #         """
    output_format = format_type or self.config.output_format

    #         if output_format == "json":
                return self._format_json(result)
    #         elif output_format == "xml":
                return self._format_xml(result)
    #         elif output_format == "text":
                return self._format_text(result)
    #         elif output_format == "html":
                return self._format_html(result)
    #         else:
                return self._format_json(result)

    #     async def _run_syntax_validator(self, code: str, file_path: Optional[str],
    #                                   aggregated: AggregatedResult) -None):
    #         """
    #         Run the syntax validator.

    #         Args:
    #             code: Code to validate
    #             file_path: Optional file path
    #             aggregated: AggregatedResult to update
    #         """
    result = await self.syntax_validator.validate(code, strict_mode=self.config.strict_mode)
    result.file_path = file_path
    aggregated.results["syntax"] = result

    #         # Update counts
    aggregated.error_count + = result.error_count
    aggregated.warning_count + = result.warning_count
    aggregated.total_issues + = len(result.issues)

    #     async def _run_semantic_validator(self, code: str, file_path: Optional[str],
    #                                     aggregated: AggregatedResult) -None):
    #         """
    #         Run the semantic validator.

    #         Args:
    #             code: Code to validate
    #             file_path: Optional file path
    #             aggregated: AggregatedResult to update
    #         """
    result = await self.semantic_validator.validate(code, strict_mode=self.config.strict_mode)
    result.file_path = file_path
    aggregated.results["semantic"] = result

    #         # Update counts
    aggregated.error_count + = result.error_count
    aggregated.warning_count + = result.warning_count
    aggregated.total_issues + = len(result.issues)

    #     async def _run_rule_engine(self, context: RuleContext,
    #                              aggregated: AggregatedResult) -None):
    #         """
    #         Run the rule engine.

    #         Args:
    #             context: Rule execution context
    #             aggregated: AggregatedResult to update
    #         """
    #         # Determine which rules to run
    rule_ids = None
    #         if self.config.custom_rules:
    rule_ids = self.config.custom_rules
    #         elif self.config.rule_categories:
    #             # Run rules from specified categories
    rule_ids = []
    #             for category in self.config.rule_categories:
                    rule_ids.extend(self.rule_engine.rule_categories[category])

    #         # Run rules
    rule_results = await self.rule_engine.check_rules(
    context, rule_ids = rule_ids, categories=self.config.rule_categories
    #         )

    aggregated.rule_results = rule_results

    #         # Update counts
    #         for rule_result in rule_results:
    #             for issue in rule_result.issues:
    #                 if issue.severity == ValidationSeverity.ERROR:
    aggregated.error_count + = 1
    #                 elif issue.severity == ValidationSeverity.WARNING:
    aggregated.warning_count + = 1
    #                 else:
    aggregated.info_count + = 1
    aggregated.total_issues + = 1

    #     def _parse_code(self, code: str) -Tuple[List[Token], ASTNode]):
    #         """
    #         Parse code into tokens and AST.

    #         Args:
    #             code: Code to parse

    #         Returns:
                Tuple of (tokens, ast_root)
    #         """
    grammar = NoodleCoreGrammar()
            return grammar.parse(code)

    #     def _update_metrics(self, result: AggregatedResult) -None):
    #         """
    #         Update engine metrics.

    #         Args:
    #             result: AggregatedResult from validation
    #         """
    self.metrics["validations_performed"] + = 1
    self.metrics["total_validation_time"] + = result.execution_time

    #         if result.file_path:
    self.metrics["files_validated"] + = 1

    #         # Count lines from results
    #         for validation_result in result.results.values():
    #             if "lines_processed" in validation_result.metrics:
    self.metrics["lines_validated"] + = validation_result.metrics["lines_processed"]

    #     def _format_json(self, result: AggregatedResult) -str):
    #         """Format result as JSON."""
    data = result.to_dict()
    return json.dumps(data, indent = 2)

    #     def _format_xml(self, result: AggregatedResult) -str):
    #         """Format result as XML."""
    #         # Simplified XML formatting
    lines = ['<?xml version="1.0" encoding="UTF-8"?>']
    lines.append(f'<validation status = "{result.status.value}" execution_time="{result.execution_time}">')

    #         # Summary
            lines.append('  <summary>')
            lines.append(f'    <total_issues>{result.total_issues}</total_issues>')
            lines.append(f'    <errors>{result.error_count}</errors>')
            lines.append(f'    <warnings>{result.warning_count}</warnings>')
            lines.append(f'    <info>{result.info_count}</info>')
            lines.append('  </summary>')

    #         # Results
            lines.append('  <results>')
    #         for name, validation_result in result.results.items():
    lines.append(f'    <validator name = "{name}">')
                lines.append(f'      <status>{validation_result.status.value}</status>')
                lines.append(f'      <issues>{len(validation_result.issues)}</issues>')
                lines.append('    </validator>')
            lines.append('  </results>')

            lines.append('</validation>')
            return '\n'.join(lines)

    #     def _format_text(self, result: AggregatedResult) -str):
    #         """Format result as plain text."""
    lines = [f"Validation Status: {result.status.value}"]
            lines.append(f"Execution Time: {result.execution_time:.3f}s")
            lines.append("")
            lines.append("Summary:")
            lines.append(f"  Total Issues: {result.total_issues}")
            lines.append(f"  Errors: {result.error_count}")
            lines.append(f"  Warnings: {result.warning_count}")
            lines.append(f"  Info: {result.info_count}")
            lines.append("")

    #         # Results
            lines.append("Validator Results:")
    #         for name, validation_result in result.results.items():
                lines.append(f"  {name}: {validation_result.status.value} ({len(validation_result.issues)} issues)")

            return '\n'.join(lines)

    #     def _format_html(self, result: AggregatedResult) -str):
    #         """Format result as HTML."""
    lines = ['<!DOCTYPE html>']
            lines.append('<html>')
            lines.append('<head>')
            lines.append('<title>NoodleCore Validation Report</title>')
            lines.append('<style>')
            lines.append('body { font-family: Arial, sans-serif; margin: 20px; }')
            lines.append('.header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }')
            lines.append('.summary { margin: 20px 0; }')
            lines.append('.error { color: red; }')
            lines.append('.warning { color: orange; }')
            lines.append('.success { color: green; }')
            lines.append('table { border-collapse: collapse; width: 100%; }')
            lines.append('th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }')
            lines.append('th { background-color: #f2f2f2; }')
            lines.append('</style>')
            lines.append('</head>')
            lines.append('<body>')

    #         # Header
    #         status_class = "success" if result.status == ValidationStatus.PASSED else "error"
    lines.append(f'<div class = "header">')
    lines.append(f'<h1 class = "{status_class}">Validation Status: {result.status.value}</h1>')
            lines.append(f'<p>Execution Time: {result.execution_time:.3f}s</p>')
            lines.append('</div>')

    #         # Summary
    lines.append('<div class = "summary">')
            lines.append('<h2>Summary</h2>')
            lines.append('<table>')
            lines.append('<tr><th>Metric</th><th>Count</th></tr>')
            lines.append(f'<tr><td>Total Issues</td><td>{result.total_issues}</td></tr>')
    lines.append(f'<tr><td>Errors</td><td class = "error">{result.error_count}</td></tr>')
    lines.append(f'<tr><td>Warnings</td><td class = "warning">{result.warning_count}</td></tr>')
            lines.append(f'<tr><td>Info</td><td>{result.info_count}</td></tr>')
            lines.append('</table>')
            lines.append('</div>')

    #         # Results
    lines.append('<div class = "results">')
            lines.append('<h2>Validator Results</h2>')
            lines.append('<table>')
            lines.append('<tr><th>Validator</th><th>Status</th><th>Issues</th></tr>')

    #         for name, validation_result in result.results.items():success" if validation_result.status == ValidationStatus.PASSED else "error"
                lines.append(f'<tr>')
                lines.append(f'<td>{name}</td>')
    lines.append(f'<td class = "{result_class}">{validation_result.status.value}</td>')
                lines.append(f'<td>{len(validation_result.issues)}</td>')
                lines.append(f'</tr>')

            lines.append('</table>')
            lines.append('</div>')

            lines.append('</body>')
            lines.append('</html>')

            return '\n'.join(lines)

    #     def get_metrics(self) -Dict[str, Any]):
    #         """
    #         Get engine metrics.

    #         Returns:
    #             Dictionary containing engine metrics
    #         """
    avg_time = 0.0
    #         if self.metrics["validations_performed"] 0):
    avg_time = self.metrics["total_validation_time"] / self.metrics["validations_performed"]

    #         return {
    #             **self.metrics,
    #             "average_validation_time": avg_time,
                "cache_hit_rate": (
    #                 self.metrics["cache_hits"] /
                    (self.metrics["cache_hits"] + self.metrics["cache_misses"])
    #                 if (self.metrics["cache_hits"] + self.metrics["cache_misses"]) 0
    #                 else 0.0
    #             )
    #         }

    #     def reset_metrics(self):
    """None)"""
    #         """Reset engine metrics."""
    self.metrics = {
    #             "validations_performed": 0,
    #             "total_validation_time": 0.0,
    #             "cache_hits": 0,
    #             "cache_misses": 0,
    #             "files_validated": 0,
    #             "lines_validated": 0
    #         }

    #     def get_engine_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the validation engine.

    #         Returns:
    #             Dictionary containing engine information
    #         """
    #         return {
    #             "version": "1.0",
    #             "supported_modes": [mode.value for mode in ValidationMode],
    #             "supported_formats": ["json", "xml", "text", "html"],
    #             "validators": ["syntax", "semantic"],
    #             "rule_categories": [category.value for category in RuleCategory],
                "metrics": self.get_metrics(),
    #             "config": {
    #                 "mode": self.config.mode.value,
    #                 "strict_mode": self.config.strict_mode,
    #                 "enable_caching": self.config.enable_caching,
    #                 "max_concurrent_validations": self.config.max_concurrent_validations,
    #                 "timeout_seconds": self.config.timeout_seconds
    #             }
    #         }