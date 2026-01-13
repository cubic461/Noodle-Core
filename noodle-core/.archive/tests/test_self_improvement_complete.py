#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_self_improvement_complete.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive test script for the self-improvement system.
This script tests all components of the self-improvement system to identify why it's not working.
"""

import os
import sys
import logging
import traceback
from typing import Dict, Any, List

# Add the src directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def setup_logging():
    """Setup logging for the test."""
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('self_improvement_test.log')
        ]
    )
    return logging.getLogger(__name__)

def test_environment_variables():
    """Test environment variables configuration."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Environment Variables ===")
    
    required_vars = [
        'NOODLE_SELF_IMPROVEMENT_ENABLED',
        'NOODLE_ENVIRONMENT',
        'NOODLE_LOG_LEVEL'
    ]
    
    results = {}
    for var in required_vars:
        value = os.environ.get(var, 'NOT_SET')
        results[var] = value
        logger.info(f"{var}: {value}")
    
    # Set default values if not present
    if os.environ.get('NOODLE_SELF_IMPROVEMENT_ENABLED') is None:
        os.environ['NOODLE_SELF_IMPROVEMENT_ENABLED'] = 'true'
        logger.info("Set NOODLE_SELF_IMPROVEMENT_ENABLED=true")
    
    if os.environ.get('NOODLE_ENVIRONMENT') is None:
        os.environ['NOODLE_ENVIRONMENT'] = 'development'
        logger.info("Set NOODLE_ENVIRONMENT=development")
    
    return results

def test_imports():
    """Test importing all self-improvement components."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Imports ===")
    
    components = {
        'self_improvement_manager': 'noodlecore.self_improvement.self_improvement_manager',
        'feedback_collector': 'noodlecore.self_improvement.feedback_collector',
        'adaptive_optimizer': 'noodlecore.self_improvement.adaptive_optimizer',
        'nc_performance_monitor': 'noodlecore.self_improvement.nc_performance_monitor',
        'enhanced_ai_decision_engine': 'noodlecore.self_improvement.enhanced_ai_decision_engine',
        'nc_optimization_engine': 'noodlecore.self_improvement.nc_optimization_engine',
        'nc_ab_testing': 'noodlecore.self_improvement.nc_ab_testing',
        'runtime_upgrade_manager': 'noodlecore.self_improvement.runtime_upgrade.runtime_upgrade_manager'
    }
    
    results = {}
    for name, module_path in components.items():
        try:
            module = __import__(module_path, fromlist=[''])
            results[name] = {'status': 'SUCCESS', 'module': module}
            logger.info(f"âœ“ Successfully imported {name}")
        except Exception as e:
            results[name] = {'status': 'FAILED', 'error': str(e)}
            logger.error(f"âœ— Failed to import {name}: {e}")
            logger.debug(traceback.format_exc())
    
    return results

def test_self_improvement_manager():
    """Test the self-improvement manager initialization and functionality."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Self-Improvement Manager ===")
    
    try:
        from noodlecore.self_improvement.self_improvement_manager import SelfImprovementManager
        
        # Test initialization
        manager = SelfImprovementManager()
        logger.info("âœ“ SelfImprovementManager initialized successfully")
        
        # Test configuration
        config = manager.get_configuration()
        logger.info(f"âœ“ Manager configuration: {config}")
        
        # Test activation
        if hasattr(manager, 'activate'):
            manager.activate()
            logger.info("âœ“ SelfImprovementManager activated")
        else:
            logger.warning("SelfImprovementManager has no activate method")
        
        # Test status
        if hasattr(manager, 'get_status'):
            status = manager.get_status()
            logger.info(f"âœ“ Manager status: {status}")
        else:
            logger.warning("SelfImprovementManager has no get_status method")
        
        # Test components
        if hasattr(manager, 'components'):
            components = manager.components
            logger.info(f"âœ“ Manager components: {list(components.keys()) if components else 'None'}")
        else:
            logger.warning("SelfImprovementManager has no components attribute")
        
        return {'status': 'SUCCESS', 'manager': manager}
        
    except Exception as e:
        logger.error(f"âœ— SelfImprovementManager test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def test_feedback_collector():
    """Test the feedback collector component."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Feedback Collector ===")
    
    try:
        from noodlecore.self_improvement.feedback_collector import FeedbackCollector
        
        # Test initialization
        collector = FeedbackCollector()
        logger.info("âœ“ FeedbackCollector initialized successfully")
        
        # Test methods
        if hasattr(collector, 'collect_feedback'):
            # Try to collect some feedback
            try:
                feedback = collector.collect_feedback()
                logger.info(f"âœ“ Collected feedback: {feedback}")
            except Exception as e:
                logger.warning(f"Feedback collection failed: {e}")
        
        return {'status': 'SUCCESS', 'collector': collector}
        
    except Exception as e:
        logger.error(f"âœ— FeedbackCollector test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def test_adaptive_optimizer():
    """Test the adaptive optimizer component."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Adaptive Optimizer ===")
    
    try:
        from noodlecore.self_improvement.adaptive_optimizer import AdaptiveOptimizer
        
        # Test initialization
        optimizer = AdaptiveOptimizer()
        logger.info("âœ“ AdaptiveOptimizer initialized successfully")
        
        # Test methods
        if hasattr(optimizer, 'optimize'):
            try:
                result = optimizer.optimize()
                logger.info(f"âœ“ Optimization result: {result}")
            except Exception as e:
                logger.warning(f"Optimization failed: {e}")
        
        return {'status': 'SUCCESS', 'optimizer': optimizer}
        
    except Exception as e:
        logger.error(f"âœ— AdaptiveOptimizer test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def test_performance_monitor():
    """Test the performance monitor component."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Performance Monitor ===")
    
    try:
        from noodlecore.self_improvement.nc_performance_monitor import NCPerformanceMonitor
        
        # Test initialization
        monitor = NCPerformanceMonitor()
        logger.info("âœ“ NCPerformanceMonitor initialized successfully")
        
        # Test methods
        if hasattr(monitor, 'get_metrics'):
            try:
                metrics = monitor.get_metrics()
                logger.info(f"âœ“ Performance metrics: {metrics}")
            except Exception as e:
                logger.warning(f"Getting metrics failed: {e}")
        
        return {'status': 'SUCCESS', 'monitor': monitor}
        
    except Exception as e:
        logger.error(f"âœ— NCPerformanceMonitor test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def test_ai_decision_engine():
    """Test the AI decision engine component."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing AI Decision Engine ===")
    
    try:
        from noodlecore.self_improvement.enhanced_ai_decision_engine import EnhancedAIDecisionEngine
        
        # Test initialization
        engine = EnhancedAIDecisionEngine()
        logger.info("âœ“ EnhancedAIDecisionEngine initialized successfully")
        
        # Test methods
        if hasattr(engine, 'make_decision'):
            try:
                decision = engine.make_decision()
                logger.info(f"âœ“ AI decision: {decision}")
            except Exception as e:
                logger.warning(f"Decision making failed: {e}")
        
        return {'status': 'SUCCESS', 'engine': engine}
        
    except Exception as e:
        logger.error(f"âœ— EnhancedAIDecisionEngine test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def test_runtime_upgrade_system():
    """Test the runtime upgrade system."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Runtime Upgrade System ===")
    
    try:
        from noodlecore.self_improvement.runtime_upgrade.runtime_upgrade_manager import RuntimeUpgradeManager
        
        # Test initialization
        upgrade_manager = RuntimeUpgradeManager()
        logger.info("âœ“ RuntimeUpgradeManager initialized successfully")
        
        # Test methods
        if hasattr(upgrade_manager, 'get_status'):
            try:
                status = upgrade_manager.get_status()
                logger.info(f"âœ“ Upgrade system status: {status}")
            except Exception as e:
                logger.warning(f"Getting upgrade status failed: {e}")
        
        return {'status': 'SUCCESS', 'upgrade_manager': upgrade_manager}
        
    except Exception as e:
        logger.error(f"âœ— RuntimeUpgradeManager test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def test_complete_workflow():
    """Test the complete self-improvement workflow."""
    logger = logging.getLogger(__name__)
    logger.info("=== Testing Complete Self-Improvement Workflow ===")
    
    try:
        from noodlecore.self_improvement.self_improvement_manager import SelfImprovementManager
        
        # Initialize the manager
        manager = SelfImprovementManager()
        logger.info("âœ“ SelfImprovementManager initialized")
        
        # Activate if possible
        if hasattr(manager, 'activate'):
            manager.activate()
            logger.info("âœ“ SelfImprovementManager activated")
        
        # Try to run a complete improvement cycle
        if hasattr(manager, 'run_improvement_cycle'):
            try:
                result = manager.run_improvement_cycle()
                logger.info(f"âœ“ Improvement cycle result: {result}")
            except Exception as e:
                logger.warning(f"Improvement cycle failed: {e}")
        else:
            logger.warning("SelfImprovementManager has no run_improvement_cycle method")
        
        # Check overall system health
        if hasattr(manager, 'get_system_health'):
            try:
                health = manager.get_system_health()
                logger.info(f"âœ“ System health: {health}")
            except Exception as e:
                logger.warning(f"Getting system health failed: {e}")
        
        return {'status': 'SUCCESS', 'manager': manager}
        
    except Exception as e:
        logger.error(f"âœ— Complete workflow test failed: {e}")
        logger.debug(traceback.format_exc())
        return {'status': 'FAILED', 'error': str(e)}

def main():
    """Main test function."""
    logger = setup_logging()
    logger.info("Starting comprehensive self-improvement system test")
    
    results = {
        'environment': test_environment_variables(),
        'imports': test_imports(),
        'self_improvement_manager': test_self_improvement_manager(),
        'feedback_collector': test_feedback_collector(),
        'adaptive_optimizer': test_adaptive_optimizer(),
        'performance_monitor': test_performance_monitor(),
        'ai_decision_engine': test_ai_decision_engine(),
        'runtime_upgrade_system': test_runtime_upgrade_system(),
        'complete_workflow': test_complete_workflow()
    }
    
    # Summary
    logger.info("=== TEST SUMMARY ===")
    success_count = 0
    total_count = len(results)
    
    for test_name, result in results.items():
        if isinstance(result, dict) and result.get('status') == 'SUCCESS':
            success_count += 1
            logger.info(f"âœ“ {test_name}: PASSED")
        else:
            logger.error(f"âœ— {test_name}: FAILED")
    
    logger.info(f"Overall Result: {success_count}/{total_count} tests passed")
    
    if success_count == total_count:
        logger.info("ðŸŽ‰ All tests passed! Self-improvement system should be working.")
    else:
        logger.warning("âš ï¸  Some tests failed. Self-improvement system may have issues.")
    
    return results

if __name__ == "__main__":
    main()

