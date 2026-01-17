"""
Unit tests for NIP data models.

Tests serialization/deserialization and validation of TaskSpec, Candidate,
Evidence, and PromotionRecord models.
"""
import pytest
import json
from datetime import datetime
from noodlecore.improve.models import (
    TaskSpec,
    Candidate,
    Evidence,
    PromotionRecord,
    TaskStatus,
    CandidateStatus,
    PromotionDecision
)


class TestTaskSpec:
    """Test TaskSpec model."""

    def test_task_spec_creation(self):
        """Test creating a basic task specification."""
        task = TaskSpec(
            id="task-1",
            title="Optimize Parser",
            goal={
                "type": "performance",
                "metric": "speed",
                "target_delta": "+20%",
                "description": "Improve parser performance"
            },
            scope={
                "repo_paths": ["noodle-lang/src"],
                "selectors": ["*.py"]
            },
            constraints={
                "max_loc_changed": 150,
                "no_new_deps": True,
                "no_public_api_break": True
            },
            verification={
                "commands": ["make test"],
                "required_green": True
            },
            risk="medium",
            mode="shadow"
        )

        assert task.id == "task-1"
        assert task.title == "Optimize Parser"
        assert task.goal["type"] == "performance"
        assert task.risk == "medium"
        assert task.mode == "shadow"

    def test_task_spec_to_dict(self):
        """Test converting task spec to dictionary."""
        task = TaskSpec(
            id="task-1",
            title="Test Task",
            goal={"type": "test", "description": "Test"},
            scope={"repo_paths": ["."]},
            constraints={"max_loc_changed": 100},
            verification={"commands": ["make test"], "required_green": True},
            risk="low",
            mode="shadow"
        )

        task_dict = task.to_dict()

        assert task_dict["id"] == "task-1"
        assert task_dict["title"] == "Test Task"
        assert task_dict["goal"]["type"] == "test"

    def test_task_spec_from_dict(self):
        """Test creating task spec from dictionary."""
        task_dict = {
            "id": "task-1",
            "title": "Test Task",
            "goal": {"type": "test", "description": "Test"},
            "scope": {"repo_paths": ["."]},
            "constraints": {"max_loc_changed": 100},
            "verification": {"commands": ["make test"], "required_green": True},
            "risk": "low",
            "mode": "shadow"
        }

        task = TaskSpec.from_dict(task_dict)

        assert task.id == "task-1"
        assert task.title == "Test Task"

    def test_task_spec_to_json(self):
        """Test JSON serialization of task spec."""
        task = TaskSpec(
            id="task-1",
            title="Test Task",
            goal={"type": "test", "description": "Test"},
            scope={"repo_paths": ["."]},
            constraints={"max_loc_changed": 100},
            verification={"commands": ["make test"], "required_green": True},
            risk="low",
            mode="shadow"
        )

        json_str = task.to_json()
        parsed = json.loads(json_str)

        assert parsed["id"] == "task-1"
        assert parsed["title"] == "Test Task"

    def test_task_spec_from_json(self):
        """Test JSON deserialization of task spec."""
        json_str = json.dumps({
            "id": "task-1",
            "title": "Test Task",
            "goal": {"type": "test", "description": "Test"},
            "scope": {"repo_paths": ["."]},
            "constraints": {"max_loc_changed": 100},
            "verification": {"commands": ["make test"], "required_green": True},
            "risk": "low",
            "mode": "shadow"
        })

        task = TaskSpec.from_json(json_str)

        assert task.id == "task-1"
        assert task.title == "Test Task"


class TestCandidate:
    """Test Candidate model."""

    def test_candidate_creation(self):
        """Test creating a candidate."""
        candidate = Candidate(
            id="candidate-1",
            task_id="task-1",
            base_snapshot_id="snapshot-1",
            patch="--- a/file.py\n+++ b/file.py\n@@ -1,1 +1,2 @@\n old\n+new",
            metadata={
                "agent": "test-agent",
                "rationale": "Test rationale"
            },
            status=CandidateStatus.CREATED
        )

        assert candidate.id == "candidate-1"
        assert candidate.task_id == "task-1"
        assert candidate.status == CandidateStatus.CREATED

    def test_candidate_serialization_roundtrip(self):
        """Test candidate serialization and deserialization."""
        candidate = Candidate(
            id="candidate-1",
            task_id="task-1",
            base_snapshot_id="snapshot-1",
            patch=None,
            metadata={"agent": "test"},
            status=CandidateStatus.CREATED
        )

        json_str = candidate.to_json()
        restored = Candidate.from_json(json_str)

        assert restored.id == candidate.id
        assert restored.task_id == candidate.task_id
        assert restored.status == candidate.status


class TestEvidence:
    """Test Evidence model."""

    def test_evidence_creation(self):
        """Test creating evidence."""
        evidence = Evidence(
            candidate_id="candidate-1",
            commands=[
                {
                    "command": "make test",
                    "exit_code": 0,
                    "stdout": "All tests passed",
                    "stderr": "",
                    "duration_ms": 1000
                }
            ],
            metrics={
                "loc_added": 10,
                "loc_removed": 5,
                "tests_passed": 42
            },
            hashes={
                "dataset": "abc123",
                "snapshot": "def456"
            },
            timestamp=datetime.now().isoformat()
        )

        assert evidence.candidate_id == "candidate-1"
        assert len(evidence.commands) == 1
        assert evidence.commands[0]["exit_code"] == 0

    def test_evidence_serialization(self):
        """Test evidence serialization."""
        evidence = Evidence(
            candidate_id="candidate-1",
            commands=[],
            metrics={},
            hashes={},
            timestamp=datetime.now().isoformat()
        )

        json_str = evidence.to_json()
        parsed = json.loads(json_str)

        assert parsed["candidate_id"] == "candidate-1"


class TestPromotionRecord:
    """Test PromotionRecord model."""

    def test_promotion_record_creation(self):
        """Test creating a promotion record."""
        record = PromotionRecord(
            candidate_id="candidate-1",
            decision=PromotionDecision.ACCEPTED,
            reason_codes=["tests_passed", "meets_criteria"],
            timestamp=datetime.now().isoformat()
        )

        assert record.candidate_id == "candidate-1"
        assert record.decision == PromotionDecision.ACCEPTED
        assert "tests_passed" in record.reason_codes

    def test_promotion_record_rejected(self):
        """Test promotion record with rejection."""
        record = PromotionRecord(
            candidate_id="candidate-1",
            decision=PromotionDecision.REJECTED,
            reason_codes=["tests_failed"],
            timestamp=datetime.now().isoformat()
        )

        assert record.decision == PromotionDecision.REJECTED
        assert "tests_failed" in record.reason_codes


class TestModelValidation:
    """Test model validation."""

    def test_task_spec_required_fields(self):
        """Test that required fields are validated."""
        with pytest.raises((TypeError, KeyError)):
            # Missing required fields
            TaskSpec(
                id="task-1",
                title="Test",
                # Missing goal, scope, etc.
            )

    def test_candidate_status_enum(self):
        """Test candidate status enum values."""
        assert CandidateStatus.CREATED.value == "CREATED"
        assert CandidateStatus.PATCH_APPLIED.value == "PATCH_APPLIED"
        assert CandidateStatus.VERIFIED.value == "VERIFIED"
        assert CandidateStatus.ACCEPTED.value == "ACCEPTED"
        assert CandidateStatus.REJECTED.value == "REJECTED"

    def test_promotion_decision_enum(self):
        """Test promotion decision enum values."""
        assert PromotionDecision.ACCEPTED.value == "accepted"
        assert PromotionDecision.REJECTED.value == "rejected"
