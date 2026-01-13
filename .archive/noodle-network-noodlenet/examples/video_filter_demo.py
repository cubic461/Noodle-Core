"""
Examples::Video Filter Demo - video_filter_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleVision Video Filter Demo

Dit voorbeeld demonstreert het gebruik van NoodleVision voor real-time videoverwerking
met blur en edge detection operatoren.
"""

import asyncio
import logging
import numpy as np
from typing import Optional

# Importeer NoodleVision modules
from noodlenet.vision import CameraStream, BlurOperator, EdgeOperator, MediaStreamPipeline, StreamStage

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class VideoFrameProcessor:
    """Verwerkt video frames met meerdere operatoren"""
    
    def __init__(self):
        """ Initialiseer frame processor """
        # Initialiseer operatoren
        self.blur_operator = BlurOperator(radius=5)
        self.edge_operator = EdgeOperator(method="canny", threshold1=100, threshold2=200)
        
        # Statistieken
        self.frame_count = 0
        self.processing_times = []
    
    def process_frame(self, frame_data: np.ndarray) -> np.ndarray:
        """
        Verwerk een enkel frame
        
        Args:
            frame_data: Input frame data
            
        Returns:
            Verwerkt frame data
        """
        import time
        start_time = time.time()
        
        # Pas blur toe
        blurred_frame = self.blur_operator(frame_data)
        
        # Pas edge detection toe
        edge_frame = self.edge_operator(blurred_frame)
        
        # Update statistieken
        self.frame_count += 1
        processing_time = time.time() - start_time
        self.processing_times.append(processing_time)
        
        # Log verwerkingstijd elke 100 frames
        if self.frame_count % 100 == 0:
            avg_time = np.mean(self.processing_times[-100:])
            logger.info(f"Frame {self.frame_count}: Gemiddelde verwerkingstijd = {avg_time:.3f}s")
        
        return edge_frame
    
    def get_statistics(self) -> dict:
        """ Verwerkingsstatistieken """
        if not self.processing_times:
            return {}
        
        return {
            "frame_count": self.frame_count,
            "avg_processing_time": np.mean(self.processing_times),
            "min_processing_time": np.min(self.processing_times),
            "max_processing_time": np.max(self.processing_times),
            "fps": 1.0 / np.mean(self.processing_times) if self.processing_times else 0
        }


async def demo_basic_processing():
    """Demo van basis videoverwerking"""
    logger.info("Start basis videoverwerking demo")
    
    # Initialiseer camera stream
    camera = CameraStream(camera_id="0")
    
    # Initialiseer frame processor
    processor = VideoFrameProcessor()
    
    try:
        # Open camera stream
        await camera.open()
        logger.info("Camera stream geopend")
        
        # Verwerk 10 frames voor demo
        frame_count = 0
        async for frame in camera.stream_frames():
            if frame_count >= 10:
                break
            
            # Verwerk frame
            processed_frame = processor.process_frame(frame.data)
            
            logger.info(f"Frame {frame_count + 1} verwerkt")
            logger.info(f"  Originele shape: {frame.data.shape}")
            logger.info(f"  Verwerkte shape: {processed_frame.shape}")
            
            frame_count += 1
            
            # Kleine vertraging om CPU overload te voorkomen
            await asyncio.sleep(0.1)
        
        # Toon statistieken
        stats = processor.get_statistics()
        logger.info("Verwerkingsstatistieken:")
        for key, value in stats.items():
            logger.info(f"  {key}: {value}")
        
    except Exception as e:
        logger.error(f"Fout tijdens videoverwerking: {e}")
    
    finally:
        # Sluit camera stream
        await camera.close()
        logger.info("Camera stream gesloten")


async def demo_pipeline_processing():
    """Demo van pipeline videoverwerking"""
    logger.info("Start pipeline videoverwerking demo")
    
    # Initialiseer camera stream
    camera = CameraStream(camera_id="0")
    
    # Maak pipeline stages
    blur_stage = StreamStage(
        name="blur",
        operator=BlurOperator(radius=3)
    )
    
    edge_stage = StreamStage(
        name="edge",
        operator=EdgeOperator(method="sobel")
    )
    
    # Initialiseer pipeline
    pipeline = MediaStreamPipeline(source=camera, max_buffer_size=5)
    pipeline.add_stage(blur_stage)
    pipeline.add_stage(edge_stage)
    
    # Frame counter
    frame_count = 0
    
    def frame_callback(frame):
        """ Callback voor verwerkte frames """
        nonlocal frame_count
        frame_count += 1
        logger.info(f"Pipeline verwerkt frame {frame_count}: shape = {frame.data.shape}")
    
    # Set callback
    pipeline.set_frame_callback(frame_callback)
    
    try:
        # Start pipeline
        pipeline_task = asyncio.create_task(pipeline.start())
        
        # Wacht tot frames zijn verwerkt
        await asyncio.sleep(2)
        
        # Stop pipeline
        await pipeline.stop()
        
        logger.info(f"Pipeline demo voltooid. {frame_count} frames verwerkt.")
        
    except Exception as e:
        logger.error(f"Fout tijdens pipeline verwerking: {e}")
        await pipeline.stop()


async def demo_multiple_operators():
    """Demo van meerdere operatoren tegelijk"""
    logger.info("Start meerdere operatoren demo")
    
    # Initialiseer camera stream
    camera = CameraStream(camera_id="0")
    
    # Initialiseer verschillende operatoren
    blur_op = BlurOperator(radius=5)
    edge_op = EdgeOperator(method="canny")
    resize_op = lambda x: np.array([x[::2, ::2]])  # Simpel downsample
    
    operators = [blur_op, edge_op, resize_op]
    
    try:
        # Open camera stream
        await camera.open()
        
        # Verwerk frames met verschillende operatoren
        frame_count = 0
        async for frame in camera.stream_frames():
            if frame_count >= 5:
                break
            
            logger.info(f"Frame {frame_count + 1}:")
            logger.info(f"  Origineel: {frame.data.shape}")
            
            # Pas elke operator toe
            for i, op in enumerate(operators):
                processed = op(frame.data)
                logger.info(f"  Operator {i+1} ({op.__class__.__name__}): {processed.shape}")
            
            frame_count += 1
            await asyncio.sleep(0.2)
        
    except Exception as e:
        logger.error(f"Fout tijdens meerdere operatoren demo: {e}")
    
    finally:
        await camera.close()


async def main():
    """Hoofd functie voor alle demos"""
    logger.info("Start NoodleVision video filter demo")
    
    # Demo 1: Basis verwerking
    await demo_basic_processing()
    print()
    
    # Demo 2: Pipeline verwerking
    await demo_pipeline_processing()
    print()
    
    # Demo 3: Meerdere operatoren
    await demo_multiple_operators()
    
    logger.info("NoodleVision demo voltooid")


if __name__ == "__main__":
    # Voer demo uit
    asyncio.run(main())


