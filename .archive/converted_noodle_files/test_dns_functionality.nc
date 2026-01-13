# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore DNS Functionality Test Script
 = ========================================

# This script tests the DNS server functionality to ensure it's working correctly.
# Run this script to verify that DNS resolution is working for all configured domains.

# Usage:
#     python test_dns_functionality.py

# Features:
# - Tests local DNS server connectivity
# - Verifies domain resolution for all configured domains
# - Tests HTTP server accessibility
# - Validates DNS cache functionality
# - Provides troubleshooting information
# """

import socket
import requests
import time
import json
import typing.Dict,

class NoodleCoreDNSTester
    #     """Test class for NoodleCore DNS functionality."""

    #     def __init__(self, server_ip: str = "127.0.0.1", http_port: int = 8080, dns_port: int = 53):
    self.server_ip = server_ip
    self.http_port = http_port
    self.dns_port = dns_port
    self.configured_domains = [
    #             "www.noodle.nc",
    #             "noodle.nc",
    #             "api.noodle.nc",
    #             "ide.noodle.nc",
    #             "dashboard.noodle.nc",
    #             "app.noodle.nc"
    #         ]

    #     def test_http_server(self) -> bool:
    #         """Test HTTP server connectivity."""
            print("🧪 Testing HTTP Server...")
    #         try:
    response = requests.get(f"http://{self.server_ip}:{self.http_port}/api/v1/health", timeout=5)
    #             if response.status_code == 200:
                    print("   ✅ HTTP server is responding")
    #                 return True
    #             else:
                    print(f"   ❌ HTTP server returned status {response.status_code}")
    #                 return False
    #         except Exception as e:
                print(f"   ❌ HTTP server test failed: {e}")
    #             return False

    #     def test_dns_server_status(self) -> bool:
    #         """Test DNS server status via API."""
            print("🧪 Testing DNS Server Status...")
    #         try:
    response = requests.get(f"http://{self.server_ip}:{self.http_port}/api/v1/dns/status", timeout=5)
    #             if response.status_code == 200:
    data = response.json()
    #                 if data.get("success"):
    status_info = data.get("data", {})
                        print(f"   ✅ DNS server is {status_info.get('status', 'unknown')}")
                        print(f"   📊 Cache entries: {status_info.get('cache_entries', 0)}")
                        print(f"   🌐 Server IP: {status_info.get('server_ip', 'unknown')}")
                        print(f"   🕐 Uptime: {status_info.get('uptime_seconds', 0)} seconds")
    #                     return True
    #                 else:
                        print("   ❌ DNS server API returned error")
    #                     return False
    #             else:
                    print(f"   ❌ DNS server API returned status {response.status_code}")
    #                 return False
    #         except Exception as e:
                print(f"   ❌ DNS server status test failed: {e}")
    #             return False

    #     def test_dns_queries(self) -> Dict[str, bool]:
    #         """Test DNS queries for all configured domains."""
            print("🧪 Testing DNS Queries...")
    results = {}

    #         for domain in self.configured_domains:
    #             try:
                    print(f"   🔍 Testing {domain}...")
    #                 # Create a simple DNS query using socket
    query_data = self._build_simple_dns_query(domain)

    #                 with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
                        sock.settimeout(2.0)
                        sock.sendto(query_data, (self.server_ip, self.dns_port))
    response_data, _ = sock.recvfrom(512)

    #                     if response_data:
    results[domain] = True
                            print(f"   ✅ {domain} - DNS response received")
    #                     else:
    results[domain] = False
                            print(f"   ❌ {domain} - No DNS response")

    #             except socket.timeout:
    results[domain] = False
                    print(f"   ⏰ {domain} - DNS query timed out")
    #             except Exception as e:
    results[domain] = False
                    print(f"   ❌ {domain} - Error: {e}")

    #         return results

    #     def test_http_accessibility(self) -> Dict[str, bool]:
    #         """Test HTTP accessibility for all domains."""
            print("🧪 Testing HTTP Accessibility...")
    results = {}

    #         for domain in self.configured_domains:
    #             try:
                    print(f"   🌐 Testing {domain} on HTTP...")
    response = requests.get(f"http://{domain}:{self.http_port}/", timeout=3, allow_redirects=False)
    #                 if response.status_code in [200, 301, 302, 404]:  # Any response indicates DNS resolution worked
    results[domain] = True
                        print(f"   ✅ {domain} - HTTP accessible (status {response.status_code})")
    #                 else:
    results[domain] = False
                        print(f"   ⚠️  {domain} - Unexpected HTTP status {response.status_code}")
    #             except requests.exceptions.ConnectTimeout:
    results[domain] = False
                    print(f"   ⏰ {domain} - HTTP connection timeout")
    #             except requests.exceptions.ConnectionError:
    results[domain] = False
                    print(f"   ❌ {domain} - Connection failed (DNS might not be configured on this device)")
    #             except Exception as e:
    results[domain] = False
                    print(f"   ❌ {domain} - Error: {e}")

    #         return results

    #     def _build_simple_dns_query(self, domain: str) -> bytes:
    #         """Build a simple DNS query packet."""
    #         import struct

    #         # Simple query for A record
    domain_parts = domain.split('.')
    query_data = b''

            # Transaction ID (simple hash)
    transaction_id = sum(domain.encode()) & 0xFFFF

            # DNS Header (12 bytes)
    header = struct.pack("!HHHHHH",
    #             transaction_id,    # Transaction ID
    #             0x0100,            # Flags: Standard query
    #             1,                 # Questions: 1
    #             0,                 # Answer RRs: 0
    #             0,                 # Authority RRs: 0
    #             0                  # Additional RRs: 0
    #         )

    #         # DNS Question
    #         for part in domain_parts:
    query_data + = struct.pack("!B", len(part)) + part.encode()
    query_data + = b'\x00'  # End of domain name
    query_data + = struct.pack("!HH", 1, 1)  # Type A, Class IN

    #         return header + query_data

    #     def run_comprehensive_test(self) -> Dict[str, any]:
    #         """Run comprehensive DNS functionality test."""
            print("🚀 NoodleCore DNS Functionality Test")
    print(" = " * 50)

    results = {
                "timestamp": time.time(),
    #             "server_ip": self.server_ip,
                "http_server": self.test_http_server(),
                "dns_server_status": self.test_dns_server_status(),
                "dns_queries": self.test_dns_queries(),
                "http_accessibility": self.test_http_accessibility()
    #         }

    #         # Print summary
            print("\n📊 Test Summary")
            print("-" * 30)

    dns_success = sum(results["dns_queries"].values())
    http_success = sum(results["http_accessibility"].values())

    #         print(f"HTTP Server: {'✅ PASS' if results['http_server'] else '❌ FAIL'}")
    #         print(f"DNS Server Status: {'✅ PASS' if results['dns_server_status'] else '❌ FAIL'}")
            print(f"DNS Queries: {dns_success}/{len(self.configured_domains)} successful")
            print(f"HTTP Accessibility: {http_success}/{len(self.configured_domains)} accessible")

    overall_success = (
    #             results["http_server"] and
    #             results["dns_server_status"] and
    dns_success > = math.divide(len(self.configured_domains), / 2)
    #         )

    #         print(f"\n🎯 Overall Result: {'✅ SUCCESS' if overall_success else '❌ FAIL'}")

    #         if not overall_success:
                self._print_troubleshooting_tips(results)

    #         return results

    #     def _print_troubleshooting_tips(self, results: Dict[str, any]):
    #         """Print troubleshooting tips based on test results."""
            print("\n🔧 Troubleshooting Tips")
            print("-" * 30)

    #         if not results["http_server"]:
    #             print("• HTTP server not responding - check if NoodleCore is running")
                print("• Verify firewall allows port 8080")
                print("• Try: curl http://localhost:8080/api/v1/health")

    #         if not results["dns_server_status"]:
                print("• DNS server API not responding - DNS server may not be running")
    #             print("• Check if running with proper privileges (port 53 requires admin)")
                print("• Try running as Administrator/root")

    #         if not any(results["dns_queries"].values()):
                print("• All DNS queries failed - DNS server may not be binding to port 53")
    #             print("• Check firewall rules for UDP port 53")
    #             print("• Verify server is running with elevated privileges")

    #         if not any(results["http_accessibility"].values()):
                print("• DNS resolution working but HTTP not accessible from this device")
    #             print("• This is expected if DNS is not configured on this device")
                print("• To test from other devices, configure their DNS to point to this server")

            print("\n📚 For more help, see: noodle-core/docs/DNS_SETUP_GUIDE.md")


function main()
    #     """Main test function."""
    #     import argparse

    parser = argparse.ArgumentParser(description="Test NoodleCore DNS functionality")
    parser.add_argument("--server", default = "127.0.0.1", help="Server IP address")
    parser.add_argument("--http-port", type = int, default=8080, help="HTTP server port")
    parser.add_argument("--dns-port", type = int, default=53, help="DNS server port")
    parser.add_argument("--output", help = "Save results to JSON file")

    args = parser.parse_args()

    tester = NoodleCoreDNSTester(
    server_ip = args.server,
    http_port = args.http_port,
    dns_port = args.dns_port
    #     )

    #     try:
    results = tester.run_comprehensive_test()

    #         if args.output:
    #             with open(args.output, 'w') as f:
    json.dump(results, f, indent = 2)
                print(f"\n💾 Results saved to {args.output}")

    #     except KeyboardInterrupt:
            print("\n⚠️  Test interrupted by user")
    #     except Exception as e:
    #         print(f"\n❌ Test failed with error: {e}")


if __name__ == "__main__"
        main()