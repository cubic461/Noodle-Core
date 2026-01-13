"""
Noodlenet::Fault Tolerance - fault_tolerance.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fault tolerance mechanisms for NoodleNet distributed systems.

This module provides comprehensive fault tolerance including failure detection,
automatic recovery, checkpointing, and replication strategies.
"""

import asyncio
import time
import logging
import json
import hashlib
import pickle
import zlib
from typing import Dict, List, Optional, Set, Tuple, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import uuid
from .config import NoodleNetConfig
from .identity import NodeIdentity
from .routing import MessageRouter, RouteInfo
from .link import Message

logger = logging.getLogger(__name__)


class FailureType(Enum):
    """Types of failures that can occur"""
    NODE_FAILURE = "node_failure"
    NETWORK_PARTITION = "network_partition"
    MESSAGE_LOSS = "message_loss"
    CORRUPTION = "corruption"
    TIMEOUT = "timeout"
    RESOURCE_EXHAUSTION = "resource_exhaustion"
    SOFTWARE_BUG = "software_bug"
    HARDWARE_FAILURE = "hardware_failure"


class FailureSeverity(Enum):
    """Failure severity levels"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class RecoveryStrategy(Enum):
    """Recovery strategies"""
    RETRY = "retry"
    FAILOVER = "failover"
    ROLLBACK = "rollback"
    RESTART = "restart"
    REPLICATION = "replication"
    DEGRADATION = "degradation"


@dataclass
class FailureEvent:
    """Represents a failure event"""
    
    event_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    failure_type: FailureType = FailureType.NODE_FAILURE
    severity: FailureSeverity = FailureSeverity.MEDIUM
    timestamp: float = field(default_factory=time.time)
    node_id: Optional[str] = None
    component: Optional[str] = None
    description: str = ""
    details: Dict[str, Any] = field(default_factory=dict)
    
    # Recovery information
    recovery_strategy: Optional[RecoveryStrategy] = None
    recovery_attempts: int = 0
    max_recovery_attempts: int = 3
    recovery_time: Optional[float] = None
    recovery_successful: bool = False
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'event_id': self.event_id,
            'failure_type': self.failure_type.value,
            'severity': self.severity.value,
            'timestamp': self.timestamp,
            'node_id': self.node_id,
            'component': self.component,
            'description': self.description,
            'details': self.details,
            'recovery_strategy': self.recovery_strategy.value if self.recovery_strategy else None,
            'recovery_attempts': self.recovery_attempts,
            'max_recovery_attempts': self.max_recovery_attempts,
            'recovery_time': self.recovery_time,
            'recovery_successful': self.recovery_successful
        }


@dataclass
class Checkpoint:
    """Checkpoint data for recovery"""
    
    checkpoint_id: str
    node_id: str
    timestamp: float
    data: Any
    checksum: str
    version: int = 1
    
    # Metadata
    size_bytes: int = 0
    compression_ratio: float = 1.0
    creation_time: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'checkpoint_id': self.checkpoint_id,
            'node_id': self.node_id,
            'timestamp': self.timestamp,
            'checksum': self.checksum,
            'version': self.version,
            'size_bytes': self.size_bytes,
            'compression_ratio': self.compression_ratio,
            'creation_time': self.creation_time
        }


@dataclass
class ReplicationState:
    """Replication state for data"""
    
    data_id: str
    primary_node: str
    replica_nodes: List[str]
    replication_factor: int
    consistency_level: str  # "eventual", "strong", "quorum"
    
    # Replication status
    last_replication: float = field(default_factory=time.time)
    pending_replications: Set[str] = field(default_factory=set)
    failed_replications: Set[str] = field(default_factory=set)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'data_id': self.data_id,
            'primary_node': self.primary_node,
            'replica_nodes': self.replica_nodes,
            'replication_factor': self.replication_factor,
            'consistency_level': self.consistency_level,
            'last_replication': self.last_replication,
            'pending_replications': list(self.pending_replications),
            'failed_replications': list(self.failed_replications)
        }


class FailureDetector:
    """Failure detection using heartbeat and timeout mechanisms"""
    
    def __init__(self, local_node_id: str, config: Optional[NoodleNetConfig] = None):
        """
        Initialize failure detector
        
        Args:
            local_node_id: ID of the local node
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.config = config or NoodleNetConfig()
        
        # Node state
        self._node_status: Dict[str, Dict[str, Any]] = {}
        self._heartbeat_intervals: Dict[str, float] = {}
        self._last_heartbeat: Dict[str, float] = {}
        
        # Failure detection
        self._failure_threshold = self.config.failure_detection_threshold
        self._heartbeat_interval = self.config.heartbeat_interval
        
        # Background tasks
        self._heartbeat_task: Optional[asyncio.Task] = None
        self._detection_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Event handlers
        self._failure_detected_handler: Optional[Callable] = None
        self._node_recovered_handler: Optional[Callable] = None
    
    async def start(self):
        """Start failure detector"""
        if self._running:
            return
        
        self._running = True
        self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())
        self._detection_task = asyncio.create_task(self._detection_loop())
        
        logger.info("Failure detector started")
    
    async def stop(self):
        """Stop failure detector"""
        if not self._running:
            return
        
        self._running = False
        
        # Cancel background tasks
        for task in [self._heartbeat_task, self._detection_task]:
            if task and not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        logger.info("Failure detector stopped")
    
    def register_node(self, node_id: str, heartbeat_interval: Optional[float] = None):
        """
        Register a node for failure detection
        
        Args:
            node_id: ID of the node to monitor
            heartbeat_interval: Custom heartbeat interval
        """
        self._node_status[node_id] = {
            'status': 'unknown',
            'last_seen': time.time(),
            'missed_heartbeats': 0,
            'consecutive_failures': 0
        }
        
        self._heartbeat_intervals[node_id] = heartbeat_interval or self._heartbeat_interval
        self._last_heartbeat[node_id] = time.time()
        
        logger.debug(f"Registered node {node_id} for failure detection")
    
    def unregister_node(self, node_id: str):
        """Unregister a node from failure detection"""
        self._node_status.pop(node_id, None)
        self._heartbeat_intervals.pop(node_id, None)
        self._last_heartbeat.pop(node_id, None)
        
        logger.debug(f"Unregistered node {node_id} from failure detection")
    
    def process_heartbeat(self, node_id: str, heartbeat_data: Dict[str, Any]):
        """
        Process a heartbeat from a node
        
        Args:
            node_id: ID of the node sending the heartbeat
            heartbeat_data: Heartbeat data
        """
        if node_id not in self._node_status:
            self.register_node(node_id)
        
        # Update node status
        self._node_status[node_id].update({
            'status': 'alive',
            'last_seen': time.time(),
            'missed_heartbeats': 0,
            'consecutive_failures': 0
        })
        
        self._last_heartbeat[node_id] = time.time()
        
        # Check if node was previously failed
        if self._node_status[node_id].get('previously_failed', False):
            self._node_status[node_id]['previously_failed'] = False
            
            # Call recovery handler
            if self._node_recovered_handler:
                asyncio.create_task(self._node_recovered_handler(node_id))
            
            logger.info(f"Node {node_id} has recovered")
    
    def get_node_status(self, node_id: str) -> Optional[Dict[str, Any]]:
        """Get the status of a node"""
        return self._node_status.get(node_id)
    
    def get_all_node_status(self) -> Dict[str, Dict[str, Any]]:
        """Get status of all monitored nodes"""
        return self._node_status.copy()
    
    def set_failure_detected_handler(self, handler: Callable):
        """Set handler for failure detection events"""
        self._failure_detected_handler = handler
    
    def set_node_recovered_handler(self, handler: Callable):
        """Set handler for node recovery events"""
        self._node_recovered_handler = handler
    
    async def _heartbeat_loop(self):
        """Send heartbeats to other nodes"""
        while self._running:
            try:
                # In a real implementation, this would send heartbeats to other nodes
                # For now, we'll simulate heartbeat processing
                
                await asyncio.sleep(self._heartbeat_interval)
                
            except Exception as e:
                logger.error(f"Error in heartbeat loop: {e}")
                await asyncio.sleep(5)
    
    async def _detection_loop(self):
        """Detect failures based on missed heartbeats"""
        while self._running:
            try:
                current_time = time.time()
                
                for node_id, status in self._node_status.items():
                    if node_id == self.local_node_id:
                        continue  # Skip local node
                    
                    # Check if heartbeat is missed
                    heartbeat_interval = self._heartbeat_intervals.get(node_id, self._heartbeat_interval)
                    time_since_last = current_time - self._last_heartbeat.get(node_id, 0)
                    
                    if time_since_last > heartbeat_interval * self._failure_threshold:
                        # Heartbeat missed
                        status['missed_heartbeats'] += 1
                        
                        if status['missed_heartbeats'] >= self._failure_threshold:
                            # Node considered failed
                            if status['status'] != 'failed':
                                status['status'] = 'failed'
                                status['consecutive_failures'] += 1
                                status['previously_failed'] = True
                                
                                # Create failure event
                                failure_event = FailureEvent(
                                    failure_type=FailureType.NODE_FAILURE,
                                    severity=FailureSeverity.HIGH,
                                    node_id=node_id,
                                    description=f"Node {node_id} failed to respond to heartbeats",
                                    details={
                                        'missed_heartbeats': status['missed_heartbeats'],
                                        'time_since_last': time_since_last,
                                        'consecutive_failures': status['consecutive_failures']
                                    }
                                )
                                
                                # Call failure handler
                                if self._failure_detected_handler:
                                    asyncio.create_task(self._failure_detected_handler(failure_event))
                                
                                logger.warning(f"Node {node_id} detected as failed")
                    else:
                        # Reset missed heartbeats
                        status['missed_heartbeats'] = 0
                
                await asyncio.sleep(heartbeat_interval)
                
            except Exception as e:
                logger.error(f"Error in failure detection loop: {e}")
                await asyncio.sleep(5)


class CheckpointManager:
    """Manager for creating and restoring checkpoints"""
    
    def __init__(self, local_node_id: str, config: Optional[NoodleNetConfig] = None):
        """
        Initialize checkpoint manager
        
        Args:
            local_node_id: ID of the local node
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.config = config or NoodleNetConfig()
        
        # Checkpoint storage
        self._checkpoints: Dict[str, Checkpoint] = {}
        self._checkpoint_metadata: Dict[str, Dict[str, Any]] = {}
        
        # Checkpoint configuration
        self._checkpoint_interval = self.config.checkpoint_interval
        self._max_checkpoints = self.config.max_checkpoints
        self._compression_enabled = self.config.checkpoint_compression
        
        # Background tasks
        self._checkpoint_task: Optional[asyncio.Task] = None
        self._cleanup_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Event handlers
        self._checkpoint_created_handler: Optional[Callable] = None
        self._checkpoint_restored_handler: Optional[Callable] = None
    
    async def start(self):
        """Start checkpoint manager"""
        if self._running:
            return
        
        self._running = True
        self._checkpoint_task = asyncio.create_task(self._checkpoint_loop())
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        logger.info("Checkpoint manager started")
    
    async def stop(self):
        """Stop checkpoint manager"""
        if not self._running:
            return
        
        self._running = False
        
        # Cancel background tasks
        for task in [self._checkpoint_task, self._cleanup_task]:
            if task and not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        logger.info("Checkpoint manager stopped")
    
    async def create_checkpoint(self, data: Any, checkpoint_id: Optional[str] = None) -> str:
        """
        Create a checkpoint
        
        Args:
            data: Data to checkpoint
            checkpoint_id: Optional custom checkpoint ID
            
        Returns:
            Checkpoint ID
        """
        if checkpoint_id is None:
            checkpoint_id = str(uuid.uuid4())
        
        # Serialize data
        try:
            serialized_data = pickle.dumps(data)
            
            # Compress if enabled
            if self._compression_enabled:
                compressed_data = zlib.compress(serialized_data)
                compression_ratio = len(serialized_data) / len(compressed_data)
            else:
                compressed_data = serialized_data
                compression_ratio = 1.0
            
            # Calculate checksum
            checksum = hashlib.sha256(compressed_data).hexdigest()
            
            # Create checkpoint
            checkpoint = Checkpoint(
                checkpoint_id=checkpoint_id,
                node_id=self.local_node_id,
                timestamp=time.time(),
                data=compressed_data,
                checksum=checksum,
                size_bytes=len(compressed_data),
                compression_ratio=compression_ratio
            )
            
            # Store checkpoint
            self._checkpoints[checkpoint_id] = checkpoint
            
            # Store metadata
            self._checkpoint_metadata[checkpoint_id] = {
                'original_size': len(serialized_data),
                'compressed_size': len(compressed_data),
                'compression_enabled': self._compression_enabled,
                'creation_time': time.time()
            }
            
            # Call handler
            if self._checkpoint_created_handler:
                asyncio.create_task(self._checkpoint_created_handler(checkpoint))
            
            logger.info(f"Created checkpoint {checkpoint_id} ({len(compressed_data)} bytes)")
            return checkpoint_id
            
        except Exception as e:
            logger.error(f"Failed to create checkpoint: {e}")
            raise
    
    async def restore_checkpoint(self, checkpoint_id: str) -> Any:
        """
        Restore data from a checkpoint
        
        Args:
            checkpoint_id: ID of checkpoint to restore
            
        Returns:
            Restored data
        """
        if checkpoint_id not in self._checkpoints:
            raise ValueError(f"Checkpoint {checkpoint_id} not found")
        
        checkpoint = self._checkpoints[checkpoint_id]
        
        try:
            # Verify checksum
            calculated_checksum = hashlib.sha256(checkpoint.data).hexdigest()
            if calculated_checksum != checkpoint.checksum:
                raise ValueError(f"Checkpoint {checkpoint_id} checksum verification failed")
            
            # Decompress if needed
            if self._compression_enabled:
                serialized_data = zlib.decompress(checkpoint.data)
            else:
                serialized_data = checkpoint.data
            
            # Deserialize data
            data = pickle.loads(serialized_data)
            
            # Call handler
            if self._checkpoint_restored_handler:
                asyncio.create_task(self._checkpoint_restored_handler(checkpoint, data))
            
            logger.info(f"Restored checkpoint {checkpoint_id}")
            return data
            
        except Exception as e:
            logger.error(f"Failed to restore checkpoint {checkpoint_id}: {e}")
            raise
    
    def get_checkpoint_info(self, checkpoint_id: str) -> Optional[Dict[str, Any]]:
        """Get information about a checkpoint"""
        if checkpoint_id not in self._checkpoints:
            return None
        
        checkpoint = self._checkpoints[checkpoint_id]
        metadata = self._checkpoint_metadata.get(checkpoint_id, {})
        
        info = checkpoint.to_dict()
        info.update(metadata)
        
        return info
    
    def list_checkpoints(self) -> List[Dict[str, Any]]:
        """List all checkpoints"""
        checkpoints = []
        
        for checkpoint_id, checkpoint in self._checkpoints.items():
            info = self.get_checkpoint_info(checkpoint_id)
            if info:
                checkpoints.append(info)
        
        # Sort by timestamp (newest first)
        checkpoints.sort(key=lambda x: x['timestamp'], reverse=True)
        
        return checkpoints
    
    async def delete_checkpoint(self, checkpoint_id: str) -> bool:
        """
        Delete a checkpoint
        
        Args:
            checkpoint_id: ID of checkpoint to delete
            
        Returns:
            True if successfully deleted
        """
        if checkpoint_id not in self._checkpoints:
            return False
        
        del self._checkpoints[checkpoint_id]
        self._checkpoint_metadata.pop(checkpoint_id, None)
        
        logger.info(f"Deleted checkpoint {checkpoint_id}")
        return True
    
    def set_checkpoint_created_handler(self, handler: Callable):
        """Set handler for checkpoint creation events"""
        self._checkpoint_created_handler = handler
    
    def set_checkpoint_restored_handler(self, handler: Callable):
        """Set handler for checkpoint restoration events"""
        self._checkpoint_restored_handler = handler
    
    async def _checkpoint_loop(self):
        """Periodic checkpoint creation"""
        while self._running:
            try:
                # In a real implementation, this would create checkpoints of system state
                # For now, we'll simulate periodic checkpoint creation
                
                await asyncio.sleep(self._checkpoint_interval)
                
            except Exception as e:
                logger.error(f"Error in checkpoint loop: {e}")
                await asyncio.sleep(30)
    
    async def _cleanup_loop(self):
        """Clean up old checkpoints"""
        while self._running:
            try:
                # Remove old checkpoints if we exceed the limit
                if len(self._checkpoints) > self._max_checkpoints:
                    # Get checkpoints sorted by timestamp (oldest first)
                    sorted_checkpoints = sorted(
                        self._checkpoints.items(),
                        key=lambda x: x[1].timestamp
                    )
                    
                    # Remove oldest checkpoints
                    to_remove = len(self._checkpoints) - self._max_checkpoints
                    for i in range(to_remove):
                        checkpoint_id = sorted_checkpoints[i][0]
                        await self.delete_checkpoint(checkpoint_id)
                
                await asyncio.sleep(300)  # Check every 5 minutes
                
            except Exception as e:
                logger.error(f"Error in checkpoint cleanup loop: {e}")
                await asyncio.sleep(60)


class ReplicationManager:
    """Manager for data replication across nodes"""
    
    def __init__(self, local_node_id: str, message_router: MessageRouter,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialize replication manager
        
        Args:
            local_node_id: ID of the local node
            message_router: Message router for communication
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.message_router = message_router
        self.config = config or NoodleNetConfig()
        
        # Replication state
        self._replication_states: Dict[str, ReplicationState] = {}
        self._replicated_data: Dict[str, Any] = {}
        
        # Replication configuration
        self._default_replication_factor = self.config.default_replication_factor
        self._replication_timeout = self.config.replication_timeout
        
        # Background tasks
        self._replication_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Event handlers
        self._replication_completed_handler: Optional[Callable] = None
        self._replication_failed_handler: Optional[Callable] = None
    
    async def start(self):
        """Start replication manager"""
        if self._running:
            return
        
        self._running = True
        self._replication_task = asyncio.create_task(self._replication_loop())
        
        logger.info("Replication manager started")
    
    async def stop(self):
        """Stop replication manager"""
        if not self._running:
            return
        
        self._running = False
        
        if self._replication_task and not self._replication_task.done():
            self._replication_task.cancel()
            try:
                await self._replication_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Replication manager stopped")
    
    async def replicate_data(self, data_id: str, data: Any, replica_nodes: List[str],
                           replication_factor: Optional[int] = None,
                           consistency_level: str = "eventual") -> bool:
        """
        Replicate data to other nodes
        
        Args:
            data_id: Unique ID for the data
            data: Data to replicate
            replica_nodes: List of target nodes for replication
            replication_factor: Number of replicas to create
            consistency_level: Consistency level for replication
            
        Returns:
            True if replication initiated successfully
        """
        if replication_factor is None:
            replication_factor = self._default_replication_factor
        
        # Limit replica nodes to replication factor
        target_nodes = replica_nodes[:replication_factor]
        
        # Create replication state
        replication_state = ReplicationState(
            data_id=data_id,
            primary_node=self.local_node_id,
            replica_nodes=target_nodes,
            replication_factor=replication_factor,
            consistency_level=consistency_level
        )
        
        self._replication_states[data_id] = replication_state
        self._replicated_data[data_id] = data
        
        # Start replication
        for node_id in target_nodes:
            replication_state.pending_replications.add(node_id)
            
            # Send replication message
            replication_message = Message(
                sender_id=self.local_node_id,
                recipient_id=node_id,
                message_type="replication_request",
                payload={
                    'data_id': data_id,
                    'data': data,
                    'primary_node': self.local_node_id,
                    'consistency_level': consistency_level
                }
            )
            
            # Send via message router
            try:
                route = await self.message_router.find_route(node_id, replication_message)
                if route:
                    await self.message_router.send_message(node_id, replication_message)
            except Exception as e:
                logger.error(f"Failed to send replication message to {node_id}: {e}")
                replication_state.pending_replications.discard(node_id)
                replication_state.failed_replications.add(node_id)
        
        logger.info(f"Initiated replication of {data_id} to {len(target_nodes)} nodes")
        return True
    
    async def handle_replication_request(self, message: Message) -> Dict[str, Any]:
        """
        Handle a replication request from another node
        
        Args:
            message: Replication request message
            
        Returns:
            Response dictionary
        """
        try:
            payload = message.payload
            data_id = payload['data_id']
            data = payload['data']
            primary_node = payload['primary_node']
            consistency_level = payload.get('consistency_level', 'eventual')
            
            # Store replicated data
            self._replicated_data[data_id] = data
            
            # Send acknowledgment
            ack_message = Message(
                sender_id=self.local_node_id,
                recipient_id=primary_node,
                message_type="replication_ack",
                payload={
                    'data_id': data_id,
                    'success': True,
                    'replica_node': self.local_node_id
                }
            )
            
            # Send acknowledgment
            route = await self.message_router.find_route(primary_node, ack_message)
            if route:
                await self.message_router.send_message(primary_node, ack_message)
            
            logger.info(f"Successfully replicated data {data_id} from {primary_node}")
            
            return {
                'success': True,
                'data_id': data_id,
                'message': 'Replication successful'
            }
            
        except Exception as e:
            logger.error(f"Failed to handle replication request: {e}")
            
            return {
                'success': False,
                'error': str(e),
                'message': 'Replication failed'
            }
    
    async def handle_replication_ack(self, message: Message):
        """
        Handle a replication acknowledgment
        
        Args:
            message: Replication acknowledgment message
        """
        try:
            payload = message.payload
            data_id = payload['data_id']
            success = payload['success']
            replica_node = payload['replica_node']
            
            if data_id in self._replication_states:
                replication_state = self._replication_states[data_id]
                
                if success:
                    replication_state.pending_replications.discard(replica_node)
                    
                    # Check if replication is complete
                    if not replication_state.pending_replications:
                        replication_state.last_replication = time.time()
                        
                        # Call handler
                        if self._replication_completed_handler:
                            asyncio.create_task(self._replication_completed_handler(data_id, replication_state))
                        
                        logger.info(f"Replication of {data_id} completed successfully")
                else:
                    replication_state.pending_replications.discard(replica_node)
                    replication_state.failed_replications.add(replica_node)
                    
                    # Call handler
                    if self._replication_failed_handler:
                        asyncio.create_task(self._replication_failed_handler(data_id, replica_node))
                    
                    logger.warning(f"Replication of {data_id} failed on {replica_node}")
            
        except Exception as e:
            logger.error(f"Failed to handle replication ack: {e}")
    
    def get_replication_state(self, data_id: str) -> Optional[ReplicationState]:
        """Get replication state for data"""
        return self._replication_states.get(data_id)
    
    def get_replicated_data(self, data_id: str) -> Optional[Any]:
        """Get replicated data"""
        return self._replicated_data.get(data_id)
    
    def set_replication_completed_handler(self, handler: Callable):
        """Set handler for replication completion events"""
        self._replication_completed_handler = handler
    
    def set_replication_failed_handler(self, handler: Callable):
        """Set handler for replication failure events"""
        self._replication_failed_handler = handler
    
    async def _replication_loop(self):
        """Replication monitoring and retry loop"""
        while self._running:
            try:
                current_time = time.time()
                
                # Check for timed-out replications
                for data_id, replication_state in list(self._replication_states.items()):
                    if replication_state.pending_replications:
                        # Check if any replication has timed out
                        for node_id in list(replication_state.pending_replications):
                            time_since_last = current_time - replication_state.last_replication
                            
                            if time_since_last > self._replication_timeout:
                                # Retry replication
                                logger.warning(f"Replication timeout for {data_id} on {node_id}, retrying")
                                
                                # Send retry message
                                retry_message = Message(
                                    sender_id=self.local_node_id,
                                    recipient_id=node_id,
                                    message_type="replication_request",
                                    payload={
                                        'data_id': data_id,
                                        'data': self._replicated_data.get(data_id),
                                        'primary_node': self.local_node_id,
                                        'consistency_level': replication_state.consistency_level,
                                        'retry': True
                                    }
                                )
                                
                                try:
                                    route = await self.message_router.find_route(node_id, retry_message)
                                    if route:
                                        await self.message_router.send_message(node_id, retry_message)
                                except Exception as e:
                                    logger.error(f"Failed to retry replication to {node_id}: {e}")
                                    replication_state.pending_replications.discard(node_id)
                                    replication_state.failed_replications.add(node_id)
                
                await asyncio.sleep(10)  # Check every 10 seconds
                
            except Exception as e:
                logger.error(f"Error in replication loop: {e}")
                await asyncio.sleep(30)


class FaultToleranceManager:
    """Comprehensive fault tolerance manager"""
    
    def __init__(self, local_node_id: str, message_router: MessageRouter,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialize fault tolerance manager
        
        Args:
            local_node_id: ID of the local node
            message_router: Message router for communication
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.message_router = message_router
        self.config = config or NoodleNetConfig()
        
        # Components
        self.failure_detector = FailureDetector(local_node_id, config)
        self.checkpoint_manager = CheckpointManager(local_node_id, config)
        self.replication_manager = ReplicationManager(local_node_id, message_router, config)
        
        # Failure history
        self._failure_history: List[FailureEvent] = []
        self._recovery_history: List[Dict[str, Any]] = []
        
        # Statistics
        self._stats = {
            'failures_detected': 0,
            'failures_recovered': 0,
            'checkpoints_created': 0,
            'checkpoints_restored': 0,
            'replications_completed': 0,
            'replications_failed': 0,
            'avg_recovery_time': 0.0,
            'system_uptime': time.time()
        }
        
        # Event handlers
        self._recovery_strategy_handlers: Dict[RecoveryStrategy, Callable] = {}
        
        # Setup component handlers
        self._setup_component_handlers()
    
    async def start(self):
        """Start fault tolerance manager"""
        # Start all components
        await self.failure_detector.start()
        await self.checkpoint_manager.start()
        await self.replication_manager.start()
        
        logger.info("Fault tolerance manager started")
    
    async def stop(self):
        """Stop fault tolerance manager"""
        # Stop all components
        await self.failure_detector.stop()
        await self.checkpoint_manager.stop()
        await self.replication_manager.stop()
        
        logger.info("Fault tolerance manager stopped")
    
    async def handle_failure(self, failure_event: FailureEvent) -> bool:
        """
        Handle a failure event
        
        Args:
            failure_event: Failure event to handle
            
        Returns:
            True if recovery was successful
        """
        # Add to failure history
        self._failure_history.append(failure_event)
        self._stats['failures_detected'] += 1
        
        # Determine recovery strategy
        recovery_strategy = self._determine_recovery_strategy(failure_event)
        failure_event.recovery_strategy = recovery_strategy
        
        # Execute recovery strategy
        recovery_successful = await self._execute_recovery_strategy(failure_event, recovery_strategy)
        
        # Update failure event
        failure_event.recovery_successful = recovery_successful
        failure_event.recovery_time = time.time()
        
        if recovery_successful:
            self._stats['failures_recovered'] += 1
            
            # Calculate recovery time
            recovery_time = failure_event.recovery_time - failure_event.timestamp
            self._update_avg_recovery_time(recovery_time)
            
            logger.info(f"Successfully recovered from failure {failure_event.event_id}")
        else:
            logger.error(f"Failed to recover from failure {failure_event.event_id}")
        
        return recovery_successful
    
    def get_failure_history(self, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get failure history"""
        history = [event.to_dict() for event in self._failure_history]
        
        # Sort by timestamp (newest first)
        history.sort(key=lambda x: x['timestamp'], reverse=True)
        
        if limit:
            history = history[:limit]
        
        return history
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get fault tolerance statistics"""
        stats = self._stats.copy()
        
        # Calculate uptime
        stats['system_uptime'] = time.time() - stats['system_uptime']
        
        # Calculate recovery rate
        if stats['failures_detected'] > 0:
            stats['recovery_rate'] = stats['failures_recovered'] / stats['failures_detected']
        else:
            stats['recovery_rate'] = 1.0
        
        # Add component statistics
        stats['node_status'] = self.failure_detector.get_all_node_status()
        stats['checkpoint_count'] = len(self.checkpoint_manager._checkpoints)
        stats['replication_states'] = len(self.replication_manager._replication_states)
        
        return stats
    
    def set_recovery_strategy_handler(self, strategy: RecoveryStrategy, handler: Callable):
        """Set handler for a specific recovery strategy"""
        self._recovery_strategy_handlers[strategy] = handler
    
    def _setup_component_handlers(self):
        """Setup handlers for fault tolerance components"""
        
        # Failure detector handlers
        async def on_failure_detected(failure_event: FailureEvent):
            await self.handle_failure(failure_event)
        
        async def on_node_recovered(node_id: str):
            logger.info(f"Node {node_id} has recovered")
            # In a real implementation, this would trigger rebalancing, etc.
        
        self.failure_detector.set_failure_detected_handler(on_failure_detected)
        self.failure_detector.set_node_recovered_handler(on_node_recovered)
        
        # Checkpoint handlers
        async def on_checkpoint_created(checkpoint: Checkpoint):
            self._stats['checkpoints_created'] += 1
            logger.debug(f"Checkpoint {checkpoint.checkpoint_id} created")
        
        async def on_checkpoint_restored(checkpoint: Checkpoint, data: Any):
            self._stats['checkpoints_restored'] += 1
            logger.debug(f"Checkpoint {checkpoint.checkpoint_id} restored")
        
        self.checkpoint_manager.set_checkpoint_created_handler(on_checkpoint_created)
        self.checkpoint_manager.set_checkpoint_restored_handler(on_checkpoint_restored)
        
        # Replication handlers
        async def on_replication_completed(data_id: str, replication_state: ReplicationState):
            self._stats['replications_completed'] += 1
            logger.debug(f"Replication of {data_id} completed")
        
        async def on_replication_failed(data_id: str, node_id: str):
            self._stats['replications_failed'] += 1
            logger.debug(f"Replication of {data_id} failed on {node_id}")
        
        self.replication_manager.set_replication_completed_handler(on_replication_completed)
        self.replication_manager.set_replication_failed_handler(on_replication_failed)
    
    def _determine_recovery_strategy(self, failure_event: FailureEvent) -> RecoveryStrategy:
        """Determine the best recovery strategy for a failure"""
        
        # Strategy selection based on failure type and severity
        if failure_event.failure_type == FailureType.NODE_FAILURE:
            if failure_event.severity == FailureSeverity.CRITICAL:
                return RecoveryStrategy.FAILOVER
            else:
                return RecoveryStrategy.REPLICATION
        
        elif failure_event.failure_type == FailureType.NETWORK_PARTITION:
            return RecoveryStrategy.RETRY
        
        elif failure_event.failure_type == FailureType.MESSAGE_LOSS:
            return RecoveryStrategy.RETRY
        
        elif failure_event.failure_type == FailureType.CORRUPTION:
            return RecoveryStrategy.ROLLBACK
        
        elif failure_event.failure_type == FailureType.TIMEOUT:
            return RecoveryStrategy.RETRY
        
        elif failure_event.failure_type == FailureType.RESOURCE_EXHAUSTION:
            return RecoveryStrategy.DEGRADATION
        
        elif failure_event.failure_type == FailureType.SOFTWARE_BUG:
            return RecoveryStrategy.RESTART
        
        elif failure_event.failure_type == FailureType.HARDWARE_FAILURE:
            return RecoveryStrategy.FAILOVER
        
        # Default strategy
        return RecoveryStrategy.RETRY
    
    async def _execute_recovery_strategy(self, failure_event: FailureEvent, 
                                        strategy: RecoveryStrategy) -> bool:
        """Execute a recovery strategy"""
        
        # Check if we have a custom handler for this strategy
        if strategy in self._recovery_strategy_handlers:
            try:
                return await self._recovery_strategy_handlers[strategy](failure_event)
            except Exception as e:
                logger.error(f"Custom recovery handler for {strategy} failed: {e}")
        
        # Default recovery strategies
        if strategy == RecoveryStrategy.RETRY:
            return await self._retry_recovery(failure_event)
        
        elif strategy == RecoveryStrategy.FAILOVER:
            return await self._failover_recovery(failure_event)
        
        elif strategy == RecoveryStrategy.ROLLBACK:
            return await self._rollback_recovery(failure_event)
        
        elif strategy == RecoveryStrategy.RESTART:
            return await self._restart_recovery(failure_event)
        
        elif strategy == RecoveryStrategy.REPLICATION:
            return await self._replication_recovery(failure_event)
        
        elif strategy == RecoveryStrategy.DEGRADATION:
            return await self._degradation_recovery(failure_event)
        
        # Unknown strategy
        logger.warning(f"Unknown recovery strategy: {strategy}")
        return False
    
    async def _retry_recovery(self, failure_event: FailureEvent) -> bool:
        """Retry recovery strategy"""
        max_retries = 3
        retry_delay = 1.0  # seconds
        
        for attempt in range(max_retries):
            try:
                # Simulate retry
                await asyncio.sleep(retry_delay)
                
                # In a real implementation, this would retry the failed operation
                # For now, we'll simulate success on the second attempt
                if attempt == 1:
                    logger.info(f"Retry {attempt + 1} successful for failure {failure_event.event_id}")
                    return True
                
            except Exception as e:
                logger.error(f"Retry {attempt + 1} failed: {e}")
                retry_delay *= 2  # Exponential backoff
        
        logger.error(f"All retries failed for failure {failure_event.event_id}")
        return False
    
    async def _failover_recovery(self, failure_event: FailureEvent) -> bool:
        """Failover recovery strategy"""
        try:
            # In a real implementation, this would failover to a backup node
            # For now, we'll simulate failover
            
            logger.info(f"Failing over for failure {failure_event.event_id}")
            await asyncio.sleep(2.0)  # Simulate failover time
            
            return True
            
        except Exception as e:
            logger.error(f"Failover failed: {e}")
            return False
    
    async def _rollback_recovery(self, failure_event: FailureEvent) -> bool:
        """Rollback recovery strategy"""
        try:
            # In a real implementation, this would rollback to a previous state
            # For now, we'll simulate rollback
            
            logger.info(f"Rolling back for failure {failure_event.event_id}")
            await asyncio.sleep(1.0)  # Simulate rollback time
            
            return True
            
        except Exception as e:
            logger.error(f"Rollback failed: {e}")
            return False
    
    async def _restart_recovery(self, failure_event: FailureEvent) -> bool:
        """Restart recovery strategy"""
        try:
            # In a real implementation, this would restart the failed component
            # For now, we'll simulate restart
            
            logger.info(f"Restarting for failure {failure_event.event_id}")
            await asyncio.sleep(3.0)  # Simulate restart time
            
            return True
            
        except Exception as e:
            logger.error(f"Restart failed: {e}")
            return False
    
    async def _replication_recovery(self, failure_event: FailureEvent) -> bool:
        """Replication recovery strategy"""
        try:
            # In a real implementation, this would replicate data to other nodes
            # For now, we'll simulate replication
            
            logger.info(f"Replicating for failure {failure_event.event_id}")
            await asyncio.sleep(1.5)  # Simulate replication time
            
            return True
            
        except Exception as e:
            logger.error(f"Replication failed: {e}")
            return False
    
    async def _degradation_recovery(self, failure_event: FailureEvent) -> bool:
        """Degradation recovery strategy"""
        try:
            # In a real implementation, this would degrade service quality
            # For now, we'll simulate degradation
            
            logger.info(f"Degrading for failure {failure_event.event_id}")
            await asyncio.sleep(0.5)  # Simulate degradation time
            
            return True
            
        except Exception as e:
            logger.error(f"Degradation failed: {e}")
            return False
    
    def _update_avg_recovery_time(self, recovery_time: float):
        """Update average recovery time"""
        current_avg = self._stats['avg_recovery_time']
        recovery_count = self._stats['failures_recovered']
        
        # Calculate new average
        new_avg = ((current_avg * (recovery_count - 1)) + recovery_time) / recovery_count
        self._stats['avg_recovery_time'] = new_avg

