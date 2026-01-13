#!/usr/bin/env python3
"""
Noodle Core::Complete Unicode Fix - complete_unicode_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


def fix_all_unicode_issues():
    """Fix all Unicode character issues in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace all Unicode escape sequences with regular characters
    # This is a comprehensive mapping of all Unicode characters that might cause issues
    unicode_replacements = {
        '\\U0001f916': 'ðŸ¤–',
        '\\U0001f50d': 'ðŸ”',
        '\\U0001f4be': 'ðŸ’¡',
        '\\U0001f4dd': 'ðŸ“',
        '\\U0001f3e5': 'ðŸ”§',
        '\\U0001f3c5': 'ðŸ“„',
        '\\U0001f4ca': 'ðŸ“Š',
        '\\U0001f527': 'ðŸ”§',
        '\\U0001f464': 'ðŸ‘¤',
        '\\U0001f46e': 'ðŸ‘¥',
        '\\U0001f527': 'ðŸ”§',
        '\\U0001f3c5': 'ðŸ“„',
        '\\U0001f4ca': 'ðŸ“Š',
        '\\U0001f4b0': 'ðŸš€',
        '\\u2705': 'âœ…',
        '\\u274c': 'âŒ',
        '\\U0001f4b0': 'ðŸš€',
        '\\U0001f46e': 'ðŸ‘¤',
        '\\U0001f464': 'ðŸ‘¥',
        '\\U0001f527': 'ðŸ”§',
        '\\U0001f3c5': 'ðŸ“„',
        '\\U0001f4ca': 'ðŸ“Š',
        '\\U0001f4b0': 'ðŸš€',
        '\\U0001f46e': 'ðŸ‘¤',
        '\\U0001f464': 'ðŸ‘¥'
    }
    
    # Apply all replacements
    for unicode_seq, regular_char in unicode_replacements.items():
        content = content.replace(unicode_seq, regular_char)
    
    # Fix the broken execute_ai_file_command method
    content = content.replace('if Command[\'type\'] == \'read\':', 'if command[\'type\'] == \'read\':')
    content = content.replace('elif Command[\'type\'] == \'write\':', 'elif command[\'type\'] == \'write\':')
    content = content.replace('elif Command[\'type\'] == \'modify\':', 'elif command[\'type\'] == \'modify\':')
    content = content.replace('elif Command[\'type\'] == \'analyze\':', 'elif command[\'type\'] == \'analyze\':')
    
    # Fix the broken _update_project_index method
    lines = content.split('\n')
    new_lines = []
    skip_next = False
    for i, line in enumerate(lines):
        if 'except Exception as e:' in line and i+1 < len(lines) and 'except Exception as e:' in lines[i+1]:
            # Remove duplicate except block
            skip_next = True
        elif skip_next and 'except Exception as e:' in line:
            # Skip the duplicate except block
            continue
        else:
            skip_next = False
            new_lines.append(line)
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(new_lines))
    
    print("Fixed all Unicode character issues in native_gui_ide.py")

if __name__ == "__main__":
    fix_all_unicode_issues()

