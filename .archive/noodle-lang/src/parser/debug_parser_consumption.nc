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
import noodlecore.compiler.parser_ast_nodes.*

class DebugLexer:
    #     """Debug lexer that shows token consumption"""

    #     def __init__(self, source: str, filename: str = "<string>"):
    self.source = source
    self.filename = filename
    self.tokens, self.errors = tokenize(source, filename)
    self.current_index = 0

    #     def get_next_token(self):
    #         """Get the next token and show consumption"""
    #         if self.current_index < len(self.tokens):
    token = self.tokens[self.current_index]
                print(f"    Consuming token: {token}")
    self.current_index + = 1
    #             return token
    #         else:
                print("    Consuming token: EOF")
                return Token(Token.EOF, "", None)

    #     def peek_token(self):
    #         """Peek at the next token without consuming it"""
    #         if self.current_index < len(self.tokens):
    #             return self.tokens[self.current_index]
    #         else:
                return Token(Token.EOF, "", None)

function debug_assignment_detection()
    #     """Debug assignment detection"""
    source_code = "var x = 10"
        print(f"\nDebugging assignment detection for: {source_code}")

    lexer = DebugLexer(source_code)

    #     # Simulate the parser logic
    current_token = lexer.get_next_token()  # Should consume VAR
        print(f"Current token after first consumption: {current_token}")

    #     if current_token.type.value == TokenType.VAR.value:
            print("Detected VAR token - this should be parsed as variable declaration")
    #         # This should call parse_var_decl, not parse_assignment_or_expr
    #     else:
    #         print("Not a VAR token - checking for assignment")

    #         # This is where the parser would go for assignment detection
    #         if current_token.type.value == TokenType.IDENTIFIER.value:
    #             print("Detected IDENTIFIER - checking for assignment")
    current_token = lexer.get_next_token()  # Should consume identifier
    next_token = lexer.get_next_token()  # Should consume ASSIGN or next token

    #             if next_token.type.value == TokenType.ASSIGN.value:
                    print("Detected ASSIGN - this is an assignment")
    #             else:
                    print("Not an assignment - this is an expression")
    #                 # Restore the token
    lexer.current_index - = 1
    #         else:
                print("Not an identifier - this is an expression")

if __name__ == "__main__"
        debug_assignment_detection()