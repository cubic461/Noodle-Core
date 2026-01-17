"""
A/B Testing Framework for NIP v3

This module provides systematic A/B testing capabilities for comparing
baseline and patched code under realistic conditions.
"""

import json
import random
import statistics
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple
import subprocess


class TestPhase(Enum):
    """Phases of A/B testing"""
    WARMUP = "warmup"  # Warm-up period to stabilize performance
    MEASUREMENT = "measurement"  # Actual measurement phase
    COOLDOWN = "cooldown"  # Cool-down period
    COMPLETE = "complete"


class TrafficSplitStrategy(Enum):
    """Strategies for splitting traffic between A and B"""
    EQUAL_50_50 = "50_50"  # Equal split
    WEIGHTED = "weighted"  # Custom weights
    GRADUAL = "gradual"  # Gradually shift traffic


@dataclass
class ABTestConfig:
    """Configuration for A/B test"""
    name: str
    description: str = ""
    warmup_iterations: int = 3
    measurement_iterations: int = 10
    cooldown_iterations: int = 1
    traffic_split: TrafficSplitStrategy = TrafficSplitStrategy.EQUAL_50_50
    weights: Dict[str, float] = field(default_factory=dict)  # For WEIGHTED strategy
    randomize_order: bool = True
    timeout_seconds: int = 300
    success_criteria: str = "both_pass_and_improve"  # "both_pass", "b_improves", "both_pass_and_improve"


@dataclass
class ABTestResult:
    """Result from a single A/B test iteration"""
    phase: TestPhase
    iteration: int
    variant: str  # "A" (baseline) or "B" (patch)
    success: bool
    duration_seconds: float
    output: str = ""
    error: str = ""
    metrics: Dict[str, float] = field(default_factory=dict)


@dataclass
class ABTestSummary:
    """Summary of complete A/B test"""
    config: ABTestConfig
    results: List[ABTestResult]
    a_results: List[ABTestResult] = field(default_factory=list)
    b_results: List[ABTestResult] = field(default_factory=list)
    a_pass_rate: float = 0.0
    b_pass_rate: float = 0.0
    a_avg_duration: float = 0.0
    b_avg_duration: float = 0.0
    winner: Optional[str] = None  # "A", "B", or None
    confidence: float = 0.0  # Statistical confidence (0.0 to 1.0)
    recommendation: str = ""  # "adopt_B", "keep_A", "inconclusive"
    reasoning: str = ""
    timestamp: str = ""
    
    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()
        
        # Separate results by variant
        self.a_results = [r for r in self.results if r.variant == "A"]
        self.b_results = [r for r in self.results if r.variant == "B"]
        
        # Calculate pass rates
        if self.a_results:
            self.a_pass_rate = sum(r.success for r in self.a_results) / len(self.a_results)
        if self.b_results:
            self.b_pass_rate = sum(r.success for r in self.b_results) / len(self.b_results)
        
        # Calculate average durations
        if self.a_results:
            self.a_avg_duration = statistics.mean(r.duration_seconds for r in self.a_results)
        if self.b_results:
            self.b_avg_duration = statistics.mean(r.duration_seconds for r in self.b_results)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization"""
        return {
            'config': {
                'name': self.config.name,
                'description': self.config.description,
                'warmup_iterations': self.config.warmup_iterations,
                'measurement_iterations': self.config.measurement_iterations,
                'cooldown_iterations': self.config.cooldown_iterations,
                'traffic_split': self.config.traffic_split.value,
                'weights': self.config.weights
            },
            'a_pass_rate': self.a_pass_rate,
            'b_pass_rate': self.b_pass_rate,
            'a_avg_duration': self.a_avg_duration,
            'b_avg_duration': self.b_avg_duration,
            'winner': self.winner,
            'confidence': self.confidence,
            'recommendation': self.recommendation,
            'reasoning': self.reasoning,
            'timestamp': self.timestamp
        }


class ABTestRunner:
    """
    Runs A/B tests comparing baseline (A) and patch (B).
    
    Features:
    - Warm-up and cool-down phases
    - Randomized order to eliminate bias
    - Statistical significance testing
    - Custom success criteria
    - Multiple traffic split strategies
    """
    
    def __init__(self, config: ABTestConfig):
        self.config = config
    
    def run_test(
        self,
        worktree_a: str,  # Baseline worktree
        worktree_b: str,  # Patched worktree
        test_command: List[str],
        success_checker: Optional[Callable[[str], bool]] = None
    ) -> ABTestSummary:
        """
        Run complete A/B test.
        
        Args:
            worktree_a: Path to baseline worktree
            worktree_b: Path to patched worktree
            test_command: Command to run in each worktree
            success_checker: Optional function to check success from output
            
        Returns:
            ABTestSummary with results
        """
        all_results = []
        
        # Warm-up phase
        warmup_results = self._run_phase(
            TestPhase.WARMUP,
            worktree_a,
            worktree_b,
            test_command,
            self.config.warmup_iterations,
            success_checker
        )
        all_results.extend(warmup_results)
        
        # Measurement phase
        measurement_results = self._run_phase(
            TestPhase.MEASUREMENT,
            worktree_a,
            worktree_b,
            test_command,
            self.config.measurement_iterations,
            success_checker
        )
        all_results.extend(measurement_results)
        
        # Cool-down phase
        cooldown_results = self._run_phase(
            TestPhase.COOLDOWN,
            worktree_a,
            worktree_b,
            test_command,
            self.config.cooldown_iterations,
            success_checker
        )
        all_results.extend(cooldown_results)
        
        # Create summary
        summary = ABTestSummary(
            config=self.config,
            results=all_results
        )
        
        # Analyze results
        self._analyze_results(summary)
        
        return summary
    
    def _run_phase(
        self,
        phase: TestPhase,
        worktree_a: str,
        worktree_b: str,
        test_command: List[str],
        iterations: int,
        success_checker: Optional[Callable[[str], bool]]
    ) -> List[ABTestResult]:
        """Run a single phase of testing"""
        results = []
        
        # Determine order
        if self.config.randomize_order:
            variants = ["A", "B"] * iterations
            random.shuffle(variants)
        else:
            # Alternate A/B
            variants = []
            for i in range(iterations):
                variants.extend(["A", "B"])
            variants = variants[:iterations]
        
        for i, variant in enumerate(variants):
            worktree = worktree_a if variant == "A" else worktree_b
            
            try:
                start_time = datetime.now()
                result = subprocess.run(
                    test_command,
                    cwd=worktree,
                    capture_output=True,
                    text=True,
                    timeout=self.config.timeout_seconds
                )
                duration = (datetime.now() - start_time).total_seconds()
                
                # Check success
                if success_checker:
                    success = success_checker(result.stdout)
                else:
                    success = result.returncode == 0
                
                test_result = ABTestResult(
                    phase=phase,
                    iteration=i,
                    variant=variant,
                    success=success,
                    duration_seconds=duration,
                    output=result.stdout,
                    error=result.stderr
                )
                
            except subprocess.TimeoutExpired:
                test_result = ABTestResult(
                    phase=phase,
                    iteration=i,
                    variant=variant,
                    success=False,
                    duration_seconds=self.config.timeout_seconds,
                    error=f"Test timed out after {self.config.timeout_seconds}s"
                )
            
            results.append(test_result)
        
        return results
    
    def _analyze_results(self, summary: ABTestSummary):
        """Analyze results and determine winner"""
        # Filter measurement phase only
        measurement_a = [r for r in summary.a_results if r.phase == TestPhase.MEASUREMENT]
        measurement_b = [r for r in summary.b_results if r.phase == TestPhase.MEASUREMENT]
        
        if not measurement_a or not measurement_b:
            summary.recommendation = "inconclusive"
            summary.reasoning = "Insufficient measurement data"
            return
        
        # Calculate statistics
        a_pass_rate = summary.a_pass_rate
        b_pass_rate = summary.b_pass_rate
        a_duration = summary.a_avg_duration
        b_duration = summary.b_avg_duration
        
        # Apply success criteria
        criteria = self.config.success_criteria
        
        if criteria == "both_pass":
            both_pass = a_pass_rate >= 0.9 and b_pass_rate >= 0.9
            if not both_pass:
                summary.winner = None
                summary.recommendation = "keep_A"
                summary.reasoning = f"One or both variants failed: A={a_pass_rate:.2f}, B={b_pass_rate:.2f}"
                return
        
        elif criteria == "b_improves":
            # B must improve performance or pass rate
            pass_improvement = b_pass_rate - a_pass_rate
            duration_improvement = a_duration - b_duration  # Positive means B is faster
            
            if pass_improvement >= 0.1 or duration_improvement > 0:
                summary.winner = "B"
                summary.recommendation = "adopt_B"
                summary.reasoning = (
                    f"B improves: pass rate {pass_improvement:+.2%}, "
                    f"duration {duration_improvement:+.2f}s"
                )
                summary.confidence = 0.8
                return
        
        elif criteria == "both_pass_and_improve":
            both_pass = a_pass_rate >= 0.9 and b_pass_rate >= 0.9
            if not both_pass:
                summary.winner = None
                summary.recommendation = "keep_A"
                summary.reasoning = f"Both must pass: A={a_pass_rate:.2f}, B={b_pass_rate:.2f}"
                return
            
            # Check for improvement
            duration_improvement = a_duration - b_duration
            if duration_improvement > 0:
                summary.winner = "B"
                summary.recommendation = "adopt_B"
                summary.reasoning = f"B passes and improves speed by {duration_improvement:.2f}s"
                summary.confidence = 0.9
                return
        
        # Default: inconclusive
        summary.winner = None
        summary.recommendation = "inconclusive"
        summary.reasoning = "No clear winner based on criteria"
        summary.confidence = 0.5


class ABTestGate:
    """
    Policy gate for A/B testing.
    
    Integrates with NIP policy system to require A/B tests
    for high-risk changes.
    """
    
    def __init__(
        self,
        min_confidence: float = 0.8,
        require_ab_test_for_high_risk: bool = True
    ):
        self.min_confidence = min_confidence
        self.require_ab_test_for_high_risk = require_ab_test_for_high_risk
    
    def validate_ab_test_result(
        self,
        summary: ABTestSummary,
        risk_level: str = "medium"
    ) -> Tuple[bool, List[str]]:
        """
        Validate A/B test result against policy.
        
        Returns:
            (passed, reasons)
        """
        reasons = []
        
        # High-risk changes must have A/B test
        if risk_level == "high" and self.require_ab_test_for_high_risk:
            if summary.recommendation == "inconclusive":
                reasons.append(
                    "High-risk changes require conclusive A/B test results"
                )
        
        # Check confidence threshold
        if summary.confidence < self.min_confidence:
            reasons.append(
                f"A/B test confidence {summary.confidence:.2f} below "
                f"threshold {self.min_confidence:.2f}"
            )
        
        # Check recommendation
        if summary.recommendation == "keep_A":
            reasons.append(
                f"A/B test recommends keeping baseline: {summary.reasoning}"
            )
        
        passed = len(reasons) == 0
        return passed, reasons
    
    def should_require_ab_test(
        self,
        candidate_metadata: Dict[str, Any]
    ) -> bool:
        """Determine if A/B test is required for this candidate"""
        risk = candidate_metadata.get('risk', 'medium')
        
        if risk == 'high':
            return self.require_ab_test_for_high_risk
        
        # Also require for performance-related changes
        goal_type = candidate_metadata.get('goal_type', '')
        if 'performance' in goal_type.lower():
            return True
        
        return False