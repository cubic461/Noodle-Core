#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_main_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for enhanced main statement fixing functionality
"""

import sys
import os
sys.path.insert(0, 'src')
from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer

# Test content with complex Python main blocks
test_content = """#!/usr/bin/env python3
import os
import sys

def process_data(data):
    \"\"\"Process some data\"\"\"
    result = []
    for item in data:
        if item > 0:
            result.append(item * 2)
        else:
            result.append(0)
    return result

def main():
    print("Starting main function")
    data = [1, -2, 3, 0, 5]
    processed = process_data(data)
    print(f"Original: {data}")
    print(f"Processed: {processed}")
    
    # Test various statement types
    x = 10
    y = 20
    sum_result = x + y
    
    # Test function calls
    print(f"Sum: {sum_result}")
    
    # Test method calls
    my_list = [1, 2, 3]
    my_list.append(4)
    print(f"List length: {len(my_list)}")
    
    # Test control flow
    for i in range(5):
        if i % 2 == 0:
            print(f"Even: {i}")
        else:
            print(f"Odd: {i}")
    
    return "success"

if __name__ == "__main__":
    result = main()
    print(f"Main result: {result}")
"""

# Write test file
test_file = 'test_enhanced_main_fix.nc'
with open(test_file, 'w', encoding='utf-8') as f:
    f.write(test_content)

# Test the fixer
fixer = NoodleCoreSyntaxFixer()
print("Testing enhanced main statement fixer...")
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

# Expected key patterns in the fixed content
expected_patterns = [
    '# Main execution',
    'main();',
    'let x = 10;',
    'let y = 20;',
    'print("Starting main function");',
    'processed = process_data(data);',
    'print(f"Original: {data}");',
    'print(f"Processed: {processed}");',
    'sum_result = x + y;',
    'print(f"Sum: {sum_result}");',
    'my_list.append(4);',
    'print(f"List length: {len(my_list)}");'
]

print("EXPECTED PATTERNS CHECK:")
for pattern in expected_patterns:
    if pattern in fixed_content:
        print(f"  [FOUND] Found: {pattern}")
    else:
        print(f"  [MISSING] Missing: {pattern}")

# Validate fixed content
validation_after = fixer.validate_file(test_file)
print("\nVALIDATION AFTER FIX:")
print(f"  Valid: {validation_after['valid']}")
if not validation_after['valid']:
    print(f"  Remaining errors: {validation_after['error_count']}")
    for error in validation_after['errors']:
        print(f"    - {error}")

# Cleanup
os.remove(test_file)
if os.path.exists(test_file + '.bak'):
    os.remove(test_file + '.bak')
print("\nTest completed.")

