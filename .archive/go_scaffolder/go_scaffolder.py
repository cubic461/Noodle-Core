#!/usr/bin/env python3
"""
Go Scaffolder::Go Scaffolder - go_scaffolder.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Go Scaffolder - Translate Python CLI tools to idiomatic Go code

This module analyzes Python scripts and generates Go code scaffolds that
maintain the same interface and behavior while leveraging Go's type safety
and performance benefits.
"""

import ast
import os
import re
import json
import textwrap
from pathlib import Path
from typing import List, Dict, Tuple, Optional, Set, Any
from dataclasses import dataclass, field
from jinja2 import Template
import argparse


@dataclass
class PythonArg:
    """Represents a Python function argument."""
    name: str
    type: Optional[str] = None
    default: Optional[str] = None
    is_kwarg: bool = False


@dataclass
class FunctionInfo:
    """Information about a Python function."""
    name: str
    args: List[PythonArg] = field(default_factory=list)
    return_type: Optional[str] = None
    docstring: Optional[str] = None
    is_main: bool = False
    has_file_ops: bool = False


@dataclass
class ImportInfo:
    """Information about imported modules."""
    module: str
    alias: Optional[str] = None
    imports: List[str] = field(default_factory=list)


@dataclass
class FileOperation:
    """Represents a file operation found in the script."""
    operation: str  # 'open', 'read', 'write', 'csv_read', 'csv_write', 'json_load', 'json_dump'
    path: str
    mode: Optional[str] = None
    context: str = ""  # Where this operation occurs


@dataclass
class ScriptAnalysis:
    """Complete analysis of a Python script."""
    script_path: str
    functions: List[FunctionInfo] = field(default_factory=list)
    imports: List[ImportInfo] = field(default_factory=list)
    main_args: List[str] = field(default_factory=list)
    file_operations: List[FileOperation] = field(default_factory=list)
    uses_argparse: bool = False
    uses_csv: bool = False
    uses_json: bool = False
    uses_sys: bool = False
    uses_os: bool = False
    
    def get_main_function(self) -> Optional[FunctionInfo]:
        """Get the main function if it exists."""
        for func in self.functions:
            if func.is_main:
                return func
        return None


class PythonAnalyzer(ast.NodeVisitor):
    """AST visitor to analyze Python scripts."""
    
    def __init__(self, script_path: str):
        self.analysis = ScriptAnalysis(script_path=script_path)
        self.current_function = None
        self.function_stack = []
        
    def visit_Import(self, node: ast.Import) -> None:
        """Handle import statements."""
        for alias in node.names:
            import_info = ImportInfo(
                module=alias.name,
                alias=alias.asname
            )
            self.analysis.imports.append(import_info)
            
            # Track common modules
            if alias.name == 'csv':
                self.analysis.uses_csv = True
            elif alias.name == 'json':
                self.analysis.uses_json = True
            elif alias.name == 'os':
                self.analysis.uses_os = True
        
        self.generic_visit(node)
    
    def visit_ImportFrom(self, node: ast.ImportFrom) -> None:
        """Handle from...import statements."""
        if node.module:
            for alias in node.names:
                import_info = ImportInfo(
                    module=node.module,
                    alias=alias.asname if alias.asname else alias.name,
                    imports=[alias.name]
                )
                self.analysis.imports.append(import_info)
                
                # Track specific imports
                if node.module == 'sys' and alias.name == 'argv':
                    self.analysis.uses_sys = True
                elif node.module == 'argparse':
                    self.analysis.uses_argparse = True
        
        self.generic_visit(node)
    
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Handle function definitions."""
        func_info = FunctionInfo(name=node.name)
        
        # Track function context
        self.function_stack.append(func_info)
        self.current_function = func_info
        
        # Process arguments
        args = node.args
        defaults = [ast.unparse(d) for d in args.defaults] if args.defaults else []
        default_offset = len(args.args) - len(defaults)
        
        for i, arg in enumerate(args.args):
            default = None
            if i >= default_offset:
                default = defaults[i - default_offset]
            
            arg_info = PythonArg(
                name=arg.arg,
                default=default
            )
            func_info.args.append(arg_info)
        
        # Get return type hint if available
        if node.returns:
            func_info.return_type = ast.unparse(node.returns)
        
        # Check for docstring
        if ast.get_docstring(node):
            func_info.docstring = ast.get_docstring(node)
        
        # Check if this is main function
        if node.name == 'main':
            func_info.is_main = True
        
        self.generic_visit(node)
        
        # Add to analysis
        self.analysis.functions.append(func_info)
        
        # Pop function context
        self.function_stack.pop()
        self.current_function = self.function_stack[-1] if self.function_stack else None
    
    def visit_Call(self, node: ast.Call) -> None:
        """Handle function calls to detect file operations."""
        func_name = ast.unparse(node.func)
        
        # Detect file operations
        if 'open' in func_name and self.current_function:
            self.current_function.has_file_ops = True
            
            # Extract file path if it's a string literal
            if len(node.args) > 0:
                if isinstance(node.args[0], ast.Constant) and isinstance(node.args[0].value, str):
                    path = node.args[0].value
                    mode = 'r'
                    if len(node.args) > 1 and isinstance(node.args[1], ast.Constant):
                        mode = node.args[1].value
                    
                    file_op = FileOperation(
                        operation='open',
                        path=path,
                        mode=mode,
                        context=self.current_function.name
                    )
                    self.analysis.file_operations.append(file_op)
        
        self.generic_visit(node)


class GoScaffolder:
    """Generate Go code from Python script analysis."""
    
    def __init__(self, analysis: ScriptAnalysis):
        self.analysis = analysis
        self.templates = self._load_templates()
    
    def _load_templates(self) -> Dict[str, Template]:
        """Load Jinja2 templates for code generation."""
        # Built-in templates
        templates = {
            'main': Template('''package main

import (
    "flag"
    "fmt"
    "os"
    {% if uses_csv %}"encoding/csv"{% endif %}
    {% if uses_json %}"encoding/json"{% endif %}
    "bufio"
)

type Config struct {
    InputPath  string
    OutputPath string
    Verbose    bool
}

func main() {
    config := parseArgs()
    if err := run(config); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\\n", err)
        os.Exit(1)
    }
}

func run(config *Config) error {
    // TODO: Implement based on Python script
    // Generated from: {{ script_path }}
    
    {% if analysis.file_operations %}
    // File operations detected:
    {% for op in analysis.file_operations %}
    // {{ op.operation }}: {{ op.path }} (mode={{ op.mode }})
    {% endfor %}
    {% endif %}
    
    return nil
}

func parseArgs() *Config {
    config := &Config{}
    
    // Define flags
    inputFlag := flag.String("input", "", "Input file path")
    outputFlag := flag.String("output", "", "Output file path")
    verboseFlag := flag.Bool("verbose", false, "Enable verbose output")
    
    flag.Parse()
    
    config.InputPath = *inputFlag
    config.OutputPath = *outputFlag
    config.Verbose = *verboseFlag
    
    // Handle positional arguments if provided
    args := flag.Args()
    if len(args) > 0 && config.InputPath == "" {
        config.InputPath = args[0]
    }
    if len(args) > 1 && config.OutputPath == "" {
        config.OutputPath = args[1]
    }
    
    return config
}
''')
        }
        return templates
    
    def generate_go_code(self) -> str:
        """Generate Go code from the analysis."""
        # Prepare context for template
        context = {
            'script_path': self.analysis.script_path,
            'analysis': self.analysis,
            'uses_csv': self.analysis.uses_csv,
            'uses_json': self.analysis.uses_json,
            'uses_argparse': self.analysis.uses_argparse,
            'main_function': self.analysis.get_main_function()
        }
        
        # Render template
        return self.templates['main'].render(**context)
    
    def generate_go_mod(self, module_name: str, go_version: str = "1.21") -> str:
        """Generate go.mod file."""
        return f'''module {module_name}

go {go_version}
'''
    
    def generate_readme(self, project_name: str) -> str:
        """Generate README for the Go project."""
        python_script = Path(self.analysis.script_path).name
        
        return f'''# {project_name} (Go Implementation)

This project is a Go implementation of the Python script `{python_script}`,
generated by NoodleCore Go Scaffolder.

## Usage

```bash
go run . -input <input_file> -output <output_file> [options]

# Or build and run:
go build -o {project_name}
./{project_name} -input <input_file>
```

## Options

- `-input string`: Input file path
- `-output string`: Output file path  
- `-verbose`: Enable verbose output

## Original Python Script

This implementation is based on: `{python_script}`

## Project Structure

```
.
â”œâ”€â”€ go.mod
â”œâ”€â”€ go.sum
â”œâ”€â”€ main.go
â””â”€â”€ README.md
```

## Implementation Notes

- This is a scaffolded version generated from Python analysis
- Some features may require manual implementation
- Error handling follows Go idioms
- Type safety is enforced
'''
    
    def scaffold_project(self, output_dir: Path, module_name: str) -> None:
        """
        Generate complete Go project structure.
        
        Args:
            output_dir: Directory to create the project in
            module_name: Go module name
        """
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate main.go
        main_go = self.generate_go_code()
        (output_dir / "main.go").write_text(main_go, encoding='utf-8')
        
        # Generate go.mod
        go_mod = self.generate_go_mod(module_name)
        (output_dir / "go.mod").write_text(go_mod, encoding='utf-8')
        
        # Generate README
        readme = self.generate_readme(module_name)
        (output_dir / "README.md").write_text(readme, encoding='utf-8')
        
        print(f"SUCCESS: Generated Go project at {output_dir}")
        print(f"  - main.go")
        print(f"  - go.mod")
        print(f"  - README.md")


def analyze_python_script(script_path: str) -> ScriptAnalysis:
    """
    Analyze a Python script and extract information for scaffolding.
    
    Args:
        script_path: Path to Python script
        
    Returns:
        ScriptAnalysis object with extracted information
    """
    if not os.path.exists(script_path):
        raise FileNotFoundError(f"Script not found: {script_path}")
    
    with open(script_path, 'r', encoding='utf-8') as f:
        source = f.read()
    
    try:
        tree = ast.parse(source)
        analyzer = PythonAnalyzer(script_path)
        analyzer.visit(tree)
        return analyzer.analysis
    except SyntaxError as e:
        raise ValueError(f"Invalid Python syntax: {e}")


def main():
    """Main entry point for CLI usage."""
    parser = argparse.ArgumentParser(
        description="Generate Go scaffolding from Python script"
    )
    parser.add_argument(
        "script",
        help="Path to Python script to analyze"
    )
    parser.add_argument(
        "-o", "--output",
        default="./generated_go_project",
        help="Output directory for Go project (default: ./generated_go_project)"
    )
    parser.add_argument(
        "-m", "--module",
        default="generated_project",
        help="Go module name (default: generated_project)"
    )
    parser.add_argument(
        "--analyze-only",
        action="store_true",
        help="Only analyze and print results, don't generate code"
    )
    
    args = parser.parse_args()
    
    try:
        # Analyze Python script
        print(f"Analyzing {args.script}...")
        analysis = analyze_python_script(args.script)
        
        print(f"\\n=== Analysis Results ===")
        print(f"Script: {analysis.script_path}")
        print(f"Functions: {len(analysis.functions)}")
        print(f"File operations: {len(analysis.file_operations)}")
        print(f"Uses argparse: {analysis.uses_argparse}")
        print(f"Uses CSV: {analysis.uses_csv}")
        print(f"Uses JSON: {analysis.uses_json}")
        
        if analysis.functions:
            print(f"\\nDetected functions:")
            for func in analysis.functions:
                print(f"  - {func.name} ({len(func.args)} args)")
                if func.has_file_ops:
                    print(f"    [file operations detected]")
        
        if analysis.file_operations:
            print(f"\\nFile operations:")
            for op in analysis.file_operations:
                print(f"  - {op.operation} {op.path} (mode={op.mode})")
        
        if args.analyze_only:
            return
        
        # Generate Go project
        print(f"\\nGenerating Go project...")
        scaffolder = GoScaffolder(analysis)
        output_dir = Path(args.output)
        scaffolder.scaffold_project(output_dir, args.module)
        
        print(f"\\nNext steps:")
        print(f"  1. cd {output_dir}")
        print(f"  2. go mod tidy")
        print(f"  3. go run .")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())


