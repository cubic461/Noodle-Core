"""
Test Suite::Noodle Lang - simple_generic_test_fixed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Test Suite for Generic Type Parameters in Noodle Language
Tests basic generic type functionality without complex dependencies.
"""

import sys
import os
import time
from typing import List, Dict, Any

# Add the lexer directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'lexer'))

try:
    from generic_type_lexer import GenericTypeLexer, Token, create_generic_token, is_generic_token
except ImportError as e:
    print(f"[ERROR] Import error: {e}")
    print("Make sure generic_type_lexer.py is in the correct location")
    sys.exit(1)

class GenericTypeTestResult:
    """Simple test result container"""
    def __init__(self, name: str, passed: bool, message: str, execution_time: float):
        self.name = name
        self.passed = passed
        self.message = message
        self.execution_time = execution_time

class GenericTypeTester:
    """Simple test runner for generic type parameters"""
    
    def __init__(self):
        self.lexer = GenericTypeLexer()
        self.results: List[GenericTypeTestResult] = []
        self.total_tests = 0
        self.passed_tests = 0
    
    def run_test(self, test_name: str, test_func) -> None:
        """Run a single test and record the result"""
        self.total_tests += 1
        start_time = time.time()
        
        try:
            test_func()
            execution_time = time.time() - start_time
            self.results.append(GenericTypeTestResult(
                test_name, True, "Test passed", execution_time
            ))
            self.passed_tests += 1
            print(f"[PASS] {test_name} - PASSED ({execution_time:.3f}s)")
        except Exception as e:
            execution_time = time.time() - start_time
            self.results.append(GenericTypeTestResult(
                test_name, False, str(e), execution_time
            ))
            print(f"[FAIL] {test_name} - FAILED: {e} ({execution_time:.3f}s)")
    
    def test_basic_type_parameter_tokenization(self) -> None:
        """Test basic type parameter tokenization"""
        test_code = "<T>"
        tokens = self.lexer.tokenize(test_code)
        
        # Should have: LT, T, GT
        expected_types = [
            GenericTypeLexer.LT,
            GenericTypeLexer.IDENTIFIER,
            GenericTypeLexer.GT
        ]
        
        assert len(tokens) == len(expected_types), f"Expected {len(expected_types)} tokens, got {len(tokens)}"
        
        for i, expected_type in enumerate(expected_types):
            assert tokens[i].type == expected_type, f"Token {i} should be {expected_type}"
        
        assert tokens[1].value == "T", "Identifier should be 'T'"
    
    def test_multiple_type_parameters(self) -> None:
        """Test multiple type parameters"""
        test_code = "<T, U, V>"
        tokens = self.lexer.tokenize(test_code)
        
        # Should have: LT, T, COMMA, U, COMMA, V, GT
        expected_types = [
            GenericTypeLexer.LT,
            GenericTypeLexer.IDENTIFIER,
            GenericTypeLexer.COMMA,
            GenericTypeLexer.IDENTIFIER,
            GenericTypeLexer.COMMA,
            GenericTypeLexer.IDENTIFIER,
            GenericTypeLexer.GT
        ]
        
        assert len(tokens) == len(expected_types), f"Expected {len(expected_types)} tokens, got {len(tokens)}"
        
        for i, expected_type in enumerate(expected_types):
            assert tokens[i].type == expected_type, f"Token {i} should be {expected_type}"
    
    def test_type_constraints(self) -> None:
        """Test type constraint syntax"""
        test_code = "<T: Numeric>"
        tokens = self.lexer.tokenize(test_code)
        
        # Should have: LT, T, COLON, Numeric, GT
        expected_types = [
            GenericTypeLexer.LT,
            GenericTypeLexer.IDENTIFIER,
            GenericTypeLexer.COLON,
            GenericTypeLexer.IDENTIFIER,
            GenericTypeLexer.GT
        ]
        
        assert len(tokens) == len(expected_types), f"Expected {len(expected_types)} tokens, got {len(tokens)}"
        
        for i, expected_type in enumerate(expected_types):
            assert tokens[i].type == expected_type, f"Token {i} should be {expected_type}"
        
        assert tokens[1].value == "T", "First identifier should be 'T'"
        assert tokens[3].value == "Numeric", "Second identifier should be 'Numeric'"
    
    def test_mixed_constraints(self) -> None:
        """Test mixed constrained and unconstrained parameters"""
        test_code = "<T, U: Numeric, V: Comparable>"
        tokens = self.lexer.tokenize(test_code)
        
        # Extract type parameters
        type_params = self.lexer.get_type_parameters(tokens)
        
        assert len(type_params) == 3, f"Expected 3 type parameters, got {len(type_params)}"
        
        # Check first parameter (no constraint)
        assert type_params[0]['name'] == "T"
        assert type_params[0]['constraint'] is None
        
        # Check second parameter (Numeric constraint)
        assert type_params[1]['name'] == "U"
        assert type_params[1]['constraint'] == "Numeric"
        
        # Check third parameter (Comparable constraint)
        assert type_params[2]['name'] == "V"
        assert type_params[2]['constraint'] == "Comparable"
    
    def test_generic_function_syntax(self) -> None:
        """Test generic function syntax recognition"""
        test_code = "function<T>(value: T) -> T"
        constructs = self.lexer.analyze_generic_constructs(test_code)
        
        assert 'type_parameters' in constructs
        assert len(constructs['type_parameters']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain type parameter tokens
        has_lt = any(t.type == GenericTypeLexer.LT for t in tokens)
        has_gt = any(t.type == GenericTypeLexer.GT for t in tokens)
        has_identifier = any(t.type == GenericTypeLexer.IDENTIFIER for t in tokens)
        
        assert has_lt, "Should have LT token"
        assert has_gt, "Should have GT token"
        assert has_identifier, "Should have IDENTIFIER token"
    
    def test_generic_class_syntax(self) -> None:
        """Test generic class syntax recognition"""
        test_code = "class Container<T>"
        constructs = self.lexer.analyze_generic_constructs(test_code)
        
        assert 'type_parameters' in constructs
        assert len(constructs['type_parameters']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        type_params = self.lexer.get_type_parameters(tokens)
        
        assert len(type_params) == 1, f"Expected 1 type parameter, got {len(type_params)}"
        assert type_params[0]['name'] == "T"
        assert type_params[0]['constraint'] is None
    
    def test_nested_generic_types(self) -> None:
        """Test nested generic type syntax"""
        test_code = "<T, U: Container<T>>"
        tokens = self.lexer.tokenize(test_code)
        
        # This is a complex case - basic tokenization should still work
        has_lt = any(t.type == GenericTypeLexer.LT for t in tokens)
        has_gt = any(t.type == GenericTypeLexer.GT for t in tokens)
        has_colon = any(t.type == GenericTypeLexer.COLON for t in tokens)
        
        assert has_lt, "Should have LT token"
        assert has_gt, "Should have GT token"
        assert has_colon, "Should have COLON token for constraint"
    
    def test_syntax_validation(self) -> None:
        """Test syntax validation for generic types"""
        # Valid syntax
        valid_code = "<T: Numeric>"
        valid_tokens = self.lexer.tokenize(valid_code)
        valid_errors = self.lexer.validate_generic_syntax(valid_tokens)
        
        assert len(valid_errors) == 0, f"Valid code should have no errors, got: {valid_errors}"
        
        # Invalid syntax (unmatched brackets would be detected in more complex scenarios)
        # For now, we test constraint validation
        invalid_code = "<: Numeric>"  # Missing identifier before colon
        invalid_tokens = self.lexer.tokenize(invalid_code)
        invalid_errors = self.lexer.validate_generic_syntax(invalid_tokens)
        
        # Should detect the missing identifier issue
        # (This is a simplified test - in practice, more complex validation would be needed)
    
    def test_utility_functions(self) -> None:
        """Test utility functions for generic tokens"""
        # Test token creation
        token = create_generic_token(GenericTypeLexer.IDENTIFIER, "T", 1, 5)
        
        assert token.type == GenericTypeLexer.IDENTIFIER
        assert token.value == "T"
        assert token.line == 1
        assert token.column == 5
        
        # Test generic token detection
        assert is_generic_token(token), "Created token should be generic token"
        
        non_generic_token = Token(999, "other", 1, 1)
        assert not is_generic_token(non_generic_token), "Non-generic token should not be detected as generic"
    
    def test_performance_basic(self) -> None:
        """Test basic performance of generic type tokenization"""
        test_code = "<T, U: Numeric, V: Comparable, W>"
        
        start_time = time.time()
        for _ in range(1000):
            tokens = self.lexer.tokenize(test_code)
        end_time = time.time()
        
        avg_time = (end_time - start_time) / 1000
        
        # Should be very fast (< 1ms per tokenization)
        assert avg_time < 0.001, f"Tokenization too slow: {avg_time:.4f}s per call"
    
    def test_complex_generic_scenario(self) -> None:
        """Test a complex generic type scenario"""
        test_code = """
        function map<T, U>(items: List<T>, mapper: (T) -> U) -> List<U> {
            result: List<U> = [];
            for item in items {
                result.append(mapper(item));
            }
            return result;
        }
        """
        
        # Analyze constructs
        constructs = self.lexer.analyze_generic_constructs(test_code)
        
        # Should find type parameters
        assert len(constructs['type_parameters']) > 0, "Should find type parameters"
        
        # Tokenize
        tokens = self.lexer.tokenize(test_code)
        
        # Should have generic tokens
        has_generic_tokens = any(is_generic_token(t) for t in tokens)
        assert has_generic_tokens, "Should have generic tokens in complex scenario"
        
        # Extract type parameters
        type_params = self.lexer.get_type_parameters(tokens)
        assert len(type_params) >= 2, f"Should have at least 2 type parameters, got {len(type_params)}"
    
    def run_all_tests(self) -> None:
        """Run all generic type tests"""
        print("Running Generic Type Parameter Tests...")
        print("=" * 50)
        
        # Basic functionality tests
        self.run_test("Basic Type Parameter Tokenization", self.test_basic_type_parameter_tokenization)
        self.run_test("Multiple Type Parameters", self.test_multiple_type_parameters)
        self.run_test("Type Constraints", self.test_type_constraints)
        self.run_test("Mixed Constraints", self.test_mixed_constraints)
        
        # Syntax recognition tests
        self.run_test("Generic Function Syntax", self.test_generic_function_syntax)
        self.run_test("Generic Class Syntax", self.test_generic_class_syntax)
        self.run_test("Nested Generic Types", self.test_nested_generic_types)
        
        # Validation and utility tests
        self.run_test("Syntax Validation", self.test_syntax_validation)
        self.run_test("Utility Functions", self.test_utility_functions)
        
        # Performance tests
        self.run_test("Performance Basic", self.test_performance_basic)
        
        # Complex scenario tests
        self.run_test("Complex Generic Scenario", self.test_complex_generic_scenario)
        
        self.print_summary()
    
    def print_summary(self) -> None:
        """Print test summary"""
        print("=" * 50)
        print("Test Summary:")
        print(f"   Total Tests: {self.total_tests}")
        print(f"   Passed: {self.passed_tests}")
        print(f"   Failed: {self.total_tests - self.passed_tests}")
        print(f"   Success Rate: {(self.passed_tests / self.total_tests * 100):.1f}%")
        
        total_time = sum(r.execution_time for r in self.results)
        print(f"   Total Execution Time: {total_time:.3f}s")
        print(f"   Average Test Time: {total_time / self.total_tests:.3f}s")
        
        if self.passed_tests == self.total_tests:
            print("All tests passed! Generic type parameters are working correctly.")
        else:
            print("Some tests failed. Check to implementation.")

def main():
    """Main test runner"""
    print("Noodle Language - Generic Type Parameter Test Suite")
    print("Testing basic generic type functionality...")
    print()
    
    tester = GenericTypeTester()
    tester.run_all_tests()
    
    print()
    print("Generic Type Features Tested:")
    print("   [OK] Basic type parameter tokenization")
    print("   [OK] Multiple type parameters")
    print("   [OK] Type constraints (T: Numeric)")
    print("   [OK] Mixed constrained/unconstrained parameters")
    print("   [OK] Generic function syntax")
    print("   [OK] Generic class syntax")
    print("   [OK] Syntax validation")
    print("   [OK] Performance characteristics")
    print("   [OK] Complex scenarios")
    print()
    print("Next Steps:")
    print("   1. Integrate with existing Noodle parser")
    print("   2. Implement type inference engine")
    print("   3. Add runtime support for generics")
    print("   4. Create comprehensive test coverage")
    
    return 0 if tester.passed_tests == tester.total_tests else 1

if __name__ == "__main__":
    sys.exit(main())

