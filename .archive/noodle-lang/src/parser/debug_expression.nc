# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Debug script to understand expression parsing issue
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser_statement_parsing.StatementParser
import noodlecore.compiler.lexer_tokens.TokenType

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing expression parsing with: "{test_code}"'

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

# Step through the parsing manually
print f'\nStep-by-step token consumption:'
print f'1. Current token (VAR): {statement_parser.current_token}'

# Consume VAR token
print f'2. Calling eat(TokenType.VAR)...'
statement_parser.eat(TokenType.VAR)
print f'   After eat(TokenType.VAR): {statement_parser.current_token}'

# Consume IDENTIFIER token
print f'3. Calling eat(TokenType.IDENTIFIER)...'
statement_parser.eat(TokenType.IDENTIFIER)
print f'   After eat(TokenType.IDENTIFIER): {statement_parser.current_token}'

# Consume ASSIGN token
print f'4. Calling eat(TokenType.ASSIGN)...'
statement_parser.eat(TokenType.ASSIGN)
print f'   After eat(TokenType.ASSIGN): {statement_parser.current_token}'

# Check what's in the expression parser
print f'\nExpression parser state:'
print f'   Current token: {statement_parser.expression_parser.current_token}'
print f'   Token index: {statement_parser.expression_parser.token_index}'

# Try to parse expression
print f'\n5. Calling expression_parser.parse_expression()...'
try
    expression = statement_parser.expression_parser.parse_expression()
        print(f'   Expression parsed successfully: {expression}')
except Exception as e
        print(f'   Error parsing expression: {e}')
