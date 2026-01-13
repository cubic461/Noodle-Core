#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_token_comparison.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test to verify TokenType comparison between lexer and parser
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from simple_lexer import SimpleLexer, TokenType as LexerTokenType, Token as LexerToken, SourceLocation as LexerSourceLocation
from src.noodlecore.compiler.enhanced_parser import EnhancedParser, TokenType as ParserTokenType

def test_token_comparison():
    """Test if TokenType from lexer and parser are compatible"""
    
    # Test lexer tokenization
    source = "match x { case _: true }"
    lexer = SimpleLexer(source, "test")
    tokens = lexer.tokenize()
    
    print("Tokens from lexer:")
    for token in tokens:
        print(f"  {token.type} ({token.type.value}): '{token.value}'")
    
    # Check if TokenType.UNDERSCORE from lexer matches parser's TokenType.UNDERSCORE
    underscore_token = None
    for token in tokens:
        if token.type == LexerTokenType.UNDERSCORE:
            underscore_token = token
            break
    
    if underscore_token:
        print(f"\nFound underscore token: {underscore_token.type} ({underscore_token.type.value})")
        
        # Check if parser's TokenType.UNDERSCORE is the same
        print(f"Parser's TokenType.UNDERSCORE: {ParserTokenType.UNDERSCORE} ({ParserTokenType.UNDERSCORE.value})")
        
        # Check if they are the same enum
        print(f"Are they the same enum? {LexerTokenType.UNDERSCORE == ParserTokenType.UNDERSCORE}")
        print(f"LexerTokenType.UNDERSCORE is ParserTokenType.UNDERSCORE? {LexerTokenType.UNDERSCORE is ParserTokenType.UNDERSCORE}")
        
        # Test parser
        parser = EnhancedParser(source, "test")
        try:
            ast = parser.parse()
            print("\nParser succeeded!")
            print(f"Errors: {parser.errors}")
        except Exception as e:
            print(f"\nParser failed: {e}")
            print(f"Errors: {parser.errors}")
    else:
        print("\nNo underscore token found in lexer output")

if __name__ == "__main__":
    test_token_comparison()

