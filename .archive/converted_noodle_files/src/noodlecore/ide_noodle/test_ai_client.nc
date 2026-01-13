# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore AI Client Test
# Test AI client functionality and provider integration
# """

import os
import sys
import pathlib.Path

# Add parent directory to path for imports
parent_dir = Path(__file__).parent.parent
if str(parent_dir) not in sys.path
        sys.path.insert(0, str(parent_dir))

function test_ai_client()
    #     """Test NoodleCoreAIClient functionality"""
        print("🤖 Testing NoodleCore AI Client...")

    #     try:
    #         # Import and instantiate runtime to get providers
    #         from runtime import NoodleCommandRuntime
    runtime = NoodleCommandRuntime()

    #         # Load specs
            print("  📋 Loading specs...")
    #         if not runtime.load_specs():
                print("  ❌ Failed to load specs")
    #             return False
            print("  ✅ Specs loaded successfully")

    #         # Test spec validation in AI client context
            print("  🔍 Testing spec validation...")
    #         try:
    #             from spec_validator import validate_specs
    validation_result = validate_specs()
    #             if not validation_result['ok']:
                    print("  ❌ Spec validation failed in AI client context")
    #                 for error in validation_result['errors']:
                        print(f"    • {error}")
    #                 return False
                print("  ✅ Spec validation passed in AI client context")
    #         except ImportError:
                print("  ⚠️  spec_validator not available - skipping validation test")

    #         # Import AI client
    #         from ai_client import NoodleCoreAIClient

    #         # Test AI client initialization with providers
            print("  🔧 Testing AI client initialization...")
    #         if not hasattr(runtime, 'providers') or not runtime.providers:
                print("  ❌ No providers loaded in runtime")
    #             return False

    ai_client = NoodleCoreAIClient(runtime.providers)
            print("  ✅ AI client initialized successfully")

    #         # Test provider resolution
            print("  🔍 Testing provider resolution...")
    provider = ai_client._resolve_provider("openrouter")
    #         if not provider:
                print("  ❌ Failed to resolve 'openrouter' provider")
    #             return False
            print("  ✅ Provider resolution successful")

    #         # Test missing provider handling
            print("  ⚠️  Testing missing provider handling...")
    missing_provider = ai_client._resolve_provider("nonexistent_provider")
    #         if missing_provider:
    #             print("  ❌ Should have failed for missing provider")
    #             return False
            print("  ✅ Missing provider handled correctly")

    #         # Test environment variable validation
            print("  🔐 Testing environment variable validation...")
    #         # Temporarily set a test env var
    os.environ['NOODLE_TEST_KEY'] = 'test_key'

    #         # Check if env var is detected
    auth_env = provider.get('auth_env', '')
    #         if not auth_env or not auth_env.startswith('NOODLE_'):
                print("  ❌ Invalid auth_env format in provider")
    #             return False

    #         if auth_env not in os.environ:
                print("  ✅ Environment variable validation works (missing env var detected)")
    #         else:
                print("  ✅ Environment variable validation works (env var present)")

    #         # Test missing NOODLE_* envs rejection
            print("  ⚠️  Testing missing NOODLE_* envs rejection...")
    #         # Temporarily clear all NOODLE env vars
    #         noodle_envs = {k: v for k, v in os.environ.items() if k.startswith('NOODLE_')}
    #         for key in noodle_envs:
    #             del os.environ[key]

    #         # Test AI client with missing env vars
    #         from ai_client import NoodleCoreAIClient
    empty_env_client = NoodleCoreAIClient(runtime.providers)

    #         # Try to invoke with missing env vars
    test_context = {
    #             'system': 'Test',
    #             'message': 'Test message',
    #             'provider': 'openrouter'
    #         }

    #         try:
    #             # This should fail gracefully
    result = empty_env_client.invoke('test_command', test_context)
    #             if result.get('ok', False):
    #                 print("  ❌ AI client should have failed with missing env vars")
    #                 return False
    #             else:
    error_msg = result.get('error', '')
    #                 if 'NOODLE_' in error_msg or 'environment' in error_msg.lower():
                        print("  ✅ AI client correctly rejects missing NOODLE_* envs")
    #                 else:
                        print(f"  ❌ Unexpected error message: {error_msg}")
    #                     return False
    #         except Exception as e:
    #             # Expected to fail gracefully
    #             if 'NOODLE_' in str(e) or 'environment' in str(e).lower():
                    print("  ✅ AI client correctly rejects missing NOODLE_* envs")
    #             else:
                    print(f"  ❌ Unexpected exception: {e}")
    #                 return False

    #         # Restore NOODLE env vars
    #         for key, value in noodle_envs.items():
    os.environ[key] = value

    #         # Clean up test env var
    #         if 'NOODLE_TEST_KEY' in os.environ:
    #             del os.environ['NOODLE_TEST_KEY']

    #         # Test request building
            print("  📝 Testing request building...")
    context = {
    #             'system': 'You are a helpful assistant.',
    #             'message': 'Hello, world!',
    #             'provider': 'openrouter'
    #         }

    #         try:
    request_data = ai_client._build_request(context, 'gpt-3.5-turbo')
    #             if not request_data:
                    print("  ❌ Failed to build request")
    #                 return False
                print("  ✅ Request building successful")
    #         except Exception as e:
                print(f"  ❌ Request building failed: {e}")
    #             return False

    #         # Test response normalization
            print("  📊 Testing response normalization...")
    test_response = "This is a test response"
    normalized = ai_client._normalize_response(True, test_response)

    #         if not isinstance(normalized, dict):
                print("  ❌ Response normalization failed - not a dict")
    #             return False

    #         if 'ok' not in normalized or 'content' not in normalized:
                print("  ❌ Response normalization failed - missing required fields")
    #             return False

    #         if normalized['ok'] != True or normalized['content'] != test_response:
                print("  ❌ Response normalization failed - incorrect values")
    #             return False

            print("  ✅ Response normalization successful")

    #         # Test error response normalization
            print("  ❌ Testing error response normalization...")
    error_normalized = ai_client._normalize_response(False, "Test error")

    #         if not isinstance(error_normalized, dict):
                print("  ❌ Error response normalization failed - not a dict")
    #             return False

    #         if error_normalized['ok'] != True or 'error' not in error_normalized:
                print("  ❌ Error response normalization failed - incorrect error handling")
    #             return False

            print("  ✅ Error response normalization successful")

            print("\n🎉 All AI client tests passed!")
    #         return True

    #     except ImportError as e:
            print(f"  ❌ Import error: {e}")
    #         return False
    #     except Exception as e:
            print(f"  ❌ Unexpected error: {e}")
    #         return False

function test_ai_integration()
    #     """Test AI integration with runtime"""
    #     print("🔗 Testing AI integration with runtime...")

    #     try:
    #         # Import and instantiate runtime
    #         from runtime import NoodleCommandRuntime
    runtime = NoodleCommandRuntime()

    #         # Load specs
    #         if not runtime.load_specs():
                print("  ❌ Failed to load specs")
    #             return False

    #         # Test AI command discovery
            print("  🔍 Testing AI command discovery...")
    #         ai_commands = [cmd_id for cmd_id, cmd_data in runtime.commands.items() if cmd_data.get('type') == 'ai']
    expected_ai_commands = [
    #             'ai.explain_current_file',
    #             'ai.code_review',
    #             'ai.generate_test',
    #             'ai.optimize_code'
    #         ]

    #         for cmd in expected_ai_commands:
    #             if cmd not in ai_commands:
                    print(f"  ❌ Missing AI command: {cmd}")
    #                 return False

            print("  ✅ All expected AI commands are discoverable")

    #         # Test AI command execution without environment variables
            print("  ⚠️  Testing AI command execution without environment...")

    context = {
    #             'file_path': 'test.py',
                'file_content': 'print("hello world")',
    #             'language': 'python'
    #         }

    result = runtime.execute('ai.explain_current_file', context)

    #         if not isinstance(result, dict):
                print("  ❌ Invalid result format")
    #             return False

    #         if result.get('ok', False):
                print("  ⚠️  AI command succeeded (unexpected without proper env)")
    #         else:
    error = result.get('error', '')
    #             if 'NOODLE_' in error or 'provider' in error.lower():
    #                 print("  ✅ AI command failed gracefully with proper error message")
    #             else:
                    print(f"  ❌ Unexpected AI error: {error}")
    #                 return False

            print("  ✅ AI integration test completed")
    #         return True

    #     except Exception as e:
            print(f"  ❌ AI integration test failed: {e}")
    #         return False

function main()
    #     """Main test entry point"""
    print(" = " * 60)
        print("NoodleCore AI Client Test")
    print(" = " * 60)

    client_success = test_ai_client()
        print()
    integration_success = test_ai_integration()

    print("\n" + " = " * 60)
    #     if client_success and integration_success:
            print("✅ TEST PASSED - NoodleCore AI client validation successful")
    #         return 0
    #     else:
            print("❌ TEST FAILED - NoodleCore AI client validation failed")
    #         return 1

if __name__ == "__main__"
        sys.exit(main())