#!/usr/bin/env python3
"""
NoodleCore Generic Worker Server (simplified v1).

This is a universal worker node that can:
1. Accept load requests (which stage id)
2. Receive forward pass inputs
3. Execute inference (placeholder → can load real models)
4. Report metrics back to coordinator
5. Serve as GPU or CPU worker

Use this script on BOTH machines (laptop + remote machine).
"""

import sys
import os
from pathlib import Path

# Add project to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(PROJECT_ROOT / 'src'))

import torch
import time
import json
from typing import List, Dict, Optional, Any
from dataclasses import asdict
import uvicorn

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import psutil

try:
    from src.plan import VirtualNode, DeviceType
except ImportError:
    VirtualNode = None  # Fallback if NoodleCore not available


# ============================================================================
# Pydantic Models for API
# ============================================================================

class LoadModelRequest(BaseModel):
    """Request to load a specific stage model."""
    stage_id: int
    model_name: str = "gpt2"
    layers_range: List[int] = [0, 12]  # [start_layer, end_layer]


class ForwardRequest(BaseModel):
    """Request for inference (forward pass)."""
    session_id: str
    token_index: int
    stage_id: int
    activations: List[List[List[float]]]
    metrics_url: Optional[str] = None  # Coordinator metrics endpoint


# ============================================================================
# FastAPI App
# ============================================================================

app = FastAPI(
    title="NoodleCore Worker",
    description="Generic inference worker node",
    version="0.1.0",
)

# CORS middleware
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

app.state.models = {}        # stage_id -> model
app.state.sessions = {}      # session_id -> Session object

# Worker identity
app.state.worker_id = os.getenv("WORKER_ID", "worker_unknown")
app.state.device = "cuda" if torch.cuda.is_available() else "cpu"

# Coordinator URL (for reporting metrics)
app.state.coordinator_url = os.getenv("COORDINATOR_URL")


# ============================================================================
# Helper Classes
# ============================================================================

class SessionMemory:
    """Session memory for KV-cache (simplified)."""

    def __init__(self, session_id: str):
        self.session_id = session_id
        self.kv_cache = {}
        self.stage_inputs = {}

    def save_stage_output(self, stage_id: int, activations):
        """Save last output for this stage."""
        self.stage_inputs[stage_id] = activations

    def get_stage_input(self, stage_id: int):
        """Get last input for this stage."""
        return self.stage_inputs.get(stage_id)


# ============================================================================
# API Endpoints
# ============================================================================

@app.get("/")
async def root():
    """Welcome message."""
    return {
        "service": "NoodleCore Worker",
        "version": "0.1.0",
        "worker_id": app.state.worker_id,
        "device": app.state.device,
        "endpoints": {
            "GET /health": "Health check",
            "POST /load_model": "Load stage model",
            "POST /forward": "Execute inference",
        }
    }


@app.get("/health")
async def health():
    """Health check."""
    gpu_available = torch.cuda.is_available()
    models_loaded = len(app.state.models)

    health_data = {
        "status": "ready",
        "worker_id": app.state.worker_id,
        "device": app.state.device,
        "models_loaded": models_loaded,
        "gpu_available": gpu_available,
        "num_sessions": len(app.state.sessions),
    }

    if gpu_available:
        health_data["gpu_name"] = torch.cuda.get_device_name(0)
        health_data["vram_gb"] = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        health_data["vram_used_mb"] = torch.cuda.memory_allocated() / (1024**2)
    else:
        proc = psutil.Process()
        health_data["ram_used_mb"] = proc.memory_info().rss / (1024**2)

    return health_data


@app.post("/load_model")
async def load_model(request: LoadModelRequest):
    """Load model for a specific stage (useful for v3+)."""

    try:
        # For v1: we don't implement actual model slicing, but we *could*
        # For now, just validate layer ranges and save configuration

        stage_data = {
            "stage_id": request.stage_id,
            "model_name": request.model_name,
            "layers_range": request.layers_range,
            "loaded_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "device": app.state.device,
        }

        # Store (don't actually load model for now)
        app.state.models[request.stage_id] = stage_data

        print(f"[LOAD] Stage {request.stage_id}: layers {request.layers_range} on {app.state.device}")

        return {
            "success": True,
            "stage": stage_data,
        }

    except Exception as e:
        raise HTTPException(500, detail=f"Load failed: {e}")


@app.post("/forward")
async def forward(request: ForwardRequest):
    """Execute forward pass."""

    start_time = time.time()
    peak_memory_mb = 0.0

    try:
        # Create session if not exists
        if request.session_id not in app.state.sessions:
            app.state.sessions[request.session_id] = SessionMemory(request.session_id)

        session = app.state.sessions[request.session_id]

        # Deserialize activations
        activations = torch.tensor(request.activations, dtype=torch.float32, device=app.state.device)
        batch_size, seq_len, hidden_dim = activations.shape

        if app.state.device == "cuda":
            torch.cuda.reset_peak_memory_stats()

        # PLACEHOLDER: Execute forward pass for stage (replace with actual model)
        # For v1, we simply pass activations through (identity)
        output = activations.detach() * 1.0  # Detached copy
        # If you *do* have a model loaded: output = app.state.models[request.stage_id].model(inputs)

        if app.state.device == "cuda":
            peak_memory_mb = torch.cuda.max_memory_allocated() / (1024**2)
            torch.cuda.empty_cache()
        else:
            proc = psutil.Process()
            peak_memory_mb = proc.memory_info().rss / (1024**2)

        # Cache output
        session.save_stage_output(request.stage_id, output.cpu().tolist())

        # Elapsed time
        elapsed_ms = (time.time() - start_time) * 1000.0

        # Report metrics to coordinator
        if request.metrics_url:

            metrics = {
                "source": app.state.worker_id,  # e.g., "remote_cpu" or "laptop_gpu"
                "stage_id": request.stage_id,
                "forward_latency_ms": elapsed_ms,
                "memory_mb": peak_memory_mb,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime()),
                "custom_data": {
                    "activations_shape": f"{batch_size}x{seq_len}x{hidden_dim}",
                    "device": app.state.device,
                }
            }

            try:
                requests.post(request.metrics_url, json=metrics, timeout=5)
            except Exception as e:
                print(f"[WARN] Failed to report metrics: {e}")

        return {
            "success": True,
            "output": output.cpu().tolist(),
            "shape": [batch_size, seq_len, hidden_dim],
            "stage_id": request.stage_id,
            "performance": {
                "forward_latency_ms": elapsed_ms,
                "peak_memory_mb": peak_memory_mb,
            }
        }

    except Exception as e:
        error_detail = f"Stage {request.stage_id} failed: {str(e)}"
        return {
            "success": False,
            "error": error_detail,
        }


@app.delete("/sessions/{session_id}")
async def close_session(session_id: str):
    """Close session and free memory."""

    if session_id in app.state.sessions:
        session = app.state.sessions.pop(session_id)
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

        return {"success": True, "message": f"Session {session_id} closed"}

    return {"success": False, "message": f"Session {session_id} not found"}


@app.get("/sessions")
async def list_sessions():
    """List active sessions."""
    return {"sessions": list(app.state.sessions.keys())}


@app.post("/configure")
async def configure(body: dict):
    """Configure worker (set coordinator, worker_id, etc.)."""

    if "worker_id" in body:
        app.state.worker_id = body["worker_id"]

    if "coordinator_url" in body:
        app.state.coordinator_url = body["coordinator_url"]

    return {
        "success": True,
        "worker_id": app.state.worker_id,
        "coordinator_url": app.state.coordinator_url,
    }


@app.get("/status")
async def status():
    """Detailed status of worker."""
    sessions_list = list(app.state.sessions.keys())

    return {
        "worker_id": app.state.worker_id,
        "device": app.state.device,
        "healthy": True,
        "models_loaded": len(app.state.models),
        "sessions_active": len(sessions_list),
        "last_update": time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime()),
    }


# ============================================================================
# Lifecycle Events
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Initialize worker."""
    print("\n" + "="*80)
    print("🤖 NoodleCore Worker Starting...")
    print("="*80)

    print(f"✅ Worker ID: {app.state.worker_id}")
    print(f"✅ Device: {app.state.device}")

    if torch.cuda.is_available():
        print(f"✅ GPU: {torch.cuda.get_device_name(0)}")
    else:
        print("⚠️  No GPU available (CPU mode)")

    if app.state.coordinator_url:
        print(f"✅ Coordinator: {app.state.coordinator_url}")

    print(f"✅ Worker ready")
    print(f"   Endpoint: http://0.0.0.0:8081")
    print(f"   Health: http://0.0.0.0:8081/health")
    print("="*80 + "\n")


# ============================================================================
# Entry Point
# ============================================================================

if __name__ == "__main__":
    # Configuration (can be overridden with environment variables)
    worker_id = os.getenv("WORKER_ID", "laptop_gpu")
    host = os.getenv("WORKER_HOST", "0.0.0.0")
    port = int(os.getenv("WORKER_PORT", "8081"))
    coordinator_url = os.getenv("COORDINATOR_URL")

    app.state.worker_id = worker_id
    app.state.coordinator_url = coordinator_url

    # Start server
    print(f"[INFO] Starting Worker on http://{host}:{port}")
    uvicorn.run(app, host=host, port=port, log_level="info", reload=True)
