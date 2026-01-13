#!/usr/bin/env python3
"""
Noodle Core::Unicode Fix - unicode_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


import re

def fix_unicode_issues():
    """Fix Unicode character issues in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix 1: Replace all Unicode escape sequences with regular characters
    content = re.sub(r'\\U0001f[0-9a-f][0-9a-f]', lambda m: chr(int(m.group(0), 16)), content)
    
    # Fix 2: Replace all Unicode escape sequences with regular characters
    content = re.sub(r'\\u[0-9a-f][0-9a-f]', lambda m: chr(int(m.group(0), 16)), content)
    
    # Fix 3: Replace all Unicode escape sequences with regular characters
    content = re.sub(r'\\U0001f[0-9a-f][0-9a-f]', lambda m: chr(int(m.group(0), 16)), content)
    
    # Fix 4: Replace all Unicode escape sequences with regular characters
    content = re.sub(r'\\u2705', 'âœ“', content)
    content = re.sub(r'\\u274c', 'âŒ', content)
    content = re.sub(r'\\U0001f50d', 'ðŸ”', content)
    content = re.sub(r'\\U0001f4be', 'ðŸ’¡', content)
    content = re.sub(r'\\U0001f4dd', 'ðŸ“', content)
    content = re.sub(r'\\u2705', 'âœ…', content)
    content = re.sub(r'\\u274c', 'âŒ', content)
    content = re.sub(r'\\U0001f916', 'ðŸ¤–', content)
    content = re.sub(r'\\U0001f50d', 'ðŸ”', content)
    content = re.sub(r'\\U0001f4be', 'ðŸ’¡', content)
    content = re.sub(r'\\U0001f4dd', 'ðŸ“', content)
    content = re.sub(r'\\U0001f3e5', 'ðŸ”§', content)
    content = re.sub(r'\\U0001f3c5', 'ðŸ“„', content)
    content = re.sub(r'\\U0001f4ca', 'ðŸ“Š', content)
    content = re.sub(r'\\U0001f527', 'ðŸ”§', content)
    content = re.sub(r'\\U0001f4b0', 'ðŸš€', content)
    content = re.sub(r'\\U0001f46e', 'ðŸ‘¤', content)
    content = re.sub(r'\\U0001f464', 'ðŸ‘¥', content)
    content = re.sub(r'\\U0001f527', 'ðŸ”§', content)
    content = re.sub(r'\\U0001f3c5', 'ðŸ“„', content)
    content = re.sub(r'\\U0001f4ca', 'ðŸ“Š', content)
    content = re.sub(r'\\U0001f4b0', 'ðŸš€', content)
    content = re.sub(r'\\U0001f46e', 'ðŸ‘¤', content)
    content = re.sub(r'\\U0001f464', 'ðŸ‘¥', content)
    content = re.sub(r'\\U0001f527', 'ðŸ”§', content)
    content = re.sub(r'\\U0001f3c5', 'ðŸ“„', content)
    content = re.sub(r'\\U0001f4ca', 'ðŸ“Š', content)
    content = re.sub(r'\\U0001f4b0', 'ðŸš€', content)
    content = re.sub(r'\\U0001f46e', 'ðŸ‘¤', content)
    content = re.sub(r'\\U0001f464', 'ðŸ‘¥', content)
    
    # Fix 5: Fix the broken execute_ai_file_command method
    content = content.replace('if Command[\'type\'] == \'read\':', 'if command[\'type\'] == \'read\':')
    content = content.replace('elif Command[\'type\'] == \'write\':', 'elif command[\'type\'] == \'write\':')
    content = content.replace('elif Command[\'type\'] == \'modify\':', 'elif command[\'type\'] == \'modify\':')
    content = content.replace('elif Command[\'type\'] == \'analyze\':', 'elif command[\'type\'] == \'analyze\':')
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed Unicode character issues in native_gui_ide.py")

if __name__ == "__main__":
    fix_unicode_issues()

