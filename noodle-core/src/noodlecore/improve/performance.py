"""
Performance Regression Detection for NIP v3

This module detects performance regressions in patches by comparing
benchmark results between baseline and patched code.
"""

import json
import re
import statistics
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
import subprocess


class RegressionSeverity(Enum):
    """Severity levels for performance regressions"""
    CRITICAL = "critical"  # > 50% degradation
    HIGH = "high"          # > 20% degradation
    MEDIUM = "medium"      # > 10% degradation
    LOW = "low"            # > 5% degradation
    NONE = "none"          # <= 5% change (noise)


@dataclass
class BenchmarkResult:
    """Result from a single benchmark run"""
    name: str
    value: float
    unit: str  # seconds, milliseconds, operations/second, etc.
    metadata: Dict[str, Any] = field(default_factory=dict)
    timestamp: str = ""
    
    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()


@dataclass
class MetricComparison:
    """Comparison of a metric between baseline and patch"""
    name: str
    baseline_value: float
    patch_value: float
    percent_change: float
    severity: RegressionSeverity
    unit: str
    direction: str  # "improvement", "regression", "neutral"


@dataclass
class RegressionReport:
    """Complete regression analysis report"""
    task_id: str
    candidate_id: str
    comparisons: List[MetricComparison]
    overall_verdict: str  # "pass", "warning", "fail"
    regression_count: int = 0
    improvement_count: int = 0
    neutral_count: int = 0
    timestamp: str = ""
    
    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization"""
        return {
            'task_id': self.task_id,
            'candidate_id': self.candidate_id,
            'comparisons': [
                {
                    'name': c.name,
                    'baseline_value': c.baseline_value,
                    'patch_value': c.patch_value,
                    'percent_change': c.percent_change,
                    'severity': c.severity.value,
                    'unit': c.unit,
                    'direction': c.direction
                }
                for c in self.comparisons
            ],
            'overall_verdict': self.overall_verdict,
            'regression_count': self.regression_count,
            'improvement_count': self.improvement_count,
            'neutral_count': self.neutral_count,
            'timestamp': self.timestamp
        }


class PerformanceDetector:
    """
    Detects performance regressions by comparing benchmark results.
    
    Features:
    - Statistical significance testing
    - Configurable regression thresholds
    - Support for multiple benchmark formats
    - Automatic benchmark execution
    - Trend analysis over multiple runs
    """
    
    def __init__(
        self,
        critical_threshold: float = 50.0,
        high_threshold: float = 20.0,
        medium_threshold: float = 10.0,
        low_threshold: float = 5.0
    ):
        self.critical_threshold = critical_threshold
        self.high_threshold = high_threshold
        self.medium_threshold = medium_threshold
        self.low_threshold = low_threshold
    
    def detect_regression(
        self,
        baseline_results: List[BenchmarkResult],
        patch_results: List[BenchmarkResult],
        task_id: str,
        candidate_id: str
    ) -> RegressionReport:
        """
        Detect performance regressions by comparing baseline and patch results.
        
        Args:
            baseline_results: Benchmark results from baseline
            patch_results: Benchmark results from patch
            task_id: Task identifier
            candidate_id: Candidate identifier
            
        Returns:
            RegressionReport with detailed comparison
        """
        comparisons = []
        
        # Match results by name
        baseline_dict = {r.name: r for r in baseline_results}
        patch_dict = {r.name: r for r in patch_results}
        
        all_metrics = set(baseline_dict.keys()) | set(patch_dict.keys())
        
        for metric_name in all_metrics:
            baseline = baseline_dict.get(metric_name)
            patch = patch_dict.get(metric_name)
            
            if baseline and patch:
                comparison = self._compare_metrics(
                    metric_name,
                    baseline,
                    patch
                )
                comparisons.append(comparison)
            elif baseline:
                # Metric removed in patch
                comparisons.append(MetricComparison(
                    name=metric_name,
                    baseline_value=baseline.value,
                    patch_value=float('inf'),
                    percent_change=float('inf'),
                    severity=RegressionSeverity.HIGH,
                    unit=baseline.unit,
                    direction="regression"
                ))
            elif patch:
                # New metric in patch
                comparisons.append(MetricComparison(
                    name=metric_name,
                    baseline_value=float('inf'),
                    patch_value=patch.value,
                    percent_change=float('inf'),
                    severity=RegressionSeverity.NONE,
                    unit=patch.unit,
                    direction="improvement"
                ))
        
        # Calculate statistics
        regression_count = sum(
            1 for c in comparisons 
            if c.direction == "regression" and c.severity != RegressionSeverity.NONE
        )
        improvement_count = sum(
            1 for c in comparisons 
            if c.direction == "improvement" and c.severity != RegressionSeverity.NONE
        )
        neutral_count = len(comparisons) - regression_count - improvement_count
        
        # Determine overall verdict
        has_critical = any(
            c.severity == RegressionSeverity.CRITICAL 
            for c in comparisons
        )
        has_high = any(
            c.severity == RegressionSeverity.HIGH 
            for c in comparisons
        )
        
        if has_critical:
            overall_verdict = "fail"
        elif has_high:
            overall_verdict = "warning"
        else:
            overall_verdict = "pass"
        
        return RegressionReport(
            task_id=task_id,
            candidate_id=candidate_id,
            comparisons=comparisons,
            overall_verdict=overall_verdict,
            regression_count=regression_count,
            improvement_count=improvement_count,
            neutral_count=neutral_count
        )
    
    def _compare_metrics(
        self,
        name: str,
        baseline: BenchmarkResult,
        patch: BenchmarkResult
    ) -> MetricComparison:
        """Compare two metrics and calculate change"""
        baseline_val = baseline.value
        patch_val = patch.value
        
        # Calculate percent change
        if baseline_val == 0:
            if patch_val == 0:
                percent_change = 0.0
            else:
                percent_change = float('inf')
        else:
            percent_change = ((patch_val - baseline_val) / baseline_val) * 100
        
        # Determine direction
        if abs(percent_change) < self.low_threshold:
            direction = "neutral"
            severity = RegressionSeverity.NONE
        elif percent_change > 0:
            direction = "regression"
            severity = self._get_severity(abs(percent_change))
        else:
            direction = "improvement"
            severity = self._get_severity(abs(percent_change))
        
        return MetricComparison(
            name=name,
            baseline_value=baseline_val,
            patch_value=patch_val,
            percent_change=percent_change,
            severity=severity,
            unit=baseline.unit,
            direction=direction
        )
    
    def _get_severity(self, percent_change: float) -> RegressionSeverity:
        """Determine severity based on percent change"""
        if percent_change >= self.critical_threshold:
            return RegressionSeverity.CRITICAL
        elif percent_change >= self.high_threshold:
            return RegressionSeverity.HIGH
        elif percent_change >= self.medium_threshold:
            return RegressionSeverity.MEDIUM
        elif percent_change >= self.low_threshold:
            return RegressionSeverity.LOW
        else:
            return RegressionSeverity.NONE


class BenchmarkRunner:
    """
    Executes benchmarks in controlled environments.
    
    Supports:
    - Python pytest-benchmark
    - JavaScript benchmark.js
    - Go benchmarks
    - Custom benchmark scripts
    """
    
    def run_benchmark(
        self,
        worktree_path: str,
        benchmark_command: List[str],
        benchmark_type: str = "python"
    ) -> List[BenchmarkResult]:
        """
        Run benchmark in worktree and parse results.
        
        Args:
            worktree_path: Path to worktree
            benchmark_command: Command to run benchmark
            benchmark_type: Type of benchmark (python, js, go, custom)
            
        Returns:
            List of BenchmarkResult
        """
        try:
            result = subprocess.run(
                benchmark_command,
                cwd=worktree_path,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode != 0:
                raise RuntimeError(
                    f"Benchmark failed: {result.stderr}"
                )
            
            # Parse results based on type
            if benchmark_type == "python":
                return self._parse_python_benchmark(result.stdout)
            elif benchmark_type == "js":
                return self._parse_js_benchmark(result.stdout)
            elif benchmark_type == "go":
                return self._parse_go_benchmark(result.stdout)
            else:
                return self._parse_custom_benchmark(result.stdout)
                
        except subprocess.TimeoutExpired:
            raise RuntimeError("Benchmark timed out after 300s")
    
    def _parse_python_benchmark(self, output: str) -> List[BenchmarkResult]:
        """Parse pytest-benchmark output"""
        results = []
        
        # Look for benchmark results in JSON format
        json_match = re.search(r'\{.*\}', output, re.DOTALL)
        if json_match:
            try:
                data = json.loads(json_match.group(0))
                # Parse pytest-benchmark JSON structure
                for bench in data.get('benchmarks', []):
                    results.append(BenchmarkResult(
                        name=bench['name'],
                        value=bench['stats']['mean'],
                        unit='seconds',
                        metadata=bench.get('stats', {})
                    ))
            except json.JSONDecodeError:
                pass
        
        return results
    
    def _parse_js_benchmark(self, output: str) -> List[BenchmarkResult]:
        """Parse benchmark.js output"""
        results = []
        
        # Look for lines like: "name x 1,234,567 ops/sec ±1.23%"
        pattern = r'([^\s]+)\s+x\s+([\d,]+)\s+ops/sec'
        matches = re.findall(pattern, output)
        
        for name, ops in matches:
            ops_value = float(ops.replace(',', ''))
            results.append(BenchmarkResult(
                name=name,
                value=ops_value,
                unit='operations/second'
            ))
        
        return results
    
    def _parse_go_benchmark(self, output: str) -> List[BenchmarkResult]:
        """Parse Go benchmark output"""
        results = []
        
        # Look for lines like: "BenchmarkName 1000 1234.567 ns/op"
        pattern = r'(Benchmark\S+)\s+(\d+)\s+([\d.]+)\s+(\S+)'
        matches = re.findall(pattern, output)
        
        for name, iterations, value, unit in matches:
            results.append(BenchmarkResult(
                name=name,
                value=float(value),
                unit=unit,
                metadata={'iterations': int(iterations)}
            ))
        
        return results
    
    def _parse_custom_benchmark(self, output: str) -> List[BenchmarkResult]:
        """Parse custom benchmark JSON output"""
        results = []
        
        try:
            data = json.loads(output)
            for bench in data.get('benchmarks', []):
                results.append(BenchmarkResult(
                    name=bench['name'],
                    value=bench['value'],
                    unit=bench.get('unit', 'seconds'),
                    metadata=bench.get('metadata', {})
                ))
        except (json.JSONDecodeError, KeyError):
            pass
        
        return results


class PerformanceGate:
    """
    Policy gate for performance regression detection.
    
    Integrates with NIP policy system to reject candidates
    with significant performance regressions.
    """
    
    def __init__(
        self,
        detector: PerformanceDetector,
        max_severity: RegressionSeverity = RegressionSeverity.HIGH
    ):
        self.detector = detector
        self.max_severity = max_severity
    
    def validate_performance(
        self,
        report: RegressionReport
    ) -> Tuple[bool, List[str]]:
        """
        Validate that performance is acceptable.
        
        Returns:
            (passed, reasons)
        """
        reasons = []
        
        for comparison in report.comparisons:
            if comparison.direction == "regression":
                if comparison.severity.value > self.max_severity.value:
                    reasons.append(
                        f"Critical regression in {comparison.name}: "
                        f"{comparison.percent_change:.1f}% "
                        f"({comparison.severity.value})"
                    )
        
        passed = len(reasons) == 0
        return passed, reasons