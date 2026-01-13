"""
Noodlenet::Hardware - hardware.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Heterogeneous hardware integration for NoodleNet.

This module provides support for heterogeneous hardware including CPU, GPU, and NPU
with hardware-specific optimizations and resource management.
"""

import asyncio
import time
import logging
import platform
import subprocess
import json
from typing import Dict, List, Optional, Set, Tuple, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from abc import ABC, abstractmethod
from .config import NoodleNetConfig

logger = logging.getLogger(__name__)


class HardwareType(Enum):
    """Hardware types supported by NoodleNet"""
    CPU = "cpu"
    GPU = "gpu"
    NPU = "npu"
    TPU = "tpu"
    FPGA = "fpga"
    ASIC = "asic"


class ComputeCapability(Enum):
    """Compute capability levels"""
    BASIC = "basic"  # Basic compute capabilities
    STANDARD = "standard"  # Standard compute capabilities
    ADVANCED = "advanced"  # Advanced compute capabilities
    ENTERPRISE = "enterprise"  # Enterprise-grade compute capabilities


@dataclass
class HardwareInfo:
    """Hardware information and capabilities"""
    
    hardware_id: str
    hardware_type: HardwareType
    name: str
    vendor: str
    model: str
    
    # Compute capabilities
    compute_capability: ComputeCapability
    max_clock_speed_mhz: float
    memory_size_mb: int
    memory_bandwidth_gbps: float
    
    # Performance metrics
    theoretical_flops: float  # Theoretical FLOPS
    actual_flops: float = 0.0  # Measured FLOPS
    power_consumption_watts: float = 0.0
    temperature_celsius: float = 0.0
    
    # Utilization metrics
    utilization: float = 0.0  # 0.0-1.0
    memory_utilization: float = 0.0  # 0.0-1.0
    power_utilization: float = 0.0  # 0.0-1.0
    
    # Capabilities
    supported_operations: Set[str] = field(default_factory=set)
    supported_formats: Set[str] = field(default_factory=set)
    
    # Optimization hints
    optimal_batch_sizes: List[int] = field(default_factory=list)
    optimal_thread_counts: List[int] = field(default_factory=list)
    
    # Metadata
    driver_version: str = ""
    firmware_version: str = ""
    last_updated: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'hardware_id': self.hardware_id,
            'hardware_type': self.hardware_type.value,
            'name': self.name,
            'vendor': self.vendor,
            'model': self.model,
            'compute_capability': self.compute_capability.value,
            'max_clock_speed_mhz': self.max_clock_speed_mhz,
            'memory_size_mb': self.memory_size_mb,
            'memory_bandwidth_gbps': self.memory_bandwidth_gbps,
            'theoretical_flops': self.theoretical_flops,
            'actual_flops': self.actual_flops,
            'power_consumption_watts': self.power_consumption_watts,
            'temperature_celsius': self.temperature_celsius,
            'utilization': self.utilization,
            'memory_utilization': self.memory_utilization,
            'power_utilization': self.power_utilization,
            'supported_operations': list(self.supported_operations),
            'supported_formats': list(self.supported_formats),
            'optimal_batch_sizes': self.optimal_batch_sizes,
            'optimal_thread_counts': self.optimal_thread_counts,
            'driver_version': self.driver_version,
            'firmware_version': self.firmware_version,
            'last_updated': self.last_updated
        }


class HardwareManager(ABC):
    """Abstract base class for hardware managers"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize hardware manager
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        self._hardware_info: Dict[str, HardwareInfo] = {}
        self._monitoring_task: Optional[asyncio.Task] = None
        self._running = False
    
    @abstractmethod
    async def initialize(self) -> bool:
        """Initialize hardware manager and discover hardware"""
        pass
    
    @abstractmethod
    async def shutdown(self):
        """Shutdown hardware manager"""
        pass
    
    @abstractmethod
    async def get_hardware_info(self, hardware_id: Optional[str] = None) -> Union[HardwareInfo, List[HardwareInfo]]:
        """Get hardware information"""
        pass
    
    @abstractmethod
    async def update_metrics(self):
        """Update hardware metrics"""
        pass
    
    @abstractmethod
    async def execute_task(self, hardware_id: str, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a task on specific hardware"""
        pass
    
    async def start_monitoring(self):
        """Start hardware monitoring"""
        if self._running:
            return
        
        self._running = True
        self._monitoring_task = asyncio.create_task(self._monitoring_loop())
    
    async def stop_monitoring(self):
        """Stop hardware monitoring"""
        if not self._running:
            return
        
        self._running = False
        if self._monitoring_task and not self._monitoring_task.done():
            self._monitoring_task.cancel()
            try:
                await self._monitoring_task
            except asyncio.CancelledError:
                pass
    
    async def _monitoring_loop(self):
        """Main monitoring loop"""
        while self._running:
            try:
                await self.update_metrics()
                await asyncio.sleep(self.config.hardware_monitoring_interval)
            except Exception as e:
                logger.error(f"Error in hardware monitoring loop: {e}")
                await asyncio.sleep(5)


class CPUManager(HardwareManager):
    """CPU hardware manager"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """Initialize CPU manager"""
        super().__init__(config)
        self._cpu_count = 0
        self._cpu_freq = 0.0
        self._cpu_info = {}
    
    async def initialize(self) -> bool:
        """Initialize CPU manager"""
        try:
            # Get CPU information
            self._cpu_count = multiprocessing.cpu_count()
            
            # Get CPU frequency
            if hasattr(psutil, 'cpu_freq'):
                freq = psutil.cpu_freq()
                if freq:
                    self._cpu_freq = freq.current or 0.0
            
            # Get CPU model information
            if platform.system() == "Linux":
                try:
                    with open('/proc/cpuinfo', 'r') as f:
                        cpuinfo = f.read()
                        for line in cpuinfo.split('\n'):
                            if 'model name' in line:
                                self._cpu_info['model'] = line.split(':')[1].strip()
                                break
                except Exception:
                    pass
            elif platform.system() == "Windows":
                try:
                    import wmi
                    c = wmi.WMI()
                    for processor in c.Win32_Processor():
                        self._cpu_info['model'] = processor.Name
                        break
                except Exception:
                    pass
            elif platform.system() == "Darwin":
                try:
                    result = subprocess.run(['sysctl', '-n', 'machdep.cpu.brand_string'], 
                                          capture_output=True, text=True)
                    if result.returncode == 0:
                        self._cpu_info['model'] = result.stdout.strip()
                except Exception:
                    pass
            
            # Create hardware info for each CPU core
            for i in range(self._cpu_count):
                hardware_id = f"cpu_core_{i}"
                
                # Estimate FLOPS based on CPU info
                theoretical_flops = self._estimate_cpu_flops()
                
                hardware_info = HardwareInfo(
                    hardware_id=hardware_id,
                    hardware_type=HardwareType.CPU,
                    name=f"CPU Core {i}",
                    vendor=self._cpu_info.get('vendor', 'Unknown'),
                    model=self._cpu_info.get('model', 'Unknown'),
                    compute_capability=self._determine_compute_capability(),
                    max_clock_speed_mhz=self._cpu_freq,
                    memory_size_mb=self._get_memory_size(),
                    memory_bandwidth_gbps=self._estimate_memory_bandwidth(),
                    theoretical_flops=theoretical_flops,
                    supported_operations=self._get_supported_operations(),
                    supported_formats=self._get_supported_formats(),
                    optimal_thread_counts=[1, 2, 4, 8, 16, 32]
                )
                
                self._hardware_info[hardware_id] = hardware_info
            
            logger.info(f"CPU manager initialized with {self._cpu_count} cores")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize CPU manager: {e}")
            return False
    
    async def shutdown(self):
        """Shutdown CPU manager"""
        await self.stop_monitoring()
        logger.info("CPU manager shutdown")
    
    async def get_hardware_info(self, hardware_id: Optional[str] = None) -> Union[HardwareInfo, List[HardwareInfo]]:
        """Get CPU hardware information"""
        if hardware_id:
            return self._hardware_info.get(hardware_id)
        else:
            return list(self._hardware_info.values())
    
    async def update_metrics(self):
        """Update CPU metrics"""
        try:
            # Get CPU utilization
            cpu_percent = psutil.cpu_percent(interval=1, percpu=True)
            
            # Get memory utilization
            memory = psutil.virtual_memory()
            memory_percent = memory.percent / 100.0
            
            # Update each core's metrics
            for i, hardware_id in enumerate(self._hardware_info.keys()):
                if i < len(cpu_percent):
                    utilization = cpu_percent[i] / 100.0
                else:
                    utilization = cpu_percent[0] / 100.0  # Fallback to average
                
                hardware_info = self._hardware_info[hardware_id]
                hardware_info.utilization = utilization
                hardware_info.memory_utilization = memory_percent
                hardware_info.last_updated = time.time()
                
                # Update actual FLOPS based on utilization
                hardware_info.actual_flops = hardware_info.theoretical_flops * utilization
                
                # Get temperature if available
                if hasattr(psutil, 'sensors_temperatures'):
                    temps = psutil.sensors_temperatures()
                    if temps and 'coretemp' in temps:
                        for temp in temps['coretemp']:
                            if f'Core {i}' in temp.label or i == 0:
                                hardware_info.temperature_celsius = temp.current
                                break
                
                # Update power consumption (estimate)
                hardware_info.power_consumption_watts = self._estimate_power_consumption(utilization)
                hardware_info.power_utilization = utilization
            
        except Exception as e:
            logger.error(f"Failed to update CPU metrics: {e}")
    
    async def execute_task(self, hardware_id: str, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a task on CPU"""
        if hardware_id not in self._hardware_info:
            raise ValueError(f"Unknown CPU hardware ID: {hardware_id}")
        
        # For CPU execution, we'll simulate task execution
        # In a real implementation, this would use thread pools or process pools
        
        task_type = task.get('task_type', 'unknown')
        payload = task.get('payload', {})
        
        # Simulate execution time based on task complexity
        execution_time = payload.get('estimated_time', 1.0)
        await asyncio.sleep(execution_time)
        
        # Simulate result
        result = {
            'hardware_id': hardware_id,
            'task_type': task_type,
            'execution_time': execution_time,
            'result': f"Task {task_type} completed on CPU",
            'success': True
        }
        
        return result
    
    def _estimate_cpu_flops(self) -> float:
        """Estimate CPU FLOPS based on available information"""
        # Simple estimation based on clock speed and core count
        if self._cpu_freq > 0:
            # Assume 2 FLOPs per clock cycle (simplified)
            return self._cpu_freq * 1e6 * 2  # Convert MHz to Hz
        else:
            # Default estimation
            return 2.0e9  # 2 GFLOPS
    
    def _determine_compute_capability(self) -> ComputeCapability:
        """Determine CPU compute capability"""
        if 'AVX512' in self._cpu_info.get('flags', ''):
            return ComputeCapability.ENTERPRISE
        elif 'AVX2' in self._cpu_info.get('flags', ''):
            return ComputeCapability.ADVANCED
        elif 'AVX' in self._cpu_info.get('flags', ''):
            return ComputeCapability.STANDARD
        else:
            return ComputeCapability.BASIC
    
    def _get_memory_size(self) -> int:
        """Get system memory size in MB"""
        try:
            memory = psutil.virtual_memory()
            return int(memory.total / (1024 * 1024))  # Convert bytes to MB
        except Exception:
            return 8192  # Default 8GB
    
    def _estimate_memory_bandwidth(self) -> float:
        """Estimate memory bandwidth in GB/s"""
        # Simplified estimation based on memory type and speed
        # In a real implementation, this would use actual memory specifications
        return 25.0  # Default 25 GB/s
    
    def _get_supported_operations(self) -> Set[str]:
        """Get supported CPU operations"""
        return {
            'matrix_multiply', 'convolution', 'pooling', 'activation',
            'normalization', 'reshape', 'transpose', 'concatenate',
            'add', 'subtract', 'multiply', 'divide', 'exp', 'log',
            'sin', 'cos', 'tan', 'sqrt', 'abs', 'max', 'min'
        }
    
    def _get_supported_formats(self) -> Set[str]:
        """Get supported data formats"""
        return {
            'float32', 'float64', 'int8', 'int16', 'int32', 'int64',
            'uint8', 'uint16', 'uint32', 'uint64', 'bool'
        }
    
    def _estimate_power_consumption(self, utilization: float) -> float:
        """Estimate power consumption in watts"""
        # Simple linear model: 15W base + 85W at full load
        return 15.0 + (85.0 * utilization)


class GPUManager(HardwareManager):
    """GPU hardware manager"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """Initialize GPU manager"""
        super().__init__(config)
        self._cuda_available = False
        self._rocm_available = False
        self._opencl_available = False
        self._gpu_count = 0
    
    async def initialize(self) -> bool:
        """Initialize GPU manager"""
        try:
            # Check for CUDA availability
            try:
                import pynvml
                pynvml.nvmlInit()
                self._cuda_available = True
                self._gpu_count = pynvml.nvmlDeviceGetCount()
                await self._initialize_cuda_gpus()
            except (ImportError, Exception):
                logger.debug("CUDA not available")
            
            # Check for ROCm availability
            if not self._cuda_available:
                try:
                    # Check for ROCm devices
                    result = subprocess.run(['rocm-smi', '--showproductname'], 
                                          capture_output=True, text=True)
                    if result.returncode == 0:
                        self._rocm_available = True
                        await self._initialize_rocm_gpus()
                except (subprocess.SubprocessError, FileNotFoundError):
                    logger.debug("ROCm not available")
            
            # Check for OpenCL availability
            if not self._cuda_available and not self._rocm_available:
                try:
                    import pyopencl
                    platforms = pyopencl.get_platforms()
                    for platform in platforms:
                        devices = platform.get_devices()
                        for device in devices:
                            if device.type == pyopencl.device_type.GPU:
                                self._opencl_available = True
                                await self._add_opencl_gpu(device)
                except (ImportError, Exception):
                    logger.debug("OpenCL not available")
            
            if self._gpu_count == 0:
                logger.info("No GPUs detected")
                return False
            
            logger.info(f"GPU manager initialized with {self._gpu_count} GPUs")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize GPU manager: {e}")
            return False
    
    async def shutdown(self):
        """Shutdown GPU manager"""
        await self.stop_monitoring()
        
        if self._cuda_available:
            try:
                import pynvml
                pynvml.nvmlShutdown()
            except Exception:
                pass
        
        logger.info("GPU manager shutdown")
    
    async def get_hardware_info(self, hardware_id: Optional[str] = None) -> Union[HardwareInfo, List[HardwareInfo]]:
        """Get GPU hardware information"""
        if hardware_id:
            return self._hardware_info.get(hardware_id)
        else:
            return list(self._hardware_info.values())
    
    async def update_metrics(self):
        """Update GPU metrics"""
        if self._cuda_available:
            await self._update_cuda_metrics()
        elif self._rocm_available:
            await self._update_rocm_metrics()
        elif self._opencl_available:
            await self._update_opencl_metrics()
    
    async def execute_task(self, hardware_id: str, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a task on GPU"""
        if hardware_id not in self._hardware_info:
            raise ValueError(f"Unknown GPU hardware ID: {hardware_id}")
        
        task_type = task.get('task_type', 'unknown')
        payload = task.get('payload', {})
        
        # For GPU execution, we'll simulate task execution
        # In a real implementation, this would use CUDA, ROCm, or OpenCL
        
        execution_time = payload.get('estimated_time', 0.5)  # GPU tasks are typically faster
        await asyncio.sleep(execution_time)
        
        # Simulate result
        result = {
            'hardware_id': hardware_id,
            'task_type': task_type,
            'execution_time': execution_time,
            'result': f"Task {task_type} completed on GPU",
            'success': True
        }
        
        return result
    
    async def _initialize_cuda_gpus(self):
        """Initialize CUDA GPUs"""
        try:
            import pynvml
            
            for i in range(self._gpu_count):
                handle = pynvml.nvmlDeviceGetHandleByIndex(i)
                
                # Get GPU information
                name = pynvml.nvmlDeviceGetName(handle).decode('utf-8')
                
                # Get memory information
                mem_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
                memory_mb = int(mem_info.total / (1024 * 1024))
                
                # Get clock speeds
                try:
                    graphics_clock = pynvml.nvmlDeviceGetClockInfo(handle, pynvml.NVML_CLOCK_GRAPHICS)
                    memory_clock = pynvml.nvmlDeviceGetClockInfo(handle, pynvml.NVML_CLOCK_MEM)
                except Exception:
                    graphics_clock = 0
                    memory_clock = 0
                
                # Get compute capability
                try:
                    major, minor = pynvml.nvmlDeviceGetCudaComputeCapability(handle)
                    compute_capability = f"{major}.{minor}"
                except Exception:
                    compute_capability = "0.0"
                
                # Estimate FLOPS
                theoretical_flops = self._estimate_gpu_flops(name, graphics_clock, compute_capability)
                
                # Determine compute capability level
                if major >= 8:
                    capability = ComputeCapability.ENTERPRISE
                elif major >= 7:
                    capability = ComputeCapability.ADVANCED
                elif major >= 6:
                    capability = ComputeCapability.STANDARD
                else:
                    capability = ComputeCapability.BASIC
                
                hardware_info = HardwareInfo(
                    hardware_id=f"cuda_gpu_{i}",
                    hardware_type=HardwareType.GPU,
                    name=name,
                    vendor="NVIDIA",
                    model=name,
                    compute_capability=capability,
                    max_clock_speed_mhz=graphics_clock,
                    memory_size_mb=memory_mb,
                    memory_bandwidth_gbps=self._estimate_gpu_memory_bandwidth(name, memory_clock),
                    theoretical_flops=theoretical_flops,
                    supported_operations=self._get_gpu_supported_operations(),
                    supported_formats=self._get_gpu_supported_formats(),
                    optimal_batch_sizes=[16, 32, 64, 128, 256, 512],
                    optimal_thread_counts=[32, 64, 128, 256, 512, 1024],
                    driver_version=self._get_cuda_driver_version()
                )
                
                self._hardware_info[hardware_info.hardware_id] = hardware_info
            
        except Exception as e:
            logger.error(f"Failed to initialize CUDA GPUs: {e}")
    
    async def _initialize_rocm_gpus(self):
        """Initialize ROCm GPUs"""
        try:
            # Parse ROCm output to get GPU information
            result = subprocess.run(['rocm-smi', '--showproductname'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                gpu_lines = [line for line in result.stdout.split('\n') if 'GPU' in line]
                
                for i, line in enumerate(gpu_lines):
                    # Extract GPU name
                    parts = line.split(':')
                    if len(parts) >= 2:
                        name = parts[1].strip()
                        
                        # Get memory information
                        mem_result = subprocess.run(['rocm-smi', '--showmeminfo', 'vram'], 
                                                  capture_output=True, text=True)
                        memory_mb = 0
                        if mem_result.returncode == 0:
                            for mem_line in mem_result.stdout.split('\n'):
                                if f'GPU {i}' in mem_line:
                                    # Extract memory size
                                    import re
                                    match = re.search(r'(\d+)\s*MB', mem_line)
                                    if match:
                                        memory_mb = int(match.group(1))
                                    break
                        
                        hardware_info = HardwareInfo(
                            hardware_id=f"rocm_gpu_{i}",
                            hardware_type=HardwareType.GPU,
                            name=name,
                            vendor="AMD",
                            model=name,
                            compute_capability=ComputeCapability.ADVANCED,
                            max_clock_speed_mhz=1500,  # Default estimate
                            memory_size_mb=memory_mb,
                            memory_bandwidth_gbps=500,  # Default estimate
                            theoretical_flops=self._estimate_gpu_flops(name, 1500, "7.0"),
                            supported_operations=self._get_gpu_supported_operations(),
                            supported_formats=self._get_gpu_supported_formats(),
                            optimal_batch_sizes=[16, 32, 64, 128, 256, 512],
                            optimal_thread_counts=[64, 128, 256, 512, 1024]
                        )
                        
                        self._hardware_info[hardware_info.hardware_id] = hardware_info
            
        except Exception as e:
            logger.error(f"Failed to initialize ROCm GPUs: {e}")
    
    async def _add_opencl_gpu(self, device):
        """Add OpenCL GPU device"""
        try:
            hardware_info = HardwareInfo(
                hardware_id=f"opencl_gpu_{len(self._hardware_info)}",
                hardware_type=HardwareType.GPU,
                name=device.name,
                vendor=device.vendor,
                model=device.name,
                compute_capability=ComputeCapability.STANDARD,
                max_clock_speed_mhz=device.max_clock_frequency / 1e6,
                memory_size_mb=device.global_mem_size // (1024 * 1024),
                memory_bandwidth_gbps=100,  # Default estimate
                theoretical_flops=1e12,  # Default estimate
                supported_operations=self._get_gpu_supported_operations(),
                supported_formats=self._get_gpu_supported_formats(),
                optimal_batch_sizes=[16, 32, 64, 128, 256],
                optimal_thread_counts=[32, 64, 128, 256]
            )
            
            self._hardware_info[hardware_info.hardware_id] = hardware_info
            self._gpu_count += 1
            
        except Exception as e:
            logger.error(f"Failed to add OpenCL GPU: {e}")
    
    async def _update_cuda_metrics(self):
        """Update CUDA GPU metrics"""
        try:
            import pynvml
            
            for hardware_id, hardware_info in self._hardware_info.items():
                if not hardware_id.startswith('cuda_gpu_'):
                    continue
                
                # Extract GPU index
                gpu_index = int(hardware_id.split('_')[-1])
                handle = pynvml.nvmlDeviceGetHandleByIndex(gpu_index)
                
                # Get utilization
                try:
                    util = pynvml.nvmlDeviceGetUtilizationRates(handle)
                    hardware_info.utilization = util.gpu / 100.0
                    memory_util = pynvml.nvmlDeviceGetUtilizationRates(handle)
                    hardware_info.memory_utilization = memory_util.memory / 100.0
                except Exception:
                    pass
                
                # Get memory usage
                try:
                    mem_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
                    hardware_info.memory_utilization = mem_info.used / mem_info.total
                except Exception:
                    pass
                
                # Get power usage
                try:
                    power = pynvml.nvmlDeviceGetPowerUsage(handle) / 1000.0  # Convert mW to W
                    hardware_info.power_consumption_watts = power
                    
                    # Estimate power utilization (assuming 250W max)
                    hardware_info.power_utilization = power / 250.0
                except Exception:
                    pass
                
                # Get temperature
                try:
                    temp = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
                    hardware_info.temperature_celsius = temp
                except Exception:
                    pass
                
                # Update actual FLOPS based on utilization
                hardware_info.actual_flops = hardware_info.theoretical_flops * hardware_info.utilization
                hardware_info.last_updated = time.time()
            
        except Exception as e:
            logger.error(f"Failed to update CUDA metrics: {e}")
    
    async def _update_rocm_metrics(self):
        """Update ROCm GPU metrics"""
        try:
            # Get ROCm metrics
            result = subprocess.run(['rocm-smi', '--showuse'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.split('\n')
                
                for i, hardware_info in enumerate(self._hardware_info.values()):
                    if not hardware_info.hardware_id.startswith('rocm_gpu_'):
                        continue
                    
                    # Find the line for this GPU
                    gpu_line = None
                    for line in lines:
                        if f'GPU {i}' in line:
                            gpu_line = line
                            break
                    
                    if gpu_line:
                        # Extract utilization
                        import re
                        match = re.search(r'(\d+)%', gpu_line)
                        if match:
                            utilization = int(match.group(1)) / 100.0
                            hardware_info.utilization = utilization
                            hardware_info.actual_flops = hardware_info.theoretical_flops * utilization
                    
                    hardware_info.last_updated = time.time()
            
        except Exception as e:
            logger.error(f"Failed to update ROCm metrics: {e}")
    
    async def _update_opencl_metrics(self):
        """Update OpenCL GPU metrics"""
        # OpenCL doesn't provide standardized metrics
        # We'll use a simple time-based update
        for hardware_info in self._hardware_info.values():
            if not hardware_info.hardware_id.startswith('opencl_gpu_'):
                continue
            
            # Simulate some utilization changes
            hardware_info.utilization = max(0.0, hardware_info.utilization * 0.95)
            hardware_info.actual_flops = hardware_info.theoretical_flops * hardware_info.utilization
            hardware_info.last_updated = time.time()
    
    def _estimate_gpu_flops(self, name: str, clock_mhz: float, compute_capability: str) -> float:
        """Estimate GPU FLOPS based on GPU specifications"""
        # Simplified estimation based on GPU model and clock speed
        name_lower = name.lower()
        
        if 'rtx 4090' in name_lower:
            return 82.6e12  # 82.6 TFLOPS
        elif 'rtx 4080' in name_lower:
            return 48.7e12  # 48.7 TFLOPS
        elif 'rtx 4070' in name_lower:
            return 29.8e12  # 29.8 TFLOPS
        elif 'rtx 3090' in name_lower:
            return 35.7e12  # 35.7 TFLOPS
        elif 'rtx 3080' in name_lower:
            return 29.8e12  # 29.8 TFLOPS
        elif 'rtx 3070' in name_lower:
            return 20.3e12  # 20.3 TFLOPS
        elif 'a100' in name_lower:
            return 19.5e12  # 19.5 TFLOPS
        elif 'h100' in name_lower:
            return 67.0e12  # 67.0 TFLOPS
        elif 'v100' in name_lower:
            return 14.8e12  # 14.8 TFLOPS
        else:
            # Generic estimation based on clock speed
            # Assume 32 CUDA cores per SM, 2 FLOPs per core per clock
            sm_count = 80  # Default assumption
            cores_per_sm = 128
            flops_per_clock = 2
            
            return clock_mhz * 1e6 * sm_count * cores_per_sm * flops_per_clock
    
    def _estimate_gpu_memory_bandwidth(self, name: str, memory_clock_mhz: float) -> float:
        """Estimate GPU memory bandwidth"""
        name_lower = name.lower()
        
        if 'rtx 4090' in name_lower:
            return 1008  # GB/s
        elif 'rtx 4080' in name_lower:
            return 716.8  # GB/s
        elif 'rtx 4070' in name_lower:
            return 504.2  # GB/s
        elif 'rtx 3090' in name_lower:
            return 936.2  # GB/s
        elif 'rtx 3080' in name_lower:
            return 760.3  # GB/s
        elif 'rtx 3070' in name_lower:
            return 448.0  # GB/s
        elif 'a100' in name_lower:
            return 1555  # GB/s
        elif 'h100' in name_lower:
            return 3350  # GB/s
        elif 'v100' in name_lower:
            return 900  # GB/s
        else:
            # Generic estimation
            return 500  # GB/s
    
    def _get_gpu_supported_operations(self) -> Set[str]:
        """Get supported GPU operations"""
        return {
            'matrix_multiply', 'convolution', 'pooling', 'activation',
            'normalization', 'reshape', 'transpose', 'concatenate',
            'add', 'subtract', 'multiply', 'divide', 'exp', 'log',
            'sin', 'cos', 'tan', 'sqrt', 'abs', 'max', 'min',
            'reduce_sum', 'reduce_mean', 'reduce_max', 'reduce_min',
            'gather', 'scatter', 'argmax', 'argmin', 'topk'
        }
    
    def _get_gpu_supported_formats(self) -> Set[str]:
        """Get supported GPU data formats"""
        return {
            'float32', 'float16', 'bfloat16', 'int8', 'int16', 'int32',
            'uint8', 'uint16', 'uint32', 'bool'
        }
    
    def _get_cuda_driver_version(self) -> str:
        """Get CUDA driver version"""
        try:
            import pynvml
            return pynvml.nvmlSystemGetDriverVersion().decode('utf-8')
        except Exception:
            return ""


class NPUManager(HardwareManager):
    """NPU (Neural Processing Unit) hardware manager"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """Initialize NPU manager"""
        super().__init__(config)
        self._npu_count = 0
    
    async def initialize(self) -> bool:
        """Initialize NPU manager"""
        try:
            # Check for NPU availability
            # This would typically involve checking for specific NPU hardware
            # such as Intel NPU, Qualcomm Hexagon, Apple Neural Engine, etc.
            
            # For now, we'll simulate NPU detection
            # In a real implementation, this would use vendor-specific APIs
            
            # Check for Intel NPU
            if await self._detect_intel_npu():
                await self._initialize_intel_npu()
            
            # Check for Apple Neural Engine
            if platform.system() == "Darwin":
                if await self._detect_apple_neural_engine():
                    await self._initialize_apple_neural_engine()
            
            if self._npu_count == 0:
                logger.info("No NPUs detected")
                return False
            
            logger.info(f"NPU manager initialized with {self._npu_count} NPUs")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize NPU manager: {e}")
            return False
    
    async def shutdown(self):
        """Shutdown NPU manager"""
        await self.stop_monitoring()
        logger.info("NPU manager shutdown")
    
    async def get_hardware_info(self, hardware_id: Optional[str] = None) -> Union[HardwareInfo, List[HardwareInfo]]:
        """Get NPU hardware information"""
        if hardware_id:
            return self._hardware_info.get(hardware_id)
        else:
            return list(self._hardware_info.values())
    
    async def update_metrics(self):
        """Update NPU metrics"""
        # NPU metrics would typically be obtained from vendor-specific APIs
        # For now, we'll simulate metric updates
        
        for hardware_info in self._hardware_info.values():
            # Simulate utilization changes
            hardware_info.utilization = max(0.0, hardware_info.utilization * 0.95)
            hardware_info.actual_flops = hardware_info.theoretical_flops * hardware_info.utilization
            hardware_info.last_updated = time.time()
    
    async def execute_task(self, hardware_id: str, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a task on NPU"""
        if hardware_id not in self._hardware_info:
            raise ValueError(f"Unknown NPU hardware ID: {hardware_id}")
        
        task_type = task.get('task_type', 'unknown')
        payload = task.get('payload', {})
        
        # For NPU execution, we'll simulate task execution
        # In a real implementation, this would use vendor-specific NPU APIs
        
        execution_time = payload.get('estimated_time', 0.1)  # NPU tasks are very fast
        await asyncio.sleep(execution_time)
        
        # Simulate result
        result = {
            'hardware_id': hardware_id,
            'task_type': task_type,
            'execution_time': execution_time,
            'result': f"Task {task_type} completed on NPU",
            'success': True
        }
        
        return result
    
    async def _detect_intel_npu(self) -> bool:
        """Detect Intel NPU"""
        try:
            # Check for Intel NPU device
            # This would typically involve checking for specific device files or registry entries
            return False  # Placeholder
        except Exception:
            return False
    
    async def _initialize_intel_npu(self):
        """Initialize Intel NPU"""
        # Placeholder for Intel NPU initialization
        pass
    
    async def _detect_apple_neural_engine(self) -> bool:
        """Detect Apple Neural Engine"""
        try:
            # Check for Apple Neural Engine
            # This would typically involve checking system information
            return True  # Assume available on Apple Silicon
        except Exception:
            return False
    
    async def _initialize_apple_neural_engine(self):
        """Initialize Apple Neural Engine"""
        try:
            hardware_info = HardwareInfo(
                hardware_id="apple_neural_engine",
                hardware_type=HardwareType.NPU,
                name="Apple Neural Engine",
                vendor="Apple",
                model="Neural Engine",
                compute_capability=ComputeCapability.ADVANCED,
                max_clock_speed_mhz=1000,  # Estimate
                memory_size_mb=16,  # Estimate
                memory_bandwidth_gbps=50,  # Estimate
                theoretical_flops=15e12,  # 15 TFLOPS estimate
                supported_operations={
                    'matrix_multiply', 'convolution', 'activation',
                    'pooling', 'normalization', 'reshape'
                },
                supported_formats={'float16', 'int8', 'bool'},
                optimal_batch_sizes=[1, 2, 4, 8, 16, 32],
                optimal_thread_counts=[1, 2, 4, 8, 16]
            )
            
            self._hardware_info[hardware_info.hardware_id] = hardware_info
            self._npu_count += 1
            
        except Exception as e:
            logger.error(f"Failed to initialize Apple Neural Engine: {e}")


class HeterogeneousHardwareManager:
    """Manager for heterogeneous hardware resources"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize heterogeneous hardware manager
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        
        # Hardware managers
        self._cpu_manager = CPUManager(config)
        self._gpu_manager = GPUManager(config)
        self._npu_manager = NPUManager(config)
        
        # All hardware info
        self._all_hardware: Dict[str, HardwareInfo] = {}
        
        # Hardware by type
        self._hardware_by_type: Dict[HardwareType, List[str]] = {
            hw_type: [] for hw_type in HardwareType
        }
        
        # Task routing table
        self._task_routing: Dict[str, List[HardwareType]] = {
            'matrix_multiply': [HardwareType.GPU, HardwareType.NPU, HardwareType.CPU],
            'convolution': [HardwareType.GPU, HardwareType.NPU, HardwareType.CPU],
            'pooling': [HardwareType.GPU, HardwareType.NPU, HardwareType.CPU],
            'activation': [HardwareType.GPU, HardwareType.NPU, HardwareType.CPU],
            'normalization': [HardwareType.GPU, HardwareType.NPU, HardwareType.CPU],
            'reshape': [HardwareType.CPU],
            'transpose': [HardwareType.CPU],
            'concatenate': [HardwareType.CPU],
            'reduce_sum': [HardwareType.GPU, HardwareType.CPU],
            'reduce_mean': [HardwareType.GPU, HardwareType.CPU],
            'gather': [HardwareType.CPU],
            'scatter': [HardwareType.CPU],
            'argmax': [HardwareType.GPU, HardwareType.CPU],
            'argmin': [HardwareType.GPU, HardwareType.CPU],
            'topk': [HardwareType.GPU, HardwareType.CPU]
        }
        
        # Performance history
        self._performance_history: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
        
        # Statistics
        self._stats = {
            'total_hardware': 0,
            'cpu_count': 0,
            'gpu_count': 0,
            'npu_count': 0,
            'total_theoretical_flops': 0.0,
            'total_actual_flops': 0.0,
            'avg_utilization': 0.0,
            'tasks_executed': 0,
            'avg_execution_time': 0.0
        }
    
    async def initialize(self) -> bool:
        """Initialize heterogeneous hardware manager"""
        try:
            # Initialize all hardware managers
            await self._cpu_manager.initialize()
            await self._gpu_manager.initialize()
            await self._npu_manager.initialize()
            
            # Collect all hardware information
            await self._collect_hardware_info()
            
            # Start monitoring
            await self._cpu_manager.start_monitoring()
            await self._gpu_manager.start_monitoring()
            await self._npu_manager.start_monitoring()
            
            # Update statistics
            self._update_statistics()
            
            logger.info(f"Heterogeneous hardware manager initialized with {self._stats['total_hardware']} devices")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize heterogeneous hardware manager: {e}")
            return False
    
    async def shutdown(self):
        """Shutdown heterogeneous hardware manager"""
        await self._cpu_manager.shutdown()
        await self._gpu_manager.shutdown()
        await self._npu_manager.shutdown()
        
        logger.info("Heterogeneous hardware manager shutdown")
    
    async def get_hardware_info(self, hardware_id: Optional[str] = None) -> Union[HardwareInfo, List[HardwareInfo]]:
        """Get hardware information"""
        if hardware_id:
            return self._all_hardware.get(hardware_id)
        else:
            return list(self._all_hardware.values())
    
    async def get_hardware_by_type(self, hardware_type: HardwareType) -> List[HardwareInfo]:
        """Get hardware by type"""
        hardware_ids = self._hardware_by_type.get(hardware_type, [])
        return [self._all_hardware[hw_id] for hw_id in hardware_ids]
    
    async def find_best_hardware(self, task_type: str, requirements: Dict[str, Any]) -> Optional[str]:
        """
        Find the best hardware for a specific task
        
        Args:
            task_type: Type of task to execute
            requirements: Task requirements
            
        Returns:
            Hardware ID of best device
        """
        # Get preferred hardware types for this task
        preferred_types = self._task_routing.get(task_type, [HardwareType.CPU])
        
        # Find available hardware
        candidates = []
        
        for hw_type in preferred_types:
            hardware_ids = self._hardware_by_type.get(hw_type, [])
            
            for hw_id in hardware_ids:
                hw_info = self._all_hardware[hw_id]
                
                # Check if hardware can fulfill requirements
                if self._can_fulfill_requirements(hw_info, requirements):
                    # Calculate score
                    score = self._calculate_hardware_score(hw_info, task_type, requirements)
                    candidates.append((hw_id, score))
        
        if not candidates:
            return None
        
        # Sort by score (descending)
        candidates.sort(key=lambda x: x[1], reverse=True)
        
        return candidates[0][0]
    
    async def execute_task(self, task_type: str, requirements: Dict[str, Any], 
                          payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute a task on the best available hardware
        
        Args:
            task_type: Type of task to execute
            requirements: Task requirements
            payload: Task payload
            
        Returns:
            Execution result
        """
        # Find best hardware
        hardware_id = await self.find_best_hardware(task_type, requirements)
        
        if not hardware_id:
            raise ValueError(f"No suitable hardware found for task type: {task_type}")
        
        # Get hardware info
        hw_info = self._all_hardware[hardware_id]
        
        # Prepare task
        task = {
            'task_type': task_type,
            'requirements': requirements,
            'payload': payload
        }
        
        # Execute task on appropriate manager
        start_time = time.time()
        
        try:
            if hw_info.hardware_type == HardwareType.CPU:
                result = await self._cpu_manager.execute_task(hardware_id, task)
            elif hw_info.hardware_type == HardwareType.GPU:
                result = await self._gpu_manager.execute_task(hardware_id, task)
            elif hw_info.hardware_type == HardwareType.NPU:
                result = await self._npu_manager.execute_task(hardware_id, task)
            else:
                raise ValueError(f"Unsupported hardware type: {hw_info.hardware_type}")
            
            # Record performance
            execution_time = time.time() - start_time
            await self._record_performance(hardware_id, task_type, execution_time, True)
            
            # Update statistics
            self._stats['tasks_executed'] += 1
            self._update_statistics()
            
            return result
            
        except Exception as e:
            # Record performance
            execution_time = time.time() - start_time
            await self._record_performance(hardware_id, task_type, execution_time, False)
            
            logger.error(f"Failed to execute task {task_type} on {hardware_id}: {e}")
            raise
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get comprehensive statistics"""
        return self._stats.copy()
    
    async def _collect_hardware_info(self):
        """Collect hardware information from all managers"""
        # Clear existing info
        self._all_hardware.clear()
        for hw_type in HardwareType:
            self._hardware_by_type[hw_type].clear()
        
        # Collect CPU info
        cpu_hardware = await self._cpu_manager.get_hardware_info()
        if isinstance(cpu_hardware, list):
            for hw in cpu_hardware:
                self._all_hardware[hw.hardware_id] = hw
                self._hardware_by_type[hw.hardware_type].append(hw.hardware_id)
        
        # Collect GPU info
        gpu_hardware = await self._gpu_manager.get_hardware_info()
        if isinstance(gpu_hardware, list):
            for hw in gpu_hardware:
                self._all_hardware[hw.hardware_id] = hw
                self._hardware_by_type[hw.hardware_type].append(hw.hardware_id)
        
        # Collect NPU info
        npu_hardware = await self._npu_manager.get_hardware_info()
        if isinstance(npu_hardware, list):
            for hw in npu_hardware:
                self._all_hardware[hw.hardware_id] = hw
                self._hardware_by_type[hw.hardware_type].append(hw.hardware_id)
    
    def _can_fulfill_requirements(self, hw_info: HardwareInfo, requirements: Dict[str, Any]) -> bool:
        """Check if hardware can fulfill requirements"""
        # Check memory requirements
        if 'memory_mb' in requirements:
            required_memory = requirements['memory_mb']
            available_memory = hw_info.memory_size_mb * (1.0 - hw_info.memory_utilization)
            if required_memory > available_memory:
                return False
        
        # Check operation support
        if 'operations' in requirements:
            required_ops = set(requirements['operations'])
            if not required_ops.issubset(hw_info.supported_operations):
                return False
        
        # Check format support
        if 'formats' in requirements:
            required_formats = set(requirements['formats'])
            if not required_formats.issubset(hw_info.supported_formats):
                return False
        
        # Check compute capability
        if 'compute_capability' in requirements:
            required_capability = requirements['compute_capability']
            capability_levels = {
                ComputeCapability.BASIC: 1,
                ComputeCapability.STANDARD: 2,
                ComputeCapability.ADVANCED: 3,
                ComputeCapability.ENTERPRISE: 4
            }
            
            required_level = capability_levels.get(required_capability, 1)
            available_level = capability_levels.get(hw_info.compute_capability, 1)
            
            if required_level > available_level:
                return False
        
        return True
    
    def _calculate_hardware_score(self, hw_info: HardwareInfo, task_type: str, 
                                 requirements: Dict[str, Any]) -> float:
        """Calculate hardware score for task"""
        # Base score on theoretical FLOPS
        score = hw_info.theoretical_flops
        
        # Adjust for utilization (lower utilization is better)
        score *= (1.0 - hw_info.utilization)
        
        # Adjust for memory utilization
        score *= (1.0 - hw_info.memory_utilization)
        
        # Adjust for power utilization
        score *= (1.0 - hw_info.power_utilization)
        
        # Adjust for temperature (lower temperature is better)
        if hw_info.temperature_celsius > 0:
            temp_factor = max(0.5, 1.0 - (hw_info.temperature_celsius - 30) / 70)
            score *= temp_factor
        
        # Adjust for historical performance
        history = self._performance_history.get(hw_info.hardware_id, [])
        if history:
            # Get recent performance for this task type
            recent_performances = [
                h for h in history[-10:]  # Last 10 records
                if h.get('task_type') == task_type and h.get('success', False)
            ]
            
            if recent_performances:
                avg_execution_time = sum(h['execution_time'] for h in recent_performances) / len(recent_performances)
                # Lower execution time is better
                score *= (1.0 / max(avg_execution_time, 0.1))
        
        return score
    
    async def _record_performance(self, hardware_id: str, task_type: str, 
                                execution_time: float, success: bool):
        """Record performance metrics"""
        performance_record = {
            'timestamp': time.time(),
            'task_type': task_type,
            'execution_time': execution_time,
            'success': success
        }
        
        self._performance_history[hardware_id].append(performance_record)
        
        # Keep only last 100 records
        if len(self._performance_history[hardware_id]) > 100:
            self._performance_history[hardware_id] = self._performance_history[hardware_id][-100:]
    
    def _update_statistics(self):
        """Update statistics"""
        self._stats['total_hardware'] = len(self._all_hardware)
        self._stats['cpu_count'] = len(self._hardware_by_type[HardwareType.CPU])
        self._stats['gpu_count'] = len(self._hardware_by_type[HardwareType.GPU])
        self._stats['npu_count'] = len(self._hardware_by_type[HardwareType.NPU])
        
        # Calculate FLOPS
        total_theoretical = sum(hw.theoretical_flops for hw in self._all_hardware.values())
        total_actual = sum(hw.actual_flops for hw in self._all_hardware.values())
        
        self._stats['total_theoretical_flops'] = total_theoretical
        self._stats['total_actual_flops'] = total_actual
        
        # Calculate average utilization
        if self._all_hardware:
            avg_utilization = sum(hw.utilization for hw in self._all_hardware.values()) / len(self._all_hardware)
            self._stats['avg_utilization'] = avg_utilization
        
        # Calculate average execution time
        all_records = []
        for records in self._performance_history.values():
            all_records.extend(records)
        
        if all_records:
            successful_records = [r for r in all_records if r.get('success', False)]
            if successful_records:
                avg_execution_time = sum(r['execution_time'] for r in successful_records) / len(successful_records)
                self._stats['avg_execution_time'] = avg_execution_time


# Import required modules
try:
    import psutil
    import multiprocessing
except ImportError:
    logger.warning("psutil or multiprocessing not available, CPU manager will have limited functionality")

