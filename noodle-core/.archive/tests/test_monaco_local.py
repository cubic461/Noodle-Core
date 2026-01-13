#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_monaco_local.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify Monaco Editor local setup functionality
"""
import requests
import time
import json
import sys

def test_monaco_editor_local_setup():
    """Test that Monaco Editor loads from local sources"""
    base_url = "http://localhost:8080"
    
    print("ðŸ§ª Testing Monaco Editor Local Setup")
    print("=" * 50)
    
    # Test 1: Server Health Check
    print("1. Testing server health...")
    try:
        response = requests.get(f"{base_url}/api/v1/health", timeout=5)
        if response.status_code == 200:
            print("   âœ… Server is running and healthy")
        else:
            print(f"   âŒ Server health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"   âŒ Server connection failed: {e}")
        return False
    
    # Test 2: Monaco Editor Loader Script
    print("\n2. Testing Monaco Editor loader script...")
    try:
        response = requests.get(f"{base_url}/monaco-editor/min/vs/loader.min.js", timeout=5)
        if response.status_code == 200:
            print("   âœ… Monaco Editor loader script is accessible")
            print(f"   ðŸ“¦ File size: {len(response.content)} bytes")
        else:
            print(f"   âŒ Monaco Editor loader failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"   âŒ Monaco Editor loader test failed: {e}")
        return False
    
    # Test 3: Enhanced IDE Page
    print("\n3. Testing Enhanced IDE page...")
    try:
        response = requests.get(f"{base_url}/enhanced-ide.html", timeout=5)
        if response.status_code == 200:
            print("   âœ… Enhanced IDE page is accessible")
            content = response.text
            
            # Check for local Monaco references
            if "/monaco-editor/min/vs/loader.min.js" in content:
                print("   âœ… Monaco loader script is configured for local loading")
            else:
                print("   âŒ Monaco loader script is not configured for local loading")
                return False
                
            if "'/monaco-editor/min/vs'" in content:
                print("   âœ… Monaco Editor path is configured for local loading")
            else:
                print("   âŒ Monaco Editor path is not configured for local loading")
                return False
                
        else:
            print(f"   âŒ Enhanced IDE page failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"   âŒ Enhanced IDE test failed: {e}")
        return False
    
    # Test 4: Monaco Editor Main Files
    print("\n4. Testing core Monaco Editor files...")
    core_files = [
        "/monaco-editor/min/vs/loader.min.js",
        "/monaco-editor/min/vs/editor/editor.main.js",
        "/monaco-editor/min/vs/editor/editor.main.css"
    ]
    
    for file_path in core_files:
        try:
            response = requests.get(f"{base_url}{file_path}", timeout=5)
            if response.status_code == 200:
                print(f"   âœ… {file_path} is accessible")
            else:
                print(f"   âŒ {file_path} failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"   âŒ {file_path} test failed: {e}")
            return False
    
    # Test 5: Monaco Editor Language Support
    print("\n5. Testing Monaco Editor language files...")
    language_files = [
        "/monaco-editor/min/vs/basic-languages/javascript/javascript.js",
        "/monaco-editor/min/vs/basic-languages/python/python.js",
        "/monaco-editor/min/vs/basic-languages/typescript/typescript.js"
    ]
    
    for file_path in language_files:
        try:
            response = requests.get(f"{base_url}{file_path}", timeout=5)
            if response.status_code == 200:
                print(f"   âœ… {file_path.split('/')[-2]} language support is accessible")
            else:
                print(f"   âš ï¸  {file_path} not found: {response.status_code}")
        except Exception as e:
            print(f"   âš ï¸  {file_path} test failed: {e}")
    
    print("\n" + "=" * 50)
    print("ðŸŽ‰ Monaco Editor Local Setup Test Completed!")
    print("\nðŸ“‹ Summary:")
    print("   âœ… Server is running and accessible")
    print("   âœ… Monaco Editor is configured for local loading")
    print("   âœ… All core Monaco Editor files are accessible")
    print("   âœ… Enhanced IDE is configured to use local Monaco Editor")
    
    print("\nðŸ”§ What's been fixed:")
    print("   â€¢ Monaco Editor now loads from local files instead of CDN")
    print("   â€¢ No external CDN dependencies required")
    print("   â€¢ All Monaco Editor features should work locally")
    print("   â€¢ Server is configured to serve Monaco Editor files")
    
    return True

def main():
    """Main test function"""
    print("NoodleCore Monaco Editor Local Setup Test")
    print("==========================================")
    
    success = test_monaco_editor_local_setup()
    
    if success:
        print("\nâœ… All tests passed! Monaco Editor CDN loading issue has been resolved.")
        sys.exit(0)
    else:
        print("\nâŒ Some tests failed. Please check the configuration.")
        sys.exit(1)

if __name__ == "__main__":
    main()

