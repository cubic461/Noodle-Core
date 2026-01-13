#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_diff_functionality.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for diff highlighting functionality in NoodleCore IDE.

This script tests:
1. Auto-apply configuration is enabled
2. Diff highlighting functionality works correctly
"""

import sys
import os
import tempfile
from pathlib import Path

# Add noodle-core to path
sys.path.insert(0, str(Path(__file__).parent))

def test_auto_apply_configuration():
    """Test that auto_apply_improvements is enabled by default."""
    print("\nTesting Auto-Apply Configuration")
    print("-" * 30)
    
    try:
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create mock IDE
        class MockIDE:
            def register_self_improvement_callback(self, callback):
                pass
        
        mock_ide = MockIDE()
        si_integration = SelfImprovementIntegration(mock_ide)
        
        # Get default configuration
        config = si_integration.config
        
        if config.get('auto_apply_improvements', False):
            print("[OK] auto_apply_improvements is enabled by default")
            return True
        else:
            print("[X] auto_apply_improvements is disabled by default")
            return False
            
    except Exception as e:
        print("[X] Configuration test failed: {0}".format(str(e)))
        return False

def test_diff_highlighting():
    """Test diff highlighting functionality."""
    print("\nTesting Diff Highlighting Functionality")
    print("-" * 40)
    
    try:
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create mock IDE with callback tracking
        callback_data = {}
        
        class MockIDE:
            def register_self_improvement_callback(self, callback):
                # Store callback for testing
                callback_data['callback'] = callback
        
        mock_ide = MockIDE()
        si_integration = SelfImprovementIntegration(mock_ide)
        
        # Test diff generation
        original_content = """def hello_world():
    print("Hello, World!")
    return True"""
        
        improved_content = """def hello_world():
    print("Hello, World!")
    print("This is an improvement!")
    return True"""
        
        # Create temporary file for testing
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(improved_content)
            temp_file = f.name
        
        try:
            # Test diff summary creation
            diff_summary = si_integration._create_diff_summary(original_content, improved_content)
            
            if diff_summary.get('lines_added', 0) > 0:
                print("[OK] Diff summary correctly identifies added lines")
            else:
                print("[X] Diff summary failed to identify added lines")
                return False
            
            # Test callback registration
            if 'callback' in callback_data:
                print("[OK] IDE callback registered successfully")
                
                # Test callback invocation
                test_data = {
                    'file_path': temp_file,
                    'diff_lines': ['test diff'],
                    'diff_summary': diff_summary,
                    'improvement': {'type': 'test'}
                }
                
                try:
                    callback_data['callback']('show_diff_highlighting', test_data)
                    print("[OK] Callback invoked successfully")
                except Exception as e:
                    print("[X] Callback invocation failed: {0}".format(str(e)))
                    return False
            else:
                print("[X] IDE callback not registered")
                return False
            
            print("[OK] Diff highlighting test passed")
            return True
            
        finally:
            # Clean up temporary file
            if os.path.exists(temp_file):
                os.unlink(temp_file)
            
    except Exception as e:
        print("[X] Diff highlighting test failed: {0}".format(str(e)))
        return False

if __name__ == "__main__":
    print("Starting Diff Highlighting Tests")
    print("=" * 60)
    
    # Test 1: Auto-apply configuration
    config_test_passed = test_auto_apply_configuration()
    
    # Test 2: Diff highlighting functionality
    diff_test_passed = test_diff_highlighting()
    
    # Summary
    print("\nTEST SUMMARY")
    print("=" * 30)
    print("Configuration Test: {0}".format('[OK] PASSED' if config_test_passed else '[X] FAILED'))
    print("Diff Highlighting Test: {0}".format('[OK] PASSED' if diff_test_passed else '[X] FAILED'))
    
    if config_test_passed and diff_test_passed:
        print("\nALL TESTS PASSED!")
        print("Diff highlighting functionality is working correctly!")
        sys.exit(0)
    else:
        print("\nSOME TESTS FAILED!")
        print("Please check the implementation.")
        sys.exit(1)

