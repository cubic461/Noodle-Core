#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase1_pattern_matching.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Phase 1 Implementation Test: Pattern Matching Parser Integration

This test validates the pattern matching parser implementation and identifies issues.
"""

import sys
import os
import json
from typing import List, Dict, Any, Optional

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try:
    from noodlecore.compiler.enhanced_parser import EnhancedParser
    from noodlecore.compiler.ast_nodes import (
        MatchExpressionNode, MatchCaseNode, Pattern, WildcardPatternNode,
        LiteralPatternNode, IdentifierPatternNode, TuplePatternNode,
        ArrayPatternNode, ObjectPatternNode, OrPatternNode, AndPatternNode,
        GuardPatternNode, TypePatternNode, RangePatternNode, SourceLocation
    )
except ImportError:
    print("Could not import Noodle parser modules. Using fallback.")
    EnhancedParser = None


class PatternMatchingTestResult:
    """Result of a pattern matching test"""
    def __init__(self, name: str, code: str, passed: bool, 
                 message: str = "", pattern_types: List[str] = None,
                 error_details: Dict[str, Any] = None):
        self.name = name
        self.code = code
        self.passed = passed
        self.message = message
        self.pattern_types = pattern_types or []
        self.error_details = error_details or {}


class PatternMatchingTestSuite:
    """Comprehensive test suite for pattern matching"""
    
    def __init__(self):
        self.results = []
        self.parser = EnhancedParser if EnhancedParser else None
    
    def add_test_result(self, result: PatternMatchingTestResult):
        """Add a test result to the suite"""
        self.results.append(result)
    
    def get_pattern_type(self, pattern: Pattern) -> str:
        """Get the pattern type as string"""
        if isinstance(pattern, WildcardPatternNode):
            return "wildcard"
        elif isinstance(pattern, LiteralPatternNode):
            return "literal"
        elif isinstance(pattern, IdentifierPatternNode):
            return "identifier"
        elif isinstance(pattern, TuplePatternNode):
            return "tuple"
        elif isinstance(pattern, ArrayPatternNode):
            return "array"
        elif isinstance(pattern, ObjectPatternNode):
            return "object"
        elif isinstance(pattern, OrPatternNode):
            return "or"
        elif isinstance(pattern, AndPatternNode):
            return "and"
        elif isinstance(pattern, GuardPatternNode):
            return "guard"
        elif isinstance(pattern, TypePatternNode):
            return "type"
        elif isinstance(pattern, RangePatternNode):
            return "range"
        else:
            return "unknown"
    
    def test_wildcard_pattern(self):
        """Test wildcard pattern (_)"""
        code = """
        match x {
            _ => "default"
        }
        """
        return self._run_test("Wildcard pattern", code, 1, ["wildcard"])
    
    def test_literal_patterns(self):
        """Test literal patterns (numbers, strings, booleans)"""
        tests = [
            {
                "name": "Number literal pattern",
                "code": """
                match x {
                    42 => "special number",
                    _ => "any other number"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["literal", "wildcard"]
            },
            {
                "name": "String literal pattern",
                "code": """
                match name {
                    "Alice" => "Hello Alice",
                    "Bob" => "Hello Bob",
                    _ => "Hello stranger"
                }
                """,
                "expected_patterns": 3,
                "expected_types": ["literal", "literal", "wildcard"]
            },
            {
                "name": "Boolean literal pattern",
                "code": """
                match flag {
                    true => "enabled",
                    false => "disabled"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["literal", "literal"]
            },
            {
                "name": "Negative number literal",
                "code": """
                match x {
                    -42 => "negative",
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["literal", "wildcard"]
            },
            {
                "name": "Float literal pattern",
                "code": """
                match x {
                    3.14 => "pi",
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["literal", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_identifier_patterns(self):
        """Test identifier patterns (variable binding)"""
        tests = [
            {
                "name": "Simple identifier pattern",
                "code": """
                match point {
                    origin => "at origin",
                    _ => "somewhere else"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["identifier", "wildcard"]
            },
            {
                "name": "Multiple identifier patterns",
                "code": """
                match point {
                    x => ("x coordinate", x),
                    y => ("y coordinate", y)
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["identifier", "identifier"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_tuple_patterns(self):
        """Test tuple patterns ((x, y), (head, ...tail))"""
        tests = [
            {
                "name": "Empty tuple pattern",
                "code": """
                match point {
                    () => "empty tuple"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["tuple"]
            },
            {
                "name": "Simple tuple pattern",
                "code": """
                match point {
                    (0, 0) => "origin",
                    (x, y) => "point"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["tuple", "tuple"]
            },
            {
                "name": "Triple tuple pattern",
                "code": """
                match point3d {
                    (x, y, z) => "3d point"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["tuple"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_array_patterns(self):
        """Test array patterns ([head, ...tail])"""
        tests = [
            {
                "name": "Empty array pattern",
                "code": """
                match list {
                    [] => "empty"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["array"]
            },
            {
                "name": "Single element array pattern",
                "code": """
                match list {
                    [head] => "single element"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["array"]
            },
            {
                "name": "Head-tail array pattern",
                "code": """
                match list {
                    [head, ...tail] => "multiple elements"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["array"]
            },
            {
                "name": "Multiple element array pattern",
                "code": """
                match list {
                    [a, b, c] => "three elements"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["array"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_object_patterns(self):
        """Test object patterns ({key: value})"""
        tests = [
            {
                "name": "Simple object pattern",
                "code": """
                match user {
                    {name: "Alice", age: 30} => "Alice is 30"
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["object"]
            },
            {
                "name": "Object pattern with variable",
                "code": """
                match user {
                    {name: n, age: a} => "User " + n + " is " + a.toString()
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["object"]
            },
            {
                "name": "Multiple properties object pattern",
                "code": """
                match person {
                    {name: n, age: a, city: c} => n + " from " + c
                }
                """,
                "expected_patterns": 1,
                "expected_types": ["object"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_or_patterns(self):
        """Test OR patterns (pattern1 | pattern2)"""
        tests = [
            {
                "name": "Simple OR pattern",
                "code": """
                match value {
                    1 | 2 | 3 => "small number",
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["or", "wildcard"]
            },
            {
                "name": "String OR pattern",
                "code": """
                match name {
                    "Alice" | "Bob" => "Hello friend",
                    _ => "Hello stranger"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["or", "wildcard"]
            },
            {
                "name": "Boolean OR pattern",
                "code": """
                match flag {
                    true | false => "boolean value",
                    _ => "not boolean"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["or", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_and_patterns(self):
        """Test AND patterns (pattern1 & pattern2)"""
        tests = [
            {
                "name": "Simple AND pattern",
                "code": """
                match data {
                    x & y => "both true",
                    _ => "not both"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["and", "wildcard"]
            },
            {
                "name": "AND with literals",
                "code": """
                match value {
                    1 & 2 => "both 1 and 2",
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["and", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_guard_patterns(self):
        """Test guard patterns (pattern if condition)"""
        tests = [
            {
                "name": "Simple guard pattern",
                "code": """
                match number {
                    n if n > 0 => "positive",
                    n if n < 0 => "negative",
                    _ => "zero"
                }
                """,
                "expected_patterns": 3,
                "expected_types": ["guard", "guard", "wildcard"]
            },
            {
                "name": "Guard with expression",
                "code": """
                match value {
                    x if x % 2 == 0 => "even",
                    _ => "odd"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["guard", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_type_patterns(self):
        """Test type patterns (TypeName variable)"""
        tests = [
            {
                "name": "Simple type pattern",
                "code": """
                match value {
                    String s => "string: " + s,
                    Number n => "number: " + n.toString()
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["type", "type"]
            },
            {
                "name": "Type pattern with generic",
                "code": """
                match item {
                    List l => "list with " + l.length() + " items",
                    _ => "not a list"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["type", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_range_patterns(self):
        """Test range patterns (start..end)"""
        tests = [
            {
                "name": "Simple range pattern",
                "code": """
                match age {
                    0..12 => "child",
                    13..19 => "teenager",
                    20..64 => "adult",
                    65.. => "senior"
                }
                """,
                "expected_patterns": 4,
                "expected_types": ["range", "range", "range", "range"]
            },
            {
                "name": "Negative range pattern",
                "code": """
                match temp {
                    -10..0 => "freezing",
                    _ => "above freezing"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["range", "wildcard"]
            },
            {
                "name": "Float range pattern",
                "code": """
                match value {
                    0.0..1.0 => "small",
                    _ => "large"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["range", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_nested_patterns(self):
        """Test nested and complex pattern combinations"""
        tests = [
            {
                "name": "Nested tuple in array",
                "code": """
                match data {
                    [(x, y)] => "point in array",
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["array", "wildcard"]
            },
            {
                "name": "Object with nested patterns",
                "code": """
                match user {
                    {name: "Alice", info: {age: a, city: c}} => "Alice from " + c,
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["object", "wildcard"]
            },
            {
                "name": "Complex nested with guard",
                "code": """
                match data {
                    {type: "user", info: {name: n, age: a}} if a >= 18 => "Adult user: " + n,
                    {type: "user", info: {name: n, age: a}} => "Minor user: " + n,
                    _ => "Unknown"
                }
                """,
                "expected_patterns": 3,
                "expected_types": ["guard", "object", "wildcard"]
            },
            {
                "name": "OR with nested patterns",
                "code": """
                match value {
                    (1, 2) | (3, 4) => "special pair",
                    _ => "other"
                }
                """,
                "expected_patterns": 2,
                "expected_types": ["or", "wildcard"]
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_test(test["name"], test["code"], 
                                   test["expected_patterns"], test["expected_types"])
            results.append(result)
        
        return results
    
    def test_error_cases(self):
        """Test error cases and invalid patterns"""
        tests = [
            {
                "name": "Unclosed tuple pattern",
                "code": """
                match point {
                    (x, y => "incomplete"
                }
                """,
                "should_fail": True,
                "expected_error": "Expected ')' to end tuple pattern"
            },
            {
                "name": "Unclosed array pattern",
                "code": """
                match list {
                    [head, ...tail => "incomplete"
                }
                """,
                "should_fail": True,
                "expected_error": "Expected ']' to end array pattern"
            },
            {
                "name": "Unclosed object pattern",
                "code": """
                match user {
                    {name: "Alice", age: 30 => "incomplete"
                }
                """,
                "should_fail": True,
                "expected_error": "Expected '}' to end object pattern"
            },
            {
                "name": "Invalid range pattern",
                "code": """
                match value {
                    1.. => "incomplete range"
                }
                """,
                "should_fail": True,
                "expected_error": "Expected number at end of range"
            }
        ]
        
        results = []
        for test in tests:
            result = self._run_error_test(test["name"], test["code"], 
                                      test["should_fail"], test["expected_error"])
            results.append(result)
        
        return results
    
    def _run_test(self, name: str, code: str, 
                  expected_patterns: int, expected_types: List[str]) -> PatternMatchingTestResult:
        """Run a single pattern matching test"""
        if self.parser is None:
            return PatternMatchingTestResult(
                name=name,
                code=code,
                passed=False,
                message="Parser not available"
            )
        
        try:
            parser = self.parser(code, f"test_{name.replace(' ', '_')}.nc")
            ast = parser.parse()
            
            # Check for parsing errors
            if parser.errors:
                error_messages = [error.message for error in parser.errors]
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=False,
                    message=f"Parse errors: {'; '.join(error_messages)}",
                    error_details={"parse_errors": error_messages}
                )
            
            # Find match expression
            match_expr = None
            for stmt in ast.statements:
                if hasattr(stmt, 'type') and stmt.type.value == 'match_expression':
                    match_expr = stmt
                    break
            
            if not match_expr:
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=False,
                    message="No match expression found"
                )
            
            # Validate match expression
            if not isinstance(match_expr, MatchExpressionNode):
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=False,
                    message=f"Wrong match expression type: {type(match_expr)}",
                    error_details={"actual_type": str(type(match_expr))}
                )
            
            # Check cases
            cases = match_expr.cases
            if len(cases) != expected_patterns:
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=False,
                    message=f"Expected {expected_patterns} cases, got {len(cases)}",
                    error_details={"expected": expected_patterns, "actual": len(cases)}
                )
            
            # Check pattern types
            actual_pattern_types = []
            for case in cases:
                if hasattr(case, 'pattern') and case.pattern:
                    actual_pattern_types.append(self.get_pattern_type(case.pattern))
                else:
                    actual_pattern_types.append("unknown")
            
            if actual_pattern_types != expected_types:
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=False,
                    message=f"Expected pattern types {expected_types}, got {actual_pattern_types}",
                    error_details={"expected": expected_types, "actual": actual_pattern_types}
                )
            
            return PatternMatchingTestResult(
                name=name,
                code=code,
                passed=True,
                message="Test passed",
                pattern_types=actual_pattern_types
            )
            
        except Exception as e:
            return PatternMatchingTestResult(
                name=name,
                code=code,
                passed=False,
                message=f"Exception: {str(e)}",
                error_details={"exception": str(e)}
            )
    
    def _run_error_test(self, name: str, code: str, 
                       should_fail: bool, expected_error: str) -> PatternMatchingTestResult:
        """Run a test that should fail with a specific error"""
        if self.parser is None:
            return PatternMatchingTestResult(
                name=name,
                code=code,
                passed=False,
                message="Parser not available"
            )
        
        try:
            parser = self.parser(code, f"error_test_{name.replace(' ', '_')}.nc")
            ast = parser.parse()
            
            # Check for parsing errors
            if should_fail:
                if not parser.errors:
                    return PatternMatchingTestResult(
                        name=name,
                        code=code,
                        passed=False,
                        message="Expected parse errors but none found"
                    )
                
                error_messages = [error.message for error in parser.errors]
                if not any(expected_error in msg for msg in error_messages):
                    return PatternMatchingTestResult(
                        name=name,
                        code=code,
                        passed=False,
                        message=f"Expected error containing '{expected_error}', got: {'; '.join(error_messages)}",
                        error_details={"expected_error": expected_error, "actual_errors": error_messages}
                    )
                
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=True,
                    message="Test passed (failed as expected)",
                    error_details={"parse_errors": error_messages}
                )
            else:
                if parser.errors:
                    return PatternMatchingTestResult(
                        name=name,
                        code=code,
                        passed=False,
                        message=f"Unexpected parse errors: {'; '.join([error.message for error in parser.errors])}"
                    )
                
                return PatternMatchingTestResult(
                    name=name,
                    code=code,
                    passed=False,
                    message="Test passed but should have failed"
                )
            
        except Exception as e:
            return PatternMatchingTestResult(
                name=name,
                code=code,
                passed=False,
                message=f"Exception: {str(e)}",
                error_details={"exception": str(e)}
            )
    
    def run_all_tests(self):
        """Run all pattern matching tests"""
        print("ðŸ§ª Testing Pattern Matching Parser Integration")
        print("=" * 60)
        
        all_results = []
        
        # Test basic patterns
        all_results.append(self.test_wildcard_pattern())
        
        # Test literal patterns
        all_results.extend(self.test_literal_patterns())
        
        # Test identifier patterns
        all_results.extend(self.test_identifier_patterns())
        
        # Test tuple patterns
        all_results.extend(self.test_tuple_patterns())
        
        # Test array patterns
        all_results.extend(self.test_array_patterns())
        
        # Test object patterns
        all_results.extend(self.test_object_patterns())
        
        # Test OR patterns
        all_results.extend(self.test_or_patterns())
        
        # Test AND patterns
        all_results.extend(self.test_and_patterns())
        
        # Test guard patterns
        all_results.extend(self.test_guard_patterns())
        
        # Test type patterns
        all_results.extend(self.test_type_patterns())
        
        # Test range patterns
        all_results.extend(self.test_range_patterns())
        
        # Test nested patterns
        all_results.extend(self.test_nested_patterns())
        
        # Test error cases
        all_results.extend(self.test_error_cases())
        
        # Print results
        passed = sum(1 for result in all_results if result.passed)
        failed = len(all_results) - passed
        
        print(f"\n{'='*60}")
        print(f"ðŸ“Š Results: {passed} passed, {failed} failed")
        print(f"ðŸ“ˆ Success Rate: {(passed/(passed+failed))*100:.1f}%")
        
        # Print detailed results
        print("\nðŸ“‹ Detailed Results:")
        print("-" * 60)
        
        for result in all_results:
            status = "âœ… PASSED" if result.passed else "âŒ FAILED"
            print(f"{status} - {result.name}")
            if not result.passed:
                print(f"    Message: {result.message}")
                if result.error_details:
                    print(f"    Details: {result.error_details}")
            elif result.pattern_types:
                print(f"    Pattern Types: {', '.join(result.pattern_types)}")
        
        return all_results


def main():
    """Run all Phase 1 tests"""
    print("ðŸš€ Starting Phase 1 Implementation Tests")
    print("=" * 60)
    
    # Create and run test suite
    suite = PatternMatchingTestSuite()
    results = suite.run_all_tests()
    
    # Overall results
    passed = sum(1 for result in results if result.passed)
    failed = len(results) - passed
    
    print(f"\n{'='*60}")
    print("ðŸŽ¯ PHASE 1 TEST SUMMARY")
    print("=" * 60)
    
    print(f"Pattern Matching: {'âœ… PASSED' if passed == len(results) else 'âŒ FAILED'}")
    print(f"Tests Passed: {passed}/{len(results)}")
    
    if failed > 0:
        print(f"\nðŸ”§ Issues identified. Next steps:")
        print("   - Fix pattern matching parser integration issues")
        print("   - Address failing test cases")
    
    return passed == len(results)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

