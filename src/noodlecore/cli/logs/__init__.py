"""
Logs::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore CLI Logs Module
=========================

Provides logging functionality for NoodleCore CLI.
"""

from .logger import CLILogger
from .alert_manager import AlertManager

__all__ = [
    'CLILogger',
    'AlertManager'
]

