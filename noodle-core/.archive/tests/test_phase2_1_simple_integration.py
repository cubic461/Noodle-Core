#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_1_simple_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Integration Tests for Phase 2.1 Components
"""

import os
import sys
import tempfile
import shutil

# Add noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.syntax_fixer_learning import (
    FixResultCollector, PatternAnalyzer, LearningEngine, FeedbackProcessor,
    FixResult, create_syntax_fixer_learning_system
)
from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2

def test_basic_integration():
    """Test basic integration between Phase 2.1 components."""
    print("Testing basic component integration...")
    
    # Test 1: Create learning system
    system = create_syntax_fixer_learning_system()
    assert 'fix_result_collector' in system, "Missing fix_result_collector"
    assert 'pattern_analyzer' in system, "Missing pattern_analyzer"
    assert 'learning_engine' in system, "Missing learning_engine"
    assert 'feedback_processor' in system, "Missing feedback_processor"
    
    # Test 2: Component interaction
    collector = system['fix_result_collector']
    analyzer = system['pattern_analyzer']
    engine = system['learning_engine']
    processor = system['feedback_processor']
    
    # Create a test fix result
    fix_result = FixResult(
        fix_id="integration-test-1",
        file_path="/test/integration.nc",
        original_content="let x = 5",
        fixed_content="let x = 5;",
        fixes_applied=[{"type": "semicolon", "line": 1}],
        confidence_score=0.9,
        fix_time=0.1
    )
    
    # Test collector
    collect_result = collector.collect_fix_result(fix_result)
    assert collect_result == True, "Failed to collect fix result"
    
    # Test analyzer
    analysis = analyzer.analyze_fix_results_patterns([fix_result])
    assert 'total_results' in analysis, "Missing total_results in analysis"
    
    # Test learning engine
    learning_result = engine.learn_from_fix_results([fix_result])
    assert learning_result['status'] == 'success', "Learning failed"
    
    # Test feedback processor
    feedback_result = processor.process_user_feedback(
        "integration-test-1",
        True,
        "Great fix!",
        {"pattern_type": "semicolon", "file_type": "test"}
    )
    assert feedback_result['status'] == 'success', "Feedback processing failed"
    
    print("Basic integration tests passed")

def test_fixer_integration():
    """Test integration of Enhanced Syntax Fixer V2."""
    print("Testing Enhanced Syntax Fixer V2 integration...")
    
    # Create temporary directory for test files
    test_dir = tempfile.mkdtemp()
    
    try:
        # Create test file
        test_file = os.path.join(test_dir, "integration_test.nc")
        with open(test_file, 'w') as f:
            f.write('let x = 5\nprint "hello"')
        
        # Initialize fixer
        fixer = EnhancedNoodleCoreSyntaxFixerV2(
            enable_ai=False,  # Disable AI for simpler testing
            enable_learning=True,
            database_config=None
        )
        
        # Test file fixing
        result = fixer.fix_file_enhanced(test_file, create_backup=True)
        
        assert result['success'], "File fixing failed"
        assert result['fixes_applied'] > 0, "No fixes applied"
        assert result['learning_enabled'], "Learning should be enabled"
        
        # Test recording feedback
        feedback_result = fixer.record_user_feedback(
            result['fix_id'],
            True,
            "Excellent fix!"
        )
        assert feedback_result['success'], "Failed to record feedback"
        
        print("Enhanced Syntax Fixer V2 integration tests passed")
        
    finally:
        # Clean up
        shutil.rmtree(test_dir, ignore_errors=True)

def main():
    """Run all integration tests."""
    print("Running Phase 2.1 Simple Integration Tests")
    print("=" * 50)
    
    try:
        test_basic_integration()
        test_fixer_integration()
        
        print("\n" + "=" * 50)
        print("All integration tests passed successfully!")
        return True
        
    except Exception as e:
        print(f"\nIntegration test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

