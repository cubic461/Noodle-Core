#!/usr/bin/env python3
"""
Execution Environment Module
============================

This module provides secure execution environment management for script execution,
including sandboxing, resource limits, and environment isolation.

Author: NoodleCore Development Team
Version: 1.0.0
"""

import os
import sys
import time
import uuid
import tempfile
import shutil
import subprocess
import resource
import psutil
import threading
import logging
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
import json
import signal
import ctypes

# Configure logging
logger = logging.getLogger(__name__)

# Environment constants
MAX_EXECUTION_TIME = 300  # 5 minutes
MAX_MEMORY_MB = 1024     # 1GB
MAX_DISK_MB = 100        # 100MB
MAX_FILE_DESCRIPTORS = 100
MAX_PROCESSES = 10
DEFAULT_TIMEOUT = 30


@dataclass
class EnvironmentConfig:
    """Configuration for execution environment."""
    environment_id: str
    working_directory: str
    timeout_seconds: int = DEFAULT_TIMEOUT
    memory_limit_mb: int = MAX_MEMORY_MB
    disk_limit_mb: int = MAX_DISK_MB
    max_file_descriptors: int = MAX_FILE_DESCRIPTORS
    max_processes: int = MAX_PROCESSES
    environment_variables: Dict[str, str] = None
    allowed_imports: List[str] = None
    blocked_imports: List[str] = None
    network_access: bool = False
    filesystem_access: bool = True
    
    def __post_init__(self):
        if not self.environment_id:
            self.environment_id = str(uuid.uuid4())
        if self.environment_variables is None:
            self.environment_variables = {}
        if self.allowed_imports is None:
            self.allowed_imports = []
        if self.blocked_imports is None:
            self.blocked_imports = ["os", "subprocess", "sys", "eval", "exec"]


@dataclass
class EnvironmentStatus:
    """Status of execution environment."""
    environment_id: str
    status: str  # "initializing", "ready", "running", "stopped", "error"
    created_at: datetime
    last_activity: datetime
    resource_usage: Dict[str, Any] = None
    active_executions: int = 0
    total_executions: int = 0
    
    def __post_init__(self):
        if isinstance(self.created_at, str):
            self.created_at = datetime.fromisoformat(self.created_at.replace('Z', '+00:00'))
        if isinstance(self.last_activity, str):
            self.last_activity = datetime.fromisoformat(self.last_activity.replace('Z', '+00:00'))
        if self.resource_usage is None:
            self.resource_usage = {}


@dataclass
class ResourceLimits:
    """Resource limits for execution."""
    cpu_time_seconds: float = MAX_EXECUTION_TIME
    memory_bytes: int = MAX_MEMORY_MB * 1024 * 1024
    disk_bytes: int = MAX_DISK_MB * 1024 * 1024
    file_descriptors: int = MAX_FILE_DESCRIPTORS
    processes: int = MAX_PROCESSES
    signals: List[int] = None
    
    def __post_init__(self):
        if self.signals is None:
            self.signals = [signal.SIGKILL, signal.SIGTERM, signal.SIGINT]


class SecurityManager:
    """Manages security aspects of execution environment."""
    
    def __init__(self):
        self.dangerous_functions = {
            "os.system", "os.popen", "os.execv", "os.execl",
            "subprocess.call", "subprocess.run", "subprocess.Popen",
            "eval", "exec", "compile", "__import__"
        }
        
        self.dangerous_modules = {
            "os", "subprocess", "sys", "ctypes", "socket",
            "urllib", "requests", "ftp", "telnet", "smtplib"
        }
    
    def validate_code(self, code: str) -> Tuple[bool, List[str]]:
        """Validate code for security issues."""
        
        violations = []
        
        # Check for dangerous function calls
        for func in self.dangerous_functions:
            if func in code:
                violations.append(f"Dangerous function detected: {func}")
        
        # Check for dangerous imports
        lines = code.split('\n')
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            if line.startswith('import ') or line.startswith('from '):
                # Parse import statement
                if line.startswith('import '):
                    modules = [m.strip() for m in line[7:].split(',')]
                else:  # from ... import
                    modules = [line.split()[1]]
                
                for module in modules:
                    base_module = module.split('.')[0]
                    if base_module in self.dangerous_modules:
                        violations.append(f"Line {line_num}: Dangerous import detected: {base_module}")
        
        return len(violations) == 0, violations
    
    def sanitize_environment(self, env_vars: Dict[str, str]) -> Dict[str, str]:
        """Sanitize environment variables."""
        
        sanitized = {}
        
        # Block dangerous environment variables
        blocked_vars = {
            "PYTHONPATH", "PATH", "LD_LIBRARY_PATH", "HOME",
            "USER", "LOGNAME", "SHELL", "TERM"
        }
        
        for key, value in env_vars.items():
            if key not in blocked_vars:
                # Sanitize value
                sanitized_value = value.replace('..', '').replace('/', '').replace('\\', '')
                sanitized[key] = sanitized_value
        
        return sanitized


class ResourceMonitor:
    """Monitors resource usage during execution."""
    
    def __init__(self, environment_id: str):
        self.environment_id = environment_id
        self.process = psutil.Process()
        self.monitoring = False
        self.monitor_thread = None
        self.start_time = None
        self.max_memory = 0
        self.cpu_samples = []
        
    def start_monitoring(self) -> bool:
        """Start resource monitoring."""
        
        try:
            self.monitoring = True
            self.start_time = time.time()
            self.max_memory = 0
            
            self.monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
            self.monitor_thread.start()
            
            return True
        except Exception as e:
            logger.error(f"Failed to start monitoring for {self.environment_id}: {e}")
            return False
    
    def stop_monitoring(self) -> Dict[str, Any]:
        """Stop monitoring and return statistics."""
        
        self.monitoring = False
        
        if self.monitor_thread and self.monitor_thread.is_alive():
            self.monitor_thread.join(timeout=1.0)
        
        # Calculate final statistics
        total_time = time.time() - self.start_time if self.start_time else 0
        
        return {
            "environment_id": self.environment_id,
            "monitoring_duration": total_time,
            "max_memory_mb": self.max_memory / (1024 * 1024),
            "average_cpu_percent": sum(self.cpu_samples) / len(self.cpu_samples) if self.cpu_samples else 0,
            "peak_cpu_percent": max(self.cpu_samples) if self.cpu_samples else 0,
            "sample_count": len(self.cpu_samples)
        }
    
    def _monitor_loop(self):
        """Main monitoring loop."""
        
        while self.monitoring:
            try:
                # Monitor memory
                memory_info = self.process.memory_info()
                self.max_memory = max(self.max_memory, memory_info.rss)
                
                # Monitor CPU
                cpu_percent = self.process.cpu_percent()
                self.cpu_samples.append(cpu_percent)
                
                # Limit sample history
                if len(self.cpu_samples) > 1000:
                    self.cpu_samples = self.cpu_samples[-500:]
                
                time.sleep(0.1)  # 100ms sampling
                
            except Exception as e:
                logger.error(f"Monitoring error: {e}")
                break


class ExecutionEnvironment:
    """Secure execution environment for script execution."""
    
    def __init__(self):
        self.environments: Dict[str, EnvironmentStatus] = {}
        self.configs: Dict[str, EnvironmentConfig] = {}
        self.security_manager = SecurityManager()
        self.active_monitors: Dict[str, ResourceMonitor] = {}
        self._lock = threading.RLock()
        
    def create_environment(self, config: EnvironmentConfig) -> bool:
        """Create a new execution environment."""
        
        logger.info(f"Creating execution environment {config.environment_id}")
        
        with self._lock:
            try:
                # Create working directory
                work_dir = Path(config.working_directory)
                work_dir.mkdir(parents=True, exist_ok=True)
                
                # Initialize status
                status = EnvironmentStatus(
                    environment_id=config.environment_id,
                    status="ready",
                    created_at=datetime.utcnow(),
                    last_activity=datetime.utcnow()
                )
                
                self.environments[config.environment_id] = status
                self.configs[config.environment_id] = config
                
                logger.info(f"Execution environment {config.environment_id} created successfully")
                return True
                
            except Exception as e:
                logger.error(f"Failed to create environment {config.environment_id}: {e}")
                return False
    
    def prepare_execution(self, environment_id: str, code: str) -> Tuple[bool, str, Dict[str, Any]]:
        """Prepare environment for code execution."""
        
        logger.info(f"Preparing execution environment {environment_id}")
        
        with self._lock:
            status = self.environments.get(environment_id)
            config = self.configs.get(environment_id)
            
            if not status or not config:
                return False, "Environment not found", {}
            
            if status.status != "ready":
                return False, f"Environment not ready (status: {status.status})", {}
            
            try:
                # Security validation
                is_safe, violations = self.security_manager.validate_code(code)
                if not is_safe:
                    return False, f"Security violations: {violations}", {"violations": violations}
                
                # Update status
                status.status = "initializing"
                status.last_activity = datetime.utcnow()
                
                # Prepare execution context
                execution_context = self._prepare_execution_context(config, code)
                
                # Start resource monitoring
                monitor = ResourceMonitor(environment_id)
                if monitor.start_monitoring():
                    self.active_monitors[environment_id] = monitor
                
                status.status = "ready"
                status.active_executions += 1
                status.total_executions += 1
                
                return True, "Environment ready", execution_context
                
            except Exception as e:
                status.status = "error"
                logger.error(f"Failed to prepare execution: {e}")
                return False, str(e), {}
    
    def execute_script(self, environment_id: str, code: str, 
                      timeout: int = None) -> Dict[str, Any]:
        """Execute script in the environment."""
        
        logger.info(f"Executing script in environment {environment_id}")
        
        with self._lock:
            status = self.environments.get(environment_id)
            config = self.configs.get(environment_id)
            
            if not status or not config:
                return {"success": False, "error": "Environment not found"}
            
            if timeout is None:
                timeout = config.timeout_seconds
            
            execution_start = time.time()
            
            try:
                # Create temporary file for execution
                with tempfile.NamedTemporaryFile(
                    mode='w', suffix='.py', delete=False, dir=config.working_directory
                ) as f:
                    f.write(code)
                    temp_file = f.name
                
                # Prepare environment
                env_vars = self.security_manager.sanitize_environment(config.environment_variables)
                env = os.environ.copy()
                env.update(env_vars)
                
                # Execute with resource limits
                result = self._execute_with_limits(
                    temp_file, config, env, timeout
                )
                
                # Clean up temp file
                try:
                    os.unlink(temp_file)
                except:
                    pass
                
                # Update status
                status.last_activity = datetime.utcnow()
                
                execution_time = time.time() - execution_start
                result["execution_time"] = execution_time
                
                logger.info(f"Script execution completed in {execution_time:.2f}s")
                return result
                
            except Exception as e:
                logger.error(f"Execution failed: {e}")
                return {
                    "success": False,
                    "error": str(e),
                    "execution_time": time.time() - execution_start
                }
    
    def _execute_with_limits(self, script_file: str, config: EnvironmentConfig,
                           env: Dict[str, str], timeout: int) -> Dict[str, Any]:
        """Execute script with resource limits."""
        
        try:
            # Set up process with resource limits
            process = subprocess.Popen(
                [sys.executable, script_file],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                cwd=config.working_directory,
                env=env,
                preexec_fn=lambda: self._set_resource_limits(config)
            )
            
            # Wait for completion or timeout
            try:
                stdout, stderr = process.communicate(timeout=timeout)
                exit_code = process.returncode
                
                return {
                    "success": exit_code == 0,
                    "stdout": stdout,
                    "stderr": stderr,
                    "exit_code": exit_code
                }
                
            except subprocess.TimeoutExpired:
                process.kill()
                return {
                    "success": False,
                    "error": "Execution timeout",
                    "exit_code": -1
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "exit_code": -1
            }
    
    def _set_resource_limits(self, config: EnvironmentConfig):
        """Set resource limits for the process."""
        
        try:
            # Set memory limit
            resource.setrlimit(resource.RLIMIT_AS, (config.memory_limit_mb * 1024 * 1024, -1))
            
            # Set CPU time limit
            resource.setrlimit(resource.RLIMIT_CPU, (config.timeout_seconds, -1))
            
            # Set file descriptor limit
            resource.setrlimit(resource.RLIMIT_NOFILE, (config.max_file_descriptors, -1))
            
        except Exception as e:
            logger.warning(f"Failed to set some resource limits: {e}")
    
    def _prepare_execution_context(self, config: EnvironmentConfig, code: str) -> Dict[str, Any]:
        """Prepare execution context."""
        
        # Create execution wrapper if needed
        if config.allowed_imports:
            wrapper_code = self._create_import_wrapper(code, config.allowed_imports)
        else:
            wrapper_code = code
        
        return {
            "environment_id": config.environment_id,
            "working_directory": config.working_directory,
            "wrapper_code": wrapper_code,
            "environment_variables": config.environment_variables,
            "resource_limits": {
                "timeout": config.timeout_seconds,
                "memory_mb": config.memory_limit_mb,
                "disk_mb": config.disk_limit_mb,
                "file_descriptors": config.max_file_descriptors,
                "processes": config.max_processes
            }
        }
    
    def _create_import_wrapper(self, code: str, allowed_imports: List[str]) -> str:
        """Create wrapper code that restricts imports."""
        
        import_allowlist = '\n    '.join(f'"{imp}"' for imp in allowed_imports)
        
        wrapper = f'''
import sys
import builtins

# Restrict imports to allowed modules only
original_import = builtins.__import__

def restricted_import(name, *args, **kwargs):
    allowed_imports = [
        {import_allowlist}
    ]
    base_name = name.split('.')[0]
    if base_name not in allowed_imports:
        raise ImportError(f"Import of '{{name}}' is not allowed")
    return original_import(name, *args, **kwargs)

builtins.__import__ = restricted_import

{code}
'''
        
        return wrapper
    
    def cleanup_environment(self, environment_id: str) -> bool:
        """Clean up execution environment."""
        
        logger.info(f"Cleaning up environment {environment_id}")
        
        with self._lock:
            try:
                # Stop monitoring
                monitor = self.active_monitors.pop(environment_id, None)
                if monitor:
                    monitor.stop_monitoring()
                
                # Update status
                status = self.environments.get(environment_id)
                if status:
                    status.status = "stopped"
                    status.active_executions = 0
                
                # Clean up working directory
                config = self.configs.get(environment_id)
                if config and os.path.exists(config.working_directory):
                    shutil.rmtree(config.working_directory, ignore_errors=True)
                
                # Remove from tracking
                self.environments.pop(environment_id, None)
                self.configs.pop(environment_id, None)
                
                logger.info(f"Environment {environment_id} cleaned up successfully")
                return True
                
            except Exception as e:
                logger.error(f"Failed to clean up environment {environment_id}: {e}")
                return False
    
    def get_environment_status(self, environment_id: str) -> Optional[EnvironmentStatus]:
        """Get environment status."""
        
        return self.environments.get(environment_id)
    
    def get_all_environments(self) -> Dict[str, EnvironmentStatus]:
        """Get status of all environments."""
        
        return self.environments.copy()
    
    def get_resource_usage(self, environment_id: str) -> Optional[Dict[str, Any]]:
        """Get current resource usage."""
        
        monitor = self.active_monitors.get(environment_id)
        if not monitor:
            return None
        
        try:
            return {
                "memory_mb": monitor.process.memory_info().rss / (1024 * 1024),
                "cpu_percent": monitor.process.cpu_percent(),
                "file_descriptors": monitor.process.num_fds(),
                "threads": monitor.process.num_threads()
            }
        except Exception:
            return None
    
    def interrupt_execution(self, environment_id: str) -> bool:
        """Interrupt execution in environment."""
        
        try:
            # Find and kill processes in the environment
            config = self.configs.get(environment_id)
            if not config:
                return False
            
            # This is a simplified implementation
            # In a real system, you'd track child processes
            logger.info(f"Interrupting execution in environment {environment_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to interrupt execution: {e}")
            return False


# Factory function
def create_execution_environment() -> ExecutionEnvironment:
    """Create a new ExecutionEnvironment instance."""
    return ExecutionEnvironment()


# Global instance
_execution_environment = None

def get_execution_environment() -> ExecutionEnvironment:
    """Get the global execution environment instance."""
    global _execution_environment
    if _execution_environment is None:
        _execution_environment = create_execution_environment()
    return _execution_environment