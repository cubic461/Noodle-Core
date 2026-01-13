#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_import_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify that the complete IDE can be imported successfully after fixes.
"""

import sys
import traceback
from pathlib import Path

# Add the noodle-core source directory to Python path
noodle_core_src = Path(__file__).parent / "src"
sys.path.insert(0, str(noodle_core_src))

def test_import(module_name, description):
    """Test importing a module and report results"""
    print(f"\n{'='*60}")
    print(f"Testing: {description}")
    print(f"Module: {module_name}")
    print('='*60)
    
    try:
        exec(f"import {module_name}")
        print(f"âœ… SUCCESS: {module_name} imported successfully")
        return True
    except ImportError as e:
        print(f"X IMPORT ERROR: {e}")
        traceback.print_exc()
        return False
    except Exception as e:
        print(f"X ERROR: {e}")
        traceback.print_exc()
        return False

def main():
    """Main test function"""
    print("NoodleCore IDE Import Test")
    print("Testing import fixes for AST nodes and complete IDE")
    
    # Test basic AST node imports
    tests = [
        ("noodlecore.compiler.ast_nodes", "AST Nodes Module"),
        ("noodlecore.compiler.enhanced_parser", "Enhanced Parser"),
        ("noodlecore.compiler.accelerated_lexer", "Accelerated Lexer"),
        ("noodlecore.compiler.bytecode_generator", "Bytecode Generator"),
        ("noodlecore.desktop.ide.native_gui_ide", "Native GUI IDE"),
        ("noodlecore.desktop.ide.enhanced_native_ide_complete", "Enhanced Native IDE Complete"),
    ]
    
    results = []
    for module_name, description in tests:
        success = test_import(module_name, description)
        results.append((module_name, description, success))
    
    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print('='*60)
    
    passed = sum(1 for _, _, success in results if success)
    total = len(results)
    
    for module_name, description, success in results:
        status = "PASS" if success else "FAIL"
        print(f"{status}: {description} ({module_name})")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("All imports successful! The IDE should now launch properly.")
        return 0
    else:
        print("Some imports failed. Further fixes may be needed.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

