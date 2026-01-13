# Converted from Python to NoodleCore
# Original file: src

# """
# Command Router Module

# This module implements a centralized command router for the NoodleCore CLI system.
# It handles command validation, routing, middleware, and performance monitoring.
# """

import asyncio
import logging
import time
import uuid
import typing.Dict
from functools import wraps

import .exceptions.(
#     CommandNotFoundError,
#     InvalidArgumentError,
#     TimeoutError,
#     NoodleCliException
# )
import .cli_config.get_cli_config

logger = logging.getLogger(__name__)


class CommandMiddleware
    #     """Base class for command middleware."""

    #     async def before_execute(self, command_name: str, args) -Any):
    #         """
    #         Execute before command execution.

    #         Args:
    #             command_name: Name of the command
                args: Command arguments (dict or Namespace)

    #         Returns:
    #             Modified arguments
    #         """
    #         return args

    #     async def after_execute(self, command_name: str, args, result: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Execute after command execution.

    #         Args:
    #             command_name: Name of the command
                args: Command arguments (dict or Namespace)
    #             result: Command result

    #         Returns:
    #             Modified result
    #         """
    #         return result

    #     async def on_error(self, command_name: str, args, error: Exception) -Optional[Dict[str, Any]]):
    #         """
    #         Execute when command execution fails.

    #         Args:
    #             command_name: Name of the command
                args: Command arguments (dict or Namespace)
    #             error: Exception that occurred

    #         Returns:
    #             Optional error result
    #         """
    #         return None


class LoggingMiddleware(CommandMiddleware)
    #     """Middleware for logging command execution."""

    #     async def before_execute(self, command_name: str, args) -Any):
    #         """Log command start."""
    #         # Convert args to dict for logging
    #         args_dict = vars(args) if hasattr(args, '__dict__') else args
    logger.info(f"Executing command: {command_name}", extra = {'command_args': args_dict})
    #         return args

    #     async def after_execute(self, command_name: str, args, result: Dict[str, Any]) -Dict[str, Any]):
    #         """Log command completion."""
    logger.info(f"Command completed: {command_name}", extra = {'command_result': result})
    #         return result

    #     async def on_error(self, command_name: str, args, error: Exception) -Optional[Dict[str, Any]]):
    #         """Log command error."""
    #         # Convert args to dict for logging
    #         args_dict = vars(args) if hasattr(args, '__dict__') else args
    logger.error(f"Command failed: {command_name}", extra = {'error': str(error), 'command_args': args_dict})
    #         return None


class AuthenticationMiddleware(CommandMiddleware)
    #     """Middleware for authentication and authorization."""

    #     def __init__(self):
    self.config = get_cli_config()

    #     async def before_execute(self, command_name: str, args) -Any):
    #         """Check authentication before command execution."""
    #         # Skip authentication for certain commands
    public_commands = ['help', 'version', 'config', 'logs']
    #         if command_name in public_commands:
    #             return args

    #         # Check for API key or authentication token
    api_key = self.config.get('NOODLE_API_KEY')
    #         if not api_key:
    #             from .exceptions import AuthenticationError
    #             raise AuthenticationError("API key required for this command")

    #         # Add authentication info to args
    #         if hasattr(args, '__dict__'):
    #             # Namespace object
                setattr(args, 'authenticated', True)
                setattr(args, 'api_key', api_key)
    #         else:
    #             # Dict object
    args['authenticated'] = True
    args['api_key'] = api_key

    #         return args


class ValidationMiddleware(CommandMiddleware)
    #     """Middleware for command validation."""

    #     async def before_execute(self, command_name: str, args) -Any):
    #         """Validate command arguments."""
    #         # Helper function to get attribute from both dict and Namespace
    #         def get_attr(obj, key, default=None):
    #             if hasattr(obj, '__dict__'):
                    return getattr(obj, key, default)
    #             else:
                    return obj.get(key, default)

    #         # Check for required arguments based on command
    #         if command_name == 'ai' and not get_attr(args, 'provider'):
                raise InvalidArgumentError('provider', None, 'AI provider is required')

    #         if command_name == 'validate' and not get_attr(args, 'file'):
    #             raise InvalidArgumentError('file', None, 'File path is required for validation')

    #         if command_name == 'sandbox' and get_attr(args, 'action') == 'run':
    #             if not get_attr(args, 'file') and not get_attr(args, 'code'):
    #                 raise InvalidArgumentError('file/code', None, 'Either file or code is required for sandbox execution')

    #         return args


class PerformanceMiddleware(CommandMiddleware)
    #     """Middleware for performance monitoring."""

    #     def __init__(self):
    self.performance_data = {}

    #     async def before_execute(self, command_name: str, args) -Any):
    #         """Record start time."""
    #         if hasattr(args, '__dict__'):
    #             # Namespace object
                setattr(args, '_start_time', time.time())
    #         else:
    #             # Dict object
    args['_start_time'] = time.time()
    #         return args

    #     async def after_execute(self, command_name: str, args, result: Dict[str, Any]) -Dict[str, Any]):
    #         """Record execution time."""
    #         # Helper function to get attribute from both dict and Namespace
    #         def get_attr(obj, key, default=None):
    #             if hasattr(obj, '__dict__'):
                    return getattr(obj, key, default)
    #             else:
                    return obj.get(key, default)

    start_time = get_attr(args, '_start_time')
    #         if start_time:
    execution_time = time.time() - start_time
    result['execution_time'] = f"{execution_time:.3f}s"

    #             # Check performance constraints
    #             if execution_time 0.5):  # 500ms limit
                    logger.warning(f"Command {command_name} exceeded 500ms limit: {execution_time:.3f}s")

    #             # Store performance data
    #             if command_name not in self.performance_data:
    self.performance_data[command_name] = []
                self.performance_data[command_name].append(execution_time)

    #         return result

    #     def get_performance_stats(self) -Dict[str, Dict[str, float]]):
    #         """Get performance statistics."""
    stats = {}
    #         for command, times in self.performance_data.items():
    #             if times:
    stats[command] = {
                        'count': len(times),
                        'avg_time': sum(times) / len(times),
                        'min_time': min(times),
                        'max_time': max(times)
    #                 }
    #         return stats


class CommandRouter
    #     """Centralized command router for NoodleCore CLI."""

    #     def __init__(self):""Initialize the command router."""
    self.commands = {}
    self.aliases = {}
    self.middleware = []
    self.performance_middleware = PerformanceMiddleware()

    #         # Add default middleware
            self.add_middleware(LoggingMiddleware())
            self.add_middleware(ValidationMiddleware())
            self.add_middleware(self.performance_middleware)

    #         # Add authentication middleware if API key is configured
    config = get_cli_config()
    #         if config.get('NOODLE_API_KEY'):
                self.add_middleware(AuthenticationMiddleware())

    #     def register_command(self, name: str, command_class: Any, aliases: Optional[List[str]] = None) -None):
    #         """
    #         Register a command with the router.

    #         Args:
    #             name: Command name
    #             command_class: Command class
    #             aliases: Optional list of command aliases
    #         """
    self.commands[name] = command_class

    #         # Register aliases
    #         if aliases:
    #             for alias in aliases:
    self.aliases[alias] = name

            logger.debug(f"Registered command: {name}")

    #     def add_middleware(self, middleware: CommandMiddleware) -None):
    #         """
    #         Add middleware to the router.

    #         Args:
    #             middleware: Middleware instance
    #         """
            self.middleware.append(middleware)
            logger.debug(f"Added middleware: {middleware.__class__.__name__}")

    #     def get_command(self, name: str) -Any):
    #         """
    #         Get a command by name or alias.

    #         Args:
    #             name: Command name or alias

    #         Returns:
    #             Command class

    #         Raises:
    #             CommandNotFoundError: If command is not found
    #         """
    #         # Check direct command name
    #         if name in self.commands:
    #             return self.commands[name]

    #         # Check aliases
    #         if name in self.aliases:
    actual_name = self.aliases[name]
    #             return self.commands[actual_name]

            raise CommandNotFoundError(name)

    #     def list_commands(self) -List[str]):
    #         """
    #         List all available commands.

    #         Returns:
    #             List of command names
    #         """
            return list(self.commands.keys())

    #     def list_aliases(self) -Dict[str, str]):
    #         """
    #         List all command aliases.

    #         Returns:
    #             Dictionary mapping aliases to command names
    #         """
            return self.aliases.copy()

    #     async def execute_command(self, command_name: str, args: Dict[str, Any], timeout: Optional[int] = None) -Dict[str, Any]):
    #         """
    #         Execute a command with middleware.

    #         Args:
    #             command_name: Name of the command to execute
    #             args: Command arguments
    #             timeout: Optional timeout in seconds

    #         Returns:
    #             Command result

    #         Raises:
    #             CommandNotFoundError: If command is not found
    #             TimeoutError: If command execution times out
    #             NoodleCliException: For other command errors
    #         """
    #         # Get command
    command = self.get_command(command_name)

    #         # Set default timeout from config if not provided
    #         if timeout is None:
    config = get_cli_config()
    timeout = config.get_int('NOODLE_REQUEST_TIMEOUT', 30)

    #         # Helper function to get and set attributes from both dict and Namespace
    #         def get_attr(obj, key, default=None):
    #             if hasattr(obj, '__dict__'):
                    return getattr(obj, key, default)
    #             else:
                    return obj.get(key, default)

    #         def set_attr(obj, key, value):
    #             if hasattr(obj, '__dict__'):
                    setattr(obj, key, value)
    #             else:
    obj[key] = value

    #         # Generate request ID if not provided
    #         if get_attr(args, 'request_id') is None:
                set_attr(args, 'request_id', str(uuid.uuid4()))

    #         # Execute with timeout and middleware
    #         try:
    #             # Execute before middleware
    #             for middleware in self.middleware:
    args = await middleware.before_execute(command_name, args)

    #             # Execute command with timeout
    result = await asyncio.wait_for(
                    self._execute_command_with_error_handling(command, args),
    timeout = timeout
    #             )

    #             # Execute after middleware
    #             for middleware in self.middleware:
    result = await middleware.after_execute(command_name, args, result)

    #             return result

    #         except asyncio.TimeoutError:
                raise TimeoutError(command_name, timeout)

    #     async def _execute_command_with_error_handling(self, command: Any, args: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Execute command with error handling.

    #         Args:
    #             command: Command instance
    #             args: Command arguments

    #         Returns:
    #             Command result
    #         """
    #         try:
    #             # Create command instance if it's a class
    #             if isinstance(command, type):
    command_instance = command()
    #             else:
    command_instance = command

    #             # Execute the command
    #             if hasattr(command_instance, 'execute'):
    result = await command_instance.execute(args)
    #             else:
                    raise NoodleCliException(f"Command {command_instance.__class__.__name__} does not have execute method", 5001)

    #             # Ensure result has required fields
    #             if 'requestId' not in result:
    result['requestId'] = args.get('request_id')

    #             if 'success' not in result:
    result['success'] = True

    #             return result

    #         except Exception as e:
    #             # Execute error middleware
    command_name = getattr(args, 'command', 'unknown')
    #             for middleware in self.middleware:
    error_result = await middleware.on_error(command_name, args, e)
    #                 if error_result:
    #                     return error_result

    #             # Re-raise NoodleCliException
    #             if isinstance(e, NoodleCliException):
    #                 raise

    #             # Wrap other exceptions
                raise NoodleCliException(f"Command execution failed: {str(e)}", 5000, {'original_error': str(e)})

    #     def get_performance_stats(self) -Dict[str, Dict[str, float]]):
    #         """
    #         Get performance statistics.

    #         Returns:
    #             Performance statistics dictionary
    #         """
            return self.performance_middleware.get_performance_stats()


# Global command router instance
_command_router = None


def get_command_router() -CommandRouter):
#     """
#     Get the global command router instance.

#     Returns:
#         CommandRouter instance
#     """
#     global _command_router
#     if _command_router is None:
_command_router = CommandRouter()
#     return _command_router


def reset_command_router() -CommandRouter):
#     """
#     Reset the global command router instance.

#     Returns:
#         New CommandRouter instance
#     """
#     global _command_router
_command_router = CommandRouter()
#     return _command_router