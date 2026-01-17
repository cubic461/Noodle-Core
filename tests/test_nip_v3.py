"""
NIP v3.0.0 Test Suite

Comprehensive tests for Noodle Improvement Pipeline v3.0.0 features:
- Parallel Execution
- Performance Detection
- Multi-Candidate Comparison
- A/B Testing
- LLM Integration
- LSP Gate
- Automatic Rollback
- Analytics
"""

import pytest
import asyncio
import json
from pathlib import Path
from typing import Dict, List, Any
from unittest.mock import Mock, patch, AsyncMock
import tempfile
import shutil


class TestParallelExecution:
    """Test parallel execution with Git worktrees"""
    
    @pytest.fixture
    def temp_repo(self, tmp_path):
        """Create a temporary Git repository"""
        import subprocess
        
        repo_dir = tmp_path / "test_repo"
        repo_dir.mkdir()
        
        # Initialize Git repo
        subprocess.run(["git", "init"], cwd=repo_dir, check=True)
        subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_dir, check=True)
        subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_dir, check=True)
        
        # Create initial commit
        (repo_dir / "README.md").write_text("# Test Repo")
        subprocess.run(["git", "add", "."], cwd=repo_dir, check=True)
        subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo_dir, check=True)
        
        return repo_dir
    
    @pytest.mark.asyncio
    async def test_parallel_worktree_creation(self, temp_repo):
        """Test creating multiple worktrees in parallel"""
        from noodle.improve.parallel import WorktreeManager
        
        manager = WorktreeManager(temp_repo, max_parallel=3)
        
        # Create 3 worktrees
        worktrees = await manager.create_worktrees(["candidate1", "candidate2", "candidate3"])
        
        assert len(worktrees) == 3
        for wt in worktrees:
            assert wt.exists()
            assert (wt / ".git").exists()
        
        # Cleanup
        await manager.cleanup()
    
    @pytest.mark.asyncio
    async def test_parallel_execution_speedup(self, temp_repo):
        """Test that parallel execution provides speedup"""
        import time
        from noodle.improve.parallel import execute_in_parallel
        
        async def mock_task(candidate_id: str) -> str:
            await asyncio.sleep(1)
            return candidate_id
        
        # Sequential execution
        start = time.time()
        results_seq = []
        for i in range(3):
            results_seq.append(await mock_task(f"candidate{i}"))
        seq_time = time.time() - start
        
        # Parallel execution
        start = time.time()
        results_par = await execute_in_parallel(
            [mock_task(f"candidate{i}") for i in range(3)],
            max_parallel=3
        )
        par_time = time.time() - start
        
        # Parallel should be faster
        assert par_time < seq_time * 0.6  # At least 40% faster
        assert len(results_par) == 3


class TestPerformanceDetection:
    """Test performance regression detection"""
    
    @pytest.fixture
    def performance_data(self):
        """Sample performance data"""
        return {
            "baseline": {
                "response_time": 100,
                "throughput": 1000,
                "memory": 512
            },
            "candidate": {
                "response_time": 125,
                "throughput": 800,
                "memory": 640
            }
        }
    
    def test_performance_regression_detection(self, performance_data):
        """Test detecting performance regression"""
        from noodle.improve.performance import PerformanceDetector
        
        detector = PerformanceDetector(threshold_percent=15)
        regression = detector.detect_regression(
            performance_data["baseline"],
            performance_data["candidate"]
        )
        
        assert regression["has_regression"] == True
        assert regression["metrics"]["response_time"]["regression"] == 25.0
        assert regression["metrics"]["throughput"]["regression"] == -20.0
    
    def test_no_regression(self, performance_data):
        """Test when performance is within threshold"""
        from noodle.improve.performance import PerformanceDetector
        
        good_candidate = {
            "response_time": 105,  # 5% increase
            "throughput": 980,     # 2% decrease
            "memory": 520
        }
        
        detector = PerformanceDetector(threshold_percent=15)
        regression = detector.detect_regression(
            performance_data["baseline"],
            good_candidate
        )
        
        assert regression["has_regression"] == False
    
    def test_statistical_significance(self):
        """Test statistical significance calculation"""
        from noodle.improve.performance import PerformanceDetector
        
        baseline_samples = [100, 102, 98, 101, 99]
        candidate_samples = [120, 125, 118, 122, 115]
        
        detector = PerformanceDetector()
        result = detector.calculate_statistical_significance(
            baseline_samples,
            candidate_samples
        )
        
        assert result["significant"] == True
        assert result["p_value"] < 0.05


class TestMultiCandidateComparison:
    """Test multi-candidate comparison and ranking"""
    
    @pytest.fixture
    def candidates(self):
        """Sample candidates"""
        return [
            {
                "id": "candidate1",
                "metrics": {
                    "performance": 0.85,
                    "safety": 0.90,
                    "innovation": 0.75
                }
            },
            {
                "id": "candidate2",
                "metrics": {
                    "performance": 0.70,
                    "safety": 0.95,
                    "innovation": 0.80
                }
            },
            {
                "id": "candidate3",
                "metrics": {
                    "performance": 0.90,
                    "safety": 0.85,
                    "innovation": 0.70
                }
            }
        ]
    
    def test_balanced_ranking(self, candidates):
        """Test balanced ranking strategy"""
        from noodle.improve.comparison import CandidateComparator
        
        comparator = CandidateComparator(strategy="BALANCED")
        ranked = comparator.rank_candidates(candidates)
        
        assert ranked[0]["id"] == "candidate1"
        assert ranked[-1]["id"] == "candidate2"
    
    def test_performance_focused_ranking(self, candidates):
        """Test performance-focused ranking"""
        from noodle.improve.comparison import CandidateComparator
        
        comparator = CandidateComparator(strategy="PERFORMANCE_FOCUSED")
        ranked = comparator.rank_candidates(candidates)
        
        assert ranked[0]["id"] == "candidate3"  # Highest performance
    
    def test_pareto_frontier(self, candidates):
        """Test Pareto frontier identification"""
        from noodle.improve.comparison import CandidateComparator
        
        comparator = CandidateComparator()
        pareto = comparator.get_pareto_frontier(candidates)
        
        # All candidates should be on Pareto frontier
        assert len(pareto) >= 2


class TestABTesting:
    """Test A/B testing functionality"""
    
    @pytest.mark.asyncio
    async def test_ab_test_execution(self):
        """Test running an A/B test"""
        from noodle.improve.ab_testing import ABTestEngine
        
        engine = ABTestEngine()
        
        config = {
            "warmup_iterations": 2,
            "measurement_iterations": 5,
            "success_criteria": "both_pass_and_improve"
        }
        
        results = await engine.run_test(
            baseline=lambda: {"response_time": 100},
            candidate=lambda: {"response_time": 90},
            config=config
        )
        
        assert results["winner"] == "candidate"
        assert results["improvement_percent"] > 0
    
    @pytest.mark.asyncio
    async def test_statistical_tests(self):
        """Test statistical test methods"""
        from noodle.improve.ab_testing import ABTestEngine
        
        engine = ABTestEngine()
        
        baseline_data = [100, 102, 98, 101, 99]
        candidate_data = [90, 92, 88, 91, 89]
        
        # T-test
        t_result = engine.t_test(baseline_data, candidate_data)
        assert t_result["significant"] == True
        
        # Mann-Whitney U
        mw_result = engine.mann_whitney_u(baseline_data, candidate_data)
        assert mw_result["significant"] == True


class TestLLMIntegration:
    """Test LLM integration features"""
    
    @pytest.mark.asyncio
    async def test_llm_provider_selection(self):
        """Test LLM provider selection and fallback"""
        from noodle.improve.llm import LLMManager
        
        manager = LLMManager()
        
        # Test primary provider
        config = {
            "primary": {"provider": "z_ai", "model": "glm-4.7"},
            "fallbacks": [
                {"provider": "openai", "model": "gpt-4"}
            ]
        }
        
        provider = manager.select_provider(config)
        assert provider["provider"] == "z_ai"
    
    @pytest.mark.asyncio
    async def test_cost_tracking(self):
        """Test LLM cost tracking"""
        from noodle.improve.llm import LLMManager
        
        manager = LLMManager()
        manager.add_request_cost("z_ai", "glm-4.7", 1000)
        manager.add_request_cost("openai", "gpt-4", 500)
        
        costs = manager.get_total_costs()
        assert costs["z_ai"] > 0
        assert costs["total"] > 0
    
    @pytest.mark.asyncio
    async def test_budget_alerts(self):
        """Test budget alert system"""
        from noodle.improve.llm import LLMManager
        
        manager = LLMManager(monthly_budget=100)
        
        # Should not alert
        manager.add_request_cost("z_ai", "glm-4.7", 10000)  # $10
        assert manager.check_budget() == False
        
        # Should alert
        manager.add_request_cost("z_ai", "glm-4.7", 900000)  # $90
        assert manager.check_budget() == True


class TestLSPGate:
    """Test LSP Gate validation"""
    
    @pytest.mark.asyncio
    async def test_lsp_validation(self):
        """Test LSP-based validation"""
        from noodle.improve.lsp_gate import LSPGate
        
        gate = LSPGate()
        
        # Valid code
        valid_code = "function add(a, b) { return a + b; }"
        result = await gate.validate(valid_code, language="typescript")
        assert result["valid"] == True
        
        # Invalid code
        invalid_code = "function add(a, b) { return a + }"
        result = await gate.validate(invalid_code, language="typescript")
        assert result["valid"] == False
    
    @pytest.mark.asyncio
    async def test_multi_language_lsp(self):
        """Test LSP support for multiple languages"""
        from noodle.improve.lsp_gate import LSPGate
        
        gate = LSPGate()
        
        # Test TypeScript
        ts_code = "const x: number = 5;"
        ts_result = await gate.validate(ts_code, language="typescript")
        assert ts_result["language"] == "typescript"
        
        # Test Python
        py_code = "def add(a, b): return a + b"
        py_result = await gate.validate(py_code, language="python")
        assert py_result["language"] == "python"


class TestAutomaticRollback:
    """Test automatic rollback functionality"""
    
    @pytest.mark.asyncio
    async def test_rollback_on_test_failure(self):
        """Test rollback triggered by test failure"""
        from noodle.improve.rollback import RollbackManager
        
        manager = RollbackManager(strategy="git_revert")
        
        # Simulate test failure
        trigger = {"type": "test_failure", "failed_tests": 3}
        decision = manager.should_rollback(trigger)
        
        assert decision == True
    
    @pytest.mark.asyncio
    async def test_rollback_on_performance_regression(self):
        """Test rollback triggered by performance regression"""
        from noodle.improve.rollback import RollbackManager
        
        manager = RollbackManager()
        
        # Simulate performance regression
        trigger = {
            "type": "performance_regression",
            "regression_percent": 25,
            "threshold": 15
        }
        decision = manager.should_rollback(trigger)
        
        assert decision == True
    
    @pytest.mark.asyncio
    async def test_graceful_degradation(self):
        """Test graceful degradation instead of rollback"""
        from noodle.improve.rollback import RollbackManager
        
        manager = RollbackManager(degraded_mode_enabled=True)
        
        # Trigger that triggers degraded mode
        trigger = {"type": "timeout", "severity": "medium"}
        action = manager.decide_action(trigger)
        
        assert action["mode"] == "degraded"


class TestAnalytics:
    """Test analytics and monitoring"""
    
    @pytest.mark.asyncio
    async def test_metrics_collection(self):
        """Test metrics collection"""
        from noodle.analytics import MetricsCollector
        
        collector = MetricsCollector()
        
        # Record metrics
        collector.record_metric("pipeline_duration", 120)
        collector.record_metric("candidate_success_rate", 0.85)
        
        metrics = collector.get_metrics()
        assert metrics["pipeline_duration"]["avg"] == 120
        assert metrics["candidate_success_rate"]["avg"] == 0.85
    
    @pytest.mark.asyncio
    async def test_dashboard_data_generation(self):
        """Test dashboard data generation"""
        from noodle.analytics import DashboardGenerator
        
        generator = DashboardGenerator()
        data = generator.generate_dashboard_data()
        
        assert "pipeline_performance" in data
        assert "candidate_success_rate" in data
        assert "resource_utilization" in data


class TestIntegration:
    """Integration tests for the full pipeline"""
    
    @pytest.mark.asyncio
    async def test_full_pipeline_execution(self):
        """Test running the full NIP pipeline"""
        from noodle.improve.pipeline import NIPPipeline
        
        pipeline = NIPPipeline(config={
            "parallel_execution": True,
            "max_candidates": 3,
            "gates": ["lsp", "test", "benchmark"]
        })
        
        # Run pipeline
        result = await pipeline.run(
            task="Refactor this function to be more efficient",
            context="def process_data(data): return [x * 2 for x in data]"
        )
        
        assert result["success"] == True
        assert "selected_candidate" in result
        assert result["metrics"]["total_duration"] > 0
    
    @pytest.mark.asyncio
    async def test_pipeline_with_rollback(self):
        """Test pipeline with automatic rollback"""
        from noodle.improve.pipeline import NIPPipeline
        
        pipeline = NIPPipeline(config={
            "rollback_enabled": True,
            "rollback_triggers": ["test_failure", "performance_regression"]
        })
        
        # Simulate a failing candidate
        result = await pipeline.run(
            task="Add a bug to this code",
            context="def test(): return True"
        )
        
        # Should rollback to baseline
        assert result["rollback_triggered"] == True
        assert result["final_state"] == "baseline"


# Pytest configuration
def pytest_configure(config):
    """Configure pytest markers"""
    config.addinivalue_line(
        "markers", "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
    config.addinivalue_line(
        "markers", "unit: marks tests as unit tests"
    )


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
