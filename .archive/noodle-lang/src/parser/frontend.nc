# Converted from Python to NoodleCore
# Original file: src

# """
# Real-time Compiler Frontend for NoodleCore
# ------------------------------------------
# This module provides the parser and AST generator for NoodleCore with real-time parsing
# capabilities to support the AI validation system.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import sys
import time
import uuid
import hashlib
import logging
import threading
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

# Import compiler components
import .lexer_main.Lexer
import .lexer_tokens.Token
import .lexer_position.Position
import .parser.Parser
import .parser_ast_nodes.ProgramNode
import .ast_nodes.ProgramNode

# Import AI components for integration
import ..ai.guard.GuardMode
import ..ai.linter_bridge.ValidationRequest
import ..ai.syntax_validator.ValidationResult


class ParsingMode(Enum)
    #     """Modes for parsing operations"""
    FULL = "full"  # Complete parsing of entire code
    #     INCREMENTAL = "incremental"  # Incremental parsing for changes
    #     PARTIAL = "partial"  # Partial parsing for code snippets
    #     STREAMING = "streaming"  # Streaming parsing for large files


class CacheStrategy(Enum)
    #     """Strategies for AST caching"""
    NONE = "none"  # No caching
    MEMORY = "memory"  # In-memory caching
    #     LRU = "lru"  # LRU caching with size limits
    PERSISTENT = "persistent"  # Persistent caching to disk


dataclass
class FrontendConfig
    #     """Configuration for the compiler frontend"""

    parsing_mode: ParsingMode = ParsingMode.INCREMENTAL
    cache_strategy: CacheStrategy = CacheStrategy.MEMORY
    cache_size: int = 100  # Maximum number of cached ASTs
    timeout_ms: int = 5000  # 5 seconds
    enable_error_recovery: bool = True
    enable_incremental_parsing: bool = True
    enable_position_tracking: bool = True
    enable_symbol_table: bool = True
    enable_type_inference: bool = True
    max_concurrent_parsers: int = 5
    retry_attempts: int = 3
    debug_mode: bool = False

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert config to dictionary"""
    #         return {
    #             "parsing_mode": self.parsing_mode.value,
    #             "cache_strategy": self.cache_strategy.value,
    #             "cache_size": self.cache_size,
    #             "timeout_ms": self.timeout_ms,
    #             "enable_error_recovery": self.enable_error_recovery,
    #             "enable_incremental_parsing": self.enable_incremental_parsing,
    #             "enable_position_tracking": self.enable_position_tracking,
    #             "enable_symbol_table": self.enable_symbol_table,
    #             "enable_type_inference": self.enable_type_inference,
    #             "max_concurrent_parsers": self.max_concurrent_parsers,
    #             "retry_attempts": self.retry_attempts,
    #             "debug_mode": self.debug_mode,
    #         }


dataclass
class ParseRequest
    #     """Represents a parsing request"""

    #     code: str
    file_path: Optional[str] = None
    mode: ParsingMode = ParsingMode.INCREMENTAL
    metadata: Dict[str, Any] = field(default_factory=dict)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "code": self.code,
    #             "filePath": self.file_path,
    #             "mode": self.mode.value,
    #             "metadata": self.metadata,
    #             "timestamp": self.timestamp,
    #         }


dataclass
class ParseResult
    #     """Represents a parsing result"""

    #     request_id: str
    #     success: bool
    ast: Optional[ProgramNode] = None
    errors: List[ParserError] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    execution_time_ms: int = 0
    cache_hit: bool = False
    timestamp: float = field(default_factory=lambda: time.time())

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "requestId": self.request_id,
    #             "success": self.success,
    #             "ast": self.ast.to_dict() if self.ast else None,
    #             "errors": [{"message": str(e), "line": e.line_number, "column": e.column} for e in self.errors],
    #             "warnings": self.warnings,
    #             "executionTimeMs": self.execution_time_ms,
    #             "cacheHit": self.cache_hit,
    #             "timestamp": self.timestamp,
    #         }


class FrontendError(Exception)
    #     """Exception raised by the compiler frontend"""

    #     def __init__(self, message: str, code: int = 1001, details: Optional[Dict[str, Any]] = None):
    self.message = message
    self.code = code
    self.details = details or {}
            super().__init__(self.message)

    #     def __str__(self):
    #         return f"FrontendError[{self.code}]: {self.message}"


class CompilerFrontend
    #     """
    #     Real-time compiler frontend for NoodleCore

    #     This class provides the parser and AST generator for NoodleCore with real-time parsing
    #     capabilities to support the AI validation system. It processes .nc files and internal
    #     code snippets directly in memory without I/O operations.
    #     """

    #     def __init__(self, config: Optional[FrontendConfig] = None):""Initialize the compiler frontend"""
    self.config = config or FrontendConfig()

    #         # Setup logging
    self.logger = self._setup_logging()

    #         # Performance tracking
    self.stats = {
    #             "total_requests": 0,
    #             "successful_requests": 0,
    #             "failed_requests": 0,
    #             "cache_hits": 0,
    #             "total_time_ms": 0,
    #         }

    #         # Initialize cache
    self._ast_cache = {}
    self._cache_access_order = []  # For LRU eviction

    #         # Thread safety
    self._lock = threading.RLock()

    #         # Parser pool for concurrent operations
    self._parser_pool = []
    self._parser_pool_lock = threading.Lock()

    #         # Integration callbacks
    self._linter_callback: Optional[Callable] = None
    self._ai_guard_callback: Optional[Callable] = None
    self._ide_callback: Optional[Callable] = None

    #         self.logger.info(f"Compiler frontend initialized with mode: {self.config.parsing_mode.value}")

    #     def _setup_logging(self) -logging.Logger):
    #         """Setup logging for the compiler frontend"""
    logger = logging.getLogger("noodlecore.compiler.frontend")
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

    #     def parse(
    #         self,
    #         code: str,
    file_path: Optional[str] = None,
    mode: Optional[ParsingMode] = None,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -ParseResult):
    #         """
    #         Parse NoodleCore code into an AST

    #         Args:
    #             code: The code to parse
    #             file_path: Optional file path for error reporting
                mode: Parsing mode (defaults to config)
    #             metadata: Optional metadata

    #         Returns:
    #             ParseResult: Result of the parsing operation
    #         """
    start_time = time.time()

    #         # Create parse request
    request = ParseRequest(
    code = code,
    file_path = file_path,
    mode = mode or self.config.parsing_mode,
    metadata = metadata or {}
    #         )

            self.logger.info(f"Processing parse request (request_id: {request.request_id})")
    self.stats["total_requests"] + = 1

    #         try:
    #             # Check cache first
    #             cache_key = self._get_cache_key(request) if self.config.cache_strategy != CacheStrategy.NONE else None
    #             if cache_key is not None and cache_key in self._ast_cache:
    cached_result = self._ast_cache[cache_key]
                    self.logger.info(f"Using cached AST (request_id: {request.request_id})")
    self.stats["cache_hits"] + = 1

    #                 # Update LRU order
    #                 if self.config.cache_strategy == CacheStrategy.LRU:
                        self._update_lru_order(cache_key)

    cached_result.cache_hit = True
    #                 return cached_result

    #             # Get a parser from the pool
    parser = self._get_parser()

    #             try:
    #                 # Create lexer
    lexer = Lexer(code, file_path)

    #                 # Configure parser
    parser.lexer = lexer
                    parser._initialize_tokens()

    #                 # Parse based on mode
    #                 if request.mode == ParsingMode.FULL:
    ast = self._parse_full(parser)
    #                 elif request.mode == ParsingMode.INCREMENTAL:
    ast = self._parse_incremental(parser, request)
    #                 elif request.mode == ParsingMode.PARTIAL:
    ast = self._parse_partial(parser, request)
    #                 else:  # STREAMING
    ast = self._parse_streaming(parser, request)

    #                 # Create result
    result = ParseResult(
    request_id = request.request_id,
    success = True,
    ast = ast,
    errors = parser.get_errors(),
    warnings = parser.get_warnings(),
    execution_time_ms = int((time.time() - start_time) * 1000)
    #                 )

    #                 # Cache the result
    #                 if cache_key is not None:
                        self._cache_result(cache_key, result)

    #                 # Update statistics
    self.stats["successful_requests"] + = 1
    self.stats["total_time_ms"] + = result.execution_time_ms

    #                 # Trigger integration callbacks
                    self._trigger_linter_callback(request, result)
                    self._trigger_ai_guard_callback(request, result)
                    self._trigger_ide_callback(request, result)

                    self.logger.info(f"Parse successful (request_id: {request.request_id})")
    #                 return result

    #             finally:
    #                 # Return parser to pool
                    self._return_parser(parser)

    #         except Exception as e:
    #             # Create error result
    error_result = ParseResult(
    request_id = request.request_id,
    success = False,
    errors = [ParserError(str(e))],
    execution_time_ms = int((time.time() - start_time) * 1000)
    #             )

    #             # Update statistics
    self.stats["failed_requests"] + = 1
    self.stats["total_time_ms"] + = error_result.execution_time_ms

                self.logger.error(f"Parse failed (request_id: {request.request_id}): {str(e)}")
    #             return error_result

    #     def _parse_full(self, parser: Parser) -ProgramNode):
    #         """Parse the entire program"""
            return parser.parse()

    #     def _parse_incremental(self, parser: Parser, request: ParseRequest) -ProgramNode):
    #         """Parse with incremental updates"""
    #         if not self.config.enable_incremental_parsing:
                return self._parse_full(parser)

    #         # Check if we have a previous AST to update
    previous_ast = self._get_previous_ast(request)
    #         if previous_ast is None:
                return self._parse_full(parser)

    #         # For now, fall back to full parsing
    #         # In a full implementation, this would update the existing AST
            return self._parse_full(parser)

    #     def _parse_partial(self, parser: Parser, request: ParseRequest) -ProgramNode):
    #         """Parse a partial code snippet"""
    #         # For partial parsing, we need to handle incomplete code
    #         try:
                return parser.parse()
    #         except ParserError as e:
    #             if self.config.enable_error_recovery:
    #                 # Try to recover and return a partial AST
                    return self._recover_partial_ast(parser, e)
    #             raise

    #     def _parse_streaming(self, parser: Parser, request: ParseRequest) -ProgramNode):
    #         """Parse using streaming for large files"""
    #         # For streaming, we would process the code in chunks
    #         # For now, fall back to full parsing
            return self._parse_full(parser)

    #     def _recover_partial_ast(self, parser: Parser, error: ParserError) -ProgramNode):
    #         """Recover from parsing error and return partial AST"""
    #         # Create a partial AST with what we could parse
    program = ProgramNode()

    #         # Try to get whatever statements were parsed before the error
    #         if hasattr(parser, 'partial_statements'):
    #             for stmt in parser.partial_statements:
                    program.add_child(stmt)

    #         return program

    #     def _get_cache_key(self, request: ParseRequest) -Optional[str]):
    #         """Generate a cache key for the request"""
    #         if self.config.cache_strategy == CacheStrategy.NONE:
    #             return None

    #         # Create hash based on code content and mode
    content = f"{request.code}:{request.mode.value}"
            return hashlib.md5(content.encode()).hexdigest()

    #     def _cache_result(self, cache_key: str, result: ParseResult):
    #         """Cache a parsing result"""
    #         with self._lock:
    #             # Check cache size limit
    #             if (self.config.cache_strategy == CacheStrategy.LRU and
    len(self._ast_cache) = self.config.cache_size)):
    #                 # Evict oldest entry
    oldest_key = self._cache_access_order.pop(0)
    #                 del self._ast_cache[oldest_key]

    #             # Store result
    self._ast_cache[cache_key] = result

    #             # Update LRU order
    #             if self.config.cache_strategy == CacheStrategy.LRU:
                    self._cache_access_order.append(cache_key)

    #     def _update_lru_order(self, cache_key: str):
    #         """Update LRU access order"""
    #         with self._lock:
    #             if cache_key in self._cache_access_order:
                    self._cache_access_order.remove(cache_key)
                self._cache_access_order.append(cache_key)

    #     def _get_previous_ast(self, request: ParseRequest) -Optional[ProgramNode]):
    #         """Get previous AST for incremental parsing"""
    #         # In a full implementation, this would look up the previous AST
    #         # based on file path or other metadata
    #         return None

    #     def _get_parser(self) -Parser):
    #         """Get a parser from the pool"""
    #         with self._parser_pool_lock:
    #             if self._parser_pool:
                    return self._parser_pool.pop()
    #             else:
    #                 # Create a new parser
    lexer = Lexer("")  # Empty lexer, will be replaced
                    return Parser(lexer)

    #     def _return_parser(self, parser: Parser):
    #         """Return a parser to the pool"""
    #         with self._parser_pool_lock:
    #             if len(self._parser_pool) < self.config.max_concurrent_parsers:
    #                 # Reset parser state
                    parser.reset()
                    self._parser_pool.append(parser)

    #     def _trigger_linter_callback(self, request: ParseRequest, result: ParseResult):
    #         """Trigger linter integration callback"""
    #         if self._linter_callback:
    #             try:
    #                 # Convert to validation request
    validation_request = ValidationRequest(
    code = request.code,
    mode = GuardMode.ADAPTIVE,
    file_path = request.file_path,
    metadata = request.metadata
    #                 )

    #                 # Call the callback
                    self._linter_callback(validation_request, result)
    #             except Exception as e:
                    self.logger.error(f"Linter callback error: {str(e)}")

    #     def _trigger_ai_guard_callback(self, request: ParseRequest, result: ParseResult):
    #         """Trigger AI guard integration callback"""
    #         if self._ai_guard_callback:
    #             try:
    #                 # Call the callback
                    self._ai_guard_callback(request, result)
    #             except Exception as e:
                    self.logger.error(f"AI guard callback error: {str(e)}")

    #     def _trigger_ide_callback(self, request: ParseRequest, result: ParseResult):
    #         """Trigger IDE integration callback"""
    #         if self._ide_callback:
    #             try:
    #                 # Call the callback
                    self._ide_callback(request, result)
    #             except Exception as e:
                    self.logger.error(f"IDE callback error: {str(e)}")

    #     def set_linter_callback(self, callback: Callable):
    #         """Set linter integration callback"""
    self._linter_callback = callback
            self.logger.info("Linter callback registered")

    #     def set_ai_guard_callback(self, callback: Callable):
    #         """Set AI guard integration callback"""
    self._ai_guard_callback = callback
            self.logger.info("AI guard callback registered")

    #     def set_ide_callback(self, callback: Callable):
    #         """Set IDE integration callback"""
    self._ide_callback = callback
            self.logger.info("IDE callback registered")

    #     def parse_file(self, file_path: str) -ParseResult):
    #         """
    #         Parse a NoodleCore file

    #         Args:
    #             file_path: Path to the .nc file

    #         Returns:
    #             ParseResult: Result of the parsing operation
    #         """
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()

                return self.parse(code, file_path)

    #         except IOError as e:
                raise FrontendError(f"Failed to read file: {str(e)}", 1002)

    #     def parse_snippet(self, code: str) -ParseResult):
    #         """
    #         Parse a code snippet

    #         Args:
    #             code: The code snippet to parse

    #         Returns:
    #             ParseResult: Result of the parsing operation
    #         """
    return self.parse(code, mode = ParsingMode.PARTIAL)

    #     def reparse_with_changes(
    #         self,
    #         original_code: str,
            changes: List[Tuple[int, int, str]],  # (start, end, new_text)
    file_path: Optional[str] = None
    #     ) -ParseResult):
    #         """
    #         Reparse code with specific changes

    #         Args:
    #             original_code: The original code
                changes: List of changes as (start, end, new_text)
    #             file_path: Optional file path

    #         Returns:
    #             ParseResult: Result of the parsing operation
    #         """
    #         # Apply changes to the code
    modified_code = original_code

    #         # Apply changes in reverse order to maintain positions
    #         for start, end, new_text in sorted(changes, reverse=True):
    modified_code = modified_code[:start] + new_text + modified_code[end:]

    #         # Parse the modified code
            return self.parse(modified_code, file_path, ParsingMode.INCREMENTAL)

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get frontend statistics"""
    #         with self._lock:
    #             return {
    #                 "total_requests": self.stats["total_requests"],
    #                 "successful_requests": self.stats["successful_requests"],
    #                 "failed_requests": self.stats["failed_requests"],
                    "success_rate": (
    #                     self.stats["successful_requests"] / self.stats["total_requests"]
    #                     if self.stats["total_requests"] 0 else 0
    #                 ),
    #                 "cache_hits"): self.stats["cache_hits"],
                    "cache_hit_rate": (
    #                     self.stats["cache_hits"] / self.stats["total_requests"]
    #                     if self.stats["total_requests"] 0 else 0
    #                 ),
    #                 "total_time_ms"): self.stats["total_time_ms"],
                    "average_time_ms": (
    #                     self.stats["total_time_ms"] / self.stats["total_requests"]
    #                     if self.stats["total_requests"] 0 else 0
    #                 ),
                    "cache_size"): len(self._ast_cache),
                    "parser_pool_size": len(self._parser_pool),
                    "config": self.config.to_dict(),
    #             }

    #     def clear_cache(self):
    #         """Clear the AST cache"""
    #         with self._lock:
                self._ast_cache.clear()
                self._cache_access_order.clear()
                self.logger.info("AST cache cleared")

    #     def reset_statistics(self):
    #         """Reset frontend statistics"""
    #         with self._lock:
    self.stats = {
    #                 "total_requests": 0,
    #                 "successful_requests": 0,
    #                 "failed_requests": 0,
    #                 "cache_hits": 0,
    #                 "total_time_ms": 0,
    #             }
                self.logger.info("Statistics reset")


# Global frontend instance
_frontend_instance: Optional[CompilerFrontend] = None
_frontend_lock = threading.Lock()


def get_frontend(config: Optional[FrontendConfig] = None) -CompilerFrontend):
#     """
#     Get the global compiler frontend instance

#     Args:
#         config: Optional configuration

#     Returns:
#         CompilerFrontend: The frontend instance
#     """
#     global _frontend_instance

#     with _frontend_lock:
#         if _frontend_instance is None:
_frontend_instance = CompilerFrontend(config)
#         elif config is not None:
#             # Update configuration if provided
_frontend_instance.config = config

#         return _frontend_instance


def parse_code(code: str, file_path: Optional[str] = None) -ParseResult):
#     """
#     Convenience function to parse code

#     Args:
#         code: The code to parse
#         file_path: Optional file path

#     Returns:
#         ParseResult: Result of the parsing operation
#     """
frontend = get_frontend()
    return frontend.parse(code, file_path)


def parse_file(file_path: str) -ParseResult):
#     """
#     Convenience function to parse a file

#     Args:
#         file_path: Path to the .nc file

#     Returns:
#         ParseResult: Result of the parsing operation
#     """
frontend = get_frontend()
    return frontend.parse_file(file_path)


def parse_snippet(code: str) -ParseResult):
#     """
#     Convenience function to parse a code snippet

#     Args:
#         code: The code snippet to parse

#     Returns:
#         ParseResult: Result of the parsing operation
#     """
frontend = get_frontend()
    return frontend.parse_snippet(code)