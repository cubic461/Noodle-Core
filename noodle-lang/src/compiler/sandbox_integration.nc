# Converted from Python to NoodleCore
# Original file: src

# """
# Sandbox Integration Module

# This module implements sandbox preview and execution within IDE for NoodleCore.
# """

import asyncio
import json
import os
import uuid
import subprocess
import tempfile
import threading
import typing.Dict
import pathlib.Path
import datetime.datetime
import difflib.unified_diff

# Import logging
import ..logs.get_logger
import ..sandbox.get_sandbox_manager

# Sandbox Integration error codes (6401-6499)
SANDBOX_INTEGRATION_ERROR_CODES = {
#     "SANDBOX_EXECUTION_FAILED": 6401,
#     "SANDBOX_TIMEOUT": 6402,
#     "SANDBOX_SECURITY_VIOLATION": 6403,
#     "SANDBOX_APPROVAL_FAILED": 6404,
#     "SANDBOX_PREVIEW_FAILED": 6405,
#     "SANDBOX_DIFF_FAILED": 6406,
#     "SANDBOX_MONITORING_FAILED": 6407,
#     "SANDBOX_CONFIG_ERROR": 6408,
#     "SANDBOX_CACHE_ERROR": 6409,
#     "SANDBOX_METRICS_ERROR": 6410,
# }


class SandboxIntegrationError(Exception)
    #     """Custom exception for sandbox integration errors with error codes."""

    #     def __init__(self, code: int, message: str, data: Optional[Dict[str, Any]] = None):
    self.code = code
    self.message = message
    self.data = data
            super().__init__(message)


class SandboxExecution
    #     """Represents a sandbox execution."""

    #     def __init__(self,
    #                  execution_id: str,
    #                  file_path: str,
    #                  code: str,
    status: str = "pending",
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    output: Optional[str] = None,
    error: Optional[str] = None,
    metrics: Optional[Dict[str, Any]] = None):""
    #         Initialize sandbox execution.

    #         Args:
    #             execution_id: Unique execution ID
    #             file_path: Path to the file
    #             code: Code to execute
    #             status: Execution status
    #             start_time: Start time
    #             end_time: End time
    #             output: Execution output
    #             error: Execution error
    #             metrics: Performance metrics
    #         """
    self.execution_id = execution_id
    self.file_path = file_path
    self.code = code
    self.status = status
    self.start_time = start_time or datetime.now()
    self.end_time = end_time
    self.output = output
    self.error = error
    self.metrics = metrics or {}

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             'execution_id': self.execution_id,
    #             'file_path': self.file_path,
    #             'status': self.status,
    #             'start_time': self.start_time.isoformat() if self.start_time else None,
    #             'end_time': self.end_time.isoformat() if self.end_time else None,
    #             'duration': (self.end_time - self.start_time).total_seconds() if self.start_time and self.end_time else None,
    #             'output': self.output,
    #             'error': self.error,
    #             'metrics': self.metrics
    #         }


class SandboxDiff
    #     """Represents a sandbox diff."""

    #     def __init__(self,
    #                  file_path: str,
    #                  original_code: str,
    #                  modified_code: str,
    diff_lines: Optional[List[str]] = None):""
    #         Initialize sandbox diff.

    #         Args:
    #             file_path: Path to the file
    #             original_code: Original code
    #             modified_code: Modified code
    #             diff_lines: List of diff lines
    #         """
    self.file_path = file_path
    self.original_code = original_code
    self.modified_code = modified_code
    self.diff_lines = diff_lines or self._generate_diff()

    #     def _generate_diff(self) -List[str]):
    #         """Generate diff lines."""
    original_lines = self.original_code.splitlines(keepends=True)
    modified_lines = self.modified_code.splitlines(keepends=True)

    diff_lines = list(unified_diff(
    #             original_lines,
    #             modified_lines,
    fromfile = f"a/{self.file_path}",
    tofile = f"b/{self.file_path}",
    lineterm = ""
    #         ))

    #         return diff_lines

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             'file_path': self.file_path,
    #             'original_code': self.original_code,
    #             'modified_code': self.modified_code,
    #             'diff_lines': self.diff_lines,
                'has_changes': len(self.diff_lines) 0
    #         }


class SandboxIntegration
    #     """Sandbox integration for NoodleCore IDE integration."""

    #     def __init__(self, workspace_dir): Optional[str] = None):
    #         """
    #         Initialize the Sandbox Integration.

    #         Args:
    #             workspace_dir: Workspace directory
    #         """
    self.name = "SandboxIntegration"
    self.workspace_dir = Path(workspace_dir or os.getcwd())
    self.cache_dir = self.workspace_dir / ".noodlecore" / "sandbox_cache"
    self.config_file = self.workspace_dir / ".noodlecore" / "sandbox_config.json"
    self.temp_dir = self.workspace_dir / ".noodlecore" / "temp"

    #         # Initialize logger
    self.logger = get_logger(f"{__name__}.{self.name}")

    #         # Ensure directories exist
    self.cache_dir.mkdir(parents = True, exist_ok=True)
    self.temp_dir.mkdir(parents = True, exist_ok=True)

    #         # Sandbox manager
    self.sandbox_manager = get_sandbox_manager()

    #         # Default configuration
    self.default_config = {
    #             'preview_enabled': True,
    #             'auto_approve_safe': False,
    #             'execution_timeout': 30,
    #             'security_level': 'medium',
    #             'monitoring_enabled': True,
    #             'metrics_enabled': True,
    #             'diff_visualization': True,
    #             'approval_workflow': {
    #                 'enabled': True,
    #                 'auto_approve_safe_operations': True,
    #                 'require_approval_for_file_system': True,
    #                 'require_approval_for_network': True,
    #                 'require_approval_for_system_calls': True
    #             },
    #             'execution': {
    #                 'max_concurrent_executions': 3,
    #                 'default_environment': 'noodlecore',
    #                 'capture_output': True,
    #                 'capture_errors': True,
    #                 'working_directory': None
    #             },
    #             'preview': {
    #                 'show_execution_time': True,
    #                 'show_memory_usage': True,
    #                 'show_security_status': True,
    #                 'auto_refresh': True,
    #                 'refresh_interval': 1000
    #             },
    #             'diff': {
    #                 'context_lines': 3,
    #                 'show_whitespace': True,
    #                 'highlight_changes': True,
    #                 'side_by_side': False
    #             },
    #             'security': {
    #                 'allow_file_access': False,
    #                 'allow_network_access': False,
    #                 'allow_system_calls': False,
    #                 'max_memory_usage': 100,  # MB
    #                 'max_execution_time': 30,  # seconds
    #                 'allowed_imports': [],
    #                 'blocked_imports': ['os', 'subprocess', 'sys']
    #             },
    #             'performance': {
    #                 'track_execution_time': True,
    #                 'track_memory_usage': True,
    #                 'track_cpu_usage': True,
    #                 'track_network_usage': True
    #             }
    #         }

    #         # Configuration
    self.config = {}

    #         # Execution tracking
    self.executions = {}
    self.execution_queue = []
    self.active_executions = {}

    #         # Approval tracking
    self.pending_approvals = {}
    self.approval_callbacks = []

    #         # Monitoring
    self.monitoring_data = {}
    self.performance_metrics = {}

    #         # Performance tracking
    self.performance_stats = {
    #             'total_executions': 0,
    #             'successful_executions': 0,
    #             'failed_executions': 0,
    #             'timeout_executions': 0,
    #             'security_violations': 0,
    #             'average_execution_time': 0,
    #             'total_execution_time': 0,
                'last_reset': datetime.now()
    #         }

    #         # Event loop for async operations
    self.event_loop = None
    self.background_thread = None
    self.running = False

    #     async def initialize(self) -Dict[str, Any]):
    #         """
    #         Initialize the Sandbox Integration.

    #         Returns:
    #             Dictionary containing initialization result
    #         """
    #         try:
                self.logger.info("Initializing Sandbox Integration")

    #             # Load configuration
    self.config = await self._load_config()

    #             # Initialize sandbox manager
                await self.sandbox_manager.initialize()

    #             # Start background thread
                self._start_background_thread()

                self.logger.info("Sandbox Integration initialized successfully")

    #             return {
    #                 'success': True,
    #                 'message': "Sandbox Integration initialized successfully",
    #                 'features': {
                        'preview_enabled': self.config.get('preview_enabled', True),
                        'auto_approve_safe': self.config.get('auto_approve_safe', False),
                        'monitoring_enabled': self.config.get('monitoring_enabled', True),
                        'metrics_enabled': self.config.get('metrics_enabled', True),
                        'diff_visualization': self.config.get('diff_visualization', True)
    #                 },
                    'security_level': self.config.get('security_level', 'medium'),
                    'execution_timeout': self.config.get('execution_timeout', 30),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_CONFIG_ERROR"]
    self.logger.error(f"Failed to initialize Sandbox Integration: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to initialize Sandbox Integration: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def shutdown(self) -Dict[str, Any]):
    #         """
    #         Shutdown the Sandbox Integration.

    #         Returns:
    #             Dictionary containing shutdown result
    #         """
    #         try:
                self.logger.info("Shutting down Sandbox Integration")

    #             # Stop all active executions
                await self._stop_all_executions()

    #             # Stop background thread
                self._stop_background_thread()

    #             # Shutdown sandbox manager
                await self.sandbox_manager.shutdown()

    #             # Clean up temp directory
                await self._cleanup_temp_directory()

                self.logger.info("Sandbox Integration shutdown successfully")

    #             return {
    #                 'success': True,
    #                 'message': "Sandbox Integration shutdown successfully",
    #                 'performance_stats': self.performance_stats,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_CONFIG_ERROR"]
    self.logger.error(f"Failed to shutdown Sandbox Integration: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to shutdown Sandbox Integration: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def execute_code(self, file_path: str, code: str, auto_approve: bool = False) -Dict[str, Any]):
    #         """
    #         Execute code in sandbox.

    #         Args:
    #             file_path: Path to the file
    #             code: Code to execute
    #             auto_approve: Whether to auto-approve execution

    #         Returns:
    #             Dictionary containing execution result
    #         """
    #         try:
    execution_id = str(uuid.uuid4())

    #             # Create execution object
    execution = SandboxExecution(
    execution_id = execution_id,
    file_path = file_path,
    code = code
    #             )

    #             # Store execution
    self.executions[execution_id] = execution

    #             # Check if approval is needed
    #             if not auto_approve and self.config.get('approval_workflow', {}).get('enabled', True):
    approval_needed = await self._check_approval_needed(code)

    #                 if approval_needed:
    #                     # Add to pending approvals
    self.pending_approvals[execution_id] = {
    #                         'execution_id': execution_id,
    #                         'file_path': file_path,
    #                         'code': code,
                            'requested_at': datetime.now(),
    #                         'status': 'pending'
    #                     }

    #                     return {
    #                         'success': True,
    #                         'message': "Execution requires approval",
    #                         'execution_id': execution_id,
    #                         'status': 'pending_approval',
                            'request_id': str(uuid.uuid4())
    #                     }

    #             # Execute code
                await self._execute_in_sandbox(execution)

    #             return {
    #                 'success': True,
    #                 'message': "Code executed successfully",
    #                 'execution_id': execution_id,
                    'execution': execution.to_dict(),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_EXECUTION_FAILED"]
    self.logger.error(f"Error executing code: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error executing code: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def approve_execution(self, execution_id: str, approved: bool, reason: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         Approve or reject execution.

    #         Args:
    #             execution_id: Execution ID
    #             approved: Whether to approve execution
    #             reason: Optional reason for approval/rejection

    #         Returns:
    #             Dictionary containing approval result
    #         """
    #         try:
    #             if execution_id not in self.pending_approvals:
    #                 return {
    #                     'success': False,
    #                     'error': f"Execution not found or already processed: {execution_id}",
    #                     'error_code': SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_APPROVAL_FAILED"],
                        'request_id': str(uuid.uuid4())
    #                 }

    approval = self.pending_approvals[execution_id]

    #             if approved:
    #                 # Execute the code
    execution = SandboxExecution(
    execution_id = execution_id,
    file_path = approval['file_path'],
    code = approval['code']
    #                 )

    self.executions[execution_id] = execution
                    await self._execute_in_sandbox(execution)

    result = {
    #                     'success': True,
    #                     'message': "Execution approved and completed",
    #                     'execution_id': execution_id,
                        'execution': execution.to_dict(),
                        'request_id': str(uuid.uuid4())
    #                 }
    #             else:
    #                 # Reject execution
    result = {
    #                     'success': True,
    #                     'message': "Execution rejected",
    #                     'execution_id': execution_id,
    #                     'reason': reason,
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Remove from pending approvals
    #             del self.pending_approvals[execution_id]

    #             # Notify callbacks
                await self._notify_approval_callbacks(execution_id, approved, reason)

    #             return result

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_APPROVAL_FAILED"]
    self.logger.error(f"Error approving execution: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error approving execution: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def get_execution_status(self, execution_id: str) -Dict[str, Any]):
    #         """
    #         Get execution status.

    #         Args:
    #             execution_id: Execution ID

    #         Returns:
    #             Dictionary containing execution status
    #         """
    #         try:
    #             if execution_id in self.pending_approvals:
    approval = self.pending_approvals[execution_id]
    #                 return {
    #                     'success': True,
    #                     'execution_id': execution_id,
    #                     'status': 'pending_approval',
                        'requested_at': approval['requested_at'].isoformat(),
                        'request_id': str(uuid.uuid4())
    #                 }

    #             if execution_id not in self.executions:
    #                 return {
    #                     'success': False,
    #                     'error': f"Execution not found: {execution_id}",
    #                     'error_code': SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_EXECUTION_FAILED"],
                        'request_id': str(uuid.uuid4())
    #                 }

    execution = self.executions[execution_id]

    #             return {
    #                 'success': True,
                    'execution': execution.to_dict(),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_EXECUTION_FAILED"]
    self.logger.error(f"Error getting execution status: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error getting execution status: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def generate_diff(self, file_path: str, original_code: str, modified_code: str) -Dict[str, Any]):
    #         """
    #         Generate diff between original and modified code.

    #         Args:
    #             file_path: Path to the file
    #             original_code: Original code
    #             modified_code: Modified code

    #         Returns:
    #             Dictionary containing diff result
    #         """
    #         try:
    #             # Create diff object
    diff = SandboxDiff(file_path, original_code, modified_code)

    #             return {
    #                 'success': True,
                    'diff': diff.to_dict(),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_DIFF_FAILED"]
    self.logger.error(f"Error generating diff: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error generating diff: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def get_security_status(self, execution_id: str) -Dict[str, Any]):
    #         """
    #         Get security status for an execution.

    #         Args:
    #             execution_id: Execution ID

    #         Returns:
    #             Dictionary containing security status
    #         """
    #         try:
    #             if execution_id not in self.executions:
    #                 return {
    #                     'success': False,
    #                     'error': f"Execution not found: {execution_id}",
    #                     'error_code': SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_EXECUTION_FAILED"],
                        'request_id': str(uuid.uuid4())
    #                 }

    execution = self.executions[execution_id]
    security_status = await self._analyze_security(execution)

    #             return {
    #                 'success': True,
    #                 'execution_id': execution_id,
    #                 'security_status': security_status,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_MONITORING_FAILED"]
    self.logger.error(f"Error getting security status: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error getting security status: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def get_performance_metrics(self, execution_id: str) -Dict[str, Any]):
    #         """
    #         Get performance metrics for an execution.

    #         Args:
    #             execution_id: Execution ID

    #         Returns:
    #             Dictionary containing performance metrics
    #         """
    #         try:
    #             if execution_id not in self.executions:
    #                 return {
    #                     'success': False,
    #                     'error': f"Execution not found: {execution_id}",
    #                     'error_code': SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_EXECUTION_FAILED"],
                        'request_id': str(uuid.uuid4())
    #                 }

    execution = self.executions[execution_id]

    #             return {
    #                 'success': True,
    #                 'execution_id': execution_id,
    #                 'metrics': execution.metrics,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_METRICS_ERROR"]
    self.logger.error(f"Error getting performance metrics: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error getting performance metrics: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     def register_approval_callback(self, callback: Callable[[str, bool, Optional[str]], None]) -None):
    #         """
    #         Register a callback for approval notifications.

    #         Args:
    #             callback: Callback function that receives execution_id, approved, and reason
    #         """
            self.approval_callbacks.append(callback)

    #     def unregister_approval_callback(self, callback: Callable[[str, bool, Optional[str]], None]) -None):
    #         """
    #         Unregister an approval callback.

    #         Args:
    #             callback: Callback function to remove
    #         """
    #         if callback in self.approval_callbacks:
                self.approval_callbacks.remove(callback)

    #     async def _execute_in_sandbox(self, execution: SandboxExecution) -None):
    #         """
    #         Execute code in sandbox.

    #         Args:
    #             execution: Execution object
    #         """
    #         try:
    execution.status = "running"
    start_time = datetime.now()

    #             # Create temporary file
    temp_file = self.temp_dir / f"{execution.execution_id}.nc"
    #             with open(temp_file, 'w') as f:
                    f.write(execution.code)

    #             # Prepare execution environment
    execution_env = await self._prepare_execution_environment(execution)

    #             # Execute in sandbox
    result = await self.sandbox_manager.execute(
    file_path = str(temp_file),
    environment = execution_env,
    timeout = self.config.get('execution_timeout', 30)
    #             )

    #             # Update execution with results
    execution.end_time = datetime.now()
    #             execution.status = "completed" if result['success'] else "failed"
    execution.output = result.get('output')
    execution.error = result.get('error')
    execution.metrics = result.get('metrics', {})

    #             # Update performance stats
    execution_time = (execution.end_time - start_time.total_seconds())
                self._update_performance_stats(execution_time, result['success'])

    #             # Clean up temp file
    #             try:
                    temp_file.unlink()
    #             except:
    #                 pass

    #         except asyncio.TimeoutError:
    execution.status = "timeout"
    execution.end_time = datetime.now()
    execution.error = "Execution timed out"
                self._update_performance_stats(0, False)
    self.performance_stats['timeout_executions'] + = 1

    #         except Exception as e:
    execution.status = "failed"
    execution.end_time = datetime.now()
    execution.error = str(e)
                self._update_performance_stats(0, False)

    #     async def _prepare_execution_environment(self, execution: SandboxExecution) -Dict[str, Any]):
    #         """
    #         Prepare execution environment.

    #         Args:
    #             execution: Execution object

    #         Returns:
    #             Execution environment dictionary
    #         """
    #         try:
    env = self.config.get('execution', {}).get('default_environment', 'noodlecore')

    security_config = self.config.get('security', {})

    #             return {
    #                 'environment': env,
                    'security_level': self.config.get('security_level', 'medium'),
                    'allow_file_access': security_config.get('allow_file_access', False),
                    'allow_network_access': security_config.get('allow_network_access', False),
                    'allow_system_calls': security_config.get('allow_system_calls', False),
                    'max_memory_usage': security_config.get('max_memory_usage', 100),
                    'max_execution_time': security_config.get('max_execution_time', 30),
                    'allowed_imports': security_config.get('allowed_imports', []),
                    'blocked_imports': security_config.get('blocked_imports', []),
                    'working_directory': self.config.get('execution', {}).get('working_directory'),
                    'capture_output': self.config.get('execution', {}).get('capture_output', True),
                    'capture_errors': self.config.get('execution', {}).get('capture_errors', True)
    #             }

    #         except Exception as e:
    self.logger.error(f"Error preparing execution environment: {str(e)}", exc_info = True)
    #             return {}

    #     async def _check_approval_needed(self, code: str) -bool):
    #         """
    #         Check if approval is needed for code execution.

    #         Args:
    #             code: Code to check

    #         Returns:
    #             True if approval is needed
    #         """
    #         try:
    #             if not self.config.get('approval_workflow', {}).get('enabled', True):
    #                 return False

    #             # Check for auto-approve safe operations
    #             if self.config.get('auto_approve_safe', False):
    #                 if await self._is_safe_operation(code):
    #                     return False

    #             # Check for file system operations
    #             if self.config.get('approval_workflow', {}).get('require_approval_for_file_system', True):
    #                 if await self._has_file_operations(code):
    #                     return True

    #             # Check for network operations
    #             if self.config.get('approval_workflow', {}).get('require_approval_for_network', True):
    #                 if await self._has_network_operations(code):
    #                     return True

    #             # Check for system calls
    #             if self.config.get('approval_workflow', {}).get('require_approval_for_system_calls', True):
    #                 if await self._has_system_calls(code):
    #                     return True

    #             return False

    #         except Exception as e:
    self.logger.error(f"Error checking approval needed: {str(e)}", exc_info = True)
    #             return True  # Default to requiring approval

    #     async def _is_safe_operation(self, code: str) -bool):
    #         """
    #         Check if code is safe for auto-approval.

    #         Args:
    #             code: Code to check

    #         Returns:
    #             True if safe
    #         """
    #         try:
    #             # Simple heuristic for safe operations
    safe_patterns = [
    #                 r'^func\s+\w+',
    r'^var\s+\w+\s* = ',
    r'^const\s+\w+\s* = ',
    #                 r'^return\s+',
    #                 r'^if\s+',
    #                 r'^for\s+',
    #                 r'^while\s+',
                    r'^print\s*\(',
                    r'^console\.log\s*\('
    #             ]

    lines = code.strip().split('\n')

    #             for line in lines:
    line = line.strip()
    #                 if not line or line.startswith('#'):
    #                     continue

    #                 # Check if line matches any safe pattern
    is_safe = False
    #                 for pattern in safe_patterns:
    #                     if re.match(pattern, line):
    is_safe = True
    #                         break

    #                 if not is_safe:
    #                     return False

    #             return True

    #         except Exception as e:
    self.logger.error(f"Error checking safe operation: {str(e)}", exc_info = True)
    #             return False

    #     async def _has_file_operations(self, code: str) -bool):
    #         """Check if code has file operations."""
    file_patterns = [
                r'\bopen\s*\(',
                r'\bfile\s*\(',
                r'\bread\s*\(',
                r'\bwrite\s*\(',
                r'\bdelete\s*\(',
                r'\bremove\s*\(',
                r'\bcreate\s*\(',
                r'\bmakedirs?\s*\(',
                r'\bremovedirs?\s*\(',
    #             r'\bos\.path',
    #             r'\bpathlib'
    #         ]

    #         for pattern in file_patterns:
    #             if re.search(pattern, code, re.IGNORECASE):
    #                 return True

    #         return False

    #     async def _has_network_operations(self, code: str) -bool):
    #         """Check if code has network operations."""
    network_patterns = [
    #             r'\bhttp\.|https\.',
    #             r'\burllib|requests',
                r'\bsocket\s*\(',
                r'\bconnect\s*\(',
                r'\bsend\s*\(',
                r'\breceive\s*\(',
                r'\bfetch\s*\(',
                r'\bget\s*\(',
                r'\bpost\s*\(',
                r'\bput\s*\(',
                r'\bdelete\s*\('
    #         ]

    #         for pattern in network_patterns:
    #             if re.search(pattern, code, re.IGNORECASE):
    #                 return True

    #         return False

    #     async def _has_system_calls(self, code: str) -bool):
    #         """Check if code has system calls."""
    system_patterns = [
                r'\bos\.system\s*\(',
    #             r'\bsubprocess\.',
                r'\beval\s*\(',
                r'\bexec\s*\(',
                r'\bcompile\s*\(',
                r'\bglobals\s*\(\)',
                r'\blocals\s*\(\)',
                r'\b__import__\s*\(',
    #             r'\bimportlib\.',
    #             r'\bsys\.',
    #             r'\bshutil\.',
    #             r'\btempfile\.',
    #             r'\bcommands?\.'
    #         ]

    #         for pattern in system_patterns:
    #             if re.search(pattern, code, re.IGNORECASE):
    #                 return True

    #         return False

    #     async def _analyze_security(self, execution: SandboxExecution) -Dict[str, Any]):
    #         """
    #         Analyze security of execution.

    #         Args:
    #             execution: Execution object

    #         Returns:
    #             Security status dictionary
    #         """
    #         try:
    security_level = self.config.get('security_level', 'medium')

    #             return {
    #                 'security_level': security_level,
    #                 'status': 'safe',
    #                 'violations': [],
    #                 'warnings': [],
    #                 'blocked_operations': [],
    #                 'file_access': False,
    #                 'network_access': False,
    #                 'system_calls': False
    #             }

    #         except Exception as e:
    self.logger.error(f"Error analyzing security: {str(e)}", exc_info = True)
    #             return {
    #                 'security_level': 'unknown',
    #                 'status': 'error',
                    'error': str(e)
    #             }

    #     async def _notify_approval_callbacks(self, execution_id: str, approved: bool, reason: Optional[str]) -None):
    #         """
    #         Notify approval callbacks.

    #         Args:
    #             execution_id: Execution ID
    #             approved: Whether approved
    #             reason: Optional reason
    #         """
    #         try:
    #             for callback in self.approval_callbacks:
    #                 try:
                        callback(execution_id, approved, reason)
    #                 except Exception as e:
    self.logger.error(f"Error in approval callback: {str(e)}", exc_info = True)
    #         except Exception as e:
    self.logger.error(f"Error notifying approval callbacks: {str(e)}", exc_info = True)

    #     async def _stop_all_executions(self) -None):
    #         """Stop all active executions."""
    #         try:
    #             for execution_id, execution in self.executions.items():
    #                 if execution.status == "running":
    execution.status = "stopped"
    execution.end_time = datetime.now()
    execution.error = "Execution stopped during shutdown"

                self.executions.clear()
                self.pending_approvals.clear()

    #         except Exception as e:
    self.logger.error(f"Error stopping all executions: {str(e)}", exc_info = True)

    #     async def _cleanup_temp_directory(self) -None):
    #         """Clean up temporary directory."""
    #         try:
    #             for file_path in self.temp_dir.glob("*"):
    #                 try:
    #                     if file_path.is_file():
                            file_path.unlink()
    #                 except:
    #                     pass
    #         except Exception as e:
    self.logger.error(f"Error cleaning up temp directory: {str(e)}", exc_info = True)

    #     def _start_background_thread(self) -None):
    #         """Start background thread for async operations."""
    #         try:
    #             if self.background_thread is None or not self.background_thread.is_alive():
    self.running = True
    self.background_thread = threading.Thread(target=self._background_thread_loop)
    self.background_thread.daemon = True
                    self.background_thread.start()
    #         except Exception as e:
    self.logger.error(f"Error starting background thread: {str(e)}", exc_info = True)

    #     def _stop_background_thread(self) -None):
    #         """Stop background thread."""
    #         try:
    self.running = False
    #             if self.background_thread and self.background_thread.is_alive():
    self.background_thread.join(timeout = 1.0)
    #         except Exception as e:
    self.logger.error(f"Error stopping background thread: {str(e)}", exc_info = True)

    #     def _background_thread_loop(self) -None):
    #         """Background thread loop for async operations."""
    #         try:
    self.event_loop = asyncio.new_event_loop()
                asyncio.set_event_loop(self.event_loop)

    #             # Run event loop until stopped
    #             while self.running:
                    self.event_loop.run_until_complete(asyncio.sleep(0.1))

    #         except Exception as e:
    self.logger.error(f"Error in background thread loop: {str(e)}", exc_info = True)
    #         finally:
    #             if self.event_loop:
                    self.event_loop.close()

    #     async def _load_config(self) -Dict[str, Any]):
    #         """Load sandbox configuration."""
    #         try:
    #             if self.config_file.exists():
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    config = json.load(f)

    #                 # Merge with default config
    merged_config = self._merge_configs(self.default_config, config)
    #                 return merged_config
    #             else:
    #                 # Create default config file
                    await self._save_config(self.default_config)
                    return self.default_config.copy()

            except (json.JSONDecodeError, IOError) as e:
    self.logger.error(f"Error loading sandbox config: {str(e)}", exc_info = True)
                return self.default_config.copy()

    #     async def _save_config(self, config: Dict[str, Any]) -None):
    #         """Save sandbox configuration."""
    #         try:
    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent = 2)
    #         except IOError as e:
    self.logger.error(f"Error saving sandbox config: {str(e)}", exc_info = True)

    #     def _merge_configs(self, default: Dict[str, Any], custom: Dict[str, Any]) -Dict[str, Any]):
    #         """Merge custom config with default config."""
    result = default.copy()

    #         for key, value in custom.items():
    #             if key in result and isinstance(result[key], dict) and isinstance(value, dict):
    result[key] = self._merge_configs(result[key], value)
    #             else:
    result[key] = value

    #         return result

    #     def _update_performance_stats(self, execution_time: float, success: bool) -None):
    #         """Update performance statistics."""
    self.performance_stats['total_executions'] + = 1

    #         if success:
    self.performance_stats['successful_executions'] + = 1
    self.performance_stats['total_execution_time'] + = execution_time
    self.performance_stats['average_execution_time'] = (
    #                 self.performance_stats['total_execution_time'] /
    #                 self.performance_stats['successful_executions']
    #             )
    #         else:
    self.performance_stats['failed_executions'] + = 1

    #     async def get_integration_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the Sandbox Integration.

    #         Returns:
    #             Dictionary containing integration information
    #         """
    #         try:
    #             return {
    #                 'name': self.name,
    #                 'version': '1.0.0',
    #                 'features': {
                        'preview_enabled': self.config.get('preview_enabled', True),
                        'auto_approve_safe': self.config.get('auto_approve_safe', False),
                        'monitoring_enabled': self.config.get('monitoring_enabled', True),
                        'metrics_enabled': self.config.get('metrics_enabled', True),
                        'diff_visualization': self.config.get('diff_visualization', True)
    #                 },
                    'security_level': self.config.get('security_level', 'medium'),
                    'execution_timeout': self.config.get('execution_timeout', 30),
    #                 'performance_stats': self.performance_stats,
                    'active_executions': len(self.executions),
                    'pending_approvals': len(self.pending_approvals),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = SANDBOX_INTEGRATION_ERROR_CODES["SANDBOX_CONFIG_ERROR"]
    self.logger.error(f"Error getting integration info: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error getting integration info: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }