#!/usr/bin/env python3
"""
Test Suite::Noodle - test_live_reload.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Live Reload Demo Test Script
Tests the live reload functionality by monitoring changes to demo_service.nc
"""

import os
import sys
import time
from datetime import datetime
from pathlib import Path

# Add noodle-core to path
noodle_path = Path(__file__).parent / "noodle-core"
if noodle_path.exists():
    sys.path.insert(0, str(noodle_path))

def test_live_reload():
    """Test the live reload functionality"""
    
    # Path to demo_service.nc
    demo_file = Path("examples/live_reload_demo/demo_service.nc")
    
    print(f"[TEST] Live Reload Demo Test")
    print(f"[FILE] Testing file: {demo_file}")
    print(f"[TIME] Starting at: {datetime.now().strftime('%H:%M:%S')}")
    print("-" * 50)
    
    # Check if file exists
    if not demo_file.exists():
        print(f"[ERROR] {demo_file} not found!")
        return
    
    # Get initial file stats
    initial_mtime = demo_file.stat().st_mtime
    print(f"[INFO] Initial modification time: {initial_mtime}")
    
    # Read initial content
    with open(demo_file, 'r') as f:
        initial_content = f.read()
    
    print(f"[CONTENT] Initial content:")
    print("-" * 30)
    print(initial_content)
    print("-" * 30)
    
    print(f"\n[WAIT] Waiting for changes... (will check every 2 seconds)")
    print(f"[TIP] Try editing and saving {demo_file} now!")
    
    # Monitor for changes
    try:
        while True:
            time.sleep(2)
            
            if demo_file.exists():
                current_mtime = demo_file.stat().st_mtime
                
                if current_mtime != initial_mtime:
                    print(f"\n[SUCCESS] File changed detected!")
                    print(f"[TIME] Change detected at: {datetime.now().strftime('%H:%M:%S')}")
                    
                    # Read new content
                    with open(demo_file, 'r') as f:
                        new_content = f.read()
                    
                    print(f"[CONTENT] New content:")
                    print("-" * 30)
                    print(new_content)
                    print("-" * 30)
                    
                    # Show diff
                    print(f"\n[DIFF] Changes made:")
                    print(f"    Old: {initial_content.splitlines()[3].strip()}")
                    print(f"    New: {new_content.splitlines()[3].strip()}")
                    
                    print(f"\n[SUCCESS] Live reload test successful!")
                    break
            else:
                print(f"[ERROR] File disappeared: {demo_file}")
                break
                
    except KeyboardInterrupt:
        print(f"\n[STOP] Stopped by user")
    
    print(f"\n[DONE] Test completed at: {datetime.now().strftime('%H:%M:%S')}")

if __name__ == "__main__":
    try:
        test_live_reload()
    except Exception as e:
        print(f"[ERROR] Error running test: {e}")
        sys.exit(1)


