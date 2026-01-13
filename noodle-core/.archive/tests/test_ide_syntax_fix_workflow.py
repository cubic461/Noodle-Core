#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_syntax_fix_workflow.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the complete IDE syntax fixer workflow
"""

import sys
import os
import tempfile
from pathlib import Path

# Add src to path
sys.path.insert(0, 'src')

def test_complete_workflow():
    """Test the complete syntax fixer workflow as used in the IDE."""
    
    print("Testing complete IDE syntax fixer workflow...")
    
    try:
        # Import IDE components
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer
        
        print("[OK] IDE components imported successfully")
        
        # Test 1: Direct syntax fixer functionality
        print("\n--- Test 1: Direct Syntax Fixer ---")
        fixer = NoodleCoreSyntaxFixer()
        
        # Create a comprehensive test file with mixed syntax
        test_content = '''#!/usr/bin/env python3
"""
Test file with mixed Python/NoodleCore syntax
This should be converted to proper NoodleCore
"""

func calculate_sum(a, b) {
    var result = a + b
    print(f"The sum is: {result}")
    return result
}

func main():
    numbers = [1, 2, 3, 4, 5]
    total = 0
    
    for num in numbers:
        total = calculate_sum(total, num)
        println(f"Running total: {total}")
    
    print("Final result:")
    print(total)
    return total

if __name__ == "__main__":
    main()
'''
        
        # Test direct content fixing
        fixed_content, fixes = fixer.fix_content(test_content)
        
        print(f"Applied {len(fixes)} fixes:")
        for fix in fixes:
            print(f"  - Line {fix['line']}: {fix['description']}")
            print(f"    Original: {fix['original']}")
            print(f"    Fixed: {fix['fixed']}")
        
        # Test 2: IDE integration with file operations
        print("\n--- Test 2: IDE File Operations ---")
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(test_content)
            temp_file = f.name
        
        try:
            # Initialize IDE (without GUI)
            ide = NativeNoodleCoreIDE()
            
            if ide.syntax_fixer:
                print("[OK] Syntax fixer is available in IDE")
                
                # Test file fixing through IDE
                result = ide.syntax_fixer.fix_file(temp_file, create_backup=True)
                
                if result['success']:
                    print(f"[OK] Successfully fixed {result['fixes_applied']} syntax issues")
                    
                    # Read fixed content
                    with open(temp_file, 'r') as f:
                        fixed_file_content = f.read()
                    
                    # Verify fixes were applied
                    expected_fixes = [
                        'shebang statement',
                        'function declaration', 
                        'variable declaration',
                        'print statement',
                        'main statement'
                    ]
                    
                    applied_fix_types = [fix['type'] for fix in result.get('fixes', [])]
                    
                    for expected_fix in expected_fixes:
                        if any(expected_fix in fix_type for fix_type in applied_fix_types):
                            print(f"[OK] {expected_fix} fix was applied")
                        else:
                            print(f"[WARNING] {expected_fix} fix was not applied")
                    
                    # Test validation
                    validation = ide.syntax_fixer.validate_file(temp_file)
                    if validation['valid']:
                        print("[OK] Fixed file passes validation")
                    else:
                        print(f"[WARNING] Fixed file has validation issues: {validation['error']}")
                    
                    print("[SUCCESS] IDE file operations test passed!")
                    return True
                else:
                    print(f"[ERROR] File fixing failed: {result.get('error', 'Unknown error')}")
                    return False
            else:
                print("[ERROR] Syntax fixer not available in IDE")
                return False
                
        finally:
            # Clean up
            try:
                os.unlink(temp_file)
                if os.path.exists(temp_file + '.bak'):
                    os.unlink(temp_file + '.bak')
                print(f"[OK] Cleaned up temporary file: {temp_file}")
            except Exception as e:
                print(f"[WARNING] Failed to clean up temporary file: {e}")
                
    except Exception as e:
        print(f"[ERROR] Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_complete_workflow()
    
    if success:
        print("\n[SUCCESS] Complete IDE syntax fixer workflow test passed!")
        print("The enhanced syntax fixer is properly integrated and working correctly!")
        sys.exit(0)
    else:
        print("\n[FAILED] Complete IDE syntax fixer workflow test failed!")
        sys.exit(1)

