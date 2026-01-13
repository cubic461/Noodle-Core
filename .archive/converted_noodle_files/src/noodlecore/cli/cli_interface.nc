# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore CLI Interface Module
 = =============================

# Provides interface classes for CLI operations.
# """

import typing.Dict,


class CLIInterface
    #     """Base interface for CLI operations."""

    #     def __init__(self):
    #         """Initialize CLI interface."""
    self.running = False
    self.commands = {}

    #     def start(self):
    #         """Start the CLI interface."""
    self.running = True
            print("CLI Interface started")

    #     def stop(self):
    #         """Stop the CLI interface."""
    self.running = False
            print("CLI Interface stopped")

    #     def add_command(self, name: str, handler):
    #         """Add a command to the interface."""
    self.commands[name] = handler

    #     def remove_command(self, name: str):
    #         """Remove a command from the interface."""
    #         if name in self.commands:
    #             del self.commands[name]

    #     def list_commands(self) -> Dict[str, Any]:
    #         """List all available commands."""
            return self.commands.copy()

    #     def is_running(self) -> bool:
    #         """Check if the interface is running."""
    #         return self.running