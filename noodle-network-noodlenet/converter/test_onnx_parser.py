"""
Test Suite::Converter - test_onnx_parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script voor de ONNX parser
"""

import sys
import os
import tempfile
import logging
import json
import numpy as np

# Voeg de converter module toe aan de Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from onnx_parser import ONNXParser, TensorType

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


def test_tensor_type_mapping():
    """Test de tensor type mapping"""
    logger.info("=== Test Tensor Type Mapping ===")
    
    # Test type mapping
    dtype_map = {
        1: TensorType.FLOAT32,
        10: TensorType.FLOAT16,
        6: TensorType.INT32,
        7: TensorType.INT64,
        9: TensorType.BOOL,
        8: TensorType.STRING,
    }
    
    logger.info("Tensor type mapping:")
    for onnx_type, noodle_type in dtype_map.items():
        logger.info(f"  {onnx_type} -> {noodle_type}")
    
    return True


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
        
        # Print tensor info
        logger.info("Input tensors:")
        for tensor in graph_info.inputs:
            logger.info(f"  {tensor.name}: shape={tensor.shape}, dtype={tensor.dtype}")
        
        logger.info("Output tensors:")
        for tensor in graph_info.outputs:
            logger.info(f"  {tensor.name}: shape={tensor.shape}, dtype={tensor.dtype}")
        
        # Print node info
        logger.info("Nodes:")
        for node in graph_info.nodes:
            logger.info(f"  {node.name}: {node.op_type} -> {node.inputs} -> {node.outputs}")
        
        # Controleer compatibiliteit
        is_compatible, messages = parser.validate_compatibility()
        logger.info(f"Compatibiliteit: {is_compatible}")
        for msg in messages:
            logger.info(f"  - {msg}")
        
        # Test ondersteunde operaties
        supported_ops = parser.get_supported_ops()
        logger.info(f"Ondersteunde operaties: {supported_ops}")
        
        return graph_info
        
    except Exception as e:
        logger.error(f"Fout in ONNX parser test: {e}")
        import traceback
        traceback.print_exc()
        return None


def main():
    """Hoofd functie"""
    logger.info("Start ONNX Parser Test")
    
    # Test tensor type mapping
    test_tensor_type_mapping()
    
    # Maak test ONNX model
    logger.info("Maak test ONNX model...")
    model_path = create_simple_onnx_model()
    if not model_path:
        logger.error("Kon geen test model aanmaken")
        return 1
    
    # Test ONNX parser
    logger.info("Test ONNX parser...")
    graph_info = test_onnx_parser(model_path)
    if not graph_info:
        logger.error("ONNX parser test mislukt")
        return 1
    
    logger.info("âœ… Alle tests geslaagd!")
    return 0


if __name__ == "__main__":
    sys.exit(main())


