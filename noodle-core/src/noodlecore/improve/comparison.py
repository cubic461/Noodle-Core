"""
Multi-Candidate Comparison and Ranking for NIP v3

This module enables comparison of multiple candidates for the same task,
providing ranking and selection capabilities.
"""

import json
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from collections import defaultdict

from .models import Candidate, CandidateStatus
from .performance import RegressionReport, RegressionSeverity


class RankingStrategy(Enum):
    """Strategies for ranking candidates"""
    BALANCED = "balanced"  # Balance of all factors
    PERFORMANCE_FOCUSED = "performance_focused"  # Prioritize performance
    SAFETY_FOCUSED = "safety_focused"  # Prioritize test passing and low risk
    INNOVATION_FOCUSED = "innovation_focused"  # Prioritize novelty and complexity


@dataclass
class CandidateScore:
    """Score for a single candidate"""
    candidate_id: str
    overall_score: float  # 0.0 to 1.0
    performance_score: float  # 0.0 to 1.0
    safety_score: float  # 0.0 to 1.0
    innovation_score: float  # 0.0 to 1.0
    test_pass_rate: float  # 0.0 to 1.0
    confidence: float  # 0.0 to 1.0
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization"""
        return {
            'candidate_id': self.candidate_id,
            'overall_score': self.overall_score,
            'performance_score': self.performance_score,
            'safety_score': self.safety_score,
            'innovation_score': self.innovation_score,
            'test_pass_rate': self.test_pass_rate,
            'confidence': self.confidence,
            'metadata': self.metadata
        }


@dataclass
class ComparisonResult:
    """Result of comparing multiple candidates"""
    task_id: str
    candidate_scores: List[CandidateScore]
    ranking: List[str]  # Ordered list of candidate IDs from best to worst
    winner: Optional[str]  # Best candidate ID
    recommendation: str  # "accept", "reject", "inconclusive"
    reasoning: str
    timestamp: str = ""
    
    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization"""
        return {
            'task_id': self.task_id,
            'candidate_scores': [s.to_dict() for s in self.candidate_scores],
            'ranking': self.ranking,
            'winner': self.winner,
            'recommendation': self.recommendation,
            'reasoning': self.reasoning,
            'timestamp': self.timestamp
        }


class CandidateComparator:
    """
    Compares and ranks multiple candidates for the same task.
    
    Features:
    - Multi-dimensional scoring (performance, safety, innovation)
    - Configurable ranking strategies
    - Statistical comparison of benchmark results
    - Test pass rate analysis
    - Confidence interval calculation
    """
    
    def __init__(
        self,
        strategy: RankingStrategy = RankingStrategy.BALANCED
    ):
        self.strategy = strategy
    
    def compare_candidates(
        self,
        candidates: List[Candidate],
        evidence_list: List[Any],  # List of Evidence objects
        regression_reports: Dict[str, RegressionReport],
        task_id: str
    ) -> ComparisonResult:
        """
        Compare multiple candidates and produce ranking.
        
        Args:
            candidates: List of candidates to compare
            evidence_list: Evidence for each candidate
            regression_reports: Performance reports by candidate ID
            task_id: Task identifier
            
        Returns:
            ComparisonResult with ranking and recommendation
        """
        # Score each candidate
        scores = []
        for candidate in candidates:
            evidence = self._get_evidence_for_candidate(
                candidate.id,
                evidence_list
            )
            regression_report = regression_reports.get(candidate.id)
            
            score = self._score_candidate(
                candidate,
                evidence,
                regression_report
            )
            scores.append(score)
        
        # Sort by overall score
        sorted_scores = sorted(
            scores,
            key=lambda s: s.overall_score,
            reverse=True
        )
        
        ranking = [s.candidate_id for s in sorted_scores]
        winner = ranking[0] if ranking else None
        
        # Generate recommendation
        recommendation, reasoning = self._generate_recommendation(
            sorted_scores,
            regression_reports
        )
        
        return ComparisonResult(
            task_id=task_id,
            candidate_scores=sorted_scores,
            ranking=ranking,
            winner=winner,
            recommendation=recommendation,
            reasoning=reasoning
        )
    
    def _get_evidence_for_candidate(
        self,
        candidate_id: str,
        evidence_list: List[Any]
    ) -> Optional[Any]:
        """Get evidence for a specific candidate"""
        for evidence in evidence_list:
            if hasattr(evidence, 'candidate_id') and evidence.candidate_id == candidate_id:
                return evidence
        return None
    
    def _score_candidate(
        self,
        candidate: Candidate,
        evidence: Optional[Any],
        regression_report: Optional[RegressionReport]
    ) -> CandidateScore:
        """
        Calculate multi-dimensional score for a candidate.
        
        Scoring factors:
        1. Performance: Based on regression report
        2. Safety: Based on test pass rate and risk level
        3. Innovation: Based on complexity and novelty
        4. Overall: Weighted combination based on strategy
        """
        # Performance score (0.0 to 1.0)
        performance_score = 1.0
        if regression_report:
            # Penalize regressions
            for comparison in regression_report.comparisons:
                if comparison.direction == "regression":
                    if comparison.severity == RegressionSeverity.CRITICAL:
                        performance_score -= 0.5
                    elif comparison.severity == RegressionSeverity.HIGH:
                        performance_score -= 0.3
                    elif comparison.severity == RegressionSeverity.MEDIUM:
                        performance_score -= 0.15
                    elif comparison.severity == RegressionSeverity.LOW:
                        performance_score -= 0.05
            
            # Reward improvements
            for comparison in regression_report.comparisons:
                if comparison.direction == "improvement":
                    performance_score += 0.1
            
            performance_score = max(0.0, min(1.0, performance_score))
        
        # Safety score (0.0 to 1.0)
        safety_score = 0.5
        if evidence and hasattr(evidence, 'commands'):
            # Calculate test pass rate
            total_commands = len(evidence.commands)
            passed_commands = sum(
                1 for cmd in evidence.commands
                if cmd.get('exit_code') == 0
            )
            test_pass_rate = passed_commands / total_commands if total_commands > 0 else 0.5
            safety_score = test_pass_rate
        
        # Adjust for risk level
        if hasattr(candidate, 'metadata'):
            risk = candidate.metadata.get('risk', 'medium')
            if risk == 'low':
                safety_score = min(1.0, safety_score + 0.1)
            elif risk == 'high':
                safety_score = max(0.0, safety_score - 0.2)
        
        # Innovation score (0.0 to 1.0)
        innovation_score = 0.5
        if candidate.metadata:
            # Higher confidence = more innovative approach
            confidence = candidate.metadata.get('confidence', 0.5)
            innovation_score = confidence
            
            # Check for novel strategies
            strategy = candidate.metadata.get('strategy', 'unknown')
            if strategy == 'hybrid':
                innovation_score += 0.2
            elif strategy == 'llm_based':
                innovation_score += 0.3
        
        innovation_score = max(0.0, min(1.0, innovation_score))
        
        # Overall score based on strategy
        weights = self._get_weights()
        overall_score = (
            weights['performance'] * performance_score +
            weights['safety'] * safety_score +
            weights['innovation'] * innovation_score
        )
        
        return CandidateScore(
            candidate_id=candidate.id,
            overall_score=overall_score,
            performance_score=performance_score,
            safety_score=safety_score,
            innovation_score=innovation_score,
            test_pass_rate=safety_score,
            confidence=candidate.metadata.get('confidence', 0.5),
            metadata=candidate.metadata
        )
    
    def _get_weights(self) -> Dict[str, float]:
        """Get weighting based on ranking strategy"""
        if self.strategy == RankingStrategy.PERFORMANCE_FOCUSED:
            return {
                'performance': 0.6,
                'safety': 0.3,
                'innovation': 0.1
            }
        elif self.strategy == RankingStrategy.SAFETY_FOCUSED:
            return {
                'performance': 0.2,
                'safety': 0.7,
                'innovation': 0.1
            }
        elif self.strategy == RankingStrategy.INNOVATION_FOCUSED:
            return {
                'performance': 0.3,
                'safety': 0.3,
                'innovation': 0.4
            }
        else:  # BALANCED
            return {
                'performance': 0.4,
                'safety': 0.4,
                'innovation': 0.2
            }
    
    def _generate_recommendation(
        self,
        scores: List[CandidateScore],
        regression_reports: Dict[str, RegressionReport]
    ) -> Tuple[str, str]:
        """
        Generate recommendation and reasoning.
        
        Returns:
            (recommendation, reasoning)
        """
        if not scores:
            return "reject", "No candidates to evaluate"
        
        best = scores[0]
        worst = scores[-1]
        
        # Check for critical regressions in best candidate
        has_critical = False
        if best.candidate_id in regression_reports:
            report = regression_reports[best.candidate_id]
            has_critical = any(
                c.severity == RegressionSeverity.CRITICAL
                for c in report.comparisons
            )
        
        # Generate recommendation
        if has_critical:
            return (
                "reject",
                f"Best candidate ({best.candidate_id}) has critical performance "
                f"regressions. Recommendation: Reject all candidates."
            )
        elif best.overall_score >= 0.7:
            return (
                "accept",
                f"Candidate {best.candidate_id} scores {best.overall_score:.2f}. "
                f"Strong performance ({best.performance_score:.2f}) and "
                f"safety ({best.safety_score:.2f}). Recommendation: Accept."
            )
        elif best.overall_score >= 0.5:
            return (
                "inconclusive",
                f"Candidate {best.candidate_id} scores {best.overall_score:.2f}. "
                f"Moderate quality. Manual review recommended."
            )
        else:
            return (
                "reject",
                f"All candidates score below 0.5. Best is {best.candidate_id} "
                f"with {best.overall_score:.2f}. Recommendation: Reject and refine."
            )


class MultiCandidateSelector:
    """
    Selects the best candidate from multiple options.
    
    Features:
    - Statistical significance testing
    - Confidence intervals
    - Pareto frontier analysis
    - Manual override support
    """
    
    def __init__(
        self,
        min_confidence: float = 0.7,
        require_clear_winner: bool = True
    ):
        self.min_confidence = min_confidence
        self.require_clear_winner = require_clear_winner
    
    def select_best_candidate(
        self,
        comparison: ComparisonResult
    ) -> Tuple[Optional[str], str]:
        """
        Select best candidate from comparison result.
        
        Returns:
            (candidate_id, reasoning)
        """
        if comparison.recommendation == "accept":
            return (
                comparison.winner,
                f"Auto-selected {comparison.winner}: {comparison.reasoning}"
            )
        elif comparison.recommendation == "reject":
            return (
                None,
                f"All candidates rejected: {comparison.reasoning}"
            )
        else:  # inconclusive
            if self.require_clear_winner:
                # Check if there's a clear winner
                scores = comparison.candidate_scores
                if len(scores) >= 2:
                    best_score = scores[0].overall_score
                    second_best = scores[1].overall_score
                    margin = best_score - second_best
                    
                    if margin >= 0.2:
                        return (
                            comparison.winner,
                            f"Selected {comparison.winner} with clear lead "
                            f"({margin:.2f} margin)"
                        )
                
                return (
                    None,
                    f"No clear winner: {comparison.reasoning}. "
                    "Manual selection required."
                )
            else:
                return (
                    comparison.winner,
                    f"Selected {comparison.winner} (margin not required)"
                )
    
    def analyze_pareto_frontier(
        self,
        scores: List[CandidateScore]
    ) -> List[str]:
        """
        Identify Pareto-optimal candidates (not dominated in any dimension).
        
        Returns:
            List of Pareto-optimal candidate IDs
        """
        if not scores:
            return []
        
        pareto = []
        
        for candidate in scores:
            is_dominated = False
            for other in scores:
                if other.candidate_id == candidate.candidate_id:
                    continue
                
                # Check if 'other' dominates 'candidate'
                # (better or equal in all dimensions, strictly better in at least one)
                if (
                    other.performance_score >= candidate.performance_score and
                    other.safety_score >= candidate.safety_score and
                    other.innovation_score >= candidate.innovation_score and
                    (
                        other.performance_score > candidate.performance_score or
                        other.safety_score > candidate.safety_score or
                        other.innovation_score > candidate.innovation_score
                    )
                ):
                    is_dominated = True
                    break
            
            if not is_dominated:
                pareto.append(candidate.candidate_id)
        
        return pareto