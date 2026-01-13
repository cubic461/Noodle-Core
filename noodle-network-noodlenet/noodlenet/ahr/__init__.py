"""
Ahr::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Adaptive Hybrid Runtime (AHR) - Zelforganiserende optimalisatie voor AI-modellen

Dit package biedt geavanceerde performance monitoring en optimalisatie:
- Performance profiling met hotspot detectie
- JIT/AOT compilatie naar NBC code
- Beslis engine voor optimalisatie keuzes
- Model lifecycle management
"""

from .ahr_base import (
    AHRBase,
    ExecutionMode,
    ModelComponent,
    ModelProfile,
    ExecutionMetrics
)
from .profiler import PerformanceProfiler, ProfileSession
from .compiler import ModelCompiler, CompilationTask, CompilationStage
from .optimizer import (
    AHRDecisionOptimizer,
    OptimizationDecision,
    OptimizationReason,
    OptimizationRule,
    OptimizationMetric
)

__version__ = "0.1.0"
__all__ = [
    "AHRBase",
    "ExecutionMode", 
    "ModelComponent",
    "ModelProfile",
    "ExecutionMetrics",
    "PerformanceProfiler",
    "ProfileSession",
    "ModelCompiler",
    "CompilationTask",
    "CompilationStage",
    "AHRDecisionOptimizer",
    "OptimizationDecision",
    "OptimizationReason", 
    "OptimizationRule",
    "OptimizationMetric"
]


