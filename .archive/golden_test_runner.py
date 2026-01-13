#!/usr/bin/env python3
"""
Test Suite::Noodle - golden_test_runner.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Golden Test Runner

This module reads golden_tests.json and validates simple_file_processor.py.
It can run tests, verify assertions, and report results with detailed diffs.
"""

import json
import os
import subprocess
import sys
import re
from pathlib import Path
from typing import Dict, List, Tuple, Any, Optional


class TestResult:
    """Represents the result of a single golden test execution."""

    def __init__(self, test_id: str):
        self.test_id = test_id
        self.passed = True
        self.failures: List[str] = []
        self.actual_output: Dict[str, Any] = {}
        self.expected_output: Dict[str, Any] = {}
        self.duration = 0.0

    def fail(self, reason: str):
        """Mark test as failed with reason."""
        self.passed = False
        self.failures.append(reason)

    def to_json(self) -> Dict[str, Any]:
        """Convert result to JSON format."""
        return {
            "test_id": self.test_id,
            "passed": self.passed,
            "failures": self.failures,
            "actual_output": self.actual_output,
            "expected_output": self.expected_output
        }


class GoldenTestRunner:
    """Runner for golden tests."""

    def __init__(self, test_file: str):
        """Initialize the runner with test suite JSON."""
        self.test_file = test_file
        self.suite: Optional[Dict[str, Any]] = None
        self.results: List[TestResult] = []

    def load_tests(self):
        """Load tests from JSON file."""
        with open(self.test_file, 'r', encoding='utf-8') as f:
            self.suite = json.load(f)
        print(f"Loaded '{self.suite['test_suite_name']}': {len(self.suite['tests'])} tests")

    def run_tests(self) -> bool:
        """
        Execute all enabled tests.

        Returns:
            True if all enabled tests passed, False otherwise.
        """
        if not self.suite:
            print("No test suite loaded!")
            return False

        passed = 0
        failed = 0
        skipped = 0

        for test in self.suite['tests']:
            if not test.get('enabled', True):
                print(f"\n[SKIP] {test['test_id']}")
                skipped += 1
                continue

            print(f"\n[TESTING] {test['test_id']} - {test['description']}")
            result = self.run_test(test)

            if result.passed:
                print(f"âœ… PASSED: {test['test_id']}")
                passed += 1
            else:
                print(f"âŒ FAILED: {test['test_id']}")
                failed += 1
                print(f"   Failures: {len(result.failures)}")
                for failure in result.failures:
                    print(f"     - {failure}")

        total = passed + failed + skipped
        print(f"\n{'='*60}")
        print(f"Tests Summary: {total} total")
        print(f"  âœ… Passed:  {passed}")
        print(f"  âŒ Failed:  {failed}")
        print(f"  â­ï¸  Skipped: {skipped}")
        print(f"{'='*60}")

        return failed == 0

    def run_test(self, test: Dict[str, Any]) -> TestResult:
        """
        Execute a single test.

        Args:
            test: Test case dictionary from suite.

        Returns:
            TestResult with pass/fail status and details.
        """
        result = TestResult(test['test_id'])

        try:
            # Setup phase
            self._run_setup(test.get('setup', {}))

            # Execute phase
            actual_output = self._run_command(test['input'])

            # Store actual output
            result.actual_output = actual_output

            # Validate outputs
            self._validate_output(test['expected_output'], actual_output, result)

            # Validate files
            self._validate_files(test.get('expected_files', []), result)

            # Validate assertions
            self._validate_assertions(test.get('assertions', []), actual_output, result)

        except Exception as e:
            result.fail(f"Test execution error: {e}")

        finally:
            # Cleanup phase
            self._run_cleanup(test.get('cleanup', {}))

        return result

    def _run_setup(self, setup: Dict[str, Any]):
        """Execute setup actions."""
        # Delete existing artifacts
        for path in setup.get('delete_files', []):
            if os.path.exists(path):
                print(f"  Deleting: {path}")
                os.remove(path)

        # Create input files
        for file_spec in setup.get('create_files', []):
            path = file_spec['path']
            content = file_spec.get('content', '')

            # Create directories if needed
            os.makedirs(os.path.dirname(path) or '.', exist_ok=True)

            print(f"  Creating: {path}")
            with open(path, 'w', encoding=file_spec.get('encoding', 'utf-8')) as f:
                f.write(content)

        # Apply environment variables
        for key, value in setup.get('environment', {}).items():
            os.environ[key] = str(value)

    def _run_command(self, input_spec: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute a command and capture its output.

        Args:
            input_spec: Input specification from test.

        Returns:
            Dictionary containing stdout, stderr, exit_code, and execution info.
        """
        command = input_spec['command']
        stdin = input_spec.get('stdin')
        timeout = input_spec.get('timeout_seconds', 10)

        proc = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=input_spec.get('working_dir') or os.getcwd(),
            input=stdin if stdin else None
        )

        return {
            'stdout': proc.stdout,
            'stderr': proc.stderr,
            'exit_code': proc.returncode,
            'command': command,
            'success': proc.returncode == 0
        }

    def _run_cleanup(self, cleanup: Dict[str, Any]):
        """Execute cleanup actions."""
        for path in cleanup.get('delete_files', []):
            if os.path.exists(path):
                print(f"  Cleaning up: {path}")
                os.remove(path)

        for path in cleanup.get('delete_dirs', []):
            if os.path.exists(path):
                print(f"  Cleaning up dir: {path}")
                import shutil
                shutil.rmtree(path)

    def _validate_output(self, expected: Dict[str, Any], actual: Dict[str, Any], result: TestResult):
        """Validate output matches expectations."""
        # Validate exit code
        if 'exit_code' in expected:
            if actual['exit_code'] != expected['exit_code']:
                result.fail(
                    f"Exit code mismatch: expected {expected['exit_code']}, got {actual['exit_code']}"
                )

        # Validate stdout
        if expected.get('stdout') is not None:
            if expected.get('stdout_regex'):
                # Regex match
                if not re.search(expected['stdout_regex'], actual['stdout']):
                    result.fail(f"Stdout regex '{expected['stdout_regex']}' did not match: {repr(actual['stdout'])}")
            else:
                # Exact or partial match
                if expected.get('partial_match', False):
                    if expected['stdout'] not in actual['stdout']:
                        result.fail(f"Stdout does not contain expected text: {repr(expected['stdout'])}")
                else:
                    if actual['stdout'] != expected['stdout']:
                        result.fail(
                            f"Stdout mismatch:\n"
                            f"  Expected: {repr(expected['stdout'])}\n"
                            f"  Actual:   {repr(actual['stdout'])}"
                        )

        # Validate stderr
        if expected.get('stderr') is not None:
            if expected.get('stderr_regex'):
                # Regex match
                if not re.search(expected['stderr_regex'], actual['stderr']):
                    result.fail(f"Stderr regex '{expected['stderr_regex']}' did not match: {repr(actual['stderr'])}")
            else:
                # Exact or partial match
                if expected.get('partial_match', False):
                    if expected['stderr'] not in actual['stderr']:
                        result.fail(f"Stderr does not contain expected text: {repr(expected['stderr'])}")
                else:
                    if actual['stderr'] != expected['stderr']:
                        result.fail(
                            f"Stderr mismatch:\n"
                            f"  Expected: {repr(expected['stderr'])}\n"
                            f"  Actual:   {repr(actual['stderr'])}"
                        )

    def _validate_files(self, expected_files: List[Dict[str, Any]], result: TestResult):
        """Validate file expectations."""
        for file_spec in expected_files:
            path = file_spec['path']
            should_exist = file_spec.get('should_exist', True)

            if should_exist and not os.path.exists(path):
                result.fail(f"Expected file does not exist: {path}")
                continue

            if not should_exist and os.path.exists(path):
                result.fail(f"Expected file should not exist: {path}")
                continue

            # Content match
            if file_spec.get('content_match') is not None:
                if os.path.exists(path):
                    with open(path, 'r', encoding=file_spec.get('encoding', 'utf-8')) as f:
                        actual_content = f.read()

                    if actual_content != file_spec['content_match']:
                        result.fail(
                            f"File content mismatch for {path}:\n"
                            f"  Expected: {repr(file_spec['content_match'])}\n"
                            f"  Actual:   {repr(actual_content)}"
                        )

            # Regex match
            if file_spec.get('content_regex') is not None and os.path.exists(path):
                with open(path, 'r', encoding=file_spec.get('encoding', 'utf-8')) as f:
                    actual_content = f.read()

                if not re.search(file_spec['content_regex'], actual_content):
                    result.fail(f"File content regex '{file_spec['content_regex']}' did not match: {repr(actual_content)}")

    def _validate_assertions(self, assertions: List[Dict[str, Any]], actual: Dict[str, Any], result: TestResult):
        """Run programmatic assertions."""
        for assertion in assertions:
            self._check_assertion(assertion, actual, result)

    def _check_assertion(self, assertion: Dict[str, Any], actual: Dict[str, Any], result: TestResult):
        """Check a single assertion."""
        assert_type = assertion['type']

        if assert_type == 'exit_code':
            self._assert_exit_code(assertion, actual, result)
        elif assert_type == 'stdout_equals':
            self._assert_stdout_equals(assertion, actual, result)
        elif assert_type == 'stdout_contains':
            self._assert_stdout_contains(assertion, actual, result)
        elif assert_type == 'stderr_contains':
            self._assert_stderr_contains(assertion, actual, result)
        elif assert_type == 'file_exists':
            self._assert_file_exists(assertion, result)
        elif assert_type == 'file_not_exists':
            self._assert_file_not_exists(assertion, result)
        elif assert_type == 'file_content_equals':
            self._assert_file_content_equals(assertion, result)
        elif assert_type == 'file_empty':
            self._assert_file_empty(assertion, result)
        else:
            result.fail(f"Unknown assertion type: {assert_type}")

    def _assert_exit_code(self, assertion: Dict[str, Any], actual: Dict[str, Any], result: TestResult):
        """Assert exit code matches."""
        if actual['exit_code'] != assertion['expected_code']:
            result.fail(f"Assertion failed - exit_code: expected {assertion['expected_code']}, got {actual['exit_code']}")

    def _assert_stdout_equals(self, assertion: Dict[str, Any], actual: Dict[str, Any], result: TestResult):
        """Assert stdout equals."""
        if actual['stdout'] != assertion['expected']:
            result.fail(f"Assertion failed - stdout_equals")
            result.fail(f"  Expected: {repr(assertion['expected'])}")
            result.fail(f"  Actual:   {repr(actual['stdout'])}")

    def _assert_stdout_contains(self, assertion: Dict[str, Any], actual: Dict[str, Any], result: TestResult):
        """Assert stdout contains substring."""
        if assertion['expected_substring'] not in actual['stdout']:
            result.fail(f"Assertion failed - stdout_contains: '{assertion['expected_substring']}' not found")

    def _assert_stderr_contains(self, assertion: Dict[str, Any], actual: Dict[str, Any], result: TestResult):
        """Assert stderr contains substring."""
        if assertion['expected_substring'] not in actual['stderr']:
            result.fail(f"Assertion failed - stderr_contains: '{assertion['expected_substring']}' not found")

    def _assert_file_exists(self, assertion: Dict[str, Any], result: TestResult):
        """Assert file exists."""
        file_path = assertion['file_path']
        if not os.path.exists(file_path):
            result.fail(f"Assertion failed - file_exists: {file_path} does not exist")

    def _assert_file_not_exists(self, assertion: Dict[str, Any], result: TestResult):
        """Assert file does not exist."""
        file_path = assertion['file_path']
        if os.path.exists(file_path):
            result.fail(f"Assertion failed - file_not_exists: {file_path} exists but should not")

    def _assert_file_content_equals(self, assertion: Dict[str, Any], result: TestResult):
        """Assert file content equals."""
        file_path = assertion['file_path']
        expected_content = assertion['expected_content']

        if not os.path.exists(file_path):
            result.fail(f"Assertion failed - file_content_equals: {file_path} does not exist")
            return

        with open(file_path, 'r', encoding='utf-8') as f:
            actual_content = f.read()

        if actual_content != expected_content:
            result.fail(f"Assertion failed - file_content_equals for {file_path}")
            result.fail(f"  Expected: {repr(expected_content)}")
            result.fail(f"  Actual:   {repr(actual_content)}")

    def _assert_file_empty(self, assertion: Dict[str, Any], result: TestResult):
        """Assert file is empty."""
        file_path = assertion['file_path']

        if not os.path.exists(file_path):
            result.fail(f"Assertion failed - file_empty: {file_path} does not exist")
            return

        if os.path.getsize(file_path) > 0:
            result.fail(f"Assertion failed - file_empty: {file_path} is not empty")


def main():
    """Main entry point for golden test runner."""
    # Find the test file in various possible locations
    possible_test_files = [
        'golden_tests.json',
        'noodle-core/src/migration/examples/golden_tests.json',
        'src/migration/examples/golden_tests.json'
    ]

    test_file = None
    for possible in possible_test_files:
        if os.path.exists(possible):
            test_file = possible
            break

    if not test_file:
        print("No golden_tests.json found in any expected locations!")
        sys.exit(2)

    print(f"Loading golden tests from: {test_file}")

    runner = GoldenTestRunner(test_file)
    runner.load_tests()

    success = runner.run_tests()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()


