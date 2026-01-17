"""Noodle Improvement Pipeline (NIP) v1 Data Models.

This module defines the core data models for the NIP system:
- TaskSpec: Defines an improvement task
- Candidate: Represents a candidate solution
- Evidence: Records execution results and metrics
- PromotionRecord: Tracks promotion history across environments
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Dict, List, Optional
from enum import Enum
import json


class TaskStatus(Enum):
    """Status of a task in the improvement pipeline."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class CandidateStatus(Enum):
    """Status of a candidate solution."""
    DRAFT = "draft"
    TESTING = "testing"
    PASSED = "passed"
    FAILED = "failed"
    PROMOTED = "promoted"
    REJECTED = "rejected"


class Environment(Enum):
    """Deployment environments."""
    DEV = "dev"
    STAGING = "staging"
    PRODUCTION = "production"


@dataclass
class TaskSpec:
    """Specification for an improvement task.
    
    A TaskSpec defines what needs to be improved, including objectives,
    constraints, and acceptance criteria.
    
    Attributes:
        id: Unique identifier for the task
        title: Human-readable title
        description: Detailed description of the task
        objective: Primary objective/goal of the task
        constraints: List of constraints or limitations
        acceptance_criteria: Criteria for task completion
        priority: Task priority (1-10, higher is more important)
        created_at: Timestamp when task was created
        updated_at: Timestamp when task was last updated
        status: Current status of the task
        metadata: Additional flexible metadata
    """
    id: str
    title: str
    description: str
    objective: str
    constraints: List[str] = field(default_factory=list)
    acceptance_criteria: List[str] = field(default_factory=list)
    priority: int = 5
    created_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    status: str = TaskStatus.PENDING.value
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_json(self) -> str:
        """Convert to JSON string."""
        return json.dumps({
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "objective": self.objective,
            "constraints": self.constraints,
            "acceptance_criteria": self.acceptance_criteria,
            "priority": self.priority,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "status": self.status,
            "metadata": self.metadata
        }, indent=2)
    
    @classmethod
    def from_json(cls, json_str: str) -> 'TaskSpec':
        """Create instance from JSON string."""
        data = json.loads(json_str)
        return cls(**data)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "objective": self.objective,
            "constraints": self.constraints,
            "acceptance_criteria": self.acceptance_criteria,
            "priority": self.priority,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "status": self.status,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TaskSpec':
        """Create instance from dictionary."""
        return cls(**data)


@dataclass
class Candidate:
    """A candidate solution for an improvement task.
    
    A Candidate represents a potential solution with its code changes,
    rationale, and associated evidence.
    
    Attributes:
        id: Unique identifier for the candidate
        task_id: ID of the task this candidate addresses
        title: Human-readable title
        description: Description of the solution approach
        diff: Unified diff of code changes
        rationale: Explanation of why this solution works
        created_at: Timestamp when candidate was created
        updated_at: Timestamp when candidate was last updated
        status: Current status of the candidate
        evidence_ids: List of evidence record IDs
        metadata: Additional flexible metadata
    """
    id: str
    task_id: str
    title: str
    description: str
    diff: str
    rationale: str
    created_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    status: str = CandidateStatus.DRAFT.value
    evidence_ids: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_json(self) -> str:
        """Convert to JSON string."""
        return json.dumps({
            "id": self.id,
            "task_id": self.task_id,
            "title": self.title,
            "description": self.description,
            "diff": self.diff,
            "rationale": self.rationale,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "status": self.status,
            "evidence_ids": self.evidence_ids,
            "metadata": self.metadata
        }, indent=2)
    
    @classmethod
    def from_json(cls, json_str: str) -> 'Candidate':
        """Create instance from JSON string."""
        data = json.loads(json_str)
        return cls(**data)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "id": self.id,
            "task_id": self.task_id,
            "title": self.title,
            "description": self.description,
            "diff": self.diff,
            "rationale": self.rationale,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "status": self.status,
            "evidence_ids": self.evidence_ids,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Candidate':
        """Create instance from dictionary."""
        return cls(**data)


@dataclass
class Evidence:
    """Execution evidence for a candidate solution.
    
    Evidence records the results of running tests, benchmarks,
    or other verification activities on a candidate.
    
    Attributes:
        id: Unique identifier for the evidence record
        candidate_id: ID of the candidate this evidence is for
        environment: Environment where evidence was collected
        timestamp: When the evidence was collected
        status: Whether tests passed or failed
        metrics: Dictionary of performance/quality metrics
        logs: Execution logs or output
        test_results: Detailed test results
        loc_added: Lines of code added
        loc_removed: Lines of code removed
        loc_modified: Lines of code modified
        metadata: Additional flexible metadata
    """
    id: str
    candidate_id: str
    environment: str
    timestamp: str
    status: str
    metrics: Dict[str, float] = field(default_factory=dict)
    logs: str = ""
    test_results: Dict[str, Any] = field(default_factory=dict)
    loc_added: int = 0
    loc_removed: int = 0
    loc_modified: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_json(self) -> str:
        """Convert to JSON string."""
        return json.dumps({
            "id": self.id,
            "candidate_id": self.candidate_id,
            "environment": self.environment,
            "timestamp": self.timestamp,
            "status": self.status,
            "metrics": self.metrics,
            "logs": self.logs,
            "test_results": self.test_results,
            "loc_added": self.loc_added,
            "loc_removed": self.loc_removed,
            "loc_modified": self.loc_modified,
            "metadata": self.metadata
        }, indent=2)
    
    @classmethod
    def from_json(cls, json_str: str) -> 'Evidence':
        """Create instance from JSON string."""
        data = json.loads(json_str)
        return cls(**data)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "id": self.id,
            "candidate_id": self.candidate_id,
            "environment": self.environment,
            "timestamp": self.timestamp,
            "status": self.status,
            "metrics": self.metrics,
            "logs": self.logs,
            "test_results": self.test_results,
            "loc_added": self.loc_added,
            "loc_removed": self.loc_removed,
            "loc_modified": self.loc_modified,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Evidence':
        """Create instance from dictionary."""
        return cls(**data)


@dataclass
class PromotionRecord:
    """Record of a candidate promotion between environments.
    
    A PromotionRecord tracks when and how a candidate was promoted
    from one environment to another (e.g., dev -> staging -> production).
    
    Attributes:
        id: Unique identifier for the promotion record
        candidate_id: ID of the candidate that was promoted
        from_environment: Source environment
        to_environment: Target environment
        timestamp: When the promotion occurred
        promoted_by: Identifier of who/what performed the promotion
        status: Status of the promotion (succeeded, failed, rolled_back)
        evidence_id: ID of evidence that justified the promotion
        rollback_data: Data needed to rollback the promotion
        metadata: Additional flexible metadata
    """
    id: str
    candidate_id: str
    from_environment: str
    to_environment: str
    timestamp: str
    promoted_by: str
    status: str
    evidence_id: Optional[str] = None
    rollback_data: Optional[Dict[str, Any]] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_json(self) -> str:
        """Convert to JSON string."""
        return json.dumps({
            "id": self.id,
            "candidate_id": self.candidate_id,
            "from_environment": self.from_environment,
            "to_environment": self.to_environment,
            "timestamp": self.timestamp,
            "promoted_by": self.promoted_by,
            "status": self.status,
            "evidence_id": self.evidence_id,
            "rollback_data": self.rollback_data,
            "metadata": self.metadata
        }, indent=2)
    
    @classmethod
    def from_json(cls, json_str: str) -> 'PromotionRecord':
        """Create instance from JSON string."""
        data = json.loads(json_str)
        return cls(**data)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "id": self.id,
            "candidate_id": self.candidate_id,
            "from_environment": self.from_environment,
            "to_environment": self.to_environment,
            "timestamp": self.timestamp,
            "promoted_by": self.promoted_by,
            "status": self.status,
            "evidence_id": self.evidence_id,
            "rollback_data": self.rollback_data,
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'PromotionRecord':
        """Create instance from dictionary."""
        return cls(**data)
