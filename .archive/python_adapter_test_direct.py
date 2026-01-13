#!/usr/bin/env python3
"""
Test Suite::Noodle - python_adapter_test_direct.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to fix and verify python_adapter.py instrumentation.
We'll directly patch the file to remove .lower() calls.
"""
import os
import re
from pathlib import Path

# Path to python_adapter.py
adapter_file = Path(r"C:\Users\micha\Noodle\noodle-core\src\migration\source_harness\runtime_adapters\python_adapter.py")

# Read content
with open(adapter_file, 'r') as f:
    content = f.read()

# Replace .lower() calls with just str() for booleans
# Find and replace the two problematic lines
old_lines = [
    '        hook_content = hook_content.replace("@IO_TRACING", str(self.config.enable_io_tracing).lower())',
    '        hook_content = hook_content.replace("@CALL_TRACING", str(self.config.enable_call_tracing).lower())'
]

new_lines = [
    '        hook_content = hook_content.replace("@IO_TRACING", str(self.config.enable_io_tracing))',
    '        hook_content = hook_content.replace("@CALL_TRACING", str(self.config.enable_call_tracing))'
]

fixed_content = content
for old, new in zip(old_lines, new_lines):
    fixed_content = fixed_content.replace(old, new)

# Write back
with open(adapter_file, 'w') as f:
    f.write(fixed_content)

print("Fixed python_adapter.py - removed .lower() from boolean replacements")

# Now test it
print("\nNow testing the adapter...")
os.chdir(r"C:\Users\micha\Noodle\noodle-core\src")
import subprocess
result = subprocess.run(["python", "-m", "migration.source_harness.runtime_adapters.python_adapter"],
                       capture_output=True, text=True, cwd=Path(r"C:\Users\micha\Noodle\noodle-core\src"))

print("STDOUT:")
print(result.stdout)
if result.stderr:
    print("\nSTDERR:")
    print(result.stderr)

# Check if instrumentation worked
trace_file = Path(r"C:\Users\micha\Noodle\noodle-core\src\test_trace.json")
if trace_file.exists():
    import json
    with open(trace_file, 'r') as f:
        trace = json.load(f)
    
    print(f"\n=== Trace Results ===")
    print(f"Function calls: {len(trace.get('call_graph', []))}")
    print(f"I/O operations: {len(trace.get('io_log', []))}")
    print(f"Exit code: {trace.get('exit_code', -1)}")
    
    if len(trace.get('call_graph', [])) > 0 or len(trace.get('io_log', [])) > 0:
        print("\nSUCCESS: Instrumentation is working!")
    else:
        print("\nFAILURE: No instrumentation captured")


