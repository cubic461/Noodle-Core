"""Policy gates for candidate verification.

This module provides policy validation logic to ensure candidates meet
quality and safety standards before promotion.
"""

from dataclasses import dataclass
from typing import List, Optional, Callable, Dict, Any
from .models import Candidate, Evidence


@dataclass
class PolicyResult:
    """Result of a policy evaluation.
    
    Attributes:
        allowed: Whether the policy passed
        reasons: List of reasons for the decision
        score: Confidence score (0.0 to 1.0)
        details: Additional details about the evaluation
    """
    allowed: bool
    reasons: List[str]
    score: float
    details: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.details is None:
            self.details = {}


class PolicyRule:
    """A single policy rule for evaluation.
    
    Each rule evaluates a specific aspect of a candidate or evidence.
    
    Attributes:
        name: Name of the rule
        description: Description of what the rule checks
        check_function: Function that performs the check
        required: Whether this rule is required (must pass)
        weight: Weight for scoring (0.0 to 1.0)
    """
    
    def __init__(
        self,
        name: str,
        description: str,
        check_function: Callable[[Candidate, List[Evidence]], bool],
        required: bool = True,
        weight: float = 1.0
    ):
        """Initialize a policy rule.
        
        Args:
            name: Name of the rule
            description: Description of the rule
            check_function: Function that evaluates the rule
            required: Whether this rule must pass
            weight: Weight for scoring
        """
        self.name = name
        self.description = description
        self.check_function = check_function
        self.required = required
        self.weight = weight
    
    def evaluate(self, candidate: Candidate, evidence_list: List[Evidence]) -> bool:
        """Evaluate this rule against a candidate.
        
        Args:
            candidate: Candidate to evaluate
            evidence_list: List of evidence records
            
        Returns:
            True if the rule passed
        """
        return self.check_function(candidate, evidence_list)


class PolicyGate:
    """Gate for evaluating candidates against policy rules.
    
    A PolicyGate contains multiple rules and evaluates candidates
    against all of them to determine if they can proceed.
    
    Attributes:
        rules: List of policy rules to enforce
        require_all_required: Whether all required rules must pass
        min_score: Minimum score to pass (0.0 to 1.0)
    """
    
    def __init__(
        self,
        rules: Optional[List[PolicyRule]] = None,
        require_all_required: bool = True,
        min_score: float = 0.8
    ):
        """Initialize the policy gate.
        
        Args:
            rules: List of policy rules (uses defaults if None)
            require_all_required: Whether all required rules must pass
            min_score: Minimum score to pass
        """
        self.rules = rules or self._get_default_rules()
        self.require_all_required = require_all_required
        self.min_score = min_score
    
    def _get_default_rules(self) -> List[PolicyRule]:
        """Get default policy rules.
        
        Returns:
            List of default policy rules
        """
        return [
            PolicyRule(
                name="has_evidence",
                description="Candidate must have at least one evidence record",
                check_function=lambda c, e: len(e) > 0,
                required=True
            ),
            PolicyRule(
                name="tests_passed",
                description="All tests must pass",
                check_function=lambda c, e: all(ev.status == "passed" for ev in e),
                required=True
            ),
            PolicyRule(
                name="no_excessive_changes",
                description="Candidate should not change excessive LOC",
                check_function=lambda c, e: self._check_loc_limit(e),
                required=False,
                weight=0.7
            ),
            PolicyRule(
                name="has_rationale",
                description="Candidate must have a rationale",
                check_function=lambda c, e: bool(c.rationale and len(c.rationale) > 0),
                required=True
            ),
            PolicyRule(
                name="multiple_evidence",
                description="Should have multiple evidence records for confidence",
                check_function=lambda c, e: len(e) >= 2,
                required=False
            )
        ]
    
    def _check_loc_limit(self, evidence_list: List[Evidence], max_loc: int = 1000) -> bool:
        """Check that LOC changes are within limits.
        
        Args:
            evidence_list: List of evidence records
            max_loc: Maximum total LOC changes allowed
            
        Returns:
            True if within limits
        """
        for evidence in evidence_list:
            total_loc = evidence.loc_added + evidence.loc_removed + evidence.loc_modified
            if total_loc > max_loc:
                return False
        return True
    
    def evaluate(self, candidate: Candidate, evidence_list: List[Evidence]) -> PolicyResult:
        """Evaluate a candidate against all policy rules.
        
        Args:
            candidate: Candidate to evaluate
            evidence_list: List of evidence records
            
        Returns:
            Policy evaluation result
        """
        passed_rules = []
        failed_rules = []
        scores = []
        reasons = []
        
        for rule in self.rules:
            try:
                passed = rule.evaluate(candidate, evidence_list)
                if passed:
                    passed_rules.append(rule.name)
                    scores.append(rule.weight)
                else:
                    failed_rules.append(rule.name)
                    reasons.append(f"{rule.name}: {rule.description}")
                    if rule.required:
                        scores.append(0.0)
                    else:
                        scores.append(rule.weight * 0.5)  # Partial credit for optional rules
            except Exception as e:
                failed_rules.append(rule.name)
                reasons.append(f"{rule.name}: Evaluation error - {str(e)}")
                scores.append(0.0)
        
        # Calculate overall score
        total_weight = sum(rule.weight for rule in self.rules)
        total_score = sum(scores) / total_weight if total_weight > 0 else 0.0
        
        # Determine if allowed
        if self.require_all_required:
            required_passed = all(
                rule.name in passed_rules or not rule.required
                for rule in self.rules
            )
            allowed = required_passed and total_score >= self.min_score
        else:
            allowed = total_score >= self.min_score
        
        if not failed_rules:
            reasons.append("All policy checks passed")
        
        return PolicyResult(
            allowed=allowed,
            reasons=reasons,
            score=total_score,
            details={
                "passed_rules": passed_rules,
                "failed_rules": failed_rules,
                "rule_count": len(self.rules),
                "passed_count": len(passed_rules),
                "failed_count": len(failed_rules)
            }
        )
    
    def add_rule(self, rule: PolicyRule) -> None:
        """Add a new policy rule.
        
        Args:
            rule: Policy rule to add
        """
        self.rules.append(rule)
    
    def remove_rule(self, rule_name: str) -> bool:
        """Remove a policy rule by name.
        
        Args:
            rule_name: Name of the rule to remove
            
        Returns:
            True if removed, False if not found
        """
        for i, rule in enumerate(self.rules):
            if rule.name == rule_name:
                self.rules.pop(i)
                return True
        return False
    
    def get_rule(self, rule_name: str) -> Optional[PolicyRule]:
        """Get a policy rule by name.
        
        Args:
            rule_name: Name of the rule
            
        Returns:
            The rule if found, None otherwise
        """
        for rule in self.rules:
            if rule.name == rule_name:
                return rule
        return None


class StandardPolicies:
    """Standard policy configurations for common use cases."""
    
    @staticmethod
    def strict() -> PolicyGate:
        """Create a strict policy gate.
        
        Returns:
            Policy gate with strict rules
        """
        rules = [
            PolicyRule(
                name="has_evidence",
                description="Candidate must have at least one evidence record",
                check_function=lambda c, e: len(e) > 0,
                required=True
            ),
            PolicyRule(
                name="tests_passed",
                description="All tests must pass",
                check_function=lambda c, e: all(ev.status == "passed" for ev in e),
                required=True
            ),
            PolicyRule(
                name="has_rationale",
                description="Candidate must have a rationale",
                check_function=lambda c, e: bool(c.rationale and len(c.rationale) > 10),
                required=True
            ),
            PolicyRule(
                name="multiple_evidence",
                description="Must have multiple evidence records",
                check_function=lambda c, e: len(e) >= 2,
                required=True
            ),
            PolicyRule(
                name="recent_evidence",
                description="Must have recent evidence (within 24 hours)",
                check_function=lambda c, e: any(
                    ev.status == "passed" for ev in e
                ),
                required=True
            )
        ]
        return PolicyGate(rules, require_all_required=True, min_score=0.95)
    
    @staticmethod
    def lenient() -> PolicyGate:
        """Create a lenient policy gate.
        
        Returns:
            Policy gate with lenient rules
        """
        rules = [
            PolicyRule(
                name="has_evidence",
                description="Candidate must have at least one evidence record",
                check_function=lambda c, e: len(e) > 0,
                required=True
            ),
            PolicyRule(
                name="tests_passed",
                description="All tests must pass",
                check_function=lambda c, e: all(ev.status == "passed" for ev in e),
                required=True
            )
        ]
        return PolicyGate(rules, require_all_required=True, min_score=0.6)
    
    @staticmethod
    def development() -> PolicyGate:
        """Create a development environment policy gate.
        
        Returns:
            Policy gate for development environment
        """
        rules = [
            PolicyRule(
                name="has_rationale",
                description="Candidate should have a rationale",
                check_function=lambda c, e: bool(c.rationale),
                required=False
            )
        ]
        return PolicyGate(rules, require_all_required=False, min_score=0.3)
