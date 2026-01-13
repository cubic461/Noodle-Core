# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Debug script to understand parser token consumption
# """

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.tokenize
import noodlecore.compiler.lexer_tokens.TokenType

function debug_tokens(source_code)
    #     """Debug token generation"""
        print(f"Debugging tokens for: {source_code}")
    tokens, errors = tokenize(source_code)

        print("Tokens:")
    #     for i, token in enumerate(tokens):
            print(f"  {i}: {token}")

        print(f"Errors: {errors}")
    #     return tokens, errors

function debug_assignment_parsing()
    #     """Debug assignment parsing"""
    source_code = "var x = 10"
        print(f"\nDebugging assignment parsing for: {source_code}")

    tokens, errors = tokenize(source_code)
    #     if errors:
            print(f"Lexer errors: {errors}")
    #         return

        print("Token stream:")
    #     for i, token in enumerate(tokens):
            print(f"  {i}: {token}")

    #     # Check if we have the expected tokens
    expected_types = [TokenType.VAR, TokenType.IDENTIFIER, TokenType.ASSIGN, TokenType.NUMBER]
        print(f"\nExpected token types:")
    #     for i, expected_type in enumerate(expected_types):
    #         if i < len(tokens):
    actual_type = tokens[i].type
                print(f"  {i}: Expected {expected_type}, Got {actual_type}")
    #             if actual_type != expected_type:
                    print(f"    MISMATCH!")
    #         else:
                print(f"  {i}: Expected {expected_type}, Got EOF")

if __name__ == "__main__"
    debug_tokens("var x = 10")
        debug_assignment_parsing()
