"""
Converter::Ntir Generator - ntir_generator.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NTIR Generator - Genereert NTIR (Noodle Tensor Intermediate Representation) code
"""

import json
import logging
import numpy as np
from typing import Dict, List, Optional, Any, Union, Tuple
from dataclasses import dataclass, field, asdict
from enum import Enum

from onnx_parser import ONNXParser, GraphInfo, NodeInfo, TensorInfo
from tensor_types import (
    NoodleTensorType, MemoryLayout, TensorShape, TensorProperty,
    create_tensor_property, get_dtype_info
)

logger = logging.getLogger(__name__)


class NTIROpcode(Enum):
    """NTIR operatie codes"""
    # Basis operaties
    LOAD = "load"
    STORE = "store"
    ADD = "add"
    SUB = "sub"
    MUL = "mul"
    DIV = "div"
    MATMUL = "matmul"
    
    # Tensor manipulatie
    RESHAPE = "reshape"
    TRANSPOSE = "transpose"
    CONCAT = "concat"
    SLICE = "slice"
    GATHER = "gather"
    SCATTER = "scatter"
    
    # Activaties
    RELU = "relu"
    SIGMOID = "sigmoid"
    TANH = "tanh"
    SOFTMAX = "softmax"
    DROPOUT = "dropout"
    
    # Convolutionele operaties
    CONV = "conv"
    CONV_TRANSPOSE = "conv_transpose"
    POOL = "pool"
    BATCH_NORM = "batch_norm"
    
    # Lineaire operaties
    LINEAR = "linear"
    FLATTEN = "flatten"
    
    # Controle stroom
    IF = "if"
    FOR = "for"
    WHILE = "while"
    
    # Meta operaties
    NOP = "nop"
    RETURN = "return"


@dataclass
class NTIRInstruction:
    """NTIR instructie"""
    opcode: NTIROpcode
    operands: List[str]
    result: Optional[str] = None
    attributes: Dict[str, Any] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        # Converteer numpy arrays in attributes naar JSON-veilige formaten
        attributes = self._convert_for_json(self.attributes)
        metadata = self._convert_for_json(self.metadata)
        
        return {
            'opcode': self.opcode.value,
            'operands': self.operands,
            'result': self.result,
            'attributes': attributes,
            'metadata': metadata
        }
    
    @staticmethod
    def _convert_for_json(data: Any) -> Any:
        """
        Converteer data naar JSON-veilige format
        
        Args:
            data: Te converteren data
            
        Returns:
            JSON-veilige data
        """
        if isinstance(data, dict):
            return {key: NTIRInstruction._convert_for_json(value) for key, value in data.items()}
        elif isinstance(data, list):
            return [NTIRInstruction._convert_for_json(item) for item in data]
        elif isinstance(data, tuple):
            return list(NTIRInstruction._convert_for_json(list(data)))
        elif hasattr(data, 'tolist'):  # Numpy array of scalar
            return data.tolist()
        elif isinstance(data, np.integer):
            return int(data)
        elif isinstance(data, np.floating):
            return float(data)
        elif isinstance(data, np.bool_):
            return bool(data)
        else:
            return data
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'NTIRInstruction':
        """Maak NTIRInstruction van dictionary"""
        return cls(
            opcode=NTIROpcode(data['opcode']),
            operands=data['operands'],
            result=data.get('result'),
            attributes=data.get('attributes', {}),
            metadata=data.get('metadata', {})
        )


@dataclass
class NTIRBlock:
    """NTIR code blok"""
    name: str
    instructions: List[NTIRInstruction] = field(default_factory=list)
    variables: Dict[str, TensorProperty] = field(default_factory=dict)
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def add_instruction(self, instruction: NTIRInstruction):
        """Voeg instructie toe"""
        self.instructions.append(instruction)
    
    def add_variable(self, name: str, tensor: TensorProperty):
        """Voeg variabele toe"""
        self.variables[name] = tensor
    
    def find_variable(self, name: str) -> Optional[TensorProperty]:
        """Zoek variabele"""
        return self.variables.get(name)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        # Converteer attributen naar JSON-veilige format
        attributes = NTIRInstruction._convert_for_json(self.attributes)
        
        return {
            'name': self.name,
            'instructions': [inst.to_dict() for inst in self.instructions],
            'variables': {name: var.to_dict() for name, var in self.variables.items()},
            'attributes': attributes
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'NTIRBlock':
        """Maak NTIRBlock van dictionary"""
        block = cls(
            name=data['name'],
            attributes=data.get('attributes', {})
        )
        
        # Laad instructies
        for inst_data in data.get('instructions', []):
            block.add_instruction(NTIRInstruction.from_dict(inst_data))
        
        # Laad variabelen
        for name, var_data in data.get('variables', {}).items():
            block.add_variable(name, TensorProperty.from_dict(var_data))
        
        return block


@dataclass
class NTIRFunction:
    """NTIR functie"""
    name: str
    return_type: str
    parameters: List[TensorProperty] = field(default_factory=list)
    blocks: List[NTIRBlock] = field(default_factory=list)
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def add_block(self, block: NTIRBlock):
        """Voeg blok toe"""
        self.blocks.append(block)
    
    def find_block(self, name: str) -> Optional[NTIRBlock]:
        """Zoek blok"""
        for block in self.blocks:
            if block.name == name:
                return block
        return None
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        # Converteer attributen naar JSON-veilige format
        attributes = NTIRInstruction._convert_for_json(self.attributes)
        
        return {
            'name': self.name,
            'return_type': self.return_type,
            'parameters': [param.to_dict() for param in self.parameters],
            'blocks': [block.to_dict() for block in self.blocks],
            'attributes': attributes
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'NTIRFunction':
        """Maak NTIRFunction van dictionary"""
        func = cls(
            name=data['name'],
            return_type=data['return_type'],
            attributes=data.get('attributes', {})
        )
        
        # Laad parameters
        for param_data in data.get('parameters', []):
            func.parameters.append(TensorProperty.from_dict(param_data))
        
        # Laad blokken
        for block_data in data.get('blocks', []):
            func.add_block(NTIRBlock.from_dict(block_data))
        
        return func


@dataclass
class NTIRProgram:
    """NTIR programma"""
    functions: List[NTIRFunction] = field(default_factory=list)
    globals: Dict[str, TensorProperty] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def add_function(self, func: NTIRFunction):
        """Voeg functie toe"""
        self.functions.append(func)
    
    def find_function(self, name: str) -> Optional[NTIRFunction]:
        """Zoek functie"""
        for func in self.functions:
            if func.name == name:
                return func
        return None
    
    def add_global(self, name: str, tensor: TensorProperty):
        """Voeg globale variabele toe"""
        self.globals[name] = tensor
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'functions': [func.to_dict() for func in self.functions],
            'globals': {name: var.to_dict() for name, var in self.globals.items()},
            'metadata': self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'NTIRProgram':
        """Maak NTIRProgram van dictionary"""
        program = cls(metadata=data.get('metadata', {}))
        
        # Laad functies
        for func_data in data.get('functions', []):
            program.add_function(NTIRFunction.from_dict(func_data))
        
        # Laad globals
        for name, var_data in data.get('globals', {}).items():
            program.add_global(name, TensorProperty.from_dict(var_data))
        
        return program
    
    def to_json(self, indent: int = 2) -> str:
        """Exporteer naar JSON"""
        return json.dumps(self.to_dict(), indent=indent)
    
    @classmethod
    def from_json(cls, json_str: str) -> 'NTIRProgram':
        """Importeer uit JSON"""
        data = json.loads(json_str)
        return cls.from_dict(data)


class NTIRGenerator:
    """Genereert NTIR code uit ONNX modellen"""
    
    def __init__(self):
        self.parser = ONNXParser()
        self.program = NTIRProgram()
        self.current_function = None
        self.current_block = None
        self.temp_counter = 0
        
    def generate_from_onnx(self, model_path: str) -> NTIRProgram:
        """
        Genereer NTIR uit ONNX model
        
        Args:
            model_path: Pad naar ONNX modelbestand
            
        Returns:
            NTIRProgram
        """
        try:
            # Parseer ONNX model
            graph_info = self.parser.parse_model(model_path)
            
            # Genereer NTIR programma
            self.program = self._generate_program(graph_info)
            
            logger.info(f"NTIR gegenereerd uit: {model_path}")
            logger.info(f"Functies: {len(self.program.functions)}")
            logger.info(f"Globale variabelen: {len(self.program.globals)}")
            
            return self.program
            
        except Exception as e:
            logger.error(f"Fout bij genereren van NTIR: {e}")
            raise
    
    def generate_from_graph(self, graph_info: GraphInfo) -> NTIRProgram:
        """
        Genereer NTIR uit GraphInfo
        
        Args:
            graph_info: GraphInfo object
            
        Returns:
            NTIRProgram
        """
        try:
            self.program = self._generate_program(graph_info)
            
            logger.info("NTIR gegenereerd uit GraphInfo")
            return self.program
            
        except Exception as e:
            logger.error(f"Fout bij genereren van NTIR: {e}")
            raise
    
    def _generate_program(self, graph_info: GraphInfo) -> NTIRProgram:
        """
        Genereer NTIR programma uit GraphInfo
        
        Args:
            graph_info: GraphInfo object
            
        Returns:
            NTIRProgram
        """
        program = NTIRProgram()
        
        # Voeg globale variabelen toe (als ze bestaan)
        if hasattr(graph_info, 'initializer') and graph_info.initializer:
            for tensor in graph_info.initializer:
                global_prop = self._convert_tensor_to_property(tensor)
                program.add_global(tensor.name, global_prop)
        
        # Hoofd functie
        main_func = self._generate_main_function(graph_info)
        program.add_function(main_func)
        
        # Hulpfuncties (bijv. custom operaties)
        helper_funcs = self._generate_helper_functions(graph_info)
        for func in helper_funcs:
            program.add_function(func)
        
        return program
    
    def _generate_main_function(self, graph_info: GraphInfo) -> NTIRFunction:
        """
        Genereer hoofd functie
        
        Args:
            graph_info: GraphInfo object
            
        Returns:
            NTIRFunction
        """
        # Maak hoofd functie
        graph_name = getattr(graph_info, 'name', 'unknown')
        main_func = NTIRFunction(
            name="main",
            return_type="void",
            attributes={'graph_name': graph_name}
        )
        
        # Maak hoofdblok
        main_block = NTIRBlock("entry")
        main_func.add_block(main_block)
        
        # Sla huidige context op
        old_function = self.current_function
        old_block = self.current_block
        
        # Stel context in
        self.current_function = main_func
        self.current_block = main_block
        
        # Voeg parameters toe (inputs)
        if hasattr(graph_info, 'inputs') and graph_info.inputs:
            for tensor in graph_info.inputs:
                param_prop = self._convert_tensor_to_property(tensor)
                main_func.parameters.append(param_prop)
                main_block.add_variable(tensor.name, param_prop)
        
        # Genereer instructies voor elke node
        if hasattr(graph_info, 'nodes') and graph_info.nodes:
            for node in graph_info.nodes:
                self._generate_node_instructions(node)
        
        # Voeg return instructie toe
        if hasattr(graph_info, 'outputs') and graph_info.outputs:
            output_names = [output.name for output in graph_info.outputs]
            return_inst = NTIRInstruction(
                opcode=NTIROpcode.RETURN,
                operands=output_names
            )
            self.current_block.add_instruction(return_inst)
        
        # Herstel context
        self.current_function = old_function
        self.current_block = old_block
        
        return main_func
    
    def _generate_node_instructions(self, node: NodeInfo):
        """
        Genereer instructies voor een node
        
        Args:
            node: NodeInfo object
        """
        # Map ONNX operaties naar NTIR operaties
        opcode_map = {
            'Add': NTIROpcode.ADD,
            'Sub': NTIROpcode.SUB,
            'Mul': NTIROpcode.MUL,
            'Div': NTIROpcode.DIV,
            'MatMul': NTIROpcode.MATMUL,
            'Transpose': NTIROpcode.TRANSPOSE,
            'Reshape': NTIROpcode.RESHAPE,
            'Concat': NTIROpcode.CONCAT,
            'Slice': NTIROpcode.SLICE,
            'Gather': NTIROpcode.GATHER,
            'Scatter': NTIROpcode.SCATTER,
            'Relu': NTIROpcode.RELU,
            'Sigmoid': NTIROpcode.SIGMOID,
            'Tanh': NTIROpcode.TANH,
            'Softmax': NTIROpcode.SOFTMAX,
            'Dropout': NTIROpcode.DROPOUT,
            'Conv': NTIROpcode.CONV,
            'ConvTranspose': NTIROpcode.CONV_TRANSPOSE,
            'MaxPool': NTIROpcode.POOL,
            'AveragePool': NTIROpcode.POOL,
            'BatchNormalization': NTIROpcode.BATCH_NORM,
            'Gemm': NTIROpcode.LINEAR,
            'Flatten': NTIROpcode.FLATTEN,
        }
        
        # Vind opcode
        opcode = opcode_map.get(node.op_type, NTIROpcode.NOP)
        
        # Genereer operanden
        operands = node.inputs
        
        # Genereer result
        result = node.outputs[0] if node.outputs else self._generate_temp_name()
        
        # Maak instructie
        instruction = NTIRInstruction(
            opcode=opcode,
            operands=operands,
            result=result,
            attributes=node.attributes
        )
        
        # Voeg instructie toe
        self.current_block.add_instruction(instruction)
        
        # Voeg result toe als variabele (als het geen output van de hele grafiek is)
        if result not in [out.name for out in self.current_function.parameters]:
            # Maak een tijdelijke tensor property voor het resultaat
            result_prop = create_tensor_property(
                name=result,
                shape=[-1],  # Placeholder shape
                dtype="float32"
            )
            self.current_block.add_variable(result, result_prop)
    
    def _generate_helper_functions(self, graph_info: GraphInfo) -> List[NTIRFunction]:
        """
        Genereer helper functies
        
        Args:
            graph_info: GraphInfo object
            
        Returns:
            Lijst met NTIRFunction
        """
        helpers = []
        
        # Genereer helper functies voor complexere operaties
        for node in graph_info.nodes:
            if node.op_type in ['Conv', 'BatchNorm']:
                helper = self._generate_conv_helper(node)
                if helper:
                    helpers.append(helper)
        
        return helpers
    
    def _generate_conv_helper(self, node: NodeInfo) -> Optional[NTIRFunction]:
        """
        Genereer helper functie voor convolutie
        
        Args:
            node: NodeInfo object
            
        Returns:
            NTIRFunction of None
        """
        if node.op_type not in ['Conv', 'BatchNorm']:
            return None
        
        # Maak helper functie
        func_name = f"{node.op_type.lower()}_helper"
        func = NTIRFunction(
            name=func_name,
            return_type="void",
            attributes={'original_node': node.name}
        )
        
        # Maak blok
        block = NTIRBlock("compute")
        func.add_block(block)
        
        # Voeg parameters toe
        for input_name in node.inputs:
            param_prop = create_tensor_property(
                name=input_name,
                shape=[-1],
                dtype="float32"
            )
            func.parameters.append(param_prop)
            block.add_variable(input_name, param_prop)
        
        # Voeg return instructie toe
        if node.outputs:
            return_inst = NTIRInstruction(
                opcode=NTIROpcode.RETURN,
                operands=node.outputs
            )
            block.add_instruction(return_inst)
        
        return func
    
    def _convert_tensor_to_property(self, tensor: TensorInfo) -> TensorProperty:
        """
        Converteer TensorInfo naar TensorProperty
        
        Args:
            tensor: TensorInfo object
            
        Returns:
            TensorProperty
        """
        # Converteer shape
        shape_dims = tensor.shape
        shape = TensorShape(shape_dims)
        
        # Converteer dtype
        dtype_map = {
            1: NoodleTensorType.FLOAT32,
            2: NoodleTensorType.FLOAT16,
            3: NoodleTensorType.INT32,
            6: NoodleTensorType.INT64,
            9: NoodleTensorType.BOOL,
            # STRING type (7) wordt niet ondersteund, gebruik FLOAT32 als fallback
        }
        
        # Haal de waarde op van tensor.dtype
        dtype_value = tensor.dtype.value if hasattr(tensor.dtype, 'value') else 1
        
        # Vind dtype in map of gebruik FLOAT32 als fallback
        dtype = dtype_map.get(dtype_value, NoodleTensorType.FLOAT32)
        
        # Als het STRING type is, gebruik FLOAT32 als fallback
        if dtype_value == 7:  # STRING
            logger.warning(f"STRING tensor type '{tensor.name}' wordt geconverteerd naar FLOAT32")
            dtype = NoodleTensorType.FLOAT32
        
        # Map tensor properties
        is_constant = not tensor.is_input and not tensor.is_output
        
        return TensorProperty(
            name=tensor.name,
            shape=shape,
            dtype=dtype,
            requires_grad=tensor.is_input,  # Inputs kunnen gradients hebben
            is_parameter=False,  # Parameters zijn gewichten/bias
            is_constant=is_constant
        )
    
    def _generate_temp_name(self) -> str:
        """Genereer tijdelijke variabele naam"""
        self.temp_counter += 1
        return f"temp_{self.temp_counter}"
    
    def optimize_program(self, program: NTIRProgram) -> NTIRProgram:
        """
        Optimaliseer NTIR programma
        
        Args:
            program: NTIRProgram object
            
        Returns:
            Geoptimaliseerd NTIRProgram
        """
        optimized = NTIRProgram(metadata=program.metadata)
        
        # Kopieer globals
        for name, tensor in program.globals.items():
            optimized.add_global(name, tensor)
        
        # Optimaliseer elke functie
        for func in program.functions:
            optimized_func = self._optimize_function(func)
            optimized.add_function(optimized_func)
        
        return optimized
    
    def _optimize_function(self, func: NTIRFunction) -> NTIRFunction:
        """
        Optimaliseer NTIR functie
        
        Args:
            func: NTIRFunction object
            
        Returns:
            Geoptimaliseerde NTIRFunction
        """
        optimized = NTIRFunction(
            name=func.name,
            return_type=func.return_type,
            attributes=func.attributes
        )
        
        # Kopieer parameters
        for param in func.parameters:
            optimized.parameters.append(param)
        
        # Optimaliseer blokken
        for block in func.blocks:
            optimized_block = self._optimize_block(block)
            optimized.add_block(optimized_block)
        
        return optimized
    
    def _optimize_block(self, block: NTIRBlock) -> NTIRBlock:
        """
        Optimaliseer NTIR blok
        
        Args:
            block: NTIRBlock object
            
        Returns:
            Geoptimaliseerd NTIRBlock
        """
        optimized = NTIRBlock(
            name=block.name,
            attributes=block.attributes
        )
        
        # Eenvoudige optimalisaties
        instructions = []
        skip_next = False
        
        for i, inst in enumerate(block.instructions):
            if skip_next:
                skip_next = False
                continue
            
            # Verwijder NOP instructies
            if inst.opcode == NTIROpcode.NOP:
                continue
            
            # Optimaliseer constante expressies
            if inst.opcode in [NTIROpcode.ADD, NTIROpcode.MUL] and len(inst.operands) == 2:
                # Controleer of operanten constanten zijn
                if self._is_constant_operand(inst.operands[0]) and self._is_constant_operand(inst.operands[1]):
                    # Vervang door constante expressie
                    const_result = self._evaluate_constant_expression(inst)
                    if const_result is not None:
                        new_inst = NTIRInstruction(
                            opcode=NTIROpcode.LOAD,
                            operands=[const_result],
                            result=inst.result
                        )
                        instructions.append(new_inst)
                        continue
            
            # Voeg instructie toe
            instructions.append(inst)
        
        # Voeg geoptimaliseerde instructies toe
        for inst in instructions:
            optimized.add_instruction(inst)
        
        # Kopieer variabelen
        for name, var in block.variables.items():
            optimized.add_variable(name, var)
        
        return optimized
    
    def _is_constant_operand(self, operand: str) -> bool:
        """Controleer of operand een constante is"""
        return operand.startswith("const_")
    
    def _evaluate_constant_expression(self, inst: NTIRInstruction) -> Optional[str]:
        """Evalueer constante expressie"""
        # Implementatie voor simpele constant folding
        if inst.opcode == NTIROpcode.ADD:
            return f"const_add_{inst.operands[0]}_{inst.operands[1]}"
        elif inst.opcode == NTIROpcode.MUL:
            return f"const_mul_{inst.operands[0]}_{inst.operands[1]}"
        
        return None
    
    def validate_program(self, program: NTIRProgram) -> Tuple[bool, List[str]]:
        """
        Valideer NTIR programma
        
        Args:
            program: NTIRProgram object
            
        Returns:
            Tuple van (is_valid, error_messages)
        """
        errors = []
        
        # Controleer functies
        for func in program.functions:
            func_valid, func_errors = self._validate_function(func)
            if not func_valid:
                errors.extend(func_errors)
        
        # Controleer globals
        for name, tensor in program.globals.items():
            if not tensor.name:
                errors.append(f"Global variabele zonder naam: {name}")
        
        is_valid = len(errors) == 0
        return is_valid, errors
    
    def _validate_function(self, func: NTIRFunction) -> Tuple[bool, List[str]]:
        """Valideer NTIR functie"""
        errors = []
        
        # Controleer parameters
        for param in func.parameters:
            if not param.name:
                errors.append("Functie parameter zonder naam")
        
        # Controleer blokken
        for block in func.blocks:
            block_valid, block_errors = self._validate_block(block)
            if not block_valid:
                errors.extend(block_errors)
        
        return len(errors) == 0, errors
    
    def _validate_block(self, block: NTIRBlock) -> Tuple[bool, List[str]]:
        """Valideer NTIR blok"""
        errors = []
        
        # Controleer instructies
        for inst in block.instructions:
            if not inst.opcode:
                errors.append("Instructie zonder opcode")
            
            if not inst.operands:
                errors.append(f"Instructie zonder operanden: {inst.opcode}")
            
            # Controleer operanden
            for operand in inst.operands:
                if not self._is_valid_operand_name(operand):
                    errors.append(f"Ongeldige operand naam: {operand}")
        
        return len(errors) == 0, errors
    
    def _is_valid_operand_name(self, name: str) -> bool:
        """Controleer of operand naam geldig is"""
        return name and isinstance(name, str) and name.strip()


