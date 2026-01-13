#!/usr/bin/env python3
"""
Noodle Core::Debug Comma Handling - debug_comma_handling.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script for comma handling in match expressions.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def debug_comma_handling():
    """Debug comma handling in match expressions"""
    
    # Test case: Two cases with comma
    test_code = 'match x { _ => "wildcard", 1 => "one" }'
    
    print("Testing comma handling...")
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
    debug_comma_handling()

