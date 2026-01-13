#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_lexer_debug.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to check lexer output
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser

def test_lexer():
    """Test lexer output"""
    test_code = """
    let x = 42;
    match x {
        case 1:
            return "one";
    }
    """
    
    try:
        parser = EnhancedParser(test_code, "test_lexer")
        
        print("Tokens:")
        for i, token in enumerate(parser.tokens):
            print(f"  {i}: {token.type} = '{token.value}' at {token.location}")
        
        print(f"\nNumber of tokens: {len(parser.tokens)}")
        
        if not parser.tokens:
            print("No tokens generated - using fallback lexer")
        
        return True
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_lexer()

