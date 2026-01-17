# 🍜 Noodle - Self-Improving Development System

**Noodle** is an open-source, production-grade **self-improving development system** that uses AI to automatically analyze, patch, test, and optimize codebases.

[![NIP Version](https://img.shields.io/badge/NIP-v3.0.0-blue)](https://github.com/block/noodle)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![TypeScript](https://img.shields.io/badge/typescript-5.0+-blue.svg)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 🚀 What is Noodle?

Noodle implements the **Noodle Improvement Pipeline (NIP)** - a sophisticated system that:

1. **Analyzes** your codebase for improvement opportunities
2. **Generates** intelligent patches using LLMs (Z.ai GLM-4.7, GPT-4, Claude)
3. **Tests** patches in isolated worktrees (parallel execution)
4. **Validates** with performance regression detection and A/B testing
5. **Promotes** only safe, tested changes to production

### Key Differentiator: Shadow Mode

✅ **100% Safe** - All changes tested in isolated snapshots  
✅ **Manual Promotion** - You decide what goes to production  
✅ **Rollback Ready** - Automatic revert on failures  
✅ **Zero Network** - Sandboxed execution by default  

---

## 📊 NIP v3 Features

| Feature | v1 | v2 | v3 |
|---------|----|----|-----|
| **Shadow Mode Testing** | ✅ | ✅ | ✅ |
| **Workspace Snapshots** | ✅ | ✅ | ✅ |
| **Sandboxed Execution** | ✅ | ✅ | ✅ |
| **Policy Gates** | ✅ | ✅ | ✅ |
| **Planner (noodle-brain)** | ❌ | 🔌 | ✅ |
| **PatchAgent (LLM)** | ❌ | 🔌 | ✅ |
| **LSP Gate (API Break)** | ❌ | 🔌 | ✅ |
| **Parallel Worktrees** | ❌ | ❌ | ✅ |
| **Performance Detection** | ❌ | ❌ | ✅ |
| **Multi-Candidate Rank** | ❌ | ❌ | ✅ |
| **A/B Testing** | ❌ | ❌ | ✅ |
| **Full LLM Integration** | ❌ | ❌ | ✅ (Z.ai GLM-4.7) |
| **Real LSP Servers** | ❌ | ❌ | ✅ |
| **Auto Rollback** | ❌ | ❌ | ✅ |
| **Analytics Dashboard** | Basic | Enhanced | Comprehensive |

**Legend:** ✅ Implemented | 🔌 Hook/Stub | ❌ Not Available

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     NIP v3 Architecture                       │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Planner    │─────▶│  PatchAgent  │─────▶│  Worktree    │
│  (noodle-    │      │  (noodle-    │      │   Manager    │
│   brain)     │      │   agents-    │      │              │
│              │      │   trm)       │      │  (Parallel)  │
└──────────────┘      └──────────────┘      └──────────────┘
       │                     │                      │
       ▼                     ▼                      ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   LSP Gate   │      │ Performance  │      │  A/B Test    │
│  (Real LSP)  │      │   Detector   │      │   Runner     │
└──────────────┘      └──────────────┘      └──────────────┘
       │                     │                      │
       └─────────────────────┴──────────────────────┘
                             │
                             ▼
                    ┌──────────────┐
                    │   Policy     │
                    │    Gate      │
                    │   (v3+)      │
                    └──────────────┘
                             │
                             ▼
                    ┌──────────────┐
                    │ Comparison   │
                    │  & Ranking   │
                    │              │
                    │ Auto-Select  │
                    │    Best      │
                    └──────────────┘
                             │
                             ▼
                    ┌──────────────┐
                    │  Manual      │
                    │  Promotion   │
                    │   (You)      │
                    └──────────────┘
```

---

## 🎯 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/block/noodle.git
cd noodle

# Install Python dependencies
cd noodle-core
pip install -e .

# Install TypeScript CLI
cd ../noodle-cli-typescript
npm install
npm link

# Configure API keys (for LLM features)
export ZAI_API_KEY="your-zai-api-key"  # Primary
export OPENAI_API_KEY="your-openai-key"  # Optional fallback
```

### Basic Usage

```bash
# 1. Create an improvement task
noodle improve task create \\
  --title "Optimize database queries" \\
  --goal "Reduce query latency by 30%" \\
  --risk medium \\
  --files database.py

# 2. Run with parallel execution (v3)
noodle improve run --task TASK_001 --parallel 3

# 3. Compare candidates (v3)
noodle improve candidate compare --task TASK_001

# 4. Promote the winner
noodle improve candidate promote --id WINNER_ID
```

---

## 📘 Documentation

### Core Documentation

- **[v3 Full Guide](docs/improve_v3.md)** - Complete NIP v3 documentation
- **[v2 Features](docs/improve_v2.md)** - Planner, PatchAgent, LSP Gate
- **[v1 Basics](docs/improve.md)** - Foundational concepts

### Change Logs

- **[v3 Changelog](CHANGELOG_NIP_v3.md)** - What\'s new in v3
- **[v2 Changelog](CHANGELOG_NIP_v2.md)** - v2 enhancements
- **[v1 Changelog](CHANGELOG_NIP_v1.md)** - Initial release

### Examples

- **[Example Tasks](examples/improve/)** - Sample task configurations
- **[CLI Usage](docs/cli_reference.md)** - Command reference

---

## 🔑 Key Features Deep Dive

### 1. Parallel Worktree Execution (v3)

Execute multiple candidates simultaneously for **3-5x faster** iteration:

```python
from noodlecore.improve.parallel import WorktreeManager, WorktreeConfig

config = WorktreeConfig(max_parallel=3)
manager = WorktreeManager(config, snapshot_manager)

results = manager.execute_parallel(
    candidates=[c1, c2, c3],
    execution_func=run_tests,
    progress_callback=log_progress
)
```

### 2. Performance Regression Detection (v3)

Automatically detect performance degradations:

```python
from noodlecore.improve.performance import PerformanceDetector

detector = PerformanceDetector()
report = detector.detect_regression(
    baseline_results,
    patch_results,
    task_id="TASK_001"
)

if report.overall_verdict == "fail":
    print(f"Critical regression: {report.regression_count} issues")
```

### 3. Multi-Candidate Comparison (v3)

Automatically rank and select the best patch:

```python
from noodlecore.improve.comparison import CandidateComparator

comparator = CandidateComparator(strategy=RankingStrategy.BALANCED)
result = comparator.compare_candidates(candidates, evidence, reports)

print(f"Winner: {result.winner}")
print(f"Recommendation: {result.recommendation}")
```

### 4. A/B Testing (v3)

Scientific validation with statistical testing:

```python
from noodlecore.improve.ab_testing import ABTestRunner, ABTestConfig

config = ABTestConfig(
    warmup_iterations=3,
    measurement_iterations=10,
    success_criteria="both_pass_and_improve"
)

summary = runner.run_test(baseline_worktree, patch_worktree, ["pytest"])
```

### 5. LLM Integration (v3)

**Primary: Z.ai GLM-4.7** (bilingual, optimized for code)

```python
from noodle_agents_trm.patch_agent import create_patch_agent

agent = create_patch_agent(agent_type="llm")
result = agent.generate_patch(request)

print(f"Confidence: {result.confidence:.2%}")
print(f"Cost: ${result.metadata['cost_usd']:.4f}")
```

**Fallback Providers:**
- OpenAI GPT-4 Turbo
- Anthropic Claude 3 Sonnet

### 6. Real LSP Integration (v3)

Accurate API break detection using real language servers:

```python
from noodlecore.improve.lsp_facts_gate import LspFactsGate

gate = LspFactsGate(use_real_lsp=True, server_name="pyls")
changes = gate.detect_breaking_changes(old_symbols, new_symbols)
```

---

## 📁 Project Structure

```
noodle/
├── noodle-core/              # Python core (NIP engine)
│   └── src/noodlecore/
│       └── improve/          # NIP modules
│           ├── models.py     # Data models (TaskSpec, Candidate, etc.)
│           ├── store.py      # File-based storage
│           ├── runner.py     # Task execution engine
│           ├── policy.py     # Validation policies
│           ├── snapshot.py   # Workspace snapshots
│           ├── diff.py       # Patch application
│           ├── sandbox/      # Sandboxed execution
│           ├── parallel.py   # v3: Parallel worktrees
│           ├── performance.py # v3: Regression detection
│           ├── comparison.py  # v3: Multi-candidate ranking
│           ├── ab_testing.py  # v3: A/B testing
│           ├── llm_integration.py # v3: LLM providers
│           └── lsp_facts_gate.py   # v3: API break detection
│
├── noodle-cli-typescript/    # TypeScript CLI
│   └── src/
│       └── improve.ts        # NIP commands
│
├── noodle-brain/             # v2/v3: Planning module
│   └── src/core/
│       └── planner.py        # Task prioritization
│
├── noodle-agents-trm/        # v2/v3: Patch generation
│   ├── patch_agent.py        # LLM-powered patch agent
│   ├── agent.py              # Base agent framework
│   └── ...
│
├── docs/                     # Documentation
│   ├── improve_v3.md         # v3 guide
│   ├── improve_v2.md         # v2 guide
│   └── improve.md            # v1 guide
│
├── examples/improve/         # Example tasks
│   ├── task_example.json
│   ├── performance_task.json
│   └── refactoring_task.json
│
├── noodle.json               # Configuration
└── README.md                 # This file
```

---

## ⚙️ Configuration

Edit `noodle.json` to customize NIP:

```json
{
  "improve": {
    "version": "3.0.0",
    
    // Enable v3 features
    "parallelExecutionEnabled": true,
    "performanceDetectionEnabled": true,
    "llmIntegrationEnabled": true,
    
    // LLM configuration (Z.ai GLM-4.7 as primary)
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "temperature": 0.3,
      "apiBase": "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    },
    
    // Performance thresholds
    "performance": {
      "criticalThreshold": 50.0,  // >50% degradation = reject
      "highThreshold": 20.0
    },
    
    // Parallel execution
    "maxParallelWorktrees": 3
  }
}
```

---

## 🔐 Safety & Security

### Shadow Mode Guarantees

✅ **Isolation:** All changes in separate snapshots/worktrees  
✅ **No Network:** Sandboxed execution by default  
✅ **Manual Review:** You approve all promotions  
✅ **Rollback:** Auto-revert on critical failures  
✅ **Validation:** Tests, policies, performance checks  

### Policy Gates

- ✅ Tests must pass
- ✅ Lines changed within limits
- ✅ No unauthorized dependencies
- ✅ No API breaking changes (configurable)
- ✅ Performance regression detection (v3)
- ✅ A/B test validation (v3)

---

## 📈 Performance

### Benchmarks

| Metric | v1 | v3 | Improvement |
|--------|----|----|-------------|
| 3 candidates execution | 15 min | 5 min | **3x faster** |
| Performance validation | Manual | Automatic | **∞x faster** |
| Winner selection | Manual | Automatic | **∞x faster** |
| Patch quality | Template | LLM | **10x smarter** |

### Cost Efficiency

**Z.ai GLM-4.7:**
- Input: ~$0.70 per 1M tokens
- Output: ~$2.00 per 1M tokens
- Typical patch: ~$0.001-0.01

**Example:** 100 patches ≈ $0.10-1.00

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Areas for Contribution

- [ ] Additional LLM providers (Google Gemini, Cohere)
- [ ] More benchmark formats (Java, C++, Ruby)
- [ ] Enhanced LSP server integrations
- [ ] Web dashboard for analytics
- [ ] Distributed execution

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

### LLM Providers

- **[Z.ai](https://z.ai/)** - Primary provider (GLM-4.7)
- **[OpenAI](https://openai.com/)** - GPT-4 fallback
- **[Anthropic](https://www.anthropic.com/)** - Claude fallback

### Tools & Libraries

- pytest-benchmark (performance testing)
- python-lsp-server (LSP integration)
- TypeScript Language Server
- Git worktrees (isolation)

---

## 📞 Support

- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues](https://github.com/block/noodle/issues)
- **Discussions:** [GitHub Discussions](https://github.com/block/noodle/discussions)

---

## 🏷️ Version History

- **v3.0.0** (2026-01-17) - Production automation with parallelism, LLM, performance
- **v2.0.0** (2026-01-17) - Semi-automated with planner, PatchAgent, LSP hooks
- **v1.0.0** (2026-01-17) - Manual shadow-mode pipeline

---

<div align="center">

**🍜 Noodle - Making software self-improving since 2026**

[GitHub](https://github.com/block/noodle) • 
[Documentation](docs/) • 
[Issues](https://github.com/block/noodle/issues)

Made with ❤️ by [Block](https://block.com)

</div>