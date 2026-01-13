#!/usr/bin/env python3
"""
Test Suite::Noodle Core - standalone_config_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Standalone test that directly imports only the config modules without triggering the problematic imports.
"""

import sys
import os
import json
import base64
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_direct_file_access():
    """Test reading the config files directly."""
    
    print("=== Testing Direct File Access ===")
    
    # Get the config directory
    app_data = os.environ.get('APPDATA')
    if not app_data:
        print("ERROR: APPDATA environment variable not found")
        return False
        
    config_dir = os.path.join(app_data, 'NoodleCore')
    print(f"Config directory: {config_dir}")
    
    if not os.path.exists(config_dir):
        print("ERROR: Config directory does not exist")
        return False
    
    # Check for config files
    config_file = os.path.join(config_dir, 'encrypted_config.json')
    key_file = os.path.join(config_dir, '.config_key')
    
    print(f"Config file exists: {os.path.exists(config_file)}")
    print(f"Key file exists: {os.path.exists(key_file)}")
    
    if not os.path.exists(config_file):
        print("ERROR: Config file does not exist")
        return False
    
    if not os.path.exists(key_file):
        print("ERROR: Key file does not exist")
        return False
    
    # Read the encrypted config
    try:
        with open(config_file, 'r') as f:
            encrypted_data = f.read()
        print(f"Encrypted config length: {len(encrypted_data)}")
        print(f"Encrypted config preview: {encrypted_data[:100]}...")
    except Exception as e:
        print(f"ERROR reading config file: {e}")
        return False
    
    # Read the key
    try:
        with open(key_file, 'r') as f:
            key_data = f.read().strip()
        print(f"Key length: {len(key_data)}")
        print(f"Key preview: {key_data[:20]}...")
    except Exception as e:
        print(f"ERROR reading key file: {e}")
        return False
    
    return True

def test_manual_decryption():
    """Test manual decryption using the same logic as the encrypted_config module."""
    
    print("\n=== Testing Manual Decryption ===")
    
    try:
        # Import cryptography modules directly
        from cryptography.fernet import Fernet
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
        print("SUCCESS: Imported cryptography modules")
    except ImportError as e:
        print(f"ERROR: Could not import cryptography: {e}")
        return False
    
    # Get the config directory
    app_data = os.environ.get('APPDATA')
    config_dir = os.path.join(app_data, 'NoodleCore')
    config_file = os.path.join(config_dir, 'encrypted_config.json')
    key_file = os.path.join(config_dir, '.config_key')
    
    try:
        # Read the files
        with open(config_file, 'r') as f:
            encrypted_data = f.read()
        with open(key_file, 'r') as f:
            key_data = f.read().strip()
        
        # Decode the key
        key = base64.urlsafe_b64decode(key_data.encode())
        
        # Create decryptor
        fernet = Fernet(key)
        
        # Decrypt the data
        decrypted_data = fernet.decrypt(encrypted_data.encode())
        config_json = decrypted_data.decode()
        
        # Parse JSON
        config = json.loads(config_json)
        
        print("SUCCESS: Decrypted config successfully")
        print(f"Config keys: {list(config.keys())}")
        
        # Check for AI fields
        ai_fields = [k for k in config.keys() if 'ai' in k.lower()]
        print(f"AI fields: {ai_fields}")
        
        for field in ai_fields:
            value = config[field]
            if 'key' in field.lower():
                print(f"{field}: {'*' * len(str(value)) if value else 'None'}")
            else:
                print(f"{field}: {value}")
        
        return True
        
    except Exception as e:
        print(f"ERROR during decryption: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_config_module_directly():
    """Test importing the config module directly without going through the main package."""
    
    print("\n=== Testing Config Module Direct Import ===")
    
    try:
        # Import the encrypted_config module directly
        import importlib.util
        spec = importlib.util.spec_from_file_location(
            "encrypted_config", 
            "src/noodlecore/config/encrypted_config.py"
        )
        encrypted_config = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(encrypted_config)
        
        print("SUCCESS: Direct import of encrypted_config")
        
        # Test the functions
        config = encrypted_config.load_config()
        print(f"Loaded config: {config}")
        
        # Test config module
        spec2 = importlib.util.spec_from_file_location(
            "config", 
            "src/noodlecore/config/__init__.py"
        )
        config_module = importlib.util.module_from_spec(spec2)
        
        # We need to set up the encrypted_config module in the sys.modules first
        sys.modules['noodlecore.config.encrypted_config'] = encrypted_config
        
        spec2.loader.exec_module(config_module)
        
        ai_config = config_module.get_ai_config()
        print(f"AI config: {ai_config}")
        
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("Standalone NoodleCore Config Test")
    print("=" * 40)
    
    success1 = test_direct_file_access()
    success2 = test_manual_decryption()
    success3 = test_config_module_directly()
    
    print(f"\nResults:")
    print(f"Direct file access: {'PASS' if success1 else 'FAIL'}")
    print(f"Manual decryption: {'PASS' if success2 else 'FAIL'}")
    print(f"Direct module import: {'PASS' if success3 else 'FAIL'}")

