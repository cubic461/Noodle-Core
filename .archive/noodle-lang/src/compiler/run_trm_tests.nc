# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Simple test runner for the fixed TRM integration test suite
# This script provides a clean interface to run the improved TRM tests
# """

import asyncio
import sys
import os
import json
import time
import pathlib.Path

# Add the current directory to the path
sys.path.insert(0, os.path.dirname(__file__))

import test_trm_compiler_integration_fixed.run_trm_test_suite

function save_results_to_file(results: dict, filename: str = "trm_test_results.json")
    #     """Save test results to JSON file"""
    #     try:
    #         with open(filename, 'w') as f:
    json.dump(results, f, indent = 2, default=str)
            print(f"Results saved to: {filename}")
    #     except Exception as e:
            print(f"Error saving results: {e}")

function print_test_summary(results: dict)
    #     """Print a formatted test summary"""
    print("\n" + " = "*60)
        print("TRM TEST SUITE EXECUTION SUMMARY")
    print(" = "*60)

    #     if results["status"] == "completed":
    summary = results["summary"]
            print(f"Total tests: {summary['total_tests']}")
            print(f"Completed: {summary['completed']}")
            print(f"Failed: {summary['failed']}")
            print(f"Timeouts: {summary['timeouts']}")
            print(f"Cancelled: {summary['cancelled']}")
            print(f"Success rate: {summary['success_rate']:.2%}")
            print(f"Total duration: {summary['total_duration']:.2f}s")
            print(f"Average duration: {summary['average_duration']:.2f}s")

    #         if results.get("memory_stats"):
                print(f"\nMemory usage: {results['memory_stats']['current_memory_mb']:.1f}MB")
                print(f"Peak memory: {results['memory_stats']['peak_memory_mb']:.1f}MB")
                print(f"Memory increase: {results['memory_stats']['memory_increase_mb']:.1f}MB")

            print(f"\nDetailed results saved to: trm_test_results.json")

    #     else:
            print(f"Test suite failed: {results['error']}")

    print(" = "*60)

# async def main():
#     """Main function to run the TRM test suite"""
    print("Starting TRM Integration Test Suite...")
    print("This version includes:")
    print("- Comprehensive timeout mechanisms")
    print("- Memory usage monitoring")
    print("- Async test execution")
    print("- Progress logging")
    print("- Proper error handling")
    print("- Batch processing to prevent freezing")
    print()

start_time = time.time()

#     try:
#         # Run the test suite
results = await run_trm_test_suite()

#         # Calculate total execution time
execution_time = time.time() - start_time

#         # Add execution time to results
results["execution_time"] = execution_time

#         # Save results to file
        save_results_to_file(results)

#         # Print summary
        print_test_summary(results)

#         # Return appropriate exit code
#         if results["status"] == "completed":
#             # Check if any tests failed
summary = results["summary"]
#             if summary["failed"] 0 or summary["timeouts"] > 0):
                print("\n[WARNING] Some tests failed or timed out. Check the detailed results.")
#                 return 1
#             else:
                print("\n[SUCCESS] All tests completed successfully!")
#                 return 0
#         else:
            print(f"\n[ERROR] Test suite failed: {results['error']}")
#             return 1

#     except KeyboardInterrupt:
        print("\n\n[INFO] Test execution interrupted by user")
#         return 130
#     except Exception as e:
        print(f"\n[ERROR] Unexpected error: {e}")
#         return 1

if __name__ == "__main__"
    exit_code = asyncio.run(main())
        sys.exit(exit_code)