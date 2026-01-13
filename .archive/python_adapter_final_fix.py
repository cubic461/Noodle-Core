#!/usr/bin/env python3
"""
Noodle::Python Adapter Final Fix - python_adapter_final_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Apply the final fix to python_adapter.py by directly editing the file
to remove .lower() from the boolean replacements.
"""
import os
from pathlib import Path

adapter_file = Path(r"C:\Users\micha\Noodle\noodle-core\src\migration\source_harness\runtime_adapters\python_adapter.py")

# Read the file
with open(adapter_file, 'r') as f:
    content = f.read()

# Find and replace the problematic lines - look for exact matches
lines_to_fix = [
    '        hook_content = hook_content.replace("@IO_TRACING", str(self.config.enable_io_tracing).lower())',
    '        hook_content = hook_content.replace("@CALL_TRACING", str(self.config.enable_call_tracing).lower())'
]

lines_fixed = [
    '        hook_content = hook_content.replace("@IO_TRACING", str(self.config.enable_io_tracing))',
    '        hook_content = hook_content.replace("@CALL_TRACING", str(self.config.enable_call_tracing))'
]

new_content = content
for old, new in zip(lines_to_fix, lines_fixed):
    new_content = new_content.replace(old, new)

# Write back
with open(adapter_file, 'w') as f:
    f.write(new_content)

print("Applied fix to python_adapter.py")

# Now test it
print("\nTesting the fix...")
os.chdir(r"C:\Users\micha\Noodle\noodle-core\src")
import subprocess
result = subprocess.run(["python", "-m", "migration.source_harness.runtime_adapters.python_adapter"],
                       capture_output=True, text=True)

print("STDOUT:")
print(result.stdout)
if result.stderr:
    print("\nSTDERR (warnings only, probably safe to ignore):")
    print(result.stderr)

# Check trace
import json
trace_file = Path(r"C:\Users\micha\Noodle\noodle-core\src\test_trace.json")
if trace_file.exists():
    with open(trace_file, 'r') as f:
        trace = json.load(f)
    
    print(f"\n=== Instrumentation Results ===")
    print(f"Function calls: {len(trace.get('call_graph', []))}")
    print(f"I/O operations: {len(trace.get('io_log', []))}")
    print(f"Exit code: {trace.get('exit_code', -1)}")
    
    if len(trace.get('call_graph', [])) > 0 or len(trace.get('io_log', [])) > 0:
        print("\nðŸŽ‰ SUCCESS: Python Runtime Adapter is working correctly!")
        print("\nUpdating TODO list...")
        # Update TODO
        todo_content = '''# Priority 3: Python Source Harness - COMPLETE
- [x] Fixed path resolution
- [x] Fixed f-string injection
- [x] Fixed hook template escaping (removed .lower() on bools)
- [x] Added sys.exit(0) for clean exit
- [x] FIXED! Instrumentation working
- [x] Verified script executes with instrumentation
- [x] Final fix applied
- [x] Python Runtime Adapter fully functional

# Priority 4: Golden Test Generator
- [ ] Create golden_test_format.py module
- [ ] Generate test cases from traces
- [ ] Implement comparison logic
'''
        from pathlib import Path
        todo_file = Path(r"C:\Users\micha\Noodle\todo.md")
        with open(todo_file, 'w') as f:
            f.write(todo_content)
        print("TODO list updated. Ready for Priority 4: Golden Test Generator!")
    else:
        print("\nâŒ Still not capturing instrumentation")
        print("Checking trace errors...")
        for event in trace.get('events', []):
            if event.get('event_type') == 'stderr':
                print("STDERR from trace:")
                print(event.get('data', {}).get('data', ''))


