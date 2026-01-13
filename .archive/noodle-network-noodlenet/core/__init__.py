"""
Core::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Integration Package - Directe integratie met NoodleCore native uitvoering

Dit package biedt volledige integratie met NoodleCore:
- Directe uitvoering van native code en AI-modellen
- Compilatie van high-level componenten naar NBC code
- Performance monitoring en optimalisatie
- Distributie van taken over het netwerk
"""

from .interface import (
    NoodleCoreInterface,
    ExecutionType,
    NoodleCoreRequest,
    NoodleCoreResponse
)
from .compiler_bridge import (
    NoodleCoreCompilerBridge,
    CompilerTarget,
    CompilationRequest,
    CompilationResult
)

__version__ = "0.1.0"
__all__ = [
    "NoodleCoreInterface",
    "ExecutionType",
    "NoodleCoreRequest",
    "NoodleCoreResponse",
    "NoodleCoreCompilerBridge",
    "CompilerTarget",
    "CompilationRequest",
    "CompilationResult"
]


