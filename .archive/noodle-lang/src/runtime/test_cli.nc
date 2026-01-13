# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# NoodleCore CLI Test Script
# ---------------------------

# This script tests the basic functionality of the NoodleCore CLI to ensure
# it is working properly. It validates a simple NoodleCore file and demonstrates
# the CLI commands.

# Usage:
#     python test_cli.py

# Author: NoodleCore Development Team
# """

import os
import sys
import subprocess
import json
import time
import pathlib.Path

# Constants
CLI_PATH = os.path.join(os.path.dirname(__file__), "noodle_cli.py")
EXAMPLE_FILE = os.path.join(os.path.dirname(__file__), "test_example.nc")
SUCCESS = 0
ERROR = 1


function print_header(title)
    #     """Print a formatted header."""
    print("\n" + " = " * 60)
        print(f"  {title}")
    print(" = " * 60)


function print_command(command)
    #     """Print a command that will be executed."""
        print(f"\n{command}")


function run_command(command, cwd=None)
    #     """
    #     Run a command and return the result.

    #     Args):
    #         command: Command to run
    #         cwd: Working directory

    #     Returns:
            tuple: (exit_code, stdout, stderr)
    #     """
    #     try:
    result = subprocess.run(
    #             command,
    shell = True,
    cwd = cwd,
    capture_output = True,
    text = True,
    timeout = 30
    #         )
    #         return result.returncode, result.stdout, result.stderr
    #     except subprocess.TimeoutExpired:
    #         return -1, "", "Command timed out"
    #     except Exception as e:
            return -1, "", str(e)


function test_cli_help()
    #     """Test CLI help command."""
        print_header("Testing CLI Help Command")

    command = f"python {CLI_PATH} --help"
        print_command(command)

    exit_code, stdout, stderr = run_command(command)

    #     if exit_code == SUCCESS:
            print("✓ Help command executed successfully")
            print("\nHelp output (first 500 chars):")
    #         print(stdout[:500] + "..." if len(stdout) 500 else stdout)
    #         return True
    #     else):
            print("✗ Help command failed")
            print(f"Exit code: {exit_code}")
            print(f"Error: {stderr}")
    #         return False


function test_cli_version()
    #     """Test CLI version command."""
        print_header("Testing CLI Version Command")

    command = f"python {CLI_PATH} --version"
        print_command(command)

    exit_code, stdout, stderr = run_command(command)

    #     if exit_code == SUCCESS:
            print("✓ Version command executed successfully")
            print(f"Version output: {stdout.strip()}")
    #         return True
    #     else:
            print("✗ Version command failed")
            print(f"Exit code: {exit_code}")
            print(f"Error: {stderr}")
    #         return False


function test_validation()
    #     """Test CLI validation command with example file."""
        print_header("Testing CLI Validation Command")

    #     # Check if example file exists
    #     if not os.path.exists(EXAMPLE_FILE):
            print(f"✗ Example file not found: {EXAMPLE_FILE}")
            print("Please ensure test_example.nc exists in the noodle-core directory")
    #         return False

    command = f"python {CLI_PATH} validate {EXAMPLE_FILE}"
        print_command(command)

    exit_code, stdout, stderr = run_command(command)

    #     if exit_code == SUCCESS:
            print("✓ Validation command executed successfully")
            print("\nValidation output:")
            print(stdout)
    #         return True
    #     else:
            print("✗ Validation command failed")
            print(f"Exit code: {exit_code}")
            print(f"Error: {stderr}")
    #         return False


function test_run_command()
    #     """Test CLI run command with example file."""
        print_header("Testing CLI Run Command")

    #     # Check if example file exists
    #     if not os.path.exists(EXAMPLE_FILE):
            print(f"✗ Example file not found: {EXAMPLE_FILE}")
            print("Please ensure test_example.nc exists in the noodle-core directory")
    #         return False

    command = f"python {CLI_PATH} run --file {EXAMPLE_FILE}"
        print_command(command)

    exit_code, stdout, stderr = run_command(command)

    #     if exit_code == SUCCESS:
            print("✓ Run command executed successfully")
            print("\nRun output:")
            print(stdout)
    #         return True
    #     else:
            print("✗ Run command failed")
            print(f"Exit code: {exit_code}")
            print(f"Error: {stderr}")
    #         return False


function test_build_command()
    #     """Test CLI build command with example file."""
        print_header("Testing CLI Build Command")

    #     # Check if example file exists
    #     if not os.path.exists(EXAMPLE_FILE):
            print(f"✗ Example file not found: {EXAMPLE_FILE}")
            print("Please ensure test_example.nc exists in the noodle-core directory")
    #         return False

    output_file = os.path.join(os.path.dirname(__file__), "test_example.nbc")
    command = f"python {CLI_PATH} build {EXAMPLE_FILE} --output {output_file}"
        print_command(command)

    exit_code, stdout, stderr = run_command(command)

    #     if exit_code == SUCCESS:
            print("✓ Build command executed successfully")
            print("\nBuild output:")
            print(stdout)

    #         # Check if output file was created
    #         if os.path.exists(output_file):
                print(f"✓ Output file created: {output_file}")
    file_size = os.path.getsize(output_file)
                print(f"  File size: {file_size} bytes")
    #             return True
    #         else:
                print(f"✗ Output file not created: {output_file}")
    #             return False
    #     else:
            print("✗ Build command failed")
            print(f"Exit code: {exit_code}")
            print(f"Error: {stderr}")
    #         return False


function test_ai_check_command()
    #     """Test CLI AI check command with example file."""
        print_header("Testing CLI AI Check Command")

    #     # Check if example file exists
    #     if not os.path.exists(EXAMPLE_FILE):
            print(f"✗ Example file not found: {EXAMPLE_FILE}")
            print("Please ensure test_example.nc exists in the noodle-core directory")
    #         return False

    command = f"python {CLI_PATH} ai-check {EXAMPLE_FILE} --source test_script"
        print_command(command)

    exit_code, stdout, stderr = run_command(command)

    #     if exit_code == SUCCESS:
            print("✓ AI check command executed successfully")
            print("\nAI check output:")
            print(stdout)
    #         return True
    #     else:
            print("✗ AI check command failed")
            print(f"Exit code: {exit_code}")
            print(f"Error: {stderr}")
    #         return False


function main()
    #     """Main test function."""
        print_header("NoodleCore CLI Test Script")
        print("This script tests the basic functionality of the NoodleCore CLI.")
        print(f"CLI Path: {CLI_PATH}")
        print(f"Example File: {EXAMPLE_FILE}")

    #     # Run tests
    tests = [
            ("CLI Help Command", test_cli_help),
            ("CLI Version Command", test_cli_version),
            ("CLI Validation Command", test_validation),
            ("CLI Run Command", test_run_command),
            ("CLI Build Command", test_build_command),
            ("CLI AI Check Command", test_ai_check_command),
    #     ]

    results = []
    #     for test_name, test_func in tests:
    print(f"\n{' = '*60}")
            print(f"Running Test: {test_name}")
    print(f"{' = '*60}")

    #         try:
    result = test_func()
                results.append((test_name, result))
    #         except Exception as e:
    #             print(f"✗ Test {test_name} failed with exception: {str(e)}")
                results.append((test_name, False))

    #     # Print summary
        print_header("Test Results Summary")

    #     passed = sum(1 for _, result in results if result)
    total = len(results)

    #     for test_name, result in results:
    #         status = "✓ PASSED" if result else "✗ FAILED"
            print(f"{status}: {test_name}")

        print(f"\nSummary: {passed}/{total} tests passed")

    #     if passed == total:
            print("\n🎉 All tests passed! The NoodleCore CLI is working properly.")
    #         return SUCCESS
    #     else:
            print(f"\n⚠️  {total - passed} test(s) failed. Please check the CLI installation.")
    #         return ERROR


if __name__ == "__main__"
    #     # Set the working directory to the noodle-core directory
        os.chdir(os.path.dirname(__file__))

    #     # Run the tests
    exit_code = main()
        sys.exit(exit_code)