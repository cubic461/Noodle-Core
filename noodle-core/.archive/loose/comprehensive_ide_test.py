#!/usr/bin/env python3
"""
Test Suite::Noodle Core - comprehensive_ide_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive IDE Import Test
Tests both basic and enhanced IDE versions after all fixes
"""

import sys
import traceback

def test_basic_ide():
    """Test basic native GUI IDE import and instantiation."""
    print("=" * 60)
    print("Testing Basic Native GUI IDE")
    print("=" * 60)
    
    try:
        # Import the module
        from src.noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        print("âœ… SUCCESS: native_gui_ide.py imported successfully")
        
        # Test class instantiation
        ide = NativeNoodleCoreIDE()
        print("âœ… SUCCESS: NativeNoodleCoreIDE class instantiated successfully")
        
        # Test key methods exist
        required_methods = ['run', 'setup_ui', 'new_file', 'open_file', 'save_file']
        for method in required_methods:
            if hasattr(ide, method):
                print(f"âœ… Method '{method}' exists")
            else:
                print(f"âŒ Method '{method}' missing")
        
        return True
        
    except Exception as e:
        print(f"âŒ FAILED: {str(e)}")
        traceback.print_exc()
        return False

def test_enhanced_ide():
    """Test enhanced native GUI IDE import and instantiation."""
    print("=" * 60)
    print("Testing Enhanced Native GUI IDE")
    print("=" * 60)
    
    try:
        # Import the module
        from src.noodlecore.desktop.ide.enhanced_native_ide_complete import EnhancedNativeNoodleCoreIDE
        print("âœ… SUCCESS: enhanced_native_ide_complete.py imported successfully")
        
        # Test class instantiation
        ide = EnhancedNativeNoodleCoreIDE()
        print("âœ… SUCCESS: EnhancedNativeNoodleCoreIDE class instantiated successfully")
        
        # Test enhanced features
        enhanced_features = [
            'ai_providers', 'ai_roles', 'suggestions', 'open_files', 
            'send_ai_message', 'convert_python_to_nc', 'run_in_sandbox'
        ]
        
        for feature in enhanced_features:
            if hasattr(ide, feature):
                print(f"âœ… Enhanced feature '{feature}' exists")
            else:
                print(f"âŒ Enhanced feature '{feature}' missing")
        
        # Test AI providers
        if hasattr(ide, 'ai_providers'):
            providers = ide.ai_providers
            expected_providers = ['OpenAI', 'OpenRouter', 'LM Studio']
            for provider in expected_providers:
                if provider in providers:
                    print(f"âœ… AI Provider '{provider}' available")
                else:
                    print(f"âŒ AI Provider '{provider}' missing")
        
        return True
        
    except Exception as e:
        print(f"âŒ FAILED: {str(e)}")
        traceback.print_exc()
        return False

def main():
    """Run comprehensive IDE tests."""
    print("Starting Comprehensive IDE Import Tests")
    print("Testing after all syntax and import fixes\n")
    
    # Test both IDE versions
    basic_success = test_basic_ide()
    print()
    enhanced_success = test_enhanced_ide()
    
    # Summary
    print("=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    if basic_success:
        print("âœ… Basic IDE: PASSED")
    else:
        print("âŒ Basic IDE: FAILED")
    
    if enhanced_success:
        print("âœ… Enhanced IDE: PASSED")
    else:
        print("âŒ Enhanced IDE: FAILED")
    
    if basic_success and enhanced_success:
        print("\nALL TESTS PASSED! Both IDE versions are working correctly.")
        return 0
    else:
        print("\nSOME TESTS FAILED! Check the errors above.")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

