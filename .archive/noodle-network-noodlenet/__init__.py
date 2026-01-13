"""
Noodle Network Noodlenet::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleNet - Zelforganiserend mesh-netwerk voor NoodleCore

Dit package biedt de infrastructuur voor gedistribueerde computing met:
- Automatische node discovery
- Betrouwbare communicatie
- Slimme taakverdeling
- Zelfoptimalisatie
"""

from .link import NoodleLink
from .discovery import NoodleDiscovery
from .identity import NodeIdentity, NoodleIdentityManager
from .mesh import NoodleMesh
from .config import NoodleNetConfig

__version__ = "0.1.0"
__all__ = [
    "NoodleLink", 
    "NoodleDiscovery", 
    "NodeIdentity", 
    "NoodleIdentityManager",
    "NoodleMesh",
    "NoodleNetConfig"
]


