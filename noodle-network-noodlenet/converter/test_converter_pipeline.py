"""
Test Suite::Converter - test_converter_pipeline.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script voor de volledige converter pipeline
"""

import sys
import os
import tempfile
import logging
import json
import numpy as np

# Voeg de converter module toe aan de Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from onnx_parser import ONNXParser
from tensor_types import create_tensor_property, NoodleTensorType, MemoryLayout
from ntir_generator import NTIRGenerator
from matrix_optimizer import MatrixOptimizer, OptimizationContext, MatrixOperationInfo, MatrixOperation
from nbc_bridge import NBCBridge, CompilationContext, NBCCompilationTarget, NBCOptimizationLevel

# Configureer logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def create_simple_onnx_model():
    """CreÃ«er een eenvoudig ONNX model voor test doeleinden"""
    try:
        import onnx
        from onnx import helper, TensorProto
        
        # CreÃ«er een simpel model met een paar basis operaties
        input_tensor = helper.make_tensor_value_info('input', TensorProto.FLOAT, [1, 3, 32, 32])
        output_tensor = helper.make_tensor_value_info('output', TensorProto.FLOAT, [1, 16, 30, 30])
        
        # Maak een convolutie operatie
        conv_node = helper.make_node(
            'Conv',
            inputs=['input', 'weight', 'bias'],
            outputs=['output'],
            kernel_shape=[3, 3],
            pads=[0, 0, 0, 0]
        )
        
        # Maak weight en bias tensors
        weight_data = np.random.randn(16, 3, 3, 3).astype(np.float32)
        bias_data = np.random.randn(16).astype(np.float32)
        
        weight_tensor = helper.make_tensor(
            'weight',
            TensorProto.FLOAT,
            [16, 3, 3, 3],
            weight_data.flatten().tolist()
        )
        
        bias_tensor = helper.make_tensor(
            'bias',
            TensorProto.FLOAT,
            [16],
            bias_data.flatten().tolist()
        )
        
        # Maak het grafiek
        graph = helper.make_graph(
            [conv_node],
            'simple_conv_model',
            [input_tensor],
            [output_tensor],
            [weight_tensor, bias_tensor]
        )
        
        # Maak het model
        model = helper.make_model(graph)
        
        # Sla het model op
        model_path = os.path.join(tempfile.gettempdir(), 'simple_conv_model.onnx')
        onnx.save(model, model_path)
        
        logger.info(f"Test ONNX model aangemaakt: {model_path}")
        return model_path
        
    except Exception as e:
        logger.error(f"Fout bij aanmaken ONNX model: {e}")
        return None


def test_onnx_parser(model_path):
    """Test de ONNX parser"""
    logger.info("=== Test ONNX Parser ===")
    
    try:
        parser = ONNXParser()
        graph_info = parser.parse_model(model_path)
        
        logger.info(f"Model naam: {graph_info.name}")
        logger.info(f"Aantal inputs: {len(graph_info.inputs)}")
        logger.info(f"Aantal outputs: {len(graph_info.outputs)}")
        logger.info(f"Aantal nodes: {len(graph_info.nodes)}")
        
        # Print model info
        model_info = parser.get_model_info()
        logger.info(f"Model info: {json.dumps(model_info, indent=2)}")
        
        # Controleer compatibiliteit
        is_compatible, messages = parser.validate_compatibility()
        logger.info(f"Compatibiliteit: {is_compatible}")
        for msg in messages:
            logger.info(f"  - {msg}")
        
        return graph_info
        
    except Exception as e:
        logger.error(f"Fout in ONNX parser test: {e}")
        return None


def test_tensor_types():
    """Test het tensor type systeem"""
    logger.info("=== Test Tensor Types ===")
    
    try:
        # Maak tensor properties
        tensor1 = create_tensor_property(
            name="input_tensor",
            shape=[1, 3, 32, 32],
            dtype=NoodleTensorType.FLOAT32,
            layout=MemoryLayout.NCHW,
            requires_grad=True
        )
        
        tensor2 = create_tensor_property(
            name="weight_tensor",
            shape=[16, 3, 3, 3],
            dtype=NoodleTensorType.FLOAT32,
            layout=MemoryLayout.NCHW
        )
        
        # Print tensor info
        logger.info(f"Tensor 1: {tensor1.to_dict()}")
        logger.info(f"Tensor 2: {tensor2.to_dict()}")
        
        # Test broadcasten
        can_broadcast = tensor1.can_broadcast_to(tensor2)
        logger.info(f"Kan broadcasten: {can_broadcast}")
        
        return [tensor1, tensor2]
        
    except Exception as e:
        logger.error(f"Fout in tensor types test: {e}")
        return None


def test_ntir_generator(graph_info):
    """Test de NTIR generator"""
    logger.info("=== Test NTIR Generator ===")
    
    try:
        generator = NTIRGenerator()
        ntir_program = generator.generate_from_graph(graph_info)
        
        logger.info(f"NTIR programma gegenereerd")
        logger.info(f"Aantal functies: {len(ntir_program.functions)}")
        logger.info(f"Aantal globals: {len(ntir_program.globals)}")
        
        # Print NTIR program
        logger.info(f"NTIR JSON: {ntir_program.to_json(indent=2)}")
        
        # Optimaliseer NTIR program
        optimized_program = generator.optimize_program(ntir_program)
        logger.info(f"Optimalisatie voltooid")
        
        # Valideer NTIR program
        is_valid, errors = generator.validate_program(optimized_program)
        logger.info(f"Validatie: {is_valid}")
        for error in errors:
            logger.error(f"  - {error}")
        
        return optimized_program
        
    except Exception as e:
        logger.error(f"Fout in NTIR generator test: {e}")
        return None


def test_matrix_optimizer(ntir_program):
    """Test de matrix optimizer"""
    logger.info("=== Test Matrix Optimizer ===")
    
    try:
        # Maak context
        context = OptimizationContext(
            available_memory=1024 * 1024 * 1024,
            available_cores=8,
            target_precision=NoodleTensorType.FLOAT32,
            enable_vectorization=True,
            enable_parallelization=True,
            enable_memory_optimization=True
        )
        
        optimizer = MatrixOptimizer(context)
        
        # Maak test operaties
        operations = []
        
        # Add operatie
        add_tensor = create_tensor_property("add_input", [10, 10], NoodleTensorType.FLOAT32)
        add_op = MatrixOperationInfo(
            operation=MatrixOperation.ADD,
            inputs=[add_tensor, add_tensor],
            output=create_tensor_property("add_output", [10, 10], NoodleTensorType.FLOAT32)
        )
        operations.append(add_op)
        
        # Matmul operatie
        matmul_input1 = create_tensor_property("matmul1", [10, 5], NoodleTensorType.FLOAT32)
        matmul_input2 = create_tensor_property("matmul2", [5, 8], NoodleTensorType.FLOAT32)
        matmul_op = MatrixOperationInfo(
            operation=MatrixOperation.MATMUL,
            inputs=[matmul_input1, matmul_input2],
            output=create_tensor_property("matmul_output", [10, 8], NoodleTensorType.FLOAT32)
        )
        operations.append(matmul_op)
        
        # Optimaliseer operaties
        results = optimizer.optimize_batch(operations)
        
        logger.info(f"Optimalisatie resultaten:")
        for i, result in enumerate(results):
            logger.info(f"  Operatie {i+1}:")
            logger.info(f"    Strategie: {result.strategy.value}")
            logger.info(f"    Prestatie verbetering: {result.performance_improvement}x")
            logger.info(f"    Geheugen reductie: {result.memory_reduction*100}%")
            logger.info(f"    Energie besparing: {result.energy_savings*100}%")
        
        return results
        
    except Exception as e:
        logger.error(f"Fout in matrix optimizer test: {e}")
        return None


def test_nbc_bridge(ntir_program):
    """Test de NBC bridge"""
    logger.info("=== Test NBC Bridge ===")
    
    try:
        # Maak compilatie context
        compile_context = CompilationContext(
            target=NBCCompilationTarget.CPU,
            optimization_level=NBCOptimizationLevel.BASIC,
            debug_symbols=False,
            enable_vectorization=True,
            enable_parallelization=True,
            enable_memory_optimization=True
        )
        
        bridge = NBCBridge(compile_context)
        
        # Compileer NTIR naar NBC
        result = bridge.compile_ntir_to_nbc(ntir_program)
        
        logger.info(f"Compilatie resultaat:")
        logger.info(f"  Succes: {result.success}")
        logger.info(f"  Output pad: {result.output_path}")
        logger.info(f"  Binary pad: {result.binary_path}")
        
        if result.success:
            logger.info(f"  Metadata: {json.dumps(result.metadata, indent=2)}")
        else:
            logger.error(f"  Fouten: {result.errors}")
        
        # Valideer binary
        if result.success and result.binary_path:
            is_valid, validation_errors = bridge.validate_binary(result.binary_path)
            logger.info(f"  Binary validatie: {is_valid}")
            for error in validation_errors:
                logger.error(f"    - {error}")
        
        return result
        
    except Exception as e:
        logger.error(f"Fout in NBC bridge test: {e}")
        return None


def test_full_pipeline():
    """Test de volledige converter pipeline"""
    logger.info("=== Test Volledige Pipeline ===")
    
    try:
        # 1. Maak test ONNX model
        logger.info("1. Maak test ONNX model...")
        model_path = create_simple_onnx_model()
        if not model_path:
            logger.error("Kon geen test model aanmaken")
            return False
        
        # 2. Test ONNX parser
        logger.info("2. Test ONNX parser...")
        graph_info = test_onnx_parser(model_path)
        if not graph_info:
            logger.error("ONNX parser test mislukt")
            return False
        
        # 3. Test tensor types
        logger.info("3. Test tensor types...")
        tensors = test_tensor_types()
        if not tensors:
            logger.error("Tensor types test mislukt")
            return False
        
        # 4. Test NTIR generator
        logger.info("4. Test NTIR generator...")
        ntir_program = test_ntir_generator(graph_info)
        if not ntir_program:
            logger.error("NTIR generator test mislukt")
            return False
        
        # 5. Test matrix optimizer
        logger.info("5. Test matrix optimizer...")
        optimization_results = test_matrix_optimizer(ntir_program)
        if not optimization_results:
            logger.error("Matrix optimizer test mislukt")
            return False
        
        # 6. Test NBC bridge
        logger.info("6. Test NBC bridge...")
        compilation_result = test_nbc_bridge(ntir_program)
        if not compilation_result or not compilation_result.success:
            logger.error("NBC bridge test mislukt")
            return False
        
        logger.info("=== Pipeline Test Voltooid ===")
        logger.info("Alle componenten werken correct!")
        
        return True
        
    except Exception as e:
        logger.error(f"Fout in volledige pipeline test: {e}")
        return False


def main():
    """Hoofd functie"""
    logger.info("Start Converter Pipeline Test")
    
    # Test individuele componenten
    success = test_full_pipeline()
    
    if success:
        logger.info("âœ… Alle tests geslaagd!")
        return 0
    else:
        logger.error("â” Sommige tests zijn mislukt")
        return 1


if __name__ == "__main__":
    sys.exit(main())


