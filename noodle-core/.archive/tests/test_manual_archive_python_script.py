#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_manual_archive_python_script.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Manual script to archive a Python file that was already converted to NoodleCore.

This script will:
1. Check if the Python file exists
2. Check if it's already converted to .nc
3. Archive the Python file using the version archive manager
4. Add a note that this was already converted
"""

import os
import sys
from pathlib import Path
from datetime import datetime

# Add noodle-core to path for imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

def main():
    """Main function to manually archive a Python file."""
    if len(sys.argv) < 2:
        print("Usage: python test_manual_archive_python_script.py <python_file_path>")
        return 1
    
    python_file_path = sys.argv[1]
    python_path = Path(python_file_path)
    
    print("=" * 60)
    print("Manual Python File Archive Script")
    print("=" * 60)
    print(f"Target file: {python_file_path}")
    print(f"Current time: {datetime.now().isoformat()}")
    print()
    
    # Check if Python file exists
    if not python_path.exists():
        print(f"[ERROR] Python file not found: {python_file_path}")
        return 1
    
    # Check if .nc file exists (already converted)
    nc_file_path = python_file_path[:-3] + '.nc'
    nc_path = Path(nc_file_path)
    
    if nc_path.exists():
        print(f"[INFO] Found corresponding .nc file: {nc_file_path}")
        print("[INFO] This file has already been converted to NoodleCore")
    else:
        print(f"[WARNING] No corresponding .nc file found: {nc_file_path}")
        print("[WARNING] This file may not have been converted yet")
    
    print()
    print("Attempting to archive Python file...")
    
    try:
        # Import the version archive manager
        from noodlecore.desktop.ide.version_archive_manager import VersionArchiveManager
        
        # Create archive manager instance
        archive_manager = VersionArchiveManager()
        
        # Read the Python file content
        with open(python_file_path, 'r', encoding='utf-8') as f:
            python_content = f.read()
        
        print(f"[INFO] Read Python file: {len(python_content)} characters")
        
        # Archive the file with a note about manual archival
        success = archive_manager.archive_version(
            python_file_path,
            python_content,
            improvement_type="manual_python_archive",
            improvement_description=f"Manually archived Python file that was already converted (Timestamp: {datetime.now().isoformat()})",
            new_content=None
        )
        
        if success:
            print(f"[SUCCESS] Python file archived successfully!")
            print(f"[INFO] Archive location: {archive_manager.archive_path}")
            
            # Get archive stats
            stats = archive_manager.get_archive_stats()
            print(f"[INFO] Archive stats: {stats}")
            
            # List archived versions for this file
            file_name = python_path.name
            archived_versions = archive_manager.get_archived_versions(python_file_path)
            
            print(f"[INFO] Archived versions for {file_name}:")
            for version in archived_versions:
                print(f"  - {version['type']} v{version['version']} ({version['timestamp']})")
            
            return 0
        else:
            print(f"[ERROR] Failed to archive Python file")
            return 1
            
    except Exception as e:
        print(f"[ERROR] Archive operation failed: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())

