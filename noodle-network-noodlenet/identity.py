"""
Noodle Network Noodlenet::Identity - identity.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Node identiteit en identificatie voor NoodleNet
"""

import uuid
import hashlib
import platform
import time
import logging
from typing import Optional, Dict, Any
from dataclasses import dataclass, field
from .config import NoodleNetConfig

logger = logging.getLogger(__name__)


@dataclass
class NodeIdentity:
    """Unieke identiteit voor een NoodleNet node"""
    
    # Basis informatie
    node_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    hostname: str = field(default="")
    platform_info: Dict[str, str] = field(default_factory=dict)
    
    # Tijdstempels
    created_at: float = field(default_factory=time.time)
    last_seen: float = field(default_factory=time.time)
    
    # Capabilities
    capabilities: Dict[str, Any] = field(default_factory=dict)
    
    # Metadata
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        """Initialiseer platform informatie als niet gespecificeerd"""
        if not self.hostname:
            self.hostname = platform.node()
        
        if not self.platform_info:
            self.platform_info = {
                'system': platform.system(),
                'release': platform.release(),
                'version': platform.version(),
                'machine': platform.machine(),
                'processor': platform.processor(),
                'python_version': platform.python_version(),
            }
    
    def update_last_seen(self):
        """Update het laatste gezien tijdstempel"""
        self.last_seen = time.time()
    
    def add_capability(self, capability: str, value: Any = None):
        """
        Voeg een capability toe aan de node
        
        Args:
            capability: Naam van de capability
            value: Waarde van de capability (optioneel)
        """
        self.capabilities[capability] = value
    
    def remove_capability(self, capability: str):
        """
        Verwijder een capability van de node
        
        Args:
            capability: Naam van de capability om te verwijderen
        """
        if capability in self.capabilities:
            del self.capabilities[capability]
    
    def has_capability(self, capability: str) -> bool:
        """
        Controleer of de node een bepaalde capability heeft
        
        Args:
            capability: Naam van de capability
            
        Returns:
            True als de capability aanwezig is
        """
        return capability in self.capabilities
    
    def get_capability(self, capability: str, default=None):
        """
        Krijg de waarde van een capability
        
        Args:
            capability: Naam van de capability
            default: Standaardwaarde als capability niet bestaat
            
        Returns:
            Waarde van de capability of default
        """
        return self.capabilities.get(capability, default)
    
    def add_metadata(self, key: str, value: Any):
        """
        Voeg metadata toe aan de node
        
        Args:
            key: Metadata key
            value: Metadata waarde
        """
        self.metadata[key] = value
    
    def get_metadata(self, key: str, default=None):
        """
        Krijg metadata waarde
        
        Args:
            key: Metadata key
            default: Standaardwaarde als key niet bestaat
            
        Returns:
            Metadata waarde of default
        """
        return self.metadata.get(key, default)
    
    def to_dict(self) -> Dict[str, Any]:
        """
        Converteer identity naar dictionary
        
        Returns:
            Dictionary met identity data
        """
        return {
            'node_id': self.node_id,
            'hostname': self.hostname,
            'platform_info': self.platform_info,
            'created_at': self.created_at,
            'last_seen': self.last_seen,
            'capabilities': self.capabilities,
            'metadata': self.metadata,
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "NodeIdentity":
        """
        Maak NodeIdentity vanaf dictionary
        
        Args:
            data: Dictionary met identity data
            
        Returns:
            NodeIdentity instance
        """
        return cls(
            node_id=data.get('node_id', str(uuid.uuid4())),
            hostname=data.get('hostname', ''),
            platform_info=data.get('platform_info', {}),
            created_at=data.get('created_at', time.time()),
            last_seen=data.get('last_seen', time.time()),
            capabilities=data.get('capabilities', {}),
            metadata=data.get('metadata', {}),
        )
    
    def generate_hash(self) -> str:
        """
        Genereer een unieke hash voor deze node identity
        
        Returns:
            SHA256 hash string
        """
        identity_str = f"{self.node_id}:{self.hostname}:{time.time()}"
        return hashlib.sha256(identity_str.encode()).hexdigest()
    
    def age(self) -> float:
        """
        Krijg de leeftijd van de node identity in seconden
        
        Returns:
            Leeftijd in seconden
        """
        return time.time() - self.created_at
    
    def is_stale(self, timeout: float) -> bool:
        """
        Controleer of de identity verouderd is
        
        Args:
            timeout: Timeout in seconden
            
        Returns:
            True als identity verouderd is
        """
        return (time.time() - self.last_seen) > timeout
    
    def __str__(self) -> str:
        """String representatie van de identity"""
        return f"Node({self.node_id[:8]}...@{self.hostname})"
    
    def __repr__(self) -> str:
        """String representatie voor debugging"""
        return (f"NodeIdentity(node_id='{self.node_id}', hostname='{self.hostname}', "
                f"created_at={self.created_at}, capabilities={len(self.capabilities)})")


class NoodleIdentityManager:
    """Manager voor node identiteiten in het netwerk"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de identity manager
        
        Args:
            config: NoodleNet configuratie
        """
        self.config = config or NoodleNetConfig()
        self.local_identity: Optional[NodeIdentity] = None
        self.known_nodes: Dict[str, NodeIdentity] = {}
        self._lock = None  # Initialiseer lock naar None voor nu
    
    async def initialize(self):
        """Initialiseer de identity manager"""
        if not self.local_identity:
            self.create_local_identity()
        
        logger.info("NoodleIdentityManager initialized")
    
    def create_local_identity(self, capabilities: Optional[Dict[str, Any]] = None,
                            metadata: Optional[Dict[str, Any]] = None) -> NodeIdentity:
        """
        Maak een lokale node identity
        
        Args:
            capabilities: Capabilities van de node
            metadata: Metadata van de node
            
        Returns:
            GecreÃ«erde NodeIdentity
        """
        self.local_identity = NodeIdentity()
        
        # Voeg standaard capabilities toe
        self.local_identity.add_capability("discovery", True)
        self.local_identity.add_capability("communication", True)
        
        # Voeg gebruikersspecificatie capabilities toe
        if capabilities:
            for cap, value in capabilities.items():
                self.local_identity.add_capability(cap, value)
        
        # Voeg metadata toe
        if metadata:
            for key, value in metadata.items():
                self.local_identity.add_metadata(key, value)
        
        return self.local_identity
    
    def get_local_identity(self) -> Optional[NodeIdentity]:
        """
        Krijg de lokale node identity
        
        Returns:
            Lokale NodeIdentity of None als niet ingesteld
        """
        return self.local_identity
    
    def register_node(self, identity: NodeIdentity) -> bool:
        """
        Registreer een nieuwe node in het netwerk
        
        Args:
            identity: NodeIdentity om te registreren
            
        Returns:
            True als succesvol registreren
        """
        if not identity or not identity.node_id:
            return False
        
        # Update last seen tijdstempel
        identity.update_last_seen()
        
        # Voeg toe aan bekende nodes
        self.known_nodes[identity.node_id] = identity
        
        return True
    
    def unregister_node(self, node_id: str) -> bool:
        """
        Verwijder een node uit het netwerk
        
        Args:
            node_id: ID van de node om te verwijderen
            
        Returns:
            True als succesvol verwijderen
        """
        if node_id in self.known_nodes:
            del self.known_nodes[node_id]
            return True
        return False
    
    def get_node(self, node_id: str) -> Optional[NodeIdentity]:
        """
        Krijg een specifieke node identity
        
        Args:
            node_id: ID van de node
            
        Returns:
            NodeIdentity of None als niet gevonden
        """
        return self.known_nodes.get(node_id)
    
    def get_nodes_by_capability(self, capability: str) -> Dict[str, NodeIdentity]:
        """
        Krijg alle nodes met een bepaalde capability
        
        Args:
            capability: Capability om te zoeken
            
        Returns:
            Dictionary met node_id -> NodeIdentity
        """
        return {node_id: identity for node_id, identity in self.known_nodes.items()
                if identity.has_capability(capability)}
    
    def get_all_nodes(self) -> Dict[str, NodeIdentity]:
        """
        Krijg alle bekende nodes
        
        Returns:
            Dictionary met alle node identities
        """
        return self.known_nodes.copy()
    
    def update_node_last_seen(self, node_id: str) -> bool:
        """
        Update het laatste gezien tijdstempel voor een node
        
        Args:
            node_id: ID van de node
            
        Returns:
            True als succesvol update
        """
        node = self.get_node(node_id)
        if node:
            node.update_last_seen()
            return True
        return False
    
    def remove_stale_nodes(self, timeout: Optional[float] = None) -> int:
        """
        Verwijder verouderde nodes uit het register
        
        Args:
            timeout: Timeout in seconden, gebruikt configuratie waarde als None
            
        Returns:
            Aantal verwijderde nodes
        """
        if timeout is None:
            timeout = self.config.heartbeat_timeout
        
        stale_nodes = [
            node_id for node_id, identity in self.known_nodes.items()
            if identity.is_stale(timeout)
        ]
        
        for node_id in stale_nodes:
            self.unregister_node(node_id)
        
        return len(stale_nodes)
    
    def get_node_count(self) -> int:
        """
        Krijg het aantal bekende nodes
        
        Returns:
            Aantal bekende nodes
        """
        return len(self.known_nodes)
    
    def find_nodes_by_hostname(self, hostname: str) -> Dict[str, NodeIdentity]:
        """
        Vind nodes op basis van hostname
        
        Args:
            hostname: Hostname om te zoeken
            
        Returns:
            Dictionary met matching nodes
        """
        return {node_id: identity for node_id, identity in self.known_nodes.items()
                if identity.hostname == hostname}
    
    def get_capabilities_summary(self) -> Dict[str, int]:
        """
        Krijg een samenvatting van alle capabilities in het netwerk
        
        Returns:
            Dictionary met capability -> aantal nodes
        """
        summary = {}
        
        for identity in self.known_nodes.values():
            for cap in identity.capabilities:
                summary[cap] = summary.get(cap, 0) + 1
        
        return summary
    
    def to_dict(self) -> Dict[str, Any]:
        """
        Converteer de manager status naar dictionary
        
        Returns:
            Dictionary met manager data
        """
        return {
            'local_identity': self.local_identity.to_dict() if self.local_identity else None,
            'known_nodes': {node_id: identity.to_dict() 
                           for node_id, identity in self.known_nodes.items()},
            'node_count': self.get_node_count(),
            'capabilities_summary': self.get_capabilities_summary(),
        }
    
    def from_dict(self, data: Dict[str, Any]):
        """
        Laad manager status vanaf dictionary
        
        Args:
            data: Dictionary met manager data
        """
        # Herstel lokale identity
        if 'local_identity' in data and data['local_identity']:
            self.local_identity = NodeIdentity.from_dict(data['local_identity'])
        
        # Herstel bekende nodes
        self.known_nodes.clear()
        if 'known_nodes' in data:
            for node_id, node_data in data['known_nodes'].items():
                self.known_nodes[node_id] = NodeIdentity.from_dict(node_data)
    
    def __len__(self) -> int:
        """Krijg het aantal bekende nodes"""
        return self.get_node_count()
    
    def __contains__(self, node_id: str) -> bool:
        """Controleer of een node ID bekend is"""
        return node_id in self.known_nodes
    
    def __str__(self) -> str:
        """String representatie van de manager"""
        return f"NoodleIdentityManager(nodes={len(self.known_nodes)})"


