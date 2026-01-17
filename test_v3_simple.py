# -*- coding: utf-8 -*-
"""
NIP v3 Quick Test - Test only v3 modules
"""

import sys
from pathlib import Path

# Set UTF-8 encoding
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Add paths
core_path = Path(__file__).parent / "noodle-core" / "src"
sys.path.insert(0, str(core_path))

print("=" * 70)
print("NIP v3 Module Test")
print("=" * 70)
print()

# Test 1: Performance Detection
print("Test 1: Performance Detection")
print("-" * 70)

try:
    from noodlecore.improve.performance import (
        PerformanceDetector, BenchmarkResult, RegressionSeverity
    )
    print("✅ Performance module imported")
    
    detector = PerformanceDetector()
    
    baseline = [BenchmarkResult(name="test", value=100.0, unit="ms")]
    patch = [BenchmarkResult(name="test", value=70.0, unit="ms")]
    
    report = detector.detect_regression(baseline, patch, "TASK_001", "CAND_001")
    print(f"✅ Report generated: {report.overall_verdict}")
    print(f"   Improvements: {report.improvement_count}")
    print()
except Exception as e:
    print(f"❌ Error: {e}")
    print()

# Test 2: Comparison
print("Test 2: Multi-Candidate Comparison")
print("-" * 70)

try:
    from noodlecore.improve.comparison import (
        CandidateComparator, RankingStrategy, CandidateScore
    )
    print("✅ Comparison module imported")
    
    comparator = CandidateComparator(strategy=RankingStrategy.BALANCED)
    print(f"✅ Comparator created: {comparator.strategy.value}")
    print()
except Exception as e:
    print(f"❌ Error: {e}")
    print()

# Test 3: A/B Testing
print("Test 3: A/B Testing")
print("-" * 70)

try:
    from noodlecore.improve.ab_testing import (
        ABTestConfig, ABTestRunner, TrafficSplitStrategy
    )
    print("✅ A/B testing module imported")
    
    config = ABTestConfig(
        name="Test",
        warmup_iterations=3,
        measurement_iterations=10
    )
    print(f"✅ Config created: {config.name}")
    print()
except Exception as e:
    print(f"❌ Error: {e}")
    print()

# Test 4: Parallel Worktrees
print("Test 4: Parallel Worktree Execution")
print("-" * 70)

try:
    from noodlecore.improve.parallel import (
        WorktreeManager, WorktreeConfig, WorktreeState
    )
    print("✅ Parallel module imported")
    
    config = WorktreeConfig(max_parallel=3)
    print(f"✅ Config created: max_parallel={config.max_parallel}")
    print()
except Exception as e:
    print(f"❌ Error: {e}")
    print()

# Test 5: LLM Integration
print("Test 5: LLM Integration")
print("-" * 70)

try:
    from noodlecore.improve.llm_integration import (
        LLMProvider, LLMModel, LLMConfig, create_default_llm_manager
    )
    print("✅ LLM module imported")
    print(f"   Primary: Z.ai {LLMModel.GLM_4_7.value}")
    print(f"   Fallback: OpenAI {LLMModel.GPT_4_TURBO.value}")
    print()
except Exception as e:
    print(f"❌ Error: {e}")
    print()

print("=" * 70)
print("V3 Module Test Complete!")
print("=" * 70)