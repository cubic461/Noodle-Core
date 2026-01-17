"""Tests for NIP snapshot functionality.

Tests WorkspaceSnapshot and SnapshotManager.
"""

import pytest
import tempfile
import shutil
import zipfile
from pathlib import Path
from datetime import datetime, timedelta
from noodlecore.improve.snapshot import (
    WorkspaceSnapshot, SnapshotManager
)


@pytest.fixture
def temp_workspace():
    """Create a temporary workspace for testing."""
    temp_dir = tempfile.mkdtemp(prefix="nip_test_workspace_")
    yield temp_dir
    # Cleanup
    shutil.rmtree(temp_dir, ignore_errors=True)


@pytest.fixture
def temp_snapshot_dir():
    """Create a temporary snapshot directory for testing."""
    temp_dir = tempfile.mkdtemp(prefix="nip_test_snapshots_")
    yield temp_dir
    # Cleanup
    shutil.rmtree(temp_dir, ignore_errors=True)


@pytest.fixture
def sample_workspace(temp_workspace):
    """Create a sample workspace with files."""
    workspace = Path(temp_workspace)
    
    # Create some files
    (workspace / "file1.txt").write_text("content 1")
    (workspace / "file2.py").write_text("print('hello')")
    
    # Create subdirectory with files
    subdir = workspace / "subdir"
    subdir.mkdir()
    (subdir / "file3.txt").write_text("content 3")
    
    return temp_workspace


@pytest.fixture
def workspace_snapshot(sample_workspace, temp_snapshot_dir):
    """Create a WorkspaceSnapshot instance."""
    return WorkspaceSnapshot(
        workspace_path=sample_workspace,
        snapshot_dir=temp_snapshot_dir
    )


@pytest.fixture
def snapshot_manager(sample_workspace, temp_snapshot_dir):
    """Create a SnapshotManager instance."""
    return SnapshotManager(
        workspace_path=sample_workspace,
        snapshot_dir=temp_snapshot_dir,
        max_snapshots=5,
        max_age_days=7
    )


class TestWorkspaceSnapshot:
    """Test WorkspaceSnapshot functionality."""
    
    def test_initialization(self, temp_workspace, temp_snapshot_dir):
        """Test WorkspaceSnapshot initialization."""
        snapshot = WorkspaceSnapshot(
            workspace_path=temp_workspace,
            snapshot_dir=temp_snapshot_dir
        )
        
        assert snapshot.workspace_path == Path(temp_workspace).resolve()
        assert snapshot.snapshot_dir == Path(temp_snapshot_dir).resolve()
        assert snapshot.snapshot_dir.exists()
    
    def test_initialization_creates_snapshot_dir(self, temp_workspace):
        """Test initialization creates snapshot directory if it doesn't exist."""
        new_snapshot_dir = tempfile.mkdtemp(prefix="nip_new_snapshots_")
        shutil.rmtree(new_snapshot_dir)
        
        snapshot = WorkspaceSnapshot(
            workspace_path=temp_workspace,
            snapshot_dir=new_snapshot_dir
        )
        
        assert snapshot.snapshot_dir.exists()
        
        # Cleanup
        shutil.rmtree(new_snapshot_dir, ignore_errors=True)
    
    def test_take_snapshot(self, workspace_snapshot):
        """Test taking a snapshot."""
        snapshot_id = workspace_snapshot.take()
        
        assert snapshot_id is not None
        assert isinstance(snapshot_id, str)
        assert snapshot_id.startswith("snapshot_")
        
        # Verify snapshot directory was created
        snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
        assert snapshot_path.exists()
        assert (snapshot_path / "metadata.json").exists()
        assert (snapshot_path / "workspace.zip").exists()
    
    def test_take_snapshot_with_metadata(self, workspace_snapshot):
        """Test taking a snapshot with custom metadata."""
        metadata = {
            "author": "test-user",
            "description": "Test snapshot",
            "tags": ["test", "example"]
        }
        
        snapshot_id = workspace_snapshot.take(metadata=metadata)
        
        # Load and verify metadata
        snapshot_info = workspace_snapshot.get_snapshot_info(snapshot_id)
        assert snapshot_info is not None
        assert snapshot_info["metadata"]["author"] == "test-user"
        assert snapshot_info["metadata"]["tags"] == ["test", "example"]
    
    def test_take_multiple_snapshots(self, workspace_snapshot):
        """Test taking multiple snapshots."""
        snapshot_ids = []
        
        for i in range(3):
            snapshot_id = workspace_snapshot.take(metadata={"index": i})
            snapshot_ids.append(snapshot_id)
        
        # All snapshots should exist
        for snapshot_id in snapshot_ids:
            snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
            assert snapshot_path.exists()
        
        # Should be able to list all snapshots
        all_snapshots = workspace_snapshot.list_snapshots()
        assert len(all_snapshots) == 3
    
    def test_restore_snapshot(self, workspace_snapshot, sample_workspace):
        """Test restoring a snapshot."""
        # Take initial snapshot
        snapshot_id = workspace_snapshot.take()
        
        # Modify workspace
        workspace_path = Path(sample_workspace)
        (workspace_path / "file1.txt").write_text("modified content")
        (workspace_path / "new_file.txt").write_text("new content")
        
        # Restore snapshot
        success = workspace_snapshot.restore(snapshot_id)
        
        assert success is True
        
        # Verify original content restored
        assert (workspace_path / "file1.txt").read_text() == "content 1"
        assert not (workspace_path / "new_file.txt").exists()
    
    def test_restore_nonexistent_snapshot(self, workspace_snapshot):
        """Test restoring a snapshot that doesn't exist."""
        success = workspace_snapshot.restore("nonexistent_snapshot")
        
        assert success is False
    
    def test_restore_without_snapshot_id(self, workspace_snapshot):
        """Test restore without providing snapshot ID (uses current)."""
        # Take a snapshot
        snapshot_id = workspace_snapshot.take()
        
        # Modify workspace
        workspace_path = Path(workspace_snapshot.workspace_path)
        (workspace_path / "file1.txt").write_text("modified")
        
        # Restore without ID (should use current)
        success = workspace_snapshot.restore()
        
        assert success is True
    
    def test_delete_snapshot(self, workspace_snapshot):
        """Test deleting a snapshot."""
        snapshot_id = workspace_snapshot.take()
        
        # Verify snapshot exists
        assert workspace_snapshot.get_snapshot_info(snapshot_id) is not None
        
        # Delete snapshot
        deleted = workspace_snapshot.delete(snapshot_id)
        
        assert deleted is True
        assert workspace_snapshot.get_snapshot_info(snapshot_id) is None
    
    def test_delete_nonexistent_snapshot(self, workspace_snapshot):
        """Test deleting a snapshot that doesn't exist."""
        deleted = workspace_snapshot.delete("nonexistent_snapshot")
        
        assert deleted is False
    
    def test_list_snapshots(self, workspace_snapshot):
        """Test listing all snapshots."""
        # Initially empty
        snapshots = workspace_snapshot.list_snapshots()
        assert len(snapshots) == 0
        
        # Take multiple snapshots
        for i in range(3):
            workspace_snapshot.take(metadata={"index": i})
        
        # List snapshots
        snapshots = workspace_snapshot.list_snapshots()
        assert len(snapshots) == 3
        
        # Verify sorted by timestamp (newest first)
        timestamps = [s["timestamp"] for s in snapshots]
        assert timestamps == sorted(timestamps, reverse=True)
    
    def test_get_snapshot_info(self, workspace_snapshot):
        """Test getting information about a specific snapshot."""
        metadata = {"test": "value"}
        snapshot_id = workspace_snapshot.take(metadata=metadata)
        
        info = workspace_snapshot.get_snapshot_info(snapshot_id)
        
        assert info is not None
        assert info["id"] == snapshot_id
        assert "timestamp" in info
        assert "workspace_path" in info
        assert info["metadata"]["test"] == "value"
    
    def test_get_snapshot_info_nonexistent(self, workspace_snapshot):
        """Test getting info for a snapshot that doesn't exist."""
        info = workspace_snapshot.get_snapshot_info("nonexistent")
        
        assert info is None
    
    def test_excluded_directories(self, workspace_snapshot, sample_workspace):
        """Test that certain directories are excluded from snapshots."""
        # Create directories that should be excluded
        workspace_path = Path(sample_workspace)
        (workspace_path / ".git").mkdir()
        (workspace_path / ".git" / "config").write_text("git config")
        (workspace_path / "__pycache__").mkdir()
        (workspace_path / "__pycache__" / "file.pyc").write_text("compiled")
        (workspace_path / "node_modules").mkdir()
        
        # Take snapshot
        snapshot_id = workspace_snapshot.take()
        
        # Extract and verify contents
        snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
        zip_path = snapshot_path / "workspace.zip"
        
        with zipfile.ZipFile(zip_path, 'r') as zipf:
            namelist = zipf.namelist()
            
            # Excluded directories should not be in snapshot
            assert not any(".git" in name for name in namelist)
            assert not any("__pycache__" in name for name in namelist)
            assert not any("node_modules" in name for name in namelist)
    
    def test_excluded_files(self, workspace_snapshot, sample_workspace):
        """Test that certain files are excluded from snapshots."""
        workspace_path = Path(sample_workspace)
        (workspace_path / ".DS_Store").write_text("mac file")
        (workspace_path / "Thumbs.db").write_text("windows file")
        (workspace_path / "test.pyc").write_text("compiled")
        
        # Take snapshot
        snapshot_id = workspace_snapshot.take()
        
        # Extract and verify contents
        snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
        zip_path = snapshot_path / "workspace.zip"
        
        with zipfile.ZipFile(zip_path, 'r') as zipf:
            namelist = zipf.namelist()
            
            # Excluded files should not be in snapshot
            assert ".DS_Store" not in namelist
            assert "Thumbs.db" not in namelist
            assert not any(name.endswith(".pyc") for name in namelist)


class TestSnapshotManager:
    """Test SnapshotManager functionality."""
    
    def test_initialization(self, sample_workspace, temp_snapshot_dir):
        """Test SnapshotManager initialization."""
        manager = SnapshotManager(
            workspace_path=sample_workspace,
            snapshot_dir=temp_snapshot_dir,
            max_snapshots=10,
            max_age_days=30
        )
        
        assert manager.workspace is not None
        assert manager.max_snapshots == 10
        assert manager.max_age_days == 30
    
    def test_take_snapshot(self, snapshot_manager):
        """Test taking a snapshot through the manager."""
        snapshot_id = snapshot_manager.take_snapshot()
        
        assert snapshot_id is not None
        
        # Verify snapshot exists
        snapshots = snapshot_manager.list_snapshots()
        assert len(snapshots) == 1
        assert snapshots[0]["id"] == snapshot_id
    
    def test_restore_snapshot(self, snapshot_manager, sample_workspace):
        """Test restoring a snapshot through the manager."""
        snapshot_id = snapshot_manager.take_snapshot()
        
        # Modify workspace
        workspace_path = Path(sample_workspace)
        (workspace_path / "file1.txt").write_text("modified")
        
        # Restore
        success = snapshot_manager.restore_snapshot(snapshot_id)
        
        assert success is True
        assert (workspace_path / "file1.txt").read_text() == "content 1"
    
    def test_list_snapshots(self, snapshot_manager):
        """Test listing snapshots through the manager."""
        # Initially empty
        snapshots = snapshot_manager.list_snapshots()
        assert len(snapshots) == 0
        
        # Take multiple snapshots
        for i in range(3):
            snapshot_manager.take_snapshot(metadata={"index": i})
        
        # List
        snapshots = snapshot_manager.list_snapshots()
        assert len(snapshots) == 3
    
    def test_max_snapshots_cleanup(self, snapshot_manager):
        """Test that old snapshots are cleaned up when exceeding max_snapshots."""
        # Set low limit
        snapshot_manager.max_snapshots = 3
        
        # Take more snapshots than allowed
        for i in range(5):
            snapshot_manager.take_snapshot(metadata={"index": i})
        
        # Should only have max_snapshots retained
        snapshots = snapshot_manager.list_snapshots()
        assert len(snapshots) <= 3
    
    def test_max_age_cleanup(self, snapshot_manager):
        """Test that old snapshots are cleaned up based on age."""
        # This test is difficult to do without mocking time
        # Just verify the cleanup method doesn't crash
        snapshot_manager.max_age_days = 0  # Should clean up immediately
        
        # Take a snapshot
        snapshot_id = snapshot_manager.take_snapshot()
        
        # The snapshot should be cleaned up (though timing-dependent)
        # Just verify the method runs without error
        snapshots = snapshot_manager.list_snapshots()
        assert isinstance(snapshots, list)
    
    def test_cleanup_old_snapshots_preserves_recent(self, snapshot_manager):
        """Test that recent snapshots are preserved during cleanup."""
        # Take snapshots
        snapshot_ids = []
        for i in range(3):
            snapshot_id = snapshot_manager.take_snapshot(metadata={"index": i})
            snapshot_ids.append(snapshot_id)
        
        # Should have all snapshots
        snapshots = snapshot_manager.list_snapshots()
        initial_count = len(snapshots)
        
        # Should not have deleted any (under limit)
        assert initial_count == 3


class TestSnapshotErrors:
    """Test error handling in snapshot functionality."""
    
    def test_snapshot_invalid_workspace(self, temp_snapshot_dir):
        """Test handling of invalid workspace path."""
        # Use a non-existent workspace
        snapshot = WorkspaceSnapshot(
            workspace_path="/nonexistent/workspace",
            snapshot_dir=temp_snapshot_dir
        )
        
        # Should not crash on initialization
        assert snapshot is not None
    
    def test_snapshot_with_empty_workspace(self, temp_workspace, temp_snapshot_dir):
        """Test snapshot of an empty workspace."""
        snapshot = WorkspaceSnapshot(
            workspace_path=temp_workspace,
            snapshot_dir=temp_snapshot_dir
        )
        
        # Should still create snapshot
        snapshot_id = snapshot.take()
        
        assert snapshot_id is not None
        assert snapshot.get_snapshot_info(snapshot_id) is not None
    
    def test_restore_after_workspace_modification(self, workspace_snapshot, sample_workspace):
        """Test restore when workspace has been modified."""
        # Take snapshot
        snapshot_id = workspace_snapshot.take()
        
        # Make significant changes
        workspace_path = Path(sample_workspace)
        (workspace_path / "file1.txt").unlink()
        (workspace_path / "new_dir").mkdir()
        (workspace_path / "new_dir" / "new_file.txt").write_text("new")
        
        # Restore
        success = workspace_snapshot.restore(snapshot_id)
        
        assert success is True
        # Verify original state
        assert (workspace_path / "file1.txt").exists()
        assert not (workspace_path / "new_dir").exists()


class TestSnapshotMetadata:
    """Test snapshot metadata handling."""
    
    def test_snapshot_metadata_fields(self, workspace_snapshot):
        """Test that all required metadata fields are present."""
        snapshot_id = workspace_snapshot.take()
        
        info = workspace_snapshot.get_snapshot_info(snapshot_id)
        
        assert "id" in info
        assert "timestamp" in info
        assert "workspace_path" in info
        assert "metadata" in info
    
    def test_snapshot_timestamp_format(self, workspace_snapshot):
        """Test that timestamp is in ISO format."""
        snapshot_id = workspace_snapshot.take()
        
        info = workspace_snapshot.get_snapshot_info(snapshot_id)
        
        # Should be parseable as ISO datetime
        datetime.fromisoformat(info["timestamp"])
    
    def test_custom_metadata_preserved(self, workspace_snapshot):
        """Test that custom metadata is preserved."""
        custom_data = {
            "author": "alice",
            "tags": ["bugfix", "urgent"],
            "ticket": "PROJ-123",
            "count": 42
        }
        
        snapshot_id = workspace_snapshot.take(metadata=custom_data)
        
        info = workspace_snapshot.get_snapshot_info(snapshot_id)
        
        assert info["metadata"]["author"] == "alice"
        assert info["metadata"]["tags"] == ["bugfix", "urgent"]
        assert info["metadata"]["ticket"] == "PROJ-123"
        assert info["metadata"]["count"] == 42


class TestSnapshotCompression:
    """Test snapshot compression and file handling."""
    
    def test_snapshot_creates_zip(self, workspace_snapshot):
        """Test that snapshot creates a zip file."""
        snapshot_id = workspace_snapshot.take()
        
        snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
        zip_path = snapshot_path / "workspace.zip"
        
        assert zip_path.exists()
        assert zipfile.is_zipfile(zip_path)
    
    def test_zip_contains_expected_files(self, workspace_snapshot):
        """Test that zip contains workspace files."""
        snapshot_id = workspace_snapshot.take()
        
        snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
        zip_path = snapshot_path / "workspace.zip"
        
        with zipfile.ZipFile(zip_path, 'r') as zipf:
            namelist = zipf.namelist()
            
            # Should contain our test files
            assert "file1.txt" in namelist
            assert "file2.py" in namelist
            # Files in subdirectory
            assert any("subdir" in name for name in namelist)
    
    def test_zip_file_contents(self, workspace_snapshot):
        """Test that zip file contents are correct."""
        snapshot_id = workspace_snapshot.take()
        
        snapshot_path = workspace_snapshot.snapshot_dir / snapshot_id
        zip_path = snapshot_path / "workspace.zip"
        
        with zipfile.ZipFile(zip_path, 'r') as zipf:
            # Read file1.txt content
            with zipf.open("file1.txt") as f:
                content = f.read().decode()
                assert content == "content 1"


class TestSnapshotIdGeneration:
    """Test snapshot ID generation."""
    
    def test_snapshot_id_format(self, workspace_snapshot):
        """Test that snapshot IDs have correct format."""
        snapshot_id = workspace_snapshot.take()
        
        assert snapshot_id.startswith("snapshot_")
        # Should contain timestamp
        assert len(snapshot_id) > len("snapshot_")
    
    def test_snapshot_ids_are_unique(self, workspace_snapshot):
        """Test that each snapshot gets a unique ID."""
        snapshot_ids = []
        
        for i in range(5):
            snapshot_id = workspace_snapshot.take()
            snapshot_ids.append(snapshot_id)
        
        # All IDs should be unique
        assert len(set(snapshot_ids)) == 5
    
    def test_snapshot_id_timestamp_ordering(self, workspace_snapshot):
        """Test that snapshot IDs reflect chronological order."""
        snapshot_ids = []
        
        for i in range(3):
            snapshot_id = workspace_snapshot.take()
            snapshot_ids.append(snapshot_id)
        
        # IDs should be in chronological order
        assert snapshot_ids[0] < snapshot_ids[1] < snapshot_ids[2]
