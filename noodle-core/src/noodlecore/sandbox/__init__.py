"""Sandbox execution environment for NIP.

This package provides safe command execution with allowlist-based
validation and resource limits.
"""

from .runner import SandboxRunner, SafeShell
from .allowlist import AllowListManager, PresetProfiles

__all__ = [
    "SandboxRunner",
    "SafeShell",
    "AllowListManager",
    "PresetProfiles"
]

__version__ = "1.0.0"
