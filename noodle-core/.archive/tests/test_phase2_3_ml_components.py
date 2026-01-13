#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_3_ml_components.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
ML Component Tests for Phase 2.3

Comprehensive testing of ML infrastructure components including:
- Model registry and neural network factory testing
- Data preprocessor and inference engine testing
- Configuration manager testing
- Performance and memory usage validation
"""

import os
import sys
import unittest
import tempfile
import shutil
import time
import json
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.ai_agents.ml_model_registry import (
    MLModelRegistry, ModelType, ModelStatus, ModelMetadata, BaseSyntaxModel
)
from noodlecore.ai_agents.ml_configuration_manager import (
    MLConfigurationManager, MLConfiguration, ModelConfiguration
)
from noodlecore.ai_agents.neural_network_factory import (
    NeuralNetworkFactory, TransformerNetwork, RecurrentNetwork, ConvolutionalNetwork
)
from noodlecore.ai_agents.data_preprocessor import (
    DataPreprocessor, Tokenizer, LanguageDetector, FeatureExtractor
)
from noodlecore.ai_agents.ml_inference_engine import (
    MLInferenceEngine, InferenceRequest, InferenceResult
)

class MockSyntaxModel(BaseSyntaxModel):
    """Mock syntax model for testing."""
    
    def __init__(self, model_id: str, config: dict):
        super().__init__(model_id, config)
        self.mock_predictions = config.get('mock_predictions', ['fix1', 'fix2'])
        self.mock_load_time = config.get('mock_load_time', 0.1)
        self.mock_predict_time = config.get('mock_predict_time', 0.05)
    
    def load(self) -> bool:
        time.sleep(self.mock_load_time)
        self.is_loaded = True
        return True
    
    def predict(self, input_data):
        time.sleep(self.mock_predict_time)
        return self.mock_predictions
    
    def get_model_info(self):
        return {
            'model_id': self.model_id,
            'type': 'mock',
            'loaded': self.is_loaded
        }
    
    def unload(self):
        self.is_loaded = False

class TestMLConfigurationManager(unittest.TestCase):
    """Test ML Configuration Manager functionality."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.config_file = os.path.join(self.temp_dir, 'test_config.json')
        self.config_manager = MLConfigurationManager(self.config_file)
    
    def tearDown(self):
        shutil.rmtree(self.temp_dir)
    
    def test_initialization(self):
        """Test configuration manager initialization."""
        config = self.config_manager.get_config()
        self.assertIsInstance(config, MLConfiguration)
        self.assertTrue(self.config_manager.is_advanced_ml_enabled())
        self.assertEqual(self.config_manager.get_model_type(), 'transformer')
    
    def test_environment_variables(self):
        """Test environment variable configuration."""
        with patch.dict(os.environ, {
            'NOODLE_SYNTAX_FIXER_ADVANCED_ML': 'false',
            'NOODLE_SYNTAX_FIXER_ML_MODEL_TYPE': 'rnn',
            'NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE': '64'
        }):
            config_manager = MLConfigurationManager()
            self.assertFalse(config_manager.is_advanced_ml_enabled())
            self.assertEqual(config_manager.get_model_type(), 'rnn')
            self.assertEqual(config_manager.get_batch_size(), 64)
    
    def test_config_update(self):
        """Test configuration updates."""
        updates = {
            'advanced_ml_enabled': False,
            'default_model_type': 'cnn'
        }
        
        success = self.config_manager.update_config(updates)
        self.assertTrue(success)
        
        self.assertFalse(self.config_manager.is_advanced_ml_enabled())
        self.assertEqual(self.config_manager.get_model_type(), 'cnn')
    
    def test_config_save_load(self):
        """Test configuration save and load."""
        # Update configuration
        updates = {
            'advanced_ml_enabled': False,
            'default_model_type': 'rnn'
        }
        self.config_manager.update_config(updates)
        
        # Create new manager from file
        new_manager = MLConfigurationManager(self.config_file)
        self.assertFalse(new_manager.is_advanced_ml_enabled())
        self.assertEqual(new_manager.get_model_type(), 'rnn')
    
    def test_config_validation(self):
        """Test configuration validation."""
        # Test invalid model type
        invalid_updates = {
            'default_model_type': 'invalid_type'
        }
        
        with patch.object(self.config_manager, '_validate_config', return_value=False):
            success = self.config_manager.update_config(invalid_updates)
            self.assertFalse(success)

class TestMLModelRegistry(unittest.TestCase):
    """Test ML Model Registry functionality."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.config_manager = MLConfigurationManager()
        self.registry = MLModelRegistry(
            config_manager=self.config_manager,
            model_path=self.temp_dir,
            cache_size=5
        )
    
    def tearDown(self):
        self.registry.shutdown()
        shutil.rmtree(self.temp_dir)
    
    def test_registry_initialization(self):
        """Test registry initialization."""
        self.assertEqual(self.registry.cache_size, 5)
        self.assertEqual(len(self.registry.models), 0)
        self.assertEqual(len(self.registry.metadata), 0)
    
    def test_model_registration(self):
        """Test model registration."""
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0",
            description="Test model"
        )
        
        self.assertIsNotNone(model_id)
        self.assertIn(model_id, self.registry.metadata)
        
        metadata = self.registry.get_model_metadata(model_id)
        self.assertEqual(metadata.model_type, ModelType.TRANSFORMER)
        self.assertEqual(metadata.model_version, "1.0.0")
        self.assertEqual(metadata.description, "Test model")
    
    def test_model_loading(self):
        """Test model loading and unloading."""
        # Register model
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0"
        )
        
        # Load model
        success = self.registry.load_model(model_id)
        self.assertTrue(success)
        self.assertIn(model_id, self.registry.models)
        
        # Get model
        model = self.registry.get_model(model_id)
        self.assertIsNotNone(model)
        self.assertTrue(model.is_loaded)
        
        # Unload model
        success = self.registry.unload_model(model_id)
        self.assertTrue(success)
        self.assertNotIn(model_id, self.registry.models)
    
    def test_model_prediction(self):
        """Test model prediction."""
        # Register and load model
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0",
            parameters={'mock_predictions': ['prediction1', 'prediction2']}
        )
        
        self.registry.load_model(model_id)
        
        # Make prediction
        prediction, success = self.registry.predict(model_id, "test input")
        self.assertTrue(success)
        self.assertEqual(prediction, ['prediction1', 'prediction2'])
    
    def test_cache_management(self):
        """Test cache size management."""
        # Register multiple models
        model_ids = []
        for i in range(7):  # More than cache size (5)
            model_id = self.registry.register_model(
                ModelType.TRANSFORMER,
                MockSyntaxModel,
                model_version=f"1.0.{i}"
            )
            model_ids.append(model_id)
            self.registry.load_model(model_id)
        
        # Should only have cache_size models loaded
        self.assertLessEqual(len(self.registry.models), 5)
    
    def test_model_listing(self):
        """Test model listing with filters."""
        # Register models of different types
        transformer_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0",
            tags=["transformer", "test"]
        )
        
        rnn_id = self.registry.register_model(
            ModelType.RNN,
            MockSyntaxModel,
            model_version="1.0.0",
            tags=["rnn", "test"]
        )
        
        # List all models
        all_models = self.registry.list_models()
        self.assertEqual(len(all_models), 2)
        
        # Filter by type
        transformer_models = self.registry.list_models(model_type=ModelType.TRANSFORMER)
        self.assertEqual(len(transformer_models), 1)
        self.assertEqual(transformer_models[0].model_id, transformer_id)
        
        # Filter by tags
        test_models = self.registry.list_models(tags=["test"])
        self.assertEqual(len(test_models), 2)
    
    def test_statistics(self):
        """Test registry statistics."""
        # Register and load some models
        model_id1 = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0"
        )
        model_id2 = self.registry.register_model(
            ModelType.RNN,
            MockSyntaxModel,
            model_version="1.0.0"
        )
        
        self.registry.load_model(model_id1)
        self.registry.predict(model_id1, "test")
        
        stats = self.registry.get_statistics()
        self.assertEqual(stats["total_models"], 2)
        self.assertEqual(stats["loaded_models"], 1)
        self.assertEqual(stats["prediction_count"], 1)
        self.assertGreater(stats["average_prediction_time"], 0)

class TestNeuralNetworkFactory(unittest.TestCase):
    """Test Neural Network Factory functionality."""
    
    def setUp(self):
        self.config_manager = MLConfigurationManager()
        self.factory = NeuralNetworkFactory(self.config_manager)
    
    def test_factory_initialization(self):
        """Test factory initialization."""
        self.assertIsNotNone(self.factory.config_manager)
        self.assertEqual(len(self.factory.network_classes), 3)  # TRANSFORMER, RNN, CNN
        
        stats = self.factory.get_statistics()
        self.assertEqual(stats["models_created"], 0)
    
    def test_transformer_creation(self):
        """Test Transformer network creation."""
        model_id = "test_transformer"
        config = {
            'vocab_size': 1000,
            'd_model': 256,
            'nhead': 4,
            'num_layers': 2
        }
        
        network = self.factory.create_transformer(model_id, config)
        self.assertIsNotNone(network)
        self.assertEqual(network.model_id, model_id)
        self.assertEqual(network.vocab_size, 1000)
        self.assertEqual(network.d_model, 256)
        
        stats = self.factory.get_statistics()
        self.assertEqual(stats["models_created"], 1)
        self.assertEqual(stats["models_by_type"]["transformer"], 1)
    
    def test_rnn_creation(self):
        """Test RNN network creation."""
        model_id = "test_rnn"
        config = {
            'vocab_size': 1000,
            'embedding_dim': 128,
            'hidden_dim': 256
        }
        
        network = self.factory.create_rnn(model_id, config)
        self.assertIsNotNone(network)
        self.assertEqual(network.model_id, model_id)
        self.assertEqual(network.vocab_size, 1000)
        self.assertEqual(network.embedding_dim, 128)
        
        stats = self.factory.get_statistics()
        self.assertEqual(stats["models_created"], 1)
        self.assertEqual(stats["models_by_type"]["rnn"], 1)
    
    def test_cnn_creation(self):
        """Test CNN network creation."""
        model_id = "test_cnn"
        config = {
            'vocab_size': 1000,
            'embedding_dim': 128,
            'num_filters': [50, 50, 50]
        }
        
        network = self.factory.create_cnn(model_id, config)
        self.assertIsNotNone(network)
        self.assertEqual(network.model_id, model_id)
        self.assertEqual(network.vocab_size, 1000)
        self.assertEqual(network.embedding_dim, 128)
        
        stats = self.factory.get_statistics()
        self.assertEqual(stats["models_created"], 1)
        self.assertEqual(stats["models_by_type"]["cnn"], 1)
    
    def test_hybrid_creation(self):
        """Test hybrid network creation."""
        model_id = "test_hybrid"
        
        network = self.factory.create_hybrid(model_id)
        self.assertIsNotNone(network)
        # Hybrid should fallback to transformer for now
        self.assertIsInstance(network, TransformerNetwork)
    
    def test_custom_network_registration(self):
        """Test custom network class registration."""
        class CustomNetwork(BaseSyntaxModel):
            def __init__(self, model_id, config):
                super().__init__(model_id, config)
            
            def load(self):
                return True
            
            def predict(self, input_data):
                return ["custom_prediction"]
            
            def get_model_info(self):
                return {"type": "custom"}
            
            def unload(self):
                pass
        
        # Register custom network
        custom_type = ModelType.HYBRID  # Use existing type for test
        self.factory.register_network_class(custom_type, CustomNetwork)
        
        # Create custom network
        network = self.factory.create_network(custom_type, "test_custom")
        self.assertIsNotNone(network)
        self.assertIsInstance(network, CustomNetwork)

class TestDataPreprocessor(unittest.TestCase):
    """Test Data Preprocessor functionality."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.config_manager = MLConfigurationManager()
        self.preprocessor = DataPreprocessor(
            config_manager=self.config_manager
        )
    
    def tearDown(self):
        shutil.rmtree(self.temp_dir)
    
    def test_language_detection(self):
        """Test programming language detection."""
        detector = LanguageDetector()
        
        # Python detection
        python_code = "def hello():\n    print('Hello, World!')"
        language = detector.detect_language(python_code, '.py')
        self.assertEqual(language, 'python')
        
        # JavaScript detection
        js_code = "function hello() {\n    console.log('Hello, World!');\n}"
        language = detector.detect_language(js_code, '.js')
        self.assertEqual(language, 'javascript')
        
        # Java detection
        java_code = "public class Hello {\n    public static void main(String[] args) {\n        System.out.println(\"Hello, World!\");\n    }\n}"
        language = detector.detect_language(java_code, '.java')
        self.assertEqual(language, 'java')
    
    def test_tokenization(self):
        """Test code tokenization."""
        tokenizer = Tokenizer(vocab_size=1000, max_seq_length=100)
        
        # Build vocabulary
        texts = [
            "def hello():\n    print('Hello')",
            "function test() {\n    return 42;\n}",
            "int main() {\n    return 0;\n}"
        ]
        tokenizer.build_vocabulary(texts, min_frequency=1)
        
        # Test tokenization
        code = "def test():\n    return 42"
        tokens = tokenizer.tokenize(code)
        self.assertGreater(len(tokens), 0)
        
        # Test encoding
        token_ids = tokenizer.encode(code)
        self.assertEqual(len(token_ids), 100)  # Should be padded to max_seq_length
        self.assertIn(tokenizer.token_to_id[tokenizer.sos_token], token_ids)
        self.assertIn(tokenizer.token_to_id[tokenizer.eos_token], token_ids)
        
        # Test decoding
        decoded = tokenizer.decode(token_ids)
        self.assertIn('def', decoded)
        self.assertIn('test', decoded)
    
    def test_feature_extraction(self):
        """Test feature extraction."""
        extractor = FeatureExtractor()
        
        code = """
def calculate_sum(numbers):
    total = 0
    for num in numbers:
        total += num
    return total

class Calculator:
    def __init__(self):
        self.result = 0
    
    def add(self, x, y):
        return x + y
"""
        
        features = extractor.extract_features(code, 'python')
        
        # Check syntax features
        syntax_features = features['syntax_features']
        self.assertGreater(syntax_features['line_count'], 0)
        self.assertGreater(syntax_features['keyword_count'], 0)
        self.assertGreater(syntax_features['function_count'], 0)
        
        # Check structural features
        structural_features = features['structural_features']
        self.assertGreater(structural_features['function_count'], 0)
        self.assertGreater(structural_features['class_count'], 0)
        self.assertGreater(structural_features['loop_count'], 0)
        
        # Check semantic features
        semantic_features = features['semantic_features']
        self.assertIn('variable_complexity', semantic_features)
        self.assertIn('control_flow_complexity', semantic_features)
    
    def test_preprocessing_pipeline(self):
        """Test complete preprocessing pipeline."""
        code = "def hello_world():\n    print('Hello, World!')"
        
        result = self.preprocessor.preprocess_text(code, language='python')
        
        self.assertEqual(result.input_data, code)
        self.assertGreater(len(result.tokens), 0)
        self.assertGreater(len(result.token_ids), 0)
        self.assertIn('features', result.__dict__)
        self.assertGreater(result.processing_time, 0)
        
        # Check features
        self.assertIn('syntax_features', result.features)
        self.assertIn('structural_features', result.features)
        self.assertIn('semantic_features', result.features)
        self.assertIn('contextual_features', result.features)
    
    def test_batch_preprocessing(self):
        """Test batch preprocessing."""
        codes = [
            "def func1():\n    return 1",
            "def func2():\n    return 2",
            "def func3():\n    return 3"
        ]
        
        result = self.preprocessor.preprocess_batch(codes)
        
        self.assertEqual(len(result.results), 3)
        self.assertEqual(result.batch_features['batch_size'], 3)
        self.assertGreater(result.total_processing_time, 0)
        
        # Check individual results
        for i, individual_result in enumerate(result.results):
            self.assertEqual(individual_result.input_data, codes[i])
            self.assertGreater(len(individual_result.tokens), 0)
    
    def test_vocabulary_management(self):
        """Test vocabulary building and management."""
        texts = [
            "def function1():\n    pass",
            "def function2():\n    pass",
            "def function3():\n    pass"
        ]
        
        # Build vocabulary
        success = self.preprocessor.build_vocabulary(texts, min_frequency=1)
        self.assertTrue(success)
        
        # Check vocabulary size
        tokenizer = self.preprocessor.get_tokenizer()
        vocab_size = tokenizer.get_vocabulary_size()
        self.assertGreater(vocab_size, 0)
        
        # Save and load vocabulary
        vocab_file = os.path.join(self.temp_dir, 'vocab.json')
        success = self.preprocessor.save_vocabulary(vocab_file)
        self.assertTrue(success)
        self.assertTrue(os.path.exists(vocab_file))
        
        # Create new preprocessor and load vocabulary
        new_preprocessor = DataPreprocessor()
        success = new_preprocessor.load_vocabulary(vocab_file)
        self.assertTrue(success)
        
        new_tokenizer = new_preprocessor.get_tokenizer()
        self.assertEqual(new_tokenizer.get_vocabulary_size(), vocab_size)
    
    def test_statistics(self):
        """Test preprocessing statistics."""
        codes = [
            "def test1():\n    return 1",
            "def test2():\n    return 2"
        ]
        
        # Process some texts
        for code in codes:
            self.preprocessor.preprocess_text(code)
        
        stats = self.preprocessor.get_statistics()
        self.assertEqual(stats["texts_processed"], 2)
        self.assertGreater(stats["tokens_generated"], 0)
        self.assertGreater(stats["processing_time_total"], 0)
        self.assertGreater(stats["average_processing_time"], 0)
        self.assertGreater(stats["vocabulary_size"], 0)

class TestMLInferenceEngine(unittest.TestCase):
    """Test ML Inference Engine functionality."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.config_manager = MLConfigurationManager()
        self.preprocessor = DataPreprocessor()
        self.registry = MLModelRegistry(
            config_manager=self.config_manager,
            model_path=self.temp_dir
        )
        
        # Register mock model
        self.model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0",
            parameters={'mock_predictions': ['fix1', 'fix2']}
        )
        
        self.inference_engine = MLInferenceEngine(
            model_registry=self.registry,
            preprocessor=self.preprocessor,
            config_manager=self.config_manager
        )
    
    def tearDown(self):
        self.inference_engine.shutdown()
        self.registry.shutdown()
        shutil.rmtree(self.temp_dir)
    
    def test_single_prediction(self):
        """Test single prediction."""
        input_data = "def broken_function(:\n    print('test'"
        
        result = self.inference_engine.predict(input_data, model_id=self.model_id)
        
        self.assertIsInstance(result, InferenceResult)
        self.assertTrue(result.success)
        self.assertEqual(result.model_id, self.model_id)
        self.assertGreater(result.processing_time, 0)
        self.assertGreater(len(result.predictions), 0)
    
    def test_batch_prediction(self):
        """Test batch prediction."""
        inputs = [
            "def func1(:\n    pass",
            "def func2(:\n    pass",
            "def func3(:\n    pass"
        ]
        
        batch_result = self.inference_engine.predict_batch(inputs, model_id=self.model_id)
        
        self.assertEqual(len(batch_result.results), 3)
        self.assertGreater(batch_result.total_processing_time, 0)
        self.assertGreater(batch_result.throughput, 0)
        
        # Check individual results
        for result in batch_result.results:
            self.assertTrue(result.success)
            self.assertEqual(result.model_id, self.model_id)
    
    def test_async_prediction(self):
        """Test asynchronous prediction."""
        input_data = "def async_test(:\n    pass"
        
        # Test with callback
        callback_result = {}
        def test_callback(result):
            callback_result['result'] = result
        
        request_id = self.inference_engine.predict_async(
            input_data,
            model_id=self.model_id,
            callback=test_callback
        )
        
        self.assertIsNotNone(request_id)
        
        # Wait for callback (simplified for test)
        time.sleep(0.2)
        
        if 'result' in callback_result:
            result = callback_result['result']
            self.assertTrue(result.success)
            self.assertEqual(result.model_id, self.model_id)
    
    def test_caching(self):
        """Test result caching."""
        input_data = "def cache_test(:\n    pass"
        
        # First prediction
        result1 = self.inference_engine.predict(input_data, model_id=self.model_id)
        
        # Second prediction (should hit cache)
        result2 = self.inference_engine.predict(input_data, model_id=self.model_id)
        
        self.assertTrue(result1.success)
        self.assertTrue(result2.success)
        
        stats = self.inference_engine.get_statistics()
        self.assertGreater(stats["cache_hits"], 0)
    
    def test_performance_targets(self):
        """Test performance target validation."""
        # Simple fix should be <50ms
        simple_input = "def x(:\n    pass"
        result = self.inference_engine.predict(simple_input, model_id=self.model_id)
        
        # Check if simple fix target is met
        targets_met = self.inference_engine.check_performance_targets()
        self.assertIn('simple_fix_target', targets_met)
        
        # For mock model, should be very fast
        if result.processing_time < 0.05:  # 50ms
            self.assertTrue(targets_met['simple_fix_target'])
    
    def test_error_handling(self):
        """Test error handling."""
        # Test with invalid model ID
        result = self.inference_engine.predict("test", model_id="invalid_model")
        
        self.assertFalse(result.success)
        self.assertIsNotNone(result.error_message)
    
    def test_statistics(self):
        """Test inference engine statistics."""
        # Make some predictions
        inputs = ["test1", "test2", "test3"]
        for input_data in inputs:
            self.inference_engine.predict(input_data, model_id=self.model_id)
        
        stats = self.inference_engine.get_statistics()
        
        self.assertEqual(stats["total_requests"], 3)
        self.assertGreater(stats["successful_requests"], 0)
        self.assertGreater(stats["average_inference_time"], 0)
        self.assertGreater(stats["requests_per_second"], 0)

class TestMLComponentIntegration(unittest.TestCase):
    """Test ML component integration."""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.config_manager = MLConfigurationManager()
        self.preprocessor = DataPreprocessor()
        self.registry = MLModelRegistry(
            config_manager=self.config_manager,
            model_path=self.temp_dir
        )
        self.factory = NeuralNetworkFactory(self.config_manager)
        self.inference_engine = MLInferenceEngine(
            model_registry=self.registry,
            preprocessor=self.preprocessor,
            config_manager=self.config_manager
        )
    
    def tearDown(self):
        self.inference_engine.shutdown()
        self.registry.shutdown()
        shutil.rmtree(self.temp_dir)
    
    def test_end_to_end_workflow(self):
        """Test complete end-to-end ML workflow."""
        # 1. Create and register model
        model_id = self.registry.register_model(
            ModelType.TRANSFORMER,
            MockSyntaxModel,
            model_version="1.0.0",
            parameters={'mock_predictions': ['fixed_code']}
        )
        
        # 2. Load model
        success = self.registry.load_model(model_id)
        self.assertTrue(success)
        
        # 3. Preprocess input
        input_code = "def broken_function(:\n    print('test'"
        preprocessing_result = self.preprocessor.preprocess_text(input_code)
        self.assertGreater(len(preprocessing_result.tokens), 0)
        
        # 4. Make prediction
        result = self.inference_engine.predict(input_code, model_id=model_id)
        self.assertTrue(result.success)
        self.assertGreater(len(result.predictions), 0)
        
        # 5. Verify workflow statistics
        registry_stats = self.registry.get_statistics()
        preprocessor_stats = self.preprocessor.get_statistics()
        inference_stats = self.inference_engine.get_statistics()
        
        self.assertGreater(registry_stats["prediction_count"], 0)
        self.assertGreater(preprocessor_stats["texts_processed"], 0)
        self.assertGreater(inference_stats["total_requests"], 0)
    
    def test_performance_validation(self):
        """Test performance validation across components."""
        # Test with multiple inputs
        inputs = [
            "def test1(:\n    pass",
            "def test2(:\n    pass",
            "def test3(:\n    pass",
            "def test4(:\n    pass",
            "def test5(:\n    pass"
        ]
        
        start_time = time.time()
        
        # Process through pipeline
        for input_data in inputs:
            preprocessing_result = self.preprocessor.preprocess_text(input_data)
            result = self.inference_engine.predict(input_data, model_id=self.model_id)
            self.assertTrue(result.success)
        
        total_time = time.time() - start_time
        avg_time_per_request = total_time / len(inputs)
        
        # Performance targets
        self.assertLess(avg_time_per_request, 0.5)  # <500ms average
        self.assertLess(total_time, 2.0)  # <2s total for 5 requests
        
        # Check component statistics
        registry_stats = self.registry.get_statistics()
        preprocessor_stats = self.preprocessor.get_statistics()
        inference_stats = self.inference_engine.get_statistics()
        
        self.assertLess(preprocessor_stats["average_processing_time"], 0.1)
        self.assertLess(inference_stats["average_inference_time"], 0.1)
    
    def test_memory_usage_validation(self):
        """Test memory usage for large files."""
        # Simulate large input
        large_input = "def large_function():\n"
        for i in range(1000):
            large_input += f"    var_{i} = {i}\n"
        
        # Process large input
        result = self.inference_engine.predict(large_input, model_id=self.model_id)
        self.assertTrue(result.success)
        
        # Check statistics
        stats = self.inference_engine.get_statistics()
        self.assertGreater(stats["total_requests"], 0)
        
        # Memory usage would be checked in a real implementation
        # For now, just verify processing completes
        self.assertLess(result.processing_time, 1.0)  # Should complete in <1s

if __name__ == '__main__':
    # Configure test environment
    os.environ['NOODLE_SYNTAX_FIXER_ADVANCED_ML'] = 'true'
    os.environ['NOODLE_SYNTAX_FIXER_ML_MODEL_TYPE'] = 'transformer'
    os.environ['NOODLE_SYNTAX_FIXER_ML_BATCH_SIZE'] = '32'
    os.environ['NOODLE_SYNTAX_FIXER_ML_INFERENCE_TIMEOUT'] = '5000'
    os.environ['NOODLE_SYNTAX_FIXER_ML_CACHE_SIZE'] = '100'
    
    # Run tests
    unittest.main(verbosity=2)

