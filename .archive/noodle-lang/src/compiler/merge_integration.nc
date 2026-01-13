# Converted from Python to NoodleCore
# Original file: src

# """
# Merge Integration for Async Operations in Noodle Core

# Integrates the merge system with the async runtime to allow
# consolidation of changes from multiple sandboxes.
# """

import asyncio
import difflib
from dataclasses import dataclass
import enum.Enum
import pathlib.Path
import typing.Any

import noodlecore.runtime.merge.MergeConflictResolution

import ...project_manager.ProjectManager
import ...sandbox.SandboxManager
import .conditional_imports.import_manager

async_module = import_manager.lazy_import(
#     "noodle.runtime.nbc_runtime.core.async_runtime"
# )
# AsyncRuntime = async_module.AsyncNBCRuntime if async_module else None

# Create a simple AsyncHandle class if it doesn't exist
if async_module and hasattr(async_module, "AsyncHandle")
    AsyncHandle = async_module.AsyncHandle
else

    #     class AsyncHandle:
    #         pass

    #     AsyncHandle = AsyncHandle if async_module else None

sandbox_module = import_manager.lazy_import(
#     "noodle.runtime.nbc_runtime.core.sandbox_integration"
# )
# SandboxAsyncManager = sandbox_module.SandboxAsyncManager if sandbox_module else None

compiler_module = import_manager.lazy_import("noodle.compiler.code_generator")
# CodeGenerator = compiler_module.CodeGenerator if compiler_module else None
# OpCode = compiler_module.OpCode if compiler_module else None


class MergeStrategy(Enum)
    #     """Merge strategies for async operations"""

    AUTO = "auto"
    MANUAL = "manual"
    AI_REVIEW = "ai_review"
    MAJORITY_VOTE = "majority_vote"
    SEQUENTIAL = "sequential"


dataclass
class MergeOperation
    #     """Represents a merge operation between sandboxes"""

    #     merge_id: str
    #     source_sandbox_ids: List[str]
    #     target_sandbox_id: str
    #     strategy: MergeStrategy
    status: str = "pending"
    conflicts: List[Dict[str, Any]] = field(default_factory=list)
    resolved_files: Dict[str, str] = field(
    default_factory = dict
    #     )  # file_path -resolution
    created_files): List[str] = field(default_factory=list)
    modified_files: List[str] = field(default_factory=list)
    deleted_files: List[str] = field(default_factory=list)
    start_time: float = 0.0
    end_time: Optional[float] = None
    merge_result: Optional[Dict[str, Any]] = None
    gpu: bool = False


dataclass
class FileDiff
    #     """Represents a diff between two files"""

    #     file_path: str
    source_content: Optional[str] = None
    target_content: Optional[str] = None
    diff_lines: List[str] = field(default_factory=list)
    change_type: str = "modified"  # "added", "modified", "deleted"


class AsyncMergeManager
    #     """Manages merge operations for async sandboxed operations"""

    #     def __init__(
    #         self,
    merge_timeout: float = 60.0,
    max_concurrent_merges: int = 5,
    debug: bool = False,
    #     ):
    self.merge_timeout = merge_timeout
    self.max_concurrent_merges = max_concurrent_merges
    self.debug = debug

    #         # Core components
    self.merge_manager = MergeManager()
    #         if SandboxAsyncManager:
    self.sandbox_manager = SandboxAsyncManager(debug=debug)
    #         else:
                raise ImportError("SandboxAsyncManager not available due to import failure")
    self.project_manager = ProjectManager()

    #         # Active merge operations
    self._active_merges: Dict[str, MergeOperation] = {}

    #         # Concurrent merge tracking
    self._merge_semaphore = asyncio.Semaphore(max_concurrent_merges)

    #         # Performance metrics
    self.metrics = {
    #             "total_merges": 0,
    #             "successful_merges": 0,
    #             "failed_merges": 0,
    #             "conflicts_resolved": 0,
    #             "average_merge_time": 0.0,
    #             "files_merged": 0,
    #         }

    #     async def create_merge_operation(
    #         self,
    #         merge_id: str,
    #         source_sandbox_ids: List[str],
    #         target_sandbox_id: str,
    strategy: MergeStrategy = MergeStrategy.AUTO,
    #     ) -Optional[MergeOperation]):
    #         """Create a new merge operation"""
    #         if merge_id in self._active_merges:
    #             if self.debug:
                    print(f"Merge operation {merge_id} already exists")
    #             return None

    #         # Validate source sandboxes
    valid_sources = []
    #         for sandbox_id in source_sandbox_ids:
    #             if sandbox_id in self.sandbox_manager._active_sandboxes:
                    valid_sources.append(sandbox_id)
    #             else:
    #                 if self.debug:
                        print(f"Source sandbox {sandbox_id} not found, skipping")

    #         if not valid_sources:
    #             if self.debug:
                    print("No valid source sandboxes found")
    #             return None

    #         # Validate target sandbox
    #         if target_sandbox_id not in self.sandbox_manager._active_sandboxes:
    #             if self.debug:
                    print(f"Target sandbox {target_sandbox_id} not found")
    #             return None

    #         # Create merge operation
    merge_op = MergeOperation(
    merge_id = merge_id,
    source_sandbox_ids = valid_sources,
    target_sandbox_id = target_sandbox_id,
    strategy = strategy,
    start_time = asyncio.get_event_loop().time(),
    #         )

    self._active_merges[merge_id] = merge_op

    #         # Update metrics
    self.metrics["total_merges"] + = 1

    #         if self.debug:
                print(
    #                 f"Created merge operation {merge_id} with sources: {valid_sources}, target: {target_sandbox_id}"
    #             )

    #         return merge_op

    #     async def generate_diffs_for_merge(self, merge_id: str) -List[FileDiff]):
    #         """Generate diffs between source sandboxes and target sandbox"""
    #         if merge_id not in self._active_merges:
    #             return []

    merge_op = self._active_merges[merge_id]
    target_sandbox = self.sandbox_manager._active_sandboxes[
    #             merge_op.target_sandbox_id
    #         ]
    source_sandboxes = [
    #             self.sandbox_manager._active_sandbox_ids[sid]
    #             for sid in merge_op.source_sandbox_ids
    #             if sid in self.sandbox_manager._active_sandboxes
    #         ]

    all_diffs = []
    processed_files = set()

    #         # Collect all files from source sandboxes
    source_files = {}
    #         for sandbox in source_sandboxes:
    #             for file_path in Path(sandbox.path).rglob("*.nbc"):
    relative_path = file_path.relative_to(sandbox.path)
    #                 if relative_path not in processed_files:
    source_files[str(relative_path)] = file_path.read_text()
                        processed_files.add(str(relative_path))

    #         # Compare with target sandbox
    target_files = {}
    #         for file_path in Path(target_sandbox.path).rglob("*.nbc"):
    relative_path = file_path.relative_to(target_sandbox.path)
    target_files[str(relative_path)] = file_path.read_text()

    #         # Generate diffs
    #         for file_path in processed_files:
    #             # Check if file exists in target
    #             if file_path in target_files:
    #                 # File exists in both, check for differences
    #                 if source_files[file_path] != target_files[file_path]:
    #                     # Generate unified diff
    diff_lines = list(
                            difflib.unified_diff(
    target_files[file_path].splitlines(keepends = True),
    source_files[file_path].splitlines(keepends = True),
    fromfile = f"target/{file_path}",
    tofile = f"source/{file_path}",
    lineterm = "",
    #                         )
    #                     )

                        all_diffs.append(
                            FileDiff(
    file_path = file_path,
    target_content = target_files[file_path],
    source_content = source_files[file_path],
    diff_lines = diff_lines,
    change_type = "modified",
    #                         )
    #                     )
                        merge_op.modified_files.append(file_path)
    #             else:
                    # File is new (only in source)
                    all_diffs.append(
                        FileDiff(
    file_path = file_path,
    source_content = source_files[file_path],
    change_type = "added",
    #                     )
    #                 )
                    merge_op.created_files.append(file_path)

    #         # Check for files deleted in sources
    #         for file_path in target_files:
    #             if file_path not in processed_files:
                    all_diffs.append(
                        FileDiff(
    file_path = file_path,
    target_content = target_files[file_path],
    change_type = "deleted",
    #                     )
    #                 )
                    merge_op.deleted_files.append(file_path)

    #         return all_diffs

    #     async def resolve_conflicts_auto(
    #         self, merge_id: str, conflicts: List[FileDiff]
    #     ) -Dict[str, str]):
    #         """Automatically resolve merge conflicts"""
    resolved = {}

    #         for conflict in conflicts:
    #             if conflict.change_type == "modified":
    #                 # Simple auto-resolution: take the source version
    resolved[conflict.file_path] = "source"
    #             elif conflict.change_type == "added":
    #                 # No conflict for new files
    resolved[conflict.file_path] = "accept"
    #             elif conflict.change_type == "deleted":
    #                 # No conflict for deleted files
    resolved[conflict.file_path] = "accept"

    #         return resolved

    #     async def apply_merge_diffs(self, merge_id: str, diffs: List[FileDiff]) -bool):
    #         """Apply diffs to target sandbox"""
    #         if merge_id not in self._active_merges:
    #             return False

    merge_op = self._active_merges[merge_id]
    target_sandbox = self.sandbox_manager._active_sandboxes[
    #             merge_op.target_sandbox_id
    #         ]

    success = True

    #         for diff in diffs:
    #             try:
    target_path = Path(target_sandbox.path) / "workspace" / diff.file_path

    #                 if diff.change_type == "added":
    #                     # Ensure directory exists
    target_path.parent.mkdir(parents = True, exist_ok=True)

    #                     # Write new file
                        target_path.write_text(diff.source_content or "")

    #                     if self.debug:
                            print(f"Added file: {diff.file_path}")

    #                 elif diff.change_type == "modified":
    #                     # Ensure directory exists
    target_path.parent.mkdir(parents = True, exist_ok=True)

    #                     # Apply diff (simplified - just overwrite with source)
                        target_path.write_text(diff.source_content or "")

    #                     if self.debug:
                            print(f"Modified file: {diff.file_path}")

    #                 elif diff.change_type == "deleted":
    #                     # Remove file
    #                     if target_path.exists():
                            target_path.unlink()

    #                         if self.debug:
                                print(f"Deleted file: {diff.file_path}")

    #                 # Update merge operation
    #                 if diff.file_path not in merge_op.resolved_files:
    merge_op.resolved_files[diff.file_path] = "applied"

    #                 # Update metrics
    self.metrics["files_merged"] + = 1

    #             except Exception as e:
    #                 if self.debug:
    #                     print(f"Failed to apply diff for {diff.file_path}: {e}")
    success = False
                    merge_op.conflicts.append(
    #                     {
    #                         "file": diff.file_path,
                            "error": str(e),
    #                         "type": "application_error",
    #                     }
    #                 )

    #         return success

    #     async def execute_merge_strategy(self, merge_id: str) -bool):
    #         """Execute a merge based on the specified strategy"""
    #         if merge_id not in self._active_merges:
    #             return False

    merge_op = self._active_merges[merge_id]

    #         try:
    #             # Generate diffs
    diffs = await self.generate_diffs_for_merge(merge_id)

    #             if not diffs:
    #                 if self.debug:
    #                     print(f"No diffs found for merge {merge_id}")
    merge_op.status = "completed_no_changes"
    #                 return True

    #             # Apply strategy
    #             if merge_op.strategy == MergeStrategy.AUTO:
    #                 # Auto-resolve conflicts
    resolved = await self.resolve_conflicts_auto(merge_id, diffs)

    #                 # Apply resolved diffs
    success = await self.apply_merge_diffs(merge_id, diffs)

    #                 if success:
    merge_op.status = "completed_auto"
    #                 else:
    merge_op.status = "completed_with_errors"

    #             elif merge_op.strategy == MergeStrategy.MANUAL:
    #                 # For manual resolution, we would need user input
    #                 # For now, just mark as needing manual review
                    merge_op.conflicts.extend(
    #                     [
    #                         {
    #                             "file": diff.file_path,
    #                             "error": "Manual resolution required",
    #                             "type": "manual_resolution_needed",
    #                         }
    #                         for diff in diffs
    #                     ]
    #                 )
    merge_op.status = "pending_manual"
    success = False

    #             elif merge_op.strategy == MergeStrategy.AI_REVIEW:
    #                 # AI review would involve analyzing diffs and making decisions
    #                 # For now, simulate AI resolution
    ai_resolved = await self.resolve_conflicts_auto(merge_id, diffs)

    #                 # Apply AI-resolved diffs
    success = await self.apply_merge_diffs(merge_id, diffs)

    #                 if success:
    merge_op.status = "completed_ai"
    #                 else:
    merge_op.status = "completed_ai_with_errors"

    #             elif merge_op.strategy == MergeStrategy.MAJORITY_VOTE:
    #                 # For majority vote, we'd need multiple sandboxes with opinions
    #                 # For now, just use source version
    resolved = await self.resolve_conflicts_auto(merge_id, diffs)
    success = await self.apply_merge_diffs(merge_id, diffs)

    #                 if success:
    merge_op.status = "completed_majority"
    #                 else:
    merge_op.status = "completed_majority_with_errors"

    #             elif merge_op.strategy == MergeStrategy.SEQUENTIAL:
    #                 # Apply diffs in sequence, handling conflicts as they arise
    success = True
    #                 for diff in diffs:
    diff_success = await self.apply_merge_diffs(merge_id, [diff])
    #                     if not diff_success:
    success = False

    #                 if success:
    merge_op.status = "completed_sequential"
    #                 else:
    merge_op.status = "completed_sequential_with_errors"

    #             # Record end time
    merge_op.end_time = asyncio.get_event_loop().time()

    #             # Update metrics
    #             if merge_op.status.startswith("completed"):
    self.metrics["successful_merges"] + = 1
    self.metrics["conflicts_resolved"] + = len(merge_op.conflicts)
    #             else:
    self.metrics["failed_merges"] + = 1

    #             # Calculate average merge time
    #             if merge_op.end_time:
    merge_duration = merge_op.end_time - merge_op.start_time
    self.metrics["average_merge_time"] = (
    #                     self.metrics["average_merge_time"]
                        * (self.metrics["total_merges"] - 1)
    #                     + merge_duration
    #                 ) / self.metrics["total_merges"]

    #             if self.debug:
    #                 print(f"Merge {merge_id} completed with status: {merge_op.status}")

    #             return success

    #         except Exception as e:
    #             if self.debug:
    #                 print(f"Error executing merge strategy for {merge_id}: {e}")

    #             # Update merge operation
    merge_op.status = "failed"
    merge_op.end_time = asyncio.get_event_loop().time()
                merge_op.conflicts.append(
                    {"file": "unknown", "error": str(e), "type": "strategy_error"}
    #             )

    #             # Update metrics
    self.metrics["failed_merges"] + = 1

    #             return False

    #     async def merge_sandbox_async_results(
    #         self,
    #         merge_id: str,
    #         source_sandbox_ids: List[str],
    #         target_sandbox_id: str,
    strategy: MergeStrategy = MergeStrategy.AUTO,
    gpu: bool = False,
    #     ) -bool):
    #         """Public method to merge results from sandbox async operations"""
    #         from ....runtime import RuntimeConfig

    config = RuntimeConfig()
    #         if gpu and not config.gpu_enabled:
    #             if self.debug:
    #                 print(f"GPU requested but not available for merge {merge_id}")
    gpu = False

    #         async with self._merge_semaphore:
    #             # Create merge operation
    merge_op = await self.create_merge_operation(
    #                 merge_id, source_sandbox_ids, target_sandbox_id, strategy
    #             )

    #             if not merge_op:
    #                 return False

    #             # Execute merge with GPU context if enabled
    #             merge_op.gpu = gpu  # Add to dataclass if needed
                return await self.execute_merge_strategy(merge_id)

    #     def get_merge_operation(self, merge_id: str) -Optional[MergeOperation]):
    #         """Get a merge operation by ID"""
            return self._active_merges.get(merge_id)

    #     def list_merge_operations(
    self, status: Optional[str] = None
    #     ) -List[MergeOperation]):
    #         """List all merge operations, optionally filtered by status"""
    operations = list(self._active_merges.values())

    #         if status:
    #             operations = [op for op in operations if op.status == status]

    #         return operations

    #     async def cancel_merge_operation(self, merge_id: str) -bool):
    #         """Cancel a merge operation"""
    #         if merge_id not in self._active_merges:
    #             return False

    merge_op = self._active_merges[merge_id]

    #         try:
    #             # Update status
    merge_op.status = "cancelled"
    merge_op.end_time = asyncio.get_event_loop().time()

    #             if self.debug:
                    print(f"Cancelled merge operation {merge_id}")

    #             return True

    #         except Exception as e:
    #             if self.debug:
                    print(f"Failed to cancel merge operation {merge_id}: {e}")
    #             return False

    #     async def cleanup_completed_merges(
    self, older_than_seconds: float = 3600.0
    #     ) -None):
    #         """Clean up completed merge operations older than specified time"""
    current_time = asyncio.get_event_loop().time()

    #         for merge_id, merge_op in list(self._active_merges.items()):
    #             if merge_op.status.startswith("completed") or merge_op.status == "failed":
    age = current_time - (merge_op.end_time or merge_op.start_time)
    #                 if age older_than_seconds):
    #                     del self._active_merges[merge_id]

    #                     if self.debug:
                            print(f"Cleaned up old merge operation {merge_id}")

    #     def get_merge_performance_metrics(self) -Dict[str, Any]):
    #         """Get performance metrics for merge operations"""
            return self.metrics.copy()

    #     def create_bytecode_for_merge_operation(
    #         self,
    #         merge_id: str,
    #         source_sandbox_ids: List[str],
    #         target_sandbox_id: str,
    #         strategy: MergeStrategy,
    #     ) -List):
    #         """Create bytecode sequence for merge operation"""
    code_gen = CodeGenerator(debug=self.debug)

    #         # Start merge operation
            code_gen._emit(OpCode.ASYNC_HANDLE, [f"merge_handle_{merge_id}"])

    #         # Generate diffs
            code_gen._emit(
                OpCode.GENERATE_DIFF, [",".join(source_sandbox_ids), target_sandbox_id]
    #         )

    #         # Apply merge strategy
            code_gen._emit(OpCode.APPLY_MERGE_STRATEGY, [str(strategy.value)])

    #         # Apply diffs
            code_gen._emit(OpCode.APPLY_DIFFS, [merge_id])

    #         # Complete merge
            code_gen._emit(OpCode.ASYNC_COMPLETE, [f"merge_handle_{merge_id}"])

    #         return code_gen.bytecode

    #     async def __aenter__(self):
    #         """Async context manager entry"""
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
    #         """Async context manager exit"""
    #         # Clean up all resources
    #         for merge_id in list(self._active_merges.keys()):
                await self.cancel_merge_operation(merge_id)
