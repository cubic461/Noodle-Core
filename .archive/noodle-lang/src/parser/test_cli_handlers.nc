# Converted from Python to NoodleCore
# Original file: src

# """
# Unit tests for CLI Command Handlers

# This module contains comprehensive unit tests for the CLI command handler system,
# testing command registration, execution, context management, and error handling.
# """

import pytest
import sys
import os
import time
import argparse
import unittest.mock.Mock
import typing.Dict

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import noodlecore.cli.command_handlers.(
#     CommandContext,
#     CommandHandler,
#     CommandRegistry,
#     register_command,
#     get_command_handler,
#     command_registry
# )

# Mock CLICommand enum for testing
class MockCLICommand
    #     """Mock CLICommand enum for testing."""
    RUN = "run"
    BUILD = "build"
    TEST = "test"
    INFO = "info"


class TestCommandContext
    #     """Test the CommandContext class."""

    #     def test_command_context_initialization(self):""Test that CommandContext initializes correctly."""
    command = MockCLICommand.RUN
    args = argparse.Namespace(file="test.noodle", verbose=True)
    request_id = "test-request-id"
    start_time = time.time()
    metadata = {"user": "test"}

    context = CommandContext(
    command = command,
    args = args,
    request_id = request_id,
    start_time = start_time,
    metadata = metadata
    #         )

    assert context.command == command
    assert context.args == args
    assert context.request_id == request_id
    assert context.start_time == start_time
    assert context.metadata == metadata

    #     def test_command_context_without_metadata(self):
    #         """Test that CommandContext initializes without metadata."""
    command = MockCLICommand.RUN
    args = argparse.Namespace(file="test.noodle")
    request_id = "test-request-id"
    start_time = time.time()

    context = CommandContext(
    command = command,
    args = args,
    request_id = request_id,
    start_time = start_time
    #         )

    assert context.command == command
    assert context.args == args
    assert context.request_id == request_id
    assert context.start_time == start_time
    #         assert context.metadata is None


class TestCommandHandler
    #     """Test the CommandHandler class."""

    #     @pytest.mark.asyncio
    #     async def test_command_handler_initialization(self):""Test that CommandHandler initializes correctly."""
    command = MockCLICommand.RUN
    handler = AsyncMock()

    command_handler = CommandHandler(command, handler)

    assert command_handler.command == command
    assert command_handler.handler == handler

    #     @pytest.mark.asyncio
    #     async def test_command_handler_execute_success(self):
    #         """Test successful command handler execution."""
    command = MockCLICommand.RUN
    handler = AsyncMock(return_value={"success": True, "result": "test"})

    command_handler = CommandHandler(command, handler)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(file="test.noodle"),
    request_id = "test-request-id",
    start_time = time.time()
    #         )

    result = await command_handler.execute(context)

    #         assert result["success"] is True
    assert result["result"] = = "test"
            handler.assert_called_once_with(context)

    #     @pytest.mark.asyncio
    #     async def test_command_handler_execute_failure(self):
    #         """Test command handler execution with failure."""
    command = MockCLICommand.RUN
    handler = AsyncMock(side_effect=Exception("Test error"))

    command_handler = CommandHandler(command, handler)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(file="test.noodle"),
    request_id = "test-request-id",
    start_time = time.time()
    #         )

    result = await command_handler.execute(context)

    #         assert result["success"] is False
    assert result["error"] = = "Test error"
    assert result["command"] = = command
    assert result["request_id"] = = "test-request-id"
    #         assert "duration" in result

    #     @pytest.mark.asyncio
    #     async def test_command_handler_execute_with_duration(self):
    #         """Test that command handler calculates execution duration."""
    command = MockCLICommand.RUN
    handler = AsyncMock(return_value={"success": True})

    command_handler = CommandHandler(command, handler)

    start_time = time.time()
    context = CommandContext(
    command = command,
    args = argparse.Namespace(file="test.noodle"),
    request_id = "test-request-id",
    start_time = start_time
    #         )

    #         # Add a small delay to ensure measurable duration
    #         import asyncio
            await asyncio.sleep(0.01)

    result = await command_handler.execute(context)

    #         assert result["success"] is True
    #         assert result["duration"] 0
    assert result["duration"] > = 0.01  # Should be at least our sleep time


class TestCommandRegistry
    #     """Test the CommandRegistry class."""

    #     def test_command_registry_initialization(self)):
    #         """Test that CommandRegistry initializes correctly."""
    registry = CommandRegistry()

            assert isinstance(registry._handlers, dict)
    assert len(registry._handlers) = = 0

    #     def test_command_registry_register(self):
    #         """Test command registration."""
    registry = CommandRegistry()
    command = MockCLICommand.RUN
    handler = Mock()

            registry.register(command, handler)

    #         assert command in registry._handlers
    assert registry._handlers[command] = = handler

    #     def test_command_registry_get_handler(self):
    #         """Test getting a registered handler."""
    registry = CommandRegistry()
    command = MockCLICommand.RUN
    handler = Mock()

            registry.register(command, handler)
    retrieved_handler = registry.get_handler(command)

    assert retrieved_handler == handler

    #     def test_command_registry_get_nonexistent_handler(self):
    #         """Test getting a non-existent handler."""
    registry = CommandRegistry()

    handler = registry.get_handler(MockCLICommand.RUN)
    #         assert handler is None

    #     def test_command_registry_list_commands(self):
    #         """Test listing all registered commands."""
    registry = CommandRegistry()

    #         # Register multiple commands
            registry.register(MockCLICommand.RUN, Mock())
            registry.register(MockCLICommand.BUILD, Mock())
            registry.register(MockCLICommand.TEST, Mock())

    commands = registry.list_commands()

    assert len(commands) = = 3
    #         assert MockCLICommand.RUN in commands
    #         assert MockCLICommand.BUILD in commands
    #         assert MockCLICommand.TEST in commands

    #     def test_command_registry_has_command(self):
    #         """Test checking if a command is registered."""
    registry = CommandRegistry()
    command = MockCLICommand.RUN
    handler = Mock()

    #         # Before registration
            assert registry.has_command(command) is False

    #         # After registration
            registry.register(command, handler)
            assert registry.has_command(command) is True

    #     def test_command_registry_overwrite_handler(self):
    #         """Test overwriting an existing handler."""
    registry = CommandRegistry()
    command = MockCLICommand.RUN
    handler1 = Mock()
    handler2 = Mock()

    #         # Register first handler
            registry.register(command, handler1)
    assert registry.get_handler(command) = = handler1

            # Register second handler (overwrite)
            registry.register(command, handler2)
    assert registry.get_handler(command) = = handler2


class TestGlobalRegistryFunctions
    #     """Test global registry functions."""

    #     def test_register_command_global(self):""Test registering a command with the global registry."""
    command = MockCLICommand.RUN
    handler = Mock()

    #         # Clear the global registry
            command_registry._handlers.clear()

            register_command(command, handler)

    #         assert command in command_registry._handlers
    assert command_registry._handlers[command].command == command
    assert command_registry._handlers[command].handler == handler

    #     def test_get_command_handler_global(self):
    #         """Test getting a command handler from the global registry."""
    command = MockCLICommand.RUN
    handler = Mock()

    #         # Clear and set up the global registry
            command_registry._handlers.clear()
            register_command(command, handler)

    retrieved_handler = get_command_handler(command)

    #         assert retrieved_handler is not None
    assert retrieved_handler.command == command
    assert retrieved_handler.handler == handler

    #     def test_get_command_handler_global_nonexistent(self):
    #         """Test getting a non-existent command handler from the global registry."""
    #         # Clear the global registry
            command_registry._handlers.clear()

    handler = get_command_handler(MockCLICommand.RUN)
    #         assert handler is None


class TestCommandHandlerIntegration
    #     """Test integration scenarios for command handlers."""

    #     @pytest.mark.asyncio
    #     async def test_multiple_command_execution(self):""Test executing multiple commands through handlers."""
    registry = CommandRegistry()

    #         # Register multiple commands
    run_handler = AsyncMock(return_value={"success": True, "output": "Run executed"})
    build_handler = AsyncMock(return_value={"success": True, "output": "Build executed"})
    test_handler = AsyncMock(return_value={"success": True, "output": "Test executed"})

            registry.register(MockCLICommand.RUN, CommandHandler(MockCLICommand.RUN, run_handler))
            registry.register(MockCLICommand.BUILD, CommandHandler(MockCLICommand.BUILD, build_handler))
            registry.register(MockCLICommand.TEST, CommandHandler(MockCLICommand.TEST, test_handler))

    #         # Execute all commands
    commands = [MockCLICommand.RUN, MockCLICommand.BUILD, MockCLICommand.TEST]
    results = []

    #         for command in commands:
    handler = registry.get_handler(command)
    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = f"test-{command}",
    start_time = time.time()
    #             )
    result = await handler.execute(context)
                results.append(result)

    #         # All commands should succeed
    #         assert all(result["success"] for result in results)
    assert results[0]["output"] = = "Run executed"
    assert results[1]["output"] = = "Build executed"
    assert results[2]["output"] = = "Test executed"

    #     @pytest.mark.asyncio
    #     async def test_command_handler_with_complex_context(self):
    #         """Test command handler with complex context data."""
    command = MockCLICommand.RUN
    handler = AsyncMock(return_value={"success": True, "processed": True})

    command_handler = CommandHandler(command, handler)

    #         # Create complex context
    args = argparse.Namespace(
    file = "test.noodle",
    verbose = True,
    output = "test.out",
    options = {"opt1": "value1", "opt2": "value2"}
    #         )

    metadata = {
    #             "user": "test_user",
    #             "session": "test_session",
    #             "permissions": ["read", "write"],
    #             "environment": "development"
    #         }

    context = CommandContext(
    command = command,
    args = args,
    request_id = "complex-request-id",
    start_time = time.time(),
    metadata = metadata
    #         )

    result = await command_handler.execute(context)

    #         assert result["success"] is True
            handler.assert_called_once_with(context)

    #         # Verify the context was passed correctly
    call_context = handler.call_args[0][0]
    assert call_context.args == args
    assert call_context.metadata == metadata
    assert call_context.request_id = = "complex-request-id"

    #     @pytest.mark.asyncio
    #     async def test_command_handler_error_propagation(self):
    #         """Test that errors are properly propagated through handlers."""
    command = MockCLICommand.RUN

    #         # Test different types of errors
    errors = [
                ValueError("Invalid value"),
                RuntimeError("Runtime error"),
                ConnectionError("Connection failed"),
                Exception("Generic error")
    #         ]

    #         for error in errors:
    handler = AsyncMock(side_effect=error)
    command_handler = CommandHandler(command, handler)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = "error-test-id",
    start_time = time.time()
    #             )

    result = await command_handler.execute(context)

    #             assert result["success"] is False
    assert result["error"] = = str(error)
    assert result["command"] = = command
    assert result["request_id"] = = "error-test-id"
    #             assert "duration" in result


class TestCommandHandlerPerformance
    #     """Test performance characteristics of command handlers."""

    #     @pytest.mark.asyncio
    #     async def test_handler_execution_performance(self, performance_monitor):""Test that handler execution is performant."""
    command = MockCLICommand.RUN
    handler = AsyncMock(return_value={"success": True})

    command_handler = CommandHandler(command, handler)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = "performance-test-id",
    start_time = time.time()
    #         )

            performance_monitor.start_timing("handler_execution")
    result = await command_handler.execute(context)
    duration = performance_monitor.end_timing("handler_execution")

    #         assert result["success"] is True
    #         assert duration < 0.1  # Should complete within 100ms

    #     @pytest.mark.asyncio
    #     async def test_registry_performance(self, performance_monitor):
    #         """Test that registry operations are performant."""
    registry = CommandRegistry()

    #         # Test registration performance
            performance_monitor.start_timing("registry_registration")
    #         for i in range(100):
    command = f"command_{i}"
    handler = Mock()
                registry.register(command, handler)
    duration = performance_monitor.end_timing("registry_registration")

    #         assert duration < 0.1  # Should complete within 100ms
    assert len(registry._handlers) = = 100

    #         # Test lookup performance
            performance_monitor.start_timing("registry_lookup")
    #         for i in range(100):
    command = f"command_{i}"
    handler = registry.get_handler(command)
    #             assert handler is not None
    duration = performance_monitor.end_timing("registry_lookup")

    #         assert duration < 0.1  # Should complete within 100ms


class TestCommandHandlerErrorCodes
    #     """Test error code handling in command handlers."""

    #     @pytest.mark.asyncio
    #     async def test_error_code_in_result(self):""Test that error codes are included in error results."""
    command = MockCLICommand.RUN

    #         # Create a custom error with error code
    #         class CustomError(Exception):
    #             def __init__(self, message, error_code):
                    super().__init__(message)
    self.error_code = error_code

    handler = AsyncMock(side_effect=CustomError("Test error", 1001))
    command_handler = CommandHandler(command, handler)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = "error-code-test-id",
    start_time = time.time()
    #         )

    result = await command_handler.execute(context)

    #         assert result["success"] is False
    assert result["error"] = = "Test error"
    #         # Note: The current implementation doesn't extract error_code from exceptions
    #         # This test documents the current behavior and could be enhanced

    #     @pytest.mark.asyncio
    #     async def test_handler_with_error_codes(self):
    #         """Test handlers that return error codes in their results."""
    command = MockCLICommand.RUN

    #         # Handler that returns error code
    handler = AsyncMock(return_value={
    #             "success": False,
    #             "error_code": 1001,
    #             "error_message": "Custom error"
    #         })

    command_handler = CommandHandler(command, handler)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = "handler-error-code-test-id",
    start_time = time.time()
    #         )

    result = await command_handler.execute(context)

    #         # The handler's result should be passed through
    #         assert result["success"] is False
    assert result["error_code"] = = 1001
    assert result["error_message"] = = "Custom error"


class TestCommandHandlerAsyncPatterns
    #     """Test async patterns in command handlers."""

    #     @pytest.mark.asyncio
    #     async def test_concurrent_handler_execution(self):""Test that multiple handlers can execute concurrently."""
    #         import asyncio

    registry = CommandRegistry()

    #         # Create handlers that simulate work
    #         async def create_handler(delay):
    #             async def handler(context):
                    await asyncio.sleep(delay)
    #                 return {"success": True, "delay": delay}
    #             return handler

    #         # Register handlers with different delays
            registry.register(MockCLICommand.RUN, CommandHandler(MockCLICommand.RUN, await create_handler(0.05)))
            registry.register(MockCLICommand.BUILD, CommandHandler(MockCLICommand.BUILD, await create_handler(0.03)))
            registry.register(MockCLICommand.TEST, CommandHandler(MockCLICommand.TEST, await create_handler(0.04)))

    #         # Execute all handlers concurrently
    commands = [MockCLICommand.RUN, MockCLICommand.BUILD, MockCLICommand.TEST]
    tasks = []

    #         for command in commands:
    handler = registry.get_handler(command)
    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = f"concurrent-{command}",
    start_time = time.time()
    #             )
                tasks.append(handler.execute(context))

    start_time = time.time()
    results = await asyncio.gather( * tasks)
    end_time = time.time()

    #         # All commands should succeed
    #         assert all(result["success"] for result in results)

    #         # Total time should be less than sum of individual delays
    total_time = end_time - start_time
    #         assert total_time < 0.12  # Should be less than 0.05 + 0.03 + 0.04

    #     @pytest.mark.asyncio
    #     async def test_handler_with_async_dependencies(self):
    #         """Test handlers that depend on async operations."""
    command = MockCLICommand.RUN

    #         # Create a handler that depends on async operations
    #         async def async_dependency():
                await asyncio.sleep(0.01)
    #             return "dependency_result"

    #         async def handler_with_dependency(context):
    dependency_result = await async_dependency()
    #             return {"success": True, "dependency": dependency_result}

    command_handler = CommandHandler(command, handler_with_dependency)

    context = CommandContext(
    command = command,
    args = argparse.Namespace(),
    request_id = "async-dependency-test-id",
    start_time = time.time()
    #         )

    result = await command_handler.execute(context)

    #         assert result["success"] is True
    assert result["dependency"] = = "dependency_result"