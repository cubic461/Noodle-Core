#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_db_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Database Test for Phase 2.1
"""

import os
import sys
import tempfile
import shutil

# Add noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.syntax_fixer_learning import create_syntax_fixer_learning_system
from noodlecore.database.database_manager import DatabaseConfig

def test_database():
    print("Testing database functionality...")
    
    # Create temporary directory for test database
    test_dir = tempfile.mkdtemp()
    db_path = os.path.join(test_dir, "test.db")
    
    try:
        # Create database configuration
        db_config = DatabaseConfig(
            database=db_path,
            max_connections=20,
            timeout=30
        )
        
        # Create learning system
        system = create_syntax_fixer_learning_system(db_config)
        
        # Verify database was created
        assert os.path.exists(db_path), "Database file not created"
        
        # Test components
        collector = system['fix_result_collector']
        processor = system['feedback_processor']
        
        # Test data persistence
        from noodlecore.ai_agents.syntax_fixer_learning import FixResult
        fix_result = FixResult(
            fix_id="test-1",
            file_path="/test.nc",
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
        
        # Record user feedback
        feedback_result = processor.process_user_feedback(
            "test-1",
            True,
            "Good fix!",
            {"pattern_type": "semicolon"}
        )
        assert feedback_result['status'] == 'success', "Feedback processing failed"
        
        print("Database test passed!")
        
    finally:
        # Clean up
        if system.get('database_manager'):
            system['database_manager'].close()
        shutil.rmtree(test_dir, ignore_errors=True)

if __name__ == '__main__':
    test_database()

