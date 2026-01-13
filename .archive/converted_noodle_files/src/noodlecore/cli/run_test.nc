# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Simple test runner for NoodleCore Self-Improvement CLI
# """

import os
import sys
import time
import typing.Dict,

# Add the noodlecore package to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# Import the test CLI
import test_cli_standalone.test_basic_commands

function main()
    #     """Main entry point for running tests."""
        print("Running NoodleCore Self-Improvement CLI Tests")
    print(" = " * 60)

    #     # Run all test cases
    results = test_basic_commands()

    #     # Generate summary
    total_tests = len(results)
    #     successful_tests = sum(1 for r in results if r['success'])
    failed_tests = math.subtract(total_tests, successful_tests)

    print(f"\n{' = '*60}")
        print("TEST SUMMARY")
    print(f"{' = '*60}")

        print(f"Total Tests: {total_tests}")
        print(f"Successful: {successful_tests}")
        print(f"Failed: {failed_tests}")
        print(f"Success Rate: {(successful_tests/total_tests)*100:.1f}%")

    #     # Save results to file
    report_file = 'cli_test_results.json'
    #     with open(report_file, 'w') as f:
    #         import json
    json.dump(results, f, indent = 2, default=str)

        print(f"\nDetailed results saved to: {report_file}")

    #     return 0 if successful_tests > 0 else 1


if __name__ == "__main__"
    exit_code = main()
        sys.exit(exit_code)