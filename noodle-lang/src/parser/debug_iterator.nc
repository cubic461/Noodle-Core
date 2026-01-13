# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Debug script to understand token iterator issue
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser_statement_parsing.StatementParser
import noodlecore.compiler.lexer_tokens.TokenType

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing iterator with: "{test_code}"'

# Create lexer
lexer = Lexer(test_code)

# Manually tokenize first to see what tokens we get
print f'\nManually tokenizing source code...'
tokens, errors = lexer.tokenize()
print f'Tokens found:'
for i, token in enumerate(tokens)
        print(f'{i}: {token}')

# Now test the statement parser
print f'\nTesting statement parser...'
statement_parser = StatementParser(lexer)

print f'Initial token: {statement_parser.current_token}'

# Let's check what's in the token iterator
print f'\nToken iterator state:'
try
    #     # Create a new iterator to see what it returns
    new_iterator = iter(statement_parser.tokens)
    first_token = next(new_iterator)
        print(f'First token from new iterator: {first_token}')

    #     # Get the next token from the current iterator
    next_token = next(statement_parser.token_iterator, None)
        print(f'Next token from current iterator: {next_token}')

except StopIteration
        print('No more tokens in iterator')

# Let's check the current token index
print f'\nCurrent token: {statement_parser.current_token}'
print f'Token at index 0: {statement_parser.tokens[0]}'
print f'Token at index 1: {statement_parser.tokens[1]}'
