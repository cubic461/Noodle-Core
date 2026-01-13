#!/usr/bin/env python3
"""
Noodle Core::Simple Syntax Fix - simple_syntax_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


def fix_syntax_errors():
    """Fix critical syntax errors in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix 1: Ensure proper newline after shebang
    content = content.replace('#!/usr/bin/env python3"""', '#!/usr/bin/env python3\n"""')
    
    # Fix 2: Fix the broken execute_ai_file_command method
    content = content.replace('if Command[\'type\'] == \'read\':', 'if command[\'type\'] == \'read\':')
    content = content.replace('elif Command[\'type\'] == \'write\':', 'elif command[\'type\'] == \'write\':')
    content = content.replace('elif Command[\'type\'] == \'modify\':', 'elif command[\'type\'] == \'modify\':')
    content = content.replace('elif Command[\'type\'] == \'analyze\':', 'elif command[\'type\'] == \'analyze\':')
    
    # Fix 3: Remove duplicate except block in _update_project_index
    lines = content.split('\n')
    new_lines = []
    skip_next = False
    for i, line in enumerate(lines):
        if 'except Exception as e:' in line and i+1 < len(lines) and 'except Exception as e:' in lines[i+1]:
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
    
    print("Fixed critical syntax errors in native_gui_ide.py")

if __name__ == "__main__":
    fix_syntax_errors()

