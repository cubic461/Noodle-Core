"""
Noodle Network Noodlenet::Discovery - discovery.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Node discovery systeem voor NoodleNet - Multicast en Gossip protocol
"""

import asyncio
import time
import json
import logging
import random
from typing import Dict, Set, Optional, List, Callable, Any
from dataclasses import dataclass, asdict
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .link import NoodleLink, Message

logger = logging.getLogger(__name__)


@dataclass
class DiscoveryMessage:
    """Bericht structuur voor discovery protocol"""
    
    message_type: str  # "hello", "heartbeat", "gossip"
    sender_id: str
    timestamp: float
    payload: Dict[str, Any]
    
    def serialize(self) -> bytes:
        """Serialiseer discovery message naar bytes"""
        message_dict = asdict(self)
        return json.dumps(message_dict).encode('utf-8')
    
    @classmethod
    def deserialize(cls, data: bytes) -> "DiscoveryMessage":
        """Deserialiseer bytes naar DiscoveryMessage"""
        message_dict = json.loads(data.decode('utf-8'))
        return cls(**message_dict)


class NoodleDiscovery:
    """Node discovery systeem voor NoodleNet"""
    
    def __init__(self, link: NoodleLink, 
                 identity_manager: NoodleIdentityManager,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de discovery manager
        
        Args:
            link: NoodleLink instantie voor communicatie
            identity_manager: NoodleIdentityManager voor node register
            config: NoodleNet configuratie
        """
        self.link = link
        self.identity_manager = identity_manager
        self.config = config or NoodleNetConfig()
        
        # Discovery state
        self._running = False
        self._last_hello = 0
        self._last_gossip = 0
        self._gossip_counter = 0
        
        # Gossip ring
        self._gossip_partners: Set[str] = set()
        self._gossip_history: Dict[str, float] = {}  # node_id -> last_seen
        
        # Event handlers
        self._node_discovered_handler: Optional[Callable] = None
        self._node_lost_handler: Optional[Callable] = None
        
        # Statistieken
        self._stats = {
            'hello_sent': 0,
            'hello_received': 0,
            'heartbeat_sent': 0,
            'heartbeat_received': 0,
            'gossip_sent': 0,
            'gossip_received': 0,
            'nodes_discovered': 0,
            'nodes_lost': 0,
        }
    
    async def start(self):
        """Start het discovery systeem"""
        if self._running:
            logger.warning("Discovery is already running")
            return
        
        self._running = True
        
        # Stel lokale identity in als niet al gedaan
        if not self.identity_manager.get_local_identity():
            self.identity_manager.create_local_identity()
        
        # Koppel identity aan link
        local_identity = self.identity_manager.get_local_identity()
        self.link.set_local_identity(local_identity)
        
        # Registreer message handlers
        self.link.register_message_handler("hello", self._handle_hello)
        self.link.register_message_handler("heartbeat", self._handle_heartbeat)
        self.link.register_message_handler("gossip", self._handle_gossip)
        
        # Start discovery taken
        asyncio.create_task(self._discovery_loop())
        asyncio.create_task(self._heartbeat_loop())
        
        logger.info("Discovery system started")
    
    async def stop(self):
        """Stop het discovery systeem"""
        if not self._running:
            return
        
        self._running = False
        
        # Deregister message handlers
        self.link.unregister_message_handler("hello")
        self.link.unregister_message_handler("heartbeat")
        self.link.unregister_message_handler("gossip")
        
        logger.info("Discovery system stopped")
    
    async def broadcast_hello(self):
        """
        Broadcast een hello bericht om jezelf bekend te maken
        """
        if not self._running:
            logger.error("Cannot broadcast hello: Discovery is not running")
            return
        
        local_identity = self.identity_manager.get_local_identity()
        if not local_identity:
            logger.error("Cannot broadcast hello: No local identity")
            return
        
        # Maak hello message
        hello_msg = DiscoveryMessage(
            message_type="hello",
            sender_id=local_identity.node_id,
            timestamp=time.time(),
            payload={
                'hostname': local_identity.hostname,
                'capabilities': local_identity.capabilities,
                'metadata': local_identity.metadata
            }
        )
        
        # Broadcast via link
        from .link import Message as LinkMessage
        link_msg = LinkMessage(
            sender_id=local_identity.node_id,
            recipient_id=None,
            message_type="hello",
            payload=hello_msg.serialize()
        )
        
        await self.link.broadcast(link_msg)
        self._stats['hello_sent'] += 1
        
        logger.debug(f"Broadcast hello message from {local_identity.node_id}")
    
    async def _discovery_loop(self):
        """Hoofd discovery loop"""
        while self._running:
            try:
                # Stuur hello bericht op interval
                current_time = time.time()
                if current_time - self._last_hello >= self.config.heartbeat_interval:
                    await self.broadcast_hello()
                    self._last_hello = current_time
                
                # Voer gossip uit op interval
                if current_time - self._last_gossip >= self.config.heartbeat_interval:
                    await self._perform_gossip()
                    self._last_gossip = current_time
                
                # Verwijder verouderde nodes
                await self._cleanup_stale_nodes()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(1)
                
            except Exception as e:
                logger.error(f"Error in discovery loop: {e}")
                await asyncio.sleep(5)  # Wacht bij fout
    
    async def _heartbeat_loop(self):
        """Heartbeat loop voor node monitoring"""
        while self._running:
            try:
                # Stuur heartbeat naar bekende nodes
                await self._send_heartbeats()
                
                # Wacht voor volgende heartbeat
                await asyncio.sleep(self.config.heartbeat_interval)
                
            except Exception as e:
                logger.error(f"Error in heartbeat loop: {e}")
                await asyncio.sleep(5)
    
    async def _send_heartbeats(self):
        """Stuur heartbeats naar alle bekende nodes"""
        local_identity = self.identity_manager.get_local_identity()
        if not local_identity:
            return
        
        # Maak heartbeat message
        heartbeat_msg = DiscoveryMessage(
            message_type="heartbeat",
            sender_id=local_identity.node_id,
            timestamp=time.time(),
            payload={
                'node_count': self.identity_manager.get_node_count(),
                'capabilities': local_identity.capabilities
            }
        )
        
        # Broadcast heartbeat
        from .link import Message as LinkMessage
        link_msg = LinkMessage(
            sender_id=local_identity.node_id,
            recipient_id=None,
            message_type="heartbeat",
            payload=heartbeat_msg.serialize()
        )
        
        await self.link.broadcast(link_msg)
        self._stats['heartbeat_sent'] += 1
    
    async def _perform_gossip(self):
        """Voer gossip protocol uit"""
        local_identity = self.identity_manager.get_local_identity()
        if not local_identity:
            return
        
        # Selecteer willekeurige gossip partners
        known_nodes = self.identity_manager.get_all_nodes()
        potential_partners = list(known_nodes.keys() - {local_identity.node_id})
        
        if not potential_partners:
            # Geen partners, gebruik multicast
            await self._multicast_gossip()
            return
        
        # Selecteer 1-3 partners
        num_partners = min(random.randint(1, 3), len(potential_partners))
        partners = random.sample(potential_partners, num_partners)
        
        # Stuur gossip naar geselecteerde partners
        for partner_id in partners:
            await self._send_gossip(partner_id)
        
        # Update gossip partners
        self._gossip_partners.update(partners)
        self._gossip_counter += 1
        
        # Beperk grootte van gossip history
        if len(self._gossip_history) > 100:
            # Verwijder oudste entries
            oldest = min(self._gossip_history.items(), key=lambda x: x[1])
            del self._gossip_history[oldest[0]]
    
    async def _multicast_gossip(self):
        """Multicast gossip naar alle nodes"""
        local_identity = self.identity_manager.get_local_identity()
        if not local_identity:
            return
        
        # Maak gossip message
        gossip_msg = DiscoveryMessage(
            message_type="gossip",
            sender_id=local_identity.node_id,
            timestamp=time.time(),
            payload={
                'nodes': self._get_node_summary(),
                'gossip_id': self._gossip_counter
            }
        )
        
        # Broadcast via link
        from .link import Message as LinkMessage
        link_msg = LinkMessage(
            sender_id=local_identity.node_id,
            recipient_id=None,
            message_type="gossip",
            payload=gossip_msg.serialize()
        )
        
        await self.link.broadcast(link_msg)
        self._stats['gossip_sent'] += 1
    
    async def _send_gossip(self, partner_id: str):
        """Stuur gossip naar een specifieke partner"""
        local_identity = self.identity_manager.get_local_identity()
        if not local_identity:
            return
        
        partner_node = self.identity_manager.get_node(partner_id)
        if not partner_node:
            return
        
        # Maak gossip message
        gossip_msg = DiscoveryMessage(
            message_type="gossip",
            sender_id=local_identity.node_id,
            timestamp=time.time(),
            payload={
                'nodes': self._get_node_summary(),
                'gossip_id': self._gossip_counter,
                'target': partner_id
            }
        )
        
        # Stuur via directe communicatie
        from .link import Message as LinkMessage
        link_msg = LinkMessage(
            sender_id=local_identity.node_id,
            recipient_id=partner_id,
            message_type="gossip",
            payload=gossip_msg.serialize()
        )
        
        await self.link.send(partner_id, link_msg)
        self._stats['gossip_sent'] += 1
    
    def _get_node_summary(self) -> Dict[str, Dict]:
        """Krijg samenvatting van alle bekende nodes"""
        nodes = {}
        for node_id, identity in self.identity_manager.get_all_nodes().items():
            nodes[node_id] = {
                'hostname': identity.hostname,
                'capabilities': list(identity.capabilities.keys()),
                'last_seen': identity.last_seen,
                'age': identity.age()
            }
        return nodes
    
    async def _handle_hello(self, message: Message, addr):
        """Behandel inkomende hello berichten"""
        try:
            # Deserialiseer discovery message
            discovery_msg = DiscoveryMessage.deserialize(message.payload)
            
            # Update statistieken
            self._stats['hello_received'] += 1
            
            # Maak of update node identity
            node_identity = NodeIdentity.from_dict({
                'node_id': discovery_msg.sender_id,
                'hostname': discovery_msg.payload.get('hostname', ''),
                'capabilities': discovery_msg.payload.get('capabilities', {}),
                'metadata': discovery_msg.payload.get('metadata', {}),
                'created_at': discovery_msg.timestamp,
                'last_seen': discovery_msg.timestamp
            })
            
            # Registreer node
            success = self.identity_manager.register_node(node_identity)
            if success:
                self._stats['nodes_discovered'] += 1
                
                # Roep event handler aan
                if self._node_discovered_handler:
                    await self._node_discovered_handler(node_identity, addr)
                
                logger.debug(f"Discovered new node: {node_identity}")
            
        except Exception as e:
            logger.error(f"Error handling hello message: {e}")
    
    async def _handle_heartbeat(self, message: Message, addr):
        """Behandel inkomende heartbeat berichten"""
        try:
            # Deserialiseer discovery message
            discovery_msg = DiscoveryMessage.deserialize(message.payload)
            
            # Update statistieken
            self._stats['heartbeat_received'] += 1
            
            # Update node laatste gezien
            success = self.identity_manager.update_node_last_seen(discovery_msg.sender_id)
            if success:
                logger.debug(f"Heartbeat received from {discovery_msg.sender_id}")
            
        except Exception as e:
            logger.error(f"Error handling heartbeat message: {e}")
    
    async def _handle_gossip(self, message: Message, addr):
        """Behandel inkomende gossip berichten"""
        try:
            # Deserialiseer discovery message
            discovery_msg = DiscoveryMessage.deserialize(message.payload)
            
            # Update statistieken
            self._stats['gossip_received'] += 1
            
            # Verwerk node informatie
            nodes_data = discovery_msg.payload.get('nodes', {})
            gossip_id = discovery_msg.payload.get('gossip_id')
            
            # Verwerk elk node in de gossip
            for node_id, node_info in nodes_data.items():
                if node_id == self.identity_manager.get_local_identity().node_id:
                    continue  # Skip eigen node
                
                # Maak node identity
                node_identity = NodeIdentity.from_dict({
                    'node_id': node_id,
                    'hostname': node_info.get('hostname', ''),
                    'capabilities': node_info.get('capabilities', {}),
                    'metadata': {},  # Geen metadata in gossip
                    'created_at': node_info.get('created_at', time.time()),
                    'last_seen': time.time()  # Update naar nu
                })
                
                # Registreer node
                self.identity_manager.register_node(node_identity)
                
                # Update gossip history
                self._gossip_history[node_id] = time.time()
            
            logger.debug(f"Processed gossip {gossip_id} with {len(nodes_data)} nodes")
            
        except Exception as e:
            logger.error(f"Error handling gossip message: {e}")
    
    async def _cleanup_stale_nodes(self):
        """Verwijder verouderde nodes"""
        removed_count = self.identity_manager.remove_stale_nodes()
        
        if removed_count > 0:
            self._stats['nodes_lost'] += removed_count
            
            # Roep event handler aan voor verloren nodes
            if self._node_lost_handler:
                # TODO: Implementeer node lost detection
                pass
            
            logger.debug(f"Removed {removed_count} stale nodes")
    
    def set_node_discovered_handler(self, handler: Callable):
        """Stel een handler in voor nieuwe nodes"""
        self._node_discovered_handler = handler
    
    def set_node_lost_handler(self, handler: Callable):
        """Stel een handler in voor verloren nodes"""
        self._node_lost_handler = handler
    
    def get_discovered_nodes(self) -> Dict[str, NodeIdentity]:
        """Krijg alle ontdekte nodes"""
        return self.identity_manager.get_all_nodes()
    
    def get_node_count(self) -> int:
        """Krijg aantal bekende nodes"""
        return self.identity_manager.get_node_count()
    
    def get_stats(self) -> Dict[str, Any]:
        """Krijg statistieken voor het discovery systeem"""
        stats = self._stats.copy()
        stats['running'] = self._running
        stats['gossip_partners'] = len(self._gossip_partners)
        stats['gossip_history_size'] = len(self._gossip_history)
        return stats
    
    def reset_stats(self):
        """Reset alle statistieken"""
        self._stats = {
            'hello_sent': 0,
            'hello_received': 0,
            'heartbeat_sent': 0,
            'heartbeat_received': 0,
            'gossip_sent': 0,
            'gossip_received': 0,
            'nodes_discovered': 0,
            'nodes_lost': 0,
        }
    
    def is_running(self) -> bool:
        """Controleer of discovery actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"NoodleDiscovery(nodes={self.get_node_count()}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"NoodleDiscovery(nodes={self.get_node_count()}, "
                f"discovered={self._stats['nodes_discovered']}, "
                f"lost={self._stats['nodes_lost']})")


