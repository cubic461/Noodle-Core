#!/usr/bin/env python3
"""
Noodle Core::Debug Underscore Detailed - debug_underscore_detailed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Detailed debug script for underscore token handling in match expressions.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def debug_simple_underscore():
    """Debug simple underscore pattern"""
    
    # Test case: Simple underscore pattern
    test_code = 'match x { _ => "wildcard" }'
    
    print("Testing simple underscore pattern...")
    print("Code:", repr(test_code))
    
    # First, let's see what tokens are generated
    parser = EnhancedParser(test_code, "<test>")
    print("\nTokens:")
    for i, token in enumerate(parser.tokens):
        print(f"  {i}: {token.type.value} = {repr(token.value)}")
    
    print("\nParsing...")
    ast = parser.parse()
    
    if parser.errors:
        print("\nParser errors:")
        for error in parser.errors:
            print(f"  - {error}")
    else:
        print("\nParsing successful!")
        if ast:
            print(f"AST: {ast}")

if __name__ == "__main__":
    debug_simple_underscore()

