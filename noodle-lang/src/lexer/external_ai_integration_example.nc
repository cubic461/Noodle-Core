# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# External AI Integration Example
# ------------------------------

# This example demonstrates how to use the NoodleCore external AI integration
# to generate code from an external AI service and validate it through the
# NoodleCore AI guard.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import asyncio
import json
import os
import sys
import pathlib.Path

# Add the src directory to the Python path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

import noodlecore.ai.external_integration.(
#     ExternalAIIntegration,
#     ExternalAIConfig,
#     AIProvider,
#     quick_generate
# )
import noodlecore.ai.guard.GuardConfig


# async def example_basic_usage():
#     """Example of basic usage with OpenAI"""
print("\n = == Basic Usage Example ===")

#     # Configure the external AI integration
config = ExternalAIConfig(
provider = AIProvider.OPENAI,
model = "gpt-3.5-turbo",
max_tokens = 500,
temperature = 0.7,
validate_output = True,
timeout_ms = 30000
#     )

#     # Create the integration instance
integration = ExternalAIIntegration(config)

#     # Generate a response
prompt = "Generate a simple Noodle function that adds two numbers together."
result = await integration.generate(prompt, file_path="example.nc")

#     # Display the results
    print(f"Request ID: {result['requestId']}")
    print(f"Success: {result['success']}")

#     if result['success']:
        print(f"\nGenerated Code:\n{result['response']['content']}")
        print(f"Model: {result['response']['model']}")
        print(f"Response Time: {result['response']['responseTimeMs']}ms")

#         # Display validation results if available
#         if result['validation']:
            print(f"\nValidation Results:")
            print(f"Valid: {result['validation']['isValid']}")
            print(f"Success: {result['validation']['success']}")

#             if result['validation']['errors']:
                print("\nErrors:")
#                 for error in result['validation']['errors']:
                    print(f"  - {error['message']}")

#             if result['validation']['warnings']:
                print("\nWarnings:")
#                 for warning in result['validation']['warnings']:
                    print(f"  - {warning['message']}")
#     else:
        print(f"Error: {result['error']}")

#     # Display statistics
stats = integration.get_statistics()
print(f"\nStatistics: {json.dumps(stats, indent = 2)}")


# async def example_custom_validation():
#     """Example with custom validation configuration"""
print("\n = == Custom Validation Example ===")

#     # Configure strict validation
guard_config = GuardConfig(
mode = GuardMode.STRICT,
action_on_failure = GuardAction.WARN,
max_correction_attempts = 2,
timeout_ms = 5000
#     )

#     # Configure the external AI integration with custom validation
config = ExternalAIConfig(
provider = AIProvider.OPENAI,
model = "gpt-3.5-turbo",
validate_output = True,
guard_config = guard_config
#     )

#     # Create the integration instance
integration = ExternalAIIntegration(config)

#     # Generate a response with stricter validation
prompt = "Generate a Noodle program that calculates the factorial of a number."
result = await integration.generate(prompt, file_path="factorial.nc")

#     # Display the results
    print(f"Request ID: {result['requestId']}")
    print(f"Success: {result['success']}")

#     if result['success']:
        print(f"\nGenerated Code:\n{result['response']['content']}")

#         # Display validation results
#         if result['validation']:
            print(f"\nValidation Results:")
            print(f"Valid: {result['validation']['isValid']}")
            print(f"Success: {result['validation']['success']}")

#             if result['validation']['errors']:
                print("\nErrors:")
#                 for error in result['validation']['errors']:
                    print(f"  - {error['message']}")

#             if result['validation']['warnings']:
                print("\nWarnings:")
#                 for warning in result['validation']['warnings']:
                    print(f"  - {warning['message']}")
#     else:
        print(f"Error: {result['error']}")


# async def example_different_providers():
#     """Example with different AI providers"""
print("\n = == Different Providers Example ===")

#     # Example with Anthropic Claude
#     if os.environ.get("ANTHROPIC_API_KEY"):
        print("\n--- Anthropic Claude ---")
config = ExternalAIConfig(
provider = AIProvider.ANTHROPIC,
model = "claude-3-haiku-20240307",
validate_output = True
#         )

integration = ExternalAIIntegration(config)

prompt = "Generate a Noodle function that sorts an array of numbers."
result = await integration.generate(prompt, file_path="sort.nc")

#         if result['success']:
            print(f"Generated Code:\n{result['response']['content']}")

#             if result['validation']:
                print(f"Valid: {result['validation']['isValid']}")
#         else:
            print(f"Error: {result['error']}")
#     else:
        print("\nSkipping Anthropic example - ANTHROPIC_API_KEY not set")

#     # Example with Custom provider (for testing)
    print("\n--- Custom Provider (Mock) ---")
config = ExternalAIConfig(
provider = AIProvider.CUSTOM,
validate_output = True
#     )

integration = ExternalAIIntegration(config)

#     # Set up a custom response callback
#     def mock_response_callback(request):
#         from noodlecore.ai.external_integration import AIResponse, AIProvider
        return AIResponse(
content = "// Mock generated Noodle code\nfunction add(a, b) {\n    return a + b;\n}",
model = "mock-model",
usage = {"prompt_tokens": 10, "completion_tokens": 20, "total_tokens": 30},
provider = AIProvider.CUSTOM
#         )

#     # Get the custom provider and set the callback
#     if hasattr(integration.provider, 'set_response_callback'):
        integration.provider.set_response_callback(mock_response_callback)

prompt = "Generate a Noodle function that adds two numbers."
result = await integration.generate(prompt, file_path="mock_add.nc")

#     if result['success']:
        print(f"Generated Code:\n{result['response']['content']}")

#         if result['validation']:
            print(f"Valid: {result['validation']['isValid']}")
#     else:
        print(f"Error: {result['error']}")


# async def example_quick_generate():
#     """Example using the quick_generate convenience function"""
print("\n = == Quick Generate Example ===")

#     # Use the quick_generate function for simple cases
prompt = "Generate a Noodle function that multiplies two numbers."
result = await quick_generate(
prompt = prompt,
provider = AIProvider.OPENAI,
model = "gpt-3.5-turbo",
validate = True,
file_path = "multiply.nc"
#     )

#     # Display the results
    print(f"Request ID: {result['requestId']}")
    print(f"Success: {result['success']}")

#     if result['success']:
        print(f"\nGenerated Code:\n{result['response']['content']}")

#         if result['validation']:
            print(f"Valid: {result['validation']['isValid']}")
#     else:
        print(f"Error: {result['error']}")


# async def example_error_handling():
#     """Example of error handling"""
print("\n = == Error Handling Example ===")

#     # Configure with invalid API key to demonstrate error handling
config = ExternalAIConfig(
provider = AIProvider.OPENAI,
api_key = "invalid-key",
validate_output = True
#     )

integration = ExternalAIIntegration(config)

#     # This should fail with an authentication error
prompt = "Generate a simple Noodle function."
result = await integration.generate(prompt)

#     # Display the error
    print(f"Request ID: {result['requestId']}")
    print(f"Success: {result['success']}")

#     if not result['success']:
        print(f"Error: {result['error']}")

#     # Display statistics
stats = integration.get_statistics()
print(f"\nStatistics: {json.dumps(stats, indent = 2)}")


# async def main():
#     """Main function to run all examples"""
    print("NoodleCore External AI Integration Examples")
print(" = =========================================")

#     # Check if API keys are set
#     if not os.environ.get("OPENAI_API_KEY"):
        print("\nWarning: OPENAI_API_KEY environment variable not set.")
        print("Some examples may not work without proper API keys.")
        print("Set the environment variables and run again to see full functionality.")

#     # Run examples
    await example_basic_usage()
    await example_custom_validation()
    await example_different_providers()
    await example_quick_generate()
    await example_error_handling()

print("\n = == All Examples Complete ===")


if __name__ == "__main__"
    #     # Run the examples
        asyncio.run(main())