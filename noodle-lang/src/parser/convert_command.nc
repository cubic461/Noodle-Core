# Converted from Python to NoodleCore
# Original file: src

# """
# Convert Command Module
# ----------------------

# This module implements the convert command for the NoodleCore CLI enforcement system.
# The convert command tries to convert external code to NoodleCore.

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
import typing.Any

import noodlecore.cli.command_handlers.CommandContext
import noodlecore.cli.error_handler.CLIError
import noodlecore.compiler.frontend.get_frontend
import noodlecore.runtime.NBCRuntime


class ConvertCommand
    #     """Command to convert external code to NoodleCore."""

    #     def __init__(self):""Initialize the convert command."""
    self.logger = logging.getLogger(__name__)
    self.compiler_frontend = get_frontend()
    self.runtime = NBCRuntime()

    #     def add_arguments(self, parser: argparse.ArgumentParser) -None):
    #         """Add command-specific arguments to the parser."""
            parser.add_argument(
    #             "input",
    help = "Input file to convert"
    #         )
            parser.add_argument(
    #             "output",
    help = "Output file"
    #         )
            parser.add_argument(
    #             "--format",
    choices = ["bytecode", "python", "javascript", "noodle"],
    default = "bytecode",
    help = "Output format"
    #         )
            parser.add_argument(
    #             "--input-format",
    choices = ["python", "javascript", "auto"],
    default = "auto",
    #             help="Input format (auto-detect if not specified)"
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
    #             "--force",
    action = "store_true",
    #             help="Force conversion even if there are errors"
    #         )

    #     async def execute(self, context: CommandContext) -Dict[str, Any]):
    #         """Execute the convert command."""
    input_file = context.args.input
    output_file = context.args.output
    format_type = context.args.format
    input_format = context.args.input_format
    output_json = context.args.json
    teach = context.args.teach
    force = context.args.force

            self.logger.info(f"Converting {input_file} to {output_file} in {format_type} format")

    #         # Check if input file exists
    #         if not os.path.exists(input_file):
                raise CLIError(1006, f"Input file not found: {input_file}")

    #         # Check if output directory exists
    output_dir = os.path.dirname(output_file)
    #         if output_dir and not os.path.exists(output_dir):
    #             try:
    os.makedirs(output_dir, exist_ok = True)
    #             except Exception as e:
                    raise CLIError(1006, f"Failed to create output directory: {str(e)}")

    #         # Read input file
    #         try:
    #             with open(input_file, 'r', encoding='utf-8') as f:
    code = f.read()
    #         except Exception as e:
                raise CLIError(1006, f"Failed to read input file: {str(e)}")

    #         # Detect input format if not specified
    #         if input_format == "auto":
    input_format = self._detect_input_format(input_file, code)

    results = {
    #             "input_file": input_file,
    #             "output_file": output_file,
    #             "input_format": input_format,
    #             "output_format": format_type,
    #             "request_id": context.request_id,
    #             "teach": teach,
    #             "force": force
    #         }

    #         # Convert based on input format
    #         if input_format == "noodle":
    #             # Parse the Noodle code
    parse_request = ParseRequest(
    code = code,
    file_path = input_file,
    mode = "compile"
    #             )
    parse_result = await self.compiler_frontend.parse(parse_request)

    #             if not parse_result.success:
    results["success"] = False
    results["errors"] = parse_result.errors
    #                 if not force:
                        raise CLIError(1007, f"Failed to parse input file: {parse_result.errors}")
    #             else:
    results["success"] = True
    results["ast"] = parse_result.ast

    #                 # Convert to specified format
    #                 try:
    #                     if format_type == "bytecode":
    converted = await self.runtime.compile_to_bytecode(parse_result.ast)
    #                     elif format_type == "python":
    converted = await self.runtime.compile_to_python(parse_result.ast)
    #                     elif format_type == "javascript":
    converted = await self.runtime.compile_to_javascript(parse_result.ast)
    #                     elif format_type == "noodle":
    #                         # Pretty print the Noodle code
    converted = await self.runtime.pretty_print(parse_result.ast)
    #                     else:
                            raise CLIError(1008, f"Unsupported output format: {format_type}")

    #                     # Write output file
    #                     with open(output_file, 'w', encoding='utf-8') as f:
                            f.write(converted)

    results["converted"] = True

    #                 except Exception as e:
    results["success"] = False
    results["errors"] = [f"Failed to convert file: {str(e)}"]
    #                     if not force:
                            raise CLIError(1009, f"Failed to convert file: {str(e)}")

    #         else:
    #             # Convert from external format to Noodle
    #             try:
    #                 # This would use a transpiler to convert from the external format to Noodle
    #                 # For now, we'll provide a placeholder implementation
    converted = await self._convert_external_to_noodle(code, input_format)

    #                 # If the output format is noodle, write the converted code
    #                 if format_type == "noodle":
    #                     with open(output_file, 'w', encoding='utf-8') as f:
                            f.write(converted)
    results["converted"] = True
    results["success"] = True
    #                 else:
    #                     # First convert to Noodle, then to the target format
    parse_request = ParseRequest(
    code = converted,
    file_path = output_file,
    mode = "compile"
    #                     )
    parse_result = await self.compiler_frontend.parse(parse_request)

    #                     if not parse_result.success:
    results["success"] = False
    results["errors"] = parse_result.errors
    #                         if not force:
                                raise CLIError(1007, f"Failed to parse converted code: {parse_result.errors}")
    #                     else:
    #                         # Convert to specified format
    #                         if format_type == "bytecode":
    final_converted = await self.runtime.compile_to_bytecode(parse_result.ast)
    #                         elif format_type == "python":
    final_converted = await self.runtime.compile_to_python(parse_result.ast)
    #                         elif format_type == "javascript":
    final_converted = await self.runtime.compile_to_javascript(parse_result.ast)
    #                         else:
                                raise CLIError(1008, f"Unsupported output format: {format_type}")

    #                         # Write output file
    #                         with open(output_file, 'w', encoding='utf-8') as f:
                                f.write(final_converted)

    results["converted"] = True
    results["success"] = True

    #             except Exception as e:
    results["success"] = False
    results["errors"] = [f"Failed to convert from {input_format}: {str(e)}"]
    #                 if not force:
                        raise CLIError(1009, f"Failed to convert file: {str(e)}")

    #         # Add teaching feedback if requested
    #         if teach:
    results["teaching_feedback"] = self._generate_teaching_feedback(results)

    #         # Format output
    #         if output_json:
                self._output_json(results)
    #         else:
                self._output_text(results)

    #         return results

    #     def _detect_input_format(self, file_path: str, code: str) -str):
    #         """Detect the input format based on file extension and code content."""
    #         # Check file extension first
    _, ext = os.path.splitext(file_path)
    ext = ext.lower()

    #         if ext == ".py":
    #             return "python"
    #         elif ext in [".js", ".jsx", ".mjs"]:
    #             return "javascript"
    #         elif ext in [".noodle", ".nd"]:
    #             return "noodle"

    #         # Try to detect from code content
    #         if "def " in code and "import " in code:
    #             return "python"
    #         elif "function " in code or "const " in code or "let " in code:
    #             return "javascript"
    #         elif "func " in code or "let " in code and "import " not in code:
    #             return "noodle"

    #         # Default to python
    #         return "python"

    #     async def _convert_external_to_noodle(self, code: str, input_format: str) -str):
    #         """Convert external code format to Noodle."""
    #         # This is a placeholder implementation
    #         # In a real implementation, this would use a transpiler

    #         if input_format == "python":
                # Simple Python to Noodle conversion (placeholder)
    #             noodle_code = code.replace("def ", "func ")
    noodle_code = noodle_code.replace("import ", "use ")
    noodle_code = noodle_code.replace("print(", "output(")
    #             return noodle_code

    #         elif input_format == "javascript":
                # Simple JavaScript to Noodle conversion (placeholder)
    noodle_code = code.replace("function ", "func ")
    noodle_code = code.replace("const ", "let ")
    noodle_code = noodle_code.replace("let ", "let ")
    noodle_code = noodle_code.replace("console.log(", "output(")
    #             return noodle_code

    #         else:
                raise CLIError(1009, f"Unsupported input format: {input_format}")

    #     def _generate_teaching_feedback(self, results: Dict[str, Any]) -List[str]):
    #         """Generate teaching feedback for the conversion process."""
    feedback = []

    #         if results.get("success"):
                feedback.append(f"Successfully converted {results['input_format']} to {results['output_format']}")

    #             if results["input_format"] != "noodle" and results["output_format"] == "noodle":
    #                 feedback.append("Tips for working with Noodle:")
                    feedback.append("  - Noodle uses 'func' instead of 'def' or 'function'")
                    feedback.append("  - Use 'output()' instead of 'print()' or 'console.log()'")
                    feedback.append("  - Import statements use 'use' instead of 'import'")

    #             if results["input_format"] == "noodle" and results["output_format"] != "noodle":
    #                 feedback.append(f"Tips for {results['output_format']}:")
    #                 if results["output_format"] == "python":
                        feedback.append("  - Python uses 'def' instead of 'func'")
                        feedback.append("  - Use 'print()' instead of 'output()'")
    #                 elif results["output_format"] == "javascript":
                        feedback.append("  - JavaScript uses 'function' or arrow functions")
                        feedback.append("  - Use 'console.log()' instead of 'output()'")
    #         else:
                feedback.append("Conversion failed. Common issues:")
                feedback.append("  - Syntax errors in the input file")
                feedback.append("  - Unsupported language features")
                feedback.append("  - Type mismatches")

    #             if results.get("errors"):
                    feedback.append("Specific errors:")
    #                 for error in results["errors"]:
                        feedback.append(f"  - {error}")

    #         return feedback

    #     def _output_text(self, results: Dict[str, Any]) -None):
    #         """Output results in text format."""
            print(f"Conversion Results:")
            print(f"Input File: {results['input_file']}")
            print(f"Output File: {results['output_file']}")
            print(f"Input Format: {results['input_format']}")
            print(f"Output Format: {results['output_format']}")
    #         print(f"Status: {'✓ Success' if results.get('success') else '✗ Failed'}")
            print()

    #         if results.get("errors"):
                print("Errors:")
    #             for error in results["errors"]:
                    print(f"  - {error}")
                print()

    #         # Teaching feedback
    #         if results.get("teaching_feedback"):
                print("Teaching Feedback:")
    #             for line in results["teaching_feedback"]:
                    print(line)

    #     def _output_json(self, results: Dict[str, Any]) -None):
    #         """Output results in JSON format."""
    print(json.dumps(results, indent = 2))