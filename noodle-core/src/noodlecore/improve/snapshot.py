"""Workspace snapshot functionality.

This module provides the ability to capture and restore workspace states,
enabling safe experimentation with code changes.
"""

import os
import shutil
import tempfile
import zipfile
from pathlib import Path
from typing import List, Optional
from datetime import datetime
import json


class WorkspaceSnapshot:
    """Captures and restores workspace states.
    
    Provides functionality to snapshot a workspace before making changes
    and restore it if needed. Supports both full and incremental snapshots.
    
    Attributes:
        workspace_path: Path to the workspace directory
        snapshot_dir: Directory where snapshots are stored
        temp_dir: Temporary directory for snapshot operations
    """
    
    def __init__(self, workspace_path: str, snapshot_dir: Optional[str] = None):
        """Initialize the workspace snapshot manager.
        
        Args:
            workspace_path: Path to the workspace to snapshot
            snapshot_dir: Directory for storing snapshots (default: .nip/snapshots)
        """
        self.workspace_path = Path(workspace_path).resolve()
        self.snapshot_dir = Path(snapshot_dir or ".nip/snapshots").resolve()
        self.snapshot_dir.mkdir(parents=True, exist_ok=True)
        self._current_snapshot_id: Optional[str] = None
        self._current_snapshot_path: Optional[Path] = None
        self._temp_dir: Optional[Path] = None
    
    def take(self, metadata: Optional[dict] = None) -> str:
        """Take a snapshot of the current workspace state.
        
        Args:
            metadata: Optional metadata to include with the snapshot
            
        Returns:
            Snapshot ID
        """
        snapshot_id = self._generate_snapshot_id()
        snapshot_path = self.snapshot_dir / snapshot_id
        snapshot_path.mkdir(parents=True, exist_ok=True)
        
        # Create metadata file
        meta = {
            "id": snapshot_id,
            "timestamp": datetime.utcnow().isoformat(),
            "workspace_path": str(self.workspace_path),
            "metadata": metadata or {}
        }
        
        with open(snapshot_path / "metadata.json", 'w') as f:
            json.dump(meta, f, indent=2)
        
        # Create temporary directory for staging
        self._temp_dir = Path(tempfile.mkdtemp(prefix="nip_snapshot_"))
        
        try:
            # Copy workspace files to temp directory
            self._copy_workspace_to_temp()
            
            # Create zip archive
            zip_path = snapshot_path / "workspace.zip"
            self._create_zip_archive(zip_path)
            
            # Store current snapshot info
            self._current_snapshot_id = snapshot_id
            self._current_snapshot_path = snapshot_path
            
        finally:
            # Clean up temp directory
            if self._temp_dir and self._temp_dir.exists():
                shutil.rmtree(self._temp_dir, ignore_errors=True)
                self._temp_dir = None
        
        return snapshot_id
    
    def restore(self, snapshot_id: Optional[str] = None) -> bool:
        """Restore a workspace snapshot.
        
        Args:
            snapshot_id: ID of snapshot to restore (uses current if None)
            
        Returns:
            True if restore succeeded
        """
        target_id = snapshot_id or self._current_snapshot_id
        if not target_id:
            return False
        
        snapshot_path = self.snapshot_dir / target_id
        if not snapshot_path.exists():
            return False
        
        zip_path = snapshot_path / "workspace.zip"
        if not zip_path.exists():
            return False
        
        # Create temporary directory for extraction
        temp_extract = Path(tempfile.mkdtemp(prefix="nip_restore_"))
        
        try:
            # Extract zip to temp directory
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(temp_extract)
            
            # Backup current workspace
            backup_path = self.workspace_path.parent / f"{self.workspace_path.name}_backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
            shutil.move(str(self.workspace_path), str(backup_path))
            
            try:
                # Move extracted files to workspace
                for item in temp_extract.iterdir():
                    dest = self.workspace_path / item.name
                    if item.is_dir():
                        shutil.copytree(item, dest, dirs_exist_ok=True)
                    else:
                        shutil.copy2(item, dest)
                
                return True
                
            except Exception as e:
                # Restore from backup if move failed
                shutil.rmtree(str(self.workspace_path), ignore_errors=True)
                shutil.move(str(backup_path), str(self.workspace_path))
                raise e
                
        finally:
            # Clean up temp directory
            if temp_extract.exists():
                shutil.rmtree(temp_extract, ignore_errors=True)
        
        return False
    
    def delete(self, snapshot_id: str) -> bool:
        """Delete a snapshot.
        
        Args:
            snapshot_id: ID of snapshot to delete
            
        Returns:
            True if deleted
        """
        snapshot_path = self.snapshot_dir / snapshot_id
        if snapshot_path.exists():
            shutil.rmtree(snapshot_path)
            return True
        return False
    
    def list_snapshots(self) -> List[dict]:
        """List all available snapshots.
        
        Returns:
            List of snapshot metadata dictionaries
        """
        snapshots = []
        
        for snapshot_dir in self.snapshot_dir.iterdir():
            if snapshot_dir.is_dir():
                meta_file = snapshot_dir / "metadata.json"
                if meta_file.exists():
                    with open(meta_file, 'r') as f:
                        meta = json.load(f)
                        snapshots.append(meta)
        
        return sorted(snapshots, key=lambda s: s['timestamp'], reverse=True)
    
    def get_snapshot_info(self, snapshot_id: str) -> Optional[dict]:
        """Get information about a specific snapshot.
        
        Args:
            snapshot_id: ID of the snapshot
            
        Returns:
            Snapshot metadata or None if not found
        """
        snapshot_path = self.snapshot_dir / snapshot_id
        meta_file = snapshot_path / "metadata.json"
        
        if meta_file.exists():
            with open(meta_file, 'r') as f:
                return json.load(f)
        
        return None
    
    def _generate_snapshot_id(self) -> str:
        """Generate a unique snapshot ID.
        
        Returns:
            Snapshot ID string
        """
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        return f"snapshot_{timestamp}"
    
    def _copy_workspace_to_temp(self) -> None:
        """Copy workspace files to temporary directory.
        
        Excludes certain directories like .git, __pycache__, node_modules, etc.
        """
        exclude_dirs = {'.git', '__pycache__', 'node_modules', '.venv', 'venv', '.nip', '.tox', '.pytest_cache', 'dist', 'build', '*.egg-info'}
        exclude_files = {'.DS_Store', 'Thumbs.db', '*.pyc', '*.pyo'}
        
        for item in self.workspace_path.iterdir():
            # Skip excluded directories
            if item.name in exclude_dirs or item.name.startswith('.'):
                continue
            
            if item.is_dir():
                dest = self._temp_dir / item.name
                shutil.copytree(item, dest, 
                              ignore=shutil.ignore_patterns(*exclude_dirs),
                              dirs_exist_ok=True)
            else:
                # Skip excluded files
                if item.name in exclude_files or item.suffix in ['.pyc', '.pyo']:
                    continue
                shutil.copy2(item, self._temp_dir / item.name)
    
    def _create_zip_archive(self, zip_path: Path) -> None:
        """Create a zip archive from the temporary directory.
        
        Args:
            zip_path: Path where the zip file should be created
        """
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for item in self._temp_dir.iterdir():
                if item.is_file():
                    zipf.write(item, item.name)
                elif item.is_dir():
                    for root, dirs, files in os.walk(item):
                        for file in files:
                            file_path = Path(root) / file
                            arcname = file_path.relative_to(self._temp_dir)
                            zipf.write(file_path, arcname)


class SnapshotManager:
    """Manages multiple workspace snapshots with cleanup policies.
    
    Provides higher-level snapshot management including automatic cleanup
    of old snapshots and retention policies.
    
    Attributes:
        workspace_path: Path to the workspace
        snapshot_dir: Directory for storing snapshots
        max_snapshots: Maximum number of snapshots to keep
        max_age_days: Maximum age of snapshots in days
    """
    
    def __init__(
        self,
        workspace_path: str,
        snapshot_dir: Optional[str] = None,
        max_snapshots: int = 10,
        max_age_days: int = 30
    ):
        """Initialize the snapshot manager.
        
        Args:
            workspace_path: Path to the workspace
            snapshot_dir: Directory for snapshots
            max_snapshots: Maximum snapshots to retain
            max_age_days: Maximum age in days
        """
        self.workspace = WorkspaceSnapshot(workspace_path, snapshot_dir)
        self.max_snapshots = max_snapshots
        self.max_age_days = max_age_days
    
    def take_snapshot(self, metadata: Optional[dict] = None) -> str:
        """Take a snapshot and enforce retention policies.
        
        Args:
            metadata: Optional metadata
            
        Returns:
            Snapshot ID
        """
        snapshot_id = self.workspace.take(metadata)
        self._cleanup_old_snapshots()
        return snapshot_id
    
    def restore_snapshot(self, snapshot_id: str) -> bool:
        """Restore a snapshot.
        
        Args:
            snapshot_id: ID of snapshot to restore
            
        Returns:
            True if succeeded
        """
        return self.workspace.restore(snapshot_id)
    
    def list_snapshots(self) -> List[dict]:
        """List all snapshots.
        
        Returns:
            List of snapshot metadata
        """
        return self.workspace.list_snapshots()
    
    def _cleanup_old_snapshots(self) -> None:
        """Remove old snapshots based on retention policies."""
        snapshots = self.workspace.list_snapshots()
        
        # Remove snapshots exceeding max count
        if len(snapshots) > self.max_snapshots:
            for snapshot in snapshots[self.max_snapshots:]:
                self.workspace.delete(snapshot['id'])
        
        # Remove snapshots older than max age
        from datetime import timedelta
        cutoff = datetime.utcnow() - timedelta(days=self.max_age_days)
        
        for snapshot in snapshots:
            snapshot_time = datetime.fromisoformat(snapshot['timestamp'])
            if snapshot_time < cutoff:
                self.workspace.delete(snapshot['id'])
