#!/usr/bin/env python3
"""
Noodle Core::Debug Encrypted Config - debug_encrypted_config.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script for encrypted configuration system.
This will help identify why API keys are not being persisted.
"""

import os
import sys
import json
import shutil
from pathlib import Path

# Add src to path
current_dir = Path(__file__).parent
src_dir = current_dir / "src"
sys.path.insert(0, str(src_dir))

def main():
    print("ðŸ” Debugging Encrypted Configuration System...")
    print("=" * 60)
    
    # Get the expected config directory
    if os.name == 'nt':  # Windows
        expected_config_dir = Path(os.environ.get('APPDATA', '')) / 'NoodleCore'
    else:  # Unix-like systems
        expected_config_dir = Path.home() / '.noodlecore'
    
    print(f"Expected config directory: {expected_config_dir}")
    
    # Check if directory exists
    if expected_config_dir.exists():
        print(f"âœ… Config directory exists")
        # List files in directory
        files = list(expected_config_dir.iterdir())
        print(f"Files in config directory: {files}")
        
        # Check for encrypted config files
        encrypted_config_file = expected_config_dir / 'encrypted_config.json'
        key_file = expected_config_dir / '.config_key'
        
        print(f"\nEncrypted config file exists: {encrypted_config_file.exists()}")
        print(f"Key file exists: {key_file.exists()}")
        
        # Check IDE subdirectory
        ide_dir = expected_config_dir / 'IDE'
        if ide_dir.exists():
            print(f"\nIDE subdirectory exists: {ide_dir}")
            ide_files = list(ide_dir.iterdir())
            print(f"Files in IDE directory: {ide_files}")
            
            # Check IDE settings file
            ide_settings = ide_dir / 'noodlecore_ide_settings.json'
            if ide_settings.exists():
                print(f"\nIDE settings file exists: {ide_settings}")
                with open(ide_settings, 'r') as f:
                    settings = json.load(f)
                    print(f"IDE settings content: {json.dumps(settings, indent=2)}")
    else:
        print(f"âŒ Config directory does not exist")
    
    # Test importing the encrypted config module
    print(f"\n" + "=" * 60)
    print("Testing encrypted config module import...")
    try:
        from noodlecore.config import EncryptedConfigManager, get_ai_config, save_ai_config
        print("âœ… Successfully imported encrypted configuration module")
        
        # Test creating a config manager
        print("\nTesting config manager creation...")
        config_manager = EncryptedConfigManager()
        print(f"Config manager directory: {config_manager.config_dir}")
        print(f"Encrypted config file path: {config_manager.encrypted_config_file}")
        print(f"Key file path: {config_manager.key_file}")
        
        # Test getting AI config
        print("\nTesting get_ai_config...")
        ai_config = get_ai_config()
        print(f"Provider: {ai_config.get('provider', 'Not set')}")
        print(f"Model: {ai_config.get('model', 'Not set')}")
        print(f"API Key set: {'Yes' if ai_config.get('api_key') else 'No'}")
        
        # Test saving AI config
        print("\nTesting save_ai_config...")
        save_ai_config('TestProvider', 'test-model', 'test-api-key-12345', False)
        print("âœ… Test config saved")
        
        # Verify save
        print("\nVerifying saved config...")
        updated_config = get_ai_config()
        print(f"Provider: {updated_config.get('provider', 'Not set')}")
        print(f"Model: {updated_config.get('model', 'Not set')}")
        print(f"API Key set: {'Yes' if updated_config.get('api_key') else 'No'}")
        
        # Check if files were actually created
        print(f"\nChecking if files were created...")
        print(f"Encrypted config file exists: {encrypted_config_file.exists()}")
        print(f"Key file exists: {key_file.exists()}")
        
        if encrypted_config_file.exists():
            print(f"Encrypted config file size: {encrypted_config_file.stat().st_size} bytes")
        
        if key_file.exists():
            print(f"Key file size: {key_file.stat().st_size} bytes")
        
    except ImportError as e:
        print(f"âŒ Import Error: {e}")
    except Exception as e:
        print(f"âŒ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()

