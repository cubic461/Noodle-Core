"""
Parallel Worktree Execution for NIP v3

This module enables parallel execution of multiple candidates in isolated worktrees,
allowing concurrent testing and validation without interference.
"""

import os
import shutil
import subprocess
import tempfile
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple
import concurrent.futures
import threading
import queue

from .models import Candidate, CandidateStatus, TaskSpec
from .snapshot import WorkspaceSnapshot, SnapshotManager


class WorktreeState(Enum):
    """Worktree lifecycle states"""
    CREATED = "created"
    CLONED = "cloned"
    PATCH_APPLIED = "patch_applied"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CLEANED = "cleaned"


@dataclass
class WorktreeConfig:
    """Configuration for worktree management"""
    max_parallel: int = 3
    worktree_base_dir: str = ".noodle/improve/worktrees"
    auto_cleanup: bool = True
    cleanup_on_completion: bool = False
    timeout_seconds: int = 600
    use_git_worktree: bool = True


@dataclass
class WorktreeResult:
    """Result from worktree execution"""
    worktree_id: str
    candidate_id: str
    state: WorktreeState
    exit_code: Optional[int] = None
    stdout: str = ""
    stderr: str = ""
    duration_seconds: float = 0.0
    error_message: str = ""
    artifacts: List[str] = field(default_factory=list)


class WorktreeManager:
    """
    Manages parallel worktree execution for candidates.
    
    Features:
    - Git worktree-based isolation (default) or directory copying
    - Parallel execution with configurable limits
    - Automatic cleanup and resource management
    - Thread-safe operations
    - Timeout handling
    """
    
    def __init__(
        self,
        config: WorktreeConfig,
        snapshot_manager: SnapshotManager
    ):
        self.config = config
        self.snapshot_manager = snapshot_manager
        self._worktrees: Dict[str, 'Worktree'] = {}
        self._lock = threading.Lock()
        self._executor: Optional[concurrent.futures.ThreadPoolExecutor] = None
        
        # Ensure base directory exists
        Path(config.worktree_base_dir).mkdir(parents=True, exist_ok=True)
    
    def create_worktree(
        self,
        candidate: Candidate,
        snapshot: WorkspaceSnapshot
    ) -> 'Worktree':
        """
        Create a new worktree for a candidate.
        
        Args:
            candidate: The candidate to create a worktree for
            snapshot: The base snapshot to use
            
        Returns:
            Worktree instance
        """
        worktree_id = f"{candidate.id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        worktree_path = Path(config.worktree_base_dir) / worktree_id
        
        with self._lock:
            if worktree_id in self._worktrees:
                raise ValueError(f"Worktree {worktree_id} already exists")
            
            worktree = Worktree(
                id=worktree_id,
                candidate_id=candidate.id,
                path=str(worktree_path),
                snapshot_id=snapshot.id,
                config=self.config,
                snapshot_manager=self.snapshot_manager
            )
            
            self._worktrees[worktree_id] = worktree
        
        return worktree
    
    def execute_parallel(
        self,
        candidates: List[Candidate],
        execution_func: Callable[['Worktree', Candidate], WorktreeResult],
        progress_callback: Optional[Callable[[WorktreeResult], None]] = None
    ) -> List[WorktreeResult]:
        """
        Execute multiple candidates in parallel worktrees.
        
        Args:
            candidates: List of candidates to execute
            execution_func: Function to execute in each worktree
            progress_callback: Optional callback for progress updates
            
        Returns:
            List of results from all executions
        """
        # Create worktrees for all candidates
        worktrees = []
        for candidate in candidates:
            snapshot = self.snapshot_manager.load(candidate.base_snapshot_id)
            worktree = self.create_worktree(candidate, snapshot)
            worktrees.append(worktree)
        
        # Execute in parallel with thread pool
        results = []
        
        with concurrent.futures.ThreadPoolExecutor(
            max_workers=self.config.max_parallel
        ) as executor:
            # Submit all tasks
            future_to_worktree = {
                executor.submit(self._execute_single, wt, execution_func): wt
                for wt in worktrees
            }
            
            # Collect results as they complete
            for future in concurrent.futures.as_completed(future_to_worktree):
                worktree = future_to_worktree[future]
                try:
                    result = future.result(timeout=self.config.timeout_seconds)
                    results.append(result)
                    
                    if progress_callback:
                        progress_callback(result)
                        
                except concurrent.futures.TimeoutError:
                    error_result = WorktreeResult(
                        worktree_id=worktree.id,
                        candidate_id=worktree.candidate_id,
                        state=WorktreeState.FAILED,
                        error_message=f"Execution timed out after {self.config.timeout_seconds}s"
                    )
                    results.append(error_result)
                    
                    if progress_callback:
                        progress_callback(error_result)
                        
                except Exception as e:
                    error_result = WorktreeResult(
                        worktree_id=worktree.id,
                        candidate_id=worktree.candidate_id,
                        state=WorktreeState.FAILED,
                        error_message=str(e)
                    )
                    results.append(error_result)
                    
                    if progress_callback:
                        progress_callback(error_result)
        
        # Cleanup if configured
        if self.config.auto_cleanup:
            self.cleanup_all()
        
        return results
    
    def _execute_single(
        self,
        worktree: 'Worktree',
        execution_func: Callable[['Worktree', Candidate], WorktreeResult]
    ) -> WorktreeResult:
        """Execute a single worktree with error handling"""
        try:
            worktree.prepare()
            return execution_func(worktree, worktree.get_candidate())
        finally:
            if self.config.cleanup_on_completion:
                worktree.cleanup()
    
    def cleanup_all(self):
        """Clean up all worktrees"""
        with self._lock:
            for worktree in self._worktrees.values():
                try:
                    worktree.cleanup()
                except Exception as e:
                    print(f"Error cleaning up worktree {worktree.id}: {e}")
            
            self._worktrees.clear()
    
    def get_worktree(self, worktree_id: str) -> Optional['Worktree']:
        """Get a worktree by ID"""
        return self._worktrees.get(worktree_id)
    
    def list_worktrees(self) -> List['Worktree']:
        """List all active worktrees"""
        return list(self._worktrees.values())


class Worktree:
    """
    Represents a single isolated worktree for candidate execution.
    
    Features:
    - Git worktree or directory-based isolation
    - Patch application
    - Command execution
    - Cleanup
    """
    
    def __init__(
        self,
        id: str,
        candidate_id: str,
        path: str,
        snapshot_id: str,
        config: WorktreeConfig,
        snapshot_manager: SnapshotManager
    ):
        self.id = id
        self.candidate_id = candidate_id
        self.path = Path(path)
        self.snapshot_id = snapshot_id
        self.config = config
        self.snapshot_manager = snapshot_manager
        self._state = WorktreeState.CREATED
        self._candidate: Optional[Candidate] = None
    
    @property
    def state(self) -> WorktreeState:
        """Get current worktree state"""
        return self._state
    
    def prepare(self) -> None:
        """
        Prepare the worktree for execution.
        
        1. Clone or create worktree from snapshot
        2. Apply patch if available
        3. Set up environment
        """
        if self.config.use_git_worktree:
            self._prepare_git_worktree()
        else:
            self._prepare_directory_copy()
        
        self._state = WorktreeState.CLONED
    
    def _prepare_git_worktree(self) -> None:
        """Prepare worktree using git worktree"""
        try:
            # Load snapshot
            snapshot = self.snapshot_manager.load(self.snapshot_id)
            
            # Create worktree from snapshot repo
            repo_path = Path(snapshot.metadata.get('repo_path', '.'))
            
            subprocess.run(
                [
                    'git', 'worktree', 'add',
                    str(self.path),
                    '-b', f'worktree-{self.id}'
                ],
                cwd=repo_path,
                check=True,
                capture_output=True,
                text=True
            )
            
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to create git worktree: {e.stderr}")
    
    def _prepare_directory_copy(self) -> None:
        """Prepare worktree by copying directory"""
        # Load and extract snapshot
        snapshot = self.snapshot_manager.load(self.snapshot_id)
        extract_path = self.snapshot_manager.extract(snapshot, self.path.parent / f"temp_{self.id}")
        
        # Move to final location
        shutil.move(str(extract_path), str(self.path))
    
    def apply_patch(self, patch: str) -> None:
        """Apply a unified diff patch to the worktree"""
        try:
            # Write patch to temp file
            patch_file = self.path / f"{self.id}.patch"
            patch_file.write_text(patch)
            
            # Apply patch
            result = subprocess.run(
                ['git', 'apply', str(patch_file)],
                cwd=self.path,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                raise RuntimeError(f"Patch application failed: {result.stderr}")
            
            self._state = WorktreeState.PATCH_APPLIED
            
        finally:
            # Clean up patch file
            if patch_file.exists():
                patch_file.unlink()
    
    def execute_command(
        self,
        command: List[str],
        timeout: int = 300,
        env: Optional[Dict[str, str]] = None
    ) -> Tuple[int, str, str, float]:
        """
        Execute a command in the worktree.
        
        Returns:
            (exit_code, stdout, stderr, duration_seconds)
        """
        self._state = WorktreeState.RUNNING
        start_time = datetime.now()
        
        try:
            result = subprocess.run(
                command,
                cwd=self.path,
                capture_output=True,
                text=True,
                timeout=timeout,
                env=env
            )
            
            duration = (datetime.now() - start_time).total_seconds()
            
            if result.returncode == 0:
                self._state = WorktreeState.COMPLETED
            else:
                self._state = WorktreeState.FAILED
            
            return (
                result.returncode,
                result.stdout,
                result.stderr,
                duration
            )
            
        except subprocess.TimeoutExpired:
            self._state = WorktreeState.FAILED
            return (
                -1,
                "",
                f"Command timed out after {timeout}s",
                timeout
            )
    
    def cleanup(self) -> None:
        """Clean up the worktree"""
        try:
            if self.path.exists():
                if self.config.use_git_worktree:
                    # Remove git worktree
                    subprocess.run(
                        ['git', 'worktree', 'remove', str(self.path)],
                        capture_output=True
                    )
                else:
                    # Remove directory
                    shutil.rmtree(self.path)
            
            self._state = WorktreeState.CLEANED
            
        except Exception as e:
            print(f"Warning: Failed to cleanup worktree {self.id}: {e}")
    
    def get_candidate(self) -> Optional[Candidate]:
        """Get the associated candidate"""
        return self._candidate
    
    def set_candidate(self, candidate: Candidate) -> None:
        """Set the associated candidate"""
        self._candidate = candidate
    
    def read_file(self, relative_path: str) -> str:
        """Read a file from the worktree"""
        file_path = self.path / relative_path
        return file_path.read_text()
    
    def write_file(self, relative_path: str, content: str) -> None:
        """Write a file to the worktree"""
        file_path = self.path / relative_path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content)