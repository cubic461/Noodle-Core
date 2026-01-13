# Python-to-Go Code Generation Design

## Overview

This document outlines the design for automatically generating Go code from Python source code, specifically for the migration use case demonstrated by `simple_file_processor.py` → `main.go`.

## Architecture

### Input: Python AST Analysis
```python
# Parse Python source into AST
import ast
with open('simple_file_processor.py') as f:
    tree = ast.parse(f.read())

# Extract:
# 1. Function signatures (process_csv)
# 2. Control flow patterns (with statements)
# 3. Standard library calls (open, readlines, writelines)
# 4. String operations (upper)
# 5. CLI argument parsing patterns
```

### Output: Go Template Generation
```go
// Rule-based transformation
template := generateGoFromPython(tree)
// Rules:
// - with open() → os.Open + defer file.Close()
// - readlines() → csv.NewReader + ReadAll()
// - writelines() → csv.NewWriter + WriteAll()
// - upper() → strings.ToUpper()
```

## Transformation Rules

### 1. File Operations

**Python:**
```python
with open(input_path, 'r') as f:
    lines = f.readlines()
```

**Go Equivalent:**
```go
file, err := os.Open(inputPath)
if err != nil {
    return 0, fmt.Errorf("error: %v", err)
}
defer file.Close()

reader := csv.NewReader(file)
records, err := reader.ReadAll()
if err != nil {
    return 0, fmt.Errorf("error: %v", err)
}
```

**Transformation Rule:**
```
Python "with open(...)" → Go "os.Open + error check + defer"
Python "readlines()" → Go "csv.NewReader + ReadAll()"
```

### 2. String Operations

**Python:**
```python
processed = [line.upper() for line in lines]
```

**Go Equivalent:**
```go
for i, record := range records {
    for j, field := range record {
        records[i][j] = strings.ToUpper(field)
    }
}
```

**Transformation Rule:**
```
Python "line.upper()" → Go "strings.ToUpper(field)"
List comprehension → Nested for loop
```

### 3. CLI Argument Parsing

**Python:**
```python
parser = argparse.ArgumentParser()
parser.add_argument('input_file', nargs='?', default='input.csv')
parser.add_argument('--verbose', '-v', action='store_true')
args = parser.parse_args()
```

**Go Equivalent:**
```go
var inputFile, verbose string
flag.StringVar(&inputFile, "input", "input.csv", "Input CSV file")
flag.StringVar(&inputFile, "i", "input.csv", "Input CSV file")
flag.BoolVar(&verbose, "verbose", false, "Verbose output")
flag.BoolVar(&verbose, "v", false, "Verbose output")
flag.Parse()
```

**Transformation Rule:**
```
argparse.ArgumentParser → flag.*Var
nargs='?' → flag.Args() processing
action='store_true' → flag.BoolVar
```

### 4. Error Handling

**Python:**
```python
try:
    count = process_csv(args.input_file, args.output_file)
except FileNotFoundError:
    print(f"Error: {e}", file=sys.stderr)
    return 1
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    return 2
```

**Go Equivalent:**
```go
count, err := ProcessCSV(inputFile, outputFile)
if err != nil {
    fmt.Fprintf(os.Stderr, "Error: %v\n", err)
    os.Exit(1)
}
```

**Transformation Rule:**
```
try-except → if err != nil + error return
FileNotFoundError → os.IsNotExist(err)
print(file=sys.stderr) → fmt.Fprintf(os.Stderr, ...)
```

## Code Generation Pipeline

### Stage 1: Python AST Extraction
```python
class PythonToGoConverter:
    def __init__(self, source_code):
        self.tree = ast.parse(source_code)
        self.imports = []
        self.functions = []
        self.cli_patterns = []

    def extract_functions(self):
        # Extract function definitions
        for node in ast.walk(self.tree):
            if isinstance(node, ast.FunctionDef):
                self.functions.append({
                    'name': node.name,
                    'args': [arg.arg for arg in node.args.args],
                    'body': ast.unparse(node.body)
                })

    def extract_operations(self):
        # Extract file operations, string operations, etc.
        for node in ast.walk(self.tree):
            if isinstance(node, ast.With):
                # File operation detected
                pass
```

### Stage 2: Pattern Matching
```python
class PatternMatcher:
    def match_patterns(self, function_body):
        patterns = []

        # Pattern 1: File operations
        if 'open(' in function_body and 'readlines' in function_body:
            patterns.append({
                'type': 'file_read',
                'pattern': 'with_open_readlines',
                'go_equivalent': 'os.Open_csv.NewReader_ReadAll'
            })

        # Pattern 2: String transformations
        if 'upper()' in function_body:
            patterns.append({
                'type': 'string_transform',
                'pattern': 'list_comprehension_upper',
                'go_equivalent': 'for_loop_strings.ToUpper'
            })

        # Pattern 3: CLI parsing
        if 'argparse' in function_body:
            patterns.append({
                'type': 'cli_parsing',
                'pattern': 'argparse',
                'go_equivalent': 'flag_package'
            })

        return patterns
```

### Stage 3: Go Template Generation
```python
class GoTemplateGenerator:
    def generate_from_patterns(self, patterns):
        template = []

        # Generate imports
        imports = set()
        for pattern in patterns:
            if 'os.Open' in pattern['go_equivalent']:
                imports.add('os')
                imports.add('encoding/csv')
            if 'strings.ToUpper' in pattern['go_equivalent']:
                imports.add('strings')
            if 'flag' in pattern['go_equivalent']:
                imports.add('flag')

        template.append('package main\n')
        template.append('import (')
        for imp in sorted(imports):
            template.append(f'\t"{imp}"')
        template.append(')\n\n')

        # Generate function template
        template.append('func ProcessCSV(inputPath string, outputPath string) (int, error) {')
        for pattern in patterns:
            if pattern['type'] == 'file_read':
                template.append('\t// Pattern: File operation (with open, readlines)')
                template.append('\tfile, err := os.Open(inputPath)')
                template.append('\tif err != nil { return 0, err }')
                template.append('\tdefer file.Close()')
                template.append('\treader := csv.NewReader(file)')
                template.append('\trecords, err := reader.ReadAll()')
                template.append('\tif err != nil { return 0, err }')
            elif pattern['type'] == 'string_transform':
                template.append('\t// Pattern: String transformation (uppercase)')
                template.append('\tfor i, record := range records {')
                template.append('\t\tfor j, field := range record {')
                template.append('\t\t\trecords[i][j] = strings.ToUpper(field)')
                template.append('\t\t}')
                template.append('\t}')
        template.append('\treturn len(records), nil')
        template.append('}\n')

        return '\n'.join(template)
```

## Example: Complete Transformation

### Input Python
```python
def process_csv(input_path: str, output_path: str) -> int:
    with open(input_path, 'r') as f:
        lines = f.readlines()

    processed = [line.upper() for line in lines]

    with open(output_path, 'w') as f:
        f.writelines(processed)

    return len(lines)
```

### Generated Go
```go
func ProcessCSV(inputPath string, outputPath string) (int, error) {
	// File read operation
	file, err := os.Open(inputPath)
	if err != nil {
		return 0, fmt.Errorf("error opening input file: %v", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	reader.FieldsPerRecord = -1
	records, err := reader.ReadAll()
	if err != nil {
		return 0, fmt.Errorf("error reading CSV: %v", err)
	}

	// String transformation
	for i, record := range records {
		for j, field := range record {
			records[i][j] = strings.ToUpper(field)
		}
	}

	// File write operation
	outFile, err := os.Create(outputPath)
	if err != nil {
		return 0, fmt.Errorf("error creating output file: %v", err)
	}
	defer outFile.Close()

	writer := csv.NewWriter(outFile)
	defer writer.Flush()

	err = writer.WriteAll(records)
	if err != nil {
		return 0, fmt.Errorf("error writing CSV: %v", err)
	}

	return len(records), nil
}
```

## CLI Support Matrix

### Go CLI Flag Patterns

**Pattern 1: Standard Flags (Extended Pattern)**
```go
// Best Practice: Define all flags explicitly
var (
    inputFile  = flag.String("input", "input.csv", "Input file path")
    outputFile = flag.String("output", "output.csv", "Output file path")
    verbose    = flag.Bool("verbose", false, "Enable verbose output")
)
```

**Pattern 2: Flag with Short Options**
```go
// Best Practice: Provide short and long forms
flag.StringVar(&inputFile, "input", "input.csv", "Input file path")
flag.StringVar(&inputFile, "i", "input.csv", "Input file path (short)")

flag.BoolVar(&verbose, "verbose", false, "Verbose output")
flag.BoolVar(&verbose, "v", false, "Verbose output (short)")
```

**Pattern 3: Positional Arguments (with Flag Compatibility)**
```go
// Support both flag-style and positional arguments
flag.Parse()

// Check for positional arguments
args := flag.Args()
if len(args) > 0 {
    inputFile = args[0]
}
if len(args) > 1 {
    outputFile = args[1]
}
```

### Code Generation Rules

```
Python argparse → Go flag

Rule 1: Argument types
  argparse positional → flag.String() + flag.Args() handling
  argparse --flag → flag.Bool() / flag.String()

Rule 2: Default values
  default='value' → flag.*Var(..., default_value, ...)

Rule 3: Help text
  help='description' → usage parameter

Rule 4: Short options
  -v → flag.BoolVar(..., "v", ...)

Rule 5: Required vs optional
  nargs='?' → Optional, check flag.Args()
  nargs=None → Required, add validation
```

## Testing Strategy

### Unit Tests for Transformations

```python
import unittest

class TestPythonToGo(unittest.TestCase):
    def test_file_read_pattern(self):
        python_code = """
        with open(path, 'r') as f:
            lines = f.readlines()
        """
        expected_pattern = 'file_read'
        pattern = PatternMatcher().match_patterns(python_code)
        self.assertEqual(pattern[0]['type'], expected_pattern)

    def test_string_uppercase_pattern(self):
        python_code = "[line.upper() for line in lines]"
        expected_pattern = 'string_transform'
        pattern = PatternMatcher().match_patterns(python_code)
        self.assertEqual(pattern[0]['type'], expected_pattern)

if __name__ == '__main__':
    unittest.main()
```

### Integration Test

```python
def test_full_pipeline():
    # Read original Python file
    with open('simple_file_processor.py') as f:
        python_code = f.read()

    # Convert to AST
    converter = PythonToGoConverter(python_code)
    converter.extract_functions()

    # Generate patterns
    patterns = []
    for func in converter.functions:
        patterns.extend(converter.match_patterns(func['body']))

    # Generate Go code
    generator = GoTemplateGenerator()
    go_code = generator.generate_from_patterns(patterns)

    # Assertions
    assert 'package main' in go_code
    assert 'func ProcessCSV' in go_code
    assert 'os.Open' in go_code
    assert 'csv.NewReader' in go_code
    assert 'strings.ToUpper' in go_code

    # Write generated file
    with open('generated_main.go', 'w') as f:
        f.write(go_code)

    print("Integration test completed!")
```

## Next Steps

1. **Implement Pattern Matching Engine**
   - Build comprehensive pattern library
   - Support nested patterns (e.g., file operations inside loops)

2. **Add More Transformation Rules**
   - Database operations (sqlite3 → database/sql)
   - HTTP servers (Flask → net/http)
   - JSON processing (json → encoding/json)

3. **Improve Error Handling**
   - Add context-aware error messages
   - Suggest Go equivalents for Python idioms

4. **Enhance Code Quality**
   - Generate idiomatic Go code
   - Add comments linking back to Python patterns
   - Include usage examples

5. **Build CLI Tool**
   - `python-to-go convert input.py output.go`
   - Interactive mode for complex cases
   - Batch conversion for entire projects
