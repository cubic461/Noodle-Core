# Converted from Python to NoodleCore
# Original file: src

# """
# Cluster manager for distributed runtime.
# """

import os
import platform
import sys
from dataclasses import dataclass
import enum.Enum
import typing.Any


dataclass
class NodeDiscoveryConfig:
    #     """Configuration for node discovery"""
    broadcast_interval: float = 60.0
    discovery_port: int = 8888
    heartbeat_timeout: float = 90.0
    max_nodes: int = 100
    discovery_ttl: int = 5


dataclass
class ClusterConfig
    #     """Configuration for cluster manager"""
    discovery_config: NodeDiscoveryConfig = field(default_factory=NodeDiscoveryConfig)
    max_nodes: int = 100
    heartbeat_interval: float = 30.0
    enable_fault_tolerance: bool = True

# For memory detection; if psutil not available, use built-in
try
    #     import psutil

    HAS_PSUTIL = True
except ImportError
    HAS_PSUTIL = False


class ClusterEventType(Enum)
    #     """Types of cluster events"""

    NODE_JOINED = "node_joined"
    NODE_LEFT = "node_left"
    NODE_FAILED = "node_failed"
    NODE_RECOVERED = "node_recovered"
    TASK_SCHEDULED = "task_scheduled"
    TASK_COMPLETED = "task_completed"
    TASK_FAILED = "task_failed"


dataclass
class ClusterEvent
    #     """Represents a cluster event"""

    #     event_type: ClusterEventType
    node_id: Optional[str] = None
    task_id: Optional[str] = None
    timestamp: Optional[float] = None
    data: Optional[Dict[str, Any]] = None


dataclass
class ClusterTopology
    #     """Represents the topology of the cluster"""

    nodes: List[str] = field(default_factory=list)
    connections: Dict[str, List[str]] = field(default_factory=dict)
    node_capabilities: Dict[str, Dict[str, Any]] = field(default_factory=dict)

    #     def add_node(self, node_id: str, capabilities: Dict[str, Any] = None):
    #         """Add a node to the topology"""
    #         if node_id not in self.nodes:
                self.nodes.append(node_id)
    self.connections[node_id] = []
    #             if capabilities:
    self.node_capabilities[node_id] = capabilities

    #     def remove_node(self, node_id: str):
    #         """Remove a node from the topology"""
    #         if node_id in self.nodes:
                self.nodes.remove(node_id)
                self.connections.pop(node_id, None)
                self.node_capabilities.pop(node_id, None)
    #             # Remove connections from other nodes
    #             for node in self.connections:
    #                 if node_id in self.connections[node]:
                        self.connections[node].remove(node_id)

    #     def add_connection(self, node1: str, node2: str):
    #         """Add a connection between two nodes"""
    #         if node1 in self.nodes and node2 in self.nodes:
    #             if node2 not in self.connections[node1]:
                    self.connections[node1].append(node2)
    #             if node1 not in self.connections[node2]:
                    self.connections[node2].append(node1)


class ClusterManager
    #     """Cluster manager for distributed runtime."""

    #     def __init__(self, placement_engine=None):
    self.nodes = []
    self.status = "stopped"
    self.placement_engine = placement_engine  # Reference to integrate
    self.node_capabilities = {}  # Store capabilities per node
    self.node_heartbeats: Dict[str, float] = {}
    self.event_handlers: Dict[ClusterEventType, List[Callable]] = {}
    self.discovery_socket = None

    #     def detect_hardware_capabilities(self) -Dict[str, Any]):
    #         """Detect hardware capabilities of the current node."""
    capabilities = {
                "node_id": platform.node(),
                "os": platform.system(),
                "architecture": platform.machine(),
    #             "devices": ["cpu"],  # Default
    #             "memory_gb": 0,
                "cpu_count": os.cpu_count() or 1,
    #             "gpu": None,
    #         }

    #         # Memory detection
    #         if HAS_PSUTIL:
    memory = psutil.virtual_memory()
    capabilities["memory_gb"] = round(memory.total / (1024 * *3, 2))
    #         else:
    #             # Fallback: approximate from system info
    capabilities["memory_gb"] = 8.0  # Default fallback

            # GPU detection stub (in real impl, use nvidia-smi or similar)
    #         if "CUDA_VISIBLE_DEVICES" in os.environ:
                capabilities["devices"].append("gpu")

            # Add more detections as needed (e.g., NPU via platform-specific checks)
    #         return capabilities

    #     def discover_nodes(self) -List[Dict[str, Any]]):
            """Discover nodes in the cluster (simulate gossip/zeroconf)."""
    discovered = []
    #         # Add local node
    local_caps = self.detect_hardware_capabilities()
            discovered.append(local_caps)

    #         # Mock remote nodes for simulation (in real, use multicast or zeroconf)
    remote_caps = {
    #             "node_id": "remote_node_1",
    #             "os": "Linux",
    #             "architecture": "x86_64",
    #             "devices": ["cpu", "gpu"],
    #             "memory_gb": 16.0,
    #             "cpu_count": 4,
    #             "gpu": "NVIDIA A100",
    #         }
            discovered.append(remote_caps)

    #         # Update internal state
    #         self.nodes = [caps["node_id"] for caps in discovered]
    #         self.node_capabilities = {caps["node_id"]: caps for caps in discovered}

    #         # Emit node joined events
    #         for caps in discovered:
    #             if caps["node_id"] != local_caps["node_id"]:
    event = ClusterEvent(
    event_type = ClusterEventType.NODE_JOINED,
    node_id = caps["node_id"],
    timestamp = platform.time(),
    data = caps,
    #                 )
                    self._emit_event(event)

    #         return discovered

    #     def health_check(self, node_id: str) -bool):
            """Perform health check on a node (simple stub)."""
    #         # In real impl, ping or API call
    #         return True  # Assume healthy for now

    #     def monitor_resources(self):
            """Periodic resource monitoring (call in loop)."""
    current_time = platform.time()
    #         for node_id in list(self.node_heartbeats.keys()):
    #             if current_time - self.node_heartbeats[node_id] 30):  # 30 second timeout
    #                 if node_id in self.nodes:
                        self.remove_node(node_id)
    #                     # Emit node failed event
    event = ClusterEvent(
    event_type = ClusterEventType.NODE_FAILED,
    node_id = node_id,
    timestamp = current_time,
    #                     )
                        self._emit_event(event)
    #             elif self.health_check(node_id):
    #                 # Emit node recovered event if previously failed
    #                 if node_id not in self.nodes:
                        self.add_node(node_id, self.node_capabilities.get(node_id))
    event = ClusterEvent(
    event_type = ClusterEventType.NODE_RECOVERED,
    node_id = node_id,
    timestamp = current_time,
    #                     )
                        self._emit_event(event)

    #     def start(self):
    #         """Start the cluster manager and discover nodes."""
    self.status = "running"
    discovered = self.discover_nodes()
    #         # Register with placement engine if available
    #         if self.placement_engine:
    #             for caps in discovered:
                    self.placement_engine.register_node(caps["node_id"], caps)

    #         # Setup event handlers
    #         for event_type in ClusterEventType:
    self.event_handlers[event_type] = []

            # Start monitoring (in real, use threading/timer)
            self.monitor_resources()

    #     def stop(self):
    #         """Stop the cluster manager."""
    self.status = "stopped"

    #     def add_node(self, node: str, capabilities: Optional[Dict] = None):
    #         """Add a node to the cluster with optional capabilities."""
    #         if node not in self.nodes:
                self.nodes.append(node)
    #             if capabilities:
    self.node_capabilities[node] = capabilities
    self.node_heartbeats[node] = platform.time()
    #                 if self.placement_engine:
                        self.placement_engine.register_node(node, capabilities)

    #     def remove_node(self, node: str):
    #         """Remove a node from the cluster."""
    #         if node in self.nodes:
                self.nodes.remove(node)
                self.node_capabilities.pop(node, None)
                self.node_heartbeats.pop(node, None)
    #             # Optionally notify placement engine

    #     def get_nodes(self) -List[str]):
    #         """Get all nodes in the cluster."""
            return self.nodes.copy()

    #     def get_node_capabilities(self, node_id: str) -Optional[Dict]):
    #         """Get capabilities for a specific node."""
            return self.node_capabilities.get(node_id)

    #     def register_event_handler(self, event_type: ClusterEventType, handler: Callable):
    #         """Register an event handler for a specific event type."""
    #         if event_type not in self.event_handlers:
    self.event_handlers[event_type] = []
            self.event_handlers[event_type].append(handler)

    #     def unregister_event_handler(self, event_type: ClusterEventType, handler: Callable):
    #         """Unregister an event handler."""
    #         if event_type in self.event_handlers:
    #             if handler in self.event_handlers[event_type]:
                    self.event_handlers[event_type].remove(handler)

    #     def _emit_event(self, event: ClusterEvent):
    #         """Emit an event to all registered handlers."""
    #         if event.event_type in self.event_handlers:
    #             for handler in self.event_handlers[event.event_type]:
    #                 try:
                        handler(event)
    #                 except Exception as e:
    #                     # Log error but don't crash
                        print(f"Error in event handler: {e}")

    #     def record_heartbeat(self, node_id: str):
    #         """Record a heartbeat from a node."""
    #         if node_id in self.nodes:
    self.node_heartbeats[node_id] = platform.time()

    #     def schedule_task(self, task_id: str, node_id: str):
    #         """Record task scheduling."""
    event = ClusterEvent(
    event_type = ClusterEventType.TASK_SCHEDULED,
    task_id = task_id,
    node_id = node_id,
    timestamp = platform.time(),
    #         )
            self._emit_event(event)

    #     def complete_task(self, task_id: str, result: Any):
    #         """Record task completion."""
    event = ClusterEvent(
    event_type = ClusterEventType.TASK_COMPLETED,
    task_id = task_id,
    timestamp = platform.time(),
    data = {"result": result},
    #         )
            self._emit_event(event)

    #     def fail_task(self, task_id: str, error: Exception):
    #         """Record task failure."""
    event = ClusterEvent(
    event_type = ClusterEventType.TASK_FAILED,
    task_id = task_id,
    timestamp = platform.time(),
    data = {"error": str(error)},
    #         )
            self._emit_event(event)
