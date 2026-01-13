#!/usr/bin/env python3
"""
Noodle Core::Fix Line 918 - fix_line_918.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the unterminated f-string on line 918 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Fix the unterminated f-string on line 918 (index 917)
if len(lines) > 917:
    lines[917] = '            self.terminal_output.insert(\'end\', f"\\n[OVERVIEW] Project overview for: {target_path}\\n")\n'

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Fixed unterminated f-string on line 918")

