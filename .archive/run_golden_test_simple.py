#!/usr/bin/env python3
"""
Test Suite::Noodle - run_golden_test_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

# Quick script to generate golden test without unicode issues
import sys, os, json, hashlib, time
from pathlib import Path

# Minimal golden test generation
trace_path = Path("C:/Users/micha/Noodle/test_trace.json")
if not trace_path.exists():
    print(f"ERROR: Trace file not found")
    sys.exit(1)

# Load trace
with open(trace_path, 'r') as f:
    trace_data = json.load(f)

# Create simple test
test_id = hashlib.sha256(f"simple_file_processor{time.time()}".encode()).hexdigest()[:16]

test = {
    "test_id": test_id,
    "name": "Simple File Processor Test",
    "description": "Generated from trace",
    "input": {
        "script_path": "C:/Users/micha/Noodle/simple_file_processor_fixed.py",
        "args": ["C:/Users/micha/Noodle/sample_input.csv", "C:/Users/micha/Noodle/output.csv"],
        "env_vars": {},
        "stdin": None,
        "working_dir": None,
        "timeout": 30
    },
    "expected_output": {
        "stdout": "",  # Not critical for this test
        "stderr": "",
        "exit_code": 0,
        "files_created": {},
        "duration_seconds": trace_data.get("duration", None),
        "call_count_range": [4500, 4600],  # Based on our 4554 calls
        "io_count_range": [1, 5]  # Based on our 1 I/O
    },
    "tags": ["auto-generated", "basic"],
    "created_at": time.strftime("%Y-%m-%d %H:%M:%S"),
    "last_updated": time.strftime("%Y-%m-%d %H:%M:%S"),
    "metadata": {
        "trace_id": trace_data.get("trace_id"),
        "original_call_count": len(trace_data.get("call_graph", [])),
        "original_io_count": len(trace_data.get("io_log", []))
    }
}

# Save test
golden_dir = Path("C:/Users/micha/Noodle/golden_tests")
golden_dir.mkdir(exist_ok=True)

output_path = golden_dir / f"simple_file_processor_{test_id}.json"
with open(output_path, 'w') as f:
    json.dump(test, f, indent=2)

print(f"SUCCESS: Created golden test")
print(f"  Test ID: {test_id}")
print(f"  Call range: {test['expected_output']['call_count_range']}")
print(f"  I/O range: {test['expected_output']['io_count_range']}")
print(f"  Saved to: {output_path}")

# Also create simple summary
print(f"\n=== Trace Statistics ===")
print(f"Total calls in trace: {len(trace_data.get('call_graph', []))}")
print(f"Total I/O in trace: {len(trace_data.get('io_log', []))}")
print(f"Exit code: {trace_data.get('exit_code')}")
print(f"Duration: {trace_data.get('duration', 0):.3f}s")


