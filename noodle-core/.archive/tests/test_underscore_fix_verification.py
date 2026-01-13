#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_underscore_fix_verification.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the underscore pattern fix
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.noodlecore.compiler.enhanced_parser import EnhancedParser

def test_underscore_pattern():
    """Test underscore pattern in match expression"""
    # Simple test case with underscore pattern and comma separator
    test_code = """
let x = 5;
match x {
    _: 1,
    2: 2
}
"""
    
    print("Testing underscore pattern with comma separator...")
    print(f"Code:\n{test_code}")
    
    try:
        parser = EnhancedParser(test_code, "<test>")
        ast = parser.parse()
        
        # Check if parsing succeeded
        if parser.errors:
            print("Parse errors:")
            for error in parser.errors:
                print(f"  - {error.message} at {error.location}")
        else:
            print("Parse successful!")
            print(f"AST: {ast}")
        
        return len(parser.errors) == 0
    except Exception as e:
        print(f"Exception during parsing: {e}")
        return False

if __name__ == "__main__":
    success = test_underscore_pattern()
    if success:
        print("\nâœ… Underscore pattern test PASSED")
    else:
        print("\nâŒ Underscore pattern test FAILED")

