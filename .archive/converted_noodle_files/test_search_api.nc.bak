# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Test script for NoodleCore Search API Endpoints
# """

import requests
import json
import time

function test_search_endpoints()
    #     """Test all search API endpoints."""
    base_url = "http://localhost:8080/api/v1/search"

        print("Testing NoodleCore Search API Endpoints")
    print(" = " * 50)

    #     # Test search status
        print("\n1. Testing /search/status endpoint...")
    #     try:
    response = requests.get(f"{base_url}/status", timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Search status endpoint working")
                print(f"   Service: {data.get('data', {}).get('service', 'Unknown')}")
                print(f"   Status: {data.get('data', {}).get('status', 'Unknown')}")
    #         else:
    #             print(f"❌ Search status failed with status {response.status_code}")
                print(f"   Response: {response.text}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Search status failed: {e}")

    #     # Test file search
        print("\n2. Testing /search/files endpoint...")
    #     try:
    params = {"q": "test", "limit": "5"}
    response = requests.get(f"{base_url}/files", params=params, timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ File search endpoint working")
                print(f"   Results found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
    #         else:
    #             print(f"❌ File search failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ File search failed: {e}")

    #     # Test content search
        print("\n3. Testing /search/content endpoint...")
    #     try:
    params = {"q": "def", "limit": "5"}
    response = requests.get(f"{base_url}/content", params=params, timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Content search endpoint working")
                print(f"   Results found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
    #         else:
    #             print(f"❌ Content search failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Content search failed: {e}")

    #     # Test semantic search
        print("\n4. Testing /search/semantic endpoint...")
    #     try:
    params = {"q": "function", "limit": "5"}
    response = requests.get(f"{base_url}/semantic", params=params, timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Semantic search endpoint working")
                print(f"   Results found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
    #         else:
    #             print(f"❌ Semantic search failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Semantic search failed: {e}")

    #     # Test global search
        print("\n5. Testing /search/global endpoint...")
    #     try:
    params = {"q": "python", "limit": "10"}
    response = requests.get(f"{base_url}/global", params=params, timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Global search endpoint working")
                print(f"   Total found: {data.get('data', {}).get('summary', {}).get('total_found', 0)}")
    #         else:
    #             print(f"❌ Global search failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Global search failed: {e}")

    #     # Test suggestions
        print("\n6. Testing /search/suggest endpoint...")
    #     try:
    params = {"q": "py", "limit": "5"}
    response = requests.get(f"{base_url}/suggest", params=params, timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Search suggestions endpoint working")
                print(f"   Suggestions found: {data.get('data', {}).get('summary', {}).get('total_suggestions', 0)}")
    #         else:
    #             print(f"❌ Search suggestions failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Search suggestions failed: {e}")

    #     # Test search history
        print("\n7. Testing /search/history endpoint...")
    #     try:
    response = requests.get(f"{base_url}/history", timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Search history endpoint working")
                print(f"   History entries: {data.get('data', {}).get('summary', {}).get('total_entries', 0)}")
    #         else:
    #             print(f"❌ Search history failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Search history failed: {e}")

    #     # Test index management
        print("\n8. Testing /search/index endpoint...")
    #     try:
    response = requests.get(f"{base_url}/index", timeout=5)
    #         if response.status_code == 200:
    data = response.json()
                print("✅ Index management endpoint working")
                print(f"   Index status: {data.get('data', {}).get('index_status', {})}")
    #         else:
    #             print(f"❌ Index management failed with status {response.status_code}")
    #     except requests.exceptions.RequestException as e:
            print(f"❌ Index management failed: {e}")

    print("\n" + " = " * 50)
        print("Search API endpoint testing completed!")

if __name__ == "__main__"
        test_search_endpoints()