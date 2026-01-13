#!/usr/bin/env python3
"""
Noodle Core::Comprehensive Fix - comprehensive_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


def fix_native_gui_ide_comprehensive():
    """Comprehensive fix for all syntax issues in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix 1: Ensure proper newline after shebang
    if lines[0].startswith('#!/usr/bin/env python3"""'):
        lines[0] = '#!/usr/bin/env python3\n'
    
    # Fix 2: Fix the docstring indentation
    if len(lines) > 1 and lines[1].startswith('"""NoodleCore'):
        lines[1] = '"""NoodleCore Native GUI IDE - Enhanced Canonical Implementation\n'
    
    # Fix 3: Fix the broken execute_ai_file_command method
    for i, line in enumerate(lines):
        if 'if Command[' in line:
            lines[i] = line.replace('if Command[', 'if command[')
        elif 'elif Command[' in line:
            lines[i] = line.replace('elif Command[', 'elif command[')
    
    # Fix 4: Fix the broken _update_project_index method
    for i, line in enumerate(lines):
        if 'except Exception as e:' in line and i+1 < len(lines) and 'except Exception as e:' in lines[i+1]:
            # Remove duplicate except block
            lines[i+1] = ''
    
    # Fix 5: Fix the broken run() method
    in_run_method = False
    run_method_start = -1
    for i, line in enumerate(lines):
        if 'def run(self):' in line:
            in_run_method = True
            run_method_start = i
        elif in_run_method and line.strip().startswith('return 0  # Success exit code') and i+1 < len(lines):
            # Fix the broken method structure
            lines[i+1] = '        except KeyboardInterrupt:\n'
            lines[i+2] = '            safe_print("IDE interrupted by user")\n'
            lines[i+3] = '            return 1\n'
            lines[i+4] = '        except Exception as e:\n'
            lines[i+5] = '            safe_print(f"IDE error: {e}")\n'
            lines[i+6] = '            return 1'
            in_run_method = False
            break
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("Comprehensive fix applied to native_gui_ide.py")

if __name__ == "__main__":
    fix_native_gui_ide_comprehensive()

