# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# AI Check Command Module
# -----------------------

# This module implements the ai-check command for the NoodleCore CLI enforcement system.
# The ai-check command reads AI output from STDIN and validates it.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import argparse
import asyncio
import json
import logging
import os
import sys
import typing.Any,

import noodlecore.cli.command_handlers.CommandContext
import noodlecore.cli.error_handler.CLIError
import noodlecore.ai.guard.AIGuard,


class AiCheckCommand
    #     """Command to validate AI-generated code."""

    #     def __init__(self):
    #         """Initialize the ai-check command."""
    self.logger = logging.getLogger(__name__)
    self.ai_guard = AIGuard(GuardConfig(
    enable_validation = True,
    strict_mode = os.environ.get("NOODLE_STRICT_MODE", "false").lower() == "true"
    #         ))

    #     def add_arguments(self, parser: argparse.ArgumentParser) -> None:
    #         """Add command-specific arguments to the parser."""
            parser.add_argument(
    #             "file",
    nargs = "?",
    #             help="File to check (optional, reads from STDIN if not provided)"
    #         )
            parser.add_argument(
    #             "--source",
    help = "AI source identifier"
    #         )
            parser.add_argument(
    #             "--stdin",
    action = "store_true",
    help = "Read code from STDIN"
    #         )
            parser.add_argument(
    #             "--json",
    action = "store_true",
    help = "Output results in JSON format"
    #         )
            parser.add_argument(
    #             "--teach",
    action = "store_true",
    #             help="Provide AI feedback for learning"
    #         )

    #     async def execute(self, context: CommandContext) -> Dict[str, Any]:
    #         """Execute the ai-check command."""
    file_path = context.args.file
    source = context.args.source or "unknown"
    use_stdin = context.args.stdin
    output_json = context.args.json
    teach = context.args.teach

    #         # Get code from file or STDIN
    #         if use_stdin or not file_path:
    code = self._read_from_stdin()
    file_display = "STDIN"
    #         else:
    #             # Check if file exists
    #             if not os.path.exists(file_path):
                    raise CLIError(1003, f"File not found: {file_path}")

    #             # Read file
    #             try:
    #                 with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()
    file_display = file_path
    #             except Exception as e:
                    raise CLIError(1003, f"Failed to read file: {str(e)}")

    #         self.logger.info(f"Checking AI-generated code from {file_display} with source: {source}")

    results = {
    #             "file": file_display,
    #             "source": source,
    #             "request_id": context.request_id,
    #             "teach": teach
    #         }

    #         # Perform AI guard validation
    #         try:
    guard_result = await self.ai_guard.validate_code(code, source)
    results["valid"] = guard_result.action == GuardAction.ALLOW
    results["guard_result"] = guard_result.to_dict()

    #             # Extract specific information for easier access
    #             results["issues"] = guard_result.issues if hasattr(guard_result, 'issues') else []
    #             results["suggestions"] = guard_result.suggestions if hasattr(guard_result, 'suggestions') else []
    #             results["risk_level"] = guard_result.risk_level if hasattr(guard_result, 'risk_level') else "unknown"

    #         except Exception as e:
    results["valid"] = False
    results["error"] = f"AI validation failed: {str(e)}"
    results["issues"] = [f"Validation error: {str(e)}"]
    results["suggestions"] = []
    results["risk_level"] = "high"

    #         # Add teaching feedback if requested
    #         if teach and not results["valid"]:
    results["teaching_feedback"] = self._generate_teaching_feedback(results)

    #         # Format output
    #         if output_json:
                self._output_json(results)
    #         else:
                self._output_text(results)

    #         return results

    #     def _read_from_stdin(self) -> str:
    #         """Read code from STDIN."""
    #         try:
    #             if sys.stdin.isatty():
    #                 # Interactive mode - prompt for input
                    print("Enter AI-generated code (Ctrl+D to finish):")
    lines = []
    #                 while True:
    #                     try:
    line = input()
                            lines.append(line)
    #                     except EOFError:
    #                         break
                    return "\n".join(lines)
    #             else:
    #                 # Piped input
                    return sys.stdin.read()
    #         except Exception as e:
                raise CLIError(1003, f"Failed to read from STDIN: {str(e)}")

    #     def _generate_teaching_feedback(self, results: Dict[str, Any]) -> List[str]:
    #         """Generate teaching feedback for AI validation issues."""
    feedback = []

    #         if results.get("risk_level") == "high":
                feedback.append("High Risk Issues Detected:")
                feedback.append("  This code may contain security vulnerabilities or harmful patterns.")
                feedback.append("  Review the code carefully before using it in production.")

    #         if results.get("issues"):
                feedback.append("Issues Found:")
    #             for issue in results["issues"]:
                    feedback.append(f"  - {issue}")
                feedback.append("  Tips: Address these issues to ensure code safety and correctness.")

    #         if results.get("suggestions"):
    #             feedback.append("Suggestions for Improvement:")
    #             for suggestion in results["suggestions"]:
                    feedback.append(f"  - {suggestion}")

            feedback.append("General AI Code Guidelines:")
            feedback.append("  - Always review AI-generated code before use")
            feedback.append("  - Test code in isolated environments first")
    #         feedback.append("  - Be cautious with code that accesses external resources")
            feedback.append("  - Validate inputs and outputs properly")

    #         return feedback

    #     def _output_text(self, results: Dict[str, Any]) -> None:
    #         """Output results in text format."""
            print(f"AI Check Results for: {results['file']}")
            print(f"Source: {results['source']}")
            print(f"Risk Level: {results.get('risk_level', 'unknown').upper()}")
    #         print(f"Overall Status: {'✓ Approved' if results['valid'] else '✗ Rejected'}")
            print()

    #         if results.get("error"):
                print(f"Error: {results['error']}")
                print()

    #         # Issues
    #         if results.get("issues"):
                print("Issues Found:")
    #             for issue in results["issues"]:
                    print(f"  - {issue}")
                print()
    #         else:
                print("No issues found")
                print()

    #         # Suggestions
    #         if results.get("suggestions"):
                print("Suggestions:")
    #             for suggestion in results["suggestions"]:
                    print(f"  - {suggestion}")
                print()

    #         # Teaching feedback
    #         if results.get("teaching_feedback"):
                print("Teaching Feedback:")
    #             for line in results["teaching_feedback"]:
                    print(line)

    #     def _output_json(self, results: Dict[str, Any]) -> None:
    #         """Output results in JSON format."""
    print(json.dumps(results, indent = 2))