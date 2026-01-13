# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Debug script to understand parser step by step
# """

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser_statement_parsing.StatementParser
import noodlecore.compiler.parser_expression_parsing.ExpressionParser

# Test code that previously caused issues
test_code = 'var x = 10'
print f'Testing parser step by step with: "{test_code}"'

# Create lexer
lexer = Lexer(test_code)

# Create statement parser
statement_parser = StatementParser(lexer)

try
    #     # Try to parse the first statement
        print(f'\nAttempting to parse statement...')
        print(f'Current token: {statement_parser.current_token}')

    #     # Check what type of statement this is
    #     if statement_parser.current_token.type.value == 'VAR':
            print('Detected VAR token - parsing as variable declaration')
    var_decl = statement_parser.parse_var_decl()
            print(f'Variable declaration parsed successfully: {var_decl}')
    #     else:
            print(f'Unexpected token type: {statement_parser.current_token.type}')

except Exception as e
        print(f'Error parsing: {str(e)}')
    #     import traceback
        traceback.print_exc()
