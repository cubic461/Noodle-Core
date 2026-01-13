#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_launcher_quick.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Desktop GUI IDE - Quick Test Suite

Basic validation tests for the NoodleCore IDE launcher system.
"""

import sys
import os
import unittest
from unittest.mock import Mock, patch
from pathlib import Path
import tempfile
import shutil

# Add noodle-core to path
sys.path.insert(0, str(Path(__file__).parent))

try:
    from launch_noodlecore_ide import (
        NoodleCoreIDEDemonstrator, LauncherConfiguration, LaunchMode, DemoScenario
    )
except ImportError as e:
    print(f"Warning: Could not import launcher modules: {e}")


class TestLauncherBasic(unittest.TestCase):
    """Basic launcher tests."""
    
    def setUp(self):
        """Set up test configuration."""
        self.config = LauncherConfiguration(
            auto_start_backend=False,
            debug_mode=True,
            log_file=None
        )
        self.demonstrator = NoodleCoreIDEDemonstrator(self.config)
    
    def tearDown(self):
        """Clean up after tests."""
        # Clean up demo files
        demo_dir = Path("demo_projects")
        if demo_dir.exists():
            shutil.rmtree(demo_dir)
    
    def test_configuration_default(self):
        """Test default configuration values."""
        self.assertEqual(self.config.mode, LaunchMode.STANDARD)
        self.assertTrue(self.config.auto_start_backend)
        self.assertEqual(self.config.backend_url, "http://localhost:8080")
        self.assertFalse(self.config.debug_mode)
    
    def test_demonstrator_initialization(self):
        """Test demonstrator initialization."""
        self.assertEqual(self.demonstrator.config, self.config)
        self.assertFalse(self.demonstrator.is_backend_running)
        self.assertFalse(self.demonstrator.is_ide_launched)
        self.assertIsNotNone(self.demonstrator.demo_content)
    
    def test_user_feedback(self):
        """Test user feedback functionality."""
        with patch('builtins.print') as mock_print:
            self.demonstrator.show_user_feedback("Test message", "info")
            mock_print.assert_called()
    
    def test_error_handling(self):
        """Test error handling."""
        test_error = ValueError("Test error")
        error_id = self.demonstrator.handle_error_gracefully(
            test_error, "test_context", "Test error message"
        )
        self.assertTrue(error_id.startswith("NC-"))
    
    def test_recovery_suggestions(self):
        """Test recovery suggestions."""
        backend_error = Exception("Backend connection failed")
        suggestions = self.demonstrator._get_recovery_suggestions(backend_error, "backend")
        self.assertTrue(len(suggestions) > 0)
        self.assertTrue(any("backend" in s.lower() for s in suggestions))
    
    def test_demo_content_creation(self):
        """Test demo content creation."""
        content = self.demonstrator.demo_content
        
        self.assertIn("welcome_message", content)
        self.assertIn("sample_files", content)
        self.assertIn("demo_projects", content)
        self.assertIn("feature_examples", content)
        
        # Check sample files
        sample_files = content["sample_files"]
        self.assertIn("welcome.py", sample_files)
        self.assertIn("example.js", sample_files)
        self.assertIn("demo.css", sample_files)
    
    def test_demo_setup(self):
        """Test demo content setup."""
        result = self.demonstrator._setup_demo_content()
        self.assertTrue(result)
        
        # Check demo files were created
        demo_dir = Path("demo_projects")
        self.assertTrue(demo_dir.exists())
        
        # Check specific files
        welcome_file = demo_dir / "welcome.py"
        self.assertTrue(welcome_file.exists())
        
        # Check file content
        welcome_content = welcome_file.read_text()
        self.assertIn("fibonacci", welcome_content)


def run_quick_tests():
    """Run quick validation tests."""
    print("ðŸ§ª NoodleCore IDE Launcher - Quick Test Suite")
    print("=" * 50)
    
    # Create test suite
    suite = unittest.TestLoader().loadTestsFromTestCase(TestLauncherBasic)
    runner = unittest.TextTestRunner(verbosity=1)
    result = runner.run(suite)
    
    # Summary
    print("\n" + "=" * 50)
    print("ðŸ“Š Test Summary:")
    print(f"   Total Tests: {result.testsRun}")
    print(f"   Passed: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"   Failed: {len(result.failures)}")
    print(f"   Errors: {len(result.errors)}")
    
    if result.failures == 0 and result.errors == 0:
        print("\nðŸŽ‰ All tests passed! Launcher system is working correctly.")
        return 0
    else:
        print("\nâš ï¸  Some tests failed. Please review issues.")
        return 1


if __name__ == "__main__":
    exit_code = run_quick_tests()
    sys.exit(exit_code)

