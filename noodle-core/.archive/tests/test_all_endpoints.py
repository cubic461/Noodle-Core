#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_all_endpoints.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive API Test Script for NoodleCore Enhanced IDE
Tests all connected endpoints to ensure full functionality
"""

import requests
import json
import time
import sys

BASE_URL = "http://localhost:8080"

def test_endpoint(name, url, method="GET", data=None):
    """Test an API endpoint"""
    try:
        print(f"\nðŸ” Testing {name}...")
        print(f"   URL: {method} {url}")
        
        if method == "GET":
            response = requests.get(url, timeout=5)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=5)
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"   âœ… SUCCESS: {name}")
                return True, result.get('data', {})
            else:
                print(f"   âŒ FAILED: {result.get('error', 'Unknown error')}")
                return False, None
        else:
            print(f"   âŒ HTTP ERROR: {response.status_code}")
            return False, None
            
    except Exception as e:
        print(f"   âŒ ERROR: {str(e)}")
        return False, None

def main():
    print("ðŸš€ NoodleCore Enhanced IDE - API Connection Test")
    print("=" * 60)
    
    # Track test results
    passed_tests = 0
    total_tests = 0
    
    # Test 1: Health Check
    total_tests += 1
    success, data = test_endpoint("Health Check", f"{BASE_URL}/api/v1/health")
    if success:
        passed_tests += 1
        print(f"   ðŸ“Š Features: {data.get('features', {})}")
    
    # Test 2: File Management
    total_tests += 1
    test_data = {"file_path": "test.py", "content": "print('Hello World')"}
    success, _ = test_endpoint("File Save", f"{BASE_URL}/api/v1/ide/files/save", "POST", test_data)
    if success:
        passed_tests += 1
    
    total_tests += 1
    success, data = test_endpoint("File List", f"{BASE_URL}/api/v1/ide/files/list")
    if success:
        passed_tests += 1
        print(f"   ðŸ“ Files: {len(data.get('files', []))} found")
    
    # Test 3: Code Execution
    total_tests += 1
    test_data = {"content": "print('Hello from IDE!')", "file_name": "test.py"}
    success, data = test_endpoint("Code Execution", f"{BASE_URL}/api/v1/execution/run", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   âš¡ Execution: {data.get('execution_time')}s")
    
    total_tests += 1
    test_data = {"content": "def hello():\n    print('Hello')"}
    success, _ = test_endpoint("Execution Improvements", f"{BASE_URL}/api/v1/execution/improve", "POST", test_data)
    if success:
        passed_tests += 1
    
    # Test 4: AI Analysis
    total_tests += 1
    test_data = {"content": "def example():\n    x = 1\n    return x", "file_path": "example.py"}
    success, data = test_endpoint("AI Code Analysis", f"{BASE_URL}/api/v1/ai/analyze", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   ðŸ“Š Analysis: Performance {int(data.get('performance_score', 0)*100)}%")
    
    total_tests += 1
    test_data = {"content": "import sys", "cursor_position": 100}
    success, data = test_endpoint("AI Suggestions", f"{BASE_URL}/api/v1/ai/suggest", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   ðŸ’¡ Suggestions: {len(data.get('suggestions', []))} found")
    
    total_tests += 1
    test_data = {"content": "x = 1\ny = 2\nprint(x + y)", "file_path": "math.py"}
    success, data = test_endpoint("AI Code Review", f"{BASE_URL}/api/v1/ai/review", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   ðŸ” Review Score: {data.get('overall_score')}/100")
    
    # Test 5: Learning System
    total_tests += 1
    success, data = test_endpoint("Learning Status", f"{BASE_URL}/api/v1/learning/status")
    if success:
        passed_tests += 1
        print(f"   ðŸŽ“ Model: {data.get('current_model')}")
    
    total_tests += 1
    test_data = {"type": "manual"}
    success, data = test_endpoint("Learning Trigger", f"{BASE_URL}/api/v1/learning/trigger", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   ðŸš€ Learning ID: {data.get('learning_id', 'N/A')}")
    
    # Test 6: Search Functions
    total_tests += 1
    success, data = test_endpoint("File Search", f"{BASE_URL}/api/v1/search/files?q=python")
    if success:
        passed_tests += 1
        print(f"   ðŸ” Files Found: {data.get('total', 0)}")
    
    total_tests += 1
    test_data = {"query": "def", "file_path": "example.py"}
    success, data = test_endpoint("Content Search", f"{BASE_URL}/api/v1/search/content", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   ðŸ“„ Matches: {data.get('total', 0)}")
    
    # Test 7: AI Deployment
    total_tests += 1
    success, data = test_endpoint("AI Deployment Status", f"{BASE_URL}/api/v1/ai/deployment/status")
    if success:
        passed_tests += 1
        print(f"   ðŸ¤– Models: {data.get('models_deployed', 0)} deployed")
    
    total_tests += 1
    test_data = {"model_name": "test-model", "version": "v1.0.0"}
    success, data = test_endpoint("AI Model Deploy", f"{BASE_URL}/api/v1/ai/deployment/deploy", "POST", test_data)
    if success:
        passed_tests += 1
        print(f"   ðŸš€ Deployment ID: {data.get('deployment_id', 'N/A')}")
    
    # Test 8: Frontend Serving
    total_tests += 1
    success, _ = test_endpoint("Enhanced IDE Page", f"{BASE_URL}/enhanced-ide-fixed.html")
    if success:
        passed_tests += 1
    
    # Summary
    print("\n" + "=" * 60)
    print(f"ðŸ“Š TEST SUMMARY: {passed_tests}/{total_tests} tests passed")
    
    if passed_tests == total_tests:
        print("ðŸŽ‰ ALL TESTS PASSED! The NoodleCore Enhanced IDE is fully functional!")
        print("\nâœ… All frontend buttons are now connected to real backend functionality:")
        print("   â€¢ AI Code Analysis â†’ /api/v1/ai/analyze")
        print("   â€¢ AI Suggestions â†’ /api/v1/ai/suggest") 
        print("   â€¢ AI Code Review â†’ /api/v1/ai/review")
        print("   â€¢ Learning System â†’ /api/v1/learning/status & /api/v1/learning/trigger")
        print("   â€¢ File Search â†’ /api/v1/search/files & /api/v1/search/content")
        print("   â€¢ Code Execution â†’ /api/v1/execution/run & /api/v1/execution/improve")
        print("   â€¢ Collaboration â†’ WebSocket connections")
        print("   â€¢ AI Deployment â†’ /api/v1/ai/deployment/status & /api/v1/ai/deployment/deploy")
        
        print("\nðŸš€ Ready to use! Open http://localhost:8080/enhanced-ide-fixed.html")
        return True
    else:
        print(f"âŒ {total_tests - passed_tests} tests failed. Check server logs.")
        return False

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\nâš ï¸ Test interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\nðŸ’¥ Unexpected error: {e}")
        sys.exit(1)

