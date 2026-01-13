"""
Noodle Network Noodlenet::Mesh - mesh.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Mesh routing systeem voor NoodleNet - Dynamische topologie met load balancing
"""

import asyncio
import time
import math
import logging
import heapq
from typing import Dict, Set, List, Optional, Tuple, Any, Callable
from dataclasses import dataclass, field
from collections import defaultdict
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .link import NoodleLink, Message

logger = logging.getLogger(__name__)


@dataclass
class NodeMetrics:
    """Metriek data voor een node"""
    
    node_id: str
    hostname: str
    
    # Prestatiemetrieken
    latency: float = 0.0  # ms
    cpu_usage: float = 0.0  # 0.0-1.0
    memory_usage: float = 0.0  # 0.0-1.0
    gpu_usage: float = 0.0  # 0.0-1.0 (als beschikbaar)
    
    # Netwerkmetrieken
    bandwidth_up: float = 0.0  # Mbps
    bandwidth_down: float = 0.0  # Mbps
    packet_loss: float = 0.0  # 0.0-1.0
    
    # Reliabiliteitsmetrieken
    uptime: float = 1.0  # 0.0-1.0
    response_time: float = 0.0  # ms
    error_rate: float = 0.0  # 0.0-1.0
    
    # Tijdstempels
    last_updated: float = field(default_factory=time.time)
    
    def get_quality_score(self) -> float:
        """
        Bereken een kwaliteitsscore (0.0-1.0) voor deze node
        
        Returns:
            Kwaliteitsscore
        """
        # Gewicht factoren
        weights = {
            'latency': 0.2,
            'cpu_usage': 0.15,
            'memory_usage': 0.15,
            'gpu_usage': 0.1,
            'packet_loss': 0.15,
            'uptime': 0.1,
            'response_time': 0.1,
            'error_rate': 0.05
        }
        
        # Normaliseer metrieken (lager is beter voor latency, memory, etc.)
        normalized_latency = min(self.latency / 100.0, 1.0)  # Normaliseer naar 100ms
        normalized_cpu = self.cpu_usage
        normalized_memory = self.memory_usage
        normalized_gpu = self.gpu_usage
        normalized_packet_loss = self.packet_loss
        normalized_response_time = min(self.response_time / 50.0, 1.0)  # Normaliseer naar 50ms
        normalized_error_rate = self.error_rate
        
        # Bereken gewogen score
        score = (
            weights['latency'] * normalized_latency +
            weights['cpu_usage'] * normalized_cpu +
            weights['memory_usage'] * normalized_memory +
            weights['gpu_usage'] * normalized_gpu +
            weights['packet_loss'] * normalized_packet_loss +
            weights['uptime'] * (1.0 - self.uptime) +
            weights['response_time'] * normalized_response_time +
            weights['error_rate'] * normalized_error_rate
        )
        
        # Converteer naar positieve score (0.0 = slecht, 1.0 = goed)
        return 1.0 - min(score, 1.0)
    
    def is_healthy(self, config: NoodleNetConfig) -> bool:
        """
        Controleer of de node gezond is
        
        Args:
            config: NoodleNet configuratie
            
        Returns:
            True als node gezond is
        """
        return (
            self.latency <= config.mesh_max_latency and
            self.cpu_usage < 0.9 and
            self.memory_usage < 0.9 and
            self.packet_loss < 0.05 and
            self.uptime > 0.95 and
            self.error_rate < 0.01 and
            self.get_quality_score() >= config.mesh_min_quality
        )


@dataclass
class Edge:
    """Vertegenwoordigt een verbinding tussen twee nodes"""
    
    from_node: str
    to_node: str
    latency: float
    bandwidth: float
    reliability: float
    last_updated: float = field(default_factory=time.time)
    
    def get_weight(self) -> float:
        """Bereken gewicht voor shortest path algoritmes"""
        # Lagere latency = lager gewicht
        # Hogere bandwidth = lager gewicht
        # Hogere reliability = lager gewicht
        latency_weight = self.latency / 100.0  # Normaliseer
        bandwidth_weight = 1.0 / max(self.bandwidth, 1.0)
        reliability_weight = 1.0 - self.reliability
        
        return latency_weight + bandwidth_weight + reliability_weight
    
    def __lt__(self, other: 'Edge') -> bool:
        """Vergelijk edges op basis van gewicht"""
        return self.get_weight() < other.get_weight()


class MeshTopology:
    """Vertegenwoordigt de mesh topologie"""
    
    def __init__(self):
        self.nodes: Dict[str, NodeMetrics] = {}
        self.edges: Dict[str, List[Edge]] = defaultdict(list)  # node_id -> list[edges]
        self.adjacency: Dict[str, Set[str]] = defaultdict(set)
    
    def add_node(self, metrics: NodeMetrics):
        """Voeg een node toe aan de topologie"""
        self.nodes[metrics.node_id] = metrics
        logger.debug(f"Added node to topology: {metrics.node_id}")
    
    def remove_node(self, node_id: str):
        """Verwijder een node uit de topologie"""
        if node_id in self.nodes:
            del self.nodes[node_id]
        
        # Verwijder gerelateerde edges
        if node_id in self.edges:
            del self.edges[node_id]
        
        # Verwijder verbindingen naar deze node
        for other_node in list(self.adjacency.keys()):
            if node_id in self.adjacency[other_node]:
                self.adjacency[other_node].discard(node_id)
                # Verwijder edges
                self.edges[other_node] = [
                    edge for edge in self.edges[other_node]
                    if edge.to_node != node_id
                ]
        
        logger.debug(f"Removed node from topology: {node_id}")
    
    def add_edge(self, from_node: str, to_node: str, latency: float, 
                 bandwidth: float, reliability: float):
        """Voeg een edge toe aan de topologie"""
        edge = Edge(from_node, to_node, latency, bandwidth, reliability)
        self.edges[from_node].append(edge)
        self.adjacency[from_node].add(to_node)
        self.adjacency[to_node].add(from_node)
        
        logger.debug(f"Added edge {from_node} -> {to_node} (latency: {latency}ms)")
    
    def update_node_metrics(self, node_id: str, **metrics):
        """Update metrieken voor een node"""
        if node_id in self.nodes:
            for key, value in metrics.items():
                if hasattr(self.nodes[node_id], key):
                    setattr(self.nodes[node_id], key, value)
            self.nodes[node_id].last_updated = time.time()
    
    def find_shortest_path(self, start: str, end: str) -> Optional[List[str]]:
        """
        Vind de kortste pad tussen twee nodes met Dijkstra's algoritme
        
        Args:
            start: Start node ID
            end: Eind node ID
            
        Returns:
            Lijst met node IDs of None als pad niet gevonden
        """
        if start == end:
            return [start]
        
        if start not in self.nodes or end not in self.nodes:
            return None
        
        # Dijkstra's algoritme
        distances = {node: float('inf') for node in self.nodes}
        distances[start] = 0
        previous = {}
        unvisited = set(self.nodes.keys())
        
        while unvisited:
            # Vind node met kleinste afstand
            current = min(unvisited, key=lambda node: distances[node])
            
            if distances[current] == float('inf'):
                break  # Onbereikbare nodes
            
            if current == end:
                # Herbouw pad
                path = []
                while current in previous:
                    path.append(current)
                    current = previous[current]
                path.append(start)
                return path[::-1]
            
            unvisited.remove(current)
            
            # Update afstanden naar buren
            for edge in self.edges[current]:
                neighbor = edge.to_node
                if neighbor in unvisited:
                    new_distance = distances[current] + edge.get_weight()
                    if new_distance < distances[neighbor]:
                        distances[neighbor] = new_distance
                        previous[neighbor] = current
        
        return None  # Geen pad gevonden
    
    def get_best_node_for_task(self, task_type: str, capabilities: Set[str],
                             exclude_nodes: Optional[Set[str]] = None) -> Optional[str]:
        """
        Vind de beste node voor een specifieke taak
        
        Args:
            task_type: Type taak (bv. "ai_inference", "data_processing")
            capabilities: Vereiste capabilities
            exclude_nodes: Te negeren node IDs
            
        Returns:
            Beste node ID of None als geen geschikte node gevonden
        """
        if exclude_nodes is None:
            exclude_nodes = set()
        
        best_node = None
        best_score = -1.0
        
        for node_id, metrics in self.nodes.items():
            if node_id in exclude_nodes:
                continue
            
            # Controleer capabilities
            node_capabilities = set()
            # TODO: Haal capabilities uit identity manager
            capabilities_set = set(capabilities) if isinstance(capabilities, dict) else capabilities
            node_capabilities_set = set(node_capabilities) if isinstance(node_capabilities, dict) else node_capabilities
            
            if not capabilities_set.issubset(node_capabilities_set):
                continue
            
            # Controleer gezondheid
            if not metrics.is_healthy(NoodleNetConfig()):
                continue
            
            # Bereek score op basis van task type
            score = self._calculate_task_score(metrics, task_type)
            
            if score > best_score:
                best_score = score
                best_node = node_id
        
        return best_node
    
    def _calculate_task_score(self, metrics: NodeMetrics, task_type: str) -> float:
        """Bereek een score voor een specifieke taak"""
        base_score = metrics.get_quality_score()
        
        # Task-specifieke aanpassingen
        if task_type == "ai_inference":
            # Voor AI: GPU belangrijk, lage latency belangrijk
            score = base_score * 0.7 + (1.0 - metrics.gpu_usage) * 0.3
        elif task_type == "data_processing":
            # Voor data processing: CPU en memory belangrijk
            score = base_score * 0.6 + (1.0 - metrics.cpu_usage) * 0.2 + (1.0 - metrics.memory_usage) * 0.2
        elif task_type == "storage":
            # Voor storage: bandwidth en reliability belangrijk
            score = base_score * 0.5 + (metrics.bandwidth_down / 1000.0) * 0.3 + metrics.reliability * 0.2
        else:
            # Algemene taak
            score = base_score
        
        return score
    
    def get_neighbors(self, node_id: str) -> Set[str]:
        """Krijg buren van een node"""
        return self.adjacency.get(node_id, set())
    
    def get_edge_count(self) -> int:
        """Krijg totaal aantal edges"""
        return sum(len(edges) for edges in self.edges.values())
    
    def get_node_count(self) -> int:
        """Krijg aantal nodes"""
        return len(self.nodes)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer topologie naar dictionary"""
        return {
            'nodes': {
                node_id: {
                    'hostname': metrics.hostname,
                    'latency': metrics.latency,
                    'cpu_usage': metrics.cpu_usage,
                    'memory_usage': metrics.memory_usage,
                    'gpu_usage': metrics.gpu_usage,
                    'quality_score': metrics.get_quality_score(),
                    'healthy': metrics.is_healthy(NoodleNetConfig())
                }
                for node_id, metrics in self.nodes.items()
            },
            'edges': {
                from_node: [
                    {
                        'to_node': edge.to_node,
                        'latency': edge.latency,
                        'bandwidth': edge.bandwidth,
                        'reliability': edge.reliability
                    }
                    for edge in edges
                ]
                for from_node, edges in self.edges.items()
            },
            'node_count': self.get_node_count(),
            'edge_count': self.get_edge_count()
        }


class NoodleMesh:
    """Mesh routing systeem voor NoodleNet"""
    
    def __init__(self, link: NoodleLink, identity_manager: NoodleIdentityManager,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de mesh manager
        
        Args:
            link: NoodleLink instantie voor communicatie
            identity_manager: NoodleIdentityManager voor node informatie
            config: NoodleNet configuratie
        """
        self.link = link
        self.identity_manager = identity_manager
        self.config = config or NoodleNetConfig()
        
        # Mesh componenten
        self.topology = MeshTopology()
        self._running = False
        
        # Update taken
        self._topology_update_task: Optional[asyncio.Task] = None
        self._metrics_collection_task: Optional[asyncio.Task] = None
        
        # Event handlers
        self._node_added_handler: Optional[Callable] = None
        self._node_removed_handler: Optional[Callable] = None
        self._topology_changed_handler: Optional[Callable] = None
        
        # Statistieken
        self._stats = {
            'routes_calculated': 0,
            'best_node_selections': 0,
            'topology_updates': 0,
            'metrics_updates': 0,
            'failed_routes': 0,
        }
    
    async def start(self):
        """Start het mesh systeem"""
        if self._running:
            logger.warning("Mesh is already running")
            return
        
        self._running = True
        
        # Registreer message handlers voor mesh updates
        self.link.register_message_handler("mesh_metrics", self._handle_mesh_metrics)
        self.link.register_message_handler("mesh_topology", self._handle_mesh_topology)
        
        # Start taken
        self._topology_update_task = asyncio.create_task(self._topology_update_loop())
        self._metrics_collection_task = asyncio.create_task(self._metrics_collection_loop())
        
        logger.info("Mesh system started")
    
    async def stop(self):
        """Stop het mesh systeem"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop taken
        if self._topology_update_task:
            self._topology_update_task.cancel()
            try:
                await self._topology_update_task
            except asyncio.CancelledError:
                pass
        
        if self._metrics_collection_task:
            self._metrics_collection_task.cancel()
            try:
                await self._metrics_collection_task
            except asyncio.CancelledError:
                pass
        
        # Deregister message handlers
        self.link.unregister_message_handler("mesh_metrics")
        self.link.unregister_message_handler("mesh_topology")
        
        logger.info("Mesh system stopped")
    
    def update_node_metrics(self, node_id: str, **metrics):
        """
        Update metrieken voor een node
        
        Args:
            node_id: Node ID
            **metrics: Metrieken om te updaten
        """
        self.topology.update_node_metrics(node_id, **metrics)
        
        # Stuur update naar andere nodes
        asyncio.create_task(self._broadcast_metrics_update(node_id, metrics))
    
    def add_node(self, node_id: str, hostname: str):
        """
        Voeg een node toe aan de mesh
        
        Args:
            node_id: Node ID
            hostname: Hostname
        """
        metrics = NodeMetrics(node_id=node_id, hostname=hostname)
        self.topology.add_node(metrics)
        
        # Roep event handler aan
        if self._node_added_handler:
            self._node_added_handler(node_id, hostname)
        
        logger.debug(f"Added node to mesh: {node_id}")
    
    def remove_node(self, node_id: str):
        """
        Verwijder een node uit de mesh
        
        Args:
            node_id: Node ID
        """
        self.topology.remove_node(node_id)
        
        # Roep event handler aan
        if self._node_removed_handler:
            self._node_removed_handler(node_id)
        
        logger.debug(f"Removed node from mesh: {node_id}")
    
    def add_edge(self, from_node: str, to_node: str, latency: float, 
                 bandwidth: float, reliability: float):
        """
        Voeg een edge toe aan de mesh
        
        Args:
            from_node: Bron node ID
            to_node: Doel node ID
            latency: Latency in ms
            bandwidth: Bandwidth in Mbps
            reliability: Reliabiliteit (0.0-1.0)
        """
        self.topology.add_edge(from_node, to_node, latency, bandwidth, reliability)
        
        # Roep topology changed handler aan
        if self._topology_changed_handler:
            self._topology_changed_handler()
        
        logger.debug(f"Added mesh edge: {from_node} -> {to_node}")
    
    def find_route(self, start: str, end: str) -> Optional[List[str]]:
        """
        Vind een route tussen twee nodes
        
        Args:
            start: Start node ID
            end: Eind node ID
            
        Returns:
            Lijst met node IDs in de route of None als geen route gevonden
        """
        route = self.topology.find_shortest_path(start, end)
        
        if route:
            self._stats['routes_calculated'] += 1
        else:
            self._stats['failed_routes'] += 1
        
        return route
    
    def get_best_node(self, task_type: str, capabilities: Set[str],
                     exclude_nodes: Optional[Set[str]] = None) -> Optional[str]:
        """
        Vind de beste node voor een specifieke taak
        
        Args:
            task_type: Type taak
            capabilities: Vereiste capabilities
            exclude_nodes: Te negeren node IDs
            
        Returns:
            Beste node ID of None als geen geschikte node gevonden
        """
        best_node = self.topology.get_best_node_for_task(task_type, capabilities, exclude_nodes)
        
        if best_node:
            self._stats['best_node_selections'] += 1
        
        return best_node
    
    def get_node_count(self) -> int:
        """Krijg aantal nodes in de mesh"""
        return self.topology.get_node_count()
    
    def get_topology(self) -> Dict[str, Any]:
        """Krijg de volledige topologie"""
        return self.topology.to_dict()
    
    def get_stats(self) -> Dict[str, Any]:
        """Krijg statistieken voor het mesh systeem"""
        stats = self._stats.copy()
        stats['running'] = self._running
        stats['node_count'] = self.get_node_count()
        stats['edge_count'] = self.topology.get_edge_count()
        return stats
    
    async def _topology_update_loop(self):
        """Loop voor topologie updates"""
        while self._running:
            try:
                # Update topologie op basis van bekende nodes
                await self._update_topology_from_nodes()
                
                # Update edge informatie
                await self._update_edges()
                
                # Roep event handler aan
                if self._topology_changed_handler:
                    self._topology_changed_handler()
                
                self._stats['topology_updates'] += 1
                
                # Wacht voor volgende update
                await asyncio.sleep(self.config.mesh_update_interval)
                
            except Exception as e:
                logger.error(f"Error in topology update loop: {e}")
                await asyncio.sleep(5)
    
    async def _metrics_collection_loop(self):
        """Loop voor het verzamelen van node metrieken"""
        while self._running:
            try:
                # Verzamel metrieken van alle nodes
                await self._collect_node_metrics()
                
                self._stats['metrics_updates'] += 1
                
                # Wacht voor volgende collectie
                await asyncio.sleep(self.config.mesh_update_interval)
                
            except Exception as e:
                logger.error(f"Error in metrics collection loop: {e}")
                await asyncio.sleep(5)
    
    async def _update_topology_from_nodes(self):
        """Update topologie op basis van bekende nodes"""
        known_nodes = self.identity_manager.get_all_nodes()
        
        # Voeg nieuwe nodes toe
        for node_id, identity in known_nodes.items():
            if node_id not in self.topology.nodes:
                self.add_node(node_id, identity.hostname)
        
        # Verwijder niet-bekende nodes
        current_nodes = set(self.topology.nodes.keys())
        known_node_ids = set(known_nodes.keys())
        
        for node_id in current_nodes - known_node_ids:
            self.remove_node(node_id)
    
    async def _update_edges(self):
        """Update edge informatie tussen nodes"""
        nodes = list(self.topology.nodes.keys())
        
        # Voor elke paar nodes, simuleer edge meting
        for i, from_node in enumerate(nodes):
            for to_node in nodes[i+1:]:
                # Simuleer meting (in echte implementatie: ping meting)
                latency = self._simulate_latency_measurement(from_node, to_node)
                bandwidth = self._simulate_bandwidth_measurement(from_node, to_node)
                reliability = self._simulate_reliability_measurement(from_node, to_node)
                
                # Update edge in beide richtingen
                self.add_edge(from_node, to_node, latency, bandwidth, reliability)
                self.add_edge(to_node, from_node, latency, bandwidth, reliability)
    
    def _simulate_latency_measurement(self, from_node: str, to_node: str) -> float:
        """Simuleer latency meting tussen twee nodes"""
        # In een echte implementatie: ping of andere netwerk meting
        base_latency = 10.0  # ms
        variation = random.uniform(-2.0, 2.0)
        return max(1.0, base_latency + variation)
    
    def _simulate_bandwidth_measurement(self, from_node: str, to_node: str) -> float:
        """Simuleer bandwidth meting tussen twee nodes"""
        # In een echte implementatie: speedtest of andere meting
        base_bandwidth = 100.0  # Mbps
        variation = random.uniform(-10.0, 10.0)
        return max(1.0, base_bandwidth + variation)
    
    def _simulate_reliability_measurement(self, from_node: str, to_node: str) -> float:
        """Simuleer reliabiliteitsmeting tussen twee nodes"""
        # In een echte implementatie: succes/fout ratio meting
        base_reliability = 0.99
        variation = random.uniform(-0.01, 0.01)
        return max(0.9, min(1.0, base_reliability + variation))
    
    async def _collect_node_metrics(self):
        """Verzamel metrieken van alle nodes"""
        for node_id, metrics in self.topology.nodes.items():
            # Simuleer metrics collectie
            simulated_metrics = self._simulate_node_metrics(node_id)
            
            # Update metrics
            self.topology.update_node_metrics(node_id, **simulated_metrics)
    
    def _simulate_node_metrics(self, node_id: str) -> Dict[str, float]:
        """Simuleer node metrics voor een node"""
        import random
        
        return {
            'latency': random.uniform(5.0, 50.0),
            'cpu_usage': random.uniform(0.1, 0.8),
            'memory_usage': random.uniform(0.2, 0.7),
            'gpu_usage': random.uniform(0.0, 0.9),
            'bandwidth_up': random.uniform(10.0, 500.0),
            'bandwidth_down': random.uniform(10.0, 500.0),
            'packet_loss': random.uniform(0.0, 0.02),
            'uptime': random.uniform(0.95, 1.0),
            'response_time': random.uniform(1.0, 20.0),
            'error_rate': random.uniform(0.0, 0.005)
        }
    
    async def _broadcast_metrics_update(self, node_id: str, metrics: Dict[str, float]):
        """Broadcast metrics update naar andere nodes"""
        local_identity = self.identity_manager.get_local_identity()
        if not local_identity:
            return
        
        # Maak mesh metrics message
        mesh_metrics_msg = {
            'node_id': node_id,
            'metrics': metrics,
            'timestamp': time.time()
        }
        
        # Broadcast via link
        from .link import Message as LinkMessage
        link_msg = LinkMessage(
            sender_id=local_identity.node_id,
            recipient_id=None,
            message_type="mesh_metrics",
            payload=mesh_metrics_msg
        )
        
        await self.link.broadcast(link_msg)
    
    async def _handle_mesh_metrics(self, message: Message, addr):
        """Behandel inkomende mesh metrics berichten"""
        try:
            mesh_metrics = message.payload
            
            # Update metrics voor de node
            node_id = mesh_metrics['node_id']
            metrics = mesh_metrics['metrics']
            
            self.topology.update_node_metrics(node_id, **metrics)
            
        except Exception as e:
            logger.error(f"Error handling mesh metrics: {e}")
    
    async def _handle_mesh_topology(self, message: Message, addr):
        """Behandel inkomende mesh topology berichten"""
        try:
            # TODO: Implementeer topology exchange
            pass
        except Exception as e:
            logger.error(f"Error handling mesh topology: {e}")
    
    def set_node_added_handler(self, handler: Callable):
        """Stel een handler in voor toegevoegde nodes"""
        self._node_added_handler = handler
    
    def set_node_removed_handler(self, handler: Callable):
        """Stel een handler in voor verwijderde nodes"""
        self._node_removed_handler = handler
    
    def set_topology_changed_handler(self, handler: Callable):
        """Stel een handler in voor topologie veranderingen"""
        self._topology_changed_handler = handler
    
    def is_running(self) -> bool:
        """Controleer of mesh actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"NoodleMesh(nodes={self.get_node_count()}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"NoodleMesh(nodes={self.get_node_count()}, "
                f"edges={self.topology.get_edge_count()}, "
                f"running={self._running})")


