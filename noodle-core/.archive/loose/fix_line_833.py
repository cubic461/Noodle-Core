#!/usr/bin/env python3
"""
Noodle Core::Fix Line 833 - fix_line_833.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the unterminated f-string on line 833 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Fix the unterminated f-string on line 833 (index 832)
if len(lines) > 832:
    lines[832] = '            self.terminal_output.insert(\'end\', f"\\n[ANALYZE] Project analysis for: {target_path}\\n")\n'

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Fixed unterminated f-string on line 833")

