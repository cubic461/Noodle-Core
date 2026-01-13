#!/usr/bin/env python3
"""
Noodle Core::Debug Config Loading - debug_config_loading.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to identify the specific issue with AI config loading in the IDE.
This script will test the exact same code path that the IDE uses.
"""

import sys
import os
import traceback

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_import_and_loading():
    """Test the exact import and loading process used by the IDE."""
    
    print("=== Testing Import and Configuration Loading ===")
    
    try:
        # Test 1: Import the exact modules the IDE imports
        print("\n1. Testing imports...")
        try:
            from src.noodlecore.config.encrypted_config import load_config, save_config, get_config_dir
            print("âœ“ Successfully imported encrypted_config functions")
        except ImportError as e:
            print(f"âœ— Failed to import encrypted_config: {e}")
            traceback.print_exc()
            return False
            
        try:
            from src.noodlecore.config import get_ai_config, set_ai_config
            print("âœ“ Successfully imported config functions")
        except ImportError as e:
            print(f"âœ— Failed to import config functions: {e}")
            traceback.print_exc()
            return False
        
        # Test 2: Check config directory
        print("\n2. Testing config directory...")
        try:
            config_dir = get_config_dir()
            print(f"Config directory: {config_dir}")
            if os.path.exists(config_dir):
                print("âœ“ Config directory exists")
            else:
                print("âœ— Config directory does not exist")
                return False
        except Exception as e:
            print(f"âœ— Error getting config directory: {e}")
            traceback.print_exc()
            return False
        
        # Test 3: Load AI config using the exact same method as IDE
        print("\n3. Testing AI config loading...")
        try:
            ai_config = get_ai_config()
            print(f"Loaded AI config: {ai_config}")
            
            # Check if we got default values or real values
            if ai_config.get('provider') == 'OpenRouter' and ai_config.get('model') == 'gpt-3.5-turbo':
                print("âš  Got default values - this suggests loading failed")
            else:
                print("âœ“ Got non-default values - loading may have succeeded")
                
            # Check if api_key is present
            if ai_config.get('api_key'):
                print("âœ“ API key is present")
            else:
                print("âœ— API key is missing")
                
        except Exception as e:
            print(f"âœ— Error loading AI config: {e}")
            traceback.print_exc()
            return False
        
        # Test 4: Try to load raw encrypted config
        print("\n4. Testing raw encrypted config loading...")
        try:
            raw_config = load_config()
            print(f"Raw config keys: {list(raw_config.keys()) if raw_config else 'None'}")
            
            if 'ai_provider' in raw_config:
                print(f"âœ“ Found ai_provider in raw config: {raw_config['ai_provider']}")
            else:
                print("âœ— ai_provider not found in raw config")
                
            if 'ai_model' in raw_config:
                print(f"âœ“ Found ai_model in raw config: {raw_config['ai_model']}")
            else:
                print("âœ— ai_model not found in raw config")
                
            if 'ai_api_key' in raw_config:
                print(f"âœ“ Found ai_api_key in raw config: {'*' * 10 if raw_config['ai_api_key'] else 'None'}")
            else:
                print("âœ— ai_api_key not found in raw config")
                
        except Exception as e:
            print(f"âœ— Error loading raw config: {e}")
            traceback.print_exc()
            return False
        
        return True
        
    except Exception as e:
        print(f"âœ— Unexpected error: {e}")
        traceback.print_exc()
        return False

def test_field_mapping():
    """Test the field mapping between raw config and AI config."""
    
    print("\n=== Testing Field Mapping ===")
    
    try:
        from src.noodlecore.config.encrypted_config import load_config
        from src.noodlecore.config import get_ai_config
        
        # Get both configs
        raw_config = load_config()
        ai_config = get_ai_config()
        
        print(f"Raw config: {raw_config}")
        print(f"AI config: {ai_config}")
        
        # Check mapping
        if raw_config and 'ai_provider' in raw_config:
            if raw_config['ai_provider'] != ai_config.get('provider'):
                print(f"âœ— Field mapping issue: raw ai_provider={raw_config['ai_provider']} vs ai_config provider={ai_config.get('provider')}")
            else:
                print("âœ“ Provider field mapping correct")
        
        if raw_config and 'ai_api_key' in raw_config:
            if raw_config['ai_api_key'] != ai_config.get('api_key'):
                print(f"âœ— Field mapping issue: raw ai_api_key exists but ai_config api_key={ai_config.get('api_key')}")
            else:
                print("âœ“ API key field mapping correct")
                
    except Exception as e:
        print(f"âœ— Error testing field mapping: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    print("NoodleCore AI Configuration Debug Script")
    print("=" * 50)
    
    success = test_import_and_loading()
    if success:
        test_field_mapping()
    
    print("\n=== Debug Complete ===")

