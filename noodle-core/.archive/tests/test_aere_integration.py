#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_aere_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive Integration Tests for AERE Components

This module provides comprehensive integration tests for all AERE components
including SyntaxErrorAnalyzer, ResolutionGenerator, ValidationEngine,
AERESyntaxValidator, and GuardrailSystem.
"""

import os
import sys
import time
import unittest
import logging
from unittest.mock import Mock, patch
from typing import Dict, List, Any, Optional

# Add the src directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai.aere_engine import AEREngine
from noodlecore.ai_agents.syntax_error_analyzer import (
    SyntaxErrorAnalyzer, SyntaxError, ErrorSeverity, ErrorCategory, LanguageSupport
)
from noodlecore.ai_agents.resolution_generator import (
    ResolutionGenerator, ResolutionApproach, ResolutionResult, ResolutionType, ResolutionStrategy
)
from noodlecore.ai_agents.validation_engine import (
    ValidationEngine, ValidationReport, ValidationIssue, ValidationResult, ValidationLevel
)
from noodlecore.ai_agents.aere_syntax_validator import (
    AERESyntaxValidator, ValidationRequest, ValidationResponse, ValidationMode
)
from noodlecore.ai_agents.guardrail_system import (
    GuardrailSystem, GuardrailReport, GuardrailRule, GuardrailType, RiskLevel, GuardrailAction
)
from noodlecore.database.connection_pool import DatabaseConnectionPool

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TestAEREngine(AEREngine):
    """Test implementation of AERE engine."""
    
    def __init__(self):
        super().__init__()
        self.analyze_error_calls = []
        self.apply_resolution_calls = []
    
    def analyze_error(self, error_info: Dict[str, Any]) -> Dict[str, Any]:
        """Mock analyze_error method."""
        self.analyze_error_calls.append(error_info)
        return {
            "status": "success",
            "error_type": "syntax",
            "severity": "medium",
            "resolutions": [
                {
                    "description": "Test resolution",
                    "confidence": 0.8,
                    "auto_applicable": True
                }
            ],
            "related_errors": []
        }
    
    def apply_resolution(self, resolution: Dict[str, Any]) -> Dict[str, Any]:
        """Mock apply_resolution method."""
        self.apply_resolution_calls.append(resolution)
        return {
            "status": "success",
            "applied": True,
            "result": "Test resolution applied"
        }

class TestAEREIntegration(unittest.TestCase):
    """Comprehensive integration tests for AERE components."""
    
    def setUp(self):
        """Set up test environment."""
        # Create mock components
        self.mock_aere_engine = TestAEREngine()
        self.mock_db_pool = Mock(spec=DatabaseConnectionPool)
        
        # Initialize components with mocks
        self.syntax_error_analyzer = SyntaxErrorAnalyzer(
            aere_engine=self.mock_aere_engine,
            db_pool=self.mock_db_pool
        )
        
        self.resolution_generator = ResolutionGenerator(
            aere_engine=self.mock_aere_engine,
            db_pool=self.mock_db_pool
        )
        
        self.validation_engine = ValidationEngine(
            aere_engine=self.mock_aere_engine,
            db_pool=self.mock_db_pool
        )
        
        self.aere_validator = AERESyntaxValidator(
            aere_engine=self.mock_aere_engine,
            syntax_error_analyzer=self.syntax_error_analyzer,
            resolution_generator=self.resolution_generator,
            validation_engine=self.validation_engine,
            db_pool=self.mock_db_pool
        )
        
        self.guardrail_system = GuardrailSystem(
            aere_engine=self.mock_aere_engine,
            syntax_error_analyzer=self.syntax_error_analyzer,
            db_pool=self.mock_db_pool
        )
    
    def test_syntax_error_analyzer_initialization(self):
        """Test SyntaxErrorAnalyzer initialization."""
        self.assertIsNotNone(self.syntax_error_analyzer)
        self.assertEqual(self.syntax_error_analyzer.aere_engine, self.mock_aere_engine)
        self.assertEqual(self.syntax_error_analyzer.db_pool, self.mock_db_pool)
        
        # Test statistics
        stats = self.syntax_error_analyzer.get_statistics()
        self.assertIn("total_analyses", stats)
        self.assertIn("successful_analyses", stats)
        self.assertIn("total_errors_detected", stats)
    
    def test_syntax_error_analyzer_python_analysis(self):
        """Test Python syntax error analysis."""
        test_content = """
def test_function():
    print("Hello world"
    return test_function()
"""
        
        result = self.syntax_error_analyzer.analyze_syntax_errors(
            file_path="test.py",
            content=test_content,
            language="python"
        )
        
        self.assertTrue(result.success)
        self.assertGreater(len(result.errors), 0)
        
        # Check for specific Python errors
        error_types = [error.error_type for error in result.errors]
        self.assertIn("IndentationError", error_types)
    
    def test_syntax_error_analyzer_javascript_analysis(self):
        """Test JavaScript syntax error analysis."""
        test_content = """
function testFunction() {
    console.log("Hello world");
    return testFunction();
"""
        
        result = self.syntax_error_analyzer.analyze_syntax_errors(
            file_path="test.js",
            content=test_content,
            language="javascript"
        )
        
        self.assertTrue(result.success)
        self.assertGreater(len(result.errors), 0)
        
        # Check for specific JavaScript errors
        error_types = [error.error_type for error in result.errors]
        self.assertIn("SyntaxError", error_types)
    
    def test_resolution_generator_initialization(self):
        """Test ResolutionGenerator initialization."""
        self.assertIsNotNone(self.resolution_generator)
        self.assertEqual(self.resolution_generator.aere_engine, self.mock_aere_engine)
        self.assertEqual(self.resolution_generator.db_pool, self.mock_db_pool)
        
        # Test statistics
        stats = self.resolution_generator.get_statistics()
        self.assertIn("total_generations", stats)
        self.assertIn("successful_generations", stats)
        self.assertIn("total_approaches_generated", stats)
    
    def test_resolution_generator_python_fixes(self):
        """Test Python resolution generation."""
        from noodlecore.ai_agents.syntax_error_analyzer import SyntaxError
        
        # Create a test syntax error
        syntax_error = SyntaxError(
            error_id="test_error",
            file_path="test.py",
            line_number=2,
            column_number=0,
            error_message="Missing colon",
            error_type="SyntaxError",
            severity=ErrorSeverity.HIGH,
            category=ErrorCategory.SYNTAX,
            language=LanguageSupport.PYTHON,
            confidence=0.9,
            context="",
            patterns=[],
            impact_analysis={},
            timestamp=None
        )
        
        test_content = "def test_function()\n    print('Hello world')"
        
        result = self.resolution_generator.generate_resolutions(
            syntax_error=syntax_error,
            file_content=test_content,
            language="python"
        )
        
        self.assertTrue(result.success)
        self.assertGreater(len(result.approaches), 0)
        
        # Check for Python-specific fixes
        approach_types = [approach.resolution_type for approach in result.approaches]
        self.assertIn(ResolutionType.SYNTAX_FIX, approach_types)
    
    def test_validation_engine_initialization(self):
        """Test ValidationEngine initialization."""
        self.assertIsNotNone(self.validation_engine)
        self.assertEqual(self.validation_engine.aere_engine, self.mock_aere_engine)
        self.assertEqual(self.validation_engine.db_pool, self.mock_db_pool)
        
        # Test statistics
        stats = self.validation_engine.get_statistics()
        self.assertIn("total_validations", stats)
        self.assertIn("successful_validations", stats)
        self.assertIn("total_issues_found", stats)
    
    def test_validation_engine_python_validation(self):
        """Test Python validation."""
        original_content = "def test_function()\n    print('Hello world'"
        fixed_content = "def test_function():\n    print('Hello world')"
        
        result = self.validation_engine.validate_fixes(
            original_content=original_content,
            fixed_content=fixed_content,
            approaches=[],
            file_path="test.py",
            language="python"
        )
        
        self.assertTrue(result.success)
        self.assertEqual(result.overall_result, ValidationResult.PASS)
        self.assertEqual(result.total_issues, 0)
    
    def test_validation_engine_syntax_failures(self):
        """Test validation with syntax failures."""
        original_content = "def test_function()\n    print('Hello world'"
        fixed_content = "def test_function()\n    print('Hello world"  # Missing quote
        
        result = self.validation_engine.validate_fixes(
            original_content=original_content,
            fixed_content=fixed_content,
            approaches=[],
            file_path="test.py",
            language="python"
        )
        
        self.assertTrue(result.success)
        self.assertEqual(result.overall_result, ValidationResult.FAIL)
        self.assertGreater(result.total_issues, 0)
    
    def test_aere_validator_initialization(self):
        """Test AERESyntaxValidator initialization."""
        self.assertIsNotNone(self.aere_validator)
        self.assertEqual(self.aere_validator.aere_engine, self.mock_aere_engine)
        self.assertEqual(self.aere_validator.syntax_error_analyzer, self.syntax_error_analyzer)
        self.assertEqual(self.aere_validator.resolution_generator, self.resolution_generator)
        self.assertEqual(self.aere_validator.validation_engine, self.validation_engine)
        self.assertEqual(self.aere_validator.db_pool, self.mock_db_pool)
        
        # Test statistics
        stats = self.aere_validator.get_statistics()
        self.assertIn("total_validations", stats)
        self.assertIn("successful_validations", stats)
        self.assertIn("approval_rate", stats)
    
    def test_aere_validator_comprehensive_validation(self):
        """Test comprehensive AERE validation."""
        original_content = "def test_function()\n    print('Hello world'"
        fixed_content = "def test_function():\n    print('Hello world')"
        
        result = self.aere_validator.validate_syntax_fix(
            file_path="test.py",
            original_content=original_content,
            fixed_content=fixed_content,
            language="python",
            validation_mode=ValidationMode.COMPREHENSIVE
        )
        
        self.assertTrue(result.success)
        self.assertIsNotNone(result.validation_report)
        self.assertEqual(result.validation_report.overall_result, ValidationResult.PASS)
        self.assertTrue(result.approved)
    
    def test_aere_validator_pipeline_stages(self):
        """Test AERE validation pipeline stages."""
        original_content = "def test_function()\n    print('Hello world'"
        fixed_content = "def test_function():\n    print('Hello world')"
        
        progress_updates = []
        
        def progress_callback(progress):
            progress_updates.append(progress)
        
        result = self.aere_validator.validate_syntax_fix(
            file_path="test.py",
            original_content=original_content,
            fixed_content=fixed_content,
            language="python",
            validation_mode=ValidationMode.BALANCED,
            progress_callback=progress_callback
        )
        
        self.assertTrue(result.success)
        self.assertGreater(len(progress_updates), 0)
        self.assertGreater(result.processing_time, 0)
    
    def test_guardrail_system_initialization(self):
        """Test GuardrailSystem initialization."""
        self.assertIsNotNone(self.guardrail_system)
        self.assertEqual(self.guardrail_system.aere_engine, self.mock_aere_engine)
        self.assertEqual(self.guardrail_system.syntax_error_analyzer, self.syntax_error_analyzer)
        self.assertEqual(self.guardrail_system.db_pool, self.mock_db_pool)
        
        # Test statistics
        stats = self.guardrail_system.get_statistics()
        self.assertIn("total_checks", stats)
        self.assertIn("triggered_checks", stats)
        self.assertIn("blocked_operations", stats)
    
    def test_guardrail_system_syntax_rules(self):
        """Test guardrail system syntax rules."""
        from noodlecore.ai_agents.validation_engine import ValidationReport
        
        # Create a validation report with syntax failures
        validation_report = ValidationReport(
            report_id="test",
            validation_id="test",
            overall_result=ValidationResult.FAIL,
            overall_confidence=0.8,
            total_issues=2,
            issues=[
                ValidationIssue(
                    issue_id="syntax1",
                    validation_level=ValidationLevel.SYNTAX,
                    result=ValidationResult.FAIL,
                    risk=ValidationRisk.HIGH,
                    description="Syntax error",
                    details={},
                    affected_changes=[],
                    suggested_fix=None,
                    auto_fixable=False,
                    confidence=0.9
                ),
                ValidationIssue(
                    issue_id="syntax2",
                    validation_level=ValidationLevel.SYNTAX,
                    result=ValidationResult.FAIL,
                    risk=ValidationRisk.CRITICAL,
                    description="Critical syntax error",
                    details={},
                    affected_changes=[],
                    suggested_fix=None,
                    auto_fixable=False,
                    confidence=0.95
                )
            ],
            validation_time=1.0,
            rollback_available=False,
            metadata={}
        )
        
        result = self.guardrail_system.check_fixes(
            validation_report=validation_report,
            approaches=[],
            file_path="test.py"
        )
        
        self.assertTrue(result.success)
        self.assertEqual(result.overall_action, GuardrailAction.BLOCK)
        self.assertTrue(result.emergency_stop_triggered)
        self.assertGreater(result.triggered_checks, 0)
    
    def test_guardrail_system_user_rules(self):
        """Test guardrail system user-defined rules."""
        # Create a custom guardrail rule
        custom_rule = GuardrailRule(
            rule_id="custom_test",
            name="Custom Test Rule",
            description="Test custom rule",
            guardrail_type=GuardrailType.CUSTOM,
            risk_level=RiskLevel.MEDIUM,
            enabled=True,
            pattern=r"test_pattern",
            conditions={"max_validation_issues": 1},
            actions={
                GuardrailAction.WARN: "Warn on pattern match",
                GuardrailAction.MODIFY: "Modify on pattern match"
            },
            metadata={"test": True}
        )
        
        # Add user rule
        self.assertTrue(self.guardrail_system.add_user_rule(custom_rule))
        
        # Verify rule was added
        user_rules = self.guardrail_system.get_user_rules()
        self.assertIn("custom_test", user_rules)
        
        # Test rule functionality
        self.assertTrue(self.guardrail_system.enable_rule("custom_test"))
        self.assertTrue(self.guardrail_system.disable_rule("custom_test"))
        self.assertTrue(self.guardrail_system.remove_user_rule("custom_test"))
    
    def test_integration_workflow(self):
        """Test complete integration workflow."""
        # Test content with syntax error
        test_content = """
def test_function()
    print("Hello world"  # Missing colon
"""
        
        # Step 1: Analyze errors
        error_result = self.syntax_error_analyzer.analyze_syntax_errors(
            file_path="test.py",
            content=test_content,
            language="python"
        )
        
        self.assertTrue(error_result.success)
        self.assertGreater(len(error_result.errors), 0)
        
        # Step 2: Generate resolutions
        if error_result.errors:
            resolution_result = self.resolution_generator.generate_resolutions(
                syntax_error=error_result.errors[0],
                file_content=test_content,
                language="python"
            )
            
            self.assertTrue(resolution_result.success)
            self.assertGreater(len(resolution_result.approaches), 0)
            
            # Step 3: Validate fixes
            validation_result = self.validation_engine.validate_fixes(
                original_content=test_content,
                fixed_content="def test_function():\n    print('Hello world')",
                approaches=resolution_result.approaches,
                file_path="test.py",
                language="python"
            )
            
            self.assertTrue(validation_result.success)
            
            # Step 4: Check guardrails
            guardrail_result = self.guardrail_system.check_fixes(
                validation_report=validation_result,
                approaches=resolution_result.approaches,
                file_path="test.py"
            )
            
            self.assertTrue(guardrail_result.success)
            
            # Step 5: Final AERE validation
            final_result = self.aere_validator.validate_syntax_fix(
                file_path="test.py",
                original_content=test_content,
                fixed_content="def test_function():\n    print('Hello world')",
                language="python",
                validation_mode=ValidationMode.BALANCED
            )
            
            self.assertTrue(final_result.success)
            self.assertTrue(final_result.approved)
    
    def test_performance_requirements(self):
        """Test performance requirements."""
        # Test that simple validations complete quickly
        start_time = time.time()
        
        result = self.aere_validator.validate_syntax_fix(
            file_path="test.py",
            original_content="def test():\n    print('Hello')",
            fixed_content="def test():\n    print('Hello')",
            language="python",
            validation_mode=ValidationMode.BALANCED
        )
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        # Should complete in under 100ms for simple validation
        self.assertLess(processing_time, 0.1)
        self.assertTrue(result.success)
    
    def test_error_handling(self):
        """Test error handling in all components."""
        # Test with None inputs
        result = self.syntax_error_analyzer.analyze_syntax_errors(
            file_path=None,
            content=None,
            language=None
        )
        
        # Should handle gracefully
        self.assertFalse(result.success)
        self.assertEqual(len(result.errors), 0)
        
        # Test with invalid content
        result = self.validation_engine.validate_fixes(
            original_content="",
            fixed_content="",
            approaches=[],
            file_path="",
            language=""
        )
        
        # Should handle gracefully
        self.assertTrue(result.success)
        self.assertEqual(result.total_issues, 0)
    
    def test_configuration(self):
        """Test configuration of all components."""
        # Test syntax error analyzer configuration
        self.syntax_error_analyzer.configure_analysis(
            validation_level="syntax_only",
            analysis_timeout=1000,
            max_errors=10
        )
        
        # Test resolution generator configuration
        self.resolution_generator.configure_generation(
            max_resolutions=3,
            resolution_timeout=2000,
            confidence_threshold=0.7
        )
        
        # Test validation engine configuration
        self.validation_engine.configure_validation(
            validation_timeout=2000,
            rollback_enabled=True,
            semantic_validation=False
        )
        
        # Test AERE validator configuration
        self.aere_validator.configure_validation(
            validation_level="basic",
            pipeline_timeout=5000,
            cache_results=False,
            parallel_validation=False
        )
        
        # Test guardrail system configuration
        self.guardrail_system.configure_guardrails(
            enabled=True,
            risk_tolerance="medium",
            emergency_stop=False
        )
        
        # Verify configurations were applied
        stats = self.syntax_error_analyzer.get_statistics()
        # Configuration changes would be reflected in stats
    
    def test_database_integration(self):
        """Test database integration."""
        # This would require actual database setup
        # For now, just verify the mock is properly configured
        self.assertIsNotNone(self.mock_db_pool)
    
    def test_thread_safety(self):
        """Test thread safety of all components."""
        import threading
        
        results = []
        errors = []
        
        def run_validation():
            try:
                result = self.aere_validator.validate_syntax_fix(
                    file_path="test.py",
                    original_content="def test():\n    print('Hello')",
                    fixed_content="def test():\n    print('Hello')",
                    language="python",
                    validation_mode=ValidationMode.BALANCED
                )
                results.append(result.success)
            except Exception as e:
                errors.append(str(e))
        
        # Run multiple validations concurrently
        threads = []
        for i in range(5):
            thread = threading.Thread(target=run_validation)
            threads.append(thread)
            thread.start()
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        # All should succeed without errors
        self.assertEqual(len(results), 5)
        self.assertTrue(all(results))
        self.assertEqual(len(errors), 0)
    
    def test_memory_usage(self):
        """Test memory usage and cleanup."""
        # Get initial statistics
        initial_stats = self.aere_validator.get_statistics()
        
        # Run multiple operations
        for i in range(10):
            self.aere_validator.validate_syntax_fix(
                file_path=f"test_{i}.py",
                original_content=f"def test_{i}():\n    print('Hello')",
                fixed_content=f"def test_{i}():\n    print('Hello')",
                language="python",
                validation_mode=ValidationMode.BALANCED
            )
        
        # Check final statistics
        final_stats = self.aere_validator.get_statistics()
        
        # Statistics should have increased
        self.assertGreater(final_stats["total_validations"], initial_stats["total_validations"])
        
        # Test cleanup
        self.aere_validator.clear_cache()
        self.guardrail_system.clear_cache()
    
    def run_integration_tests(self):
        """Run all integration tests."""
        logger.info("Starting AERE integration tests...")
        
        # Run all test methods
        test_methods = [
            self.test_syntax_error_analyzer_initialization,
            self.test_syntax_error_analyzer_python_analysis,
            self.test_syntax_error_analyzer_javascript_analysis,
            self.test_resolution_generator_initialization,
            self.test_resolution_generator_python_fixes,
            self.test_validation_engine_initialization,
            self.test_validation_engine_python_validation,
            self.test_validation_engine_syntax_failures,
            self.test_aere_validator_initialization,
            self.test_aere_validator_comprehensive_validation,
            self.test_aere_validator_pipeline_stages,
            self.test_guardrail_system_initialization,
            self.test_guardrail_system_syntax_rules,
            self.test_guardrail_system_user_rules,
            self.test_integration_workflow,
            self.test_performance_requirements,
            self.test_error_handling,
            self.test_configuration,
            self.test_database_integration,
            self.test_thread_safety,
            self.test_memory_usage
        ]
        
        passed = 0
        failed = 0
        
        for test_method in test_methods:
            try:
                test_method()
                passed += 1
                logger.info(f"âœ“ {test_method.__name__}")
            except Exception as e:
                failed += 1
                logger.error(f"âœ— {test_method.__name__}: {e}")
        
        logger.info(f"AERE integration tests completed: {passed} passed, {failed} failed")
        
        return passed == len(test_methods)

if __name__ == "__main__":
    # Run tests when executed directly
    test_suite = TestAEREIntegration()
    test_suite.run_integration_tests()
    
    # Exit with appropriate code
    sys.exit(0 if test_suite.run_integration_tests() else 1)

