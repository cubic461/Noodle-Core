#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ai_config_diagnostic.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
AI Configuration Diagnostic Script

This script tests the AI configuration loading system to identify
why AI settings are not being loaded properly in the NoodleCore IDE.
"""

import os
import sys
import json
import traceback
from pathlib import Path

# Add the src directory to Python path
CURRENT_DIR = Path(__file__).parent
REPO_ROOT = CURRENT_DIR.parent
SRC_DIR = REPO_ROOT / "src"

for p in (str(REPO_ROOT), str(SRC_DIR)):
    if p not in sys.path:
        sys.path.insert(0, p)

def test_home_directory():
    """Test if home directory exists and is accessible."""
    print("=== HOME DIRECTORY TEST ===")
    home_dir = Path.home()
    print(f"Home directory: {home_dir}")
    print(f"Home directory exists: {home_dir.exists()}")
    print(f"Home directory is writable: {os.access(home_dir, os.W_OK)}")
    print()

def test_config_directory():
    """Test if config directory exists and is accessible."""
    print("=== CONFIG DIRECTORY TEST ===")
    config_dir = Path.home() / '.noodlecore'
    print(f"Config directory: {config_dir}")
    print(f"Config directory exists: {config_dir.exists()}")
    
    if not config_dir.exists():
        print("Config directory does not exist - this could be the problem!")
        try:
            config_dir.mkdir(exist_ok=True)
            print("Created config directory successfully")
        except Exception as e:
            print(f"Failed to create config directory: {e}")
    else:
        print(f"Config directory is writable: {os.access(config_dir, os.W_OK)}")
    print()

def test_encrypted_config_import():
    """Test if encrypted config system can be imported."""
    print("=== ENCRYPTED CONFIG IMPORT TEST ===")
    try:
        from noodlecore.config import get_ai_config, save_ai_config
        print("âœ… Successfully imported encrypted config functions")
        
        # Test if config manager can be created
        from noodlecore.config.encrypted_config import get_config_manager
        config_manager = get_config_manager()
        print("âœ… Successfully created config manager")
        
        return True
    except ImportError as e:
        print(f"âŒ Failed to import encrypted config: {e}")
        print("This means the encrypted config system is not available")
        return False
    except Exception as e:
        print(f"âŒ Error creating config manager: {e}")
        return False

def test_legacy_config_file():
    """Test if legacy config file exists and is readable."""
    print("=== LEGACY CONFIG FILE TEST ===")
    config_dir = Path.home() / '.noodlecore'
    legacy_config_file = config_dir / 'ai_config.json'
    
    print(f"Legacy config file: {legacy_config_file}")
    print(f"Legacy config file exists: {legacy_config_file.exists()}")
    
    if legacy_config_file.exists():
        try:
            with open(legacy_config_file, 'r') as f:
                config = json.load(f)
            print(f"âœ… Successfully read legacy config: {config}")
            return True
        except Exception as e:
            print(f"âŒ Failed to read legacy config: {e}")
            return False
    else:
        print("Legacy config file does not exist")
        return False

def test_encrypted_config_file():
    """Test if encrypted config file exists and is readable."""
    print("=== ENCRYPTED CONFIG FILE TEST ===")
    config_dir = Path.home() / '.noodlecore'
    encrypted_config_file = config_dir / 'ai_config.enc'
    
    print(f"Encrypted config file: {encrypted_config_file}")
    print(f"Encrypted config file exists: {encrypted_config_file.exists()}")
    
    if encrypted_config_file.exists():
        try:
            from noodlecore.config import get_ai_config
            config = get_ai_config()
            print(f"âœ… Successfully read encrypted config: {config}")
            return True
        except Exception as e:
            print(f"âŒ Failed to read encrypted config: {e}")
            print(f"Error type: {type(e).__name__}")
            print(f"Full traceback:")
            traceback.print_exc()
            return False
    else:
        print("Encrypted config file does not exist")
        return False

def test_api_key_persistence():
    """Test if API key can be saved and loaded."""
    print("=== API KEY PERSISTENCE TEST ===")
    
    test_config = {
        'provider': 'OpenRouter',
        'model': 'gpt-3.5-turbo',
        'ai_api_key': 'test-api-key-12345',
        'use_noodle_runtime_for_python': False
    }
    
    try:
        from noodlecore.config import save_ai_config, get_ai_config
        
        # Save test config
        save_ai_config(**test_config)
        print("âœ… Successfully saved test config")
        
        # Load test config
        loaded_config = get_ai_config()
        print(f"âœ… Successfully loaded test config: {loaded_config}")
        
        # Verify the config was saved correctly
        if loaded_config.get('ai_api_key') == test_config['ai_api_key']:
            print("âœ… API key was saved and loaded correctly")
            return True
        else:
            print("âŒ API key was not saved correctly")
            return False
            
    except Exception as e:
        print(f"âŒ API key persistence test failed: {e}")
        print(f"Error type: {type(e).__name__}")
        print(f"Full traceback:")
        traceback.print_exc()
        return False

def test_ide_ai_config_loading():
    """Test the IDE's AI config loading logic."""
    print("=== IDE AI CONFIG LOADING TEST ===")
    
    # Simulate the IDE's load_ai_config method
    home_dir = Path.home()
    config_dir = home_dir / '.noodlecore'
    encrypted_config_file = config_dir / 'ai_config.enc'
    legacy_config_file = config_dir / 'ai_config.json'
    
    print("Simulating IDE load_ai_config logic...")
    
    # Check if home directory exists
    print(f"Home directory exists: {home_dir.exists()}")
    print(f"Config directory exists: {config_dir.exists()}")
    print(f"Encrypted config file exists: {encrypted_config_file.exists()}")
    print(f"Legacy config file exists: {legacy_config_file.exists()}")
    
    # Test encrypted config loading
    encrypted_config_available = False
    try:
        from noodlecore.config import get_ai_config
        ai_config = get_ai_config()
        if ai_config:
            print(f"âœ… Encrypted config loaded: {ai_config}")
            encrypted_config_available = True
        else:
            print("âš ï¸ Encrypted config returned None/empty")
    except Exception as e:
        print(f"âŒ Encrypted config failed: {e}")
    
    # Test legacy config loading
    if not encrypted_config_available:
        print("Testing legacy config fallback...")
        if legacy_config_file.exists():
            try:
                with open(legacy_config_file, 'r') as f:
                    config = json.load(f)
                print(f"âœ… Legacy config loaded: {config}")
            except Exception as e:
                print(f"âŒ Legacy config failed: {e}")
        else:
            print("âš ï¸ No legacy config file found")
    
    print()

def main():
    """Run all diagnostic tests."""
    print("NoodleCore IDE AI Configuration Diagnostic")
    print("=" * 50)
    print()
    
    # Run all tests
    test_home_directory()
    test_config_directory()
    encrypted_config_works = test_encrypted_config_import()
    test_legacy_config_file()
    test_encrypted_config_file()
    test_api_key_persistence()
    test_ide_ai_config_loading()
    
    # Summary
    print("=== DIAGNOSTIC SUMMARY ===")
    if not encrypted_config_works:
        print("âŒ PRIMARY ISSUE: Encrypted config system cannot be imported")
        print("   This is likely due to missing dependencies or import errors")
        print("   The IDE will fall back to legacy JSON config")
    else:
        print("âœ… Encrypted config system is available")
    
    config_dir = Path.home() / '.noodlecore'
    if not config_dir.exists():
        print("âŒ PRIMARY ISSUE: Config directory ~/.noodlecore does not exist")
        print("   This prevents both encrypted and legacy config from working")
        print("   SOLUTION: Create the directory manually or fix directory creation logic")
    else:
        print("âœ… Config directory exists")
    
    print()
    print("RECOMMENDED ACTIONS:")
    print("1. Ensure ~/.noodlecore directory exists")
    print("2. Check if encrypted config dependencies are installed")
    print("3. Verify config file permissions")
    print("4. Test API key persistence manually")
    print("5. Check IDE logs for specific error messages")

if __name__ == "__main__":
    main()

