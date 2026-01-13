# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Syntax Validator Module

# This module implements syntax validation for NoodleCore code using the formal grammar.
# """

import time
import typing.Dict,
import logging

import .validator_base.(
#     ValidatorBase, ValidationResult, ValidationIssue,
#     ValidationSeverity, ValidationStatus
# )
import .grammar.NoodleCoreGrammar,


class SyntaxValidator(ValidatorBase)
    #     """Syntax validator for NoodleCore code."""

    #     def __init__(self, config: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize the syntax validator.

    #         Args:
    #             config: Optional configuration dictionary
    #         """
            super().__init__("SyntaxValidator", config)
    self.grammar = NoodleCoreGrammar()
    self.required_constructs = {
    #             'module_declaration': False,
    #             'entry_point': False
    #         }
    self.construct_patterns = {
    #             'module_declaration': r'^module\s+[\w.]+\s*:',
                'entry_point': r'^entry\s+\w+\s*\(.*\)\s*:',
                'function_definition': r'^func\s+\w+\s*\(.*\)\s*:',
    #             'type_definition': r'^type\s+\w+\s*:',
    #             'import_statement': r'^import\s+[\w.]+',
    #             'match_statement': r'^match\s+',
    #             'case_statement': r'^case\s+',
    #             'end_statement': r'^end\s*$'
    #         }

    #         # Error code definitions for syntax validation (2001-2099)
    self.error_codes = {
    #             'invalid_token': '2001',
    #             'unexpected_token': '2002',
    #             'missing_token': '2003',
    #             'invalid_module_declaration': '2004',
    #             'invalid_entry_declaration': '2005',
    #             'invalid_function_declaration': '2006',
    #             'invalid_type_declaration': '2007',
    #             'invalid_import_declaration': '2008',
    #             'invalid_match_case': '2009',
    #             'missing_end_statement': '2010',
    #             'invalid_identifier': '2011',
    #             'invalid_string_literal': '2012',
    #             'invalid_number_literal': '2013',
    #             'unclosed_block': '2014',
    #             'mismatched_brackets': '2015',
    #             'missing_required_construct': '2016'
    #         }

    #     async def validate(self, code: str, **kwargs) -> ValidationResult:
    #         """
    #         Validate NoodleCore code syntax.

    #         Args:
    #             code: NoodleCore code to validate
    #             **kwargs: Additional validation parameters

    #         Returns:
    #             ValidationResult object containing validation results
    #         """
    start_time = time.time()
    strict_mode = kwargs.get('strict_mode', False)

    #         # Check cache first
    cache_key = math.multiply(self._get_cache_key(code,, *kwargs))
    cached_result = self._get_cached_result(cache_key)
    #         if cached_result:
    #             return cached_result

    result = ValidationResult(
    validator_name = self.name,
    metrics = {
    #                 'validation_time': 0.0,
    #                 'token_count': 0,
    #                 'ast_nodes': 0,
                    'lines_processed': len(code.split('\n'))
    #             }
    #         )

    #         try:
    #             # Tokenize the code
    tokens = self.grammar.tokenize_only(code)
    result.metrics['token_count'] = len(tokens)

    #             # Validate tokens
                self._validate_tokens(tokens, result, strict_mode)

    #             # Parse the code into AST
    tokens, ast_root = self.grammar.parse(code)
    result.metrics['ast_nodes'] = self._count_ast_nodes(ast_root)

    #             # Validate AST structure
                self._validate_ast_structure(ast_root, result, strict_mode)

    #             # Check for required language elements
                self._validate_required_constructs(ast_root, result, strict_mode)

    #             # Validate syntax structure and nesting
                self._validate_structure_and_nesting(tokens, result, strict_mode)

    #         except Exception as e:
                self.logger.error(f"Syntax validation error: {str(e)}")
                result.add_issue(ValidationIssue(
    message = f"Syntax validation failed: {str(e)}",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_token']
    #             ))
    result.status = ValidationStatus.FAILED

    #         # Update metrics
    validation_time = math.subtract(time.time(), start_time)
    result.metrics['validation_time'] = validation_time
            self._update_metrics(start_time)

    #         # Cache the result
            self._cache_result(cache_key, result)

    #         return result

    #     def _validate_tokens(self, tokens: List[Token], result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate individual tokens.

    #         Args:
    #             tokens: List of tokens to validate
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         for token in tokens:
    #             if token.type == TokenType.UNKNOWN:
                    result.add_issue(ValidationIssue(
    line = token.line,
    column = token.column,
    message = f"Unknown token: '{token.value}'",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_token'],
    suggestion = "Remove or replace the unknown token"
    #                 ))

    #             # Validate string literals
    #             elif token.type == TokenType.STRING:
    #                 if not self._is_valid_string_literal(token.value):
                        result.add_issue(ValidationIssue(
    line = token.line,
    column = token.column,
    message = f"Invalid string literal: {token.value}",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_string_literal'],
    #                         suggestion="Check for unclosed quotes or escape sequences"
    #                     ))

    #             # Validate identifiers
    #             elif token.type == TokenType.IDENTIFIER:
    #                 if not self._is_valid_identifier(token.value):
                        result.add_issue(ValidationIssue(
    line = token.line,
    column = token.column,
    message = f"Invalid identifier: {token.value}",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_identifier'],
    #                         suggestion="Identifiers must start with a letter or underscore and contain only letters, digits, and underscores"
    #                     ))

    #     def _validate_ast_structure(self, ast_root: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate the AST structure.

    #         Args:
    #             ast_root: Root AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if ast_root.node_type != "Program":
                result.add_issue(ValidationIssue(
    message = f"Invalid AST root node: {ast_root.node_type}",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_token']
    #             ))

    #         # Validate each top-level declaration
    #         for child in ast_root.children:
                self._validate_declaration(child, result, strict_mode)

    #     def _validate_declaration(self, node: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate a declaration node.

    #         Args:
    #             node: AST node to validate
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if node.node_type == "ModuleDeclaration":
                self._validate_module_declaration(node, result, strict_mode)
    #         elif node.node_type == "ImportDeclaration":
                self._validate_import_declaration(node, result, strict_mode)
    #         elif node.node_type == "EntryDeclaration":
                self._validate_entry_declaration(node, result, strict_mode)
    #         elif node.node_type == "FunctionDeclaration":
                self._validate_function_declaration(node, result, strict_mode)
    #         elif node.node_type == "TypeDeclaration":
                self._validate_type_declaration(node, result, strict_mode)

    #     def _validate_module_declaration(self, node: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate a module declaration.

    #         Args:
    #             node: Module declaration AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if not node.children or node.children[0].node_type != "Identifier":
                result.add_issue(ValidationIssue(
    line = node.line,
    column = node.column,
    message = "Module declaration missing module name",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_module_declaration'],
    suggestion = "Add a module name after 'module' keyword"
    #             ))
    #         else:
    self.required_constructs['module_declaration'] = True

    #     def _validate_import_declaration(self, node: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate an import declaration.

    #         Args:
    #             node: Import declaration AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if not node.children or node.children[0].node_type != "ModuleName":
                result.add_issue(ValidationIssue(
    line = node.line,
    column = node.column,
    message = "Import declaration missing module name",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_import_declaration'],
    suggestion = "Add a module name after 'import' keyword"
    #             ))

    #     def _validate_entry_declaration(self, node: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate an entry declaration.

    #         Args:
    #             node: Entry declaration AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if not node.children or len(node.children) < 2:
                result.add_issue(ValidationIssue(
    line = node.line,
    column = node.column,
    message = "Entry declaration missing function name or parameters",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_entry_declaration'],
    suggestion = "Add a function name and parameter list after 'entry' keyword"
    #             ))
    #         else:
    self.required_constructs['entry_point'] = True

    #     def _validate_function_declaration(self, node: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate a function declaration.

    #         Args:
    #             node: Function declaration AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if not node.children or len(node.children) < 2:
                result.add_issue(ValidationIssue(
    line = node.line,
    column = node.column,
    message = "Function declaration missing function name or parameters",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_function_declaration'],
    suggestion = "Add a function name and parameter list after 'func' keyword"
    #             ))

    #     def _validate_type_declaration(self, node: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate a type declaration.

    #         Args:
    #             node: Type declaration AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if not node.children or node.children[0].node_type != "Identifier":
                result.add_issue(ValidationIssue(
    line = node.line,
    column = node.column,
    message = "Type declaration missing type name",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['invalid_type_declaration'],
    suggestion = "Add a type name after 'type' keyword"
    #             ))

    #     def _validate_required_constructs(self, ast_root: ASTNode, result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate that required language constructs are present.

    #         Args:
    #             ast_root: Root AST node
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         if strict_mode:
    #             for construct, present in self.required_constructs.items():
    #                 if not present:
    #                     if construct == 'module_declaration':
                            result.add_issue(ValidationIssue(
    message = "Missing module declaration",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['missing_required_construct'],
    suggestion = "Add a module declaration at the beginning of the file: 'module your.module.name:'"
    #                         ))
    #                     elif construct == 'entry_point':
                            result.add_issue(ValidationIssue(
    message = "Missing entry point",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['missing_required_construct'],
    suggestion = "Add an entry point: 'entry main(args):'"
    #                         ))

    #     def _validate_structure_and_nesting(self, tokens: List[Token], result: ValidationResult, strict_mode: bool) -> None:
    #         """
    #         Validate proper syntax structure and nesting.

    #         Args:
    #             tokens: List of tokens to validate
    #             result: ValidationResult to add issues to
    #             strict_mode: Whether to use strict validation mode
    #         """
    #         # Check for balanced brackets, braces, and parentheses
    bracket_stack = []
    brace_stack = []
    paren_stack = []

    #         for token in tokens:
    #             if token.type == TokenType.LBRACKET:
                    bracket_stack.append((token.line, token.column))
    #             elif token.type == TokenType.RBRACKET:
    #                 if not bracket_stack:
                        result.add_issue(ValidationIssue(
    line = token.line,
    column = token.column,
    message = "Unmatched closing bracket ']'",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['mismatched_brackets']
    #                     ))
    #                 else:
                        bracket_stack.pop()

    #             elif token.type == TokenType.LBRACE:
                    brace_stack.append((token.line, token.column))
    #             elif token.type == TokenType.RBRACE:
    #                 if not brace_stack:
                        result.add_issue(ValidationIssue(
    line = token.line,
    column = token.column,
    message = "Unmatched closing brace '}'",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['mismatched_brackets']
    #                     ))
    #                 else:
                        brace_stack.pop()

    #             elif token.type == TokenType.LPAREN:
                    paren_stack.append((token.line, token.column))
    #             elif token.type == TokenType.RPAREN:
    #                 if not paren_stack:
                        result.add_issue(ValidationIssue(
    line = token.line,
    column = token.column,
    message = "Unmatched closing parenthesis ')'",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['mismatched_brackets']
    #                     ))
    #                 else:
                        paren_stack.pop()

    #         # Check for unclosed blocks
    #         for line, column in bracket_stack:
                result.add_issue(ValidationIssue(
    line = line,
    column = column,
    message = "Unclosed bracket '['",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['unclosed_block']
    #             ))

    #         for line, column in brace_stack:
                result.add_issue(ValidationIssue(
    line = line,
    column = column,
    message = "Unclosed brace '{'",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['unclosed_block']
    #             ))

    #         for line, column in paren_stack:
                result.add_issue(ValidationIssue(
    line = line,
    column = column,
    message = "Unclosed parenthesis '('",
    severity = ValidationSeverity.ERROR,
    code = self.error_codes['unclosed_block']
    #             ))

    #     def _is_valid_string_literal(self, value: str) -> bool:
    #         """
    #         Check if a string literal is valid.

    #         Args:
    #             value: String literal value

    #         Returns:
    #             True if the string literal is valid
    #         """
    #         if len(value) < 2:
    #             return False

    #         # Check if it starts and ends with the same quote type
    #         if (value[0] == '"' and value[-1] == '"') or (value[0] == "'" and value[-1] == "'"):
    #             return True

    #         return False

    #     def _is_valid_identifier(self, value: str) -> bool:
    #         """
    #         Check if an identifier is valid.

    #         Args:
    #             value: Identifier value

    #         Returns:
    #             True if the identifier is valid
    #         """
    #         import re
            return bool(re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', value))

    #     def _count_ast_nodes(self, node: ASTNode) -> int:
    #         """
    #         Count the number of nodes in an AST.

    #         Args:
    #             node: Root AST node

    #         Returns:
    #             Number of nodes in the AST
    #         """
    count = 1
    #         for child in node.children:
    count + = self._count_ast_nodes(child)
    #         return count

    #     async def get_syntax_info(self) -> Dict[str, Any]:
    #         """
    #         Get information about supported syntax.

    #         Returns:
    #             Dictionary containing syntax information
    #         """
    #         return {
    #             'language': 'NoodleCore',
    #             'version': '1.0',
                'supported_constructs': list(self.construct_patterns.keys()),
    #             'validator': self.name,
                'keywords': self.grammar.get_keywords(),
                'operators': self.grammar.get_operators(),
    #             'features': [
    #                 'module_declaration',
    #                 'import_statements',
    #                 'entry_points',
    #                 'function_definitions',
    #                 'type_definitions',
    #                 'match_case_statements',
    #                 'async_await_patterns'
    #             ],
    #             'error_codes': self.error_codes
    #         }