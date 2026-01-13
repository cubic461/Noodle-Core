# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Run Command Module
# ------------------

# This module implements the run command for the NoodleCore CLI enforcement system.
# The run command executes validated code.

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
import time
import typing.Any,

import noodlecore.cli.command_handlers.CommandContext
import noodlecore.cli.error_handler.CLIError
import noodlecore.compiler.frontend.get_frontend,
import noodlecore.linter.NoodleLinter,
import noodlecore.runtime.NBCRuntime


class RunCommand
    #     """Command to run Noodle programs."""

    #     def __init__(self):
    #         """Initialize the run command."""
    self.logger = logging.getLogger(__name__)
    self.compiler_frontend = get_frontend()
    self.linter = NoodleLinter(LinterConfig(
    enable_syntax_check = True,
    enable_semantic_check = True,
    strict_mode = os.environ.get("NOODLE_STRICT_MODE", "false").lower() == "true"
    #         ))
    self.runtime = NBCRuntime()

    #     def add_arguments(self, parser: argparse.ArgumentParser) -> None:
    #         """Add command-specific arguments to the parser."""
            parser.add_argument(
    #             "file",
    help = "File to run"
    #         )
            parser.add_argument(
    #             "--args",
    help = "Program arguments (space-separated)"
    #         )
            parser.add_argument(
    #             "--skip-validation",
    action = "store_true",
    help = "Skip validation before running"
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
            parser.add_argument(
    #             "--timeout",
    type = int,
    default = 30,
    help = "Execution timeout in seconds (default: 30)"
    #         )
            parser.add_argument(
    #             "--capture-output",
    action = "store_true",
    help = "Capture and return program output"
    #         )

    #     async def execute(self, context: CommandContext) -> Dict[str, Any]:
    #         """Execute the run command."""
    file_path = context.args.file
    program_args = context.args.args or ""
    skip_validation = context.args.skip_validation
    output_json = context.args.json
    teach = context.args.teach
    timeout = context.args.timeout
    capture_output = context.args.capture_output

    #         self.logger.info(f"Running file: {file_path} with args: {program_args}")

    #         # Check if file exists
    #         if not os.path.exists(file_path):
                raise CLIError(1004, f"File not found: {file_path}")

    #         # Read file
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()
    #         except Exception as e:
                raise CLIError(1004, f"Failed to read file: {str(e)}")

    results = {
    #             "file": file_path,
    #             "args": program_args,
    #             "request_id": context.request_id,
    #             "skip_validation": skip_validation,
    #             "teach": teach,
    #             "timeout": timeout,
    #             "capture_output": capture_output
    #         }

    #         # Validate the file unless explicitly skipped
    #         if not skip_validation:
    validation_result = await self._validate_code(code, file_path)
    results["validation"] = validation_result

    #             if not validation_result["valid"]:
    results["success"] = False
    results["error"] = "File validation failed"

    #                 if output_json:
                        self._output_json(results)
    #                 else:
                        self._output_text(results)

    #                 return results
    #         else:
    results["validation"] = {"skipped": True}

    #         # Run the program
    #         try:
    start_time = time.time()

    #             # Parse program arguments
    #             args_list = program_args.split() if program_args else []

    #             # Execute with timeout
    run_result = await asyncio.wait_for(
    self.runtime.execute(file_path, args_list, capture_output = capture_output),
    timeout = timeout
    #             )

    execution_time = math.subtract(time.time(), start_time)

                results.update({
    #                 "success": run_result.success,
    #                 "exit_code": run_result.exit_code,
    #                 "execution_time": execution_time
    #             })

    #             if capture_output:
    results["stdout"] = run_result.stdout
    results["stderr"] = run_result.stderr

    #             if not run_result.success:
    #                 results["error"] = run_result.error if hasattr(run_result, 'error') else "Execution failed"

    #         except asyncio.TimeoutError:
    results["success"] = False
    results["error"] = f"Execution timed out after {timeout} seconds"
    results["exit_code"] = 124  # Standard timeout exit code

    #         except Exception as e:
    results["success"] = False
    results["error"] = f"Failed to run program: {str(e)}"
    results["exit_code"] = 1

    #         # Add teaching feedback if requested
    #         if teach:
    results["teaching_feedback"] = self._generate_teaching_feedback(results)

    #         # Format output
    #         if output_json:
                self._output_json(results)
    #         else:
                self._output_text(results)

    #         return results

    #     async def _validate_code(self, code: str, file_path: str) -> Dict[str, Any]:
    #         """Validate the code before running."""
    validation_result = {
    #             "syntax": {"valid": False, "errors": []},
    #             "semantic": {"valid": False, "errors": []},
    #             "valid": False
    #         }

    #         # Perform syntax checking
    parse_request = ParseRequest(
    code = code,
    file_path = file_path,
    mode = "syntax_check"
    #         )

    #         try:
    parse_result = await self.compiler_frontend.parse(parse_request)
    validation_result["syntax"] = {
    #                 "valid": parse_result.success,
    #                 "errors": parse_result.errors if not parse_result.success else []
    #             }
    #         except Exception as e:
    validation_result["syntax"] = {
    #                 "valid": False,
                    "errors": [f"Syntax analysis failed: {str(e)}"]
    #             }

    #         # Perform semantic checking
    #         try:
    linter_result = self.linter.check(code, file_path)
    validation_result["semantic"] = {
    #                 "valid": linter_result.success,
    #                 "errors": linter_result.errors if not linter_result.success else []
    #             }
    #         except Exception as e:
    validation_result["semantic"] = {
    #                 "valid": False,
                    "errors": [f"Semantic analysis failed: {str(e)}"]
    #             }

    validation_result["valid"] = (
    #             validation_result["syntax"]["valid"] and
    #             validation_result["semantic"]["valid"]
    #         )

    #         return validation_result

    #     def _generate_teaching_feedback(self, results: Dict[str, Any]) -> List[str]:
    #         """Generate teaching feedback for the run process."""
    feedback = []

    #         if results.get("success"):
                feedback.append("Program executed successfully!")

    #             if "execution_time" in results:
                    feedback.append(f"Execution time: {results['execution_time']:.2f} seconds")

    #             feedback.append("Tips for improving your Noodle programs:")
                feedback.append("  - Use efficient algorithms to reduce execution time")
    #             feedback.append("  - Handle errors gracefully with try-catch blocks")
    #             feedback.append("  - Use appropriate data structures for your use case")

    #         else:
                feedback.append("Program execution failed.")

    #             if results.get("error"):
    #                 if "timeout" in results["error"].lower():
                        feedback.append("Your program took too long to execute.")
    #                     feedback.append("Tips for fixing timeouts:")
    #                     feedback.append("  - Check for infinite loops")
                        feedback.append("  - Optimize algorithms")
                        feedback.append("  - Reduce unnecessary computations")
    #                 elif "validation" in results["error"].lower():
                        feedback.append("Your code has syntax or semantic errors.")
    #                     feedback.append("Tips for fixing validation errors:")
    #                     feedback.append("  - Check for proper indentation")
                        feedback.append("  - Ensure variables are declared before use")
                        feedback.append("  - Verify function signatures match their calls")
    #                 else:
                        feedback.append(f"Error: {results['error']}")
    #                     feedback.append("Tips for debugging:")
                        feedback.append("  - Add debug output statements")
                        feedback.append("  - Check variable values at different points")
                        feedback.append("  - Verify logic flow")

    #             # Validation feedback
    #             if "validation" in results and not results["validation"].get("valid", True):
    validation = results["validation"]

    #                 if not validation.get("syntax", {}).get("valid", True):
                        feedback.append("Syntax errors found:")
    #                     for error in validation["syntax"].get("errors", []):
                            feedback.append(f"  - {error}")

    #                 if not validation.get("semantic", {}).get("valid", True):
                        feedback.append("Semantic errors found:")
    #                     for error in validation["semantic"].get("errors", []):
                            feedback.append(f"  - {error}")

    #         return feedback

    #     def _output_text(self, results: Dict[str, Any]) -> None:
    #         """Output results in text format."""
            print(f"Run Results for: {results['file']}")

    #         if results.get("args"):
                print(f"Arguments: {results['args']}")

    #         print(f"Status: {'✓ Success' if results.get('success') else '✗ Failed'}")

    #         if "execution_time" in results:
                print(f"Execution Time: {results['execution_time']:.2f} seconds")

    #         if "exit_code" in results:
                print(f"Exit Code: {results['exit_code']}")

    #         if results.get("error"):
                print(f"Error: {results['error']}")

    #         # Validation results
    #         if "validation" in results and not results["validation"].get("skipped", False):
    validation = results["validation"]
                print()
                print("Validation Results:")
    #             print(f"  Syntax: {'✓ Valid' if validation.get('syntax', {}).get('valid') else '✗ Invalid'}")
    #             print(f"  Semantic: {'✓ Valid' if validation.get('semantic', {}).get('valid') else '✗ Invalid'}")

    #         # Captured output
    #         if results.get("capture_output"):
    #             if results.get("stdout"):
                    print()
                    print("Standard Output:")
                    print(results["stdout"])

    #             if results.get("stderr"):
                    print()
                    print("Standard Error:")
                    print(results["stderr"])

    #         # Teaching feedback
    #         if results.get("teaching_feedback"):
                print()
                print("Teaching Feedback:")
    #             for line in results["teaching_feedback"]:
                    print(line)

    #     def _output_json(self, results: Dict[str, Any]) -> None:
    #         """Output results in JSON format."""
    print(json.dumps(results, indent = 2))