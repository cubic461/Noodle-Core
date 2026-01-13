"""
Noodlenet::Config - config.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Configuratie voor NoodleNet netwerkcomponenten
"""

import os
import yaml
from typing import Dict, Any, Optional
from dataclasses import dataclass, field


@dataclass
class NoodleNetConfig:
    """Configuratieklasse voor NoodleNet componenten"""
    
    # Basis netwerk configuratie
    discovery_port: int = 4040
    discovery_multicast_addr: str = "224.1.1.1"
    discovery_multicast_port: int = 10000
    discovery_ttl: int = 1
    
    # Heartbeat configuratie
    heartbeat_interval: float = 5.0  # seconden
    heartbeat_timeout: float = 15.0  # seconden
    
    # Buffer sizes
    send_buffer_size: int = 64 * 1024  # 64KB
    recv_buffer_size: int = 64 * 1024  # 64KB
    
    # Timeouts
    connect_timeout: float = 2.0
    send_timeout: float = 5.0
    recv_timeout: float = 5.0
    
    # Retries
    max_retries: int = 3
    retry_delay: float = 1.0
    
    # Mesh configuratie
    mesh_update_interval: float = 10.0
    mesh_max_latency: float = 50.0  # ms
    mesh_min_quality: float = 0.7
    
    # Security
    enable_encryption: bool = False
    encryption_key: Optional[str] = None
    
    # Logging
    log_level: str = "INFO"
    log_file: Optional[str] = None
    
    # Resource limits
    max_connections: int = 100
    max_message_size: int = 10 * 1024 * 1024  # 10MB
    
    @classmethod
    def from_file(cls, config_path: str) -> "NoodleNetConfig":
        """
        Laad configuratie uit YAML bestand
        
        Args:
            config_path: Pad naar configuratiebestand
            
        Returns:
            NoodleNetConfig instance
        """
        if not os.path.exists(config_path):
            raise FileNotFoundError(f"Config file not found: {config_path}")
            
        with open(config_path, 'r') as f:
            config_data = yaml.safe_load(f)
            
        return cls(**config_data)
    
    @classmethod
    def from_env(cls) -> "NoodleNetConfig":
        """
        Laad configuratie uit environment variabelen
        
        Returns:
            NoodleNetConfig instance
        """
        config_dict = {}
        
        # Map environment variabelen naar config attributen
        env_mapping = {
            'NOODLENET_DISCOVERY_PORT': 'discovery_port',
            'NOODLENET_DISCOVERY_MC_ADDR': 'discovery_multicast_addr',
            'NOODLENET_DISCOVERY_MC_PORT': 'discovery_multicast_port',
            'NOODLENET_HEARTBEAT_INTERVAL': 'heartbeat_interval',
            'NOODLENET_HEARTBEAT_TIMEOUT': 'heartbeat_timeout',
            'NOODLENET_SEND_BUFFER_SIZE': 'send_buffer_size',
            'NOODLENET_RECV_BUFFER_SIZE': 'recv_buffer_size',
            'NOODLENET_CONNECT_TIMEOUT': 'connect_timeout',
            'NOODLENET_SEND_TIMEOUT': 'send_timeout',
            'NOODLENET_RECV_TIMEOUT': 'recv_timeout',
            'NOODLENET_MAX_RETRIES': 'max_retries',
            'NOODLENET_RETRY_DELAY': 'retry_delay',
            'NOODLENET_MESH_UPDATE_INTERVAL': 'mesh_update_interval',
            'NOODLENET_MESH_MAX_LATENCY': 'mesh_max_latency',
            'NOODLENET_MESH_MIN_QUALITY': 'mesh_min_quality',
            'NOODLENET_ENABLE_ENCRYPTION': 'enable_encryption',
            'NOODLENET_ENCRYPTION_KEY': 'encryption_key',
            'NOODLENET_LOG_LEVEL': 'log_level',
            'NOODLENET_LOG_FILE': 'log_file',
            'NOODLENET_MAX_CONNECTIONS': 'max_connections',
            'NOODLENET_MAX_MESSAGE_SIZE': 'max_message_size',
        }
        
        for env_var, config_attr in env_mapping.items():
            value = os.getenv(env_var)
            if value is not None:
                # Converteer waarde naar geschikt type
                if config_attr in ['discovery_port', 'discovery_multicast_port', 'send_buffer_size', 
                                 'recv_buffer_size', 'max_retries', 'max_connections', 'max_message_size']:
                    config_dict[config_attr] = int(value)
                elif config_attr in ['heartbeat_interval', 'heartbeat_timeout', 'connect_timeout',
                                   'send_timeout', 'recv_timeout', 'retry_delay', 'mesh_update_interval',
                                   'mesh_max_latency']:
                    config_dict[config_attr] = float(value)
                elif config_attr in ['enable_encryption']:
                    config_dict[config_attr] = value.lower() in ('true', '1', 'yes', 'on')
                else:
                    config_dict[config_attr] = value
        
        return cls(**config_dict)
    
    def to_file(self, config_path: str):
        """
        Sla configuratie op naar YAML bestand
        
        Args:
            config_path: Pad naar configuratiebestand
        """
        config_dict = {
            'discovery_port': self.discovery_port,
            'discovery_multicast_addr': self.discovery_multicast_addr,
            'discovery_multicast_port': self.discovery_multicast_port,
            'discovery_ttl': self.discovery_ttl,
            'heartbeat_interval': self.heartbeat_interval,
            'heartbeat_timeout': self.heartbeat_timeout,
            'send_buffer_size': self.send_buffer_size,
            'recv_buffer_size': self.recv_buffer_size,
            'connect_timeout': self.connect_timeout,
            'send_timeout': self.send_timeout,
            'recv_timeout': self.recv_timeout,
            'max_retries': self.max_retries,
            'retry_delay': self.retry_delay,
            'mesh_update_interval': self.mesh_update_interval,
            'mesh_max_latency': self.mesh_max_latency,
            'mesh_min_quality': self.mesh_min_quality,
            'enable_encryption': self.enable_encryption,
            'encryption_key': self.encryption_key,
            'log_level': self.log_level,
            'log_file': self.log_file,
            'max_connections': self.max_connections,
            'max_message_size': self.max_message_size,
        }
        
        with open(config_path, 'w') as f:
            yaml.dump(config_dict, f, default_flow_style=False)
    
    def get_default_config_path(self) -> str:
        """
        Krijg het standaard configuratiepad
        
        Returns:
            Pad naar standaard configuratiebestand
        """
        home_dir = os.path.expanduser("~")
        config_dir = os.path.join(home_dir, ".noodlenet")
        os.makedirs(config_dir, exist_ok=True)
        return os.path.join(config_dir, "config.yaml")
    
    def validate(self) -> Dict[str, Any]:
        """
        Valideer configuratiewaarden
        
        Returns:
            Dictionary met validatieresultaten
        """
        errors = []
        warnings = []
        
        # Poorten moeten binnen geldige range zijn
        if not (1 <= self.discovery_port <= 65535):
            errors.append("discovery_port must be between 1 and 65535")
        
        if not (1 <= self.discovery_multicast_port <= 65535):
            errors.append("discovery_multicast_port must be between 1 and 65535")
        
        # Buffer sizes moeten redelijk zijn
        if self.send_buffer_size < 1024:
            warnings.append("send_buffer_size is very small, may cause performance issues")
        
        if self.recv_buffer_size < 1024:
            warnings.append("recv_buffer_size is very small, may cause performance issues")
        
        # Timeouts moeten positief zijn
        if self.heartbeat_interval <= 0:
            errors.append("heartbeat_interval must be positive")
        
        if self.heartbeat_timeout <= 0:
            errors.append("heartbeat_timeout must be positive")
        
        # Max connections moet redelijk zijn
        if self.max_connections <= 0:
            errors.append("max_connections must be positive")
        
        if self.max_connections > 10000:
            warnings.append("max_connections is very large, may cause resource issues")
        
        return {
            'valid': len(errors) == 0,
            'errors': errors,
            'warnings': warnings
        }


# Standaard configuratie instance
default_config = NoodleNetConfig()


