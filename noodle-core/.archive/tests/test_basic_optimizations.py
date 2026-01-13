#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_basic_optimizations.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Basic test for advanced optimizations to verify core functionality
"""

import os
import sys
import tempfile
import unittest

# Add the noodle-core source directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.advanced_optimizations import (
    AdvancedOptimizationConfig, OptimizationLevel, CompilerMetrics,
    ProfileGuidedOptimizer, IncrementalCompilationCache,
    FunctionInliningPass, LoopOptimizationPass, AdvancedDeadCodeEliminationPass,
    AdvancedConstantFoldingPass, ParallelCompilationManager, MemoryOptimizer,
    SecureCompilationValidator, AdvancedOptimizationPipeline,
    create_advanced_optimization_config, create_advanced_optimization_pipeline
)

from noodlecore.compiler.ast_nodes import (
    EnhancedProgramNode, EnhancedFunctionDefinitionNode, EnhancedBinaryExpressionNode,
    EnhancedLiteralNode, EnhancedFunctionCallNode, EnhancedLetStatementNode,
    EnhancedForStatementNode, EnhancedWhileStatementNode, EnhancedIdentifierNode,
    NodeType, SourceLocation, create_enhanced_ast_node_factory
)


class TestBasicOptimizations(unittest.TestCase):
    """Basic test cases for advanced optimizations"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.config = AdvancedOptimizationConfig()
        self.factory = create_enhanced_ast_node_factory()
        self.location = SourceLocation("test", 1, 1, 0)
    
    def test_config_creation(self):
        """Test configuration creation"""
        config = create_advanced_optimization_config()
        self.assertIsInstance(config, AdvancedOptimizationConfig)
        self.assertEqual(config.optimization_level, OptimizationLevel.BALANCED)
        self.assertTrue(config.enable_function_inlining)
        self.assertTrue(config.enable_loop_optimizations)
        self.assertTrue(config.enable_dead_code_elimination)
        self.assertTrue(config.enable_constant_folding)
    
    def test_profile_optimizer(self):
        """Test profile optimizer"""
        config = AdvancedOptimizationConfig(enable_profile_guided_opt=True)
        optimizer = ProfileGuidedOptimizer(config)
        self.assertIsInstance(optimizer, ProfileGuidedOptimizer)
        self.assertEqual(len(optimizer.function_profiles), 0)
    
    def test_cache_operations(self):
        """Test cache operations"""
        with tempfile.TemporaryDirectory() as temp_dir:
            config = AdvancedOptimizationConfig(cache_directory=temp_dir)
            cache = IncrementalCompilationCache(config)
            
            # Test file hash calculation
            test_file = os.path.join(temp_dir, "test.txt")
            with open(test_file, 'w') as f:
                f.write("test content")
            
            hash1 = cache.get_file_hash(test_file)
            hash2 = cache.get_file_hash(test_file)
            self.assertEqual(hash1, hash2)
            self.assertTrue(hash1 != "")
            
            # Test file change detection
            self.assertFalse(cache.is_file_changed(test_file))
            cache.update_file_hash(test_file)
            self.assertFalse(cache.is_file_changed(test_file))
            
            # Test cache operations
            test_data = b"test data"
            cache.cache_module(test_file, test_data)
            cached_data = cache.get_cached_module(test_file)
            self.assertEqual(cached_data, test_data)
    
    def test_optimization_passes(self):
        """Test optimization passes"""
        config = AdvancedOptimizationConfig()
        
        # Test function inlining pass
        inlining_pass = FunctionInliningPass(None, config)
        self.assertIsInstance(inlining_pass, FunctionInliningPass)
        
        # Test loop optimization pass
        loop_pass = LoopOptimizationPass(None, config)
        self.assertIsInstance(loop_pass, LoopOptimizationPass)
        
        # Test dead code elimination pass
        dce_pass = AdvancedDeadCodeEliminationPass(None, config)
        self.assertIsInstance(dce_pass, AdvancedDeadCodeEliminationPass)
        
        # Test constant folding pass
        cf_pass = AdvancedConstantFoldingPass(None, config)
        self.assertIsInstance(cf_pass, AdvancedConstantFoldingPass)
    
    def test_parallel_compilation(self):
        """Test parallel compilation"""
        config = AdvancedOptimizationConfig(enable_parallel_compilation=True)
        manager = ParallelCompilationManager(config)
        self.assertIsInstance(manager, ParallelCompilationManager)
        
        # Test compilation
        modules = [("module1", "content1"), ("module2", "content2")]
        results = manager.compile_parallel(modules)
        self.assertEqual(len(results), 2)
        self.assertIn("Compiled: module1", results)
        self.assertIn("Compiled: module2", results)
    
    def test_memory_optimizer(self):
        """Test memory optimizer"""
        config = AdvancedOptimizationConfig(enable_memory_optimization=True)
        optimizer = MemoryOptimizer(config)
        self.assertIsInstance(optimizer, MemoryOptimizer)
        
        # Test memory monitoring
        optimizer.start_monitoring()
        current, peak = optimizer.get_memory_usage()
        self.assertGreaterEqual(current, 0)
        self.assertGreaterEqual(peak, 0)
    
    def test_security_validator(self):
        """Test security validator"""
        config = AdvancedOptimizationConfig(enable_security_validation=True)
        validator = SecureCompilationValidator(config)
        self.assertIsInstance(validator, SecureCompilationValidator)
        
        # Test validation
        self.assertTrue(validator.validate_source_code("let x = 42;", "test.txt"))
        self.assertEqual(validator.validations, 1)
    
    def test_optimization_pipeline(self):
        """Test optimization pipeline"""
        config = AdvancedOptimizationConfig(
            enable_function_inlining=True,
            enable_loop_optimizations=True,
            enable_dead_code_elimination=True,
            enable_constant_folding=True
        )
        
        pipeline = create_advanced_optimization_pipeline(config)
        self.assertIsInstance(pipeline, AdvancedOptimizationPipeline)
        
        # Test optimization
        ast = EnhancedProgramNode([], self.location)
        optimized_ast = pipeline.optimize(ast)
        self.assertIsInstance(optimized_ast, EnhancedProgramNode)
        
        # Test metrics
        metrics = pipeline.get_metrics()
        self.assertIsInstance(metrics, CompilerMetrics)


def run_basic_tests():
    """Run basic optimization tests"""
    # Create test suite
    suite = unittest.TestSuite()
    
    # Add test cases
    test_classes = [
        TestBasicOptimizations
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        suite.addTests(tests)
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return success status
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_basic_tests()
    sys.exit(0 if success else 1)

