# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Sandbox Integration for Async Operations in Noodle Core

# Integrates the sandboxing system with the async runtime to allow
# agents to work in isolated environments.
# """

import asyncio
import os
import shutil
import tempfile
import warnings
import dataclasses.dataclass,
import pathlib.Path
import typing.Any,

import pydantic.BaseModel,

import ....runtime.merge.MergeManager
import ....runtime.project_manager.ProjectManager
import ....runtime.sandbox.SandboxManager
import .conditional_imports.import_manager

async_module = import_manager.lazy_import(
#     "noodle.runtime.nbc_runtime.core.async_runtime"
# )
# AsyncRuntime = async_module.AsyncNBCRuntime if async_module else None
# AsyncHandle = async_module.ResourceHandle if async_module else None

resource_module = import_manager.lazy_import(
#     "noodle.runtime.nbc_runtime.core.resource_manager"
# )
# ResourceManager = resource_module.ResourceManager if resource_module else None

compiler_module = import_manager.lazy_import("noodle.compiler.code_generator")
# CodeGenerator = compiler_module.CodeGenerator if compiler_module else None
# OpCode = compiler_module.OpCode if compiler_module else None

merge_module = import_manager.lazy_import("noodle.runtime.merge")
# MergeManager = merge_module.MergeManager if merge_module else None


class OperationInput(BaseModel)
    #     operation_id: str
    #     script_content: str
    dependencies: Optional[List[str]] = None

        @validator("script_content")
    #     def validate_script(cls, v):
    #         if not v.strip():
                raise ValueError("Script content cannot be empty")
    #         if len(v) > 1000000:  # 1MB limit
                raise ValueError("Script content too large")
    #         return v

        @validator("dependencies")
    #     def validate_deps(cls, v):
    #         if v:
    #             for dep in v:
    #                 if not isinstance(dep, str) or not dep.strip():
                        raise ValueError("Dependencies must be non-empty strings")
    #         return v


# @dataclass
class SandboxAsyncOperation
    #     """Represents an async operation within a sandbox"""

    #     handle: AsyncHandle
    #     sandbox_id: str
    #     operation_id: str
    #     script_path: str
    status: str = "running"
    result: Optional[Any] = None
    error: Optional[str] = None
    start_time: float = 0.0
    end_time: Optional[float] = None
    resources: List[str] = field(default_factory=list)


class SandboxAsyncManager
    #     """Manages async operations within sandboxes"""

    #     def __init__(
    #         self,
    max_sandboxes: int = 10,
    sandbox_timeout: float = 300.0,
    debug: bool = False,
    #     ):
    self.max_sandboxes = max_sandboxes
    self.sandbox_timeout = sandbox_timeout
    self.debug = debug

    #         # Async runtime for executing operations
    self.async_runtime = AsyncRuntime(debug=debug)

    #         # Active sandboxes
    self._active_sandboxes: Dict[str, Any] = {}

    #         # Async operations in sandboxes
    self._sandbox_operations: Dict[str, SandboxAsyncOperation] = {}

    #         # Resource manager for tracking sandbox resources
    self.resource_manager = ResourceManager()

    #         # Performance metrics
    self.metrics = {
    #             "total_sandbox_operations": 0,
    #             "successful_operations": 0,
    #             "failed_operations": 0,
    #             "average_operation_time": 0.0,
    #             "total_memory_used": 0,
    #             "active_sandboxes": 0,
    #         }

    #     def _get_available_sandbox(self) -> Optional[Any]:
    #         """Get an available sandbox or create a new one"""
    #         if len(self._active_sandboxes) < self.max_sandboxes:
    #             # Try to reuse existing sandbox
    #             for sandbox_id, sandbox in self._active_sandboxes.items():
    #                 if not self._is_sandbox_in_use(sandbox_id):
    #                     return sandbox

    #         # Create new sandbox
    #         try:
    #             # Use the global sandbox manager to create a sandbox
    #             from ....runtime.sandbox import init_global_sandbox_manager

    sandbox_manager = init_global_sandbox_manager()
    sandbox_path = sandbox_manager.create_sandbox(
    "async_operation", copy_base = False
    #             )

    #             # Create a simple wrapper object to match expected interface
    #             class SandboxWrapper:
    #                 def __init__(self, path, manager):
    self.path = path
    self.id = path.name
    self.manager = manager

    #                 def destroy(self):
                        self.manager.destroy_sandbox("async_operation")

    sandbox = SandboxWrapper(sandbox_path, sandbox_manager)
    self._active_sandboxes[sandbox.id] = sandbox
    #             if self.debug:
                    print(f"Created new sandbox: {sandbox.id}")
    #             return sandbox
    #         except Exception as e:
    #             if self.debug:
                    print(f"Failed to create sandbox: {e}")
    #             return None

    #     def _is_sandbox_in_use(self, sandbox_id: str) -> bool:
    #         """Check if sandbox has active operations"""
            return any(
    op.sandbox_id = = sandbox_id and op.status == "running"
    #             for op in self._sandbox_operations.values()
    #         )

    #     def _cleanup_sandbox_resources(self, operation_id: str) -> None:
    #         """Clean up resources associated with an async operation"""
    #         if operation_id in self._sandbox_operations:
    operation = self._sandbox_operations[operation_id]

    #             # Clean up script file
    #             if os.path.exists(operation.script_path):
    #                 try:
                        os.unlink(operation.script_path)
    #                 except Exception as e:
    #                     if self.debug:
                            print(
    #                             f"Failed to cleanup script file {operation.script_path}: {e}"
    #                         )

    #             # Clean up other resources
    #             for resource_id in operation.resources:
                    self.resource_manager.release_resource(resource_id)

    #     async def create_sandbox_async_operation(
    #         self,
    #         operation_id: str,
    #         script_content: str,
    dependencies: List[str] = None,
    gpu: bool = False,
    #     ) -> Optional[SandboxAsyncOperation]:
    #         """Create and start an async operation in a sandbox"""
    #         from ....runtime import RuntimeConfig

    config = RuntimeConfig()
    #         if gpu and not config.gpu_enabled:
    #             if self.debug:
    #                 print(f"GPU requested but not available for operation {operation_id}")
    gpu = False

            warnings.warn(
    #             "create_sandbox_async_operation uses legacy sync validation. "
    #             "Use the new validated async executor in v2.0.",
    #             DeprecationWarning,
    stacklevel = 2,
    #         )
    #         try:
    input_data = OperationInput(
    operation_id = operation_id,
    script_content = script_content,
    dependencies = dependencies or [],
    #             )
    #         except ValueError as e:
    #             if self.debug:
                    print(f"Input validation failed: {e}")
    #             return None

    #         if operation_id in self._sandbox_operations:
    #             if self.debug:
                    print(f"Operation {operation_id} already exists")
    #             return None

    #         # Get available sandbox
    sandbox = self._get_available_sandbox()
    #         if not sandbox:
    #             if self.debug:
                    print("No available sandboxes")
    #             return None

    #         try:
    #             # Create script in sandbox
    script_filename = f"async_op_{operation_id}.nbc"
    script_path = Path(sandbox.path) / "workspace" / script_filename

    #             # Ensure workspace directory exists
    script_path.parent.mkdir(parents = True, exist_ok=True)

    #             # Write script content with GPU context if enabled
    #             gpu_context = f"gpu_enabled = {gpu}\n" if gpu else ""
    full_content = math.add(gpu_context, input_data.script_content)
    #             with open(script_path, "w") as f:
                    f.write(full_content)

    #             # Allocate resources
    resource_ids = []
    #             if input_data.dependencies:
    dep_resource_id = f"dep_{operation_id}"
                    self.resource_manager.allocate_resource(dep_resource_id, "dependencies")
                    resource_ids.append(dep_resource_id)
    #             if gpu:
    gpu_resource_id = f"gpu_{operation_id}"
                    self.resource_manager.allocate_resource(gpu_resource_id, "gpu")
                    resource_ids.append(gpu_resource_id)

    #             # Create async operation
    handle = await self.async_runtime.execute_async_script(str(script_path))

    #             # Create operation record
    operation = SandboxAsyncOperation(
    handle = handle,
    sandbox_id = sandbox.id,
    operation_id = operation_id,
    script_path = str(script_path),
    start_time = asyncio.get_event_loop().time(),
    resources = resource_ids,
    #             )

    self._sandbox_operations[operation_id] = operation

    #             # Update metrics
    self.metrics["total_sandbox_operations"] + = 1
    self.metrics["active_sandboxes"] = len(
    #                 [
    #                     s
    #                     for s in self._active_sandboxes.values()
    #                     if self._is_sandbox_in_use(s.id)
    #                 ]
    #             )

    #             if self.debug:
                    print(
    #                     f"Created sandbox async operation {operation_id} in sandbox {sandbox.id} with GPU: {gpu}"
    #                 )

    #             return operation

    #         except Exception as e:
    #             if self.debug:
                    print(f"Failed to create sandbox async operation: {e}")
    #             # Cleanup if needed
                sandbox.destroy()
    #             del self._active_sandboxes[sandbox.id]
    #             return None

    #     async def wait_for_sandbox_operation(
    self, operation_id: str, timeout: Optional[float] = None
    #     ) -> bool:
    #         """Wait for a sandbox async operation to complete"""
    #         if operation_id not in self._sandbox_operations:
    #             if self.debug:
                    print(f"Operation {operation_id} not found")
    #             return False

    operation = self._sandbox_operations[operation_id]

    #         try:
    #             # Wait for operation to complete
    timeout = timeout or self.sandbox_timeout
    result = await self.async_runtime.wait_for_async(
    operation.handle, timeout = timeout
    #             )

    #             # Update operation record
    operation.status = "completed"
    operation.result = result
    operation.end_time = asyncio.get_event_loop().time()

    #             # Update metrics
    self.metrics["successful_operations"] + = 1

    #             if self.debug:
                    print(f"Sandbox operation {operation_id} completed successfully")

    #             return True

    #         except Exception as e:
    #             # Update operation record
    operation.status = "failed"
    operation.error = str(e)
    operation.end_time = asyncio.get_event_loop().time()

    #             # Update metrics
    self.metrics["failed_operations"] + = 1

    #             if self.debug:
                    print(f"Sandbox operation {operation_id} failed: {e}")

    #             return False

    #     async def poll_sandbox_operation_status(self, operation_id: str) -> Optional[str]:
    #         """Poll the status of a sandbox async operation"""
    #         if operation_id not in self._sandbox_operations:
    #             return None

    operation = self._sandbox_operations[operation_id]

    #         try:
    status = await self.async_runtime.poll_async_status(operation.handle)
    operation.status = status
    #             return status
    #         except Exception as e:
    #             if self.debug:
                    print(f"Failed to poll operation {operation_id}: {e}")
    operation.status = "unknown"
    #             return "unknown"

    #     async def cancel_sandbox_operation(self, operation_id: str) -> bool:
    #         """Cancel a sandbox async operation"""
    #         if operation_id not in self._sandbox_operations:
    #             return False

    operation = self._sandbox_operations[operation_id]

    #         try:
    #             # Cancel the async operation
                await self.async_runtime.cancel_async_operation(operation.handle)

    #             # Update operation record
    operation.status = "cancelled"
    operation.end_time = asyncio.get_event_loop().time()

    #             # Cleanup resources
                self._cleanup_sandbox_resources(operation_id)

    #             if self.debug:
                    print(f"Cancelled sandbox operation {operation_id}")

    #             return True

    #         except Exception as e:
    #             if self.debug:
                    print(f"Failed to cancel operation {operation_id}: {e}")
    #             return False

    #     def get_sandbox_operation(
    #         self, operation_id: str
    #     ) -> Optional[SandboxAsyncOperation]:
    #         """Get a sandbox async operation by ID"""
            return self._sandbox_operations.get(operation_id)

    #     def list_sandbox_operations(
    self, sandbox_id: Optional[str] = None
    #     ) -> List[SandboxAsyncOperation]:
    #         """List all sandbox async operations, optionally filtered by sandbox"""
    operations = list(self._sandbox_operations.values())

    #         if sandbox_id:
    #             operations = [op for op in operations if op.sandbox_id == sandbox_id]

    #         return operations

    #     async def execute_sandbox_batch(
    self, operations: Dict[str, str], batch_id: str = "default"
    #     ) -> Dict[str, bool]:
    #         """Execute multiple operations in sandboxes as a batch"""
    results = {}

    #         # Create all operations first
    #         for operation_id, script_content in operations.items():
    operation = await self.create_sandbox_async_operation(
    #                 f"{batch_id}_{operation_id}", script_content
    #             )
    #             if operation:
    results[operation_id] = True
    #             else:
    results[operation_id] = False

    #         # Wait for all operations to complete
    #         for operation_id, script_content in operations.items():
    batch_op_id = f"{batch_id}_{operation_id}"
    #             if results.get(operation_id, False):
    success = await self.wait_for_sandbox_operation(batch_op_id)
    results[operation_id] = success

    #         return results

    #     async def merge_sandbox_results(
    self, source_sandbox_ids: List[str], target_sandbox_id: Optional[str] = None
    #     ) -> Optional[str]:
    #         """Merge results from multiple source sandboxes to a target sandbox"""
    #         if not source_sandbox_ids:
    #             return None

    #         # Use first sandbox as target if none specified
    #         if target_sandbox_id is None:
    target_sandbox_id = source_sandbox_ids[0]

    #         # Get target sandbox
    target_sandbox = self._active_sandboxes.get(target_sandbox_id)
    #         if not target_sandbox:
    #             if self.debug:
                    print(f"Target sandbox {target_sandbox_id} not found")
    #             return None

    #         # Collect diff operations
    diff_operations = []

    #         for source_sandbox_id in source_sandbox_ids:
    source_sandbox = self._active_sandboxes.get(source_sandbox_id)
    #             if not source_sandbox:
    #                 continue

    #             # Calculate diff (simplified for demo)
    #             # In production, this would compare file contents
    source_files = list(Path(source_sandbox.path).rglob("*.nbc"))
    target_files = list(Path(target_sandbox.path).rglob("*.nbc"))

    #             # Find new/modified files in source
    #             for source_file in source_files:
    relative_path = source_file.relative_to(source_sandbox.path)
    target_file = math.divide(Path(target_sandbox.path), relative_path)

    #                 if target_file not in target_files:
    #                     # Add new file
                        diff_operations.append(
    #                         {
    #                             "type": "new_file",
                                "source": str(source_file),
                                "target": str(target_file),
                                "content": source_file.read_text(),
    #                         }
    #                     )

    #         # Apply diff using merge manager
    #         if MergeManager:
    merge_manager = MergeManager()
    #         else:
                raise ImportError("MergeManager not available due to import failure")

    #         for diff_op in diff_operations:
    #             try:
    #                 if diff_op["type"] == "new_file":
    #                     # Ensure target directory exists
    target_path = Path(diff_op["target"])
    target_path.parent.mkdir(parents = True, exist_ok=True)

    #                     # Copy file content
                        target_path.write_text(diff_op["content"])

    #                     if self.debug:
                            print(f"Merged new file: {diff_op['target']}")
    #             except Exception as e:
    #                 if self.debug:
                        print(f"Failed to merge {diff_op['type']}: {e}")
    #                 continue

    #         if self.debug:
                print(
                    f"Completed merge from {len(source_sandbox_ids)} sandboxes to {target_sandbox_id}"
    #             )

    #         return target_sandbox_id

    #     def cleanup_sandbox(self, sandbox_id: str) -> bool:
    #         """Clean up and destroy a sandbox"""
    #         if sandbox_id not in self._active_sandboxes:
    #             return False

    #         # Cancel any running operations in the sandbox
    sandbox_operations = [
    #             op_id
    #             for op_id, op in self._sandbox_operations.items()
    #             if op.sandbox_id == sandbox_id
    #         ]

    #         for operation_id in sandbox_operations:
                asyncio.create_task(self.cancel_sandbox_operation(operation_id))

    #         # Destroy sandbox
    #         try:
    sandbox = self._active_sandboxes[sandbox_id]
                sandbox.destroy()
    #             del self._active_sandboxes[sandbox_id]

    #             # Update metrics
    self.metrics["active_sandboxes"] = len(
    #                 [
    #                     s
    #                     for s in self._active_sandboxes.values()
    #                     if self._is_sandbox_in_use(s.id)
    #                 ]
    #             )

    #             if self.debug:
                    print(f"Cleaned up sandbox {sandbox_id}")

    #             return True

    #         except Exception as e:
    #             if self.debug:
                    print(f"Failed to cleanup sandbox {sandbox_id}: {e}")
    #             return False

    #     def cleanup_expired_sandboxes(self) -> None:
    #         """Clean up sandboxes that have been idle too long"""
    current_time = asyncio.get_event_loop().time()

    #         for sandbox_id, sandbox in list(self._active_sandboxes.items()):
    #             # Check if sandbox is idle (no running operations)
    idle_time = math.subtract(current_time, max()
    #                 op.end_time if op.end_time else op.start_time
    #                 for op in self._sandbox_operations.values()
    #                 if op.sandbox_id == sandbox_id
    #             )

    #             if idle_time > self.sandbox_timeout:
    #                 if self.debug:
    #                     print(f"Sandbox {sandbox_id} expired (idle for {idle_time:.2f}s)")
                    self.cleanup_sandbox(sandbox_id)

    #     def get_performance_metrics(self) -> Dict[str, Any]:
    #         """Get performance metrics for sandboxed async operations"""
    #         # Calculate average operation time
    completed_ops = [
    #             op
    #             for op in self._sandbox_operations.values()
    #             if op.status in ["completed", "failed"] and op.end_time
    #         ]

    #         if completed_ops:
    #             total_time = sum(op.end_time - op.start_time for op in completed_ops)
    self.metrics["average_operation_time"] = math.divide(total_time, len(completed_ops))

    #         # Calculate total memory usage
    self.metrics["total_memory_used"] = sum(
    #             op.resources.count("memory") for op in self._sandbox_operations.values()
    #         )

            return self.metrics.copy()

    #     def create_bytecode_for_sandbox_operation(
    self, operation_id: str, script_content: str, dependencies: List[str] = None
    #     ) -> List:
    #         """Create bytecode sequence for sandbox async operation"""
    code_gen = CodeGenerator(debug=self.debug)

    #         # Create sandbox operation
            code_gen._emit(OpCode.ASYNC_HANDLE, [f"sandbox_handle_{operation_id}"])

    #         # Execute script in sandbox
    #         if dependencies:
    #             # Load dependencies first
    #             for dep in dependencies:
                    code_gen._emit(OpCode.LOAD_DEPENDENCY, [dep])

            code_gen._emit(OpCode.ASYNC_EXECUTE, [f"sandbox_script_{operation_id}.nbc"])

    #         # Wait for completion
            code_gen._emit(OpCode.ASYNC_AWAIT, [f"sandbox_handle_{operation_id}"])

    #         # Poll status
            code_gen._emit(OpCode.ASYNC_POLL, [f"sandbox_handle_{operation_id}"])

    #         # Get result
            code_gen._emit(OpCode.ASYNC_COMPLETE, [f"sandbox_handle_{operation_id}"])

    #         # Merge results
    #         if dependencies:
                code_gen._emit(OpCode.MERGE_RESULTS, [f"{operation_id}_merge"])

    #         return code_gen.bytecode

    #     async def __aenter__(self):
    #         """Async context manager entry"""
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
    #         """Async context manager exit"""
    #         # Clean up all resources
    #         for sandbox_id in list(self._active_sandboxes.keys()):
                self.cleanup_sandbox(sandbox_id)

    #         # Shutdown async runtime
            await self.async_runtime.shutdown()
