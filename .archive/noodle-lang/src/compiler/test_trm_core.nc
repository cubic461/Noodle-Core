# Converted from Python to NoodleCore
# Original file: src

# """
# TRM Core Tests
 = =============

# Comprehensive tests for the TRM core implementation
# """

import unittest
import unittest.mock.Mock
import sys
import os

# Add the parent directory to the path so we can import TRM modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

import noodlecore.trm.trm_types.(
#     TRMNetwork, TRMLayer, TRMRecursiveFunction, TRMParameter,
#     TRMLatentState, TRMActivationFunction, TRMNodeType,
#     TRMTrainingConfig, TRMInferenceConfig
# )
import noodlecore.trm.trm_core.TRMCore
import noodlecore.compiler.types.BaseType
import noodlecore.compiler.nir.ir.Value


class TestTRMCore(unittest.TestCase)
    #     """Test cases for TRM core"""

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
    self.test_network.input_size = 3
    self.test_network.output_size = 2

    self.trm_core = TRMCore(self.test_network)

    #     def test_trm_core_creation(self):
    #         """Test TRM core creation"""
            self.assertIsInstance(self.trm_core, TRMCore)
            self.assertEqual(self.trm_core.network.name, "test_network")
            self.assertIsInstance(self.trm_core.parameters, dict)
            self.assertIsInstance(self.trm_core.latent_states, dict)
            self.assertFalse(self.trm_core.training_mode)

    #     def test_parameter_initialization(self):
    #         """Test parameter initialization"""
            self.assertEqual(len(self.trm_core.parameters), 2)
            self.assertIn("weight", self.trm_core.parameters)
            self.assertIn("bias", self.trm_core.parameters)

    weight_param = self.trm_core.parameters["weight"]
            self.assertEqual(weight_param.name, "weight")
            self.assertEqual(weight_param.value, [[1.0, 0.5], [0.5, 1.0], [0.25, 0.75]])
            self.assertTrue(weight_param.requires_grad)

    #     def test_latent_state_initialization(self):
    #         """Test latent state initialization"""
            self.assertEqual(len(self.trm_core.latent_states), 0)

    #     def test_forward_pass_simple(self):
    #         """Test simple forward pass"""
    inputs = [1.0, 2.0, 3.0]
    outputs = self.trm_core.forward(inputs)

    #         # Should return output of correct size
            self.assertEqual(len(outputs), 2)
            # All outputs should be floats (current placeholder implementation)
    #         for output in outputs:
                self.assertIsInstance(output, float)

    #     def test_forward_pass_with_empty_network(self):
    #         """Test forward pass with empty network"""
    empty_network = TRMNetwork(name="empty_network")
    empty_core = TRMCore(empty_network)

    inputs = [1.0, 2.0, 3.0]
    outputs = empty_core.forward(inputs)

            self.assertEqual(len(outputs), 0)

    #     def test_forward_pass_single_input(self):
    #         """Test forward pass with single input"""
    single_input_network = TRMNetwork(name="single_input")
    single_layer = TRMLayer(
    layer_type = TRMNodeType.FEEDFORWARD,
    input_size = 1,
    output_size = 1,
    activation = TRMActivationFunction.LINEAR
    #         )
            single_layer.parameters.append(TRMParameter(
    name = "weight",
    value = [[2.0]],
    requires_grad = True
    #         ))
            single_layer.parameters.append(TRMParameter(
    name = "bias",
    value = [1.0],
    requires_grad = True
    #         ))
            single_input_network.layers.append(single_layer)

    single_core = TRMCore(single_input_network)
    inputs = [3.0]
    outputs = single_core.forward(inputs)

    # Should return 2.0 * 3.0 + 1.0 = 7.0
    self.assertAlmostEqual(outputs[0], 7.0, places = 5)

    #     def test_forward_pass_with_latent_states(self):
    #         """Test forward pass with latent states"""
    network_with_latent = TRMNetwork(name="latent_network")
            network_with_latent.latent_states.append(TRMLatentState(
    name = "latent_1",
    size = 2,
    value = [0.1, 0.2]
    #         ))

    core_with_latent = TRMCore(network_with_latent)
    inputs = [1.0, 2.0, 3.0]
    outputs = core_with_latent.forward(inputs)

            self.assertEqual(len(outputs), 2)

    #     def test_forward_pass_recursive_layer(self):
    #         """Test forward pass with recursive layer"""
    recursive_network = TRMNetwork(name="recursive_network")
    recursive_layer = TRMLayer(
    layer_type = TRMNodeType.RECURSIVE,
    input_size = 2,
    output_size = 2,
    activation = TRMActivationFunction.TANH
    #         )
            recursive_network.layers.append(recursive_layer)

    recursive_core = TRMCore(recursive_network)
    inputs = [1.0, 2.0]
    outputs = recursive_core.forward(inputs)

            self.assertEqual(len(outputs), 2)

    #     def test_forward_pass_attention_layer(self):
    #         """Test forward pass with attention layer"""
    attention_network = TRMNetwork(name="attention_network")
    attention_layer = TRMLayer(
    layer_type = TRMNodeType.ATTENTION,
    input_size = 3,
    output_size = 3,
    activation = TRMActivationFunction.SOFTMAX
    #         )
            attention_network.layers.append(attention_layer)

    attention_core = TRMCore(attention_network)
    inputs = [1.0, 2.0, 3.0]
    outputs = attention_core.forward(inputs)

            self.assertEqual(len(outputs), 3)

    #     def test_forward_pass_output_layer(self):
    #         """Test forward pass with output layer"""
    output_network = TRMNetwork(name="output_network")
    hidden_layer = TRMLayer(
    layer_type = TRMNodeType.FEEDFORWARD,
    input_size = 3,
    output_size = 4,
    activation = TRMActivationFunction.RELU
    #         )
    output_layer = TRMLayer(
    layer_type = TRMNodeType.OUTPUT,
    input_size = 4,
    output_size = 2,
    activation = TRMActivationFunction.LINEAR
    #         )

            output_network.layers.extend([hidden_layer, output_layer])
    output_core = TRMCore(output_network)

    inputs = [1.0, 2.0, 3.0]
    outputs = output_core.forward(inputs)

            self.assertEqual(len(outputs), 2)

    #     def test_train_step(self):
    #         """Test single training step"""
    train_inputs = [1.0, 2.0, 3.0]
    train_targets = [2.0, 1.0]

    metrics = self.trm_core.train_step(train_inputs, train_targets)

            self.assertIsInstance(metrics, dict)
            self.assertIn("loss", metrics)
            self.assertIn("learning_rate", metrics)
            self.assertIsInstance(metrics["loss"], float)
            self.assertIsInstance(metrics["learning_rate"], float)

    #     def test_train_step_mismatched_sizes(self):
    #         """Test training step with mismatched input/output sizes"""
    train_inputs = [1.0, 2.0, 3.0]
    train_targets = [1.0]  # Wrong size

    #         with self.assertRaises(ValueError):
                self.trm_core.train_step(train_inputs, train_targets)

    #     def test_compute_loss(self):
    #         """Test loss computation"""
    outputs = [2.0, 3.0]
    targets = [1.0, 2.0]

    loss = self.trm_core._compute_loss(outputs, targets)

            self.assertIsInstance(loss, float)
    # MSE loss: ((2.0-1.0)^2 + (3.0-2.0)^2) / 2 = 1.0
    self.assertAlmostEqual(loss, 1.0, places = 5)

    #     def test_compute_loss_mismatched_sizes(self):
    #         """Test loss computation with mismatched sizes"""
    outputs = [1.0, 2.0, 3.0]
    targets = [1.0, 2.0]

    #         with self.assertRaises(ValueError):
                self.trm_core._compute_loss(outputs, targets)

    #     def test_backward_pass(self):
    #         """Test backward pass"""
    inputs = [1.0, 2.0, 3.0]
    outputs = [2.0, 1.0]
    targets = [1.0, 2.0]

    #         # Should not raise any exceptions
            self.trm_core._backward_pass(inputs, outputs, targets)

    #         # Check that gradients were computed
    #         for param in self.trm_core.parameters.values():
    #             if param.requires_grad:
                    self.assertIsNotNone(param.grad)

    #     def test_parameter_update(self):
    #         """Test parameter updates"""
    #         # Set initial gradients
    #         for param in self.trm_core.parameters.values():
    #             if param.requires_grad:
    param.grad = 0.1

    #         # Perform parameter update
            self.trm_core._update_parameters()

    #         # Check that parameters were updated
    #         for param in self.trm_core.parameters.values():
    #             if param.requires_grad:
                    self.assertIsNotNone(param.value)
    #                 # Gradients should be reset
                    self.assertIsNone(param.grad)

    #     def test_training_mode_toggle(self):
    #         """Test training mode toggle"""
    #         # Start in inference mode
            self.assertFalse(self.trm_core.training_mode)

    #         # Train method should set training mode
    #         with patch.object(self.trm_core, 'train_step') as mock_train_step:
    mock_train_step.return_value = {"loss": 0.5, "learning_rate": 0.001}

                self.trm_core.train(
    TRMTrainingConfig(epochs = 1),
                    [([1.0, 2.0, 3.0], [1.0, 2.0])]
    #             )

                self.assertTrue(self.trm_core.training_mode)

    #     def test_to_ir(self):
    #         """Test IR conversion"""
    ir_module = self.trm_core.to_ir()

            self.assertIsInstance(ir_module, Module)
            self.assertEqual(ir_module.name, "test_network")

    #     def test_ir_builder_functionality(self):
    #         """Test IR builder functionality"""
    builder = self.trm_core.ir_builder

    #         # Test constant creation
    const_value = builder.create_constant(1.0, "float32", "test_const")
            self.assertIsInstance(const_value, Value)

    #         # Test add operation
    add_result = builder.create_add_operation(const_value, const_value)
            self.assertIsInstance(add_result, Value)

    #     def test_process_layer_types(self):
    #         """Test different layer type processing"""
    #         # Test feedforward layer
    ff_layer = TRMLayer(
    layer_type = TRMNodeType.FEEDFORWARD,
    input_size = 2,
    output_size = 2,
    activation = TRMActivationFunction.RELU
    #         )
            ff_layer.parameters.append(TRMParameter(
    name = "weight",
    value = [[1.0, 0.5], [0.5, 1.0]],
    requires_grad = True
    #         ))

    ff_inputs = [Mock(), Mock()]
    ff_result = self.trm_core._process_feedforward_layer(ff_layer, ff_inputs)
            self.assertIsInstance(ff_result, list)

    #     def test_activation_functions(self):
    #         """Test activation function application"""
    #         # Test different activation functions
    test_value = Mock()

    relu_result = self.trm_core._apply_activation(test_value, TRMActivationFunction.RELU)
            self.assertIsInstance(relu_result, Value)

    sigmoid_result = self.trm_core._apply_activation(test_value, TRMActivationFunction.SIGMOID)
            self.assertIsInstance(sigmoid_result, Value)

    tanh_result = self.trm_core._apply_activation(test_value, TRMActivationFunction.TANH)
            self.assertIsInstance(tanh_result, Value)

    #     def test_layer_optimization(self):
    #         """Test network optimization"""
            # Test layer fusion (currently placeholder)
    original_network = TRMNetwork(name="test")
            original_network.layers.append(TRMLayer(
    layer_type = TRMNodeType.FEEDFORWARD,
    input_size = 2,
    output_size = 2,
    activation = TRMActivationFunction.RELU
    #         ))

    #         # Should not raise exceptions
    optimized_network = self.trm_core._optimize_trm_network(original_network)
            self.assertIsInstance(optimized_network, TRMNetwork)

    #     def test_inference_mode(self):
    #         """Test inference mode"""
    config = TRMInferenceConfig(
    batch_size = 1,
    temperature = 1.0,
    do_sample = False
    #         )

    inputs = [1.0, 2.0, 3.0]
    outputs = self.trm_core.infer(inputs, config)

            self.assertIsInstance(outputs, list)
            self.assertEqual(len(outputs), 2)  # Based on our test network

    #     def test_invalid_layer_type(self):
    #         """Test handling of invalid layer types"""
    invalid_layer = TRMLayer(
    layer_type = "invalid_type",  # This should be an enum value
    input_size = 2,
    output_size = 2,
    activation = TRMActivationFunction.RELU
    #         )

    inputs = [Mock(), Mock()]

    #         with self.assertRaises(ValueError):
                self.trm_core._process_layer(invalid_layer, inputs)

    #     def tearDown(self):
    #         """Clean up test fixtures"""
    #         # Reset any global state if needed
    #         pass


if __name__ == '__main__'
        unittest.main()
