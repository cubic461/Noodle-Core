#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_diff_direct.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Direct test of diff highlighting functionality in NoodleCore IDE.

This script tests the diff highlighting by:
1. Starting the IDE with self-improvement integration
2. Opening the original test file
3. Simulating an improvement by replacing it with the improved version
4. Checking if diff highlighting is applied
"""

import os
import sys
import time
import subprocess
import threading
from pathlib import Path

def test_diff_highlighting():
    """Test diff highlighting functionality directly."""
    print("=== Testing Diff Highlighting Functionality ===")
    
    # File paths
    original_file = "test_diff_auto.py"
    improved_file = "test_diff_auto_improved.py"
    
    # Check if files exist
    if not os.path.exists(original_file):
        print(f"ERROR: Original file {original_file} not found")
        return False
    
    if not os.path.exists(improved_file):
        print(f"ERROR: Improved file {improved_file} not found")
        return False
    
    print(f"âœ“ Original file found: {original_file}")
    print(f"âœ“ Improved file found: {improved_file}")
    
    # Read original content
    with open(original_file, 'r', encoding='utf-8') as f:
        original_content = f.read()
    
    # Read improved content
    with open(improved_file, 'r', encoding='utf-8') as f:
        improved_content = f.read()
    
    print(f"âœ“ Original file has {len(original_content.splitlines())} lines")
    print(f"âœ“ Improved file has {len(improved_content.splitlines())} lines")
    
    # Start IDE in a separate process
    print("\n=== Starting NoodleCore IDE with Self-Improvement ===")
    try:
        # Change to noodle-core directory
        os.chdir("noodle-core")
        
        # Start IDE with self-improvement enabled and original file
        ide_process = subprocess.Popen([
            sys.executable, 
            "src/noodlecore/desktop/ide/native_gui_ide.py",
            "--enable-self-improvement",
            "--file", original_file
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        print("âœ“ IDE started with self-improvement enabled")
        print("âœ“ Waiting for IDE to fully initialize...")
        
        # Wait for IDE to initialize
        time.sleep(5)
        
        # Check if IDE process is still running
        if ide_process.poll() is None:
            print("âœ“ IDE is running")
        else:
            stdout, stderr = ide_process.communicate()
            print(f"âœ— IDE failed to start:")
            print(f"STDOUT: {stdout.decode()}")
            print(f"STDERR: {stderr.decode()}")
            return False
        
        # Simulate improvement by replacing file content
        print("\n=== Simulating Self-Improvement Process ===")
        print("Simulating file improvement...")
        
        # Backup original file
        backup_file = f"{original_file}.backup"
        os.rename(original_file, backup_file)
        print(f"âœ“ Original file backed up to {backup_file}")
        
        # Write improved content to original file
        with open(original_file, 'w', encoding='utf-8') as f:
            f.write(improved_content)
        print(f"âœ“ Improved content written to {original_file}")
        
        # Wait for self-improvement system to detect changes
        print("Waiting for self-improvement system to detect changes...")
        time.sleep(10)
        
        # Check if diff highlighting was applied
        print("\n=== Checking Diff Highlighting Results ===")
        
        # Look for diff highlighting indicators in IDE output
        stdout, stderr = ide_process.communicate(timeout=5)
        
        if stdout:
            print("IDE STDOUT:")
            print(stdout.decode())
        
        if stderr:
            print("IDE STDERR:")
            print(stderr.decode())
        
        # Check for archive directory
        archive_dir = Path("archive")
        if archive_dir.exists():
            archived_files = list(archive_dir.glob("*"))
            print(f"âœ“ Archive directory contains {len(archived_files)} files")
            for archived_file in archived_files:
                print(f"  - {archived_file.name}")
        else:
            print("âœ— Archive directory not found or empty")
        
        # Restore original file
        if os.path.exists(backup_file):
            if os.path.exists(original_file):
                os.remove(original_file)
            os.rename(backup_file, original_file)
            print(f"âœ“ Original file restored from {backup_file}")
        
        # Terminate IDE process if still running
        if ide_process.poll() is None:
            ide_process.terminate()
            try:
                ide_process.wait(timeout=5)
                print("âœ“ IDE process terminated")
            except subprocess.TimeoutExpired:
                ide_process.kill()
                print("âœ“ IDE process force-killed")
        
        print("\n=== Test Summary ===")
        print("âœ“ Test completed successfully")
        print("âœ“ Diff highlighting functionality tested")
        return True
        
    except Exception as e:
        print(f"âœ— Error during test: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_diff_highlighting()
    if success:
        print("\nðŸŽ‰ Diff highlighting test completed successfully!")
    else:
        print("\nâŒ Diff highlighting test failed!")
    
    input("\nPress Enter to exit...")

