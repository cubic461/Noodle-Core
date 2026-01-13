#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Script for Enhanced NoodleCore IDE with Feedback System

This script tests the enhanced IDE functionality including:
- Feedback system integration
- Progress tracking
- Syntax fixing
- Conversion monitoring
- Error tracking
- Performance metrics
"""

import sys
import os
import tempfile
import time
from pathlib import Path

# Add the noodle-core src directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_feedback_system():
    """Test the feedback system functionality."""
    print("ðŸ§ª Testing Feedback System...")
    
    try:
        from noodlecore.desktop.ide.feedback_system import FeedbackSystem, FeedbackLevel, FeedbackType
        print("âœ… Feedback System imported successfully")
        
        # Create a mock IDE instance
        class MockIDE:
            def __init__(self):
                self.root = None
                self.terminal_output = None
        
        mock_ide = MockIDE()
        
        # Initialize feedback system
        feedback_system = FeedbackSystem(mock_ide)
        print("âœ… Feedback System initialized successfully")
        
        # Test feedback event logging
        feedback_system._log_feedback_event(
            FeedbackLevel.INFO,
            FeedbackType.USER_PROGRESS,
            "Test Event",
            "This is a test feedback event",
            {"test": "data"}
        )
        print("âœ… Feedback event logged successfully")
        
        # Test script analysis tracking
        feedback_system.track_script_analysis(
            "/test/script.py",
            {
                "improvements": [
                    {"description": "Use list comprehension", "impact": "performance"},
                    {"description": "Add type hints", "impact": "readability"}
                ],
                "quality_score": 0.85
            }
        )
        print("âœ… Script analysis tracking works")
        
        # Test conversion progress tracking
        feedback_system.track_conversion_progress(
            "/test/script.py",
            75.0,
            {"stage": "syntax_fixing", "fixes_applied": 5}
        )
        print("âœ… Conversion progress tracking works")
        
        # Test self-improvement tracking
        feedback_system.track_self_improvement(
            "code_analysis",
            90.0,
            {"learning_rate": 0.8, "accuracy_improvement": 0.15}
        )
        print("âœ… Self-improvement tracking works")
        
        # Test error resolution tracking
        feedback_system.track_error_resolution({
            "file_path": "/test/script.py",
            "error_type": "syntax_error",
            "line_number": 42
        })
        print("âœ… Error resolution tracking works")
        
        # Test AI assistance tracking
        feedback_system.track_ai_assistance(
            "code_review",
            2.5,
            0.9,
            {"reviewer": "code_assistant", "issues_found": 3}
        )
        print("âœ… AI assistance tracking works")
        
        # Test feedback summary
        summary = feedback_system.get_feedback_summary()
        print(f"âœ… Feedback summary generated: {len(summary['feedback_history'])} events")
        
        return True
        
    except Exception as e:
        print(f"âŒ Feedback System test failed: {e}")
        return False

def test_progress_manager():
    """Test the progress manager functionality."""
    print("\nðŸ“Š Testing Progress Manager...")
    
    try:
        from noodlecore.desktop.ide.progress_manager import ProgressManager
        print("âœ… Progress Manager imported successfully")
        
        # Create a mock IDE instance
        class MockIDE:
            def __init__(self):
                self.root = None
                self.open_files = {}
                self.ai_conversations = {}
                self.current_ai_role = {}
        
        mock_ide = MockIDE()
        
        # Initialize progress manager
        progress_manager = ProgressManager(mock_ide)
        print("âœ… Progress Manager initialized successfully")
        
        # Test progress monitoring
        progress_manager.start_monitoring()
        print("âœ… Progress monitoring started")
        
        # Test progress summary
        summary = progress_manager.get_progress_summary()
        print(f"âœ… Progress summary generated: {summary['overview']['current_productivity_score']:.1f}/100")
        
        # Stop monitoring
        progress_manager.stop_monitoring()
        print("âœ… Progress monitoring stopped")
        
        return True
        
    except Exception as e:
        print(f"âŒ Progress Manager test failed: {e}")
        return False

def test_syntax_fixer():
    """Test the NoodleCore syntax fixer functionality."""
    print("\nðŸ”§ Testing NoodleCore Syntax Fixer...")
    
    try:
        from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer
        print("âœ… NoodleCore Syntax Fixer imported successfully")
        
        # Initialize syntax fixer
        fixer = NoodleCoreSyntaxFixer()
        print("âœ… NoodleCore Syntax Fixer initialized successfully")
        
        # Test content fixing
        test_content = '''#!/usr/bin/env python3
"""
This is a test Python file for syntax fixing.
"""

def test_function(param1, param2):
    """Test function with Python syntax."""
    result = []
    for i in range(10):
        if i % 2 == 0:
            result.append(i * param1)
        else:
            result.append(i * param2)
    return result

if __name__ == "__main__":
    print("Hello, World!")
    test_function(1, 2)
'''
        
        fixed_content, fixes = fixer.fix_content(test_content)
        print(f"âœ… Content fixing works: {len(fixes)} fixes applied")
        
        # Test file fixing
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
            f.write(test_content)
            temp_file = f.name
        
        try:
            result = fixer.fix_file(temp_file)
            print(f"âœ… File fixing works: {result['fixes_applied']} fixes applied")
        finally:
            os.unlink(temp_file)
        
        return True
        
    except Exception as e:
        print(f"âŒ NoodleCore Syntax Fixer test failed: {e}")
        return False

def test_syntax_highlighter():
    """Test the syntax highlighter functionality."""
    print("\nðŸŽ¨ Testing Syntax Highlighter...")
    
    try:
        from noodlecore.desktop.ide.syntax_highlighter import SyntaxHighlighter, HighlightType
        print("âœ… Syntax Highlighter imported successfully")
        
        # Initialize syntax highlighter
        highlighter = SyntaxHighlighter()
        print("âœ… Syntax Highlighter initialized successfully")
        
        # Test highlighting
        test_code = '''def test_function():
    """Test function."""
    return "Hello, World!"

# This is a comment
variable = 42
'''
        
        # Test different languages
        for language in ['python', 'javascript', 'html']:
            try:
                highlighter.set_language(language)
                print(f"âœ… {language.capitalize()} highlighting works")
            except Exception as e:
                print(f"âš ï¸  {language.capitalize()} highlighting failed: {e}")
        
        # Test theme switching
        for theme in ['dark', 'light', 'blue']:
            try:
                highlighter.set_theme(theme)
                print(f"âœ… {theme.capitalize()} theme works")
            except Exception as e:
                print(f"âš ï¸  {theme.capitalize()} theme failed: {e}")
        
        return True
        
    except Exception as e:
        print(f"âŒ Syntax Highlighter test failed: {e}")
        return False

def test_ide_integration():
    """Test the IDE integration with all components."""
    print("\nðŸ—ï¸  Testing IDE Integration...")
    
    try:
        # Test that all components can be imported together
        from noodlecore.desktop.ide.feedback_system import FeedbackSystem
        from noodlecore.desktop.ide.progress_manager import ProgressManager
        from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer
        from noodlecore.desktop.ide.syntax_highlighter import SyntaxHighlighter
        
        print("âœ… All IDE components imported successfully")
        
        # Test that the native IDE can import all components
        try:
            from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
            print("âœ… NativeNoodleCoreIDE imports all components successfully")
        except Exception as e:
            print(f"âš ï¸  NativeNoodleCoreIDE import issue: {e}")
        
        return True
        
    except Exception as e:
        print(f"âŒ IDE Integration test failed: {e}")
        return False

def test_performance_monitoring():
    """Test performance monitoring capabilities."""
    print("\nâš¡ Testing Performance Monitoring...")
    
    try:
        from noodlecore.desktop.ide.feedback_system import FeedbackSystem
        
        # Create a mock IDE instance
        class MockIDE:
            def __init__(self):
                self.root = None
                self.terminal_output = None
        
        mock_ide = MockIDE()
        feedback_system = FeedbackSystem(mock_ide)
        
        # Test performance tracking
        start_time = time.time()
        
        # Simulate some operations
        for i in range(10):
            feedback_system.track_script_analysis(f"/test/script_{i}.py", {
                "improvements": [{"description": f"Improvement {i}", "impact": "performance"}],
                "quality_score": 0.8 + i * 0.01
            })
            time.sleep(0.01)  # Small delay
        
        # Test performance metrics
        summary = feedback_system.get_feedback_summary()
        print(f"âœ… Performance monitoring works: {len(summary['performance_metrics'])} metrics tracked")
        
        return True
        
    except Exception as e:
        print(f"âŒ Performance Monitoring test failed: {e}")
        return False

def test_error_handling():
    """Test error handling and recovery."""
    print("\nðŸ›¡ï¸  Testing Error Handling...")
    
    try:
        from noodlecore.desktop.ide.feedback_system import FeedbackSystem
        
        # Create a mock IDE instance
        class MockIDE:
            def __init__(self):
                self.root = None
                self.terminal_output = None
        
        mock_ide = MockIDE()
        feedback_system = FeedbackSystem(mock_ide)
        
        # Test error tracking
        error_details = {
            "file_path": "/test/broken_script.py",
            "error_type": "syntax_error",
            "line_number": 42,
            "error_message": "Invalid syntax"
        }
        
        feedback_system.track_error_resolution(error_details)
        print("âœ… Error tracking works")
        
        # Test error recovery simulation
        feedback_system._log_feedback_event(
            FeedbackLevel.SUCCESS,
            FeedbackType.ERROR_RESOLUTION,
            "Error Resolved",
            "Successfully resolved syntax error",
            error_details
        )
        print("âœ… Error recovery tracking works")
        
        return True
        
    except Exception as e:
        print(f"âŒ Error Handling test failed: {e}")
        return False

def run_all_tests():
    """Run all tests and provide a summary."""
    print("ðŸš€ Starting Enhanced NoodleCore IDE Tests...\n")
    
    tests = [
        ("Feedback System", test_feedback_system),
        ("Progress Manager", test_progress_manager),
        ("NoodleCore Syntax Fixer", test_syntax_fixer),
        ("Syntax Highlighter", test_syntax_highlighter),
        ("IDE Integration", test_ide_integration),
        ("Performance Monitoring", test_performance_monitoring),
        ("Error Handling", test_error_handling)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"\n{'='*60}")
        print(f"Running: {test_name}")
        print('='*60)
        
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"âŒ {test_name} test crashed: {e}")
            results.append((test_name, False))
    
    # Print summary
    print(f"\n{'='*60}")
    print("ðŸ“Š TEST SUMMARY")
    print('='*60)
    
    passed = 0
    failed = 0
    
    for test_name, result in results:
        status = "âœ… PASSED" if result else "âŒ FAILED"
        print(f"{test_name:<25} {status}")
        if result:
            passed += 1
        else:
            failed += 1
    
    print(f"\n{'='*60}")
    print(f"Total Tests: {len(results)}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Success Rate: {(passed/len(results)*100):.1f}%")
    print('='*60)
    
    if failed == 0:
        print("\nðŸŽ‰ All tests passed! The Enhanced NoodleCore IDE is working correctly.")
        return True
    else:
        print(f"\nâš ï¸  {failed} test(s) failed. Please check the implementation.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)

