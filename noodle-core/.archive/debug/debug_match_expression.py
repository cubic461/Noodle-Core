#!/usr/bin/env python3
"""
Noodle Core::Debug Match Expression - debug_match_expression.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to test match expression parsing
"""

import sys
import os
import json

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser
from simple_lexer import SimpleLexer

def test_match_expression():
    source = "match x { case _: true }"
    filename = "test"
    
    print(f"Testing source code: {source}")
    print()
    
    # Create lexer and tokenize
    lexer = SimpleLexer(source, filename)
    tokens = lexer.tokenize()
    
    print("Tokens from lexer:")
    for token in tokens:
        print(f"  {token.type} ({token.type.name}): '{token.value}'")
    print()
    
    # Create parser and parse
    parser = EnhancedParser(source, filename)
    
    # Debug: Check what happens when parsing match expression
    print("Parsing match expression...")
    try:
        # Get the current position before parsing
        print(f"Initial position: {parser.position}, current token: {parser._current_token().type}")
        
        # Parse match expression
        match_expr = parser._parse_match_expression()
        print(f"Match expression parsed: {match_expr}")
        print(f"After parsing match expression, position: {parser.position}, current token: {parser._current_token().type}")
        
        # Check if the match expression has the right type
        if match_expr and hasattr(match_expr, 'type'):
            print(f"Match expression type: {match_expr.type}")
            print(f"Is MATCH_EXPRESSION: {match_expr.type == parser.factory.create_match_expression_node.__code__.co_consts[0] if hasattr(parser.factory.create_match_expression_node, '__code__') else 'unknown'}")
        
    except Exception as e:
        print(f"Error parsing match expression: {e}")
        import traceback
        traceback.print_exc()
    
    print()
    
    # Parse the full program
    try:
        ast = parser.parse()
        print("Parser succeeded!")
        print(f"Errors: {parser.errors}")
        print(f"Warnings: {parser.warnings}")
        print()
        print("AST structure:")
        print(json.dumps(ast.to_dict(), indent=2))
    except Exception as e:
        print(f"Parser failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_match_expression()

