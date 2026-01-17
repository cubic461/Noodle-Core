"""Diff application and LOC counting utilities.

This module provides functionality for applying unified diffs to files
and counting lines of code changes.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple


class DiffApplier:
    """Applies unified diffs to files and counts LOC changes.
    
    Supports standard unified diff format for applying patches
    and calculating statistics about code changes.
    
    Attributes:
        base_path: Base directory for resolving file paths
    """
    
    def __init__(self, base_path: str = "."):
        """Initialize the diff applier.
        
        Args:
            base_path: Base directory for file operations
        """
        self.base_path = Path(base_path)
    
    def apply_diff(self, diff: str) -> Dict[str, any]:
        """Apply a unified diff to files.
        
        Args:
            diff: Unified diff string
            
        Returns:
            Dictionary with apply results including success status
        """
        if not diff or not diff.strip():
            return {"success": True, "files_modified": 0}
        
        files_modified = 0
        errors = []
        
        # Parse and apply each file's diff
        file_diffs = self._parse_diff(diff)
        
        for file_path, file_diff in file_diffs.items():
            full_path = self.base_path / file_path
            try:
                self._apply_file_diff(full_path, file_diff)
                files_modified += 1
            except Exception as e:
                errors.append(f"{file_path}: {str(e)}")
        
        return {
            "success": len(errors) == 0,
            "files_modified": files_modified,
            "errors": errors
        }
    
    def count_loc(self, diff: str) -> Dict[str, int]:
        """Count lines of code changes in a diff.
        
        Args:
            diff: Unified diff string
            
        Returns:
            Dictionary with added, removed, and modified line counts
        """
        if not diff or not diff.strip():
            return {"added": 0, "removed": 0, "modified": 0}
        
        added = 0
        removed = 0
        
        lines = diff.split('\n')
        for line in lines:
            if line.startswith('+') and not line.startswith('+++'):
                added += 1
            elif line.startswith('-') and not line.startswith('---'):
                removed += 1
        
        # Modified is an approximation - minimum of added and removed
        modified = min(added, removed)
        added -= modified
        removed -= modified
        
        return {
            "added": added,
            "removed": removed,
            "modified": modified
        }
    
    def _parse_diff(self, diff: str) -> Dict[str, List[str]]:
        """Parse a unified diff into per-file chunks.
        
        Args:
            diff: Unified diff string
            
        Returns:
            Dictionary mapping file paths to their diff chunks
        """
        file_diffs = {}
        current_file = None
        current_diff = []
        
        lines = diff.split('\n')
        i = 0
        
        while i < len(lines):
            line = lines[i]
            
            # Look for file header lines
            if line.startswith('--- '):
                if current_file and current_diff:
                    file_diffs[current_file] = current_diff
                
                # Extract file path from next line (+++ line)
                if i + 1 < len(lines) and lines[i + 1].startswith('+++ '):
                    file_path = lines[i + 1][4:].strip().split('\t')[0]
                    # Remove a/ prefix if present
                    if file_path.startswith('a/'):
                        file_path = file_path[2:]
                    current_file = file_path
                    current_diff = []
                    i += 2
                    continue
            
            if current_file:
                current_diff.append(line)
            
            i += 1
        
        if current_file and current_diff:
            file_diffs[current_file] = current_diff
        
        return file_diffs
    
    def _apply_file_diff(self, file_path: Path, diff_lines: List[str]) -> None:
        """Apply a diff to a single file.
        
        Args:
            file_path: Path to the file
            diff_lines: List of diff lines for this file
        """
        if not file_path.exists():
            # Create parent directories
            file_path.parent.mkdir(parents=True, exist_ok=True)
            original_lines = []
        else:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_lines = f.readlines()
        
        # Apply hunks
        new_lines = self._apply_hunks(original_lines, diff_lines)
        
        # Write the modified content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
    
    def _apply_hunks(self, original_lines: List[str], diff_lines: List[str]) -> List[str]:
        """Apply diff hunks to original content.
        
        Args:
            original_lines: Original file lines
            diff_lines: Diff lines containing hunks
            
        Returns:
            Modified lines
        """
        result = original_lines.copy()
        line_offset = 0
        
        i = 0
        while i < len(diff_lines):
            line = diff_lines[i]
            
            # Look for hunk header
            hunk_match = re.match(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@', line)
            if hunk_match:
                old_start = int(hunk_match.group(1)) - 1  # Convert to 0-indexed
                old_count = int(hunk_match.group(2)) if hunk_match.group(2) else 1
                new_start = int(hunk_match.group(3)) - 1
                new_count = int(hunk_match.group(4)) if hunk_match.group(4) else 1
                
                # Collect hunk lines
                hunk_lines = []
                i += 1
                while i < len(diff_lines):
                    hunk_line = diff_lines[i]
                    if hunk_line.startswith('@@') or hunk_line.startswith('---') or hunk_line.startswith('+++'):
                        break
                    hunk_lines.append(hunk_line)
                    i += 1
                
                # Apply this hunk
                result = self._apply_hunk(result, old_start + line_offset, hunk_lines)
                
                # Update offset for next hunk
                offset_change = len([l for l in hunk_lines if l.startswith('+')]) - \
                               len([l for l in hunk_lines if l.startswith('-')])
                line_offset += offset_change
            else:
                i += 1
        
        return result
    
    def _apply_hunk(self, lines: List[str], start_line: int, hunk_lines: List[str]) -> List[str]:
        """Apply a single hunk to lines.
        
        Args:
            lines: Original lines
            start_line: Starting line for the hunk
            hunk_lines: Lines in the hunk
            
        Returns:
            Modified lines
        """
        result = []
        i = 0
        hunk_idx = 0
        
        while i < len(lines):
            if i == start_line:
                # Apply hunk at this position
                for hunk_line in hunk_lines:
                    if hunk_line.startswith('+'):
                        # Add new line (without the + prefix)
                        result.append(hunk_line[1:] + '\n')
                    elif hunk_line.startswith(' '):
                        # Context line - keep original
                        result.append(lines[i])
                        i += 1
                    elif hunk_line.startswith('-'):
                        # Remove line - skip original
                        i += 1
            else:
                result.append(lines[i])
                i += 1
        
        return result
    
    def validate_diff(self, diff: str) -> Tuple[bool, List[str]]:
        """Validate a diff format.
        
        Args:
            diff: Diff string to validate
            
        Returns:
            Tuple of (is_valid, list_of_errors)
        """
        errors = []
        
        if not diff or not diff.strip():
            return True, errors
        
        lines = diff.split('\n')
        has_file_header = False
        has_hunk = False
        
        for i, line in enumerate(lines):
            if line.startswith('--- ') or line.startswith('+++ '):
                has_file_header = True
            elif line.startswith('@@'):
                has_hunk = True
            elif line.startswith('+') and not line.startswith('+++'):
                pass  # Valid addition line
            elif line.startswith('-') and not line.startswith('---'):
                pass  # Valid removal line
            elif line.startswith(' '):
                pass  # Valid context line
            elif line.startswith('diff '):
                pass  # Valid diff command
            elif line.startswith('index ') or line.startswith('new file ') or line.startswith('deleted file '):
                pass  # Valid git metadata
            elif not line.strip():
                pass  # Empty line is fine
            else:
                errors.append(f"Line {i + 1}: Invalid diff syntax: {line[:50]}")
        
        if not has_file_header:
            errors.append("No file header found (expected ---/+++ lines)")
        
        if not has_hunk:
            errors.append("No hunk headers found (expected @@ lines)")
        
        return len(errors) == 0, errors


def parse_diff_file(diff_path: str) -> str:
    """Read a diff from a file.
    
    Args:
        diff_path: Path to the diff file
        
    Returns:
        Diff content as string
        
    Raises:
        FileNotFoundError: If file doesn't exist
    """
    with open(diff_path, 'r', encoding='utf-8') as f:
        return f.read()


def create_simple_diff(file_path: str, old_content: str, new_content: str) -> str:
    """Create a simple diff between two contents.
    
    Args:
        file_path: Path for display in diff header
        old_content: Original content
        new_content: New content
        
    Returns:
        Unified diff string
    """
    import difflib
    
    old_lines = old_content.splitlines(keepends=True)
    new_lines = new_content.splitlines(keepends=True)
    
    diff = difflib.unified_diff(
        old_lines,
        new_lines,
        fromfile=f"a/{file_path}",
        tofile=f"b/{file_path}",
        lineterm=''
    )
    
    return ''.join(diff)
