#!/usr/bin/env python3
"""
Noodle Core::Debug Underscore - debug_underscore.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to test underscore token handling
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try:
    from noodlecore.compiler.enhanced_parser import EnhancedParser
    from simple_lexer import SimpleLexer, TokenType
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

def test_underscore_token():
    """Test underscore token handling"""
    
    # Test 1: Simple underscore in pattern context
    code1 = """
    match x {
        _ => "default"
    }
    """
    
    print("Test 1: Simple underscore in pattern context")
    print(f"Code: {code1.strip()}")
    
    # Test lexer directly
    lexer = SimpleLexer(code1, "test.nc")
    tokens = lexer.tokenize()
    
    print("Tokens:")
    for i, token in enumerate(tokens):
        print(f"  {i}: {token.type.value} = '{token.value}' at line {token.location.line}, col {token.location.column}")
    
    print("\nTesting parser...")
    # Test parser
    parser = EnhancedParser(code1, "test.nc")
    try:
        ast = parser.parse()
        print(f"Parse errors: {len(parser.errors)}")
        for error in parser.errors:
            print(f"  - {error.message} at {error.location}")
    except Exception as e:
        print(f"Exception: {e}")
    
    print()
    
    # Exit to avoid infinite loop
    sys.exit(0)

if __name__ == "__main__":
    test_underscore_token()

