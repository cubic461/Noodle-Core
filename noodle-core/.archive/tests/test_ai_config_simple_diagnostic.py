#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ai_config_simple_diagnostic.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple AI Configuration Diagnostic Script

This script tests the AI configuration loading system without importing
problematic modules to identify why AI settings are not being loaded.
"""

import os
import sys
import json
import traceback
from pathlib import Path

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
        print("Encrypted config file exists but cannot test reading without imports")
        return True
    else:
        print("Encrypted config file does not exist")
        return False

def test_ide_ai_config_loading():
    """Test the IDE's AI config loading logic without imports."""
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
    
    # Test what would happen in the IDE
    if not config_dir.exists():
        print("âŒ PROBLEM: Config directory does not exist!")
        print("   This would cause both encrypted and legacy config loading to fail")
        return False
    
    # Check if we have any config files
    if not encrypted_config_file.exists() and not legacy_config_file.exists():
        print("âŒ PROBLEM: No config files found!")
        print("   This would cause the IDE to use default settings with no API key")
        return False
    
    print("âœ… Config files are available")
    return True

def test_file_permissions():
    """Test file permissions for config directory."""
    print("=== FILE PERMISSIONS TEST ===")
    config_dir = Path.home() / '.noodlecore'
    
    if config_dir.exists():
        print(f"Config directory exists: {config_dir}")
        print(f"Is writable: {os.access(config_dir, os.W_OK)}")
        print(f"Is readable: {os.access(config_dir, os.R_OK)}")
        
        # Test creating a test file
        test_file = config_dir / 'test_write.txt'
        try:
            with open(test_file, 'w') as f:
                f.write('test')
            print("âœ… Can write to config directory")
            
            # Clean up
            test_file.unlink()
        except Exception as e:
            print(f"âŒ Cannot write to config directory: {e}")
    else:
        print("Config directory does not exist")
    print()

def main():
    """Run all diagnostic tests."""
    print("Simple NoodleCore IDE AI Configuration Diagnostic")
    print("=" * 50)
    print()
    
    # Run all tests
    test_home_directory()
    test_config_directory()
    test_legacy_config_file()
    test_encrypted_config_file()
    test_file_permissions()
    config_loading_works = test_ide_ai_config_loading()
    
    # Summary
    print("=== DIAGNOSTIC SUMMARY ===")
    
    config_dir = Path.home() / '.noodlecore'
    if not config_dir.exists():
        print("âŒ PRIMARY ISSUE: Config directory ~/.noodlecore does not exist")
        print("   This prevents both encrypted and legacy config from working")
        print("   SOLUTION: Create the directory manually or fix directory creation logic")
    else:
        print("âœ… Config directory exists")
    
    # Check for config files
    legacy_config_file = config_dir / 'ai_config.json'
    encrypted_config_file = config_dir / 'ai_config.enc'
    
    if not legacy_config_file.exists() and not encrypted_config_file.exists():
        print("âŒ PRIMARY ISSUE: No AI config files found")
        print("   This means no API key has been saved yet")
        print("   SOLUTION: Configure AI settings through the IDE's AI Settings menu")
    else:
        print("âœ… Config files are present")
        if legacy_config_file.exists():
            print(f"   - Legacy config: {legacy_config_file}")
        if encrypted_config_file.exists():
            print(f"   - Encrypted config: {encrypted_config_file}")
    
    print()
    print("RECOMMENDED ACTIONS:")
    print("1. Ensure ~/.noodlecore directory exists and is writable")
    print("2. Check if config files exist in ~/.noodlecore/")
    print("3. If no config files exist, configure AI settings in the IDE")
    print("4. Verify file permissions allow reading/writing")
    print("5. Check IDE logs for specific error messages during config loading")

if __name__ == "__main__":
    main()

