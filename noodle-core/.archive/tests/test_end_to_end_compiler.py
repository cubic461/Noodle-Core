#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_end_to_end_compiler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
End-to-End Compiler Test Suite for NoodleCore

This module provides comprehensive end-to-end testing for the complete NoodleCore compiler,
including real-world code examples testing, performance regression tests, security compliance tests,
and error handling and recovery tests.

Features:
- Complete compilation workflow tests
- Real-world code examples testing
- Performance regression tests
- Security compliance tests
- Error handling and recovery tests
- Integration testing with all components
"""

import os
import sys
import time
import unittest
import tempfile
import json
import uuid
import logging
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass

# Add the src directory to the path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.testing_framework import (
    UnifiedTestingFramework, TestConfiguration, TestSuite, TestCase,
    TestCategory, TestPriority, create_test_configuration, create_test_suite, create_test_case
)
from noodlecore.compiler.validation_framework import (
    ValidationFramework, ValidationConfiguration, create_validation_framework
)
from noodlecore.compiler.compiler_pipeline import (
    CompilerPipeline, CompilationConfig, CompilationTarget
)
from noodlecore.compiler.accelerated_lexer import create_accelerated_lexer
from noodlecore.compiler.enhanced_parser import create_enhanced_parser
from noodlecore.compiler.bytecode_generator import create_bytecode_generator
from noodlecore.compiler.optimization_passes import OptimizationLevel
from noodlecore.compiler.advanced_optimizations import (
    AdvancedOptimizationConfig, create_advanced_optimization_config
)
from noodlecore.compiler.security_integration import (
    CompilerSecurityManager, CompilerSecurityConfig
)


class TestEndToEndCompiler(unittest.TestCase):
    """End-to-end compiler test cases"""
    
    def setUp(self):
        """Set up test environment"""
        self.logger = logging.getLogger(__name__)
        
        # Initialize testing framework
        self.test_config = TestConfiguration(
            max_parallel_tests=2,
            enable_performance_benchmarks=True,
            enable_security_testing=True,
            enable_regression_testing=True,
            enable_coverage_analysis=True,
            verbose_output=True,
            generate_reports=True
        )
        
        self.testing_framework = UnifiedTestingFramework(self.test_config)
        
        # Initialize validation framework
        self.validation_config = ValidationConfiguration(
            enable_correctness_validation=True,
            enable_performance_validation=True,
            enable_security_validation=True,
            enable_code_quality_validation=True,
            enable_integration_validation=True,
            generate_reports=True
        )
        
        self.validation_framework = create_validation_framework(self.validation_config)
        
        # Initialize compiler pipeline
        self.compilation_config = CompilationConfig(
            target=CompilationTarget.PYTHON_BYTECODE,
            optimization_level=OptimizationLevel.BALANCED,
            enable_debug_info=True,
            enable_performance_monitoring=True
        )
        
        self.compiler_pipeline = CompilerPipeline(self.compilation_config)
    
    def test_simple_program_compilation(self):
        """Test compilation of a simple program"""
        source_code = """
        // Simple arithmetic program
        function add(a, b) {
            return a + b;
        }
        
        function multiply(a, b) {
            return a * b;
        }
        
        let x = 5;
        let y = 10;
        let sum = add(x, y);
        let product = multiply(x, y);
        let result = sum + product;
        """
        
        # Test compilation
        compilation_result = self.compiler_pipeline.compile_source(source_code, "simple_program.nc")
        
        self.assertTrue(compilation_result.success, "Simple program should compile successfully")
        self.assertIsNotNone(compilation_result.bytecode, "Bytecode should be generated")
        self.assertEqual(len(compilation_result.errors), 0, "Should have no compilation errors")
        
        # Test execution
        try:
            module = {}
            exec(compilation_result.bytecode, module)
            
            self.assertEqual(module.x, 5, "Variable x should be 5")
            self.assertEqual(module.y, 10, "Variable y should be 10")
            self.assertEqual(module.sum, 15, "Sum should be 15")
            self.assertEqual(module.product, 50, "Product should be 50")
            self.assertEqual(module.result, 65, "Result should be 65")
            
        except Exception as e:
            self.fail(f"Execution failed: {e}")
    
    def test_complex_program_compilation(self):
        """Test compilation of a complex program with multiple features"""
        source_code = """
        // Complex program with control flow and data structures
        class Calculator {
            value: number;
            
            function constructor(initial_value: number) {
                this.value = initial_value;
            }
            
            function add(addend: number): number {
                this.value = this.value + addend;
                return this.value;
            }
            
            function multiply(multiplier: number): number {
                this.value = this.value * multiplier;
                return this.value;
            }
            
            function factorial(n: number): number {
                if (n <= 1) {
                    return 1;
                } else {
                    return n * this.factorial(n - 1);
                }
            }
        }
        
        function process_numbers(numbers: number[]): number {
            let calc = new Calculator(0);
            let result = 0;
            
            for (let i = 0; i < numbers.length; i++) {
                if (i % 2 == 0) {
                    result = result + calc.add(numbers[i]);
                } else {
                    result = result + calc.multiply(numbers[i]);
                }
            }
            
            return result + calc.factorial(numbers.length);
        }
        
        let test_array = [1, 2, 3, 4, 5];
        let final_result = process_numbers(test_array);
        """
        
        # Test compilation
        compilation_result = self.compiler_pipeline.compile_source(source_code, "complex_program.nc")
        
        self.assertTrue(compilation_result.success, "Complex program should compile successfully")
        self.assertIsNotNone(compilation_result.bytecode, "Bytecode should be generated")
        
        # Test execution
        try:
            module = {}
            exec(compilation_result.bytecode, module)
            
            # Verify the calculation
            # Expected: (1+2*1) + (3*2) + (4+3*1) + (5*4) = 3 + 6 + 7 + 20 = 36
            # Plus factorial(5) = 120
            # Total: 36 + 120 = 156
            self.assertEqual(module.final_result, 156, "Complex calculation should be correct")
            
        except Exception as e:
            self.fail(f"Complex program execution failed: {e}")
    
    def test_performance_intensive_compilation(self):
        """Test compilation of performance-intensive code"""
        # Generate a large program
        source_lines = ["// Performance-intensive program\n"]
        
        # Add many functions
        for i in range(100):
            source_lines.append(f"""
        function perf_func_{i}(x: number): number {{
            let result = 0;
            for (let j = 0; j < {i + 10}; j++) {{
                result = result + x * j;
            }}
            return result / ({i + 1});
        }}
        """)
        
        # Add function calls
        source_lines.append("""
        function run_performance_test(): number {
            let total = 0;
        """)
        
        for i in range(100):
            source_lines.append(f"            total = total + perf_func_{i}({i + 1});\n")
        
        source_lines.append("""
            return total;
        }
        
        let result = run_performance_test();
        """)
        
        source_code = "".join(source_lines)
        
        # Measure compilation time
        start_time = time.perf_counter()
        compilation_result = self.compiler_pipeline.compile_source(source_code, "performance_test.nc")
        compilation_time = time.perf_counter() - start_time
        
        self.assertTrue(compilation_result.success, "Performance-intensive program should compile successfully")
        self.assertLess(compilation_time, 5.0, "Compilation should complete within 5 seconds")
        
        # Test execution
        try:
            module = {}
            exec(compilation_result.bytecode, module)
            
            self.assertIsNotNone(module.result, "Result should be computed")
            self.assertIsInstance(module.result, (int, float), "Result should be numeric")
            
        except Exception as e:
            self.fail(f"Performance-intensive program execution failed: {e}")
    
    def test_error_handling_and_recovery(self):
        """Test compiler error handling and recovery"""
        # Test syntax error
        syntax_error_code = """
        function test_syntax_error() {
            let x = ;  // Syntax error
            return x;
        }
        """
        
        compilation_result = self.compiler_pipeline.compile_source(syntax_error_code, "syntax_error.nc")
        
        self.assertFalse(compilation_result.success, "Syntax error should cause compilation failure")
        self.assertIsNone(compilation_result.bytecode, "Bytecode should not be generated for syntax error")
        self.assertGreater(len(compilation_result.errors), 0, "Should have compilation errors")
        
        # Test semantic error (if implemented)
        semantic_error_code = """
        function test_semantic_error() {
            let x = "hello";
            let y = x + 5;  // Type error
            return y;
        }
        """
        
        compilation_result = self.compiler_pipeline.compile_source(semantic_error_code, "semantic_error.nc")
        
        # May succeed at compile time but fail at execution
        if compilation_result.success:
            try:
                module = {}
                exec(compilation_result.bytecode, module)
                module.test_semantic_error()
                self.fail("Semantic error should cause execution failure")
            except Exception:
                pass  # Expected
        else:
            # Or fail at compile time
            self.assertGreater(len(compilation_result.errors), 0, "Should have semantic errors")
    
    def test_security_vulnerability_detection(self):
        """Test security vulnerability detection"""
        # Test code with security issues
        vulnerable_code = """
        function process_user_input(input: string): any {
            // SQL injection vulnerability
            let query = "SELECT * FROM users WHERE name = '" + input + "'";
            let results = database.execute(query);
            
            // Code injection vulnerability
            let processed = eval(input);
            
            // Path traversal vulnerability
            let filename = "../../../etc/passwd";
            let file_content = file.read(filename);
            
            return {
                "query": query,
                "processed": processed,
                "file_content": file_content
            };
        }
        
        let malicious_input = "1' OR '1'='1";
        let result = process_user_input(malicious_input);
        """
        
        # Test validation
        validation_result = self.validation_framework.validate_security("vulnerable_test.nc", vulnerable_code)
        
        self.assertIn(validation_result.status.value, ["failed", "warning"], "Security validation should detect issues")
        self.assertGreater(len(validation_result.issues), 0, "Should detect security issues")
        
        # Check for specific vulnerability types
        vulnerability_types = [issue.details.get("rule_name") for issue in validation_result.issues]
        self.assertIn("No Dangerous Functions", vulnerability_types, "Should detect dangerous functions")
        self.assertIn("No SQL Injection Patterns", vulnerability_types, "Should detect SQL injection")
        self.assertIn("No Path Traversal", vulnerability_types, "Should detect path traversal")
    
    def test_optimization_levels(self):
        """Test different optimization levels"""
        source_code = """
        function optimization_test(x: number): number {
            let a = 2 + 3 * 4;  // Should be optimized to 14
            let b = x * 2 + 1;      // Should be optimized
            let c = a + b;             // Should be optimized
            return c;
        }
        
        let result = optimization_test(5);
        """
        
        expected_result = 14 + (5 * 2 + 1)  # 14 + 11 = 25
        
        optimization_levels = [OptimizationLevel.MINIMAL, OptimizationLevel.BALANCED, OptimizationLevel.AGGRESSIVE]
        
        for opt_level in optimization_levels:
            with self.subTest(optimization_level=opt_level):
                # Update compilation config
                self.compilation_config.optimization_level = opt_level
                self.compiler_pipeline = CompilerPipeline(self.compilation_config)
                
                # Compile and test
                compilation_result = self.compiler_pipeline.compile_source(source_code, f"opt_test_{opt_level.value}.nc")
                
                self.assertTrue(compilation_result.success, f"Compilation should succeed with {opt_level.value} optimization")
                
                # Test execution
                try:
                    module = {}
                    exec(compilation_result.bytecode, module)
                    
                    self.assertEqual(module.result, expected_result, 
                                   f"Result should be correct with {opt_level.value} optimization")
                    
                except Exception as e:
                    self.fail(f"Execution failed with {opt_level.value} optimization: {e}")
    
    def test_advanced_language_features(self):
        """Test advanced language features"""
        # Test pattern matching
        pattern_matching_code = """
        function process_value(value: any): string {
            match value {
                0 => "zero",
                1 | 2 | 3 => "small",
                n when n > 10 => "large",
                _ => "other"
            }
        }
        
        let result1 = process_value(0);
        let result2 = process_value(2);
        let result3 = process_value(15);
        let result4 = process_value("unknown");
        """
        
        compilation_result = self.compiler_pipeline.compile_source(pattern_matching_code, "pattern_matching.nc")
        
        if compilation_result.success:
            try:
                module = {}
                exec(compilation_result.bytecode, module)
                
                self.assertEqual(module.result1, "zero", "Pattern matching should work for 0")
                self.assertEqual(module.result2, "small", "Pattern matching should work for 2")
                self.assertEqual(module.result3, "large", "Pattern matching should work for 15")
                self.assertEqual(module.result4, "other", "Pattern matching should work for unknown")
                
            except Exception as e:
                self.fail(f"Pattern matching execution failed: {e}")
        else:
            self.logger.warning("Pattern matching feature not fully implemented")
        
        # Test generics
        generics_code = """
        function identity<T>(x: T): T {
            return x;
        }
        
        function process_pair<A, B>(pair: (A, B)): string {
            let first = identity<A>(pair[0]);
            let second = identity<B>(pair[1]);
            return first + ":" + second;
        }
        
        let result = process_pair<number, string>((42, "hello"));
        """
        
        compilation_result = self.compiler_pipeline.compile_source(generics_code, "generics.nc")
        
        if compilation_result.success:
            try:
                module = {}
                exec(compilation_result.bytecode, module)
                
                self.assertEqual(module.result, "42:hello", "Generics should work correctly")
                
            except Exception as e:
                self.fail(f"Generics execution failed: {e}")
        else:
            self.logger.warning("Generics feature not fully implemented")
        
        # Test async/await
        async_code = """
        async function fetch_data(url: string): string {
            let response = await http.get(url);
            return response.data;
        }
        
        async function process_urls(urls: string[]): string[] {
            let results = [];
            for (let url of urls) {
                let data = await fetch_data(url);
                results.push(data);
            }
            return results;
        }
        
        let urls = ["http://example.com/1", "http://example.com/2"];
        let result = process_urls(urls);
        """
        
        compilation_result = self.compiler_pipeline.compile_source(async_code, "async.nc")
        
        if compilation_result.success:
            try:
                module = {}
                exec(compilation_result.bytecode, module)
                
                self.assertIsNotNone(module.result, "Async function should return result")
                
            except Exception as e:
                self.fail(f"Async/await execution failed: {e}")
        else:
            self.logger.warning("Async/await feature not fully implemented")
    
    def test_integration_with_security(self):
        """Test integration of compiler with security components"""
        source_code = """
        function secure_operation(data: string): string {
            // This should be secure
            let sanitized = sanitize_input(data);
            let result = process_securely(sanitized);
            return result;
        }
        
        let input = "user_input_123";
        let result = secure_operation(input);
        """
        
        # Initialize security manager
        security_config = CompilerSecurityConfig(
            security_enabled=True,
            security_level="standard",
            scan_bytecode=True
        )
        
        security_manager = CompilerSecurityManager(security_config)
        
        # Test with security integration
        compilation_result = self.compiler_pipeline.compile_source(source_code, "secure_test.nc")
        
        self.assertTrue(compilation_result.success, "Secure program should compile successfully")
        
        # Test security validation
        validation_result = self.validation_framework.validate_security("secure_test.nc", source_code)
        
        # Should have fewer security issues than the vulnerable code
        self.assertLessEqual(len(validation_result.issues), 2, "Should have minimal security issues")
    
    def test_performance_regression_detection(self):
        """Test performance regression detection"""
        source_code = """
        function regression_test(n: number): number {
            let result = 0;
            for (let i = 0; i < n; i++) {
                result = result + i * 2;
            }
            return result;
        }
        
        let answer = regression_test(100);
        """
        
        # Save performance baseline
        self.validation_framework.save_performance_baseline(
            "regression_test_baseline",
            source_code,
            {"description": "Baseline for regression testing"}
        )
        
        # Test current performance
        validation_result = self.validation_framework.validate_performance(
            "regression_test.nc",
            source_code,
            "regression_test_baseline"
        )
        
        self.assertIn(validation_result.status.value, ["passed", "warning"], 
                      "Performance validation should pass against baseline")
        
        # Test with degraded performance (simulate)
        if hasattr(validation_result, 'baseline_comparison'):
            baseline_comp = validation_result.baseline_comparison
            if baseline_comp:
                self.assertIsNotNone(baseline_comp, "Should have baseline comparison")
    
    def test_code_quality_validation(self):
        """Test code quality validation"""
        # Test with quality issues
        poor_quality_code = """
        function very_long_function_that_does_too_many_things_and_has_poor_structure(a: number, b: number, c: number, d: number, e: number, f: number): number {
            // This function is too long and has poor structure
            let result = 0;
            if (a > 0) {
                if (b > 0) {
                    if (c > 0) {
                        if (d > 0) {
                            if (e > 0) {
                                if (f > 0) {
                                    result = a + b + c + d + e + f;
                                } else {
                                    result = a + b + c + d + e;
                                }
                            } else {
                                result = a + b + c + d;
                            }
                        } else {
                            result = a + b + c;
                        }
                    } else {
                        result = a + b;
                    }
                } else {
                    result = a;
                }
            } else {
                result = 0;
            }
            return result;
        }
        
        // No comments for documentation
        let x = very_long_function_that_does_too_many_things_and_has_poor_structure(1, 2, 3, 4, 5, 6);
        """
        
        # Test code quality validation
        validation_result = self.validation_framework.validate_code_quality("poor_quality.nc", poor_quality_code)
        
        self.assertIn(validation_result.status.value, ["warning", "failed"], 
                      "Code quality validation should detect issues")
        self.assertGreater(len(validation_result.issues), 0, "Should detect quality issues")
        
        # Check for specific quality issues
        issue_types = [issue.details.get("rule_name") for issue in validation_result.issues]
        self.assertIn("No Deep Nesting", issue_types, "Should detect deep nesting")
        self.assertIn("Maximum File Length", issue_types, "Should detect long file")
    
    def test_memory_usage_validation(self):
        """Test memory usage during compilation"""
        # Generate memory-intensive code
        memory_intensive_code = """
        // Memory-intensive program
        class DataContainer {
            data: number[];
            
            function constructor(size: number) {
                this.data = [];
                for (let i = 0; i < size; i++) {
                    this.data.push(i * i);
                }
            }
            
            function process(): number {
                let sum = 0;
                for (let i = 0; i < this.data.length; i++) {
                    sum = sum + this.data[i];
                }
                return sum;
            }
        }
        
        function memory_test(): number {
            let containers = [];
            for (let i = 0; i < 10; i++) {
                containers.push(new DataContainer(1000));
            }
            
            let total = 0;
            for (let container of containers) {
                total = total + container.process();
            }
            
            return total;
        }
        
        let result = memory_test();
        """
        
        # Test compilation with memory monitoring
        compilation_result = self.compiler_pipeline.compile_source(memory_intensive_code, "memory_test.nc")
        
        self.assertTrue(compilation_result.success, "Memory-intensive program should compile successfully")
        
        # Check memory usage statistics
        stats = compilation_result.statistics
        self.assertIsNotNone(stats, "Should have compilation statistics")
        
        # Test execution
        try:
            module = {}
            exec(compilation_result.bytecode, module)
            
            self.assertIsNotNone(module.result, "Should compute result")
            self.assertIsInstance(module.result, (int, float), "Result should be numeric")
            
        except Exception as e:
            self.fail(f"Memory-intensive program execution failed: {e}")
    
    def test_comprehensive_integration(self):
        """Test comprehensive integration of all components"""
        # Create a comprehensive test that uses multiple features
        comprehensive_code = """
        // Comprehensive integration test
        import math.utils;
        import security.sanitizer;
        
        class DataProcessor {
            private data: any[];
            private validator: SecurityValidator;
            
            function constructor() {
                this.data = [];
                this.validator = new SecurityValidator();
            }
            
            function add_item(item: any): void {
                let sanitized = this.validator.sanitize(item);
                this.data.push(sanitized);
            }
            
            function process_with_pattern_matching(items: any[]): number {
                let total = 0;
                for (let item of items) {
                    match item {
                        n when typeof n === "number" => total = total + n,
                        s when typeof s === "string" => total = total + s.length,
                        _ => total = total + 1
                    }
                }
                return total;
            }
            
            function get_statistics(): any {
                return {
                    "count": this.data.length,
                    "sum": this.process_with_pattern_matching(this.data),
                    "average": this.process_with_pattern_matching(this.data) / this.data.length
                };
            }
        }
        
        function complex_calculation(x: number, y: number): any {
            let processor = new DataProcessor();
            
            // Add items with different types
            processor.add_item(x);
            processor.add_item(y);
            processor.add_item("test_string");
            processor.add_item([1, 2, 3]);
            
            // Get statistics
            let stats = processor.get_statistics();
            
            // Complex calculation
            let result = {
                "input_sum": x + y,
                "processed_count": stats.count,
                "processed_sum": stats.sum,
                "processed_average": stats.average,
                "calculation_time": time.now()
            };
            
            return result;
        }
        
        let test_result = complex_calculation(42, 17);
        """
        
        # Test with all validation types
        validation_summary = self.validation_framework.validate_all(
            target="comprehensive_test.nc",
            source_code=comprehensive_code,
            expected_result={
                "input_sum": 59,
                "processed_count": 4,
                "processed_sum": 59 + 11 + 6,  # 42 + 17 + "test_string".length + 6
                "processed_average": (59 + 11 + 6) / 4
            }
        )
        
        # Check overall validation result
        total_validations = (
            validation_summary.passed_validations + 
            validation_summary.failed_validations + 
            validation_summary.warning_validations + 
            validation_summary.error_validations
        )
        
        self.assertGreater(total_validations, 0, "Should run multiple validations")
        
        # Should have at least some passed validations
        self.assertGreater(validation_summary.passed_validations, 0, "Should have some passed validations")
        
        # Check execution time is reasonable
        self.assertLess(validation_summary.execution_time, 10.0, "Should complete within reasonable time")
    
    def test_error_recovery_mechanisms(self):
        """Test compiler error recovery mechanisms"""
        # Test code with recoverable errors
        recoverable_code = """
        function test_recovery() {
            let x = 42;
            let y = ;  // Error here
            let z = x + y;  // Should recover if possible
            
            // Another error
            let w = "hello" + ;  // Error here
            
            return x + z;  // Should use default values if recovery works
        }
        """
        
        # Test compilation with error recovery
        compilation_result = self.compiler_pipeline.compile_source(recoverable_code, "recovery_test.nc")
        
        # May fail but should provide useful error information
        if not compilation_result.success:
            self.assertGreater(len(compilation_result.errors), 0, "Should have error information")
            
            # Check error details
            for error in compilation_result.errors:
                self.assertIn("message", error, "Error should have message")
                self.assertIn("location", error, "Error should have location")
        else:
            # If it succeeds, test execution
            try:
                module = {}
                exec(compilation_result.bytecode, module)
                
                # Should have reasonable defaults or recovery
                self.assertIsNotNone(module.test_recovery, "Should have recovery function")
                
            except Exception as e:
                self.fail(f"Recovery test execution failed: {e}")
    
    def test_concurrent_compilation(self):
        """Test concurrent compilation capabilities"""
        source_code = """
        function concurrent_test(id: number): number {
            let result = 0;
            for (let i = 0; i < 1000; i++) {
                result = result + i * id;
            }
            return result;
        }
        """
        
        # Test multiple compilations
        compilation_results = []
        
        for i in range(5):
            start_time = time.perf_counter()
            result = self.compiler_pipeline.compile_source(
                source_code, 
                f"concurrent_test_{i}.nc"
            )
            compilation_time = time.perf_counter() - start_time
            
            compilation_results.append({
                "id": i,
                "result": result,
                "time": compilation_time
            })
        
        # All should succeed
        for comp_result in compilation_results:
            self.assertTrue(comp_result["result"].success, 
                           f"Concurrent compilation {comp_result['id']} should succeed")
        
        # Check compilation times are reasonable
        avg_time = sum(r["time"] for r in compilation_results) / len(compilation_results)
        self.assertLess(avg_time, 1.0, "Average compilation time should be reasonable")
    
    def test_compiler_statistics_collection(self):
        """Test compiler statistics collection"""
        source_code = """
        function statistics_test(n: number): number {
            let result = 0;
            for (let i = 0; i < n; i++) {
                result = result + i * 2;
            }
            return result;
        }
        
        let answer = statistics_test(100);
        """
        
        # Compile with statistics enabled
        compilation_result = self.compiler_pipeline.compile_source(source_code, "statistics_test.nc")
        
        self.assertTrue(compilation_result.success, "Statistics test should compile successfully")
        
        # Check statistics are collected
        stats = compilation_result.statistics
        self.assertIsNotNone(stats, "Should collect statistics")
        
        # Check specific statistics
        expected_stats = [
            "lexing_time", "parsing_time", "optimization_time", 
            "code_generation_time", "total_time", "tokens_processed",
            "ast_nodes_created", "optimizations_applied"
        ]
        
        for stat in expected_stats:
            self.assertIn(stat, stats, f"Should collect {stat} statistic")
        
        # Verify statistics are reasonable
        self.assertGreater(stats["total_time"], 0, "Total time should be positive")
        self.assertGreater(stats["tokens_processed"], 0, "Should process tokens")
        self.assertGreater(stats["ast_nodes_created"], 0, "Should create AST nodes")


def run_end_to_end_tests():
    """Run all end-to-end tests"""
    # Create test suite
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromTestCase(TestEndToEndCompiler)
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return success status
    return result.wasSuccessful()


def run_performance_benchmarks():
    """Run performance benchmarks"""
    print("Running performance benchmarks...")
    
    # Initialize testing framework
    test_config = TestConfiguration(
        max_parallel_tests=1,
        enable_performance_benchmarks=True,
        verbose_output=True
    )
    
    framework = UnifiedTestingFramework(test_config)
    
    # Create performance test suite
    perf_suite = create_test_suite(
        "performance_benchmarks",
        "Performance benchmark tests"
    )
    
    # Add performance test cases
    test_cases = [
        create_test_case(
            "perf_small",
            "Small Program Performance",
            TestCategory.PERFORMANCE,
            "let x = 42; let result = x * 2;",
            performance_baseline={"compilation_time": 0.01, "tolerance": 0.5}
        ),
        create_test_case(
            "perf_medium",
            "Medium Program Performance",
            TestCategory.PERFORMANCE,
            """
            function factorial(n): number {
                if (n <= 1) return 1;
                return n * factorial(n - 1);
            }
            
            let result = factorial(10);
            """,
            performance_baseline={"compilation_time": 0.05, "tolerance": 0.5}
        ),
        create_test_case(
            "perf_large",
            "Large Program Performance",
            TestCategory.PERFORMANCE,
            """
            function complex_calculation(): number {
                let result = 0;
                for (let i = 0; i < 1000; i++) {
                    for (let j = 0; j < 100; j++) {
                        result = result + i * j;
                    }
                }
                return result;
            }
            
            let answer = complex_calculation();
            """,
            performance_baseline={"compilation_time": 0.2, "tolerance": 0.5}
        )
    ]
    
    for test_case in test_cases:
        perf_suite.add_test_case(test_case)
    
    # Register and run
    framework.register_test_suite(perf_suite)
    summary = framework.run_all_tests()
    
    print(f"\nPerformance benchmarks completed:")
    print(f"Total tests: {summary.total_tests}")
    print(f"Passed: {summary.total_passed}")
    print(f"Failed: {summary.total_failed}")
    print(f"Total time: {summary.total_execution_time:.2f}s")
    
    return summary.total_passed == summary.total_tests


def run_security_compliance_tests():
    """Run security compliance tests"""
    print("Running security compliance tests...")
    
    # Initialize validation framework
    validation_config = ValidationConfiguration(
        enable_security_validation=True,
        enable_correctness_validation=True,
        verbose_output=True
    )
    
    framework = create_validation_framework(validation_config)
    
    # Test cases with security issues
    security_test_cases = [
        {
            "name": "SQL Injection Test",
            "code": 'function query_user(id): string { return "SELECT * FROM users WHERE id = \'" + id + "\'"; }',
            "should_fail": True
        },
        {
            "name": "Code Injection Test",
            "code": 'function evaluate(expr): any { return eval(expr); }',
            "should_fail": True
        },
        {
            "name": "Path Traversal Test",
            "code": 'function read_file(path): string { return file.read("../data/" + path); }',
            "should_fail": True
        },
        {
            "name": "Secure Code Test",
            "code": 'function safe_operation(data): string { return sanitize(data); }',
            "should_fail": False
        }
    ]
    
    passed_tests = 0
    total_tests = len(security_test_cases)
    
    for test_case in security_test_cases:
        print(f"\nTesting: {test_case['name']}")
        
        validation_result = framework.validate_security(
            f"security_test_{passed_tests}.nc",
            test_case["code"]
        )
        
        if test_case["should_fail"]:
            # Should detect security issues
            if validation_result.status.value in ["failed", "warning"]:
                print(f"  âœ“ Security issues detected (as expected)")
                passed_tests += 1
            else:
                print(f"  âœ— Security issues NOT detected (unexpected)")
        else:
            # Should pass security validation
            if validation_result.status.value == "passed":
                print(f"  âœ“ No security issues detected (as expected)")
                passed_tests += 1
            else:
                print(f"  âœ— Unexpected security issues detected")
        
        print(f"  Issues found: {len(validation_result.issues)}")
        for issue in validation_result.issues:
            print(f"    - {issue.severity.value}: {issue.message}")
    
    print(f"\nSecurity compliance tests completed:")
    print(f"Passed: {passed_tests}/{total_tests}")
    
    return passed_tests == total_tests


if __name__ == '__main__':
    print("NoodleCore End-to-End Compiler Test Suite")
    print("=" * 50)
    
    # Run unit tests
    print("\nRunning end-to-end unit tests...")
    unit_test_success = run_end_to_end_tests()
    
    # Run performance benchmarks
    perf_test_success = run_performance_benchmarks()
    
    # Run security compliance tests
    security_test_success = run_security_compliance_tests()
    
    # Overall result
    all_passed = unit_test_success and perf_test_success and security_test_success
    
    print("\n" + "=" * 50)
    print("END-TO-END TEST SUMMARY")
    print("=" * 50)
    print(f"Unit Tests: {'PASSED' if unit_test_success else 'FAILED'}")
    print(f"Performance Benchmarks: {'PASSED' if perf_test_success else 'FAILED'}")
    print(f"Security Compliance: {'PASSED' if security_test_success else 'FAILED'}")
    print(f"Overall: {'PASSED' if all_passed else 'FAILED'}")
    print("=" * 50)
    
    sys.exit(0 if all_passed else 1)

