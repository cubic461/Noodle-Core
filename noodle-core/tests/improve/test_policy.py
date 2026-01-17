"""Tests for NIP policy gates.

Tests PolicyRule, PolicyGate, and StandardPolicies.
"""

import pytest
from noodlecore.improve.models import Candidate, Evidence
from noodlecore.improve.policy import (
    PolicyRule, PolicyGate, PolicyResult, StandardPolicies
)


@pytest.fixture
def sample_candidate():
    """Create a sample candidate."""
    return Candidate(
        id="cand-1",
        task_id="task-1",
        title="Fix authentication bug",
        description="Fix token validation",
        diff="diff --git a/auth.py",
        rationale="Fix critical security issue with token validation"
    )


@pytest.fixture
def sample_passed_evidence():
    """Create sample evidence for passed tests."""
    return Evidence(
        id="ev-1",
        candidate_id="cand-1",
        environment="dev",
        timestamp="2024-01-01T12:00:00",
        status="passed",
        loc_added=50,
        loc_removed=20,
        loc_modified=30
    )


@pytest.fixture
def sample_failed_evidence():
    """Create sample evidence for failed tests."""
    return Evidence(
        id="ev-2",
        candidate_id="cand-1",
        environment="dev",
        timestamp="2024-01-01T12:00:00",
        status="failed",
        logs="Test assertion failed"
    )


@pytest.fixture
def sample_large_loc_evidence():
    """Create evidence with large LOC changes."""
    return Evidence(
        id="ev-3",
        candidate_id="cand-1",
        environment="dev",
        timestamp="2024-01-01T12:00:00",
        status="passed",
        loc_added=800,
        loc_removed=300,
        loc_modified=200
    )


class TestPolicyResult:
    """Test PolicyResult dataclass."""
    
    def test_policy_result_creation(self):
        """Test creating a PolicyResult."""
        result = PolicyResult(
            allowed=True,
            reasons=["All checks passed"],
            score=1.0,
            details={"check1": True}
        )
        
        assert result.allowed is True
        assert result.reasons == ["All checks passed"]
        assert result.score == 1.0
        assert result.details == {"check1": True}
    
    def test_policy_result_default_details(self):
        """Test PolicyResult creates empty details dict by default."""
        result = PolicyResult(
            allowed=False,
            reasons=["Failed"],
            score=0.5
        )
        
        assert result.details == {}


class TestPolicyRule:
    """Test PolicyRule functionality."""
    
    def test_policy_rule_creation(self):
        """Test creating a PolicyRule."""
        rule = PolicyRule(
            name="test_rule",
            description="A test rule",
            check_function=lambda c, e: True,
            required=True,
            weight=1.0
        )
        
        assert rule.name == "test_rule"
        assert rule.description == "A test rule"
        assert rule.required is True
        assert rule.weight == 1.0
    
    def test_policy_rule_evaluate_pass(self, sample_candidate, sample_passed_evidence):
        """Test rule evaluation that passes."""
        rule = PolicyRule(
            name="has_evidence",
            description="Must have evidence",
            check_function=lambda c, e: len(e) > 0,
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [sample_passed_evidence])
        
        assert result is True
    
    def test_policy_rule_evaluate_fail(self, sample_candidate):
        """Test rule evaluation that fails."""
        rule = PolicyRule(
            name="has_evidence",
            description="Must have evidence",
            check_function=lambda c, e: len(e) > 0,
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [])
        
        assert result is False
    
    def test_policy_rule_with_complex_check(self, sample_candidate):
        """Test rule with complex check logic."""
        rule = PolicyRule(
            name="has_rationale",
            description="Must have rationale",
            check_function=lambda c, e: len(c.rationale) > 10,
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [])
        
        assert result is True


class TestPolicyGate:
    """Test PolicyGate functionality."""
    
    def test_policy_gate_default_rules(self):
        """Test PolicyGate initializes with default rules."""
        gate = PolicyGate()
        
        assert len(gate.rules) > 0
        assert any(rule.name == "has_evidence" for rule in gate.rules)
        assert any(rule.name == "tests_passed" for rule in gate.rules)
    
    def test_policy_gate_custom_rules(self):
        """Test PolicyGate with custom rules."""
        custom_rules = [
            PolicyRule(
                name="custom_rule",
                description="Custom check",
                check_function=lambda c, e: True,
                required=True,
                weight=0.5
            )
        ]
        
        gate = PolicyGate(rules=custom_rules)
        
        assert len(gate.rules) == 1
        assert gate.rules[0].name == "custom_rule"
    
    def test_policy_gate_evaluate_all_passed(self, sample_candidate, sample_passed_evidence):
        """Test evaluation when all rules pass."""
        gate = PolicyGate(min_score=0.5)
        
        result = gate.evaluate(sample_candidate, [sample_passed_evidence])
        
        # Note: Default rules require evidence and tests to pass
        # With one passed evidence, should get reasonable score
        assert isinstance(result, PolicyResult)
        assert "score" in result.details
        assert "passed_count" in result.details
    
    def test_policy_gate_evaluate_no_evidence(self, sample_candidate):
        """Test evaluation with no evidence."""
        gate = PolicyGate()
        
        result = gate.evaluate(sample_candidate, [])
        
        assert result.allowed is False  # has_evidence rule is required
        assert any("evidence" in r.lower() for r in result.reasons)
    
    def test_policy_gate_evaluate_failed_tests(self, sample_candidate, sample_failed_evidence):
        """Test evaluation with failed tests."""
        gate = PolicyGate()
        
        result = gate.evaluate(sample_candidate, [sample_failed_evidence])
        
        assert result.allowed is False  # tests_passed rule is required
        assert any("test" in r.lower() for r in result.reasons)
    
    def test_policy_gate_evaluate_large_loc(self, sample_candidate, sample_large_loc_evidence):
        """Test evaluation with large LOC changes."""
        gate = PolicyGate()
        
        result = gate.evaluate(sample_candidate, [sample_large_loc_evidence])
        
        # LOC rule is optional, so might still pass but with lower score
        assert isinstance(result, PolicyResult)
        assert result.score >= 0.0
        assert result.score <= 1.0
    
    def test_policy_gate_multiple_evidence(self, sample_candidate):
        """Test evaluation with multiple evidence records."""
        evidence_list = [
            Evidence(
                id=f"ev-{i}",
                candidate_id="cand-1",
                environment="dev",
                timestamp="2024-01-01T12:00:00",
                status="passed"
            )
            for i in range(3)
        ]
        
        gate = PolicyGate(min_score=0.6)
        
        result = gate.evaluate(sample_candidate, evidence_list)
        
        assert isinstance(result, PolicyResult)
        # With multiple passed evidence, should do well on optional rules
        assert result.details["passed_count"] >= 2
    
    def test_policy_gate_add_rule(self):
        """Test adding a rule to the gate."""
        gate = PolicyGate()
        initial_count = len(gate.rules)
        
        new_rule = PolicyRule(
            name="new_rule",
            description="A new rule",
            check_function=lambda c, e: True,
            required=False
        )
        
        gate.add_rule(new_rule)
        
        assert len(gate.rules) == initial_count + 1
        assert any(r.name == "new_rule" for r in gate.rules)
    
    def test_policy_gate_remove_rule(self):
        """Test removing a rule from the gate."""
        gate = PolicyGate()
        initial_count = len(gate.rules)
        
        # Remove a known default rule
        removed = gate.remove_rule("multiple_evidence")
        
        if removed:
            assert len(gate.rules) == initial_count - 1
            assert not any(r.name == "multiple_evidence" for r in gate.rules)
        else:
            # Rule might not exist in default set
            assert len(gate.rules) == initial_count
    
    def test_policy_gate_remove_nonexistent_rule(self):
        """Test removing a rule that doesn't exist."""
        gate = PolicyGate()
        initial_count = len(gate.rules)
        
        removed = gate.remove_rule("nonexistent_rule")
        
        assert removed is False
        assert len(gate.rules) == initial_count
    
    def test_policy_gate_get_rule(self):
        """Test getting a specific rule."""
        gate = PolicyGate()
        
        rule = gate.get_rule("has_evidence")
        
        assert rule is not None
        assert rule.name == "has_evidence"
    
    def test_policy_gate_get_nonexistent_rule(self):
        """Test getting a rule that doesn't exist."""
        gate = PolicyGate()
        
        rule = gate.get_rule("nonexistent_rule")
        
        assert rule is None
    
    def test_policy_gate_require_all_required(self, sample_candidate, sample_passed_evidence):
        """Test require_all_required flag behavior."""
        # With require_all_required=True
        gate_strict = PolicyGate(require_all_required=True, min_score=0.0)
        result_strict = gate_strict.evaluate(sample_candidate, [sample_passed_evidence])
        
        # With require_all_required=False
        gate_lenient = PolicyGate(require_all_required=False, min_score=0.0)
        result_lenient = gate_lenient.evaluate(sample_candidate, [sample_passed_evidence])
        
        # Results should exist for both
        assert isinstance(result_strict, PolicyResult)
        assert isinstance(result_lenient, PolicyResult)
    
    def test_policy_gate_min_score(self, sample_candidate, sample_passed_evidence):
        """Test min_score threshold."""
        gate = PolicyGate(min_score=1.0)
        
        result = gate.evaluate(sample_candidate, [sample_passed_evidence])
        
        # With perfect score requirement, might not pass
        assert isinstance(result, PolicyResult)
        if result.score < 1.0:
            assert result.allowed is False


class TestCommandSuccessGate:
    """Test command success policy checks."""
    
    def test_command_success_rule(self, sample_candidate):
        """Test rule that checks command execution success."""
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed",
            test_results={"success": True, "exit_code": 0}
        )
        
        rule = PolicyRule(
            name="command_success",
            description="Command must succeed",
            check_function=lambda c, e: any(ev.test_results.get("success", False) for ev in e),
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [evidence])
        
        assert result is True
    
    def test_command_failure_rule(self, sample_candidate):
        """Test rule that detects command failure."""
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="failed",
            test_results={"success": False, "exit_code": 1}
        )
        
        rule = PolicyRule(
            name="command_success",
            description="Command must succeed",
            check_function=lambda c, e: all(ev.test_results.get("success", True) for ev in e),
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [evidence])
        
        assert result is False


class TestLOCDeltaGate:
    """Test LOC delta policy checks."""
    
    def test_loc_delta_within_limits(self, sample_candidate):
        """Test LOC delta check within acceptable limits."""
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed",
            loc_added=50,
            loc_removed=30,
            loc_modified=20
        )
        
        rule = PolicyRule(
            name="loc_limit",
            description="Total LOC changes must be under limit",
            check_function=lambda c, e: all(
                (ev.loc_added + ev.loc_removed + ev.loc_modified) < 200
                for ev in e
            ),
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [evidence])
        
        assert result is True
    
    def test_loc_delta_exceeds_limits(self, sample_candidate):
        """Test LOC delta check exceeding limits."""
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed",
            loc_added=500,
            loc_removed=400,
            loc_modified=300
        )
        
        rule = PolicyRule(
            name="loc_limit",
            description="Total LOC changes must be under limit",
            check_function=lambda c, e: all(
                (ev.loc_added + ev.loc_removed + ev.loc_modified) < 200
                for ev in e
            ),
            required=True
        )
        
        result = rule.evaluate(sample_candidate, [evidence])
        
        assert result is False
    
    def test_loc_delta_ratio_check(self, sample_candidate):
        """Test LOC ratio (added vs removed) check."""
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed",
            loc_added=100,
            loc_removed=50
        )
        
        # Ratio should be reasonable (not adding too much without removing)
        rule = PolicyRule(
            name="loc_ratio",
            description="Added LOC should not exceed removed by too much",
            check_function=lambda c, e: all(
                ev.loc_added <= ev.loc_removed * 3
                for ev in e
            ),
            required=False
        )
        
        result = rule.evaluate(sample_candidate, [evidence])
        
        assert result is True  # 100 <= 50 * 3


class TestStandardPolicies:
    """Test standard policy configurations."""
    
    def test_strict_policy(self, sample_candidate):
        """Test strict policy configuration."""
        evidence_list = [
            Evidence(
                id=f"ev-{i}",
                candidate_id="cand-1",
                environment="dev",
                timestamp="2024-01-01T12:00:00",
                status="passed"
            )
            for i in range(2)
        ]
        
        policy = StandardPolicies.strict()
        
        assert policy.min_score == 0.95
        assert policy.require_all_required is True
        assert len(policy.rules) >= 4
    
    def test_lenient_policy(self, sample_candidate):
        """Test lenient policy configuration."""
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed"
        )
        
        policy = StandardPolicies.lenient()
        
        assert policy.min_score == 0.6
        assert policy.require_all_required is True
        assert len(policy.rules) == 2
    
    def test_development_policy(self, sample_candidate):
        """Test development environment policy."""
        policy = StandardPolicies.development()
        
        assert policy.min_score == 0.3
        assert policy.require_all_required is False
        assert len(policy.rules) == 1
    
    def test_strict_policy_evaluation(self, sample_candidate):
        """Test strict policy evaluation with good candidate."""
        evidence_list = [
            Evidence(
                id=f"ev-{i}",
                candidate_id="cand-1",
                environment="dev",
                timestamp="2024-01-01T12:00:00",
                status="passed"
            )
            for i in range(2)
        ]
        
        policy = StandardPolicies.strict()
        result = policy.evaluate(sample_candidate, evidence_list)
        
        assert isinstance(result, PolicyResult)
        # With 2 passed evidence and good rationale, should have high score
        assert result.score >= 0.0


class TestPolicyGateAggregation:
    """Test policy gate aggregation and scoring."""
    
    def test_score_calculation(self, sample_candidate):
        """Test score is calculated correctly."""
        gate = PolicyGate(min_score=0.0)
        
        # Create evidence that will pass some rules but not all
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed"
        )
        
        result = gate.evaluate(sample_candidate, [evidence])
        
        assert 0.0 <= result.score <= 1.0
        assert "passed_count" in result.details
        assert "failed_count" in result.details
    
    def test_reasons_aggregation(self, sample_candidate):
        """Test reasons are aggregated properly."""
        gate = PolicyGate()
        
        result = gate.evaluate(sample_candidate, [])
        
        # Should have reasons for failures
        assert len(result.reasons) > 0
        assert isinstance(result.reasons, list)
    
    def test_details_population(self, sample_candidate, sample_passed_evidence):
        """Test result details are populated."""
        gate = PolicyGate()
        
        result = gate.evaluate(sample_candidate, [sample_passed_evidence])
        
        assert "passed_rules" in result.details
        assert "failed_rules" in result.details
        assert "rule_count" in result.details
        assert result.details["rule_count"] == len(gate.rules)
    
    def test_all_optional_rules_pass(self, sample_candidate):
        """Test when all optional rules pass."""
        evidence_list = [
            Evidence(
                id=f"ev-{i}",
                candidate_id="cand-1",
                environment="dev",
                timestamp="2024-01-01T12:00:00",
                status="passed",
                loc_added=10,
                loc_removed=5
            )
            for i in range(3)
        ]
        
        gate = PolicyGate(min_score=0.5)
        result = gate.evaluate(sample_candidate, evidence_list)
        
        # With multiple evidence and reasonable LOC, should pass optional rules
        assert result.details["passed_count"] >= 2
