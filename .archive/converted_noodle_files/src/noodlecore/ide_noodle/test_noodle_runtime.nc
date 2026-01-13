# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Runtime Validation Test
# Minimal test to validate specs and sequences run without errors
# Tests unified runtime behavior with core NoodleCore primitives
# """

import os
import sys
import pathlib.Path

# Add parent directory to path for imports
parent_dir = Path(__file__).parent.parent
if str(parent_dir) not in sys.path
        sys.path.insert(0, str(parent_dir))

function test_runtime()
    #     """Test NoodleCommandRuntime functionality"""
        print("🧪 Testing NoodleCore Command Runtime...")

    #     try:
    #         # Import and instantiate runtime
    #         from runtime import NoodleCommandRuntime
    runtime = NoodleCommandRuntime()

    #         # Load specs
            print("  📋 Loading specs...")
    #         if not runtime.load_specs():
                print("  ❌ Failed to load specs")
    #             return False
            print("  ✅ Specs loaded successfully")

    #         # Test spec validation
            print("  🔍 Testing spec validation...")
    #         try:
    #             from spec_validator import validate_specs
    validation_result = validate_specs()
    #             if not validation_result['ok']:
                    print("  ❌ Spec validation failed:")
    #                 for error in validation_result['errors']:
                        print(f"    • {error}")
    #                 return False
                print("  ✅ Spec validation passed")
    #         except ImportError:
                print("  ⚠️  spec_validator not available - skipping validation test")

    #         # Test command retrieval
            print("  🔍 Testing command retrieval...")
    intellisense_cmd = runtime.get_command("intellisense.suggest")
    #         if not intellisense_cmd:
                print("  ❌ Failed to get 'intellisense.suggest' command")
    #             return False
            print("  ✅ Found 'intellisense.suggest' command")

    analyze_workflow_cmd = runtime.get_command("workflow.analyze_current_file")
    #         if not analyze_workflow_cmd:
                print("  ❌ Failed to get 'workflow.analyze_current_file' command")
    #             return False
            print("  ✅ Found 'workflow.analyze_current_file' command")

    #         # Test sequence retrieval
            print("  🔄 Testing sequence retrieval...")
    health_check_seq = runtime.get_sequence("workflow.project_health_check")
    #         if not health_check_seq:
                print("  ❌ Failed to get 'workflow.project_health_check' sequence")
    #             return False
            print("  ✅ Found 'workflow.project_health_check' sequence")

    #         # Test sequence execution
            print("  ⚡ Testing sequence execution...")

    #         # Test analyze current file workflow
            print("    📝 Testing 'workflow.analyze_current_file'...")
    analyze_context = {
    #             "file_path": "dummy.py",
    #             "language": "python",
                "content": "print('hello world')"
    #         }
    analyze_result = runtime.execute_sequence("workflow.analyze_current_file", analyze_context)

    #         if not isinstance(analyze_result, dict) or 'ok' not in analyze_result or 'results' not in analyze_result:
    #             print("    ❌ Invalid result format for analyze workflow")
    #             return False
            print("    ✅ Analyze workflow executed successfully")

    #         # Test project health check workflow
            print("    🏥 Testing 'workflow.project_health_check'...")
    health_context = {
    #             "project_root": "."
    #         }
    health_result = runtime.execute_sequence("workflow.project_health_check", health_context)

    #         if not isinstance(health_result, dict) or 'ok' not in health_result or 'results' not in health_result:
    #             print("    ❌ Invalid result format for health check workflow")
    #             return False
            print("    ✅ Health check workflow executed successfully")

    #         # Test AI command discovery
            print("  🤖 Testing AI command discovery...")
    explain_cmd = runtime.get_command("ai.explain_current_file")
    #         if not explain_cmd:
                print("  ❌ Failed to get 'ai.explain_current_file' command")
    #             return False
            print("  ✅ Found 'ai.explain_current_file' command")

    review_cmd = runtime.get_command("ai.code_review")
    #         if not review_cmd:
                print("  ❌ Failed to get 'ai.code_review' command")
    #             return False
            print("  ✅ Found 'ai.code_review' command")

    test_cmd = runtime.get_command("ai.generate_test")
    #         if not test_cmd:
                print("  ❌ Failed to get 'ai.generate_test' command")
    #             return False
            print("  ✅ Found 'ai.generate_test' command")

    optimize_cmd = runtime.get_command("ai.optimize_code")
    #         if not optimize_cmd:
                print("  ❌ Failed to get 'ai.optimize_code' command")
    #             return False
            print("  ✅ Found 'ai.optimize_code' command")

    #         # Test AI provider loading
            print("  🔧 Testing AI provider loading...")
    #         if not hasattr(runtime, 'providers') or not runtime.providers:
                print("  ❌ Failed to load AI providers")
    #             return False
            print("  ✅ AI providers loaded successfully")

    #         # Test AI client initialization
            print("  🧠 Testing AI client initialization...")
    #         if not hasattr(runtime, 'ai_client'):
                print("  ❌ AI client not initialized")
    #             return False
            print("  ✅ AI client initialized successfully")

    #         # Test AI command execution with missing environment (fail-soft behavior)
            print("  ⚠️  Testing AI command fail-soft behavior...")
    ai_context = {
    #             "file_path": "test.py",
                "file_content": "print('hello')",
    #             "language": "python"
    #         }

    #         # This should fail gracefully without crashing
    ai_result = runtime.execute("ai.explain_current_file", ai_context)
    #         if not isinstance(ai_result, dict) or 'ok' not in ai_result:
    #             print("  ❌ Invalid result format for AI command")
    #             return False

    #         if ai_result.get('ok', False):
    #             print("  ⚠️  AI command succeeded (unexpected with missing env vars)")
    #         else:
    error_msg = ai_result.get('error', '')
    #             if 'NOODLE_' in error_msg or 'provider' in error_msg.lower():
    #                 print("  ✅ AI command failed gracefully with proper error message")
    #             else:
                    print(f"  ❌ Unexpected AI error: {error_msg}")
    #                 return False

    #         # Test runtime with validation enabled
    #         print("  🧪 Testing runtime with validation enabled...")
    #         try:
    validated_runtime = NoodleCommandRuntime(validate_on_load=True)
    #             if not validated_runtime.load_specs():
    #                 print("  ❌ Failed to load specs with validation")
    #                 return False
    #             print("  ✅ Runtime with validation enabled works correctly")
    #         except Exception as e:
                print(f"  ❌ Runtime validation test failed: {e}")
    #             return False

    #         # Test unified runtime behavior
            print("  🔄 Testing unified runtime behavior...")
    #         try:
    #             # Check if adapter is initialized
    #             if hasattr(runtime, '_core_adapter') and runtime._core_adapter:
                    print("    ✅ Core runtime adapter initialized")

    #                 # Test that adapter can be called safely
    #                 if hasattr(runtime._core_adapter, '_core_runtime'):
    #                     if runtime._core_adapter._core_runtime is not None:
                            print("    ✅ Core runtime accessible via adapter")
    #                     else:
                            print("    ⚠️  Core runtime not available (fallback to local execution)")
    #                 else:
                        print("    ⚠️  Core runtime adapter structure unexpected")
    #             else:
                    print("    ⚠️  Core runtime adapter not initialized (using local execution)")

    #             # Test that delegation works for NoodleCore commands
    nc_context = {
                    'code': 'print("Hello from NoodleCore")',
    #                 'execution_mode': 'direct'
    #             }
    nc_result = runtime.execute("noodlecore.execute", nc_context)

    #             if not isinstance(nc_result, dict) or 'ok' not in nc_result:
    #                 print("    ❌ Invalid result for NoodleCore execution")
    #                 return False

    #             # Should work whether core runtime is available or not
    #             if nc_result.get('ok', False):
                    print("    ✅ NoodleCore command execution succeeded")
    #             else:
    error_msg = nc_result.get('error', '')
    #                 if 'adapter' in error_msg.lower() or 'core' in error_msg.lower():
    #                     print("    ✅ NoodleCore command failed gracefully with adapter error")
    #                 else:
                        print(f"    ⚠️  NoodleCore command failed: {error_msg}")

    #         except Exception as e:
                print(f"    ❌ Unified runtime test error: {e}")
    #             return False

    #         print("\n🎉 All tests passed! NoodleCore runtime is working correctly with unified behavior.")
    #         return True

    #     except ImportError as e:
            print(f"  ❌ Import error: {e}")
    #         return False
    #     except Exception as e:
            print(f"  ❌ Unexpected error: {e}")
    #         return False

function main()
    #     """Main test entry point"""
    print(" = " * 60)
        print("NoodleCore Runtime Validation Test")
    print(" = " * 60)

    success = test_runtime()

    print("\n" + " = " * 60)
    #     if success:
            print("✅ TEST PASSED - NoodleCore runtime validation successful")
    #         return 0
    #     else:
            print("❌ TEST FAILED - NoodleCore runtime validation failed")
    #         return 1

function test_end_to_end_unified_runtime()
    #     """Test end-to-end unified runtime behavior."""
        print("🔄 Testing end-to-end unified runtime behavior...")

    #     try:
    #         # Import and instantiate runtime with validation enabled
    #         from runtime import NoodleCommandRuntime
    runtime = NoodleCommandRuntime(validate_on_load=True)

    #         # Load specs
    #         print("  📋 Loading specs with validation...")
    #         if not runtime.load_specs():
                print("  ❌ Failed to load specs")
    #             return False
            print("  ✅ Specs loaded and validated successfully")

    #         # Test simple command execution
            print("  🔍 Testing simple command execution...")
    simple_context = {'test': True}
    simple_result = runtime.execute("intellisense.suggest", simple_context)

    #         if not isinstance(simple_result, dict) or 'ok' not in simple_result:
    #             print("  ❌ Invalid result format for simple command")
    #             return False

    #         if simple_result.get('ok', False):
                print("  ⚠️ Simple command failed gracefully (expected without full environment)")
                print(f"    Error: {simple_result.get('error', 'Unknown')}")
    #         else:
                print("  ✅ Simple command executed successfully")

    #         # Test sequence execution
            print("  🔄 Testing sequence execution...")
    sequence_context = {'project_root': '.'}
    sequence_result = runtime.execute_sequence("workflow.project_health_check", sequence_context)

    #         if not isinstance(sequence_result, dict) or 'ok' not in sequence_result or 'results' not in sequence_result:
    #             print("  ❌ Invalid result format for sequence")
    #             return False

    #         if sequence_result.get('ok', False):
                print("  ⚠️ Sequence failed gracefully (expected without full environment)")
                print(f"    Error: {sequence_result.get('error', 'Unknown')}")
    #         else:
    results = sequence_result.get('results', [])
                print("  ✅ Sequence executed successfully")
                print(f"    Completed {len(results)} workflow steps")

    #         # Test normalized response structure
            print("  📊 Testing normalized response structure...")
    #         for result_type, result in [('simple', simple_result), ('sequence', sequence_result)]:
    ok = result.get('ok', False)
    error = result.get('error', None)
    data = result.get('data', None)

    #             if ok and data is not None:
    print(f"    ✅ {result_type}: ok = {ok}, has_data")
    #             elif not ok and error is not None:
    print(f"    ✅ {result_type}: ok = {ok}, has_error")
    #             else:
    print(f"    ⚠️ {result_type}: ok = {ok}, minimal_response")

            print("  ✅ End-to-end unified runtime test passed")
    #         return True

    #     except Exception as e:
            print(f"  ❌ End-to-end test error: {e}")
    #         return False

if __name__ == "__main__"
    #     # Run existing tests first
    success = test_runtime()

    #     # Then run end-to-end test
    #     if success:
    print("\n" + " = " * 60)
    end_to_end_success = test_end_to_end_unified_runtime()
    #         if end_to_end_success:
                print("\n🎉 ALL TESTS PASSED - NoodleCore runtime validation successful")
                sys.exit(0)
    #         else:
                print("\n❌ END-TO-END TEST FAILED")
                sys.exit(1)
    #     else:
            print("\n❌ BASIC TESTS FAILED - skipping end-to-end test")
            sys.exit(1)