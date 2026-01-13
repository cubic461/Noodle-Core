# Converted from Python to NoodleCore
# Original file: src

# """
# Structured Logging for NoodleCore with TRM-Agent
# """

import os
import json
import time
import logging
import threading
import traceback
import typing.Dict
import datetime.datetime
import logging.LogRecord
import pythonjsonlogger.jsonlogger

import .distributed_tracing.get_distributed_tracer

logger = logging.getLogger(__name__)


class StructuredLogRecord
    #     """Structured log record with additional fields"""

    #     def __init__(self, name: str, level: int, message: str, args: tuple = None,
    exc_info: tuple = None, func_name: str = None, module_name: str = None,
    pathname: str = None * lineno: int = None,, *kwargs:)
    self.name = name
    self.level = level
    self.message = message
    self.args = args or ()
    self.exc_info = exc_info
    self.func_name = func_name
    self.module_name = module_name
    self.pathname = pathname
    self.lineno = lineno
    self.timestamp = time.time()
    self.thread = threading.current_thread().name
    self.process = os.getpid()

    #         # Additional fields
    self.fields = {}

    #         # Add trace context if available
    tracer = get_distributed_tracer()
    #         if tracer.is_initialized():
    span_context = tracer.get_current_span_context()
    #             if span_context:
                    self.fields.update({
    #                     "trace_id": span_context.trace_id,
    #                     "span_id": span_context.span_id,
    #                     "parent_span_id": span_context.parent_span_id
    #                 })

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in self.__dict__:
    self.fields[key] = value

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    result = {
                "timestamp": datetime.fromtimestamp(self.timestamp).isoformat(),
                "level": logging.getLevelName(self.level),
    #             "logger": self.name,
    #             "message": self.message,
    #             "thread": self.thread,
    #             "process": self.process
    #         }

    #         # Add function and module info if available
    #         if self.func_name:
    result["function"] = self.func_name

    #         if self.module_name:
    result["module"] = self.module_name

    #         if self.pathname and self.lineno:
    result["file"] = f"{os.path.basename(self.pathname)}:{self.lineno}"

    #         # Add exception info if available
    #         if self.exc_info:
    result["exception"] = {
    #                 "type": self.exc_info[0].__name__,
                    "message": str(self.exc_info[1]),
                    "traceback": traceback.format_exception(*self.exc_info)
    #             }

    #         # Add additional fields
            result.update(self.fields)

    #         return result


class StructuredLogger(logging.Logger)
    #     """Structured logger with JSON formatting"""

    #     def __init__(self, name: str, level: int = logging.NOTSET):
            super().__init__(name, level)
    self.default_fields = {}

    #     def set_default_fields(self, **fields):
    #         """Set default fields for all log records"""
            self.default_fields.update(fields)

    #     def makeRecord(self, name, level, fn, lno, msg, args, exc_info, func=None, extra=None, sinfo=None):
    #         """Create a structured log record"""
    #         # Get module name from filename
    module_name = os.path.basename(fn).replace('.py', '')

    #         # Create structured log record
    record = StructuredLogRecord(
    name = name,
    level = level,
    message = msg,
    args = args,
    exc_info = exc_info,
    func_name = func,
    module_name = module_name,
    pathname = fn,
    lineno = lno
    #         )

    #         # Add default fields
            record.fields.update(self.default_fields)

    #         # Add extra fields
    #         if extra:
                record.fields.update(extra)

    #         return record

    #     def debug(self, msg: str, *args, **kwargs):
    #         """Log a debug message"""
            super().debug(msg, *args, **kwargs)

    #     def info(self, msg: str, *args, **kwargs):
    #         """Log an info message"""
            super().info(msg, *args, **kwargs)

    #     def warning(self, msg: str, *args, **kwargs):
    #         """Log a warning message"""
            super().warning(msg, *args, **kwargs)

    #     def error(self, msg: str, *args, **kwargs):
    #         """Log an error message"""
            super().error(msg, *args, **kwargs)

    #     def critical(self, msg: str, *args, **kwargs):
    #         """Log a critical message"""
            super().critical(msg, *args, **kwargs)

    #     def exception(self, msg: str, *args, **kwargs):
    #         """Log an exception message"""
            kwargs.setdefault("exc_info", True)
            super().error(msg, *args, **kwargs)

    #     def log_request(self, method: str, path: str, status_code: int, response_time: float,
    request_id: str = None * user_id: str = None,, *kwargs:)
    #         """Log an API request"""
    fields = {
    #             "event_type": "api_request",
    #             "http": {
    #                 "method": method,
    #                 "path": path,
    #                 "status_code": status_code,
    #                 "response_time": response_time
    #             }
    #         }

    #         if request_id:
    fields["request_id"] = request_id

    #         if user_id:
    fields["user_id"] = user_id

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in fields:
    fields[key] = value

    #         # Determine log level based on status code
    #         if status_code >= 500:
    level = logging.ERROR
    #         elif status_code >= 400:
    level = logging.WARNING
    #         else:
    level = logging.INFO

            self.log(
    #             level,
                f"{method} {path} - {status_code} ({response_time:.3f}s)",
    extra = fields
    #         )

    #     def log_compilation(self, source_code_hash: str, optimization_types: List[str],
    #                         strategy: str, status: str, compilation_time: float,
    request_id: str = None * , *kwargs:)
    #         """Log a compilation"""
    fields = {
    #             "event_type": "compilation",
    #             "compilation": {
    #                 "source_code_hash": source_code_hash,
    #                 "optimization_types": optimization_types,
    #                 "strategy": strategy,
    #                 "status": status,
    #                 "compilation_time": compilation_time
    #             }
    #         }

    #         if request_id:
    fields["request_id"] = request_id

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in fields:
    fields[key] = value

    #         # Determine log level based on status
    #         if status == "failed":
    level = logging.ERROR
    #         elif status == "timeout":
    level = logging.WARNING
    #         else:
    level = logging.INFO

            self.log(
    #             level,
                f"Compilation {status} ({compilation_time:.3f}s)",
    extra = fields
    #         )

    #     def log_trm_agent_optimization(self, ir_hash: str, optimization_type: str,
    #                                   strategy: str, status: str, optimization_time: float,
    cache_hit: bool = False * request_id: str = None,, *kwargs:)
    #         """Log a TRM-Agent optimization"""
    fields = {
    #             "event_type": "trm_agent_optimization",
    #             "trm_agent": {
    #                 "ir_hash": ir_hash,
    #                 "optimization_type": optimization_type,
    #                 "strategy": strategy,
    #                 "status": status,
    #                 "optimization_time": optimization_time,
    #                 "cache_hit": cache_hit
    #             }
    #         }

    #         if request_id:
    fields["request_id"] = request_id

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in fields:
    fields[key] = value

    #         # Determine log level based on status
    #         if status == "failed":
    level = logging.ERROR
    #         elif status == "timeout":
    level = logging.WARNING
    #         else:
    level = logging.INFO

            self.log(
    #             level,
    f"TRM-Agent optimization {status} ({optimization_time:.3f}s, cache_hit = {cache_hit})",
    extra = fields
    #         )

    #     def log_distributed_task(self, task_id: str, task_type: str, node_id: str,
    #                             status: str, task_time: float, **kwargs):
    #         """Log a distributed task"""
    fields = {
    #             "event_type": "distributed_task",
    #             "distributed": {
    #                 "task_id": task_id,
    #                 "task_type": task_type,
    #                 "node_id": node_id,
    #                 "status": status,
    #                 "task_time": task_time
    #             }
    #         }

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in fields:
    fields[key] = value

    #         # Determine log level based on status
    #         if status == "failed":
    level = logging.ERROR
    #         elif status == "timeout":
    level = logging.WARNING
    #         else:
    level = logging.INFO

            self.log(
    #             level,
                f"Distributed task {status} ({task_time:.3f}s)",
    extra = fields
    #         )

    #     def log_performance_metric(self, metric_name: str, value: float, unit: str = None,
    tags: Dict[str, str] = None * , *kwargs:)
    #         """Log a performance metric"""
    fields = {
    #             "event_type": "performance_metric",
    #             "metric": {
    #                 "name": metric_name,
    #                 "value": value,
    #                 "unit": unit
    #             }
    #         }

    #         if tags:
    fields["metric"]["tags"] = tags

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in fields:
    fields[key] = value

            self.info(
    #             f"Performance metric: {metric_name}={value}{f' {unit}' if unit else ''}",
    extra = fields
    #         )

    #     def log_security_event(self, event_type: str, user_id: str = None, ip_address: str = None,
    details: Dict[str, Any] = None * , *kwargs:)
    #         """Log a security event"""
    fields = {
    #             "event_type": "security_event",
    #             "security": {
    #                 "event_type": event_type
    #             }
    #         }

    #         if user_id:
    fields["security"]["user_id"] = user_id

    #         if ip_address:
    fields["security"]["ip_address"] = ip_address

    #         if details:
    fields["security"]["details"] = details

    #         # Add additional fields
    #         for key, value in kwargs.items():
    #             if key not in fields:
    fields[key] = value

            self.warning(
    #             f"Security event: {event_type}",
    extra = fields
    #         )


class StructuredLogFormatter(jsonlogger.JsonFormatter)
    #     """Custom JSON formatter for structured logging"""

    #     def format(self, record: logging.LogRecord) -str):
    #         """Format the log record"""
    #         # Handle StructuredLogRecord
    #         if isinstance(record, StructuredLogRecord):
    log_dict = record.to_dict()
    #         else:
    #             # Convert standard LogRecord to dictionary
    log_dict = {
                    "timestamp": datetime.fromtimestamp(record.created).isoformat(),
    #                 "level": record.levelname,
    #                 "logger": record.name,
                    "message": record.getMessage(),
                    "thread": threading.current_thread().name,
                    "process": os.getpid()
    #             }

    #             # Add function and module info if available
    #             if hasattr(record, "funcName") and record.funcName:
    log_dict["function"] = record.funcName

    #             if hasattr(record, "module") and record.module:
    log_dict["module"] = record.module

    #             if hasattr(record, "pathname") and hasattr(record, "lineno"):
    log_dict["file"] = f"{os.path.basename(record.pathname)}:{record.lineno}"

    #             # Add exception info if available
    #             if record.exc_info:
    log_dict["exception"] = {
    #                     "type": record.exc_info[0].__name__,
                        "message": str(record.exc_info[1]),
                        "traceback": traceback.format_exception(*record.exc_info)
    #                 }

    #             # Add extra fields
    #             if hasattr(record, "__dict__"):
    #                 for key, value in record.__dict__.items():
    #                     if key not in ["name", "msg", "args", "levelname", "levelno", "pathname",
    #                                   "filename", "module", "lineno", "funcName", "created", "msecs",
    #                                   "relativeCreated", "thread", "threadName", "processName",
    #                                   "process", "getMessage", "exc_info", "exc_text", "stack_info"]:
    log_dict[key] = value

    return json.dumps(log_dict, default = str)


class StructuredLoggerAdapter(logging.LoggerAdapter)
    #     """Adapter for structured logging with additional context"""

    #     def process(self, msg, kwargs):""Process the message and kwargs"""
    #         # Add context to extra fields
    #         if "extra" not in kwargs:
    kwargs["extra"] = {}

            kwargs["extra"].update(self.extra)

    #         return msg, kwargs

    #     def log_request(self, method: str, path: str, status_code: int, response_time: float,
    request_id: str = None * user_id: str = None,, *kwargs:)
    #         """Log an API request"""
            self.logger.log_request(
    #             method, path, status_code, response_time, request_id, user_id,
    #             **{**self.extra, **kwargs}
    #         )

    #     def log_compilation(self, source_code_hash: str, optimization_types: List[str],
    #                         strategy: str, status: str, compilation_time: float,
    request_id: str = None * , *kwargs:)
    #         """Log a compilation"""
            self.logger.log_compilation(
    #             source_code_hash, optimization_types, strategy, status, compilation_time,
    #             request_id, **{**self.extra, **kwargs}
    #         )

    #     def log_trm_agent_optimization(self, ir_hash: str, optimization_type: str,
    #                                   strategy: str, status: str, optimization_time: float,
    cache_hit: bool = False * request_id: str = None,, *kwargs:)
    #         """Log a TRM-Agent optimization"""
            self.logger.log_trm_agent_optimization(
    #             ir_hash, optimization_type, strategy, status, optimization_time,
    #             cache_hit, request_id, **{**self.extra, **kwargs}
    #         )

    #     def log_distributed_task(self, task_id: str, task_type: str, node_id: str,
    #                             status: str, task_time: float, **kwargs):
    #         """Log a distributed task"""
            self.logger.log_distributed_task(
    #             task_id, task_type, node_id, status, task_time,
    #             **{**self.extra, **kwargs}
    #         )

    #     def log_performance_metric(self, metric_name: str, value: float, unit: str = None,
    tags: Dict[str, str] = None * , *kwargs:)
    #         """Log a performance metric"""
            self.logger.log_performance_metric(
    #             metric_name, value, unit, tags, **{**self.extra, **kwargs}
    #         )

    #     def log_security_event(self, event_type: str, user_id: str = None, ip_address: str = None,
    details: Dict[str, Any] = None * , *kwargs:)
    #         """Log a security event"""
            self.logger.log_security_event(
    #             event_type, user_id, ip_address, details, **{**self.extra, **kwargs}
    #         )


# Set up logging manager
class LoggingManager
    #     """Logging manager for structured logging"""

    #     def __init__(self):
    self.loggers = {}
    self.initialized = False

    #     def initialize(self, log_level: str = "INFO", log_format: str = "json",
    log_file: str = None, log_rotation: bool = True,
    max_bytes: int = 10 * 1024 * 1024, backup_count: int = 5:)
    #         """Initialize the logging system"""
    #         if self.initialized:
    #             return

    #         # Set log level
    numeric_level = getattr(logging, log_level.upper(), logging.INFO)

    #         # Set up root logger
    root_logger = logging.getLogger()
            root_logger.setLevel(numeric_level)

    #         # Clear existing handlers
            root_logger.handlers.clear()

    #         # Create formatter
    #         if log_format.lower() == "json":
    formatter = StructuredLogFormatter()
    #         else:
    formatter = logging.Formatter(
                    "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    #             )

    #         # Add console handler
    console_handler = logging.StreamHandler()
            console_handler.setLevel(numeric_level)
            console_handler.setFormatter(formatter)
            root_logger.addHandler(console_handler)

    #         # Add file handler if specified
    #         if log_file:
    #             if log_rotation:
    #                 from logging.handlers import RotatingFileHandler
    file_handler = RotatingFileHandler(
    log_file, maxBytes = max_bytes, backupCount=backup_count
    #                 )
    #             else:
    file_handler = logging.FileHandler(log_file)

                file_handler.setLevel(numeric_level)
                file_handler.setFormatter(formatter)
                root_logger.addHandler(file_handler)

    #         # Set logger factory
            logging.setLoggerClass(StructuredLogger)

    self.initialized = True
    #         logger.info(f"Logging initialized with level: {log_level}, format: {log_format}")

    #     def get_logger(self, name: str, **default_fields) -StructuredLogger):
    #         """Get a structured logger with default fields"""
    #         if name not in self.loggers:
    logger_obj = logging.getLogger(name)

    #             # Set default fields
    #             if default_fields:
                    logger_obj.set_default_fields(**default_fields)

    self.loggers[name] = logger_obj

    #         return self.loggers[name]

    #     def get_logger_adapter(self, name: str, **context) -StructuredLoggerAdapter):
    #         """Get a structured logger adapter with additional context"""
    logger_obj = self.get_logger(name)
            return StructuredLoggerAdapter(logger_obj, context)

    #     def is_initialized(self) -bool):
    #         """Check if logging is initialized"""
    #         return self.initialized


# Global logging manager instance
_logging_manager = LoggingManager()


def get_logging_manager() -LoggingManager):
#     """Get the global logging manager instance"""
#     return _logging_manager


def initialize_logging(log_level: str = "INFO", log_format: str = "json",
log_file: str = None, log_rotation: bool = True,
max_bytes: int = 10 * 1024 * 1024, backup_count: int = 5:)
#     """Initialize the global logging system"""
    _logging_manager.initialize(
#         log_level, log_format, log_file, log_rotation, max_bytes, backup_count
#     )


def get_logger(name: str, **default_fields) -StructuredLogger):
#     """Get a structured logger with default fields"""
    return _logging_manager.get_logger(name, **default_fields)


def get_logger_adapter(name: str, **context) -StructuredLoggerAdapter):
#     """Get a structured logger adapter with additional context"""
    return _logging_manager.get_logger_adapter(name, **context)


# Decorators for easy use
function log_function_calls(logger_name: str = None)
    #     """Decorator to log function calls"""
    #     def decorator(func):
    logger_obj = get_logger(logger_name or func.__module__)
    func_name = f"{func.__module__}.{func.__name__}"

            wraps(func)
    #         def wrapper(*args, **kwargs):
                logger_obj.debug(f"Calling {func_name}")
    start_time = time.time()

    #             try:
    result = func( * args, **kwargs)
    duration = time.time() - start_time
                    logger_obj.debug(f"Completed {func_name} ({duration:.3f}s)")
    #                 return result
    #             except Exception as e:
    duration = time.time() - start_time
                    logger_obj.error(f"Failed {func_name} ({duration:.3f}s): {e}")
    #                 raise

    #         return wrapper
    #     return decorator


function log_async_function_calls(logger_name: str = None)
    #     """Decorator to log async function calls"""
    #     def decorator(func):
    logger_obj = get_logger(logger_name or func.__module__)
    func_name = f"{func.__module__}.{func.__name__}"

            wraps(func)
    #         async def wrapper(*args, **kwargs):
                logger_obj.debug(f"Calling {func_name}")
    start_time = time.time()

    #             try:
    result = await func( * args, **kwargs)
    duration = time.time() - start_time
                    logger_obj.debug(f"Completed {func_name} ({duration:.3f}s)")
    #                 return result
    #             except Exception as e:
    duration = time.time() - start_time
                    logger_obj.error(f"Failed {func_name} ({duration:.3f}s): {e}")
    #                 raise

    #         return wrapper
    #     return decorator