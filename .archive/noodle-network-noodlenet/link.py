"""
Noodle Network Noodlenet::Link - link.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Transportlaag voor NoodleNet - Berichtverzending en ontvangst
"""

import asyncio
import socket
import struct
import time
import json
import logging
from typing import Optional, Dict, Any, Set, Callable, AsyncIterator
from dataclasses import dataclass, field
from .config import NoodleNetConfig
from .identity import NodeIdentity

logger = logging.getLogger(__name__)


@dataclass
class Message:
    """Bericht structuur voor NoodleNet communicatie"""
    
    sender_id: str
    recipient_id: Optional[str]  # None voor broadcast
    message_type: str
    payload: Any
    timestamp: float = field(default_factory=time.time)
    message_id: str = field(default_factory=lambda: str(time.time()))
    
    def serialize(self) -> bytes:
        """
        Serialiseer het bericht naar bytes
        
        Returns:
            Geserialiseerde bytes
        """
        # Eerst serialiseer de payload naar JSON
        if isinstance(self.payload, (dict, list, str, int, float, bool)):
            payload_json = json.dumps(self.payload)
        else:
            # Voor complexe objecten, converteer naar string representatie
            payload_json = str(self.payload)
        
        # Bouw het bericht
        message_dict = {
            'sender_id': self.sender_id,
            'recipient_id': self.recipient_id,
            'message_type': self.message_type,
            'payload': payload_json,
            'timestamp': self.timestamp,
            'message_id': self.message_id,
        }
        
        # Serialiseer naar JSON en encode naar bytes
        message_json = json.dumps(message_dict)
        return message_json.encode('utf-8')
    
    @classmethod
    def deserialize(cls, data: bytes) -> "Message":
        """
        Deserialiseer bytes naar Message object
        
        Args:
            data: Geserialiseerde bericht bytes
            
        Returns:
            Message object
        """
        try:
            # Decode bytes en parse JSON
            message_json = data.decode('utf-8')
            message_dict = json.loads(message_json)
            
            # Maak Message object
            # Parseer payload als het JSON is
            payload = message_dict['payload']
            try:
                # Probeer te parsen als JSON
                if isinstance(payload, str):
                    parsed_payload = json.loads(payload)
                else:
                    parsed_payload = payload
            except json.JSONDecodeError:
                # Als JSON parsing faalt, gebruik de originele payload
                parsed_payload = payload
            
            return cls(
                sender_id=message_dict['sender_id'],
                recipient_id=message_dict['recipient_id'],
                message_type=message_dict['message_type'],
                payload=parsed_payload,
                timestamp=message_dict['timestamp'],
                message_id=message_dict['message_id'],
            )
        except (UnicodeDecodeError, json.JSONDecodeError, KeyError) as e:
            logger.error(f"Failed to deserialize message: {e}")
            raise ValueError(f"Invalid message data: {e}")


class NoodleLink:
    """Transportlaag voor NoodleNet communicatie"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None,
                 local_identity: Optional[NodeIdentity] = None):
        """
        Initialiseer de NoodleLink
        
        Args:
            config: NoodleNet configuratie
            local_identity: Lokale node identity
        """
        self.config = config or NoodleNetConfig()
        self.local_identity = local_identity
        
        # Netwerk sockets
        self._udp_socket: Optional[socket.socket] = None
        self._tcp_socket: Optional[socket.socket] = None
        self._tcp_server: Optional[asyncio.Server] = None
        
        # Asynchrone taken
        self._receive_task: Optional[asyncio.Task] = None
        self._heartbeat_task: Optional[asyncio.Task] = None
        
        # Status tracking
        self._connected_nodes: Set[str] = set()
        self._message_handlers: Dict[str, Callable] = {}
        self._error_handler: Optional[Callable] = None
        self._running = False
        
        # Statistieken
        self._stats = {
            'messages_sent': 0,
            'messages_received': 0,
            'bytes_sent': 0,
            'bytes_received': 0,
            'connection_errors': 0,
            'send_errors': 0,
            'receive_errors': 0,
        }
    
    async def start(self):
        """Start de transportlaag"""
        if self._running:
            logger.warning("NoodleLink is already running")
            return
        
        self._running = True
        
        # Initialiseer sockets
        await self._init_sockets()
        
        # Start asynchrone taken
        self._receive_task = asyncio.create_task(self._receive_loop())
        
        logger.info("NoodleLink started")
    
    async def stop(self):
        """Stop de transportlaag"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop taken
        if self._receive_task:
            self._receive_task.cancel()
            try:
                await self._receive_task
            except asyncio.CancelledError:
                pass
        
        if self._heartbeat_task:
            self._heartbeat_task.cancel()
            try:
                await self._heartbeat_task
            except asyncio.CancelledError:
                pass
        
        # Sluit sockets
        if self._udp_socket:
            self._udp_socket.close()
        
        if self._tcp_socket:
            self._tcp_socket.close()
        
        if self._tcp_server:
            self._tcp_server.close()
            await self._tcp_server.wait_closed()
        
        logger.info("NoodleLink stopped")
    
    async def _init_sockets(self):
        """Initialiseer netwerk sockets"""
        # UDP socket voor multicast berichten
        self._udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._udp_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        # Bind aan lokale poort
        self._udp_socket.bind(('', self.config.discovery_port))
        
        # Stel multicast in
        mreq = struct.pack("4sl", socket.inet_aton(self.config.discovery_multicast_addr),
                          socket.INADDR_ANY)
        self._udp_socket.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)
        
        # TCP socket voor directe verbindingen
        self._tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._tcp_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        # Start TCP server voor inkomende verbindingen
        self._tcp_server = await asyncio.start_server(
            self._handle_tcp_connection,
            '0.0.0.0',
            self.config.discovery_port
        )
    
    async def send(self, recipient_id: str, message: Message) -> bool:
        """
        Verstuur een bericht naar een specifieke node
        
        Args:
            recipient_id: ID van de ontvanger
            message: Message object om te versturen
            
        Returns:
            True als bericht succesvol verzonden
        """
        if not self._running:
            logger.error("Cannot send message: NoodleLink is not running")
            return False
        
        if not self.local_identity:
            logger.error("Cannot send message: No local identity set")
            return False
        
        # Update sender ID
        message.sender_id = self.local_identity.node_id
        
        try:
            # Serialiseer bericht
            data = message.serialize()
            
            # Verstuur via TCP als directe verbinding bekend
            if recipient_id in self._connected_nodes:
                success = await self._send_tcp(recipient_id, data)
            else:
                # Broadcast via multicast
                success = await self._send_udp(data)
            
            if success:
                self._stats['messages_sent'] += 1
                self._stats['bytes_sent'] += len(data)
            
            return success
            
        except Exception as e:
            self._stats['send_errors'] += 1
            logger.error(f"Failed to send message to {recipient_id}: {e}")
            
            if self._error_handler:
                await self._error_handler(e, {'recipient': recipient_id, 'message': message})
            
            return False
    
    async def broadcast(self, message: Message) -> bool:
        """
        Broadcast een bericht naar alle nodes
        
        Args:
            message: Message object om te broadcasten
            
        Returns:
            True als bericht succesvol verzonden
        """
        if not self._running:
            logger.error("Cannot broadcast message: NoodleLink is not running")
            return False
        
        if not self.local_identity:
            logger.error("Cannot broadcast message: No local identity set")
            return False
        
        # Update sender ID en recipient
        message.sender_id = self.local_identity.node_id
        message.recipient_id = None
        
        try:
            # Serialiseer bericht
            data = message.serialize()
            
            # Verstuur via multicast
            success = await self._send_udp(data)
            
            if success:
                self._stats['messages_sent'] += 1
                self._stats['bytes_sent'] += len(data)
            
            return success
            
        except Exception as e:
            self._stats['send_errors'] += 1
            logger.error(f"Failed to broadcast message: {e}")
            
            if self._error_handler:
                await self._error_handler(e, {'message': message})
            
            return False
    
    async def _send_tcp(self, recipient_id: str, data: bytes) -> bool:
        """
        Verstuur data via TCP naar een specifieke node
        
        Args:
            recipient_id: ID van de ontvanger
            data: Data om te versturen
            
        Returns:
            True als succesvol verzonden
        """
        # Implementeer TCP verzending
        # Dit vereist een verbinding met de remote node
        # Voor nu, simuleren we met lokale communicatie
        
        logger.debug(f"Sending TCP data to {recipient_id}: {len(data)} bytes")
        
        try:
            # Simuleer TCP verzending
            reader, writer = await asyncio.open_connection(
                'localhost', self.config.discovery_port
            )
            
            # Stuur data lengte
            writer.write(struct.pack('!I', len(data)))
            await writer.drain()
            
            # Stuur data
            writer.write(data)
            await writer.drain()
            
            # Sluit verbinding
            writer.close()
            await writer.wait_closed()
            
            return True
            
        except Exception as e:
            logger.error(f"TCP send failed to {recipient_id}: {e}")
            return False
    
    async def _send_udp(self, data: bytes) -> bool:
        """
        Verstuur data via multicast
        
        Args:
            data: Data om te versturen
            
        Returns:
            True als succesvol verzonden
        """
        try:
            # Bereken multicast adres
            multicast_addr = (self.config.discovery_multicast_addr,
                            self.config.discovery_multicast_port)
            
            # Verstuur via multicast
            self._udp_socket.sendto(data, multicast_addr)
            
            return True
            
        except Exception as e:
            logger.error(f"UDP multicast send failed: {e}")
            return False
    
    async def _receive_loop(self):
        """Hoofd ontvangst loop"""
        udp_reader = asyncio.StreamReader()
        udp_protocol = asyncio.StreamReaderProtocol(udp_reader)
        
        loop = asyncio.get_event_loop()
        
        # Start UDP ontvangst
        transport, _ = await loop.create_datagram_endpoint(
            lambda: udp_protocol,
            sock=self._udp_socket
        )
        
        try:
            while self._running:
                try:
                    # Lees UDP data
                    data, addr = await udp_reader.readexactly(self.config.recv_buffer_size)
                    
                    # Verwerk bericht
                    await self._handle_udp_message(data, addr)
                    
                except asyncio.IncompleteReadError:
                    # Geen volledig bericht ontvangen, wacht op meer data
                    continue
                except Exception as e:
                    self._stats['receive_errors'] += 1
                    logger.error(f"Error in receive loop: {e}")
                    
                    if self._error_handler:
                        await self._error_handler(e, {'context': 'receive_loop'})
                    
                    # Korte pauze voor herstel
                    await asyncio.sleep(0.1)
                    
        finally:
            transport.close()
    
    async def _handle_tcp_connection(self, reader: asyncio.StreamReader,
                                   writer: asyncio.StreamWriter):
        """
        Behandel inkomende TCP verbindingen
        
        Args:
            reader: Stream reader
            writer: Stream writer
        """
        try:
            # Lees data lengte
            length_data = await reader.readexactly(4)
            length = struct.unpack('!I', length_data)[0]
            
            # Lees data
            data = await reader.readexactly(length)
            
            # Verwerk bericht (gebruik dezelfde handler als UDP)
            await self._handle_message(data, ('TCP', self.config.discovery_port))
            
        except asyncio.IncompleteReadError:
            logger.debug("Incomplete TCP message received")
        except Exception as e:
            logger.error(f"Error handling TCP connection: {e}")
        finally:
            writer.close()
            await writer.wait_closed()
    
    async def _handle_udp_message(self, data: bytes, addr):
        """
        Behandel inkomende UDP berichten
        
        Args:
            data: Ontvangen data
            addr: Adres van afzender
        """
        await self._handle_message(data, addr)
    
    async def _handle_message(self, data: bytes, addr):
        """
        Verwerk een ontvangen bericht
        
        Args:
            data: Ontvangen data
            addr: Adres van afzender
        """
        try:
            # Deserialiseer bericht
            message = Message.deserialize(data)
            
            # Update statistieken
            self._stats['messages_received'] += 1
            self._stats['bytes_received'] += len(data)
            
            # Log bericht
            logger.debug(f"Received message from {message.sender_id}: {message.message_type}")
            
            # Registreer node als verbonden
            self._connected_nodes.add(message.sender_id)
            
            # Roep message handler aan
            if message.message_type in self._message_handlers:
                handler = self._message_handlers[message.message_type]
                try:
                    await handler(message, addr)
                except Exception as e:
                    logger.error(f"Error in message handler for {message.message_type}: {e}")
            
            # Roep generieke handler aan als geregistreerd
            if None in self._message_handlers:
                handler = self._message_handlers[None]
                try:
                    await handler(message, addr)
                except Exception as e:
                    logger.error(f"Error in generic message handler: {e}")
            
        except ValueError as e:
            logger.error(f"Failed to parse message from {addr}: {e}")
        except Exception as e:
            logger.error(f"Error handling message from {addr}: {e}")
    
    def register_message_handler(self, message_type: Optional[str],
                                handler: Callable[[Message, tuple], Any]):
        """
        Registreer een bericht handler
        
        Args:
            message_type: Type bericht om te handleren (None voor generiek)
            handler: Async functie die message en addr accepteert
        """
        self._message_handlers[message_type] = handler
        logger.info(f"Registered message handler for {message_type}")
    
    def unregister_message_handler(self, message_type: Optional[str]):
        """
        Verwijder een bericht handler
        
        Args:
            message_type: Type bericht om te verwijderen
        """
        if message_type in self._message_handlers:
            del self._message_handlers[message_type]
            logger.info(f"Unregistered message handler for {message_type}")
    
    def set_error_handler(self, handler: Callable[[Exception, dict], Any]):
        """
        Stel een error handler in
        
        Args:
            handler: Async functie die error en context accepteert
        """
        self._error_handler = handler
        logger.info("Registered error handler")
    
    def get_connected_nodes(self) -> Set[str]:
        """
        Krijg set van verbonden node IDs
        
        Returns:
            Set met node IDs
        """
        return self._connected_nodes.copy()
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Krijg statistieken over de transportlaag
        
        Returns:
            Dictionary met statistieken
        """
        stats = self._stats.copy()
        stats['connected_nodes'] = len(self._connected_nodes)
        stats['running'] = self._running
        return stats
    
    def reset_stats(self):
        """Reset alle statistieken"""
        self._stats = {
            'messages_sent': 0,
            'messages_received': 0,
            'bytes_sent': 0,
            'bytes_received': 0,
            'connection_errors': 0,
            'send_errors': 0,
            'receive_errors': 0,
        }
    
    async def send_heartbeat(self):
        """
        Stuur een heartbeat bericht naar alle verbonden nodes
        """
        heartbeat_message = Message(
            sender_id=self.local_identity.node_id if self.local_identity else "unknown",
            recipient_id=None,
            message_type="heartbeat",
            payload={"timestamp": time.time()},
            timestamp=time.time()
        )
        
        await self.broadcast(heartbeat_message)
    
    def set_local_identity(self, identity: NodeIdentity):
        """
        Stel de lokale node identity in
        
        Args:
            identity: Lokale NodeIdentity
        """
        self.local_identity = identity
        logger.info(f"Local identity set to {identity}")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"NoodleLink(connected_nodes={len(self._connected_nodes)}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"NoodleLink(nodes={len(self._connected_nodes)}, "
                f"sent={self._stats['messages_sent']}, "
                f"received={self._stats['messages_received']})")


class Link:
    """
    Simplified Link class for NoodleNet network communication.
    
    This class provides a basic interface for network communication
    between nodes in the NoodleNet system, with proper error handling
    and logging capabilities.
    """
    
    def __init__(self, node_id: Optional[str] = None, config: Optional[Dict[str, Any]] = None):
        """
        Initialize the Link instance.
        
        Args:
            node_id: Unique identifier for this node
            config: Configuration dictionary for the link
        """
        import uuid
        import logging
        
        self.node_id = node_id or str(uuid.uuid4())
        self.config = config or {}
        
        # Setup logging
        self.logger = logging.getLogger(__name__)
        
        # Connection status
        self.connected_nodes = set()
        self.active = False
        
        # Error handling
        self.error_handlers = []
        
        # Performance metrics
        self.metrics = {
            "messages_sent": 0,
            "messages_received": 0,
            "connection_errors": 0,
            "last_activity": None
        }
        
        # Initialize link
        self._initialize()
    
    def _initialize(self):
        """Initialize the link with default configuration."""
        try:
            # Set default configuration values
            self.config.setdefault("host", "0.0.0.0")
            self.config.setdefault("port", 8080)
            self.config.setdefault("timeout", 30)
            self.config.setdefault("max_connections", 100)
            
            self.logger.info(f"Link initialized with node_id: {self.node_id}")
            
        except Exception as e:
            error_code = 2001
            self.logger.error(f"Failed to initialize link: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "initialization"})
    
    def connect(self, target_node_id: str) -> bool:
        """
        Connect to a target node.
        
        Args:
            target_node_id: ID of the target node to connect to
            
        Returns:
            True if connection was successful, False otherwise
        """
        try:
            if target_node_id in self.connected_nodes:
                self.logger.warning(f"Already connected to node: {target_node_id}")
                return True
            
            # Simulate connection establishment
            # In a real implementation, this would establish network connection
            self.connected_nodes.add(target_node_id)
            self._update_activity()
            
            self.logger.info(f"Connected to node: {target_node_id}")
            return True
            
        except Exception as e:
            error_code = 2002
            self.metrics["connection_errors"] += 1
            self.logger.error(f"Failed to connect to node {target_node_id}: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "connect", "target": target_node_id})
            return False
    
    def disconnect(self, target_node_id: str) -> bool:
        """
        Disconnect from a target node.
        
        Args:
            target_node_id: ID of the target node to disconnect from
            
        Returns:
            True if disconnection was successful, False otherwise
        """
        try:
            if target_node_id not in self.connected_nodes:
                self.logger.warning(f"Not connected to node: {target_node_id}")
                return False
            
            # Simulate disconnection
            # In a real implementation, this would close network connection
            self.connected_nodes.remove(target_node_id)
            self._update_activity()
            
            self.logger.info(f"Disconnected from node: {target_node_id}")
            return True
            
        except Exception as e:
            error_code = 2003
            self.logger.error(f"Failed to disconnect from node {target_node_id}: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "disconnect", "target": target_node_id})
            return False
    
    def send_message(self, target_node_id: str, message: Dict[str, Any]) -> bool:
        """
        Send a message to a target node.
        
        Args:
            target_node_id: ID of the target node
            message: Message content as a dictionary
            
        Returns:
            True if message was sent successfully, False otherwise
        """
        try:
            if target_node_id not in self.connected_nodes:
                error_code = 2004
                self.logger.error(f"Not connected to node {target_node_id} (Error: {error_code})")
                return False
            
            # Add metadata to message
            message_data = {
                "sender": self.node_id,
                "recipient": target_node_id,
                "timestamp": self._get_timestamp(),
                "message_id": self._generate_message_id(),
                "content": message
            }
            
            # Simulate message sending
            # In a real implementation, this would send the message over the network
            self.metrics["messages_sent"] += 1
            self._update_activity()
            
            self.logger.debug(f"Message sent to {target_node_id}: {message_data['message_id']}")
            return True
            
        except Exception as e:
            error_code = 2005
            self.logger.error(f"Failed to send message to {target_node_id}: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "send_message", "target": target_node_id})
            return False
    
    def broadcast_message(self, message: Dict[str, Any]) -> int:
        """
        Broadcast a message to all connected nodes.
        
        Args:
            message: Message content as a dictionary
            
        Returns:
            Number of nodes the message was sent to
        """
        success_count = 0
        
        for node_id in self.connected_nodes.copy():
            if self.send_message(node_id, message):
                success_count += 1
        
        self.logger.info(f"Broadcast message sent to {success_count}/{len(self.connected_nodes)} nodes")
        return success_count
    
    def receive_message(self) -> Optional[Dict[str, Any]]:
        """
        Receive a message from any connected node.
        
        Returns:
            Received message as a dictionary, or None if no message available
        """
        try:
            # Simulate message reception
            # In a real implementation, this would wait for and return incoming messages
            # For now, return None to indicate no message available
            return None
            
        except Exception as e:
            error_code = 2006
            self.logger.error(f"Failed to receive message: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "receive_message"})
            return None
    
    def get_status(self) -> Dict[str, Any]:
        """
        Get the current status of the link.
        
        Returns:
            Dictionary containing status information
        """
        return {
            "node_id": self.node_id,
            "active": self.active,
            "connected_nodes": list(self.connected_nodes),
            "connection_count": len(self.connected_nodes),
            "metrics": self.metrics.copy(),
            "config": self.config.copy()
        }
    
    def add_error_handler(self, handler: Callable[[Exception, Dict[str, Any]], None]):
        """
        Add an error handler function.
        
        Args:
            handler: Function that takes an exception and context dictionary
        """
        self.error_handlers.append(handler)
        self.logger.info("Error handler added")
    
    def _handle_error(self, error: Exception, context: Dict[str, Any]):
        """
        Handle an error by calling registered error handlers.
        
        Args:
            error: The exception that occurred
            context: Context information about the error
        """
        for handler in self.error_handlers:
            try:
                handler(error, context)
            except Exception as e:
                self.logger.error(f"Error in error handler: {e}")
    
    def _update_activity(self):
        """Update the last activity timestamp."""
        import time
        self.metrics["last_activity"] = time.time()
    
    def _get_timestamp(self) -> float:
        """Get the current timestamp."""
        import time
        return time.time()
    
    def _generate_message_id(self) -> str:
        """Generate a unique message ID."""
        import uuid
        return str(uuid.uuid4())
    
    def start(self) -> bool:
        """
        Start the link and make it active.
        
        Returns:
            True if started successfully, False otherwise
        """
        try:
            if self.active:
                self.logger.warning("Link is already active")
                return True
            
            # Simulate starting the link
            # In a real implementation, this would start network services
            self.active = True
            self._update_activity()
            
            self.logger.info("Link started successfully")
            return True
            
        except Exception as e:
            error_code = 2007
            self.logger.error(f"Failed to start link: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "start"})
            return False
    
    def stop(self) -> bool:
        """
        Stop the link and make it inactive.
        
        Returns:
            True if stopped successfully, False otherwise
        """
        try:
            if not self.active:
                self.logger.warning("Link is already inactive")
                return True
            
            # Disconnect from all nodes
            for node_id in self.connected_nodes.copy():
                self.disconnect(node_id)
            
            # Simulate stopping the link
            # In a real implementation, this would stop network services
            self.active = False
            
            self.logger.info("Link stopped successfully")
            return True
            
        except Exception as e:
            error_code = 2008
            self.logger.error(f"Failed to stop link: {e} (Error: {error_code})")
            self._handle_error(e, {"error_code": error_code, "context": "stop"})
            return False
    
    def __str__(self) -> str:
        """String representation of the Link."""
        return f"Link(node_id={self.node_id}, connections={len(self.connected_nodes)}, active={self.active})"
    
    def __repr__(self) -> str:
        """Debug representation of the Link."""
        return (f"Link(node_id={self.node_id}, "
                f"connections={len(self.connected_nodes)}, "
                f"messages_sent={self.metrics['messages_sent']}, "
                f"messages_received={self.metrics['messages_received']})")


