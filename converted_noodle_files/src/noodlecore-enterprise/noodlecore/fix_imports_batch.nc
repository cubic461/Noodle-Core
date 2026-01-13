# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Script to fix import paths from 'noodle.*' to 'noodlecore.*' in test files
# """

import os
import re
import sys
import pathlib.Path

function fix_imports_in_file(file_path)
    #     """Fix import paths in a single file"""
    #     try:
    #         with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #         # Pattern to match imports from noodle.*
    pattern = r'from\s+noodle\.|import\s+noodle\.'

    #         # Replace noodle. with noodlecore.
    content = re.sub(r'from\s+noodle\.', 'from noodlecore.', content)
    content = re.sub(r'import\s+noodle\.', 'import noodlecore.', content)

    #         # Write the fixed content back
    #         with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

    #         return True
    #     except Exception as e:
            print(f"Error processing {file_path}: {e}")
    #         return False

function main()
    #     """Main function to fix imports in all test files"""
    tests_dir = Path(__file__).parent / "tests"

    #     if not tests_dir.exists():
            print(f"Tests directory not found: {tests_dir}")
    #         return 1

    #     # Count of files processed
    processed = 0
    fixed = 0

    #     # Walk through all Python files in the tests directory
    #     for py_file in tests_dir.rglob("*.py"):
    processed + = 1
    #         if fix_imports_in_file(py_file):
    fixed + = 1
                print(f"Fixed imports in: {py_file}")

        print(f"\nProcessed {processed} files, fixed imports in {fixed} files")
    #     return 0

if __name__ == "__main__"
        sys.exit(main())