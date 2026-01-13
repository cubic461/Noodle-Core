#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_1_database.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Database Schema and Persistence Tests for Phase 2.1 Implementation
"""

import os
import sys
import tempfile
import shutil
import sqlite3
from datetime import datetime, timedelta

# Add noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.syntax_fixer_learning import create_syntax_fixer_learning_system
from noodlecore.database.database_manager import DatabaseConfig

def test_database_schema():
    """Test database schema creation and persistence."""
    print("Testing database schema...")
    
    # Create temporary directory for test database
    test_dir = tempfile.mkdtemp()
    db_path = os.path.join(test_dir, "test_phase2_1.db")
    
    try:
        # Create database configuration
        db_config = DatabaseConfig(
            database_path=db_path,
            database_type="sqlite",
            max_connections=20,
            connection_timeout=30
        )
        
        # Create learning system with database
        system = create_syntax_fixer_learning_system(db_config)
        
        # Verify database was created
        assert os.path.exists(db_path), "Database file not created"
        
        # Verify tables were created
        collector = system['fix_result_collector']
        analyzer = system['pattern_analyzer']
        engine = system['learning_engine']
        processor = system['feedback_processor']
        
        # Test database connection
        if system.get('database_manager'):
            db_manager = system['database_manager']
            
            # Test that tables exist
            assert db_manager.table_exists('syntax_fix_results'), "syntax_fix_results table not created"
            assert db_manager.table_exists('syntax_pattern_matches'), "syntax_pattern_matches table not created"
            assert db_manager.table_exists('syntax_learning_patterns'), "syntax_learning_patterns table not created"
            
            # Test data persistence
            # Create a test fix result
            from noodlecore.ai_agents.syntax_fixer_learning import FixResult
            fix_result = FixResult(
                fix_id="db-test-1",
                file_path="/test/db_test.nc",
                original_content="let x = 5",
                fixed_content="let x = 5;",
                fixes_applied=[{"type": "semicolon", "line": 1}],
                confidence_score=0.9,
                fix_time=0.1,
                user_accepted=True
            )
            
            # Collect the fix result
            collect_result = collector.collect_fix_result(fix_result)
            assert collect_result == True, "Failed to collect fix result"
            
            # Record user feedback
            feedback_result = processor.process_user_feedback(
                "db-test-1",
                True,
                "Great fix!",
                {"pattern_type": "semicolon", "file_type": "test"}
            )
            assert feedback_result['status'] == 'success', "Failed to process feedback"
            
            # Verify data was persisted
            # Get fix results from database
            results = collector.get_fix_results(limit=10)
            assert len(results) > 0, "No fix results found in database"
            
            # Verify our test result is in the results
            found = False
            for result in results:
                if result.fix_id == "db-test-1":
                    found = True
                    assert result.user_accepted == True, "User acceptance not persisted"
                    assert result.user_feedback == "Great fix!", "User feedback not persisted"
                    break
            
            assert found, "Test fix result not found in database"
            
            # Test pattern analysis
            analysis = analyzer.analyze_fix_results_patterns(results)
            assert 'total_results' in analysis, "Missing total_results in analysis"
            assert 'success_rates' in analysis, "Missing success_rates in analysis"
            
            # Test learning
            learning_result = engine.learn_from_fix_results(results)
            assert learning_result['status'] == 'success', "Learning failed"
            
            # Test feedback summary
            summary = processor.get_feedback_summary()
            assert 'total_feedback' in summary, "Missing total_feedback in summary"
            
            print("Database schema tests passed")
            
        finally:
            # Clean up
            if system.get('database_manager'):
                system['database_manager'].close()
            shutil.rmtree(test_dir, ignore_errors=True)

def test_data_persistence():
    """Test data persistence across restarts."""
    print("Testing data persistence...")
    
    # Create temporary directory for test database
    test_dir = tempfile.mkdtemp()
    db_path = os.path.join(test_dir, "test_persistence.db")
    
    try:
        # Create database configuration
        db_config = DatabaseConfig(
            database_path=db_path,
            database_type="sqlite",
            max_connections=20,
            connection_timeout=30
        )
        
        # Create learning system and add test data
        system1 = create_syntax_fixer_learning_system(db_config)
        
        # Add test fix result
        from noodlecore.ai_agents.syntax_fixer_learning import FixResult
        fix_result = FixResult(
                fix_id="persistence-test-1",
                file_path="/test/persistence_test.nc",
                original_content="let x = 5",
                fixed_content="let x = 5;",
                fixes_applied=[{"type": "semicolon", "line": 1}],
                confidence_score=0.9,
                fix_time=0.1,
                user_accepted=True
            )
        
        collector1 = system1['fix_result_collector']
        collector1.collect_fix_result(fix_result)
        
        # Close the database connection
        if system1.get('database_manager'):
            system1['database_manager'].close()
        
        # Create new learning system (simulating restart)
        system2 = create_syntax_fixer_learning_system(db_config)
        
        # Verify data persistence
        collector2 = system2['fix_result_collector']
        results = collector2.get_fix_results(limit=10)
        
        # Check if our test data is still there
        found = False
        for result in results:
            if result.fix_id == "persistence-test-1":
                found = True
                break
        
        assert found, "Test data not persisted across restarts"
        
        print("Data persistence tests passed")
        
        # Clean up
        if system2.get('database_manager'):
            system2['database_manager'].close()
            shutil.rmtree(test_dir, ignore_errors=True)

def test_database_performance():
    """Test database performance with multiple operations."""
    print("Testing database performance...")
    
    # Create temporary directory for test database
    test_dir = tempfile.mkdtemp()
    db_path = os.path.join(test_dir, "test_performance.db")
    
    try:
        # Create database configuration
        db_config = DatabaseConfig(
            database_path=db_path,
            database_type="sqlite",
            max_connections=20,
            connection_timeout=30
        )
        
        # Create learning system
        system = create_syntax_fixer_learning_system(db_config)
        
        collector = system['fix_result_collector']
        processor = system['feedback_processor']
        
        # Test performance with multiple operations
        import time
        start_time = time.time()
        
        # Add many test fix results
        for i in range(100):
            fix_result = FixResult(
                fix_id=f"perf-test-{i}",
                file_path=f"/test/perf_test_{i}.nc",
                original_content=f"let x{i} = {i}",
                fixed_content=f"let x{i} = {i};",
                fixes_applied=[{"type": "semicolon", "line": 1}],
                confidence_score=0.8 + (i % 10) * 0.02,
                fix_time=0.05 + (i % 20) * 0.01,
                user_accepted=i % 3 != 0,  # 2/3 accepted
                timestamp=datetime.now() - timedelta(days=i)
            )
            
            collector.collect_fix_result(fix_result)
            
            if i % 10 == 0:  # Process feedback every 10 operations
                for j in range(i):
                    if j < len(collector.fix_results):
                        result = collector.fix_results[j]
                        processor.process_user_feedback(
                            result.fix_id,
                            True,
                            f"Performance test feedback {j}",
                            {"pattern_type": "semicolon", "file_type": "performance"}
                        )
        
        # Get performance metrics
        metrics = collector.get_effectiveness_metrics(days=7)
        
        # Verify performance
        assert metrics['total_fixes'] == 100, "Wrong total fixes count"
        assert metrics['acceptance_rate'] > 60, "Acceptance rate too low"
        assert metrics['average_fix_time'] > 0, "Average fix time should be positive"
        
        # Test database query performance
        query_start = time.time()
        results = collector.get_fix_results(limit=50)
        query_time = time.time() - query_start
        
        assert query_time < 1.0, "Database query took too long"
        
        print("Database performance tests passed")
        
        # Clean up
        if system.get('database_manager'):
            system['database_manager'].close()
            shutil.rmtree(test_dir, ignore_errors=True)

def main():
    """Run all database tests."""
    print("Running Phase 2.1 Database Tests")
    print("=" * 50)
    
    try:
        test_database_schema()
        test_data_persistence()
        test_database_performance()
        
        print("\n" + "=" * 50)
        print("All database tests passed successfully!")
        return True
        
    except Exception as e:
        print(f"\nDatabase test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

