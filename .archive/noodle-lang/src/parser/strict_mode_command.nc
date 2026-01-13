# Converted from Python to NoodleCore
# Original file: src

# """
# Strict Mode Command Module
# --------------------------

# This module implements the strict-mode command for the NoodleCore CLI enforcement system.
# The strict-mode command enables/disables .nc requirement enforcement.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import argparse
import asyncio
import json
import logging
import os
import typing.Any

import noodlecore.cli.command_handlers.CommandContext
import noodlecore.cli.error_handler.CLIError


class StrictModeCommand
    #     """Command to enable or disable strict mode for NoodleCore enforcement."""

    #     def __init__(self):""Initialize the strict-mode command."""
    self.logger = logging.getLogger(__name__)
    self.config_file = os.path.expanduser("~/.noodlecore_config.json")

    #     def add_arguments(self, parser: argparse.ArgumentParser) -None):
    #         """Add command-specific arguments to the parser."""
    group = parser.add_mutually_exclusive_group()
            group.add_argument(
    #             "--enable",
    action = "store_true",
    help = "Enable strict mode"
    #         )
            group.add_argument(
    #             "--disable",
    action = "store_true",
    help = "Disable strict mode"
    #         )
            parser.add_argument(
    #             "--global",
    action = "store_true",
    help = "Apply setting globally (affects all projects)"
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

    #     async def execute(self, context: CommandContext) -Dict[str, Any]):
    #         """Execute the strict-mode command."""
    enable = context.args.enable
    disable = context.args.disable
    global_setting = context.args.global
    output_json = context.args.json
    teach = context.args.teach

    #         if enable and disable:
                raise CLIError(1010, "Cannot both enable and disable strict mode")

    results = {
    #             "request_id": context.request_id,
    #             "teach": teach,
    #             "global": global_setting
    #         }

    #         # Determine config file path
    #         config_path = self.config_file if global_setting else ".noodlecore_config.json"

    #         # Load current configuration
    config = self._load_config(config_path)
    current_status = config.get("strict_mode", False)

    #         if not enable and not disable:
    #             # Show current status
    results["strict_mode"] = current_status
    results["action"] = "status"

    #             if output_json:
                    self._output_json(results)
    #             else:
                    self._output_text(results)

    #             return results

    #         # Update strict mode
    new_status = enable
    config["strict_mode"] = new_status

    #         # Save configuration
            self._save_config(config_path, config)

    #         # Update environment variable for current session
    #         os.environ["NOODLE_STRICT_MODE"] = "true" if new_status else "false"

            results.update({
    #             "strict_mode": new_status,
    #             "previous_status": current_status,
    #             "action": "toggle",
    #             "config_file": config_path
    #         })

    #         # Add teaching feedback if requested
    #         if teach:
    results["teaching_feedback"] = self._generate_teaching_feedback(results)

    #         # Format output
    #         if output_json:
                self._output_json(results)
    #         else:
                self._output_text(results)

    #         return results

    #     def _load_config(self, config_path: str) -Dict[str, Any]):
    #         """Load configuration from file."""
    #         try:
    #             if os.path.exists(config_path):
    #                 with open(config_path, 'r', encoding='utf-8') as f:
                        return json.load(f)
    #             else:
    #                 return {}
    #         except Exception as e:
                self.logger.warning(f"Failed to load config from {config_path}: {str(e)}")
    #             return {}

    #     def _save_config(self, config_path: str, config: Dict[str, Any]) -None):
    #         """Save configuration to file."""
    #         try:
    #             # Create directory if it doesn't exist
    config_dir = os.path.dirname(config_path)
    #             if config_dir and not os.path.exists(config_dir):
    os.makedirs(config_dir, exist_ok = True)

    #             with open(config_path, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent = 2)
    #         except Exception as e:
                raise CLIError(1011, f"Failed to save config to {config_path}: {str(e)}")

    #     def _generate_teaching_feedback(self, results: Dict[str, Any]) -List[str]):
    #         """Generate teaching feedback for strict mode changes."""
    feedback = []

    #         if results["strict_mode"]:
                feedback.append("Strict mode is now ENABLED.")
                feedback.append("")
                feedback.append("What strict mode does:")
                feedback.append("  - Enforces .nc file extension requirement")
                feedback.append("  - Applies stricter validation rules")
                feedback.append("  - Requires explicit type declarations")
                feedback.append("  - Disallows potentially unsafe operations")
                feedback.append("")
                feedback.append("Benefits of strict mode:")
                feedback.append("  - Catches errors earlier in development")
                feedback.append("  - Improves code quality and consistency")
                feedback.append("  - Enhances security by preventing risky patterns")
                feedback.append("  - Makes code more maintainable")
                feedback.append("")
                feedback.append("Things to be aware of:")
                feedback.append("  - Some existing code may need modifications")
                feedback.append("  - Development might be slower initially")
                feedback.append("  - More explicit code is required")
    #         else:
                feedback.append("Strict mode is now DISABLED.")
                feedback.append("")
                feedback.append("What this means:")
                feedback.append("  - .nc file extension is not strictly required")
                feedback.append("  - More permissive validation rules")
                feedback.append("  - Type inference is allowed")
                feedback.append("  - Some potentially unsafe operations are allowed")
                feedback.append("")
                feedback.append("When to use strict mode:")
                feedback.append("  - For production code")
                feedback.append("  - In team environments")
                feedback.append("  - For critical security applications")
                feedback.append("  - When learning Noodle best practices")
                feedback.append("")
                feedback.append("When to disable strict mode:")
                feedback.append("  - For quick prototyping")
                feedback.append("  - When learning the language")
                feedback.append("  - For simple scripts and utilities")

    #         if results.get("global"):
                feedback.append("")
                feedback.append("This setting has been applied globally and will affect all NoodleCore projects.")
    #         else:
                feedback.append("")
                feedback.append("This setting applies only to the current project.")
                feedback.append("Use --global to apply this setting to all projects.")

    #         return feedback

    #     def _output_text(self, results: Dict[str, Any]) -None):
    #         """Output results in text format."""
    #         if results.get("action") == "status":
    #             status = "ENABLED" if results["strict_mode"] else "DISABLED"
    #             scope = "globally" if results.get("global") else "for this project"
                print(f"Strict mode is currently {status} {scope}.")

    #             if results.get("global"):
                    print(f"Global config file: {self.config_file}")
    #             else:
                    print("Project config file: .noodlecore_config.json")
    #         else:
    #             status = "ENABLED" if results["strict_mode"] else "DISABLED"
    #             previous = "ENABLED" if results["previous_status"] else "DISABLED"
    #             scope = "globally" if results.get("global") else "for this project"

                print(f"Strict mode {status} {scope}.")
                print(f"Previous status: {previous}")
                print(f"Config file: {results['config_file']}")

    #         # Teaching feedback
    #         if results.get("teaching_feedback"):
                print()
                print("Teaching Feedback:")
    #             for line in results["teaching_feedback"]:
                    print(line)

    #     def _output_json(self, results: Dict[str, Any]) -None):
    #         """Output results in JSON format."""
    print(json.dumps(results, indent = 2))