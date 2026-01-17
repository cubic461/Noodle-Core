"""Noodle Improvement Pipeline (NIP) v1.

This package provides the core data models and functionality for the
Noodle Improvement Pipeline system.
"""

from .models import (
    TaskSpec,
    Candidate,
    Evidence,
    PromotionRecord,
    TaskStatus,
    CandidateStatus,
    Environment
)

from .store import (
    FileStore,
    TaskStore,
    CandidateStore,
    EvidenceStore,
    PromotionStore
)

from .runner import TaskRunner

from .policy import (
    PolicyResult,
    PolicyRule,
    PolicyGate,
    StandardPolicies
)

from .diff import (
    DiffApplier,
    parse_diff_file,
    create_simple_diff
)

from .snapshot import (
    WorkspaceSnapshot,
    SnapshotManager
)

__all__ = [
    # Models
    "TaskSpec",
    "Candidate",
    "Evidence",
    "PromotionRecord",
    "TaskStatus",
    "CandidateStatus",
    "Environment",
    
    # Stores
    "FileStore",
    "TaskStore",
    "CandidateStore",
    "EvidenceStore",
    "PromotionStore",
    
    # Runner
    "TaskRunner",
    
    # Policy
    "PolicyResult",
    "PolicyRule",
    "PolicyGate",
    "StandardPolicies",
    
    # Diff
    "DiffApplier",
    "parse_diff_file",
    "create_simple_diff",
    
    # Snapshot
    "WorkspaceSnapshot",
    "SnapshotManager"
]

__version__ = "1.0.0"
