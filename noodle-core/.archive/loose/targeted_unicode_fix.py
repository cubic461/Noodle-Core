#!/usr/bin/env python3
"""
Noodle Core::Targeted Unicode Fix - targeted_unicode_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


def fix_unicode_syntax_errors():
    """Fix specific Unicode syntax errors in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the specific Unicode issues causing syntax errors
    content = content.replace('\\U0001f916', 'ðŸ¤–')
    content = content.replace('\\U0001f50d', 'ðŸ”')
    content = content.replace('\\U0001f4be', 'ðŸ’¡')
    content = content.replace('\\U0001f4dd', 'ðŸ“')
    content = content.replace('\\U0001f3e5', 'ðŸ”§')
    content = content.replace('\\U0001f3c5', 'ðŸ“„')
    content = content.replace('\\U0001f4ca', 'ðŸ“Š')
    content = content.replace('\\U0001f527', 'ðŸ”§')
    content = content.replace('\\U0001f4b0', 'ðŸš€')
    content = content.replace('\\U0001f46e', 'ðŸ‘¤')
    content = content.replace('\\U0001f464', 'ðŸ‘¥')
    content = content.replace('\\U0001f50d', 'ðŸ”')
    content = content.replace('\\U0001f4be', 'ðŸ’¡')
    content = content.replace('\\U0001f4dd', 'ðŸ“')
    content = content.replace('\\u2705', 'âœ“')
    content = content.replace('\\u274c', 'âŒ')
    content = content.replace('\\U0001f3e5', 'ðŸ”§')
    content = content.replace('\\U0001f3c5', 'ðŸ“„')
    content = content.replace('\\U0001f4ca', 'ðŸ“Š')
    content = content.replace('\\U0001f4b0', 'ðŸš€')
    content = content.replace('\\U0001f46e', 'ðŸ‘¤')
    content = content.replace('\\U0001f464', 'ðŸ‘¥')
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed Unicode syntax errors in native_gui_ide.py")

if __name__ == "__main__":
    fix_unicode_syntax_errors()

