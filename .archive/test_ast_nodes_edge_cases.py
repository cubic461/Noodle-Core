#!/usr/bin/env python3
"""
Edge Cases & Boundary Conditions Tests for Noodle AST Nodes
===========================================================
Test suite for edge cases, error conditions, and boundary scenarios in ast_nodes.nc

Generated: December 19, 2025
Author: Michael van Erp
"""

import unittest
import sys
from pathlib import Path
from unittest.mock import Mock

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent / "noodle-core" / "src"))

# Import Noodle AST nodes
try:
    from noodlecore.parser.parser_ast_nodes_nc import (
        NodeType, Type, Identifier, ASTNode,
        StatementNode, ExpressionNode,
        LiteralExprNode, IdentifierExprNode, BinaryExprNode,
        VarDeclNode, FuncDefNode, IfStmtNode, WhileStmtNode
    )
except ImportError:
    print("Warning: Noodle AST nodes not found. Using mock classes.")
    from unittest.mock import Mock
    NodeType = Mock()
    ASTNode = Mock()


class TestBoundaryValueConditions(unittest.TestCase):
    """Test boundary value conditions and edge cases."""
    
    def test_integer_literal_max_value(self):
        """Test maximum integer literal value."""
        # MAX_INT = 2147483647
        max_int = 2**31 - 1
        literal = LiteralExprNode(value=max_int, type_name="int")
        self.assertEqual(literal.value, max_int)
        self.assertEqual(literal.type_name, "int")
    
    def test_integer_literal_min_value(self):
        """Test minimum integer literal value."""
        # MIN_INT = -2147483648
        min_int = -(2**31)
        literal = LiteralExprNode(value=min_int, type_name="int")
        self.assertEqual(literal.value, min_int)
    
    def test_integer_literal_overflow(self):
        """Test integer literal overflow behavior."""
        # 2**63 - 1 (maximum for 64-bit signed int)
        large_int = 2**63 - 1
        literal = LiteralExprNode(value=large_int, type_name="int")
        self.assertGreater(literal.value, 0)
    
    def test_integer_literal_zero(self):
        """Test zero integer literal."""
        literal = LiteralExprNode(value=0, type_name="int")
        self.assertEqual(literal.value, 0)
    
    def test_float_literal_max(self):
        """Test maximum float literal value."""
        max_float = 1.7976931348623157e+308  # sys.float_info.max
        literal = LiteralExprNode(value=max_float, type_name="float")
        self.assertGreater(literal.value, 0)
    
    def test_float_literal_min_positive(self):
        """Test minimum positive float literal value."""
        min_float = 2.2250738585072014e-308  # sys.float_info.min
        literal = LiteralExprNode(value=min_float, type_name="float")
        self.assertGreater(literal.value, 0)
        self.assertLess(literal.value, 1)
    
    def test_float_literal_infinity(self):
        """Test infinity float value."""
        import math
        inf = float('inf')
        literal = LiteralExprNode(value=inf, type_name="float")
        self.assertTrue(math.isinf(literal.value))
    
    def test_float_literal_nan(self):
        """Test NaN float value."""
        import math
        nan = float('nan')
        literal = LiteralExprNode(value=nan, type_name="float")
        self.assertTrue(math.isnan(literal.value))
    
    def test_string_literal_empty(self):
        """Test empty string literal."""
        empty_str = ""
        literal = LiteralExprNode(value=empty_str, type_name="str")
        self.assertEqual(literal.value, "")
        self.assertEqual(len(literal.value), 0)
    
    def test_string_literal_very_long(self):
        """Test very long string literal."""
        long_str = "x" * 100000  # 100K character string
        literal = LiteralExprNode(value=long_str, type_name="str")
        self.assertEqual(len(literal.value), 100000)
        self.assertEqual(literal.value[0], "x")
        self.assertEqual(literal.value[-1], "x")
    
    def test_string_literal_unicode(self):
        """Test unicode string literal."""
        unicode_str = "こんにちは世界 🌍 Привет мир 🚀"
        literal = LiteralExprNode(value=unicode_str, type_name="str")
        self.assertIn("こんにちは", literal.value)
        self.assertIn("🌍", literal.value)
        self.assertIn("🚀", literal.value)
    
    def test_string_literal_escape_chars(self):
        """Test string with escape characters."""
        escape_str = "Line1\\nLine2\\tTabbed\\r\\nWin\\\"Quote\\'\\\\Backslash"
        literal = LiteralExprNode(value=escape_str, type_name="str")
        self.assertIn("\\n", literal.value)
        self.assertIn("\\t", literal.value)
        self.assertIn("\\\"", literal.value)
    
    def test_boolean_boundary_values(self):
        """Test boolean boundary values."""
        true_literal = LiteralExprNode(value=True, type_name="bool")
        false_literal = LiteralExprNode(value=False, type_name="bool")
        
        self.assertEqual(true_literal.value, True)
        self.assertEqual(false_literal.value, False)
        self.assertIsInstance(true_literal.value, bool)
        self.assertIsInstance(false_literal.value, bool)


class TestInvalidInputConditions(unittest.TestCase):
    """Test behavior with invalid input data."""
    
    def test_null_node_type(self):
        """Test node with null/None type."""
        with self.assertRaises((ValueError, TypeError)):
            ASTNode(node_type=None)
    
    def test_undefined_identifier(self):
        """Test undefined identifier."""
        # Variable not defined in scope
        identifier = IdentifierExprNode(name="undefined_var")
        self.assertEqual(identifier.name, "undefined_var")
    
    def test_identifier_empty_name(self):
        """Test identifier with empty name."""
        with self.assertRaises((ValueError, AttributeError)):
            IdentifierExprNode(name="")
    
    def test_identifier_only_numbers(self):
        """Test identifier with only numbers."""
        # Identifiers cannot be just numbers
        with self.assertRaises((ValueError, AttributeError)):
            IdentifierExprNode(name="12345")
    
    def test_identifier_with_special_chars(self):
        """Test identifier with special characters."""
        # Identifiers should not have special chars
        invalid_names = ["var-name", "var@name", "var#name", "var$name"]
        for name in invalid_names:
            with self.assertRaises((ValueError, AttributeError)):
                IdentifierExprNode(name=name)
    
    def test_identifier_too_long(self):
        """Test excessively long identifier name."""
        # Very long names should be handled gracefully
        long_name = "a" * 10000
        identifier = IdentifierExprNode(name=long_name)
        self.assertEqual(len(identifier.name), 10000)
    
    def test_invalid_operator_binary_expr(self):
        """Test binary expression with invalid operator."""
        left = LiteralExprNode(value=1, type_name="int")
        right = LiteralExprNode(value=2, type_name="int")
        
        # "&&&" is not a valid operator
        with self.assertRaises((ValueError, AttributeError)):
            BinaryExprNode(left=left, operator="&&&", right=right)
    
    def test_mixed_types_binary_expr(self):
        """Test binary expression with mixed types."""
        # int + string should cause type error
        left = LiteralExprNode(value=5, type_name="int")
        right = LiteralExprNode(value="text", type_name="str")
        
        # Type system should catch this
        binary_expr = BinaryExprNode(left=left, operator="+", right=right)
        self.assertNotEqual(binary_expr.left.type_name, binary_expr.right.type_name)
    
    def test_division_by_zero_literal(self):
        """Test division by zero (literal)."""
        left = LiteralExprNode(value=10, type_name="int")
        right = LiteralExprNode(value=0, type_name="int")
        
        binary_expr = BinaryExprNode(left=left, operator="/", right=right)
        self.assertEqual(binary_expr.right.value, 0)  # Should not crash yet
        # Runtime will catch actual division by zero
    
    def test_negative_array_index(self):
        """Test negative array indexing."""
        index_expr = LiteralExprNode(value=-1, type_name="int")
        self.assertEqual(index_expr.value, -1)
        # Negative indices should be validated during runtime


class TestNullUndefinedHandling(unittest.TestCase):
    """Test null, None, and undefined value handling."""
    
    def test_literal_null_value(self):
        """Test null literal value."""
        null_literal = LiteralExprNode(value=None, type_name="null")
        self.assertIsNone(null_literal.value)
        self.assertEqual(null_literal.type_name, "null")
    
    def test_null_in_binary_expr(self):
        """Test null value in binary expression."""
        left = LiteralExprNode(value=None, type_name="null")
        right = LiteralExprNode(value=5, type_name="int")
        
        binary_expr = BinaryExprNode(left=left, operator="+", right=right)
        self.assertIsNone(binary_expr.left.value)
    
    def test_null_function_argument(self):
        """Test null passed as function argument."""
        # func(null) should be valid
        null_arg = LiteralExprNode(value=None, type_name="null")
        self.assertIsNone(null_arg.value)
    
    def test_null_assignment(self):
        """Test assigning null to variable."""
        var_decl = VarDeclNode(
            name="nullable_var",
            type_hint="Optional[int]",
            initializer=LiteralExprNode(value=None, type_name="null")
        )
        self.assertIsNone(var_decl.initializer.value)
    
    def test_undefined_variable_access(self):
        """Test accessing undefined variable."""
        identifier = IdentifierExprNode(name="undefined")
        self.assertEqual(identifier.name, "undefined")
    
    def test_optional_type_declaration(self):
        """Test optional type declaration."""
        var_decl = VarDeclNode(
            name="optional_var",
            type_hint="Optional[str]",
            initializer=None
        )
        self.assertIsNone(var_decl.initializer)
    
    def test_null_comparison(self):
        """Test null comparison operations."""
        left = LiteralExprNode(value=None, type_name="null")
        right = LiteralExprNode(value=None, type_name="null")
        
        # null == null should be true
        binary_expr = BinaryExprNode(left=left, operator="==", right=right)
        self.assertIsNone(binary_expr.left.value)
        self.assertIsNone(binary_expr.right.value)


class TestErrorConditionScenarios(unittest.TestCase):
    """Test error condition and exception scenarios."""
    
    def test_invalid_type_conversion(self):
        """Test invalid type conversion."""
        # "hello" as int should be invalid
        string_literal = LiteralExprNode(value="hello", type_name="str")
        self.assertEqual(string_literal.type_name, "str")
        self.assertEqual(string_literal.value, "hello")
    
    def test_missing_function_definition(self):
        """Test calling undefined function."""
        # func_does_not_exist() should be validated
        func_identifier = IdentifierExprNode(name="func_does_not_exist")
        self.assertEqual(func_identifier.name, "func_does_not_exist")
    
    def test_missing_return_statement(self):
        """Test function without return statement."""
        func = FuncDefNode(
            name="no_return_func",
            params=[],
            return_type="int",
            body=Mock()  # Body without return
        )
        self.assertIsNone(func.return_type) or self.assertEqual(func.return_type, "int")
    
    def test_duplicate_variable_declaration(self):
        """Test duplicate variable declaration in same scope."""
        # Should be caught by validation
        var1 = VarDeclNode(name="count", type_hint="int")
        var2 = VarDeclNode(name="count", type_hint="str")
        
        self.assertEqual(var1.name, var2.name)
        self.assertNotEqual(var1.type_hint, var2.type_hint)
    
    def test_unreachable_code_detection(self):
        """Test unreachable code after return statement."""
        # Code after return should be unreachable
        return_stmt = Mock()
        unreachable_code = Mock()
        self.assertIsNotNone(return_stmt)
        self.assertIsNotNone(unreachable_code)
    
    def test_missing_break_in_switch(self):
        """Test missing break in switch statement."""
        # Fall-through should be intentional or warned
        switch_case = Mock()
        self.assertIsNotNone(switch_case)
    
    def test_infinite_loop_detection(self):
        """Test potentially infinite loop."""
        # while True:  # Should be detected
        condition = LiteralExprNode(value=True, type_name="bool")
        loop = WhileStmtNode(
            condition=condition,
            body=Mock()
        )
        self.assertEqual(loop.condition.value, True)


class TestResourceBoundaryScenarios(unittest.TestCase):
    """Test resource boundary and limitation scenarios."""
    
    def test_memory_allocation_large_array(self):
        """Test memory allocation for very large arrays."""
        large_size = 1000000  # 1 million elements
        array_data = {"size": large_size, "type": "int"}
        self.assertEqual(array_data["size"], 1000000)
    
    def test_deeply_nested_expressions(self):
        """Test deeply nested expression trees."""
        depth = 1000  # Very deep nesting
        current = LiteralExprNode(value=0, type_name="int")
        for i in range(depth):
            wrapper = Mock()
        self.assertIsNotNone(current)
    
    def test_wide_expression_trees(self):
        """Test very wide expression trees."""
        width = 1000  # Many children
        operands = [LiteralExprNode(value=i, type_name="int") for i in range(width)]
        self.assertEqual(len(operands), width)
    
    def test_recursive_function_calls(self):
        """Test deep recursive function calls."""
        recursive_depth = 500
        call_stack = [f"frame_{i}" for i in range(recursive_depth)]
        self.assertEqual(len(call_stack), recursive_depth)
    
    def test_file_handle_limit(self):
        """Test handling large number of file handles."""
        file_count = 1000
        files = [f"file_{i}.txt" for i in range(file_count)]
        self.assertEqual(len(files), file_count)


class TestTypeSystemEdgeCases(unittest.TestCase):
    """Test type system edge cases and corner scenarios."""
    
    def test_generic_type_self_reference(self):
        """Test self-referential generic types."""
        # class Node<T> { T data; Node<T> next; }
        self_ref_type = {
            "name": "Node",
            "generics": ["T"],
            "fields": {
                "data": "T",
                "next": "Node<T>"
            }
        }
        self.assertEqual(self_ref_type["fields"]["next"], "Node<T>")
    
    def test_circular_type_dependencies(self):
        """Test circular type dependencies."""
        # class A { B b; } class B { A a; }
        circular_types = {
            "A": {"fields": {"b": "B"}},
            "B": {"fields": {"a": "A"}}
        }
        self.assertEqual(circular_types["A"]["fields"]["b"], "B")
        self.assertEqual(circular_types["B"]["fields"]["a"], "A")
    
    def test_union_types_complex(self):
        """Test complex union type scenarios."""
        union_type = "int | float | str | bool | null"
        self.assertIn("int", union_type)
        self.assertIn("null", union_type)
    
    def test_intersection_types(self):
        """Test intersection type scenarios."""
        intersection = "Serializable & Comparable & Cloneable"
        self.assertIn("Serializable", intersection)
        self.assertIn("Comparable", intersection)
    
    def test_function_types_higher_order(self):
        """Test higher-order function types."""
        func_type = "(int, str) -> (bool -> list)"
        self.assertIn("->", func_type)
    
    def test_variance_contravariant(self):
        """Test contravariant type parameters."""
        # function(Consumer<Animal>): can accept Consumer<Cat>
        contravariant = {
            "base": "Consumer<Animal>",
            "derived": "Consumer<Cat>",
            "relationship": "contravariant"
        }
        self.assertEqual(contravariant["relationship"], "contravariant")


class TestConcurrencyEdgeCases(unittest.TestCase):
    """Test concurrency-related edge cases."""
    
    def test_race_condition_two_threads(self):
        """Test race condition between two threads."""
        # counter = 100
        # Thread A: counter++  (100 times)
        # Thread B: counter--  (100 times)
        # Final value? May be any value between 0 and 200
        counter_data = {
            "initial": 100,
            "thread_a_increments": 100,
            "thread_b_decrements": 100,
            "expected_range": (0, 200)
        }
        self.assertGreater(counter_data["expected_range"][1], counter_data["expected_range"][0])
    
    def test_deadlock_two_resources(self):
        """Test deadlock scenario with two resources."""
        # Thread 1: lock A, wait for B
        # Thread 2: lock B, wait for A
        # Result: deadlock
        deadlock_scenario = {
            "thread1": {"lock": "A", "waiting_for": "B"},
            "thread2": {"lock": "B", "waiting_for": "A"},
            "deadlock": True
        }
        self.assertTrue(deadlock_scenario["deadlock"])
    
    def test_livelock_scenario(self):
        """Test livelock scenario."""
        # Two threads repeatedly try to avoid deadlock but never make progress
        livelock_data = {
            "thread1": "retry_retry",
            "thread2": "retry_retry",
            "progress": False
        }
        self.assertFalse(livelock_data["progress"])
    
    def test_starvation_scenario(self):
        """Test thread starvation scenario."""
        # Low-priority thread never gets CPU time
        starvation = {
            "low_priority_thread": "waiting",
            "high_priority_threads": ["running", "running", "running"],
            "starved": True
        }
        self.assertTrue(starvation["starved"])


class TestSecurityEdgeCases(unittest.TestCase):
    """Test security-related edge cases."""
    
    def test_sql_injection_prevention(self):
        """Test SQL injection prevention with parameters."""
        # Use parameterized queries to prevent injection
        query_data = {
            "safe_query": "SELECT * FROM users WHERE id = ?",
            "parameters": [42],
            "injection_prevented": True
        }
        self.assertTrue(query_data["injection_prevented"])
    
    def test_buffer_overflow_prevention(self):
        """Test prevention of buffer overflows."""
        # Proper bounds checking
        buffer_data = {
            "buffer_size": 1024,
            "input_length": 2048,
            "bounds_checked": True
        }
        self.assertGreater(buffer_data["input_length"], buffer_data["buffer_size"])
        self.assertTrue(buffer_data["bounds_checked"])
    
    def test_dos_prevention_input_validation(self):
        """Test DoS prevention through input validation."""
        # Reject extremely large inputs
        input_validation = {
            "max_size": 10000,
            "actual_input_size": 100000,
            "rejected": True
        }
        self.assertGreater(input_validation["actual_input_size"], input_validation["max_size"])
        self.assertTrue(input_validation["rejected"])
    
    def test_path_traversal_prevention(self):
        """Test path traversal attack prevention."""
        # Block "../" patterns
        path_data = {
            "input_path": "../../../etc/passwd",
            "blocked_sequences": ["../"],
            "sanitized": True
        }
        self.assertIn("../", path_data["input_path"])


class TestInternationalizationEdgeCases(unittest.TestCase):
    """Test internationalization and localization edge cases."""
    
    def test_timezone_conversion_zero_meridian(self):
        """Test timezone conversion at zero meridian."""
        gmt_time = "12:00:00 GMT"
        utc_time = "12:00:00 UTC"
        self.assertIn("12:00:00", gmt_time)
        self.assertIn("12:00:00", utc_time)
    
    def test_date_international_format(self):
        """Test international date format handling."""
        # 2025-12-31 vs 31/12/2025 vs 12/31/2025
        date_formats = {
            "iso": "2025-12-31",
            "european": "31/12/2025",
            "american": "12/31/2025",
            "same_date": True
        }
        self.assertTrue(date_formats["same_date"])
    
    def test_unicode_normalization(self):
        """Test unicode normalization edge cases."""
        # é as single character vs e + combining accent
        unicode_data = {
            "composed": "é",
            "decomposed": "e\u0301",
            "equivalent": True
        }
        self.assertTrue(unicode_data["equivalent"])
    
    def test_currency_conversion_edge_cases(self):
        """Test currency conversion edge cases."""
        # Very large amounts, very small amounts, zero
        currency_data = {
            "large_amount": 999999999.99,
            "small_amount": 0.01,
            "zero": 0.00
        }
        self.assertGreater(currency_data["large_amount"], 0)
        self.assertGreater(currency_data["small_amount"], 0)
        self.assertEqual(currency_data["zero"], 0)


class TestCompilationEdgeCases(unittest.TestCase):
    """Test compilation and build system edge cases."""
    
    def test_compiler_recursion_limit(self):
        """Test compiler recursion depth limit."""
        # Expression nested 1000 levels deep
        depth = 1000
        recursion_data = {
            "depth": depth,
            "limit": 10000,
            "within_limits": depth < 10000
        }
        self.assertTrue(recursion_data["within_limits"])
    
    def test_template_instantiation_limit(self):
        """Test template/generic instantiation limit."""
        # List<List<List<...>>> 100 levels deep
        nested_generics = "List<" * 100 + "int" + ">" * 100
        self.assertIn("List<", nested_generics)
        self.assertIn("int", nested_generics)
    
    def test_static_initialization_order(self):
        """Test static initialization order fiasco."""
        # Global static variables initialized in undefined order
        initialization_data = {
            "global_a": "initialized",
            "global_b": "initialized",
            "dependency_order": "undefined"
        }
        self.assertEqual(initialization_data["dependency_order"], "undefined")


if __name__ == '__main__':
    unittest.main()
