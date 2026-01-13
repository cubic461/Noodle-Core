"""
Utilities and helper classes for network communication.
Includes serialization, deserialization, and data structures.
"""

import torch
import numpy as np
from typing import Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime
import pickle
import json


@dataclass
class NodeInfo:
    """Information about a worker node."""
    node_id: str
    host: str
    port: int
    hardware: 'HardwareInfo'
    load_factor: float = 0.0  # 0.0 = idle, 1.0 = fully loaded


@dataclass
class HardwareInfo:
    """Hardware capabilities."""
    device_type: str  # GPU, CPU, iGPU
    device_name: str
    total_memory_gb: float
    compute_capability: float
    network_bandwidth_mbps: float


@dataclass
class ExecutionMetadata:
    """Metadata about execution."""
    forward_latency_ms: float
    transfer_latency_ms: float = 0.0
    peak_memory_mb: float = 0.0
    device: str = "cpu"
    stage_index: int = 0


@dataclass
class Capabilities:
    """Node capabilities."""
    node_id: str
    hardware: HardwareInfo
    supported_dtypes: list
    available_memory_gb: float
    bandwidth_mbps: float


@dataclass
class SessionState:
    """State of inference session."""
    session_id: str
    created_at: datetime
    stage_assignments: Dict[str, str]  # stage -> node_id
    sequence_length: int = 0
    last_access: datetime = None


@dataclass
class InferenceMetrics:
    """Inference performance metrics."""
    request_id: str
    total_latency_ms: float
    num_stages: int
    stage_latencies: Dict[str, float]
    transfer_latencies: Dict[str, float]
    timestamp: datetime = None

    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now()

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            'request_id': self.request_id,
            'total_latency_ms': self.total_latency_ms,
            'num_stages': self.num_stages,
            'stage_latencies': self.stage_latencies,
            'transfer_latencies': self.transfer_latencies,
            'timestamp': self.timestamp.isoformat(),
        }

    def __str__(self) -> str:
        return f"Inference(request_id={self.request_id}, latency={self.total_latency_ms:.2f}ms)"


def serialize_tensor(tensor: torch.Tensor) -> Dict[str, Any]:
    """
    Serialize PyTorch tensor for network transmission.

    Args:
        tensor: PyTorch tensor to serialize

    Returns:
        Dictionary with serialized data
    """
    # Convert to numpy
    numpy_array = tensor.cpu().detach().numpy()

    # Get dtype string
    dtype_map = {
        'float32': 'float32',
        'float64': 'float64',
        'float16': 'float16',
        'bfloat16': 'bfloat16',
        'int64': 'int64',
        'int32': 'int32',
        'int16': 'int16',
        'int8': 'int8',
        'uint8': 'uint8',
    }

    dtype_str = str(tensor.dtype).replace('torch.', '')
    dtype_str = dtype_map.get(dtype_str, 'float32')

    # Serialize to bytes
    data_bytes = pickle.dumps(numpy_array, protocol=pickle.HIGHEST_PROTOCOL)

    return {
        'dtype': dtype_str,
        'shape': list(tensor.shape),
        'data': data_bytes,
        'num_bytes': len(data_bytes),
    }


def deserialize_tensor(tensor_data: Dict[str, Any]) -> torch.Tensor:
    """
    Deserialize tensor data from network.

    Args:
        tensor_data: Dictionary with serialized data

    Returns:
        PyTorch tensor
    """
    # Deserialize numpy array
    numpy_array = pickle.loads(tensor_data['data'])

    # Convert to tensor
    tensor = torch.from_numpy(numpy_array)

    return tensor


def create_forward_request(
    session_id: str,
    token_index: int,
    tensor: torch.Tensor,
) -> Dict[str, Any]:
    """Create forward request structure."""
    return {
        'session_id': session_id,
        'token_index': token_index,
        'input_activations': serialize_tensor(tensor),
        'stage_ids': [],  # Would be populated by coordinator
    }


def create_session_request(
    session_id: str,
    stage_config: Dict[str, Any],
    layer_names: list,
    max_sequence_length: int,
    dtype: str
) -> Dict[str, Any]:
    """Create session initialization request."""
    return {
        'session_id': session_id,
        'stage_config': stage_config,
        'layer_names': layer_names,
        'max_sequence_length': max_sequence_length,
        'dtype': dtype,
    }


class MetricsCollector:
    """Collects and aggregates inference metrics."""

    def __init__(self):
        self.metrics_history: list = []
        self.total_requests = 0
        self.total_latency_ms = 0.0
        self.total_transfer_latency_ms = 0.0

    def record_inference_latency(self, latency_ms: float):
        """Record inference latency."""
        self.total_requests += 1
        self.total_latency_ms += latency_ms

    def record_transfer_latency(self, latency_ms: float):
        """Record data transfer latency."""
        self.total_transfer_latency_ms += latency_ms

    def record_inference(self, metrics: InferenceMetrics):
        """Record complete inference metrics."""
        self.metrics_history.append(metrics)

    def get_summary(self) -> Dict[str, Any]:
        """Get metrics summary."""
        avg_latency = self.total_latency_ms / max(self.total_requests, 1)
        avg_transfer = self.total_transfer_latency_ms / max(self.total_requests, 1)

        return {
            'total_requests': self.total_requests,
            'total_latency_ms': self.total_latency_ms,
            'total_transfer_latency_ms': self.total_transfer_latency_ms,
            'avg_latency_ms': avg_latency,
            'avg_transfer_latency_ms': avg_transfer,
            'throughput_rps': 1000.0 / avg_latency if avg_latency > 0 else 0.0,
            'num_metrics': len(self.metrics_history),
        }

    def export_to_json(self, filepath: str):
        """Export metrics to JSON file."""
        data = {
            'summary': self.get_summary(),
            'history': [m.to_dict() for m in self.metrics_history],
        }

        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)


class NodeRegistry:
    """Registry of available worker nodes."""

    def __init__(self):
        self.nodes: Dict[str, NodeInfo] = {}
        self.last_heartbeats: Dict[str, datetime] = {}
        self.node_loads: Dict[str, float] = {}

    def register_node(self, node_info: NodeInfo):
        """Register or update node."""
        node_id = node_info.node_id
        self.nodes[node_id] = node_info
        self.last_heartbeats[node_id] = datetime.now()

    def unregister_node(self, node_id: str):
        """Remove node from registry."""
        self.nodes.pop(node_id, None)
        self.last_heartbeats.pop(node_id, None)
        self.node_loads.pop(node_id, None)

    def get_available_nodes(self) -> Dict[str, NodeInfo]:
        """Get all available nodes."""
        return dict(self.nodes)

    def get_node(self, node_id: str) -> Optional[NodeInfo]:
        """Get specific node."""
        return self.nodes.get(node_id)

    def update_load(self, node_id: str, load_factor: float):
        """Update node load factor."""
        self.node_loads[node_id] = load_factor

    def heartbeat(self, node_id: str):
        """Update node heartbeat."""
        self.last_heartbeats[node_id] = datetime.now()

    def check_all_heartbeats(self, timeout_sec: float = 30.0):
        """Check for nodes with expired heartbeats."""
        now = datetime.now()

        for node_id, last_heartbeat in list(self.last_heartbeats.items()):
            age = (now - last_heartbeat).total_seconds()

            if age > timeout_sec:
                # Mark as unresponsive
                node_info = self.nodes.get(node_id)
                if node_info:
                    node_info.load_factor = 1.0  # Mark as unavailable

                # Would also emit event here
    def select_best_node(self, required_memory_gb: float = 0.0) -> Optional[str]:
        """Select best node based on load and resources."""
        if not self.nodes:
            return None

        # Filter nodes with sufficient memory
        candidate_nodes = []

        for node_id, node_info in self.nodes.items():
            # Skip over-loaded nodes
            if node_info.load_factor > 0.9:
                continue

            # Check memory
            if node_info.hardware.total_memory_gb >= required_memory_gb:
                candidate_nodes.append((node_id, node_info))

        if not candidate_nodes:
            return None

        # Sort by load (ascending) and select best
        candidate_nodes.sort(key=lambda x: x[1].load_factor)
        best_node_id = candidate_nodes[0][0]

        return best_node_id

    def get_metrics(self) -> Dict[str, Any]:
        """Get registry metrics."""
        return {
            'total_nodes': len(self.nodes),
            'healthy_nodes': sum(
                1 for node_id in self.nodes
                if (datetime.now() - self.last_heartbeats.get(node_id, datetime.now())).total_seconds() < 30.0
            ),
            'avg_load': sum(self.node_loads.values()) / len(self.node_loads) if self.node_loads else 0.0,
        }


class SessionManager:
    """Manages inference sessions."""

    def __init__(self, session_timeout_sec: float = 300.0):
        self.sessions: Dict[str, SessionState] = {}
        self.session_timeout_sec = session_timeout_sec

    def add_session(self, session_state: SessionState):
        """Add new session."""
        self.sessions[session_state.session_id] = session_state

    def get_session(self, session_id: str) -> Optional[SessionState]:
        """Get session by ID."""
        return self.sessions.get(session_id)

    def update_session(self, session_id: str, **kwargs):
        """Update session state."""
        if session_id in self.sessions:
            session = self.sessions[session_id]
            for key, value in kwargs.items():
                if hasattr(session, key):
                    setattr(session, key, value)

            session.last_access = datetime.now()

    def cleanup_expired_sessions(self) -> list:
        """Remove expired sessions."""
        now = datetime.now()
        expired = []

        for session_id, session in list(self.sessions.items()):
            age = (now - session.last_access if session.last_access else now).total_seconds()

            if age > self.session_timeout_sec:
                expired.append(session_id)
                del self.sessions[session_id]

        return expired

    def __contains__(self, session_id: str) -> bool:
        return session_id in self.sessions

    def __len__(self) -> int:
        return len(self.sessions)

    def get_active_session_ids(self) -> list:
        """Get list of active session IDs."""
        return list(self.sessions.keys())


# Helper functions for optimization

def estimate_tensor_transfer_time(
    tensor: torch.Tensor,
    bandwidth_mbps: float
) -> float:
    """
    Estimate tensor transfer time over network.

    Args:
        tensor: Tensor to estimate
        bandwidth_mbps: Network bandwidth in Mbps

    Returns:
        Estimated transfer time in milliseconds
    """
    num_bytes = tensor.numel() * tensor.element_size()

    # Convert to Mb
    num_mb = (num_bytes * 8) / (1024 * 1024)

    # Account for protocol overhead (~10%)
    effective_mb = num_mb * 1.1

    # Time = distance / speed
    transfer_time_ms = (effective_mb / bandwidth_mbps) * 1000

    return transfer_time_ms


def tokens_to_tensor(tokens: list) -> torch.Tensor:
    """Convert token list to tensor."""
    return torch.tensor(tokens, dtype=torch.long)
