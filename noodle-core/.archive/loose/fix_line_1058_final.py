#!/usr/bin/env python3
"""
Noodle Core::Fix Line 1058 Final - fix_line_1058_final.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix unterminated f-string on line 1058 in native_gui_ide.py"""

import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 1058-1059 (unterminated f-string)
if len(lines) > 1058:
    # Replace the broken lines with proper code
    lines[1057] = '            self.terminal_output.insert(\'end\', f"[WARNING] Dependencies: No requirements file found\\n")\n'
    lines[1058] = '        self.terminal_output.insert(\'end\', f"[HEALTH] Overall Health Score: {health_score}/100\\n")\n'
    lines[1059] = '        self.terminal_output.insert(\'end\', "=" * 50 + "\\n")\n'

# Write the file back
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed unterminated f-string on lines 1058-1059")

