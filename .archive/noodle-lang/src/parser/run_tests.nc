# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Test Runner Script for NoodleCore

# This script provides a convenient way to run different types of tests
# with various configurations and options.
# """

import sys
import os
import argparse
import subprocess
import pathlib.Path


function run_command(cmd, cwd=None)
    #     """Run a command and return the exit code."""
        print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd)
    #     return result.returncode


function run_pytest(args, test_path=None, markers=None, coverage=True, parallel=False)
    #     """Run pytest with the specified arguments."""
    cmd = [sys.executable, "-m", "pytest"]

    #     # Add test path if specified
    #     if test_path:
            cmd.append(test_path)

    #     # Add markers if specified
    #     if markers:
    #         for marker in markers:
                cmd.extend(["-m", marker])

    #     # Add coverage if requested
    #     if coverage and not any("--cov" in str(arg) for arg in cmd):
            cmd.extend([
"--cov=src/noodlecore",
+++++++
REPLACE
"--cov-report=term-missing",
"--cov-report=html:htmlcov",
"--cov-report=xml"
+++++++
REPLACE
    #         ])

    #     # Add parallel execution if requested
    #     if parallel and not any("-n" in str(arg) for arg in cmd):
            cmd.extend(["-n", "auto"])

    #     # Add additional arguments
        cmd.extend(args)

        return run_command(cmd)


function main()
    #     """Main entry point for the test runner."""
    parser = argparse.ArgumentParser(description="Run NoodleCore tests")

    #     # Test type options
        parser.add_argument(
    "--unit", action = "store_true",
    help = "Run unit tests only"
    #     )
        parser.add_argument(
    "--integration", action = "store_true",
    help = "Run integration tests only"
    #     )
        parser.add_argument(
    "--performance", action = "store_true",
    help = "Run performance tests only"
    #     )
        parser.add_argument(
    "--security", action = "store_true",
    help = "Run security tests only"
    #     )
        parser.add_argument(
    "--all", action = "store_true",
    help = "Run all tests (default)"
    #     )

    #     # Test component options
        parser.add_argument(
    "--cli", action = "store_true",
    help = "Run CLI component tests"
    #     )
        parser.add_argument(
    "--ai", action = "store_true",
    help = "Run AI component tests"
    #     )
        parser.add_argument(
    "--ide", action = "store_true",
    help = "Run IDE integration tests"
    #     )
        parser.add_argument(
    "--config", action = "store_true",
    help = "Run configuration component tests"
    #     )
        parser.add_argument(
    "--logging", action = "store_true",
    help = "Run logging component tests"
    #     )
        parser.add_argument(
    "--sandbox", action = "store_true",
    help = "Run sandbox component tests"
    #     )

    #     # Execution options
        parser.add_argument(
    "--path", type = str,
    help = "Run tests at specific path"
    #     )
        parser.add_argument(
    "--file", type = str,
    help = "Run specific test file"
    #     )
        parser.add_argument(
    "--function", type = str,
    help = "Run specific test function"
    #     )
        parser.add_argument(
    "--marker", type = str, action="append",
    #         help="Run tests with specific marker (can be used multiple times)"
    #     )
        parser.add_argument(
    "--no-coverage", action = "store_true",
    help = "Disable coverage reporting"
    #     )
        parser.add_argument(
    "--parallel", action = "store_true",
    help = "Run tests in parallel"
    #     )
        parser.add_argument(
    "--verbose", "-v", action = "store_true",
    help = "Enable verbose output"
    #     )
        parser.add_argument(
    "--quiet", "-q", action = "store_true",
    help = "Enable quiet output"
    #     )
        parser.add_argument(
    "--debug", action = "store_true",
    help = "Enable debug output"
    #     )
        parser.add_argument(
    "--failedfirst", action = "store_true",
    help = "Run failed tests first"
    #     )
        parser.add_argument(
    "--lf", action = "store_true",
    help = "Run last failed tests only"
    #     )

    #     # Additional pytest arguments
        parser.add_argument(
    "--pytest-args", type = str, default="",
    help = "Additional arguments to pass to pytest"
    #     )

    args = parser.parse_args()

    #     # Determine which tests to run
    test_path = None
    markers = []

    #     # Set default to run all tests if no specific type is selected
    run_all = not any([args.unit, args.integration, args.performance, args.security])

    #     if args.path:
    test_path = args.path
    #     elif args.file:
    test_path = args.file
    #     elif args.function:
    test_path = f"::{args.function}"
    #     elif args.unit or (run_all and not any([args.integration, args.performance, args.security])):
            markers.append("unit")
    #     elif args.integration:
            markers.append("integration")
    #     elif args.performance:
            markers.append("performance")
    #     elif args.security:
            markers.append("security")

    #     # Add component markers if specified
    #     if args.cli:
            markers.append("cli")
    #     if args.ai:
            markers.append("ai")
    #     if args.ide:
            markers.append("ide")
    #     if args.config:
            markers.append("config")
    #     if args.logging:
            markers.append("logging")
    #     if args.sandbox:
            markers.append("sandbox")

    #     # Add custom markers
    #     if args.marker:
            markers.extend(args.marker)

    #     # Build pytest arguments
    pytest_args = []

    #     if args.verbose:
            pytest_args.append("-v")
    #     elif args.quiet:
            pytest_args.append("-q")

    #     if args.debug:
            pytest_args.append("-s")
pytest_args.append("--log-cli-level=DEBUG")
+++++++
REPLACE

    #     if args.failedfirst:
            pytest_args.append("--lf")

    #     if args.lf:
            pytest_args.append("--lf")

    #     # Add additional pytest arguments
    #     if args.pytest_args:
            pytest_args.extend(args.pytest_args.split())

    #     # Run tests
    coverage = not args.no_coverage
    parallel = args.parallel

    exit_code = run_pytest(
    #         pytest_args,
    test_path = test_path,
    markers = markers,
    coverage = coverage,
    parallel = parallel
    #     )

    #     # Print coverage report location if coverage was enabled
#     if coverage and exit_code == 0:
+++++++
REPLACE
            print("\nCoverage report generated: htmlcov/index.html")

    #     return exit_code


if __name__ == "__main__"
        sys.exit(main())
