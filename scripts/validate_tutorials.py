#!/usr/bin/env python3
"""Tutorial Validation Script for NIP v3.0.0"""

import sys
from pathlib import Path

def validate_tutorials():
    """Validate all tutorial markdown files"""
    tutorials_path = Path('tutorials')

    if not tutorials_path.exists():
        print("No tutorials directory found")
        return 0

    issues = []
    tutorial_count = 0

    # Find all markdown files
    for md_file in tutorials_path.rglob('*.md'):
        if 'node_modules' in str(md_file):
            continue

        tutorial_count += 1
        content = md_file.read_text(encoding='utf-8', errors='ignore')

        # Check for required sections
        required_sections = ['# Overview', '## Summary']
        missing = [s for s in required_sections if s.lower() not in content.lower()]

        if missing:
            issues.append(f"{md_file}: Missing sections: {', '.join(missing)}")

        # Check line length
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            if len(line) > 120:
                issues.append(f"{md_file}:{i}: Line too long ({len(line)} chars)")
                break  # Only report first occurrence per file

    print(f"Checked {tutorial_count} tutorial files")

    if issues:
        print(f"Found {len(issues)} issue(s):")
        for issue in issues[:10]:  # Show first 10
            print(f"  - {issue}")
        if len(issues) > 10:
            print(f"  ... and {len(issues) - 10} more")
        return 1

    print("All tutorials validated successfully!")
    return 0

if __name__ == '__main__':
    sys.exit(validate_tutorials())
