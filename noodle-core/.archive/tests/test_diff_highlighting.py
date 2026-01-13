#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_diff_highlighting.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for diff highlighting functionality in NoodleCore IDE.

This script creates a test file and simulates a self-improvement
to verify that the diff highlighting system works correctly.
"""

import os
import sys
import tempfile
from pathlib import Path

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent))

def test_diff_highlighting():
    """Test the diff highlighting functionality."""
    print("Testing Diff Highlighting Functionality")
    print("=" * 50)
    
    # Create a temporary Python file for testing
    test_content = '''# Test Python file for diff highlighting
def old_function():
    """This is an old function that needs improvement."""
    print("Hello, World!")
    return "old result"

def main():
    result = old_function()
    print(f"Result: {result}")
    
if __name__ == "__main__":
    main()
'''
    
    improved_content = '''# Test Python file for diff highlighting
def improved_function():
    """This is an improved function with better documentation."""
    print("Hello, World!")
    return "improved result"

def main():
    result = improved_function()
    print(f"Result: {result}")
    
if __name__ == "__main__":
    main()
'''
    
    # Create temporary file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as temp_file:
        temp_file.write(test_content)
        temp_file_path = temp_file.name
    
    print(f"Created test file: {temp_file_path}")
    
    try:
        # Import the self-improvement integration
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create a mock improvement
        improvement = {
            'type': 'code_analysis',
            'description': 'Test improvement for diff highlighting',
            'priority': 'medium',
            'source': 'test_script',
            'file': temp_file_path,
            'suggestion': 'Improve function name and documentation'
        }
        
        # Create a mock IDE instance
        class MockIDE:
            def __init__(self):
                self.open_file_calls = []
                self.diff_highlighting_calls = []
            
            def _open_file_in_explorer(self, file_path):
                self.open_file_calls.append(file_path)
                print(f"[FILE] Mock IDE: Opening file {file_path}")
            
            def _apply_diff_highlighting_to_editor(self, file_path, diff_lines, diff_summary, improvement, original_content, improved_content):
                self.diff_highlighting_calls.append({
                    'file_path': file_path,
                    'diff_lines_count': len(diff_lines),
                    'diff_summary': diff_summary
                })
                print(f"[DIFF] Mock IDE: Applying diff highlighting to {file_path}")
                print(f"   - Diff lines: {len(diff_lines)}")
                print(f"   - Summary: {diff_summary}")
                print(f"   - Improvement type: {improvement.get('type')}")
        
        # Create self-improvement integration instance
        mock_ide = MockIDE()
        si_integration = SelfImprovementIntegration(mock_ide)
        
        # Simulate the improvement process
        print("\n[TOOL] Simulating improvement process...")
        
        # First, apply the improvement (this should trigger diff highlighting)
        success = si_integration._apply_improvement(improvement)
        
        if success:
            print("[OK] Improvement applied successfully!")
            
            # Check if diff highlighting was called
            if len(mock_ide.diff_highlighting_calls) > 0:
                diff_call = mock_ide.diff_highlighting_calls[0]
                print("[OK] Diff highlighting was triggered!")
                print(f"   - File: {diff_call['file_path']}")
                print(f"   - Diff lines processed: {diff_call['diff_lines_count']}")
                print(f"   - Changes detected: {diff_call['diff_summary'].get('total_changes', 0)}")
            else:
                print("[FAIL] Diff highlighting was NOT triggered!")
        else:
            print("[FAIL] Improvement failed!")
        
        print("\nðŸ“Š Test Results:")
        print(f"   - File opened: {len(mock_ide.open_file_calls)} times")
        print(f"   - Diff highlighting calls: {len(mock_ide.diff_highlighting_calls)}")
        
        # Clean up
        try:
            os.unlink(temp_file_path)
            print(f"[CLEAN] Cleaned up test file: {temp_file_path}")
        except Exception as e:
            print(f"[WARN] Failed to clean up test file: {e}")
        
        print("\n" + "=" * 50)
        print("[DONE] Test completed!")
        
        return len(mock_ide.diff_highlighting_calls) > 0
        
    except ImportError as e:
        print(f"[FAIL] Failed to import self-improvement integration: {e}")
        return False
    except Exception as e:
        print(f"[FAIL] Test failed with error: {e}")
        return False

if __name__ == "__main__":
    success = test_diff_highlighting()
    if success:
        print("\n[SUCCESS] All tests passed! Diff highlighting is working correctly.")
        sys.exit(0)
    else:
        print("\n[FAIL] Some tests failed. Please check the implementation.")
        sys.exit(1)

