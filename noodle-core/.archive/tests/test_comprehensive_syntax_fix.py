#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_comprehensive_syntax_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive test script for syntax fixer
"""

import sys
import os
sys.path.insert(0, 'src')
from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer

# Create a test file with mixed syntax issues
test_content = """#!/usr/bin/env python3
func hello_world():
    println("Hello from func!")
    message = "This is a test"
    var result = message + " processed"

def main():
    print("Starting main function")
    hello_world()
    return "success"

if __name__ == "__main__":
    main()
"""

# Write test file
test_file = 'test_comprehensive_syntax_fix.nc'
with open(test_file, 'w', encoding='utf-8') as f:
    f.write(test_content)

# Test the fixer
fixer = NoodleCoreSyntaxFixer()
print("Testing comprehensive syntax fixer...")
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
def hello_world():
    print("Hello from func!");
    let message = "This is a test";
    let result = message + " processed";

def main():
    print("Starting main function");
    hello_world();
    return "success";

# Main execution
main();
"""

print("EXPECTED CONTENT:")
print(expected_content)
print("=" * 60)

# Compare with expected
try:
    if fixed_content.strip() == expected_content.strip():
        print("[SUCCESS] All fixes applied correctly!")
    else:
        print("[FAILURE] Fixed content doesn't match expected")
        print("Differences found:")
        
        fixed_lines = fixed_content.strip().split('\n')
        expected_lines = expected_content.strip().split('\n')
        
        for i, (fixed_line, expected_line) in enumerate(zip(fixed_lines, expected_lines)):
            if fixed_line.strip() != expected_line.strip():
                print(f"  Line {i+1}:")
                print(f"    Fixed:    {fixed_line}")
                print(f"    Expected:  {expected_line}")
except Exception as e:
    print(f"Error during comparison: {e}")

# Cleanup
os.remove(test_file)
if os.path.exists(test_file + '.bak'):
    os.remove(test_file + '.bak')
print("Test completed.")

