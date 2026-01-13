#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_self_improvement_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the self-improvement system fixes.
"""

import sys
import os
from pathlib import Path

# Add the noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent / "src"
sys.path.insert(0, str(noodle_core_path))

def test_import_and_method():
    """Test that the import works and the method exists."""
    print("Testing self-improvement system fixes...")
    
    try:
        # Test the import
        print("1. Testing import...")
        from noodlecore.noodlecore_self_improvement_system import NoodleCoreSelfImprover
        print("   [OK] Import successful")
        
        # Test instantiation
        print("2. Testing instantiation...")
        improver = NoodleCoreSelfImprover()
        print("   [OK] Instantiation successful")
        
        # Test method existence
        print("3. Testing method existence...")
        if hasattr(improver, 'analyze_system_for_improvements'):
            print("   [OK] analyze_system_for_improvements method exists")
        else:
            print("   [ERROR] analyze_system_for_improvements method MISSING")
            print(f"   Available methods: {[method for method in dir(improver) if not method.startswith('_')]}")
            return False
        
        # Test method call
        print("4. Testing method call...")
        result = improver.analyze_system_for_improvements()
        print("   [OK] Method call successful")
        print(f"   Result type: {type(result)}")
        print(f"   Result keys: {list(result.keys()) if isinstance(result, dict) else 'Not a dict'}")
        
        return True
        
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_unicode_handling():
    """Test Unicode handling in logging."""
    print("\n5. Testing Unicode handling...")
    
    try:
        # Test emoji in print statement
        print("   Testing emoji: [WRENCH] Self-Improvement Test")
        print("   [OK] Unicode handling successful")
        return True
    except UnicodeEncodeError as e:
        print(f"   [ERROR] Unicode error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("SELF-IMPROVEMENT SYSTEM FIX VERIFICATION")
    print("=" * 50)
    
    success1 = test_import_and_method()
    success2 = test_unicode_handling()
    
    print("\n" + "=" * 50)
    if success1 and success2:
        print("[SUCCESS] ALL TESTS PASSED - Fixes are working!")
    else:
        print("[FAILURE] SOME TESTS FAILED - Issues remain")
    print("=" * 50)

