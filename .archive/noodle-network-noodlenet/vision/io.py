"""
Vision::Io - io.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Media I/O interfaces for NoodleVision

This module provides abstract interfaces and implementations for handling
video, audio, and sensor streams as NBC tensors.
"""

import asyncio
import logging
import numpy as np
from typing import AsyncIterator, Optional, Dict, Any, Union
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)


class StreamType(Enum):
    """Stream types for media sources"""
    VIDEO = "video"
    AUDIO = "audio"
    SENSOR = "sensor"
    UNKNOWN = "unknown"


@dataclass
class MediaFrame:
    """Represents a single frame in a media stream"""
    data: np.ndarray  # Tensor data
    timestamp: float  # Timestamp in seconds
    stream_type: StreamType
    metadata: Dict[str, Any]  # Additional metadata
    
    def __post_init__(self):
        """Validate frame data"""
        if not isinstance(self.data, np.ndarray):
            raise ValueError("Frame data must be a numpy array")
        
        if self.stream_type not in StreamType:
            raise ValueError(f"Invalid stream type: {self.stream_type}")


class MediaStream(ABC):
    """Abstract base class for media streams"""
    
    def __init__(self, source: str):
        """
        Initialize media stream
        
        Args:
            source: Source URI (e.g., "camera://0", "file://video.mp4")
        """
        self.source = source
        self.stream_type = StreamType.UNKNOWN
        self.is_running = False
        self.frame_count = 0
        self._frame_callback: Optional[callable] = None
        
    @abstractmethod
    async def open(self):
        """Open the media stream"""
        pass
    
    @abstractmethod
    async def close(self):
        """Close the media stream"""
        pass
    
    @abstractmethod
    async def read_frame(self) -> Optional[MediaFrame]:
        """Read a single frame from the stream"""
        pass
    
    async def __aenter__(self):
        """Async context manager entry"""
        await self.open()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        await self.close()
    
    def set_frame_callback(self, callback: callable):
        """Set callback for when a frame is read"""
        self._frame_callback = callback
    
    async def stream_frames(self) -> AsyncIterator[MediaFrame]:
        """Stream frames asynchronously"""
        await self.open()
        
        try:
            while self.is_running:
                frame = await self.read_frame()
                if frame is None:
                    break
                
                self.frame_count += 1
                
                # Call callback if set
                if self._frame_callback:
                    await self._frame_callback(frame)
                
                yield frame
                
                # Small delay to prevent busy waiting
                await asyncio.sleep(0.001)
                
        finally:
            await self.close()
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get stream statistics"""
        return {
            "source": self.source,
            "stream_type": self.stream_type.value,
            "is_running": self.is_running,
            "frame_count": self.frame_count
        }


class CameraStream(MediaStream):
    """Camera stream for real-time video capture"""
    
    def __init__(self, camera_id: str = "0"):
        """
        Initialize camera stream
        
        Args:
            camera_id: Camera device ID or URL
        """
        super().__init__(f"camera://{camera_id}")
        self.stream_type = StreamType.VIDEO
        self.camera_id = camera_id
        self._capture = None
        self._width = 640
        self._height = 480
        self._fps = 30
    
    async def open(self):
        """Open the camera stream"""
        try:
            # Placeholder for actual camera initialization
            # In a real implementation, this would use OpenCV, V4L2, or similar
            logger.info(f"Opening camera stream: {self.camera_id}")
            self.is_running = True
        except Exception as e:
            logger.error(f"Failed to open camera stream: {e}")
            raise
    
    async def close(self):
        """Close the camera stream"""
        try:
            # Placeholder for actual camera cleanup
            if self._capture:
                self._capture.release()
                self._capture = None
            logger.info(f"Closed camera stream: {self.camera_id}")
            self.is_running = False
        except Exception as e:
            logger.error(f"Failed to close camera stream: {e}")
            raise
    
    async def read_frame(self) -> Optional[MediaFrame]:
        """Read a frame from the camera"""
        if not self.is_running:
            return None
        
        try:
            # Placeholder for actual frame capture
            # In a real implementation, this would capture from the camera
            # Simulate a frame with random data
            frame_data = np.random.randint(0, 255, (self._height, self._width, 3), dtype=np.uint8)
            
            timestamp = asyncio.get_event_loop().time()
            metadata = {
                "camera_id": self.camera_id,
                "width": self._width,
                "height": self._height,
                "fps": self._fps
            }
            
            return MediaFrame(
                data=frame_data,
                timestamp=timestamp,
                stream_type=self.stream_type,
                metadata=metadata
            )
            
        except Exception as e:
            logger.error(f"Failed to read frame from camera: {e}")
            return None
    
    def set_resolution(self, width: int, height: int):
        """Set camera resolution"""
        self._width = width
        self._height = height
        logger.info(f"Set camera resolution to {width}x{height}")
    
    def set_fps(self, fps: int):
        """Set camera FPS"""
        self._fps = fps
        logger.info(f"Set camera FPS to {fps}")


