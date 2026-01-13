# Converted from Python to NoodleCore
# Original file: src

# """
# Statement Parsing for Noodle Programming Language
# -------------------------------------------------
# This module implements statement parsing for the Noodle parser.
# It handles the parsing of statements like variable declarations, assignments, etc.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import typing.List
import .lexer_tokens.Token
import .parser_ast_nodes.(
#     ProgramNode,
#     StatementNode,
#     VarDeclNode,
#     AssignStmtNode,
#     ExprStmtNode,
#     IfStmtNode,
#     WhileStmtNode,
#     ForStmtNode,
#     FuncDefNode,
#     ReturnStmtNode,
#     PrintStmtNode,
#     ImportStmtNode,
#     CompoundStmtNode,
#     IdentifierExprNode,
#     TryStmtNode,
# )
import .parser_expression_parsing.ExpressionParser
import .lexer_main.tokenize


class StatementParser
    #     """Handles statement parsing"""

    #     def __init__(self, lexer):
    self.lexer = lexer
    #         # Ensure the lexer tokenizes the source first
            self.lexer.tokenize()
    #         # Create our own iterator for the tokens
    self.tokens = self.lexer.tokens
    self.token_index = 0
    #         self.current_token = self.tokens[0] if self.tokens else None
    #         # Create expression parser with the same token stream
    self.expression_parser = ExpressionParser(lexer, self.tokens, self.token_index)
    #         # Sync the expression parser's current token
    self.expression_parser.current_token = self.current_token

    #     def eat(self, token_type):
    #         """Consume the current token if it matches the expected type"""
            print(f"DEBUG: eat() called - current_token: {self.current_token}, expected: {token_type}")
    #         if self.current_token and self.current_token.type.value == token_type.value:
    #             # Move to the next token using our index
    self.token_index + = 1
                print(f"DEBUG: Advanced to token index {self.token_index}")
    #             if self.token_index < len(self.tokens):
    self.current_token = self.tokens[self.token_index]
                    print(f"DEBUG: New current_token: {self.current_token}")
    #             else:
    self.current_token = Token(Token.EOF, "", None)
                    print(f"DEBUG: Reached EOF")
    #             # Update the expression parser's current token
    self.expression_parser.current_token = self.current_token
    self.expression_parser.token_index = self.token_index
    #         else:
                print(f"DEBUG: eat() failed - current_token: {self.current_token}, expected: {token_type}")
    #             self.error(f"Expected {token_type}, got {self.current_token.type if self.current_token else 'None'}")

    #     def error(self, message):
    #         """Raise a parsing error"""
            raise Exception(f"Parser error: {message}")

    #     def parse_program(self) -ProgramNode):
            """Parse a program (list of statements)"""
    statements = []

    #         while self.current_token.type.value != Token.EOF.value:
    stmt = self.parse_statement()
    #             if stmt:
                    statements.append(stmt)

            return ProgramNode(statements)

    #     def parse_statement(self) -Optional[StatementNode]):
    #         """Parse a statement"""
    token = self.current_token

    #         if token.type.value == TokenType.VAR.value:
                return self.parse_var_decl()
    #         elif token.type.value == TokenType.IDENTIFIER.value:
                return self.parse_assignment_or_expr()
    #         elif token.type.value == TokenType.IF.value:
                return self.parse_if_stmt()
    #         elif token.type.value == TokenType.WHILE.value:
                return self.parse_while_stmt()
    #         elif token.type.value == TokenType.FOR.value:
                return self.parse_for_stmt()
    #         elif token.type.value == TokenType.FUNC.value:
                return self.parse_func_def()
    #         elif token.type.value == TokenType.RETURN.value:
                return self.parse_return_stmt()
    #         elif token.type.value == TokenType.PRINT.value:
                return self.parse_print_stmt()
    #         elif token.type.value == TokenType.IMPORT.value:
                return self.parse_import_stmt()
    #         elif token.type.value == TokenType.TRY.value:
                return self.parse_try_stmt()
    #         elif token.type.value == TokenType.LEFT_BRACE.value:
                return self.parse_compound_stmt()
    #         else:
    #             # Try to parse as expression statement
                return self.parse_expression_stmt()

    #     def parse_var_decl(self) -VarDeclNode):
    #         """Parse variable declaration with type annotation support"""
            self.eat(TokenType.VAR)
    name = self.current_token.value
            self.eat(TokenType.IDENTIFIER)

    type_hint = None
    initializer = None

    #         # Check for type annotation: name: type = value
    #         if self.current_token.type.value == TokenType.COLON.value:
                self.eat(TokenType.COLON)
    type_hint = self.current_token.value
                self.eat(TokenType.IDENTIFIER)

    #         # Check for initializer
    #         if self.current_token.type.value == TokenType.ASSIGN.value:
                self.eat(TokenType.ASSIGN)
    #             # Update the expression parser's token index before parsing
    self.expression_parser.token_index = self.token_index
    initializer = self.expression_parser.parse_expression()

            return VarDeclNode(name, type_hint, initializer)

    #     def parse_assignment_or_expr(self) -StatementNode):
    #         """Parse assignment or expression statement"""
    #         # Look ahead to see if this is an assignment
    #         if self.current_token.type.value == TokenType.IDENTIFIER.value:
    #             # Save current position and token
    current_token = self.current_token

    #             # Get next token to check if it's ASSIGN
    #             # Save current index and get token manually to avoid side effects
    current_index = self.token_index
    #             if current_index + 1 < len(self.tokens):
    next_token = self.tokens[current_index + 1]
    #             else:
    next_token = Token(Token.EOF, "", None)

    #             # Restore current token
    self.current_token = current_token

    #             if next_token.type.value == TokenType.ASSIGN.value:
    #                 # This is an assignment, pass the identifier to parse_assignment
    target = IdentifierExprNode(current_token.value)
    #                 # Advance to the assignment token
    self.current_token = next_token
    self.token_index = current_index + 1
    #                 # Update the expression parser's current token
    self.expression_parser.current_token = self.current_token
    self.expression_parser.token_index = self.token_index
                    return self.parse_assignment(target)
    #             else:
    #                 # This is an expression, restore both tokens and parse expression
    self.current_token = next_token
                    return self.parse_expression_stmt()
    #         else:
                return self.parse_expression_stmt()

    #     def parse_assignment(self, target: IdentifierExprNode) -AssignStmtNode):
    #         """Parse assignment statement with pre-parsed target"""
    #         # Consume the ASSIGN token
            self.eat(TokenType.ASSIGN)
    value = self.expression_parser.parse_expression()
            return AssignStmtNode(target, value)

    #     def parse_expression_stmt(self) -ExprStmtNode):
    #         """Parse expression statement"""
    expression = self.expression_parser.parse_expression()
            return ExprStmtNode(expression)

    #     def parse_if_stmt(self) -IfStmtNode):
    #         """Parse if statement with C-like syntax and elif/else support"""
    #         start_position = self.current_token.position if self.current_token else None

            self.eat(TokenType.IF)
    condition = self.expression_parser.parse_expression()

    #         # Sync the token_index and current_token from expression parser
    self.token_index = self.expression_parser.token_index
    self.current_token = self.expression_parser.current_token

    #         # Expect opening brace for then block
            self.eat(TokenType.LEFT_BRACE)
    then_branch = self.parse_compound_stmt()

    #         # Handle elif chains
    elif_branches = []
    else_branch = None

    #         while self.current_token.type.value == TokenType.ELIF.value:
                self.eat(TokenType.ELIF)
    elif_condition = self.expression_parser.parse_expression()

    #             # Sync the token_index and current_token from expression parser
    self.token_index = self.expression_parser.token_index
    self.current_token = self.expression_parser.current_token

    #             # Expect opening brace for elif block
                self.eat(TokenType.LEFT_BRACE)
    elif_branch = self.parse_compound_stmt()
                elif_branches.append((elif_condition, elif_branch))

    #         # Handle else block
    #         if self.current_token.type.value == TokenType.ELSE.value:
                self.eat(TokenType.ELSE)

    #             # Expect opening brace for else block
                self.eat(TokenType.LEFT_BRACE)
    else_branch = self.parse_compound_stmt()

    #         # Create the if statement with all branches
    if_stmt = IfStmtNode(condition, then_branch, else_branch)
    if_stmt.position = start_position

    #         # Add elif branches metadata
    #         if elif_branches:
    if_stmt.elif_branches = elif_branches

    #         return if_stmt

    #     def parse_while_stmt(self) -WhileStmtNode):
    #         """Parse while statement with C-like syntax"""
    #         start_position = self.current_token.position if self.current_token else None

            self.eat(TokenType.WHILE)
    condition = self.expression_parser.parse_expression()

    #         # Sync the token_index and current_token from expression parser
    self.token_index = self.expression_parser.token_index
    self.current_token = self.expression_parser.current_token

    #         # Expect opening brace for while block
            self.eat(TokenType.LEFT_BRACE)
    body = self.parse_compound_stmt()

    #         # Create while statement with position
    while_stmt = WhileStmtNode(condition, body)
    while_stmt.position = start_position

    #         return while_stmt

    #     def parse_for_stmt(self) -ForStmtNode):
    #         """Parse for statement with C-like syntax and range support"""
    #         start_position = self.current_token.position if self.current_token else None

            self.eat(TokenType.FOR)
    variable = self.current_token.value
            self.eat(TokenType.IDENTIFIER)

            self.eat(TokenType.IN)
    iterable = self.expression_parser.parse_expression()

    #         # Sync the token_index and current_token from expression parser
    self.token_index = self.expression_parser.token_index
    self.current_token = self.expression_parser.current_token

    #         # Expect opening brace for for block
            self.eat(TokenType.LEFT_BRACE)
    body = self.parse_compound_stmt()

    #         # Create for statement with position and enhanced metadata
    for_stmt = ForStmtNode(variable, iterable, body)
    for_stmt.position = start_position

    #         # Add metadata for loop optimization
    for_stmt.metadata = {
    #             'loop_type': 'for_in',
    #             'variable_type': 'iterator',
    #             'has_body': body is not None,
    #         }

    #         return for_stmt

    #     def parse_func_def(self) -FuncDefNode):
    #         """Parse function definition with C-like syntax and type annotations"""
    #         start_position = self.current_token.position if self.current_token else None

            self.eat(TokenType.FUNC)
    name = self.current_token.value
            self.eat(TokenType.IDENTIFIER)

            self.eat(TokenType.LPAREN)
    params = []

    #         while self.current_token.type.value != TokenType.RPAREN.value:
    param_name = self.current_token.value
                self.eat(TokenType.IDENTIFIER)

    #             # Check for type annotation
    param_type = None
    #             if self.current_token.type.value == TokenType.COLON.value:
                    self.eat(TokenType.COLON)
    param_type = self.current_token.value
                    self.eat(TokenType.IDENTIFIER)

                params.append({"name": param_name, "type": param_type or "auto", "default": None})

    #             if self.current_token.type.value == TokenType.COMMA.value:
                    self.eat(TokenType.COMMA)

            self.eat(TokenType.RPAREN)

    #         # Check for return type annotation
    return_type = None
    #         if self.current_token.type.value == TokenType.ARROW.value:
                self.eat(TokenType.ARROW)
    return_type = self.current_token.value
                self.eat(TokenType.IDENTIFIER)

    #         # Expect opening brace for function body
            self.eat(TokenType.LEFT_BRACE)
    body = self.parse_compound_stmt()

    #         # Create function definition with enhanced metadata
    #         func_def = FuncDefNode(name, params, return_type, body)
    func_def.position = start_position

    #         # Add function metadata
    func_def.metadata = {
    #             'func_name': name,
                'param_count': len(params),
    #             'has_body': body is not None,
    #             'return_type': return_type or 'auto',
    #             'visibility': 'public',
    #             'is_async': False,
    #         }

    #         # Validate function definition
    #         if not name.isidentifier():
                self.error(f"Invalid function name: {name}")

    #         return func_def

    #     def parse_return_stmt(self) -ReturnStmtNode):
    #         """Parse return statement"""
            self.eat(TokenType.RETURN)

    #         if self.current_token.type.value != TokenType.NEWLINE.value and \
    self.current_token.type.value != Token.EOF.value:
    value = self.expression_parser.parse_expression()
    #         else:
    value = None

            return ReturnStmtNode(value)

    #     def parse_print_stmt(self) -PrintStmtNode):
    #         """Parse print statement"""
            self.eat(TokenType.PRINT)
    arguments = [self.expression_parser.parse_expression()]

            return PrintStmtNode(arguments)

    #     def parse_import_stmt(self) -ImportStmtNode):
    #         """Parse import statement"""
            self.eat(TokenType.IMPORT)
    module = self.current_token.value
            self.eat(TokenType.IDENTIFIER)

    #         if self.current_token.type.value == TokenType.AS.value:
                self.eat(TokenType.AS)
    alias = self.current_token.value
                self.eat(TokenType.IDENTIFIER)
    #         else:
    alias = None

            return ImportStmtNode(module, alias)

    #     def parse_compound_stmt(self) -CompoundStmtNode):
    #         """Parse compound statement with C-like syntax (curly braces)"""
    statements = []

    #         # We're already at the opening brace or inside it
    #         if self.current_token.type.value == TokenType.LEFT_BRACE.value:
                self.eat(TokenType.LEFT_BRACE)

    #         # Parse statements until we reach the closing brace
    #         while (self.current_token and
    self.current_token.type.value != TokenType.RIGHT_BRACE.value and
    self.current_token.type.value != Token.EOF.value):
    stmt = self.parse_statement()
    #             if stmt:
                    statements.append(stmt)

    #         # Expect closing brace
    #         if self.current_token and self.current_token.type.value == TokenType.RIGHT_BRACE.value:
                self.eat(TokenType.RIGHT_BRACE)

            return CompoundStmtNode(statements)

    #     def parse_try_stmt(self) -TryStmtNode):
    #         """Parse try-catch statement with C-like syntax"""
    #         start_position = self.current_token.position if self.current_token else None

            self.eat(TokenType.TRY)

    #         # Expect opening brace for try block
            self.eat(TokenType.LEFT_BRACE)
    try_body = self.parse_compound_stmt()

    catch_var = None
    catch_body = None

    #         if self.current_token and self.current_token.type.value == TokenType.CATCH.value:
                self.eat(TokenType.CATCH)

    #             # Check for catch variable
    #             if self.current_token.type.value == TokenType.LEFT_PAREN.value:
                    self.eat(TokenType.LEFT_PAREN)
    catch_var = self.current_token.value
                    self.eat(TokenType.IDENTIFIER)
                    self.eat(TokenType.RIGHT_PAREN)

    #             # Expect opening brace for catch block
                self.eat(TokenType.LEFT_BRACE)
    catch_body = self.parse_compound_stmt()

    #         # Create try statement
    try_stmt = TryStmtNode(try_body, catch_var, catch_body)
    try_stmt.position = start_position

    #         return try_stmt

    #     def error(self, message: str):
    #         """Raise an error with the given message"""
            raise Exception(f"Parser error: {message}")
