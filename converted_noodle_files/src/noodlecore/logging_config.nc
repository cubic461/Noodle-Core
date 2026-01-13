# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Logging Configuration for NoodleCore IDE
# Implements logging framework with DEBUG, INFO, ERROR, WARNING levels
# """

import logging
import os
import sys
import pathlib.Path
import datetime.datetime
import typing.Optional


class NoodleCoreLogger
    #     """NoodleCore logging configuration manager."""

    #     def __init__(self, name: str = "noodlecore.ide"):
    self.name = name
    self.logger = logging.getLogger(name)
            self._setup_logger()

    #     def _setup_logger(self) -> None:
    #         """Setup logger with proper configuration."""
    #         try:
    #             # Get log level from environment
    debug_mode = os.getenv('NOODLE_DEBUG', '0') == '1'
    #             log_level = logging.DEBUG if debug_mode else logging.INFO

    #             # Create logs directory
    logs_dir = Path('logs')
    logs_dir.mkdir(exist_ok = True)

    #             # Create timestamped log filename
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_filename = logs_dir / f'noodlecore_ide_{timestamp}.log'

    #             # Setup formatters
    detailed_formatter = logging.Formatter(
                    '%(asctime)s - %(name)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s'
    #             )
    simple_formatter = logging.Formatter(
                    '%(asctime)s - %(levelname)s - %(message)s'
    #             )

    #             # Setup handlers
    #             # File handler for detailed logging
    file_handler = logging.FileHandler(log_filename, encoding='utf-8')
                file_handler.setLevel(logging.DEBUG)
                file_handler.setFormatter(detailed_formatter)

    #             # Console handler for important messages
    console_handler = logging.StreamHandler(sys.stdout)
                console_handler.setLevel(log_level)
                console_handler.setFormatter(simple_formatter)

    #             # Error file handler for errors and above
    error_filename = logs_dir / f'noodlecore_ide_errors_{timestamp}.log'
    error_handler = logging.FileHandler(error_filename, encoding='utf-8')
                error_handler.setLevel(logging.ERROR)
                error_handler.setFormatter(detailed_formatter)

    #             # Configure logger
                self.logger.setLevel(logging.DEBUG)
                self.logger.addHandler(file_handler)
                self.logger.addHandler(console_handler)
                self.logger.addHandler(error_handler)

    #             # Prevent duplicate logging
    self.logger.propagate = False

                self.logger.info(f"Logger initialized - Debug mode: {debug_mode}")

    #         except Exception as e:
    #             # Fallback to basic logging if setup fails
    logging.basicConfig(level = logging.INFO)
                print(f"Failed to setup advanced logging: {e}")
    self.logger = logging.getLogger(self.name)

    #     def debug(self, message: str, **kwargs) -> None:
    #         """Log debug message."""
    self.logger.debug(message, extra = kwargs)

    #     def info(self, message: str, **kwargs) -> None:
    #         """Log info message."""
    self.logger.info(message, extra = kwargs)

    #     def warning(self, message: str, **kwargs) -> None:
    #         """Log warning message."""
    self.logger.warning(message, extra = kwargs)

    #     def error(self, message: str, **kwargs) -> None:
    #         """Log error message."""
    self.logger.error(message, extra = kwargs)

    #     def critical(self, message: str, **kwargs) -> None:
    #         """Log critical message."""
    self.logger.critical(message, extra = kwargs)


def get_logger(name: str = "noodlecore.ide") -> NoodleCoreLogger:
#     """Get or create a NoodleCore logger instance."""
    return NoodleCoreLogger(name)


def setup_layout_logging() -> NoodleCoreLogger:
#     """Setup logging specifically for layout operations."""
    return get_logger("noodlecore.ide.layout")


def setup_config_logging() -> NoodleCoreLogger:
#     """Setup logging specifically for configuration operations."""
    return get_logger("noodlecore.ide.config")


def setup_gui_logging() -> NoodleCoreLogger:
#     """Setup logging specifically for GUI operations."""
    return get_logger("noodlecore.ide.gui")