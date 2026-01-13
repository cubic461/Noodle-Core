#!/usr/bin/env python3
"""
Noodle Core::Check Config - check_config.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import json
from pathlib import Path

config_file = Path.home() / '.noodlecore' / 'ai_config.json'
print('Config file exists:', config_file.exists())
if config_file.exists():
    print('Content:', config_file.read_text())

