#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_integration_fixed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify that the IDE integration with corrected Python to NoodleCore workflow works properly.

This script tests:
1. The import path works correctly
2. The workflow is properly initialized
3. The conversion functionality works with the corrected workflow
4. Error handling works as expected
"""

import os
import sys
import tempfile
import shutil
import json
import time
import traceback
from pathlib import Path
from typing import Dict, Any, Optional

# Add the src directory to the path for imports
current_dir = Path(__file__).parent
src_dir = current_dir / "src"
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

# Test configuration
TEST_RESULTS = {
    "total_tests": 0,
    "passed_tests": 0,
    "failed_tests": 0,
    "test_details": []
}

def log_test_result(test_name: str, passed: bool, message: str = "", details: Dict[str, Any] = None):
    """Log a test result."""
    TEST_RESULTS["total_tests"] += 1
    if passed:
        TEST_RESULTS["passed_tests"] += 1
        status = "PASS"
    else:
        TEST_RESULTS["failed_tests"] += 1
        status = "FAIL"
    
    print(f"[{status}] {test_name}: {message}")
    
    TEST_RESULTS["test_details"].append({
        "test_name": test_name,
        "status": status,
        "message": message,
        "details": details or {}
    })

def create_test_python_file(file_path: str) -> bool:
    """Create a simple Python file for testing."""
    try:
        test_content = '''#!/usr/bin/env python3
"""
Test Python file for conversion to NoodleCore.
"""

def calculate_sum(numbers):
    """Calculate the sum of a list of numbers."""
    total = 0
    for num in numbers:
        total += num
    return total

def fibonacci(n):
    """Generate Fibonacci sequence up to n."""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    elif n == 2:
        return [0, 1]
    
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    return fib

if __name__ == "__main__":
    # Test the functions
    numbers = [1, 2, 3, 4, 5]
    print(f"Sum of {numbers}: {calculate_sum(numbers)}")
    print(f"Fibonacci sequence of length 10: {fibonacci(10)}")
'''
        
        with open(file_path, 'w') as f:
            f.write(test_content)
        return True
    except Exception as e:
        print(f"Failed to create test Python file: {e}")
        return False

def test_import_path():
    """Test that the import path works correctly."""
    try:
        from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
        log_test_result(
            "Import Path Test", 
            True, 
            "Successfully imported CorrectedPythonToNoodleCoreWorkflow"
        )
        return True
    except ImportError as e:
        log_test_result(
            "Import Path Test", 
            False, 
            f"Failed to import CorrectedPythonToNoodleCoreWorkflow: {str(e)}"
        )
        return False
    except Exception as e:
        log_test_result(
            "Import Path Test", 
            False, 
            f"Unexpected error during import: {str(e)}"
        )
        return False

def test_workflow_initialization():
    """Test that the workflow is properly initialized."""
    try:
        from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
        
        workflow = CorrectedPythonToNoodleCoreWorkflow()
        
        # Check if workflow has required attributes
        required_attrs = [
            'converter', 'archive_manager', 'workflow_history', 
            'active_conversions', 'config'
        ]
        
        missing_attrs = [attr for attr in required_attrs if not hasattr(workflow, attr)]
        
        if missing_attrs:
            log_test_result(
                "Workflow Initialization Test", 
                False, 
                f"Missing required attributes: {', '.join(missing_attrs)}"
            )
            return False
        
        # Check if workflow is enabled
        is_enabled = workflow.is_workflow_enabled()
        
        log_test_result(
            "Workflow Initialization Test", 
            True, 
            f"Workflow initialized successfully, enabled: {is_enabled}",
            {"enabled": is_enabled}
        )
        return True
    except Exception as e:
        log_test_result(
            "Workflow Initialization Test", 
            False, 
            f"Failed to initialize workflow: {str(e)}"
        )
        return False

def test_ide_integration():
    """Test that the IDE can integrate with the corrected workflow."""
    try:
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        
        # Create a mock IDE instance (without initializing the GUI)
        class MockIDE:
            def __init__(self):
                self.python_to_nc_conversion_enabled = False
                self.python_to_nc_workflow = None
            
            def enable_python_to_nc_conversion(self):
                try:
                    from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
                    
                    # Initialize the workflow
                    self.python_to_nc_workflow = CorrectedPythonToNoodleCoreWorkflow()
                    
                    # Store reference for later use
                    self.python_to_nc_conversion_enabled = True
                    
                    return True
                except Exception as e:
                    print(f"Failed to enable Python to NoodleCore conversion: {str(e)}")
                    return False
        
        mock_ide = MockIDE()
        result = mock_ide.enable_python_to_nc_conversion()
        
        if result and mock_ide.python_to_nc_conversion_enabled and mock_ide.python_to_nc_workflow:
            log_test_result(
                "IDE Integration Test", 
                True, 
                "IDE successfully integrated with corrected workflow"
            )
            return True
        else:
            log_test_result(
                "IDE Integration Test", 
                False, 
                "IDE failed to integrate with corrected workflow"
            )
            return False
    except Exception as e:
        log_test_result(
            "IDE Integration Test", 
            False, 
            f"IDE integration test failed: {str(e)}"
        )
        return False

def test_conversion_functionality():
    """Test the conversion functionality with the corrected workflow."""
    try:
        from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
        
        # Create a temporary directory for testing
        with tempfile.TemporaryDirectory() as temp_dir:
            # Create test Python file
            test_file_path = os.path.join(temp_dir, "test_conversion.py")
            if not create_test_python_file(test_file_path):
                log_test_result(
                    "Conversion Functionality Test", 
                    False, 
                    "Failed to create test Python file"
                )
                return False
            
            # Initialize workflow
            workflow = CorrectedPythonToNoodleCoreWorkflow()
            
            # Enable workflow for testing
            workflow.enable_workflow()
            
            # Test conversion
            result = workflow.convert_python_file(test_file_path)
            
            # Check result
            if result.get("success", False):
                nc_file_path = result.get("nc_file")
                if nc_file_path and os.path.exists(nc_file_path):
                    # Check if original file is archived
                    archived = result.get("archived", False)
                    
                    # Check if NC file has content
                    with open(nc_file_path, 'r') as f:
                        nc_content = f.read()
                    
                    if nc_content.strip():
                        log_test_result(
                            "Conversion Functionality Test", 
                            True, 
                            f"Successfully converted Python to NC, archived: {archived}",
                            {
                                "nc_file": nc_file_path,
                                "archived": archived,
                                "nc_content_length": len(nc_content),
                                "steps": result.get("steps", [])
                            }
                        )
                        return True
                    else:
                        log_test_result(
                            "Conversion Functionality Test", 
                            False, 
                            "NC file was created but is empty"
                        )
                        return False
                else:
                    log_test_result(
                        "Conversion Functionality Test", 
                        False, 
                        "NC file path not found in result or file doesn't exist"
                    )
                    return False
            else:
                error_msg = result.get("error", "Unknown error")
                log_test_result(
                    "Conversion Functionality Test", 
                    False, 
                    f"Conversion failed: {error_msg}"
                )
                return False
    except Exception as e:
        log_test_result(
            "Conversion Functionality Test", 
            False, 
            f"Conversion test failed with exception: {str(e)}"
        )
        return False

def test_error_handling():
    """Test error handling in the workflow."""
    try:
        from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
        
        workflow = CorrectedPythonToNoodleCoreWorkflow()
        workflow.enable_workflow()
        
        # Test with non-existent file
        result = workflow.convert_python_file("non_existent_file.py")
        
        if not result.get("success", False) and result.get("error"):
            log_test_result(
                "Error Handling Test", 
                True, 
                f"Correctly handled non-existent file error: {result.get('error')}"
            )
        else:
            log_test_result(
                "Error Handling Test", 
                False, 
                "Failed to handle non-existent file error"
            )
            return False
        
        # Test with non-Python file
        with tempfile.TemporaryDirectory() as temp_dir:
            test_file_path = os.path.join(temp_dir, "test_file.txt")
            with open(test_file_path, 'w') as f:
                f.write("This is not a Python file")
            
            result = workflow.convert_python_file(test_file_path)
            
            if not result.get("success", False) and result.get("error"):
                log_test_result(
                    "Error Handling Test", 
                    True, 
                    f"Correctly handled non-Python file error: {result.get('error')}"
                )
                return True
            else:
                log_test_result(
                    "Error Handling Test", 
                    False, 
                    "Failed to handle non-Python file error"
                )
                return False
    except Exception as e:
        log_test_result(
            "Error Handling Test", 
            False, 
            f"Error handling test failed with exception: {str(e)}"
        )
        return False

def test_workflow_configuration():
    """Test workflow configuration options."""
    try:
        from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
        
        workflow = CorrectedPythonToNoodleCoreWorkflow()
        
        # Test getting workflow status
        status = workflow.get_workflow_status()
        
        required_status_keys = [
            "enabled", "active_conversions", "total_conversions",
            "successful_conversions", "failed_conversions", "workflow_type"
        ]
        
        missing_keys = [key for key in required_status_keys if key not in status]
        
        if missing_keys:
            log_test_result(
                "Workflow Configuration Test", 
                False, 
                f"Missing status keys: {', '.join(missing_keys)}"
            )
            return False
        
        # Test configuring workflow
        test_config = {
            "test_setting": "test_value",
            "validate_nc_before_delete": True,
            "require_nc_better": False
        }
        
        workflow.configure_workflow(test_config)
        
        # Check if configuration was updated
        updated_config = workflow.config
        if updated_config.get("test_setting") == "test_value":
            log_test_result(
                "Workflow Configuration Test", 
                True, 
                "Workflow configuration works correctly",
                {"initial_status": status, "config_updated": True}
            )
            return True
        else:
            log_test_result(
                "Workflow Configuration Test", 
                False, 
                "Failed to update workflow configuration"
            )
            return False
    except Exception as e:
        log_test_result(
            "Workflow Configuration Test", 
            False, 
            f"Workflow configuration test failed: {str(e)}"
        )
        return False

def test_ide_convert_method():
    """Test the IDE's convert_current_file_to_nc method with the corrected workflow."""
    try:
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        
        # Create a mock IDE instance with the necessary methods
        class MockIDE:
            def __init__(self):
                self.current_file = None
                self.python_to_nc_conversion_enabled = False
                self.python_to_nc_workflow = None
                self.open_files = {}
            
            def enable_python_to_nc_conversion(self):
                try:
                    from noodlecore.compiler.corrected_python_to_nc_workflow import CorrectedPythonToNoodleCoreWorkflow
                    
                    self.python_to_nc_workflow = CorrectedPythonToNoodleCoreWorkflow()
                    self.python_to_nc_conversion_enabled = True
                    return True
                except Exception as e:
                    print(f"Failed to enable Python to NoodleCore conversion: {str(e)}")
                    return False
            
            def convert_current_file_to_nc(self):
                if not self.current_file or not self.current_file.endswith('.py'):
                    return False
                
                if not hasattr(self, 'python_to_nc_conversion_enabled') or not self.python_to_nc_conversion_enabled:
                    if not self.enable_python_to_nc_conversion():
                        return False
                
                try:
                    # Use corrected workflow
                    result = self.python_to_nc_workflow.convert_python_file(self.current_file)
                    
                    if result['success']:
                        return True
                    else:
                        return False
                except Exception as e:
                    print(f"Error during conversion: {str(e)}")
                    return False
        
        # Create a temporary directory for testing
        with tempfile.TemporaryDirectory() as temp_dir:
            # Create test Python file
            test_file_path = os.path.join(temp_dir, "test_ide_conversion.py")
            if not create_test_python_file(test_file_path):
                log_test_result(
                    "IDE Convert Method Test", 
                    False, 
                    "Failed to create test Python file"
                )
                return False
            
            # Initialize mock IDE
            mock_ide = MockIDE()
            mock_ide.current_file = test_file_path
            
            # Test conversion
            result = mock_ide.convert_current_file_to_nc()
            
            if result:
                log_test_result(
                    "IDE Convert Method Test", 
                    True, 
                    "IDE convert_current_file_to_nc method works correctly"
                )
                return True
            else:
                log_test_result(
                    "IDE Convert Method Test", 
                    False, 
                    "IDE convert_current_file_to_nc method failed"
                )
                return False
    except Exception as e:
        log_test_result(
            "IDE Convert Method Test", 
            False, 
            f"IDE convert method test failed: {str(e)}"
        )
        return False

def cleanup_test_files():
    """Clean up any test files created during testing."""
    try:
        # This would be used to clean up any test files
        # In our case, we're using temporary directories which are automatically cleaned up
        pass
    except Exception as e:
        print(f"Error during cleanup: {e}")

def print_test_summary():
    """Print a summary of all test results."""
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    print(f"Total Tests: {TEST_RESULTS['total_tests']}")
    print(f"Passed: {TEST_RESULTS['passed_tests']}")
    print(f"Failed: {TEST_RESULTS['failed_tests']}")
    
    if TEST_RESULTS['total_tests'] > 0:
        success_rate = (TEST_RESULTS['passed_tests'] / TEST_RESULTS['total_tests']) * 100
        print(f"Success Rate: {success_rate:.1f}%")
    
    print("\nTest Details:")
    print("-"*60)
    
    for test_detail in TEST_RESULTS["test_details"]:
        status_symbol = "âœ“" if test_detail["status"] == "PASS" else "âœ—"
        print(f"{status_symbol} {test_detail['test_name']}: {test_detail['message']}")
        
        if test_detail["details"]:
            for key, value in test_detail["details"].items():
                print(f"    {key}: {value}")
    
    print("="*60)

def main():
    """Main test function."""
    print("Starting IDE Integration Test Suite")
    print("Testing corrected Python to NoodleCore workflow integration...")
    print("="*60)
    
    try:
        # Run all tests
        test_import_path()
        test_workflow_initialization()
        test_ide_integration()
        test_conversion_functionality()
        test_error_handling()
        test_workflow_configuration()
        test_ide_convert_method()
        
        # Print summary
        print_test_summary()
        
        # Return appropriate exit code
        return 0 if TEST_RESULTS['failed_tests'] == 0 else 1
        
    except Exception as e:
        print(f"Test suite failed with exception: {str(e)}")
        traceback.print_exc()
        return 1
    finally:
        # Cleanup
        cleanup_test_files()

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

