#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_integration_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Integration Test for Phase 2.1
"""

import os
import sys

# Add noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_basic_integration():
    """Test basic integration functionality."""
    print("Testing basic integration...")
    
    try:
        # Test importing components
        from noodlecore.ai_agents.syntax_fixer_learning import (
            FixResultCollector, PatternAnalyzer, LearningEngine, 
            FeedbackProcessor, create_syntax_fixer_learning_system
        )
        
        # Test creating learning system
        learning_system = create_syntax_fixer_learning_system()
        
        # Verify components were created
        assert 'fix_result_collector' in learning_system, "FixResultCollector not created"
        assert 'pattern_analyzer' in learning_system, "PatternAnalyzer not created"
        assert 'learning_engine' in learning_system, "LearningEngine not created"
        assert 'feedback_processor' in learning_system, "FeedbackProcessor not created"
        
        print("PASSED Basic integration test!")
        return True
        
    except Exception as e:
        print(f"âœ— Basic integration test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run simple integration tests."""
    print("Running Phase 2.1 Simple Integration Tests")
    print("=" * 50)
    
    try:
        success = test_basic_integration()
        
        print("\n" + "=" * 50)
        if success:
            print("All simple integration tests passed successfully!")
        else:
            print("Some simple integration tests failed!")
        
        return success
        
    except Exception as e:
        print(f"Test execution failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

