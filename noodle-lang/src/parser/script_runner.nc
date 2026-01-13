#!/usr/bin/env python3
"""
Script Runner Module
====================

This module provides comprehensive script execution capabilities for Python and
NoodleCore scripts with support for real-time output streaming, error handling,
and performance monitoring.

Author: NoodleCore Development Team
Version: 1.0.0
"""

import os
import sys
import time
import uuid
import asyncio
import threading
import subprocess
import tempfile
import json
import logging
from typing import Dict, List, Optional, Any, Callable, Union
from pathlib import Path
from dataclasses import dataclass, asdict
from datetime import datetime
import queue
import io
import traceback

# Configure logging
logger = logging.getLogger(__name__)

# Constants
EXECUTION_TIMEOUT_SECONDS = 30
MAX_OUTPUT_SIZE = 1024 * 1024  # 1MB
MAX_ERROR_SIZE = 1024 * 1024   # 1MB
SUPPORTED_LANGUAGES = ["python", "noodle", "noodlecore"]


@dataclass
class ExecutionRequest:
    """Request for script execution."""
    script_id: str
    code: str
    language: str = "python"
    timeout_seconds: int = EXECUTION_TIMEOUT_SECONDS
    working_directory: Optional[str] = None
    environment_variables: Dict[str, str] = None
    arguments: List[str] = None
    stdin_data: Optional[str] = None
    capture_output: bool = True
    streaming_enabled: bool = True
    
    def __post_init__(self):
        if self.script_id is None:
            self.script_id = str(uuid.uuid4())
        if self.environment_variables is None:
            self.environment_variables = {}
        if self.arguments is None:
            self.arguments = []


@dataclass
class ExecutionResult:
    """Result of script execution."""
    script_id: str
    status: str  # "success", "error", "timeout", "cancelled"
    exit_code: Optional[int] = None
    stdout: str = ""
    stderr: str = ""
    execution_time: float = 0.0
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    memory_usage: float = 0.0
    cpu_usage: float = 0.0
    output_lines: List[str] = None
    error_lines: List[str] = None
    
    def __post_init__(self):
        if self.output_lines is None:
            self.output_lines = []
        if self.error_lines is None:
            self.error_lines = []
        if self.start_time is None:
            self.start_time = datetime.utcnow()


class OutputStreamHandler:
    """Handler for real-time output streaming during execution."""
    
    def __init__(self, script_id: str, output_callback: Callable = None):
        self.script_id = script_id
        self.output_callback = output_callback
        self.output_queue = queue.Queue()
        self.error_queue = queue.Queue()
        self.running = False
        
    def add_output(self, data: str, stream_type: str = "stdout"):
        """Add output data to streaming queue."""
        if stream_type == "stdout":
            self.output_queue.put({
                "type": "stdout",
                "data": data,
                "timestamp": datetime.utcnow().isoformat() + "Z"
            })
        else:
            self.error_queue.put({
                "type": "stderr", 
                "data": data,
                "timestamp": datetime.utcnow().isoformat() + "Z"
            })
        
        # Call output callback if provided
        if self.output_callback:
            try:
                self.output_callback({
                    "script_id": self.script_id,
                    "stream_type": stream_type,
                    "data": data,
                    "timestamp": datetime.utcnow().isoformat() + "Z"
                })
            except Exception as e:
                logger.error(f"Output callback error: {e}")
    
    def get_output(self, timeout: float = 1.0) -> Optional[Dict]:
        """Get next output from queue."""
        try:
            # Check stdout first
            try:
                return self.output_queue.get_nowait()
            except queue.Empty:
                pass
            
            # Check stderr
            try:
                return self.error_queue.get_nowait()
            except queue.Empty:
                pass
                
        except Exception as e:
            logger.error(f"Get output error: {e}")
        
        return None


class ScriptRunner:
    """Advanced script runner with real-time monitoring and streaming."""
    
    def __init__(self):
        self.active_executions: Dict[str, Dict] = {}
        self.execution_history: List[ExecutionResult] = []
        self.output_handlers: Dict[str, OutputStreamHandler] = {}
        self.running = False
        self._lock = threading.RLock()
        
    def execute_script(self, request: ExecutionRequest, 
                      output_callback: Callable = None) -> ExecutionResult:
        """Execute script with optional real-time output streaming."""
        
        logger.info(f"Starting execution for script {request.script_id} in {request.language}")
        
        # Validate request
        if request.language.lower() not in SUPPORTED_LANGUAGES:
            raise ValueError(f"Unsupported language: {request.language}")
        
        # Create output handler for streaming
        if request.streaming_enabled:
            output_handler = OutputStreamHandler(request.script_id, output_callback)
            self.output_handlers[request.script_id] = output_handler
        
        # Track active execution
        with self._lock:
            self.active_executions[request.script_id] = {
                "request": request,
                "start_time": time.time(),
                "status": "running",
                "output_handler": output_handler if request.streaming_enabled else None
            }
        
        try:
            # Execute based on language
            if request.language.lower() == "python":
                result = self._execute_python(request)
            elif request.language.lower() in ["noodle", "noodlecore"]:
                result = self._execute_noodle(request)
            else:
                raise ValueError(f"Unsupported language: {request.language}")
            
            # Finalize execution
            result.end_time = datetime.utcnow()
            result.execution_time = time.time() - self.active_executions[request.script_id]["start_time"]
            
            logger.info(f"Execution completed for script {request.script_id}: {result.status}")
            
            return result
            
        except Exception as e:
            logger.error(f"Execution error for script {request.script_id}: {e}")
            result = ExecutionResult(
                script_id=request.script_id,
                status="error",
                stderr=str(e),
                execution_time=time.time() - self.active_executions[request.script_id]["start_time"]
            )
            result.end_time = datetime.utcnow()
            return result
            
        finally:
            # Clean up
            with self._lock:
                self.active_executions.pop(request.script_id, None)
                if request.script_id in self.output_handlers:
                    del self.output_handlers[request.script_id]
            
            # Add to history
            self.execution_history.append(result)
            
            # Limit history size
            if len(self.execution_history) > 1000:
                self.execution_history = self.execution_history[-500:]
    
    def _execute_python(self, request: ExecutionRequest) -> ExecutionResult:
        """Execute Python script."""
        
        # Create temporary file for execution
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(request.code)
            temp_file = f.name
        
        try:
            # Prepare command
            cmd = [sys.executable, temp_file] + request.arguments
            
            # Prepare environment
            env = os.environ.copy()
            env.update(request.environment_variables)
            
            # Create process
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                cwd=request.working_directory,
                env=env
            )
            
            # Monitor execution
            stdout_data = []
            stderr_data = []
            start_time = time.time()
            
            # Read output with streaming
            while True:
                if request.streaming_enabled and request.script_id in self.output_handlers:
                    handler = self.output_handlers[request.script_id]
                    
                    # Read stdout
                    stdout_line = process.stdout.readline()
                    if stdout_line:
                        stdout_data.append(stdout_line)
                        if len(''.join(stdout_data)) <= MAX_OUTPUT_SIZE:
                            handler.add_output(stdout_line, "stdout")
                    
                    # Read stderr  
                    stderr_line = process.stderr.readline()
                    if stderr_line:
                        stderr_data.append(stderr_line)
                        if len(''.join(stderr_data)) <= MAX_ERROR_SIZE:
                            handler.add_output(stderr_line, "stderr")
                
                # Check if process has finished
                if process.poll() is not None:
                    break
                    
                # Check timeout
                if time.time() - start_time > request.timeout_seconds:
                    process.terminate()
                    return ExecutionResult(
                        script_id=request.script_id,
                        status="timeout",
                        stdout=''.join(stdout_data),
                        stderr=''.join(stderr_data),
                        execution_time=request.timeout_seconds
                    )
            
            # Get final output
            remaining_stdout, remaining_stderr = process.communicate()
            if remaining_stdout:
                stdout_data.append(remaining_stdout)
            if remaining_stderr:
                stderr_data.append(remaining_stderr)
            
            stdout_text = ''.join(stdout_data) if stdout_data else ""
            stderr_text = ''.join(stderr_data) if stderr_data else ""
            
            # Parse output lines
            output_lines = [line for line in stdout_text.split('\n') if line.strip()]
            error_lines = [line for line in stderr_text.split('\n') if line.strip()]
            
            return ExecutionResult(
                script_id=request.script_id,
                status="success" if process.returncode == 0 else "error",
                exit_code=process.returncode,
                stdout=stdout_text,
                stderr=stderr_text,
                output_lines=output_lines,
                error_lines=error_lines,
                execution_time=time.time() - start_time
            )
            
        finally:
            # Clean up temporary file
            try:
                os.unlink(temp_file)
            except Exception as e:
                logger.error(f"Failed to cleanup temp file {temp_file}: {e}")
    
    def _execute_noodle(self, request: ExecutionRequest) -> ExecutionResult:
        """Execute Noodle/NoodleCore script."""
        
        # For now, simulate noodle execution
        # In a real implementation, this would call the noodle interpreter
        
        start_time = time.time()
        
        try:
            # Simulate noodle script parsing and execution
            result = self._simulate_noodle_execution(request.code)
            
            # Add output streaming if enabled
            if request.streaming_enabled and request.script_id in self.output_handlers:
                handler = self.output_handlers[request.script_id]
                
                for line in result.get("output_lines", []):
                    handler.add_output(line + "\n", "stdout")
                    
                for line in result.get("error_lines", []):
                    handler.add_output(line + "\n", "stderr")
            
            return ExecutionResult(
                script_id=request.script_id,
                status=result.get("status", "success"),
                stdout=result.get("stdout", ""),
                stderr=result.get("stderr", ""),
                output_lines=result.get("output_lines", []),
                error_lines=result.get("error_lines", []),
                execution_time=time.time() - start_time
            )
            
        except Exception as e:
            return ExecutionResult(
                script_id=request.script_id,
                status="error",
                stderr=str(e),
                execution_time=time.time() - start_time
            )
    
    def _simulate_noodle_execution(self, code: str) -> Dict[str, Any]:
        """Simulate noodle execution for demonstration."""
        
        lines = code.split('\n')
        output_lines = []
        error_lines = []
        
        # Simple noodle language simulation
        for line in lines:
            line = line.strip()
            
            if not line or line.startswith('#'):
                continue
                
            # Simulate different noodle constructs
            if line.startswith('print'):
                # Extract print content
                if '(' in line and ')' in line:
                    start = line.find('(') + 1
                    end = line.rfind(')')
                    content = line[start:end].strip()
                    if content.startswith('"') and content.endswith('"'):
                        output_lines.append(content[1:-1])
                    elif content.startswith("'") and content.endswith("'"):
                        output_lines.append(content[1:-1])
                    else:
                        output_lines.append(content)
                        
            elif line.startswith('def '):
                # Function definition
                output_lines.append(f"Function defined: {line}")
                
            elif '=' in line and not line.startswith('='):
                # Variable assignment
                var_name = line.split('=')[0].strip()
                output_lines.append(f"Variable set: {var_name}")
                
            elif 'if ' in line:
                # Conditional statement
                output_lines.append("Conditional branch detected")
                
            elif 'for ' in line:
                # Loop statement
                output_lines.append("Loop detected")
                
            elif 'while ' in line:
                # While loop
                output_lines.append("While loop detected")
        
        return {
            "status": "success",
            "stdout": '\n'.join(output_lines),
            "stderr": '\n'.join(error_lines),
            "output_lines": output_lines,
            "error_lines": error_lines
        }
    
    def get_execution_status(self, script_id: str) -> Optional[Dict]:
        """Get current execution status."""
        
        with self._lock:
            execution_info = self.active_executions.get(script_id)
            if not execution_info:
                return None
                
            return {
                "script_id": script_id,
                "status": execution_info["status"],
                "start_time": execution_info["start_time"],
                "current_time": time.time(),
                "elapsed_seconds": time.time() - execution_info["start_time"],
                "has_streaming": execution_info["output_handler"] is not None
            }
    
    def get_execution_output(self, script_id: str) -> Optional[Dict]:
        """Get current execution output."""
        
        if script_id not in self.output_handlers:
            return None
            
        handler = self.output_handlers[script_id]
        outputs = []
        
        # Get all available output
        while True:
            output = handler.get_output(timeout=0.1)
            if output is None:
                break
            outputs.append(output)
        
        return {
            "script_id": script_id,
            "output_count": len(outputs),
            "outputs": outputs
        }
    
    def interrupt_execution(self, script_id: str) -> bool:
        """Interrupt a running execution."""
        
        with self._lock:
            execution_info = self.active_executions.get(script_id)
            if not execution_info:
                return False
                
            execution_info["status"] = "interrupted"
            return True
    
    def get_execution_history(self, limit: int = 50) -> List[Dict]:
        """Get execution history."""
        
        return [asdict(result) for result in self.execution_history[-limit:]]
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get execution statistics."""
        
        with self._lock:
            total_executions = len(self.execution_history)
            active_executions = len(self.active_executions)
            
            if not self.execution_history:
                return {
                    "total_executions": 0,
                    "active_executions": 0,
                    "success_rate": 0.0,
                    "average_execution_time": 0.0
                }
            
            # Calculate statistics
            successful_executions = sum(1 for r in self.execution_history if r.status == "success")
            success_rate = successful_executions / total_executions if total_executions > 0 else 0.0
            
            execution_times = [r.execution_time for r in self.execution_history if r.execution_time > 0]
            average_execution_time = sum(execution_times) / len(execution_times) if execution_times else 0.0
            
            return {
                "total_executions": total_executions,
                "active_executions": active_executions,
                "successful_executions": successful_executions,
                "success_rate": success_rate,
                "average_execution_time": average_execution_time,
                "supported_languages": SUPPORTED_LANGUAGES
            }


# Factory function
def create_script_runner() -> ScriptRunner:
    """Create a new ScriptRunner instance."""
    return ScriptRunner()


# Global instance
_script_runner = None

def get_script_runner() -> ScriptRunner:
    """Get the global script runner instance."""
    global _script_runner
    if _script_runner is None:
        _script_runner = create_script_runner()
    return _script_runner