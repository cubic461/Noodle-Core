# Converted from Python to NoodleCore
# Original file: noodle-core

# """
Mathematical Query Language (MQL) Parser
# -----------------------------------------
# Parses and executes mathematical queries in MQL format.
# """

import importlib
import json
import logging
import re
import threading
import collections.defaultdict
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import numpy as np


# Lazy loading for heavy dependencies
class LazyLoader
    #     """Lazy loader for heavy dependencies"""

    #     def __init__(self, module_name, import_name=None):
    self.module_name = module_name
    self.import_name = import_name
    self._module = None
    self._lock = threading.Lock()

    #     def __getattr__(self, name):
    #         if self._module is None:
    #             with self._lock:
    #                 if self._module is None:
    #                     try:
    module = importlib.import_module(self.module_name)
    #                         if self.import_name:
    self._module = getattr(module, self.import_name)
    #                         else:
    self._module = module
    #                     except ImportError as e:
                            raise ImportError(
    #                             f"Failed to lazy load {self.module_name}: {e}"
    #                         )
            return getattr(self._module, name)

    #     def __dir__(self):
    #         if self._module is None:
    #             with self._lock:
    #                 if self._module is None:
    #                     try:
    module = importlib.import_module(self.module_name)
    #                         if self.import_name:
    self._module = getattr(module, self.import_name)
    #                         else:
    self._module = module
    #                     except ImportError:
    #                         return []
            return dir(self._module)


# Lazy imports for database components
error_handler = LazyLoader("noodle.error_handler")
mathematical_objects = LazyLoader("noodle.runtime.mathematical_objects")
query_planner = LazyLoader("noodle.database.query_planner")
cost_based_optimizer = LazyLoader("noodle.database.cost_based_optimizer")
mathematical_cache = LazyLoader("noodle.database.mathematical_cache")
query_rewriter = LazyLoader("noodle.database.query_rewriter")

# Lazy imports for specific classes
MQLError = LazyLoader("noodle.error_handler", "MQLError")
ParseError = LazyLoader("noodle.error_handler", "ParseError")
SemanticError = LazyLoader("noodle.error_handler", "SemanticError")
MathematicalObject = LazyLoader(
#     "noodle.runtime.mathematical_objects", "MathematicalObject"
# )
ObjectType = LazyLoader("noodle.runtime.mathematical_objects", "ObjectType")
Matrix = LazyLoader("noodle.runtime.mathematical_objects", "Matrix")
Tensor = LazyLoader("noodle.runtime.mathematical_objects", "Tensor")
QueryPlanNode = LazyLoader("noodle.database.query_planner", "QueryPlanNode")
QueryPlanType = LazyLoader("noodle.database.query_planner", "QueryPlanType")
CostBasedOptimizer = LazyLoader(
#     "noodle.database.cost_based_optimizer", "CostBasedOptimizer"
# )
OptimizationContext = LazyLoader(
#     "noodle.database.cost_based_optimizer", "OptimizationContext"
# )
MathematicalCache = LazyLoader(
#     "noodle.database.mathematical_cache", "MathematicalCache"
# )
CacheConfig = LazyLoader("noodle.database.mathematical_cache", "CacheConfig")
QueryRewriter = LazyLoader("noodle.database.query_rewriter", "QueryRewriter")


class MQLTokenType(Enum)
    #     """Token types for MQL parser."""

    KEYWORD = "keyword"
    IDENTIFIER = "identifier"
    OPERATOR = "operator"
    LITERAL = "literal"
    SEPARATOR = "separator"
    FUNCTION = "function"
    MATRIX_OP = "matrix_op"
    TENSOR_OP = "tensor_op"
    CATEGORY_OP = "category_op"
    SYMBOLIC_OP = "symbolic_op"
    PAREN_OPEN = "paren_open"
    PAREN_CLOSE = "paren_close"
    BRACKET_OPEN = "bracket_open"
    BRACKET_CLOSE = "bracket_close"
    BRACE_OPEN = "brace_open"
    BRACE_CLOSE = "brace_close"
    COMMA = "comma"
    DOT = "dot"
    EOF = "eof"


# @dataclass
class MQLToken
    #     """Represents a token in MQL."""

    #     type: MQLTokenType
    #     value: str
    #     position: int
    #     line: int
    #     column: int


# @dataclass
class MQLASTNode
    #     """Base class for MQL AST nodes."""

    #     node_type: str
    children: List["MQLASTNode"] = field(default_factory=list)
    value: Any = None
    position: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class MQLQuery(MQLASTNode)
    #     """Represents a complete MQL query."""

    #     def __init__(self, **kwargs):
    super().__init__(node_type = "query", **kwargs)
    self.select_clause: Optional[MQLASTNode] = None
    self.from_clause: Optional[MQLASTNode] = None
    self.where_clause: Optional[MQLASTNode] = None
    self.group_by_clause: Optional[MQLASTNode] = None
    self.having_clause: Optional[MQLASTNode] = None
    self.order_by_clause: Optional[MQLASTNode] = None
    self.limit_clause: Optional[MQLASTNode] = None
    self.mathematical_operations: List[MQLASTNode] = []


# @dataclass
class MQLSelectClause(MQLASTNode)
    #     """Represents a SELECT clause in MQL."""

    #     def __init__(self, **kwargs):
    super().__init__(node_type = "select", **kwargs)
    self.columns: List[MQLASTNode] = []
    self.distinct: bool = False


# @dataclass
class MQLFromClause(MQLASTNode)
    #     """Represents a FROM clause in MQL."""

    #     def __init__(self, **kwargs):
    super().__init__(node_type = "from", **kwargs)
    self.sources: List[MQLASTNode] = []
    self.joins: List[MQLASTNode] = []


# @dataclass
class MQLWhereClause(MQLASTNode)
    #     """Represents a WHERE clause in MQL."""

    #     def __init__(self, **kwargs):
    super().__init__(node_type = "where", **kwargs)
    self.condition: Optional[MQLASTNode] = None


# @dataclass
class MQLMathematicalOperation(MQLASTNode)
    #     """Represents a mathematical operation in MQL."""

    #     def __init__(self, **kwargs):
    super().__init__(node_type = "math_operation", **kwargs)
    self.operation_type: str = ""
    self.operands: List[MQLASTNode] = []
    self.function_name: str = ""
    self.parameters: Dict[str, Any] = {}


class MQLLexer
    #     """Lexical analyzer for MQL."""

    KEYWORDS = {
    #         "SELECT",
    #         "FROM",
    #         "WHERE",
    #         "GROUP",
    #         "BY",
    #         "HAVING",
    #         "ORDER",
    #         "LIMIT",
    #         "DISTINCT",
    #         "MATRIX",
    #         "TENSOR",
    #         "CATEGORY",
    #         "SYMBOLIC",
    #         "EVALUATE",
    #         "COMPUTE",
    #         "TRANSFORM",
    #         "FILTER",
    #         "JOIN",
    #         "UNION",
    #         "INTERSECT",
    #     }

    FUNCTIONS = {
    #         "eigenvalues",
    #         "eigenvectors",
    #         "determinant",
    #         "inverse",
    #         "transpose",
    #         "contract",
    #         "decompose",
    #         "simplify",
    #         "expand",
    #         "factor",
    #         "solve",
    #         "integrate",
    #         "differentiate",
    #         "gradient",
    #         "jacobian",
    #         "hessian",
    #         "functor",
    #         "natural_transformation",
    #         "compose",
    #         "map",
    #         "reduce",
    #     }

    MATRIX_OPERATORS = {"multiply", "add", "subtract", "kronecker", "hadamard", "outer"}

    TENSOR_OPERATORS = {
    #         "contract",
    #         "decompose",
    #         "reshape",
    #         "transpose",
    #         "contract_dims",
    #     }

    CATEGORY_OPERATORS = {
    #         "functor_apply",
    #         "natural_transform",
    #         "compose",
    #         "map",
    #         "reduce",
    #     }

    SYMBOLIC_OPERATORS = {
    #         "simplify",
    #         "expand",
    #         "factor",
    #         "substitute",
    #         "evaluate",
    #         "differentiate",
    #     }

    #     def __init__(self, query: str):
    #         """Initialize the lexer.

    #         Args:
    #             query: The MQL query string to lex
    #         """
    self.query = query
    self.position = 0
    self.line = 1
    self.column = 1
    self.tokens = []

    #         # Predefined regex patterns
    self.token_patterns = [
                (MQLTokenType.PAREN_OPEN, r"\("),
                (MQLTokenType.PAREN_CLOSE, r"\)"),
                (MQLTokenType.BRACKET_OPEN, r"\["),
                (MQLTokenType.BRACKET_CLOSE, r"\]"),
                (MQLTokenType.BRACE_OPEN, r"\{"),
                (MQLTokenType.BRACE_CLOSE, r"\}"),
                (MQLTokenType.COMMA, r","),
                (MQLTokenType.DOT, r"\."),
    (MQLTokenType.OPERATOR, r"[+\-*/^% = <>!&|]+"),
                (MQLTokenType.LITERAL, r"\d+\.?\d*|\d+\.?\d*[eE][+-]?\d+"),
                (
    #                 MQLTokenType.FUNCTION,
    r"|".join(sorted(self.FUNCTIONS, key = len, reverse=True)),
    #             ),
                (
    #                 MQLTokenType.MATRIX_OP,
    r"|".join(sorted(self.MATRIX_OPERATORS, key = len, reverse=True)),
    #             ),
                (
    #                 MQLTokenType.TENSOR_OP,
    r"|".join(sorted(self.TENSOR_OPERATORS, key = len, reverse=True)),
    #             ),
                (
    #                 MQLTokenType.CATEGORY_OP,
    r"|".join(sorted(self.CATEGORY_OPERATORS, key = len, reverse=True)),
    #             ),
                (
    #                 MQLTokenType.SYMBOLIC_OP,
    r"|".join(sorted(self.SYMBOLIC_OPERATORS, key = len, reverse=True)),
    #             ),
                (
    #                 MQLTokenType.KEYWORD,
    r"|".join(sorted(self.KEYWORDS, key = len, reverse=True)),
    #             ),
                (MQLTokenType.IDENTIFIER, r"[a-zA-Z_]\w*"),
                (MQLTokenType.SEPARATOR, r"\s+"),
    #         ]

    #         # Compile regex
    self.token_regex = "|".join(
                f"(?P<{token_type.name}>{pattern})"
    #             for token_type, pattern in self.token_patterns
    #         )
    self.token_compiled = re.compile(self.token_regex)

    #     def tokenize(self) -> List[MQLToken]:
    #         """Tokenize the query string."""
    self.tokens = []
    self.position = 0
    self.line = 1
    self.column = 1

    #         while self.position < len(self.query):
    match = self.token_compiled.match(self.query, self.position)
    #             if not match:
                    raise ParseError(
    #                     f"Unexpected character at position {self.position}: {self.query[self.position]}"
    #                 )

    #             # Find which group matched
    token_type = None
    token_value = None

    #             for group_name, value in match.groupdict().items():
    #                 if value is not None:
    token_type = MQLTokenType[group_name]
    token_value = value
    #                     break

    #             # Skip whitespace
    #             if token_type != MQLTokenType.SEPARATOR:
    token = MQLToken(
    type = token_type,
    value = token_value,
    position = self.position,
    line = self.line,
    column = self.column,
    #                 )
                    self.tokens.append(token)

    #             # Update position
    self.position = match.end()
    self.column + = len(token_value)

    #             # Update line count
    #             if "\n" in token_value:
    self.line + = token_value.count("\n")
    self.column = 1

    #         # Add EOF token
            self.tokens.append(
                MQLToken(
    type = MQLTokenType.EOF,
    value = "",
    position = self.position,
    line = self.line,
    column = self.column,
    #             )
    #         )

    #         return self.tokens


class MQLParser
    #     """Parser for MQL queries."""

    #     def __init__(self, tokens: List[MQLToken]):
    #         """Initialize the parser.

    #         Args:
    #             tokens: List of tokens to parse
    #         """
    self.tokens = tokens
    self.current_token_index = 0
    #         self.current_token = tokens[0] if tokens else None
    self.logger = logging.getLogger(__name__)

    #     def parse(self) -> MQLQuery:
    #         """Parse the tokens into an AST."""
    query = MQLQuery()

    #         # Parse SELECT clause
    #         if self._match(MQLTokenType.KEYWORD, "SELECT"):
    query.select_clause = self._parse_select_clause()

    #         # Parse FROM clause
    #         if self._match(MQLTokenType.KEYWORD, "FROM"):
    query.from_clause = self._parse_from_clause()

    #         # Parse WHERE clause
    #         if self._match(MQLTokenType.KEYWORD, "WHERE"):
    query.where_clause = self._parse_where_clause()

    #         # Parse mathematical operations
    #         while self._peek() and self._peek().type in [
    #             MQLTokenType.FUNCTION,
    #             MQLTokenType.MATRIX_OP,
    #             MQLTokenType.TENSOR_OP,
    #             MQLTokenType.CATEGORY_OP,
    #             MQLTokenType.SYMBOLIC_OP,
    #         ]:
                query.mathematical_operations.append(self._parse_mathematical_operation())

    #         return query

    #     def _parse_select_clause(self) -> MQLSelectClause:
    #         """Parse a SELECT clause."""
    clause = MQLSelectClause()

    #         # Check for DISTINCT
    #         if self._match(MQLTokenType.KEYWORD, "DISTINCT"):
    clause.distinct = True

    #         # Parse columns
    #         while True:
    column = self._parse_column()
                clause.columns.append(column)

    #             if not self._match(MQLTokenType.COMMA):
    #                 break

    #         return clause

    #     def _parse_from_clause(self) -> MQLFromClause:
    #         """Parse a FROM clause."""
    clause = MQLFromClause()

    #         # Parse sources
    #         while True:
    source = self._parse_source()
                clause.sources.append(source)

    #             if not self._match(MQLTokenType.COMMA):
    #                 break

    #         return clause

    #     def _parse_where_clause(self) -> MQLWhereClause:
    #         """Parse a WHERE clause."""
    clause = MQLWhereClause()
    clause.condition = self._parse_expression()
    #         return clause

    #     def _parse_mathematical_operation(self) -> MQLMathematicalOperation:
    #         """Parse a mathematical operation."""
    operation = MQLMathematicalOperation()

    #         # Determine operation type
    #         if self.current_token.type == MQLTokenType.FUNCTION:
    operation.operation_type = "function"
    operation.function_name = self.current_token.value
                self._advance()

    #             # Parse parameters
    #             if self._match(MQLTokenType.PAREN_OPEN):
    #                 while not self._match(MQLTokenType.PAREN_CLOSE):
    param = self._parse_expression()
                        operation.operands.append(param)

    #                     if not self._match(MQLTokenType.COMMA):
    #                         break
    #         elif self.current_token.type == MQLTokenType.MATRIX_OP:
    operation.operation_type = "matrix"
    operation.function_name = self.current_token.value
                self._advance()

    #             # Parse operands
    #             if self._match(MQLTokenType.PAREN_OPEN):
    #                 while not self._match(MQLTokenType.PAREN_CLOSE):
    operand = self._parse_expression()
                        operation.operands.append(operand)

    #                     if not self._match(MQLTokenType.COMMA):
    #                         break
    #         elif self.current_token.type == MQLTokenType.TENSOR_OP:
    operation.operation_type = "tensor"
    operation.function_name = self.current_token.value
                self._advance()

    #             # Parse operands
    #             if self._match(MQLTokenType.PAREN_OPEN):
    #                 while not self._match(MQLTokenType.PAREN_CLOSE):
    operand = self._parse_expression()
                        operation.operands.append(operand)

    #                     if not self._match(MQLTokenType.COMMA):
    #                         break
    #         elif self.current_token.type == MQLTokenType.CATEGORY_OP:
    operation.operation_type = "category"
    operation.function_name = self.current_token.value
                self._advance()

    #             # Parse operands
    #             if self._match(MQLTokenType.PAREN_OPEN):
    #                 while not self._match(MQLTokenType.PAREN_CLOSE):
    operand = self._parse_expression()
                        operation.operands.append(operand)

    #                     if not self._match(MQLTokenType.COMMA):
    #                         break
    #         elif self.current_token.type == MQLTokenType.SYMBOLIC_OP:
    operation.operation_type = "symbolic"
    operation.function_name = self.current_token.value
                self._advance()

    #             # Parse operands
    #             if self._match(MQLTokenType.PAREN_OPEN):
    #                 while not self._match(MQLTokenType.PAREN_CLOSE):
    operand = self._parse_expression()
                        operation.operands.append(operand)

    #                     if not self._match(MQLTokenType.COMMA):
    #                         break

    #         return operation

    #     def _parse_column(self) -> MQLASTNode:
    #         """Parse a column expression."""
    node = MQLASTNode(node_type="column")

    #         if self.current_token.type == MQLTokenType.IDENTIFIER:
    node.value = self.current_token.value
                self._advance()
    #         else:
    node = self._parse_expression()

    #         return node

    #     def _parse_source(self) -> MQLASTNode:
    #         """Parse a data source."""
    node = MQLASTNode(node_type="source")

    #         if self.current_token.type == MQLTokenType.IDENTIFIER:
    node.value = self.current_token.value
                self._advance()
    #         else:
                raise ParseError(f"Expected identifier, got {self.current_token.type}")

    #         return node

    #     def _parse_expression(self) -> MQLASTNode:
    #         """Parse an expression."""
            return self._parse_logical_or()

    #     def _parse_logical_or(self) -> MQLASTNode:
    #         """Parse logical OR expression."""
    node = self._parse_logical_and()

    #         while self._match(MQLTokenType.OPERATOR, "||"):
    right = self._parse_logical_and()
    new_node = MQLASTNode(
    node_type = "binary_op", value="||", children=[node, right]
    #             )
    node = new_node

    #         return node

    #     def _parse_logical_and(self) -> MQLASTNode:
    #         """Parse logical AND expression."""
    node = self._parse_equality()

    #         while self._match(MQLTokenType.OPERATOR, "&&"):
    right = self._parse_equality()
    new_node = MQLASTNode(
    node_type = "binary_op", value="&&", children=[node, right]
    #             )
    node = new_node

    #         return node

    #     def _parse_equality(self) -> MQLASTNode:
    #         """Parse equality expression."""
    node = self._parse_relational()

    #         while self._match(MQLTokenType.OPERATOR, ("==", "!=")):
    op = self.current_token.value
                self._advance()
    right = self._parse_relational()
    new_node = MQLASTNode(
    node_type = "binary_op", value=op, children=[node, right]
    #             )
    node = new_node

    #         return node

    #     def _parse_relational(self) -> MQLASTNode:
    #         """Parse relational expression."""
    node = self._parse_additive()

    #         while self._match(MQLTokenType.OPERATOR, ("<", ">", "<=", ">=")):
    op = self.current_token.value
                self._advance()
    right = self._parse_additive()
    new_node = MQLASTNode(
    node_type = "binary_op", value=op, children=[node, right]
    #             )
    node = new_node

    #         return node

    #     def _parse_additive(self) -> MQLASTNode:
    #         """Parse additive expression."""
    node = self._parse_multiplicative()

    #         while self._match(MQLTokenType.OPERATOR, ("+", "-")):
    op = self.current_token.value
                self._advance()
    right = self._parse_multiplicative()
    new_node = MQLASTNode(
    node_type = "binary_op", value=op, children=[node, right]
    #             )
    node = new_node

    #         return node

    #     def _parse_multiplicative(self) -> MQLASTNode:
    #         """Parse multiplicative expression."""
    node = self._parse_unary()

    #         while self._match(MQLTokenType.OPERATOR, ("*", "/", "%")):
    op = self.current_token.value
                self._advance()
    right = self._parse_unary()
    new_node = MQLASTNode(
    node_type = "binary_op", value=op, children=[node, right]
    #             )
    node = new_node

    #         return node

    #     def _parse_unary(self) -> MQLASTNode:
    #         """Parse unary expression."""
    #         if self._match(MQLTokenType.OPERATOR, ("-", "!")):
    op = self.current_token.value
                self._advance()
    operand = self._parse_unary()
    return MQLASTNode(node_type = "unary_op", value=op, children=[operand])

            return self._parse_primary()

    #     def _parse_primary(self) -> MQLASTNode:
    #         """Parse primary expression."""
    #         if self._match(MQLTokenType.LITERAL):
    value = (
                    float(self.current_token.value)
    #                 if "." in self.current_token.value
                    else int(self.current_token.value)
    #             )
    node = MQLASTNode(node_type="literal", value=value)
                self._advance()
    #             return node

    #         elif self._match(MQLTokenType.IDENTIFIER):
    value = self.current_token.value
                self._advance()

    #             # Check for function call
    #             if self._match(MQLTokenType.PAREN_OPEN):
    args = []
    #                 while not self._match(MQLTokenType.PAREN_CLOSE):
    arg = self._parse_expression()
                        args.append(arg)

    #                     if not self._match(MQLTokenType.COMMA):
    #                         break

    return MQLASTNode(node_type = "function_call", value=value, children=args)
    #             else:
    return MQLASTNode(node_type = "identifier", value=value)

    #         elif self._match(MQLTokenType.PAREN_OPEN):
    expr = self._parse_expression()
                self._expect(MQLTokenType.PAREN_CLOSE)
    #             return expr

    #         else:
                raise ParseError(f"Unexpected token: {self.current_token}")

    #     def _execute_symbolic_operation(
    #         self, operation_name: str, data: List[Any], parameters: Dict[str, Any]
    #     ) -> Any:
    #         """Execute a symbolic operation."""
    #         # Check cache
    #         if len(data) == 1 and hasattr(data[0], "expression"):
    cache_key = f"symbolic:{operation_name}:{hash(str(data[0].expression))}"
    cached_result = self.pattern_cache.get_symbolic_pattern(
    #                 operation_name, data[0].expression
    #             )
    #             if cached_result is not None:
    #                 return cached_result

    #         # Execute operation
    #         if operation_name == "simplify":
    #             if len(data) == 1 and hasattr(data[0], "simplify"):
    result = data[0].simplify()
    #             else:
                    raise MQLError("Simplify operation requires a symbolic expression")
    #         elif operation_name == "expand":
    #             if len(data) == 1 and hasattr(data[0], "expand"):
    result = data[0].expand()
    #             else:
                    raise MQLError("Expand operation requires a symbolic expression")
    #         elif operation_name == "factor":
    #             if len(data) == 1 and hasattr(data[0], "factor"):
    result = data[0].factor()
    #             else:
                    raise MQLError("Factor operation requires a symbolic expression")
    #         else:
                raise MQLError(f"Unknown symbolic operation: {operation_name}")

    #         # Cache result
    #         if len(data) == 1 and hasattr(data[0], "expression"):
                self.pattern_cache.cache_symbolic_pattern(
    #                 operation_name, data[0].expression, result
    #             )

    #         return result

    #     def _evaluate_condition(self, condition: MQLASTNode, item: Dict[str, Any]) -> bool:
    #         """Evaluate a condition against an item."""
    #         if condition.node_type == "binary_op":
    left = self._evaluate_expression(condition.children[0], item)
    right = self._evaluate_expression(condition.children[1], item)

    #             if condition.value == "==":
    return left = = right
    #             elif condition.value == "!=":
    return left ! = right
    #             elif condition.value == "<":
    #                 return left < right
    #             elif condition.value == ">":
    #                 return left > right
    #             elif condition.value == "<=":
    return left < = right
    #             elif condition.value == ">=":
    return left > = right
    #             elif condition.value == "&&":
    #                 return left and right
    #             elif condition.value == "||":
    #                 return left or right
    #             else:
                    raise MQLError(f"Unknown binary operator: {condition.value}")

    #         elif condition.node_type == "unary_op":
    operand = self._evaluate_expression(condition.children[0], item)
    #             if condition.value == "!":
    #                 return not operand
    #             else:
                    raise MQLError(f"Unknown unary operator: {condition.value}")

    #         else:
                return bool(self._evaluate_expression(condition, item))

    #     def _evaluate_join_condition(
    #         self,
    #         condition: MQLASTNode,
    #         left_item: Dict[str, Any],
    #         right_item: Dict[str, Any],
    #     ) -> bool:
    #         """Evaluate a join condition between two items."""
    #         # For join conditions, we need to evaluate expressions that may reference both items
    #         # This is a simplified implementation
            return self._evaluate_condition(condition, {**left_item, **right_item})

    #     def _evaluate_expression(self, expr: MQLASTNode, item: Dict[str, Any]) -> Any:
    #         """Evaluate an expression against an item."""
    #         if expr.node_type == "literal":
    #             return expr.value
    #         elif expr.node_type == "identifier":
                return item.get(expr.value, None)
    #         elif expr.node_type == "binary_op":
    left = self._evaluate_expression(expr.children[0], item)
    right = self._evaluate_expression(expr.children[1], item)

    #             if expr.value == "+":
    #                 return left + right
    #             elif expr.value == "-":
    #                 return left - right
    #             elif expr.value == "*":
    #                 return left * right
    #             elif expr.value == "/":
    #                 return left / right if right != 0 else 0
    #             elif expr.value == "%":
    #                 return left % right if right != 0 else 0
    #             else:
                    raise MQLError(f"Unknown binary operator: {expr.value}")

    #         elif expr.node_type == "unary_op":
    operand = self._evaluate_expression(expr.children[0], item)
    #             if expr.value == "-":
    #                 return -operand
    #             else:
                    raise MQLError(f"Unknown unary operator: {expr.value}")

    #         elif expr.node_type == "function_call":
    #             # Evaluate function arguments
    #             args = [self._evaluate_expression(arg, item) for arg in expr.children]

    #             # Apply function to item context
    #             def apply_function(*args):
    #                 # Create a context that includes the item and function arguments
    context = {**item, "args": args}

    #                 # Apply the function based on its name
    #                 if expr.value == "abs":
    #                     return abs(args[0]) if args else 0
    #                 elif expr.value == "sqrt":
    #                     import math

    #                     return math.sqrt(args[0]) if args else 0
    #                 elif expr.value == "sin":
    #                     import math

    #                     return math.sin(args[0]) if args else 0
    #                 elif expr.value == "cos":
    #                     import math

    #                     return math.cos(args[0]) if args else 0
    #                 elif expr.value == "tan":
    #                     import math

    #                     return math.tan(args[0]) if args else 0
    #                 elif expr.value == "log":
    #                     import math

    #                     return math.log(args[0]) if args else 0
    #                 elif expr.value == "exp":
    #                     import math

    #                     return math.exp(args[0]) if args else 0
    #                 else:
                        raise MQLError(f"Unknown function: {expr.value}")

                return apply_function(*args)

    #         else:
                raise MQLError(f"Unknown expression type: {expr.node_type}")


class MQLExecutor
    #     """Executes MQL queries."""

    #     def __init__(
    #         self,
    #         database_backend,
    #         mathematical_mapper,
    cache_config: Optional[CacheConfig] = None,
    #     ):
    #         """Initialize the MQL executor.

    #         Args:
    #             database_backend: Database backend to use
    #             mathematical_mapper: Mathematical object mapper
    #             cache_config: Cache configuration
    #         """
    self.database_backend = database_backend
    self.mathematical_mapper = mathematical_mapper
    self.cache_config = cache_config
    #         self.pattern_cache = MathematicalCache(cache_config) if cache_config else None
    self.logger = logging.getLogger(__name__)

    #     def execute_query(self, query: str) -> Any:
    #         """Execute an MQL query.

    #         Args:
    #             query: The MQL query string

    #         Returns:
    #             Query result
    #         """
    #         # Parse the query
    lexer = MQLLexer(query)
    tokens = lexer.tokenize()
    parser = MQLParser(tokens)
    query_ast = parser.parse()

    #         # Type check the query
    type_checker = MQLTypeChecker()
    is_valid, errors = type_checker.check_types(query_ast)

    #         if not is_valid:
                raise SemanticError(f"Type checking failed: {', '.join(errors)}")

    #         # Execute the query
            return self._execute_query_ast(query_ast)

    #     def _execute_query_ast(self, query: MQLQuery) -> Any:
    #         """Execute a parsed MQL query.

    #         Args:
    #             query: The parsed query AST

    #         Returns:
    #             Query result
    #         """
    #         # Execute FROM clause
    #         data = self._execute_from_clause(query.from_clause) if query.from_clause else []

    #         # Execute WHERE clause
    #         if query.where_clause and query.where_clause.condition:
    data = [
    #                 item
    #                 for item in data
    #                 if self._evaluate_condition(query.where_clause.condition, item)
    #             ]

    #         # Execute mathematical operations
    #         for operation in query.mathematical_operations:
    data = self._execute_mathematical_operation(operation, data)

    #         # Execute SELECT clause
    #         if query.select_clause:
    data = self._execute_select_clause(query.select_clause, data)

    #         return data

    #     def _execute_from_clause(self, clause: MQLFromClause) -> List[Any]:
    #         """Execute a FROM clause.

    #         Args:
    #             clause: The FROM clause to execute

    #         Returns:
    #             List of data items
    #         """
    data = []

    #         for source in clause.sources:
    #             if source.node_type == "source":
    #                 # Query data from the database backend
    #                 # Use parameterized query to prevent SQL injection
    source_data = self.database_backend.query(
                        "SELECT * FROM ?", (source.value,)
    #                 )
                    data.extend(source_data)
    #             else:
                    raise MQLError(f"Unknown source type: {source.node_type}")

    #         return data

    #     def _execute_select_clause(
    #         self, clause: MQLSelectClause, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a SELECT clause.

    #         Args:
    #             clause: The SELECT clause to execute
    #             data: Input data

    #         Returns:
    #             Selected data
    #         """
    #         if not clause.columns:
    #             return data

    result = []

    #         for item in data:
    selected_item = {}

    #             for column in clause.columns:
    #                 if column.node_type == "identifier":
    selected_item[column.value] = item.get(column.value, None)
    #                 elif column.node_type == "function_call":
    #                     # Evaluate function call
    func_value = self._evaluate_expression(column, item)
    selected_item[column.value] = func_value
    #                 else:
    #                     # Evaluate expression
    expr_value = self._evaluate_expression(column, item)
    selected_item[f"expr_{len(selected_item)}"] = expr_value

                result.append(selected_item)

    #         return result

    #     def _execute_mathematical_operation(
    #         self, operation: MQLMathematicalOperation, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a mathematical operation.

    #         Args:
    #             operation: The operation to execute
    #             data: Input data

    #         Returns:
    #             Result data
    #         """
    #         if operation.operation_type == "function":
                return self._execute_function_operation(operation, data)
    #         elif operation.operation_type == "matrix":
                return self._execute_matrix_operation(operation, data)
    #         elif operation.operation_type == "tensor":
                return self._execute_tensor_operation(operation, data)
    #         elif operation.operation_type == "category":
                return self._execute_category_operation(operation, data)
    #         elif operation.operation_type == "symbolic":
                return self._execute_symbolic_operation(operation, data)
    #         else:
                raise MQLError(f"Unknown operation type: {operation.operation_type}")

    #     def _execute_function_operation(
    #         self, operation: MQLMathematicalOperation, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a function operation.

    #         Args:
    #             operation: The operation to execute
    #             data: Input data

    #         Returns:
    #             Result data
    #         """
    function_name = operation.function_name

    #         # Check cache
    #         if self.pattern_cache and len(data) == 1 and hasattr(data[0], "data"):
    cache_key = f"function:{function_name}:{hash(str(data[0]))}"
    cached_result = self.pattern_cache.get_function_pattern(
    #                 function_name, data[0]
    #             )
    #             if cached_result is not None:
    #                 return [cached_result]

    #         # Execute function
    result_data = []

    #         for item in data:
    #             try:
    #                 if function_name == "eigenvalues":
    #                     if hasattr(item, "eigenvalues"):
    result = item.eigenvalues()
    #                     else:
                            raise MQLError("Eigenvalues operation requires a matrix")
    #                 elif function_name == "eigenvectors":
    #                     if hasattr(item, "eigenvectors"):
    result = item.eigenvectors()
    #                     else:
                            raise MQLError("Eigenvectors operation requires a matrix")
    #                 elif function_name == "determinant":
    #                     if hasattr(item, "determinant"):
    result = item.determinant()
    #                     else:
                            raise MQLError("Determinant operation requires a matrix")
    #                 elif function_name == "inverse":
    #                     if hasattr(item, "inverse"):
    result = item.inverse()
    #                     else:
                            raise MQLError("Inverse operation requires a matrix")
    #                 elif function_name == "transpose":
    #                     if hasattr(item, "transpose"):
    result = item.transpose()
    #                     else:
                            raise MQLError("Transpose operation requires a matrix")
    #                 else:
                        raise MQLError(f"Unknown function: {function_name}")

                    result_data.append(result)

    #                 # Cache result
    #                 if self.pattern_cache and hasattr(item, "data"):
                        self.pattern_cache.cache_function_pattern(
    #                         function_name, item, result
    #                     )

    #             except Exception as e:
                    raise MQLError(f"Error executing function {function_name}: {str(e)}")

    #         return result_data

    #     def _execute_matrix_operation(
    #         self, operation: MQLMathematicalOperation, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a matrix operation.

    #         Args:
    #             operation: The operation to execute
    #             data: Input data

    #         Returns:
    #             Result data
    #         """
    operation_name = operation.function_name

    #         # Check cache
    #         if (
    #             self.pattern_cache
    and len(data) = = 2
                and hasattr(data[0], "data")
                and hasattr(data[1], "data")
    #         ):
    cache_key = (
                    f"matrix:{operation_name}:{hash(str(data[0]))}:{hash(str(data[1]))}"
    #             )
    cached_result = self.pattern_cache.get_matrix_pattern(
    #                 operation_name, data[0], data[1]
    #             )
    #             if cached_result is not None:
    #                 return [cached_result]

    #         # Execute operation
    result_data = []

    #         if len(data) == 2:
    #             try:
    #                 if operation_name == "multiply":
    #                     if hasattr(data[0], "multiply") and hasattr(data[1], "multiply"):
    result = data[0].multiply(data[1])
    #                     else:
                            raise MQLError(
    #                             "Matrix multiply operation requires two matrices"
    #                         )
    #                 elif operation_name == "add":
    #                     if hasattr(data[0], "add") and hasattr(data[1], "add"):
    result = data[0].add(data[1])
    #                     else:
                            raise MQLError("Matrix add operation requires two matrices")
    #                 elif operation_name == "subtract":
    #                     if hasattr(data[0], "subtract") and hasattr(data[1], "subtract"):
    result = data[0].subtract(data[1])
    #                     else:
                            raise MQLError(
    #                             "Matrix subtract operation requires two matrices"
    #                         )
    #                 else:
                        raise MQLError(f"Unknown matrix operation: {operation_name}")

                    result_data.append(result)

    #                 # Cache result
    #                 if (
    #                     self.pattern_cache
                        and hasattr(data[0], "data")
                        and hasattr(data[1], "data")
    #                 ):
                        self.pattern_cache.cache_matrix_pattern(
    #                         operation_name, data[0], data[1], result
    #                     )

    #             except Exception as e:
                    raise MQLError(
                        f"Error executing matrix operation {operation_name}: {str(e)}"
    #                 )
    #         else:
                raise MQLError(
    #                 f"Matrix operation {operation_name} requires exactly two operands"
    #             )

    #         return result_data

    #     def _execute_tensor_operation(
    #         self, operation: MQLMathematicalOperation, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a tensor operation.

    #         Args:
    #             operation: The operation to execute
    #             data: Input data

    #         Returns:
    #             Result data
    #         """
    operation_name = operation.function_name

    #         # Check cache
    #         if (
    #             self.pattern_cache
    and len(data) = = 2
                and hasattr(data[0], "data")
                and hasattr(data[1], "data")
    #         ):
    cache_key = (
                    f"tensor:{operation_name}:{hash(str(data[0]))}:{hash(str(data[1]))}"
    #             )
    cached_result = self.pattern_cache.get_tensor_pattern(
    #                 operation_name, data[0], data[1]
    #             )
    #             if cached_result is not None:
    #                 return [cached_result]

    #         # Execute operation
    result_data = []

    #         if len(data) == 2:
    #             try:
    #                 if operation_name == "contract":
    #                     if hasattr(data[0], "contract") and hasattr(data[1], "contract"):
    result = data[0].contract(data[1])
    #                     else:
                            raise MQLError("Tensor contract operation requires two tensors")
    #                 else:
                        raise MQLError(f"Unknown tensor operation: {operation_name}")

                    result_data.append(result)

    #                 # Cache result
    #                 if (
    #                     self.pattern_cache
                        and hasattr(data[0], "data")
                        and hasattr(data[1], "data")
    #                 ):
                        self.pattern_cache.cache_tensor_pattern(
    #                         operation_name, data[0], data[1], result
    #                     )

    #             except Exception as e:
                    raise MQLError(
                        f"Error executing tensor operation {operation_name}: {str(e)}"
    #                 )
    #         else:
                raise MQLError(
    #                 f"Tensor operation {operation_name} requires exactly two operands"
    #             )

    #         return result_data

    #     def _execute_category_operation(
    #         self, operation: MQLMathematicalOperation, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a category operation.

    #         Args:
    #             operation: The operation to execute
    #             data: Input data

    #         Returns:
    #             Result data
    #         """
    operation_name = operation.function_name

    #         # Check cache
    #         if (
    #             self.pattern_cache
    and len(data) = = 2
                and hasattr(data[0], "data")
                and hasattr(data[1], "data")
    #         ):
    cache_key = (
                    f"category:{operation_name}:{hash(str(data[0]))}:{hash(str(data[1]))}"
    #             )
    cached_result = self.pattern_cache.get_category_pattern(
    #                 operation_name, data[0], data[1]
    #             )
    #             if cached_result is not None:
    #                 return [cached_result]

    #         # Execute operation
    result_data = []

    #         if len(data) == 2:
    #             try:
    #                 if operation_name == "functor_apply":
    #                     if hasattr(data[0], "apply"):
    result = data[0].apply(data[1])
    #                     else:
                            raise MQLError(
    #                             "Functor apply operation requires a functor and object"
    #                         )
    #                 elif operation_name == "natural_transform":
    #                     if hasattr(data[0], "transform"):
    result = data[0].transform(data[1])
    #                     else:
                            raise MQLError(
    #                             "Natural transform operation requires two functors"
    #                         )
    #                 else:
                        raise MQLError(f"Unknown category operation: {operation_name}")

                    result_data.append(result)

    #                 # Cache result
    #                 if (
    #                     self.pattern_cache
                        and hasattr(data[0], "data")
                        and hasattr(data[1], "data")
    #                 ):
                        self.pattern_cache.cache_category_pattern(
    #                         operation_name, data[0], data[1], result
    #                     )

    #             except Exception as e:
                    raise MQLError(
                        f"Error executing category operation {operation_name}: {str(e)}"
    #                 )
    #         else:
                raise MQLError(
    #                 f"Category operation {operation_name} requires exactly two operands"
    #             )

    #         return result_data

    #     def _execute_symbolic_operation(
    #         self, operation: MQLMathematicalOperation, data: List[Any]
    #     ) -> List[Any]:
    #         """Execute a symbolic operation.

    #         Args:
    #             operation: The operation to execute
    #             data: Input data

    #         Returns:
    #             Result data
    #         """
    operation_name = operation.function_name

    #         # Check cache
    #         if self.pattern_cache and len(data) == 1 and hasattr(data[0], "expression"):
    cache_key = f"symbolic:{operation_name}:{hash(str(data[0].expression))}"
    cached_result = self.pattern_cache.get_symbolic_pattern(
    #                 operation_name, data[0].expression
    #             )
    #             if cached_result is not None:
    #                 return [cached_result]

    #         # Execute operation
    result_data = []

    #         if len(data) == 1:
    #             try:
    #                 if operation_name == "simplify":
    #                     if hasattr(data[0], "simplify"):
    result = data[0].simplify()
    #                     else:
                            raise MQLError(
    #                             "Simplify operation requires a symbolic expression"
    #                         )
    #                 elif operation_name == "expand":
    #                     if hasattr(data[0], "expand"):
    result = data[0].expand()
    #                     else:
                            raise MQLError(
    #                             "Expand operation requires a symbolic expression"
    #                         )
    #                 elif operation_name == "factor":
    #                     if hasattr(data[0], "factor"):
    result = data[0].factor()
    #                     else:
                            raise MQLError(
    #                             "Factor operation requires a symbolic expression"
    #                         )
    #                 else:
                        raise MQLError(f"Unknown symbolic operation: {operation_name}")

                    result_data.append(result)

    #                 # Cache result
    #                 if self.pattern_cache and hasattr(data[0], "expression"):
                        self.pattern_cache.cache_symbolic_pattern(
    #                         operation_name, data[0].expression, result
    #                     )

    #             except Exception as e:
                    raise MQLError(
                        f"Error executing symbolic operation {operation_name}: {str(e)}"
    #                 )
    #         else:
                raise MQLError(
    #                 f"Symbolic operation {operation_name} requires exactly one operand"
    #             )

    #         return result_data


class MQLTypeChecker
    #     """Performs type checking on MQL queries."""

    #     def __init__(self):
    #         """Initialize the type checker."""
    self.logger = logging.getLogger(__name__)
    self.type_environment = {}
    self.errors = []
    self.warnings = []

    #     def check_types(self, query: MQLQuery) -> Tuple[bool, List[str]]:
    #         """Perform type checking on a query.

    #         Args:
    #             query: The query to type check

    #         Returns:
                Tuple of (is_valid, error_messages)
    #         """
    self.errors = []
    self.warnings = []

    #         # Check SELECT clause
    #         if query.select_clause:
                self._check_select_clause_types(query.select_clause)

    #         # Check FROM clause
    #         if query.from_clause:
                self._check_from_clause_types(query.from_clause)

    #         # Check WHERE clause
    #         if query.where_clause:
                self._check_where_clause_types(query.where_clause)

    #         # Check mathematical operations
    #         for op in query.mathematical_operations:
                self._check_mathematical_operation_types(op)

    return len(self.errors) = = 0, self.errors

    #     def _check_select_clause_types(self, clause: MQLSelectClause):
    #         """Check types in a SELECT clause."""
    #         for column in clause.columns:
                self._check_expression_types(column)

    #     def _check_from_clause_types(self, clause: MQLFromClause):
    #         """Check types in a FROM clause."""
    #         for source in clause.sources:
    #             if source.node_type == "source":
    #                 # Check if source type is known
    #                 if source.value not in self.type_environment:
                        self.warnings.append(f"Unknown source type: {source.value}")
    #             else:
                    self._check_expression_types(source)

    #     def _check_where_clause_types(self, clause: MQLWhereClause):
    #         """Check types in a WHERE clause."""
    #         if clause.condition:
                self._check_expression_types(clause.condition)

    #     def _check_mathematical_operation_types(self, operation: MQLMathematicalOperation):
    #         """Check types in a mathematical operation."""
    #         # Check operation type
    #         if operation.operation_type not in [
    #             "function",
    #             "matrix",
    #             "tensor",
    #             "category",
    #             "symbolic",
    #         ]:
                self.errors.append(f"Unknown operation type: {operation.operation_type}")

    #         # Check operand types
    #         for operand in operation.operands:
                self._check_expression_types(operand)

    #     def _check_expression_types(self, expr: MQLASTNode):
    #         """Recursively check types in an expression."""
    #         if expr.node_type == "binary_op":
    #             # Check that both operands have compatible types
    left_type = self._get_expression_type(expr.children[0])
    right_type = self._get_expression_type(expr.children[1])

    #             # Check for basic type compatibility
    #             if left_type is not None and right_type is not None:
    #                 if not self._are_types_compatible(left_type, right_type, expr.value):
                        self.errors.append(
    #                         f"Incompatible types: {left_type} {expr.value} {right_type}"
    #                     )

    #             for child in expr.children:
                    self._check_expression_types(child)

    #         elif expr.node_type == "unary_op":
    operand_type = self._get_expression_type(expr.children[0])
    #             if operand_type is not None:
    #                 if not self._is_unary_operator_valid(expr.value, operand_type):
                        self.errors.append(
    #                         f"Invalid unary operator: {expr.value} {operand_type}"
    #                     )

    #             for child in expr.children:
                    self._check_expression_types(child)

    #         elif expr.node_type == "function_call":
    #             # Check function signature
    #             if expr.value not in self._get_valid_function_signatures():
                    self.errors.append(f"Unknown function: {expr.value}")

    #             # Check argument types
    #             for i, child in enumerate(expr.children):
    arg_type = self._get_expression_type(child)
    expected_type = self._get_function_argument_type(expr.value, i)

    #                 if arg_type is not None and expected_type is not None:
    #                     if not self._is_type_subtype(arg_type, expected_type):
                            self.errors.append(
    #                             f"Function {expr.value} argument {i}: expected {expected_type}, got {arg_type}"
    #                         )

    #             for child in expr.children:
                    self._check_expression_types(child)

    #         elif expr.node_type == "identifier":
    #             # Check if identifier type is known
    #             if expr.value not in self.type_environment:
                    self.warnings.append(f"Unknown identifier: {expr.value}")

    #     def _get_expression_type(self, expr: MQLASTNode) -> Optional[str]:
    #         """Get the type of an expression."""
    #         if expr.node_type == "literal":
    #             if isinstance(expr.value, (int, float)):
    #                 return "number"
    #             elif isinstance(expr.value, str):
    #                 return "string"
    #             elif isinstance(expr.value, bool):
    #                 return "boolean"
    #             else:
    #                 return "unknown"

    #         elif expr.node_type == "identifier":
                return self.type_environment.get(expr.value, "unknown")

    #         elif expr.node_type == "binary_op":
    left_type = self._get_expression_type(expr.children[0])
    right_type = self._get_expression_type(expr.children[1])

    #             # For binary operations, return the common type
    #             if left_type == right_type:
    #                 return left_type
    #             elif left_type == "number" and right_type == "number":
    #                 return "number"
    #             else:
    #                 return "unknown"

    #         elif expr.node_type == "unary_op":
                return self._get_expression_type(expr.children[0])

    #         elif expr.node_type == "function_call":
    #             # Return the function's return type
                return self._get_function_return_type(expr.value)

    #         else:
    #             return "unknown"

    #     def _are_types_compatible(self, type1: str, type2: str, operator: str) -> bool:
    #         """Check if two types are compatible for an operator."""
    #         if operator in ["+", "-", "*", "/", "%"]:
    return type1 = = "number" and type2 == "number"
    #         elif operator in ["==", "!=", "<", ">", "<=", ">="]:
    return type1 = = type2
    #         elif operator in ["&&", "||"]:
    return type1 = = "boolean" and type2 == "boolean"
    #         else:
    #             return True

    #     def _is_unary_operator_valid(self, operator: str, operand_type: str) -> bool:
    #         """Check if a unary operator is valid for an operand type."""
    #         if operator == "!":
    return operand_type = = "boolean"
    #         elif operator == "-":
    return operand_type = = "number"
    #         else:
    #             return True

    #     def _get_valid_function_signatures(self) -> Dict[str, List[str]]:
    #         """Get valid function signatures."""
    #         return {
    #             "abs": ["number"],
    #             "sqrt": ["number"],
    #             "sin": ["number"],
    #             "cos": ["number"],
    #             "tan": ["number"],
    #             "log": ["number"],
    #             "exp": ["number"],
    #             "eigenvalues": ["matrix"],
    #             "eigenvectors": ["matrix"],
    #             "determinant": ["matrix"],
    #             "inverse": ["matrix"],
    #             "transpose": ["matrix"],
    #             "contract": ["tensor"],
    #             "decompose": ["tensor"],
    #             "simplify": ["symbolic"],
    #             "expand": ["symbolic"],
    #             "factor": ["symbolic"],
    #         }

    #     def _get_function_argument_type(
    #         self, function_name: str, arg_index: int
    #     ) -> Optional[str]:
    #         """Get the expected type for a function argument."""
    signatures = self._get_valid_function_signatures()
    #         if function_name in signatures:
    args = signatures[function_name]
    #             if arg_index < len(args):
    #                 return args[arg_index]
    #         return None

    #     def _get_function_return_type(self, function_name: str) -> Optional[str]:
    #         """Get the return type for a function."""
    return_types = {
    #             "abs": "number",
    #             "sqrt": "number",
    #             "sin": "number",
    #             "cos": "number",
    #             "tan": "number",
    #             "log": "number",
    #             "exp": "number",
    #             "eigenvalues": "list",
    #             "eigenvectors": "list",
    #             "determinant": "number",
    #             "inverse": "matrix",
    #             "transpose": "matrix",
    #             "contract": "tensor",
    #             "decompose": "list",
    #             "simplify": "symbolic",
    #             "expand": "symbolic",
    #             "factor": "symbolic",
    #         }
            return return_types.get(function_name, "unknown")

    #     def _is_type_subtype(self, subtype: str, supertype: str) -> bool:
    #         """Check if one type is a subtype of another."""
    #         if subtype == supertype:
    #             return True
    #         elif subtype == "number" and supertype == "number":
    #             return True
    #         elif subtype == "list" and supertype == "list":
    #             return True
    #         else:
    #             return False


def create_mql_executor(
database_backend, mathematical_mapper, cache_config: Optional[CacheConfig] = None
# ):
#     """Create and return an MQL executor instance."""
    return MQLExecutor(database_backend, mathematical_mapper, cache_config)


def parse_mql_query(
#     query: str,
#     database_backend,
#     mathematical_mapper,
cache_config: Optional[CacheConfig] = None,
# ):
#     """Parse and execute an MQL query.

#     Args:
#         query: The MQL query string
#         database_backend: Database backend to use
#         mathematical_mapper: Mathematical object mapper
#         cache_config: Cache configuration

#     Returns:
#         Query result
#     """
executor = create_mql_executor(database_backend, mathematical_mapper, cache_config)
    return executor.execute_query(query)
