#!/usr/bin/env python3
"""
Noodle::Trace Capture Example - trace_capture_example.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Trace Capture Example

Demonstrates how to capture execution traces of file processing operations
using the Trace format and convert them to golden tests.

This example:
1. Executes a file processing command
2. Captures execution trace
3. Converts trace to golden test format
4. Saves golden test for regression testing
"""

import sys
import subprocess
import json
import time
from pathlib import Path
from typing import Dict, List, Any

# Import trace format from noodle-core
try:
    # Try to import from local development installation
    from noodle_core.src.migration.source_harness.trace_format import Trace, IOLog, CallFrame
except ImportError:
    # Fallback: Use local implementation as placeholder
    print("Warning: Using simplified trace format")
    
    class IOLog:
        def __init__(self, operation: str, path: str = None, data: bytes = None, 
                     success: bool = True, error: str = None, timestamp: float = None):
            self.operation = operation
            self.path = path
            self.data = data
            self.success = success
            self.error = error
            self.timestamp = timestamp or time.time()
    
    class CallFrame:
        def __init__(self, name: str, module: str = None, args: Dict = None, 
                     kwargs: Dict = None, locals: Dict = None, timestamp: float = None,
                     duration: float = None):
            self.name = name
            self.module = module
            self.args = args or {}
            self.kwargs = kwargs or {}
            self.locals = locals or {}
            self.timestamp = timestamp or time.time()
            self.duration = duration
    
    class Trace:
        def __init__(self, trace_id: str = None, language: str = "python", 
                     command: List[str] = None, working_dir: str = None):
            self.trace_id = trace_id or f"trace_{int(time.time())}"
            self.language = language
            self.command = command or []
            self.working_dir = working_dir or str(Path.cwd())
            self.start_time = time.time()
            self.end_time = None
            self.io_log = []
            self.call_graph = []
            self.exit_code = None
        
        def finalize(self, exit_code: int = 0):
            self.end_time = time.time()
            self.exit_code = exit_code
        
        def to_dict(self) -> Dict[str, Any]:
            return {
                'trace_id': self.trace_id,
                'language': self.language,
                'command': self.command,
                'working_dir': self.working_dir,
                'start_time': self.start_time,
                'end_time': self.end_time,
                'io_log': [
                    {
                        'operation': io.operation,
                        'path': io.path,
                        'data': io.data,
                        'success': io.success,
                        'error': io.error,
                        'timestamp': io.timestamp
                    }
                    for io in self.io_log
                ],
                'call_graph': [
                    {
                        'name': call.name,
                        'module': call.module,
                        'args': call.args,
                        'kwargs': call.kwargs,
                        'locals': call.locals,
                        'timestamp': call.timestamp,
                        'duration': call.duration
                    }
                    for call in self.call_graph
                ],
                'exit_code': self.exit_code
            }


class ExecutionTracer:
    """Monitors and traces file processing execution."""
    
    def __init__(self, trace_id: str = None):
        self.trace = Trace(trace_id=trace_id)
        self.file_monitor = FileMonitor()
    
    def capture_execution(self, command: List[str], timeout: int = 30) -> Trace:
        """Execute command and capture trace."""
        self.trace.command = command
        
        print(f"Starting execution trace: {' '.join(command)}")
        
        try:
            # Start file monitoring
            self.file_monitor.start_monitoring()
            
            # Execute the command
            start_time = time.time()
            
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=self.trace.working_dir
            )
            
            duration = time.time() - start_time
            
            # Stop monitoring and collect file operations
            file_operations = self.file_monitor.stop_monitoring()
            
            # Add file operations to trace
            for op in file_operations:
                self.trace.io_log.append(IOLog(
                    operation=op['type'],
                    path=op['path'],
                    success=True,
                    timestamp=op['timestamp']
                ))
            
            # Add execution metadata
            self.trace.finalize(exit_code=result.returncode)
            
            # Capture stdout/stderr
            if result.stdout:
                self.trace.io_log.append(IOLog(
                    operation='stdout',
                    data=result.stdout.encode(),
                    success=True
                ))
            
            if result.stderr:
                self.trace.io_log.append(IOLog(
                    operation='stderr',
                    data=result.stderr.encode(),
                    success=True
                ))
            
            print(f"âœ“ Execution completed (exit code: {result.returncode}, duration: {duration:.3f}s)")
            print(f"  File operations captured: {len(file_operations)}")
            
            return self.trace
            
        except subprocess.TimeoutExpired:
            print(f"âœ— Execution timed out after {timeout} seconds")
            self.trace.finalize(exit_code=124)  # Timeout exit code
            return self.trace
        
        except Exception as e:
            print(f"âœ— Execution failed: {e}")
            self.trace.finalize(exit_code=1)
            return self.trace
    
    def save_trace(self, output_path: str):
        """Save trace to JSON file."""
        trace_data = self.trace.to_dict()
        
        with open(output_path, 'w') as f:
            json.dump(trace_data, f, indent=2, default=str)
        
        print(f"Trace saved to: {output_path}")


class FileMonitor:
    """Simple file operation monitor."""
    
    def __init__(self):
        self.operations = []
        self.monitoring = False
    
    def start_monitoring(self):
        """Start monitoring file operations."""
        self.operations = []
        self.monitoring = True
    
    def stop_monitoring(self) -> List[Dict[str, Any]]:
        """Stop monitoring and return captured operations."""
        self.monitoring = False
        return self.operations.copy()
    
    def log_operation(self, operation: str, path: str):
        """Log a file operation."""
        if self.monitoring:
            self.operations.append({
                'type': operation,
                'path': str(path),
                'timestamp': time.time()
            })


class GoldenTestGenerator:
    """Generate golden tests from captured traces."""
    
    def __init__(self, output_dir: str = "golden_tests"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    
    def generate_from_trace(self, trace: Trace, test_name: str) -> Dict[str, Any]:
        """Generate golden test specification from trace."""
        
        golden_test = {
            "version": "1.0",
            "test_name": test_name,
            "description": f"Generated from trace {trace.trace_id}",
            "language": trace.language,
            
            "setup": {
                "create_files": [],
                "environment": {
                    "working_directory": trace.working_dir
                },
                "preconditions": []
            },
            
            "execution": {
                "command": trace.command,
                "timeout_seconds": max(30, int((trace.end_time - trace.start_time) * 1.5)),
                "expected_exit_code": trace.exit_code
            },
            
            "assertions": {
                "files_created": [],
                "files_modified": [],
                "file_operations": [],
                "stdout": {"checks": []},
                "stderr": {"checks": []}
            },
            
            "teardown": {
                "cleanup_files": [],
                "preserve_on_failure": False
            },
            
            "metadata": {
                "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "trace_id": trace.trace_id,
                "duration": trace.end_time - trace.start_time
            }
        }
        
        # Analyze file operations
        written_files = set()
        read_files = set()
        
        for io_op in trace.io_log:
            path = io_op.path
            operation = io_op.operation
            
            if not path:
                continue
            
            if operation in ['write', 'create']:
                written_files.add(path)
                # Add file creation assertion
                golden_test["assertions"]["files_created"].append({
                    "path": path,
                    "optional": False
                })
            
            elif operation == 'read':
                read_files.add(path)
                # Add file operation assertion
                golden_test["assertions"]["file_operations"].append({
                    "type": "read",
                    "path": path,
                    "count": {"min": 1, "max": 999}
                })
            
            elif operation == 'stdout':
                if io_op.data:
                    stdout_text = io_op.data.decode() if isinstance(io_op.data, bytes) else str(io_op.data)
                    if stdout_text.strip():
                        golden_test["assertions"]["stdout"]["checks"].append({
                            "type": "contains",
                            "expected": stdout_text.strip()
                        })
        
        # Files that were both read and written (modified files)
        modified_files = read_files & written_files
        for path in modified_files:
            golden_test["assertions"]["files_modified"].append({
                "path": path,
                "checks": [
                    {
                        "type": "file_exists",
                        "expected": True
                    }
                ]
            })
        
        return golden_test
    
    def save_golden_test(self, golden_test: Dict[str, Any], filename: str = None):
        """Save golden test to file."""
        if filename is None:
            filename = f"{golden_test['test_name']}.json"
        
        output_path = self.output_dir / filename
        with open(output_path, 'w') as f:
            json.dump(golden_test, f, indent=2)
        
        print(f"Golden test saved: {output_path}")
        return output_path


def demonstrate_workflow():
    """Demonstrate the complete trace -> golden test workflow."""
    
    print("=" * 60)
    print("Trace -> Golden Test Workflow Demonstration")
    print("=" * 60)
    
    # Setup test environment
    test_dir = Path("test_data")
    test_dir.mkdir(exist_ok=True)
    
    input_file = test_dir / "input.txt"
    output_file = test_dir / "output.txt"
    
    # Create test input file
    test_content = "Hello World\nThis is a test file\n"
    with open(input_file, 'w') as f:
        f.write(test_content)
    
    print(f"\nâœ“ Created test input: {input_file}")
    
    # 1. Trace execution
    tracer = ExecutionTracer("demo_trace")
    command = [
        sys.executable, 
        "simple_file_processor_example.py",
        str(input_file),
        str(output_file)
    ]
    
    trace = tracer.capture_execution(command)
    tracer.save_trace("demo_trace.json")
    
    # 2. Generate golden test
    generator = GoldenTestGenerator()
    golden_test = generator.generate_from_trace(trace, "simple_processor_golden")
    
    # 3. Save golden test
    generator.save_golden_test(golden_test)
    
    print("\n" + "=" * 60)
    print("Golden Test Preview:")
    print("=" * 60)
    print(json.dumps(golden_test, indent=2))
    
    print("\n" + "=" * 60)
    print("Summary:")
    print(f"  - File operations captured: {len(trace.io_log)}")
    print(f"  - Assertions generated: {len(golden_test['assertions']['files_created'])}")
    print(f"  - Test duration: {golden_test['metadata']['duration']:.3f}s")
    print("=" * 60)
    
    # Cleanup
    if output_file.exists():
        output_file.unlink()
    
    print("âœ“ Demo completed successfully!")


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Capture execution traces and generate golden tests"
    )
    
    parser.add_argument(
        '--demo',
        action='store_true',
        help='Run demonstration workflow'
    )
    
    parser.add_argument(
        '--command',
        nargs='+',
        help='Command to trace and generate golden test for'
    )
    
    parser.add_argument(
        '--test-name',
        help='Name for the generated golden test'
    )
    
    parser.add_argument(
        '--output-dir',
        default='golden_tests',
        help='Output directory for golden tests'
    )
    
    args = parser.parse_args()
    
    if args.demo:
        demonstrate_workflow()
    elif args.command:
        # Trace specified command
        tracer = ExecutionTracer()
        trace = tracer.capture_execution(args.command)
        
        # Generate golden test
        test_name = args.test_name or f"command_trace_{int(time.time())}"
        generator = GoldenTestGenerator(args.output_dir)
        golden_test = generator.generate_from_trace(trace, test_name)
        generator.save_golden_test(golden_test)
    else:
        print("No action specified. Use --demo or --command")
        parser.print_help()


if __name__ == "__main__":
    main()


