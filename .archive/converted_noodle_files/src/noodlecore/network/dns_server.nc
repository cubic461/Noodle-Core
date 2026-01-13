# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore DNS Server
# --------------------

# This module provides DNS server functionality for NoodleCore to enable
# home network access using custom domains like www.noodle.nc.

# The DNS server integrates with the existing HTTP server and provides
# domain resolution for:
# - www.noodle.nc -> Noodle IDE interface
# - api.noodle.nc -> API endpoints
# - ide.noodle.nc -> IDE interface
# - *.noodle.nc -> Various NoodleCore services

# Features:
# - Custom domain resolution for home network
# - DNS caching for performance
# - Security measures and access controls
# - Fallback to upstream DNS for external domains
# - Integration with HTTP server startup
# """

import socket
import threading
import time
import logging
import struct
import hashlib
import typing.Dict,
import dataclasses.dataclass
import collections.defaultdict
import json
import os

# Configure logging
logger = logging.getLogger(__name__)

# DNS Server Constants
DEFAULT_DNS_PORT = 53
DNS_TIMEOUT_SECONDS = 30
MAX_DNS_CONNECTIONS = 50
CACHE_TTL_SECONDS = 300  # 5 minutes
UPSTREAM_DNS_SERVERS = [
#     "8.8.8.8",      # Google DNS
#     "1.1.1.1",      # Cloudflare DNS
#     "9.9.9.9"       # Quad9 DNS
# ]

# Domain Configuration for NoodleCore
NOODLE_DOMAINS = {
#     "www.noodle.nc": "0.0.0.0",    # Resolve to server IP
#     "noodle.nc": "0.0.0.0",        # Root domain
#     "api.noodle.nc": "0.0.0.0",    # API endpoints
#     "ide.noodle.nc": "0.0.0.0",    # IDE interface
#     "dashboard.noodle.nc": "0.0.0.0",  # Dashboard
#     "app.noodle.nc": "0.0.0.0",    # Application
# }

# DNS Resource Record Types
DNS_TYPE_A = 1      # IPv4 Address
DNS_TYPE_AAAA = 28  # IPv6 Address
DNS_TYPE_CNAME = 5  # Canonical Name
DNS_TYPE_PTR = 12   # Pointer (reverse DNS)

# DNS Response Codes
DNS_RCODE_NOERROR = 0
DNS_RCODE_NXDOMAIN = 3


# @dataclass
class DNSQuery
    #     """DNS query structure."""
    #     name: str
    #     qtype: int
    #     qclass: int
    #     transaction_id: int


# @dataclass
class DNSRecord
    #     """DNS record structure."""
    #     name: str
    #     qtype: int
    #     ttl: int
    #     data: str


class DNSCache
    #     """DNS cache for performance optimization."""

    #     def __init__(self, ttl: int = CACHE_TTL_SECONDS):
    self.ttl = ttl
    self.cache: Dict[str, Tuple[DNSRecord, float]] = {}
    self.lock = threading.Lock()

    #     def get(self, domain: str, qtype: int) -> Optional[DNSRecord]:
    #         """Get cached DNS record."""
    key = f"{domain}:{qtype}"
    #         with self.lock:
    #             if key in self.cache:
    record, timestamp = self.cache[key]
    #                 if time.time() - timestamp < self.ttl:
    #                     return record
    #                 else:
    #                     # Expired, remove from cache
    #                     del self.cache[key]
    #         return None

    #     def put(self, domain: str, qtype: int, record: DNSRecord):
    #         """Cache DNS record."""
    key = f"{domain}:{qtype}"
    #         with self.lock:
    self.cache[key] = (record, time.time())

    #     def clear(self):
    #         """Clear all cached records."""
    #         with self.lock:
                self.cache.clear()


class DNSResponder
    #     """DNS query responder with domain resolution logic."""

    #     def __init__(self, cache: DNSCache):
    self.cache = cache
    self.noodle_domains = NOODLE_DOMAINS.copy()
    self.upstream_dns = UPSTREAM_DNS_SERVERS
    self.active_queries = 0
    self.lock = threading.Lock()

    #     def get_server_ip(self) -> str:
    #         """Get the server's IP address."""
    #         try:
    #             # Try to get the primary network interface IP
    hostname = socket.gethostname()
    server_ip = socket.gethostbyname(hostname)
    #             if server_ip not in ["127.0.0.1", "0.0.0.0", "localhost"]:
    #                 return server_ip

    #             # Fallback: get IP from socket connection
    #             with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                    s.connect(("8.8.8.8", 80))
                    return s.getsockname()[0]
    #         except Exception as e:
                logger.warning(f"Could not determine server IP: {e}")
    #             return "127.0.0.1"

    #     def resolve_noodle_domain(self, domain: str) -> Optional[str]:
    #         """Resolve NoodleCore domains."""
            # Normalize domain (remove trailing dots)
    domain = domain.rstrip('.')

    #         # Check exact matches
    #         if domain in self.noodle_domains:
    target_ip = self.noodle_domains[domain]
    #             if target_ip == "0.0.0.0":
                    return self.get_server_ip()
    #             return target_ip

    #         # Check wildcard matches for subdomains
    #         for pattern, target_ip in self.noodle_domains.items():
    #             if pattern.startswith("*"):
    suffix = pattern[1:]  # Remove "*"
    #                 if domain.endswith(suffix):
    #                     if target_ip == "0.0.0.0":
                            return self.get_server_ip()
    #                     return target_ip

    #         return None

    #     def query_upstream(self, domain: str, qtype: int) -> Optional[DNSRecord]:
    #         """Query upstream DNS servers."""
    #         for dns_server in self.upstream_dns:
    #             try:
    #                 # Simple DNS query using socket
    query_data = self._build_dns_query(domain, qtype)

    #                 # Send query to upstream DNS
    #                 with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
                        sock.settimeout(5.0)
                        sock.sendto(query_data, (dns_server, 53))
    response_data, _ = sock.recvfrom(512)

    #                     # Parse response
    record = self._parse_dns_response(response_data, domain, qtype)
    #                     if record:
    #                         # Cache the result
                            self.cache.put(domain, qtype, record)
    #                         return record
    #             except Exception as e:
    #                 logger.debug(f"Upstream DNS query failed for {dns_server}: {e}")
    #                 continue

    #         return None

    #     def _build_dns_query(self, domain: str, qtype: int) -> bytes:
    #         """Build DNS query packet."""
    #         # Simple DNS query builder (simplified for basic A record queries)
    transaction_id = hash(domain.encode()) & 0xFFFF

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
    domain_parts = domain.split('.')
    question = b''
    #         for part in domain_parts:
    question + = struct.pack("!B", len(part)) + part.encode()
    question + = b'\x00'  # End of domain name
    question + = struct.pack("!HH", qtype, 1)  # Type A, Class IN

    #         return header + question

    #     def _parse_dns_response(self, response_data: bytes, domain: str, qtype: int) -> Optional[DNSRecord]:
    #         """Parse DNS response packet."""
    #         try:
                # Skip header (12 bytes)
    offset = 12

    #             # Skip question section
    #             while offset < len(response_data) and response_data[offset] != 0:
    offset + = math.add(response_data[offset], 1)
    offset + = 3  # Skip QTYPE and QCLASS (6 bytes)

    #             # Parse answer section
    #             if len(response_data) > offset + 12:
                    # Skip answer name (pointer or labels)
    #                 if response_data[offset] & 0xC0 == 0xC0:
    offset + = 2  # Pointer
    #                 else:
    #                     while response_data[offset] != 0:
    offset + = math.add(response_data[offset], 1)
    offset + = 1

    #                 # Parse answer type, class, and TTL
    ans_type, ans_class, ttl = struct.unpack("!HHI", response_data[offset:offset+8])
    offset + = 8

    #                 # Parse answer data (A record = 4 bytes for IP)
    #                 if ans_type == DNS_TYPE_A and len(response_data) >= offset + 4:
    ip_addr = math.add(socket.inet_ntoa(response_data[offset:offset, 4]))
                        return DNSRecord(domain, qtype, int(ttl), ip_addr)
    #         except Exception as e:
                logger.debug(f"DNS response parsing failed: {e}")

    #         return None

    #     def create_response(self, query: DNSQuery, records: List[DNSRecord]) -> bytes:
    #         """Create DNS response packet."""
    #         # DNS Header
    header = struct.pack("!HHHHHH",
    #             query.transaction_id,  # Transaction ID
    #             0x8000 | (0x0000 if records else 0x0003),  # Flags: Response, with error code
    #             1,                     # Questions: 1
                len(records),          # Answer RRs
    #             0,                     # Authority RRs
    #             0                      # Additional RRs
    #         )

            # DNS Question (echo original)
    question = b''
    domain_parts = query.name.split('.')
    #         for part in domain_parts:
    question + = struct.pack("!B", len(part)) + part.encode()
    question + = b'\x00'
    question + = struct.pack("!HH", query.qtype, query.qclass)

    #         # DNS Answer sections
    answer = b''
    #         for record in records:
                # Answer name (pointer to question name)
    #             if record.name == query.name:
    answer + = b'\xC00C'  # Pointer to question name
    #             else:
    #                 # Build full name
    domain_parts = record.name.split('.')
    name_data = b''
    #                 for part in domain_parts:
    name_data + = struct.pack("!B", len(part)) + part.encode()
    name_data + = b'\x00'
    answer + = name_data

    #             # Answer type, class, TTL
    answer + = struct.pack("!HHI", record.qtype, query.qclass, record.ttl)

                # Answer data (A record)
    #             if record.qtype == DNS_TYPE_A:
    ip_parts = record.data.split('.')
    answer + = struct.pack("!HBBBBB",
    #                     4,              # Data length
                        int(ip_parts[0]),  # IP octets
                        int(ip_parts[1]),
                        int(ip_parts[2]),
                        int(ip_parts[3])
    #                 )

    #         return header + question + answer

    #     def handle_query(self, query_data: bytes, client_addr: Tuple[str, int]) -> Optional[bytes]:
    #         """Handle incoming DNS query."""
    #         with self.lock:
    #             if self.active_queries >= MAX_DNS_CONNECTIONS:
                    logger.warning("DNS query rejected - too many active queries")
    #                 return None
    self.active_queries + = 1

    #         try:
    #             # Parse DNS query
    query = self._parse_dns_query(query_data)
    #             if not query:
    #                 return None

    domain = query.name.rstrip('.')
                logger.debug(f"DNS query: {domain} (type {query.qtype}) from {client_addr}")

    #             # Check cache first
    cached_record = self.cache.get(domain, query.qtype)
    #             if cached_record:
                    return self.create_response(query, [cached_record])

    #             # Resolve domain
    response_records = []

    #             # Check if it's a NoodleCore domain
    resolved_ip = self.resolve_noodle_domain(domain)
    #             if resolved_ip:
    record = DNSRecord(domain, query.qtype, CACHE_TTL_SECONDS, resolved_ip)
                    response_records.append(record)

    #                 # Cache the result
                    self.cache.put(domain, query.qtype, record)
    #             else:
    #                 # Query upstream DNS
    upstream_record = self.query_upstream(domain, query.qtype)
    #                 if upstream_record:
                        response_records.append(upstream_record)

    #             # Create response
    #             if response_records:
                    return self.create_response(query, response_records)
    #             else:
    #                 # No records found - create NXDOMAIN response
                    return self._create_nxdomain_response(query)

    #         except Exception as e:
                logger.error(f"DNS query handling error: {e}")
    #             return None
    #         finally:
    #             with self.lock:
    self.active_queries = math.subtract(max(0, self.active_queries, 1))

    #     def _parse_dns_query(self, query_data: bytes) -> Optional[DNSQuery]:
    #         """Parse DNS query packet."""
    #         try:
    #             # Parse header
    #             if len(query_data) < 12:
    #                 return None

    transaction_id, flags, qdcount, _, _, _ = struct.unpack("!HHHHHH", query_data[:12])

    #             # Parse question
    offset = 12
    domain_parts = []
    #             while offset < len(query_data) and query_data[offset] != 0:
    length = query_data[offset]
    #                 if length == 0 or offset + length + 1 > len(query_data):
    #                     break
                    domain_parts.append(query_data[offset+1:offset+1+length].decode())
    offset + = math.add(length, 1)

    #             if offset >= len(query_data) - 4:
    #                 return None

    #             # Parse QTYPE and QCLASS
    #             qtype, qclass = struct.unpack("!HH", query_data[offset:offset+4])

    domain = '.'.join(domain_parts)
                return DNSQuery(domain, qtype, qclass, transaction_id)

    #         except Exception as e:
                logger.debug(f"DNS query parsing failed: {e}")
    #             return None

    #     def _create_nxdomain_response(self, query: DNSQuery) -> bytes:
    #         """Create NXDOMAIN response."""
    #         # DNS Header with NXDOMAIN flag
    header = struct.pack("!HHHHHH",
    #             query.transaction_id,
    #             0x8003,  # Response + NXDOMAIN
    #             1,       # Questions: 1
    #             0,       # Answer RRs: 0
    #             0,       # Authority RRs: 0
    #             0        # Additional RRs: 0
    #         )

            # DNS Question (echo original)
    question = b''
    domain_parts = query.name.split('.')
    #         for part in domain_parts:
    question + = struct.pack("!B", len(part)) + part.encode()
    question + = b'\x00'
    question + = struct.pack("!HH", query.qtype, query.qclass)

    #         return header + question


class DNSServer
    #     """DNS Server for NoodleCore home network access."""

    #     def __init__(self, host: str = "0.0.0.0", port: int = DEFAULT_DNS_PORT, debug: bool = False):
    #         """Initialize DNS Server.

    #         Args:
    #             host: Host address to bind to
    #             port: Port to bind to
    #             debug: Enable debug mode
    #         """
    self.host = host
    self.port = port
    self.debug = debug
    self.start_time = time.time()
    self.cache = DNSCache()
    self.responder = DNSResponder(self.cache)
    self.running = False
    self.socket = None

            logger.info(f"DNS Server initialized on {host}:{port}")

    #     def start(self):
    #         """Start the DNS server."""
    #         try:
    self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    #             # Set socket timeout for graceful shutdown
                self.socket.settimeout(1.0)

    #             # Bind to address and port
                self.socket.bind((self.host, self.port))
    self.running = True

                logger.info(f"DNS Server listening on {self.host}:{self.port}")
                logger.info(f"Configured domains: {list(self.noodle_domains.keys())}")

    #             # Start query handling loop
                self._handle_queries()

    #         except Exception as e:
                logger.error(f"Failed to start DNS server: {e}")
    #             raise
    #         finally:
    #             if self.socket:
                    self.socket.close()
    self.running = False

    #     def _handle_queries(self):
    #         """Main DNS query handling loop."""
    #         while self.running:
    #             try:
    #                 # Receive DNS query
    query_data, client_addr = self.socket.recvfrom(512)

    #                 # Process query in separate thread for concurrent handling
    query_thread = threading.Thread(
    target = self._process_query,
    args = (query_data, client_addr),
    daemon = True
    #                 )
                    query_thread.start()

    #             except socket.timeout:
    #                 # Continue loop for graceful shutdown check
    #                 continue
    #             except Exception as e:
    #                 if self.running:
                        logger.error(f"DNS query reception error: {e}")

    #     def _process_query(self, query_data: bytes, client_addr: Tuple[str, int]):
    #         """Process DNS query in separate thread."""
    #         try:
    #             # Handle DNS query
    response_data = self.responder.handle_query(query_data, client_addr)

    #             if response_data:
    #                 # Send response back to client
                    self.socket.sendto(response_data, client_addr)
    #             else:
                    logger.debug(f"Failed to process DNS query from {client_addr}")

    #         except Exception as e:
                logger.error(f"Query processing error from {client_addr}: {e}")

    #     def stop(self):
    #         """Stop the DNS server."""
            logger.info("Stopping DNS server...")
    self.running = False
    #         if self.socket:
                self.socket.close()

    #     @property
    #     def noodle_domains(self) -> Dict[str, str]:
    #         """Get configured NoodleCore domains."""
    #         return self.responder.noodle_domains

    #     def get_status(self) -> Dict[str, Any]:
    #         """Get DNS server status and statistics."""
    #         return {
    #             "status": "running" if self.running else "stopped",
    #             "host": self.host,
    #             "port": self.port,
                "uptime_seconds": time.time() - self.start_time,
                "cache_entries": len(self.cache.cache),
    #             "active_queries": self.responder.active_queries,
                "configured_domains": list(self.noodle_domains.keys()),
                "server_ip": self.responder.get_server_ip()
    #         }


function create_dns_server(host: str = "0.0.0.0", port: int = DEFAULT_DNS_PORT, debug: bool = False)
    #     """Factory function to create DNS server instance.

    #     Args:
    #         host: Host address to bind to
    #         port: Port to bind to
    #         debug: Enable debug mode

    #     Returns:
    #         DNSServer instance
    #     """
    return DNSServer(host = host, port=port, debug=debug)


function main()
    #     """Main entry point for the DNS server."""
    #     import argparse

    parser = argparse.ArgumentParser(description="NoodleCore DNS Server")
        parser.add_argument(
    #         "--host",
    default = "0.0.0.0",
    help = f"Host address (default: 0.0.0.0)"
    #     )
        parser.add_argument(
    #         "--port",
    type = int,
    default = DEFAULT_DNS_PORT,
    help = f"Port number (default: {DEFAULT_DNS_PORT})"
    #     )
        parser.add_argument(
    #         "--debug",
    action = "store_true",
    help = "Enable debug mode"
    #     )

    args = parser.parse_args()

    #     # Create and run the DNS server
    #     try:
    server = create_dns_server(
    host = args.host,
    port = args.port,
    debug = args.debug
    #         )
            server.start()
    #     except KeyboardInterrupt:
            logger.info("DNS server stopped by user")
    #     except Exception as e:
            logger.error(f"Failed to start DNS server: {e}")
            sys.exit(1)


if __name__ == "__main__"
        main()