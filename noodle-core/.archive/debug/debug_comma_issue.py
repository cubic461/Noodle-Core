#!/usr/bin/env python3
"""
Noodle Core::Debug Comma Issue - debug_comma_issue.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to understand the comma handling issue in match expressions.
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser

def test_comma_handling():
    """Test comma handling in match expressions"""
    code = """
let x = 5;
match x {
    _: 1,
    2: 2
}
"""
    
    print("Code:")
    print(code)
    print("\n" + "="*50)
    
    parser = EnhancedParser(code, "<test>")
    
    print("Tokens:")
    for i, token in enumerate(parser.tokens):
        print(f"  {i}: {token.type.value} '{token.value}' at {token.location}")
    
    print("\n" + "="*50)
    print("Parsing step by step...")
    
    try:
        # First, let's see what happens when we parse the match expression
        # We'll manually call _parse_match_expression to see what's happening
        
        # Skip to the MATCH token
        while not parser._match(parser.tokens[0].__class__.MATCH if hasattr(parser.tokens[0].__class__, 'MATCH') else None):
            parser._advance()
            if parser._match(parser.tokens[0].__class__.EOF if hasattr(parser.tokens[0].__class__, 'EOF') else None):
                break
        
        if parser._match(parser.tokens[0].__class__.MATCH if hasattr(parser.tokens[0].__class__, 'MATCH') else None):
            print("Found MATCH token, calling _parse_match_expression...")
            match_expr = parser._parse_match_expression()
            if match_expr:
                print("SUCCESS: Match expression parsed successfully")
                print(f"Match expression: {match_expr}")
            else:
                print("FAILED: Match expression parsing returned None")
        else:
            print("FAILED: Could not find MATCH token")
            
    except Exception as e:
        print(f"Exception during parsing: {e}")
        import traceback
        traceback.print_exc()
    
    print("\n" + "="*50)
    print("Full parse result:")
    
    # Try a full parse
    parser = EnhancedParser(code, "<test>")
    ast = parser.parse()
    
    if parser.errors:
        print("Parse errors:")
        for error in parser.errors:
            print(f"  - {error.message} at {error.location}")
    else:
        print("SUCCESS: No parse errors")

if __name__ == "__main__":
    test_comma_handling()

