# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Comprehensive debug script to understand token consumption and parsing
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser_statement_parsing.StatementParser

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing comprehensive parsing with: "{test_code}"'

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

try
    #     # Try to parse the first statement
    #     if statement_parser.current_token.type.value == 'VAR':
            print('Detected VAR token - parsing as variable declaration')

    #         # Step through the parsing manually
    #         from noodlecore.compiler.lexer_tokens import TokenType
            print(f'Before eat(TokenType.VAR): {statement_parser.current_token}')
            statement_parser.eat(TokenType.VAR)
            print(f'After eat(TokenType.VAR): {statement_parser.current_token}')

            print(f'Before eat(TokenType.IDENTIFIER): {statement_parser.current_token}')
            statement_parser.eat(TokenType.IDENTIFIER)
            print(f'After eat(TokenType.IDENTIFIER): {statement_parser.current_token}')

            print(f'Before check ASSIGN: {statement_parser.current_token}')
    #         if statement_parser.current_token.type == TokenType.ASSIGN:
                print('Found ASSIGN token')
                statement_parser.eat(TokenType.ASSIGN)
                print(f'After eat(TokenType.ASSIGN): {statement_parser.current_token}')
    #         else:
                print(f'No ASSIGN token found, got: {statement_parser.current_token}')

    #     else:
            print(f'Unexpected token type: {statement_parser.current_token.type}')

except Exception as e
        print(f'Error during parsing: {str(e)}')
    #     import traceback
        traceback.print_exc()
