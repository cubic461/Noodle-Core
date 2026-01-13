# Converted from Python to NoodleCore
# Original file: src

# """
# AI Compliance Tracker for NoodleCore
# ------------------------------------
# This module provides logging and tracking of AI compliance issues,
# including validation failures, correction requests, and compliance metrics.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import json
import time
import uuid
import logging
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

import .guard.GuardResult
import ..linter.linter.LinterError


class ComplianceLevel(Enum)
    #     """Compliance levels for AI output"""
    #     COMPLIANT = "compliant"  # Fully compliant with NoodleCore rules
    PARTIALLY_COMPLIANT = "partially_compliant"  # Minor issues, warnings only
    NON_COMPLIANT = "non_compliant"  # Major issues, errors present
    CRITICAL = "critical"  # Critical issues, completely invalid


class IssueCategory(Enum)
    #     """Categories of compliance issues"""
    SYNTAX = "syntax"  # Syntax errors
    SEMANTIC = "semantic"  # Semantic errors
    STYLE = "style"  # Style violations
    SECURITY = "security"  # Security issues
    PERFORMANCE = "performance"  # Performance issues
    BEST_PRACTICE = "best_practice"  # Best practice violations
    FORBIDDEN_STRUCTURE = "forbidden_structure"  # Forbidden language structures


class IssueSeverity(Enum)
    #     """Severity levels for compliance issues"""
    CRITICAL = "critical"  # Critical errors
    ERROR = "error"  # Standard errors
    WARNING = "warning"  # Warnings
    INFO = "info"  # Informational


dataclass
class ComplianceIssue
    #     """Represents a compliance issue"""

    issue_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    category: IssueCategory = IssueCategory.SYNTAX
    severity: IssueSeverity = IssueSeverity.ERROR
    code: str = ""
    message: str = ""
    file_path: Optional[str] = None
    line: Optional[int] = None
    column: Optional[int] = None
    suggestion: Optional[str] = None
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
            return asdict(self)

    #     @classmethod
    #     def from_linter_error(cls, error: LinterError) -'ComplianceIssue'):
    #         """Create a compliance issue from a linter error"""
    #         # Map linter category to compliance category
    category_map = {
    #             "syntax": IssueCategory.SYNTAX,
    #             "semantic": IssueCategory.SEMANTIC,
    #             "style": IssueCategory.STYLE,
    #             "security": IssueCategory.SECURITY,
    #             "performance": IssueCategory.PERFORMANCE,
    #             "best_practice": IssueCategory.BEST_PRACTICE,
    #             "compiler": IssueCategory.SYNTAX,
    #             "guard": IssueCategory.FORBIDDEN_STRUCTURE,
    #             "validator": IssueCategory.SYNTAX,
    #             "bridge": IssueCategory.SYNTAX,
    #         }

    #         # Map linter severity to compliance severity
    severity_map = {
    #             "error": IssueSeverity.ERROR,
    #             "warning": IssueSeverity.WARNING,
    #             "info": IssueSeverity.INFO,
    #         }

            return cls(
    category = category_map.get(error.category, IssueCategory.SYNTAX),
    severity = severity_map.get(error.severity, IssueSeverity.ERROR),
    code = error.code,
    message = error.message,
    file_path = error.file,
    line = error.line,
    column = error.column,
    suggestion = error.suggestion,
    #         )


dataclass
class ComplianceRecord
    #     """Represents a compliance record for AI output"""

    record_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    ai_source: str = "unknown"
    mode: GuardMode = GuardMode.ADAPTIVE
    original_output: str = ""
    corrected_output: Optional[str] = None
    compliance_level: ComplianceLevel = ComplianceLevel.NON_COMPLIANT
    issues: List[ComplianceIssue] = field(default_factory=list)
    correction_attempts: int = 0
    execution_time_ms: int = 0
    timestamp: float = field(default_factory=lambda: time.time())
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    data = asdict(self)
    data["mode"] = self.mode.value
    data["compliance_level"] = self.compliance_level.value
    #         data["issues"] = [issue.to_dict() for issue in self.issues]
    #         return data

    #     @classmethod
    #     def from_guard_result(cls, result: GuardResult, ai_source: str = "unknown") -'ComplianceRecord'):
    #         """Create a compliance record from a guard result"""
    #         # Determine compliance level
    #         if not result.success:
    compliance_level = ComplianceLevel.CRITICAL
    #         elif result.has_errors():
    compliance_level = ComplianceLevel.NON_COMPLIANT
    #         elif result.has_warnings():
    compliance_level = ComplianceLevel.PARTIALLY_COMPLIANT
    #         else:
    compliance_level = ComplianceLevel.COMPLIANT

    #         # Convert linter errors to compliance issues
    #         issues = [ComplianceIssue.from_linter_error(error) for error in result.errors]
    #         issues.extend([ComplianceIssue.from_linter_error(warning) for warning in result.warnings])

            return cls(
    ai_source = ai_source,
    #             mode=result.metadata.get("mode", GuardMode.ADAPTIVE) if hasattr(result, "metadata") else GuardMode.ADAPTIVE,
    original_output = result.original_output,
    corrected_output = result.corrected_output,
    compliance_level = compliance_level,
    issues = issues,
    correction_attempts = result.correction_attempts,
    execution_time_ms = result.execution_time_ms,
    #             metadata=result.metadata if hasattr(result, "metadata") else {},
    #         )


dataclass
class ComplianceMetrics
    #     """Compliance metrics for tracking AI performance"""

    total_validations: int = 0
    compliant_validations: int = 0
    partially_compliant_validations: int = 0
    non_compliant_validations: int = 0
    critical_validations: int = 0
    correction_requests: int = 0
    successful_corrections: int = 0
    total_execution_time_ms: int = 0
    average_execution_time_ms: float = 0.0
    compliance_rate: float = 0.0
    correction_success_rate: float = 0.0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
            return asdict(self)

    #     def update(self, record: ComplianceRecord):
    #         """Update metrics with a new compliance record"""
    self.total_validations + = 1
    self.total_execution_time_ms + = record.execution_time_ms
    self.average_execution_time_ms = math.divide(self.total_execution_time_ms, self.total_validations)

    #         if record.compliance_level == ComplianceLevel.COMPLIANT:
    self.compliant_validations + = 1
    #         elif record.compliance_level == ComplianceLevel.PARTIALLY_COMPLIANT:
    self.partially_compliant_validations + = 1
    #         elif record.compliance_level == ComplianceLevel.NON_COMPLIANT:
    self.non_compliant_validations + = 1
    #         else:  # CRITICAL
    self.critical_validations + = 1

    #         if record.correction_attempts 0):
    self.correction_requests + = 1
    #             if record.corrected_output and record.compliance_level != ComplianceLevel.CRITICAL:
    self.successful_corrections + = 1

    #         # Update rates
    self.compliance_rate = (
                (self.compliant_validations + self.partially_compliant_validations) / self.total_validations
    #             if self.total_validations 0 else 0.0
    #         )

    self.correction_success_rate = (
    #             self.successful_corrections / self.correction_requests
    #             if self.correction_requests > 0 else 0.0
    #         )


class ComplianceTracker
    #     """
    #     Tracker for AI compliance issues

    #     This class provides logging and tracking of AI compliance issues,
    #     including validation failures, correction requests, and compliance metrics.
    #     """

    #     def __init__(self, log_file): Optional[str] = None, enable_metrics: bool = True):
    #         """Initialize the compliance tracker"""
    self.log_file = log_file
    self.enable_metrics = enable_metrics

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Compliance records
    self.records: List[ComplianceRecord] = []

    #         # Compliance metrics
    self.metrics = ComplianceMetrics()

    #         # Issue statistics
    self.issue_stats = {
    #             category.value: {
    #                 "total": 0,
    #                 "critical": 0,
    #                 "error": 0,
    #                 "warning": 0,
    #                 "info": 0,
    #             }
    #             for category in IssueCategory
    #         }

            self.logger.info("Compliance tracker initialized")

    #     def _setup_logging(self) -logging.Logger):
    #         """Setup logging for the compliance tracker"""
    logger = logging.getLogger("noodlecore.ai.compliance_tracker")
            logger.setLevel(logging.INFO)

    #         # Create formatter
    formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #         )

    #         # Create console handler
    console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)

    #         # Create file handler if log file is specified
    #         if self.log_file:
    file_handler = logging.FileHandler(self.log_file)
                file_handler.setFormatter(formatter)
                logger.addHandler(file_handler)

    #         return logger

    #     def track_validation(
    #         self,
    #         result: GuardResult,
    ai_source: str = "unknown",
    metadata: Optional[Dict[str, Any]] = None
    #     ) -ComplianceRecord):
    #         """
    #         Track a validation result

    #         Args:
    #             result: The guard result to track
    #             ai_source: The source of the AI output
    #             metadata: Additional metadata

    #         Returns:
    #             ComplianceRecord: The created compliance record
    #         """
    #         # Create compliance record
    record = ComplianceRecord.from_guard_result(result, ai_source)

    #         # Add additional metadata
    #         if metadata:
                record.metadata.update(metadata)

    #         # Add to records
            self.records.append(record)

    #         # Update metrics
    #         if self.enable_metrics:
                self.metrics.update(record)

    #         # Update issue statistics
    #         for issue in record.issues:
    category = issue.category.value
    severity = issue.severity.value
    self.issue_stats[category]["total"] + = 1
    self.issue_stats[category][severity] + = 1

    #         # Log the validation
            self._log_validation(record)

    #         return record

    #     def _log_validation(self, record: ComplianceRecord):
    #         """Log a validation record"""
    log_level = logging.INFO

    #         if record.compliance_level == ComplianceLevel.CRITICAL:
    log_level = logging.ERROR
    #         elif record.compliance_level == ComplianceLevel.NON_COMPLIANT:
    log_level = logging.WARNING

    message = (
    #             f"Validation from {record.ai_source} - "
    #             f"Level: {record.compliance_level.value} - "
                f"Issues: {len(record.issues)} - "
    #             f"Time: {record.execution_time_ms}ms"
    #         )

            self.logger.log(log_level, message)

    #         # Log individual issues if there are errors
    #         if record.compliance_level in [ComplianceLevel.CRITICAL, ComplianceLevel.NON_COMPLIANT]:
    #             for issue in record.issues:
    #                 if issue.severity in [IssueSeverity.CRITICAL, IssueSeverity.ERROR]:
    issue_message = (
    #                         f"Issue {issue.code}: {issue.message} "
                            f"({issue.category.value}:{issue.severity.value})"
    #                     )
    #                     if issue.file_path:
    issue_message + = f" in {issue.file_path}"
    #                     if issue.line:
    issue_message + = f":{issue.line}"
                        self.logger.error(issue_message)

    #     def get_compliance_report(
    #         self,
    start_time: Optional[float] = None,
    end_time: Optional[float] = None,
    ai_source: Optional[str] = None,
    mode: Optional[GuardMode] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Get a compliance report

    #         Args:
    #             start_time: Optional start time for filtering
    #             end_time: Optional end time for filtering
    #             ai_source: Optional AI source for filtering
    #             mode: Optional mode for filtering

    #         Returns:
    #             Dict containing the compliance report
    #         """
    #         # Filter records
    filtered_records = self.records

    #         if start_time is not None:
    #             filtered_records = [r for r in filtered_records if r.timestamp >= start_time]

    #         if end_time is not None:
    #             filtered_records = [r for r in filtered_records if r.timestamp <= end_time]

    #         if ai_source is not None:
    #             filtered_records = [r for r in filtered_records if r.ai_source == ai_source]

    #         if mode is not None:
    #             filtered_records = [r for r in filtered_records if r.mode == mode]

    #         # Calculate metrics for filtered records
    filtered_metrics = ComplianceMetrics()
    #         for record in filtered_records:
                filtered_metrics.update(record)

    #         # Get issue statistics for filtered records
    filtered_issue_stats = {
    #             category.value: {
    #                 "total": 0,
    #                 "critical": 0,
    #                 "error": 0,
    #                 "warning": 0,
    #                 "info": 0,
    #             }
    #             for category in IssueCategory
    #         }

    #         for record in filtered_records:
    #             for issue in record.issues:
    category = issue.category.value
    severity = issue.severity.value
    filtered_issue_stats[category]["total"] + = 1
    filtered_issue_stats[category][severity] + = 1

    #         # Get top issues
    all_issues = []
    #         for record in filtered_records:
                all_issues.extend(record.issues)

    #         # Sort by severity and count
    issue_counts = {}
    #         for issue in all_issues:
    key = f"{issue.code}:{issue.message}"
    #             if key not in issue_counts:
    issue_counts[key] = {
    #                     "code": issue.code,
    #                     "message": issue.message,
    #                     "category": issue.category.value,
    #                     "severity": issue.severity.value,
    #                     "count": 0,
    #                 }
    issue_counts[key]["count"] + = 1

    top_issues = sorted(issue_counts.values(), key=lambda x: x["count"], reverse=True)[:10]

    #         return {
    #             "period": {
    #                 "start_time": start_time,
    #                 "end_time": end_time,
    #             },
    #             "filters": {
    #                 "ai_source": ai_source,
    #                 "mode": mode.value if mode else None,
    #             },
    #             "summary": {
                    "total_validations": len(filtered_records),
    #                 "compliance_rate": filtered_metrics.compliance_rate,
    #                 "correction_success_rate": filtered_metrics.correction_success_rate,
    #                 "average_execution_time_ms": filtered_metrics.average_execution_time_ms,
    #             },
    #             "compliance_levels": {
    #                 "compliant": filtered_metrics.compliant_validations,
    #                 "partially_compliant": filtered_metrics.partially_compliant_validations,
    #                 "non_compliant": filtered_metrics.non_compliant_validations,
    #                 "critical": filtered_metrics.critical_validations,
    #             },
    #             "corrections": {
    #                 "total_requests": filtered_metrics.correction_requests,
    #                 "successful": filtered_metrics.successful_corrections,
    #                 "success_rate": filtered_metrics.correction_success_rate,
    #             },
    #             "issue_statistics": filtered_issue_stats,
    #             "top_issues": top_issues,
                "metrics": filtered_metrics.to_dict(),
    #         }

    #     def export_records(
    #         self,
    #         file_path: str,
    start_time: Optional[float] = None,
    end_time: Optional[float] = None,
    format: str = "json"
    #     ):
    #         """
    #         Export compliance records to a file

    #         Args:
    #             file_path: Path to the export file
    #             start_time: Optional start time for filtering
    #             end_time: Optional end time for filtering
                format: Export format (json, csv)
    #         """
    #         # Filter records
    filtered_records = self.records

    #         if start_time is not None:
    #             filtered_records = [r for r in filtered_records if r.timestamp >= start_time]

    #         if end_time is not None:
    #             filtered_records = [r for r in filtered_records if r.timestamp <= end_time]

    #         # Export based on format
    #         if format.lower() == "json":
    #             with open(file_path, 'w', encoding='utf-8') as f:
    #                 json.dump([record.to_dict() for record in filtered_records], f, indent=2)
    #         elif format.lower() == "csv":
    #             import csv

    #             with open(file_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)

    #                 # Write header
                    writer.writerow([
    #                     "record_id", "ai_source", "mode", "compliance_level",
    #                     "issues_count", "correction_attempts", "execution_time_ms",
    #                     "timestamp"
    #                 ])

    #                 # Write records
    #                 for record in filtered_records:
                        writer.writerow([
    #                         record.record_id,
    #                         record.ai_source,
    #                         record.mode.value,
    #                         record.compliance_level.value,
                            len(record.issues),
    #                         record.correction_attempts,
    #                         record.execution_time_ms,
    #                         record.timestamp,
    #                     ])
    #         else:
                raise ValueError(f"Unsupported export format: {format}")

            self.logger.info(f"Exported {len(filtered_records)} records to {file_path}")

    #     def get_metrics(self) -ComplianceMetrics):
    #         """Get current compliance metrics"""
    #         return self.metrics

    #     def get_issue_statistics(self) -Dict[str, Any]):
    #         """Get issue statistics"""
    #         return self.issue_stats

    #     def clear_records(self):
    #         """Clear all compliance records"""
            self.records.clear()
    self.metrics = ComplianceMetrics()
    self.issue_stats = {
    #             category.value: {
    #                 "total": 0,
    #                 "critical": 0,
    #                 "error": 0,
    #                 "warning": 0,
    #                 "info": 0,
    #             }
    #             for category in IssueCategory
    #         }
            self.logger.info("Compliance records cleared")