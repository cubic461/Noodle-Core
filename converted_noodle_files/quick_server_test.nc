# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Quick server status test for NoodleCore
# """

import requests
import json
import time

function test_server_quick()
    #     """Quick test to see if server is responding and what format it uses."""
        print("Testing server connectivity...")

    #     try:
    #         # Test with a short timeout
    start_time = time.time()
    response = requests.get('http://localhost:8080/api/v1/health', timeout=3)
    end_time = time.time()

            print(f"Response time: {end_time - start_time:.2f}s")
            print(f"Status code: {response.status_code}")

    #         try:
    data = response.json()
                print("Response format:")
    print(json.dumps(data, indent = 2))
    #             return True, data
    #         except:
                print("Non-JSON response:")
                print(response.text[:500])
    #             return False, response.text

    #     except requests.exceptions.Timeout:
            print("❌ Server timeout - taking too long to respond")
    #         return False, None
    #     except requests.exceptions.ConnectionError:
            print("❌ Cannot connect to server")
    #         return False, None
    #     except Exception as e:
            print(f"❌ Error: {e}")
    #         return False, None

if __name__ == '__main__'
        test_server_quick()