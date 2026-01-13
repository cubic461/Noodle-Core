#!/usr/bin/env python3
"""
Noodle Core::Fix Encrypted Config - fix_encrypted_config.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Script to fix the encrypted configuration issue.
This will reset the encrypted configuration so that API keys are properly saved.
"""

import os
import sys
import shutil
from pathlib import Path

# Add src to path
current_dir = Path(__file__).parent
src_dir = current_dir / "src"
sys.path.insert(0, str(src_dir))

def main():
    print("Resetting encrypted configuration to fix the key storage issue...")
    
    # Get the config directory
    if os.name == 'nt':  # Windows
        config_dir = Path(os.environ.get('APPDATA', '')) / 'NoodleCore'
    else:  # Unix-like systems
        config_dir = Path.home() / '.noodlecore'
    
    # File paths
    encrypted_config_file = config_dir / 'encrypted_config.json'
    key_file = config_dir / '.config_key'
    
    # Create backup of existing config
    if encrypted_config_file.exists():
        backup_file = encrypted_config_file.with_suffix('.json.backup_before_fix')
        print(f"Creating backup of existing config to: {backup_file}")
        shutil.copy2(encrypted_config_file, backup_file)
    
    # Remove existing key file to force regeneration
    if key_file.exists():
        print(f"Removing existing key file: {key_file}")
        key_file.unlink()
    
    # Remove existing encrypted config
    if encrypted_config_file.exists():
        print(f"Removing existing encrypted config: {encrypted_config_file}")
        encrypted_config_file.unlink()
    
    print("\nConfiguration reset complete!")
    print("Please restart the IDE and enter your AI key again.")
    print("It should now be properly saved and persist across restarts.")

if __name__ == "__main__":
    main()

