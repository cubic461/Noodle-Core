# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Test script for CLI-IDE integration.
# """

import os
import sys
import json

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

# Import modules directly to avoid circular imports
import noodlecore.config.ai_config.get_ai_config
import noodlecore.ide.cli_integration.CLIIntegration

function test_cli_integration()
    #     """Test CLI integration functionality."""
        print("Testing CLI-IDE integration...")

    #     # Get CLI integration instance
    #     try:
    integration = CLIIntegration()
            print("✓ CLI integration instance created successfully")
    #     except Exception as e:
            print(f"✗ Failed to create CLI integration instance: {e}")
    #         return False

    #     # Get AI configuration
    #     try:
    ai_config = get_ai_config()
            print("✓ AI configuration loaded successfully")
    #     except Exception as e:
            print(f"✗ Failed to load AI configuration: {e}")
    #         return False

    #     # Test AI configuration
    #     try:
    providers = ai_config.get_all_providers()
            print(f"✓ Found {len(providers)} AI providers")

    default_provider = ai_config.get_default_provider()
    #         if default_provider:
                print(f"✓ Default provider: {default_provider.name}")
    #         else:
                print("! No default provider set")
    #     except Exception as e:
            print(f"✗ Failed to test AI configuration: {e}")
    #         return False

    #     # Test CLI command execution
    #     try:
    result = integration.execute_cli(
    command = "run",
    args = ["print('Hello from CLI integration test!')"],
    timeout = 10
    #         )

    #         if result.get("success"):
                print("✓ CLI command executed successfully")
    #             if result.get("output"):
    #                 print(f"  Output: {result['output'][-1] if result['output'] else 'No output'}")
    #         else:
                print(f"✗ CLI command failed: {result.get('errors', ['Unknown error'])}")
    #             return False
    #     except Exception as e:
            print(f"✗ Failed to execute CLI command: {e}")
    #         return False

        print("\n✓ All tests passed! CLI-CLI integration is working correctly.")
    #     return True

if __name__ == "__main__"
    success = test_cli_integration()
    #     sys.exit(0 if success else 1)