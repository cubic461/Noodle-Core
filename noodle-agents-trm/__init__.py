"""
TRM Agent for NoodleCore - Self-optimization & Transpiler

This package implements a Tiny Recursive Model (TRM) based agent
that can parse Python code, translate to NoodleCore IR, optimize,
and learn from feedback.
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

from .agent import TRMAgent
from .parser import TRMParser
from .translator import TRMTranslator
from .optimizer import TRMOptimizer
from .feedback import TRMFeedback

__version__ = "0.1.0"
__author__ = "NoodleCore Team"
__email__ = "team@noodlenet.ai"

__all__ = [
    'TRMAgent',
    'TRMParser',
    'TRMTranslator',
    'TRMOptimizer',
    'TRMFeedback'
]
