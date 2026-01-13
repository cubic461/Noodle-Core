#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_1_components.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Individual Component Tests for Phase 2.1 Implementation
"""

import os
import sys
import tempfile
import shutil

# Add the noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.syntax_fixer_learning import (
    FixResultCollector, PatternAnalyzer, LearningEngine, FeedbackProcessor,
    FixResult, create_syntax_fixer_learning_system
)
from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
from noodlecore.noodlecore_self_improvement_system_v2 import NoodleCoreSelfImproverV2

def test_fix_result_collector():
    """Test FixResultCollector component."""
    print("Testing FixResultCollector...")
    
    collector = FixResultCollector()
    
    # Test collecting a fix result
    fix_result = FixResult(
        fix_id="test-fix-1",
        file_path="/test/file.nc",
        original_content="let x = 5",
        fixed_content="let x = 5;",
        fixes_applied=[{"type": "semicolon", "line": 1}],
        confidence_score=0.9,
        fix_time=0.1
    )
    
    result = collector.collect_fix_result(fix_result)
    assert result == True, "Failed to collect fix result"
    assert len(collector.fix_results) == 1, "Fix result not added to cache"
    
    # Test recording user feedback
    feedback_result = collector.record_user_feedback("test-fix-1", True, "Good fix!")
    assert feedback_result == True, "Failed to record user feedback"
    assert collector.fix_results[0].user_accepted == True, "User feedback not recorded"
    
    # Test effectiveness metrics
    metrics = collector.get_effectiveness_metrics(days=30)
    assert 'total_fixes' in metrics, "Missing total_fixes in metrics"
    assert 'acceptance_rate' in metrics, "Missing acceptance_rate in metrics"
    
    print("FixResultCollector tests passed")

def test_pattern_analyzer():
    """Test PatternAnalyzer component."""
    print("Testing PatternAnalyzer...")
    
    analyzer = PatternAnalyzer()
    
    # Test pattern analysis in content
    content = """
    let x = 5
    print "hello"
    def test_func(param1, param2)
    if x > 0
        print "positive"
    """
    
    matches = analyzer.analyze_patterns_in_content(content, "/test/file.nc")
    assert len(matches) > 0, "No patterns found in test content"
    
    # Test fix results pattern analysis
    fix_results = [
        FixResult(
            fix_id="test-1",
            file_path="/test/file1.nc",
            original_content="let x = 5",
            fixed_content="let x = 5;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.9,
            fix_time=0.1,
            user_accepted=True
        ),
        FixResult(
            fix_id="test-2",
            file_path="/test/file2.nc",
            original_content="import math",
            fixed_content='import "math";',
            fixes_applied=[{"type": "import_fix", "line": 1}],
            confidence_score=0.8,
            fix_time=0.15,
            user_accepted=False
        )
    ]
    
    analysis = analyzer.analyze_fix_results_patterns(fix_results)
    assert 'total_results' in analysis, "Missing total_results in analysis"
    assert 'success_rates' in analysis, "Missing success_rates in analysis"
    
    print("PatternAnalyzer tests passed")

def test_learning_engine():
    """Test LearningEngine component."""
    print("Testing LearningEngine...")
    
    engine = LearningEngine()
    
    # Test learning from fix results
    fix_results = [
        FixResult(
            fix_id="learn-1",
            file_path="/test/learn1.nc",
            original_content="let x = 5",
            fixed_content="let x = 5;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.9,
            fix_time=0.1,
            user_accepted=True
        )
    ]
    
    learning_result = engine.learn_from_fix_results(fix_results)
    assert learning_result['status'] == 'success', "Learning failed"
    assert 'patterns_updated' in learning_result, "Missing patterns_updated in learning result"
    
    # Test pattern confidence
    engine.pattern_performance['test_pattern'] = {
        'success_rate': 85.0,
        'usage_count': 15
    }
    
    confidence = engine.get_pattern_confidence('test_pattern')
    assert confidence > 0.8, "Pattern confidence too low"
    
    # Test fix strategy suggestion
    strategy = engine.suggest_fix_strategy('missing_semicolon', {'file_path': '/test/file.nc'})
    assert 'pattern_type' in strategy, "Missing pattern_type in strategy"
    assert 'recommended_approach' in strategy, "Missing recommended_approach in strategy"
    
    print("LearningEngine tests passed")

def test_feedback_processor():
    """Test FeedbackProcessor component."""
    print("Testing FeedbackProcessor...")
    
    processor = FeedbackProcessor()
    
    # Test processing user feedback
    feedback_result = processor.process_user_feedback(
        "test-fix-1",
        True,
        "Excellent fix, worked perfectly!"
    )
    
    assert feedback_result['status'] == 'success', "Feedback processing failed"
    assert feedback_result['feedback_type'] == 'acceptance', "Wrong feedback type"
    assert feedback_result['sentiment'] == 'positive', "Wrong sentiment analysis"
    
    # Test adaptive suggestions
    # Add some feedback history first
    for i in range(5):
        context = {'pattern_type': 'missing_semicolon', 'file_type': 'test'}
        processor.process_user_feedback(
            f"test-fix-{i}",
            i % 2 == 0,  # 50% accepted
            "Good" if i % 2 == 0 else "Needs improvement",
            context
        )
    
    suggestion = processor.get_adaptive_suggestions('missing_semicolon', {'file_type': 'test'})
    assert 'pattern_type' in suggestion, "Missing pattern_type in suggestion"
    assert 'historical_acceptance_rate' in suggestion, "Missing historical_acceptance_rate in suggestion"
    
    print("FeedbackProcessor tests passed")

def test_enhanced_syntax_fixer_v2():
    """Test EnhancedNoodleCoreSyntaxFixerV2 component."""
    print("Testing EnhancedNoodleCoreSyntaxFixerV2...")
    
    # Create temporary directory for test files
    test_dir = tempfile.mkdtemp()
    
    try:
        # Create test file
        test_file = os.path.join(test_dir, "test.nc")
        with open(test_file, 'w') as f:
            f.write('let x = 5\nprint "hello"')
        
        # Initialize fixer
        fixer = EnhancedNoodleCoreSyntaxFixerV2(
            enable_ai=False,  # Disable AI for simpler testing
            enable_learning=True,
            database_config=None
        )
        
        # Test enhanced file fixing
        result = fixer.fix_file_enhanced(test_file, create_backup=True)
        
        assert result['success'], "File fixing failed"
        assert result['fixes_applied'] > 0, "No fixes applied"
        assert result['learning_enabled'], "Learning should be enabled"
        assert result['fix_id'] is not None, "Missing fix ID"
        
        # Test recording user feedback
        feedback_result = fixer.record_user_feedback(result['fix_id'], True, "Good fix!")
        assert feedback_result['success'], "Failed to record feedback"
        
        # Test performance metrics
        metrics = fixer.get_performance_metrics()
        assert 'files_processed' in metrics, "Missing files_processed in metrics"
        assert 'learning_enabled' in metrics, "Missing learning_enabled in metrics"
        
        print("EnhancedNoodleCoreSyntaxFixerV2 tests passed")
        
    finally:
        # Clean up
        shutil.rmtree(test_dir, ignore_errors=True)

def test_self_improver_v2():
    """Test NoodleCoreSelfImproverV2 component."""
    print("Testing NoodleCoreSelfImproverV2...")
    
    improver = NoodleCoreSelfImproverV2({
        'enable_database': False  # Disable database for testing
    })
    
    # Test starting monitoring
    result = improver.start_monitoring()
    assert result == True, "Failed to start monitoring"
    assert improver.monitoring_active == True, "Monitoring not active"
    
    # Test system analysis
    analysis_result = improver.analyze_system_for_improvements()
    assert 'improvement_opportunities' in analysis_result, "Missing improvement opportunities"
    assert 'system_health_score' in analysis_result, "Missing system health score"
    
    # Test syntax fixer status
    fixer_status = improver.get_syntax_fixer_status()
    assert 'status' in fixer_status, "Missing status in fixer status"
    
    # Test configuration
    config = {
        'syntax_learning': {
            'learning_interval': 1800,
            'focus': 'quality_improvement'
        }
    }
    
    config_result = improver.configure(config)
    assert config_result == True, "Failed to configure"
    
    # Test shutdown
    improver.shutdown()
    assert improver.monitoring_active == False, "Monitoring still active after shutdown"
    
    print("NoodleCoreSelfImproverV2 tests passed")

def test_complete_system():
    """Test complete system integration."""
    print("Testing complete system integration...")
    
    # Create complete learning system
    system = create_syntax_fixer_learning_system()
    
    assert 'fix_result_collector' in system, "Missing fix_result_collector in system"
    assert 'pattern_analyzer' in system, "Missing pattern_analyzer in system"
    assert 'learning_engine' in system, "Missing learning_engine in system"
    assert 'feedback_processor' in system, "Missing feedback_processor in system"
    
    # Test component status
    collector_status = system['fix_result_collector'].get_status()
    assert 'collection_enabled' in collector_status, "Missing collection_enabled in status"
    
    engine_status = system['learning_engine'].get_learning_status()
    assert 'learning_enabled' in engine_status, "Missing learning_enabled in status"
    
    processor_status = system['feedback_processor'].get_status()
    assert 'feedback_history_size' in processor_status, "Missing feedback_history_size in status"
    
    print("Complete system integration tests passed")

def main():
    """Run all component tests."""
    print("Running Phase 2.1 Individual Component Tests")
    print("=" * 50)
    
    try:
        test_fix_result_collector()
        test_pattern_analyzer()
        test_learning_engine()
        test_feedback_processor()
        test_enhanced_syntax_fixer_v2()
        test_self_improver_v2()
        test_complete_system()
        
        print("\n" + "=" * 50)
        print("All component tests passed successfully!")
        return True
        
    except Exception as e:
        print(f"\nTest failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

