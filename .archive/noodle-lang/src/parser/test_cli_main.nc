# Converted from Python to NoodleCore
# Original file: src

# """
# Test Suite for CLI Main Module
# -------------------------------

# This module contains unit tests for the NoodleCore CLI main module,
# testing command parsing, routing, and execution.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import asyncio
import json
import os
import tempfile
import unittest
import unittest.mock.AsyncMock

import noodlecore.ai.guard.AIGuard
import noodlecore.cli.cmdb_logger.CMDBLogger
import noodlecore.cli.command_handlers.CommandHandler
import noodlecore.cli.error_handler.CLIErrorHandler
import noodlecore.cli.main.CLICommand
import noodlecore.cli.output_formatter.OutputFormatter
import noodlecore.compiler.frontend.get_frontend
import noodlecore.database.DatabaseConfig
import noodlecore.linter.NoodleLinter
import noodlecore.runtime.NBCRuntime


class TestNoodleCLIEnforcer(unittest.TestCase)
    #     """Test cases for the NoodleCLIEnforcer class."""

    #     def setUp(self):""Set up test fixtures."""
    self.config = {
    #             "enable_colors": False,
    #             "strict_mode": False
    #         }
    self.temp_dir = tempfile.mkdtemp()

    #         # Create a test file
    self.test_file = os.path.join(self.temp_dir, "test.nc")
    #         with open(self.test_file, 'w') as f:
                f.write("print('Hello, World!')")

    #     def tearDown(self):
    #         """Clean up test fixtures."""
    #         import shutil
            shutil.rmtree(self.temp_dir)

        patch('noodlecore.cli.main.DatabaseModule')
        patch('noodlecore.cli.main.CMDBLogger')
        patch('noodlecore.cli.main.NoodleLinter')
        patch('noodlecore.cli.main.AIGuard')
        patch('noodlecore.cli.main.get_frontend')
        patch('noodlecore.cli.main.NBCRuntime')
        patch('noodlecore.cli.main.CLIErrorHandler')
    #     def test_init(self, mock_error_handler, mock_runtime, mock_get_frontend,
    #                   mock_ai_guard, mock_linter, mock_cmdb_logger, mock_database):
    #         """Test CLI enforcer initialization."""
    #         # Set up mocks
    mock_database_instance = MagicMock()
    mock_database.return_value = mock_database_instance

    mock_cmdb_logger_instance = MagicMock()
    mock_cmdb_logger.return_value = mock_cmdb_logger_instance

    mock_linter_instance = MagicMock()
    mock_linter.return_value = mock_linter_instance

    mock_ai_guard_instance = MagicMock()
    mock_ai_guard.return_value = mock_ai_guard_instance

    mock_frontend_instance = MagicMock()
    mock_get_frontend.return_value = mock_frontend_instance

    mock_runtime_instance = MagicMock()
    mock_runtime.return_value = mock_runtime_instance

    mock_error_handler_instance = MagicMock()
    mock_error_handler.return_value = mock_error_handler_instance

    #         # Create CLI enforcer
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Verify initialization
            self.assertEqual(enforcer.config, self.config)
            self.assertIsNotNone(enforcer.request_id)
            self.assertIsNotNone(enforcer.output_formatter)

    #         # Verify component initialization
            mock_database.assert_called_once()
            mock_cmdb_logger.assert_called_once_with(mock_database_instance)
            mock_linter.assert_called_once()
            mock_ai_guard.assert_called_once()
            mock_get_frontend.assert_called_once()
            mock_runtime.assert_called_once()
            mock_error_handler.assert_called_once_with(mock_cmdb_logger_instance)

    #     def test_parse_arguments_validate(self):
    #         """Test parsing validate command arguments."""
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Mock the database and other components to avoid initialization
    #         with patch.object(enforcer, '_init_components'):
    #             with patch.object(enforcer, '_init_command_handlers'):
    args = enforcer.parse_arguments(['validate', self.test_file])

                    self.assertEqual(args.command, 'validate')
                    self.assertEqual(args.file, self.test_file)
                    self.assertFalse(args.syntax_only)

    #     def test_parse_arguments_ai_check(self):
    #         """Test parsing ai-check command arguments."""
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Mock the database and other components to avoid initialization
    #         with patch.object(enforcer, '_init_components'):
    #             with patch.object(enforcer, '_init_command_handlers'):
    args = enforcer.parse_arguments(['ai-check', self.test_file, '--source', 'test-ai'])

                    self.assertEqual(args.command, 'ai-check')
                    self.assertEqual(args.file, self.test_file)
                    self.assertEqual(args.source, 'test-ai')

    #     def test_parse_arguments_run(self):
    #         """Test parsing run command arguments."""
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Mock the database and other components to avoid initialization
    #         with patch.object(enforcer, '_init_components'):
    #             with patch.object(enforcer, '_init_command_handlers'):
    args = enforcer.parse_arguments(['run', self.test_file, '--args', 'test'])

                    self.assertEqual(args.command, 'run')
                    self.assertEqual(args.file, self.test_file)
                    self.assertEqual(args.args, 'test')

    #     def test_parse_arguments_convert(self):
    #         """Test parsing convert command arguments."""
    enforcer = NoodleCLIEnforcer(self.config)

    output_file = os.path.join(self.temp_dir, "output.nbc")

    #         # Mock the database and other components to avoid initialization
    #         with patch.object(enforcer, '_init_components'):
    #             with patch.object(enforcer, '_init_command_handlers'):
    args = enforcer.parse_arguments(['convert', self.test_file, output_file, '--format', 'bytecode'])

                    self.assertEqual(args.command, 'convert')
                    self.assertEqual(args.input, self.test_file)
                    self.assertEqual(args.output, output_file)
                    self.assertEqual(args.format, 'bytecode')

    #     def test_parse_arguments_strict_mode(self):
    #         """Test parsing strict-mode command arguments."""
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Mock the database and other components to avoid initialization
    #         with patch.object(enforcer, '_init_components'):
    #             with patch.object(enforcer, '_init_command_handlers'):
    args = enforcer.parse_arguments(['strict-mode', '--enable'])

                    self.assertEqual(args.command, 'strict-mode')
                    self.assertTrue(args.enable)
                    self.assertFalse(args.disable)

        patch('noodlecore.cli.main.DatabaseModule')
        patch('noodlecore.cli.main.CMDBLogger')
        patch('noodlecore.cli.main.NoodleLinter')
        patch('noodlecore.cli.main.AIGuard')
        patch('noodlecore.cli.main.get_frontend')
        patch('noodlecore.cli.main.NBCRuntime')
        patch('noodlecore.cli.main.CLIErrorHandler')
    #     async def test_execute_validate_command(self, mock_error_handler, mock_runtime,
    #                                            mock_get_frontend, mock_ai_guard,
    #                                            mock_linter, mock_cmdb_logger, mock_database):
    #         """Test executing the validate command."""
    #         # Set up mocks
    mock_database_instance = MagicMock()
    mock_database.return_value = mock_database_instance

    mock_cmdb_logger_instance = AsyncMock()
    mock_cmdb_logger.return_value = mock_cmdb_logger_instance

    mock_linter_instance = MagicMock()
    mock_linter.return_value = mock_linter_instance

    mock_ai_guard_instance = MagicMock()
    mock_ai_guard.return_value = mock_ai_guard_instance

    mock_frontend_instance = AsyncMock()
    mock_get_frontend.return_value = mock_frontend_instance

    mock_runtime_instance = AsyncMock()
    mock_runtime.return_value = mock_runtime_instance

    mock_error_handler_instance = MagicMock()
    mock_error_handler.return_value = mock_error_handler_instance

    #         # Set up parse result
    mock_parse_result = MagicMock()
    mock_parse_result.success = True
    mock_parse_result.errors = []
    mock_frontend_instance.parse.return_value = mock_parse_result

    #         # Set up linter result
    mock_linter_result = MagicMock()
    mock_linter_result.success = True
    mock_linter_result.errors = []
    mock_linter_result.warnings = []
    mock_linter_instance.check.return_value = mock_linter_result

    #         # Create CLI enforcer
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Create mock args
    args = MagicMock()
    args.command = 'validate'
    args.request_id = 'test-request-id'
    args.file = self.test_file
    args.syntax_only = False
    args.output_format = 'text'

    #         # Execute command
    result = await enforcer.execute_command(args)

    #         # Verify result
            self.assertEqual(result, 0)

    #         # Verify logging
            mock_cmdb_logger_instance.log_command_start.assert_called_once()
            mock_cmdb_logger_instance.log_command_complete.assert_called_once()

    #         # Verify frontend and linter were called
            mock_frontend_instance.parse.assert_called_once()
            mock_linter_instance.check.assert_called_once()

        patch('noodlecore.cli.main.DatabaseModule')
        patch('noodlecore.cli.main.CMDBLogger')
        patch('noodlecore.cli.main.NoodleLinter')
        patch('noodlecore.cli.main.AIGuard')
        patch('noodlecore.cli.main.get_frontend')
        patch('noodlecore.cli.main.NBCRuntime')
        patch('noodlecore.cli.main.CLIErrorHandler')
    #     async def test_execute_ai_check_command(self, mock_error_handler, mock_runtime,
    #                                            mock_get_frontend, mock_ai_guard,
    #                                            mock_linter, mock_cmdb_logger, mock_database):
    #         """Test executing the ai-check command."""
    #         # Set up mocks
    mock_database_instance = MagicMock()
    mock_database.return_value = mock_database_instance

    mock_cmdb_logger_instance = AsyncMock()
    mock_cmdb_logger.return_value = mock_cmdb_logger_instance

    mock_linter_instance = MagicMock()
    mock_linter.return_value = mock_linter_instance

    mock_ai_guard_instance = AsyncMock()
    mock_ai_guard.return_value = mock_ai_guard_instance

    mock_frontend_instance = AsyncMock()
    mock_get_frontend.return_value = mock_frontend_instance

    mock_runtime_instance = AsyncMock()
    mock_runtime.return_value = mock_runtime_instance

    mock_error_handler_instance = MagicMock()
    mock_error_handler.return_value = mock_error_handler_instance

    #         # Set up guard result
    mock_guard_result = MagicMock()
    mock_guard_result.action = GuardAction.ALLOW
    mock_guard_result.to_dict.return_value = {"action": "ALLOW", "reason": "Code is safe"}
    mock_ai_guard_instance.validate_code.return_value = mock_guard_result

    #         # Create CLI enforcer
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Create mock args
    args = MagicMock()
    args.command = 'ai-check'
    args.request_id = 'test-request-id'
    args.file = self.test_file
    args.source = 'test-ai'
    args.output_format = 'text'

    #         # Execute command
    result = await enforcer.execute_command(args)

    #         # Verify result
            self.assertEqual(result, 0)

    #         # Verify logging
            mock_cmdb_logger_instance.log_command_start.assert_called_once()
            mock_cmdb_logger_instance.log_command_complete.assert_called_once()

    #         # Verify AI guard was called
            mock_ai_guard_instance.validate_code.assert_called_once()

        patch('noodlecore.cli.main.DatabaseModule')
        patch('noodlecore.cli.main.CMDBLogger')
        patch('noodlecore.cli.main.NoodleLinter')
        patch('noodlecore.cli.main.AIGuard')
        patch('noodlecore.cli.main.get_frontend')
        patch('noodlecore.cli.main.NBCRuntime')
        patch('noodlecore.cli.main.CLIErrorHandler')
    #     async def test_execute_unknown_command(self, mock_error_handler, mock_runtime,
    #                                           mock_get_frontend, mock_ai_guard,
    #                                           mock_linter, mock_cmdb_logger, mock_database):
    #         """Test executing an unknown command."""
    #         # Set up mocks
    mock_database_instance = MagicMock()
    mock_database.return_value = mock_database_instance

    mock_cmdb_logger_instance = AsyncMock()
    mock_cmdb_logger.return_value = mock_cmdb_logger_instance

    mock_linter_instance = MagicMock()
    mock_linter.return_value = mock_linter_instance

    mock_ai_guard_instance = MagicMock()
    mock_ai_guard.return_value = mock_ai_guard_instance

    mock_frontend_instance = AsyncMock()
    mock_get_frontend.return_value = mock_frontend_instance

    mock_runtime_instance = AsyncMock()
    mock_runtime.return_value = mock_runtime_instance

    mock_error_handler_instance = AsyncMock()
    mock_error_handler.return_value = mock_error_handler_instance

    #         # Create CLI enforcer
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Create mock args
    args = MagicMock()
    args.command = 'unknown-command'
    args.request_id = 'test-request-id'
    args.output_format = 'text'

    #         # Execute command
    result = await enforcer.execute_command(args)

    #         # Verify result
    #         self.assertEqual(result, 1001)  # Error code for unknown command

    #         # Verify error handler was called
            mock_error_handler_instance.handle_cli_error.assert_called_once()

        patch('noodlecore.cli.main.DatabaseModule')
        patch('noodlecore.cli.main.CMDBLogger')
        patch('noodlecore.cli.main.NoodleLinter')
        patch('noodlecore.cli.main.AIGuard')
        patch('noodlecore.cli.main.get_frontend')
        patch('noodlecore.cli.main.NBCRuntime')
        patch('noodlecore.cli.main.CLIErrorHandler')
    #     async def test_execute_command_with_error(self, mock_error_handler, mock_runtime,
    #                                              mock_get_frontend, mock_ai_guard,
    #                                              mock_linter, mock_cmdb_logger, mock_database):
    #         """Test executing a command that raises an error."""
    #         # Set up mocks
    mock_database_instance = MagicMock()
    mock_database.return_value = mock_database_instance

    mock_cmdb_logger_instance = AsyncMock()
    mock_cmdb_logger.return_value = mock_cmdb_logger_instance

    mock_linter_instance = MagicMock()
    mock_linter.return_value = mock_linter_instance

    mock_ai_guard_instance = MagicMock()
    mock_ai_guard.return_value = mock_ai_guard_instance

    mock_frontend_instance = AsyncMock()
    mock_get_frontend.return_value = mock_frontend_instance

    mock_runtime_instance = AsyncMock()
    mock_runtime.return_value = mock_runtime_instance

    mock_error_handler_instance = AsyncMock()
    mock_error_handler.return_value = mock_error_handler_instance

    #         # Make frontend.parse raise an exception
    mock_frontend_instance.parse.side_effect = Exception("Test error")

    #         # Create CLI enforcer
    enforcer = NoodleCLIEnforcer(self.config)

    #         # Create mock args
    args = MagicMock()
    args.command = 'validate'
    args.request_id = 'test-request-id'
    args.file = self.test_file
    args.syntax_only = False
    args.output_format = 'text'

    #         # Execute command
    result = await enforcer.execute_command(args)

    #         # Verify result
    #         self.assertEqual(result, 9999)  # Error code for unexpected error

    #         # Verify error handler was called
            mock_error_handler_instance.handle_cli_error.assert_called_once()


class TestCLICommand(unittest.TestCase)
    #     """Test cases for the CLICommand enum."""

    #     def test_command_values(self):""Test that command values are correct."""
            self.assertEqual(CLICommand.VALIDATE.value, "validate")
            self.assertEqual(CLICommand.AI_CHECK.value, "ai-check")
            self.assertEqual(CLICommand.RUN.value, "run")
            self.assertEqual(CLICommand.CONVERT.value, "convert")
            self.assertEqual(CLICommand.STRICT_MODE.value, "strict-mode")


class TestOutputFormatter(unittest.TestCase)
    #     """Test cases for the OutputFormatter class."""

    #     def setUp(self):""Set up test fixtures."""
    self.formatter = OutputFormatter(enable_colors=False)

    #     def test_format_validation_result_valid(self):
    #         """Test formatting a valid validation result."""
    result = {
    #             "file": "test.nc",
    #             "valid": True,
    #             "results": {
    #                 "syntax": {"valid": True, "errors": []},
    #                 "semantic": {"valid": True, "errors": [], "warnings": []}
    #             }
    #         }

    #         # Capture output
    #         with patch('builtins.print') as mock_print:
                self.formatter.format_validation_result(result)

    #             # Verify print was called with expected content
    #             calls = [str(call) for call in mock_print.call_args_list]
    output = ' '.join(calls)
                self.assertIn("✓", output)
                self.assertIn("test.nc", output)

    #     def test_format_validation_result_invalid(self):
    #         """Test formatting an invalid validation result."""
    result = {
    #             "file": "test.nc",
    #             "valid": False,
    #             "results": {
    #                 "syntax": {"valid": False, "errors": ["Syntax error at line 1"]},
    #                 "semantic": {"valid": True, "errors": [], "warnings": ["Warning: unused variable"]}
    #             }
    #         }

    #         # Capture output
    #         with patch('builtins.print') as mock_print:
                self.formatter.format_validation_result(result)

    #             # Verify print was called with expected content
    #             calls = [str(call) for call in mock_print.call_args_list]
    output = ' '.join(calls)
                self.assertIn("✗", output)
                self.assertIn("test.nc", output)
                self.assertIn("Syntax error at line 1", output)
                self.assertIn("Warning: unused variable", output)

    #     def test_format_ai_guard_result_allowed(self):
    #         """Test formatting an AI guard result with allowed action."""
    result = {
    #             "file": "test.nc",
    #             "source": "test-ai",
    #             "valid": True,
    #             "result": {
    #                 "action": "ALLOW",
    #                 "reason": "Code is safe",
    #                 "issues": []
    #             }
    #         }

    #         # Capture output
    #         with patch('builtins.print') as mock_print:
                self.formatter.format_ai_guard_result(result)

    #             # Verify print was called with expected content
    #             calls = [str(call) for call in mock_print.call_args_list]
    output = ' '.join(calls)
                self.assertIn("✓", output)
                self.assertIn("test.nc", output)
                self.assertIn("ALLOW", output)
                self.assertIn("Code is safe", output)

    #     def test_format_ai_guard_result_blocked(self):
    #         """Test formatting an AI guard result with blocked action."""
    result = {
    #             "file": "test.nc",
    #             "source": "test-ai",
    #             "valid": False,
    #             "result": {
    #                 "action": "BLOCK",
    #                 "reason": "Code contains unsafe constructs",
                    "issues": ["Use of eval() function"]
    #             }
    #         }

    #         # Capture output
    #         with patch('builtins.print') as mock_print:
                self.formatter.format_ai_guard_result(result)

    #             # Verify print was called with expected content
    #             calls = [str(call) for call in mock_print.call_args_list]
    output = ' '.join(calls)
                self.assertIn("✗", output)
                self.assertIn("test.nc", output)
                self.assertIn("BLOCK", output)
                self.assertIn("Code contains unsafe constructs", output)
                self.assertIn("Use of eval() function", output)


if __name__ == '__main__'
        unittest.main()