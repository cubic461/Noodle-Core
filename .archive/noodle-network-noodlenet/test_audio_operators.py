"""
Test Suite::Noodle Network Noodlenet - test_audio_operators.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script voor audio operators
"""

import sys
import os
import numpy as np
import time
import logging

# Voeg de bovenliggende directory toe aan sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    # Importeer de modules direct
    from noodlenet.vision.ops_audio import (
        ChromaOperator, TonnetzOperator, SpectrogramOperator, 
        AudioConfig, WindowType
    )
    logger.info("Modules succesvol geÃ¯mporteerd")
except ImportError as e:
    logger.error(f"Import fout: {e}")
    sys.exit(1)

def generate_test_audio(duration: float = 1.0, sample_rate: int = 22050) -> np.ndarray:
    """Genereer test audio data"""
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    
    # Genereer een samengesteld signaal
    audio = np.sin(2 * np.pi * 440 * t) + 0.5 * np.sin(2 * np.pi * 880 * t)
    
    # Voeg wat ruis toe
    noise = 0.1 * np.random.randn(len(t))
    audio = audio + noise
    
    return audio.astype(np.float32)

def test_chroma_operator():
    """Test ChromaOperator met verschillende configuraties"""
    logger.info("Test ChromaOperator")
    
    test_audio = generate_test_audio(duration=2.0)
    
    # Test met verschillende configuraties
    configs = [
        AudioConfig(sample_rate=22050, window_type=WindowType.HANN),
        AudioConfig(sample_rate=44100, window_type=WindowType.HAMMING),
        AudioConfig(sample_rate=16000, window_type=WindowType.BLACKMAN),
    ]
    
    for i, config in enumerate(configs):
        logger.info(f"\nConfiguratie {i+1}: {config.window_type.value} @ {config.sample_rate}Hz")
        
        try:
            chroma_op = ChromaOperator(config=config)
            start_time = time.time()
            chroma = chroma_op(test_audio)
            processing_time = time.time() - start_time
            
            logger.info(f"  Chroma shape: {chroma.shape}")
            logger.info(f"  Processing time: {processing_time:.4f}s")
            logger.info(f"  Dominant chroma bin: {np.argmax(np.mean(chroma, axis=1))}")
            
        except Exception as e:
            logger.error(f"  Fout bij configuratie {i+1}: {e}")

def test_tonnetz_operator():
    """Test TonnetzOperator met verschillende configuraties"""
    logger.info("\nTest TonnetzOperator")
    
    test_audio = generate_test_audio(duration=2.0)
    
    # Test met verschillende configuraties
    configs = [
        AudioConfig(sample_rate=22050, window_type=WindowType.HANN),
        AudioConfig(sample_rate=44100, window_type=WindowType.HAMMING),
        AudioConfig(sample_rate=16000, window_type=WindowType.BLACKMAN),
    ]
    
    for i, config in enumerate(configs):
        logger.info(f"\nConfiguratie {i+1}: {config.window_type.value} @ {config.sample_rate}Hz")
        
        try:
            tonnetz_op = TonnetzOperator(config=config)
            start_time = time.time()
            tonnetz = tonnetz_op(test_audio)
            processing_time = time.time() - start_time
            
            logger.info(f"  Tonnetz shape: {tonnetz.shape}")
            logger.info(f"  Processing time: {processing_time:.4f}s")
            logger.info(f"  Energy: {np.sum(tonnetz**2):.4f}")
            
        except Exception as e:
            logger.error(f"  Fout bij configuratie {i+1}: {e}")

def test_chroma_tonnetz_integration():
    """Test integratie tussen Chroma en Tonnetz operatoren"""
    logger.info("\nTest Chroma-Tonnetz integratie")
    
    test_audio = generate_test_audio(duration=2.0)
    
    try:
        # Maak operators met dezelfde configuratie
        config = AudioConfig(sample_rate=22050, window_type=WindowType.HANN)
        chroma_op = ChromaOperator(config=config)
        tonnetz_op = TonnetzOperator(config=config)
        
        # Verken audio
        chroma = chroma_op(test_audio)
        tonnetz = tonnetz_op(test_audio)
        
        logger.info(f"Chroma shape: {chroma.shape}")
        logger.info(f"Tonnetz shape: {tonnetz.shape}")
        
        # Controleer of de integratie correct is
        # Tonnetz moet een transformatie zijn van Chroma
        expected_tonnetz_shape = (6, chroma.shape[1])
        if tonnetz.shape == expected_tonnetz_shape:
            logger.info("  âœ“ Integratie correct: Tonnetz heeft verwachte vorm")
        else:
            logger.error(f"  âœ— Integratie fout: Verwacht {expected_tonnetz_shape}, gekregen {tonnetz.shape}")
        
        # Toon basis statistieken
        logger.info(f"  Chroma energie: {np.sum(chroma**2):.4f}")
        logger.info(f"  Tonnetz energie: {np.sum(tonnetz**2):.4f}")
        
    except Exception as e:
        logger.error(f"  Fout bij integratietest: {e}")

def main():
    """Hoofd test functie"""
    logger.info("Start audio operators test")
    
    # Test ChromaOperator
    test_chroma_operator()
    
    # Test TonnetzOperator
    test_tonnetz_operator()
    
    # Test integratie
    test_chroma_tonnetz_integration()
    
    logger.info("Test voltooid")

if __name__ == "__main__":
    main()


