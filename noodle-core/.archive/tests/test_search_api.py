#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_search_api.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for NoodleCore Search API Endpoints
"""

import requests
import json
import time

def test_search_endpoints():
    """Test all search API endpoints."""
    base_url = "http://localhost:8080/api/v1/search"
    
    print("Testing NoodleCore Search API Endpoints")
    print("=" * 50)
    
    # Test search status
    print("\n1. Testing /search/status endpoint...")
    try:
        response = requests.get(f"{base_url}/status", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Search status endpoint working")
            print(f"   Service: {data.get('data', {}).get('service', 'Unknown')}")
            print(f"   Status: {data.get('data', {}).get('status', 'Unknown')}")
        else:
            print(f"âŒ Search status failed with status {response.status_code}")
            print(f"   Response: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Search status failed: {e}")
    
    # Test file search
    print("\n2. Testing /search/files endpoint...")
    try:
        params = {"q": "test", "limit": "5"}
        response = requests.get(f"{base_url}/files", params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… File search endpoint working")
            print(f"   Results found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
        else:
            print(f"âŒ File search failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ File search failed: {e}")
    
    # Test content search
    print("\n3. Testing /search/content endpoint...")
    try:
        params = {"q": "def", "limit": "5"}
        response = requests.get(f"{base_url}/content", params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Content search endpoint working")
            print(f"   Results found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
        else:
            print(f"âŒ Content search failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Content search failed: {e}")
    
    # Test semantic search
    print("\n4. Testing /search/semantic endpoint...")
    try:
        params = {"q": "function", "limit": "5"}
        response = requests.get(f"{base_url}/semantic", params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Semantic search endpoint working")
            print(f"   Results found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
        else:
            print(f"âŒ Semantic search failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Semantic search failed: {e}")
    
    # Test global search
    print("\n5. Testing /search/global endpoint...")
    try:
        params = {"q": "python", "limit": "10"}
        response = requests.get(f"{base_url}/global", params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Global search endpoint working")
            print(f"   Total found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
        else:
            print(f"âŒ Global search failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Global search failed: {e}")
    
    # Test suggestions
    print("\n6. Testing /search/suggest endpoint...")
    try:
        params = {"q": "py", "limit": "5"}
        response = requests.get(f"{base_url}/suggest", params=params, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Search suggestions endpoint working")
            print(f"   Suggestions found: {data.get('data', {}).get('summary', {}).get('total_suggestions', 0)}")
        else:
            print(f"âŒ Search suggestions failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Search suggestions failed: {e}")
    
    # Test search history
    print("\n7. Testing /search/history endpoint...")
    try:
        response = requests.get(f"{base_url}/history", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Search history endpoint working")
            print(f"   History entries: {data.get('data', {}).get('summary', {}).get('total_entries', 0)}")
        else:
            print(f"âŒ Search history failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Search history failed: {e}")
    
    # Test index management
    print("\n8. Testing /search/index endpoint...")
    try:
        response = requests.get(f"{base_url}/index", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("âœ… Index management endpoint working")
            print(f"   Index status: {data.get('data', {}).get('index_status', {})}")
        else:
            print(f"âŒ Index management failed with status {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"âŒ Index management failed: {e}")
    
    print("\n" + "=" * 50)
    print("Search API endpoint testing completed!")

if __name__ == "__main__":
    test_search_endpoints()

