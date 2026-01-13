#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_ux_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Enhanced User Experience Integration Test Suite

This module provides comprehensive tests for all enhanced user experience components:
- FeedbackCollectionUI
- ExplainableAI
- InteractiveFixModifier
- UserExperienceManager
- FeedbackAnalyzer
- EnhancedUXIntegration

Tests cover functionality, integration, performance, and error handling.
"""

import os
import sys
import unittest
import tempfile
import json
import uuid
import threading
import time
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, timedelta
from pathlib import Path

# Add the project root to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

# Import components to test
from noodlecore.desktop.ide.feedback_collection_ui import (
    FeedbackCollectionUI, FeedbackRequest, FeedbackResponse, FeedbackCategory
)
from noodlecore.ai_agents.explainable_ai import (
    ExplainableAI, FixExplanation, FixType
)
from noodlecore.desktop.ide.interactive_fix_modifier import (
    InteractiveFixModifier, FixModificationRequest, FixModificationType
)
from noodlecore.desktop.ide.user_experience_manager import (
    UserExperienceManager, ThemeType, AccessibilityMode, PerformanceMode
)
from noodlecore.ai_agents.feedback_analyzer import (
    FeedbackAnalyzer, FeedbackEntry, SentimentType, FeedbackCategory
)
from noodlecore.desktop.ide.enhanced_ux_integration import (
    EnhancedUXIntegration, UXIntegrationConfig
)

class TestFeedbackCollectionUI(unittest.TestCase):
    """Test cases for FeedbackCollectionUI."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_ide = Mock()
        self.mock_database_pool = Mock()
        self.mock_feedback_analyzer = Mock()
        
        self.feedback_ui = FeedbackCollectionUI(
            self.mock_ide,
            self.mock_database_pool,
            self.mock_feedback_analyzer
        )
    
    def test_feedback_request_creation(self):
        """Test feedback request creation."""
        request = FeedbackRequest(
            session_id="test_session",
            fix_id="test_fix",
            original_code="def test():\n    print('hello')",
            fixed_code="def test():\n    print('hello')\n",
            error_info={"type": "syntax_error", "line": 2},
            auto_show=False
        )
        
        self.assertEqual(request.session_id, "test_session")
        self.assertEqual(request.fix_id, "test_fix")
        self.assertEqual(request.category, FeedbackCategory.FIX_QUALITY)
        self.assertFalse(request.auto_show)
    
    def test_feedback_response_creation(self):
        """Test feedback response creation."""
        response = FeedbackResponse(
            session_id="test_session",
            fix_id="test_fix",
            rating=4,
            category=FeedbackCategory.FIX_QUALITY,
            comment="Good fix, worked well",
            tags=["helpful", "accurate"],
            would_recommend=True
        )
        
        self.assertEqual(response.session_id, "test_session")
        self.assertEqual(response.rating, 4)
        self.assertEqual(response.category, FeedbackCategory.FIX_QUALITY)
        self.assertTrue(response.would_recommend)
    
    def test_collect_feedback_success(self):
        """Test successful feedback collection."""
        request = FeedbackRequest(
            session_id="test_session",
            fix_id="test_fix",
            original_code="def test():\n    print('hello')",
            fixed_code="def test():\n    print('hello')\n",
            error_info={"type": "syntax_error", "line": 2}
        )
        
        # Mock the database operations
        self.mock_database_pool.get_connection.return_value.__enter__.return_value = Mock()
        
        response = self.feedback_ui.collect_feedback(request)
        
        self.assertIsNotNone(response)
        self.assertEqual(response.session_id, request.session_id)
        self.assertEqual(response.fix_id, request.fix_id)
    
    def test_get_statistics(self):
        """Test statistics retrieval."""
        stats = self.feedback_ui.get_statistics()
        
        self.assertIsInstance(stats, dict)
        self.assertIn("total_requests", stats)
        self.assertIn("total_responses", stats)
        self.assertIn("average_rating", stats)
    
    def test_configure_settings(self):
        """Test settings configuration."""
        settings = {
            "auto_show_delay": 10,
            "min_rating_for_improvement": 3,
            "enable_sentiment_analysis": True
        }
        
        self.feedback_ui.configure_settings(settings)
        
        # Verify settings were applied
        self.assertEqual(self.feedback_ui.config["auto_show_delay"], 10)
        self.assertEqual(self.feedback_ui.config["min_rating_for_improvement"], 3)
        self.assertTrue(self.feedback_ui.config["enable_sentiment_analysis"])

class TestExplainableAI(unittest.TestCase):
    """Test cases for ExplainableAI."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_syntax_fixer = Mock()
        self.mock_database_pool = Mock()
        
        self.explainable_ai = ExplainableAI(
            self.mock_syntax_fixer,
            self.mock_database_pool
        )
    
    def test_explain_fix_basic(self):
        """Test basic fix explanation."""
        original_code = "def test():\n    print('hello')"
        fixed_code = "def test():\n    print('hello')\n"
        error_info = {"type": "syntax_error", "line": 2, "message": "Missing newline at end of file"}
        
        explanation = self.explainable_ai.explain_fix(original_code, fixed_code, error_info)
        
        self.assertIsNotNone(explanation)
        self.assertIsInstance(explanation, FixExplanation)
        self.assertEqual(explanation.fix_type, FixType.SYNTAX_ERROR)
        self.assertGreater(explanation.confidence, 0.0)
        self.assertIn("Missing newline", explanation.reasoning)
    
    def test_explain_fix_with_context(self):
        """Test fix explanation with context."""
        original_code = "def test():\n    x = 1\n    return x"
        fixed_code = "def test():\n    x = 1\n    return x\n"
        error_info = {"type": "syntax_error", "line": 3, "message": "Missing newline at end of file"}
        
        context = {
            "file_type": "python",
            "function_name": "test",
            "surrounding_code": "# Function definition\ndef test():\n    x = 1\n    return x\n\n# End of file"
        }
        
        explanation = self.explainable_ai.explain_fix(original_code, fixed_code, error_info, context)
        
        self.assertIsNotNone(explanation)
        self.assertIsInstance(explanation, FixExplanation)
        self.assertGreater(len(explanation.changes), 0)
        self.assertIn("newline", explanation.reasoning.lower())
    
    def test_generate_alternatives(self):
        """Test alternative fix generation."""
        original_code = "def test():\n    print('hello')"
        fixed_code = "def test():\n    print('hello')\n"
        error_info = {"type": "syntax_error", "line": 2, "message": "Missing newline at end of file"}
        
        alternatives = self.explainable_ai.generate_alternatives(original_code, fixed_code, error_info)
        
        self.assertIsInstance(alternatives, list)
        self.assertGreater(len(alternatives), 0)
        
        for alternative in alternatives:
            self.assertIn("description", alternative)
            self.assertIn("code", alternative)
            self.assertIn("confidence", alternative)
    
    def test_get_statistics(self):
        """Test statistics retrieval."""
        stats = self.explainable_ai.get_statistics()
        
        self.assertIsInstance(stats, dict)
        self.assertIn("total_explanations", stats)
        self.assertIn("average_confidence", stats)
        self.assertIn("explanations_by_type", stats)

class TestInteractiveFixModifier(unittest.TestCase):
    """Test cases for InteractiveFixModifier."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_ide = Mock()
        self.mock_syntax_fixer = Mock()
        self.mock_database_pool = Mock()
        
        self.interactive_modifier = InteractiveFixModifier(
            self.mock_ide,
            self.mock_syntax_fixer,
            self.mock_database_pool
        )
    
    def test_fix_modification_request_creation(self):
        """Test fix modification request creation."""
        request = FixModificationRequest(
            session_id="test_session",
            fix_id="test_fix",
            original_code="def test():\n    print('hello')",
            current_fix="def test():\n    print('hello')\n",
            error_info={"type": "syntax_error", "line": 2},
            auto_show=False
        )
        
        self.assertEqual(request.session_id, "test_session")
        self.assertEqual(request.fix_id, "test_fix")
        self.assertFalse(request.auto_show)
    
    def test_apply_modification_basic(self):
        """Test basic modification application."""
        original_code = "def test():\n    print('hello')"
        current_fix = "def test():\n    print('hello')\n"
        
        # Apply a simple modification
        modified_code = self.interactive_modifier.apply_modification(
            current_fix,
            FixModificationType.INSERT_TEXT,
            {"position": len(current_fix), "text": "# End of file"}
        )
        
        self.assertIn("# End of file", modified_code)
        self.assertTrue(modified_code.endswith("# End of file"))
    
    def test_preview_modification(self):
        """Test modification preview."""
        original_code = "def test():\n    print('hello')"
        current_fix = "def test():\n    print('hello')\n"
        
        preview = self.interactive_modifier.preview_modification(
            current_fix,
            FixModificationType.REPLACE_TEXT,
            {"start": 0, "end": len(current_fix), "text": "# Modified code"}
        )
        
        self.assertIn("original", preview)
        self.assertIn("modified", preview)
        self.assertIn("diff", preview)
        self.assertEqual(preview["modified"], "# Modified code")
    
    def test_validate_modification(self):
        """Test modification validation."""
        original_code = "def test():\n    print('hello')"
        current_fix = "def test():\n    print('hello')\n"
        
        # Valid modification
        is_valid, issues = self.interactive_modifier.validate_modification(
            original_code,
            current_fix + "# Added comment"
        )
        
        self.assertTrue(is_valid)
        self.assertEqual(len(issues), 0)
        
        # Invalid modification (introducing syntax error)
        is_valid, issues = self.interactive_modifier.validate_modification(
            original_code,
            current_fix + "def invalid_syntax(:"
        )
        
        self.assertFalse(is_valid)
        self.assertGreater(len(issues), 0)
    
    def test_get_statistics(self):
        """Test statistics retrieval."""
        stats = self.interactive_modifier.get_statistics()
        
        self.assertIsInstance(stats, dict)
        self.assertIn("total_modifications", stats)
        self.assertIn("successful_modifications", stats)
        self.assertIn("modification_types", stats)

class TestUserExperienceManager(unittest.TestCase):
    """Test cases for UserExperienceManager."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_ide = Mock()
        self.mock_database_pool = Mock()
        
        self.ux_manager = UserExperienceManager(
            self.mock_ide,
            self.mock_database_pool
        )
    
    def test_preference_creation(self):
        """Test preference creation."""
        preferences = self.ux_manager.get_preferences()
        
        self.assertIsNotNone(preferences)
        self.assertEqual(preferences.theme, ThemeType.DEFAULT)
        self.assertEqual(preferences.accessibility_mode, AccessibilityMode.STANDARD)
        self.assertEqual(preferences.performance_mode, PerformanceMode.BALANCED)
    
    def test_theme_configuration(self):
        """Test theme configuration."""
        self.ux_manager.configure_settings(theme="dark")
        
        preferences = self.ux_manager.get_preferences()
        self.assertEqual(preferences.theme, ThemeType.DARK)
    
    def test_accessibility_configuration(self):
        """Test accessibility configuration."""
        self.ux_manager.configure_settings(accessibility_mode="high_contrast")
        
        preferences = self.ux_manager.get_preferences()
        self.assertEqual(preferences.accessibility_mode, AccessibilityMode.HIGH_CONTRAST)
    
    def test_user_action_tracking(self):
        """Test user action tracking."""
        self.ux_manager.track_user_action("test_action", {"param1": "value1"})
        
        # Verify action was tracked
        self.assertIsNotNone(self.ux_manager.current_session)
        self.assertGreater(len(self.ux_manager.current_session.actions), 0)
        
        last_action = self.ux_manager.current_session.actions[-1]
        self.assertEqual(last_action["type"], "test_action")
        self.assertEqual(last_action["details"]["param1"], "value1")
    
    def test_get_statistics(self):
        """Test statistics retrieval."""
        stats = self.ux_manager.get_statistics()
        
        self.assertIsInstance(stats, dict)
        self.assertIn("current_theme", stats)
        self.assertIn("current_accessibility_mode", stats)
        self.assertIn("behavior_tracking_enabled", stats)

class TestFeedbackAnalyzer(unittest.TestCase):
    """Test cases for FeedbackAnalyzer."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_database_pool = Mock()
        self.mock_learning_system = Mock()
        
        self.feedback_analyzer = FeedbackAnalyzer(
            self.mock_database_pool,
            self.mock_learning_system
        )
    
    def test_feedback_entry_creation(self):
        """Test feedback entry creation."""
        entry = FeedbackEntry(
            id="test_entry",
            timestamp=datetime.now(),
            user_id="test_user",
            session_id="test_session",
            fix_id="test_fix",
            rating=4,
            sentiment=SentimentType.POSITIVE,
            category=FeedbackCategory.FIX_QUALITY,
            text="Great fix, worked perfectly!",
            tags=["helpful", "accurate"],
            metadata={}
        )
        
        self.assertEqual(entry.id, "test_entry")
        self.assertEqual(entry.rating, 4)
        self.assertEqual(entry.sentiment, SentimentType.POSITIVE)
        self.assertEqual(entry.category, FeedbackCategory.FIX_QUALITY)
    
    def test_sentiment_analysis_positive(self):
        """Test positive sentiment analysis."""
        text = "This is a great fix! I really like how it solved my problem. Very helpful and accurate."
        
        analysis = self.feedback_analyzer.analyze_sentiment(text)
        
        self.assertEqual(analysis.sentiment, SentimentType.POSITIVE)
        self.assertGreater(analysis.positive_score, analysis.negative_score)
        self.assertGreater(analysis.confidence, 0.5)
    
    def test_sentiment_analysis_negative(self):
        """Test negative sentiment analysis."""
        text = "This fix is terrible. It didn't work at all and made things worse. Very disappointed."
        
        analysis = self.feedback_analyzer.analyze_sentiment(text)
        
        self.assertEqual(analysis.sentiment, SentimentType.NEGATIVE)
        self.assertGreater(analysis.negative_score, analysis.positive_score)
        self.assertGreater(analysis.confidence, 0.5)
    
    def test_trend_analysis(self):
        """Test trend analysis."""
        # Add some test feedback entries
        base_time = datetime.now() - timedelta(days=30)
        
        for i in range(10):
            entry = FeedbackEntry(
                id=f"test_entry_{i}",
                timestamp=base_time + timedelta(days=i * 3),
                rating=3 + i % 3,  # Ratings 3, 4, 5, 3, 4, 5, ...
                sentiment=SentimentType.POSITIVE,
                category=FeedbackCategory.FIX_QUALITY,
                text=f"Test feedback {i}",
                tags=[],
                metadata={}
            )
            self.feedback_analyzer.add_feedback(entry)
        
        # Analyze trend
        trend = self.feedback_analyzer.analyze_trends("overall_rating", 30)
        
        self.assertIsNotNone(trend)
        self.assertIn(trend.direction, ["improving", "declining", "stable"])
        self.assertIsInstance(trend.change_rate, float)
    
    def test_satisfaction_metrics(self):
        """Test satisfaction metrics calculation."""
        # Add test feedback entries
        for i in range(5):
            entry = FeedbackEntry(
                id=f"test_entry_{i}",
                timestamp=datetime.now(),
                rating=4,
                sentiment=SentimentType.POSITIVE,
                category=FeedbackCategory.FIX_QUALITY,
                text=f"Test feedback {i}",
                tags=[],
                metadata={}
            )
            self.feedback_analyzer.add_feedback(entry)
        
        metrics = self.feedback_analyzer.calculate_satisfaction_metrics()
        
        self.assertIsNotNone(metrics)
        self.assertEqual(metrics.overall_rating, 4.0)
        self.assertGreater(metrics.fix_quality_rating, 0.0)
        self.assertIn(SentimentType.POSITIVE, metrics.sentiment_distribution)
    
    def test_improvement_suggestions(self):
        """Test improvement suggestion generation."""
        # Add negative feedback entries
        for i in range(3):
            entry = FeedbackEntry(
                id=f"negative_entry_{i}",
                timestamp=datetime.now(),
                rating=2,
                sentiment=SentimentType.NEGATIVE,
                category=FeedbackCategory.PERFORMANCE,
                text=f"The fix is slow and laggy {i}",
                tags=["slow", "performance"],
                metadata={}
            )
            self.feedback_analyzer.add_feedback(entry)
        
        suggestions = self.feedback_analyzer.generate_improvement_suggestions()
        
        self.assertIsInstance(suggestions, list)
        # Should have at least one suggestion for performance issues
        performance_suggestions = [s for s in suggestions if s.category == FeedbackCategory.PERFORMANCE]
        self.assertGreater(len(performance_suggestions), 0)
    
    def test_get_statistics(self):
        """Test statistics retrieval."""
        stats = self.feedback_analyzer.get_statistics()
        
        self.assertIsInstance(stats, dict)
        self.assertIn("total_feedback_processed", stats)
        self.assertIn("sentiment_analyses_performed", stats)
        self.assertIn("trend_analyses_performed", stats)

class TestEnhancedUXIntegration(unittest.TestCase):
    """Test cases for EnhancedUXIntegration."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_ide = Mock()
        self.mock_syntax_fixer = Mock()
        self.mock_syntax_fixer.database_pool = Mock()
        
        # Create temporary database for testing
        self.temp_db = tempfile.NamedTemporaryFile(delete=False)
        self.temp_db.close()
        
        self.ux_integration = EnhancedUXIntegration(
            self.mock_ide,
            self.mock_syntax_fixer
        )
    
    def tearDown(self):
        """Clean up test environment."""
        # Clean up temporary database
        try:
            os.unlink(self.temp_db.name)
        except:
            pass
    
    def test_integration_initialization(self):
        """Test integration initialization."""
        self.assertIsNotNone(self.ux_integration.ide)
        self.assertIsNotNone(self.ux_integration.syntax_fixer)
        self.assertIsNotNone(self.ux_integration.config)
        
        # Check components are initialized based on configuration
        if self.ux_integration.config.enable_user_experience_management:
            self.assertIsNotNone(self.ux_integration.ux_manager)
        
        if self.ux_integration.config.enable_feedback_analysis:
            self.assertIsNotNone(self.ux_integration.feedback_analyzer)
    
    def test_process_syntax_fix(self):
        """Test syntax fix processing through UX pipeline."""
        original_code = "def test():\n    print('hello')"
        fixed_code = "def test():\n    print('hello')\n"
        error_info = {"type": "syntax_error", "line": 2, "message": "Missing newline"}
        
        result = self.ux_integration.process_syntax_fix(original_code, fixed_code, error_info)
        
        self.assertIsNotNone(result)
        self.assertIn("fix_id", result)
        self.assertIn("ux_enhancements", result)
        self.assertIn("processing_time", result)
        
        # Check statistics were updated
        self.assertGreater(self.ux_integration.stats["total_fixes_processed"], 0)
    
    def test_request_feedback(self):
        """Test feedback request."""
        # First process a fix to create pending feedback
        original_code = "def test():\n    print('hello')"
        fixed_code = "def test():\n    print('hello')\n"
        error_info = {"type": "syntax_error", "line": 2}
        
        self.ux_integration.process_syntax_fix(original_code, fixed_code, error_info)
        
        # Request feedback
        with patch.object(self.ux_integration.feedback_ui, 'show_feedback_dialog') as mock_dialog:
            mock_response = Mock()
            mock_response.rating = 4
            mock_dialog.return_value = mock_response
            
            response = self.ux_integration.request_feedback()
            
            self.assertIsNotNone(response)
            mock_dialog.assert_called_once()
    
    def test_show_explanation(self):
        """Test explanation display."""
        # First process a fix to generate explanation
        original_code = "def test():\n    print('hello')"
        fixed_code = "def test():\n    print('hello')\n"
        error_info = {"type": "syntax_error", "line": 2}
        
        self.ux_integration.process_syntax_fix(original_code, fixed_code, error_info)
        
        # Show explanation
        with patch.object(self.ux_integration, '_show_explanation') as mock_show:
            result = self.ux_integration.show_explanation()
            
            self.assertTrue(result)
            mock_show.assert_called_once()
    
    def test_enable_interactive_mode(self):
        """Test interactive mode enabling."""
        # First process a fix
        original_code = "def test():\n    print('hello')"
        fixed_code = "def test():\n    print('hello')\n"
        error_info = {"type": "syntax_error", "line": 2}
        
        self.ux_integration.process_syntax_fix(original_code, fixed_code, error_info)
        
        # Enable interactive mode
        with patch.object(self.ux_integration.interactive_modifier, 'show_interactive_modifier') as mock_show:
            mock_show.return_value = True
            
            result = self.ux_integration.enable_interactive_mode()
            
            self.assertTrue(result)
            mock_show.assert_called_once()
    
    def test_configuration_updates(self):
        """Test configuration updates."""
        new_config = UXIntegrationConfig(
            enable_feedback_collection=False,
            enable_explainable_ai=True,
            enable_interactive_fixes=False,
            auto_show_feedback=False,
            auto_show_explanations=False
        )
        
        self.ux_integration.configure_integration(new_config)
        
        self.assertEqual(self.ux_integration.config.enable_feedback_collection, False)
        self.assertEqual(self.ux_integration.config.enable_explainable_ai, True)
        self.assertEqual(self.ux_integration.config.enable_interactive_fixes, False)
    
    def test_get_ux_statistics(self):
        """Test UX statistics retrieval."""
        stats = self.ux_integration.get_ux_statistics()
        
        self.assertIsInstance(stats, dict)
        self.assertIn("integration", stats)
        self.assertIn("components", stats)
        
        # Check integration stats
        integration_stats = stats["integration"]
        self.assertIn("total_fixes_processed", integration_stats)
        self.assertIn("feedback_requests_shown", integration_stats)
    
    def test_get_feedback_analytics(self):
        """Test feedback analytics retrieval."""
        analytics = self.ux_integration.get_feedback_analytics()
        
        self.assertIsInstance(analytics, dict)
        self.assertIn("satisfaction_metrics", analytics)
        self.assertIn("feedback_summary", analytics)
        self.assertIn("improvement_suggestions", analytics)
        self.assertIn("statistics", analytics)
    
    def test_component_interactions(self):
        """Test interactions between components."""
        # Test that components are properly connected
        if self.ux_integration.feedback_ui and self.ux_integration.feedback_analyzer:
            self.assertEqual(
                self.ux_integration.feedback_ui.feedback_analyzer,
                self.ux_integration.feedback_analyzer
            )
        
        if self.ux_integration.explainable_ai and self.ux_integration.interactive_modifier:
            self.assertEqual(
                self.ux_integration.interactive_modifier.explainable_ai,
                self.ux_integration.explainable_ai
            )
    
    def test_error_handling(self):
        """Test error handling in integration."""
        # Test with invalid inputs
        result = self.ux_integration.process_syntax_fix("", "", {})
        
        self.assertIsNotNone(result)
        self.assertIn("error", result)
    
    def test_shutdown(self):
        """Test graceful shutdown."""
        # This should not raise any exceptions
        self.ux_integration.shutdown()

class TestIntegrationPerformance(unittest.TestCase):
    """Performance tests for the enhanced UX integration."""
    
    def setUp(self):
        """Set up test environment."""
        self.mock_ide = Mock()
        self.mock_syntax_fixer = Mock()
        
        self.ux_integration = EnhancedUXIntegration(
            self.mock_ide,
            self.mock_syntax_fixer
        )
    
    def test_processing_performance(self):
        """Test processing performance with multiple fixes."""
        start_time = time.time()
        
        # Process multiple fixes
        for i in range(10):
            original_code = f"def test_{i}():\n    print('hello {i}')"
            fixed_code = f"def test_{i}():\n    print('hello {i}')\n"
            error_info = {"type": "syntax_error", "line": 2}
            
            self.ux_integration.process_syntax_fix(original_code, fixed_code, error_info)
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        # Should process 10 fixes in reasonable time (less than 5 seconds)
        self.assertLess(processing_time, 5.0)
        
        # Check statistics
        self.assertEqual(self.ux_integration.stats["total_fixes_processed"], 10)
    
    def test_memory_usage(self):
        """Test memory usage doesn't grow excessively."""
        import psutil
        import os
        
        process = psutil.Process(os.getpid())
        initial_memory = process.memory_info().rss
        
        # Process many fixes
        for i in range(100):
            original_code = f"def test_{i}():\n    print('hello {i}')"
            fixed_code = f"def test_{i}():\n    print('hello {i}')\n"
            error_info = {"type": "syntax_error", "line": 2}
            
            self.ux_integration.process_syntax_fix(original_code, fixed_code, error_info)
        
        final_memory = process.memory_info().rss
        memory_increase = final_memory - initial_memory
        
        # Memory increase should be reasonable (less than 50MB)
        self.assertLess(memory_increase, 50 * 1024 * 1024)

def run_tests():
    """Run all tests."""
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add test cases
    test_classes = [
        TestFeedbackCollectionUI,
        TestExplainableAI,
        TestInteractiveFixModifier,
        TestUserExperienceManager,
        TestFeedbackAnalyzer,
        TestEnhancedUXIntegration,
        TestIntegrationPerformance
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        test_suite.addTests(tests)
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Return success status
    return result.wasSuccessful()

if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)

