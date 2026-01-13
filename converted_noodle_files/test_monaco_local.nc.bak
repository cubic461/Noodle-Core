# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Test script to verify Monaco Editor local setup functionality
# """
import requests
import time
import json
import sys

function test_monaco_editor_local_setup()
    #     """Test that Monaco Editor loads from local sources"""
    base_url = "http://localhost:8080"

        print("🧪 Testing Monaco Editor Local Setup")
    print(" = " * 50)

    #     # Test 1: Server Health Check
        print("1. Testing server health...")
    #     try:
    response = requests.get(f"{base_url}/api/v1/health", timeout=5)
    #         if response.status_code == 200:
                print("   ✅ Server is running and healthy")
    #         else:
                print(f"   ❌ Server health check failed: {response.status_code}")
    #             return False
    #     except Exception as e:
            print(f"   ❌ Server connection failed: {e}")
    #         return False

    #     # Test 2: Monaco Editor Loader Script
        print("\n2. Testing Monaco Editor loader script...")
    #     try:
    response = requests.get(f"{base_url}/monaco-editor/min/vs/loader.min.js", timeout=5)
    #         if response.status_code == 200:
                print("   ✅ Monaco Editor loader script is accessible")
                print(f"   📦 File size: {len(response.content)} bytes")
    #         else:
                print(f"   ❌ Monaco Editor loader failed: {response.status_code}")
    #             return False
    #     except Exception as e:
            print(f"   ❌ Monaco Editor loader test failed: {e}")
    #         return False

    #     # Test 3: Enhanced IDE Page
        print("\n3. Testing Enhanced IDE page...")
    #     try:
    response = requests.get(f"{base_url}/enhanced-ide.html", timeout=5)
    #         if response.status_code == 200:
                print("   ✅ Enhanced IDE page is accessible")
    content = response.text

    #             # Check for local Monaco references
    #             if "/monaco-editor/min/vs/loader.min.js" in content:
    #                 print("   ✅ Monaco loader script is configured for local loading")
    #             else:
    #                 print("   ❌ Monaco loader script is not configured for local loading")
    #                 return False

    #             if "'/monaco-editor/min/vs'" in content:
    #                 print("   ✅ Monaco Editor path is configured for local loading")
    #             else:
    #                 print("   ❌ Monaco Editor path is not configured for local loading")
    #                 return False

    #         else:
                print(f"   ❌ Enhanced IDE page failed: {response.status_code}")
    #             return False
    #     except Exception as e:
            print(f"   ❌ Enhanced IDE test failed: {e}")
    #         return False

    #     # Test 4: Monaco Editor Main Files
        print("\n4. Testing core Monaco Editor files...")
    core_files = [
    #         "/monaco-editor/min/vs/loader.min.js",
    #         "/monaco-editor/min/vs/editor/editor.main.js",
    #         "/monaco-editor/min/vs/editor/editor.main.css"
    #     ]

    #     for file_path in core_files:
    #         try:
    response = requests.get(f"{base_url}{file_path}", timeout=5)
    #             if response.status_code == 200:
                    print(f"   ✅ {file_path} is accessible")
    #             else:
                    print(f"   ❌ {file_path} failed: {response.status_code}")
    #                 return False
    #         except Exception as e:
                print(f"   ❌ {file_path} test failed: {e}")
    #             return False

    #     # Test 5: Monaco Editor Language Support
        print("\n5. Testing Monaco Editor language files...")
    language_files = [
    #         "/monaco-editor/min/vs/basic-languages/javascript/javascript.js",
    #         "/monaco-editor/min/vs/basic-languages/python/python.js",
    #         "/monaco-editor/min/vs/basic-languages/typescript/typescript.js"
    #     ]

    #     for file_path in language_files:
    #         try:
    response = requests.get(f"{base_url}{file_path}", timeout=5)
    #             if response.status_code == 200:
                    print(f"   ✅ {file_path.split('/')[-2]} language support is accessible")
    #             else:
                    print(f"   ⚠️  {file_path} not found: {response.status_code}")
    #         except Exception as e:
                print(f"   ⚠️  {file_path} test failed: {e}")

    print("\n" + " = " * 50)
        print("🎉 Monaco Editor Local Setup Test Completed!")
        print("\n📋 Summary:")
        print("   ✅ Server is running and accessible")
    #     print("   ✅ Monaco Editor is configured for local loading")
        print("   ✅ All core Monaco Editor files are accessible")
        print("   ✅ Enhanced IDE is configured to use local Monaco Editor")

        print("\n🔧 What's been fixed:")
        print("   • Monaco Editor now loads from local files instead of CDN")
        print("   • No external CDN dependencies required")
        print("   • All Monaco Editor features should work locally")
        print("   • Server is configured to serve Monaco Editor files")

    #     return True

function main()
    #     """Main test function"""
        print("NoodleCore Monaco Editor Local Setup Test")
    print(" = =========================================")

    success = test_monaco_editor_local_setup()

    #     if success:
            print("\n✅ All tests passed! Monaco Editor CDN loading issue has been resolved.")
            sys.exit(0)
    #     else:
            print("\n❌ Some tests failed. Please check the configuration.")
            sys.exit(1)

if __name__ == "__main__"
        main()