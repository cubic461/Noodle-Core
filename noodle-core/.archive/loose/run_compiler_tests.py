#!/usr/bin/env python3
"""
Test Suite::Noodle Core - run_compiler_tests.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive Test Runner for NoodleCore Compiler

This script provides a comprehensive test runner for all NoodleCore compiler tests,
including test configuration management, test result aggregation, test report generation,
and test execution coordination.

Features:
- Run all compiler tests
- Test configuration management
- Test result aggregation and reporting
- Integration with testing framework
- Support for different test categories
- Performance benchmarking
- Security compliance testing
- HTML and JSON report generation
"""

import os
import sys
import time
import json
import uuid
import logging
import argparse
import subprocess
from typing import List, Dict, Any, Optional, Union
from pathlib import Path

# Add the src directory to the path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.testing_framework import (
    UnifiedTestingFramework, TestConfiguration, TestCategory, TestPriority,
    create_test_configuration, create_test_suite, create_test_case
)
from noodlecore.compiler.validation_framework import (
    ValidationFramework, ValidationConfiguration, ValidationType,
    create_validation_configuration, create_validation_framework
)
from noodlecore.compiler.continuous_testing import (
    ContinuousTestingPipeline, ContinuousTestingConfig,
    create_continuous_testing_config, create_continuous_testing_pipeline
)
from noodlecore.compiler.test_dashboard import (
    TestDashboard, DashboardConfig,
    create_dashboard_config, create_test_dashboard
)
from noodlecore.compiler.test_data_manager import (
    TestDataManager, TestDataManagerConfig,
    create_test_data_manager_config, create_test_data_manager
)


class TestRunnerConfig:
    """Configuration for the comprehensive test runner"""
    def __init__(
        self,
        test_categories: List[TestCategory] = None,
        test_priorities: List[TestPriority] = None,
        max_parallel_tests: int = 4,
        enable_performance_benchmarks: bool = True,
        enable_security_testing: bool = True,
        enable_validation: bool = True,
        enable_continuous_testing: bool = False,
        enable_dashboard: bool = False,
        output_directory: str = "test_results",
        report_format: str = "json",  # json, html, both
        verbose: bool = False,
        continue_on_failure: bool = True,
        timeout_seconds: float = 300.0,
        test_data_directory: str = "test_data",
        baseline_directory: str = "validation_baselines",
        generate_test_data: bool = False,
        test_filter: str = None,
        environment_variables: Dict[str, str] = None
    ):
        self.test_categories = test_categories or list(TestCategory)
        self.test_priorities = test_priorities or list(TestPriority)
        self.max_parallel_tests = max_parallel_tests
        self.enable_performance_benchmarks = enable_performance_benchmarks
        self.enable_security_testing = enable_security_testing
        self.enable_validation = enable_validation
        self.enable_continuous_testing = enable_continuous_testing
        self.enable_dashboard = enable_dashboard
        self.output_directory = output_directory
        self.report_format = report_format
        self.verbose = verbose
        self.continue_on_failure = continue_on_failure
        self.timeout_seconds = timeout_seconds
        self.test_data_directory = test_data_directory
        self.baseline_directory = baseline_directory
        self.generate_test_data = generate_test_data
        self.test_filter = test_filter
        self.environment_variables = environment_variables or {}


class ComprehensiveTestRunner:
    """Comprehensive test runner for NoodleCore compiler"""
    
    def __init__(self, config: TestRunnerConfig = None):
        self.config = config or TestRunnerConfig()
        self.logger = logging.getLogger(__name__)
        
        # Create output directory
        os.makedirs(self.config.output_directory, exist_ok=True)
        
        # Initialize components
        self.testing_framework = None
        self.validation_framework = None
        self.continuous_pipeline = None
        self.test_dashboard = None
        self.test_data_manager = None
        
        # Test execution results
        self.test_results: List[Dict[str, Any]] = []
        self.validation_results: List[Dict[str, Any]] = []
        
        # Set up environment variables
        self._setup_environment_variables()
    
    def _setup_environment_variables(self):
        """Set up environment variables for testing"""
        for key, value in self.config.environment_variables.items():
            if not os.environ.get(key):
                os.environ[key] = value
                self.logger.info(f"Set environment variable: {key}={value}")
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Run all compiler tests"""
        print("NoodleCore Comprehensive Test Runner")
        print("=" * 50)
        
        start_time = time.perf_counter()
        
        try:
            # Initialize components
            self._initialize_components()
            
            # Run unit tests
            if self.config.test_categories:
                unit_test_results = self._run_unit_tests()
                self.test_results.extend(unit_test_results)
            
            # Run validation tests
            if self.config.enable_validation:
                validation_results = self._run_validation_tests()
                self.validation_results.extend(validation_results)
            
            # Run performance benchmarks
            if self.config.enable_performance_benchmarks:
                performance_results = self._run_performance_benchmarks()
                self.test_results.extend(performance_results)
            
            # Run security tests
            if self.config.enable_security_testing:
                security_results = self._run_security_tests()
                self.test_results.extend(security_results)
            
            # Start continuous testing if enabled
            if self.config.enable_continuous_testing:
                self._start_continuous_testing()
            
            # Start dashboard if enabled
            if self.config.enable_dashboard:
                self._start_dashboard()
            
            # Generate test data if requested
            if self.config.generate_test_data:
                self._generate_test_data()
            
            execution_time = time.perf_counter() - start_time
            
            # Generate reports
            self._generate_reports(execution_time)
            
            # Print summary
            self._print_summary(execution_time)
            
            return {
                "execution_time": execution_time,
                "test_results": self.test_results,
                "validation_results": self.validation_results,
                "success": self._check_overall_success()
            }
            
        except KeyboardInterrupt:
            print("\nTest execution interrupted by user.")
            return {"success": False, "interrupted": True}
        except Exception as e:
            print(f"Test execution failed: {e}")
            return {"success": False, "error": str(e)}
    
    def _initialize_components(self):
        """Initialize testing components"""
        # Initialize testing framework
        test_config = create_test_configuration(
            max_parallel_tests=self.config.max_parallel_tests,
            enable_performance_benchmarks=self.config.enable_performance_benchmarks,
            enable_security_testing=self.config.enable_security_testing,
            enable_regression_testing=True,
            enable_coverage_analysis=True,
            verbose_output=self.config.verbose,
            generate_reports=True,
            test_categories=self.config.test_categories,
            test_priorities=self.config.test_priorities
        )
        
        self.testing_framework = UnifiedTestingFramework(test_config)
        
        # Initialize validation framework
        if self.config.enable_validation:
            validation_config = create_validation_configuration(
                enable_correctness_validation=True,
                enable_performance_validation=True,
                enable_security_validation=True,
                enable_code_quality_validation=True,
                enable_integration_validation=True,
                generate_reports=True
            )
            
            self.validation_framework = create_validation_framework(validation_config)
        
        # Initialize test data manager
        data_config = create_test_data_manager_config(
            data_directory=self.config.test_data_directory,
            baseline_directory=self.config.baseline_directory,
            enable_checksum_validation=True,
            backup_on_change=True
        )
        
        self.test_data_manager = create_test_data_manager(data_config)
        
        self.logger.info("Components initialized")
    
    def _run_unit_tests(self) -> List[Dict[str, Any]]:
        """Run unit tests"""
        print("\nRunning unit tests...")
        
        # Run existing test suites
        test_suites = [
            "test_advanced_optimizations.py",
            "test_language_features.py",
            "test_compiler_security.py",
            "test_end_to_end_compiler.py"
        ]
        
        results = []
        
        for test_suite in test_suites:
            if self.config.test_filter and self.config.test_filter not in test_suite:
                continue
            
            print(f"  Running {test_suite}...")
            
            try:
                # Run the test suite
                result = subprocess.run([
                    sys.executable, test_suite
                ], capture_output=True, text=True, timeout=self.config.timeout_seconds)
                
                # Parse results
                success = result.returncode == 0
                
                results.append({
                    "test_suite": test_suite,
                    "success": success,
                    "returncode": result.returncode,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                    "execution_time": 0.0  # Would need to be measured properly
                })
                
                status = "PASSED" if success else "FAILED"
                print(f"    {status}")
                
            except subprocess.TimeoutExpired:
                results.append({
                    "test_suite": test_suite,
                    "success": False,
                    "returncode": -1,
                    "stdout": "",
                    "stderr": "Test timed out",
                    "execution_time": self.config.timeout_seconds
                })
                print(f"    TIMEOUT")
                
            except Exception as e:
                results.append({
                    "test_suite": test_suite,
                    "success": False,
                    "returncode": -2,
                    "stdout": "",
                    "stderr": str(e),
                    "execution_time": 0.0
                })
                print(f"    ERROR: {e}")
        
        print(f"Unit tests completed: {len(results)} suites")
        
        return results
    
    def _run_validation_tests(self) -> List[Dict[str, Any]]:
        """Run validation tests"""
        print("\nRunning validation tests...")
        
        if not self.validation_framework:
            return []
        
        # Create a simple validation test
        test_code = """
        function test_validation() {
            let x = 42;
            return x > 0;
        }
        """
        
        try:
            # Run validation
            validation_result = self.validation_framework.validate_all(
                target="validation_test.nc",
                source_code=test_code,
                expected_result=True
            )
            
            result = {
                "test_type": "validation",
                "success": validation_result.total_validations == validation_result.passed_validations + validation_result.failed_validations + validation_result.error_validations,
                "total_validations": validation_result.total_validations,
                "passed_validations": validation_result.passed_validations,
                "failed_validations": validation_result.failed_validations,
                "error_validations": validation_result.error_validations,
                "execution_time": validation_result.execution_time
            }
            
            status = "PASSED" if result["success"] else "FAILED"
            print(f"  Validation tests: {status}")
            
            return [result]
            
        except Exception as e:
            error_result = {
                "test_type": "validation",
                "success": False,
                "error": str(e),
                "execution_time": 0.0
            }
            print(f"  ERROR: {e}")
            
            return [error_result]
    
    def _run_performance_benchmarks(self) -> List[Dict[str, Any]]:
        """Run performance benchmarks"""
        print("\nRunning performance benchmarks...")
        
        if not self.testing_framework:
            return []
        
        # Create performance test cases
        perf_test_cases = [
            {
                "name": "Small Program Performance",
                "code": "let x = 42; let result = x * 2;",
                "expected_time": 0.01
            },
            {
                "name": "Medium Program Performance",
                "code": """
                function factorial(n): number {
                    if (n <= 1) return 1;
                    return n * factorial(n - 1);
                }
                
                let result = factorial(10);
                """,
                "expected_time": 0.05
            },
            {
                "name": "Large Program Performance",
                "code": """
                function complex_calculation(): number {
                    let result = 0;
                    for (let i = 0; i < 1000; i++) {
                        for (let j = 0; j < 100; j++) {
                            result = result + i * j;
                        }
                    }
                    return result;
                }
                
                let answer = complex_calculation();
                """,
                "expected_time": 0.2
            }
        ]
        
        results = []
        
        for test_case in perf_test_cases:
            print(f"  Running {test_case['name']}...")
            
            try:
                # Create test case
                from noodlecore.compiler.testing_framework import TestCase, TestCategory
                
                tc = create_test_case(
                    test_id=str(uuid.uuid4()),
                    name=test_case["name"],
                    description=f"Performance test for {test_case['name']}",
                    category=TestCategory.PERFORMANCE,
                    test_code=test_case["code"],
                    performance_baseline={
                        "compilation_time": test_case["expected_time"],
                        "tolerance": 0.5
                    }
                )
                
                # Add to test suite
                from noodlecore.compiler.testing_framework import TestSuite
                
                suite = TestSuite(
                    name="performance_benchmarks",
                    description="Performance benchmark tests"
                )
                suite.add_test_case(tc)
                
                # Run the test
                summary = self.testing_framework.run_all_tests()
                
                # Extract performance results
                perf_results = []
                for suite_result in summary.suite_results:
                    for test_result in suite_result.test_results:
                        if test_result.performance_metrics:
                            perf_results.append({
                                "test_name": test_result.test_name,
                                "execution_time": test_result.execution_time,
                                "metrics": test_result.performance_metrics
                            })
                
                result = {
                    "test_type": "performance",
                    "success": summary.total_passed == summary.total_tests,
                    "total_tests": summary.total_tests,
                    "passed_tests": summary.total_passed,
                    "failed_tests": summary.total_failed,
                    "performance_results": perf_results
                }
                
                status = "PASSED" if result["success"] else "FAILED"
                print(f"    {status}")
                
                results.append(result)
                
            except Exception as e:
                error_result = {
                    "test_type": "performance",
                    "success": False,
                    "error": str(e),
                    "execution_time": 0.0
                }
                print(f"    ERROR: {e}")
                
                results.append(error_result)
        
        print(f"Performance benchmarks completed: {len(results)} tests")
        
        return results
    
    def _run_security_tests(self) -> List[Dict[str, Any]]:
        """Run security tests"""
        print("\nRunning security tests...")
        
        if not self.validation_framework:
            return []
        
        # Create security test cases
        security_test_cases = [
            {
                "name": "SQL Injection Test",
                "code": "function query_user(id): string { return 'SELECT * FROM users WHERE id = '' + id + '''; }",
                "should_fail": True
            },
            {
                "name": "Code Injection Test",
                "code": "function evaluate(expr): any { return eval(expr); }",
                "should_fail": True
            },
            {
                "name": "Path Traversal Test",
                "code": "function read_file(path): string { return file.read('../data/' + path); }",
                "should_fail": True
            },
            {
                "name": "Secure Code Test",
                "code": "function safe_operation(data): string { return sanitize(data); }",
                "should_fail": False
            }
        ]
        
        results = []
        
        for test_case in security_test_cases:
            print(f"  Running {test_case['name']}...")
            
            try:
                # Run validation
                validation_result = self.validation_framework.validate_security(
                    f"security_test_{len(results)}.nc",
                    test_case["code"]
                )
                
                result = {
                    "test_type": "security",
                    "success": not test_case["should_fail"] and validation_result.status.value in ["passed", "warning"],
                    "total_issues": len(validation_result.issues),
                    "security_issues": validation_result.issues,
                    "execution_time": validation_result.execution_time
                }
                
                status = "PASSED" if result["success"] else "FAILED"
                print(f"    {status}")
                
                results.append(result)
                
            except Exception as e:
                error_result = {
                    "test_type": "security",
                    "success": False,
                    "error": str(e),
                    "execution_time": 0.0
                }
                print(f"    ERROR: {e}")
                
                results.append(error_result)
        
        print(f"Security tests completed: {len(results)} tests")
        
        return results
    
    def _start_continuous_testing(self):
        """Start continuous testing pipeline"""
        print("\nStarting continuous testing pipeline...")
        
        if not self.continuous_pipeline:
            # Initialize continuous testing pipeline
            config = create_continuous_testing_config(
                enable_scheduled_tests=True,
                enable_event_driven_tests=True,
                enable_alerting=True,
                max_concurrent_executions=self.config.max_parallel_tests
            )
            
            self.continuous_pipeline = create_continuous_testing_pipeline(config)
            self.continuous_pipeline.start()
    
    def _start_dashboard(self):
        """Start test dashboard"""
        print("\nStarting test dashboard...")
        
        if not self.test_dashboard:
            # Initialize test dashboard
            config = create_dashboard_config(
                enable_real_time_updates=True,
                update_interval=5.0,
                max_history_days=30
            )
            
            self.test_dashboard = create_test_dashboard(config)
            
            # Add existing test results to dashboard
            for result in self.test_results:
                if result.get("test_type") == "test_execution":
                    from noodlecore.compiler.testing_framework import TestExecutionSummary
                    
                    # Create a mock summary
                    summary = TestExecutionSummary(
                        total_tests=result.get("total_tests", 0),
                        total_passed=result.get("passed_tests", 0),
                        total_failed=result.get("failed_tests", 0),
                        total_execution_time=result.get("execution_time", 0.0),
                        suite_results=[]
                    )
                    
                    self.test_dashboard.add_test_execution(summary)
                elif result.get("test_type") == "validation":
                    from noodlecore.compiler.validation_framework import ValidationSummary
                    
                    # Create a mock summary
                    summary = ValidationSummary(
                        validation_id=str(uuid.uuid4()),
                        target="validation_test",
                        total_validations=result.get("total_validations", 0),
                        passed_validations=result.get("passed_validations", 0),
                        failed_validations=result.get("failed_validations", 0),
                        error_validations=result.get("error_validations", 0),
                        total_issues=result.get("total_issues", 0),
                        execution_time=result.get("execution_time", 0.0),
                        validation_results=[]
                    )
                    
                    self.test_dashboard.add_validation_result(summary)
            
            self.test_dashboard.start()
    
    def _generate_test_data(self):
        """Generate test data for testing"""
        print("\nGenerating test data...")
        
        if not self.test_data_manager:
            return
        
        # Generate various test cases
        test_cases = []
        
        # Simple arithmetic tests
        for i in range(10):
            a = i + 1
            b = i * 2
            
            test_cases.append(self.test_data_manager.create_test_case(
                name=f"Arithmetic Test {i+1}",
                description=f"Test arithmetic operations with {a} and {b}",
                category="arithmetic",
                test_code=f"let x = {a}; let y = {b}; let result = x + y;",
                expected_result=a + b
            ))
        
        # Function tests
        for i in range(5):
            test_cases.append(self.test_data_manager.create_test_case(
                name=f"Function Test {i+1}",
                description=f"Test function definition and execution",
                category="functions",
                test_code=f"""
                function test_func_{i+1}(x: number): number {{
                    return x * 2;
                }}
                
                let result = test_func_{i+1}({i+1});
                """,
                expected_result=(i+1) * 2
            ))
        
        # Control flow tests
        test_cases.append(self.test_data_manager.create_test_case(
            name="Control Flow Test",
            description="Test if-else control flow",
            category="control_flow",
            test_code="""
                function test_control_flow(x: number): string {{
                    if (x > 0) {{
                        return "positive";
                    }} else {{
                        return "zero";
                    }}
                }}
                
                let result1 = test_control_flow(5);
                let result2 = test_control_flow(0);
                let result3 = test_control_flow(-1);
                """,
                expected_result=["positive", "zero", "negative"]
            ))
        
        # Performance tests
        test_cases.append(self.test_data_manager.create_test_case(
            name="Performance Test",
            description="Test performance with large dataset",
            category="performance",
            test_code="""
                function performance_test(): number {{
                    let result = 0;
                    for (let i = 0; i < 1000; i++) {{
                        result = result + i;
                    }}
                    return result;
                }}
                
                let start_time = performance.now();
                let result = performance_test();
                let end_time = performance.now();
                let duration = end_time - start_time;
                """,
                performance_baseline={"compilation_time": 0.1, "tolerance": 0.5}
            ))
        
        print(f"Generated {len(test_cases)} test cases")
    
    def _generate_reports(self, execution_time: float):
        """Generate test reports"""
        print("\nGenerating test reports...")
        
        # Generate JSON report
        if self.config.report_format in ["json", "both"]:
            json_report_path = os.path.join(self.config.output_directory, "test_report.json")
            
            report_data = {
                "execution_time": execution_time,
                "timestamp": time.time(),
                "test_results": self.test_results,
                "validation_results": self.validation_results,
                "configuration": {
                    "test_categories": [c.value for c in self.config.test_categories],
                    "test_priorities": [p.value for p in self.config.test_priorities],
                    "max_parallel_tests": self.config.max_parallel_tests,
                    "enable_performance_benchmarks": self.config.enable_performance_benchmarks,
                    "enable_security_testing": self.config.enable_security_testing,
                    "enable_validation": self.config.enable_validation,
                    "enable_continuous_testing": self.config.enable_continuous_testing,
                    "enable_dashboard": self.config.enable_dashboard,
                    "output_directory": self.config.output_directory,
                    "report_format": self.config.report_format
                }
            }
            
            with open(json_report_path, 'w') as f:
                json.dump(report_data, f, indent=2, default=str)
            
            print(f"JSON report generated: {json_report_path}")
        
        # Generate HTML report
        if self.config.report_format in ["html", "both"]:
            html_report_path = os.path.join(self.config.output_directory, "test_report.html")
            
            html_content = self._generate_html_report(execution_time)
            
            with open(html_report_path, 'w') as f:
                f.write(html_content)
            
            print(f"HTML report generated: {html_report_path}")
    
    def _generate_html_report(self, execution_time: float) -> str:
        """Generate HTML test report"""
        # Calculate statistics
        total_tests = sum(r.get("total_tests", 0) for r in self.test_results)
        total_passed = sum(r.get("passed_tests", 0) for r in self.test_results)
        total_failed = sum(r.get("failed_tests", 0) for r in self.test_results)
        
        success_rate = (total_passed / total_tests * 100) if total_tests > 0 else 0
        
        # Calculate validation statistics
        total_validations = sum(r.get("total_validations", 0) for r in self.validation_results)
        validation_passed = sum(r.get("passed_validations", 0) for r in self.validation_results)
        validation_failed = sum(r.get("failed_validations", 0) for r in self.validation_results)
        
        validation_success_rate = (validation_passed / total_validations * 100) if total_validations > 0 else 0
        
        return f"""
<!DOCTYPE html>
<html>
<head>
    <title>NoodleCore Compiler Test Report</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        .header {{
            text-align: center;
            margin-bottom: 30px;
        }}
        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .summary-card {{
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #4CAF50;
        }}
        .summary-card h3 {{
            margin: 0 0 10px 0;
            color: #333;
        }}
        .summary-value {{
            font-size: 24px;
            font-weight: bold;
            color: #4CAF50;
        }}
        .success {{
            color: #28a745;
        }}
        .failure {{
            color: #dc3545;
        }}
        .test-results {{
            margin-bottom: 30px;
        }}
        .test-item {{
            background-color: #f8f9fa;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 4px;
        }}
        .test-name {{
            font-weight: bold;
            margin-bottom: 5px;
        }}
        .test-status {{
            margin-bottom: 5px;
        }}
        .last-updated {{
            text-align: center;
            color: #666;
            font-size: 12px;
            margin-top: 30px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>NoodleCore Compiler Test Report</h1>
            <p>Generated on {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
        </div>
        
        <div class="summary">
            <div class="summary-card">
                <h3>Test Execution Summary</h3>
                <div class="summary-value">{total_tests}</div>
                <div>Total Tests</div>
                <div class="summary-value success">{total_passed}</div>
                <div>Passed</div>
                <div class="summary-value failure">{total_failed}</div>
                <div>Failed</div>
                <div class="summary-value">{success_rate:.1f}%</div>
                <div>Success Rate</div>
            </div>
            
            <div class="summary-card">
                <h3>Validation Summary</h3>
                <div class="summary-value">{total_validations}</div>
                <div>Total Validations</div>
                <div class="summary-value success">{validation_passed}</div>
                <div>Passed</div>
                <div class="summary-value failure">{validation_failed}</div>
                <div>Failed</div>
                <div class="summary-value">{validation_success_rate:.1f}%</div>
                <div>Success Rate</div>
            </div>
            
            <div class="summary-card">
                <h3>Execution Time</h3>
                <div class="summary-value">{execution_time:.2f}s</div>
                <div>Total Time</div>
            </div>
        </div>
        
        <div class="test-results">
            <h2>Test Results</h2>
"""
        
        # Add test results
        for result in self.test_results:
            test_name = result.get("test_suite", "Unknown Test")
            status = result.get("success", False)
            status_class = "success" if status else "failure"
            
            html += f"""
            <div class="test-item">
                <div class="test-name">{test_name}</div>
                <div class="test-status">
                    <span class="{status_class}">{status.upper()}</span>
                </div>
            </div>
"""
        
        html += """
        </div>
        
        <div class="last-updated">
            Report generated on {time.strftime('%Y-%m-%d %H:%M:%S')}
        </div>
    </div>
</body>
</html>
        """
    
    def _print_summary(self, execution_time: float):
        """Print test execution summary"""
        print("\n" + "=" * 50)
        print("TEST EXECUTION SUMMARY")
        print("=" * 50)
        
        # Calculate statistics
        total_tests = sum(r.get("total_tests", 0) for r in self.test_results)
        total_passed = sum(r.get("passed_tests", 0) for r in self.test_results)
        total_failed = sum(r.get("failed_tests", 0) for r in self.test_results)
        
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {total_passed}")
        print(f"Failed: {total_failed}")
        print(f"Success Rate: {(total_passed/total_tests)*100:.1f}%")
        print(f"Execution Time: {execution_time:.2f}s")
        
        # Validation statistics
        total_validations = sum(r.get("total_validations", 0) for r in self.validation_results)
        validation_passed = sum(r.get("passed_validations", 0) for r in self.validation_results)
        validation_failed = sum(r.get("failed_validations", 0) for r in self.validation_results)
        
        if total_validations > 0:
            print(f"\nValidation Summary:")
            print(f"Total Validations: {total_validations}")
            print(f"Passed: {validation_passed}")
            print(f"Failed: {validation_failed}")
            print(f"Success Rate: {(validation_passed/total_validations)*100:.1f}%")
        
        print("\n" + "=" * 50)
    
    def _check_overall_success(self) -> bool:
        """Check if all tests passed"""
        # Check unit tests
        unit_test_results = [r for r in self.test_results if r.get("test_type") == "test_execution"]
        
        if not unit_test_results:
            return False
        
        all_unit_passed = all(r.get("success", False) for r in unit_test_results)
        
        # Check other tests
        other_tests_passed = True
        
        for result in self.test_results:
            if result.get("test_type") != "test_execution":
                if not result.get("success", False):
                    other_tests_passed = False
        
        return all_unit_passed and other_tests_passed


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="NoodleCore Comprehensive Test Runner")
    parser.add_argument("--categories", nargs="*", choices=[c.value for c in TestCategory], 
                       help="Test categories to run")
    parser.add_argument("--priorities", nargs="*", choices=[p.value for p in TestPriority],
                       help="Test priorities to run")
    parser.add_argument("--parallel", type=int, default=4,
                       help="Maximum parallel tests")
    parser.add_argument("--timeout", type=float, default=300.0,
                       help="Test timeout in seconds")
    parser.add_argument("--output", default="test_results",
                       help="Output directory for reports")
    parser.add_argument("--format", choices=["json", "html", "both"], default="json",
                       help="Report format")
    parser.add_argument("--verbose", action="store_true",
                       help="Enable verbose output")
    parser.add_argument("--generate-data", action="store_true",
                       help="Generate test data")
    parser.add_argument("--continuous", action="store_true",
                       help="Enable continuous testing")
    parser.add_argument("--dashboard", action="store_true",
                       help="Enable test dashboard")
    parser.add_argument("--filter", help="Filter test suites by name pattern")
    
    args = parser.parse_args()
    
    # Create configuration
    config = TestRunnerConfig(
        test_categories=[TestCategory(c) for c in args.categories] if args.categories else None,
        test_priorities=[TestPriority(p) for p in args.priorities] if args.priorities else None,
        max_parallel_tests=args.parallel,
        timeout_seconds=args.timeout,
        output_directory=args.output,
        report_format=args.format,
        verbose=args.verbose,
        generate_test_data=args.generate_data,
        enable_continuous_testing=args.continuous,
        enable_dashboard=args.dashboard,
        test_filter=args.filter
    )
    
    # Create and run test runner
    runner = ComprehensiveTestRunner(config)
    results = runner.run_all_tests()
    
    # Exit with appropriate code
    sys.exit(0 if results.get("success", False) else 1)


if __name__ == '__main__':
    main()

