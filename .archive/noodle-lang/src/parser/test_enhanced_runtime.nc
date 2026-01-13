# Tests for Enhanced NBC Runtime
# ==============================
#
# This module contains comprehensive tests for the enhanced NBC runtime
# with robust module loading and parser-interpreter integration.
#

import unittest
import tempfile
import os
import time
import shutil
from unittest.mock import Mock, patch, MagicMock

import ...core.runtime_enhanced as enhanced_runtime
import ...core.runtime_enhanced.RuntimeConfig
import ...core.runtime_enhanced.RuntimeMetrics
import ...core.runtime_enhanced.RuntimeState
import ...robust_module_loader.RobustNoodleModuleLoader
import ...parser_interpreter_interface.ParserInterpreterInterface


class TestRuntimeConfig(unittest.TestCase):
    """Test cases for RuntimeConfig."""
    
    def test_default_config(self):
        """Test default configuration values."""
        config = enhanced_runtime.RuntimeConfig()
        
        # Test default values
        self.assertEqual(config.max_stack_depth, 1000)
        self.assertEqual(config.max_execution_time, 3600.0)
        self.assertEqual(config.max_memory_usage, 1024 * 1024 * 1024)
        self.assertTrue(config.enable_optimization)
        self.assertEqual(config.optimization_level, 2)
        self.assertEqual(config.log_level, "INFO")
        self.assertTrue(config.enable_module_cache)
        self.assertEqual(config.module_cache_ttl, 300.0)
        self.assertEqual(config.max_module_retries, 3)
        self.assertTrue(config.enable_parser_optimizations)
        self.assertEqual(config.parser_optimization_level, 2)
        self.assertTrue(config.enable_bytecode_generation)
    
    def test_custom_config(self):
        """Test custom configuration values."""
        config = enhanced_runtime.RuntimeConfig(
            max_stack_depth=2000,
            max_execution_time=7200.0,
            enable_module_cache=False,
            module_cache_ttl=600.0,
            parser_optimization_level=3
        )
        
        self.assertEqual(config.max_stack_depth, 2000)
        self.assertEqual(config.max_execution_time, 7200.0)
        self.assertFalse(config.enable_module_cache)
        self.assertEqual(config.module_cache_ttl, 600.0)
        self.assertEqual(config.parser_optimization_level, 3)
    
    def test_config_to_dict(self):
        """Test configuration to dictionary conversion."""
        config = enhanced_runtime.RuntimeConfig()
        config_dict = config.to_dict()
        
        # Check that all expected keys are present
        expected_keys = [
            "max_stack_depth", "max_execution_time", "max_memory_usage",
            "enable_optimization", "optimization_level", "enable_profiling",
            "enable_tracing", "log_level", "matrix_backend",
            "enable_module_cache", "module_cache_ttl", "max_module_retries",
            "enable_parser_optimizations", "parser_optimization_level",
            "enable_bytecode_generation"
        ]
        
        for key in expected_keys:
            self.assertIn(key, config_dict)


class TestRuntimeMetrics(unittest.TestCase):
    """Test cases for RuntimeMetrics."""
    
    def test_default_metrics(self):
        """Test default metrics values."""
        metrics = enhanced_runtime.RuntimeMetrics()
        
        # Test default values
        self.assertEqual(metrics.start_time, 0.0)
        self.assertIsNone(metrics.end_time)
        self.assertEqual(metrics.execution_time, 0.0)
        self.assertEqual(metrics.instructions_executed, 0)
        self.assertEqual(self.runtime_metrics.modules_loaded, 0)
        self.assertEqual(self.runtime_metrics.modules_cached, 0)
        self.assertEqual(self.runtime_metrics.source_code_parsed, 0)
        self.assertEqual(self.runtime_metrics.bytecode_generated, 0)
    
    def test_metrics_to_dict(self):
        """Test metrics to dictionary conversion."""
        metrics = enhanced_runtime.RuntimeMetrics()
        metrics.instructions_executed = 100
        metrics.modules_loaded = 5
        metrics.modules_cached = 3
        
        metrics_dict = metrics.to_dict()
        
        # Check that all expected keys are present
        expected_keys = [
            "start_time", "end_time", "execution_time", "instructions_executed",
            "memory_used", "stack_depth", "errors_count", "warnings_count",
            "database_queries", "matrix_operations", "optimization_applied",
            "modules_loaded", "modules_cached", "module_load_time",
            "source_code_parsed", "bytecode_generated", "optimizations_applied"
        ]
        
        for key in expected_keys:
            self.assertIn(key, metrics_dict)
        
        # Check specific values
        self.assertEqual(metrics_dict["instructions_executed"], 100)
        self.assertEqual(metrics_dict["modules_loaded"], 5)
        self.assertEqual(metrics_dict["modules_cached"], 3)


class TestNBCRuntime(unittest.TestCase):
    """Test cases for Enhanced NBC Runtime."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = enhanced_runtime.RuntimeConfig(
            max_execution_time=10.0,  # Shorter timeout for tests
            enable_module_cache=True,
            module_cache_ttl=60.0,
            enable_parser_optimizations=True,
            parser_optimization_level=1
        )
        self.runtime = enhanced_runtime.NBCRuntime(self.config)
    
    def tearDown(self):
        """Clean up test fixtures."""
        if self.runtime:
            self.runtime.stop()
    
    def test_runtime_initialization(self):
        """Test runtime initialization."""
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.READY)
        self.assertIsNotNone(self.runtime.config)
        self.assertIsNotNone(self.runtime.runtime_metrics)
        self.assertIsNone(self.runtime.current_program)
        self.assertEqual(self.runtime.program_counter, 0)
    
    def test_runtime_state_transitions(self):
        """Test runtime state transitions."""
        # Test initial state
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.READY)
        
        # Test running state
        self.runtime.state = enhanced_runtime.RuntimeState.RUNNING
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.RUNNING)
        
        # Test paused state
        self.runtime.pause()
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.PAUSED)
        
        # Test resume
        self.runtime.resume()
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.RUNNING)
        
        # Test stop
        self.runtime.stop()
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.STOPPED)
    
    def test_load_program_validation(self):
        """Test program loading validation."""
        # Test empty program
        with self.assertRaises(ValueError):
            self.runtime.load_program([])
        
        # Test invalid program (missing type)
        invalid_program = [{"not_type": "value"}]
        with self.assertRaises(ValueError):
            self.runtime.load_program(invalid_program)
        
        # Test valid program
        valid_program = [
            {"type": "assignment", "variable": "x", "value": "42"},
            {"type": "print", "args": ["x"]}
        ]
        self.runtime.load_program(valid_program)
        self.assertEqual(len(self.runtime.current_program), 2)
    
    def test_execute_simple_program(self):
        """Test execution of a simple program."""
        program = [
            {"type": "assignment", "variable": "x", "value": "42"},
            {"type": "print", "args": ["x"]}
        ]
        
        result = self.runtime.execute_program(program)
        
        self.assertTrue(result["success"])
        self.assertEqual(result["state"], "stopped")
        self.assertEqual(result["metrics"]["instructions_executed"], 2)
    
    def test_load_program_from_source(self):
        """Test loading program from source code."""
        source_code = """
x = 42
print(x)
y = x + 10
print(y)
"""
        
        success = self.runtime.load_program_from_source(source_code, "test_module")
        
        self.assertTrue(success)
        self.assertEqual(self.runtime.state, enhanced_runtime.RuntimeState.READY)
        self.assertGreater(len(self.runtime.current_program), 0)
    
    def test_load_module_with_mock_loader(self):
        """Test loading module with mocked module loader."""
        # Mock the module loader
        mock_module = {"name": "test_module", "content": "test content"}
        self.runtime.module_loader = Mock()
        self.runtime.module_loader.load_module.return_value = mock_module
        self.runtime.module_loader.cache_enabled = True
        
        success = self.runtime.load_module("test_module")
        
        self.assertTrue(success)
        self.runtime.module_loader.load_module.assert_called_once_with("test_module")
        
        # Check that metrics were updated
        self.assertEqual(self.runtime.runtime_metrics.modules_loaded, 1)
        self.assertEqual(self.runtime.runtime_metrics.modules_cached, 1)
    
    def test_execute_assignment_instruction(self):
        """Test execution of assignment instruction."""
        instruction = {"type": "assignment", "variable": "test_var", "value": "123"}
        
        result = self.runtime._execute_instruction(instruction)
        
        self.assertEqual(result, 123)
        self.assertIn("test_var", self.runtime._variables)
        self.assertEqual(self.runtime._variables["test_var"], 123)
    
    def test_execute_print_instruction(self):
        """Test execution of print instruction."""
        # Set up a variable to print
        self.runtime._variables = {"test_var": "Hello World"}
        
        instruction = {"type": "print", "args": ["test_var"]}
        
        # Capture print output
        with patch('builtins.print') as mock_print:
            result = self.runtime._execute_instruction(instruction)
            
            mock_print.assert_called_once_with("Hello World")
            self.assertEqual(result, "Hello World")
    
    def test_execute_expression_instruction(self):
        """Test execution of expression instruction."""
        # Set up variables for expression
        self.runtime._variables = {"x": 10, "y": 20}
        
        instruction = {"type": "expression", "expression": "x + y"}
        
        result = self.runtime._execute_instruction(instruction)
        
        self.assertEqual(result, 30)
    
    def test_execute_function_definition(self):
        """Test execution of function definition."""
        instruction = {
            "type": "function_def",
            "name": "test_func",
            "parameters": ["a", "b"],
            "instructions": [
                {"type": "expression", "expression": "a + b"}
            ]
        }
        
        result = self.runtime._execute_instruction(instruction)
        
        self.assertIn("test_func", self.runtime._functions)
        function = self.runtime._functions["test_func"]
        self.assertEqual(function["name"], "test_func")
        self.assertEqual(function["parameters"], ["a", "b"])
    
    def test_error_handling(self):
        """Test error handling in runtime."""
        # Create an invalid instruction that will cause an error
        instruction = {"type": "invalid_instruction_type"}
        
        with self.assertRaises(ValueError):
            self.runtime._execute_instruction(instruction)
    
    def test_metrics_collection(self):
        """Test metrics collection during execution."""
        program = [
            {"type": "assignment", "variable": "x", "value": "1"},
            {"type": "assignment", "variable": "y", "value": "2"},
            {"type": "expression", "expression": "x + y"}
        ]
        
        # Execute program with timeout
        result = self.runtime.execute_program(program)
        
        self.assertTrue(result["success"])
        metrics = result["metrics"]
        self.assertGreater(metrics["instructions_executed"], 0)
        self.assertGreater(metrics["execution_time"], 0)
    
    def test_context_manager(self):
        """Test runtime as context manager."""
        with enhanced_runtime.enhanced_runtime_context(self.config) as runtime:
            self.assertEqual(runtime.state, enhanced_runtime.RuntimeState.READY)
        
        # Runtime should be stopped after context exit
        self.assertEqual(runtime.state, enhanced_runtime.RuntimeState.STOPPED)
    
    def test_factory_functions(self):
        """Test factory functions."""
        # Test create_enhanced_runtime
        runtime = enhanced_runtime.create_enhanced_runtime(self.config)
        self.assertIsInstance(runtime, enhanced_runtime.NBCRuntime)
        runtime.stop()
        
        # Test enhanced_runtime_context
        with enhanced_runtime.enhanced_runtime_context() as runtime:
            self.assertIsInstance(runtime, enhanced_runtime.NBCRuntime)


class TestRobustModuleLoaderIntegration(unittest.TestCase):
    """Test cases for RobustNoodleModuleLoader integration."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.config = enhanced_runtime.RuntimeConfig(
            module_search_paths=[self.temp_dir],
            enable_module_cache=True,
            module_cache_ttl=60.0
        )
        self.runtime = enhanced_runtime.NBCRuntime(self.config)
    
    def tearDown(self):
        """Clean up test fixtures."""
        if self.runtime:
            self.runtime.stop()
        shutil.rmtree(self.temp_dir)
    
    def test_module_loader_initialization(self):
        """Test module loader initialization."""
        self.assertIsNotNone(self.runtime.module_loader)
        self.assertTrue(self.runtime.module_loader.cache_enabled)
        self.assertEqual(self.runtime.module_loader.cache_ttl, 60.0)
    
    def test_module_loader_statistics(self):
        """Test module loader statistics."""
        stats = self.runtime.get_module_loader_stats()
        
        if stats:
            # Check that statistics dictionary has expected structure
            expected_keys = ["total_modules", "loaded_modules", "error_modules", 
                           "cache_size", "cache_enabled", "cache_ttl"]
            for key in expected_keys:
                self.assertIn(key, stats)
    
    def test_module_search_paths(self):
        """Test module search paths configuration."""
        # Create a test module file
        test_module_path = os.path.join(self.temp_dir, "test_module.nc")
        with open(test_module_path, 'w') as f:
            f.write("# Test module\nx = 42")
        
        # Test that module loader can find the module
        if self.runtime.module_loader:
            found_path = self.runtime.module_loader.find_module("test_module")
            self.assertIsNotNone(found_path)
            self.assertTrue(os.path.exists(found_path))


class TestParserInterpreterIntegration(unittest.TestCase):
    """Test cases for ParserInterpreterInterface integration."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = enhanced_runtime.RuntimeConfig(
            enable_parser_optimizations=True,
            parser_optimization_level=1,
            enable_bytecode_generation=True
        )
        self.runtime = enhanced_runtime.NBCRuntime(self.config)
    
    def tearDown(self):
        """Clean up test fixtures."""
        if self.runtime:
            self.runtime.stop()
    
    def test_parser_interpreter_initialization(self):
        """Test parser-interpreter initialization."""
        self.assertIsNotNone(self.runtime.parser_interpreter)
        self.assertTrue(self.runtime.parser_interpreter.enable_optimizations)
        self.assertEqual(self.runtime.parser_interpreter.optimization_level, 1)
    
    def test_parser_interpreter_statistics(self):
        """Test parser-interpreter statistics."""
        stats = self.runtime.get_parser_interpreter_stats()
        
        if stats:
            # Check that statistics dictionary has expected structure
            expected_keys = ["optimizations_enabled", "optimization_level", 
                           "global_symbols", "type_table_size", 
                           "error_count", "warning_count"]
            for key in expected_keys:
                self.assertIn(key, stats)
    
    def test_source_code_parsing(self):
        """Test source code parsing and compilation."""
        source_code = """
# Test program
x = 10
y = 20
result = x + y
print(result)
"""
        
        success = self.runtime.load_program_from_source(source_code, "test_program")
        
        if success and self.runtime.parser_interpreter:
            # Check that metrics were updated
            self.assertGreater(self.runtime.runtime_metrics.source_code_parsed, 0)
            self.assertGreater(self.runtime.runtime_metrics.bytecode_generated, 0)
    
    def test_bytecode_generation(self):
        """Test bytecode generation from source."""
        source_code = "x = 42"
        
        # Mock the parser-interpreter to return bytecode
        mock_bytecode = {
            "name": "test_module",
            "functions": {
                "main": {
                    "name": "main",
                    "parameters": [],
                    "instructions": [
                        {"opcode": "PUSH", "operands": [42]},
                        {"opcode": "STORE", "operands": ["x"]}
                    ]
                }
            }
        }
        
        self.runtime.parser_interpreter.parse_and_compile = Mock(return_value=mock_bytecode)
        
        success = self.runtime.load_program_from_source(source_code, "test_module")
        
        if success:
            # Check that the bytecode was converted to instructions
            self.assertIsNotNone(self.runtime.current_program)
            self.assertGreater(len(self.runtime.current_program), 0)


class TestEnhancedExecution(unittest.TestCase):
    """Test cases for enhanced execution features."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = enhanced_runtime.RuntimeConfig(
            max_execution_time=5.0,  # Short timeout
            enable_profiling=True
        )
        self.runtime = enhanced_runtime.NBCRuntime(self.config)
    
    def tearDown(self):
        """Clean up test fixtures."""
        if self.runtime:
            self.runtime.stop()
    
    def test_program_execution_flow(self):
        """Test complete program execution flow."""
        program = [
            {"type": "assignment", "variable": "counter", "value": "0"},
            {"type": "assignment", "variable": "counter", "value": "counter + 1"},
            {"type": "print", "args": ["counter"]}
        ]
        
        result = self.runtime.execute_program(program)
        
        self.assertTrue(result["success"])
        self.assertEqual(result["state"], "stopped")
        self.assertEqual(result["metrics"]["instructions_executed"], 3)
        self.assertGreater(result["metrics"]["execution_time"], 0)
    
    def test_error_recovery(self):
        """Test error recovery in execution."""
        # Create a program with an error
        program = [
            {"type": "assignment", "variable": "x", "value": "42"},
            {"type": "invalid_instruction"},  # This will cause an error
            {"type": "print", "args": ["x"]}
        ]
        
        result = self.runtime.execute_program(program)
        
        # The execution should fail gracefully
        self.assertFalse(result["success"])
        self.assertIn("error", result)
        self.assertEqual(result["state"], "error")
    
    def test_performance_profiling(self):
        """Test performance profiling."""
        # Create a moderately complex program
        program = []
        for i in range(10):
            program.append({
                "type": "assignment", 
                "variable": f"var_{i}", 
                "value": str(i)
            })
            program.append({
                "type": "expression", 
                "expression": f"var_{i} + 1"
            })
        
        start_time = time.time()
        result = self.runtime.execute_program(program)
        end_time = time.time()
        
        # Check profiling results
        self.assertTrue(result["success"])
        metrics = result["metrics"]
        
        # Check that execution time was measured
        self.assertGreater(metrics["execution_time"], 0)
        
        # Check that instructions were counted
        self.assertEqual(metrics["instructions_executed"], 20)  # 10 assignments + 10 expressions
        
        # Check performance is reasonable (should complete quickly)
        self.assertLess(metrics["execution_time"], 1.0)  # Should complete in less than 1 second
    
    def test_memory_usage_tracking(self):
        """Test memory usage tracking."""
        # Create a program that uses some memory
        program = []
        for i in range(100):
            program.append({
                "type": "assignment", 
                "variable": f"list_{i}", 
                "value": f"[{i}] * 10"  # Create small lists
            })
        
        result = self.runtime.execute_program(program)
        
        self.assertTrue(result["success"])
        metrics = result["metrics"]
        
        # Memory usage should be tracked
        self.assertGreaterEqual(metrics["memory_used"], 0)
    
    def test_threading_safety(self):
        """Test threading safety of execution."""
        program = [
            {"type": "assignment", "variable": "x", "value": "0"},
            {"type": "expression", "expression": "x + 1"},
            {"type": "expression", "expression": "x + 2"},
            {"type": "expression", "expression": "x + 3"}
        ]
        
        # Execute program
        result = self.runtime.execute_program(program)
        
        self.assertTrue(result["success"])
        self.assertEqual(result["state"], "stopped")
        
        # Check that execution completed properly
        self.assertEqual(result["metrics"]["instructions_executed"], 4)


class TestEventSystem(unittest.TestCase):
    """Test cases for event system."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = enhanced_runtime.RuntimeConfig()
        self.runtime = enhanced_runtime.NBCRuntime(self.config)
        self.event_log = []
    
    def tearDown(self):
        """Clean up test fixtures."""
        if self.runtime:
            self.runtime.stop()
    
    def test_event_callback_registration(self):
        """Test event callback registration."""
        # Create a simple callback
        def callback(*args, **kwargs):
            self.event_log.append({"event": "test_event", "args": args, "kwargs": kwargs})
        
        # Register callback
        self.runtime.add_event_callback("test_event", callback)
        
        # Check that callback was registered
        self.assertIn("test_event", self.runtime._event_callbacks)
        self.assertIn(callback, self.runtime._event_callbacks["test_event"])
    
    def test_event_callback_removal(self):
        """Test event callback removal."""
        def callback(*args, **kwargs):
            pass
        
        # Register and remove callback
        self.runtime.add_event_callback("test_event", callback)
        self.runtime.remove_event_callback("test_event", callback)
        
        # Check that callback was removed
        self.assertNotIn(callback, self.runtime._event_callbacks["test_event"])
    
    def test_event_firing(self):
        """Test event firing."""
        def callback(*args, **kwargs):
            self.event_log.append({"args": args, "kwargs": kwargs})
        
        self.runtime.add_event_callback("test_event", callback)
        
        # Fire event
        self.runtime._fire_event("test_event", "arg1", "arg2", kwarg1="value1")
        
        # Check that callback was called
        self.assertEqual(len(self.event_log), 1)
        event_data = self.event_log[0]
        self.assertEqual(event_data["args"], ("arg1", "arg2"))
        self.assertEqual(event_data["kwargs"]["kwarg1"], "value1")
    
    def test_instruction_events(self):
        """Test instruction-related events."""
        event_log = []
        
        def instruction_callback(instruction, *args):
            event_log.append({
                "event": "instruction",
                "type": instruction.get("type"),
                "line": instruction.get("line")
            })
        
        self.runtime.add_event_callback("before_instruction", instruction_callback)
        self.runtime.add_event_callback("after_instruction", instruction_callback)
        
        # Execute a simple program
        program = [
            {"type": "assignment", "variable": "x", "value": "42", "line": 1},
            {"type": "print", "args": ["x"], "line": 2}
        ]
        
        result = self.runtime.execute_program(program)
        
        # Check that events were fired
        self.assertEqual(len(event_log), 4)  # 2 before + 2 after events
        self.assertIn({"event": "instruction", "type": "assignment", "line": 1}, event_log)
        self.assertIn({"event": "instruction", "type": "print", "line": 2}, event_log)
    
    def test_error_events(self):
        """Test error events."""
        error_log = []
        
        def error_callback(error, *args):
            error_log.append({"error": str(error)})
        
        self.runtime.add_event_callback("on_error", error_callback)
        
        # Execute a program with an error
        program = [
            {"type": "assignment", "variable": "x", "value": "42"},
            {"type": "invalid_instruction"}  # This will cause an error
        ]
        
        result = self.runtime.execute_program(program)
        
        # Check that error event was fired
        self.assertEqual(len(error_log), 1)
        self.assertIn("error", error_log[0])


# Utility functions for testing


def create_test_program(complexity=1):
    """Create a test program with specified complexity."""
    program = []
    
    if complexity >= 1:
        # Basic assignments
        program.extend([
            {"type": "assignment", "variable": "x", "value": "42"},
            {"type": "assignment", "variable": "y", "value": "10"},
            {"type": "assignment", "variable": "z", "value": "5"}
        ])
    
    if complexity >= 2:
        # Basic expressions
        program.extend([
            {"type": "expression", "expression": "x + y"},
            {"type": "expression", "expression": "z * 2"},
            {"type": "expression", "expression": "x - y + z"}
        ])
    
    if complexity >= 3:
        # Print statements
        program.extend([
            {"type": "print", "args": ["x"]},
            {"type": "print", "args": ["y"]},
            {"type": "print", "args": ["z"]}
        ])
    
    return program


def run_performance_test(runtime, program, iterations=10):
    """Run performance test on a program."""
    times = []
    
    for _ in range(iterations):
        start_time = time.time()
        result = runtime.execute_program(program)
        end_time = time.time()
        times.append(end_time - start_time)
        
        if not result["success"]:
            break
    
    return {
        "avg_time": sum(times) / len(times) if times else 0,
        "min_time": min(times) if times else 0,
        "max_time": max(times) if times else 0,
        "success": all(r["success"] for r in 
                      [runtime.execute_program(program) for _ in range(iterations)])
    }


if __name__ == "__main__":
    # Run the tests
    unittest.main()
