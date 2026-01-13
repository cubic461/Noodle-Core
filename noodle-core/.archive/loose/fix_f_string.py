#!/usr/bin/env python3
"""
Noodle Core::Fix F String - fix_f_string.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Quick fix for f-string issue in self_improvement_manager.py
"""

import os
import re

def fix_f_string_issue():
    """Fix the f-string issue in self_improvement_manager.py"""
    file_path = "src/noodlecore/self_improvement/self_improvement_manager.py"
    
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Fix the f-string issue on line 229
        # Replace: logger.error(f"Failed to activate self-improvement system: {str(e)}")
        # With: logger.error(f"Failed to activate self-improvement system: {str(e)}")
        fixed_content = re.sub(
            r'logger\.error\(f"Failed to activate self-improvement system: \{str\(e\)\}"',
            r'logger.error(f"Failed to activate self-improvement system: {str(e)}")',
            content
        )
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)
        
        print(f"Successfully fixed f-string issue in {file_path}")
        return True
        
    except Exception as e:
        print(f"Error fixing f-string issue: {str(e)}")
        return False

if __name__ == "__main__":
    fix_f_string_issue()

