#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_missing_modules_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test script to verify the missing module fixes.

This script tests the import of both missing modules directly.
"""

import sys
import os
from pathlib import Path

def test_noodlecore_self_improvement_system_v2():
    """Test importing noodlecore_self_improvement_system_v2 module."""
    print("Testing noodlecore_self_improvement_system_v2 import...")
    
    try:
        # Add noodle-core/src/noodlecore to path
        noodle_core_path = Path(__file__).parent / "src" / "noodlecore"
        if str(noodle_core_path) not in sys.path:
            sys.path.insert(0, str(noodle_core_path))
        
        # Try importing the module directly
        import noodlecore_self_improvement_system_v2
        print("Successfully imported noodlecore_self_improvement_system_v2")
        
        # Check if NoodleCoreSelfImproverV2 class exists
        if hasattr(noodlecore_self_improvement_system_v2, 'NoodleCoreSelfImproverV2'):
            print("NoodleCoreSelfImproverV2 class found")
        else:
            print("NoodleCoreSelfImproverV2 class not found")
        
        return True
        
    except ImportError as e:
        print(f"Failed to import noodlecore_self_improvement_system_v2: {e}")
        return False
    except Exception as e:
        print(f"Error testing noodlecore_self_improvement_system_v2: {e}")
        return False

def test_noodle_lang_import():
    """Test importing noodle_lang module."""
    print("\nTesting noodle_lang import...")
    
    try:
        # Add noodle-lang/src to path
        noodle_lang_path = Path(__file__).parent.parent / "noodle-lang" / "src"
        if str(noodle_lang_path) not in sys.path:
            sys.path.insert(0, str(noodle_lang_path))
        
        # Try importing noodle_lang
        import noodle_lang
        print("Successfully imported noodle_lang")
        
        # Check version
        version = getattr(noodle_lang, '__version__', 'unknown')
        print(f"noodle_lang version: {version}")
        
        # Test specific imports
        from noodle_lang.lexer import NoodleLexer
        print("Successfully imported NoodleLexer")
        
        from noodle_lang.parser import NoodleParser
        print("Successfully imported NoodleParser")
        
        from noodle_lang.compiler import NoodleCompiler
        print("Successfully imported NoodleCompiler")
        
        return True
        
    except ImportError as e:
        print(f"Failed to import noodle_lang: {e}")
        return False
    except Exception as e:
        print(f"Error testing noodle_lang: {e}")
        return False

def main():
    """Run all tests."""
    print("=" * 60)
    print("MISSING MODULES FIX VERIFICATION (SIMPLE)")
    print("=" * 60)
    
    # Test results
    results = []
    
    # Test noodlecore_self_improvement_system_v2
    results.append(test_noodlecore_self_improvement_system_v2())
    
    # Test noodle_lang
    results.append(test_noodle_lang_import())
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    passed = sum(results)
    total = len(results)
    
    print(f"Tests passed: {passed}/{total}")
    
    if passed == total:
        print("All tests passed! The missing module issues have been resolved.")
        return 0
    else:
        print("Some tests failed. The missing module issues may not be fully resolved.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

