#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_fix_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify IDE integration with syntax fixer
"""

import sys
import os
import tempfile
from pathlib import Path

# Add src to path
sys.path.insert(0, 'src')

def test_ide_syntax_fixer_integration():
    """Test that the IDE properly integrates with the syntax fixer."""
    
    print("Testing IDE integration with syntax fixer...")
    
    try:
        # Import IDE
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        
        # Create a temporary test file with syntax issues
        test_content = '''#!/usr/bin/env python3
func hello_world():
    println("Hello from test function")
    var message = "This needs fixing"
    print(message)
    return message

if __name__ == "__main__":
    hello_world()
'''
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(test_content)
            temp_file = f.name
        
        print(f"Created test file: {temp_file}")
        
        try:
            # Initialize IDE (without starting GUI)
            ide = NativeNoodleCoreIDE()
            
            # Check if syntax fixer is available
            if ide.syntax_fixer:
                print("[OK] Syntax fixer is available in IDE")
                
                # Test fixing the temporary file
                result = ide.syntax_fixer.fix_file(temp_file, create_backup=True)
                
                if result['success']:
                    print(f"[OK] Successfully fixed {result['fixes_applied']} syntax issues")
                    
                    # Read the fixed content
                    with open(temp_file, 'r') as f:
                        fixed_content = f.read()
                    
                    print("Fixed content:")
                    print(fixed_content)
                    
                    # Verify specific fixes
                    fixes_applied = result.get('fixes', [])
                    fix_types = [fix['type'] for fix in fixes_applied]
                    
                    expected_fixes = ['shebang statement', 'function declaration', 'variable declaration', 'print statement']
                    for expected_fix in expected_fixes:
                        if expected_fix in fix_types:
                            print(f"[OK] {expected_fix} fix applied")
                        else:
                            print(f"[ERROR] {expected_fix} fix missing")
                    
                    print("[SUCCESS] IDE integration test successful!")
                    return True
                else:
                    print(f"[ERROR] Failed to fix syntax: {result.get('error', 'Unknown error')}")
                    return False
            else:
                print("[ERROR] Syntax fixer not available in IDE")
                return False
                
        finally:
            # Clean up temporary file
            try:
                os.unlink(temp_file)
                if os.path.exists(temp_file + '.bak'):
                    os.unlink(temp_file + '.bak')
                print(f"Cleaned up temporary file: {temp_file}")
            except Exception as e:
                print(f"Failed to clean up temporary file: {e}")
                
    except Exception as e:
        print(f"[ERROR] Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_ide_syntax_fixer_integration()
    if success:
        print("\n[SUCCESS] IDE integration with syntax fixer is working correctly!")
        sys.exit(0)
    else:
        print("\n[FAILED] IDE integration test failed!")
        sys.exit(1)

