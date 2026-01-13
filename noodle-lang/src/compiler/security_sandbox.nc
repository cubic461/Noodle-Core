# Converted from Python to NoodleCore
# Original file: src

# """
# Security Sandbox for NoodleCore Runtime

# This module provides a secure execution environment for validated NoodleCore code,
# preventing unauthorized access to system resources and enforcing security policies.
# """

import os
import sys
import importlib
import hashlib
import logging
import typing.Any
from dataclasses import dataclass
import enum.Enum

import .errors.NoodleError


class SandboxPermission(Enum)
    #     """Sandbox permission levels."""
    NONE = "none"
    READ_ONLY = "read_only"
    RESTRICTED = "restricted"
    FULL = "full"


class SecurityViolationError(NoodleError)
    #     """Raised when code violates security policies."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3001", details)


class UnsignedCodeError(NoodleError)
    #     """Raised when attempting to execute unsigned code."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3002", details)


class UnknownExtensionError(NoodleError)
    #     """Raised when attempting to execute code with unknown extensions."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3003", details)


dataclass
class SandboxConfig
    #     """Configuration for the security sandbox."""
    allow_filesystem: bool = False
    allow_network: bool = False
    allow_imports: bool = True
    allowed_imports: Optional[Set[str]] = None
    max_memory_mb: int = 512
    max_execution_time: float = 30.0
    trusted_signatures: Optional[Set[str]] = None
    allowed_extensions: Optional[Set[str]] = None
    log_violations: bool = True

    #     def __post_init__(self):
    #         if self.allowed_imports is None:
    self.allowed_imports = {
    #                 "math", "random", "datetime", "json", "collections",
    #                 "itertools", "functools", "operator", "re", "string"
    #             }
    #         if self.trusted_signatures is None:
    self.trusted_signatures = set()
    #         if self.allowed_extensions is None:
    self.allowed_extensions = {".nc", ".py"}


class SecuritySandbox
    #     """
    #     Provides a secure execution environment for validated NoodleCore code.

    #     This sandbox enforces security policies to prevent unauthorized access to
    #     system resources and ensures only validated code can be executed.
    #     """

    #     def __init__(self, config: Optional[SandboxConfig] = None):""
    #         Initialize the security sandbox.

    #         Args:
    #             config: Sandbox configuration
    #         """
    self.config = config or SandboxConfig()
    self.logger = logging.getLogger(__name__)
    self._execution_context = {}
    self._restricted_modules = {
    #             "os", "sys", "subprocess", "socket", "urllib", "http", "ftplib",
    #             "smtplib", "telnetlib", "pickle", "shelve", "dbm", "sqlite3",
    #             "ctypes", "threading", "multiprocessing", "asyncio", "inspect"
    #         }

    #     def validate_code_signature(self, code: str, signature: str) -bool):
    #         """
    #         Validate the signature of the code.

    #         Args:
    #             code: The code to validate
    #             signature: The signature to check against

    #         Returns:
    #             True if the signature is valid, False otherwise
    #         """
    #         # Compute SHA-256 hash of the code
    code_hash = hashlib.sha256(code.encode()).hexdigest()

    #         # Check if the signature matches any trusted signatures
    #         if signature in self.config.trusted_signatures:
    #             return True

    #         # Check if the computed hash matches the signature
    #         if code_hash == signature:
    #             return True

    #         return False

    #     def check_file_extension(self, file_path: str) -bool):
    #         """
    #         Check if the file extension is allowed.

    #         Args:
    #             file_path: Path to the file to check

    #         Returns:
    #             True if the extension is allowed, False otherwise
    #         """
    _, ext = os.path.splitext(file_path)
            return ext.lower() in self.config.allowed_extensions

    #     def validate_imports(self, code: str) -List[str]):
    #         """
    #         Validate imports in the code.

    #         Args:
    #             code: The code to validate

    #         Returns:
    #             List of invalid imports found
    #         """
    #         import re

    #         # Find all import statements
    import_pattern = r"(?:import\s+([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)*)|from\s+([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)*)\s+import)"
    matches = re.findall(import_pattern, code)

    #         # Extract module names
    modules = set()
    #         for match in matches:
    #             for module in match:
    #                 if module:
                        modules.add(module.split('.')[0])

    #         # Check for restricted modules
    invalid_imports = []
    #         for module in modules:
    #             if module in self._restricted_modules or module not in self.config.allowed_imports:
                    invalid_imports.append(module)

    #         return invalid_imports

    #     def check_security_violations(self, code: str) -List[str]):
    #         """
    #         Check for potential security violations in the code.

    #         Args:
    #             code: The code to check

    #         Returns:
    #             List of security violations found
    #         """
    violations = []

    #         # Check for dangerous functions
    dangerous_patterns = [
                (r"eval\s*\(", "Use of eval() function"),
                (r"exec\s*\(", "Use of exec() function"),
                (r"compile\s*\(", "Use of compile() function"),
                (r"__import__\s*\(", "Use of __import__() function"),
                (r"open\s*\(", "File access"),
                (r"input\s*\(", "User input"),
    #         ]

    #         import re
    #         for pattern, description in dangerous_patterns:
    #             if re.search(pattern, code):
                    violations.append(description)

    #         return violations

    #     def create_restricted_globals(self) -Dict[str, Any]):
    #         """
    #         Create a restricted globals dictionary for code execution.

    #         Returns:
    #             Restricted globals dictionary
    #         """
    safe_builtins = {
    #             'abs': abs, 'all': all, 'any': any, 'bin': bin, 'bool': bool,
    #             'chr': chr, 'dict': dict, 'divmod': divmod, 'enumerate': enumerate,
    #             'float': float, 'format': format, 'frozenset': frozenset, 'hex': hex,
    #             'int': int, 'len': len, 'list': list, 'map': map, 'max': max,
    #             'min': min, 'oct': oct, 'ord': ord, 'pow': pow, 'range': range,
    #             'repr': repr, 'reversed': reversed, 'round': round, 'set': set,
    #             'slice': slice, 'sorted': sorted, 'str': str, 'sum': sum,
    #             'tuple': tuple, 'type': type, 'zip': zip,
    #         }

    #         # Add allowed modules
    #         for module_name in self.config.allowed_imports:
    #             try:
    module = importlib.import_module(module_name)
    safe_builtins[module_name] = module
    #             except ImportError:
    #                 pass

    #         return {
    #             '__builtins__': safe_builtins,
    #             '__name__': '__noodle_sandbox__',
    #             '__doc__': 'NoodleCore Security Sandbox',
    #         }

    #     def execute_code(self, code: str, signature: Optional[str] = None,
    file_path: Optional[str] = None) - Any):
    #         """
    #         Execute code in the secure sandbox.

    #         Args:
    #             code: The code to execute
    #             signature: Optional signature of the code
    #             file_path: Optional path to the source file

    #         Returns:
    #             Result of code execution

    #         Raises:
    #             SecurityViolationError: If code violates security policies
    #             UnsignedCodeError: If code is not signed when required
    #             UnknownExtensionError: If file has unknown extension
    #         """
    #         # Check file extension if provided
    #         if file_path and not self.check_file_extension(file_path):
                raise UnknownExtensionError(
                    f"File extension not allowed: {os.path.splitext(file_path)[1]}"
    #             )

    #         # Validate signature if provided
    #         if signature and not self.validate_code_signature(code, signature):
                raise UnsignedCodeError("Code signature validation failed")

    #         # Check for security violations
    violations = self.check_security_violations(code)
    #         if violations:
    message = f"Security violations detected: {', '.join(violations)}"
    #             if self.config.log_violations:
                    self.logger.warning(message)
                raise SecurityViolationError(message, {"violations": violations})

    #         # Validate imports
    invalid_imports = self.validate_imports(code)
    #         if invalid_imports:
    message = f"Invalid imports detected: {', '.join(invalid_imports)}"
    #             if self.config.log_violations:
                    self.logger.warning(message)
                raise SecurityViolationError(message, {"invalid_imports": invalid_imports})

    #         # Execute code in restricted environment
    restricted_globals = self.create_restricted_globals()

    #         try:
                exec(code, restricted_globals, self._execution_context)
    #             return self._execution_context
    #         except Exception as e:
                self.logger.error(f"Error executing code in sandbox: {str(e)}")
                raise NoodleError(f"Code execution failed: {str(e)}", "3004", {"original_error": str(e)})

    #     def reset_context(self) -None):
    #         """Reset the execution context."""
    self._execution_context = {}

    #     def get_context(self) -Dict[str, Any]):
    #         """
    #         Get the current execution context.

    #         Returns:
    #             Current execution context
    #         """
            return self._execution_context.copy()