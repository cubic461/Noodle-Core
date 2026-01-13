#!/usr/bin/env python3
"""
Noodle Core::Simple Config Debug - simple_config_debug.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple debug script to test config loading without complex imports.
"""

import sys
import os

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_direct_config_import():
    """Test importing config modules directly."""
    
    print("=== Testing Direct Config Import ===")
    
    try:
        # Import directly from the encrypted_config module
        from noodlecore.config.encrypted_config import load_config, save_config, get_config_dir
        print("SUCCESS: Imported encrypted_config functions")
        
        # Test config directory
        config_dir = get_config_dir()
        print(f"Config directory: {config_dir}")
        
        # Test loading config
        config = load_config()
        print(f"Loaded config: {config}")
        
        # Check for AI-related fields
        if config:
            ai_fields = [k for k in config.keys() if 'ai' in k.lower()]
            print(f"AI-related fields: {ai_fields}")
            
            for field in ai_fields:
                value = config[field]
                if 'key' in field.lower():
                    print(f"{field}: {'*' * len(value) if value else 'None'}")
                else:
                    print(f"{field}: {value}")
        else:
            print("No config loaded")
            
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_config_module_import():
    """Test importing from the config module."""
    
    print("\n=== Testing Config Module Import ===")
    
    try:
        from noodlecore.config import get_ai_config, set_ai_config
        print("SUCCESS: Imported config functions")
        
        # Test getting AI config
        ai_config = get_ai_config()
        print(f"AI config: {ai_config}")
        
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("Simple NoodleCore Config Debug")
    print("=" * 40)
    
    success1 = test_direct_config_import()
    success2 = test_config_module_import()
    
    if success1 and success2:
        print("\nAll tests passed!")
    else:
        print("\nSome tests failed!")

