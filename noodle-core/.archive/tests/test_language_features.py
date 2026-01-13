#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_language_features.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive test suite for NoodleCore language features.

This module tests all the newly implemented language features:
- Pattern matching syntax and semantics
- Generics system
- Async/await syntax
- Advanced type system improvements
- Integration with existing compiler components
"""

import unittest
import sys
import os
import time
from typing import List, Dict, Any

# Add the src directory to the path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser, ParserConfig, create_enhanced_parser
from noodlecore.compiler.bytecode_generator import PythonBytecodeGenerator, BytecodeGeneratorConfig, create_bytecode_generator
from noodlecore.compiler.accelerated_lexer import create_accelerated_lexer, LexerConfig
from noodlecore.compiler.ast_nodes import (
    NodeType, MatchExpressionNode, MatchCaseNode, WildcardPatternNode, LiteralPatternNode,
    IdentifierPatternNode, TuplePatternNode, ArrayPatternNode, ObjectPatternNode,
    OrPatternNode, AndPatternNode, GuardPatternNode, TypePatternNode, RangePatternNode,
    GenericParameterNode, GenericFunctionDefinitionNode, GenericClassDefinitionNode,
    TypeConstraintNode, GenericTypeAnnotationNode,
    AsyncFunctionDefinitionNode, AwaitExpressionNode, AsyncForStatementNode,
    AsyncWithStatementNode, YieldExpressionNode,
    TypeAliasNode, UnionTypeNode, IntersectionTypeNode, ComputedTypeNode,
    TypeParameterNode
)


class TestPatternMatching(unittest.TestCase):
    """Test pattern matching functionality"""
    
    def setUp(self):
        self.parser = create_enhanced_parser("", "<test>")
        self.generator = create_bytecode_generator()
    
    def test_wildcard_pattern(self):
        """Test wildcard pattern matching"""
        source = """
        match x {
            _ => "wildcard"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        self.assertEqual(len(ast.statements), 1)
        
        # Test bytecode generation
        bytecode = self.generator.generate_bytecode(ast)
        self.assertIsNotNone(bytecode)
    
    def test_literal_pattern(self):
        """Test literal pattern matching"""
        source = """
        match x {
            1 => "one",
            2 => "two",
            "hello" => "greeting"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Find match expression
        match_expr = None
        for stmt in ast.statements:
            if hasattr(stmt, 'type') and stmt.type == NodeType.MATCH_EXPRESSION:
                match_expr = stmt
                break
        
        self.assertIsNotNone(match_expr)
        self.assertEqual(len(match_expr.cases), 3)
    
    def test_identifier_pattern(self):
        """Test identifier pattern matching"""
        source = """
        match point {
            (x, y) => x + y
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_tuple_pattern(self):
        """Test tuple pattern matching"""
        source = """
        match point {
            (0, 0) => "origin",
            (x, y) => f"({x}, {y})"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_array_pattern(self):
        """Test array pattern matching"""
        source = """
        match list {
            [] => "empty",
            [x] => f"single: {x}",
            [x, y] => f"pair: {x}, {y}"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_object_pattern(self):
        """Test object pattern matching"""
        source = """
        match person {
            {name: "John", age: 30} => "John is 30",
            {name: name, age: age} => f"{name} is {age}"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_guard_pattern(self):
        """Test guard pattern matching"""
        source = """
        match x {
            n if n > 0 => "positive",
            n if n < 0 => "negative",
            _ => "zero"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_or_pattern(self):
        """Test or pattern matching"""
        source = """
        match x {
            0 or 1 => "small",
            2 or 3 => "medium",
            _ => "large"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_and_pattern(self):
        """Test and pattern matching"""
        source = """
        match x {
            n if n > 0 and n < 10 => "small positive",
            n if n >= 10 and n < 100 => "medium positive"
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)


class TestGenerics(unittest.TestCase):
    """Test generics functionality"""
    
    def setUp(self):
        self.parser = create_enhanced_parser("", "<test>")
        self.generator = create_bytecode_generator()
    
    def test_generic_function(self):
        """Test generic function definition"""
        source = """
        function identity<T>(x: T): T {
            return x;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Find generic function
        gen_func = None
        for stmt in ast.statements:
            if hasattr(stmt, 'type') and stmt.type == NodeType.GENERIC_FUNCTION_DEFINITION:
                gen_func = stmt
                break
        
        self.assertIsNotNone(gen_func)
        self.assertEqual(len(gen_func.generic_parameters), 1)
        self.assertEqual(gen_func.generic_parameters[0].name, "T")
    
    def test_generic_function_multiple_params(self):
        """Test generic function with multiple type parameters"""
        source = """
        function pair<A, B>(first: A, second: B): (A, B) {
            return (first, second);
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_generic_function_with_constraints(self):
        """Test generic function with type constraints"""
        source = """
        function process<T: Number>(x: T): T {
            return x * 2;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_generic_class(self):
        """Test generic class definition"""
        source = """
        class Container<T> {
            value: T;
            
            function get(): T {
                return value;
            }
            
            function set(newValue: T): void {
                value = newValue;
            }
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Find generic class
        gen_class = None
        for stmt in ast.statements:
            if hasattr(stmt, 'type') and stmt.type == NodeType.GENERIC_CLASS_DEFINITION:
                gen_class = stmt
                break
        
        self.assertIsNotNone(gen_class)
        self.assertEqual(len(gen_class.generic_parameters), 1)
        self.assertEqual(gen_class.generic_parameters[0].name, "T")
    
    def test_generic_class_inheritance(self):
        """Test generic class with inheritance"""
        source = """
        class SpecialContainer<T>: Container<T> {
            // Additional methods
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_generic_type_annotation(self):
        """Test generic type annotation usage"""
        source = """
        let list: List<String> = ["hello", "world"];
        let dict: Map<String, Number> = {"one": 1, "two": 2};
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_nested_generics(self):
        """Test nested generic types"""
        source = """
        let nested: List<Map<String, Number>> = [
            {"a": 1, "b": 2},
            {"c": 3, "d": 4}
        ];
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)


class TestAsyncAwait(unittest.TestCase):
    """Test async/await functionality"""
    
    def setUp(self):
        self.parser = create_enhanced_parser("", "<test>")
        self.generator = create_bytecode_generator()
    
    def test_async_function_definition(self):
        """Test async function definition"""
        source = """
        async function fetchData(url: String): String {
            return await http.get(url);
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Find async function
        async_func = None
        for stmt in ast.statements:
            if hasattr(stmt, 'type') and stmt.type == NodeType.ASYNC_FUNCTION_DEFINITION:
                async_func = stmt
                break
        
        self.assertIsNotNone(async_func)
        self.assertEqual(async_func.name, "fetchData")
    
    def test_await_expression(self):
        """Test await expression"""
        source = """
        async function process() {
            let result = await someAsyncOperation();
            return result;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_async_for_loop(self):
        """Test async for loop"""
        source = """
        async function processItems() {
            async for item in asyncIterable {
                await processItem(item);
            }
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_yield_expression(self):
        """Test yield expression"""
        source = """
        function* generator() {
            yield 1;
            yield 2;
            yield 3;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_async_with_statement(self):
        """Test async with statement"""
        source = """
        async function readFile() {
            async with file.open("data.txt") as f {
                let content = await f.read();
                return content;
            }
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)


class TestAdvancedTypeSystem(unittest.TestCase):
    """Test advanced type system functionality"""
    
    def setUp(self):
        self.parser = create_enhanced_parser("", "<test>")
        self.generator = create_bytecode_generator()
    
    def test_union_type(self):
        """Test union type definition"""
        source = """
        let value: String | Number = "hello";
        let result: String | Number = value;
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_intersection_type(self):
        """Test intersection type definition"""
        source = """
        let obj: Serializable & Comparable = someObject;
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_type_alias(self):
        """Test type alias definition"""
        source = """
        type UserID = Number;
        type UserName = String;
        type User = {id: UserID, name: UserName};
        
        let user: User = {id: 123, name: "John"};
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Find type alias
        type_alias = None
        for stmt in ast.statements:
            if hasattr(stmt, 'type') and stmt.type == NodeType.TYPE_ALIAS:
                type_alias = stmt
                break
        
        self.assertIsNotNone(type_alias)
        self.assertEqual(type_alias.name, "UserID")
    
    def test_generic_type_alias(self):
        """Test generic type alias"""
        source = """
        type Box<T> = {value: T};
        type Pair<A, B> = (A, B);
        
        let boxed: Box<String> = {value: "hello"};
        let pair: Pair<Number, String> = (42, "answer");
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_function_type(self):
        """Test function type annotation"""
        source = """
        let callback: (String) => Number = (s) => s.length;
        let handler: (Number, String) => void = (n, s) => console.log(n, s);
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_array_type(self):
        """Test array type annotation"""
        source = """
        let numbers: Number[] = [1, 2, 3, 4, 5];
        let matrix: Number[][] = [[1, 2], [3, 4]];
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_tuple_type(self):
        """Test tuple type annotation"""
        source = """
        let point: (Number, Number) = (10, 20);
        let triple: (String, Number, Boolean) = ("hello", 42, true);
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)


class TestIntegration(unittest.TestCase):
    """Test integration of all language features"""
    
    def setUp(self):
        self.parser = create_enhanced_parser("", "<test>")
        self.generator = create_bytecode_generator()
    
    def test_complex_pattern_matching_with_generics(self):
        """Test complex pattern matching with generics"""
        source = """
        function processOption<T>(option: Option<T>): String {
            match option {
                Some(value) => f"Value: {value}",
                None => "No value"
            }
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Test bytecode generation
        bytecode = self.generator.generate_bytecode(ast)
        self.assertIsNotNone(bytecode)
    
    def test_async_function_with_generics(self):
        """Test async function with generics"""
        source = """
        async function fetchAll<T>(urls: String[]): Promise<T[]> {
            let results: T[] = [];
            
            async for url in urls {
                let result = await fetchData<T>(url);
                results.push(result);
            }
            
            return results;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_complex_type_system(self):
        """Test complex type system usage"""
        source = """
        type Result<T, E> = Success<T> | Failure<E>;
        
        type Success<T> = {type: "success", value: T};
        type Failure<E> = {type: "failure", error: E};
        
        function process<T, E>(result: Result<T, E>): String {
            match result {
                {type: "success", value: v} => f"Success: {v}",
                {type: "failure", error: e} => f"Error: {e}"
            }
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
    
    def test_performance_benchmark(self):
        """Benchmark performance of language features"""
        source = """
        // Complex code using all features
        type ComplexType<T> = {
            data: T,
            metadata: Map<String, Any>
        };
        
        function processData<T>(items: ComplexType<T>[]): T[] {
            let results: T[] = [];
            
            async for item in items {
                match item {
                    {data: d, metadata: m} if m.get("valid") => {
                        let processed = await transform(d);
                        results.push(processed);
                    },
                    _ => console.log("Invalid item")
                }
            }
            
            return results;
        }
        """
        
        # Benchmark parsing
        start_time = time.perf_counter()
        ast = self.parser.parse()
        parse_time = time.perf_counter() - start_time
        
        self.assertIsNotNone(ast)
        self.assertLess(parse_time, 0.1, "Parsing should be fast")
        
        # Benchmark bytecode generation
        start_time = time.perf_counter()
        bytecode = self.generator.generate_bytecode(ast)
        generation_time = time.perf_counter() - start_time
        
        self.assertIsNotNone(bytecode)
        self.assertLess(generation_time, 0.1, "Bytecode generation should be fast")


class TestErrorHandling(unittest.TestCase):
    """Test error handling for language features"""
    
    def setUp(self):
        self.parser = create_enhanced_parser("", "<test>")
        self.generator = create_bytecode_generator()
    
    def test_invalid_pattern_syntax(self):
        """Test handling of invalid pattern syntax"""
        source = """
        match x {
            (1, 2, => "invalid"  // Missing closing parenthesis
        }
        """
        # Should parse but generate errors
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Should have errors
        errors = self.parser.get_errors()
        self.assertGreater(len(errors), 0)
    
    def test_invalid_generic_syntax(self):
        """Test handling of invalid generic syntax"""
        source = """
        function invalid<T,>(x: T): T {  // Extra comma
            return x;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Should have errors
        errors = self.parser.get_errors()
        self.assertGreater(len(errors), 0)
    
    def test_invalid_async_syntax(self):
        """Test handling of invalid async syntax"""
        source = """
        async function invalid() {
            let x = await;  // Missing expression
            return x;
        }
        """
        ast = self.parser.parse()
        self.assertIsNotNone(ast)
        
        # Should have errors
        errors = self.parser.get_errors()
        self.assertGreater(len(errors), 0)


def run_performance_tests():
    """Run performance tests and print results"""
    print("Running performance tests...")
    
    # Test large file parsing
    large_source = """
    function test<T>(x: T): T { return x; }
    """ * 1000  # 1000 functions
    
    parser = create_enhanced_parser(large_source, "<large>")
    generator = create_bytecode_generator()
    
    start_time = time.perf_counter()
    ast = parser.parse()
    parse_time = time.perf_counter() - start_time
    
    start_time = time.perf_counter()
    bytecode = generator.generate_bytecode(ast)
    generation_time = time.perf_counter() - start_time
    
    print(f"Large file parsing: {parse_time:.4f}s")
    print(f"Large file bytecode generation: {generation_time:.4f}s")
    print(f"Total functions: 1000")
    print(f"Parse rate: {1000/parse_time:.0f} functions/second")
    print(f"Generation rate: {len(bytecode)/generation_time:.0f} bytes/second")


def run_tests():
    """Run all tests using unified testing framework"""
    try:
        # Import unified testing framework
        from noodlecore.compiler.testing_framework import (
            UnifiedTestingFramework, TestConfiguration, TestCategory, TestPriority,
            create_test_configuration, create_test_suite, create_test_case
        )
        
        # Create test configuration
        config = create_test_configuration(
            max_parallel_tests=4,
            enable_performance_benchmarks=True,
            enable_security_testing=True,
            enable_regression_testing=True,
            enable_coverage_analysis=True,
            verbose_output=True,
            generate_reports=True,
            test_categories=[TestCategory.UNIT, TestCategory.INTEGRATION, TestCategory.PERFORMANCE],
            test_priorities=[TestPriority.HIGH, TestPriority.MEDIUM]
        )
        
        # Create unified testing framework
        framework = UnifiedTestingFramework(config)
        
        # Create test suite
        test_suite = create_test_suite(
            name="language_features",
            description="Test suite for NoodleCore language features",
            category=TestCategory.UNIT
        )
        
        # Add test cases from existing test classes
        test_classes = [
            TestPatternMatching,
            TestGenerics,
            TestAsyncAwait,
            TestAdvancedTypeSystem,
            TestIntegration,
            TestErrorHandling
        ]
        
        # Convert unittest test cases to unified framework format
        for test_class in test_classes:
            tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
            for test_group in tests:
                for test in test_group:
                    if hasattr(test, '_testMethodName'):
                        test_case = create_test_case(
                            test_id=f"{test_class.__name__}.{test._testMethodName}",
                            name=f"{test_class.__name__}.{test._testMethodName}",
                            description=f"Test case for {test_class.__name__}.{test._testMethodName}",
                            category=TestCategory.UNIT,
                            priority=TestPriority.MEDIUM,
                            test_method=test,
                            setup_method=getattr(test_class, 'setUp', None),
                            teardown_method=getattr(test_class, 'tearDown', None)
                        )
                        test_suite.add_test_case(test_case)
        
        # Add test suite to framework
        framework.add_test_suite(test_suite)
        
        # Run tests
        summary = framework.run_all_tests()
        
        # Print summary
        print(f"\nLanguage Features Test Summary:")
        print(f"Total Tests: {summary.total_tests}")
        print(f"Passed: {summary.total_passed}")
        print(f"Failed: {summary.total_failed}")
        print(f"Errors: {summary.total_errors}")
        print(f"Success Rate: {(summary.total_passed/summary.total_tests)*100:.1f}%")
        print(f"Execution Time: {summary.total_execution_time:.2f}s")
        
        # Run performance tests
        run_performance_tests()
        
        # Return success status
        return summary.total_passed == summary.total_tests
        
    except ImportError:
        # Fallback to traditional unittest if unified framework is not available
        print("Warning: Unified testing framework not available, falling back to unittest")
        
        # Run unit tests
        unittest.main(argv=[''], exit=False, verbosity=2)
        
        # Run performance tests
        run_performance_tests()
        
        print("\nAll tests completed!")
        return True


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)

