#!/usr/bin/env python3
"""
Validate all JSON files in the project
"""
import json
import sys
from pathlib import Path

def validate_json_files():
    """Validate all JSON files in the project directory"""
    errors = []
    checked = 0

    # Exclude directories
    exclude_dirs = {
        'node_modules', '.git', '.venv', 'venv', 'env',
        'build', 'dist', '__pycache__', '.pytest_cache'
    }

    for json_file in Path('.').rglob('*.json'):
        # Skip excluded directories
        if any(excluded in str(json_file) for excluded in exclude_dirs):
            continue

        try:
            content = json_file.read_text(encoding='utf-8')
            json.loads(content)
            print(f'✓ {json_file}')
            checked += 1
        except json.JSONDecodeError as e:
            error_msg = f'✗ {json_file}: {e}'
            print(error_msg, file=sys.stderr)
            errors.append(error_msg)
        except Exception as e:
            error_msg = f'⚠ {json_file}: {e}'
            print(error_msg, file=sys.stderr)
            # Don't fail on permission errors, etc.

    print(f'\n📊 Checked {checked} JSON files')
    if errors:
        print(f'⚠ Found {len(errors)} error(s)')
        return 1

    print('✅ All JSON files are valid!')
    return 0

if __name__ == '__main__':
    sys.exit(validate_json_files())
