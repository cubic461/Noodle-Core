# Converted from Python to NoodleCore
# Original file: src

# """
# Linter Communication Bridge for NoodleCore AI Guard
# ----------------------------------------------------
# This module provides communication between the AI Guard and the NoodleCore linter,
# facilitating semantic checks and validation of AI-generated code.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import time
import uuid
import logging
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

import ..linter.linter.NoodleLinter
import ..compiler.parser_ast_nodes.ProgramNode
import .guard.GuardMode


class CommunicationMode(Enum)
    #     """Modes of communication with the linter"""
    DIRECT = "direct"  # Direct linter calls
    ASYNC = "async"  # Asynchronous linter calls
    BATCH = "batch"  # Batch processing
    STREAMING = "streaming"  # Streaming validation


class ValidationPriority(Enum)
    #     """Priority levels for validation"""
    CRITICAL = "critical"  # Critical errors only
    HIGH = "high"  # High priority issues
    NORMAL = "normal"  # Normal priority issues
    LOW = "low"  # All issues including style


dataclass
class LinterBridgeConfig
    #     """Configuration for the linter bridge"""

    mode: CommunicationMode = CommunicationMode.DIRECT
    priority: ValidationPriority = ValidationPriority.NORMAL
    timeout_ms: int = 5000  # 5 seconds
    enable_caching: bool = True
    enable_semantic_check: bool = True
    enable_style_check: bool = True
    max_concurrent_validations: int = 5
    batch_size: int = 10
    retry_attempts: int = 3
    custom_rules: List[str] = field(default_factory=list)
    disabled_rules: Set[str] = field(default_factory=set)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert config to dictionary"""
    #         return {
    #             "mode": self.mode.value,
    #             "priority": self.priority.value,
    #             "timeout_ms": self.timeout_ms,
    #             "enable_caching": self.enable_caching,
    #             "enable_semantic_check": self.enable_semantic_check,
    #             "enable_style_check": self.enable_style_check,
    #             "max_concurrent_validations": self.max_concurrent_validations,
    #             "batch_size": self.batch_size,
    #             "retry_attempts": self.retry_attempts,
    #             "custom_rules": self.custom_rules,
                "disabled_rules": list(self.disabled_rules),
    #         }


dataclass
class ValidationRequest
    #     """Represents a validation request"""

    #     code: str
    #     mode: GuardMode
    file_path: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "code": self.code,
    #             "mode": self.mode.value,
    #             "filePath": self.file_path,
    #             "metadata": self.metadata,
    #             "timestamp": self.timestamp,
    #         }


dataclass
class ValidationResponse
    #     """Represents a validation response"""

    #     request_id: str
    #     success: bool
    #     result: LinterResult
    #     execution_time_ms: int
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "success": self.success,
                "result": self.result.to_dict(),
    #             "executionTimeMs": self.execution_time_ms,
    #             "timestamp": self.timestamp,
    #         }


class LinterBridge
    #     """
    #     Bridge between AI Guard and NoodleCore linter

    #     This class provides communication between the AI Guard and the NoodleCore linter,
    #     facilitating semantic checks and validation of AI-generated code.
    #     """

    #     def __init__(self, config: Optional[LinterBridgeConfig] = None):""Initialize the linter bridge"""
    self.config = config or LinterBridgeConfig()

    #         # Initialize linter with appropriate configuration
    linter_config = LinterConfig()
    linter_config.mode = "runtime_load"
    linter_config.enable_syntax_check = True
    linter_config.enable_semantic_check = self.config.enable_semantic_check
    linter_config.enable_validation_rules = self.config.enable_style_check
    linter_config.timeout_ms = self.config.timeout_ms
    linter_config.cache_enabled = self.config.enable_caching

    self.linter = NoodleLinter(linter_config)

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Performance tracking
    self.stats = {
    #             "total_requests": 0,
    #             "successful_requests": 0,
    #             "failed_requests": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Cache for performance
    #         self._request_cache = {} if self.config.enable_caching else None

    #         # Batch processing queue
    self._batch_queue = []
    self._batch_timer = None

    #         self.logger.info(f"Linter bridge initialized with mode: {self.config.mode.value}")

    #     def _setup_logging(self) -logging.Logger):
    #         """Setup logging for the linter bridge"""
    logger = logging.getLogger("noodlecore.ai.linter_bridge")
            logger.setLevel(logging.INFO)

    #         # Create formatter
    formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #         )

    #         # Create console handler
    console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)

    #         return logger

    #     def validate(
    #         self,
    #         code: str,
    mode: GuardMode = GuardMode.ADAPTIVE,
    file_path: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -ValidationResponse):
    #         """
    #         Validate code using the linter

    #         Args:
    #             code: The code to validate
    #             mode: The validation mode
    #             file_path: Optional file path for error reporting
    #             metadata: Optional metadata

    #         Returns:
    #             ValidationResponse: Result of the validation
    #         """
    start_time = time.time()

    #         # Create validation request
    request = ValidationRequest(
    code = code,
    mode = mode,
    file_path = file_path,
    metadata = metadata or {}
    #         )

            self.logger.info(f"Processing validation request (request_id: {request.request_id})")
    self.stats["total_requests"] + = 1

    #         try:
    #             # Check cache first
    #             cache_key = hash(code) if self.config.enable_caching else None
    #             if cache_key is not None and self._request_cache and cache_key in self._request_cache:
    cached_response = self._request_cache[cache_key]
                    self.logger.info(f"Using cached validation result (request_id: {request.request_id})")
    #                 return cached_response

    #             # Process based on communication mode
    #             if self.config.mode == CommunicationMode.DIRECT:
    linter_result = self._validate_direct(request)
    #             elif self.config.mode == CommunicationMode.ASYNC:
    linter_result = self._validate_async(request)
    #             elif self.config.mode == CommunicationMode.BATCH:
    linter_result = self._validate_batch(request)
    #             else:  # STREAMING
    linter_result = self._validate_streaming(request)

    #             # Create response
    response = ValidationResponse(
    request_id = request.request_id,
    success = True,
    result = linter_result,
    execution_time_ms = int((time.time() - start_time) * 1000)
    #             )

    #             # Cache the response
    #             if cache_key is not None and self._request_cache is not None:
    self._request_cache[cache_key] = response

    #             # Update statistics
    self.stats["successful_requests"] + = 1
    self.stats["total_time_ms"] + = response.execution_time_ms

                self.logger.info(f"Validation successful (request_id: {request.request_id})")
    #             return response

    #         except Exception as e:
    #             # Create error response
    error_result = LinterResult(success=False)
                error_result.errors.append(LinterError(
    code = "E805",
    message = f"Linter bridge error: {str(e)}",
    severity = "error",
    category = "bridge",
    file = file_path,
    #             ))

    response = ValidationResponse(
    request_id = request.request_id,
    success = False,
    result = error_result,
    execution_time_ms = int((time.time() - start_time) * 1000)
    #             )

    #             # Update statistics
    self.stats["failed_requests"] + = 1
    self.stats["total_time_ms"] + = response.execution_time_ms

                self.logger.error(f"Validation failed (request_id: {request.request_id}): {str(e)}")
    #             return response

    #     def _validate_direct(self, request: ValidationRequest) -LinterResult):
    #         """Validate directly using the linter"""
    #         # Configure linter based on mode and priority
            self._configure_linter(request.mode, request.priority)

    #         # Perform validation with retry logic
    #         for attempt in range(self.config.retry_attempts + 1):
    #             try:
    result = self.linter.lint_source(request.code, request.file_path)

    #                 # Filter results based on priority
                    return self._filter_result_by_priority(result, request.priority)

    #             except Exception as e:
    #                 if attempt == self.config.retry_attempts:
    #                     raise e
                    self.logger.warning(f"Validation attempt {attempt + 1} failed, retrying: {str(e)}")

    #     def _validate_async(self, request: ValidationRequest) -LinterResult):
            """Validate asynchronously (simplified implementation)"""
    #         # In a real implementation, this would use async/await or threading
    #         # For now, we'll fall back to direct validation
            return self._validate_direct(request)

    #     def _validate_batch(self, request: ValidationRequest) -LinterResult):
    #         """Validate using batch processing"""
    #         # Add request to batch queue
            self._batch_queue.append(request)

    #         # Process batch if it's full
    #         if len(self._batch_queue) >= self.config.batch_size:
                return self._process_batch()

    #         # Return a temporary result for now
    #         # In a real implementation, this would return a future or promise
            return self._validate_direct(request)

    #     def _validate_streaming(self, request: ValidationRequest) -LinterResult):
            """Validate using streaming (simplified implementation)"""
    #         # In a real implementation, this would process the code in chunks
    #         # For now, we'll fall back to direct validation
            return self._validate_direct(request)

    #     def _process_batch(self) -LinterResult):
    #         """Process the batch queue"""
    #         if not self._batch_queue:
    return LinterResult(success = True)

    #         # Configure linter for batch processing
            self._configure_linter(GuardMode.ADAPTIVE, ValidationPriority.NORMAL)

    #         # Process all requests in the batch
    results = []
    #         for request in self._batch_queue:
    #             try:
    result = self.linter.lint_source(request.code, request.file_path)
    result = self._filter_result_by_priority(result, request.priority)
                    results.append(result)
    #             except Exception as e:
    #                 # Create error result
    error_result = LinterResult(success=False)
                    error_result.errors.append(LinterError(
    code = "E805",
    message = f"Batch validation error: {str(e)}",
    severity = "error",
    category = "bridge",
    file = request.file_path,
    #                 ))
                    results.append(error_result)

    #         # Clear the batch queue
            self._batch_queue.clear()

    #         # Combine results
    combined_result = LinterResult(success=True)
    #         for result in results:
                combined_result.errors.extend(result.errors)
                combined_result.warnings.extend(result.warnings)
                combined_result.infos.extend(result.infos)

    combined_result.success = len(combined_result.errors) == 0

    #         return combined_result

    #     def _configure_linter(self, mode: GuardMode, priority: ValidationPriority):
    #         """Configure the linter based on mode and priority"""
    #         # Configure based on mode
    #         if mode == GuardMode.STRICT:
    self.linter.config.strict_mode = True
    self.linter.config.enable_syntax_check = True
    self.linter.config.enable_semantic_check = True
    self.linter.config.enable_validation_rules = True
    #         elif mode == GuardMode.ADAPTIVE:
    self.linter.config.strict_mode = False
    self.linter.config.enable_syntax_check = True
    self.linter.config.enable_semantic_check = True
    self.linter.config.enable_validation_rules = True
    #         else:  # PERMISSIVE
    self.linter.config.strict_mode = False
    self.linter.config.enable_syntax_check = True
    self.linter.config.enable_semantic_check = True
    self.linter.config.enable_validation_rules = False

    #         # Configure based on priority
    #         if priority == ValidationPriority.CRITICAL:
    self.linter.config.max_errors = 10
    self.linter.config.max_warnings = 0
    #         elif priority == ValidationPriority.HIGH:
    self.linter.config.max_errors = 50
    self.linter.config.max_warnings = 10
    #         elif priority == ValidationPriority.NORMAL:
    self.linter.config.max_errors = 100
    self.linter.config.max_warnings = 50
    #         else:  # LOW
    self.linter.config.max_errors = 1000
    self.linter.config.max_warnings = 100

    #     def _filter_result_by_priority(self, result: LinterResult, priority: ValidationPriority) -LinterResult):
    #         """Filter linter result based on priority"""
    filtered_result = LinterResult(success=result.success)

    #         if priority == ValidationPriority.CRITICAL:
    #             # Only include critical errors
    filtered_result.errors = [
    #                 error for error in result.errors
    #                 if error.severity == "error" and error.category in ["syntax", "semantic", "compiler"]
    #             ]
    #         elif priority == ValidationPriority.HIGH:
    #             # Include errors and high-priority warnings
    filtered_result.errors = result.errors
    filtered_result.warnings = [
    #                 warning for warning in result.warnings
    #                 if warning.category in ["syntax", "semantic", "compiler", "security"]
    #             ]
    #         elif priority == ValidationPriority.NORMAL:
    #             # Include errors and most warnings
    filtered_result.errors = result.errors
    filtered_result.warnings = result.warnings
    filtered_result.infos = [
    #                 info for info in result.infos
    #                 if info.category in ["syntax", "semantic", "compiler", "security", "performance"]
    #             ]
    #         else:  # LOW
    #             # Include everything
    filtered_result = result

    #         return filtered_result

    #     def validate_multiple(
    #         self,
    #         requests: List[ValidationRequest]
    #     ) -List[ValidationResponse]):
    #         """
    #         Validate multiple requests

    #         Args:
    #             requests: List of validation requests

    #         Returns:
    #             List[ValidationResponse]: List of validation responses
    #         """
    responses = []

    #         for request in requests:
    response = self.validate(
    #                 request.code,
    #                 request.mode,
    #                 request.file_path,
    #                 request.metadata
    #             )
                responses.append(response)

    #         return responses

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get bridge statistics"""
    #         return {
    #             "total_requests": self.stats["total_requests"],
    #             "successful_requests": self.stats["successful_requests"],
    #             "failed_requests": self.stats["failed_requests"],
                "success_rate": (
    #                 self.stats["successful_requests"] / self.stats["total_requests"]
    #                 if self.stats["total_requests"] 0 else 0
    #             ),
    #             "total_time_ms"): self.stats["total_time_ms"],
                "average_time_ms": (
    #                 self.stats["total_time_ms"] / self.stats["total_requests"]
    #                 if self.stats["total_requests"] 0 else 0
    #             ),
    #             "cache_size"): len(self._request_cache) if self._request_cache else 0,
                "batch_queue_size": len(self._batch_queue),
                "config": self.config.to_dict(),
    #         }

    #     def clear_cache(self):
    #         """Clear the request cache"""
    #         if self._request_cache:
                self._request_cache.clear()
                self.logger.info("Request cache cleared")

    #     def reset_statistics(self):
    #         """Reset bridge statistics"""
    self.stats = {
    #             "total_requests": 0,
    #             "successful_requests": 0,
    #             "failed_requests": 0,
    #             "total_time_ms": 0,
    #         }
            self.logger.info("Statistics reset")