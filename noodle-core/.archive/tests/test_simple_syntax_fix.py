#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_syntax_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test script for syntax fixer
"""

import sys
import os
sys.path.insert(0, 'src')
from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer

# Create a test file with mixed syntax issues
test_content = """#!/usr/bin/env python3
func test_func():
    println("Hello World")

if __name__ == "__main__":
    test_func()
"""

# Write test file
test_file = 'test_simple_syntax_fix.nc'
with open(test_file, 'w') as f:
    f.write(test_content)

# Test the fixer
fixer = NoodleCoreSyntaxFixer()
print("Testing syntax fixer...")
print("=" * 50)

# Show original content
print("ORIGINAL CONTENT:")
print(test_content)
print("=" * 50)

# Validate first
validation = fixer.validate_file(test_file)
print("VALIDATION RESULTS:")
print(f"  Valid: {validation['valid']}")
if not validation['valid']:
    print(f"  Errors found: {validation['error_count']}")
    for error in validation['errors']:
        print(f"    - {error}")
print("=" * 50)

# Fix the file
fix_result = fixer.fix_file(test_file, create_backup=True)
print("FIX RESULTS:")
print(f"  Success: {fix_result['success']}")
print(f"  Fixes applied: {fix_result['fixes_applied']}")

if fix_result['fixes_applied'] > 0:
    print("  Detailed fixes:")
    for fix in fix_result['fixes']:
        print(f"    Line {fix['line']}: {fix['description']}")
        print(f"      Original: {fix['original']}")
        print(f"      Fixed: {fix['fixed']}")
else:
    print(f"  Message: {fix_result.get('message', 'No message')}")
print("=" * 50)

# Read fixed content
with open(test_file, 'r') as f:
    fixed_content = f.read()

print("FIXED CONTENT:")
print(fixed_content)
print("=" * 50)

# Expected result for comparison
expected_func_fix = "def test_func():"
expected_println_fix = "print(\"Hello World\");"
expected_shebang_fix = "# NoodleCore converted from Python"

# Check if all expected fixes are present
all_fixes_present = (
    expected_func_fix in fixed_content and
    expected_println_fix in fixed_content and
    expected_shebang_fix in fixed_content
)

if all_fixes_present:
    print("âœ… SUCCESS: All fixes applied correctly!")
else:
    print("âŒ FAILURE: Some fixes missing")
    print(f"  Expected func fix: {expected_func_fix in fixed_content}")
    print(f"  Expected println fix: {expected_println_fix in fixed_content}")
    print(f"  Expected shebang fix: {expected_shebang_fix in fixed_content}")

# Cleanup
os.remove(test_file)
if os.path.exists(test_file + '.bak'):
    os.remove(test_file + '.bak')
print("Test completed.")

