"""
Vision::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleVision - Multimedia tensor support for NoodleCore

This module provides native support for video, audio, and sensor data processing
through NBC tensor operators with GPU acceleration and streaming capabilities.
"""

from .io import MediaStream, CameraStream, MediaFrame, StreamType
from .ops_video import (
    BlurOperator, EdgeOperator, ConvolutionOperator, ColorSpaceOperator, 
    ResizeOperator, MorphologyOperator, ThresholdOperator, NBCTensorOperator, 
    BorderType, OperatorConfig
)
from .ops_audio import (
    SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator,
    SpectralContrastOperator, ZeroCrossingRateOperator, EnergyOperator,
    AudioOperator, AudioConfig, WindowType, MelScale
)
from .ops_sensors import (
    SensorOperator, IMUSensorOperator, GPSSensorOperator, LIDARSensorOperator,
    CameraSensorOperator, SensorFusionOperator, SensorAnomalyDetector,
    SensorReading, SensorConfig, SensorType, SensorDataFormat
)
from .stream import (
    MediaStreamPipeline, StreamStage, BatchProcessor, AdaptiveBuffer,
    StreamOptimizer, SchedulingPolicy, OptimizationStrategy
)
from .memory import (
    MemoryManager, MemoryPool, GPUMemoryPool, CPUMemoryPool,
    MemoryBlock, MemoryStats, MemoryPolicy, SystemMemoryMonitor, TensorCache
)

__version__ = "0.1.0"
__all__ = [
    # Media I/O
    "MediaStream",
    "CameraStream", 
    "MediaFrame",
    "StreamType",
    
    # Video operators
    "BlurOperator",
    "EdgeOperator", 
    "ConvolutionOperator",
    "ColorSpaceOperator",
    "ResizeOperator",
    "MorphologyOperator",
    "ThresholdOperator",
    "NBCTensorOperator",
    "BorderType",
    "OperatorConfig",
    
    # Audio operators
    "SpectrogramOperator",
    "MFCCOperator",
    "ChromaOperator",
    "TonnetzOperator",
    "SpectralContrastOperator",
    "ZeroCrossingRateOperator",
    "EnergyOperator",
    "AudioOperator",
    "AudioConfig",
    "WindowType",
    "MelScale",
    
    # Sensor operators
    "SensorOperator",
    "IMUSensorOperator",
    "GPSSensorOperator",
    "LIDARSensorOperator",
    "CameraSensorOperator",
    "SensorFusionOperator",
    "SensorAnomalyDetector",
    "SensorReading",
    "SensorConfig",
    "SensorType",
    "SensorDataFormat",
    
    # Streaming
    "MediaStreamPipeline",
    "StreamStage",
    "BatchProcessor",
    "AdaptiveBuffer",
    "StreamOptimizer",
    "SchedulingPolicy",
    "OptimizationStrategy",
    
    # Memory management
    "MemoryManager",
    "MemoryPool",
    "GPUMemoryPool",
    "CPUMemoryPool",
    "MemoryBlock",
    "MemoryStats",
    "MemoryPolicy",
    "SystemMemoryMonitor",
    "TensorCache"
]


