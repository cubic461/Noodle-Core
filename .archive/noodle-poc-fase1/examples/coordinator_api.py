#!/usr/bin/env python3
"""
NoodleCore Distributed Coordinator REST API (Simplified v1).

This FastAPI service:
1. Accepts inference requests
2. Coordinates multi-stage execution
3. Routes requests between local and remote workers
4. Collects centralized metrics
5. Generates execution plans based on hardware

Designed for simplicity and easy debugging (replaces gRPC for v1).
"""

import sys
import os
from pathlib import Path

# Add project to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(PROJECT_ROOT / 'src'))

import torch
import json
import time
import asyncio
from typing import List, Dict, Optional, Any
from dataclasses import asdict
import uvicorn

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psutil

try:
    from src.plan import VirtualNode, DeviceType, PartitionPlan
    from src.planner import ExecutionPlanner, PartitionStrategy
    from src.metrics import MetricsCollector
    NOODLE_CORE_AVAILABLE = True
except ImportError:
    NOODLE_CORE_AVAILABLE = False


# ============================================================================
# Pydantic Models for API
# ============================================================================

class NodeInfo(BaseModel):
    """Hardware node information."""
    node_id: str
    device_type: str  # 'gpu', 'cpu', 'igpu'
    compute_score: float
    vram_gb: Optional[float] = None
    ram_gb: Optional[float] = None
    network_latency_ms: float = 0.5
    address: str  # 'http://192.168.1.101:8080'


class StageRequest(BaseModel):
    """Request for stage execution."""
    session_id: str
    token_index: int
    stage_id: int
    activations: List[List[List[float]]]  # [batch, seq_len, hidden_dim]
    return_logits: bool = False


class PlanningRequest(BaseModel):
    """Request for generating execution plan."""
    model_name: str = "gpt2"
    strategy: str = "balanced"  # balanced, bottleneck_first, memory_aware
    available_nodes: List[NodeInfo]


class MetricsSubmission(BaseModel):
    """Metrics sent from workers."""
    source: str  # 'gpu_worker', 'cpu_worker', etc.
    stage_id: int
    forward_latency_ms: float
    memory_mb: float
    timestamp: str
    custom_data: Dict[str, Any] = {}


# ============================================================================
# FastAPI App
# ============================================================================

app = FastAPI(
    title="NoodleCore Coordinator",
    description="Distributed inference orchestrator",
    version="0.1.0",
)

# CORS middleware (for browser debugging)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# Global State
# ============================================================================

# Server state
app.state.sessions = {}  # session_id -> session_data
app.state.workers = {}   # node_id -> WorkerInfo
app.state.plan = None    # current PartitionPlan
app.state.planner = None # ExecutionPlanner instance
app.state.metrics_history = []  # All collected metrics

# Placeholder models (populated on startup)
app.state.models = {}

# Used for collecting centralized metrics
app.state.central_metrics = {
    "laptop_gpu": [],
    "remote_cpu": [],
}


# ============================================================================
# Helper Classes
# ============================================================================

class WorkerInfo:
    """Information about a worker node."""
    def __init__(self, node_id: str, address: str, device_type: str):
        self.node_id = node_id
        self.address = address.rstrip('/')
        self.device_type = device_type
        self.healthy = False
        self.last_ping = None

    def __repr__(self):
        return f"<Worker {self.node_id}@{self.address}>"


class SessionData:
    """Session state for multi-stage inference."""
    def __init__(self, session_id: str, max_sequence_length: int = 512):
        self.session_id = session_id
        self.max_sequence_length = max_sequence_length
        self.tokens_generated = 0
        self.stage_inputs = {}  # stage_id -> last_output
        self.kv_cache = {}

    def can_continue(self) -> bool:
        return self.tokens_generated < self.max_sequence_length

    def finalize(self):
        """Cleanup session resources."""
        self.stage_inputs.clear()
        self.kv_cache.clear()


# ============================================================================
# API Endpoints
# ============================================================================

@app.get("/")
async def root():
    """Welcome message."""
    return {
        "service": "NoodleCore Coordinator",
        "version": "0.1.0",
        "health": "/health",
        "endpoints": {
            "POST /plan/generate": "Generate partition plan",
            "POST /stage/{stage_id}/forward": "Execute stage",
            "POST /central_metrics": "Submit metrics",
            "GET /metrics": "View collected metrics",
            "GET /dashboard": "Generated dashboard (if implemented)",
        }
    }


@app.get("/health")
async def health():
    """Health check."""
    gpu_available = torch.cuda.is_available()

    health_data = {
        "status": "healthy",
        "coordinator": "ready",
        "gpu_available": gpu_available,
        "num_sessions": len(app.state.sessions),
        "num_workers": len(app.state.workers),
        "current_plan": app.state.plan is not None,
    }

    if gpu_available:
        health_data["gpu_name"] = torch.cuda.get_device_name(0)
        health_data["vram_gb"] = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        health_data["vram_used_mb"] = torch.cuda.memory_allocated() / (1024**2)

    return health_data


@app.post("/workers/register")
async def register_worker(node_info: NodeInfo):
    """Register a worker node."""

    worker = WorkerInfo(
        node_id=node_info.node_id,
        address=node_info.address,
        device_type=node_info.device_type,
    )

    # Attempt health check
    try:
        import requests
        response = requests.get(f"{worker.address}/health", timeout=3)
        worker.healthy = response.status_code == 200
        worker.last_ping = time.time()

    except Exception as e:
        print(f"[WARN] Worker {worker.node_id} failed health check: {e}")
        worker.healthy = False

    # Store worker
    app.state.workers[worker.node_id] = worker

    return {
        "success": True,
        "worker": {
            "node_id": worker.node_id,
            "address": worker.address,
            "healthy": worker.healthy,
        }
    }


@app.post("/plan/generate")
async def generate_plan(request: PlanningRequest):
    """Generate partition plan based on hardware."""

    if not NOODLE_CORE_AVAILABLE:
        raise HTTPException(500, detail="NoodleCore modules not available (see requirements.txt)")

    try:
        # Convert NodeInfo to VirtualNode objects
        virtual_nodes = []
        for node in request.available_nodes:
            device_type = DeviceType(node.device_type)
            vnode = VirtualNode(
                node_id=node.node_id,
                device_type=device_type,
                compute_score=node.compute_score,
                vram_gb=node.vram_gb or 0.0,
                ram_gb=node.ram_gb or 0.0,
            )
            virtual_nodes.append(vnode)

            # Create WorkerInfo if not exists (implicit registration)
            if node.node_id not in app.state.workers:
                worker = WorkerInfo(
                    node_id=node.node_id,
                    address=node.address,
                    device_type=node.device_type,
                )
                worker.healthy = True  # Assume healthy if in planning request
                app.state.workers[node.node_id] = worker

        # Initialize planner with basic demo metrics
        from src.plan import create_fake_metrics_for_demo
        collector = MetricsCollector()
        fake_metrics = create_fake_metrics_for_demo()
        collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

        # Create planner
        strategy = PartitionStrategy(request.strategy)
        planner = ExecutionPlanner(
            collector,
            strategy=strategy,
        )
        app.state.planner = planner

        # Generate plan
        plan = planner.generate_plan(
            available_nodes=virtual_nodes,
            model_name=request.model_name,
        )
        app.state.plan = plan

        # Return human-readable plan summary
        plan_summary = plan.visualize()

        return {
            "success": True,
            "plan": plan.to_dict(),
            "human_readable": plan_summary,
            "bottleneck": {
                "stage_id": plan.bottleneck_stage_id,
                "latency_ms": plan.bottleneck_latency_ms,
                "reason": plan.bottleneck_reason,
            },
            "workers_registered": len(app.state.workers),
        }

    except Exception as e:
        raise HTTPException(500, detail=f"Planning failed: {e}")


@app.post("/stage/{stage_id}/forward")
async def forward_stage(stage_id: int, request: StageRequest):
    """Execute forward pass for a specific stage."""

    try:
        # Validate session
        if request.session_id not in app.state.sessions:
            app.state.sessions[request.session_id] = SessionData(request.session_id)

        session = app.state.sessions[request.session_id]

        # For v1: placeholder stubs (in reality, load stage model and run inference)
        # If you have models loaded in app.state.models, use them here

        # Simulate forward pass
        activations_tensor = torch.tensor(request.activations, dtype=torch.float32)
        batch_size, seq_len, hidden_dim = activations_tensor.shape

        # Placeholder transformation (replace with actual model)
        output = activations_tensor * 1.0  # Identity (placeholder)

        # Cache for future stages
        session.stage_inputs[stage_id] = output.tolist()

        # Collect local metrics (if coordinator also runs inference)
        if torch.cuda.is_available():
            peak_vram = torch.cuda.max_memory_allocated() / (1024**2)
        else:
            peak_vram = psutil.Process().memory_info().rss / (1024**2)

        app.state.metrics_history.append({
            "stage_id": stage_id,
            "source": "coordinator_laptop",
            "forward_latency_ms": 1.0,  # placeholder
            "memory_mb": peak_vram,
            "timestamp": time.strftime("%H:%M:%S", time.gmtime()),
        })

        return {
            "success": True,
            "output": output.tolist(),
            "shape": [batch_size, seq_len, hidden_dim],
            "stage_id": stage_id,
        }

    except Exception as e:
        raise HTTPException(500, detail=f"Stage {stage_id} failed: {e}")


@app.post("/central_metrics")
async def receive_metrics(metrics: MetricsSubmission):
    """Receive metrics from remote workers (central collection)."""

    metric_data = {
        "source": metrics.source,
        "stage_id": metrics.stage_id,
        "forward_latency_ms": metrics.forward_latency_ms,
        "memory_mb": metrics.memory_mb,
        "timestamp": metrics.timestamp,
        "custom": metrics.custom_data,
    }

    app.state.metrics_history.append(metric_data)

    # Store per-worker metrics
    if metrics.source in app.state.central_metrics:
        app.state.central_metrics[metrics.source].append(metric_data)

    return {"success": True}


@app.get("/metrics")
async def get_metrics(source: Optional[str] = None):
    """Get central metrics."""

    if source:
        filtered = [m for m in app.state.metrics_history if m.get("source") == source]
    else:
        filtered = app.state.metrics_history

    # Basic stats
    latencies = [m["forward_latency_ms"] for m in filtered if "forward_latency_ms" in m]
    avg_latency = sum(latencies) / len(latencies) if latencies else 0.0

    return {
        "total_records": len(app.state.metrics_history),
        "filtered_records": len(filtered),
        "by_source": {
            source: len(data) for source, data in app.state.central_metrics.items()
        },
        "average_latency_ms": avg_latency,
        "recent": app.state.metrics_history[-10:],  # Last 10
    }


@app.delete("/sessions/{session_id}")
async def close_session(session_id: str):
    """Close and cleanup session."""

    if session_id in app.state.sessions:
        session = app.state.sessions[session_id]
        session.finalize()
        del app.state.sessions[session_id]

        return {"success": True, "message": f"Session {session_id} closed"}

    return {"success": False, "message": f"Session {session_id} not found"}


# ============================================================================
# Background Tasks
# ============================================================================

async def periodic_worker_health_check():
    """Periodically ping workers to ensure they're alive."""
    import requests

    while True:
        await asyncio.sleep(30)  # Every 30 seconds

        for worker in app.state.workers.values():
            try:
                response = requests.get(f"{worker.address}/health", timeout=3)
                worker.healthy = response.status_code == 200
                worker.last_ping = time.time()

            except Exception:
                worker.healthy = False


# ============================================================================
# Lifecycle Events
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Initialize coordinator on startup."""
    print("\n" + "="*80)
    print("🚀 NoodleCore Coordinator Starting...")
    print("="*80)

    # Load placeholder models (simplified v1)
    if torch.cuda.is_available():
        print(f"✅ GPU: {torch.cuda.get_device_name(0)}")
    else:
        print("⚠️  No GPU available (CPU-only mode)")

    print(f"✅ Coordinator ready")
    print(f"   Endpoint: http://0.0.0.0:8080")
    print(f"   Health: http://0.0.0.0:8080/health")
    print("="*80 + "\n")

    # Start background health checks
    asyncio.create_task(periodic_worker_health_check())


# ============================================================================
# Main Entry Point
# ============================================================================

if __name__ == "__main__":
    # Configuration (can be overridden with environment variables)
    host = os.getenv("COORDINATOR_HOST", "0.0.0.0")
    port = int(os.getenv("COORDINATOR_PORT", "8080"))

    # Start server
    print(f"[INFO] Starting Coordinator on http://{host}:{port}")
    uvicorn.run(app, host=host, port=port, log_level="info", reload=True)
