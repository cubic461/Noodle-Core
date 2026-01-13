#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ml_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Integration Tests for ML Infrastructure Components

This module provides comprehensive integration tests for the Phase 2.3 ML infrastructure
components including MLModelRegistry, NeuralNetworkFactory, DataPreprocessor,
MLInferenceEngine, and MLConfigurationManager.
"""

import os
import sys
import time
import tempfile
import unittest
import logging
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.ml_configuration_manager import MLConfigurationManager
from noodlecore.ai_agents.ml_model_registry import MLModelRegistry, ModelType, ModelStatus
from noodlecore.ai_agents.neural_network_factory import NeuralNetworkFactory
from noodlecore.ai_agents.data_preprocessor import DataPreprocessor
from noodlecore.ai_agents.ml_inference_engine import MLInferenceEngine, InferenceResult
from noodlecore.ai_agents.ml_enhanced_syntax_fixer import MLEnhancedSyntaxFixer

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TestMLConfigurationManager(unittest.TestCase):
    """Test cases for MLConfigurationManager."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.config_file = os.path.join(self.temp_dir, 'test_config.json')
        
        # Create test configuration
        test_config = {
            "advanced_ml_enabled": True,
            "default_model_type": "transformer",
            "model_registry": {
                "enabled": True,
                "model_path": "./test_models",
                "batch_size": 16,
                "inference_timeout_ms": 3000,
                "cache_size": 50,
                "min_confidence_threshold": 0.7
            },
            "federated_learning": {
                "enabled": False,
                "privacy_level": "high"
            },
            "predictive_fixing": {
                "enabled": True,
                "confidence_threshold": 0.8
            }
        }
        
        import json
        with open(self.config_file, 'w') as f:
            json.dump(test_config, f)
    
    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def test_initialization(self):
        """Test configuration manager initialization."""
        # Test with file
        config_manager = MLConfigurationManager(self.config_file)
        self.assertTrue(config_manager.is_advanced_ml_enabled())
        self.assertEqual(config_manager.get_model_type(), "transformer")
        self.assertEqual(config_manager.get_batch_size(), 16)
        self.assertEqual(config_manager.get_confidence_threshold(), 0.8)
        
        # Test environment variable override
        os.environ['NOODLE_SYNTAX_FIXER_ADVANCED_ML'] = 'false'
        config_manager_env = MLConfigurationManager()
        self.assertFalse(config_manager_env.is_advanced_ml_enabled())
        
        # Clean up
        del os.environ['NOODLE_SYNTAX_FIXER_ADVANCED_ML']
    
    def test_configuration_updates(self):
        """Test configuration updates."""
        config_manager = MLConfigurationManager(self.config_file)
        
        # Test configuration update
        updates = {
            "model_registry": {
                "batch_size": 32
            },
            "predictive_fixing": {
                "confidence_threshold": 0.9
            }
        }
        
        success = config_manager.update_config(updates)
        self.assertTrue(success)
        self.assertEqual(config_manager.get_batch_size(), 32)
        self.assertEqual(config_manager.get_confidence_threshold(), 0.9)
    
    def test_configuration_validation(self):
        """Test configuration validation."""
        config_manager = MLConfigurationManager()
        
        # Test invalid configuration
        invalid_updates = {
            "model_registry": {
                "batch_size": -1  # Invalid negative value
            }
        }
        
        success = config_manager.update_config(invalid_updates)
        self.assertFalse(success)  # Should fail validation
        
        # Test valid configuration
        valid_updates = {
            "model_registry": {
                "batch_size": 64  # Valid positive value
            }
        }
        
        success = config_manager.update_config(valid_updates)
        self.assertTrue(success)  # Should pass validation

class TestDataPreprocessor(unittest.TestCase):
    """Test cases for DataPreprocessor."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config_manager = MLConfigurationManager()
        self.preprocessor = DataPreprocessor(self.config_manager)
        
        # Sample test data
        self.test_code = """
def calculate_sum(a, b):
    # Calculate the sum of two numbers
    result = a + b
    return result

def main():
    x = 10
    y = 20
    sum_result = calculate_sum(x, y)
    print(f"The sum is: {sum_result}")
    return sum_result
"""
        self.test_python_code = "def test_function():\n    return 'hello world'\n"
        self.test_javascript_code = "function test() {\n    return 'hello world';\n}"
    
    def test_language_detection(self):
        """Test programming language detection."""
        # Test Python detection
        language = self.preprocessor.language_detector.detect_language(self.test_python_code, '.py')
        self.assertEqual(language, 'python')
        
        # Test JavaScript detection
        language = self.preprocessor.language_detector.detect_language(self.test_javascript_code, '.js')
        self.assertEqual(language, 'javascript')
        
        # Test unknown detection
        unknown_code = "some random code without clear patterns"
        language = self.preprocessor.language_detector.detect_language(unknown_code)
        self.assertEqual(language, 'unknown')
    
    def test_tokenization(self):
        """Test code tokenization."""
        # Build vocabulary
        texts = [self.test_python_code, self.test_javascript_code]
        self.preprocessor.build_vocabulary(texts)
        
        # Test tokenization
        tokens = self.preprocessor.tokenizer.tokenize(self.test_python_code)
        self.assertIsInstance(tokens, list)
        self.assertGreater(len(tokens), 0)
        
        # Test encoding
        token_ids = self.preprocessor.tokenizer.encode(self.test_python_code)
        self.assertEqual(len(token_ids), len(tokens) + 2)  # +2 for SOS and EOS
        
        # Test decoding
        decoded = self.preprocessor.tokenizer.decode(token_ids)
        self.assertIsInstance(decoded, str)
    
    def test_feature_extraction(self):
        """Test feature extraction."""
        features = self.preprocessor.feature_extractor.extract_features(self.test_code)
        
        # Check expected feature types
        self.assertIn('syntax_features', features)
        self.assertIn('structural_features', features)
        self.assertIn('semantic_features', features)
        self.assertIn('contextual_features', features)
        
        # Check specific features
        syntax_features = features['syntax_features']
        self.assertIn('line_count', syntax_features)
        self.assertIn('keyword_count', syntax_features)
        self.assertIn('identifier_count', syntax_features)
    
    def test_preprocessing_pipeline(self):
        """Test complete preprocessing pipeline."""
        result = self.preprocessor.preprocess_text(self.test_code, 'python')
        
        # Check result structure
        self.assertIsInstance(result, object)
        self.assertTrue(hasattr(result, 'tokens'))
        self.assertTrue(hasattr(result, 'token_ids'))
        self.assertTrue(hasattr(result, 'features'))
        self.assertTrue(hasattr(result, 'metadata'))
        
        # Check content
        self.assertGreater(len(result.tokens), 0)
        self.assertEqual(len(result.token_ids), len(result.tokens) + 2)  # +2 for SOS and EOS
        self.assertEqual(result.metadata['language'], 'python')
    
    def test_batch_processing(self):
        """Test batch preprocessing."""
        texts = [self.test_python_code, self.test_javascript_code]
        languages = ['python', 'javascript']
        
        result = self.preprocessor.preprocess_batch(texts, languages)
        
        # Check batch result
        self.assertIsInstance(result, object)
        self.assertEqual(len(result.results), 2)
        self.assertEqual(result.batch_features['batch_size'], 2)
        
        # Check individual results
        for i, individual_result in enumerate(result.results):
            self.assertEqual(individual_result.metadata['language'], languages[i])
    
    def test_vocabulary_persistence(self):
        """Test vocabulary saving and loading."""
        # Build vocabulary
        texts = [self.test_python_code, self.test_javascript_code]
        self.preprocessor.build_vocabulary(texts)
        
        # Save vocabulary
        vocab_file = os.path.join(tempfile.gettempdir(), 'test_vocab.json')
        success = self.preprocessor.save_vocabulary(vocab_file)
        self.assertTrue(success)
        self.assertTrue(os.path.exists(vocab_file))
        
        # Create new preprocessor and load vocabulary
        new_preprocessor = DataPreprocessor(self.config_manager)
        load_success = new_preprocessor.load_vocabulary(vocab_file)
        self.assertTrue(load_success)
        
        # Check vocabulary size
        self.assertEqual(
            self.preprocessor.get_vocabulary_size(),
            new_preprocessor.get_vocabulary_size()
        )
        
        # Clean up
        os.remove(vocab_file)

class TestMLModelRegistry(unittest.TestCase):
    """Test cases for MLModelRegistry."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.model_path = os.path.join(self.temp_dir, 'test_models')
        os.makedirs(self.model_path)
        
        self.config_manager = MLConfigurationManager()
        self.config_manager.update_config({
            'model_registry': {
                'model_path': self.model_path
            }
        })
        
        self.registry = MLModelRegistry(
            config_manager=self.config_manager,
            model_path=self.model_path
        )
        
        # Register test model class
        from noodlecore.ai_agents.neural_network_factory import TransformerNetwork
        self.registry.register_model_class(ModelType.TRANSFORMER, TransformerNetwork)
    
    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def test_model_registration(self):
        """Test model registration."""
        # Test model registration
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            TransformerNetwork,
            "1.0.0",
            "Test transformer model"
        )
        
        self.assertIsNotNone(model_id)
        self.assertIn(model_id, self.registry.metadata)
        
        # Check metadata
        metadata = self.registry.get_model_metadata(model_id)
        self.assertIsNotNone(metadata)
        self.assertEqual(metadata.model_type, ModelType.TRANSFORMER)
        self.assertEqual(metadata.model_version, "1.0.0")
        self.assertEqual(metadata.description, "Test transformer model")
    
    def test_model_loading(self):
        """Test model loading."""
        # Register a model
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            TransformerNetwork,
            "1.0.0",
            "Test transformer model"
        )
        
        # Test loading (will fail since model is not actually trained)
        success = self.registry.load_model(model_id)
        self.assertFalse(success)  # Expected to fail without actual model file
        
        # Check model status
        metadata = self.registry.get_model_metadata(model_id)
        self.assertEqual(metadata.status, ModelStatus.ERROR)
    
    def test_model_listing(self):
        """Test model listing."""
        # Register multiple models
        transformer_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            TransformerNetwork,
            "1.0.0",
            "Test transformer model"
        )
        
        # Test listing all models
        all_models = self.registry.list_models()
        self.assertGreaterEqual(len(all_models), 1)
        
        # Test filtering by type
        transformer_models = self.registry.list_models(model_type=ModelType.TRANSFORMER)
        self.assertEqual(len(transformer_models), 1)
        
        # Test filtering by status
        ready_models = self.registry.list_models(status=ModelStatus.READY)
        self.assertEqual(len(ready_models), 0)  # No models are ready
    
    def test_model_deletion(self):
        """Test model deletion."""
        # Register a model
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            TransformerNetwork,
            "1.0.0",
            "Test transformer model"
        )
        
        # Test deletion
        success = self.registry.delete_model(model_id)
        self.assertTrue(success)
        
        # Verify deletion
        metadata = self.registry.get_model_metadata(model_id)
        self.assertIsNone(metadata)
    
    def test_statistics(self):
        """Test registry statistics."""
        stats = self.registry.get_statistics()
        
        # Check expected statistics keys
        expected_keys = [
            'total_models', 'loaded_models', 'cache_hits', 'cache_misses',
            'load_errors', 'prediction_count', 'average_prediction_time'
        ]
        
        for key in expected_keys:
            self.assertIn(key, stats)

class TestNeuralNetworkFactory(unittest.TestCase):
    """Test cases for NeuralNetworkFactory."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config_manager = MLConfigurationManager()
        self.factory = NeuralNetworkFactory(self.config_manager)
    
    def test_network_creation(self):
        """Test neural network creation."""
        # Test transformer creation
        transformer = self.factory.create_transformer('test_transformer')
        self.assertIsNotNone(transformer)
        self.assertEqual(transformer.model_id, 'test_transformer')
        
        # Test RNN creation
        rnn = self.factory.create_rnn('test_rnn')
        self.assertIsNotNone(rnn)
        self.assertEqual(rnn.model_id, 'test_rnn')
        
        # Test CNN creation
        cnn = self.factory.create_cnn('test_cnn')
        self.assertIsNotNone(cnn)
        self.assertEqual(cnn.model_id, 'test_cnn')
        
        # Test hybrid creation
        hybrid = self.factory.create_hybrid('test_hybrid')
        self.assertIsNotNone(hybrid)
        self.assertEqual(hybrid.model_id, 'test_hybrid')
    
    def test_network_configuration(self):
        """Test neural network configuration."""
        # Test with custom configuration
        custom_config = {
            'vocab_size': 5000,
            'd_model': 256,
            'num_layers': 4
        }
        
        transformer = self.factory.create_transformer('test_transformer', custom_config)
        self.assertIsNotNone(transformer)
        
        # Check model info
        model_info = transformer.get_model_info()
        self.assertEqual(model_info['vocab_size'], 5000)
        self.assertEqual(model_info['d_model'], 256)
        self.assertEqual(model_info['num_layers'], 4)
    
    def test_supported_types(self):
        """Test supported network types."""
        types = self.factory.get_supported_types()
        
        # Check expected types
        expected_types = [ModelType.TRANSFORMER, ModelType.RNN, ModelType.CNN]
        for expected_type in expected_types:
            self.assertIn(expected_type, types)
    
    def test_factory_statistics(self):
        """Test factory statistics."""
        stats = self.factory.get_statistics()
        
        # Check expected statistics keys
        expected_keys = [
            'models_created', 'models_by_type', 'creation_time_total',
            'average_creation_time'
        ]
        
        for key in expected_keys:
            self.assertIn(key, stats)

class TestMLInferenceEngine(unittest.TestCase):
    """Test cases for MLInferenceEngine."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.model_path = os.path.join(self.temp_dir, 'test_models')
        os.makedirs(self.model_path)
        
        self.config_manager = MLConfigurationManager()
        self.config_manager.update_config({
            'model_registry': {
                'model_path': self.model_path
            },
            'performance': {
                'inference_timeout_ms': 5000,
                'batch_size': 8
            }
        })
        
        # Initialize components
        self.model_registry = MLModelRegistry(
            config_manager=self.config_manager,
            model_path=self.model_path
        )
        self.data_preprocessor = DataPreprocessor(self.config_manager)
        self.inference_engine = MLInferenceEngine(
            model_registry=self.model_registry,
            preprocessor=self.data_preprocessor,
            config_manager=self.config_manager
        )
        
        # Register test model class
        from noodlecore.ai_agents.neural_network_factory import TransformerNetwork
        self.model_registry.register_model_class(ModelType.TRANSFORMER, TransformerNetwork)
    
    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def test_single_prediction(self):
        """Test single prediction."""
        # Test prediction (will fail without trained model)
        result = self.inference_engine.predict(
            input_data="def test():\n    pass",
            model_id="non_existent_model"
        )
        
        # Check result structure
        self.assertIsInstance(result, InferenceResult)
        self.assertFalse(result.success)
        self.assertIsNotNone(result.error_message)
        self.assertEqual(result.model_id, "non_existent_model")
    
    def test_batch_prediction(self):
        """Test batch prediction."""
        inputs = [
            "def test1():\n    pass",
            "def test2():\n    pass"
        ]
        
        result = self.inference_engine.predict_batch(inputs)
        
        # Check batch result
        self.assertIsInstance(result, object)
        self.assertEqual(len(result.results), 2)
        self.assertEqual(result.batch_features['batch_size'], 2)
        
        # Check individual results
        for individual_result in result.results:
            self.assertIsInstance(individual_result, InferenceResult)
    
    def test_async_prediction(self):
        """Test asynchronous prediction."""
        # Test async prediction
        request_id = self.inference_engine.predict_async(
            input_data="def test():\n    pass",
            model_id="non_existent_model"
        )
        
        # Check request ID
        self.assertIsNotNone(request_id)
        self.assertIsInstance(request_id, str)
    
    def test_caching(self):
        """Test inference caching."""
        # This is a simplified test - full implementation would test actual caching
        
        # Get initial statistics
        initial_stats = self.inference_engine.get_statistics()
        self.assertIn('cache_hits', initial_stats)
        self.assertIn('cache_misses', initial_stats)
        
        # Clear cache
        self.inference_engine.clear_cache()
        
        # Get updated statistics
        cleared_stats = self.inference_engine.get_statistics()
        self.assertIn('cache_stats', cleared_stats)
        
        # Check cache stats
        cache_stats = cleared_stats['cache_stats']
        self.assertEqual(cache_stats['size'], 0)
    
    def test_performance_monitoring(self):
        """Test performance monitoring."""
        # Get initial statistics
        initial_stats = self.inference_engine.get_statistics()
        
        # Check expected statistics
        expected_keys = [
            'total_requests', 'successful_requests', 'failed_requests',
            'average_inference_time', 'requests_per_second', 'success_rate'
        ]
        
        for key in expected_keys:
            self.assertIn(key, initial_stats)
        
        # Check that values are reasonable
        self.assertGreaterEqual(initial_stats['total_requests'], 0)
        self.assertGreaterEqual(initial_stats['average_inference_time'], 0.0)

class TestMLEnhancedSyntaxFixer(unittest.TestCase):
    """Test cases for MLEnhancedSyntaxFixer."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.model_path = os.path.join(self.temp_dir, 'test_models')
        os.makedirs(self.model_path)
        
        # Initialize ML infrastructure
        from noodlecore.ai_agents import create_ml_infrastructure
        self.ml_infra = create_ml_infrastructure(
            config_file=None  # Use default config
        )
        
        # Create ML-enhanced syntax fixer
        self.syntax_fixer = MLEnhancedSyntaxFixer(
            model_registry=self.ml_infra['model_registry'],
            inference_engine=self.ml_infra['inference_engine'],
            data_preprocessor=self.ml_infra['data_preprocessor'],
            config_manager=self.ml_infra['config_manager'],
            model_id=None
        )
        
        # Test code
        self.test_code = """
def calculate_sum(a, b):
    # Missing semicolon
    result = a + b
    return result
"""
        self.expected_fixed_code = """
def calculate_sum(a, b):
    # Missing semicolon
    result = a + b
    return result;
"""
    
    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def test_syntax_fixing(self):
        """Test syntax fixing functionality."""
        # Test syntax fixing
        result = self.syntax_fixer.fix_syntax(
            code=self.test_code,
            error_message="Missing semicolon at end of statement",
            line_number=3,
            use_ml=True  # Force ML usage
        )
        
        # Check result
        self.assertIsInstance(result, dict)
        self.assertIn('success', result)
        self.assertIn('original_code', result)
        self.assertIn('fixed_code', result)
        self.assertIn('ml_enabled', result)
        
        if result['success']:
            self.assertIn('fixes', result)
            self.assertGreater(len(result['fixes']), 0)
    
    def test_ml_decision_making(self):
        """Test ML decision making logic."""
        # Test simple code (should use traditional)
        simple_code = "x = 1"
        result = self.syntax_fixer.fix_syntax(
            code=simple_code,
            use_ml=None  # Auto-detect
        )
        
        # Simple code should not use ML
        self.assertFalse(result.get('ml_enabled', False))
        
        # Test complex code (should use ML)
        complex_code = """
def complex_function(param1, param2, param3):
    if param1 > 0 and param2 < 10:
        for i in range(param3):
            if i % param1 == 0:
                result = param1 * i + param2
                print(result)
    return result
"""
        
        result = self.syntax_fixer.fix_syntax(
            code=complex_code,
            use_ml=None  # Auto-detect
        )
        
        # Complex code should use ML
        self.assertTrue(result.get('ml_enabled', False))  # May still be False due to no model
    
    def test_confidence_threshold(self):
        """Test confidence threshold handling."""
        # Test with low confidence prediction
        result = self.syntax_fixer.fix_syntax(
            code=self.test_code,
            use_ml=True,
            confidence_threshold=0.9  # High threshold
        )
        
        # Should not apply fixes if confidence is below threshold
        if not result.get('success', False):
            self.assertEqual(result['ml_confidence'], 0.0)  # No ML prediction made
    
    def test_batch_processing(self):
        """Test batch processing."""
        code_snippets = [
            {
                'code': self.test_code,
                'file_path': 'test1.py',
                'error_message': 'Syntax error'
            },
            {
                'code': "x = 1\ny = 2",
                'file_path': 'test2.py',
                'error_message': 'Missing semicolon'
            }
        ]
        
        result = self.syntax_fixer.fix_syntax_batch(code_snippets, use_ml=True)
        
        # Check batch result
        self.assertIsInstance(result, dict)
        self.assertIn('success', result)
        self.assertIn('total_snippets', result)
        self.assertIn('successful_fixes', result)
        self.assertEqual(result['total_snippets'], 2)
    
    def test_performance_tracking(self):
        """Test performance tracking."""
        # Get initial statistics
        initial_stats = self.syntax_fixer.get_statistics()
        
        # Check expected statistics
        expected_keys = [
            'total_fixes', 'ml_fixes', 'traditional_fixes',
            'hybrid_fixes', 'average_confidence', 'average_processing_time'
        ]
        
        for key in expected_keys:
            self.assertIn(key, initial_stats)
        
        # Check that values are reasonable
        self.assertGreaterEqual(initial_stats['total_fixes'], 0)
        self.assertGreaterEqual(initial_stats['average_processing_time'], 0.0)

class TestMLIntegration(unittest.TestCase):
    """Integration tests for ML components."""
    
    def test_end_to_end_workflow(self):
        """Test end-to-end ML workflow."""
        # Initialize ML infrastructure
        from noodlecore.ai_agents import create_ml_infrastructure
        ml_infra = create_ml_infrastructure()
        
        # Create ML-enhanced syntax fixer
        syntax_fixer = MLEnhancedSyntaxFixer(
            model_registry=ml_infra['model_registry'],
            inference_engine=ml_infra['inference_engine'],
            data_preprocessor=ml_infra['data_preprocessor'],
            config_manager=ml_infra['config_manager'],
            model_id=None
        )
        
        # Test with problematic code
        problematic_code = """
def problematic_function():
    # Multiple syntax issues
    x = (1 + 2  # Missing closing parenthesis
    if x > 0
        print("Positive")
    else
        print("Negative")
    return x
"""
        
        # Fix syntax
        result = syntax_fixer.fix_syntax(
            code=problematic_code,
            use_ml=True
        )
        
        # Check that some processing occurred
        self.assertIsInstance(result, dict)
        self.assertGreater(result.get('processing_time', 0), 0)
        
        # Check status
        status = syntax_fixer.get_status()
        self.assertIsInstance(status, dict)
        self.assertIn('ml_enabled', status)
        self.assertIn('statistics', status)
    
    def test_component_integration(self):
        """Test integration between components."""
        # Test that components can work together
        from noodlecore.ai_agents import create_ml_infrastructure
        ml_infra = create_ml_infrastructure()
        
        # Check that all components are initialized
        self.assertIn('config_manager', ml_infra)
        self.assertIn('model_registry', ml_infra)
        self.assertIn('network_factory', ml_infra)
        self.assertIn('data_preprocessor', ml_infra)
        self.assertIn('inference_engine', ml_infra)
        
        # Check configuration consistency
        config = ml_infra['config_manager'].get_config()
        self.assertIn('model_registry', config)
        self.assertIn('federated_learning', config)
        self.assertIn('predictive_fixing', config)
        self.assertIn('performance', config)

def run_integration_tests():
    """Run all integration tests."""
    logger.info("Starting ML integration tests")
    
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add test cases
    test_suite.addTest(unittest.makeSuite(TestMLConfigurationManager))
    test_suite.addTest(unittest.makeSuite(TestDataPreprocessor))
    test_suite.addTest(unittest.makeSuite(TestMLModelRegistry))
    test_suite.addTest(unittest.makeSuite(TestNeuralNetworkFactory))
    test_suite.addTest(unittest.makeSuite(TestMLInferenceEngine))
    test_suite.addTest(unittest.makeSuite(TestMLEnhancedSyntaxFixer))
    test_suite.addTest(unittest.makeSuite(TestMLIntegration))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Print results
    print(f"\n{'='*60}")
    print(f"ML Integration Test Results")
    print(f"{'='*60}")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Success rate: {((result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100):.1f}%")
    
    if result.failures:
        print(f"\nFailures:")
        for test, failure in result.failures:
            print(f"- {test}: {failure}")
    
    if result.errors:
        print(f"\nErrors:")
        for test, error in result.errors:
            print(f"- {test}: {error}")
    
    print(f"{'='*60}")
    
    return result.wasSuccessful()

if __name__ == '__main__':
    run_integration_tests()

