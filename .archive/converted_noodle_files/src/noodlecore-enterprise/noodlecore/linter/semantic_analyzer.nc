# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Semantic Analyzer for NoodleCore Linter
# ----------------------------------------
# This module provides semantic analysis functionality for NoodleCore code,
# checking for type consistency, variable scope validation, import validation,
# and function signature checking.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import ..compiler.parser_ast_nodes.(
#     ASTNode, ProgramNode, StatementNode, ExpressionNode,
#     NodeType, get_node_position, find_variable_declarations,
#     find_function_definitions
# )
import ..compiler.lexer.Position
import ..compiler.semantic_analyzer_symbol_table.SymbolTable
import ..compiler.types.Type,
import .linter.LinterError,


class VariableScope(Enum)
    #     """Variable scope levels"""
    GLOBAL = "global"
    FUNCTION = "function"
    BLOCK = "block"


# @dataclass
class SymbolInfo
    #     """Information about a symbol in the symbol table"""

    #     name: str
    #     type: Type
    #     scope: VariableScope
    position: Optional[Position] = None
    is_defined: bool = True
    is_used: bool = False
    is_function: bool = False
    function_params: List[str] = field(default_factory=list)
    function_return_type: Optional[Type] = None


class SemanticAnalyzer
    #     """
    #     Semantic analyzer for NoodleCore code

    #     This class performs semantic analysis including type checking, scope validation,
    #     import validation, and function signature checking.
    #     """

    #     def __init__(self):
    #         """Initialize the semantic analyzer"""
    self.symbol_table = SymbolTable()
    self.current_scope = VariableScope.GLOBAL
    self.current_function = None
    self.type_system = self._initialize_type_system()

    #     def _initialize_type_system(self) -> Dict[str, Type]:
    #         """Initialize the type system with basic types"""
    #         return {
                "int": BasicType("int"),
                "float": BasicType("float"),
                "string": BasicType("string"),
                "bool": BasicType("bool"),
                "void": BasicType("void"),
                "list": BasicType("list"),
                "matrix": BasicType("matrix"),
                "tensor": BasicType("tensor"),
    #         }

    #     def analyze(self, ast: ProgramNode, file_path: Optional[str] = None) -> LinterResult:
    #         """
    #         Perform semantic analysis on a parsed AST

    #         Args:
    #             ast: The AST to analyze
    #             file_path: Optional file path for error reporting

    #         Returns:
    #             LinterResult: Result of the semantic analysis
    #         """
    result = LinterResult(success=True)

    #         # First pass: collect all symbol declarations
            self._collect_declarations(ast, result, file_path)

    #         # Second pass: validate all symbol usages
            self._validate_usages(ast, result, file_path)

    #         # Third pass: type checking
            self._check_types(ast, result, file_path)

    #         # Fourth pass: validate imports
            self._validate_imports(ast, result, file_path)

    #         return result

    #     def _collect_declarations(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Collect all symbol declarations"""
    #         if node.node_type == NodeType.FUNCTION_DEF:
                self._collect_function_declaration(node, result, file_path)
    #         elif node.node_type == NodeType.ASSIGNMENT:
                self._collect_variable_declaration(node, result, file_path)

    #         # Recursively process child nodes
    #         for child in node.get_children():
                self._collect_declarations(child, result, file_path)

    #     def _collect_function_declaration(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Collect a function declaration"""
    position = get_node_position(node)

    #         if not hasattr(node, 'name') or not node.name:
                result.errors.append(LinterError(
    code = "E104",
    message = "Function must have a name",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    #             ))
    #             return

    #         # Check for duplicate function declaration
    #         if self.symbol_table.lookup(node.name):
                result.errors.append(LinterError(
    code = "E201",
    message = f"Redeclaration of function '{node.name}'",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    #             ))
    #             return

    #         # Create function type
    param_types = []
    #         if hasattr(node, 'parameters') and node.parameters:
    #             for param in node.parameters:
    param_type = self._get_type_from_node(param) or BasicType("any")
                    param_types.append(param_type)

    return_type = None
    #         if hasattr(node, 'return_type') and node.return_type:
    return_type = node.return_type
    #         else:
    return_type = BasicType("void")

    function_type = FunctionType(param_types, return_type)

    #         # Add to symbol table
    symbol_info = SymbolInfo(
    name = node.name,
    type = function_type,
    scope = VariableScope.GLOBAL,
    position = position,
    is_function = True,
    #             function_params=[p.name for p in node.parameters] if hasattr(node, 'parameters') else [],
    function_return_type = return_type,
    #         )

            self.symbol_table.insert(node.name, symbol_info)

    #     def _collect_variable_declaration(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Collect a variable declaration"""
    position = get_node_position(node)

    #         if not hasattr(node, 'target') or not node.target:
    #             return

    #         # Get variable name
    var_name = None
    #         if hasattr(node.target, 'name'):
    var_name = node.target.name
    #         elif hasattr(node.target, 'node_type') and node.target.node_type == NodeType.VARIABLE:
    var_name = node.target.name

    #         if not var_name:
    #             return

    #         # Check for duplicate variable declaration in current scope
    existing_symbol = self.symbol_table.lookup_in_current_scope(var_name)
    #         if existing_symbol:
                result.errors.append(LinterError(
    code = "E201",
    message = f"Redeclaration of variable '{var_name}'",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    #             ))
    #             return

    #         # Infer variable type
    var_type = BasicType("any")
    #         if hasattr(node, 'value') and node.value:
    var_type = self._infer_type(node.value) or BasicType("any")

    #         # Add to symbol table
    symbol_info = SymbolInfo(
    name = var_name,
    type = var_type,
    scope = self.current_scope,
    position = position,
    #         )

            self.symbol_table.insert(var_name, symbol_info)

    #     def _validate_usages(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Validate all symbol usages"""
    #         if node.node_type == NodeType.VARIABLE:
                self._validate_variable_usage(node, result, file_path)
    #         elif node.node_type == NodeType.CALL:
                self._validate_function_call(node, result, file_path)

    #         # Recursively process child nodes
    #         for child in node.get_children():
                self._validate_usages(child, result, file_path)

    #     def _validate_variable_usage(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Validate a variable usage"""
    position = get_node_position(node)

    #         if not hasattr(node, 'name') or not node.name:
    #             return

    #         # Check if variable is declared
    symbol = self.symbol_table.lookup(node.name)
    #         if not symbol:
                result.errors.append(LinterError(
    code = "E202",
    message = f"Undeclared variable '{node.name}'",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Declare variable '{node.name}' before using it",
    #             ))
    #             return

    #         # Mark variable as used
    #         if hasattr(symbol, 'is_used'):
    symbol.is_used = True

    #         # Check if variable is initialized
    #         if hasattr(symbol, 'is_defined') and not symbol.is_defined:
                result.errors.append(LinterError(
    code = "E203",
    message = f"Variable '{node.name}' used before initialization",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Initialize variable '{node.name}' before using it",
    #             ))

    #     def _validate_function_call(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Validate a function call"""
    position = get_node_position(node)

    #         if not hasattr(node, 'function') or not node.function:
    #             return

    #         # Get function name
    func_name = None
    #         if hasattr(node.function, 'name'):
    func_name = node.function.name
    #         elif hasattr(node.function, 'node_type') and node.function.node_type == NodeType.VARIABLE:
    func_name = node.function.name

    #         if not func_name:
    #             return

    #         # Check if function is declared
    symbol = self.symbol_table.lookup(func_name)
    #         if not symbol or not hasattr(symbol, 'is_function') or not symbol.is_function:
                result.errors.append(LinterError(
    code = "E204",
    message = f"Function '{func_name}' not found",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Define function '{func_name}' before calling it",
    #             ))
    #             return

    #         # Check argument count
    #         expected_args = len(symbol.function_params) if hasattr(symbol, 'function_params') else 0
    #         actual_args = len(node.arguments) if hasattr(node, 'arguments') else 0

    #         if actual_args > expected_args:
                result.errors.append(LinterError(
    code = "E205",
    message = f"Too many arguments to function '{func_name}'",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Remove {actual_args - expected_args} argument(s)",
    #             ))
    #         elif actual_args < expected_args:
                result.errors.append(LinterError(
    code = "E206",
    message = f"Too few arguments to function '{func_name}'",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Add {expected_args - actual_args} argument(s)",
    #             ))

    #     def _check_types(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check type consistency"""
    #         if node.node_type == NodeType.ASSIGNMENT:
                self._check_assignment_type(node, result, file_path)
    #         elif node.node_type == NodeType.BINARY:
                self._check_binary_operation_type(node, result, file_path)
    #         elif node.node_type == NodeType.RETURN:
                self._check_return_type(node, result, file_path)

    #         # Recursively process child nodes
    #         for child in node.get_children():
                self._check_types(child, result, file_path)

    #     def _check_assignment_type(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check assignment type consistency"""
    position = get_node_position(node)

    #         if not hasattr(node, 'target') or not hasattr(node, 'value'):
    #             return

    #         # Get target type
    target_type = None
    #         if hasattr(node.target, 'name'):
    symbol = self.symbol_table.lookup(node.target.name)
    #             if symbol:
    target_type = symbol.type

    #         # Get value type
    value_type = self._infer_type(node.value)

    #         if target_type and value_type and not self._is_type_compatible(target_type, value_type):
                result.errors.append(LinterError(
    code = "E301",
    message = f"Type mismatch: expected '{target_type}', got '{value_type}'",
    severity = "error",
    category = "type",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Convert value to type '{target_type}' or change target type",
    #             ))

    #     def _check_binary_operation_type(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check binary operation type consistency"""
    position = get_node_position(node)

    #         if not hasattr(node, 'left') or not hasattr(node, 'right') or not hasattr(node, 'operator'):
    #             return

    #         # Get operand types
    left_type = self._infer_type(node.left)
    right_type = self._infer_type(node.right)

    #         if left_type and right_type:
    #             # Check if operation is supported for these types
    #             if not self._is_operation_supported(node.operator, left_type, right_type):
                    result.errors.append(LinterError(
    code = "E303",
    #                     message=f"Operation '{node.operator}' not supported for types '{left_type}' and '{right_type}'",
    severity = "error",
    category = "type",
    file = file_path,
    #                     line=position.line if position else None,
    #                     column=position.column if position else None,
    suggestion = "Use compatible types or a different operation",
    #                 ))

    #     def _check_return_type(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Check return type consistency"""
    position = get_node_position(node)

    #         if not self.current_function:
                result.errors.append(LinterError(
    code = "E207",
    message = "Return statement outside function",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = "Move return statement inside a function",
    #             ))
    #             return

    #         # Get function return type
    func_symbol = self.symbol_table.lookup(self.current_function)
    #         if not func_symbol or not hasattr(func_symbol, 'function_return_type'):
    #             return

    expected_type = func_symbol.function_return_type

    #         # Get actual return type
    actual_type = None
    #         if hasattr(node, 'value') and node.value:
    actual_type = self._infer_type(node.value)
    #         else:
    actual_type = BasicType("void")

    #         if expected_type and actual_type and not self._is_type_compatible(expected_type, actual_type):
                result.errors.append(LinterError(
    code = "E301",
    message = f"Type mismatch: expected return type '{expected_type}', got '{actual_type}'",
    severity = "error",
    category = "type",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    suggestion = f"Convert return value to type '{expected_type}' or change function return type",
    #             ))

    #     def _validate_imports(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Validate import statements"""
    #         if node.node_type == NodeType.IMPORT:
                self._validate_import_statement(node, result, file_path)

    #         # Recursively process child nodes
    #         for child in node.get_children():
                self._validate_imports(child, result, file_path)

    #     def _validate_import_statement(self, node: ASTNode, result: LinterResult, file_path: Optional[str]):
    #         """Validate an import statement"""
    position = get_node_position(node)

    #         if not hasattr(node, 'module') or not node.module:
                result.errors.append(LinterError(
    code = "E104",
    message = "Import must specify a module",
    severity = "error",
    category = "semantic",
    file = file_path,
    #                 line=position.line if position else None,
    #                 column=position.column if position else None,
    #             ))
    #             return

    #         # Check if module exists (placeholder for actual implementation)
    #         # In a real implementation, this would check the file system or module registry

    #         # Check if imported symbols are used
    #         if hasattr(node, 'aliases') and node.aliases:
    #             for alias in node.aliases:
    #                 # This would require tracking usage of imported symbols
    #                 pass

    #     def _infer_type(self, node: ASTNode) -> Optional[Type]:
    #         """Infer the type of an expression node"""
    #         if not node:
    #             return None

    #         if node.node_type == NodeType.LITERAL:
    #             if hasattr(node, 'literal_type'):
    #                 if node.literal_type.value == "NUMBER":
    #                     # Check if it's an integer or float
    #                     if hasattr(node, 'value') and isinstance(node.value, float):
                            return BasicType("float")
    #                     else:
                            return BasicType("int")
    #                 elif node.literal_type.value == "STRING":
                        return BasicType("string")
    #                 elif node.literal_type.value == "BOOLEAN":
                        return BasicType("bool")

    #         elif node.node_type == NodeType.VARIABLE:
    #             if hasattr(node, 'name'):
    symbol = self.symbol_table.lookup(node.name)
    #                 if symbol:
    #                     return symbol.type

    #         elif node.node_type == NodeType.BINARY:
    #             if hasattr(node, 'operator'):
    #                 if node.operator in ["+", "-", "*", "/"]:
    #                     # Arithmetic operations
    left_type = self._infer_type(node.left)
    right_type = self._infer_type(node.right)

    #                     if left_type and right_type:
    #                         # If either is float, result is float
    #                         if (left_type.name == "float" or right_type.name == "float"):
                                return BasicType("float")
    #                         # If both are int, result is int
    #                         elif (left_type.name == "int" and right_type.name == "int"):
                                return BasicType("int")

    #                 elif node.operator in ["==", "!=", "<", ">", "<=", ">="]:
    #                     # Comparison operations
                        return BasicType("bool")

    #                 elif node.operator in ["and", "or"]:
    #                     # Logical operations
                        return BasicType("bool")

    #         elif node.node_type == NodeType.CALL:
    #             if hasattr(node, 'function') and hasattr(node.function, 'name'):
    symbol = self.symbol_table.lookup(node.function.name)
    #                 if symbol and hasattr(symbol, 'function_return_type'):
    #                     return symbol.function_return_type

            return BasicType("any")

    #     def _get_type_from_node(self, node: ASTNode) -> Optional[Type]:
    #         """Get the type from a type annotation node"""
    #         # This would handle type annotations in the AST
    #         # For now, return None
    #         return None

    #     def _is_type_compatible(self, expected: Type, actual: Type) -> bool:
    #         """Check if a type is compatible with another"""
    #         if not expected or not actual:
    #             return True

    #         # If they're the same type
    #         if expected.name == actual.name:
    #             return True

    #         # If expected is 'any', anything is compatible
    #         if expected.name == "any":
    #             return True

    #         # If actual is 'any', it's compatible with anything
    #         if actual.name == "any":
    #             return True

    #         # Numeric type promotion
    #         if expected.name == "float" and actual.name == "int":
    #             return True

    #         return False

    #     def _is_operation_supported(self, operator: str, left_type: Type, right_type: Type) -> bool:
    #         """Check if an operation is supported for the given types"""
    #         # Arithmetic operations
    #         if operator in ["+", "-", "*", "/"]:
                return (left_type.name in ["int", "float"] and
    #                     right_type.name in ["int", "float"])

    #         # Comparison operations
    #         elif operator in ["==", "!=", "<", ">", "<=", ">="]:
                return (left_type.name in ["int", "float", "string"] and
    #                     right_type.name in ["int", "float", "string"])

    #         # Logical operations
    #         elif operator in ["and", "or"]:
    return left_type.name = = "bool" and right_type.name == "bool"

    #         return False

    #     def check_unused_symbols(self, result: LinterResult, file_path: Optional[str]):
    #         """Check for unused symbols"""
    #         # This would check for symbols that are declared but never used
    #         # Implementation would depend on the symbol table structure
    #         pass