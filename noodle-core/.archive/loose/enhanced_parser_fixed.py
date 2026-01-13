#!/usr/bin/env python3
"""
Noodle Core::Enhanced Parser Fixed - enhanced_parser_fixed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Enhanced Noodle Language Parser

This module implements an enhanced parser for Noodle programming language,
properly integrating with enhanced AST node system.

Features:
- Support for all language features (pattern matching, generics, async/await)
- Enhanced error handling and recovery
- Integration with enhanced AST node system
- Source location tracking
- Type-safe parsing with proper node validation
"""

import logging
from typing import Dict, List, Optional, Tuple, Any, Union
from dataclasses import dataclass

# Import enhanced AST nodes
from .ast_nodes import (
    # Base classes
    ASTNode, NodeType, SourceLocation, CompilationError,
    
    # Enhanced AST nodes
    EnhancedProgramNode, EnhancedLetStatementNode, EnhancedFunctionDefinitionNode,
    EnhancedBinaryExpressionNode, EnhancedFunctionCallNode, EnhancedIdentifierNode,
    EnhancedLiteralNode, EnhancedNumberLiteralNode, EnhancedStringLiteralNode,
    EnhancedBooleanLiteralNode, EnhancedNoneLiteralNode, EnhancedReturnStatementNode,
    EnhancedIfStatementNode, EnhancedForStatementNode, EnhancedWhileStatementNode,
    EnhancedImportStatementNode, EnhancedClassDefinitionNode, EnhancedExpressionStatementNode,
    EnhancedUnaryExpressionNode, EnhancedArrayLiteralNode, EnhancedObjectLiteralNode,
    EnhancedObjectPropertyNode,
    
    # Pattern matching nodes
    MatchExpressionNode, MatchCaseNode, Pattern, WildcardPatternNode, LiteralPatternNode,
    IdentifierPatternNode, TuplePatternNode, ArrayPatternNode, ObjectPatternNode,
    OrPatternNode, AndPatternNode, GuardPatternNode, TypePatternNode, RangePatternNode,
    
    # Generics nodes
    GenericParameterNode, GenericType, GenericFunction, GenericClass,
    GenericFunctionDefinitionNode, GenericClassDefinitionNode, TypeConstraintNode,
    GenericTypeAnnotationNode, TypeAliasNode, UnionTypeNode, IntersectionTypeNode,
    ComputedTypeNode, TypeParameterNode, FunctionTypeNode, TupleTypeNode,
    ArrayTypeNode,
    
    # Async/await nodes
    AsyncFunctionDefinitionNode, AwaitExpressionNode, AsyncForStatementNode,
    AsyncWithStatementNode, YieldExpressionNode,
    
    # Factory
    ASTNodeFactory
)

# Import lexer
try:
    from noodle_lang.lexer import NoodleLexer, TokenType, Token, CompilationError as LexerCompilationError
except ImportError:
    # Try to import our simple lexer
    try:
        import sys
        import os
        # Add the noodle-core directory to the path
        sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))
        from simple_lexer import SimpleLexer, TokenType, Token, SourceLocation
        
        # Create an alias for compatibility
        NoodleLexer = SimpleLexer
        
        class LexerCompilationError:
            def __init__(self, message, location):
                self.message = message
                self.location = location
    except ImportError:
        # Fallback for development
        # Define fallback Token class
        from dataclasses import dataclass
        from enum import Enum
        
        class TokenType(Enum):
            EOF = "EOF"
            IDENTIFIER = "IDENTIFIER"
            NUMBER = "NUMBER"
            STRING = "STRING"
            TRUE = "TRUE"
            FALSE = "FALSE"
            NONE = "NONE"
            PLUS = "PLUS"
            MINUS = "MINUS"
            MULTIPLY = "MULTIPLY"
            DIVIDE = "DIVIDE"
            MODULO = "MODULO"
            ASSIGN = "ASSIGN"
            EQ = "EQ"
            NE = "NE"
            LESS_THAN = "LESS_THAN"
            GREATER_THAN = "GREATER_THAN"
            LESS_EQUAL = "LESS_EQUAL"
            GREATER_EQUAL = "GREATER_EQUAL"
            AND = "AND"
            OR = "OR"
            NOT = "NOT"
            LPAREN = "LPAREN"
            RPAREN = "RPAREN"
            LBRACE = "LBRACE"
            RBRACE = "RBRACE"
            LBRACKET = "LBRACKET"
            RBRACKET = "RBRACKET"
            COMMA = "COMMA"
            DOT = "DOT"
            COLON = "COLON"
            SEMICOLON = "SEMICOLON"
            ARROW = "ARROW"
            LET = "LET"
            DEF = "DEF"
            RETURN = "RETURN"
            IF = "IF"
            ELSE = "ELSE"
            FOR = "FOR"
            IN = "IN"
            WHILE = "WHILE"
            BREAK = "BREAK"
            CONTINUE = "CONTINUE"
            IMPORT = "IMPORT"
            FROM = "FROM"
            AS = "AS"
            CLASS = "CLASS"
            STRUCT = "STRUCT"
            INTERFACE = "INTERFACE"
            IMPLEMENTS = "IMPLEMENTS"
            EXTENDS = "EXTENDS"
            TYPE = "TYPE"
            ENUM = "ENUM"
            MATCH = "MATCH"
            CASE = "CASE"
            DEFAULT = "DEFAULT"
            ASYNC = "ASYNC"
            AWAIT = "AWAIT"
            YIELD = "YIELD"
            UNDERSCORE = "UNDERSCORE"
            LT = "LT"
            GT = "GT"
            LE = "LE"
            GE = "GE"
            PIPE = "PIPE"  # Added for OR pattern
            AMPERSAND = "AMPERSAND"  # Added for AND pattern
            RANGE = "RANGE"  # Added for range pattern
        
        @dataclass
        class Token:
            type: TokenType
            value: str
            location: 'SourceLocation'
        
        @dataclass
        class NoodleLexer:
            source: str
            filename: str
            
            def tokenize(self):
                return []
            
            @property
            def errors(self):
                return []
        
        class LexerCompilationError:
            def __init__(self, message, location):
                self.message = message
                self.location = location

logger = logging.getLogger(__name__)


class ParserConfig:
    """Configuration for enhanced parser"""
    def __init__(self,
                 enable_error_recovery: bool = True,
                 max_errors: int = 100,
                 strict_mode: bool = False,
                 enable_warnings: bool = True):
        self.enable_error_recovery = enable_error_recovery
        self.max_errors = max_errors
        self.strict_mode = strict_mode
        self.enable_warnings = enable_warnings


class ParseError(CompilationError):
    """Parse-specific error"""
    def __init__(self, message: str, location: SourceLocation):
        super().__init__(message, location, "parser_error")


class EnhancedParser:
    """Enhanced parser for Noodle language with full feature support"""
    
    def __init__(self, source: str, filename: str = "<input>"):
        self.lexer = NoodleLexer(source, filename)
        self.tokens = []
        self.position = 0
        self.errors = []
        self.warnings = []
        self.factory = ASTNodeFactory()
        
        # Tokenize first
        self.tokens = self.lexer.tokenize()
        self.errors.extend(self.lexer.errors)
        
        # Convert lexer errors to parser errors
        for error in self.lexer.errors:
            self.errors.append(ParseError(error.message, error.location))
    
    def error(self, message: str, location: SourceLocation = None):
        """Record a parsing error"""
        if location is None:
            token = self._current_token()
            location = token.location
        
        self.errors.append(ParseError(message, location))
        logger.error(f"Parse error at {location}: {message}")
    
    def warning(self, message: str, location: SourceLocation = None):
        """Record a parsing warning"""
        if location is None:
            token = self._current_token()
            location = token.location
        
        self.warnings.append(ParseError(message, location))
        logger.warning(f"Parse warning at {location}: {message}")
    
    def _current_token(self) -> Token:
        """Get current token"""
        if self.position >= len(self.tokens):
            return Token(TokenType.EOF, '', SourceLocation("", 0, 0, 0))
        return self.tokens[self.position]
    
    def _peek_token(self, offset: int = 1) -> Token:
        """Peek at token at offset"""
        pos = self.position + offset
        if pos >= len(self.tokens):
            return Token(TokenType.EOF, '', SourceLocation("", 0, 0, 0))
        return self.tokens[pos]
    
    def _advance(self) -> Token:
        """Advance to next token"""
        token = self._current_token()
        self.position += 1
        return token
    
    def _expect(self, expected_type: TokenType, error_message: str = None) -> Token:
        """Expect a specific token type"""
        token = self._current_token()
        if token.type == expected_type:
            return self._advance()
        
        if error_message is None:
            error_message = f"Expected {expected_type.value}, got {token.type.value}"
        self.error(error_message, token.location)
        return token
    
    def _match(self, *token_types: TokenType) -> bool:
        """Check if current token matches any of the given types"""
        return self._current_token().type in token_types
    
    def _synchronize(self):
        """Attempt to recover from error by synchronizing to next statement"""
        self._advance()  # Skip current token
        
        while not self._match(TokenType.EOF):
            if self._match(TokenType.SEMICOLON, TokenType.RBRACE):
                # Found potential synchronization point
                if self._match(TokenType.SEMICOLON):
                    self._advance()  # Consume semicolon
                break
            
            self._advance()  # Keep looking for synchronization point
    
    def parse(self) -> EnhancedProgramNode:
        """Parse token stream into an enhanced AST"""
        self.errors = []
        self.warnings = []
        
        statements = []
        
        while not self._match(TokenType.EOF):
            try:
                stmt = self._parse_statement()
                if stmt:
                    statements.append(stmt)
            except ParseError as e:
                self.errors.append(e)
                self._synchronize()
        
        location = SourceLocation("", 0, 0, 0) if not statements else statements[0].location
        return self.factory.create_program(statements, location)
    
    def _parse_statement(self) -> Optional[ASTNode]:
        """Parse a statement"""
        if self._match(TokenType.LET):
            return self._parse_let_statement()
        elif self._match(TokenType.DEF):
            return self._parse_function_definition()
        elif self._match(TokenType.ASYNC):
            # Check if this is an async function
            if self._peek_token().type == TokenType.DEF:
                return self._parse_async_function_definition()
            else:
                # Might be async with or other async construct
                return self._parse_async_statement()
        elif self._match(TokenType.IF):
            return self._parse_if_statement()
        elif self._match(TokenType.FOR):
            # Check if this is an async for
            if self._peek_token().type == TokenType.ASYNC:
                return self._parse_async_for_statement()
            else:
                return self._parse_for_statement()
        elif self._match(TokenType.WHILE):
            return self._parse_while_statement()
        elif self._match(TokenType.RETURN):
            return self._parse_return_statement()
        elif self._match(TokenType.IMPORT):
            return self._parse_import_statement()
        elif self._match(TokenType.CLASS):
            return self._parse_class_definition()
        elif self._match(TokenType.MATCH):
            match_expr = self._parse_match_expression()
            if match_expr:
                return self.factory.create_expression_statement(match_expr, match_expr.location)
            return None
        elif self._match(TokenType.YIELD):
            return self._parse_yield_expression()
        else:
            # Try to parse as expression statement
            expr = self._parse_expression()
            if expr:
                if not self._match(TokenType.SEMICOLON):
                    self.error("Expected ';' after expression")
                else:
                    self._advance()  # Consume semicolon
                return self.factory.create_expression_statement(expr, expr.location)
            return None
    
    def _parse_let_statement(self) -> Optional[EnhancedLetStatementNode]:
        """Parse a let statement (variable declaration)"""
        let_token = self._advance()  # 'let'
        
        name_token = self._expect(TokenType.IDENTIFIER, "Expected variable name after 'let'")
        name = name_token.value
        
        # Optional type annotation
        type_annotation = None
        if self._match(TokenType.COLON):
            self._advance()  # ':'
            type_annotation = self._parse_type_annotation()
        
        # Optional initialization
        initializer = None
        if self._match(TokenType.ASSIGN):
            self._advance()  # '='
            initializer = self._parse_expression()
        
        if not self._match(TokenType.SEMICOLON):
            self.error("Expected ';' after let statement")
        else:
            self._advance()  # Consume semicolon
        
        return self.factory.create_let_statement(name, type_annotation, initializer, let_token.location)
    
    def _parse_function_definition(self, is_async: bool = False) -> Optional[EnhancedFunctionDefinitionNode]:
        """Parse a function definition"""
        def_token = self._advance()  # 'def'
        
        name_token = self._expect(TokenType.IDENTIFIER, "Expected function name after 'def'")
        name = name_token.value
        
        # Optional generic parameters
        generic_parameters = []
        if self._match(TokenType.LT):
            generic_parameters = self._parse_generic_parameters()
        
        self._expect(TokenType.LPAREN, "Expected '(' after function name")
        
        parameters = []
        if not self._match(TokenType.RPAREN):
            while True:
                param_name_token = self._expect(TokenType.IDENTIFIER, "Expected parameter name")
                param_name = param_name_token.value
                
                # Optional type annotation
                param_type = None
                if self._match(TokenType.COLON):
                    self._advance()  # ':'
                    param_type = self._parse_type_annotation()
                
                parameters.append({
                    'name': param_name,
                    'type': param_type
                })
                
                if self._match(TokenType.COMMA):
                    self._advance()  # ','
                else:
                    break
        
        self._expect(TokenType.RPAREN, "Expected ')' after parameters")
        
        # Optional return type
        return_type = None
        if self._match(TokenType.ARROW):
            self._advance()  # '->'
            return_type = self._parse_type_annotation()
        
        # Function body
        self._expect(TokenType.LBRACE, "Expected '{' to start function body")
        
        body = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end function body")
        
        if is_async:
            return self.factory.create_async_function_definition(name, parameters, return_type, body, False, def_token.location)
        else:
            return self.factory.create_function_definition(name, parameters, return_type, body, def_token.location)
    
    def _parse_async_function_definition(self) -> Optional[AsyncFunctionDefinitionNode]:
        """Parse an async function definition"""
        async_token = self._advance()  # 'async'
        return self._parse_function_definition(is_async=True)
    
    def _parse_generic_parameters(self) -> List[GenericParameterNode]:
        """Parse generic parameters"""
        self._advance()  # '<'
        
        parameters = []
        while not self._match(TokenType.GT) and not self._match(TokenType.EOF):
            name_token = self._expect(TokenType.IDENTIFIER, "Expected generic parameter name")
            name = name_token.value
            
            # Optional constraint
            constraint = None
            if self._match(TokenType.COLON):
                self._advance()  # ':'
                constraint_token = self._expect(TokenType.IDENTIFIER, "Expected constraint type")
                constraint = constraint_token.value
            
            parameters.append(self.factory.create_generic_parameter(name, constraint, name_token.location))
            
            if self._match(TokenType.COMMA):
                self._advance()  # ','
            else:
                break
        
        self._expect(TokenType.GT, "Expected '>' after generic parameters")
        return parameters
    
    def _parse_type_annotation(self) -> str:
        """Parse a type annotation"""
        type_token = self._expect(TokenType.IDENTIFIER, "Expected type name")
        type_name = type_token.value
        
        # Check for generic type arguments
        if self._match(TokenType.LT):
            self._advance()  # '<'
            type_args = []
            
            while not self._match(TokenType.GT) and not self._match(TokenType.EOF):
                arg_token = self._expect(TokenType.IDENTIFIER, "Expected type argument")
                type_args.append(arg_token.value)
                
                if self._match(TokenType.COMMA):
                    self._advance()  # ','
                else:
                    break
            
            self._expect(TokenType.GT, "Expected '>' after type arguments")
            type_name += f"<{', '.join(type_args)}>"
        
        return type_name
    
    def _parse_if_statement(self) -> Optional[EnhancedIfStatementNode]:
        """Parse an if statement"""
        if_token = self._advance()  # 'if'
        
        condition = self._parse_expression()
        if not condition:
            self.error("Expected condition after 'if'")
        
        self._expect(TokenType.LBRACE, "Expected '{' after if condition")
        
        then_branch = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                then_branch.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end if body")
        
        # Optional else branch
        else_branch = None
        if self._match(TokenType.ELSE):
            self._advance()  # 'else'
            
            if self._match(TokenType.IF):
                # else if
                else_branch = self._parse_if_statement()
            else:
                self._expect(TokenType.LBRACE, "Expected '{' after else")
                
                else_branch = []
                while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
                    stmt = self._parse_statement()
                    if stmt:
                        else_branch.append(stmt)
                
                self._expect(TokenType.RBRACE, "Expected '}' to end else body")
        
        return self.factory.create_if_statement(condition, then_branch, else_branch, if_token.location)
    
    def _parse_for_statement(self) -> Optional[EnhancedForStatementNode]:
        """Parse a for statement"""
        for_token = self._advance()  # 'for'
        
        variable_token = self._expect(TokenType.IDENTIFIER, "Expected variable name after 'for'")
        variable = variable_token.value
        
        self._expect(TokenType.IN, "Expected 'in' after for variable")
        
        iterable = self._parse_expression()
        if not iterable:
            self.error("Expected iterable after 'in'")
        
        self._expect(TokenType.LBRACE, "Expected '{' after for iterable")
        
        body = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end for body")
        
        return self.factory.create_for_statement(variable, iterable, body, for_token.location)
    
    def _parse_async_for_statement(self) -> Optional[AsyncForStatementNode]:
        """Parse an async for statement"""
        for_token = self._advance()  # 'for'
        async_token = self._expect(TokenType.ASYNC, "Expected 'async' after 'for'")
        
        variable_token = self._expect(TokenType.IDENTIFIER, "Expected variable name after 'async for'")
        variable = variable_token.value
        
        self._expect(TokenType.IN, "Expected 'in' after for variable")
        
        iterable = self._parse_expression()
        if not iterable:
            self.error("Expected iterable after 'in'")
        
        self._expect(TokenType.LBRACE, "Expected '{' after for iterable")
        
        body = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end for body")
        
        return self.factory.create_async_for_statement(variable, iterable, body, for_token.location)
    
    def _parse_while_statement(self) -> Optional[EnhancedWhileStatementNode]:
        """Parse a while statement"""
        while_token = self._advance()  # 'while'
        
        condition = self._parse_expression()
        if not condition:
            self.error("Expected condition after 'while'")
        
        self._expect(TokenType.LBRACE, "Expected '{' after while condition")
        
        body = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end while body")
        
        return self.factory.create_while_statement(condition, body, while_token.location)
    
    def _parse_async_statement(self) -> Optional[ASTNode]:
        """Parse an async statement (async with, etc.)"""
        async_token = self._advance()  # 'async'
        
        if self._match(TokenType.WITH):
            return self._parse_async_with_statement(async_token.location)
        else:
            self.error("Expected 'with' after 'async'")
            return None
    
    def _parse_async_with_statement(self, async_location: SourceLocation) -> Optional[AsyncWithStatementNode]:
        """Parse an async with statement"""
        self._advance()  # 'with'
        
        target = self._parse_expression()
        if not target:
            self.error("Expected resource expression after 'async with'")
        
        self._expect(TokenType.LBRACE, "Expected '{' after async with target")
        
        body = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end async with body")
        
        return self.factory.create_async_with_statement(target, body, async_location)
    
    def _parse_return_statement(self) -> Optional[EnhancedReturnStatementNode]:
        """Parse a return statement"""
        return_token = self._advance()  # 'return'
        
        value = None
        if not self._match(TokenType.SEMICOLON):
            value = self._parse_expression()
        
        if not self._match(TokenType.SEMICOLON):
            self.error("Expected ';' after return statement")
        else:
            self._advance()  # Consume semicolon
        
        return self.factory.create_return_statement(value, return_token.location)
    
    def _parse_yield_expression(self) -> Optional[YieldExpressionNode]:
        """Parse a yield expression"""
        yield_token = self._advance()  # 'yield'
        
        value = None
        if not self._match(TokenType.SEMICOLON):
            value = self._parse_expression()
        
        if not self._match(TokenType.SEMICOLON):
            self.error("Expected ';' after yield expression")
        else:
            self._advance()  # Consume semicolon
        
        return self.factory.create_yield_expression(value, yield_token.location)
    
    def _parse_import_statement(self) -> Optional[EnhancedImportStatementNode]:
        """Parse an import statement"""
        import_token = self._advance()  # 'import'
        
        module_token = self._expect(TokenType.STRING, "Expected module name as string literal")
        module_name = module_token.value
        
        # Optional alias
        alias = None
        if self._match(TokenType.AS):
            self._advance()  # 'as'
            alias_token = self._expect(TokenType.IDENTIFIER, "Expected alias name after 'as'")
            alias = alias_token.value
        
        if not self._match(TokenType.SEMICOLON):
            self.error("Expected ';' after import statement")
        else:
            self._advance()  # Consume semicolon
        
        return self.factory.create_import_statement(module_name, alias, import_token.location)
    
    def _parse_class_definition(self) -> Optional[EnhancedClassDefinitionNode]:
        """Parse a class definition"""
        class_token = self._advance()  # 'class'
        
        name_token = self._expect(TokenType.IDENTIFIER, "Expected class name after 'class'")
        name = name_token.value
        
        # Optional generic parameters
        generic_parameters = []
        if self._match(TokenType.LT):
            generic_parameters = self._parse_generic_parameters()
        
        # Optional inheritance
        extends = None
        if self._match(TokenType.EXTENDS):
            self._advance()  # 'extends'
            extends_token = self._expect(TokenType.IDENTIFIER, "Expected parent class name after 'extends'")
            extends = extends_token.value
        
        self._expect(TokenType.LBRACE, "Expected '{' to start class body")
        
        members = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            stmt = self._parse_statement()
            if stmt:
                members.append(stmt)
        
        self._expect(TokenType.RBRACE, "Expected '}' to end class body")
        
        if generic_parameters:
            return self.factory.create_generic_class_definition(name, generic_parameters, [extends] if extends else [], members, class_token.location)
        else:
            return self.factory.create_class_definition(name, extends, members, class_token.location)
    
    def _parse_match_expression(self) -> Optional[MatchExpressionNode]:
        """Parse a match expression"""
        match_token = self._advance()  # 'match'
        
        expression = self._parse_expression()
        if not expression:
            self.error("Expected expression after 'match'")
        
        self._expect(TokenType.LBRACE, "Expected '{' after match expression")
        
        cases = []
        default_case = None
        
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            if self._match(TokenType.CASE):
                case_node = self._parse_match_case()
                if case_node:
                    cases.append(case_node)
            elif self._match(TokenType.DEFAULT):
                self._advance()  # 'default'
                self._expect(TokenType.COLON, "Expected ':' after default")
               
                default_case = []
                while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF) and not self._match(TokenType.CASE):
                    stmt = self._parse_statement()
                    if stmt:
                        default_case.append(stmt)
            else:
                self.error("Expected 'case' or 'default' in match body")
                break
        
        self._expect(TokenType.RBRACE, "Expected '}' to end match body")
        
        return self.factory.create_match_expression(expression, cases, default_case, match_token.location)
    
    def _parse_match_case(self) -> Optional[MatchCaseNode]:
        """Parse a match case"""
        case_token = self._advance()  # 'case'
        
        pattern = self._parse_pattern()
        if not pattern:
            self.error("Expected pattern after 'case'")
        
        self._expect(TokenType.COLON, "Expected ':' after case pattern")
        
        body = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF) and not self._match(TokenType.CASE) and not self._match(TokenType.DEFAULT):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        return self.factory.create_match_case(pattern, body, case_token.location)
    
    def _parse_pattern(self) -> Optional[Pattern]:
        """Parse a pattern"""
        if self._match(TokenType.UNDERSCORE):
            # Wildcard pattern
            underscore_token = self._advance()
            return self.factory.create_wildcard_pattern(underscore_token.location)
        
        if self._match(TokenType.NUMBER):
            # Check if this might be a range pattern (start..end)
            if (self._peek_token().type == TokenType.RANGE or
                (self._peek_token().type == TokenType.DOT and
                 self._peek_token(2).type == TokenType.DOT)):
                return self._parse_range_pattern()
            
            # Literal pattern
            num_token = self._advance()
            value = float(num_token.value) if '.' in num_token.value else int(num_token.value)
            return self.factory.create_literal_pattern(value, num_token.location)
        
        if self._match(TokenType.STRING):
            # Literal pattern
            str_token = self._advance()
            return self.factory.create_literal_pattern(str_token.value, str_token.location)
        
        if self._match(TokenType.TRUE):
            # Literal pattern
            true_token = self._advance()
            return self.factory.create_literal_pattern(True, true_token.location)
        
        if self._match(TokenType.FALSE):
            # Literal pattern
            false_token = self._advance()
            return self.factory.create_literal_pattern(False, false_token.location)
        
        if self._match(TokenType.IDENTIFIER):
            # Save current position to potentially backtrack
            start_pos = self.position
            ident_token = self._advance()
            
            # Check if this is a guard pattern (pattern if condition)
            if self._match(TokenType.IF):
                # Backtrack and parse as guard pattern
                self.position = start_pos
                return self._parse_guard_pattern()
            
            # Check if this is a type pattern (followed by identifier)
            if self._match(TokenType.IDENTIFIER):
                type_name = ident_token.value
                var_token = self._advance()
                return self.factory.create_type_pattern(type_name, var_token.value, ident_token.location)
            
            # Save position to check for OR or AND patterns
            after_ident_pos = self.position
            
            # Check if this might be an OR pattern (pattern1 | pattern2)
            if self._current_token().type in (TokenType.OR, TokenType.PIPE):
                # Backtrack and parse as OR pattern
                self.position = start_pos
                return self._parse_or_pattern()
            
            # Check if this might be an AND pattern (pattern1 & pattern2)
            if self._current_token().type in (TokenType.AND, TokenType.AMPERSAND):
                # Backtrack and parse as AND pattern
                self.position = start_pos
                return self._parse_and_pattern()
            
            # Simple identifier pattern
            return self.factory.create_identifier_pattern(ident_token.value, ident_token.location)
        
        if self._match(TokenType.LPAREN):
            # Tuple pattern
            return self._parse_tuple_pattern()
        
        if self._match(TokenType.LBRACKET):
            # Array pattern
            return self._parse_array_pattern()
        
        if self._match(TokenType.LBRACE):
            # Object pattern
            return self._parse_object_pattern()
        
        self.error(f"Unexpected token in pattern: {self._current_token().type.value}")
        return None
    
    def _parse_non_or_pattern(self) -> Optional[Pattern]:
        """Parse a pattern that is not an OR pattern (to avoid infinite recursion)"""
        if self._match(TokenType.UNDERSCORE):
            # Wildcard pattern
            underscore_token = self._advance()
            return self.factory.create_wildcard_pattern(underscore_token.location)
        
        if self._match(TokenType.NUMBER):
            # Check if this might be a range pattern (start..end)
            if (self._peek_token().type == TokenType.RANGE or
                (self._peek_token().type == TokenType.DOT and
                 self._peek_token(2).type == TokenType.DOT)):
                return self._parse_range_pattern()
            
            # Literal pattern
            num_token = self._advance()
            value = float(num_token.value) if '.' in num_token.value else int(num_token.value)
            return self.factory.create_literal_pattern(value, num_token.location)
        
        if self._match(TokenType.STRING):
            # Literal pattern
            str_token = self._advance()
            return self.factory.create_literal_pattern(str_token.value, str_token.location)
        
        if self._match(TokenType.TRUE):
            # Literal pattern
            true_token = self._advance()
            return self.factory.create_literal_pattern(True, true_token.location)
        
        if self._match(TokenType.FALSE):
            # Literal pattern
            false_token = self._advance()
            return self.factory.create_literal_pattern(False, false_token.location)
        
        if self._match(TokenType.IDENTIFIER):
            # Save position to potentially backtrack
            start_pos = self.position
            ident_token = self._advance()
            
            # Check if this is a guard pattern (pattern if condition)
            if self._match(TokenType.IF):
                # Backtrack and parse as guard pattern
                self.position = start_pos
                return self._parse_guard_pattern()
            
            # Check if this is a type pattern (followed by identifier)
            if self._match(TokenType.IDENTIFIER):
                type_name = ident_token.value
                var_token = self._advance()
                return self.factory.create_type_pattern(type_name, var_token.value, ident_token.location)
            
            # Save position to check for AND patterns
            after_ident_pos = self.position
            
            # Check if this might be an AND pattern (pattern1 & pattern2)
            if self._current_token().type in (TokenType.AND, TokenType.AMPERSAND):
                # Backtrack and parse as AND pattern
                self.position = start_pos
                return self._parse_and_pattern()
            
            # Simple identifier pattern
            return self.factory.create_identifier_pattern(ident_token.value, ident_token.location)
        
        if self._match(TokenType.LPAREN):
            # Tuple pattern
            return self._parse_tuple_pattern()
        
        if self._match(TokenType.LBRACKET):
            # Array pattern
            return self._parse_array_pattern()
        
        if self._match(TokenType.LBRACE):
            # Object pattern
            return self._parse_object_pattern()
        
        self.error(f"Unexpected token in pattern: {self._current_token().type.value}")
        return None
    
    def _parse_or_pattern(self) -> Optional[OrPatternNode]:
        """Parse an OR pattern (pattern1 | pattern2)"""
        # Parse left pattern (but don't allow another OR pattern to avoid infinite recursion)
        left_pattern = self._parse_non_or_pattern()
        if not left_pattern:
            self.error("Expected pattern before '|'")
            return None
        
        # Expect OR operator
        if not self._current_token().type in (TokenType.OR, TokenType.PIPE):
            self.error("Expected '|' in OR pattern")
            return left_pattern
        
        self._advance()  # Consume '|'
        
        # Parse right pattern (allow OR patterns on the right for chaining)
        right_pattern = self._parse_pattern()
        if not right_pattern:
            self.error("Expected pattern after '|'")
            return left_pattern
        
        return self.factory.create_or_pattern(left_pattern, right_pattern, left_pattern.location)
    
    def _parse_and_pattern(self) -> Optional[AndPatternNode]:
        """Parse an AND pattern (pattern1 & pattern2)"""
        # Parse left pattern
        left_pattern = self._parse_pattern()
        if not left_pattern:
            self.error("Expected pattern before '&'")
            return None
        
        # Expect AND operator
        if not self._current_token().type in (TokenType.AND, TokenType.AMPERSAND):
            self.error("Expected '&' in AND pattern")
            return left_pattern
        
        self._advance()  # Consume '&'
        
        # Parse right pattern
        right_pattern = self._parse_pattern()
        if not right_pattern:
            self.error("Expected pattern after '&'")
            return left_pattern
        
        return self.factory.create_and_pattern(left_pattern, right_pattern, left_pattern.location)
    
    def _parse_guard_pattern(self) -> Optional[GuardPatternNode]:
        """Parse a guard pattern (pattern if condition)"""
        # Parse pattern
        pattern = self._parse_pattern()
        if not pattern:
            self.error("Expected pattern before 'if'")
            return None
        
        # Expect 'if' keyword
        if not self._match(TokenType.IF):
            return pattern  # Not a guard pattern, just return the pattern
        
        self._advance()  # Consume 'if'
        
        # Parse guard condition
        condition = self._parse_expression()
        if not condition:
            self.error("Expected condition after 'if'")
            return pattern
        
        return self.factory.create_guard_pattern(condition, pattern, pattern.location)
    
    def _parse_range_pattern(self) -> Optional[RangePatternNode]:
        """Parse a range pattern (start..end)"""
        # Parse start value
        start_token = self._current_token()
        if not self._match(TokenType.NUMBER):
            self.error("Expected number at start of range")
            return None
        
        start_token = self._advance()
        start_value = float(start_token.value) if '.' in start_token.value else int(start_token.value)
        
        # Expect range operator '..'
        if not (self._current_token().type == TokenType.DOT and
                self._peek_token().type == TokenType.DOT):
            self.error("Expected '..' in range pattern")
            return None
        
        # Check if we have '..'
        if not (self._current_token().type == TokenType.DOT and
                self._peek_token().type == TokenType.DOT):
            self.error("Expected '..' in range pattern")
            return None
        
        self._advance()  # Consume first '.'
        self._advance()  # Consume second '.'
        
        # Parse end value
        end_token = self._current_token()
        if not self._match(TokenType.NUMBER):
            self.error("Expected number at end of range")
            return None
        
        end_token = self._advance()
        end_value = float(end_token.value) if '.' in end_token.value else int(end_token.value)
        
        return self.factory.create_range_pattern(start_value, end_value, start_token.location)
    
    def _parse_tuple_pattern(self) -> Optional[TuplePatternNode]:
        """Parse a tuple pattern"""
        lparen_token = self._advance()  # '('
        
        elements = []
        while not self._match(TokenType.RPAREN) and not self._match(TokenType.EOF):
            pattern = self._parse_pattern()
            if pattern:
                elements.append(pattern)
            
            if self._match(TokenType.COMMA):
                self._advance()  # ','
            else:
                break
        
        self._expect(TokenType.RPAREN, "Expected ')' to end tuple pattern")
        
        return self.factory.create_tuple_pattern(elements, lparen_token.location)
    
    def _parse_array_pattern(self) -> Optional[ArrayPatternNode]:
        """Parse an array pattern"""
        lbracket_token = self._advance()  # '['
        
        elements = []
        while not self._match(TokenType.RBRACKET) and not self._match(TokenType.EOF):
            pattern = self._parse_pattern()
            if pattern:
                elements.append(pattern)
            
            if self._match(TokenType.COMMA):
                self._advance()  # ','
            else:
                break
        
        self._expect(TokenType.RBRACKET, "Expected ']' to end array pattern")
        
        return self.factory.create_array_pattern(elements, lbracket_token.location)
    
    def _parse_object_pattern(self) -> Optional[ObjectPatternNode]:
        """Parse an object pattern"""
        lbrace_token = self._advance()  # '{'
        
        properties = []
        while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
            key_token = self._expect(TokenType.IDENTIFIER, "Expected property key in object pattern")
            key = key_token.value
            
            self._expect(TokenType.COLON, "Expected ':' after object pattern key")
            
            pattern = self._parse_pattern()
            if pattern:
                properties.append((key, pattern))
            
            if self._match(TokenType.COMMA):
                self._advance()  # ','
            else:
                break
        
        self._expect(TokenType.RBRACE, "Expected '}' to end object pattern")
        
        return self.factory.create_object_pattern(properties, lbrace_token.location)
    
    def _parse_expression(self) -> Optional[ASTNode]:
        """Parse an expression"""
        return self._parse_assignment()
    
    def _parse_assignment(self) -> Optional[ASTNode]:
        """Parse assignment expression"""
        left = self._parse_logical_or()
        
        if self._match(TokenType.ASSIGN):
            assign_token = self._advance()  # '='
            right = self._parse_assignment()
            
            if not right:
                self.error("Expected expression after '='")
                return left
            
            return self.factory.create_binary_expression('=', left, right, assign_token.location)
        
        return left
    
    def _parse_logical_or(self) -> Optional[ASTNode]:
        """Parse logical OR expression"""
        left = self._parse_logical_and()
        
        while self._match(TokenType.OR):
            op_token = self._advance()  # '||'
            right = self._parse_logical_and()
            
            if not right:
                self.error("Expected expression after '||'")
                return left
            
            left = self.factory.create_binary_expression('||', left, right, op_token.location)
        
        return left
    
    def _parse_logical_and(self) -> Optional[ASTNode]:
        """Parse logical AND expression"""
        left = self._parse_equality()
        
        while self._match(TokenType.AND):
            op_token = self._advance()  # '&&'
            right = self._parse_equality()
            
            if not right:
                self.error("Expected expression after '&&'")
                return left
            
            left = self.factory.create_binary_expression('&&', left, right, op_token.location)
        
        return left
    
    def _parse_equality(self) -> Optional[ASTNode]:
        """Parse equality expression"""
        left = self._parse_comparison()
        
        while self._match(TokenType.EQ, TokenType.NE):
            op_token = self._advance()
            operator = '==' if op_token.type == TokenType.EQ else '!='
            right = self._parse_comparison()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = self.factory.create_binary_expression(operator, left, right, op_token.location)
        
        return left
    
    def _parse_comparison(self) -> Optional[ASTNode]:
        """Parse comparison expression"""
        left = self._parse_term()
        
        while self._match(TokenType.LESS_THAN, TokenType.GREATER_THAN, TokenType.LESS_EQUAL, TokenType.GREATER_EQUAL):
            op_token = self._advance()
            operator_map = {
                TokenType.LESS_THAN: '<',
                TokenType.GREATER_THAN: '>',
                TokenType.LESS_EQUAL: '<=',
                TokenType.GREATER_EQUAL: '>='
            }
            operator = operator_map[op_token.type]
            right = self._parse_term()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = self.factory.create_binary_expression(operator, left, right, op_token.location)
        
        return left
    
    def _parse_term(self) -> Optional[ASTNode]:
        """Parse term expression (addition/subtraction)"""
        left = self._parse_factor()
        
        while self._match(TokenType.PLUS, TokenType.MINUS):
            op_token = self._advance()
            operator = '+' if op_token.type == TokenType.PLUS else '-'
            right = self._parse_factor()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = self.factory.create_binary_expression(operator, left, right, op_token.location)
        
        return left
    
    def _parse_factor(self) -> Optional[ASTNode]:
        """Parse factor expression (multiplication/division)"""
        left = self._parse_unary()
        
        while self._match(TokenType.MULTIPLY, TokenType.DIVIDE, TokenType.MODULO):
            op_token = self._advance()
            operator_map = {
                TokenType.MULTIPLY: '*',
                TokenType.DIVIDE: '/',
                TokenType.MODULO: '%'
            }
            operator = operator_map[op_token.type]
            right = self._parse_unary()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = self.factory.create_binary_expression(operator, left, right, op_token.location)
        
        return left
    
    def _parse_unary(self) -> Optional[ASTNode]:
        """Parse unary expression"""
        if self._match(TokenType.NOT, TokenType.MINUS):
            op_token = self._advance()
            operator = '!' if op_token.type == TokenType.NOT else '-'
            operand = self._parse_unary()
            
            if not operand:
                self.error(f"Expected expression after '{operator}'")
                return None
            
            return self.factory.create_unary_expression(operator, operand, op_token.location)
        
        return self._parse_primary()
    
    def _parse_primary(self) -> Optional[ASTNode]:
        """Parse primary expression"""
        token = self._current_token()
        
        if self._match(TokenType.NUMBER):
            num_token = self._advance()
            value = float(num_token.value) if '.' in num_token.value else int(num_token.value)
            return self.factory.create_number_literal(value, num_token.location)
        
        if self._match(TokenType.STRING):
            str_token = self._advance()
            return self.factory.create_string_literal(str_token.value, str_token.location)
        
        if self._match(TokenType.TRUE):
            true_token = self._advance()
            return self.factory.create_boolean_literal(True, true_token.location)
        
        if self._match(TokenType.FALSE):
            false_token = self._advance()
            return self.factory.create_boolean_literal(False, false_token.location)
        
        if self._match(TokenType.NONE):
            none_token = self._advance()
            return self.factory.create_none_literal(none_token.location)
        
        if self._match(TokenType.IDENTIFIER):
            ident_token = self._advance()
            name = ident_token.value
            
            # Function call
            if self._match(TokenType.LPAREN):
                return self._parse_function_call(name, ident_token.location)
            
            # Variable reference
            return self.factory.create_identifier(name, ident_token.location)
        
        if self._match(TokenType.AWAIT):
            await_token = self._advance()
            expression = self._parse_primary()
            if not expression:
                self.error("Expected expression after 'await'")
                return None
            
            return self.factory.create_await_expression(expression, await_token.location)
        
        if self._match(TokenType.LPAREN):
            self._advance()  # '('
            expr = self._parse_expression()
            if not expr:
                self.error("Expected expression inside parentheses")
                return None
            
            self._expect(TokenType.RPAREN, "Expected ')' after expression")
            return expr
        
        if self._match(TokenType.LBRACE):
            return self._parse_object_literal()
        
        if self._match(TokenType.LBRACKET):
            return self._parse_array_literal()
        
        self.error(f"Unexpected token: {token.type.value}")
        return None
    
    def _parse_function_call(self, function_name: str, location: SourceLocation) -> Optional[EnhancedFunctionCallNode]:
        """Parse a function call"""
        self._advance()  # '('
        
        arguments = []
        if not self._match(TokenType.RPAREN):
            while True:
                arg = self._parse_expression()
                if arg:
                    arguments.append(arg)
                
                if self._match(TokenType.COMMA):
                    self._advance()  # ','
                else:
                    break
        
        self._expect(TokenType.RPAREN, "Expected ')' after function arguments")
        
        return self.factory.create_function_call(function_name, arguments, location)
    
    def _parse_object_literal(self) -> Optional[EnhancedObjectLiteralNode]:
        """Parse an object literal"""
        lbrace_token = self._advance()  # '{'
        
        properties = []
        if not self._match(TokenType.RBRACE):
            while True:
                key_token = self._expect(TokenType.STRING, "Expected string key in object literal")
                key = key_token.value
                
                self._expect(TokenType.COLON, "Expected ':' after object key")
                value = self._parse_expression()
                
                if not value:
                    self.error("Expected value after ':' in object literal")
                    break
                
                properties.append(self.factory.create_object_property(key, value, key_token.location))
                
                if self._match(TokenType.COMMA):
                    self._advance()  # ','
                else:
                    break
        
        self._expect(TokenType.RBRACE, "Expected '}' to end object literal")
        
        return self.factory.create_object_literal(properties, lbrace_token.location)
    
    def _parse_array_literal(self) -> Optional[EnhancedArrayLiteralNode]:
        """Parse an array literal"""
        lbracket_token = self._advance()  # '['
        
        elements = []
        if not self._match(TokenType.RBRACKET):
            while True:
                element = self._parse_expression()
                if element:
                    elements.append(element)
                
                if self._match(TokenType.COMMA):
                    self._advance()  # ','
                else:
                    break
        
        self._expect(TokenType.RBRACKET, "Expected ']' to end array literal")
        
        return self.factory.create_array_literal(elements, lbracket_token.location)


def parse_source(source: str, filename: str = "<source>") -> EnhancedProgramNode:
    """Parse Noodle source code with enhanced parser"""
    parser = EnhancedParser(source, filename)
    return parser.parse()


def parse_file(filepath: str) -> EnhancedProgramNode:
    """Parse a Noodle file with enhanced parser"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            source = f.read()
        return parse_source(source, filepath)
    except Exception as e:
        raise Exception(f"Failed to read file {filepath}: {str(e)}")


def create_enhanced_parser(source: str, filename: str = "<source>", parser_config=None) -> EnhancedParser:
    """Create an enhanced parser instance"""
    return EnhancedParser(source, filename)


if __name__ == '__main__':
    import sys
    import json
    
    if len(sys.argv) < 2:
        print("Usage: python enhanced_parser.py <file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    
    try:
        ast = parse_file(filepath)
        print(json.dumps(ast.to_dict(), indent=2))
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

