# Go Migration Template

A template and reference implementation for migrating Python CLI tools to Go, based on best practices research and the `simple_file_processor.py` example.

## Research: Go CLI Best Practices

This template incorporates insights from analyzing three major Go CLI libraries:

### 1. Standard `flag` Package (Used in this template)

**Strengths:**
- Part of Go standard library (no external dependencies)
- Simple and reliable
- Familiar to all Go developers
- Good for straightforward CLIs

**Usage Pattern:**
```go
var verbose bool
var inputFile string

flag.BoolVar(&verbose, "v", false, "Verbose output")
flag.StringVar(&inputFile, "input", "default.csv", "Input file")
flag.Parse()
```

**When to Use:**
- Simple CLIs with < 10 flags
- Standard argument patterns
- Minimal external dependencies desired

### 2. Cobra Framework (Enterprise Standard)

**Strengths:**
- Used by Kubernetes, Hugo, GitHub CLI
- Powerful: subcommands, aliases, shell completion
- Built-in help generation
- Integrates with Viper for config

**Usage Pattern:**
```go
var rootCmd = &cobra.Command{
    Use:   "csv-processor",
    Short: "Process CSV files",
    Run: func(cmd *cobra.Command, args []string) {
        // Implementation
    },
}

func main() {
    rootCmd.Execute()
}
```

**When to Use:**
- Complex CLIs with subcommands
- Need shell completion
- Enterprise-grade applications

### 3. urfave/cli (Developer-Friendly)

**Strengths:**
- Elegant API
- Built-in help and Bash completion
- Good for rapid development

**Usage Pattern:**
```go
app := &cli.App{
    Name:  "csv-processor",
    Usage: "Process CSV files",
    Action: func(c *cli.Context) error {
        input := c.String("input")
        // Implementation
        return nil
    },
}
```

**When to Use:**
- Modern CLI design
- Rapid development
- Prefer functional API over struct-based

## Analysis: `simple_file_processor.py`

### Python Implementation Pattern Analysis

```python
def process_csv(input_path: str, output_path: str) -> int:
    # Pattern 1: File read with context manager
    with open(input_path, 'r') as f:
        lines = f.readlines()

    # Pattern 2: List comprehension with string transformation
    processed = [line.upper() for line in lines]

    # Pattern 3: File write with context manager
    with open(output_path, 'w') as f:
        f.writelines(processed)

    return len(lines)
```

**Key Patterns Identified:**
1. `with open()` → Go `os.Open() + defer`
2. `readlines()` → Go `csv.NewReader + ReadAll()`
3. `upper()` → Go `strings.ToUpper()`
4. `writelines()` → Go `csv.NewWriter + WriteAll()`
5. `argparse` → Go `flag` package
6. `try-except` → Go `if err != nil`

## Go Template Structure

### Files

```
go-migration-template/
├── go.mod              # Module definition and dependencies
├── main.go             # Main implementation with best practices
├── Makefile            # Convenient build/run commands
├── CODE_GENERATION_DESIGN.md  # Design for auto-generation system
└── README.md           # This file
```

### Key Features

1. **Error Handling**: All operations return error and check immediately
2. **Resource Management**: Proper `defer` for file closing
3. **CSV Processing**: Using encoding/csv for proper CSV handling
4. **Flag Compatibility**: Supports both flag syntax and positional args
5. **Verbosity Levels**: Verbose flag with detailed output

### How to Use

**Build:**
```bash
make build
```

**Run:**
```bash
# Using flags
./csv-processor -input input.csv -output output.csv -verbose

# Short flags
./csv-processor -i input.csv -o output.csv -v

# Positional arguments (compatible with Python CLI)
./csv-processor input.csv output.csv
```

**Test:**
```bash
make test
```

## Code Generation Design

See [CODE_GENERATION_DESIGN.md](CODE_GENERATION_DESIGN.md) for detailed architecture on automatically generating Go code from Python source.

### Transformation Pipeline

```
Python Source Code
    ↓
AST Analysis
    ↓
Pattern Matching (file ops, string ops, CLI parsing)
    ↓
Go Template Generation
    ↓
Generated Go Code
```

### Supported Transformations

| Python Pattern | Go Equivalent | Status |
|----------------|---------------|---------|
| `with open() as f` | `os.Open() + defer` | ✅ |
| `readlines()` | `csv.NewReader + ReadAll()` | ✅ |
| `write()` | `csv.NewWriter + WriteAll()` | ✅ |
| `upper()` | `strings.ToUpper()` | ✅ |
| `argparse` | `flag` package | ✅ |
| `try-except` | `if err != nil` | ✅ |
| `sys.exit()` | `os.Exit()` | ✅ |

## Best Practices Implemented

1. **Flag Package Usage**
   - Long and short options provided
   - Sensible defaults
   - Good help text

2. **Error Handling**
   - Explicit error returns
   - Meaningful error messages
   - Proper exit codes

3. **Resource Management**
   - `defer` for cleanup
   - No resource leaks

4. **CSV Processing**
   - Uses standard library
   - Handles variable fields per record
   - Proper encoding/decoding

5. **CLI Design**
   - Compatible with original Python CLI
   - Verbose mode for debugging
   - Standard output/error usage

## Migration Checklist

When migrating Python CLI tools to Go:

- [ ] Analyze original Python patterns
- [ ] Choose appropriate CLI library (flag/cobra/urfave)
- [ ] Map file operations (context managers → os.Open + defer)
- [ ] Convert argument parsing (argparse → flag)
- [ ] Handle error patterns (try-except → if err != nil)
- [ ] Preserve command-line compatibility
- [ ] Test with existing scripts/automation
- [ ] Update documentation and examples

## Example: Side-by-Side Comparison

### Original Python
```python
import sys
import argparse

def process_csv(input_path: str, output_path: str) -> int:
    with open(input_path, 'r') as f:
        lines = f.readlines()

    processed = [line.upper() for line in lines]

    with open(output_path, 'w') as f:
        f.writelines(processed)

    return len(lines)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file', nargs='?', default='input.csv')
    parser.add_argument('output_file', nargs='?', default='output.csv')
    parser.add_argument('--verbose', '-v', action='store_true')

    args = parser.parse_args()

    try:
        count = process_csv(args.input_file, args.output_file)
        if args.verbose:
            print(f"Successfully processed {count} lines")
        print(f"Processed {count} lines")
        return 0
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
```

### Migrated Go
```go
package main

import (
    "encoding/csv"
    "flag"
    "fmt"
    "os"
    "strings"
)

func ProcessCSV(inputPath string, outputPath string) (int, error) {
    file, err := os.Open(inputPath)
    if err != nil {
        return 0, fmt.Errorf("error opening input file: %v", err)
    }
    defer file.Close()

    reader := csv.NewReader(file)
    records, err := reader.ReadAll()
    if err != nil {
        return 0, fmt.Errorf("error reading CSV: %v", err)
    }

    for i, record := range records {
        for j, field := range record {
            records[i][j] = strings.ToUpper(field)
        }
    }

    outFile, err := os.Create(outputPath)
    if err != nil {
        return 0, fmt.Errorf("error creating output file: %v", err)
    }
    defer outFile.Close()

    writer := csv.NewWriter(outFile)
    defer writer.Flush()

    if err := writer.WriteAll(records); err != nil {
        return 0, fmt.Errorf("error writing CSV: %v", err)
    }

    return len(records), nil
}

func main() {
    var verbose bool
    var inputFile, outputFile string

    flag.StringVar(&inputFile, "input", "input.csv", "Input CSV file")
    flag.StringVar(&inputFile, "i", "input.csv", "Input CSV file (short)")
    flag.StringVar(&outputFile, "output", "output.csv", "Output CSV file")
    flag.StringVar(&outputFile, "o", "output.csv", "Output CSV file (short)")
    flag.BoolVar(&verbose, "verbose", false, "Verbose output")
    flag.BoolVar(&verbose, "v", false, "Verbose output (short)")
    flag.Parse()

    args := flag.Args()
    if len(args) > 0 {
        inputFile = args[0]
    }
    if len(args) > 1 {
        outputFile = args[1]
    }

    count, err := ProcessCSV(inputFile, outputFile)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)
    }

    if verbose {
        fmt.Printf("Successfully processed %d lines\n", count)
        fmt.Printf("Input:  %s\n", inputFile)
        fmt.Printf("Output: %s\n", outputFile)
    } else {
        fmt.Printf("Processed %d lines\n", count)
    }

    os.Exit(0)
}
```

## Next Steps

1. **Use this template** for similar Python → Go migrations
2. **Study the design doc** for building automated conversion tools
3. **Extend patterns** for more complex operations (database, HTTP, JSON)
4. **Contribute** additional transformation rules

## References

- [Go flag package](https://pkg.go.dev/flag)
- [Cobra Framework](https://github.com/spf13/cobra)
- [urfave/cli](https://github.com/urfave/cli)
- [csv package](https://pkg.go.dev/encoding/csv)
- [Effective Go](https://go.dev/doc/effective_go)
