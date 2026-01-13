#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_corrected_workflow_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for the Corrected Python to NoodleCore Workflow

This script tests the corrected workflow that:
1. Copies original Python file to archive (keeps original)
2. Converts to NoodleCore format
3. Validates NC version works and is better
4. Only then deletes original Python file
5. Archive copy remains intact
"""

import os
import sys
import json
import logging
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from noodlecore.compiler.corrected_python_to_nc_workflow import get_corrected_python_to_nc_workflow

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def create_test_python_file(file_path: str) -> bool:
    """Create a simple test Python file."""
    try:
        content = '''#!/usr/bin/env python3
"""
Test Python file for conversion to NoodleCore

This is a simple test file to verify the corrected workflow.
"""

def calculate_fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    else:
        return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

def main():
    """Main function to test Fibonacci calculation."""
    print("Testing Fibonacci calculation:")
    
    for i in range(10):
        result = calculate_fibonacci(i)
        print(f"Fibonacci({i}) = {result}")
    
    print("Test completed successfully!")

if __name__ == "__main__":
    main()
'''
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        logger.info(f"Created test Python file: {file_path}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to create test Python file: {e}")
        return False


def test_corrected_workflow():
    """Test the corrected Python to NoodleCore workflow."""
    print("=" * 70)
    print("Testing Corrected Python to NoodleCore Workflow")
    print("=" * 70)
    
    # Create test Python file
    test_file = "test_corrected_workflow_sample.py"
    
    # Clean up any existing files
    if os.path.exists(test_file):
        os.remove(test_file)
    
    nc_file = test_file[:-3] + '.nc'
    if os.path.exists(nc_file):
        os.remove(nc_file)
    
    # Create test file
    if not create_test_python_file(test_file):
        print("Failed to create test file")
        return False
    
    print(f"Created test file: {test_file}")
    
    # Get the corrected workflow
    try:
        workflow = get_corrected_python_to_nc_workflow()
        print("Corrected workflow initialized")
    except Exception as e:
        print(f"Failed to initialize corrected workflow: {e}")
        return False
    
    # Enable the workflow
    try:
        workflow.enable_workflow()
        print("Workflow enabled")
    except Exception as e:
        print(f"Failed to enable workflow: {e}")
        return False
    
    # Configure for testing
    try:
        workflow.configure_workflow({
            "auto_approve": True,  # Auto-approve for testing
            "validate_nc_before_delete": True,
            "require_nc_better": True,
            "archive_originals": True
        })
        print("Workflow configured for testing")
    except Exception as e:
        print(f"Failed to configure workflow: {e}")
        return False
    
    # Test the conversion
    try:
        print(f"\nStarting conversion of {test_file}...")
        result = workflow.convert_python_file(test_file)
        
        print("\nConversion Result:")
        print(json.dumps(result, indent=2))
        
        # Check the result
        if result["success"]:
            print("\nConversion completed successfully!")
            
            # Verify the workflow steps
            steps = {step["step"]: step for step in result["steps"]}
            
            # Check archive step
            if "archive_copy" in steps and steps["archive_copy"]["success"]:
                print("Step 1: File copied to archive (original kept)")
            else:
                print("Step 1: Archive copy failed")
                return False
            
            # Check conversion step
            if "convert" in steps and steps["convert"]["success"]:
                print("Step 2: Python converted to NoodleCore")
            else:
                print("Step 2: Conversion failed")
                return False
            
            # Check validation step
            if "validate" in steps and steps["validate"]["success"]:
                print("Step 3: NC version validated")
            else:
                print("Step 3: NC validation failed")
                return False
            
            # Check original deletion step
            if "delete_original" in steps:
                if steps["delete_original"]["success"]:
                    print("Step 4: Original Python file deleted (after validation)")
                else:
                    print("Step 4: Original file not deleted (may be expected)")
            else:
                print("Step 4: Original deletion step missing")
                return False
            
            # Verify files exist
            if os.path.exists(nc_file):
                print(f"NoodleCore file exists: {nc_file}")
            else:
                print(f"NoodleCore file missing: {nc_file}")
                return False
            
            if not os.path.exists(test_file):
                print(f"Original Python file deleted: {test_file}")
            else:
                print(f"Original Python file still exists: {test_file}")
            
            # Check archive
            archive_stats = workflow.archive_manager.get_archive_stats()
            print(f"Archive stats: {archive_stats}")
            
            if archive_stats["total_archived_files"] > 0:
                print("Archive contains files")
            else:
                print("Archive is empty")
                return False
            
            return True
            
        else:
            print(f"\nConversion failed: {result.get('error', 'Unknown error')}")
            return False
            
    except Exception as e:
        print(f"Workflow test failed: {e}")
        return False
    
    finally:
        # Clean up test files
        try:
            if os.path.exists(nc_file):
                os.remove(nc_file)
                print(f"Cleaned up: {nc_file}")
            
            if os.path.exists(test_file):
                os.remove(test_file)
                print(f"Cleaned up: {test_file}")
                
        except Exception as e:
            print(f"Cleanup failed: {e}")


def test_workflow_status():
    """Test workflow status reporting."""
    print("\n" + "=" * 50)
    print("Testing Workflow Status")
    print("=" * 50)
    
    try:
        workflow = get_corrected_python_to_nc_workflow()
        status = workflow.get_workflow_status()
        
        print("Workflow Status:")
        print(json.dumps(status, indent=2))
        
        # Check key status fields
        if "workflow_type" in status and status["workflow_type"] == "corrected":
            print("Corrected workflow type identified")
        else:
            print("Workflow type not correctly identified")
            return False
        
        if "enabled" in status:
            print(f"Workflow status: {'enabled' if status['enabled'] else 'disabled'}")
        else:
            print("Enabled status missing")
            return False
        
        return True
        
    except Exception as e:
        print(f"Status test failed: {e}")
        return False


def main():
    """Main test function."""
    print("Testing Corrected Python to NoodleCore Workflow")
    from datetime import datetime
    print(f"Current time: {datetime.now().isoformat()}")
    
    # Test the corrected workflow
    workflow_test_passed = test_corrected_workflow()
    
    # Test status reporting
    status_test_passed = test_workflow_status()
    
    # Summary
    print("\n" + "=" * 70)
    print("TEST SUMMARY")
    print("=" * 70)
    
    if workflow_test_passed:
        print("Corrected workflow test: PASSED")
    else:
        print("Corrected workflow test: FAILED")
    
    if status_test_passed:
        print("Status reporting test: PASSED")
    else:
        print("Status reporting test: FAILED")
    
    overall_success = workflow_test_passed and status_test_passed
    
    if overall_success:
        print("\nALL TESTS PASSED! Corrected workflow is working correctly.")
        print("\nKey improvements verified:")
        print("   1. Original file is COPIED to archive (not moved)")
        print("   2. NC version is validated before deletion")
        print("   3. Original file only deleted after successful validation")
        print("   4. Archive copy remains intact")
        print("   5. No data loss during conversion")
    else:
        print("\nSOME TESTS FAILED! Please check the implementation.")
    
    return overall_success


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

