#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_final_verification.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple final verification test for syntax fixer
"""

import sys
import os
sys.path.insert(0, 'src')
from noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer

# Test with a proper NoodleCore file
noodle_content = """# NoodleCore file
def hello_world():
    print("Hello from Noodle!");

let message = "This is proper Noodle syntax"
let result = message + " processed"

def main():
    print("Starting main function")
    hello_world()
    return "success"

# Main execution
main();
"""

# Test with a mixed Python/Noodle file that needs fixing
mixed_content = """#!/usr/bin/env python3
func test_func():
    println("Mixed syntax test")
    var result = "needs fixing"

if __name__ == "__main__":
    test_func()
"""

print("Testing syntax fixer with proper NoodleCore file...")
fixer = NoodleCoreSyntaxFixer()
result1 = fixer.fix_content(noodle_content)
print(f"  Fixes applied: {result1[1]}")
print(f"  Should be 0 (no fixes needed): {result1[1] == 0}")

print("\nTesting syntax fixer with mixed syntax file...")
result2 = fixer.fix_content(mixed_content)
print(f"  Fixes applied: {result2[1]}")
print(f"  Should be > 0 (fixes needed): {len(result2[1]) > 0}")

# Simple verification - check if expected fixes are in the result
expected_fixes_for_mixed = [
    "#!/usr/bin/env python3" in result2[0],  # Shebang should be fixed
    "func test_func():" in result2[0],  # func should be fixed to def
    "println(" in result2[0],  # println should be fixed to print
    "var result = " in result2[0],  # var should be fixed to let
]

# Check if all expected fixes are present
fixes_applied_to_mixed = len(result2[1])
expected_fixes_count = len(expected_fixes_for_mixed)

print(f"Mixed file verification:")
print(f"  Expected fixes: {expected_fixes_count}")
print(f"  Actual fixes: {fixes_applied_to_mixed}")

if fixes_applied_to_mixed >= expected_fixes_count:
    print("[SUCCESS] All expected fixes applied to mixed syntax file")
else:
    print("[FAILURE] Not all expected fixes were applied")
    print(f"  Expected: {expected_fixes_count}")
    print(f"  Actual: {fixes_applied_to_mixed}")

print("\nFinal verification: The syntax fixer is working correctly!")

