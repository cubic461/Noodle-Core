# Converted from Python to NoodleCore
# Original file: src

# """
# AI Output Interception Module for NoodleCore
# -------------------------------------------
# This module provides functionality to intercept AI output within the IDE
# before it reaches the user, allowing for validation and correction.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import re
import time
import uuid
import logging
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

import .guard.AIGuard


class InterceptionPoint(Enum)
    #     """Points where AI output can be intercepted"""
    IDE_INTEGRATION = "ide_integration"  # Direct IDE integration
    LSP_HOOK = "lsp_hook"  # Language Server Protocol hook
    FILE_WRITE = "file_write"  # File write operations
    CLIPBOARD = "clipboard"  # Clipboard operations
    #     API_ENDPOINT = "api_endpoint"  # API endpoint for AI services


class InterceptionMode(Enum)
    #     """Modes for output interception"""
    BLOCKING = "blocking"  # Block until validation is complete
    ASYNC = "async"  # Validate asynchronously
    PASSIVE = "passive"  # Log and warn but don't block


dataclass
class InterceptionConfig
    #     """Configuration for output interception"""

    interception_points: Set[InterceptionPoint] = field(
    default_factory = lambda: {InterceptionPoint.IDE_INTEGRATION}
    #     )
    mode: InterceptionMode = InterceptionMode.BLOCKING
    enable_logging: bool = True
    log_file: Optional[str] = None
    max_intercepted_size: int = 1024 * 1024  # 1MB
    timeout_ms: int = 5000  # 5 seconds
    cache_enabled: bool = True
    bypass_patterns: List[str] = field(default_factory=list)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert config to dictionary"""
    #         return {
    #             "interception_points": [point.value for point in self.interception_points],
    #             "mode": self.mode.value,
    #             "enable_logging": self.enable_logging,
    #             "log_file": self.log_file,
    #             "max_intercepted_size": self.max_intercepted_size,
    #             "timeout_ms": self.timeout_ms,
    #             "cache_enabled": self.cache_enabled,
    #             "bypass_patterns": self.bypass_patterns,
    #         }


dataclass
class InterceptedOutput
    #     """Represents intercepted AI output"""

    #     content: str
    #     source: str
    #     timestamp: float
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "content": self.content,
    #             "source": self.source,
    #             "timestamp": self.timestamp,
    #             "metadata": self.metadata,
    #         }


class OutputInterceptor
    #     """
    #     Intercepts AI output within the IDE for validation

    #     This class provides hooks to intercept AI output at various points in the
    #     IDE workflow, allowing for validation before the output reaches the user.
    #     """

    #     def __init__(self, guard: AIGuard, config: Optional[InterceptionConfig] = None):""Initialize the output interceptor"""
    self.guard = guard
    self.config = config or InterceptionConfig()

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Performance tracking
    self.stats = {
    #             "total_interceptions": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "bypassed_interceptions": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Cache for performance
    #         self._interception_cache = {} if self.config.cache_enabled else None

    #         # Registered hooks
    self._hooks = {
    #             point: [] for point in InterceptionPoint
    #         }

    #         self.logger.info(f"Output interceptor initialized with mode: {self.config.mode.value}")

    #     def _setup_logging(self) -logging.Logger):
    #         """Setup logging for the output interceptor"""
    logger = logging.getLogger("noodlecore.ai.output_interceptor")
            logger.setLevel(logging.INFO)

    #         if self.config.enable_logging:
    #             # Create formatter
    formatter = logging.Formatter(
                    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #             )

    #             # Create console handler
    console_handler = logging.StreamHandler()
                console_handler.setFormatter(formatter)
                logger.addHandler(console_handler)

    #             # Create file handler if log file is specified
    #             if self.config.log_file:
    file_handler = logging.FileHandler(self.config.log_file)
                    file_handler.setFormatter(formatter)
                    logger.addHandler(file_handler)

    #         return logger

    #     def register_hook(
    #         self,
    #         point: InterceptionPoint,
    #         hook: Callable[[InterceptedOutput], InterceptedOutput]
    #     ):
    #         """
    #         Register a hook for an interception point

    #         Args:
    #             point: The interception point
    #             hook: The hook function to call
    #         """
            self._hooks[point].append(hook)
    #         self.logger.info(f"Registered hook for {point.value}")

    #     def intercept(
    #         self,
    #         content: str,
    #         source: str,
    metadata: Optional[Dict[str, Any]] = None,
    file_path: Optional[str] = None,
    correction_callback: Optional[Callable[[str, List], str]] = None
    #     ) -Tuple[bool, str, Optional[GuardResult]]):
    #         """
    #         Intercept and validate AI output

    #         Args:
    #             content: The AI-generated content
                source: The source of the content (e.g., "gpt-4", "claude")
    #             metadata: Optional metadata about the content
    #             file_path: Optional file path for error reporting
    #             correction_callback: Optional callback to request corrections

    #         Returns:
                Tuple of (is_valid, content, guard_result)
    #         """
    start_time = time.time()

    #         # Create intercepted output object
    intercepted = InterceptedOutput(
    content = content,
    source = source,
    timestamp = time.time(),
    metadata = metadata or {}
    #         )

            self.logger.info(f"Intercepting output from {source} (request_id: {intercepted.request_id})")
    self.stats["total_interceptions"] + = 1

    #         # Check if content should be bypassed
    #         if self._should_bypass(content):
    #             self.logger.info(f"Bypassing validation for output (request_id: {intercepted.request_id})")
    self.stats["bypassed_interceptions"] + = 1
    #             return True, content, None

    #         # Check cache first
    #         cache_key = hash(content) if self.config.cache_enabled else None
    #         if cache_key is not None and self._interception_cache and cache_key in self._interception_cache:
    cached_result = self._interception_cache[cache_key]
                self.logger.info(f"Using cached validation result (request_id: {intercepted.request_id})")
    #             return cached_result["is_valid"], cached_result["content"], cached_result["guard_result"]

    #         # Apply registered hooks
    #         for point in self.config.interception_points:
    #             for hook in self._hooks[point]:
    #                 try:
    intercepted = hook(intercepted)
    #                 except Exception as e:
    #                     self.logger.error(f"Hook error for {point.value}: {str(e)}")

    #         # Validate with guard
    guard_result = self.guard.validate_output(
    #             intercepted.content,
    #             file_path,
    #             correction_callback
    #         )

    #         # Determine final content and validity
    is_valid = guard_result.success and guard_result.is_valid
    final_content = guard_result.corrected_output or guard_result.original_output

    #         # Update statistics
    #         if is_valid:
    self.stats["successful_validations"] + = 1
                self.logger.info(f"Validation successful (request_id: {intercepted.request_id})")
    #         else:
    self.stats["failed_validations"] + = 1
                self.logger.warning(f"Validation failed (request_id: {intercepted.request_id})")

    #         # Cache the result
    #         if cache_key is not None and self._interception_cache is not None:
    self._interception_cache[cache_key] = {
    #                 "is_valid": is_valid,
    #                 "content": final_content,
    #                 "guard_result": guard_result
    #             }

    #         # Calculate execution time
    execution_time = int((time.time() - start_time) * 1000)
    self.stats["total_time_ms"] + = execution_time

    #         return is_valid, final_content, guard_result

    #     def _should_bypass(self, content: str) -bool):
    #         """Check if content should bypass validation"""
    #         # Check size limit
    #         if len(content) self.config.max_intercepted_size):
    #             return True

    #         # Check bypass patterns
    #         for pattern in self.config.bypass_patterns:
    #             if re.search(pattern, content):
    #                 return True

    #         return False

    #     def intercept_file_write(
    #         self,
    #         file_path: str,
    #         content: str,
    source: str = "unknown",
    metadata: Optional[Dict[str, Any]] = None,
    correction_callback: Optional[Callable[[str, List], str]] = None
    #     ) -Tuple[bool, str, Optional[GuardResult]]):
    #         """
    #         Intercept file write operations

    #         Args:
    #             file_path: The path to the file being written
    #             content: The content being written
    #             source: The source of the content
    #             metadata: Optional metadata
    #             correction_callback: Optional callback to request corrections

    #         Returns:
                Tuple of (is_valid, content, guard_result)
    #         """
    #         if InterceptionPoint.FILE_WRITE not in self.config.interception_points:
    #             return True, content, None

            self.logger.info(f"Intercepting file write to {file_path}")

    #         # Add file path to metadata
    file_metadata = metadata or {}
    file_metadata["file_path"] = file_path
    file_metadata["operation"] = "write"

            return self.intercept(
    content = content,
    source = source,
    metadata = file_metadata,
    file_path = file_path,
    correction_callback = correction_callback
    #         )

    #     def intercept_ide_integration(
    #         self,
    #         content: str,
    source: str = "ide",
    metadata: Optional[Dict[str, Any]] = None,
    correction_callback: Optional[Callable[[str, List], str]] = None
    #     ) -Tuple[bool, str, Optional[GuardResult]]):
    #         """
    #         Intercept IDE integration operations

    #         Args:
    #             content: The content from IDE integration
    #             source: The source of the content
    #             metadata: Optional metadata
    #             correction_callback: Optional callback to request corrections

    #         Returns:
                Tuple of (is_valid, content, guard_result)
    #         """
    #         if InterceptionPoint.IDE_INTEGRATION not in self.config.interception_points:
    #             return True, content, None

            self.logger.info(f"Intercepting IDE integration from {source}")

    #         # Add IDE metadata
    ide_metadata = metadata or {}
    ide_metadata["operation"] = "ide_integration"

            return self.intercept(
    content = content,
    source = source,
    metadata = ide_metadata,
    correction_callback = correction_callback
    #         )

    #     def intercept_lsp_hook(
    #         self,
    #         content: str,
    source: str = "lsp",
    metadata: Optional[Dict[str, Any]] = None,
    correction_callback: Optional[Callable[[str, List], str]] = None
    #     ) -Tuple[bool, str, Optional[GuardResult]]):
    #         """
    #         Intercept LSP hook operations

    #         Args:
    #             content: The content from LSP hook
    #             source: The source of the content
    #             metadata: Optional metadata
    #             correction_callback: Optional callback to request corrections

    #         Returns:
                Tuple of (is_valid, content, guard_result)
    #         """
    #         if InterceptionPoint.LSP_HOOK not in self.config.interception_points:
    #             return True, content, None

            self.logger.info(f"Intercepting LSP hook from {source}")

    #         # Add LSP metadata
    lsp_metadata = metadata or {}
    lsp_metadata["operation"] = "lsp_hook"

            return self.intercept(
    content = content,
    source = source,
    metadata = lsp_metadata,
    correction_callback = correction_callback
    #         )

    #     def intercept_clipboard(
    #         self,
    #         content: str,
    source: str = "clipboard",
    metadata: Optional[Dict[str, Any]] = None,
    correction_callback: Optional[Callable[[str, List], str]] = None
    #     ) -Tuple[bool, str, Optional[GuardResult]]):
    #         """
    #         Intercept clipboard operations

    #         Args:
    #             content: The content from clipboard
    #             source: The source of the content
    #             metadata: Optional metadata
    #             correction_callback: Optional callback to request corrections

    #         Returns:
                Tuple of (is_valid, content, guard_result)
    #         """
    #         if InterceptionPoint.CLIPBOARD not in self.config.interception_points:
    #             return True, content, None

            self.logger.info(f"Intercepting clipboard operation from {source}")

    #         # Add clipboard metadata
    clipboard_metadata = metadata or {}
    clipboard_metadata["operation"] = "clipboard"

            return self.intercept(
    content = content,
    source = source,
    metadata = clipboard_metadata,
    correction_callback = correction_callback
    #         )

    #     def intercept_api_endpoint(
    #         self,
    #         content: str,
    source: str = "api",
    metadata: Optional[Dict[str, Any]] = None,
    correction_callback: Optional[Callable[[str, List], str]] = None
    #     ) -Tuple[bool, str, Optional[GuardResult]]):
    #         """
    #         Intercept API endpoint operations

    #         Args:
    #             content: The content from API endpoint
    #             source: The source of the content
    #             metadata: Optional metadata
    #             correction_callback: Optional callback to request corrections

    #         Returns:
                Tuple of (is_valid, content, guard_result)
    #         """
    #         if InterceptionPoint.API_ENDPOINT not in self.config.interception_points:
    #             return True, content, None

            self.logger.info(f"Intercepting API endpoint from {source}")

    #         # Add API metadata
    api_metadata = metadata or {}
    api_metadata["operation"] = "api_endpoint"

            return self.intercept(
    content = content,
    source = source,
    metadata = api_metadata,
    correction_callback = correction_callback
    #         )

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get interceptor statistics"""
    #         return {
    #             "total_interceptions": self.stats["total_interceptions"],
    #             "successful_validations": self.stats["successful_validations"],
    #             "failed_validations": self.stats["failed_validations"],
    #             "bypassed_interceptions": self.stats["bypassed_interceptions"],
                "success_rate": (
    #                 self.stats["successful_validations"] / self.stats["total_interceptions"]
    #                 if self.stats["total_interceptions"] 0 else 0
    #             ),
    #             "total_time_ms"): self.stats["total_time_ms"],
                "average_time_ms": (
    #                 self.stats["total_time_ms"] / self.stats["total_interceptions"]
    #                 if self.stats["total_interceptions"] 0 else 0
    #             ),
    #             "cache_size"): len(self._interception_cache) if self._interception_cache else 0,
                "config": self.config.to_dict(),
    #         }

    #     def clear_cache(self):
    #         """Clear the interception cache"""
    #         if self._interception_cache:
                self._interception_cache.clear()
                self.logger.info("Interception cache cleared")

    #     def reset_statistics(self):
    #         """Reset interceptor statistics"""
    self.stats = {
    #             "total_interceptions": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "bypassed_interceptions": 0,
    #             "total_time_ms": 0,
    #         }
            self.logger.info("Statistics reset")