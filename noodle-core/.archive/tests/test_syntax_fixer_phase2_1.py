#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_fixer_phase2_1.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive Tests for Phase 2.1: Syntax Fixer Self-Improvement Feedback Loops

This module tests all components implemented in phase 2.1:
- FixResultCollector
- PatternAnalyzer
- LearningEngine
- FeedbackProcessor
- Enhanced Syntax Fixer v2
- NoodleCore Self-Improvement System v2
"""

import os
import sys
import unittest
import tempfile
import shutil
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, timedelta

# Add the noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.syntax_fixer_learning import (
    FixResultCollector, PatternAnalyzer, LearningEngine, FeedbackProcessor,
    FixResult, PatternMatch, LearningPattern, create_syntax_fixer_learning_system
)
from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
from noodlecore.noodlecore_self_improvement_system_v2 import (
    NoodleCoreSelfImproverV2, SyntaxFixLearningModule, ContinuousImprovementCycle
)
from noodlecore.database.database_manager import DatabaseConfig

class TestFixResultCollector(unittest.TestCase):
    """Test cases for FixResultCollector component."""
    
    def setUp(self):
        """Set up test environment."""
        self.collector = FixResultCollector()
    
    def test_collect_fix_result(self):
        """Test collecting a fix result."""
        fix_result = FixResult(
            fix_id="test-fix-1",
            file_path="/test/file.nc",
            original_content="let x = 5",
            fixed_content="let x = 5;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.9,
            fix_time=0.1
        )
        
        result = self.collector.collect_fix_result(fix_result)
        
        self.assertTrue(result)
        self.assertEqual(len(self.collector.fix_results), 1)
        self.assertEqual(self.collector.fix_results[0].fix_id, "test-fix-1")
    
    def test_record_user_feedback(self):
        """Test recording user feedback."""
        # First collect a fix result
        fix_result = FixResult(
            fix_id="test-fix-2",
            file_path="/test/file2.nc",
            original_content="let y = 10",
            fixed_content="let y = 10;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.8,
            fix_time=0.15
        )
        self.collector.collect_fix_result(fix_result)
        
        # Record feedback
        result = self.collector.record_user_feedback("test-fix-2", True, "Good fix!")
        
        self.assertTrue(result)
        
        # Check feedback was recorded
        collected_result = self.collector.fix_results[0]
        self.assertTrue(collected_result.user_accepted)
        self.assertEqual(collected_result.user_feedback, "Good fix!")
    
    def test_get_effectiveness_metrics(self):
        """Test calculating effectiveness metrics."""
        # Add some test data
        for i in range(10):
            fix_result = FixResult(
                fix_id=f"test-fix-{i}",
                file_path=f"/test/file{i}.nc",
                original_content=f"let x{i} = {i}",
                fixed_content=f"let x{i} = {i};",
                fixes_applied=[{"type": "semicolon", "line": 1}],
                confidence_score=0.8 + (i * 0.02),
                fix_time=0.1 + (i * 0.01),
                user_accepted=i % 3 != 0,  # 2/3 accepted
                timestamp=datetime.now() - timedelta(days=i)
            )
            self.collector.collect_fix_result(fix_result)
        
        metrics = self.collector.get_effectiveness_metrics(days=30)
        
        self.assertEqual(metrics['total_fixes'], 10)
        self.assertGreaterEqual(metrics['acceptance_rate'], 60)  # Should be around 66%
        self.assertGreater(metrics['average_confidence'], 0.8)
        self.assertGreater(metrics['average_fix_time'], 0.1)
    
    def test_clear_cache(self):
        """Test clearing the cache."""
        # Add some data
        fix_result = FixResult(
            fix_id="test-fix-clear",
            file_path="/test/clear.nc",
            original_content="let z = 15",
            fixed_content="let z = 15;",
            fixes_applied=[{"type": "semicolon", "line": 1}],
            confidence_score=0.9,
            fix_time=0.1
        )
        self.collector.collect_fix_result(fix_result)
        
        self.assertEqual(len(self.collector.fix_results), 1)
        
        # Clear cache
        self.collector.clear_cache()
        
        self.assertEqual(len(self.collector.fix_results), 0)

class TestPatternAnalyzer(unittest.TestCase):
    """Test cases for PatternAnalyzer component."""
    
    def setUp(self):
        """Set up test environment."""
        self.analyzer = PatternAnalyzer()
    
    def test_analyze_patterns_in_content(self):
        """Test analyzing patterns in content."""
        content = """
        let x = 5
        print "hello"
        def test_func(param1, param2)
        if x > 0
            print "positive"
        """
        
        matches = self.analyzer.analyze_patterns_in_content(content, "/test/file.nc")
        
        # Should find multiple patterns
        self.assertGreater(len(matches), 0)
        
        # Check for specific patterns
        pattern_types = [match.pattern_type for match in matches]
        self.assertIn("syntax", pattern_types)  # Should find syntax issues
    
    def test_analyze_fix_results_patterns(self):
        """Test analyzing patterns in fix results."""
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
        
        analysis = self.analyzer.analyze_fix_results_patterns(fix_results)
        
        self.assertEqual(analysis['total_results'], 2)
        self.assertIn('success_rates', analysis)
        self.assertIn('improvement_opportunities', analysis)
        
        # Check success rates
        success_rates = analysis['success_rates']
        self.assertIn('semicolon', success_rates)
        self.assertIn('import_fix', success_rates)
    
    def test_get_learning_insights(self):
        """Test getting learning insights."""
        insights = self.analyzer.get_learning_insights(days=30)
        
        self.assertIn('period_days', insights)
        self.assertIn('patterns_analyzed', insights)
        self.assertIn('insights', insights)
        
        # Should have some insights
        self.assertGreater(len(insights['insights']), 0)
    
    def test_update_pattern_definition(self):
        """Test updating pattern definitions."""
        original_description = self.analyzer.pattern_definitions['missing_semicolon']['description']
        
        updates = {
            'description': 'Updated description for missing semicolon',
            'confidence_boost': 0.1
        }
        
        result = self.analyzer.update_pattern_definition('missing_semicolon', updates)
        
        self.assertTrue(result)
        self.assertEqual(
            self.analyzer.pattern_definitions['missing_semicolon']['description'],
            'Updated description for missing semicolon'
        )

class TestLearningEngine(unittest.TestCase):
    """Test cases for LearningEngine component."""
    
    def setUp(self):
        """Set up test environment."""
        self.engine = LearningEngine()
    
    def test_learn_from_fix_results(self):
        """Test learning from fix results."""
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
            ),
            FixResult(
                fix_id="learn-2",
                file_path="/test/learn2.nc",
                original_content="import math",
                fixed_content='import "math";',
                fixes_applied=[{"type": "import_fix", "line": 1}],
                confidence_score=0.7,
                fix_time=0.2,
                user_accepted=False
            )
        ]
        
        learning_result = self.engine.learn_from_fix_results(fix_results)
        
        self.assertEqual(learning_result['status'], 'success')
        self.assertGreater(learning_result['patterns_updated'], 0)
        self.assertIn('new_insights', learning_result)
    
    def test_get_pattern_confidence(self):
        """Test getting pattern confidence."""
        # Set up some performance data
        self.engine.pattern_performance['test_pattern'] = {
            'success_rate': 85.0,
            'usage_count': 15
        }
        
        confidence = self.engine.get_pattern_confidence('test_pattern')
        
        self.assertGreater(confidence, 0.8)  # Should be high confidence
        self.assertLessEqual(confidence, 1.0)
    
    def test_suggest_fix_strategy(self):
        """Test suggesting fix strategies."""
        context = {
            'file_path': '/test/strategy.nc',
            'file_size': 1000
        }
        
        strategy = self.engine.suggest_fix_strategy('missing_semicolon', context)
        
        self.assertEqual(strategy['pattern_type'], 'missing_semicolon')
        self.assertIn('recommended_approach', strategy)
        self.assertIn('confidence', strategy)
        self.assertIn('adaptations', strategy)
    
    def test_get_learning_status(self):
        """Test getting learning status."""
        status = self.engine.get_learning_status()
        
        self.assertIn('learning_enabled', status)
        self.assertIn('learning_rate', status)
        self.assertIn('patterns_learned', status)

class TestFeedbackProcessor(unittest.TestCase):
    """Test cases for FeedbackProcessor component."""
    
    def setUp(self):
        """Set up test environment."""
        self.processor = FeedbackProcessor()
    
    def test_process_user_feedback(self):
        """Test processing user feedback."""
        feedback_result = self.processor.process_user_feedback(
            "test-fix-1",
            True,
            "Excellent fix, worked perfectly!"
        )
        
        self.assertEqual(feedback_result['status'], 'success')
        self.assertEqual(feedback_result['feedback_type'], 'acceptance')
        self.assertEqual(feedback_result['sentiment'], 'positive')
    
    def test_analyze_sentiment(self):
        """Test sentiment analysis."""
        positive_sentiment = self.processor._analyze_sentiment("Great fix, very helpful!")
        self.assertEqual(positive_sentiment, 'positive')
        
        negative_sentiment = self.processor._analyze_sentiment("Bad fix, didn't work")
        self.assertEqual(negative_sentiment, 'negative')
        
        neutral_sentiment = self.processor._analyze_sentiment("The fix was applied")
        self.assertEqual(neutral_sentiment, 'neutral')
    
    def test_get_adaptive_suggestions(self):
        """Test getting adaptive suggestions."""
        # Add some feedback history with proper context
        for i in range(10):
            context = {
                'pattern_type': 'missing_semicolon',
                'file_type': 'test'
            }
            self.processor.process_user_feedback(
                f"test-fix-{i}",
                i % 3 != 0,  # 2/3 accepted
                "Good" if i % 3 != 0 else "Needs improvement",
                context
            )
        
        test_context = {
            'file_type': 'test'
        }
        
        suggestion = self.processor.get_adaptive_suggestions('missing_semicolon', test_context)
        
        self.assertEqual(suggestion['pattern_type'], 'missing_semicolon')
        self.assertIn('historical_acceptance_rate', suggestion)
        self.assertIn('recommendation', suggestion)
        self.assertIn('confidence', suggestion)
    
    def test_get_feedback_summary(self):
        """Test getting feedback summary."""
        # Add some feedback data
        for i in range(5):
            self.processor.process_user_feedback(
                f"summary-fix-{i}",
                i % 2 == 0,
                f"Feedback {i}"
            )
        
        summary = self.processor.get_feedback_summary(days=30)
        
        self.assertIn('period_days', summary)
        self.assertIn('total_feedback', summary)
        self.assertIn('acceptance_rate', summary)
        self.assertIn('common_insights', summary)

class TestEnhancedSyntaxFixerV2(unittest.TestCase):
    """Test cases for EnhancedNoodleCoreSyntaxFixerV2."""
    
    def setUp(self):
        """Set up test environment."""
        # Create temporary directory for test files
        self.test_dir = tempfile.mkdtemp()
        
        # Create test file
        self.test_file = os.path.join(self.test_dir, "test.nc")
        with open(self.test_file, 'w') as f:
            f.write('let x = 5\nprint "hello"')
        
        # Initialize fixer without database for testing
        self.fixer = EnhancedNoodleCoreSyntaxFixerV2(
            enable_ai=False,  # Disable AI for simpler testing
            enable_learning=True,
            database_config=None
        )
    
    def tearDown(self):
        """Clean up test environment."""
        shutil.rmtree(self.test_dir, ignore_errors=True)
    
    def test_fix_file_enhanced(self):
        """Test enhanced file fixing."""
        result = self.fixer.fix_file_enhanced(self.test_file, create_backup=True)
        
        self.assertTrue(result['success'])
        self.assertGreater(result['fixes_applied'], 0)
        self.assertTrue(result['learning_enabled'])
        self.assertIsNotNone(result['fix_id'])
        
        # Check if backup was created
        backup_path = self.test_file + '.bak'
        self.assertTrue(os.path.exists(backup_path))
    
    def test_record_user_feedback(self):
        """Test recording user feedback."""
        # First fix a file
        result = self.fixer.fix_file_enhanced(self.test_file)
        fix_id = result['fix_id']
        
        # Record feedback
        feedback_result = self.fixer.record_user_feedback(fix_id, True, "Good fix!")
        
        self.assertTrue(feedback_result['success'])
        self.assertTrue(feedback_result['user_accepted'])
        self.assertEqual(feedback_result['feedback'], "Good fix!")
    
    def test_get_performance_metrics(self):
        """Test getting performance metrics."""
        # Fix a file to generate some metrics
        self.fixer.fix_file_enhanced(self.test_file)
        
        metrics = self.fixer.get_performance_metrics()
        
        self.assertIn('files_processed', metrics)
        self.assertIn('total_fixes', metrics)
        self.assertIn('learning_enabled', metrics)
        self.assertIn('learning_updates', metrics)
    
    def test_get_status(self):
        """Test getting fixer status."""
        status = self.fixer.get_status()
        
        self.assertEqual(status['version'], 'v2')
        self.assertIn('learning_enabled', status)
        self.assertIn('statistics', status)

class TestNoodleCoreSelfImproverV2(unittest.TestCase):
    """Test cases for NoodleCoreSelfImproverV2."""
    
    def setUp(self):
        """Set up test environment."""
        self.improver = NoodleCoreSelfImproverV2({
            'enable_database': False  # Disable database for testing
        })
    
    def test_start_monitoring(self):
        """Test starting monitoring."""
        result = self.improver.start_monitoring()
        
        self.assertTrue(result)
        self.assertTrue(self.improver.monitoring_active)
    
    def test_analyze_codebase(self):
        """Test codebase analysis."""
        result = self.improver.analyze_codebase("/test/path")
        
        self.assertIn('status', result)
        self.assertIn('syntax_fixer_integration', result)
    
    def test_analyze_system_for_improvements(self):
        """Test system analysis for improvements."""
        result = self.improver.analyze_system_for_improvements()
        
        self.assertIn('improvement_opportunities', result)
        self.assertIn('system_health_score', result)
        self.assertIn('syntax_fixer_status', result)
    
    def test_get_syntax_fixer_status(self):
        """Test getting syntax fixer status."""
        status = self.improver.get_syntax_fixer_status()
        
        self.assertIn('status', status)
        self.assertIn('learning_metrics', status)
    
    def test_configure(self):
        """Test configuration."""
        config = {
            'syntax_learning': {
                'learning_interval': 1800,
                'focus': 'quality_improvement'
            }
        }
        
        result = self.improver.configure(config)
        
        self.assertTrue(result)
    
    def test_shutdown(self):
        """Test shutdown."""
        # Start monitoring first
        self.improver.start_monitoring()
        
        # Then shutdown
        self.improver.shutdown()
        
        self.assertFalse(self.improver.monitoring_active)

class TestSyntaxFixLearningModule(unittest.TestCase):
    """Test cases for SyntaxFixLearningModule."""
    
    def setUp(self):
        """Set up test environment."""
        self.module = SyntaxFixLearningModule()
    
    def test_start_learning(self):
        """Test starting learning."""
        result = self.module.start_learning()
        
        self.assertTrue(result)
        self.assertTrue(self.module.learning_active)
    
    def test_stop_learning(self):
        """Test stopping learning."""
        # Start first
        self.module.start_learning()
        
        # Then stop
        result = self.module.stop_learning()
        
        self.assertTrue(result)
        self.assertFalse(self.module.learning_active)
    
    def test_get_learning_metrics(self):
        """Test getting learning metrics."""
        metrics = self.module.get_learning_metrics()
        
        self.assertIn('total_fixes_analyzed', metrics)
        self.assertIn('patterns_learned', metrics)
        self.assertIn('learning_cycles', metrics)

class TestContinuousImprovementCycle(unittest.TestCase):
    """Test cases for ContinuousImprovementCycle."""
    
    def setUp(self):
        """Set up test environment."""
        learning_module = Mock()
        learning_module.fix_result_collector = Mock()
        learning_module.pattern_analyzer = Mock()
        learning_module.learning_engine = Mock()
        learning_module.feedback_processor = Mock()
        
        self.cycle = ContinuousImprovementCycle(learning_module)
    
    def test_start_cycles(self):
        """Test starting improvement cycles."""
        result = self.cycle.start_cycles()
        
        self.assertTrue(result)
        self.assertTrue(self.cycle.cycle_active)
    
    def test_stop_cycles(self):
        """Test stopping improvement cycles."""
        # Start first
        self.cycle.start_cycles()
        
        # Then stop
        result = self.cycle.stop_cycles()
        
        self.assertTrue(result)
        self.assertFalse(self.cycle.cycle_active)
    
    def test_get_cycle_status(self):
        """Test getting cycle status."""
        status = self.cycle.get_cycle_status()
        
        self.assertIn('cycles_active', status)
        self.assertIn('daily_analysis_enabled', status)
        self.assertIn('weekly_analysis_enabled', status)

class TestIntegration(unittest.TestCase):
    """Integration tests for the complete phase 2.1 system."""
    
    def setUp(self):
        """Set up test environment."""
        self.test_dir = tempfile.mkdtemp()
        
        # Create test files
        self.test_files = []
        for i in range(3):
            file_path = os.path.join(self.test_dir, f"test{i}.nc")
            with open(file_path, 'w') as f:
                f.write(f'let x{i} = {i}\nprint "test{i}"')
            self.test_files.append(file_path)
        
        # Initialize complete system
        self.fixer = EnhancedNoodleCoreSyntaxFixerV2(
            enable_ai=False,
            enable_learning=True,
            database_config=None
        )
        
        self.improver = NoodleCoreSelfImproverV2({
            'enable_database': False
        })
    
    def tearDown(self):
        """Clean up test environment."""
        shutil.rmtree(self.test_dir, ignore_errors=True)
    
    def test_end_to_end_workflow(self):
        """Test complete end-to-end workflow."""
        # Start monitoring
        self.improver.start_monitoring()
        
        # Fix files
        fix_results = []
        for file_path in self.test_files:
            result = self.fixer.fix_file_enhanced(file_path)
            fix_results.append(result)
            
            # Record some feedback
            if result['success']:
                self.fixer.record_user_feedback(
                    result['fix_id'],
                    True,  # Accept all fixes
                    "Good fix"
                )
        
        # Check that fixes were applied
        successful_fixes = [r for r in fix_results if r['success']]
        self.assertEqual(len(successful_fixes), len(self.test_files))
        
        # Get system status
        system_status = self.improver.analyze_system_for_improvements()
        
        self.assertIn('syntax_fixer_status', system_status)
        self.assertIn('system_health_score', system_status)
        
        # Shutdown
        self.improver.shutdown()
    
    def test_learning_integration(self):
        """Test learning integration between components."""
        # Fix a file multiple times to generate learning data
        file_path = self.test_files[0]
        
        for i in range(5):
            result = self.fixer.fix_file_enhanced(file_path)
            
            if result['success']:
                # Record feedback
                feedback = "Good" if i % 2 == 0 else "OK"
                self.fixer.record_user_feedback(
                    result['fix_id'],
                    i % 2 == 0,  # Alternate acceptance
                    feedback
                )
        
        # Check learning metrics
        metrics = self.fixer.get_performance_metrics()
        
        self.assertGreater(metrics['learning_updates'], 0)
        self.assertGreater(metrics['user_feedback_count'], 0)
        
        # Get syntax fixer status
        fixer_status = self.improver.get_syntax_fixer_status()
        
        self.assertEqual(fixer_status['status'], 'active')

def run_all_tests():
    """Run all test suites."""
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add all test classes
    test_classes = [
        TestFixResultCollector,
        TestPatternAnalyzer,
        TestLearningEngine,
        TestFeedbackProcessor,
        TestEnhancedSyntaxFixerV2,
        TestNoodleCoreSelfImproverV2,
        TestSyntaxFixLearningModule,
        TestContinuousImprovementCycle,
        TestIntegration
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        test_suite.addTests(tests)
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Return success status
    return result.wasSuccessful()

if __name__ == '__main__':
    print("Running Phase 2.1 Syntax Fixer Self-Improvement Tests")
    print("=" * 60)
    
    success = run_all_tests()
    
    print("\n" + "=" * 60)
    if success:
        print("All tests passed!")
        sys.exit(0)
    else:
        print("Some tests failed!")
        sys.exit(1)

