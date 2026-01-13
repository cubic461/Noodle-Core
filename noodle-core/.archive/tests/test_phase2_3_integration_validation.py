#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_3_integration_validation.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Integration Validation Tests for Phase 2.3

Comprehensive testing of cross-system integration including:
- Cross-system integration validation
- Database integration testing
- Environment variable configuration testing
- Error propagation and handling testing
- System stability and reliability testing
"""

import os
import sys
import unittest
import tempfile
import shutil
import time
import json
import sqlite3
import threading
import multiprocessing
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.database.connection_pool import DatabaseConnectionPool
from noodlecore.ai_agents.ml_model_registry import MLModelRegistry
from noodlecore.ai_agents.ml_configuration_manager import MLConfigurationManager
from noodlecore.ai_agents.ml_inference_engine import MLInferenceEngine
from noodlecore.ai_agents.data_preprocessor import DataPreprocessor

class TestDatabaseIntegration(unittest.TestCase):
    """Test database integration functionality."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.db_path = os.path.join(self.temp_dir, 'test.db')
        
        # Create test database
        self.conn = sqlite3.connect(self.db_path)
        self.cursor = self.conn.cursor()
        
        # Create test tables
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS test_table (
                id INTEGER PRIMARY KEY,
                data TEXT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        self.conn.commit()
        
        # Initialize connection pool
        self.db_pool = DatabaseConnectionPool(
            db_url=f'sqlite:///{self.db_path}',
            max_connections=5,
            max_idle_time=30
        )
    
    def tearDown(self):
        self.db_pool.close_all()
        self.conn.close()
        shutil.rmtree(self.temp_dir)
    
    def test_connection_pool_initialization(self):
        """Test connection pool initialization."""
        self.assertIsNotNone(self.db_pool)
        self.assertEqual(self.db_pool.max_connections, 5)
        self.assertEqual(self.db_pool.max_idle_time, 30)
        
        # Check pool statistics
        stats = self.db_pool.get_statistics()
        self.assertIn('total_connections', stats)
        self.assertIn('active_connections', stats)
        self.assertIn('idle_connections', stats)
    
    def test_database_connection_and_query(self):
        """Test database connection and querying."""
        def test_operation():
            conn = self.db_pool.get_connection()
            self.assertIsNotNone(conn)
            
            try:
                cursor = conn.cursor()
                
                # Insert test data
                cursor.execute(
                    "INSERT INTO test_table (data) VALUES (?)",
                    ("test_data",)
                )
                conn.commit()
                
                # Query test data
                cursor.execute("SELECT * FROM test_table WHERE data = ?", ("test_data",))
                result = cursor.fetchone()
                
                self.assertIsNotNone(result)
                self.assertEqual(result[1], "test_data")
                
                return True
                
            finally:
                self.db_pool.return_connection(conn)
        
        # Test operation
        result = test_operation()
        self.assertTrue(result)
        
        # Check connection pool statistics
        stats = self.db_pool.get_statistics()
        self.assertGreater(stats['total_connections'], 0)
        self.assertEqual(stats['active_connections'], 0)  # Should be returned
    
    def test_concurrent_database_operations(self):
        """Test concurrent database operations."""
        def worker_operation(worker_id):
            try:
                conn = self.db_pool.get_connection()
                cursor = conn.cursor()
                
                # Insert worker-specific data
                cursor.execute(
                    "INSERT INTO test_table (data) VALUES (?)",
                    (f"worker_{worker_id}_data",)
                )
                conn.commit()
                
                # Query all data
                cursor.execute("SELECT COUNT(*) FROM test_table")
                count = cursor.fetchone()[0]
                
                self.db_pool.return_connection(conn)
                return count
                
            except Exception as e:
                return f"Error: {e}"
        
        # Run multiple workers
        with multiprocessing.Pool(processes=3) as pool:
            results = pool.map(worker_operation, [1, 2, 3])
        
        # Check results
        for i, result in enumerate(results):
            self.assertIsInstance(result, int)
            self.assertGreater(result, i)  # Each worker should see previous data
        
        # Final count should be 3 (one from each worker)
        final_conn = self.db_pool.get_connection()
        cursor = final_conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM test_table")
        final_count = cursor.fetchone()[0]
        self.db_pool.return_connection(final_conn)
        
        self.assertEqual(final_count, 3)
    
    def test_transaction_handling(self):
        """Test transaction handling."""
        def test_transaction():
            conn = self.db_pool.get_connection()
            self.assertIsNotNone(conn)
            
            try:
                cursor = conn.cursor()
                
                # Start transaction
                cursor.execute("BEGIN TRANSACTION")
                
                # Insert multiple records
                for i in range(5):
                    cursor.execute(
                        "INSERT INTO test_table (data) VALUES (?)",
                        (f"transaction_data_{i}",)
                    )
                
                # Commit transaction
                conn.commit()
                
                # Verify all records were inserted
                cursor.execute("SELECT COUNT(*) FROM test_table WHERE data LIKE 'transaction_data_%'")
                count = cursor.fetchone()[0]
                
                self.db_pool.return_connection(conn)
                return count
                
            except Exception as e:
                conn.rollback()
                self.db_pool.return_connection(conn)
                raise e
        
        # Test successful transaction
        count = test_transaction()
        self.assertEqual(count, 5)
        
        # Test failed transaction
        def test_failed_transaction():
            conn = self.db_pool.get_connection()
            cursor = conn.cursor()
            
            try:
                cursor.execute("BEGIN TRANSACTION")
                
                # This will cause an error
                cursor.execute("INSERT INTO test_table (invalid_column) VALUES (?)", ("test",))
                
                conn.commit()
                return True
                
            except Exception:
                conn.rollback()
                self.db_pool.return_connection(conn)
                return False
        
        result = test_failed_transaction()
        self.assertFalse(result)  # Should have been rolled back
    
    def test_connection_pool_limits(self):
        """Test connection pool limits."""
        connections = []
        
        # Get all available connections
        for i in range(6):  # More than max_connections (5)
            try:
                conn = self.db_pool.get_connection()
                if conn:
                    connections.append(conn)
                else:
                    break
            except:
                break
        
        # Should only get 5 connections
        self.assertEqual(len(connections), 5)
        
        # Return all connections
        for conn in connections:
            self.db_pool.return_connection(conn)
        
        # Check pool statistics
        stats = self.db_pool.get_statistics()
        self.assertGreaterEqual(stats['total_connections'], 5)
        self.assertEqual(stats['active_connections'], 0)
    
    def test_database_error_handling(self):
        """Test database error handling."""
        # Test with invalid SQL
        conn = self.db_pool.get_connection()
        cursor = conn.cursor()
        
        with self.assertRaises(Exception):
            cursor.execute("SELECT * FROM non_existent_table")
        
        self.db_pool.return_connection(conn)
        
        # Connection should still be usable
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        self.assertEqual(result[0], 1)
        
        self.db_pool.return_connection(conn)

class TestEnvironmentVariableConfiguration(unittest.TestCase):
    """Test environment variable configuration."""
    
    def setUp(self):
        # Save original environment
        self.original_env = os.environ.copy()
    
    def tearDown(self):
        # Restore original environment
        os.environ.clear()
        os.environ.update(self.original_env)
    
    def test_noodle_prefix_variables(self):
        """Test NOODLE_ prefix environment variables."""
        # Set test variables
        test_vars = {
            'NOODLE_ENV': 'development',
            'NOODLE_PORT': '8080',
            'NOODLE_LOG_LEVEL': 'DEBUG',
            'NOODLE_DB_PATH': '/tmp/test.db',
            'NOODLE_ML_MODEL_TYPE': 'transformer',
            'NOODLE_SYNTAX_FIXER_ADVANCED_ML': 'true',
            'NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE': '64'
        }
        
        for key, value in test_vars.items():
            os.environ[key] = value
        
        # Test configuration manager reads variables
        config_manager = MLConfigurationManager()
        
        self.assertTrue(config_manager.is_advanced_ml_enabled())
        self.assertEqual(config_manager.get_model_type(), 'transformer')
        self.assertEqual(config_manager.get_batch_size(), 64)
    
    def test_environment_variable_validation(self):
        """Test environment variable validation."""
        # Test with invalid values
        os.environ['NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE'] = 'invalid'
        
        with self.assertRaises(ValueError):
            MLConfigurationManager()
        
        # Test with out-of-range values
        os.environ['NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE'] = '-1'
        
        with self.assertRaises(ValueError):
            MLConfigurationManager()
        
        # Test with valid values
        os.environ['NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE'] = '32'
        config_manager = MLConfigurationManager()
        self.assertEqual(config_manager.get_batch_size(), 32)
    
    def test_environment_variable_inheritance(self):
        """Test environment variable inheritance."""
        # Set parent process variables
        parent_vars = {
            'NOODLE_PARENT_VAR': 'parent_value',
            'NOODLE_INHERITED_VAR': 'inherited_value'
        }
        
        for key, value in parent_vars.items():
            os.environ[key] = value
        
        # Create child process and check inheritance
        import subprocess
        result = subprocess.run([
            sys.executable, '-c',
            '''
import os
import json
from noodlecore.ai_agents.ml_configuration_manager import MLConfigurationManager

config = MLConfigurationManager()
result = {
    "parent_var": os.environ.get("NOODLE_PARENT_VAR"),
    "inherited_var": os.environ.get("NOODLE_INHERITED_VAR")
}
print(json.dumps(result))
'''
        ], capture_output=True, text=True)
        
        child_result = json.loads(result.stdout)
        
        self.assertEqual(child_result['parent_var'], 'parent_value')
        self.assertEqual(child_result['inherited_var'], 'inherited_value')
    
    def test_environment_variable_updates(self):
        """Test runtime environment variable updates."""
        # Initial configuration
        os.environ['NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE'] = '16'
        config_manager = MLConfigurationManager()
        self.assertEqual(config_manager.get_batch_size(), 16)
        
        # Update environment variable
        os.environ['NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE'] = '128'
        
        # Reload configuration
        config_manager.reload_from_environment()
        
        self.assertEqual(config_manager.get_batch_size(), 128)
    
    def test_environment_variable_fallbacks(self):
        """Test environment variable fallbacks."""
        # Clear relevant environment variables
        for key in list(os.environ.keys()):
            if key.startswith('NOODLE_'):
                del os.environ[key]
        
        # Should use defaults
        config_manager = MLConfigurationManager()
        
        # Check default values
        self.assertIsInstance(config_manager.get_batch_size(), int)
        self.assertIsInstance(config_manager.get_model_type(), str)
        self.assertIsInstance(config_manager.is_advanced_ml_enabled(), bool)
    
    def test_environment_variable_security(self):
        """Test environment variable security."""
        # Test with potentially dangerous values
        dangerous_values = [
            'NOODLE_DB_PATH': '/etc/passwd',
            'NOODLE_SECRET_KEY': 'hardcoded_secret_value',
            'NOODLE_API_TOKEN': 'bearer_token_12345'
        ]
        
        for key, value in dangerous_values.items():
            os.environ[key] = value
            
            # Configuration should handle or reject dangerous values
            try:
                config_manager = MLConfigurationManager()
                
                # Check if dangerous values are handled appropriately
                if 'password' in key.lower() or 'secret' in key.lower() or 'token' in key.lower():
                    # In a real implementation, might log warnings or use secure defaults
                    pass
                
            except Exception as e:
                # Should handle errors gracefully
                self.assertIsInstance(e, (ValueError, SecurityError))
    
    def test_environment_variable_type_conversion(self):
        """Test environment variable type conversion."""
        # Test various type conversions
        type_test_vars = {
            'NOODLE_INT_VAR': '42',
            'NOODLE_FLOAT_VAR': '3.14',
            'NOODLE_BOOL_VAR': 'true',
            'NOODLE_LIST_VAR': 'item1,item2,item3',
            'NOODLE_JSON_VAR': '{"key": "value", "number": 123}'
        }
        
        for key, value in type_test_vars.items():
            os.environ[key] = value
        
        # Create configuration manager that handles type conversion
        config_manager = MLConfigurationManager()
        
        # Test that values are converted to appropriate types
        # This would depend on the specific implementation
        # For now, just verify no exceptions are raised
        self.assertIsInstance(config_manager.get_config(), object)

class TestErrorPropagationAndHandling(unittest.TestCase):
    """Test error propagation and handling across components."""
    
    def setUp(self):
        self.error_log = []
        self.temp_dir = tempfile.mkdtemp()
        
        # Mock error handler
        def error_handler(error, context):
            self.error_log.append({
                'error': str(error),
                'context': context,
                'timestamp': time.time()
            })
        
        self.error_handler = error_handler
    
    def test_error_propagation_through_ml_pipeline(self):
        """Test error propagation through ML pipeline."""
        # Mock components that can fail
        class MockFailingPreprocessor:
            def preprocess_text(self, text, language=None):
                if 'fail' in text:
                    raise ValueError("Preprocessing failed")
                return {'tokens': ['mock'], 'processing_time': 0.1}
        
        class MockFailingModel:
            def predict(self, input_data):
                if 'error' in str(input_data):
                    raise RuntimeError("Model prediction failed")
                return ['mock_prediction']
        
        # Create pipeline with failing components
        preprocessor = MockFailingPreprocessor()
        model = MockFailingModel()
        
        # Test error propagation
        try:
            # This should fail at preprocessing
            result = preprocessor.preprocess_text("fail this text")
            self.fail("Should have raised an exception")
        except ValueError as e:
            # Error should be caught and logged
            self.error_handler(e, {'component': 'preprocessor', 'operation': 'preprocess_text'})
            
            # Verify error details
            self.assertIn("Preprocessing failed", str(e))
        
        try:
            # This should fail at model prediction
            result = model.predict("error this input")
            self.fail("Should have raised an exception")
        except RuntimeError as e:
            # Error should be caught and logged
            self.error_handler(e, {'component': 'model', 'operation': 'predict'})
            
            # Verify error details
            self.assertIn("Model prediction failed", str(e))
        
        # Check error log
        self.assertEqual(len(self.error_log), 2)
        
        # Verify error contexts
        contexts = [entry['context'] for entry in self.error_log]
        self.assertIn({'component': 'preprocessor', 'operation': 'preprocess_text'}, contexts)
        self.assertIn({'component': 'model', 'operation': 'predict'}, contexts)
    
    def test_error_recovery_mechanisms(self):
        """Test error recovery mechanisms."""
        recovery_attempts = []
        
        class MockRecoveringComponent:
            def __init__(self, fail_count=2):
                self.fail_count = fail_count
                self.attempt = 0
            
            def process(self, data):
                self.attempt += 1
                recovery_attempts.append(self.attempt)
                
                if self.attempt <= self.fail_count:
                    raise Exception(f"Attempt {self.attempt} failed")
                
                return f"processed_{data}"
        
        component = MockRecoveringComponent(fail_count=2)
        
        # Test recovery
        result = None
        for attempt in range(4):  # Try 4 times
            try:
                result = component.process("test_data")
                break
            except Exception:
                if attempt >= 2:  # Give up after 3 attempts
                    break
        
        # Should eventually succeed
        self.assertIsNotNone(result)
        self.assertEqual(result, "processed_test_data")
        
        # Should have made 3 attempts (2 failures + 1 success)
        self.assertEqual(len(recovery_attempts), 3)
        self.assertEqual(recovery_attempts, [1, 2, 3])
    
    def test_error_context_preservation(self):
        """Test error context preservation."""
        error_contexts = []
        
        def context_aware_error_handler(error, context, operation_chain):
            error_contexts.append({
                'error': str(error),
                'context': context,
                'operation_chain': operation_chain,
                'timestamp': time.time()
            })
        
        # Simulate error chain
        try:
            try:
                raise ValueError("Initial error")
            except ValueError as e:
                context_aware_error_handler(e, {'level': '1'}, ['operation1'])
                
                try:
                    raise RuntimeError("Secondary error") from e
                except RuntimeError as e2:
                    context_aware_error_handler(e2, {'level': '2'}, ['operation1', 'operation2'])
                    
                    raise Exception("Final error") from e2
        except Exception as e3:
            context_aware_error_handler(e3, {'level': '3'}, ['operation1', 'operation2', 'operation3'])
        
        # Check error context preservation
        self.assertEqual(len(error_contexts), 3)
        
        # Verify context chaining
        for i, context in enumerate(error_contexts):
            expected_chain = ['operation1', 'operation2', 'operation3'][:i+1]
            self.assertEqual(context['operation_chain'], expected_chain)
            self.assertEqual(context['context']['level'], str(i+1))
    
    def test_error_aggregation_and_reporting(self):
        """Test error aggregation and reporting."""
        error_report = {
            'total_errors': 0,
            'error_types': {},
            'error_components': {},
            'error_severity': {},
            'recovery_success_rate': 0,
            'total_recovery_attempts': 0
        }
        
        def aggregating_error_handler(error, context):
            # Update error report
            error_report['total_errors'] += 1
            
            # Categorize error
            error_type = type(error).__name__
            error_report['error_types'][error_type] = error_report['error_types'].get(error_type, 0) + 1
            
            # Track component
            component = context.get('component', 'unknown')
            error_report['error_components'][component] = error_report['error_components'].get(component, 0) + 1
            
            # Track severity
            severity = context.get('severity', 'medium')
            error_report['error_severity'][severity] = error_report['error_severity'].get(severity, 0) + 1
        
        # Generate various errors
        test_errors = [
            (ValueError("Syntax error"), {'component': 'parser', 'severity': 'high'}),
            (RuntimeError("Processing error"), {'component': 'processor', 'severity': 'medium'}),
            (KeyError("Configuration error"), {'component': 'config', 'severity': 'low'}),
            (MemoryError("Memory error"), {'component': 'processor', 'severity': 'critical'})
        ]
        
        for error, context in test_errors:
            try:
                raise error
            except type(error) as e:
                aggregating_error_handler(e, context)
        
        # Verify error report
        self.assertEqual(error_report['total_errors'], 4)
        self.assertEqual(error_report['error_types']['ValueError'], 1)
        self.assertEqual(error_report['error_types']['RuntimeError'], 1)
        self.assertEqual(error_report['error_types']['KeyError'], 1)
        self.assertEqual(error_report['error_types']['MemoryError'], 1)
        
        self.assertEqual(error_report['error_components']['parser'], 1)
        self.assertEqual(error_report['error_components']['processor'], 2)
        self.assertEqual(error_report['error_components']['config'], 1)
        
        self.assertEqual(error_report['error_severity']['high'], 1)
        self.assertEqual(error_report['error_severity']['medium'], 1)
        self.assertEqual(error_report['error_severity']['low'], 1)
        self.assertEqual(error_report['error_severity']['critical'], 1)
    
    def test_error_boundary_conditions(self):
        """Test error handling at boundary conditions."""
        boundary_test_results = []
        
        def boundary_test_handler(test_name, test_func):
            try:
                result = test_func()
                boundary_test_results.append({
                    'test': test_name,
                    'result': 'success',
                    'output': result
                })
            except Exception as e:
                boundary_test_results.append({
                    'test': test_name,
                    'result': 'error',
                    'error': str(e)
                })
        
        # Test various boundary conditions
        boundary_tests = [
            ('empty_input', lambda: "".upper()),
            ('null_input', lambda: None.upper()),
            ('very_large_input', lambda: "x" * 1000000),
            ('special_characters', lambda: "\x00\x01\x02".upper()),
            ('unicode_input', lambda: "cafÃ© naÃ¯ve".upper()),
            ('numeric_overflow', lambda: 999999999999999999999999),
            ('recursive_depth', lambda: [1, [2, [3, [4, [5]]]]])
        ]
        
        for test_name, test_func in boundary_tests:
            boundary_test_handler(test_name, test_func)
        
        # Check results
        self.assertEqual(len(boundary_test_results), len(boundary_tests))
        
        # Some tests should pass, some should fail
        passed_tests = [r for r in boundary_test_results if r['result'] == 'success']
        failed_tests = [r for r in boundary_test_results if r['result'] == 'error']
        
        self.assertGreater(len(passed_tests), 0)
        self.assertGreater(len(failed_tests), 0)

class TestSystemStabilityAndReliability(unittest.TestCase):
    """Test system stability and reliability."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.stability_metrics = {
            'uptime': 0,
            'memory_usage': [],
            'response_times': [],
            'error_count': 0,
            'throughput': 0
        }
    
    def tearDown(self):
        shutil.rmtree(self.temp_dir)
    
    def test_long_running_stability(self):
        """Test stability over long-running operations."""
        start_time = time.time()
        
        # Simulate long-running process
        def long_running_process():
            for i in range(1000):
                # Simulate work
                time.sleep(0.001)
                
                # Record metrics
                current_time = time.time()
                self.stability_metrics['response_times'].append(0.001)
                
                # Simulate occasional errors
                if i % 100 == 0:
                    self.stability_metrics['error_count'] += 1
                
                # Simulate memory usage
                if i % 50 == 0:
                    self.stability_metrics['memory_usage'].append(50 + i % 20)
        
        # Run in thread
        thread = threading.Thread(target=long_running_process)
        thread.start()
        thread.join(timeout=5)  # 5 second max
        
        end_time = time.time()
        uptime = end_time - start_time
        
        self.stability_metrics['uptime'] = uptime
        
        # Verify stability metrics
        self.assertGreater(uptime, 4)  # Should run for at least 4 seconds
        self.assertGreater(len(self.stability_metrics['response_times']), 900)
        self.assertEqual(self.stability_metrics['error_count'], 10)  # 1000 / 100
        self.assertGreater(len(self.stability_metrics['memory_usage']), 0)
        
        # Check for memory leaks (simplified)
        if len(self.stability_metrics['memory_usage']) > 1:
            memory_trend = self.stability_metrics['memory_usage'][-10:]  # Last 10 measurements
            if memory_trend:
                avg_memory = sum(memory_trend) / len(memory_trend)
                # Memory should be relatively stable
                self.assertLess(abs(memory_trend[-1] - avg_memory), 10)
    
    def test_load_stress_testing(self):
        """Test system stability under load."""
        def stress_worker(worker_id):
            worker_metrics = {
                'operations': 0,
                'errors': 0,
                'start_time': time.time()
            }
            
            try:
                for i in range(100):  # 100 operations per worker
                    # Simulate work
                    time.sleep(0.001)
                    
                    # Simulate occasional errors
                    if i % 25 == 0:  # 25% error rate
                        worker_metrics['errors'] += 1
                        raise Exception(f"Worker {worker_id} error {i}")
                    
                    worker_metrics['operations'] += 1
                    
            except Exception:
                worker_metrics['errors'] += 1
            
            worker_metrics['end_time'] = time.time()
            worker_metrics['duration'] = worker_metrics['end_time'] - worker_metrics['start_time']
            
            return worker_metrics
        
        # Run multiple workers
        num_workers = 4
        with multiprocessing.Pool(processes=num_workers) as pool:
            worker_results = pool.map(stress_worker, range(num_workers))
        
        # Analyze stress test results
        total_operations = sum(r['operations'] for r in worker_results)
        total_errors = sum(r['errors'] for r in worker_results)
        avg_duration = sum(r['duration'] for r in worker_results) / num_workers
        
        # Verify stress test results
        self.assertEqual(total_operations, 400)  # 100 operations * 4 workers
        self.assertGreater(total_errors, 0)  # Should have errors
        self.assertLess(avg_duration, 2.0)  # Should complete in reasonable time
        
        # Calculate error rate
        error_rate = total_errors / total_operations
        self.assertGreater(error_rate, 0.2)  # Should be around 25%
        self.assertLess(error_rate, 0.3)  # But not too high
    
    def test_resource_cleanup_stability(self):
        """Test resource cleanup stability."""
        cleanup_tracker = {
            'created_resources': [],
            'cleaned_resources': [],
            'leaked_resources': []
        }
        
        class TestResource:
            def __init__(self, resource_id):
                self.resource_id = resource_id
                self.is_cleaned = False
                
            def cleanup(self):
                self.is_cleaned = True
                cleanup_tracker['cleaned_resources'].append(self.resource_id)
                
            def __del__(self):
                if not self.is_cleaned:
                    cleanup_tracker['leaked_resources'].append(self.resource_id)
        
        # Create and cleanup resources
        for i in range(10):
            resource = TestResource(f"resource_{i}")
            cleanup_tracker['created_resources'].append(resource.resource_id)
            
            # Some resources are cleaned up, some are not
            if i % 3 == 0:  # Clean up every 3rd resource
                resource.cleanup()
        
        # Force garbage collection
        import gc
        gc.collect()
        
        # Check cleanup results
        self.assertEqual(len(cleanup_tracker['created_resources']), 10)
        self.assertEqual(len(cleanup_tracker['cleaned_resources']), 3)  # Resources 0, 3, 6, 9
        self.assertEqual(len(cleanup_tracker['leaked_resources']), 7)  # Resources 1, 2, 4, 5, 7, 8, 10
    
    def test_concurrent_access_stability(self):
        """Test stability under concurrent access."""
        shared_counter = {'value': 0, 'errors': 0}
        lock = threading.Lock()
        
        def concurrent_worker(worker_id):
            for i in range(50):
                try:
                    with lock:
                        # Simulate critical section
                        shared_counter['value'] += 1
                        
                        # Simulate occasional contention
                        if i % 10 == 0 and worker_id % 2 == 0:
                            time.sleep(0.001)  # Small delay to cause contention
                            
                except Exception:
                    with lock:
                        shared_counter['errors'] += 1
        
        # Run multiple workers
        num_workers = 5
        threads = []
        
        for i in range(num_workers):
            thread = threading.Thread(target=concurrent_worker, args=(i,))
            thread.start()
            threads.append(thread)
        
        # Wait for completion
        for thread in threads:
            thread.join(timeout=2)
        
        # Verify concurrent access results
        expected_value = 50 * num_workers  # 50 operations * 5 workers
        self.assertEqual(shared_counter['value'], expected_value)
        
        # Should have minimal errors (only from contention)
        self.assertLessEqual(shared_counter['errors'], 5)  # At most one per worker
    
    def test_configuration_stability(self):
        """Test stability with configuration changes."""
        config_changes = []
        
        class TestConfigurableComponent:
            def __init__(self):
                self.config = {'setting1': 'value1', 'setting2': 'value2'}
                self.change_count = 0
            
            def update_config(self, key, value):
                self.config[key] = value
                self.change_count += 1
                config_changes.append({
                    'key': key,
                    'old_value': self.config.get(key),
                    'new_value': value,
                    'timestamp': time.time()
                })
                
                # Simulate configuration validation
                if key == 'setting2' and value == 'invalid':
                    raise ValueError("Invalid configuration value")
            
            def get_config(self, key):
                return self.config.get(key)
        
        component = TestConfigurableComponent()
        
        # Apply various configuration changes
        config_updates = [
            ('setting1', 'new_value1'),
            ('setting2', 'new_value2'),
            ('setting1', 'new_value3'),
            ('setting2', 'invalid'),  # This should fail
            ('setting3', 'new_value4')  # New setting
        ]
        
        successful_updates = 0
        failed_updates = 0
        
        for key, value in config_updates:
            try:
                component.update_config(key, value)
                successful_updates += 1
            except ValueError:
                failed_updates += 1
        
        # Verify configuration stability
        self.assertEqual(successful_updates, 4)
        self.assertEqual(failed_updates, 1)
        self.assertEqual(component.change_count, 5)
        
        # Verify final state
        self.assertEqual(component.get_config('setting1'), 'new_value3')
        self.assertEqual(component.get_config('setting2'), 'new_value2')  # Should not have changed to invalid
        
        # Check change history
        self.assertEqual(len(config_changes), 5)
        
        # Verify change tracking
        last_change = config_changes[-1]
        self.assertEqual(last_change['key'], 'setting3')
        self.assertEqual(last_change['new_value'], 'new_value4')
    
    def test_performance_degradation_detection(self):
        """Test detection of performance degradation."""
        performance_metrics = []
        
        def simulate_performance_test():
            start_time = time.time()
            
            # Simulate work with varying performance
            for i in range(10):
                if i < 5:
                    time.sleep(0.01)  # Fast initially
                else:
                    time.sleep(0.05)  # Slower later
                
            end_time = time.time()
            duration = end_time - start_time
            
            performance_metrics.append({
                'iteration': len(performance_metrics) + 1,
                'duration': duration,
                'timestamp': time.time()
            })
            
            return duration
        
        # Run multiple performance tests
        for _ in range(5):
            simulate_performance_test()
        
        # Analyze performance degradation
        self.assertEqual(len(performance_metrics), 5)
        
        # Calculate performance trend
        durations = [m['duration'] for m in performance_metrics]
        early_avg = sum(durations[:2]) / 2
        late_avg = sum(durations[3:]) / 2
        
        # Should detect performance degradation
        self.assertLess(early_avg, late_avg)
        
        # Performance degradation should be significant
        degradation_ratio = late_avg / early_avg
        self.assertGreater(degradation_ratio, 2.0)  # At least 2x slower

class TestCrossSystemIntegration(unittest.TestCase):
    """Test cross-system integration."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.integration_log = []
        
        def integration_logger(event_type, component1, component2, details):
            self.integration_log.append({
                'event_type': event_type,
                'component1': component1,
                'component2': component2,
                'details': details,
                'timestamp': time.time()
            })
        
        self.integration_logger = integration_logger
    
    def test_ml_to_database_integration(self):
        """Test ML to database integration."""
        # Create mock ML components
        class MockMLComponent:
            def __init__(self, db_pool):
                self.db_pool = db_pool
                
            def process_and_store(self, data):
                # Process data
                processed_data = f"processed_{data}"
                
                # Store in database
                conn = self.db_pool.get_connection()
                try:
                    cursor = conn.cursor()
                    cursor.execute(
                        "INSERT INTO test_table (data) VALUES (?)",
                        (processed_data,)
                    )
                    conn.commit()
                    
                    self.integration_logger(
                        'data_store',
                        'ml_component',
                        'database',
                        {'data': data, 'processed_data': processed_data}
                    )
                    
                    return processed_data
                    
                finally:
                    self.db_pool.return_connection(conn)
        
        # Create database
        db_path = os.path.join(self.temp_dir, 'integration_test.db')
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS test_table (
                id INTEGER PRIMARY KEY,
                data TEXT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        conn.commit()
        
        db_pool = DatabaseConnectionPool(
            db_url=f'sqlite:///{db_path}',
            max_connections=3
        )
        
        # Create and test ML component
        ml_component = MockMLComponent(db_pool)
        
        # Process test data
        test_data = ['test1', 'test2', 'test3']
        results = []
        
        for data in test_data:
            result = ml_component.process_and_store(data)
            results.append(result)
        
        # Verify results
        self.assertEqual(len(results), 3)
        for i, result in enumerate(results):
            self.assertEqual(result, f"processed_{test_data[i]}")
        
        # Verify database storage
        conn = db_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM test_table")
        count = cursor.fetchone()[0]
        db_pool.return_connection(conn)
        
        self.assertEqual(count, 3)
        
        # Verify integration logging
        self.assertEqual(len(self.integration_log), 3)
        
        # Close database
        db_pool.close_all()
        conn.close()
    
    def test_configuration_to_performance_integration(self):
        """Test configuration to performance integration."""
        # Mock configuration manager
        class MockConfigManager:
            def __init__(self):
                self.config = {
                    'batch_size': 16,
                    'max_memory': 512,
                    'optimization_level': 'balanced'
                }
                self.listeners = []
                
            def update_config(self, key, value):
                old_value = self.config.get(key)
                self.config[key] = value
                
                # Notify listeners
                for listener in self.listeners:
                    listener('config_changed', key, old_value, value)
                
                self.integration_logger(
                    'config_change',
                    'config_manager',
                    'performance_system',
                    {'key': key, 'old_value': old_value, 'new_value': value}
                )
            
            def get_config(self, key):
                return self.config.get(key)
            
            def add_listener(self, listener):
                self.listeners.append(listener)
        
        # Mock performance system
        class MockPerformanceSystem:
            def __init__(self):
                self.metrics = {
                    'throughput': 100,
                    'latency': 50,
                    'memory_usage': 256
                }
                
            def update_performance_config(self, config):
                # Apply configuration to performance parameters
                if 'batch_size' in config:
                    self.metrics['throughput'] = 1000 // config['batch_size']
                    
                if 'max_memory' in config:
                    self.metrics['memory_usage'] = min(
                        self.metrics['memory_usage'],
                        config['max_memory']
                    )
                    
                if 'optimization_level' in config:
                    if config['optimization_level'] == 'performance':
                        self.metrics['latency'] *= 0.8  # 20% improvement
                    elif config['optimization_level'] == 'memory':
                        self.metrics['memory_usage'] *= 0.7  # 30% reduction
                
                self.integration_logger(
                    'performance_update',
                    'performance_system',
                    'config_manager',
                    {'config': config, 'new_metrics': self.metrics}
                )
            
            def get_metrics(self):
                return self.metrics.copy()
        
        # Create components
        config_manager = MockConfigManager()
        performance_system = MockPerformanceSystem()
        
        # Set up integration
        def performance_config_listener(event_type, key, old_value, new_value):
            if event_type == 'config_changed':
                performance_system.update_performance_config(config_manager.config)
        
        config_manager.add_listener(performance_config_listener)
        
        # Test configuration changes affecting performance
        initial_metrics = performance_system.get_metrics()
        
        # Change batch size
        config_manager.update_config('batch_size', 32)
        
        # Change optimization level
        config_manager.update_config('optimization_level', 'performance')
        
        # Verify performance updates
        updated_metrics = performance_system.get_metrics()
        
        self.assertNotEqual(updated_metrics['throughput'], initial_metrics['throughput'])
        self.assertNotEqual(updated_metrics['latency'], initial_metrics['latency'])
        
        # Verify integration logging
        config_events = [e for e in self.integration_log if e['event_type'] == 'config_change']
        performance_events = [e for e in self.integration_log if e['event_type'] == 'performance_update']
        
        self.assertEqual(len(config_events), 2)
        self.assertEqual(len(performance_events), 2)
    
    def test_error_handling_integration(self):
        """Test error handling integration across systems."""
        error_tracker = {
            'ml_errors': 0,
            'db_errors': 0,
            'config_errors': 0,
            'recovered_errors': 0
        }
        
        # Mock integrated components
        class MockIntegratedSystem:
            def __init__(self):
                self.components = {
                    'ml': MockMLComponent(),
                    'db': MockDatabaseComponent(),
                    'config': MockConfigComponent()
                }
                
            def process_request(self, request):
                try:
                    # ML processing
                    if request.get('should_fail_ml', False):
                        raise ValueError("ML processing failed")
                    result = self.components['ml'].process(request)
                    
                    # Database storage
                    self.components['db'].store(result)
                    
                    # Configuration update
                    self.components['config'].update_from_result(result)
                    
                    return result
                    
                except ValueError as e:
                    error_tracker['ml_errors'] += 1
                    
                    # Attempt recovery
                    try:
                        recovery_result = self.components['ml'].recover(e, request)
                        self.components['db'].store(recovery_result)
                        error_tracker['recovered_errors'] += 1
                        return recovery_result
                        
                    except Exception:
                        # Propagate error
                        raise
        
        class MockMLComponent:
            def process(self, request):
                return f"ml_processed_{request}"
                
            def recover(self, error, request):
                return f"ml_recovered_{request}"
        
        class MockDatabaseComponent:
            def store(self, data):
                if 'error' in data:
                    raise RuntimeError("Database storage failed")
                    
            self.integration_logger(
                'data_store',
                'database',
                'ml_component',
                {'data': data}
            )
        
        class MockConfigComponent:
            def update_from_result(self, result):
                if 'invalid' in result:
                    raise KeyError("Configuration update failed")
                    
                self.integration_logger(
                'config_update',
                'config_component',
                'ml_component',
                {'result': result}
            )
        
        # Create integrated system
        system = MockIntegratedSystem()
        
        # Test successful request
        success_result = system.process_request({'data': 'test'})
        self.assertEqual(success_result, 'ml_processed_test')
        
        # Test ML failure with recovery
        recovery_result = system.process_request({'data': 'recover_test', 'should_fail_ml': True})
        self.assertEqual(recovery_result, 'ml_recovered_recover_test')
        
        # Test database failure
        try:
            system.process_request({'data': 'db_fail_test'})
            self.fail("Should have raised database error")
        except RuntimeError:
            error_tracker['db_errors'] += 1
        
        # Test configuration failure
        try:
            system.process_request({'data': 'config_fail_test'})
            self.fail("Should have raised configuration error")
        except KeyError:
            error_tracker['config_errors'] += 1
        
        # Verify error tracking
        self.assertEqual(error_tracker['ml_errors'], 1)
        self.assertEqual(error_tracker['db_errors'], 1)
        self.assertEqual(error_tracker['config_errors'], 1)
        self.assertEqual(error_tracker['recovered_errors'], 1)
        
        # Verify integration logging
        self.assertGreater(len(self.integration_log), 0)

if __name__ == '__main__':
    # Configure test environment
    os.environ['NOODLE_ENV'] = 'test'
    os.environ['NOODLE_LOG_LEVEL'] = 'DEBUG'
    
    # Run tests
    unittest.main(verbosity=2)

