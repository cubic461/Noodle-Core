# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Query Rewriter for Mathematical Equivalence
# -------------------------------------------
# Implements query rewriting based on mathematical equivalence rules.
# """

import logging
import re
import threading
import time
import collections.defaultdict
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import numpy as np
import sympy
import sympy.Eq,

import ..runtime.mathematical_objects.(
#     MathematicalObject,
#     Matrix,
#     ObjectType,
#     Tensor,
# )
import .errors.QueryRewriteError


class RewriteRuleType(Enum)
    #     """Types of rewrite rules."""

    ALGEBRAIC = "algebraic"
    MATRIX = "matrix"
    TENSOR = "tensor"
    CATEGORY_THEORY = "category_theory"
    SYMBOLIC = "symbolic"
    CALCULUS = "calculus"
    STATISTICAL = "statistical"


# @dataclass
class RewriteRule
    #     """Represents a rewrite rule for mathematical expressions."""

    #     name: str
    #     rule_type: RewriteRuleType
    #     pattern: str  # Pattern to match
    #     replacement: str  # Replacement pattern
    #     condition: Optional[Callable] = None  # Optional condition for applying the rule
    #     cost_factor: float = 1.0  # Cost factor for this rewrite
    enabled: bool = True
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def can_apply(self, expression: str, context: Dict[str, Any] = None) -> bool:
    #         """Check if this rule can be applied to the given expression."""
    #         if not self.enabled:
    #             return False

    #         # Basic pattern matching
    #         if not re.search(self.pattern, expression):
    #             return False

    #         # Check condition if provided
    #         if self.condition is not None:
                return self.condition(expression, context or {})

    #         return True


# @dataclass
class RewriteResult
    #     """Result of a query rewrite operation."""

    #     original_expression: str
    #     rewritten_expression: str
    #     rules_applied: List[str]
    #     cost_savings: float
    #     complexity_reduction: float
    #     confidence: float  # 0.0 to 1.0
    metadata: Dict[str, Any] = field(default_factory=dict)


class QueryRewriter
    #     """Rewrites mathematical queries based on equivalence rules."""

    #     def __init__(self):
    #         """Initialize the query rewriter."""
    self.logger = logging.getLogger(__name__)

    #         # Collection of rewrite rules
    self.rules: Dict[RewriteRuleType, List[RewriteRule]] = defaultdict(list)

    #         # Rule registry
            self._register_default_rules()

    #         # Cache for rewrite results
    self.rewrite_cache = {}
    self.cache_lock = threading.RLock()

    #         # Statistics
    self.stats = {
    #             "rewrites_attempted": 0,
    #             "rewrites_successful": 0,
                "rules_applied": defaultdict(int),
    #             "time_spent": 0.0,
    #         }

    #     def rewrite_expression(
    self, expression: str, context: Dict[str, Any] = None
    #     ) -> RewriteResult:
    #         """Rewrite a mathematical expression using equivalence rules.

    #         Args:
    #             expression: The mathematical expression to rewrite
    #             context: Context information for rewriting

    #         Returns:
    #             Rewrite result with the rewritten expression and metadata
    #         """
    start_time = time.time()
    self.stats["rewrites_attempted"] + = 1

    #         # Create cache key
    cache_key = self._create_cache_key(expression, context or {})

    #         # Check cache
    #         with self.cache_lock:
    #             if cache_key in self.rewrite_cache:
    #                 self.logger.debug(f"Using cached rewrite for expression: {expression}")
    #                 return self.rewrite_cache[cache_key]

    #         # Initialize result
    result = RewriteResult(
    original_expression = expression,
    rewritten_expression = expression,
    rules_applied = [],
    cost_savings = 0.0,
    complexity_reduction = 0.0,
    confidence = 0.0,
    #         )

    #         # Try different rule types in order of preference
    rule_types_order = [
    #             RewriteRuleType.ALGEBRAIC,
    #             RewriteRuleType.SYMBOLIC,
    #             RewriteRuleType.MATRIX,
    #             RewriteRuleType.TENSOR,
    #             RewriteRuleType.CALCULUS,
    #             RewriteRuleType.STATISTICAL,
    #             RewriteRuleType.CATEGORY_THEORY,
    #         ]

    current_expression = expression

    #         for rule_type in rule_types_order:
    #             if rule_type in self.rules:
    #                 # Apply rules of this type
    type_result = self._apply_rules_by_type(
    #                     current_expression, rule_type, context
    #                 )

    #                 if type_result.rules_applied:
    #                     # Update result
                        result.rules_applied.extend(type_result.rules_applied)
    result.cost_savings + = type_result.cost_savings
    result.complexity_reduction + = type_result.complexity_reduction
    result.confidence = max(result.confidence, type_result.confidence)

    #                     # Update expression
    current_expression = type_result.rewritten_expression

    #                     # Update statistics
    #                     for rule_name in type_result.rules_applied:
    self.stats["rules_applied"][rule_name] + = 1

    #         # Set final expression
    result.rewritten_expression = current_expression

    #         # Calculate final confidence
    #         if result.rules_applied:
    result.confidence = min(
                    1.0, result.confidence + 0.1 * len(result.rules_applied)
    #             )

    #         # Check if rewrite was successful
    #         if result.rewritten_expression != result.original_expression:
    self.stats["rewrites_successful"] + = 1

    #         # Cache the result
    #         with self.cache_lock:
    self.rewrite_cache[cache_key] = result

    #         # Update timing statistics
    rewrite_time = math.subtract(time.time(), start_time)
    self.stats["time_spent"] + = rewrite_time

    #         return result

    #     def rewrite_matrix_expression(
    self, matrix_expr: str, context: Dict[str, Any] = None
    #     ) -> RewriteResult:
    #         """Rewrite a matrix-specific expression."""
    #         # Add matrix-specific context
    matrix_context = (context or {}).copy()
    matrix_context["expression_type"] = "matrix"

            return self.rewrite_expression(matrix_expr, matrix_context)

    #     def rewrite_tensor_expression(
    self, tensor_expr: str, context: Dict[str, Any] = None
    #     ) -> RewriteResult:
    #         """Rewrite a tensor-specific expression."""
    #         # Add tensor-specific context
    tensor_context = (context or {}).copy()
    tensor_context["expression_type"] = "tensor"

            return self.rewrite_expression(tensor_expr, tensor_context)

    #     def rewrite_symbolic_expression(
    self, symbolic_expr: str, context: Dict[str, Any] = None
    #     ) -> RewriteResult:
    #         """Rewrite a symbolic mathematical expression."""
    #         # Add symbolic-specific context
    symbolic_context = (context or {}).copy()
    symbolic_context["expression_type"] = "symbolic"

            return self.rewrite_expression(symbolic_expr, symbolic_context)

    #     def add_rule(self, rule: RewriteRule):
    #         """Add a rewrite rule to the rewriter."""
            self.rules[rule.rule_type].append(rule)
            self.logger.info(f"Added rewrite rule: {rule.name}")

    #     def remove_rule(self, rule_name: str, rule_type: RewriteRuleType):
    #         """Remove a rewrite rule."""
    #         if rule_type in self.rules:
    self.rules[rule_type] = [
    #                 rule for rule in self.rules[rule_type] if rule.name != rule_name
    #             ]
                self.logger.info(f"Removed rewrite rule: {rule_name}")

    #     def enable_rule(self, rule_name: str, rule_type: RewriteRuleType):
    #         """Enable a rewrite rule."""
    #         if rule_type in self.rules:
    #             for rule in self.rules[rule_type]:
    #                 if rule.name == rule_name:
    rule.enabled = True
    #                     break

    #     def disable_rule(self, rule_name: str, rule_type: RewriteRuleType):
    #         """Disable a rewrite rule."""
    #         if rule_type in self.rules:
    #             for rule in self.rules[rule_type]:
    #                 if rule.name == rule_name:
    rule.enabled = False
    #                     break

    #     def get_rule_statistics(self) -> Dict[str, Any]:
    #         """Get statistics about rewrite rules."""
    #         return {
    #             "total_rules": sum(len(rules) for rules in self.values()),
                "enabled_rules": sum(
    #                 sum(1 for rule in rules if rule.enabled)
    #                 for rules in self.rules.values()
    #             ),
    #             "rule_types": {
    #                 rule_type.value: len(rules) for rule_type, rules in self.rules.items()
    #             },
                "most_used_rules": dict(
                    sorted(
                        self.stats["rules_applied"].items(),
    key = lambda x: x[1],
    reverse = True,
    #                 )[:10]
    #             ),
    #         }

    #     def clear_cache(self):
    #         """Clear the rewrite cache."""
    #         with self.cache_lock:
                self.rewrite_cache.clear()

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get rewriter statistics."""
    #         return {
    #             **self.stats,
                "cache_size": len(self.rewrite_cache),
                "rule_stats": self.get_rule_statistics(),
    #         }

    #     def _apply_rules_by_type(
    #         self,
    #         expression: str,
    #         rule_type: RewriteRuleType,
    context: Dict[str, Any] = None,
    #     ) -> RewriteResult:
    #         """Apply all rules of a specific type to an expression."""
    result = RewriteResult(
    original_expression = expression,
    rewritten_expression = expression,
    rules_applied = [],
    cost_savings = 0.0,
    complexity_reduction = 0.0,
    confidence = 0.0,
    #         )

    current_expression = expression

    #         for rule in self.rules[rule_type]:
    #             if rule.can_apply(current_expression, context):
    #                 try:
    #                     # Apply the rule
    new_expression = re.sub(
    #                         rule.pattern, rule.replacement, current_expression
    #                     )

    #                     if new_expression != current_expression:
    #                         # Update result
                            result.rules_applied.append(rule.name)
    result.cost_savings + = rule.cost_factor

    #                         # Estimate complexity reduction
    complexity_reduction = self._estimate_complexity_reduction(
    #                             current_expression, new_expression
    #                         )
    result.complexity_reduction + = complexity_reduction

    #                         # Update confidence based on rule type
    rule_confidence = self._get_rule_confidence(rule)
    result.confidence = max(result.confidence, rule_confidence)

    #                         # Update expression
    current_expression = new_expression

                            self.logger.debug(
    #                             f"Applied rule {rule.name}: {expression} -> {new_expression}"
    #                         )

    #                         # Don't apply more rules of the same type to avoid over-rewriting
    #                         break

    #                 except Exception as e:
                        self.logger.warning(f"Failed to apply rule {rule.name}: {e}")

    result.rewritten_expression = current_expression
    #         return result

    #     def _estimate_complexity_reduction(self, original: str, rewritten: str) -> float:
    #         """Estimate the complexity reduction from a rewrite."""
    #         # Simple heuristic: count operators and parentheses
    original_ops = len(re.findall(r"[\+\-\*\/\^\(\)\[\]\{\}]", original))
    rewritten_ops = len(re.findall(r"[\+\-\*\/\^\(\)\[\]\{\}]", rewritten))

    #         if original_ops == 0:
    #             return 0.0

    reduction = math.subtract((original_ops, rewritten_ops) / original_ops)
            return max(0.0, reduction)

    #     def _get_rule_confidence(self, rule: RewriteRule) -> float:
    #         """Get confidence level for a rule based on its type and metadata."""
    base_confidence = {
    #             RewriteRuleType.ALGEBRAIC: 0.9,
    #             RewriteRuleType.SYMBOLIC: 0.8,
    #             RewriteRuleType.MATRIX: 0.7,
    #             RewriteRuleType.TENSOR: 0.6,
    #             RewriteRuleType.CALCULUS: 0.5,
    #             RewriteRuleType.STATISTICAL: 0.4,
    #             RewriteRuleType.CATEGORY_THEORY: 0.3,
    #         }

    confidence = base_confidence.get(rule.rule_type, 0.5)

    # Adjust based on cost factor (lower cost = higher confidence)
    #         if rule.cost_factor < 1.0:
    confidence * = 1.2

    #         # Adjust based on metadata
    #         if rule.metadata.get("verified", False):
    confidence * = 1.1

            return min(1.0, confidence)

    #     def _create_cache_key(self, expression: str, context: Dict[str, Any]) -> str:
    #         """Create a cache key for an expression and context."""
    #         # Simple implementation - could be improved with hashing
    context_str = str(sorted(context.items()))
    #         return f"{expression}_{context_str}"

    #     def _register_default_rules(self):
    #         """Register default rewrite rules."""

    #         # Algebraic rules
            self.add_rule(
                RewriteRule(
    name = "commutative_addition",
    rule_type = RewriteRuleType.ALGEBRAIC,
    pattern = r"(\w+)\s*\+\s*(\w+)",
    replacement = r"\2 + \1",
    cost_factor = 0.1,
    metadata = {"verified": True},
    #             )
    #         )

            self.add_rule(
                RewriteRule(
    name = "associative_addition",
    rule_type = RewriteRuleType.ALGEBRAIC,
    pattern = r"\(\s*(\w+)\s*\+\s*(\w+)\s*\)\s*\+\s*(\w+)",
    replacement = r"\1 + (\2 + \3)",
    cost_factor = 0.1,
    metadata = {"verified": True},
    #             )
    #         )

            self.add_rule(
                RewriteRule(
    name = "distributive_property",
    rule_type = RewriteRuleType.ALGEBRAIC,
    pattern = r"\(\s*(\w+)\s*\+\s*(\w+)\s*\)\s*\*\s*(\w+)",
    replacement = r"(\1 * \3) + (\2 * \3)",
    cost_factor = 0.2,
    metadata = {"verified": True},
    #             )
    #         )

    #         # Matrix rules
            self.add_rule(
                RewriteRule(
    name = "matrix_transpose_double",
    rule_type = RewriteRuleType.MATRIX,
    pattern = r"transpose\(transpose\((\w+)\)\)",
    replacement = r"\1",
    cost_factor = 0.5,
    condition = lambda expr, ctx: "matrix" in ctx.get("expression_type", ""),
    metadata = {"verified": True},
    #             )
    #         )

            self.add_rule(
                RewriteRule(
    name = "matrix_multiply_identity",
    rule_type = RewriteRuleType.MATRIX,
    pattern = r"(\w+)\s*\*\s*identity\((\d+)\)",
    replacement = r"\1",
    cost_factor = 0.3,
    condition = lambda expr, ctx: "matrix" in ctx.get("expression_type", ""),
    metadata = {"verified": True},
    #             )
    #         )

    #         # Symbolic rules
            self.add_rule(
                RewriteRule(
    name = "symbolic_simplify",
    rule_type = RewriteRuleType.SYMBOLIC,
    pattern = r"simplify\(([^)]+)\)",
    replacement = r"\1",  # Will be handled by sympy
    cost_factor = 0.2,
    condition = lambda expr, ctx: self._can_simplify_symbolic(expr),
    metadata = {"verified": True},
    #             )
    #         )

    #         # Tensor rules
            self.add_rule(
                RewriteRule(
    name = "tensor_contraction_identity",
    rule_type = RewriteRuleType.TENSOR,
    pattern = r"contract\((\w+),\s*identity\(\)\)",
    replacement = r"\1",
    cost_factor = 0.4,
    condition = lambda expr, ctx: "tensor" in ctx.get("expression_type", ""),
    metadata = {"verified": True},
    #             )
    #         )

    #     def _can_simplify_symbolic(self, expression: str) -> bool:
    #         """Check if an expression can be simplified symbolically."""
    #         try:
    #             # Try to parse with sympy
    parsed = sympy.sympify(expression)
    #             return not parsed.is_Atom  # Can simplify non-atomic expressions
    #         except:
    #             return False


class MathematicalEquivalenceChecker
    #     """Checks mathematical equivalence between expressions."""

    #     def __init__(self):
    #         """Initialize the equivalence checker."""
    self.logger = logging.getLogger(__name__)

    #         # Cache for equivalence results
    self.equivalence_cache = {}
    self.cache_lock = threading.RLock()

    #     def are_equivalent(
    self, expr1: str, expr2: str, context: Dict[str, Any] = None
    #     ) -> Tuple[bool, float]:
    #         """Check if two mathematical expressions are equivalent.

    #         Args:
    #             expr1: First expression
    #             expr2: Second expression
    #             context: Context information

    #         Returns:
                Tuple of (is_equivalent, confidence)
    #         """
    #         # Create cache key
    cache_key = f"{expr1}={expr2}"

    #         # Check cache
    #         with self.cache_lock:
    #             if cache_key in self.equivalence_cache:
    #                 return self.equivalence_cache[cache_key]

    #         # Try different equivalence checking methods
    methods = [
    #             self._check_sympy_equivalence,
    #             self._check_pattern_equivalence,
    #             self._check_numeric_equivalence,
    #         ]

    best_result = (False, 0.0)

    #         for method in methods:
    #             try:
    is_equivalent, confidence = method(expr1, expr2, context or {})

    #                 if is_equivalent and confidence > best_result[1]:
    best_result = (True, confidence)

    #             except Exception as e:
                    self.logger.warning(f"Equivalence check method failed: {e}")

    #         # Cache the result
    #         with self.cache_lock:
    self.equivalence_cache[cache_key] = best_result

    #         return best_result

    #     def _check_sympy_equivalence(
    #         self, expr1: str, expr2: str, context: Dict[str, Any]
    #     ) -> Tuple[bool, float]:
    #         """Check equivalence using sympy."""
    #         try:
    #             # Parse expressions
    parsed1 = sympy.sympify(expr1)
    parsed2 = sympy.sympify(expr2)

    #             # Check if they are mathematically equivalent
    equivalent = math.subtract(sympy.simplify(parsed1, parsed2) == 0)

    #             # Calculate confidence based on expression complexity
    complexity1 = len(str(parsed1))
    complexity2 = len(str(parsed2))
    max_complexity = max(complexity1, complexity2)

    #             confidence = 0.9 if max_complexity < 10 else 0.7

    #             return equivalent, confidence

    #         except Exception as e:
                self.logger.debug(f"Sympy equivalence check failed: {e}")
    #             return False, 0.0

    #     def _check_pattern_equivalence(
    #         self, expr1: str, expr2: str, context: Dict[str, Any]
    #     ) -> Tuple[bool, float]:
    #         """Check equivalence using pattern matching."""
    #         # Normalize expressions
    norm1 = self._normalize_expression(expr1)
    norm2 = self._normalize_expression(expr2)

    equivalent = norm1 == norm2
    confidence = 0.6  # Pattern matching is less reliable

    #         return equivalent, confidence

    #     def _check_numeric_equivalence(
    #         self, expr1: str, expr2: str, context: Dict[str, Any]
    #     ) -> Tuple[bool, float]:
    #         """Check equivalence by evaluating with sample values."""
    #         try:
    #             # Create sample values for variables
    variables = math.add(self._extract_variables(expr1, expr2))
    #             sample_values = {var: np.random.uniform(-10, 10) for var in variables}

    #             # Evaluate expressions
    val1 = self._evaluate_expression(expr1, sample_values)
    val2 = self._evaluate_expression(expr2, sample_values)

    #             # Check if values are close (within numerical tolerance)
    equivalent = math.subtract(np.isclose(val1, val2, rtol=1e, 6, atol=1e-8))
    confidence = 0.8  # Numeric checking is reliable but not absolute

    #             return equivalent, confidence

    #         except Exception as e:
                self.logger.debug(f"Numeric equivalence check failed: {e}")
    #             return False, 0.0

    #     def _normalize_expression(self, expression: str) -> str:
    #         """Normalize an expression for pattern matching."""
    #         # Remove whitespace
    normalized = re.sub(r"\s+", "", expression)

    #         # Sort commutative operations
    normalized = re.sub(
                r"(\w+)\+(\w+)",
                lambda m: "+".join(sorted([m.group(1), m.group(2)])),
    #             normalized,
    #         )
    normalized = re.sub(
                r"(\w+)\*(\w+)",
                lambda m: "*".join(sorted([m.group(1), m.group(2)])),
    #             normalized,
    #         )

    #         return normalized

    #     def _extract_variables(self, expression: str) -> List[str]:
    #         """Extract variables from an expression."""
            # Find all alphanumeric sequences (excluding function names)
    variables = re.findall(r"\b[a-zA-Z_]\w*\b", expression)

    #         # Filter out common function names
    functions = {"sin", "cos", "tan", "exp", "log", "sqrt", "transpose", "contract"}
    #         variables = [var for var in variables if var not in functions]

            return list(set(variables))

    #     def _evaluate_expression(self, expression: str, values: Dict[str, float]) -> float:
    #         """Evaluate an expression with given values."""
    #         # Replace variables with values
    #         for var, val in values.items():
    expression = expression.replace(var, str(val))

    #         # Evaluate safely
    #         try:
                return eval(expression, {"__builtins__": None}, {"np": np})
    #         except:
                raise ValueError(f"Failed to evaluate expression: {expression}")

    #     def clear_cache(self):
    #         """Clear the equivalence cache."""
    #         with self.cache_lock:
                self.equivalence_cache.clear()
