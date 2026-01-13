#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_api_key_persistence.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify API key persistence after the key mismatch fix.

This script tests:
1. Saving an API key using the IDE's save_ai_config method
2. Loading the API key using the IDE's load_ai_config method
3. Verifying that the API key persists correctly after the fix
"""

import sys
import os
from pathlib import Path

# Add the src directory to the path to import noodlecore modules
current_dir = Path(__file__).parent
src_dir = current_dir / "src"
sys.path.insert(0, str(src_dir))

def test_api_key_persistence():
    """Test API key persistence using the encrypted config system."""
    
    print("=" * 60)
    print("API Key Persistence Test")
    print("=" * 60)
    
    try:
        # Import the necessary modules
        print("\n1. Importing modules...")
        from noodlecore.config.encrypted_config import save_ai_config, get_ai_config
        print("   [OK] Successfully imported encrypted_config module")
        
        # Set a test API key
        test_api_key = "sk-test-api-key-123456789"
        test_provider = "OpenAI"
        test_model = "gpt-3.5-turbo"
        test_use_noodle_runtime = True
        
        print(f"\n2. Setting test API key:")
        print(f"   - Provider: {test_provider}")
        print(f"   - Model: {test_model}")
        print(f"   - API Key: {test_api_key[:10]}...{test_api_key[-4:]}")
        print(f"   - Use Noodle Runtime: {test_use_noodle_runtime}")
        
        # Save the test API key using save_ai_config
        print("\n3. Saving API key using save_ai_config...")
        save_ai_config(
            provider=test_provider,
            model=test_model,
            api_key=test_api_key,
            use_noodle_runtime_for_python=test_use_noodle_runtime
        )
        print("   [OK] API key saved successfully")
        
        # Load the API key using get_ai_config
        print("\n4. Loading API key using get_ai_config...")
        loaded_config = get_ai_config()
        print("   [OK] API key loaded successfully")
        
        # Verify the loaded values match the saved values
        print("\n5. Verifying loaded values...")
        
        provider_match = loaded_config.get('provider') == test_provider
        model_match = loaded_config.get('model') == test_model
        api_key_match = loaded_config.get('ai_api_key') == test_api_key
        runtime_match = loaded_config.get('use_noodle_runtime_for_python') == test_use_noodle_runtime
        
        print(f"   - Provider match: {'[OK]' if provider_match else '[FAIL]'}")
        print(f"   - Model match: {'[OK]' if model_match else '[FAIL]'}")
        print(f"   - API key match: {'[OK]' if api_key_match else '[FAIL]'}")
        print(f"   - Runtime setting match: {'[OK]' if runtime_match else '[FAIL]'}")
        
        # Overall test result
        all_match = provider_match and model_match and api_key_match and runtime_match
        
        print("\n" + "=" * 60)
        if all_match:
            print("TEST RESULT: [PASSED]")
            print("API key persistence is working correctly!")
            print("The key mismatch issue has been resolved.")
        else:
            print("TEST RESULT: [FAILED]")
            print("API key persistence is NOT working correctly.")
            print("The key mismatch issue may still exist.")
            
            # Show details of what didn't match
            print("\nDetails:")
            if not provider_match:
                print(f"  - Provider: Expected '{test_provider}', got '{loaded_config.get('provider')}'")
            if not model_match:
                print(f"  - Model: Expected '{test_model}', got '{loaded_config.get('model')}'")
            if not api_key_match:
                print(f"  - API Key: Expected '{test_api_key}', got '{loaded_config.get('ai_api_key')}'")
            if not runtime_match:
                print(f"  - Runtime: Expected {test_use_noodle_runtime}, got {loaded_config.get('use_noodle_runtime_for_python')}")
        
        print("=" * 60)
        
        return all_match
        
    except Exception as e:
        print(f"\n[ERROR] during test: {str(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        print("=" * 60)
        return False

if __name__ == "__main__":
    success = test_api_key_persistence()
    sys.exit(0 if success else 1)

