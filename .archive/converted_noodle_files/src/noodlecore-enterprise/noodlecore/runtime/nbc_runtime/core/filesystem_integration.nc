# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Filesystem Integration for Sandbox & Merge System in Noodle Core

# Integrates the filesystem operations with the sandboxing and merge systems
# to enable consistent file I/O for AI agents working in isolated environments.
# """

import asyncio
import os
import shutil
import contextlib.asynccontextmanager
import dataclasses.dataclass,
import enum.Enum
import pathlib.Path
import typing.Any,

import noodlecore.runtime.merge.MergeManager
import noodlecore.runtime.nbc_runtime.core.async_runtime.AsyncNBCRuntime
import noodlecore.runtime.nbc_runtime.core.merge_integration.(
#     AsyncMergeManager,
#     MergeStrategy,
# )
import noodlecore.runtime.nbc_runtime.core.sandbox_integration.SandboxAsyncManager
import noodlecore.runtime.project_manager.ProjectManager
import noodlecore.runtime.sandbox.SandboxManager


class FileOperation(Enum)
    READ = "read"
    WRITE = "write"
    DELETE = "delete"
    RENAME = "rename"
    LIST = "list"
    MAKE_DIR = "make_dir"
    REMOVE_DIR = "remove_dir"
    COPY = "copy"


class FilePermission(Enum)
    READ = "r"
    WRITE = "w"
    EXECUTE = "x"
    READ_WRITE = "rw"
    READ_EXECUTE = "rx"
    WRITE_EXECUTE = "wx"
    ALL = "rwx"


# @dataclass
class FileOperationRequest
    #     """Represents a file operation request"""

    #     operation: FileOperation
    #     path: str
    sandbox_id: Optional[str] = None
    content: Optional[Union[str, bytes]] = None
    permissions: Optional[List[FilePermission]] = None
    overwrite: bool = False
    recursive: bool = False
    async_operation: bool = False
    operation_id: Optional[str] = None


# @dataclass
class FileOperationResult
    #     """Represents the result of a file operation"""

    #     success: bool
    #     message: str
    content: Optional[Union[str, bytes]] = None
    metadata: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    operation_id: Optional[str] = None


# @dataclass
class FileOverwriteConflict
    #     """Represents a file overwrite conflict"""

    #     path: str
    #     source_content: Union[str, bytes]
    #     target_content: Union[str, bytes]
    #     sandbox_id: str
    #     operation_id: str
    strategy: str = "ask"
    resolved: bool = False
    resolution: Optional[str] = None


class AsyncFilesystemManager
    #     """Manages async file operations within sandboxes"""

    #     def __init__(
    #         self,
    max_operations: int = 100,
    operation_timeout: float = 30.0,
    debug: bool = False,
    #     ):
    self.max_operations = max_operations
    self.operation_timeout = operation_timeout
    self.debug = debug

    #         # Core components
    self.sandbox_manager = SandboxAsyncManager(debug=debug)
    self.merge_manager = AsyncMergeManager(debug=debug)
    self.project_manager = ProjectManager()

    #         # Active file operations
    self._active_operations: Dict[str, FileOperationRequest] = {}

    #         # File operation queues
    self._operation_queues: Dict[str, asyncio.Queue] = {}

    #         # Operation semaphores for limiting concurrency
    self._operation_semaphore = asyncio.Semaphore(max_operations)

    #         # Performance metrics
    self.metrics = {
    #             "total_operations": 0,
    #             "successful_operations": 0,
    #             "failed_operations": 0,
    #             "conflicts_resolved": 0,
    #             "average_operation_time": 0.0,
    #             "active_operations": 0,
    #             "file_operations": {
    #                 "read": 0,
    #                 "write": 0,
    #                 "delete": 0,
    #                 "rename": 0,
    #                 "list": 0,
    #                 "make_dir": 0,
    #                 "remove_dir": 0,
    #                 "copy": 0,
    #             },
    #         }

    #         # File operation handlers
    self._operation_handlers: Dict[FileOperation, Callable] = {
    #             FileOperation.READ: self._handle_read,
    #             FileOperation.WRITE: self._handle_write,
    #             FileOperation.DELETE: self._handle_delete,
    #             FileOperation.RENAME: self._handle_rename,
    #             FileOperation.LIST: self._handle_list,
    #             FileOperation.MAKE_DIR: self._handle_make_dir,
    #             FileOperation.REMOVE_DIR: self._handle_remove_dir,
    #             FileOperation.COPY: self._handle_copy,
    #         }

    #     async def register_sandbox(self, sandbox_id: str) -> bool:
    #         """Register a sandbox for filesystem operations"""
    #         if sandbox_id not in self.sandbox_manager._active_sandboxes:
    #             if self.debug:
                    print(f"Sandbox {sandbox_id} not found")
    #             return False

    #         # Create operation queue for sandbox
    #         if sandbox_id not in self._operation_queues:
    self._operation_queues[sandbox_id] = asyncio.Queue()

    #         if self.debug:
    #             print(f"Registered sandbox {sandbox_id} for filesystem operations")

    #         return True

    #     def _get_sandbox_path(self, sandbox_id: str) -> Optional[Path]:
    #         """Get the filesystem path for a sandbox"""
    #         if sandbox_id not in self.sandbox_manager._active_sandboxes:
    #             return None

    sandbox = self.sandbox_manager._active_sandboxes[sandbox_id]
            return Path(sandbox.path) / "workspace"

    #     async def execute_file_operation(
    #         self, operation_request: FileOperationRequest
    #     ) -> FileOperationResult:
    #         """Execute a file operation synchronously"""
    #         async with self._operation_semaphore:
    #             # Track metrics
    self.metrics["total_operations"] + = 1
    self.metrics["active_operations"] + = 1
    self.metrics["file_operations"][operation_request.operation.value] + = 1

    #             # Register operation
    operation_request.operation_id = f"op_{self.metrics['total_operations']}"
    self._active_operations[operation_request.operation_id] = operation_request

    #             if self.debug:
                    print(
    #                     f"Executing {operation_request.operation.value} operation on {operation_request.path}"
    #                 )

    #             try:
    #                 # Verify sandbox exists if specified
    #                 if operation_request.sandbox_id:
    #                     if not self._get_sandbox_path(operation_request.sandbox_id):
                            raise FileNotFoundError(
    #                             f"Sandbox {operation_request.sandbox_id} not found"
    #                         )

    #                     # Register sandbox if not already
                        await self.register_sandbox(operation_request.sandbox_id)

    #                 # Get operation handler
    handler = self._operation_handlers.get(operation_request.operation)
    #                 if not handler:
                        raise ValueError(
    #                         f"No handler for operation {operation_request.operation}"
    #                     )

    #                 # Execute operation
    result = await handler(operation_request)

    #                 # Update metrics
    #                 if result.success:
    self.metrics["successful_operations"] + = 1
    #                 else:
    self.metrics["failed_operations"] + = 1

    #                 # Clean up operation
    #                 if operation_request.operation_id in self._active_operations:
    #                     del self._active_operations[operation_request.operation_id]

    self.metrics["active_operations"] - = 1

    #                 return result

    #             except Exception as e:
    error_result = FileOperationResult(
    success = False,
    message = str(e),
    error = str(e),
    operation_id = operation_request.operation_id,
    #                 )

    #                 # Update metrics
    self.metrics["failed_operations"] + = 1
    self.metrics["active_operations"] - = 1

    #                 return error_result

    #     async def _handle_read(self, request: FileOperationRequest) -> FileOperationResult:
    #         """Handle file read operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    file_path = math.divide(sandbox_path, request.path)

    #         try:
    #             # Check if file exists
    #             if not file_path.exists():
                    raise FileNotFoundError(f"File not found: {file_path}")

    #             # Check if it's a directory
    #             if file_path.is_dir():
                    raise ValueError(f"Path is a directory, not a file: {file_path}")

    #             # Read file content
    #             with open(file_path, "rb") as f:
    content = f.read()

    #             # Convert to string if text content
    #             if isinstance(content, bytes):
    #                 try:
    content = content.decode("utf-8")
    #                 except UnicodeDecodeError:
    #                     # Keep as bytes if can't decode
    #                     pass

    #             if self.debug:
                    print(f"Successfully read file: {file_path}")

                return FileOperationResult(
    success = True,
    message = f"File read successfully: {file_path}",
    content = content,
    metadata = {
                        "path": str(file_path),
                        "size": len(content),
                        "modified": file_path.stat().st_mtime,
    #                 },
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_write(self, request: FileOperationRequest) -> FileOperationResult:
    #         """Handle file write operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    file_path = math.divide(sandbox_path, request.path)

    #         try:
    #             # Ensure directory exists
    file_path.parent.mkdir(parents = True, exist_ok=True)

    #             # Check if file exists and handle conflicts
    #             if file_path.exists() and not request.overwrite:
                    raise FileExistsError(
    f"File already exists and overwrite = False: {file_path}"
    #                 )

    #             # Write content
    #             mode = "w" if isinstance(request.content, str) else "wb"
    #             with open(file_path, mode) as f:
                    f.write(request.content)

    #             if self.debug:
                    print(f"Successfully wrote to file: {file_path}")

                return FileOperationResult(
    success = True,
    message = f"File written successfully: {file_path}",
    metadata = {
                        "path": str(file_path),
                        "size": (
                            len(str(request.content))
    #                         if isinstance(request.content, str)
                            else len(request.content)
    #                     ),
    #                 },
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_delete(
    #         self, request: FileOperationRequest
    #     ) -> FileOperationResult:
    #         """Handle delete operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    file_path = math.divide(sandbox_path, request.path)

    #         try:
    #             if not file_path.exists():
                    raise FileNotFoundError(f"File not found: {file_path}")

    #             if file_path.is_dir():
    #                 if request.recursive:
                        shutil.rmtree(file_path)
    #                 else:
                        raise ValueError(
    f"Path is a directory and recursive = False: {file_path}"
    #                     )
    #             else:
                    file_path.unlink()

    #             if self.debug:
                    print(f"Successfully deleted: {file_path}")

                return FileOperationResult(
    success = True,
    message = f"Deleted successfully: {file_path}",
    metadata = {"path": str(file_path)},
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_rename(
    #         self, request: FileOperationRequest
    #     ) -> FileOperationResult:
    #         """Handle rename operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    old_path = math.divide(sandbox_path, request.path)
    new_path = math.divide(sandbox_path, request.content  # Use content parameter as new path)

    #         try:
    #             if not old_path.exists():
                    raise FileNotFoundError(f"File not found: {old_path}")

    #             # Check if target exists
    #             if new_path.exists() and not request.overwrite:
                    raise FileExistsError(
    f"Target file already exists and overwrite = False: {new_path}"
    #                 )

                # Rename (move)
                old_path.rename(new_path)

    #             if self.debug:
                    print(f"Successfully renamed: {old_path} -> {new_path}")

                return FileOperationResult(
    success = True,
    message = f"Renamed successfully: {old_path} -> {new_path}",
    metadata = {"old_path": str(old_path), "new_path": str(new_path)},
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_list(self, request: FileOperationRequest) -> FileOperationResult:
    #         """Handle list directory operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    dir_path = math.divide(sandbox_path, request.path)

    #         try:
    #             if not dir_path.exists():
                    raise FileNotFoundError(f"Directory not found: {dir_path}")

    #             if not dir_path.is_dir():
                    raise ValueError(f"Path is not a directory: {dir_path}")

    #             # List directory contents
    items = []
    #             for item in dir_path.iterdir():
                    items.append(
    #                     {
    #                         "name": item.name,
                            "path": str(item.relative_to(sandbox_path)),
    #                         "type": "directory" if item.is_dir() else "file",
                            "size": item.stat().st_size,
                            "modified": item.stat().st_mtime,
    #                     }
    #                 )

    #             if self.debug:
                    print(f"Successfully listed: {dir_path}")

                return FileOperationResult(
    success = True,
    message = f"Listed successfully: {dir_path}",
    content = items,
    metadata = {"path": str(dir_path), "count": len(items)},
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_make_dir(
    #         self, request: FileOperationRequest
    #     ) -> FileOperationResult:
    #         """Handle make directory operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    dir_path = math.divide(sandbox_path, request.path)

    #         try:
    #             if dir_path.exists() and not request.overwrite:
                    raise FileExistsError(
    f"Path already exists and overwrite = False: {dir_path}"
    #                 )

    #             # Create directory
    dir_path.mkdir(parents = request.recursive, exist_ok=request.overwrite)

    #             if self.debug:
                    print(f"Successfully created directory: {dir_path}")

                return FileOperationResult(
    success = True,
    message = f"Directory created successfully: {dir_path}",
    metadata = {"path": str(dir_path)},
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_remove_dir(
    #         self, request: FileOperationRequest
    #     ) -> FileOperationResult:
    #         """Handle remove directory operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    dir_path = math.divide(sandbox_path, request.path)

    #         try:
    #             if not dir_path.exists():
                    raise FileNotFoundError(f"Directory not found: {dir_path}")

    #             if not dir_path.is_dir():
                    raise ValueError(f"Path is not a directory: {dir_path}")

    #             if request.recursive:
                    shutil.rmtree(dir_path)
    #             else:
                    dir_path.rmdir()

    #             if self.debug:
                    print(f"Successfully removed directory: {dir_path}")

                return FileOperationResult(
    success = True,
    message = f"Directory removed successfully: {dir_path}",
    metadata = {"path": str(dir_path)},
    #             )

    #         except Exception as e:
    #             raise e

    #     async def _handle_copy(self, request: FileOperationRequest) -> FileOperationResult:
    #         """Handle copy operation"""
    sandbox_path = (
                self._get_sandbox_path(request.sandbox_id)
    #             if request.sandbox_id
                else Path.cwd()
    #         )
    src_path = math.divide(sandbox_path, request.path)
    dst_path = (
    #             sandbox_path / request.content
    #         )  # Use content parameter as destination

    #         try:
    #             if not src_path.exists():
                    raise FileNotFoundError(f"Source not found: {src_path}")

    #             # Check if destination exists
    #             if dst_path.exists() and not request.overwrite:
                    raise FileExistsError(
    f"Destination already exists and overwrite = False: {dst_path}"
    #                 )

    #             # Copy operation
    #             if src_path.is_dir():
    #                 if request.recursive:
                        shutil.copytree(src_path, dst_path)
    #                 else:
                        raise ValueError(
    f"Source is a directory and recursive = False: {src_path}"
    #                     )
    #             else:
                    shutil.copy2(src_path, dst_path)

    #             if self.debug:
                    print(f"Successfully copied: {src_path} -> {dst_path}")

                return FileOperationResult(
    success = True,
    message = f"Copied successfully: {src_path} -> {dst_path}",
    metadata = {"source": str(src_path), "destination": str(dst_path)},
    #             )

    #         except Exception as e:
    #             raise e

    #     async def check_file_conflict(
    self, file_path: str, sandbox_id: str, strategy: str = "ask"
    #     ) -> Optional[FileOverwriteConflict]:
    #         """Check if a file operation would cause a conflict"""
    sandbox_path = self._get_sandbox_path(sandbox_id)
    #         if not sandbox_path:
    #             return None

    full_path = math.divide(sandbox_path, file_path)
    #         if not full_path.exists():
    #             return None

    #         # Get content from different sandboxes for comparison
    source_contents = []

    #         # Get content from current sandbox
    #         try:
    #             with open(full_path, "rb") as f:
    current_content = f.read()

    #             # Convert to string if possible
    #             try:
    current_content = current_content.decode("utf-8")
    #             except UnicodeDecodeError:
    #                 pass

                source_contents.append({"sandbox": sandbox_id, "content": current_content})
    #         except Exception:
    #             pass

    #         # Get content from other sandboxes
    #         for other_id, sandbox in self.sandbox_manager._active_sandboxes.items():
    #             if other_id != sandbox_id:
    other_path = Path(sandbox.path) / "workspace" / file_path
    #                 if other_path.exists():
    #                     try:
    #                         with open(other_path, "rb") as f:
    other_content = f.read()

    #                         try:
    other_content = other_content.decode("utf-8")
    #                         except UnicodeDecodeError:
    #                             pass

                            source_contents.append(
    #                             {"sandbox": other_id, "content": other_content}
    #                         )
    #                     except Exception:
    #                         pass

    #         # Create conflict if contents differ
    #         if len(source_contents) > 1:
                return FileOverwriteConflict(
    path = file_path,
    source_content = source_contents[-1]["content"],
    target_content = source_contents[0]["content"],
    sandbox_id = sandbox_id,
    operation_id = f"conflict_{file_path}",
    strategy = strategy,
    #             )

    #         return None

    #     async def resolve_file_conflict(
    #         self, conflict: FileOverwriteConflict, resolution: str, target_sandbox_id: str
    #     ) -> bool:
    #         """Resolve a file overwrite conflict"""
    #         try:
    #             # Apply resolution based on strategy
    #             if resolution == "overwrite":
    #                 # Write source content to target
    request = FileOperationRequest(
    operation = FileOperation.WRITE,
    path = conflict.path,
    sandbox_id = target_sandbox_id,
    content = conflict.source_content,
    overwrite = True,
    #                 )

    result = await self.execute_file_operation(request)
    #                 if result.success:
    conflict.resolved = True
    conflict.resolution = resolution
    self.metrics["conflicts_resolved"] + = 1

    #                 return result.success

    #             elif resolution == "keep_target":
    #                 # Do nothing, target content stays
    conflict.resolved = True
    conflict.resolution = resolution
    self.metrics["conflicts_resolved"] + = 1
    #                 return True

    #             elif resolution == "create_new":
    #                 # Create a new file with a modified name
    base_path = Path(conflict.path)
    new_path = (
    #                     base_path.parent / f"{base_path.stem}_conflict{base_path.suffix}"
    #                 )

    request = FileOperationRequest(
    operation = FileOperation.WRITE,
    path = str(new_path),
    sandbox_id = target_sandbox_id,
    content = conflict.source_content,
    overwrite = True,
    #                 )

    result = await self.execute_file_operation(request)
    #                 if result.success:
    conflict.resolved = True
    conflict.resolution = f"created_{new_path}"
    self.metrics["conflicts_resolved"] + = 1

    #                 return result.success

    #             else:
    conflict.error = f"Unknown resolution: {resolution}"
    #                 return False

    #         except Exception as e:
    conflict.error = str(e)
    #             return False

    #     async def sync_sandbox_filesystem(
    #         self,
    #         source_sandbox_id: str,
    #         target_sandbox_id: str,
    merge_strategy: MergeStrategy = MergeStrategy.AUTO,
    #     ) -> bool:
    #         """Sync filesystem from source sandbox to target sandbox"""
    #         if source_sandbox_id not in self.sandbox_manager._active_sandboxes:
    #             if self.debug:
                    print(f"Source sandbox {source_sandbox_id} not found")
    #             return False

    #         if target_sandbox_id not in self.sandbox_manager._active_sandboxes:
    #             if self.debug:
                    print(f"Target sandbox {target_sandbox_id} not found")
    #             return False

    #         try:
    #             # Get paths
    source_path = self._get_sandbox_path(source_sandbox_id)
    target_path = self._get_sandbox_path(target_sandbox_id)

    #             # Use merge manager to sync files
    sync_result = await self.merge_manager.merge_sandbox_async_results(
    merge_id = f"sync_{source_sandbox_id}_to_{target_sandbox_id}",
    source_sandbox_ids = [source_sandbox_id],
    target_sandbox_id = target_sandbox_id,
    strategy = merge_strategy,
    #             )

    #             if self.debug:
                    print(
    #                     f"Synced filesystem from {source_sandbox_id} to {target_sandbox_id}"
    #                 )

    #             return sync_result

    #         except Exception as e:
    #             if self.debug:
                    print(f"Error syncing filesystem: {e}")
    #             return False

    #     def get_filesystem_metrics(self) -> Dict[str, Any]:
    #         """Get performance metrics for filesystem operations"""
            return self.metrics.copy()

    #     async def __aenter__(self):
    #         """Async context manager entry"""
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
    #         """Async context manager exit"""
    #         # Clean up all resources
    #         for operation_id in list(self._active_operations.keys()):
    #             # Note: In production, you might want to abort pending operations
    #             pass
