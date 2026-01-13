# 🔧 Fix Python Adapter Hook Script Exit Issue

## 🚨 Probleem

De hook script in `python_adapter.py` heeft een **kritieke fout**:

1. `sys.exit(0)` wordt aangeroepen in de `finalize()` functie
2. `finalize()` is geregistreerd als `atexit` callback
3. Wanneer `simple_file_processor.py` een argparse error geeft → start Python exit
4. `atexit` callbacks worden triggered → `finalize()` roept `sys.exit(0)` aan
5. **Resultaat**: De trace data (call_graph, io_log) wordt niet meer verzameld

## 🔍 Symptomen

In `test_adapter.py` output:
- Hook zegt: "Calls: 4554" en "IO: 1" ✅
- Maar trace object heeft: `"call_graph": [], "io_log": []` ❌
- Exit code: 2 (argparse error)
- Fout: "SystemExit: 0" in atexit callback

## 💡 Oplossing

### Stap 1: Verwijder `sys.exit(0)` uit `finalize()`

```python
def finalize():
    if not _TRACE:
        return
    _TRACE["end_time"] = time.time()
    _TRACE["duration"] = _TRACE["end_time"] - _TRACE["start_time"]
    
    print("")
    print("=== Trace ===")
    print("Duration: {:.3f}s".format(_TRACE["duration"]))
    print("Calls: {}".format(len(_TRACE["call_graph"])))
    print("IO: {}".format(len(_TRACE["io_log"])))
    print("Trace ID: {}".format(_TRACE["trace_id"]))
    # VERWIJDERD: sys.exit(0)
```

### Stap 2: Voeg try-catch toe rond exec()

```python
# Start instrumentation
setup()

# Execute script with proper error handling
try:
    sys.argv = ["python", _SCRIPT_PATH] + sys.argv[1:]
    exec(open(_SCRIPT_PATH).read(), {"__file__": _SCRIPT_PATH, "__name__": "__main__"})
    _TRACE["exit_code"] = 0  # Success
except SystemExit as e:
    _TRACE["exit_code"] = e.code if e.code is not None else 0
    # Don't re-raise - let script finish naturally
except Exception as e:
    _TRACE["exit_code"] = 1
    print("[ERROR] Script failed: {}".format(e), file=sys.stderr)
    import traceback
    traceback.print_exc()

# Clean exit after everything is done
sys.exit(_TRACE.get("exit_code", 0))
```

## 📝 Code Template

```python
def _generate_hook_script(self, script_path: str) -> str:
    """Generate hook script that patches Python builtins."""
    
    # Determine trace_id to embed
    trace_id = self.trace.trace_id if self.trace else f"trace_{int(time.time())}"
    script_dir = os.path.dirname(script_path)
    
    # Safely encode values using json.dumps for proper quoting
    trace_id_str = json.dumps(trace_id)
    script_path_str = json.dumps(script_path)
    script_dir_str = json.dumps(script_dir)
    
    # Template for the hook script
    template = '''#!/usr/bin/env python3
# Python Runtime Adapter Hook Script

import sys
import os
import time
import json
import threading
from pathlib import Path

# Prepare environment - values injected via format()
_SCRIPT_PATH = @SCRIPT_PATH
_SCRIPT_DIR = @SCRIPT_DIR
_TRACE_ID = @TRACE_ID

# Global state
_TRACE = None
_IO_COUNT = 0
_CALL_COUNT = 0
_CALL_STACK = []
_LOCK = threading.Lock()
_ORIGINAL_OPEN = open

def setup():
    global _TRACE
    _TRACE = {
        "trace_id": @TRACE_ID,
        "language": "python",
        "script_path": @SCRIPT_PATH,
        "start_time": time.time(),
        "events": [],
        "call_graph": [],
        "io_log": [],
        "exit_code": 0
    }
    
    if @IO_TRACING:
        import builtins
        builtins.open = hook_open
    if @CALL_TRACING:
        sys.settrace(hook_trace)
    import atexit
    atexit.register(finalize)

def hook_open(file, mode='r', *args, **kwargs):
    global _IO_COUNT
    with _LOCK:
        op = {
            "operation": "open",
            "path": str(file),
            "mode": mode,
            "timestamp": time.time(),
            "thread": threading.get_ident()
        }
        _TRACE["io_log"].append(op)
        _IO_COUNT += 1
    return _ORIGINAL_OPEN(file, mode, *args, **kwargs)

def hook_trace(frame, event, arg):
    if event == "call":
        with _LOCK:
            call = {
                "name": frame.f_code.co_name,
                "module": frame.f_globals.get("__name__", ""),
                "filename": frame.f_code.co_filename,
                "lineno": frame.f_lineno,
                "timestamp": time.time(),
                "thread": threading.get_ident()
            }
            _TRACE["call_graph"].append(call)
            _CALL_STACK.append(time.time())
    return hook_trace

def finalize():
    """Finalize trace - DO NOT call sys.exit() here!"""
    if not _TRACE:
        return
    _TRACE["end_time"] = time.time()
    _TRACE["duration"] = _TRACE["end_time"] - _TRACE["start_time"]
    
    print("")
    print("=== Trace ===")
    print("Duration: {:.3f}s".format(_TRACE["duration"]))
    print("Calls: {}".format(len(_TRACE["call_graph"])))
    print("IO: {}".format(len(_TRACE["io_log"])))
    print("Trace ID: {}".format(_TRACE["trace_id"]))

# Start instrumentation
setup()

# Execute script with proper error handling
try:
    sys.argv = ["python", _SCRIPT_PATH] + sys.argv[1:]
    exec(open(_SCRIPT_PATH).read(), {"__file__": _SCRIPT_PATH, "__name__": "__main__"})
    _TRACE["exit_code"] = 0
except SystemExit as e:
    _TRACE["exit_code"] = e.code if e.code is not None else 0
    # Don't re-raise - let script finish naturally
except Exception as e:
    _TRACE["exit_code"] = 1
    print("[ERROR] Script failed: {}".format(e), file=sys.stderr)
    import traceback
    traceback.print_exc()

# Clean exit after everything is done
sys.exit(_TRACE.get("exit_code", 0))
'''
    
    # Replace placeholders with properly quoted values
    hook_content = template.replace("@SCRIPT_PATH", script_path_str)
    hook_content = hook_content.replace("@SCRIPT_DIR", script_dir_str)
    hook_content = hook_content.replace("@TRACE_ID", trace_id_str)
    hook_content = hook_content.replace("@IO_TRACING", str(self.config.enable_io_tracing))
    hook_content = hook_content.replace("@CALL_TRACING", str(self.config.enable_call_tracing))
    
    return hook_content
```

## 🎯 Test Na Fix

```bash
# Run test again
python C:\Users\micha\Noodle\noodle-core\src\migration\source_harness\runtime_adapters\test_adapter.py
```

**Verwacht Resultaat:**
- Exit code: 0 of 2 (maakt niet uit)
- Function calls: > 4000 (niet leeg!)
- I/O operations: 1 (niet leeg!)
- Trace JSON bevat call_graph en io_log data

## ✅ Success Criteria

- [ ] Geen "SystemExit ignored" error meer
- [ ] `call_graph` bevat 4554+ functie calls
- [ ] `io_log` bevat 1+ I/O operatie
- [ ] Exit code wordt correct doorgegeven
- [ ] Trace data blijft behouden in JSON

---
