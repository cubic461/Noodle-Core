"""
Worker node implementation for executing inference stages.
Handles gRPC requests, model execution, and session management.
"""

import asyncio
import logging
from typing import Dict, Optional, Any
from dataclasses import dataclass, field
from datetime import datetime
import uuid
import time
import os
from pathlib import Path

import torch
import torch.nn as nn

from . import utils


@dataclass
class WorkerConfig:
    """Configuration for worker node."""
    worker_id: str = field(default_factory=lambda: f"worker-{uuid.uuid4().hex[:8]}")
    listen_host: str = "0.0.0.0"
    listen_port: int = 8082
    coordinator_host: str = "localhost"
    coordinator_port: int = 8081
    device: str = "cpu"
    max_concurrent_sessions: int = 10
    model_dir: Optional[str] = None  # Directory with model weights
    enable_profiling: bool = True
    log_level: str = "INFO"
    heartbeat_interval_sec: float = 5.0


class StageWorkerService:
    """
    Worker service for stage execution.

    Responsibilities:
    - Receive execution requests from coordinator
    - Load and manage model weights for assigned layers
    - Execute forward passes on specific layers
    - Manage KV-cache for sessions
    - Report metrics and health

    This is the "data plane" of distributed inference.
    """

    def __init__(self, config: Optional[WorkerConfig] = None):
        """Initialize worker service."""
        self.config = config or WorkerConfig()
        self.logger = logging.getLogger(f"Worker-{self.config.worker_id}")

        # Model and session state
        self.model: Optional[nn.Module] = None
        self.device = torch.device(self.config.device)
        self.layers_assigned: Dict[str, nn.Module] = {}
        self.active_sessions: Dict[str, SessionContext] = {}

        # Metrics
        self.metrics = utils.MetricsCollector()
        self.total_requests = 0
        self.total_latency_ms = 0.0

        # Coordinator client
        self.coordinator_client: Optional[CoordinatorClient] = None

        # Runtime state
        self._is_ready = False
        self._shutdown_event = asyncio.Event()

    async def start(self):
        """Start worker service."""
        self.logger.info(f"Starting worker {self.config.worker_id}")
        self.logger.info(f"Device: {self.config.device}")

        # Initialize hardware
        await self._setup_hardware()

        # Setup gRPC server
        server = await self._start_grpc_server()

        # Register with coordinator
        await self._register_with_coordinator()

        # Start health reporting
        asyncio.create_task(self._health_reporting_loop())

        self._is_ready = True
        self.logger.info("Worker started successfully")

        return server

    async def CreateSession(
        self,
        session_id: str,
        stage_config,
        layer_names: list,
        max_sequence_length: int,
        dtype: str
    ) -> 'CreateSessionResponse':
        """Create new execution session."""
        try:
            if session_id in self.active_sessions:
                return CreateSessionResponse(
                    success=True,
                    node_info=self._get_node_info()
                )

            # Validate layer assignment
            for layer_name in layer_names:
                if layer_name not in self.layers_assigned:
                    return CreateSessionResponse(
                        success=False,
                        error_message=f"Layer not available: {layer_name}"
                    )

            # Create session context
            context = SessionContext(
                session_id=session_id,
                stage_config=stage_config,
                layer_names=layer_names,
                max_sequence_length=max_sequence_length,
                dtype=dtype,
                device=self.device,
            )

            # Load layers for this session
            await self._load_session_layers(context)

            self.active_sessions[session_id] = context

            self.logger.info(f"Created session {session_id} with {len(layer_names)} layers")
            return CreateSessionResponse(
                success=True,
                node_info=self._get_node_info()
            )

        except Exception as e:
            self.logger.error(f"CreateSession error: {e}")
            return CreateSessionResponse(
                success=False,
                error_message=str(e)
            )

    async def ExecuteForward(
        self,
        session_id: str,
        token_index: int,
        input_activations,
        stage_ids: list
    ) -> 'ExecuteForwardResponse':
        """Execute forward pass on assigned layers."""
        start_time = time.time()

        try:
            self.total_requests += 1

            # Get session
            if session_id not in self.active_sessions:
                return ExecuteForwardResponse(
                    success=False,
                    error_message=f"Session not found: {session_id}"
                )

            context = self.active_sessions[session_id]

            # Deserialize input
            input_tensor = utils.deserialize_tensor(input_activations)

            # Move to device
            if input_tensor.device != self.device:
                input_tensor = input_tensor.to(self.device)

            # Execute layers: forward through assigned layers
            output_tensor = await self._execute_layers(
                context.layer_names,
                input_tensor,
                context
            )

            # Calculate metrics
            forward_latency_ms = (time.time() - start_time) * 1000
            self.total_latency_ms += forward_latency_ms

            peak_memory_mb = 0.0
            if self.device.type == 'cuda':
                peak_memory_mb = torch.cuda.max_memory_allocated() / (1024 ** 2)

            # Serialize output
            output_data = utils.serialize_tensor(output_tensor.cpu())

            return ExecuteForwardResponse(
                success=True,
                output_activations=output_data,
                metadata=utils.ExecutionMetadata(
                    forward_latency_ms=forward_latency_ms,
                    peak_memory_mb=peak_memory_mb,
                    device=str(self.device),
                    stage_index=0,  # Would be actual stage index
                )
            )

        except Exception as e:
            self.logger.error(f"ExecuteForward error: {e}")
            return ExecuteForwardResponse(
                success=False,
                error_message=str(e)
            )

    async def CloseSession(self, session_id: str) -> 'CloseSessionResponse':
        """Close and cleanup session."""
        try:
            if session_id in self.active_sessions:
                context = self.active_sessions[session_id]

                # Cleanup KV cache if exists
                context.cleanup()

                del self.active_sessions[session_id]

                self.logger.info(f"Closed session {session_id}")
                return CloseSessionResponse(success=True)

            return CloseSessionResponse(success=True, error_message="Session not found")

        except Exception as e:
            self.logger.error(f"CloseSession error: {e}")
            return CloseSessionResponse(success=False, error_message=str(e))

    async def Ping(self, message: str) -> 'PingResponse':
        """Health check."""
        return PingResponse(
            message=f"Worker {self.config.worker_id} is alive",
            timestamp=datetime.now().isoformat(),
            node_version="0.1.0"
        )

    async def ReportCapabilities(self, node_id: str) -> 'CapabilitiesResponse':
        """Report node capabilities."""
        return CapabilitiesResponse(
            node_id=self.config.worker_id,
            hardware=self._get_hardware_info(),
            supported_dtypes=["fp32", "fp16"] if torch.cuda.is_available() else ["fp32"],
            available_memory_gb=self._get_available_memory_gb(),
            bandwidth_mbps=8000.0,  # Approximate
        )

    async def _setup_hardware(self):
        """Initialize hardware and load model."""
        self.logger.info(f"Setting up hardware: {self.device}")

        if self.device.type == 'cuda':
            torch.cuda.set_device(self.device)
            props = torch.cuda.get_device_properties(self.device)
            self.logger.info(f"CUDA device: {props.name} ({props.total_memory / 1024**3:.1f} GB)")

        # Load base model (simplified: loads full model, would load only assigned layers)
        await self._load_base_model()

    async def _load_base_model(self):
        """Load base model architecture."""
        # Placeholder: In production, would load specific layers
        # For now, we'll load the full model and select layers dynamically
        self.logger.info("Loading base model architecture...")

        from transformers import GPT2LMHeadModel

        model = GPT2LMHeadModel.from_pretrained("gpt2")
        model = model.to(self.device)
        model.eval()

        self.model = model

        # Extract all named modules
        for name, module in model.named_modules():
            if name and name != "":
                self.layers_assigned[name] = module

        self.logger.info(f"Loaded {len(self.layers_assigned)} layers")

    async def _load_session_layers(self, context: 'SessionContext'):
        """Load specific layers for session."""
        self.logger.info(f"Loading {len(context.layer_names)} layers for session {context.session_id}")

        # Store session-specific layer references
        for layer_name in context.layer_names:
            if layer_name not in self.layers_assigned:
                self.logger.warning(f"Layer {layer_name} not found, skipping")
                continue

            context.layers[layer_name] = self.layers_assigned[layer_name]

        self.logger.info(f"Loaded layers: {list(context.layers.keys())}")

    async def _execute_layers(
        self,
        layer_names: list,
        input_tensor: torch.Tensor,
        context: 'SessionContext'
    ) -> torch.Tensor:
        """
        Execute forward pass through assigned layers.

        This is the core execution logic.
        """
        activations = input_tensor

        with torch.no_grad():
            # Execute each layer sequentially: this is where the actual work happens
            for layer_name in layer_names:
                layer = context.layers.get(layer_name)

                if layer is None:
                    continue

                try:
                    if isinstance(layer, (nn.Linear, nn.LayerNorm)):
                        # Matrices: reshape to expected shape
                        activations = activations.view(1, -1)
                        activations = layer(activations)
                    else:
                        # Other layer types
                        activations = layer(activations)

                except Exception as e:
                    self.logger.error(f"Layer error {layer_name}: {e}")
                    raise

        return activations

    async def _start_grpc_server(self):
        """Start gRPC server for coordinator communication."""
        self.logger.info(f"Starting gRPC server on {self.config.listen_host}:{self.config.listen_port}")
        # Actual gRPC implementation would go here
        return None

    async def _register_with_coordinator(self):
        """Register worker with coordinator."""
        self.logger.info(f"Registering with coordinator at {self.config.coordinator_host}:{self.config.coordinator_port}")

        # Create coordinator client
        self.coordinator_client = CoordinatorClient(
            self.config.coordinator_host,
            self.config.coordinator_port
        )

        try:
            await self.coordinator_client.register_worker(self._get_node_info())
            self.logger.info("Successfully registered with coordinator")
        except Exception as e:
            self.logger.error(f"Registration failed: {e}")

    async def _health_reporting_loop(self):
        """Periodically report health to coordinator."""
        while not self._shutdown_event.is_set():
            try:
                await asyncio.sleep(self.config.heartbeat_interval_sec)

                if self.coordinator_client:
                    await self.coordinator_client.send_heartbeat(
                        self.config.worker_id,
                        len(self.active_sessions),
                        self._get_load_metrics()
                    )

            except Exception as e:
                self.logger.error(f"Heartbeat error: {e}")

    def _get_node_info(self) -> 'NodeInfo':
        """Get node information."""
        return utils.NodeInfo(
            node_id=self.config.worker_id,
            host=self.config.listen_host,
            port=self.config.listen_port,
            hardware=self._get_hardware_info(),
            load_factor=len(self.active_sessions) / self.config.max_concurrent_sessions,
        )

    def _get_hardware_info(self) -> 'HardwareInfo':
        """Get hardware information."""
        device_name = "CPU"
        total_memory_gb = 32.0  # Simplified
        compute_capability = 1.0

        if self.device.type == 'cuda':
            props = torch.cuda.get_device_properties(self.device)
            device_name = props.name
            total_memory_gb = props.total_memory / (1024 ** 3)
            compute_capability = float(props.major) + float(props.minor) / 10.0

        return utils.HardwareInfo(
            device_type="GPU" if self.device.type == 'cuda' else "CPU",
            device_name=device_name,
            total_memory_gb=total_memory_gb,
            compute_capability=compute_capability,
            network_bandwidth_mbps=8000.0,  # Approximate
        )

    def _get_available_memory_gb(self) -> float:
        """Get available memory in GB."""
        if self.device.type == 'cuda':
            allocated = torch.cuda.memory_allocated()
            reserved = torch.cuda.memory_reserved()
            available = reserved - allocated
            return available / (1024 ** 3)

        return 32.0  # CPU: assume 32GB

    def _get_load_metrics(self) -> Dict[str, float]:
        """Get current load metrics."""
        return {
            'active_sessions': len(self.active_sessions),
            'avg_latency_ms': self.total_latency_ms / self.total_requests if self.total_requests > 0 else 0.0,
            'requests_per_sec': self.total_requests / (time.time() - self.start_time) if hasattr(self, 'start_time') else 0.0,
        }

    def get_metrics_summary(self) -> Dict[str, Any]:
        """Get metrics summary for debugging."""
        return {
            'worker_id': self.config.worker_id,
            'is_ready': self._is_ready,
            'active_sessions': len(self.active_sessions),
            'layers_assigned': list(self.layers_assigned.keys()),
            'total_requests': self.total_requests,
            'avg_latency_ms': self.total_latency_ms / self.total_requests if self.total_requests > 0 else 0.0,
            'device': str(self.device),
        }


class SessionContext:
    """Context for active inference session."""

    def __init__(
        self,
        session_id: str,
        stage_config,
        layer_names: list,
        max_sequence_length: int,
        dtype: str,
        device: torch.device,
    ):
        self.session_id = session_id
        self.stage_config = stage_config
        self.layer_names = layer_names
        self.max_sequence_length = max_sequence_length
        self.dtype = dtype
        self.device = device

        # Layer storage
        self.layers: Dict[str, nn.Module] = {}

        # KV cache (placeholder for Transformer models)
        self.kv_cache: Optional[Dict[str, torch.Tensor]] = None

        # Metadata
        self.created_at = datetime.now()
        self.last_access = datetime.now()

    def cleanup(self):
        """Cleanup session resources."""
        if self.kv_cache:
            self.kv_cache.clear()
            self.kv_cache = None

        self.layers.clear()


# Placeholder classes for gRPC messages
class CreateSessionResponse:
    def __init__(self, success: bool, error_message: str = None, node_info=None):
        self.success = success
        self.error_message = error_message or ""
        self.node_info = node_info


class ExecuteForwardResponse:
    def __init__(self, success: bool, error_message: str = None, output_activations=None, metadata=None):
        self.success = success
        self.error_message = error_message or ""
        self.output_activations = output_activations
        self.metadata = metadata


class CloseSessionResponse:
    def __init__(self, success: bool, error_message: str = None):
        self.success = success
        self.error_message = error_message or ""


class PingResponse:
    def __init__(self, message: str, timestamp: str, node_version: str):
        self.message = message
        self.timestamp = timestamp
        self.node_version = node_version


class CapabilitiesResponse:
    def __init__(self, node_id: str, hardware=None, supported_dtypes=None, available_memory_gb=0.0, bandwidth_mbps=0.0):
        self.node_id = node_id
        self.hardware = hardware
        self.supported_dtypes = supported_dtypes or []
        self.available_memory_gb = available_memory_gb
        self.bandwidth_mbps = bandwidth_mbps


class CoordinatorClient:
    """Client for communicating with coordinator (placeholder)."""
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port

    async def connect(self):
        pass

    async def register_worker(self, node_info):
        pass

    async def send_heartbeat(self, worker_id: str, active_sessions: int, metrics: Dict):
        pass

    async def close(self):
        pass
