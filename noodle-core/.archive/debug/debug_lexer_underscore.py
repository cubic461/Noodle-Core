#!/usr/bin/env python3
"""
Noodle Core::Debug Lexer Underscore - debug_lexer_underscore.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug underscore tokenization
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.noodlecore.compiler.enhanced_parser import EnhancedParser

def debug_lexer():
    """Debug underscore tokenization"""
    # Simple test case with underscore pattern and comma separator
    test_code = """
let x = 5;
match x {
    _: 1,
    2: 2
}
"""
    
    print("Testing underscore tokenization...")
    print(f"Code:\n{test_code}")
    
    try:
        parser = EnhancedParser(test_code, "<test>")
        
        # Print tokens for debugging
        print("\nTokens:")
        for i, token in enumerate(parser.tokens):
            print(f"  {i}: {token.type.value} '{token.value}' at {token.location}")
        
        return True
    except Exception as e:
        print(f"Exception during tokenization: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = debug_lexer()
    if success:
        print("\nâœ… Lexer test PASSED")
    else:
        print("\nâŒ Lexer test FAILED")

