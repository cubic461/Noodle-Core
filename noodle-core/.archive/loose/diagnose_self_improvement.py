#!/usr/bin/env python3
"""
Noodle Core::Diagnose Self Improvement - diagnose_self_improvement.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Diagnostic script to identify why self-improvement system is not working

This script will:
1. Check current environment variables
2. Test self-improvement manager initialization
3. Check each component's activation status
4. Identify specific error messages or issues
5. Provide recommendations

Usage:
    python diagnose_self_improvement.py [--verbose] [--fix-issues]

Options:
    --verbose    Show detailed diagnostic output
    --fix-issues  Attempt to fix identified issues automatically

"""

import os
import sys
import logging
import importlib.util
from typing import Dict, List, Optional, Any

# Add noodle-core to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'noodle-core', 'src'))

def setup_logging():
    """Setup logging configuration."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

def check_environment_variables() -> Dict[str, Any]:
    """Check self-improvement related environment variables."""
    print("\n=== Environment Variables Check ===")
    
    # Critical variables for self-improvement system
    critical_vars = {
        'NOODLE_SELF_IMPROVEMENT': 'Self-improvement system enabled',
        'NOODLE_AUTO_ACTIVATION': 'Auto-activation of self-improvement',
        'NOODLE_ADAPTIVE_OPTIMIZATION': 'Adaptive optimization enabled',
        'NOODLE_DEBUG': 'Debug mode for detailed logging'
    }
    
    # Supporting variables
    supporting_vars = {
        'NOODLE_FEEDBACK_ENABLED': 'Feedback collection enabled',
        'NOODLE_FEEDBACK_STORAGE': 'Feedback storage file',
        'NOODLE_FEEDBACK_RETENTION': 'Feedback retention count',
        'NOODLE_AUTO_LEARNING': 'Auto-learning enabled',
        'NOODLE_RUNTIME_UPGRADE_ENABLED': 'Runtime upgrade system enabled',
        'NOODLE_RUNTIME_UPGRADE_INTEGRATION': 'Runtime upgrade integration enabled',
        'NOODLE_AI_UPGRADE_DECISION_THRESHOLD': 'AI upgrade decision threshold',
        'NOODLE_AI_ROLLBACK_THRESHOLD': 'AI rollback threshold',
        'NOODLE_AI_MAX_UPGRADE_SUGGESTIONS': 'Max AI upgrade suggestions',
        'NOODLE_AI_UPGRADE_CONFIDENCE_BOOST': 'AI upgrade confidence boost',
        'NOODLE_RUNTIME_UPGRADE_ENABLED': 'Runtime upgrade system enabled',
        'NOODLE_HOT_SWAP_ENABLED': 'Hot swap enabled',
        'NOODLE_UPGRADE_TIMEOUT': 'Upgrade timeout',
        'NOODLE_ROLLBACK_ENABLED': 'Rollback enabled',
        'NOODLE_UPGRADE_VALIDATION_LEVEL': 'Upgrade validation level',
        'NOODLE_GRADUAL_ROLLOUT_PERCENTAGE': 'Gradual rollout percentage',
        'NOODLE_MAX_CONCURRENT_UPGRADES': 'Max concurrent upgrades',
        'NOODLE_ROLLBACK_RETENTION_DAYS': 'Rollback retention days',
        'NOODLE_METADATA_RETENTION_DAYS': 'Metadata retention days'
    }
    
    all_vars = {**critical_vars, **supporting_vars}
    
    issues = []
    
    for var_name, description in all_vars.items():
        value = os.environ.get(var_name, 'NOT_SET')
        status = "[OK] SET" if value == "1" else "[ERROR] NOT SET"
        print(f"  {var_name}: {value} - {description}")
        
        if value == "NOT_SET":
            issues.append(f"Critical variable {var_name} is not set")
    
    # Check for AI configuration
    ai_vars = {
        'NOODLE_AI_PROVIDER': 'AI provider',
        'NOODLE_AI_MODEL': 'AI model',
        'NOODLE_AI_API_KEY': 'AI API key',
    }
    
    for var_name, description in ai_vars.items():
        value = os.environ.get(var_name)
        if value:
            print(f"  [OK] {var_name}: {value}")
        else:
            print(f"  [ERROR] {var_name}: NOT SET")
    
    return {
        'environment_vars': all_vars,
        'issues': issues
    }

def test_self_improvement_manager() -> Dict[str, Any]:
    """Test self-improvement manager initialization and activation."""
    print("\n=== Self-Improvement Manager Test ===")
    
    try:
        from noodlecore.self_improvement.self_improvement_manager import get_self_improvement_manager
        
        manager = get_self_improvement_manager()
        
        # Test activation
        print("Testing self-improvement manager activation...")
        activation_result = manager.activate()
        
        if activation_result:
            print(" [OK] Self-improvement manager activated successfully")
            return {'status': 'success', 'message': 'Self-improvement manager activated'}
        else:
            print(" [ERROR] Self-improvement manager activation failed")
            return {'status': 'error', 'message': 'Self-improvement manager activation failed'}
            
    except ImportError as e:
        print(f" [ERROR] Import error: {str(e)}")
        return {'status': 'error', 'message': f'Import error: {str(e)}'}
    except Exception as e:
        print(f" [ERROR] Unexpected error: {str(e)}")
        return {'status': 'error', 'message': f'Unexpected error: {str(e)}'}

def test_feedback_collector() -> Dict[str, Any]:
    """Test feedback collector functionality."""
    print("\n=== Feedback Collector Test ===")
    
    try:
        from noodlecore.self_improvement.feedback_collector import get_feedback_collector
        
        collector = get_feedback_collector()
        
        # Test activation
        print("Testing feedback collector activation...")
        activation_result = collector.activate()
        
        if activation_result:
            print(" [OK] Feedback collector activated successfully")
            return {'status': 'success', 'message': 'Feedback collector activated'}
        else:
            print(" [ERROR] Feedback collector activation failed")
            return {'status': 'error', 'message': 'Feedback collector activation failed'}
            
    except ImportError as e:
        print(f" [ERROR] Import error: {str(e)}")
        return {'status': 'error', 'message': f'Import error: {str(e)}'}
    except Exception as e:
        print(f" [ERROR] Unexpected error: {str(e)}")
        return {'status': 'error', 'message': f'Unexpected error: {str(e)}'}

def test_adaptive_optimizer() -> Dict[str, Any]:
    """Test adaptive optimizer functionality."""
    print("\n=== Adaptive Optimizer Test ===")
    
    try:
        from noodlecore.self_improvement.adaptive_optimizer import get_adaptive_optimizer
        
        optimizer = get_adaptive_optimizer()
        
        # Test activation
        print("Testing adaptive optimizer activation...")
        activation_result = optimizer.activate()
        
        if activation_result:
            print(" [OK] Adaptive optimizer activated successfully")
            return {'status': 'success', 'message': 'Adaptive optimizer activated'}
        else:
            print(" [ERROR] Adaptive optimizer activation failed")
            return {'status': 'error', 'message': 'Adaptive optimizer activation failed'}
            
    except ImportError as e:
        print(f" [ERROR] Import error: {str(e)}")
        return {'status': 'error', 'message': f'Import error: {str(e)}'}
    except Exception as e:
        print(f" [ERROR] Unexpected error: {str(e)}")
        return {'status': 'error', 'message': f'Unexpected error: {str(e)}'}

def test_performance_monitoring() -> Dict[str, Any]:
    """Test performance monitoring system."""
    print("\n=== Performance Monitoring Test ===")
    
    try:
        from noodlecore.self_improvement.nc_performance_monitor import get_nc_performance_monitor
        
        monitor = get_nc_performance_monitor()
        
        # Test activation
        print("Testing performance monitor activation...")
        activation_result = monitor.start_monitoring()
        
        if activation_result:
            print(" [OK] Performance monitor activated successfully")
            return {'status': 'success', 'message': 'Performance monitor activated'}
        else:
            print(" [ERROR] Performance monitor activation failed")
            return {'status': 'error', 'message': 'Performance monitor activation failed'}
            
    except ImportError as e:
        print(f" [ERROR] Import error: {str(e)}")
        return {'status': 'error', 'message': f'Import error: {str(e)}'}
    except Exception as e:
        print(f" [ERROR] Unexpected error: {str(e)}")
        return {'status': 'error', 'message': f'Unexpected error: {str(e)}'}

def test_ai_decision_engine() -> Dict[str, Any]:
    """Test AI decision engine integration."""
    print("\n=== AI Decision Engine Test ===")
    
    try:
        from noodlecore.self_improvement.enhanced_ai_decision_engine import get_enhanced_ai_decision_engine
        
        engine = get_enhanced_ai_decision_engine()
        
        # Test basic functionality
        print("Testing AI decision engine basic functionality...")
        
        # Test upgrade approval decision
        try:
            from noodlecore.self_improvement.runtime_upgrade.models import UpgradeRequest, UpgradeStrategy
            
            test_request = UpgradeRequest(
                request_id="test-123",
                component_name="test_component",
                current_version="1.0.0",
                target_version="2.0.0",
                strategy=UpgradeStrategy.GRADUAL,
                rollback_enabled=True,
                validation_enabled=True
            )
            
            decision = engine.make_upgrade_approval_decision(test_request)
            print(f" [OK] Upgrade approval decision: {decision.decision_type.value} (confidence: {decision.confidence:.2f})")
            
        except Exception as e:
            print(f" [ERROR] AI decision engine error: {str(e)}")
            return {'status': 'error', 'message': f'AI decision engine error: {str(e)}'}
        
        return {'status': 'success', 'message': 'AI decision engine basic functionality working'}
        
    except ImportError as e:
        print(f" [ERROR] Import error: {str(e)}")
        return {'status': 'error', 'message': f'Import error: {str(e)}'}
    except Exception as e:
        print(f" [ERROR] Unexpected error: {str(e)}")
        return {'status': 'error', 'message': f'Unexpected error: {str(e)}'}

def test_runtime_upgrade_system() -> Dict[str, Any]:
    """Test runtime upgrade system integration."""
    print("\n=== Runtime Upgrade System Test ===")
    
    try:
        from noodlecore.self_improvement.runtime_upgrade.runtime_upgrade_manager import get_runtime_upgrade_manager
        
        manager = get_runtime_upgrade_manager()
        
        # Test basic functionality
        print("Testing runtime upgrade manager basic functionality...")
        
        # Test upgrade feasibility
        feasibility = manager.analyze_upgrade_feasibility("test_component", "1.0.0", "2.0.0")
        print(f" [OK] Upgrade feasibility analysis: {feasibility.get('feasible', False)}")
        
        # Test upgrade request
        try:
            import asyncio
            
            async def test_upgrade():
                result = await manager.request_upgrade(
                    component_name="test_component",
                    target_version="2.0.0",
                    strategy="gradual"
                )
                print(f" [OK] Upgrade request result: {result.success} (status: {result.status.value})")
                return result
            
            # Run the test
            result = asyncio.run(test_upgrade())
            
        except Exception as e:
            print(f" [ERROR] Runtime upgrade system error: {str(e)}")
            return {'status': 'error', 'message': f'Runtime upgrade system error: {str(e)}'}
        
        return {'status': 'success', 'message': 'Runtime upgrade system basic functionality working'}
        
    except ImportError as e:
        print(f" [ERROR] Import error: {str(e)}")
        return {'status': 'error', 'message': f'Import error: {str(e)}'}
    except Exception as e:
        print(f" [ERROR] Unexpected error: {str(e)}")
        return {'status': 'error', 'message': f'Unexpected error: {str(e)}'}

def fix_common_issues() -> List[str]:
    """Attempt to fix common self-improvement issues."""
    fixes = []
    
    # Fix environment variables
    print("Attempting to fix environment variables...")
    os.environ['NOODLE_SELF_IMPROVEMENT'] = '1'
    os.environ['NOODLE_AUTO_ACTIVATION'] = '1'
    os.environ['NOODLE_ADAPTIVE_OPTIMIZATION'] = '1'
    os.environ['NOODLE_DEBUG'] = '0'  # Enable debug for troubleshooting
    fixes.append("Set critical environment variables (NOODLE_SELF_IMPROVEMENT=1, NOODLE_AUTO_ACTIVATION=1)")
    
    return fixes

def main():
    """Main diagnostic function."""
    verbose = '--verbose' in sys.argv or '--fix-issues' in sys.argv
    
    setup_logging()
    
    print("NoodleCore Self-Improvement System Diagnostic")
    print("=" * 50)
    
    # Check environment variables
    env_result = check_environment_variables()
    if env_result['issues']:
        print(f"\n[WARNING] Environment Issues Found:")
        for issue in env_result['issues']:
            print(f"  - {issue}")
    
    # Test self-improvement manager
    manager_result = test_self_improvement_manager()
    if verbose or manager_result['status'] != 'success':
        print(f"\n[STATUS] Self-Improvement Manager Status: {manager_result['status']}")
        print(f"[MESSAGE] Message: {manager_result['message']}")
    
    # Test feedback collector
    collector_result = test_feedback_collector()
    if verbose or collector_result['status'] != 'success':
        print(f"\n[STATUS] Feedback Collector Status: {collector_result['status']}")
        print(f"[MESSAGE] Message: {collector_result['message']}")
    
    # Test adaptive optimizer
    optimizer_result = test_adaptive_optimizer()
    if verbose or optimizer_result['status'] != 'success':
        print(f"\n[STATUS] Adaptive Optimizer Status: {optimizer_result['status']}")
        print(f"[MESSAGE] Message: {optimizer_result['message']}")
    
    # Test performance monitoring
    monitor_result = test_performance_monitoring()
    if verbose or monitor_result['status'] != 'success':
        print(f"\n[STATUS] Performance Monitor Status: {monitor_result['status']}")
        print(f"[MESSAGE] Message: {monitor_result['message']}")
    
    # Test AI decision engine
    ai_result = test_ai_decision_engine()
    if verbose or ai_result['status'] != 'success':
        print(f"\n[STATUS] AI Decision Engine Status: {ai_result['status']}")
        print(f"[MESSAGE] Message: {ai_result['message']}")
    
    # Test runtime upgrade system
    upgrade_result = test_runtime_upgrade_system()
    if verbose or upgrade_result['status'] != 'success':
        print(f"\n[STATUS] Runtime Upgrade System Status: {upgrade_result['status']}")
        print(f"[MESSAGE] Message: {upgrade_result['message']}")
    
    # Apply fixes if requested
    if '--fix-issues' in sys.argv:
        fixes = fix_common_issues()
        if fixes:
            print(f"\n[FIX] Applied Fixes:")
            for fix in fixes:
                print(f"  - {fix}")
        else:
            print("\n[FIX] No automatic fixes applied")
    
    # Summary
    print("\n" + "=" * 50)
    print("DIAGNOSTIC SUMMARY")
    
    all_results = [
        ('Environment Variables', env_result),
        ('Self-Improvement Manager', manager_result),
        ('Feedback Collector', collector_result),
        ('Adaptive Optimizer', optimizer_result),
        ('Performance Monitor', monitor_result),
        ('AI Decision Engine', ai_result),
        ('Runtime Upgrade System', upgrade_result)
    ]
    
    success_count = sum(1 for name, result in all_results if result.get('status') == 'success')
    
    print(f"Overall Status: {success_count}/{len(all_results)} components working correctly")
    
    if success_count == len(all_results):
        print("[OK] All systems are functioning correctly!")
    else:
        print("[WARNING] Some systems have issues that need attention")
    
    print("\nRECOMMENDATIONS:")
    print("1. Ensure NOODLE_SELF_IMPROVEMENT=1 is set in your environment")
    print("2. Set NOODLE_AUTO_ACTIVATION=1 to enable automatic activation")
    print("3. Check that all required dependencies are installed")
    print("4. Run this diagnostic script regularly to monitor system health")
    print("5. If issues persist, check the logs for specific error messages")

if __name__ == "__main__":
    main()

