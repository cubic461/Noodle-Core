"""
Noodlenet::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleNet - Distributed communication protocol for NoodleCore.

This package provides the core networking infrastructure for NoodleCore,
including node discovery, mesh routing, and secure communication.
"""

from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .link import NoodleLink, Message
from .mesh import NoodleMesh, NodeMetrics, MeshTopology
from .discovery import NoodleDiscovery, DiscoveryMessage

__version__ = "1.0.0"
__all__ = [
    "NoodleNetConfig",
    "NodeIdentity", 
    "NoodleIdentityManager",
    "NoodleLink",
    "Message",
    "NoodleMesh",
    "NodeMetrics",
    "MeshTopology",
    "NoodleDiscovery",
    "DiscoveryMessage"
]


