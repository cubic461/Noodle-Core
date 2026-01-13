"""
Converter::Onnx Parser - onnx_parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
ONNX Parser - Parseert ONNX modellen naar interne representatie
"""

import onnx
import numpy as np
import logging
from typing import Dict, List, Optional, Any, Union, Tuple
from dataclasses import dataclass, field
from enum import Enum

from onnx.onnx_ml_pb2 import AttributeProto

logger = logging.getLogger(__name__)


class TensorType(Enum):
    """Tensor type mapping"""
    FLOAT32 = "float32"
    FLOAT16 = "float16"
    INT32 = "int32"
    INT64 = "int64"
    BOOL = "bool"
    STRING = "string"


@dataclass
class TensorInfo:
    """Tensor informatie"""
    name: str
    shape: List[int]
    dtype: TensorType
    data: Optional[np.ndarray] = None
    is_input: bool = False
    is_output: bool = False
    attributes: Dict[str, Any] = field(default_factory=dict)


@dataclass
class NodeInfo:
    """Knoop informatie"""
    name: str
    op_type: str
    inputs: List[str]
    outputs: List[str]
    attributes: Dict[str, Any] = field(default_factory=dict)
    domain: str = ""
    version: int = 1


@dataclass
class GraphInfo:
    """Graaf informatie"""
    name: str
    inputs: List[TensorInfo]
    outputs: List[TensorInfo]
    nodes: List[NodeInfo]
    initializer: List[TensorInfo] = field(default_factory=list)
    training_info: Dict[str, Any] = field(default_factory=dict)


class ONNXParser:
    """Parseert ONNX modellen naar interne GraphInfo representatie"""
    
    def __init__(self):
        self.model = None
        self.graph_info = None
        
    def parse_model(self, model_path: str) -> GraphInfo:
        """
        Parseer een ONNX modelbestand
        
        Args:
            model_path: Pad naar ONNX modelbestand
            
        Returns:
            GraphInfo object met modelinformatie
        """
        try:
            # Laad het ONNX model
            self.model = onnx.load(model_path)
            
            # Valideer het model
            onnx.checker.check_model(self.model)
            
            # Parseer de grafiek
            self.graph_info = self._parse_graph(self.model.graph)
            
            logger.info(f"Succesvol geparseerd: {model_path}")
            logger.info(f"Grafiek: {self.graph_info.name}")
            logger.info(f"Nodes: {len(self.graph_info.nodes)}")
            logger.info(f"Inputs: {len(self.graph_info.inputs)}")
            logger.info(f"Outputs: {len(self.graph_info.outputs)}")
            
            return self.graph_info
            
        except Exception as e:
            logger.error(f"Fout bij parsen van {model_path}: {e}")
            raise
    
    def parse_from_bytes(self, model_bytes: bytes) -> GraphInfo:
        """
        Parseer een ONNX model uit bytes
        
        Args:
            model_bytes: ONNX model als bytes
            
        Returns:
            GraphInfo object met modelinformatie
        """
        try:
            # Laad het ONNX model uit bytes
            self.model = onnx.load_model_from_string(model_bytes)
            
            # Valideer het model
            onnx.checker.check_model(self.model)
            
            # Parseer de grafiek
            self.graph_info = self._parse_graph(self.model.graph)
            
            logger.info("Succesvol geparseerd uit bytes")
            return self.graph_info
            
        except Exception as e:
            logger.error(f"Fout bij parsen uit bytes: {e}")
            raise
    
    def _parse_graph(self, graph) -> GraphInfo:
        """
        Parseer een ONNX grafiek
        
        Args:
            graph: ONNX grafiek object
            
        Returns:
            GraphInfo object
        """
        # Parseer inputs
        inputs = []
        for input_tensor in graph.input:
            tensor_info = self._parse_tensor(input_tensor, is_input=True)
            inputs.append(tensor_info)
        
        # Parseer outputs
        outputs = []
        for output_tensor in graph.output:
            tensor_info = self._parse_tensor(output_tensor, is_output=True)
            outputs.append(tensor_info)
        
        # Parseer initializers
        initializers = []
        for initializer in graph.initializer:
            tensor_info = self._parse_tensor(initializer, is_initializer=True)
            initializers.append(tensor_info)
        
        # Parseer nodes
        nodes = []
        for node in graph.node:
            node_info = self._parse_node(node)
            nodes.append(node_info)
        
        # Creer GraphInfo
        graph_info = GraphInfo(
            name=graph.name,
            inputs=inputs,
            outputs=outputs,
            nodes=nodes,
            initializer=initializers
        )
        
        return graph_info
    
    def _parse_tensor(self, tensor, is_input: bool = False, 
                     is_output: bool = False, is_initializer: bool = False) -> TensorInfo:
        """
        Parseer een ONNX tensor
        
        Args:
            tensor: ONNX tensor object
            is_input: Is dit een input tensor?
            is_output: Is dit een output tensor?
            is_initializer: Is dit een initializer tensor?
            
        Returns:
            TensorInfo object
        """
        # Parseer shape
        if hasattr(tensor, 'dims'):
            shape = list(tensor.dims)
        elif hasattr(tensor, 'type') and hasattr(tensor.type, 'tensor_type') and hasattr(tensor.type.tensor_type, 'shape'):
            shape = [dim.dim_value for dim in tensor.type.tensor_type.shape.dim]
        else:
            shape = []
        
        # Parseer dtype
        if hasattr(tensor, 'data_type'):
            dtype = self._map_onnx_dtype(tensor.data_type)
        elif hasattr(tensor, 'type') and hasattr(tensor.type, 'tensor_type') and hasattr(tensor.type.tensor_type, 'elem_type'):
            dtype = self._map_onnx_dtype(tensor.type.tensor_type.elem_type)
        else:
            dtype = TensorType.FLOAT32
        
        # Haal data op als het een initializer is
        data = None
        if is_initializer:
            data = onnx.numpy_helper.to_array(tensor)
        
        # Creer TensorInfo
        tensor_info = TensorInfo(
            name=tensor.name,
            shape=shape,
            dtype=dtype,
            data=data,
            is_input=is_input,
            is_output=is_output
        )
        
        return tensor_info
    
    def _parse_node(self, node) -> NodeInfo:
        """
        Parseer een ONNX node
        
        Args:
            node: ONNX node object
            
        Returns:
            NodeInfo object
        """
        # Parseer attributes
        attributes = {}
        for attr in node.attribute:
            attributes[attr.name] = self._parse_attribute(attr)
        
        # Creer NodeInfo
        version = 1
        if hasattr(node, 'opset_import') and node.opset_import:
            version = node.opset_import[0].version
        
        node_info = NodeInfo(
            name=node.name,
            op_type=node.op_type,
            inputs=list(node.input),
            outputs=list(node.output),
            attributes=attributes,
            domain=node.domain,
            version=version
        )
        
        return node_info
    
    def _parse_attribute(self, attr) -> Any:
        """
        Parseer een ONNX attribute
        
        Args:
            attr: ONNX attribute object
            
        Returns:
            Geparsed attribute waarde
        """
        if attr.type == AttributeProto.FLOAT:
            return attr.f
        elif attr.type == AttributeProto.INT:
            return attr.i
        elif attr.type == AttributeProto.STRING:
            return attr.s.decode('utf-8')
        elif attr.type == AttributeProto.TENSOR:
            return onnx.numpy_helper.to_array(attr.t)
        elif attr.type == AttributeProto.GRAPH:
            # Recursief parsen van geneste grafieken
            return self._parse_graph(attr.graph)
        elif attr.type == AttributeProto.FLOATS:
            return list(attr.floats)
        elif attr.type == AttributeProto.INTS:
            return list(attr.ints)
        elif attr.type == AttributeProto.STRINGS:
            return [s.decode('utf-8') for s in attr.strings]
        else:
            logger.warning(f"Ondersteunde attribute type: {attr.type}")
            return None
    
    def _map_onnx_dtype(self, onnx_dtype: int) -> TensorType:
        """
        Map ONNX data type naar TensorType
        
        Args:
            onnx_dtype: ONNX data type
            
        Returns:
            TensorType enum
        """
        dtype_map = {
            onnx.TensorProto.FLOAT: TensorType.FLOAT32,
            onnx.TensorProto.FLOAT16: TensorType.FLOAT16,
            onnx.TensorProto.DOUBLE: TensorType.FLOAT32,  # Gebruik float32 als default
            onnx.TensorProto.INT32: TensorType.INT32,
            onnx.TensorProto.INT64: TensorType.INT64,
            onnx.TensorProto.BOOL: TensorType.BOOL,
            onnx.TensorProto.STRING: TensorType.STRING,
        }
        
        return dtype_map.get(onnx_dtype, TensorType.FLOAT32)
    
    def get_supported_ops(self) -> List[str]:
        """
        Krijg lijst met ondersteunde operaties
        
        Returns:
            Lijst met operatie types
        """
        if not self.graph_info:
            return []
        
        return list(set(node.op_type for node in self.graph_info.nodes))
    
    def get_model_info(self) -> Dict[str, Any]:
        """
        Krijg model informatie als dictionary
        
        Returns:
            Model informatie dictionary
        """
        if not self.graph_info:
            return {}
        
        return {
            'model_name': self.model.graph.name,
            'model_version': self.model.model_version,
            'producer_name': self.model.producer_name,
            'producer_version': self.model.producer_version,
            'domain': self.model.domain,
            'opset_version': self.model.opset_import[0].version if self.model.opset_import else None,
            'inputs': [
                {
                    'name': tensor.name,
                    'shape': tensor.shape,
                    'dtype': tensor.dtype.value
                }
                for tensor in self.graph_info.inputs
            ],
            'outputs': [
                {
                    'name': tensor.name,
                    'shape': tensor.shape,
                    'dtype': tensor.dtype.value
                }
                for tensor in self.graph_info.outputs
            ],
            'nodes': len(self.graph_info.nodes),
            'supported_ops': self.get_supported_ops()
        }
    
    def validate_compatibility(self) -> Tuple[bool, List[str]]:
        """
        Valideer compatibiliteit met NoodleCore
        
        Args:
            Tuple van (is_compatible, error_messages)
        """
        if not self.graph_info:
            return False, ["Geen model geladen"]
        
        errors = []
        warnings = []
        
        # Controleer op ondersteunde operaties
        supported_ops = self.get_supported_ops()
        unsupported_ops = []
        
        # Basis lijst met ondersteunde operaties
        noodlecore_ops = [
            'Add', 'Sub', 'Mul', 'Div', 'MatMul', 'Transpose',
            'Reshape', 'Concat', 'Slice', 'Gather', 'Scatter',
            'Relu', 'Sigmoid', 'Tanh', 'Softmax', 'Dropout',
            'Conv', 'Pool', 'BatchNorm', 'Linear', 'Flatten'
        ]
        
        for op in supported_ops:
            if op not in noodlecore_ops:
                unsupported_ops.append(op)
        
        if unsupported_ops:
            errors.append(f"Ondersteunde operaties ontbreken: {unsupported_ops}")
        
        # Controleer tensor types
        for tensor in self.graph_info.inputs + self.graph_info.outputs:
            if tensor.dtype not in [TensorType.FLOAT32, TensorType.FLOAT16]:
                warnings.append(f"Niet-standaard tensor type: {tensor.dtype}")
        
        # Controleer tensor shapes
        for tensor in self.graph_info.inputs + self.graph_info.outputs:
            if -1 in tensor.shape:  # Dynamische dimensies
                warnings.append(f"Dynamische dimensie gevonden in: {tensor.name}")
        
        is_compatible = len(errors) == 0
        all_messages = errors + warnings
        
        return is_compatible, all_messages
    
    def export_graphviz(self, output_path: str):
        """
        Exporteer de grafiek naar Graphviz formaat
        
        Args:
            output_path: Pad voor outputbestand
        """
        if not self.graph_info:
            raise ValueError("Geen model geladen")
        
        dot_content = []
        dot_content.append("digraph ONNX_Graph {")
        dot_content.append("  rankdir=LR;")
        dot_content.append("  node [shape=box];")
        
        # Voeg input nodes toe
        for tensor in self.graph_info.inputs:
            dot_content.append(f'  "{tensor.name}" [label="{tensor.name}\\nInput" style=filled fillcolor=lightgreen];')
        
        # Voeg output nodes toe
        for tensor in self.graph_info.outputs:
            dot_content.append(f'  "{tensor.name}" [label="{tensor.name}\\nOutput" style=filled fillcolor=lightcoral];')
        
        # Voeg operatie nodes toe
        for node in self.graph_info.nodes:
            dot_content.append(f'  "{node.name}" [label="{node.op_type}"];')
        
        # Voeg edges toe
        for node in self.graph_info.nodes:
            for input_name in node.inputs:
                dot_content.append(f'  "{input_name}" -> "{node.name}";')
            for output_name in node.outputs:
                dot_content.append(f'  "{node.name}" -> "{output_name}";')
        
        dot_content.append("}")
        
        # Schrijf naar bestand
        with open(output_path, 'w') as f:
            f.write('\n'.join(dot_content))
        
        logger.info(f"Grafiek geÃ«xporteerd naar: {output_path}")


