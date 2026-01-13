#!/usr/bin/env python3
"""
Noodle Core::Debug Underscore Step By Step - debug_underscore_step_by_step.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug underscore pattern parsing step by step
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.noodlecore.compiler.enhanced_parser import EnhancedParser

def debug_underscore_parsing():
    """Debug underscore pattern parsing step by step"""
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
        
        # Print tokens for debugging
        print("\nTokens:")
        for i, token in enumerate(parser.tokens):
            print(f"  {i}: {token.type.value} '{token.value}' at {token.location}")
        
        # Try to parse step by step
        print("\nParsing step by step:")
        ast = parser.parse()
        
        # Check if parsing succeeded
        if parser.errors:
            print("\nParse errors:")
            for error in parser.errors:
                print(f"  - {error.message} at {error.location}")
        else:
            print("\nParse successful!")
            print(f"AST: {ast}")
        
        return len(parser.errors) == 0
    except Exception as e:
        print(f"Exception during parsing: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = debug_underscore_parsing()
    if success:
        print("\nâœ… Underscore pattern test PASSED")
    else:
        print("\nâŒ Underscore pattern test FAILED")

