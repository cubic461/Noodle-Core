"""
Noodle Improvement Pipeline (NIP) - v3

A production-grade, self-improving development system with:
- Parallel worktree execution
- Performance regression detection
- Multi-candidate comparison
- A/B testing framework
- Full LLM integration (Z.ai GLM-4.7, OpenAI, Anthropic)
- Real LSP server integration
- Automatic rollback
- Enhanced analytics
"""

from .models import (
    TaskSpec,
    Candidate,
    CandidateStatus,
    Evidence,
    PromotionRecord,
    PromotionDecision
)

from .store import (
    TaskStore,
    CandidateStore,
    EvidenceStore,
    PromotionStore
)

from .policy import (
    PolicyRule,
    PolicyGate,
    PolicyResult,
    StandardPolicies
)

from .snapshot import (
    WorkspaceSnapshot,
    SnapshotManager
)

from .diff import (
    DiffApplier,
    count_loc,
    validate_diff
)

# v2 Features
try:
    from .policy_v2 import (
        LSPAPIBreakRule,
        EnhancedPolicyGate
    )
    _v2_available = True
except ImportError:
    _v2_available = False

# v3 Features
try:
    from .parallel import (
        WorktreeManager,
        WorktreeConfig,
        Worktree,
        WorktreeResult,
        WorktreeState
    )
    _parallel_available = True
except ImportError:
    _parallel_available = False

try:
    from .performance import (
        PerformanceDetector,
        BenchmarkRunner,
        PerformanceGate,
        RegressionReport,
        BenchmarkResult,
        RegressionSeverity
    )
    _performance_available = True
except ImportError:
    _performance_available = False

try:
    from .comparison import (
        CandidateComparator,
        MultiCandidateSelector,
        RankingStrategy,
        ComparisonResult,
        CandidateScore
    )
    _comparison_available = True
except ImportError:
    _comparison_available = False

try:
    from .ab_testing import (
        ABTestRunner,
        ABTestConfig,
        ABTestGate,
        ABTestSummary,
        ABTestResult,
        TestPhase,
        TrafficSplitStrategy
    )
    _ab_testing_available = True
except ImportError:
    _ab_testing_available = False

try:
    from .llm_integration import (
        LLMManager,
        LLMConfig,
        LLMProvider,
        LLMModel,
        LLMRequest,
        LLMResponse,
        LLMProviderBase,
        ZAIProvider,
        OpenAIProvider,
        AnthropicProvider,
        create_default_llm_manager
    )
    _llm_available = True
except ImportError:
    _llm_available = False

try:
    from .lsp_facts_gate import (
        LspFactsGate,
        LSPAnalysisResult,
        APIChange,
        ChangeType,
        Severity,
        SymbolInfo,
        SimpleLspFactsGate
    )
    _lsp_available = True
except ImportError:
    _lsp_available = False

__version__ = "3.0.0"
__all__ = [
    # Core
    "TaskSpec",
    "Candidate",
    "CandidateStatus",
    "Evidence",
    "PromotionRecord",
    "PromotionDecision",
    "TaskStore",
    "CandidateStore",
    "EvidenceStore",
    "PromotionStore",
    "PolicyRule",
    "PolicyGate",
    "PolicyResult",
    "StandardPolicies",
    "WorkspaceSnapshot",
    "SnapshotManager",
    "DiffApplier",
    "count_loc",
    "validate_diff",
]

def get_version_info():
    """Get version and feature availability."""
    return {
        "version": __version__,
        "features": {
            "v2_planner": _v2_available,
            "v2_lsp_gate": _lsp_available,
            "v3_parallel": _parallel_available,
            "v3_performance": _performance_available,
            "v3_comparison": _comparison_available,
            "v3_ab_testing": _ab_testing_available,
            "v3_llm": _llm_available,
            "v3_real_lsp": _lsp_available
        }
    }

def check_dependencies():
    """Check which features are available."""
    info = get_version_info()
    missing = []
    
    if not _parallel_available:
        missing.append("parallel execution (requests library)")
    if not _performance_available:
        missing.append("performance detection (pytest-benchmark)")
    if not _llm_available:
        missing.append("LLM integration (requests library)")
    
    if missing:
        print("Warning: The following v3 features are not available:")
        for feat in missing:
            print(f"  - {feat}")
        print("\\nInstall with: pip install requests pytest-benchmark")
    
    return info