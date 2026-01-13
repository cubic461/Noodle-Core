"""
NoodleCore Fase 2: Stage Simulation Module
Simulates multi-node execution on a single machine using virtual nodes.
"""

from .core import StagedSimulator, VirtualNode, ExecutionTrace

__all__ = [
    'StagedSimulator',
    'VirtualNode',
    'ExecutionTrace',
]
