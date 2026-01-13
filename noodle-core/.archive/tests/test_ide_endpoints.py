#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_endpoints.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Test script for new IDE endpoints"""

import requests
import json

def test_ide_endpoints():
    """Test the new IDE endpoints"""
    base_url = "http://localhost:8080"
    
    print("Testing NoodleCore IDE Endpoints")
    print("=" * 50)
    
    try:
        # Test 1: Health check (should already work)
        print("1. Testing Health Endpoint...")
        response = requests.get(f"{base_url}/api/v1/health", timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            print("   âœ… Health endpoint working")
        else:
            print("   âŒ Health endpoint failed")
        
        print()
        
        # Test 2: File Save Endpoint
        print("2. Testing File Save Endpoint...")
        save_data = {
            "file_path": "test.py",
            "content": "print('Hello from iPhone IDE!')",
            "file_type": "python"
        }
        response = requests.post(f"{base_url}/api/v1/ide/files/save", 
                               json=save_data, timeout=10)
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"   Response: {json.dumps(result, indent=4)}")
            print("   âœ… File Save endpoint working")
        else:
            print(f"   âŒ File Save failed: {response.text}")
        
        print()
        
        # Test 3: Code Execution Endpoint
        print("3. Testing Code Execution Endpoint...")
        exec_data = {
            "content": "print('Testing from iPhone')",
            "file_type": "python",
            "file_name": "test.py"
        }
        response = requests.post(f"{base_url}/api/v1/ide/code/execute",
                               json=exec_data, timeout=10)
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"   Response: {json.dumps(result, indent=4)}")
            print("   âœ… Code Execution endpoint working")
        else:
            print(f"   âŒ Code Execution failed: {response.text}")
        
        print()
        print("=" * 50)
        print("IDE Endpoint Tests Complete!")
        
    except requests.exceptions.RequestException as e:
        print(f"âŒ Network error: {e}")
    except Exception as e:
        print(f"âŒ Unexpected error: {e}")

if __name__ == "__main__":
    test_ide_endpoints()

