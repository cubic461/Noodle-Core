# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Debug script to see what's happening in the test
# """

import sys
sys.path.insert(0, 'src')

import noodlecore.compiler.lexer.Lexer

function debug_specific_test()
    #     """Debug the specific test case that's failing"""
    numbers = [
    #         "0",
    #         "1",
    #         "123",
    #         "3.14",
    #         "0.5",
    #         ".5",
    #         "1.0",
    #         "1e10",
    #         "1.5e-3",
    #         "0x10",
    #         "0XFF",
    #         "0b1010",
    #         "0B1101",
    #         "0o755",
    #         "0O644",
    #     ]

        print("Testing numbers...")
    #     for i, number in enumerate(numbers):
            print(f"\n{i+1}. Testing: {repr(number)}")
    lexer = Lexer(number)
    tokens = list(lexer.tokenize())
            print(f"   Tokens generated: {len(tokens)}")
    #         for j, token in enumerate(tokens):
    print(f"   {j}: {token.type.name} = {repr(token.value)}")

    #         if len(tokens) != 3:
                print(f"   FAILED: Expected 3 tokens, got {len(tokens)}")
    #         else:
                print(f"   PASSED")

if __name__ == "__main__"
        debug_specific_test()