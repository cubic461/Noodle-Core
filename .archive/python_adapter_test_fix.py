#!/usr/bin/env python3
"""
Test Suite::Noodle - python_adapter_test_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify python_adapter.py instrumentation is being called.
We see that the hook template is broken because we inject 'true' instead of 'True' from bool values.
"""
import os
import sys
from pathlib import Path

# Change to noodle-core/src
os.chdir(r'C:\Users\micha\Noodle\noodle-core\src')
sys.path.insert(0, os.getcwd())

# Import the adapter module
from migration.source_harness.runtime_adapters.python_adapter import PythonRuntimeAdapter, PythonObservationConfig

# Create adapter
adapter = PythonRuntimeAdapter(config=PythonObservationConfig(
    enable_io_tracing=True,
    enable_call_tracing=True
))

# Construct paths
current_file = Path(r"C:\Users\micha\Noodle\noodle-core\src\migration\source_harness\runtime_adapters\python_adapter.py")
project_root = current_file.parent.parent.parent.parent

examples_dir = project_root / "migration" / "examples"
simple_file_path = examples_dir / "simple_file_processor.py"
sample_input_path = examples_dir / "sample_input.csv"
output_file_path = examples_dir / "test_output.csv"

print(f"Adapter config: IO={adapter.config.enable_io_tracing}, Call={adapter.config.enable_call_tracing}")
print(f"Type of config values: IO type={type(adapter.config.enable_io_tracing)}")

# Generate the hook script manually
if adapter.trace is None:
    # Create a minimal trace for the adapter
    from migration.source_harness.trace_format import Trace
    adapter.trace = Trace(
        language="python",
        command=["python", str(simple_file_path), str(sample_input_path), str(output_file_path)],
        working_dir=str(examples_dir)
    )
    print("Created trace_id:", adapter.trace.trace_id)

hook_script = adapter._generate_hook_script(str(simple_file_path))

# Save it to a file for inspection
with open("generated_hook_debug.py", "w") as f:
    f.write(hook_script)

print("\n=== Generated Hook Script Inspection ===")
lines = hook_script.split('\n')
for i, line in enumerate(lines[:50], 1):
    print(f"{i:3d}: {line}")

# Check for boolean injection
if "true" in hook_script or "false" in hook_script:
    print("\n[ERROR] Found lowercase 'true' or 'false' in hook script!")
if "@IO_TRACING@" in hook_script or "@CALL_TRACING@" in hook_script:
    print("[ERROR] Found unreplaced placeholders!")
    
# Also show what booleans are after str(...)
print(f"IO Tracing as lower string: '{str(adapter.config.enable_io_tracing).lower()}'")
print(f"Call Tracing as lower string: '{str(adapter.config.enable_call_tracing).lower()}'")
    
# Now try to run the adapter if hook looks correct
if "true" not in hook_script and "false" not in hook_script:
    print("\nHook script looks correct. Running adapter...")
    trace = adapter.observe(str(simple_file_path), [str(sample_input_path), str(output_file_path)])
    print(f"Success! Calls: {len(trace.call_graph)}, IO: {len(trace.io_log)}")
else:
    print("\nHook script needs fixing.")


