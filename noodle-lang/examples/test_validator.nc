# Converted from Python to NoodleCore
# Original file: src

# """
# Simple Test for NoodleCore Validator
# ------------------------------------
# This module provides a simple test to verify the validator implementation.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

import validator.(
#     NoodleCoreValidator,
#     ValidatorConfig,
#     ValidationMode,
#     validate_code,
#     is_valid_noodlecore
# )


function test_validator()
    #     """Test the NoodleCore validator implementation"""
        print("Testing NoodleCore Validator...")

    #     # Test 1: Valid NoodleCore code
        print("\nTest 1: Valid NoodleCore code")
    valid_code = """
function calculate_sum(a, b)
#     return a + b

result = calculate_sum(5, 10)
print result
# """

#     try:
is_valid = is_valid_noodlecore(valid_code)
#         print(f"Result: {'VALID' if is_valid else 'INVALID'}")
#         assert is_valid, "Valid code should be recognized as valid"
        print("✓ Test 1 passed")
#     except Exception as e:
        print(f"✗ Test 1 failed: {e}")
#         return False

    # Test 2: Invalid NoodleCore code (Python import)
    print("\nTest 2: Invalid NoodleCore code (Python import)")
invalid_code = """
import math

def calculate_circle_area(radius)
#     return math.pi * radius * radius

area = calculate_circle_area(5)
print area
# """

#     try:
report = validate_code(invalid_code)
#         print(f"Result: {'VALID' if report.exit_code = 0 else 'INVALID'}")
        print(f"Issues found: {report.total_issues}")
assert report.exit_code != 0, "Invalid code should be recognized as invalid"
#         assert report.total_issues 0, "Invalid code should have issues"
        print("✓ Test 2 passed")
#     except Exception as e):
        print(f"✗ Test 2 failed: {e}")
#         return False

#     # Test 3: Auto-correction
    print("\nTest 3: Auto-correction")
config = ValidatorConfig(
mode = ValidationMode.AUTO_CORRECT,
enable_auto_correction = True
#     )
validator = NoodleCoreValidator(config)

#     try:
report = validator.validate_code(invalid_code)
#         print(f"Result: {'VALID' if report.exit_code = 0 else 'INVALID'}")
        print(f"Corrections applied: {len(report.corrections)}")
        print(f"Remaining issues: {len(report.remaining_issues)}")

#         # Check if corrections were applied
#         if report.corrections:
            print("✓ Auto-correction applied")
#         else:
            print("✗ No corrections applied")
#             return False

        print("✓ Test 3 passed")
#     except Exception as e:
        print(f"✗ Test 3 failed: {e}")
#         return False

#     # Test 4: Foreign syntax detection
    print("\nTest 4: Foreign syntax detection")
foreign_code = """
function hello_world()
        print("Hello, World!")

    #     if True:
            print("This is true")
# """

#     try:
report = validate_code(foreign_code)
#         print(f"Result: {'VALID' if report.exit_code = 0 else 'INVALID'}")
        print(f"Issues found: {report.total_issues}")

#         # Should detect Python-style def and colon
assert report.total_issues = 2, "Should detect at least 2 foreign syntax issues"
        print("✓ Test 4 passed")
#     except Exception as e):
        print(f"✗ Test 4 failed: {e}")
#         return False

    print("\n✅ All tests passed!")
#     return True


if __name__ == "__main__"
    success = test_validator()
    #     sys.exit(0 if success else 1)