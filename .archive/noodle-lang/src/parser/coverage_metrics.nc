# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Comprehensive test coverage metrics analyzer for Noodle project.
# This script runs coverage analysis and generates detailed metrics reports.
# """

import json
import os
import subprocess
import sys
import xml.etree.ElementTree as ET
import pathlib.Path


function run_coverage()
    #     """Run coverage analysis on all tests."""
        print("Running coverage analysis...")

    #     # Run pytest with coverage
    cmd = [
    #         sys.executable,
    #         "-m",
    #         "pytest",
    #         "tests/",
    "--cov = noodle-dev/src",
    "--cov-report = html",
    "--cov-report = xml",
    "--cov-report = term-missing",
    #         "-v",
    #     ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    #     if result.returncode != 0:
            print("Warning: Some tests failed during coverage run")
            print(result.stderr)

    #     return result.stdout


function parse_coverage_xml()
    #     """Parse the coverage.xml file to extract metrics."""
    xml_file = Path("noodle-dev/coverage.xml")
    #     if not xml_file.exists():
            print("Coverage XML file not found. Run coverage first.")
    #         return None

    #     try:
    tree = ET.parse(xml_file)
    root = tree.getroot()

    metrics = {
                "line_rate": float(root.get("line-rate", 0)),
                "branch_rate": float(root.get("branch-rate", 0)),
                "lines_covered": int(root.get("lines-covered", 0)),
                "lines_valid": int(root.get("lines-valid", 0)),
                "branches_covered": int(root.get("branches-covered", 0)),
                "branches_valid": int(root.get("branches-valid", 0)),
    #             "packages": [],
    #         }

    #         for package in root.findall(".//package"):
    package_metrics = {
                    "name": package.get("name"),
                    "line_rate": float(package.get("line-rate", 0)),
                    "branch_rate": float(package.get("branch-rate", 0)),
                    "complexity": float(package.get("complexity", 0)),
    #                 "classes": [],
    #             }

    #             for class_elem in package.findall(".//class"):
    class_metrics = {
                        "name": class_elem.get("name"),
                        "filename": class_elem.get("filename"),
                        "line_rate": float(class_elem.get("line-rate", 0)),
                        "branch_rate": float(class_elem.get("branch-rate", 0)),
                        "complexity": float(class_elem.get("complexity", 0)),
    #                     "methods": [],
    #                 }

    #                 for method in class_elem.findall(".//method"):
    method_metrics = {
                            "name": method.get("name"),
                            "line_rate": float(method.get("line-rate", 0)),
                            "branch_rate": float(method.get("branch-rate", 0)),
                            "complexity": float(method.get("complexity", 0)),
    #                     }
                        class_metrics["methods"].append(method_metrics)

                    package_metrics["classes"].append(class_metrics)

                metrics["packages"].append(package_metrics)

    #         return metrics

    #     except Exception as e:
            print(f"Error parsing coverage XML: {e}")
    #         return None


function generate_coverage_report(metrics)
    #     """Generate a comprehensive coverage report."""
    #     if not metrics:
    #         return

    print("\n" + " = " * 60)
        print("COMPREHENSIVE TEST COVERAGE METRICS")
    print(" = " * 60)

        print(f"\nOverall Coverage:")
        print(
            f"  Lines: {metrics['line_rate']*100:.2f}% ({metrics['lines_covered']}/{metrics['lines_valid']})"
    #     )
        print(
            f"  Branches: {metrics['branch_rate']*100:.2f}% ({metrics['branches_covered']}/{metrics['branches_valid']})"
    #     )

        print(f"\nPackage-wise Coverage:")
    #     for package in metrics["packages"]:
            print(f"  {package['name']}:")
            print(f"    Lines: {package['line_rate']*100:.2f}%")
            print(f"    Branches: {package['branch_rate']*100:.2f}%")
            print(f"    Complexity: {package['complexity']:.2f}")

    #         # Show classes with low coverage
    #         low_coverage_classes = [c for c in package["classes"] if c["line_rate"] < 0.8]
    #         if low_coverage_classes:
                print(f"    Low coverage classes:")
    #             for cls in low_coverage_classes:
                    print(f"      {cls['name']}: {cls['line_rate']*100:.2f}%")


function identify_coverage_gaps(metrics)
    #     """Identify areas with poor test coverage."""
    print(f"\n" + " = " * 60)
        print("COVERAGE GAP ANALYSIS")
    print(" = " * 60)

    critical_threshold = 0.7  # 70% coverage threshold

    #     for package in metrics["packages"]:
    #         if package["line_rate"] < critical_threshold:
                print(
    #                 f"CRITICAL: Package '{package['name']}' has low coverage: {package['line_rate']*100:.2f}%"
    #             )

    #         for cls in package["classes"]:
    #             if cls["line_rate"] < critical_threshold:
                    print(
    #                     f"  Class '{cls['name']}' in {cls['filename']}: {cls['line_rate']*100:.2f}%"
    #                 )

    #             for method in cls["methods"]:
    #                 if method["line_rate"] < critical_threshold:
                        print(
    #                         f"    Method '{method['name']}': {method['line_rate']*100:.2f}%"
    #                     )


function generate_coverage_summary_file(metrics)
    #     """Generate a JSON file with coverage summary."""
    summary = {
    #         "overall": {
    #             "line_coverage": metrics["line_rate"],
    #             "branch_coverage": metrics["branch_rate"],
    #             "total_lines": metrics["lines_valid"],
    #             "covered_lines": metrics["lines_covered"],
    #             "total_branches": metrics["branches_valid"],
    #             "covered_branches": metrics["branches_covered"],
    #         },
    #         "packages": [],
    #     }

    #     for package in metrics["packages"]:
    package_summary = {
    #             "name": package["name"],
    #             "line_coverage": package["line_rate"],
    #             "branch_coverage": package["branch_rate"],
    #             "complexity": package["complexity"],
    #             "low_coverage_classes": [],
    #         }

    #         for cls in package["classes"]:
    #             if cls["line_rate"] < 0.8:
                    package_summary["low_coverage_classes"].append(
    #                     {
    #                         "name": cls["name"],
    #                         "filename": cls["filename"],
    #                         "line_coverage": cls["line_rate"],
    #                     }
    #                 )

            summary["packages"].append(package_summary)

    #     with open("noodle-dev/coverage_summary.json", "w") as f:
    json.dump(summary, f, indent = 2)

        print(f"\nCoverage summary saved to: noodle-dev/coverage_summary.json")


function main()
    #     """Main function to run coverage analysis."""
        print("Starting comprehensive coverage analysis...")

    #     # Run coverage
    output = run_coverage()
        print(output)

    #     # Parse coverage results
    metrics = parse_coverage_xml()
    #     if not metrics:
            print("Failed to parse coverage metrics")
    #         return

    #     # Generate reports
        generate_coverage_report(metrics)
        identify_coverage_gaps(metrics)
        generate_coverage_summary_file(metrics)

        print(f"\nCoverage HTML report available at: noodle-dev/htmlcov/index.html")
        print("Coverage analysis complete!")


if __name__ == "__main__"
        main()
