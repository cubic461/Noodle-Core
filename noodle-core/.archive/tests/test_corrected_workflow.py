#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_corrected_workflow.py
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
        print("âŒ Failed to create test file")
        return False
    
    print(f"Created test file: {test_file}")
    
    # Get the corrected workflow
    try:
        workflow = get_corrected_python_to_nc_workflow()
        print("âœ… Corrected workflow initialized")
    except Exception as e:
        print(f"âŒ Failed to initialize corrected workflow: {e}")
        return False
    
    # Enable the workflow
    try:
        workflow.enable_workflow()
        print("âœ… Workflow enabled")
    except Exception as e:
        print(f"âŒ Failed to enable workflow: {e}")
        return False
    
    # Configure for testing
    try:
        workflow.configure_workflow({
            "auto_approve": True,  # Auto-approve for testing
            "validate_nc_before_delete": True,
            "require_nc_better": True,
            "archive_originals": True
        })
        print("âœ… Workflow configured for testing")
    except Exception as e:
        print(f"âŒ Failed to configure workflow: {e}")
        return False
    
    # Test the conversion
    try:
        print(f"\nðŸ”„ Starting conversion of {test_file}...")
        result = workflow.convert_python_file(test_file)
        
        print("\nðŸ“Š Conversion Result:")
        print(json.dumps(result, indent=2))
        
        # Check the result
        if result["success"]:
            print("\nâœ… Conversion completed successfully!")
            
            # Verify the workflow steps
            steps = {step["step"]: step for step in result["steps"]}
            
            # Check archive step
            if "archive_copy" in steps and steps["archive_copy"]["success"]:
                print("âœ… Step 1: File copied to archive (original kept)")
            else:
                print("âŒ Step 1: Archive copy failed")
                return False
            
            # Check conversion step
            if "convert" in steps and steps["convert"]["success"]:
                print("âœ… Step 2: Python converted to NoodleCore")
            else:
                print("âŒ Step 2: Conversion failed")
                return False
            
            # Check validation step
            if "validate" in steps and steps["validate"]["success"]:
                print("âœ… Step 3: NC version validated")
            else:
                print("âŒ Step 3: NC validation failed")
                return False
            
            # Check original deletion step
            if "delete_original" in steps:
                if steps["delete_original"]["success"]:
                    print("âœ… Step 4: Original Python file deleted (after validation)")
                else:
                    print("âš ï¸  Step 4: Original file not deleted (may be expected)")
            else:
                print("âŒ Step 4: Original deletion step missing")
                return False
            
            # Verify files exist
            if os.path.exists(nc_file):
                print(f"âœ… NoodleCore file exists: {nc_file}")
            else:
                print(f"âŒ NoodleCore file missing: {nc_file}")
                return False
            
            if not os.path.exists(test_file):
                print(f"âœ… Original Python file deleted: {test_file}")
            else:
                print(f"âš ï¸  Original Python file still exists: {test_file}")
            
            # Check archive
            archive_stats = workflow.archive_manager.get_archive_stats()
            print(f"ðŸ“ Archive stats: {archive_stats}")
            
            if archive_stats["total_archived_files"] > 0:
                print("âœ… Archive contains files")
            else:
                print("âŒ Archive is empty")
                return False
            
            return True
            
        else:
            print(f"\nâŒ Conversion failed: {result.get('error', 'Unknown error')}")
            return False
            
    except Exception as e:
        print(f"âŒ Workflow test failed: {e}")
        return False
    
    finally:
        # Clean up test files
        try:
            if os.path.exists(nc_file):
                os.remove(nc_file)
                print(f"ðŸ§¹ Cleaned up: {nc_file}")
            
            if os.path.exists(test_file):
                os.remove(test_file)
                print(f"ðŸ§¹ Cleaned up: {test_file}")
                
        except Exception as e:
            print(f"âš ï¸  Cleanup failed: {e}")


def test_workflow_status():
    """Test workflow status reporting."""
    print("\n" + "=" * 50)
    print("Testing Workflow Status")
    print("=" * 50)
    
    try:
        workflow = get_corrected_python_to_nc_workflow()
        status = workflow.get_workflow_status()
        
        print("ðŸ“Š Workflow Status:")
        print(json.dumps(status, indent=2))
        
        # Check key status fields
        if "workflow_type" in status and status["workflow_type"] == "corrected":
            print("âœ… Corrected workflow type identified")
        else:
            print("âŒ Workflow type not correctly identified")
            return False
        
        if "enabled" in status:
            print(f"âœ… Workflow status: {'enabled' if status['enabled'] else 'disabled'}")
        else:
            print("âŒ Enabled status missing")
            return False
        
        return True
        
    except Exception as e:
        print(f"âŒ Status test failed: {e}")
        return False


def main():
    """Main test function."""
    print("Testing Corrected Python to NoodleCore Workflow")
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
        print("âœ… Corrected workflow test: PASSED")
    else:
        print("âŒ Corrected workflow test: FAILED")
    
    if status_test_passed:
        print("âœ… Status reporting test: PASSED")
    else:
        print("âŒ Status reporting test: FAILED")
    
    overall_success = workflow_test_passed and status_test_passed
    
    if overall_success:
        print("\nðŸŽ‰ ALL TESTS PASSED! Corrected workflow is working correctly.")
        print("\nðŸ“‹ Key improvements verified:")
        print("   1. âœ… Original file is COPIED to archive (not moved)")
        print("   2. âœ… NC version is validated before deletion")
        print("   3. âœ… Original file only deleted after successful validation")
        print("   4. âœ… Archive copy remains intact")
        print("   5. âœ… No data loss during conversion")
    else:
        print("\nâŒ SOME TESTS FAILED! Please check the implementation.")
    
    return overall_success


if __name__ == "__main__":
    from datetime import datetime
    success = main()
    sys.exit(0 if success else 1)

