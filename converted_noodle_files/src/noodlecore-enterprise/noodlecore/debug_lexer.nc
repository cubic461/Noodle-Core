# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Debug script for the Noodle lexer
# """

import sys
import os

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer

function debug_lexer()
    #     """Debug the lexer functionality"""
    source = "x + 5"
    #     print(f"Debugging lexer with source: '{source}'")

    #     # Create lexer
    lexer = Lexer("<string>", source)

        print(f"Lexer created successfully")
        print(f"Lexer tokens: {lexer.tokens}")

    #     # Try to tokenize manually
        print(f"\nManual tokenization:")
    #     for token in lexer.tokens:
            print(f"Token: {token}")

    #     # Check if tokenize method exists
    #     if hasattr(lexer, 'tokenize'):
            print(f"\nCalling tokenize method:")
            lexer.tokenize()
            print(f"Tokens after tokenize: {lexer.tokens}")
    #     else:
            print(f"\nNo tokenize method found")

    #     # Check pattern matcher
    #     if hasattr(lexer, 'pattern_matcher'):
            print(f"\nPattern matcher:")
            print(f"Pattern matcher: {lexer.pattern_matcher}")

    #         # Try to match patterns
    #         if lexer.pattern_matcher:
    matches = lexer.pattern_matcher.match_patterns(source)
                print(f"Matches found: {matches}")
    #     else:
            print(f"\nNo pattern matcher found")

if __name__ == "__main__"
        debug_lexer()
