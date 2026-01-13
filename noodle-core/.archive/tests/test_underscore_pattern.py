#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_underscore_pattern.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test underscore pattern specifically
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from simple_lexer import SimpleLexer, TokenType, Token, SourceLocation
from src.noodlecore.compiler.enhanced_parser import EnhancedParser

def test_underscore_pattern():
    """Test underscore pattern in match expression"""
    
    # Test simple match with underscore
    source = """
    match x {
        case _: {
            return true;
        }
    }
    """
    
    print("Testing source code:")
    print(source)
    
    # Test lexer
    lexer = SimpleLexer(source, "test")
    tokens = lexer.tokenize()
    
    print("\nTokens from lexer:")
    for token in tokens:
        print(f"  {token.type} ({token.type.value}): '{token.value}'")
    
    # Test parser
    parser = EnhancedParser(source, "test")
    try:
        ast = parser.parse()
        print("\nParser succeeded!")
        print(f"Errors: {parser.errors}")
        print(f"Warnings: {parser.warnings}")
        
        # Print AST structure
        print("\nAST structure:")
        print(ast.to_dict())
    except Exception as e:
        print(f"\nParser failed: {e}")
        print(f"Errors: {parser.errors}")

if __name__ == "__main__":
    test_underscore_pattern()

