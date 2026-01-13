"""
Converter::Tensor Types - tensor_types.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Tensor Type Systeem - Type definitie voor NoodleCore tensors
"""

import numpy as np
from typing import Dict, List, Optional, Any, Union, Tuple
from dataclasses import dataclass, field
from enum import Enum
import logging

logger = logging.getLogger(__name__)


class NoodleTensorType(Enum):
    """NoodleCore tensor types"""
    FLOAT32 = "float32"
    FLOAT16 = "float16"
    BFLOAT16 = "bfloat16"
    INT32 = "int32"
    INT64 = "int64"
    BOOL = "bool"
    COMPLEX64 = "complex64"
    COMPLEX128 = "complex128"


class MemoryLayout(Enum):
    """Geheugen layout voor tensors"""
    ROW_MAJOR = "row_major"
    COLUMN_MAJOR = "column_major"
    NHWC = "nhwc"  # Channels Last
    NCHW = "nchw"  # Channels First
    BLOCKED = "blocked"


@dataclass
class TensorShape:
    """Tensor shape met ondersteuning voor dynamische dimensies"""
    dims: List[Union[int, str]]
    layout: MemoryLayout = MemoryLayout.NCHW
    
    def __post_init__(self):
        # Valideer shape
        for dim in self.dims:
            if not isinstance(dim, (int, str)):
                raise ValueError(f"Ongeldige dimensie: {dim}")
    
    def is_dynamic(self) -> bool:
        """Controleer of shape dynamische dimensies bevat"""
        return any(isinstance(dim, str) for dim in self.dims)
    
    def get_static_dims(self) -> List[int]:
        """Krijg alleen statische dimensies"""
        return [dim for dim in self.dims if isinstance(dim, int)]
    
    def get_dynamic_dims(self) -> List[str]:
        """Krijg alleen dynamische dimensies"""
        return [dim for dim in self.dims if isinstance(dim, str)]
    
    def total_size(self) -> int:
        """Bereken totale grootte (alleen statische dimensies)"""
        static_dims = self.get_static_dims()
        return np.prod(static_dims) if static_dims else 0
    
    def __str__(self) -> str:
        return str(self.dims)


@dataclass
class DataTypeSpec:
    """Data type specificaties"""
    dtype: NoodleTensorType
    element_size: int
    alignment: int = 64
    is_floating_point: bool = False
    is_complex: bool = False
    is_integer: bool = False
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    
    @classmethod
    def from_dtype(cls, dtype: NoodleTensorType) -> 'DataTypeSpec':
        """Maak DataTypeSpec from dtype"""
        specs = {
            NoodleTensorType.FLOAT32: cls(
                dtype=dtype,
                element_size=4,
                is_floating_point=True,
                min_value=-3.402823466e+38,
                max_value=3.402823466e+38
            ),
            NoodleTensorType.FLOAT16: cls(
                dtype=dtype,
                element_size=2,
                is_floating_point=True,
                min_value=-65504.0,
                max_value=65504.0
            ),
            NoodleTensorType.BFLOAT16: cls(
                dtype=dtype,
                element_size=2,
                is_floating_point=True,
                min_value=-65504.0,
                max_value=65504.0
            ),
            NoodleTensorType.INT32: cls(
                dtype=dtype,
                element_size=4,
                is_integer=True,
                min_value=-2147483648,
                max_value=2147483647
            ),
            NoodleTensorType.INT64: cls(
                dtype=dtype,
                element_size=8,
                is_integer=True,
                min_value=-9223372036854775808,
                max_value=9223372036854775807
            ),
            NoodleTensorType.BOOL: cls(
                dtype=dtype,
                element_size=1,
                min_value=0,
                max_value=1
            ),
            NoodleTensorType.COMPLEX64: cls(
                dtype=dtype,
                element_size=8,
                is_complex=True,
                is_floating_point=True
            ),
            NoodleTensorType.COMPLEX128: cls(
                dtype=dtype,
                element_size=16,
                is_complex=True,
                is_floating_point=True
            ),
        }
        return specs.get(dtype, specs[NoodleTensorType.FLOAT32])
    
    @property
    def numpy_dtype(self) -> np.dtype:
        """Krijg numpy dtype"""
        dtype_map = {
            NoodleTensorType.FLOAT32: np.float32,
            NoodleTensorType.FLOAT16: np.float16,
            NoodleTensorType.BFLOAT16: np.float16,  # Geen directe BF16 in numpy
            NoodleTensorType.INT32: np.int32,
            NoodleTensorType.INT64: np.int64,
            NoodleTensorType.BOOL: np.bool_,
            NoodleTensorType.COMPLEX64: np.complex64,
            NoodleTensorType.COMPLEX128: np.complex128,
        }
        return dtype_map.get(self.dtype, np.float32)


@dataclass
class TensorMemoryLayout:
    """Tensor geheugen layout specificaties"""
    layout: MemoryLayout
    strides: List[int]
    offset: int = 0
    alignment: int = 64
    
    def is_contiguous(self) -> bool:
        """Controleer of tensor contiguus geheugen heeft"""
        expected_stride = 1
        for stride in reversed(self.strides):
            if stride != expected_stride:
                return False
            expected_stride *= self.strides[-1] if self.strides else 1
        return True
    
    def get_memory_size(self, shape: TensorShape) -> int:
        """Bereken geheugen grootte"""
        if not shape.get_static_dims():
            return 0
        
        # Basis grootte
        size = shape.total_size()
        
        # Alignment
        size = (size + self.alignment - 1) // self.alignment * self.alignment
        
        return size


@dataclass
class TensorProperty:
    """Tensor eigenschappen voor NoodleCore"""
    name: str
    shape: TensorShape
    dtype: NoodleTensorType
    layout: MemoryLayout = MemoryLayout.NCHW
    requires_grad: bool = False
    is_parameter: bool = False
    is_constant: bool = False
    memory_layout: Optional[TensorMemoryLayout] = None
    
    def __post_init__(self):
        if self.memory_layout is None:
            self.memory_layout = TensorMemoryLayout(
                layout=self.layout,
                strides=self._compute_strides()
            )
    
    def _compute_strides(self) -> List[int]:
        """Bereken strides voor de gegeven shape en layout"""
        static_dims = self.shape.get_static_dims()
        if not static_dims:
            return []
        
        if self.layout == MemoryLayout.NCHW:
            # NCHW: [batch, channels, height, width]
            strides = []
            stride = 1
            for dim in reversed(static_dims):
                strides.append(stride)
                stride *= dim
            return list(reversed(strides))
        
        elif self.layout == MemoryLayout.NHWC:
            # NHWC: [batch, height, width, channels]
            strides = []
            stride = 1
            for dim in reversed(static_dims):
                strides.append(stride)
                stride *= dim
            return list(reversed(strides))
        
        else:
            # Default row-major
            strides = []
            stride = 1
            for dim in reversed(static_dims):
                strides.append(stride)
                stride *= dim
            return list(reversed(strides))
    
    @property
    def dtype_spec(self) -> DataTypeSpec:
        """Krijg data type specificaties"""
        return DataTypeSpec.from_dtype(self.dtype)
    
    @property
    def element_size(self) -> int:
        """Krijg element grootte in bytes"""
        return self.dtype_spec.element_size
    
    @property
    def total_size(self) -> int:
        """Bereken totale geheugen grootte"""
        static_size = self.shape.total_size()
        return static_size * self.element_size
    
    def is_compatible(self, other: 'TensorProperty') -> bool:
        """Controleer compatibility met andere tensor"""
        return (
            self.dtype == other.dtype and
            self.layout == other.layout and
            self.shape.dims == other.shape.dims
        )
    
    def can_broadcast_to(self, target: 'TensorProperty') -> bool:
        """Controleer of deze tensor kan worden uitgebreid naar target shape"""
        source_dims = self.shape.dims
        target_dims = target.shape.dims
        
        # Pad met 1's aan de voorkant
        while len(source_dims) < len(target_dims):
            source_dims = [1] + source_dims
        
        # Controleer broadcast regels
        for s, t in zip(reversed(source_dims), reversed(target_dims)):
            if s != 1 and t != 1 and s != t:
                return False
        
        return True
    
    def reshape(self, new_shape: TensorShape) -> 'TensorProperty':
        """Reshape tensor naar nieuwe shape"""
        # Controleer of reshape geldig is
        old_static_dims = self.shape.get_static_dims()
        new_static_dims = new_shape.get_static_dims()
        
        if old_static_dims and new_static_dims:
            old_total = np.prod(old_static_dims)
            new_total = np.prod(new_static_dims)
            
            if old_total != new_total:
                raise ValueError(f"Reshape niet mogelijk: {old_static_dims} -> {new_static_dims}")
        
        return TensorProperty(
            name=self.name + "_reshaped",
            shape=new_shape,
            dtype=self.dtype,
            layout=new_shape.layout,
            requires_grad=self.requires_grad,
            is_parameter=self.is_parameter,
            is_constant=self.is_constant
        )
    
    def transpose(self, axes: Optional[List[int]] = None) -> 'TensorProperty':
        """Transpose tensor"""
        if axes is None:
            # Standaard transpose voor tensors > 2D
            axes = list(range(len(self.shape.dims)))[::-1]
        
        # Bereken nieuwe shape
        new_dims = [self.shape.dims[i] for i in axes]
        new_shape = TensorShape(new_dims, self.layout)
        
        # Update layout
        new_layout = MemoryLayout.ROW_MAJOR  # Transposed tensors zijn meestal row-major
        
        return TensorProperty(
            name=self.name + "_t",
            shape=new_shape,
            dtype=self.dtype,
            layout=new_layout,
            requires_grad=self.requires_grad,
            is_parameter=self.is_parameter,
            is_constant=self.is_constant
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'name': self.name,
            'shape': [str(dim) for dim in self.shape.dims],
            'dtype': self.dtype.value,
            'layout': self.layout.value,
            'requires_grad': self.requires_grad,
            'is_parameter': self.is_parameter,
            'is_constant': self.is_constant,
            'element_size': self.element_size,
            'total_size': self.total_size
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TensorProperty':
        """Maak TensorProperty van dictionary"""
        return cls(
            name=data['name'],
            shape=TensorShape(
                dims=[int(dim) if dim.isdigit() else dim for dim in data['shape']],
                layout=MemoryLayout(data['layout'])
            ),
            dtype=NoodleTensorType(data['dtype']),
            layout=MemoryLayout(data['layout']),
            requires_grad=data.get('requires_grad', False),
            is_parameter=data.get('is_parameter', False),
            is_constant=data.get('is_constant', False)
        )


class TypeRegistry:
    """Registry voor tensor types en properties"""
    
    def __init__(self):
        self.types: Dict[str, NoodleTensorType] = {}
        self.properties: Dict[str, TensorProperty] = {}
        self._register_builtin_types()
    
    def _register_builtin_types(self):
        """Registreer ingebouwde types"""
        for dtype in NoodleTensorType:
            self.types[dtype.value] = dtype
    
    def register_type(self, name: str, dtype: NoodleTensorType):
        """Registreer een nieuw type"""
        self.types[name] = dtype
        logger.info(f"Geregistreerd type: {name} -> {dtype.value}")
    
    def register_tensor(self, tensor: TensorProperty):
        """Registreer een tensor"""
        self.properties[tensor.name] = tensor
        logger.info(f"Geregistreerde tensor: {tensor.name}")
    
    def get_type(self, name: str) -> Optional[NoodleTensorType]:
        """Krijg type by naam"""
        return self.types.get(name)
    
    def get_tensor(self, name: str) -> Optional[TensorProperty]:
        """Krijg tensor by naam"""
        return self.properties.get(name)
    
    def list_types(self) -> List[str]:
        """Krijg lijst van geregistreerde types"""
        return list(self.types.keys())
    
    def list_tensors(self) -> List[str]:
        """Krijg lijst van geregistreerde tensors"""
        return list(self.properties.keys())
    
    def validate_type(self, name: str) -> bool:
        """Valideer type naam"""
        return name in self.types
    
    def validate_tensor(self, name: str) -> bool:
        """Valideer tensor naam"""
        return name in self.properties
    
    def remove_tensor(self, name: str) -> bool:
        """Verwijder tensor"""
        if name in self.properties:
            del self.properties[name]
            logger.info(f"Verwijderde tensor: {name}")
            return True
        return False
    
    def clear_tensors(self):
        """Wis alle tensors"""
        self.properties.clear()
        logger.info("Alle tensors gewist")
    
    def export_schema(self) -> Dict[str, Any]:
        """Exporteer type schema"""
        return {
            'types': {name: dtype.value for name, dtype in self.types.items()},
            'tensors': {name: prop.to_dict() for name, prop in self.properties.items()}
        }
    
    def import_schema(self, schema: Dict[str, Any]):
        """Importeer type schema"""
        # Importeer types
        for name, dtype_value in schema.get('types', {}).items():
            self.types[name] = NoodleTensorType(dtype_value)
        
        # Importeer tensors
        for name, tensor_data in schema.get('tensors', {}).items():
            self.properties[name] = TensorProperty.from_dict(tensor_data)
        
        logger.info(f"Schema geÃ¯mporteerd: {len(self.types)} types, {len(self.properties)} tensors")


# Globale type registry
type_registry = TypeRegistry()


def create_tensor_property(
    name: str,
    shape: Union[List[Union[int, str]], TensorShape],
    dtype: Union[str, NoodleTensorType],
    layout: Union[str, MemoryLayout] = MemoryLayout.NCHW,
    **kwargs
) -> TensorProperty:
    """Helper functie om TensorProperty aan te maken"""
    if isinstance(shape, list):
        shape = TensorShape(shape, layout if isinstance(layout, MemoryLayout) else MemoryLayout(layout))
    else:
        shape = shape
    
    if isinstance(dtype, str):
        dtype = NoodleTensorType(dtype)
    else:
        dtype = dtype
    
    if isinstance(layout, str):
        layout = MemoryLayout(layout)
    else:
        layout = layout
    
    return TensorProperty(
        name=name,
        shape=shape,
        dtype=dtype,
        layout=layout,
        **kwargs
    )


def get_dtype_info(dtype: Union[str, NoodleTensorType]) -> DataTypeSpec:
    """Krijg data type informatie"""
    if isinstance(dtype, str):
        dtype = NoodleTensorType(dtype)
    return DataTypeSpec.from_dtype(dtype)


