"""
Vision::Stream - stream.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Streaming pipeline for NoodleVision

This module provides streaming capabilities for real-time media processing
with NBC tensor operators and optimization.
"""

import asyncio
import logging
import numpy as np
from typing import AsyncIterator, List, Dict, Any, Optional, Callable
from dataclasses import dataclass
from enum import Enum
from concurrent.futures import ThreadPoolExecutor
import queue
import threading

from .io import MediaStream, MediaFrame
from .ops_video import NBCTensorOperator
from .ops_audio import AudioOperator

logger = logging.getLogger(__name__)


class SchedulingPolicy(Enum):
    """Scheduling policies for streaming pipelines"""
    REALTIME = "realtime"  # Low latency, minimal buffering
    BATCHED = "batched"    # High throughput, buffering allowed
    ADAPTIVE = "adaptive"  # Dynamically switch based on conditions


class OptimizationStrategy(Enum):
    """Optimization strategies for streaming"""
    SPEED = "speed"        # Prioritize processing speed
    MEMORY = "memory"      # Prioritize memory efficiency
    QUALITY = "quality"    # Prioritize output quality


@dataclass
class StreamStage:
    """Represents a stage in the streaming pipeline"""
    name: str
    operator: Callable[[np.ndarray], np.ndarray]
    buffer_size: int = 1
    parallel_workers: int = 1
    
    def __post_init__(self):
        """Validate stage configuration"""
        if self.buffer_size <= 0:
            raise ValueError("Buffer size must be positive")
        if self.parallel_workers <= 0:
            raise ValueError("Number of workers must be positive")


class StreamOptimizer:
    """Optimizes streaming pipeline performance"""
    
    def __init__(self):
        """Initialize stream optimizer"""
        self.metrics = {
            "throughput": 0.0,
            "latency": 0.0,
            "memory_usage": 0.0,
            "cpu_usage": 0.0
        }
        self._monitor_task = None
        self._stop_monitoring = False
    
    def start_monitoring(self, pipeline):
        """Start performance monitoring"""
        self._stop_monitoring = False
        self._monitor_task = asyncio.create_task(self._monitor(pipeline))
    
    def stop_monitoring(self):
        """Stop performance monitoring"""
        self._stop_monitoring = True
        if self._monitor_task:
            self._monitor_task.cancel()
    
    async def _monitor(self, pipeline):
        """Monitor pipeline performance"""
        while not self._stop_monitoring:
            # Update metrics
            self.metrics.update(pipeline.get_metrics())
            
            # Log metrics
            logger.info(f"Pipeline metrics: {self.metrics}")
            
            # Wait before next check
            await asyncio.sleep(1.0)


class MediaStreamPipeline:
    """Streaming pipeline for media processing"""
    
    def __init__(self, source: MediaStream, max_buffer_size: int = 10):
        """
        Initialize streaming pipeline
        
        Args:
            source: Media source stream
            max_buffer_size: Maximum buffer size for frames
        """
        self.source = source
        self.stages: List[StreamStage] = []
        self.max_buffer_size = max_buffer_size
        self.is_running = False
        
        # Performance optimization
        self.optimizer = StreamOptimizer()
        self.scheduling_policy = SchedulingPolicy.REALTIME
        self.optimization_strategy = OptimizationStrategy.SPEED
        
        # Threading
        self._executor = ThreadPoolExecutor(max_workers=4)
        self._frame_queue = queue.Queue(maxsize=max_buffer_size)
        self._result_queue = queue.Queue(maxsize=max_buffer_size)
        
        # Statistics
        self.stats = {
            "frames_processed": 0,
            "frames_dropped": 0,
            "total_processing_time": 0.0,
            "average_latency": 0.0
        }
        
        # Callbacks
        self._frame_callback: Optional[Callable[[MediaFrame], None]] = None
        self._error_callback: Optional[Callable[[Exception], None]] = None
    
    def add_stage(self, stage: StreamStage):
        """Add a processing stage to the pipeline"""
        self.stages.append(stage)
        logger.info(f"Added stage: {stage.name}")
    
    def set_frame_callback(self, callback: Callable[[MediaFrame], None]):
        """Set callback for processed frames"""
        self._frame_callback = callback
    
    def set_error_callback(self, callback: Callable[[Exception], None]):
        """Set callback for errors"""
        self._error_callback = callback
    
    def set_scheduling_policy(self, policy: SchedulingPolicy):
        """Set scheduling policy"""
        self.scheduling_policy = policy
        logger.info(f"Set scheduling policy to: {policy.value}")
    
    def set_optimization_strategy(self, strategy: OptimizationStrategy):
        """Set optimization strategy"""
        self.optimization_strategy = strategy
        logger.info(f"Set optimization strategy to: {strategy.value}")
    
    async def start(self):
        """Start the streaming pipeline"""
        if self.is_running:
            logger.warning("Pipeline is already running")
            return
        
        self.is_running = True
        logger.info("Starting media streaming pipeline")
        
        # Start monitoring
        self.optimizer.start_monitoring(self)
        
        # Start pipeline tasks
        tasks = [
            asyncio.create_task(self._source_reader()),
            asyncio.create_task(self._frame_processor()),
            asyncio.create_task(self._result_writer())
        ]
        
        try:
            await asyncio.gather(*tasks)
        except asyncio.CancelledError:
            logger.info("Pipeline cancelled")
        finally:
            self.stop()
    
    async def stop(self):
        """Stop the streaming pipeline"""
        if not self.is_running:
            return
        
        self.is_running = False
        logger.info("Stopping media streaming pipeline")
        
        # Stop monitoring
        self.optimizer.stop_monitoring()
        
        # Clear queues
        while not self._frame_queue.empty():
            self._frame_queue.get()
            self._frame_queue.task_done()
        
        while not self._result_queue.empty():
            self._result_queue.get()
            self._result_queue.task_done()
        
        # Shutdown executor
        self._executor.shutdown(wait=True)
    
    async def _source_reader(self):
        """Read frames from source"""
        try:
            async for frame in self.source.stream_frames():
                if not self.is_running:
                    break
                
                # Put frame in queue
                try:
                    self._frame_queue.put_nowait(frame)
                except queue.Full:
                    logger.warning("Frame queue full, dropping frame")
                    self.stats["frames_dropped"] += 1
                    
        except Exception as e:
            logger.error(f"Error reading from source: {e}")
            if self._error_callback:
                await self._error_callback(e)
    
    async def _frame_processor(self):
        """Process frames through pipeline stages"""
        while self.is_running:
            try:
                # Get frame from queue
                frame = self._frame_queue.get(timeout=1.0)
                
                # Process frame through stages
                processed_frame = await self._process_frame(frame)
                
                # Put result in queue
                try:
                    self._result_queue.put_nowait(processed_frame)
                except queue.Full:
                    logger.warning("Result queue full, dropping frame")
                    self.stats["frames_dropped"] += 1
                
                # Update statistics
                self.stats["frames_processed"] += 1
                
                # Mark task as done
                self._frame_queue.task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                logger.error(f"Error processing frame: {e}")
                if self._error_callback:
                    await self._error_callback(e)
    
    async def _process_frame(self, frame: MediaFrame) -> MediaFrame:
        """Process a single frame through all stages"""
        start_time = asyncio.get_event_loop().time()
        
        # Convert to tensor
        tensor = frame.data
        
        # Process through stages
        for stage in self.stages:
            # Process frame
            if asyncio.iscoroutinefunction(stage.operator):
                tensor = await stage.operator(tensor)
            else:
                # Run in executor for CPU-bound operations
                tensor = await asyncio.get_event_loop().run_in_executor(
                    self._executor, stage.operator, tensor
                )
        
        # Create processed frame
        processed_frame = MediaFrame(
            data=tensor,
            timestamp=frame.timestamp,
            stream_type=frame.stream_type,
            metadata={**frame.metadata, "processed": True}
        )
        
        # Update latency
        end_time = asyncio.get_event_loop().time()
        processing_time = end_time - start_time
        self.stats["total_processing_time"] += processing_time
        self.stats["average_latency"] = (
            self.stats["total_processing_time"] / self.stats["frames_processed"]
        )
        
        return processed_frame
    
    async def _result_writer(self):
        """Write processed frames to output"""
        while self.is_running:
            try:
                # Get processed frame
                frame = self._result_queue.get(timeout=1.0)
                
                # Call callback if set
                if self._frame_callback:
                    # Run in executor to avoid blocking
                    await asyncio.get_event_loop().run_in_executor(
                        self._executor, self._frame_callback, frame
                    )
                
                # Mark task as done
                self._result_queue.task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                logger.error(f"Error writing result: {e}")
                if self._error_callback:
                    await self._error_callback(e)
    
    async def execute(self) -> AsyncIterator[MediaFrame]:
        """Execute pipeline and return processed frames"""
        # Start pipeline
        pipeline_task = asyncio.create_task(self.start())
        
        try:
            # Yield processed frames
            while self.is_running:
                # This is a simplified implementation
                # In a real implementation, you would use a proper async queue
                await asyncio.sleep(0.1)
                yield None  # Placeholder
                
        finally:
            # Stop pipeline
            pipeline_task.cancel()
            try:
                await pipeline_task
            except asyncio.CancelledError:
                pass
    
    def get_metrics(self) -> Dict[str, Any]:
        """Get pipeline performance metrics"""
        return {
            **self.stats,
            "scheduling_policy": self.scheduling_policy.value,
            "optimization_strategy": self.optimization_strategy.value,
            "buffer_usage": self._frame_queue.qsize() / self.max_buffer_size,
            "num_stages": len(self.stages)
        }
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get pipeline statistics"""
        return {
            "is_running": self.is_running,
            "frames_processed": self.stats["frames_processed"],
            "frames_dropped": self.stats["frames_dropped"],
            "average_latency": self.stats["average_latency"],
            "total_processing_time": self.stats["total_processing_time"],
            "buffer_size": self.max_buffer_size,
            "current_buffer_usage": self._frame_queue.qsize(),
            "num_stages": len(self.stages)
        }


class BatchProcessor:
    """Batch processor for improved throughput"""
    
    def __init__(self, batch_size: int = 32, max_wait_time: float = 0.1):
        """
        Initialize batch processor
        
        Args:
            batch_size: Maximum batch size
            max_wait_time: Maximum time to wait for batch completion
        """
        self.batch_size = batch_size
        self.max_wait_time = max_wait_time
        self._batch_queue = queue.Queue()
        self._executor = ThreadPoolExecutor(max_workers=2)
    
    async def process_batch(self, frames: List[MediaFrame],
                           operators: List[Callable]) -> List[MediaFrame]:
        """
        Process a batch of frames
        
        Args:
            frames: List of frames to process
            operators: List of operators to apply
            
        Returns:
            List of processed frames
        """
        # Process frames in batch
        processed_frames = []
        
        for frame in frames:
            # Apply operators
            tensor = frame.data
            for op in operators:
                tensor = op(tensor)
            
            # Create processed frame
            processed_frame = MediaFrame(
                data=tensor,
                timestamp=frame.timestamp,
                stream_type=frame.stream_type,
                metadata={**frame.metadata, "batch_processed": True}
            )
            
            processed_frames.append(processed_frame)
        
        return processed_frames
    
    async def process_stream(self, frame_stream: AsyncIterator[MediaFrame],
                            operators: List[Callable]) -> AsyncIterator[MediaFrame]:
        """
        Process frames from stream in batches
        
        Args:
            frame_stream: Input frame stream
            operators: List of operators to apply
            
        Returns:
            Stream of processed frames
        """
        batch = []
        
        async for frame in frame_stream:
            batch.append(frame)
            
            # Process batch when full or timeout reached
            if len(batch) >= self.batch_size:
                processed = await self.process_batch(batch, operators)
                for frame in processed:
                    yield frame
                batch = []
        
        # Process remaining frames
        if batch:
            processed = await self.process_batch(batch, operators)
            for frame in processed:
                yield frame


class AdaptiveBuffer:
    """Adaptive buffer for streaming optimization"""
    
    def __init__(self, initial_size: int = 10):
        """
        Initialize adaptive buffer
        
        Args:
            initial_size: Initial buffer size
        """
        self.buffer = []
        self.max_size = initial_size
        self.min_size = 1
        self.current_size = initial_size
        self.history = []
        
        # Performance tracking
        self.processing_times = []
        self.dropped_frames = 0
    
    def add_frame(self, frame: MediaFrame) -> bool:
        """
        Add frame to buffer
        
        Args:
            frame: Frame to add
            
        Returns:
            True if frame was added, False if buffer is full
        """
        if len(self.buffer) >= self.current_size:
            return False
        
        self.buffer.append(frame)
        return True
    
    def get_frame(self) -> Optional[MediaFrame]:
        """Get frame from buffer"""
        if not self.buffer:
            return None
        
        return self.buffer.pop(0)
    
    def update_performance(self, processing_time: float, frame_dropped: bool):
        """
        Update performance metrics
        
        Args:
            processing_time: Time to process last frame
            frame_dropped: Whether a frame was dropped
        """
        self.processing_times.append(processing_time)
        
        if frame_dropped:
            self.dropped_frames += 1
        
        # Keep only recent history
        if len(self.processing_times) > 100:
            self.processing_times = self.processing_times[-100:]
        
        # Adjust buffer size based on performance
        self._adjust_buffer_size()
    
    def _adjust_buffer_size(self):
        """Adjust buffer size based on performance"""
        if len(self.processing_times) < 10:
            return
        
        avg_processing_time = np.mean(self.processing_times)
        
        # If processing is slow, increase buffer
        if avg_processing_time > 0.1:  # 100ms
            self.current_size = min(self.current_size + 1, self.max_size)
        # If processing is fast and no drops, decrease buffer
        elif avg_processing_time < 0.01 and self.dropped_frames == 0:
            self.current_size = max(self.current_size - 1, self.min_size)
        
        # Reset drops counter
        self.dropped_frames = 0


