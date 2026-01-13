"""
Vision::Ops Audio - ops_audio.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Audio operators for NoodleVision

This module provides audio processing operators implemented as NBC tensor operations.
"""

import logging
import numpy as np
from typing import Optional, Tuple, Dict, Any, List
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)


class WindowType(Enum):
    """Window types for audio processing"""
    HANN = "hann"
    HAMMING = "hamming"
    BLACKMAN = "blackman"
    FLAT_TOP = "flat_top"
    RECTANGULAR = "rectangular"


class MelScale(Enum):
    """Mel scale implementations"""
    SLANEY = "slaney"
    VTK = "vtk"


@dataclass
class AudioConfig:
    """Configuration for audio operators"""
    # Audio settings
    sample_rate: int = 22050
    hop_length: int = 512
    win_length: int = 2048
    
    # Window settings
    window_type: WindowType = WindowType.HANN
    
    # STFT settings
    n_fft: int = 2048
    power_spectrum: bool = True
    
    # Mel scale settings
    n_mels: int = 128
    mel_fmin: float = 0.0
    mel_fmax: Optional[float] = None
    mel_scale: MelScale = MelScale.SLANEY
    
    # MFCC settings
    n_mfcc: int = 13
    melkwargs: Optional[Dict[str, Any]] = None


class AudioOperator(ABC):
    """Base class for audio operators"""
    
    def __init__(self, config: Optional[AudioConfig] = None):
        """
        Initialize audio operator
        
        Args:
            config: Audio configuration
        """
        self.config = config or AudioConfig()
        self.execution_stats = {
            "total_calls": 0,
            "total_time": 0.0,
            "input_samples": 0,
            "output_samples": 0
        }
    
    @abstractmethod
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Apply the operator to audio data
        
        Args:
            audio_data: Input audio array (samples, channels)
            
        Returns:
            Processed audio array
        """
        pass
    
    def __call__(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Operator call interface
        
        Args:
            audio_data: Input audio array
            
        Returns:
            Processed audio array
        """
        # Update statistics
        self.execution_stats["total_calls"] += 1
        self.execution_stats["input_samples"] += len(audio_data)
        
        # Apply operator
        result = self.apply(audio_data)
        
        # Update output statistics
        self.execution_stats["output_samples"] += len(result)
        
        return result
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get operator execution statistics"""
        return self.execution_stats.copy()


class SpectrogramOperator(AudioOperator):
    """Spectrogram calculation operator"""
    
    def __init__(self, config: Optional[AudioConfig] = None):
        """
        Initialize spectrogram operator
        
        Args:
            config: Audio configuration
        """
        super().__init__(config)
        self._mel_filters = None
        self._window = self._create_window()
    
    def _create_window(self) -> np.ndarray:
        """Create analysis window"""
        n = self.config.win_length
        
        if self.config.window_type == WindowType.HANN:
            return np.hanning(n)
        elif self.config.window_type == WindowType.HAMMING:
            return np.hamming(n)
        elif self.config.window_type == WindowType.BLACKMAN:
            return np.blackman(n)
        elif self.config.window_type == WindowType.FLAT_TOP:
            return np.blackman(n)
        elif self.config.window_type == WindowType.RECTANGULAR:
            return np.ones(n)
        else:
            raise ValueError(f"Unknown window type: {self.config.window_type}")
    
    def _create_mel_filters(self) -> np.ndarray:
        """Create Mel filter bank"""
        # Create frequency bins
        nyquist = self.config.sample_rate / 2
        all_freqs = np.linspace(0, nyquist, self.config.n_fft // 2 + 1)
        
        # Convert to Mel scale
        mel_fmin = self.config.mel_fmin
        mel_fmax = self.config.mel_fmax or nyquist
        
        if self.config.mel_scale == MelScale.SLANEY:
            # Slaney mel scale
            melpoints = np.linspace(self._hz_to_mel(mel_fmin),
                                    self._hz_to_mel(mel_fmax),
                                    self.config.n_mels + 2)
        else:
            # VTK mel scale
            melpoints = np.linspace(0, self._hz_to_mel(mel_fmax),
                                    self.config.n_mels + 2)
        
        # Convert back to Hz
        hz_points = self._mel_to_hz(melpoints)
        
        # Create filter bank
        filters = np.zeros((self.config.n_mels, len(all_freqs)))
        
        for i in range(self.config.n_mels):
            start = hz_points[i]
            center = hz_points[i + 1]
            end = hz_points[i + 2]
            
            # Triangular filter
            for j, freq in enumerate(all_freqs):
                if start <= freq <= end:
                    if freq <= center:
                        filters[i, j] = (freq - start) / (center - start)
                    else:
                        filters[i, j] = (end - freq) / (end - center)
        
        return filters
    
    def _hz_to_mel(self, hz: float) -> float:
        """Convert Hz to Mel scale (Slaney)"""
        return 1127.0 * np.log1p(hz / 700.0)
    
    def _mel_to_hz(self, mel: float) -> float:
        """Convert Mel scale to Hz (Slaney)"""
        return 700.0 * (np.exp(mel / 1127.0) - 1.0)
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate spectrogram from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            Spectrogram array (freq_bins, time_frames)
        """
        # Ensure mono audio
        if len(audio_data.shape) > 1:
            audio_data = np.mean(audio_data, axis=1)
        
        # Apply window and STFT
        n = self.config.win_length
        hop = self.config.hop_length
        
        # Pad audio if needed
        pad_length = n // 2
        audio_padded = np.pad(audio_data, (pad_length, pad_length), mode='reflect')
        
        # Initialize STFT matrix
        n_frames = 1 + (len(audio_data) - n) // hop
        stft = np.zeros((self.config.n_fft // 2 + 1, n_frames), dtype=np.complex128)
        
        # Compute STFT
        for i in range(n_frames):
            start = i * hop
            end = start + n
            frame = audio_padded[start:end] * self._window
            stft[:, i] = np.fft.rfft(frame, self.config.n_fft)
        
        # Convert to power spectrum
        if self.config.power_spectrum:
            spectrogram = np.abs(stft) ** 2
        else:
            spectrogram = np.abs(stft)
        
        # Apply Mel filter bank
        if self.config.n_mels > 0:
            if self._mel_filters is None:
                self._mel_filters = self._create_mel_filters()
            
            mel_spec = self._mel_filters @ spectrogram
        else:
            mel_spec = spectrogram
        
        return mel_spec


class MFCCOperator(AudioOperator):
    """MFCC (Mel-Frequency Cepstral Coefficients) calculation operator"""
    
    def __init__(self, n_mfcc: int = 13, config: Optional[AudioConfig] = None):
        """
        Initialize MFCC operator
        
        Args:
            n_mfcc: Number of MFCC coefficients
            config: Audio configuration
        """
        # Override n_mfcc in config
        if config is None:
            config = AudioConfig()
        config.n_mfcc = n_mfcc
        
        super().__init__(config)
        self.spectrogram = SpectrogramOperator(config)
        self._dct_matrix = self._create_dct_matrix()
    
    def _create_dct_matrix(self) -> np.ndarray:
        """Create DCT matrix"""
        n_filters = self.config.n_mels
        n_coeff = self.config.n_mfcc
        
        # DCT type II
        dct_matrix = np.zeros((n_coeff, n_filters))
        for k in range(n_coeff):
            dct_matrix[k, :] = np.cos(np.arange(n_filters) * (k + 0.5) * np.pi / n_filters)
        
        # Orthogonalize
        dct_matrix *= np.sqrt(2.0 / n_filters)
        dct_matrix[0, :] *= 0.5
        
        return dct_matrix
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate MFCC from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            MFCC array (n_mfcc, time_frames)
        """
        # Calculate spectrogram
        spectrogram = self.spectrogram.apply(audio_data)
        
        # Convert to Mel scale
        if self.config.n_mels > 0:
            mel_spec = spectrogram
        else:
            mel_spec = spectrogram
        
        # Apply log compression
        log_spec = np.log(mel_spec + 1e-8)
        
        # Apply DCT
        mfcc = self._dct_matrix @ log_spec
        
        # Apply liftering (optional)
        if hasattr(self.config, 'liftering') and self.config.liftering > 0:
            n_coeff = self.config.n_mfcc
            lifter = np.sin(np.pi * np.arange(n_coeff) / self.config.liftering)
            lifter[0] = 1.0
            mfcc *= lifter[:, np.newaxis]
        
        return mfcc


class ChromaOperator(AudioOperator):
    """Chroma feature extraction operator"""
    
    def __init__(self, n_chroma: int = 12, config: Optional[AudioConfig] = None):
        """
        Initialize chroma operator
        
        Args:
            n_chroma: Number of chroma bins
            config: Audio configuration
        """
        super().__init__(config)
        self.n_chroma = n_chroma
        self._chroma_filters = self._create_chroma_filters()
    
    def _create_chroma_filters(self) -> np.ndarray:
        """Create chroma filter bank"""
        # Create frequency bins
        n_freq = self.config.n_fft // 2 + 1
        chroma_filters = np.zeros((self.n_chroma, n_freq))
        
        # Calculate frequency resolution
        freq_resolution = self.config.sample_rate / self.config.n_fft
        
        # Create chroma filters based on actual frequency mapping
        for i in range(n_freq):
            # Convert bin number to frequency
            freq = i * freq_resolution
            
            # Handle DC bin (0 Hz) - map to first chroma bin
            if freq == 0:
                chroma_idx = 0
            else:
                # Calculate chroma bin (modulo 12 semitones)
                # Add small epsilon to avoid division by zero
                try:
                    chroma_idx = int(12 * np.log2(freq / 440.0) + 69) % self.n_chroma
                except:
                    # Fallback to first chroma bin for problematic frequencies
                    chroma_idx = 0
            
            # Ensure chroma index is within bounds
            chroma_idx = max(0, min(chroma_idx, self.n_chroma - 1))
            
            # Set filter value
            chroma_filters[chroma_idx, i] = 1.0
        
        # Smooth filters for better frequency response
        try:
            from scipy.ndimage import gaussian_filter1d
            chroma_filters = gaussian_filter1d(chroma_filters, sigma=1.5, axis=1)
        except ImportError:
            logger.warning("scipy not available for chroma filter smoothing")
            # Alternative smoothing using simple moving average
            kernel_size = 3
            for c in range(self.n_chroma):
                padded = np.pad(chroma_filters[c], (kernel_size//2, kernel_size//2), mode='edge')
                smoothed = np.convolve(padded, np.ones(kernel_size)/kernel_size, mode='valid')
                chroma_filters[c] = smoothed
        
        return chroma_filters
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate chroma features from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            Chroma array (n_chroma, time_frames)
        """
        # Create a spectrogram operator without Mel filtering for chroma
        spec_config = AudioConfig(
            sample_rate=self.config.sample_rate,
            window_type=self.config.window_type,
            n_fft=self.config.n_fft,
            power_spectrum=True,
            n_mels=0  # Disable Mel filtering for chroma
        )
        
        # Calculate raw spectrogram
        spectrogram = SpectrogramOperator(spec_config).apply(audio_data)
        
        # Apply chroma filters
        chroma = self._chroma_filters @ spectrogram
        
        # Normalize
        chroma = chroma / (np.max(chroma) + 1e-8)
        
        return chroma


class TonnetzOperator(AudioOperator):
    """Tonnetz (harmonic network) feature extraction operator"""
    
    def __init__(self, config: Optional[AudioConfig] = None):
        """
        Initialize Tonnetz operator
        
        Args:
            config: Audio configuration
        """
        super().__init__(config)
        # Use 12 chroma bins for compatibility with Tonnetz transformation
        self.chroma = ChromaOperator(12, config)
        
        # Tonnetz transformation matrix
        self._tonnetz_matrix = self._create_tonnetz_matrix()
    
    def _create_tonnetz_matrix(self) -> np.ndarray:
        """Create Tonnetz transformation matrix"""
        # First dimension: fifths
        # Second dimension: thirds
        tonnetz = np.zeros((6, 12))
        
        # Fifth transformation
        tonnetz[0, :] = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]
        tonnetz[1, :] = [0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0]
        tonnetz[2, :] = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0]
        
        # Third transformation
        tonnetz[3, :] = [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]
        tonnetz[4, :] = [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0]
        tonnetz[5, :] = [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1]
        
        return tonnetz
    
    def _validate_chroma_input(self, chroma: np.ndarray) -> np.ndarray:
        """
        Validate and prepare chroma input for Tonnetz transformation
        
        Args:
            chroma: Input chroma array
            
        Returns:
            Validated chroma array
        """
        # Ensure chroma has 12 bins
        if chroma.shape[0] != 12:
            if chroma.shape[0] > 12:
                # Downsample by averaging
                chroma = np.mean(chroma.reshape(12, -1), axis=1)
            else:
                # Upsample by repeating
                repeat_factor = 12 // chroma.shape[0]
                remainder = 12 % chroma.shape[0]
                chroma = np.repeat(chroma, repeat_factor, axis=0)
                if remainder > 0:
                    chroma = np.concatenate([chroma, chroma[:remainder]], axis=0)
            
            # Normalize
            chroma = chroma / (np.sum(chroma) + 1e-8)
        
        return chroma
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate Tonnetz features from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            Tonnetz array (6, time_frames)
        """
        # Calculate chroma features
        chroma = self.chroma.apply(audio_data)
        
        # Apply Tonnetz transformation
        tonnetz = self._tonnetz_matrix @ chroma
        
        return tonnetz


class SpectralContrastOperator(AudioOperator):
    """Spectral contrast feature extraction operator"""
    
    def __init__(self, n_bands: int = 6, config: Optional[AudioConfig] = None):
        """
        Initialize spectral contrast operator
        
        Args:
            n_bands: Number of spectral contrast bands
            config: Audio configuration
        """
        super().__init__(config)
        self.n_bands = n_bands
        self._freq_bands = self._create_frequency_bands()
    
    def _create_frequency_bands(self) -> List[Tuple[int, int]]:
        """Create frequency bands for contrast calculation"""
        nyquist = self.config.sample_rate / 2
        n_freq = self.config.n_fft // 2 + 1
        
        # Create logarithmic frequency bands
        bands = []
        freq_bins_per_band = n_freq // (self.n_bands + 1)
        
        for i in range(self.n_bands):
            start = (i + 1) * freq_bins_per_band
            end = (i + 2) * freq_bins_per_band
            bands.append((start, min(end, n_freq)))
        
        return bands
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate spectral contrast from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            Spectral contrast array (n_bands + 1, time_frames)
        """
        # Calculate spectrogram
        spectrogram = SpectrogramOperator(self.config).apply(audio_data)
        
        # Calculate spectral contrast
        contrast = np.zeros((self.n_bands + 1, spectrogram.shape[1]))
        
        for i, (start, end) in enumerate(self._freq_bands):
            # Mean energy in band
            band_energy = np.mean(spectrogram[start:end, :], axis=0)
            
            # Peak energy in band
            band_peak = np.max(spectrogram[start:end, :], axis=0)
            
            # Contrast = peak - mean
            contrast[i, :] = band_peak - band_energy
        
        # Overall energy (DC + low frequencies)
        contrast[-1, :] = np.mean(spectrogram[:self._freq_bands[0][0], :], axis=0)
        
        return contrast


class ZeroCrossingRateOperator(AudioOperator):
    """Zero crossing rate calculation operator"""
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate zero crossing rate from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            Zero crossing rate array (time_frames,)
        """
        # Ensure mono
        if len(audio_data.shape) > 1:
            audio_data = np.mean(audio_data, axis=1)
        
        # Calculate zero crossings
        zero_crossings = np.abs(np.diff(np.sign(audio_data)))
        
        # Frame the signal
        hop_length = self.config.hop_length
        win_length = self.config.win_length
        
        # Calculate ZCR for each frame
        n_frames = 1 + (len(audio_data) - win_length) // hop_length
        zcr = np.zeros(n_frames)
        
        for i in range(n_frames):
            start = i * hop_length
            end = start + win_length
            frame = audio_data[start:end]
            frame_zcr = np.sum(zero_crossings[start:end-1]) / len(frame)
            zcr[i] = frame_zcr
        
        return zcr[np.newaxis, :]  # Return as (1, n_frames) for consistency


class EnergyOperator(AudioOperator):
    """Energy calculation operator"""
    
    def apply(self, audio_data: np.ndarray) -> np.ndarray:
        """
        Calculate energy from audio data
        
        Args:
            audio_data: Input audio array (samples,)
            
        Returns:
            Energy array (time_frames,)
        """
        # Ensure mono
        if len(audio_data.shape) > 1:
            audio_data = np.mean(audio_data, axis=1)
        
        # Frame the signal
        hop_length = self.config.hop_length
        win_length = self.config.win_length
        
        # Calculate energy for each frame
        n_frames = 1 + (len(audio_data) - win_length) // hop_length
        energy = np.zeros(n_frames)
        
        for i in range(n_frames):
            start = i * hop_length
            end = start + win_length
            frame = audio_data[start:end]
            energy[i] = np.sum(frame ** 2)
        
        return energy[np.newaxis, :]  # Return as (1, n_frames) for consistency


