# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Output Formatter Module
# -----------------------

# This module provides output formatting functionality for the NoodleCore CLI,
# supporting text, JSON, and YAML output formats.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import json
import sys
import enum.Enum
import typing.Any,

try
    #     import yaml
    YAML_AVAILABLE = True
except ImportError
    YAML_AVAILABLE = False


class OutputFormat(Enum)
    #     """Supported output formats."""
    TEXT = "text"
    JSON = "json"
    YAML = "yaml"


class OutputFormatter
    #     """Formatter for CLI output."""

    #     def __init__(self, default_format: OutputFormat = OutputFormat.TEXT,
    enable_colors: bool = True):
    #         """Initialize the output formatter."""
    self.default_format = default_format
    self.enable_colors = enable_colors

    #         # Color codes for terminal output
    self.colors = {
    #             "reset": "\033[0m",
    #             "bold": "\033[1m",
    #             "red": "\033[31m",
    #             "green": "\033[32m",
    #             "yellow": "\033[33m",
    #             "blue": "\033[34m",
    #             "magenta": "\033[35m",
    #             "cyan": "\033[36m",
    #             "white": "\033[37m"
    #         }

    #     def format_output(self, data: Any, format_type: Union[str, OutputFormat] = None) -> None:
    #         """Format and output data."""
    #         if format_type is None:
    format_type = self.default_format

    #         if isinstance(format_type, str):
    #             try:
    format_type = OutputFormat(format_type)
    #             except ValueError:
    format_type = self.default_format

    #         if format_type == OutputFormat.JSON:
                self._format_json(data)
    #         elif format_type == OutputFormat.YAML:
                self._format_yaml(data)
    #         else:
                self._format_text(data)

    #     def _format_json(self, data: Any) -> None:
    #         """Format data as JSON."""
    #         try:
    json_output = json.dumps(data, indent=2, ensure_ascii=False)
                print(json_output)
    #         except Exception as e:
                self._print_error(f"Failed to format JSON output: {e}")

    #     def _format_yaml(self, data: Any) -> None:
    #         """Format data as YAML."""
    #         if not YAML_AVAILABLE:
                self._print_error("YAML output format requires PyYAML to be installed")
    #             return

    #         try:
    yaml_output = yaml.dump(data, default_flow_style=False,
    allow_unicode = True, sort_keys=False)
                print(yaml_output)
    #         except Exception as e:
                self._print_error(f"Failed to format YAML output: {e}")

    #     def _format_text(self, data: Any) -> None:
    #         """Format data as human-readable text."""
    #         if isinstance(data, dict):
                self._format_dict_text(data)
    #         elif isinstance(data, list):
                self._format_list_text(data)
    #         else:
                print(str(data))

    #     def _format_dict_text(self, data: Dict[str, Any]) -> None:
    #         """Format a dictionary as text."""
    #         for key, value in data.items():
    #             if key == "success" and isinstance(value, bool):
    #                 status = "✓" if value else "✗"
    #                 color = self.colors["green"] if value else self.colors["red"]
    #                 reset = self.colors["reset"] if self.enable_colors else ""
                    print(f"{color}{status} {key.capitalize()}{reset}")
    #             elif key == "errors" and isinstance(value, list):
    #                 if value:
    #                     color = self.colors["red"] if self.enable_colors else ""
    #                     reset = self.colors["reset"] if self.enable_colors else ""
                        print(f"{color}Errors:{reset}")
    #                     for error in value:
                            print(f"  - {error}")
    #             elif key == "warnings" and isinstance(value, list):
    #                 if value:
    #                     color = self.colors["yellow"] if self.enable_colors else ""
    #                     reset = self.colors["reset"] if self.enable_colors else ""
                        print(f"{color}Warnings:{reset}")
    #                     for warning in value:
                            print(f"  - {warning}")
    #             elif key == "file" and isinstance(value, str):
    #                 color = self.colors["cyan"] if self.enable_colors else ""
    #                 reset = self.colors["reset"] if self.enable_colors else ""
                    print(f"{color}File:{reset} {value}")
    #             elif key == "valid" and isinstance(value, bool):
    #                 status = "✓" if value else "✗"
    #                 color = self.colors["green"] if value else self.colors["red"]
    #                 reset = self.colors["reset"] if self.enable_colors else ""
                    print(f"{color}{status} {key.capitalize()}{reset}")
    #             elif isinstance(value, dict):
    #                 color = self.colors["blue"] if self.enable_colors else ""
    #                 reset = self.colors["reset"] if self.enable_colors else ""
                    print(f"{color}{key.capitalize()}:{reset}")
    #                 for sub_key, sub_value in value.items():
                        print(f"  {sub_key}: {sub_value}")
    #             else:
    #                 color = self.colors["white"] if self.enable_colors else ""
    #                 reset = self.colors["reset"] if self.enable_colors else ""
                    print(f"{color}{key.capitalize()}:{reset} {value}")

    #     def _format_list_text(self, data: list) -> None:
    #         """Format a list as text."""
    #         for i, item in enumerate(data):
    #             if isinstance(item, dict):
    #                 color = self.colors["blue"] if self.enable_colors else ""
    #                 reset = self.colors["reset"] if self.enable_colors else ""
                    print(f"{color}[{i + 1}]{reset}")
    #                 for key, value in item.items():
                        print(f"  {key}: {value}")
    #             else:
                    print(f"[{i + 1}] {item}")

    #     def _print_error(self, message: str) -> None:
    #         """Print an error message."""
    #         color = self.colors["red"] if self.enable_colors else ""
    #         reset = self.colors["reset"] if self.enable_colors else ""
    print(f"{color}Error: {message}{reset}", file = sys.stderr)

    #     def format_validation_result(self, result: Dict[str, Any]) -> None:
    #         """Format a validation result."""
    file_path = result.get("file", "Unknown")
    is_valid = result.get("valid", False)

    #         color = self.colors["green"] if is_valid else self.colors["red"]
    #         reset = self.colors["reset"] if self.enable_colors else ""
    #         status = "✓" if is_valid else "✗"

            print(f"{color}{status} Validation: {file_path}{reset}")

    #         if "results" in result:
    #             for check_type, check_result in result["results"].items():
    check_valid = check_result.get("valid", False)
    #                 check_color = self.colors["green"] if check_valid else self.colors["red"]
    #                 check_reset = self.colors["reset"] if self.enable_colors else ""
    #                 check_status = "✓" if check_valid else "✗"

                    print(f"  {check_color}{check_status} {check_type.capitalize()}{check_reset}")

    #                 if not check_valid and "errors" in check_result:
    #                     for error in check_result["errors"]:
                            print(f"    - {error}")

    #                 if "warnings" in check_result:
    #                     for warning in check_result["warnings"]:
    #                         warning_color = self.colors["yellow"] if self.enable_colors else ""
    #                         warning_reset = self.colors["reset"] if self.enable_colors else ""
                            print(f"    {warning_color}! {warning}{warning_reset}")

    #     def format_ai_guard_result(self, result: Dict[str, Any]) -> None:
    #         """Format an AI guard result."""
    file_path = result.get("file", "Unknown")
    source = result.get("source", "Unknown")
    is_valid = result.get("valid", False)

    #         color = self.colors["green"] if is_valid else self.colors["red"]
    #         reset = self.colors["reset"] if self.enable_colors else ""
    #         status = "✓" if is_valid else "✗"

            print(f"{color}{status} AI Guard Check: {file_path}{reset}")
            print(f"  Source: {source}")

    #         if "result" in result:
    guard_result = result["result"]
    action = guard_result.get("action", "UNKNOWN")

    #             action_color = self.colors["green"] if action == "ALLOW" else self.colors["red"]
    #             action_reset = self.colors["reset"] if self.enable_colors else ""

                print(f"  Action: {action_color}{action}{action_reset}")

    #             if "reason" in guard_result:
    reason = guard_result["reason"]
                    print(f"  Reason: {reason}")

    #             if "issues" in guard_result:
    issues = guard_result["issues"]
    #                 if issues:
                        print("  Issues:")
    #                     for issue in issues:
    #                         issue_color = self.colors["yellow"] if self.enable_colors else ""
    #                         issue_reset = self.colors["reset"] if self.enable_colors else ""
                            print(f"    {issue_color}- {issue}{issue_reset}")

    #     def format_run_result(self, result: Dict[str, Any]) -> None:
    #         """Format a run result."""
    file_path = result.get("file", "Unknown")
    args = result.get("args", "")
    success = result.get("success", False)
    exit_code = result.get("exit_code", -1)

    #         color = self.colors["green"] if success else self.colors["red"]
    #         reset = self.colors["reset"] if self.enable_colors else ""
    #         status = "✓" if success else "✗"

            print(f"{color}{status} Run: {file_path}{reset}")
    #         if args:
                print(f"  Args: {args}")
            print(f"  Exit Code: {exit_code}")

    #         if "output" in result:
    output = result["output"]
    #             if output:
                    print("  Output:")
    #                 for line in output.split("\n"):
                        print(f"    {line}")

    #     def format_convert_result(self, result: Dict[str, Any]) -> None:
    #         """Format a convert result."""
    input_file = result.get("input_file", "Unknown")
    output_file = result.get("output_file", "Unknown")
    format_type = result.get("format", "Unknown")
    success = result.get("success", False)

    #         color = self.colors["green"] if success else self.colors["red"]
    #         reset = self.colors["reset"] if self.enable_colors else ""
    #         status = "✓" if success else "✗"

            print(f"{color}{status} Convert: {input_file}{reset}")
            print(f"  Output: {output_file}")
            print(f"  Format: {format_type}")

    #     def format_strict_mode_result(self, result: Dict[str, Any]) -> None:
    #         """Format a strict mode result."""
    strict_mode = result.get("strict_mode", False)
    message = result.get("message", "")

    #         color = self.colors["green"] if strict_mode else self.colors["yellow"]
    #         reset = self.colors["reset"] if self.enable_colors else ""
    #         status = "ON" if strict_mode else "OFF"

            print(f"{color}Strict Mode: {status}{reset}")
    #         if message:
                print(f"  {message}")