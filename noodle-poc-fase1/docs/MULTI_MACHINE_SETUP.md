# Multi-Machine Setup Guide (Fase 3)

**Doel**: Profileer en test distributed inference over meerdere fysieke machines.

## Overzicht

Dit document beschrijft hoe je:
1.  **Machine A** (Laptop met RTX 1050) als Coordinator + Stage 0
2.  **Machine B** (andere PC) als Stage 1

Laat samenwerken voor distributed inference.

---

## Stap 1: Netwerkconfiguratie

Voor elke machine:

### 1.1 Vaste IP-adressen instellen (Windows)

Voor eenvoud, wijs vaste IP's toe via je router DHCP reservation.

Ga naar je router instellingen:
- Machine A (Laptop): Reserve IP `192.168.1.101`
- Machine B (Andere PC): Reserve IP `192.168.1.102`

**Altijd IP adres gebruiken.** Hostnames (bv. `DESKTOP-ABC`) zijn onbetrouwbaar na herstart.

### 1.2 Firewall Configuratie

Beide machines moeten toegang toestaan via Windows Firewall.

```powershell
# PowerShell als Administrator (op BEIDE machines)

# Poort 8080 toestaan (voor REST API, zie later)
New-NetFirewallRule -DisplayName "Noodle-Coordinator-Http" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow

# Poort 50051 toestaan (voor gRPC, optioneel maar aanbevolen)
New-NetFirewallRule -DisplayName "Noodle-Stage-gRPC" -Direction Inbound -Protocol TCP -LocalPort 50051 -Action Allow

# SSH (voor debugging, optioneel)
New-NetFirewallRule -DisplayName "SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
```

### 1.3 Shared Directory instellen

Wil je resultaten centraliseren? Installeer **VS Code Remote SSH**:
- Extensie: "Remote - SSH"
- Verbind met Machine B
- Workspace op Machine B openen

**Alternative zonder SSH**: Deploy script uploadt resultaten naar Machine A na elke run.

---

## Stap 2: Software Installatie

### Machine A (Laptop) - Coordinator

```powershell
cd C:\Users\micha\Noodle\noodle-poc-fase1

# Install dependencies
pip install -e .
pip install fastapi uvicorn requests

# Controleer
python -c "import transformers"
python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
```

### Machine B (Andere PC) - Worker

```bash
# Op Machine B (Linux of Windows)
cd /path/to/noodle-poc-project

# Install dependencies
pip install -e .
pip install fastapi uvicorn requests

# Controleer hardware
python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"CPU-only\"}')"
```

---

## Stap 3: Simple REST API voor Coordinatie

gRPC is complex voor v1. Een simpele REST API met **FastAPI** werkt sneller.

### Deploy: `coordinator_api.py`

**Plaats**: `examples/coordinator_api.py`

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from typing import List, Dict
import json

app = FastAPI()

class StageRequest(BaseModel):
    session_id: str
    activations: List[List[float]]  # Nested list voor tensor data
    token_index: int
    stage_id: int

# In-memory state (voor simpliciteit)
sessions = {}
models = {}  # Stage-i -> model

@app.on_event("startup")
async def startup_event():
    """Load models bij opstarten."""
    from transformers import GPT2LMHeadModel

    print("Loading models...")

    # Stage 0: layers 0-10 (embeddings + vroege layers)
    model_stage0 = GPT2LMHeadModel.from_pretrained("gpt2")
    model_stage0.transformer.h = model_stage0.transformer.h[:10]
    models[0] = model_stage0
    print(f"[OK] Stage 0 loaded (10 layers)")

    # Stage 1: layers 10-12 (latere layers + head)
    model_stage1 = GPT2LMHeadModel.from_pretrained("gpt2")
    model_stage1.transformer.h = model_stage1.transformer.h[10:12]
    models[1] = model_stage1
    print(f"[OK] Stage 1 loaded (2 layers)")

@app.post("/stage/{stage_id}/forward")
async def forward_stage(stage_id: int, request: StageRequest):
    """Forward pass voor een stage."""
    try:
        # Deserialiseer activations
        activations = torch.tensor(request.activations)

        # Haal model
        model = models[stage_id]

        # Forward (placeholders)
        output = {"forward_complete": True, "stage_id": stage_id, "output_shape": list(activations.shape)}

        return {"success": True, "output": output}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/plan/generate")
async def generate_plan(available_nodes: List[Dict]):
    """Genereer partition plan op basis van hardware."""
    # Gebruik jouw bestaande planner
    # ...

    plan_json = json.dumps({
        "nodes": available_nodes,
        "plan": "TODO: return PartitionPlan object"
    })
    return {"success": True, "plan": json.loads(plan_json)}

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
```

---

## Stap 4: Deploy Workflow

### Op Machine A (Coordinator)

**Bestand**: `deploy_to_remote.ps1`

```powershell
# PowerShell script
param(
    [Parameter(Mandatory=$true)]
    [string]$RemoteIP
)

$ProjectDir = "C:\Users\micha\Noodle\noodle-poc-fase1"

# 1. Synchroniseer project naar Machine B (via SCP of rsync)
# Install Git Bash (met rsync)

$Env:Path += ";C:\Program Files\Git\usr\bin"
$RemoteUser = "micha"  # Pas aan

Write-Host "Uploading code to $RemoteIP..."
rsync -avz --exclude="__pycache__" --exclude="*.pyc" -e "ssh -o StrictHostKeyChecking=no" `
    "$ProjectDir/" `
    "$RemoteUser@${RemoteIP}:/home/micha/noodle-poc-fase1/"

# 2. Start remote worker
Write-Host "Starting remote worker..."
ssh $RemoteUser@$RemoteIP "cd /home/micha/noodle-poc-fase1 && python examples/worker_server.py &"

# 3. Start te local coordinator
Write-Host "Starting coordinator..."
Start-Process powershell -ArgumentList "cd $ProjectDir; python examples/coordinator_api.py"

Write-Host "`n[OK] Deployment complete!"
Write-Host "  - Coordinator: http://localhost:8080"
Write-Host "  - Health check: http://localhost:8080/health"
Write-Host "  - Remote worker: $RemoteIP:8081"
```

**Uitvoeren**:
```powershell
.\deploy_to_remote.ps1 -RemoteIP "192.168.1.102"
```

### Op Machine B (Worker)

**Bestand**: `worker_server.py`

```python
import uvicorn
from fastapi import FastAPI
import torch

app = FastAPI()

class WorkerService:
    def __init__(self):
        self.model = None  # Wordt ingesteld via API call of startup

    def load_stage_model(self, stage_id, model_path):
        # Load stage uit planners output
        pass

worker = WorkerService()

@app.get("/health")
def health():
    return {"status": "ready"}

@app.post("/load_model/{stage_id}")
def load_model(stage_id: int, model_config: dict):
    worker.load_stage_model(stage_id, model_config)
    return {"success": True}

@app.post("/forward")
def forward(data: dict):
    # Voer forward uit voor deze worker
    return {"output": "placeholder"}

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8081)
```

---

## Stap 5: Run Distributed Test

**Bestand**: `examples/test_distributed.py`

```python
import requests
import json

COORDINATOR_URL = "http://192.168.1.101:8080"
REMOTE_WORKER_URL = "http://192.168.1.102:8081"

def test_distributed():
    # 1. Register workers
    workers = {
        "local_rtx1050": "http://192.168.1.101:8080/stage/0",
        "remote_cpu": "http://192.168.1.102:8081/forward",
    }

    # 2. Genereer plan
    response = requests.post(f"{COORDINATOR_URL}/plan/generate", json={
        "available_nodes": [
            {"node_id": "local_rtx1050", "device_type": "gpu", "vram_gb": 4.0},
            {"node_id": "remote_cpu", "device_type": "cpu", "ram_gb": 16.0},
        ]
    })

    plan = response.json()['plan']
    print("Plan generated:", json.dumps(plan, indent=2))

    # 3. Stuur test activations
    test_activations = [[0.1, 0.2, 0.3]]  # Mock data
    response = requests.post(f"{COORDINATOR_URL}/stage/0/forward", json={
        "session_id": "test_123",
        "activations": test_activations,
        "token_index": 0,
        "stage_id": 0,
    })

    print("Response:", response.json())

if __name__ == '__main__':
    test_distributed()
```

---

## Stap 6: Debug & Monitor

### Network debugging

```powershell
# Op Machine A: ping de andere machine
ping 192.168.1.102

# Test poorten
Test-NetConnection -ComputerName 192.168.1.102 -Port 8081
```

### Logs synchroniseren

**Manier 1: NFS/SMB Share**
Map een netwerkdrive van Machine A op Machine B voor gedeelde logs.

**Manier 2: Centrale logging** (beter)
Stuur alle metrics naar een REST endpoint op Machine A.

```python
# In je code, waar je metrics logt:
import requests

def log_to_central(metrics: dict):
    try:
        requests.post("http://192.168.1.101:8080/log_metrics", json=metrics)
    except:
        pass  # Fallback: sla lokaal op
```

---

## Stap 7: Performance benchmarks

```python
import time

def benchmark_distributed(num_tokens=100):
    start = time.time()
    
    # Emuleer token-by-token decoding
    for i in range(num_tokens):
        activations = get_initial_activations() if i == 0 else output_from_prev
        
        # Stage 0 (local GPU)
        response0 = requests.post(f"{COORDINATOR_URL}/stage/0/forward", json=activations)
        
        # Stage 1 (remote CPU)
        output_from_prev = response0.json()
        response1 = requests.post(f"{REMOTE_WORKER_URL}/forward", json=response0.json())
        
        decoded_token = decode_logits(response1.json())
    
    elapsed = time.time() - start
    tokens_per_sec = num_tokens / elapsed
    
    print(f"Distributed: {tokens_per_sec:.2f} tokens/sec")
    print(f"Local (Control): <comparable metric>")
```

---

## Foutmeldingen & Oplossingen

| Probleem | Oorzaak | Oplossing |
|:--- |:--- |:--- |
| **Connection Refused** | Firewall blokkeert de poort | `New-NetFirewallRule` (zie Stap 1.2) |
| **Hostname not found** | DHCP reageert IP aan andere machine | Gebruik altijd vaste IP's |
| **Permission denied** | SSH keys niet ingesteld | Genereer keypair óf gebruik wachtwoord auth |
| **CUDA out of memory** | Model te groot | Gebruik FP16, verlaag batch size, of gebruik smaller model |
| **"Cannot connect to self"** | URL localhost:8080 gebruikt | Gebruik **0.0.0.0:8080** voor extern access |

---

## Volgende Stappen

✅ **Week 1**: Profileer RTX 1050 + CPU lokaal (script: `examples/profile_rtx1050.py`)\
🟡 **Week 2**: Stel vaste IP's in, test `coordinator_api.py`\
🟡 **Week 3**: Deploy naar Machine B, voer distributed test uit\
🟡 **Week 4**: Voeg dashboard toe met real-time metrics van beide machines
