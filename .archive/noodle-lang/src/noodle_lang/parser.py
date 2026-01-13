#!/usr/bin/env python3
"""
Noodle Lang::Parser - parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Noodle Language Parser

This module implements the parser for the Noodle programming language,
converting token streams into Abstract Syntax Trees (ASTs).

Features:
- Recursive descent parsing
- Error recovery
- AST construction
- Source location tracking
- Type annotation parsing
"""

from typing import Dict, List, Optional, Tuple, Any, Union
from dataclasses import dataclass
from enum import Enum

from .lexer import NoodleLexer, SourceLocation, CompilationError, CompilationPhase


class NodeType(Enum):
    """AST node types"""
    PROGRAM = "program"
    LET_STATEMENT = "let_statement"
    FUNCTION_DEFINITION = "function_definition"
    IF_STATEMENT = "if_statement"
    FOR_STATEMENT = "for_statement"
    WHILE_STATEMENT = "while_statement"
    RETURN_STATEMENT = "return_statement"
    IMPORT_STATEMENT = "import_statement"
    CLASS_DEFINITION = "class_definition"
    EXPRESSION_STATEMENT = "expression_statement"
    
    BINARY_EXPRESSION = "binary_expression"
    UNARY_EXPRESSION = "unary_expression"
    FUNCTION_CALL = "function_call"
    IDENTIFIER = "identifier"
    NUMBER_LITERAL = "number_literal"
    STRING_LITERAL = "string_literal"
    BOOLEAN_LITERAL = "boolean_literal"
    NONE_LITERAL = "none_literal"
    ARRAY_LITERAL = "array_literal"
    OBJECT_LITERAL = "object_literal"


@dataclass
class ASTNode:
    """Base AST node class"""
    type: NodeType
    location: SourceLocation
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert node to dictionary representation"""
        result = {
            'type': self.type.value,
            'location': {
                'file': self.location.file,
                'line': self.location.line,
                'column': self.location.column,
                'offset': self.location.offset
            }
        }
        
        # Add node-specific fields
        for field_name, field_value in self.__dict__.items():
            if field_name not in ['type', 'location']:
                if isinstance(field_value, ASTNode):
                    result[field_name] = field_value.to_dict()
                elif isinstance(field_value, list):
                    result[field_name] = [item.to_dict() if isinstance(item, ASTNode) else item for item in field_value]
                else:
                    result[field_name] = field_value
        
        return result


@dataclass
class ProgramNode(ASTNode):
    """Program AST node"""
    statements: List[ASTNode]
    
    def __init__(self, statements: List[ASTNode], location: SourceLocation):
        self.type = NodeType.PROGRAM
        self.location = location
        self.statements = statements


@dataclass
class LetStatementNode(ASTNode):
    """Let statement AST node"""
    name: str
    type_annotation: Optional[str]
    initializer: Optional[ASTNode]
    
    def __init__(self, name: str, type_annotation: Optional[str], initializer: Optional[ASTNode], location: SourceLocation):
        self.type = NodeType.LET_STATEMENT
        self.location = location
        self.name = name
        self.type_annotation = type_annotation
        self.initializer = initializer


@dataclass
class ParameterNode:
    """Function parameter"""
    name: str
    type_annotation: Optional[str]
    location: SourceLocation


@dataclass
class FunctionDefinitionNode(ASTNode):
    """Function definition AST node"""
    name: str
    parameters: List[ParameterNode]
    return_type: Optional[str]
    body: List[ASTNode]
    
    def __init__(self, name: str, parameters: List[ParameterNode], return_type: Optional[str], body: List[ASTNode], location: SourceLocation):
        self.type = NodeType.FUNCTION_DEFINITION
        self.location = location
        self.name = name
        self.parameters = parameters
        self.return_type = return_type
        self.body = body


@dataclass
class IfStatementNode(ASTNode):
    """If statement AST node"""
    condition: ASTNode
    then_branch: List[ASTNode]
    else_branch: Union[ASTNode, List[ASTNode], None]
    
    def __init__(self, condition: ASTNode, then_branch: List[ASTNode], else_branch: Union[ASTNode, List[ASTNode], None], location: SourceLocation):
        self.type = NodeType.IF_STATEMENT
        self.location = location
        self.condition = condition
        self.then_branch = then_branch
        self.else_branch = else_branch


@dataclass
class ForStatementNode(ASTNode):
    """For statement AST node"""
    variable: str
    iterable: ASTNode
    body: List[ASTNode]
    
    def __init__(self, variable: str, iterable: ASTNode, body: List[ASTNode], location: SourceLocation):
        self.type = NodeType.FOR_STATEMENT
        self.location = location
        self.variable = variable
        self.iterable = iterable
        self.body = body


@dataclass
class WhileStatementNode(ASTNode):
    """While statement AST node"""
    condition: ASTNode
    body: List[ASTNode]
    
    def __init__(self, condition: ASTNode, body: List[ASTNode], location: SourceLocation):
        self.type = NodeType.WHILE_STATEMENT
        self.location = location
        self.condition = condition
        self.body = body


@dataclass
class ReturnStatementNode(ASTNode):
    """Return statement AST node"""
    value: Optional[ASTNode]
    
    def __init__(self, value: Optional[ASTNode], location: SourceLocation):
        self.type = NodeType.RETURN_STATEMENT
        self.location = location
        self.value = value


@dataclass
class ImportStatementNode(ASTNode):
    """Import statement AST node"""
    module: str
    alias: Optional[str]
    
    def __init__(self, module: str, alias: Optional[str], location: SourceLocation):
        self.type = NodeType.IMPORT_STATEMENT
        self.location = location
        self.module = module
        self.alias = alias


@dataclass
class ClassDefinitionNode(ASTNode):
    """Class definition AST node"""
    name: str
    extends: Optional[str]
    members: List[ASTNode]
    
    def __init__(self, name: str, extends: Optional[str], members: List[ASTNode], location: SourceLocation):
        self.type = NodeType.CLASS_DEFINITION
        self.location = location
        self.name = name
        self.extends = extends
        self.members = members


@dataclass
class ExpressionStatementNode(ASTNode):
    """Expression statement AST node"""
    expression: ASTNode
    
    def __init__(self, expression: ASTNode, location: SourceLocation):
        self.type = NodeType.EXPRESSION_STATEMENT
        self.location = location
        self.expression = expression


@dataclass
class BinaryExpressionNode(ASTNode):
    """Binary expression AST node"""
    operator: str
    left: ASTNode
    right: ASTNode
    
    def __init__(self, operator: str, left: ASTNode, right: ASTNode, location: SourceLocation):
        self.type = NodeType.BINARY_EXPRESSION
        self.location = location
        self.operator = operator
        self.left = left
        self.right = right


@dataclass
class UnaryExpressionNode(ASTNode):
    """Unary expression AST node"""
    operator: str
    operand: ASTNode
    
    def __init__(self, operator: str, operand: ASTNode, location: SourceLocation):
        self.type = NodeType.UNARY_EXPRESSION
        self.location = location
        self.operator = operator
        self.operand = operand


@dataclass
class FunctionCallNode(ASTNode):
    """Function call AST node"""
    function: str
    arguments: List[ASTNode]
    
    def __init__(self, function: str, arguments: List[ASTNode], location: SourceLocation):
        self.type = NodeType.FUNCTION_CALL
        self.location = location
        self.function = function
        self.arguments = arguments


@dataclass
class IdentifierNode(ASTNode):
    """Identifier AST node"""
    name: str
    
    def __init__(self, name: str, location: SourceLocation):
        self.type = NodeType.IDENTIFIER
        self.location = location
        self.name = name


@dataclass
class NumberLiteralNode(ASTNode):
    """Number literal AST node"""
    value: Union[int, float]
    
    def __init__(self, value: Union[int, float], location: SourceLocation):
        self.type = NodeType.NUMBER_LITERAL
        self.location = location
        self.value = value


@dataclass
class StringLiteralNode(ASTNode):
    """String literal AST node"""
    value: str
    
    def __init__(self, value: str, location: SourceLocation):
        self.type = NodeType.STRING_LITERAL
        self.location = location
        self.value = value


@dataclass
class BooleanLiteralNode(ASTNode):
    """Boolean literal AST node"""
    value: bool
    
    def __init__(self, value: bool, location: SourceLocation):
        self.type = NodeType.BOOLEAN_LITERAL
        self.location = location
        self.value = value


@dataclass
class NoneLiteralNode(ASTNode):
    """None literal AST node"""
    value: None
    
    def __init__(self, location: SourceLocation):
        self.type = NodeType.NONE_LITERAL
        self.location = location
        self.value = None


@dataclass
class ArrayLiteralNode(ASTNode):
    """Array literal AST node"""
    elements: List[ASTNode]
    
    def __init__(self, elements: List[ASTNode], location: SourceLocation):
        self.type = NodeType.ARRAY_LITERAL
        self.location = location
        self.elements = elements


@dataclass
class ObjectPropertyNode:
    """Object property"""
    key: str
    value: ASTNode
    location: SourceLocation


@dataclass
class ObjectLiteralNode(ASTNode):
    """Object literal AST node"""
    properties: List[ObjectPropertyNode]
    
    def __init__(self, properties: List[ObjectPropertyNode], location: SourceLocation):
        self.type = NodeType.OBJECT_LITERAL
        self.location = location
        self.properties = properties


class NoodleParser:
    """Parser for Noodle language"""
    
    def __init__(self, source: str, filename: str = "<input>"):
        self.lexer = NoodleLexer(source, filename)
        self.tokens = []
        self.position = 0
        self.errors = []
        self.warnings = []
        
        # Tokenize first
        self.tokens = self.lexer.tokenize()
        self.errors.extend(self.lexer.errors)
    
    def error(self, message: str, location: SourceLocation = None):
        """Record a parsing error"""
        if location is None:
            token = self._current_token()
            location = token[2] if len(token) > 2 else SourceLocation("", 0, 0, 0)
        
        self.errors.append(CompilationError(location, message, "error", CompilationPhase.PARSING))
    
    def warning(self, message: str, location: SourceLocation = None):
        """Record a parsing warning"""
        if location is None:
            token = self._current_token()
            location = token[2] if len(token) > 2 else SourceLocation("", 0, 0, 0)
        
        self.warnings.append(CompilationError(location, message, "warning", CompilationPhase.PARSING))
    
    def _current_token(self) -> Tuple[str, str, SourceLocation]:
        """Get current token"""
        if self.position >= len(self.tokens):
            return ('EOF', '', SourceLocation("", 0, 0, 0))
        return self.tokens[self.position]
    
    def _peek_token(self, offset: int = 1) -> Tuple[str, str, SourceLocation]:
        """Peek at token at offset"""
        pos = self.position + offset
        if pos >= len(self.tokens):
            return ('EOF', '', SourceLocation("", 0, 0, 0))
        return self.tokens[pos]
    
    def _advance(self) -> Tuple[str, str, SourceLocation]:
        """Advance to next token"""
        token = self._current_token()
        self.position += 1
        return token
    
    def _expect(self, expected_type: str, error_message: str = None) -> Tuple[str, str, SourceLocation]:
        """Expect a specific token type"""
        token = self._current_token()
        if token[0] == expected_type:
            return self._advance()
        
        if error_message is None:
            error_message = f"Expected {expected_type}, got {token[0]}"
        self.error(error_message)
        return token
    
    def _match(self, *token_types: str) -> bool:
        """Check if current token matches any of the given types"""
        return self._current_token()[0] in token_types
    
    def parse(self) -> ProgramNode:
        """Parse token stream into an AST"""
        self.errors = []
        self.warnings = []
        
        statements = []
        
        while not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                statements.append(stmt)
        
        location = SourceLocation("", 0, 0, 0) if not statements else statements[0].location
        return ProgramNode(statements, location)
    
    def _parse_statement(self) -> Optional[ASTNode]:
        """Parse a statement"""
        if self._match('LET'):
            return self._parse_let_statement()
        elif self._match('DEF'):
            return self._parse_function_definition()
        elif self._match('IF'):
            return self._parse_if_statement()
        elif self._match('FOR'):
            return self._parse_for_statement()
        elif self._match('WHILE'):
            return self._parse_while_statement()
        elif self._match('RETURN'):
            return self._parse_return_statement()
        elif self._match('IMPORT'):
            return self._parse_import_statement()
        elif self._match('CLASS'):
            return self._parse_class_definition()
        else:
            # Try to parse as expression statement
            expr = self._parse_expression()
            if expr:
                if not self._match('SEMICOLON'):
                    self.error("Expected ';' after expression")
                else:
                    self._advance()  # Consume semicolon
                return ExpressionStatementNode(expr, expr.location)
            return None
    
    def _parse_let_statement(self) -> Optional[LetStatementNode]:
        """Parse a let statement (variable declaration)"""
        let_token = self._advance()  # 'let'
        
        name_token = self._expect('IDENTIFIER', "Expected variable name after 'let'")
        name = name_token[1]
        
        # Optional type annotation
        type_annotation = None
        if self._match('COLON'):
            self._advance()  # ':'
            type_token = self._expect('IDENTIFIER', "Expected type name after ':'")
            type_annotation = type_token[1]
        
        # Optional initialization
        initializer = None
        if self._match('ASSIGN'):
            self._advance()  # '='
            initializer = self._parse_expression()
        
        if not self._match('SEMICOLON'):
            self.error("Expected ';' after let statement")
        else:
            self._advance()  # Consume semicolon
        
        return LetStatementNode(name, type_annotation, initializer, let_token[2])
    
    def _parse_function_definition(self) -> Optional[FunctionDefinitionNode]:
        """Parse a function definition"""
        def_token = self._advance()  # 'def'
        
        name_token = self._expect('IDENTIFIER', "Expected function name after 'def'")
        name = name_token[1]
        
        self._expect('LPAREN', "Expected '(' after function name")
        
        parameters = []
        if not self._match('RPAREN'):
            while True:
                param_name_token = self._expect('IDENTIFIER', "Expected parameter name")
                param_name = param_name_token[1]
                
                # Optional type annotation
                param_type = None
                if self._match('COLON'):
                    self._advance()  # ':'
                    type_token = self._expect('IDENTIFIER', "Expected type name after ':'")
                    param_type = type_token[1]
                
                parameters.append(ParameterNode(param_name, param_type, param_name_token[2]))
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RPAREN', "Expected ')' after parameters")
        
        # Optional return type
        return_type = None
        if self._match('ARROW'):
            self._advance()  # '->'
            return_type_token = self._expect('IDENTIFIER', "Expected return type after '->'")
            return_type = return_type_token[1]
        
        # Function body
        self._expect('LBRACE', "Expected '{' to start function body")
        
        body = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end function body")
        
        return FunctionDefinitionNode(name, parameters, return_type, body, def_token[2])
    
    def _parse_if_statement(self) -> Optional[IfStatementNode]:
        """Parse an if statement"""
        if_token = self._advance()  # 'if'
        
        condition = self._parse_expression()
        if not condition:
            self.error("Expected condition after 'if'")
        
        self._expect('LBRACE', "Expected '{' after if condition")
        
        then_branch = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                then_branch.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end if body")
        
        # Optional else branch
        else_branch = None
        if self._match('ELSE'):
            self._advance()  # 'else'
            
            if self._match('IF'):
                # else if
                else_branch = self._parse_if_statement()
            else:
                self._expect('LBRACE', "Expected '{' after else")
                
                else_branch = []
                while not self._match('RBRACE') and not self._match('EOF'):
                    stmt = self._parse_statement()
                    if stmt:
                        else_branch.append(stmt)
                
                self._expect('RBRACE', "Expected '}' to end else body")
        
        return IfStatementNode(condition, then_branch, else_branch, if_token[2])
    
    def _parse_for_statement(self) -> Optional[ForStatementNode]:
        """Parse a for statement"""
        for_token = self._advance()  # 'for'
        
        variable_token = self._expect('IDENTIFIER', "Expected variable name after 'for'")
        variable = variable_token[1]
        
        self._expect('IN', "Expected 'in' after for variable")
        
        iterable = self._parse_expression()
        if not iterable:
            self.error("Expected iterable after 'in'")
        
        self._expect('LBRACE', "Expected '{' after for iterable")
        
        body = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end for body")
        
        return ForStatementNode(variable, iterable, body, for_token[2])
    
    def _parse_while_statement(self) -> Optional[WhileStatementNode]:
        """Parse a while statement"""
        while_token = self._advance()  # 'while'
        
        condition = self._parse_expression()
        if not condition:
            self.error("Expected condition after 'while'")
        
        self._expect('LBRACE', "Expected '{' after while condition")
        
        body = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                body.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end while body")
        
        return WhileStatementNode(condition, body, while_token[2])
    
    def _parse_return_statement(self) -> Optional[ReturnStatementNode]:
        """Parse a return statement"""
        return_token = self._advance()  # 'return'
        
        value = None
        if not self._match('SEMICOLON'):
            value = self._parse_expression()
        
        if not self._match('SEMICOLON'):
            self.error("Expected ';' after return statement")
        else:
            self._advance()  # Consume semicolon
        
        return ReturnStatementNode(value, return_token[2])
    
    def _parse_import_statement(self) -> Optional[ImportStatementNode]:
        """Parse an import statement"""
        import_token = self._advance()  # 'import'
        
        module_token = self._expect('STRING', "Expected module name as string literal")
        module_name = module_token[1]
        
        # Optional alias
        alias = None
        if self._match('AS'):
            self._advance()  # 'as'
            alias_token = self._expect('IDENTIFIER', "Expected alias name after 'as'")
            alias = alias_token[1]
        
        if not self._match('SEMICOLON'):
            self.error("Expected ';' after import statement")
        else:
            self._advance()  # Consume semicolon
        
        return ImportStatementNode(module_name, alias, import_token[2])
    
    def _parse_class_definition(self) -> Optional[ClassDefinitionNode]:
        """Parse a class definition"""
        class_token = self._advance()  # 'class'
        
        name_token = self._expect('IDENTIFIER', "Expected class name after 'class'")
        name = name_token[1]
        
        # Optional inheritance
        extends = None
        if self._match('EXTENDS'):
            self._advance()  # 'extends'
            extends_token = self._expect('IDENTIFIER', "Expected parent class name after 'extends'")
            extends = extends_token[1]
        
        self._expect('LBRACE', "Expected '{' to start class body")
        
        members = []
        while not self._match('RBRACE') and not self._match('EOF'):
            stmt = self._parse_statement()
            if stmt:
                members.append(stmt)
        
        self._expect('RBRACE', "Expected '}' to end class body")
        
        return ClassDefinitionNode(name, extends, members, class_token[2])
    
    def _parse_expression(self) -> Optional[ASTNode]:
        """Parse an expression"""
        return self._parse_assignment()
    
    def _parse_assignment(self) -> Optional[ASTNode]:
        """Parse assignment expression"""
        left = self._parse_logical_or()
        
        if self._match('ASSIGN'):
            assign_token = self._advance()  # '='
            right = self._parse_assignment()
            
            if not right:
                self.error("Expected expression after '='")
                return left
            
            return BinaryExpressionNode('=', left, right, assign_token[2])
        
        return left
    
    def _parse_logical_or(self) -> Optional[ASTNode]:
        """Parse logical OR expression"""
        left = self._parse_logical_and()
        
        while self._match('OR'):
            op_token = self._advance()  # '||'
            right = self._parse_logical_and()
            
            if not right:
                self.error("Expected expression after '||'")
                return left
            
            left = BinaryExpressionNode('||', left, right, op_token[2])
        
        return left
    
    def _parse_logical_and(self) -> Optional[ASTNode]:
        """Parse logical AND expression"""
        left = self._parse_equality()
        
        while self._match('AND'):
            op_token = self._advance()  # '&&'
            right = self._parse_equality()
            
            if not right:
                self.error("Expected expression after '&&'")
                return left
            
            left = BinaryExpressionNode('&&', left, right, op_token[2])
        
        return left
    
    def _parse_equality(self) -> Optional[ASTNode]:
        """Parse equality expression"""
        left = self._parse_comparison()
        
        while self._match('EQ', 'NE'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_comparison()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = BinaryExpressionNode(operator, left, right, op_token[2])
        
        return left
    
    def _parse_comparison(self) -> Optional[ASTNode]:
        """Parse comparison expression"""
        left = self._parse_term()
        
        while self._match('LT', 'GT', 'LE', 'GE'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_term()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = BinaryExpressionNode(operator, left, right, op_token[2])
        
        return left
    
    def _parse_term(self) -> Optional[ASTNode]:
        """Parse term expression (addition/subtraction)"""
        left = self._parse_factor()
        
        while self._match('PLUS', 'MINUS'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_factor()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = BinaryExpressionNode(operator, left, right, op_token[2])
        
        return left
    
    def _parse_factor(self) -> Optional[ASTNode]:
        """Parse factor expression (multiplication/division)"""
        left = self._parse_unary()
        
        while self._match('MULTIPLY', 'DIVIDE', 'MODULO'):
            op_token = self._advance()
            operator = op_token[0]
            right = self._parse_unary()
            
            if not right:
                self.error(f"Expected expression after '{operator}'")
                return left
            
            left = BinaryExpressionNode(operator, left, right, op_token[2])
        
        return left
    
    def _parse_unary(self) -> Optional[ASTNode]:
        """Parse unary expression"""
        if self._match('NOT', 'MINUS'):
            op_token = self._advance()
            operator = op_token[0]
            operand = self._parse_unary()
            
            if not operand:
                self.error(f"Expected expression after '{operator}'")
                return None
            
            return UnaryExpressionNode(operator, operand, op_token[2])
        
        return self._parse_primary()
    
    def _parse_primary(self) -> Optional[ASTNode]:
        """Parse primary expression"""
        token = self._current_token()
        
        if self._match('NUMBER'):
            num_token = self._advance()
            value = float(num_token[1]) if '.' in num_token[1] else int(num_token[1])
            return NumberLiteralNode(value, num_token[2])
        
        if self._match('STRING'):
            str_token = self._advance()
            return StringLiteralNode(str_token[1], str_token[2])
        
        if self._match('TRUE'):
            true_token = self._advance()
            return BooleanLiteralNode(True, true_token[2])
        
        if self._match('FALSE'):
            false_token = self._advance()
            return BooleanLiteralNode(False, false_token[2])
        
        if self._match('NONE'):
            none_token = self._advance()
            return NoneLiteralNode(none_token[2])
        
        if self._match('IDENTIFIER'):
            ident_token = self._advance()
            name = ident_token[1]
            
            # Function call
            if self._match('LPAREN'):
                return self._parse_function_call(name, ident_token[2])
            
            # Variable reference
            return IdentifierNode(name, ident_token[2])
        
        if self._match('LPAREN'):
            self._advance()  # '('
            expr = self._parse_expression()
            if not expr:
                self.error("Expected expression inside parentheses")
                return None
            
            self._expect('RPAREN', "Expected ')' after expression")
            return expr
        
        if self._match('LBRACE'):
            return self._parse_object_literal()
        
        if self._match('LBRACKET'):
            return self._parse_array_literal()
        
        self.error(f"Unexpected token: {token[0]}")
        return None
    
    def _parse_function_call(self, function_name: str, location: SourceLocation) -> Optional[FunctionCallNode]:
        """Parse a function call"""
        self._advance()  # '('
        
        arguments = []
        if not self._match('RPAREN'):
            while True:
                arg = self._parse_expression()
                if arg:
                    arguments.append(arg)
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RPAREN', "Expected ')' after function arguments")
        
        return FunctionCallNode(function_name, arguments, location)
    
    def _parse_object_literal(self) -> Optional[ObjectLiteralNode]:
        """Parse an object literal"""
        lbrace_token = self._advance()  # '{'
        
        properties = []
        if not self._match('RBRACE'):
            while True:
                key_token = self._expect('STRING', "Expected string key in object literal")
                key = key_token[1]
                
                self._expect('COLON', "Expected ':' after object key")
                value = self._parse_expression()
                
                if not value:
                    self.error("Expected value after ':' in object literal")
                    break
                
                properties.append(ObjectPropertyNode(key, value, key_token[2]))
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RBRACE', "Expected '}' to end object literal")
        
        return ObjectLiteralNode(properties, lbrace_token[2])
    
    def _parse_array_literal(self) -> Optional[ArrayLiteralNode]:
        """Parse an array literal"""
        lbracket_token = self._advance()  # '['
        
        elements = []
        if not self._match('RBRACKET'):
            while True:
                element = self._parse_expression()
                if element:
                    elements.append(element)
                
                if self._match('COMMA'):
                    self._advance()  # ','
                else:
                    break
        
        self._expect('RBRACKET', "Expected ']' to end array literal")
        
        return ArrayLiteralNode(elements, lbracket_token[2])


def parse_source(source: str, filename: str = "<source>") -> ProgramNode:
    """Parse Noodle source code"""
    parser = NoodleParser(source, filename)
    return parser.parse()


def parse_file(filepath: str) -> ProgramNode:
    """Parse a Noodle file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            source = f.read()
        return parse_source(source, filepath)
    except Exception as e:
        raise Exception(f"Failed to read file {filepath}: {str(e)}")


if __name__ == '__main__':
    import sys
    import json
    
    if len(sys.argv) < 2:
        print("Usage: python parser.py <file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    
    try:
        ast = parse_file(filepath)
        print(json.dumps(ast.to_dict(), indent=2))
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

