# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Debug script to understand token consumption
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing lexer with: "{test_code}"'

# Create lexer
lexer = Lexer(test_code)

# Get all tokens and print them
tokens, errors = lexer.tokenize()
print f'\nTokens found:'
for i, token in enumerate(tokens)
        print(f'{i}: {token}')

print f'\nErrors found:'
for error in errors
        print(f'  {error}')

# Test token consumption
print f'\nTesting token consumption:'
lexer2 = Lexer(test_code)
print f'Initial token: {lexer2.get_next_token()}'
print f'Next token: {lexer2.get_next_token()}'
print f'Next token: {lexer2.get_next_token()}'
print f'Next token: {lexer2.get_next_token()}'
print f'Next token: {lexer2.get_next_token()}'
