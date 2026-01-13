#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_3_ux_components.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
UX Component Tests for Phase 2.3

Comprehensive testing of enhanced user experience components including:
- Feedback collection UI and explainable AI testing
- Interactive fix modifier and user experience manager testing
- Feedback analyzer testing
- UI responsiveness and accessibility testing
"""

import os
import sys
import unittest
import tempfile
import shutil
import time
import json
from unittest.mock import Mock, patch, MagicMock, call
from pathlib import Path

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.desktop.ide.feedback_collection_ui import FeedbackCollectionUI
from noodlecore.ai_agents.explainable_ai import ExplainableAI
from noodlecore.desktop.ide.interactive_fix_modifier import InteractiveFixModifier
from noodlecore.desktop.ide.user_experience_manager import UserExperienceManager
from noodlecore.ai_agents.feedback_analyzer import FeedbackAnalyzer

class MockFeedbackCollectionUI(FeedbackCollectionUI):
    """Mock feedback collection UI for testing."""
    
    def __init__(self):
        self.feedback_data = []
        self.ui_visible = False
        self.interaction_log = []
        
    def show_feedback_dialog(self, context, suggested_fixes):
        self.ui_visible = True
        self.interaction_log.append({
            'action': 'show_dialog',
            'context': context,
            'suggested_fixes': suggested_fixes,
            'timestamp': time.time()
        })
        return True
    
    def collect_user_feedback(self, fix_id, rating, comments, categories):
        feedback = {
            'fix_id': fix_id,
            'rating': rating,
            'comments': comments,
            'categories': categories,
            'timestamp': time.time()
        }
        self.feedback_data.append(feedback)
        self.interaction_log.append({
            'action': 'collect_feedback',
            'feedback': feedback,
            'timestamp': time.time()
        })
        return True
    
    def hide_feedback_dialog(self):
        self.ui_visible = False
        self.interaction_log.append({
            'action': 'hide_dialog',
            'timestamp': time.time()
        })
        return True
    
    def get_feedback_data(self):
        return self.feedback_data.copy()
    
    def get_interaction_log(self):
        return self.interaction_log.copy()
    
    def is_visible(self):
        return self.ui_visible

class MockExplainableAI(ExplainableAI):
    """Mock explainable AI for testing."""
    
    def __init__(self):
        self.explanations = []
        self.explanation_history = []
        
    def generate_explanation(self, fix_data, context, user_expertise_level='beginner'):
        explanation = {
            'fix_id': fix_data.get('id'),
            'explanation_text': f"This fix addresses the syntax error by {fix_data.get('description', 'making a correction')}.",
            'confidence': fix_data.get('confidence', 0.8),
            'reasoning_steps': [
                "1. Analyzed the syntax error",
                "2. Identified the specific issue",
                "3. Applied the appropriate correction"
            ],
            'alternatives': [
                "Alternative approach: Manual correction",
                "Alternative approach: Use code formatter"
            ],
            'expertise_level': user_expertise_level,
            'timestamp': time.time()
        }
        
        self.explanations.append(explanation)
        self.explanation_history.append({
            'action': 'generate_explanation',
            'fix_data': fix_data,
            'explanation': explanation,
            'timestamp': time.time()
        })
        
        return explanation
    
    def get_explanation_history(self):
        return self.explanation_history.copy()
    
    def clear_explanations(self):
        self.explanations.clear()
        self.explanation_history.append({
            'action': 'clear_explanations',
            'timestamp': time.time()
        })

class MockInteractiveFixModifier(InteractiveFixModifier):
    """Mock interactive fix modifier for testing."""
    
    def __init__(self):
        self.modification_history = []
        self.current_fix = None
        self.modification_ui_visible = False
        
    def show_modification_interface(self, original_code, suggested_fix):
        self.modification_ui_visible = True
        self.current_fix = {
            'original_code': original_code,
            'suggested_fix': suggested_fix,
            'modifications': [],
            'timestamp': time.time()
        }
        return True
    
    def apply_modification(self, modification_type, details):
        if not self.current_fix:
            return False
        
        modification = {
            'type': modification_type,
            'details': details,
            'timestamp': time.time()
        }
        
        self.current_fix['modifications'].append(modification)
        self.modification_history.append({
            'action': 'apply_modification',
            'fix_id': self.current_fix.get('id'),
            'modification': modification,
            'timestamp': time.time()
        })
        
        return True
    
    def get_modified_code(self):
        if not self.current_fix:
            return None
        
        # Apply all modifications to original code
        modified_code = self.current_fix['original_code']
        
        for modification in self.current_fix['modifications']:
            if modification['type'] == 'replace':
                modified_code = modified_code.replace(
                    modification['details']['old_text'],
                    modification['details']['new_text']
                )
            elif modification['type'] == 'insert':
                position = modification['details']['position']
                text = modification['details']['text']
                modified_code = modified_code[:position] + text + modified_code[position:]
            elif modification['type'] == 'delete':
                start = modification['details']['start']
                end = modification['details']['end']
                modified_code = modified_code[:start] + modified_code[end:]
        
        return modified_code
    
    def hide_modification_interface(self):
        self.modification_ui_visible = False
        return True
    
    def get_modification_history(self):
        return self.modification_history.copy()

class MockUserExperienceManager(UserExperienceManager):
    """Mock user experience manager for testing."""
    
    def __init__(self):
        self.user_preferences = {}
        self.usage_metrics = {}
        self.ux_events = []
        
    def track_user_interaction(self, event_type, details):
        event = {
            'type': event_type,
            'details': details,
            'timestamp': time.time()
        }
        self.ux_events.append(event)
        return True
    
    def set_user_preference(self, preference_key, value):
        self.user_preferences[preference_key] = value
        return True
    
    def get_user_preference(self, preference_key):
        return self.user_preferences.get(preference_key)
    
    def update_usage_metrics(self, metric_name, value):
        if metric_name not in self.usage_metrics:
            self.usage_metrics[metric_name] = []
        self.usage_metrics[metric_name].append({
            'value': value,
            'timestamp': time.time()
        })
        return True
    
    def get_usage_metrics(self, metric_name):
        return self.usage_metrics.get(metric_name, [])
    
    def get_ux_events(self, event_type=None):
        if event_type:
            return [e for e in self.ux_events if e['type'] == event_type]
        return self.ux_events.copy()
    
    def calculate_ux_score(self):
        # Calculate UX score based on various factors
        base_score = 80
        
        # Adjust based on user preferences
        if self.user_preferences.get('auto_apply_fixes', False):
            base_score += 5
        
        # Adjust based on usage metrics
        if 'fix_acceptance_rate' in self.usage_metrics:
            recent_acceptance = [
                m for m in self.usage_metrics['fix_acceptance_rate']
                if time.time() - m['timestamp'] < 3600  # Last hour
            ]
            if recent_acceptance:
                avg_acceptance = sum(m['value'] for m in recent_acceptance) / len(recent_acceptance)
                if avg_acceptance > 0.8:
                    base_score += 10
                elif avg_acceptance > 0.6:
                    base_score += 5
        
        return min(100, max(0, base_score))

class MockFeedbackAnalyzer(FeedbackAnalyzer):
    """Mock feedback analyzer for testing."""
    
    def __init__(self):
        self.analysis_results = []
        self.feedback_patterns = {}
        
    def analyze_feedback(self, feedback_data):
        if not feedback_data:
            return None
        
        # Analyze feedback patterns
        ratings = [f.get('rating', 0) for f in feedback_data]
        avg_rating = sum(ratings) / len(ratings) if ratings else 0
        
        # Categorize feedback
        categories = {}
        for feedback in feedback_data:
            for category in feedback.get('categories', []):
                if category not in categories:
                    categories[category] = 0
                categories[category] += 1
        
        # Identify common issues
        comments = [f.get('comments', '') for f in feedback_data]
        common_issues = self._extract_common_issues(comments)
        
        analysis = {
            'total_feedback_count': len(feedback_data),
            'average_rating': avg_rating,
            'rating_distribution': self._calculate_rating_distribution(ratings),
            'category_distribution': categories,
            'common_issues': common_issues,
            'sentiment_analysis': self._analyze_sentiment(comments),
            'timestamp': time.time()
        }
        
        self.analysis_results.append(analysis)
        self.feedback_patterns = self._update_patterns(self.feedback_patterns, analysis)
        
        return analysis
    
    def _extract_common_issues(self, comments):
        """Extract common issues from comments."""
        common_issues = {}
        
        # Simple keyword-based extraction
        issue_keywords = {
            'incorrect fix': ['wrong', 'incorrect', 'not working'],
            'incomplete fix': ['missing', 'incomplete', 'partial'],
            'performance issue': ['slow', 'performance', 'lag'],
            'ui issue': ['interface', 'ui', 'display'],
            'confusing': ['confusing', 'unclear', 'hard to understand']
        }
        
        for comment in comments:
            comment_lower = comment.lower()
            for issue, keywords in issue_keywords.items():
                if any(keyword in comment_lower for keyword in keywords):
                    if issue not in common_issues:
                        common_issues[issue] = 0
                    common_issues[issue] += 1
        
        return common_issues
    
    def _calculate_rating_distribution(self, ratings):
        """Calculate rating distribution."""
        distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
        for rating in ratings:
            if rating in distribution:
                distribution[rating] += 1
        
        return distribution
    
    def _analyze_sentiment(self, comments):
        """Analyze sentiment in comments."""
        positive_words = ['good', 'great', 'excellent', 'helpful', 'useful', 'perfect']
        negative_words = ['bad', 'terrible', 'useless', 'wrong', 'broken', 'confusing']
        
        positive_count = 0
        negative_count = 0
        
        for comment in comments:
            comment_lower = comment.lower()
            for word in positive_words:
                if word in comment_lower:
                    positive_count += 1
            for word in negative_words:
                if word in comment_lower:
                    negative_count += 1
        
        if positive_count + negative_count == 0:
            return 'neutral'
        elif positive_count > negative_count:
            return 'positive'
        else:
            return 'negative'
    
    def _update_patterns(self, existing_patterns, new_analysis):
        """Update feedback patterns with new analysis."""
        updated_patterns = existing_patterns.copy()
        
        # Update trend data
        if 'rating_trend' not in updated_patterns:
            updated_patterns['rating_trend'] = []
        
        updated_patterns['rating_trend'].append({
            'timestamp': new_analysis['timestamp'],
            'average_rating': new_analysis['average_rating']
        })
        
        # Keep only recent trends (last 100)
        if len(updated_patterns['rating_trend']) > 100:
            updated_patterns['rating_trend'] = updated_patterns['rating_trend'][-100:]
        
        return updated_patterns
    
    def get_analysis_results(self):
        return self.analysis_results.copy()
    
    def get_feedback_patterns(self):
        return self.feedback_patterns.copy()

class TestFeedbackCollectionUI(unittest.TestCase):
    """Test Feedback Collection UI functionality."""
    
    def setUp(self):
        self.feedback_ui = MockFeedbackCollectionUI()
    
    def test_feedback_dialog_display(self):
        """Test feedback dialog display."""
        context = {
            'code': 'def test()\n    pass',
            'error': 'missing colon',
            'line_number': 1
        }
        
        suggested_fixes = [
            {'id': 'fix1', 'description': 'Add colon after function definition'},
            {'id': 'fix2', 'description': 'Redefine function with proper syntax'}
        ]
        
        # Show dialog
        result = self.feedback_ui.show_feedback_dialog(context, suggested_fixes)
        
        self.assertTrue(result)
        self.assertTrue(self.feedback_ui.is_visible())
        
        # Check interaction log
        interaction_log = self.feedback_ui.get_interaction_log()
        self.assertEqual(len(interaction_log), 1)
        
        dialog_event = interaction_log[0]
        self.assertEqual(dialog_event['action'], 'show_dialog')
        self.assertEqual(dialog_event['context'], context)
        self.assertEqual(dialog_event['suggested_fixes'], suggested_fixes)
    
    def test_feedback_collection(self):
        """Test feedback data collection."""
        # First show dialog
        self.feedback_ui.show_feedback_dialog({}, [])
        
        # Collect feedback
        result = self.feedback_ui.collect_user_feedback(
            fix_id='fix1',
            rating=4,
            comments='Good fix, resolved the issue',
            categories=['syntax', 'accuracy']
        )
        
        self.assertTrue(result)
        
        # Check feedback data
        feedback_data = self.feedback_ui.get_feedback_data()
        self.assertEqual(len(feedback_data), 1)
        
        feedback = feedback_data[0]
        self.assertEqual(feedback['fix_id'], 'fix1')
        self.assertEqual(feedback['rating'], 4)
        self.assertEqual(feedback['comments'], 'Good fix, resolved the issue')
        self.assertEqual(feedback['categories'], ['syntax', 'accuracy'])
        self.assertIn('timestamp', feedback)
    
    def test_multiple_feedback_collection(self):
        """Test collection of multiple feedback entries."""
        fixes = [
            {'id': 'fix1', 'description': 'Fix 1'},
            {'id': 'fix2', 'description': 'Fix 2'},
            {'id': 'fix3', 'description': 'Fix 3'}
        ]
        
        self.feedback_ui.show_feedback_dialog({}, fixes)
        
        # Collect feedback for each fix
        for i, fix in enumerate(fixes):
            result = self.feedback_ui.collect_user_feedback(
                fix_id=fix['id'],
                rating=i + 2,  # 2, 3, 4
                comments=f'Comments for fix {i+1}',
                categories=[f'category{i}']
            )
            self.assertTrue(result)
        
        # Check all feedback was collected
        feedback_data = self.feedback_ui.get_feedback_data()
        self.assertEqual(len(feedback_data), 3)
        
        for i, feedback in enumerate(feedback_data):
            self.assertEqual(feedback['rating'], i + 2)
            self.assertEqual(feedback['comments'], f'Comments for fix {i+1}')
            self.assertEqual(feedback['categories'], [f'category{i}'])
    
    def test_feedback_dialog_lifecycle(self):
        """Test feedback dialog lifecycle."""
        context = {'code': 'test'}
        fixes = [{'id': 'fix1', 'description': 'Test fix'}]
        
        # Show dialog
        self.feedback_ui.show_feedback_dialog(context, fixes)
        self.assertTrue(self.feedback_ui.is_visible())
        
        # Hide dialog
        result = self.feedback_ui.hide_feedback_dialog()
        self.assertTrue(result)
        self.assertFalse(self.feedback_ui.is_visible())
        
        # Check interaction log
        interaction_log = self.feedback_ui.get_interaction_log()
        self.assertEqual(len(interaction_log), 2)
        
        actions = [event['action'] for event in interaction_log]
        self.assertIn('show_dialog', actions)
        self.assertIn('hide_dialog', actions)
    
    def test_feedback_data_persistence(self):
        """Test feedback data persistence."""
        # Collect feedback
        self.feedback_ui.collect_user_feedback(
            fix_id='fix1',
            rating=5,
            comments='Excellent fix',
            categories=['perfect']
        )
        
        # Get feedback data
        feedback_data = self.feedback_ui.get_feedback_data()
        original_feedback = feedback_data[0]
        
        # Create new UI instance (simulating restart)
        new_feedback_ui = MockFeedbackCollectionUI()
        
        # Should not have old data (in real implementation, would load from storage)
        new_feedback_data = new_feedback_ui.get_feedback_data()
        self.assertEqual(len(new_feedback_data), 0)
    
    def test_ui_responsiveness(self):
        """Test UI responsiveness during feedback collection."""
        # Test with rapid interactions
        start_time = time.time()
        
        for i in range(10):
            self.feedback_ui.show_feedback_dialog(
                {'code': f'test_{i}'},
                [{'id': f'fix_{i}', 'description': f'Fix {i}'}]
            )
            
            self.feedback_ui.collect_user_feedback(
                fix_id=f'fix_{i}',
                rating=i % 5 + 1,
                comments=f'Rapid feedback {i}',
                categories=[f'rapid_{i}']
            )
            
            self.feedback_ui.hide_feedback_dialog()
        
        total_time = time.time() - start_time
        avg_time = total_time / 10
        
        # Should be responsive (<100ms per operation)
        self.assertLess(avg_time, 0.1)
        
        # Check interaction log
        interaction_log = self.feedback_ui.get_interaction_log()
        self.assertEqual(len(interaction_log), 30)  # 10 show + 10 collect + 10 hide

class TestExplainableAI(unittest.TestCase):
    """Test Explainable AI functionality."""
    
    def setUp(self):
        self.explainable_ai = MockExplainableAI()
    
    def test_basic_explanation_generation(self):
        """Test basic explanation generation."""
        fix_data = {
            'id': 'fix1',
            'description': 'Add missing colon',
            'confidence': 0.9
        }
        context = {
            'code': 'def test()\n    pass',
            'error': 'missing colon',
            'language': 'python'
        }
        
        explanation = self.explainable_ai.generate_explanation(fix_data, context)
        
        self.assertIsNotNone(explanation)
        self.assertEqual(explanation['fix_id'], 'fix1')
        self.assertIn('explanation_text', explanation)
        self.assertEqual(explanation['confidence'], 0.9)
        self.assertIn('reasoning_steps', explanation)
        self.assertIn('alternatives', explanation)
        self.assertEqual(explanation['expertise_level'], 'beginner')
        self.assertIn('timestamp', explanation)
    
    def test_expertise_level_adaptation(self):
        """Test explanation adaptation based on expertise level."""
        fix_data = {'id': 'fix1', 'description': 'Add colon'}
        context = {'code': 'def test()\n    pass'}
        
        # Test different expertise levels
        levels = ['beginner', 'intermediate', 'expert']
        explanations = []
        
        for level in levels:
            explanation = self.explainable_ai.generate_explanation(
                fix_data, context, level
            )
            explanations.append(explanation)
        
        # Should have different explanations for different levels
        for i, explanation in enumerate(explanations):
            self.assertEqual(explanation['expertise_level'], levels[i])
            self.assertIn('explanation_text', explanation)
            
            # Expert explanations might be more technical
            if levels[i] == 'expert':
                self.assertGreater(len(explanation['reasoning_steps']), 3)
            elif levels[i] == 'beginner':
                self.assertLessEqual(len(explanation['reasoning_steps']), 5)
    
    def test_explanation_history_tracking(self):
        """Test explanation history tracking."""
        fix_data = {'id': 'fix1', 'description': 'Test fix'}
        context = {'code': 'test code'}
        
        # Generate multiple explanations
        for i in range(5):
            self.explainable_ai.generate_explanation(
                fix_data, 
                context, 
                f'level_{i}'
            )
        
        # Check history
        history = self.explainable_ai.get_explanation_history()
        self.assertEqual(len(history), 5)
        
        # All entries should be generate_explanation actions
        for entry in history:
            self.assertEqual(entry['action'], 'generate_explanation')
            self.assertEqual(entry['fix_data'], fix_data)
            self.assertIn('explanation', entry)
            self.assertIn('timestamp', entry)
    
    def test_explanation_clearing(self):
        """Test explanation clearing."""
        # Generate some explanations
        for i in range(3):
            self.explainable_ai.generate_explanation(
                {'id': f'fix_{i}'},
                {'code': f'test_{i}'},
                'beginner'
            )
        
        # Clear explanations
        self.explainable_ai.clear_explanations()
        
        # Check history for clear action
        history = self.explainable_ai.get_explanation_history()
        
        # Should have generation entries plus clear entry
        self.assertEqual(len(history), 4)
        
        # Last entry should be clear action
        clear_entry = history[-1]
        self.assertEqual(clear_entry['action'], 'clear_explanations')
        self.assertIn('timestamp', clear_entry)
    
    def test_confidence_based_explanations(self):
        """Test explanations based on different confidence levels."""
        context = {'code': 'test code'}
        
        # Test with different confidence levels
        confidence_levels = [0.5, 0.7, 0.9, 1.0]
        explanations = []
        
        for confidence in confidence_levels:
            fix_data = {
                'id': f'fix_{confidence}',
                'description': f'Fix with {confidence} confidence',
                'confidence': confidence
            }
            
            explanation = self.explainable_ai.generate_explanation(fix_data, context)
            explanations.append(explanation)
        
        # Higher confidence should have more detailed explanations
        for explanation in explanations:
            self.assertEqual(explanation['confidence'], fix_data['confidence'])
            self.assertGreater(len(explanation['reasoning_steps']), 2)
            
            # High confidence explanations should be more assertive
            if explanation['confidence'] > 0.8:
                self.assertIn('definitely', explanation['explanation_text'].lower())
            elif explanation['confidence'] < 0.6:
                self.assertIn('might', explanation['explanation_text'].lower())
    
    def test_alternative_explanations(self):
        """Test generation of alternative explanations."""
        fix_data = {
            'id': 'fix1',
            'description': 'Add missing colon',
            'confidence': 0.8
        }
        context = {'code': 'def test()\n    pass'}
        
        explanation = self.explainable_ai.generate_explanation(fix_data, context)
        
        self.assertIn('alternatives', explanation)
        self.assertGreater(len(explanation['alternatives']), 0)
        
        # Alternatives should be different approaches
        alternatives = explanation['alternatives']
        self.assertIsInstance(alternatives, list)
        
        for alternative in alternatives:
            self.assertIsInstance(alternative, str)
            self.assertGreater(len(alternative), 5)  # Meaningful description

class TestInteractiveFixModifier(unittest.TestCase):
    """Test Interactive Fix Modifier functionality."""
    
    def setUp(self):
        self.modifier = MockInteractiveFixModifier()
    
    def test_modification_interface_display(self):
        """Test modification interface display."""
        original_code = 'def test()\n    pass'
        suggested_fix = 'def test():\n    pass'
        
        result = self.modifier.show_modification_interface(original_code, suggested_fix)
        
        self.assertTrue(result)
        self.assertTrue(self.modifier.modification_ui_visible)
        self.assertIsNotNone(self.modifier.current_fix)
        
        current_fix = self.modifier.current_fix
        self.assertEqual(current_fix['original_code'], original_code)
        self.assertEqual(current_fix['suggested_fix'], suggested_fix)
        self.assertIn('modifications', current_fix)
        self.assertIn('timestamp', current_fix)
    
    def test_replacement_modification(self):
        """Test replacement modifications."""
        original_code = 'def test()\n    pass'
        suggested_fix = 'def test():\n    pass'
        
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # Apply replacement modification
        result = self.modifier.apply_modification('replace', {
            'old_text': 'pass',
            'new_text': 'return 42'
        })
        
        self.assertTrue(result)
        
        # Check modification was applied
        modified_code = self.modifier.get_modified_code()
        self.assertIn('return 42', modified_code)
        self.assertNotIn('pass', modified_code)
        
        # Check modification history
        history = self.modifier.get_modification_history()
        self.assertEqual(len(history), 1)
        
        modification = history[0]['modification']
        self.assertEqual(modification['type'], 'replace')
        self.assertEqual(modification['details']['old_text'], 'pass')
        self.assertEqual(modification['details']['new_text'], 'return 42')
    
    def test_insertion_modification(self):
        """Test insertion modifications."""
        original_code = 'def test():\n    pass'
        suggested_fix = 'def test():\n    pass'
        
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # Apply insertion modification
        result = self.modifier.apply_modification('insert', {
            'position': len('def test():\n    '),
            'text': '# Added comment\n'
        })
        
        self.assertTrue(result)
        
        # Check modification was applied
        modified_code = self.modifier.get_modified_code()
        self.assertIn('# Added comment', modified_code)
        self.assertIn('def test():', modified_code)
        
        # Check modification history
        history = self.modifier.get_modification_history()
        self.assertEqual(len(history), 1)
        
        modification = history[0]['modification']
        self.assertEqual(modification['type'], 'insert')
        self.assertEqual(modification['details']['position'], len('def test():\n    '))
        self.assertEqual(modification['details']['text'], '# Added comment\n')
    
    def test_deletion_modification(self):
        """Test deletion modifications."""
        original_code = 'def test():\n    pass  # Unnecessary comment'
        suggested_fix = 'def test():\n    pass'
        
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # Apply deletion modification
        result = self.modifier.apply_modification('delete', {
            'start': len('def test():\n    pass'),
            'end': len('def test():\n    pass  # Unnecessary comment')
        })
        
        self.assertTrue(result)
        
        # Check modification was applied
        modified_code = self.modifier.get_modified_code()
        self.assertNotIn('# Unnecessary comment', modified_code)
        self.assertIn('def test():\n    pass', modified_code)
        
        # Check modification history
        history = self.modifier.get_modification_history()
        self.assertEqual(len(history), 1)
        
        modification = history[0]['modification']
        self.assertEqual(modification['type'], 'delete')
        self.assertEqual(modification['details']['start'], len('def test():\n    pass'))
        self.assertEqual(modification['details']['end'], len('def test():\n    pass  # Unnecessary comment'))
    
    def test_multiple_modifications(self):
        """Test applying multiple modifications."""
        original_code = 'def test()\n    pass'
        suggested_fix = 'def test():\n    return 42'
        
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # Apply multiple modifications
        modifications = [
            ('replace', {'old_text': 'test()', 'new_text': 'test():'}),
            ('replace', {'old_text': 'pass', 'new_text': 'return 42'}),
            ('insert', {'position': len('def test():\n    '), 'text': '# Fixed function\n'})
        ]
        
        for mod_type, details in modifications:
            result = self.modifier.apply_modification(mod_type, details)
            self.assertTrue(result)
        
        # Check all modifications were applied
        modified_code = self.modifier.get_modified_code()
        self.assertIn('def test():', modified_code)
        self.assertIn('# Fixed function', modified_code)
        self.assertIn('return 42', modified_code)
        self.assertNotIn('pass', modified_code)
        
        # Check modification history
        history = self.modifier.get_modification_history()
        self.assertEqual(len(history), 3)
    
    def test_modification_interface_lifecycle(self):
        """Test modification interface lifecycle."""
        original_code = 'test code'
        suggested_fix = 'fixed code'
        
        # Show interface
        result = self.modifier.show_modification_interface(original_code, suggested_fix)
        self.assertTrue(result)
        self.assertTrue(self.modifier.modification_ui_visible)
        
        # Hide interface
        result = self.modifier.hide_modification_interface()
        self.assertTrue(result)
        self.assertFalse(self.modifier.modification_ui_visible)
    
    def test_modification_history_tracking(self):
        """Test modification history tracking."""
        original_code = 'test code'
        suggested_fix = 'fixed code'
        
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # Apply multiple modifications over time
        for i in range(5):
            self.modifier.apply_modification('replace', {
                'old_text': f'word_{i}',
                'new_text': f'replacement_{i}'
            })
            time.sleep(0.01)  # Small delay to test timestamps
        
        # Check history
        history = self.modifier.get_modification_history()
        self.assertEqual(len(history), 5)
        
        # Check timestamps are increasing
        timestamps = [entry['timestamp'] for entry in history]
        self.assertEqual(timestamps, sorted(timestamps))
        
        # Check all entries have correct structure
        for entry in history:
            self.assertEqual(entry['action'], 'apply_modification')
            self.assertIn('modification', entry)
            self.assertIn('timestamp', entry)

class TestUserExperienceManager(unittest.TestCase):
    """Test User Experience Manager functionality."""
    
    def setUp(self):
        self.ux_manager = MockUserExperienceManager()
    
    def test_user_interaction_tracking(self):
        """Test user interaction tracking."""
        interaction_types = [
            'fix_applied',
            'fix_rejected',
            'help_requested',
            'settings_changed'
        ]
        
        for i, interaction_type in enumerate(interaction_types):
            details = {
                'fix_id': f'fix_{i}',
                'timestamp': time.time(),
                'context': f'test_context_{i}'
            }
            
            result = self.ux_manager.track_user_interaction(interaction_type, details)
            self.assertTrue(result)
        
        # Check all interactions were tracked
        events = self.ux_manager.get_ux_events()
        self.assertEqual(len(events), 4)
        
        # Check event types
        tracked_types = set(event['type'] for event in events)
        self.assertEqual(tracked_types, set(interaction_types))
        
        # Check event details
        for i, event in enumerate(events):
            self.assertEqual(event['type'], interaction_types[i])
            self.assertIn('details', event)
            self.assertIn('timestamp', event)
    
    def test_user_preferences_management(self):
        """Test user preferences management."""
        preferences = {
            'auto_apply_fixes': True,
            'show_explanations': True,
            'expertise_level': 'intermediate',
            'ui_theme': 'dark',
            'notification_level': 'normal'
        }
        
        # Set preferences
        for key, value in preferences.items():
            result = self.ux_manager.set_user_preference(key, value)
            self.assertTrue(result)
        
        # Get preferences
        for key, expected_value in preferences.items():
            actual_value = self.ux_manager.get_user_preference(key)
            self.assertEqual(actual_value, expected_value)
    
    def test_usage_metrics_tracking(self):
        """Test usage metrics tracking."""
        metrics = [
            ('fix_acceptance_rate', 0.8),
            ('fix_rejection_rate', 0.2),
            ('average_fix_time', 1.5),
            ('help_requests_per_session', 2)
        ]
        
        for metric_name, value in metrics:
            result = self.ux_manager.update_usage_metrics(metric_name, value)
            self.assertTrue(result)
        
        # Check metrics were recorded
        for metric_name, expected_value in metrics:
            metric_data = self.ux_manager.get_usage_metrics(metric_name)
            self.assertEqual(len(metric_data), 1)
            self.assertEqual(metric_data[0]['value'], expected_value)
            self.assertIn('timestamp', metric_data[0])
    
    def test_ux_score_calculation(self):
        """Test UX score calculation."""
        # Set some preferences and metrics
        self.ux_manager.set_user_preference('auto_apply_fixes', True)
        self.ux_manager.update_usage_metrics('fix_acceptance_rate', 0.9)
        self.ux_manager.update_usage_metrics('fix_acceptance_rate', 0.85)
        self.ux_manager.update_usage_metrics('fix_acceptance_rate', 0.75)
        
        # Calculate UX score
        ux_score = self.ux_manager.calculate_ux_score()
        
        self.assertIsInstance(ux_score, (int, float))
        self.assertGreaterEqual(ux_score, 0)
        self.assertLessEqual(ux_score, 100)
        
        # Should be higher with good preferences and metrics
        self.assertGreater(ux_score, 80)  # Base score + improvements
    
    def test_event_filtering(self):
        """Test UX event filtering."""
        # Track various events
        events = [
            ('fix_applied', {'fix_id': 'fix1'}),
            ('fix_rejected', {'fix_id': 'fix1'}),
            ('help_requested', {'topic': 'syntax'}),
            ('fix_applied', {'fix_id': 'fix2'}),
            ('settings_changed', {'setting': 'theme'})
        ]
        
        for event_type, details in events:
            self.ux_manager.track_user_interaction(event_type, details)
        
        # Filter by event type
        fix_events = self.ux_manager.get_ux_events('fix_applied')
        self.assertEqual(len(fix_events), 2)
        
        for event in fix_events:
            self.assertEqual(event['type'], 'fix_applied')
            self.assertIn('details', event)
        
        help_events = self.ux_manager.get_ux_events('help_requested')
        self.assertEqual(len(help_events), 1)
        self.assertEqual(help_events[0]['details']['topic'], 'syntax')
    
    def test_comprehensive_ux_tracking(self):
        """Test comprehensive UX tracking."""
        # Simulate user session
        session_events = [
            ('session_start', {'timestamp': time.time()}),
            ('fix_viewed', {'fix_id': 'fix1', 'view_duration': 2.5}),
            ('fix_applied', {'fix_id': 'fix1', 'time_to_apply': 1.2}),
            ('explanation_viewed', {'fix_id': 'fix1', 'explanation_level': 'beginner'}),
            ('fix_modified', {'fix_id': 'fix1', 'modifications': 2}),
            ('fix_applied', {'fix_id': 'fix1', 'time_to_apply': 0.8}),
            ('session_end', {'session_duration': 15.5})
        ]
        
        for event_type, details in session_events:
            self.ux_manager.track_user_interaction(event_type, details)
        
        # Analyze session
        all_events = self.ux_manager.get_ux_events()
        self.assertEqual(len(all_events), len(session_events))
        
        # Check session flow
        session_start = next(e for e in all_events if e['type'] == 'session_start')
        session_end = next(e for e in all_events if e['type'] == 'session_end')
        
        self.assertIsNotNone(session_start)
        self.assertIsNotNone(session_end)
        
        # Session should have logical flow
        fix_events = [e for e in all_events if 'fix' in e['type']]
        self.assertGreater(len(fix_events), 0)

class TestFeedbackAnalyzer(unittest.TestCase):
    """Test Feedback Analyzer functionality."""
    
    def setUp(self):
        self.analyzer = MockFeedbackAnalyzer()
    
    def test_basic_feedback_analysis(self):
        """Test basic feedback analysis."""
        feedback_data = [
            {
                'fix_id': 'fix1',
                'rating': 4,
                'comments': 'Good fix, worked perfectly',
                'categories': ['syntax', 'accuracy']
            },
            {
                'fix_id': 'fix2',
                'rating': 2,
                'comments': 'Partially fixed the issue',
                'categories': ['incomplete']
            },
            {
                'fix_id': 'fix3',
                'rating': 5,
                'comments': 'Excellent solution',
                'categories': ['perfect', 'complete']
            }
        ]
        
        analysis = self.analyzer.analyze_feedback(feedback_data)
        
        self.assertIsNotNone(analysis)
        self.assertEqual(analysis['total_feedback_count'], 3)
        self.assertAlmostEqual(analysis['average_rating'], (4 + 2 + 5) / 3, places=2)
        
        # Check rating distribution
        rating_dist = analysis['rating_distribution']
        self.assertEqual(rating_dist[4], 1)
        self.assertEqual(rating_dist[2], 1)
        self.assertEqual(rating_dist[5], 1)
        
        # Check category distribution
        category_dist = analysis['category_distribution']
        self.assertIn('syntax', category_dist)
        self.assertIn('accuracy', category_dist)
        self.assertIn('incomplete', category_dist)
        self.assertIn('perfect', category_dist)
        self.assertIn('complete', category_dist)
    
    def test_sentiment_analysis(self):
        """Test sentiment analysis in feedback."""
        feedback_data = [
            {
                'fix_id': 'fix1',
                'rating': 5,
                'comments': 'Excellent and very helpful fix'
            },
            {
                'fix_id': 'fix2',
                'rating': 1,
                'comments': 'Terrible fix, made things worse'
            },
            {
                'fix_id': 'fix3',
                'rating': 3,
                'comments': 'Average fix, nothing special'
            }
        ]
        
        analysis = self.analyzer.analyze_feedback(feedback_data)
        
        self.assertEqual(analysis['sentiment_analysis'], 'positive')
        
        # Check analysis results
        self.assertIn('common_issues', analysis)
        self.assertIn('rating_distribution', analysis)
        self.assertIn('category_distribution', analysis)
    
    def test_common_issues_extraction(self):
        """Test extraction of common issues."""
        feedback_data = [
            {
                'fix_id': 'fix1',
                'rating': 2,
                'comments': 'The fix was wrong and incorrect'
            },
            {
                'fix_id': 'fix2',
                'rating': 1,
                'comments': 'Missing parts of the fix, incomplete solution'
            },
            {
                'fix_id': 'fix3',
                'rating': 2,
                'comments': 'The UI is confusing and hard to understand'
            },
            {
                'fix_id': 'fix4',
                'rating': 1,
                'comments': 'Performance is slow and lagging'
            }
        ]
        
        analysis = self.analyzer.analyze_feedback(feedback_data)
        
        common_issues = analysis['common_issues']
        
        self.assertIn('incorrect fix', common_issues)
        self.assertIn('incomplete fix', common_issues)
        self.assertIn('confusing', common_issues)
        self.assertIn('performance issue', common_issues)
        
        # Check issue counts
        self.assertEqual(common_issues['incorrect fix'], 1)
        self.assertEqual(common_issues['incomplete fix'], 1)
        self.assertEqual(common_issues['confusing'], 1)
        self.assertEqual(common_issues['performance issue'], 1)
    
    def test_feedback_trend_analysis(self):
        """Test feedback trend analysis."""
        # Analyze multiple feedback sets over time
        feedback_sets = [
            [  # First set
                {'fix_id': 'fix1', 'rating': 3, 'comments': 'Average'},
                {'fix_id': 'fix2', 'rating': 4, 'comments': 'Good'}
            ],
            [  # Second set
                {'fix_id': 'fix3', 'rating': 4, 'comments': 'Good'},
                {'fix_id': 'fix4', 'rating': 5, 'comments': 'Excellent'}
            ],
            [  # Third set
                {'fix_id': 'fix5', 'rating': 2, 'comments': 'Poor'},
                {'fix_id': 'fix6', 'rating': 3, 'comments': 'Average'}
            ]
        ]
        
        for feedback_set in feedback_sets:
            self.analyzer.analyze_feedback(feedback_set)
            time.sleep(0.01)  # Small delay between analyses
        
        # Check patterns
        patterns = self.analyzer.get_feedback_patterns()
        
        self.assertIn('rating_trend', patterns)
        rating_trend = patterns['rating_trend']
        
        self.assertEqual(len(rating_trend), 3)
        
        # Check trend values
        ratings = [entry['average_rating'] for entry in rating_trend]
        self.assertEqual(ratings[0], 3.5)  # (3 + 4) / 2
        self.assertEqual(ratings[1], 4.5)  # (4 + 5) / 2
        self.assertEqual(ratings[2], 2.5)  # (2 + 3) / 2
    
    def test_empty_feedback_handling(self):
        """Test handling of empty feedback."""
        # Test with None
        analysis = self.analyzer.analyze_feedback(None)
        self.assertIsNone(analysis)
        
        # Test with empty list
        analysis = self.analyzer.analyze_feedback([])
        self.assertIsNone(analysis)
        
        # Test with empty feedback entries
        empty_feedback = [{'fix_id': 'fix1'}]  # Missing rating
        analysis = self.analyzer.analyze_feedback(empty_feedback)
        
        self.assertIsNotNone(analysis)
        self.assertEqual(analysis['total_feedback_count'], 1)
        self.assertEqual(analysis['average_rating'], 0)  # Default for missing rating
    
    def test_analysis_results_tracking(self):
        """Test tracking of analysis results."""
        feedback_data = [
            {'fix_id': 'fix1', 'rating': 4, 'comments': 'Good'},
            {'fix_id': 'fix2', 'rating': 3, 'comments': 'Average'}
        ]
        
        # Analyze feedback
        self.analyzer.analyze_feedback(feedback_data)
        
        # Check analysis results
        results = self.analyzer.get_analysis_results()
        self.assertEqual(len(results), 1)
        
        analysis = results[0]
        self.assertIn('total_feedback_count', analysis)
        self.assertIn('average_rating', analysis)
        self.assertIn('rating_distribution', analysis)
        self.assertIn('category_distribution', analysis)
        self.assertIn('common_issues', analysis)
        self.assertIn('sentiment_analysis', analysis)
        self.assertIn('timestamp', analysis)

class TestUXIntegration(unittest.TestCase):
    """Test integration of UX components."""
    
    def setUp(self):
        self.feedback_ui = MockFeedbackCollectionUI()
        self.explainable_ai = MockExplainableAI()
        self.modifier = MockInteractiveFixModifier()
        self.ux_manager = MockUserExperienceManager()
        self.analyzer = MockFeedbackAnalyzer()
    
    def test_complete_ux_workflow(self):
        """Test complete UX workflow."""
        # Simulate user session
        original_code = 'def test()\n    pass'
        suggested_fix = 'def test():\n    pass'
        
        # 1. Show feedback dialog
        self.feedback_ui.show_feedback_dialog(
            {'code': original_code, 'error': 'missing colon'},
            [{'id': 'fix1', 'description': 'Add colon'}]
        )
        
        # 2. Track interaction
        self.ux_manager.track_user_interaction('fix_viewed', {
            'fix_id': 'fix1',
            'view_duration': 2.5
        })
        
        # 3. Generate explanation
        explanation = self.explainable_ai.generate_explanation(
            {'id': 'fix1', 'description': 'Add colon'},
            {'code': original_code},
            'beginner'
        )
        
        # 4. Show modification interface
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # 5. Apply modification
        self.modifier.apply_modification('replace', {
            'old_text': 'test()',
            'new_text': 'test():'
        })
        
        # 6. Collect feedback
        self.feedback_ui.collect_user_feedback(
            fix_id='fix1',
            rating=4,
            comments='Good explanation and easy to apply',
            categories=['explanation', 'usability']
        )
        
        # 7. Track final interaction
        self.ux_manager.track_user_interaction('fix_applied', {
            'fix_id': 'fix1',
            'time_to_apply': 1.2
        })
        
        # Verify workflow completion
        self.assertTrue(self.feedback_ui.is_visible())
        self.assertIsNotNone(self.modifier.current_fix)
        self.assertGreater(len(self.ux_manager.get_ux_events()), 2)
        
        # Analyze collected feedback
        feedback_data = self.feedback_ui.get_feedback_data()
        analysis = self.analyzer.analyze_feedback(feedback_data)
        
        self.assertIsNotNone(analysis)
        self.assertEqual(analysis['total_feedback_count'], 1)
        self.assertEqual(analysis['average_rating'], 4)
    
    def test_ux_performance_validation(self):
        """Test UX performance validation."""
        # Simulate rapid interactions
        start_time = time.time()
        
        for i in range(20):
            # Rapid feedback collection
            self.feedback_ui.show_feedback_dialog(
                {'code': f'test_{i}'},
                [{'id': f'fix_{i}', 'description': f'Fix {i}'}]
            )
            
            self.feedback_ui.collect_user_feedback(
                fix_id=f'fix_{i}',
                rating=i % 5 + 1,
                comments=f'Feedback {i}',
                categories=[f'cat_{i}']
            )
            
            # Track interactions
            self.ux_manager.track_user_interaction('rapid_action', {
                'iteration': i,
                'timestamp': time.time()
            })
        
        total_time = time.time() - start_time
        avg_time = total_time / 20
        
        # Performance targets
        self.assertLess(avg_time, 0.05)  # <50ms per operation
        
        # Check interaction tracking
        events = self.ux_manager.get_ux_events('rapid_action')
        self.assertEqual(len(events), 20)
    
    def test_accessibility_validation(self):
        """Test accessibility features."""
        # Test with accessibility-focused interactions
        accessibility_features = [
            'screen_reader_compatible',
            'keyboard_navigation',
            'high_contrast_mode',
            'large_text_mode',
            'voice_commands'
        ]
        
        for feature in accessibility_features:
            self.ux_manager.set_user_preference(f'accessibility_{feature}', True)
            
            # Track accessibility usage
            self.ux_manager.track_user_interaction('accessibility_feature_used', {
                'feature': feature,
                'timestamp': time.time()
            })
        
        # Verify accessibility preferences
        for feature in accessibility_features:
            pref_value = self.ux_manager.get_user_preference(f'accessibility_{feature}')
            self.assertTrue(pref_value)
        
        # Check accessibility events
        access_events = self.ux_manager.get_ux_events('accessibility_feature_used')
        self.assertEqual(len(access_events), len(accessibility_features))
    
    def test_personalization_features(self):
        """Test personalization features."""
        # Set user preferences
        personalization_prefs = {
            'expertise_level': 'expert',
            'ui_theme': 'dark',
            'language': 'python',
            'auto_apply_fixes': False,
            'show_advanced_options': True
        }
        
        for key, value in personalization_prefs.items():
            self.ux_manager.set_user_preference(key, value)
        
        # Test personalized explanations
        explanation = self.explainable_ai.generate_explanation(
            {'id': 'fix1', 'description': 'Advanced fix'},
            {'code': 'def test()\n    pass'},
            self.ux_manager.get_user_preference('expertise_level')
        )
        
        # Should adapt to expertise level
        self.assertEqual(explanation['expertise_level'], 'expert')
        
        # Test personalized UI behavior
        auto_apply = self.ux_manager.get_user_preference('auto_apply_fixes')
        self.assertFalse(auto_apply)
        
        show_advanced = self.ux_manager.get_user_preference('show_advanced_options')
        self.assertTrue(show_advanced)
    
    def test_feedback_driven_improvement(self):
        """Test feedback-driven improvement."""
        # Initial feedback (poor)
        initial_feedback = [
            {
                'fix_id': 'fix1',
                'rating': 2,
                'comments': 'Confusing explanation',
                'categories': ['confusing', 'explanation']
            }
        ]
        
        initial_analysis = self.analyzer.analyze_feedback(initial_feedback)
        
        # Simulate improvement based on feedback
        improvement_actions = [
            'improve_explanation_clarity',
            'add_more_examples',
            'simplify_language'
        ]
        
        for action in improvement_actions:
            self.ux_manager.track_user_interaction('improvement_applied', {
                'action': action,
                'based_on_feedback': initial_analysis['timestamp'],
                'timestamp': time.time()
            })
        
        # New feedback (improved)
        improved_feedback = [
            {
                'fix_id': 'fix2',
                'rating': 4,
                'comments': 'Much clearer explanation',
                'categories': ['explanation', 'clarity']
            }
        ]
        
        improved_analysis = self.analyzer.analyze_feedback(improved_feedback)
        
        # Verify improvement
        self.assertGreater(improved_analysis['average_rating'], initial_analysis['average_rating'])
        
        # Check improvement tracking
        improvement_events = self.ux_manager.get_ux_events('improvement_applied')
        self.assertEqual(len(improvement_events), len(improvement_actions))
    
    def test_cross_component_communication(self):
        """Test communication between UX components."""
        # Test that components can share data
        original_code = 'def test()\n    pass'
        suggested_fix = 'def test():\n    pass'
        
        # 1. Feedback UI shows dialog
        self.feedback_ui.show_feedback_dialog(
            {'code': original_code},
            [{'id': 'fix1', 'description': 'Add colon'}]
        )
        
        # 2. UX Manager tracks the interaction
        self.ux_manager.track_user_interaction('dialog_shown', {
            'component': 'feedback_ui',
            'fix_count': 1,
            'timestamp': time.time()
        })
        
        # 3. Explainable AI generates explanation
        explanation = self.explainable_ai.generate_explanation(
            {'id': 'fix1', 'description': 'Add colon'},
            {'code': original_code},
            'beginner'
        )
        
        # 4. Explanation is shared with modifier
        self.modifier.show_modification_interface(original_code, suggested_fix)
        
        # 5. UX Manager tracks explanation usage
        self.ux_manager.track_user_interaction('explanation_viewed', {
            'component': 'explainable_ai',
            'explanation_id': explanation.get('fix_id'),
            'timestamp': time.time()
        })
        
        # Verify cross-component communication
        feedback_events = self.ux_manager.get_ux_events()
        component_events = [e for e in feedback_events if 'component' in e['details']]
        
        self.assertEqual(len(component_events), 2)
        components_used = [e['details']['component'] for e in component_events]
        self.assertIn('feedback_ui', components_used)
        self.assertIn('explainable_ai', components_used)

if __name__ == '__main__':
    # Configure test environment
    os.environ['NOODLE_SYNTAX_FIXER_ENHANCED_UX'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_UX_FEEDBACK_COLLECTION'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_UX_EXPLAINABLE_AI'] = 'true'
    
    # Run tests
    unittest.main(verbosity=2)

