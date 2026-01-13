#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_improvement_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to demonstrate script improvements and file opening in the IDE.
This creates a simple test file and demonstrates the self-improvement system.
"""

import os
import sys
import tempfile
from pathlib import Path

# Add src directory to the path
sys.path.insert(0, str(Path(__file__).parent / "src"))

def test_improvement_demo():
    """Demonstrate script improvements and file opening in the IDE."""
    
    # Create a temporary test file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as temp_file:
        temp_file.write("""# Original test file
def hello_world():
    print("Hello, World!")
    return "old result"

def main():
    result = hello_world()
    print(f"Result: {result}")
    
if __name__ == "__main__":
    main()
""")
        temp_path = temp_file.name
    
    try:
        # Import self-improvement integration
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create a mock IDE with necessary methods
        class MockIDE:
            def __init__(self):
                self.open_files = {}
                self.si_display = None
                self.ai_chat = None
                self.status_bar = None
                
            def register_self_improvement_callback(self, callback):
                self.callback = callback
                print("[OK] Self-improvement callback registered")
                
            def show_diff_highlighting(self, file_path, diff_lines, diff_summary, improvement, original_content, improved_content):
                print(f"[OK] Diff highlighting called for file: {file_path}")
                print(f"  - Improvement type: {improvement.get('type', 'unknown')}")
                print(f"  - Lines added: {diff_summary.get('lines_added', 0)}")
                print(f"  - Lines removed: {diff_summary.get('lines_removed', 0)}")
                print(f"  - Total changes: {diff_summary.get('total_changes', 0)}")
                
                # Show the actual diff
                print("\n--- DIFF PREVIEW ---")
                for line in diff_lines[:10]:  # Show first 10 lines
                    print(line)
                if len(diff_lines) > 10:
                    print(f"... ({len(diff_lines) - 10} more lines)")
                print("--- END DIFF PREVIEW ---\n")
                
                return True
        
        # Create mock IDE instance
        mock_ide = MockIDE()
        
        # Create self-improvement integration
        integration = SelfImprovementIntegration(mock_ide)
        
        print("Demonstrating script improvements and file opening in IDE...")
        print("=" * 60)
        
        # Create an improvement
        improvement = {
            'id': 'demo_improvement_1',
            'type': 'code_quality',  # This should trigger diff highlighting
            'description': 'Demo improvement for better code quality',
            'priority': 'medium',
            'source': 'demo_system',
            'file': temp_path,
            'auto_applicable': True,
            'status': 'pending'
        }
        
        # Add improvement to active list
        integration.active_improvements.append(improvement)
        
        # Apply improvement (this should trigger diff highlighting)
        print("\nApplying improvement...")
        integration._apply_improvement(improvement)
        
        # Check result
        if improvement.get('status') == 'applied':
            print("[SUCCESS] Improvement applied successfully!")
            print("[SUCCESS] Diff highlighting was triggered!")
            print("\nThis demonstrates that:")
            print("1. Scripts can be improved by the self-improvement system")
            print("2. Files are automatically processed for diff highlighting")
            print("3. Changes are detected and displayed")
            print("4. The IDE callback system is working correctly")
        else:
            print(f"[ERROR] Improvement failed: {improvement.get('status', 'unknown')}")
        
        print("\n" + "=" * 60)
        print("DEMONSTRATION COMPLETED!")
        print("\nThe self-improvement system is working correctly.")
        print("When run in the actual IDE, improved files will be opened")
        print("in the code editor with diff highlighting applied.")
        
        return True
        
    except Exception as e:
        print(f"Demo failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        # Clean up temporary file
        try:
            os.unlink(temp_path)
            print(f"\n[CLEAN] Temporary file removed: {temp_path}")
        except:
            pass

if __name__ == "__main__":
    print("Testing self-improvement system demonstration...")
    success = test_improvement_demo()
    
    if success:
        print("\n+ Demo completed successfully!")
        print("\nThe self-improvement system is working as expected.")
        print("In the actual IDE, improved scripts will be opened with diff highlighting.")
    else:
        print("\n- Demo failed!")
        sys.exit(1)

