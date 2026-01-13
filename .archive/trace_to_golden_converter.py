#!/usr/bin/env python3
"""
Noodle::Trace To Golden Converter - trace_to_golden_converter.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Trace to Golden Test Converter

Converts execution traces into golden test format for regression testing.

This tool reads trace.json files and generates golden test specifications
that can be used to validate future executions against expected behavior.
"""

import json
import sys
import argparse
import time
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict


@dataclass
class GoldenTest:
    """Golden test format container."""
    
    version: str = "1.0"
    test_name: str = ""
    description: str = ""
    language: str = "python"
    
    # Setup phase
    setup: Dict[str, Any] = None
    execution: Dict[str, Any] = None
    assertions: Dict[str, Any] = None
    teardown: Dict[str, Any] = None
    metadata: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.setup is None:
            self.setup = {
                "create_files": [],
                "environment": {"working_directory": "."},
                "preconditions": []
            }
        if self.execution is None:
            self.execution = {
                "command": [],
                "timeout_seconds": 30,
                "expected_exit_code": 0
            }
        if self.assertions is None:
            self.assertions = {
                "files_created": [],
                "files_modified": [],
                "stdout": {"checks": []},
                "stderr": {"checks": []},
                "file_operations": []
            }
        if self.teardown is None:
            self.teardown = {
                "cleanup_files": [],
                "preserve_on_failure": False
            }
        if self.metadata is None:
            self.metadata = {
                "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "tags": []
            }
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)
    
    def to_json(self, indent: int = 2) -> str:
        """Convert to JSON string."""
        return json.dumps(self.to_dict(), indent=indent, default=str)
    
    def save(self, path: str):
        """Save golden test to file."""
        with open(path, 'w') as f:
            f.write(self.to_json())


class TraceConverter:
    """Converts Trace objects to GoldenTest format."""
    
    def __init__(self, trace_data: Dict[str, Any]):
        self.trace_data = trace_data
        self.golden_test = GoldenTest()
    
    def convert(self) -> GoldenTest:
        """Convert trace to golden test format."""
        # Basic metadata
        self.golden_test.test_name = self.trace_data.get('trace_id', 'unnamed_test')
        self.golden_test.language = self.trace_data.get('language', 'python')
        self.golden_test.description = f"Generated from trace {self.golden_test.test_name}"
        
        # Execution configuration
        self._convert_execution()
        
        # File operations and assertions
        self._convert_io_operations()
        
        # Call graph (if available)
        self._convert_call_graph()
        
        # Finalize metadata
        self.golden_test.metadata['trace_source'] = self.trace_data.get('trace_id')
        self.golden_test.metadata['duration'] = self._calculate_duration()
        
        return self.golden_test
    
    def _convert_execution(self):
        """Convert execution metadata."""
        self.golden_test.execution['command'] = self.trace_data.get('command', [])
        self.golden_test.execution['expected_exit_code'] = self.trace_data.get('exit_code', 0)
        self.golden_test.execution['working_directory'] = self.trace_data.get('working_dir', '.')
        
        # Calculate timeout (1.5x actual duration)
        duration = self._calculate_duration()
        if duration:
            self.golden_test.execution['timeout_seconds'] = max(30, int(duration * 1.5))
    
    def _convert_io_operations(self):
        """Convert I/O operations to assertions."""
        io_log = self.trace_data.get('io_log', [])
        files_written = {}
        files_read = {}
        
        for io_op in io_log:
            operation = io_op.get('operation', '')
            path = io_op.get('path', '')
            success = io_op.get('success', True)
            
            if not path or not success:
                continue
            
            # Count operations by type
            if operation in ['write', 'create']:
                if path not in files_written:
                    files_written[path] = {'count': 0, 'data': io_op.get('data')}
                files_written[path]['count'] += 1
            
            elif operation == 'read':
                if path not in files_read:
                    files_read[path] = 0
                files_read[path] += 1
        
        # Add file creation assertions
        for path, info in files_written.items():
            self.golden_test.assertions['files_created'].append({
                'path': path,
                'optional': False,
                'content_type': self._detect_content_type(info.get('data'))
            })
        
        # Add file modification assertions (for files that were read from and written to)
        for path in set(files_read.keys()) & set(files_written.keys()):
            checks = []
            
            # Add content check if we have data
            if files_written[path].get('data'):
                content = files_written[path]['data']
                if isinstance(content, bytes):
                    checks.append({
                        'type': 'file_hash',
                        'algorithm': 'sha256'
                    })
                else:
                    checks.append({
                        'type': 'exact_match',
                        'expected': content
                    })
            
            if checks:
                self.golden_test.assertions['files_modified'].append({
                    'path': path,
                    'checks': checks
                })
        
        # Add file operation assertions
        for io_op in io_log:
            operation = io_op.get('operation', '')
            path = io_op.get('path', '')
            
            if operation in ['read', 'write', 'delete'] and path:
                self.golden_test.assertions['file_operations'].append({
                    'type': operation,
                    'path': path,
                    'count': self._count_operations(io_log, operation, path)
                })
    
    def _convert_call_graph(self):
        """Convert call graph to test assertions (if applicable)."""
        call_graph = self.trace_data.get('call_graph', [])
        
        # Extract key function calls
        main_functions = []
        for call in call_graph:
            name = call.get('name', '')
            module = call.get('module', '')
            
            if name and module:
                main_functions.append(f"{module}.{name}")
        
        if main_functions:
            self.golden_test.assertions['function_calls'] = main_functions
    
    def _calculate_duration(self) -> Optional[float]:
        """Calculate total execution duration."""
        start_time = self.trace_data.get('start_time')
        end_time = self.trace_data.get('end_time')
        
        if start_time and end_time:
            return end_time - start_time
        return None
    
    def _detect_content_type(self, data: Any) -> str:
        """Detect content type from data."""
        if data is None:
            return 'binary'
        elif isinstance(data, bytes):
            return 'binary'
        elif isinstance(data, str):
            try:
                json.loads(data)
                return 'json'
            except:
                return 'text'
        else:
            return 'text'
    
    def _count_operations(self, io_log: List[Dict], operation: str, path: str) -> Dict[str, int]:
        """Count operations of a specific type on a path."""
        count = sum(1 for op in io_log 
                   if op.get('operation') == operation and op.get('path') == path)
        return {'min': count, 'max': count}


class GoldenTestGenerator:
    """High-level interface for generating golden tests from traces."""
    
    def __init__(self, output_dir: str = "golden_tests"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    
    def from_trace_file(self, trace_path: str, test_name: str = None) -> GoldenTest:
        """Generate golden test from trace file."""
        with open(trace_path, 'r') as f:
            trace_data = json.load(f)
        
        # Convert trace to golden test
        converter = TraceConverter(trace_data)
        golden_test = converter.convert()
        
        # Override test name if provided
        if test_name:
            golden_test.test_name = test_name
        
        return golden_test
    
    def save_golden_test(self, golden_test: GoldenTest, filename: str = None):
        """Save golden test to file."""
        if filename is None:
            filename = f"{golden_test.test_name}.json"
        
        output_path = self.output_dir / filename
        golden_test.save(str(output_path))
        print(f"Saved golden test: {output_path}")
    
    def generate_from_directory(self, trace_dir: str, pattern: str = "*.json"):
        """Generate golden tests from all trace files in directory."""
        trace_dir = Path(trace_dir)
        
        for trace_file in trace_dir.glob(pattern):
            print(f"Processing: {trace_file}")
            
            try:
                golden_test = self.from_trace_file(str(trace_file))
                self.save_golden_test(golden_test)
            except Exception as e:
                print(f"Error processing {trace_file}: {e}")


def main():
    """Command-line interface."""
    parser = argparse.ArgumentParser(
        description="Convert execution traces to golden test format"
    )
    
    parser.add_argument(
        'trace_file',
        help='Path to trace.json file or directory containing traces'
    )
    
    parser.add_argument(
        '-o', '--output-dir',
        default='golden_tests',
        help='Output directory for golden tests (default: golden_tests)'
    )
    
    parser.add_argument(
        '-n', '--test-name',
        help='Override test name (default: use trace_id)'
    )
    
    parser.add_argument(
        '-b', '--batch',
        action='store_true',
        help='Process all JSON files in directory'
    )
    
    parser.add_argument(
        '-p', '--pattern',
        default='*.json',
        help='File pattern for batch processing (default: *.json)'
    )
    
    args = parser.parse_args()
    
    generator = GoldenTestGenerator(args.output_dir)
    
    if args.batch:
        # Batch process directory
        generator.generate_from_directory(args.trace_file, args.pattern)
    else:
        # Single file
        golden_test = generator.from_trace_file(args.trace_file, args.test_name)
        generator.save_golden_test(golden_test)
        
        # Preview
        print("\nPreview:")
        print(golden_test.to_json())


if __name__ == "__main__":
    main()


