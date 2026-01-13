# Converted from Python to NoodleCore
# Original file: src

# """
# Unit tests for Native CLI

# This module contains comprehensive unit tests for the native CLI component,
# testing command execution, error handling, argument parsing, and performance.
# """

import pytest
import sys
import os
import uuid
import argparse
import unittest.mock.Mock
import pathlib.Path

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import noodlecore.cli.native_cli.(
#     NativeNoodleCLI,
#     NativeCLIError,
#     main,
#     ERROR_CODE_SUCCESS,
#     ERROR_CODE_GENERAL_ERROR,
#     ERROR_CODE_FILE_NOT_FOUND,
#     ERROR_CODE_COMPILATION_ERROR,
#     ERROR_CODE_EXECUTION_ERROR,
#     ERROR_CODE_INVALID_ARGUMENT
# )


class TestNativeCLIError
    #     """Test the NativeCLIError class."""

    #     def test_native_cli_error_initialization(self):""Test that NativeCLIError initializes correctly."""
    error = NativeCLIError("Test error", 1001)
    assert str(error) = = "Test error"
    assert error.error_code = 1001

    #     def test_native_cli_error_default_code(self):
    #         """Test that NativeCLIError uses default error code."""
    error = NativeCLIError("Test error")
    assert str(error) = = "Test error"
    assert error.error_code == ERROR_CODE_GENERAL_ERROR


class TestNativeNoodleCLI
    #     """Test the NativeNoodleCLI class."""

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_cli_initialization(self, mock_logging, mock_runtime):""Test that CLI initializes correctly."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    assert cli.runtime == mock_runtime_instance
    #         assert cli.request_id is None
    #         assert cli.verbose is False
    #         assert cli.debug is False
    assert cli.output_format = = "text"
            assert isinstance(cli.config, dict)

    mock_runtime.assert_called_once_with(debug = False)
            mock_logging.assert_called_once()

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_cli_initialization_with_debug(self, mock_logging, mock_runtime):
    #         """Test that CLI initializes with debug mode."""
    #         with patch.dict(os.environ, {'NOODLE_DEBUG': '1'}):
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #             assert cli.debug is True
    mock_runtime.assert_called_once_with(debug = True)

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_cli_initialization_failure(self, mock_logging, mock_runtime):
    #         """Test that CLI handles initialization failure."""
    mock_runtime.side_effect = Exception("Runtime initialization failed")

    #         with pytest.raises(NativeCLIError) as exc_info:
                NativeNoodleCLI()

            assert "Failed to initialize native NoodleCore runtime" in str(exc_info.value)
    assert exc_info.value.error_code == ERROR_CODE_GENERAL_ERROR

    #     def test_generate_request_id(self):
    #         """Test request ID generation."""
    cli = NativeNoodleCLI()

    #         # Mock runtime to avoid initialization
    cli.runtime = Mock()

    request_id = cli._generate_request_id()
            assert isinstance(request_id, str)

    #         # Should generate the same ID on subsequent calls
    same_request_id = cli._generate_request_id()
    assert request_id == same_request_id

    #         # Should be a valid UUID
    #         uuid.UUID(request_id)  # Will raise ValueError if not valid

    #     def test_format_output_text(self):
    #         """Test text output formatting."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()

    #         # Test dict with status
    data = {"status": "success", "message": "Operation completed"}
    result = cli._format_output(data, "text")
    assert result = = "Operation completed"

    #         # Test dict with error
    data = {"status": "error", "error": "Something went wrong"}
    result = cli._format_output(data, "text")
    assert result = = "Error: Something went wrong"

    #         # Test string
    data = "Simple string"
    result = cli._format_output(data, "text")
    assert result = = "Simple string"

    #     def test_format_output_json(self):
    #         """Test JSON output formatting."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()

    data = {"status": "success", "message": "Operation completed"}
    result = cli._format_output(data, "json")

    #         import json
    parsed = json.loads(result)
    assert parsed["status"] = = "success"
    assert parsed["message"] = = "Operation completed"

    #     def test_format_output_yaml(self):
    #         """Test YAML output formatting."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()

    data = {"status": "success", "message": "Operation completed"}

    #         with patch('yaml.dump', return_value="status: success\nmessage: Operation completed\n") as mock_yaml:
    result = cli._format_output(data, "yaml")
    assert result = = "status: success\nmessage: Operation completed\n"
                mock_yaml.assert_called_once()

    #     def test_format_output_yaml_fallback(self):
    #         """Test YAML output formatting falls back to JSON."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()

    data = {"status": "success", "message": "Operation completed"}

    #         with patch('yaml.dump', side_effect=ImportError("No module named 'yaml'")):
    result = cli._format_output(data, "yaml")

    #             import json
    parsed = json.loads(result)
    assert parsed["status"] = = "success"

    #     def test_handle_error_native_cli_error(self):
    #         """Test error handling for NativeCLIError."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()
    cli.debug = False

    error = NativeCLIError("Test error", 1001)
    result = cli._handle_error(error, "Test context")

    assert result = 1001

    #     def test_handle_error_runtime_error(self):
    #         """Test error handling for NoodleRuntimeError."""
    #         from noodlecore.runtime.native import NoodleRuntimeError

    cli = NativeNoodleCLI()
    cli.runtime = Mock()
    cli.debug = False

    error = NoodleRuntimeError("Runtime error")
    result = cli._handle_error(error, "Test context")

    assert result == ERROR_CODE_EXECUTION_ERROR

    #     def test_handle_error_general_error(self):
    #         """Test error handling for general exceptions."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()
    cli.debug = False

    error = Exception("General error")
    result = cli._handle_error(error, "Test context")

    assert result == ERROR_CODE_GENERAL_ERROR

    #     def test_handle_error_with_debug(self):
    #         """Test error handling with debug mode."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()
    cli.debug = True

    error = Exception("Test error")
    #         with patch('traceback.format_exc', return_value="Traceback"):
    result = cli._handle_error(error, "Test context")

    assert result == ERROR_CODE_GENERAL_ERROR

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_run_command_with_file(self, mock_logging, mock_runtime):
    #         """Test run command with file argument."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_file.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

    #         # Create a mock file path
    #         with patch('pathlib.Path.exists', return_value=True):
    args = argparse.Namespace(file="test.noodle", code=None)
    result = cli.run_command(args)

    assert result == ERROR_CODE_SUCCESS
            mock_runtime_instance.run_file.assert_called_once_with("test.noodle")

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_run_command_with_code(self, mock_logging, mock_runtime):
    #         """Test run command with code argument."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

    args = argparse.Namespace(file=None, code="print('Hello, World!')")
    result = cli.run_command(args)

    assert result == ERROR_CODE_SUCCESS
            mock_runtime_instance.run_source.assert_called_once_with("print('Hello, World!')")

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_run_command_file_not_found(self, mock_logging, mock_runtime):
    #         """Test run command with file not found."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch('pathlib.Path.exists', return_value=False):
    args = argparse.Namespace(file="missing.noodle", code=None)
    result = cli.run_command(args)

    assert result == ERROR_CODE_FILE_NOT_FOUND

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_run_command_with_exception(self, mock_logging, mock_runtime):
    #         """Test run command with exception."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.side_effect = Exception("Runtime error")

    cli = NativeNoodleCLI()

    args = argparse.Namespace(file=None, code="print('Hello, World!')")
    result = cli.run_command(args)

    assert result == ERROR_CODE_EXECUTION_ERROR

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_build_command(self, mock_logging, mock_runtime):
    #         """Test build command."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch('pathlib.Path.exists', return_value=True):
    args = argparse.Namespace(source="test.noodle", output=None)
    result = cli.build_command(args)

    assert result == ERROR_CODE_SUCCESS
            mock_runtime_instance.compile_to_bytecode.assert_called_once()

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_build_command_with_custom_output(self, mock_logging, mock_runtime):
    #         """Test build command with custom output file."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch('pathlib.Path.exists', return_value=True):
    args = argparse.Namespace(source="test.noodle", output="custom.nbc")
    result = cli.build_command(args)

    assert result == ERROR_CODE_SUCCESS
            mock_runtime_instance.compile_to_bytecode.assert_called_once_with("test.noodle", "custom.nbc")

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_build_command_source_not_found(self, mock_logging, mock_runtime):
    #         """Test build command with source file not found."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch('pathlib.Path.exists', return_value=False):
    args = argparse.Namespace(source="missing.noodle", output=None)
    result = cli.build_command(args)

    assert result == ERROR_CODE_FILE_NOT_FOUND

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_execute_command(self, mock_logging, mock_runtime):
    #         """Test execute command."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.load_bytecode.return_value = {"bytecode": "test"}
    mock_runtime_instance.execute_bytecode.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

    #         with patch('pathlib.Path.exists', return_value=True):
    args = argparse.Namespace(bytecode="test.nbc", function="main")
    result = cli.execute_command(args)

    assert result == ERROR_CODE_SUCCESS
            mock_runtime_instance.load_bytecode.assert_called_once_with("test.nbc")
            mock_runtime_instance.execute_bytecode.assert_called_once_with({"bytecode": "test"}, "main")

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_execute_command_bytecode_not_found(self, mock_logging, mock_runtime):
    #         """Test execute command with bytecode file not found."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch('pathlib.Path.exists', return_value=False):
    args = argparse.Namespace(bytecode="missing.nbc", function="main")
    result = cli.execute_command(args)

    assert result == ERROR_CODE_FILE_NOT_FOUND

    #     def test_create_parser(self):
    #         """Test argument parser creation."""
    cli = NativeNoodleCLI()
    cli.runtime = Mock()

    parser = cli.create_parser()
            assert isinstance(parser, argparse.ArgumentParser)

    #         # Test parsing run command
    args = parser.parse_args(['run', '--file', 'test.noodle'])
    assert args.command = = 'run'
    assert args.file = = 'test.noodle'

    #         # Test parsing build command
    args = parser.parse_args(['build', 'test.noodle', '--output', 'test.nbc'])
    assert args.command = = 'build'
    assert args.source = = 'test.noodle'
    assert args.output = = 'test.nbc'

    #         # Test parsing execute command
    args = parser.parse_args(['execute', 'test.nbc', '--function', 'main'])
    assert args.command = = 'execute'
    assert args.bytecode = = 'test.nbc'
    assert args.function = = 'main'

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_main_run_command(self, mock_logging, mock_runtime):
    #         """Test main entry point with run command."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

    args = ['run', 'print("Hello, World!")']
    result = cli.main(args)

    assert result == ERROR_CODE_SUCCESS

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_main_no_command(self, mock_logging, mock_runtime):
    #         """Test main entry point with no command."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch('argparse.ArgumentParser.print_help'):
    result = cli.main([])

    assert result == ERROR_CODE_INVALID_ARGUMENT

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_main_keyboard_interrupt(self, mock_logging, mock_runtime):
    #         """Test main entry point with keyboard interrupt."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         with patch.object(cli, 'run_command', side_effect=KeyboardInterrupt()):
    result = cli.main(['run', 'print("Hello, World!")'])

    assert result == ERROR_CODE_GENERAL_ERROR

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_main_verbose_mode(self, mock_logging, mock_runtime):
    #         """Test main entry point with verbose mode."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

    args = ['--verbose', 'run', 'print("Hello, World!")']
    result = cli.main(args)

    assert result == ERROR_CODE_SUCCESS
    #         assert cli.verbose is True

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_main_debug_mode(self, mock_logging, mock_runtime):
    #         """Test main entry point with debug mode."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

    args = ['--debug', 'run', 'print("Hello, World!")']
    result = cli.main(args)

    assert result == ERROR_CODE_SUCCESS
    #         assert cli.debug is True


class TestMainFunction
    #     """Test the main function."""

        patch('noodlecore.cli.native_cli.NativeNoodleCLI')
    #     def test_main_function(self, mock_cli_class):""Test the main function."""
    mock_cli = Mock()
    mock_cli.main.return_value = 0
    mock_cli_class.return_value = mock_cli

    #         with patch('sys.exit') as mock_exit:
                main()
                mock_exit.assert_called_once_with(0)

        patch('noodlecore.cli.native_cli.NativeNoodleCLI')
    #     def test_main_function_with_args(self, mock_cli_class):
    #         """Test the main function with arguments."""
    mock_cli = Mock()
    mock_cli.main.return_value = 1
    mock_cli_class.return_value = mock_cli

    #         with patch('sys.exit') as mock_exit:
                main(['run', 'test.noodle'])
                mock_cli.main.assert_called_once_with(['run', 'test.noodle'])
                mock_exit.assert_called_once_with(1)


class TestNativeCLIPerformance
    #     """Test performance characteristics of native CLI."""

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_command_execution_performance(self, mock_logging, mock_runtime, performance_monitor):""Test that command execution is performant."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()

            performance_monitor.start_timing("run_command")
    args = argparse.Namespace(file=None, code="print('Hello, World!')")
    result = cli.run_command(args)
    duration = performance_monitor.end_timing("run_command")

    assert result == ERROR_CODE_SUCCESS
    #         assert duration < 1.0  # Should complete within 1 second

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_memory_usage(self, mock_logging, mock_runtime, performance_monitor):
    #         """Test that CLI doesn't use excessive memory."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

            performance_monitor.start_timing("cli_initialization")
    #         # CLI is already initialized
            performance_monitor.end_timing("cli_initialization")

            performance_monitor.assert_memory_usage(50)  # Should use less than 50MB


class TestNativeCLIErrorCodes
    #     """Test that all error codes are properly used."""

    #     def test_all_error_codes_defined(self):""Test that all error codes are defined and unique."""
    error_codes = [
    #             ERROR_CODE_SUCCESS,
    #             ERROR_CODE_GENERAL_ERROR,
    #             ERROR_CODE_FILE_NOT_FOUND,
    #             ERROR_CODE_COMPILATION_ERROR,
    #             ERROR_CODE_EXECUTION_ERROR,
    #             ERROR_CODE_INVALID_ARGUMENT
    #         ]

    #         # All error codes should be integers
    #         assert all(isinstance(code, int) for code in error_codes)

    #         # All error codes should be unique
    assert len(error_codes) = = len(set(error_codes))

    #         # Success code should be 0
    assert ERROR_CODE_SUCCESS = 0

    #         # Error codes should be positive
    #         assert all(code 0 for code in error_codes[1):])

        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     def test_error_code_propagation(self, mock_logging, mock_runtime):
    #         """Test that error codes are properly propagated."""
    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance

    cli = NativeNoodleCLI()

    #         # Test file not found error
    #         with patch('pathlib.Path.exists', return_value=False):
    args = argparse.Namespace(file="missing.noodle", code=None)
    result = cli.run_command(args)
    assert result == ERROR_CODE_FILE_NOT_FOUND

    #         # Test invalid argument error
    #         with patch('argparse.ArgumentParser.print_help'):
    result = cli.main([])
    assert result == ERROR_CODE_INVALID_ARGUMENT


class TestNativeCLIAsyncPatterns
    #     """Test async patterns in native CLI."""

    #     @pytest.mark.asyncio
        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     async def test_async_command_execution(self, mock_logging, mock_runtime):""Test that commands can be executed asynchronously."""
    #         import asyncio

    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()
    args = argparse.Namespace(file=None, code="print('Hello, World!')")

    #         # Execute command in async context
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(None, cli.run_command, args)

    assert result == ERROR_CODE_SUCCESS

    #     @pytest.mark.asyncio
        patch('noodlecore.cli.native_cli.NoodleRuntime')
        patch('noodlecore.cli.native_cli.initialize_logging')
    #     async def test_concurrent_command_execution(self, mock_logging, mock_runtime):
    #         """Test that multiple commands can be executed concurrently."""
    #         import asyncio

    mock_runtime_instance = Mock()
    mock_runtime.return_value = mock_runtime_instance
    mock_runtime_instance.run_source.return_value = {
    #             'output': ['Hello, World!'],
    #             'execution_time': 0.1,
    #             'instruction_count': 10
    #         }

    cli = NativeNoodleCLI()
    args = argparse.Namespace(file=None, code="print('Hello, World!')")

    #         # Execute multiple commands concurrently
    loop = asyncio.get_event_loop()
    tasks = [
                loop.run_in_executor(None, cli.run_command, args)
    #             for _ in range(5)
    #         ]

    results = await asyncio.gather( * tasks)

    #         # All commands should succeed
    #         assert all(result == ERROR_CODE_SUCCESS for result in results)