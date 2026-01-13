"""
Vision::Ops Sensors - ops_sensors.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Sensor operators for NoodleVision

This module provides sensor data processing operators for various sensor types
implemented as NBC tensor operations.
"""

import logging
import numpy as np
from typing import Optional, Tuple, Dict, Any, List, Union
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
import asyncio
from collections import deque

logger = logging.getLogger(__name__)


class SensorType(Enum):
    """Types of supported sensors"""
    IMU = "imu"           # Inertial Measurement Unit
    GPS = "gps"           # Global Positioning System
    LIDAR = "lidar"       # Light Detection and Ranging
    CAMERA = "camera"     # Camera sensor
    THERMAL = "thermal"   # Thermal camera
    RADAR = "radar"       # Radar sensor
    ULTRASOUND = "ultrasound"  # Ultrasonic sensor
    BAROMETER = "barometer"   # Barometric pressure
    HYGROMETER = "hygrometer"  # Humidity sensor
    ACCELEROMETER = "accelerometer"  # Accelerometer
    GYROSCOPE = "gyroscope"   # Gyroscope
    MAGNETOMETER = "magnetometer"  # Magnetometer


class SensorDataFormat(Enum):
    """Data formats for sensor readings"""
    RAW = "raw"           # Raw sensor readings
    PROCESSED = "processed"  # Processed/filtered data
    CALIBRATED = "calibrated"  # Calibrated data
    NORMALIZED = "normalized"  # Normalized data


@dataclass
class SensorReading:
    """Represents a single sensor reading"""
    timestamp: float
    sensor_id: str
    sensor_type: SensorType
    data: np.ndarray
    format: SensorDataFormat
    metadata: Dict[str, Any]
    
    def __post_init__(self):
        """Validate sensor reading"""
        if not isinstance(self.data, np.ndarray):
            raise ValueError("Sensor data must be a numpy array")
        
        if self.sensor_type not in SensorType:
            raise ValueError(f"Invalid sensor type: {self.sensor_type}")


@dataclass
class SensorConfig:
    """Configuration for sensor processing"""
    # Processing settings
    sample_rate: float = 100.0
    filter_window: int = 5
    smoothing_factor: float = 0.1
    
    # Calibration settings
    apply_calibration: bool = True
    calibration_matrix: Optional[np.ndarray] = None
    
    # Normalization settings
    normalize_data: bool = True
    min_value: float = 0.0
    max_value: float = 1.0
    
    # Buffer settings
    buffer_size: int = 1000
    history_window: int = 100


class SensorOperator(ABC):
    """Base class for sensor operators"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize sensor operator
        
        Args:
            config: Sensor configuration
        """
        self.config = config or SensorConfig()
        self.buffer = deque(maxlen=self.config.buffer_size)
        self.stats = {
            "total_readings": 0,
            "processed_readings": 0,
            "filtered_readings": 0,
            "calibration_errors": 0
        }
    
    @abstractmethod
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process sensor reading
        
        Args:
            reading: Input sensor reading
            
        Returns:
            Processed sensor reading
        """
        pass
    
    def __call__(self, reading: SensorReading) -> SensorReading:
        """
        Operator call interface
        
        Args:
            reading: Input sensor reading
            
        Returns:
            Processed sensor reading
        """
        # Add to buffer
        self.buffer.append(reading)
        
        # Update statistics
        self.stats["total_readings"] += 1
        
        # Process reading
        result = self.process(reading)
        
        # Update statistics
        self.stats["processed_readings"] += 1
        
        return result
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get operator statistics"""
        return self.stats.copy()
    
    def get_buffer_data(self) -> List[SensorReading]:
        """Get buffer data"""
        return list(self.buffer)


class IMUSensorOperator(SensorOperator):
    """IMU (Inertial Measurement Unit) sensor operator"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize IMU sensor operator
        
        Args:
            config: Sensor configuration
        """
        super().__init__(config)
        
        # Initialize calibration matrices
        self.accel_calib = self.config.calibration_matrix or np.eye(3)
        self.gyro_calib = self.config.calibration_matrix or np.eye(3)
        self.mag_calib = self.config.calibration_matrix or np.eye(3)
    
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process IMU sensor reading
        
        Args:
            reading: Input IMU reading
            
        Returns:
            Processed IMU reading
        """
        if reading.sensor_type not in [SensorType.IMU, SensorType.ACCELEROMETER,
                                     SensorType.GYROSCOPE, SensorType.MAGNETOMETER]:
            raise ValueError(f"Invalid sensor type for IMU operator: {reading.sensor_type}")
        
        data = reading.data.copy()
        
        # Apply calibration if enabled
        if self.config.apply_calibration:
            if reading.sensor_type == SensorType.ACCELEROMETER:
                data = self._apply_calibration(data, self.accel_calib)
            elif reading.sensor_type == SensorType.GYROSCOPE:
                data = self._apply_calibration(data, self.gyro_calib)
            elif reading.sensor_type == SensorType.MAGNETOMETER:
                data = self._apply_calibration(data, self.mag_calib)
        
        # Apply smoothing
        if len(self.buffer) > 1:
            data = self._apply_smoothing(data)
        
        # Normalize if enabled
        if self.config.normalize_data:
            data = self._normalize_data(data)
        
        return SensorReading(
            timestamp=reading.timestamp,
            sensor_id=reading.sensor_id,
            sensor_type=reading.sensor_type,
            data=data,
            format=SensorDataFormat.PROCESSED,
            metadata={**reading.metadata, "processed": True}
        )
    
    def _apply_calibration(self, data: np.ndarray, matrix: np.ndarray) -> np.ndarray:
        """Apply calibration matrix to sensor data"""
        try:
            if data.shape[0] >= matrix.shape[0]:
                calibrated = np.dot(data[:matrix.shape[0]], matrix.T)
                self.stats["calibration_errors"] += 0
            else:
                calibrated = data
                self.stats["calibration_errors"] += 1
        except Exception as e:
            logger.warning(f"Calibration failed: {e}")
            calibrated = data
            self.stats["calibration_errors"] += 1
        
        return calibrated
    
    def _apply_smoothing(self, data: np.ndarray) -> np.ndarray:
        """Apply smoothing filter to sensor data"""
        if len(self.buffer) < self.config.filter_window:
            return data
        
        # Get recent readings
        recent_data = []
        for reading in list(self.buffer)[-self.config.filter_window:]:
            if reading.sensor_type == data.shape[0]:
                recent_data.append(reading.data)
        
        if len(recent_data) >= 2:
            # Apply exponential moving average
            smoothed = data * self.config.smoothing_factor
            smoothed += np.mean(recent_data, axis=0) * (1 - self.config.smoothing_factor)
            return smoothed
        
        return data
    
    def _normalize_data(self, data: np.ndarray) -> np.ndarray:
        """Normalize sensor data"""
        min_val = self.config.min_value
        max_val = self.config.max_value
        
        # Handle division by zero
        if max_val == min_val:
            return data
        
        normalized = (data - min_val) / (max_val - min_val)
        return np.clip(normalized, min_val, max_val)


class GPSSensorOperator(SensorOperator):
    """GPS sensor operator"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize GPS sensor operator
        
        Args:
            config: Sensor configuration
        """
        super().__init__(config)
        
        # Position history for smoothing
        self.position_history = deque(maxlen=self.config.history_window)
        self.velocity_history = deque(maxlen=self.config.history_window)
    
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process GPS sensor reading
        
        Args:
            reading: Input GPS reading
            
        Returns:
            Processed GPS reading
        """
        if reading.sensor_type != SensorType.GPS:
            raise ValueError(f"Invalid sensor type for GPS operator: {reading.sensor_type}")
        
        data = reading.data.copy()
        
        # Extract position data (assuming [latitude, longitude, altitude])
        if data.shape[0] >= 3:
            position = data[:3]
            velocity = data[3:] if data.shape[0] > 3 else np.zeros(3)
            
            # Update history
            self.position_history.append(position)
            self.velocity_history.append(velocity)
            
            # Apply smoothing to position
            if len(self.position_history) > 1:
                position = self._smooth_position(position)
            
            # Calculate velocity if not available
            if len(self.velocity_history) > 1 and np.all(velocity == 0):
                velocity = self._calculate_velocity()
            
            # Combine data
            data = np.concatenate([position, velocity])
        
        # Apply calibration if enabled
        if self.config.apply_calibration:
            data = self._apply_gps_calibration(data)
        
        return SensorReading(
            timestamp=reading.timestamp,
            sensor_id=reading.sensor_id,
            sensor_type=reading.sensor_type,
            data=data,
            format=SensorDataFormat.PROCESSED,
            metadata={**reading.metadata, "processed": True}
        )
    
    def _smooth_position(self, position: np.ndarray) -> np.ndarray:
        """Apply smoothing to GPS position"""
        # Simple moving average
        recent_positions = list(self.position_history)
        recent_positions.append(position)
        
        smoothed = np.mean(recent_positions, axis=0)
        
        # Apply exponential smoothing
        smoothed = position * self.config.smoothing_factor
        smoothed += np.mean(recent_positions[:-1], axis=0) * (1 - self.config.smoothing_factor)
        
        return smoothed
    
    def _calculate_velocity(self) -> np.ndarray:
        """Calculate velocity from position history"""
        if len(self.position_history) < 2:
            return np.zeros(3)
        
        # Calculate velocity as position difference over time
        positions = np.array(list(self.position_history))
        time_diff = 1.0 / self.config.sample_rate
        
        velocity = np.diff(positions, axis=0) / time_diff
        return np.mean(velocity, axis=0)
    
    def _apply_gps_calibration(self, data: np.ndarray) -> np.ndarray:
        """Apply GPS calibration (e.g., offset correction)"""
        # Simple offset correction (in real implementation, this would be more complex)
        if self.config.calibration_matrix is not None:
            data = np.dot(data, self.config.calibration_matrix.T)
        
        return data


class LIDARSensorOperator(SensorOperator):
    """LIDAR sensor operator"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize LIDAR sensor operator
        
        Args:
            config: Sensor configuration
        """
        super().__init__(config)
        
        # Point cloud processing
        self.point_clouds = deque(maxlen=self.config.history_window)
    
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process LIDAR sensor reading
        
        Args:
            reading: Input LIDAR reading
            
        Returns:
            Processed LIDAR reading
        """
        if reading.sensor_type != SensorType.LIDAR:
            raise ValueError(f"Invalid sensor type for LIDAR operator: {reading.sensor_type}")
        
        data = reading.data.copy()
        
        # Store point cloud
        self.point_clouds.append(data)
        
        # Apply filtering
        if len(self.point_clouds) > 1:
            data = self._apply_filtering(data)
        
        # Apply clustering
        data = self._apply_clustering(data)
        
        # Downsample if needed
        if data.shape[0] > 10000:
            data = self._downsample(data)
        
        return SensorReading(
            timestamp=reading.timestamp,
            sensor_id=reading.sensor_id,
            sensor_type=reading.sensor_type,
            data=data,
            format=SensorDataFormat.PROCESSED,
            metadata={**reading.metadata, "processed": True}
        )
    
    def _apply_filtering(self, points: np.ndarray) -> np.ndarray:
        """Apply filtering to point cloud"""
        # Remove outliers (simple statistical filter)
        if len(self.point_clouds) < 3:
            return points
        
        # Calculate median distance
        distances = np.linalg.norm(points, axis=1)
        median_dist = np.median(distances)
        
        # Remove points too far from median
        threshold = median_dist * 2.0
        mask = distances < threshold
        
        return points[mask]
    
    def _apply_clustering(self, points: np.ndarray) -> np.ndarray:
        """Apply clustering to point cloud"""
        # Simple clustering based on proximity
        if len(points) < 2:
            return points
        
        # Calculate distances between points
        from scipy.spatial.distance import pdist, squareform
        distances = squareform(pdist(points))
        
        # Threshold for clustering
        threshold = 0.5  # meters
        clusters = []
        
        # Simple clustering algorithm
        visited = set()
        for i in range(len(points)):
            if i in visited:
                continue
            
            cluster = [i]
            stack = [i]
            visited.add(i)
            
            while stack:
                current = stack.pop()
                neighbors = np.where(distances[current] < threshold)[0]
                
                for neighbor in neighbors:
                    if neighbor not in visited:
                        cluster.append(neighbor)
                        stack.append(neighbor)
                        visited.add(neighbor)
            
            clusters.append(cluster)
        
        # Keep largest cluster
        if clusters:
            largest_cluster = max(clusters, key=len)
            return points[largest_cluster]
        
        return points
    
    def _downsample(self, points: np.ndarray) -> np.ndarray:
        """Downsample point cloud"""
        # Random sampling for now (in real implementation, use voxel grid)
        indices = np.random.choice(len(points), 10000, replace=False)
        return points[indices]


class CameraSensorOperator(SensorOperator):
    """Camera sensor operator"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize camera sensor operator
        
        Args:
            config: Sensor configuration
        """
        super().__init__(config)
        
        # Image processing
        self.frame_history = deque(maxlen=self.config.history_window)
    
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process camera sensor reading
        
        Args:
            reading: Input camera reading
            
        Returns:
            Processed camera reading
        """
        if reading.sensor_type not in [SensorType.CAMERA, SensorType.THERMAL]:
            raise ValueError(f"Invalid sensor type for camera operator: {reading.sensor_type}")
        
        data = reading.data.copy()
        
        # Store frame
        self.frame_history.append(data)
        
        # Apply preprocessing
        data = self._preprocess_image(data)
        
        # Apply computer vision operations
        data = self._apply_cv_operations(data)
        
        return SensorReading(
            timestamp=reading.timestamp,
            sensor_id=reading.sensor_id,
            sensor_type=reading.sensor_type,
            data=data,
            format=SensorDataFormat.PROCESSED,
            metadata={**reading.metadata, "processed": True}
        )
    
    def _preprocess_image(self, image: np.ndarray) -> np.ndarray:
        """Apply preprocessing to image"""
        # Normalize pixel values
        if image.dtype == np.uint8:
            image = image.astype(np.float32) / 255.0
        
        # Apply histogram equalization for thermal images
        if len(image.shape) == 2 and image.dtype == np.float32:
            image = self._histogram_equalization(image)
        
        # Apply Gaussian blur for noise reduction
        if len(image.shape) == 2:
            from scipy.ndimage import gaussian_filter
            image = gaussian_filter(image, sigma=1.0)
        
        return image
    
    def _histogram_equalization(self, image: np.ndarray) -> np.ndarray:
        """Apply histogram equalization to image"""
        # Calculate histogram
        hist, bins = np.histogram(image.flatten(), 256, [0, 1])
        
        # Calculate cumulative distribution
        cdf = hist.cumsum()
        cdf_normalized = cdf * hist.max() / cdf.max()
        
        # Apply equalization
        equalized = np.interp(image.flatten(), bins[:-1], cdf_normalized)
        return equalized.reshape(image.shape)
    
    def _apply_cv_operations(self, image: np.ndarray) -> np.ndarray:
        """Apply computer vision operations"""
        # Edge detection
        if len(image.shape) == 2:
            from scipy.ndimage import sobel
            edges = sobel(image)
            return edges
        
        # Color analysis for color images
        if len(image.shape) == 3:
            # Calculate color statistics
            mean_color = np.mean(image, axis=(0, 1))
            std_color = np.std(image, axis=(0, 1))
            
            # Create analysis overlay
            overlay = np.zeros_like(image)
            overlay[:, :] = mean_color
            
            # Blend original with overlay
            result = image * 0.7 + overlay * 0.3
            
            return result
        
        return image


class SensorFusionOperator(SensorOperator):
    """Sensor fusion operator for combining multiple sensors"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize sensor fusion operator
        
        Args:
            config: Sensor configuration
        """
        super().__init__(config)
        
        # Sensor data storage
        self.sensor_data = {}
        
        # Kalman filter for fusion
        self.kalman_filter = None
    
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process sensor reading with fusion
        
        Args:
            reading: Input sensor reading
            
        Returns:
            Fused sensor reading
        """
        # Store sensor data
        if reading.sensor_id not in self.sensor_data:
            self.sensor_data[reading.sensor_id] = deque(maxlen=self.config.history_window)
        
        self.sensor_data[reading.sensor_id].append(reading)
        
        # Perform fusion
        fused_data = self._fuse_sensors(reading)
        
        return SensorReading(
            timestamp=reading.timestamp,
            sensor_id="fused",
            sensor_type=reading.sensor_type,
            data=fused_data,
            format=SensorDataFormat.PROCESSED,
            metadata={**reading.metadata, "fused": True}
        )
    
    def _fuse_sensors(self, reading: SensorReading) -> np.ndarray:
        """Fuse data from multiple sensors"""
        # Simple fusion based on sensor types
        fused_data = reading.data.copy()
        
        # IMU + GPS fusion
        if reading.sensor_type == SensorType.GPS:
            if "imu" in self.sensor_data:
                # Get latest IMU data
                imu_readings = list(self.sensor_data["imu"])
                if imu_readings:
                    imu_data = imu_readings[-1].data
                    
                    # Simple complementary filter
                    alpha = 0.98
                    fused_data[:3] = alpha * fused_data[:3] + (1 - alpha) * imu_data[:3]
        
        # LIDAR + Camera fusion
        elif reading.sensor_type == SensorType.LIDAR:
            if "camera" in self.sensor_data:
                # Get latest camera data
                camera_readings = list(self.sensor_data["camera"])
                if camera_readings:
                    camera_data = camera_readings[-1].data
                    
                    # Simple depth estimation from camera
                    if len(camera_data.shape) == 2:
                        # Convert depth to 3D points
                        height, width = camera_data.shape
                        y, x = np.mgrid[0:height, 0:width]
                        
                        # Simple depth to 3D conversion
                        points = np.column_stack([x, y, camera_data.flatten()])
                        
                        # Combine with LIDAR points
                        fused_data = np.vstack([fused_data, points])
        
        return fused_data


class SensorAnomalyDetector(SensorOperator):
    """Anomaly detection for sensor data"""
    
    def __init__(self, config: Optional[SensorConfig] = None):
        """
        Initialize anomaly detector
        
        Args:
            config: Sensor configuration
        """
        super().__init__(config)
        
        # Anomaly detection parameters
        self.z_score_threshold = 3.0
        self.mahalanobis_threshold = 5.0
        
        # Statistics tracking
        self.mean_values = {}
        self.std_values = {}
        self.covariance = None
    
    def process(self, reading: SensorReading) -> SensorReading:
        """
        Process sensor reading with anomaly detection
        
        Args:
            reading: Input sensor reading
            
        Returns:
            Processed sensor reading with anomaly flag
        """
        data = reading.data.copy()
        
        # Update statistics
        self._update_statistics(reading)
        
        # Detect anomalies
        is_anomaly = self._detect_anomaly(reading)
        
        # Mark reading if anomaly detected
        if is_anomaly:
            metadata = {**reading.metadata, "anomaly": True}
        else:
            metadata = {**reading.metadata, "anomaly": False}
        
        return SensorReading(
            timestamp=reading.timestamp,
            sensor_id=reading.sensor_id,
            sensor_type=reading.sensor_type,
            data=data,
            format=SensorDataFormat.CALIBRATED,
            metadata=metadata
        )
    
    def _update_statistics(self, reading: SensorReading):
        """Update statistics for anomaly detection"""
        sensor_id = reading.sensor_id
        
        if sensor_id not in self.mean_values:
            self.mean_values[sensor_id] = reading.data.copy()
            self.std_values[sensor_id] = np.zeros_like(reading.data)
            return
        
        # Update mean and standard deviation
        alpha = 1.0 / len(self.buffer) if self.buffer else 0
        self.mean_values[sensor_id] = (
            alpha * reading.data + (1 - alpha) * self.mean_values[sensor_id]
        )
        
        # Update standard deviation
        diff = reading.data - self.mean_values[sensor_id]
        self.std_values[sensor_id] = (
            alpha * diff**2 + (1 - alpha) * self.std_values[sensor_id]
        )
    
    def _detect_anomaly(self, reading: SensorReading) -> bool:
        """Detect anomalies in sensor reading"""
        sensor_id = reading.sensor_id
        
        # Check if we have enough data
        if sensor_id not in self.mean_values:
            return False
        
        # Z-score test
        z_scores = np.abs((reading.data - self.mean_values[sensor_id]) / 
                         (self.std_values[sensor_id] + 1e-8))
        
        if np.any(z_scores > self.z_score_threshold):
            return True
        
        # Mahalanobis distance (simplified)
        if self.covariance is not None and len(self.buffer) > 10:
            diff = reading.data - self.mean_values[sensor_id]
            mahalanobis = np.sqrt(diff.T @ np.linalg.inv(self.covariance) @ diff)
            
            if mahalanobis > self.mahalanobis_threshold:
                return True
        
        return False


