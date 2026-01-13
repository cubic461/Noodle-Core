#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_underscore_tokens.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to examine token handling for underscore patterns
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

def test_underscore_tokens():
    """Test underscore token handling in detail"""
    
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
    
    print("\nTesting parser step by step...")
    # Test parser with detailed debugging
    parser = EnhancedParser(code1, "test.nc")
    
    # Manually step through the parsing process
    print(f"Current token position: {parser.position}")
    print(f"Current token: {parser._current_token().type.value}")
    
    # Try to parse the match case manually
    if parser._match(TokenType.MATCH):
        print("Found MATCH token")
        parser._advance()  # Consume MATCH
        
        if parser._match(TokenType.IDENTIFIER):
            print("Found IDENTIFIER token (x)")
            parser._advance()  # Consume x
            
            if parser._match(TokenType.LBRACE):
                print("Found LBRACE token")
                parser._advance()  # Consume {
                
                if parser._match(TokenType.CASE):
                    print("Found CASE token")
                    parser._advance()  # Consume CASE
                    
                    # Now try to parse the pattern
                    print(f"Before parsing pattern: position={parser.position}, token={parser._current_token().type.value}")
                    pattern = parser._parse_pattern()
                    print(f"After parsing pattern: position={parser.position}, pattern={pattern}")
                    
                    if pattern:
                        print("Pattern parsed successfully")
                        
                        # Check for arrow or colon
                        print(f"Current token after pattern: {parser._current_token().type.value}")
                        
                        if parser._match(TokenType.ARROW):
                            print("Found ARROW token, consuming")
                            parser._advance()
                        elif parser._match(TokenType.COLON):
                            print("Found COLON token, consuming")
                            parser._advance()
                        else:
                            print(f"ERROR: Expected ARROW or COLON, got {parser._current_token().type.value}")
                    else:
                        print("ERROR: Failed to parse pattern")
                else:
                    print("ERROR: Expected CASE token after {")
            else:
                print(f"ERROR: Expected IDENTIFIER after MATCH, got {parser._current_token().type.value}")
        else:
            print(f"ERROR: Expected MATCH token, got {parser._current_token().type.value}")
    
    print(f"Final position: {parser.position}")
    print(f"Final token: {parser._current_token().type.value}")
    
    # Exit to avoid infinite loop
    sys.exit(0)

if __name__ == "__main__":
    test_underscore_tokens()

