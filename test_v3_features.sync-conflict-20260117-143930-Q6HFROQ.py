"""
NIP v3 Feature Demonstration Script

This script demonstrates all v3 features:
1. Parallel Worktree Execution
2. Performance Regression Detection
3. Multi-Candidate Comparison
4. A/B Testing
5. LLM Integration
"""

import sys
import os
from pathlib import Path

# Add paths
core_path = Path(__file__).parent / "noodle-core" / "src"
agents_path = Path(__file__).parent / "noodle-agents-trm"

sys.path.insert(0, str(core_path))
sys.path.insert(0, str(agents_path))

print("=" * 70)
print("🍜 Noodle Improvement Pipeline v3 - Feature Demonstration")
print("=" * 70)
print()

# Test 1: Import all v3 modules
print("📦 Test 1: Import v3 modules")
print("-" * 70)

try:
    from noodlecore.improve import (
        TaskSpec, Candidate, CandidateStatus,
        WorktreeManager, WorktreeConfig,
        PerformanceDetector, BenchmarkRunner,
        CandidateComparator, RankingStrategy,
        ABTestRunner, ABTestConfig,
        get_version_info
    )
    print("✅ Core modules imported successfully")
except ImportError as e:
    print(f"❌ Import failed: {e}")
    print("Note: v3 features require: pip install requests pytest-benchmark")
    sys.exit(1)

try:
    from noodle_agents_trm.patch_agent import (
        LLMPatchAgent, HybridPatchAgent, create_patch_agent
    )
    print("✅ PatchAgent modules imported successfully")
except ImportError as e:
    print(f"⚠️  PatchAgent import failed: {e}")
    print("Note: LLM features require noodle-agents-trm module")

print()

# Test 2: Check version info
print("📊 Test 2: Version and Feature Availability")
print("-" * 70)

info = get_version_info()
print(f"NIP Version: {info['version']}")
print()
print("Feature Availability:")
for feature, available in info['features'].items():
    status = "✅" if available else "❌"
    print(f"  {status} {feature}")

print()

# Test 3: Performance Detection
print("📊 Test 3: Performance Regression Detection")
print("-" * 70)

detector = PerformanceDetector(
    critical_threshold=50.0,
    high_threshold=20.0,
    medium_threshold=10.0,
    low_threshold=5.0
)
print("✅ PerformanceDetector configured")
print(f"   Critical threshold: >50% degradation")
print(f"   High threshold: >20% degradation")
print(f"   Medium threshold: >10% degradation")
print(f"   Low threshold: >5% degradation")

# Simulate benchmark comparison
from noodlecore.improve.performance import BenchmarkResult

baseline = [
    BenchmarkResult(name="query_1", value=100.0, unit="ms"),
    BenchmarkResult(name="query_2", value=200.0, unit="ms"),
    BenchmarkResult(name="query_3", value=150.0, unit="ms")
]

patch = [
    BenchmarkResult(name="query_1", value=70.0, unit="ms"),  # 30% improvement
    BenchmarkResult(name="query_2", value=180.0, unit="ms"),  # 10% improvement
    BenchmarkResult(name="query_3", value=130.0, unit="ms")  # 13% improvement
]

report = detector.detect_regression(
    baseline_results=baseline,
    patch_results=patch,
    task_id="TEST_001",
    candidate_id="CAND_001"
)

print()
print("📈 Performance Analysis:")
print(f"   Overall verdict: {report.overall_verdict.upper()}")
print(f"   Regressions: {report.regression_count}")
print(f"   Improvements: {report.improvement_count}")
print(f"   Neutral: {report.neutral_count}")
print()

for comp in report.comparisons:
    direction_icon = "📉" if comp.direction == "improvement" else "📈" if comp.direction == "regression" else "➡️"
    print(f"   {direction_icon} {comp.name}: {comp.percent_change:+.1f}% ({comp.severity.value})")

print()

# Test 4: Multi-Candidate Comparison
print("🔀 Test 4: Multi-Candidate Comparison")
print("-" * 70)

comparator = CandidateComparator(strategy=RankingStrategy.PERFORMANCE_FOCUSED)
print("✅ CandidateComparator created (PERFORMANCE_FOCUSED)")

# Create mock candidates and scores
from noodlecore.improve.comparison import CandidateScore

scores = [
    CandidateScore(
        candidate_id="CAND_001",
        overall_score=0.85,
        performance_score=0.95,
        safety_score=0.80,
        innovation_score=0.70,
        test_pass_rate=0.90,
        confidence=0.90,
        metadata={"strategy": "llm_based"}
    ),
    CandidateScore(
        candidate_id="CAND_002",
        overall_score=0.75,
        performance_score=0.80,
        safety_score=0.85,
        innovation_score=0.60,
        test_pass_rate=0.95,
        confidence=0.80,
        metadata={"strategy": "template"}
    ),
    CandidateScore(
        candidate_id="CAND_003",
        overall_score=0.65,
        performance_score=0.70,
        safety_score=0.75,
        innovation_score=0.85,
        test_pass_rate=0.85,
        confidence=0.70,
        metadata={"strategy": "hybrid"}
    )
]

print()
print("🏆 Candidate Ranking:")
for i, score in enumerate(sorted(scores, key=lambda s: s.overall_score, reverse=True), 1):
    print(f"   {i}. {score.candidate_id}: {score.overall_score:.2f}")
    print(f"      Performance: {score.performance_score:.2f} | Safety: {score.safety_score:.2f} | Innovation: {score.innovation_score:.2f}")

print()
print(f"   🥇 Winner: {scores[0].candidate_id} (score: {scores[0].overall_score:.2f})")

print()

# Test 5: A/B Testing Configuration
print("🧪 Test 5: A/B Testing Framework")
print("-" * 70)

from noodlecore.improve.ab_testing import TrafficSplitStrategy, TestPhase

config = ABTestConfig(
    name="Performance Comparison Test",
    description="Compare baseline vs patch performance",
    warmup_iterations=3,
    measurement_iterations=10,
    cooldown_iterations=1,
    traffic_split=TrafficSplitStrategy.EQUAL_50_50,
    randomize_order=True,
    success_criteria="both_pass_and_improve"
)

print("✅ ABTestConfig created")
print(f"   Name: {config.name}")
print(f"   Warmup iterations: {config.warmup_iterations}")
print(f"   Measurement iterations: {config.measurement_iterations}")
print(f"   Traffic split: {config.traffic_split.value}")
print(f"   Success criteria: {config.success_criteria}")

print()

# Test 6: LLM Integration (stub)
print("🤖 Test 6: LLM Integration")
print("-" * 70)

try:
    from noodlecore.improve.llm_integration import (
        LLMProvider, LLMModel, LLMConfig
    )
    print("✅ LLM integration available")
    print()
    print("   Supported Providers:")
    print(f"      • Z.ai: {LLMModel.GLM_4_7.value} (PRIMARY)")
    print(f"      • OpenAI: {LLMModel.GPT_4_TURBO.value}")
    print(f"      • Anthropic: {LLMModel.CLAUDE_3_SONNET.value}")
    print()
    print("   To enable LLM features:")
    print("      export ZAI_API_KEY='your-api-key'")
    print("      export OPENAI_API_KEY='your-openai-key'")
    
except ImportError:
    print("⚠️  LLM integration not available")
    print("   Install with: pip install requests")

print()

# Test 7: Worktree Configuration
print("🔄 Test 7: Parallel Worktree Configuration")
print("-" * 70)

worktree_config = WorktreeConfig(
    max_parallel=3,
    worktree_base_dir=".noodle/improve/worktrees",
    auto_cleanup=True,
    use_git_worktree=True
)

print("✅ WorktreeConfig created")
print(f"   Max parallel worktrees: {worktree_config.max_parallel}")
print(f"   Worktree directory: {worktree_config.worktree_base_dir}")
print(f"   Auto cleanup: {worktree_config.auto_cleanup}")
print(f"   Use git worktree: {worktree_config.use_git_worktree}")

print()

# Summary
print("=" * 70)
print("✨ NIP v3 Feature Demonstration Complete!")
print("=" * 70)
print()
print("📚 Next Steps:")
print("   1. Configure API keys for LLM features")
print("   2. Run: noodle improve task create --file examples/improve/task_v3_example.json")
print("   3. Run: noodle improve run --task TASK_V3_001 --parallel 3")
print("   4. Compare: noodle improve candidate compare --task TASK_V3_001")
print()
print("📖 Documentation:")
print("   • V3 Full Guide: docs/improve_v3.md")
print("   • V3 Changelog: CHANGELOG_NIP_v3.md")
print()