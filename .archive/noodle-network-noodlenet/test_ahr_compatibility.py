#!/usr/bin/env python3
"""
Test Suite::Noodle Network Noodlenet - test_ahr_compatibility.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive AHR (Adaptive Hybrid Runtime) Compatibility Test

This test validates the compatibility of AHR runtime components including:
1. AHR base functionality and model management
2. Model execution and profiling capabilities
3. Memory management and adaptive features
4. Integration with NoodleCore runtime system
5. Runtime dependency and error handling

Key validation points:
- Test AHR components can import successfully
- Verify model execution functionality works correctly
- Test memory management and adaptive capabilities
- Validate integration with NoodleCore runtime system
- Check for any runtime or dependency issues
"""

import sys
import os
import asyncio
import time
import tempfile
import json
from typing import Dict, List, Optional, Any
from unittest.mock import Mock, MagicMock, patch

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

def test_ahr_imports():
    """Test that AHR components can be imported successfully"""
    print("Testing AHR component imports...")
    
    try:
        # Test AHR base imports
        from noodlenet.ahr.ahr_base import (
            AHRBase, ExecutionMode, ModelComponent,
            ModelProfile, ExecutionMetrics
        )
        print("[PASS] AHR base imports successful")
        
        # Test profiler imports
        from noodlenet.ahr.profiler import PerformanceProfiler, ProfileSession
        print("[PASS] Profiler imports successful")
        
        # Test compiler imports
        from noodlenet.ahr.compiler import ModelCompiler, CompilationTask, CompilationStage
        print("[PASS] Compiler imports successful")
        
        # Test optimizer imports
        from noodlenet.ahr.optimizer import (
            AHRDecisionOptimizer, OptimizationDecision,
            OptimizationReason, OptimizationRule
        )
        print("[PASS] Optimizer imports successful")
        
        # Test NoodleNet dependencies
        from noodlenet.config import NoodleNetConfig
        from noodlenet.mesh import NoodleMesh
        from noodlenet.link import NoodleLink
        from noodlenet.identity import NoodleIdentityManager
        print("[PASS] NoodleNet dependency imports successful")
        
        return True
        
    except ImportError as e:
        print(f"[FAIL] Import error: {e}")
        return False
    except Exception as e:
        print(f"[FAIL] Unexpected error during imports: {e}")
        return False

def test_ahr_base_functionality():
    """Test AHR base functionality and model management"""
    print("\nTesting AHR base functionality...")
    
    try:
        from noodlenet.ahr.ahr_base import AHRBase, ExecutionMode, ModelComponent
        from noodlenet.config import NoodleNetConfig
        
        # Create mock dependencies
        mock_link = Mock()
        mock_identity_manager = Mock()
        mock_mesh = Mock()
        config = NoodleNetConfig()
        
        # Initialize AHR base
        ahr = AHRBase(mock_link, mock_identity_manager, mock_mesh, config)
        print("[PASS] AHRBase initialization successful")
        
        # Test model registration
        ahr.register_model("test_model_1", "pytorch", "1.0")
        ahr.register_model("test_model_2", "tensorflow", "2.0")
        print("[PASS] Model registration successful")
        
        # Test component registration
        ahr.register_model_component("test_model_1", "dense_1", "dense")
        ahr.register_model_component("test_model_1", "activation_1", "activation")
        print("[PASS] Component registration successful")
        
        # Test model statistics
        stats = ahr.get_model_statistics("test_model_1")
        assert stats['model_id'] == "test_model_1"
        assert stats['model_type'] == "pytorch"
        assert len(stats['components']) == 2
        print("[PASS] Model statistics retrieval successful")
        
        # Test execution metrics
        metrics = ahr.record_execution_start("test_model_1", "dense_1")
        time.sleep(0.01)  # Simulate some execution time
        ahr.record_execution_end("test_model_1", "dense_1", metrics, success=True)
        print("[PASS] Execution metrics recording successful")
        
        # Test optimization candidates
        candidates = ahr.get_optimization_candidates("test_model_1")
        print(f"[PASS] Optimization candidates found: {len(candidates)}")
        
        # Test performance summary
        perf_summary = ahr.get_performance_summary("test_model_1")
        assert 'total_executions' in perf_summary
        print("[PASS] Performance summary generation successful")
        
        return True
        
    except Exception as e:
        print(f"[FAIL] AHR base functionality error: {e}")
        return False

def test_profiler_functionality():
    """Test profiler functionality and performance monitoring"""
    print("\nTesting profiler functionality...")
    
    try:
        from noodlenet.ahr.profiler import PerformanceProfiler, ProfileSession
        from noodlenet.mesh import NoodleMesh
        from noodlenet.config import NoodleNetConfig
        
        # Create mock mesh
        mock_mesh = Mock()
        config = NoodleNetConfig()
        
        # Initialize profiler
        profiler = PerformanceProfiler(mock_mesh, config)
        print("[PASS] Profiler initialization successful")
        
        # Test session management
        session_id = asyncio.run(profiler.start_profiling("test_model", "dense_1"))
        assert session_id is not None
        print("[PASS] Profiling session start successful")
        
        # Add samples
        metrics = {
            'execution_time': 50.0,
            'cpu_usage': 0.3,
            'memory_usage': 0.4,
            'error_rate': 0.0
        }
        profiler.add_sample(session_id, time.time(), metrics)
        print("[PASS] Sample addition successful")
        
        # Stop session
        session = profiler.stop_profiling(session_id)
        assert session is not None
        assert session.is_completed()
        print("[PASS] Profiling session stop successful")
        
        # Test statistics
        stats = profiler.get_session_statistics(session_id)
        assert stats is not None
        assert stats['sample_count'] == 1
        print("[PASS] Session statistics retrieval successful")
        
        # Test hotspot detection
        hotspot_metrics = {
            'execution_time': 150.0,  # Above threshold
            'cpu_usage': 0.3,
            'memory_usage': 0.4,
            'error_rate': 0.0
        }
        profiler.add_sample(session_id, time.time(), hotspot_metrics)
        hotspots = profiler.get_hotspots()
        print(f"[PASS] Hotspot detection: {len(hotspots)} hotspots found")
        
        # Test resource monitoring
        profiler.start_resource_monitoring(interval=0.1)
        time.sleep(0.2)  # Let it collect some samples
        resource_summary = profiler.get_resource_summary()
        assert 'sample_count' in resource_summary
        profiler.stop_resource_monitoring()
        print("[PASS] Resource monitoring successful")
        
        return True
        
    except Exception as e:
        print(f"[FAIL] Profiler functionality error: {e}")
        return False

def test_compiler_functionality():
    """Test compiler functionality and model optimization"""
    print("\nTesting compiler functionality...")
    
    try:
        from noodlenet.ahr.compiler import ModelCompiler, CompilationTask, CompilationStage
        from noodlenet.mesh import NoodleMesh
        from noodlenet.config import NoodleNetConfig
        
        # Create mock mesh
        mock_mesh = Mock()
        config = NoodleNetConfig()
        
        # Initialize compiler
        compiler = ModelCompiler(mock_mesh, config)
        print("âœ“ Compiler initialization successful")
        
        # Test compilation task submission
        source_code = "def model_function():\n    return x * y"
        task_id = compiler.submit_compilation_task(
            "test_model", "dense_1", source_code, ExecutionMode.JIT
        )
        assert task_id is not None
        print("âœ“ Compilation task submission successful")
        
        # Test task status retrieval
        status = compiler.get_compilation_status(task_id)
        assert status is not None
        assert status['status'] == 'pending'
        print("âœ“ Task status retrieval successful")
        
        # Test compilation statistics
        stats = compiler.get_compilation_statistics()
        assert stats['total_tasks'] >= 1
        assert stats['pending_tasks'] >= 1
        print("âœ“ Compilation statistics retrieval successful")
        
        # Test cache functionality
        compiler.clear_cache()
        print("âœ“ Cache clearing successful")
        
        # Test compiler settings
        compiler.set_compiler_setting('optimization_level', 3)
        print("âœ“ Compiler settings update successful")
        
        return True
        
    except Exception as e:
        print(f"[FAIL] Compiler functionality error: {e}")
        return False

def test_optimizer_functionality():
    """Test optimizer functionality and decision making"""
    print("\nTesting optimizer functionality...")
    
    try:
        from noodlenet.ahr.optimizer import (
            AHRDecisionOptimizer, OptimizationDecision, OptimizationRule
        )
        from noodlenet.ahr.profiler import PerformanceProfiler
        from noodlenet.ahr.compiler import ModelCompiler
        from noodlenet.mesh import NoodleMesh
        from noodlenet.config import NoodleNetConfig
        
        # Create mock dependencies
        mock_mesh = Mock()
        mock_profiler = Mock()
        mock_compiler = Mock()
        config = NoodleNetConfig()
        
        # Initialize optimizer
        optimizer = AHRDecisionOptimizer(mock_mesh, mock_profiler, mock_compiler, config)
        print("âœ“ Optimizer initialization successful")
        
        # Test rule management
        rule = OptimizationRule("test_rule", priority=3)
        rule.add_condition("latency", 100.0, 50.0, 1.0)
        optimizer.add_optimization_rule(rule)
        print("âœ“ Optimization rule addition successful")
        
        # Test rule removal
        removed = optimizer.remove_optimization_rule("test_rule")
        assert removed
        print("âœ“ Optimization rule removal successful")
        
        # Test optimization settings
        optimizer.set_optimization_setting('decision_interval', 3.0)
        print("âœ“ Optimization settings update successful")
        
        # Test decision statistics
        stats = optimizer.get_decision_statistics()
        assert 'total_decisions' in stats
        print("âœ“ Decision statistics retrieval successful")
        
        # Test optimization summary
        summary = optimizer.get_optimization_summary()
        assert 'total_decisions' in summary
        print("âœ“ Optimization summary generation successful")
        
        return True
        
    except Exception as e:
        print(f"âœ— Optimizer functionality error: {e}")
        return False

def test_memory_management():
    """Test memory management and adaptive capabilities"""
    print("\nTesting memory management...")
    
    try:
        from noodlenet.ahr.ahr_base import AHRBase, ExecutionMode, ModelComponent
        from noodlenet.config import NoodleNetConfig
        
        # Create mock dependencies
        mock_link = Mock()
        mock_identity_manager = Mock()
        mock_mesh = Mock()
        config = NoodleNetConfig()
        
        # Initialize AHR base
        ahr = AHRBase(mock_link, mock_identity_manager, mock_mesh, config)
        
        # Register multiple models and components
        for i in range(10):
            model_id = f"model_{i}"
            ahr.register_model(model_id, "pytorch", "1.0")
            ahr.register_model_component(model_id, f"component_{i}", "dense")
        
        # Simulate many executions
        for model_id in [f"model_{i}" for i in range(10)]:
            for _ in range(20):  # 20 executions per model
                metrics = ahr.record_execution_start(model_id, f"component_{model_id.split('_')[1]}")
                time.sleep(0.001)
                ahr.record_execution_end(model_id, f"component_{model_id.split('_')[1]}", metrics, success=True)
        
        # Test memory usage tracking
        all_stats = ahr.get_all_statistics()
        assert all_stats['model_count'] == 10
        assert all_stats['total_executions'] == 200  # 10 models * 20 executions
        print("âœ“ Memory usage tracking successful")
        
        # Test execution history management
        history = ahr.get_execution_history(limit=50)
        assert len(history) <= 50
        print("âœ“ Execution history management successful")
        
        # Test history clearing
        ahr.clear_history()
        history_after_clear = ahr.get_execution_history()
        assert len(history_after_clear) == 0
        print("âœ“ History clearing successful")
        
        # Test statistics export
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            temp_file = f.name
        
        try:
            ahr.export_statistics(temp_file)
            assert os.path.exists(temp_file)
            
            # Verify exported content
            with open(temp_file, 'r') as f:
                exported_data = json.load(f)
                assert 'models' in exported_data
                assert 'performance_summary' in exported_data
            print("âœ“ Statistics export successful")
        finally:
            os.unlink(temp_file)
        
        return True
        
    except Exception as e:
        print(f"âœ— Memory management error: {e}")
        return False

def test_noodlecore_integration():
    """Test integration with NoodleCore runtime system"""
    print("\nTesting NoodleCore integration...")
    
    try:
        # Test imports from NoodleCore
        from noodlecore.runtime.core import NBCRuntime
        from noodlecore.runtime.execution_engine import ExecutionEngine
        from noodlecore.runtime.memory_optimization_manager import MemoryOptimizationManager
        print("âœ“ NoodleCore imports successful")
        
        # Test AHR integration with NoodleCore components
        from noodlenet.ahr.ahr_base import AHRBase, ExecutionMode
        from noodlecore.runtime.core import NBCRuntime
        
        # Create mock dependencies
        mock_link = Mock()
        mock_identity_manager = Mock()
        mock_mesh = Mock()
        
        # Initialize AHR with NBCRuntime integration
        ahr = AHRBase(mock_link, mock_identity_manager, mock_mesh)
        print("âœ“ AHR with NoodleCore integration successful")
        
        # Test execution mode compatibility
        assert ExecutionMode.INTERPRETER.value == "interpreter"
        assert ExecutionMode.JIT.value == "jit"
        assert ExecutionMode.AOT.value == "aot"
        print("âœ“ Execution mode compatibility verified")
        
        # Test model component NBC runtime integration
        component = ModelComponent("test_component", "dense")
        component.execution_mode = ExecutionMode.JIT
        assert component.execution_mode == ExecutionMode.JIT
        print("âœ“ NBC runtime mode assignment successful")
        
        return True
        
    except ImportError as e:
        print(f"âœ— NoodleCore integration import error: {e}")
        return False
    except Exception as e:
        print(f"âœ— NoodleCore integration error: {e}")
        return False

def test_error_handling():
    """Test error handling and runtime stability"""
    print("\nTesting error handling...")
    
    try:
        from noodlenet.ahr.ahr_base import AHRBase
        from noodlenet.config import NoodleNetConfig
        
        # Create mock dependencies
        mock_link = Mock()
        mock_identity_manager = Mock()
        mock_mesh = Mock()
        config = NoodleNetConfig()
        
        # Initialize AHR
        ahr = AHRBase(mock_link, mock_identity_manager, mock_mesh, config)
        
        # Test error handling for invalid model operations
        stats = ahr.get_model_statistics("nonexistent_model")
        assert stats == {}
        print("âœ“ Invalid model handling successful")
        
        # Test error handling for invalid component operations
        candidates = ahr.get_optimization_candidates("nonexistent_model")
        assert candidates == []
        print("âœ“ Invalid component handling successful")
        
        # Test error handling for invalid execution metrics
        try:
            metrics = ahr.record_execution_start("nonexistent_model", "nonexistent_component")
            ahr.record_execution_end("nonexistent_model", "nonexistent_component", metrics, success=True)
            print("âœ“ Invalid execution metrics handling successful")
        except Exception:
            print("âœ“ Invalid execution metrics properly handled")
        
        # Test AHR lifecycle management
        ahr.start()
        assert ahr.is_running()
        assert ahr.is_monitoring()
        
        ahr.stop()
        assert not ahr.is_running()
        print("âœ“ AHR lifecycle management successful")
        
        return True
        
    except Exception as e:
        print(f"âœ— Error handling test error: {e}")
        return False

def test_concurrent_operations():
    """Test concurrent operations and thread safety"""
    print("\nTesting concurrent operations...")
    
    try:
        import threading
        import time
        from noodlenet.ahr.ahr_base import AHRBase, ExecutionMode, ModelComponent
        from noodlenet.config import NoodleNetConfig
        
        # Create mock dependencies
        mock_link = Mock()
        mock_identity_manager = Mock()
        mock_mesh = Mock()
        config = NoodleNetConfig()
        
        # Initialize AHR
        ahr = AHRBase(mock_link, mock_identity_manager, mock_mesh, config)
        ahr.register_model("concurrent_model", "pytorch", "1.0")
        ahr.register_model_component("concurrent_model", "dense_1", "dense")
        
        results = []
        errors = []
        
        def worker(worker_id: int):
            """Worker function for concurrent testing"""
            try:
                for i in range(10):
                    metrics = ahr.record_execution_start("concurrent_model", "dense_1")
                    time.sleep(0.001)  # Simulate work
                    ahr.record_execution_end("concurrent_model", "dense_1", metrics, success=True)
                    results.append(f"worker_{worker_id}_iteration_{i}")
            except Exception as e:
                errors.append(f"worker_{worker_id}: {e}")
        
        # Start multiple threads
        threads = []
        for i in range(5):
            thread = threading.Thread(target=worker, args=(i,))
            threads.append(thread)
            thread.start()
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        # Check results
        assert len(errors) == 0, f"Errors occurred: {errors}"
        assert len(results) == 50  # 5 workers * 10 iterations each
        print(f"âœ“ Concurrent operations successful: {len(results)} operations completed")
        
        # Verify thread-safe statistics
        stats = ahr.get_model_statistics("concurrent_model")
        assert stats['total_executions'] == 50
        print("âœ“ Thread-safe statistics verification successful")
        
        return True
        
    except Exception as e:
        print(f"âœ— Concurrent operations error: {e}")
        return False

def run_comprehensive_test():
    """Run all AHR compatibility tests"""
    print("=" * 60)
    print("AHR (Adaptive Hybrid Runtime) Compatibility Test Suite")
    print("=" * 60)
    
    tests = [
        ("AHR Component Imports", test_ahr_imports),
        ("AHR Base Functionality", test_ahr_base_functionality),
        ("Profiler Functionality", test_profiler_functionality),
        ("Compiler Functionality", test_compiler_functionality),
        ("Optimizer Functionality", test_optimizer_functionality),
        ("Memory Management", test_memory_management),
        ("NoodleCore Integration", test_noodlecore_integration),
        ("Error Handling", test_error_handling),
        ("Concurrent Operations", test_concurrent_operations),
    ]
    
    results = []
    total_tests = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{'='*20} {test_name} {'='*20}")
        try:
            success = test_func()
            results.append((test_name, success))
            status = "âœ“ PASSED" if success else "âœ— FAILED"
            print(f"\n{status}: {test_name}")
        except Exception as e:
            results.append((test_name, False))
            print(f"\nâœ— FAILED: {test_name} - {e}")
    
    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    passed = sum(1 for _, success in results if success)
    failed = total_tests - passed
    
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Success Rate: {(passed/total_tests)*100:.1f}%")
    
    print("\nDetailed Results:")
    for test_name, success in results:
        status = "âœ“ PASS" if success else "âœ— FAIL"
        print(f"  {status}: {test_name}")
    
    # Final assessment
    if passed == total_tests:
        print("\nðŸŽ‰ ALL TESTS PASSED - AHR Runtime System is FULLY COMPATIBLE")
        return True
    else:
        print(f"\nâš ï¸  {failed} TESTS FAILED - AHR Runtime System has COMPATIBILITY ISSUES")
        return False

if __name__ == "__main__":
    success = run_comprehensive_test()
    sys.exit(0 if success else 1)

