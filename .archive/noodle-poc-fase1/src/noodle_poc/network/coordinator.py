"""
Coordinator service for distributed inference orchestration.
Manages session lifecycle, stage assignment, and request routing.
"""

import asyncio
import logging
from typing import Dict, List, Optional, Set
from dataclasses import dataclass, field
from datetime import datetime
import uuid
import time
from contextlib import asynccontextmanager

from .stage_registry import NodeRegistry, NodeInfo
from .session_manager import SessionManager, Session
from . import utils


@dataclass
class CoordinatorConfig:
    """Configuration for coordinator service."""
    listen_host: str = "0.0.0.0"
    listen_port: int = 8081
    heartbeat_interval_sec: float = 5.0
    session_timeout_sec: float = 300.0
    max_concurrent_requests: int = 100
    enable_metrics: bool = True
    log_level: str = "INFO"


@dataclass
class InferenceRequest:
    """Single inference request."""
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    input_tokens: List[int] = field(default_factory=list)
    max_new_tokens: int = 20
    temperature: float = 1.0
    top_p: float = 1.0
    created_at: datetime = field(default_factory=datetime.now)
    session_id: Optional[str] = None


@dataclass
class InferenceResponse:
    """Response for inference request."""
    request_id: str
    generated_tokens: List[int]
    is_complete: bool
    error_message: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ExecutionPlan:
    """Plan for distributed execution."""
    session_id: str
    stages: List[str]  # Ordered list of stage IDs
    stage_to_node: Dict[str, str]  # Mapping: stage -> node
    metadata: Dict[str, Any] = field(default_factory=dict)


class CoordinatorService:
    """
    Main coordinator service.

    Responsibilities:
    - Accept inference requests from clients
    - Select execution plan based on available nodes
    - Orchestrate stage execution across nodes
    - Manage session lifecycle
    - Handle retries and fault tolerance
    """

    def __init__(self, config: Optional[CoordinatorConfig] = None):
        """Initialize coordinator service."""
        self.config = config or CoordinatorConfig()
        self.logger = logging.getLogger("CoordinatorService")

        # Core components
        self.node_registry = NodeRegistry()
        self.session_manager = SessionManager(self.config.session_timeout_sec)

        # Runtime state
        self.active_requests: Dict[str, InferenceRequest] = {}
        self.execution_plans: Dict[str, ExecutionPlan] = {}
        self.metrics_collector = utils.MetricsCollector() if self.config.enable_metrics else None

        # gRPC clients for communicating with worker nodes
        self.stage_clients: Dict[str, StageServiceClient] = {}

        self._shutdown_event = asyncio.Event()
        self._background_tasks: Set[asyncio.Task] = set()

    async def start(self):
        """Start coordinator service."""
        self.logger.info(f"Starting coordinator on {self.config.listen_host}:{self.config.listen_port}")

        # Start background tasks
        await self._start_background_tasks()

        # Start gRPC server
        server = await self._start_grpc_server()

        self.logger.info("Coordinator started successfully")
        return server

    async def submit_inference_request(
        self, request: InferenceRequest
    ) -> InferenceResponse:
        """
        Submit a new inference request.

        This is the main entry point for inference.
        """
        start_time = time.time()

        try:
            # Validate request
            if not request.input_tokens:
                return InferenceResponse(
                    request_id=request.request_id,
                    generated_tokens=[],
                    is_complete=True,
                    error_message="Empty input tokens"
                )

            # Create or reuse session
            session = await self._get_or_create_session(request)

            # Get or create execution plan
            plan = await self._get_execution_plan(session)

            # Track request
            self.active_requests[request.request_id] = request

            # Execute autoregressive generation
            generated_tokens = []
            is_complete = False

            try:
                for step in range(request.max_new_tokens):
                    # Single token generation step
                    next_token = await self._execute_generation_step(
                        session,
                        plan,
                        request,
                        generated_tokens
                    )

                    if next_token is None:
                        is_complete = True
                        break

                    generated_tokens.append(next_token)

                    # Stop if we hit EOS (simplified)
                    if next_token == 50256:  # GPT-2 EOS token
                        is_complete = True
                        break

                is_complete = True

            except Exception as e:
                self.logger.error(f"Generation error: {e}")
                return InferenceResponse(
                    request_id=request.request_id,
                    generated_tokens=generated_tokens,
                    is_complete=True,
                    error_message=str(e)
                )

            finally:
                # Cleanup active request
                self.active_requests.pop(request.request_id, None)

            # Record metrics
            if self.metrics_collector:
                latency_ms = (time.time() - start_time) * 1000
                self.metrics_collector.record_inference_latency(latency_ms)

            return InferenceResponse(
                request_id=request.request_id,
                generated_tokens=generated_tokens,
                is_complete=is_complete,
                metadata={
                    'total_latency_ms': (time.time() - start_time) * 1000,
                    'num_generated_tokens': len(generated_tokens),
                    'session_id': session.session_id,
                }
            )

        except Exception as e:
            self.logger.error(f"Request handling error: {e}")
            return InferenceResponse(
                request_id=request.request_id,
                generated_tokens=[],
                is_complete=True,
                error_message=str(e)
            )

    async def _get_or_create_session(self, request: InferenceRequest) -> Session:
        """Get existing session or create new one."""
        if request.session_id and request.session_id in self.session_manager:
            return self.session_manager.get_session(request.session_id)

        # Create new session
        session_id = request.session_id or str(uuid.uuid4())
        session = Session(
            session_id=session_id,
            created_at=datetime.now(),
        )

        self.session_manager.add_session(session)
        return session

    async def _get_execution_plan(self, session: Session) -> ExecutionPlan:
        """Get existing plan or create new one for session."""
        if session.session_id in self.execution_plans:
            return self.execution_plans[session.session_id]

        # Create new execution plan
        # This is where we use the Fase 2 planner!
        plan = await self._create_execution_plan(session)
        self.execution_plans[session.session_id] = plan

        return plan

    async def _create_execution_plan(self, session: Session) -> ExecutionPlan:
        """
        Create execution plan using Fase 2 planner.

        In Fase 3, this integrates the ExecutionPlanner from Fase 2
        with real network nodes from the registry.
        """
        # Get available nodes
        available_nodes = self.node_registry.get_available_nodes()

        if not available_nodes:
            raise RuntimeError("No available worker nodes")

        # Simple plan: assign stages round-robin
        # In production, this would use the Fase 2 partition planner
        workers = list(available_nodes.keys())
        stages = ["stage_0", "stage_1", "stage_2"]  # From Fase 2 plan

        stage_to_node = {}
        for i, stage in enumerate(stages):
            node_id = workers[i % len(workers)]
            stage_to_node[stage] = node_id

        plan = ExecutionPlan(
            session_id=session.session_id,
            stages=stages,
            stage_to_node=stage_to_node,
            metadata={
                'created_at': datetime.now().isoformat(),
                'num_stages': len(stages),
                'num_nodes': len(set(stage_to_node.values())),
            }
        )

        self.logger.info(f"Created execution plan: {plan.metadata}")
        return plan

    async def _execute_generation_step(
        self,
        session: Session,
        plan: ExecutionPlan,
        request: InferenceRequest,
        generated_tokens: List[int]
    ) -> Optional[int]:
        """
        Execute single generation step across distributed stages.

        This is the core pipeline execution logic.
        """
        # Prepare input: existing tokens + generated tokens
        all_tokens = request.input_tokens + generated_tokens
        current_activations = utils.tokens_to_tensor(all_tokens)

        # Execute pipeline: pass through each stage
        for stage_id in plan.stages:
            node_id = plan.stage_to_node[stage_id]

            # Execute forward pass on worker node
            response = await self._execute_stage_forward(
                session.session_id,
                node_id,
                stage_id,
                current_activations,
                step=len(generated_tokens)
            )

            if not response.success:
                raise RuntimeError(f"Stage execution failed: {response.error_message}")

            # Update activations for next stage
            current_activations = utils.deserialize_tensor(response.output_activations)

        # Sample next token (simplified: just get argmax)
        next_token = int(current_activations.argmax())

        return next_token

    async def _execute_stage_forward(
        self,
        session_id: str,
        node_id: str,
        stage_id: str,
        activations: 'torch.Tensor',
        step: int
    ) -> 'ExecuteForwardResponse':
        """Execute forward pass on specific worker node."""
        # Get client for node
        client = await self._get_stage_client(node_id)

        # Prepare request
        request = utils.create_forward_request(
            session_id=session_id,
            token_index=step,
            tensor=activations,
        )

        # Call worker
        try:
            response = await client.ExecuteForward(request)
            return response
        except Exception as e:
            self.logger.error(f"Stage forward error: {e}")
            # Retry logic would go here
            raise

    async def _get_stage_client(self, node_id: str) -> 'StageServiceClient':
        """Get or create gRPC client for node."""
        if node_id not in self.stage_clients:
            node_info = self.node_registry.get_node(node_id)
            if not node_info:
                raise RuntimeError(f"Node not found: {node_id}")

            client = StageServiceClient(node_info.host, node_info.port)
            await client.connect()
            self.stage_clients[node_id] = client

        return self.stage_clients[node_id]

    async def _start_background_tasks(self):
        """Start background maintenance tasks."""
        # Heartbeat monitoring
        task1 = asyncio.create_task(self._heartbeat_monitor())
        self._background_tasks.add(task1)
        task1.add_done_callback(self._background_tasks.discard)

        # Session cleanup
        task2 = asyncio.create_task(self._session_cleanup())
        self._background_tasks.add(task2)
        task2.add_done_callback(self._background_tasks.discard)

    async def _heartbeat_monitor(self):
        """Monitor worker node health."""
        while not self._shutdown_event.is_set():
            try:
                await asyncio.sleep(self.config.heartbeat_interval_sec)
                await self.node_registry.check_all_heartbeats()
            except Exception as e:
                self.logger.error(f"Heartbeat monitoring error: {e}")

    async def _session_cleanup(self):
        """Cleanup expired sessions."""
        while not self._shutdown_event.is_set():
            try:
                await asyncio.sleep(60.0)
                expired = self.session_manager.cleanup_expired_sessions()
                if expired:
                    self.logger.info(f"Cleaned up {len(expired)} expired sessions")
            except Exception as e:
                self.logger.error(f"Session cleanup error: {e}")

    async def _start_grpc_server(self):
        """Start gRPC server for client connections."""
        # This would start the actual gRPC server
        # Placeholder for now
        self.logger.info(f"gRPC server would start on {self.config.listen_host}:{self.config.listen_port}")
        return None

    async def shutdown(self):
        """Graceful shutdown."""
        self.logger.info("Shutting down coordinator...")
        self._shutdown_event.set()

        # Cancel background tasks
        for task in self._background_tasks:
            task.cancel()

        # Close connections
        for client in self.stage_clients.values():
            await client.close()

        self.logger.info("Coordinator shutdown complete")
