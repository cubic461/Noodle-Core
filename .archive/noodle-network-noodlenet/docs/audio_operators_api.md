# NoodleVision Audio Operators API Reference

This document provides detailed API documentation for all audio operators in NoodleVision.

## Overview

NoodleVision provides a comprehensive set of audio processing operators for feature extraction and analysis. These operators are designed to be efficient, robust, and easy to use.

## Audio Operators

### SpectrogramOperator

Computes the spectrogram of an audio signal using Short-Time Fourier Transform (STFT).

```python
from noodlenet.vision.ops_audio import SpectrogramOperator

# Initialize operator
spectrogram = SpectrogramOperator(
    window_size=2048,
    hop_length=512,
    n_fft=2048,
    power=2.0,
    center=True,
    pad_mode='reflect'
)

# Process audio
audio = np.random.randn(22050)  # 1 second of audio
spectrogram_result = spectrogram(audio)
```

#### Parameters

- **window_size** (`int`): Size of the analysis window in samples. Default: 2048
- **hop_length** (`int`): Number of samples between successive frames. Default: 512
- **n_fft** (`int`): Size of the FFT. Default: 2048
- **power** (`float`): Exponent for the magnitude spectrogram. Default: 2.0
- **center** (`bool`): Whether to pad the signal on both sides. Default: True
- **pad_mode** (`str`): Padding mode. Options: 'reflect', 'constant', 'edge', 'linear_ramp'. Default: 'reflect'

#### Returns

- `np.ndarray`: Complex-valued spectrogram with shape `(n_freqs, n_frames)`

#### Example Usage

```python
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator

# Create audio signal
sample_rate = 22050
duration = 2.0
audio = np.random.randn(int(sample_rate * duration))

# Initialize spectrogram operator
spec_op = SpectrogramOperator(
    window_size=1024,
    hop_length=256,
    n_fft=1024
)

# Compute spectrogram
spectrogram = spec_op(audio)

print(f"Spectrogram shape: {spectrogram.shape}")
print(f"Frequency bins: {spectrogram.shape[0]}")
print(f"Time frames: {spectrogram.shape[1]}")
```

### MFCCOperator

Computes Mel-Frequency Cepstral Coefficients (MFCCs) from an audio signal.

```python
from noodlenet.vision.ops_audio import MFCCOperator

# Initialize operator
mfcc = MFCCOperator(
    n_mfcc=13,
    n_fft=2048,
    hop_length=512,
    win_length=None,
    window='hann',
    n_mels=128,
    fmin=0.0,
    fmax=None,
    htk=False,
    norm='ortho'
)

# Process audio
audio = np.random.randn(22050)  # 1 second of audio
mfcc_result = mfcc(audio)
```

#### Parameters

- **n_mfcc** (`int`): Number of MFCCs to return. Default: 13
- **n_fft** (`int`): Number of FFT points. Default: 2048
- **hop_length** (`int`): Hop length for STFT. Default: 512
- **win_length** (`int`): Window length for STFT. Default: None (uses n_fft)
- **window** (`str`): Window function. Default: 'hann'
- **n_mels** (`int`): Number of mel bands. Default: 128
- **fmin** (`float`): Minimum frequency. Default: 0.0
- **fmax** (`float`): Maximum frequency. Default: None (uses sample_rate/2)
- **htk** (`bool`): Use HTK formula instead of Slaney. Default: False
- **norm** (`str`): Normalization. Options: None, 'ortho', 'slaney'. Default: 'ortho'

#### Returns

- `np.ndarray`: MFCC coefficients with shape `(n_mfcc, n_frames)`

#### Example Usage

```python
import numpy as np
from noodlenet.vision.ops_audio import MFCCOperator

# Create audio signal
sample_rate = 22050
duration = 3.0
audio = np.random.randn(int(sample_rate * duration))

# Initialize MFCC operator
mfcc_op = MFCCOperator(
    n_mfcc=13,
    n_fft=2048,
    hop_length=512,
    n_mels=128
)

# Compute MFCCs
mfccs = mfcc_op(audio)

print(f"MFCC shape: {mfccs.shape}")
print(f"Number of coefficients: {mfccs.shape[0]}")
print(f"Number of frames: {mfccs.shape[1]}")
```

### ChromaOperator

Computes chroma features from an audio signal.

```python
from noodlenet.vision.ops_audio import ChromaOperator

# Initialize operator
chroma = ChromaOperator(
    n_chroma=12,
    n_fft=2048,
    hop_length=512,
    win_length=None,
    window='hann',
    tuning=0.0,
    norm=2
)

# Process audio
audio = np.random.randn(22050)  # 1 second of audio
chroma_result = chroma(audio)
```

#### Parameters

- **n_chroma** (`int`): Number of chroma bins. Default: 12
- **n_fft** (`int`): Number of FFT points. Default: 2048
- **hop_length** (`int`): Hop length for STFT. Default: 512
- **win_length** (`int`): Window length for STFT. Default: None (uses n_fft)
- **window** (`str`): Window function. Default: 'hann'
- **tuning** (`float`): Deviation from A440 tuning in fractional chroma bins. Default: 0.0
- **norm** (`int` or `float`): Normalization. Default: 2

#### Returns

- `np.ndarray`: Chroma features with shape `(n_chroma, n_frames)`

#### Example Usage

```python
import numpy as np
from noodlenet.vision.ops_audio import ChromaOperator

# Create audio signal
sample_rate = 22050
duration = 4.0
audio = np.random.randn(int(sample_rate * duration))

# Initialize chroma operator
chroma_op = ChromaOperator(
    n_chroma=12,
    n_fft=2048,
    hop_length=512
)

# Compute chroma features
chroma = chroma_op(audio)

print(f"Chroma shape: {chroma.shape}")
print(f"Number of chroma bins: {chroma.shape[0]}")
print(f"Number of frames: {chroma.shape[1]}")
```

### TonnetzOperator

Computes Tonnetz (harmonic network) features from audio.

```python
from noodlenet.vision.ops_audio import TonnetzOperator

# Initialize operator
tonnetz = TonnetzOperator(
    n_tonnetz=6,
    chroma_operator=None  # Will create default ChromaOperator
)

# Process audio
audio = np.random.randn(22050)  # 1 second of audio
tonnetz_result = tonnetz(audio)
```

#### Parameters

- **n_tonnetz** (`int`): Number of Tonnetz dimensions. Default: 6
- **chroma_operator** (`ChromaOperator`): Chroma operator to use. Default: None (creates default)

#### Returns

- `np.ndarray`: Tonnetz features with shape `(n_tonnetz, n_frames)`

#### Example Usage

```python
import numpy as np
from noodlenet.vision.ops_audio import TonnetzOperator

# Create audio signal
sample_rate = 22050
duration = 5.0
audio = np.random.randn(int(sample_rate * duration))

# Initialize Tonnetz operator
tonnetz_op = TonnetzOperator(n_tonnetz=6)

# Compute Tonnetz features
tonnetz = tonnetz_op(audio)

print(f"Tonnetz shape: {tonnetz.shape}")
print(f"Number of Tonnetz dimensions: {tonnetz.shape[0]}")
print(f"Number of frames: {tonnetz.shape[1]}")
```

## Usage Patterns

### Basic Processing

```python
import numpy as np
from noodlenet.vision.ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator

# Create test audio
sample_rate = 22050
duration = 10.0
audio = np.random.randn(int(sample_rate * duration))

# Initialize all operators
operators = {
    'Spectrogram': SpectrogramOperator(),
    'MFCC': MFCCOperator(n_mfcc=13),
    'Chroma': ChromaOperator(),
    'Tonnetz': TonnetzOperator()
}

# Process audio with each operator
results = {}
for name, operator in operators.items():
    results[name] = operator(audio)
    print(f"{name} shape: {results[name].shape}")
```

### Pipeline Processing

```python
def extract_audio_features(audio, sample_rate):
    """Extract comprehensive audio features"""
    features = {}
    
    # Basic operators
    features['spectrogram'] = SpectrogramOperator()(audio)
    features['mfcc'] = MFCCOperator(n_mfcc=13)(audio)
    features['chroma'] = ChromaOperator()(audio)
    features['tonnetz'] = TonnetzOperator()(audio)
    
    # Additional features can be computed from spectrogram
    magnitude = np.abs(features['spectrogram'])
    features['magnitude'] = magnitude
    features['phase'] = np.angle(features['spectrogram'])
    
    return features

# Usage
audio = np.random.randn(22050 * 5)  # 5 seconds
features = extract_audio_features(audio, 22050)
```

### Memory Management Integration

```python
from noodlenet.vision.memory import MemoryManager, MemoryPolicy

# Initialize memory manager
manager = MemoryManager(policy=MemoryPolicy.BALANCED)

# Process audio with memory management
audio = np.random.randn(22050 * 10)  # 10 seconds

# Allocate memory for features
spectrogram_shape = (1025, 431)  # Example shape
mfcc_shape = (13, 431)

spec_memory = manager.allocate_tensor(spectrogram_shape, np.float32)
mfcc_memory = manager.allocate_tensor(mfcc_shape, np.float32)

# Compute features
spec_op = SpectrogramOperator()
mfcc_op = MFCCOperator()

spec_memory[:] = spec_op(audio)
mfcc_memory[:] = mfcc_op(audio)

# Free memory when done
manager.free_tensor(spec_memory)
manager.free_tensor(mfcc_memory)
```

## Performance Considerations

### Memory Usage
- Spectrogram: O(n_fft * n_frames) - Can be memory intensive for long signals
- MFCC: O(n_mfcc * n_frames) - Generally memory efficient
- Chroma: O(n_chroma * n_frames) - Memory efficient
- Tonnetz: O(n_tonnetz * n_frames) - Memory efficient

### Processing Time
- Processing time is primarily determined by the STFT computation
- Use appropriate hop_length for desired time resolution
- Smaller window sizes provide better time resolution but poorer frequency resolution

### Optimization Tips
1. **Reuse Operators**: Initialize operators once and reuse them
2. **Batch Processing**: Process multiple audio files in batch when possible
3. **Memory Management**: Use MemoryManager for large audio files
4. **Appropriate Window Sizes**: Choose window sizes based on your application needs

## Error Handling

The operators are designed to handle common errors gracefully:

```python
try:
    # Very short audio
    short_audio = np.random.randn(100)
    mfcc = MFCCOperator()(short_audio)
    print("Processed short audio successfully")
    
except Exception as e:
    print(f"Error processing audio: {e}")
    
# Zero audio
zero_audio = np.zeros(22050)
chroma = ChromaOperator()(zero_audio)  # Returns zero chroma features
```

## Best Practices

1. **Input Validation**: Ensure audio is 1D numpy array
2. **Sample Rate**: Know your sample rate for proper frequency interpretation
3. **Normalization**: Consider normalizing audio input if needed
4. **Parameter Selection**: Choose parameters appropriate for your use case
5. **Memory Monitoring**: Use MemoryManager for long audio processing sessions
