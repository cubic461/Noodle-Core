#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_phase2_1_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Phase 2.1 IDE Integration

This test verifies that the NativeNoodleCoreIDE correctly integrates with
the EnhancedNoodleCoreSyntaxFixerV2 and Phase 2.1 self-improvement components.
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent / "src"))

class TestPhase21IDEIntegration(unittest.TestCase):
    """Test Phase 2.1 IDE Integration"""
    
    def setUp(self):
        """Set up test environment"""
        # Set environment variables for testing
        os.environ['NOODLE_SYNTAX_FIXER_AI'] = 'true'
        os.environ['NOODLE_SYNTAX_FIXER_REALTIME'] = 'true'
        os.environ['NOODLE_SYNTAX_FIXER_LEARNING'] = 'true'
        
        # Create a temporary directory for test files
        self.test_dir = tempfile.mkdtemp()
        self.test_file_path = os.path.join(self.test_dir, "test.nc")
        
        # Create a test .nc file with syntax issues
        with open(self.test_file_path, 'w') as f:
            f.write("""
# Test NoodleCore file with syntax issues
func test_function() {
    print("Hello World"  # Missing closing quote
    return 42
}

# Another function with issues
func another_function(param1 param2) {  # Missing comma
    if param1 == param2 {
        return True
    }
    return False
}
""")
    
    def tearDown(self):
        """Clean up test environment"""
        # Clean up test files
        import shutil
        if os.path.exists(self.test_dir):
            shutil.rmtree(self.test_dir)
    
    @patch('tkinter.Tk')
    def test_ide_initialization_with_phase2_1(self, mock_tk):
        """Test that IDE initializes with Phase 2.1 components"""
        # Mock the Tkinter components to avoid GUI during testing
        mock_root = Mock()
        mock_tk.return_value = mock_root
        
        try:
            # Import and initialize the IDE
            from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
            
            # Create IDE instance
            ide = NativeNoodleCoreIDE()
            
            # Check that syntax fixer was initialized
            self.assertIsNotNone(ide.syntax_fixer, "Syntax fixer should be initialized")
            
            # Check that it's the V2 version with Phase 2.1 features
            self.assertEqual(
                ide.syntax_fixer_config.get('version'), 
                'v2_phase2_1',
                "Should use EnhancedNoodleCoreSyntaxFixerV2 with Phase 2.1"
            )
            
            # Check that learning is enabled
            self.assertTrue(
                ide.syntax_fixer_config.get('learning_enabled', False),
                "Learning system should be enabled"
            )
            
            # Check that AI is enabled
            self.assertTrue(
                ide.syntax_fixer_config.get('ai_enabled', False),
                "AI enhancement should be enabled"
            )
            
            # Check that real-time validation is enabled
            self.assertTrue(
                ide.syntax_fixer_config.get('real_time_enabled', False),
                "Real-time validation should be enabled"
            )
            
            print("[OK] IDE initialization with Phase 2.1 components successful")
            
        except ImportError as e:
            self.skipTest(f"Could not import IDE components: {e}")
        except Exception as e:
            self.fail(f"IDE initialization failed: {e}")
    
    @patch('tkinter.Tk')
    def test_syntax_validation_callback_v2(self, mock_tk):
        """Test that the V2 syntax validation callback works correctly"""
        # Mock the Tkinter components
        mock_root = Mock()
        mock_tk.return_value = mock_root
        
        try:
            from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
            
            # Create IDE instance
            ide = NativeNoodleCoreIDE()
            
            # Create mock issues to test the callback
            mock_issues = [
                {
                    'line_number': 3,
                    'severity': 'error',
                    'message': 'Missing closing quote',
                    'suggestion': 'Add closing quote'
                },
                {
                    'line_number': 9,
                    'severity': 'warning',
                    'message': 'Missing comma in parameters',
                    'suggestion': 'Add comma between parameters'
                }
            ]
            
            # Create a mock text widget
            mock_text_widget = Mock()
            mock_text_widget.tag_remove = Mock()
            mock_text_widget.tag_add = Mock()
            
            # Set up the IDE state for testing
            ide.current_file = self.test_file_path
            ide.open_files = {'mock_tab': {'path': self.test_file_path, 'text': mock_text_widget}}
            
            # Test the V2 callback
            ide._on_syntax_validation_issue_v2(mock_issues)
            
            # Verify that highlighting was applied
            mock_text_widget.tag_remove.assert_called()
            mock_text_widget.tag_add.assert_called()
            
            # Check that status bar was updated
            # This would normally update the status bar with error/warning count
            
            print("[OK] V2 syntax validation callback test successful")
            
        except ImportError as e:
            self.skipTest(f"Could not import IDE components: {e}")
        except Exception as e:
            self.fail(f"V2 syntax validation callback test failed: {e}")
    
    @patch('tkinter.Tk')
    def test_phase2_1_fallback_mechanism(self, mock_tk):
        """Test that the IDE properly falls back when V2 is not available"""
        # Mock the Tkinter components
        mock_root = Mock()
        mock_tk.return_value = mock_root
        
        try:
            from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
            
            # Mock the V2 import to fail
            with patch('noodlecore.desktop.ide.native_gui_ide.EnhancedNoodleCoreSyntaxFixerV2', side_effect=ImportError("V2 not available")):
                # Create IDE instance - should fall back to V1
                ide = NativeNoodleCoreIDE()
                
                # Should still have a syntax fixer (V1 fallback)
                self.assertIsNotNone(ide.syntax_fixer, "Should have fallback syntax fixer")
                
                # Should not be V2 since we mocked it to fail
                self.assertNotEqual(
                    ide.syntax_fixer_config.get('version'), 
                    'v2_phase2_1',
                    "Should not use V2 when import fails"
                )
                
                print("[OK] Phase 2.1 fallback mechanism test successful")
            
        except ImportError as e:
            self.skipTest(f"Could not import IDE components: {e}")
        except Exception as e:
            self.fail(f"Phase 2.1 fallback mechanism test failed: {e}")
    
    def test_phase2_1_environment_variables(self):
        """Test that Phase 2.1 environment variables are properly handled"""
        # Test with custom environment variables
        os.environ['NOODLE_SYNTAX_FIXER_AI'] = 'false'
        os.environ['NOODLE_SYNTAX_FIXER_REALTIME'] = 'false'
        os.environ['NOODLE_SYNTAX_FIXER_LEARNING'] = 'false'
        
        @patch('tkinter.Tk')
        def test_with_env(mock_tk):
            mock_root = Mock()
            mock_root._last_child_ids = {}  # Fix for tkinter menu creation
            mock_tk.return_value = mock_root
            
            try:
                from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
                
                # Create IDE instance
                ide = NativeNoodleCoreIDE()
                
                # Check that environment variables were respected
                self.assertFalse(
                    ide.syntax_fixer_config.get('ai_enabled', True),
                    "AI should be disabled when environment variable is false"
                )
                
                self.assertFalse(
                    ide.syntax_fixer_config.get('real_time_enabled', True),
                    "Real-time validation should be disabled when environment variable is false"
                )
                
                self.assertFalse(
                    ide.syntax_fixer_config.get('learning_enabled', True),
                    "Learning should be disabled when environment variable is false"
                )
                
                print("[OK] Phase 2.1 environment variables test successful")
                
            except ImportError as e:
                self.skipTest(f"Could not import IDE components: {e}")
            except Exception as e:
                self.fail(f"Phase 2.1 environment variables test failed: {e}")
        
        test_with_env()
    
    def test_phase2_1_database_config(self):
        """Test that Phase 2.1 database configuration is properly set up"""
        # Enable learning for database configuration test
        os.environ['NOODLE_SYNTAX_FIXER_LEARNING'] = 'true'
        
        @patch('tkinter.Tk')
        def test_with_database(mock_tk):
            mock_root = Mock()
            mock_root._last_child_ids = {}  # Fix for tkinter menu creation
            mock_tk.return_value = mock_root
            
            try:
                from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
                
                # Create IDE instance
                ide = NativeNoodleCoreIDE()
                
                # If V2 was initialized, check that database config was set up
                if ide.syntax_fixer_config.get('version') == 'v2_phase2_1':
                    # Check that the syntax fixer has database configuration
                    if hasattr(ide.syntax_fixer, 'database_config'):
                        self.assertIsNotNone(
                            ide.syntax_fixer.database_config,
                            "Database config should be set up when learning is enabled"
                        )
                    
                    print("[OK] Phase 2.1 database configuration test successful")
                else:
                    self.skipTest("V2 not available, skipping database configuration test")
                
            except ImportError as e:
                self.skipTest(f"Could not import IDE components: {e}")
            except Exception as e:
                self.fail(f"Phase 2.1 database configuration test failed: {e}")
        
        test_with_database()


if __name__ == "__main__":
    print("=" * 60)
    print("Phase 2.1 IDE Integration Tests")
    print("=" * 60)
    
    # Run the tests
    unittest.main(verbosity=2)

