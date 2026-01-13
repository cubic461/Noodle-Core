#!/usr/bin/env python3
"""
Examples::Audio Feature Extraction Demo - audio_feature_extraction_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleVision Audio Feature Extraction Demo

This script demonstrates how to use NoodleVision for comprehensive audio feature extraction.
It processes audio files and extracts various features including spectrograms, MFCCs, chroma features, and Tonnetz features.

Features demonstrated:
- Audio loading and preprocessing
- Feature extraction with memory management
- Batch processing
- Performance monitoring
- Visualization of results
"""

import numpy as np
import matplotlib.pyplot as plt
import time
import os
import logging
from typing import Dict, List, Tuple, Optional
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Import NoodleVision modules
try:
    import sys
    import os
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))
    
    from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
    from memory import MemoryManager, MemoryPolicy
    logger.info("âœ“ Successfully imported NoodleVision modules")
except ImportError as e:
    logger.error(f"âœ— Failed to import NoodleVision: {e}")
    exit(1)

class AudioFeatureExtractor:
    """Comprehensive audio feature extractor using NoodleVision"""
    
    def __init__(self, memory_policy: MemoryPolicy = MemoryPolicy.BALANCED):
        """
        Initialize the audio feature extractor.
        
        Args:
            memory_policy: Memory management policy to use
        """
        self.memory_manager = MemoryManager(policy=memory_policy)
        self.operators = {
            'spectrogram': SpectrogramOperator(),
            'mfcc': MFCCOperator(n_mfcc=13),
            'chroma': ChromaOperator(),
            'tonnetz': TonnetzOperator()
        }
        
        # Performance tracking
        self.performance_metrics = {
            'extraction_times': [],
            'memory_usage': [],
            'cache_stats': []
        }
        
        logger.info(f"âœ“ Initialized AudioFeatureExtractor with {memory_policy.value} policy")
    
    def generate_test_audio(self, duration: float = 10.0, sample_rate: int = 22050) -> np.ndarray:
        """
        Generate test audio signal with multiple frequency components.
        
        Args:
            duration: Duration in seconds
            sample_rate: Sample rate in Hz
            
        Returns:
            Generated audio signal
        """
        t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
        
        # Generate complex audio with multiple frequency components
        audio = (
            0.5 * np.sin(2 * np.pi * 440 * t) +  # A4 note
            0.3 * np.sin(2 * np.pi * 880 * t) +  # A5 note
            0.2 * np.sin(2 * np.pi * 220 * t) +  # A3 note
            0.1 * np.random.randn(len(t))          # Noise
        )
        
        # Normalize to prevent clipping
        audio = audio / np.max(np.abs(audio))
        
        logger.info(f"âœ“ Generated test audio: {duration}s at {sample_rate}Hz")
        return audio
    
    def extract_features(self, audio: np.ndarray, sample_rate: int = 22050) -> Dict[str, np.ndarray]:
        """
        Extract all audio features using NoodleVision operators.
        
        Args:
            audio: Audio signal
            sample_rate: Sample rate of audio
            
        Returns:
            Dictionary containing all extracted features
        """
        features = {}
        start_time = time.time()
        
        logger.info("ðŸ”„ Extracting audio features...")
        
        for name, operator in self.operators.items():
            try:
                # Extract features
                feature_start = time.time()
                feature = operator(audio)
                feature_time = time.time() - feature_start
                
                features[name] = feature
                
                # Log performance
                logger.info(f"  âœ“ {name}: {feature.shape} in {feature_time:.3f}s")
                
            except Exception as e:
                logger.error(f"  âœ— {name} failed: {e}")
                features[name] = None
        
        total_time = time.time() - start_time
        self.performance_metrics['extraction_times'].append(total_time)
        
        # Get memory statistics
        stats = self.memory_manager.get_statistics()
        self.performance_metrics['memory_usage'].append({
            'cpu_usage': stats['cpu_pool']['usage_percentage'],
            'gpu_usage': stats['gpu_pool']['usage_percentage']
        })
        self.performance_metrics['cache_stats'].append(stats['cache_stats'])
        
        logger.info(f"âœ“ Feature extraction completed in {total_time:.3f}s")
        return features
    
    def extract_batch(self, audio_files: List[str], batch_size: int = 5) -> List[Dict[str, np.ndarray]]:
        """
        Extract features from multiple audio files in batches.
        
        Args:
            audio_files: List of audio file paths
            batch_size: Number of files to process in each batch
            
        Returns:
            List of feature dictionaries
        """
        all_features = []
        
        for i in range(0, len(audio_files), batch_size):
            batch_files = audio_files[i:i + batch_size]
            logger.info(f"ðŸ”„ Processing batch {i//batch_size + 1}/{(len(audio_files)-1)//batch_size + 1}")
            
            batch_features = []
            for file_path in batch_files:
                try:
                    # In a real implementation, you would load the actual audio file
                    # For this demo, we'll use generated test audio
                    audio = self.generate_test_audio()
                    features = self.extract_features(audio)
                    batch_features.append(features)
                except Exception as e:
                    logger.error(f"âœ— Failed to process {file_path}: {e}")
                    batch_features.append(None)
            
            all_features.extend(batch_features)
            
            # Clean up after batch
            self.memory_manager.cleanup()
        
        return all_features
    
    def analyze_performance(self) -> Dict[str, float]:
        """
        Analyze performance metrics.
        
        Returns:
            Dictionary with performance statistics
        """
        if not self.performance_metrics['extraction_times']:
            return {}
        
        extraction_times = self.performance_metrics['extraction_times']
        
        analysis = {
            'avg_extraction_time': np.mean(extraction_times),
            'std_extraction_time': np.std(extraction_times),
            'min_extraction_time': np.min(extraction_times),
            'max_extraction_time': np.max(extraction_times),
            'total_extractions': len(extraction_times)
        }
        
        # Memory usage analysis
        if self.performance_metrics['memory_usage']:
            cpu_usage = [m['cpu_usage'] for m in self.performance_metrics['memory_usage']]
            gpu_usage = [m['gpu_usage'] for m in self.performance_metrics['memory_usage']]
            
            analysis.update({
                'avg_cpu_usage': np.mean(cpu_usage),
                'avg_gpu_usage': np.mean(gpu_usage),
                'max_cpu_usage': np.max(cpu_usage),
                'max_gpu_usage': np.max(gpu_usage)
            })
        
        logger.info("ðŸ“Š Performance Analysis:")
        for key, value in analysis.items():
            if isinstance(value, float):
                logger.info(f"  {key}: {value:.3f}")
            else:
                logger.info(f"  {key}: {value}")
        
        return analysis
    
    def visualize_features(self, features: Dict[str, np.ndarray], save_path: Optional[str] = None):
        """
        Visualize extracted features.
        
        Args:
            features: Dictionary of features to visualize
            save_path: Path to save the visualization
        """
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        fig.suptitle('NoodleVision Audio Feature Extraction Results', fontsize=16)
        
        # Spectrogram
        if features['spectrogram'] is not None:
            spec = np.abs(features['spectrogram'])
            im1 = axes[0, 0].imshow(spec, aspect='auto', origin='lower', cmap='viridis')
            axes[0, 0].set_title('Spectrogram')
            axes[0, 0].set_xlabel('Time Frames')
            axes[0, 0].set_ylabel('Frequency Bins')
            plt.colorbar(im1, ax=axes[0, 0])
        
        # MFCC
        if features['mfcc'] is not None:
            im2 = axes[0, 1].imshow(features['mfcc'], aspect='auto', origin='lower', cmap='coolwarm')
            axes[0, 1].set_title('MFCC Coefficients')
            axes[0, 1].set_xlabel('Time Frames')
            axes[0, 1].set_ylabel('MFCC Coefficients')
            plt.colorbar(im2, ax=axes[0, 1])
        
        # Chroma
        if features['chroma'] is not None:
            im3 = axes[1, 0].imshow(features['chroma'], aspect='auto', origin='lower', cmap='hsv')
            axes[1, 0].set_title('Chroma Features')
            axes[1, 0].set_xlabel('Time Frames')
            axes[1, 0].set_ylabel('Chroma Bins')
            plt.colorbar(im3, ax=axes[1, 0])
        
        # Tonnetz
        if features['tonnetz'] is not None:
            im4 = axes[1, 1].imshow(features['tonnetz'], aspect='auto', origin='lower', cmap='plasma')
            axes[1, 1].set_title('Tonnetz Features')
            axes[1, 1].set_xlabel('Time Frames')
            axes[1, 1].set_ylabel('Tonnetz Dimensions')
            plt.colorbar(im4, ax=axes[1, 1])
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            logger.info(f"âœ“ Visualization saved to {save_path}")
        
        plt.show()
    
    def cleanup(self):
        """Clean up resources"""
        self.memory_manager.cleanup()
        logger.info("âœ“ Memory cleanup completed")


def demo_basic_usage():
    """Demonstrate basic usage of the audio feature extractor"""
    logger.info("ðŸš€ Starting Basic Usage Demo")
    
    # Initialize extractor
    extractor = AudioFeatureExtractor(memory_policy=MemoryPolicy.BALANCED)
    
    try:
        # Generate test audio
        audio = extractor.generate_test_audio(duration=5.0)
        logger.info(f"ðŸŽµ Generated audio: {len(audio)} samples, {audio.dtype}")
        
        # Extract features
        features = extractor.extract_features(audio)
        
        # Display results
        logger.info("\nðŸ“ˆ Extracted Features:")
        for name, feature in features.items():
            if feature is not None:
                logger.info(f"  {name}: {feature.shape}, dtype: {feature.dtype}")
            else:
                logger.warning(f"  {name}: Failed to extract")
        
        # Visualize results
        extractor.visualize_features(features)
        
        # Analyze performance
        extractor.analyze_performance()
        
    except Exception as e:
        logger.error(f"âœ— Demo failed: {e}")
    finally:
        extractor.cleanup()


def demo_memory_policies():
    """Demonstrate different memory management policies"""
    logger.info("ðŸš€ Starting Memory Policies Demo")
    
    policies = [
        MemoryPolicy.CONSERVATIVE,
        MemoryPolicy.BALANCED,
        MemoryPolicy.AGGRESSIVE_REUSE,
        MemoryPolicy.QUALITY_FIRST,
        MemoryPolicy.LATENCY_FIRST
    ]
    
    results = {}
    
    for policy in policies:
        logger.info(f"\nðŸ“Š Testing {policy.value} policy...")
        
        extractor = AudioFeatureExtractor(memory_policy=policy)
        
        try:
            # Extract features multiple times to test memory reuse
            for i in range(3):
                audio = extractor.generate_test_audio(duration=3.0)
                features = extractor.extract_features(audio)
                time.sleep(0.1)  # Small delay to simulate processing
            
            # Get final statistics
            stats = extractor.memory_manager.get_statistics()
            results[policy.value] = {
                'cache_efficiency': stats['cache_stats']['cache_efficiency'],
                'allocations_count': stats['allocations_count'],
                'avg_cpu_usage': stats['cpu_pool']['usage_percentage'],
                'avg_gpu_usage': stats['gpu_pool']['usage_percentage']
            }
            
            logger.info(f"  Cache efficiency: {stats['cache_stats']['cache_efficiency']:.2f}")
            logger.info(f"  Allocations: {stats['allocations_count']}")
            
        except Exception as e:
            logger.error(f"  âœ— {policy.value} policy failed: {e}")
            results[policy.value] = None
        finally:
            extractor.cleanup()
    
    # Display comparison
    logger.info("\nðŸ“Š Memory Policy Comparison:")
    for policy, metrics in results.items():
        if metrics:
            logger.info(f"  {policy}:")
            logger.info(f"    Cache efficiency: {metrics['cache_efficiency']:.2f}")
            logger.info(f"    Allocations: {metrics['allocations_count']}")
            logger.info(f"    CPU usage: {metrics['avg_cpu_usage']:.1f}%")
            logger.info(f"    GPU usage: {metrics['avg_gpu_usage']:.1f}%")
        else:
            logger.info(f"  {policy}: Failed")


def demo_batch_processing():
    """Demonstrate batch processing capabilities"""
    logger.info("ðŸš€ Starting Batch Processing Demo")
    
    # Create dummy audio files list
    num_files = 10
    audio_files = [f"audio_{i:03d}.wav" for i in range(num_files)]
    
    # Initialize extractor with aggressive reuse for batch processing
    extractor = AudioFeatureExtractor(memory_policy=MemoryPolicy.AGGRESSIVE_REUSE)
    
    try:
        # Process in batches
        start_time = time.time()
        all_features = extractor.extract_batch(audio_files, batch_size=3)
        total_time = time.time() - start_time
        
        logger.info(f"\nâœ“ Processed {len(all_features)} files in {total_time:.3f}s")
        logger.info(f"  Average time per file: {total_time/len(all_features):.3f}s")
        
        # Analyze performance
        extractor.analyze_performance()
        
    except Exception as e:
        logger.error(f"âœ— Batch processing failed: {e}")
    finally:
        extractor.cleanup()


def demo_error_handling():
    """Demonstrate error handling capabilities"""
    logger.info("ðŸš€ Starting Error Handling Demo")
    
    extractor = AudioFeatureExtractor(memory_policy=MemoryPolicy.CONSERVATIVE)
    
    try:
        # Test with empty audio
        logger.info("ðŸ“‹ Testing with empty audio...")
        try:
            empty_audio = np.array([])
            features = extractor.extract_features(empty_audio)
            logger.warning("  Expected error but got features")
        except Exception as e:
            logger.info(f"  âœ“ Correctly handled empty audio: {e}")
        
        # Test with very short audio
        logger.info("ðŸ“‹ Testing with very short audio...")
        try:
            short_audio = np.random.randn(100)  # Very short
            features = extractor.extract_features(short_audio)
            logger.info(f"  âœ“ Processed short audio: {len(features)} features extracted")
        except Exception as e:
            logger.warning(f"  âœ— Failed to process short audio: {e}")
        
        # Test with zero audio
        logger.info("ðŸ“‹ Testing with zero audio...")
        try:
            zero_audio = np.zeros(22050)
            features = extractor.extract_features(zero_audio)
            logger.info(f"  âœ“ Processed zero audio: {len(features)} features extracted")
        except Exception as e:
            logger.warning(f"  âœ— Failed to process zero audio: {e}")
        
    except Exception as e:
        logger.error(f"âœ— Error handling demo failed: {e}")
    finally:
        extractor.cleanup()


def main():
    """Main demo function"""
    logger.info("ðŸŒŸ NoodleVision Audio Feature Extraction Demo")
    logger.info("=" * 50)
    
    # Run different demos
    demos = [
        ("Basic Usage", demo_basic_usage),
        ("Memory Policies", demo_memory_policies),
        ("Batch Processing", demo_batch_processing),
        ("Error Handling", demo_error_handling)
    ]
    
    for demo_name, demo_func in demos:
        try:
            logger.info(f"\n{'='*20} {demo_name} {'='*20}")
            demo_func()
            logger.info(f"\n{'âœ“' * 50}")
        except Exception as e:
            logger.error(f"\nâœ— {demo_name} demo failed: {e}")
            logger.error(f"\n{'âœ—' * 50}")
    
    logger.info("\nðŸŽ‰ Demo completed!")


if __name__ == "__main__":
    main()


