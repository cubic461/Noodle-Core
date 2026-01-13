#!/usr/bin/env python3
"""
Noodle Core::Multi Line String Fix - multi_line_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix for multi-line string issues in native_gui_ide.py
"""

def fix_multi_line_strings():
    """Fix all multi-line string issues in file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the specific problematic section around line 728-736
    old_section = '''            self.terminal_output.insert('end', f"
[READ] {filename}:
")
            self.terminal_output.insert('end', "-" * 50 + "
")
            self.terminal_output.insert('end', content)
            self.terminal_output.insert('end', "
" + "-" * 50 + "
")'''
    
    new_section = '''            self.terminal_output.insert('end', f"\\n[READ] {filename}:\\n")
            self.terminal_output.insert('end', "-" * 50 + "\\n")
            self.terminal_output.insert('end', content)
            self.terminal_output.insert('end', "\\n" + "-" * 50 + "\\n")'''
    
    content = content.replace(old_section, new_section)
    
    # Fix other similar patterns
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to read {filename}: {str(e)}\n")',
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to read {filename}: {str(e)}\\n")'
    )
    
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"[WRITE] Created {filename}\n")',
        '            self.terminal_output.insert(\'end\', f"[WRITE] Created {filename}\\n")'
    )
    
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to write {filename}: {str(e)}\n")',
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to write {filename}: {str(e)}\\n")'
    )
    
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"[MODIFY] Updated {filename}\n")',
        '            self.terminal_output.insert(\'end\', f"[MODIFY] Updated {filename}\\n")'
    )
    
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to modify {filename}: {str(e)}\n")',
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to modify {filename}: {str(e)}\\n")'
    )
    
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to open {filename}: {str(e)}\n")',
        '            self.terminal_output.insert(\'end\', f"[ERROR] Failed to open {filename}: {str(e)}\\n")'
    )
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed multi-line string issues")

if __name__ == "__main__":
    fix_multi_line_strings()

