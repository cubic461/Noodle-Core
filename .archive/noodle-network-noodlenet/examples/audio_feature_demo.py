"""
Examples::Audio Feature Demo - audio_feature_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleVision Audio Feature Demo

Dit voorbeeld demonstreert het gebruik van NoodleVision voor audio feature extraction
met spectrogram en MFCC operatoren.
"""

import asyncio
import logging
import numpy as np
import sys
import os
from typing import Optional

# Voeg huidige directory toe aan sys.path voor imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Importeer NoodleVision modules
from noodlenet.vision import (
    MediaStream, MediaFrame, SpectrogramOperator, MFCCOperator, ChromaOperator,
    TonnetzOperator, AudioConfig, WindowType, MelScale, StreamType
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class AudioFeatureExtractor:
    """Extraheert features uit audio data"""
    
    def __init__(self, config: Optional[AudioConfig] = None):
        """
        Initialiseer audio feature extractor
        
        Args:
            config: Audio configuratie
        """
        self.config = config or AudioConfig()
        
        # Initialiseer operatoren
        self.spectrogram_op = SpectrogramOperator(config)
        self.mfcc_op = MFCCOperator(config=config)
        self.chroma_op = ChromaOperator(config=config)
        self.tonnetz_op = TonnetzOperator(config=config)
        
        # Statistieken
        self.frame_count = 0
        self.processing_times = []
    
    def extract_features(self, audio_data: np.ndarray) -> dict:
        """
        Extraheer features uit audio data
        
        Args:
            audio_data: Input audio data
            
        Returns:
            Dictionary met geÃ«xtraheerde features
        """
        import time
        start_time = time.time()
        
        features = {}
        
        # Spectrogram
        try:
            spectrogram = self.spectrogram_op(audio_data)
            features['spectrogram'] = spectrogram
            logger.debug(f"Spectrogram berekend: shape={spectrogram.shape}")
        except Exception as e:
            logger.warning(f"Kon spectrogram niet berekenen: {e}")
            features['spectrogram'] = None
        
        # MFCC
        try:
            mfcc = self.mfcc_op(audio_data)
            features['mfcc'] = mfcc
            logger.debug(f"MFCC berekend: shape={mfcc.shape}")
        except Exception as e:
            logger.warning(f"Kon MFCC niet berekenen: {e}")
            features['mfcc'] = None
        
        # Chroma
        try:
            chroma = self.chroma_op(audio_data)
            features['chroma'] = chroma
            logger.debug(f"Chroma berekend: shape={chroma.shape}")
        except Exception as e:
            logger.warning(f"Kon chroma niet berekenen: {e}")
            features['chroma'] = None
        
        # Tonnetz
        try:
            tonnetz = self.tonnetz_op(audio_data)
            features['tonnetz'] = tonnetz
            logger.debug(f"Tonnetz berekend: shape={tonnetz.shape}")
        except Exception as e:
            logger.warning(f"Kon Tonnetz niet berekenen: {e}")
            features['tonnetz'] = None
        
        # Update statistieken
        self.frame_count += 1
        processing_time = time.time() - start_time
        self.processing_times.append(processing_time)
        
        return features
    
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


def generate_test_audio(duration: float = 1.0, sample_rate: int = 22050) -> np.ndarray:
    """
    Genereer test audio data
    
    Args:
        duration: Duur in seconden
        sample_rate: Sample rate
        
    Returns:
        Test audio data
    """
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    
    # Genereer een samengesteld signaal
    # 440 Hz (A4) + 880 Hz (A5)
    audio = np.sin(2 * np.pi * 440 * t) + 0.5 * np.sin(2 * np.pi * 880 * t)
    
    # Voeg wat ruis toe
    noise = 0.1 * np.random.randn(len(t))
    audio = audio + noise
    
    return audio.astype(np.float32)


async def demo_basic_audio_processing():
    """Demo van basis audioverwerking"""
    logger.info("Start basis audioverwerking demo")
    
    # Genereer test audio
    test_audio = generate_test_audio(duration=2.0)
    logger.info(f"Test audio gegenereerd: shape={test_audio.shape}")
    
    # Initialiseer feature extractor
    extractor = AudioFeatureExtractor()
    
    try:
        # Verwerk audio data
        features = extractor.extract_features(test_audio)
        
        logger.info("Audio features geÃ«xtraheerd:")
        for feature_name, feature_data in features.items():
            if feature_data is not None:
                logger.info(f"  {feature_name}: shape={feature_data.shape}")
                # Toon basis statistieken
                if len(feature_data.shape) == 2:
                    logger.info(f"    Dimensies: {feature_data.shape[0]} bands, {feature_data.shape[1]} frames")
                else:
                    logger.info(f"    Waarden: min={np.min(feature_data):.3f}, max={np.max(feature_data):.3f}")
            else:
                logger.info(f"  {feature_name}: Kon niet berekenen")
        
        # Toon verwerkingsstatistieken
        stats = extractor.get_statistics()
        logger.info("Verwerkingsstatistieken:")
        for key, value in stats.items():
            logger.info(f"  {key}: {value}")
        
    except Exception as e:
        logger.error(f"Fout tijdens audioverwerking: {e}")


async def demo_audio_streaming():
    """Demo van audio streaming"""
    logger.info("Start audio streaming demo")
    
    # Initialiseer audio stream (gebruikt microphone in echte implementatie)
    # Voor nu gebruiken we een test stream
    class TestAudioStream(MediaStream):
        """Test audio stream voor demo"""
        
        def __init__(self, sample_rate: int = 22050):
            super().__init__(f"audio://test_stream_{sample_rate}")
            self.stream_type = StreamType.AUDIO
            self.sample_rate = sample_rate
            self.duration = 0.1  # 100ms frames
            self.total_frames = 0
        
        async def open(self):
            """Open stream"""
            logger.info("Test audio stream geopend")
            await super().open()
        
        async def close(self):
            """Sluit stream"""
            logger.info("Test audio stream gesloten")
            await super().close()
        
        async def read_frame(self) -> Optional[MediaFrame]:
            """Lees een frame"""
            if self.total_frames >= 20:  # Stop na 20 frames
                return None
            
            # Genereer test frame
            frame_data = generate_test_audio(duration=self.duration, sample_rate=self.sample_rate)
            timestamp = asyncio.get_event_loop().time()
            metadata = {
                "sample_rate": self.sample_rate,
                "duration": self.duration,
                "frame_number": self.total_frames
            }
            
            self.total_frames += 1
            
            return MediaFrame(
                data=frame_data,
                timestamp=timestamp,
                stream_type=self.stream_type,
                metadata=metadata
            )
        
        async def stream_frames(self):
            """Stream frames"""
            await self.open()
            try:
                while True:
                    frame = await self.read_frame()
                    if frame is None:
                        break
                    yield frame
            finally:
                await self.close()
    
    # Maak test stream
    audio_stream = TestAudioStream()
    
    # Initialiseer feature extractor
    extractor = AudioFeatureExtractor()
    
    try:
        # Stream en verwerk frames
        frame_count = 0
        async for frame in audio_stream.stream_frames():
            features = extractor.extract_features(frame.data)
            
            logger.info(f"Frame {frame_count + 1} verwerkt")
            for feature_name, feature_data in features.items():
                if feature_data is not None and len(feature_data.shape) == 2:
                    logger.info(f"  {feature_name}: {feature_data.shape[0]} x {feature_data.shape[1]}")
            
            frame_count += 1
            
            if frame_count >= 5:  # Verwerk slechts 5 frames voor demo
                break
        
        # Toon statistieken
        stats = extractor.get_statistics()
        logger.info("Streaming statistieken:")
        for key, value in stats.items():
            logger.info(f"  {key}: {value}")
        
    except Exception as e:
        logger.error(f"Fout tijdens audio streaming: {e}")


async def demo_multiple_configurations():
    """Demo met verschillende configuraties"""
    logger.info("Start meerdere configuraties demo")
    
    # Definieer verschillende configuraties
    configs = [
        AudioConfig(sample_rate=22050, window_type=WindowType.HANN),
        AudioConfig(sample_rate=44100, window_type=WindowType.HAMMING),
        AudioConfig(sample_rate=16000, window_type=WindowType.BLACKMAN),
    ]
    
    test_audio = generate_test_audio(duration=1.0)
    
    for i, config in enumerate(configs):
        logger.info(f"\nConfiguratie {i+1}: {config.window_type.value} @ {config.sample_rate}Hz")
        
        extractor = AudioFeatureExtractor(config)
        
        try:
            features = extractor.extract_features(test_audio)
            
            for feature_name, feature_data in features.items():
                if feature_data is not None:
                    if feature_name == 'mfcc':
                        logger.info(f"  {feature_name}: {feature_data.shape[0]} MFCC coefficients")
                    elif feature_name == 'chroma':
                        logger.info(f"  {feature_name}: {feature_data.shape[0]} chroma bins")
                    else:
                        logger.info(f"  {feature_name}: {feature_data.shape}")
        
        except Exception as e:
            logger.error(f"Fout met configuratie {i+1}: {e}")


async def demo_feature_comparison():
    """Demo van feature vergelijking"""
    logger.info("Start feature vergelijking demo")
    
    # Genereer verschillende audio signalen
    signals = {
        "440Hz": generate_test_audio(duration=1.0, sample_rate=22050),
        "880Hz": generate_test_audio(duration=1.0, sample_rate=22050),
        "Noise": np.random.randn(22050).astype(np.float32),
        "Silence": np.zeros(22050, dtype=np.float32)
    }
    
    # Gebruik simpele configuratie
    config = AudioConfig(sample_rate=22050, n_mfcc=13, n_mels=128)
    extractor = AudioFeatureExtractor(config)
    
    try:
        # Vergelijk features voor verschillende signalen
        for signal_name, signal_data in signals.items():
            logger.info(f"\n{signal_name} signaal:")
            
            features = extractor.extract_features(signal_data)
            
            # Vergelijk spectrogram kenmerken
            if features['spectrogram'] is not None:
                spec = features['spectrogram']
                logger.info(f"  Spectrogram: energie={np.sum(spec):.2f}, dominant_freq={np.unravel_index(np.argmax(spec), spec.shape)[0]}")
            
            # Vergelijk MFCC kenmerken
            if features['mfcc'] is not None:
                mfcc = features['mfcc']
                logger.info(f"  MFCC: gemiddelde={np.mean(mfcc):.3f}, std={np.std(mfcc):.3f}")
            
            # Vergelijk chroma kenmerken
            if features['chroma'] is not None:
                chroma = features['chroma']
                logger.info(f"  Chroma: dominant_chroma={np.argmax(np.mean(chroma, axis=1))}")
    
    except Exception as e:
        logger.error(f"Fout tijdens feature vergelijking: {e}")


async def main():
    """Hoofd functie voor alle demos"""
    logger.info("Start NoodleVision audio feature demo")
    
    # Demo 1: Basis audioverwerking
    await demo_basic_audio_processing()
    print()
    
    # Demo 2: Audio streaming
    await demo_audio_streaming()
    print()
    
    # Demo 3: Meerdere configuraties
    await demo_multiple_configurations()
    print()
    
    # Demo 4: Feature vergelijking
    await demo_feature_comparison()
    
    logger.info("NoodleVision audio demo voltooid")


if __name__ == "__main__":
    # Voer demo uit
    asyncio.run(main())


