# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Detailed debug script to understand token consumption
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser_statement_parsing.StatementParser
import noodlecore.compiler.lexer_tokens.TokenType

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing detailed token consumption with: "{test_code}"'

# Create lexer
lexer = Lexer(test_code)

# Manually tokenize first to see what tokens we get
print f'\nManually tokenizing source code...'
tokens, errors = lexer.tokenize()
print f'Tokens found:'
for i, token in enumerate(tokens)
        print(f'{i}: {token}')

print f'\nErrors found:'
for error in errors
        print(f'  {error}')

# Now test the statement parser
print f'\nTesting statement parser...'
statement_parser = StatementParser(lexer)

print f'Initial token: {statement_parser.current_token}'

# Step through the parsing manually
print f'\nStep-by-step token consumption:'
print f'1. Current token (VAR): {statement_parser.current_token}'

# Consume VAR token
print f'2. Calling eat(TokenType.VAR)...'
statement_parser.eat(TokenType.VAR)
print f'   After eat(TokenType.VAR): {statement_parser.current_token}'

# Try to consume IDENTIFIER token
print f'3. Current token (should be IDENTIFIER): {statement_parser.current_token}'

# Let's check what's in the tokens list at this point
print f'\nTokens list after consuming VAR:'
for i, token in enumerate(statement_parser.tokens)
        print(f'{i}: {token}')

# Let's check what's in the token iterator
print f'\nToken iterator state:'
try
    next_token = next(statement_parser.token_iterator)
        print(f'Next token: {next_token}')
except StopIteration
        print('No more tokens in iterator')

# Let's try to get the next token manually
print f'\nGetting next token manually:'
next_token = next(statement_parser.token_iterator, None)
print f'Next token: {next_token}'
