"""
Hardware capability matching and device selection.
"""

from .core import (
    DeviceType,
    HardwareCapability,
    LayerRequirements,
    CapabilityMatcher,
    auto_detect_capabilities,
    create_requirement_from_metrics,
)

__version__ = "0.1.0"
__all__ = [
    'DeviceType',
    'HardwareCapability',
    'LayerRequirements',
    'CapabilityMatcher',
    'auto_detect_capabilities',
    'create_requirement_from_metrics',
]
