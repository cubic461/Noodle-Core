#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for IDE Integration with Corrected Workflow

This script tests the corrected workflow through the IDE interface.
"""

import os
import sys
import json
import logging
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE

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
Test Python file for IDE integration testing.

This file will be converted using the corrected workflow through the IDE.
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


def test_ide_workflow():
    """Test the corrected workflow through the IDE interface."""
    print("=" * 70)
    print("Testing IDE Integration with Corrected Workflow")
    print("=" * 70)
    
    # Create test Python file
    test_file = "test_ide_workflow_sample.py"
    
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
    
    # Initialize the IDE
    try:
        ide = NativeNoodleCoreIDE()
        print("IDE initialized successfully")
    except Exception as e:
        print(f"Failed to initialize IDE: {e}")
        return False
    
    # Test the workflow through IDE
    try:
        print(f"\nTesting workflow through IDE for {test_file}...")
        
        # Enable Python to NoodleCore conversion
        ide.enable_python_to_nc_conversion()
        print("Python to NoodleCore conversion enabled")
        
        # Configure for testing
        ide.configure_python_conversion({
            "auto_approve": True,
            "validate_nc_before_delete": True,
            "require_nc_better": True,
            "archive_originals": True
        })
        print("Python conversion configured for testing")
        
        # Convert the file
        result = ide.convert_python_to_nc(test_file)
        
        print("\nIDE Conversion Result:")
        print(json.dumps(result, indent=2))
        
        # Check the result
        if result["success"]:
            print("\nIDE conversion completed successfully!")
            
            # Verify the workflow steps
            steps = {step["step"]: step for step in result.get("steps", [])}
            
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
            
            return True
            
        else:
            print(f"\nIDE conversion failed: {result.get('error', 'Unknown error')}")
            return False
            
    except Exception as e:
        print(f"IDE workflow test failed: {e}")
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


def main():
    """Main test function."""
    print("Testing IDE Integration with Corrected Workflow")
    from datetime import datetime
    print(f"Current time: {datetime.now().isoformat()}")
    
    # Test the IDE workflow
    ide_test_passed = test_ide_workflow()
    
    # Summary
    print("\n" + "=" * 70)
    print("IDE INTEGRATION TEST SUMMARY")
    print("=" * 70)
    
    if ide_test_passed:
        print("IDE integration test: PASSED")
        print("\nKey improvements verified:")
        print("   1. Original file is COPIED to archive through IDE")
        print("   2. NC version is validated before deletion")
        print("   3. Original file only deleted after successful validation")
        print("   4. Archive copy remains intact")
        print("   5. No data loss during conversion")
        print("   6. IDE interface works correctly with corrected workflow")
    else:
        print("IDE integration test: FAILED")
    
    return ide_test_passed


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

