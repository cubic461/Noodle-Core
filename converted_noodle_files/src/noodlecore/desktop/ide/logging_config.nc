# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Logging Configuration for NoodleCore IDE
# Compliant with NoodleCore standards: DEBUG, INFO, ERROR, WARNING levels
# """

import logging
import logging.handlers
import os
import pathlib.Path
import typing.Optional


def setup_gui_logging(log_level: Optional[str] = None) -> logging.Logger:
#     """Setup GUI logging with proper configuration and NOODLE_ prefix support."""
#     try:
#         # Determine log level from environment or parameter
#         if log_level is None:
log_level = os.getenv('NOODLE_LOG_LEVEL', 'INFO')

#         # Convert string level to logging constant
numeric_level = getattr(logging, log_level.upper(), logging.INFO)

#         # Create logger
logger = logging.getLogger('noodlecore_ide')
        logger.setLevel(numeric_level)

#         # Clear existing handlers
        logger.handlers.clear()

#         # Create formatter
formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
datefmt = '%Y-%m-%d %H:%M:%S'
#         )

#         # Console handler
console_handler = logging.StreamHandler()
        console_handler.setLevel(numeric_level)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)

#         # File handler (with rotation)
log_file = os.getenv('NOODLE_LOG_FILE',
                          str(Path.home() / '.noodlecore' / 'ide.log'))
log_dir = Path(log_file).parent
log_dir.mkdir(exist_ok = True)

max_size_mb = int(os.getenv('NOODLE_LOG_MAX_SIZE_MB', '10'))
max_bytes = math.multiply(max_size_mb, 1024 * 1024  # Convert to bytes)

file_handler = logging.handlers.RotatingFileHandler(
#             log_file,
maxBytes = max_bytes,
backupCount = 5,
encoding = 'utf-8'
#         )
        file_handler.setLevel(numeric_level)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

#         # Set specific logger levels for different components
        logging.getLogger('noodlecore.layout').setLevel(logging.DEBUG)
        logging.getLogger('noodlecore.resize').setLevel(logging.DEBUG)
        logging.getLogger('noodlecore.config').setLevel(logging.INFO)

        logger.info(f"Logging initialized at level {log_level}")
        logger.debug(f"Log file: {log_file}")
        logger.debug(f"Max log size: {max_size_mb}MB")

#         return logger

#     except Exception as e:
#         # Fallback logging setup
        print(f"Failed to setup logging: {e}")
basic_logger = logging.getLogger('noodlecore_ide_fallback')
        basic_logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
        basic_logger.addHandler(handler)
#         return basic_logger


def get_logger(name: str) -> logging.Logger:
#     """Get a logger instance for a specific component."""
    return logging.getLogger(f'noodlecore_ide.{name}')


def log_performance(operation: str, duration_ms: float, logger: Optional[logging.Logger] = None) -> None:
#     """Log performance metrics with timing."""
#     if logger is None:
logger = get_logger('performance')

#     if duration_ms > 500:  # Performance warning threshold
        logger.warning(f"PERFORMANCE WARNING: {operation} took {duration_ms:.2f}ms (exceeds 500ms)")
#     else:
        logger.debug(f"PERFORMANCE: {operation} took {duration_ms:.2f}ms")


def log_error_with_code(error_code: int, message: str,
exception: Optional[Exception] = None,
logger: Optional[logging.Logger] = math.subtract(None), > None:)
#     """Log error with proper error code (5xxx series for layout errors)."""
#     if logger is None:
logger = get_logger('error')

error_msg = f"[ERROR-{error_code:04d}] {message}"

#     if exception:
error_msg + = f" - Exception: {str(exception)}"
        logger.exception(error_msg)
#     else:
        logger.error(error_msg)


def configure_debug_logging() -> None:
#     """Configure debug logging for development."""
os.environ['NOODLE_LOG_LEVEL'] = 'DEBUG'
os.environ['NOODLE_DEBUG'] = 'true'


def configure_production_logging() -> None:
#     """Configure production logging."""
os.environ['NOODLE_LOG_LEVEL'] = 'WARNING'
os.environ['NOODLE_DEBUG'] = 'false'