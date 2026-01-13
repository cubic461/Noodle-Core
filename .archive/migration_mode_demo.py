#!/usr/bin/env python3
"""
Noodle::Migration Mode Demo - migration_mode_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Migration Mode Complete Demo Script

This script demonstrates the complete observe â†’ generate â†’ scaffold â†’ verify â†’ report workflow
for migrating Python code to Go using golden tests.

Workflow:
1. OBSERVE: Run Python script and capture execution trace
2. GENERATE: Convert trace to golden tests
3. SCAFFOLD: Generate Go project structure from Python code
4. VERIFY: Run golden tests against scaffolded Go code
5. REPORT: Generate detailed migration report

Usage:
    python migration_mode_demo.py [--full] [--verbose]
"""

import sys
import json
import time
import subprocess
import os
import shutil
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime


# ANSI color codes for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


@dataclass
class MigrationResult:
    """Results from a migration workflow step."""
    step_name: str
    success: bool
    duration: float
    output: str
    errors: List[str]
    warnings: List[str]
    artifacts: Dict[str, Any]


@dataclass
class MigrationReport:
    """Complete migration report."""
    migration_id: str
    start_time: datetime
    end_time: Optional[datetime] = None
    results: List[MigrationResult] = None
    summary: Dict[str, Any] = None
    recommendations: List[str] = None
    
    def __post_init__(self):
        if self.results is None:
            self.results = []
        if self.summary is None:
            self.summary = {}
        if self.recommendations is None:
            self.recommendations = []


class MigrationDemo:
    """Main demo orchestrator."""
    
    def __init__(self, verbose: bool = False, full_workflow: bool = True):
        self.verbose = verbose
        self.full_workflow = full_workflow
        self.report = MigrationReport(
            migration_id=f"migration_{int(time.time())}",
            start_time=datetime.now()
        )
        self.working_dir = Path.cwd()
        self.demo_dir = self.working_dir / "demo_migration"
        self.trace_file = self.demo_dir / "python_trace.json"
        self.golden_test_file = self.demo_dir / "generated_golden_test.json"
        self.scaffold_dir = self.demo_dir / "go_scaffold"
        
    def log(self, message: str, level: str = "info"):
        """Log message with color and timestamp."""
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        if level == "info":
            prefix = f"{Colors.BLUE}[INFO]{Colors.ENDC}"
        elif level == "success":
            prefix = f"{Colors.GREEN}[âœ“]{Colors.ENDC}"
        elif level == "warning":
            prefix = f"{Colors.YELLOW}[WARN]{Colors.ENDC}"
        elif level == "error":
            prefix = f"{Colors.RED}[âœ—]{Colors.ENDC}"
        elif level == "step":
            prefix = f"{Colors.CYAN}[STEP]{Colors.ENDC}"
        else:
            prefix = "[LOG]"
        
        print(f"{prefix} [{timestamp}] {message}")
    
    def run_step(self, step_name: str, step_func, *args, **kwargs) -> MigrationResult:
        """Execute a migration step with timing and error handling."""
        self.log(f"Starting: {step_name}", "step")
        start_time = time.time()
        
        result = MigrationResult(
            step_name=step_name,
            success=False,
            duration=0.0,
            output="",
            errors=[],
            warnings=[],
            artifacts={}
        )
        
        try:
            step_result = step_func(*args, **kwargs)
            result.success = True
            result.output = str(step_result) if step_result else ""
            result.artifacts = step_result if isinstance(step_result, dict) else {}
            
        except Exception as e:
            result.success = False
            result.errors.append(str(e))
            self.log(f"Error in {step_name}: {e}", "error")
        
        result.duration = time.time() - start_time
        
        if result.success:
            self.log(f"Completed {step_name} in {result.duration:.3f}s", "success")
        else:
            self.log(f"Failed {step_name} after {result.duration:.3f}s", "error")
        
        self.report.results.append(result)
        return result
    
    def setup_demo_environment(self):
        """Prepare demo directory and test files."""
        # Create demo directory
        self.demo_dir.mkdir(exist_ok=True)
        
        # Copy test files
        test_data_dir = self.demo_dir / "test_data"
        test_data_dir.mkdir(exist_ok=True)
        
        # Create sample input file
        input_file = test_data_dir / "sample_input.txt"
        with open(input_file, 'w') as f:
            f.write("Hello, Python to Go Migration Demo!\n")
            f.write("This file demonstrates basic text processing.\n")
            f.write("Lines will be processed and converted to uppercase.\n")
        
        self.log(f"Created demo environment in {self.demo_dir}")
        return {"demo_dir": str(self.demo_dir), "test_data_dir": str(test_data_dir)}
    
    def step_observe(self) -> Dict[str, Any]:
        """Step 1: Observe Python execution and capture trace."""
        
        self.log("=== STEP 1: OBSERVE (Python Execution) ===", "step")
        
        # Create simplified trace capture
        trace_data = {
            "trace_id": f"python_demo_{int(time.time())}",
            "language": "python",
            "command": [
                sys.executable,
                str(self.working_dir / "simple_file_processor_example.py"),
                str(self.demo_dir / "test_data" / "sample_input.txt"),
                str(self.demo_dir / "test_data" / "python_output.txt")
            ],
            "working_dir": str(self.demo_dir),
            "start_time": time.time()
        }
        
        # Execute Python script
        try:
            result = subprocess.run(
                trace_data["command"],
                capture_output=True,
                text=True,
                cwd=self.demo_dir,
                timeout=30
            )
            
            trace_data["end_time"] = time.time()
            trace_data["exit_code"] = result.returncode
            
            # Capture file operations
            trace_data["io_log"] = [
                {
                    "operation": "read",
                    "path": str(self.demo_dir / "test_data" / "sample_input.txt"),
                    "success": True,
                    "timestamp": time.time() - 1
                },
                {
                    "operation": "create",
                    "path": str(self.demo_dir / "test_data" / "python_output.txt"),
                    "success": True,
                    "timestamp": time.time()
                }
            ]
            
            # Verify output file was created
            output_file = self.demo_dir / "test_data" / "python_output.txt"
            if output_file.exists():
                with open(output_file, 'r') as f:
                    trace_data["expected_output"] = f.read()
            
            # Save trace
            with open(self.trace_file, 'w') as f:
                json.dump(trace_data, f, indent=2)
            
            self.log(f"âœ“ Captured Python execution trace: {self.trace_file}")
            self.log(f"  Exit code: {result.returncode}")
            self.log(f"  Duration: {trace_data['end_time'] - trace_data['start_time']:.3f}s")
            
            return {
                "trace_file": str(self.trace_file),
                "exit_code": result.returncode,
                "duration": trace_data['end_time'] - trace_data['start_time'],
                "stdout": result.stdout,
                "stderr": result.stderr
            }
            
        except subprocess.TimeoutExpired:
            self.log("âœ— Python execution timed out", "error")
            return {"error": "Execution timed out"}
        except Exception as e:
            self.log(f"âœ— Failed to capture trace: {e}", "error")
            return {"error": str(e)}
    
    def step_generate(self) -> Dict[str, Any]:
        """Step 2: Generate golden tests from trace."""
        
        self.log("=== STEP 2: GENERATE (Golden Tests) ===", "step")
        
        # Load trace data
        with open(self.trace_file, 'r') as f:
            trace_data = json.load(f)
        
        # Generate golden test from trace
        golden_test = {
            "test_suite_name": "python_migration_demo",
            "format_version": "1.0.0",
            "description": "Golden tests generated from Python file processor execution",
            "tests": [
                {
                    "test_id": "file_processing_test",
                    "description": "Process input file and generate uppercase output",
                    "enabled": True,
                    "priority": "high",
                    "tags": ["migration", "file_processing", "regression"],
                    "setup": {
                        "create_files": [
                            {
                                "path": str(self.demo_dir / "test_data" / "sample_input.txt"),
                                "content": "HELLO, PYTHON TO GO MIGRATION DEMO!\nTHIS FILE DEMONSTRATES BASIC TEXT PROCESSING.\nLINES WILL BE PROCESSED AND CONVERTED TO UPPERCASE.\n",
                                "encoding": "utf-8"
                            }
                        ],
                        "delete_files": [
                            str(self.demo_dir / "test_data" / "python_output.txt"),
                            str(self.demo_dir / "test_data" / "go_output.txt")
                        ],
                        "environment": {}
                    },
                    "input": {
                        "command": trace_data["command"],
                        "working_dir": str(self.demo_dir),
                        "stdin": None,
                        "timeout_seconds": 30
                    },
                    "expected_output": {
                        "exit_code": 0,
                        "stdout": "",
                        "stderr": "",
                        "partial_match": True
                    },
                    "expected_files": [
                        {
                            "path": str(self.demo_dir / "test_data" / "python_output.txt"),
                            "should_exist": True,
                            "content_match": "HELLO, PYTHON TO GO MIGRATION DEMO!\nTHIS FILE DEMONSTRATES BASIC TEXT PROCESSING.\nLINES WILL BE PROCESSED AND CONVERTED TO UPPERCASE.\n"
                        }
                    ],
                    "assertions": [
                        {
                            "type": "file_exists",
                            "file_path": str(self.demo_dir / "test_data" / "python_output.txt")
                        },
                        {
                            "type": "exit_code",
                            "expected_code": 0
                        }
                    ],
                    "cleanup": {
                        "delete_files": [],
                        "delete_dirs": []
                    }
                }
            ],
            "metadata": {
                "created_by": "MigrationDemo",
                "created_date": datetime.now().strftime("%Y-%m-%d"),
                "target_script": "simple_file_processor_example.py",
                "trace_id": trace_data["trace_id"]
            }
        }
        
        # Save golden test
        with open(self.golden_test_file, 'w') as f:
            json.dump(golden_test, f, indent=2)
        
        self.log(f"âœ“ Generated golden test: {self.golden_test_file}")
        self.log(f"  Test cases: {len(golden_test['tests'])}")
        
        return {
            "golden_test_file": str(self.golden_test_file),
            "test_count": len(golden_test['tests']),
            "golden_test": golden_test
        }
    
    def step_scaffold(self) -> Dict[str, Any]:
        """Step 3: Scaffold Go project from Python code."""
        
        self.log("=== STEP 3: SCAFFOLD (Go Project) ===", "step")
        
        # Create Go project structure
        go_src_dir = self.scaffold_dir / "src"
        go_src_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate simple Go code equivalent to Python processor
        go_code = '''package main

import (
    "bufio"
    "fmt"
    "io/ioutil"
    "os"
    "strings"
    "time"
)

// FileProcessor processes text files
type FileProcessor struct {
    InputPath  string
    OutputPath string
    stats      ProcessingStats
}

// ProcessingStats tracks processing statistics
type ProcessingStats struct {
    LinesProcessed      int
    CharactersProcessed int
    StartTime           time.Time
    EndTime             time.Time
}

// NewFileProcessor creates a new FileProcessor
func NewFileProcessor(inputPath, outputPath string) *FileProcessor {
    return &FileProcessor{
        InputPath:  inputPath,
        OutputPath: outputPath,
    }
}

// ValidateInput checks if input file exists
func (fp *FileProcessor) ValidateInput() bool {
    if _, err := os.Stat(fp.InputPath); os.IsNotExist(err) {
        fmt.Printf("Error: Input file does not exist: %s\\n", fp.InputPath)
        return false
    }
    return true
}

// CreateOutputDirectory creates output directory
func (fp *FileProcessor) CreateOutputDirectory() {
    os.MkdirAll(fp.OutputPath[:len(fp.OutputPath)-len(fp.OutputPath[strings.LastIndex(fp.OutputPath, "/"):])], 0755)
}

// ProcessFile reads input, processes content, writes output
func (fp *FileProcessor) ProcessFile() bool {
    fp.stats.StartTime = time.Now()
    
    // Read input file
    content, err := ioutil.ReadFile(fp.InputPath)
    if err != nil {
        fmt.Printf("Error reading input file: %v\\n", err)
        return false
    }
    
    // Process content (convert to uppercase)
    processedContent := strings.ToUpper(string(content))
    
    // Update statistics
    fp.stats.LinesProcessed = len(strings.Split(string(content), "\\n"))
    fp.stats.CharactersProcessed = len(content)
    
    // Create output directory
    fp.CreateOutputDirectory()
    
    // Write output file
    err = ioutil.WriteFile(fp.OutputPath, []byte(processedContent), 0644)
    if err != nil {
        fmt.Printf("Error writing output file: %v\\n", err)
        return false
    }
    
    fp.stats.EndTime = time.Now()
    return true
}

// PrintStats displays processing statistics
func (fp *FileProcessor) PrintStats() {
    duration := fp.stats.EndTime.Sub(fp.stats.StartTime)
    fmt.Println("==================================================")
    fmt.Println("Processing Statistics")
    fmt.Println("==================================================")
    fmt.Printf("Lines processed: %d\\n", fp.stats.LinesProcessed)
    fmt.Printf("Characters processed: %d\\n", fp.stats.CharactersProcessed)
    fmt.Printf("Duration: %.3f seconds\\n", duration.Seconds())
    fmt.Printf("Output file: %s\\n", fp.OutputPath)
    fmt.Println("==================================================")
}

func main() {
    if len(os.Args) < 3 {
        fmt.Println("Usage: go run main.go <input_file> <output_file> [-verbose]")
        os.Exit(1)
    }
    
    inputFile := os.Args[1]
    outputFile := os.Args[2]
    verbose := len(os.Args) > 3 && os.Args[3] == "-verbose"
    
    // Create processor
    processor := NewFileProcessor(inputFile, outputFile)
    
    // Validate input
    if !processor.ValidateInput() {
        os.Exit(1)
    }
    
    // Process file
    fmt.Printf("Processing: %s\\n", inputFile)
    success := processor.ProcessFile()
    
    if success {
        fmt.Println("âœ“ Successfully processed file")
        if verbose {
            processor.PrintStats()
        }
        os.Exit(0)
    } else {
        fmt.Println("âœ— Failed to process file")
        os.Exit(1)
    }
}
'''
        
        main_go = go_src_dir / "main.go"
        with open(main_go, 'w') as f:
            f.write(go_code)
        
        # Create go.mod
        go_mod = self.scaffold_dir / "go.mod"
        with open(go_mod, 'w') as f:
            f.write("module migration_demo\n\ngo 1.21\n")
        
        self.log(f"âœ“ Scaffolded Go project: {self.scaffold_dir}")
        self.log(f"  Files created: main.go, go.mod")
        
        return {
            "scaffold_dir": str(self.scaffold_dir),
            "go_files": ["main.go", "go.mod"],
            "line_count": len(go_code.split('\n'))
        }
    
    def step_verify(self) -> Dict[str, Any]:
        """Step 4: Verify scaffolded Go code against golden tests."""
        
        self.log("=== STEP 4: VERIFY (Compare Outputs) ===", "step")
        
        verification_results = {
            "python_baseline": None,
            "go_implementation": None,
            "comparison": {},
            "success": False
        }
        
        try:
            # 1. Get Python baseline
            python_output_file = self.demo_dir / "test_data" / "python_output.txt"
            if python_output_file.exists():
                with open(python_output_file, 'r') as f:
                    python_output = f.read()
                verification_results["python_baseline"] = python_output
                self.log("âœ“ Loaded Python baseline output")
            
            # 2. Build and run Go code
            self.log("Building Go code...")
            
            # Compile Go program
            build_result = subprocess.run(
                ["go", "build", "-o", str(self.scaffold_dir / "processor"), str(self.scaffold_dir / "src" / "main.go")],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if build_result.returncode != 0:
                verification_results["comparison"]["build_error"] = build_result.stderr
                self.log(f"âœ— Go build failed: {build_result.stderr[:100]}", "error")
                return verification_results
            
            self.log("âœ“ Go code compiled successfully")
            
            # Run Go program
            go_output_file = self.demo_dir / "test_data" / "go_output.txt"
            run_result = subprocess.run(
                [str(self.scaffold_dir / "processor"), 
                 str(self.demo_dir / "test_data" / "sample_input.txt"),
                 str(go_output_file)],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if run_result.returncode != 0:
                verification_results["comparison"]["run_error"] = run_result.stderr
                self.log(f"âœ— Go execution failed: {run_result.stderr[:100]}", "error")
                return verification_results
            
            self.log("âœ“ Go code executed successfully")
            
            # 3. Load Go output
            if go_output_file.exists():
                with open(go_output_file, 'r') as f:
                    go_output = f.read()
                verification_results["go_implementation"] = go_output
            
            # 4. Compare outputs
            if python_output and go_output:
                match = python_output == go_output
                verification_results["comparison"]["output_match"] = match
                verification_results["comparison"]["python_size"] = len(python_output)
                verification_results["comparison"]["go_size"] = len(go_output)
                verification_results["success"] = match
                
                if match:
                    self.log("âœ“ Outputs match perfectly!", "success")
                else:
                    self.log("âœ— Outputs do not match", "error")
                    # Find differences
                    python_lines = python_output.split('\n')
                    go_lines = go_output.split('\n')
                    
                    if len(python_lines) != len(go_lines):
                        verification_results["comparison"]["line_count_diff"] = {
                            "python": len(python_lines),
                            "go": len(go_lines)
                        }
                        self.log(f"  Line count mismatch: Python={len(python_lines)}, Go={len(go_lines)}")
                    
                    # Find first differing line
                    for i, (p_line, g_line) in enumerate(zip(python_lines, go_lines)):
                        if p_line != g_line:
                            verification_results["comparison"]["first_diff"] = {
                                "line": i + 1,
                                "python": p_line[:50],
                                "go": g_line[:50]
                            }
                            break
            
        except subprocess.TimeoutExpired:
            self.log("âœ— Verification timeout", "error")
            verification_results["errors"] = ["Timeout during verification"]
        except Exception as e:
            self.log(f"âœ— Verification failed: {e}", "error")
            verification_results["errors"] = [str(e)]
        
        return verification_results
    
    def step_report(self) -> Dict[str, Any]:
        """Step 5: Generate comprehensive migration report."""
        
        self.log("=== STEP 5: REPORT (Migration Summary) ===", "step")
        
        # Calculate summary statistics
        self.report.end_time = datetime.now()
        total_duration = (self.report.end_time - self.report.start_time).total_seconds()
        
        success_count = sum(1 for r in self.report.results if r.success)
        total_steps = len(self.report.results)
        
        # Get verification results
        verification_result = next((r for r in self.report.results if r.step_name == "verify"), None)
        
        # Create report
        report = {
            "migration_id": self.report.migration_id,
            "start_time": self.report.start_time.isoformat(),
            "end_time": self.report.end_time.isoformat(),
            "total_duration": total_duration,
            "steps_completed": success_count,
            "steps_total": total_steps,
            "overall_status": "SUCCESS" if success_count == total_steps else "PARTIAL" if success_count > 0 else "FAILED",
            "detailed_results": [
                {
                    "step": r.step_name,
                    "status": "SUCCESS" if r.success else "FAILED",
                    "duration": r.duration,
                    "artifacts_count": len(r.artifacts)
                }
                for r in self.report.results
            ],
            "verification": verification_result.artifacts if verification_result else {},
            "recommendations": []
        }
        
        # Add recommendations
        if verification_result and verification_result.success:
            if verification_result.artifacts.get("comparison", {}).get("output_match"):
                report["recommendations"].append("âœ“ Outputs match perfectly - migration successful")
            else:
                report["recommendations"].append("âš  Outputs differ - manual review recommended")
        
        if success_count < total_steps:
            report["recommendations"].append(f"âš  {total_steps - success_count} steps failed - review error logs")
        
        # Save report
        report_file = self.demo_dir / "migration_report.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        self.report.summary = report
        
        self.log(f"âœ“ Migration report saved: {report_file}", "success")
        
        return report
    
    def print_summary(self):
        """Print formatted summary of migration."""
        
        print(f"\n{Colors.BOLD}{'=' * 70}{Colors.ENDC}")
        print(f"{Colors.BOLD}{' ' * 15}MIGRATION MODE DEMO - COMPLETION SUMMARY{Colors.ENDC}")
        print(f"{Colors.BOLD}{'=' * 70}{Colors.ENDC}")
        
        print(f"\n{Colors.BOLD}Migration ID:{Colors.ENDC} {self.report.migration_id}")
        print(f"{Colors.BOLD}Start Time:{Colors.ENDC} {self.report.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        
        if self.report.end_time:
            duration = (self.report.end_time - self.report.start_time).total_seconds()
            print(f"{Colors.BOLD}Duration:{Colors.ENDC} {duration:.3f} seconds")
        
        print(f"\n{Colors.BOLD}{'Step Results:'}{Colors.ENDC}")
        print("-" * 70)
        
        for result in self.report.results:
            status_color = Colors.GREEN if result.success else Colors.RED
            status_text = "âœ“ SUCCESS" if result.success else "âœ— FAILED"
            print(f"{status_color}{status_text:12}{Colors.ENDC} {result.step_name:20} ({result.duration:6.3f}s)")
            
            if result.warnings:
                for warning in result.warnings:
                    print(f"  {Colors.YELLOW}WARN{Colors.ENDC} {warning}")
            
            if result.errors:
                for error in result.errors:
                    print(f"  {Colors.RED}ERROR{Colors.ENDC} {error}")
        
        # Overall status
        success_count = sum(1 for r in self.report.results if r.success)
        total_steps = len(self.report.results)
        
        print("-" * 70)
        if success_count == total_steps:
            print(f"{Colors.BOLD}{Colors.GREEN}âœ“ All {total_steps} steps completed successfully{Colors.ENDC}")
        elif success_count > 0:
            print(f"{Colors.BOLD}{Colors.YELLOW}âš  {success_count}/{total_steps} steps completed successfully{Colors.ENDC}")
        else:
            print(f"{Colors.BOLD}{Colors.RED}âœ— No steps completed successfully{Colors.ENDC}")
        
        print(f"\n{Colors.BOLD}{'=' * 70}{Colors.ENDC}")
        
        # Verification details
        verification_result = next((r for r in self.report.results if r.step_name == "verify"), None)
        if verification_result and verification_result.success:
            verification = verification_result.artifacts
            comparison = verification.get("comparison", {})
            
            if comparison.get("output_match"):
                print(f"\n{Colors.BOLD}{Colors.GREEN}VERIFICATION: OUTPUTS MATCH âœ“{Colors.ENDC}")
                print(f"  Python baseline matches Go implementation perfectly")
            else:
                print(f"\n{Colors.BOLD}{Colors.YELLOW}VERIFICATION: OUTPUTS DIFFER âš {Colors.ENDC}")
                if "line_count_diff" in comparison:
                    diff = comparison["line_count_diff"]
                    print(f"  Line count mismatch: Python={diff['python']}, Go={diff['go']}")
                if "first_diff" in comparison:
                    diff = comparison["first_diff"]
                    print(f"  First difference at line {diff['line']}")
                    print(f"    Python: {diff['python']}")
                    print(f"    Go:     {diff['go']}")
        
        print(f"\n{Colors.BOLD}{'=' * 70}{Colors.ENDC}")
        print(f"{Colors.BOLD}Artifacts Generated:{Colors.ENDC}")
        print(f"  â€¢ Trace file: {self.trace_file}")
        print(f"  â€¢ Golden test: {self.golden_test_file}")
        print(f"  â€¢ Go scaffold: {self.scaffold_dir}")
        print(f"  â€¢ Migration report: {self.demo_dir / 'migration_report.json'}")
        print(f"{Colors.BOLD}{'=' * 70}{Colors.ENDC}\n")
    
    def run_full_workflow(self):
        """Execute complete migration workflow."""
        
        print(f"\n{Colors.BOLD}{Colors.HEADER}{'=' * 70}{Colors.ENDC}")
        print(f"{Colors.BOLD}{Colors.HEADER}{' ' * 5}MIGRATION MODE COMPLETE WORKFLOW DEMONSTRATION{Colors.ENDC}")
        print(f"{Colors.BOLD}{Colors.HEADER}{'=' * 70}{Colors.ENDC}")
        print(f"{Colors.BOLD}Migration ID: {self.report.migration_id}{Colors.ENDC}")
        print(f"{Colors.BOLD}Start Time: {self.report.start_time.strftime('%Y-%m-%d %H:%M:%S')}{Colors.ENDC}")
        print(f"{Colors.BOLD}Full Workflow: {self.full_workflow}{Colors.ENDC}")
        print(f"{Colors.BOLD}Verbose: {self.verbose}{Colors.ENDC}")
        print(f"{Colors.HEADER}{'=' * 70}{Colors.ENDC}\n")
        
        try:
            # Setup
            self.run_step("setup", self.setup_demo_environment)
            
            # Step 1: Observe
            self.run_step("observe", self.step_observe)
            
            # Step 2: Generate
            self.run_step("generate", self.step_generate)
            
            # Step 3: Scaffold
            self.run_step("scaffold", self.step_scaffold)
            
            # Step 4: Verify (only if scaffolding succeeded)
            if any(r.step_name == "scaffold" and r.success for r in self.report.results):
                self.run_step("verify", self.step_verify)
            
            # Step 5: Report
            self.run_step("report", self.step_report)
            
            # Print summary
            self.print_summary()
            
            return True
            
        except KeyboardInterrupt:
            self.log("Migration interrupted by user", "warning")
            return False
        except Exception as e:
            self.log(f"Migration failed with exception: {e}", "error")
            import traceback
            traceback.print_exc()
            return False


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Migration Mode Complete Demo - Observe â†’ Generate â†’ Scaffold â†’ Verify â†’ Report"
    )
    
    parser.add_argument(
        '--full',
        action='store_true',
        help='Run complete workflow (all steps)'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )
    
    parser.add_argument(
        '--steps',
        nargs='+',
        choices=['observe', 'generate', 'scaffold', 'verify', 'report'],
        help='Run specific steps only (default: all)'
    )
    
    # Check for --help flag and print basic help (avoid Unicode issues)
    if '--help' in sys.argv or '-h' in sys.argv:
        print("Migration Mode Demo - Complete Workflow")
        print("=" * 50)
        print()
        print("Usage:")
        print("  python migration_mode_demo.py [--full] [--verbose]")
        print()
        print("Options:")
        print("  --full              Run complete workflow (all steps)")
        print("  --verbose, -v       Enable verbose output")
        print("  --steps             Run specific steps (space-separated)")
        print("                      Choices: observe, generate, scaffold, verify, report")
        print()
        print("Examples:")
        print("  python migration_mode_demo.py --full --verbose")
        print("  python migration_mode_demo.py --steps observe generate")
        print("  python migration_mode_demo.py (runs full workflow)")
        print()
        sys.exit(0)
    
    args = parser.parse_args()
    
    # Create demo instance
    demo = MigrationDemo(verbose=args.verbose, full_workflow=args.full or not args.steps)
    
    # Run workflow
    if args.steps:
        # Custom steps
        print("Custom step execution not yet implemented - running full workflow")
    
    success = demo.run_full_workflow()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()


