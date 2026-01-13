# Converted from Python to NoodleCore
# Original file: src

# """
# Validation Result Reporter for NoodleCore
# ----------------------------------------
# This module provides comprehensive reporting capabilities for validation results,
# including console output, file reports, and integration with IDE systems.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import json
import logging
import os
import time
import uuid
import datetime.datetime
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.List

import .foreign_syntax_detector.ValidationIssue
import .auto_corrector.AutoCorrectionResult


class ReportFormat(Enum)
    #     """Supported report formats"""
    CONSOLE = "console"
    JSON = "json"
    HTML = "html"
    XML = "xml"
    SARIF = "sarif"


class ReportLevel(Enum)
    #     """Detail levels for reports"""
    SUMMARY = "summary"
    STANDARD = "standard"
    DETAILED = "detailed"
    VERBOSE = "verbose"


dataclass
class ValidationReport
    #     """Complete validation report"""
    #     request_id: str
    #     file_path: Optional[str]
    #     timestamp: datetime
    exit_code: int  # 0 = valid - 1 = invalid, 2 = auto, correction failed
    #     total_issues: int
    #     error_count: int
    #     warning_count: int
    #     info_count: int
    issues: List[ValidationIssue] = field(default_factory=list)
    corrections: List[Correction] = field(default_factory=list)
    auto_correction_enabled: bool = False
    execution_time_ms: int = 0
    noodlecore_version: str = "1.0.0"
    validator_version: str = "1.0.0"

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert report to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "filePath": self.file_path,
                "timestamp": self.timestamp.isoformat(),
    #             "exitCode": self.exit_code,
    #             "totalIssues": self.total_issues,
    #             "errorCount": self.error_count,
    #             "warningCount": self.warning_count,
    #             "infoCount": self.info_count,
    #             "issues": [
    #                 {
    #                     "lineNumber": issue.line_number,
    #                     "column": issue.column,
    #                     "severity": issue.severity.value,
    #                     "message": issue.message,
    #                     "suggestion": issue.suggestion,
    #                     "autoCorrectable": issue.auto_correctable,
    #                     "errorCode": issue.error_code
    #                 }
    #                 for issue in self.issues
    #             ],
    #             "corrections": [
    #                 {
    #                     "lineNumber": correction.line_number,
    #                     "column": correction.column,
    #                     "originalText": correction.original_text,
    #                     "correctedText": correction.corrected_text,
    #                     "description": correction.description,
    #                     "result": correction.result.value
    #                 }
    #                 for correction in self.corrections
    #             ],
    #             "autoCorrectionEnabled": self.auto_correction_enabled,
    #             "executionTimeMs": self.execution_time_ms,
    #             "noodlecoreVersion": self.noodlecore_version,
    #             "validatorVersion": self.validator_version
    #         }


class ValidationResultReporter
    #     """
    #     Reports validation results in various formats

    #     This class provides comprehensive reporting capabilities for validation results,
    #     including console output, file reports, and integration with IDE systems.
    #     """

    #     def __init__(self, log_level: str = "INFO"):""
    #         Initialize the validation result reporter

    #         Args:
    #             log_level: Logging level
    #         """
    self.logger = logging.getLogger("noodlecore.validator.result_reporter")
            self.logger.setLevel(getattr(logging, log_level.upper()))

    #         # Report templates
    self.console_template = self._load_console_template()
    self.html_template = self._load_html_template()

            self.logger.info("Validation result reporter initialized")

    #     def create_report(
    #         self,
    #         issues: List[ValidationIssue],
    auto_correction_result: Optional[AutoCorrectionResult] = None,
    file_path: Optional[str] = None,
    execution_time_ms: int = 0,
    request_id: Optional[str] = None
    #     ) -ValidationReport):
    #         """
    #         Create a validation report from issues and correction results

    #         Args:
    #             issues: List of validation issues
    #             auto_correction_result: Result of auto-correction attempts
    #             file_path: Path to the validated file
    #             execution_time_ms: Execution time in milliseconds
    #             request_id: Unique request ID

    #         Returns:
    #             ValidationReport with all information
    #         """
    #         # Count issues by severity
    #         error_count = sum(1 for issue in issues if issue.severity == ValidationSeverity.ERROR)
    #         warning_count = sum(1 for issue in issues if issue.severity == ValidationSeverity.WARNING)
    #         info_count = sum(1 for issue in issues if issue.severity == ValidationSeverity.INFO)

    #         # Determine exit code
    #         if auto_correction_result:
    exit_code = auto_correction_result.exit_code
    remaining_issues = auto_correction_result.remaining_issues
    corrections = auto_correction_result.corrections
    #         else:
    #             exit_code = 0 if error_count = 0 else 1
    remaining_issues = issues
    corrections = []

            return ValidationReport(
    request_id = request_id or str(uuid.uuid4()),
    file_path = file_path,
    timestamp = datetime.now(),
    exit_code = exit_code,
    total_issues = len(issues),
    error_count = error_count,
    warning_count = warning_count,
    info_count = info_count,
    issues = issues,
    corrections = corrections,
    auto_correction_enabled = auto_correction_result is not None,
    execution_time_ms = execution_time_ms
    #         )

    #     def report_to_console(
    #         self,
    #         report: ValidationReport,
    level: ReportLevel = ReportLevel.STANDARD,
    use_colors: bool = True
    #     ) -str):
    #         """
    #         Generate a console report

    #         Args:
    #             report: Validation report
    #             level: Report detail level
    #             use_colors: Whether to use colors in output

    #         Returns:
    #             Console report as string
    #         """
    lines = []

    #         # Header
            lines.append(self._format_header("NoodleCore Validation Report", use_colors))
            lines.append("")

    #         # Summary
            lines.append(self._format_section("Summary", use_colors))
            lines.append(f"  File: {report.file_path or '<stdin>'}")
            lines.append(f"  Status: {self._format_status(report.exit_code, use_colors)}")
            lines.append(f"  Total Issues: {report.total_issues}")
            lines.append(f"  Errors: {self._format_count(report.error_count, 'error', use_colors)}")
            lines.append(f"  Warnings: {self._format_count(report.warning_count, 'warning', use_colors)}")
            lines.append(f"  Info: {report.info_count}")
            lines.append(f"  Execution Time: {report.execution_time_ms}ms")

    #         if report.auto_correction_enabled:
                lines.append(f"  Auto-corrections: {len(report.corrections)}")

            lines.append("")

    #         # Issues
    #         if level in [ReportLevel.STANDARD, ReportLevel.DETAILED, ReportLevel.VERBOSE]:
    #             if report.issues:
                    lines.append(self._format_section("Issues", use_colors))

    #                 for issue in report.issues:
    severity_color = self._get_severity_color(issue.severity, use_colors)
                        lines.append(f"  {severity_color}{issue.severity.value.upper()}:")
                        lines.append(f"    Line {issue.line_number}, Column {issue.column}")
                        lines.append(f"    {issue.message}")

    #                     if issue.suggestion and level in [ReportLevel.DETAILED, ReportLevel.VERBOSE]:
                            lines.append(f"    Suggestion: {issue.suggestion}")

    #                     if issue.error_code and level == ReportLevel.VERBOSE:
                            lines.append(f"    Error Code: {issue.error_code}")

    #                     if issue.auto_correctable and level in [ReportLevel.DETAILED, ReportLevel.VERBOSE]:
                            lines.append(f"    Auto-correctable: Yes")

                        lines.append("")
    #             else:
                    lines.append(self._format_section("Issues", use_colors))
                    lines.append("  No issues found!")
                    lines.append("")

    #         # Corrections
    #         if report.corrections and level in [ReportLevel.DETAILED, ReportLevel.VERBOSE]:
                lines.append(self._format_section("Auto-Corrections", use_colors))

    #             for correction in report.corrections:
    result_color = self._get_correction_result_color(correction.result, use_colors)
                    lines.append(f"  {result_color}{correction.result.value.upper()}:")
                    lines.append(f"    Line {correction.line_number}, Column {correction.column}")
                    lines.append(f"    {correction.description}")

    #                 if level == ReportLevel.VERBOSE and correction.result.value == "failed":
                        lines.append(f"    Error: Could not apply correction")

                    lines.append("")

    #         # Footer
            lines.append(self._format_footer(use_colors))

            return "\n".join(lines)

    #     def report_to_json(self, report: ValidationReport, pretty: bool = True) -str):
    #         """
    #         Generate a JSON report

    #         Args:
    #             report: Validation report
    #             pretty: Whether to format JSON with indentation

    #         Returns:
    #             JSON report as string
    #         """
    data = report.to_dict()

    #         if pretty:
    return json.dumps(data, indent = 2)
    #         else:
                return json.dumps(data)

    #     def report_to_html(self, report: ValidationReport, level: ReportLevel = ReportLevel.STANDARD) -str):
    #         """
    #         Generate an HTML report

    #         Args:
    #             report: Validation report
    #             level: Report detail level

    #         Returns:
    #             HTML report as string
    #         """
    #         # Use a simple template for HTML reporting
    html = f"""
# <!DOCTYPE html>
<html lang = "en">
# <head>
<meta charset = "UTF-8">
<meta name = "viewport" content="width=device-width, initial-scale=1.0">
#     <title>NoodleCore Validation Report</title>
#     <style>
#         body {{
#             font-family: Arial, sans-serif;
#             max-width: 1200px;
#             margin: 0 auto;
#             padding: 20px;
#             background-color: #f5f5f5;
#         }}
#         .container {{
#             background-color: white;
#             padding: 30px;
#             border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
#         }}
#         h1 {{
#             color: #333;
#             border-bottom: 2px solid #4CAF50;
#             padding-bottom: 10px;
#         }}
#         h2 {{
#             color: #555;
#             margin-top: 30px;
#         }}
#         .summary {{
#             background-color: #f9f9f9;
#             padding: 15px;
#             border-radius: 5px;
#             margin-bottom: 20px;
#         }}
#         .status-valid {{
#             color: #4CAF50;
#             font-weight: bold;
#         }}
#         .status-invalid {{
#             color: #f44336;
#             font-weight: bold;
#         }}
#         .status-partial {{
#             color: #ff9800;
#             font-weight: bold;
#         }}
#         .issue {{
#             margin-bottom: 15px;
#             padding: 10px;
#             border-left: 4px solid #ddd;
#         }}
#         .issue-error {{
#             border-left-color: #f44336;
#             background-color: #ffebee;
#         }}
#         .issue-warning {{
#             border-left-color: #ff9800;
#             background-color: #fff8e1;
#         }}
#         .issue-info {{
#             border-left-color: #2196F3;
#             background-color: #e3f2fd;
#         }}
#         .correction {{
#             margin-bottom: 15px;
#             padding: 10px;
#             border-left: 4px solid #4CAF50;
#             background-color: #e8f5e8;
#         }}
#         .correction-failed {{
#             border-left-color: #f44336;
#             background-color: #ffebee;
#         }}
#         table {{
#             width: 100%;
#             border-collapse: collapse;
#             margin-top: 10px;
#         }}
#         th, td {{
#             padding: 8px 12px;
#             text-align: left;
#             border-bottom: 1px solid #ddd;
#         }}
#         th {{
#             background-color: #f2f2f2;
#         }}
#         .footer {{
#             margin-top: 30px;
#             padding-top: 15px;
#             border-top: 1px solid #ddd;
#             color: #777;
#             font-size: 0.9em;
#         }}
#     </style>
# </head>
# <body>
<div class = "container">
#         <h1>NoodleCore Validation Report</h1>

<div class = "summary">
#             <h2>Summary</h2>
#             <table>
#                 <tr><td><strong>File:</strong></td><td>{report.file_path or '<stdin>'}</td></tr>
<tr><td><strong>Status:</strong></td><td class = "status-{self._get_status_class(report.exit_code)}">{self._get_status_text(report.exit_code)}</td></tr>
#                 <tr><td><strong>Total Issues:</strong></td><td>{report.total_issues}</td></tr>
#                 <tr><td><strong>Errors:</strong></td><td>{report.error_count}</td></tr>
#                 <tr><td><strong>Warnings:</strong></td><td>{report.warning_count}</td></tr>
#                 <tr><td><strong>Info:</strong></td><td>{report.info_count}</td></tr>
#                 <tr><td><strong>Execution Time:</strong></td><td>{report.execution_time_ms}ms</td></tr>
#                 {f'<tr><td><strong>Auto-corrections:</strong></td><td>{len(report.corrections)}</td></tr>' if report.auto_correction_enabled else ''}
#             </table>
#         </div>

#         {self._generate_issues_html(report.issues, level) if report.issues else '<h2>Issues</h2><p>No issues found!</p>'}

#         {self._generate_corrections_html(report.corrections, level) if report.corrections and level in [ReportLevel.DETAILED, ReportLevel.VERBOSE] else ''}

<div class = "footer">
            <p>Generated on {report.timestamp.strftime('%Y-%m-%d %H:%M:%S')} | NoodleCore Validator v{report.validator_version}</p>
#         </div>
#     </div>
# </body>
# </html>
#         """

#         return html

#     def report_to_sarif(self, report: ValidationReport) -str):
#         """
        Generate a SARIF (Static Analysis Results Interchange Format) report

#         Args:
#             report: Validation report

#         Returns:
#             SARIF report as string
#         """
#         sarif = {
#             "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
#             "version": "2.1.0",
#             "runs": [
#                 {
#                     "tool": {
#                         "driver": {
#                             "name": "NoodleCore Validator",
#                             "version": report.validator_version,
#                             "informationUri": "https://noodlecore.org"
#                         }
#                     },
#                     "results": [
#                         {
#                             "ruleId": f"NC{issue.error_code:04d}" if issue.error_code else "NC0000",
                            "level": self._severity_to_sarif_level(issue.severity),
#                             "message": {
#                                 "text": issue.message
#                             },
#                             "locations": [
#                                 {
#                                     "physicalLocation": {
#                                         "artifactLocation": {
#                                             "uri": report.file_path or ""
#                                         },
#                                         "region": {
#                                             "startLine": issue.line_number,
#                                             "startColumn": issue.column
#                                         }
#                                     }
#                                 }
#                             ]
#                         }
#                         for issue in report.issues
#                     ]
#                 }
#             ]
#         }

return json.dumps(sarif, indent = 2)

#     def save_report(
#         self,
#         report: ValidationReport,
#         file_path: str,
format: ReportFormat = ReportFormat.JSON,
level: ReportLevel = ReportLevel.STANDARD
#     ) -bool):
#         """
#         Save a report to a file

#         Args:
#             report: Validation report
#             file_path: Path to save the report
#             format: Report format
#             level: Report detail level

#         Returns:
#             True if successful, False otherwise
#         """
#         try:
#             # Generate report content based on format
#             if format == ReportFormat.CONSOLE:
content = self.report_to_console(report, level)
#             elif format == ReportFormat.JSON:
content = self.report_to_json(report)
#             elif format == ReportFormat.HTML:
content = self.report_to_html(report, level)
#             elif format == ReportFormat.SARIF:
content = self.report_to_sarif(report)
#             else:
                self.logger.error(f"Unsupported report format: {format.value}")
#                 return False

#             # Ensure directory exists
Path(file_path).parent.mkdir(parents = True, exist_ok=True)

#             # Write to file
#             with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

            self.logger.info(f"Report saved to {file_path}")
#             return True

#         except Exception as e:
            self.logger.error(f"Failed to save report to {file_path}: {e}")
#             return False

#     def _format_header(self, text: str, use_colors: bool) -str):
#         """Format a header with or without colors"""
#         if use_colors:
#             return f"\033[1;36m{text}\033[0m"
#         return text

#     def _format_section(self, text: str, use_colors: bool) -str):
#         """Format a section header with or without colors"""
#         if use_colors:
#             return f"\033[1;33m{text}:\033[0m"
#         return f"{text}:"

#     def _format_footer(self, use_colors: bool) -str):
#         """Format a footer with or without colors"""
#         if use_colors:
#             return "\033[0;36m--- End of Report ---\033[0m"
#         return "--- End of Report ---"

#     def _format_status(self, exit_code: int, use_colors: bool) -str):
#         """Format status with or without colors"""
#         if exit_code = 0:
status = "VALID"
#             color = "\033[0;32m" if use_colors else ""
#         elif exit_code = 2:
status = "PARTIAL"
#             color = "\033[0;33m" if use_colors else ""
#         else:
status = "INVALID"
#             color = "\033[0;31m" if use_colors else ""

#         if use_colors:
#             return f"{color}{status}\033[0m"
#         return status

#     def _format_count(self, count: int, label: str, use_colors: bool) -str):
#         """Format count with or without colors"""
#         if count = 0:
            return str(count)

#         color = "\033[0;31m" if use_colors else ""
#         reset = "\033[0m" if use_colors else ""

#         if use_colors:
#             return f"{color}{count}{reset}"
        return str(count)

#     def _get_severity_color(self, severity: ValidationSeverity, use_colors: bool) -str):
#         """Get color for a severity level"""
#         if not use_colors:
#             return ""

#         if severity == ValidationSeverity.ERROR:
#             return "\033[0;31m"
#         elif severity == ValidationSeverity.WARNING:
#             return "\033[0;33m"
#         else:
#             return "\033[0;34m"

#     def _get_correction_result_color(self, result, use_colors: bool) -str):
#         """Get color for a correction result"""
#         if not use_colors:
#             return ""

#         if result.value == "success":
#             return "\033[0;32m"
#         else:
#             return "\033[0;31m"

#     def _severity_to_sarif_level(self, severity: ValidationSeverity) -str):
#         """Convert validation severity to SARIF level"""
#         if severity == ValidationSeverity.ERROR:
#             return "error"
#         elif severity == ValidationSeverity.WARNING:
#             return "warning"
#         else:
#             return "note"

#     def _get_status_class(self, exit_code: int) -str):
#         """Get CSS class for status"""
#         if exit_code = 0:
#             return "valid"
#         elif exit_code = 2:
#             return "partial"
#         else:
#             return "invalid"

#     def _get_status_text(self, exit_code: int) -str):
#         """Get text for status"""
#         if exit_code = 0:
#             return "VALID"
#         elif exit_code = 2:
            return "PARTIAL (Auto-correction attempted)"
#         else:
#             return "INVALID"

#     def _generate_issues_html(self, issues: List[ValidationIssue], level: ReportLevel) -str):
#         """Generate HTML for issues"""
html = '<h2>Issues</h2>'

#         for issue in issues:
#             severity_class = f"issue-{issue.severity.value}"
html + = f'<div class="issue {severity_class}">'
html + = f'<strong>{issue.severity.value.upper()}</strong'
html + = f'(Line {issue.line_number}, Column {issue.column})<br>'
html + = f'{issue.message}'

#             if issue.suggestion and level in [ReportLevel.DETAILED, ReportLevel.VERBOSE]):
html + = f'<br><strong>Suggestion:</strong{issue.suggestion}'

#             if issue.error_code and level == ReportLevel.VERBOSE):
html + = f'<br><strong>Error Code:</strong{issue.error_code}'

#             if issue.auto_correctable and level in [ReportLevel.DETAILED, ReportLevel.VERBOSE]):
html + = '<br><strong>Auto-correctable:</strongYes'

html + = '</div>'

#         return html

#     def _generate_corrections_html(self, corrections): List[Correction], level: ReportLevel) -str):
#         """Generate HTML for corrections"""
html = '<h2>Auto-Corrections</h2>'

#         for correction in corrections:
#             result_class = "correction" if correction.result.value == "success" else "correction-failed"
html + = f'<div class="{result_class}">'
html + = f'<strong>{correction.result.value.upper()}</strong'
html + = f'(Line {correction.line_number}, Column {correction.column})<br>'
html + = f'{correction.description}'

#             if correction.result.value == "failed" and level == ReportLevel.VERBOSE):
html + = '<br><strong>Error:</strongCould not apply correction'

html + = '</div>'

#         return html

#     def _load_console_template(self):
    """str)"""
#         """Load console template (placeholder for future implementation)"""
#         return ""

#     def _load_html_template(self) -str):
#         """Load HTML template (placeholder for future implementation)"""
#         return ""