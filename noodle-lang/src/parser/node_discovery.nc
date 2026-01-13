# Node Discovery Module
# ====================
# 
# Automatic node discovery and registration for NoodleCore distributed development.
# Handles discovery protocols, node registration, and network topology maintenance.
#
# Discovery Methods:
# - UDP Broadcast discovery for local networks
# - Multicast discovery for subnet communication
# - Direct connection attempts for known addresses
# - Cloud-based discovery for wide area networks

module node_discovery
version: "1.0.0"
author: "NoodleCore Development Team"
description: "Node Discovery for distributed network formation"

# Core Dependencies
dependencies:
  - socket
  - threading
  - asyncio
  - json
  - time
  - uuid
  - logging
  - struct
  - ipaddress

# Discovery Constants
constants:
  DISCOVERY_PORT: 8081
  BROADCAST_PORT: 8082
  MULTICAST_GROUP: "239.255.42.99"
  DISCOVERY_TIMEOUT: 5.0
  HEARTBEAT_INTERVAL: 10.0
  NODE_TTL: 30.0
  MAX_DISCOVERY_RETRIES: 3
  DISCOVERY_BUFFER_SIZE: 1024

# Discovery Types
enum DiscoveryMethod:
  UDP_BROADCAST
  MULTICAST
  DIRECT_CONNECTION
  CLOUD_REGISTRY
  MANUAL_ENTRY

# Discovery Status
enum DiscoveryStatus:
  IDLE
  DISCOVERING
  REGISTERING
  HEARTBEATING
  SYNCHRONIZING
  FAILED

# Discovery Request
struct DiscoveryRequest:
  request_id: string
  sender_id: string
  sender_type: string
  discovery_method: DiscoveryMethod
  timestamp: float
  capabilities: [string]
  version: string

# Discovery Response
struct DiscoveryResponse:
  request_id: string
  responder_id: string
  responder_type: string
  host: string
  port: int
  capabilities: [string]
  load_factor: float
  timestamp: float
  version: string
  metadata: dict

# Network Service
struct NetworkService:
  service_type: string
  service_id: string
  host: string
  port: int
  endpoint: string
  protocols: [string]
  metadata: dict

# Discovered Node
struct DiscoveredNode:
  node_id: string
  host: string
  port: int
  node_type: string
  capabilities: [string]
  last_seen: float
  response_time: float
  connection_quality: float
  discovery_method: DiscoveryMethod
  services: [NetworkService]
  metadata: dict

# Core Classes
class NodeDiscoveryService:
  """Service for discovering and registering network nodes."""
  
  # Properties
  service_id: string
  discovery_status: DiscoveryStatus
  discovered_nodes: [DiscoveredNode]
  known_addresses: [string]
  discovery_methods: [DiscoveryMethod]
  active_discovery_threads: dict
  heartbeat_threads: dict
  node_registry: dict
  network_interfaces: [string]
  discovery_callbacks: dict
  
  # Constructor
  init():
    self.service_id = self._generate_service_id()
    self.discovery_status = DiscoveryStatus.IDLE
    self.discovered_nodes = []
    self.known_addresses = []
    self.active_discovery_threads = {}
    self.heartbeat_threads = {}
    self.node_registry = {}
    self.network_interfaces = self._get_network_interfaces()
    self.discovery_callbacks = {}
    
    # Enable all discovery methods
    self.discovery_methods = [
      DiscoveryMethod.UDP_BROADCAST,
      DiscoveryMethod.MULTICAST,
      DiscoveryMethod.DIRECT_CONNECTION,
      DiscoveryMethod.MANUAL_ENTRY
    ]
    
    log_info(f"Node Discovery Service initialized: {self.service_id}")
  
  # Discovery Methods
  func start_discovery(methods: [DiscoveryMethod] = None, timeout: float = DISCOVERY_TIMEOUT) -> [DiscoveredNode]:
    """Start node discovery using specified methods."""
    if methods is None:
      methods = self.discovery_methods
    
    self.discovery_status = DiscoveryStatus.DISCOVERING
    found_nodes = []
    
    # Start discovery using each method
    for method in methods:
      try:
        log_info(f"Starting discovery using {method}")
        
        if method == DiscoveryMethod.UDP_BROADCAST:
          nodes = self._discover_via_udp_broadcast(timeout)
        elif method == DiscoveryMethod.MULTICAST:
          nodes = self._discover_via_multicast(timeout)
        elif method == DiscoveryMethod.DIRECT_CONNECTION:
          nodes = self._discover_via_direct_connection(timeout)
        elif method == DiscoveryMethod.MANUAL_ENTRY:
          nodes = self._discover_via_manual_entries(timeout)
        else:
          log_warn(f"Unknown discovery method: {method}")
          continue
        
        found_nodes.extend(nodes)
        log_info(f"Discovered {len(nodes)} nodes via {method}")
        
      except Exception as e:
        log_error(f"Discovery method {method} failed: {str(e)}")
    
    # Deduplicate and filter nodes
    unique_nodes = self._deduplicate_nodes(found_nodes)
    
    # Update discovered nodes list
    self.discovered_nodes = unique_nodes
    
    # Start heartbeat monitoring for discovered nodes
    self._start_heartbeat_monitoring(unique_nodes)
    
    self.discovery_status = DiscoveryStatus.IDLE
    
    log_info(f"Total discovered nodes: {len(unique_nodes)}")
    return unique_nodes
  
  func _discover_via_udp_broadcast(timeout: float) -> [DiscoveredNode]:
    """Discover nodes via UDP broadcast."""
    discovered = []
    
    try:
      # Create UDP socket
      sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
      sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
      sock.settimeout(timeout)
      
      # Broadcast discovery request
      request = {
        "type": "noodle_discovery",
        "version": "1.0.0",
        "sender_id": self.service_id,
        "timestamp": time.time()
      }
      
      # Send broadcast on all network interfaces
      for interface_ip in self.network_interfaces:
        try:
          # Send to local network broadcast
          broadcast_addr = self._calculate_broadcast_address(interface_ip)
          if broadcast_addr:
            sock.sendto(json.dumps(request).encode(), (broadcast_addr, BROADCAST_PORT))
            log_debug(f"Broadcast sent to {broadcast_addr}:{BROADCAST_PORT}")
        except Exception as e:
          log_debug(f"Broadcast failed for interface {interface_ip}: {str(e)}")
      
      # Listen for responses
      start_time = time.time()
      while time.time() - start_time < timeout:
        try:
          data, addr = sock.recvfrom(DISCOVERY_BUFFER_SIZE)
          response_data = json.loads(data.decode())
          
          if self._is_valid_discovery_response(response_data):
            node = self._parse_discovery_response(response_data, addr, DiscoveryMethod.UDP_BROADCAST)
            discovered.append(node)
            
        except socket.timeout:
          break
        except Exception as e:
          log_debug(f"UDP discovery receive error: {str(e)}")
      
      sock.close()
      
    except Exception as e:
      log_error(f"UDP broadcast discovery failed: {str(e)}")
    
    return discovered
  
  func _discover_via_multicast(timeout: float) -> [DiscoveredNode]:
    """Discover nodes via multicast."""
    discovered = []
    
    try:
      # Create multicast socket
      sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
      sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
      sock.settimeout(timeout)
      
      # Join multicast group
      mreq = struct.pack("4s4s", socket.inet_aton(MULTICAST_GROUP), socket.inet_aton("0.0.0.0"))
      sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)
      
      # Send multicast discovery request
      request = {
        "type": "noodle_multicast_discovery",
        "version": "1.0.0",
        "sender_id": self.service_id,
        "timestamp": time.time()
      }
      
      sock.sendto(json.dumps(request).encode(), (MULTICAST_GROUP, DISCOVERY_PORT))
      
      # Listen for responses
      start_time = time.time()
      while time.time() - start_time < timeout:
        try:
          data, addr = sock.recvfrom(DISCOVERY_BUFFER_SIZE)
          response_data = json.loads(data.decode())
          
          if self._is_valid_discovery_response(response_data):
            node = self._parse_discovery_response(response_data, addr, DiscoveryMethod.MULTICAST)
            discovered.append(node)
            
        except socket.timeout:
          break
        except Exception as e:
          log_debug(f"Multicast discovery receive error: {str(e)}")
      
      sock.close()
      
    except Exception as e:
      log_error(f"Multicast discovery failed: {str(e)}")
    
    return discovered
  
  func _discover_via_direct_connection(timeout: float) -> [DiscoveredNode]:
    """Discover nodes via direct connection attempts."""
    discovered = []
    
    for address in self.known_addresses:
      try:
        # Test connection to known address
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout / len(self.known_addresses))
        
        # Try standard ports
        for port in [8080, 8081, 3000, 5000]:
          try:
            sock.connect((address, port))
            
            # Send discovery request
            request = {
              "type": "noodle_direct_discovery",
              "version": "1.0.0",
              "sender_id": self.service_id,
              "timestamp": time.time()
            }
            
            sock.sendall(json.dumps(request).encode())
            
            # Read response
            sock.settimeout(timeout / len(self.known_addresses))
            response_data = sock.recv(DISCOVERY_BUFFER_SIZE)
            
            if response_data:
              response = json.loads(response_data.decode())
              if self._is_valid_discovery_response(response):
                addr = (address, port)
                node = self._parse_discovery_response(response, addr, DiscoveryMethod.DIRECT_CONNECTION)
                discovered.append(node)
                break
                
          except socket.timeout:
            continue
          except Exception as e:
            log_debug(f"Direct connection failed to {address}:{port}: {str(e)}")
            continue
          
          finally:
            sock.close()
            
      except Exception as e:
        log_debug(f"Direct connection failed to {address}: {str(e)}")
    
    return discovered
  
  func _discover_via_manual_entries(timeout: float) -> [DiscoveredNode]:
    """Discover nodes from manually configured entries."""
    discovered = []
    
    # Check manually configured nodes
    for node_config in self._get_manually_configured_nodes():
      try:
        node = self._test_manual_node_entry(node_config, timeout)
        if node:
          discovered.append(node)
      except Exception as e:
        log_debug(f"Manual node entry test failed: {str(e)}")
    
    return discovered
  
  # Node Registry Management
  func register_node(node: DiscoveredNode) -> bool:
    """Register a discovered node in the local registry."""
    try:
      # Add to registry
      self.node_registry[node.node_id] = node
      
      # Start heartbeat monitoring
      self._start_node_heartbeat(node)
      
      log_info(f"Node registered: {node.node_id} at {node.host}:{node.port}")
      return True
      
    except Exception as e:
      log_error(f"Failed to register node {node.node_id}: {str(e)}")
      return False
  
  func unregister_node(node_id: string):
    """Unregister a node from the registry."""
    if node_id in self.node_registry:
      del self.node_registry[node_id]
      
      # Stop heartbeat monitoring
      if node_id in self.heartbeat_threads:
        # Stop heartbeat thread
        self.heartbeat_threads[node_id] = None
      
      log_info(f"Node unregistered: {node_id}")
  
  func get_registered_nodes() -> [DiscoveredNode]:
    """Get list of all registered nodes."""
    return list(self.node_registry.values())
  
  func find_node_by_id(node_id: string) -> DiscoveredNode:
    """Find a specific node by ID."""
    return self.node_registry.get(node_id)
  
  # Heartbeat Monitoring
  func _start_heartbeat_monitoring(nodes: [DiscoveredNode]):
    """Start heartbeat monitoring for discovered nodes."""
    for node in nodes:
      self._start_node_heartbeat(node)
  
  func _start_node_heartbeat(node: DiscoveredNode):
    """Start heartbeat monitoring for a specific node."""
    def heartbeat_worker():
      while node.node_id in self.node_registry:
        try:
          # Send heartbeat
          if self._send_heartbeat(node):
            node.last_seen = time.time()
            node.connection_quality = min(node.connection_quality + 0.1, 1.0)
          else:
            node.connection_quality = max(node.connection_quality - 0.1, 0.0)
            
          time.sleep(HEARTBEAT_INTERVAL)
          
        except Exception as e:
          log_debug(f"Heartbeat error for node {node.node_id}: {str(e)}")
          break
    
    # Start heartbeat thread
    self.heartbeat_threads[node.node_id] = threading.Thread(target=heartbeat_worker, daemon=True)
    self.heartbeat_threads[node.node_id].start()
  
  func _send_heartbeat(node: DiscoveredNode) -> bool:
    """Send heartbeat to a node."""
    try:
      sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      sock.settimeout(5.0)
      sock.connect((node.host, node.port))
      
      # Send heartbeat
      heartbeat_request = {
        "type": "heartbeat",
        "sender_id": self.service_id,
        "timestamp": time.time()
      }
      
      sock.sendall(json.dumps(heartbeat_request).encode())
      
      # Read response
      response = sock.recv(1024)
      sock.close()
      
      return response and b"heartbeat_ack" in response
      
    except Exception as e:
      log_debug(f"Heartbeat failed to {node.node_id}: {str(e)}")
      return False
  
  # Discovery Utilities
  func _get_network_interfaces() -> [string]:
    """Get list of active network interfaces."""
    interfaces = []
    try:
      import psutil
      for interface, addrs in psutil.net_if_addrs().items():
        for addr in addrs:
          if addr.family == socket.AF_INET:
            interfaces.append(addr.address)
    except ImportError:
      # Fallback: try to get local IP
      try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.connect(("8.8.8.8", 80))
        interfaces.append(sock.getsockname()[0])
        sock.close()
      except:
        interfaces.append("127.0.0.1")
    
    return interfaces
  
  func _calculate_broadcast_address(ip_address: string) -> string:
    """Calculate broadcast address for a network interface."""
    try:
      import ipaddress
      network = ipaddress.IPv4Network(f"{ip_address}/24", strict=False)
      return str(network.broadcast_address)
    except:
      # Fallback: assume /24 network
      parts = ip_address.split('.')
      if len(parts) == 4:
        return f"{parts[0]}.{parts[1]}.{parts[2]}.255"
    return None
  
  func _is_valid_discovery_response(response_data: dict) -> bool:
    """Validate if response data is a valid discovery response."""
    required_fields = ["type", "responder_id", "host"]
    return all(field in response_data for field in required_fields)
  
  func _parse_discovery_response(response_data: dict, addr: tuple, method: DiscoveryMethod) -> DiscoveredNode:
    """Parse discovery response into DiscoveredNode."""
    return DiscoveredNode(
      node_id = response_data.get("responder_id", str(uuid.uuid4())),
      host = response_data.get("host", addr[0]),
      port = response_data.get("port", addr[1]),
      node_type = response_data.get("responder_type", "unknown"),
      capabilities = response_data.get("capabilities", []),
      last_seen = time.time(),
      response_time = 0.0,  # Would be calculated based on round-trip time
      connection_quality = 1.0,
      discovery_method = method,
      services = response_data.get("services", []),
      metadata = response_data.get("metadata", {})
    )
  
  func _deduplicate_nodes(nodes: [DiscoveredNode]) -> [DiscoveredNode]:
    """Remove duplicate nodes from discovery results."""
    seen_ids = set()
    unique_nodes = []
    
    for node in nodes:
      if node.node_id not in seen_ids:
        seen_ids.add(node.node_id)
        unique_nodes.append(node)
    
    return unique_nodes
  
  # Configuration Management
  func add_known_address(address: string):
    """Add a known address for direct connection discovery."""
    self.known_addresses.append(address)
    log_info(f"Added known address: {address}")
  
  def _get_manually_configured_nodes() -> [dict]:
    """Get manually configured nodes from configuration."""
    # Would load from configuration file or environment
    return []
  
  def _test_manual_node_entry(node_config: dict, timeout: float) -> DiscoveredNode:
    """Test a manually configured node entry."""
    # Test connection to manually configured node
    return None
  
  func _generate_service_id() -> string:
    """Generate unique service identifier."""
    return str(uuid.uuid4())
  
  # Discovery Statistics
  func get_discovery_statistics() -> dict:
    """Get discovery service statistics."""
    return {
      "service_id": self.service_id,
      "status": self.discovery_status.value,
      "discovered_nodes_count": len(self.discovered_nodes),
      "registered_nodes_count": len(self.node_registry),
      "known_addresses_count": len(self.known_addresses),
      "active_heartbeat_threads": len(self.heartbeat_threads),
      "network_interfaces": self.network_interfaces,
      "enabled_discovery_methods": [method.value for method in self.discovery_methods]
    }

# Logging Functions
func log_info(message: string):
  logging.info(f"[NodeDiscovery] {message}")

func log_warn(message: string):
  logging.warning(f"[NodeDiscovery] {message}")

func log_error(message: string):
  logging.error(f"[NodeDiscovery] {message}")

func log_debug(message: string):
  logging.debug(f"[NodeDiscovery] {message}")

# Export
export NodeDiscoveryService, DiscoveryRequest, DiscoveryResponse, NetworkService, DiscoveredNode
export DiscoveryMethod, DiscoveryStatus