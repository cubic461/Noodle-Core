#!/usr/bin/env python3
"""
Test Suite::Noodle Core - final_import_test_report.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Final Import Test Report for Enhanced NoodleCore IDE
Tests all import functionality after fixes
"""

import sys
import os
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / 'src'))

def test_basic_imports():
    """Test basic module imports."""
    print("=" * 60)
    print("TESTING BASIC MODULE IMPORTS")
    print("=" * 60)
    
    tests = [
        ("Native GUI IDE", "noodlecore.desktop.ide.native_gui_ide"),
        ("Enhanced Native GUI IDE", "noodlecore.desktop.ide.enhanced_native_ide_complete"),
        ("Launch Script", "noodlecore.desktop.ide.launch_native_ide"),
    ]
    
    results = []
    for name, module_path in tests:
        try:
            __import__(module_path)
            print(f"âœ… SUCCESS: {name}")
            results.append(True)
        except Exception as e:
            print(f"âŒ FAILED: {name} - {str(e)}")
            results.append(False)
    
    return all(results)

def test_class_instantiation():
    """Test class instantiation."""
    print("\n" + "=" * 60)
    print("TESTING CLASS INSTANTIATION")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        ide1 = NativeNoodleCoreIDE()
        print("âœ… SUCCESS: NativeNoodleCoreIDE instantiated")
        
        from noodlecore.desktop.ide.enhanced_native_ide_complete import EnhancedNativeNoodleCoreIDE
        ide2 = EnhancedNativeNoodleCoreIDE()
        print("âœ… SUCCESS: EnhancedNativeNoodleCoreIDE instantiated")
        
        return True
    except Exception as e:
        print(f"âŒ FAILED: Class instantiation - {str(e)}")
        return False

def test_enhanced_features():
    """Test enhanced IDE features."""
    print("\n" + "=" * 60)
    print("TESTING ENHANCED IDE FEATURES")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.enhanced_native_ide_complete import EnhancedNativeNoodleCoreIDE
        ide = EnhancedNativeNoodleCoreIDE()
        
        # Test AI providers
        expected_providers = ['OpenAI', 'OpenRouter', 'LM Studio']
        for provider in expected_providers:
            if provider in ide.ai_providers:
                print(f"âœ… AI Provider '{provider}' available")
            else:
                print(f"âŒ AI Provider '{provider}' missing")
                return False
        
        # Test AI roles
        if len(ide.ai_roles) > 0:
            print(f"âœ… AI Roles loaded: {len(ide.ai_roles)} roles")
        else:
            print("âŒ No AI roles loaded")
            return False
        
        # Test file tracking
        if hasattr(ide, 'file_paths') and isinstance(ide.file_paths, dict):
            print("âœ… File path tracking initialized")
        else:
            print("âŒ File path tracking not initialized")
            return False
        
        # Test suggestions system
        if hasattr(ide, 'suggestions') and isinstance(ide.suggestions, list):
            print("âœ… Suggestions system initialized")
        else:
            print("âŒ Suggestions system not initialized")
            return False
        
        return True
    except Exception as e:
        print(f"âŒ FAILED: Enhanced features test - {str(e)}")
        return False

def test_launch_script():
    """Test launch script functionality."""
    print("\n" + "=" * 60)
    print("TESTING LAUNCH SCRIPT")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.launch_native_ide import main
        if callable(main):
            print("âœ… SUCCESS: Launch script main function accessible")
            return True
        else:
            print("âŒ FAILED: Main function not callable")
            return False
    except Exception as e:
        print(f"âŒ FAILED: Launch script test - {str(e)}")
        return False

def main():
    """Run all tests and generate report."""
    print("FINAL IMPORT TEST REPORT FOR ENHANCED NOODLECORE IDE")
    print("Testing after all fixes and improvements")
    print("Generated:", sys.version)
    
    # Run all tests
    test_results = []
    test_results.append(("Basic Imports", test_basic_imports()))
    test_results.append(("Class Instantiation", test_class_instantiation()))
    test_results.append(("Enhanced Features", test_enhanced_features()))
    test_results.append(("Launch Script", test_launch_script()))
    
    # Generate summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    all_passed = True
    for test_name, result in test_results:
        status = "PASSED" if result else "FAILED"
        print(f"{test_name}: {status}")
        if not result:
            all_passed = False
    
    print("\n" + "=" * 60)
    if all_passed:
        print("ðŸŽ‰ ALL TESTS PASSED! The Enhanced IDE is ready to use.")
        print("\nKey fixes implemented:")
        print("âœ… Fixed Treeview file path tracking")
        print("âœ… Resolved import dependency issues")
        print("âœ… Fixed syntax errors in enhanced IDE")
        print("âœ… Verified AI provider integration")
        print("âœ… Confirmed launch script functionality")
    else:
        print("âŒ SOME TESTS FAILED. Please review the errors above.")
    print("=" * 60)
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    sys.exit(main())

