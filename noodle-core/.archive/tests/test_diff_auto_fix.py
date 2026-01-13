#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_diff_auto_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to validate the automatic diff highlighting fix
"""

import os
import sys
import time
import tempfile
from pathlib import Path

# Add the noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

def test_file_detection():
    """Test if file detection is working properly."""
    print("=== Testing File Detection ===")
    
    # Create a temporary Python file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
        f.write("""
# Test Python file for automatic diff highlighting
def test_function():
    print("This is a test function")
    return True

if __name__ == "__main__":
    test_function()
""")
        temp_file = f.name
    
    try:
        # Import the self-improvement integration
        from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create a mock IDE instance with minimal required attributes
        class MockIDE:
            def __init__(self):
                self.current_project_path = os.path.dirname(temp_file)
                self.status_bar = MockStatusBar()
                self.ai_chat = MockChat()
                self.si_display = MockDisplay()
            
            def register_self_improvement_callback(self, callback):
                self.callback = callback
        
        class MockStatusBar:
            def config(self, text=None):
                if text:
                    print(f"Status bar: {text}")
        
        class MockChat:
            def __init__(self):
                self.content = []
            
            def config(self, state):
                pass
            
            def insert(self, position, text):
                self.content.append(text)
                print(f"AI Chat: {text.strip()}")
            
            def see(self, end):
                pass
        
        class MockDisplay:
            def __init__(self):
                self.content = []
            
            def config(self, state):
                pass
            
            def insert(self, position, text):
                self.content.append(text)
                print(f"SI Display: {text.strip()}")
            
            def see(self, end):
                pass
        
        # Initialize the self-improvement integration
        mock_ide = MockIDE()
        si_integration = SelfImprovementIntegration(mock_ide)
        
        # Test file scanning
        print(f"Scanning project files in: {mock_ide.current_project_path}")
        files = si_integration._scan_project_files(mock_ide.current_project_path)
        print(f"Found {len(files)} files:")
        for file_path, file_info in files.items():
            print(f"  - {file_path} (size: {file_info['size']}, modified: {file_info['modified']})")
        
        # Test file improvement checking
        print(f"\nChecking file for improvements: {temp_file}")
        si_integration._check_file_for_improvements(temp_file)
        
        # Check if improvements were generated
        active_improvements = si_integration.get_active_improvements()
        print(f"\nActive improvements: {len(active_improvements)}")
        for improvement in active_improvements:
            print(f"  - Type: {improvement.get('type')}")
            print(f"    Description: {improvement.get('description')}")
            print(f"    Priority: {improvement.get('priority')}")
            print(f"    Auto-applicable: {improvement.get('auto_applicable')}")
        
        # Test the monitoring loop with file watching
        print("\n=== Testing Monitoring Loop with File Watching ===")
        si_integration.start_monitoring()
        
        # Wait a few seconds to see if file detection works
        print("Waiting 5 seconds for monitoring to detect files...")
        time.sleep(5)
        
        # Create another test file to trigger file watching
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write("""
# Another test file
def another_test():
    return "Another test function"
""")
            temp_file2 = f.name
        
        print(f"Created second test file: {temp_file2}")
        print("Waiting 5 more seconds to see if new file is detected...")
        time.sleep(5)
        
        # Check for new improvements
        new_improvements = si_integration.get_active_improvements()
        print(f"Total improvements after file creation: {len(new_improvements)}")
        
        # Stop monitoring
        si_integration.stop_monitoring()
        
        # Clean up
        os.unlink(temp_file)
        os.unlink(temp_file2)
        
        print("\n=== Test Results ===")
        if len(new_improvements) > 0:
            print("âœ… File detection and improvement generation is working!")
            return True
        else:
            print("âŒ File detection or improvement generation is not working properly")
            return False
            
    except Exception as e:
        print(f"âŒ Error during testing: {e}")
        import traceback
        traceback.print_exc()
        
        # Clean up
        if os.path.exists(temp_file):
            os.unlink(temp_file)
        return False

def test_diff_highlighting():
    """Test the diff highlighting functionality."""
    print("\n=== Testing Diff Highlighting ===")
    
    try:
        from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create test original and improved content
        original_content = """# Original Python file
def old_function():
    print("This is the old version")
    return False
"""
        
        improved_content = """# Improved Python file
def new_function():
    print("This is the improved version")
    return True

def helper_function():
    return "This is a new helper function"
"""
        
        # Create a temporary file with improved content
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(improved_content)
            temp_file = f.name
        
        # Create mock IDE
        class MockIDE:
            def __init__(self):
                self.open_files = {}
                self.notebook = MockNotebook()
                self.status_bar = MockStatusBar()
            
            def show_diff_highlighting(self, file_path, diff_lines, diff_summary, improvement, original_content, improved_content):
                print(f"âœ… Diff highlighting called for: {file_path}")
                print(f"  Lines added: {diff_summary.get('lines_added', 0)}")
                print(f"  Lines removed: {diff_summary.get('lines_removed', 0)}")
                print(f"  Character changes: {diff_summary.get('character_changes', 0)}")
                return True
        
        class MockNotebook:
            def select(self, tab_id):
                pass
        
        class MockStatusBar:
            def config(self, text=None):
                if text:
                    print(f"Status bar: {text}")
        
        # Test diff generation
        si_integration = SelfImprovementIntegration(MockIDE())
        
        # Create a test improvement
        improvement = {
            'type': 'python_conversion',
            'description': 'Test improvement',
            'priority': 'medium',
            'source': 'test'
        }
        
        # Test diff highlighting
        si_integration._show_diff_highlighting(temp_file, original_content, improvement)
        
        # Clean up
        os.unlink(temp_file)
        
        print("âœ… Diff highlighting test completed successfully!")
        return True
        
    except Exception as e:
        print(f"âŒ Error during diff highlighting test: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("Testing automatic diff highlighting fixes...\n")
    
    # Test file detection
    file_detection_ok = test_file_detection()
    
    # Test diff highlighting
    diff_highlighting_ok = test_diff_highlighting()
    
    # Overall result
    print("\n=== Overall Test Results ===")
    if file_detection_ok and diff_highlighting_ok:
        print("âœ… All tests passed! The automatic diff highlighting should now work correctly.")
        sys.exit(0)
    else:
        print("âŒ Some tests failed. Please check the implementation.")
        sys.exit(1)

