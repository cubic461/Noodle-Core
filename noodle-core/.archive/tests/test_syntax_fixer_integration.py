#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_fixer_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Integration of Phase 2.1 with Existing Syntax Fixer
"""

import os
import sys
import tempfile
import shutil

# Add noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_enhanced_syntax_fixer_v2():
    """Test EnhancedNoodleCoreSyntaxFixerV2 integration."""
    print("Testing EnhancedNoodleCoreSyntaxFixerV2...")
    
    try:
        from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
        from noodlecore.ai_agents.syntax_fixer_learning import FixResult
        
        # Create test file with syntax issues
        test_content = """
let x = 5
print "hello world"
if x > 0
    print "positive"
"""
        
        # Create enhanced syntax fixer
        fixer = EnhancedNoodleCoreSyntaxFixerV2()
        
        # Test syntax fixing
        result = fixer.fix_file_enhanced("test.nc", test_content)
        
        # Verify results
        assert result is not None, "Syntax fixer returned None"
        assert result.get('success', False), "Result not successful"
        assert result.get('fixed_content'), "Result missing fixed_content"
        assert result.get('fixes_applied'), "Result missing fixes_applied"
        assert result.get('confidence_score'), "Result missing confidence_score"
        
        print(f"Enhanced syntax fixer test passed!")
        print(f"  - Fixed content length: {len(result.fixed_content)}")
        print(f"  - Fixes applied: {len(result.fixes_applied)}")
        print(f"  - Confidence score: {result.confidence_score}")
        
        return True
        
    except Exception as e:
        print(f"Enhanced syntax fixer test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_syntax_fixer_with_learning():
    """Test syntax fixer with learning components."""
    print("Testing syntax fixer with learning components...")
    
    try:
        from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
        from noodlecore.ai_agents.syntax_fixer_learning import create_syntax_fixer_learning_system
        
        # Create learning system
        learning_system = create_syntax_fixer_learning_system()
        
        # Create enhanced syntax fixer with learning
        fixer = EnhancedNoodleCoreSyntaxFixerV2(
            enable_learning=True
        )
        
        # Test syntax fixing with learning
        test_content = """
let x = 5
print "hello world"
if x > 0
    print "positive"
"""
        
        result = fixer.fix_syntax(test_content, "test.nc")
        
        # Verify results
        assert result is not None, "Syntax fixer returned None"
        assert hasattr(result, 'fixed_content'), "Result missing fixed_content"
        assert hasattr(result, 'fixes_applied'), "Result missing fixes_applied"
        assert hasattr(result, 'confidence_score'), "Result missing confidence_score"
        
        print(f"Syntax fixer with learning test passed!")
        print(f"  - Fixed content length: {len(result.fixed_content)}")
        print(f"  - Fixes applied: {len(result.fixes_applied)}")
        print(f"  - Confidence score: {result.confidence_score}")
        
        # Test learning system status
        if learning_system:
            collector_status = learning_system.get('fix_result_collector', {}).get_status()
            engine_status = learning_system.get('learning_engine', {}).get_learning_status()
            
            print(f"  - Collector status: {collector_status.get('collection_enabled', False)}")
            print(f"  - Learning enabled: {engine_status.get('learning_enabled', False)}")
        
        return True
        
    except Exception as e:
        print(f"Syntax fixer with learning test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_feedback_processing():
    """Test feedback processing functionality."""
    print("Testing feedback processing...")
    
    try:
        from noodlecore.ai_agents.syntax_fixer_learning import create_syntax_fixer_learning_system
        
        # Create learning system
        learning_system = create_syntax_fixer_learning_system()
        
        if not learning_system:
            print("Learning system not available, skipping feedback test")
            return True
        
        # Get components
        collector = learning_system.get('fix_result_collector')
        processor = learning_system.get('feedback_processor')
        
        # Create test fix result
        from noodlecore.ai_agents.syntax_fixer_learning import FixResult
        fix_result = FixResult(
            fix_id="feedback-test-1",
            file_path="/test/feedback_test.nc",
            original_content="let x = 5",
            fixed_content="let x = 5;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.9,
            fix_time=0.1,
            user_accepted=True
        )
        
        # Collect fix result
        collect_result = collector.collect_fix_result(fix_result)
        assert collect_result == True, "Failed to collect fix result"
        
        # Process feedback
        feedback_result = processor.process_user_feedback(
            "feedback-test-1",
            True,
            "Great fix!",
            {"pattern_type": "semicolon", "file_type": "test"}
        )
        assert feedback_result['status'] == 'success', "Feedback processing failed"
        
        # Verify feedback was recorded
        results = collector.get_fix_results(limit=10)
        assert len(results) > 0, "No fix results found"
        
        found_feedback = False
        for result in results:
            if result.fix_id == "feedback-test-1":
                assert result.user_accepted == True, "User acceptance not recorded"
                assert result.user_feedback == "Great fix!", "User feedback not recorded"
                found_feedback = True
                break
        
        assert found_feedback, "Feedback not found in results"
        
        print("Feedback processing test passed!")
        
        # Clean up
        if learning_system.get('database_manager'):
            learning_system['database_manager'].close()
        
        return True
        
    except Exception as e:
        print(f"Feedback processing test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all integration tests."""
    print("Running Phase 2.1 Integration Tests")
    print("=" * 50)
    
    tests = [
        ("Enhanced Syntax Fixer V2", test_enhanced_syntax_fixer_v2),
        ("Syntax Fixer with Learning", test_syntax_fixer_with_learning),
        ("Feedback Processing", test_feedback_processing)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n--- {test_name} ---")
        try:
            if test_func():
                passed += 1
                print(f"PASSED {test_name}")
            else:
                print(f"âœ— {test_name} FAILED")
        except Exception as e:
            print(f"FAILED {test_name}: {e}")
    
    print("\n" + "=" * 50)
    print(f"Integration Tests: {passed}/{total} passed")
    
    if passed == total:
        print("All integration tests passed successfully!")
        return True
    else:
        print("Some integration tests failed!")
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

