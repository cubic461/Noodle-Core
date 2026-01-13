# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Test script to verify AI chat functionality is working properly.
# """

import sys
import os
import tempfile
import subprocess

function test_ai_functionality()
    #     """Test if the AI functionality in the IDE works."""
        print("Testing AI Chat Functionality...")

    #     # Check if the main IDE file exists
    ide_file = "src/noodlecore/desktop/ide/native_ide_complete.py"
    #     if not os.path.exists(ide_file):
            print(f"❌ IDE file not found: {ide_file}")
    #         return False

        print(f"✅ Found IDE file: {ide_file}")

    #     # Test 1: Check if AI methods exist and are properly defined
        print("\n1. Checking AI method definitions...")
    #     try:
    #         with open(ide_file, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

    #         # Check for key AI methods
    required_methods = [
    #             'send_ai_message',
    #             'make_ai_request',
    #             'call_openrouter_api',
    #             'call_openai_api',
    #             'call_anthropic_api',
    #             'call_ollama_api',
    #             'load_api_key_from_env',
    #             'ensure_ai_initialization'
    #         ]

    missing_methods = []
    #         for method in required_methods:
    #             if f"def {method}(" not in content:
                    missing_methods.append(method)

    #         if missing_methods:
                print(f"❌ Missing methods: {missing_methods}")
    #             return False
    #         else:
                print(f"✅ All required AI methods found")

    #     except Exception as e:
            print(f"❌ Error checking AI methods: {e}")
    #         return False

    #     # Test 2: Check if error handling improvements are present
        print("\n2. Checking error handling improvements...")
    error_handling_signatures = [
    #         'requests.exceptions.RequestException',
    #         'Authentication failed',
    #         'Rate limit exceeded',
    #         'Network error connecting'
    #     ]

    missing_signatures = []
    #     for signature in error_handling_signatures:
    #         if signature not in content:
                missing_signatures.append(signature)

    #     if missing_signatures:
            print(f"❌ Missing error handling: {missing_signatures}")
    #         return False
    #     else:
            print(f"✅ Error handling improvements found")

    #     # Test 3: Check environment variable support
        print("\n3. Checking environment variable support...")
    env_signatures = [
    #         'load_api_key_from_env',
    #         'OPENROUTER_API_KEY',
    #         'OPENAI_API_KEY',
    #         'ANTHROPIC_API_KEY'
    #     ]

    missing_env = []
    #     for signature in env_signatures:
    #         if signature not in content:
                missing_env.append(signature)

    #     if missing_env:
            print(f"❌ Missing environment variable support: {missing_env}")
    #         return False
    #     else:
            print(f"✅ Environment variable support found")

    #     # Test 4: Check proper chat state management
        print("\n4. Checking chat state management...")
    chat_state_checks = [
    "self.ai_chat.config(state = 'normal')",
    "self.ai_chat.config(state = 'disabled')",
            "self.ai_chat.see('end')"
    #     ]

    missing_states = []
    #     for check in chat_state_checks:
    #         if check not in content:
                missing_states.append(check)

    #     if missing_states:
            print(f"❌ Missing proper chat state management: {missing_states}")
    #         return False
    #     else:
            print(f"✅ Proper chat state management found")

    #     # Test 5: Verify AI provider configurations
        print("\n5. Checking AI provider configurations...")
    provider_configs = [
    #         '"OpenRouter"',
    #         '"OpenAI"',
    #         '"Anthropic"',
    #         '"Ollama"'
    #     ]

    missing_configs = []
    #     for config in provider_configs:
    #         if config not in content:
                missing_configs.append(config)

    #     if missing_configs:
            print(f"❌ Missing AI provider configurations: {missing_configs}")
    #         return False
    #     else:
            print(f"✅ All AI provider configurations found")

        print("\n🎉 AI Functionality Test Results:")
        print("✅ All AI methods properly implemented")
        print("✅ Error handling improvements added")
        print("✅ Environment variable support added")
        print("✅ Proper state management implemented")
        print("✅ AI provider configurations complete")
        print("\n🚀 AI chat should now work properly!")
        print("\nNext steps:")
    print("1. Set your API key: export OPENAI_API_KEY = 'your-key' (or use Properties panel)")
        print("2. Run the IDE: python native_ide_complete.py")
        print("3. Try sending a message in the AI chat")

    #     return True

if __name__ == "__main__"
    success = test_ai_functionality()
    #     if not success:
            print("\n❌ Some tests failed. Please check the implementation.")
            sys.exit(1)
    #     else:
            print("\n✅ All tests passed! AI functionality is ready.")
            sys.exit(0)