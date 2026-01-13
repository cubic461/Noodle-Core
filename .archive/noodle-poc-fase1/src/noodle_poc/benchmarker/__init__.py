"""
NoodleCore Fase 2: Benchmarking Module
Compares staged execution performance against native PyTorch.
"""

from .core import ExecutionBenchmarker, BenchmarkResults

__all__ = [
    'ExecutionBenchmarker',
    'BenchmarkResults',
]
