# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Focused debug script to understand token consumption issue
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser_statement_parsing.StatementParser

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing focused token consumption with: "{test_code}"'

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
print f'   Token index: {statement_parser.current_token_index}'

# Import TokenType enum
import noodlecore.compiler.lexer_tokens.TokenType

# Consume VAR token
print f'2. Calling eat(TokenType.VAR)...'
statement_parser.eat(TokenType.VAR)  # This is where the issue occurs
print f'   After eat(TokenType.VAR): {statement_parser.current_token}'
print f'   Token index: {statement_parser.current_token_index}'

# Try to consume IDENTIFIER token
print f'3. Current token (should be IDENTIFIER): {statement_parser.current_token}'
print f'   Token index: {statement_parser.current_token_index}'
