"""
Proto file for StageService definition.
"""

from pathlib import Path

PROTO_CONTENT = """
syntax = "proto3";

package noodlecore.network;

option java_multiple_files = true;
option java_package = "com.noodlecore.network";
option java_outer_classname = "StageServiceProto";

// Service for distributed stage execution.
service StageService {
  // Initialize execution session
  rpc CreateSession(CreateSessionRequest) returns (CreateSessionResponse);

  // Execute forward pass on this stage
  rpc ExecuteForward(ExecuteForwardRequest) returns (ExecuteForwardResponse);

  // Close and cleanup session
  rpc CloseSession(CloseSessionRequest) returns (CloseSessionResponse);

  // Health check
  rpc Ping(PingRequest) returns (PingResponse);

  // Report node capabilities
  rpc ReportCapabilities(CapabilitiesRequest) returns (CapabilitiesResponse);
}

// Session management
message CreateSessionRequest {
  string session_id = 1;
  StageConfig stage_config = 2;
  repeated string layer_names = 3;
  uint32 max_sequence_length = 4;
  string dtype = 5;
}

message CreateSessionResponse {
  bool success = 1;
  string error_message = 2;
  NodeInfo node_info = 3;
}

message CloseSessionRequest {
  string session_id = 1;
}

message CloseSessionResponse {
  bool success = 1;
  string error_message = 2;
}

// Forward pass execution
message ExecuteForwardRequest {
  string session_id = 1;
  uint32 token_index = 2;
  TensorData input_activations = 3;
  repeated uint32 stage_ids = 4;
}

message ExecuteForwardResponse {
  bool success = 1;
  string error_message = 2;
  TensorData output_activations = 3;
  ExecutionMetadata metadata = 4;
}

// Node capabilities
message CapabilitiesRequest {
  string node_id = 1;
}

message CapabilitiesResponse {
  string node_id = 1;
  HardwareInfo hardware = 2;
  repeated string supported_dtypes = 3;
  float available_memory_gb = 4;
  float bandwidth_mbps = 5;
}

// Data structures
message StageConfig {
  string stage_id = 1;
  uint32 stage_index = 2;
  string device = 3;
  bool enable_kv_cache = 4;
}

message TensorData {
  string dtype = 1;
  repeated uint32 shape = 2;
  bytes data = 3;
  uint64 num_bytes = 4;
}

message ExecutionMetadata {
  float forward_latency_ms = 1;
  float transfer_latency_ms = 2;
  float peak_memory_mb = 3;
  string device = 4;
  uint32 stage_index = 5;
}

message NodeInfo {
  string node_id = 1;
  string host = 2;
  uint32 port = 3;
  HardwareInfo hardware = 4;
  float load_factor = 5;
}

message HardwareInfo {
  string device_type = 1;
  string device_name = 2;
  float total_memory_gb = 3;
  float compute_capability = 4;
  float network_bandwidth_mbps = 5;
}

// Health check
message PingRequest {
  string message = 1;
}

message PingResponse {
  string message = 1;
  string timestamp = 2;
  string node_version = 3;
}
"""

def get_proto_path() -> Path:
    """Get path to proto file."""
    return Path(__file__).parent.parent.parent / "protos" / "stage_service.proto"
