# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Command Handlers Module
# -----------------------

# This module provides the command handler infrastructure for the NoodleCore CLI.
# It defines the base command handler class and context for command execution.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import argparse
import time
import abc.ABC,
import dataclasses.dataclass
import typing.Any,

import noodlecore.cli.main.CLICommand


# @dataclass
class CommandContext
    #     """Context for command execution."""
    #     command: CLICommand
    #     args: argparse.Namespace
    #     request_id: str
    #     start_time: float
    metadata: Optional[Dict[str, Any]] = None


class CommandHandler(ABC)
    #     """Base class for command handlers."""

    #     def __init__(self, command: CLICommand, handler: Callable):
    #         """Initialize the command handler."""
    self.command = command
    self.handler = handler

    #     async def execute(self, context: CommandContext) -> Dict[str, Any]:
    #         """Execute the command with the given context."""
    #         try:
                return await self.handler(context)
    #         except Exception as e:
    #             return {
    #                 "success": False,
                    "error": str(e),
    #                 "command": self.command.value,
    #                 "request_id": context.request_id,
                    "duration": time.time() - context.start_time
    #             }


class CommandRegistry
    #     """Registry for command handlers."""

    #     def __init__(self):
    #         """Initialize the command registry."""
    self._handlers: Dict[CLICommand, CommandHandler] = {}

    #     def register(self, command: CLICommand, handler: CommandHandler) -> None:
    #         """Register a command handler."""
    self._handlers[command] = handler

    #     def get_handler(self, command: CLICommand) -> Optional[CommandHandler]:
    #         """Get a handler for a command."""
            return self._handlers.get(command)

    #     def list_commands(self) -> List[CLICommand]:
    #         """List all registered commands."""
            return list(self._handlers.keys())

    #     def has_command(self, command: CLICommand) -> bool:
    #         """Check if a command is registered."""
    #         return command in self._handlers


# Global command registry instance
command_registry = CommandRegistry()


def register_command(command: CLICommand, handler: Callable) -> None:
#     """Register a command with the global registry."""
command_handler = CommandHandler(command, handler)
    command_registry.register(command, command_handler)


def get_command_handler(command: CLICommand) -> Optional[CommandHandler]:
#     """Get a command handler from the global registry."""
    return command_registry.get_handler(command)