"""
Logs::Logger - logger.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Logger Module

This module implements the comprehensive logging system for the NoodleCore CLI.
It supports multiple log levels, structured logging, async operations, and audit trails.
"""

import asyncio
import json
import logging
import logging.handlers
import os
import sys
import time
import uuid
from abc import ABC, abstractmethod
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Dict, Any, Optional, List, Union, Callable
from concurrent.futures import ThreadPoolExecutor

from ..cli_config import get_cli_config


# Error codes for logging system (5001-5999)
class LoggingErrorCodes:
    LOGGER_INIT_FAILED = 5001
    HANDLER_CREATION_FAILED = 5002
    LOG_WRITE_FAILED = 5003
    LOG_ROTATION_FAILED = 5004
    ASYNC_LOG_FAILED = 5005
    FILTER_CONFIG_FAILED = 5006
    OUTPUT_CONFIG_FAILED = 5007
    REQUEST_ID_GENERATION_FAILED = 5008
    LOG_FORMAT_ERROR = 5009
    STORAGE_ERROR = 5010


class LogLevel(Enum):
    """Log levels for the logging system."""
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class LogFormat(Enum):
    """Supported log formats."""
    JSON = "json"
    TEXT = "text"
    STRUCTURED = "structured"


class LogOutput(Enum):
    """Supported log output destinations."""
    CONSOLE = "console"
    FILE = "file"
    SYSLOG = "syslog"
    REMOTE = "remote"


class LoggingException(Exception):
    """Base exception for logging system errors."""
    
    def __init__(self, message: str, error_code: int):
        self.error_code = error_code
        super().__init__(message)


class LogFilter(ABC):
    """Abstract base class for log filters."""
    
    @abstractmethod
    def should_log(self, record: logging.LogRecord) -> bool:
        """Determine if a log record should be processed."""
        pass


class ComponentFilter(LogFilter):
    """Filter logs based on component."""
    
    def __init__(self, allowed_components: List[str]):
        self.allowed_components = allowed_components
    
    def should_log(self, record: logging.LogRecord) -> bool:
        component = getattr(record, 'component', 'unknown')
        return component in self.allowed_components


class LevelFilter(LogFilter):
    """Filter logs based on level."""
    
    def __init__(self, min_level: LogLevel):
        self.min_level = min_level
    
    def should_log(self, record: logging.LogRecord) -> bool:
        level_mapping = {
            'DEBUG': 10,
            'INFO': 20,
            'WARNING': 30,
            'ERROR': 40,
            'CRITICAL': 50
        }
        record_level = level_mapping.get(record.levelname, 20)
        min_level_value = level_mapping.get(self.min_level.value, 20)
        return record_level >= min_level_value


class StructuredFormatter(logging.Formatter):
    """Custom formatter for structured log output."""
    
    def __init__(self, format_type: LogFormat = LogFormat.JSON):
        super().__init__()
        self.format_type = format_type
    
    def format(self, record: logging.LogRecord) -> str:
        """Format log record as structured JSON or text."""
        timestamp = datetime.fromtimestamp(record.created).isoformat() + 'Z'
        
        log_data = {
            'timestamp': timestamp,
            'level': record.levelname,
            'component': getattr(record, 'component', 'unknown'),
            'request_id': getattr(record, 'request_id', str(uuid.uuid4())),
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        
        # Add exception info if present
        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)
        
        # Add extra fields
        for key, value in record.__dict__.items():
            if key not in ['name', 'msg', 'args', 'levelname', 'levelno', 'pathname',
                          'filename', 'module', 'lineno', 'funcName', 'created', 'msecs',
                          'relativeCreated', 'thread', 'threadName', 'processName',
                          'process', 'getMessage', 'exc_info', 'exc_text', 'stack_info']:
                log_data[key] = value
        
        if self.format_type == LogFormat.JSON:
            return json.dumps(log_data, default=str)
        elif self.format_type == LogFormat.TEXT:
            return (f"{timestamp} - {log_data['level']} - {log_data['component']} - "
                   f"{log_data['request_id']} - {log_data['message']}")
        else:  # STRUCTURED
            return json.dumps(log_data, default=str, indent=2)


class AsyncLogHandler:
    """Async log handler for performance optimization."""
    
    def __init__(self, handler: logging.Handler):
        self.handler = handler
        self.queue = asyncio.Queue()
        self.task = None
        self.running = False
    
    async def start(self):
        """Start the async log handler."""
        self.running = True
        self.task = asyncio.create_task(self._process_queue())
    
    async def stop(self):
        """Stop the async log handler."""
        self.running = False
        if self.task:
            await self.queue.put(None)  # Signal to stop
            await self.task
    
    async def emit(self, record: logging.LogRecord):
        """Emit a log record asynchronously."""
        await self.queue.put(record)
    
    async def _process_queue(self):
        """Process log records from the queue."""
        while self.running:
            try:
                record = await asyncio.wait_for(self.queue.get(), timeout=1.0)
                if record is None:  # Stop signal
                    break
                
                # Process in thread pool to avoid blocking
                loop = asyncio.get_event_loop()
                await loop.run_in_executor(None, self.handler.emit, record)
                
            except asyncio.TimeoutError:
                continue
            except Exception as e:
                # Fallback to sync logging if async fails
                try:
                    self.handler.emit(record)
                except:
                    pass  # Avoid infinite recursion


class Logger:
    """Main logger class for NoodleCore CLI with comprehensive features."""
    
    def __init__(self):
        """Initialize the logger."""
        self.config = get_cli_config()
        self.logger = logging.getLogger('noodlecore')
        self.audit_logger = None
        self._initialized = False
        self._async_handlers: List[AsyncLogHandler] = []
        self._filters: List[LogFilter] = []
        self._executor = ThreadPoolExecutor(max_workers=4)
        
        # Performance tracking
        self._performance_stats = {
            'total_logs': 0,
            'error_count': 0,
            'warning_count': 0,
            'avg_log_time': 0.0
        }
    
    async def initialize(
        self, 
        level: str = 'INFO', 
        verbose: bool = False,
        outputs: List[LogOutput] = None,
        format_type: LogFormat = LogFormat.JSON,
        enable_async: bool = True
    ) -> None:
        """
        Initialize the logging system with comprehensive configuration.
        
        Args:
            level: Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            verbose: Enable verbose logging
            outputs: List of output destinations
            format_type: Log format type
            enable_async: Enable async logging
            
        Raises:
            LoggingException: If initialization fails
        """
        if self._initialized:
            return
        
        try:
            # Set log level
            if verbose:
                log_level = logging.DEBUG
            else:
                log_level = getattr(logging, level.upper(), logging.INFO)
            
            self.logger.setLevel(log_level)
            
            # Clear existing handlers
            self.logger.handlers.clear()
            
            # Set default outputs
            if outputs is None:
                outputs = [LogOutput.CONSOLE, LogOutput.FILE]
            
            # Create formatters
            formatter = StructuredFormatter(format_type)
            
            # Setup handlers for each output
            for output in outputs:
                await self._setup_handler(output, formatter, log_level, enable_async)
            
            # Initialize audit logger if enabled
            if self.config.get_bool('NOODLE_ENABLE_AUDIT_LOG', True):
                from .audit_trail import AuditTrail
                self.audit_logger = AuditTrail()
            
            self._initialized = True
            await self._log_with_request_id(
                LogLevel.INFO,
                "Logger initialized",
                extra={
                    'level': level,
                    'verbose': verbose,
                    'outputs': [o.value for o in outputs],
                    'format': format_type.value,
                    'async_enabled': enable_async
                }
            )
            
        except Exception as e:
            raise LoggingException(
                f"Failed to initialize logger: {str(e)}",
                LoggingErrorCodes.LOGGER_INIT_FAILED
            )
    
    async def _setup_handler(
        self, 
        output: LogOutput, 
        formatter: StructuredFormatter,
        log_level: int,
        enable_async: bool
    ) -> None:
        """Setup a log handler for the specified output."""
        try:
            if output == LogOutput.CONSOLE:
                handler = logging.StreamHandler(sys.stdout)
            elif output == LogOutput.FILE:
                log_dir = self.config.get_path('NOODLE_LOG_DIR', Path('.project/.noodle/logs'))
                log_dir.mkdir(parents=True, exist_ok=True)
                log_file = log_dir / 'cli.log'
                
                handler = logging.handlers.RotatingFileHandler(
                    log_file,
                    maxBytes=50 * 1024 * 1024,  # 50MB
                    backupCount=10,
                    encoding='utf-8'
                )
            elif output == LogOutput.SYSLOG:
                handler = logging.handlers.SysLogHandler(address='/dev/log')
            elif output == LogOutput.REMOTE:
                # Remote logging configuration
                remote_host = self.config.get('NOODLE_REMOTE_LOG_HOST', 'localhost')
                remote_port = self.config.get_int('NOODLE_REMOTE_LOG_PORT', 514)
                handler = logging.handlers.SysLogHandler(address=(remote_host, remote_port))
            else:
                raise LoggingException(
                    f"Unsupported output type: {output}",
                    LoggingErrorCodes.OUTPUT_CONFIG_FAILED
                )
            
            handler.setLevel(log_level)
            handler.setFormatter(formatter)
            
            if enable_async and output != LogOutput.CONSOLE:
                async_handler = AsyncLogHandler(handler)
                await async_handler.start()
                self._async_handlers.append(async_handler)
                # Add custom async handler wrapper
                self.logger.addHandler(AsyncHandlerWrapper(async_handler))
            else:
                self.logger.addHandler(handler)
                
        except Exception as e:
            raise LoggingException(
                f"Failed to setup {output.value} handler: {str(e)}",
                LoggingErrorCodes.HANDLER_CREATION_FAILED
            )
    
    async def _log_with_request_id(
        self, 
        level: LogLevel, 
        message: str, 
        request_id: str = None,
        **kwargs
    ) -> None:
        """Log a message with request ID tracking."""
        try:
            start_time = time.time()
            
            if request_id is None:
                request_id = str(uuid.uuid4())
            
            extra = {
                'request_id': request_id,
                'component': kwargs.get('component', 'logger'),
                **kwargs
            }
            
            # Apply filters
            if not self._should_log(level, extra):
                return
            
            # Log the message
            log_method = getattr(self.logger, level.value.lower())
            log_method(message, extra=extra)
            
            # Update performance stats
            log_time = time.time() - start_time
            self._update_performance_stats(level, log_time)
            
        except Exception as e:
            # Fallback logging to avoid infinite recursion
            try:
                self.logger.error(f"Logging failed: {str(e)}")
            except:
                pass
    
    def _should_log(self, level: LogLevel, extra: Dict[str, Any]) -> bool:
        """Check if log should be processed based on filters."""
        # Create a mock log record for filtering
        record = logging.LogRecord(
            name='noodlecore',
            level=getattr(logging, level.value),
            pathname='',
            lineno=0,
            msg='',
            args=(),
            exc_info=None
        )
        
        # Add extra attributes
        for key, value in extra.items():
            setattr(record, key, value)
        
        # Apply all filters
        for filter_obj in self._filters:
            if not filter_obj.should_log(record):
                return False
        
        return True
    
    def _update_performance_stats(self, level: LogLevel, log_time: float) -> None:
        """Update performance statistics."""
        self._performance_stats['total_logs'] += 1
        
        if level in [LogLevel.ERROR, LogLevel.CRITICAL]:
            self._performance_stats['error_count'] += 1
        elif level == LogLevel.WARNING:
            self._performance_stats['warning_count'] += 1
        
        # Update average log time
        total = self._performance_stats['total_logs']
        current_avg = self._performance_stats['avg_log_time']
        self._performance_stats['avg_log_time'] = (current_avg * (total - 1) + log_time) / total
    
    def add_filter(self, filter_obj: LogFilter) -> None:
        """Add a log filter."""
        self._filters.append(filter_obj)
    
    def remove_filter(self, filter_obj: LogFilter) -> None:
        """Remove a log filter."""
        if filter_obj in self._filters:
            self._filters.remove(filter_obj)
    
    async def debug(self, message: str, request_id: str = None, **kwargs) -> None:
        """Log debug message."""
        await self._log_with_request_id(LogLevel.DEBUG, message, request_id, **kwargs)
    
    async def info(self, message: str, request_id: str = None, **kwargs) -> None:
        """Log info message."""
        await self._log_with_request_id(LogLevel.INFO, message, request_id, **kwargs)
    
    async def warning(self, message: str, request_id: str = None, **kwargs) -> None:
        """Log warning message."""
        await self._log_with_request_id(LogLevel.WARNING, message, request_id, **kwargs)
    
    async def error(self, message: str, request_id: str = None, error_code: int = None, **kwargs) -> None:
        """Log error message with optional error code."""
        if error_code:
            kwargs['error_code'] = error_code
        await self._log_with_request_id(LogLevel.ERROR, message, request_id, **kwargs)
    
    async def critical(self, message: str, request_id: str = None, error_code: int = None, **kwargs) -> None:
        """Log critical message with optional error code."""
        if error_code:
            kwargs['error_code'] = error_code
        await self._log_with_request_id(LogLevel.CRITICAL, message, request_id, **kwargs)
    
    async def log_ai_request(
        self, 
        request_id: str,
        model: str,
        prompt: str,
        component: str = 'ai_adapter'
    ) -> None:
        """Log AI request with standardized format."""
        await self.info(
            "AI Request",
            request_id=request_id,
            component=component,
            event='AI Request',
            details={
                'model': model,
                'prompt': prompt[:500] + '...' if len(prompt) > 500 else prompt,  # Truncate long prompts
                'timestamp': datetime.now().isoformat()
            }
        )
    
    async def log_ai_response(
        self,
        request_id: str,
        model: str,
        response: str,
        tokens: int,
        latency: float,
        component: str = 'ai_adapter'
    ) -> None:
        """Log AI response with performance metrics."""
        await self.info(
            "AI Response",
            request_id=request_id,
            component=component,
            event='AI Response',
            details={
                'model': model,
                'response': response[:500] + '...' if len(response) > 500 else response,
                'tokens': tokens,
                'latency': f"{latency}s",
                'timestamp': datetime.now().isoformat()
            }
        )
    
    async def log_sandbox_operation(
        self,
        request_id: str,
        operation: str,
        file_path: str,
        validation_result: str,
        component: str = 'sandbox'
    ) -> None:
        """Log sandbox operation with validation results."""
        await self.info(
            "Sandbox Operation",
            request_id=request_id,
            component=component,
            event='AI Output',
            details={
                'file': file_path,
                'operation': operation,
                'validation': validation_result,
                'timestamp': datetime.now().isoformat()
            }
        )
    
    def set_level(self, level: str) -> None:
        """Set the logging level dynamically."""
        log_level = getattr(logging, level.upper(), logging.INFO)
        self.logger.setLevel(log_level)
        
        # Update handler levels
        for handler in self.logger.handlers:
            if isinstance(handler, AsyncHandlerWrapper):
                handler.handler.handler.setLevel(log_level)
            else:
                handler.setLevel(log_level)
    
    def get_performance_stats(self) -> Dict[str, Any]:
        """Get performance statistics."""
        return self._performance_stats.copy()
    
    async def shutdown(self) -> None:
        """Shutdown the logging system gracefully."""
        # Stop async handlers
        for async_handler in self._async_handlers:
            await async_handler.stop()
        
        # Shutdown executor
        self._executor.shutdown(wait=True)
        
        self._initialized = False


class AsyncHandlerWrapper(logging.Handler):
    """Wrapper for async log handlers to work with standard logging."""
    
    def __init__(self, async_handler: AsyncLogHandler):
        super().__init__()
        self.async_handler = async_handler
    
    def emit(self, record: logging.LogRecord):
        """Emit record asynchronously."""
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                asyncio.create_task(self.async_handler.emit(record))
            else:
                # Fallback to sync if no event loop
                self.async_handler.handler.emit(record)
        except:
            # Fallback to sync
            self.async_handler.handler.emit(record)


# Global logger instance
_logger = None


async def get_logger() -> Logger:
    """Get the global logger instance."""
    global _logger
    if _logger is None:
        _logger = Logger()
        await _logger.initialize()
    return _logger


def reset_logger() -> Logger:
    """Reset the global logger instance."""
    global _logger
    _logger = Logger()
    return _logger

