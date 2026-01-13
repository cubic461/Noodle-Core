#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_1_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Integration Tests for Phase 2.1 Components
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
from noodlecore.noodlecore_self_improvement_system_v2 import NoodleCoreSelfImproverV2

def test_component_integration():
    """Test integration between Phase 2.1 components."""
    print("Testing component integration...")
    
    # Create complete learning system
    system = create_syntax_fixer_learning_system()
    
    # Get individual components
    collector = system['fix_result_collector']
    analyzer = system['pattern_analyzer']
    engine = system['learning_engine']
    processor = system['feedback_processor']
    
    # Test data flow between components
    
    # 1. Collector to Analyzer
    fix_result = FixResult(
        fix_id="integration-test-1",
        file_path="/test/integration.nc",
        original_content="let x = 5\nprint \"hello\"",
        fixed_content="let x = 5;\nprint \"hello\";",
        fixes_applied=[
            {"type": "semicolon", "line": 1},
            {"type": "semicolon", "line": 2}
        ],
        confidence_score=0.9,
        fix_time=0.15,
        user_accepted=True
    )
    
    # Collect fix result
    collect_result = collector.collect_fix_result(fix_result)
    assert collect_result == True, "Failed to collect fix result"
    
    # Analyze patterns in fix results
    analysis = analyzer.analyze_fix_results_patterns([fix_result])
    assert 'total_results' in analysis, "Missing total_results in analysis"
    assert 'success_rates' in analysis, "Missing success_rates in analysis"
    
    # Learn from fix results
    learning_result = engine.learn_from_fix_results([fix_result])
    assert learning_result['status'] == 'success', "Learning failed"
    
    # Process user feedback
    feedback_result = processor.process_user_feedback(
        "integration-test-1",
        True,
        "Great fix, worked perfectly!",
        {"pattern_type": "semicolon", "file_type": "test"}
    )
    assert feedback_result['status'] == 'success', "Feedback processing failed"
    
    # Test adaptive suggestions based on feedback
    suggestion = processor.get_adaptive_suggestions(
        "semicolon",
        {"file_type": "test", "pattern_type": "semicolon"}
    )
    assert 'pattern_type' in suggestion, "Missing pattern_type in suggestion"
    assert 'recommendation' in suggestion, "Missing recommendation in suggestion"
    
    print("Component integration tests passed")

def test_fixer_integration():
    """Test integration of Enhanced Syntax Fixer V2 with learning components."""
    print("Testing Enhanced Syntax Fixer V2 integration...")
    
    # Create temporary directory for test files
    test_dir = tempfile.mkdtemp()
    
    try:
        # Create test file
        test_file = os.path.join(test_dir, "integration_test.nc")
        with open(test_file, 'w') as f:
            f.write('let x = 5\nprint "hello"\ndef test_func(param1, param2)\nreturn x')
        
        # Initialize fixer with learning system
        system = create_syntax_fixer_learning_system()
        fixer = EnhancedNoodleCoreSyntaxFixerV2(
            enable_ai=False,  # Disable AI for simpler testing
            enable_learning=True,
            database_config=None
        )
        
        # Manually inject the learning system for testing
        fixer.learning_system = system
        
        # Test file fixing with learning integration
        result = fixer.fix_file_enhanced(test_file, create_backup=True)
        
        assert result['success'], "File fixing failed"
        assert result['fixes_applied'] > 0, "No fixes applied"
        assert result['learning_enabled'], "Learning should be enabled"
        
        # Test that learning system was used
        # Note: The fixer creates its own learning system, so we need to check the fixer's learning system
        assert len(fixer.learning_system['fix_result_collector'].fix_results) > 0, "No fix results collected"
        
        # Test recording feedback through fixer
        feedback_result = fixer.record_user_feedback(
            result['fix_id'],
            True,
            "Excellent fix!",
            {"rating": 5, "comments": "Very helpful"}
        )
        assert feedback_result['success'], "Failed to record feedback through fixer"
        
        # Test that feedback was processed by learning system
        assert len(system['feedback_processor'].feedback_history) > 0, "No feedback processed"
        
        # Test getting performance metrics
        metrics = fixer.get_performance_metrics()
        assert 'files_processed' in metrics, "Missing files_processed in metrics"
        assert 'learning_updates' in metrics, "Missing learning_updates in metrics"
        
        print("Enhanced Syntax Fixer V2 integration tests passed")
        
    finally:
        # Clean up
        shutil.rmtree(test_dir, ignore_errors=True)

def test_self_improver_integration():
    """Test integration of NoodleCoreSelfImproverV2 with learning system."""
    print("Testing Self Improver V2 integration...")
    
    # Create learning system
    learning_system = create_syntax_fixer_learning_system()
    
    # Initialize self improver with learning system
    improver = NoodleCoreSelfImproverV2({
        'enable_database': False,
        'learning_system': learning_system  # Use our integrated system
    })
    
    # Test starting monitoring
    result = improver.start_monitoring()
    assert result == True, "Failed to start monitoring"
    
    # Test that learning system is accessible through improver
    fixer_status = improver.get_syntax_fixer_status()
    assert 'status' in fixer_status, "Missing status in fixer status"
    assert 'learning_metrics' in fixer_status, "Missing learning metrics in fixer status"
    
    # Test system analysis with learning integration
    analysis_result = improver.analyze_system_for_improvements()
    assert 'improvement_opportunities' in analysis_result, "Missing improvement opportunities"
    assert 'system_health_score' in analysis_result, "Missing system health score"
    
    # Test configuration
    config = {
        'syntax_learning': {
            'learning_interval': 1800,
            'focus': 'quality_improvement',
            'enable_adaptive_learning': True
        }
    }
    
    config_result = improver.configure(config)
    assert config_result == True, "Failed to configure"
    
    # Test shutdown
    improver.shutdown()
    assert not improver.monitoring_active, "Monitoring still active after shutdown"
    
    print("Self Improver V2 integration tests passed")

def test_data_flow_integration():
    """Test complete data flow between all components."""
    print("Testing complete data flow integration...")
    
    # Create learning system
    system = create_syntax_fixer_learning_system()
    
    # Create test fix results with different scenarios
    fix_results = [
        FixResult(
            fix_id="flow-test-1",
            file_path="/test/flow1.nc",
            original_content="let x = 5",
            fixed_content="let x = 5;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.9,
            fix_time=0.1,
            user_accepted=True,
            timestamp=None
        ),
        FixResult(
            fix_id="flow-test-2",
            file_path="/test/flow2.nc",
            original_content="import math",
            fixed_content='import "math";',
            fixes_applied=[{"type": "import_fix", "line": 1}],
            confidence_score=0.8,
            fix_time=0.15,
            user_accepted=False,
            timestamp=None
        ),
        FixResult(
            fix_id="flow-test-3",
            file_path="/test/flow3.nc",
            original_content="def test_func(param1, param2)",
            fixed_content="def test_func(param1, param2):",
            fixes_applied=[{"type": "function_def", "line": 1}],
            confidence_score=0.7,
            fix_time=0.2,
            user_accepted=True,
            timestamp=None
        )
    ]
    
    # 1. Collect all fix results
    collector = system['fix_result_collector']
    for fix_result in fix_results:
        result = collector.collect_fix_result(fix_result)
        assert result == True, f"Failed to collect fix result {fix_result.fix_id}"
    
    # 2. Analyze patterns in all fix results
    analyzer = system['pattern_analyzer']
    analysis = analyzer.analyze_fix_results_patterns(fix_results)
    assert analysis['total_results'] == 3, "Wrong total results count"
    assert 'success_rates' in analysis, "Missing success rates in analysis"
    
    # 3. Learn from all fix results
    engine = system['learning_engine']
    learning_result = engine.learn_from_fix_results(fix_results)
    assert learning_result['status'] == 'success', "Learning from all results failed"
    assert learning_result['patterns_updated'] > 0, "No patterns were updated"
    
    # 4. Process feedback for all fix results
    processor = system['feedback_processor']
    for i, fix_result in enumerate(fix_results):
        feedback_result = processor.process_user_feedback(
            fix_result.fix_id,
            fix_result.user_accepted,
            f"Feedback for fix {i+1}",
            {"pattern_type": fix_result.fixes_applied[0]['type'], "file_type": "test"}
        )
        assert feedback_result['status'] == 'success', f"Failed to process feedback for {fix_result.fix_id}"
    
    # 5. Verify data consistency across components
    # Check that collector has all fix results
    assert len(collector.fix_results) == 3, "Not all fix results in collector"
    
    # Check that processor has all feedback
    assert len(processor.feedback_history) == 3, "Not all feedback in processor"
    
    # Check that learning engine has updated patterns
    assert len(engine.pattern_performance) > 0, "No patterns learned"
    
    # 6. Test adaptive suggestions based on learned data
    suggestion = processor.get_adaptive_suggestions(
        "semicolon",
        {"file_type": "test", "pattern_type": "semicolon"}
    )
    assert 'historical_acceptance_rate' in suggestion, "Missing historical acceptance rate"
    assert 'recommendation' in suggestion, "Missing recommendation"
    
    print("Complete data flow integration tests passed")

def main():
    """Run all integration tests."""
    print("Running Phase 2.1 Integration Tests")
    print("=" * 50)
    
    try:
        test_component_integration()
        test_fixer_integration()
        test_self_improver_integration()
        test_data_flow_integration()
        
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

