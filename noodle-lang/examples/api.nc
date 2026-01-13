# Converted from Python to NoodleCore
# Original file: src

# """
# Linter API for NoodleCore Integration
# --------------------------------------
# This module provides the API for integrating the NoodleCore linter with
# other components, including IDE integration, AI guard integration, and
# real-time validation.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import json
import os
import time
import uuid
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

import .linter.NoodleLinter
import .syntax_checker.SyntaxChecker
import .semantic_analyzer.SemanticAnalyzer
import .validation_rules.ValidationRules


class IntegrationMode(Enum)
    #     """Integration modes for the linter API"""
    IDE = "ide"  # For IDE integration
    AI_GUARD = "ai_guard"  # For AI guard integration
    CLI = "cli"  # For command-line interface
    WEB_API = "web_api"  # For web API integration
    BATCH = "batch"  # For batch processing


dataclass
class LinterAPIConfig
    #     """Configuration for the linter API"""

    integration_mode: IntegrationMode = IntegrationMode.IDE
    enable_real_time: bool = True
    enable_caching: bool = True
    max_concurrent_requests: int = 10
    request_timeout_ms: int = 5000
    enable_statistics: bool = True
    enable_diagnostics: bool = True
    output_format: str = "json"  # json, xml, text
    log_level: str = "INFO"
    log_file: Optional[str] = None

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert config to dictionary"""
    #         return {
    #             "integration_mode": self.integration_mode.value,
    #             "enable_real_time": self.enable_real_time,
    #             "enable_caching": self.enable_caching,
    #             "max_concurrent_requests": self.max_concurrent_requests,
    #             "request_timeout_ms": self.request_timeout_ms,
    #             "enable_statistics": self.enable_statistics,
    #             "enable_diagnostics": self.enable_diagnostics,
    #             "output_format": self.output_format,
    #             "log_level": self.log_level,
    #             "log_file": self.log_file,
    #         }


dataclass
class LintRequest
    #     """Represents a lint request"""

    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    source_code: Optional[str] = None
    file_path: Optional[str] = None
    config: Optional[LinterConfig] = None
    mode: LinterMode = LinterMode.REAL_TIME
    timestamp: float = field(default_factory=time.time)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert request to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "sourceCode": self.source_code,
    #             "filePath": self.file_path,
    #             "mode": self.mode.value,
    #             "timestamp": self.timestamp,
    #             "config": self.config.to_dict() if self.config else None,
    #         }


dataclass
class LintResponse
    #     """Represents a lint response"""

    #     request_id: str
    #     success: bool
    result: Optional[LinterResult] = None
    error_message: Optional[str] = None
    processing_time_ms: int = 0
    timestamp: float = field(default_factory=time.time)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert response to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "success": self.success,
    #             "result": self.result.to_dict() if self.result else None,
    #             "errorMessage": self.error_message,
    #             "processingTimeMs": self.processing_time_ms,
    #             "timestamp": self.timestamp,
    #         }


class LinterAPI
    #     """
    #     API for the NoodleCore linter

    #     This class provides a high-level API for integrating the NoodleCore linter
    #     with other components, including IDE integration, AI guard integration,
    #     and real-time validation.
    #     """

    #     def __init__(self, config: Optional[LinterAPIConfig] = None):""Initialize the linter API"""
    self.config = config or LinterAPIConfig()
    self.linter = NoodleLinter()
    self.request_handlers: Dict[str, Callable] = {}
    self.active_requests: Dict[str, LintRequest] = {}
    self.statistics = {
    #             "requests_processed": 0,
    #             "total_processing_time_ms": 0,
    #             "average_processing_time_ms": 0,
    #             "errors": 0,
    #             "cache_hits": 0,
    #         }

    #         # Initialize request handlers
            self._initialize_request_handlers()

    #     def _initialize_request_handlers(self):
    #         """Initialize request handlers"""
    self.request_handlers = {
    #             "lint_file": self._handle_lint_file,
    #             "lint_source": self._handle_lint_source,
    #             "lint_directory": self._handle_lint_directory,
    #             "get_statistics": self._handle_get_statistics,
    #             "clear_cache": self._handle_clear_cache,
    #             "configure": self._handle_configure,
    #         }

    #     def process_request(self, request_type: str, request_data: Dict[str, Any]) -LintResponse):
    #         """
    #         Process a linter request

    #         Args:
                request_type: Type of request (lint_file, lint_source, etc.)
    #             request_data: Request data

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    start_time = time.time()
    request_id = request_data.get("requestId", str(uuid.uuid4()))

    #         try:
    #             # Get the request handler
    handler = self.request_handlers.get(request_type)
    #             if not handler:
                    return LintResponse(
    request_id = request_id,
    success = False,
    error_message = f"Unknown request type: {request_type}",
    #                 )

    #             # Process the request
    result = handler(request_data)

    #             # Update statistics
    processing_time = int((time.time() - start_time) * 1000)
    self.statistics["requests_processed"] + = 1
    self.statistics["total_processing_time_ms"] + = processing_time
    self.statistics["average_processing_time_ms"] = (
    #                 self.statistics["total_processing_time_ms"] / self.statistics["requests_processed"]
    #             )

                return LintResponse(
    request_id = request_id,
    success = True,
    result = result,
    processing_time_ms = processing_time,
    #             )

    #         except Exception as e:
    self.statistics["errors"] + = 1
                return LintResponse(
    request_id = request_id,
    success = False,
    error_message = str(e),
    processing_time_ms = int((time.time() - start_time) * 1000,)
    #             )

    #     def _handle_lint_file(self, request_data: Dict[str, Any]) -LinterResult):
    #         """Handle a lint file request"""
    file_path = request_data.get("filePath")
    #         if not file_path:
                raise ValueError("File path is required")

    #         # Get configuration from request
    config_data = request_data.get("config")
    #         if config_data:
    config = LinterConfig(
    mode = LinterMode(config_data.get("mode", LinterMode.REAL_TIME.value)),
    enable_syntax_check = config_data.get("enable_syntax_check", True),
    enable_semantic_check = config_data.get("enable_semantic_check", True),
    enable_validation_rules = config_data.get("enable_validation_rules", True),
    enable_forbidden_structure_check = config_data.get("enable_forbidden_structure_check", True),
    max_errors = config_data.get("max_errors", 100),
    max_warnings = config_data.get("max_warnings", 50),
    timeout_ms = config_data.get("timeout_ms", 5000),
    cache_enabled = config_data.get("cache_enabled", True),
    strict_mode = config_data.get("strict_mode", False),
    custom_rules = config_data.get("custom_rules", []),
    disabled_rules = set(config_data.get("disabled_rules", [])),
    disabled_categories = set(config_data.get("disabled_categories", [])),
    #             )
    self.linter.config = config

            return self.linter.lint_file(file_path)

    #     def _handle_lint_source(self, request_data: Dict[str, Any]) -LinterResult):
    #         """Handle a lint source request"""
    source_code = request_data.get("sourceCode")
    #         if not source_code:
                raise ValueError("Source code is required")

    file_path = request_data.get("filePath")

    #         # Get configuration from request
    config_data = request_data.get("config")
    #         if config_data:
    config = LinterConfig(
    mode = LinterMode(config_data.get("mode", LinterMode.REAL_TIME.value)),
    enable_syntax_check = config_data.get("enable_syntax_check", True),
    enable_semantic_check = config_data.get("enable_semantic_check", True),
    enable_validation_rules = config_data.get("enable_validation_rules", True),
    enable_forbidden_structure_check = config_data.get("enable_forbidden_structure_check", True),
    max_errors = config_data.get("max_errors", 100),
    max_warnings = config_data.get("max_warnings", 50),
    timeout_ms = config_data.get("timeout_ms", 5000),
    cache_enabled = config_data.get("cache_enabled", True),
    strict_mode = config_data.get("strict_mode", False),
    custom_rules = config_data.get("custom_rules", []),
    disabled_rules = set(config_data.get("disabled_rules", [])),
    disabled_categories = set(config_data.get("disabled_categories", [])),
    #             )
    self.linter.config = config

            return self.linter.lint_source(source_code, file_path)

    #     def _handle_lint_directory(self, request_data: Dict[str, Any]) -List[LinterResult]):
    #         """Handle a lint directory request"""
    directory_path = request_data.get("directoryPath")
    #         if not directory_path:
                raise ValueError("Directory path is required")

    pattern = request_data.get("pattern", "*.nc")

            return self.linter.lint_directory(directory_path, pattern)

    #     def _handle_get_statistics(self, request_data: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle a get statistics request"""
    linter_stats = self.linter.get_statistics()
    api_stats = self.statistics.copy()

    #         return {
    #             "linter": linter_stats,
    #             "api": api_stats,
    #         }

    #     def _handle_clear_cache(self, request_data: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle a clear cache request"""
            self.linter.clear_cache()
    #         return {"success": True, "message": "Cache cleared"}

    #     def _handle_configure(self, request_data: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle a configure request"""
    config_data = request_data.get("config")
    #         if not config_data:
                raise ValueError("Configuration is required")

    #         # Update API configuration
    #         if "integration_mode" in config_data:
    self.config.integration_mode = IntegrationMode(config_data["integration_mode"])
    #         if "enable_real_time" in config_data:
    self.config.enable_real_time = config_data["enable_real_time"]
    #         if "enable_caching" in config_data:
    self.config.enable_caching = config_data["enable_caching"]
    #         if "max_concurrent_requests" in config_data:
    self.config.max_concurrent_requests = config_data["max_concurrent_requests"]
    #         if "request_timeout_ms" in config_data:
    self.config.request_timeout_ms = config_data["request_timeout_ms"]
    #         if "enable_statistics" in config_data:
    self.config.enable_statistics = config_data["enable_statistics"]
    #         if "enable_diagnostics" in config_data:
    self.config.enable_diagnostics = config_data["enable_diagnostics"]
    #         if "output_format" in config_data:
    self.config.output_format = config_data["output_format"]
    #         if "log_level" in config_data:
    self.config.log_level = config_data["log_level"]
    #         if "log_file" in config_data:
    self.config.log_file = config_data["log_file"]

    #         # Update linter configuration
    linter_config_data = config_data.get("linter")
    #         if linter_config_data:
    linter_config = LinterConfig(
    mode = LinterMode(linter_config_data.get("mode", LinterMode.REAL_TIME.value)),
    enable_syntax_check = linter_config_data.get("enable_syntax_check", True),
    enable_semantic_check = linter_config_data.get("enable_semantic_check", True),
    enable_validation_rules = linter_config_data.get("enable_validation_rules", True),
    enable_forbidden_structure_check = linter_config_data.get("enable_forbidden_structure_check", True),
    max_errors = linter_config_data.get("max_errors", 100),
    max_warnings = linter_config_data.get("max_warnings", 50),
    timeout_ms = linter_config_data.get("timeout_ms", 5000),
    cache_enabled = linter_config_data.get("cache_enabled", True),
    strict_mode = linter_config_data.get("strict_mode", False),
    custom_rules = linter_config_data.get("custom_rules", []),
    disabled_rules = set(linter_config_data.get("disabled_rules", [])),
    disabled_categories = set(linter_config_data.get("disabled_categories", [])),
    #             )
    self.linter.config = linter_config

    #         return {"success": True, "message": "Configuration updated"}

    #     def lint_file(self, file_path: str, config: Optional[LinterConfig] = None) -LintResponse):
    #         """
    #         Lint a file

    #         Args:
    #             file_path: Path to the file to lint
    #             config: Optional linter configuration

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    request_data = {
                "requestId": str(uuid.uuid4()),
    #             "filePath": file_path,
    #             "config": config.to_dict() if config else None,
    #         }

            return self.process_request("lint_file", request_data)

    #     def lint_source(self, source_code: str, file_path: Optional[str] = None, config: Optional[LinterConfig] = None) -LintResponse):
    #         """
    #         Lint source code

    #         Args:
    #             source_code: Source code to lint
    #             file_path: Optional file path for error reporting
    #             config: Optional linter configuration

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    request_data = {
                "requestId": str(uuid.uuid4()),
    #             "sourceCode": source_code,
    #             "filePath": file_path,
    #             "config": config.to_dict() if config else None,
    #         }

            return self.process_request("lint_source", request_data)

    #     def lint_directory(self, directory_path: str, pattern: str = "*.nc", config: Optional[LinterConfig] = None) -LintResponse):
    #         """
    #         Lint all files in a directory

    #         Args:
    #             directory_path: Path to the directory
    #             pattern: File pattern to match
    #             config: Optional linter configuration

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    request_data = {
                "requestId": str(uuid.uuid4()),
    #             "directoryPath": directory_path,
    #             "pattern": pattern,
    #             "config": config.to_dict() if config else None,
    #         }

            return self.process_request("lint_directory", request_data)

    #     def get_statistics(self) -LintResponse):
    #         """
    #         Get linter statistics

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    request_data = {
                "requestId": str(uuid.uuid4()),
    #         }

            return self.process_request("get_statistics", request_data)

    #     def clear_cache(self) -LintResponse):
    #         """
    #         Clear the linter cache

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    request_data = {
                "requestId": str(uuid.uuid4()),
    #         }

            return self.process_request("clear_cache", request_data)

    #     def configure(self, config: Dict[str, Any]) -LintResponse):
    #         """
    #         Configure the linter

    #         Args:
    #             config: Configuration data

    #         Returns:
    #             LintResponse: Response to the request
    #         """
    request_data = {
                "requestId": str(uuid.uuid4()),
    #             "config": config,
    #         }

            return self.process_request("configure", request_data)

    #     def to_json(self, response: LintResponse) -str):
    #         """
    #         Convert a response to JSON

    #         Args:
    #             response: Response to convert

    #         Returns:
    #             str: JSON representation of the response
    #         """
    return json.dumps(response.to_dict(), indent = 2)

    #     def from_json(self, json_str: str) -LintResponse):
    #         """
    #         Convert JSON to a response

    #         Args:
    #             json_str: JSON string to convert

    #         Returns:
    #             LintResponse: Response from JSON
    #         """
    data = json.loads(json_str)

    #         # Convert result to LinterResult if present
    result = None
    #         if data.get("result"):
    result_data = data["result"]
    result = LinterResult(
    success = result_data["success"],
    errors = [
                        LinterError(
    code = error["code"],
    message = error["message"],
    severity = error["severity"],
    category = error["category"],
    line = error.get("line"),
    column = error.get("column"),
    file = error.get("file"),
    suggestion = error.get("suggestion"),
    related_info = error.get("related_info", []),
    #                     )
    #                     for error in result_data.get("errors", [])
    #                 ],
    warnings = [
                        LinterError(
    code = warning["code"],
    message = warning["message"],
    severity = warning["severity"],
    category = warning["category"],
    line = warning.get("line"),
    column = warning.get("column"),
    file = warning.get("file"),
    suggestion = warning.get("suggestion"),
    related_info = warning.get("related_info", []),
    #                     )
    #                     for warning in result_data.get("warnings", [])
    #                 ],
    infos = [
                        LinterError(
    code = info["code"],
    message = info["message"],
    severity = info["severity"],
    category = info["category"],
    line = info.get("line"),
    column = info.get("column"),
    file = info.get("file"),
    suggestion = info.get("suggestion"),
    related_info = info.get("related_info", []),
    #                     )
    #                     for info in result_data.get("infos", [])
    #                 ],
    execution_time_ms = result_data.get("execution_time_ms", 0),
    request_id = result_data.get("requestId", ""),
    #             )

            return LintResponse(
    request_id = data["requestId"],
    success = data["success"],
    result = result,
    error_message = data.get("errorMessage"),
    processing_time_ms = data.get("processingTimeMs", 0),
    timestamp = data.get("timestamp", time.time()),
    #         )


# Convenience function for creating a linter API
def create_linter_api(config: Optional[LinterAPIConfig] = None) -LinterAPI):
#     """
#     Create a linter API instance

#     Args:
#         config: Optional API configuration

#     Returns:
#         LinterAPI: Linter API instance
#     """
    return LinterAPI(config)


# Convenience function for IDE integration
def create_ide_linter() -LinterAPI):
#     """
#     Create a linter API instance configured for IDE integration

#     Returns:
#         LinterAPI: Linter API instance
#     """
config = LinterAPIConfig(
integration_mode = IntegrationMode.IDE,
enable_real_time = True,
enable_caching = True,
max_concurrent_requests = 5,
request_timeout_ms = 1000,
enable_statistics = True,
enable_diagnostics = True,
output_format = "json",
#     )

    return LinterAPI(config)


# Convenience function for AI guard integration
def create_ai_guard_linter() -LinterAPI):
#     """
#     Create a linter API instance configured for AI guard integration

#     Returns:
#         LinterAPI: Linter API instance
#     """
config = LinterAPIConfig(
integration_mode = IntegrationMode.AI_GUARD,
enable_real_time = True,
enable_caching = True,
max_concurrent_requests = 10,
request_timeout_ms = 500,
enable_statistics = True,
enable_diagnostics = True,
output_format = "json",
#     )

    return LinterAPI(config)