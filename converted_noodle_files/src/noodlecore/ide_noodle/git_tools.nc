# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Git Integration Tools
# Pure-Python Git helpers with attribute-gated operations and AI context builders.
# """

import subprocess
import os
import json
import pathlib.Path
import typing.Dict,


class NoodleCoreGitTools
    #     """
    #     NoodleCore-native Git integration tools.
    #     Provides safe, deterministic Git operations with attribute gating.
    #     """

    #     def __init__(self, noodle_attributes: Dict[str, Any] = None):
    self.noodle_attributes = noodle_attributes or {}
    self._git_available = None

    #     def _is_git_enabled(self) -> bool:
    #         """Check if git_integration attribute is enabled."""
    git_attr = self.noodle_attributes.get('git_integration', {})
            return git_attr.get('enabled', False)

    #     def _is_git_repo(self, path: Path = None) -> bool:
    #         """Check if current directory is a Git repository."""
    #         if path is None:
    path = Path.cwd()

    git_dir = path / '.git'
            return git_dir.exists() and git_dir.is_dir()

    #     def _run_git_command(self, args: List[str], timeout: int = 10) -> Dict[str, Any]:
    #         """
    #         Run a Git command safely with timeout and error handling.

    #         Args:
    #             args: Git command arguments
    #             timeout: Command timeout in seconds

    #         Returns:
    #             Dictionary with success, stdout, stderr, and error message
    #         """
    #         if not self._is_git_enabled():
    #             return {
    #                 'success': False,
    #                 'stdout': '',
    #                 'stderr': '',
    #                 'error': 'Git integration is disabled in NoodleCore attributes'
    #             }

    #         if not self._is_git_repo():
    #             return {
    #                 'success': False,
    #                 'stdout': '',
    #                 'stderr': '',
    #                 'error': 'Not a Git repository'
    #             }

    #         try:
    #             # Run git command with timeout
    result = subprocess.run(
    #                 ['git'] + args,
    capture_output = True,
    text = True,
    timeout = timeout,
    cwd = Path.cwd()
    #             )

    #             return {
    'success': result.returncode = = 0,
                    'stdout': result.stdout.strip(),
                    'stderr': result.stderr.strip(),
    #                 'error': None
    #             }

    #         except subprocess.TimeoutExpired:
    #             return {
    #                 'success': False,
    #                 'stdout': '',
    #                 'stderr': '',
    #                 'error': f'Git command timed out after {timeout} seconds'
    #             }
    #         except FileNotFoundError:
    #             return {
    #                 'success': False,
    #                 'stdout': '',
    #                 'stderr': '',
    #                 'error': 'Git command not found. Please install Git.'
    #             }
    #         except Exception as e:
    #             return {
    #                 'success': False,
    #                 'stdout': '',
    #                 'stderr': '',
                    'error': f'Git command error: {str(e)}'
    #             }

    #     def get_status(self) -> Dict[str, Any]:
    #         """
    #         Get Git repository status.

    #         Returns:
    #             Dictionary with status information
    #         """
    result = self._run_git_command(['status', '--porcelain'])

    #         if not result['success']:
    #             return {
    #                 'success': False,
    #                 'error': result['error'],
    #                 'files': [],
    #                 'branch': 'unknown',
    #                 'clean': False
    #             }

    #         # Parse git status output
    #         lines = result['stdout'].split('\n') if result['stdout'] else []
    files = []

    #         for line in lines:
    #             if line.strip():
    status_code = line[:2]
    file_path = line[3:]
                    files.append({
    #                     'status': status_code,
    #                     'file': file_path,
    'staged': status_code[0] ! = ' ' and status_code[0] != '?',
    'modified': status_code[1] ! = ' '
    #                 })

    #         # Get current branch
    branch_result = self._run_git_command(['rev-parse', '--abbrev-ref', 'HEAD'])
    #         branch = branch_result['stdout'] if branch_result['success'] else 'unknown'

    #         return {
    #             'success': True,
    #             'files': files,
    #             'branch': branch,
    'clean': len(files) = = 0,
    #             'summary': f"On branch '{branch}'" + (", working directory clean" if len(files) == 0 else f", {len(files)} modified files")
    #         }

    #     def get_recent_commits(self, limit: int = 20) -> Dict[str, Any]:
    #         """
    #         Get recent commits from the repository.

    #         Args:
    #             limit: Maximum number of commits to retrieve

    #         Returns:
    #             Dictionary with commit information
    #         """
    result = self._run_git_command([
    #             'log',
    #             '--oneline',
    f'--max-count = {limit}',
    '--pretty = format:%H|%s|%an|%ad',
    '--date = short'
    #         ])

    #         if not result['success']:
    #             return {
    #                 'success': False,
    #                 'error': result['error'],
    #                 'commits': []
    #             }

    commits = []
    #         lines = result['stdout'].split('\n') if result['stdout'] else []

    #         for line in lines:
    #             if line.strip():
    parts = line.split('|', 3)
    #                 if len(parts) >= 4:
                        commits.append({
    #                         'hash': parts[0][:8],  # Short hash
    #                         'message': parts[1],
    #                         'author': parts[2],
    #                         'date': parts[3]
    #                     })

    #         return {
    #             'success': True,
    #             'commits': commits,
                'summary': f"Found {len(commits)} recent commits"
    #         }

    #     def get_diff_summary(self) -> Dict[str, Any]:
    #         """
    #         Get diff summary with statistics.

    #         Returns:
    #             Dictionary with diff information
    #         """
    result = self._run_git_command(['diff', '--stat'])

    #         if not result['success']:
    #             return {
    #                 'success': False,
    #                 'error': result['error'],
    #                 'summary': 'No diff available'
    #             }

    output = result['stdout']
    #         if not output:
    #             return {
    #                 'success': True,
    #                 'summary': 'No changes to show',
    #                 'files_changed': 0,
    #                 'insertions': 0,
    #                 'deletions': 0
    #             }

    #         # Parse diff statistics
    lines = output.split('\n')
    files_changed = 0
    insertions = 0
    deletions = 0

    #         for line in lines:
    #             if '|' in line and ('+' in line or '-' in line):
    files_changed + = 1
    #                 # Extract insertion/deletion counts
    parts = line.split('|')
    #                 if len(parts) > 1:
    stats = parts[1].strip()
    #                     if '+' in stats or '-' in stats:
                            # Parse something like "5 insertions(+), 2 deletions(-)"
    #                         for part in stats.split(','):
    part = part.strip()
    #                             if 'insertion' in part:
    insertions + = int(part.split()[0])
    #                             elif 'deletion' in part:
    deletions + = int(part.split()[0])

    #         return {
    #             'success': True,
    #             'summary': output,
    #             'files_changed': files_changed,
    #             'insertions': insertions,
    #             'deletions': deletions,
    #             'total_changes': insertions + deletions
    #         }

    #     def build_git_context_summary(self) -> str:
    #         """
    #         Build AI-friendly Git context summary.

    #         Returns:
    #             Formatted string with Git context for AI analysis
    #         """
    #         if not self._is_git_enabled():
    #             return "Git integration is disabled in NoodleCore attributes."

    #         if not self._is_git_repo():
    #             return "Current directory is not a Git repository."

    #         # Get status, commits, and diff
    status = self.get_status()
    commits = self.get_recent_commits(limit=5)
    diff = self.get_diff_summary()

    summary_parts = []
    summary_parts.append(" = == NOODLECORE GIT CONTEXT ===")

    #         # Add status information
    #         if status['success']:
                summary_parts.append(f"Status: {status['summary']}")
    #             if status['files']:
                    summary_parts.append("Modified files:")
    #                 for file_info in status['files'][:10]:  # Limit to 10 files
                        summary_parts.append(f"  {file_info['status']} {file_info['file']}")

    #         # Add recent commits
    #         if commits['success'] and commits['commits']:
                summary_parts.append("\nRecent commits:")
    #             for commit in commits['commits'][:5]:  # Limit to 5 commits
                    summary_parts.append(f"  {commit['hash']} {commit['message']} ({commit['author']}, {commit['date']})")

    #         # Add diff summary
    #         if diff['success']:
                summary_parts.append(f"\nDiff: {diff['summary']}")

    summary_parts.append("\n = == END GIT CONTEXT ===")

            return '\n'.join(summary_parts)


# Handler functions for NoodleCommandRuntime
def get_git_status(context: Dict[str, Any]) -> Dict[str, Any]:
#     """Handler for git.status command"""
#     try:
project_path = context.get('project_path', str(Path.cwd()))
include_untracked = context.get('include_untracked', True)

#         # Create git tools instance
git_tools = NoodleCoreGitTools()

#         # Change to project directory if specified
original_cwd = None
#         if project_path and project_path != str(Path.cwd()):
original_cwd = Path.cwd()
            os.chdir(project_path)

#         try:
#             # Get status
status = git_tools.get_status()

#             # Format result for command runtime
#             if status['success']:
#                 return {
#                     'branch': status['branch'],
#                     'status': {
#                         'clean': status['clean'],
                        'files_count': len(status['files'])
#                     },
#                     'changes': status['files']
#                 }
#             else:
#                 return {
#                     'branch': 'unknown',
#                     'status': {'clean': False, 'files_count': 0},
#                     'changes': [],
#                     'error': status['error']
#                 }
#         finally:
#             # Restore original directory
#             if original_cwd:
                os.chdir(original_cwd)

#     except Exception as e:
#         return {
#             'branch': 'unknown',
#             'status': {'clean': False, 'files_count': 0},
#             'changes': [],
            'error': str(e)
#         }


def get_recent_commits(context: Dict[str, Any]) -> Dict[str, Any]:
#     """Handler for git.recent_commits command"""
#     try:
project_path = context.get('project_path', str(Path.cwd()))
limit = context.get('limit', 20)

#         # Create git tools instance
git_tools = NoodleCoreGitTools()

#         # Change to project directory if specified
original_cwd = None
#         if project_path and project_path != str(Path.cwd()):
original_cwd = Path.cwd()
            os.chdir(project_path)

#         try:
#             # Get recent commits
commits_result = git_tools.get_recent_commits(limit=limit)

#             # Format result for command runtime
#             if commits_result['success']:
#                 return {
#                     'commits': commits_result['commits'],
                    'total_count': len(commits_result['commits'])
#                 }
#             else:
#                 return {
#                     'commits': [],
#                     'total_count': 0,
#                     'error': commits_result['error']
#                 }
#         finally:
#             # Restore original directory
#             if original_cwd:
                os.chdir(original_cwd)

#     except Exception as e:
#         return {
#             'commits': [],
#             'total_count': 0,
            'error': str(e)
#         }


def get_diff_summary(context: Dict[str, Any]) -> Dict[str, Any]:
#     """Handler for git.diff_summary command"""
#     try:
project_path = context.get('project_path', str(Path.cwd()))
file_path = context.get('file_path', '')
commit_range = context.get('commit_range', '')

#         # Create git tools instance
git_tools = NoodleCoreGitTools()

#         # Change to project directory if specified
original_cwd = None
#         if project_path and project_path != str(Path.cwd()):
original_cwd = Path.cwd()
            os.chdir(project_path)

#         try:
#             # Get diff summary
diff_result = git_tools.get_diff_summary()

#             # Format result for command runtime
#             if diff_result['success']:
#                 return {
#                     'summary': diff_result['summary'],
#                     'changes': {
#                         'files_changed': diff_result['files_changed'],
#                         'insertions': diff_result['insertions'],
#                         'deletions': diff_result['deletions'],
#                         'total_changes': diff_result['total_changes']
#                     },
#                     'affected_files': []  # Would need additional git commands to populate
#                 }
#             else:
#                 return {
#                     'summary': 'No diff available',
#                     'changes': {
#                         'files_changed': 0,
#                         'insertions': 0,
#                         'deletions': 0,
#                         'total_changes': 0
#                     },
#                     'affected_files': [],
#                     'error': diff_result['error']
#                 }
#         finally:
#             # Restore original directory
#             if original_cwd:
                os.chdir(original_cwd)

#     except Exception as e:
#         return {
#             'summary': 'Error getting diff',
#             'changes': {
#                 'files_changed': 0,
#                 'insertions': 0,
#                 'deletions': 0,
#                 'total_changes': 0
#             },
#             'affected_files': [],
            'error': str(e)
#         }