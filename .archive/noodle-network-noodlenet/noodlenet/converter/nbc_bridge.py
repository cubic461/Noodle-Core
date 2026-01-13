"""
Converter::Nbc Bridge - nbc_bridge.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NBC Bridge - Bridge tussen NTIR en NBC (Noodle Binary Code)
"""

import json
import logging
from typing import Dict, List, Optional, Any, Union, Tuple
from dataclasses import dataclass, field
from enum import Enum
import subprocess
import tempfile
import os
import datetime

from tensor_types import NoodleTensorType, TensorProperty
from ntir_generator import NTIRProgram, NTIRFunction, NTIRBlock, NTIRInstruction

logger = logging.getLogger(__name__)


class NBCCompilationTarget(Enum):
    """NBC compilatie targets"""
    CPU = "cpu"
    GPU = "gpu"
    NPU = "npu"
    HYBRID = "hybrid"


class NBCOptimizationLevel(Enum):
    """NBC optimalisatie niveaus"""
    NONE = "none"
    BASIC = "basic"
    AGGRESSIVE = "aggressive"
    DEBUG = "debug"


@dataclass
class CompilationContext:
    """Compilatie context"""
    target: NBCCompilationTarget = NBCCompilationTarget.CPU
    optimization_level: NBCOptimizationLevel = NBCOptimizationLevel.BASIC
    debug_symbols: bool = False
    enable_vectorization: bool = True
    enable_parallelization: bool = True
    enable_memory_optimization: bool = True
    output_format: str = "binary"
    include_paths: List[str] = field(default_factory=list)
    library_paths: List[str] = field(default_factory=list)
    compiler_flags: List[str] = field(default_factory=list)
    linker_flags: List[str] = field(default_factory=list)
    
    def get_default_flags(self) -> List[str]:
        """Krijg standaard compilatie vlaggen"""
        flags = []
        
        # Target specifieke vlaggen
        if self.target == NBCCompilationTarget.CPU:
            flags.extend(["-target-cpu", "native"])
        elif self.target == NBCCompilationTarget.GPU:
            flags.extend(["-target-gpu", "cuda"])
        elif self.target == NBCCompilationTarget.NPU:
            flags.extend(["-target-npu", "tpu"])
        
        # Optimalisatie vlaggen
        if self.optimization_level == NBCOptimizationLevel.BASIC:
            flags.append("-O2")
        elif self.optimization_level == NBCOptimizationLevel.AGGRESSIVE:
            flags.extend(["-O3", "-march=native"])
        elif self.optimization_level == NBCOptimizationLevel.DEBUG:
            flags.append("-g")
            self.debug_symbols = True
        
        # Feature vlaggen
        if self.enable_vectorization:
            flags.append("-vectorize")
        if self.enable_parallelization:
            flags.append("-parallelize")
        if self.enable_memory_optimization:
            flags.append("-optimize-mem")
        
        return flags


@dataclass
class CompilationResult:
    """Compilatie resultaat"""
    success: bool
    output_path: Optional[str] = None
    binary_path: Optional[str] = None
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    statistics: Dict[str, Any] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'success': self.success,
            'output_path': self.output_path,
            'binary_path': self.binary_path,
            'errors': self.errors,
            'warnings': self.warnings,
            'statistics': self.statistics,
            'metadata': self.metadata
        }


class NBCBridge:
    """Bridge tussen NTIR en NBC"""
    
    def __init__(self, context: Optional[CompilationContext] = None):
        self.context = context or CompilationContext()
        self.compilation_history = []
        self.compiler_path = "noodle-compiler"
        self.linker_path = "noodle-linker"
        
    def compile_ntir_to_nbc(self, ntir_program: NTIRProgram, 
                           output_path: Optional[str] = None) -> CompilationResult:
        """
        Compileer NTIR programma naar NBC
        
        Args:
            ntir_program: NTIRProgram object
            output_path: Pad voor outputbestand
            
        Returns:
            CompilationResult
        """
        try:
            # Maak tijdelijke bestanden
            with tempfile.TemporaryDirectory() as temp_dir:
                # Sla NTIR op als JSON
                ntir_path = os.path.join(temp_dir, "program.ntir")
                with open(ntir_path, 'w') as f:
                    f.write(ntir_program.to_json())
                
                # Genereer NBC bron code
                nbc_source = self._generate_nbc_source(ntir_program, temp_dir)
                nbc_source_path = os.path.join(temp_dir, "program.nbc")
                with open(nbc_source_path, 'w') as f:
                    f.write(nbc_source)
                
                # Compileer NBC naar binary
                binary_path = self._compile_nbc_source(nbc_source_path, temp_dir, output_path)
                
                # Genereer metadata
                metadata = self._generate_metadata(ntir_program, nbc_source_path, binary_path)
                
                # Maak resultaat
                result = CompilationResult(
                    success=True,
                    output_path=nbc_source_path,
                    binary_path=binary_path,
                    metadata=metadata
                )
                
                # Sla op in geschiedenis
                self.compilation_history.append({
                    'ntir_program': ntir_program,
                    'result': result
                })
                
                return result
                
        except Exception as e:
            error_msg = f"Compilatie mislukt: {str(e)}"
            logger.error(error_msg)
            return CompilationResult(
                success=False,
                errors=[error_msg]
            )
    
    def _generate_nbc_source(self, ntir_program: NTIRProgram, temp_dir: str) -> str:
        """Genereer NBC bron code uit NTIR"""
        nbc_source = []
        
        # Header
        nbc_source.append("// Generated NBC (Noodle Binary Code)")
        nbc_source.append(f"// Target: {self.context.target.value}")
        nbc_source.append(f"// Optimization: {self.context.optimization_level.value}")
        nbc_source.append("")
        
        # Includes
        nbc_source.append("#include <noodle_core.h>")
        nbc_source.append("#include <noodle_math.h>")
        nbc_source.append("#include <noodle_tensor.h>")
        nbc_source.append("")
        
        # Globale variabelen
        if ntir_program.globals:
            nbc_source.append("// Global Variables")
            for name, tensor in ntir_program.globals.items():
                nbc_source.append(f"Tensor {name} = create_tensor(")
                nbc_source.append(f"    shape={tensor.shape.dims}, "
                                 f"dtype={tensor.dtype.value}, "
                                 f"layout={tensor.layout.value});")
            nbc_source.append("")
        
        # Functies
        for func in ntir_program.functions:
            nbc_source.extend(self._generate_function_code(func))
        
        return "\n".join(nbc_source)
    
    def _generate_function_code(self, func: NTIRFunction) -> List[str]:
        """Genereer NBC functie code"""
        func_code = []
        
        # Functie header
        func_code.append(f"// Function: {func.name}")
        func_code.append(f"void {func.name}(")
        
        # Parameters
        param_decls = []
        for param in func.parameters:
            param_decl = f"Tensor {param.name}"
            if param.is_parameter:
                param_decl += " [parameter]"
            if param.is_constant:
                param_decl += " [constant]"
            param_decls.append(param_decl)
        
        func_code.append(",\n".join(param_decls))
        func_code.append(") {")
        
        # Lokale variabelen
        if func.blocks:
            # Haal alle lokale variabelen op uit de eerste blok
            for name, tensor in func.blocks[0].variables.items():
                if name not in [p.name for p in func.parameters]:
                    func_code.append(f"    Tensor {name} = create_tensor(")
                    func_code.append(f"        shape={tensor.shape.dims}, "
                                   f"dtype={tensor.dtype.value}, "
                                   f"layout={tensor.layout.value});")
        
        # Blokken
        for block in func.blocks:
            func_code.extend(self._generate_block_code(block))
        
        # Return statement
        if func.return_type != "void":
            func_code.append("    return result;")
        
        func_code.append("}")
        func_code.append("")
        
        return func_code
    
    def _generate_block_code(self, block: NTIRBlock) -> List[str]:
        """Genereer NBC blok code"""
        block_code = []
        
        # Blok header
        block_code.append(f"    // Block: {block.name}")
        
        # Instructies
        for instruction in block.instructions:
            block_code.extend(self._generate_instruction_code(instruction))
        
        return block_code
    
    def _generate_instruction_code(self, instruction: NTIRInstruction) -> List[str]:
        """Genereer NBC instructie code"""
        inst_code = []
        
        # Commentaar
        inst_code.append(f"    // {instruction.opcode.value}")
        
        # Genereer specifieke code per opcode
        if instruction.opcode.value == "add":
            inst_code.append(f"    {instruction.result} = add_tensors(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"{instruction.operands[1]});")
        elif instruction.opcode.value == "mul":
            inst_code.append(f"    {instruction.result} = mul_tensors(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"{instruction.operands[1]});")
        elif instruction.opcode.value == "matmul":
            inst_code.append(f"    {instruction.result} = matmul_tensors(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"{instruction.operands[1]});")
        elif instruction.opcode.value == "relu":
            inst_code.append(f"    {instruction.result} = relu_tensor(")
            inst_code.append(f"        {instruction.operands[0]});")
        elif instruction.opcode.value == "transpose":
            inst_code.append(f"    {instruction.result} = transpose_tensor(")
            inst_code.append(f"        {instruction.operands[0]});")
        elif instruction.opcode.value == "reshape":
            # Haal shape uit attributes
            new_shape = instruction.attributes.get('shape', [-1])
            inst_code.append(f"    {instruction.result} = reshape_tensor(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"shape={new_shape});")
        elif instruction.opcode.value == "conv":
            kernel_shape = instruction.attributes.get('kernel_shape', [3, 3])
            inst_code.append(f"    {instruction.result} = conv2d_tensor(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"{instruction.operands[1]}, "
                           f"kernel={kernel_shape}, "
                           f"stride=1, padding=0);")
        elif instruction.opcode.value == "pool":
            pool_type = instruction.attributes.get('pool_type', 'max')
            kernel_size = instruction.attributes.get('kernel_size', [2, 2])
            inst_code.append(f"    {instruction.result} = pool2d_tensor(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"pool_type='{pool_type}', "
                           f"kernel={kernel_size}, "
                           f"stride=1, padding=0);")
        elif instruction.opcode.value == "linear":
            inst_code.append(f"    {instruction.result} = linear_tensor(")
            inst_code.append(f"        {instruction.operands[0]}, "
                           f"{instruction.operands[1]}, "
                           f"{instruction.operands[2] if len(instruction.operands) > 2 else 'NULL'});")
        elif instruction.opcode.value == "flatten":
            inst_code.append(f"    {instruction.result} = flatten_tensor(")
            inst_code.append(f"        {instruction.operands[0]});")
        elif instruction.opcode.value == "softmax":
            inst_code.append(f"    {instruction.result} = softmax_tensor(")
            inst_code.append(f"        {instruction.operands[0]});")
        elif instruction.opcode.value == "return":
            inst_code.append(f"    return {', '.join(instruction.operands) if instruction.operands else 'NULL'};")
        else:
            # Default: genereer simpele toewijzing
            if instruction.result:
                inst_code.append(f"    {instruction.result} = {instruction.opcode.value}(")
                inst_code.append(f"        {', '.join(instruction.operands)});")
        
        return inst_code
    
    def _compile_nbc_source(self, source_path: str, temp_dir: str, 
                           output_path: Optional[str] = None) -> str:
        """Compileer NBC bron code naar binary"""
        
        # Bepaal output pad
        if output_path is None:
            binary_path = os.path.join(temp_dir, "program.nbcbin")
        else:
            binary_path = output_path
        
        # Compiler command
        compiler_flags = self.context.get_default_flags()
        compiler_flags.extend(self.context.compiler_flags)
        
        cmd = [
            self.compiler_path,
            source_path,
            "-o", binary_path,
            *compiler_flags
        ]
        
        # Include paths
        for include_path in self.context.include_paths:
            cmd.extend(["-I", include_path])
        
        # Voer compiler uit
        try:
            result = subprocess.run(
                cmd, 
                cwd=temp_dir,
                capture_output=True, 
                text=True, 
                check=True
            )
            
            # Linken als nodig
            if self.context.linker_path:
                linker_cmd = [
                    self.linker_path,
                    binary_path,
                    "-o", binary_path,
                    *self.context.linker_flags
                ]
                
                linker_result = subprocess.run(
                    linker_cmd,
                    cwd=temp_dir,
                    capture_output=True,
                    text=True,
                    check=True
                )
                
                if linker_result.stdout:
                    logger.info(f"Linker output: {linker_result.stdout}")
                if linker_result.stderr:
                    logger.warning(f"Linker warnings: {linker_result.stderr}")
            
            if result.stdout:
                logger.info(f"Compiler output: {result.stdout}")
            if result.stderr:
                logger.warning(f"Compiler warnings: {result.stderr}")
            
            return binary_path
            
        except subprocess.CalledProcessError as e:
            error_msg = f"Compiler fout: {e.stderr}"
            logger.error(error_msg)
            raise RuntimeError(error_msg)
    
    def _generate_metadata(self, ntir_program: NTIRProgram, 
                          source_path: str, binary_path: str) -> Dict[str, Any]:
        """Genereer metadata over compilatie"""
        
        # Bereken statistieken
        total_functions = len(ntir_program.functions)
        total_blocks = sum(len(func.blocks) for func in ntir_program.functions)
        total_instructions = sum(
            len(block.instructions) 
            for func in ntir_program.functions 
            for block in func.blocks
        )
        total_globals = len(ntir_program.globals)
        
        # Bestandsgroottes
        source_size = os.path.getsize(source_path)
        binary_size = os.path.getsize(binary_path)
        
        metadata = {
            'compilation_target': self.context.target.value,
            'optimization_level': self.context.optimization_level.value,
            'debug_symbols': self.context.debug_symbols,
            'features': {
                'vectorization': self.context.enable_vectorization,
                'parallelization': self.context.enable_parallelization,
                'memory_optimization': self.context.enable_memory_optimization
            },
            'statistics': {
                'total_functions': total_functions,
                'total_blocks': total_blocks,
                'total_instructions': total_instructions,
                'total_globals': total_globals,
                'source_size_bytes': source_size,
                'binary_size_bytes': binary_size,
                'compression_ratio': binary_size / source_size if source_size > 0 else 0
            },
            'compiler_info': {
                'compiler': self.compiler_path,
                'linker': self.linker_path,
                'flags': self.context.get_default_flags(),
                'include_paths': self.context.include_paths,
                'library_paths': self.context.library_paths
            },
            'timestamp': str(datetime.datetime.now())
        }
        
        return metadata
    
    def validate_binary(self, binary_path: str) -> Tuple[bool, List[str]]:
        """
        Valideer NBC binary
        
        Args:
            binary_path: Pad naar NBC binary
            
        Returns:
            Tuple van (is_valid, error_messages)
        """
        errors = []
        
        # Controleer bestand bestaat
        if not os.path.exists(binary_path):
            errors.append(f"Binary bestand niet gevonden: {binary_path}")
            return False, errors
        
        # Controleer bestandsgrootte
        if os.path.getsize(binary_path) == 0:
            errors.append("Binary bestand is leeg")
            return False, errors
        
        # Voer binary uit met --validate vlag
        try:
            cmd = [binary_path, "--validate"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                errors.append(f"Validatie mislukt: {result.stderr}")
                return False, errors
            
            # Parse validatie output
            validation_output = json.loads(result.stdout)
            if not validation_output.get('valid', False):
                errors.append("Binary validatie mislukt")
                return False, errors
            
        except Exception as e:
            errors.append(f"Validatie fout: {str(e)}")
            return False, errors
        
        return True, errors
    
    def get_compilation_info(self) -> Dict[str, Any]:
        """Krijg compilatie informatie"""
        return {
            'compiler_path': self.compiler_path,
            'linker_path': self.linker_path,
            'context': {
                'target': self.context.target.value,
                'optimization_level': self.context.optimization_level.value,
                'debug_symbols': self.context.debug_symbols,
                'include_paths': self.context.include_paths,
                'library_paths': self.context.library_paths
            },
            'compilation_history_count': len(self.compilation_history),
            'last_compilation': self.compilation_history[-1] if self.compilation_history else None
        }
    
    def update_context(self, **kwargs):
        """Update compilatie context"""
        for key, value in kwargs.items():
            if hasattr(self.context, key):
                setattr(self.context, key, value)
                logger.info(f"Updated context: {key} = {value}")
    
    def set_compiler_paths(self, compiler_path: str, linker_path: str):
        """Stel compiler en linker paden in"""
        self.compiler_path = compiler_path
        self.linker_path = linker_path
        logger.info(f"Updated compiler path: {compiler_path}")
        logger.info(f"Updated linker path: {linker_path}")


