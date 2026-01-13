"""
Noodlenet::Routing - routing.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Automatic message routing for NoodleNet - Intelligent routing with load balancing and fault tolerance.
"""

import asyncio
import time
import heapq
import logging
import random
from typing import Dict, List, Optional, Set, Tuple, Any, Callable
from dataclasses import dataclass, field
from collections import defaultdict, deque
from .config import NoodleNetConfig
from .identity import NodeIdentity
from .link import Message

logger = logging.getLogger(__name__)


@dataclass
class RouteInfo:
    """Information about a route through the network"""
    
    path: List[str]  # List of node IDs
    cost: float  # Total cost of the route
    latency: float  # Total latency
    bandwidth: float  # Minimum bandwidth
    reliability: float  # Minimum reliability
    last_used: float = field(default_factory=time.time)
    usage_count: int = 0
    success_count: int = 0
    failure_count: int = 0
    
    def update_usage(self, success: bool):
        """Update route usage statistics"""
        self.last_used = time.time()
        self.usage_count += 1
        
        if success:
            self.success_count += 1
        else:
            self.failure_count += 1
    
    def get_success_rate(self) -> float:
        """Calculate success rate of this route"""
        if self.usage_count == 0:
            return 1.0
        return self.success_count / self.usage_count
    
    def get_effective_cost(self) -> float:
        """Calculate effective cost considering success rate"""
        success_rate = self.get_success_rate()
        if success_rate < 0.5:
            # Penalize unreliable routes heavily
            return self.cost * 10.0
        elif success_rate < 0.8:
            # Lightly penalize somewhat unreliable routes
            return self.cost * (2.0 - success_rate)
        else:
            # Reward reliable routes
            return self.cost * (1.0 + (1.0 - success_rate) * 0.5)
    
    def __lt__(self, other: 'RouteInfo') -> bool:
        """Compare routes for priority queue"""
        return self.get_effective_cost() < other.get_effective_cost()


@dataclass
class RoutingTable:
    """Routing table for a node"""
    
    node_id: str
    routes: Dict[str, RouteInfo] = field(default_factory=dict)  # destination -> RouteInfo
    last_update: float = field(default_factory=time.time)
    
    def add_route(self, destination: str, route_info: RouteInfo):
        """Add or update a route"""
        self.routes[destination] = route_info
        self.last_update = time.time()
    
    def get_route(self, destination: str) -> Optional[RouteInfo]:
        """Get best route to destination"""
        return self.routes.get(destination)
    
    def remove_route(self, destination: str):
        """Remove a route"""
        if destination in self.routes:
            del self.routes[destination]
    
    def cleanup_stale_routes(self, timeout: float = 300.0):
        """Remove stale routes"""
        current_time = time.time()
        stale_destinations = [
            dest for dest, route in self.routes.items()
            if current_time - route.last_used > timeout
        ]
        
        for dest in stale_destinations:
            del self.routes[dest]
    
    def get_route_count(self) -> int:
        """Get number of routes"""
        return len(self.routes)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert routing table to dictionary"""
        return {
            'node_id': self.node_id,
            'routes': {
                dest: {
                    'path': route.path,
                    'cost': route.cost,
                    'latency': route.latency,
                    'bandwidth': route.bandwidth,
                    'reliability': route.reliability,
                    'success_rate': route.get_success_rate(),
                    'usage_count': route.usage_count,
                    'last_used': route.last_used
                }
                for dest, route in self.routes.items()
            },
            'last_update': self.last_update,
            'route_count': self.get_route_count()
        }


class MessageRouter:
    """Intelligent message router with load balancing and fault tolerance"""
    
    def __init__(self, local_node_id: str, config: Optional[NoodleNetConfig] = None):
        """
        Initialize the message router
        
        Args:
            local_node_id: ID of the local node
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.config = config or NoodleNetConfig()
        
        # Routing components
        self.routing_tables: Dict[str, RoutingTable] = {}  # node_id -> RoutingTable
        self.route_cache: Dict[str, RouteInfo] = {}  # destination -> RouteInfo
        self.active_routes: Dict[str, RouteInfo] = {}  # message_id -> RouteInfo
        
        # Load balancing
        self.load_balancer: LoadBalancer = LoadBalancer()
        
        # Fault tolerance
        self.fault_detector: FaultDetector = FaultDetector()
        
        # Performance tracking
        self._stats = {
            'messages_routed': 0,
            'routes_discovered': 0,
            'routes_failed': 0,
            'load_balanced_decisions': 0,
            'fault_detected': 0,
            'cache_hits': 0,
            'cache_misses': 0
        }
        
        # Event handlers
        self._route_discovered_handler: Optional[Callable] = None
        self._route_failed_handler: Optional[Callable] = None
        self._fault_detected_handler: Optional[Callable] = None
    
    def add_routing_table(self, routing_table: RoutingTable):
        """
        Add a routing table from another node
        
        Args:
            routing_table: Routing table to add
        """
        self.routing_tables[routing_table.node_id] = routing_table
        self._stats['routes_discovered'] += 1
        
        if self._route_discovered_handler:
            self._route_discovered_handler(routing_table)
        
        logger.debug(f"Added routing table from node {routing_table.node_id}")
    
    def remove_routing_table(self, node_id: str):
        """
        Remove a routing table
        
        Args:
            node_id: ID of the node to remove
        """
        if node_id in self.routing_tables:
            del self.routing_tables[node_id]
            logger.debug(f"Removed routing table from node {node_id}")
    
    def find_route(self, destination: str, message: Optional[Message] = None) -> Optional[RouteInfo]:
        """
        Find best route to destination
        
        Args:
            destination: Destination node ID
            message: Optional message for context-aware routing
            
        Returns:
            Best route or None if no route found
        """
        # Check cache first
        if destination in self.route_cache:
            cached_route = self.route_cache[destination]
            if self._is_route_valid(cached_route):
                self._stats['cache_hits'] += 1
                return cached_route
            else:
                del self.route_cache[destination]
        
        self._stats['cache_misses'] += 1
        
        # Find routes from all routing tables
        candidate_routes = []
        
        for node_id, routing_table in self.routing_tables.items():
            route = routing_table.get_route(destination)
            if route and self._is_route_valid(route):
                candidate_routes.append((node_id, route))
        
        # Add local routes if available
        if self.local_node_id in self.routing_tables:
            local_route = self.routing_tables[self.local_node_id].get_route(destination)
            if local_route and self._is_route_valid(local_route):
                candidate_routes.append((self.local_node_id, local_route))
        
        if not candidate_routes:
            return None
        
        # Select best route based on multiple criteria
        best_route = self._select_best_route(candidate_routes, message)
        
        if best_route:
            # Cache the best route
            self.route_cache[destination] = best_route
        
        return best_route
    
    def _select_best_route(self, candidate_routes: List[Tuple[str, RouteInfo]], 
                         message: Optional[Message] = None) -> Optional[RouteInfo]:
        """
        Select the best route from candidates
        
        Args:
            candidate_routes: List of (node_id, route) tuples
            message: Optional message for context
            
        Returns:
            Best route or None
        """
        if not candidate_routes:
            return None
        
        # Filter out routes through failed nodes
        valid_routes = [
            (node_id, route) for node_id, route in candidate_routes
            if not self.fault_detector.is_node_failed(node_id)
        ]
        
        if not valid_routes:
            return None
        
        # Consider message type for routing decision
        message_type = message.message_type if message else "default"
        
        # Apply load balancing
        if len(valid_routes) > 1:
            selected_node_id, selected_route = self.load_balancer.select_route(
                valid_routes, message_type
            )
            self._stats['load_balanced_decisions'] += 1
        else:
            selected_node_id, selected_route = valid_routes[0]
        
        # Update route usage
        selected_route.update_usage(True)
        
        return selected_route
    
    def _is_route_valid(self, route: RouteInfo) -> bool:
        """
        Check if a route is still valid
        
        Args:
            route: Route to check
            
        Returns:
            True if route is valid
        """
        # Check if route is too old
        if time.time() - route.last_used > self.config.routing_timeout:
            return False
        
        # Check if route has too high failure rate
        if route.get_success_rate() < 0.3:  # Less than 30% success rate
            return False
        
        # Check if route cost is reasonable
        if route.cost > self.config.max_route_cost:
            return False
        
        return True
    
    def update_route_performance(self, destination: str, success: bool, 
                           latency: Optional[float] = None):
        """
        Update performance information for a route
        
        Args:
            destination: Destination node ID
            success: Whether the route was successful
            latency: Optional latency measurement
        """
        # Update cached route if exists
        if destination in self.route_cache:
            cached_route = self.route_cache[destination]
            cached_route.update_usage(success)
            
            # Update latency if provided
            if latency is not None:
                # Exponential moving average for latency
                alpha = 0.1  # Learning rate
                cached_route.latency = alpha * latency + (1 - alpha) * cached_route.latency
        
        # Update fault detector
        if not success:
            self.fault_detector.record_failure(destination)
        
        # Update statistics
        self._stats['messages_routed'] += 1
        if not success:
            self._stats['routes_failed'] += 1
    
    def cleanup_stale_routes(self):
        """Clean up stale routes and routing tables"""
        current_time = time.time()
        
        # Clean up route cache
        stale_destinations = [
            dest for dest, route in self.route_cache.items()
            if current_time - route.last_used > self.config.routing_timeout
        ]
        
        for dest in stale_destinations:
            del self.route_cache[dest]
        
        # Clean up routing tables
        for routing_table in self.routing_tables.values():
            routing_table.cleanup_stale_routes(self.config.routing_timeout)
        
        # Clean up fault detector
        self.fault_detector.cleanup_stale_failures()
        
        logger.debug(f"Cleaned up {len(stale_destinations)} stale routes")
    
    def get_routing_statistics(self) -> Dict[str, Any]:
        """
        Get comprehensive routing statistics
        
        Returns:
            Dictionary with routing statistics
        """
        stats = self._stats.copy()
        
        # Add cache statistics
        total_requests = stats['cache_hits'] + stats['cache_misses']
        if total_requests > 0:
            stats['cache_hit_rate'] = stats['cache_hits'] / total_requests
        else:
            stats['cache_hit_rate'] = 0.0
        
        # Add fault detector statistics
        stats.update(self.fault_detector.get_statistics())
        
        # Add load balancer statistics
        stats.update(self.load_balancer.get_statistics())
        
        # Add routing table statistics
        stats['routing_tables_count'] = len(self.routing_tables)
        stats['total_routes'] = sum(rt.get_route_count() for rt in self.routing_tables.values())
        stats['cached_routes'] = len(self.route_cache)
        
        return stats
    
    def set_route_discovered_handler(self, handler: Callable):
        """Set handler for route discovery events"""
        self._route_discovered_handler = handler
    
    def set_route_failed_handler(self, handler: Callable):
        """Set handler for route failure events"""
        self._route_failed_handler = handler
    
    def set_fault_detected_handler(self, handler: Callable):
        """Set handler for fault detection events"""
        self._fault_detected_handler = handler
    
    def reset_statistics(self):
        """Reset all routing statistics"""
        self._stats = {
            'messages_routed': 0,
            'routes_discovered': 0,
            'routes_failed': 0,
            'load_balanced_decisions': 0,
            'fault_detected': 0,
            'cache_hits': 0,
            'cache_misses': 0
        }
        
        self.load_balancer.reset_statistics()
        self.fault_detector.reset_statistics()


class LoadBalancer:
    """Load balancer for intelligent route selection"""
    
    def __init__(self):
        """Initialize load balancer"""
        self.node_loads: Dict[str, float] = {}  # node_id -> load (0.0-1.0)
        self.node_capacities: Dict[str, float] = {}  # node_id -> capacity
        self._stats = {
            'selections_by_load': 0,
            'selections_by_round_robin': 0,
            'selections_by_random': 0,
            'load_updates': 0
        }
    
    def update_node_load(self, node_id: str, load: float):
        """
        Update load information for a node
        
        Args:
            node_id: ID of the node
            load: Load value (0.0-1.0)
        """
        self.node_loads[node_id] = load
        self._stats['load_updates'] += 1
    
    def update_node_capacity(self, node_id: str, capacity: float):
        """
        Update capacity information for a node
        
        Args:
            node_id: ID of the node
            capacity: Capacity value
        """
        self.node_capacities[node_id] = capacity
    
    def select_route(self, routes: List[Tuple[str, RouteInfo]], 
                  message_type: str = "default") -> Tuple[str, RouteInfo]:
        """
        Select best route based on load balancing strategy
        
        Args:
            routes: List of (node_id, route) tuples
            message_type: Type of message for strategy selection
            
        Returns:
            Selected (node_id, route) tuple
        """
        if not routes:
            raise ValueError("No routes available")
        
        # Strategy selection based on message type
        if message_type in ["heartbeat", "discovery"]:
            # Use round-robin for system messages
            return self._round_robin_selection(routes)
        elif message_type in ["data_transfer", "bulk_data"]:
            # Use load-based selection for data transfer
            return self._load_based_selection(routes)
        elif message_type in ["urgent", "critical"]:
            # Use fastest route for urgent messages
            return self._fastest_route_selection(routes)
        else:
            # Use weighted selection for general messages
            return self._weighted_selection(routes)
    
    def _round_robin_selection(self, routes: List[Tuple[str, RouteInfo]]) -> Tuple[str, RouteInfo]:
        """Round-robin selection"""
        # Simple round-robin based on route order
        index = self._stats['selections_by_round_robin'] % len(routes)
        selected_route = routes[index]
        self._stats['selections_by_round_robin'] += 1
        return selected_route
    
    def _load_based_selection(self, routes: List[Tuple[str, RouteInfo]]) -> Tuple[str, RouteInfo]:
        """Load-based selection"""
        # Calculate available capacity for each route
        route_scores = []
        
        for node_id, route in routes:
            node_load = self.node_loads.get(node_id, 0.5)  # Default to 50% load
            node_capacity = self.node_capacities.get(node_id, 1.0)  # Default to full capacity
            
            available_capacity = node_capacity * (1.0 - node_load)
            
            # Consider route reliability
            success_rate = route.get_success_rate()
            
            # Calculate score (higher is better)
            score = available_capacity * success_rate
            route_scores.append((node_id, route, score))
        
        # Select route with highest score
        route_scores.sort(key=lambda x: x[2], reverse=True)
        selected_route = route_scores[0]
        self._stats['selections_by_load'] += 1
        
        return (selected_route[0], selected_route[1])
    
    def _fastest_route_selection(self, routes: List[Tuple[str, RouteInfo]]) -> Tuple[str, RouteInfo]:
        """Select fastest route based on latency"""
        fastest_route = min(routes, key=lambda x: x[1].latency)
        self._stats['selections_by_random'] += 1  # Using this counter for fastest selection
        return fastest_route
    
    def _weighted_selection(self, routes: List[Tuple[str, RouteInfo]]) -> Tuple[str, RouteInfo]:
        """Weighted selection considering multiple factors"""
        route_scores = []
        
        for node_id, route in routes:
            # Factors for selection
            latency_score = 1.0 / max(route.latency, 1.0)  # Lower latency = higher score
            reliability_score = route.get_success_rate()  # Higher success rate = higher score
            load_score = 1.0 - self.node_loads.get(node_id, 0.5)  # Lower load = higher score
            
            # Combined score (weighted sum)
            combined_score = (
                latency_score * 0.4 +
                reliability_score * 0.4 +
                load_score * 0.2
            )
            
            route_scores.append((node_id, route, combined_score))
        
        # Select route with highest score
        route_scores.sort(key=lambda x: x[2], reverse=True)
        selected_route = route_scores[0]
        self._stats['selections_by_random'] += 1  # Using this counter for weighted selection
        
        return (selected_route[0], selected_route[1])
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get load balancer statistics"""
        stats = self._stats.copy()
        stats['node_count'] = len(self.node_loads)
        stats['avg_load'] = sum(self.node_loads.values()) / max(len(self.node_loads), 1)
        stats['total_capacity'] = sum(self.node_capacities.values())
        return stats
    
    def reset_statistics(self):
        """Reset load balancer statistics"""
        self._stats = {
            'selections_by_load': 0,
            'selections_by_round_robin': 0,
            'selections_by_random': 0,
            'load_updates': 0
        }


class FaultDetector:
    """Fault detection and recovery for routing"""
    
    def __init__(self):
        """Initialize fault detector"""
        self.node_failures: Dict[str, List[float]] = {}  # node_id -> list of failure timestamps
        self.suspected_nodes: Set[str] = set()  # Nodes suspected of being faulty
        self.recovery_times: Dict[str, float] = {}  # node_id -> recovery timestamp
        
        self._stats = {
            'failures_detected': 0,
            'nodes_suspected': 0,
            'nodes_recovered': 0,
            'false_positives': 0
        }
    
    def record_failure(self, node_id: str):
        """
        Record a failure for a node
        
        Args:
            node_id: ID of the node that failed
        """
        current_time = time.time()
        
        if node_id not in self.node_failures:
            self.node_failures[node_id] = []
        
        self.node_failures[node_id].append(current_time)
        
        # Check if node should be suspected
        recent_failures = [
            failure_time for failure_time in self.node_failures[node_id]
            if current_time - failure_time < 60  # Last minute
        ]
        
        if len(recent_failures) >= 3:  # 3+ failures in last minute
            if node_id not in self.suspected_nodes:
                self.suspected_nodes.add(node_id)
                self._stats['nodes_suspected'] += 1
                logger.warning(f"Node {node_id} suspected of being faulty")
        
        self._stats['failures_detected'] += 1
    
    def record_recovery(self, node_id: str):
        """
        Record recovery of a node
        
        Args:
            node_id: ID of the node that recovered
        """
        current_time = time.time()
        
        if node_id in self.suspected_nodes:
            self.suspected_nodes.remove(node_id)
            self.recovery_times[node_id] = current_time
            self._stats['nodes_recovered'] += 1
            logger.info(f"Node {node_id} recovered from suspected state")
        else:
            # False positive - node was never suspected
            self._stats['false_positives'] += 1
    
    def is_node_failed(self, node_id: str) -> bool:
        """
        Check if a node is considered failed
        
        Args:
            node_id: ID of the node to check
            
        Returns:
            True if node is considered failed
        """
        return node_id in self.suspected_nodes
    
    def cleanup_stale_failures(self, max_age: float = 300.0):
        """
        Clean up stale failure records
        
        Args:
            max_age: Maximum age of failure records in seconds
        """
        current_time = time.time()
        
        for node_id, failures in list(self.node_failures.items()):
            # Remove old failures
            recent_failures = [
                failure_time for failure_time in failures
                if current_time - failure_time < max_age
            ]
            
            if recent_failures:
                self.node_failures[node_id] = recent_failures
            else:
                del self.node_failures[node_id]
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get fault detector statistics"""
        stats = self._stats.copy()
        stats['suspected_nodes_count'] = len(self.suspected_nodes)
        stats['failed_nodes_count'] = len(self.node_failures)
        stats['recovered_nodes_count'] = len(self.recovery_times)
        return stats
    
    def reset_statistics(self):
        """Reset fault detector statistics"""
        self._stats = {
            'failures_detected': 0,
            'nodes_suspected': 0,
            'nodes_recovered': 0,
            'false_positives': 0
        }

