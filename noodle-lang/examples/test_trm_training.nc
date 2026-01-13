# Converted from Python to NoodleCore
# Original file: src

# """
# TRM Training Tests
 = ================

# Comprehensive tests for the TRM training system
# """

import unittest
import unittest.mock.Mock
import sys
import os
import time
import threading

# Add the parent directory to the path so we can import TRM modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

import noodlecore.trm.trm_types.(
#     TRMNetwork, TRMLayer, TRMRecursiveFunction, TRMParameter,
#     TRMLatentState, TRMActivationFunction, TRMNodeType,
#     TRMTrainingConfig, TRMInferenceConfig
# )
import noodlecore.trm.trm_core.TRMCore
import noodlecore.trm.trm_training.(
#     TRMTrainer, TRMTrainingManager, TrainingMetrics, TrainingHistory,
#     train_trm_model, train_trm_model_async
# )


class TestTRMTraining(unittest.TestCase)
    #     """Test cases for TRM training"""

    #     def setUp(self):""Set up test fixtures"""
    self.test_network = TRMNetwork(name="test_network")
    self.test_layer = TRMLayer(
    layer_type = TRMNodeType.FEEDFORWARD,
    input_size = 3,
    output_size = 2,
    activation = TRMActivationFunction.RELU
    #         )
            self.test_layer.parameters.append(TRMParameter(
    name = "weight",
    value = [[1.0, 0.5], [0.5, 1.0], [0.25, 0.75]],
    requires_grad = True
    #         ))
            self.test_layer.parameters.append(TRMParameter(
    name = "bias",
    value = [0.1, 0.2],
    requires_grad = True
    #         ))

            self.test_network.layers.append(self.test_layer)
    self.test_network.learning_rate = 0.001

    self.trm_core = TRMCore(self.test_network)
    self.training_config = TRMTrainingConfig(
    epochs = 5,
    batch_size = 2,
    learning_rate = 0.001,
    early_stopping = True,
    patience = 3
    #         )

    self.trainer = TRMTrainer(self.trm_core, self.training_config)

    #         # Mock training data
    self.train_data = [
                ([1.0, 2.0, 3.0], [2.0, 1.0]),
                ([0.5, 1.0, 1.5], [1.5, 0.5]),
                ([2.0, 3.0, 4.0], [3.0, 2.0]),
                ([1.5, 2.5, 3.5], [2.5, 1.5])
    #         ]

    self.validation_data = [
                ([0.8, 1.8, 2.8], [1.8, 0.8]),
                ([1.2, 2.2, 3.2], [2.2, 1.2])
    #         ]

    #     def test_trm_trainer_creation(self):
    #         """Test TRM trainer creation"""
            self.assertIsInstance(self.trainer, TRMTrainer)
            self.assertEqual(self.trainer.trm_core, self.trm_core)
            self.assertEqual(self.trainer.config, self.training_config)
            self.assertIsInstance(self.trainer.training_history, TrainingHistory)
            self.assertFalse(self.trainer.is_training)
            self.assertFalse(self.trainer.should_stop)

    #     def test_training_metrics_creation(self):
    #         """Test training metrics creation"""
    metrics = TrainingMetrics(
    epoch = 1,
    train_loss = 0.5,
    val_loss = 0.6,
    train_accuracy = 0.8,
    val_accuracy = 0.7,
    learning_rate = 0.001,
    execution_time = 10.5,
    memory_usage = 100.0,
    parameter_updates = 5
    #         )

            self.assertEqual(metrics.epoch, 1)
            self.assertEqual(metrics.train_loss, 0.5)
            self.assertEqual(metrics.val_loss, 0.6)
            self.assertEqual(metrics.train_accuracy, 0.8)
            self.assertEqual(metrics.val_accuracy, 0.7)
            self.assertEqual(metrics.learning_rate, 0.001)
            self.assertEqual(metrics.execution_time, 10.5)
            self.assertEqual(metrics.memory_usage, 100.0)
            self.assertEqual(metrics.parameter_updates, 5)

    #     def test_training_metrics_to_dict(self):
    #         """Test training metrics to dictionary conversion"""
    metrics = TrainingMetrics(
    epoch = 1,
    train_loss = 0.5,
    val_loss = 0.6,
    learning_rate = 0.001
    #         )

    metrics_dict = metrics.to_dict()

            self.assertIsInstance(metrics_dict, dict)
            self.assertEqual(metrics_dict["epoch"], 1)
            self.assertEqual(metrics_dict["train_loss"], 0.5)
            self.assertEqual(metrics_dict["val_loss"], 0.6)
            self.assertEqual(metrics_dict["learning_rate"], 0.001)

    #     def test_training_history_creation(self):
    #         """Test training history creation"""
    history = TrainingHistory()

            self.assertEqual(len(history.metrics), 0)
            self.assertIsNone(history.best_metrics)
            self.assertFalse(history.early_stopped)
            self.assertEqual(history.early_stop_epoch, 0)

    #     def test_training_history_add_metrics(self):
    #         """Test adding metrics to training history"""
    history = TrainingHistory()
    metrics = TrainingMetrics(epoch=1, train_loss=0.5, val_loss=0.6)

            history.add_metrics(metrics)

            self.assertEqual(len(history.metrics), 1)
            self.assertEqual(history.best_metrics, metrics)

    #     def test_training_history_should_early_stop(self):
    #         """Test early stopping logic"""
    history = TrainingHistory()

    #         # Not enough metrics
            self.assertFalse(history.should_early_stop(3))

    #         # Add metrics with decreasing loss
    #         for i in range(5):
    metrics = TrainingMetrics(
    epoch = i,
    train_loss = 1.0 - i * 0.1,
    val_loss = 0.8 - i * 0.05
    #             )
                history.add_metrics(metrics)

    #         # Should not early stop because loss is decreasing
            self.assertFalse(history.should_early_stop(3))

    #         # Add metrics with plateau
    #         for i in range(5):
    metrics = TrainingMetrics(
    epoch = 5 + i,
    train_loss = 0.5,
    val_loss = 0.3
    #             )
                history.add_metrics(metrics)

    #         # Should early stop because of plateau
            self.assertTrue(history.should_early_stop(3))
            self.assertTrue(history.early_stopped)

    #     def test_trm_trainer_train_basic(self):
    #         """Test basic training functionality"""
    #         with patch.object(self.trainer, '_train_epoch') as mock_train_epoch, \
                 patch.object(self.trainer, '_adjust_learning_rate_on_plateau') as mock_adjust_lr:

    mock_metrics = TrainingMetrics(epoch=0, train_loss=0.5, val_loss=0.6)
    mock_train_epoch.return_value = mock_metrics

    self.trainer.train(self.train_data, self.validation_data, epochs = 3)

                self.assertEqual(mock_train_epoch.call_count, 3)
    self.assertTrue(self.trainer.training_history.metrics[0].epoch = 0)

    #     def test_trm_trainer_train_with_early_stopping(self):
    #         """Test training with early stopping"""
    #         with patch.object(self.trainer, '_train_epoch') as mock_train_epoch:
    #             # Create metrics that trigger early stopping
    #             metrics = [TrainingMetrics(epoch=i, val_loss=0.5) for i in range(5)]
    mock_train_epoch.side_effect = metrics

    self.trainer.config.early_stopping = True
    self.trainer.config.patience = 2

                self.trainer.train(self.train_data, self.validation_data)

    #             # Should stop early
                self.assertTrue(self.trainer.training_history.early_stopped)
                self.assertEqual(len(self.trainer.training_history.metrics), 5)

    #     def test_trm_trainer_train_async(self):
    #         """Test async training functionality"""
    #         with patch.object(self.trainer, 'train') as mock_train:
    self.trainer.train_async(self.train_data, self.validation_data, epochs = 2)

                self.assertTrue(self.trainer.training_thread is not None)
    #             self.trainer.training_thread.join(timeout=1)  # Wait for thread to finish

    #     def test_trm_trainer_stop_training(self):
    #         """Test stopping training"""
    #         with patch.object(self.trainer, 'train') as mock_train:
    #             # Make training run for a while
    #             def mock_train_func(*args, **kwargs):
                    time.sleep(0.1)
    #                 return

    mock_train.side_effect = mock_train_func

    #             # Start training
                self.trainer.train_async(self.train_data, self.validation_data)

    #             # Stop training
                self.trainer.stop_training()

    #             # Check that should_stop was set
                self.assertTrue(self.trainer.should_stop)

    #     def test_train_epoch(self):
    #         """Test single epoch training"""
    #         with patch.object(self.trainer, '_train_epoch_phase') as mock_train_phase, \
                 patch.object(self.trainer, '_validate_epoch') as mock_validate, \
                 patch.object(self.trainer.performance_monitor, 'start_monitoring') as mock_start, \
                 patch.object(self.trainer.performance_monitor, 'get_memory_usage') as mock_memory:

    mock_train_phase.return_value = (0.5, 0.8)
    mock_validate.return_value = (0.6, 0.7)
    mock_memory.return_value = 50.0

    metrics = self.trainer._train_epoch(self.train_data, self.validation_data)

                self.assertIsInstance(metrics, TrainingMetrics)
                self.assertEqual(metrics.train_loss, 0.5)
                self.assertEqual(metrics.val_loss, 0.6)
                self.assertEqual(metrics.train_accuracy, 0.8)
                self.assertEqual(metrics.val_accuracy, 0.7)
                self.assertEqual(metrics.memory_usage, 50.0)

    #     def test_train_epoch_phase(self):
    #         """Test training phase for one epoch"""
    #         with patch.object(self.trainer, '_train_batch') as mock_train_batch:
    mock_train_batch.side_effect = [
                    (0.4, 1, 2),  # First batch
                    (0.6, 1, 2),  # Second batch
    #             ]

    loss, accuracy = self.trainer._train_epoch_phase(self.train_data[:4])

                self.assertEqual(loss, 0.5)  # Average of 0.4 and 0.6
                self.assertEqual(accuracy, 0.5)  # 2 correct out of 4 samples

    #     def test_train_batch(self):
    #         """Test training on a single batch"""
    #         with patch.object(self.trm_core, 'train_step') as mock_train_step, \
                 patch.object(self.trm_core, 'forward') as mock_forward:

    mock_train_step.return_value = {"loss": 0.5}
    mock_forward.return_value = [2.0, 1.0]

    loss, correct, total = self.trainer._train_batch(self.train_data[:2])

                self.assertEqual(loss, 1.0)  # 0.5 * 2
                self.assertEqual(correct, 2)  # Both samples correct
                self.assertEqual(total, 2)

    #     def test_validate_epoch(self):
    #         """Test validation for one epoch"""
    #         with patch.object(self.trm_core, 'forward') as mock_forward, \
                 patch.object(self.trm_core, '_compute_loss') as mock_loss:

    mock_forward.return_value = [2.0, 1.0]
    mock_loss.return_value = 0.3

    loss, accuracy = self.trainer._validate_epoch(self.validation_data)

                self.assertEqual(loss, 0.3)  # Single loss value
                self.assertEqual(accuracy, 1.0)  # 1 out of 1 correct

    #     def test_adjust_learning_rate_on_plateau(self):
    #         """Test learning rate adjustment on plateau"""
    #         # Create metrics that trigger plateau detection
    #         for i in range(5):
    metrics = TrainingMetrics(epoch=i, val_loss=0.5)
                self.trainer.training_history.add_metrics(metrics)

    original_lr = self.trm_core.network.learning_rate

            self.trainer._adjust_learning_rate_on_plateau()

    #         # Learning rate should be halved
            self.assertEqual(self.trm_core.network.learning_rate, original_lr * 0.5)

    #     def test_get_training_history(self):
    #         """Test getting training history"""
    history = self.trainer.get_training_history()

            self.assertIsInstance(history, TrainingHistory)
            self.assertEqual(history, self.trainer.training_history)

    #     def test_set_callbacks(self):
    #         """Test setting callback functions"""
    epoch_callback = Mock()
    batch_callback = Mock()
    complete_callback = Mock()

            self.trainer.set_epoch_callback(epoch_callback)
            self.trainer.set_batch_callback(batch_callback)
            self.trainer.set_training_complete_callback(complete_callback)

            self.assertEqual(self.trainer.epoch_callback, epoch_callback)
            self.assertEqual(self.trainer.batch_callback, batch_callback)
            self.assertEqual(self.trainer.training_complete_callback, complete_callback)

    #     def test_convenience_functions(self):
    #         """Test convenience training functions"""
    #         with patch('noodlecore.trm.trm_training.TRMTrainer') as mock_trainer_class:
    mock_trainer = Mock()
    mock_trainer_class.return_value = mock_trainer

    #             # Test sync training
    history = train_trm_model(self.trm_core, self.train_data, self.training_config)

                mock_trainer_class.assert_called_once()
                mock_trainer.train.assert_called_once()
                self.assertEqual(history, mock_trainer.get_training_history())

    #             # Reset mock
                mock_trainer.reset_mock()

    #             # Test async training
    trainer = train_trm_model_async(self.trm_core, self.train_data, self.training_config)

                mock_trainer_class.assert_called_once()
                self.assertEqual(trainer, mock_trainer)

    #     def test_trm_training_manager_creation(self):
    #         """Test TRM training manager creation"""
    manager = TRMTrainingManager(max_workers=2)

            self.assertEqual(manager.max_workers, 2)
            self.assertEqual(len(manager.executors), 0)
            self.assertEqual(len(manager.active_trainers), 0)
            self.assertEqual(len(manager.training_results), 0)

    #     def test_trm_training_manager_create_trainer(self):
    #         """Test trainer creation in training manager"""
    manager = TRMTrainingManager()
    trainer = manager.create_trainer(self.trm_core, self.training_config)

            self.assertIsInstance(trainer, TRMTrainer)
            self.assertIn(trainer, manager.active_trainers)

    #     def test_trm_training_manager_train_multiple_models(self):
    #         """Test training multiple models"""
    manager = TRMTrainingManager(max_workers=1)

    #         # Create multiple model configs
    model_configs = [
                ("model1", self.trm_core, self.training_config),
                ("model2", self.trm_core, self.training_config),
    #         ]

            manager.train_multiple_models(model_configs, self.train_data, self.validation_data)

    #         # Check that executors were created
            self.assertEqual(len(manager.executors), 1)
            self.assertEqual(len(manager.training_results), 2)

    #     def test_trm_training_manager_wait_for_all_training(self):
    #         """Test waiting for all training to complete"""
    manager = TRMTrainingManager()

    #         # Add mock training results
    manager.training_results["model1"] = Mock()
    manager.training_results["model2"] = Mock()

    #         # Add mock trainers
    trainer1 = Mock()
    trainer1.training_history.metrics = [Mock()]
    trainer2 = Mock()
    trainer2.training_history.metrics = [Mock()]

            manager.active_trainers.extend([trainer1, trainer2])

    results = manager.wait_for_all_training()

            self.assertIsInstance(results, dict)
            self.assertIn("model1", results)
            self.assertIn("model2", results)

    #     def test_trm_training_manager_cleanup(self):
    #         """Test training manager cleanup"""
    manager = TRMTrainingManager()

    #         # Add some mock data
    mock_executor = Mock()
            manager.executors.append(mock_executor)
            manager.active_trainers.append(Mock())
    manager.training_results["test"] = Mock()

            manager.cleanup()

            self.assertEqual(len(manager.executors), 0)
            self.assertEqual(len(manager.active_trainers), 0)
            self.assertEqual(len(manager.training_results), 0)
            mock_executor.shutdown.assert_called_once()

    #     def test_training_error_handling(self):
    #         """Test error handling during training"""
    #         with patch.object(self.trainer, '_train_epoch') as mock_train_epoch:
    mock_train_epoch.side_effect = Exception("Training failed")

    #             with self.assertRaises(Exception):
                    self.trainer.train(self.train_data, self.validation_data)

    #     def test_parameter_counting(self):
    #         """Test parameter counting"""
    #         # Set up some gradients
    #         for param in self.trm_core.parameters.values():
    #             if param.requires_grad:
    param.grad = 0.1

    count = self.trainer._count_parameter_updates()

    #         # Should count all parameters with gradients
    #         expected_count = len([p for p in self.trm_core.parameters.values() if p.requires_grad])
            self.assertEqual(count, expected_count)

    #     def tearDown(self):
    #         """Clean up test fixtures"""
    #         # Clean up any active training threads
    #         if hasattr(self.trainer, 'training_thread') and self.trainer.training_thread:
                self.trainer.stop_training()


if __name__ == '__main__'
        unittest.main()
