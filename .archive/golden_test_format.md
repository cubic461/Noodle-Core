# Golden Test Format Specification

## Overview

A **golden test** is a type of regression test that captures the expected behavior of a program by recording both its inputs and correct outputs. Golden tests are particularly valuable for:

- Ensuring consistent behavior across refactoring or migration
- Detecting unintended side effects or regressions
- Documenting expected behavior in a machine-readable format
- Validating program behavior against a known-good baseline

This document defines the JSON format for golden tests.

## Version

**Current Version:** 1.0.0

---

## Schema

### Root Object

```json
{
  "test_suite_name": "string",
  "format_version": "string",
  "description": "string",
  "test_runners": [...],  // Optional
  "tests": [...],
  "metadata": {...}
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `test_suite_name` | string | Name of the test suite (e.g., "simple_file_processor_tests") |
| `format_version` | string | Version of the golden test format (e.g., "1.0.0") |
| `description` | string | Human-readable description of what the test suite covers |
| `test_runners` | array | Optional: Available test runners/platforms |
| `tests` | array | List of test cases to execute |
| `metadata` | object | Suite-level metadata (author, timestamps, etc.) |

---

## Test Runner Object

Defines how tests can be executed on different platforms.

```json
{
  "language": "string",          // e.g., "python", "go", "javascript"
  "command_template": "string",  // Template for running tests
  "env_vars": {...}             // Optional environment variables
}
```

---

## Test Case Object

A single test case within the suite.

### Structure

```json
{
  "test_id": "string",
  "description": "string",
  "enabled": true|false,
  "priority": "low|medium|high",
  "tags": ["string", ...],
  "setup": {...},
  "input": {...},
  "expected_output": {...},
  "expected_files": [...],
  "assertions": [...],
  "cleanup": {...}
}
```

### Test Case Fields

| Field | Type | Description |
|-------|------|-------------|
| `test_id` | string | Unique identifier for the test (machine-readable) |
| `description` | string | Human-readable description of test case |
| `enabled` | boolean | Whether the test is active (default: `true`) |
| `priority` | enum | Importance of the test: `"low"`, `"medium"`, `"high"` |
| `tags` | array | Labels for categorizing tests (e.g., ["functional", "error_handling"]) |
| `setup` | object | Test preparation actions |
| `input` | object | Execution parameters (command, working dir, etc.) |
| `expected_output` | object | Expected stdout, stderr, exit code |
| `expected_files` | array | Expected file creations or modifications |
| `assertions` | array | Programmatic checks to perform |
| `cleanup` | object | Post-test cleanup actions |

---

## Setup Object

Actions to perform before test execution.

```json
{
  "create_files": [
    {
      "path": "string",
      "content": "string",
      "encoding": "utf-8|..."
    }
  ],
  "delete_files": ["string"],
  "create_dirs": ["string"],
  "delete_dirs": ["string"],
  "environment": {"VAR": "value", ...},
  "timeout_seconds": 10
}
```

---

## Input Object

Defines how to execute the program under test.

```json
{
  "command": ["string", ...],
  "working_dir": "string",
  "stdin": "string|null",
  "timeout_seconds": 10,
  "environment": {"VAR": "value", ...}
}
```

### Input Fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | array | Command to execute (including arguments) |
| `working_dir` | string | Working directory for command execution |
| `stdin` | string/null | Standard input data (or `null` for no stdin) |
| `timeout_seconds` | number | Maximum time to wait before failing test |
| `environment` | object | Environment variables to set for the process |

---

## Expected Output Object

Defines what output the program should produce.

```json
{
  "exit_code": 0,
  "stdout": "string",
  "stderr": "string",
  "stdout_regex": "string|null",
  "stderr_regex": "string|null",
  "partial_match": true|false
}
```

### Expected Output Fields

| Field | Type | Description |
|-------|------|-------------|
| `exit_code` | number | Expected exit/return code |
| `stdout` | string | Expected standard output content (exact match) |
| `stderr` | string | Expected standard error content (exact match) |
| `stdout_regex` | string/null | Pattern to match against stdout; overrides `stdout` if set |
| `stderr_regex` | string/null | Pattern to match against stderr; overrides `stderr` if set |
| `partial_match` | boolean | If `true`, stdout/stderr may contain additional text |

---

## Expected Files Object

Defines files that should exist after execution and their content expectations.

```json
{
  "path": "string",
  "should_exist": true|false,
  "content_match": "string|null",
  "content_regex": "string|null",
  "encoding": "utf-8|...",
  "size_bytes": 1024,
  "permissions": "644|755|...",
  "created": true|false,
  "modified": true|false
}
```

### Expected Files Fields

| Field | Type | Description |
|-------|------|-------------|
| `path` | string | Absolute or relative file path to check |
| `should_exist` | boolean | Whether the file must exist after execution |
| `content_match` | string/null | Exact content the file must contain |
| `content_regex` | string/null | Pattern to match against file content |
| `encoding` | string | File encoding (default: `"utf-8"`) |
| `size_bytes` | number | Expected file size in bytes |
| `permissions` | string | File permissions (Unix-style, e.g., `"644"`) |
| `created` | boolean | File should be created during execution |
| `modified` | boolean | File should be modified during execution |

---

## Assertions Object

Programmatic checks to perform after execution. Each assertion has a `type` and `parameters`.

### Supported Assertion Types

| Type | Parameters | Description |
|------|-----------|-------------|
| `exit_code` | `"expected_code": number` | Check process exit code |
| `stdout_equals` | `"expected": string` | Exact stdout content match |
| `stdout_contains` | `"expected_substring": string` | Substring search in stdout |
| `stdout_regex` | `"pattern": string` | Regex match against stdout |
| `stderr_equals` | `"expected": string` | Exact stderr content match |
| `stderr_contains` | `"expected_substring": string` | Substring search in stderr |
| `file_exists` | `"file_path": string` | Assert file exists |
| `file_not_exists` | `"file_path": string` | Assert file does not exist |
| `file_content_equals` | `"file_path": string`, `"expected_content": string` | Exact file content match |
| `file_content_regex` | `"file_path": string`, `"pattern": string` | Regex match against file content |
| `file_empty` | `"file_path": string` | Assert file is empty |
| `file_size_equals` | `"file_path": string`, `"expected_size_bytes": number` | Exact file size match |
| `file_permissions` | `"file_path": string`, `"expected_permissions": string` | Check file permissions (Unix) |
| `directory_exists` | `"directory_path": string` | Assert directory exists |
| `file_count_in_dir` | `"directory": string`, `"pattern": string`, `"expected_count": number` | Count files matching pattern |

---

## Cleanup Object

Actions to perform after test execution (success or failure).

```json
{
  "delete_files": ["string"],
  "delete_dirs": ["string"],
  "preserve_on_failure": ["string"]
}
```

### Cleanup Fields

| Field | Type | Description |
|-------|------|-------------|
| `delete_files` | array | Files to remove after the test |
| `delete_dirs` | array | Directories to recursively remove |
| `preserve_on_failure` | array | Artifacts to keep if the test fails |

---

## Metadata Object

Suite-level information about authorship, dates, etc.

```json
{
  "created_by": "string",
  "created_date": "YYYY-MM-DD",
  "last_modified": "YYYY-MM-DD",
  "target_script": "string",
  "notes": "string"
}
```

---

## Trace Format Integration

The golden test format is designed to work with the **trace format** used for execution capture:

```python
# From trace_format.py
@dataclass
class Trace:
    trace_id: str
    language: str
    command: List[str]
    working_dir: str
    start_time: float
    end_time: Optional[float]
    events: List[TraceEvent]
    call_graph: List[CallFrame]
    io_log: List[IOLog]
    cpu_time: Optional[float]
    peak_memory: Optional[int]
    exit_code: Optional[int]
    termination_reason: Optional[str]
```

### Relationship

- **Golden Test Input** → **Trace Execution** → **Golden Test Output**
- A golden test can be "recorded" from a trace that passes manually.
- A golden test can be "verified" by re-running the test and comparing output to expectations.
- The `command`, `working_dir`, and `environment` from `input` are used to execute the trace.

---

## Test Execution Flow

1. **Setup Phase**
   - Create input files defined in `setup.create_files`
   - Create directories defined in `setup.create_dirs`
   - Delete any files/dirs specified in `setup.delete_files` or `setup.delete_dirs`
   - Set environment variables from `setup.environment`

2. **Execution Phase**
   - Execute `input.command` in `input.working_dir`
   - Provide `input.stdin` to the process (if specified)
   - Capture stdout, stderr, and exit code

3. **Validation Phase**
   - Compare actual exit code vs `expected_output.exit_code`
   - Compare actual stdout vs `expected_output.stdout` (or regex if `stdout_regex` set)
   - Compare actual stderr vs `expected_output.stderr` (or regex if `stderr_regex` set)
   - Verify file existence/content matches `expected_files` entries
   - Execute all assertions in `assertions`

4. **Cleanup Phase**
   - Clean up files/dirs defined in `cleanup.delete_files` and `cleanup.delete_dirs`

---

## Example Golden Test

```json
{
  "test_suite_name": "csv_processor_tests",
  "format_version": "1.0.0",
  "description": "Tests for CSV file processor with uppercasing transformation",
  "tests": [
    {
      "test_id": "basic_processing",
      "description": "Basic CSV processing with uppercasing",
      "enabled": true,
      "priority": "high",
      "tags": ["functional", "basic"],
      "setup": {
        "create_files": [
          {
            "path": "input.csv",
            "content": "name,email\nalice,alice@example.com\nbob,bob@example.com"
          }
        ],
        "delete_files": ["output.csv"],
        "environment": {}
      },
      "input": {
        "command": ["python", "processor.py", "input.csv", "output.csv"],
        "working_dir": ".",
        "stdin": null,
        "timeout_seconds": 10
      },
      "expected_output": {
        "exit_code": 0,
        "stdout": "Processed 2 lines\n",
        "stderr": "",
        "stdout_regex": null,
        "stderr_regex": null,
        "partial_match": false
      },
      "expected_files": [
        {
          "path": "output.csv",
          "should_exist": true,
          "content_match": "NAME,EMAIL\nALICE,ALICE@EXAMPLE.COM\nBOB,BOB@EXAMPLE.COM",
          "content_regex": null,
          "encoding": "utf-8"
        }
      ],
      "assertions": [
        {
          "type": "exit_code",
          "expected_code": 0
        },
        {
          "type": "file_content_equals",
          "file_path": "output.csv",
          "expected_content": "NAME,EMAIL\nALICE,ALICE@EXAMPLE.COM\nBOB,BOB@EXAMPLE.COM"
        }
      ],
      "cleanup": {
        "delete_files": ["input.csv", "output.csv"],
        "delete_dirs": []
      }
    }
  ],
  "metadata": {
    "created_by": "System",
    "created_date": "2025-12-14",
    "target_script": "processor.py"
  }
}
```

---

## Implementation Notes

### Recording vs. Verifying

- **Recording**: Execute code, capture trace, and generate golden test JSON (manual approval required).
- **Verifying**: Execute code, capture trace, and compare against golden test expectations.

### Delta Detection

When a test fails:
- Report exact mismatches (e.g., "Expected 'A', got 'B'")
- Suggest updating golden test if the actual behavior is correct
- Capture actual results as candidates for gold

### Generators and Regression

- Generate golden tests before migration to capture current behavior
- Run golden tests post-migration to validate behavior preservation
- Manually approve any diffs that are intentional behavior changes

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-14 | Initial specification |

---

## TODO / Future Improvements

- [ ] Add support for network I/O expectations
- [ ] Add support for timing assertions (execution time budgets)
- [ ] Add support for performance benchmarking expectations
- [ ] Add support for Windows vs. Unix path normalization
- [ ] Add support for optional/conditional assertions
- [ ] Add support for retry logic in case of flaky tests
- [ ] Define a trace-to-golden-test converter tool

---

## License

This golden test format is part of the Noodle project and follows the project's license.
