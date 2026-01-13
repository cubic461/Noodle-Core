#!/usr/bin/env python3
"""
Noodle Core::Fix Line 960 - fix_line_960.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the unterminated f-string on line 960 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Fix the unterminated f-string on line 960 (index 959)
if len(lines) > 959:
    lines[959] = '            self.terminal_output.insert(\'end\', f"\\n[SCAN] Scanning project: {target_path}\\n")\n'

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Fixed unterminated f-string on line 960")

