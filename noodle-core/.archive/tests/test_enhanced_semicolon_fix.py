#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_semicolon_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for enhanced semicolon fixing functionality
"""

import sys
import os
sys.path.insert(0, 'src')
from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer

# Test content with various semicolon patterns
test_content = """#!/usr/bin/env python3
import os
import sys

func calculate_sum(a, b):
    result = a + b
    print(f"Sum: {result}")
    return result

def main():
    x = 10
    y = 20
    total = calculate_sum(x, y)
    print(f"Total: {total}")
    
    # Test method calls
    list_data = [1, 2, 3]
    list_data.append(4)
    print(list_data.length)
    
    # Test control statements
    for item in list_data:
        if item > 2:
            break
        else:
            continue
    
    # Test multiple assignments
    var1 = "test"
    var2 = "another test"

if __name__ == "__main__":
    main()
"""

# Write test file
test_file = 'test_enhanced_semicolon_fix.nc'
with open(test_file, 'w', encoding='utf-8') as f:
    f.write(test_content)

# Test the fixer
fixer = NoodleCoreSyntaxFixer()
print("Testing enhanced semicolon fixer...")
print("=" * 60)

# Show original content
print("ORIGINAL CONTENT:")
print(test_content)
print("=" * 60)

# Validate first
validation = fixer.validate_file(test_file)
print("VALIDATION RESULTS:")
print(f"  Valid: {validation['valid']}")
if not validation['valid']:
    print(f"  Errors found: {validation['error_count']}")
    for error in validation['errors']:
        print(f"    - {error}")
print("=" * 60)

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
print("=" * 60)

# Read fixed content
with open(test_file, 'r', encoding='utf-8') as f:
    fixed_content = f.read()

print("FIXED CONTENT:")
print(fixed_content)
print("=" * 60)

# Expected result for comparison
expected_content = """# NoodleCore converted from Python
import "os";
import "sys";

def calculate_sum(a, b):
    let result = a + b;
    print("Sum: {result}");
    return result;

def main():
    let x = 10;
    let y = 20;
    let total = calculate_sum(x, y);
    print("Total: {total}");
    
    # Test method calls
    let list_data = [1, 2, 3];
    list_data.append(4);
    print(list_data.length);
    
    # Test control statements
    for item in list_data:
        if item > 2:
            break;
        else:
            continue;
    
    # Test multiple assignments
    let var1 = "test";
    let var2 = "another test";

# Main execution
calculate_sum(x, y);
print("Total: {total}");
list_data.append(4);
print(list_data.length);
if item > 2:
    break;
else:
    continue;
let var1 = "test";
let var2 = "another test";
main();
"""

print("EXPECTED CONTENT (simplified):")
print("Note: Expected content shows the key patterns that should be fixed")
print("=" * 60)

# Validate fixed content
validation_after = fixer.validate_file(test_file)
print("VALIDATION AFTER FIX:")
print(f"  Valid: {validation_after['valid']}")
if not validation_after['valid']:
    print(f"  Remaining errors: {validation_after['error_count']}")
    for error in validation_after['errors']:
        print(f"    - {error}")

# Cleanup
os.remove(test_file)
if os.path.exists(test_file + '.bak'):
    os.remove(test_file + '.bak')
print("Test completed.")

