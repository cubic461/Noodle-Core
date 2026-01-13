# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# AST Interpreter for NoodleCore Runtime

This module provides an Abstract Syntax Tree (AST) interpreter that can execute
# validated Python AST directly without compilation to bytecode, offering an
# additional execution method for the NoodleCore runtime.
# """

import ast
import time
import logging
import hashlib
import typing.Any,
import dataclasses.dataclass

import .security_sandbox.SecuritySandbox,
import .errors.NoodleError


class ASTValidationError(NoodleError)
    #     """Raised when AST validation fails."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3201", details)


class ASTSecurityError(NoodleError)
    #     """Raised when AST contains security violations."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3202", details)


# @dataclass
class ASTInterpreterConfig
    #     """Configuration for the AST interpreter."""
    max_recursion_depth: int = 1000
    max_execution_time: float = 30.0
    max_memory_mb: int = 512
    enable_debugging: bool = False
    allow_loops: bool = True
    max_loop_iterations: int = 10000
    trusted_sources: Optional[List[str]] = None

    #     def __post_init__(self):
    #         if self.trusted_sources is None:
    self.trusted_sources = []


class ASTNodeVisitor(ast.NodeVisitor)
    #     """
    #     AST visitor for validation and security checks.
    #     """

    #     def __init__(self, config: ASTInterpreterConfig):
    self.config = config
    self.violations = []
    self.imports = []
    self.function_calls = []
    self.has_loops = False

    #     def visit_Import(self, node: ast.Import) -> None:
    #         """Visit import nodes."""
    #         for alias in node.names:
                self.imports.append(alias.name)
            self.generic_visit(node)

    #     def visit_ImportFrom(self, node: ast.ImportFrom) -> None:
    #         """Visit from-import nodes."""
    #         if node.module:
                self.imports.append(node.module)
            self.generic_visit(node)

    #     def visit_Call(self, node: ast.Call) -> None:
    #         """Visit function call nodes."""
    #         if isinstance(node.func, ast.Name):
                self.function_calls.append(node.func.id)
    #         elif isinstance(node.func, ast.Attribute):
                # Handle method calls like obj.method()
    #             if isinstance(node.func.value, ast.Name):
                    self.function_calls.append(f"{node.func.value.id}.{node.func.attr}")
            self.generic_visit(node)

    #     def visit_For(self, node: ast.For) -> None:
    #         """Visit for loop nodes."""
    self.has_loops = True
            self.generic_visit(node)

    #     def visit_While(self, node: ast.While) -> None:
    #         """Visit while loop nodes."""
    self.has_loops = True
            self.generic_visit(node)

    #     def visit_Exec(self, node: ast.Exec) -> None:
    #         """Visit exec nodes (Python 2 only, but check for safety)."""
            self.violations.append("Use of exec() function")
            self.generic_visit(node)

    #     def visit_Eval(self, node: ast.Eval) -> None:
    #         """Visit eval nodes."""
            self.violations.append("Use of eval() function")
            self.generic_visit(node)


class ASTInterpreter
    #     """
    #     AST interpreter for executing validated Python AST.

    #     This interpreter executes Python AST directly without compilation to bytecode,
    #     providing an additional execution method for the NoodleCore runtime.
    #     """

    #     def __init__(self, config: Optional[ASTInterpreterConfig] = None,
    sandbox: Optional[SecuritySandbox] = None):
    #         """
    #         Initialize the AST interpreter.

    #         Args:
    #             config: Interpreter configuration
    #             sandbox: Security sandbox for execution
    #         """
    self.config = config or ASTInterpreterConfig()
    self.sandbox = sandbox or SecuritySandbox()
    self.logger = logging.getLogger(__name__)
    self._execution_context = {}
    self._start_time = 0.0
    self._loop_iterations = 0

    #     def parse_code(self, code: str, filename: str = "<string>") -> ast.AST:
    #         """
    #         Parse code into an AST.

    #         Args:
    #             code: Source code to parse
    #             filename: Optional filename for error reporting

    #         Returns:
    #             Parsed AST

    #         Raises:
    #             ASTValidationError: If parsing fails
    #         """
    #         try:
    return ast.parse(code, filename = filename)
    #         except SyntaxError as e:
                raise ASTValidationError(f"Syntax error: {str(e)}", {
    #                 "line": e.lineno,
    #                 "offset": e.offset,
    #                 "filename": filename
    #             })

    #     def validate_ast(self, tree: ast.AST, source: Optional[str] = None) -> None:
    #         """
    #         Validate an AST for security and compliance.

    #         Args:
    #             tree: AST to validate
    #             source: Optional source identifier

    #         Raises:
    #             ASTValidationError: If validation fails
    #             ASTSecurityError: If security violations are found
    #         """
    #         # Check if source is trusted
    #         if source and source in self.config.trusted_sources:
    #             return

    #         # Visit AST to collect information
    visitor = ASTNodeVisitor(self.config)
            visitor.visit(tree)

    #         # Check for security violations
    #         if visitor.violations:
                raise ASTSecurityError(
                    f"Security violations found: {', '.join(visitor.violations)}",
    #                 {"violations": visitor.violations}
    #             )

    #         # Check for dangerous imports
    restricted_imports = {
    #             "os", "sys", "subprocess", "socket", "urllib", "http", "ftplib",
    #             "smtplib", "telnetlib", "pickle", "shelve", "dbm", "sqlite3",
    #             "ctypes", "threading", "multiprocessing", "asyncio", "inspect"
    #         }

    #         for imp in visitor.imports:
    #             if imp in restricted_imports:
                    raise ASTSecurityError(f"Restricted import found: {imp}",
    #                                      {"import": imp})

    #         # Check for dangerous function calls
    dangerous_calls = {"eval", "exec", "compile", "__import__"}
    #         for call in visitor.function_calls:
    #             if call in dangerous_calls:
                    raise ASTSecurityError(f"Dangerous function call found: {call}",
    #                                      {"call": call})

    #         # Check for loops if not allowed
    #         if not self.config.allow_loops and visitor.has_loops:
                raise ASTSecurityError("Loops are not allowed in this context")

    #     def execute_ast(self, tree: ast.AST, context: Optional[Dict[str, Any]] = None) -> Any:
    #         """
    #         Execute an AST.

    #         Args:
    #             tree: AST to execute
    #             context: Optional execution context

    #         Returns:
    #             Result of execution

    #         Raises:
    #             ASTValidationError: If validation fails
    #             ASTSecurityError: If security violations are found
    #         """
    #         # Reset execution state
    self._start_time = time.time()
    self._loop_iterations = 0

    #         # Set up execution context
    #         exec_context = context.copy() if context else {}
            exec_context.update(self._execution_context)

    #         # Execute the AST
    #         try:
    code_obj = compile(tree, filename="<ast>", mode="exec")
                exec(code_obj, exec_context)

    #             # Update our context with the new values
                self._execution_context.update(exec_context)

    #             # Return the result if there's a variable named 'result'
                return exec_context.get("result")

    #         except Exception as e:
                self.logger.error(f"Error executing AST: {str(e)}")
                raise ASTValidationError(f"Execution error: {str(e)}", {
                    "original_error": str(e),
                    "execution_time": time.time() - self._start_time
    #             })

    #     def execute_code(self, code: str, context: Optional[Dict[str, Any]] = None,
    source: Optional[str] = math.subtract(None), > Any:)
    #         """
    #         Parse, validate, and execute code.

    #         Args:
    #             code: Source code to execute
    #             context: Optional execution context
    #             source: Optional source identifier

    #         Returns:
    #             Result of execution
    #         """
    #         # Parse code into AST
    tree = self.parse_code(code)

    #         # Validate AST
            self.validate_ast(tree, source)

    #         # Execute AST
            return self.execute_ast(tree, context)

    #     def execute_in_sandbox(self, code: str, context: Optional[Dict[str, Any]] = None) -> Any:
    #         """
    #         Execute code in the security sandbox.

    #         Args:
    #             code: Source code to execute
    #             context: Optional execution context

    #         Returns:
    #             Result of execution
    #         """
    #         # Prepare context for sandbox
    #         sandbox_context = context.copy() if context else {}

    #         # Execute in sandbox
    return self.sandbox.execute_code(code, context = sandbox_context)

    #     def _execute_node(self, node: ast.AST, context: Dict[str, Any]) -> Any:
    #         """
    #         Execute a single AST node.

    #         Args:
    #             node: AST node to execute
    #             context: Execution context

    #         Returns:
    #             Result of node execution
    #         """
    #         # Check execution time
    #         if time.time() - self._start_time > self.config.max_execution_time:
                raise ASTValidationError("Execution timeout exceeded")

    #         # Dispatch based on node type
    method_name = f"_execute_{node.__class__.__name__}"
    method = getattr(self, method_name, self._execute_default)
            return method(node, context)

    #     def _execute_default(self, node: ast.AST, context: Dict[str, Any]) -> Any:
    #         """
    #         Default handler for unimplemented node types.

    #         Args:
    #             node: AST node
    #             context: Execution context

    #         Returns:
    #             None
    #         """
            raise ASTValidationError(f"Unsupported AST node type: {node.__class__.__name__}")

    #     def _execute_Constant(self, node: ast.Constant, context: Dict[str, Any]) -> Any:
    #         """Execute a constant node."""
    #         return node.value

    #     def _execute_Name(self, node: ast.Name, context: Dict[str, Any]) -> Any:
    #         """Execute a name node."""
            return context.get(node.id, None)

    #     def _execute_BinOp(self, node: ast.BinOp, context: Dict[str, Any]) -> Any:
    #         """Execute a binary operation node."""
    left = self._execute_node(node.left, context)
    right = self._execute_node(node.right, context)

    #         if isinstance(node.op, ast.Add):
    #             return left + right
    #         elif isinstance(node.op, ast.Sub):
    #             return left - right
    #         elif isinstance(node.op, ast.Mult):
    #             return left * right
    #         elif isinstance(node.op, ast.Div):
    #             return left / right
    #         elif isinstance(node.op, ast.Mod):
    #             return left % right
    #         elif isinstance(node.op, ast.Pow):
    #             return left ** right
    #         else:
                raise ASTValidationError(f"Unsupported binary operator: {node.op.__class__.__name__}")

    #     def _execute_UnaryOp(self, node: ast.UnaryOp, context: Dict[str, Any]) -> Any:
    #         """Execute a unary operation node."""
    operand = self._execute_node(node.operand, context)

    #         if isinstance(node.op, ast.UAdd):
    #             return +operand
    #         elif isinstance(node.op, ast.USub):
    #             return -operand
    #         elif isinstance(node.op, ast.Not):
    #             return not operand
    #         else:
                raise ASTValidationError(f"Unsupported unary operator: {node.op.__class__.__name__}")

    #     def _execute_Compare(self, node: ast.Compare, context: Dict[str, Any]) -> Any:
    #         """Execute a comparison node."""
    left = self._execute_node(node.left, context)
    result = True

    #         for i, op in enumerate(node.ops):
    right = self._execute_node(node.comparators[i], context)

    #             if isinstance(op, ast.Eq):
    current = left == right
    #             elif isinstance(op, ast.NotEq):
    current = left != right
    #             elif isinstance(op, ast.Lt):
    current = left < right
    #             elif isinstance(op, ast.LtE):
    current = left <= right
    #             elif isinstance(op, ast.Gt):
    current = left > right
    #             elif isinstance(op, ast.GtE):
    current = left >= right
    #             else:
                    raise ASTValidationError(f"Unsupported comparison operator: {op.__class__.__name__}")

    result = result and current
    left = right

    #         return result

    #     def _execute_If(self, node: ast.If, context: Dict[str, Any]) -> Any:
    #         """Execute an if statement."""
    test = self._execute_node(node.test, context)

    #         if test:
    #             for stmt in node.body:
                    self._execute_node(stmt, context)
    #         elif node.orelse:
    #             for stmt in node.orelse:
                    self._execute_node(stmt, context)

    #     def _execute_Assign(self, node: ast.Assign, context: Dict[str, Any]) -> Any:
    #         """Execute an assignment node."""
    value = self._execute_node(node.value, context)

    #         for target in node.targets:
    #             if isinstance(target, ast.Name):
    context[target.id] = value
    #             else:
                    raise ASTValidationError(f"Unsupported assignment target: {target.__class__.__name__}")

    #         return value

    #     def _execute_Expr(self, node: ast.Expr, context: Dict[str, Any]) -> Any:
    #         """Execute an expression statement."""
            return self._execute_node(node.value, context)

    #     def reset_context(self) -> None:
    #         """Reset the execution context."""
    self._execution_context = {}

    #     def get_context(self) -> Dict[str, Any]:
    #         """
    #         Get the current execution context.

    #         Returns:
    #             Current execution context
    #         """
            return self._execution_context.copy()