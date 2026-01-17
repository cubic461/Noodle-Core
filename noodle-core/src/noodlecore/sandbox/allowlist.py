"""Command allowlist management for sandbox execution.

This module provides allowlist-based validation for commands and arguments,
enabling safe execution in a sandboxed environment.
"""

import json
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


class AllowListManager:
    """Manages command allowlists for sandbox execution.
    
    Provides validation of commands and their arguments against
    configured allowlists to ensure safe execution.
    
    Attributes:
        allowed_commands: Set of allowed base commands
        argument_restrictions: Per-command argument restrictions
        blocked_patterns: Patterns that are never allowed in arguments
    """
    
    def __init__(self, config_path: Optional[str] = None):
        """Initialize the allowlist manager.
        
        Args:
            config_path: Path to allowlist config file (JSON)
        """
        self.allowed_commands: Set[str] = set()
        self.argument_restrictions: Dict[str, Dict[str, any]] = {}
        self.blocked_patterns: List[str] = [
            "rm -rf /",
            "rm -rf /*",
            "mkfs",
            "dd if=/dev/zero",
            "> /dev/sda",
            "chmod 000",
            "chown root"
        ]
        
        if config_path:
            self.load_from_file(config_path)
        else:
            self._load_default_allowlist()
    
    def _load_default_allowlist(self) -> None:
        """Load the default safe command allowlist."""
        # Development and testing commands
        dev_commands = {
            "python", "python3", "pip", "pip3",
            "node", "npm", "yarn",
            "go", "cargo", "rustc",
            "java", "javac",
            "ruby", "gem",
            "php", "composer"
        }
        
        # Build tools
        build_commands = {
            "make", "cmake", "ninja",
            "gcc", "g++", "clang", "clang++",
            "mvn", "gradle",
            "meson", "bazel"
        }
        
        # Version control
        vcs_commands = {
            "git", "hg", "svn"
        }
        
        # File operations (safe ones)
        file_commands = {
            "cat", "head", "tail", "less", "more",
            "grep", "egrep", "fgrep",
            "find", "locate",
            "ls", "dir", "tree",
            "cp", "mv", "mkdir", "touch",
            "file", "stat", "wc", "sort", "uniq"
        }
        
        # Text processing
        text_commands = {
            "sed", "awk", "tr", "cut",
            "diff", "patch"
        }
        
        # Archive tools
        archive_commands = {
            "tar", "zip", "unzip", "gzip", "gunzip",
            "xz", "7z"
        }
        
        # Testing tools
        test_commands = {
            "pytest", "unittest", "jest",
            "mocha", "jasmine",
            "cargo test", "go test"
        }
        
        # Documentation
        doc_commands = {
            "pydoc", "godoc", "javadoc"
        }
        
        # System info (read-only)
        info_commands = {
            "uname", "hostname", "whoami", "id",
            "df", "du", "free", "top",
            "ps", "pgrep", "pidof"
        }
        
        # Network (diagnostic only)
        network_commands = {
            "ping", "traceroute", "nslookup",
            "curl", "wget", "http"
        }
        
        # Shell built-ins and utilities
        shell_commands = {
            "echo", "printf", "date",
            "sleep", "time", "watch"
        }
        
        # Combine all safe commands
        self.allowed_commands = dev_commands | build_commands | vcs_commands | \
                               file_commands | text_commands | archive_commands | \
                               test_commands | doc_commands | info_commands | \
                               network_commands | shell_commands
        
        # Set up argument restrictions for certain commands
        self.argument_restrictions = {
            "rm": {
                "max_recursive_depth": 3,
                "blocked_flags": ["-rf", "-fr", "-r /", "-R /"],
                "require_confirmation": True
            },
            "chmod": {
                "blocked_modes": ["000", "777"],
                "max_permission": "755"
            },
            "chown": {
                "blocked_users": ["root"],
                "allow_current_user": True
            },
            "pip": {
                "blocked_commands": ["uninstall"],
                "require_user_flag": True
            },
            "npm": {
                "blocked_commands": ["uninstall", "un"],
                "require_prefix": ["--user", "ignore-scripts"]
            },
            "git": {
                "blocked_commands": ["push --force", "reset --hard"],
                "allowed_remotes": ["origin"]
            }
        }
    
    def is_allowed(self, command: str) -> bool:
        """Check if a command is in the allowlist.
        
        Args:
            command: Base command name (e.g., 'python', 'git')
            
        Returns:
            True if command is allowed
        """
        # Extract base command (handle paths)
        base = command.split("/")[-1].split("\\")[-1]
        
        # Check if it's in the allowed set
        if base in self.allowed_commands:
            return True
        
        # Check for common aliases
        aliases = {
            "python3": "python",
            "pip3": "pip",
            "node": "nodejs"
        }
        if base in aliases and aliases[base] in self.allowed_commands:
            return True
        
        return False
    
    def validate_arguments(
        self,
        command: str,
        args: List[str]
    ) -> Dict[str, any]:
        """Validate command arguments against restrictions.
        
        Args:
            command: Base command name
            args: List of command arguments
            
        Returns:
            Dictionary with 'allowed' bool and optional 'reason'
        """
        # Check for blocked patterns in the full argument string
        full_command = " ".join(args)
        for pattern in self.blocked_patterns:
            if pattern.lower() in full_command.lower():
                return {
                    "allowed": False,
                    "reason": f"Blocked pattern detected: {pattern}"
                }
        
        # Check command-specific restrictions
        if command in self.argument_restrictions:
            restrictions = self.argument_restrictions[command]
            
            # Check for blocked flags
            if "blocked_flags" in restrictions:
                for flag in restrictions["blocked_flags"]:
                    if flag in args:
                        return {
                            "allowed": False,
                            "reason": f"Flag '{flag}' is not allowed for {command}"
                        }
            
            # Check for blocked subcommands
            if "blocked_commands" in restrictions and len(args) > 0:
                subcommand = args[0]
                for blocked in restrictions["blocked_commands"]:
                    if blocked.lower() in subcommand.lower():
                        return {
                            "allowed": False,
                            "reason": f"Subcommand '{subcommand}' is not allowed for {command}"
                        }
        
        return {"allowed": True}
    
    def add_command(self, command: str, restrictions: Optional[Dict] = None) -> None:
        """Add a command to the allowlist.
        
        Args:
            command: Command name to add
            restrictions: Optional argument restrictions
        """
        self.allowed_commands.add(command)
        if restrictions:
            self.argument_restrictions[command] = restrictions
    
    def remove_command(self, command: str) -> None:
        """Remove a command from the allowlist.
        
        Args:
            command: Command name to remove
        """
        self.allowed_commands.discard(command)
        if command in self.argument_restrictions:
            del self.argument_restrictions[command]
    
    def add_restriction(self, command: str, restrictions: Dict[str, any]) -> None:
        """Add argument restrictions for a command.
        
        Args:
            command: Command name
            restrictions: Dictionary of restrictions
        """
        if command in self.argument_restrictions:
            self.argument_restrictions[command].update(restrictions)
        else:
            self.argument_restrictions[command] = restrictions
    
    def list_allowed(self) -> List[str]:
        """Get list of allowed commands.
        
        Returns:
            Sorted list of allowed command names
        """
        return sorted(list(self.allowed_commands))
    
    def load_from_file(self, config_path: str) -> None:
        """Load allowlist configuration from a JSON file.
        
        Args:
            config_path: Path to JSON config file
        """
        config_file = Path(config_path)
        if not config_file.exists():
            return
        
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        self.allowed_commands = set(config.get("allowed_commands", []))
        self.argument_restrictions = config.get("argument_restrictions", {})
        self.blocked_patterns = config.get("blocked_patterns", [])
    
    def save_to_file(self, config_path: str) -> None:
        """Save allowlist configuration to a JSON file.
        
        Args:
            config_path: Path to save config file
        """
        config = {
            "allowed_commands": list(self.allowed_commands),
            "argument_restrictions": self.argument_restrictions,
            "blocked_patterns": self.blocked_patterns
        }
        
        config_file = Path(config_path)
        config_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
    
    def export_profile(self, profile_name: str) -> Dict[str, any]:
        """Export the current allowlist as a named profile.
        
        Args:
            profile_name: Name for the profile
            
        Returns:
            Profile dictionary
        """
        return {
            "name": profile_name,
            "allowed_commands": list(self.allowed_commands),
            "argument_restrictions": self.argument_restrictions,
            "blocked_patterns": self.blocked_patterns
        }
    
    def import_profile(self, profile: Dict[str, any]) -> None:
        """Import an allowlist profile.
        
        Args:
            profile: Profile dictionary from export_profile
        """
        self.allowed_commands = set(profile.get("allowed_commands", []))
        self.argument_restrictions = profile.get("argument_restrictions", {})
        self.blocked_patterns = profile.get("blocked_patterns", [])


class PresetProfiles:
    """Preset allowlist profiles for different use cases."""
    
    @staticmethod
    def development() -> Dict[str, any]:
        """Get a development-focused allowlist profile.
        
        Returns:
            Profile dictionary with development tools
        """
        manager = AllowListManager()
        return manager.export_profile("development")
    
    @staticmethod
    def testing() -> Dict[str, any]:
        """Get a testing-focused allowlist profile.
        
        Returns:
            Profile dictionary with testing tools
        """
        manager = AllowListManager()
        # Restrict to testing commands only
        manager.allowed_commands = {
            "pytest", "python", "python3",
            "jest", "node", "npm",
            "go", "go test",
            "cargo", "cargo test",
            "make", "cmake",
            "git"
        }
        return manager.export_profile("testing")
    
    @staticmethod
    def minimal() -> Dict[str, any]:
        """Get a minimal allowlist profile.
        
        Returns:
            Profile dictionary with minimal safe commands
        """
        manager = AllowListManager()
        manager.allowed_commands = {
            "cat", "ls", "echo", "pwd",
            "python", "python3",
            "git"
        }
        return manager.export_profile("minimal")
    
    @staticmethod
    def strict() -> Dict[str, any]:
        """Get a strict allowlist profile with aggressive restrictions.
        
        Returns:
            Profile dictionary with strict restrictions
        """
        manager = AllowListManager()
        manager.allowed_commands = {
            "python", "python3",
            "pytest",
            "git",
            "cat", "head", "tail", "grep"
        }
        manager.argument_restrictions = {
            "git": {
                "blocked_commands": ["push", "reset", "rebase", "force"],
                "allow_readonly": True
            }
        }
        return manager.export_profile("strict")
