"""Sandbox execution with allowlist-based command validation.

This module provides safe command execution in a sandboxed environment
with configurable allowlists for permitted commands.
"""

import subprocess
import shlex
from typing import Dict, List, Optional, Tuple
from pathlib import Path
from .allowlist import AllowListManager


class SandboxRunner:
    """Executes commands in a sandboxed environment with allowlist validation.
    
    Provides safe command execution by validating commands against an allowlist
    before running them. Supports timeout, output capture, and resource limits.
    
    Attributes:
        allowlist: AllowListManager for command validation
        timeout: Default timeout for commands (in seconds)
        working_dir: Working directory for command execution
    """
    
    def __init__(
        self,
        allowlist: Optional[AllowListManager] = None,
        timeout: int = 300,
        working_dir: str = "."
    ):
        """Initialize the sandbox runner.
        
        Args:
            allowlist: AllowListManager instance (creates default if None)
            timeout: Default timeout in seconds (default: 300)
            working_dir: Working directory for commands
        """
        self.allowlist = allowlist or AllowListManager()
        self.timeout = timeout
        self.working_dir = Path(working_dir)
    
    def run_command(
        self,
        command: str,
        timeout: Optional[int] = None,
        capture_output: bool = True,
        env: Optional[Dict[str, str]] = None
    ) -> Dict[str, any]:
        """Run a command in the sandbox.
        
        Args:
            command: Command string to execute
            timeout: Timeout in seconds (uses default if None)
            capture_output: Whether to capture stdout/stderr
            env: Environment variables for the command
            
        Returns:
            Dictionary with execution results
        """
        # Parse the command to get the base command
        try:
            parts = shlex.split(command)
            if not parts:
                return {
                    "success": False,
                    "error": "Empty command",
                    "exit_code": -1,
                    "output": ""
                }
            base_command = parts[0]
        except ValueError as e:
            return {
                "success": False,
                "error": f"Invalid command syntax: {str(e)}",
                "exit_code": -1,
                "output": ""
            }
        
        # Validate against allowlist
        if not self.allowlist.is_allowed(base_command):
            return {
                "success": False,
                "error": f"Command '{base_command}' is not in the allowlist",
                "exit_code": -1,
                "output": ""
            }
        
        # Check for argument restrictions
        args = parts[1:] if len(parts) > 1 else []
        validation_result = self.allowlist.validate_arguments(base_command, args)
        if not validation_result["allowed"]:
            return {
                "success": False,
                "error": f"Arguments not allowed: {validation_result['reason']}",
                "exit_code": -1,
                "output": ""
            }
        
        # Execute the command
        actual_timeout = timeout or self.timeout
        
        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=str(self.working_dir),
                timeout=actual_timeout,
                capture_output=capture_output,
                text=True,
                env=env
            )
            
            output = ""
            if capture_output:
                output = result.stdout
                if result.stderr:
                    output += "\n" + result.stderr
            
            return {
                "success": result.returncode == 0,
                "exit_code": result.returncode,
                "output": output,
                "command": command
            }
            
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "error": f"Command timed out after {actual_timeout} seconds",
                "exit_code": -1,
                "output": ""
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "exit_code": -1,
                "output": ""
            }
    
    def run_script(
        self,
        script_path: str,
        script_args: Optional[List[str]] = None,
        timeout: Optional[int] = None
    ) -> Dict[str, any]:
        """Run a script file in the sandbox.
        
        Args:
            script_path: Path to the script file
            script_args: Arguments to pass to the script
            timeout: Timeout in seconds
            
        Returns:
            Dictionary with execution results
        """
        script = Path(script_path)
        if not script.exists():
            return {
                "success": False,
                "error": f"Script not found: {script_path}",
                "exit_code": -1,
                "output": ""
            }
        
        # Determine interpreter based on extension
        extension = script.suffix.lower()
        interpreters = {
            '.py': 'python',
            '.sh': 'bash',
            '.bash': 'bash',
            '.zsh': 'zsh',
            '.ps1': 'pwsh',
            '.rb': 'ruby',
            '.js': 'node',
            '.ts': 'ts-node'
        }
        
        interpreter = interpreters.get(extension)
        if not interpreter:
            return {
                "success": False,
                "error": f"Unknown script type: {extension}",
                "exit_code": -1,
                "output": ""
            }
        
        # Build command
        args_str = " ".join(script_args) if script_args else ""
        command = f"{interpreter} {script_path} {args_str}"
        
        return self.run_command(command, timeout=timeout)
    
    def validate_command(self, command: str) -> Tuple[bool, Optional[str]]:
        """Validate a command without executing it.
        
        Args:
            command: Command string to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        try:
            parts = shlex.split(command)
            if not parts:
                return False, "Empty command"
            base_command = parts[0]
        except ValueError as e:
            return False, f"Invalid command syntax: {str(e)}"
        
        if not self.allowlist.is_allowed(base_command):
            return False, f"Command '{base_command}' is not in the allowlist"
        
        args = parts[1:] if len(parts) > 1 else []
        validation_result = self.allowlist.validate_arguments(base_command, args)
        
        if not validation_result["allowed"]:
            return False, validation_result["reason"]
        
        return True, None
    
    def set_working_dir(self, path: str) -> None:
        """Set the working directory for commands.
        
        Args:
            path: New working directory path
        """
        self.working_dir = Path(path)
    
    def get_allowed_commands(self) -> List[str]:
        """Get list of allowed commands.
        
        Returns:
            List of allowed command names
        """
        return self.allowlist.list_allowed()


class SafeShell:
    """A safer shell interface for executing multiple commands.
    
    Provides a shell-like interface for running multiple commands
    with proper validation and error handling.
    
    Attributes:
        sandbox: SandboxRunner instance
        history: List of executed commands
    """
    
    def __init__(self, sandbox: Optional[SandboxRunner] = None):
        """Initialize the safe shell.
        
        Args:
            sandbox: SandboxRunner instance (creates default if None)
        """
        self.sandbox = sandbox or SandboxRunner()
        self.history: List[Dict[str, any]] = []
    
    def execute(self, command: str, **kwargs) -> Dict[str, any]:
        """Execute a command and record it in history.
        
        Args:
            command: Command to execute
            **kwargs: Additional arguments for run_command
            
        Returns:
            Execution result dictionary
        """
        result = self.sandbox.run_command(command, **kwargs)
        self.history.append({
            "command": command,
            "result": result,
            "timestamp": None  # Could add timestamp if needed
        })
        return result
    
    def execute_batch(self, commands: List[str]) -> List[Dict[str, any]]:
        """Execute multiple commands in sequence.
        
        Stops on first failure unless continue_on_error is True.
        
        Args:
            commands: List of commands to execute
            
        Returns:
            List of execution results
        """
        results = []
        for command in commands:
            result = self.execute(command)
            results.append(result)
            if not result["success"]:
                break
        return results
    
    def validate(self, command: str) -> bool:
        """Validate a command.
        
        Args:
            command: Command to validate
            
        Returns:
            True if command is allowed
        """
        is_valid, _ = self.sandbox.validate_command(command)
        return is_valid
    
    def get_history(self) -> List[Dict[str, any]]:
        """Get execution history.
        
        Returns:
            List of executed commands and their results
        """
        return self.history.copy()
    
    def clear_history(self) -> None:
        """Clear execution history."""
        self.history.clear()
