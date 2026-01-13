#!/usr/bin/env python3
"""
Noodle Core::Fix Line 1057 Final - fix_line_1057_final.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Final fix for unterminated f-string on line 1057 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Fix the unterminated f-string on line 1057 (index 1056)
if len(lines) > 1056:
    lines[1056] = '            self.terminal_output.insert(\'end\', f"[WARNING] Dependencies: No requirements file found\\n")\n'

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Fixed unterminated f-string on line 1057")

