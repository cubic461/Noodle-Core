# Golden Test Format Specification

## Overview
Golden tests capture expected behavior of file processing operations by recording:
- Input/output pairs
- Expected side effects (file operations, system calls)
- Assertions about data transformations
- Execution metadata

## Schema

```json
{
  "version": "1.0",
  "test_name": "string",
  "description": "string",
  "language": "python|nc|js|...",
  
  "setup": {
    "create_files": [
      {
        "path": "input/data.txt",
        "content": "file contents or null for binary",
        "encoding": "utf-8|binary|base64"
      }
    ],
    "environment": {
      "variables": {"KEY": "value"},
      "working_directory": "."
    },
    "preconditions": ["file_exists:input/data.txt", "directory_empty:output"]
  },
  
  "execution": {
    "command": ["python", "process.py", "input/data.txt"],
    "timeout_seconds": 30,
    "expected_exit_code": 0
  },
  
  "assertions": {
    "files_created": [
      {
        "path": "output/result.txt",
        "optional": false,
        "content_type": "text|binary|json|..."
      }
    ],
    "files_modified": [
      {
        "path": "output/result.txt",
        "checks": [
          {
            "type": "exact_match|regex_match|contains|json_schema|file_hash",
            "expected": "expected content or pattern"
          },
          {
            "type": "line_count",
            "expected": 100,
            "tolerance": 5
          }
        ]
      }
    ],
    "stdout": {
      "checks": [
        {
          "type": "contains|exact_match|regex",
          "expected": "Expected output string"
        }
      ]
    },
    "stderr": {
      "checks": [
        {
          "type": "is_empty",
          "expected": true
        }
      ]
    },
    "file_operations": [
      {
        "type": "read|write|delete",
        "path": "input/data.txt",
        "count": {"min": 1, "max": 1}
      }
    ]
  },
  
  "teardown": {
    "cleanup_files": ["output/result.txt"],
    "preserve_on_failure": false
  },
  
  "metadata": {
    "created": "2025-12-14T00:00:00Z",
    "last_updated": "2025-12-14T00:00:00Z",
    "tags": ["unit", "integration", "regression"]
  }
}
```

## Example Test Cases

### Simple Text Processing
```json
{
  "version": "1.0",
  "test_name": "uppercase_converter",
  "description": "Converts text file to uppercase",
  "language": "python",
  
  "setup": {
    "create_files": [
      {
        "path": "input/text.txt",
        "content": "hello world\nthis is a test\n",
        "encoding": "utf-8"
      }
    ],
    "environment": {
      "working_directory": "."
    }
  },
  
  "execution": {
    "command": ["python", "uppercase.py", "input/text.txt", "output/result.txt"],
    "timeout_seconds": 10,
    "expected_exit_code": 0
  },
  
  "assertions": {
    "files_created": [
      {
        "path": "output/result.txt",
        "optional": false
      }
    ],
    "files_modified": [
      {
        "path": "output/result.txt",
        "checks": [
          {
            "type": "exact_match",
            "expected": "HELLO WORLD\nTHIS IS A TEST\n"
          }
        ]
      }
    ]
  }
}
```

### Binary File Processing
```json
{
  "version": "1.0",
  "test_name": "image_thumbnail_generator",
  "description": "Generates thumbnail from image",
  "language": "python",
  
  "setup": {
    "create_files": [
      {
        "path": "input/image.jpg",
        "content": null,
        "encoding": "binary",
        "note": "Use base64 or file hash for binary data"
      }
    ]
  },
  
  "execution": {
    "command": ["python", "thumbnail.py", "--size", "128x128", "input/image.jpg"],
    "expected_exit_code": 0
  },
  
  "assertions": {
    "files_created": [
      {
        "path": "input/image_thumb.jpg",
        "optional": false
      }
    ],
    "files_modified": [
      {
        "path": "input/image_thumb.jpg",
        "checks": [
          {
            "type": "file_size",
            "expected": {"min": 1000, "max": 10000}
          },
          {
            "type": "file_hash",
            "expected": "a1b2c3d4e5f6...",
            "algorithm": "sha256"
          }
        ]
      }
    ]
  }
}
```

### Side Effects and I/O Operations
```json
{
  "version": "1.0",
  "test_name": "csv_processor_side_effects",
  "description": "Validates CSV processing with I/O logging",
  "language": "python",
  
  "setup": {
    "create_files": [
      {
        "path": "input/data.csv",
        "content": "name,age,city\nAlice,25,NYC\nBob,30,LA",
        "encoding": "utf-8"
      }
    ],
    "preconditions": ["file_exists:input/data.csv"]
  },
  
  "execution": {
    "command": ["python", "process_csv.py", "input/data.csv"],
    "expected_exit_code": 0
  },
  
  "assertions": {
    "file_operations": [
      {
        "type": "read",
        "path": "input/data.csv",
        "count": {"min": 1, "max": 10}
      },
      {
        "type": "write",
        "path": "output/processed.csv",
        "count": {"min": 1, "max": 5}
      }
    ],
    "stdout": {
      "checks": [
        {
          "type": "contains",
          "expected": "Processed 2 records"
        }
      ]
    }
  }
}
```

## Assertion Types

### File Content Assertions
- `exact_match`: Content must exactly match expected string
- `contains`: Content must contain substring
- `regex_match`: Content must match regular expression
- `json_schema`: JSON content must validate against schema
- `line_count`: File must have specific number of lines (with tolerance)
- `file_size`: File size in bytes (min/max range)

### Binary Assertions
- `file_hash`: SHA-256/MD5 hash of file content
- `file_size`: Size range validation

### I/O Operation Assertions
- Count specific file operations (read/write/delete)
- Validate operation order
- Check access patterns

### Output Assertions
- `stdout`: Standard output checks
- `stderr`: Error output checks
- `exit_code`: Process exit code validation

## Integration with Trace Format

The golden test format can be generated from `Trace` objects:

```python
def trace_to_golden_test(trace: Trace) -> GoldenTest:
    """Convert a trace to golden test format."""
    golden = {
        "version": "1.0",
        "test_name": trace.trace_id,
        "language": trace.language,
        "execution": {
            "command": trace.command,
            "expected_exit_code": trace.exit_code
        },
        "assertions": {
            "file_operations": []
        }
    }
    
    # Extract I/O operations
    for io_op in trace.io_log:
        if io_op.operation in ['read', 'write', 'delete']:
            golden["assertions"]["file_operations"].append({
                "type": io_op.operation,
                "path": io_op.path,
                "success": io_op.success
            })
    
    return golden
```

## Usage in Testing Framework

```python
# Generate golden test from successful run
golden_test = capture_execution_as_golden(
    command=["python", "processor.py", "input.txt"],
    test_name="basic_processing"
)

# Run regression test
results = run_golden_test(golden_test)
if results.failed:
    # Show diff
    print(f"Expected: {results.expected}")
    print(f"Actual: {results.actual}")
```
