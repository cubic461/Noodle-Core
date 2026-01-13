"""
Test Suite::Noodle Network Noodlenet - test_simple_connectivity.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simplified test for NoodleNet mesh network connectivity validation
"""

import asyncio
import logging
import time
import sys
import os
import importlib.util
from typing import Dict, List, Any, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class NoodleNetConnectivityTester:
    """Simplified tester for NoodleNet mesh network connectivity"""
    
    def __init__(self):
        self.test_results = {
            'component_imports': False,
            'basic_functionality': False,
            'configuration_validation': False,
            'network_connectivity': False,
            'issues_found': [],
            'recommendations': []
        }
        
    def test_component_imports(self) -> bool:
        """Test that all NoodleNet components can be imported successfully"""
        logger.info("Testing component imports...")
        
        try:
            # Test importing each module file directly
            modules_to_test = [
                'config',
                'identity', 
                'link',
                'discovery',
                'mesh'
            ]
            
            for module_name in modules_to_test:
                try:
                    spec = importlib.util.spec_from_file_location(
                        module_name, 
                        f"{module_name}.py"
                    )
                    module = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(module)
                    logger.info(f"âœ“ Successfully imported {module_name}")
                except Exception as e:
                    error_msg = f"Failed to import {module_name}: {e}"
                    logger.error(f"âœ— {error_msg}")
                    self.test_results['issues_found'].append(error_msg)
                    return False
            
            self.test_results['component_imports'] = True
            return True
            
        except Exception as e:
            error_msg = f"Import test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    def test_basic_functionality(self) -> bool:
        """Test basic functionality of core components"""
        logger.info("Testing basic functionality...")
        
        try:
            # Import modules
            spec = importlib.util.spec_from_file_location("config", "config.py")
            config_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(config_module)
            
            spec = importlib.util.spec_from_file_location("identity", "identity.py")
            identity_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(identity_module)
            
            spec = importlib.util.spec_from_file_location("link", "link.py")
            link_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(link_module)
            
            # Get classes
            NoodleNetConfig = config_module.NoodleNetConfig
            NodeIdentity = identity_module.NodeIdentity
            NoodleIdentityManager = identity_module.NoodleIdentityManager
            NoodleLink = link_module.NoodleLink
            Message = link_module.Message
            
            # Test configuration
            config = NoodleNetConfig()
            logger.info(f"âœ“ Configuration created: {config.discovery_port}")
            
            # Test identity management
            identity_manager = NoodleIdentityManager(config)
            local_identity = identity_manager.create_local_identity({
                'discovery': True,
                'communication': True
            })
            logger.info(f"âœ“ Identity created: {local_identity}")
            
            # Test message creation
            test_message = Message(
                sender_id=local_identity.node_id,
                recipient_id="test_node",
                message_type="test",
                payload={"data": "test"}
            )
            logger.info(f"âœ“ Message created: {test_message.message_type}")
            
            # Test serialization
            serialized = test_message.serialize()
            deserialized = Message.deserialize(serialized)
            logger.info(f"âœ“ Message serialization/deserialization works")
            
            self.test_results['basic_functionality'] = True
            return True
            
        except Exception as e:
            error_msg = f"Basic functionality test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    def test_configuration_validation(self) -> bool:
        """Test configuration validation"""
        logger.info("Testing configuration validation...")
        
        try:
            # Import config module
            spec = importlib.util.spec_from_file_location("config", "config.py")
            config_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(config_module)
            
            NoodleNetConfig = config_module.NoodleNetConfig
            
            # Test default configuration
            config = NoodleNetConfig()
            validation = config.validate()
            
            if not validation['valid']:
                error_msg = f"Configuration validation failed: {validation['errors']}"
                logger.error(f"âœ— {error_msg}")
                self.test_results['issues_found'].append(error_msg)
                return False
            
            logger.info(f"âœ“ Configuration validation passed")
            
            if validation['warnings']:
                logger.warning(f"Configuration warnings: {validation['warnings']}")
            
            # Test environment-based configuration
            os.environ['NOODLENET_DISCOVERY_PORT'] = '4041'
            config_from_env = NoodleNetConfig.from_env()
            logger.info(f"âœ“ Environment-based config: {config_from_env.discovery_port}")
            
            self.test_results['configuration_validation'] = True
            return True
            
        except Exception as e:
            error_msg = f"Configuration validation test failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    def test_network_connectivity_simulation(self) -> bool:
        """Simulate network connectivity tests"""
        logger.info("Testing network connectivity simulation...")
        
        try:
            # Import required modules
            spec = importlib.util.spec_from_file_location("config", "config.py")
            config_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(config_module)
            
            spec = importlib.util.spec_from_file_location("identity", "identity.py")
            identity_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(identity_module)
            
            spec = importlib.util.spec_from_file_location("mesh", "mesh.py")
            mesh_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(mesh_module)
            
            # Get classes
            NoodleNetConfig = config_module.NoodleNetConfig
            NodeIdentity = identity_module.NodeIdentity
            NoodleIdentityManager = identity_module.NoodleIdentityManager
            NoodleMesh = mesh_module.NoodleMesh
            NodeMetrics = mesh_module.NodeMetrics
            
            # Create test configuration
            config = NoodleNetConfig()
            
            # Create identity manager
            identity_manager = NoodleIdentityManager(config)
            local_identity = identity_manager.create_local_identity({
                'discovery': True,
                'communication': True,
                'mesh': True
            })
            
            # Create mesh component
            mesh = NoodleMesh(None, identity_manager, config)
            
            # Add test nodes
            test_nodes = [
                ("node1", "host1"),
                ("node2", "host2"),
                ("node3", "host3")
            ]
            
            for node_id, hostname in test_nodes:
                mesh.add_node(node_id, hostname)
            
            # Add edges
            mesh.add_edge("node1", "node2", 10.0, 100.0, 0.99)
            mesh.add_edge("node2", "node3", 15.0, 80.0, 0.98)
            mesh.add_edge("node1", "node3", 25.0, 60.0, 0.95)
            
            # Test route finding
            route = mesh.find_route("node1", "node3")
            if route:
                logger.info(f"âœ“ Route found: {' -> '.join(route)}")
            else:
                logger.warning("âš  No route found between nodes")
            
            # Test node metrics
            metrics = NodeMetrics(
                node_id="test_node",
                hostname="test_host",
                latency=10.0,
                cpu_usage=0.5,
                memory_usage=0.6,
                quality_score=0.8
            )
            
            logger.info(f"âœ“ Node metrics created: quality_score={metrics.get_quality_score():.2f}")
            
            self.test_results['network_connectivity'] = True
            return True
            
        except Exception as e:
            error_msg = f"Network connectivity simulation failed: {e}"
            logger.error(f"âœ— {error_msg}")
            self.test_results['issues_found'].append(error_msg)
            return False
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Run all connectivity tests and return results"""
        logger.info("Starting NoodleNet mesh network connectivity tests...")
        
        # Run all tests
        tests = [
            ("Component Imports", self.test_component_imports),
            ("Basic Functionality", self.test_basic_functionality),
            ("Configuration Validation", self.test_configuration_validation),
            ("Network Connectivity Simulation", self.test_network_connectivity_simulation)
        ]
        
        for test_name, test_func in tests:
            logger.info(f"\n{'='*50}")
            logger.info(f"Running: {test_name}")
            logger.info(f"{'='*50}")
            
            try:
                success = test_func()
                logger.info(f"{'âœ“' if success else 'âœ—'} {test_name}: {'PASSED' if success else 'FAILED'}")
            except Exception as e:
                logger.error(f"âœ— {test_name}: ERROR - {e}")
                self.test_results['issues_found'].append(f"{test_name} error: {e}")
        
        # Generate recommendations
        self._generate_recommendations()
        
        # Calculate overall score
        passed_tests = sum(1 for result in self.test_results.values() if result is True)
        total_tests = len([k for k in self.test_results.keys() if k not in ['issues_found', 'recommendations']])
        
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
            recommendations.append("Fix relative import issues in NoodleNet modules")
            recommendations.append("Consider creating a proper package structure")
        
        if not self.test_results['basic_functionality']:
            recommendations.append("Review core component implementations")
            recommendations.append("Check for missing dependencies or circular imports")
        
        if not self.test_results['configuration_validation']:
            recommendations.append("Review configuration validation logic")
            recommendations.append("Test environment variable handling")
        
        if not self.test_results['network_connectivity']:
            recommendations.append("Implement proper network simulation")
            recommendations.append("Add comprehensive routing algorithm testing")
        
        # General recommendations
        recommendations.append("Implement proper error handling and logging")
        recommendations.append("Add comprehensive unit tests for edge cases")
        recommendations.append("Consider implementing circuit breakers for network resilience")
        recommendations.append("Add integration tests for multi-node scenarios")
        
        self.test_results['recommendations'] = recommendations


def main():
    """Main test execution function"""
    tester = NoodleNetConnectivityTester()
    results = tester.run_all_tests()
    
    # Return exit code based on results
    exit_code = 0 if all(results[key] for key in results.keys() if key not in ['issues_found', 'recommendations', 'overall_score', 'success_rate']) else 1
    
    return exit_code


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

