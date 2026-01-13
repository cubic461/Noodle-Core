#!/usr/bin/env python3
"""
Noodle Core::Targeted Line 728 Fix - targeted_line_728_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Targeted fix for unterminated f-string at line 728 in native_gui_ide.py
"""

def fix_line_728():
    """Fix the specific unterminated f-string at line 728"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix line 728 - the unterminated f-string
    # Line 728: self.terminal_output.insert('end', f"
    # Should be: self.terminal_output.insert('end', f"\n[READ] {filename}:\n")
    
    # Replace the problematic section
    for i, line in enumerate(lines):
        if i == 727:  # Line 728 (0-indexed)
            if 'self.terminal_output.insert(\'end\', f"' in line:
                lines[i] = '            self.terminal_output.insert(\'end\', f"\\n[READ] {filename}:\\n")\n'
    
    # Write back the fixed content
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("Fixed line 728 f-string termination")

if __name__ == "__main__":
    fix_line_728()

