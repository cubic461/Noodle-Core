#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_db_minimal.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Minimal Database Test for Phase 2.1
"""

import os
import sys
import tempfile
import shutil
import sqlite3

# Add noodle-core directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_basic_database():
    """Test basic database functionality without connection pool."""
    print("Testing basic database functionality...")
    
    # Create temporary directory for test database
    test_dir = tempfile.mkdtemp()
    db_path = os.path.join(test_dir, "test.db")
    
    try:
        # Test basic SQLite connection
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Create test table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS test_table (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                value TEXT
            )
        """)
        
        # Insert test data
        cursor.execute("INSERT INTO test_table (name, value) VALUES (?, ?)", ("test", "value"))
        conn.commit()
        
        # Query test data
        cursor.execute("SELECT * FROM test_table")
        results = cursor.fetchall()
        
        # Verify results
        assert len(results) == 1, "Test data not inserted"
        assert results[0][1] == "test", "Test data incorrect"
        
        # Close connection
        conn.close()
        
        print("Basic database test passed!")
        
    finally:
        # Clean up
        shutil.rmtree(test_dir, ignore_errors=True)

def test_phase2_1_components():
    """Test Phase 2.1 components without database."""
    print("Testing Phase 2.1 components...")
    
    try:
        from noodlecore.ai_agents.syntax_fixer_learning import (
            FixResultCollector, PatternAnalyzer, LearningEngine, FeedbackProcessor
        )
        
        # Test component creation
        collector = FixResultCollector()
        analyzer = PatternAnalyzer()
        engine = LearningEngine()
        processor = FeedbackProcessor()
        
        # Test basic functionality
        assert collector is not None, "FixResultCollector not created"
        assert analyzer is not None, "PatternAnalyzer not created"
        assert engine is not None, "LearningEngine not created"
        assert processor is not None, "FeedbackProcessor not created"
        
        # Test status methods
        collector_status = collector.get_status()
        analyzer_status = analyzer.get_status() if hasattr(analyzer, 'get_status') else {}
        engine_status = engine.get_learning_status()
        processor_status = processor.get_status()
        
        assert isinstance(collector_status, dict), "Collector status not dict"
        assert isinstance(engine_status, dict), "Engine status not dict"
        assert isinstance(processor_status, dict), "Processor status not dict"
        
        print("Phase 2.1 components test passed!")
        
    except Exception as e:
        print(f"Phase 2.1 components test failed: {e}")
        raise

def main():
    """Run all minimal database tests."""
    print("Running Phase 2.1 Minimal Database Tests")
    print("=" * 50)
    
    try:
        test_basic_database()
        test_phase2_1_components()
        
        print("\n" + "=" * 50)
        print("All minimal database tests passed successfully!")
        return True
        
    except Exception as e:
        print(f"\nMinimal database test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

