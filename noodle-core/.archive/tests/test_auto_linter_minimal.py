#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_auto_linter_minimal.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Minimal Test script for Auto Linter and Documentation Integration

This script tests if the integration class can be imported
without actually running the integration.
"""

import sys
from pathlib import Path

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent / "src"))

def test_import():
    """Test if the auto linter integration can be imported."""
    print("Testing Auto Linter Integration Import...")
    
    try:
        from noodlecore.desktop.ide.auto_linter_documentation_integration import AutoLinterDocumentationIntegration
        print("PASS: AutoLinterDocumentationIntegration class imported successfully")
        return True
        
    except ImportError as e:
        print(f"FAIL: Error importing AutoLinterDocumentationIntegration: {e}")
        return False

def main():
    """Main test function."""
    print("=" * 60)
    print("Auto Linter Integration Import Test")
    print("=" * 60)
    
    # Run test
    result = test_import()
    
    # Summary
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    if result:
        print("PASS: Import test passed")
        return 0
    else:
        print("FAIL: Import test failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())

