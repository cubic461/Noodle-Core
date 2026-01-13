# NoodleCore Distributed Inference - Fase 1: Observability Engine

**Proof of Concept** voor het observeren en profileren van LLM gedrag, als fundament voor runtime-aware distributed inference planning.

## 📋 Inhoud

- `src/` - Hoofdcode voor observability engine
- `tests/` - Unit tests en integration tests
- `config/` - Configuratiebestanden voor verschillende modellen
- `data/` - Output directory voor metrische data (JSONL logs, visualisaties)
- `examples/` - Voorbeeld scripts voor profiling en evaluatie
- `docs/` - Documentatie en architecture design

## 🚀 Snel Starten

### Installatie

```bash
cd noodle-poc-fase1
pip install -e .
pip install -e ".[dev,dashboard]"
```

### Voorbeeld: GPT-2 Profilen

```bash
python examples/profile_gpt2.py --model gpt2 --num-samples 100
```

Dit genereert:
- `data/metrics/gpt2_profile.jsonl` - Gedetailleerde metrische data per layer
- `data/dashboard/gpt2_dashboard.html` - Interactieve visualisatie

## 🎯 Doelen Fase 1

1.  **Layer Monitoring**: Hooken in PyTorch forward/backward passes om per-layer metrics te verzamelen
2.  **Metrics Collection**: Systematisch loggen van latency, geheugen, tensor shapes en data types
3.  **Structured Logging**: Output naar JSONL formaat voor analyse
4.  **Dashboard**: Simpele visualisatie van metrische data
5.  **Baseline Metrics**: Documentatie van baseline performance voor GPT-2 of vergelijkbaar model

## 📊 Metrics Verzameld

Voor elke layer worden de volgende metrics verzameld:

- **Latency**: Gemiddelde, p50, p95, p99 forward pass duur
- **Geheugen**: VRAM/CPU geheugen toename per layer
- **Tensor Shapes**: Input/output tensor dimensies
- **Data Types**: Gebruikte precisie (FP32/FP16/BF16)
- **Cache Metrics**: Hit/miss ratios (indien van toepassing)

## 🔧 Architectuur

```
┌─────────────────────────────────────────────┐
│           Observability Engine              │
├─────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────────┐ │
│  │ PyTorch      │───▶│ MetricsCollector │ │
│  │ Layer Hooks  │    │ - Latency        │ │
│  │              │    │ - Memory         │ │
│  │              │    │ - Cache Stats    │ │
│  └──────────────┘    └──────────────────┘ │
│              │                │           │
│              └────────────────┘           │
│                     ▼                     │
│         ┌──────────────────────┐          │
│         │ StructuredLogger     │          │
│         │ - JSONL Output       │          │
│         │ - Aggregation        │          │
│         └──────────────────────┘          │
│                     ▼                     │
│         ┌──────────────────────┐          │
│         │ DashboardGenerator   │          │
│         │ - HTML Report        │          │
│         │ - Plots              │          │
│         └──────────────────────┘          │
└─────────────────────────────────────────────┘
```

## 📝 Voorbeeld Configuratie

Zie `config/gpt2_config.yaml` voor een complete setup:

```yaml
model_name: gpt2
device: cuda:0  # of cpu
batch_size: 1
sequence_length: 128
num_warmup_runs: 10
num_profile_runs: 100
log_level: INFO
```

## 🧪 Tests

```bash
pytest tests/ -v --cov=src/
```

## 📈 Dashboard Voorbeeld

Na profiling wordt een interactieve HTML dashboard gegenereerd met:
- Latency overzichten per layer (bar charts)
- Geheugen gebruik trends
- Vergelijking van verschillende runs

## 🛣️ Volgende Fases

**Fase 2**: Staged execution simulatie met de gemeten metrics  
**Fase 3**: Distributed execution over meerdere machines  
**Fase 4**: Adaptieve planning gebaseerd op runtime gedrag
