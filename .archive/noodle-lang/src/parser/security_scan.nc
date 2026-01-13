# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Security scanning script for NoodleCore with TRM-Agent
# """

import os
import sys
import json
import subprocess
import argparse
import typing.Dict


class SecurityScanner:
    #     """Security scanner for NoodleCore with TRM-Agent"""

    #     def __init__(self, output_dir: str = "security_reports"):
    self.output_dir = output_dir
    self.results = {}

    #         # Create output directory if it doesn't exist
    os.makedirs(self.output_dir, exist_ok = True)

    #     def run_bandit_scan(self) -Dict[str, Any]):
    #         """Run Bandit security scan"""
            print("Running Bandit security scan...")

    output_file = os.path.join(self.output_dir, "bandit_report.json")

    #         try:
    #             # Run Bandit scan
    cmd = [
    #                 "bandit",
    #                 "-r", "src/",
    #                 "-f", "json",
    #                 "-o", output_file,
    #                 "-c", ".bandit"
    #             ]

    result = subprocess.run(
    #                 cmd,
    capture_output = True,
    text = True,
    check = False
    #             )

    #             # Parse results
    #             if os.path.exists(output_file):
    #                 with open(output_file, "r") as f:
    bandit_results = json.load(f)
    #             else:
    bandit_results = {"results": [], "metrics": {}}

    self.results["bandit"] = {
    #                 "exit_code": result.returncode,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    #                 "results": bandit_results
    #             }

    #             print(f"Bandit scan completed with exit code: {result.returncode}")

    #             if result.returncode = 0:
                    print("✅ No security issues found by Bandit")
    #             else:
                    print(f"⚠️ Bandit found {len(bandit_results.get('results', []))} potential security issues")

    #             return self.results["bandit"]
    #         except Exception as e:
                print(f"❌ Error running Bandit scan: {str(e)}")
    self.results["bandit"] = {"error": str(e)}
    #             return self.results["bandit"]

    #     def run_safety_scan(self) -Dict[str, Any]):
    #         """Run Safety dependency scan"""
            print("Running Safety dependency scan...")

    output_file = os.path.join(self.output_dir, "safety_report.json")

    #         try:
    #             # Run Safety scan
    cmd = [
    #                 "safety",
    #                 "check",
    #                 "--json",
    #                 "--output", output_file
    #             ]

    result = subprocess.run(
    #                 cmd,
    capture_output = True,
    text = True,
    check = False
    #             )

    #             # Parse results
    #             if os.path.exists(output_file):
    #                 with open(output_file, "r") as f:
    safety_results = json.load(f)
    #             else:
    safety_results = []

    self.results["safety"] = {
    #                 "exit_code": result.returncode,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    #                 "results": safety_results
    #             }

    #             print(f"Safety scan completed with exit code: {result.returncode}")

    #             if result.returncode = 0:
                    print("✅ No security vulnerabilities found by Safety")
    #             else:
                    print(f"⚠️ Safety found {len(safety_results)} potential security vulnerabilities")

    #             return self.results["safety"]
    #         except Exception as e:
                print(f"❌ Error running Safety scan: {str(e)}")
    self.results["safety"] = {"error": str(e)}
    #             return self.results["safety"]

    #     def run_semgrep_scan(self) -Dict[str, Any]):
    #         """Run Semgrep static analysis"""
            print("Running Semgrep static analysis...")

    output_file = os.path.join(self.output_dir, "semgrep_report.json")

    #         try:
    #             # Run Semgrep scan
    cmd = [
    #                 "semgrep",
    "--config = auto",
    #                 "--json",
    #                 "--output", output_file,
    #                 "src/"
    #             ]

    result = subprocess.run(
    #                 cmd,
    capture_output = True,
    text = True,
    check = False
    #             )

    #             # Parse results
    #             if os.path.exists(output_file):
    #                 with open(output_file, "r") as f:
    semgrep_results = json.load(f)
    #             else:
    semgrep_results = {"results": []}

    self.results["semgrep"] = {
    #                 "exit_code": result.returncode,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    #                 "results": semgrep_results
    #             }

    #             print(f"Semgrep scan completed with exit code: {result.returncode}")

    #             if result.returncode = 0:
                    print("✅ No security issues found by Semgrep")
    #             else:
                    print(f"⚠️ Semgrep found {len(semgrep_results.get('results', []))} potential security issues")

    #             return self.results["semgrep"]
    #         except Exception as e:
                print(f"❌ Error running Semgrep scan: {str(e)}")
    self.results["semgrep"] = {"error": str(e)}
    #             return self.results["semgrep"]

    #     def run_trivy_scan(self) -Dict[str, Any]):
    #         """Run Trivy container scan"""
            print("Running Trivy container scan...")

    output_file = os.path.join(self.output_dir, "trivy_report.json")

    #         try:
    #             # Run Trivy scan
    cmd = [
    #                 "trivy",
    #                 "image",
    #                 "--format", "json",
    #                 "--output", output_file,
    #                 "noodleai/noodle-core:latest"
    #             ]

    result = subprocess.run(
    #                 cmd,
    capture_output = True,
    text = True,
    check = False
    #             )

    #             # Parse results
    #             if os.path.exists(output_file):
    #                 with open(output_file, "r") as f:
    trivy_results = json.load(f)
    #             else:
    trivy_results = {"Results": []}

    self.results["trivy"] = {
    #                 "exit_code": result.returncode,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    #                 "results": trivy_results
    #             }

    #             print(f"Trivy scan completed with exit code: {result.returncode}")

    #             if result.returncode = 0:
                    print("✅ No security vulnerabilities found by Trivy")
    #             else:
    vulnerabilities = 0
    #                 for scan_result in trivy_results.get("Results", []):
    vulnerabilities + = len(scan_result.get("Vulnerabilities", []))

                    print(f"⚠️ Trivy found {vulnerabilities} potential security vulnerabilities")

    #             return self.results["trivy"]
    #         except Exception as e:
                print(f"❌ Error running Trivy scan: {str(e)}")
    self.results["trivy"] = {"error": str(e)}
    #             return self.results["trivy"]

    #     def run_dockerfile_scan(self) -Dict[str, Any]):
    #         """Run Dockerfile security scan"""
            print("Running Dockerfile security scan...")

    output_file = os.path.join(self.output_dir, "dockerfile_report.json")

    #         try:
    #             # Run Dockerfile scan
    cmd = [
    #                 "hadolint",
    #                 "--format", "json",
    #                 "Dockerfile"
    #             ]

    result = subprocess.run(
    #                 cmd,
    capture_output = True,
    text = True,
    check = False
    #             )

    #             # Parse results
    #             if result.stdout:
    #                 try:
    dockerfile_results = json.loads(result.stdout)
    #                 except json.JSONDecodeError:
    dockerfile_results = []
    #             else:
    dockerfile_results = []

    self.results["dockerfile"] = {
    #                 "exit_code": result.returncode,
    #                 "stdout": result.stdout,
    #                 "stderr": result.stderr,
    #                 "results": dockerfile_results
    #             }

    #             print(f"Dockerfile scan completed with exit code: {result.returncode}")

    #             if result.returncode = 0:
                    print("✅ No security issues found in Dockerfile")
    #             else:
                    print(f"⚠️ Found {len(dockerfile_results)} potential security issues in Dockerfile")

    #             return self.results["dockerfile"]
    #         except Exception as e:
                print(f"❌ Error running Dockerfile scan: {str(e)}")
    self.results["dockerfile"] = {"error": str(e)}
    #             return self.results["dockerfile"]

    #     def run_all_scans(self) -Dict[str, Any]):
    #         """Run all security scans"""
            print("Starting comprehensive security scan...")

    #         # Run Bandit scan
            self.run_bandit_scan()

    #         # Run Safety scan
            self.run_safety_scan()

            # Try to run Semgrep scan (optional)
    #         try:
    subprocess.run(["semgrep", "--version"], capture_output = True, check=True)
                self.run_semgrep_scan()
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("⚠️ Semgrep not installed, skipping Semgrep scan")
    self.results["semgrep"] = {"skipped": True}

            # Try to run Trivy scan (optional)
    #         try:
    subprocess.run(["trivy", "--version"], capture_output = True, check=True)
                self.run_trivy_scan()
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("⚠️ Trivy not installed, skipping Trivy scan")
    self.results["trivy"] = {"skipped": True}

            # Try to run Hadolint scan (optional)
    #         try:
    subprocess.run(["hadolint", "--version"], capture_output = True, check=True)
                self.run_dockerfile_scan()
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("⚠️ Hadolint not installed, skipping Dockerfile scan")
    self.results["dockerfile"] = {"skipped": True}

    #         return self.results

    #     def generate_report(self) -str):
    #         """Generate comprehensive security report"""
    report_file = os.path.join(self.output_dir, "security_report.json")

    #         # Calculate summary
    total_issues = 0
    scan_summary = {}

    #         for scan_name, scan_results in self.results.items():
    #             if "error" in scan_results or "skipped" in scan_results:
    scan_summary[scan_name] = {
    #                     "status": "error" if "error" in scan_results else "skipped",
    #                     "issues": 0
    #                 }
    #                 continue

    #             if scan_name == "bandit":
    issues = len(scan_results.get("results", {}).get("results", []))
    #             elif scan_name == "safety":
    issues = len(scan_results.get("results", []))
    #             elif scan_name == "semgrep":
    issues = len(scan_results.get("results", {}).get("results", []))
    #             elif scan_name == "trivy":
    issues = 0
    #                 for scan_result in scan_results.get("results", {}).get("Results", []):
    issues + = len(scan_result.get("Vulnerabilities", []))
    #             elif scan_name == "dockerfile":
    issues = len(scan_results.get("results", []))
    #             else:
    issues = 0

    total_issues + = issues
    scan_summary[scan_name] = {
    #                 "status": "success",
    #                 "issues": issues
    #             }

    #         # Create report
    report = {
    "scan_date": subprocess.check_output(["date"], text = True).strip(),
    #             "total_issues": total_issues,
    #             "scan_summary": scan_summary,
    #             "detailed_results": self.results
    #         }

    #         # Save report
    #         with open(report_file, "w") as f:
    json.dump(report, f, indent = 2)

            print(f"Security report saved to {report_file}")

    #         return report_file

    #     def print_summary(self):
    #         """Print security scan summary"""
    print("\n = == SECURITY SCAN SUMMARY ===")

    total_issues = 0

    #         for scan_name, scan_results in self.results.items():
    #             if "error" in scan_results:
                    print(f"❌ {scan_name.upper()}: Error - {scan_results['error']}")
    #             elif "skipped" in scan_results:
                    print(f"⚠️ {scan_name.upper()}: Skipped")
    #             else:
    #                 if scan_name == "bandit":
    issues = len(scan_results.get("results", {}).get("results", []))
    #                 elif scan_name == "safety":
    issues = len(scan_results.get("results", []))
    #                 elif scan_name == "semgrep":
    issues = len(scan_results.get("results", {}).get("results", []))
    #                 elif scan_name == "trivy":
    issues = 0
    #                     for scan_result in scan_results.get("results", {}).get("Results", []):
    issues + = len(scan_result.get("Vulnerabilities", []))
    #                 elif scan_name == "dockerfile":
    issues = len(scan_results.get("results", []))
    #                 else:
    issues = 0

    total_issues + = issues

    #                 if issues 0):
                        print(f"⚠️ {scan_name.upper()}: {issues} issues found")
    #                 else:
                        print(f"✅ {scan_name.upper()}: No issues found")

            print(f"\nTotal security issues found: {total_issues}")

    #         if total_issues 0):
                print("⚠️ Security issues detected. Please review the detailed reports.")
    #         else:
                print("✅ No security issues detected. All scans passed!")


function main()
    #     """Main function"""
    parser = argparse.ArgumentParser(description="NoodleCore Security Scanner")
    #     parser.add_argument("--output-dir", default="security_reports", help="Output directory for reports")
    parser.add_argument("--bandit-only", action = "store_true", help="Run only Bandit scan")
    parser.add_argument("--safety-only", action = "store_true", help="Run only Safety scan")
    parser.add_argument("--semgrep-only", action = "store_true", help="Run only Semgrep scan")
    parser.add_argument("--trivy-only", action = "store_true", help="Run only Trivy scan")
    parser.add_argument("--dockerfile-only", action = "store_true", help="Run only Dockerfile scan")

    args = parser.parse_args()

    scanner = SecurityScanner(args.output_dir)

    #     if args.bandit_only:
            scanner.run_bandit_scan()
    #     elif args.safety_only:
            scanner.run_safety_scan()
    #     elif args.semgrep_only:
            scanner.run_semgrep_scan()
    #     elif args.trivy_only:
            scanner.run_trivy_scan()
    #     elif args.dockerfile_only:
            scanner.run_dockerfile_scan()
    #     else:
            scanner.run_all_scans()

        scanner.generate_report()
        scanner.print_summary()


if __name__ == "__main__"
        main()