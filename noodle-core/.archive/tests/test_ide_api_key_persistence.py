#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_api_key_persistence.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify API key persistence in the IDE context.

This script tests:
1. Creating an IDE instance
2. Using the IDE's save_ai_config method to save an API key
3. Using the IDE's load_ai_config method to retrieve it
4. Verifying that the API key persists correctly
"""

import sys
import os
from pathlib import Path

# Add src directory to the path to import noodlecore modules
current_dir = Path(__file__).parent
src_dir = current_dir / "src"
sys.path.insert(0, str(src_dir))

def test_ide_api_key_persistence():
    """Test API key persistence using the IDE's methods."""
    
    print("=" * 60)
    print("IDE API Key Persistence Test")
    print("=" * 60)
    
    try:
        print("\n1. Importing IDE module...")
        # Import only what we need for the test
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        print("   [OK] Successfully imported NativeNoodleCoreIDE")
        
        print("\n2. Creating IDE instance...")
        # Create an IDE instance (this will load existing config)
        ide = NativeNoodleCoreIDE()
        print("   [OK] IDE instance created")
        
        # Set a test API key
        test_api_key = "sk-ide-test-api-key-987654321"
        test_provider = "OpenRouter"
        test_model = "gpt-3.5-turbo"
        test_use_noodle_runtime = False
        
        print(f"\n3. Setting test API key in IDE:")
        print(f"   - Provider: {test_provider}")
        print(f"   - Model: {test_model}")
        print(f"   - API Key: {test_api_key[:10]}...{test_api_key[-4:]}")
        print(f"   - Use Noodle Runtime: {test_use_noodle_runtime}")
        
        # Set the test values in the IDE
        ide.current_ai_provider = test_provider
        ide.current_ai_model = test_model
        ide.ai_api_key = test_api_key
        ide.use_noodle_runtime_for_python = test_use_noodle_runtime
        
        print("\n4. Saving API key using IDE's save_ai_config method...")
        # Use the IDE's save_ai_config method
        ide.save_ai_config()
        print("   [OK] API key saved successfully")
        
        print("\n5. Loading API key using IDE's load_ai_config method...")
        # Create a new IDE instance to test loading
        ide2 = NativeNoodleCoreIDE()
        print("   [OK] New IDE instance created (should load saved config)")
        
        print("\n6. Verifying loaded values...")
        
        # Check if the loaded values match the saved values
        provider_match = ide2.current_ai_provider == test_provider
        model_match = ide2.current_ai_model == test_model
        api_key_match = ide2.ai_api_key == test_api_key
        runtime_match = ide2.use_noodle_runtime_for_python == test_use_noodle_runtime
        
        print(f"   - Provider match: {'[OK]' if provider_match else '[FAIL]'}")
        print(f"   - Model match: {'[OK]' if model_match else '[FAIL]'}")
        print(f"   - API key match: {'[OK]' if api_key_match else '[FAIL]'}")
        print(f"   - Runtime setting match: {'[OK]' if runtime_match else '[FAIL]'}")
        
        # Overall test result
        all_match = provider_match and model_match and api_key_match and runtime_match
        
        print("\n" + "=" * 60)
        if all_match:
            print("TEST RESULT: [PASSED]")
            print("API key persistence is working correctly in the IDE!")
            print("The key mismatch issue has been resolved.")
        else:
            print("TEST RESULT: [FAILED]")
            print("API key persistence is NOT working correctly in the IDE.")
            print("The key mismatch issue may still exist.")
            
            # Show details of what didn't match
            print("\nDetails:")
            if not provider_match:
                print(f"  - Provider: Expected '{test_provider}', got '{ide2.current_ai_provider}'")
            if not model_match:
                print(f"  - Model: Expected '{test_model}', got '{ide2.current_ai_model}'")
            if not api_key_match:
                print(f"  - API Key: Expected '{test_api_key}', got '{ide2.ai_api_key}'")
            if not runtime_match:
                print(f"  - Runtime: Expected {test_use_noodle_runtime}, got {ide2.use_noodle_runtime_for_python}")
        
        print("=" * 60)
        
        return all_match
        
    except Exception as e:
        print(f"\n[ERROR] during test: {str(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        print("=" * 60)
        return False

if __name__ == "__main__":
    success = test_ide_api_key_persistence()
    sys.exit(0 if success else 1)

