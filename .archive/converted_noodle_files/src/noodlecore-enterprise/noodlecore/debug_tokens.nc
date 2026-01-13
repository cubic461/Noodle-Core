# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Debug script to see what tokens are being generated
# """

import sys
sys.path.insert(0, 'src')

import noodlecore.compiler.lexer.Lexer

function debug_tokens(code)
        print(f"Debugging code: {repr(code)}")
    lexer = Lexer(code)
    tokens = list(lexer.tokenize())
        print(f"Tokens generated: {len(tokens)}")
    #     for i, token in enumerate(tokens):
    print(f"  {i}: {token.type.name} = {repr(token.value)}")
        print()

# Test with different inputs
debug_tokens("123")
debug_tokens("x")
debug_tokens("+")
debug_tokens("")