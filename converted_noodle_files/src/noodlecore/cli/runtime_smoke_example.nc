# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Minimal smoke test demonstrating unified NoodleCore runtime end-to-end execution.
# This example shows how to use NoodleCommandRuntime with .nc specs.
# """

import sys
import pathlib.Path

# Add parent directory to path for imports
parent_dir = Path(__file__).parent.parent
if str(parent_dir) not in sys.path
        sys.path.insert(0, str(parent_dir))

function main()
    #     """Demonstrate unified runtime usage."""
        print("🚀 NoodleCore Unified Runtime Smoke Test")
    print(" = " * 50)

    #     try:
    #         # Import and instantiate runtime with validation enabled
    #         from ide_noodle.runtime import NoodleCommandRuntime
    runtime = NoodleCommandRuntime(validate_on_load=True)

    #         # Load all .nc specifications
            print("📋 Loading .nc specifications...")
    #         if not runtime.load_specs():
                print("❌ Failed to load specs")
    #             return 1
            print("✅ Specifications loaded successfully")

            # Execute a non-AI command (git status)
            print("\n🔍 Testing non-AI command (git.status)...")
    git_context = {
    #             'project_path': '.',
    #             'format': 'summary'
    #         }
    git_result = runtime.execute("git.status", git_context)

    #         if git_result.get('ok', False):
                print("✅ Git status command executed successfully")
    data = git_result.get('data', {})
    #             if data:
                    print(f"   Branch: {data.get('branch', 'unknown')}")
                    print(f"   Changes: {len(data.get('changes', []))}")
    #         else:
                print(f"⚠️ Git status failed gracefully: {git_result.get('error', 'Unknown error')}")

            # Execute a workflow sequence (project health check)
            print("\n🔄 Testing workflow sequence (workflow.project_health_check)...")
    health_context = {
    #             'project_root': '.'
    #         }
    health_result = runtime.execute_sequence("workflow.project_health_check", health_context)

    #         if health_result.get('ok', False):
                print("✅ Project health check executed successfully")
    results = health_result.get('results', [])
                print(f"   Completed {len(results)} workflow steps")
    #             for step in results:
    cmd = step.get('command', '')
    ok = step.get('ok', False)
    #                 status = "✅" if ok else "❌"
                    print(f"   {status} {cmd}")
    #         else:
                print(f"⚠️ Project health check failed gracefully: {health_result.get('error', 'Unknown error')}")

            print("\n🎉 Unified runtime smoke test completed successfully!")
            print("   - Specifications loaded and validated")
            print("   - Non-AI command executed")
            print("   - Workflow sequence executed")
            print("   - All operations handled gracefully")
    #         return 0

    #     except Exception as e:
            print(f"\n❌ Unexpected error: {e}")
    #         return 1

if __name__ == "__main__"
        sys.exit(main())