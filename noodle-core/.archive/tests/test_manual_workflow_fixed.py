#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_manual_workflow_fixed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Manual test for Python to NoodleCore workflow with archiving - FIXED VERSION.
"""

import sys
import os
from pathlib import Path

# Add the noodle-core directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from src.noodlecore.compiler.python_to_nc_workflow import PythonToNoodleCoreWorkflow

def main():
    """Test the workflow manually."""
    # Create workflow instance
    workflow = PythonToNoodleCoreWorkflow()
    
    # Enable workflow
    workflow.enable_workflow()
    
    # Test file - use absolute path
    test_file = os.path.abspath("test_simple_python.py")
    
    print(f"Testing workflow with file: {test_file}")
    print(f"Workflow enabled: {workflow.is_workflow_enabled()}")
    
    # Execute conversion
    result = workflow.convert_python_file(test_file)
    
    print(f"Conversion result: {result}")
    
    if result['success']:
        print(f"Success! NC file created: {result['nc_file']}")
        print(f"Success! Archived: {result['archived']}")
        
        # Check if files were actually created
        if os.path.exists(result['nc_file']):
            print(f"Success! NC file exists at: {result['nc_file']}")
        else:
            print(f"Error! NC file NOT found at: {result['nc_file']}")
            
        # Check archived versions directory
        archive_dir = Path("noodle-core/archived_versions")
        if archive_dir.exists():
            archived_files = list(archive_dir.rglob("*"))
            print(f"Success! Archive directory contains {len(archived_files)} files")
            for f in archived_files[:5]:  # Show first 5 files
                print(f"  - {f.name}")
        else:
            print("Error! Archive directory not found")
    else:
        print(f"Error! Conversion failed: {result.get('error', 'Unknown error')}")

if __name__ == "__main__":
    main()

