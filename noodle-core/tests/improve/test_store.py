"""Tests for NIP file-based storage.

Tests TaskStore, CandidateStore, EvidenceStore, and PromotionStore.
"""

import pytest
import tempfile
import shutil
from pathlib import Path
from noodlecore.improve.models import (
    TaskSpec, Candidate, Evidence, PromotionRecord,
    TaskStatus, CandidateStatus, Environment
)
from noodlecore.improve.store import (
    FileStore, TaskStore, CandidateStore, EvidenceStore, PromotionStore
)


@pytest.fixture
def temp_storage():
    """Create a temporary storage directory for testing."""
    temp_dir = tempfile.mkdtemp(prefix="nip_test_store_")
    yield temp_dir
    # Cleanup
    shutil.rmtree(temp_dir, ignore_errors=True)


@pytest.fixture
def task_store(temp_storage):
    """Create a TaskStore with temporary storage."""
    return TaskStore(base_path=temp_storage)


@pytest.fixture
def candidate_store(temp_storage):
    """Create a CandidateStore with temporary storage."""
    return CandidateStore(base_path=temp_storage)


@pytest.fixture
def evidence_store(temp_storage):
    """Create an EvidenceStore with temporary storage."""
    return EvidenceStore(base_path=temp_storage)


@pytest.fixture
def promotion_store(temp_storage):
    """Create a PromotionStore with temporary storage."""
    return PromotionStore(base_path=temp_storage)


@pytest.fixture
def sample_task():
    """Create a sample TaskSpec."""
    return TaskSpec(
        id="task-1",
        title="Fix bug in auth module",
        description="Users cannot log in with valid credentials",
        objective="Restore login functionality",
        constraints=["Must not break existing sessions"],
        acceptance_criteria=["Users can log in successfully"],
        priority=8
    )


@pytest.fixture
def sample_candidate():
    """Create a sample Candidate."""
    return Candidate(
        id="cand-1",
        task_id="task-1",
        title="Fix token validation",
        description="Update JWT validation logic",
        diff="diff --git a/auth.py",
        rationale="Previous validation was too strict"
    )


@pytest.fixture
def sample_evidence():
    """Create a sample Evidence."""
    return Evidence(
        id="ev-1",
        candidate_id="cand-1",
        environment="dev",
        timestamp="2024-01-01T12:00:00",
        status="passed",
        metrics={"execution_time": 1.2},
        logs="All tests passed",
        loc_added=10,
        loc_removed=5
    )


@pytest.fixture
def sample_promotion():
    """Create a sample PromotionRecord."""
    return PromotionRecord(
        id="promo-1",
        candidate_id="cand-1",
        from_environment="dev",
        to_environment="staging",
        timestamp="2024-01-02T12:00:00",
        promoted_by="user-1",
        status="succeeded",
        evidence_id="ev-1"
    )


class TestFileStore:
    """Test base FileStore functionality."""
    
    def test_filestore_initialization(self, temp_storage):
        """Test FileStore creates necessary directories."""
        store = FileStore(base_path=temp_storage)
        
        assert store.tasks_dir.exists()
        assert store.candidates_dir.exists()
        assert store.evidence_dir.exists()
        assert store.promotions_dir.exists()
    
    def test_filestore_save_and_load(self, temp_storage, sample_task):
        """Test saving and loading an entity."""
        store = FileStore(base_path=temp_storage)
        
        # Save
        store.save(sample_task, 'task')
        
        # Load
        loaded = store.load(sample_task.id, 'task')
        
        assert loaded is not None
        assert loaded.id == sample_task.id
        assert loaded.title == sample_task.title
    
    def test_filestore_load_nonexistent(self, temp_storage):
        """Test loading a non-existent entity returns None."""
        store = FileStore(base_path=temp_storage)
        
        loaded = store.load("nonexistent", 'task')
        
        assert loaded is None
    
    def test_filestore_delete(self, temp_storage, sample_task):
        """Test deleting an entity."""
        store = FileStore(base_path=temp_storage)
        
        # Save then delete
        store.save(sample_task, 'task')
        deleted = store.delete(sample_task.id, 'task')
        
        assert deleted is True
        
        # Verify it's gone
        loaded = store.load(sample_task.id, 'task')
        assert loaded is None
    
    def test_filestore_delete_nonexistent(self, temp_storage):
        """Test deleting a non-existent entity returns False."""
        store = FileStore(base_path=temp_storage)
        
        deleted = store.delete("nonexistent", 'task')
        
        assert deleted is False
    
    def test_filestore_exists(self, temp_storage, sample_task):
        """Test checking if an entity exists."""
        store = FileStore(base_path=temp_storage)
        
        assert store.exists(sample_task.id, 'task') is False
        
        store.save(sample_task, 'task')
        
        assert store.exists(sample_task.id, 'task') is True
    
    def test_filestore_list_all(self, temp_storage):
        """Test listing all entity IDs."""
        store = FileStore(base_path=temp_storage)
        
        # Initially empty
        ids = store.list_all('task')
        assert ids == []
        
        # Add multiple
        for i in range(3):
            task = TaskSpec(
                id=f"task-{i}",
                title=f"Task {i}",
                description="Test",
                objective="Test"
            )
            store.save(task, 'task')
        
        # List
        ids = store.list_all('task')
        assert len(ids) == 3
        assert "task-0" in ids
        assert "task-1" in ids
        assert "task-2" in ids
    
    def test_filestore_load_all(self, temp_storage):
        """Test loading all entities of a type."""
        store = FileStore(base_path=temp_storage)
        
        # Add multiple
        for i in range(3):
            task = TaskSpec(
                id=f"task-{i}",
                title=f"Task {i}",
                description="Test",
                objective="Test"
            )
            store.save(task, 'task')
        
        # Load all
        tasks = store.load_all('task')
        assert len(tasks) == 3
        assert all(isinstance(t, TaskSpec) for t in tasks)


class TestTaskStore:
    """Test TaskStore functionality."""
    
    def test_task_store_save_and_load(self, task_store, sample_task):
        """Test saving and loading a task."""
        task_store.save_task(sample_task)
        
        loaded = task_store.load_task(sample_task.id)
        
        assert loaded is not None
        assert loaded.id == sample_task.id
        assert loaded.title == sample_task.title
        assert loaded.priority == sample_task.priority
    
    def test_task_store_delete(self, task_store, sample_task):
        """Test deleting a task."""
        task_store.save_task(sample_task)
        
        deleted = task_store.delete_task(sample_task.id)
        
        assert deleted is True
        assert task_store.load_task(sample_task.id) is None
    
    def test_task_store_exists(self, task_store, sample_task):
        """Test checking if a task exists."""
        assert task_store.task_exists(sample_task.id) is False
        
        task_store.save_task(sample_task)
        
        assert task_store.task_exists(sample_task.id) is True
    
    def test_task_store_list_all(self, task_store):
        """Test listing all tasks."""
        # Initially empty
        tasks = task_store.list_tasks()
        assert len(tasks) == 0
        
        # Add multiple
        for i in range(3):
            task = TaskSpec(
                id=f"task-{i}",
                title=f"Task {i}",
                description="Test",
                objective="Test"
            )
            task_store.save_task(task)
        
        # List
        tasks = task_store.list_tasks()
        assert len(tasks) == 3
        assert all(isinstance(t, TaskSpec) for t in tasks)


class TestCandidateStore:
    """Test CandidateStore functionality."""
    
    def test_candidate_store_save_and_load(self, candidate_store, sample_candidate):
        """Test saving and loading a candidate."""
        candidate_store.save_candidate(sample_candidate)
        
        loaded = candidate_store.load_candidate(sample_candidate.id)
        
        assert loaded is not None
        assert loaded.id == sample_candidate.id
        assert loaded.task_id == sample_candidate.task_id
        assert loaded.diff == sample_candidate.diff
    
    def test_candidate_store_delete(self, candidate_store, sample_candidate):
        """Test deleting a candidate."""
        candidate_store.save_candidate(sample_candidate)
        
        deleted = candidate_store.delete_candidate(sample_candidate.id)
        
        assert deleted is True
        assert candidate_store.load_candidate(sample_candidate.id) is None
    
    def test_candidate_store_exists(self, candidate_store, sample_candidate):
        """Test checking if a candidate exists."""
        assert candidate_store.candidate_exists(sample_candidate.id) is False
        
        candidate_store.save_candidate(sample_candidate)
        
        assert candidate_store.candidate_exists(sample_candidate.id) is True
    
    def test_candidate_store_list_all(self, candidate_store):
        """Test listing all candidates."""
        # Initially empty
        candidates = candidate_store.list_candidates()
        assert len(candidates) == 0
        
        # Add multiple
        for i in range(3):
            candidate = Candidate(
                id=f"cand-{i}",
                task_id="task-1",
                title=f"Candidate {i}",
                description="Test",
                diff="diff",
                rationale="Test"
            )
            candidate_store.save_candidate(candidate)
        
        # List
        candidates = candidate_store.list_candidates()
        assert len(candidates) == 3
    
    def test_candidate_store_list_for_task(self, candidate_store):
        """Test listing candidates for a specific task."""
        # Add candidates for different tasks
        for i in range(2):
            candidate = Candidate(
                id=f"cand-task1-{i}",
                task_id="task-1",
                title=f"Candidate {i}",
                description="Test",
                diff="diff",
                rationale="Test"
            )
            candidate_store.save_candidate(candidate)
        
        for i in range(3):
            candidate = Candidate(
                id=f"cand-task2-{i}",
                task_id="task-2",
                title=f"Candidate {i}",
                description="Test",
                diff="diff",
                rationale="Test"
            )
            candidate_store.save_candidate(candidate)
        
        # List for task-1
        task1_candidates = candidate_store.list_candidates_for_task("task-1")
        assert len(task1_candidates) == 2
        assert all(c.task_id == "task-1" for c in task1_candidates)
        
        # List for task-2
        task2_candidates = candidate_store.list_candidates_for_task("task-2")
        assert len(task2_candidates) == 3
        assert all(c.task_id == "task-2" for c in task2_candidates)


class TestEvidenceStore:
    """Test EvidenceStore functionality."""
    
    def test_evidence_store_save_and_load(self, evidence_store, sample_evidence):
        """Test saving and loading evidence."""
        evidence_store.save_evidence(sample_evidence)
        
        loaded = evidence_store.load_evidence(sample_evidence.id)
        
        assert loaded is not None
        assert loaded.id == sample_evidence.id
        assert loaded.candidate_id == sample_evidence.candidate_id
        assert loaded.status == sample_evidence.status
    
    def test_evidence_store_delete(self, evidence_store, sample_evidence):
        """Test deleting evidence."""
        evidence_store.save_evidence(sample_evidence)
        
        deleted = evidence_store.delete_evidence(sample_evidence.id)
        
        assert deleted is True
        assert evidence_store.load_evidence(sample_evidence.id) is None
    
    def test_evidence_store_exists(self, evidence_store, sample_evidence):
        """Test checking if evidence exists."""
        assert evidence_store.evidence_exists(sample_evidence.id) is False
        
        evidence_store.save_evidence(sample_evidence)
        
        assert evidence_store.evidence_exists(sample_evidence.id) is True
    
    def test_evidence_store_list_all(self, evidence_store):
        """Test listing all evidence."""
        # Initially empty
        evidence_list = evidence_store.list_evidence()
        assert len(evidence_list) == 0
        
        # Add multiple
        for i in range(3):
            evidence = Evidence(
                id=f"ev-{i}",
                candidate_id="cand-1",
                environment="dev",
                timestamp="2024-01-01T12:00:00",
                status="passed"
            )
            evidence_store.save_evidence(evidence)
        
        # List
        evidence_list = evidence_store.list_evidence()
        assert len(evidence_list) == 3
    
    def test_evidence_store_list_for_candidate(self, evidence_store):
        """Test listing evidence for a specific candidate."""
        # Add evidence for different candidates
        for i in range(2):
            evidence = Evidence(
                id=f"ev-cand1-{i}",
                candidate_id="cand-1",
                environment="dev",
                timestamp="2024-01-01T12:00:00",
                status="passed"
            )
            evidence_store.save_evidence(evidence)
        
        for i in range(3):
            evidence = Evidence(
                id=f"ev-cand2-{i}",
                candidate_id="cand-2",
                environment="staging",
                timestamp="2024-01-02T12:00:00",
                status="failed"
            )
            evidence_store.save_evidence(evidence)
        
        # List for cand-1
        cand1_evidence = evidence_store.list_evidence_for_candidate("cand-1")
        assert len(cand1_evidence) == 2
        assert all(e.candidate_id == "cand-1" for e in cand1_evidence)
        
        # List for cand-2
        cand2_evidence = evidence_store.list_evidence_for_candidate("cand-2")
        assert len(cand2_evidence) == 3
        assert all(e.candidate_id == "cand-2" for e in cand2_evidence)


class TestPromotionStore:
    """Test PromotionStore functionality."""
    
    def test_promotion_store_save_and_load(self, promotion_store, sample_promotion):
        """Test saving and loading a promotion record."""
        promotion_store.save_promotion(sample_promotion)
        
        loaded = promotion_store.load_promotion(sample_promotion.id)
        
        assert loaded is not None
        assert loaded.id == sample_promotion.id
        assert loaded.candidate_id == sample_promotion.candidate_id
        assert loaded.from_environment == sample_promotion.from_environment
    
    def test_promotion_store_delete(self, promotion_store, sample_promotion):
        """Test deleting a promotion record."""
        promotion_store.save_promotion(sample_promotion)
        
        deleted = promotion_store.delete_promotion(sample_promotion.id)
        
        assert deleted is True
        assert promotion_store.load_promotion(sample_promotion.id) is None
    
    def test_promotion_store_exists(self, promotion_store, sample_promotion):
        """Test checking if a promotion record exists."""
        assert promotion_store.promotion_exists(sample_promotion.id) is False
        
        promotion_store.save_promotion(sample_promotion)
        
        assert promotion_store.promotion_exists(sample_promotion.id) is True
    
    def test_promotion_store_list_all(self, promotion_store):
        """Test listing all promotion records."""
        # Initially empty
        promotions = promotion_store.list_promotions()
        assert len(promotions) == 0
        
        # Add multiple
        for i in range(3):
            promotion = PromotionRecord(
                id=f"promo-{i}",
                candidate_id="cand-1",
                from_environment="dev",
                to_environment="staging",
                timestamp="2024-01-01T12:00:00",
                promoted_by="user-1",
                status="succeeded"
            )
            promotion_store.save_promotion(promotion)
        
        # List
        promotions = promotion_store.list_promotions()
        assert len(promotions) == 3
    
    def test_promotion_store_list_for_candidate(self, promotion_store):
        """Test listing promotions for a specific candidate."""
        # Add promotions for different candidates
        for i in range(2):
            promotion = PromotionRecord(
                id=f"promo-cand1-{i}",
                candidate_id="cand-1",
                from_environment="dev",
                to_environment="staging",
                timestamp="2024-01-01T12:00:00",
                promoted_by="user-1",
                status="succeeded"
            )
            promotion_store.save_promotion(promotion)
        
        for i in range(3):
            promotion = PromotionRecord(
                id=f"promo-cand2-{i}",
                candidate_id="cand-2",
                from_environment="staging",
                to_environment="production",
                timestamp="2024-01-02T12:00:00",
                promoted_by="user-2",
                status="succeeded"
            )
            promotion_store.save_promotion(promotion)
        
        # List for cand-1
        cand1_promos = promotion_store.list_promotions_for_candidate("cand-1")
        assert len(cand1_promos) == 2
        assert all(p.candidate_id == "cand-1" for p in cand1_promos)
        
        # List for cand-2
        cand2_promos = promotion_store.list_promotions_for_candidate("cand-2")
        assert len(cand2_promos) == 3
        assert all(p.candidate_id == "cand-2" for p in cand2_promos)


class TestStoreIntegration:
    """Integration tests for stores working together."""
    
    def test_task_candidate_evidence_relationship(self, temp_storage):
        """Test the relationship between tasks, candidates, and evidence."""
        task_store = TaskStore(base_path=temp_storage)
        candidate_store = CandidateStore(base_path=temp_storage)
        evidence_store = EvidenceStore(base_path=temp_storage)
        
        # Create task
        task = TaskSpec(
            id="task-1",
            title="Test task",
            description="Test",
            objective="Test"
        )
        task_store.save_task(task)
        
        # Create candidate for task
        candidate = Candidate(
            id="cand-1",
            task_id="task-1",
            title="Test candidate",
            description="Test",
            diff="diff",
            rationale="Test"
        )
        candidate_store.save_candidate(candidate)
        
        # Create evidence for candidate
        evidence = Evidence(
            id="ev-1",
            candidate_id="cand-1",
            environment="dev",
            timestamp="2024-01-01T12:00:00",
            status="passed"
        )
        evidence_store.save_evidence(evidence)
        
        # Verify relationships
        loaded_task = task_store.load_task("task-1")
        assert loaded_task is not None
        
        task_candidates = candidate_store.list_candidates_for_task("task-1")
        assert len(task_candidates) == 1
        assert task_candidates[0].id == "cand-1"
        
        candidate_evidence = evidence_store.list_evidence_for_candidate("cand-1")
        assert len(candidate_evidence) == 1
        assert candidate_evidence[0].id == "ev-1"
