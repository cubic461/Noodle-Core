#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_trm_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test suite for Phase 2.2 TRM Integration for Complex Syntax Problems

This test suite validates the TRM integration components:
1. SyntaxReasoningModule
2. ComplexityDetector
3. TRMIntegrationInterface
4. EnhancedNoodleCoreSyntaxFixerV3
5. IDE TRM Integration
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path
import json
import time

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent))

class TestSyntaxReasoningModule(unittest.TestCase):
    """Test the SyntaxReasoningModule component."""
    
    def setUp(self):
        """Set up test fixtures."""
        try:
            from noodlecore.ai_agents.syntax_reasoning_module import SyntaxReasoningModule
            self.reasoning_module = SyntaxReasoningModule()
        except ImportError as e:
            self.skipTest(f"SyntaxReasoningModule not available: {e}")
    
    def test_module_initialization(self):
        """Test that the module initializes correctly."""
        self.assertIsNotNone(self.reasoning_module)
        self.assertTrue(hasattr(self.reasoning_module, 'analyze_syntax_problem'))
        self.assertTrue(hasattr(self.reasoning_module, 'analyze_syntax_problem_async'))
    
    def test_simple_syntax_analysis(self):
        """Test analysis of simple syntax problems."""
        # Create a simple syntax problem
        test_content = """
function test_function() {
    return "hello world"
}
"""
        
        try:
            # Log diagnostic information
            print(f"DEBUG: Testing SyntaxReasoningModule.analyze_syntax_problem method signature")
            print(f"DEBUG: Module has analyze_syntax_problem: {hasattr(self.reasoning_module, 'analyze_syntax_problem')}")
            print(f"DEBUG: Module has analyze_syntax_problem_async: {hasattr(self.reasoning_module, 'analyze_syntax_problem_async')}")
            
            # Try to create SyntaxProblem object as expected by implementation
            from noodlecore.ai_agents.syntax_reasoning_module import SyntaxProblem, ComplexityLevel
            problem = SyntaxProblem(
                problem_id="test-1",
                file_path="test.nc",
                content=test_content,
                error_type="syntax_error",
                error_message="Test syntax error",
                complexity_level=ComplexityLevel.LOW,
                confidence=0.8
            )
            
            print(f"DEBUG: Created SyntaxProblem object: {problem}")
            
            # Call with proper signature
            result = self.reasoning_module.analyze_syntax_problem(problem)
            
            print(f"DEBUG: Result type: {type(result)}")
            print(f"DEBUG: Result attributes: {dir(result)}")
            
            self.assertIsNotNone(result)
            # Check for TRMReasoningResult attributes
            self.assertTrue(hasattr(result, 'success'))
            self.assertTrue(hasattr(result, 'reasoning'))
            self.assertTrue(hasattr(result, 'confidence'))
            
        except Exception as e:
            print(f"DEBUG: Exception in simple syntax analysis: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"Simple syntax analysis failed: {e}")
    
    def test_complex_syntax_analysis(self):
        """Test analysis of complex syntax problems."""
        # Create a complex syntax problem that should trigger TRM
        test_content = """
function complex_nested_structure(param1, param2 = {
    nested: {
        deeply: {
            nested: [1, 2, 3, function(x) {
                return x * param1 + param2.nested.deeply.nested[0]
            }]
        }
    }
}) {
    var result = []
    for (var i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            result.push(param2.nested.deeply.nested[3](i))
        } else {
            result.push(param1 * i)
        }
    }
    return result
}
"""
        
        try:
            # Log diagnostic information
            print(f"DEBUG: Testing complex syntax analysis")
            
            # Create SyntaxProblem object as expected by implementation
            from noodlecore.ai_agents.syntax_reasoning_module import SyntaxProblem, ComplexityLevel
            problem = SyntaxProblem(
                problem_id="test-2",
                file_path="complex_test.nc",
                content=test_content,
                error_type="syntax_error",
                error_message="Complex syntax error",
                complexity_level=ComplexityLevel.HIGH,
                confidence=0.3
            )
            
            print(f"DEBUG: Created complex SyntaxProblem object: {problem}")
            
            # Call with proper signature
            result = self.reasoning_module.analyze_syntax_problem(problem)
            
            print(f"DEBUG: Complex result type: {type(result)}")
            print(f"DEBUG: Complex result success: {result.success}")
            
            self.assertIsNotNone(result)
            self.assertTrue(result.success)
            self.assertGreater(result.confidence, 0.5)  # Should have reasonable confidence
            
        except Exception as e:
            print(f"DEBUG: Exception in complex syntax analysis: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"Complex syntax analysis failed: {e}")


class TestComplexityDetector(unittest.TestCase):
    """Test the ComplexityDetector component."""
    
    def setUp(self):
        """Set up test fixtures."""
        try:
            from noodlecore.ai_agents.complexity_detector import ComplexityDetector
            self.detector = ComplexityDetector()
        except ImportError as e:
            self.skipTest(f"ComplexityDetector not available: {e}")
    
    def test_detector_initialization(self):
        """Test that the detector initializes correctly."""
        self.assertIsNotNone(self.detector)
        self.assertTrue(hasattr(self.detector, 'analyze_complexity'))
        self.assertTrue(hasattr(self.detector, 'should_invoke_trm'))
    
    def test_simple_content_complexity(self):
        """Test complexity analysis of simple content."""
        simple_content = """
function simple() {
    return "hello"
}
"""
        
        try:
            # Log diagnostic information
            print(f"DEBUG: Testing ComplexityDetector.analyze_complexity method signature")
            print(f"DEBUG: Module has analyze_complexity: {hasattr(self.detector, 'analyze_complexity')}")
            print(f"DEBUG: Module has should_invoke_trm: {hasattr(self.detector, 'should_invoke_trm')}")
            
            # Call with proper signature (including error_message parameter)
            metrics = self.detector.analyze_complexity(
                content=simple_content,
                file_path="simple.nc",
                error_message="Test error message"
            )
            
            print(f"DEBUG: Complexity result type: {type(metrics)}")
            print(f"DEBUG: Complexity result: {metrics}")
            
            self.assertIsNotNone(metrics)
            # Check for tuple return (complexity_level, complexity_score, complexity_metrics)
            self.assertEqual(len(metrics), 3)
            complexity_level, complexity_score, complexity_metrics = metrics
            
            print(f"DEBUG: Complexity level: {complexity_level}")
            print(f"DEBUG: Complexity score: {complexity_score}")
            print(f"DEBUG: Complexity metrics: {complexity_metrics}")
            
            self.assertLess(complexity_score, 0.5)
            
            # Should not invoke TRM for simple content - call with proper signature
            should_invoke = self.detector.should_invoke_trm(
                content=simple_content,
                file_path="simple.nc",
                error_message="Test error message"
            )
            self.assertFalse(should_invoke)
            
        except Exception as e:
            print(f"DEBUG: Exception in simple complexity analysis: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"Simple content complexity analysis failed: {e}")
    
    def test_complex_content_complexity(self):
        """Test complexity analysis of complex content."""
        complex_content = """
function complex_nested(param1, param2 = {
    nested: {
        deeply: {
            nested: [1, 2, 3, function(x) {
                return x * param1 + param2.nested.deeply.nested[0]
            }]
        }
    }
}) {
    var result = []
    for (var i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            result.push(param2.nested.deeply.nested[3](i))
        } else {
            result.push(param1 * i)
        }
    }
    return result
}
"""
        
        try:
            # Call with proper signature (including error_message parameter)
            metrics = self.detector.analyze_complexity(
                content=complex_content,
                file_path="complex.nc",
                error_message="Complex syntax error"
            )
            
            print(f"DEBUG: Complex complexity result type: {type(metrics)}")
            print(f"DEBUG: Complex complexity result: {metrics}")
            
            self.assertIsNotNone(metrics)
            # Check for tuple return (complexity_level, complexity_score, complexity_metrics)
            self.assertEqual(len(metrics), 3)
            complexity_level, complexity_score, complexity_metrics = metrics
            
            print(f"DEBUG: Complex complexity level: {complexity_level}")
            print(f"DEBUG: Complex complexity score: {complexity_score}")
            print(f"DEBUG: Complex complexity metrics: {complexity_metrics}")
            
            self.assertGreater(complexity_score, 0.7)
            
            # Should invoke TRM for complex content - call with proper signature
            should_invoke = self.detector.should_invoke_trm(
                content=complex_content,
                file_path="complex.nc",
                error_message="Complex syntax error"
            )
            self.assertTrue(should_invoke)
            
        except Exception as e:
            print(f"DEBUG: Exception in complex complexity analysis: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"Complex content complexity analysis failed: {e}")


class TestTRMIntegrationInterface(unittest.TestCase):
    """Test the TRMIntegrationInterface component."""
    
    def setUp(self):
        """Set up test fixtures."""
        try:
            from noodlecore.ai_agents.trm_integration_interface import TRMIntegrationInterface
            self.interface = TRMIntegrationInterface()
        except ImportError as e:
            self.skipTest(f"TRMIntegrationInterface not available: {e}")
    
    def test_interface_initialization(self):
        """Test that the interface initializes correctly."""
        self.assertIsNotNone(self.interface)
        self.assertTrue(hasattr(self.interface, 'analyze_and_fix'))
        self.assertTrue(hasattr(self.interface, 'analyze_and_fix_async'))
    
    def test_simple_problem_handling(self):
        """Test handling of simple syntax problems."""
        # Create a temporary file with simple syntax problem
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as temp_file:
            temp_file.write("""
function simple_test() {
    return "hello world"
}
""")
            temp_path = temp_file.name
        
        try:
            # Log diagnostic information
            print(f"DEBUG: Testing TRMIntegrationInterface.analyze_and_fix method signature")
            print(f"DEBUG: Interface has analyze_and_fix: {hasattr(self.interface, 'analyze_and_fix')}")
            
            # Read file content for proper signature
            with open(temp_path, 'r') as f:
                content = f.read()
            
            print(f"DEBUG: File content: {content[:100]}...")
            
            # Call with proper signature (content, file_path, error_message, ...)
            result = self.interface.analyze_and_fix(
                content=content,
                file_path=temp_path,
                error_message="Test syntax error",
                existing_confidence=0.5
            )
            
            print(f"DEBUG: TRM result type: {type(result)}")
            print(f"DEBUG: TRM result: {result}")
            
            self.assertIsNotNone(result)
            self.assertTrue(hasattr(result, 'success'))
            self.assertTrue(hasattr(result, 'fixes_applied'))
            
        except Exception as e:
            print(f"DEBUG: Exception in simple problem handling: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"Simple problem handling failed: {e}")
        finally:
            # Clean up
            try:
                os.unlink(temp_path)
            except:
                pass
    
    def test_complex_problem_handling(self):
        """Test handling of complex syntax problems."""
        # Create a temporary file with complex syntax problem
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as temp_file:
            temp_file.write("""
function complex_nested(param1, param2 = {
    nested: {
        deeply: {
            nested: [1, 2, 3, function(x) {
                return x * param1 + param2.nested.deeply.nested[0]
            }]
        }
    }
}) {
    var result = []
    for (var i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            result.push(param2.nested.deeply.nested[3](i))
        } else {
            result.push(param1 * i)
        }
    }
    return result
}
""")
            temp_path = temp_file.name
        
        try:
            # Read file content for proper signature
            with open(temp_path, 'r') as f:
                content = f.read()
            
            print(f"DEBUG: Complex file content: {content[:100]}...")
            
            # Call with proper signature (content, file_path, error_message, ...)
            result = self.interface.analyze_and_fix(
                content=content,
                file_path=temp_path,
                error_message="Complex syntax error",
                existing_confidence=0.3  # Lower confidence to trigger TRM
            )
            
            print(f"DEBUG: Complex TRM result type: {type(result)}")
            print(f"DEBUG: Complex TRM result: {result}")
            
            self.assertIsNotNone(result)
            self.assertTrue(hasattr(result, 'success'))
            self.assertTrue(hasattr(result, 'fixes_applied'))
            
        except Exception as e:
            print(f"DEBUG: Exception in complex problem handling: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"Complex problem handling failed: {e}")
        finally:
            # Clean up
            try:
                os.unlink(temp_path)
            except:
                pass


class TestEnhancedSyntaxFixerV3(unittest.TestCase):
    """Test the EnhancedNoodleCoreSyntaxFixerV3 component."""
    
    def setUp(self):
        """Set up test fixtures."""
        try:
            from noodlecore.desktop.ide.enhanced_syntax_fixer_v3 import EnhancedNoodleCoreSyntaxFixerV3
            self.fixer = EnhancedNoodleCoreSyntaxFixerV3(
                enable_ai=True,
                enable_real_time=False,  # Disable for testing
                enable_learning=False,  # Disable for testing
                enable_trm=True
            )
        except ImportError as e:
            self.skipTest(f"EnhancedNoodleCoreSyntaxFixerV3 not available: {e}")
    
    def test_fixer_initialization(self):
        """Test that the fixer initializes correctly."""
        self.assertIsNotNone(self.fixer)
        self.assertTrue(hasattr(self.fixer, 'fix_file_enhanced_v3'))
        self.assertTrue(hasattr(self.fixer, 'configure_trm_settings'))
        self.assertTrue(hasattr(self.fixer, 'get_trm_status'))
    
    def test_trm_configuration(self):
        """Test TRM configuration."""
        try:
            print(f"DEBUG: Testing TRM configuration methods")
            print(f"DEBUG: Fixer has configure_trm_settings: {hasattr(self.fixer, 'configure_trm_settings')}")
            print(f"DEBUG: Fixer has get_trm_status: {hasattr(self.fixer, 'get_trm_status')}")
            print(f"DEBUG: Fixer has get_status: {hasattr(self.fixer, 'get_status')}")
            
            trm_config = {
                'complexity_threshold': 0.7,
                'timeout': 30,
                'max_retries': 3,
                'cache_results': True,
                'enable_async': True
            }
            
            # Try to call configure_trm_settings if it exists
            if hasattr(self.fixer, 'configure_trm_settings'):
                self.fixer.configure_trm_settings(trm_config)
            else:
                print(f"DEBUG: configure_trm_settings method not found, trying configure_trm_settings")
                # Try actual method name in implementation
                self.fixer.configure_trm_settings(**trm_config)
            
            # Verify configuration was applied - try get_trm_status first, then get_status
            if hasattr(self.fixer, 'get_trm_status'):
                status = self.fixer.get_trm_status()
            else:
                print(f"DEBUG: get_trm_status not found, using get_status")
                status = self.fixer.get_status()
            
            print(f"DEBUG: TRM status: {status}")
            self.assertIsNotNone(status)
            
        except Exception as e:
            print(f"DEBUG: Exception in TRM configuration: {e}")
            import traceback
            traceback.print_exc()
            self.fail(f"TRM configuration failed: {e}")
    
    def test_simple_file_fixing(self):
        """Test fixing of simple files."""
        # Create a temporary file with simple syntax problem
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as temp_file:
            temp_file.write("""
function simple_test() {
    return "hello world"
}
""")
            temp_path = temp_file.name
        
        try:
            result = self.fixer.fix_file_enhanced_v3(
                file_path=temp_path,
                create_backup=False
            )
            
            self.assertIsNotNone(result)
            self.assertIn('success', result)
            self.assertIn('fixes_applied', result)
            self.assertIn('trm_used', result)
            
            # For simple files, TRM should not be used
            self.assertFalse(result.get('trm_used', False))
            
        except Exception as e:
            self.fail(f"Simple file fixing failed: {e}")
        finally:
            # Clean up
            try:
                os.unlink(temp_path)
            except:
                pass
    
    def test_complex_file_fixing(self):
        """Test fixing of complex files."""
        # Create a temporary file with complex syntax problem
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as temp_file:
            temp_file.write("""
function complex_nested(param1, param2 = {
    nested: {
        deeply: {
            nested: [1, 2, 3, function(x) {
                return x * param1 + param2.nested.deeply.nested[0]
            }]
        }
    }
}) {
    var result = []
    for (var i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            result.push(param2.nested.deeply.nested[3](i))
        } else {
            result.push(param1 * i)
        }
    }
    return result
}
""")
            temp_path = temp_file.name
        
        try:
            result = self.fixer.fix_file_enhanced_v3(
                file_path=temp_path,
                create_backup=False
            )
            
            self.assertIsNotNone(result)
            self.assertIn('success', result)
            self.assertIn('fixes_applied', result)
            self.assertIn('trm_used', result)
            
            # For complex files, TRM should be used
            self.assertTrue(result.get('trm_used', False))
            
        except Exception as e:
            self.fail(f"Complex file fixing failed: {e}")
        finally:
            # Clean up
            try:
                os.unlink(temp_path)
            except:
                pass


class TestTRMIntegrationEndToEnd(unittest.TestCase):
    """End-to-end tests for TRM integration."""
    
    def setUp(self):
        """Set up test fixtures."""
        try:
            from noodlecore.desktop.ide.enhanced_syntax_fixer_v3 import EnhancedNoodleCoreSyntaxFixerV3
            self.fixer = EnhancedNoodleCoreSyntaxFixerV3(
                enable_ai=True,
                enable_real_time=False,
                enable_learning=False,
                enable_trm=True
            )
        except ImportError as e:
            self.skipTest(f"EnhancedNoodleCoreSyntaxFixerV3 not available: {e}")
    
    def test_end_to_end_trm_workflow(self):
        """Test complete end-to-end TRM workflow."""
        # Create a temporary file with complex syntax problem
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as temp_file:
            temp_file.write("""
function complex_workflow_test(param1, param2 = {
    nested: {
        deeply: {
            nested: [1, 2, 3, function(x) {
                return x * param1 + param2.nested.deeply.nested[0]
            }]
        }
    }
}) {
    var result = []
    for (var i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            result.push(param2.nested.deeply.nested[3](i))
        } else {
            result.push(param1 * i)
        }
    }
    return result
}
""")
            temp_path = temp_file.name
        
        try:
            # Step 1: Analyze complexity
            from noodlecore.ai_agents.complexity_detector import ComplexityDetector
            detector = ComplexityDetector()
            metrics = detector.analyze_complexity(
                content=open(temp_path, 'r').read(),
                file_path=temp_path,
                error_message="Complex syntax error"
            )
            
            print(f"DEBUG: End-to-end complexity result: {metrics}")
            
            # Should detect high complexity
            complexity_level, complexity_score, complexity_metrics = metrics
            self.assertGreater(complexity_score, 0.7)
            
            # Step 2: Should invoke TRM - call with proper signature
            should_invoke = detector.should_invoke_trm(
                content=open(temp_path, 'r').read(),
                file_path=temp_path,
                error_message="Complex syntax error",
                existing_confidence=0.3
            )
            self.assertTrue(should_invoke)
            
            # Step 3: Fix with TRM
            result = self.fixer.fix_file_enhanced_v3(
                file_path=temp_path,
                create_backup=False
            )
            
            # Should succeed and use TRM
            self.assertTrue(result.get('success', False))
            self.assertTrue(result.get('trm_used', False))
            
            # Step 4: Check TRM status - use get_status if get_trm_status not available
            if hasattr(self.fixer, 'get_trm_status'):
                trm_status = self.fixer.get_trm_status()
            else:
                trm_status = self.fixer.get_status()
            
            print(f"DEBUG: End-to-end TRM status: {trm_status}")
            self.assertIsNotNone(trm_status)
            
            # Check for operations in appropriate status structure
            if isinstance(trm_status, dict):
                if 'operations_completed' in trm_status:
                    self.assertGreater(trm_status.get('operations_completed', 0), 0)
                elif 'trm_statistics' in trm_status:
                    stats = trm_status['trm_statistics']
                    self.assertGreater(stats.get('trm_operations', 0), 0)
            
        except Exception as e:
            self.fail(f"End-to-end TRM workflow failed: {e}")
        finally:
            # Clean up
            try:
                os.unlink(temp_path)
            except:
                pass
    
    def test_trm_caching(self):
        """Test TRM result caching."""
        # Create a temporary file with complex syntax problem
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as temp_file:
            temp_file.write("""
function cache_test(param1, param2 = {
    nested: {
        deeply: {
            nested: [1, 2, 3, function(x) {
                return x * param1 + param2.nested.deeply.nested[0]
            }]
        }
    }
}) {
    var result = []
    for (var i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            result.push(param2.nested.deeply.nested[3](i))
        } else {
            result.push(param1 * i)
        }
    }
    return result
}
""")
            temp_path = temp_file.name
        
        try:
            # First fix - should use TRM
            start_time = time.time()
            result1 = self.fixer.fix_file_enhanced_v3(
                file_path=temp_path,
                create_backup=False
            )
            first_time = time.time() - start_time
            
            self.assertTrue(result1.get('success', False))
            self.assertTrue(result1.get('trm_used', False))
            
            # Second fix - should use cache
            start_time = time.time()
            result2 = self.fixer.fix_file_enhanced_v3(
                file_path=temp_path,
                create_backup=False
            )
            second_time = time.time() - start_time
            
            self.assertTrue(result2.get('success', False))
            
            # Second time should be faster (cache hit)
            self.assertLess(second_time, first_time)
            
            # Check cache status - use get_status if get_trm_status not available
            if hasattr(self.fixer, 'get_trm_status'):
                trm_status = self.fixer.get_trm_status()
            else:
                trm_status = self.fixer.get_status()
            
            print(f"DEBUG: Cache test TRM status: {trm_status}")
            self.assertIsNotNone(trm_status)
            
            # Check for cache hits in appropriate status structure
            if isinstance(trm_status, dict):
                if 'cache_hits' in trm_status:
                    self.assertGreater(trm_status.get('cache_hits', 0), 0)
                elif 'trm_statistics' in trm_status:
                    stats = trm_status['trm_statistics']
                    # Look for cache hits in integration statistics
                    if 'trm_integration_status' in stats and 'statistics' in stats['trm_integration_status']:
                        integration_stats = stats['trm_integration_status']['statistics']
                        self.assertGreater(integration_stats.get('cache_hits', 0), 0)
            
        except Exception as e:
            self.fail(f"TRM caching test failed: {e}")
        finally:
            # Clean up
            try:
                os.unlink(temp_path)
            except:
                pass


def run_trm_integration_tests():
    """Run all TRM integration tests."""
    print("=" * 60)
    print("Running Phase 2.2 TRM Integration Tests")
    print("=" * 60)
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test cases
    suite.addTests(loader.loadTestsFromTestCase(TestSyntaxReasoningModule))
    suite.addTests(loader.loadTestsFromTestCase(TestComplexityDetector))
    suite.addTests(loader.loadTestsFromTestCase(TestTRMIntegrationInterface))
    suite.addTests(loader.loadTestsFromTestCase(TestEnhancedSyntaxFixerV3))
    suite.addTests(loader.loadTestsFromTestCase(TestTRMIntegrationEndToEnd))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Print summary
    print("\n" + "=" * 60)
    print("TRM Integration Test Summary:")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Skipped: {len(result.skipped) if hasattr(result, 'skipped') else 0}")
    
    if result.failures:
        print("\nFailures:")
        for test, traceback in result.failures:
            print(f"- {test}: {traceback}")
    
    if result.errors:
        print("\nErrors:")
        for test, traceback in result.errors:
            print(f"- {test}: {traceback}")
    
    success = len(result.failures) == 0 and len(result.errors) == 0
    print(f"\nOverall result: {'SUCCESS' if success else 'FAILED'}")
    print("=" * 60)
    
    return success


if __name__ == "__main__":
    success = run_trm_integration_tests()
    sys.exit(0 if success else 1)

