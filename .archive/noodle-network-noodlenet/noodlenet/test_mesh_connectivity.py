"""
Test Suite::Noodlenet - test_mesh_connectivity.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive test suite for NoodleNet mesh network connectivity validation
"""

import asyncio
import logging
import time
import sys
import os
from typing import Dict, List, Any, Optional
from dataclasses import asdict

# Add the current directory to the path to import NoodleNet modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import modules directly without relative imports
import link
import discovery
import identity
import mesh
import config

# Get the classes from the modules
NoodleLink = link.NoodleLink
Message = link.Message
NoodleDiscovery = discovery.NoodleDiscovery
DiscoveryMessage = discovery.DiscoveryMessage
NodeIdentity = identity.NodeIdentity
NoodleIdentityManager = identity.NoodleIdentityManager
NoodleMesh = mesh.NoodleMesh
NodeMetrics = mesh.NodeMetrics
MeshTopology = mesh.MeshTopology
NoodleNetConfig = config.NoodleNetConfig

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class NoodleNetConnectivityTester:
    """Comprehensive tester for NoodleNet mesh network connectivity"""
    
    def __init__(self):
        self.config = NoodleNetConfig()
        self.test_results = {
            'component_imports': False,
            'node_discovery': False,
            'message_communication': False,
            'mesh_topology': False,
            'network_connectivity': False,
            'issues_found': [],
            'recommendations': []
        }
        
    async def test_component_imports(self) -> bool:
        """Test that all NoodleNet components can be imported successfully"""
        logger.info("Testing component imports...")
        
        try:
            # Test imports
            from link import NoodleLink, Message
            from discovery import NoodleDiscovery
            from identity import NodeIdentity, NoodleIdentityManager
            from mesh import NoodleMesh
            from config import NoodleNetConfig
            
            logger.info("âœ“ All components imported successfully")
            self.test_results['component_imports'] = True
            return True
            
        except ImportError as e:
            error_msg = f"Import error: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
        except Exception as e:
            error_msg = f"Unexpected error during import: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    async def test_node_discovery(self) -> bool:
        """Test node discovery functionality"""
        logger.info("Testing node discovery functionality...")
        
        try:
            # Create components
            config = NoodleNetConfig()
            identity_manager = NoodleIdentityManager(config)
            link = NoodleLink(config)
            discovery = NoodleDiscovery(link, identity_manager, config)
            
            # Initialize identity manager
            await identity_manager.initialize()
            
            # Create local identity
            local_identity = identity_manager.create_local_identity({
                'discovery': True,
                'communication': True,
                'mesh': True
            })
            
            # Start discovery
            await discovery.start()
            
            # Wait a moment for discovery to establish
            await asyncio.sleep(2)
            
            # Check if discovery is running
            if not discovery.is_running():
                error_msg = "Discovery system failed to start"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            # Test hello broadcast
            await discovery.broadcast_hello()
            await asyncio.sleep(1)
            
            # Check discovered nodes
            nodes = discovery.get_discovered_nodes()
            node_count = discovery.get_node_count()
            
            logger.info(f"âœ“ Discovery running, found {node_count} nodes")
            logger.info(f"âœ“ Local identity: {local_identity}")
            
            # Stop discovery
            await discovery.stop()
            
            self.test_results['node_discovery'] = True
            return True
            
        except Exception as e:
            error_msg = f"Node discovery test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    async def test_message_communication(self) -> bool:
        """Test message sending and receiving between nodes"""
        logger.info("Testing message communication...")
        
        try:
            # Create two nodes for communication testing
            config1 = NoodleNetConfig()
            config2 = NoodleNetConfig()
            
            # Node 1
            identity_manager1 = NoodleIdentityManager(config1)
            link1 = NoodleLink(config1)
            discovery1 = NoodleDiscovery(link1, identity_manager1, config1)
            
            # Node 2
            identity_manager2 = NoodleIdentityManager(config2)
            link2 = NoodleLink(config2)
            discovery2 = NoodleDiscovery(link2, identity_manager2, config2)
            
            # Initialize both nodes
            await identity_manager1.initialize()
            await identity_manager2.initialize()
            
            # Create identities
            identity1 = identity_manager1.create_local_identity({
                'discovery': True,
                'communication': True
            })
            identity2 = identity_manager2.create_local_identity({
                'discovery': True,
                'communication': True
            })
            
            # Start components
            await link1.start()
            await link2.start()
            await discovery1.start()
            await discovery2.start()
            
            # Wait for discovery
            await asyncio.sleep(3)
            
            # Test message sending from node 1 to node 2
            test_message = Message(
                sender_id=identity1.node_id,
                recipient_id=identity2.node_id,
                message_type="test_message",
                payload={"content": "Hello from node 1!", "timestamp": time.time()}
            )
            
            success = await link1.send(identity2.node_id, test_message)
            
            if not success:
                error_msg = "Failed to send message from node 1 to node 2"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            # Test broadcast message
            broadcast_message = Message(
                sender_id=identity1.node_id,
                recipient_id=None,
                message_type="broadcast_test",
                payload={"content": "Broadcast message", "timestamp": time.time()}
            )
            
            success = await link1.broadcast(broadcast_message)
            
            if not success:
                error_msg = "Failed to broadcast message"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            # Get statistics
            stats1 = link1.get_stats()
            stats2 = link2.get_stats()
            
            logger.info(f"âœ“ Message communication successful")
            logger.info(f"âœ“ Node 1 stats: {stats1}")
            logger.info(f"âœ“ Node 2 stats: {stats2}")
            
            # Stop components
            await discovery1.stop()
            await discovery2.stop()
            await link1.stop()
            await link2.stop()
            
            self.test_results['message_communication'] = True
            return True
            
        except Exception as e:
            error_msg = f"Message communication test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    async def test_mesh_topology_formation(self) -> bool:
        """Test mesh topology formation and routing"""
        logger.info("Testing mesh topology formation...")
        
        try:
            # Create mesh components
            config = NoodleNetConfig()
            identity_manager = NoodleIdentityManager(config)
            link = NoodleLink(config)
            mesh = NoodleMesh(link, identity_manager, config)
            
            # Initialize
            await identity_manager.initialize()
            
            # Create local identity
            local_identity = identity_manager.create_local_identity({
                'discovery': True,
                'communication': True,
                'mesh': True
            })
            
            # Start mesh
            await mesh.start()
            
            # Wait for mesh to establish
            await asyncio.sleep(2)
            
            # Check if mesh is running
            if not mesh.is_running():
                error_msg = "Mesh system failed to start"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            # Add some test nodes to the mesh
            test_nodes = [
                ("node1", "host1"),
                ("node2", "host2"),
                ("node3", "host3")
            ]
            
            for node_id, hostname in test_nodes:
                mesh.add_node(node_id, hostname)
            
            # Add edges between nodes
            mesh.add_edge("node1", "node2", 10.0, 100.0, 0.99)
            mesh.add_edge("node2", "node3", 15.0, 80.0, 0.98)
            mesh.add_edge("node1", "node3", 25.0, 60.0, 0.95)
            
            # Test route finding
            route = mesh.find_route("node1", "node3")
            
            if not route:
                error_msg = "Failed to find route between nodes"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            logger.info(f"âœ“ Found route: {' -> '.join(route)}")
            
            # Test best node selection
            best_node = mesh.get_best_node("ai_inference", {"gpu": True})
            
            logger.info(f"âœ“ Mesh topology formed with {mesh.get_node_count()} nodes")
            logger.info(f"âœ“ Best node for AI inference: {best_node}")
            
            # Get topology information
            topology = mesh.get_topology()
            logger.info(f"âœ“ Topology: {topology}")
            
            # Stop mesh
            await mesh.stop()
            
            self.test_results['mesh_topology'] = True
            return True
            
        except Exception as e:
            error_msg = f"Mesh topology test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    async def test_network_connectivity(self) -> bool:
        """Test overall network connectivity and dependency issues"""
        logger.info("Testing network connectivity...")
        
        try:
            # Test configuration validation
            config = NoodleNetConfig()
            validation = config.validate()
            
            if not validation['valid']:
                error_msg = f"Configuration validation failed: {validation['errors']}"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            if validation['warnings']:
                logger.warning(f"Configuration warnings: {validation['warnings']}")
            
            # Test component initialization sequence
            components = []
            
            try:
                # Initialize in correct order
                identity_manager = NoodleIdentityManager(config)
                await identity_manager.initialize()
                components.append("identity_manager")
                
                link = NoodleLink(config)
                components.append("link")
                
                discovery = NoodleDiscovery(link, identity_manager, config)
                components.append("discovery")
                
                mesh = NoodleMesh(link, identity_manager, config)
                components.append("mesh")
                
                logger.info(f"âœ“ All components initialized: {', '.join(components)}")
                
            except Exception as e:
                error_msg = f"Component initialization failed: {e}"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            # Test dependency injection
            try:
                # Create local identity
                local_identity = identity_manager.create_local_identity({
                    'discovery': True,
                    'communication': True,
                    'mesh': True
                })
                
                # Link identity to link component
                link.set_local_identity(local_identity)
                
                logger.info(f"âœ“ Dependency injection successful")
                
            except Exception as e:
                error_msg = f"Dependency injection failed: {e}"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            # Test concurrent operations
            try:
                async def concurrent_task(task_id: int):
                    """Concurrent task for testing"""
                    await asyncio.sleep(0.1)
                    return f"Task {task_id} completed"
                
                # Run multiple concurrent tasks
                tasks = [concurrent_task(i) for i in range(5)]
                results = await asyncio.gather(*tasks)
                
                logger.info(f"âœ“ Concurrent operations successful: {len(results)} tasks completed")
                
            except Exception as e:
                error_msg = f"Concurrent operations failed: {e}"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            self.test_results['network_connectivity'] = True
            return True
            
        except Exception as e:
            error_msg = f"Network connectivity test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    async def run_all_tests(self) -> Dict[str, Any]:
        """Run all connectivity tests and return results"""
        logger.info("Starting NoodleNet mesh network connectivity tests...")
        
        # Run all tests
        tests = [
            ("Component Imports", self.test_component_imports),
            ("Node Discovery", self.test_node_discovery),
            ("Message Communication", self.test_message_communication),
            ("Mesh Topology", self.test_mesh_topology_formation),
            ("Network Connectivity", self.test_network_connectivity)
        ]
        
        for test_name, test_func in tests:
            logger.info(f"\n{'='*50}")
            logger.info(f"Running: {test_name}")
            logger.info(f"{'='*50}")
            
            try:
                success = await test_func()
                logger.info(f"{'âœ“' if success else 'âœ—'} {test_name}: {'PASSED' if success else 'FAILED'}")
            except Exception as e:
                logger.error(f"âœ— {test_name}: ERROR - {e}")
                self.test_results['issues_found'].append(f"{test_name} error: {e}")
        
        # Generate recommendations
        self._generate_recommendations()
        
        # Calculate overall score
        passed_tests = sum(1 for result in self.test_results.values() if result is True)
        total_tests = len([k for k in self.test_results.keys() if k != 'issues_found' and k != 'recommendations'])
        
        self.test_results['overall_score'] = f"{passed_tests}/{total_tests}"
        self.test_results['success_rate'] = (passed_tests / total_tests) * 100 if total_tests > 0 else 0
        
        logger.info(f"\n{'='*50}")
        logger.info("TEST SUMMARY")
        logger.info(f"{'='*50}")
        logger.info(f"Overall Score: {self.test_results['overall_score']}")
        logger.info(f"Success Rate: {self.test_results['success_rate']:.1f}%")
        
        if self.test_results['issues_found']:
            logger.info(f"\nIssues Found ({len(self.test_results['issues_found'])}):")
            for issue in self.test_results['issues_found']:
                logger.info(f"  - {issue}")
        
        if self.test_results['recommendations']:
            logger.info(f"\nRecommendations ({len(self.test_results['recommendations'])}):")
            for rec in self.test_results['recommendations']:
                logger.info(f"  - {rec}")
        
        return self.test_results
    
    def _generate_recommendations(self):
        """Generate recommendations based on test results"""
        recommendations = []
        
        if not self.test_results['component_imports']:
            recommendations.append("Check Python path and ensure all required dependencies are installed")
        
        if not self.test_results['node_discovery']:
            recommendations.append("Verify network configuration and multicast settings")
            recommendations.append("Check firewall settings that might block multicast traffic")
        
        if not self.test_results['message_communication']:
            recommendations.append("Test network connectivity between nodes")
            recommendations.append("Verify port availability and configuration")
        
        if not self.test_results['mesh_topology']:
            recommendations.append("Review mesh routing algorithm implementation")
            recommendations.append("Check node metrics collection and quality scoring")
        
        if not self.test_results['network_connectivity']:
            recommendations.append("Validate configuration settings")
            recommendations.append("Test dependency injection and component lifecycle")
        
        # General recommendations
        recommendations.append("Implement proper error handling and logging")
        recommendations.append("Add comprehensive unit tests for edge cases")
        recommendations.append("Consider implementing circuit breakers for network resilience")
        
        self.test_results['recommendations'] = recommendations


async def main():
    """Main test execution function"""
    tester = NoodleNetConnectivityTester()
    results = await tester.run_all_tests()
    
    # Return exit code based on results
    exit_code = 0 if all(results[key] for key in results.keys() if key not in ['issues_found', 'recommendations', 'overall_score', 'success_rate']) else 1
    
    return exit_code


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)

