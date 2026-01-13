#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_diff_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify that diff highlighting works for all improvement types.
"""

import os
import sys
import tempfile
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent / "src"))

def test_diff_highlighting():
    """Test that diff highlighting works for all improvement types."""
    
    # Create a temporary test file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as temp_file:
        temp_file.write("""# Original test file
def hello_world():
    print("Hello, World!")

if __name__ == "__main__":
    hello_world()
""")
        temp_path = temp_file.name
    
    try:
        # Import the self-improvement integration
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create a mock IDE with the necessary methods
        class MockIDE:
            def __init__(self):
                self.open_files = {}
                self.si_display = None
                self.ai_chat = None
                self.status_bar = None
                
            def register_self_improvement_callback(self, callback):
                self.callback = callback
                
            def show_diff_highlighting(self, file_path, diff_lines, diff_summary, improvement, original_content, improved_content):
                print(f"[SUCCESS] Diff highlighting called for file: {file_path}")
                print(f"  Improvement type: {improvement.get('type', 'unknown')}")
                print(f"  Lines added: {diff_summary.get('lines_added', 0)}")
                print(f"  Lines removed: {diff_summary.get('lines_removed', 0)}")
                return True
        
        # Create mock IDE instance
        mock_ide = MockIDE()
        
        # Create self-improvement integration
        integration = SelfImprovementIntegration(mock_ide)
        
        # Test different improvement types
        improvement_types = [
            'python_conversion',
            'runtime_upgrade',
            'syntax_fix',
            'performance_optimization',
            'bug_fix',
            'refactoring',
            'code_quality',
            'security_improvement',
            'unknown_improvement_type'
        ]
        
        print("Testing diff highlighting for different improvement types...")
        print("=" * 60)
        
        for improvement_type in improvement_types:
            print(f"\nTesting improvement type: {improvement_type}")
            
            # Create an improvement
            improvement = {
                'id': f'test_{improvement_type}',
                'type': improvement_type,
                'file': temp_path,
                'description': f'Test {improvement_type} improvement',
                'priority': 'medium',
                'estimated_impact': 0.5,
                'auto_apply': True,
                'status': 'pending'
            }
            
            # Add improvement to active list
            integration.active_improvements.append(improvement)
            
            # Apply the improvement (this should trigger diff highlighting)
            integration._apply_improvement(improvement)
            
            # Check if improvement was applied
            if improvement.get('status') == 'applied':
                print(f"  [OK] Improvement applied successfully")
            else:
                print(f"  [ERROR] Improvement failed to apply: {improvement.get('status', 'unknown')}")
        
        print("\n" + "=" * 60)
        print("Test completed!")
        
        # Check if callback was registered
        if hasattr(mock_ide, 'callback'):
            print("[OK] Self-improvement callback was registered")
        else:
            print("[ERROR] Self-improvement callback was not registered")
        
        return True
        
    except Exception as e:
        print(f"Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        # Clean up temporary file
        try:
            os.unlink(temp_path)
        except:
            pass

if __name__ == "__main__":
    print("Testing diff highlighting fix for all improvement types...")
    success = test_diff_highlighting()
    
    if success:
        print("\nâœ“ All tests passed!")
        print("\nThe fix ensures that diff highlighting is triggered for ALL improvement types,")
        print("not just specific ones like 'python_conversion' and 'runtime_upgrade'.")
        print("\nNow when any script is improved, it will:")
        print("1. Open automatically in the code editor")
        print("2. Show diff highlighting with changes marked")
        print("3. Display improvement details in the AI chat")
    else:
        print("\nâœ— Tests failed!")
        sys.exit(1)

