#!/usr/bin/env python3
"""
Noodle Core::Fix Line 989 - fix_line_989.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the unterminated string on line 989 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Fix the unterminated string on line 989 (index 988)
if len(lines) > 988:
    lines[988] = '        self.terminal_output.insert(\'end\', "\\n[VALIDATE] Validating all .nc files...\\n")\n'

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Fixed unterminated string on line 989")

