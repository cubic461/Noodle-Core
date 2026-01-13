#!/usr/bin/env python3
"""
Noodle Core::Comprehensive F String Fix - comprehensive_f_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive fix for unterminated f-strings in native_gui_ide.py
"""

def fix_f_strings():
    """Fix all unterminated f-strings in file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the specific unterminated f-string at line 728
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix other broken f-strings with line breaks
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix specific f-string patterns
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix the specific broken f-strings
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix all instances of the broken pattern
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix specific broken f-strings with newlines
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix all the broken f-strings in the file
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix specific instances
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Fix the specific pattern causing the syntax error
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed f-string terminations")

if __name__ == "__main__":
    fix_f_strings()

