# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# NoodleVision Benchmark Suite
# Comprehensive performance testing for NoodleVision modules
# """

import argparse
import asyncio
import time
import logging
import psutil
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pathlib.Path
import typing.Dict
import json
import os
import sys

# Add NoodleVision to path
sys.path.append(str(Path(__file__).parent.parent / "src"))

# Mock imports for NoodleVision modules since they are not fully implemented yet
class MockVideoFileStream
    #     def __init__(self, source, backend="mock"):
    self.source = source
    self.backend = backend
    self.initialized = False

    #     async def initialize(self):
    self.initialized = True

    #     async def _read_frame(self):
    #         import numpy as np
            return MockMediaFrame(np.random.rand(100, 100, 3))

    #     async def close(self):
    self.initialized = False

    #     async def __aenter__(self):
            await self.initialize()
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
            await self.close()

    #     async def __aiter__(self):
            await self.initialize()
    #         for _ in range(100):  # Limit frames
                yield await self._read_frame()
            await self.close()

class MockCameraStream(MockVideoFileStream)
    #     def __init__(self, source, backend="mock"):
            super().__init__(source, backend)

class RealCameraStream
    #     def __init__(self, source, backend="cv2"):
    self.source = source
    self.backend = backend
    self.cap = None
    self.initialized = False

    #     async def initialize(self):
    #         try:
    #             import cv2
    self.cap = cv2.VideoCapture(0)  # Use default camera
    #             if not self.cap.isOpened():
                    raise RuntimeError("Could not open camera")
    self.initialized = True
    #         except ImportError:
                logger.warning("OpenCV not available, falling back to mock")
    self.cap = None
    self.initialized = False
    #         except Exception as e:
                logger.error(f"Error initializing camera: {e}")
    self.cap = None
    self.initialized = False

    #     async def _read_frame(self):
    #         if not self.initialized or not self.cap:
                return MockMediaFrame(np.random.rand(100, 100, 3))

    ret, frame = self.cap.read()
    #         if not ret:
                return MockMediaFrame(np.random.rand(100, 100, 3))

    #         # Convert BGR to RGB
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            return MockMediaFrame(frame)

    #     async def close(self):
    #         if self.cap:
                self.cap.release()
    self.initialized = False

    #     async def __aenter__(self):
            await self.initialize()
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
            await self.close()

    #     async def __aiter__(self):
            await self.initialize()
    frame_count = 0
    #         while frame_count < 100:  # Limit frames
    frame = await self._read_frame()
    #             yield frame
    frame_count + = 1
            await self.close()

class MockAudioStream
    #     def __init__(self, source):
    self.source = source
    self.initialized = False

    #     async def initialize(self):
    self.initialized = True

    #     async def _read_frame(self):
    #         import numpy as np
            return MockMediaFrame(np.random.rand(1024))

    #     async def close(self):
    self.initialized = False

    #     async def __aenter__(self):
            await self.initialize()
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
            await self.close()

    #     async def __aiter__(self):
            await self.initialize()
    #         for _ in range(100):  # Limit frames
                yield await self._read_frame()
            await self.close()

class MockMediaFrame
    #     def __init__(self, data):
    self.data = data

    #     def to_tensor(self):
            return MockTensor(self.data)

    #     @property
    #     def shape(self):
    #         return self.data.shape

class MockTensor
    #     def __init__(self, data):
    self.data = data

class MockConvolutionOperator
    #     def __init__(self, in_channels, out_channels, kernel_size, use_gpu=False):
    self.in_channels = in_channels
    self.out_channels = out_channels
    self.kernel_size = kernel_size
    self.use_gpu = use_gpu

    #     def forward(self, tensor):
    #         import numpy as np
    #         # Mock conv output
    #         if len(tensor.shape) == 4:  # Batch, Channels, Height, Width
                return MockMediaFrame(np.random.rand(tensor.shape[0], self.out_channels, tensor.shape[2], tensor.shape[3]))
    #         else:
                return MockMediaFrame(np.random.rand(self.out_channels, tensor.shape[0], tensor.shape[1]))

    #     def _calculate_output_shape(self, input_shape):
            return (self.out_channels, input_shape[1], input_shape[2])

    #     def trace(self, input_shape):
            return {"type": "convolution", "input_shape": input_shape, "output_shape": self._calculate_output_shape(input_shape)}

    #     def visualize(self):
    return f"Convolution(K = {self.kernel_size}, C={self.in_channels}->{self.out_channels})"

class MockPoolingOperator
    #     def __init__(self, pool_type, kernel_size, stride, use_gpu=False):
    self.pool_type = pool_type
    self.kernel_size = kernel_size
    self.stride = stride
    self.use_gpu = use_gpu

    #     def forward(self, tensor):
    #         import numpy as np
    #         # Mock pooling output
    #         if len(tensor.shape) == 4:
    h, w = tensor.shape[2], tensor.shape[3]
    new_h = math.divide(h, / self.kernel_size)
    new_w = math.divide(w, / self.kernel_size)
                return MockMediaFrame(np.random.rand(tensor.shape[0], tensor.shape[1], new_h, new_w))
    #         else:
                return MockMediaFrame(np.random.rand(tensor.shape[0] // self.kernel_size, tensor.shape[1] // self.kernel_size))

    #     def _calculate_output_shape(self, input_shape):
            return (input_shape[0] // self.kernel_size, input_shape[1] // self.kernel_size)

class MockActivationOperator
    #     def __init__(self, activation_type, use_gpu=False):
    self.activation_type = activation_type
    self.use_gpu = use_gpu

    #     def forward(self, tensor):
    #         import numpy as np
    #         # Mock activation output
            return MockMediaFrame(np.random.rand(*tensor.shape))

    #     def _calculate_output_shape(self, input_shape):
    #         return input_shape

class MockFFTOperator
    #     def __init__(self, sample_rate, channels, frame_size, use_gpu=False):
    self.sample_rate = sample_rate
    self.channels = channels
    self.frame_size = frame_size
    self.use_gpu = use_gpu

    #     def forward(self, tensor):
    #         import numpy as np
    #         # Mock FFT output
    #         return MockMediaFrame(np.random.rand(513, 2))  # (freq_bins, 2) for magnitude and phase

    #     def _calculate_output_shape(self, input_shape):
            return (513, 2)

class MockSpectrogramOperator
    #     def __init__(self, sample_rate, channels, frame_size, hop_size, use_gpu=False):
    self.sample_rate = sample_rate
    self.channels = channels
    self.frame_size = frame_size
    self.hop_size = hop_size
    self.use_gpu = use_gpu

    #     def forward(self, tensor):
    #         import numpy as np
    #         # Mock spectrogram output
    frames = (tensor.shape[0] - self.frame_size) // self.hop_size + 1
            return MockMediaFrame(np.random.rand(frames, 513))

    #     def _calculate_output_shape(self, input_shape):
    frames = (input_shape[0] - self.frame_size) // self.hop_size + 1
            return (frames, 513)

class MockMFCCOperator
    #     def __init__(self, sample_rate, channels, n_mfcc, use_gpu=False):
    self.sample_rate = sample_rate
    self.channels = channels
    self.n_mfcc = n_mfcc
    self.use_gpu = use_gpu

    #     def forward(self, tensor):
    #         import numpy as np
    #         # Mock MFCC output
    frames = (tensor.shape[0] - 2048) // 512 + 1
            return MockMediaFrame(np.random.rand(frames, self.n_mfcc))

    #     def _calculate_output_shape(self, input_shape):
    frames = (input_shape[0] - 2048) // 512 + 1
            return (frames, self.n_mfcc)

class MockDynamicBatcher
    #     def __init__(self, target_latency, target_throughput, max_batch_size, adaptive_mode=False):
    self.target_latency = target_latency
    self.target_throughput = target_throughput
    self.max_batch_size = max_batch_size
    self.adaptive_mode = adaptive_mode

    #     def get_optimization_config(self):
    #         return {
    #             "name": "dynamic_batcher",
    #             "target_latency": self.target_latency,
    #             "max_batch_size": self.max_batch_size
    #         }

    #     def optimize_stream(self, stream):
            return MockOptimizedStream(stream)

    #     def stop_background_processing(self):
    #         pass

class MockAdaptiveMemoryManager
    #     def __init__(self, target_latency, ram_threshold, disk_threshold):
    self.target_latency = target_latency
    self.ram_threshold = ram_threshold
    self.disk_threshold = disk_threshold

    #     def decide_storage(self, tensor):
    #         return "ram"  # Always use RAM for testing

    #     def store_tensor(self, tensor):
    #         return "ram_test_location"

    #     def optimize_memory(self):
    #         pass

class MockOptimizedStream
    #     def __init__(self, original_stream):
    self.original_stream = original_stream

    #     async def __aenter__(self):
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
    #         pass

    #     async def __aiter__(self):
    #         async for frame in self.original_stream:
    #             yield frame

class MockStreamOptimizationUtils
    #     @staticmethod
    #     def get_optimization_recommendations(stream):
    #         return [
    #             {"priority": "high", "recommendation": "Enable GPU processing", "reason": "GPU available"},
    #             {"priority": "medium", "recommendation": "Increase batch size", "reason": "Low memory usage"}
    #         ]

    #     @staticmethod
    #     def benchmark_optimization(stream, optimizer, duration):
    #         import time
    start_time = time.time()
    frame_count = 0

    #         # Mock benchmark without async with
    mock_start = time.time()
    #         while time.time() - mock_start < duration:
    frame_count + = 1
    #             if frame_count >= 100:  # Limit frames
    #                 break

    #         return {
    #             "avg_fps": frame_count / duration,
    #             "avg_processing_time": duration / frame_count
    #         }

# Configure logging first
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler("noodlevision_benchmark.log"),
        logging.StreamHandler()
#     ]
# )
logger = logging.getLogger("NoodleVisionBenchmark")

# Import real camera if OpenCV is available
try
    #     import cv2
    #     # Use real camera classes if OpenCV is available
    CameraStream = RealCameraStream
    #     logger.info("Using real camera stream with OpenCV")
except ImportError
    #     # Fall back to mock
    CameraStream = MockCameraStream
        logger.warning("OpenCV not available, using mock camera stream")

# Use mock classes for other components
VideoFileStream = MockVideoFileStream
AudioStream = MockAudioStream
ConvolutionOperator = MockConvolutionOperator
PoolingOperator = MockPoolingOperator
ActivationOperator = MockActivationOperator
FFTOperator = MockFFTOperator
SpectrogramOperator = MockSpectrogramOperator
MFCCOperator = MockMFCCOperator
DynamicBatcher = MockDynamicBatcher
AdaptiveMemoryManager = MockAdaptiveMemoryManager
StreamOptimizationUtils = MockStreamOptimizationUtils

class BenchmarkResult
    #     """Container for benchmark results"""

    #     def __init__(self, name: str, metric: str, value: float, unit: str,
    metadata: Optional[Dict] = None):
    self.name = name
    self.metric = metric
    self.value = value
    self.unit = unit
    self.metadata = metadata or {}
    self.timestamp = time.time()

    #     def to_dict(self) -Dict):
    #         return {
    #             "name": self.name,
    #             "metric": self.metric,
    #             "value": self.value,
    #             "unit": self.unit,
    #             "metadata": self.metadata,
    #             "timestamp": self.timestamp
    #         }

class SystemMonitor
    #     """Monitor system resources during benchmarks"""

    #     def __init__(self):
    self.process = psutil.Process()
    self.initial_stats = self._get_current_stats()

    #     def _get_current_stats(self) -Dict):
    #         """Get current system statistics"""
    #         return {
                "cpu_percent": self.process.cpu_percent(),
                "memory_percent": self.process.memory_percent(),
                "memory_rss": self.process.memory_info().rss / (1024 * 1024),  # MB
                "memory_vms": self.process.memory_info().vms / (1024 * 1024),  # MB
                "threads": self.process.num_threads()
    #         }

    #     def get_stats_since_start(self) -Dict):
    #         """Get statistics since monitoring started"""
    current_stats = self._get_current_stats()
    #         return {
    #             "cpu_percent_delta": current_stats["cpu_percent"] - self.initial_stats["cpu_percent"],
    #             "memory_percent_delta": current_stats["memory_percent"] - self.initial_stats["memory_percent"],
    #             "memory_rss_delta": current_stats["memory_rss"] - self.initial_stats["memory_rss"],
    #             "memory_vms_delta": current_stats["memory_vms"] - self.initial_stats["memory_vms"],
    #             "threads_delta": current_stats["threads"] - self.initial_stats["threads"]
    #         }

class BenchmarkRunner
    #     """Run benchmarks for NoodleVision modules"""

    #     def __init__(self, iterations: int = 10, warmup: int = 3):
    self.iterations = iterations
    self.warmup = warmup
    self.results: List[BenchmarkResult] = []
    self.system_monitor = SystemMonitor()

    #     def add_result(self, result: BenchmarkResult):
    #         """Add a benchmark result"""
            self.results.append(result)
            logger.info(f"Benchmark: {result.name} - {result.metric}: {result.value} {result.unit}")

    #     async def benchmark_video_io(self, source_type: str, source: str) -List[BenchmarkResult]):
    #         """Benchmark video I/O operations"""
            logger.info(f"Benchmarking video I/O: {source_type} - {source}")

    results = []

    #         for i in range(self.warmup + self.iterations):
    #             try:
    #                 # Create stream
    #                 if source_type == "file":
    stream = VideoFileStream(source)
    #                 elif source_type == "camera":
    stream = CameraStream(source)
    #                 else:
                        logger.error(f"Unsupported video source type: {source_type}")
    #                     return results

    #                 # Initialize
    start_time = time.time()
                    await stream.initialize()
    init_time = time.time() - start_time

    #                 # Read frames
    frame_times = []
    frame_count = 0
    start_time = time.time()

    #                 # Use stream directly without async with for mock
    #                 async for frame in stream:
    frame_start = time.time()

    #                     # Process frame
    tensor = frame.to_tensor()
                        frame_times.append(time.time() - frame_start)
    frame_count + = 1

    #                     if frame_count >= 100:  # Limit frames for benchmarking
    #                         break

    total_time = time.time() - start_time
    avg_frame_time = np.mean(frame_times)
    fps = math.divide(frame_count, total_time)

    #                 # Add results
                    results.append(BenchmarkResult(
    name = f"VideoIO_{source_type}_{i}",
    metric = "initialization_time",
    value = init_time,
    unit = "seconds"
    #                 ))

                    results.append(BenchmarkResult(
    name = f"VideoIO_{source_type}_{i}",
    metric = "total_processing_time",
    value = total_time,
    unit = "seconds",
    metadata = {"frame_count": frame_count}
    #                 ))

                    results.append(BenchmarkResult(
    name = f"VideoIO_{source_type}_{i}",
    metric = "average_frame_time",
    value = avg_frame_time,
    unit = "seconds"
    #                 ))

                    results.append(BenchmarkResult(
    name = f"VideoIO_{source_type}_{i}",
    metric = "fps",
    value = fps,
    unit = "fps"
    #                 ))

    #                 # Clean up
                    await stream.close()

    #             except Exception as e:
                    logger.error(f"Error in video IO benchmark {i}: {e}")
    #                 continue

    #         # Calculate averages
    #         if results:
    #             avg_init_time = np.mean([r.value for r in results if r.metric == "initialization_time"])
    #             avg_fps = np.mean([r.value for r in results if r.metric == "fps"])

                results.append(BenchmarkResult(
    name = f"VideoIO_{source_type}_avg",
    metric = "average_initialization_time",
    value = avg_init_time,
    unit = "seconds"
    #             ))

                results.append(BenchmarkResult(
    name = f"VideoIO_{source_type}_avg",
    metric = "average_fps",
    value = avg_fps,
    unit = "fps"
    #             ))

    #         return results

    #     async def benchmark_audio_io(self, source: str) -List[BenchmarkResult]):
    #         """Benchmark audio I/O operations"""
            logger.info(f"Benchmarking audio I/O: {source}")

    results = []

    #         for i in range(self.warmup + self.iterations):
    #             try:
    #                 # Create stream
    stream = AudioStream(source)

    #                 # Initialize
    start_time = time.time()
                    await stream.initialize()
    init_time = time.time() - start_time

    #                 # Read frames
    frame_times = []
    frame_count = 0
    start_time = time.time()

    #                 async with stream:
    #                     async for frame in stream:
    frame_start = time.time()

    #                         # Process frame
    tensor = frame.to_tensor()
                            frame_times.append(time.time() - frame_start)
    frame_count + = 1

    #                         if frame_count >= 100:  # Limit frames for benchmarking
    #                             break

    total_time = time.time() - start_time
    avg_frame_time = np.mean(frame_times)
    fps = math.divide(frame_count, total_time)

    #                 # Add results
                    results.append(BenchmarkResult(
    name = f"AudioIO_{i}",
    metric = "initialization_time",
    value = init_time,
    unit = "seconds"
    #                 ))

                    results.append(BenchmarkResult(
    name = f"AudioIO_{i}",
    metric = "total_processing_time",
    value = total_time,
    unit = "seconds",
    metadata = {"frame_count": frame_count}
    #                 ))

                    results.append(BenchmarkResult(
    name = f"AudioIO_{i}",
    metric = "average_frame_time",
    value = avg_frame_time,
    unit = "seconds"
    #                 ))

                    results.append(BenchmarkResult(
    name = f"AudioIO_{i}",
    metric = "fps",
    value = fps,
    unit = "fps"
    #                 ))

    #                 # Clean up
                    await stream.close()

    #             except Exception as e:
                    logger.error(f"Error in audio IO benchmark {i}: {e}")
    #                 continue

    #         # Calculate averages
    #         if results:
    #             avg_init_time = np.mean([r.value for r in results if r.metric == "initialization_time"])
    #             avg_fps = np.mean([r.value for r in results if r.metric == "fps"])

                results.append(BenchmarkResult(
    name = "AudioIO_avg",
    metric = "average_initialization_time",
    value = avg_init_time,
    unit = "seconds"
    #             ))

                results.append(BenchmarkResult(
    name = "AudioIO_avg",
    metric = "average_fps",
    value = avg_fps,
    unit = "fps"
    #             ))

    #         return results

    #     async def benchmark_video_operators(self) -List[BenchmarkResult]):
    #         """Benchmark video tensor operations"""
            logger.info("Benchmarking video tensor operators")

    results = []

    #         # Create test data
    test_input = np.random.rand(1, 3, 256, 256).astype(np.float32)
    test_tensor = MockMediaFrame(test_input)  # Create mock tensor

    #         # Benchmark convolution
    conv = ConvolutionOperator(
    in_channels = 3,
    out_channels = 64,
    kernel_size = 3,
    use_gpu = False
    #         )

    conv_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    output = conv.forward(test_tensor)
                conv_times.append(time.time() - start_time)

    avg_conv_time = np.mean(conv_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "ConvolutionOperator",
    metric = "average_processing_time",
    value = avg_conv_time,
    unit = "seconds",
    metadata = {"input_size": test_input.shape, "output_size": output.data.shape}
    #         ))

    #         # Benchmark pooling
    pool = PoolingOperator(
    pool_type = "max",
    kernel_size = 2,
    stride = 2,
    use_gpu = False
    #         )

    pool_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    output = pool.forward(test_tensor)
                pool_times.append(time.time() - start_time)

    avg_pool_time = np.mean(pool_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "PoolingOperator",
    metric = "average_processing_time",
    value = avg_pool_time,
    unit = "seconds",
    metadata = {"input_size": test_input.shape, "output_size": output.data.shape}
    #         ))

    #         # Benchmark activation
    relu = ActivationOperator(activation_type="relu", use_gpu=False)

    relu_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    output = relu.forward(test_tensor)
                relu_times.append(time.time() - start_time)

    avg_relu_time = np.mean(relu_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "ActivationOperator",
    metric = "average_processing_time",
    value = avg_relu_time,
    unit = "seconds",
    metadata = {"input_size": test_input.shape, "output_size": output.data.shape}
    #         ))

    #         return results

    #     async def benchmark_audio_operators(self) -List[BenchmarkResult]):
    #         """Benchmark audio tensor operations"""
            logger.info("Benchmarking audio tensor operators")

    results = []

    #         # Create test data
    test_input = np.random.rand(4096).astype(np.float32)
    test_tensor = MockMediaFrame(test_input)

    #         # Benchmark FFT
    fft = FFTOperator(sample_rate=44100, channels=1, frame_size=4096, use_gpu=False)

    fft_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    output = fft.forward(test_tensor)
                fft_times.append(time.time() - start_time)

    avg_fft_time = np.mean(fft_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "FFTOperator",
    metric = "average_processing_time",
    value = avg_fft_time,
    unit = "seconds",
    metadata = {"input_size": test_input.shape, "output_size": output.data.shape}
    #         ))

    #         # Benchmark spectrogram
    spectrogram = SpectrogramOperator(
    sample_rate = 44100,
    channels = 1,
    frame_size = 2048,
    hop_size = 512,
    use_gpu = False
    #         )

    spec_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    output = spectrogram.forward(test_tensor)
                spec_times.append(time.time() - start_time)

    avg_spec_time = np.mean(spec_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "SpectrogramOperator",
    metric = "average_processing_time",
    value = avg_spec_time,
    unit = "seconds",
    metadata = {"input_size": test_input.shape, "output_size": output.data.shape}
    #         ))

    #         # Benchmark MFCC
    mfcc = MFCCOperator(
    sample_rate = 44100,
    channels = 1,
    n_mfcc = 13,
    use_gpu = False
    #         )

    mfcc_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    output = mfcc.forward(test_tensor)
                mfcc_times.append(time.time() - start_time)

    avg_mfcc_time = np.mean(mfcc_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "MFCCOperator",
    metric = "average_processing_time",
    value = avg_mfcc_time,
    unit = "seconds",
    metadata = {"input_size": test_input.shape, "output_size": output.data.shape}
    #         ))

    #         return results

    #     async def benchmark_stream_optimization(self) -List[BenchmarkResult]):
    #         """Benchmark stream optimization"""
            logger.info("Benchmarking stream optimization")

    results = []

    #         # Create mock stream
    stream = VideoFileStream("dummy.mp4", backend="mock")

    #         # Benchmark dynamic batcher
    batcher = DynamicBatcher(
    target_latency = 0.016,
    target_throughput = 60.0,
    max_batch_size = 8,
    adaptive_mode = True
    #         )

    batcher_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    optimized_stream = batcher.optimize_stream(stream)

    #             # Process frames without async with for mock
    frame_count = 0
    #             async for frame in optimized_stream:
    frame_count + = 1
    #                 if frame_count >= 50:  # Limit frames
    #                     break

                batcher_times.append(time.time() - start_time)

    avg_batcher_time = np.mean(batcher_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "DynamicBatcher",
    metric = "average_processing_time",
    value = avg_batcher_time,
    unit = "seconds",
    metadata = {"frames_processed": 50}
    #         ))

    #         # Benchmark memory management
    manager = AdaptiveMemoryManager(
    target_latency = 0.016,
    ram_threshold = 0.7,
    disk_threshold = 0.9
    #         )

    #         # Create test tensors
    tensors = []
    #         for i in range(100):
    test_tensor = np.random.rand(256, 256, 3).astype(np.float32)
                tensors.append(MockMediaFrame(test_tensor))

    manager_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()

    #             # Store tensors
    locations = []
    #             for t in tensors:
    location = manager.store_tensor(t)
                    locations.append(location)

    #             # Optimize memory
                manager.optimize_memory()

                manager_times.append(time.time() - start_time)

    avg_manager_time = np.mean(manager_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "AdaptiveMemoryManager",
    metric = "average_processing_time",
    value = avg_manager_time,
    unit = "seconds",
    metadata = {"tensors_processed": len(tensors)}
    #         ))

    #         return results

    #     async def benchmark_stream_utils(self) -List[BenchmarkResult]):
    #         """Benchmark stream utility functions"""
            logger.info("Benchmarking stream utility functions")

    results = []

    #         # Benchmark optimization recommendations
    mock_stream = VideoFileStream("dummy.mp4", backend="mock")

    rec_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    recommendations = StreamOptimizationUtils.get_optimization_recommendations(mock_stream)
                rec_times.append(time.time() - start_time)

    avg_rec_time = np.mean(rec_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "StreamOptimizationUtils",
    metric = "average_recommendation_time",
    value = avg_rec_time,
    unit = "seconds",
    metadata = {"recommendations_count": len(recommendations)}
    #         ))

    #         # Benchmark optimization benchmarking
    benchmark_times = []
    #         for i in range(self.warmup + self.iterations):
    start_time = time.time()
    #             # Mock benchmark without async with
    benchmark = {
    #                 "avg_fps": 30.0,
    #                 "avg_processing_time": 0.033
    #             }
                benchmark_times.append(time.time() - start_time)

    avg_benchmark_time = np.mean(benchmark_times[self.warmup:])
            results.append(BenchmarkResult(
    name = "StreamOptimizationUtils",
    metric = "average_benchmark_time",
    value = avg_benchmark_time,
    unit = "seconds",
    metadata = {"benchmark_duration": 1.0}
    #         ))

    #         return results

    #     async def run_all_benchmarks(self) -List[BenchmarkResult]):
    #         """Run all benchmarks"""
            logger.info("Starting all benchmarks")

    #         # Video I/O benchmarks
    video_file_results = await self.benchmark_video_io("file", "test_video.mp4")
    video_camera_results = await self.benchmark_video_io("camera", "camera://0")

    #         # Audio I/O benchmarks
    audio_results = await self.benchmark_audio_io("microphone://default")

    #         # Video operator benchmarks
    video_operator_results = await self.benchmark_video_operators()

    #         # Audio operator benchmarks
    audio_operator_results = await self.benchmark_audio_operators()

    #         # Stream optimization benchmarks
    stream_optimization_results = await self.benchmark_stream_optimization()

    #         # Stream utility benchmarks
    stream_utility_results = await self.benchmark_stream_utils()

    #         # Combine all results
    all_results = (
    #             video_file_results +
    #             video_camera_results +
    #             audio_results +
    #             video_operator_results +
    #             audio_operator_results +
    #             stream_optimization_results +
    #             stream_utility_results
    #         )

    #         # Add system metrics
    system_stats = self.system_monitor.get_stats_since_start()
            all_results.append(BenchmarkResult(
    name = "System",
    metric = "cpu_percent_delta",
    value = system_stats["cpu_percent_delta"],
    unit = "percent"
    #         ))

            all_results.append(BenchmarkResult(
    name = "System",
    metric = "memory_percent_delta",
    value = system_stats["memory_percent_delta"],
    unit = "percent"
    #         ))

            all_results.append(BenchmarkResult(
    name = "System",
    metric = "memory_rss_delta",
    value = system_stats["memory_rss_delta"],
    unit = "MB"
    #         ))

    #         return all_results

    #     def save_results(self, results: List[BenchmarkResult], output_file: str):
    #         """Save benchmark results to file"""
    output_dir = Path(output_file).parent
    output_dir.mkdir(parents = True, exist_ok=True)

    #         # Save as JSON
    #         with open(output_file, 'w') as f:
    #             json.dump([r.to_dict() for r in results], f, indent=2)

            logger.info(f"Benchmark results saved to {output_file}")

    #     def generate_report(self, results: List[BenchmarkResult], output_dir: str):
    #         """Generate benchmark report with visualizations"""
    output_path = Path(output_dir)
    output_path.mkdir(parents = True, exist_ok=True)

    #         # Group results by metric
    metric_groups = {}
    #         for result in results:
    #             if result.metric not in metric_groups:
    metric_groups[result.metric] = []
                metric_groups[result.metric].append(result)

    #         # Generate plots
    #         for metric, metric_results in metric_groups.items():
    #             # Create plot
    plt.figure(figsize = (10, 6))

    #             # Extract data
    #             names = [r.name for r in metric_results]
    #             values = [r.value for r in metric_results]

    #             # Create bar plot
    bars = plt.bar(names, values)

    #             # Add value labels on bars
    #             for bar in bars:
    height = bar.get_height()
                    plt.text(bar.get_x() + bar.get_width()/2., height,
    #                         f'{height:.4f}',
    ha = 'center', va='bottom')

    plt.xticks(rotation = 45, ha='right')
                plt.ylabel(f"{metric} ({metric_results[0].unit})")
                plt.title(f"Benchmark Results: {metric}")
                plt.tight_layout()

    #             # Save plot
    plot_file = output_path / f"{metric}_benchmark.png"
                plt.savefig(plot_file)
                plt.close()

                logger.info(f"Saved plot: {plot_file}")

    #         # Generate summary report
    summary_file = output_path / "benchmark_summary.txt"
    #         with open(summary_file, 'w') as f:
                f.write("NoodleVision Benchmark Report\n")
    f.write(" = " * 50 + "\n\n")

    #             # System info
                f.write("System Information:\n")
                f.write(f"CPU Cores: {psutil.cpu_count()}\n")
                f.write(f"Memory: {psutil.virtual_memory().total / (1024**3):.1f} GB\n")
                f.write(f"Python Version: {sys.version}\n\n")

    #             # Benchmark summary
                f.write("Benchmark Results:\n")
                f.write("-" * 30 + "\n")

    #             for metric, metric_results in metric_groups.items():
    #                 avg_value = np.mean([r.value for r in metric_results])
                    f.write(f"\n{metric}:\n")
                    f.write(f"  Average: {avg_value:.4f} {metric_results[0].unit}\n")
    #                 f.write(f"  Min: {min(r.value for r in metric_results):.4f} {metric_results[0].unit}\n")
    #                 f.write(f"  Max: {max(r.value for r in metric_results):.4f} {metric_results[0].unit}\n")

    #             # Performance analysis
                f.write("\nPerformance Analysis:\n")
                f.write("-" * 30 + "\n")

    #             # Analyze video performance
    #             video_fps = [r.value for r in results if r.metric == "fps" and "VideoIO" in r.name]
    #             if video_fps:
                    f.write(f"\nVideo I/O Performance:\n")
                    f.write(f"  Average FPS: {np.mean(video_fps):.2f}\n")
                    f.write(f"  Min FPS: {min(video_fps):.2f}\n")
                    f.write(f"  Max FPS: {max(video_fps):.2f}\n")

    #             # Analyze operator performance
    #             operator_times = [r.value for r in results if "Operator" in r.name and r.metric == "average_processing_time"]
    #             if operator_times:
                    f.write(f"\nOperator Performance:\n")
                    f.write(f"  Average processing time: {np.mean(operator_times)*1000:.2f} ms\n")
                    f.write(f"  Fastest operator: {min(operator_times)*1000:.2f} ms\n")
                    f.write(f"  Slowest operator: {max(operator_times)*1000:.2f} ms\n")

    #             # Analyze system impact
    #             system_metrics = [r for r in results if r.name == "System"]
    #             if system_metrics:
                    f.write(f"\nSystem Impact:\n")
    #                 for metric in ["cpu_percent_delta", "memory_percent_delta", "memory_rss_delta"]:
    #                     r_metric = next((r for r in system_metrics if r.metric == metric), None)
    #                     if r_metric:
                            f.write(f"  {metric}: {r_metric.value:.2f} {r_metric.unit}\n")
    #                     else:
                            f.write(f"  {metric}: N/A\n")

            logger.info(f"Generated benchmark report: {summary_file}")

# async def main():
#     """Main benchmark runner"""
parser = argparse.ArgumentParser(description="NoodleVision Benchmark Suite")
parser.add_argument("--iterations", type = int, default=10, help="Number of benchmark iterations")
parser.add_argument("--warmup", type = int, default=3, help="Number of warmup iterations")
parser.add_argument("--output", type = str, default="benchmark_results.json", help="Output JSON file")
parser.add_argument("--report-dir", type = str, default="benchmark_report", help="Report directory")
parser.add_argument("--verbose", action = "store_true", help="Enable verbose logging")

args = parser.parse_args()

#     if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

#     # Create benchmark runner
runner = BenchmarkRunner(iterations=args.iterations, warmup=args.warmup)

#     # Run benchmarks
results = await runner.run_all_benchmarks()

#     # Save results
    runner.save_results(results, args.output)

#     # Generate report
    runner.generate_report(results, args.report_dir)

    logger.info("Benchmarking completed successfully")

if __name__ == "__main__"
        asyncio.run(main())
