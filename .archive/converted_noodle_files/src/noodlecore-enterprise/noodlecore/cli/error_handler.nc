# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Error Handler Module
# -------------------

# This module provides error handling functionality for the NoodleCore CLI,
# including custom exception classes with 4-digit error codes as required by
# the Noodle AI Coding Agent Development Standards.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import logging
import sys
import traceback
import typing.Any,

import noodlecore.cli.cmdb_logger.CMDBLogger


class CLIError(Exception)
    #     """Base exception for CLI errors with 4-digit error codes."""

    #     def __init__(self, error_code: int, message: str, details: Optional[Dict[str, Any]] = None):
    #         """Initialize the CLI error."""
            super().__init__(message)
    self.error_code = error_code
    self.message = message
    self.details = details or {}

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert error to dictionary representation."""
    #         return {
    #             "error_code": self.error_code,
    #             "message": self.message,
    #             "details": self.details
    #         }


class ValidationError(CLIError)
    #     """Exception for validation errors."""

    #     def __init__(self, error_code: int, message: str, file_path: Optional[str] = None,
    line_number: Optional[int] = None, column: Optional[int] = None):
    #         """Initialize the validation error."""
    details = {}
    #         if file_path:
    details["file_path"] = file_path
    #         if line_number:
    details["line_number"] = line_number
    #         if column:
    details["column"] = column

            super().__init__(error_code, message, details)


class ConfigurationError(CLIError)
    #     """Exception for configuration errors."""

    #     def __init__(self, error_code: int, message: str, config_key: Optional[str] = None):
    #         """Initialize the configuration error."""
    details = {}
    #         if config_key:
    details["config_key"] = config_key

            super().__init__(error_code, message, details)


class RuntimeError(CLIError)
    #     """Exception for runtime errors."""

    #     def __init__(self, error_code: int, message: str, exit_code: Optional[int] = None):
    #         """Initialize the runtime error."""
    details = {}
    #         if exit_code:
    details["exit_code"] = exit_code

            super().__init__(error_code, message, details)


class AIGuardError(CLIError)
    #     """Exception for AI guard errors."""

    #     def __init__(self, error_code: int, message: str, source: Optional[str] = None):
    #         """Initialize the AI guard error."""
    details = {}
    #         if source:
    details["source"] = source

            super().__init__(error_code, message, details)


class ErrorHandler
    #     """Base class for error handlers."""

    #     def __init__(self, logger: logging.Logger):
    #         """Initialize the error handler."""
    self.logger = logger


class CLIErrorHandler(ErrorHandler)
    #     """Error handler for CLI operations."""

    #     def __init__(self, cmdb_logger: CMDBLogger):
    #         """Initialize the CLI error handler."""
            super().__init__(logging.getLogger(__name__))
    self.cmdb_logger = cmdb_logger

    #     async def handle_cli_error(self, error: CLIError, request_id: str) -> None:
    #         """Handle a CLI error."""
    #         # Log the error
            self.logger.error(f"CLI Error {error.error_code}: {error.message}")

    #         # Log to CMDB
            await self.cmdb_logger.log_error(
    error_code = error.error_code,
    message = error.message,
    request_id = request_id,
    details = error.details
    #         )

    #         # Print error to stderr
            self._print_error(error)

    #     def _print_error(self, error: CLIError) -> None:
    #         """Print error to stderr."""
    print(f"Error {error.error_code}: {error.message}", file = sys.stderr)

    #         if error.details:
    #             for key, value in error.details.items():
    print(f"  {key}: {value}", file = sys.stderr)

    #         # Print stack trace in debug mode
    #         if self.logger.isEnabledFor(logging.DEBUG):
    traceback.print_exc(file = sys.stderr)

    #     async def handle_unexpected_error(self, error: Exception, request_id: str) -> None:
    #         """Handle an unexpected error."""
    #         # Create a CLI error from the exception
    cli_error = CLIError(
    error_code = 9999,
    message = f"Unexpected error: {str(error)}",
    details = {"type": type(error).__name__}
    #         )

            await self.handle_cli_error(cli_error, request_id)


# Error code constants
class ErrorCodes
    #     """Error code constants for CLI operations."""

        # General errors (1000-1099)
    UNKNOWN_COMMAND = 1001
    FILE_READ_ERROR = 1002
    AI_CHECK_FILE_READ_ERROR = 1003
    VALIDATION_FAILED = 1004
    RUN_FAILED = 1005
    CONVERT_INPUT_READ_ERROR = 1006
    CONVERT_PARSE_ERROR = 1007
    CONVERT_UNSUPPORTED_FORMAT = 1008
    CONVERT_FAILED = 1009
    STRICT_MODE_INVALID_ARGS = 1010

        # Configuration errors (1100-1199)
    CONFIG_LOAD_ERROR = 1101
    CONFIG_MISSING_KEY = 1102
    CONFIG_INVALID_VALUE = 1103

        # Validation errors (1200-1299)
    SYNTAX_ERROR = 1201
    SEMANTIC_ERROR = 1202
    TYPE_ERROR = 1203
    IMPORT_ERROR = 1204

        # Runtime errors (1300-1399)
    RUNTIME_INIT_ERROR = 1301
    RUNTIME_EXECUTION_ERROR = 1302
    RUNTIME_TIMEOUT = 1303

        # AI Guard errors (1400-1499)
    AI_GUARD_VALIDATION_FAILED = 1401
    AI_GUARD_POLICY_VIOLATION = 1402
    AI_GUARD_SOURCE_BLOCKED = 1403

        # Database errors (1500-1599)
    DATABASE_CONNECTION_ERROR = 1501
    DATABASE_QUERY_ERROR = 1502
    DATABASE_TIMEOUT = 1503

        # System errors (9000-9999)
    UNEXPECTED_ERROR = 9999