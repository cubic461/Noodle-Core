#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_auto_linter_integration_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Test script for Auto Linter and Documentation Integration

This script tests the integration of auto linter and documentation
functionality into the self-improvement workflow.
"""

import os
import sys
import json
import tempfile
import shutil
from pathlib import Path
from datetime import datetime

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent / "src"))

def create_test_files():
    """Create test files for linting and documentation testing."""
    test_dir = Path(tempfile.mkdtemp(prefix="noodle_test_"))
    
    # Create a Python file with linting issues
    py_file = test_dir / "test_file.py"
    py_content = '''#!/usr/bin/env python3
"""
Test file for auto linter and documentation integration.
"""

import os
import sys
import json  # Unused import
import requests  # Unused import

def calculate_sum(a, b, c, d, e, f):
    # This function is too long and has too many parameters
    result = a + b + c + d + e + f
    return result

def another_function():
    # This function is missing a docstring
    x = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15 + 16 + 17 + 18 + 19 + 20
    y = x * 2
    return y

class TestClass:
    def __init__(self):
        self.value = 42
        
    def method_with_very_long_name_that_exceeds_pep8_guidelines(self, parameter1, parameter2, parameter3, parameter4, parameter5):
        # This line is too long and method name is too long
        return parameter1 + parameter2 + parameter3 + parameter4 + parameter5
'''
    with open(py_file, 'w') as f:
        f.write(py_content)
    
    # Create a JavaScript file with issues
    js_file = test_dir / "test_file.js"
    js_content = '''// JavaScript file with linting issues
var unused_variable = "This is unused";

function calculateSum(a, b, c) {
    // Function name should be camelCase
    var result = a + b + c;
    return result;
}

// Missing semicolon
var anotherFunction = function() {
    console.log("Hello World")
}

// Line too long
var veryLongVariableNameThatExceedsRecommendedLengthAndShouldBeShortened = "This is a very long string that exceeds the recommended line length for JavaScript files";
'''
    with open(js_file, 'w') as f:
        f.write(js_content)
    
    # Create a NoodleCore file
    nc_file = test_dir / "test_file.nc"
    nc_content = '''# NoodleCore test file
func calculate_product(a, b):
    # Missing docstring
    return a * b

func another_function():
    # This function has no documentation
    x = 10
    return x + 5
'''
    with open(nc_file, 'w') as f:
        f.write(nc_content)
    
    return test_dir

def test_auto_linter_integration():
    """Test the auto linter integration."""
    print("Testing Auto Linter Integration...")
    
    try:
        from noodlecore.desktop.ide.auto_linter_documentation_integration import AutoLinterDocumentationIntegration
        
        # Create the integration
        integration = AutoLinterDocumentationIntegration()
        
        # Check if linter API is initialized
        if integration.linter_api:
            print("âœ“ Linter API initialized successfully")
        else:
            print("âœ— Linter API initialization failed")
            return False
        
        # Get statistics
        stats = integration.get_statistics()
        print(f"âœ“ Statistics retrieved: {stats}")
        
        return True
        
    except Exception as e:
        print(f"âœ— Error testing auto linter integration: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_auto_documentation_integration():
    """Test the auto documentation integration."""
    print("Testing Auto Documentation Integration...")
    
    try:
        from noodlecore.desktop.ide.auto_linter_documentation_integration import AutoLinterDocumentationIntegration
        
        # Create the integration
        integration = AutoLinterDocumentationIntegration()
        
        # Check if documentation integration is initialized
        if integration.documentation_integration:
            print("âœ“ Documentation integration initialized successfully")
        else:
            print("âœ— Documentation integration initialization failed")
            return False
        
        # Get statistics
        stats = integration.get_statistics()
        print(f"âœ“ Statistics retrieved: {stats}")
        
        return True
        
    except Exception as e:
        print(f"âœ— Error testing auto documentation integration: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_configuration():
    """Test configuration loading."""
    print("Testing Configuration...")
    
    try:
        from noodlecore.desktop.ide.auto_linter_documentation_integration import AutoLinterDocumentationIntegration
        
        # Create the integration
        integration = AutoLinterDocumentationIntegration()
        
        # Check configuration
        config = integration.config
        print(f"âœ“ Configuration loaded: {json.dumps(config, indent=2)}")
        
        # Test configuration update
        new_settings = {
            "enable_auto_linter": False,
            "enable_auto_documentation": False,
            "linting_interval": 120
        }
        integration.configure_settings(new_settings)
        
        # Check if settings were applied
        if not integration.config.get("enable_auto_linter"):
            print("âœ“ Configuration updated successfully")
        else:
            print("âœ— Configuration update failed")
            return False
        
        return True
        
    except Exception as e:
        print(f"âœ— Error testing configuration: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Main test function."""
    print("=" * 60)
    print("Auto Linter and Documentation Integration Test")
    print("=" * 60)
    print(f"Test started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Run tests
    tests = [
        ("Configuration", test_configuration),
        ("Auto Linter Integration", test_auto_linter_integration),
        ("Auto Documentation Integration", test_auto_documentation_integration)
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"Running test: {test_name}")
        print("-" * 40)
        try:
            result = test_func()
            results.append((test_name, result))
            print(f"Result: {'PASS' if result else 'FAIL'}")
        except Exception as e:
            print(f"Error: {e}")
            results.append((test_name, False))
        print()
    
    # Summary
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "PASS" if result else "FAIL"
        print(f"{test_name}: {status}")
    
    print()
    print(f"Total: {passed}/{total} tests passed")
    
    if passed == total:
        print("âœ“ All tests passed!")
        return 0
    else:
        print("âœ— Some tests failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())

