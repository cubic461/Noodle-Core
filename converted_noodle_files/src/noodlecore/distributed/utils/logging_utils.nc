# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Logging Utilities for NoodleCore Distributed AI Task Management.

# This module provides centralized logging functionality with NoodleCore integration.
# """

import logging
import logging.handlers
import sys
import typing.Optional,
import pathlib.Path


class LoggingUtils
    #     """Centralized logging utilities for the distributed system."""

    _loggers: Dict[str, logging.Logger] = {}
    _configured = False

    #     @classmethod
    #     def configure_logging(cls,
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    max_bytes: int = math.multiply(10, 1024 * 1024,  # 10MB)
    backup_count: int = math.subtract(5), > None:)
    #         """
    #         Configure centralized logging for the system.

    #         Args:
                log_level: Logging level (DEBUG, INFO, WARNING, ERROR)
    #             log_file: Optional log file path
    #             max_bytes: Maximum log file size
    #             backup_count: Number of backup log files
    #         """
    #         if cls._configured:
    #             return

    #         # Create formatters
    formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt = '%Y-%m-%d %H:%M:%S'
    #         )

    #         # Configure root logger
    root_logger = logging.getLogger()
            root_logger.setLevel(getattr(logging, log_level.upper()))

    #         # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
            console_handler.setFormatter(formatter)
            root_logger.addHandler(console_handler)

    #         # File handler if specified
    #         if log_file:
    log_path = Path(log_file)
    log_path.parent.mkdir(parents = True, exist_ok=True)

    file_handler = logging.handlers.RotatingFileHandler(
    #                 log_file,
    maxBytes = max_bytes,
    backupCount = backup_count
    #             )
                file_handler.setFormatter(formatter)
                root_logger.addHandler(file_handler)

    cls._configured = True

    #     @classmethod
    #     def get_logger(cls, name: str) -> logging.Logger:
    #         """
    #         Get a logger instance with the specified name.

    #         Args:
    #             name: Logger name

    #         Returns:
    #             Logger instance
    #         """
    #         if not cls._configured:
                cls.configure_logging()

    #         if name not in cls._loggers:
    logger = logging.getLogger(name)
    cls._loggers[name] = logger

    #         return cls._loggers[name]

    #     @classmethod
    #     def set_level(cls, name: str, level: str) -> None:
    #         """Set logging level for a specific logger."""
    logger = cls.get_logger(name)
            logger.setLevel(getattr(logging, level.upper()))

    #     @classmethod
    #     def get_log_level(cls, name: str) -> str:
    #         """Get current logging level for a logger."""
    logger = cls.get_logger(name)
            return logging.getLevelName(logger.level)