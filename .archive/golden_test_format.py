#!/usr/bin/env python3
"""
Test Suite::Noodle - golden_test_format.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Golden Test Format Module

This module defines the data structures for golden test format:
- GoldenTest: Complete test case container
- TestInput: Input specification (args, files, stdin)
- TestOutput: Expected output specification (files, stdout, exit_code)

Format designed for CLI tool testing with file operations.
"""

from dataclasses import dataclass, field, asdict
from typing import Dict, List, Optional, Any
import json


@dataclass
class TestInput:
    """
    Input specification for a golden test.
    
    Represents command-line arguments, input files, and stdin data.
    """
    # Command to execute with arguments (e.g., ['python', 'script.py', 'arg1', 'arg2'])
    command: List[str]
    
    # Working directory for execution
    working_dir: str
    
    # Standard input (string) or None
    stdin: Optional[str] = None
    
    # Allowed execution time in seconds
    timeout_seconds: int = 30
    
    # Environment variables (key-value pairs)
    environment: Dict[str, str] = field(default_factory=dict)
    
    # Extra metadata
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TestInput':
        """Create instance from dictionary."""
        return cls(**data)


@dataclass
class TestOutputFile:
    """
    Expected output file specification.
    
    Defines what should be present after test execution.
    """
    # File path (relative to working_dir)
    path: str
    
    # Whether file should exist
    should_exist: bool = True
    
    # Exact content match (if provided)
    content_match: Optional[str] = None
    
    # Regex pattern for content match (if provided)
    content_regex: Optional[str] = None
    
    # File encoding
    encoding: str = 'utf-8'
    
    # Partial match allowed (for large files)
    partial_match: bool = False
    
    # Extra metadata
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TestOutputFile':
        """Create instance from dictionary."""
        return cls(**data)


@dataclass
class TestOutput:
    """
    Expected output specification for a golden test.
    
    Captures stdout, stderr, exit code, and expected files.
    """
    # Exit code expected
    exit_code: int = 0
    
    # Expected stdout content (exact match)
    stdout: Optional[str] = None
    
    # Expected stderr content (exact match)
    stderr: Optional[str] = None
    
    # Regex pattern for stdout (alternative to exact match)
    stdout_regex: Optional[str] = None
    
    # Regex pattern for stderr (alternative to exact match)
    stderr_regex: Optional[str] = None
    
    # Partial matching allowed (useful for dynamic content)
    partial_match: bool = False
    
    # Expected files (path -> TestOutputFile)
    files: Dict[str, TestOutputFile] = field(default_factory=dict)
    
    # Extra metadata
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        result = asdict(self)
        # Handle nested TestOutputFile objects
        result['files'] = {k: v.to_dict() for k, v in self.files.items()}
        return result
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TestOutput':
        """Create instance from dictionary."""
        files = data.pop('files', {})
        obj = cls(**data)
        obj.files = {k: TestOutputFile.from_dict(v) for k, v in files.items()}
        return obj


@dataclass
class GoldenTest:
    """
    Complete golden test case.
    
    A golden test captures deterministic behavior by recording:
    - Input: command, files, stdin
    - Expected output: files, stdout, stderr, exit_code
    
    Test execution compares actual vs expected outputs.
    """
    # Unique identifier for this test case
    test_case_id: str
    
    # Human-readable description
    description: str
    
    # Test input specification
    input_spec: TestInput
    
    # Expected output specification
    expected_output: TestOutput
    
    # Tags for categorization
    tags: List[str] = field(default_factory=list)
    
    # Test enabled/disabled
    enabled: bool = True
    
    # Priority (high/medium/low)
    priority: str = 'medium'
    
    # Extra metadata
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        result = asdict(self)
        result['input_spec'] = self.input_spec.to_dict()
        result['expected_output'] = self.expected_output.to_dict()
        return result
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'GoldenTest':
        """Create instance from dictionary."""
        input_spec_data = data.pop('input_spec')
        expected_output_data = data.pop('expected_output')
        
        obj = cls(**data)
        obj.input_spec = TestInput.from_dict(input_spec_data)
        obj.expected_output = TestOutput.from_dict(expected_output_data)
        return obj

    def to_json(self, indent: int = 2) -> str:
        """Serialize to JSON string."""
        return json.dumps(self.to_dict(), indent=indent, ensure_ascii=False)
    
    @classmethod
    def from_json(cls, json_str: str) -> 'GoldenTest':
        """Deserialize from JSON string."""
        data = json.loads(json_str)
        return cls.from_dict(data)


# Example creation helpers


def create_simple_file_processor_test(
    test_id: str,
    input_csv_content: str,
    expected_csv_content: str,
    expected_line_count: int,
    additional_args: List[str] = None
) -> GoldenTest:
    """
    Create a simple_file_processor golden test.
    
    Args:
        test_id: Test identifier
        input_csv_content: Input CSV file content
        expected_csv_content: Expected output CSV file content
        expected_line_count: Expected line count (for stdout)
        additional_args: Optional command-line args (e.g., ['--verbose'])
    
    Returns:
        GoldenTest for simple_file_processor
    """
    working_dir = '.'  # Tests run in current directory by default
    
    # Build command
    command = ['python', 'simple_file_processor.py', 'input.csv', 'output.csv']
    if additional_args:
        command.extend(additional_args)
    
    # Create input specification
    input_spec = TestInput(
        command=command,
        working_dir=working_dir,
        stdin=None,
        timeout_seconds=10,
        environment={}
    )
    
    # Create expected output
    expected_output = TestOutput(
        exit_code=0,
        stdout=f"Processed {expected_line_count} lines\n",
        stderr="",
        files={
            'output.csv': TestOutputFile(
                path='output.csv',
                should_exist=True,
                content_match=expected_csv_content,
                encoding='utf-8'
            )
        }
    )
    
    return GoldenTest(
        test_case_id=test_id,
        description=f"Processing test with {expected_line_count} lines",
        input_spec=input_spec,
        expected_output=expected_output,
        tags=['functional', 'basic'],
        enabled=True
    )


# Example usage
if __name__ == "__main__":
    # Create sample test
    test = create_simple_file_processor_test(
        test_id="basic_csv_uppercase",
        input_csv_content="name,email\njohn,john@example.com\njane,jane@example.com",
        expected_csv_content="NAME,EMAIL\nJOHN,JOHN@EXAMPLE.COM\nJANE,JANE@EXAMPLE.COM",
        expected_line_count=3,  # header + 2 rows
        additional_args=None
    )
    
    # Print as JSON for example
    print(test.to_json())


