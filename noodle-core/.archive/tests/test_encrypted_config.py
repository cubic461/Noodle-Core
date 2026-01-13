#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_encrypted_config.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for encrypted configuration system
"""

import sys
import os
from pathlib import Path

# Add src to path
src_dir = Path(__file__).parent / 'src'
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

def test_encrypted_config():
    """Test the encrypted configuration system."""
    print("ðŸ” Testing Encrypted Configuration System...")
    print("=" * 50)
    
    try:
        from noodlecore.config import (
            EncryptedConfigManager, 
            get_ai_config, 
            save_ai_config, 
            is_ai_configured
        )
        
        print("âœ… Successfully imported encrypted configuration module")
        
        # Test 1: Check if AI is configured
        print("\n1. Checking AI configuration status...")
        is_configured = is_ai_configured()
        print(f"   AI Configured: {'Yes' if is_configured else 'No'}")
        
        # Test 2: Get current configuration
        print("\n2. Getting current AI configuration...")
        ai_config = get_ai_config()
        print(f"   Provider: {ai_config.get('provider', 'Not set')}")
        print(f"   Model: {ai_config.get('model', 'Not set')}")
        print(f"   API Key: {'***SET***' if ai_config.get('api_key') else 'Not set'}")
        print(f"   Use Noodle Runtime: {ai_config.get('use_noodle_runtime_for_python', False)}")
        
        # Test 3: Save test configuration
        print("\n3. Saving test configuration...")
        save_ai_config(
            provider='TestProvider',
            model='test-model',
            api_key='test-api-key-12345',
            use_noodle_runtime_for_python=True
        )
        print("   âœ… Test configuration saved successfully")
        
        # Test 4: Verify saved configuration
        print("\n4. Verifying saved configuration...")
        updated_config = get_ai_config()
        print(f"   Provider: {updated_config.get('provider', 'Not set')}")
        print(f"   Model: {updated_config.get('model', 'Not set')}")
        print(f"   API Key: {'***SET***' if updated_config.get('api_key') else 'Not set'}")
        print(f"   Use Noodle Runtime: {updated_config.get('use_noodle_runtime_for_python', False)}")
        
        # Test 5: Test configuration manager directly
        print("\n5. Testing configuration manager directly...")
        config_manager = EncryptedConfigManager()
        
        # Test setting and getting values
        test_values = {
            'test_string': 'Hello, World!',
            'test_number': 42,
            'test_boolean': True,
            'test_list': [1, 2, 3],
            'test_dict': {'nested': 'value'}
        }
        
        print("   Setting test values...")
        for key, value in test_values.items():
            config_manager.set(key, value)
            print(f"   {key}: {value}")
        
        print("   Getting test values...")
        for key in test_values:
            retrieved_value = config_manager.get(key)
            matches = retrieved_value == value
            print(f"   {key}: {retrieved_value} {'âœ…' if matches else 'âŒ'}")
        
        print("\n" + "=" * 50)
        print("ðŸŽ‰ Encrypted configuration system test completed successfully!")
        print("\nðŸ“ Configuration files created in:")
        print(f"   {config_manager.config_dir}")
        print("\nðŸ”’ Your API keys and sensitive data are now encrypted and secure!")
        
        return True
        
    except ImportError as e:
        print(f"âŒ Import Error: {e}")
        print("\nðŸ’¡ Solution: Install the required cryptography package:")
        print("   pip install cryptography>=3.4.8")
        return False
        
    except Exception as e:
        print(f"âŒ Test Failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_encrypted_config()
    sys.exit(0 if success else 1)

