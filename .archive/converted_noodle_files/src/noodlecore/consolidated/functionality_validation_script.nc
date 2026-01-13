# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Functionality Preservation Validation Script
 = =========================================
# Validates that all consolidated components maintain original functionality.
# Part of Noodle Project Reorganization - Phase 2.10

# Author: Noodle Reorganization Team
# Date: 2025-11-10
# Purpose: Ensure zero functionality loss during consolidation
# """

import os
import sys
import json
import hashlib
import logging
import pathlib.Path
import typing.Dict,
import datetime.datetime

# Setup logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(levelname)s - %(message)s'
# )
logger = logging.getLogger(__name__)

class FunctionalityValidator
    #     """Validates functionality preservation after consolidation."""

    #     def __init__(self):
    #         """Initialize the functionality validator."""
    self.base_path = Path.cwd()
    self.backup_dir = self.base_path / "backup_pre_reorganization"
    self.unified_dirs = {
    #             "core": self.base_path / "noodle-core" / "src" / "noodlecore" / "consolidated",
    #             "ide": self.base_path / "noodle-ide-unified",
    #             "lang": self.base_path / "noodle-lang"
    #         }

    #         # Test results
    self.validation_results = {
    #             "total_tests": 0,
    #             "passed_tests": 0,
    #             "failed_tests": 0,
    #             "warnings": [],
    #             "errors": [],
    #             "missing_files": [],
    #             "hash_mismatches": []
    #         }

    #     def create_test_suite(self):
    #         """Create comprehensive test suite for all consolidated components."""
            logger.info("🧪 Creating functionality test suite...")

    test_categories = {
    #             "import_tests": "Verify all imports work correctly",
    #             "syntax_tests": "Validate syntax correctness",
    #             "structure_tests": "Check file structure integrity",
    #             "api_tests": "Test API functionality",
    #             "integration_tests": "Cross-component integration"
    #         }

    test_suite = {
                "validation_timestamp": datetime.now().isoformat(),
    #             "consolidated_components": {
    #                 "core_runtime": {
                        "location": str(self.unified_dirs["core"]),
    #                     "expected_files": "600+",
    #                     "components": ["runtime", "compiler", "api", "database", "ai", "utils"]
    #                 },
    #                 "ide_components": {
                        "location": str(self.unified_dirs["ide"]),
    #                     "expected_files": "30+",
    #                     "components": ["native", "web", "shared"]
    #                 },
    #                 "language_components": {
                        "location": str(self.unified_dirs["lang"]),
    #                     "expected_files": "500+",
    #                     "components": ["parser", "compiler", "lexer", "stdlib", "runtime"]
    #                 }
    #             },
    #             "test_categories": test_categories,
    #             "validation_criteria": {
    #                 "file_presence": "All original files must exist in unified structure",
    #                 "syntax_validity": "All Python/.nc files must have valid syntax",
    #                 "import_ability": "All modules must be importable",
    #                 "function_preservation": "All original functions must remain accessible"
    #             }
    #         }

    test_file = self.base_path / "docs" / "functionality_test_suite.json"
    #         with open(test_file, 'w') as f:
    json.dump(test_suite, f, indent = 2)

            logger.info(f"  ✅ Test suite created: {test_file}")
    #         return test_suite

    #     def validate_file_presence(self):
    #         """Validate that all original files are present in unified structure."""
            logger.info("📁 Validating file presence...")

    #         # Collect all .nc and .py files from original locations
    original_files = set()
    #         for backup_subdir in self.backup_dir.iterdir():
    #             if backup_subdir.is_dir():
    #                 for file_path in backup_subdir.rglob("*.nc"):
                        original_files.add(file_path.relative_to(backup_subdir))
    #                 for file_path in backup_subdir.rglob("*.py"):
                        original_files.add(file_path.relative_to(backup_subdir))

            logger.info(f"  Found {len(original_files)} original files to validate")

    #         # Check presence in unified structure
    unified_files = set()
    #         for component_dir in self.unified_dirs.values():
    #             if component_dir.exists():
    #                 for file_path in component_dir.rglob("*.nc"):
                        unified_files.add(file_path.relative_to(component_dir))
    #                 for file_path in component_dir.rglob("*.py"):
                        unified_files.add(file_path.relative_to(component_dir))

    missing_files = math.subtract(original_files, unified_files)
    extra_files = math.subtract(unified_files, original_files)

    self.validation_results["total_tests"] + = 1
    #         if not missing_files:
    self.validation_results["passed_tests"] + = 1
                logger.info("  ✅ All original files present in unified structure")
    #         else:
    self.validation_results["failed_tests"] + = 1
    self.validation_results["missing_files"] = list(missing_files)
                logger.warning(f"  ⚠️ {len(missing_files)} files missing from unified structure")

            logger.info(f"  📊 Found {len(unified_files)} files in unified structure")
            logger.info(f"  📊 Found {len(extra_files)} additional files in unified structure")

    #         return {
                "original_count": len(original_files),
                "unified_count": len(unified_files),
                "missing_files": list(missing_files),
                "extra_files": list(extra_files)
    #         }

    #     def validate_syntax_validity(self):
    #         """Validate syntax correctness of all Python files."""
            logger.info("🔍 Validating syntax validity...")

    syntax_errors = []

    #         for component_dir in self.unified_dirs.values():
    #             if component_dir.exists():
    #                 for py_file in component_dir.rglob("*.py"):
    #                     try:
    #                         # Try to compile the file to check syntax
    #                         with open(py_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()
                            compile(content, py_file, 'exec')
    #                     except SyntaxError as e:
                            syntax_errors.append({
                                "file": str(py_file),
                                "error": str(e),
                                "line": getattr(e, 'lineno', 'unknown')
    #                         })
    #                     except Exception as e:
                            # Non-syntax errors (encoding, etc.) are warnings
                            logger.warning(f"  Non-syntax error in {py_file}: {e}")

    self.validation_results["total_tests"] + = 1
    #         if not syntax_errors:
    self.validation_results["passed_tests"] + = 1
                logger.info("  ✅ All Python files have valid syntax")
    #         else:
    self.validation_results["failed_tests"] + = 1
                self.validation_results["errors"].extend(syntax_errors)
                logger.error(f"  ❌ {len(syntax_errors)} Python files have syntax errors")

    #         return {
    #             "total_python_files": len(list(self.unified_dirs["core"].rglob("*.py"))) if self.unified_dirs["core"].exists() else 0,
    #             "syntax_errors": syntax_errors,
                "error_count": len(syntax_errors)
    #         }

    #     def generate_validation_report(self):
    #         """Generate comprehensive validation report."""
            logger.info("📋 Generating validation report...")

    #         # Calculate overall success rate
    #         if self.validation_results["total_tests"] > 0:
    success_rate = (self.validation_results["passed_tests"] / self.validation_results["total_tests"]) * 100
    #         else:
    success_rate = 0

    report_content = f"""# Functionality Preservation Validation Report

**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
# **Status:** {'✅ PASSED' if success_rate >= 80 else '⚠️ PARTIAL' if success_rate >= 60 else '❌ FAILED'}

## 🎯 **Validation Summary**

# - **Total Tests Run:** {self.validation_results['total_tests']}
- **Tests Passed:** {self.validation_results['passed_tests']} ({success_rate:.1f}%)
# - **Tests Failed:** {self.validation_results['failed_tests']}
# - **Overall Status:** {'PASS' if success_rate >= 80 else 'PARTIAL' if success_rate >= 60 else 'FAIL'}

## 📊 **Consolidated Components Status**

### Core Runtime (noodle-core/src/noodlecore/consolidated/)
# - **Status:** {'✅ AVAILABLE' if self.unified_dirs['core'].exists() else '❌ MISSING'}
# - **Location:** {self.unified_dirs['core']}
# - **Expected Files:** 600+ files

### IDE Components (noodle-ide-unified/)
# - **Status:** {'✅ AVAILABLE' if self.unified_dirs['ide'].exists() else '❌ MISSING'}
# - **Location:** {self.unified_dirs['ide']}
# - **Expected Files:** 30+ files

### Language Components (noodle-lang/)
# - **Status:** {'✅ AVAILABLE' if self.unified_dirs['lang'].exists() else '❌ MISSING'}
# - **Location:** {self.unified_dirs['lang']}
# - **Expected Files:** 500+ files

## 🔍 **Validation Results**

### File Presence Validation
# - **Result:** {'✅ PASSED' if not self.validation_results['missing_files'] else '⚠️ PARTIAL'}
- **Missing Files:** {len(self.validation_results['missing_files'])}

### Syntax Validation
# - **Result:** {'✅ PASSED' if not any('SyntaxError' in str(e) for e in self.validation_results['errors']) else '❌ FAILED'}

## 🎯 **Recommendations**

# 1. **If PASSED:** Proceed to Phase 3: Integration & Testing
# 2. **If PARTIAL:** Address warnings and missing files before proceeding
# 3. **If FAILED:** Fix critical issues before continuing

## 🔒 **Rollback Information**

# All original files are safely backed up in:
# `{self.backup_dir}`

# Complete rollback is available if validation fails.

# ---
*Validation completed at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
# """

report_path = self.base_path / "docs" / "functionality_validation_report.md"
#         with open(report_path, 'w', encoding='utf-8') as f:
            f.write(report_content)

        logger.info(f"  ✅ Validation report created: {report_path}")

#         return {
#             "success_rate": success_rate,
#             "status": "PASS" if success_rate >= 80 else "PARTIAL" if success_rate >= 60 else "FAIL",
            "report_path": str(report_path)
#         }

#     def run_validation(self):
#         """Run complete functionality validation."""
        logger.info("🚀 Starting Functionality Preservation Validation")

#         try:
#             # Create test suite
test_suite = self.create_test_suite()

#             # Run validation tests
file_validation = self.validate_file_presence()
syntax_validation = self.validate_syntax_validity()

#             # Generate report
report = self.generate_validation_report()

            logger.info("✅ Functionality validation completed!")
            logger.info(f"📊 Success Rate: {report['success_rate']:.1f}%")
            logger.info(f"🎯 Status: {report['status']}")

#             return report

#         except Exception as e:
            logger.error(f"❌ Functionality validation failed: {e}")
#             raise

if __name__ == "__main__"
    validator = FunctionalityValidator()
        validator.run_validation()