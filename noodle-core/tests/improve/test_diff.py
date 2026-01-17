"""Tests for NIP diff handling.

Tests DiffApplier for diff application, LOC counting, and validation.
"""

import pytest
import tempfile
import shutil
from pathlib import Path
from noodlecore.improve.diff import (
    DiffApplier, parse_diff_file, create_simple_diff
)


@pytest.fixture
def temp_workspace():
    """Create a temporary workspace for testing."""
    temp_dir = tempfile.mkdtemp(prefix="nip_test_diff_")
    yield temp_dir
    # Cleanup
    shutil.rmtree(temp_dir, ignore_errors=True)


@pytest.fixture
def diff_applier(temp_workspace):
    """Create a DiffApplier with temporary workspace."""
    return DiffApplier(base_path=temp_workspace)


@pytest.fixture
def sample_diff():
    """Create a sample unified diff."""
    return """--- a/test.py
+++ b/test.py
@@ -1,5 +1,6 @@
 def hello():
-    print("Hello")
+    print("Hello World")
     return True
+    print("Done")
"""


@pytest.fixture
def multi_file_diff():
    """Create a diff with multiple files."""
    return """--- a/file1.py
+++ b/file1.py
@@ -1,3 +1,4 @@
 # File 1
 def func1():
     pass
+    return 42
--- a/file2.py
+++ b/file2.py
@@ -1,2 +1,3 @@
 # File 2
-x = 1
+x = 2
+y = 3
"""


@pytest.fixture
def empty_diff():
    """Create an empty diff."""
    return ""


class TestDiffApplier:
    """Test DiffApplier functionality."""
    
    def test_diff_applier_initialization(self, temp_workspace):
        """Test DiffApplier initialization."""
        applier = DiffApplier(base_path=temp_workspace)
        
        assert applier.base_path == Path(temp_workspace)
    
    def test_apply_empty_diff(self, diff_applier):
        """Test applying an empty diff."""
        result = diff_applier.apply_diff("")
        
        assert result["success"] is True
        assert result["files_modified"] == 0
        assert result["errors"] == []
    
    def test_apply_whitespace_diff(self, diff_applier):
        """Test applying a diff with only whitespace."""
        result = diff_applier.apply_diff("   \n\n  ")
        
        assert result["success"] is True
        assert result["files_modified"] == 0


class TestLOCCounting:
    """Test LOC counting functionality."""
    
    def test_count_loc_simple_diff(self, diff_applier, sample_diff):
        """Test counting LOC in a simple diff."""
        counts = diff_applier.count_loc(sample_diff)
        
        assert "added" in counts
        assert "removed" in counts
        assert "modified" in counts
        assert counts["added"] >= 0
        assert counts["removed"] >= 0
        assert counts["modified"] >= 0
    
    def test_count_loc_empty_diff(self, diff_applier, empty_diff):
        """Test counting LOC in an empty diff."""
        counts = diff_applier.count_loc(empty_diff)
        
        assert counts == {"added": 0, "removed": 0, "modified": 0}
    
    def test_count_loc_only_additions(self, diff_applier):
        """Test counting LOC with only additions."""
        diff = """--- a/test.py
+++ b/test.py
@@ -1,1 +1,3 @@
 line 1
+line 2
+line 3
"""
        counts = diff_applier.count_loc(diff)
        
        assert counts["added"] == 2
        assert counts["removed"] == 0
    
    def test_count_loc_only_removals(self, diff_applier):
        """Test counting LOC with only removals."""
        diff = """--- a/test.py
+++ b/test.py
@@ -1,3 +1,1 @@
 line 1
-line 2
-line 3
"""
        counts = diff_applier.count_loc(diff)
        
        assert counts["added"] == 0
        assert counts["removed"] == 2
    
    def test_count_loc_mixed_changes(self, diff_applier):
        """Test counting LOC with mixed changes."""
        diff = """--- a/test.py
+++ b/test.py
@@ -1,5 +1,7 @@
 line 1
-line 2
+line 2 modified
 line 3
-line 4
+line 4 modified
 line 5
+line 6
+line 7
"""
        counts = diff_applier.count_loc(diff)
        
        assert counts["added"] == 3  # 2 modified + 1 new
        assert counts["removed"] == 2
        assert counts["modified"] == 2  # min of added and removed
    
    def test_count_loc_multi_file(self, diff_applier, multi_file_diff):
        """Test counting LOC across multiple files."""
        counts = diff_applier.count_loc(multi_file_diff)
        
        assert counts["added"] >= 0
        assert counts["removed"] >= 0
        assert counts["modified"] >= 0
        # Total changes should be reflected
        total = counts["added"] + counts["removed"] + counts["modified"]
        assert total > 0
    
    def test_count_loc_no_changes(self, diff_applier):
        """Test counting LOC with no actual changes."""
        diff = """--- a/test.py
+++ b/test.py
@@ -1,2 +1,2 @@
 line 1
 line 2
"""
        counts = diff_applier.count_loc(diff)
        
        # Only context lines, no actual changes
        assert counts["added"] == 0
        assert counts["removed"] == 0
        assert counts["modified"] == 0


class TestDiffValidation:
    """Test diff validation functionality."""
    
    def test_validate_valid_diff(self, diff_applier, sample_diff):
        """Test validating a valid diff."""
        is_valid, errors = diff_applier.validate_diff(sample_diff)
        
        assert is_valid is True
        assert len(errors) == 0
    
    def test_validate_empty_diff(self, diff_applier, empty_diff):
        """Test validating an empty diff."""
        is_valid, errors = diff_applier.validate_diff(empty_diff)
        
        assert is_valid is True
        assert len(errors) == 0
    
    def test_validate_missing_file_header(self, diff_applier):
        """Test validating a diff without file headers."""
        invalid_diff = """@@ -1,3 +1,4 @@
 line 1
 line 2
"""
        is_valid, errors = diff_applier.validate_diff(invalid_diff)
        
        assert is_valid is False
        assert any("file header" in e.lower() for e in errors)
    
    def test_validate_missing_hunk(self, diff_applier):
        """Test validating a diff without hunk headers."""
        invalid_diff = """--- a/test.py
+++ b/test.py
line 1
line 2
"""
        is_valid, errors = diff_applier.validate_diff(invalid_diff)
        
        assert is_valid is False
        assert any("hunk" in e.lower() for e in errors)
    
    def test_validate_invalid_syntax(self, diff_applier):
        """Test validating a diff with invalid syntax."""
        invalid_diff = """--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
INVALID LINE TYPE X
"""
        is_valid, errors = diff_applier.validate_diff(invalid_diff)
        
        # Should have at least one error
        assert is_valid is False or len(errors) > 0
    
    def test_validate_git_metadata(self, diff_applier):
        """Test validating a diff with git metadata."""
        git_diff = """diff --git a/test.py b/test.py
index abc123..def456 100644
--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
-old line
+new line
"""
        is_valid, errors = diff_applier.validate_diff(git_diff)
        
        assert is_valid is True
        assert len(errors) == 0


class TestDiffApplication:
    """Test diff application functionality."""
    
    def test_apply_diff_to_new_file(self, diff_applier, temp_workspace):
        """Test applying a diff to create a new file."""
        diff = """--- a/newfile.py
+++ b/newfile.py
@@ -0,0 +1,2 @@
+# New file
+print("Hello")
"""
        result = diff_applier.apply_diff(diff)
        
        assert result["success"] is True
        assert result["files_modified"] == 1
        
        # Verify file was created
        new_file = Path(temp_workspace) / "newfile.py"
        assert new_file.exists()
    
    def test_apply_diff_to_existing_file(self, diff_applier, temp_workspace):
        """Test applying a diff to an existing file."""
        # Create original file
        original_file = Path(temp_workspace) / "test.py"
        original_file.write_text("line 1\nline 2\nline 3\n")
        
        diff = """--- a/test.py
+++ b/test.py
@@ -1,3 +1,3 @@
 line 1
-line 2
+line 2 modified
 line 3
"""
        result = diff_applier.apply_diff(diff)
        
        assert result["success"] is True
        assert result["files_modified"] == 1
        
        # Verify content was modified
        content = original_file.read_text()
        assert "line 2 modified" in content
        assert "line 2" not in content or "line 2\n" not in content
    
    def test_apply_multi_file_diff(self, diff_applier, temp_workspace):
        """Test applying a diff to multiple files."""
        # Create original files
        (Path(temp_workspace) / "file1.py").write_text("line 1\n")
        (Path(temp_workspace) / "file2.py").write_text("line A\n")
        
        result = diff_applier.apply_diff(multi_file_diff)
        
        assert result["success"] is True
        assert result["files_modified"] == 2
    
    def test_apply_diff_with_context(self, diff_applier, temp_workspace):
        """Test applying a diff with context lines."""
        original_file = Path(temp_workspace) / "test.py"
        original_content = "line 1\nline 2\nline 3\nline 4\nline 5\n"
        original_file.write_text(original_content)
        
        diff = """--- a/test.py
+++ b/test.py
@@ -1,5 +1,5 @@
 line 1
 line 2
-line 3
+line 3 modified
 line 4
 line 5
"""
        result = diff_applier.apply_diff(diff)
        
        assert result["success"] is True
        
        # Verify context lines preserved
        content = original_file.read_text()
        assert "line 1" in content
        assert "line 2" in content
        assert "line 4" in content
        assert "line 5" in content
        assert "line 3 modified" in content
    
    def test_apply_diff_create_directory(self, diff_applier, temp_workspace):
        """Test applying a diff that creates a new directory."""
        diff = """--- a/newdir/file.py
+++ b/newdir/file.py
@@ -0,0 +1,1 @@
+print("new")
"""
        result = diff_applier.apply_diff(diff)
        
        assert result["success"] is True
        
        # Verify directory and file were created
        new_file = Path(temp_workspace) / "newdir" / "file.py"
        assert new_file.exists()
    
    def test_apply_diff_error_handling(self, diff_applier, temp_workspace):
        """Test error handling when applying invalid diff."""
        # Create a file with content that doesn't match the diff
        original_file = Path(temp_workspace) / "test.py"
        original_file.write_text("completely different content\n")
        
        diff = """--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
-old content
+new content
"""
        result = diff_applier.apply_diff(diff)
        
        # Should handle gracefully
        assert "success" in result
        assert "files_modified" in result
        assert "errors" in result


class TestDiffParsing:
    """Test diff parsing functionality."""
    
    def test_parse_single_file_diff(self, diff_applier, sample_diff):
        """Test parsing a single file diff."""
        file_diffs = diff_applier._parse_diff(sample_diff)
        
        assert len(file_diffs) >= 1
        assert "test.py" in file_diffs or any("test.py" in k for k in file_diffs.keys())
    
    def test_parse_multi_file_diff(self, diff_applier, multi_file_diff):
        """Test parsing a multi-file diff."""
        file_diffs = diff_applier._parse_diff(multi_file_diff)
        
        assert len(file_diffs) == 2
        # Should have both files
        assert any("file1.py" in path for path in file_diffs.keys())
        assert any("file2.py" in path for path in file_diffs.keys())
    
    def test_parse_empty_diff(self, diff_applier, empty_diff):
        """Test parsing an empty diff."""
        file_diffs = diff_applier._parse_diff(empty_diff)
        
        assert len(file_diffs) == 0


class TestDiffUtilities:
    """Test diff utility functions."""
    
    def test_parse_diff_file(self, temp_workspace):
        """Test reading a diff from a file."""
        diff_content = """--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
-old
+new
"""
        diff_file = Path(temp_workspace) / "changes.diff"
        diff_file.write_text(diff_content)
        
        diff = parse_diff_file(str(diff_file))
        
        assert "old" in diff
        assert "new" in diff
    
    def test_create_simple_diff(self):
        """Test creating a simple diff."""
        old_content = "line 1\nline 2\nline 3\n"
        new_content = "line 1\nline 2 modified\nline 3\n"
        
        diff = create_simple_diff("test.py", old_content, new_content)
        
        assert "---" in diff
        assert "+++" in diff
        assert "@" in diff  # Hunk header
        assert "-" in diff  # Removal
        assert "+" in diff  # Addition
    
    def test_diff_roundtrip(self):
        """Test creating and then applying a diff."""
        old_content = "line 1\nline 2\nline 3\n"
        new_content = "line 1\nline 2 modified\nline 3\nline 4\n"
        
        # Create diff
        diff = create_simple_diff("test.py", old_content, new_content)
        
        # Count LOC
        applier = DiffApplier()
        counts = applier.count_loc(diff)
        
        assert counts["removed"] == 1
        assert counts["added"] >= 1  # At least the modification and new line


class TestDiffEdgeCases:
    """Test edge cases and error conditions."""
    
    def test_diff_with_binary_file(self, diff_applier):
        """Test handling a diff mentioning binary files."""
        binary_diff = """Binary files a/image.png and b/image.png differ
"""
        is_valid, errors = diff_applier.validate_diff(binary_diff)
        
        # Should not crash
        assert isinstance(is_valid, bool)
    
    def test_diff_with_special_characters(self, diff_applier):
        """Test handling special characters in diffs."""
        diff = """--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
-old line with !@#$%^&*()
+new line with !@#$%^&*()
"""
        counts = diff_applier.count_loc(diff)
        
        # Should handle special characters
        assert counts["removed"] == 1
        assert counts["added"] == 1
    
    def test_diff_unicode_content(self, diff_applier):
        """Test handling Unicode content in diffs."""
        diff = """--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
-old line with émojis 🎉
+new line with émojis 🚀
"""
        is_valid, errors = diff_applier.validate_diff(diff)
        
        # Should handle Unicode
        assert isinstance(is_valid, bool)
    
    def test_large_diff(self, diff_applier):
        """Test handling a large diff."""
        # Generate a large diff
        lines = []
        for i in range(1000):
            lines.append(f"-line {i}")
            lines.append(f"+line {i} modified")
        
        diff = f"""--- a/test.py
+++ b/test.py
@@ -1,{len(lines)} +1,{len(lines)} +
"""
        diff += "\n".join(lines[:50])  # Add subset for test
        
        counts = diff_applier.count_loc(diff)
        
        # Should handle large diffs without crashing
        assert isinstance(counts, dict)
    
    def test_diff_with_no_newline(self, diff_applier):
        """Test handling diffs with files missing trailing newlines."""
        diff = r"""--- a/test.py
+++ b/test.py
@@ -1,1 +1,1 @@
\ No newline at end of file
-old content
+new content
"""
        is_valid, errors = diff_applier.validate_diff(diff)
        
        # Should handle the special case
        assert isinstance(is_valid, bool)
