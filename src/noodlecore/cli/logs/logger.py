"""
Logs::Logger - logger.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore CLI Logger Module
===========================

Provides logging functionality for NoodleCore CLI.
"""

import logging
import sys
from typing import Optional, Dict, Any


class CLILogger:
    """CLI logger for NoodleCore operations."""
    
    def __init__(self, name: str = "noodlecore.cli", level: str = "INFO"):
        """
        Initialize CLI logger.
        
        Args:
            name: Logger name
            level: Log level
        """
        self.logger = logging.getLogger(name)
        self.level = level.upper()
        self.setup_logger()
    
    def setup_logger(self):
        """Setup logger with console handler."""
        # Set level
        numeric_level = getattr(logging, self.level, logging.INFO)
        self.logger.setLevel(numeric_level)
        
        # Create console handler
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(numeric_level)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        
        # Add handler to logger
        if not self.logger.handlers:
            self.logger.addHandler(handler)
    
    def debug(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log debug message."""
        self.logger.debug(message, extra=extra)
    
    def info(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log info message."""
        self.logger.info(message, extra=extra)
    
    def warning(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log warning message."""
        self.logger.warning(message, extra=extra)
    
    def error(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log error message."""
        self.logger.error(message, extra=extra)
    
    def critical(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log critical message."""
        self.logger.critical(message, extra=extra)
    
    def set_level(self, level: str):
        """Set log level."""
        self.level = level.upper()
        numeric_level = getattr(logging, self.level, logging.INFO)
        self.logger.setLevel(numeric_level)
        
        # Update handler level
        for handler in self.logger.handlers:
            handler.setLevel(numeric_level)
    
    def get_level(self) -> str:
        """Get current log level."""
        return self.level
    
    def add_handler(self, handler):
        """Add a handler to the logger."""
        self.logger.addHandler(handler)
    
    def remove_handler(self, handler):
        """Remove a handler from the logger."""
        self.logger.removeHandler(handler)

