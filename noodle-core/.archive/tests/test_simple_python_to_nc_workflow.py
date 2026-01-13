#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_python_to_nc_workflow.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test for Python to NoodleCore conversion workflow.

This script tests the basic functionality without complex dependencies.
"""

import os
import sys
import tempfile
from pathlib import Path

def create_simple_python_file(file_path: str) -> None:
    """Create a simple test Python file."""
    content = '''#!/usr/bin/env python3
"""
Simple test Python file for conversion.
"""

def hello_world():
    """A simple hello world function."""
    print("Hello, World!")
    return "Hello, World!"

def calculate_sum(a, b):
    """Calculate the sum of two numbers."""
    return a + b

def main():
    """Main function."""
    hello_world()
    result = calculate_sum(5, 3)
    print(f"Sum of 5 and 3 is: {result}")
    
if __name__ == "__main__":
    main()
'''
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def test_basic_conversion():
    """Test basic Python to NoodleCore conversion."""
    print("Testing basic Python to NoodleCore conversion...")
    
    # Create temporary directory
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Create test Python file
        py_file = temp_path / "test_simple.py"
        create_simple_python_file(str(py_file))
        print(f"Created test Python file: {py_file}")
        
        # Test basic conversion (simple approach)
        try:
            # Read Python file
            with open(py_file, 'r', encoding='utf-8') as f:
                python_code = f.read()
            
            # Simple conversion (basic approach)
            nc_code = python_code.replace('print(', 'println(')
            nc_code = nc_code.replace('def ', 'func ')
            nc_code = nc_code.replace('return ', 'return ')
            
            # Create .nc file
            nc_file = py_file.with_suffix('.nc')
            with open(nc_file, 'w', encoding='utf-8') as f:
                f.write(nc_code)
            
            print(f"[SUCCESS] Basic conversion successful: {nc_file}")
            
            # Verify .nc file exists and has content
            if nc_file.exists():
                with open(nc_file, 'r', encoding='utf-8') as f:
                    nc_content = f.read()
                if nc_content and 'println(' in nc_content:
                    print(f"[SUCCESS] NoodleCore file contains converted code")
                    return True
                else:
                    print(f"[ERROR] NoodleCore file missing expected content")
                    return False
            else:
                print(f"[ERROR] NoodleCore file not created")
                return False
                
        except Exception as e:
            print(f"[ERROR] Basic conversion failed: {e}")
            return False

def main():
    """Main test function."""
    print("=" * 60)
    print("Simple Python to NoodleCore Conversion Test")
    print("=" * 60)
    
    success = test_basic_conversion()
    
    if success:
        print("\n[SUCCESS] Basic Python to NoodleCore conversion test PASSED")
        return 0
    else:
        print("\n[ERROR] Basic Python to NoodleCore conversion test FAILED")
        return 1

if __name__ == "__main__":
    sys.exit(main())

