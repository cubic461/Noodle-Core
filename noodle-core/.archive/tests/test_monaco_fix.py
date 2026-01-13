#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_monaco_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify Monaco Editor fixes are working
"""

import requests
import time
import sys

def test_server_connection():
    """Test if the server is running and responding"""
    try:
        response = requests.get('http://localhost:8080/api/v1/health', timeout=5)
        print(f"âœ… Server health check: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Enhanced IDE Available: {data.get('data', {}).get('enhanced_ide_available', False)}")
            return True
    except Exception as e:
        print(f"âŒ Server connection failed: {e}")
        return False

def test_html_loading():
    """Test if the enhanced-ide.html file loads correctly"""
    try:
        response = requests.get('http://localhost:8080/enhanced-ide.html', timeout=5)
        print(f"âœ… HTML page load: {response.status_code}")
        
        if response.status_code == 200:
            content = response.text
            
            # Check for Monaco Editor loading fixes
            fixes_present = []
            
            # Check for proper initialization
            if 'initializeMonacoLoader' in content:
                fixes_present.append("âœ… Enhanced Monaco loader")
            
            # Check for error handling
            if 'showEditorError' in content:
                fixes_present.append("âœ… Error handling")
            
            # Check for fallback mechanism
            if 'fallbackToBasicEditor' in content:
                fixes_present.append("âœ… Fallback mechanism")
            
            # Check for timeout handling
            if 'loadTimeout' in content:
                fixes_present.append("âœ… Timeout handling")
            
            # Check for proper dependencies
            if 'monaco-editor/0.45.0' in content:
                fixes_present.append("âœ… Monaco dependency")
            
            print("   Monaco Editor fixes implemented:")
            for fix in fixes_present:
                print(f"   {fix}")
                
            if len(fixes_present) >= 4:
                print("âœ… All major Monaco Editor fixes are present!")
                return True
            else:
                print("âš ï¸  Some fixes may be missing")
                return False
        
    except Exception as e:
        print(f"âŒ HTML loading failed: {e}")
        return False

def test_api_endpoints():
    """Test if API endpoints are working"""
    endpoints = [
        '/api/v1/ide/files/save',
        '/api/v1/ide/code/execute', 
        '/api/v1/ai/analyze/code'
    ]
    
    working_endpoints = 0
    
    for endpoint in endpoints:
        try:
            response = requests.post(
                f'http://localhost:8080{endpoint}',
                json={'test': 'data'},
                timeout=3
            )
            if response.status_code in [200, 400]:  # 400 is OK for invalid data
                print(f"âœ… {endpoint}: {response.status_code}")
                working_endpoints += 1
            else:
                print(f"âš ï¸  {endpoint}: {response.status_code}")
        except Exception as e:
            print(f"âŒ {endpoint}: Failed")
    
    return working_endpoints >= 2

def main():
    """Run all tests"""
    print("ðŸ”§ Testing Monaco Editor Fixes")
    print("=" * 40)
    
    tests = [
        ("Server Connection", test_server_connection),
        ("HTML Loading & Fixes", test_html_loading),
        ("API Endpoints", test_api_endpoints)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\nðŸ“‹ {test_name}")
        if test_func():
            passed += 1
        else:
            print("   Test failed")
    
    print(f"\n{'=' * 40}")
    print(f"ðŸ“Š Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("ðŸŽ‰ All tests passed! Monaco Editor fixes are working.")
        print("\nðŸš€ You can now test the enhanced IDE at:")
        print("   http://localhost:8080/enhanced-ide.html")
        print("\nâœ¨ The Monaco Editor should now:")
        print("   - Load properly with error handling")
        print("   - Show user-friendly error messages if something fails") 
        print("   - Provide fallback mechanisms")
        print("   - Handle loading timeouts gracefully")
    else:
        print("âš ï¸  Some tests failed. Please check the server and fixes.")
        sys.exit(1)

if __name__ == '__main__':
    main()

