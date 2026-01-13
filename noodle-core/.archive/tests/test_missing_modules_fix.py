#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_missing_modules_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the missing module fixes.

This script tests the import of both missing modules and validates our fixes.
"""

import sys
import os
from pathlib import Path

def test_noodlecore_self_improvement_system_v2():
    """Test importing noodlecore_self_improvement_system_v2 module."""
    print("Testing noodlecore_self_improvement_system_v2 import...")
    
    try:
        # Add noodle-core to path
        noodle_core_path = Path(__file__).parent
        if str(noodle_core_path) not in sys.path:
            sys.path.insert(0, str(noodle_core_path))
        
        # Try importing with full path
        from src.noodlecore.noodlecore_self_improvement_system_v2 import NoodleCoreSelfImproverV2
        print("âœ“ Successfully imported NoodleCoreSelfImproverV2")
        
        # Try creating an instance
        improver = NoodleCoreSelfImproverV2()
        print("âœ“ Successfully created NoodleCoreSelfImproverV2 instance")
        
        # Check if analyze_system_for_improvements method exists
        if hasattr(improver, 'analyze_system_for_improvements'):
            print("âœ“ analyze_system_for_improvements method exists")
        else:
            print("âœ— analyze_system_for_improvements method missing")
        
        return True
        
    except ImportError as e:
        print(f"âœ— Failed to import noodlecore_self_improvement_system_v2: {e}")
        return False
    except Exception as e:
        print(f"âœ— Error testing noodlecore_self_improvement_system_v2: {e}")
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
        print("âœ“ Successfully imported noodle_lang")
        
        # Check version
        version = getattr(noodle_lang, '__version__', 'unknown')
        print(f"âœ“ noodle_lang version: {version}")
        
        # Test specific imports
        from noodle_lang.lexer import NoodleLexer
        print("âœ“ Successfully imported NoodleLexer")
        
        from noodle_lang.parser import NoodleParser
        print("âœ“ Successfully imported NoodleParser")
        
        from noodle_lang.compiler import NoodleCompiler
        print("âœ“ Successfully imported NoodleCompiler")
        
        return True
        
    except ImportError as e:
        print(f"âœ— Failed to import noodle_lang: {e}")
        return False
    except Exception as e:
        print(f"âœ— Error testing noodle_lang: {e}")
        return False

def test_self_improvement_integration():
    """Test importing the self-improvement integration module."""
    print("\nTesting self_improvement_integration import...")
    
    try:
        # Add noodle-core to path
        noodle_core_path = Path(__file__).parent
        if str(noodle_core_path) not in sys.path:
            sys.path.insert(0, str(noodle_core_path))
        
        # Try importing the integration module
        from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        print("âœ“ Successfully imported SelfImprovementIntegration")
        
        # Try creating an instance
        integration = SelfImprovementIntegration()
        print("âœ“ Successfully created SelfImprovementIntegration instance")
        
        return True
        
    except ImportError as e:
        print(f"âœ— Failed to import self_improvement_integration: {e}")
        return False
    except Exception as e:
        print(f"âœ— Error testing self_improvement_integration: {e}")
        return False

def main():
    """Run all tests."""
    print("=" * 60)
    print("MISSING MODULES FIX VERIFICATION")
    print("=" * 60)
    
    # Test results
    results = []
    
    # Test noodlecore_self_improvement_system_v2
    results.append(test_noodlecore_self_improvement_system_v2())
    
    # Test noodle_lang
    results.append(test_noodle_lang_import())
    
    # Test self_improvement_integration
    results.append(test_self_improvement_integration())
    
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

