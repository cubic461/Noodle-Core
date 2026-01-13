# Converted from Python to NoodleCore
# Original file: src

# """
# Syntax Checker for NoodleCore Linter
# ------------------------------------
# This module provides syntax checking functionality for NoodleCore code,
# validating the structure according to the official NoodleCore grammar.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import re
from dataclasses import dataclass
import typing.Any

import ..compiler.parser_ast_nodes.(
#     ASTNode, ProgramNode, StatementNode, ExpressionNode,
#     NodeType, get_node_position
# )
import ..compiler.lexer.Position
import .linter.LinterError


dataclass
class SyntaxPattern
    #     """Represents a syntax pattern to check against"""

    #     name: str
    #     pattern: str
    #     description: str
    severity: str = "error"
    suggestion: Optional[str] = None
    examples: List[str] = field(default_factory=list)


class SyntaxChecker
    #     """
    #     Syntax checker for NoodleCore code

    #     This class validates the syntax structure of NoodleCore code according to
    #     the official grammar rules.
    #     """

    #     def __init__(self):""Initialize the syntax checker"""
    self.patterns = self._initialize_patterns()
    self.forbidden_patterns = self._initialize_forbidden_patterns()

    #     def _initialize_patterns(self) -List[SyntaxPattern]):
    #         """Initialize syntax patterns to check"""
    patterns = [
    #             # Statement structure patterns
                SyntaxPattern(
    name = "invalid_statement_termination",
    pattern = r"[^;]\s*$",
    #                 description="Statement should end with semicolon",
    severity = "error",
    suggestion = "Add semicolon at the end of the statement",
    examples = ["x = 5", "print('hello')"]
    #             ),

    #             # Function definition patterns
                SyntaxPattern(
    name = "invalid_function_definition",
    pattern = r"func\s+\w+\s*\([^)]*\)\s*{",
    description = "Function definition should use NoodleCore syntax",
    severity = "error",
    suggestion = "Use proper NoodleCore function syntax",
    examples = ["func myFunction() {"]
    #             ),

    #             # Variable declaration patterns
                SyntaxPattern(
    name = "invalid_variable_declaration",
    pattern = r"(var|let|const)\s+\w+\s*=",
    description = "Variable declaration should use NoodleCore syntax",
    severity = "error",
    suggestion = "Use proper NoodleCore variable syntax",
    examples = ["var x = 5", "let y = 10"]
    #             ),

    #             # Import statement patterns
                SyntaxPattern(
    name = "invalid_import_statement",
    pattern = r"import\s+.*\s+from\s+",
    description = "Import statement should use NoodleCore syntax",
    severity = "error",
    suggestion = "Use proper NoodleCore import syntax",
    examples = ["import something from 'module'"]
    #             ),

    #             # Conditional statement patterns
                SyntaxPattern(
    name = "invalid_conditional",
    pattern = r"if\s*\([^)]*\)\s*{",
    description = "Conditional statement should use NoodleCore syntax",
    severity = "error",
    suggestion = "Use proper NoodleCore conditional syntax",
    #                 examples=["if (x 0) {"]
    #             ),

    #             # Loop statement patterns
                SyntaxPattern(
    name = "invalid_loop",
    pattern = r"(for|while)\s*\([^)]*\)\s*{",
    description = "Loop statement should use NoodleCore syntax",
    severity = "error",
    suggestion = "Use proper NoodleCore loop syntax",
    #                 examples=["for (i = 0; i < 10; i++) {"]
    #             ),
    #         ]

    #         return patterns

    #     def _initialize_forbidden_patterns(self):
    """List[SyntaxPattern])"""
    #         """Initialize forbidden syntax patterns"""
    patterns = [
    #             # Python-like patterns
                SyntaxPattern(
    name = "python_syntax",
    pattern = r"def\s+\w+\s*\([^)]*\)\s*:",
    description = "Python-style function definition is not allowed",
    severity = "error",
    suggestion = "Use NoodleCore function syntax",
    #                 examples=["def my_function():"]
    #             ),

                SyntaxPattern(
    name = "python_indentation",
    pattern = r"^\s+\w+.*:\s*$",
    description = "Python-style indentation is not allowed",
    severity = "error",
    suggestion = "Use NoodleCore block syntax",
    examples = ["    print('hello'):"]
    #             ),

                SyntaxPattern(
    name = "python_list_comprehension",
    pattern = r"\[.*\s+for\s+.*\s+in\s+.*\]",
    description = "Python-style list comprehension is not allowed",
    severity = "error",
    suggestion = "Use NoodleCore list construction",
    #                 examples=["[x for x in range(10)]"]
    #             ),

    #             # JavaScript-like patterns
                SyntaxPattern(
    name = "javascript_function",
    pattern = r"function\s+\w+\s*\([^)]*\)\s*{",
    description = "JavaScript-style function definition is not allowed",
    severity = "error",
    suggestion = "Use NoodleCore function syntax",
    examples = ["function myFunction() {"]
    #             ),

                SyntaxPattern(
    name = "javascript_arrow_function",
    pattern = r"\([^)]*\)\s*=>\s*{",
    description = "JavaScript-style arrow function is not allowed",
    severity = "error",
    suggestion = "Use NoodleCore function syntax",
    examples = ["(x) ={ return x * 2; }"]
    #             ),

                SyntaxPattern(
    name = "javascript_var",
    pattern = r"\b(var|let|const)\s+\w+\s*=",
    description = "JavaScript-style variable declaration is not allowed",
    severity = "error",
    suggestion = "Use NoodleCore variable syntax",
    examples = ["var x = 5", "let y = 10", "const z = 15"]
    #             ),
    #         ]

    #         return patterns

    #     def check(self, ast): ProgramNode, file_path: Optional[str] = None) -LinterResult):
    #         """
    #         Check the syntax of a parsed AST

    #         Args:
    #             ast: The AST to check
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             LinterResult: Result of the syntax check
    #         """
    result = LinterResult(success=True)

    #         # Check the AST structure
            self._check_ast_structure(ast, result, file_path)

    #         # Check each statement
    #         for statement in ast.children:
                self._check_statement(statement, result, file_path)

    #         return result

    #     def _check_ast_structure(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check the overall AST structure"""
    #         if not isinstance(node, ProgramNode):
                result.errors.append(LinterError(
    code = "E104",
    message = "Root node must be a ProgramNode",
    severity = "error",
    category = "syntax",
    file = file_path,
    #             ))

    #         # Check if program has statements
    #         if len(node.children) == 0:
                result.warnings.append(LinterError(
    code = "W106",
    message = "Empty program detected",
    severity = "warning",
    category = "syntax",
    file = file_path,
    #             ))

    #     def _check_statement(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check a statement node"""
    position = get_node_position(node)

    #         # Check based on node type
    #         if node.node_type == NodeType.FUNCTION_DEF:
                self._check_function_definition(node, result, file_path)
    #         elif node.node_type == NodeType.ASSIGNMENT:
                self._check_assignment(node, result, file_path)
    #         elif node.node_type == NodeType.IF:
                self._check_conditional(node, result, file_path)
    #         elif node.node_type == NodeType.WHILE or node.node_type == NodeType.FOR:
                self._check_loop(node, result, file_path)
    #         elif node.node_type == NodeType.IMPORT:
                self._check_import(node, result, file_path)

    #         # Recursively check child nodes
    #         for child in node.get_children():
                self._check_statement(child, result, file_path)

    #     def _check_function_definition(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check a function definition"""
    position = get_node_position(node)

    #         # Check if function has a name
    #         if not hasattr(node, 'name') or not node.name:
                result.errors.append(LinterError(
    code = "E104",
    message = "Function must have a name",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a name to the function",
    #             ))

    #         # Check if function has a body
    #         if not hasattr(node, 'body') or not node.body:
                result.errors.append(LinterError(
    code = "E104",
    message = "Function must have a body",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a body to the function",
    #             ))

    #     def _check_assignment(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check an assignment statement"""
    position = get_node_position(node)

    #         # Check if assignment has a target
    #         if not hasattr(node, 'target') or not node.target:
                result.errors.append(LinterError(
    code = "E104",
    message = "Assignment must have a target",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a target to the assignment",
    #             ))

    #         # Check if assignment has a value
    #         if not hasattr(node, 'value') or not node.value:
                result.errors.append(LinterError(
    code = "E104",
    message = "Assignment must have a value",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a value to the assignment",
    #             ))

    #     def _check_conditional(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check a conditional statement"""
    position = get_node_position(node)

    #         # Check if conditional has a condition
    #         if not hasattr(node, 'condition') or not node.condition:
                result.errors.append(LinterError(
    code = "E104",
    message = "Conditional must have a condition",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a condition to the conditional",
    #             ))

    #         # Check if conditional has a body
    #         if not hasattr(node, 'then_body') or not node.then_body:
                result.errors.append(LinterError(
    code = "E104",
    message = "Conditional must have a body",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a body to the conditional",
    #             ))

    #     def _check_loop(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check a loop statement"""
    position = get_node_position(node)

    #         if node.node_type == NodeType.WHILE:
    #             # Check while loop condition
    #             if not hasattr(node, 'condition') or not node.condition:
                    result.errors.append(LinterError(
    code = "E104",
    message = "While loop must have a condition",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    #                     suggestion="Add a condition to the while loop",
    #                 ))
    #         elif node.node_type == NodeType.FOR:
    #             # Check for loop components
    #             if not hasattr(node, 'variable') or not node.variable:
                    result.errors.append(LinterError(
    code = "E104",
    message = "For loop must have a variable",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    #                     suggestion="Add a variable to the for loop",
    #                 ))

    #             if not hasattr(node, 'iterable') or not node.iterable:
                    result.errors.append(LinterError(
    code = "E104",
    message = "For loop must have an iterable",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    #                     suggestion="Add an iterable to the for loop",
    #                 ))

    #         # Check if loop has a body
    #         if not hasattr(node, 'body') or not node.body:
                result.errors.append(LinterError(
    code = "E104",
    message = "Loop must have a body",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a body to the loop",
    #             ))

    #     def _check_import(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check an import statement"""
    position = get_node_position(node)

    #         # Check if import has a module
    #         if not hasattr(node, 'module') or not node.module:
                result.errors.append(LinterError(
    code = "E104",
    message = "Import must specify a module",
    severity = "error",
    category = "syntax",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Add a module name to the import",
    #             ))

    #     def check_source_code(self, source_code: str, file_path: Optional[str] = None) -LinterResult):
    #         """
    #         Check source code for syntax patterns

    #         Args:
    #             source_code: The source code to check
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             LinterResult: Result of the syntax check
    #         """
    result = LinterResult(success=True)

    lines = source_code.split('\n')

    #         for line_num, line in enumerate(lines, 1):
    #             # Check for forbidden patterns
    #             for pattern in self.forbidden_patterns:
    #                 if re.search(pattern.pattern, line):
                        result.errors.append(LinterError(
    code = "E104",
    message = pattern.description,
    severity = pattern.severity,
    category = "syntax",
    file = file_path,
    line = line_num,
    suggestion = pattern.suggestion,
    #                     ))

    #             # Check for invalid patterns
    #             for pattern in self.patterns:
    #                 if re.search(pattern.pattern, line):
                        result.errors.append(LinterError(
    code = "E104",
    message = pattern.description,
    severity = pattern.severity,
    category = "syntax",
    file = file_path,
    line = line_num,
    suggestion = pattern.suggestion,
    #                     ))

    #         return result