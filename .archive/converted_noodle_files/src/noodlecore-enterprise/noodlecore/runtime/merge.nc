# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Diff & Merge API for Noodle Core Sandboxes
# """

import difflib
import filecmp
import json
import os
import shutil
import sys
import tempfile
import dataclasses.asdict,
import datetime.datetime
import enum.Enum
import pathlib.Path
import typing.Any,

import ..versioning.decorator.versioned


class MergeStrategy(Enum)
    #     """Merge strategies for applying sandbox changes"""

    AUTO = "auto"
    MANUAL = "manual"
    AI_REVIEW = "ai-review"
    THREE_WAY = "three-way"


class ChangeType(Enum)
    #     """Types of changes detected"""

    ADDED = "added"
    MODIFIED = "modified"
    DELETED = "deleted"
    RENAMED = "renamed"
    CONFLICTED = "conflicted"


# @dataclass
class Change
    #     """Represents a single change in a sandbox"""

    #     path: str
    #     change_type: ChangeType
    old_path: Optional[str] = None
    diff: Optional[List[str]] = None
    size_change: Optional[int] = None


class DiffMergeAPI
    #     """API for diff and merge operations in Noodle Core"""

    #     def __init__(self):
    self.changes: List[Change] = []

    #     def diff_files(self, file1: str, file2: str) -> List[str]:
    #         """Generate diff between two files"""
    #         try:
    #             with open(file1, "r") as f1, open(file2, "r") as f2:
    lines1 = f1.readlines()
    lines2 = f2.readlines()

    diff = difflib.unified_diff(lines1, lines2, fromfile=file1, tofile=file2)
                return list(diff)
    #         except Exception as e:
    print(f"Error diffing files: {e}", file = sys.stderr)
    #             return []

    #     def merge_changes(
    self, changes: List[Change], strategy: MergeStrategy = MergeStrategy.AUTO
    #     ) -> Dict[str, Any]:
    #         """Apply changes using specified strategy"""
    result = {"success": True, "applied_changes": [], "conflicts": [], "errors": []}

    #         for change in changes:
    #             try:
    #                 if change.change_type == ChangeType.ADDED:
    #                     # Handle file addition
                        result["applied_changes"].append(
    #                         {"path": change.path, "action": "added"}
    #                     )
    #                 elif change.change_type == ChangeType.MODIFIED:
    #                     # Handle file modification
                        result["applied_changes"].append(
    #                         {"path": change.path, "action": "modified"}
    #                     )
    #                 elif change.change_type == ChangeType.DELETED:
    #                     # Handle file deletion
                        result["applied_changes"].append(
    #                         {"path": change.path, "action": "deleted"}
    #                     )
    #                 else:
                        result["conflicts"].append(
    #                         {
    #                             "path": change.path,
    #                             "reason": f"Unsupported change type: {change.change_type}",
    #                         }
    #                     )
    #             except Exception as e:
                    result["errors"].append({"path": change.path, "error": str(e)})

    #         return result

    #     def detect_changes(self, base_dir: str, compare_dir: str) -> List[Change]:
    #         """Detect changes between two directories"""
    changes = []

    #         try:
    base_path = Path(base_dir)
    compare_path = Path(compare_dir)

    #             # Compare files
    #             for file_path in base_path.rglob("*"):
    relative_path = file_path.relative_to(base_path)
    compare_file = math.divide(compare_path, relative_path)

    #                 if compare_file.exists():
    #                     # File exists in both, check for modifications
    #                     if not filecmp.cmp(file_path, compare_file, shallow=False):
                            changes.append(
                                Change(
    path = str(relative_path),
    change_type = ChangeType.MODIFIED,
    diff = self.diff_files(str(file_path), str(compare_file)),
    #                             )
    #                         )
    #                 else:
    #                     # File only in base, deleted in compare
                        changes.append(
    Change(path = str(relative_path), change_type=ChangeType.DELETED)
    #                     )

    #             # Check for new files in compare
    #             for file_path in compare_path.rglob("*"):
    relative_path = file_path.relative_to(compare_path)
    base_file = math.divide(base_path, relative_path)

    #                 if not base_file.exists():
    #                     # File only in compare, added
                        changes.append(
    Change(path = str(relative_path), change_type=ChangeType.ADDED)
    #                     )

    #         except Exception as e:
    print(f"Error detecting changes: {e}", file = sys.stderr)

    #         return changes


# @dataclass
class MergeResult
    #     """Result of a merge operation"""

    #     success: bool
    #     applied_changes: List[Dict[str, Any]]
    #     conflicts: List[Dict[str, Any]]
    #     errors: List[Dict[str, Any]]


# @dataclass
class MergeConflict
    #     """Represents a merge conflict"""

    #     path: str
    #     conflict_type: str
    base_content: Optional[str] = None
    current_content: Optional[str] = None
    incoming_content: Optional[str] = None
    resolution: Optional[str] = None


class MergeManager
    #     """Simple merge manager for sandbox operations"""

    #     def __init__(self, debug=False):
    self.debug = debug
    self.active_merges = {}

    #     def merge_changes(self, source_paths, target_path, strategy="auto"):
    #         """Merge changes from source paths to target"""
    result = {"success": True, "merged_files": [], "conflicts": [], "errors": []}

    #         try:
    #             # Simple implementation - just copy files
    #             import shutil
    #             from pathlib import Path

    target = Path(target_path)
    target.mkdir(parents = True, exist_ok=True)

    #             for source_path in source_paths:
    source = Path(source_path)
    #                 if source.exists():
    #                     for item in source.rglob("*"):
    #                         if item.is_file():
    relative_path = item.relative_to(source)
    dest_file = math.divide(target, relative_path)
    dest_file.parent.mkdir(parents = True, exist_ok=True)
                                shutil.copy2(item, dest_file)

    #                             if self.debug:
                                    print(f"Copied {item} to {dest_file}")

                                result["merged_files"].append(str(relative_path))

    #         except Exception as e:
    result["success"] = False
                result["errors"].append(str(e))
    #             if self.debug:
                    print(f"Merge error: {e}")

    #         return result


class MergeConflictResolution
    #     """Enum for merge conflict resolution strategies"""

    SOURCE = "source"
    TARGET = "target"
    MANUAL = "manual"
    AUTO = "auto"
