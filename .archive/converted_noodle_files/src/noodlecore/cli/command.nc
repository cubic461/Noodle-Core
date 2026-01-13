# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore CLI Command Module
 = ===========================

# Base command classes for CLI operations.
# """

import dataclasses.dataclass
import typing.Dict,


# @dataclass
class CommandResult
    #     """Result of a command execution."""
    success: bool = False
    message: str = ""
    data: Optional[Dict[str, Any]] = None
    error_code: Optional[int] = None


class NoodleCommand
    #     """Base command class for NoodleCore CLI."""

    #     def __init__(self, name: str, handler=None):
    #         """
    #         Initialize command.

    #         Args:
    #             name: Command name
    #             handler: Optional handler function
    #         """
    self.name = name
    self.handler = handler

    #     def execute(self, args: Dict[str, Any]) -> CommandResult:
    #         """
    #         Execute the command.

    #         Args:
    #             args: Command arguments

    #         Returns:
    #             CommandResult instance
    #         """
    #         if self.handler:
    #             try:
    result = self.handler(args)
    #                 if isinstance(result, CommandResult):
    #                     return result
    #                 else:
    return CommandResult(success = True, message="Command executed", data=result)
    #             except Exception as e:
                    return CommandResult(
    success = False,
    message = f"Command failed: {str(e)}",
    error_code = 5001
    #                 )
    #         else:
                return CommandResult(
    success = False,
    #                 message="No handler defined for command",
    error_code = 5002
    #             )