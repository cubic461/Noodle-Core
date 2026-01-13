#!/usr/bin/env python3
"""
Noodle Core::Debug Parser Detailed - debug_parser_detailed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to test parser token handling in detail
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try:
    from noodlecore.compiler.enhanced_parser import EnhancedParser
    from simple_lexer import SimpleLexer, TokenType
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

def test_parser_detailed():
    """Test parser with detailed debugging"""
    
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
    
    print("\nTesting parser with debug...")
    # Test parser with debug
    parser = EnhancedParser(code1, "test.nc")
    
    # Add debug prints to parser
    print(f"Current token before parsing: {parser._current_token().type.value}")
    
    # Try to parse pattern directly
    try:
        pattern = parser._parse_pattern()
        if pattern:
            print(f"Pattern created successfully: {type(pattern)}")
        else:
            print("Pattern creation failed")
    except Exception as e:
        print(f"Exception in _parse_pattern: {e}")
        import traceback
        traceback.print_exc()
    
    # Try full parse
    try:
        ast = parser.parse()
        print(f"Parse errors: {len(parser.errors)}")
        for error in parser.errors:
            print(f"  - {error.message} at {error.location}")
        
        # Print AST if successful
        if len(parser.errors) == 0:
            print("AST generated successfully!")
            print(f"AST type: {type(ast)}")
    except Exception as e:
        print(f"Exception in parse: {e}")
        import traceback
        traceback.print_exc()
    
    print()

if __name__ == "__main__":
    test_parser_detailed()

