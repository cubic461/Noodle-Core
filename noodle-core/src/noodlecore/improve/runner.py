"""Runner module for executing tasks and candidates.

This module provides orchestration for running improvement tasks,
executing candidate solutions, and managing the overall workflow.
"""

import uuid
from datetime import datetime
from typing import List, Optional, Dict, Any
from pathlib import Path

from .models import TaskSpec, Candidate, Evidence, CandidateStatus, TaskStatus
from .store import TaskStore, CandidateStore, EvidenceStore
from .policy import PolicyGate, PolicyResult
from .diff import DiffApplier
from .snapshot import WorkspaceSnapshot


class TaskRunner:
    """Orchestrator for running improvement tasks.
    
    Manages the lifecycle of tasks from creation to completion,
    including candidate generation, testing, and promotion.
    
    Attributes:
        task_store: Store for task persistence
        candidate_store: Store for candidate persistence
        evidence_store: Store for evidence persistence
        workspace_path: Path to the workspace directory
        policy_gate: Policy gate for verification
    """
    
    def __init__(
        self,
        task_store: Optional[TaskStore] = None,
        candidate_store: Optional[CandidateStore] = None,
        evidence_store: Optional[EvidenceStore] = None,
        workspace_path: str = ".",
        policy_gate: Optional[PolicyGate] = None
    ):
        """Initialize the task runner.
        
        Args:
            task_store: Store for task persistence (creates new if None)
            candidate_store: Store for candidate persistence (creates new if None)
            evidence_store: Store for evidence persistence (creates new if None)
            workspace_path: Path to the workspace directory
            policy_gate: Policy gate for verification (creates default if None)
        """
        self.task_store = task_store or TaskStore()
        self.candidate_store = candidate_store or CandidateStore()
        self.evidence_store = evidence_store or EvidenceStore()
        self.workspace_path = Path(workspace_path)
        self.policy_gate = policy_gate or PolicyGate()
        self.diff_applier = DiffApplier(str(self.workspace_path))
    
    def create_task(
        self,
        title: str,
        description: str,
        objective: str,
        constraints: List[str] = None,
        acceptance_criteria: List[str] = None,
        priority: int = 5
    ) -> TaskSpec:
        """Create a new improvement task.
        
        Args:
            title: Human-readable title
            description: Detailed description
            objective: Primary objective
            constraints: List of constraints
            acceptance_criteria: List of acceptance criteria
            priority: Task priority (1-10)
            
        Returns:
            The created TaskSpec
        """
        task_id = str(uuid.uuid4())
        task = TaskSpec(
            id=task_id,
            title=title,
            description=description,
            objective=objective,
            constraints=constraints or [],
            acceptance_criteria=acceptance_criteria or [],
            priority=priority
        )
        
        self.task_store.save_task(task)
        return task
    
    def create_candidate(
        self,
        task_id: str,
        title: str,
        description: str,
        diff: str,
        rationale: str
    ) -> Optional[Candidate]:
        """Create a new candidate solution for a task.
        
        Args:
            task_id: ID of the task this candidate addresses
            title: Human-readable title
            description: Description of the solution
            diff: Unified diff of code changes
            rationale: Explanation of the solution
            
        Returns:
            The created Candidate, or None if task not found
        """
        task = self.task_store.load_task(task_id)
        if not task:
            return None
        
        candidate_id = str(uuid.uuid4())
        candidate = Candidate(
            id=candidate_id,
            task_id=task_id,
            title=title,
            description=description,
            diff=diff,
            rationale=rationale
        )
        
        self.candidate_store.save_candidate(candidate)
        return candidate
    
    def run_candidate(
        self,
        candidate_id: str,
        environment: str = "dev",
        test_command: Optional[str] = None
    ) -> Optional[Evidence]:
        """Run a candidate and collect evidence.
        
        This applies the candidate's diff to the workspace, runs tests,
        and collects execution evidence.
        
        Args:
            candidate_id: ID of the candidate to run
            environment: Environment to run in (dev, staging, production)
            test_command: Optional test command to execute
            
        Returns:
            Evidence record, or None if candidate not found
        """
        candidate = self.candidate_store.load_candidate(candidate_id)
        if not candidate:
            return None
        
        # Take snapshot before applying changes
        snapshot = WorkspaceSnapshot(str(self.workspace_path))
        snapshot.take()
        
        try:
            # Apply the diff
            apply_result = self.diff_applier.apply_diff(candidate.diff)
            
            # Count LOC changes
            loc_counts = self.diff_applier.count_loc(candidate.diff)
            
            # Run tests if command provided
            test_results = {}
            logs = ""
            status = "passed"
            
            if test_command:
                from .sandbox import SandboxRunner
                sandbox = SandboxRunner()
                result = sandbox.run_command(test_command)
                logs = result.get("output", "")
                status = "passed" if result.get("success", False) else "failed"
                test_results = {
                    "command": test_command,
                    "exit_code": result.get("exit_code", -1),
                    "success": result.get("success", False)
                }
            
            # Create evidence record
            evidence_id = str(uuid.uuid4())
            evidence = Evidence(
                id=evidence_id,
                candidate_id=candidate_id,
                environment=environment,
                timestamp=datetime.utcnow().isoformat(),
                status=status,
                logs=logs,
                test_results=test_results,
                loc_added=loc_counts["added"],
                loc_removed=loc_counts["removed"],
                loc_modified=loc_counts["modified"]
            )
            
            self.evidence_store.save_evidence(evidence)
            
            # Update candidate with evidence reference
            candidate.evidence_ids.append(evidence_id)
            
            # Update candidate status based on test results
            if status == "passed":
                candidate.status = CandidateStatus.PASSED.value
            else:
                candidate.status = CandidateStatus.FAILED.value
            
            self.candidate_store.save_candidate(candidate)
            
            return evidence
            
        except Exception as e:
            # Restore snapshot on error
            snapshot.restore()
            raise e
    
    def evaluate_candidate(
        self,
        candidate_id: str
    ) -> PolicyResult:
        """Evaluate a candidate against policy gates.
        
        Args:
            candidate_id: ID of the candidate to evaluate
            
        Returns:
            Policy evaluation result
        """
        candidate = self.candidate_store.load_candidate(candidate_id)
        if not candidate:
            return PolicyResult(
                allowed=False,
                reasons=["Candidate not found"],
                score=0.0
            )
        
        # Get all evidence for this candidate
        evidence_list = self.evidence_store.list_evidence_for_candidate(candidate_id)
        
        # Evaluate against policy gates
        result = self.policy_gate.evaluate(candidate, evidence_list)
        
        return result
    
    def promote_candidate(
        self,
        candidate_id: str,
        from_environment: str,
        to_environment: str,
        promoted_by: str
    ) -> bool:
        """Promote a candidate to a new environment.
        
        Args:
            candidate_id: ID of the candidate to promote
            from_environment: Source environment
            to_environment: Target environment
            promoted_by: Who/what is performing the promotion
            
        Returns:
            True if promotion succeeded, False otherwise
        """
        candidate = self.candidate_store.load_candidate(candidate_id)
        if not candidate:
            return False
        
        # Check if candidate has passed tests
        if candidate.status != CandidateStatus.PASSED.value:
            return False
        
        # Get the most recent evidence
        evidence_list = self.evidence_store.list_evidence_for_candidate(candidate_id)
        if not evidence_list:
            return False
        
        latest_evidence = max(evidence_list, key=lambda e: e.timestamp)
        
        # Create promotion record
        promotion_id = str(uuid.uuid4())
        from .models import PromotionRecord
        
        promotion = PromotionRecord(
            id=promotion_id,
            candidate_id=candidate_id,
            from_environment=from_environment,
            to_environment=to_environment,
            timestamp=datetime.utcnow().isoformat(),
            promoted_by=promoted_by,
            status="succeeded",
            evidence_id=latest_evidence.id
        )
        
        # Update candidate status
        candidate.status = CandidateStatus.PROMOTED.value
        
        # Save changes
        from .store import PromotionStore
        promotion_store = PromotionStore()
        promotion_store.save_promotion(promotion)
        self.candidate_store.save_candidate(candidate)
        
        return True
    
    def get_task_candidates(self, task_id: str) -> List[Candidate]:
        """Get all candidates for a task.
        
        Args:
            task_id: ID of the task
            
        Returns:
            List of candidates for the task
        """
        return self.candidate_store.list_candidates_for_task(task_id)
    
    def get_candidate_evidence(self, candidate_id: str) -> List[Evidence]:
        """Get all evidence for a candidate.
        
        Args:
            candidate_id: ID of the candidate
            
        Returns:
            List of evidence records
        """
        return self.evidence_store.list_evidence_for_candidate(candidate_id)
