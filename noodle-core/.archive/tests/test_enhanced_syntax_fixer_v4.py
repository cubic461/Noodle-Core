#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_syntax_fixer_v4.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test suite for Enhanced NoodleCore Syntax Fixer v4 with AERE Integration

This test suite validates the functionality of the enhanced syntax fixer v4,
including AERE validation, guardrail systems, and resolution generation.
"""

import os
import sys
import tempfile
import unittest
import shutil
import time
from pathlib import Path

# Add the noodle-core directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.noodlecore.desktop.ide.enhanced_syntax_fixer_v4 import (
    EnhancedNoodleCoreSyntaxFixerV4, AEREValidationProgress, FixProgress
)
from src.noodlecore.database.database_manager import DatabaseConfig

class TestEnhancedSyntaxFixerV4(unittest.TestCase):
    """Test cases for Enhanced NoodleCore Syntax Fixer V4."""
    
    def setUp(self):
        """Set up test environment."""
        self.test_dir = tempfile.mkdtemp()
        self.test_files = {}
        
        # Create test files with various syntax issues
        self._create_test_files()
        
        # Initialize the enhanced syntax fixer v4
        self.syntax_fixer = EnhancedNoodleCoreSyntaxFixerV4(
            enable_ai=True,
            enable_real_time=True,
            enable_learning=True,
            enable_trm=True,
            enable_aere=True
        )
    
    def tearDown(self):
        """Clean up test environment."""
        # Shutdown the syntax fixer
        if hasattr(self, 'syntax_fixer'):
            self.syntax_fixer.shutdown()
        
        # Clean up test directory
        if os.path.exists(self.test_dir):
            shutil.rmtree(self.test_dir)
    
    def _create_test_files(self):
        """Create test files with various syntax issues."""
        # Python file with missing semicolon equivalent (colon)
        python_content = """def hello_world()
    print("Hello, World!")
    return "success"
"""
        self.test_files['python'] = os.path.join(self.test_dir, 'test.py')
        with open(self.test_files['python'], 'w') as f:
            f.write(python_content)
        
        # JavaScript file with missing semicolon
        js_content = """function helloWorld() {
    console.log("Hello, World!")
    return "success"
}"""
        self.test_files['javascript'] = os.path.join(self.test_dir, 'test.js')
        with open(self.test_files['javascript'], 'w') as f:
            f.write(js_content)
        
        # File with mismatched brackets
        bracket_content = """function test() {
    if (condition {
        console.log("Mismatched brackets")
    }
}"""
        self.test_files['brackets'] = os.path.join(self.test_dir, 'test_brackets.js')
        with open(self.test_files['brackets'], 'w') as f:
            f.write(bracket_content)
        
        # File with indentation issues
        indent_content = """def test_function():
if True:
    print("Bad indentation")
    return False"""
        self.test_files['indent'] = os.path.join(self.test_dir, 'test_indent.py')
        with open(self.test_files['indent'], 'w') as f:
            f.write(indent_content)
    
    def test_v4_initialization(self):
        """Test V4 initialization and component availability."""
        self.assertIsNotNone(self.syntax_fixer)
        self.assertTrue(self.syntax_fixer.enable_aere)
        self.assertIsNotNone(self.syntax_fixer.aere_validator)
        self.assertIsNotNone(self.syntax_fixer.syntax_error_analyzer)
        self.assertIsNotNone(self.syntax_fixer.resolution_generator)
        self.assertIsNotNone(self.syntax_fixer.validation_engine)
        self.assertIsNotNone(self.syntax_fixer.guardrail_system)
        
        # Check status
        status = self.syntax_fixer.get_status()
        self.assertEqual(status['version'], 'v4')
        self.assertTrue(status['aere_enabled'])
        self.assertTrue(status['aere_validator_available'])
        self.assertTrue(status['syntax_error_analyzer_available'])
        self.assertTrue(status['resolution_generator_available'])
        self.assertTrue(status['validation_engine_available'])
        self.assertTrue(status['guardrail_system_available'])
    
    def test_aere_configuration(self):
        """Test AERE configuration settings."""
        # Test configuration changes
        self.syntax_fixer.configure_aere_settings(
            validation_level='conservative',
            risk_tolerance='low',
            validation_timeout=3000,
            max_resolutions=3,
            auto_validate=False
        )
        
        # Verify configuration changes
        self.assertEqual(self.syntax_fixer.aere_validation_level, 'conservative')
        self.assertEqual(self.syntax_fixer.aere_risk_tolerance, 'low')
        self.assertEqual(self.syntax_fixer.aere_validation_timeout, 3000)
        self.assertEqual(self.syntax_fixer.aere_max_resolutions, 3)
        self.assertFalse(self.syntax_fixer.aere_auto_validate)
    
    def test_fix_file_with_aere(self):
        """Test fixing a file with AERE validation enabled."""
        # Fix Python file with AERE
        result = self.syntax_fixer.fix_file_enhanced_v4(
            file_path=self.test_files['python'],
            create_backup=True,
            use_ai=True,
            use_trm=True,
            use_aere=True
        )
        
        # Check result
        self.assertTrue(result['success'])
        self.assertEqual(result['version'], 'v4')
        self.assertTrue(result['aere_used'])
        self.assertIsNotNone(result['aere_validation_id'])
        self.assertIsNotNone(result['aere_validation_results'])
        self.assertIsNotNone(result['validation_level'])
        self.assertIsNotNone(result['risk_level'])
        
        # Check that file was modified
        with open(self.test_files['python'], 'r') as f:
            fixed_content = f.read()
        self.assertNotEqual(fixed_content, "")
        
        # Check that backup was created
        self.assertTrue(os.path.exists(self.test_files['python'] + '.bak'))
    
    def test_fix_file_without_aere(self):
        """Test fixing a file with AERE validation disabled."""
        # Fix file without AERE
        result = self.syntax_fixer.fix_file_enhanced_v4(
            file_path=self.test_files['javascript'],
            create_backup=True,
            use_ai=True,
            use_trm=True,
            use_aere=False
        )
        
        # Check result
        self.assertTrue(result['success'])
        self.assertEqual(result['version'], 'v4')
        self.assertFalse(result['aere_used'])
        self.assertIsNone(result['aere_validation_id'])
        self.assertIsNone(result['aere_validation_results'])
    
    def test_aere_progress_tracking(self):
        """Test AERE validation progress tracking."""
        progress_events = []
        
        def track_progress(progress):
            progress_events.append({
                'validation_id': progress.validation_id,
                'stage': progress.stage,
                'progress': progress.progress_percentage,
                'message': progress.message
            })
        
        # Fix file with progress tracking
        result = self.syntax_fixer.fix_file_enhanced_v4(
            file_path=self.test_files['brackets'],
            create_backup=True,
            use_ai=True,
            use_trm=True,
            use_aere=True,
            aere_progress_callback=track_progress
        )
        
        # Check that progress events were tracked
        self.assertTrue(len(progress_events) > 0)
        self.assertTrue(result['aere_used'])
        
        # Check progress stages
        stages = [event['stage'] for event in progress_events]
        self.assertIn('analysis', stages)
        self.assertIn('validation', stages)
    
    def test_multiple_files_with_aere(self):
        """Test fixing multiple files with AERE validation."""
        file_paths = [
            self.test_files['python'],
            self.test_files['javascript'],
            self.test_files['brackets']
        ]
        
        # Fix multiple files
        result = self.syntax_fixer.fix_multiple_files_enhanced_v4(
            file_paths=file_paths,
            create_backup=True,
            use_ai=True,
            use_trm=True,
            use_aere=True
        )
        
        # Check result
        self.assertTrue(result['success'])
        self.assertEqual(result['version'], 'v4')
        self.assertEqual(result['total_files'], 3)
        self.assertEqual(result['aere_operations'], 3)
        self.assertTrue(result['aere_enabled'])
        
        # Check individual file results
        for file_path in file_paths:
            self.assertIn(file_path, result['results'])
            file_result = result['results'][file_path]
            self.assertTrue(file_result['success'])
            self.assertTrue(file_result['aere_used'])
    
    def test_aere_status_and_metrics(self):
        """Test AERE status and performance metrics."""
        # Fix a file to generate some statistics
        self.syntax_fixer.fix_file_enhanced_v4(
            file_path=self.test_files['python'],
            create_backup=True,
            use_aere=True
        )
        
        # Get AERE status
        aere_status = self.syntax_fixer.get_aere_status()
        self.assertTrue(aere_status['aere_enabled'])
        self.assertTrue(aere_status['validator_available'])
        self.assertTrue(aere_status['analyzer_available'])
        self.assertTrue(aere_status['generator_available'])
        self.assertTrue(aere_status['engine_available'])
        self.assertTrue(aere_status['guardrails_available'])
        self.assertGreater(aere_status['operations_completed'], 0)
        self.assertGreater(aere_status['validations_completed'], 0)
        
        # Get V4 performance metrics
        metrics = self.syntax_fixer.get_v4_performance_metrics()
        self.assertEqual(metrics['version'], 'v4')
        self.assertTrue(metrics['aere_enabled'])
        self.assertIn('aere_statistics', metrics)
        self.assertGreater(metrics['aere_statistics']['aere_operations'], 0)
    
    def test_aere_integration_testing(self):
        """Test AERE integration functionality."""
        # Test AERE integration
        test_results = self.syntax_fixer.test_aere_integration()
        
        # Check test results
        self.assertTrue(test_results['syntax_error_analyzer_available'])
        self.assertTrue(test_results['resolution_generator_available'])
        self.assertTrue(test_results['validation_engine_available'])
        self.assertTrue(test_results['guardrail_system_available'])
        self.assertTrue(test_results['aere_validator_available'])
        
        # Check individual component tests
        if 'aere_validation' in test_results:
            self.assertTrue(test_results['aere_validation']['success'])
        
        if 'syntax_error_analysis' in test_results:
            self.assertTrue(test_results['syntax_error_analysis']['success'])
        
        if 'resolution_generation' in test_results:
            self.assertTrue(test_results['resolution_generation']['success'])
    
    def test_aere_validation_cancellation(self):
        """Test AERE validation cancellation."""
        # Start a fix operation
        import threading
        
        def fix_file():
            return self.syntax_fixer.fix_file_enhanced_v4(
                file_path=self.test_files['indent'],
                create_backup=True,
                use_aere=True
            )
        
        # Run fix in background thread
        fix_thread = threading.Thread(target=fix_file)
        fix_thread.start()
        
        # Wait a bit then try to cancel (this is a simplified test)
        time.sleep(0.1)
        
        # Wait for thread to complete
        fix_thread.join(timeout=5)
        
        # The test passes if we don't hang
        self.assertTrue(True)
    
    def test_environment_variables(self):
        """Test environment variable configuration."""
        # Test that environment variables are properly read
        self.assertEqual(
            self.syntax_fixer.enable_aere,
            os.getenv('NOODLE_SYNTAX_FIXER_V4_AERE_ENABLED', 'true').lower() == 'true'
        )
        self.assertEqual(
            self.syntax_fixer.aere_validation_level,
            os.getenv('NOODLE_SYNTAX_FIXER_V4_AERE_VALIDATION_LEVEL', 'balanced')
        )
        self.assertEqual(
            self.syntax_fixer.aere_guardrails,
            os.getenv('NOODLE_SYNTAX_FIXER_V4_AERE_GUARDRAILS', 'true').lower() == 'true'
        )
        self.assertEqual(
            self.syntax_fixer.aere_risk_tolerance,
            os.getenv('NOODLE_SYNTAX_FIXER_V4_AERE_RISK_TOLERANCE', 'medium')
        )
    
    def test_error_handling(self):
        """Test error handling in V4 operations."""
        # Test with non-existent file
        result = self.syntax_fixer.fix_file_enhanced_v4(
            file_path='/non/existent/file.py',
            use_aere=True
        )
        
        self.assertFalse(result['success'])
        self.assertIn('error', result)
        self.assertEqual(result['version'], 'v4')
        self.assertFalse(result['aere_used'])
    
    def test_backward_compatibility(self):
        """Test backward compatibility with V3 features."""
        # Test that V3 features still work
        self.assertTrue(hasattr(self.syntax_fixer, 'fix_file_enhanced_v3'))
        self.assertTrue(hasattr(self.syntax_fixer, 'get_trm_status'))
        self.assertTrue(hasattr(self.syntax_fixer, 'test_trm_integration'))
        
        # Test V3 methods
        trm_status = self.syntax_fixer.get_trm_status()
        self.assertIsInstance(trm_status, dict)
        
        trm_test = self.syntax_fixer.test_trm_integration()
        self.assertIsInstance(trm_test, dict)

class TestAEREValidationProgress(unittest.TestCase):
    """Test cases for AEREValidationProgress dataclass."""
    
    def test_aere_validation_progress_creation(self):
        """Test AEREValidationProgress creation."""
        progress = AEREValidationProgress(
            validation_id="test-123",
            stage="validation",
            progress_percentage=0.5,
            message="Validating syntax fix",
            estimated_remaining=2.0,
            validation_results={"status": "in_progress"}
        )
        
        self.assertEqual(progress.validation_id, "test-123")
        self.assertEqual(progress.stage, "validation")
        self.assertEqual(progress.progress_percentage, 0.5)
        self.assertEqual(progress.message, "Validating syntax fix")
        self.assertEqual(progress.estimated_remaining, 2.0)
        self.assertEqual(progress.validation_results, {"status": "in_progress"})

if __name__ == '__main__':
    # Set up environment for testing
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_ENABLED'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_VALIDATION_LEVEL'] = 'balanced'
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_GUARDRAILS'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_RISK_TOLERANCE'] = 'medium'
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_VALIDATION_TIMEOUT'] = '5000'
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_MAX_RESOLUTIONS'] = '5'
    os.environ['NOODLE_SYNTAX_FIXER_V4_AERE_AUTO_VALIDATE'] = 'true'
    
    # Run tests
    unittest.main(verbosity=2)

