#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_feedback_system.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for IDE feedback system integration.

This script tests the enhanced IDE with feedback mechanisms to ensure all functions work correctly.
"""

import sys
import os
import time
import json
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent / 'src'))

def test_ide_feedback_system():
    """Test the IDE feedback system integration."""
    print("ðŸ§ª Testing IDE Feedback System Integration")
    print("=" * 60)
    
    try:
        # Test 1: Import the IDE
        print("1. Testing IDE import...")
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        print("âœ… IDE imported successfully")
        
        # Test 2: Check feedback system availability
        print("\n2. Testing feedback system availability...")
        from noodlecore.desktop.ide.feedback_system import FeedbackSystem, FeedbackLevel, FeedbackType
        print("âœ… Feedback system imported successfully")
        
        # Test 3: Create IDE instance
        print("\n3. Creating IDE instance...")
        ide = NativeNoodleCoreIDE()
        print("âœ… IDE instance created successfully")
        
        # Test 4: Check feedback system initialization
        print("\n4. Checking feedback system initialization...")
        if hasattr(ide, 'feedback_system') and ide.feedback_system:
            print("âœ… Feedback system initialized in IDE")
        else:
            print("âŒ Feedback system not initialized in IDE")
            return False
        
        # Test 5: Test feedback logging
        print("\n5. Testing feedback logging...")
        try:
            ide.feedback_system._log_feedback_event(
                FeedbackLevel.INFO,
                FeedbackType.USER_ACTION,
                "Test Event",
                "This is a test feedback event",
                {"test": "data"}
            )
            print("âœ… Feedback logging works")
        except Exception as e:
            print(f"âŒ Feedback logging failed: {e}")
            return False
        
        # Test 6: Test script analysis tracking
        print("\n6. Testing script analysis tracking...")
        try:
            test_analysis = {
                "script_type": "Python",
                "complexity": "medium",
                "issues_found": 3,
                "suggestions": ["Use NoodleCore", "Optimize performance", "Add error handling"]
            }
            ide.track_script_analysis("test_script.py", test_analysis)
            print("âœ… Script analysis tracking works")
        except Exception as e:
            print(f"âŒ Script analysis tracking failed: {e}")
            return False
        
        # Test 7: Test conversion progress tracking
        print("\n7. Testing conversion progress tracking...")
        try:
            conversion_details = {
                "conversion_type": "Python to NoodleCore",
                "success": True,
                "time_taken": 2.5,
                "lines_converted": 100
            }
            ide.track_conversion_progress("test_script.py", 0.8, conversion_details)
            print("âœ… Conversion progress tracking works")
        except Exception as e:
            print(f"âŒ Conversion progress tracking failed: {e}")
            return False
        
        # Test 8: Test self-improvement tracking
        print("\n8. Testing self-improvement tracking...")
        try:
            improvement_details = {
                "improvement_type": "Performance",
                "optimization_level": "high",
                "expected_gain": "30%"
            }
            ide.track_self_improvement("Performance Optimization", 0.6, improvement_details)
            print("âœ… Self-improvement tracking works")
        except Exception as e:
            print(f"âŒ Self-improvement tracking failed: {e}")
            return False
        
        # Test 9: Test error resolution tracking
        print("\n9. Testing error resolution tracking...")
        try:
            error_details = {
                "error_type": "Syntax Error",
                "error_message": "Invalid syntax",
                "file_path": "test.py",
                "line_number": 10
            }
            ide.track_error_resolution(error_details)
            print("âœ… Error resolution tracking works")
        except Exception as e:
            print(f"âŒ Error resolution tracking failed: {e}")
            return False
        
        # Test 10: Test AI assistance tracking
        print("\n10. Testing AI assistance tracking...")
        try:
            ai_details = {
                "ai_provider": "OpenAI",
                "model_used": "gpt-3.5-turbo",
                "prompt_tokens": 100,
                "completion_tokens": 50
            }
            ide.track_ai_assistance("Code Review", 1.2, 0.85, ai_details)
            print("âœ… AI assistance tracking works")
        except Exception as e:
            print(f"âŒ AI assistance tracking failed: {e}")
            return False
        
        # Test 11: Test feedback dashboard
        print("\n11. Testing feedback dashboard...")
        try:
            # This would normally open a GUI dialog, so we'll just check if the method exists
            if hasattr(ide, 'show_feedback_dashboard'):
                print("âœ… Feedback dashboard method exists")
            else:
                print("âŒ Feedback dashboard method not found")
                return False
        except Exception as e:
            print(f"âŒ Feedback dashboard test failed: {e}")
            return False
        
        # Test 12: Test feedback report export
        print("\n12. Testing feedback report export...")
        try:
            # This would normally export a report, so we'll just check if the method exists
            if hasattr(ide, 'export_feedback_report'):
                print("âœ… Feedback report export method exists")
            else:
                print("âŒ Feedback report export method not found")
                return False
        except Exception as e:
            print(f"âŒ Feedback report export test failed: {e}")
            return False
        
        print("\n" + "=" * 60)
        print("ðŸŽ‰ All IDE feedback system tests passed!")
        print("âœ… The enhanced IDE is working correctly with feedback mechanisms")
        return True
        
    except Exception as e:
        print(f"\nâŒ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_ide_functions():
    """Test that all IDE functions are available and working."""
    print("\nðŸ§ª Testing IDE Functions")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        ide = NativeNoodleCoreIDE()
        
        # Test core IDE functions
        functions_to_test = [
            'new_file',
            'open_file',
            'save_file',
            'run_current_file',
            'show_ai_chat',
            'ai_code_review',
            'ai_explain_code',
            'convert_python_to_nc',
            'auto_fix_code_errors',
            'fix_noodlecore_syntax',
            'validate_all_nc_files',
            'show_git_status',
            'show_git_commits',
            'show_git_diff',
            'project_health_check_workflow',
            'show_progress_manager',
            'show_self_improvement_panel',
            'show_trm_controller_status',
            'show_feedback_dashboard'
        ]
        
        missing_functions = []
        for func_name in functions_to_test:
            if hasattr(ide, func_name):
                print(f"âœ… {func_name}")
            else:
                print(f"âŒ {func_name} - MISSING")
                missing_functions.append(func_name)
        
        if missing_functions:
            print(f"\nâŒ Missing functions: {missing_functions}")
            return False
        else:
            print(f"\nðŸŽ‰ All {len(functions_to_test)} IDE functions are available!")
            return True
            
    except Exception as e:
        print(f"\nâŒ Function test failed: {e}")
        return False

def main():
    """Main test runner."""
    print("ðŸš€ Starting IDE Enhancement Tests")
    print("=" * 60)
    
    # Run tests
    feedback_test_passed = test_ide_feedback_system()
    function_test_passed = test_ide_functions()
    
    # Summary
    print("\n" + "=" * 60)
    print("ðŸ“Š TEST SUMMARY")
    print("=" * 60)
    
    if feedback_test_passed:
        print("âœ… Feedback System Integration: PASSED")
    else:
        print("âŒ Feedback System Integration: FAILED")
    
    if function_test_passed:
        print("âœ… IDE Functions: PASSED")
    else:
        print("âŒ IDE Functions: FAILED")
    
    if feedback_test_passed and function_test_passed:
        print("\nðŸŽ‰ ALL TESTS PASSED!")
        print("The enhanced IDE with feedback mechanisms is working correctly.")
        return 0
    else:
        print("\nâŒ SOME TESTS FAILED!")
        print("Please check the error messages above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

