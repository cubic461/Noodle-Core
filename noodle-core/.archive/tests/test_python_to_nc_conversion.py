#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_python_to_nc_conversion.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for Python to NoodleCore conversion functionality.
This script tests both the advanced converter and the integration with self-improvement system.
"""

import sys
import os
from pathlib import Path

# Add noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

def test_advanced_converter():
    """Test the advanced Python to NoodleCore converter."""
    print("Testing Advanced Python to NoodleCore Converter...")
    print("=" * 60)
    
    try:
        from src.noodlecore.compiler.python_to_nc_converter import PythonToNoodleCoreConverter
        
        # Initialize converter
        converter = PythonToNoodleCoreConverter()
        
        # Test file path
        test_file = "test_python_conversion.py"
        
        if not os.path.exists(test_file):
            print(f"Error: Test file {test_file} not found")
            return False
        
        # Convert file
        print(f"Converting {test_file} to NoodleCore format...")
        nc_file = converter.convert_file(test_file)
        
        if nc_file:
            print(f"âœ“ Successfully converted to {nc_file}")
            
            # Read and display first few lines of converted file
            try:
                with open(nc_file, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    print("\nFirst 20 lines of converted file:")
                    print("-" * 40)
                    for i, line in enumerate(lines[:20], 1):
                        print(f"{i:2d}: {line.rstrip()}")
                    if len(lines) > 20:
                        print(f"... and {len(lines) - 20} more lines")
            except Exception as e:
                print(f"Error reading converted file: {e}")
            
            return True
        else:
            print("âœ— Conversion failed")
            return False
            
    except Exception as e:
        print(f"Error testing advanced converter: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_self_improvement_integration():
    """Test the self-improvement integration with Python conversion."""
    print("\n\nTesting Self-Improvement Integration...")
    print("=" * 60)
    
    try:
        from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Initialize self-improvement integration
        si_integration = SelfImprovementIntegration()
        
        # Create a test improvement
        test_improvement = {
            'type': 'python_conversion',
            'description': 'Test Python conversion',
            'priority': 'medium',
            'source': 'test_script',
            'file': 'test_python_conversion.py',
            'suggestion': 'Convert this Python file to NoodleCore',
            'action': 'convert_to_nc'
        }
        
        print("Testing Python conversion improvement...")
        print(f"Improvement: {test_improvement}")
        
        # Enable Python conversion in config
        si_integration.config['enable_python_conversion'] = True
        
        # Apply improvement
        success = si_integration._apply_python_conversion_improvement(test_improvement)
        
        if success:
            print("âœ“ Python conversion improvement applied successfully")
            
            # Check if .nc file was created
            nc_file = 'test_python_conversion.nc'
            if os.path.exists(nc_file):
                print(f"âœ“ NoodleCore file created: {nc_file}")
                
                # Display first few lines
                try:
                    with open(nc_file, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                        print("\nFirst 15 lines of converted file:")
                        print("-" * 40)
                        for i, line in enumerate(lines[:15], 1):
                            print(f"{i:2d}: {line.rstrip()}")
                except Exception as e:
                    print(f"Error reading converted file: {e}")
            else:
                print("âœ— NoodleCore file was not created")
                return False
        else:
            print("âœ— Python conversion improvement failed")
            return False
        
        # Test with disabled Python conversion
        print("\nTesting with Python conversion disabled...")
        si_integration.config['enable_python_conversion'] = False
        success_disabled = si_integration._apply_python_conversion_improvement(test_improvement)
        
        if not success_disabled:
            print("âœ“ Correctly rejected conversion when disabled")
        else:
            print("âœ— Should have rejected conversion when disabled")
            return False
        
        return True
        
    except Exception as e:
        print(f"Error testing self-improvement integration: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_environment_variable():
    """Test environment variable setting."""
    print("\n\nTesting Environment Variable Integration...")
    print("=" * 60)
    
    # Set environment variable
    os.environ["NOODLE_ENABLE_PYTHON_CONVERSION"] = "true"
    print("Set NOODLE_ENABLE_PYTHON_CONVERSION=true")
    
    try:
        from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create new instance to test config loading
        si_integration = SelfImprovementIntegration()
        
        # Check if environment variable was loaded
        if si_integration.config.get('enable_python_conversion', False):
            print("âœ“ Environment variable correctly loaded into config")
            return True
        else:
            print("âœ— Environment variable not loaded into config")
            return False
            
    except Exception as e:
        print(f"Error testing environment variable: {e}")
        return False

def cleanup():
    """Clean up test files."""
    print("\n\nCleaning up test files...")
    test_files = [
        'test_python_conversion.nc',
        'test_python_conversion_simple.nc'
    ]
    
    for file in test_files:
        if os.path.exists(file):
            try:
                os.remove(file)
                print(f"Removed {file}")
            except Exception as e:
                print(f"Error removing {file}: {e}")

def main():
    """Run all tests."""
    print("Python to NoodleCore Conversion Test Suite")
    print("=" * 60)
    
    # Run tests
    results = []
    results.append(("Advanced Converter", test_advanced_converter()))
    results.append(("Self-Improvement Integration", test_self_improvement_integration()))
    results.append(("Environment Variable", test_environment_variable()))
    
    # Summary
    print("\n\nTest Results Summary")
    print("=" * 60)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results:
        status = "PASS" if result else "FAIL"
        print(f"{test_name}: {status}")
        if result:
            passed += 1
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("ðŸŽ‰ All tests passed!")
        return 0
    else:
        print("âŒ Some tests failed")
        return 1

if __name__ == "__main__":
    try:
        exit_code = main()
        cleanup()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        cleanup()
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        cleanup()
        sys.exit(1)

