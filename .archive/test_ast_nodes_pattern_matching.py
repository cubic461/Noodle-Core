#!/usr/bin/env python3
"""
Pattern Matching Tests for Noodle AST Nodes
===========================================
Test suite for pattern matching functionality in ast_nodes.nc

Generated: December 19, 2025
Author: Michael van Erp
"""

import unittest
import sys
from pathlib import Path

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent / "noodle-core" / "src"))

# We need to import from the Noodle files (converted from .nc)
try:
    from noodlecore.parser.parser_ast_nodes_nc import (
        NodeType, Type, Identifier, ASTNode, 
        StatementNode, ExpressionNode,
        PatternMatchingNode, PatternClauseNode,
        LiteralPatternNode, WildcardPatternNode,
        VariablePatternNode, TypePatternNode,
        TuplePatternNode, ListPatternNode,
        RecordPatternNode, GuardExpressionNode,
        DestructuringPatternNode
    )
except ImportError:
    # Fallback - use mock classes if Noodle files not available
    print("Warning: Noodle AST nodes not found. Using mock classes for test generation.")
    from unittest.mock import Mock
    NodeType = Mock()
    ASTNode = Mock()
    ExpressionNode = Mock()
    StatementNode = Mock()


class TestPatternMatchingBasic(unittest.TestCase):
    """Test basic pattern matching constructs - literal, wildcard, variable patterns."""
    
    def test_literal_pattern_number(self):
        """Test literal pattern matching for numbers."""
        # Match 42 => "answer"
        # Pattern: case 42
        pattern = LiteralPatternNode(value=42, type_name="int")
        self.assertEqual(pattern.value, 42)
        self.assertEqual(pattern.type_name, "int")
    
    def test_literal_pattern_string(self):
        """Test literal pattern matching for strings."""
        # Match "hello" => "greeting"
        pattern = LiteralPatternNode(value="hello", type_name="str")
        self.assertEqual(pattern.value, "hello")
        self.assertEqual(pattern.type_name, "str")
    
    def test_literal_pattern_boolean(self):
        """Test literal pattern matching for booleans."""
        # Match true => "boolean"
        pattern = LiteralPatternNode(value=True, type_name="bool")
        self.assertEqual(pattern.value, True)
        self.assertEqual(pattern.type_name, "bool")
    
    def test_literal_pattern_float(self):
        """Test literal pattern matching for floats."""
        # Match 3.14 => "pi"
        pattern = LiteralPatternNode(value=3.14, type_name="float")
        self.assertAlmostEqual(pattern.value, 3.14, places=2)
        self.assertEqual(pattern.type_name, "float")
    
    def test_wildcard_pattern(self):
        """Test wildcard pattern (_) matches everything."""
        # Match _ => "default"
        pattern = WildcardPatternNode()
        self.assertIsNotNone(pattern)
        # Wildcard should match any value
        self.assertTrue(pattern.matches_any())
    
    def test_variable_pattern_simple(self):
        """Test variable binding pattern."""
        # Match x => f"got {x}"
        pattern = VariablePatternNode(name="x", type_hint=None)
        self.assertEqual(pattern.name, "x")
        self.assertIsNone(pattern.type_hint)
    
    def test_variable_pattern_typed(self):
        """Test typed variable pattern."""
        # Match x: int => f"got integer {x}"
        type_hint = Type(name="int", is_builtin=True)
        pattern = VariablePatternNode(name="x", type_hint=type_hint)
        self.assertEqual(pattern.name, "x")
        self.assertEqual(pattern.type_hint.name, "int")
    
    def test_variable_pattern_string(self):
        """Test string-typed variable pattern."""
        # Match s: str => len(s)
        type_hint = Type(name="str", is_builtin=True)
        pattern = VariablePatternNode(name="s", type_hint=type_hint)
        self.assertEqual(pattern.name, "s")
        self.assertEqual(pattern.type_hint.name, "str")


class TestPatternMatchingDestructuring(unittest.TestCase):
    """Test destructuring patterns - tuple, list, record destructuring."""
    
    def test_tuple_pattern_two_elements(self):
        """Test tuple destructuring pattern with two elements."""
        # Match (x, y) => x + y
        elements = [
            VariablePatternNode(name="x"),
            VariablePatternNode(name="y")
        ]
        pattern = TuplePatternNode(elements=elements)
        self.assertEqual(len(pattern.elements), 2)
        self.assertEqual(pattern.elements[0].name, "x")
        self.assertEqual(pattern.elements[1].name, "y")
    
    def test_tuple_pattern_three_elements(self):
        """Test tuple destructuring pattern with three elements."""
        # Match (x, y, z) => x + y + z
        elements = [
            VariablePatternNode(name="x"),
            VariablePatternNode(name="y"),
            VariablePatternNode(name="z")
        ]
        pattern = TuplePatternNode(elements=elements)
        self.assertEqual(len(pattern.elements), 3)
    
    def test_tuple_pattern_nested(self):
        """Test nested tuple destructuring pattern."""
        # Match ((a, b), c) => a + b + c
        inner_tuple = TuplePatternNode(elements=[
            VariablePatternNode(name="a"),
            VariablePatternNode(name="b")
        ])
        pattern = TuplePatternNode(elements=[inner_tuple, VariablePatternNode(name="c")])
        self.assertEqual(len(pattern.elements), 2)
    
    def test_list_pattern_empty(self):
        """Test empty list destructuring pattern."""
        # Match [] => "empty"
        pattern = ListPatternNode(elements=[], has_rest=False)
        self.assertEqual(len(pattern.elements), 0)
        self.assertFalse(pattern.has_rest)
    
    def test_list_pattern_single(self):
        """Test list destructuring pattern with single element."""
        # Match [x] => f"single {x}"
        elements = [VariablePatternNode(name="x")]
        pattern = ListPatternNode(elements=elements, has_rest=False)
        self.assertEqual(len(pattern.elements), 1)
        self.assertEqual(pattern.elements[0].name, "x")
    
    def test_list_pattern_head_tail(self):
        """Test list destructuring pattern with head and tail."""
        # Match [head, *tail] => head + sum(tail)
        elements = [VariablePatternNode(name="head")]
        pattern = ListPatternNode(elements=elements, has_rest=True, rest_name="tail")
        self.assertEqual(len(pattern.elements), 1)
        self.assertTrue(pattern.has_rest)
        self.assertEqual(pattern.rest_name, "tail")
    
    def test_list_pattern_multiple_with_rest(self):
        """Test list destructuring pattern with multiple elements and rest."""
        # Match [first, second, *_] => first + second
        elements = [
            VariablePatternNode(name="first"),
            VariablePatternNode(name="second")
        ]
        pattern = ListPatternNode(elements=elements, has_rest=True, rest_name="_")
        self.assertEqual(len(pattern.elements), 2)
        self.assertTrue(pattern.has_rest)
    
    def test_record_pattern_simple(self):
        """Test simple record/object destructuring pattern."""
        # Match Person(name, age) => f"{name} is {age}"
        fields = {
            "name": VariablePatternNode(name="name"),
            "age": VariablePatternNode(name="age")
        }
        pattern = RecordPatternNode(record_type="Person", fields=fields)
        self.assertEqual(pattern.record_type, "Person")
        self.assertEqual(len(pattern.fields), 2)
        self.assertIn("name", pattern.fields)
        self.assertIn("age", pattern.fields)
    
    def test_record_pattern_nested(self):
        """Test nested record destructuring pattern."""
        # Match Address(street, city) with street field
        address_fields = {
            "street": VariablePatternNode(name="street"),
            "city": VariablePatternNode(name="city")
        }
        address_pattern = RecordPatternNode(record_type="Address", fields=address_fields)
        
        # Person with nested Address
        person_fields = {
            "name": VariablePatternNode(name="name"),
            "address": address_pattern
        }
        pattern = RecordPatternNode(record_type="Person", fields=person_fields)
        self.assertEqual(pattern.record_type, "Person")
        self.assertIn("address", pattern.fields)


class TestPatternMatchingGuards(unittest.TestCase):
    """Test pattern guards (when clauses)."""
    
    def test_guard_simple_condition(self):
        """Test basic guard condition."""
        # Match x if x > 0 => "positive"
        guard = GuardExpressionNode(condition="x > 0")
        self.assertEqual(guard.condition, "x > 0")
        self.assertTrue(guard.has_condition())
    
    def test_guard_type_check(self):
        """Test guard with type check."""
        # Match s: str if len(s) > 5 => "long string"
        guard = GuardExpressionNode(condition="len(s) > 5")
        self.assertEqual(guard.condition, "len(s) > 5")
    
    def test_guard_complex_logic(self):
        """Test guard with complex logical expression."""
        # Match x if x > 10 && x < 100 => "in range"
        guard = GuardExpressionNode(condition="x > 10 && x < 100")
        self.assertEqual(guard.condition, "x > 10 && x < 100")
    
    def test_guard_with_and(self):
        """Test guard with AND logic."""
        # Match p: Point if p.x > 0 && p.y > 0 => "first quadrant"
        guard = GuardExpressionNode(condition="p.x > 0 && p.y > 0")
        self.assertEqual(guard.condition, "p.x > 0 && p.y > 0")
    
    def test_guard_with_or(self):
        """Test guard with OR logic."""
        # Match x if x < 0 || x > 100 => "out of range"
        guard = GuardExpressionNode(condition="x < 0 || x > 100")
        self.assertEqual(guard.condition, "x < 0 || x > 100")


class TestPatternMatchingExpressions(unittest.TestCase):
    """Test full pattern matching expressions."""
    
    def test_pattern_clause_basic(self):
        """Test basic pattern clause structure."""
        # case 42 => "answer"
        pattern = LiteralPatternNode(value=42)
        result = LiteralExprNode(value="answer", type_name="str")
        clause = PatternClauseNode(pattern=pattern, expression=result)
        
        self.assertIsNotNone(clause.pattern)
        self.assertIsNotNone(clause.expression)
    
    def test_pattern_clause_with_guard(self):
        """Test pattern clause with guard condition."""
        # case x if x > 0 => "positive"
        pattern = VariablePatternNode(name="x")
        guard = GuardExpressionNode(condition="x > 0")
        result = LiteralExprNode(value="positive", type_name="str")
        clause = PatternClauseNode(pattern=pattern, expression=result, guard=guard)
        
        self.assertIsNotNone(clause.pattern)
        self.assertIsNotNone(clause.guard)
        self.assertEqual(clause.guard.condition, "x > 0")
    
    def test_match_expression_simple(self):
        """Test simple match expression."""
        # result = match value {
        #   case 1 => "one"
        #   case 2 => "two"
        #   case _ => "other"
        # }
        clauses = [
            PatternClauseNode(
                pattern=LiteralPatternNode(value=1),
                expression=LiteralExprNode(value="one", type_name="str")
            ),
            PatternClauseNode(
                pattern=LiteralPatternNode(value=2),
                expression=LiteralExprNode(value="two", type_name="str")
            ),
            PatternClauseNode(
                pattern=WildcardPatternNode(),
                expression=LiteralExprNode(value="other", type_name="str")
            )
        ]
        
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="value"),
            clauses=clauses
        )
        
        self.assertEqual(len(match_expr.clauses), 3)
        self.assertEqual(match_expr.clauses[0].pattern.value, 1)
        self.assertEqual(match_expr.clauses[1].pattern.value, 2)
        self.assertIsInstance(match_expr.clauses[2].pattern, WildcardPatternNode)
    
    def test_match_expression_with_types(self):
        """Test match expression with type patterns."""
        # result = match value {
        #   case x: int => "integer"
        #   case s: str => "string"
        #   case _ => "other"
        # }
        int_type = Type(name="int", is_builtin=True)
        str_type = Type(name="str", is_builtin=True)
        
        clauses = [
            PatternClauseNode(
                pattern=VariablePatternNode(name="x", type_hint=int_type),
                expression=LiteralExprNode(value="integer", type_name="str")
            ),
            PatternClauseNode(
                pattern=VariablePatternNode(name="s", type_hint=str_type),
                expression=LiteralExprNode(value="string", type_name="str")
            ),
            PatternClauseNode(
                pattern=WildcardPatternNode(),
                expression=LiteralExprNode(value="other", type_name="str")
            )
        ]
        
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="value"),
            clauses=clauses
        )
        
        self.assertEqual(len(match_expr.clauses), 3)
        self.assertEqual(match_expr.clauses[0].pattern.type_hint.name, "int")
        self.assertEqual(match_expr.clauses[1].pattern.type_hint.name, "str")
    
    def test_match_expression_destructuring(self):
        """Test match expression with destructuring patterns."""
        # result = match point {
        #   case Point(0, y) => f"on x-axis at y={y}"
        #   case Point(x, 0) => f"on y-axis at x={x}"
        #   case Point(x, y) => f"at ({x}, {y})"
        # }
        clauses = [
            # Point(0, y)
            PatternClauseNode(
                pattern=RecordPatternNode(
                    record_type="Point",
                    fields={
                        "x": LiteralPatternNode(value=0),
                        "y": VariablePatternNode(name="y")
                    }
                ),
                expression=LiteralExprNode(value="on x-axis", type_name="str")
            ),
            # Point(x, 0)
            PatternClauseNode(
                pattern=RecordPatternNode(
                    record_type="Point",
                    fields={
                        "x": VariablePatternNode(name="x"),
                        "y": LiteralPatternNode(value=0)
                    }
                ),
                expression=LiteralExprNode(value="on y-axis", type_name="str")
            ),
            # Point(x, y)
            PatternClauseNode(
                pattern=RecordPatternNode(
                    record_type="Point",
                    fields={
                        "x": VariablePatternNode(name="x"),
                        "y": VariablePatternNode(name="y")
                    }
                ),
                expression=LiteralExprNode(value="at coordinates", type_name="str")
            )
        ]
        
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="point"),
            clauses=clauses
        )
        
        self.assertEqual(len(match_expr.clauses), 3)


class TestPatternMatchingEdgeCases(unittest.TestCase):
    """Test edge cases and error conditions."""
    
    def test_empty_pattern_list(self):
        """Test pattern matching with no clauses."""
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="value"),
            clauses=[]
        )
        self.assertEqual(len(match_expr.clauses), 0)
    
    def test_single_clause_no_default(self):
        """Test match expression with single clause and no default."""
        clauses = [
            PatternClauseNode(
                pattern=LiteralPatternNode(value=42),
                expression=LiteralExprNode(value="answer", type_name="str")
            )
        ]
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="value"),
            clauses=clauses
        )
        self.assertEqual(len(match_expr.clauses), 1)
    
    def test_nested_match_expression(self):
        """Test nested pattern matching."""
        # Match outer {
        #   case Inner(value) => match value { ... }
        # }
        inner_clauses = [
            PatternClauseNode(
                pattern=LiteralPatternNode(value=1),
                expression=LiteralExprNode(value="one", type_name="str")
            ),
            PatternClauseNode(
                pattern=WildcardPatternNode(),
                expression=LiteralExprNode(value="other", type_name="str")
            )
        ]
        inner_match = PatternMatchingNode(
            value=IdentifierExprNode(name="value"),
            clauses=inner_clauses
        )
        
        outer_clauses = [
            PatternClauseNode(
                pattern=RecordPatternNode(
                    record_type="Inner",
                    fields={"value": VariablePatternNode(name="value")}
                ),
                expression=inner_match
            )
        ]
        outer_match = PatternMatchingNode(
            value=IdentifierExprNode(name="outer"),
            clauses=outer_clauses
        )
        
        self.assertEqual(len(outer_match.clauses), 1)
    
    def test_pattern_with_multiple_guards(self):
        """Test pattern matching with multiple guard conditions."""
        # Match x {
        #   case x if x > 10 => "big"
        #   case x if x > 0 => "small"
        #   case _ => "zero or negative"
        # }
        clauses = [
            PatternClauseNode(
                pattern=VariablePatternNode(name="x"),
                expression=LiteralExprNode(value="big", type_name="str"),
                guard=GuardExpressionNode(condition="x > 10")
            ),
            PatternClauseNode(
                pattern=VariablePatternNode(name="x"),
                expression=LiteralExprNode(value="small", type_name="str"),
                guard=GuardExpressionNode(condition="x > 0")
            ),
            PatternClauseNode(
                pattern=WildcardPatternNode(),
                expression=LiteralExprNode(value="zero or negative", type_name="str")
            )
        ]
        
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="x"),
            clauses=clauses
        )
        
        self.assertEqual(len(match_expr.clauses), 3)
        self.assertIsNotNone(match_expr.clauses[0].guard)
        self.assertIsNotNone(match_expr.clauses[1].guard)
        self.assertIsNone(match_expr.clauses[2].guard)


class TestPatternMatchingComplex(unittest.TestCase):
    """Test complex pattern matching scenarios."""
    
    def test_list_head_tail_pattern(self):
        """Test list head-tail pattern matching."""
        # Match list {
        #   case [] => "empty"
        #   case [x] => f"single {x}"
        #   case [head, *tail] => head + sum(tail)
        # }
        clauses = [
            PatternClauseNode(
                pattern=ListPatternNode(elements=[], has_rest=False),
                expression=LiteralExprNode(value="empty", type_name="str")
            ),
            PatternClauseNode(
                pattern=ListPatternNode(
                    elements=[VariablePatternNode(name="x")],
                    has_rest=False
                ),
                expression=LiteralExprNode(value="single", type_name="str")
            ),
            PatternClauseNode(
                pattern=ListPatternNode(
                    elements=[VariablePatternNode(name="head")],
                    has_rest=True,
                    rest_name="tail"
                ),
                expression=LiteralExprNode(value="head + sum(tail)", type_name="str")
            )
        ]
        
        match_expr = PatternMatchingNode(
            value=IdentifierExprNode(name="list"),
            clauses=clauses
        )
        
        self.assertEqual(len(match_expr.clauses), 3)
    
    def test_tuple_nested_destructuring(self):
        """Test nested tuple destructuring."""
        # Match ((a, b), c) => a + b + c
        inner_tuple = TuplePatternNode(elements=[
            VariablePatternNode(name="a"),
            VariablePatternNode(name="b")
        ])
        pattern = TuplePatternNode(elements=[inner_tuple, VariablePatternNode(name="c")])
        
        clause = PatternClauseNode(
            pattern=pattern,
            expression=LiteralExprNode(value="a + b + c", type_name="str")
        )
        
        self.assertIsNotNone(clause)
    
    def test_record_with_complex_fields(self):
        """Test record pattern with complex field patterns."""
        # Match Person(name: str, age: int if age >= 18)
        name_pattern = VariablePatternNode(name="name", type_hint=Type(name="str"))
        age_pattern = VariablePatternNode(name="age", type_hint=Type(name="int"))
        age_guard = GuardExpressionNode(condition="age >= 18")
        
        pattern = RecordPatternNode(
            record_type="Person",
            fields={
                "name": name_pattern,
                "age": age_pattern
            }
        )
        
        clause = PatternClauseNode(
            pattern=pattern,
            expression=LiteralExprNode(value="adult", type_name="str"),
            guard=age_guard
        )
        
        self.assertIsNotNone(clause)
        self.assertIsNotNone(clause.guard)


if __name__ == '__main__':
    unittest.main()
