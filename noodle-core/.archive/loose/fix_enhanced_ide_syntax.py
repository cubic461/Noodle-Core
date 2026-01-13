#!/usr/bin/env python3
"""
Noodle Core::Fix Enhanced Ide Syntax - fix_enhanced_ide_syntax.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix syntax error in enhanced_native_ide_complete.py at line 1801"""

import os

def fix_syntax_error():
    file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'enhanced_native_ide_complete.py')
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix the syntax error at line 1801 - missing except/finally block
    if len(lines) > 1800:
        # Line 1801 has the issue
        line_1800 = lines[1799].strip()
        line_1801 = lines[1800].strip()
        
        # Fix the syntax error by adding proper exception handling
        if 'except Exception as e:' in line_1801 and 'finally:' in line_1801:
            # The line is already correct, check the next line
            if len(lines) > 1801:
                line_1802 = lines[1801].strip()
                if line_1802.startswith('except Exception:'):
                    # Replace with proper exception handling
                    lines[1801] = '                except Exception as e:\n                    print(f"âŒ Failed to start Enhanced NoodleCore IDE: {str(e)}")\n                finally:\n                    threading.Thread(target=periodic_analysis, daemon=True).start()'
                else:
                    # Add the missing finally block
                    lines.insert(1801, '                except Exception as e:\n                    print(f"âŒ Failed to start Enhanced NoodleCore IDE: {str(e)}")\n            finally:\n                    threading.Thread(target=periodic_analysis, daemon=True).start()')
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed syntax error at line 1801 in {file_path}")

if __name__ == "__main__":
    fix_syntax_error()

