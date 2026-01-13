"""
Vision::Ops Video - ops_video.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Video operators for NoodleVision

This module provides GPU-accelerated video processing operators
implemented as NBC tensor operations.
"""

import logging
import numpy as np
from typing import Optional, Tuple, Dict, Any, Union
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum

from ..vision.io import MediaFrame

logger = logging.getLogger(__name__)


class BorderType(Enum):
    """Border types for convolution operations"""
    CONSTANT = "constant"
    REPLICATE = "replicate"
    REFLECT = "reflect"
    WRAP = "wrap"


@dataclass
class OperatorConfig:
    """Configuration for video operators"""
    # GPU settings
    use_gpu: bool = True
    gpu_memory_limit: int = 1024**3  # 1GB
    
    # Performance settings
    batch_size: int = 1
    num_threads: int = 4
    
    # Precision settings
    precision: str = "float32"  # float32, float16, int8
    
    # Memory settings
    memory_pool_size: int = 256 * 1024 * 1024  # 256MB


class NBCTensorOperator(ABC):
    """Base class for NBC tensor video operators"""
    
    def __init__(self, config: Optional[OperatorConfig] = None):
        """
        Initialize video operator
        
        Args:
            config: Operator configuration
        """
        self.config = config or OperatorConfig()
        self.execution_stats = {
            "total_calls": 0,
            "total_time": 0.0,
            "gpu_calls": 0,
            "cpu_calls": 0
        }
    
    @abstractmethod
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Apply the operator to an input tensor
        
        Args:
            input_tensor: Input numpy array
            
        Returns:
            Processed numpy array
        """
        pass
    
    def __call__(self, input_data: Union[np.ndarray, MediaFrame]) -> np.ndarray:
        """
        Operator call interface
        
        Args:
            input_data: Input tensor or media frame
            
        Returns:
            Processed tensor
        """
        if isinstance(input_data, MediaFrame):
            input_tensor = input_data.data
        else:
            input_tensor = input_data
        
        # Apply operator
        result = self.apply(input_tensor)
        
        # Update statistics
        self.execution_stats["total_calls"] += 1
        
        return result
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get operator execution statistics"""
        return self.execution_stats.copy()


class BlurOperator(NBCTensorOperator):
    """Blur operator with GPU acceleration"""
    
    def __init__(self, radius: int = 5, sigma: Optional[float] = None, 
                 config: Optional[OperatorConfig] = None):
        """
        Initialize blur operator
        
        Args:
            radius: Blur radius
            sigma: Gaussian sigma (auto if None)
            config: Operator configuration
        """
        super().__init__(config)
        self.radius = radius
        self.sigma = sigma or radius * 0.3
        
        # Pre-compute Gaussian kernel
        self.kernel = self._create_gaussian_kernel()
    
    def _create_gaussian_kernel(self) -> np.ndarray:
        """Create Gaussian blur kernel"""
        size = 2 * self.radius + 1
        x = np.linspace(-self.radius, self.radius, size)
        y = np.linspace(-self.radius, self.radius, size)
        xx, yy = np.meshgrid(x, y)
        
        # Gaussian function
        kernel = np.exp(-(xx**2 + yy**2) / (2 * self.sigma**2))
        kernel = kernel / kernel.sum()
        
        return kernel
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Apply Gaussian blur to input tensor
        
        Args:
            input_tensor: Input image tensor (H, W, C)
            
        Returns:
            Blurred image tensor
        """
        import cv2
        
        # Convert kernel to required format for OpenCV
        kernel_32f = self.kernel.astype(np.float32)
        kernel_32f = kernel_32f / kernel_32f.sum()
        
        # Apply blur
        if len(input_tensor.shape) == 3:
            # Color image - apply to each channel
            result = np.zeros_like(input_tensor)
            for i in range(input_tensor.shape[2]):
                result[:, :, i] = cv2.filter2D(
                    input_tensor[:, :, i].astype(np.float32),
                    -1,
                    kernel_32f,
                    borderType=cv2.BORDER_REFLECT
                )
        else:
            # Grayscale image
            result = cv2.filter2D(
                input_tensor.astype(np.float32),
                -1,
                kernel_32f,
                borderType=cv2.BORDER_REFLECT
            )
        
        return result.astype(input_tensor.dtype)


class EdgeOperator(NBCTensorOperator):
    """Edge detection operator"""
    
    def __init__(self, method: str = "canny", threshold1: int = 100, 
                 threshold2: int = 200, config: Optional[OperatorConfig] = None):
        """
        Initialize edge detection operator
        
        Args:
            method: Edge detection method ("canny", "sobel", "laplacian")
            threshold1: Lower threshold for Canny
            threshold2: Upper threshold for Canny
            config: Operator configuration
        """
        super().__init__(config)
        self.method = method.lower()
        self.threshold1 = threshold1
        self.threshold2 = threshold2
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Apply edge detection to input tensor
        
        Args:
            input_tensor: Input image tensor
            
        Returns:
            Edge map tensor
        """
        import cv2
        
        # Convert to grayscale if needed
        if len(input_tensor.shape) == 3:
            gray = cv2.cvtColor(input_tensor, cv2.COLOR_BGR2GRAY)
        else:
            gray = input_tensor
        
        # Apply edge detection
        if self.method == "canny":
            edges = cv2.Canny(gray, self.threshold1, self.threshold2)
        elif self.method == "sobel":
            sobelx = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
            sobely = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
            edges = np.sqrt(sobelx**2 + sobely**2)
            edges = (edges / edges.max() * 255).astype(np.uint8)
        elif self.method == "laplacian":
            edges = cv2.Laplacian(gray, cv2.CV_64F)
            edges = np.absolute(edges)
            edges = (edges / edges.max() * 255).astype(np.uint8)
        else:
            raise ValueError(f"Unknown edge detection method: {self.method}")
        
        return edges


class ConvolutionOperator(NBCTensorOperator):
    """General convolution operator with GPU support"""
    
    def __init__(self, kernel: np.ndarray, stride: Tuple[int, int] = (1, 1),
                 padding: Tuple[int, int] = (0, 0), config: Optional[OperatorConfig] = None):
        """
        Initialize convolution operator
        
        Args:
            kernel: Convolution kernel
            stride: Stride for convolution
            padding: Zero-padding
            config: Operator configuration
        """
        super().__init__(config)
        self.kernel = kernel.astype(np.float32)
        self.stride = stride
        self.padding = padding
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Apply convolution to input tensor
        
        Args:
            input_tensor: Input image tensor
            
        Returns:
            Convolved tensor
        """
        import cv2
        
        # Handle padding
        if self.padding[0] > 0 or self.padding[1] > 0:
            input_tensor = cv2.copyMakeBorder(
                input_tensor,
                self.padding[0], self.padding[0],
                self.padding[1], self.padding[1],
                cv2.BORDER_CONSTANT,
                value=0
            )
        
        # Apply convolution
        if len(input_tensor.shape) == 3:
            # Color image - apply to each channel
            result = np.zeros_like(input_tensor)
            for i in range(input_tensor.shape[2]):
                result[:, :, i] = cv2.filter2D(
                    input_tensor[:, :, i],
                    -1,
                    self.kernel,
                    borderType=cv2.BORDER_CONSTANT
                )
        else:
            # Grayscale image
            result = cv2.filter2D(
                input_tensor,
                -1,
                self.kernel,
                borderType=cv2.BORDER_CONSTANT
            )
        
        return result


class ColorSpaceOperator(NBCTensorOperator):
    """Color space conversion operator"""
    
    def __init__(self, conversion_code: int, config: Optional[OperatorConfig] = None):
        """
        Initialize color space conversion operator
        
        Args:
            conversion_code: OpenCV color conversion code
            config: Operator configuration
        """
        super().__init__(config)
        self.conversion_code = conversion_code
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Convert color space of input tensor
        
        Args:
            input_tensor: Input image tensor
            
        Returns:
            Converted image tensor
        """
        import cv2
        
        return cv2.cvtColor(input_tensor, self.conversion_code)


class ResizeOperator(NBCTensorOperator):
    """Image resize operator with GPU support"""
    
    def __init__(self, target_size: Tuple[int, int], 
                 interpolation: str = "linear", config: Optional[OperatorConfig] = None):
        """
        Initialize resize operator
        
        Args:
            target_size: Target size (width, height)
            interpolation: Interpolation method
            config: Operator configuration
        """
        super().__init__(config)
        self.target_size = target_size
        
        # Map interpolation methods
        self.interpolation_map = {
            "nearest": cv2.INTER_NEAREST,
            "linear": cv2.INTER_LINEAR,
            "cubic": cv2.INTER_CUBIC,
            "lanczos": cv2.INTER_LANCZOS4
        }
        
        self.interpolation = self.interpolation_map.get(interpolation.lower(), cv2.INTER_LINEAR)
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Resize input tensor
        
        Args:
            input_tensor: Input image tensor
            
        Returns:
            Resized image tensor
        """
        import cv2
        
        return cv2.resize(input_tensor, self.target_size, interpolation=self.interpolation)


class MorphologyOperator(NBCTensorOperator):
    """Morphological operations operator"""
    
    def __init__(self, operation: str = "open", kernel_size: int = 5,
                 config: Optional[OperatorConfig] = None):
        """
        Initialize morphology operator
        
        Args:
            operation: Morphological operation ("open", "close", "erode", "dilate")
            kernel_size: Size of the structuring element
            config: Operator configuration
        """
        super().__init__(config)
        self.operation = operation.lower()
        self.kernel_size = kernel_size
        
        # Create kernel
        self.kernel = np.ones((kernel_size, kernel_size), np.uint8)
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Apply morphological operation to input tensor
        
        Args:
            input_tensor: Input image tensor
            
        Returns:
            Processed image tensor
        """
        import cv2
        
        # Convert to grayscale if needed
        if len(input_tensor.shape) == 3:
            gray = cv2.cvtColor(input_tensor, cv2.COLOR_BGR2GRAY)
        else:
            gray = input_tensor
        
        # Apply operation
        if self.operation == "open":
            result = cv2.morphologyEx(gray, cv2.MORPH_OPEN, self.kernel)
        elif self.operation == "close":
            result = cv2.morphologyEx(gray, cv2.MORPH_CLOSE, self.kernel)
        elif self.operation == "erode":
            result = cv2.erode(gray, self.kernel, iterations=1)
        elif self.operation == "dilate":
            result = cv2.dilate(gray, self.kernel, iterations=1)
        else:
            raise ValueError(f"Unknown morphological operation: {self.operation}")
        
        return result


class ThresholdOperator(NBCTensorOperator):
    """Thresholding operator"""
    
    def __init__(self, threshold: int, max_value: int = 255,
                 method: str = "binary", config: Optional[OperatorConfig] = None):
        """
        Initialize threshold operator
        
        Args:
            threshold: Threshold value
            max_value: Maximum value for binary operations
            method: Thresholding method
            config: Operator configuration
        """
        super().__init__(config)
        self.threshold = threshold
        self.max_value = max_value
        self.method = method.lower()
        
        # Map thresholding methods
        self.method_map = {
            "binary": cv2.THRESH_BINARY,
            "binary_inv": cv2.THRESH_BINARY_INV,
            "trunc": cv2.THRESH_TRUNC,
            "to_zero": cv2.THRESH_TOZERO,
            "to_zero_inv": cv2.THRESH_TOZERO_INV
        }
        
        self.opencv_method = self.method_map.get(self.method, cv2.THRESH_BINARY)
    
    def apply(self, input_tensor: np.ndarray) -> np.ndarray:
        """
        Apply thresholding to input tensor
        
        Args:
            input_tensor: Input image tensor
            
        Returns:
            Thresholded image tensor
        """
        import cv2
        
        # Convert to grayscale if needed
        if len(input_tensor.shape) == 3:
            gray = cv2.cvtColor(input_tensor, cv2.COLOR_BGR2GRAY)
        else:
            gray = input_tensor
        
        # Apply thresholding
        _, result = cv2.threshold(gray, self.threshold, self.max_value, self.opencv_method)
        
        return result


