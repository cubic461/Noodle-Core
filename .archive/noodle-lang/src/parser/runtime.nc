# Converted from Python to NoodleCore
# Original file: src

# """
# IDE Runtime Integration Module for NoodleCore
# ----------------------------------------------
# This module provides the main IDE runtime integration that coordinates all validation
# components for real-time code validation in IDE environments.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import time
import uuid
import logging
import threading
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

# Import AI components
import ..ai.guard.AIGuard
import ..ai.syntax_validator.SyntaxValidator
import ..ai.linter_bridge.LinterBridge
import ..ai.compliance_tracker.ComplianceTracker

# Import compiler components
import ..compiler.frontend.CompilerFrontend

# Import linter components
import ..linter.linter.NoodleLinter


class RuntimeActionType(Enum)
    #     """Types of IDE actions that can be validated"""
    BUFFER_CHANGE = "buffer_change"  # Buffer content changed
    BUFFER_SAVE = "buffer_save"  # Buffer saved to file
    CURSOR_MOVE = "cursor_move"  # Cursor position changed
    SELECTION_CHANGE = "selection_change"  # Text selection changed
    COMPLETION_REQUEST = "completion_request"  # Code completion requested
    FORMAT_REQUEST = "format_request"  # Code formatting requested
    AI_INTERVENTION = "ai_intervention"  # AI intervention in progress
    EXTERNAL_FRAGMENT = "external_fragment"  # External code fragment inserted


class RuntimeStatus(Enum)
    #     """Status of the IDE runtime"""
    INITIALIZING = "initializing"
    READY = "ready"
    VALIDATING = "validating"
    ERROR = "error"
    SHUTTING_DOWN = "shutting_down"


dataclass
class RuntimeConfig
    #     """Configuration for the IDE runtime"""

    enable_syntax_validation: bool = True
    enable_semantic_validation: bool = True
    enable_ai_guard: bool = True
    enable_compliance_tracking: bool = True
    enable_incremental_validation: bool = True
    validation_timeout_ms: int = 5000  # 5 seconds
    max_concurrent_validations: int = 5
    cache_size: int = 100
    auto_save_validation_results: bool = True
    log_level: str = "INFO"
    cmdb_connection_string: Optional[str] = None
    project_database_path: Optional[str] = None

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert config to dictionary"""
    #         return {
    #             "enable_syntax_validation": self.enable_syntax_validation,
    #             "enable_semantic_validation": self.enable_semantic_validation,
    #             "enable_ai_guard": self.enable_ai_guard,
    #             "enable_compliance_tracking": self.enable_compliance_tracking,
    #             "enable_incremental_validation": self.enable_incremental_validation,
    #             "validation_timeout_ms": self.validation_timeout_ms,
    #             "max_concurrent_validations": self.max_concurrent_validations,
    #             "cache_size": self.cache_size,
    #             "auto_save_validation_results": self.auto_save_validation_results,
    #             "log_level": self.log_level,
    #             "cmdb_connection_string": self.cmdb_connection_string,
    #             "project_database_path": self.project_database_path,
    #         }


dataclass
class RuntimeAction
    #     """Represents an IDE action to be validated"""

    #     action_type: RuntimeActionType
    #     buffer_id: str
    file_path: Optional[str] = None
    content: Optional[str] = None
    cursor_position: Optional[Tuple[int, int]] = None
    selection: Optional[Tuple[int, int]] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    action_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "actionId": self.action_id,
    #             "actionType": self.action_type.value,
    #             "bufferId": self.buffer_id,
    #             "filePath": self.file_path,
    #             "content": self.content,
    #             "cursorPosition": self.cursor_position,
    #             "selection": self.selection,
    #             "metadata": self.metadata,
    #             "timestamp": self.timestamp,
    #         }


dataclass
class RuntimeResult
    #     """Result of runtime validation"""

    #     action_id: str
    #     success: bool
    syntax_result: Optional[ValidationResult] = None
    linter_result: Optional[ValidationResponse] = None
    ai_guard_result: Optional[GuardResult] = None
    parse_result: Optional[ParseResult] = None
    compliance_record: Optional[ComplianceRecord] = None
    execution_time_ms: int = 0
    error_message: Optional[str] = None
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "actionId": self.action_id,
    #             "success": self.success,
    #             "syntaxResult": self.syntax_result.to_dict() if self.syntax_result else None,
    #             "linterResult": self.linter_result.to_dict() if self.linter_result else None,
    #             "aiGuardResult": self.ai_guard_result.to_dict() if self.ai_guard_result else None,
    #             "parseResult": self.parse_result.to_dict() if self.parse_result else None,
    #             "complianceRecord": self.compliance_record.to_dict() if self.compliance_record else None,
    #             "executionTimeMs": self.execution_time_ms,
    #             "errorMessage": self.error_message,
    #             "timestamp": self.timestamp,
    #         }


class RuntimeError(Exception)
    #     """Exception raised by the IDE runtime"""

    #     def __init__(self, message: str, code: int = 2001, details: Optional[Dict[str, Any]] = None):
    self.message = message
    self.code = code
    self.details = details or {}
            super().__init__(self.message)

    #     def __str__(self):
    #         return f"RuntimeError[{self.code}]: {self.message}"


class BufferManager
    #     """Manages IDE buffers and their state"""

    #     def __init__(self):""Initialize the buffer manager"""
    self.buffers: Dict[str, Dict[str, Any]] = {}
    self.logger = logging.getLogger("noodlecore.ide.buffer_manager")
    self._lock = threading.RLock()

    #     def create_buffer(self, buffer_id: str, file_path: Optional[str] = None) -bool):
    #         """Create a new buffer"""
    #         with self._lock:
    #             if buffer_id in self.buffers:
                    self.logger.warning(f"Buffer {buffer_id} already exists")
    #                 return False

    self.buffers[buffer_id] = {
    #                 "id": buffer_id,
    #                 "file_path": file_path,
    #                 "content": "",
                    "last_modified": time.time(),
    #                 "is_noodlecore": False,
    #                 "has_external_fragments": False,
    #                 "ai_interventions": [],
    #                 "validation_results": [],
    #             }

                self.logger.info(f"Created buffer {buffer_id}")
    #             return True

    #     def update_buffer(self, buffer_id: str, content: str) -bool):
    #         """Update buffer content"""
    #         with self._lock:
    #             if buffer_id not in self.buffers:
                    self.logger.warning(f"Buffer {buffer_id} does not exist")
    #                 return False

    self.buffers[buffer_id]["content"] = content
    self.buffers[buffer_id]["last_modified"] = time.time()

    #             # Check if content has NoodleCore syntax
    self.buffers[buffer_id]["is_noodlecore"] = self._is_noodlecore_content(content)

    #             # Check for external code fragments
    self.buffers[buffer_id]["has_external_fragments"] = self._has_external_fragments(content)

                self.logger.debug(f"Updated buffer {buffer_id}")
    #             return True

    #     def get_buffer(self, buffer_id: str) -Optional[Dict[str, Any]]):
    #         """Get buffer information"""
    #         with self._lock:
                return self.buffers.get(buffer_id)

    #     def delete_buffer(self, buffer_id: str) -bool):
    #         """Delete a buffer"""
    #         with self._lock:
    #             if buffer_id not in self.buffers:
                    self.logger.warning(f"Buffer {buffer_id} does not exist")
    #                 return False

    #             del self.buffers[buffer_id]
                self.logger.info(f"Deleted buffer {buffer_id}")
    #             return True

    #     def add_ai_intervention(self, buffer_id: str, intervention: Dict[str, Any]) -bool):
    #         """Add an AI intervention record"""
    #         with self._lock:
    #             if buffer_id not in self.buffers:
                    self.logger.warning(f"Buffer {buffer_id} does not exist")
    #                 return False

                self.buffers[buffer_id]["ai_interventions"].append(intervention)
                self.logger.debug(f"Added AI intervention to buffer {buffer_id}")
    #             return True

    #     def add_validation_result(self, buffer_id: str, result: RuntimeResult) -bool):
    #         """Add a validation result"""
    #         with self._lock:
    #             if buffer_id not in self.buffers:
                    self.logger.warning(f"Buffer {buffer_id} does not exist")
    #                 return False

                self.buffers[buffer_id]["validation_results"].append(result)
                self.logger.debug(f"Added validation result to buffer {buffer_id}")
    #             return True

    #     def _is_noodlecore_content(self, content: str) -bool):
    #         """Check if content contains NoodleCore syntax"""
    #         # Simple heuristic: check for NoodleCore keywords or file extension
    noodlecore_keywords = ["func", "let", "var", "if", "else", "for", "while", "return"]
    content_lower = content.lower()

    #         # Check for keywords
    #         for keyword in noodlecore_keywords:
    #             if keyword in content_lower:
    #                 return True

    #         # Check for NoodleCore file extension in comments
    #         if "// .nc" in content or "# .nc" in content:
    #             return True

    #         return False

    #     def _has_external_fragments(self, content: str) -bool):
    #         """Check if content contains external code fragments"""
    #         # Look for patterns that suggest external code fragments
    external_patterns = [
    #             "```",  # Code blocks
    #             "<script",  # Script tags
    #             "import ",  # Import statements
                "require(",  # Require statements
    #             "include ",  # Include statements
    #         ]

    #         for pattern in external_patterns:
    #             if pattern in content:
    #                 return True

    #         return False


class ActionValidator
    #     """Validates IDE actions"""

    #     def __init__(self, config: RuntimeConfig):""Initialize the action validator"""
    self.config = config
    self.logger = logging.getLogger("noodlecore.ide.action_validator")

    #     def validate_action(self, action: RuntimeAction, buffer_info: Dict[str, Any]) -bool):
    #         """
    #         Validate an action based on buffer state

    #         Args:
    #             action: The action to validate
    #             buffer_info: Buffer information

    #         Returns:
    #             bool: True if action is valid for validation
    #         """
    #         # Check if buffer has NoodleCore syntax
    #         if not buffer_info.get("is_noodlecore", False):
    #             self.logger.debug(f"Skipping validation for non-NoodleCore buffer {action.buffer_id}")
    #             return False

    #         # Check action type
    #         if action.action_type == RuntimeActionType.BUFFER_CHANGE:
    #             return True
    #         elif action.action_type == RuntimeActionType.BUFFER_SAVE:
    #             return True
    #         elif action.action_type == RuntimeActionType.AI_INTERVENTION:
    #             return True
    #         elif action.action_type == RuntimeActionType.EXTERNAL_FRAGMENT:
    #             return True

    #         return False


class ValidationPipeline
    #     """Pipeline for coordinating all validation components"""

    #     def __init__(self, config: RuntimeConfig):""Initialize the validation pipeline"""
    self.config = config

    #         # Initialize validation components
    #         self.syntax_validator = SyntaxValidator() if config.enable_syntax_validation else None
    #         self.linter_bridge = LinterBridge() if config.enable_semantic_validation else None
    #         self.ai_guard = AIGuard() if config.enable_ai_guard else None
    #         self.compiler_frontend = CompilerFrontend() if config.enable_syntax_validation else None
    #         self.compliance_tracker = ComplianceTracker() if config.enable_compliance_tracking else None

    self.logger = logging.getLogger("noodlecore.ide.validation_pipeline")

    #     def validate(self, action: RuntimeAction, content: str, file_path: Optional[str] = None) -RuntimeResult):
    #         """
    #         Run the full validation pipeline

    #         Args:
    #             action: The action being validated
    #             content: The content to validate
    #             file_path: Optional file path

    #         Returns:
    #             RuntimeResult: Combined validation results
    #         """
    start_time = time.time()
    result = RuntimeResult(action_id=action.action_id, success=False)

    #         try:
    #             self.logger.info(f"Starting validation pipeline for action {action.action_id}")

    #             # Step 1: Parse the code
    #             if self.compiler_frontend:
    parse_result = self.compiler_frontend.parse(content, file_path)
    result.parse_result = parse_result

    #                 if not parse_result.success:
    result.error_message = "Parsing failed"
    #                     self.logger.warning(f"Parsing failed for action {action.action_id}")
    #                     return result

    #             # Step 2: Syntax validation
    #             if self.syntax_validator:
    syntax_result = self.syntax_validator.validate(content, GuardMode.ADAPTIVE, file_path)
    result.syntax_result = syntax_result

    #                 if not syntax_result.is_valid:
    result.error_message = "Syntax validation failed"
    #                     self.logger.warning(f"Syntax validation failed for action {action.action_id}")

    #             # Step 3: Linter validation
    #             if self.linter_bridge:
    linter_result = self.linter_bridge.validate(content, GuardMode.ADAPTIVE, file_path)
    result.linter_result = linter_result

    #                 if not linter_result.success:
    result.error_message = "Linter validation failed"
    #                     self.logger.warning(f"Linter validation failed for action {action.action_id}")

    #             # Step 4: AI guard validation
    #             if self.ai_guard:
    ai_guard_result = self.ai_guard.validate(content, GuardMode.ADAPTIVE)
    result.ai_guard_result = ai_guard_result

    #                 if not ai_guard_result.success:
    result.error_message = "AI guard validation failed"
    #                     self.logger.warning(f"AI guard validation failed for action {action.action_id}")

    #             # Step 5: Compliance tracking
    #             if self.compliance_tracker and result.ai_guard_result:
    compliance_record = self.compliance_tracker.track_validation(
    #                     result.ai_guard_result,
    #                     "ide_runtime",
    #                     {"action_id": action.action_id, "action_type": action.action_type.value}
    #                 )
    result.compliance_record = compliance_record

    #             # Determine overall success
    result.success = (
                    (result.parse_result is None or result.parse_result.success) and
                    (result.syntax_result is None or result.syntax_result.is_valid) and
                    (result.linter_result is None or result.linter_result.success) and
                    (result.ai_guard_result is None or result.ai_guard_result.success)
    #             )

    #             if result.success:
    #                 self.logger.info(f"Validation successful for action {action.action_id}")

    #         except Exception as e:
    result.error_message = f"Validation pipeline error: {str(e)}"
    #             self.logger.error(f"Validation pipeline error for action {action.action_id}: {str(e)}")

    #         # Calculate execution time
    result.execution_time_ms = int((time.time() - start_time) * 1000)

    #         return result


class RuntimeLogger
    #     """Logger for IDE runtime events"""

    #     def __init__(self, config: RuntimeConfig):""Initialize the runtime logger"""
    self.config = config
    self.logger = self._setup_logging()
    self._log_buffer = []
    self._buffer_lock = threading.Lock()

    #     def _setup_logging(self) -logging.Logger):
    #         """Setup logging for the runtime"""
    logger = logging.getLogger("noodlecore.ide.runtime")
            logger.setLevel(getattr(logging, self.config.log_level.upper()))

    #         # Create formatter
    formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #         )

    #         # Create console handler
    console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            logger.addHandler(console_handler)

    #         # Create file handler if configured
    #         if self.config.project_database_path:
    log_file = os.path.join(self.config.project_database_path, "ide_runtime.log")
    file_handler = logging.FileHandler(log_file)
                file_handler.setFormatter(formatter)
                logger.addHandler(file_handler)

    #         return logger

    #     def log_action(self, action: RuntimeAction, result: RuntimeResult):
    #         """Log an action and its result"""
    log_entry = {
                "action": action.to_dict(),
                "result": result.to_dict(),
                "timestamp": time.time(),
    #         }

    #         with self._buffer_lock:
                self._log_buffer.append(log_entry)

    #             # Keep buffer size limited
    #             if len(self._log_buffer) 1000):
                    self._log_buffer.pop(0)

    #         # Log to standard logger
    #         if result.success:
                self.logger.info(f"Action {action.action_id} ({action.action_type.value}) succeeded")
    #         else:
                self.logger.error(f"Action {action.action_id} ({action.action_type.value}) failed: {result.error_message}")

    #     def get_log_entries(self, limit: int = 100) -List[Dict[str, Any]]):
    #         """Get recent log entries"""
    #         with self._buffer_lock:
    #             return self._log_buffer[-limit:]

    #     def export_logs(self, file_path: str):
    #         """Export logs to a file"""
    #         import json

    #         with self._buffer_lock:
    logs = self._log_buffer.copy()

    #         with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(logs, f, indent = 2)

            self.logger.info(f"Exported {len(logs)} log entries to {file_path}")


class IDERuntime
    #     """
    #     Main IDE runtime integration class

    #     This class provides the main integration point for IDE validation,
    #     coordinating all validation components and managing the validation pipeline.
    #     """

    #     def __init__(self, config: Optional[RuntimeConfig] = None):""Initialize the IDE runtime"""
    self.config = config or RuntimeConfig()
    self.status = RuntimeStatus.INITIALIZING

    #         # Initialize components
    self.buffer_manager = BufferManager()
    self.action_validator = ActionValidator(self.config)
    self.validation_pipeline = ValidationPipeline(self.config)
    self.runtime_logger = RuntimeLogger(self.config)

    #         # Thread safety
    self._lock = threading.RLock()

    #         # Statistics
    self.stats = {
    #             "total_actions": 0,
    #             "validated_actions": 0,
    #             "successful_validations": 0,
    #             "failed_validations": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Event callbacks
    self._action_callbacks: List[Callable] = []

    self.status = RuntimeStatus.READY
            self.runtime_logger.logger.info("IDE runtime initialized")

    #     def process_action(self, action: RuntimeAction) -RuntimeResult):
    #         """
    #         Process an IDE action through the validation pipeline

    #         Args:
    #             action: The action to process

    #         Returns:
    #             RuntimeResult: Result of the validation
    #         """
    #         with self._lock:
    self.stats["total_actions"] + = 1

    #             try:
                    self.runtime_logger.logger.info(f"Processing action {action.action_id} ({action.action_type.value})")

    #                 # Get buffer information
    buffer_info = self.buffer_manager.get_buffer(action.buffer_id)
    #                 if not buffer_info:
                        raise RuntimeError(f"Buffer {action.buffer_id} not found", 2002)

    #                 # Update buffer if content is provided
    #                 if action.content is not None:
                        self.buffer_manager.update_buffer(action.buffer_id, action.content)
    buffer_info = self.buffer_manager.get_buffer(action.buffer_id)

    #                 # Validate action
    #                 if not self.action_validator.validate_action(action, buffer_info):
                        self.runtime_logger.logger.debug(f"Action {action.action_id} skipped validation")
    return RuntimeResult(action_id = action.action_id, success=True)

    #                 # Run validation pipeline
    content = buffer_info.get("content", "")
    file_path = buffer_info.get("file_path")

    result = self.validation_pipeline.validate(action, content, file_path)

    #                 # Store result in buffer
                    self.buffer_manager.add_validation_result(action.buffer_id, result)

    #                 # Update statistics
    self.stats["validated_actions"] + = 1
    self.stats["total_time_ms"] + = result.execution_time_ms

    #                 if result.success:
    self.stats["successful_validations"] + = 1
    #                 else:
    self.stats["failed_validations"] + = 1

    #                 # Log the action and result
                    self.runtime_logger.log_action(action, result)

    #                 # Trigger callbacks
                    self._trigger_action_callbacks(action, result)

    #                 return result

    #             except Exception as e:
    error_result = RuntimeResult(
    action_id = action.action_id,
    success = False,
    error_message = str(e)
    #                 )

    self.stats["failed_validations"] + = 1
                    self.runtime_logger.log_action(action, error_result)

    #                 return error_result

    #     def register_buffer(self, buffer_id: str, file_path: Optional[str] = None) -bool):
    #         """
    #         Register a new buffer with the runtime

    #         Args:
    #             buffer_id: Unique buffer identifier
    #             file_path: Optional file path

    #         Returns:
    #             bool: True if buffer was registered successfully
    #         """
            return self.buffer_manager.create_buffer(buffer_id, file_path)

    #     def unregister_buffer(self, buffer_id: str) -bool):
    #         """
    #         Unregister a buffer from the runtime

    #         Args:
    #             buffer_id: Buffer identifier

    #         Returns:
    #             bool: True if buffer was unregistered successfully
    #         """
            return self.buffer_manager.delete_buffer(buffer_id)

    #     def get_buffer_info(self, buffer_id: str) -Optional[Dict[str, Any]]):
    #         """
    #         Get information about a buffer

    #         Args:
    #             buffer_id: Buffer identifier

    #         Returns:
    #             Dict containing buffer information or None if not found
    #         """
            return self.buffer_manager.get_buffer(buffer_id)

    #     def get_buffer_validation_history(self, buffer_id: str, limit: int = 10) -List[RuntimeResult]):
    #         """
    #         Get validation history for a buffer

    #         Args:
    #             buffer_id: Buffer identifier
    #             limit: Maximum number of results to return

    #         Returns:
    #             List of validation results
    #         """
    buffer_info = self.buffer_manager.get_buffer(buffer_id)
    #         if not buffer_info:
    #             return []

    validation_results = buffer_info.get("validation_results", [])
    #         return validation_results[-limit:]

    #     def add_action_callback(self, callback: Callable[[RuntimeAction, RuntimeResult], None]):
    #         """
    #         Add a callback for action processing

    #         Args:
    #             callback: Callback function that receives action and result
    #         """
            self._action_callbacks.append(callback)
            self.runtime_logger.logger.info("Action callback registered")

    #     def remove_action_callback(self, callback: Callable[[RuntimeAction, RuntimeResult], None]):
    #         """
    #         Remove an action callback

    #         Args:
    #             callback: Callback function to remove
    #         """
    #         if callback in self._action_callbacks:
                self._action_callbacks.remove(callback)
                self.runtime_logger.logger.info("Action callback removed")

    #     def _trigger_action_callbacks(self, action: RuntimeAction, result: RuntimeResult):
    #         """Trigger all registered action callbacks"""
    #         for callback in self._action_callbacks:
    #             try:
                    callback(action, result)
    #             except Exception as e:
                    self.runtime_logger.logger.error(f"Action callback error: {str(e)}")

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get runtime statistics"""
    #         with self._lock:
    #             return {
    #                 "status": self.status.value,
    #                 "total_actions": self.stats["total_actions"],
    #                 "validated_actions": self.stats["validated_actions"],
    #                 "successful_validations": self.stats["successful_validations"],
    #                 "failed_validations": self.stats["failed_validations"],
                    "validation_rate": (
    #                     self.stats["validated_actions"] / self.stats["total_actions"]
    #                     if self.stats["total_actions"] 0 else 0
    #                 ),
                    "success_rate"): (
    #                     self.stats["successful_validations"] / self.stats["validated_actions"]
    #                     if self.stats["validated_actions"] 0 else 0
    #                 ),
    #                 "total_time_ms"): self.stats["total_time_ms"],
                    "average_time_ms": (
    #                     self.stats["total_time_ms"] / self.stats["validated_actions"]
    #                     if self.stats["validated_actions"] 0 else 0
    #                 ),
                    "buffer_count"): len(self.buffer_manager.buffers),
                    "config": self.config.to_dict(),
    #             }

    #     def export_logs(self, file_path: str):
    #         """Export runtime logs to a file"""
            self.runtime_logger.export_logs(file_path)

    #     def shutdown(self):
    #         """Shutdown the runtime"""
    self.status = RuntimeStatus.SHUTTING_DOWN
            self.runtime_logger.logger.info("IDE runtime shutting down")

    #         # Export logs if configured
    #         if self.config.auto_save_validation_results and self.config.project_database_path:
    log_file = os.path.join(self.config.project_database_path, "ide_runtime_logs.json")
                self.export_logs(log_file)

    self.status = RuntimeStatus.SHUTTING_DOWN
            self.runtime_logger.logger.info("IDE runtime shutdown complete")


# Global runtime instance
_runtime_instance: Optional[IDERuntime] = None
_runtime_lock = threading.Lock()


def get_runtime(config: Optional[RuntimeConfig] = None) -IDERuntime):
#     """
#     Get the global IDE runtime instance

#     Args:
#         config: Optional configuration

#     Returns:
#         IDERuntime: The runtime instance
#     """
#     global _runtime_instance

#     with _runtime_lock:
#         if _runtime_instance is None:
_runtime_instance = IDERuntime(config)
#         elif config is not None:
#             # Update configuration if provided
_runtime_instance.config = config

#         return _runtime_instance


def process_action(
#     action_type: RuntimeActionType,
#     buffer_id: str,
content: Optional[str] = None,
file_path: Optional[str] = None,
cursor_position: Optional[Tuple[int, int]] = None,
selection: Optional[Tuple[int, int]] = None,
metadata: Optional[Dict[str, Any]] = None
# ) -RuntimeResult):
#     """
#     Convenience function to process an action

#     Args:
#         action_type: Type of action
#         buffer_id: Buffer identifier
#         content: Optional buffer content
#         file_path: Optional file path
#         cursor_position: Optional cursor position
#         selection: Optional selection
#         metadata: Optional metadata

#     Returns:
#         RuntimeResult: Result of the validation
#     """
runtime = get_runtime()

action = RuntimeAction(
action_type = action_type,
buffer_id = buffer_id,
file_path = file_path,
content = content,
cursor_position = cursor_position,
selection = selection,
metadata = metadata or {}
#     )

    return runtime.process_action(action)